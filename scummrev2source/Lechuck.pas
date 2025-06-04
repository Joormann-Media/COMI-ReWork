unit LECHUCK;

interface
  procedure LECHUCKDecomp(DecLoc: cardinal);

implementation
uses
  SysUtils, Main, Analyze, Tables, Classes, SpecForm;

var
  Stack: TStringList;
  IfStack: string;
  Indent: cardinal;

function StringToStr(DecLoc: cardinal): string;
var
  RByte: byte;
  n: byte;
begin
  n:=0;
  result:='"';
  repeat
    RByte:=Analyzer.InputFile.ReadByte(DecLoc+n);
    if RByte<>0 then
      result:=result+Chr(RByte);
    Inc(n);
  until RByte=0;
  result:=result+'"';
end;

function ParamToStr(DecLoc: cardinal): string;
var
  param: cardinal;
begin
  param:=Analyzer.InputFile.ReadInvDWord(DecLoc);
  if (param shr 24) = $40 then
  begin
    result:='var'+inttostr(param-$40000000);
    Exit;
  end;

  if (param shr 24) = $80 then
  begin
    result:='something'+inttostr(param-$80000000);
    Exit;
  end;

  result:=inttostr(param);
end;

function FunctionToStr(Op: TOpcode): string;
var
  n: cardinal;
  Assignment: string;
  LParam: string;
  StartStack: cardinal;
