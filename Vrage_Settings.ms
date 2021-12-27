




struct VRageConfig
(

	/*Static Options */
	VRageConfigDir = GetDir #plugcfg + @"\VRageUtilities",
	VRageConfigFile = VRageConfigDir + @"\MyVRageCfg.ini",
	VRageScriptsDir = GetDir #userScripts + "\\VRageToolbox\\",
	/*configureable User Paths*/
	PathToolsFolder = "",
	PathHavokContentTools = " ",
	PathFBXImporter = " ",
	PathMwmBuilder = " ",
	PathTextures = " ",
	PathModSDK = " ",
	UseGameTextures = False,
	TextureType = 5,
	PathGame = " ",
	UsePbrMats = True, --Needs GUI
	DefaultThumbnail = VrageConfigDir + "\\MaterialThumbnails\\" + "NoThumbnail.jpg",

	/*Export Settings */
	Exp_StartGameAfter = False, --start game after export for testing for example
	Exp_ToModFolder = false, -- export block directly to mod folder? if no extra path?
	Exp_GenerateBlockDef = false, -- Flag is blockdef .sbc sall be generated
	Exp_DestPath = "", -- Path if ExptoModfolder == false
	Exp_ModName = "", -- current Modname for folder generation (may maxscene as default?)
	

	fn save = (
		try (
			makedir VRageConfigDir
		)
		catch (
			messageBox title:"Permission Error!"
		)
		
		if ( VRageScriptsDir ) != "" then (
			if getDirectories ( VRageScriptsDir ) != undefined then (	
				PathFBXImporter = if ( tmp = getFiles ( VRageScriptsDir + "\\Vrage_Tools\\FbxImporter.exe" ) ).count != 0 then tmp[1] else ""
				PathMwmBuilder = if ( tmp = getFiles ( VRageScriptsDir + "\\Vrage_Tools\\MWMBuilder\\MwmBuilder.exe" ) ).count != 0 then ( VRageScriptsDir + "\\Vrage_Tools\\MWMBuilder\\MwmBuilder.exe" ) else ""
				PathTextures = if ( tmp = getDirectories ( PathToolsFolder + "\\Textures" ) ).count != 0 then ( PathToolsFolder ) else ""
			)
		)
		setINISetting VRageConfigFile "Directories" "Toolsfolder" PathToolsFolder
		--setINISetting VRageConfigFile "Directories" "FBXImporter" PathFBXImporter
		--setINISetting VRageConfigFile "Directories" "MwMBuilder" PathMwmBuilder
		--setINISetting VRageConfigFile "Directories" "TexturePath" PathTextures
		
		setINISetting VRageConfigFile "Directories" "ModSDK" PathModSDK
		setINISetting VRageConfigFile "Directories" "HavokContentTools" PathHavokContentTools
		setINISetting VRageConfigFile "Textures" "TextureType" ( TextureType as string )
		setINISetting VRageConfigFile "Directories" "pathgame" PathGame
		setINISetting VRageConfigFile "Textures" "UseGameTextures" ( if UseGameTextures then "1" else "0" )
		setINISetting VRageConfigFile "Textures" "UsePbrMats" ( if UsePbrMats then "1" else "0" )

		setINISetting VRageConfigFile "Export" "Exp_StartGameAfter" ( if Exp_StartGameAfter then "1" else "0" )
		setINISetting VRageConfigFile "Export" "Exp_ToModFolder" ( if Exp_ToModFolder then "1" else "0" )
		setINISetting VRageConfigFile "Export" "Exp_GenerateBlockDef" ( if Exp_GenerateBlockDef then "1" else "0" )
		setINISetting VRageConfigFile "Export" "Exp_DestPath" Exp_DestPath
		setINISetting VRageConfigFile "Export" "Exp_ModName" Exp_ModName

		
	),

	fn load = (

		if ( doesFileExist VRageConfigFile ) then (
			
			PathToolsFolder = if ( tmp = getINISetting VRageConfigFile "Directories" "Toolsfolder" ) != undefined then tmp else "" 
			if ( PathToolsFolder ) != "" then (
				if getDirectories ( PathToolsFolder ) != undefined then (	
					PathFBXImporter = if ( tmp = getFiles ( VRageScriptsDir + "\\Vrage_Tools\\FbxImporter.exe" ) ).count != 0 then tmp[1] else ""
					PathMwmBuilder = if ( tmp = getFiles ( VRageScriptsDir + "\\Vrage_Tools\\MWMBuilder\\MwmBuilder.exe" ) ).count != 0 then ( PathToolsFolder + "\\Vrage_Tools\\MWMBuilder\\MwmBuilder.exe" ) else ""
					PathTextures = if ( tmp = getDirectories ( PathToolsFolder + "\\Textures" ) ).count != 0 then PathToolsFolder else ""
				)
			)

			PathHavokContentTools = if ( tmp = getINISetting VRageConfigFile "Directories" "HavokContentTools" ) != undefined then tmp else "" 
			--PathHavokContentTools =   if (tmp = getFiles (PathHavokContentTools + "\\hctStandAloneFilterManager.exe")) != undefined then PathHavokContentTools  else ""

			PathModSDK = if ( tmp = getINISetting VRageConfigFile "Directories" "ModSDK" ) != undefined then tmp else "" 
			UseGameTextures = ( getINISetting VRageConfigFile "Textures" "UseGameTextures" ) == "1"
			UsePbrMats = ( getINISetting VRageConfigFile "Textures" "UsePbrMats" ) == "1"

			TextureType = try ( getINISetting VRageConfigFile "Textures" "TextureType" as integer ) catch 1
			PathGame = if ( tmp = getINISetting VRageConfigFile "Directories" "pathgame" ) != undefined then tmp else "" 

			Exp_StartGameAfter = ( getINISetting VRageConfigFile "Export" "Exp_StartGameAfter" ) == "1"
			Exp_ToModFolder = ( getINISetting VRageConfigFile "Export" "Exp_ToModFolder" ) == "1"
			Exp_GenerateBlockDef = ( getINISetting VRageConfigFile "Export" "Exp_GenerateBlockDef" ) == "1"
			Exp_DestPath = if ( tmp = getINISetting VRageConfigFile "Export" "Exp_DestPath" ) != undefined then tmp else ""
			Exp_ModName = if ( tmp = getINISetting VRageConfigFile "Export" "Exp_ModName" ) != undefined then tmp else ""
		)
		else (
			PathToolsFolder = ""
			PathFBXImporter = " "
			PathHavokContentTools = " "
			PathMwmBuilder = " "
			PathTextures = " "
			PathModSDK = ""
			UseGameTextures = False
			TextureType = 1
			PathGame = ""

			Exp_StartGameAfter = False 
			Exp_ToModFolder = false 
			Exp_GenerateBlockDef = false 
			Exp_DestPath = "" 
			Exp_ModName = "" 
		)
	),

	fn gInt prop = (

		( getProperty VRageConfig ( name as name ) )

	),
	
	fn gFloat prop = (
		( getProperty VRageConfig ( name as name ) ) as float
	)

)


