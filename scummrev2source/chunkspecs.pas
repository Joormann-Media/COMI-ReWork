unit ChunkSpecs;

interface

uses
  Forms;

const
  ImageNone     = -1;
  Image3D       = 0;
  ImageAHeader  = 1;
  ImageAKOS     = 2;
  ImageAmiga    = 3;
  ImageBox      = 4;
  ImageBoxMatrix= 5;
  ImageBundle   = 6;
  ImageCDHeader = 7;
  ImageChar     = 8;
  ImageComp     = 9;
  ImageCOHeader = 10;
  ImageCostume  = 11;
  ImageCycle    = 12;
  ImageDCHR     = 13;
  ImageDCOS     = 14;
  ImageDialogue = 15;
  ImageDigital  = 16;
  ImageDOBJ     = 17;
  ImageDROO     = 18;
  ImageDSCR     = 19;
  ImageDSOU     = 20;
  ImageENCD     = 21;
  ImageEXCD     = 22;
  ImageGlobals  = 23;
  ImageIACT     = 24;
  ImageImage    = 25;
  ImageIMHD     = 26;
  ImageiMUSE    = 27;
  ImageKey      = 28;
  ImageMap      = 29;
  ImageMaterial = 30;
  ImageMIDI     = 31;
  ImageMovie    = 32;
  ImageOBIM     = 33;
  ImagePalette  = 34;
  ImageRMHD     = 35;
  ImageRMIH     = 36;
  ImageRMIM     = 37;
  ImageRoom     = 38;
  ImageSave     = 39;
  ImageScale    = 40;
  ImageScript   = 41;
  ImageSMAP     = 42;
  ImageSync     = 43;
  ImageTable    = 44;
  ImageText     = 45;
  ImageTrans    = 46;
  ImageUnknown  = 47;
  ImageUsed     = 48;
  ImageVars     = 49;
  ImageVerb     = 50;
  ImageWave     = 51;
  ImageZPlane   = 52;
  ImageFImage   = 53;
  ImageFKey     = 54;
  ImageFMovie   = 55;
  ImageFPalette = 56;
  ImageFScript  = 57;
  ImageFSCUMM   = 58;
  ImageFSound   = 59;
  ImageFWrap    = 60;

