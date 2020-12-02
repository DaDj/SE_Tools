struct MyVrageConfig
(
	PathFBXImporter = "none",
	PathHavokContentTools = "none",
	PathMwmBuilder = "none",
	PathTextures = "none",
	PathModSDK = "none",
	TextureType = ".dds",
	PathGame = "none"
)


global VRageCfg = MyVrageConfig()

global VRageConfigDir =  GetDir #plugcfg+ @"\VRageUtilities" 
makedir VRageConfigDir
global VrageConfigPath = VRageConfigDir + @"\VRageCfg.ini"


 VRageCfg.PathFBXImporter = getINISetting VrageConfigPath "Directories" "FBXImporter"
 VRageCfg.PathHavokContentTools = getINISetting VrageConfigPath "Directories" "HavokContentTools"
 VRageCfg.PathMwmBuilder = getINISetting VrageConfigPath "Directories" "MwMBuilder"
 VRageCfg.PathTextures = getINISetting VrageConfigPath "Directories" "TexturePath"
 VRageCfg.PathModSDK = getINISetting VrageConfigPath "Directories" "PathModSDK"
 VRageCfg.TextureType = getINISetting VrageConfigPath "Textures" "TextureType"
 VRageCfg.PathGame = getINISetting VrageConfigPath "Directories" "pathgame"

fn OpenSettings = (
rollout VrageUtils_CfgScene "VRage Utilities - Config" width:210 height:400
(
label lbl_text "Configuration Panel for the VRAGE Utilites. \nPlease refer to the setup tutorial if the settings are unclear."	height:30 align:#left across:2
button btn_CFgHelp "Help / Info" width:100 height:25 toolTip:"---" align:#right 
)

rollout VrageUtils_CfgTools "Tools" width:210 height:400
(
	label lbl_PathFbx  "FBXImporter"align:#left across:2
	button btn_PathFBXImp VRageCfg.PathFBXImporter width:400 height:25 align:#right tooltip:" path to the executable of FbxImporter" 
		on btn_PathFBXImp pressed do (
			FilePath = getOpenFileName  types:"Executable(*.exe)|*.exe|All|*.*|"
			 if(FilePath != undefined ) do (
				btn_PathFBXImp.text = VRageCfg.PathFBXImporter  = FilePath 
				setINISetting VrageConfigPath "Directories" "FBXImporter" FilePath
			)
		)
			 
			 
	label lbl_PathHavok  "HavokContentTools"align:#left across:2
	button btn_PathHavok VRageCfg.PathHavokContentTools width:400 height:25 align:#right tooltip:" path to the installation directory of HavokContentTools"
		on btn_PathHavok pressed do (
			FilePath = getSavePath caption:"Test path..."
			if(FilePath != undefined ) do (
				btn_PathHavok.text = VRageCfg.PathHavokContentTools = FilePath
				setINISetting VrageConfigPath "Directories" "HavokContentTools" FilePath
			)
		)
		

	label lbl_PathMwmBuilder "MWMBuilder"align:#left across:2
	button btn_PathMwmBuilder  VRageCfg.PathMwmBuilder width:400 height:25 align:#right tooltip:" path to the MwmBuilder exceutable"
		on btn_PathMwmBuilder  pressed do (
			FilePath  = getOpenFileName  types:"Executable(*.exe)|*.exe|All|*.*|"
			if(FilePath != undefined ) do (
				btn_PathMwmBuilder.text = VRageCfg.PathMwmBuilder = FilePath
				setINISetting VrageConfigPath "Directories" "MwMBuilder" FilePath
			)
		)		 
			 
)
	
rollout VrageUtils_CfgTextures "Textures" width:210 height:400	
(
	label lbl_PathTextures  "Textures path"align:#left across:2
			button btn_PathTextures VRageCfg.PathTextures width:400 height:25 align:#right tooltip:" path to the  directory with the Textures"
			on btn_PathTextures pressed do (
					FilePath   = getSavePath caption:"Test path..."
					 if(FilePath != undefined ) do ( 
						btn_PathTextures.text = VRageCfg.PathTextures = FilePath
						setINISetting VrageConfigPath "Directories" "TexturePath" FilePath
					)
				)

			label lbl_txtcfg "   "align:#left across:3
			dropdownlist ddl_TexType "Type of Textures" items:#(".dds", ".tif", ".png") enabled: true width:150  align:#left 
			button btn_ConvertTxt "Texture Convert Tool" width:150 height:25 toolTip:"---" align:#right  offset:[0,15]  

			on VrageUtils_Scene open do (
				ddl_TexType.selection = findItem ddl_TexType.items VRageCfg.TextureType
			)
			
			on ddl_TexType selected sel do (
				 VRageCfg.TextureType = ddl_TexType.selected
				setINISetting VrageConfigPath "Textures" "TextureType" VRageCfg.TextureType 
			)
)

rollout VrageUtils_CfgGame "Game" width:210 height:400	
(
	label lbl_PathPathModeSDK "ModSDK" align:#left across:2
	button btn_PathPathModeSDK VRageCfg.PathModSDK width:400 height:25 align:#right tooltip:" path to the directory of the SE/ME PathModSDK"
		on btn_PathPathModeSDK pressed do (
			FilePath   = getSavePath caption:"Test path..."
			 if(FilePath != undefined ) do ( 
				btn_PathPathModeSDK.text = VRageCfg.PathModSDK = FilePath
				setINISetting VrageConfigPath "Directories" "PathModSDK" FilePath
			)
		)

	label lbl_PathGame "Game" align:#left across:2
	button btn_PathGame VRageCfg.PathGame width:400 height:25 align:#right tooltip:" path to the directory of the SE Game"
		on btn_pathgame pressed do (
			filepath   = getsavepath caption:"test path..."
			 if(filepath != undefined ) do ( 
				btn_pathgame.text = vragecfg.pathgame = filepath
				setinisetting vrageconfigpath "directories" "pathgame" filepath
			)
		)
)
	
	try (closeRolloutFloater VrageCfgFloater) catch () 
	VrageCfgFloater = newRolloutFloater  "VRage Utilities Config" 600 500 20 130 
	addRollout VrageUtils_CfgScene VrageCfgFloater
	addRollout VrageUtils_CfgTools VrageCfgFloater
	addRollout VrageUtils_CfgTextures VrageCfgFloater
	addRollout VrageUtils_CfgGame VrageCfgFloater
)
