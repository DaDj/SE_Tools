		global Block_size  = "Large"
		global size_mult  = 2.5
		global size_mult_half  = 1.25
	--	global expo_selected = true
		global round_1digit = false
		
		fn size_func = (
			if Block_size == "Large" do ( 
				size_mult = units.decodeValue "250cm"    
				size_mult_half = units.decodeValue "125cm"     )
			if Block_size =="Small" do (
				size_mult = units.decodeValue "50cm"          
				size_mult_half = units.decodeValue "25cm"     )
		)


rollout Mountpoint_GUI "Mountpoint_GUI" width:200 height:443
(
button export "Export Mountpoints" width:150 align:#center
	on export pressed do ( 
		--expo_selected = select_expo.checked
		try ( fileIn (scriptspath+"\\SE_Tools\\mountpoints.ms") quiet:true   ) 
		catch messagebox "Can't find the mountpoint script " title:"Error!"
		)		
	
	
	 checkbox select_expo "export selected only" checked:true
		on select_expo changed theState do (
global expo_selected = theState 
		)
		--expo_selected = select_expo .checked
	checkbox round_1digit "round to 2 digit" checked:false
			on round_1digit changed theState do (
global  round_1digit = theState 
		)
  
	group "Block" (
		
		dropdownlist scale_dd "Blocksize" items:#("Large","Small")
		on scale_dd selected i do(
			format "You selected '%'!\n" scale_dd.items[i]
			Block_size  = scale_dd.items[i]
		)
		
		spinner  bound_leng "Length" fieldwidth:45 range:[1,100,1] type:#integer
		spinner bound_width "Width" fieldwidth:45 range:[1,100,1] type:#integer
		spinner  bound_height "Height" fieldwidth:45 range:[1,100,1] type:#integer
		button create_bound "Create Boundingbox " width:140 align:#center
		on  create_bound pressed do (
			size_func()
-- 		if Block_size == undefined do ( Block_size  = "Large" ) 
			obj = getnodebyname "Boundbox_Large"
			obj2 = getnodebyname "Boundbox_Small"
			if obj != undefined then( delete obj)
			else if obj2 != undefined do ( delete obj2)
			leng = bound_leng.value * (size_mult) 
			height = bound_height.value  * (size_mult) 
			width = bound_width.value *(size_mult) 
			Boundingbox = box length:leng width:width  height:height
			boundingbox.pos = [0 ,0,-height/2 ]
			Boundingbox.visibility = bezier_float()
			Boundingbox.name = "Boundbox" + "_" +  Block_size
			Boundingbox.visibility.controller.value = 0.1
		freeze	Boundingbox
			--setgrouphead 	Boundingbox true
			)		
	)

	
	group "Mountpoint - Plane Creation" (
	
		button front "Front - Plane " width:140 align:#center
		on front pressed do (
			obj = getnodebyname "Boundbox_Large"
			obj2 = getnodebyname "Boundbox_Small"
			
			if obj != undefined  or obj2 != undefined  do ( 
				size_func()
				planefront = plane  length:1 width:1
				planefront.rotation.x_rotation = 90.0
				planefront.name = "Mountpoint_Front"
				planefront.lengthsegs = 1
				planefront.widthsegs = 1			
				planefront.pos = [0,bound_leng.value*size_mult_half ,0]
			--	planefront.wirecolor = color 150 255 255
				obj = getnodebyname "Boundbox_Large"
				obj2 = getnodebyname "Boundbox_Small"
			---	if obj != undefined  then (planefront.parent = obj ) 
				--else if obj2 != undefined  do (planefront.parent = obj2)
			)
			
		)		
			
		button back "Back - Plane" width:140 align:#center
		on back pressed do (
			size_func()
				planes = plane  length:1 width:1
			planes.rotation.x_rotation = 90.0
			planes.name = "Mountpoint_Back"
			planes.lengthsegs = 1
			planes.widthsegs = 1	
			planes.pos = [0,-bound_leng.value*size_mult_half ,0]
			obj = getnodebyname "Boundbox_Large"
			obj2 = getnodebyname "Boundbox_Small"
		--	if obj != undefined  then (planes.parent = obj ) 
			--else if obj2 != undefined  do ( planes.parent = obj2 )
		)		
			
		button left "Left - Plane " width:140 align:#center
		on left pressed do (
			size_func()
			planes = plane  length:1 width:1
			planes.rotation.x_rotation = 90.0
			planes.rotation.z_rotation = 90.0
			planes.name = "Mountpoint_left"
			planes.lengthsegs = 1
			planes.widthsegs = 1	
			planes.pos = [- bound_width.value*size_mult_half,0 ,0]
			obj = getnodebyname "Boundbox_Large"
			obj2 = getnodebyname "Boundbox_Small"
		---	if obj != undefined  then (planes.parent = obj ) 
			--else if obj2 != undefined  do ( planes.parent = obj2 )
		)		
			
			button right "Right - Plane" width:140 align:#center
		on right pressed do (
					size_func()
			planes = plane  length:1 width:1
			planes.rotation.x_rotation = 90.0
			planes.rotation.z_rotation = 90.0
			planes.name = "Mountpoint_right"
			planes.lengthsegs = 1
			planes.widthsegs = 1	
			planes.pos = [bound_width.value*size_mult_half,0 ,0]
			obj = getnodebyname "Boundbox_Large"
			obj2 = getnodebyname "Boundbox_Small"
		--	if obj != undefined  then (planes.parent = obj ) 
			--else if obj2 != undefined  do ( planes.parent = obj2 )
		)		
		
			
		button top "Top - Plane " width:140 align:#center
		on top pressed do (
		size_func()
			planes = plane  length:1 width:1
			planes.name = "Mountpoint_Top"
			planes.lengthsegs = 1
			planes.widthsegs = 1	
			planes.pos = [0,0 ,bound_height.value *size_mult_half]
			obj = getnodebyname "Boundbox_Large"
			obj2 = getnodebyname "Boundbox_Small"
			--if obj != undefined  then (planes.parent = obj ) 
			--else if obj2 != undefined  do ( planes.parent = obj2 )
		)		
			
		button bottom "Bottom - Plane" width:140 align:#center
		on bottom pressed do (
					size_func()
			planes = plane  length:1 width:1
			planes.name = "Mountpoint_bottom"
			planes.lengthsegs = 1
			planes.widthsegs = 1	
			planes.pos = [0,0 ,-bound_height.value *size_mult_half]
			obj = getnodebyname "Boundbox_Large"
			obj2 = getnodebyname "Boundbox_Small"
			--if obj != undefined  then (planes.parent = obj ) 
			--else if obj2 != undefined  do ( planes.parent = obj2 )
		)		
		
	)
)


if Mount_SE!= undefined then ( closeRolloutFloater Mount_SE; gc() )
Mount_SE = newRolloutFloater "Mountpoints" 190 520 10 50		
addRollout Mountpoint_GUI  Mount_SE rolledup:false
