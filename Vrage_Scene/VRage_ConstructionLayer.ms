
VrageLayer_ConstructData = attributes "VrageLayer_ConstructData" attribID:#( 0x4d367979, 0x6e68ad54 )
(
	parameters main
	(
		ConstructionID type:#integer default:1 ;
		BuildPercent type:#integer default:50.0 ;
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
				if Constrttr != undefined and Constrttr.VRType == "VRageConstructstage" do Idx_BuildStage += 1
			)
			
			if Attr != undefined then 
			(
				--print Attr.Type
				if Attr.VRType == "ConstructArrayDef" then 
				(
					Idx_BuildStage = Idx_BuildStage as string
					layer = VRLayers.CreateOrRenameLayer ( Attr.SeName + "Construction_" + Idx_BuildStage ) ( Attr.SeName + "Construction_" + Idx_BuildStage ) parent_layer:( Mainlayer.LayerProperties )
					layerRT = layer.layerAsRefTarg
					custAttributes.add layerRT VrageLayerData
					custAttributes.add layerRT VrageLayer_ConstructData
					layerRT.VRType = "VRageConstructstage"
					layerRT.ConstructionID = Idx_BuildStage as Integer
					layerRT.BuildPercent = 33 
					
					-- always add the Lod 0 automatically
					LodLayer = VrageLodLayer()
					LodLayer.Add Mainlayer:layerRT
				)
			)

			
		)
		else MyVRageLog.Info ( "No Layer selected" ) Show:true

	),

	fn Delete Mainlayer:undefined  = 
	(
		If Mainlayer == undefined then Mainlayer = ( VRLayers.GetSelected()).getParent()

		--find current Construction index
		Idx_BuildStage = 0 ;
		if Mainlayer != undefined then 
		(
			for i = 1 to Mainlayer.getNumChildren() do 
			(
				ChildLayer = Mainlayer.getChild i
				layerRT = ChildLayer.layerAsRefTarg
				Constrttr = custAttributes.get layerRT VrageLayerData
				if Constrttr != undefined and Constrttr.VRType == VRLayers.Construction do Idx_BuildStage += 1
			)
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
		VrageLodLayer.Add Mainlayer:( VRLayers.GetSelected())
	)	

	on btnValidate pressed do 
	(
		Mainlayer = ( VRLayers.GetSelected()).getParent()
		VrageConstructionLayer.Delete Mainlayer:Mainlayer
	)
)
