/* 
This File handles all the Layer stuff
It implements:
	 - custom attributes to define what the layers are.
	 - custom attributes with corresponding layer data
	 - UI tool do modify this data + add/delete layers
*/

global VRAGE_ModelUI
global VrageTempAllTypes = #( "CubeBlock", "Cockpit", "Gravity", "Refinery", "Armor" )

-- Custom Attributes for Layer Data
VrageLayerData= attributes "VrageLayerData" attribID:#( 0x5eac4f6e, 0xd624011 )
(
	parameters main
	(
		Type type:#string default:"CubeBlockDef" ;
		/*
		CubeBlockDef -- Info regarding cubeblockstoff gridsize, defintion etc.	
		CollisionDef -- Collision ofc
		DummiesDef 
		VRageLOD
		SubPartArray
		SubpartDef
		ConstructArrayDef --main layer under which the buildstages are.
		VRageConstructstage
		*/
		SeName type:#string default:"MySEBlock" ;
	)
)

VrageLayer_CubeBlockData = attributes "VrageLayer_CubeBlockData" attribID:#( 0x20b6687b, 0x63bbfe0a )
(
	parameters main
	(
		Size type:#string default:"Large" ;
		TypeId type:#string	default:"CubeBlock" ;
		SubtypeID type:#string	default:"MyBlock" ;
	)
)

VrageLayer_BlockPartData = attributes "VrageLayer_BlockPartData" attribID:#( 0x52819f64, 0x4bc544fb )
(
	parameters main
	(
		NumLod type:#integer default:1 ;
		NumConstruction type:#integer	default:0 ;
	)
)

VrageLayer_SubpartPartData = attributes "VrageLayer_SubpartPartData" attribID:#(0xd6eac3c, 0x44c8462e)
(
	parameters main
	(
		NumLod type:#integer default:1 ;
		NumConstruction type:#integer	default:0 ;
	)
)

VrageLayer_ConstructData = attributes "VrageLayer_ConstructData" attribID:#( 0x4d367979, 0x6e68ad54 )
(
	parameters main
	(
		ConstructionID type:#integer default:1 ;
		BuildPercent type:#integer default:50.0 ;
	)
)

VrageLayer_LODData = attributes "VrageLayer_LODData" attribID:#( 0xdcaefca, 0x59c57e45 )
(
	parameters main
	(
		DrawDistance type:#float default: 20.0 ;
		LODID type:#integer default: 0 ;
	)
)

-- Functions for the Layers
struct VRageLayers 
(
	fn CreateOrRenameLayer MyName MyOldName parent_layer:undefined = (
		if ( LayerManager.getLayerFromName ( MyOldName ) == undefined ) then (
			if ( LayerManager.getLayerFromName ( MyName ) == undefined ) then (
				layer = LayerManager.newLayer()
				layer.setname MyName
				layer.setParent parent_layer
			)
		)
		else 
		(
			layer = LayerManager.getLayerFromName ( MyOldName )
			layer.setname MyName
			layer.setParent parent_layer
		)
		layer
	),
	
	fn GetSelected = (
		-- Tries to get the selected Layer and also sets it active.
		-- If no Layer is selected it will get the  Layer of the first obj in the selection.
		layerExplorer = SceneExplorerManager.GetActiveExplorer()
		items = layerExplorer.SelectedItems()
		Layer = undefined
		for i in items where isKindOf i Base_Layer do
		(
			Layer = i
		)

		-- Set the currently selected layer automatically as the current layer
		if Layer != undefined then Layer.current = true 

		-- Set the layer to the first selected object if no Layer is directly selected
		if Layer == undefined then 
		(
			if selection[1] != undefined then 
			(
				Layer = selection[1].layer.layerAsRefTarg
				selection[1].layer.current = true
			)
		)
		Layer
	),

	fn Delete LayerHandle = (
		try 
		(
			canDelete = ( LayerHandle.canDelete()) and not ( LayerManager.doesLayerHierarchyContainNodes LayerHandle.name )
			if canDelete then 
			(
				if LayerHandle.getNumChildren() > 0 then 
				(
					/*	for i in LayerHandle.getNumChildren() to 1 by -1  do 
					(
						VRLayers.Delete (LayerHandle.getChild(i))
						--	LayerManager.deleteLayerByName ((LayerHandle.getChild(i)).name) 
					)*/

					for i = 1 to LayerHandle.getNumChildren() do 
					(
						VRLayers.Delete ( LayerHandle.getChild ( 1 ) )
					) 
				)
				LayerManager.deleteLayerByName LayerHandle.name
			) 
			else
			(
				if LayerManager.doesLayerHierarchyContainNodes LayerHandle.name then 
				( MyVRageLog.Info ( "Can't Delete Layer. Layers with Nodes/Objects in it can't be deleted!" ) Show:true )
				else ( MyVRageLog.Info ( "Can't Delete Layer." ) Show:true )
				
			) 
		)
		catch ( MyVRageLog.Info ( "Something went wrong while trying to delete Layer/s" ) Show:true )
	)
)
VRLayers = VRageLayers()

