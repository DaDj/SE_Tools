VrageSceneData = attributes "VrageSceneData" attribID:#(0x4161fb2e, 0x68bae400)
(
	Parameters main
	(
		VRagePaintColor type:#color default:(color 128 128 128);
		VRagePaintColorNode type:#maxObject ;
	)
)


struct VrageScene
(
	fn InitPaint = 
	(
		Attr = custAttributes.get rootnode VrageSceneData
		if  Attr == undefined then 
		(
			CustAttributes.add rootnode VrageSceneData
		)

		if rootnode.VrageSceneData.VRagePaintColorNode == undefined then 
		(
			rootnode.VrageSceneData.VRagePaintColorNode = osl_SetColor()
			rootnode.VrageSceneData.VRagePaintColorNode.color = (color 128 128 128 128)
		)
	),
	
	fn SetPaintColor TheColor:(color 128 128 128 128) =
	(
		Attr = custAttributes.get rootnode VrageSceneData
		if  Attr == undefined then InitPaint()
		rootnode.VrageSceneData.VRagePaintColorNode.color = TheColor
	),

	fn getPaintNode =
	(
		Attr = custAttributes.get rootnode VrageSceneData
		if  Attr == undefined then InitPaint()
		rootnode.VrageSceneData.VRagePaintColorNode
	)


)


