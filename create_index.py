"""Generate a room index from a SCUMM resource file.

The tool looks for ``LOFF`` and optionally ``RNAM`` chunks inside the given file
and writes a text listing with pairs of ``ROOM-ID`` and ``ROOM-NAME`` entries.
"""

import argparse
import struct
from pathlib import Path


def _get_chunk_offset(data: bytes, tag: str) -> int:
    """Return the byte offset of ``tag`` in *data* or -1 if not found."""
    return data.find(tag.encode("ascii"))


def _read_u32_be(data: bytes, offset: int) -> int:
    return struct.unpack_from(">I", data, offset)[0]


def _read_u32_le(data: bytes, offset: int) -> int:
    return struct.unpack_from("<I", data, offset)[0]


def parse_loff(data: bytes) -> list[tuple[int, int]]:
    """Return a list of ``(room_id, room_offset)`` pairs from the LOFF chunk."""

    offset = _get_chunk_offset(data, "LOFF")
    if offset == -1:
        raise ValueError("LOFF chunk not found")

    size = _read_u32_be(data, offset + 4)
    pos = offset + 8
    count = data[pos]
    pos += 1

    if pos + count * 5 > offset + 8 + size:
        raise ValueError("Truncated LOFF chunk")

    entries = []
    for _ in range(count):
        room_id = data[pos]
        room_offset = _read_u32_le(data, pos + 1)
        entries.append((room_id, room_offset))
        pos += 5
    return entries


def parse_rnam(data: bytes) -> list[str]:
    """Return room names from the RNAM chunk if present."""

    offset = _get_chunk_offset(data, "RNAM")
    if offset == -1:
        return []

    size = _read_u32_be(data, offset + 4)
    pos = offset + 8
    end = pos + size
    names = []
    while pos < end:
        terminator = data.find(b"\x00", pos, end)
        if terminator == -1:
            break
        names.append(data[pos:terminator].decode("utf-8", errors="replace"))
        pos = terminator + 1
    return names


def build_index(file: Path) -> str:
    """Return text for the room index read from *file*."""

    data = file.read_bytes()
    rooms = parse_loff(data)
    names = parse_rnam(data)

    lines: list[str] = []
    for idx, (room_id, _) in enumerate(rooms):
        name = names[idx] if idx < len(names) else f"room_{room_id}"
        lines.append(f"ROOM-ID: {room_id}")
        lines.append(f"ROOM-NAME: {name}")
        lines.append("")
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description="Create room index from a SCUMM resource file")
    parser.add_argument("resource", type=Path, help="Input resource file")
    parser.add_argument("-o", "--output", type=Path, default=Path("room_index.txt"), help="Output text file")
    args = parser.parse_args()

    output = args.output
    if output.exists():
        stem = output.stem
        suffix = output.suffix
        parent = output.parent
        counter = 1
        while output.exists():
            output = parent / f"{stem}_{counter}{suffix}"
            counter += 1

    index_text = build_index(args.resource)
    output.write_text(index_text, encoding="utf-8")
    print(f"Index written to {output}")


if __name__ == "__main__":
    main()
