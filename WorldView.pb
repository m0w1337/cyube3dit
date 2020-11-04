;
; ------------------------------------------------------------
;
;   PureBasic - Library
;*srcbuff
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#VERSION = "1.1.0."+#PB_Editor_BuildCount

#mode_init = -1
#mode_normal = 0
#mode_cut = 1
#mode_insert = 2
#mode_chunksel_nodel = 3

#maxSchemXZ = 600
#maxSchemY = 300


#BLOCKTYPE_VOID = 100
#BLOCKTYPE_NORMAL = 0
#BLOCKTYPE_ALPHA = 1
#BLOCKTYPE_BILLBOARD = 2
#BLOCKTYPE_Torch = 3
#BLOCKTYPE_MESH = 4
#MATERIAL_BLACK = 999

#texInd_all = 0

#texInd_upDown = 0
#texInd_sides = 2

#texInd_top = 0
#texInd_bottom = 1
#texInd_left = 2
#texInd_right = 3
#texInd_front = 4
#texInd_back = 5


#gdg_fps =  0
#gdg_note = 1
#numthreads = 8
#distance_far = 600
#distance_mid = 300
#distance_short = 150
Global g_viewdistance = #distance_short
Global Mutex = CreateMutex()
Global DelMutex = CreateMutex()
Global DrawMutex = CreateMutex()
Global g_chunkborders = 1
Global g_restrictHeight = 0
Global g_DoubleDraw = 1
Global g_saveDir.s
Global g_instaLoadDir.s
Global g_steamAppsDir.s
Global g_LastWorld.s
Global g_Shadows
Global g_ChunkLoadingPaused = #False
Global Dim g_drawing(#numthreads-1)
Global g_ForceUpdate = 0
Global g_noLocalMods = 1
Global g_EditMode = #mode_normal

Structure chunk
    id.l
  EndStructure
  
  Structure xy
    x.l
    y.l
    vis.l
  EndStructure
  
  Structure marker
    x.f
    y.f
    z.f
    sx.l
    sy.l
    sz.l
    vis.l
    entity.l
  EndStructure
  
  Structure block
    x.l
    y.l
    z.l
    id.a
    bb.a
    cblock.l
  EndStructure
  
  Structure face
    x.l
    y.l
    z.l
    id.a
    entity.a
    cblock.l
  EndStructure
  
  Structure box
    x1.f
    y1.f
    z1.f
    sx.l
    sy.l
    sz.l
  EndStructure
  
  
  Structure chunkmeshes
    done.a
    Array id.l(16)
  EndStructure
  
  Structure CBlocks
    name.s
    Array tex.l(6)
    prev.l
    id.l
    mode.a
  EndStructure
  
  Structure SBlocks
    name.s
    Array tex.l(6)
    mesh.l
    mode.a
    type.a
  EndStructure
  
  Structure singleMesh
    id.q
  EndStructure
  Structure int
    i.i
  EndStructure
  
  Structure pos
    x.f
    y.f
    z.f
  EndStructure
  
Structure chunkmesh
List chunkmesh.block()
EndStructure


Global Dim g_chunkArray.chunkmesh(#numthreads,16)
Global g_exit = 0
Global NewMap meshIDs.chunkmeshes(64)
Global NewMap CBlocks.CBlocks(64)
Global Dim g_prepareX.l(#numthreads-1)
Global Dim g_prepareY.l(#numthreads-1)
Global Dim g_prepareID.l(#numthreads-1)
Global Dim g_prepareNewChunk.i(#numthreads-1)
Global Dim thread(#numthreads)
Global g_deleteChunk.l
Global Dim g_chunk0ToRender.i(#numthreads-1)
Global schBox.box
Global NewList SchBlocks.block()
Global currentchunk.xy  
Global NewList Markers.marker()
Global g_SchematicFile.s
Global g_schRotation
Global g_UpdateSchGeo
Global schGeo.singleMesh
Global g_CBlockDB
Global NewList BlockListIcon.block()
;Global Dim numchunks.l(#numthreads-1)

Global Dim lastpart(#numthreads-1)

Global g_chunk1ToRender.i

Global NewMap chunks.chunk(4096*4)
Global NewMap visibleChunks.xy(4096)

Global chunkx
Global chunky
Global Dim SBlocks.SBlocks(255)
Global Dim SBlockTypes.a(255)
Global NewMap AlphaBlocks.SBlocks()


IncludeFile "Helper.pbi"
IncludeFile "database.pbi"


IncludeFile "chunks.pbi"
IncludeFile "loadSchematic.pbi"
IncludeFile "SaveSchematic.pbi"
IncludeFile "loadCustomBlocks.pbi"
IncludeFile "manipulateChunk.pbi"
IncludeFile "menu.pbi"

UseTARPacker()
UseSQLiteDatabase()
UsePNGImageDecoder()
UsePNGImageEncoder()
InitMouse()
InitKeyboard()
LoadFont(0,"Palatino Linotype",5)
LoadFont(1,"Palatino Linotype",25)
#CameraSpeed  = 1
#CameraSpeedSlow  = 0.15
#Acceleration = 0.05
#AccelerationMax = 4
#MainWindow = 0
#CloseButton = 0




Define.f KeyX, accX, KeyY, accY, KeyZ, accZ, MouseX, MouseY, camRotX, camRotY, camShiftX, camShiftY, camZoom

UsePNGImageDecoder()
If Not InitEngine3D(#PB_Engine3D_DebugOutput) 
  MessageRequester("Error","Could not initialize the 3D Engine. Aborting.")
  End
EndIf

InitSprite() 
If(FileSize(GetLApplicationDataDirectory()+"CyubE3dit") <> -2)
  CreateDirectory(GetLApplicationDataDirectory()+"CyubE3dit")
EndIf
If(FileSize(GetLApplicationDataDirectory()+"CyubE3dit\cblock_prev") <> -2)
  CreateDirectory(GetLApplicationDataDirectory()+"CyubE3dit\cblock_prev")
EndIf
If(FileSize(GetLApplicationDataDirectory()+"CyubE3dit\block_prev") <> -2)
  CreateDirectory(GetLApplicationDataDirectory()+"CyubE3dit\block_prev")
EndIf
If(FileSize(GetLApplicationDataDirectory()+"CyubE3dit\save") <> -2)
  CreateDirectory(GetLApplicationDataDirectory()+"CyubE3dit\save")
EndIf

If FileSize(GetLApplicationDataDirectory()+"CyubE3dit\prefs.ini") = -1
  If CreatePreferences(GetLApplicationDataDirectory()+"CyubE3dit\prefs.ini")
    ClosePreferences()
  EndIf
EndIf

g_steamAppsDir = ReadRegKey(#HKEY_LOCAL_MACHINE,"SOFTWARE\Valve\Steam","InstallPath")
If  g_steamAppsDir = "Error Opening Key"
  g_steamAppsDir = ReadRegKey(#HKEY_LOCAL_MACHINE,"SOFTWARE\Wow6432Node\Valve\Steam","InstallPath")
EndIf
If(g_steamAppsDir = "Error Opening Key")
  g_steamAppsDir = ""
Else
  g_steamAppsDir = g_steamAppsDir + "\steamapps\"
EndIf

If (OpenPreferences(GetLApplicationDataDirectory()+"CyubE3dit\prefs.ini"))
  g_saveDir.s = ReadPreferenceString("SaveDir", GetLApplicationDataDirectory()+"cyubeVR\Saved\WorldData\")
  g_instaLoadDir.s = ReadPreferenceString("InstaLoadDir", GetLApplicationDataDirectory()+"cyubeVR\Saved\WorldData_InstaLoad\")
  If g_steamAppsDir = ""
    g_steamAppsDir.s = ReadPreferenceString("SteamAppsDir","C:\Program Files (x86)\Steam\steamapps\")
  EndIf
  g_LastWorld = ReadPreferenceString("LastWorld","My Great World")
  g_chunkborders = ReadPreferenceInteger("VisibleChunkBorders",0)
  g_restrictHeight = ReadPreferenceInteger("NarrowRenderHeight",0)
  g_viewdistance = ReadPreferenceInteger("ViewDistance",150)
  ; g_DoubleDraw = ReadPreferenceInteger("DrawBothNormals",1)
  g_DoubleDraw = 1
  g_Shadows = ReadPreferenceInteger("Shadows",#PB_Shadow_None)
  g_noLocalMods = ReadPreferenceInteger("Do not share custom Blocks in mods directory",1)
 
  
Else
  MessageRequester("FileSystem Error","Could not create or read preferences file, please make sure the current user has write permission to the application directory!")
  End
EndIf

If Not Add3DArchive("Textures\",#PB_3DArchive_FileSystem)
  MessageRequester("Missing ressources","Meshes and textures could not be located!!")
  End
EndIf

;WorldDir.s = g_saveDir+g_LastWorld+"/"; GetLApplicationDataDirectory()+"cyubeVR\Saved\WorldData\My Great World\"

If(Not GetChunkList(g_saveDir+g_LastWorld+"/", @playerpos.pos))
  MessageRequester("No current World","There is no current world selected. Please select a world from the list.")
  g_ChunkLoadingPaused = #True
EndIf

AntialiasingMode(#PB_AntialiasingMode_None)
MaterialFilteringMode(#PB_Default,#PB_Material_Anisotropic,4)
OpenWindow(0, 0, 0, 1024, 700, "CyubE3dit", #PB_Window_SystemMenu | #PB_Window_ScreenCentered  | #WS_OVERLAPPEDWINDOW)
SetWindowState(0,#PB_Window_Maximize)
CreateStatusBar(0,WindowID(0))
AddStatusBarField(WindowWidth(0)/3)
AddStatusBarField(WindowWidth(0)/3)
AddStatusBarField(WindowWidth(0)/3)
StatusBarText(0,0,"Running...")
StatusBarProgress(0,1,0)

    g_restrictHeight = 0
    CreateMenuEntries()
    
    Result = OpenWindowedScreen(WindowID(0), 0, 0, WindowWidth(0,#PB_Window_InnerCoordinate), WindowHeight(0,#PB_Window_InnerCoordinate)-StatusBarHeight(0)-MenuHeight(), 0, 0, StatusBarHeight(0), #PB_Screen_SmartSynchronization)
    CreateCamera(0, 0, 0, 100, 100)
    CameraFOV(0, 50)
    AmbientColor(RGB(200,200,220))
    Sun(10,800,10,RGB(255,200,150))
    
    If g_shadows = #PB_Shadow_Modulative
      WorldShadows(g_Shadows,30,RGB(210,205,230))
    Else
      WorldShadows(g_Shadows,25,RGB(10,10,30),256)
    EndIf
    
    EnableWorldPhysics(#False)
    EnableWorldCollisions(#False)
    
    camdist.f = 1.1 * (WindowHeight(0)/1000)
    MoveCamera(0,camdist,camdist,camdist,#PB_Absolute)
    CameraLookAt(0,0.06,0,0.06)
    CreateLight(0, RGB(250, 250, 230), -100, 100, -100)
    CreateLight(1, RGB(250, 250, 230), -100, 100, 100)
    CameraBackColor(0,RGB(255,255,255))
    DisableMenuInteraction(#True)
    g_CBlockDB = ConnectBlockDatabase()
    generateBlockMeshes()
    
    LoadBlocks(SBlocks(),AlphaBlocks())
    
    thread(0) = CreateThread(@farchunks(),0)
    For threads = 0 To #numthreads-1
      thread(threads+1) = CreateThread(@DiscriminateChunk(),threads)
    Next
    CreateSprite(0, 450, 100, #PB_Sprite_AlphaBlending)     
    StartDrawing(SpriteOutput(0))  
    DrawingMode(#PB_2DDrawing_AlphaChannel)
    Box(0, 0, 450, 100,RGBA(0,0,0,0))
    DrawingMode(#PB_2DDrawing_AlphaChannel|#PB_2DDrawing_Outlined)
    RoundBox(0, 0, 450, 100, 10, 10, RGBA(0,0,0,255))
    StopDrawing()
    For i=0 To 255
      If i <> 66
        CreateTexture(i,32,32)
        StartDrawing(TextureOutput(i))
        DrawText(1,1,Str(i),RGB(255,0,0))
        StopDrawing()
        CreateMaterial(i,TextureID(i))
      EndIf
    Next
    CreateTexture(#Marker_green,256,256)
    StartDrawing(TextureOutput(#Marker_green))
    DrawingMode(#PB_2DDrawing_AlphaBlend)
    Box(0,0,256,256,RGBA(50,200,50,70))
    DrawingMode(#PB_2DDrawing_Outlined)
    Box(0,0,256,256,RGB(0,200,0))
    StopDrawing()
    CreateMaterial(#Marker_green,TextureID(#Marker_green))
    MaterialBlendingMode(#Marker_green,#PB_Material_AlphaBlend)
    MaterialCullingMode(#Marker_green,#PB_Material_NoCulling)
    
    LoadTexture(#ToolBlock,"Toolblock.png")
    LoadTexture(#ToolBlock_act,"Toolblock_act.png")
    CreateMaterial(#ToolBlock,TextureID(#ToolBlock))
    CreateMaterial(#ToolBlock_act,TextureID(#ToolBlock_act))
    MaterialBlendingMode(#ToolBlock, #PB_Material_AlphaBlend)
    MaterialBlendingMode(#ToolBlock_act, #PB_Material_AlphaBlend)
    MaterialCullingMode(#ToolBlock,#PB_Material_NoCulling)
    MaterialCullingMode(#ToolBlock_act,#PB_Material_NoCulling)
   
    
    CreateEntity(#ToolFaceTop, MeshID(#FaceTop), MaterialID(#ToolBlock))
    CreateEntity(#ToolFaceBottom, MeshID(#FaceBottom), MaterialID(#ToolBlock))
    CreateEntity(#ToolFaceLeft, MeshID(#FaceLeft), MaterialID(#ToolBlock))
    CreateEntity(#ToolFaceRight, MeshID(#FaceRight), MaterialID(#ToolBlock))
    
    CreateEntity(#ToolFaceBack, MeshID(#FaceBack), MaterialID(#ToolBlock))
    CreateEntity(#ToolFaceFront, MeshID(#FaceFront), MaterialID(#ToolBlock))
    CreateNode(#ToolBlock)
    AttachNodeObject(#ToolBlock,EntityID(#ToolFaceTop))
    AttachNodeObject(#ToolBlock,EntityID(#ToolFaceBottom))
    AttachNodeObject(#ToolBlock,EntityID(#ToolFaceLeft))
    AttachNodeObject(#ToolBlock,EntityID(#ToolFaceRight))
    AttachNodeObject(#ToolBlock,EntityID(#ToolFaceFront))
    AttachNodeObject(#ToolBlock,EntityID(#ToolFaceBack))
    
     ScaleToolBlock(1.01,1.01,1.01,#PB_Absolute)
     HideToolBlock(#True)

   
 CompilerIf #PB_Compiler_Debugger = 0
   
   LoadCustomBlocks(g_steamAppsDir+"workshop\content\619500\",0)
   LoadCustomBlocks(g_steamAppsDir+"common\cyubeVR\cyubeVR\Mods\Blocks\",g_noLocalMods)
   StatusBarText(0,0,"Custom Blocks loaded!")
   StatusBarProgress(0,1,0)
   
 CompilerEndIf
DisableMenuInteraction(#False)
CameraBackColor(0,RGB(100,100,255))
MoveStart(@playerpos)

LockMutex(DelMutex)
g_deleteChunk = -1
UnlockMutex(DelMutex)

For thread = 0 To #numthreads-1
  ;numchunks(thread) = thread
  g_prepareNewChunk(thread) = 1
  lastpart(thread) = -1
Next
CameraBackColor(0, RGB(100, 156, 251))
;renderNextChunk(CameraX(0),CameraY(0))
;loadSchematic()
MouseWheel()
SkyDome("clouds.jpg", 10)

Fog(RGB(30,40,40),2, 32, 512)
ReleaseMouse(#True)
chunkdrawTime.l = 0
lastChunkDraw.q = ElapsedMilliseconds()
rstMaterials = 1


lastupdate.q = ElapsedMilliseconds() ;+ 10000
updateMsgBox(#mode_init, 0)
SetMaterialCulling()
MouseCatch = #False
Repeat    
  event = WindowEvent()
  If(g_chunk0ToRender(drawthread) = 1)
      If drawChunk(g_prepareID(drawthread),drawthread,g_prepareX(drawthread),g_prepareY(drawthread),rstMaterials)
        g_chunk0ToRender(drawthread) = 0
        drawthread = drawthread + 1
        If(drawthread >= #numthreads)
          drawthread = 0
        EndIf
      EndIf
      rstMaterials = 1
  Else
    drawthread = drawthread + 1
    If(drawthread >= #numthreads)
      drawthread = 0
    EndIf
  EndIf
  If ElapsedMilliseconds() - lastupdate > 500 
    lastupdate = ElapsedMilliseconds()   
    getChunk(@currentchunk,CameraX(0),CameraZ(0))
    updateMsgBox(g_EditMode, currentchunk\vis)
;     If second = 0
;           SetMaterialColor(SBlocks(0)\tex(0),#PB_Material_AmbientColor,RGB(0,255,0))
;           SetMaterialColor(SBlocks(0)\tex(0),#PB_Material_DiffuseColor,RGB(0,255,0))
;           SetMaterialColor(SBlocks(0)\tex(0),#PB_Material_SelfIlluminationColor,RGB(0,255,0))
;           second = 1
;         ElseIf second = 1
;           SetMaterialColor(SBlocks(0)\tex(0),#PB_Material_AmbientColor,RGB(255,0,0))
;           SetMaterialColor(SBlocks(0)\tex(0),#PB_Material_DiffuseColor,RGB(255,0,0))
;           SetMaterialColor(SBlocks(0)\tex(0),#PB_Material_SelfIlluminationColor,RGB(255,0,0))
;           second = 2
;         Else
;           SetMaterialColor(SBlocks(0)\tex(0),#PB_Material_AmbientColor,RGB(0,0,255))
;           SetMaterialColor(SBlocks(0)\tex(0),#PB_Material_DiffuseColor,RGB(0,0,255))
;           SetMaterialColor(SBlocks(0)\tex(0),#PB_Material_SelfIlluminationColor,RGB(0,0,255))
;           second = 0
;         EndIf
  EndIf
    If(g_UpdateSchGeo)
      lastcID = -1
      lastID = -1
      OpenProgress(progH.pHnd,"Drawing schematic","Building mesh...")
      While WindowEvent()
      Wend
        g_UpdateSchGeo = 0
        If(IsStaticGeometry(schGeo.singleMesh\id))
          FreeStaticGeometry(schGeo\id)
        EndIf
        done = 0
        all = ListSize(SchBlocks())
        ResetList(SchBlocks())
        schGeo\id = CreateStaticGeometry(#PB_Any,10,10,10,#False)
        While(NextElement(SchBlocks()))
          lastdone + 1
          If lastdone = 10000
            prcnt = ((done)*99)/(all)
            UpdateProgress(progH,"Building mesh..."+Str(prcnt)+"%",prcnt)
            lastdone = 0
          EndIf
          AddBlockToGeo(schGeo\id,schGeo\id,SchBlocks(),schBox\x1,schBox\y1,schBox\z1,0)
          done + 1
        Wend
        UpdateProgress(progH,"Building mesh..."+Str(99)+"%",99)
        While WindowEvent()
        Wend
        BuildStaticGeometry(schGeo\id)
        closeProgress(progH)
      EndIf

  If(TryLockMutex(DelMutex))
    If(g_deleteChunk > -1)
      deleteChunk(g_deleteChunk)
      g_deleteChunk = -1
    EndIf
    UnlockMutex(DelMutex)
  EndIf
  
  
  If event = #PB_Event_CloseWindow
    LockMutex(Mutex)
    g_exit = 1
    UnlockMutex(Mutex)
  EndIf

  If event = #PB_Event_Menu
    HandleMenuEvents(EventMenu())
  EndIf
  
  If( GetMouseButtonState(#PB_MouseButton_Left) And MouseCatch = #False And EventWindow() = 0 )
    mposX = DesktopMouseX()
    mposY = DesktopMouseY()
    wmposX = WindowMouseX(0)
    wmposY = WindowMouseY(0)
    CatchAction = #False
    If(wmposX > 0 And wmposY > 0)
      If IsWindow(#BSubstWind)
        If (mposX < WindowX(#BSubstWind) Or mposX > WindowX(#BSubstWind)+WindowWidth(#BSubstWind,#PB_Window_FrameCoordinate) Or mposy < WindowY(#BSubstWind) Or mposy > WindowY(#BSubstWind)+WindowHeight(#BSubstWind,#PB_Window_FrameCoordinate))
          CatchAction = #True
        EndIf
      Else
        CatchAction = #True
      EndIf
    EndIf
    If CatchAction
      ReleaseMouse(#False)
      MouseCatch = #True
      If ExamineMouse()
        MouseDeltaX()
        MouseDeltaY()
        MouseWheel()
        cast = MouseRayCast(0, wmposX, wmposY,2)
        If(cast > 0 And (g_EditMode <> #mode_normal))
          nx = NormalX()
          ny = NormalY()
          nz = NormalZ()
          SnapSize = CamDistance3D(0,NodeX(#ToolBlock),NodeY(#ToolBlock),NodeZ(#ToolBlock))/2
          If SnapSize = 0
            SnapSize = 80
          Else
            SnapSize = 10 *(10/SnapSize)
            If SnapSize < 5
              SnapSize = 5
            EndIf
          EndIf
          MoveToolX = nx
          MoveToolZ = nz
          Select g_EditMode
            Case #mode_cut:
              grid = 1
              gridY = 1
            Case #mode_insert:
              grid = 1
              gridY = 1
            Case #mode_chunksel_nodel
              grid = 32
              gridY = 0
              SnapSize = SnapSize * grid/2
            Default
              grid = 0
          EndSelect
        Else
          MoveToolX = 0
          MoveToolZ = 0
          mDeltaSnapx = 0
          mDeltaSnapY = 0
        EndIf
        
      EndIf
    EndIf
  EndIf
  If ExamineKeyboard()
  If ExamineMouse()
    MouseX = MouseDeltaX()
    MouseY = MouseDeltaY()
    MouseWheel = MouseWheel()
    If(Not GetMouseButtonState(#PB_MouseButton_Left) And MouseCatch)
      While(WindowEvent())
      Wend
      ReleaseMouse(#True)
      MouseCatch = #False
      SetCursorPos_(mposX,mposY)
    Else
      If(MoveToolX Or MoveToolZ)
        mDeltaSnapY = mDeltaSnapY + MouseY
        mDeltaSnapX = mDeltaSnapX + MouseX
        zoom = MouseWheel
        If(mDeltaSnapX > SnapSize Or mDeltaSnapX < -SnapSize Or mDeltaSnapY > SnapSize Or mDeltaSnapY < -SnapSize)
          mDeltaSnapX = mDeltaSnapX / SnapSize
          mDeltaSnapY = mDeltaSnapY / SnapSize
          
          If KeyboardPushed(#PB_Key_LeftShift)
            If g_EditMode = #mode_cut Or g_EditMode = #mode_chunksel_nodel
              If(GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleX)  - Abs(MoveToolZ)*grid*mDeltaSnapX >= grid And GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleX)  - Abs(MoveToolZ) * grid * mDeltaSnapX <= #maxSchemXZ * grid And GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleZ)  - Abs(MoveToolX) * grid * mDeltaSnapX >= grid And GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleZ)  - Abs(MoveToolX) * grid * mDeltaSnapX <= #maxSchemXZ * grid)
                ScaleToolBlock(GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleX) - Abs(MoveToolZ)*grid*mDeltaSnapX,GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleY),GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleZ) - Abs(MoveToolX)*grid*mDeltaSnapX,#PB_Absolute)
                MoveNode(#ToolBlock,0.25 * MovetoolZ*grid*mDeltaSnapX,0,-0.25*MoveToolX*grid*mDeltaSnapX,#PB_Relative)
              EndIf
              If(GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleY) - gridY * mDeltaSnapY >= gridY And GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleY) - gridY * mDeltaSnapY <= gridY * #maxSchemY And (GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleY) - gridY * mDeltaSnapY) / 4 + (NodeY(#ToolBlock) - 0.25*gridY*mDeltaSnapY) <= 800)
                ScaleToolBlock(GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleX),GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleY)-1*gridY*mDeltaSnapY,GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleZ),#PB_Absolute)
                MoveNode(#ToolBlock,0,-0.25*gridY*mDeltaSnapY,0,#PB_Relative)
              EndIf
            EndIf
          Else
            MoveNode(#ToolBlock,0.5 * MoveToolZ * grid * mDeltaSnapX,0,-0.5 * MoveToolX * grid * mDeltaSnapX,#PB_Relative)
            If(NodeY(#ToolBlock) - 0.5 * gridY * mDeltaSnapY - GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleY)/4 >= 0 And NodeY(#ToolBlock) - 0.5 * gridY * mDeltaSnapY + GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleY)/4 <= 800)
              MoveNode(#ToolBlock,0,-0.5 * gridY * mDeltaSnapY,0,#PB_Relative)
            EndIf
          EndIf
          mDeltaSnapX = 0
          mDeltaSnapY = 0
        EndIf
        If(zoom)
          If KeyboardPushed(#PB_Key_LeftShift)
            If g_EditMode = #mode_cut Or g_EditMode = #mode_chunksel_nodel
              If(GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleX) - MoveToolX*grid*zoom >= grid And GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleX) - MoveToolX*grid*zoom <= #maxSchemXZ*grid And GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleZ) + MoveToolZ*grid*zoom >= grid And GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleZ) + MoveToolZ*grid*zoom <= #maxSchemXZ*grid)
                ScaleToolBlock(GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleX) - MoveToolX*grid*zoom,GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleY),GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleZ) + MoveToolZ*grid*zoom,#PB_Absolute)
                MoveNode(#ToolBlock,-0.25 *grid*zoom* MoveToolX,0,-0.25 *grid*zoom* MoveToolZ,#PB_Relative)
              EndIf
            EndIf
          Else
            MoveNode(#ToolBlock,-0.5 *grid*zoom* MoveToolX,0,-0.5 *grid*zoom* MoveToolZ,#PB_Relative)
          EndIf
        EndIf
      ElseIf g_EditMode = #mode_cut
        camZoom =  MouseWheel
        camShiftX = -MouseX * #CameraSpeed * 0.2
        camShiftY = -MouseY * #CameraSpeed * 0.2
      Else
        camZoom =  MouseWheel
        camRotX = -MouseX * #CameraSpeed * 0.2
        camRotY = -MouseY * #CameraSpeed * 0.2
      EndIf
    EndIf
  Else  ;mouseover toolblock
    cast = MouseRayCast(0, WindowMouseX(0), WindowMouseY(0),2)
    If(cast > 0)
      nx = NormalX()
      ny = NormalY()
      nz = NormalZ()
      If nz > 0
        cast = 3
      ElseIf nz < 0
        cast = 4
      ElseIf nx > 0
        cast = 2
      ElseIf nx < 0
        cast = 1
      Else 
        cast = 0
      EndIf
      If(lastcast <> cast)
        SetEntityMaterial(#ToolFaceBottom+lastcast,MaterialID(#ToolBlock))
        lastcast = cast
        SetEntityMaterial(#ToolFaceBottom+cast,MaterialID(#ToolBlock_act))
        
      EndIf
    Else
      If lastcast <> 0
        SetEntityMaterial(#ToolFaceBottom+lastcast,MaterialID(#ToolBlock))
        lastcast = 0
      EndIf
      lastcast = 0
    EndIf
  EndIf
    moveDelta.f = ElapsedMilliseconds() - lastmove.q
    lastmove = ElapsedMilliseconds()
    movedelta = movedelta / 10

    If KeyboardPushed(#PB_Key_A) Or KeyboardPushed(#PB_Key_Left)
      If AccX < #AccelerationMax
        AccX + #Acceleration
      EndIf
      
      If(KeyboardPushed(#PB_Key_LeftShift))
        KeyX = -#CameraSpeed * movedelta * AccX
      Else
        KeyX = -#CameraSpeedSlow * movedelta * AccX
      EndIf
    ElseIf KeyboardPushed(#PB_Key_D) Or KeyboardPushed(#PB_Key_Right)
      If AccX < #AccelerationMax
        AccX + #Acceleration
      EndIf
      If(KeyboardPushed(#PB_Key_LeftShift))
        KeyX = #CameraSpeed * movedelta * AccX
      Else
        KeyX = #CameraSpeedSlow * movedelta * AccX
      EndIf
    Else
      AccX = 0
    EndIf
    
    
    If KeyboardPushed(#PB_Key_W)
      If AccY < #AccelerationMax
        AccY + #Acceleration
      EndIf
      If(KeyboardPushed(#PB_Key_LeftShift))
        KeyY = -#CameraSpeed * movedelta * AccY
      Else
        KeyY = -#CameraSpeedSlow * movedelta * AccY
      EndIf
    ElseIf KeyboardPushed(#PB_Key_S)
      If AccY < #AccelerationMax
        AccY + #Acceleration
      EndIf
      If(KeyboardPushed(#PB_Key_LeftShift))
        KeyY = #CameraSpeed * movedelta * AccY
      ElseIf(g_EditMode = #mode_insert And KeyboardPushed(#PB_Key_LeftControl))
        KeyY = 0
        AccY = 0
        SaveModifiedChunk(schBox\x1 + (schBox\sx-1)/4, schBox\y1 + (schBox\sy-1)/4, schBox\z1 + (schBox\sz-1)/4, g_schRotation)
        g_EditMode = #mode_normal
        HideToolBlock(#True)
        If IsStaticGeometry(schGeo\id)
          WorldShadows(g_Shadows)
          FreeStaticGeometry(schGeo\id)
        EndIf
        ClearList(SchBlocks())
      Else
        KeyY = #CameraSpeedSlow * movedelta  * AccY
      EndIf
    Else
      AccY = 0
    EndIf
    
    If(KeyboardPushed(#PB_Key_Up))  Or KeyboardPushed(#PB_Key_R)  Or KeyboardPushed(#PB_Key_E)
      If AccZ < #AccelerationMax
        AccZ + #Acceleration
      EndIf
       If(KeyboardPushed(#PB_Key_LeftShift))
        CamShiftY = #CameraSpeed * movedelta * AccZ
      Else
        CamShiftY = #CameraSpeedSlow * movedelta * AccZ
      EndIf
    ElseIf(KeyboardPushed(#PB_Key_Down))  Or KeyboardPushed(#PB_Key_F)
      If AccZ < #AccelerationMax
        AccZ + #Acceleration
      EndIf
      If(KeyboardPushed(#PB_Key_LeftShift))
        CamShiftY = -#CameraSpeed * movedelta * AccZ
      Else
        CamShiftY = -#CameraSpeedSlow * movedelta * AccZ
      EndIf
    Else
      AccZ = 0
    EndIf
    RotateCamera(0, camRotY, camRotX, 0, #PB_Relative)
    If g_EditMode = #mode_cut
      If KeyY Or camZoom
        distance = CamDistance3D(0,NodeX(#ToolBlock),NodeY(#ToolBlock),NodeZ(#ToolBlock))
        MoveCamera(0, 0, 0, KeyY+camZoom)
        If distance < 5 
          If(CamDistance3D(0,NodeX(#ToolBlock),NodeY(#ToolBlock),NodeZ(#ToolBlock)) < distance)
            MoveCamera(0, 0, 0, -(KeyY+camZoom))
          EndIf
        EndIf
        KeyY = 0
        camZoom = 0
      EndIf
    EndIf
  
    MoveCamera(0, KeyX+camShiftX, KeyZ+CamShiftY, KeyY+camZoom)
    
  If(CameraY(0) > 450)
    MoveCamera(0, CameraX(0), 450, CameraZ(0),#PB_Absolute)
  ElseIf CameraY(0) < -50
    MoveCamera(0, CameraX(0), -50, CameraZ(0),#PB_Absolute)
  EndIf
  
  If g_EditMode = #mode_cut 
    CameraFollow(0,NodeID(#ToolBlock),0,0,0.01,0.01,0)
    If KeyboardReleased(#PB_Key_Return)
      While(WindowEvent())
      Wend
      If SaveCyubeAreaToFile(NodeX(#ToolBlock), NodeY(#ToolBlock), NodeZ(#ToolBlock),Round(GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleX),#PB_Round_Down),Round(GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleY),#PB_Round_Down),Round(GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleZ),#PB_Round_Down))
        g_EditMode = #mode_normal
        ;ReleaseMouse(#False)
        HideToolBlock(#True)
      EndIf
    EndIf  
   ElseIf g_EditMode = #mode_insert
     If KeyboardReleased(#PB_Key_Return)
       schBox\x1 = NodeX(#ToolBlock) - (schBox\sx-1)/4
       schBox\y1 = NodeY(#ToolBlock) - (schBox\sy-1)/4
       schBox\z1 = NodeZ(#ToolBlock) - (schBox\sz-1)/4
       g_UpdateSchGeo = 1 ;displayCYSchematic(g_SchematicFile, SchBlocks())
     ElseIf KeyboardReleased(#PB_Key_Z)
       RotSchem = 1
     ElseIf KeyboardReleased(#PB_Key_X)
       RotSchem = -1
     EndIf
     If RotSchem
       If RotSchem < 0
         g_schRotation + 1
         rotstep = -4
         i = 0
         While g_schRotation >= 4
           g_schRotation - 4
         Wend
       Else
         rotstep = 4
         i = 0
         g_schRotation - 1
        While g_schRotation < 0
           g_schRotation + 4
         Wend
       EndIf
       RotSchem = 0
        OpenProgress(progH.phnd, "Rotating Cyube Schematic...", "Re-organizing blocks...")
        prog.int
        schThread = CreateThread(@displayCYSchematic(),@prog)
        While i >= -90 And i <= 90
          i+rotstep
          progress = prog\i
          UpdateProgress(progH,"Rotating mesh..."+Str(progress)+"%",progress)
          RotateNode(#ToolBlock,0,90*i/100,0)
          RenderWorld()
          FlipBuffers()
          Delay(20)
        Wend
        While IsThread(schThread)
          progress = prog\i
          UpdateProgress(progH,"Optimizing mesh..."+Str(progress)+"%",progress)
          RenderWorld()
          FlipBuffers()
          Delay(20)
        Wend
        RotateNode(#ToolBlock,0,0,0)
        ScaleToolBlock(schBox\sx+0.03,schBox\sy+0.03,schBox\sz+0.03,#PB_Absolute)
        CloseProgress(progH)
       g_UpdateSchGeo = 1
       ScaleToolBlock(schBox\sx+0.03,schBox\sy+0.03,schBox\sz+0.03,#PB_Absolute)
       schBox\x1 = NodeX(#ToolBlock) - (schBox\sx-1)/4
       schBox\y1 = NodeY(#ToolBlock) - (schBox\sy-1)/4
       schBox\z1 = NodeZ(#ToolBlock) - (schBox\sz-1)/4
     EndIf
     
   ElseIf g_EditMode = #mode_chunksel_nodel
     If KeyboardReleased(#PB_Key_Return)
       AddElement(Markers())
       Markers()\sx = GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleX)
       Markers()\sy = GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleY)
       Markers()\sz = GetEntityAttribute(#ToolFaceTop,#PB_Entity_ScaleZ)
       Markers()\x = NodeX(#ToolBlock)
       Markers()\y = NodeY(#ToolBlock)
       Markers()\z = NodeZ(#ToolBlock)
       
       Markers()\entity = CreateEntity(#PB_Any,MeshID(#FullBlock),MaterialID(#Marker_green),Markers()\x,200,Markers()\z)
       ScaleEntity(Markers()\entity,Markers()\sx,800,Markers()\sz,#PB_Absolute)
       g_EditMode = #mode_normal
        HideToolBlock(#True)
      EndIf  
    EndIf
  
    If KeyboardReleased(#PB_Key_Escape)
      If g_EditMode <> #mode_normal
        g_EditMode = #mode_normal
        HideToolBlock(#True)
        If(IsStaticGeometry(schGeo\id))
          WorldShadows(g_Shadows)
          FreeStaticGeometry(schGeo\id)
        EndIf
        ClearList(SchBlocks())
      EndIf
    ElseIf KeyboardReleased(#PB_Key_P)
      If(g_ChunkLoadingPaused)
        g_ChunkLoadingPaused = #False
      Else
        g_ChunkLoadingPaused = #True
      EndIf
      updateMsgBox(g_EditMode, currentchunk\vis)
    EndIf

  EndIf

;   If(event = #PB_Event_Gadget)
;     If EventGadget() = #BlockListIcon
;       If EventType() = #PB_EventType_LeftDoubleClick
;         
;       ElseIf EventType() = #PB_EventType_LeftClick
;         ResetList(BlockListIcon())
;         While NextElement(BlockListIcon())
;           If ListIndex(BlockListIcon()) = GetGadgetState(#BlockListIcon)
;             If BlockListIcon()\id = 66
;               If Not FindMapElement(CBlocks(),Str(BlockListIcon()\cblock))
;                 addCustomBlock(BlockListIcon()\cblock)
;               EndIf
;                 For i = 0 To 5
;                   If IsMaterial(CBlocks()\tex(i))
;                     SetMaterialColor(CBlocks()\tex(i),#PB_Material_DiffuseColor,RGBA(0,200,0,255))
;                     SetMaterialColor(CBlocks()\tex(i),#PB_Material_AmbientColor,RGBA(0,200,0,255))
;                     SetMaterialColor(CBlocks()\tex(i),#PB_Material_SpecularColor,RGBA(0,50,20,255))
;                   EndIf
;                 Next
;             Else
;               For i = 0 To 5
;                 If IsMaterial(SBlocks(BlockListIcon()\id)\tex(i))
;                   SetMaterialColor(SBlocks(BlockListIcon()\id)\tex(i),#PB_Material_DiffuseColor,RGBA(0,200,0,255))
;                   SetMaterialColor(SBlocks(BlockListIcon()\id)\tex(i),#PB_Material_AmbientColor,RGBA(0,200,0,255))
;                   SetMaterialColor(SBlocks(BlockListIcon()\id)\tex(i),#PB_Material_SpecularColor,RGBA(0,50,20,255))
;                 EndIf
;               Next
;             EndIf
;           Else
;             If BlockListIcon()\id = 66
;               If Not FindMapElement(CBlocks(),Str(BlockListIcon()\cblock))
;                 addCustomBlock(BlockListIcon()\cblock)
;               EndIf
;                 For i = 0 To 5
;                   If IsMaterial(CBlocks()\tex(i))
;                     SetMaterialColor(CBlocks()\tex(i),#PB_Material_DiffuseColor,RGBA(255,255,255,255))
;                     SetMaterialColor(CBlocks()\tex(i),#PB_Material_AmbientColor,RGBA(255,255,255,255))
;                     SetMaterialColor(CBlocks()\tex(i),#PB_Material_SpecularColor,RGBA(0,0,0,255))
;                   EndIf
;                 Next
;             Else
;               For i = 0 To 5
;                 If IsMaterial(SBlocks(BlockListIcon()\id)\tex(i))
;                   SetMaterialColor(SBlocks(BlockListIcon()\id)\tex(i),#PB_Material_DiffuseColor,RGBA(255,255,255,255))
;                   SetMaterialColor(SBlocks(BlockListIcon()\id)\tex(i),#PB_Material_AmbientColor,RGBA(255,255,255,255))
;                   SetMaterialColor(SBlocks(BlockListIcon()\id)\tex(i),#PB_Material_SpecularColor,RGBA(0,0,0,255))
;                 EndIf
;               Next
;             EndIf
;           EndIf
;           
;         Wend
;         
;       EndIf
;     EndIf
;   EndIf
  
      
      
      
  MouseX = 0
  MouseY = 0
  camRotY = 0
  camRotX = 0
  CamShiftX = 0
  CamShiftY = 0
  camZoom = 0
  KeyX = 0
  KeyZ = 0
  KeyY = 0
  RenderWorld()

  StartDrawing(SpriteOutput(0))
  DrawingMode(#PB_2DDrawing_AlphaBlend)
  For i = 0 To #numthreads-1
    If(g_drawing(i) = 1)
      RoundBox(10+i*30,90,24,16,4,4,RGBA(0,200,0,255))
    ElseIf(g_drawing(i) = 2)
      RoundBox(10+i*30,90,24,16,4,4,RGBA(200,150,0,255))
    ElseIf(g_drawing(i) = 3)
      RoundBox(10+i*30,90,24,16,4,4,RGBA(255,255,255,255))  
    Else
      RoundBox(10+i*30,90,24,16,4,4,RGBA(200,0,0,255))
    EndIf
  Next
  StopDrawing()
  DisplayTransparentSprite(0, 10, 10)
  FlipBuffers()
  
  
Until g_exit

SavePrefs()

g_exit = 1
StopChunkloading()
For i= 0 To #numthreads
  If IsThread(thread(i))        
    KillThread(thread(i))
  EndIf
Next

CloseWindow(0)
End


; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 25
; Folding = -
; EnableXP
; Executable = test.exe
; CPU = 1
; DisableDebugger
; Watchlist = chunks(24)\x;chunks(24)\id;chunks(24)\y