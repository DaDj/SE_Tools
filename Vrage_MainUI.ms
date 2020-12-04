
-- Scene Settings
rollout VrageUtils_Scene "Set up Scene/Models" width:210 height:104
(		
-- 	button 'Prep_scene' "Pepare scene" width:185 height:25 toolTip:"Generates the basic Setup for working with SE)" align:#center across:1
-- 	on Prep_scene pressed do MySE.run "Scene_Setup.ms"		

	
	group "BLock Dimensions" 
	(
				
		dropdownlist scale_dd "Blocksize" items:#("Large","Small") 
		spinner  bound_leng "Length" fieldwidth:45 range:[1,100,1] type:#integer across: 3
		spinner bound_width "Width" fieldwidth:45 range:[1,100,1] type:#integer
		spinner  bound_height "Height" fieldwidth:45 range:[1,100,1] type:#integer
	)

	
	group "Models"	
	(
		
		spinner SpinLodCount "Number of LODS" fieldwidth:80 range:[0,6,1] type:#integer  align:#right 
		spinner SpinBSCount "Number of BuildStages" fieldwidth:80 range:[0,3,1] type:#integer  align:#right 
		spinner SpinBSLodCount "Number of LODs per BuildStage" fieldwidth:80 range:[0,6,1] type:#integer  align:#right 
		
	
        on SpinLodCount changed val do 
        (
            VrageScene.i_LODS = val
            --VrageScene.run "Scene_Setup.ms"	
		)		

	
        on SpinBSCount changed val do 
        (
            VrageScene.i_Buildstages = val
           -- VrageScene.run "Scene_Setup.ms"	
		)		
	
        on SpinBSLodCount changed val do 
        (
            VrageScene.i_BuildstagesLODS = val
            --VrageScene.run "Scene_Setup.ms"	
		)			
		
	)
	
	edittext EditBlockName "Block Name:" fieldWidth:200 labelOnTop:false text: "MyBlock" 
	
	button 'Prep_scene2' "Add Block" width:120 height:25 toolTip:"Generates the basic Setup for working with SE)" align:#center across:2
	on Prep_scene pressed do MySE.run "Scene_Setup.ms"		
	
	button 'Prep_scene3' "Add Subpart" width:120 height:25 toolTip:"Generates the basic Setup for working with SE)" align:#center across:2
	on Prep_scene3 pressed do 
		(
			-- Missing: Find all MainModels fucntion
			rollout Dialog_Addsubpart "Parent" --define a rollout and create a dialog 
			(
				dropdownlist scale_MainModel  "Add Subpart to Model:" items:#("Model1","Model2") 
				
				button 'btn_AddSub' "Add Subpart" width:120 height:25 toolTip:"Generates the basic Setup for working with SE)" align:#center
				on btn_AddSub pressed do 
					(
					destroyDialog Dialog_Addsubpart
					)
				
	
			)
		createDialog Dialog_Addsubpart  style:#(#style_titlebar, #style_border, #style_sysmenu, #style_minimizebox)
			
		)
		
	subrollout ExtendedSettings height:190 scrollbar:off
	on VrageUtils_Scene open  do VrageUtils_Scene.height -=60;
)

rollout VRageUtils_extBlocksets "Extended Settings" height:240
(
	spinner SpinLod1Dist "Lod1 Distance" fieldwidth:45 range:[1,200,1] type:#integer  align:#center 
	spinner SpinLod2Dist "Lod2 Distance" fieldwidth:45 range:[1,200,1] type:#integer  align:#center 
	spinner SpinLod3Dist "Lod3 Distance" fieldwidth:45 range:[1,200,1] type:#integer  align:#center 
	spinner SpinLod4Dist "Lod4 Distance" fieldwidth:45 range:[1,200,1] type:#integer  align:#center 
	spinner SpinLod5Dist "Lod5 Distance" fieldwidth:45 range:[1,200,1] type:#integer  align:#center 
	spinner SpinLod6Dist "Lod6 Distance" fieldwidth:45 range:[1,200,1] type:#integer  align:#center 

	
	on VRageUtils_extBlocksets open do(
	SpinLod1Dist.value = VrageScene.LodDistance1
	SpinLod2Dist.value = VrageScene.LodDistance2
	SpinLod3Dist.value = VrageScene.LodDistance3
	SpinLod4Dist.value = VrageScene.LodDistance4
	SpinLod5Dist.value = VrageScene.LodDistance5
	SpinLod6Dist.value = VrageScene.LodDistance6
	)
	
	on VRageUtils_extBlocksets rolledUp state do
	if state then
	(
		VrageUtils_Scene.ExtendedSettings.height += 170;
		VrageUtils_Scene.height  +=170;
	)		
		else
	(
		VrageUtils_Scene.ExtendedSettings.height -= 170;
		VrageUtils_Scene.height -=170;
	)
)

