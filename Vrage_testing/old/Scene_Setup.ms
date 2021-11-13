
-- Create Layer for Main Model and set it as the active one
if (LayerManager.getLayerFromName("Main") == undefined) then (
    layer = LayerManager.newLayer()
    layer.setname "Main"
) 
(LayerManager.getLayerFromName("Main")).current = true;

-- Create Layers for LODS 
for i = 1 to 4 do 
(
		if (LayerManager.getLayerFromName("LOD" + i as string) == undefined  and i < MyVrageScene.i_LODS) then (
			layer = LayerManager.newLayer()
			layer.setname ("LOD" + i as string)
		)
		else if(LayerManager.getLayerFromName("LOD" + i as string) != undefined  and i >=MyVrageScene.i_LODS) then
		(
			LayerManager.deleteLayerByName ("LOD" + i as string)
			)
)

-- Create Layers for Buildstages 
for i = 1 to 4 do 
(
		if (LayerManager.getLayerFromName("BS" + i as string) == undefined  and i < MyVrageScene.i_Buildstages) then (
			layer = LayerManager.newLayer()
			layer.setname ("BS" + i as string)
		)
		else if(LayerManager.getLayerFromName("BS" + i as string) != undefined  and i >=MyVrageScene.i_Buildstages) then
		(
			LayerManager.deleteLayerByName ("BS" + i as string)
			)
)


--Create Layers for Buildstages LoDs not sdone yet
-- for i = 1 to 4 do 
-- (
-- 		if (LayerManager.getLayerFromName("BS" + i as string) == undefined  and i < MyVrageScene.i_Buildstages) then (
-- 			layer = LayerManager.newLayer()
-- 			layer.setname ("BS" + i as string)
-- 		)
-- 		else if(LayerManager.getLayerFromName("BS" + i as string) != undefined  and i >=MyVrageScene.i_Buildstages) then
-- 		(
-- 			LayerManager.deleteLayerByName ("BS" + i as string)
-- 			)
-- )



-- Create a layer for all the Collision Stuff for the .hkt
if (LayerManager.getLayerFromName("Collision") == undefined) then (
    layer = LayerManager.newLayer()
    layer.setname "Collision"
) 