type
  TChunkType =  ( ctNull,
                  ctStart,
                  //Standard File
                  //Headers
                  ctLECF, ctLOFF, ctLFLF, ctROOM,
                  //Rooms
                  ctRMHD, ctCYCL, ctTRNS, ctEPAL, ctBOXD,
                  ctBOXM, ctCLUT, ctSCAL, ctPALS, ctWRAP,
                  ctOFFS, ctAPAL, ctRMIM, ctOBIM, ctRMSC,
                  //Images
                  ctRMIH, ctIMHD, ctIM00, ctIM01, ctIM02,
                  ctIM03, ctIM04, ctIM05, ctIM06, ctIM07,
                  ctIM08, ctIM09, ctIM0A, ctIM0B, ctIM0C,
                  ctIM0D, ctIM0E, ctIM0F,
                  ctIMAG, ctSMAP,
                  ctBSTR, ctZPLN, ctZSTR, ctBOMP,
                  //ZPs
                  ctZP00, ctZP01, ctZP02, ctZP03, ctZP04,
                  //Code
                  ctOBCD, ctCDHD, ctVERB, ctOBNA, ctEXCD,
                  ctENCD, ctNLSC, ctLSCR, ctSCRP,
                  //Sound/MIDI
                  ctSOUN, ctSOU , ctADL , ctSBL , ctROL ,
                  ctSPK , ctGMD , ctMIDI, ctVCTL, ctVTTL,
                  ctVTLK, ctCrea,
                  //Actor
                  ctAKOS, ctAKHD, ctAKPL, ctRGBS, ctAKSQ,
                  ctAKCH, ctAKOF, ctAKCI, ctAKCD,
                  //Other
                  ctCOST, ctCHAR,

                  //Savegame Files
                  //Header
                  ctSAVE, ctSG09,
                  //Stuff
                  ctVARS, ctSNDD, ctGLOB, ctUSED, ctSIMUS,
                  ctMSCR,

                  //Directory Files
                  ctRNAM, ctMAXS, ctDROO, ctDRSC, ctDSCR,
                  ctDSOU, ctDCOS, ctDCHR, ctDOBJ, ctAARY,
                  ctANAM,

                  //Something...
                  ctFLUP,

                  //SMUSH Animation Files
                  //Headers
                  ctANIM, ctAHDR, ctFRME,
                  //Stuff
                  ctFOBJ, ctIACT, ctNPAL, ctFTCH, ctSTOR,
                  ctXPAL,
                  ctPSAD, ctSAUD, ctSTRK, ctSDAT, ctTRES,
                  ctSANM, ctSHDR, ctFLHD, ctBl16, ctWave,

                  //LAB/BUN Files
                  //Headers
                  ctLABN, ctLB83, ctMCMP, ctCOMP,
                  //iMUS
                  ctiMUS, ctMAP , ctFRMT, ctJUMP, ctREGN,
                  ctTEXT, ctSTOP, ctSYNC, ctDATA,

                  ctLDOM, ctFYEK, ctRIFF, ctMAT , ctBM_ ,
                  ctCMP ,

                  //Files
                  fctFileStart,
                  fctIMU , fctIMC , fctIMX , fctWAV , fctLIP ,
                  fct3DO , fctCOS , fctMAT , fctKEY , fctBM  ,
                  fctZBM , fctCMP , fctSET , fctTXT , fctSNM ,
                  fctLUA , fctLAF , fctXXX ,
                  fctGCF , fctSPR , fctBMP , fctWM,
                  fctBAF ,
                  //Unknown
                  fctFileUnknown,

                  //Old Format
                  //Headers
                  ctLE, ctFO, ctLF, ctRO,
                  //Rooms
                  ctHD, ctCC, ctSP, ctBX, ctBM,
                  ctPA, ctSA,
                  //Images
                  ctOI,
                  //Sound
                  ctSO, ctWA, ctAD,
                  //Scripts
                  ctSC,
                  ctNL, ctSL, ctOC, ctEX, ctEN,
                  ctLC, ctLS, ctCO,
                  //Amiga specific
                  ctAM,
                  //Directory
                  ctRN, ct0R, ct0S, ct0N, ct0C,
                  ct0O,

                  //Amiga Specific Blocks
                  ctPLIB, ctLHDR, ctPDAT, ctPTCH, ctPHDR,
                  ctSDATAmiga, ctAMI,

                  //Language tables
                  ctRCNE,

                  //Unknown
                  ctUnknown,

                  ctEnd
                  );

  TSizeFormat = ( csfStd,   // Standard
                  csfNHS,   // Without Header/Size
                  csfNHSI,  // Without Header/Size + Inconsistent...
                  csfInc,   // Inconsistent
                  csfUnP,   // Undefined - based on parent
                  csfEnt,   // Entry Based
                  csfDir,   // Directory Table
                  csfOld,   // Old Format
                  csfCrea,  // Creative Voice File
                  csfUnk    // Unknown
                  );

  TChildFrmt  = ( coNull, co8, co18, coLABN, coLB83, coFile, coOld, coOldS, coNone, coUnk
                  );

  TChunkSpec  = record
    Name      : String;
    Desc      : String;
    SizeFrmt  : TSizeFormat;
    ChildFrmt : TChildFrmt;
    SpecProc  : procedure(AOffset: cardinal; ASize: cardinal) of object;
    Image     : integer;
  end;

  TFileType = ( ftStdSCUMM, ftBundle, ftCMIBundle, ftANIM, ftRCNE,
                ftDir, ftSave, ftMonster, ftFLUP, ftOld, ftOldRoom, ftUnknown );

const
  HelpItems : set of TChunkType = [ctADL, ctAMI, ctAPAL, ctCLUT, ctCrea, ctDATA,
              fctIMC, fctIMX, fctLua, fctTXT, fctWAV, ctFRMT, ctGMD, ctiMUS,
              ctJUMP, ctLABN, ctLB83, ctLECF, ctLFLF, ctLOFF, ctMAP, ctMCMP,
              ctMIDI, ctNPAL, ctOFFS, ctPALS, ctRIFF, ctRMSC, ctROL, ctROOM,
              ctSPK,  ctSTOP, ctWRAP];

  NoOfXORTries  = 3;
  XORTries: array[0..NoOfXorTries-1] of byte = ( $00, $69, $FF );

  HeaderSpec: array[ftStdSCUMM..ftUnknown] of TChunkType = (
    ctLECF, ctLABN, ctLB83, ctANIM, ctRCNE, ctRNAM, ctSAVE, ctSOU, ctFLUP, ctLE, ctRO, ctUnknown);

  FileTypeName: array[ftStdSCUMM..ftUnknown] of string = (
    'Standard SCUMM',
    'Bundle',
    'CMI/Dig Bundle',
    'SMUSH/Font',
    'Language table',
    'Directory',
    'Savegame',
    'Monster Sound',
    'FLUP...',
    'Old SCUMM Bundled',
    'Old SCUMM Single Room',
    '[Unknown]'
    );
