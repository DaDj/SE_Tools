/* 
This File handles all the Layer stuff
It implements:
	 - custom attributes to define what the layers are.
	 - custom attributes with corresponding layer data
	 - UI tool do modify this data + add/delete layers
*/

global VRAGE_ModelUI
global VrageTempAllTypes = #("CubeBlock","Cockpit","Gravity","Refinery","Armor")

-- Custom Attributes for Layer Data
VrageLayerData= attributes "VrageLayerData" attribID:#(0x5eac4f6e, 0xd624011)
(
	parameters main
	(
		Type type:#string 	default:"CubeBlockDef";
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
		SeName type:#string 	default:"MySEBlock";
	)
)

VrageLayer_CubeBlockData = attributes "VrageLayer_CubeBlockData"   attribID:#(0x20b6687b, 0x63bbfe0a)
(
	parameters main
	(
		Size type:#string default:"Large";
		TypeId type:#string	default:"CubeBlock";
		SubtypeID type:#string	default:"MyBlock";
	)
)

VrageLayer_BlockPartData = attributes "VrageLayer_BlockPartData" attribID:#(0x52819f64, 0x4bc544fb)
(
	parameters main
	(
		NumLod type:#integer default:1;
		NumConstruction type:#integer	default:0;
	)
)


VrageLayer_ConstructData = attributes "VrageLayer_ConstructData" attribID:#(0x4d367979, 0x6e68ad54)
(
	parameters main
	(
		ConstructionID type:#integer default:1;
		BuildPercent type:#integer default:50.0;
	)
)

VrageLayer_LODData = attributes "VrageLayer_LODData" attribID:#(0xdcaefca, 0x59c57e45)
(
	parameters main
	(
		DrawDistance type:#float default: 20.0;
		LODID type:#integer default: 0;
	)
)

-- Functions for the Layers
struct VRageLayers 
(
	fn CreateOrRenameLayer MyName MyOldName parent_layer:undefined = (
		if (LayerManager.getLayerFromName(MyOldName) == undefined) then (
			if (LayerManager.getLayerFromName(MyName) == undefined) then (
				layer = LayerManager.newLayer()
				layer.setname MyName
				layer.setParent parent_layer
			)
		)
		else 
		(
			layer = LayerManager.getLayerFromName(MyOldName)
			layer.setname  MyName
			layer.setParent parent_layer
		)
		layer
	),
	
	fn GetSelected =(
		layerExplorer = SceneExplorerManager.GetActiveExplorer()
		items = layerExplorer.SelectedItems()

		Layer = undefined
		for i in items where isKindOf i Base_Layer do
		(
			Layer = i
		)
		Layer
	),

	fn Delete LayerHandle = (
		--try 
		--(
			canDelete = (LayerHandle.canDelete()) and not (LayerManager.doesLayerHierarchyContainNodes LayerHandle.name)
			if canDelete then 
			(
				if LayerHandle.getNumChildren() > 0 then 
				(
					for i= 1 to (LayerHandle.getNumChildren()) do 
					(
					VRLayers.Delete (LayerHandle.getChild(i))
				--	LayerManager.deleteLayerByName ((LayerHandle.getChild(i)).name) 
					)
				)
				LayerManager.deleteLayerByName LayerHandle.name
			) 
			else
			(
				if LayerManager.doesLayerHierarchyContainNodes LayerHandle.name then 
				(MyVRageLog.Info ("Can't Delete Layer. Layers with Nodes/Objects in it can'#'t be deleted!") Show:true )
				else (MyVRageLog.Info ("Can't Delete Layer.") Show:true )
				
			) 
		--)
		--catch( MyVRageLog.Info ("Something went wreng while trying to delete LayerS") Show:true )
	)
)
VRLayers = VRageLayers()

