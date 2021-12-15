function MXSColor_to_dotNetColor hColor = --New function
(
	m_dnColor = dotNetClass "System.Drawing.Color"
	--[brief] Converts a maxscript color to a .NET color
	--[param] The maxscript color to convert
	--[return] A System.Drawing.Color object
	m_dnColor.fromARGB hColor.r hColor.g hColor.b
)

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

fn Vrage_getNormalData theMod =(
	
	
	
	struct VrageNormalData (
		
		faces,
		normals
		
	)
	
	faces = 	for f = 1 to theMod.GetNumFaces() collect (
		for c = 1 to theMod.GetFaceDegree f collect theMod.GetNormalID f c
	)
	normals = #() 
	
	
	for n = 1 to theMod.GetNumNormals() do (
		append normals (theMod.getNormal n)
	)
	
	VrageNormalData faces:faces normals:normals
	
)

fn Vrage_setNormalData theMod data =(

	for f = 1 to theMod.GetNumFaces() do (
		deg = theMod.GetFaceDegree f 
		
		for c = 1 to deg do (
			norm = data.faces[f][c]
			id = theMod.GetNormalID f c
			theMod.setNormal id data.normals[norm]
			theMod.setNormalExplicit id
		)
	)
	
)

fn Vrage_condenseMatIds obj non_destructive:true =(

	if classOf obj.material == Multimaterial do (
		
		face_ids = Vrage_getFacesByMatId(obj.mesh)
		
		materials = #() 
		
		new_ids = #() 
		
		for i = 1 to face_ids.count where face_ids[i] != undefined do (
			
			mat = obj.material.materialList[i]
			
			append materials mat
			append new_ids face_ids[i]
		)
		
		if non_destructive and obj.modifiers.count > 0 then (
			max modify mode
			meshMod = Turn_to_Mesh name:"Triangulate Mesh" useInvisibleEdges:off
			
			if validModifier obj meshMod do (
				select obj
				addModifier obj meshMod
			)

			normalMod = Edit_Normals name:"get normals"
			face_normals = undefined

			if validModifier obj normalMod do (
				addModifier obj normalMod 
				face_normals = Vrage_getNormalData normalMod
				deleteModifier obj 1
			)
			
			MaterialMod = Edit_Poly name:"Vrage Cleaned Material IDs"

			if validModifier obj MaterialMod do (
				addModifier obj MaterialMod 
				
				subobjectlevel = 4
				
				for g = 1 to new_ids.count do (
					MaterialMod.setSelection #Face #{}
					MaterialMod.select #Face (new_ids[g] as BitArray)
					MaterialMod.SetOperation #SetMaterial
					MaterialMod.materialIDToSet = g
					MaterialMod.Commit()
				)
			)

			newNormalMod = Edit_Normals name:"Vrage Fix Normals"

			if face_normals != undefined do (
				addModifier obj newNormalMod 
				Vrage_setNormalData newNormalMod face_normals
			)

			max create mode
		)
		else (
			
			convertTo obj Editable_mesh
			
			for g = 1 to new_ids.count do (
				for f in new_ids[g] do (
					setFaceMatID obj f g
				)
			)
		)
		
		new_material = Multimaterial numsubs:materials.count materialList:materials names:(for m in materials collect m.name)
		
		obj.material = new_material
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

fn Vrage_XMLtoVec xml =(
	[xml.item["X"].innertext as float, xml.item["Y"].innertext as float, xml.item["Z"].innertext as float]
)

fn Vrage_XMLtoColor xml =(
	([xml.item["X"].innertext as float, xml.item["Y"].innertext as float, xml.item["Z"].innertext as float]) as color
)

fn Vrage_wrapText str maxW=
(
	local strArr=#()
	local lastSpace=1
	for i = 1 to str.count do
	(
		if str[i]==" " then lastSpace=i
		local curLine=substring str 1 (lastSpace)
		local w=(getTextExtent curLine).x
		if w>maxW then
		(
			append strArr curLine
			str=substring str (curLine.count+1) str.count
		)
	)
	append strArr str
	str=""
	for s in strArr do str+=s+"\n"
	return str
)

fn ReplaceWords mString mFromStr mToStr mIgnoreCase:false =
(
	mStream = mString as stringStream 
	regex = dotnetclass "system.text.regularexpressions.regex"
	pattern =  mFromStr 
	if mIgnoreCase do pattern = "(?i)" + pattern
	
	result = regex.replace mStream pattern mToStr
	return (result as string)
)

function GetObjsMats objs = 
(    
	--Get a unique Matlist of Objs
	local MatList = #()
	for obj in objs do 
	(
		if ((ClassOf Obj.Material)  as string) != "Multimaterial" then 
		(
			appendIfUnique MatList Obj.Material.Name
		) 
		else 
		(
			for MtlID = 1 to obj.Material.MaterialList.Count do 
			(
				appendIfUnique MatList Obj.Material.MaterialList[MtlID].Name
			)
		)
		
	)
	MatList
)