struct VrageLodLayer
(
	fn Add Mainlayer:undefined LodDistanceMultiplier:15 =
	(
		If Mainlayer == undefined then Mainlayer = VRLayers.GetSelected()

		if Mainlayer != undefined then 
		(
			Attr = custAttributes.get Mainlayer VrageLayerData
			--find current LOD index
			Idx_Lod = 0 ;
			for i = 1 to Mainlayer.getNumChildren() do 
			(
				ChildLayer = Mainlayer.getChild i
				layerRT = ChildLayer.layerAsRefTarg
				LodAttr = custAttributes.get layerRT VrageLayerData
				if LodAttr != undefined and LodAttr.Type == "VRageLOD" do Idx_Lod += 1
			)
			
			if Attr != undefined then 
			(
				print Attr.Type
				if Attr.Type == "CubeBlockDef" or Attr.Type == "SubpartDef" or Attr.Type == "VRageConstructstage" then 
				(
					Idx_Lod = Idx_Lod as string
					layer = VRLayers.CreateOrRenameLayer ( Mainlayer.name + " #LOD" + Idx_Lod ) ( Mainlayer.name + " #LOD" + Idx_Lod ) parent_layer:( Mainlayer.LayerProperties )
					layerRT = layer.layerAsRefTarg
					custAttributes.add layerRT VrageLayerData
					custAttributes.add layerRT VrageLayer_LODData
					layerRT.Type = "VRageLOD"
					layerRT.LODID = Idx_Lod as Integer
					layerRT.DrawDistance = LodDistanceMultiplier * ( Idx_Lod as Integer ) - 5 * ( Idx_Lod as Integer ) ^ 2 + 5 * ( Idx_Lod as Integer ) ^ 3
				)
			)
		)
		else MyVRageLog.Info ( "No Layer selected" ) Show:true

	)
)

struct VrageConstructionLayer
(
	fn Add Mainlayer:undefined =
	(
		If Mainlayer == undefined then Mainlayer = VRLayers.GetSelected()

		if Mainlayer != undefined then 
		(
			Attr = custAttributes.get Mainlayer VrageLayerData
			--find current Construction index
			Idx_BuildStage = 1 ;
			for i = 1 to Mainlayer.getNumChildren() do 
			(
				ChildLayer = Mainlayer.getChild i
				layerRT = ChildLayer.layerAsRefTarg
				Constrttr = custAttributes.get layerRT VrageLayerData
				if Constrttr != undefined and Constrttr.Type == "VRageConstructstage" do Idx_BuildStage += 1
			)
			
			if Attr != undefined then 
			(
				print Attr.Type
				if Attr.Type == "ConstructArrayDef" then 
				(
					Idx_BuildStage = Idx_BuildStage as string
					layer = VRLayers.CreateOrRenameLayer ( Attr.SeName + "Construction_" + Idx_BuildStage ) ( Attr.SeName + "Construction_" + Idx_BuildStage ) parent_layer:( Mainlayer.LayerProperties )
					layerRT = layer.layerAsRefTarg
					custAttributes.add layerRT VrageLayerData
					custAttributes.add layerRT VrageLayer_ConstructData
					layerRT.Type = "VRageConstructstage"
					layerRT.ConstructionID = Idx_BuildStage as Integer
					layerRT.BuildPercent = 33 
					
					-- always add the Lod 0 automatically
					LodLayer = VrageLodLayer()
					LodLayer.Add Mainlayer:layerRT
				)
			)

			
		)
		else MyVRageLog.Info ( "No Layer selected" ) Show:true

	)
)

