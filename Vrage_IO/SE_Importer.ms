--Generates a Material Library from Space Engineers Material xml files

try destroydialog randomMat catch()

placeholder_texture = "E:\Program Files (x86)\Steam\SteamApps\common\SpaceEngineersModSDK\OriginalContent\textures\\fake.png"
material_xml_dir = "E:\\Program Files (x86)\\Steam\\SteamApps\\common\\SpaceEngineersModSDK\\OriginalContent\\Materials\\"
--tex_dir = "E:\\Users\\Robin\\Documents\\SE Modding\\models\\"
--tex_ext = ".tif"

tex_dir = "C:\\SteamLibrary\\steamapps\\common\\SpaceEngineers\\Content\\"
tex_ext = ".dds"

global SE_MatLib


fn SE_report_Error msg =(

	print (msg as string)
	
)

SE_material_CA = attributes SE_material attribID:#(0x162d47c4, 0x6a278b17)
(
	parameters main rollout:params (
		'is_se_material' Type:#boolean Default:True
	)
	Rollout params "Space Engineers Material" (
		label lb_info "Space Engineers Material"
	)
)

struct SE_material (
	
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
			custAttributes.add material SE_material_CA
		)
		catch ()
		
		material
	)
	
)

struct SE_materialLib (

	files = getFiles (material_xml_dir + "*.xml"),
	
	xmlDoc = dotNetObject "system.xml.xmlDocument",
	
	--Fetch Material by material name
	fn get_mat_by_name name =(
		
		xpath = substituteString "//Material[@Name='%']" "%" (name as string)
		xml_mat = xmlDoc.selectSingleNode xpath
		
		if xml_mat != undefined then (
			mat = (SE_Material xml_mat:xml_mat).get_material()
		)
		else (
			mat = undefined
		)
		
		mat
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

fn SE_getMatByName name =(
	
	--Get Array of Materials in Scene
	sceneMats = for m in (getClassInstances Standardmaterial) where custAttributes.get m SE_material_CA != undefined collect m
	
	--collect list of Names from SceneMats
	sceneMatNames = for m in sceneMats collect m.name
		
	index = findItem sceneMatNames name
	
	if index > 0 then (
		material = sceneMats[index]
	)
	else (		
		if SE_MatLib == undefined do (
			SE_MatLib = SE_materialLib()
			SE_MatLib.main()
		)
		material = SE_MatLib.get_mat_by_name name
	)
	
	material
	
)

fn SE_cleanMats obj_list =(
	
	obj_list = obj_list as array
	
	for o in obj_list do(
		
		condense_material_ids o
		
		if classOf o.material == Multimaterial then (
			
			for m = 1 to o.material.materialList.count do (
				old_material = o.material.materialList[m]
				
				if (custAttributes.get old_material SE_material_CA) == undefined do (
					
					new_material = SE_getMatByName old_material.name --error kommt hier her
					
					if new_material != undefined then (
						
						o.material.materialList[m] = new_material
						
					)
					else (
						if not MatchPattern old_material.name pattern:"SE_Blocks Slot #*" do (
							error_stream = "" as StringStream
							format "No Material named \"%\" for object \"%\" in XML files" old_material.name o to:error_stream
							SE_report_Error error_stream
						)
					)
				)
			)
		)
		else (
			if o.material != undefined do (
				new_material = SE_getMatByName o.material.name
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

fn SE_write_material_xml obj_list =(
	
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

fn SE_importFBX file root_layer:(LayerManager.getLayer 0) parent_layer:undefined parent_node:undefined = (

	fname = filenameFromPath file --getFilenameFile
	name = getFilenameFile file
		
	old_objects = objects as array
	
	importfile file #noPrompt using:FBXIMP
		
	imported = for o in objects where findItem old_objects o == 0 collect o
	
	if parent_layer == undefined then (
		parent_layer = layermanager.newLayerFromName fname
		parent_layer.setParent root_layer
		lod0_layer = layermanager.newLayerFromName ("LOD0 (" + fname + ")")
		lod0_layer.setParent parent_layer
		dummy_layer = layermanager.newLayerFromName ("Dummies (" + fname + ")")
		dummy_layer.setParent parent_layer

		for o in imported do (
			case (superclassOf o) of (
				GeometryClass: lod0_layer.addNode o
				helper: dummy_layer.addNode o
			)
		)
			
		subparts = for o in imported where (superclassOf o == helper) and (isProperty o "file") collect o
		
		if subparts.count > 0 do (
			sub_layer = layermanager.newLayerFromName ("Subparts (" + fname + ")")
			sub_layer.setParent parent_layer
			
			for sub in subparts do (
				sub_file = getFilenamePath file + sub.file as string + ".fbx"
				if doesFileExist sub_file do (
					sub_imports = SE_importFBX sub_file root_layer:sub_layer parent_node:sub			
					join imported sub_imports
				)
			)
		)
		
		lod_files = getFiles (getFilenamePath file + name + "_LOD*.FBX")
		
		for lod_file in lod_files do (
			lod_imports = SE_importFBX lod_file parent_layer:parent_layer parent_node:parent_node
			join imported lod_imports
		)
		
		construction_files = getFiles (getFilenamePath file + getFilenameFile file + "Construction*.FBX") + getFiles (getFilenamePath file + getFilenameFile file + "_Construction*.FBX")
		
		if construction_files.count > 0 do (
			constr_layer = layermanager.newLayerFromName ("Construction (" + fname + ")")
			constr_layer.setParent parent_layer
			constr_layer.ishidden  = True
			
			for constr in construction_files where not matchpattern constr pattern:"*_LOD*" do (
				constr_imports = SE_importFBX constr root_layer:constr_layer parent_node:parent_node
				join imported constr_imports
			)
			
		)
			
		if parent_node != undefined do (
			for o in imported where o.parent == undefined do (
				o.position = parent_node.position
				o.parent = parent_node
			)
		)
	)
	else (
		lod_name = getFilenameFile file
		lod_name = subString lod_name (1 + FindString lod_name "_LOD") -1
			
		lod_layer = layermanager.newLayerFromName (lod_name + " (" + fname + ")")
		lod_layer.setParent parent_layer
		lod_layer.ishidden  = True
		
		for i = imported.count to 1 by -1 do (
			o = imported[i]
			case (superclassOf o) of (
				GeometryClass: lod_layer.addNode o
				helper: delete o
			)			
		)
	)
	
	imported
)

rollout randomMat "Clean Material" width:250 (
	
	--edittext et_name "Material:" readOnly:True
	--button b_random "Randomize!"
	button b_clean "clean"
	
	on b_random pressed do (
		
		if $Box001 == undefined do (
			Box name:"Box001" mapcoords:on
			addModifier $Box001 (UVW_Xform U_tile:2 V_tile:2 W_tile:2)
		)
		
		rand_name = lib.names[random 1 lib.names.count]
		
		et_name.text = rand_name
		
		$Box001.material = lib.get_mat_by_name rand_name
		
	)
	
	on b_clean pressed do (
		object_list = for o in objects where classOf o == editable_mesh and o.material != undefined collect o
		
		SE_cleanMats object_list
	)
	
)

max reset file
clearListener()

start = timestamp()

SE_MatLib = SE_materialLib()
SE_MatLib.main()

dir = @"E:\Program Files (x86)\Steam\SteamApps\common\SpaceEngineersModSDK\OriginalContent\Models\Cubes\large\"

fname1 = "SlideDoor.FBX"

LastImport = SE_importFBX (dir + fname1)
cleanLayers()

SE_cleanMats LastImport
	
time_expired = timestamp() - start