rollout VrageUtils_Mountpoints "Mountpoints" width:210 height:504
(
	button btn_StartMountpoints "Start Mountpoints Mode" width:185 height:25 toolTip:" " align:#center
	on btn_StartMountpoints pressed do filein "Mountpoint_GUI.ms"
)

rollout VrageUtils_Collision "Collisions" width:330 height:504
(
-- 	button btn_StartCollision "Start Collision Mode" width:185 height:25 toolTip:" " align:#center
-- 	on btn_Settings pressed do OpenSettings()
	
		group "Create RigidBodies"	
	(
	button btn_RigidBox "Box" width:50 height:40 toolTip:"Box" align:#center across:5
	button btn_RigidSphere "Sphere" width:50 height:40 toolTip:"Sphere" align:#center
	button btn_RigidCylinder "Cylinder" width:50 height:40 toolTip:"Cylinder" align:#center
	button btn_RigidMesh "Hull" width:50 height:40 toolTip:"Hull" align:#center
	button btn_RigidCapsule "Capsule" width:50 height:40 toolTip:"Capsule" align:#center enabled:false
	
	checkbox chbox_FitSelec "Fit to Selection" align:#center tooltip:"Fits the generated Rididbody to the selected Object. Generates an Convex Hull if mesh is choosen,"
		
	on btn_RigidBox pressed do  CreateRigidBodyObject   "Box" chbox_FitSelec.checked 
	on btn_RigidSphere pressed do  CreateRigidBodyObject "Sphere"  chbox_FitSelec.checked 
	on btn_RigidCylinder pressed do  CreateRigidBodyObject "Cylinder" chbox_FitSelec.checked 
	on btn_RigidMesh pressed do  CreateRigidBodyObject "Hull" chbox_FitSelec.checked 
	

	)

)

rollout VrageUtils_Settings"VRage Utilities Settings" width:210 height:504
(
	button btn_Settings "Open Settings" width:120 height:25 toolTip:" " align:#center across:2
	on btn_Settings pressed do OpenSettings()
	
	button btn_LOg "Open Log" width:120 height:25 toolTip:" " align:#center
	on btn_LOg pressed do VRageLog_Show()

	
-- 	on VrageUtils_Settings open do (	btn_Settings.images = #(
-- "Containers_24i.bmp",
-- "Containers_24i.bmp",
-- 18, 18, 1, 1+1, 1+1, false, true
-- 	))
)


rollout VRageUtils_Export"VRage I/O"
(
	button 'Btn_export' "Export" width:185 height:25 toolTip:"Generates  MWM file/s from the selected Block/s" align:#center 
	on Prep_scene pressed do MySE.run "Scene_Setup.ms"		

)


try (closeRolloutFloater VrageFloater1) catch () 
VrageFloater1 = newRolloutFloater  "VRage Utilies"320 800 300 300 
clearListener()
addRollout VrageUtils_Scene VrageFloater1
addRollout VrageUtils_Collision VrageFloater1
addRollout VrageUtils_Mountpoints VrageFloater1
addRollout VRageUtils_Export VrageFloater1
addRollout VrageUtils_Settings VrageFloater1

AddSubRollout VrageUtils_Scene .ExtendedSettings VRageUtils_extBlocksets rolledUp:true



-- cui.RegisterDialogBar VrageFloater1 style:#(#cui_floatable, #cui_dock_right) --minSize:[236,100] maxSize:[236,1600]
-- cui.DockDialogBar VrageFloater1 #cui_dock_right