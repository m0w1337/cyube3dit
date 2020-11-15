Global *chunkmem = AllocateMemory(32*32*800*2,#PB_Memory_NoClear)


Procedure ChangeSingleBlockID(id,cid,x.f,z.f,y.f)
  Shared *chunkmem
  Static loadedChunk = -1
  Static chunkToSave = 0
  Static cBlockOffset = 0
  Static tRotOffset = 0
  Static cBlockLen = 0
  Static tRotLen = 0
  Static LowestZ = 0
  Static HighestZ = 0
  Static NewMap customBlocks.block(64)
  Static NewMap TorchRot.block(64)
  chunk.xy      
  getChunk(@chunk,x,y)

  If(chunk\vis <> loadedChunk Or (id = 0 And cid = 0 And x = 0 And y = 0 And z = 0)) ;NEED TO LOAD NEW CHUNKDATA OR FINISH LAST CHANGES
    lib = OpenLibrary(#PB_Any, ".\lz4.dll")
    If lib
      If(chunkToSave)
        If(MapSize(customBlocks()) > cBlockLen)
          *chunkmem = ReAllocateMemory(*chunkmem,MemorySize(*chunkmem)+(MapSize(customBlocks())-cBlockLen)*8)
          MoveMemory(*chunkmem+cBlockOffset, *chunkmem+cBlockOffset+(MapSize(customBlocks())-cBlockLen)*8, MemorySize(*chunkmem) - ((MapSize(customBlocks())- cBlockLen)*8 + cBlockOffset))
        ElseIf(MapSize(customBlocks()) < cBlockLen)
          MoveMemory(*chunkmem+cBlockOffset + cBlockLen*8 + 4, *chunkmem + cBlockOffset + cBlockLen*8 + 4 - (cBlockLen - MapSize(customBlocks()))*8, MemorySize(*chunkmem) - (cBlockOffset + cBlockLen*8 + 4))
          *chunkmem = ReAllocateMemory(*chunkmem,MemorySize(*chunkmem)-(cBlockLen - MapSize(customBlocks()))*8)
        EndIf
        PokeL(*chunkmem+cBlockOffset,MapSize(customBlocks()))
        ResetMap(customBlocks())
        elm = 0
        While(NextMapElement(customBlocks()))
          PokeA(*chunkmem+cBlockOffset+4+elm,customBlocks()\x)
          PokeA(*chunkmem+cBlockOffset+4+elm+1,customBlocks()\y)
          PokeW(*chunkmem+cBlockOffset+4+elm+2,customBlocks()\z)
          PokeL(*chunkmem+cBlockOffset+4+elm+4,customBlocks()\cblock)
          elm=elm+8
        Wend
        
        If(MapSize(TorchRot()) > tRotLen)
          *chunkmem = ReAllocateMemory(*chunkmem,MemorySize(*chunkmem)+(MapSize(TorchRot())-tRotLen)*5)
          MoveMemory(*chunkmem+tRotOffset, *chunkmem+tRotOffset+(MapSize(TorchRot())-tRotLen)*5, MemorySize(*chunkmem) - ((MapSize(TorchRot())-tRotLen)*5 + tRotOffset))
        ElseIf(MapSize(TorchRot()) < tRotLen)
          MoveMemory(*chunkmem+tRotOffset + tRotLen*5 + 4, *chunkmem + tRotOffset + tRotLen*5 + 4 - (tRotLen - MapSize(TorchRot()))*5, MemorySize(*chunkmem) - (tRotOffset + tRotLen*5 + 4))
          *chunkmem = ReAllocateMemory(*chunkmem,MemorySize(*chunkmem)-(tRotLen - MapSize(TorchRot()))*5)
        EndIf
        PokeL(*chunkmem+tRotOffset,MapSize(TorchRot()))
        ResetMap(TorchRot())
        elm = 0
        While(NextMapElement(TorchRot()))
          PokeA(*chunkmem+tRotOffset+4+elm,TorchRot()\x)
          PokeA(*chunkmem+tRotOffset+4+elm+1,TorchRot()\y)
          PokeW(*chunkmem+tRotOffset+4+elm+2,TorchRot()\z)
          PokeA(*chunkmem+tRotOffset+4+elm+4,TorchRot()\cblock)
          elm=elm+5
        Wend
        limitOffset = tRotOffset + 4 + elm
        limitOffset = limitOffset + PeekL(*chunkmem+limitOffset) * 5 + 4
        PokeW(*chunkmem+limitOffset,LowestZ)
        PokeW(*chunkmem+limitOffset+2,HighestZ)
          *dstbuff = AllocateMemory(300000)
          destsize.i = CallCFunction(lib, "LZ4_compress_default" ,*chunkmem,*dstbuff,MemorySize(*chunkmem),MemorySize(*dstbuff))
          PokeL(*dstbuff+destsize,MemorySize(*chunkmem))
          If(destsize)
            db = OpenDatabase(#PB_Any, g_saveDir+g_LastWorld+"/"+"chunkdata.sqlite", "", "",#PB_Database_SQLite)
            done = 0
            If(db)  ;TRY DB FIRST
              If DatabaseQuery(db,"SELECT data FROM CHUNKDATA WHERE chunkid = "+Str(loadedChunk))
                If(NextDatabaseRow(db))
                  ;FOR TESTING
;                           blobsize.i = DatabaseColumnSize(db, 0)
;                           *srcbuff = AllocateMemory(blobsize)
;                           GetDatabaseBlob(db, 0, *srcbuff, blobsize)
;                           msize = PeekL(*srcbuff+blobsize-4)
;                           *tstmem = AllocateMemory(msize,#PB_Memory_NoClear)
;                           If *tstmem
;                             tstsize.i = CallCFunction(lib, "LZ4_decompress_safe" ,*srcbuff,*tstmem,blobsize-4,msize)
;                           EndIf
;                           file = CreateFile(#PB_Any,"C:\Users\m0\Desktop\before.bin")
;                           If(file)
;                             WriteData(file,*tstmem,tstsize)
;                             CloseFile(file)
;                           EndIf
;                           FreeMemory(*srcbuff)
;                           FreeMemory(*tstmem)
                  SetDatabaseBlob(db, 0, *dstbuff, destsize+4)
                  DatabaseUpdate(db, "UPDATE CHUNKDATA SET data=? WHERE chunkid = "+Str(loadedChunk)+";")
                  
                 ;FOR TESTING
;                           msize = PeekL(*dstbuff+destsize)
;                           *tstmem = AllocateMemory(msize,#PB_Memory_NoClear)
;                           If *tstmem
;                             tstsize.i = CallCFunction(lib, "LZ4_decompress_safe" ,*dstbuff,*tstmem,destsize,msize)
;                           EndIf
;                           file = CreateFile(#PB_Any,"C:\Users\m0\Desktop\after.bin")
;                           If(file)
;                             WriteData(file,*tstmem,msize)
;                             CloseFile(file)
;                           EndIf
;                           FreeMemory(*tstmem)
                  ;END TESTING
                  done = 1
                EndIf
                FinishDatabaseQuery(db)
              EndIf
              If(done = 0)
                file = OpenFile(#PB_Any,g_saveDir+g_LastWorld+"/"+Str(loadedChunk)+".chunks")
                If(file)
                  TruncateFile(file)
                  WriteData(file,*dstbuff,destsize+4)
                  CloseFile(file)
                EndIf
              EndIf
              CloseDatabase(db)
            Else ;NO DB PRESENT
              file = OpenFile(#PB_Any,g_saveDir+g_LastWorld+"/"+Str(loadedChunk)+".chunks")
              If(file)
                TruncateFile(file)
                WriteData(file,*dstbuff,destsize+4)
                CloseFile(file)
              EndIf
            EndIf
         EndIf
          FreeMemory(*dstbuff)
          chunkToSave = 0
          If(id = 0 And cid = 0 And x = 0 And y = 0 And z = 0)
            ProcedureReturn
          EndIf
          
      EndIf
     
      FillMemory(*chunkmem,32*32*800,#BLOCK_AIR)
      *srcbuff = AllocateMemory(100)
      destsize = 0
 
      loadedChunk = chunk\vis
      If loadedChunk > -1
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
              FinishDatabaseQuery(db)
          EndIf
          If(destsize = 0)
            file = ReadFile(#PB_Any,g_saveDir+g_LastWorld+"/"+Str(chunk\vis)+".chunks", #PB_File_SharedRead)
            If(file)
              blobsize.i = Lof(file)
              *srcbuff = ReAllocateMemory(*srcbuff,blobsize)
              ReadData(file, *srcbuff, blobsize)
              CloseFile(file)
              msize = PeekL(*srcbuff+blobsize-4)
              If msize
                *chunkmem = ReAllocateMemory(*chunkmem,msize,#PB_Memory_NoClear)
                If *chunkmem
                  destsize.i = CallCFunction(lib, "LZ4_decompress_safe" ,*srcbuff,*chunkmem,blobsize-4,msize)
                EndIf
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
      EndIf
    EndIf ;NEW CHUNKDATA LOADED
    FreeMemory(*srcbuff)      
    If(MemorySize(*chunkmem) > $190000) ;Only look for custom blocks if the chunk was correctly loaded!
      ClearMap(customBlocks())
      ClearMap(TorchRot())
      varOffset = PeekL(*chunkmem+4+32*32*800*2)
      tRotOffset = 4+32*32*800*2
      tRotLen = varOffset
      For i=8+32*32*800*2 To 8+32*32*800*2+(varOffset*5)-1 Step 5
        TorchRot(Str(PeekA(*chunkmem+ i))+","+Str(PeekA(*chunkmem+ i+1))+","+Str(PeekW(*chunkmem+ i+2)))\cblock = PeekB(*chunkmem+ i+4)
        TorchRot()\x = PeekA(*chunkmem+ i)
        TorchRot()\y = PeekA(*chunkmem+ i+1)
        TorchRot()\z = PeekW(*chunkmem+ i+2)
      Next
      varOffset = 8+32*32*800*2+(varOffset*5)
      varOffset = varOffset + PeekL(*chunkmem+ varoffset)*5+4
      LowestZ = PeekW(*chunkmem+ varoffset)
      HighestZ = PeekW(*chunkmem+ varoffset+2)
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
            cBlockOffset = varoffset
            varOffset = varOffset + 4
            For i = varoffset To varoffset+(CBlockLen*8)-1 Step 8
              customBlocks(Str(PeekA(*chunkmem+ i))+","+Str(PeekA(*chunkmem+ i+1))+","+Str(PeekW(*chunkmem+ i+2)))\cblock = PeekL(*chunkmem+ i+4)
              customBlocks()\x = PeekA(*chunkmem+ i)
              customBlocks()\y = PeekA(*chunkmem+ i+1)
              customBlocks()\z = PeekW(*chunkmem+ i+2)
            Next
          EndIf
        EndIf
      EndIf
    EndIf
    CloseLibrary(lib)
  EndIf
  bx = (x-chunk\x)*2
  by = (y-chunk\y)*2*32
  bz = z*2*32*32
  If(z*2 > HighestZ And id <> #BLOCK_AIR)
    HighestZ = z*2
  ElseIf z*2 < LowestZ And id = #BLOCK_AIR
    LowestZ = z*2
  EndIf
  If HighestZ > 799
    HighestZ = 799
  ElseIf HighestZ < 1
    HighestZ = 1
  EndIf
  If LowestZ < 1
    LowestZ = 0
  ElseIf LowestZ > 798
    LowestZ = 798
  EndIf
  If(highestZ < LowestZ)
    highestZ = lowestZ + 1
  EndIf
  
  
    
  ;If(SavechunkArray(bx+by+bz) = 0)
    If(PeekB(*chunkmem+4+bx+by+bz) = 66)
      If(FindMapElement(customBlocks(),Str(bx)+","+Str((y-chunk\y)*2)+","+Str(z*2)))
        If(id = 66)
          customBlocks()\cblock = cid
        Else
          DeleteMapElement(customBlocks(), Str(bx)+","+Str((y-chunk\y)*2)+","+Str(z*2))
        EndIf
      EndIf
    ElseIf id = 66
      customBlocks(Str(bx)+","+Str((y-chunk\y)*2)+","+Str(z*2))\cblock = cid
      customBlocks()\x = bx
      customBlocks()\y = (y-chunk\y)*2
      customBlocks()\z = z*2
    EndIf
    If(SBlocks(PeekB(*chunkmem+4+bx+by+bz))\type = #BLOCKTYPE_Torch)
      If(FindMapElement(TorchRot(),Str(bx)+","+Str((y-chunk\y)*2)+","+Str(z*2)))
        If(SBlocks(id)\type = #BLOCKTYPE_Torch)
          TorchRot()\cblock = cid
        Else
          DeleteMapElement(TorchRot(), Str(bx)+","+Str((y-chunk\y)*2)+","+Str(z*2))
        EndIf
      EndIf
    ElseIf SBlocks(id)\type = #BLOCKTYPE_Torch
      TorchRot(Str(bx)+","+Str((y-chunk\y)*2)+","+Str(z*2))\cblock = cid
      TorchRot()\x = bx
      TorchRot()\y = (y-chunk\y)*2
      TorchRot()\z = z*2
    EndIf
  PokeB(*chunkmem + 4 +bx + by + bz,id)
  chunkToSave = 1
  ;EndIf
EndProcedure

Procedure SaveModifiedChunk(x.f,z.f,y.f, rotation)
  Shared DelMutex, toolBox
  cySchFile.s = g_SchematicFile
  file = OpenFile(#PB_Any,cySchFile,#PB_File_SharedRead)
  If file
    OpenProgress(progH.pHnd,"World manipulation","Injecting the schematic into your world...")
    
    sx = toolBox\sx
    sy = toolBox\sz
    sz = toolBox\sy
    areasize = sx*sy*sz
    startX.f = x-(sx-1)/4  ;Get the edge coordinate instead of the center
    startY.f = y-(sy-1)/4
    startZ.f = z-(sz-1)/4
    endX.f = x + (sx-1)/4
    endY.f = y + (sy-1)/4
    endZ.f = z + (sz-1)/4
    toolBox\sx = ReadLong(file)
    toolBox\sz = ReadLong(file)
    toolBox\sy = ReadLong(file)

    
    FileSeek(file,Lof(file)-4)
     *destbuff = AllocateMemory(ReadLong(file))
    *srcbuff = AllocateMemory(Lof(file)-20)
    FileSeek(file,12)
    If(*destbuff And *srcbuff And ReadLong(file) = $13371337)
      lib = OpenLibrary(#PB_Any, ".\lz4.dll")
      If lib
        ReadData(file,*srcbuff,Lof(file)-20)
        destsize.i = CallCFunction(lib, "LZ4_decompress_safe" ,*srcbuff,*destbuff,MemorySize(*srcbuff),MemorySize(*destbuff))
        CloseLibrary(lib)
        numCblocks = 0
      If(destsize = MemorySize(*destbuff) And destsize > 0)
          memoffs = toolBox\sx * toolBox\sy * toolBox\sz
          numCblocks = PeekL(*destbuff+memoffs)
          memoffs+4
        Else
          MessageRequester("","Failed to unpack schematic file. Sorry, but this file is not useable.")
          FreeMemory(*destbuff)
          FreeMemory(*srcbuff)
          CloseFile(file)
          CloseWindow(progressWindow)
          ProcedureReturn 0
        EndIf
        NewMap customBlocks.xy(16)
        If(numCblocks)
          For i = 0 To numCblocks-1
            cx = PeekW(*destbuff+memoffs)
            memoffs+2
            cy = PeekW(*destbuff+memoffs)
            memoffs+2
            cz = PeekW(*destbuff+memoffs)
            memoffs+2
            customBlocks(Str(cx)+","+Str(cy)+","+Str(cz))\vis = PeekL(*destbuff+memoffs)
            memoffs+4
          Next
        EndIf
        numTorchRot = 0
        numTorchRot = PeekL(*destbuff+memoffs)
        memoffs+4
        NewMap torches.xy(16)
        If(numTorchRot)
          For i = 0 To numTorchRot-1
            cx = PeekW(*destbuff+memoffs)
            memoffs+2
            cy = PeekW(*destbuff+memoffs)
            memoffs+2
            cz = PeekW(*destbuff+memoffs)
            memoffs+2
            torches(Str(cx)+","+Str(cy)+","+Str(cz))\vis = PeekB(*destbuff+memoffs)
            memoffs+1
          Next
        EndIf
      If rotation
        UpdateProgress(progH,"Preparing data...",#PB_ProgressBar_Unknown)
        RotateSchematic(customBlocks(),torches(),*destbuff,rotation)
      EndIf
      
      NewMap affectedChunks.xy()
      thischunk.xy
      For blockx = 0 To sx
        For blocky = 0 To sy
          cbx.f = blockx
          cbx = cbx/2
          cby.f = blocky
          cby = cby/2
          getChunk(@thischunk,cbx+startX,cby+startY)
          If(thischunk\vis = -1)
            MessageRequester("Error","The insertion overlaps at least one not yet generated chunk, only generated chunnks can be manipulated!")
            If(*destbuff)
              FreeMemory(*destbuff)
            EndIf
            If *srcbuff
              FreeMemory(*srcbuff)
            EndIf
            CloseFile(file)
            CloseWindow(progressWindow)
            ProcedureReturn 0
          EndIf
          
          affectedChunks(Str(thischunk\vis))\vis = thischunk\vis
          affectedChunks()\x = thischunk\x
          affectedChunks()\y = thischunk\y
        Next
      Next
      
      
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
          While py <= ley - startY
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
               id = PeekB(*destbuff+mx+my+mz)
               If(id = 66)
                 If(FindMapElement(customBlocks(),Str(mx)+","+Str(py*2)+","+Str(pz*2)))
                   cid = customBlocks()\vis
                 Else
                   MessageRequester("Error","Cblock not found: Aboring")
                   Break 3
                 EndIf
               ElseIf(SBlocks(id)\type = #BLOCKTYPE_Torch)
                 If(FindMapElement(torches(),Str(mx)+","+Str(py*2)+","+Str(pz*2)))
                   cid = torches()\vis
                   Else
                     MessageRequester("Error","Torchrot not found: Aboring")
                     Break 3
                 EndIf
               Else
                 cid = 1
               EndIf
               ChangeSingleBlockID(id,cid,bx,bz,by)
               done = done+1
              If(ElapsedMilliseconds()-lastU.q > 500)
                lastU = ElapsedMilliseconds()
                prcnt = ((done)*100)/areasize
                UpdateProgress(progH,"Changing cubes..."+Str(prcnt)+"%",prcnt)
              EndIf
              pz = pz + 0.5
            Wend
            py = py + 0.5
          Wend
          px = px + 0.5
        Wend
        LockMutex(DelMutex)
        If(FindMapElement(visibleChunks(),Str(affectedChunks()\x)+","+Str(affectedChunks()\y)))
          deleteChunk(affectedChunks()\vis)
          DeleteMapElement(visibleChunks())
        EndIf
        UnlockMutex(DelMutex)
      Wend  ;nextChunk
      
      ChangeSingleBlockID(0,0,0,0,0) ;Flush last modified chunk to DB/file
      Else
        MessageRequester("Error","Lz4.dll not found, or not accessible. This file should have been shipped with the tool, try to re-download.")
      EndIf
      FreeMemory(*destbuff)
      FreeMemory(*srcbuff)
      DeleteFile(g_instaLoadDir+g_LastWorld+"/"+"chunkmeshes.sqlite")
    Else
      MessageRequester("Error","There is not enough memory available to ofen this schematic. Try unloading some chunks and closing applications to make some space.")
      If(*destbuff)
        FreeMemory(*destbuff)
      EndIf
      If *srcbuff
        FreeMemory(*srcbuff)
      EndIf
    EndIf
      ;Add the neighbour chunks To be deleted fron the instaload table
;       NewMap NeighbourChunks.xy()
;       ResetMap(affectedChunks())
;       While(NextMapElement(affectedChunks()))
;         getChunk(@thischunk,affectedChunks()\x +32,affectedChunks()\y)
;         NeighbourChunks(Str(thischunk\vis))\vis = thischunk\vis
;         getChunk(@thischunk,affectedChunks()\x -32,affectedChunks()\y)
;         NeighbourChunks(Str(thischunk\vis))\vis = thischunk\vis
;         getChunk(@thischunk,affectedChunks()\x,affectedChunks()\y + 32)
;         NeighbourChunks(Str(thischunk\vis))\vis = thischunk\vis
;         getChunk(@thischunk,affectedChunks()\x,affectedChunks()\y - 32)
;         NeighbourChunks(Str(thischunk\vis))\vis = thischunk\vis
;         getChunk(@thischunk,affectedChunks()\x +32,affectedChunks()\y + 32)
;         NeighbourChunks(Str(thischunk\vis))\vis = thischunk\vis
;         getChunk(@thischunk,affectedChunks()\x -32,affectedChunks()\y - 32)
;         NeighbourChunks(Str(thischunk\vis))\vis = thischunk\vis
;         getChunk(@thischunk,affectedChunks()\x - 32,affectedChunks()\y + 32)
;         NeighbourChunks(Str(thischunk\vis))\vis = thischunk\vis
;         getChunk(@thischunk,affectedChunks()\x + 32,affectedChunks()\y - 32)
;         NeighbourChunks(Str(thischunk\vis))\vis = thischunk\vis
;       Wend
;       FreeMap(affectedChunks())
;       ResetMap(NeighbourChunks())
;       db = OpenDatabase(#PB_Any, g_instaLoadDir+g_LastWorld+"/"+"chunkmeshes.sqlite", "", "",#PB_Database_SQLite)
;       If(db)
;         While(NextMapElement(NeighbourChunks()))
;           CheckDatabaseUpdate(db,"DELETE FROM chunkdata WHERE chunkid = "+Str(NeighbourChunks()\vis))
;         Wend
;         CloseDatabase(db)
;       EndIf
;       FreeMap(NeighbourChunks())
    CloseFile(file)
    closeProgress(progH)
  EndIf
  ProcedureReturn 1
EndProcedure
; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 337
; FirstLine = 333
; Folding = -
; EnableXP