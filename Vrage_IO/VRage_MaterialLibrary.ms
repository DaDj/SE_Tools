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

global MyVRageMatLib

global MyVrageNoTex
MyVrageNoTex = pathConfig.removePathLeaf (getSourceFileName()) + "\\NoTex.tif"

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
	
	fn get_path m =(
		if m != undefined then (
			if MyVrageMatLib.tex_dir == undefined do (
				MyVrageMatLib.tex_dir = MyVRageMatLib.get_tex_dir()
			)

			if not MyVRageCfg.UseGameTextures then (
				outpath = MyVrageMatLib.tex_dir + (substituteString m ".dds" VRageTexTypes[MyVRageCfg.TextureType])
			)
			else (
				outpath = MyVrageMatLib.tex_dir + m
			)
			
			if not doesFileExist outpath then (
				MyVRageLog.Warn ("Texturefile \"" + outpath + "\" could not be found, using placeholder instead!")
				outpath = MyVrageNoTex
			)
		)
		else (
			MyVRageLog.Error ("Material \"" + xml_mat.attributes.itemOf["Name"].value + "\" has an undefined texturemap, using placeholder instead!")	
			outpath = MyVrageNoTex
		)

		outpath
	),
	
	fn get_bm m = (
		bm = openBitmap (get_path m)
		bm.gamma = 1.0
		
		bm
	),
	
	fn get_std_material =(
		material = StandardMaterial Name:xml_mat.attributes.itemOf["Name"].value showInViewport:true
		cm_map = xml_mat.selectSingleNode "Parameter[@Name='ColorMetalTexture']"
		op_map = xml_mat.selectSingleNode "Parameter[@Name='AlphamaskTexture']"
				
		if cm_map != undefined and doesFileexist (get_path cm_map.innertext) then (
			material.diffuseMap = bitmaptexture bitmap:(get_bm cm_map.innertext) alphasource:2
		)
		else (
			material.diffuseMap = bitmaptexture filename:MyVrageNoTex alphasource:2
		)
			
		if op_map != undefined and doesFileexist (get_path op_map.innertext) do (
			material.opacityMap = Bitmaptexture bitmap:(get_bm op_map.innertext) alphasource:2 monoOutput:0 RGBOutput:0
		)
		
		material
	),

	fn get_tr_material =(
		
		mat_name = (xml_mat.selectSingleNode "Id/SubtypeId").innertext
		material = StandardMaterial Name:mat_name showInViewport:true
		
		tex = xml_mat.selectSingleNode "Texture"
		glossTex = xml_mat.selectSingleNode "GlossTexture"
		glossTexAdd = xml_mat.selectSingleNode "GlossTextureAdd"

		col = xml_mat.selectSingleNode "Color"
		colAdd = xml_mat.selectSingleNode "ColorAdd"
		uvSize = xml_mat.selectSingleNode "UVSize"
		uvOffset = xml_mat.selectSingleNode "UVOffset"
		reflectivity = xml_mat.selectSingleNode "Reflectivity"

		if tex != undefined then (
			tex_bm = get_bm tex.innertext
			material.diffuseMap = bitmapTexture bitmap:tex_bm alphasource:2
			material.opacityMap = Bitmaptexture bitmap:tex_bm alphasource:2 monoOutput:1 RGBOutput:1
		)
		else (
			material.diffuseMap = bitmapTexture filename:MyVrageNoTex alphasource:2
		)
		
		if col != undefined then (
			dCol = Vrage_XMLtoColor col
			
			material.opacityMapAmount = 100 * col.item["W"].innertext as float
			material.Diffuse = dCol
			if colAdd != undefined do (
				colAdd_alpha = colAdd.item["W"].innertext as float
				if colAdd_alpha == 0 do colAdd_alpha = 1
					
				material.opacity = 100 * colAdd_alpha
				material.Diffuse = dCol + Vrage_XMLtoColor colAdd
			)
		)
		else (
			material.Diffuse = white
		)
		
		if glossTex != undefined do (
			gtex_bm = get_bm glossTex.innertext
			material.bumpMap = Normal_Bump normal_map:(bitmapTexture bitmap:gtex_bm alphasource:2) flipgreen:true
			material.glossinessMap = bitmapTexture bitmap:gtex_bm alphasource:2 monoOutput:1
			if glossTexAdd != undefined then (
				material.glossinessMapAmount = 100 * glossTexAdd.innertext as float
			)
			else (
				material.glossinessMapAmount = 100
			)
		)
		
		if glossTexAdd != undefined do (
			material.specularLevel = 100 * glossTexAdd.innertext as float
			material.glossiness = 100
		)
		
		refTex = "Textures\BackgroundCube\Final\BackgroundCube.TIF"
		
		if doesFileExist (get_path refTex) do (
			
			ref = falloff type:2
			
			ref.map1 = Bitmaptexture bitmap:(get_bm refTex)
			ref.map1.coords.mappingtype = 1 --set the mapping type to environment
			ref.map1.coordinates.mapping = 1 --set the mapping to Screen
			ref.map1.coordinates.V_Tiling = 1.5
			ref.map1.coordinates.W_Angle = 90
			material.reflectionMap = ref
		)
		
		material
	),
	
	fn get_material =(
		
		transp = (toLower xml_mat.Name) == "transparentmaterial"

		/*
		(MyVrageCfg.UsePbrMats and transp):get_tr_pbr_material()
		(MyVrageCfg.UsePbrMats): get_pbr_material()
		*/
		
		out = case Of (
			transp: get_tr_material()
			default: get_std_material()
		)
		
		try (
			custAttributes.add out VrageMaterial_CA
		)
		catch ()
		
		out.timeGen = MyVrageMatLib.timeGen
		
		out
	)
	
)

