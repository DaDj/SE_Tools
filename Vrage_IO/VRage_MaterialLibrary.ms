if MyVRageCfg == undefined do (
    root = pathConfig.removePathLeaf (getSourceFileName());
    
    if matchpattern (toLower root) pattern:"*vragetoolbox*" then (
        while toLower (a = filterString root "\\")[a.count] != "vragetoolbox" do (
            root = getfilenamepath (trimright root "\\")
        )
    
        fileIn (root + "Vrage_Startup.ms")
    )
    else (
        MessageBox "Vrage Toolbox can not be initialised!"
    )
)
	
placeholder_texture = @"E:\Program Files (x86)\Steam\SteamApps\common\SpaceEngineersModSDK\OriginalContent\textures\\fake.png"

global MyVRageMatLib

if MyVRageCfg == undefined do (
	fileIn 
)

fn VRage_report_Error msg =(

	print (msg as string)
	
)

VrageMaterial_CA = attributes VrageMaterial attribID:#(0x162d47c4, 0x6a278b17)
(
	parameters main rollout:params (
		is_se_material Type:#boolean Default:True
		timeGen type:#integer Default:(timestamp())
	)
	Rollout params "Space Engineers Material" (
		label lb_info "Space Engineers Material"
	)
)

struct VrageMaterial (
	
	xml_mat,
	
	fn get_path m tex_dir:undefined =(
		
		if tex_dir == undefined do (
			tex_dir = MyVRageMatLib.get_tex_dir()
		)

		if not MyVRageCfg.UseGameTextures then (
			outpath = tex_dir + (substituteString m ".dds" VRageTexTypes[MyVRageCfg.TextureType])
		)
		else (
			outpath = tex_dir + m
		)
		print outpath
		print (doesFileExist outpath)
		
		outpath
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
			custAttributes.add material VrageMaterial_CA
		)
		catch ()
		
		material
	)
	
)

struct VRageMaterialLibrary (
	
	files,
		
	xmlDoc,
	
	mat_list = #(),
	mat_names = #(),
	
	fn get_tex_dir =(
		if MyVRageCfg.UseGameTextures then (
			tex_dir = MyVRageCfg.PathGame + @"\Content\"
		)
		else (
			split = filterString MyVRageCfg.PathTextures "\\"
			
			if toLower(split[split.count]) == "textures" then (
				tex_dir = getFilenamePath MyVRageCfg.PathTextures
			)
			else (
				tex_dir = MyVRageCfg.PathTextures
			)
			
			tex_dir = MyVRageCfg.PathTextures + "\\"
		)
		
		tex_dir
	),
	
	--Fetch Material by material name
	fn get_mat_by_name name tex_dir:undefined =(
		
		xpath = substituteString "//Material[@Name='%']" "%" (name as string)
		xml_mat = xmlDoc.selectSingleNode xpath
		
		if xml_mat != undefined then (
			mat = (VrageMaterial xml_mat:xml_mat).get_material tex_dir:tex_dir
		)
		else (
			mat = undefined
		)
		
		mat
	),
	
	fn get_mat_list =(
		
		xml_mats = xmlDoc.selectNodes "//Material"
		
		mat_names = for i=0 to xml_mats.count-1 collect xml_mats.itemOf[i].attributes.itemOf["Name"].value
		
		sort mat_names
		mat_list = mat_names
	),
		
	fn main =(
		
		if MyVRageCfg != undefined then (
			dir = MyVRageCfg.PathModSDK + "\\OriginalContent\\Materials\\"
			if doesDirectoryExist dir then (
				files = getFiles (dir + "*.xml")
				xmlDoc = dotNetObject "system.xml.xmlDocument"
				
				xmlDoc.load files[1]
				
				for f = 2 to files.count do (
					tempDoc = dotNetObject "system.xml.xmlDocument"
					tempDoc.load files[f]
					theNode = xmlDoc.ImportNode tempDoc.documentElement True
					xmlDoc.documentElement.appendchild theNode
				)
				
				get_mat_list()
			)
			else (
				--TODO: Errormessage Materialdirectory not found
			)
		)
		else (
			--TODO: Errormessage ModSDK not set	
		)
	)
	
)

fn VRage_getMatByName name tex_dir:undefined=(
	
	--Get Array of Materials in Scene
	sceneMats = for m in (getClassInstances Standardmaterial) where custAttributes.get m VrageMaterial_CA != undefined collect m
	
	--collect list of Names from SceneMats
	sceneMatNames = for m in sceneMats collect m.namem
		
	index = findItem sceneMatNames name
	
	if index > 0 then (
		material = sceneMats[index]
	)
	else (		
		if MyVRageMatLib == undefined do (
			MyVRageMatLib = VRageMaterialLibrary()
			MyVRageMatLib.main()
		)
		material = MyVRageMatLib.get_mat_by_name name tex_dir:tex_dir
	)
	
	material
	
)

fn VRage_cleanMats obj_list =(
	
	obj_list = obj_list as array
	this_tex_dir = MyVRageMatLib.get_tex_dir()
	for o in obj_list do(
		
		Vrage_condenseMatIds o
		
		if classOf o.material == Multimaterial then (
			
			for m = 1 to o.material.materialList.count do (
				old_material = o.material.materialList[m]
				
				if (custAttributes.get old_material VrageMaterial_CA) == undefined do (
					
					new_material = VRage_getMatByName old_material.name tex_dir:this_tex_dir
					
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

MyVRageMatLib = VRageMaterialLibrary()
MyVRageMatLib.main()
--format "VRage Material Library initialised\n"
