-- 		global Block_size  = "Large"
-- 		global size_mult  = 2.5
-- 		global size_mult_half  = 1.25
-- 		global expo_selected = true
-- 		global round_1digit = false
-- 		
-- 		fn size_func = (
-- 			if Block_size == "Large" do ( 
-- 				size_mult = 2.5     
-- 				size_mult_half = 1.25 )
-- 			if Block_size =="Small" do (
-- 				size_mult = 0.5      
-- 				size_mult_half = 0.25 )
-- 		)


utility Mountpoint_tool "VRAGE TOOLKIT" 
(
	button butt_mount "Mountpoints" width:150 align:#center
	on butt_mount pressed do ( 
		try ( fileIn (scriptspath+"\\SE_Tools\\mountpoint_GUI.ms") quiet:true   ) 
		catch messagebox "Error!" title:"Can't find the mountpoint script"
		)		
		
	button butt_highlight "Highlights" width:150 align:#center
	on butt_highlight pressed do ( 
-- 		try ( fileIn (scriptspath+"\\SE_Tools\\Highlights_GUI.ms") quiet:true   ) 
-- 		catch messagebox "Error!" title:"Can't find the mountpoint script"
		)		
		
	button butt_expoMWM "Export to MWM" width:150 align:#center
	on butt_expoMWM pressed do ( 
-- 		try ( fileIn (scriptspath+"\\SE_Tools\\Highlights_GUI.ms") quiet:true   ) 
-- 		catch messagebox "Error!" title:"Can't find the mountpoint script"
		)		
			
	)

	
	

openUtility Mountpoint_tool