struct VRageMaterialLibrary (
	
	files,
		
	xmlDoc,
	timeGen = 0,
	mat_list = #(),
	mat_names = #(),
	
	tex_dir = undefined,
	
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
		
	),
	
	--Fetch Material by material name
	fn get_mat_by_name name =(
		
		xpath = "//TransparentMaterial[Id/SubtypeId[contains(text(),'" + name + "')]]"
		xml_mat = xmlDoc.selectSingleNode xpath
		
		If xml_mat == undefined do (
			xpath = substituteString "//Material[@Name='%']" "%" (name as string)
			xml_mat = xmlDoc.selectSingleNode xpath
		)
		
		if xml_mat != undefined then (
			mat = (VrageMaterial xml_mat:xml_mat)
		)
		else (
			mat = undefined
		)
		
		mat
	),
	
	fn get_mat_list =(
		
		xml_mats = xmlDoc.selectNodes "//Material"
		xml_TransMats = xmlDoc.selectNodes "//TransparentMaterial/Id/SubtypeId"
		
		reg_mat_names = for i=0 to xml_mats.count-1 collect xml_mats.itemOf[i].attributes.itemOf["Name"].value
		transp_mat_names = for i =0 to xml_TransMats.count-1 collect xml_TransMats.itemOf[i].innertext
			
		for t in transp_mat_names where findItem reg_mat_names t == 0 do append reg_mat_names t
		
		
		mat_names = deepcopy reg_mat_names
		sort mat_names
		mat_list = mat_names
	),
		
	fn main =(
		
		if MyVRageCfg != undefined then (
			dir = (trimright MyVRageCfg.PathModSDK "\\") + "\\OriginalContent\\Materials\\"
			if doesDirectoryExist dir then (
				files = getFiles (dir + "*.xml")
				
				transp_mats = MyVrageCfg.PathGame + @"\Content\Data\TransparentMaterials.sbc"
				
				if doesFileExist transp_mats do (
					append files transp_mats
				)
				
				xmlDoc = dotNetObject "system.xml.xmlDocument"
				
				xmlDoc.load files[1]
				
				for f = 2 to files.count do (
					tempDoc = dotNetObject "system.xml.xmlDocument"
					tempDoc.load files[f]
					theNode = xmlDoc.ImportNode tempDoc.documentElement True
					xmlDoc.documentElement.appendchild theNode
				)
				
				timeGen = timeStamp()
				
				get_mat_list()
			)
			else (
				--TODO: Errormessage Materialdirectory not found
				messageBox "Materialdirectory not found"
			)
		)
		else (
			--TODO: Errormessage ModSDK not set
			messageBox "ModSDK not set"
		)
	)
	
)

fn VRage_getMatByName name=(
	
	--Get Array of Materials in Scene
	sceneMats = for m in (getClassInstances Standardmaterial) where isProperty m #is_se_material and m.timeGen >= MyVRageMatLib.timeGen collect m
	
	--collect list of Names from SceneMats
	sceneMatNames = for m in sceneMats collect m.name
		
	index = findItem sceneMatNames name
	
	if index > 0 then (
		material = sceneMats[index]
	)
	else (		
		if MyVRageMatLib == undefined do (
			MyVRageMatLib = VRageMaterialLibrary()
			MyVRageMatLib.main()
		)
		
		mat = MyVRageMatLib.get_mat_by_name name
		
		material = if mat != undefined then mat.get_material() else undefined
	)
	
	material
	
)

fn VRage_cleanMats obj_list =(
	
	if doesFileExist MyVrageCfg.PathToolsFolder then (
		obj_list = obj_list as array
		
		if not (doesFileExist (MyVrageCfg.PathToolsFolder + "\\Textures")) and not MyVrageCfg.UseGameTextures do (
			return VrageLogSys.Error "Texture folder does not exist!"
		)
		
		MyVRageMatLib.get_tex_dir()
		
		undo "Vrage Clean Materials" on (
			with redraw off (
				for o in obj_list do(
					
					if o != undefined do Vrage_condenseMatIds o

					if classOf o.material == Multimaterial then (
						
						for m = 1 to o.material.materialList.count do (
							old_material = o.material.materialList[m]
							
							if old_material != undefined and (custAttributes.get old_material VrageMaterial_CA) == undefined do (
								
								new_material = VRage_getMatByName old_material.name
								
								if new_material != undefined then (
									
									o.material.materialList[m] = new_material
									
								)
								else (
									if not MatchPattern old_material.name pattern:"*_Blocks Slot #*" do (
										error_stream = "" as StringStream
										format "No Material named \"%\" for object \"%\" in XML files" old_material.name o to:error_stream
										VrageLogSys.Error (error_stream as string)
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
								format "No Material named \"%\" for object \"%\" in XML files" o.material.name o to:error_stream
								VrageLogSys.Error (error_stream as string)
							)
						)
					)
				)
				
				select obj_list
			)
		)
		
	)
	else (
		VRage_report_Error "Tools Folder does not exist/is not set!\nOpen settings and correct your configuration!"
	)
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
--test