IncludeFile "ddsUnpack.pbi"

If OpenWindow(0, 100, 200, 550, 550, "2D Drawing Test")

  ; Create an offscreen image, with a green circle in it.
  ; It will be displayed later
  ;
 
  
  ;
  ; This is the 'event loop'. All the user actions are processed here.
  ; It's very easy to understand: when an action occurs, the Event
  ; isn't 0 and we just have to see what have happened...
  ;
  *imagedata = AllocateMemory(512*512*4)
  OpenDDS("C:\Program Files (x86)\Steam\steamapps\common\cyubeVR\cyubeVR\Mods\Blocks\Dark Wood E-W\Textures\left_small.dds", *imagedata)
   If CreateImage(0, 512, 512)
    If StartDrawing(ImageOutput(0))
      For y = 0 To 511
        For x = 0 To 511
          Plot(x,y,PeekL(*imagedata+(x+y*512)*4))
        Next
      Next
      
      StopDrawing()
     ResizeImage(0,128,128,#PB_Image_Smooth)
    EndIf
  EndIf

  ; Create a gadget to display our nice image
  ;  
  ImageGadget(0, 0, 0, 512, 512, ImageID(0))
  
      
  Repeat
    Event = WaitWindowEvent() 
  Until Event = #PB_Event_CloseWindow  ; If the user has pressed on the window close button
  
EndIf

End   ; All the opened windows are closed automatically by PureBasic
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 25
; EnableXP