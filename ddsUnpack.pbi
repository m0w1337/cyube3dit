
    
    Procedure OpenDDS(filename.s, *imagedata,*ddsSize.xy)
      
      If(FileSize(filename) > 0)
        file = ReadFile(#PB_Any, filename, #PB_File_SharedRead)
        If IsFile(file)
          *memory = AllocateMemory(16)
          FileSeek(file,12,#PB_Absolute)
          ReadData(file,*memory,8)

          width = PeekL(*memory)
          height = PeekL(*memory+4)
          *ddsSize\x = width
          *ddsSize\y = height
          FileSeek(file,$80,#PB_Absolute)
          For y = 0 To height-1 Step 4
            For x = 0 To width-1 Step 4
              If Eof(file)
                Break 2
              EndIf
              ReadData(file,*memory,MemorySize(*memory))
              alpha0 = PeekA(*memory)
              alpha1 = PeekA(*memory+1)
              alphaCode1 = PeekL(*memory+4)
              alphaCode2 = PeekW(*memory+2)
              color0 = PeekW(*memory+8);PeekB(*memory+8) << 8 | PeekB(*memory+9) ;PeekW!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
              color1 = PeekW(*memory+10); << 8 | PeekB(*memory+11) ;PeekW!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
              temp = ((color0 >> 11) & $1F) * 255 + 16
              r0.a = (temp/32 + temp)/32
              temp = ((color0 & $07E0) >> 5) * 255 + 32
              g0 = ((temp/64 + temp)/64)
              temp = (color0 & $001F) * 255 + 16
              b0 = ((temp/32 + temp)/32)
    
              temp = ((color1 >> 11) & $1F) * 255 + 16
              r1 = ((temp/32 + temp)/32)
              temp = ((color1 & $07E0) >> 5) * 255 + 32
              g1 = ((temp/64 + temp)/64)
              temp = (color1 & $001F) * 255 + 16
              b1 = ((temp/32 + temp)/32)
              code = PeekL(*memory+12)
              For j=0 To 3
                For i=0 To 3
                  alphaCodeIndex = 3*(4*j+i)
                  If (alphaCodeIndex <= 12)
                    alphaCode = (alphaCode2 >> alphaCodeIndex) & $07;
                  ElseIf (alphaCodeIndex = 15)
                    alphaCode = (alphaCode2 >> 15) | ((alphaCode1 << 1) & $06);
                  Else
                    alphaCode = (alphaCode1 >> (alphaCodeIndex - 16)) & $07;
                  EndIf
    
                  finalAlpha.a = 0
                  If (alphaCode = 0)
                    finalAlpha = alpha0;
                  ElseIf (alphaCode = 1)
                    finalAlpha = alpha1;
                  Else
                    If (alpha0 > alpha1)
                      finalAlpha = ((8-alphaCode)*alpha0 + (alphaCode-1)*alpha1)/7;
                    Else
                      If (alphaCode = 6)
                        finalAlpha = 0;
                      ElseIf (alphaCode = 7)
                        finalAlpha = 255;
                      Else
                        finalAlpha = ((6-alphaCode)*alpha0 + (alphaCode-1)*alpha1)/5;
                      EndIf
                    EndIf
                  EndIf    
                colorCode = (code >> (2*(4*j+i))) & $03;
    
                finalColor.l = 0
                Select colorCode
                Case 0:
                  finalColor = RGBA(r0, g0, b0, finalAlpha);
                Case 1:
                  finalColor = RGBA(r1, g1, b1, finalAlpha);
                Case 2:
                  finalColor = RGBA((2*r0+r1)/3, (2*g0+g1)/3, (2*b0+b1)/3, finalAlpha);
                Case 3:
                  finalColor = RGBA((r0+2*r1)/3, (g0+2*g1)/3, (b0+2*b1)/3, finalAlpha);
              EndSelect
              
                If ((x + i) < width)
                  PokeL(*imagedata + (((y + j) * width + (x + i)))*4,finalcolor)
                EndIf
              Next i
            Next j
          Next x
        Next y
        
        FreeMemory(*memory)
        EndIf
      EndIf
    EndProcedure
    
 Procedure OpenDDSFast(filename.s, tex)
  If(FileSize(filename) > 0)
    file = ReadFile(#PB_Any, filename, #PB_File_SharedRead)
    If IsFile(file)
      *memory = AllocateMemory(16)
      FileSeek(file,12,#PB_Absolute)
      ReadData(file,*memory,8)

      width = PeekL(*memory)/4
      height = PeekL(*memory+4)/4
      If(TextureHeight(tex) < height Or TextureWidth(tex)< width)
        ProcedureReturn 0
      EndIf
      
      ;*ddsSize\x = width
      ;*ddsSize\y = height
      FileSeek(file,$80,#PB_Absolute)
      finalAlpha.a = 0
;       If(img)
;         ret = StartDrawing(ImageOutput(img))
;       Else
;         ret = StartDrawing(TextureOutput(tex))
;       EndIf
      If(StartDrawing(TextureOutput(tex)))
        For y = 0 To height-1
          For x = 0 To width-1
            If Eof(file)
              Break 2
            EndIf
            ReadData(file,*memory,MemorySize(*memory))
            alpha0 = PeekA(*memory)
            alpha1 = PeekA(*memory+1)
            ;alphaCode1 = PeekL(*memory+4)
            alphaCode = PeekW(*memory+2) & $07
            color0 = PeekW(*memory+8);PeekB(*memory+8) << 8 | PeekB(*memory+9) ;PeekW!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            color1 = PeekW(*memory+10); << 8 | PeekB(*memory+11) ;PeekW!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
            temp = ((color0 >> 11) & $1F) * 255 + 16
            r0.a = (temp/32 + temp)/32
            temp = ((color0 & $07E0) >> 5) * 255 + 32
            g0 = ((temp/64 + temp)/64)
            temp = (color0 & $001F) * 255 + 16
            b0 = ((temp/32 + temp)/32)
  
            temp = ((color1 >> 11) & $1F) * 255 + 16
            r1 = ((temp/32 + temp)/32)
            temp = ((color1 & $07E0) >> 5) * 255 + 32
            g1 = ((temp/64 + temp)/64)
            temp = (color1 & $001F) * 255 + 16
            b1 = ((temp/32 + temp)/32)
            code = PeekL(*memory+12)

            If (alphaCode = 0)
              finalAlpha = alpha0;
            ElseIf (alphaCode = 1)
              finalAlpha = alpha1;
            Else
              If (alpha0 > alpha1)
                finalAlpha = ((8-alphaCode)*alpha0 + (alphaCode-1)*alpha1)/7;
              Else
                If (alphaCode = 6)
                  finalAlpha = 0;
                ElseIf (alphaCode = 7)
                  finalAlpha = 255
                Else
                  finalAlpha = ((6-alphaCode)*alpha0 + (alphaCode-1)*alpha1)/5;
                EndIf
              EndIf
            EndIf    
            colorCode = code & $03;
            finalColor.l = 0
            Select colorCode
              Case 0:
                finalColor = RGBA(r0, g0, b0, finalAlpha);
              Case 1:
                finalColor = RGBA(r1, g1, b1, finalAlpha);
              Case 2:
                finalColor = RGBA((2*r0+r1)/3, (2*g0+g1)/3, (2*b0+b1)/3, finalAlpha);
              Case 3:
                finalColor = RGBA((r0+2*r1)/3, (g0+2*g1)/3, (b0+2*b1)/3, finalAlpha);
            EndSelect
            Plot(x,y,finalcolor)
          Next x
          
          WindowEvent()
        Next y
        StopDrawing()
      EndIf
      FreeMemory(*memory)
    EndIf
  EndIf
;   If img And StartDrawing(TextureOutput(tex))
;     ResizeImage(img,TextureWidth(tex),TextureHeight(tex))
;     DrawImage(ImageID(img),0,0,TextureWidth(tex),TextureHeight(tex))
;     StopDrawing()
;     FreeImage(img)
;   EndIf
  
EndProcedure
    
    
Procedure.l CreateTextureDDS(filename.s)
  ;StatusBarProgress(0,1,0)
  ;While WindowEvent()
  ;Wend
  
  tex = CreateTexture(#PB_Any,512,512)
  If tex
    ;*imageMem = AllocateMemory(512*512*4)
    OpenDDSFast(filename, tex)
    ;StatusBarProgress(0,1,100)
    ;While WindowEvent()
    ;Wend
  
;         If CreateImage(0,ddssize\x,ddssize\y)
;           If StartDrawing(ImageOutput(0))
;             For y = 0 To ddssize\y-1
;               For x = 0 To ddssize\x-1
;                 Plot(x,y,PeekL(*imageMem+(x+y* (ddssize\x))*4))
;               Next
;               WindowEvent()
;             Next
;             StopDrawing()
;             ResizeImage(0,width,height,#PB_Image_Smooth)
;             If(StartDrawing(TextureOutput(tex)))
;               DrawImage(ImageID(0),0,0)
;               StopDrawing()
;             EndIf
;           EndIf
;           FreeImage(0)
;         EndIf
    ;FreeMemory(*imageMem)
    ProcedureReturn tex
  EndIf
  ProcedureReturn 0     
 EndProcedure
   
    
    
; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 201
; FirstLine = 187
; Folding = -
; EnableXP