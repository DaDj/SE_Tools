
-- Create Layer for Main Model and set it as the active one
if (LayerManager.getLayerFromName("MainModel") == undefined) then (
    layer = LayerManager.newLayer()
    layer.setname "MainModel"
) 
(LayerManager.getLayerFromName("MainModel")).current = true;

-- Create Layers for LODS 
for i = 1 to MySE.i_LODS do 
(
        if (LayerManager.getLayerFromName("LOD_" + i as string) == undefined) then (
        layer = LayerManager.newLayer()
    layer.setname ("LOD_" + i as string)
		)
)

-- Create a layer for all the Collision Stuff for the .hkt
if (LayerManager.getLayerFromName("Collision") == undefined) then (
    layer = LayerManager.newLayer()
    layer.setname "Collision"
) 


