

--Custom Attributes for extra Icon data
VrageLayer_IconData = attributes "VrageLayer_IconData" attribID:#( 0x27951347, 0x2b49c1fd )
(
	parameters main
	(
		Size type:#string default:"Large" ;
		IconCameraTgtPos type:#point3 default:[0, 0, 0] ;
		IconCameraPos type:#point3 default:[(units.decodeValue "500cm"), (units.decodeValue "350cm"), (units.decodeValue "200cm")] ;
		IconTintColor type:#color	default:[132, 170, 190] ;
		IconCameraFOV type:#float default:40.0 ;
	)
)

struct VRage_Icon 
(
	fn ApplyColorTint r_image TheTint = 
	( -- Makes the Icon monochrome and tint it.
		bmp_w = r_image.width
		bmp_h = ( r_image.height - ( 1 as integer ) )
		for y = 0 to bmp_h do
		(
			pixel_line = getPixels r_image [0, y] bmp_w
			for x = 1 to bmp_w do
			(
				--TINT = color 180 248 255
				pv = pixel_line[x]
				pv.saturation = 0.0
				if pv != ( color 0 0 0 0 ) then 
				(
					Color = ( TheTint ) * pv
					Color.alpha = pv.alpha
				)
				else 
				(
					Color = pv 
				)
				pixel_line[x] = Color
			) --end x loop
			setPixels r_image [0, y] pixel_line
		) --end y loop
		r_image
	),

	fn SetupObjects Layer reset:false activate:false =
	(	--creates the camera an lights for the Icon render
		IconCam = undefined	
		IconCamtarget = undefined
		IconLight = undefined
		SunLight = undefined
		IconDummy = undefined
		--find the camera/omnis in the defined layer
		( Layer.layerAsRefTarg ).nodes &theNodes
		for tNode in theNodes do 
		(
			if tNode.name != undefined then 
			(
				if tNode.name == "IconCam" then IconCam = tNode
				if tNode.name == "IconCam.Target" then IconCamtarget = tNode
				if tNode.name == "IconLight" then IconLight = tNode
				if tNode.name == "SunLight" then SunLight = tNode
				if tNode.name == "IconDummy" then IconDummy = tNode
			) 
		)
		if IconDummy == undefined then 
		(
			IconDummy = dummy()
			IconDummy.Boxsize = [0.1, 0.1, 0.1] ;
			IconDummy.Name = "IconDummy"
		)

		MainAttr = custAttributes.get Layer VrageLayer_IconData
		if ( MainAttr == undefined ) then 
		(
			layerRT = Layer.layerAsRefTarg
			custAttributes.add layerRT VrageLayer_IconData
		) 

		if reset == true and MainAttr != undefined then 
		(
			MainAttr.IconTintColor = [132, 170, 190] 
		)

		-- if any object is missing OR if reset is true then delete existing and recreate
		if IconCam == undefined or IconCamtarget == undefined or reset == true then 
		(
			if IconCam != undefined then delete IconCam
			--if IconCamtarget != undefined then delete IconCamtarget
			
			cameraname = "IconCam"
			tempCamera = TargetCamera name:cameraname target:( TargetObject name:( cameraname + ".Target" ) )
			tempCamera.target.pos = [0, 0, 0]
			tempCamera.pos = [(units.decodeValue "500cm"), (units.decodeValue "350cm"), (units.decodeValue "200cm")] 
			
			tempCamera.fov = 40
			if ( MainAttr != undefined ) then 
			(
			print reset
				if reset == false then 
				(
					tempCamera.position = MainAttr.IconCameraPos
					tempCamera.target.pos = MainAttr.IconCameraTgtPos
					tempCamera.fov = MainAttr.IconCameraFOV
				)
				else 
				(
					MainAttr.IconCameraPos =tempCamera.position 
					MainAttr.IconCameraTgtPos = tempCamera.target.pos
					MainAttr.IconCameraFOV = tempCamera.fov 
				)
			) 
			tempCamera.parent = IconDummy
			( Layer.layerAsRefTarg ).addnode	tempCamera
			IconCam = tempCamera
		)

		if SunLight == undefined or reset == true then 
		(
			if SunLight != undefined then delete SunLight
			
			SunLight = Skylight multiplier:1.0 name:"SunLight"
			SunLight.rgb = [255, 255, 255]
			--SunLight.attenDecay = 1
			--SunLight.castShadows = true
			--SunLight.baseObject.castShadows = true
			SunLight.position.x = units.decodeValue "2500cm" 
			SunLight.position.y = units.decodeValue "3500cm" 
			SunLight.position.z = units.decodeValue "0cm" 
			( Layer.layerAsRefTarg ).addnode	SunLight
			SunLight.parent = IconDummy
			
		)

		if IconLight == undefined or reset == true then 
		(
			if IconLight != undefined then delete IconLight
			
			tempLight = Omnilight multiplier:5.0 name:"IconLight"
			tempLight.rgb = [255, 255, 255]
			tempLight.attenDecay = 1
			tempLight.castShadows = true
			tempLight.baseObject.castShadows = true
			tempLight.position.x = units.decodeValue "2500cm" 
			tempLight.position.y = units.decodeValue "3500cm" 
			tempLight.position.z = units.decodeValue "0cm" 
			( Layer.layerAsRefTarg ).addnode	tempLight
			IconLight = tempLight
			IconLight.parent = IconDummy
		)

		--always hide the lights. The user shouldn't care about those.
		IconLight.isHidden = true 
		SunLight.isHidden = true 
		-- activate deactivate cam/lights if active/inactive
		if activate == true then 
		(
			IconLight.enabled = true 
			SunLight.enabled = true 
			IconCam.isHidden = false
	
			viewport.setCamera IconCam
		) 
		else 
		(
			IconLight.enabled = false
			SunLight.enabled = false
			IconCam.isHidden = true
		)
		select IconCam
		IconCam 
	),

	fn SavetoCA Layer = 
	(
		--find the camera/omnis in the defined layer
		(Layer.layerAsRefTarg ).nodes &theNodes
		MainAttr = custAttributes.get Layer VrageLayer_IconData
		for tNode in theNodes do 
		(
			if tNode.name != undefined then 
			(
				if tNode.name == "IconCam" then 
				(
					MainAttr.IconCameraPos = tNode.pos
					MainAttr.IconCameraFOV = tNode.fov

				)
				if tNode.name == "IconCam.Target" then 
				(
					MainAttr.IconCameraTgtPos = tNode.pos
				)
			) 
		)
	),

	fn CloseDownObjects Layer = 
	(
		SavetoCA Layer
		--find the camera/omnis in the defined layer
		( Layer.layerAsRefTarg ).nodes &theNodes
		for tNode in theNodes do 
		(
			try 
			(
				if tNode.name != undefined and tNode.isDeleted == false then 
				(
					
					if tNode.name == "IconCam" then delete tNode 
					if tNode.name == "IconCam.Target" then delete tNode 
					if tNode.name == "IconLight" then delete tNode 
					if tNode.name == "SunLight" then delete tNode 
					if tNode.name == "IconDummy" then delete tNode 
				)
			) 
			catch()
		)

		
	),

	fn RenderIcon inputWidth inputHeight Layer:undefined Filename:undefined TintColor:( color 200 248 255 ) = 
	(
		useEnvironmentMap = false
		result = undefined
		--save current render and set render to quicksilver
		cur_rdr = renderers.current
		new_rdr = Quicksilver_Hardware_Renderer()
		renderers.current = new_rdr
		new_rdr.AmbientOcclusionEnabled = true
		new_rdr.AmbientOcclusionIntensity = 2.0
		new_rdr.AmbientOcclusionRadius = 10.0
		new_rdr.IndirectIlluminationEnabled = true
		new_rdr.IndirectIlluminationMultiplier = 2.0
		-- Do Bloom if version is above 2021. 
		-- Bloom has beend implemented 2022
		if ( ( maxversion())[8] ) > 2021 then 
		(
			--new_rdr.BloomEnabled = true	
		)

		-- ave current data to CA
		SavetoCA Layer
		-- setup objects as safety again and get the camera
		tempCamera = SetupObjects Layer activate:true
		
		--do the renderer
		with redraw off
		with undo off
		(
			pngio.setAlpha true ;
			if Filename == undefined then
			(
				result = render camera:tempCamera outputsize:[inputWidth, inputHeight] vfb:false renderatmosphericeffects:true
				result = ApplyColorTint result TintColor
			)
			else 
			(
				result = render camera:tempCamera outputsize:[inputWidth, inputHeight] vfb:false --outputfile:Filename
			)
			--delete #( tempLight )
		)

		-- Disable Objects(light)
		SetupObjects Layer activate:false
		-- reset of Render to previous one
		renderers.current = cur_rdr
		useEnvironmentMap = true
		result
	),

	fn SaveIcon Bitmap Filename Format:"dds" =
	(

	)
)

