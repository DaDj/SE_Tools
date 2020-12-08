MyLayer = LayerManager.getLayer 1

clearListener()
format "%:\n" MyLayer.name

for c = 1 to MyLayer.getNumChildren() do (

	child = MyLayer.getChild c
	childNodes = refs.dependents (ILayerManager.getLayerObject child.name)
	child_names = for k in childNodes where classOf k != Layer_Manager and classOf k != scene collect k.name
	
	if child_names.count > 0 do (
		format "\t%:\n" child.name
		format "\t\t%\n" child_names
	)
)