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
global MyVrageMatBrowser


MyVrageNoTex = pathConfig.removePathLeaf (getSourceFileName()) + "\\NoTex.tif"
try MyVrageMatBrowser.close() catch()


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
	OSLBitmap = getdir #maxroot + "\\OSL\\OSLBitmap.osl",
	
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
				errorMsg = "Texturefile \"" + outpath + "\" could not be found, using placeholder instead!"
				outpath = MyVrageNoTex
				
				if findItem MyVrageMatLib.warnings errorMsg == 0 do (
					MyVRageLog.Warn errorMsg
					append MyVrageMatLib.warnings errorMsg
				)
				
			)
		)
		else (
			errorMsg = "Material \"" + xml_mat.attributes.itemOf["Name"].value + "\" has an undefined texturemap, using placeholder instead!"
			outpath = MyVrageNoTex
			
			if findItem MyVrageMatLib.errors errorMsg == 0 do (
				MyVRageLog.Error errorMsg
				append MyVrageMatLib.errors errorMsg
			)
		)

		outpath
	),
	
	fn get_bm m = (
		bm = openBitmap (get_path m)
		
		if bm == undefined do (
			bm = openBitmap MyVrageNoTex
		)
		
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
	
	fn get_tr_pbr_material =(
		mat_name = (xml_mat.selectSingleNode "Id/SubtypeId").innertext
		material = PBRMetalRough Name:mat_name useGlossiness:1

		nt_osl_map = OSLMap OSLPath:OSLBitmap filename:MyVrageNoTex autogamma: 1
		nt_osl_map.autogamma = 1
		nt_interface = MultiOutputChannelTexmapToTexmap sourceMap:nt_osl_map outputChannelIndex:1 
		material.base_color_map = nt_interface
		
		material
	),
		
	
	fn get_pbr_material =(
		
		cm_map = xml_mat.selectSingleNode "Parameter[@Name='ColorMetalTexture']"
		ng_map = xml_mat.selectSingleNode "Parameter[@Name='NormalGlossTexture']"
		add_map = xml_mat.selectSingleNode "Parameter[@Name='AddMapsTexture']"
		op_map = xml_mat.selectSingleNode "Parameter[@Name='AlphamaskTexture']"
		
		material = PBRMetalRough Name:(xml_mat.attributes.itemOf["Name"].value) useGlossiness:1 normal_flip_green:True

		if cm_map != undefined and doesFileexist (get_path cm_map.innertext) then (
			cm_osl_map = OSLMap Name:(getFilenameFile cm_map.innertext) OSLPath:OSLBitmap filename:(get_path cm_map.innertext) autogamma: 1
			cm_osl_map.autogamma = 1
			c_interface = MultiOutputChannelTexmapToTexmap sourceMap:cm_osl_map outputChannelIndex:1 
			m_interface = MultiOutputChannelTexmapToTexmap sourceMap:cm_osl_map outputChannelIndex:5 
			material.base_color_map = c_interface
			material.metalness_map = m_interface
		) else (
			nt_osl_map = OSLMap Name:"NOTEXTURE" OSLPath:OSLBitmap filename:MyVrageNoTex autogamma: 1
			nt_osl_map.autogamma = 1
			nt_interface = MultiOutputChannelTexmapToTexmap sourceMap:nt_osl_map outputChannelIndex:1 
			material.base_color_map = nt_interface
		)

		if ng_map != undefined and doesFileexist (get_path ng_map.innertext) then (
			ng_osl_map = OSLMap Name:(getFilenameFile ng_map.innertext) OSLPath:OSLBitmap filename:(get_path ng_map.innertext)
			n_interface = MultiOutputChannelTexmapToTexmap sourceMap:ng_osl_map outputChannelIndex:1
			g_interface = MultiOutputChannelTexmapToTexmap sourceMap:ng_osl_map outputChannelIndex:5
			material.norm_map = n_interface
			material.roughness_map = g_interface
		)

		if add_map != undefined and doesFileexist (get_path add_map.innertext) then (
			add_osl_map = OSLMap Name:(getFilenameFile add_map.innertext) OSLPath:OSLBitmap filename:(get_path add_map.innertext)
			ao_interface = MultiOutputChannelTexmapToTexmap sourceMap:add_osl_map outputChannelIndex:2
			em_interface = MultiOutputChannelTexmapToTexmap sourceMap:add_osl_map outputChannelIndex:3
			p_interface = MultiOutputChannelTexmapToTexmap sourceMap:add_osl_map outputChannelIndex:4
			col_interface = MultiOutputChannelTexmapToTexmap sourceMap:add_osl_map outputChannelIndex:5
			material.ao_map = ao_interface
			material.emit_color_map = em_interface
		)

		if op_map != undefined and doesFileexist (get_path op_map.innertext) then (
			mask_osl_map = OSLMap Name:(getFilenameFile op_map.innertext) OSLPath:OSLBitmap filename:(get_path op_map.innertext)
			mask_interface = MultiOutputChannelTexmapToTexmap sourceMap:mask_osl_map outputChannelIndex:1
			material.opacity_map = mask_interface
		)

		material.base_color_map.sourcemap.autogamma = 1
		material
	),

	fn get_material =(
		
		transp = (toLower xml_mat.Name) == "transparentmaterial"

		/*

		*/
		
		out = case Of (
			(MyVrageCfg.UsePbrMats and transp):get_tr_pbr_material()
			(MyVrageCfg.UsePbrMats): get_pbr_material()
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
	errors = #(),
	warnings = #(),
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

		mat_names = deepcopy (makeUniqueArray reg_mat_names)
		sort mat_names
		mat_list = mat_names
		
		errors = #()
		warnings = #()
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
				
				all_mats = (trimright MyVRageCfg.PathModSDK "\\") + "\\OriginalContent\\AllMaterials.xml"
				
				if doesFileExist all_mats do (
					insertItem all_mats files 1
				)
					
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

struct Vrage_MaterialButton (
	
	name = '',
	bsize = 100,
	bpadding = 6,
	bsize_image = bsize - bpadding * 2,
	bmargin = 3,
	
	fn click_event=(
		
		undo "Vrage: Assign Material" on (
			
			local new_mat = VRage_getMatByName name
			local target = modpanel.getcurrentobject()
			
			local sel = selection as array
			
			local mode = undefined 
			
			if isProperty target #materialID and classOf target == Chamfer do (
				local queryDialog = rollout queryDialog "" width:360
				(
					
					local result
					
					local txt = "The current Modifier references a material ID, would you like to:\n\n" \
					+"A : Overwrite the current material ID with the selected material?\n" \
					+"B : Append the selected material as a new Material ID?\n" \
					+"C : Abort and change nothing?"
					
					label lb_text txt height:75
					
					button b_overwrite "Overwrite" height:24 width:80 across:3 align:#left
					button b_append "Append" height:24 width:80 align:#center
					button b_abort "Abort" height:24 width:80 align:#right
					
					fn init val:undefined =(
						try destroyDialog queryDialog catch()
						result = val
						createDialog queryDialog modal:true
						setFocus queryDialog
						result
					)

					fn switchAndClose val =(
						result = val
						destroyDialog queryDialog
					)

					on b_overwrite pressed do switchAndClose #overwrite
					on b_append pressed do switchAndClose #append
					on b_abort pressed do destroyDialog queryDialog
				)

				queryDialog.init()
				
				mode = queryDialog.result
			)
			
			for o in sel do (		
				
				case classOf target of (
					(Edit_Poly): (
						if subobjectlevel >= 4 and ((facesel = target.GetSelection #Face) as array).count != 0 then (
							temp_mat = VRage_JoinMaterials o.Material new_mat
							o.Material = temp_mat[1]
							target.SetOperation #SetMaterial 
							target.materialIDToSet = temp_mat[2] - 1
							target.Commit()
						)
						else (
							o.material = new_mat
							num = target.getnumfaces()
							target.setSelection #face #{1..num}
							target.SetOperation #SetMaterial 
							target.materialIDToSet = (0)
							target.Commit()
							target.setSelection #face #{}
						)
					)
					(Editable_poly):(
						if subobjectlevel >= 4 and ((facesel = polyop.getFaceSelection target) as array).count != 0 then (
							o.material = new_mat
							--o.material.names = for m in o.material.materiallist collect m.name
						)
						else (
							o.material = new_mat
							facesel = #{1..(polyop.getNumFaces o)}
							polyop.setFaceMatID o facesel 1
						)
					)
					(Chamfer):(
						target.SetMaterial = on
						case mode of (
							
							#overwrite: (
								if classOf o.material == multimaterial then (
									o.material.materiallist[target.materialID] = new_mat
									o.material.names[target.materialID] = new_mat.name
								)
								else (
									mat_list = #(o.material)
									mat_names = #(o.material.name)
									
									mat_list[target.materialID] = new_mat
									mat_names[target.materialID] = new_mat.name
									
									mat_names = for n in mat_names collect if n == undefined then "" else n
									o.material = Multimaterial numsubs:mat_list.count materiallist:mat_list names:mat_names 
								)
							)
							#append: (
								temp_mat = VRage_JoinMaterials o.Material new_mat
								o.Material = temp_mat[1]
								target.materialID = temp_mat[2]
							)
							default:()
						)
						
					)
					default:o.material = new_mat
				)
			)
		)
		
		redrawViews()
	),
	
	fn getButton =(
		
		imageList = dotNetObject "System.Windows.Forms.ImageList"
		imageList.ImageSize = dotNetObject "System.Drawing.Size" bsize_image bsize_image
		imageList.ColorDepth = (dotNetClass "System.Windows.Forms.ColorDepth").Depth32bit
		
		thumb_path = MyVrageCfg.VrageConfigDir + "\\MaterialThumbnails\\" + name + ".jpg"
		
		if doesFileExist thumb_path then (
			imageList.images.add ((dotNetClass "System.Drawing.Image").fromFile thumb_path)
		)
		else (
			imageList.images.add ((dotNetClass "System.Drawing.Image").fromFile MyVrageCfg.DefaultThumbnail)
		)
		
		bFontStyle = (dotNetClass "System.Drawing.FontStyle").bold
		bfont = dotNetObject "System.Drawing.Font" "Microsoft Sans Serif" 7 bFontStyle

		mButton = dotNetObject "System.Windows.Forms.Button"
		mButton.text = name
		mButton.size = dotNetObject "System.Drawing.Size" bsize bsize
		
		mButton.ImageList = imageList
		mButton.ImageIndex = 0

		mButton.ImageAlign = (dotNetClass "System.Drawing.ContentAlignment").MiddleCenter
		mButton.TextAlign = (dotNetClass "System.Drawing.ContentAlignment").topLeft
		mButton.padding = dotNetObject "System.Windows.Forms.Padding" bpadding

		mButton.Font = bfont
		mButton.Margin = dotNetObject "System.Windows.Forms.Padding" bmargin
		
		dotNet.addEventHandler mButton "click" click_event
		dotnet.setLifetimeControl mButton #dotnet
		
		mButton
	)
)

struct Vrage_MaterialBrowser (
	
	Margin = dotNetObject "System.Windows.Forms.Padding" 5,
	Padding = dotNetObject "System.Windows.Forms.Padding" 5,
	DockStyle = dotNetClass "System.Windows.Forms.DockStyle",
	BorderStyle = dotNetClass "System.Windows.Forms.BorderStyle",
	Color = dotNetClass "System.Drawing.Color",
	AutoSizeMode = dotNetClass "System.Windows.Forms.AutoSizeMode",
	AnchorStyles = dotNetClass "System.Windows.Forms.AnchorStyles",
	dnKeys = dotnetclass "System.Windows.Forms.Keys",
	
	form_size = [815, 480],
	Mat_Layout = dotNetObject "System.Windows.Forms.FlowLayoutPanel",
	Mat_Group = dotNetObject "System.Windows.Forms.Groupbox",
	Filter_Group = dotNetObject "System.Windows.Forms.Groupbox",
	hForm = dotNetObject "MaxCustomControls.MaxForm",
	filter_box = dotNetObject "System.Windows.Forms.Textbox",
	filter_button = dotNetObject "System.Windows.Forms.button",
	
	last_txt = "",
	
	fn populateMats txt:"" =(
		
		Mat_Layout.controls.clear()
		
		for n in MyVrageMatLib.mat_names where matchpattern n pattern:("*" + txt + "*") do (			
			Mat_Layout.controls.add ((Vrage_MaterialButton name:n).getButton())
		)
		
		print Mat_Layout.controls.count
		
	),
	
	fn filter_box_ku sender eb =(
		if eb.KeyCode == eb.KeyCode.Enter and sender.text != last_txt do (
			last_txt = sender.text
			populateMats txt:sender.text
		)
	),
		
	fn filter_box_click sender eb =(
		new_txt = filter_box.text
		if new_txt != last_txt do (
			last_txt = new_txt
			populateMats txt:new_txt
		)
	),
	
	fn getForm =(
		Vrage_getMaterialThumbnails MyVrageMatLib.mat_names
		/*Filter_Group*/
		Filter_Group.location = dotNetObject "System.Drawing.Point" 5 5
		Filter_Group.size = dotNetObject "System.Drawing.Size" (form_size.x - 30) ((form_size.y - 30) * 0.12)
		Filter_Group.Margin = Margin
		Filter_Group.padding = Padding
		Filter_Group.text = "Filter:"
		Filter_Group.Dock = DockStyle.Top
		Filter_Group.forecolor = Color.white
		
		/*Mat_Group*/
		--Mat_Group.location = dotNetObject "System.Drawing.Point" 5 (10 + ((form_size.y - 30) * 0.15))
		--Mat_Group.size = dotNetObject "System.Drawing.Size" (form_size.x - 30) ((form_size.y - 30) * 0.85 - 20)
		Mat_Group.Margin = Margin
		Mat_Group.padding = Padding
		Mat_Group.text = "Materials:"
		Mat_Group.Anchor = dotNet.combineEnums AnchorStyles.Top AnchorStyles.Left --AnchorStyles.Right AnchorStyles.Bottom
		Mat_Group.Dock = DockStyle.Fill
		Mat_Group.forecolor = Color.white
		
		/*Mat_Layout*/
		Mat_Layout.location = dotNetObject "System.Drawing.Point" (Mat_Group.location.x + 10) (Mat_Group.location.y + 10)
		Mat_Layout.size = dotNetObject "System.Drawing.Size" (Mat_Group.size.width - 100) (Mat_Group.size.height - 100)
		Mat_Layout.AutoScroll = True
		Mat_Layout.text = "Materials:"
		Mat_Layout.Dock = DockStyle.Fill
		Mat_Layout.Margin = Margin
		Mat_Layout.padding = Padding
				
		/*filter box*/
		filter_box.size = dotNetObject "System.Drawing.Size" (form_size.x - 160) 50
		filter_box.location = dotNetObject "System.Drawing.Point" 15 20
		filter_box.Margin = Margin
		filter_box.padding = Padding
		filter_box.Anchor = dotNet.combineEnums AnchorStyles.Left AnchorStyles.Top AnchorStyles.right
		dotNet.addEventHandler filter_box "keyUp" filter_box_ku
		
		dotnet.setLifetimeControl filter_box #dotnet
		
		/*filter button*/
		filter_button.size = dotNetObject "System.Drawing.Size" 100 30
		filter_button.location = dotNetObject "System.Drawing.Point" (form_size.x - filter_button.size.width - 40) 12
		filter_button.Margin = Margin
		filter_button.Anchor = dotNet.combineEnums AnchorStyles.Top AnchorStyles.Right
		filter_button.Dock = DockStyle.right
		filter_button.padding = Padding
		filter_button.text = "Filter"
		dotNet.addEventHandler filter_button "click" filter_box_click
		
		dotnet.setLifetimeControl filter_button #dotnet
		
		Filter_Group.controls.add filter_button
		Filter_Group.controls.add filter_box
		
		
		hForm.text = "Vrage Material Browser"
		hForm.padding = Padding
		hForm.margin = Margin
		
		Mat_Group.controls.add Mat_Layout
		
		hForm.controls.add Mat_Group
		hForm.controls.add Filter_Group
		
		populateMats()
		
		--hForm.controls.add Form_Layout
		--hForm.topmost = true
		
		nw = DotNetObject "System.Windows.Forms.NativeWindow"
		nw.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND()))
		
		hForm.size = dotNetObject "System.Drawing.Size" form_size.x form_size.y
		hForm.show(nw)
		nw.releaseHandle()
		--hForm.topmost = true
		hForm
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
				for o in obj_list where not isDeleted o do(
					
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
										errorMsg = error_stream as string
										
										if findItem MyVrageMatLib.errors old_material.name == 0 do (
											MyVRageLog.Error errorMsg
											append MyVrageMatLib.errors old_material.name
										)
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
								errorMsg = error_stream as string
								
								if findItem MyVrageMatLib.errors o.material.name == 0 do (
									MyVRageLog.Error errorMsg
									append MyVrageMatLib.errors o.material.name
								)
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

fn VRage_JoinMaterials obj_mat new_mat =(
	
	if obj_mat != undefined then ( 	
		case classOf obj_mat of (
			(multimaterial): ( 
				temp_mat = obj_mat
				Matnames = for m in temp_mat.materiallist collect m.name
				MatIndex = findItem Matnames (new_mat.name as string)	
				temp_mat.names = Matnames
				if MatIndex == 0 then (
					temp_mat.numsubs += 1
					temp_mat.materiallist[temp_mat.numsubs] = new_mat
					temp_mat.names[temp_mat.numsubs] = new_mat.name
					id = temp_mat.numsubs
				)
				else (
					id = MatIndex
				)
			)
			default: (
				temp_mat = multimaterial numsubs:2 materiallist:#(obj_mat, new_mat) names:#(obj_mat.name, new_mat.name)
				id = 2
			)
		)
	)
	else (
		temp_mat = multimaterial numsubs:1 materiallist:#(new_mat) names:#(new_mat.name)
		id = 1
	)
	
	#(temp_mat, id)
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

fn Vrage_getMaterialThumbnails names= (
	thumb_dir = MyVrageCfg.VrageConfigDir + "\\MaterialThumbnails\\"
	try (makeDir thumb_dir) catch()
	
	start = timestamp()
	
	if classOf names == String do (
		names = #(names)
	)
	
	MatEditor.Close()
	backup = IDisplayGamma.affectMEdit
	IDisplayGamma.affectMEdit = False
	local backupMat = meditMaterials[1]
	MyVRageLog.silent = True
	
	local thumb = undefined
	local iGlobal = (dotnetClass "Autodesk.Max.GlobalInterface").Instance
	
	progressStart "Generating Thumbnails"

	if iGlobal != undefined then (
		local IntPtr = dotnetClass "System.IntPtr"
		local pStampSize = (dotnetclass "Autodesk.Max.PostageStampSize").Large
		
		prog = 0.0
		limit = names.count as float
		
		for n in names do (
			meditMaterials[1] = Vrage_getmatbyname n
			
			local fname = thumb_dir + n + ".jpg"
		
			local matRef = iGlobal.CoreInterface.GetMtlSlot 0

			local pStamp = matRef.CreatePStamp pStampSize true
			local bytes = pStamp.Image
			local size = pStamp.Width
			
			try (
				thumb = bitmap size size gamma:1 filename:fname
				
				local step = size * 3
				for y = 1 to bytes.count by step do (
					local row = for x = y to (y + step - 1) by 3 collect [bytes[x + 2], bytes[x + 1], bytes[x]]
					setpixels thumb [0, size -= 1] row
				)
				
				format "%\n" thumb.filename
				
				try (
					save thumb
				)
				catch(format "Thumbnail could not be saved! %\n" thumb.filename)
			)
			catch()
			
			prog += 1.0
			progressUpdate (prog / limit * 100.0)
			
			pStamp.Dispose()
			matRef.Dispose()
		)
		
	)
	
	progressEnd()
	
	meditMaterials[1] = backupMat
	IDisplayGamma.affectMEdit = backup
	
	end = timestamp()
	MyVRageLog.silent = False
	--format "Time: % ms" (end - start)
)


MyVRageMatLib = VRageMaterialLibrary()
MyVRageMatLib.main()

/* Example Code to open Browser
MyVrageMatBrowser = (Vrage_MaterialBrowser()).getForm()
*/