struct VRage_Icon 
(
	fn ApplyColorTint r_image TheTint = 
	( -- Makes the Icon monochrome and tint it.
		bmp_w = r_image.width
		bmp_h = (r_image.height - (1 as integer))
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
			) 
		)
		-- if any object is missing OR if reset is true then delete existing and recreate
		if IconCam == undefined or IconCamtarget == undefined or reset == true then 
		(
			if IconCam != undefined then delete IconCam
			--if IconCamtarget != undefined then delete IconCamtarget
			
			cameraname = "IconCam"
			tempCamera = TargetCamera name:cameraname target:( TargetObject name:( cameraname + ".Target" ) )
			tempCamera.target.pos = [0, 0, 0]
			tempCamera.position.x = units.decodeValue "500cm" 
			tempCamera.position.y = units.decodeValue "350cm" 
			tempCamera.position.z = units.decodeValue "200cm" 
			tempCamera.fov = 40

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
		)
		
		if activate == true then 
		(
			IconLight.enabled = true 
			SunLight.enabled = true 
		) 
		else 
		(
			IconLight.enabled = false
			SunLight.enabled = false
		)
		IconCam
	),

	fn RenderIcon inputWidth inputHeight Layer:undefined Filename:undefined TintColor:( color 200 248 255 ) = 
	(
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
		result
	),

	fn SaveIcon Bitmap Filename Format:"dds" =
	(

	)
)

--MyIcon = VRage_Icon()
--MyIcon.RenderIcon "C:\Users\patgr\Desktop\myicon.png" 256 256