struct VrageCubeBlock
(
	MyDummy = "",
	-- Creates A Cubeblock with barebonex defintions (no lods ar anything)
	fn CreateSkel BlockName optional_param:unsupplied =
	(
		-- Create Main Layer
		Mainlayer = VRLayers.CreateOrRenameLayer BlockName BlockName parent_layer:( LayerManager.getLayer 0 ) 
		layerRT = Mainlayer.layerAsRefTarg
		custAttributes.add layerRT VrageLayerData
		custAttributes.add layerRT VrageLayer_CubeBlockData
		layerRT.SeName = BlockName
		-- Collision Stuff  (Main Model ofc) 
		layer = VRLayers.CreateOrRenameLayer ( BlockName + " #Collision" ) ( BlockName + " #Collision" ) parent_layer:Mainlayer
		layerRT = layer.layerAsRefTarg
		custAttributes.add layerRT VrageLayerData
		layerRT.Type = "CollisionDef"
		layerRT.SeName = BlockName
		-- Dummies Layer
		layer = VRLayers.CreateOrRenameLayer ( BlockName + " #Dummies" ) ( BlockName + " #Dummies" ) parent_layer:Mainlayer
		layerRT = layer.layerAsRefTarg
		custAttributes.add layerRT VrageLayerData
		layerRT.Type = "DummiesDef"
		layerRT.SeName = BlockName

		-- Construction Layer
		layer = VRLayers.CreateOrRenameLayer ( BlockName + " #Construction" ) ( BlockName + " #Construction" ) parent_layer:Mainlayer
		layerRT = layer.layerAsRefTarg
		custAttributes.add layerRT VrageLayerData
		layerRT.Type = "ConstructArrayDef"
		layerRT.SeName = BlockName	

		-- Subpart Layer
		layer = VRLayers.CreateOrRenameLayer ( BlockName + " #Subparts" ) ( BlockName + " #Subparts" ) parent_layer:Mainlayer
		layerRT = layer.layerAsRefTarg
		custAttributes.add layerRT VrageLayerData
		layerRT.Type = "SubPartArray"
		layerRT.SeName = BlockName	

		-- always add the Lod 0 automatically
		layerRT = Mainlayer.layerAsRefTarg
		LodLayer = VrageLodLayer()
		LodLayer.Add Mainlayer:layerRT
	),

	-- Creates a Cubeblock with given amount of lods an buldstages + builstages lods.
	fn Create i_Lods i_Construct optional_param:unsupplied =
	(
		
	),

	-- Renames all Layers of Cubeblock except Subparts cause they can have different names
	fn RenameAll Layer OldName NewName =
	(
		layerRT = Layer.layerAsRefTarg
		Attr = custAttributes.get layerRT VrageLayerData
		if Attr.Type == "CubeBlockDef" or 
		Attr.Type == "SubPartArray" or 
		Attr.Type == "VRageConstructstage" or
		Attr.Type == "CollisionDef" or 
		Attr.Type == "ConstructArrayDef" or 
		Attr.Type == "VRageLOD" or 
		Attr.Type == "DummiesDef" then 
		(	
			Attr.SeName = NewName
			Layer.setName ( ReplaceWords Layer.Name OldName NewName mIgnoreCase:true )
		)

		if Attr.Type != "SubPartArray" then
		(
			for i = 1 to Layer.getNumChildren() do
			(
				CurrentChildLayer = Layer.getChild i
				RenameAll CurrentChildLayer OldName NewName
				
			)
		)
	)

)

