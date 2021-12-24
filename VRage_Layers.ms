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
		VRType type:#string default:"CubeBlockDef" ;
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

VrageLayer_SubpartPartData = attributes "VrageLayer_SubpartPartData" attribID:#( 0xd6eac3c, 0x44c8462e )
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
	AutoSwitchLayer = true,
	AutoHideLAyer = false,
	
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
		items = undefined
		if layerExplorer != undefined then items = layerExplorer.SelectedItems() 
		
		Layer = undefined
		if items != undefined then 
		(
			for i in items where isKindOf i Base_Layer do
			(
				Layer = i
			)
		)
		
		if AutoSwitchLayer == true then 
		(
			-- Set the currently selected layer automatically as the current layer
			if Layer != undefined then Layer.current = true 
			if Layer != undefined then Layer.ishidden = false 
			-- Set the layer to the first selected object if no Layer is directly selected
			if Layer == undefined then 
			(
				if selection[1] != undefined then 
				(
					Layer = selection[1].layer.layerAsRefTarg
					selection[1].layer.current = true
				)
			)
		)
		
		-- Following codes attempts to hide the other layers when the checkbox is checked.
		if AutoHideLAyer == true then 
		(
			for L = 1 to LayerManager.count do
			(
				layer2 = ( layermanager.getlayer ( L - 1 ) )
				MainAttr = custAttributes.get ( layer2.layerAsRefTarg ) VrageLayerData
				if MainAttr != undefined then 
				(
					Thecurrentlayer = false ;
					if MainAttr.VRType== "VRageLOD" or MainAttr.VRType== "CollisionDef" then --dont hide or MainAttr.Type == "DummiesDef" for now...
					(
						if layer2.current == true then layer2.ishidden = false else layer2.ishidden = true
					)
				)
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
						VRLayers.Delete ( LayerHandle.getChild ( i ) )
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
				if LodAttr != undefined and LodAttr.VRType== "VRageLOD" do Idx_Lod += 1
			)
			
			if Attr != undefined then 
			(
				--print Attr.Type
				if Attr.VRType== "CubeBlockDef" or Attr.VRType== "SubpartDef" or Attr.VRType== "VRageConstructstage" then 
				(
					Idx_Lod = Idx_Lod as string
					layer = VRLayers.CreateOrRenameLayer ( Mainlayer.name + " #LOD" + Idx_Lod ) ( Mainlayer.name + " #LOD" + Idx_Lod ) parent_layer:( Mainlayer.LayerProperties )
					layerRT = layer.layerAsRefTarg
					custAttributes.add layerRT VrageLayerData
					custAttributes.add layerRT VrageLayer_LODData
					layerRT.VRType= "VRageLOD"
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
				if Constrttr != undefined and Constrttr.VRType== "VRageConstructstage" do Idx_BuildStage += 1
			)
			
			if Attr != undefined then 
			(
				--print Attr.Type
				if Attr.VRType== "ConstructArrayDef" then 
				(
					Idx_BuildStage = Idx_BuildStage as string
					layer = VRLayers.CreateOrRenameLayer ( Attr.SeName + "Construction_" + Idx_BuildStage ) ( Attr.SeName + "Construction_" + Idx_BuildStage ) parent_layer:( Mainlayer.LayerProperties )
					layerRT = layer.layerAsRefTarg
					custAttributes.add layerRT VrageLayerData
					custAttributes.add layerRT VrageLayer_ConstructData
					layerRT.VRType= "VRageConstructstage"
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

struct VrageSubpartLayer
(
	fn Add Mainlayer:undefined Name:undefined =
	(
		Attr = undefined
		ParentLayerDummies = undefined 
		ParentLayer = undefined

		if Mainlayer == undefined then Mainlayer = VRLayers.GetSelected()
		if Mainlayer != undefined then ( Attr = custAttributes.get Mainlayer VrageLayerData )
		if Attr != undefined and Attr.VRType== "SubPartArray" then 
		(
			ParentLayer = Mainlayer.getParent() --Cubeblock or a Subpartdef
			if ParentLayer != undefined then 
			( -- trying to find the Dummie layer in which the dummy for the subpart has to be placed
				layerRT = ParentLayer.layerAsRefTarg
				layerRT.SeName
				ParentLayerDummies = ( LayerManager.getLayerFromName ( layerRT.SeName + " #Dummies" ) ).layerAsRefTarg
				if ParentLayerDummies.VRType!= "DummiesDef" then ( ParentLayerDummies = undefined )
			) 
			if ParentLayerDummies != undefined then 
			(
				--1. Place the Dummy
				--2. Create the Subpart Layer
			)
		)
	)
)
--test = VrageSubpartLayer()
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
		custAttributes.add layerRT VrageLayer_IconData
		layerRT.SeName = BlockName
		-- Collision Stuff  (Main Model ofc) 
		layer = VRLayers.CreateOrRenameLayer ( BlockName + " #Collision" ) ( BlockName + " #Collision" ) parent_layer:Mainlayer
		layerRT = layer.layerAsRefTarg
		custAttributes.add layerRT VrageLayerData
		layerRT.VRType= "CollisionDef"
		layerRT.SeName = BlockName
		-- Dummies Layer
		layer = VRLayers.CreateOrRenameLayer ( BlockName + " #Dummies" ) ( BlockName + " #Dummies" ) parent_layer:Mainlayer
		layerRT = layer.layerAsRefTarg
		custAttributes.add layerRT VrageLayerData
		layerRT.VRType= "DummiesDef"
		layerRT.SeName = BlockName

		-- Construction Layer
		layer = VRLayers.CreateOrRenameLayer ( BlockName + " #Construction" ) ( BlockName + " #Construction" ) parent_layer:Mainlayer
		layerRT = layer.layerAsRefTarg
		custAttributes.add layerRT VrageLayerData
		layerRT.VRType= "ConstructArrayDef"
		layerRT.SeName = BlockName	

		-- Subpart Layer
		layer = VRLayers.CreateOrRenameLayer ( BlockName + " #Subparts" ) ( BlockName + " #Subparts" ) parent_layer:Mainlayer
		layerRT = layer.layerAsRefTarg
		custAttributes.add layerRT VrageLayerData
		layerRT.VRType= "SubPartArray"
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
		if Attr.VRType== "CubeBlockDef" or 
		Attr.VRType== "SubPartArray" or 
		Attr.VRType== "VRageConstructstage" or
		Attr.VRType== "CollisionDef" or 
		Attr.VRType== "ConstructArrayDef" or 
		Attr.VRType== "VRageLOD" or 
		Attr.VRType== "DummiesDef" then 
		(	
			Attr.SeName = NewName
			Layer.setName ( ReplaceWords Layer.Name OldName NewName mIgnoreCase:true )
		)

		if Attr.VRType!= "SubPartArray" then
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
	--button btnValidate "Validate" width:120 height:25 tooltip:"Check if all expected data/Layer exist"	align:#right
	group "CubeBlock Settings"
	(
		label lbl_Size "Block Size" across:2 align: #left
		dropdownlist dropdnSize "" items:#( "Large", "Small" ) tooltip:"Size of the Block Grid (large =2.5m, Small: 0.25m)" labelOnTop: false Width:150 enabled: true align: #right

		--label lbl_Type "Block Type" across:2 align: #left
		--edittext FilterTypes "Filter" fieldWidth:100 labelOnTop:false align: #right
		label lbl_ID "Type ID" across:2 align: #left
		edittext editt_TypeID "" fieldWidth:120 labelOnTop:true align: #right \ 
		toolTip:"Type of Block. If no valid is entered, a default Cubeblock will be assumed"
		button btnSearch "..." width:25 height:20 pos:[72, 52] \
		toolTip:"Open List of existing Types."	images: #( VRageIcons, VRageIcons, VRageIcoLeng, 25, 25, 25, 25 )
		--label lbl_Filter "" across:2 align: #left
		--listbox listboxtype "" items:VrageTempAllTypes tooltip:"Type of Block" Width:150 Height:4 enabled: true align: #center 

		label lbl_SubID "Subtype ID" across:2 align: #left
		edittext editt_SubID "" fieldWidth:120 labelOnTop:true align: #right
	)

	group "Actions"
	(
		button btnAddLod "Add a Lod" width:100 height:25 align: #center across:2 \
		toolTip:"Add Lod"	images: #( VRageIcons, VRageIcons, VRageIcoLeng, 28, 28, 28, 28 )

		label lbl_fake1 "" align: #left
		button btnrenameBlock "Rename:" width:100 height:25 align: #center across:2
		edittext editt_Rename "" fieldWidth:100 labelOnTop:true offset:[0, 4] align: #right 
		
	)


	--button 'Btn_Import' "Import" width:100 height:25 toolTip:"Imports an Fbx from the ModSDK" align:#center across:2
	--on Prep_scene pressed do MySE.run "Scene_Setup.ms"	
	
	button Btn_export "Export" width:230 height:25 align:#center \
	toolTip:"Export: Generates  MWM file/s from the selected Block/s" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 12, 12, 12, 12 )
	

	on Btn_export pressed do OpenVrageExport()

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
				--listboxtype.selection = Index
			)
			--else listboxtype.selection = 1
			
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
		button btnAddConstr "Add ConstructionStage" width:100 height:25 align:#center across:2 \
		tooltip:"Add a Construction Stage." images: #( VRageIcons, VRageIcons, VRageIcoLeng, 29, 29, 29, 29 )
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
		button btnValidate "Delete" width:100 height:25 align:#center across:2 \
		tooltip:"Deletes this Layer." images: #( VRageIcons, VRageIcons, VRageIcoLeng, 18, 18, 18, 18 )
		--checkbox CHbox_ReSortLods "Resort after Delete" offset:[0,5] align:#right checked:true tooltip:"Resort after the deletion of this Layer."
		button btnAddLod "Add a Lod" width:100 height:25 \
		tooltip:"Add a Lod" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 28, 28, 28, 28 )
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
			if Constrttr != undefined and Constrttr.VRType== "VRageConstructstage" do Idx_BuildStage += 1
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

rollout Vrage_LODRollout "VrageLayer_LODData" width:200 height:200
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
		button btnDelete "Delete" width:100 height:25 align:#center across:2 \
		tooltip:"Deletes this Layer." images: #( VRageIcons, VRageIcons, VRageIcoLeng, 18, 18, 18, 18 )
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
			if LodAttr != undefined and LodAttr.VRType== "VRageLOD" do Idx_Lod += 1
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

rollout Vrage_CollisonRollout "VrageLayer Collison Data" width:200 height:200
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
		--	button btnDelete "Delete" width:100 height:25	align:#center across:2 \
		--		tooltip:"Deletes this Layer." images: #(VRageIcons, VRageIcons, VRageIcoLeng,18,18,18,18)
		--	checkbox CHbox_ReSortLods "Resort after Delete" offset:[0,5] align:#right checked:true tooltip:"Resort LodIds after the deletion of this Layer."
	)
	/*	on btnDelete pressed do 
	(
		VRLayers.Delete ( VRLayers.GetSelected())
	)*/
)

