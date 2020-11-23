thing = "detector_terminal_section_001"
cust_attrib = attributes "Custom Attributes"
(
parameters main rollout:params
	(
	highlight type:#string ui:highlight default: thing
	)
rollout params "Custom Attributes"
	(
	EditText highlight "highlight" 
	)
)



SizeX = 0;
SizeY = 0;
SizeZ =0;
for obj in selection do ( 
 	test = obj.name
 	custAttributes.delete  obj 1
 	print(obj.name)
	CustAttributes.add obj cust_attrib #unique 
 	test = obj.name
 	obj.highlight= test
 	old_def = custAttributes.getDef obj 1
 	old_def_data = custAttributes.getDefData old_def -- get my defData from it
 	print(custAttributes.getPBlockDefs old_def)
	)

SizeX = abs(selection.max.x - selection.min.x + 0.01);
SizeY = abs(selection.max.y - selection.min.y + 0.01);
SizeZ = abs(selection.max.z - selection.min.z + 0.01);
	
HighlightDummy = dummy() ;
HighlightDummy.Pos = selection.Center;
HighlightDummy.Boxsize = [SizeX,SizeY,SizeZ];
	
HighlightDummy.name = "Test";	
	
-- 	List_NEW:
-- 	detector_conveyor
-- 	detector_terminal
-- 	detector_upgrade
-- 	detector_cockpit
-- 	detector_wardrobe
-- 	detector_panel_button
-- 	detector_respawn

	
	
	
-- detector_conveyor_01
-- detector_conveyor_small_001
-- detector_terminal_001
-- dummy_detector_panel_button_1
-- dummy detector_respawn
-- detector_wardrobe
-- detector_block_1
-- detector_cockpit_2
-- muzzle_missile_001
-- muzzle_projectile_001
-- subpart_InteriorTurretBase1
-- subpart_InteriorTurretBase2
-- subpart_MissileTurretBase1
-- subpart_MissileTurretBarrels
-- subpart_GatlingTurretBase1
-- subpart_GatlingTurretBase2
-- subpart_GatlingBarrel
-- thruster_flame_01
-- LIGHT01
-- camera   (Elevation part, Turrets)
-- detector_upgrade_001
-- dummy_detector_Connector_001
-- vent_001
-- gear_lock_001
-- subpart_DrillHead
-- detector_shiptool_1
-- subpart_DoorLeft
-- subpart_DoorRight
-- detector_terminal_section_002
-- dummy_electric_motor
-- dummy_electric_motor (small)