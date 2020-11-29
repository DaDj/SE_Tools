struct MyVrageConfig
(
	PathFBXImporter = "none",
	PathHavokContentTools = "none",
	PathMwmBuilder = "none",
	PathTextures = "none",
	ModSDK = "none"
)


global VRageCfg = MyVrageConfig()

global VRageConfigDir =  GetDir #plugcfg+ @"\VRageUtilities" 
makedir VRageConfigDir
global VrageConfigPath = VRageConfigDir + @"\VRageCfg.ini"


 VRageCfg.PathFBXImporter = getINISetting VrageConfigPath "Directories" "FBXImporter"
 VRageCfg.PathHavokContentTools = getINISetting VrageConfigPath "Directories" "HavokContentTools"
 VRageCfg.PathMwmBuilder = getINISetting VrageConfigPath "Directories" "MwMBuilder"
 VRageCfg.PathTextures = getINISetting VrageConfigPath "Directories" "TexturePath"
 VRageCfg.ModSDK = getINISetting VrageConfigPath "Directories" "ModSDK"



fn OpenSettings = (
rollout VrageUtils_Scene "VRage Utilities - Config" width:210 height:400
(
	group "Info"
	(
		label lbl_text "Configuration Panel for the VRAGE Utilites. \nPlease refer to the setup tutorial if the seetings are unclear."	height:30 align:#left
		)
	
	label lbl_PathFbx  "FBXImporter"align:#left across:2
	button btn_PathFBXImp VRageCfg.PathFBXImporter width:400 height:20 align:#right tooltip:" path to the executable of FbxImporter" 
		on btn_PathFBXImp pressed do (
			FilePath = getOpenFileName  types:"Executable(*.exe)|*.exe|All|*.*|"
			 if(FilePath != undefined ) do (
				btn_PathFBXImp.text = VRageCfg.PathFBXImporter  = FilePath 
				setINISetting VrageConfigPath "Directories" "FBXImporter" FilePath
			)
		)
			 
			 
	label lbl_PathHavok  "HavokContentTools"align:#left across:2
	button btn_PathHavok VRageCfg.PathHavokContentTools width:400 height:20 align:#right tooltip:" path to the installation directory of HavokContentTools"
		on btn_PathHavok pressed do (
			FilePath = getSavePath caption:"Test path..."
			if(FilePath != undefined ) do (
				btn_PathHavok.text = VRageCfg.PathHavokContentTools = FilePath
				setINISetting VrageConfigPath "Directories" "HavokContentTools" FilePath
			)
		)
		

	label lbl_PathMwmBuilder "MWMBuilder"align:#left across:2
	button btn_PathMwmBuilder  VRageCfg.PathMwmBuilder width:400 height:20 align:#right tooltip:" path to the MwmBuilder exceutable"
		on btn_PathMwmBuilder  pressed do (
			FilePath  = getOpenFileName  types:"Executable(*.exe)|*.exe|All|*.*|"
			if(FilePath != undefined ) do (
				btn_PathMwmBuilder.text = VRageCfg.PathMwmBuilder = FilePath
				setINISetting VrageConfigPath "Directories" "MwMBuilder" FilePath
			)
		)		 
			 
			 
	label lbl_PathTextures  "Textures path"align:#left across:2
	button btn_PathTextures VRageCfg.PathTextures width:400 height:20 align:#right tooltip:" path to the  directory with the Textures"
		on btn_PathTextures pressed do (
			FilePath   = getSavePath caption:"Test path..."
			 if(FilePath != undefined ) do ( 
				btn_PathTextures.text = VRageCfg.PathTextures = FilePath
				setINISetting VrageConfigPath "Directories" "TexturePath" FilePath
			)
		)
		
	label lbl_PathModSDK "ModSDK" align:#left across:2
	button btn_PathModSDK VRageCfg.ModSDK width:400 height:20 align:#right tooltip:" path to the directory of the SE/ME ModSDK"
		on btn_PathModSDK pressed do (
			FilePath   = getSavePath caption:"Test path..."
			 if(FilePath != undefined ) do ( 
				btn_PathModSDK.text = VRageCfg.ModSDK = FilePath
				setINISetting VrageConfigPath "Directories" "ModSDK" FilePath
			)
		)
)

	
	
	
	try (closeRolloutFloater VrageCfgFloater) catch () 
	VrageCfgFloater = newRolloutFloater  "VRage Utilities Config"600 300 20 130 
	addRollout VrageUtils_Scene VrageCfgFloater
)