struct VrageLodLayer
(
	fn Add Mainlayer:undefined =
	(
		If Mainlayer == undefined then Mainlayer = VRLayers.GetSelected()

		if Mainlayer != undefined then 
		(
			Attr = custAttributes.get Mainlayer VrageLayerData
			--find current LOD index
			Idx_Lod =0;
			for i=1 to Mainlayer.getNumChildren() do 
			(
				ChildLayer = Mainlayer.getChild i
				layerRT = ChildLayer.layerAsRefTarg
				LodAttr = custAttributes.get layerRT VrageLayerData
				if LodAttr != undefined and LodAttr.Type == "VRageLOD" do Idx_Lod += 1
			)
			
			if Attr != undefined then 
			(
				print Attr.Type
				if Attr.Type == "CubeBlockDef" or Attr.Type == "SubpartDef" or  Attr.Type == "VRageConstructstage" then 
				(
					Idx_Lod = Idx_Lod as string
					layer = VRLayers.CreateOrRenameLayer (Mainlayer.name + " #LOD" + Idx_Lod)  (Mainlayer.name + " #LOD" + Idx_Lod) parent_layer:(Mainlayer.LayerProperties)
					layerRT = layer.layerAsRefTarg
					custAttributes.add layerRT VrageLayerData
					custAttributes.add layerRT VrageLayer_LODData
					layerRT.Type = "VRageLOD"
					layerRT.LODID = Idx_Lod as Integer
					layerRT.DrawDistance =  20.0 + (Idx_Lod as Integer)*20.0
				)
			)
		)
		else MyVRageLog.Info ("No Layer selected") Show:true

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
			Idx_BuildStage =1;
			for i=1 to Mainlayer.getNumChildren() do 
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
					layer = VRLayers.CreateOrRenameLayer (Attr.SeName  + "Construction_" + Idx_BuildStage)  (Attr.SeName  + "Construction_" + Idx_BuildStage) parent_layer:(Mainlayer.LayerProperties)
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
		else MyVRageLog.Info ("No Layer selected") Show:true

	)
)

