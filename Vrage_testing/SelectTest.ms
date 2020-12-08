/*
MyLayer = LayerManager.getLayer 1

format "%:\n" MyLayer.name

for c = 1 to MyLayer.getNumChildren() do (

	child = MyLayer.getChild c
	childNodes = refs.dependents (ILayerManager.getLayerObject child.name)
	child_names = for k in childNodes where classOf k != Layer_Manager and classOf k != scene collect k.name
	child_classes = for k in childNodes collect classOf k
		
	makeUniqueArray child_classes
	
	--if child_names.count > 0 do (
		format "\t%:\n" child.name
		format "\t\t%\n" child_names
		format "\t\t%\n" child_classes
	--)
)
*/

try deleteAllChangeHandlers id:#LayerWatchdog catch()

clearListener()
global LayerNames
global NewLayerNames
global LayerRefs



fn getLayerNameList =(
	LayerNames =  for l = 0 to LayerManager.count-1 collect (LayerManager.getLayer l).name
)

fn getLayerRefs =(
	LayerRefs =  for l = 0 to LayerManager.count-1 collect (LayerManager.getLayer l).layerAsRefTarg
)

getLayerNameList()
getLayerRefs()

fn getLayerNameChanges =(
	
	newNames = for l = 0 to LayerManager.count-1 collect (LayerManager.getLayer l).name
	
	for n = 1 to LayerNames.count do (
		if newNames[n] != LayerNames[n] do (
			format "% -> %\n" LayerNames[n] newNames[n]
		)
	)
)