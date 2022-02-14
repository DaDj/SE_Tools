struct VRageBBox
(
	fn Show X Y Z Type= 
	(
		size_mult =  units.decodeValue "250cm" 
		if Type == "Small" then  size_mult =  units.decodeValue "50cm" 
		
		obj = getnodebyname "VRageBB"
		if obj != undefined then( delete obj)
		leng =   X * (size_mult) 
		height = Y  * (size_mult) 
		width =  Z *(size_mult) 
		Boundingbox = box length:leng width:width  height:height
		Layer = VRLayers.GetSelected();
		Layer.addNode Boundingbox
		boundingbox.pos = [0 ,0,-height/2 ]
		Boundingbox.visibility = bezier_float()
		Boundingbox.name = "VRageBB" 
		Boundingbox.visibility.controller.value = 0.1
		select Boundingbox
		freeze	Boundingbox
	),

	fn Hide = 
	(
        print "hee"
		obj = getnodebyname "VRageBB"
        print obj
		if obj != undefined then( delete obj)
	)
)