struct VrageCubeBlock
(
	MyDummy ="",
	-- Creates A Cubeblock with barebonex defintions (no lods ar anything)
	fn CreateSkel BlockName optional_param:unsupplied =
	(
		-- Create Main Layer
		Mainlayer = VRLayers.CreateOrRenameLayer BlockName  BlockName  parent_layer:(LayerManager.getLayer 0) 
		layerRT = Mainlayer.layerAsRefTarg
		custAttributes.add layerRT VrageLayerData
		custAttributes.add layerRT VrageLayer_CubeBlockData
		layerRT.SeName = BlockName
		-- Collision Stuff  (Main Model ofc) 
		layer = VRLayers.CreateOrRenameLayer (BlockName + " #Collision")  (BlockName + " #Collision") parent_layer:Mainlayer
		layerRT = layer.layerAsRefTarg
		custAttributes.add layerRT VrageLayerData
		layerRT.Type = "CollisionDef"
		layerRT.SeName = BlockName
		-- Dummies Layer
		layer = VRLayers.CreateOrRenameLayer (BlockName + " #Dummies")  (BlockName+ " #Dummies") parent_layer:Mainlayer
		layerRT = layer.layerAsRefTarg
		custAttributes.add layerRT VrageLayerData
		layerRT.Type = "DummiesDef"
		layerRT.SeName = BlockName

		-- Construction Layer
		layer = VRLayers.CreateOrRenameLayer (BlockName + " #Construction")  (BlockName + " #Construction") parent_layer:Mainlayer
		layerRT = layer.layerAsRefTarg
		custAttributes.add layerRT VrageLayerData
		layerRT.Type = "ConstructArrayDef"
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
		Attr.Type == "DummiesDef" 	then 
		(	
			Attr.SeName = NewName
			Layer.setName (ReplaceWords Layer.Name OldName NewName mIgnoreCase:true)
		)

		for i = 1 to Layer.getNumChildren() do
		(
			CurrentChildLayer= Layer.getChild  i
			RenameAll CurrentChildLayer OldName NewName

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
		dropdownlist dropdnSize "" items:#("Large","Small")   tooltip:"Size of the Block Grid (large =2.5m, Small: 0.25m)"  labelOnTop: false  Width:150 enabled: true align: #right

		label lbl_Type "Block Type" across:2 align: #left
		edittext FilterTypes "Filter" fieldWidth:100 labelOnTop:false align: #right
		
		label lbl_Filter"" across:2 align: #left
		listbox   listboxtype "" items:VrageTempAllTypes   tooltip:"Type of Block"  Width:150  Height:4  enabled: true align: #right 

		label lbl_SubID "Subtype ID" across:2 align: #left
		edittext editt_SubID "" fieldWidth:150 labelOnTop:true align: #right
	)

	group "Actions"
	(
		button btnAddLod "Add a Lod" width:120 height:25
		edittext editt_Rename "Rename:" fieldWidth:100 labelOnTop:false align: #right across:2 offset:[0,4] 
		button btnrenameBlock "Rename" width:120 height:25 
	)

	on btnAddLod pressed do 
	(
		Layer = VrageLodLayer()
		Layer.Add Mainlayer:(VRLayers.GetSelected())
	)

	on btnrenameBlock pressed do 
	(
		if editt_Rename.text != "" then 
		(
			
			if (queryBox ("Do you want to rename to: " + editt_Rename.text + "?")  beep:false) then 
			(
				Layer = VRLayers.GetSelected();
				Cubeblock = VrageCubeBlock()
				Cubeblock.RenameAll  (Layer) Layer.name editt_Rename.text 
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
			if MainAttr.Size == "Large" then dropdnSize.selection = 1 else  dropdnSize.selection = 2

			-- Type of Block
			if MainAttr.TypeId != undefined then
			(
				Index  = findItem VrageTempAllTypes MainAttr.TypeId
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
			listboxtype.items = #()
			Myarray = #()
			for n in VrageTempAllTypes where matchpattern n pattern:("*" + txt + "*") do 
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
		Layer.Add Mainlayer:(VRLayers.GetSelected())
	)	
)

rollout Vrage_ConstructionRollout "VrageLayer_ConstructData" width:250 height:200
(
	group "Construction Settings"
	(
		label t1 "BuildPercent:" across:2
		spinner SpinPercent "" fieldwidth:40 range:[0,100,1] type:#integer  align:#cente
	)

	on Vrage_ConstructionRollout open  do 
	(
		Layer = VRLayers.GetSelected();
		MainAttr = custAttributes.get Layer VrageLayer_ConstructData
		SpinPercent.value = (MainAttr.BuildPercent as Integer) 
		--SpinID.value = (MainAttr.LODID as integer) 
	) 

	on SpinPercent changed val  do 
	(
		Layer = VRLayers.GetSelected();
		MainAttr = custAttributes.get Layer VrageLayer_ConstructData
		MainAttr.BuildPercent = val
	) 

	timer clock "testClock" interval:50 
	on clock tick do
	( 
		Layer = VRLayers.GetSelected();
		if 	Layer != undefined do  ( MainAttr = custAttributes.get Layer VrageLayer_ConstructData) 
		if MainAttr != undefined do 
		(
			SpinPercent.value = (MainAttr.BuildPercent as Integer) 
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
		Layer.Add Mainlayer:(VRLayers.GetSelected())
	)	

	on btnValidate pressed do 
	(
		Mainlayer = (VRLayers.GetSelected()).getParent()

		--find current Construction index
		Idx_BuildStage =0;
		for i=1 to Mainlayer.getNumChildren() do 
		(
			ChildLayer = Mainlayer.getChild i
			layerRT = ChildLayer.layerAsRefTarg
			Constrttr = custAttributes.get layerRT VrageLayerData
			if Constrttr != undefined and Constrttr.Type == "VRageConstructstage" do Idx_BuildStage += 1
		)
		
		layerRT = (VRLayers.GetSelected()).layerAsRefTarg
		if layerRT.ConstructionID < Idx_BuildStage then 
		(
			MyVRageLog.Warn("Can't delete Construction Layer if a higher  ID exists" + "\n" + "Current:" + (layerRT.ConstructionID as string) + " < Highest:"+ (Idx_BuildStage as string))
		)
		else 
		(
			VRLayers.Delete (VRLayers.GetSelected())
		)
	)
)

rollout Vrage_LODRollout "VrageLayer_LODData" width:250 height:200
(
	group "LOD Settings"
	(
		label t1 "Draw Distance:" across:2
		spinner SpinLodDD "" fieldwidth:40 range:[0,200,1] type:#integer  align:#center
		label t2 "ID:" across:2
		spinner SpinID "" fieldwidth:40 range:[0,10,1] type:#integer  align:#center enabled:false
	)

	on Vrage_LODRollout open  do 
	(
		Layer = VRLayers.GetSelected();
		MainAttr = custAttributes.get Layer VrageLayer_LODData
		SpinLodDD.value = (MainAttr.DrawDistance as Integer) 
		SpinID.value = (MainAttr.LODID as integer) 
	) 

	on SpinLodDD changed val  do 
	(
		Layer = VRLayers.GetSelected();
		MainAttr = custAttributes.get Layer VrageLayer_LODData
		MainAttr.DrawDistance = val
	) 

	on SpinID changed val  do 
	(
		Layer = VRLayers.GetSelected();
		MainAttr = custAttributes.get Layer VrageLayer_LODData
		MainAttr.LODID = val
	) 

	timer clock "testClock" interval:50 
	on clock tick do
	( 
		Layer = VRLayers.GetSelected();
		if 	Layer != undefined do  ( MainAttr = custAttributes.get Layer VrageLayer_LODData) 
		if MainAttr != undefined do 
		(
			SpinLodDD.value = (MainAttr.DrawDistance as Integer) 
			SpinID.value = (MainAttr.LODID as integer) 
		) 
	)
	group "Actions"
	(
		button btnDelete "Delete" width:120 height:25 tooltip:"Deletes this Layer."	align:#center across:2 
		--	checkbox CHbox_ReSortLods "Resort after Delete" offset:[0,5] align:#right checked:true tooltip:"Resort LodIds after the deletion of this Layer."
	)

	on btnDelete pressed do 
	(
		Mainlayer = (VRLayers.GetSelected()).getParent()
		Idx_Lod =0;
		for i=1 to Mainlayer.getNumChildren() do 
		(
			ChildLayer = Mainlayer.getChild i
			layerRT = ChildLayer.layerAsRefTarg
			LodAttr = custAttributes.get layerRT VrageLayerData
			if LodAttr != undefined and LodAttr.Type == "VRageLOD" do Idx_Lod += 1
		)
		layerRT = (VRLayers.GetSelected()).layerAsRefTarg

		if (layerRT.LODID+1) < Idx_Lod then 
		(
			MyVRageLog.Warn("Can't delete Lod Layer if a higher Lod ID exists" + "\n" + "Current LOD:" + ((layerRT.LODID+1) as string) + " < Highest LOD:"+ (Idx_Lod as string))
		)
		else 
		(
			VRLayers.Delete (VRLayers.GetSelected())
		)
	)
)

rollout VrageModels "ModelData" width:200 height:200
(
	--dropdownlist Model_DD "Model" items:#("1/2", "1/4", "1/8", "1/16")
	--dotnetcontrol tv "TreeView" width:240 height:400  pos:[0, 20]
	label lbl_LayernameA "Name: "  across: 2 
	label lbl_LayernameB "--" 
	label lbl_LayterTypeA "LayerType: " across: 2 
	label lbl_LayterTypeb "--" 
	--button theButton "+"   width:30 height:30 toolTip:"Apply new name" pos:[300, 40] 
	--button theButton1 "-" width:30 height:30 toolTip:"Apply new name" pos:[330, 40] 
	
	timer clock "testClock" interval:10 --tick  every 2 sec
	on clock tick do
	( 
		i = VRLayers.GetSelected()
		if i != undefined then 
		(
			FullNameToFind =  i.name
			MainAttr = custAttributes.get i VrageLayerData
			
			if MainAttr != undefined then 
			(
				lbl_LayernameB.text =  FullNameToFind  
				lbl_LayterTypeb.text =  MainAttr.Type
				
				if MainAttr.Type == "VRageConstructstage" then 
				addRollout Vrage_ConstructionRollout VRAGE_ModelUI 
				else try (removeRollout Vrage_ConstructionRollout VRAGE_ModelUI ) catch () 

				if MainAttr.Type == "CubeBlockDef" then 
				addRollout Vrage_CubeBlockRollout VRAGE_ModelUI 
				else try (removeRollout Vrage_CubeBlockRollout VRAGE_ModelUI ) catch ()  

				if MainAttr.Type == "VRageLOD" then 
				addRollout Vrage_LODRollout VRAGE_ModelUI 
				else try (removeRollout Vrage_LODRollout VRAGE_ModelUI ) catch ()  

				if MainAttr.Type == "ConstructArrayDef" then 
				addRollout Vrage_ConstructionArrayRollout VRAGE_ModelUI 
				else try (removeRollout Vrage_ConstructionArrayRollout VRAGE_ModelUI ) catch ()  
			)
		)
		else 
		(
			try (removeRollout Vrage_ConstructionRollout VRAGE_ModelUI ) catch () 
			try (removeRollout Vrage_CubeBlockRollout VRAGE_ModelUI ) catch () 
			try (removeRollout Vrage_LODRollout VRAGE_ModelUI ) catch () 
			try (removeRollout Vrage_ConstructionArrayRollout VRAGE_ModelUI ) catch ()  
		)
	)
)

fn VrageModelLayer_ShowUI = 
(
	try (cui.UnRegisterDialogBar VRAGE_ModelUI) catch () 	
	try (closeRolloutFloater VRAGE_ModelUI) catch () 
	VRAGE_ModelUI = newRolloutFloater  "VRage Utilies" 350 600 450 300 
	addRollout VrageModels VRAGE_ModelUI border:true
	cui.RegisterDialogBar VRAGE_ModelUI style:#(#cui_floatable)
)

Tesxtthing = VrageCubeBlock()
Tesxtthing.CreateSkel "MyNewBlock"
--Tesxtthing.RenameAll  (LayerManager.getLayerFromName "NyNEwblock2") "NyNEwblock2"  "NyNEwblock3"
VrageModelLayer_ShowUI()