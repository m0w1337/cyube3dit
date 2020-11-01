Procedure AsyncBuildChunk(chunknum, x, y, chunkx, chunky)
  startz.f = 0
  If(Not IsStaticGeometry(Chunknum))
    CreateStaticGeometry(Chunknum, 32, 800, 32, #True)
  EndIf
  prevblock = -1
  For z = 0 To 799
      If(CurrChunkData(x,y,z) <> prevblock Or prevblock > 5)
        If(prevblock > -1)
           If(IsEntity(prevblock))
             AddStaticGeometryEntity(Chunknum, EntityID(prevblock), (x*0.5-15) + chunkx,startz+(scale-1)*0.25,(y*0.5-16) + chunky,1,scale,1)
           ElseIf(prevblock = 15)
             light = CreateLight(#PB_Any, RGB(255, 255, 150), (x*0.5-15) + chunkx,startz+(scale-1)*0.25,(y*0.5-16) + chunky)
              LightAttenuation(light,25,1.5)
           ElseIf(prevblock <> 3)
             AddStaticGeometryEntity(Chunknum, EntityID(999), (x*0.5-15) + chunkx,startz+(scale-1)*0.25,(y*0.5-16) + chunky,1,scale,1)
           EndIf
        EndIf
        startz = z*0.5
        scale = 1
      Else
        scale = scale + 1
      EndIf
      prevblock = CurrChunkData(x,y,z)
  Next
  If(prevblock > -1)
    If(IsEntity(prevblock))
      AddStaticGeometryEntity(Chunknum, EntityID(prevblock), (x*0.5-15) + chunkx,startz+(scale-1)*0.25,(y*0.5-16) + chunky,1,scale,1)
    ElseIf(prevblock <> 3)
      AddStaticGeometryEntity(Chunknum, EntityID(999), (x*0.5-15) + chunkx,startz+(scale-1)*0.25,(y*0.5-16) + chunky,1,scale,1)
    EndIf
  EndIf
EndProcedure


Procedure AsyncBuildChunkVertices(chunknum, x, y, chunkx, chunky)
  startz.f = 0
  If(Not IsStaticGeometry(Chunknum))
    CreateStaticGeometry(Chunknum, 32, 800, 32, #True)
  EndIf
  prevblock = -1
  For z = 0 To 799
      If(CurrChunkData(x,y,z) <> prevblock Or prevblock > 5)
        If(prevblock > -1)
           If(IsEntity(prevblock))
             AddStaticGeometryEntity(Chunknum, EntityID(prevblock), (x*0.5-15) + chunkx,startz+(scale-1)*0.25,(y*0.5-16) + chunky,1,scale,1)
           ElseIf(prevblock = 15)
             ;light = CreateLight(#PB_Any, RGB(255, 255, 150), (x*0.5-15) + chunkx,startz+(scale-1)*0.25,(y*0.5-16) + chunky)
              ;LightAttenuation(light,25,1.5)
           ElseIf(prevblock <> 3)
             AddStaticGeometryEntity(Chunknum, EntityID(999), (x*0.5-15) + chunkx,startz+(scale-1)*0.25,(y*0.5-16) + chunky,1,scale,1)
           EndIf
        EndIf
        startz = z*0.5
        scale = 1
      Else
        scale = scale + 1
      EndIf
      prevblock = CurrChunkData(x,y,z)
  Next
  If(prevblock > -1)
    If(IsEntity(prevblock))
      AddStaticGeometryEntity(Chunknum, EntityID(prevblock), (x*0.5-15) + chunkx,startz+(scale-1)*0.25,(y*0.5-16) + chunky,1,scale,1)
    ElseIf(prevblock <> 3)
      AddStaticGeometryEntity(Chunknum, EntityID(999), (x*0.5-15) + chunkx,startz+(scale-1)*0.25,(y*0.5-16) + chunky,1,scale,1)
    EndIf
  EndIf
EndProcedure
; IDE Options = PureBasic 5.60 (Windows - x64)
; CursorPosition = 33
; Folding = -
; EnableXP