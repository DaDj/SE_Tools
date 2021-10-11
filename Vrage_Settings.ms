struct VRageConfig
(

	/*Static Options */
	VRageConfigDir = GetDir #plugcfg+ @"\VRageUtilities",
	VRageConfigFile = VRageConfigDir + @"\MyVRageCfg.ini",

	/*configureable User Paths*/
	PathToolsFolder = "",
	PathHavokContentTools = " ",
	PathFBXImporter = " ",
	PathMwmBuilder = " ",
	PathTextures = " ",
	PathModSDK = " ",
	UseGameTextures = False,
	TextureType = 1,
	PathGame = " ",
	UsePbrMats = False, --Needs GUI

	/*Export Settings */
	Exp_StartGameAfter = False, --start game after export for testing for example
	Exp_ToModFolder = false, -- export block directly to mod folder? if no extra path?
	Exp_GenerateBlockDef = false, -- Flag is blockdef .sbc sall be generated
	Exp_DestPath = "", -- Path if ExptoModfolder == false
	Exp_ModName = "", -- current Modname for folder generation (may maxscene as default?)


	fn save =(
		try (
			makedir VRageConfigDir
		)
		catch (
			messageBox title:"Permission Error!"
		)
		
		if (PathToolsFolder) != "" then (
				if getDirectories(PathToolsFolder) != undefined then (	
					PathFBXImporter = if (tmp = getFiles (PathToolsFolder + "\\Tools\\FbxImporter.exe")).count != 0 then tmp[1] else ""
					PathMwmBuilder = if (tmp = getFiles (PathToolsFolder + "\\Tools\\MWMBuilder\\MwmBuilder.exe")).count != 0 then ( PathToolsFolder + "\\Tools\\MWMBuilder\\MwmBuilder.exe" ) else ""
					PathTextures =  if (tmp = getDirectories (PathToolsFolder + "\\Textures")).count != 0 then PathToolsFolder else ""
				)
			)
		setINISetting VRageConfigFile "Directories" "Toolsfolder" PathToolsFolder
		--setINISetting VRageConfigFile "Directories" "FBXImporter" PathFBXImporter
		--setINISetting VRageConfigFile "Directories" "MwMBuilder" PathMwmBuilder
		--setINISetting VRageConfigFile "Directories" "TexturePath" PathTextures
			
		setINISetting VRageConfigFile "Directories" "ModSDK" PathModSDK
		setINISetting VRageConfigFile "Directories" "HavokContentTools" PathHavokContentTools
		setINISetting VRageConfigFile "Textures" "TextureType" (TextureType as string)
		setINISetting VRageConfigFile "Directories" "pathgame" PathGame
		setINISetting VRageConfigFile "Textures" "UseGameTextures" (if UseGameTextures then "1" else "0")
		setINISetting VRageConfigFile "Textures" "UsePbrMats" (if UsePbrMats then "1" else "0")

		setINISetting VRageConfigFile "Export" "Exp_StartGameAfter" (if Exp_StartGameAfter then "1" else "0")
		setINISetting VRageConfigFile "Export" "Exp_ToModFolder" (if Exp_ToModFolder then "1" else "0")
		setINISetting VRageConfigFile "Export" "Exp_GenerateBlockDef" (if Exp_GenerateBlockDef then "1" else "0")
		setINISetting VRageConfigFile "Export" "Exp_DestPath" Exp_DestPath
		setINISetting VRageConfigFile "Export" "Exp_ModName" Exp_ModName

		
	),

	fn load =(

		if (doesFileExist VRageConfigFile) then (
			
			PathToolsFolder =  if (tmp =getINISetting VRageConfigFile "Directories" "Toolsfolder") != undefined then tmp else ""   
			if (PathToolsFolder) != "" then (
				if getDirectories(PathToolsFolder) != undefined then (	
					PathFBXImporter = if (tmp = getFiles (PathToolsFolder + "\\Tools\\FbxImporter.exe")).count != 0 then tmp[1] else ""
				PathMwmBuilder = if (tmp = getFiles (PathToolsFolder + "\\Tools\\MWMBuilder\\MwmBuilder.exe")).count != 0 then ( PathToolsFolder + "\\Tools\\MWMBuilder\\MwmBuilder.exe" ) else ""
					PathTextures =  if (tmp = getDirectories (PathToolsFolder + "\\Textures")).count != 0 then PathToolsFolder else ""
				)
			)

			PathHavokContentTools = if (tmp = getINISetting VRageConfigFile "Directories" "HavokContentTools") != undefined then tmp else "" 
			--PathHavokContentTools =   if (tmp = getFiles (PathHavokContentTools + "\\hctStandAloneFilterManager.exe")) != undefined then PathHavokContentTools  else ""

			PathModSDK = if (tmp = getINISetting VRageConfigFile "Directories" "ModSDK") != undefined then tmp else "" 
			UseGameTextures = (getINISetting VRageConfigFile "Textures" "UseGameTextures") == "1"
			UsePbrMats = (getINISetting VRageConfigFile "Textures" "UsePbrMats") == "1"

			TextureType = try (getINISetting VRageConfigFile "Textures" "TextureType" as integer) catch 1
			PathGame =  if (tmp = getINISetting VRageConfigFile "Directories" "pathgame") != undefined then tmp else "" 

			Exp_StartGameAfter =  (getINISetting VRageConfigFile "Export" "Exp_StartGameAfter") == "1"
			Exp_ToModFolder = (getINISetting VRageConfigFile "Export" "Exp_ToModFolder") == "1"
			Exp_GenerateBlockDef = (getINISetting VRageConfigFile "Export" "Exp_GenerateBlockDef") == "1"
			Exp_DestPath = if (tmp = getINISetting VRageConfigFile "Export" "Exp_DestPath") != undefined then tmp else ""
			Exp_ModName = if (tmp = getINISetting VRageConfigFile "Export" "Exp_ModName")  != undefined then tmp else ""
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

		label lbl_PathTools  "VrageToolbox Utils Folder:"align:#left across:2
		button btn_PathTools  MyVRageCfg.PathToolsFolder width:400 height:25 align:#right \
			tooltip:"Path to the Vragetoolbox Folder which has the external tools and Utilities" 
			on btn_PathTools pressed do (
				FilePath = getSavePath caption:"Test path..."
				if(FilePath != undefined ) do (
					btn_PathTools.text = MyVRageCfg.PathToolsFolder = FilePath
					MyVRageCfg.save()
				)
			)
			on btn_PathTools rightclick do try (shellLaunch (getFilenamePath MyVRageCfg.PathToolsFolder) "") catch()

				
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
		
		label lbl_ToolStatus  "Status:"align:#left across:5 tooltip:"Status if the displayed tools have benn found in the defined paths.(green = yes/red=no) "
		hyperlink Chbx_Textures "Textures"  Enabled:false  color: (color 240 0 0)   align:#right
		hyperlink Chbx_FBXImporter "FBXImporter"  Enabled:false  color: (color 240 0 0)   align:#right
		hyperlink Chbx_MwMBuilder "MWMBuilder"  Enabled:false color: (color 240 0 0)   align:#right
		hyperlink Chbx_Havoktools "Havoktools "  Enabled:false color: (color 240 0 0)   align:#right
				
		timer clock "testClock" interval:1000 --tick  every 2 sec
	  	on clock tick do
	  	(
				if getDirectories(MyVRageCfg.PathToolsFolder) != undefined then (	
					MyVRageCfg.PathFBXImporter = if (tmp = getFiles (MyVRageCfg.PathToolsFolder + "\\Tools\\FbxImporter.exe")).count != 0 then tmp[1] else ""
					MyVRageCfg.PathMwmBuilder = if (tmp = getFiles (MyVRageCfg.PathToolsFolder + "\\Tools\\MWMBuilder\\MwmBuilder.exe")).count != 0 then ( MyVRageCfg.PathToolsFolder + "\\Tools\\MWMBuilder\\MwmBuilder.exe" ) else ""
					MyVRageCfg.PathTextures  =  if (tmp = getDirectories (MyVRageCfg.PathToolsFolder + "\\Textures")).count != 0 then MyVRageCfg.PathToolsFolder else ""	
				)
		
			MyVRageCfg.PathHavokContentTools =   if (tmp = getFiles (MyVRageCfg.PathHavokContentTools + "\\hctStandAloneFilterManager.exe")).count != 0 then MyVRageCfg.PathHavokContentTools  else "none"
			if MyVRageCfg.PathFBXImporter != "" then (Chbx_FBXImporter.color = (color 0 200 0)   ) else (Chbx_FBXImporter.color = (color 240 0 0) )
			if MyVRageCfg.PathMwmBuilder != "" then (Chbx_MwMBuilder.color = (color 0 200 0)   ) else (Chbx_MwMBuilder.color = (color 240 0 0) )
			if MyVRageCfg.PathTextures != "" then (Chbx_Textures.color = (color 0 200 0)   ) else (Chbx_Textures.color = (color 240 0 0) )
			if MyVRageCfg.PathHavokContentTools != "none" then (Chbx_Havoktools.color = (color 0 200 0)   ) else (Chbx_Havoktools.color = (color 240 0 0) )  
		)
	)
	
	rollout VrageUtils_CfgTextures "Textures" width:210 height:400	
	(

		label lbl_textureType "Texture Format:"   across:4
		dropdownlist ddl_TexType "" items:VrageTexTypes enabled:(not MyVRageCfg.UseGameTextures) selection:MyVRageCfg.TextureType width:60
			on ddl_TexType selected sel do (
				MyVRageCfg.TextureType = ddl_TexType.selection
				MyVRageCfg.save()
			)
			
		checkbutton cbn_UseGameTextures "Use Game Textures"  width:120 height:25 checked:MyVRageCfg.UseGameTextures
			tooltip:"Check if you want to use DDS Textures straight from the Game files" 
			on cbn_UseGameTextures changed state do (
				if not (doesDirectoryExist MyVRageCfg.PathGame) then (
					state = False
				)
				
				for c in #(ddl_TexType) do c.enabled = not state
				MyVRageCfg.UseGameTextures = state
				MyVRageCfg.save()
			)
			
		button btn_ConvertTxt "Texture Convert Tool" width:120 height:25 toolTip:"Run the Bulk Texture Converter to convert the Game textures to the chosen format." 
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
	MyVRageCfgFloater = newRolloutFloater  "VRage Utilities Config" 600 400 20 130 
	addRollout VrageUtils_CfgScene MyVRageCfgFloater
	addRollout VrageUtils_CfgTools MyVRageCfgFloater
	addRollout VrageUtils_CfgTextures MyVRageCfgFloater
	addRollout VrageUtils_CfgGame MyVRageCfgFloater
)

--OpenSettings()

