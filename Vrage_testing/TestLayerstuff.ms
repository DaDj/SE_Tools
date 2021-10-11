

fn compareLodIds v1 v2 =
(
	if v1 == undefined do return 0
	if v2 == undefined do return 0
	local d = (v1.Id)-(v2.Id)
	case of
	(
		(d < 0.): -1
		(d > 0.): 1
		default: 0
	)
)

struct VrageLodDef
(
    Title = "",
	MyDistance = 20,
	Id = 0
)

struct VrageConstructionDef
(
	Title = "",
    Lods = #(),
	Id = 0,
	Percent = 10 
)

struct VRageLayerInfos
(
	List = #(),
	
	fn CreateLayerlist =
		(
			for i = 0 to layerManager.count-1 do
			(
				ilayer = layerManager.getLayer i
				if matchPattern ilayer.name pattern:"*#LOD*" then(
					LodIndex = substring ilayer.name ilayer.name.count -1
					LodIndex = LodIndex as Integer + 1
					MyLod = VrageLodDef()
					MyLod.Title = ilayer.name
					MyLod.Id = LodIndex - 1 
					append List MyLod 
				) 
				else if matchPattern ilayer.name pattern:"*#Construction*" then(
					MyConstruction = VrageConstructionDef()
					append List MyConstruction
				)
			)
		)
	)	


struct VrageMainBlockDef2(
	Title = "",
    Lods = #(),
    Constructions = #(),
	Subparts = #(),
	LayerInfos = #()
	
	)

struct VrageMainBlockDef 
(
    Title = "",
    Lods = #(),
    Constructions = #(),
	Subparts = #(),
	LayerInfos = #(),
	


	fn CreateLodList Layer =(
		local LodArray = #()
		for i = 1 to Layer.getNumChildren() do
		(
			CurrentChildLayer= Layer.getChild  i
			if matchPattern CurrentChildLayer.name pattern:"*#LOD*" then(
				print CurrentChildLayer.name
				LodIndex = substring CurrentChildLayer.name CurrentChildLayer.name.count -1
				LodIndex = LodIndex as Integer + 1
				MyLod = VrageLodDef()
				MyLod.Title = CurrentChildLayer.name
				MyLod.Id = LodIndex - 1 
				insertItem MyLod  LodArray Lodindex
		)
	)
	qsort  LodArray compareLodIds 
	LodArray =  for i in LodArray where i != undefined collect i
	return LodArray
	),

	fn CreateConstructions Layer =(
		local MyConstruction = VrageConstructionDef()
		for i = 1 to Layer.getNumChildren() do
		(
			CurrentLayer= Layer.getChild  i
			if matchPattern CurrentLayer.name pattern:"*#Construction*" then(
			MyConstruction = VrageConstructionDef()
			--print CurrentLayer.name
			MyConstruction.Lods  = CreateLodList (LayerManager.getLayerFromName CurrentLayer.name)
			append  Constructions MyConstruction
			)
		)
	),


	fn CreateBlockDef LayerName =
	(
		--local MyBlock = VrageMainBlockDef()
		Layer = LayerManager.getLayerFromName LayerName
		Layer.getNumChildren() 
		Lods  = CreateLodList Layer 
			
		for i = 1 to Layer.getNumChildren() do
		(
			CurrentChildLayer= Layer.getChild  i
			if matchPattern CurrentChildLayer.name pattern:"*#Construction*" do(
				CreateConstructions CurrentChildLayer
			)
			
			if matchPattern CurrentChildLayer.name pattern:"*#Subparts" do(
					for iSubs = 1 to CurrentChildLayer.getNumChildren() do
				(
				SubpartLayer = CurrentChildLayer.getChild iSubs
				Subpart = VrageMainBlockDef()
				Subpart.CreateBlockDef SubpartLayer.name 
				append Subparts Subpart
				)
			)
		)
		---return MyBlock
	),
	
	fn UpdateLodDef Layer =(
		Layer = LayerManager.getLayerFromName Layer
		Lodnew  = CreateLodList Layer
		for NewObj in Lodnew do(
			for obj in Lods do ( if obj.Title == NewObj.Title do (
				NewObj.MyDistance= obj.MyDistance
				))
				
		)
		Lods = Lodnew
	)
)

MyMainBlock = VrageMainBlockDef()
MyMainBlock.CreateBlockDef "MySEModel"
MyMainBlock
MyMainBlock.Subparts

MyMainBlock.Constructions
 test = VRageLayerInfos()
 test.CreateLayerlist()


  test
-- for obj in test.List do
-- (
--  print	obj.Title
-- 	)
-- MyMainBlock

-- for objs in MyMainBlock.Lods do (
-- 	if objs.Title == "MySEModel #LOD0" do (
-- 		print "lol"
-- 		deepCopy objs 
-- 	)
-- )
--  test = MyMainBlock as string

-- thing = execute test

-- for i = 1 to Layer.getNumChildren() do
-- (
-- 	CurrentChildLayer= Layer.getChild  i
-- 	
--  if matchPattern CurrentChildLayer.name pattern:"*#Construction*" then(
-- 		print  CurrentChildLayer.name
-- 	)
-- )


