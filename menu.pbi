#menu_load = 0
#menu_save = 1
#menu_quit = 2
#menu_loadAgain = 3

#menu_chunkBorders = 10
#menu_setPPos = 11
#menu_narrowHeight = 12
#menu_viewFar = 13
#menu_viewMed = 14
#menu_viewShort = 15
#menu_noCulling = 16
#menu_shadows_none = 17
#menu_shadows_simple = 18
#menu_shadows_adv = 19
#menu_define_marker = 20
#menu_remove_marker = 21
#menu_del_except = 22
#menu_del_only = 23
#menu_nolocalmods = 24
#menu_fillWithBlocks = 25
#menu_copyFilesToDB = 26
#menu_lastEntry = 26


#Font_about_title = 10
#Font_about_version = 11
#Font_about_text = 12


LoadFont(#Font_about_title,"Palatino Linotype",16)
LoadFont(#Font_about_version,"Palatino Linotype",10)
LoadFont(#Font_about_text,"Palatino Linotype",12)

NewList Worlds.s()

Procedure CreateMenuEntries()
  Shared Worlds()
  PopulateWorldList(Worlds(), g_saveDir)
  If ListSize(worlds()) = 0
    g_saveDir =  GetLApplicationDataDirectory()+"cyubeVR/Saved/WorldData/"
    g_instaLoadDir = GetLApplicationDataDirectory()+"cyubeVR/Saved/WorldData_InstaLoad/"
    PopulateWorldList(Worlds(), g_saveDir)
  EndIf
  
  CreateMenu(0, WindowID(0))
  MenuTitle("File")
  MenuItem(#menu_save, "Save Schematic Cube (COPY)")
  MenuItem(#menu_load, "Load Schematic (PASTE)")
  MenuItem(#menu_fillWithBlocks,"Fill Area with Blocks (FILL)")
  MenuBar() 
  MenuItem(#menu_copyFilesToDB,"Copy chunkfiles to Database and delete them.")
  OpenSubMenu("Chunk deletion")
  MenuItem(#menu_define_marker,"Add a marker area")
  MenuItem(#menu_remove_marker,"Remove all markers")
  MenuItem(#menu_del_except,"Delete ALL UNmarked chunks")
  MenuItem(#menu_del_only,"Delete ALL marked chunks")
  CloseSubMenu()
  MenuItem(#menu_nolocalmods, "Do not share information about my mods directoy (Only sync workshop blocks).")
  SetMenuItemState(0,#menu_nolocalmods,g_noLocalMods)
  MenuBar() 
  MenuItem(#menu_quit, "Quit")
  MenuTitle("World")
  OpenSubMenu("Active World")
  ResetList(worlds())
  While(NextElement(Worlds()))
    MenuItem(100+ListIndex(Worlds()),Worlds())
    If GetMenuItemText(0,100+ListIndex(Worlds())) = g_LastWorld
      SetMenuItemState(0,100+ListIndex(Worlds()),#True)
    EndIf
    
  Wend
  CloseSubMenu()
 
  MenuItem(#menu_setPPos,"Set Playerposition")
  
  
  MenuTitle("Visuals")
  MenuItem(#menu_chunkBorders,"Visible Chunkborders")
  SetMenuItemState(0,#menu_chunkBorders,g_chunkborders)
  MenuItem(#menu_narrowHeight, "Narrow Render Height")
  SetMenuItemState(0,#menu_narrowHeight,g_restrictHeight)
  MenuBar() 
  OpenSubMenu("Shadows")
  MenuItem(#menu_shadows_none, "None")
  MenuItem(#menu_shadows_simple, "Simple")
  MenuItem(#menu_shadows_adv, "Advanced")
  Select g_Shadows
    Case #PB_Shadow_Modulative
      SetMenuItemState(0,#menu_shadows_none,0)
      SetMenuItemState(0,#menu_shadows_simple,1)
      SetMenuItemState(0,#menu_shadows_adv,0)
    Case #PB_Shadow_Additive
      SetMenuItemState(0,#menu_shadows_none,0)
      SetMenuItemState(0,#menu_shadows_simple,0)
      SetMenuItemState(0,#menu_shadows_adv,1)
    Default
      SetMenuItemState(0,#menu_shadows_none,1)
      SetMenuItemState(0,#menu_shadows_simple,0)
      SetMenuItemState(0,#menu_shadows_adv,0)
  EndSelect
  CloseSubMenu()
  SetMenuItemState(0,#menu_narrowHeight,g_restrictHeight)
  MenuItem(#menu_noCulling, "Make world Surface visible from inside blocks")
  SetMenuItemState(0,#menu_noCulling,g_DoubleDraw)
  OpenSubMenu("Draw distance")
  MenuItem(#menu_ViewFar, "Far")
  MenuItem(#menu_viewMed, "Medium")
  MenuItem(#menu_viewShort, "Short")
  Select g_viewdistance
    Case #distance_far:
      SetMenuItemState(0,#menu_ViewFar,1)
      SetMenuItemState(0,#menu_viewMed,0)
      SetMenuItemState(0,#menu_viewShort,0)
    Case #distance_short
      SetMenuItemState(0,#menu_ViewFar,0)
      SetMenuItemState(0,#menu_viewMed,0)
      SetMenuItemState(0,#menu_viewShort,1)
    Default:
      SetMenuItemState(0,#menu_ViewFar,0)
      SetMenuItemState(0,#menu_viewMed,1)
      SetMenuItemState(0,#menu_viewShort,0)
   EndSelect
   CloseSubMenu()
   MenuTitle("Help")
   MenuItem(90,"Open Quickstart (website)")
   MenuItem(91,"Download most recent Version")
   MenuItem(92,"View all currently known custom blocks")
   MenuItem(93,"About")
 EndProcedure
 
 Procedure DisableMenuInteraction(state)
   Shared Worlds()
   For i=0 To #menu_lastEntry
     DisableMenuItem(0,i,state)
   Next
   PushListPosition(worlds())
   ResetList(Worlds())
   While(NextElement(worlds()))
     DisableMenuItem(0,100+ListIndex(worlds()),state)
   Wend
   PopListPosition(worlds())
 EndProcedure
 


Procedure HandleMenuEvents(evMenu)
  Shared Worlds()
  Shared Mutex
  If evMenu > 99
      ResetList(Worlds())
      While(NextElement(worlds()))
        If(evMenu = 100+ListIndex(worlds()))
          If(g_saveDir+g_LastWorld <> g_saveDir+worlds()) ; is it really worth the effort??
            StopEditing()
            SetMenuItemState(0,100+ListIndex(worlds()),#True)
            StopChunkloading()
            g_LastWorld = worlds()
            ClearMap(chunks())
            If(Not GetChunkList(g_saveDir+g_LastWorld+"/", @playerpos.pos))
              MessageRequester("Something is wrong","This world doesn't seem to have enough chunks to be worth loading... (<10)")
            EndIf
            RebuildWorld()
            MoveStart(@playerpos)
          EndIf
        Else
          SetMenuItemState(0,100+ListIndex(worlds()),#False)
        EndIf
      Wend
    Else
      Select evMenu
        Case #menu_load:
          g_SchematicFile = OpenFileRequester("Choose a schematic file","","Schematic Files (*.CySch, *.gz)|*.CySch;*.gz|All files (*.*)|*.*",0)
          If g_SchematicFile
            g_EditMode = #mode_insert
            CYSchematicGetSize(@toolBox,g_SchematicFile)
            setToolBlocktype(-1)
            ScaleToolBlock(toolBox\sx,toolBox\sy,toolBox\sz)
            MoveNode(#ToolBlock,Round(CameraX(0),#PB_Round_Up),Round(CameraY(0),#PB_Round_Up),Round(CameraZ(0),#PB_Round_Up),#PB_Absolute)
            MoveNode(#ToolBlock,CameraDirectionX(0)*(toolBox\sx),CameraDirectionY(0) * toolBox\sy/3,CameraDirectionZ(0)*(toolBox\sz),#PB_Relative)
            MoveNode(#ToolBlock,Round(NodeX(#ToolBlock),#PB_Round_Up)-(toolBox\sx-1)*0.25,Round(NodeY(#ToolBlock),#PB_Round_Up)-(toolBox\sy-1)*0.25,Round(NodeZ(#ToolBlock),#PB_Round_Up)-(toolBox\sz-1)*0.25,#PB_Absolute)
            toolBox\x1 = NodeX(#ToolBlock) - (toolBox\sx-1)/4
            toolBox\y1 = NodeY(#ToolBlock) - (toolBox\sy-1)/4
            toolBox\z1 = NodeZ(#ToolBlock) - (toolBox\sz-1)/4
            If toolBox\y1 < 0  ;Make sure the inserted schematic is spawned within Y boundaries!!!
              MoveNode(#ToolBlock,0,-toolBox\y1+4,0,#PB_Relative)
            ElseIf toolBox\y1 + toolBox\sy / 2 > 800
              MoveNode(#ToolBlock,0,796 - (toolBox\y1 + toolBox\sy / 2),0,#PB_Relative)
            EndIf
            toolBox\x1 = NodeX(#ToolBlock) - (toolBox\sx-1)/4
            toolBox\y1 = NodeY(#ToolBlock) - (toolBox\sy-1)/4
            toolBox\z1 = NodeZ(#ToolBlock) - (toolBox\sz-1)/4
            g_schRotation = 0
            OpenProgress(progH.phnd, "Loading Cyube Schematic...", "Optimizing blocks...")
            prog.int
            schThread = CreateThread(@displayCYSchematic(),@prog)
            While IsThread(schThread)
              LockMutex(ProgMutex)
              progress = prog\i
              UnlockMutex(ProgMutex)
              UpdateProgress(progH,"Optimizing mesh..."+Str(progress)+"%",progress)
              ZoomToolBlock(progress / 100,progress / 100,progress / 100)
              RenderWorld()
              FlipBuffers()
            Wend
            ZoomToolBlock(1,1,1)
            CloseProgress(progH)
            If ListSize(SchBlocks())
              g_UpdateSchGeo = 1
            EndIf
            
            If(g_UpdateSchGeo)
              WorldShadows(#PB_Shadow_None)
            Else
              g_EditMode = #mode_normal
              HideToolBlock()
            EndIf
            updateMsgBox(g_EditMode, currentchunk\vis)
          EndIf
        Case #menu_loadAgain:
           If g_SchematicFile And g_EditMode = #mode_normal
            setToolBlocktype(-1)
            g_EditMode = #mode_insert
            If toolBox\y1 < 0  ;Make sure the inserted schematic is spawned within Y boundaries!!!
              MoveNode(#ToolBlock,0,-toolBox\y1+4,0,#PB_Relative)
            ElseIf toolBox\y1 + toolBox\sy / 2 > 800
              MoveNode(#ToolBlock,0,796 - (toolBox\y1 + toolBox\sy / 2),0,#PB_Relative)
            EndIf
            toolBox\x1 = NodeX(#ToolBlock) - (toolBox\sx-1)/4
            toolBox\y1 = NodeY(#ToolBlock) - (toolBox\sy-1)/4
            toolBox\z1 = NodeZ(#ToolBlock) - (toolBox\sz-1)/4
            OpenProgress(progH.phnd, "Loading Cyube Schematic...", "Optimizing blocks...")
            prog.int
            schThread = CreateThread(@displayCYSchematic(),@prog)
            While IsThread(schThread)
              LockMutex(ProgMutex)
              progress = prog\i
              UnlockMutex(ProgMutex)
              UpdateProgress(progH,"Optimizing mesh..."+Str(progress)+"%",progress)
              ZoomToolBlock(progress / 100,progress / 100,progress / 100)
              RenderWorld()
              FlipBuffers()
            Wend
            ZoomToolBlock(1,1,1)
            CloseProgress(progH)
            If ListSize(SchBlocks())
              g_UpdateSchGeo = 1
            EndIf
            
            If(g_UpdateSchGeo)
              WorldShadows(#PB_Shadow_None)
            Else
              g_EditMode = #mode_normal
              HideToolBlock()
            EndIf
            updateMsgBox(g_EditMode, currentchunk\vis)
          EndIf
        Case #menu_save:
          g_SchematicFile = ""
          g_EditMode = #mode_cut
          If(IsStaticGeometry(schGeo\id))
            WorldShadows(g_Shadows)
            FreeStaticGeometry(schGeo\id)
          EndIf
          setToolBlocktype(-1)
          ScaleToolBlock(3.03,3.03,3.03)
          MoveNode(#ToolBlock,Round(CameraX(0),#PB_Round_Up),Round(CameraY(0),#PB_Round_Up),Round(CameraZ(0),#PB_Round_Up),#PB_Absolute)
          MoveNode(#ToolBlock,CameraDirectionX(0)*6,0.5,CameraDirectionZ(0)*6,#PB_Relative)
          MoveNode(#ToolBlock,Round(NodeX(#ToolBlock),#PB_Round_Up),Round(NodeY(#ToolBlock),#PB_Round_Up),Round(NodeZ(#ToolBlock),#PB_Round_Up),#PB_Absolute)
          CameraFollow(0,NodeID(#ToolBlock),0,0,1,1,0)
          updateMsgBox(g_EditMode, currentchunk\vis)
        Case #menu_fillWithBlocks:
          g_SchematicFile = ""
          initBlockSubstWindow()
          For i=0 To 255
            If SBlocks(i)\mode > 0 And SBlocks(i)\mode < 4
              AddBlockToList(SBlocks(i)\name,i,0)
            EndIf
          Next i
          ResetMap(CBlocks())
          While NextMapElement(CBlocks())
            AddBlockToList(CBlocks()\name,66,CBlocks()\id)
          Wend
          g_EditMode = #mode_fill
          If(IsStaticGeometry(schGeo\id))
            FreeStaticGeometry(schGeo\id)
          EndIf
          setToolBlocktype(0)
          FillerBlock\id = 0
          FillerBlock\cID = 0
          ScaleToolBlock(3.03,3.03,3.03)
          MoveNode(#ToolBlock,Round(CameraX(0),#PB_Round_Up),Round(CameraY(0),#PB_Round_Up),Round(CameraZ(0),#PB_Round_Up),#PB_Absolute)
          MoveNode(#ToolBlock,CameraDirectionX(0)*6,0.5,CameraDirectionZ(0)*6,#PB_Relative)
          MoveNode(#ToolBlock,Round(NodeX(#ToolBlock),#PB_Round_Up),Round(NodeY(#ToolBlock),#PB_Round_Up),Round(NodeZ(#ToolBlock),#PB_Round_Up),#PB_Absolute)
          CameraFollow(0,NodeID(#ToolBlock),0,0,1,1,0)
        Case #menu_quit:
          g_exit = 1
        Case #menu_nolocalmods:
          If g_noLocalMods
            g_noLocalMods = 0
          Else
            g_noLocalMods = 1
          EndIf
        Case #menu_chunkBorders:
          If g_chunkborders
            g_chunkborders = 0
          Else
            g_chunkborders = 1
          EndIf
          SetMenuItemState(0, #menu_chunkBorders, g_chunkborders)
          RebuildWorld()
        Case #menu_setPPos:
          If MessageRequester("Info","This will update the in game player position to the current camera position. Please make sure you dont bake yourself in solid Rock."+Chr(10)+Chr(13)+"Do it?",#PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
            WritePlayerPos(g_saveDir+g_LastWorld+"/",CameraX(0),CameraY(0),CameraZ(0))
            playerpos\x = CameraX(0)
            playerpos\z = CameraY(0)
            playerpos\y = CameraZ(0)
            MoveStart(@playerpos)
            MessageRequester("Info","OK, prepare yourself to wake up in foreign lands...")
            
          EndIf
        Case #menu_narrowHeight:
          If g_restrictHeight
            g_restrictHeight = 0
          Else
            g_restrictHeight = 1
          EndIf
          SetMenuItemState(0, #menu_narrowHeight, g_restrictHeight)
        Case #menu_viewFar:
          g_viewdistance = #distance_far
          SetMenuItemState(0,#menu_viewFar,1)
          SetMenuItemState(0,#menu_viewMed,0)
          SetMenuItemState(0,#menu_viewShort,0)
        Case #menu_viewMed:
          g_viewdistance = #distance_mid
          SetMenuItemState(0,#menu_viewFar,0)
          SetMenuItemState(0,#menu_viewMed,1)
          SetMenuItemState(0,#menu_viewShort,0)
        Case #menu_viewShort:
          g_viewdistance = #distance_short
          SetMenuItemState(0,#menu_viewFar,0)
          SetMenuItemState(0,#menu_viewMed,0)
          SetMenuItemState(0,#menu_viewShort,1)
        Case #menu_noCulling:
          If g_DoubleDraw
            g_DoubleDraw = 0
          Else
            g_DoubleDraw = 1
          EndIf
          SetMaterialCulling()
          SetMenuItemState(0, #menu_noCulling, g_DoubleDraw)
          If(g_Shadows  <> #PB_Shadow_None)
            RebuildWorld()
          EndIf
        Case #menu_shadows_none:
          g_shadows = #PB_Shadow_None
          WorldShadows(g_shadows,0,0,0)
          RebuildWorld()
          SetMenuItemState(0,#menu_shadows_none,1)
          SetMenuItemState(0,#menu_shadows_simple,0)
          SetMenuItemState(0,#menu_shadows_adv,0)
        Case #menu_shadows_simple:
          g_shadows = #PB_Shadow_Modulative
          WorldShadows(g_shadows,30,RGB(150,150,170))
          RebuildWorld()
          SetMenuItemState(0,#menu_shadows_none,0)
          SetMenuItemState(0,#menu_shadows_simple,1)
          SetMenuItemState(0,#menu_shadows_adv,0)
        Case #menu_shadows_adv:
          g_shadows = #PB_Shadow_Additive
          WorldShadows(g_Shadows,25,RGB(10,10,30),256)
          RebuildWorld()
          SetMenuItemState(0,#menu_shadows_none,0)
          SetMenuItemState(0,#menu_shadows_simple,0)
          SetMenuItemState(0,#menu_shadows_adv,1)
        Case #menu_define_marker:
          g_EditMode = #mode_chunksel_nodel
          updateMsgBox(g_EditMode, currentchunk\vis)
          ScaleToolBlock(32.01,200.01,32.01)
          MoveNode(#ToolBlock,Round(CameraX(0)/16,#PB_Round_Up)*16,Round(CameraY(0),#PB_Round_Up)-25,Round(CameraZ(0)/16,#PB_Round_Up)*16,#PB_Absolute)
          MoveNode(#ToolBlock,CameraDirectionX(0)*16,0,CameraDirectionZ(0)*16,#PB_Relative)
          MoveNode(#ToolBlock,Round(NodeX(#ToolBlock)/16,#PB_Round_Up)*16-0.26,Round(NodeY(#ToolBlock),#PB_Round_Up),Round(NodeZ(#ToolBlock)/16,#PB_Round_Up)*16-0.26,#PB_Absolute)
        Case #menu_remove_marker:
          ResetList(markers())
          While(NextElement(markers()))
            If IsEntity(markers()\entity)
              FreeEntity(markers()\entity)
            EndIf
          Wend
          ClearList(markers())
          g_EditMode = #mode_normal
          HideToolBlock()
        Case #menu_del_only:
          g_SchematicFile = ""
          If g_EditMode = #mode_chunksel_nodel
            MessageRequester("Attention","There is a marker selection, that is not yet confirmed, please finish the selection first, by either confirming (Enter) or deleting (Escape) the current selection.")
          Else
            NewMap affectedChunks.xy()
            thischunnk.xy
            ResetList(markers())
            While(NextElement(markers()))
              For blockx = markers()\x*2 - (markers()\sx-1)/2 To markers()\x*2 + (markers()\sx-1)/2
                For blocky = markers()\z*2 - (markers()\sz-1)/2 To markers()\z*2 + (markers()\sz-1)/2
                  getChunk(@thischunnk,blockx/2,blocky/2)
                  affectedChunks(Str(thischunnk\vis))\vis = thischunnk\vis
                  affectedChunks()\x = thischunnk\x
                  affectedChunks()\y = thischunnk\y
                Next
              Next
            Wend
            ResetMap(affectedChunks())
            db = OpenDatabase(#PB_Any, g_saveDir+g_LastWorld+"/"+"chunkdata.sqlite", "", "",#PB_Database_SQLite)
            While NextMapElement(affectedChunks())
              If FileSize(g_saveDir+g_LastWorld+"/"+Str(affectedChunks()\vis)+".chunks")
                DeleteFile(g_saveDir+g_LastWorld+"/"+Str(affectedChunks()\vis)+".chunks")
              EndIf
              If FileSize(g_saveDir+g_LastWorld+"/"+Str(affectedChunks()\vis)+".chunkmon")
                DeleteFile(g_saveDir+g_LastWorld+"/"+Str(affectedChunks()\vis)+".chunkmon")
              EndIf
              If(db)
                DatabaseUpdate(db, "DELETE FROM CHUNKDATA WHERE chunkid = "+Str(affectedChunks()\vis)+";")
                DatabaseUpdate(db, "DELETE FROM MESHOBJECTS WHERE chunkid = "+Str(affectedChunks()\vis)+";")
              EndIf
              deleteChunk(affectedChunks()\vis)
            Wend
            CloseDatabase(db)
            DeleteFile(g_instaLoadDir+g_LastWorld+"/"+"chunkmeshes.sqlite")
            ResetList(markers())
            While(NextElement(markers()))
              If IsEntity(markers()\entity)
                FreeEntity(markers()\entity)
              EndIf
            Wend
            ClearList(markers())
            g_EditMode = #mode_normal
            HideToolBlock()
          EndIf
        Case #menu_del_except:
          g_SchematicFile = ""
          If g_EditMode = #mode_chunksel_nodel
            MessageRequester("Attention","There is a marker selection, that is not yet confirmed, please finish the selection first, by either confirming (Enter) or deleting (Escape) the current selection.")
          Else
            NewMap affectedChunks.xy()
            thischunnk.xy
            ResetList(markers())
            While(NextElement(markers()))
              For blockx = markers()\x*2 - (markers()\sx-1)/2 To markers()\x*2 + (markers()\sx-1)/2
                For blocky = markers()\z*2 - (markers()\sz-1)/2 To markers()\z*2 + (markers()\sz-1)/2
                  getChunk(@thischunnk,blockx/2,blocky/2)
                  affectedChunks(Str(thischunnk\vis))\vis = thischunnk\vis
                  affectedChunks()\x = thischunnk\x
                  affectedChunks()\y = thischunnk\y
                Next
              Next
            Wend
            If(MapSize(affectedChunks()))
              dir = ExamineDirectory(#PB_Any,g_saveDir+g_LastWorld+"/","*.chunks")
              If dir
                While NextDirectoryEntry(dir)
                  If Not FindMapElement(affectedChunks(),GetFilePart(DirectoryEntryName(dir),#PB_FileSystem_NoExtension))
                    DeleteFile(g_saveDir+g_LastWorld+"/"+DirectoryEntryName(dir))
                  EndIf
                Wend
                FinishDirectory(dir)
              EndIf
              dir = ExamineDirectory(#PB_Any,g_saveDir+g_LastWorld+"/","*.chunkmon")
              If dir
                While NextDirectoryEntry(dir)
                  If Not FindMapElement(affectedChunks(),GetFilePart(DirectoryEntryName(dir),#PB_FileSystem_NoExtension))
                    DeleteFile(g_saveDir+g_LastWorld+"/"+DirectoryEntryName(dir))
                  EndIf
                Wend
                FinishDirectory(dir)
              EndIf
              ResetMap(affectedChunks())
              If NextMapElement(affectedChunks())
                exclude.s = " chunkid != "+Str(affectedChunks()\vis)
                While NextMapElement(affectedChunks())
                  exclude + " AND chunkid != "+Str(affectedChunks()\vis)
                Wend
                db = OpenDatabase(#PB_Any, g_saveDir+g_LastWorld+"/"+"chunkdata.sqlite", "", "",#PB_Database_SQLite)
                If(db)
                  DatabaseUpdate(db, "DELETE FROM CHUNKDATA WHERE"+exclude+";")
                  DatabaseUpdate(db, "DELETE FROM MESHOBJECTS WHERE"+exclude+";")
                  CloseDatabase(db)
                EndIf
              EndIf
              RebuildWorld()
              DeleteFile(g_instaLoadDir+g_LastWorld+"/"+"chunkmeshes.sqlite")
            Else
              MessageRequester("Not possible","Please select at least one chunk to keep, to delete the whole world you don't need this tool.")
            EndIf
            ResetList(markers())
            While(NextElement(markers()))
              If IsEntity(markers()\entity)
                FreeEntity(markers()\entity)
              EndIf
            Wend
            ClearList(markers())
            g_EditMode = #mode_normal
            HideToolBlock()
          EndIf
        Case #menu_copyFilesToDB:
          If MessageRequester("Attention", "Would you really like To copy all single chunk files into the sqlite database? It is recommended to do a backup of your world before this!",#PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
            db = OpenDatabase(#PB_Any, g_saveDir+g_LastWorld+"/"+"chunkdata.sqlite", "", "",#PB_Database_SQLite)
            filecount = 0
            currfile = 0
            existing = 0
            If(db)
              dir = ExamineDirectory(#PB_Any,g_saveDir+g_LastWorld+"/","*.*")
              If dir
                While NextDirectoryEntry(dir)
                  If GetExtensionPart(DirectoryEntryName(dir)) = "chunks" Or GetExtensionPart(DirectoryEntryName(dir)) = "chunkmon"
                    filecount+1
                  EndIf
                Wend
                FinishDirectory(dir)
              EndIf
              OpenProgress(progH.phnd, "Copy Chunkdata...", "Copy old chunkdata into database...")
              dir = ExamineDirectory(#PB_Any,g_saveDir+g_LastWorld+"/","*.chunks")
              If dir
                While NextDirectoryEntry(dir)
                  If GetExtensionPart(DirectoryEntryName(dir)) = "chunks"
                    currfile + 1
                    progress = (currfile * 100) / filecount
                    UpdateProgress(progH,"Copy Chunks into database..."+Str(progress)+"%",progress)
                    chnk = ReadFile(#PB_Any,g_saveDir+g_LastWorld+"/"+DirectoryEntryName(dir),#PB_File_SharedRead)
                    If chnk
                      id = Val(GetFilePart(DirectoryEntryName(dir),#PB_FileSystem_NoExtension))
                      If DatabaseQuery(db,"SELECT CHUNKID from CHUNKDATA WHERE CHUNKID = "+Str(id)+";")
                        entry = FirstDatabaseRow(db)
                        FinishDatabaseQuery(db)
                        If Not entry
                          *chnkmem = AllocateMemory(Lof(chnk))
                          FileSeek(chnk,0)
                          ReadData(chnk,*chnkmem,Lof(chnk))
                          SetDatabaseBlob(db,0,*chnkmem,Lof(chnk))
                          CloseFile(chnk)
                          If CheckDatabaseUpdate(db, "INSERT INTO CHUNKDATA (CHUNKID, DATA) VALUES ("+Str(id)+", ?);")
                            DeleteFile(g_saveDir+g_LastWorld+"/"+DirectoryEntryName(dir))
                          Else
                            MessageRequester("Warning","Chunk with ID "+Str(id)+" could not be copied, operation aborted!")
                            CloseDatabase(db)
                            FinishDirectory(dir)
                            CloseProgress(progH)
                            ProcedureReturn 0
                          EndIf
                        Else
                          CloseFile(chnk)
                          existing+1
                        EndIf
                      Else
                        MessageRequester("Warning","The check if exists query failed on chunk ID "+Str(id)+", operation aborted!")
                        CloseDatabase(db)
                        FinishDirectory(dir)
                        CloseProgress(progH)
                        ProcedureReturn 0
                      EndIf
                    Else
                      MessageRequester("Warning","Chunk with ID "+Str(id)+" could not be opened, operation aborted!")
                      CloseDatabase(db)
                      FinishDirectory(dir)
                      CloseProgress(progH)
                      ProcedureReturn 0
                    EndIf
                  EndIf
                Wend
                FinishDirectory(dir)
              EndIf
              dir = ExamineDirectory(#PB_Any,g_saveDir+g_LastWorld+"/","*.chunkmon")
              If dir
                While NextDirectoryEntry(dir)
                  If GetExtensionPart(DirectoryEntryName(dir)) = "chunkmon"
                    currfile + 1
                    progress = (currfile * 100) / filecount
                    UpdateProgress(progH,"Copy Chunk Meshes into database..."+Str(progress)+"%",progress)
                    chnk = ReadFile(#PB_Any,g_saveDir+g_LastWorld+"/"+DirectoryEntryName(dir),#PB_File_SharedRead)
                    If chnk
                      id = Val(GetFilePart(DirectoryEntryName(dir),#PB_FileSystem_NoExtension))
                      If DatabaseQuery(db,"SELECT CHUNKID from MESHOBJECTS WHERE CHUNKID = "+Str(id)+";")
                        entry = FirstDatabaseRow(db)
                        FinishDatabaseQuery(db)
                        If Not entry
                          *chnkmem = AllocateMemory(Lof(chnk))
                          FileSeek(chnk,0)
                          ReadData(chnk,*chnkmem,Lof(chnk))
                          SetDatabaseBlob(db,0,*chnkmem,Lof(chnk))
                          CloseFile(chnk)
                          If CheckDatabaseUpdate(db, "INSERT INTO MESHOBJECTS (CHUNKID,DATA) VALUES ("+Str(id)+", ?);")
                            DeleteFile(g_saveDir+g_LastWorld+"/"+DirectoryEntryName(dir))
                          Else
                            MessageRequester("Warning","Meshes of Chunk with ID "+Str(id)+" could not be copied, operation aborted!")
                            CloseDatabase(db)
                            FinishDirectory(dir)
                            CloseProgress(progH)
                            ProcedureReturn 0
                          EndIf
                        Else
                          CloseFile(chnk)
                          existing+1
                        EndIf
                      Else
                        MessageRequester("Warning","The check if exists query failed on chunk ID "+Str(id)+", operation aborted!")
                        CloseDatabase(db)
                        FinishDirectory(dir)
                        CloseProgress(progH)
                        ProcedureReturn 0
                      EndIf
                    Else
                      MessageRequester("Warning","Meshes of Chunk with ID "+Str(id)+" could not be opened, operation aborted!")
                      CloseDatabase(db)
                      FinishDirectory(dir)
                      CloseProgress(progH)
                      ProcedureReturn 0
                    EndIf
                  EndIf
                Wend
                FinishDirectory(dir)
              EndIf
              CloseProgress(progH)
              CloseDatabase(db)
              If existing
                If MessageRequester("Leftover files","There are "+Str(existing)+" files left over, they were copied already by the game, should they be removed as well?",#PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
                  dir = ExamineDirectory(#PB_Any,g_saveDir+g_LastWorld+"/","*.*")
                  If dir
                    While NextDirectoryEntry(dir)
                      If GetExtensionPart(DirectoryEntryName(dir)) = "chunks" Or GetExtensionPart(DirectoryEntryName(dir)) = "chunkmon"
                        DeleteFile(g_saveDir+g_LastWorld+"/"+DirectoryEntryName(dir))
                      EndIf
                    Wend
                    FinishDirectory(dir)
                  EndIf
                EndIf
              EndIf
              MessageRequester("Done!","All done, please check, if everything is OK before getting rid of your Backup :)")
            Else
              MessageRequester("Impossible","There is currently no database for this world, please open the world at least once with the current CyubeVR Version before running this operation.")
            EndIf
          EndIf
        Case 90:
          RunProgram("http://cyube3dit.el-wa.org/index.php?action=quickstart", "", "")
        Case 91:
          RunProgram("http://cyube3dit.el-wa.org/index.php?action=download", "", "")
        Case 92:
          RunProgram("http://cyube3dit.el-wa.org/index.php?action=customblocks", "", "")  
        Case 93:
          aboutWnd = OpenWindow(#PB_Any,0,0,600,350,"About CyubE3dit - CyubeVR swiss army knife.", #PB_Window_WindowCentered | #PB_Window_Tool)
          StickyWindow(aboutWnd,#True)
          
          txtHead=TextGadget(#PB_Any,10,10,580,35,"CyubE3dit",#PB_Text_Center)
          SetGadgetFont(txtHead,FontID(#Font_about_title))
          txtVers=TextGadget(#PB_Any,10,40,580,15,"Version "+#VERSION,#PB_Text_Center) 
          SetGadgetFont(txtVers,FontID(#Font_about_version))
          txt=TextGadget(#PB_Any,10,100,580,250,"Special thanks to @B4nH4mm3r on discord for all the testing and the nice ideas!"+Chr(10)+Chr(13)+Chr(10)+Chr(13)+"Thanks to @Sbsce (Stonebrick Studios) for this awesome game and"+Chr(10)+Chr(13)+"the kind support in decoding all the world data!!"+Chr(10)+Chr(13)+Chr(10)+Chr(13)+"CyubeVR world viewer and multi purpose tool"+Chr(10)+Chr(13)+"under development since 2020 by m0w1337",#PB_Text_Center) 
          SetGadgetFont(txt,FontID(#Font_about_text))
          closebtn = ButtonGadget(#PB_Any, 250,315,100,25,"Close")
          Repeat
            If WaitWindowEvent() = #PB_Event_Gadget
              If EventGadget() = closebtn
                Break
              EndIf
            EndIf
          ForEver 
          CloseWindow(aboutWnd)
      EndSelect
    EndIf
  EndProcedure
  
; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 153
; FirstLine = 141
; Folding = -
; EnableXP