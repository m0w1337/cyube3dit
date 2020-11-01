#BLOCK_AIR = 3
#BLOCK_TORCH = 15
#BLOCK_STRAWS = 5
#BLOCK_FLOWER1 = 16
#BLOCK_FLOWER2 = 17 
#BLOCK_FLOWER3 = 36
#BLOCK_FLOWER4 = 39
#BLOCK_FLOWER_RAINBOW = 63
#BLOCK_GLASS = 3

Enumeration
    #Right
    #Left
    #Forward
    #Back
    #Up
    #Down
EndEnumeration

Global Dim CurrChunkData.b(31,31,799)

Global NowVisChunks = 0

Global NewChunkToLoad = -1
Global GeneratingChunk = -1
Global ChunkToFinish = -1
Global chunkx
Global chunky
Global xoffs
Global yoffs



Procedure.l spiralx(n)
  k=Round((Sqr(n)-1)/2,#PB_Round_Up)
  t=2*k+1
  m=Pow(t,2)
  t=t-1
  If(n>=m-t)
    ProcedureReturn k-(m-n)
  Else
    m=m-t
  EndIf
  If(n>=m-t)
    ProcedureReturn -k
  Else
    m=m-t
  EndIf
  If(n>=m-t)
    ProcedureReturn -k+(m-n)
  Else
    ProcedureReturn k
  EndIf
EndProcedure

  
Procedure.l spiraly(n)
  k=Round((Sqr(n)-1)/2,#PB_Round_Up)
  t=2*k+1
  m=Pow(t,2)
  t=t-1
  If(n>=m-t)
    ProcedureReturn -k
  Else
    m=m-t
  EndIf
  If(n>=m-t)
    ProcedureReturn -k+(m-n)
  Else
    m=m-t
  EndIf
  If(n>=m-t)
    ProcedureReturn k
  Else
    ProcedureReturn k-(m-n-t)
  EndIf
EndProcedure

Macro AddBlockToGeo(GeoID,BBGeoID,SchBlocks,startx,starty,startz, showBorders)
  id = SchBlocks\id
  bb = SchBlocks\bb
  by.f = starty+SchBlocks\z*0.5
  bx.f = startx+SchBlocks\x*0.5
  bz.f = startz+SchBlocks\y*0.5
  ent = 2
  If SBlocks(id)\type <> #BLOCKTYPE_Torch
    If id = 66
      cID = SchBlocks\cblock
      If(lastcID <> cID)
        lastcID = cID
        If Not FindMapElement(CBlocks(),Str(cID))
          addCustomBlock(cID)
        EndIf
        BMode = CBlocks()\mode
        Select BMode
          Case 1:
            SetEntityMaterial(#FaceTop,MaterialID(CBlocks()\tex(#texInd_all)))
            SetEntityMaterial(#FaceBottom,MaterialID(CBlocks()\tex(#texInd_all)))
            SetEntityMaterial(#FaceLeft,MaterialID(CBlocks()\tex(#texInd_all)))
            SetEntityMaterial(#FaceRight,MaterialID(CBlocks()\tex(#texInd_all)))
            SetEntityMaterial(#FaceFront,MaterialID(CBlocks()\tex(#texInd_all)))
            SetEntityMaterial(#FaceBack,MaterialID(CBlocks()\tex(#texInd_all)))
          Case 2:
            SetEntityMaterial(#FaceTop,MaterialID(CBlocks()\tex(#texInd_upDown)))
            SetEntityMaterial(#FaceBottom,MaterialID(CBlocks()\tex(#texInd_upDown)))
            SetEntityMaterial(#FaceLeft,MaterialID(CBlocks()\tex(#texInd_sides)))
            SetEntityMaterial(#FaceRight,MaterialID(CBlocks()\tex(#texInd_sides)))
            SetEntityMaterial(#FaceFront,MaterialID(CBlocks()\tex(#texInd_sides)))
            SetEntityMaterial(#FaceBack,MaterialID(CBlocks()\tex(#texInd_sides)))
          Case 3:
            SetEntityMaterial(#FaceTop,MaterialID(CBlocks()\tex(#texInd_top)))
            SetEntityMaterial(#FaceBottom,MaterialID(CBlocks()\tex(#texInd_bottom)))
            SetEntityMaterial(#FaceLeft,MaterialID(CBlocks()\tex(#texInd_sides)))
            SetEntityMaterial(#FaceRight,MaterialID(CBlocks()\tex(#texInd_sides)))
            SetEntityMaterial(#FaceFront,MaterialID(CBlocks()\tex(#texInd_sides)))
            SetEntityMaterial(#FaceBack,MaterialID(CBlocks()\tex(#texInd_sides)))
          Case 4:
            SetEntityMaterial(#FaceTop,MaterialID(CBlocks()\tex(#texInd_top)))
            SetEntityMaterial(#FaceBottom,MaterialID(CBlocks()\tex(#texInd_bottom)))
            SetEntityMaterial(#FaceLeft,MaterialID(CBlocks()\tex(#texInd_left)))
            SetEntityMaterial(#FaceRight,MaterialID(CBlocks()\tex(#texInd_right)))
            SetEntityMaterial(#FaceFront,MaterialID(CBlocks()\tex(#texInd_front)))
            SetEntityMaterial(#FaceBack,MaterialID(CBlocks()\tex(#texInd_back)))
        EndSelect
        lastID = 66
      EndIf
    ElseIf id <> lastID
      lastcID = -1
      Select SBlocks(id)\mode
        Case 0:
          SetEntityMaterial(#FaceTop,MaterialID(SBlocks(id)\tex(#texInd_all)))
          SetEntityMaterial(#FaceBottom,MaterialID(SBlocks(id)\tex(#texInd_all)))
          SetEntityMaterial(#FaceLeft,MaterialID(SBlocks(id)\tex(#texInd_all)))
          SetEntityMaterial(#FaceRight,MaterialID(SBlocks(id)\tex(#texInd_all)))
          SetEntityMaterial(#FaceFront,MaterialID(SBlocks(id)\tex(#texInd_all)))
          SetEntityMaterial(#FaceBack,MaterialID(SBlocks(id)\tex(#texInd_all)))
        Case 1:
          SetEntityMaterial(#FaceTop,MaterialID(SBlocks(id)\tex(#texInd_all)))
          SetEntityMaterial(#FaceBottom,MaterialID(SBlocks(id)\tex(#texInd_all)))
          SetEntityMaterial(#FaceLeft,MaterialID(SBlocks(id)\tex(#texInd_all)))
          SetEntityMaterial(#FaceRight,MaterialID(SBlocks(id)\tex(#texInd_all)))
          SetEntityMaterial(#FaceFront,MaterialID(SBlocks(id)\tex(#texInd_all)))
          SetEntityMaterial(#FaceBack,MaterialID(SBlocks(id)\tex(#texInd_all)))
        Case 2:
          SetEntityMaterial(#FaceTop,MaterialID(SBlocks(id)\tex(#texInd_upDown)))
          SetEntityMaterial(#FaceBottom,MaterialID(SBlocks(id)\tex(#texInd_upDown)))
          SetEntityMaterial(#FaceLeft,MaterialID(SBlocks(id)\tex(#texInd_sides)))
          SetEntityMaterial(#FaceRight,MaterialID(SBlocks(id)\tex(#texInd_sides)))
          SetEntityMaterial(#FaceFront,MaterialID(SBlocks(id)\tex(#texInd_sides)))
          SetEntityMaterial(#FaceBack,MaterialID(SBlocks(id)\tex(#texInd_sides)))
        Case 3:
          SetEntityMaterial(#FaceTop,MaterialID(SBlocks(id)\tex(#texInd_top)))
          SetEntityMaterial(#FaceBottom,MaterialID(SBlocks(id)\tex(#texInd_bottom)))
          SetEntityMaterial(#FaceLeft,MaterialID(SBlocks(id)\tex(#texInd_sides)))
          SetEntityMaterial(#FaceRight,MaterialID(SBlocks(id)\tex(#texInd_sides)))
          SetEntityMaterial(#FaceFront,MaterialID(SBlocks(id)\tex(#texInd_sides)))
          SetEntityMaterial(#FaceBack,MaterialID(SBlocks(id)\tex(#texInd_sides)))
        Case 4:
          SetEntityMaterial(#FaceTop,MaterialID(SBlocks(id)\tex(#texInd_top)))
          SetEntityMaterial(#FaceBottom,MaterialID(SBlocks(id)\tex(#texInd_bottom)))
          SetEntityMaterial(#FaceLeft,MaterialID(SBlocks(id)\tex(#texInd_left)))
          SetEntityMaterial(#FaceRight,MaterialID(SBlocks(id)\tex(#texInd_right)))
          SetEntityMaterial(#FaceFront,MaterialID(SBlocks(id)\tex(#texInd_front)))
          SetEntityMaterial(#FaceBack,MaterialID(SBlocks(id)\tex(#texInd_back)))
        Case 5:
          SetEntityMaterial(#BillBoardMesh,MaterialID(SBlocks(id)\tex(#texInd_all)))
      EndSelect
      lastID = id
    EndIf
    sx.f = 1
    sy.f = 1
    If(showBorders)
      If(SchBlocks\x = 31 And Not bb & $80)
        sx = 0.9
        bx = bx-0.025
        If(bb & $01)
          AddStaticGeometryEntity(GeoID, EntityID(#LineTop), bx+0.25,by,bz,0.1,1,1)
        EndIf
        If(bb & $02)
          AddStaticGeometryEntity(GeoID, EntityID(#LineBottom), bx+0.25,by,bz,0.1,1,1)
        EndIf
         If(bb & $04)
           AddStaticGeometryEntity(GeoID, EntityID(#FaceLeft), bx+0.25,by,bz,0.1,1,1)
         EndIf
         If(bb & $08)
           AddStaticGeometryEntity(GeoID, EntityID(#FaceRight), bx+0.25,by,bz,0.1,1,1)
         EndIf
        If(bb & $10)
          AddStaticGeometryEntity(GeoID, EntityID(#LineFront), bx+0.25,by,bz,0.1,1,1)
        EndIf
        If(bb & $20)
          AddStaticGeometryEntity(GeoID, EntityID(#LineBack), bx+0.25,by,bz,0.1,1,1)
        EndIf
      EndIf
      If(SchBlocks\y = 31 And Not bb & $80)
        sy = 0.9
        bz = bz-0.025
        If(bb & $01)
          AddStaticGeometryEntity(GeoID, EntityID(#LineTop), bx,by,bz+0.25,1,1,0.1)
        EndIf
        If(bb & $02)
          AddStaticGeometryEntity(GeoID, EntityID(#LineBottom), bx,by,bz+0.25,1,1,0.1)
        EndIf
        If(bb & $04)
          AddStaticGeometryEntity(GeoID, EntityID(#LineLeft), bx,by,bz+0.25,1,1,0.1)
        EndIf
        If(bb & $08)
          AddStaticGeometryEntity(GeoID, EntityID(#LineRight), bx,by,bz+0.25,1,1,0.1)
        EndIf
        If(bb & $10)
          AddStaticGeometryEntity(GeoID, EntityID(#FaceFront), bx,by,bz+0.25,1,1,0.1)
        EndIf
        If(bb & $20)
          AddStaticGeometryEntity(GeoID, EntityID(#FaceBack), bx,by,bz+0.25,1,1,0.1)
        EndIf
      EndIf
    EndIf
    If(bb & $80)
      AddStaticGeometryEntity(BBGeoID, EntityID(#BillBoardMesh),bx,by,bz,sx,1,sy)
    Else
      If(bb & $01)
        AddStaticGeometryEntity(GeoID, EntityID(#FaceTop), bx,by,bz,sx,1,sy)
      EndIf
      If(bb & $02)
        AddStaticGeometryEntity(GeoID, EntityID(#FaceBottom), bx,by,bz,sx,1,sy)
      EndIf
      If(bb & $04)
        AddStaticGeometryEntity(GeoID, EntityID(#FaceLeft), bx,by,bz,sx,1,sy)
      EndIf
      If(bb & $08)
        AddStaticGeometryEntity(GeoID, EntityID(#FaceRight), bx,by,bz,sx,1,sy)
      EndIf
      If(bb & $10)
        AddStaticGeometryEntity(GeoID, EntityID(#FaceFront), bx,by,bz,sx,1,sy)
      EndIf
      If(bb & $20)
        AddStaticGeometryEntity(GeoID, EntityID(#FaceBack), bx,by,bz,sx,1,sy)
      EndIf
    EndIf
  Else
    ent = EntityID(SBlocks(id)\mesh)
    Select SchBlocks\cblock
      Case #Right:
        AddStaticGeometryEntity(BBGeoID, ent, bx,by,bz,1,1,1,0,0,0)
      Case #Left:
        AddStaticGeometryEntity(BBGeoID, ent, bx,by,bz,1,1,1,0,180,0)
      Case #Forward:
        AddStaticGeometryEntity(BBGeoID, ent, bx,by,bz,1,1,1,0,90,0)
      Case #Back:
        AddStaticGeometryEntity(BBGeoID, ent, bx,by,bz,1,1,1,0,-90,0)
      Case #Up:
        AddStaticGeometryEntity(BBGeoID, ent, bx,by-0.36,bz-0.12,1,1.4,1,0,-90,0)
      Default:
        AddStaticGeometryEntity(BBGeoID, ent, bx,by+0.36,bz+0.12,1,1.4,1,180,0,0)
    EndSelect
    ent = -1
  EndIf
EndMacro

Procedure.d GetChunkList(WorldDir.s, *player.pos)
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
    For i = 0 To numchunks-1
      ReadData(0, *chunkdata, 4)
      xCoord.s = Str(PeekL(*chunkdata)/100)
      ReadData(0, *chunkdata, 4)
      yCoord.s  = Str(PeekL(*chunkdata)/100)
      chunks(xCoord+","+yCoord)\id = i
    Next
    ReadData(0, *chunkdata, 4)
    trashlen = PeekL(*chunkdata)
    FileSeek(0,trashlen*12+24+28,#PB_Relative)
    *chunkdata = ReAllocateMemory(*chunkdata, 8)
    ReadData(0, *chunkdata, 8)
    *player\x = PeekD(*chunkdata) / 100
    ReadData(0, *chunkdata, 8)
    *player\y = PeekD(*chunkdata) / 100
    ReadData(0, *chunkdata, 8)
    *player\z = 2 + PeekD(*chunkdata) / 100
    FreeMemory(*chunkdata)
    CloseFile(0)
  EndIf
  If(MapSize(chunks()) > 10)
    ProcedureReturn 1
  Else
    ProcedureReturn 0
  EndIf
EndProcedure



Procedure drawChunk(meshnum,threadnum,x,y,resetMaterial)
  Shared CBlocks() 
  Static lastID
  Static lastcID
  Static currGeoID
  Static currBBGeoID
  added = 0
  If(resetMaterial)
    lastID = -1
    lastcID = -1
  EndIf
  
  If lastpart(threadnum) = -1
    lastpart(threadnum) = 0
    g_drawing(threadnum) = 1
    currGeoID = CreateStaticGeometry(#PB_Any, 32, 50, 32, #True)
    currBBGeoID = CreateStaticGeometry(#PB_Any, 32, 50, 32, #False)
    meshIDs(Str(meshnum))\id(lastpart(threadnum)) = currGeoID
    meshIDs(Str(meshnum))\id(16) = currBBGeoID
  EndIf
   
  start.q = ElapsedMilliseconds()
  While (ElapsedMilliseconds() - start) < 25
    If IsStaticGeometry(currGeoID) And IsStaticGeometry(currBBGeoID)
      GeoStillPresent = 1
    Else
      GeoStillPresent = 0
    EndIf
    
    If(lastpart(threadnum) = 12)
      If IsStaticGeometry(currBBGeoID)
        BuildStaticGeometry(currBBGeoID)
        meshIDs(Str(meshnum))\done = 1
      EndIf
      g_drawing(threadnum) = 0
      lastpart(threadnum) = -1
      ProcedureReturn 1
    Else
      If currGeoID = 0
        If(NextElement(g_chunkArray(threadnum, lastpart(threadnum))\chunkmesh()) = 0 And lastpart(threadnum) < 12)  ;skip empty chunkparts
          lastpart(threadnum) = lastpart(threadnum) + 1
        ElseIf(lastpart(threadnum) < 12)
          g_drawing(threadnum) = 1
          currGeoID = CreateStaticGeometry(#PB_Any, 32, 50, 32, #True)
          meshIDs(Str(meshnum))\id(lastpart(threadnum)) = currGeoID
          ResetList(g_chunkArray(threadnum, lastpart(threadnum))\chunkmesh())
          meshIDs()\done = 0
        Else
          lastpart(threadnum) = 12
        EndIf
      ElseIf (NextElement(g_chunkArray(threadnum, lastpart(threadnum))\chunkmesh()) And GeoStillPresent)
        AddBlockToGeo(currGeoID,currBBGeoID,g_chunkArray(threadnum, lastpart(threadnum))\chunkmesh(),x,0,y,g_chunkborders)
        added = 1
        
      ElseIf(Not GeoStillPresent)  ;stop drawing this chunk as soon as the drawing was interrupted from a delete, because it shouldn't be visible in this case
        g_drawing(threadnum) = 3
        lastpart(threadnum) = -1
        ProcedureReturn 1
      ElseIf(added = 0)
        BuildStaticGeometry(currGeoID)
        g_drawing(threadnum) = 1
        currGeoID = 0
        ProcedureReturn 0
       Else
         g_drawing(threadnum) = 2
         ProcedureReturn 0
      EndIf
    EndIf
  Wend
  
 ; UnlockMutex(DrawMutex)
  ProcedureReturn 0
EndProcedure

Procedure deleteChunk(chunk)
  If FindMapElement(meshIDs(),Str(chunk))
    For ii=0 To 16
      If(IsStaticGeometry(meshIDs()\id(ii)))
        FreeStaticGeometry(meshIDs()\id(ii))
      EndIf
    Next
    DeleteMapElement(meshIDs())
  EndIf
EndProcedure


Procedure DiscriminateChunk(threadnum)
Shared DelMutex
Shared Mutex
Delay((threadnum+1)*10)

lib = OpenLibrary(#PB_Any, ".\lz4.dll")
If lib
  db = OpenDatabase(#PB_Any, g_saveDir+g_LastWorld+"/chunkdata.sqlite", "", "",#PB_Database_SQLite)
  Repeat
    loadNew = 0
    Delay(50)
    If(g_chunk0ToRender(threadnum) = 0 And g_ChunkLoadingPaused = #False)
      If(g_restrictHeight)
        LowestZ = 100
        HighestZ = 249
      Else
        LowestZ = 0
        HighestZ = 799
        EndIf
      LockMutex(DelMutex)
      If (MapSize(visibleChunks()) < g_viewdistance * 2)
        
        camChunkx = Round(CameraX(0)/16,#PB_Round_Up)*16 - 8 
        camChunky = Round(CameraZ(0)/16,#PB_Round_Up)*16 - 8 
        radius = threadnum
        yCoord = camChunky
        yCoord = camChunky
        xCoord = camChunkx
     
        LockMutex(Mutex)
        While(FindMapElement(visibleChunks(),Str(xCoord)+","+Str(yCoord)) And radius < g_viewdistance)
          xCoord = camChunkx + spiralx(radius)*16
          yCoord = camChunky + spiraly(radius)*16
          radius = radius + #numthreads
        Wend
        If(radius < g_viewdistance)
          g_prepareX(threadnum) = xCoord
          g_prepareY(threadnum) = yCoord
          If(FindMapElement(chunks(), Str(xCoord)+","+Str(yCoord)))
            ChunkID = chunks()\id
          Else
            ChunkID = -1
          EndIf
          AddMapElement(visibleChunks(),Str(xCoord)+","+Str(yCoord))
          visibleChunks()\vis = ChunkID;numchunks(threadnum)
          visibleChunks()\x = xCoord
          visibleChunks()\y = yCoord
          g_prepareNewChunk(threadnum) = 0
          loadNew = 1
        EndIf
        UnlockMutex(Mutex)
      EndIf
      UnlockMutex(DelMutex)
      If(loadNew = 1)
        g_prepareID(threadnum) = ChunkID
        UnlockMutex(Mutex)
        If(FindMapElement(chunks(), Str(xCoord-16)+","+Str(yCoord)))
          ChunkLID = chunks()\id
        Else
          ChunkLID = -1
        EndIf
        If(FindMapElement(chunks(), Str(xCoord+16)+","+Str(yCoord)))
          ChunkRID = chunks()\id
        Else
          ChunkRID = -1
        EndIf
        If(FindMapElement(chunks(), Str(xCoord)+","+Str(yCoord+16)))
          ChunkUID = chunks()\id
        Else
          ChunkUID = -1
        EndIf
        If (FindMapElement(chunks(), Str(xCoord)+","+Str(yCoord-16)))
          ChunkDID = chunks()\id
        Else
          ChunkDID = -1
        EndIf
        UnlockMutex(Mutex)
        *destbuff  = AllocateMemory(32*32*800+4,#PB_Memory_NoClear)
        FillMemory(*destbuff,32*32*800+4,#BLOCK_AIR)
        *destbuffL  = AllocateMemory(10+32*32*800)
        ;FillMemory(*destbuffL,10+32*32*800,#BLOCK_STONE)
        *destbuffR  = AllocateMemory(10+32*32*800)
        ;FillMemory(*destbuffR,10+32*32*800,#BLOCK_STONE)
        *destbuffU  = AllocateMemory(10+32*32*800)
        ;FillMemory(*destbuffU,10+32*32*800,#BLOCK_STONE)
        *destbuffD  = AllocateMemory(10+32*32*800)
        ;FillMemory(*destbuffD,10+32*32*800,#BLOCK_STONE)
        *srcbuff = AllocateMemory(100)
        destsize = 0
          If(db)
              If DatabaseQuery(db,"SELECT data FROM CHUNKDATA WHERE chunkid = "+Str(ChunkID))
                If(NextDatabaseRow(db))
                  blobsize.i = DatabaseColumnSize(db, 0)
                  *srcbuff = ReAllocateMemory(*srcbuff,blobsize)
                  GetDatabaseBlob(db, 0, *srcbuff, blobsize)
                  msize = PeekL(*srcbuff+blobsize-4)
                  *destbuff = ReAllocateMemory(*destbuff,msize,#PB_Memory_NoClear)
                  If *destbuff
                    destsize.i = CallCFunction(lib, "LZ4_decompress_safe" ,*srcbuff,*destbuff,blobsize-4,msize)
                  EndIf               
                EndIf
                FinishDatabaseQuery(db)
              EndIf
              If(destsize = 0)
                file = ReadFile(#PB_Any,g_saveDir+g_LastWorld+"/"+Str(ChunkID)+".chunks", #PB_File_SharedRead)
                If(file)
                  blobsize.i = Lof(file)
                  *srcbuff = ReAllocateMemory(*srcbuff,blobsize)
                  ReadData(file, *srcbuff, blobsize)
                  CloseFile(file)
                  msize = PeekL(*srcbuff+blobsize-4)
                  If msize
                  *destbuff = ReAllocateMemory(*destbuff,msize,#PB_Memory_NoClear)
                    If *destbuff
                      destsize.i = CallCFunction(lib, "LZ4_decompress_safe" ,*srcbuff,*destbuff,blobsize-4,msize)
                    EndIf
                  EndIf
                EndIf
              EndIf
              
              destsize = 0
              If DatabaseQuery(db,"SELECT data FROM CHUNKDATA WHERE chunkid = "+Str(ChunkLID))
                If(NextDatabaseRow(db))
                  blobsize.i = DatabaseColumnSize(db, 0)
                  *srcbuff = ReAllocateMemory(*srcbuff,blobsize)
                  GetDatabaseBlob(db, 0, *srcbuff, blobsize)
                  ;msize = PeekL(*srcbuff+blobsize-4)
                  ;*destbuffL = ReAllocateMemory(*destbuffL,msize,#PB_Memory_NoClear)
                  If *destbuffL
                    destsize.i = CallCFunction(lib, "LZ4_decompress_safe" ,*srcbuff,*destbuffL,blobsize-4,10+32*32*800)
                  EndIf
                EndIf
                FinishDatabaseQuery(db)
              EndIf
              If(destsize = 0)
                file = ReadFile(#PB_Any,g_saveDir+g_LastWorld+"/"+Str(ChunkLID)+".chunks", #PB_File_SharedRead)
                If(file)
                  blobsize.i = Lof(file)
                  *srcbuff = ReAllocateMemory(*srcbuff,blobsize)
                  ReadData(file, *srcbuff, blobsize)
                  CloseFile(file)
                  ;msize = PeekL(*srcbuff+blobsize-4)
                  ;*destbuffL = ReAllocateMemory(*destbuffL,msize,#PB_Memory_NoClear)
                  If *destbuffL
                    destsize.i = CallCFunction(lib, "LZ4_decompress_safe" ,*srcbuff,*destbuffL,blobsize-4,10+32*32*800)
                  EndIf
                EndIf
              EndIf
              
              destsize = 0
              If DatabaseQuery(db,"SELECT data FROM CHUNKDATA WHERE chunkid = "+Str(ChunkRID))
                If(NextDatabaseRow(db))
                  blobsize.i = DatabaseColumnSize(db, 0)
                  *srcbuff = ReAllocateMemory(*srcbuff,blobsize)
                  GetDatabaseBlob(db, 0, *srcbuff, blobsize)
                  ;msize = PeekL(*srcbuff+blobsize-4)
                  ;*destbuffR = ReAllocateMemory(*destbuffR,msize,#PB_Memory_NoClear)
                  If *destbuffR
                    destsize.i = CallCFunction(lib, "LZ4_decompress_safe" ,*srcbuff,*destbuffR,blobsize-4,10+32*32*800)
                  EndIf
                EndIf
                FinishDatabaseQuery(db)
              EndIf
              If(destsize = 0)
                file = ReadFile(#PB_Any,g_saveDir+g_LastWorld+"/"+Str(ChunkRID)+".chunks", #PB_File_SharedRead)
                If(file)
                  blobsize.i = Lof(file)
                  *srcbuff = ReAllocateMemory(*srcbuff,blobsize)
                  ReadData(file, *srcbuff, blobsize)
                  CloseFile(file)
                  ;msize = PeekL(*srcbuff+blobsize-4)
                  ;*destbuffR = ReAllocateMemory(*destbuffR,msize,#PB_Memory_NoClear)
                  If *destbuffR
                    destsize.i = CallCFunction(lib, "LZ4_decompress_safe" ,*srcbuff,*destbuffR,blobsize-4,10+32*32*800)
                  EndIf
                EndIf
              EndIf
              
              destsize = 0
              If DatabaseQuery(db,"SELECT data FROM CHUNKDATA WHERE chunkid = "+Str(ChunkUID))
                If(NextDatabaseRow(db))
                  blobsize.i = DatabaseColumnSize(db, 0)
                  *srcbuff = ReAllocateMemory(*srcbuff,blobsize)
                  GetDatabaseBlob(db, 0, *srcbuff, blobsize)
                  ;msize = PeekL(*srcbuff+blobsize-4)
                  ;*destbuffU = ReAllocateMemory(*destbuffU,msize,#PB_Memory_NoClear)
                  If *destbuffU
                    destsize.i = CallCFunction(lib, "LZ4_decompress_safe" ,*srcbuff,*destbuffU,blobsize-4,10+32*32*800)
                  EndIf
                EndIf
                FinishDatabaseQuery(db)
              EndIf
              If(destsize = 0)
                file = ReadFile(#PB_Any,g_saveDir+g_LastWorld+"/"+Str(ChunkUID)+".chunks", #PB_File_SharedRead)
                If(file)
                  blobsize.i = Lof(file)
                  *srcbuff = ReAllocateMemory(*srcbuff,blobsize)
                  ReadData(file, *srcbuff, blobsize)
                  CloseFile(file)
                  ;msize = PeekL(*srcbuff+blobsize-4)
                  ;*destbuffU = ReAllocateMemory(*destbuffU,msize,#PB_Memory_NoClear)
                  If *destbuffU
                    destsize.i = CallCFunction(lib, "LZ4_decompress_safe" ,*srcbuff,*destbuffU,blobsize-4,10+32*32*800)
                  EndIf
                EndIf
              EndIf
              
              destsize = 0
              If DatabaseQuery(db,"SELECT data FROM CHUNKDATA WHERE chunkid = "+Str(ChunkDID))
                If(NextDatabaseRow(db))
                  blobsize.i = DatabaseColumnSize(db, 0)
                  *srcbuff = ReAllocateMemory(*srcbuff,blobsize)
                  GetDatabaseBlob(db, 0, *srcbuff, blobsize)
                  ;msize = PeekL(*srcbuff+blobsize-4)
                  ;*destbuffD = ReAllocateMemory(*destbuffD,msize,#PB_Memory_NoClear)
                  If *destbuffD
                    destsize.i = CallCFunction(lib, "LZ4_decompress_safe" ,*srcbuff,*destbuffD,blobsize-4,10+32*32*800)
                  EndIf
                EndIf
                FinishDatabaseQuery(db)
              EndIf
              If(destsize = 0)
                file = ReadFile(#PB_Any,g_saveDir+g_LastWorld+"/"+Str(ChunkDID)+".chunks", #PB_File_SharedRead)
                If(file)
                  blobsize.i = Lof(file)
                  *srcbuff = ReAllocateMemory(*srcbuff,blobsize)
                  ReadData(file, *srcbuff, blobsize)
                  CloseFile(file)
                  ;msize = PeekL(*srcbuff+blobsize-4)
                  ;*destbuffD = ReAllocateMemory(*destbuffD,msize,#PB_Memory_NoClear)
                  If *destbuffD
                    destsize.i = CallCFunction(lib, "LZ4_decompress_safe" ,*srcbuff,*destbuffD,blobsize-4,10+32*32*800)
                  EndIf
                EndIf
              EndIf
            Else
              file = ReadFile(#PB_Any,g_saveDir+g_LastWorld+"/"+Str(ChunkID)+".chunks", #PB_File_SharedRead)
              If(file)
                blobsize.i = Lof(file)
                *srcbuff = ReAllocateMemory(*srcbuff,blobsize)
                ReadData(file, *srcbuff, blobsize)
                CloseFile(file)
                msize = PeekL(*srcbuff+blobsize-4)
                *destbuff = ReAllocateMemory(*destbuff,msize,#PB_Memory_NoClear)
                If *destbuff
                  destsize.i = CallCFunction(lib, "LZ4_decompress_safe" ,*srcbuff,*destbuff,blobsize-4,msize)
                EndIf
              EndIf
              
              file = ReadFile(#PB_Any,g_saveDir+g_LastWorld+"/"+Str(ChunkLID)+".chunks", #PB_File_SharedRead)
              If(file)
                blobsize.i = Lof(file)
                *srcbuff = ReAllocateMemory(*srcbuff,blobsize)
                ReadData(file, *srcbuff, blobsize)
                CloseFile(file)
                ;msize = PeekL(*srcbuff+blobsize-4)
                ;*destbuffL = ReAllocateMemory(*destbuffL,msize,#PB_Memory_NoClear)
                If *destbuffL
                  destsize.i = CallCFunction(lib, "LZ4_decompress_safe" ,*srcbuff,*destbuffL,blobsize-4,10+32*32*800)
                EndIf
              EndIf
              
              file = ReadFile(#PB_Any,g_saveDir+g_LastWorld+"/"+Str(ChunkRID)+".chunks", #PB_File_SharedRead)
              If(file)
                blobsize.i = Lof(file)
                *srcbuff = ReAllocateMemory(*srcbuff,blobsize)
                ReadData(file, *srcbuff, blobsize)
                CloseFile(file)
                ;msize = PeekL(*srcbuff+blobsize-4)
                ;*destbuffR = ReAllocateMemory(*destbuffR,msize,#PB_Memory_NoClear)
                If *destbuffR
                  destsize.i = CallCFunction(lib, "LZ4_decompress_safe" ,*srcbuff,*destbuffR,blobsize-4,10+32*32*800)
                EndIf
              EndIf
              
              file = ReadFile(#PB_Any,g_saveDir+g_LastWorld+"/"+Str(ChunkUID)+".chunks", #PB_File_SharedRead)
              If(file)
                blobsize.i = Lof(file)
                *srcbuff = ReAllocateMemory(*srcbuff,blobsize)
                ReadData(file, *srcbuff, blobsize)
                CloseFile(file)
                ;msize = PeekL(*srcbuff+blobsize-4)
                ;*destbuffU = ReAllocateMemory(*destbuffU,msize,#PB_Memory_NoClear)
                If *destbuffU
                  destsize.i = CallCFunction(lib, "LZ4_decompress_safe" ,*srcbuff,*destbuffU,blobsize-4,10+32*32*800)
                EndIf
              EndIf
              
              file = ReadFile(#PB_Any,g_saveDir+g_LastWorld+"/"+Str(ChunkDID)+".chunks", #PB_File_SharedRead)
              If(file)
                blobsize.i = Lof(file)
                *srcbuff = ReAllocateMemory(*srcbuff,blobsize)
                ReadData(file, *srcbuff, blobsize)
                CloseFile(file)
                ;msize = PeekL(*srcbuff+blobsize-4)
                ;*destbuffD = ReAllocateMemory(*destbuffD,msize,#PB_Memory_NoClear)
                If *destbuffD
                  destsize.i = CallCFunction(lib, "LZ4_decompress_safe" ,*srcbuff,*destbuffD,blobsize-4,10+32*32*800)
                EndIf
              EndIf
            EndIf
            
          If(MemorySize(*destbuff) > $190000) ;Only look for custom blocks if the chunk was correctly loaded!
            NewMap customBlocks.xy(16)
            NewMap TorchRot.xy(16)
            varOffset = PeekL(*destbuff+4+32*32*800*2)
            For i=8+32*32*800*2 To 8+32*32*800*2+(varOffset*5)-1 Step 5
              TorchRot(Str(PeekA(*destbuff+ i))+","+Str(PeekA(*destbuff+ i+1))+","+Str(PeekW(*destbuff+ i+2)))\vis = PeekB(*destbuff+ i+4)
            Next
            varOffset = 8+32*32*800*2 + varOffset*5
            varOffset = varOffset + PeekL(*destbuff+ varoffset)*5+4
            LowestZ = PeekW(*destbuff+ varoffset)
            If(lowestZ > 0)
              lowestZ = LowestZ-1
            EndIf
            HighestZ = PeekW(*destbuff+ varoffset+2)
            varOffset = varoffset+8
            lightmapsize = PeekL(*destbuff+ varoffset)
            varoffset = varoffset + 4
            For i = 0 To lightmapsize-1
              varoffset = varoffset + 4
              varoffset = varoffset + PeekL(*destbuff+ varoffset)+4
              varoffset = varoffset + PeekL(*destbuff+ varoffset)*4+4
            Next
            For i=0 To 7
              If(PeekL(*destbuff+ varoffset) = 0 Or PeekL(*destbuff+ varoffset) = 1)
                varoffset = varoffset + 4
              Else
                varOffset = 0
                Break
              EndIf
            Next
            If(varOffset)
              varOffset = varOffset+5
              varOffset = varOffset + PeekL(*destbuff+varoffset)*8+4
              WorldFormat = PeekL(*destbuff+varoffset)
              If( WorldFormat < 51)
                varoffset = varoffset + 8
                varOffset = varOffset + PeekL(*destbuff+varoffset)*5+4
                If(PeekL(*destbuff+varoffset) = 1024)
                  varOffset = varOffset + PeekL(*destbuff+varoffset)*1+4
                  varOffset = varOffset + PeekL(*destbuff+varoffset)*4+4
                  CBlockLen = PeekL(*destbuff+varoffset)
                  varOffset = varOffset + 4
                  For i = varoffset To varoffset+(CBlockLen*8)-1 Step 8
                    customBlocks(Str(PeekA(*destbuff+ i))+","+Str(PeekA(*destbuff+ i+1))+","+Str(PeekW(*destbuff+ i+2)))\vis = PeekL(*destbuff+ i+4)
                  Next
                EndIf
              EndIf
            EndIf
          EndIf
          For i = 0 To 15
            ClearList(g_chunkArray(threadnum,i)\chunkmesh())
          Next
          For x=0 To 31
            For y = 0 To 31
              memy = y*32
              For z = LowestZ To HighestZ
                memz = z*32*32
                
                tmp = PeekA(*destbuff + 4 + x + memy + memz)
                bb = 0
                If tmp = 66
                  If FindMapElement(customBlocks(),Str(x)+","+Str(y)+","+Str(z))
                    cblock = customBlocks()\vis
                  EndIf
                ElseIf SBlockTypes(tmp) = #BLOCKTYPE_TORCH
                  If FindMapElement(TorchRot(),Str(x)+","+Str(y)+","+Str(z))
                    cblock = TorchRot()\vis
                    
                  EndIf
                EndIf
                If SBlockTypes(tmp) <> #BLOCKTYPE_VOID
                  If SBlockTypes(tmp) = #BLOCKTYPE_NORMAL
                    If(x<31)
                      nb = PeekA(*destbuff + 4 + x+1 + memy + memz)
                    Else
                      nb = PeekA(*destbuffR + 4 + 0 + memy + memz)
                    EndIf
                    If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL
                      bb = $08  
                    EndIf
                    If(x>0)
                      nb = PeekA(*destbuff + 4 + x-1 + memy + memz)
                    Else
                      nb = PeekA(*destbuffL + 4 + 31 + memy + memz)
                    EndIf
                    If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL
                      bb = bb | $04
                      
                    EndIf
                    If(y<31)
                      nb = PeekA(*destbuff + 4 + x + memy+32 + memz)
                    Else
                      nb = PeekA(*destbuffU + 4 + x + 0 + memz)
                    EndIf
                    
                    If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL
                      bb = bb | $10
                     
                    EndIf
                    If(y>0)
                      nb = PeekA(*destbuff + 4 + x + memy-32 + memz)
                    Else
                      nb = PeekA(*destbuffD + 4 + x + 31*32 + memz)
                    EndIf
                    
                    If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL
                      bb = bb | $20
                      
                    EndIf
                    If(z<HighestZ)
                      nb = PeekA(*destbuff + 4 + x + memy + memz+(32*32))
                      If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL
                        bb = bb | $01
                        
                      EndIf
                    Else
                      bb = bb | $01
         
                    EndIf
                   
                    If(z>LowestZ)
                      nb = PeekA(*destbuff + 4 + x + memy + memz-(32*32))
                      If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL
                        bb = bb | $02
           
                      EndIf
                    Else
                      bb = bb | $02
                    EndIf
                    If(bb)
                      AddElement(g_chunkArray(threadnum,z/75)\chunkmesh())
                      g_chunkArray(threadnum,z/75)\chunkmesh()\x = x
                      g_chunkArray(threadnum,z/75)\chunkmesh()\y = y
                      g_chunkArray(threadnum,z/75)\chunkmesh()\z = z
                      g_chunkArray(threadnum,z/75)\chunkmesh()\id = tmp
                      g_chunkArray(threadnum,z/75)\chunkmesh()\bb = bb
                      g_chunkArray(threadnum,z/75)\chunkmesh()\cblock = cblock
                    EndIf
                  ElseIf SBlockTypes(tmp) = #BLOCKTYPE_BILLBOARD
                    AddElement(g_chunkArray(threadnum,z/75)\chunkmesh())
                    g_chunkArray(threadnum,z/75)\chunkmesh()\x = x
                    g_chunkArray(threadnum,z/75)\chunkmesh()\y = y
                    g_chunkArray(threadnum,z/75)\chunkmesh()\z = z
                    g_chunkArray(threadnum,z/75)\chunkmesh()\id = tmp
                    g_chunkArray(threadnum,z/75)\chunkmesh()\bb = $80
                    g_chunkArray(threadnum,z/75)\chunkmesh()\cblock = cblock
                  Else    ;alpha blocks
                    If(x<31)
                      nb = PeekA(*destbuff + 4 + x+1 + memy + memz)
                    Else
                      nb = PeekA(*destbuffR + 4 + 0 + memy + memz)
                    EndIf
                    If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL And SBlockTypes(nb) <> #BLOCKTYPE_ALPHA
                      bb = $08  
                    EndIf
                    If(x>0)
                      nb = PeekA(*destbuff + 4 + x-1 + memy + memz)
                    Else
                      nb = PeekA(*destbuffL + 4 + 31 + memy + memz)
                    EndIf
                    If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL And SBlockTypes(nb) <> #BLOCKTYPE_ALPHA
                      bb = bb | $04
                      
                    EndIf
                    If(y<31)
                      nb = PeekA(*destbuff + 4 + x + memy+32 + memz)
                    Else
                      nb = PeekA(*destbuffU + 4 + x + 0 + memz)
                    EndIf
                    
                    If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL And SBlockTypes(nb) <> #BLOCKTYPE_ALPHA
                      bb = bb | $10
                     
                    EndIf
                    If(y>0)
                      nb = PeekA(*destbuff + 4 + x + memy-32 + memz)
                    Else
                      nb = PeekA(*destbuffD + 4 + x + 31*32 + memz)
                    EndIf
                    
                    If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL And SBlockTypes(nb) <> #BLOCKTYPE_ALPHA
                      bb = bb | $20
                      
                    EndIf
                    If(z<HighestZ)
                      nb = PeekA(*destbuff + 4 + x + memy + memz+(32*32))
                      If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL And SBlockTypes(nb) <> #BLOCKTYPE_ALPHA
                        bb = bb | $01
                        
                      EndIf
                    Else
                      bb = bb | $01
         
                    EndIf
                   
                    If(z>LowestZ)
                      nb = PeekA(*destbuff + 4 + x + memy + memz-(32*32))
                      If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL And SBlockTypes(nb) <> #BLOCKTYPE_ALPHA
                        bb = bb | $02
           
                      EndIf
                    Else
                      bb = bb | $02
                    EndIf
                    If bb
                      AddElement(g_chunkArray(threadnum,z/75)\chunkmesh())
                      g_chunkArray(threadnum,z/75)\chunkmesh()\x = x
                      g_chunkArray(threadnum,z/75)\chunkmesh()\y = y
                      g_chunkArray(threadnum,z/75)\chunkmesh()\z = z
                      g_chunkArray(threadnum,z/75)\chunkmesh()\id = tmp
                      g_chunkArray(threadnum,z/75)\chunkmesh()\bb = bb
                      g_chunkArray(threadnum,z/75)\chunkmesh()\cblock = cblock
                    EndIf
                    
                  EndIf
                EndIf
              Next
            Next
          Next
          While(Not TryLockMutex(Mutex) And Not g_exit)
          Wend
          If Not g_exit
            For i = 0 To 11
              SortStructuredList(g_chunkArray(threadnum,i)\chunkmesh(), #PB_Sort_Ascending, OffsetOf(Block\cblock), TypeOf(Block\cblock))
              SortStructuredList(g_chunkArray(threadnum,i)\chunkmesh(), #PB_Sort_Ascending, OffsetOf(Block\id), TypeOf(Block\id))
              ResetList(g_chunkArray(threadnum,i)\chunkmesh())
            Next
            g_chunk0ToRender(threadnum) = 1
            UnlockMutex(Mutex)
          EndIf
          FreeMemory(*destbuff)
          FreeMemory(*destbuffL)
          FreeMemory(*destbuffR)
          FreeMemory(*destbuffU)
          FreeMemory(*destbuffD)
          FreeMemory(*srcbuff)
          FreeMap(customBlocks())
          FreeMap(TorchRot())
        EndIf
    EndIf
  Until g_exit
  g_chunk0ToRender(threadnum) = 0
  CloseLibrary(lib)
  If(db)
    CloseDatabase(db)
  EndIf
Else
  MessageRequester("Error", "LZ4 couldn't be opened")
EndIf
EndProcedure

Procedure farchunks(unused)
  Shared DelMutex
  Shared Mutex
  Shared DrawMutex
  Repeat
    If TryLockMutex(DelMutex)
      tmp = g_deleteChunk
      If(tmp = -1)
        ResetMap(visibleChunks())
        While NextMapElement(visibleChunks())
          If (Sqr(Pow(Abs(visibleChunks()\x-CameraX(0)),2)+Pow(Abs(visibleChunks()\y-CameraZ(0)),2)) > Sqr(g_viewdistance * 2*16*16)-g_viewdistance/4)
            nodel = 0
            If nodel = 0
              g_deleteChunk = visibleChunks()\vis
              DeleteMapElement(visibleChunks())
            EndIf 
            Break
          EndIf
        Wend
      EndIf
      UnlockMutex(DelMutex)
    EndIf
    
  Delay(10)  
  ForEver
  
EndProcedure

Procedure StopChunkloading()
  SavePrefs()
  g_exit = 1
  running = 1
  start.q = ElapsedMilliseconds()
  While running And ElapsedMilliseconds() - start < 5000
    running = 0
    For i = 0 To #numthreads-1
      If IsThread(thread(i+1))
        running = 1
      Else
        Break
      EndIf
    Next
    Delay(10)
  Wend
  For i= 0 To #numthreads-1 ;kill any leftover threads
    If IsThread(thread(i+1))        
      KillThread(thread(i+1))
    EndIf
  Next
  g_exit = 0
EndProcedure

Procedure StartChunkloading()
  For i= 0 To #numthreads-1
     thread(i+1) = CreateThread(@DiscriminateChunk(),i)
  Next
EndProcedure

Procedure RebuildWorld()
  LockMutex(DelMutex)
  ResetMap(visibleChunks())
  While NextMapElement(visibleChunks())
    deleteChunk(visibleChunks()\vis)
    DeleteMapElement(visibleChunks())
  Wend
  For i = 0 To #numthreads-1
    g_chunk0ToRender(i) = 0
     For i = 0 To 15
        ClearList(g_chunkArray(threadnum,i)\chunkmesh())
      Next
    Next
  FreeStaticGeometry(#PB_All) 
  UnlockMutex(DelMutex)
EndProcedure
; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 91
; FirstLine = 51
; Folding = --
; EnableXP