--  Rollouts for Layer Types
rollout Vrage_CubeBlockRollout "CubeBlock" width:300 height:200
(	
	button btnValidate "Validate" width:120 height:25 tooltip:"Check if all expected data/Layer exist"	align:#right
	group "CubeBlock Settings"
	(
		label lbl_Size "Block Size" across:2 align: #left
		dropdownlist dropdnSize "" items:#( "Large", "Small" ) tooltip:"Size of the Block Grid (large =2.5m, Small: 0.25m)" labelOnTop: false Width:150 enabled: true align: #right

		label lbl_Type "Block Type" across:2 align: #left
		edittext FilterTypes "Filter" fieldWidth:100 labelOnTop:false align: #right
		
		label lbl_Filter "" across:2 align: #left
		listbox listboxtype "" items:VrageTempAllTypes tooltip:"Type of Block" Width:150 Height:4 enabled: true align: #right 

		label lbl_SubID "Subtype ID" across:2 align: #left
		edittext editt_SubID "" fieldWidth:150 labelOnTop:true align: #right
	)

	group "Actions"
	(
		button btnAddLod "Add a Lod" width:120 height:25
		edittext editt_Rename "Rename:" fieldWidth:100 labelOnTop:false align: #right across:2 offset:[0, 4] 
		button btnrenameBlock "Rename" width:120 height:25 
	)

	group "I/O "	
	(
		button 'Btn_Import' "Import" width:100 height:25 toolTip:"Imports an Fbx from the ModSDK" align:#center across:2
		--on Prep_scene pressed do MySE.run "Scene_Setup.ms"	
		
		button 'Btn_export' "Export" width:100 height:25 toolTip:"Generates  MWM file/s from the selected Block/s" align:#center 
		on Btn_export pressed do OpenVrageExport()
		
	)


	on btnAddLod pressed do 
	(
		Layer = VrageLodLayer()
		Layer.Add Mainlayer:( VRLayers.GetSelected())
	)

	on btnrenameBlock pressed do 
	(
		if editt_Rename.text != "" then 
		(
			
			if ( queryBox ( "Do you want to rename to: " + editt_Rename.text + "?" ) beep:false ) then 
			(
				Layer = VRLayers.GetSelected();
				Cubeblock = VrageCubeBlock()
				Cubeblock.RenameAll ( Layer ) Layer.name editt_Rename.text 
			)
		)
		else 
		(
			messageBox "No New Name entered in field!" beep:false
		)
	)
	
	on Vrage_CubeBlockRollout open do 
	(
		Layer = VRLayers.GetSelected();
		MainAttr = custAttributes.get Layer VrageLayer_CubeBlockData
		if MainAttr != undefined do 
		(
			-- Size of Block
			if MainAttr.Size == "Large" then dropdnSize.selection = 1 else dropdnSize.selection = 2

			-- Type of Block
			if MainAttr.TypeId != undefined then
			(
				Index = findItem VrageTempAllTypes MainAttr.TypeId
				listboxtype.selection = Index
			)
			else listboxtype.selection = 1
			
			-- Subtype  ID
			editt_SubID.text = MainAttr.SubtypeID
		)
	)

	-- Size of Block
	on dropdnSize selected i do 
	(
		Layer = VRLayers.GetSelected();
		MainAttr = custAttributes.get Layer VrageLayer_CubeBlockData
		MainAttr.Size = dropdnSize.items[i]
	)

	-- Type of Block
	on listboxtype selected i do 
	(
		Layer = VRLayers.GetSelected();
		MainAttr = custAttributes.get Layer VrageLayer_CubeBlockData
		MainAttr.TypeId = listboxtype.items[i]
	)

	on FilterTypes changed txt do 
	(
		if txt != "" then
		(
			listboxtype.items = #( )
			Myarray = #( )
			for n in VrageTempAllTypes where matchpattern n pattern:( "*" + txt + "*" ) do 
			(

				append Myarray n
			)
			print Myarray
			listboxtype.items = Myarray
		)
		else listboxtype.items = VrageTempAllTypes
	)

	-- Subtype  ID
	on editt_SubID changed txt do 
	(
		Layer = VRLayers.GetSelected();
		MainAttr = custAttributes.get Layer VrageLayer_CubeBlockData
		MainAttr.SubtypeID = editt_SubID.text
	)
)

rollout Vrage_ConstructionArrayRollout "VrageLayer_ConstructArray" width:250 height:200
(
	group "Actions"
	(
		button btnAddConstr "Add ConstructionStage" width:120 height:25 tooltip:"Add a Construction Stage."	align:#center across:1 
	)
	on btnAddConstr pressed do 
	(
		Layer = VrageConstructionLayer()
		Layer.Add Mainlayer:( VRLayers.GetSelected())
	)	
)

