/* 
This File handles all the Layer stuff
It implements:
	 - custom attributes to define what the layers are.
	 - custom attributes with corresponding layer data
	 - UI tool do modify this data + add/delete layers
*/

-- intialize Materiallibrary if its lost...
if Vrage_MaterialBrowser == undefined then 
(
	fileIn ( GetDir #userScripts + "\\VRageToolbox\\Vrage_IO\\Vrage_MaterialLibrary.ms" )
)



global VRAGE_ModelUI
global VrageTempAllTypes = #( "CubeBlock", "Cockpit", "Gravity", "Refinery", "Armor" )


-- Custom Attributes for Layer Data 
VrageLayerData= attributes "VrageLayerData" attribID:#( 0x5eac4f6e, 0xd624011 )
(
	Parameters main
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

-- Functions for the LayerHandling
struct VRageLayers 
(
	AutoSwitchLayer = true,
	AutoHideLAyer = false,
	
	CubeBlock = "CubeBlockDef", -- Info regarding cubeblockstoff gridsize, defintion etc.	
	Collision = "CollisionDef",-- Collision ofc
	Dummies = "DummiesDef", 
	LOD = "VRageLOD",
	SubPartArray = "SubPartArray",
	SubPart = "	SubpartDef",
	ConstructArray = "ConstructArrayDef",--main layer under which the buildstages are.
	Construction = "VRageConstructstage",
	
	fn CreateOrRenameLayer MyName MyOldName parent_layer:undefined = 
	(
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
	
	fn GetSelected = 
	(
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
					if MainAttr.VRType == "VRageLOD" or MainAttr.VRType == "CollisionDef" then --dont hide or MainAttr.Type == "DummiesDef" for now...
					(
						if layer2.current == true then layer2.ishidden = false else layer2.ishidden = true
					)
				)
			)
		)
		Layer
	),

	fn Delete LayerHandle = 
	(
		try 
		(
			canDelete = ( LayerHandle.canDelete()) and not ( LayerManager.doesLayerHierarchyContainNodes LayerHandle.name )
			if canDelete then 
			(
				if LayerHandle.getNumChildren() > 0 then 
				(
					for i in LayerHandle.getNumChildren() to 1 by -1  do 
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
				( MyVRageLog.Info ( "Can't Delete Layer. Layers with Nodes/Objects in it can't be deleted!" ) Show:true )
				else ( MyVRageLog.Info ( "Can't Delete Layer." ) Show:true )
				
			) 
		)
		catch ( MyVRageLog.Info ( "Something went wrong while trying to delete Layer/s" ) Show:true )
	),

	fn GetObjsOfLayer TheLayer = 
	(
		TheLayer.nodes &Objs
		/*
		TheLayer.select true
		Objs = selection as array
		deselect selection
		TheLayer.select false
		*/
		Objs 
	),

	fn IsTypeof TheLayer Type= 
	(
		if TheLayer != undefined then 
		( 	State = false
			
			Currentlayer = TheLayer.layerAsRefTarg
			MainAttr = custAttributes.get Currentlayer VrageLayerData
			if MainAttr != undefined then 
			(
				if Currentlayer.VrageLayerData.VRType == Type then State = true 
			)
			
		)
		State
	),

	fn GetChildofType TheLayer Type = 
	(
		TheChilds = #()
		TheLayer = TheLayer.layerAsRefTarg
		for i=1 to TheLayer.getNumChildren() do 
		(
			if (IsTypeof (TheLayer.getChild i) Type) then append TheChilds (TheLayer.getChild i)
		)
		TheChilds
	),

	fn FindMainTypes = 
	(--Returns all Maintypes in Children of "Default" Layer ...like CubeBlock for example
		DefaultLayer = (LayerManager.getLayerFromName "0"); --should ALWAYS exist
		TheMainObjs = #()
		for i=1 to DefaultLayer.getNumChildren() do 
		(
			if (IsTypeof (DefaultLayer.getChild  i) CubeBlock) then append TheMainObjs (DefaultLayer.getChild  i)
		)
		TheMainObjs
	)
)
VRLayers = VRageLayers()

--Load the Layer Types and Funcstions:
fileIn ( GetDir #userScripts + "\\VRageToolbox\\Vrage_Scene\\Vrage_LodLayer.ms" )
fileIn ( GetDir #userScripts + "\\VRageToolbox\\Vrage_Scene\\VRage_ConstructionLayer.ms" )
fileIn ( GetDir #userScripts + "\\VRageToolbox\\VRage_Icon.ms" )
fileIn ( GetDir #userScripts + "\\VRageToolbox\\Vrage_Scene\\VRage_CubeBlockLayer.ms" )
fileIn ( GetDir #userScripts + "\\VRageToolbox\\Vrage_Scene\\VRage_SubpartLayer.ms" )

--  Rollouts for Layer Types

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


rollout VrageModels "VrageToolbox" width:200 height:200
(
	on VrageModels open do ()
	timer clock "testClock" interval:10 --tick  every 2 sec
	on clock tick do
	( 
		
		--if btn_MAgicLayer.checked == true then VRLayers.AutoHideLAyer = true else VRLayers.AutoHideLAyer = false
		--if btn_SwitchLayer.checked == true then VRLayers.AutoSwitchLayer = true else VRLayers.AutoSwitchLayer = false

		i = VRLayers.GetSelected()
		if i != undefined then 
		(
			--FullNameToFind = i.name
			MainAttr = custAttributes.get i VrageLayerData
			
			if MainAttr != undefined then 
			(
				--lbl_LayernameB.text =  FullNameToFind  
				--lbl_LayterTypeb.text =  MainAttr.Type
				if MainAttr.VRType == "VRageConstructstage" then 
				addRollout Vrage_ConstructionRollout VRAGE_ModelUI 
				else try ( removeRollout Vrage_ConstructionRollout VRAGE_ModelUI ) catch () 

				if MainAttr.VRType == "CubeBlockDef" then 
				(
					addRollout Vrage_CubeBlockRollout VRAGE_ModelUI 
					--addRollout Vrage_SceneRoll VRAGE_ModelUI
					addRollout Vrage_CubeBlock_BBBoxRollout VRAGE_ModelUI 
					addRollout Vrage_IconRollout VRAGE_ModelUI rolledUp:true

					
				)
				else try 
				( 
					removeRollout Vrage_CubeBlock_BBBoxRollout VRAGE_ModelUI 
					removeRollout Vrage_CubeBlockRollout VRAGE_ModelUI 
					removeRollout Vrage_IconRollout VRAGE_ModelUI 
				) catch () 

				if MainAttr.VRType == "VRageLOD" then 
				addRollout Vrage_LODRollout VRAGE_ModelUI 
				else try ( removeRollout Vrage_LODRollout VRAGE_ModelUI ) catch () 

				if MainAttr.VRType == "ConstructArrayDef" then 
				addRollout Vrage_ConstructionArrayRollout VRAGE_ModelUI 
				else try ( removeRollout Vrage_ConstructionArrayRollout VRAGE_ModelUI ) catch () 

				if MainAttr.VRType == "CollisionDef" then 
				addRollout Vrage_CollisonRollout VRAGE_ModelUI 
				else try ( removeRollout Vrage_CollisonRollout VRAGE_ModelUI ) catch () 

				if MainAttr.VRType == VRLayers.SubPartArray then 
				addRollout Vrage_SubpartsArrayRollout VRAGE_ModelUI 
				else try ( removeRollout Vrage_SubpartsArrayRollout VRAGE_ModelUI ) catch () 
				
			)
		)
		else 
		(
			try ( removeRollout Vrage_ConstructionRollout VRAGE_ModelUI ) catch () 
			try ( 	removeRollout Vrage_CubeBlock_BBBoxRollout VRAGE_ModelUI  ) catch ()
			try ( removeRollout Vrage_CubeBlockRollout VRAGE_ModelUI ) catch () 
			try ( removeRollout Vrage_LODRollout VRAGE_ModelUI ) catch () 
			try ( removeRollout Vrage_ConstructionArrayRollout VRAGE_ModelUI ) catch () 
			try ( removeRollout Vrage_CollisonRollout VRAGE_ModelUI ) catch () 
			try ( removeRollout Vrage_IconRollout VRAGE_ModelUI ) catch () 
			try ( removeRollout Vrage_SubpartsArrayRollout VRAGE_ModelUI ) catch () 
		)

	)
)

fn VrageModelLayer_ShowUI = 
(
	try ( cui.UnRegisterDialogBar VRAGE_ModelUI ) catch () 
	try ( closeRolloutFloater VRAGE_ModelUI ) catch () 
	VRAGE_ModelUI = newRolloutFloater "VRage Utilies" 250 500 500 250 
	addRollout VrageModels VRAGE_ModelUI border:true
	cui.RegisterDialogBar VRAGE_ModelUI style:#(  #cui_dock_vert, #cui_floatable )
	--cui.DockDialogBar VRAGE_ModelUI #cui_dock_left
)

fn VrageModelLayer_HideUI = 
(
	try ( cui.UnRegisterDialogBar VRAGE_ModelUI ) catch () 
	try ( closeRolloutFloater VRAGE_ModelUI ) catch () 
	--cui.DockDialogBar VRAGE_ModelUI #cui_dock_left
)

