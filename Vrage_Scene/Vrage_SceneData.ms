VrageSceneData = attributes "VrageSceneData" attribID:#(0x4161fb2e, 0x68bae400)
(
	Parameters main
	(
		PaintColorNode type:#maxObject ;
		ModDir type:#string default:"";
		ModName type:#string default:"";
		GenerateSBC type:#boolean default:true;
		UpdateSBC type:#boolean default:true;
		ExporttoModDir type:#boolean default:true;
		StartGameAfterExpo type:#boolean default:false;
	)
)


struct VrageScene
(
	fn Init = 
	(
		Attr = custAttributes.get rootnode VrageSceneData
		if  Attr == undefined then 
		(
			CustAttributes.add rootnode VrageSceneData
		)
		if rootnode.VrageSceneData.PaintColorNode == undefined then 
		(
			print "okey?"
			rootnode.VrageSceneData.PaintColorNode = osl_SetColor()
			rootnode.VrageSceneData.PaintColorNode.color = (color 144 144 144 255)
		)
	),

	fn Get = 
	(
		Attr = custAttributes.get rootnode VrageSceneData
		if  Attr == undefined then  VrageScene.Init()
		rootnode.VrageSceneData
	),
	
	fn SetPaintColor TheColor:(color 144 144 144 255) =
	(
		Attr = custAttributes.get rootnode VrageSceneData
		if  Attr == undefined then  VrageScene.Init()
		rootnode.VrageSceneData.PaintColorNode.color = TheColor
	),

	fn getPaintNode =
	(
		Attr = custAttributes.get rootnode VrageSceneData
		if  Attr == undefined then VrageScene.Init()
		if rootnode.VrageSceneData.PaintColorNode == undefined then VrageScene.Init()
		rootnode.VrageSceneData.PaintColorNode
	),

	fn SetEnvmap iMap = 
	(
		environmentMap =   osl_HDRIenv()
		if iMap == 1 then environmentMap.hdri = MyVRageRoot + "\\Vrage_resources\\mySpace.hdr"
		if iMap == 2 then environmentMap.hdri = MyVRageRoot + "\\Vrage_resources\\myearth.hdr"
	),

	fn GetExportRollout = 
	(
		rollout rollExpUI "VRage Export Settings" width:400 height:200
		(
			group "Toggles"
			(
				
				checkbutton ChkExp_GenerateBlockDef "Generate Block Def."   checked:((VrageScene.get()).GenerateSBC)  width:130  height:25\
				tooltip:"Generate as Blockdefintion File (.sbc) "  across:3 align:#center

				

				checkbutton ChkExpotoModFolder "Export to Mod Folder" checked:((VrageScene.get()).ExporttoModDir)  width:130  height:25\
				tooltip:"Export directly to the mod folder in the appdata of Spaceengineers. If fasle, directory can be selected at export."   align:#center
				
				
				checkbutton ChkExp_StartGameAfter "Start Game after export"  checked:((VrageScene.get()).StartGameAfterExpo)  width:130  height:25 \
				tooltip:"Start Game after export?"   align:#center

				checkbutton ChkExp_UpdateBlockDef "Update Block Def."   checked:((VrageScene.get()).UpdateSBC)  width:130  height:25\
				tooltip:"If true updates(.sbc) if existing. If false, overwrites existing "  across:3 align:#center 

				on ChkExp_GenerateBlockDef changed state do 
				(
					(VrageScene.get()).GenerateSBC = state
					ChkExp_UpdateBlockDef.visible = state
				)

				on ChkExpotoModFolder changed state do (VrageScene.get()).ExporttoModDir = state   

				on ChkExp_StartGameAfter changed state do 	(VrageScene.get()).StartGameAfterExpo = state   
			
				on ChkExp_UpdateBlockDef changed state do (VrageScene.get()).UpdateSBC = state   

			)

			on rollExpUI open do 
			(
				ChkExp_UpdateBlockDef.visible = (VrageScene.get()).GenerateSBC 
			)
		)

		rollExpUI
	),

	
	fn ShowUI = 
	(
		rollout SceneSettingsRollout "Mod Settings" width:256 height:300
		(
			--label lbl_Modname "Modification Name:" across:4 align: #left
			--	edittext editt_Modname "" fieldWidth:120 labelOnTop:true align: #right \ 
			--toolTip:"Name of your Modifiaction"
			label lbl_PathModir "Mod Directory:" align:#left across:2 offset:[0,5]
			button btn_PathModir  "" width:350 height:25 align:#right tooltip:"Path to the mods directory"
			on btn_PathModir pressed do (
				FilePath = getSavePath caption:"Mod path..."  initialDir:(systemTools.getEnvVariable "USERPROFILE" + "\AppData\Roaming\SpaceEngineers\Mods"  )
				if ( FilePath != undefined ) do ( 
					btn_PathModir.text =  (VrageScene.get()).ModDir = 	FilePath
				)
			)
			on btn_PathPathModeSDK rightclick do try ( shellLaunch MyVRageCfg.PathModSDK "" ) catch()


			on SceneSettingsRollout open do 
			(
				--editt_Modname.text = (VrageScene.get()).ModName
				btn_PathModir.text =  (VrageScene.get()).ModDir
			)
			

		)

		try (cui.UnRegisterDialogBar MySceneSettingUI ) catch () 
		try (closeRolloutFloater MySceneSettingUI) catch ()

		MySceneSettingUI = newRolloutFloater "VRAGE Scene Settings" 500 200
		addRollout SceneSettingsRollout MySceneSettingUI
		addRollout (GetExportRollout()) MySceneSettingUI

		cui.RegisterDialogBar MySceneSettingUI style:#( #cui_floatable ) 
	)
)