rollout Vrage_ConstructionRollout "VrageLayer_ConstructData" width:250 height:200
(
	group "Construction Settings"
	(
		label t1 "BuildPercent:" across:2
		spinner SpinPercent "" fieldwidth:40 range:[0, 100, 1] type:#integer align:#cente
	)

	on Vrage_ConstructionRollout open do 
	(
		Layer = VRLayers.GetSelected();
		MainAttr = custAttributes.get Layer VrageLayer_ConstructData
		SpinPercent.value = ( MainAttr.BuildPercent as Integer ) 
		--SpinID.value = (MainAttr.LODID as integer) 
	) 

	on SpinPercent changed val do 
	(
		Layer = VRLayers.GetSelected();
		MainAttr = custAttributes.get Layer VrageLayer_ConstructData
		MainAttr.BuildPercent = val
	) 

	timer clock "testClock" interval:50 
	on clock tick do
	( 
		Layer = VRLayers.GetSelected();
		if Layer != undefined do ( MainAttr = custAttributes.get Layer VrageLayer_ConstructData ) 
		if MainAttr != undefined do 
		(
			SpinPercent.value = ( MainAttr.BuildPercent as Integer ) 
		) 
	)

	group "Actions"
	(
		button btnValidate "Delete" width:120 height:25 tooltip:"Deletes this Layer."	align:#center across:2 
		--checkbox CHbox_ReSortLods "Resort after Delete" offset:[0,5] align:#right checked:true tooltip:"Resort after the deletion of this Layer."
		button btnAddLod "Add a Lod" width:120 height:25
	)

	on btnAddLod pressed do 
	(
		Layer = VrageLodLayer()
		Layer.Add Mainlayer:( VRLayers.GetSelected())
	)	

	on btnValidate pressed do 
	(
		Mainlayer = ( VRLayers.GetSelected()).getParent()

		--find current Construction index
		Idx_BuildStage = 0 ;
		for i = 1 to Mainlayer.getNumChildren() do 
		(
			ChildLayer = Mainlayer.getChild i
			layerRT = ChildLayer.layerAsRefTarg
			Constrttr = custAttributes.get layerRT VrageLayerData
			if Constrttr != undefined and Constrttr.Type == "VRageConstructstage" do Idx_BuildStage += 1
		)
		
		layerRT = ( VRLayers.GetSelected()).layerAsRefTarg
		if layerRT.ConstructionID < Idx_BuildStage then 
		(
			MyVRageLog.Warn ( "Can't delete Construction Layer if a higher  ID exists" + "\n" + "Current:" + ( layerRT.ConstructionID as string ) + " < Highest:" + ( Idx_BuildStage as string ) )
		)
		else 
		(
			VRLayers.Delete ( VRLayers.GetSelected())
		)
	)
)

rollout Vrage_LODRollout "VrageLayer_LODData" width:250 height:200
(
	group "LOD Settings"
	(
		label t1 "Draw Distance:" across:2
		spinner SpinLodDD "" fieldwidth:40 range:[0, 5000, 1] type:#integer align:#center
		label t2 "ID:" across:2
		spinner SpinID "" fieldwidth:40 range:[0, 10, 1] type:#integer align:#center enabled:false
	)

	on Vrage_LODRollout open do 
	(
		Layer = VRLayers.GetSelected();
		MainAttr = custAttributes.get Layer VrageLayer_LODData
		SpinLodDD.value = ( MainAttr.DrawDistance as Integer ) 
		SpinID.value = ( MainAttr.LODID as integer ) 
	) 

	on SpinLodDD changed val do 
	(
		Layer = VRLayers.GetSelected();
		MainAttr = custAttributes.get Layer VrageLayer_LODData
		MainAttr.DrawDistance = val
	) 

	on SpinID changed val do 
	(
		Layer = VRLayers.GetSelected();
		MainAttr = custAttributes.get Layer VrageLayer_LODData
		MainAttr.LODID = val
	) 

	timer clock "testClock" interval:50 
	on clock tick do
	( 
		Layer = VRLayers.GetSelected();
		if Layer != undefined do ( MainAttr = custAttributes.get Layer VrageLayer_LODData ) 
		if MainAttr != undefined do 
		(
			SpinLodDD.value = ( MainAttr.DrawDistance as Integer ) 
			SpinID.value = ( MainAttr.LODID as integer ) 
		) 
	)
	group "Actions"
	(
		button btnDelete "Delete" width:120 height:25 tooltip:"Deletes this Layer."	align:#center across:2 
		--	checkbox CHbox_ReSortLods "Resort after Delete" offset:[0,5] align:#right checked:true tooltip:"Resort LodIds after the deletion of this Layer."
	)

	on btnDelete pressed do 
	(
		Mainlayer = ( VRLayers.GetSelected()).getParent()
		Idx_Lod = 0 ;
		for i = 1 to Mainlayer.getNumChildren() do 
		(
			ChildLayer = Mainlayer.getChild i
			layerRT = ChildLayer.layerAsRefTarg
			LodAttr = custAttributes.get layerRT VrageLayerData
			if LodAttr != undefined and LodAttr.Type == "VRageLOD" do Idx_Lod += 1
		)
		layerRT = ( VRLayers.GetSelected()).layerAsRefTarg

		Idx_Lod -= 1
		if ( layerRT.LODID ) < Idx_Lod then 
		(
			MyVRageLog.Warn ( "Can't delete Lod Layer if a higher Lod ID exists" + "\n" + "Current LOD:" + ( layerRT.LODID as string ) + " < Highest LOD:" + ( Idx_Lod as string ) )
		)
		else 
		(
			VRLayers.Delete ( VRLayers.GetSelected())
		)
	)
)

