
placeholder_texture = "E:\Program Files (x86)\Steam\SteamApps\common\SpaceEngineersModSDK\OriginalContent\textures\\fake.png"
material_xml_dir = "E:\\Program Files (x86)\\Steam\\SteamApps\\common\\SpaceEngineersModSDK\\OriginalContent\\Materials\\"

tex_dir = "C:\\SteamLibrary\\steamapps\\common\\SpaceEngineers\\Content\\"
tex_ext = ".dds"

global VRage_MatLib


fn VRage_report_Error msg =(

	print (msg as string)
	
)

VRage_material_CA = attributes VRage_materialattribID:#(0x162d47c4, 0x6a278b17)
(
	parameters main rollout:params (
		'is_se_material' Type:#boolean Default:True
	)
	Rollout params "Space Engineers Material" (
		label lb_info "Space Engineers Material"
	)
)

struct VRage_material (
	
	xml_mat,
	
	fn get_path m =(
		tex_dir + (substituteString m ".dds" tex_ext)
	),
	
	fn get_material =(
		material = StandardMaterial Name:xml_mat.attributes.itemOf["Name"].value showInViewport:true
		
		cm_map = xml_mat.selectSingleNode "Parameter[@Name='ColorMetalTexture']"
		op_map = xml_mat.selectSingleNode "Parameter[@Name='AlphamaskTexture']"
		
		if cm_map != undefined and doesFileexist (get_path cm_map.innerText) then (
			dm_filename = get_path cm_map.innerText
		)
		else (
			dm_filename = placeholder_texture
		)
		
		diffuseBitmap = openBitmap dm_filename gamma:1.0
		material.diffuseMap = bitmaptexture bitmap:diffuseBitmap alphasource:2
		
		if op_map != undefined and doesFileexist (get_path op_map.innerText) do (
			opacityBitmap = diffuseBitmap = openBitmap (get_path op_map.innerText) gamma:1.0
			material.opacityMap = Bitmaptexture filename:(get_path op_map.innerText) alphasource:2
		)
		
		try (
			custAttributes.add material VRage_material_CA
		)
		catch ()
		
		material
	)
	
)

struct VRage_materialLib (

	files = getFiles (VRageCfg.ModSDK + "\\OriginalContent\\Materials\\" + "*.xml"),
	
	xmlDoc = dotNetObject "system.xml.xmlDocument",
	
	--Fetch Material by material name
	fn get_mat_by_name name =(
		
		xpath = substituteString "//Material[@Name='%']" "%" (name as string)
		xml_mat = xmlDoc.selectSingleNode xpath
		
		if xml_mat != undefined then (
			mat = (VRage_Material xml_mat:xml_mat).get_material()
		)
		else (
			mat = undefined
		)
		
		mat
	),
	
	fn get_mat_list =(
		
		xml_mats = xmlDoc.selectNodes "//Material"
		
		mat_names = for i=0 to xml_mats.count-1 collect xml_mats.itemOf[i].attributes.itemOf["Name"].value
		
		sorted = sort mat_names
		print sorted
	),
		
	fn main =(
		
		xmlDoc.load files[1]
		
		for f = 2 to files.count do (
			tempDoc = dotNetObject "system.xml.xmlDocument"
			tempDoc.load files[f]
			theNode = xmlDoc.ImportNode tempDoc.documentElement True
			xmlDoc.documentElement.appendchild theNode
		)
		
	)
	
	
)

fn get_faces_by_mat_id mesh =(
	
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

fn condense_material_ids obj nondestructive:false =(
	
	if classOf obj.material == Multimaterial do (
		face_ids = get_faces_by_mat_id(obj.mesh)
		
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

fn CleanLayers =( --Deletes empty layers after import
	
	for l=LayerManager.count-1 to 0 by -1 do (
		local this_layer = LayerManager.getLayer l
		
		canDelete = (this_layer.canDelete()) and not (LayerManager.doesLayerHierarchyContainNodes this_layer.name)
		if canDelete do (
			LayerManager.deleteLayerByName this_layer.name
		)
	)
)

fn VRage_getMatByName name =(
	
	--Get Array of Materials in Scene
	sceneMats = for m in (getClassInstances Standardmaterial) where custAttributes.get m VRage_material_CA != undefined collect m
	
	--collect list of Names from SceneMats
	sceneMatNames = for m in sceneMats collect m.name
		
	index = findItem sceneMatNames name
	
	if index > 0 then (
		material = sceneMats[index]
	)
	else (		
		if VRage_MatLib == undefined do (
			VRage_MatLib = VRage_materialLib()
			VRage_MatLib.main()
		)
		material = VRage_MatLib.get_mat_by_name name
	)
	
	material
	
)

fn VRage_cleanMats obj_list =(
	
	obj_list = obj_list as array
	
	for o in obj_list do(
		
		condense_material_ids o
		
		if classOf o.material == Multimaterial then (
			
			for m = 1 to o.material.materialList.count do (
				old_material = o.material.materialList[m]
				
				if (custAttributes.get old_material VRage_material_CA) == undefined do (
					
					new_material = VRage_getMatByName old_material.name --error kommt hier her
					
					if new_material != undefined then (
						
						o.material.materialList[m] = new_material
						
					)
					else (
						if not MatchPattern old_material.name pattern:"*_Blocks Slot #*" do (
							error_stream = "" as StringStream
							format "No Material named \"%\" for object \"%\" in XML files" old_material.name o to:error_stream
							VRage_report_Error error_stream
						)
					)
				)
			)
		)
		else (
			if o.material != undefined do (
				new_material = VRage_getMatByName o.material.name
				if new_material != undefined then (
					o.material = new_material
				)
				else (
					error_stream = "" as StringStream
					format "No Material named \"%\" for object \"%\" in XML files" material.name o
				)
			)
		)
	)
	
	print "Done!"
)

fn VRage_write_material_xml obj_list =(
	
	material_names = #()
	
	for o in obj_list do (
		
		if classOf o.material == multimaterial do (
			for m in o.material.materialList do (
				appendIfUnique material_names m.name
			)
		)
	)
	
	xmlDoc = dotNetObject "system.xml.xmlDocument"

	/* create header */
	header = xmlDoc.CreateXmlDeclaration "1.0" "" ""
	xmlDoc.AppendChild header

	root = xmlDoc.createElement "Model"
	root.SetAttribute "Name" "Default"
	xmlDoc.appendChild root

	for n in material_names do (
		
		newRef = xmlDoc.createElement "MaterialRef"
		newRef.SetAttribute "Name" n
		root.appendChild newRef
	)



	xmlDoc.save ((getDir #temp)+"\\test.xml")

	edit ((getDir #temp)+"\\test.xml")
	
)

VRage_MatLib = VRage_materialLib()
--VRage_MatLib.main()
--format "VRage Material Library initialised\n"
