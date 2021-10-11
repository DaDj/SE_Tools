global MyVrageLayerDict
global MyVrageLayerTree



struct VrageLayerDict (
	
	names = #(),
	nodes = #(),
	
	fn build =(
		
		for c = 0 to LayerManager.count-1 do (
			this_Layer = LayerManager.getLayer c
			append names this_Layer.name
			layer_children = refs.dependents (ILayerManager.getLayerObject this_Layer.name)
			layer_nodes = for k in layer_children where superClassOf k == GeometryClass or superClassOf k == helper collect k
			sub_layers = for k in layer_children where not (superClassOf k == GeometryClass or superClassOf k == helper) collect k
			append nodes layer_nodes
		)
	),
	
	fn select name =(
		index = findItem names name
		
		if index > 0 then (
			nodes[index]
		)
		else (
			#()
		)
	)
)

struct VrageLayerBranch (
	layer,
	nodes = #(),
	subs = #(),
	
	fn getSubs =(
		
		dependents = refs.dependents (ILayerManager.getLayerObject layer.name)
		nodes = for k in dependents where superClassOf k == GeometryClass or superClassOf k == helper collect k
		
		for i = 1 to layer.getNumChildren() do (
			sub_layer = layer.getChild i
			branch = VrageLayerBranch layer:sub_layer
			branch.getSubs()
			
			append subs branch
		)
	),
		
	fn getFilename =(
		fname = layer.name
		
		case of (
			(matchPattern fname pattern:"* #LOD0"): fname = substring fname 1 ((findString fname " #") - 1)
			default: fname = substituteString fname " #" "_"
		)
		
		fname += ".FBX"
		
		--format "%\n" fname
		fname
	),
	
	fn print level =(
		
		pre = ""
		for i = 1 to level do pre += "\t"
		
		format "%%: %\n" pre layer.name (getFilename())
		
		for sub in subs do (
			sub.print (level + 1)
		)
	)
)

struct VrageLayerTree (
	Tree = #(),
	nodes = #(),

	fn getRoots = (
		local root_layer = layermanager.getLayer 0
		
		nodes = for c in refs.dependents (ILayerManager.getLayerObject root_layer.name) where superclassOf c == GeometryClass or superClassOf c == helper collect c
		
		for i = 1 to root_layer.getNumChildren() do (
			sub = root_layer.getChild i
			
			root = VrageLayerBranch layer:sub
			root.getSubs()
			
			append Tree root
		)
	),
	
	fn print =(
		for root in Tree do root.print 0
	)
)

MyVrageLayerDict = VrageLayerDict()
MyVrageLayerDict.build()
MyVrageLayerTree = VrageLayerTree()
MyVrageLayerTree.getRoots()

MyVrageLayerTree.print()