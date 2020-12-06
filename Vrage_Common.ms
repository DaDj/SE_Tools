fn Vrage_getFacesByMatId mesh =(
	
    mesh_faces_by_mat_id = #()

    for f = 1 to mesh.numfaces do (
        mat_id = getFaceMatID mesh f
        
        if mesh_faces_by_mat_id[mat_id] != undefined then (
            mesh_faces_by_mat_id[mat_id] += #(f)
        )
        else (
            mesh_faces_by_mat_id[mat_id] = #(f)
        )
    )

    mesh_faces_by_mat_id
)

fn Vrage_condenseMatIds obj nondestructive:false =(

    if classOf obj.material == Multimaterial do (
        face_ids = Vrage_getFacesByMatId(obj.mesh)
        
        materials = #() 
        
        new_ids = #() 
        
        for i = 1 to face_ids.count where face_ids[i] != undefined do (
            
            mat = obj.material.materialList[i]
            
            append materials mat
            append new_ids face_ids[i]
        )
        
        if classOf obj == editable_mesh then (
            for g = 1 to new_ids.count do (
                for f in new_ids[g] do (
                    setFaceMatID obj f g
                )
            )
        )
        
        new_material = Multimaterial numsubs:materials.count materialList:materials names:(for m in materials collect m.name)
        
        obj.material = new_material
        
        update obj
    )
)

fn Vrage_cleanLayers =( --Deletes empty layers after import

    for l=LayerManager.count-1 to 0 by -1 do (
        local this_layer = LayerManager.getLayer l
        
        canDelete = (this_layer.canDelete()) and not (LayerManager.doesLayerHierarchyContainNodes this_layer.name)
        if canDelete do (
            LayerManager.deleteLayerByName this_layer.name
        )
    )
)

fn Vrage_sumArray arr =(

    sum = 0

    for a in arr do (

        if classOf a == array then (
            sum += sum_array a
        )
        else if a != undefined and a as float != undefined then (
            sum += a as float
        )
        else (
			print "Sum Error!"
            return 0
        )
    )
	
    sum
	
)


fn Vrage_SetLayerbyName Name =(
    
    if LayerManager.getLayerFromName(Name) == undefined then(
        return undefined  
    ) 
    else(
        (LayerManager.getLayerFromName(Name)).current = true;
        return LayerManager.getLayerFromName(Name)
    ) 
)