begin
  StartStack:=0;
  Assignment:='';
  LParam:='';
  result:='';
  case Op of
    O_IF                  : begin result:=result+'if '+IfStack; Exit; end;
    O_IF_NOT              : begin result:=result+'if not '+IfStack; Exit; end;
    O_EQ                  : begin Assignment:=' == '; end;
    O_NEQ                 : begin Assignment:=' != '; end;
    O_GT                  : begin Assignment:=' > '; end;
    O_LT                  : begin Assignment:=' < '; end;
    O_LEQ                 : begin Assignment:=' <= '; StartStack:=1; end;
    O_GEQ                 : begin Assignment:=' >= '; StartStack:=1; end;
    O_ADD                 : begin Assignment:=' += '; end;
    O_SUB                 : begin Assignment:=' -= '; end;
    O_MUL                 : begin Assignment:=' *= '; end;
    O_DIV                 : begin Assignment:=' /= '; end;
    O_LAND                : begin Assignment:=' AND '; end;
    O_LOR                 : begin Assignment:=' OR '; end;
    O_BAND                : begin Assignment:=' AND '; end;
    O_BOR                 : begin Assignment:=' OR '; end;
    O_MOD                 : begin Assignment:=' % '; end;
    O_CURRENT_ROOM        : begin Assignment:=' = '; LParam:='CurrentRoom'; end;
    SO_PRINT_CHARSET      : begin Assignment:=' = '; LParam:='PrintCharSet'; end;
    SO_PRINT_COLOR        : begin Assignment:=' = '; LParam:='PrintColor'; end;
    SO_ACTOR_COSTUME      : begin Assignment:=' = '; LParam:='Costume'; end;
    SO_ACTOR_FREQUENCY    : begin Assignment:=' = '; LParam:='Frequency'; end;
    SO_ACTOR_FACE         : begin Assignment:=' = '; LParam:='Face'; end;
    SO_ACTOR_TALK_COLOR   : begin Assignment:=' = '; LParam:='TalkColor'; end;
    SO_ACTOR_SPECIAL_DRAW : begin Assignment:=' = '; LParam:='SpecialDraw'; end;
    SO_ACTOR_SCALE        : begin Assignment:=' = '; LParam:='Scale'; end;
    SO_ACTOR_STEP_DIST    : begin Assignment:=' = '; LParam:='StepDist'; end;

    F_RANDOM              : begin result:='Random'; end;
    F_RANDOM_BETWEEN      : begin result:='Random'; end;
    F_OWNER_OF            : begin result:='OwnerOf'; end;

    O_CUT_SCENE             : begin result:='Cutscene'; Inc(Indent); end;
    O_END_CUT_SCENE         : begin result:='EndCutscene'; if Indent>0 then Dec(Indent); end;

    SO_CAMERA_RESUME        : result:='Resume';
    SO_ROOM_FADE            : result:='Fade';
    SO_ROOM_RGB_INTENSITY   : result:='RGBIntensity';
    SO_ROOM_TRANSFORM       : result:='Transform';
    SO_ROOM_NEW_PALETTE     : result:='NewPalette';
    SO_ROOM_SAVE_GAME       : result:='SaveGame';
    SO_HEAP_LOAD_SCRIPT     : result:='LoadScript';
    SO_HEAP_LOCK_SCRIPT     : result:='LockScript';
    SO_HEAP_LOAD_SOUND      : result:='LoadSound';
    SO_HEAP_LOCK_SOUND      : result:='LockSound';
    SO_HEAP_UNLOCK_SOUND    : result:='UnlockSound';
    SO_HEAP_LOAD_COSTUME    : result:='LoadCostume';
    SO_HEAP_LOCK_COSTUME    : result:='LockCostume';
    SO_HEAP_UNLOCK_COSTUME  : result:='UnlockCostume';
    SO_HEAP_LOAD_OBJECT     : result:='LoadObject';
    SO_PRINT_BASEOP         : result:='PrintBaseOp';
    SO_PRINT_AT             : result:='PrintAt';
    SO_ACTOR_INIT           : result:='Init';
    SO_ACTOR_TURN           : result:='Turn';
    SO_ACTOR_ANIMATION_TALK : result:='AnimationTalk';
    SO_ACTOR_ANIMATION_STAND: result:='AnimationStand';
    SO_ACTOR_TEXT_OFFSET    : result:='TextOffset';
    SO_ACTOR_IGNORE_BOXES   : result:='IgnoreBoxes';
    SO_ACTOR_FOLLOW_BOXES   : result:='FollowBoxes';
    SO_ACTOR_DEFAULT        : result:='Default';
    SO_ACTOR_ALWAYS_ZCLIP   : result:='AlwaysZClip';
    SO_ACTOR_NEVER_ZCLIP    : result:='NeverZClip';
    SO_ACTOR_STOP           : result:='Stop';
    SO_WAIT_FOR_ACTOR       : result:='ForActor';
    SO_WAIT_FOR_CAMERA      : result:='ForCamera';
    SO_WAIT_FOR_MESSAGE     : result:='ForMessage';

    O_FREEZE_SCRIPTS      : result:='FreezeScripts';
    O_DO_ANIMATION        : result:='DoAnimation';
    O_SLEEP_JIFFIES       : result:='SleepJiffies';
    O_SLEEP_SECONDS       : result:='SleepSeconds';
    O_SLEEP_MINUTES       : result:='SleepMinutes';
    O_START_SFX           : result:='StartSFX';
    O_START_MUSIC         : result:='StartMusic';
    O_STOP_SOUND          : result:='StopSound';
    O_START_SCRIPT        : result:='StartScript';
    O_START_SCRIPT_QUICK  : result:='StartScriptQuick';
    O_STOP_SCRIPT         : result:='StopScript';
    O_STOP_SENTENCE       : result:='StopSentence';
    O_CAMERA_FOLLOW       : result:='CameraFollow';
    O_CAMERA_PAN_TO       : result:='CameraPanTo';
    O_SET_BOX             : result:='SetBox';
    O_SET_BOX_PATH        : result:='SetBoxPath';
    O_BREAK_HERE          : result:='BreakHere';
    O_BREAK_HERE_VAR      : result:='BreakHereVar';

    O_PUT_ACTOR_AT_XY     : result:='PutActorAtXY';
    O_PUT_ACTOR_AT_OBJECT : result:='PutActorAtObject';
    O_WALK_ACTOR_TO_XY    : result:='WalkActorToXY';
    O_WALK_ACTOR_TO_OBJECT: result:='WalkActorToObject';
    O_PICK_UP_OBJECT      : result:='PickUpObject';
    O_CLASS_OF            : result:='ClassOf';
    O_START_OBJECT        : result:='StartObject';

    O_SOUND_KLUDGE        : result:='SoundKludge';
    O_KLUDGE              : result:='Kludge';


  else
    result:=OpcodeName[Op];
  end;

  if Assignment='' then
    result:=result+'(';

  if Stack.Count>StartStack then
  begin
    if Assignment<>'' then
    begin
      if LParam<>'' then
      begin
        result:=result+LParam+Assignment;
      end
      else
      begin
        result:=result+Stack.Strings[StartStack]+Assignment;
        Stack.Delete(StartStack);
      end;
      for n:=StartStack to Stack.Count-1 do
      begin
        result:=result+Stack.Strings[n];
        if n<Stack.Count-1 then result:=result+',';
      end;
    end
    else
    begin
      for n:=StartStack to Stack.Count-1 do
      begin
        result:=result+Stack.Strings[n];
        if n<Stack.Count-1 then result:=result+',';
      end;
    end;
    Stack.Clear;
  end;
  if Assignment='' then
    result:=result+');'
  else
    result:=result+';';
end;

procedure LECHUCKDecomp(DecLoc: cardinal);
var
  Chunk: TChunk;
  Stuff: boolean;
  Line:  string;
  LineDone: boolean;
  Op: TOpCode;
  Strng: string;
  IndentString: string;
  n: cardinal;
