struct VRageConfig
(

	/*Static Options */
	VRageConfigDir = GetDir #plugcfg+ @"\VRageUtilities",
	VRageConfigFile = VRageConfigDir + @"\MyVRageCfg.ini",

	/*configureable User Paths*/
	PathFBXImporter = " ",
	PathHavokContentTools = " ",
	PathMwmBuilder = " ",
	PathTextures = " ",
	PathModSDK = " ",
	UseGameTextures = False,
	TextureType = 1,
	PathGame = " ",

	fn save =(
		try (
			makedir VRageConfigDir
		)
		catch (
			messageBox title:"Permission Error!"
		)

		setINISetting VRageConfigFile "Directories" "MwMBuilder" PathMwmBuilder
		setINISetting VRageConfigFile "Directories" "FBXImporter" PathFBXImporter
		setINISetting VRageConfigFile "Directories" "HavokContentTools" PathHavokContentTools
		setINISetting VRageConfigFile "Directories" "MwMBuilder" PathMwmBuilder
		setINISetting VRageConfigFile "Directories" "TexturePath" PathTextures
		setINISetting VRageConfigFile "Directories" "ModSDK" PathModSDK
		setINISetting VRageConfigFile "Textures" "TextureType" (TextureType as string)
		setINISetting VRageConfigFile "Directories" "pathgame" PathGame
		setINISetting VRageConfigFile "Textures" "UseGameTextures" (if UseGameTextures then "1" else "0")
		
		"Teststring"
	),

	fn load =(

		if (doesFileExist VRageConfigFile) then (
			PathFBXImporter = if (tmp =getINISetting VRageConfigFile "Directories" "FBXImporter") != undefined then tmp else "" 
			PathHavokContentTools = if (tmp = getINISetting VRageConfigFile "Directories" "HavokContentTools") != undefined then tmp else "" 
			PathMwmBuilder = if (tmp = getINISetting VRageConfigFile "Directories" "MwMBuilder") != undefined then tmp else "" 
			PathTextures = if (tmp = getINISetting VRageConfigFile "Directories" "TexturePath") != undefined then tmp else "" 
			PathModSDK = if (tmp = getINISetting VRageConfigFile "Directories" "ModSDK") != undefined then tmp else "" 
			UseGameTextures = (getINISetting VRageConfigFile "Textures" "UseGameTextures") == "1"
			
			TextureType = try (getINISetting VRageConfigFile "Textures" "TextureType" as integer) catch 1

			PathGame =  if (tmp = getINISetting VRageConfigFile "Directories" "pathgame") != undefined then tmp else "" 
		)
		else (
			PathFBXImporter = " "
			PathHavokContentTools = " "
			PathMwmBuilder = " "
			PathTextures = " "
			PathModSDK = ""
			UseGameTextures = False
			TextureType = 1
			PathGame = ""
		)
	),

	fn gInt prop =(

		(getProperty VRageConfig (name as name))

	),
	
	fn gFloat prop =(
		(getProperty VRageConfig (name as name)) as float
	)

)

global MyVRageCfg = VRageConfig()
MyVRageCfg.load()

global VRageTexTypes = #(".dds", ".tif", ".png", ".tga", ".jpg")
sort VRageTexTypes

/* has to be global to be closable from anywhere */
global MyVRageCfgFloater