rollout Vrage_IconRollout "CubeBlock Icon" width:200 height:200 
( -- UI for the Icon rendering.
	checkbutton btn_IconMode "Icon Mode" width:230 height:25  align:#center  \
		toolTip:"Icon Mode on/off" --images: #( VRageIcons, VRageIcons, VRageIcoLeng, 27, 27,27, 27 )



	imgTag the_bmp width:100 height:100 align:#left across:2

	button btn_Setup "Reset" width:40 height:25 align:#right pos:[192, 70] \
		toolTip:"recreate the Camera Setup if its lost or if it needs to be reset." images: #( VRageIcons, VRageIcons, VRageIcoLeng, 3, 3, 3, 3 )

	colorpicker theColor "Tint Color:" color:[132, 170, 251905] modal:false align:#right pos:[135, 40] 

	button btn_Preview "Preview" width:25 height:25 toolTip:"Generates a preview of the Icon" align:#righ pos:[3, 125]  \
		toolTip:"Icon Mode on/off" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 32, 32,32, 32 )

	button btn_CreateIcon "Create Icon" width:199 height:25 toolTip:"Box" align:#right pos:[33, 125]
		toolTip:"Creates the Icon" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 12, 12,12, 12 )

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
		MyIcon = VRage_Icon()
		if Layer != undefined do 
		(
			MyIcon.CloseDownObjects Layer
		)
	)

	on btn_IconMode changed state do 
	(
		Layer = ( VRLayers.GetSelected()) ;
		MyIcon = VRage_Icon()
		if Layer != undefined do 
		(
			if state == on then 
			(
				MyIcon.SetupObjects Layer activate:true
			)
			else 
			(
				MyIcon.CloseDownObjects Layer 
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
			MyIcon = VRage_Icon()
			theBmp = MyIcon.RenderIcon 300 300 Layer:Layer TintColor:( theColor.color )
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
			MyIcon = VRage_Icon() 
			MyIcon = MyIcon.SetupObjects Layer reset:true	
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
			MyIcon = VRage_Icon()
			theBmp = MyIcon.RenderIcon 128 128 Layer:Layer TintColor:( theColor.color )
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

rollout VrageModels "VrageToolbox" width:200 height:200
(
	button btn_Help "\x2699" width:20 height:20 align:#center pos:[120, 0] \
	toolTip:"Opens the Documentation/Help" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 17, 17, 17, 17 )

	button btn_Settings "\x2699" width:20 height:20 align:#center pos:[150, 0] \
	toolTip:"Opens the VrageToolbox Settings" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 5, 5, 5, 5 )

	button btn_LOg "Open Notifications" width:20 height:20 align:#center pos:[180, 0] \ 
	toolTip:"Opens the VrageToolbox Notifications" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 2, 2, 2, 2 )

	button btn_ReloadVrage "\x21BA" width:20 height:20 align:#right pos:[210, 0] \
	toolTip:"Reloads Vrage Utilies. Use if scripts may not work." images: #( VRageIcons, VRageIcons, VRageIcoLeng, 3, 3, 3, 3 )
	
	

	button butt_Import "Import" width:30 height:30 align:#center pos:[5, 30] \
	toolTip:"Import an FBX" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 11, 11, 11, 11 )

	button butt_CreatMod "Create Mod" width:30 height:30 align:#center pos:[40, 30] \
	toolTip:"Creates Layer Setup for Block/Character/Model" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 26, 26, 26, 26 )

	button butt_MAtlib "Material Browser" width:30 height:30 align:#center pos:[85, 30] \ 
	toolTip:"Opens the Material Browser" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 4, 4, 4, 4 )
	

	groupBox group1 "" pos:[0, 20] width:75 height:45
	groupBox group4 "" pos:[80, 20] width:75 height:45
	groupBox group2 "" pos:[160, 20] width:75 height:45 

	checkbutton btn_MAgicLayer "\x21BA" width:20 height:30 align:#right pos:[190, 30] \
	toolTip:"Only show Objects in selected Layer" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 23, 23, 23, 23 )
	
	checkbutton btn_SwitchLayer "\x21BA" width:20 height:30 align:#right pos:[165, 30] checked:true \
	toolTip:"Automatically switch to selected Layer" images: #( VRageIcons, VRageIcons, VRageIcoLeng, 31, 31, 31, 31 )


	on VrageModels open do ()

	on btn_ReloadVrage pressed do fileIn ( GetDir #userScripts + "\\VRageToolbox\\VRage_Startup.ms" )
	
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

	on btn_Settings pressed do OpenSettings()	
	
	on btn_LOg pressed do VrageLogSys.CreateMessageRollout()

	on butt_CreatMod pressed do 
	(
		Testthing = VrageCubeBlock();
		Testthing.CreateSkel "MyNewBlock" ;

	)

	timer clock "testClock" interval:10 --tick  every 2 sec
	on clock tick do
	( 
		
		if btn_MAgicLayer.checked == true then VRLayers.AutoHideLAyer = true else VRLayers.AutoHideLAyer = false
		if btn_SwitchLayer.checked == true then VRLayers.AutoSwitchLayer = true else VRLayers.AutoSwitchLayer = false

		i = VRLayers.GetSelected()
		if i != undefined then 
		(
			--FullNameToFind = i.name
			MainAttr = custAttributes.get i VrageLayerData
			
			if MainAttr != undefined then 
			(
				--lbl_LayernameB.text =  FullNameToFind  
				--lbl_LayterTypeb.text =  MainAttr.Type
				if MainAttr.VRType== "VRageConstructstage" then 
				addRollout Vrage_ConstructionRollout VRAGE_ModelUI 
				else try ( removeRollout Vrage_ConstructionRollout VRAGE_ModelUI ) catch () 

				if MainAttr.VRType== "CubeBlockDef" then 
				(
					addRollout Vrage_CubeBlockRollout VRAGE_ModelUI 
					addRollout Vrage_IconRollout VRAGE_ModelUI rolledUp:true
				)
				else try 
				( 
					removeRollout Vrage_CubeBlockRollout VRAGE_ModelUI 
					removeRollout Vrage_IconRollout VRAGE_ModelUI 				
				) catch () 

				if MainAttr.VRType== "VRageLOD" then 
				addRollout Vrage_LODRollout VRAGE_ModelUI 
				else try ( removeRollout Vrage_LODRollout VRAGE_ModelUI ) catch () 

				if MainAttr.VRType== "ConstructArrayDef" then 
				addRollout Vrage_ConstructionArrayRollout VRAGE_ModelUI 
				else try ( removeRollout Vrage_ConstructionArrayRollout VRAGE_ModelUI ) catch () 

				if MainAttr.VRType== "CollisionDef" then 
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
			try ( removeRollout Vrage_IconRollout VRAGE_ModelUI ) catch () 
		)

	)
)

fn VrageModelLayer_ShowUI = 
(
	try ( cui.UnRegisterDialogBar VRAGE_ModelUI ) catch () 
	try ( closeRolloutFloater VRAGE_ModelUI ) catch () 
	VRAGE_ModelUI = newRolloutFloater "VRage Utilies" 250 600 450 300 
	addRollout VrageModels VRAGE_ModelUI border:true
	cui.RegisterDialogBar VRAGE_ModelUI style:#( #cui_dock_all, #cui_dock_vert, #cui_floatable )
	cui.DockDialogBar VRAGE_ModelUI #cui_dock_left
)


--Tesxtthing.RenameAll  (LayerManager.getLayerFromName "NyNEwblock2") "NyNEwblock2"  "NyNEwblock3"
VrageModelLayer_ShowUI();