var
  ChunkSpec: array[ctNull..ctEnd] of TChunkSpec = (
    (Name: ' '; Desc: '';
     SizeFrmt: csfUnk; ChildFrmt: coNull; SpecProc: nil;
     Image: ImageNone),
    (Name: ' '; Desc: '';
     SizeFrmt: csfUnk; ChildFrmt: coUnk; SpecProc: nil;
     Image: ImageNone),

    //Standard Files
    (Name: 'LECF'; Desc: 'LucasArts Entertainment Company File';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageBundle),
    (Name: 'LOFF'; Desc: 'Room Offset Table';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageTable),
    (Name: 'LFLF'; Desc: 'LucasArts File Format';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImagefSCUMM),
    (Name: 'ROOM'; Desc: 'Room';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageRoom),
    (Name: 'RMHD'; Desc: 'Room Header';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageRMHD),
    (Name: 'CYCL'; Desc: 'Color Cycle?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageCycle),
    (Name: 'TRNS'; Desc: 'Transparency?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageTrans),
    (Name: 'EPAL'; Desc: 'Enhanced? Palette';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImagePalette),
    (Name: 'BOXD'; Desc: 'Box Description';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageBox),
    (Name: 'BOXM'; Desc: 'Box Matrix';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageBoxMatrix),
    (Name: 'CLUT'; Desc: 'Color LookUp Table';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImagePalette),
    (Name: 'SCAL'; Desc: 'Scaling?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageScale),
    (Name: 'PALS'; Desc: 'Palettes';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageFPalette),
    (Name: 'WRAP'; Desc: 'Wrapper';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageFWrap),
    (Name: 'OFFS'; Desc: 'Wrapper Offsets';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageTable),
    (Name: 'APAL'; Desc: 'A? Palette';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImagePalette),
    (Name: 'RMIM'; Desc: 'Room Image';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageRMIM),
    (Name: 'OBIM'; Desc: 'Object Image';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageOBIM),
    (Name: 'RMSC'; Desc: 'Room Scripts';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageFScript),
    (Name: 'RMIH'; Desc: 'Room Image Header';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageRMIH),
    (Name: 'IMHD'; Desc: 'Image Header';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageIMHD),
    (Name: 'IM00'; Desc: 'Image';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageImage),
    (Name: 'IM01'; Desc: 'Image';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageImage),
    (Name: 'IM02'; Desc: 'Image';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageImage),
    (Name: 'IM03'; Desc: 'Image';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageImage),
    (Name: 'IM04'; Desc: 'Image';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageImage),
    (Name: 'IM05'; Desc: 'Image';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageImage),
    (Name: 'IM06'; Desc: 'Image';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageImage),
    (Name: 'IM07'; Desc: 'Image';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageImage),
    (Name: 'IM08'; Desc: 'Image';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageImage),
    (Name: 'IM09'; Desc: 'Image';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageImage),
    (Name: 'IM0A'; Desc: 'Image';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageImage),
    (Name: 'IM0B'; Desc: 'Image';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageImage),
    (Name: 'IM0C'; Desc: 'Image';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageImage),
    (Name: 'IM0D'; Desc: 'Image';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageImage),
    (Name: 'IM0E'; Desc: 'Image';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageImage),
    (Name: 'IM0F'; Desc: 'Image';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageImage),
    (Name: 'IMAG'; Desc: 'Image';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageImage),
    (Name: 'SMAP'; Desc: 'Pixelmap';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageSMAP),
    (Name: 'BSTR'; Desc: 'Blast <something>?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageSMAP),
    (Name: 'ZPLN'; Desc: 'Z Plane?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageZPlane),
    (Name: 'ZSTR'; Desc: 'Z Buffer String?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageZPlane),
    (Name: 'BOMP'; Desc: 'Blast Object Map?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageSMAP),
    (Name: 'ZP00'; Desc: 'Z Plane?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageZPlane),
    (Name: 'ZP01'; Desc: 'Z Plane?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageZPlane),
    (Name: 'ZP02'; Desc: 'Z Plane?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageZPlane),
    (Name: 'ZP03'; Desc: 'Z Plane?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageZPlane),
    (Name: 'ZP04'; Desc: 'Z Plane?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageZPlane),
    (Name: 'OBCD'; Desc: 'Object Code';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageFScript),
    (Name: 'CDHD'; Desc: 'Code Header';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageCDHeader),
    (Name: 'VERB'; Desc: 'Verbs';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageVerb),
    (Name: 'OBNA'; Desc: 'Object Name';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageText),
    (Name: 'EXCD'; Desc: 'Exit Code';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageEXCD),
    (Name: 'ENCD'; Desc: 'Entry Code';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageENCD),
    (Name: 'NLSC'; Desc: 'Non Local Script?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageScript),
    (Name: 'LSCR'; Desc: 'Local Script?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageScript),
    (Name: 'SCRP'; Desc: 'Script';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageScript),
    (Name: 'SOUN'; Desc: 'Sound';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageFSound),
    (Name: 'SOU '; Desc: 'Sound';
     SizeFrmt: csfUnP; ChildFrmt: co8; SpecProc: nil;
     Image: ImageFSound),
    (Name: 'ADL '; Desc: 'Adlib MIDI';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageMIDI),
    (Name: 'SBL '; Desc: 'SoundBlaster Wave File';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageDigital),
    (Name: 'ROL '; Desc: 'Roland MT-32 MIDI';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageMIDI),
    (Name: 'SPK '; Desc: 'PC Speaker MIDI';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageMIDI),
    (Name: 'GMD '; Desc: 'General MIDI';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageMIDI),
    (Name: 'MIDI'; Desc: 'General MIDI';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageMIDI),
    (Name: 'VCTL'; Desc: 'Voice - Creative Labs File';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageDialogue),
    (Name: 'VTTL'; Desc: 'Voice?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageDialogue),
    (Name: 'VTLK'; Desc: 'Voice Talk???';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageDialogue),
    (Name: 'Crea'; Desc: 'Creative Labs Voice File';
     SizeFrmt: csfCrea; ChildFrmt: coNone; SpecProc: nil;
     Image: ImageDigital),

    (Name: 'AKOS'; Desc: 'Actor Costume';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageCostume),
    (Name: 'AKHD'; Desc: 'Actor Header?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageCOHeader),
    (Name: 'AKPL'; Desc: 'Actor Palette?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImagePalette),
    (Name: 'RGBS'; Desc: 'RGB Values?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImagePalette),
    (Name: 'AKSQ'; Desc: '?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageUnknown),
    (Name: 'AKCH'; Desc: 'Actor Costume Header?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageCDHeader),
    (Name: 'AKOF'; Desc: 'Actor Offsets?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageTable),
    (Name: 'AKCI'; Desc: 'Actor <something>';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageUnknown),
    (Name: 'AKCD'; Desc: 'Actor Costume Description?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageScript),
    (Name: 'COST'; Desc: 'Costume';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageCostume),
    (Name: 'CHAR'; Desc: 'Character Set?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageChar),

    //Savegame Files
    (Name: 'SAVE'; Desc: 'Savegame';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageSave),
    (Name: 'SG09'; Desc: 'Grim Fandango Savegame';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageSave),
    (Name: 'VARS'; Desc: 'Savegame Variables';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageVars),
    (Name: 'SNDD'; Desc: 'Savegame Sound <something>?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageiMUSE),
    (Name: 'GLOB'; Desc: 'Savegame Globals';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageGlobals),
    (Name: 'USED'; Desc: 'Savegame <something>';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageUsed),
    (Name: 'IMUS'; Desc: 'Savegame iMUSE Info';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageiMUSE),
    (Name: 'MSCR'; Desc: 'Savegame <something>';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageUnknown),

    //Directory Files
    (Name: 'RNAM'; Desc: '?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageUnknown),
    (Name: 'MAXS'; Desc: '?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageAKOS),
    (Name: 'DROO'; Desc: 'Directory of Rooms';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageDROO),
    (Name: 'DRSC'; Desc: 'Directory of Room Scripts?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageDSCR),
    (Name: 'DSCR'; Desc: 'Directory of Scripts';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageDSCR),
    (Name: 'DSOU'; Desc: 'Directory of Sound';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageDSOU),
    (Name: 'DCOS'; Desc: 'Directory of Costumes';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageDCOS),
    (Name: 'DCHR'; Desc: 'Directory of Character Sets?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageDCHR),
    (Name: 'DOBJ'; Desc: 'Directory of Objects';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageDOBJ),
    (Name: 'AARY'; Desc: '<something> Array?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageUnknown),
    (Name: 'ANAM'; Desc: '<something> Name?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageUnknown),

    //Something...
    (Name: 'FLUP'; Desc: '<fomething> Lookup?';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageUnknown),

    //SMUSH Animation Files
    (Name: 'ANIM'; Desc: 'SMUSH Animation File';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageFMovie),
    (Name: 'AHDR'; Desc: 'SMUSH Animation Header';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageAHeader),
    (Name: 'FRME'; Desc: 'Frame?';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageFMovie),
    (Name: 'FOBJ'; Desc: 'Frame Object?';
     SizeFrmt: csfNHSI; ChildFrmt: co8; SpecProc: nil;
     Image: ImageMovie),
    (Name: 'IACT'; Desc: 'iMUSE <something>';
     SizeFrmt: csfNHSI; ChildFrmt: co8; SpecProc: nil;
     Image: ImageIACT),
    (Name: 'NPAL'; Desc: '<something> Palette';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImagePalette),
    (Name: 'FTCH'; Desc: 'Fetch?';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageUnknown),
    (Name: 'STOR'; Desc: 'Store?';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageUnknown),
    (Name: 'XPAL'; Desc: 'Crossfade Palette?';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImagePalette),
    (Name: 'PSAD'; Desc: 'Audio?';
     SizeFrmt: csfNHSI; ChildFrmt: co18; SpecProc: nil;
     Image: ImageIACT),
    (Name: 'SAUD'; Desc: 'SMUSH Audio?';
     SizeFrmt: csfUnP; ChildFrmt: co8; SpecProc: nil;
     Image: ImageIACT),
    (Name: 'STRK'; Desc: 'SMUSH Audio Track?';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageIACT),
    (Name: 'SDAT'; Desc: 'SMUSH Audio Data?';
     SizeFrmt: csfUnP; ChildFrmt: co8; SpecProc: nil;
     Image: ImageIACT),
    (Name: 'TRES'; Desc: '?';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageUnknown),

    (Name: 'SANM'; Desc: 'SMUSH Animation';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageFMovie),
    (Name: 'SHDR'; Desc: 'SMUSH Header';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageAHeader),
    (Name: 'FLHD'; Desc: 'FLObject Header?';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageAHeader),
    (Name: 'Bl16'; Desc: '16 bit something?';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageAHeader),
    (Name: 'Wave'; Desc: 'Digital Sound Wave';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageAHeader),

     //LAB/BUN Files
    (Name: 'LABN'; Desc: 'LucasArts Bundle';
     SizeFrmt: csfUnP; ChildFrmt: coLABN; SpecProc: nil;
     Image: ImageBundle),
    (Name: 'LB83'; Desc: 'LucasArts Bundle';
     SizeFrmt: csfStd; ChildFrmt: coLB83; SpecProc: nil;
     Image: ImageBundle),
    (Name: 'MCMP'; Desc: 'Compression Map';
     SizeFrmt: csfEnt; ChildFrmt: co8; SpecProc: nil;
     Image: ImageComp),
    (Name: 'COMP'; Desc: 'Compression Map';
     SizeFrmt: csfEnt; ChildFrmt: co8; SpecProc: nil;
     Image: ImageComp),
    (Name: 'iMUS'; Desc: 'iMUSE Digital Sound';
     SizeFrmt: csfUnP; ChildFrmt: co8; SpecProc: nil;
     Image: ImageFSound),
    (Name: 'MAP '; Desc: 'iMUSE Map';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageMap),
    (Name: 'FRMT'; Desc: 'iMUSE Sound Format';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageWave),
    (Name: 'JUMP'; Desc: 'iMUSE Jump Hook';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageiMUSE),
    (Name: 'REGN'; Desc: 'iMUSE Region';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageiMUSE),
    (Name: 'TEXT'; Desc: 'iMUSE Text';
     SizeFrmt: csfNHSI; ChildFrmt: co8; SpecProc: nil;
     Image: ImageText),
    (Name: 'STOP'; Desc: 'iMUSE Stop Hook';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageiMUSE),
    (Name: 'SYNC'; Desc: 'iMUSE Voice Synchronization';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageSync),
    (Name: 'DATA'; Desc: 'iMUSE Sound Data';
     SizeFrmt: csfUnP; ChildFrmt: co8; SpecProc: nil;
     Image: ImageDigital),

    (Name: 'LDOM'; Desc: '3D Model';
     SizeFrmt: csfUnP; ChildFrmt: co8; SpecProc: nil;
     Image: Image3D),
    (Name: 'FYEK'; Desc: 'Keyframe';
     SizeFrmt: csfUnP; ChildFrmt: co8; SpecProc: nil;
     Image: ImageKey),
    (Name: 'MAT '; Desc: 'Material';
     SizeFrmt: csfUnP; ChildFrmt: co8; SpecProc: nil;
     Image: ImageMaterial),
    (Name: 'RIFF'; Desc: '(Compressed) RIFF Wave File';
     SizeFrmt: csfUnP; ChildFrmt: coNone; SpecProc: nil;
     Image: ImageDigital),
    (Name: 'BM  '; Desc: 'Bitmap';
     SizeFrmt: csfUnP; ChildFrmt: co8; SpecProc: nil;
     Image: ImageImage),
    (Name: 'CMP '; Desc: 'Color Map';
     SizeFrmt: csfUnP; ChildFrmt: co8; SpecProc: nil;
     Image: ImagePalette),

    (Name: ' '; Desc: '';
     SizeFrmt: csfUnk; ChildFrmt: coUnk; SpecProc: nil;
     Image: ImageNone),
    (Name: '.IMU'; Desc: 'Compressed(?) iMUSE Cue';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: ImageFSound),
    (Name: '.IMC'; Desc: 'Compressed iMUSE Cue';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: ImageFSound),
    (Name: '.IMX'; Desc: 'Compressed iMUSE Cue';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: ImageFSound),
    (Name: '.WAV'; Desc: 'Compressed .WAV File';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: ImageFSound),
    (Name: '.LIP'; Desc: 'Lip Synchronization';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: ImageSync),
    (Name: '.3DO'; Desc: '3D Object';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: Image3D),
    (Name: '.COS'; Desc: 'Costume?';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: ImageCostume),
    (Name: '.MAT'; Desc: 'Material';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: ImageMaterial),
    (Name: '.KEY'; Desc: 'Keyframe';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: ImageFKey),
    (Name: '.BM'; Desc: 'Bitmap';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: ImageFImage),
    (Name: '.ZBM'; Desc: 'Z Buffer Map';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: ImageZPlane),
    (Name: '.CMP'; Desc: 'Color Map?';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: ImagePalette),
    (Name: '.SET'; Desc: 'Room Setup?';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: ImageRMHD),
    (Name: '.TXT'; Desc: 'Plain Text';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: ImageText),
    (Name: '.SNM'; Desc: 'Insane Movie? SMUSH aNiMation?';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: ImageFMovie),
    (Name: '.LUA'; Desc: 'Compiled LUA Script';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: ImageScript),
    (Name: '.LAF'; Desc: 'LucasArts Font';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: ImageChar),
    (Name: '.XXX'; Desc: 'Voice?';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: ImageFSound),
    (Name: '.GCF'; Desc: 'Font Info?';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: ImageChar),
    (Name: '.SPR'; Desc: 'Font Info?';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: ImageChar),
    (Name: '.BMP'; Desc: 'Bitmap';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: ImageImage),
    (Name: '.WM'; Desc: 'Voice file';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: ImageDigital),
    (Name: '.BAF'; Desc: '3D Model?';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: Image3D),
    (Name: '.???'; Desc: 'Unknown LAB/BUN File Type!';
     SizeFrmt: csfDir; ChildFrmt: coFile; SpecProc: nil;
     Image: ImageUnknown),

    //Old Format
    (Name: 'LE'; Desc: 'LucasArts Entertainment Company File';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageBundle),
    (Name: 'FO'; Desc: 'File Offsets';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageTable),
    (Name: 'LF'; Desc: 'LucasArts File Format';
     SizeFrmt: csfOld; ChildFrmt: coOldS; SpecProc: nil;
     Image: ImageFSCUMM),
    (Name: 'RO'; Desc: 'Room';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageRoom),
    (Name: 'HD'; Desc: 'Room Header';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageRMHD),
    (Name: 'CC'; Desc: 'Color Cycle?';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageCycle),
    (Name: 'SP'; Desc: '?';
     SizeFrmt: csfOld; ChildFrmt: coNone; SpecProc: nil;
     Image: ImageUnknown),
    (Name: 'BX'; Desc: 'Box Description and Matrix';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageBox),
    (Name: 'BM'; Desc: 'Bitmap';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageRMIM),
    (Name: 'PA'; Desc: 'Palette';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImagePalette),
    (Name: 'SA'; Desc: '?';
     SizeFrmt: csfOld; ChildFrmt: coNone; SpecProc: nil;
     Image: ImageUnknown),
    (Name: 'OI'; Desc: 'Object Image';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageOBIM),
    (Name: 'SO'; Desc: 'Sound';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageFSound),
    (Name: 'WA'; Desc: 'Wave?';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageDigital),
    (Name: 'AD'; Desc: 'Adlib?';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageMIDI),
    (Name: 'SC'; Desc: 'Script';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageScript),
    (Name: 'NL'; Desc: 'Script?';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageScript),
    (Name: 'SL'; Desc: 'Script?';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageScript),
    (Name: 'OC'; Desc: 'Object Code?';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageScript),
    (Name: 'EN'; Desc: 'Entry Code?';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageENCD),
    (Name: 'EX'; Desc: 'Exit Code?';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageEXCD),
    (Name: 'LC'; Desc: '?';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageUnknown),
    (Name: 'LS'; Desc: 'Local Script?';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageScript),
    (Name: 'CO'; Desc: 'Costume?';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageCostume),
    (Name: 'AM'; Desc: 'Some Amiga Specific Block';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageAmiga),
    (Name: 'RN'; Desc: '?';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageUnknown),
    (Name: '0R'; Desc: 'Directory of Rooms?';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageDROO),
    (Name: '0S'; Desc: 'Directory of Scripts (or Sounds)?';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageDSCR),
    (Name: '0N'; Desc: 'Directory of <something>?';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageUnknown),
    (Name: '0C'; Desc: 'Directory of Costumes?';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageDCOS),
    (Name: '0O'; Desc: 'Directory of Objects?';
     SizeFrmt: csfOld; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageDOBJ),

    // Amiga specific blocks
    (Name: 'PLIB'; Desc: '<Something> Library?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageUnknown),
    (Name: 'LHDR'; Desc: 'Library Header?';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageUnknown),
    (Name: 'PDAT'; Desc: '<Something> Data?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageUnknown),
    (Name: 'PTCH'; Desc: '?';
     SizeFrmt: csfStd; ChildFrmt: co8; SpecProc: nil;
     Image: ImageUnknown),
    (Name: 'PHDR'; Desc: '?';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageUnknown),
    (Name: 'SDAT'; Desc: 'Sound Data?';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageUnknown),
    (Name: 'AMI '; Desc: 'Amiga MIDI file';
     SizeFrmt: csfNHS; ChildFrmt: co8; SpecProc: nil;
     Image: ImageMIDI),

    (Name: 'RCNE'; Desc: 'Encrypted Language file';
     SizeFrmt: csfUnP; ChildFrmt: coNone; SpecProc: nil;
     Image: ImageText),

    (Name: '????'; Desc: 'Unknown Block Type!';
     SizeFrmt: csfUnk; ChildFrmt: co8; SpecProc: nil;
     Image: ImageUnknown),

    (Name: ' '; Desc: '';
     SizeFrmt: csfUnk; ChildFrmt: coOld; SpecProc: nil;
     Image: ImageNone)

  );

implementation

end.
