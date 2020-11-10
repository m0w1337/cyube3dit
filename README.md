# cyube3dit
*"CyubeVR swiss army knife"*

**cyube3dit is a non-VR world editor tool for the virtual reality game [cyubeVR](https://www.cyubevr.com)**



# Installation and first start
1. Download the latest release here:
[![Download here!](https://cdn.discordapp.com/attachments/597106606643216385/775474419093995550/68747470733a2f2f63646e2e617373697374616e742e6d6f652f696d616765732f4d6f64417373697374616e742f49636f6e.svg)](https://github.com/m0w1337/cyube3dit/releases)

2. Unpack the .zip package to any folder with write permission.
3. Doubleclick the executable.

# User interface
The Application will start as fullscreen window loading all installed custom blocks and preparing proper textures to display them accordingly. This process can be observed via the (maybe only very short) progress window, that also tells you how many custom blocks are loaded so far. The loading will be cached, so expect it to be only slow at the first start of the tool. Once this is done the application will start to load chunks from the last world you left, or the first world it finds within your save directory.

The Main screen you will land on is probably the most basic one you can imagine, just a viewport displaying your world, a menu bar with some properties and a Info Box overlay on the left top of the viewport.

![Main screen](http://cyube3dit.el-wa.org/screen0.jpg)

# Info box
The Info Box is telling you various information depending on the current usage mode:
* The number of loaded chunks
* Your current location in meters
* The ID of the chunk you are standing on.
* Quick tips on how to use the active tool (Insert or Copy)

# Viewport
The viewport is your main working area. Here you can navigate through the world and position your schematic toolbox. World movement is abolutely without any restrictions, so you will be able to freely move through walls and beyond world borders to investigate everything to your liking.

Flying through the world is done via the following commands:
* `W,A,S,D` Keys for movement
* Shift + `W,A,S,D` Keys for fast movement
* `R, F` to move the camera straight up/down
* Click and hold the left mousebutton whithin the viewport to use the mouse for rotating the view.
Press `P` at any time to pause, or resume the chunkloader. This might be helpful it chunkloading results in frame drops.

**While the Pick/Place tool is active:**

* Click on a plane of the tool to drag it for moving along this Plane (as the arrows on the tool indicate)
* While dragging the toolbox you can use the mousewheel to move the box in the Normal direction of the plane (Move it towards you and away from you).
* ONLY IN COPY MODE: Hold shift while draging the Toolbox to resize it. Shift scroll to resize in normal direction.
* ONLY IN COPY MODE: The camera viewing angle is fixed to directly hold the toolbox in the center of view. And the movement is restricted, so that you can not fly "inside" the toolbox to make sure it is visible at all times.

# Menu bar
With the menu bar all necessary settings and tools are available at any time. The options are split into three groups:
* File
* World
* Visuals
![File dropdown menu](http://cyube3dit.el-wa.org/file.jpg)

# File - Load Schematic
Here you will have the possibility to load a previously generates schematic file (*.cySch) into the currently active world. Once you chose the schematic from disc, it will spawn before your current position. It might spawn (partly) invisible behind walls depending on whewre you look at.

After spawn you will see the loaded cube surrounded by the toolbox cube, outlining the schematic size. To move the object you first have to move the Tool block by dragging. Once the toolblock sits at the desired position, hit enter tu move the actual schematic content. You can do this as often as you need to find an appropriate spot. Nothing will be written to the world at any time during this process.

Once you found the final spot to insert the schematic, and want to write the changes to your world hit Ctrl+S. Now all changed chunks of the world will disappear and reload (if chunkloading is currently running, press "P" to pause/resume chunkloading)

If you want to abort the process just hit "Escape" and the schematic preview as well as the Toolbox will go away.

# File - Save Schematic Cube
Here you will have the possibility to select a portion of your world (up to 255x255x255 blocks) to be saved as schematic file (*.cySch).

The tool block will spawn in front of you, catching the camera rotation to keep it in the center of the viewport for your convenience. You can now click and drag the tool block to move it to the place you want to save. Resizing the toolblock is possible with holding shift while draging.

Once you found the final spot and size to save, hit enter and you will be able to select a destination to save the file to.

If you want to abort the process just hit "Escape" and the Toolbox will go away releasing your camera again.

# File - Quit
Nothing to say here.
![World dropdown menu](http://cyube3dit.el-wa.org/world.jpg)

**World - Active world**
This menu will present you a list of all worlds found within your cyubeVR save directory. You can switch worlds by simply clicking them. Be aware, that changing the world will always spawn you at the current player position of this world.

**World - Set Playerposition**
With this option you can override the in game player postition with the current player position. Can be very helpful to teleport over long distances, as movement in the editor is way faster than in the game. Be Aware though, as the editor does not have any collision detection it is easy to set the playerposition within solid structures, which can lead to undefined behaviour in game.
![Visuals dropdown menu](http://cyube3dit.el-wa.org/visuals.jpg)

**Visuals - Visible Chunkborders**
This will draw black lines where chunks end, so you can always see the borders of chunks, nice for debugging. And to keep a feeling for dimensions.

**Visuals - Narrow render Height**
This option will limit all future loaded chunks to height between 50m and 125m (absolute Z-height) This option will be enhanced with a variable band to be able to cut the world at certain heights and see what's there. It also increases chunk drawing speed when there are huge mountains.

**Visuals - Shadows**
By default no shadows are rendered to the world, but if you'd like (and have enough performance) you can add simple, or even more ressource hungry shadows to your view.
The World will rebuild completely when changing this setting!
Visuals - Make World surface visible from inside blocks
This lenghty option will add more vertices to the world, so that you will see the world outer surface even when the camera is "inside" solid world portions, nice to investigate the cave system, but comes with a performance cost.

**Visuals - Draw distance**
Here you can set the chunk-count at which the chunkloader comes to rest and the distance, when far chunks are being deleted. Choose betweenhort, medium and far as you prefer. With the option to pause/resume the chunkloader at any time and keeping in mind, that the chunkloader will always spiralize around the current camera position this gives the possibility to load exactly the portions of the world you need.
Dynamic Custom Block Database
In order to be able to view custom block information, even for blocks that are not present in the current installation, the tool automatically builds and updates a online custom block database.
This Database will hold the block information of all users that allow the application to communicate via a TCP connection on port 3306 (mysql).

The outcome is publicly available here: [Dynamic CyubeVR Custom block list](http://cyube3dit.el-wa.org/index.php?action=customblocks)
