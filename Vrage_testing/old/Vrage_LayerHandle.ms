

struct Vrage_LayerHandler
(
    fn CreateOrRenameLayer MyName MyOldName parent_layer:undefined = (
        if (LayerManager.getLayerFromName(MyOldName) == undefined) then (
            if (LayerManager.getLayerFromName(MyName) == undefined) then (
                layer = LayerManager.newLayer()
                layer.setname MyName
                layer.setParent parent_layer
          )
        )
        else 
        (
            layer = LayerManager.getLayerFromName(MyOldName)
            layer.setname  MyName
            layer.setParent parent_layer
        )
     -- (LayerManager.getLayerFromName(Name)).current = true;
    ),

    fn CreateLodsLayer MyName MyOldname LodCount parent:undefined = (
        for i = 0 to 5 do 
        (
            local lodString = MyName  + " #LOD" + i as string
            local lodStringOld = MyOldname + " #LOD" +  i as string
            
            if ( i <= LodCount) then (
                CreateOrRenameLayer lodString lodStringOld parent_layer:parent
            )
            else if( i > LodCount) then
            (
                if (LayerManager.getLayerFromName(lodString) != undefined) then (LayerManager.deleteLayerByName lodString)
                if (LayerManager.getLayerFromName(lodStringOld) != undefined) then (LayerManager.deleteLayerByName lodStringOld)
            )
        )

    ),

    fn CreatefromSetting = (
        -- Create Main Layer
        CreateOrRenameLayer MyVrageScene.ModelName  MyVrageScene.OldModelname  parent_layer:(LayerManager.getLayer 0) 
		
		Mainlayer = LayerManager.getLayerFromName(MyVrageScene.ModelName )

        -- Collision Stuff  (Main Model ofc) 
        CreateOrRenameLayer (MyVrageScene.ModelName + " #Collision")  (MyVrageScene.OldModelname + " #Collision") parent_layer:Mainlayer
        
        -- Dummies Layer
        CreateOrRenameLayer (MyVrageScene.ModelName + " #Dummies")  (MyVrageScene.OldModelname + " #Dummies") parent_layer:Mainlayer

        -- Construction layer
        CreateOrRenameLayer (MyVrageScene.ModelName + " #Construction")  (MyVrageScene.OldModelname + " #Construction") parent_layer:Mainlayer


        --Create Construction 0-5  (5 is max possible,  also deletes if there are too many)
        for i = 1 to 5 do 
        (
            local ConstructionString = MyVrageScene.ModelName  + " #Construction" + i as string
            local ConstructionStringOld = MyVrageScene.OldModelname + " #Construction" +  i as string

            if ( i <= MyVrageScene.i_Construction) then (
                CreateOrRenameLayer ConstructionString  ConstructionStringOld  parent_layer:ConstructionLayer
                tmplayer  = LayerManager.getLayerFromName(ConstructionString)
                CreateLodsLayer  ConstructionString ConstructionStringOld MyVrageScene.i_ConstructionLODS parent:tmplayer
            )
            else if(i > MyVrageScene.i_Construction) then (
                CreateLodsLayer  ConstructionString ConstructionStringOld -1 parent:ConstructionLayer
                if (LayerManager.getLayerFromName(ConstructionString) != undefined) then (LayerManager.deleteLayerByName ConstructionString)
                if (LayerManager.getLayerFromName(ConstructionStringOld) != undefined) then (LayerManager.deleteLayerByName ConstructionStringOld)
            )
        )

    )

)

MyVrageLayers = Vrage_LayerHandler()