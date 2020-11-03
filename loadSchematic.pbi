#GEO = 9999

Procedure CYSchematicGetSize(*size.box,filename.s)
  file = OpenFile(#PB_Any,filename,#PB_File_SharedRead)
  If file
    *size\sx = ReadLong(file)
    *size\sz = ReadLong(file)
    *size\sy = ReadLong(file)
    CloseFile(file)
  EndIf  
EndProcedure

Procedure.l displayCYSchematic(filename.s,List schBlocks.block(), rotation)
  Shared Mutex
  ret = 0
  file = OpenFile(#PB_Any,filename,#PB_File_SharedRead)
  progressWindow = OpenWindow(#PB_Any,0,0,400,100,"Loading Cyube Schematic...",#PB_Window_ScreenCentered)
  progress = ProgressBarGadget(#PB_Any,10,10,380,15,0,100,#PB_ProgressBar_Smooth)
  progressText = TextGadget(#PB_Any,10,30,380,50,"Optimizing blocks...")
  While WindowEvent()
  Wend
  If file
    sx = ReadLong(file)
    sy = ReadLong(file)
    sz = ReadLong(file)
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
          memoffs = sx*sy*sz
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
            x = PeekW(*destbuff+memoffs)
            memoffs+2
            y = PeekW(*destbuff+memoffs)
            memoffs+2
            z = PeekW(*destbuff+memoffs)
            memoffs+2
            customBlocks(Str(x)+","+Str(y)+","+Str(z))\vis = PeekL(*destbuff+memoffs)
            memoffs+4
          Next
        EndIf
        numTorchRot = 0
        numTorchRot = PeekL(*destbuff+memoffs)
        memoffs+4
        If(numTorchRot)
          For i = 0 To numTorchRot-1
            x = PeekW(*destbuff+memoffs)
            memoffs+2
            y = PeekW(*destbuff+memoffs)
            memoffs+2
            z = PeekW(*destbuff+memoffs)
            memoffs+2
            customBlocks(Str(x)+","+Str(y)+","+Str(z))\vis = PeekB(*destbuff+memoffs)
            memoffs+1
          Next
        EndIf
;         If rotation
;           Dim dest(sx*sy)
;           Dim rotRemap(4)
;           rotRemap(0) = 3
;           rotRemap(1) = 2
;           rotRemap(2) = 0
;           rotRemap(3) = 1
;           NewMap customBlocksRot.xy()
;           While rotation
;             For z = 0 To sz-1
;               dest_col = sy - 1 
;               For h = 0 To sy - 1
;                 For w = 0 To sx - 1
;                   tmp = PeekB(*destbuff+z*sx*sy + h*sx + w)
;                   dest(w * sy + dest_col) = tmp
;                   If tmp = 66 Or SBlocks(tmp)\type = #BLOCKTYPE_Torch
;                     If FindMapElement(customBlocks(),Str(w)+","+Str(h)+","+Str(z))
;                       
;                       If SBlocks(tmp)\type = #BLOCKTYPE_Torch And customBlocks()\vis < 4
;                         customBlocksRot(Str(dest_col)+","+Str(w)+","+Str(z))\vis = rotRemap(customBlocks()\vis) ;Rotate torches
;                       Else
;                         customBlocksRot(Str(dest_col)+","+Str(w)+","+Str(z))\vis = customBlocks()\vis
;                       EndIf
;                       
;                     EndIf
;                   EndIf
;                  Next
;                  dest_col-1
;                Next
;                For h = 0 To sy - 1
;                 For w = 0 To sx - 1
;                     PokeB(*destbuff+z*sx*sy + h*sx + w, dest(h*sx + w))
;                  Next
;                Next
;              Next z
;              stmp = sx
;              sx = sy
;              sy = stmp
;              ClearMap(customBlocks())
;              ResetMap(customBlocksRot())
;              While NextMapElement(customBlocksRot())
;                customBlocks(MapKey(customBlocksRot()))\vis = customBlocksRot()\vis
;              Wend
;              ClearMap(customBlocksRot())
;             rotation-1
;           Wend
;           FreeMap(customBlocksRot())
;         EndIf
        
        schemGeo = 100
        ClearList(schBlocks())
        For x=0 To sx-1
          prcnt = ((x)*100)/(sx)
            SetGadgetState(progress,prcnt)
            SetGadgetText(progressText,"Optimizing mesh..."+Str(prcnt)+"%")
            WindowEvent()
          For y = 0 To sy-1
            memy = y*sx
            For z = 0 To sz-1
              memz = z*sx*sy
              tmp = PeekB(*destbuff + x + memy + memz)
              bb = 0
              If tmp = 66 Or SBlocks(tmp)\type = #BLOCKTYPE_Torch
                If FindMapElement(customBlocks(),Str(x)+","+Str(y)+","+Str(z))
                  cblock = customBlocks()\vis
                EndIf
              EndIf
              If SBlockTypes(tmp) <> #BLOCKTYPE_VOID
                If SBlockTypes(tmp) = #BLOCKTYPE_NORMAL
                  If(x<sx-1)
                    nb = PeekB(*destbuff + x+1 + memy + memz)
                    If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL
                      bb = $08
                    EndIf
                  Else
                    bb = $08
                  EndIf
                  
                  If(x>0)
                    nb = PeekB(*destbuff + x-1 + memy + memz)
                    If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL
                      bb = bb | $04
                    EndIf
                  Else
                    bb = bb | $04
                  EndIf
                 
                  If(y<sy-1)
                    nb = PeekB(*destbuff + x + memy+sx + memz)
                    If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL
                      bb = bb | $10
                    EndIf
                  Else
                    bb = bb | $10
                  EndIf
                  If(y>0)
                    nb = PeekB(*destbuff + x + memy-sx + memz)
                    If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL
                      bb = bb | $20
                    EndIf
                  Else
                    bb = bb | $20
                  EndIf
                  If(z<sz-1)
                    nb = PeekB(*destbuff + x + memy + memz+(sx*sy))
                    If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL
                      bb = bb | $01
                    EndIf
                  Else
                    bb = bb | $01
                  EndIf
                 
                  If(z>0)
                    nb = PeekB(*destbuff + x + memy + memz-(sx*sy))
                    If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL
                      bb = bb | $02
                    EndIf
                  Else
                    bb = bb | $02
                  EndIf
                  
                  If(bb)
                    AddElement(schBlocks())
                    schBlocks()\x = x
                    schBlocks()\y = y
                    schBlocks()\z = z
                    schBlocks()\id = tmp
                    schBlocks()\bb = bb
                    schBlocks()\cblock = cblock
                  EndIf
                ElseIf SBlockTypes(tmp) = #BLOCKTYPE_BILLBOARD
                  AddElement(schBlocks())
                  schBlocks()\x = x
                  schBlocks()\y = y
                  schBlocks()\z = z
                  schBlocks()\id = tmp
                  schBlocks()\bb = $80
                  schBlocks()\cblock = cblock
                Else  ;alpha blocks
                  If(x<sx-1)
                    nb = PeekB(*destbuff + x+1 + memy + memz)
                    If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL
                      bb = $08
                    EndIf
                  Else
                    bb = $08
                  EndIf
                  
                  If(x>0)
                    nb = PeekB(*destbuff + x-1 + memy + memz)
                    If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL
                      bb = bb | $04
                    EndIf
                  Else
                    bb = bb | $04
                  EndIf
                 
                  If(y<sy-1)
                    nb = PeekB(*destbuff + x + memy+sx + memz)
                    If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL
                      bb = bb | $10
                    EndIf
                  Else
                    bb = bb | $10
                  EndIf
                  If(y>0)
                    nb = PeekB(*destbuff + x + memy-sx + memz)
                    If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL
                      bb = bb | $20
                    EndIf
                  Else
                    bb = bb | $20
                  EndIf
                  If(z<sz-1)
                    nb = PeekB(*destbuff + x + memy + memz+(sx*sy))
                    If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL
                      bb = bb | $01
                    EndIf
                  Else
                    bb = bb | $01
                  EndIf
                 
                  If(z>0)
                    nb = PeekB(*destbuff + x + memy + memz-(sx*sy))
                    If SBlockTypes(nb) <> #BLOCKTYPE_NORMAL
                      bb = bb | $02
                    EndIf
                  Else
                    bb = bb | $02
                  EndIf
                  If bb
                    AddElement(schBlocks())
                    schBlocks()\x = x
                    schBlocks()\y = y
                    schBlocks()\z = z
                    schBlocks()\id = tmp
                    schBlocks()\bb = bb
                    schBlocks()\cblock = cblock
                  EndIf
                EndIf
              EndIf
            Next
          Next
        Next
        SetGadgetState(progress,99)
        SetGadgetText(progressText,"Sorting Blocktypes...")
        WindowEvent()
        SortStructuredList(schBlocks(), #PB_Sort_Ascending, OffsetOf(Block\cblock), TypeOf(Block\cblock))
        SortStructuredList(schBlocks(), #PB_Sort_Ascending, OffsetOf(Block\id), TypeOf(Block\id))
        ResetList(schBlocks())
        lastEl = -1
        lastCEl = -1
        While NextElement(schBlocks())
          If schBlocks()\id <> 66
            If lastEl <> schBlocks()\id
              lastEl = schBlocks()\id
              ;AddBlockToList(SBlocks(schBlocks()\id)\name,schBlocks()\id,0)
            EndIf
          ElseIf lastCEl <> schBlocks()\cblock
            lastCEl = schBlocks()\cblock
            If Not FindMapElement(CBlocks(),Str(schBlocks()\cblock))
              addCustomBlock(schBlocks()\cblock)
            EndIf
            ;AddBlockToList(CBlocks()\name,schBlocks()\id,schBlocks()\cblock)
          EndIf
        Wend
        ret = 1
      Else
        MessageRequester("Error","Lz4.dll not found, or not accessible. This file should have been shipped with the tool, try to re-download.")
      EndIf
      FreeMemory(*destbuff)
      FreeMemory(*srcbuff)
    Else
      MessageRequester("Error","There is not enough memory available to ofen this schematic. Try unloading some chunks and closing applications to make some space.")
      If(*destbuff)
        FreeMemory(*destbuff)
      EndIf
      If *srcbuff
        FreeMemory(*srcbuff)
      EndIf
    EndIf
    CloseFile(file)
  Else
    MessageRequester("Error","The selected file could not be read, sorry.")
  EndIf
  CloseWindow(progressWindow)
ProcedureReturn ret
EndProcedure







Procedure.i readInverse(file, bytes)
  Ret.i = 0
  For i=0 To bytes-1
    unsigned.a = ReadByte(0)
    Ret = ret*256
    ret = ret + unsigned
  Next
  ProcedureReturn ret
EndProcedure


Procedure loadMCSchematic()
  Dim BlockReMap.l(255) 
  Dim StairsReMap.b(255)
  Dim SlabsReMap.b(255)

For i=0 To 255
  BlockReMap(i) = 3   ; replace unknowns with air
Next
BlockReMap(0) = 3
BlockReMap(1) = 0
BlockReMap(2) = 1
BlockReMap(3) = 2
BlockReMap(4) = 8
BlockReMap(5) = 33
BlockReMap(12) = 10
BlockReMap(13) = 8
BlockReMap(14) = 26
BlockReMap(17) = 6
BlockReMap(98) = 46
BlockReMap(48) = 46
BlockReMap(18) = 7

;unmappable stuff (trapdoors signs buttons, etc

BlockReMap(143) = 3
BlockReMap(96) = 3
BlockReMap(85) = 3
BlockReMap(188) = 3
BlockReMap(183) = 3
BlockReMap(136) = 3
BlockReMap(167) = 3
BlockReMap(65) = 3



;slabs
BlockReMap(126) = 1001
BlockReMap(182) = 1001
BlockReMap(205) = 1001
BlockReMap(44) = 1001

SlabsReMap(126) = 33
SlabsReMap(182) = 10
SlabsReMap(205) = 10
SlabsReMap(44) = 0


;Stairs
BlockReMap(53) = 1000
BlockReMap(67) = 1000
BlockReMap(108) = 1000
BlockReMap(109) = 1000
BlockReMap(114) = 1000
BlockReMap(128) = 1000
BlockReMap(134) = 1000
BlockReMap(135) = 1000
BlockReMap(136) = 1000
BlockReMap(163) = 1000
BlockReMap(164) = 1000
BlockReMap(180) = 1000

StairsReMap(53) = 33
StairsReMap(67) = 8
StairsReMap(108) = 46
StairsReMap(109) = 46
StairsReMap(114) = 46
StairsReMap(128) = 10


StairsReMap(134) = 33
StairsReMap(135) = 33
StairsReMap(136) = 33
StairsReMap(163) = 33
StairsReMap(164) = 33

StairsReMap(180) = 10


Dim RawBlocks.b(1)
Dim RawBlockData.b(1)
If(OpenFile(0,"D:\m0\INGb\projekte\cyubeVR\castledepoindestev-2"))
  Dim Arrrecord(1)
  unsigned.a = 0
  While(Not Eof(0) And (width = 0 Or Height=0 Or Length=0 Or ArraySize(RawBlocks()) = 1 Or ArraySize(RawBlockData()) = 1))
    RecType = ReadByte(0)
    If(RecType <> 0)
      RecNamLen.i = ReadByte(0)*256+ReadByte(0)
      RecName.s = ReadString(0,#PB_Ascii,RecNamLen)
      Select RecType
        Case 0:
          RecLen = 0
        Case 1:
          RecLen = 1
          record = readInverse(0,1)
        Case 2:
          RecLen = 2
          record = readInverse(0,2)
        Case 3:
          RecLen = 4
          record = readInverse(0,4)
        Case 4:
          RecLen = 8
          record = readInverse(0,8)
        Case 5:
          RecLen = 4
          Frecord.f = ReadFloat(0)
        Case 6:
          RecLen = 8
          Drecord.d = ReadDouble(0)
        Case 7:
          RecLen = readInverse(0,4)
          If RecLen
            ReDim Arrrecord(RecLen-1)
            For i=0 To RecLen-1
              Arrrecord(i) = readInverse(0,1)
            Next
          EndIf
          
        Case 8:
          RecLen = readInverse(0,2)
          If RecLen
            ReDim Arrrecord(RecLen-1)
            For i=0 To RecLen-1
              Arrrecord(i) = readInverse(0,1)
            Next  
          EndIf
          
        Case 9:
          InnerTagType = readInverse(0,1)
          If(InnerTagType <> 0)
            If(InnerTagType <> 10)
              MessageRequester("Error","nested tags not supported when of type "+Str(InnerTagType))
              End
            EndIf
            InnerPayload = readInverse(0,4)
          EndIf
          
          RecLen = 0
          
        Case 11:
          RecLen = readInverse(0,4)
          If(RecLen)
            ReDim Arrrecord(RecLen-1)
            For i=0 To RecLen-1
              Arrrecord(i) =  readInverse(0,4)
            Next
          EndIf
          
        Case 12:
          RecLen = readInverse(0,4)
          If RecLen
            ReDim Arrrecord(RecLen-1)
            For i=0 To RecLen-1
              Arrrecord(i) = readInverse(0,8)
            Next
          EndIf
          
        Default:
          RecLen = 0
      EndSelect   
      ;MessageRequester("",RecName)
      If RecName = "Width"
        Width = record
      ElseIf RecName = "Height"
        Height = record
      ElseIf RecName = "Length"
        Length = record
      ElseIf RecName = "Blocks"
        ReDim RawBlocks(RecLen-1)
        For i=0 To RecLen-1
          RawBlocks(i) = Arrrecord(i)
        Next
      ElseIf RecName = "Data"
        ReDim RawBlockData(RecLen-1)
        For i=0 To RecLen-1
          RawBlockData(i) = Arrrecord(i)
        Next
      EndIf
    EndIf 
    Wend
    Dim Blocks.a(width-1,Length-1,height-1)
    Dim BlockData.a(width-1,Length-1,height-1)
    For x=0 To width-1
      For y=0 To height-1
        For z=0 To Length-1
          Blocks(x,z,y) = RawBlocks((Y*length + Z)*width + X)
          BlockData(x,z,y) = RawBlockData((Y*length + Z)*width + X)
          ;MessageRequester("Blocks",Str(x)+", "+Str(y)+", "+Str(z)+": "+Str(Blocks(x,y,z)))
        Next
      Next
    Next
    CloseFile(0)
  EndIf
  Dim cyubeBlocks(width*2-1,length*2-1,height*2-1)
  CreateStaticGeometry(#GEO, width, height, length, #True)
  For x=0 To width-1
    cx = x*2
    For y=0 To Length-1
      cy = y*2
      For z=0 To height-1
        cz = z*2
        If(IsEntity(BlockReMap(Blocks(x,y,z))))
          cblock = BlockReMap(Blocks(x,y,z))
          AddStaticGeometryEntity(#GEO, EntityID(cblock), (x-0.25-height/4),z-0.25,(y-0.25-width/4),2,2,2)
          cyubeBlocks(cx,cy,cz) = cblock
          cyubeBlocks(cx+1,cy,cz) = cblock
          cyubeBlocks(cx,cy+1,cz) = cblock
          cyubeBlocks(cx+1,cy+1,cz) = cblock
          cyubeBlocks(cx,cy,cz+1) = cblock
          cyubeBlocks(cx+1,cy,cz+1) = cblock
          cyubeBlocks(cx,cy+1,cz+1) = cblock
          cyubeBlocks(cx+1,cy+1,cz+1) = cblock
        ElseIf(BlockReMap(Blocks(x,y,z)) <> 3)
          If(BlockReMap(Blocks(x,y,z)) = 1000)  ;Stairs
            cblock = StairsReMap(Blocks(x,y,z))
            If(BlockData(x,y,z) & $04)
              AddStaticGeometryEntity(#GEO, EntityID(cblock), (x-0.25-height/4),z,(y-0.25-width/4),2,1,2) ;upside down
              cyubeBlocks(cx,cy,cz+1) = cblock
              cyubeBlocks(cx+1,cy,cz+1) = cblock
              cyubeBlocks(cx,cy+1,cz+1) = cblock
              cyubeBlocks(cx+1,cy+1,cz+1) = cblock
              Select (BlockData(x,y,z) & $03)
                  Case 2:
                    AddStaticGeometryEntity(#GEO, EntityID(cblock), (x-0.25-height/4),z-0.5,(y-width/4),2,1,1)
                    cyubeBlocks(cx,cy+1,cz) = cblock
                    cyubeBlocks(cx+1,cy+1,cz) = cblock
                  Case 3:
                    AddStaticGeometryEntity(#GEO, EntityID(cblock), (x-0.25-height/4),z-0.5,(y-0.5-width/4),2,1,1)
                    cyubeBlocks(cx,cy,cz) = cblock
                    cyubeBlocks(cx+1,cy,cz) = cblock
                  Case 0:
                    AddStaticGeometryEntity(#GEO, EntityID(cblock), (x-height/4),z-0.5,(y-0.25-width/4),1,1,2)
                    cyubeBlocks(cx+1,cy,cz) = cblock
                    cyubeBlocks(cx+1,cy+1,cz) = cblock
                  Case 1:
                    AddStaticGeometryEntity(#GEO, EntityID(cblock), (x-0.5-height/4),z-0.5,(y-0.25-width/4),1,1,2)
                    cyubeBlocks(cx,cy,cz) = cblock
                    cyubeBlocks(cx,cy+1,cz) = cblock
                EndSelect
              Else
              AddStaticGeometryEntity(#GEO, EntityID(cblock), (x-0.25-height/4),z-0.5,(y-0.25-width/4),2,1,2) ;Upside up
              cyubeBlocks(cx,cy,cz) = cblock
              cyubeBlocks(cx+1,cy,cz) = cblock
              cyubeBlocks(cx,cy+1,cz) = cblock
              cyubeBlocks(cx+1,cy+1,cz) = cblock
              Select (BlockData(x,y,z) & $03)
                  Case 2:
                    AddStaticGeometryEntity(#GEO, EntityID(cblock), (x-0.25-height/4),z,(y-width/4),2,1,1)
                    cyubeBlocks(cx,cy+1,cz+1) = cblock
                    cyubeBlocks(cx+1,cy+1,cz+1) = cblock
                  Case 3:
                    AddStaticGeometryEntity(#GEO, EntityID(cblock), (x-0.25-height/4),z,(y-0.5-width/4),2,1,1)
                    cyubeBlocks(cx,cy,cz+1) = cblock
                    cyubeBlocks(cx+1,cy,cz+1) = cblock
                  Case 0:
                    AddStaticGeometryEntity(#GEO, EntityID(cblock), (x-height/4),z,(y-0.25-width/4),1,1,2)
                    cyubeBlocks(cx+1,cy,cz+1) = cblock
                    cyubeBlocks(cx+1,cy+1,cz+1) = cblock
                  Case 1:
                    AddStaticGeometryEntity(#GEO, EntityID(cblock), (x-0.5-height/4),z,(y-0.25-width/4),1,1,2)
                    cyubeBlocks(cx,cy,cz+1) = cblock
                    cyubeBlocks(cx,cy+1,cz+1) = cblock
                EndSelect
            EndIf
          ElseIf (BlockReMap(Blocks(x,y,z)) = 1001)  ;Slabs
            cblock = SlabsReMap(Blocks(x,y,z))
            If(BlockData(x,y,z) & $08)
              AddStaticGeometryEntity(#GEO, EntityID(cblock), (x-0.25-height/4),z,(y-0.25-width/4),2,1,2) ;upside down
              cyubeBlocks(cx,cy,cz+1) = cblock
              cyubeBlocks(cx+1,cy,cz+1) = cblock
              cyubeBlocks(cx,cy+1,cz+1) = cblock
              cyubeBlocks(cx+1,cy+1,cz+1) = cblock
            Else
              AddStaticGeometryEntity(#GEO, EntityID(cblock), (x-0.25-height/4),z-0.5,(y-0.25-width/4),2,1,2) ;Upside up
              cyubeBlocks(cx,cy,cz) = cblock
              cyubeBlocks(cx+1,cy,cz) = cblock
              cyubeBlocks(cx,cy+1,cz) = cblock
              cyubeBlocks(cx+1,cy+1,cz) = cblock
            EndIf
          Else
            ;AddStaticGeometryEntity(#GEO, EntityID(3), (x-height/2),z,(y-width/2),2,2,2)
            cyubeBlocks(cx,cy,cz) = 3
            cyubeBlocks(cx+1,cy,cz) = 3
            cyubeBlocks(cx,cy+1,cz) = 3
            cyubeBlocks(cx+1,cy+1,cz) = 3
            cyubeBlocks(cx,cy,cz+1) = 3
            cyubeBlocks(cx+1,cy,cz+1) = 3
            cyubeBlocks(cx,cy+1,cz+1) = 3
            cyubeBlocks(cx+1,cy+1,cz+1) = 3
          EndIf
        Else
            cyubeBlocks(cx,cy,cz) = 3
            cyubeBlocks(cx+1,cy,cz) = 3
            cyubeBlocks(cx,cy+1,cz) = 3
            cyubeBlocks(cx+1,cy+1,cz) = 3
            cyubeBlocks(cx,cy,cz+1) = 3
            cyubeBlocks(cx+1,cy,cz+1) = 3
            cyubeBlocks(cx,cy+1,cz+1) = 3
            cyubeBlocks(cx+1,cy+1,cz+1) = 3
       EndIf
      Next
    Next
  Next
  BuildStaticGeometry(#GEO) 
  If(OpenFile(0,"D:\m0\INGb\projekte\cyubeVR\CyubeSchem.schem"))
    WriteLong(0,width*2)
    WriteLong(0,length*2)
    WriteLong(0,Height*2)
    
    For x=0 To width*2-1
        For y = 0 To length*2-1
          For z = 0 To height*2-1
            WriteByte(0,cyubeBlocks(x,y,z))
          Next
        Next
      Next
      CloseFile(0)
      
      EndIf
 ; MessageRequester("Dims:","Width: "+Str(Width)+" Length: "+Str(Length)+" Height: "+Str(Height))
EndProcedure

; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 20
; Folding = -
; EnableXP