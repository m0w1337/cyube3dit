

IncludeFile "ddsUnpack.pbi"


Procedure LoadCustomBlocks(CustomBlockDir.s, noUpload)
  Shared CBlocks
  If noUpload = 0
    If Not g_CBlockDB
      MessageRequester("","Connection to block database failed, custom block database could not be updated with your blocks!")
    EndIf
  EndIf
  If ExamineDirectory(0,CustomBlockDir,"*.*")
    While NextDirectoryEntry(0)
      StatusBarProgressUnknown(0,1)
      If DirectoryEntryType(0) = #PB_DirectoryEntry_Directory And DirectoryEntryName(0) <> "." And DirectoryEntryName(0) <> ".."
        If FileSize(CustomBlockDir+DirectoryEntryName(0)+"\properties.json") > 0 And FileSize(CustomBlockDir+DirectoryEntryName(0)+"\textures\") = -2
          file = ReadFile(#PB_Any,CustomBlockDir+DirectoryEntryName(0)+"\properties.json")
          If file
            CBauthor.s = ""
            While Not Eof(file)
              line.s = ReadString(file)
              If FindString(line,Chr(34)+"Name"+Chr(34)+":",0,#PB_String_NoCase)
                line = ReverseString(line)
                pos1 = FindString(line,Chr(34))
                pos2 = FindString(line,Chr(34),pos1+1)-1
                CBname.s = ReverseString(Mid(line,pos1+1,pos2-pos1))      
                If FindString(CBname,"Matrix")
                  MessageRequester("","")
                EndIf
                
              ElseIf FindString(line,Chr(34)+"Mode"+Chr(34),0,#PB_String_NoCase)
                line = ReverseString(line)
                pos1 = FindString(line,":")
                CBmode = Val(ReverseString(Mid(line,0,pos1-1)))
              ElseIf FindString(line,Chr(34)+"UniqueID"+Chr(34),0,#PB_String_NoCase)
                line = ReverseString(line)
                pos1 = FindString(line,":")
                CBid.l = Val(ReverseString(Mid(line,0,pos1-1)))
              ElseIf FindString(line,Chr(34)+"CreatorName"+Chr(34),0,#PB_String_NoCase)
                line = ReverseString(line)
                pos1 = FindString(line,Chr(34))
                pos2 = FindString(line,Chr(34),pos1+1)-1
                CBauthor.s = ReverseString(Mid(line,pos1+1,pos2-pos1))
              EndIf
              While WindowEvent()
              Wend
            Wend
            CloseFile(file)
            While WindowEvent()
            Wend
            
            lastDate = 0
            If(CBname And CBmode > 0 And CBmode < 5)
              Select CBmode
                Case 1:
                  CBlocks(Str(CBid))\mode = CBmode
                  CBlocks()\id = CBid
                  CBlocks()\name = CBname
                  If FileSize(CustomBlockDir+DirectoryEntryName(0)+"\Textures\all.dds")
                    Date = GetFileDate(CustomBlockDir+DirectoryEntryName(0)+"\Textures\all.dds", #PB_Date_Modified)
                    If date > lastDate
                      lastDate = date
                    EndIf
                    CBlocks()\tex(#texInd_all) = CreateTextureDDS(CustomBlockDir+DirectoryEntryName(0)+"\Textures\all.dds")
                    If CBlocks()\tex(#texInd_all)
                      CBlocks()\mode = CBmode
                      CBlocks()\id = CBid
                      CBlocks()\mat(#texInd_all) =  CreateMaterial(#PB_Any,TextureID(CBlocks()\tex(#texInd_all)))
                      CBlocks()\name = CBname
                    EndIf
                  EndIf
                Case 2:
                  CBlocks(Str(CBid))\mode = CBmode
                  CBlocks()\id = CBid
                  CBlocks()\name = CBname
                  If FileSize(CustomBlockDir+DirectoryEntryName(0)+"\Textures\sides.dds")
                    Date = GetFileDate(CustomBlockDir+DirectoryEntryName(0)+"\Textures\sides.dds", #PB_Date_Modified)
                    If date > lastDate
                      lastDate = date
                    EndIf
                    CBlocks()\tex(#texInd_sides) = CreateTextureDDS(CustomBlockDir+DirectoryEntryName(0)+"\Textures\sides.dds")
                    If CBlocks()\tex(#texInd_sides)
                      CBlocks()\mode = CBmode
                      CBlocks()\id = CBid
                      CBlocks()\mat(#texInd_sides) =  CreateMaterial(#PB_Any,TextureID(CBlocks()\tex(#texInd_sides)))
                      CBlocks()\name = CBname
                    EndIf
                  EndIf
                  If  FileSize(CustomBlockDir+DirectoryEntryName(0)+"\Textures\updown.dds")
                    Date = GetFileDate(CustomBlockDir+DirectoryEntryName(0)+"\Textures\updown.dds", #PB_Date_Modified)
                    If date > lastDate
                      lastDate = date
                    EndIf
                    CBlocks()\tex(#texInd_upDown) = CreateTextureDDS(CustomBlockDir+DirectoryEntryName(0)+"\Textures\updown.dds")
                    If CBlocks()\tex(#texInd_upDown)
                      CBlocks()\mat(#texInd_upDown) =  CreateMaterial(#PB_Any,TextureID(CBlocks()\tex(#texInd_upDown)))
                    Else
                      CBlocks()\mat(#texInd_upDown) =  CBlocks()\mat(#texInd_sides)
                      CBlocks()\tex(#texInd_upDown) =  CBlocks()\tex(#texInd_sides)
                    EndIf
                  EndIf
                Case 3:
                  CBlocks(Str(CBid))\mode = CBmode
                  CBlocks()\id = CBid
                  CBlocks()\name = CBname
                  If FileSize(CustomBlockDir+DirectoryEntryName(0)+"\Textures\sides.dds")
                    Date = GetFileDate(CustomBlockDir+DirectoryEntryName(0)+"\Textures\sides.dds", #PB_Date_Modified)
                    If date > lastDate
                      lastDate = date
                    EndIf
                    CBlocks()\tex(#texInd_sides) = CreateTextureDDS(CustomBlockDir+DirectoryEntryName(0)+"\Textures\sides.dds")
                    If CBlocks()\tex(#texInd_sides)
                      CBlocks()\mat(#texInd_sides) =  CreateMaterial(#PB_Any,TextureID(CBlocks()\tex(#texInd_sides)))
                    EndIf
                  EndIf
                  If FileSize(CustomBlockDir+DirectoryEntryName(0)+"\Textures\up.dds")
                    Date = GetFileDate(CustomBlockDir+DirectoryEntryName(0)+"\Textures\up.dds", #PB_Date_Modified)
                    If date > lastDate
                      lastDate = date
                    EndIf
                    CBlocks()\tex(#texInd_top) = CreateTextureDDS(CustomBlockDir+DirectoryEntryName(0)+"\Textures\up.dds")
                    If CBlocks()\tex(#texInd_top)
                      CBlocks()\mat(#texInd_top) =  CreateMaterial(#PB_Any,TextureID(CBlocks()\tex(#texInd_top)))
                    Else
                      CBlocks()\tex(#texInd_top) =  CBlocks()\tex(#texInd_sides)
                      CBlocks()\mat(#texInd_top) =  CBlocks()\mat(#texInd_sides)
                    EndIf
                  EndIf
                  If FileSize(CustomBlockDir+DirectoryEntryName(0)+"\Textures\down.dds")
                    Date = GetFileDate(CustomBlockDir+DirectoryEntryName(0)+"\Textures\down.dds", #PB_Date_Modified)
                    If date > lastDate
                      lastDate = date
                    EndIf
                    CBlocks()\tex(#texInd_bottom) = CreateTextureDDS(CustomBlockDir+DirectoryEntryName(0)+"\Textures\down.dds")
                    If CBlocks()\tex(#texInd_bottom)
                      CBlocks()\mat(#texInd_bottom) =  CreateMaterial(#PB_Any,TextureID(CBlocks()\tex(#texInd_bottom)))
                    Else
                      CBlocks()\tex(#texInd_bottom) =  CBlocks()\tex(#texInd_sides)
                      CBlocks()\mat(#texInd_bottom) =  CBlocks()\mat(#texInd_sides)
                    EndIf
                  EndIf
                Case 4:
                  CBlocks(Str(CBid))\mode = CBmode
                  CBlocks()\id = CBid
                  CBlocks()\name = CBname
                  If FileSize(CustomBlockDir+DirectoryEntryName(0)+"\Textures\up.dds")
                    Date = GetFileDate(CustomBlockDir+DirectoryEntryName(0)+"\Textures\up.dds", #PB_Date_Modified)
                    If date > lastDate
                      lastDate = date
                    EndIf
                    CBlocks()\tex(#texInd_top) = CreateTextureDDS(CustomBlockDir+DirectoryEntryName(0)+"\Textures\up.dds")
                    If CBlocks()\tex(#texInd_top)
                      CBlocks()\mat(#texInd_top) =  CreateMaterial(#PB_Any,TextureID(CBlocks()\tex(#texInd_top)))
                    EndIf
                  EndIf
                  If FileSize(CustomBlockDir+DirectoryEntryName(0)+"\Textures\down.dds")
                    Date = GetFileDate(CustomBlockDir+DirectoryEntryName(0)+"\Textures\down.dds", #PB_Date_Modified)
                    If date > lastDate
                      lastDate = date
                    EndIf
                    CBlocks()\tex(#texInd_bottom) = CreateTextureDDS(CustomBlockDir+DirectoryEntryName(0)+"\Textures\down.dds")
                    If CBlocks()\tex(#texInd_bottom)
                      CBlocks()\mat(#texInd_bottom) =  CreateMaterial(#PB_Any,TextureID(CBlocks()\tex(#texInd_bottom)))
                    Else
                      CBlocks()\tex(#texInd_bottom) =  CBlocks()\tex(#texInd_top)
                      CBlocks()\mat(#texInd_bottom) =  CBlocks()\mat(#texInd_top)
                    EndIf
                  EndIf
                  If FileSize(CustomBlockDir+DirectoryEntryName(0)+"\Textures\left.dds")
                    Date = GetFileDate(CustomBlockDir+DirectoryEntryName(0)+"\Textures\left.dds", #PB_Date_Modified)
                    If date > lastDate
                      lastDate = date
                    EndIf
                    CBlocks()\tex(#texInd_left) = CreateTextureDDS(CustomBlockDir+DirectoryEntryName(0)+"\Textures\left.dds")
                    If CBlocks()\tex(#texInd_left)
                      CBlocks()\mat(#texInd_left) =  CreateMaterial(#PB_Any,TextureID(CBlocks()\tex(#texInd_left)))
                    Else
                      CBlocks()\tex(#texInd_left) =  CBlocks()\tex(#texInd_top)
                      CBlocks()\mat(#texInd_left) =  CBlocks()\mat(#texInd_top)
                    EndIf
                  EndIf
                  If FileSize(CustomBlockDir+DirectoryEntryName(0)+"\Textures\right.dds")
                    Date = GetFileDate(CustomBlockDir+DirectoryEntryName(0)+"\Textures\right.dds", #PB_Date_Modified)
                    If date > lastDate
                      lastDate = date
                    EndIf
                    CBlocks()\tex(#texInd_right) = CreateTextureDDS(CustomBlockDir+DirectoryEntryName(0)+"\Textures\right.dds")
                    If CBlocks()\tex(#texInd_right)
                      CBlocks()\mat(#texInd_right) =  CreateMaterial(#PB_Any,TextureID(CBlocks()\tex(#texInd_right)))
                    Else
                      CBlocks()\tex(#texInd_right) =  CBlocks()\tex(#texInd_top)
                      CBlocks()\mat(#texInd_right) =  CBlocks()\mat(#texInd_top)
                    EndIf
                  EndIf
                  If FileSize(CustomBlockDir+DirectoryEntryName(0)+"\Textures\front.dds")
                    Date = GetFileDate(CustomBlockDir+DirectoryEntryName(0)+"\Textures\front.dds", #PB_Date_Modified)
                    If date > lastDate
                      lastDate = date
                    EndIf
                    CBlocks()\tex(#texInd_front) = CreateTextureDDS(CustomBlockDir+DirectoryEntryName(0)+"\Textures\front.dds")
                    If CBlocks()\tex(#texInd_front)
                      CBlocks()\mat(#texInd_front) =  CreateMaterial(#PB_Any,TextureID(CBlocks()\tex(#texInd_front)))
                    Else
                      CBlocks()\tex(#texInd_front) =  CBlocks()\tex(#texInd_top)
                      CBlocks()\mat(#texInd_front) =  CBlocks()\mat(#texInd_top)
                    EndIf
                  EndIf
                  If FileSize(CustomBlockDir+DirectoryEntryName(0)+"\Textures\back.dds")
                    Date = GetFileDate(CustomBlockDir+DirectoryEntryName(0)+"\Textures\back.dds", #PB_Date_Modified)
                    If date > lastDate
                      lastDate = date
                    EndIf
                    CBlocks()\tex(#texInd_back) = CreateTextureDDS(CustomBlockDir+DirectoryEntryName(0)+"\Textures\back.dds")
                    If CBlocks()\tex(#texInd_back)
                      CBlocks()\mat(#texInd_back) =  CreateMaterial(#PB_Any,TextureID(CBlocks()\tex(#texInd_back)))
                    Else
                      CBlocks()\tex(#texInd_back) =  CBlocks()\tex(#texInd_top)
                      CBlocks()\mat(#texInd_back) =  CBlocks()\mat(#texInd_top)
                    EndIf
                  EndIf
              EndSelect
              update = 1
            If FileSize(GetLApplicationDataDirectory()+"CyubE3dit\cblock_prev\"+Str(CBlocks()\id)+".png") > 0
              If lastDate <= GetFileDate(GetLApplicationDataDirectory()+"CyubE3dit\cblock_prev\"+Str(CBlocks()\id)+".png", #PB_Date_Modified)
                update = 0
              EndIf
            EndIf
            If update 
              SaveBlockPreview(66, CBlocks()\id, noUpload,CBauthor)
            EndIf
            ;CBlocks()\prev = LoadImage(#PB_Any,GetLApplicationDataDirectory()+"CyubE3dit\cblock_prev\"+Str(CBlocks()\id)+".png")
            StatusBarText(0,0,"Found "+MapSize(CBlocks())+" custom blocks so far. (Last Added '"+CBname+"')")
             While WindowEvent()
             Wend
             ;DeleteFile("./Textures/Block_prev/"+Str(CBlocks()\id)+".png")
            EndIf
          EndIf
        EndIf
      EndIf
      WindowEvent()
    Wend
    FinishDirectory(0)
  EndIf
EndProcedure



; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 38
; FirstLine = 18
; Folding = -
; EnableXP