rollout Vrage_IconRollout "CubeBlock Icon" width:200 height:200 
( -- UI for the Icon rendering.
	checkbutton btn_IconMode "Icon Mode" width:230 height:25 align:#center \
	toolTip:"Icon Mode on/off" --images: #( VRageIcons, VRageIcons, VRageIcoLeng, 27, 27,27, 27 )


	groupBox group1 "" pos:[5, 35] width:100 height:100 
	imgtag the_bmp width:100 height:100 align:#left across:2 pos:[5, 35]

	button btn_Setup "Reset" width:40 height:25 align:#right pos:[192, 70] \
	toolTip:"recreate the Camera Setup if its lost or if it needs to be reset." images: #( VRageIcons, VRageIcons, VRageIcoLeng, 3, 3, 3, 3 )

	colorpicker theColor "Tint Color:" color:[132, 170, 251905] modal:false align:#right pos:[135, 40] 

	button btn_Preview "Preview" width:25 height:25 toolTip:"Generates a preview of the Icon" align:#righ pos:[3, 140] \
	toolTip:"Icon Mode on/off" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 32, 32, 32, 32 )

	button btn_CreateIcon "Create Icon" width:199 height:25 toolTip:"Box" align:#right pos:[33, 140]
	toolTip:"Creates the Icon" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 12, 12, 12, 12 )

	on Vrage_IconRollout open do
	(
		Layer = ( VRLayers.GetSelected()) ;
		MainAttr = custAttributes.get Layer VrageLayer_IconData
		if Layer != undefined do 
		(
			try
			(
				theColor.color = MainAttr.IconTintColor 
			)
			catch (	MyVRageLog.Warn ( "Failed to re/create Camera Objs" ) )
		)
	)

	on Vrage_IconRollout close do 
	(
		Layer = ( VRLayers.GetSelected()) ;
		if Layer != undefined do 
		(
			VRage_Icon.CloseDownObjects Layer
		)
	)

	on btn_IconMode changed state do 
	(
		Layer = ( VRLayers.GetSelected()) ;
		if Layer != undefined do 
		(
			if state == on then 
			(
				VRage_Icon.SetupObjects Layer activate:true
			)
			else 
			(
				VRage_Icon.CloseDownObjects Layer 
			)
		)
	)

	on btn_Preview pressed do 
	(
		try
		(
			Layer = ( VRLayers.GetSelected()) ;
			MainAttr = custAttributes.get Layer VrageLayer_IconData
			MainAttr.IconTintColor = theColor.color
			theBmp = VRage_Icon.RenderIcon 200 200 Layer:Layer TintColor:( theColor.color )
			the_bmp.bitmap = theBmp
		)
		catch (	MyVRageLog.Warn ( "Failed to render Icon Preview" ) )
	) 

	on btn_Setup pressed do 
	(
		try
		(
			Layer = ( VRLayers.GetSelected()) ;
			MainAttr = custAttributes.get Layer VrageLayer_IconData
			MyIcon = VRage_Icon.SetupObjects Layer reset:true	
			theColor.color = MainAttr.IconTintColor 
			btn_IconMode.checked = true
		)
		catch (	MyVRageLog.Warn ( "Failed to Reset Icon Setup" ) )
	) 

	on btn_CreateIcon pressed do 
	(
		try
		(
			Layer = ( VRLayers.GetSelected()) ;
			MainAttr = custAttributes.get Layer VrageLayer_IconData
			MainAttr.IconTintColor = theColor.color
			theBmp = VRage_Icon.RenderIcon 128 128 Layer:Layer TintColor:( theColor.color )
			the_bmp.bitmap = theBmp
		)
		catch (	MyVRageLog.Warn ( "Failed to render Icon " ) )
		try 
		(
			FileName = SelectSaveBitmap caption:"Select a file"
			if FileName != undefined then theBmp.filename = FileName
			if ( theBmp.filename != undefined ) do save theBmp
		) 
		catch (	MyVRageLog.Warn ( "Failed to save Icon" ) )
	) 

	on theColor changed new_col do
	(
		Layer = ( VRLayers.GetSelected()) ;
		MainAttr = custAttributes.get Layer VrageLayer_IconData
		MainAttr.IconTintColor = theColor.color
	)
)

--MyIcon = VRage_Icon()
--MyIcon.RenderIcon "C:\Users\patgr\Desktop\myicon.png" 256 256
