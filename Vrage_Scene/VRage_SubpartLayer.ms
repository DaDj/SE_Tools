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
				layerRT.SeName
				ParentLayerDummies = ( LayerManager.getLayerFromName ( layerRT.SeName + " #Dummies" ) ).layerAsRefTarg
				if ParentLayerDummies.VRType != "DummiesDef" then ( ParentLayerDummies = undefined )
			) 
			if ParentLayerDummies != undefined then 
			(
				--1. Place the Dummy
				--2. Create the Subpart Layer
			)
		)
	)
)