rollout Vrage_CollisonRollout "VrageLayer Collison Data" width:250 height:200
(
	group "Create RigidBodies"	
	(
		button btn_RigidBox "Box" width:30 height:30 toolTip:"Box" align:#center across:5 
		button btn_RigidSphere "Sphere" width:30 height:30 toolTip:"Sphere" align:#center
		button btn_RigidCylinder "Cylinder" width:30 height:30 toolTip:"Cylinder" align:#center
		button btn_RigidMesh "Hull" width:30 height:30 toolTip:"Hull" align:#center
		button btn_RigidCapsule "Capsule" width:30 height:30 toolTip:"Capsule" align:#center enabled:false
		
		checkbox chbox_FitSelec "Fit to Selection" tooltip:"Fits the generated Rididbody to the selected Object. Generates an Convex Hull if mesh is choosen" align:#center
		
		button btn_Convertselection "Convert selection" width:100 height:25 toolTip:" Convert selected objects to rigid bodies." align:#center across:2
		button btn_StartConvexHulltool "Convex Hull Tool" width:100 height:25 toolTip:" " align:#center
		--	on btn_StartMountpoints pressed do filein "Mountpoint_GUI.ms"
	)

	on btn_RigidBox pressed do CreateRigidBodyObject "Box" chbox_FitSelec.checked 
	on btn_RigidSphere pressed do CreateRigidBodyObject "Sphere" chbox_FitSelec.checked 
	on btn_RigidCylinder pressed do CreateRigidBodyObject "Cylinder" chbox_FitSelec.checked 
	on btn_RigidMesh pressed do CreateRigidBodyObject "Hull" chbox_FitSelec.checked 

	on Vrage_CollisonRollout open do 
	(
		btn_RigidBox.images = #( "Standard_24i.bmp", undefined, 11, 1, 1, 1, 1, true, true )
		btn_RigidSphere.images = #( "Standard_24i.bmp", undefined, 11, 2, 2, 2, 2, false, true )
		btn_RigidCylinder.images = #( "Standard_24i.bmp", undefined, 11, 3, 3, 3, 3, false, true )
		btn_RigidMesh.images = #( "Extended_24i.bmp", undefined, 12, 5, 5, 5, 5, false, true )
		btn_RigidCapsule.images = #( "Extended_24i.bmp", undefined, 12, 9, 9, 9, 9, false, true )
	)

	timer clock "testClock" interval:5000 
	on clock tick do
	( 
		
	)

	group "Actions"
	(
		button btnDelete "Delete" width:120 height:25 tooltip:"Deletes this Layer."	align:#center across:2 
		--	checkbox CHbox_ReSortLods "Resort after Delete" offset:[0,5] align:#right checked:true tooltip:"Resort LodIds after the deletion of this Layer."
	)

	on btnDelete pressed do 
	(
		VRLayers.Delete ( VRLayers.GetSelected())
	)
)

