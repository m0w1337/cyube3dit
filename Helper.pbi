#BSubstWind = 10
#BlockListIcon = 100
#blockPrevSize = 32

#LineTop = 0
#LineBottom = 1
#LineLeft = 2
#LineRight = 3
#LineFront = 4
#LineBack = 5
#FaceTop = 10
#FaceBottom = 11
#FaceLeft = 12
#FaceRight = 13
#FaceFront = 14
#FaceBack = 15

#FullBlock = 306
#BillBoardMesh = 16
#ToolBlock = 1001
#ToolBlock_act = 1002
#ToolFaceTop = 1003
#ToolFaceBottom = 1004
#ToolFaceLeft = 1005
#ToolFaceRight = 1006
#ToolFaceFront = 1007
#ToolFaceBack = 1008
#Marker_green = 1010
#Marker_red = 1011

Structure pHnd
  wind.i
  progbar.i
  progtxt.i
EndStructure


Global BlockListIconIL = 0

Declare  publishCustomBlock(db, id, mode, name.s, author.s)
Declare  findCustomBlock(db,id, name.s)

Procedure.s GetLApplicationDataDirectory()
 Protected path$
 path$=Space(#MAX_PATH*2)
 If SHGetSpecialFolderPath_(#Null,@path$,#CSIDL_LOCAL_APPDATA,#True)
  Trim(path$)
  If Right(path$,1)<>"\"
   path$+"\"
  EndIf
 Else
  path$=""
 EndIf
 ProcedureReturn path$
EndProcedure

Procedure.l avg64(value.q)
  Static Dim values.q(63)
  Static pos.a=0
  Static full.a = 0
  
  values(pos) = value
  pos = pos + 1
  If(pos = 64)
    pos = 0
    full = 1
  EndIf
  If(full)
    For i=0 To 63
      avg.q = avg + values(i)
    Next
    avg = avg / 64
  Else
;     For i=0 To pos-1
;       avg = avg + values(i)
;     Next
    avg = 0
  EndIf
  ProcedureReturn avg
EndProcedure

Procedure DrawTextEx(X.i, Y.i, Text.s)
   Protected I.i, Max = CountString(Text, #CRLF$)+1
   Protected Line.s
   For I = 1 To Max
     Line = StringField(Text, I, #CRLF$)
     While Len(line) > 0
       DrawText(X, Y, Left(Line,14))
       Line = Right(Line,Len(line)-14)
       Y + TextHeight(" ")
     Wend
   Next
 EndProcedure
 
Procedure  StatusBarProgressUnknown(statusBar,Field)
  Static prog = 0
  StatusBarProgress(statusBar,Field,prog)
  prog = prog+1
  If prog=101
    prog=0
  EndIf
EndProcedure
  


Procedure generateBlockMeshes()
;   CreateMesh(0)
;     ;TOP
;     vert=0
;     uv0.f = 0
;     uv1.f = 1
;     MeshVertex(-0.25, 0.25, -0.25,uv0,uv0,RGBA(255,255,255,255),0,1,0)
;     MeshVertex(0.25, 0.25, -0.25,uv1,uv0,RGBA(255,255,255,255),0,1,0)
;     MeshVertex(0.25, 0.25, 0.25,uv1,uv1,RGBA(255,255,255,255),0,1,0)
;     MeshVertex(-0.25, 0.25, 0.25,uv0,uv1,RGBA(255,255,255,255),0,1,0)
;     MeshFace(vert+2,vert+1,vert+0)
;     MeshFace(vert+0,vert+3,vert+2)
;     ;BOTTOM
;     vert=vert+4
;     MeshVertex(-0.25, -0.25, 0.25,uv0,uv0,RGBA(255,255,255,255),0,-1,0)
;     MeshVertex(0.25, -0.25, 0.25,uv1,uv0,RGBA(255,255,255,255),0,-1,0)
;     MeshVertex(0.25, -0.25, -0.25,uv1,uv1,RGBA(255,255,255,255),0,-1,0)
;     MeshVertex(-0.25, -0.25, -0.25,uv0,uv1,RGBA(255,255,255,255),0,-1,0)
;     MeshFace(vert+2,vert+1,vert+0)
;     MeshFace(vert+0,vert+3,vert+2)
;     ;LEFT
;     vert=vert+4
;     MeshVertex(-0.25, 0.25, 0.25,uv1,uv0,RGBA(255,255,255,255),-1,0,0)
;     MeshVertex(-0.25, -0.25, 0.25,uv1,uv1,RGBA(255,255,255,255),-1,0,0)
;     MeshVertex(-0.25, -0.25, -0.25,uv0,uv1,RGBA(255,255,255,255),-1,0,0)
;     MeshFace(vert+1,vert,0)
;     MeshFace(0,vert+2,vert+1)
;     ;RIGHT
;     vert=vert+3
;     MeshVertex(0.25, 0.25, 0.25,uv0,uv0,RGBA(255,255,255,255),1,0,0)
;     MeshVertex(0.25, -0.25, -0.25,uv1,uv1,RGBA(255,255,255,255),1,0,0)
;     MeshVertex(0.25, -0.25, 0.25,uv0,uv1,RGBA(255,255,255,255),1,0,0)
;     MeshFace(vert+1,1,vert+0)
;     MeshFace(vert+0,vert+2,vert+1)
;     ;FRONT
;     vert=vert+3
;     MeshVertex(-0.25, 0.25, 0.25,uv0,uv0,RGBA(255,255,255,255),0,0,1)
;     MeshVertex(0.25, 0.25, 0.25,uv1,uv0,RGBA(255,255,255,255),0,0,1)
;     MeshVertex(0.25, -0.25, 0.25,uv1,uv1,RGBA(255,255,255,255),0,0,1)
;     MeshVertex(-0.25, -0.25, 0.25,uv0,uv1,RGBA(255,255,255,255),0,0,1)
;     MeshFace(vert+2,vert+1,vert+0)
;     MeshFace(vert+0,vert+3,vert+2)
;     ;BACK
;     vert=vert+4
;     MeshVertex(0.25, 0.25, -0.25,uv0,uv0,RGBA(255,255,255,255),0,0,-1)
;     MeshVertex(-0.25, 0.25, -0.25,uv1,uv0,RGBA(255,255,255,255),0,0,-1)
;     MeshVertex(-0.25, -0.25, -0.25,uv1,uv1,RGBA(255,255,255,255),0,0,-1)
;     MeshVertex(0.25, -0.25, -0.25,uv0,uv1,RGBA(255,255,255,255),0,0,-1)
;     MeshFace(vert+2,vert+1,vert+0)
;     MeshFace(vert+0,vert+3,vert+2)
;     FinishMesh(#True)
  CreateMesh(#BillBoardMesh)
    MeshVertex(0, -0.25, -0.25,1,1,RGBA(255,255,255,255))
    MeshVertex(0, -0.25, 0.25,0,1,RGBA(255,255,255,255))
    MeshVertex(0, 0.25, 0.25,0,0,RGBA(255,255,255,255))
    MeshVertex(0, 0.25, -0.25,1,0,RGBA(255,255,255,255))

    MeshVertex(-0.25, -0.25, 0,1,1,RGBA(255,255,255,255))
    MeshVertex(0.25, -0.25, 0,0,1,RGBA(255,255,255,255))
    MeshVertex(0.25, 0.25, 0,0,0,RGBA(255,255,255,255))
    MeshVertex(-0.25, 0.25, 0,1,0,RGBA(255,255,255,255))
    
    MeshFace(2,1,0)
    MeshFace(2,3,0)
    
    MeshFace(6,5,4)
    MeshFace(6,7,4)
    FinishMesh(#True)
    ;NormalizeMesh(#BillBoardMesh)
    BuildMeshShadowVolume(#BillBoardMesh)
    CreateCube(#FullBlock, 0.5)
    
    CreateMesh(#FaceTop)
    ;TOP
    vert=0
    uv0.f = 0
    uv1.f = 1
    MeshVertex(-0.25, 0.25, -0.25,uv0,uv1,RGBA(255,255,255,255),0,1,0)
    MeshVertex(0.25, 0.25, -0.25,uv0,uv0,RGBA(255,255,255,255),0,1,0)
    MeshVertex(0.25, 0.25, 0.25,uv1,uv0,RGBA(255,255,255,255),0,1,0)
    MeshVertex(-0.25, 0.25, 0.25,uv1,uv1,RGBA(255,255,255,255),0,1,0)
    MeshFace(2,1,0)
    MeshFace(0,3,2)
    FinishMesh(#True)
    BuildMeshShadowVolume(#FaceTop)
        ;BOTTOM
    CreateMesh(#FaceBottom)
    MeshVertex(-0.25, -0.25, 0.25,uv0,uv1,RGBA(255,255,255,255),0,-1,0)
    MeshVertex(0.25, -0.25, 0.25,uv0,uv0,RGBA(255,255,255,255),0,-1,0)
    MeshVertex(0.25, -0.25, -0.25,uv1,uv0,RGBA(255,255,255,255),0,-1,0)
    MeshVertex(-0.25, -0.25, -0.25,uv1,uv1,RGBA(255,255,255,255),0,-1,0)
    MeshFace(2,1,0)
    MeshFace(0,3,2)
    FinishMesh(#True)
    BuildMeshShadowVolume(#FaceBottom)
        ;LEFT
    CreateMesh(#FaceLeft)
    MeshVertex(-0.25, 0.25, -0.25,uv0,uv0,RGBA(255,255,255,255),-1,0,0)
    MeshVertex(-0.25, 0.25, 0.25,uv1,uv0,RGBA(255,255,255,255),-1,0,0)
    MeshVertex(-0.25, -0.25, 0.25,uv1,uv1,RGBA(255,255,255,255),-1,0,0)
    MeshVertex(-0.25, -0.25, -0.25,uv0,uv1,RGBA(255,255,255,255),-1,0,0)
    MeshFace(2,1,0)
    MeshFace(0,3,2)
    FinishMesh(#True)
    BuildMeshShadowVolume(#FaceLeft)
        ;RIGHT
    CreateMesh(#FaceRight)
    MeshVertex(0.25, 0.25, 0.25,uv0,uv0,RGBA(255,255,255,255),1,0,0)
    MeshVertex(0.25, 0.25, -0.25,uv1,uv0,RGBA(255,255,255,255),1,0,0)
    MeshVertex(0.25, -0.25, -0.25,uv1,uv1,RGBA(255,255,255,255),1,0,0)
    MeshVertex(0.25, -0.25, 0.25,uv0,uv1,RGBA(255,255,255,255),1,0,0)
    MeshFace(2,1,0)
    MeshFace(0,3,2)
    FinishMesh(#True)
    BuildMeshShadowVolume(#FaceRight)
        ;FRONT
    CreateMesh(#FaceFront)
    MeshVertex(-0.25, 0.25, 0.25,uv0,uv0,RGBA(255,255,255,255),0,0,1)
    MeshVertex(0.25, 0.25, 0.25,uv1,uv0,RGBA(255,255,255,255),0,0,1)
    MeshVertex(0.25, -0.25, 0.25,uv1,uv1,RGBA(255,255,255,255),0,0,1)
    MeshVertex(-0.25, -0.25, 0.25,uv0,uv1,RGBA(255,255,255,255),0,0,1)
    MeshFace(2,1,0)
    MeshFace(0,3,2)
    FinishMesh(#True)
    BuildMeshShadowVolume(#FaceFront)
        ;BACK
    CreateMesh(#FaceBack)
    MeshVertex(0.25, 0.25, -0.25,uv0,uv0,RGBA(255,255,255,255),0,0,-1)
    MeshVertex(-0.25, 0.25, -0.25,uv1,uv0,RGBA(255,255,255,255),0,0,-1)
    MeshVertex(-0.25, -0.25, -0.25,uv1,uv1,RGBA(255,255,255,255),0,0,-1)
    MeshVertex(0.25, -0.25, -0.25,uv0,uv1,RGBA(255,255,255,255),0,0,-1)
    MeshFace(2,1,0)
    MeshFace(0,3,2)
    FinishMesh(#True)
    BuildMeshShadowVolume(#FaceBack)
    CreateTexture(#MATERIAL_BLACK,1,1)
    CreateMaterial(#MATERIAL_BLACK,TextureID(#MATERIAL_BLACK))
    CreateEntity(#LineTop,MeshID(#FaceTop),MaterialID(#MATERIAL_BLACK))
    HideEntity(#LineTop,#True)
    CreateEntity(#LineBottom,MeshID(#FaceBottom),MaterialID(#MATERIAL_BLACK))
    HideEntity(#LineBottom,#True)
    CreateEntity(#LineLeft,MeshID(#FaceLeft),MaterialID(#MATERIAL_BLACK))
    HideEntity(#LineLeft,#True)
    CreateEntity(#LineRight,MeshID(#FaceRight),MaterialID(#MATERIAL_BLACK))
    HideEntity(#LineRight,#True)
    CreateEntity(#LineFront,MeshID(#FaceFront),MaterialID(#MATERIAL_BLACK))
    HideEntity(#LineFront,#True)
    CreateEntity(#LineBack,MeshID(#FaceBack),MaterialID(#MATERIAL_BLACK))
    HideEntity(#LineBack,#True)
    
    CreateEntity(#BillBoardMesh,MeshID(#BillBoardMesh),MaterialID(#MATERIAL_BLACK))
    HideEntity(#BillBoardMesh,#True)
    CreateEntity(#FaceTop, MeshID(#FaceTop), MaterialID(#MATERIAL_BLACK))
    ;HideEntity(#FaceTop,#True)
    CreateEntity(#FaceBottom, MeshID(#FaceBottom), MaterialID(#MATERIAL_BLACK))
    ;HideEntity(#FaceBottom,#True)
    CreateEntity(#FaceLeft, MeshID(#FaceLeft), MaterialID(#MATERIAL_BLACK))
    ;HideEntity(#FaceLeft,#True)
    CreateEntity(#FaceRight, MeshID(#FaceRight), MaterialID(#MATERIAL_BLACK))
    ;HideEntity(#FaceRight,#True)
    CreateEntity(#FaceFront, MeshID(#FaceFront), MaterialID(#MATERIAL_BLACK))
    ;HideEntity(#FaceFront,#True)
    CreateEntity(#FaceBack, MeshID(#FaceBack), MaterialID(#MATERIAL_BLACK))
    ;HideEntity(#FaceBack,#True)
    CreateEntity(#FullBlock, MeshID(#FullBlock), MaterialID(#MATERIAL_BLACK))
    HideEntity(#FullBlock,#True)
    
  EndProcedure
  
  
  Procedure ScaleToolBlock(x.f,y.f,z.f,mode)
    ScaleEntity(#ToolFaceTop,x,y,z,mode)
    ScaleEntity(#ToolFaceBottom,x,y,z,mode)
    ScaleEntity(#ToolFaceLeft,x,y,z,mode)
    ScaleEntity(#ToolFaceRight,x,y,z,mode)
    ScaleEntity(#ToolFaceFront,x,y,z,mode)
    ScaleEntity(#ToolFaceBack,x,y,z,mode)
;     StartDrawing(TextureOutput(#ToolBlock))
;     DrawingFont(FontID(1))
;     DrawingMode(#PB_2DDrawing_AlphaChannel )
;     Box(0,0,256,256,RGBA(100,255,100,0))
;     DrawingMode(#PB_2DDrawing_Transparent|#PB_2DDrawing_AlphaBlend )
;     DrawText(10,10,Str(x)+"x"+Str(y)+"x"+Str(z),RGBA(0,0,0,255))
;     StopDrawing()
  EndProcedure
  
    Procedure HideToolBlock(mode)
    HideEntity(#ToolFaceTop,mode)
    HideEntity(#ToolFaceBottom,mode)
    HideEntity(#ToolFaceLeft,mode)
    HideEntity(#ToolFaceRight,mode)
    HideEntity(#ToolFaceFront,mode)
    HideEntity(#ToolFaceBack,mode)
  EndProcedure
  
  
  ;need this because examinemouse will not returned presse dbutton is already pressed when it got the focus
  Procedure GetMouseButtonState(button.i)
   ; checks if a mouse button is pressed
   ; ExamineMouse() is not required
   ; works for left or right hand mouse configuration
   ; button parameter should be:
   ;    #PB_MouseButton_Left  or
   ;    #PB_MouseButton_Right or
   ;    #PB_MouseButton_Middle
   ;
   ; procedure returns #True if button is pressed
   
   Protected result = #False
   
   Static firstRun   = #True
   Static _VK_LBUTTON = #VK_LBUTTON
   Static _VK_RBUTTON = #VK_RBUTTON
   
   If firstRun = #True
      firstRun = #False
      If GetSystemMetrics_(#SM_SWAPBUTTON)
         Swap _VK_LBUTTON, _VK_RBUTTON
      EndIf
   EndIf
   
   Select button
      Case #PB_MouseButton_Left   : result = GetAsyncKeyState_(_VK_LBUTTON) >> 15 & 1
      Case #PB_MouseButton_Middle : result = GetAsyncKeyState_(#VK_MBUTTON) >> 15 & 1
      Case #PB_MouseButton_Right  : result = GetAsyncKeyState_(_VK_RBUTTON) >> 15 & 1
   EndSelect
   
   ProcedureReturn result
 EndProcedure
 
 Procedure CamDistance3D(cam,x,y,z)
   ProcedureReturn Sqr(Pow(CameraX(cam)-x,2)+Pow(CameraY(cam)-y,2)+Pow(CameraZ(cam)-z,2))
 EndProcedure
 
 Procedure PopulateWorldList(List Worlds.s(), saveDir.s)
    If ExamineDirectory(0,saveDir,"*.*")
      While NextDirectoryEntry(0)
        If DirectoryEntryType(0) = #PB_DirectoryEntry_Directory And DirectoryEntryName(0) <> "." And DirectoryEntryName(0) <> ".."
          If ExamineDirectory(1,saveDir+DirectoryEntryName(0)+"/","*.important")
            While NextDirectoryEntry(1)
              If DirectoryEntryType(1) = #PB_DirectoryEntry_File
                AddElement(Worlds())
                Worlds() = DirectoryEntryName(0)
                Break
              EndIf
            Wend
            FinishDirectory(1)
          EndIf
        EndIf
      Wend
      FinishDirectory(0)
    EndIf
  EndProcedure
  
  Procedure WritePlayerPos(worldDir.s, x.d,y.d,z.d)
    If(ExamineDirectory(0,WorldDir,"*.important"))
    While NextDirectoryEntry(0)
      If DirectoryEntryType(0) = #PB_DirectoryEntry_File
        name.s = DirectoryEntryName(0)
        filenum = Val(Mid(name,14,Len(name)-23))
        If filenum > lastfilenum
          lastfilenum = filenum
        EndIf
      EndIf
    Wend
  EndIf
  If(OpenFile(0,worldDir+"WorldMetadata"+Str(lastfilenum)+".important"))
    FileSeek(0,8)
    *chunkdata = AllocateMemory(4)
    ReadData(0, *chunkdata, 4)
    numchunks = PeekL(*chunkdata)
    FileSeek(0,numchunks*8,#PB_Relative)
;     For i = 0 To numchunks-1
;       ReadData(0, *chunkdata, 4)
;       xCoord.s = Str(PeekL(*chunkdata)/100)
;       ReadData(0, *chunkdata, 4)
;       yCoord.s  = Str(PeekL(*chunkdata)/100)
;       chunks(xCoord+","+yCoord)\id = i
;     Next
    ReadData(0, *chunkdata, 4)
    trashlen = PeekL(*chunkdata)
    FileSeek(0,trashlen*12+24+28,#PB_Relative)
    *chunkdata = ReAllocateMemory(*chunkdata, 8)
    PokeD(*chunkdata,x*100)
    WriteData(0,*chunkdata,8)
    PokeD(*chunkdata,z*100)
    WriteData(0,*chunkdata,8)
    PokeD(*chunkdata,y*100)
    WriteData(0,*chunkdata,8)
    FreeMemory(*chunkdata)
    CloseFile(0)
  EndIf
EndProcedure

Procedure SavePrefs()
  If (OpenPreferences(GetLApplicationDataDirectory()+"CyubE3dit\prefs.ini"))
    WritePreferenceString("LastWorld",g_LastWorld)
    WritePreferenceString("SaveDir",g_saveDir)
    WritePreferenceString("InstaLoadDir", g_instaLoadDir)
    WritePreferenceString("SteamAppsDir",g_steamAppsDir)
    WritePreferenceInteger("VisibleChunkBorders",g_chunkborders)
    WritePreferenceInteger("NarrowRenderHeight",g_restrictHeight)
    WritePreferenceInteger("ViewDistance",g_viewdistance)
    WritePreferenceInteger("DrawBothNormals",g_DoubleDraw)
    WritePreferenceInteger("Shadows",g_Shadows)
    WritePreferenceInteger("Do not share custom Blocks in mods directory",g_noLocalMods)
  Else
    MessageRequester("FileSystem Error","Could not create or read preferences file, please make sure the current user has write permission to the application directory!")
    End
  EndIf
EndProcedure

Procedure.l GrabSpriteEx(sprite, x, y, width, height, mode=0)
  ; netmaestro 2007
  ; Grab a Sprite from the backbuffer or visible screen
  ; buffer values: 0=backbuffer, 1=visible screen

  srcDC = GetDC_(ScreenID())
  trgDC = CreateCompatibleDC_(srcDC)
  BMPHandle = CreateCompatibleBitmap_(srcDC, Width, Height)
  SelectObject_( trgDC, BMPHandle)
  BitBlt_( trgDC, 0, 0, Width, Height, srcDC, x, y, #SRCCOPY)
  DeleteDC_( trgDC)
  ReleaseDC_(ScreenID(), srcDC)
  result = CreateSprite(sprite, width, height, mode)
  If sprite = #PB_Any
    output = result
  Else
    output = sprite
  EndIf
  StartDrawing(SpriteOutput(output))
  If BMPHandle
    DrawImage(BMPHandle, 0, 0)
  EndIf
  StopDrawing()
  DeleteObject_(BMPHandle)
  ProcedureReturn output
EndProcedure  


Procedure SaveBlockPreview(BlockID, CBlockID, noUpload,CBauthor.s)
  draw = 0
  If(BlockID = 66)
    If FindMapElement(CBlocks(),Str(CBlockID))
      HideEntity(#FaceTop,#False)
      HideEntity(#FaceBottom,#False)
      HideEntity(#FaceLeft,#False)
      HideEntity(#FaceRight,#False)
      HideEntity(#FaceFront,#False)
      HideEntity(#FaceBack,#False)
      HideEntity(#BillBoardMesh,#True)
      Select CBlocks()\mode
        Case 1:
          SetEntityMaterial(#FaceTop,MaterialID(CBlocks()\tex(#texInd_all)))
          SetEntityMaterial(#FaceBottom,MaterialID(CBlocks()\tex(#texInd_all)))
          SetEntityMaterial(#FaceLeft,MaterialID(CBlocks()\tex(#texInd_all)))
          SetEntityMaterial(#FaceRight,MaterialID(CBlocks()\tex(#texInd_all)))
          SetEntityMaterial(#FaceFront,MaterialID(CBlocks()\tex(#texInd_all)))
          SetEntityMaterial(#FaceBack,MaterialID(CBlocks()\tex(#texInd_all)))
          draw = 1
        Case 2:
          SetEntityMaterial(#FaceTop,MaterialID(CBlocks()\tex(#texInd_upDown)))
          SetEntityMaterial(#FaceBottom,MaterialID(CBlocks()\tex(#texInd_upDown)))
          SetEntityMaterial(#FaceLeft,MaterialID(CBlocks()\tex(#texInd_sides)))
          SetEntityMaterial(#FaceRight,MaterialID(CBlocks()\tex(#texInd_sides)))
          SetEntityMaterial(#FaceFront,MaterialID(CBlocks()\tex(#texInd_sides)))
          SetEntityMaterial(#FaceBack,MaterialID(CBlocks()\tex(#texInd_sides)))
          draw = 1
        Case 3:
          SetEntityMaterial(#FaceTop,MaterialID(CBlocks()\tex(#texInd_top)))
          SetEntityMaterial(#FaceBottom,MaterialID(CBlocks()\tex(#texInd_bottom)))
          SetEntityMaterial(#FaceLeft,MaterialID(CBlocks()\tex(#texInd_sides)))
          SetEntityMaterial(#FaceRight,MaterialID(CBlocks()\tex(#texInd_sides)))
          SetEntityMaterial(#FaceFront,MaterialID(CBlocks()\tex(#texInd_sides)))
          SetEntityMaterial(#FaceBack,MaterialID(CBlocks()\tex(#texInd_sides)))
          draw = 1
        Case 4:
          SetEntityMaterial(#FaceTop,MaterialID(CBlocks()\tex(#texInd_top)))
          SetEntityMaterial(#FaceBottom,MaterialID(CBlocks()\tex(#texInd_bottom)))
          SetEntityMaterial(#FaceLeft,MaterialID(CBlocks()\tex(#texInd_left)))
          SetEntityMaterial(#FaceRight,MaterialID(CBlocks()\tex(#texInd_right)))
          SetEntityMaterial(#FaceFront,MaterialID(CBlocks()\tex(#texInd_front)))
          SetEntityMaterial(#FaceBack,MaterialID(CBlocks()\tex(#texInd_back)))
          draw = 1
      EndSelect
    Else
      BlockID = 999
    EndIf
  Else
    If BlockID >= 0 And BlockID < 256
      If(SBlocks(BlockID)\mode) < 5
        HideEntity(#FaceTop,#False)
        HideEntity(#FaceBottom,#False)
        HideEntity(#FaceLeft,#False)
        HideEntity(#FaceRight,#False)
        HideEntity(#FaceFront,#False)
        HideEntity(#FaceBack,#False)
        HideEntity(#BillBoardMesh,#True)
      Else
        HideEntity(#FaceTop,#True)
        HideEntity(#FaceBottom,#True)
        HideEntity(#FaceLeft,#True)
        HideEntity(#FaceRight,#True)
        HideEntity(#FaceFront,#True)
        HideEntity(#FaceBack,#True)
        HideEntity(#BillBoardMesh,#False)
      EndIf
      
      Select SBlocks(BlockID)\mode
        Case 1:
          If IsMaterial(SBlocks(BlockID)\tex(#texInd_all))
            SetEntityMaterial(#FaceTop,MaterialID(SBlocks(BlockID)\tex(#texInd_all)))
            SetEntityMaterial(#FaceBottom,MaterialID(SBlocks(BlockID)\tex(#texInd_all)))
            SetEntityMaterial(#FaceLeft,MaterialID(SBlocks(BlockID)\tex(#texInd_all)))
            SetEntityMaterial(#FaceRight,MaterialID(SBlocks(BlockID)\tex(#texInd_all)))
            SetEntityMaterial(#FaceFront,MaterialID(SBlocks(BlockID)\tex(#texInd_all)))
            SetEntityMaterial(#FaceBack,MaterialID(SBlocks(BlockID)\tex(#texInd_all)))
            draw = 1
          EndIf
        Case 2:
          If IsMaterial(SBlocks(BlockID)\tex(#texInd_upDown))
            SetEntityMaterial(#FaceTop,MaterialID(SBlocks(BlockID)\tex(#texInd_upDown)))
            SetEntityMaterial(#FaceBottom,MaterialID(SBlocks(BlockID)\tex(#texInd_upDown)))
          EndIf
          If IsMaterial(SBlocks(BlockID)\tex(#texInd_sides))
            SetEntityMaterial(#FaceLeft,MaterialID(SBlocks(BlockID)\tex(#texInd_sides)))
            SetEntityMaterial(#FaceRight,MaterialID(SBlocks(BlockID)\tex(#texInd_sides)))
            SetEntityMaterial(#FaceFront,MaterialID(SBlocks(BlockID)\tex(#texInd_sides)))
            SetEntityMaterial(#FaceBack,MaterialID(SBlocks(BlockID)\tex(#texInd_sides)))
            draw = 1
          EndIf
        Case 3:
          If IsMaterial(SBlocks(BlockID)\tex(#texInd_upDown))
            SetEntityMaterial(#FaceTop,MaterialID(SBlocks(BlockID)\tex(#texInd_top)))
          EndIf
          If IsMaterial(SBlocks(BlockID)\tex(#texInd_upDown))
            SetEntityMaterial(#FaceBottom,MaterialID(SBlocks(BlockID)\tex(#texInd_bottom)))
          EndIf
          If IsMaterial(SBlocks(BlockID)\tex(#texInd_sides))
            SetEntityMaterial(#FaceLeft,MaterialID(SBlocks(BlockID)\tex(#texInd_sides)))
            SetEntityMaterial(#FaceRight,MaterialID(SBlocks(BlockID)\tex(#texInd_sides)))
            SetEntityMaterial(#FaceFront,MaterialID(SBlocks(BlockID)\tex(#texInd_sides)))
            SetEntityMaterial(#FaceBack,MaterialID(SBlocks(BlockID)\tex(#texInd_sides)))
            draw = 1
          EndIf
        Case 4:
          If IsMaterial(SBlocks(BlockID)\tex(#texInd_top)) And IsMaterial(SBlocks(BlockID)\tex(#texInd_bottom)) And IsMaterial(SBlocks(BlockID)\tex(#texInd_left)) And IsMaterial(SBlocks(BlockID)\tex(#texInd_right)) And IsMaterial(SBlocks(BlockID)\tex(#texInd_front)) And IsMaterial(SBlocks(BlockID)\tex(#texInd_back))
            SetEntityMaterial(#FaceTop,MaterialID(SBlocks(BlockID)\tex(#texInd_top)))
            SetEntityMaterial(#FaceBottom,MaterialID(SBlocks(BlockID)\tex(#texInd_bottom)))
            SetEntityMaterial(#FaceLeft,MaterialID(SBlocks(BlockID)\tex(#texInd_left)))
            SetEntityMaterial(#FaceRight,MaterialID(SBlocks(BlockID)\tex(#texInd_right)))
            SetEntityMaterial(#FaceFront,MaterialID(SBlocks(BlockID)\tex(#texInd_front)))
            SetEntityMaterial(#FaceBack,MaterialID(SBlocks(BlockID)\tex(#texInd_back)))
            draw = 1
          EndIf
        Case 5:
          If IsMaterial(SBlocks(BlockID)\tex(#texInd_top))
            SetEntityMaterial(#BillBoardMesh,MaterialID(SBlocks(BlockID)\tex(#texInd_all)))
            draw = 1
          EndIf
          
      EndSelect
    EndIf
  EndIf
  
  While(WindowEvent())
  Wend
  If draw
    RenderWorld()
    FlipBuffers()
    save = GrabSpriteEx(#PB_Any,ScreenWidth()/2-256,ScreenHeight()/2-256,512,512,#PB_Sprite_AlphaBlending)
    TransparentSpriteColor(save,RGB(255,255,255))
    If blockID = 66
      SaveSprite(save,GetLApplicationDataDirectory()+"CyubE3dit\cblock_prev\"+Str(CBlocks()\id)+".png",#PB_ImagePlugin_PNG)
      prog = RunProgram(GetPathPart(ProgramFilename())+".\tools\pingo.exe","-pngpalette=40 "+Chr(34)+GetLApplicationDataDirectory()+"CyubE3dit\cblock_prev\"+Str(CBlocks()\id)+".png"+Chr(34),"", #PB_Program_Hide | #PB_Program_Open)
    Else
      SaveSprite(save,GetLApplicationDataDirectory()+"CyubE3dit\block_prev\"+Str(BlockID)+".png",#PB_ImagePlugin_PNG)
      prog = RunProgram(GetPathPart(ProgramFilename())+".\tools\pingo.exe","-pngpalette=40 "+Chr(34)+GetLApplicationDataDirectory()+"CyubE3dit\block_prev\"+Str(BlockID)+".png"+Chr(34),"", #PB_Program_Hide | #PB_Program_Open)
    EndIf
    If IsProgram(prog)
      If Not WaitProgram(prog,3000)
        KillProgram(prog)
      EndIf
    EndIf
    While(WindowEvent())
    Wend
    If g_CBlockDB And noUpload = 0 And BlockID = 66
      tmpblock.CBlocks
      If Not findCustomBlock(g_CBlockDB,CBlocks()\id,CBlocks()\name) Or g_ForceUpdate
        publishCustomBlock(g_CBlockDB,CBlocks()\id,CBlocks()\mode,CBlocks()\name,CBauthor.s)
      EndIf
    EndIf 
  EndIf
  
EndProcedure

;>>>>>>>>>>>>>>>>>>>> BUG GetScriptMaterial <<<<<<<<<<<<<<<<<<<<
Procedure.i GetScriptMaterial_(material.i,name.s)
  Protected m,mtemp=GetScriptMaterial(-1,name)
  m=CopyMaterial(mtemp,material)
  If material=-1:material=m:EndIf
  FreeMaterial(mtemp)
  ProcedureReturn material
EndProcedure
Macro GetScriptMaterial(material,name):GetScriptMaterial_(material,name):EndMacro

Procedure LoadBlocks(Array blockArr.SBlocks(1), Map ABlockMap.SBlocks())
  StatusBarText(0,0,"Loading Blocks, please wait...")
  StatusBarProgress(0,1,0)
  currBlock.CBlocks
  For i=0 To 255
    For ii = 0 To 5
      blockArr(i)\tex(ii) = i
    Next
  Next
  ClearMap(ABlockMap())
  If(LoadXML(0,"blocks.xml"))
    If(XMLStatus(0) = #PB_XML_Success)
      *MainNode = MainXMLNode(0)      
      If *MainNode
        *ChildNode = ChildXMLNode(*MainNode)
        While *ChildNode <> 0
          lastDate = 0
          For i=0 To 5
            currBlock\tex(i) = 0
          Next
          currBlock\name = GetXMLNodeText(*ChildNode)
          ExamineXMLAttributes(*ChildNode)
          mesh.s = ""
          While(NextXMLAttribute(*ChildNode))
            Select XMLAttributeName(*ChildNode)
              Case "id":
                currBlock\id = Val(XMLAttributeValue(*ChildNode))
                StatusBarProgress(0,1,25500/(id+1))
              Case "mesh":
                mesh = XMLAttributeValue(*ChildNode)
              Case "textype":
                currBlock\mode= Val(XMLAttributeValue(*ChildNode))
              Case "texture0":
                date = GetFileDate(".\Textures\"+XMLAttributeValue(*ChildNode), #PB_Date_Modified)
                If date > lastDate
                  lastDate = date
                EndIf
                If GetExtensionPart(XMLAttributeValue(*ChildNode)) = "material"
                   currBlock\tex(0) = GetScriptMaterial(#PB_Any,GetFilePart(XMLAttributeValue(*ChildNode),#PB_FileSystem_NoExtension))
                Else
                  currBlock\tex(0) = LoadTexture(#PB_Any,XMLAttributeValue(*ChildNode))
                  If currBlock\tex(0)
                    currBlock\tex(0) = CreateMaterial(#PB_Any,TextureID(currBlock\tex(0)))
                    MaterialCullingMode(currBlock\tex(0),#PB_Material_NoCulling)
                  EndIf
                EndIf
                
                If currBlock\tex(0) = 0
                  currBlock\tex(0) = CreateTexture(#PB_Any,128,128)
                  StartDrawing(TextureOutput(currBlock\tex(0)))
                  DrawingMode(#PB_2DDrawing_AlphaBlend)
                  DrawTextEx(1,1,"Texture missing:"+#CRLF$+XMLAttributeValue(*ChildNode))
                  StopDrawing()
                  currBlock\tex(0) = CreateMaterial(#PB_Any,TextureID(currBlock\tex(0)))
                  MaterialCullingMode(currBlock\tex(0),#PB_Material_NoCulling)
                EndIf
                
              Case "texture1":
                date = GetFileDate(".\Textures\"+XMLAttributeValue(*ChildNode), #PB_Date_Modified)
                If date > lastDate
                  lastDate = date
                EndIf
                currBlock\tex(1) = LoadTexture(#PB_Any,XMLAttributeValue(*ChildNode))
                If currBlock\tex(1) = 0
                  currBlock\tex(1) = CreateTexture(#PB_Any,128,128)
                  StartDrawing(TextureOutput(currBlock\tex(1)))
                  DrawingMode(#PB_2DDrawing_AlphaBlend)
                  DrawTextEx(1,1,"Texture missing:"+#CRLF$+XMLAttributeValue(*ChildNode))
                  StopDrawing()
                EndIf
                currBlock\tex(1) = CreateMaterial(#PB_Any,TextureID(currBlock\tex(1)))
                MaterialCullingMode(currBlock\tex(1),#PB_Material_NoCulling)
              Case "texture2":
                date = GetFileDate(".\Textures\"+XMLAttributeValue(*ChildNode), #PB_Date_Modified)
                If date > lastDate
                  lastDate = date
                EndIf
                currBlock\tex(2) = LoadTexture(#PB_Any,XMLAttributeValue(*ChildNode))
                If currBlock\tex(2) = 0
                  currBlock\tex(2) = CreateTexture(#PB_Any,128,128)
                  If StartDrawing(TextureOutput(currBlock\tex(2)))
                    DrawingMode(#PB_2DDrawing_AlphaBlend)
                    DrawTextEx(1,1,"Texture missing:"+#CRLF$+XMLAttributeValue(*ChildNode))
                    StopDrawing()
                  Else
                    MessageRequester("","Drawing failed!")
                  EndIf
                EndIf
                currBlock\tex(2) = CreateMaterial(#PB_Any,TextureID(currBlock\tex(2)))
                MaterialCullingMode(currBlock\tex(2),#PB_Material_NoCulling)
              Case "texture3":
                date = GetFileDate(".\Textures\"+XMLAttributeValue(*ChildNode), #PB_Date_Modified)
                If date > lastDate
                  lastDate = date
                EndIf
                currBlock\tex(3) = LoadTexture(#PB_Any,XMLAttributeValue(*ChildNode))
                If currBlock\tex(3) = 0
                  currBlock\tex(3) = CreateTexture(#PB_Any,128,128)
                  StartDrawing(TextureOutput(currBlock\tex(3)))
                  DrawingMode(#PB_2DDrawing_AlphaBlend)
                  DrawTextEx(1,1,"Texture missing:"+#CRLF$+XMLAttributeValue(*ChildNode))
                  StopDrawing()
                EndIf
                currBlock\tex(3) = CreateMaterial(#PB_Any,TextureID(currBlock\tex(3)))
                MaterialCullingMode(currBlock\tex(3),#PB_Material_NoCulling)
              Case "texture4":
                date = GetFileDate(".\Textures\"+XMLAttributeValue(*ChildNode), #PB_Date_Modified)
                If date > lastDate
                  lastDate = date
                EndIf
                currBlock\tex(4) = LoadTexture(#PB_Any,XMLAttributeValue(*ChildNode))
                If currBlock\tex(4) = 0
                  currBlock\tex(4) = CreateTexture(#PB_Any,128,128)
                  StartDrawing(TextureOutput(currBlock\tex(4)))
                  DrawingMode(#PB_2DDrawing_AlphaBlend)
                  DrawTextEx(1,1,"Texture missing:"+#CRLF$+XMLAttributeValue(*ChildNode))
                  StopDrawing()
                EndIf
                currBlock\tex(4) = CreateMaterial(#PB_Any,TextureID(currBlock\tex(4)))
                MaterialCullingMode(currBlock\tex(4),#PB_Material_NoCulling)
              Case "texture5":
                date = GetFileDate(".\Textures\"+XMLAttributeValue(*ChildNode), #PB_Date_Modified)
                If date > lastDate
                  lastDate = date
                EndIf
                currBlock\tex(5) = LoadTexture(#PB_Any,XMLAttributeValue(*ChildNode))
                If currBlock\tex(5) = 0
                  currBlock\tex(5) = CreateTexture(#PB_Any,128,128)
                  StartDrawing(TextureOutput(currBlock\tex(5)))
                  DrawingMode(#PB_2DDrawing_AlphaBlend)
                  DrawTextEx(1,1,"Texture missing:"+#CRLF$+XMLAttributeValue(*ChildNode))
                  StopDrawing()
                EndIf
                currBlock\tex(5) = CreateMaterial(#PB_Any,TextureID(currBlock\tex(5)))
                MaterialCullingMode(currBlock\tex(5),#PB_Material_NoCulling)
            EndSelect
          Wend
          blockArr(currBlock\id)\type = #BLOCKTYPE_NORMAL
          blockArr(currBlock\id)\mode = currBlock\mode
          blockArr(currBlock\id)\name = currBlock\name
          For i=0 To 5
            blockArr(currBlock\id)\tex(i) = currBlock\tex(i)
          Next
          If(GetXMLNodeName(*ChildNode) = "AlphaBlock" And currBlock\mode < 6)  ;add only billboards And blocks, no meshes
            ABlockMap(Str(currBlock\id))\mode = currBlock\mode
            ABlockMap()\name = currBlock\name
            For i=0 To 5
              ABlockMap()\tex(i) = currBlock\tex(i)
              If ABlockMap()\tex(i) 
                MaterialBlendingMode(ABlockMap()\tex(i), #PB_Material_AlphaBlend)
                ;MaterialShadingMode(ABlockMap()\tex(i),#PB_Material_Phong | #PB_Material_Solid)
                ;MaterialShininess(ABlockMap()\tex(i), 999999999999999)
                ;SetMaterialColor(ABlockMap()\tex(i),#PB_Material_SpecularColor,RGBA(255,0,0,255))
                ;DisableMaterialLighting(ABlockMap()\tex(i),#True)
              EndIf
            Next
            If(currBlock\mode = 5)
              blockArr(currBlock\id)\type = #BLOCKTYPE_BILLBOARD
            Else
              If(currBlock\tex(0))
                blockArr(currBlock\id)\type = #BLOCKTYPE_ALPHA
              Else
                blockArr(currBlock\id)\type = #BLOCKTYPE_VOID
              EndIf
            EndIf
            
          Else
            If(mesh)
              blockArr(currBlock\id)\mesh = LoadMesh(#PB_Any,mesh)
              If(blockArr(currBlock\id)\mesh = 0)
                MessageRequester("Error","Mesh not found: "+mesh)
                blockArr(currBlock\id)\type = #BLOCKTYPE_ALPHA
              Else
                TransformMesh(blockArr(currBlock\id)\mesh, 0.03, -0.36, 0, 0.02, 0.02, 0.02, -90, 90, 0)
                blockArr(currBlock\id)\mesh = CreateEntity(#PB_Any,MeshID(blockArr(currBlock\id)\mesh),MaterialID(blockArr(currBlock\id)\tex(0)))
                blockArr(currBlock\id)\type = #BLOCKTYPE_TORCH
              EndIf
              
            EndIf
          EndIf
          SBlockTypes(currBlock\id) = blockArr(currBlock\id)\type
          update = 1
          If FileSize(GetLApplicationDataDirectory()+"CyubE3dit\block_prev\"+Str(currBlock\id)+".png") > 0
            If lastDate <= GetFileDate(GetLApplicationDataDirectory()+"CyubE3dit\block_prev\"+Str(currBlock\id)+".png", #PB_Date_Modified)
              update = 0
            EndIf
          EndIf
          If update
            SaveBlockPreview(currBlock\id, 0, 0,"")
          EndIf
          *ChildNode = NextXMLNode(*ChildNode)
        Wend  
        StatusBarProgress(0,1,100)
        StatusBarText(0,0,"Game blocks loaded")
      Else
        MessageRequester("Error", "No Main XML note present in block definition file.")
      EndIf
      
    Else
      Message$ = "Error in the Block definition XML:" + Chr(13)
      Message$ + "Message: " + XMLError(0) + Chr(13)
      Message$ + "Line: " + Str(XMLErrorLine(0)) + "   Character: " + Str(XMLErrorPosition(0))
      MessageRequester("Error", Message$)
    EndIf
  Else
    MessageRequester("Error","Sorry, the block definition XML could not be loaded.")
  EndIf
  
EndProcedure

Procedure MoveStart(*playerpos.pos)
  If IsLight(0)
    MoveLight(0,*playerpos\x-100, *playerpos\z+300, *playerpos\y-200)
  Else
    CreateLight(0, RGB(255, 255, 255), *playerpos\x-100, *playerpos\z+300, *playerpos\y-200)
  EndIf
  
  If IsLight(1)
    MoveLight(1,*playerpos\x+300, *playerpos\z+400, *playerpos\y+200)
  Else
    CreateLight(1, RGB(205, 200, 155),*playerpos\x+300, *playerpos\z+400, *playerpos\y+200)
  EndIf
  SetLightColor(0,#PB_Light_DiffuseColor,RGB(205, 200, 155))
  SetLightColor(0,#PB_Light_SpecularColor,RGBA(255, 255, 255,255))
  SetLightColor(1,#PB_Light_DiffuseColor,RGB(205, 200, 155))
  SetLightColor(1,#PB_Light_SpecularColor,RGBA(255, 255, 255,255))
  MoveCamera(0, *playerpos\x, *playerpos\z, *playerpos\y, #PB_Absolute)
  CameraLookAt(0, *playerpos\x+10, *playerpos\z, *playerpos\y)
EndProcedure

Procedure SetMaterialCulling()
  WorldShadows(#PB_Shadow_None)
  If Not g_DoubleDraw
    If(IsMaterial(#MATERIAL_BLACK))
      MaterialCullingMode(#MATERIAL_BLACK,#PB_Material_ClockWiseCull)
    EndIf
    For i = 0 To 255
      If IsMaterial(i)
        MaterialCullingMode(i,#PB_Material_ClockWiseCull)
      EndIf
      For ii = 0 To 5
        If IsMaterial(SBlocks(i)\tex(ii))
          If SBlocks(i)\type = #BLOCKTYPE_BILLBOARD
            MaterialCullingMode(SBlocks(i)\tex(ii),#PB_Material_NoCulling)
          Else
            MaterialCullingMode(SBlocks(i)\tex(ii),#PB_Material_ClockWiseCull)
          EndIf
          
        EndIf
      Next
    Next
    While(NextMapElement(CBlocks()))
      For ii = 0 To 5
        If IsMaterial(CBlocks()\tex(ii))
          MaterialCullingMode(CBlocks()\tex(ii),#PB_Material_ClockWiseCull)
        EndIf
      Next
    Wend
  Else
    If(IsMaterial(#MATERIAL_BLACK))
      MaterialCullingMode(#MATERIAL_BLACK,#PB_Material_NoCulling)
    EndIf
    For i = 0 To 255
      If IsMaterial(i)
        MaterialCullingMode(i,#PB_Material_NoCulling)
      EndIf
      For ii = 0 To 5
        If IsMaterial(SBlocks(i)\tex(ii))
          If SBlocks(i)\type = #BLOCKTYPE_ALPHA
            MaterialCullingMode(SBlocks(i)\tex(ii),#PB_Material_ClockWiseCull)
          Else
            MaterialCullingMode(SBlocks(i)\tex(ii),#PB_Material_NoCulling)
          EndIf
        EndIf
      Next
    Next
    ResetMap(CBlocks())
    While(NextMapElement(CBlocks()))
      For ii = 0 To 5
        If IsMaterial(CBlocks()\tex(ii))
          MaterialCullingMode(CBlocks()\tex(ii),#PB_Material_NoCulling)
        EndIf
      Next
    Wend
  EndIf
  WorldShadows(g_Shadows)
EndProcedure

Procedure.s ReadRegKey(OpenKey.l, SubKey.s, ValueName.s)
    hKey.l = 0
    KeyValue.s = Space(255)
    Datasize.l = 255
    If RegOpenKeyEx_(OpenKey, SubKey, 0, #KEY_READ, @hKey)
        KeyValue = "Error Opening Key"
    Else
        If RegQueryValueEx_(hKey, ValueName, 0, 0, @KeyValue, @Datasize)
            KeyValue = "Error Reading Key"
        Else 
            KeyValue = Left(KeyValue, Datasize - 1)
        EndIf
        RegCloseKey_(hKey)
    EndIf
    ProcedureReturn KeyValue
  EndProcedure 
  
  
  Procedure updateMsgBox(mode, currChunk)
    StartDrawing(SpriteOutput(0))  
    DrawingMode(#PB_2DDrawing_AlphaChannel)
    RoundBox(1, 1, 448, 98, 10, 10, RGBA(0,0,0,0))
    DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
    RoundBox(0, 0, 450, 100, 10, 10, RGBA(0,0,0,100))

    If(g_ChunkLoadingPaused)
      DrawText(10,10,"Chunkloading paused",RGBA(255,255,0,255))
    EndIf
    Select mode
      Case #mode_init:
        DrawText(10,10,"Click into world to rotate view.",RGBA(255,255,255,255))
        DrawText(10,30,"WASD To move, hold Shift For fast move.",RGBA(255,255,255,255))
      Case #mode_normal:
        DrawText(10,30,Str(MapSize(meshIDs()))+" Chunks displaying of '"+g_LastWorld+"'",RGBA(200,200,200,255))
        DrawText(10,50,"Position: X="+StrF(CameraX(0),1)+"m Y="+StrF(CameraZ(0),1)+"m z="+StrF(CameraY(0),1)+"m ",RGBA(200,200,200,255))
         DrawText(10,70,"Currently within Chunk ID "+Str(currChunk),RGBA(200,200,200,255))
      Case #mode_insert:
        DrawText(10,30,"Press ESC to stop inserting schematic block",RGBA(255,255,255,255))
        DrawText(10,50,"Press Enter to update position (nothing will be written to your world yet)",RGBA(255,255,255,255))
        DrawText(10,70,"Press ctrl+S to write changes to the world.",RGBA(255,255,255,255))     
      Case #mode_cut:
        DrawText(10,30,"Drag the Block to move, Shift Drag to resize.",RGBA(255,255,255,255))
        DrawText(10,50,"Press Enter to generate schematic file of selected block.",RGBA(50,200,50,255))
        DrawText(10,70,"Press ESC to stop selecting a block to save.",RGBA(255,150,0,255))
      Case #mode_chunksel_nodel:
        DrawText(10,30,"Drag the Block to move, Shift Drag to resize.",RGBA(255,255,255,255))
        DrawText(10,50,"Press ENTER to confirm selection and continue.",RGBA(50,200,50,255))
        DrawText(10,70,"Press ESC to discard this selection.",RGBA(255,150,0,255))
    EndSelect
    StopDrawing()  
  EndProcedure
  

Procedure initBlockSubstWindow()
  OpenWindow(#BSubstWind,0,0,250,750,"Block substitution",#PB_Window_WindowCentered | #PB_Window_Tool | #PB_Window_BorderLess,WindowID(0))
  ResizeWindow(#BSubstWind, WindowX(0,#PB_Window_InnerCoordinate), WindowY(#BSubstWind,#PB_Window_InnerCoordinate)+20, #PB_Ignore, #PB_Ignore)
  ListIconGadget(#BlockListIcon,0,0,250,750,"Original Block",125,#PB_ListIcon_FullRowSelect)
  AddGadgetColumn(#BlockListIcon,1,"Substituted Block",125)
  BlockListIconIL = ImageList_Create_(#blockPrevSize,#blockPrevSize,#ILC_COLOR32| #ILC_MASK, 0, 100)
  SendMessage_(GadgetID(#BlockListIcon), #LVM_SETIMAGELIST, #LVSIL_SMALL, BlockListIconIL)
  StickyWindow(#BSubstWind, #True) 
EndProcedure

Procedure AddBlockToList(text.s,id,cid)
  AddGadgetItem(#BlockListIcon,-1,text)
  items = CountGadgetItems(#BlockListIcon)
  AddElement(BlockListIcon())
  BlockListIcon()\id = id
  BlockListIcon()\cblock = cid
  If id = 66 And FindMapElement(CBlocks(),Str(cid))
    If IsImage(CBlocks()\prev)
      icon = CopyImage_(ImageID(cblocks()\prev),#IMAGE_BITMAP,#blockPrevSize,#blockPrevSize,0)
      ImageList_Add_(BlockListIconIL,icon,0)
    Else
      ImageList_Add_(BlockListIconIL,ImageID(CreateImage(#PB_Any,#blockPrevSize,#blockPrevSize,32,RGB(255,0,255))),0)
    EndIf
  ElseIf id <> 66
    img = LoadImage(#PB_Any,GetLApplicationDataDirectory()+"CyubE3dit\block_prev\"+Str(id)+".png")
    If img
      icon = CopyImage_(ImageID(img),#IMAGE_BITMAP,#blockPrevSize,#blockPrevSize,0)
      ImageList_Add_(BlockListIconIL,icon,0)
      FreeImage(img)
    Else
      ImageList_Add_(BlockListIconIL,ImageID(CreateImage(#PB_Any,#blockPrevSize,#blockPrevSize,32,RGB(0,255,255))),0)
    EndIf
  Else
    ImageList_Add_(BlockListIconIL,ImageID(CreateImage(#PB_Any,#blockPrevSize,#blockPrevSize,32,RGB(255,255,0))),0)
  EndIf
  lvi.LV_ITEM
  lvi\mask = #LVIF_IMAGE
  For i = 0 To items
    lvi\iItem = i : lvi\iImage = i
    SendMessage_(GadgetID(#BlockListIcon),#LVM_SETITEM,0,lvi)
  Next
EndProcedure

Procedure RotateSchematic(Map customBlocks.xy(), Map torches.xy(), *destbuff, rotation)

  Dim dest(schBox\sx*schBox\sz)
  Dim rotRemap(6)
  rotRemap(0) = 3
  rotRemap(1) = 2
  rotRemap(2) = 0
  rotRemap(3) = 1
  rotRemap(4) = 4
  rotRemap(5) = 5
  NewMap customBlocksRot.xy()
  NewMap torchesRot.xy()
  While rotation
    sx = schBox\sx
    sy = schBox\sz
    sz = schBox\sy
    For z = 0 To sz-1
      dest_col = sy - 1 
      For h = 0 To sy - 1
        For w = 0 To sx - 1
          tmp = PeekB(*destbuff+z*sx*sy + h*sx + w)
          dest(w * sy + dest_col) = tmp
          If tmp = 66
            If FindMapElement(customBlocks(),Str(w)+","+Str(h)+","+Str(z))
              customBlocksRot(Str(dest_col)+","+Str(w)+","+Str(z))\vis = customBlocks()\vis
            EndIf
          ElseIf SBlocks(tmp)\type = #BLOCKTYPE_Torch
            If FindMapElement(torches(),Str(w)+","+Str(h)+","+Str(z))
              torchesRot(Str(dest_col)+","+Str(w)+","+Str(z))\vis = rotRemap(torches()\vis) ;Rotate torches
            EndIf
          EndIf
         Next
         dest_col-1
       Next
       For h = 0 To sy - 1
        For w = 0 To sx - 1
            PokeB(*destbuff+z*sx*sy + h*sx + w, dest(h*sx + w))
         Next
       Next
     Next z
     schBox\sx = sy
     schBox\sz = sx
     schBox\sy = sz
     
     ClearMap(customBlocks())
     ClearMap(torches())
     
     ResetMap(customBlocksRot())
     While NextMapElement(customBlocksRot())
       customBlocks(MapKey(customBlocksRot()))\vis = customBlocksRot()\vis
     Wend

     ResetMap(torchesRot())
     While NextMapElement(torchesRot())
       torches(MapKey(torchesRot()))\vis = torchesRot()\vis
     Wend
    rotation-1
  Wend
  FreeMap(customBlocksRot())
  FreeMap(torchesRot())
EndProcedure

Procedure OpenProgress(*ret.pHnd, windowTitle.s, initText.s)
  *ret\wind = OpenWindow(#PB_Any,0,0,400,100,windowTitle,#PB_Window_ScreenCentered|#PB_Window_Tool,WindowID(0))
  StickyWindow(*ret\wind ,#True)
  *ret\progbar = ProgressBarGadget(#PB_Any,10,10,380,15,0,100,#PB_ProgressBar_Smooth)
  *ret\progtxt = TextGadget(#PB_Any,10,30,380,50,initText)
  While WindowEvent()
  Wend
EndProcedure


Procedure closeProgress(*progHnd.pHnd)
  CloseWindow(*progHnd\wind)
EndProcedure

Procedure UpdateProgress(*progH.pHnd, text.s, value)
  SetGadgetText(*progH\progtxt,text)
  SetGadgetState(*progH\progbar, value)
  WindowEvent()
EndProcedure


Procedure StopEditing()
  If g_EditMode <> #mode_normal
    g_EditMode = #mode_normal
    HideToolBlock(#True)
    If(IsStaticGeometry(schGeo\id))
      WorldShadows(g_Shadows)
      FreeStaticGeometry(schGeo\id)
    EndIf
    ClearList(SchBlocks())
  EndIf
EndProcedure






  
; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 649
; FirstLine = 624
; Folding = -----
; EnableXP