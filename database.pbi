UseMySQLDatabase()
Global mysqlhandle

Procedure ConnectDatabaseThread(nothing)
  mysqlhandle = OpenDatabase(#PB_Any, "host=el-wa.org port=3306 dbname=d034043b", "d034043b", "CyubeVRdbRoot@HansWurscht")
EndProcedure

Procedure ConnectBlockDatabase()
  StatusBarText(0,2,"Connecting to custom block database...")
  StatusBarProgress(0,1,#PB_ProgressBar_Unknown)
  dbconn = CreateThread(@ConnectDatabaseThread(),0)
  While(IsThread(dbconn))
    StatusBarProgressUnknown(0,1)
    WindowEvent()
    Delay(10)
  Wend 
  If(mysqlhandle)
    StatusBarText(0,2,"Custom block database connected!")
  Else
    StatusBarText(0,2,"Could not connect to custom block database!")
  EndIf
  ProcedureReturn mysqlhandle
EndProcedure



Procedure CheckDatabaseUpdate(Database, Query$)
   Result = DatabaseUpdate(Database, Query$)
   If Result = 0
     Debug DatabaseError()
     Debug Query$ + "FAILED"
   EndIf
   ProcedureReturn Result
EndProcedure


Procedure publishCustomBlock(db, id, mode, name.s, author.s)
  SetDatabaseString(db,0,name)
  SetDatabaseString(db,1,author)
  img = ReadFile(#PB_Any,GetLApplicationDataDirectory()+"CyubE3dit\cblock_prev\"+Str(id)+".png",#PB_File_NoBuffering |#PB_File_SharedRead)
  If img
    *imgmem = AllocateMemory(Lof(img))
    FileSeek(img,0)
    ReadData(img,*imgmem,Lof(img))
    SetDatabaseBlob(db,2,*imgmem,Lof(img))
    SetDatabaseString(db,3,name)
    SetDatabaseString(db,4,author)
    SetDatabaseBlob(db,5,*imgmem,Lof(img))
    CloseFile(img)
    CheckDatabaseUpdate(db, "INSERT INTO CustomBlocks (id,name,author,type, preview,hasPrev) VALUES ("+Str(id)+", ?, ?, "+Str(mode)+", ?, 1) ON DUPLICATE KEY UPDATE type = "+Str(mode)+", name = ?, author = ?, preview = ?, hasPrev=1;")
  Else
    SetDatabaseString(db,2,name)
    SetDatabaseString(db,3,author)
    CheckDatabaseUpdate(db, "INSERT INTO CustomBlocks (id,name,author,type,hasPrev) VALUES ("+Str(id)+", ?, ?, "+Str(mode)+", 0) ON DUPLICATE KEY UPDATE type = "+Str(mode)+", name = ?, author = ?, hasPrev=0;")
  EndIf
  
EndProcedure

Procedure publishStdBlock(db, id, mode, name.s, author.s)
  SetDatabaseString(db,0,name)
  SetDatabaseString(db,1,author)
  img = ReadFile(#PB_Any,GetLApplicationDataDirectory()+"CyubE3dit\block_prev\"+Str(id)+".png",#PB_File_NoBuffering |#PB_File_SharedRead)
  If img
    *imgmem = AllocateMemory(Lof(img))
    FileSeek(img,0)
    ReadData(img,*imgmem,Lof(img))
    SetDatabaseBlob(db,2,*imgmem,Lof(img))
    SetDatabaseString(db,3,name)
    SetDatabaseString(db,4,author)
    SetDatabaseBlob(db,5,*imgmem,Lof(img))
    CloseFile(img)
    CheckDatabaseUpdate(db, "INSERT INTO StandardBlocks (id,name,author,type, preview,hasPrev) VALUES ("+Str(id)+", ?, ?, "+Str(mode)+", ?, 1) ON DUPLICATE KEY UPDATE type = "+Str(mode)+", name = ?, author = ?, preview = ?, hasPrev=1;")
  Else
    SetDatabaseString(db,2,name)
    SetDatabaseString(db,3,author)
    CheckDatabaseUpdate(db, "INSERT INTO StandardBlocks (id,name,author,type,hasPrev) VALUES ("+Str(id)+", ?, ?, "+Str(mode)+", 0) ON DUPLICATE KEY UPDATE type = "+Str(mode)+", name = ?, author = ?, hasPrev=0;")
  EndIf
  
EndProcedure

Procedure findCustomBlock(db,id, name.s)
  ret = 0
  If db
    SetDatabaseString(db,0,name)
    DatabaseQuery(db, "SELECT id from CustomBlocks WHERE id = "+Str(id)+" and name = ? and hasPrev = 1;")
    If NextDatabaseRow(db)
      ret = 1
    EndIf
    FinishDatabaseQuery(db)
  EndIf
  ProcedureReturn ret
EndProcedure

Procedure findStdBlock(db,id, name.s)
  ret = 0
  If db
    SetDatabaseString(db,0,name)
    DatabaseQuery(db, "SELECT id from StandardBlocks WHERE id = "+Str(id)+" and name = ? and hasPrev = 1;")
    If NextDatabaseRow(db)
      ret = 1
    EndIf
    FinishDatabaseQuery(db)
  EndIf
  ProcedureReturn ret
EndProcedure

Procedure remoteLoadCustomBlock(db,id, *ret.CBlocks)
  ret = 0
  If db
    DatabaseQuery(db, "SELECT id,name,author,type,preview from CustomBlocks WHERE id = "+Str(id)+";")
    If NextDatabaseRow(db)
      *ret\id = id
      *ret\mode = GetDatabaseLong(db,3)
      *ret\name = GetDatabaseString(db,1)
      size= DatabaseColumnSize(db, 4)
      prevImg = 0
      If size
        *mem = AllocateMemory(size)
        GetDatabaseBlob(db,4,*mem,size)
        prevImg = CatchImage(#PB_Any,*mem)
        ret = 1
      EndIf
      *ret\prev = prevImg
    EndIf
    FinishDatabaseQuery(db)
  EndIf
  ProcedureReturn ret
EndProcedure

Procedure addCustomBlock(cID,async=1)
  CBlocks(Str(cID))\id = cID
  CBlocks()\mode = 1
  CBlocks()\name = "the unknown custom Block"
  CBlocks()\tex(0) = CreateTexture(#PB_Any,256,256)
  If g_CBlockDB
    If Not async
      StatusBarText(0,0,"Gathering information about a not installed custom block, please stand by...")
      UpdateWindow_(StatusBarID(0))
    EndIf
    loadedCBlock.CBlocks
    If remoteLoadCustomBlock(g_CBlockDB,cID, @loadedCBlock)
      CBlocks()\name = loadedCBlock\name
      CBlocks()\prev = loadedCBlock\prev
    EndIf
    If Not async
      StatusBarText(0,0,"Running...")
    EndIf
    
  EndIf
  StartDrawing(TextureOutput(CBlocks()\tex(0)))
  DrawingMode(#PB_2DDrawing_Transparent)
  Box(0,0,256,256,RGB(255,255,255))
  If(IsImage(CBlocks()\prev))
    DrawImage(ImageID(CBlocks()\prev),64,64,128,128)
  EndIf
  DrawText((256-TextWidth("Unknown Block!"))/2,4,"Unknown Block!",RGB(255,0,0))
  DrawText((256-TextWidth("Please Install"))/2,TextHeight(" ")+4,"Please Install",RGB(0,0,0))
  DrawText((256-TextWidth(CBlocks()\name))/2,2*TextHeight(" ")+4,CBlocks()\name,RGB(0,0,0))
  DrawText((256-TextWidth("(Block ID: "+Str(cID)+")"))/2,193,"(Block ID: "+Str(cID)+")",RGB(0,0,0))
  DrawText((256-TextWidth("or CyubeVR won't"))/2,TextHeight(" ")+193,"or CyubeVR won't",RGB(0,0,0))
  DrawText((256-TextWidth("show it correctly."))/2,2*TextHeight(" ")+193,"show it correctly.",RGB(0,0,0))
  StopDrawing()
  CBlocks()\mat(0) = CreateMaterial(#PB_Any,TextureID(CBlocks()\tex(0)))
EndProcedure

; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 30
; FirstLine = 22
; Folding = --
; EnableXP