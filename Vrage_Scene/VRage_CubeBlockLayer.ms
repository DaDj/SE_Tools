VrageLayer_CubeBlockData = attributes "VrageLayer_CubeBlockData" attribID:#( 0x20b6687b, 0x63bbfe0a )
(
	parameters main
	(
		GridSize type:#string default:"Large" ;
		TypeId type:#string	default:"CubeBlock" ;
		SubtypeID type:#string	default:"MyBlock" ;
		BBSize type:#point3 default:[1, 1, 1] ;
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
		custAttributes.add layerRT VrageLayer_IconData
		layerRT.SeName = BlockName
		-- Collision Stuff  (Main Model ofc) 
		layer = VRLayers.CreateOrRenameLayer ( BlockName + " #Collision" ) ( BlockName + " #Collision" ) parent_layer:Mainlayer
		layerRT = layer.layerAsRefTarg
		custAttributes.add layerRT VrageLayerData
		layerRT.VRType = VRLayers.Collision
		layerRT.SeName = BlockName
		/*-- Dummies Layer
		layer = VRLayers.CreateOrRenameLayer ( BlockName + " #Dummies" ) ( BlockName + " #Dummies" ) parent_layer:Mainlayer
		layerRT = layer.layerAsRefTarg
		custAttributes.add layerRT VrageLayerData
		layerRT.VRType = VRLayers.Dummies
		layerRT.SeName = BlockName */

		-- Construction Layer
		layer = VRLayers.CreateOrRenameLayer ( BlockName + " #Construction" ) ( BlockName + " #Construction" ) parent_layer:Mainlayer
		layerRT = layer.layerAsRefTarg
		custAttributes.add layerRT VrageLayerData
		layerRT.VRType = VRLayers.ConstructArray
		layerRT.SeName = BlockName	

		-- Subpart Layer
		layer = VRLayers.CreateOrRenameLayer ( BlockName + " #Subparts" ) ( BlockName + " #Subparts" ) parent_layer:Mainlayer
		layerRT = layer.layerAsRefTarg
		custAttributes.add layerRT VrageLayerData
		layerRT.VRType = VRLayers.SubPartArray
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
		if Attr.VRType == VRLayers.CubeBlock or 
		Attr.VRType ==  VRLayers.SubPartArray or 
		Attr.VRType == VRLayers.Construction or
		Attr.VRType == VRLayers.Collision  or 
		Attr.VRType == VRLayers.ConstructArray or 
		Attr.VRType == VRLayers.LOD or 
		Attr.VRType == VRLayers.Dummies then 
		(	
			Attr.SeName = NewName
			Layer.setName ( ReplaceWords Layer.Name OldName NewName mIgnoreCase:true )
		)

		if Attr.VRType != VRLayers.SubPartArray then
		(
			for i = 1 to Layer.getNumChildren() do
			(
				CurrentChildLayer = Layer.getChild i
				RenameAll CurrentChildLayer OldName NewName
				
			)
		)
	)

)

rollout Vrage_CubeBlockRollout "CubeBlock" width:300 height:200
(	
	--button btnValidate "Validate" width:120 height:25 tooltip:"Check if all expected data/Layer exist"	align:#right
	group "CubeBlock Settings"
	(
		label lbl_Size "Block Size" across:2 align: #left
		dropdownlist dropdnSize "" items:#( "Large", "Small" ) tooltip:"Size of the Block Grid (large =2.5m, Small: 0.25m)" labelOnTop: false Width:150 enabled: true align: #right

		label lbl_ID "Type ID" across:2 align: #left
		edittext editt_TypeID "" fieldWidth:120 labelOnTop:true align: #right \ 
		toolTip:"Type of Block. If no valid is entered, a default Cubeblock will be assumed"
		button btnSearch "..." width:25 height:20 pos:[72, 52] \
		toolTip:"Open List of existing Types."	images: #( VRageIcons, VRageIcons, VRageIcoLeng, 25, 25, 25, 25 )

		label lbl_SubID "Subtype ID" across:2 align: #left
		edittext editt_SubID "" fieldWidth:120 labelOnTop:true align: #right
	)

	group "Actions"
	(
		button btnrenameBlock "Rename:" width:100 height:25 align: #center across:2
		edittext editt_Rename "" fieldWidth:100 labelOnTop:true offset:[0, 4] align: #right 

		button btnAddLod "Add a Lod" width:100 height:25 align: #center across:2 \
		toolTip:"Add Lod"	images: #( VRageIcons, VRageIcons, VRageIcoLeng, 28, 28, 28, 28 )

		label lbl_fake1 "" align: #left
		
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
			if MainAttr.GridSize == "Large" then dropdnSize.selection = 1 else dropdnSize.selection = 2

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
		MainAttr.GridSize = dropdnSize.items[i]
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

rollout Vrage_CubeBlock_BBBoxRollout "BoundingBox"  width:300 height:200
(
	spinner spin_x "X:" range:[1,100,1] type:#integer across:3
	spinner spin_Y "Y:" range:[1,100,1] type:#integer
	spinner spin_Z "Z:" range:[1,100,1] type:#integer
	checkbutton btn_BBBox "Toggle Boundingbox" width:150 height:25 align: #center across:1
	
	on spin_x changed val do 
	(
		Layer = VRLayers.GetSelected();
		MainAttr = custAttributes.get Layer VrageLayer_CubeBlockData
		MainAttr.BBSize = [ spin_x.value, spin_y.value, spin_z.value ]
	)
	on spin_y changed val do 
	(
		Layer = VRLayers.GetSelected();
		MainAttr = custAttributes.get Layer VrageLayer_CubeBlockData
		MainAttr.BBSize = [ spin_x.value, spin_y.value, spin_z.value ]
	)
	on spin_z changed val do 
	(
		Layer = VRLayers.GetSelected();
		MainAttr = custAttributes.get Layer VrageLayer_CubeBlockData
		MainAttr.BBSize = [ spin_x.value, spin_y.value, spin_z.value ]
	)

	on Vrage_CubeBlock_BBBoxRollout open do 
	(
		obj = getnodebyname "VRageBB"
		if obj != undefined then(btn_BBBox.checked = true )
		
		Layer = VRLayers.GetSelected();
		MainAttr = custAttributes.get Layer VrageLayer_CubeBlockData
		spin_x.value = MainAttr.BBSize[1]
		spin_y.value = MainAttr.BBSize[2]
		spin_z.value = MainAttr.BBSize[3]
	) 
	
	on btn_BBBox changed state do 
	(
		if state == on then
		(
			Layer = VRLayers.GetSelected();
			MainAttr = custAttributes.get Layer VrageLayer_CubeBlockData
			VRageBBox.show  spin_x.value spin_y.value spin_z.value MainAttr.GridSize
		)
		else  
		(
			VRageBBox.hide()
		)
		
	)
)