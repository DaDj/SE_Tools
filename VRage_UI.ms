struct Vrage_UI 
(-- UI Struct for general/main UI
	fn PaintUI = 
	(
		rollout VRageEnvColorRollout "Paint / Environment" width:160 height:80  
		(
			colorpicker theColor "Paint:" color:[128, 128, 128]  align:#left  offset:[0,5] \
			toolTip:"Choose Paintcolor"  

			-- use apply button. applying the color will take some time on huge models.
			button ButtApplyPaint "Apply" width:30 height:30 align:#right  pos:[120,5]\ 
			toolTip:"Apply Paint" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 13, 13, 13, 13 )

			checkbutton Buttautoupdate "Apply" width:20 height:20 align:#right  pos:[90,10]\ 
			toolTip:"Autoupdate  Paint" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 37, 37, 37, 37 )

			on VRageEnvColorRollout open do theColor.color = (VrageScene.getPaintNode()).color
			on ButtApplyPaint pressed do 
			(
				with redraw off
				(
					VrageScene.SetPaintColor TheColor:theColor.color
				)
				
			) 
			on theColor changed new_col do 
			(	with redraw off
				(
					if Buttautoupdate.checked == true then	VrageScene.SetPaintColor TheColor:new_col
				)
			) 
		)

		try ( cui.UnRegisterDialogBar VRageEnvColorRollout ) catch () 
		try ( DestroyDialog VRageEnvColorRollout) catch () 	

		CreateDialog VRageEnvColorRollout  pos:[500, 400]
		cui.RegisterDialogBar VRageEnvColorRollout style:#( #cui_dock_all, #cui_dock_vert, #cui_floatable )
	),

	
	fn CreateaMain = 
	(
		rollout CreateMainRollout "Create New Main Object" width:250 height:260
		(
			combobox Type "Type:" items:#("Cubeblock")   height:8 align:center
			--items:#("Cubeblock", "Character", "PhysicalItem","Just Lods")
			edittext prefix_txt "Name:" fieldWidth:220 labelOnTop:true text:"MyNewBlock"   
			button Butt_Create "Create" width:220 height:30 align:center

			on Butt_Create pressed do
			(
				--implement other models at some time
				(VrageCubeBlock()).CreateSkel prefix_txt.text ;
				try (cui.UnRegisterDialogBar CreateMainRollout) catch () 
				try (DestroyDialog  CreateMainRollout) catch ()
			) 
		)
		
		try (cui.UnRegisterDialogBar CreateMainRollout) catch () 
		try (DestroyDialog  CreateMainRollout) catch ()
		CreateDialog CreateMainRollout
		cui.RegisterDialogBar CreateMainRollout  style:#(#cui_floatable)
	),


	fn ShowSidebar = 
	(
		try ( cui.UnRegisterDialogBar VrageSidebar ) catch () 
		try ( DestroyDialog VrageSidebar) catch () 	

		rollout VrageSidebar "" width:30 height:20
		(
			button btn_Help "\x2699" width:20 height:20 align:#center  \
			toolTip:"Opens the Documentation/Help" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 17, 17, 17, 17 )

			button btn_Settings "\x2699" width:20 height:20 align:#center  \
			toolTip:"Opens the VrageToolbox Settings" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 5, 5, 5, 5 )

			button btn_LOg "Open Notifications" width:20 height:20 align:#center  \ 
			toolTip:"Opens the VrageToolbox Notifications" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 2, 2, 2, 2 )

			button btn_ReloadVrage "\x21BA" width:20 height:20 align:#center  \
			toolTip:"Reloads Vrage Utilies. Use if scripts may not work." images: #( VRageIcons, VRageIcons, VRageIcoLeng, 3, 3, 3, 3 )

			label mySplitter1 "\x2500\x2500\x2500\x2500\x2500" 

			
			button butt_ModSettings "ModSettings" width:30 height:30 align:#center  \
			toolTip:"Open Mod&Scene Settings" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 36, 36, 36, 36 )

			on butt_ModSettings pressed do 	VrageScene.ShowUI()
			

			label mySplitterddd2 "\x2500\x2500\x2500\x2500\x2500" 
			
			
			checkbutton btn_ShowLayerUI "\x21BA" width:30 height:30 align:#center  \
			toolTip:"Expand LAyer UI" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 31, 31, 31, 31 )

			on btn_ShowLayerUI changed state do 
			(
				if state == on then VrageModelLayer_ShowUI() else VrageModelLayer_HideUI()
			)
			on btn_Help pressed do ( ShellLaunch "https://vragetoolbox.ratpool.de" "" )
			on btn_ReloadVrage pressed do fileIn ( GetDir #userScripts + "\\VRageToolbox\\VRage_Startup.ms" )
			on btn_Settings pressed do OpenSettings()	
			on btn_LOg pressed do VrageLogSys.CreateMessageRollout()


			checkbutton btn_MAgicLayer "\x21BA" width:30 height:20 align:#center  \
			toolTip:"Only show Objects in selected Layer" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 23, 23, 23, 23 )

			checkbutton btn_SwitchLayer "\x21BA" width:30 height:20 align:#center  checked:true \
			toolTip:"Automatically switch to selected Layer" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 31, 31, 31, 31 )

			timer clock "testClock" interval:10 --tick  every 2 sec
			on clock tick do
			( 
				
				if btn_MAgicLayer.checked == true then VRLayers.AutoHideLAyer = true else VRLayers.AutoHideLAyer = false
				if btn_SwitchLayer.checked == true then VRLayers.AutoSwitchLayer = true else VRLayers.AutoSwitchLayer = false

				VRLayers.GetSelected() --call to update the layer switches.
			)

			label mySplitter3 "\x2500\x2500\x2500\x2500\x2500" 
			button butt_MAtlib "Material Browser" width:30 height:30 align:#center  \ 
			toolTip:"Opens the Material Browser" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 4, 4, 4, 4 )
			
			button butt_Paint "Paint" width:30 height:30 align:#center  \ 
			toolTip:"BlockPaint & Environment" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 13, 13, 13, 13 )
			
			on butt_Paint pressed do PaintUI()

			on butt_MAtlib pressed do
			(
				try ( MyVrageMatBrowser = ( Vrage_MaterialBrowser()).getForm() ) 
				catch 
				(
					fileIn ( GetDir #userScripts + "\\VRageToolbox\\Vrage_IO\\Vrage_MaterialLibrary.ms" )
					try ( MyVrageMatBrowser = ( Vrage_MaterialBrowser()).getForm() ) 
					catch ( messagebox "Failed to open MaterialBrwoser" title:"Error!" )
				)
			) 
			
			label mySplitter5 "\x2500\x2500\x2500\x2500\x2500" 

			button butt_CreatMod "Create Mod" width:30 height:30 align:#center  \
			toolTip:"Creates Layer Setup for Block/Character/Model" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 26, 26, 26, 26 )

			button butt_Import "Import" width:30 height:30 align:#center  \
			toolTip:"Import an FBX" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 11, 11, 11, 11 )

			button butt_Export "Export" width:30 height:30 align:#center  \
			toolTip:"Export" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 12, 12, 12, 12 )

			on butt_Export pressed do VRageExporter.ShowUI()

			


			on butt_CreatMod pressed do 
			(
				CreateaMain();
			)

		)

		CreateDialog VrageSidebar 
		cui.RegisterDialogBar VrageSidebar style:#( #cui_dock_all, #cui_dock_vert, #cui_floatable )
		cui.DockDialogBar VrageSidebar #cui_dock_left
	)
)

Vrage_UI.ShowSidebar()