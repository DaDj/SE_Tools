
VrageLayer_LODData = attributes "VrageLayer_LODData" attribID:#( 0xdcaefca, 0x59c57e45 )
(
	parameters main
	(
		DrawDistance type:#float default: 20.0 ;
		LODID type:#integer default: 0 ;
	)
)


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
				if LodAttr != undefined and LodAttr.VRType == VRLayers.LOD do Idx_Lod += 1
			)
			
			if Attr != undefined then 
			(
				--print Attr.Type
				if Attr.VRType == "CubeBlockDef" or Attr.VRType == "SubpartDef" or Attr.VRType == "VRageConstructstage" then 
				(
					Idx_Lod = Idx_Lod as string
					layer = VRLayers.CreateOrRenameLayer ( Mainlayer.name + " #LOD" + Idx_Lod ) ( Mainlayer.name + " #LOD" + Idx_Lod ) parent_layer:( Mainlayer.LayerProperties )
					layerRT = layer.layerAsRefTarg
					custAttributes.add layerRT VrageLayerData
					custAttributes.add layerRT VrageLayer_LODData
					layerRT.VRType = VRLayers.LOD
					layerRT.LODID = Idx_Lod as Integer
					layerRT.DrawDistance = LodDistanceMultiplier * ( Idx_Lod as Integer ) - 5 * ( Idx_Lod as Integer ) ^ 2 + 5 * ( Idx_Lod as Integer ) ^ 3
				)
			)
		)
		else MyVRageLog.Info ( "No Layer selected" ) Show:true

	),

	fn Delete  Mainlayer:undefined = 
	(
		If Mainlayer == undefined then	Mainlayer = ( VRLayers.GetSelected()).getParent()
		Idx_Lod = 0 ;

		if Mainlayer != undefined then 
		(
			for i = 1 to Mainlayer.getNumChildren() do 
			(
				ChildLayer = Mainlayer.getChild i
				layerRT = ChildLayer.layerAsRefTarg
				LodAttr = custAttributes.get layerRT VrageLayerData
				if LodAttr != undefined and LodAttr.VRType == VRLayers.LOD do Idx_Lod += 1
			)
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
		Mainlayer = (VRLayers.GetSelected()).getParent()
		VrageLodLayer.Delete  Mainlayer:Mainlayer
	)
)