fn Vrage_LaunchGame =(
	
	if MyVRageCfg.PathGame != "" and doesDirectoryExist MyVRageCfg.PathGame then (
		executeables = getFiles (MyVRageCfg.PathGame + "*Engineers.exe")
		if executeables.count == 0 then (
			dirs = getDirectories (MyVRageCfg.PathGame + "\\*")
			
			for d in dirs do join executeables (getFiles (d + "*Engineers.exe"))
				
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
		button btn_CFgHelp "Help / Info" width:100 height:25 \
		toolTip:"---" align:#right 
	)

	rollout VrageUtils_CfgTools "Tools" width:210 height:400
	(
		label lbl_PathFbx  "FBXImporter:"align:#left across:2
		button btn_PathFBXImp MyVRageCfg.PathFBXImporter width:400 height:25 align:#right \
			tooltip:" path to the executable of FbxImporter" 
			on btn_PathFBXImp pressed do (
				FilePath = getOpenFileName  types:"Executable(*.exe)|*.exe|All|*.*|"
				if(FilePath != undefined ) do (
					btn_PathFBXImp.text = MyVRageCfg.PathFBXImporter  = FilePath 
					MyVRageCfg.save()
				)
			)
			on btn_PathFBXImp rightclick do try (shellLaunch (getFilenamePath MyVRageCfg.PathFBXImporter) "") catch()
				
		label lbl_PathHavok  "HavokContentTools:"align:#left across:2
		button btn_PathHavok MyVRageCfg.PathHavokContentTools width:400 height:25 align:#right \
			tooltip:" path to the installation directory of HavokContentTools"
			on btn_PathHavok pressed do (
				FilePath = getSavePath caption:"Test path..."
				if(FilePath != undefined ) do (
					btn_PathHavok.text = MyVRageCfg.PathHavokContentTools = FilePath
					MyVRageCfg.save()
				)
			)
			on btn_PathHavok rightclick do try (shellLaunch (getFilenamePath MyVRageCfg.PathHavokContentTools) "") catch()

		label lbl_PathMwmBuilder "MWMBuilder:"align:#left across:2
		button btn_PathMwmBuilder  MyVRageCfg.PathMwmBuilder width:400 height:25 align:#right
			tooltip:" path to the MwmBuilder exceutable"

			on btn_PathMwmBuilder pressed do (
				FilePath  = getOpenFileName  types:"Executable(*.exe)|*.exe|All|*.*|"
				if(FilePath != undefined ) do (
					btn_PathMwmBuilder.text = MyVRageCfg.PathMwmBuilder = FilePath
					MyVRageCfg.save()
				)
			)
			on btn_PathMwmBuilder rightclick do try (shellLaunch (getFilenamePath MyVRageCfg.PathMwmBuilder) "") catch()
				
	)
	
	rollout VrageUtils_CfgTextures "Textures" width:210 height:400	
	(
		label lbl_PathTextures  "Texture Directory:"align:#left across:2
		button btn_PathTextures MyVRageCfg.PathTextures width:400 height:25 align:#right enabled:(not MyVRageCfg.UseGameTextures)
			tooltip:"Path to your converted \\Textures\\* Folder"

			on btn_PathTextures pressed do (
				FilePath   = getSavePath caption:"Test path..."
					if(FilePath != undefined ) do ( 
					btn_PathTextures.text = MyVRageCfg.PathTextures = FilePath
					MyVRageCfg.save()
				)
			)
			on btn_PathTextures rightclick do try (shellLaunch MyVRageCfg.PathTextures "") catch()

		label lbl_textureType "Texture Format:" align:#right offset:[120,0] across:3 
		dropdownlist ddl_TexType "" items:VrageTexTypes enabled:(not MyVRageCfg.UseGameTextures) selection:MyVRageCfg.TextureType width:60 align:#right
			on ddl_TexType selected sel do (
				MyVRageCfg.TextureType = ddl_TexType.selection
				MyVRageCfg.save()
			)
			
		checkbutton cbn_UseGameTextures "Use Game Textures" align:#right width:150 height:25 checked:MyVRageCfg.UseGameTextures
			tooltip:"Check if you want to use DDS Textures straight from the Game files" 
			on cbn_UseGameTextures changed state do (
				if not (doesDirectoryExist MyVRageCfg.PathGame) then (
					state = False
				)
				
				for c in #(ddl_TexType, btn_PathTextures) do c.enabled = not state
				MyVRageCfg.UseGameTextures = state
				MyVRageCfg.save()
			)
			
		button btn_ConvertTxt "Texture Convert Tool" width:150 height:25 toolTip:"Run the Bulk Texture Converter to convert the Game textures to the chosen format." align:#right  offset:[0,15]  
			on btn_ConvertTxt pressed do (
				--TODO: Shell Launch BulkTextureConverter.exe "switches go here (In Theory)"
				--TODO: Alternately use DosCommand/HiddenDosCommand
				--REF: <full path to your texconv foldere>\texconv -nologo -ft png <path to the folder where your texture is>/<filename of the texture>
				--Rel. Path from SDK: SpaceEngineersModSDK\Tools\TexturePacking\Tools\texconv.exe
			)
	
	)

	rollout VrageUtils_CfgGame "Game" width:210 height:400	
	(
		label lbl_PathPathModeSDK "ModSDK:" align:#left across:2
		button btn_PathPathModeSDK MyVRageCfg.PathModSDK width:400 height:25 align:#right tooltip:"Path to the SE/ME PathModSDK directory"
			on btn_PathPathModeSDK pressed do (
				FilePath   = getSavePath caption:"Test path..."
				if(FilePath != undefined ) do ( 
					btn_PathPathModeSDK.text = MyVRageCfg.PathModSDK = FilePath
					MyVRageCfg.save()
				)
			)
			on btn_PathPathModeSDK rightclick do try (shellLaunch MyVRageCfg.PathModSDK "") catch()

		label lbl_PathGame "Game Directory:" align:#left across:2
		button btn_PathGame MyVRageCfg.PathGame width:400 height:25 align:#right tooltip:"Path to the Space/Medieval Engineers directory"
			on btn_pathgame pressed do (
				filepath   = getsavepath caption:"test path..."
				if(filepath != undefined ) do ( 
					btn_pathgame.text = MyVRageCfg.pathgame = filepath
					MyVRageCfg.save()
				)
			)
			on btn_pathgame rightclick do try (shellLaunch MyVRageCfg.PathGame "") catch()
			
		button btn_LaunchGame "Launch Game" width:150 height:25 toolTip:"Launches the Game" align:#right  offset:[0,15]
			on btn_LaunchGame pressed do (
				Vrage_LaunchGame()
			)
	)
	
	try (closeRolloutFloater MyVRageCfgFloater) catch ()
	MyVRageCfgFloater = newRolloutFloater  "VRage Utilities Config" 600 500 20 130 
	addRollout VrageUtils_CfgScene MyVRageCfgFloater
	addRollout VrageUtils_CfgTools MyVRageCfgFloater
	addRollout VrageUtils_CfgTextures MyVRageCfgFloater
	addRollout VrageUtils_CfgGame MyVRageCfgFloater
)

--OpenSettings()

