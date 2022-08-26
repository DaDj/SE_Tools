struct VrageSubpartLayer
(
	fn Add Mainlayer:undefined Name:undefined =
	(
		Attr = undefined
		ParentLayerDummies = undefined 
		ParentLayer = undefined

		if Mainlayer == undefined then Mainlayer = VRLayers.GetSelected()
		if Mainlayer != undefined then ( Attr = custAttributes.get Mainlayer VrageLayerData )
		if Attr != undefined and Attr.VRType == "SubPartArray" then 
		(
			ParentLayer = Mainlayer.getParent() --Cubeblock or a Subpartdef
			if ParentLayer != undefined then 
			( -- trying to find the Dummie layer in which the dummy for the subpart has to be placed
				layerRT = ParentLayer.layerAsRefTarg
				print layerRT.SeName
				ParentLayerDummies = ( LayerManager.getLayerFromName ( layerRT.SeName + " #LOD0" ) ).layerAsRefTarg
				--if ParentLayerDummies.VRType != "DummiesDef" then ( ParentLayerDummies = undefined )
			) 
			if ParentLayerDummies != undefined then 
			(
				--1. Place the Dummy
				VrageDummy_SubpartAdd "Subpart" "Dummyatm" ParentLayerDummies
		
				--2. Create the Subpart Layer
				if Mainlayer != undefined then 
				(
					layer = VRLayers.CreateOrRenameLayer ("Subparttst") ("Subparttst") parent_layer:( Mainlayer.LayerProperties )
					layerRT = layer.layerAsRefTarg
					custAttributes.add layerRT VrageLayerData
					layerRT.VRType = VRLayers.SubPart	
				)	
			)
		)
	)
)

rollout Vrage_SubpartsArrayRollout "VrageLayer_SubpartsArray" width:250 height:200
(
	group "Actions"
	(
		button btnAdd "Add SubPart" width:100 height:25 align:#center across:2 \
		tooltip:"Add a Subpart." images: #( VRageIcons, VRageIcons, VRageIcoLeng, 30, 30, 30, 30 )
	)
	on btnAdd pressed do 
	(
		VrageSubpartLayer.add Mainlayer:(VRLayers.GetSelected())
		
	)	
)