rollout VrageModels "ModelData" width:200 height:200
(
	--	label lbl_LayernameA "Name: "  across: 2 
	--	label lbl_LayernameB "--" 
	--	label lbl_LayterTypeA "LayerType: " across: 2 
	--	label lbl_LayterTypeb "--" 
	--button theButton "+"   width:30 height:30 toolTip:"Apply new name" pos:[300, 40] 
	--button theButton1 "-" width:30 height:30 toolTip:"Apply new name" pos:[330, 40] 
	button butt_MAtlib "Material Browser" width:100 height:25 align:#center across:4
	button btn_Settings "Open Settings" width:100 height:25 toolTip:" " align:#center  offset:[25,0]
	button btn_LOg "Open Notifications" width:100 height:25 toolTip:" " align:#right offset:[61,0]
	button btn_ReloadVrage "\x21BA" width:25 height:25 toolTip:"Reloads Vrage Utilies. Use if scripts may not work." align:#right offset:[15,0]
	on btn_ReloadVrage pressed do fileIn(GetDir #userScripts+"\\VRageToolbox\\VRage_Startup.ms")

	on butt_MAtlib pressed do
	(
		try (MyVrageMatBrowser = ( Vrage_MaterialBrowser()).getForm() ) 
		catch 
		(
			fileIn ( GetDir #userScripts + "\\VRageToolbox\\Vrage_IO\\Vrage_MaterialLibrary.ms" )
			try (MyVrageMatBrowser = ( Vrage_MaterialBrowser()).getForm() ) 
			catch ( messagebox "Failed to open MaterialBrwoser" title:"Error!" )
		)
	) 

	on btn_Settings pressed do OpenSettings()	
	on btn_LOg pressed do VrageLogSys.CreateMessageRollout()

	timer clock "testClock" interval:10 --tick  every 2 sec
	on clock tick do
	( 
		i = VRLayers.GetSelected()
		if i != undefined then 
		(
			FullNameToFind = i.name
			MainAttr = custAttributes.get i VrageLayerData
			
			if MainAttr != undefined then 
			(
				--lbl_LayernameB.text =  FullNameToFind  
				--lbl_LayterTypeb.text =  MainAttr.Type
				if MainAttr.Type == "VRageConstructstage" then 
				addRollout Vrage_ConstructionRollout VRAGE_ModelUI 
				else try ( removeRollout Vrage_ConstructionRollout VRAGE_ModelUI ) catch () 

				if MainAttr.Type == "CubeBlockDef" then 
				addRollout Vrage_CubeBlockRollout VRAGE_ModelUI 
				else try ( removeRollout Vrage_CubeBlockRollout VRAGE_ModelUI ) catch () 

				if MainAttr.Type == "VRageLOD" then 
				addRollout Vrage_LODRollout VRAGE_ModelUI 
				else try ( removeRollout Vrage_LODRollout VRAGE_ModelUI ) catch () 

				if MainAttr.Type == "ConstructArrayDef" then 
				addRollout Vrage_ConstructionArrayRollout VRAGE_ModelUI 
				else try ( removeRollout Vrage_ConstructionArrayRollout VRAGE_ModelUI ) catch () 

				if MainAttr.Type == "CollisionDef" then 
				addRollout Vrage_CollisonRollout VRAGE_ModelUI 
				else try ( removeRollout Vrage_CollisonRollout VRAGE_ModelUI ) catch () 
			)
		)
		else 
		(
			try ( removeRollout Vrage_ConstructionRollout VRAGE_ModelUI ) catch () 
			try ( removeRollout Vrage_CubeBlockRollout VRAGE_ModelUI ) catch () 
			try ( removeRollout Vrage_LODRollout VRAGE_ModelUI ) catch () 
			try ( removeRollout Vrage_ConstructionArrayRollout VRAGE_ModelUI ) catch () 
			try ( removeRollout Vrage_CollisonRollout VRAGE_ModelUI ) catch () 
		)
	)
)

fn VrageModelLayer_ShowUI = 
(
	try ( cui.UnRegisterDialogBar VRAGE_ModelUI ) catch () 
	try ( closeRolloutFloater VRAGE_ModelUI ) catch () 
	VRAGE_ModelUI = newRolloutFloater "VRage Utilies" 350 600 450 300 
	addRollout VrageModels VRAGE_ModelUI border:true
	cui.RegisterDialogBar VRAGE_ModelUI style:#( #cui_floatable )
)

Tesxtthing = VrageCubeBlock()
Tesxtthing.CreateSkel "MyNewBlock"
--Tesxtthing.RenameAll  (LayerManager.getLayerFromName "NyNEwblock2") "NyNEwblock2"  "NyNEwblock3"
VrageModelLayer_ShowUI()