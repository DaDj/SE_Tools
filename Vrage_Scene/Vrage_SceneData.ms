VrageSceneData = attributes "VrageSceneData" attribID:#(0x4161fb2e, 0x68bae400)
(
	Parameters main
	(
		PaintColor type:#color default:(color 128 128 128);
		PaintColorNode type:#maxObject ;
		ModDir type:#string default:"";
		ModName type:#string default:"";
		OverwriteSBC type:#boolean default:true;
		StartGameAfterExpo type:#boolean default:false;
	)
)


struct VrageScene
(
	PaintColor,
	PaintColorNode,
	ModDir = "",
	ModName = "",
	OverwriteSBC = true,
	StartGameAfterExpo = false,

	fn InitPaint = 
	(
		Attr = custAttributes.get rootnode VrageSceneData
		if  Attr == undefined then 
		(
			CustAttributes.add rootnode VrageSceneData
		)

		if rootnode.VrageSceneData.PaintColorNode == undefined then 
		(
			rootnode.VrageSceneData.PaintColorNode = osl_SetColor()
			rootnode.VrageSceneData.PaintColorNode.color = (color 144 144 144 255)
		)
	),
	
	fn SetPaintColor TheColor:(color 144 144 144 255) =
	(
		Attr = custAttributes.get rootnode VrageSceneData
		if  Attr == undefined then InitPaint()
		rootnode.VrageSceneData.PaintColorNode.color = TheColor
	),

	fn getPaintNode =
	(
		Attr = custAttributes.get rootnode VrageSceneData
		if  Attr == undefined then InitPaint()
		rootnode.VrageSceneData.PaintColorNode
	),


	fn Init = 
	(

	),

	fn Get = 
	(

	),

	fn Set = 
	(

	)
)


