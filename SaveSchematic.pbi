Procedure getChunk(*ret.xy,x.f,y.f)
  *ret.xy\x = Round(x/16,#PB_Round_Nearest)*16 - 8
  *ret.xy\y = Round(y/16,#PB_Round_Nearest)*16 - 8
  If(y - *ret.xy\y > 15.5)
    *ret.xy\y = *ret.xy\y + 16
  EndIf
  If(x - *ret.xy\x > 15.5)
    *ret.xy\x = *ret.xy\x + 16
  EndIf
  LockMutex(Mutex)
  If(FindMapElement(chunks(), Str(*ret.xy\x)+","+Str(*ret.xy\y)))
    *ret.xy\vis = chunks()\id
  Else
    *ret.xy\vis = -1
  EndIf
  UnlockMutex(Mutex)
EndProcedure



Procedure GetSingleBlockID(*ret.CBlocks,x.f,z.f,y.f)
  Static Dim SavechunkArray(32*32*800 - 1)
  Static loadedChunk = -1
  Static NewMap customBlocks.xy(16)
  Static NewMap TorchRot.xy(16)
  chunk.xy      
  getChunk(@chunk,x,y)
  
  If(chunk\vis <> loadedChunk And chunk\vis > -1) ;NEED TO LOAD NEW CHUNKDATA
    *chunkmem = AllocateMemory(32*32*800*2,#PB_Memory_NoClear)
    FillMemory(*chunkmem,32*32*800,#BLOCK_AIR)
    *srcbuff = AllocateMemory(100)
    destsize = 0
    lib = OpenLibrary(#PB_Any, ".\lz4.dll")
    If lib
      loadedChunk = chunk\vis
      db = OpenDatabase(#PB_Any, g_saveDir+g_LastWorld+"/"+"chunkdata.sqlite", "", "",#PB_Database_SQLite)
      If(db)  ;TRY DB FIRST
        If DatabaseQuery(db,"SELECT data FROM CHUNKDATA WHERE chunkid = "+Str(chunk\vis))
          If(NextDatabaseRow(db))
            blobsize.i = DatabaseColumnSize(db, 0)
            *srcbuff = ReAllocateMemory(*srcbuff,blobsize)
            GetDatabaseBlob(db, 0, *srcbuff, blobsize)
            msize = PeekL(*srcbuff+blobsize-4)
            *chunkmem = ReAllocateMemory(*chunkmem,msize,#PB_Memory_NoClear)
            If *chunkmem
              destsize.i = CallCFunction(lib, "LZ4_decompress_safe" ,*srcbuff,*chunkmem,blobsize-4,msize)
              EndIf
          EndIf
        EndIf
        If(destsize = 0)
          file = ReadFile(#PB_Any,g_saveDir+g_LastWorld+"/"+Str(chunk\vis)+".chunks", #PB_File_SharedRead)
          If(file)
            blobsize.i = Lof(file)
            *srcbuff = ReAllocateMemory(*srcbuff,blobsize)
            ReadData(file, *srcbuff, blobsize)
            CloseFile(file)
            msize = PeekL(*srcbuff+blobsize-4)
            *chunkmem = ReAllocateMemory(*chunkmem,msize,#PB_Memory_NoClear)
            If *chunkmem
              destsize.i = CallCFunction(lib, "LZ4_decompress_safe" ,*srcbuff,*chunkmem,blobsize-4,msize)
            EndIf
            
          EndIf
        EndIf
        CloseDatabase(db)
       Else ;NO DB PRESENT
        file = ReadFile(#PB_Any,g_saveDir+g_LastWorld+"/"+Str(chunk\vis)+".chunks", #PB_File_SharedRead)
        If(file)
          blobsize.i = Lof(file)
          *srcbuff = ReAllocateMemory(*srcbuff,blobsize)
          ReadData(file, *srcbuff, blobsize)
          CloseFile(file)
          msize = PeekL(*srcbuff+blobsize-4)
          *chunkmem = ReAllocateMemory(*chunkmem,msize,#PB_Memory_NoClear)
          If *chunkmem
            destsize.i = CallCFunction(lib, "LZ4_decompress_safe" ,*srcbuff,*chunkmem,blobsize-4,msize)
          EndIf
          
        EndIf
      EndIf
      CloseLibrary(lib)
    Else
      MessageRequester("Error","An error occured caching chunk to extract blockdata: lz4.dll could not be loaded!")
    EndIf ;NEW CHUNKDATA LOADED
    If(MemorySize(*chunkmem) > $190000) ;Only look for custom blocks if the chunk was correctly loaded!
      ClearMap(customBlocks())
      ClearMap(TorchRot())
      varOffset = PeekL(*chunkmem+4+32*32*800*2)
      For i=8+32*32*800*2 To 8+32*32*800*2+(varOffset*5)-1 Step 5
        TorchRot(Str(PeekA(*chunkmem+ i))+","+Str(PeekA(*chunkmem+ i+1))+","+Str(PeekW(*chunkmem+ i+2)))\vis = PeekB(*chunkmem+ i+4)
      Next
      varOffset = 4+32*32*800*2 + varOffset*5+4
      varOffset = varOffset + PeekL(*chunkmem+ varoffset)*5+4
      varOffset = varoffset+8
      lightmapsize = PeekL(*chunkmem+ varoffset)
      varoffset = varoffset + 4
      For i = 0 To lightmapsize-1
        varoffset = varoffset + 4
        varoffset = varoffset + PeekL(*chunkmem+ varoffset)+4
        varoffset = varoffset + PeekL(*chunkmem+ varoffset)*4+4
      Next
      For i=0 To 7
        If(PeekL(*chunkmem+ varoffset) = 0 Or PeekL(*chunkmem+ varoffset) = 1)
          varoffset = varoffset + 4
        Else
          varOffset = 0
          Break
        EndIf
      Next
      If(varOffset)
        varOffset = varOffset+5
        varOffset = varOffset + PeekL(*chunkmem+varoffset)*8+4
        WorldFormat = PeekL(*chunkmem+varoffset)
        If( WorldFormat < 51)
          varoffset = varoffset + 8
          varOffset = varOffset + PeekL(*chunkmem+varoffset)*5+4
          If(PeekL(*chunkmem+varoffset) = 1024)
            varOffset = varOffset + PeekL(*chunkmem+varoffset)*1+4
            varOffset = varOffset + PeekL(*chunkmem+varoffset)*4+4
            CBlockLen = PeekL(*chunkmem+varoffset)
            varOffset = varOffset + 4
            For i = varoffset To varoffset+(CBlockLen*8)-1 Step 8
              customBlocks(Str(PeekA(*chunkmem+ i))+","+Str(PeekA(*chunkmem+ i+1))+","+Str(PeekW(*chunkmem+ i+2)))\vis = PeekL(*chunkmem+ i+4)
            Next
          EndIf
        EndIf
      EndIf
    EndIf

    For ix = 0 To 31
      For iy = 0 To 31
        For iz = 0 To 799
          SavechunkArray(ix+iy*32+iz*32*32) = PeekB(*chunkmem + 4 + ix + iy*32 + iz*32*32)
        Next
      Next
    Next
    FreeMemory(*srcbuff)
    FreeMemory(*chunkmem)
  ElseIf chunk\vis = -1
    FillMemory(*chunkmem,32*32*800,#BLOCK_AIR)
  EndIf
  bx = (x-chunk\x)*2
  by = (y-chunk\y)*2*32
  bz = z*2*32*32
  tmp = SavechunkArray(bx + by + bz)
  If(tmp = 66)
    If(FindMapElement(customBlocks(),Str(bx)+","+Str((y-chunk\y)*2)+","+Str(z*2)))
      *ret\id = customBlocks()\vis
    EndIf
  ElseIf(SBlocks(tmp)\type = #BLOCKTYPE_Torch)
    If(FindMapElement(TorchRot(),Str(bx)+","+Str((y-chunk\y)*2)+","+Str(z*2)))
      *ret\id = TorchRot()\vis
    EndIf
  EndIf
  
  ProcedureReturn tmp
EndProcedure


Procedure SaveCyubeAreaToFile(x.f,z.f,y.f,sx,sz,sy)
  startX.f = x-(sx-1)/4  ;Get the edge coordinate instead of the center
  startY.f = y-(sy-1)/4
  startZ.f = z-(sz-1)/4
  filename.s = SaveFileRequester("Choose a File to save to","","Cyube Schematic | *.CySch",0)
  If filename = ""
    ProcedureReturn 0
  EndIf
  If(GetExtensionPart(filename) <> "cySch")
    filename = filename + ".cySch"
  EndIf
  
  areasize = sx*sy*sz
  file = CreateFile(#PB_Any,filename,#PB_Ascii)
  If Not file
    ProcedureReturn 0
  EndIf

  progressWindow = OpenWindow(#PB_Any,0,0,400,200,"Saving Cyube Schematic...",#PB_Window_ScreenCentered)
  progress = ProgressBarGadget(#PB_Any,10,10,380,15,0,100,#PB_ProgressBar_Smooth)
  progressText = TextGadget(#PB_Any,10,30,380,50,"Saving cube...")
  StickyWindow(progressWindow, #True) 
  WriteLong(file,  sx)
  WriteLong(file,  sy)
  WriteLong(file,  sz)
  WriteLong(file,  $13371337)
  NewList customBlocks.block()
  NewList torchRot.block()
  NewMap affectedChunks.xy()
  thischunnk.xy
  For blockx = 0 To sx
    For blocky = 0 To sy
      cbx.f = blockx
      cbx = cbx/2
      cby.f = blocky
      cby = cby/2
      getChunk(@thischunnk,cbx+startX,cby+startY)
      affectedChunks(Str(thischunnk\vis))\vis = thischunnk\vis
      affectedChunks()\x = thischunnk\x
      affectedChunks()\y = thischunnk\y
    Next
  Next
  *schMem = AllocateMemory(sx*sy*sz)
  If Not *schMem
    MessageRequester("Out of memory","Sorry, not enough free memory available to save this map portion, try to lower the viewdistance, or reduce schematic size.")
    FreeMap(affectedChunks())
    FreeList(customBlocks.block())
    FreeList(torchRot.block())
    CloseFile(file)
    DeleteFile(filename)
    ProcedureReturn 0
  EndIf
  endX.f = x + (sx-1)/4
  endY.f = y + (sy-1)/4
  endZ.f = z + (sz-1)/4
  custom.CBlocks
  ResetMap(affectedChunks())
  done = 0
  While(NextMapElement(affectedChunks()))
    If(affectedChunks()\x < startX)
      lsX.f = startX
    Else
      lsX.f = affectedChunks()\x
    EndIf
    If(affectedChunks()\y < startY)
      lsY.f = startY
    Else
      lsY.f = affectedChunks()\y
    EndIf
    If(affectedChunks()\x + 15.5 > endX)
      leX.f = endX
    Else
      leX.f = affectedChunks()\x + 15.5
    EndIf
    If(affectedChunks()\y + 15.5 > endY)
      leY.f = endY
    Else
      leY.f = affectedChunks()\y + 15.5
    EndIf
    px.f=lsx - startX
    While px <= lex - startX
      py.f=lsy - startY
      While py <= leY - startY
        pz.f= 0
        While pz <= endZ - startZ
          mx = px*2
          my = py*2
          my = my * sx
          mz = pz*2
          mz = mz * sx * sy
          bx.f = px + startX
          by.f = py + startY
          bz.f = pz + startZ
          id= GetSingleBlockID(@custom,bx,bz,by)
          PokeB(*schMem +mx+my+mz,id)
          If id = 66
            AddElement(customBlocks())
            customBlocks()\cblock = custom\id
            customBlocks()\x = px*2
            customBlocks()\y = py*2
            customBlocks()\z = pz*2
          ElseIf SBlocks(id)\type = #BLOCKTYPE_Torch
            AddElement(torchRot())
            torchRot()\cblock = custom\id
            torchRot()\x = px*2
            torchRot()\y = py*2
            torchRot()\z = pz*2
          EndIf
          done = done+1
          If(ElapsedMilliseconds()-lastU.q > 500)
            lastU = ElapsedMilliseconds()
            prcnt = ((done)*100)/areasize
            SetGadgetState(progress,prcnt)
            progressText = TextGadget(#PB_Any,10,30,380,50,"Saving cube..."+Str(prcnt)+"%")
            WindowEvent()
          EndIf
          pz = pz + 0.5
        Wend
        py = py + 0.5
      Wend
      px = px + 0.5
    Wend
  Wend  ;nextChunk
  *schMem2 = ReAllocateMemory(*schMem,MemorySize(*schMem)+ListSize(customBlocks())*10+4+ListSize(torchRot())*7+4)
  If Not *schMem2
    FreeMemory(*schMem)
    FreeMap(affectedChunks())
    FreeList(customBlocks.block())
    FreeList(torchRot.block())
    CloseFile(file)
    MessageRequester("Out of memory","Sorry, not enough free memory available to save this map portion, try to lower the viewdistance, or reduce schematic size.")
    DeleteFile(filename)
    ProcedureReturn 0
  Else
    *schMem = *schMem2
  EndIf
  memoffs = sx*sy*sz
  If(ListSize(customBlocks()))
    PokeL(*schMem+memoffs,ListSize(customBlocks()))
    memoffs+4
    ResetList(customBlocks())
    While(NextElement(customBlocks()))
      PokeW(*schMem+memoffs,customBlocks()\x)
      memoffs+2
      PokeW(*schMem+memoffs,customBlocks()\y)
      memoffs+2
      PokeW(*schMem+memoffs,customBlocks()\z)
      memoffs+2
      PokeL(*schMem+memoffs,customBlocks()\cblock)
      memoffs+4
    Wend
  Else
    PokeL(*schMem+memoffs,0)
    memoffs+4
  EndIf
  If(ListSize(torchRot()))
    PokeL(*schMem+memoffs,ListSize(torchRot()))
    memoffs+4
    ResetList(torchRot())
    While(NextElement(torchRot()))
      PokeW(*schMem+memoffs,torchRot()\x)
      memoffs+2
      PokeW(*schMem+memoffs,torchRot()\y)
      memoffs+2
      PokeW(*schMem+memoffs,torchRot()\z)
      memoffs+2
      PokeB(*schMem+memoffs,torchRot()\cblock)
      memoffs+1
    Wend
  Else
    PokeL(*schMem+memoffs,0)
    memoffs+4
  EndIf
  lib = OpenLibrary(#PB_Any, ".\lz4.dll")
  If lib
    *dstbuff = AllocateMemory(50000000)
    If Not *dstbuff
      MessageRequester("Out of memory","Sorry, not enough free memory available to save this map portion, try to lower the viewdistance, or reduce schematic size.")
    Else  
      destsize.i = CallCFunction(lib, "LZ4_compress_default" ,*schMem,*dstbuff,MemorySize(*schMem),MemorySize(*dstbuff))
      WriteData(file,*dstbuff,destsize)
      FreeMemory(*dstbuff)
    EndIf
    
    CloseLibrary(lib)
  Else
    MessageRequester("Error","Lz4.dll not found, or not accessible. This file should have been shipped with the tool, try to re-download.")
  EndIf
  WriteLong(file,MemorySize(*schMem))
  CloseFile(file)
  FreeMemory(*schMem)
  FreeMap(affectedChunks())
  FreeList(customBlocks.block())
  FreeList(torchRot.block())
  CloseWindow(progressWindow)
  ProcedureReturn 1

EndProcedure

; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 247
; FirstLine = 217
; Folding = -
; EnableXP