begin
  Chunk:=MainForm.ExplorerTreeView.Selected.Data;
  Stack:=TStringList.Create;
  Stuff:=false;
  LineDone:=false;
  Indent:=0;

  repeat
    if Stuff then
    begin
      Op:=TOpCode(Analyzer.InputFile.ReadByte(DecLoc)+256);
      Stuff:=false;
    end
    else
      Op:=TOpCode(Analyzer.InputFile.ReadByte(DecLoc));

    case Op of
      O_PUSH_NUMBER     : begin Stack.Add(ParamToStr(DecLoc+1)); Inc(DecLoc,4); end;
      O_PUSH_VARIABLE   : begin Stack.Add(ParamToStr(DecLoc+1)); Inc(DecLoc,4); end;
      O_EQ              : begin IfStack:=FunctionToStr(Op); end;
      O_NEQ             : begin IfStack:=FunctionToStr(Op); end;
      O_GT              : begin IfStack:=FunctionToStr(Op); end;
      O_LT              : begin IfStack:=FunctionToStr(Op); end;
      O_LEQ             : begin IfStack:=FunctionToStr(Op); end;
      O_GEQ             : begin IfStack:=FunctionToStr(Op); end;
      O_STORE_VARIABLE  : begin Line:='Store '+ParamToStr(DecLoc+1)+';'; Inc(DecLoc,4); LineDone:=true; end;
      O_DEC_VARIABLE    : begin Line:=ParamToStr(DecLoc+1)+'--;'; Inc(DecLoc,4); LineDone:=true; end;
      O_INC_VARIABLE    : begin Line:=ParamToStr(DecLoc+1)+'++;'; Inc(DecLoc,4); LineDone:=true; end;

      O_IF              : begin Line:=FunctionToStr(Op)+ParamToStr(DecLoc+1); Inc(DecLoc,4); LineDone:=true; end;
      O_IF_NOT          : begin Line:=FunctionToStr(Op)+ParamToStr(DecLoc+1); Inc(DecLoc,4); LineDone:=true; end;
      O_JUMP            : begin Line:='Jump '+ParamToStr(DecLoc+1)+';'; Inc(DecLoc,4); LineDone:=true; end;
      O_HEAP_STUFF      : begin Line:='Heap.'; Stuff:=true; end;
      O_ROOM_STUFF      : begin Line:='Room.'; Stuff:=true; end;
      O_ACTOR_STUFF     : begin Line:='Actor.'; Stuff:=true; end;
      O_CAMERA_STUFF    : begin Line:='Camera.'; Stuff:=true; end;
      O_VERB_STUFF      : begin Line:='Verb.'; Stuff:=true; end;
      O_WAIT_FOR_STUFF  : begin Line:='Wait.'; Stuff:=true; end;
      O_BLAST_TEXT      : begin Line:='BlastText.'; Stuff:=true; end;
      SO_PRINT_STRING   : begin Strng:=StringToStr(DecLoc+1); DecLoc:=DecLoc+length(Strng)+1; Line:=Line+'PrintString('+Strng+');'; LineDone:=true; end;
      O_SAY_LINE        : begin Strng:=StringToStr(DecLoc+1); DecLoc:=DecLoc+length(Strng)+1; Line:=Line+'PrintString('+Strng+');'; LineDone:=true; end;
      O_SAY_LINE_SIMPLE : begin Strng:=StringToStr(DecLoc+1); DecLoc:=DecLoc+length(Strng)+1; Line:=Line+'PrintString('+Strng+');'; LineDone:=true; end;
      O_PRINT_DEBUG     : begin Strng:=StringToStr(DecLoc+1); DecLoc:=DecLoc+length(Strng)+1; Line:=Line+'PrintString('+Strng+');'; LineDone:=true; end;
      O_PRINT_LINE      : begin Strng:=StringToStr(DecLoc+1); DecLoc:=DecLoc+length(Strng)+1; Line:=Line+'PrintString('+Strng+');'; LineDone:=true; end;
    else
      Line:=Line+FunctionToStr(Op);
      LineDone:=true;
    end;
    Inc(DecLoc);
    if LineDone then
    begin
      SpecInfoForm.SpecInfoRichEdit.Lines.Add(IndentString+Line);
      IndentString:='';
      if Indent>0 then
      begin
        for n:=1 to Indent do
        begin
          IndentString:=IndentString+' ';
        end;
      end;

      Line:='';
      LineDone:=false;
    end;
  until (DecLoc>=Chunk.Size+Chunk.Offset) or (Op=O_END_SCRIPT);
  Stack.Free;
end;

end.