global VrageTextureIO_ConvertSEtoReadable

global MyVRageCfg = VRageConfig()
MyVRageCfg.load()


-- intialize Materiallibrary if its lost...
if Vrage_MaterialThumbRenderer == undefined then
(
	fileIn ( GetDir #userScripts + "\\VRageToolbox\\Vrage_IO\\Vrage_MaterialLibrary.ms" )
	
) 


global VRageTexTypes = #(".dds", ".jpg", ".png", ".tga", ".tif")

/* has to be global to be closable from anywhere */
global MyVRageCfgFloater

fn Vrage_LaunchGame = (
	
	if MyVRageCfg.PathGame != "" and doesDirectoryExist MyVRageCfg.PathGame then (
		executeables = getFiles ( MyVRageCfg.PathGame + "*Engineers.exe" )
		if executeables.count == 0 then (
			dirs = getDirectories ( MyVRageCfg.PathGame + "\\*" )
			
			for d in dirs do join executeables ( getFiles ( d + "*Engineers.exe" ) )
			
			if executeables.count > 0 then (
				ShellLaunch executeables[1] ""
			)
			else (
				--TODO: Messagebox to notify the user that no Game.exe could be found
			)
		)
		else (
			ShellLaunch executeables[1] ""
		)
	)
)

fn OpenSettings = (
	
	rollout VrageUtils_CfgScene "VRage Utilities - Config" width:210 height:400
	(
		label lbl_text "Configuration Panel for the VRAGE Utilites. \nPlease refer to the setup tutorial if the settings are unclear."	height:30 align:#left across:2
		button btn_CFgHelp "Help / Info" width:50 height:25 align:#right \
		toolTip:"Opens the Documentation/Help" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 17, 17, 17, 17 )

		on btn_CFgHelp pressed  do (ShellLaunch "https://vragetoolbox.ratpool.de/doku.php?id=vrt:settings" "")
	
	)

	rollout VrageUtils_CfgTools "Tools/Paths" width:210 height:400
	(
		label lbl_PathTools "VrageToolbox Utils Folder:" align:#left across:2
		button btn_PathTools MyVRageCfg.PathToolsFolder width:400 height:25 align:#right \
		tooltip:"Path to the Vragetoolbox Folder which has/will contain textures and other custom materials for example" 
		on btn_PathTools pressed do (
			FilePath = getSavePath caption:"Test path..."
			if ( FilePath != undefined ) do (
				btn_PathTools.text = MyVRageCfg.PathToolsFolder = FilePath
				MyVRageCfg.save()
			)
		)
		on btn_PathTools rightclick do try ( shellLaunch ( getFilenamePath MyVRageCfg.PathToolsFolder ) "" ) catch()

		
		label lbl_PathHavok "HavokContentTools:" align:#left across:2
		button btn_PathHavok MyVRageCfg.PathHavokContentTools width:400 height:25 align:#right \
		tooltip:" path to the installation directory of HavokContentTools"
		on btn_PathHavok pressed do (
			FilePath = getSavePath caption:"Test path..."
			if ( FilePath != undefined ) do (
				btn_PathHavok.text = MyVRageCfg.PathHavokContentTools = FilePath
				MyVRageCfg.save()
			)
		)
		on btn_PathHavok rightclick do try ( shellLaunch ( getFilenamePath MyVRageCfg.PathHavokContentTools ) "" ) catch()
		
		label lbl_ToolStatus "Status:" align:#left across:5 tooltip:"Status if the displayed tools have benn found in the defined paths.(green = yes/red=no) "
		hyperlink Chbx_Textures "Textures" Enabled:false color: ( color 240 0 0 ) align:#right
		hyperlink Chbx_FBXImporter "FBXImporter" Enabled:false color: ( color 240 0 0 ) align:#right
		hyperlink Chbx_MwMBuilder "MWMBuilder" Enabled:false color: ( color 240 0 0 ) align:#right
		hyperlink Chbx_Havoktools "Havoktools " Enabled:false color: ( color 240 0 0 ) align:#right
		
		timer clock "testClock" interval:500 --tick  every 2 sec
		on clock tick do
		(
			if getDirectories ( MyVRageCfg.PathToolsFolder ) != undefined then (	
				MyVRageCfg.PathTextures = if ( tmp = getDirectories ( MyVRageCfg.PathToolsFolder + "\\Textures" ) ).count != 0 then ( MyVRageCfg.PathToolsFolder ) else ""	
			)
			MyVRageCfg.PathFBXImporter = if ( tmp = getFiles ( MyVRageCfg.VRageScriptsDir + "\\Vrage_Tools\\FbxImporter.exe" ) ).count != 0 then tmp[1] else ""
			MyVRageCfg.PathMwmBuilder = if ( tmp = getFiles ( MyVRageCfg.VRageScriptsDir + "\\Vrage_Tools\\MWMBuilder\\MwmBuilder.exe" ) ).count != 0 then ( MyVRageCfg.VRageScriptsDir + "\\Vrage_Tools\\MWMBuilder\\MwmBuilder.exe" ) else ""
			
			MyVRageCfg.PathHavokContentTools = if ( tmp = getFiles ( MyVRageCfg.PathHavokContentTools + "\\hctStandAloneFilterManager.exe" ) ).count != 0 then MyVRageCfg.PathHavokContentTools else "none"
			if MyVRageCfg.PathFBXImporter != "" then ( Chbx_FBXImporter.color = ( color 0 200 0 ) ) else ( Chbx_FBXImporter.color = ( color 240 0 0 ) )
			if MyVRageCfg.PathMwmBuilder != "" then ( Chbx_MwMBuilder.color = ( color 0 200 0 ) ) else ( Chbx_MwMBuilder.color = ( color 240 0 0 ) )
			if MyVRageCfg.PathTextures != "" then ( Chbx_Textures.color = ( color 0 200 0 ) ) else ( Chbx_Textures.color = ( color 240 0 0 ) )
			if MyVRageCfg.PathHavokContentTools != "none" then ( Chbx_Havoktools.color = ( color 0 200 0 ) ) else ( Chbx_Havoktools.color = ( color 240 0 0 ) ) 
		)
	)
	
	rollout VrageUtils_CfgTextures "Textures" width:210 height:400	
	(
		/*label lbl_textureType "Texture Format:"   across:4 enabled:false
		dropdownlist ddl_TexType "" items:VrageTexTypes selection:MyVRageCfg.TextureType width:60 enabled:false -- enabled:(not MyVRageCfg.UseGameTextures)
			on ddl_TexType selected sel do (
				MyVRageCfg.TextureType = ddl_TexType.selection
				MyVRageCfg.save()
			)
			
		checkbutton cbn_UseGameTextures "Use Game Textures"  width:120 height:25 checked:MyVRageCfg.UseGameTextures
			tooltip:"Check if you want to use DDS Textures straight from the Game files"  enabled:false
			on cbn_UseGameTextures changed state do (
				if not (doesDirectoryExist MyVRageCfg.PathGame) then (
					state = False
				)
				
				for c in #(ddl_TexType) do c.enabled = not state
				MyVRageCfg.UseGameTextures = state
				MyVRageCfg.save()
			)*/
		

		button btn_ConvertTxt "Convert Textures" width:150 height:25 toolTip:"Run the Bulk Texture Converter to convert the Game textures to the 3dsmax readable format." across:3
		on btn_ConvertTxt pressed do 
		(
			if VrageTextureIO_ConvertSEtoReadable == undefined then
			(
				fileIn ( GetDir #userScripts + "\\VRageToolbox\\Vrage_IO\\Vrage_TextureIO.ms" )
			) 
			if queryBox "This will take ~5 minutes or more. \n Do you want to continue?" beep:false title:"VrageToolbox" then VrageTextureIO_ConvertSEtoReadable()
			
		)

		button btn_GenMatThumbs "Generate MaterialThumbnails" width:150 height:25 toolTip:"Re/Generates the Materialthumbnails"
		on btn_GenMatThumbs pressed do 
		(
			if Vrage_MaterialThumbRenderer == undefined then
			(
				fileIn ( GetDir #userScripts + "\\VRageToolbox\\Vrage_IO\\Vrage_MaterialLibrary.ms" )
			) 
			if queryBox "This will take ~5 minutes or more. \n Do you want to continue?" beep:false title:"VrageToolbox" do (
				MyVrageThumbRenderer = Vrage_MaterialThumbRenderer()
				MyVrageThumbRenderer.GenerateMatThumbnails MyVrageMatLib.mat_names
			)
			
		)
		
		on VrageUtils_CfgTextures open do 
		(
			
			--theBmp = (openBitMap  @"C:\Users\patgr\Desktop\Standard_24i.tif")
			--the_bmp.bitmap = theBmp
			--print theBmp.color
			--	btn_ConvertTxt.images =  #(theBmp, undefined, 1,1,1,1,1 )
		) 
	)

	rollout VrageUtils_CfgGame "Game" width:210 height:400	
	(
		label lbl_PathPathModeSDK "ModSDK:" align:#left across:2
		button btn_PathPathModeSDK MyVRageCfg.PathModSDK width:400 height:25 align:#right tooltip:"Path to the SE/ME PathModSDK directory"
		on btn_PathPathModeSDK pressed do (
			FilePath = getSavePath caption:"Test path..."
			if ( FilePath != undefined ) do ( 
				btn_PathPathModeSDK.text = MyVRageCfg.PathModSDK = FilePath
				MyVRageCfg.save()
			)
		)
		on btn_PathPathModeSDK rightclick do try ( shellLaunch MyVRageCfg.PathModSDK "" ) catch()

		label lbl_PathGame "Game Directory:" align:#left across:2
		button btn_PathGame MyVRageCfg.PathGame width:400 height:25 align:#right tooltip:"Path to the Space/Medieval Engineers directory"
		on btn_pathgame pressed do (
			filepath = getsavepath caption:"test path..."
			if ( filepath != undefined ) do ( 
				btn_pathgame.text = MyVRageCfg.pathgame = filepath
				MyVRageCfg.save()
			)
		)
		on btn_pathgame rightclick do try ( shellLaunch MyVRageCfg.PathGame "" ) catch()
		
		button btn_LaunchGame "Launch Game" width:150 height:25 toolTip:"Launches the Game" align:#right offset:[0, 15]
		on btn_LaunchGame pressed do (
			Vrage_LaunchGame()
		)
	)
	
	try ( cui.UnRegisterDialogBar MyVRageCfgFloater ) catch () 
	try ( closeRolloutFloater MyVRageCfgFloater ) catch ()

	Pos = getMaxWindowSize() 
	PosX = Pos[1] / 2 - 300
	MyVRageCfgFloater = newRolloutFloater "VRage Utilities Config" 600 380 PosX 250 
	addRollout VrageUtils_CfgScene MyVRageCfgFloater
	addRollout VrageUtils_CfgTools MyVRageCfgFloater
	addRollout VrageUtils_CfgTextures MyVRageCfgFloater
	addRollout VrageUtils_CfgGame MyVRageCfgFloater

	cui.RegisterDialogBar MyVRageCfgFloater style:#( #cui_floatable, #cui_dock_right , #cui_dock_left ) 
)

--OpenSettings()

