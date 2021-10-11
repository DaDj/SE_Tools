
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

    fn CreatefromSetting  Title OldTitle iLods:0 iConstr:0  iConstrLods:0   parent_layer:undefined = (
        -- Create Main Layer
        CreateOrRenameLayer Title  OldTitle  parent_layer:parent_layer
		
		Mainlayer = LayerManager.getLayerFromName(Title)

        -- Collision Stuff  (Main Model ofc) 
        CreateOrRenameLayer (Title + " #Collision")  (OldTitle + " #Collision") parent_layer:Mainlayer
        
        -- Dummies Layer
        CreateOrRenameLayer (Title + " #Dummies")  (OldTitle + " #Dummies") parent_layer:Mainlayer
        
        --Create Lods 0-5  (5 is max possible,  also deletes if there are too many)
        CreateLodsLayer  Title  OldTitle iLods parent:Mainlayer


        CreateOrRenameLayer (Title + " #Construction")  (OldTitle + " #Construction") parent_layer:Mainlayer
        ConstructionLayer = LayerManager.getLayerFromName((Title + " #Construction") )


        --Create Construction 0-5  (5 is max possible,  also deletes if there are too many)
        for i = 1 to 5 do 
        (
            local ConstructionString = Title  + " #Construction" + i as string
            local ConstructionStringOld = OldTitle + " #Construction" +  i as string

            if ( i <= iConstr) then (
                CreateOrRenameLayer ConstructionString  ConstructionStringOld  parent_layer:ConstructionLayer
                tmplayer  = LayerManager.getLayerFromName(ConstructionString)
                CreateLodsLayer  ConstructionString ConstructionStringOld iConstrLods parent:tmplayer
            )
            else if(i > iConstr) then (
                CreateLodsLayer  ConstructionString ConstructionStringOld -1 parent:ConstructionLayer
                if (LayerManager.getLayerFromName(ConstructionString) != undefined) then (LayerManager.deleteLayerByName ConstructionString)
                if (LayerManager.getLayerFromName(ConstructionStringOld) != undefined) then (LayerManager.deleteLayerByName ConstructionStringOld)
            )
        )

  CreateOrRenameLayer  (Title + " #Subparts")  (Title + " #Subparts") parent_layer:Mainlayer

    )

)


MyVrageLayers = Vrage_LayerHandler()
MyVrageLayers.CreatefromSetting  MyVrageScene.ModelName  MyVrageScene.OldModelname iLods:1 iConstr:1  iConstrLods:0 	parent_layer:(LayerManager.getLayer 0) 

MyVrageSubpart = Vrage_LayerHandler()

MyVrageSubpart.CreatefromSetting  "What" "Lol" iLods:0 iConstr:2  iConstrLods:0 	parent_layer:(LayerManager.getLayerFromName( MyVrageScene.ModelName + " #Subparts") )