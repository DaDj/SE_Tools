if MyVRageCfg == undefined do (
	root = pathConfig.removePathLeaf ( getSourceFileName()) ;
	
	if matchpattern ( toLower root ) pattern:"*vragetoolbox*" then (
		while toLower ( a = filterString root "\\" )[a.count] != "vragetoolbox" do (
			root = getfilenamepath ( trimright root "\\" )
		)
		
		fileIn ( root + "Vrage_Startup.ms" )
	)
	else (
		MessageBox "Vrage Toolbox can not be initialised!"
	)
)

global MyVRageMatLib

global MyVrageNoTex
global MyVrageMatBrowser

--MyVrageNoTex = pathConfig.removePathLeaf ( getSourceFileName()) + "\\NoTex.tif"
MyVrageNoTex = GetDir #userScripts + "\\VRageToolbox\\Vrage_resources\\NoTex.tif"
try MyVrageMatBrowser.close() catch()

VrageMaterial_CA = attributes VrageMaterial attribID:#( 0x162d47c4, 0x6a278b17 )
(
	parameters main rollout:params (
		is_se_material Type:#boolean Default:True
		timeGen type:#integer Default:(timestamp())
		is_decal Type:#boolean Default:False
	)
	Rollout params "Space Engineers Material" (
		label lb_info "Space Engineers Material"
	)
)


fn getDnColor val = (
	
	MXSColor_to_dotNetColor val

)


struct VrageMaterial (
	
	xml_mat,
	OSLBitmap = getdir #maxroot + "\\OSL\\OSLBitmap.osl",
	
	fn get_path m = (
		if m != undefined then (
			if MyVrageMatLib.tex_dir == undefined do (
				MyVrageMatLib.tex_dir = MyVRageMatLib.get_tex_dir()
			)

			if not MyVRageCfg.UseGameTextures then (
				outpath = MyVrageMatLib.tex_dir + ( substituteString m ".dds" VRageTexTypes[MyVRageCfg.TextureType] )
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
		bm = openBitmap ( get_path m )
		
		if bm == undefined do (
			bm = openBitmap MyVrageNoTex
		)
		
		bm.gamma = 1.0
		
		bm
	),
	
	fn get_std_material = (
		material = StandardMaterial Name:xml_mat.attributes.itemOf["Name"].value showInViewport:true
		cm_map = xml_mat.selectSingleNode "Parameter[@Name='ColorMetalTexture']"
		op_map = xml_mat.selectSingleNode "Parameter[@Name='AlphamaskTexture']"
		
		if cm_map != undefined and doesFileexist ( get_path cm_map.innertext ) then (
			material.diffuseMap = bitmaptexture bitmap:( get_bm cm_map.innertext ) alphasource:2
		)
		else (
			material.diffuseMap = bitmaptexture filename:MyVrageNoTex alphasource:2
		)
		
		if op_map != undefined and doesFileexist ( get_path op_map.innertext ) do (
			material.opacityMap = Bitmaptexture bitmap:( get_bm op_map.innertext ) alphasource:2 monoOutput:0 RGBOutput:0
		)
		
		material
	),

	fn get_tr_material = (
		
		mat_name = ( xml_mat.selectSingleNode "Id/SubtypeId" ).innertext
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
			material.bumpMap = Normal_Bump normal_map:( bitmapTexture bitmap:gtex_bm alphasource:2 ) flipgreen:true
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
		
		if doesFileExist ( get_path refTex ) do (
			
			ref = falloff type:2
			
			ref.map1 = Bitmaptexture bitmap:( get_bm refTex )
			ref.map1.coords.mappingtype = 1 --set the mapping type to environment
			ref.map1.coordinates.mapping = 1 --set the mapping to Screen
			ref.map1.coordinates.V_Tiling = 1.5
			ref.map1.coordinates.W_Angle = 90
			material.reflectionMap = ref
		)
		
		material
	),
	
	fn get_tr_pbr_material = (
		mat_name = ( xml_mat.selectSingleNode "Id/SubtypeId" ).innertext
		tex = xml_mat.selectSingleNode "Texture"
		glossTex = xml_mat.selectSingleNode "GlossTexture"
		glossTexAdd = xml_mat.selectSingleNode "GlossTextureAdd"

		col = xml_mat.selectSingleNode "Color"
		colAdd = xml_mat.selectSingleNode "ColorAdd"
		uvSize = xml_mat.selectSingleNode "UVSize"
		uvOffset = xml_mat.selectSingleNode "UVOffset"
		reflectivity = xml_mat.selectSingleNode "Reflectivity"
		
		material = PBRMetalRough Name:mat_name useGlossiness:1 normal_flip_green:True
		

		-- glass texture
		if tex != undefined and doesFileexist ( get_path tex.innertext ) then (
			cm_osl_map = OSLMap Name:( getFilenameFile tex.innertext ) OSLPath:OSLBitmap filename:( get_path tex.innertext ) autogamma: 1
			cm_osl_map.autogamma = 1
			c_interface = MultiOutputChannelTexmapToTexmap sourceMap:cm_osl_map outputChannelIndex:1 
			m_interface = MultiOutputChannelTexmapToTexmap sourceMap:cm_osl_map outputChannelIndex:5 
			material.base_color_map = c_interface
			material.opacity_map = m_interface
			
			if col != undefined then 
			(
				dCol = ( Vrage_XMLtoColor col ) * 255
				--print dcol
				--dCol.alpha = 255
				material.basecolor = dCol
				OpacityColorclamp = osl_ColorClamp()
				if colAdd != undefined then Opacityval = ( colAdd.item["W"].innertext as float ) else Opacityval = ( col.item["W"].innertext as float )
				OpacityColorclamp.Min = [Opacityval, Opacityval, Opacityval, Opacityval]
				t_interface = MultiOutputChannelTexmapToTexmap sourceMap:OpacityColorclamp outputChannelIndex:1 
				m_interface = MultiOutputChannelTexmapToTexmap sourceMap:cm_osl_map outputChannelIndex:5 
				OpacityColorclamp.Input_map = m_interface
				material.opacity_map = t_interface
			)

		) else (
			nt_osl_map = OSLMap Name:"NOTEXTURE" OSLPath:OSLBitmap filename:MyVrageNoTex autogamma: 1
			nt_osl_map.autogamma = 1
			nt_interface = MultiOutputChannelTexmapToTexmap sourceMap:nt_osl_map outputChannelIndex:1 
			material.base_color_map = nt_interface
		)

		if glossTex != undefined and doesFileexist ( get_path glossTex.innertext ) then 
		( 
			ng_osl_map = OSLMap Name:( getFilenameFile glossTex.innertext ) OSLPath:OSLBitmap filename:( get_path glossTex.innertext )
			n_interface = MultiOutputChannelTexmapToTexmap sourceMap:ng_osl_map outputChannelIndex:1
			g_interface = MultiOutputChannelTexmapToTexmap sourceMap:ng_osl_map outputChannelIndex:5

			ReflectionColorclamp = osl_ColorClamp()
			ReflectionColorclampVal = if reflectivity != undefined then (reflectivity.innertext) as float else 0.5
			ReflectionColorclamp.Min = [ReflectionColorclampVal,ReflectionColorclampVal,ReflectionColorclampVal,ReflectionColorclampVal]
			--material.norm_map = n_interface
			t_interface = MultiOutputChannelTexmapToTexmap sourceMap:ReflectionColorclamp outputChannelIndex:1 
			ReflectionColorclamp.Input_map = g_interface
			material.roughness_map = t_interface
			material.useGlossiness = true
			material.roughness = 1
		)

		material
	),
	
	
	fn get_pbr_material = (
		
		cm_map = xml_mat.selectSingleNode "Parameter[@Name='ColorMetalTexture']"
		ng_map = xml_mat.selectSingleNode "Parameter[@Name='NormalGlossTexture']"
		add_map = xml_mat.selectSingleNode "Parameter[@Name='AddMapsTexture']"
		op_map = xml_mat.selectSingleNode "Parameter[@Name='AlphamaskTexture']"
		
		material = PBRMetalRough Name:( xml_mat.attributes.itemOf["Name"].value ) useGlossiness:1 normal_flip_green:True

		if cm_map != undefined and doesFileexist ( get_path cm_map.innertext ) then (
			cm_osl_map = OSLMap Name:( getFilenameFile cm_map.innertext ) OSLPath:OSLBitmap filename:( get_path cm_map.innertext ) autogamma: 1
			cm_osl_map.autogamma = 1
			c_interface = MultiOutputChannelTexmapToTexmap sourceMap:cm_osl_map outputChannelIndex:1 
			m_interface = MultiOutputChannelTexmapToTexmap sourceMap:cm_osl_map outputChannelIndex:5 
			material.base_color_map = c_interface
			material.metalness_map = m_interface
			cm_osl_map.autogamma = 1
		) else (
			nt_osl_map = OSLMap Name:"NOTEXTURE" OSLPath:OSLBitmap filename:MyVrageNoTex autogamma: 1
			nt_osl_map.autogamma = 1
			nt_interface = MultiOutputChannelTexmapToTexmap sourceMap:nt_osl_map outputChannelIndex:1 
			material.base_color_map = nt_interface
		)

		if ng_map != undefined and doesFileexist ( get_path ng_map.innertext ) then (
			ng_osl_map = OSLMap Name:( getFilenameFile ng_map.innertext ) OSLPath:OSLBitmap filename:( get_path ng_map.innertext )
			n_interface = MultiOutputChannelTexmapToTexmap sourceMap:ng_osl_map outputChannelIndex:1
			g_interface = MultiOutputChannelTexmapToTexmap sourceMap:ng_osl_map outputChannelIndex:5
			material.norm_map = n_interface
			material.roughness_map = g_interface
		)

		if add_map != undefined and doesFileexist ( get_path add_map.innertext ) then (
			add_osl_map = OSLMap Name:( getFilenameFile add_map.innertext ) OSLPath:OSLBitmap filename:( get_path add_map.innertext )
			ao_interface = MultiOutputChannelTexmapToTexmap sourceMap:add_osl_map outputChannelIndex:2
			p_interface = MultiOutputChannelTexmapToTexmap sourceMap:add_osl_map outputChannelIndex:4
			Out_AddAlpha = MultiOutputChannelTexmapToTexmap sourceMap:add_osl_map outputChannelIndex:5
			material.ao_map = ao_interface
			

			
			if cm_map != undefined and doesFileexist ( get_path cm_map.innertext ) then 
			(
				--///Paintability - lloks good BUT: currently the mixing results in NOT whiter than the cm texture.
				--ColorNode
				PaintColorNode = VrageScene.getPaintNode()
				Out_PaintColorNode = MultiOutputChannelTexmapToTexmap sourceMap:PaintColorNode outputChannelIndex:1
				c_interface = MultiOutputChannelTexmapToTexmap sourceMap:cm_osl_map outputChannelIndex:1 

				--1. Disable Auto-gamma of Srgb
				if cm_osl_map !=undefined then cm_osl_map.autogamma = 0

				--2. Mix Add alpha with our Paintcolor
				OSL_Mix_ColorAdd =  osl_MixColor()
				OSL_Mix_ColorAdd.A = color 255 255 255 255
				OSL_Mix_ColorAdd.B_map = Out_PaintColorNode
				OSL_Mix_ColorAdd.Mix_map = Out_AddAlpha

				Out_Mix_ColorAdd =  MultiOutputChannelTexmapToTexmap sourceMap:OSL_Mix_ColorAdd outputChannelIndex:1

				--2.Multiply Painted add with CM
				OSL_Mul_PaintCM  = osl_ColorMul()
				OSL_Mul_PaintCM.A_map = Out_Mix_ColorAdd
				OSL_Mul_PaintCM.B_map = c_interface
				Out_Mul_PaintCM = MultiOutputChannelTexmapToTexmap sourceMap:OSL_Mul_PaintCM outputChannelIndex:1
				material.base_color_map = Out_Mul_PaintCM

				-- Emisive by using osl_ColorMulitply.
				-- Input B_amp is the normal cm map and input A_map is the emissive map (green channel of add)
				-- This does make the rightparts glow AND the color of the textures are still there. 
				em_interface = MultiOutputChannelTexmapToTexmap sourceMap:add_osl_map outputChannelIndex:3 
				cm_EM_interface = MultiOutputChannelTexmapToTexmap sourceMap:PaintColorAdd outputChannelIndex:1 
				EmissiveColorMul = osl_ColorMul()
				EmissiveColorMul.B_map = Out_Mul_PaintCM
				EmissiveColorMul.A_map = em_interface
				em_Basecolor_interface = MultiOutputChannelTexmapToTexmap sourceMap:EmissiveColorMul outputChannelIndex:1
				material.emit_color_map = em_Basecolor_interface
			)
			else 
			(
				em_interface = MultiOutputChannelTexmapToTexmap sourceMap:add_osl_map outputChannelIndex:3
				material.emit_color_map = em_interface
			)
		)

		if op_map != undefined and doesFileexist ( get_path op_map.innertext ) then (
			mask_osl_map = OSLMap Name:( getFilenameFile op_map.innertext ) OSLPath:OSLBitmap filename:( get_path op_map.innertext )
			mask_interface = MultiOutputChannelTexmapToTexmap sourceMap:mask_osl_map outputChannelIndex:1
			material.opacity_map = mask_interface
		)
		--if cm_osl_map !=undefined then cm_osl_map.autogamma = 1
		
		--material.base_color_map.sourcemap.autogamma = 1
		material
	),

	fn get_material = (
		
		transp = ( toLower xml_mat.Name ) == "transparentmaterial"

		/*

		*/
		
		out = case Of (
			( MyVrageCfg.UsePbrMats and transp ):get_tr_pbr_material()
			( MyVrageCfg.UsePbrMats ): get_pbr_material()
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
	mat_list = #( ),
	mat_names = #( ),
	errors = #( ),
	warnings = #( ),
	tex_dir = undefined,
	
	fn get_tex_dir = (
		if MyVRageCfg.UseGameTextures then (
			tex_dir = MyVRageCfg.PathGame + @"\Content\"
		)
		else (
			split = filterString MyVRageCfg.PathTextures "\\"
			
			if toLower ( split[split.count] ) == "textures" then (
				tex_dir = getFilenamePath MyVRageCfg.PathTextures
			)
			else (
				tex_dir = MyVRageCfg.PathTextures
			)
			
			tex_dir = MyVRageCfg.PathTextures + "\\"
		)
		
	),
	
	--Fetch Material by material name
	fn get_mat_by_name name = (
		
		xpath = "//TransparentMaterial[Id/SubtypeId[contains(text(),'" + name + "')]]"
		xml_mat = xmlDoc.selectSingleNode xpath
		
		If xml_mat == undefined do (
			xpath = substituteString "//Material[@Name='%']" "%" ( name as string )
			xml_mat = xmlDoc.selectSingleNode xpath
		)
		
		if xml_mat != undefined then (
			mat = ( VrageMaterial xml_mat:xml_mat )
		)
		else (
			mat = undefined
		)
		
		mat
	),
	
	fn get_mat_list = (
		
		xml_mats = xmlDoc.selectNodes "//Material"
		xml_TransMats = xmlDoc.selectNodes "//TransparentMaterial/Id/SubtypeId"
		
		reg_mat_names = for i = 0 to xml_mats.count-1 collect xml_mats.itemOf[i].attributes.itemOf["Name"].value
		transp_mat_names = for i = 0 to xml_TransMats.count-1 collect xml_TransMats.itemOf[i].innertext
		
		for t in transp_mat_names where findItem reg_mat_names t == 0 do append reg_mat_names t

		mat_names = deepcopy ( makeUniqueArray reg_mat_names )
		sort mat_names
		mat_list = mat_names
		
		errors = #( )
		warnings = #( )
	),
	
	fn main = (
		
		if MyVRageCfg != undefined then (
			dir = ( trimright MyVRageCfg.PathModSDK "\\" ) + "\\OriginalContent\\Materials\\"
			if doesDirectoryExist dir then (
				files = getFiles ( dir + "*.xml" )
				
				transp_mats = MyVrageCfg.PathGame + @"\Content\Data\TransparentMaterials.sbc"
				
				if doesFileExist transp_mats do (
					append files transp_mats
				)
				
				xmlDoc = dotNetObject "system.xml.xmlDocument"
				header = xmlDoc.CreateXmlDeclaration "1.0" "" ""
				xmlDoc.AppendChild header
				matFiles = xmlDoc.createElement "MaterialFiles"
				xmlDoc.AppendChild matFiles
				all_mats = (trimright MyVRageCfg.PathModSDK "\\") + "\\OriginalContent\\AllMaterials.xml"
				
				if doesFileExist all_mats do (
					insertItem all_mats files 1
				)
				
				for f = 1 to files.count do (
					tempDoc = dotNetObject "system.xml.xmlDocument"
					tempDoc.load files[f]
					fname = filenameFromPath files[f]
					
					fileElement = xmlDoc.createElement "MaterialFile"
					fileElement.SetAttribute "Name" fname
					
					theNode = xmlDoc.ImportNode tempDoc.documentElement True
					
					fileElement.appendChild theNode
					matFiles.appendChild fileElement
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
	bsize = 180,
	bpadding = 0,
	bsize_image = bsize - bpadding * 2,
	bmargin = 8,
	imageList = undefined,
	mButton = dotNetObject "System.Windows.Forms.Button",

	fn click_event = (
		
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
					+ "A : Overwrite the current material ID with the selected material?\n" \
					+ "B : Append the selected material as a new Material ID?\n" \
					+ "C : Abort and change nothing?"
					
					label lb_text txt height:75
					
					button b_overwrite "Overwrite" height:24 width:80 across:3 align:#left
					button b_append "Append" height:24 width:80 align:#center
					button b_abort "Abort" height:24 width:80 align:#right
					
					fn init val:undefined = (
						try destroyDialog queryDialog catch()
						result = val
						createDialog queryDialog modal:true
						setFocus queryDialog
						result
					)

					fn switchAndClose val = (
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
					( Edit_Poly ): (
						if subobjectlevel >= 4 and ( ( facesel = target.GetSelection #Face ) as array ).count != 0 then (
							temp_mat = VRage_JoinMaterials o.Material new_mat
							o.Material = temp_mat[1]
							target.SetOperation #SetMaterial 
							target.materialIDToSet = temp_mat[2] - 1
							target.Commit()
						)
						else (
							o.material = new_mat
							num = target.getnumfaces()
							target.setSelection #face #{ 1..num }
							target.SetOperation #SetMaterial 
							target.materialIDToSet = ( 0 )
							target.Commit()
							target.setSelection #face #{ }
						)
					)
					( Editable_poly ):(
						if subobjectlevel >= 4 and ( ( facesel = polyop.getFaceSelection target ) as array ).count != 0 then (
							o.material = new_mat
							--o.material.names = for m in o.material.materiallist collect m.name
						)
						else (
							o.material = new_mat
							facesel = #{ 1..( polyop.getNumFaces o ) }
							polyop.setFaceMatID o facesel 1
						)
					)
					( Chamfer ):(
						target.SetMaterial = on
						case mode of (
							
							#overwrite: (
								if classOf o.material == multimaterial then (
									o.material.materiallist[target.materialID] = new_mat
									o.material.names[target.materialID] = new_mat.name
								)
								else (
									mat_list = #( o.material )
									mat_names = #( o.material.name )
									
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

	fn hover_event sender eb = (
		Color = dotNetClass "System.Drawing.Color"
		mButton.BackColor = Color.gray 
	),

	fn hoverEnd_event sender eb = (
		Color = dotNetClass "System.Drawing.Color"
		mButton.BackColor = Color.transparent
	),
	
	fn getButton = (
		
		imageList = dotNetObject "System.Windows.Forms.ImageList"
		imageList.ImageSize = dotNetObject "System.Drawing.Size" bsize_image bsize_image
		imageList.ColorDepth = ( dotNetClass "System.Windows.Forms.ColorDepth" ).Depth32bit
		
		thumb_path = MyVrageCfg.VrageConfigDir + "\\MaterialThumbnails\\" + name + ".png"
		img_path = MyVrageCfg.DefaultThumbnail

		if doesFileExist thumb_path do (
			img_path = thumb_path
		)

		local img = ( dotnetclass "System.Drawing.Image" ).fromfile img_path 
		local retBmp = dotnetObject "System.Drawing.Bitmap" img.Width img.height
		local g = ( dotnetclass "system.drawing.graphics" ).fromImage retBmp
		g.drawimage img 0 0 
		img.Dispose();

		imageList.images.add retBmp
		
		bFontStyle = ( dotNetClass "System.Drawing.FontStyle" ).bold
		bfont = dotNetObject "System.Drawing.Font" "Microsoft Sans Serif" 7 bFontStyle

		
		mButton.text = name
		mButton.size = dotNetObject "System.Drawing.Size" bsize bsize
		
		mButton.ForeColor = getDnColor #text
		
		mButton.flatStyle = mButton.flatStyle.Flat
		mButton.FlatAppearance.BorderSize = 0
		
		mButton.BackColor = getDnColor #background
		mButton.ImageList = imageList
		mButton.ImageIndex = 0

		mButton.ImageAlign = ( dotNetClass "System.Drawing.ContentAlignment" ).MiddleCenter
		mButton.TextAlign = ( dotNetClass "System.Drawing.ContentAlignment" ).topLeft
		mButton.padding = dotNetObject "System.Windows.Forms.Padding" bpadding

		mButton.Font = bfont
		mButton.Margin = dotNetObject "System.Windows.Forms.Padding" bmargin
		
		dotNet.addEventHandler mButton "click" click_event
		--	dotNet.addEventHandler mButton "MouseHover" hover_event
		--dotNet.addEventHandler mButton "MouseLeave" hoverEnd_event
		
		dotnet.setLifetimeControl mButton #dotnet
		
		mButton
	)
)

struct Vrage_MaterialBrowser (
	
	padsize = 10,
	marginsize = 10,
	
	Margin = dotNetObject "System.Windows.Forms.Padding" padsize,
	Padding = dotNetObject "System.Windows.Forms.Padding" marginsize,
	DockStyle = dotNetClass "System.Windows.Forms.DockStyle",
	BorderStyle = dotNetClass "System.Windows.Forms.BorderStyle",
	Color = dotNetClass "System.Drawing.Color",
	AutoSizeMode = dotNetClass "System.Windows.Forms.AutoSizeMode",
	AnchorStyles = dotNetClass "System.Windows.Forms.AnchorStyles",
	dnKeys = dotnetclass "System.Windows.Forms.Keys",
	SortOrder = dotnetclass "System.Windows.Forms.SortOrder",
	View = dotnetclass "System.Windows.Forms.View",
	HorizontalAlignment = dotNetclass "System.Windows.Forms.HorizontalAlignment",
	
	dnPoint = dotNetClass "System.Drawing.Point",
	dnSize = dotNetClass "System.Drawing.Size",
	dnRectangle = dotNetClass "System.Drawing.Rectangle",
	

	form_size = [MyVRageCfg.MatBrowserSizeX, MyVRageCfg.MatBrowserSizeY],
	Mat_Layout = dotNetObject "System.Windows.Forms.FlowLayoutPanel",
	Mat_Group = dotNetObject "System.Windows.Forms.Groupbox",
	Filter_Group = dotNetObject "System.Windows.Forms.Groupbox",
	hForm = dotNetObject "MaxCustomControls.MaxForm",
	filter_box = dotNetObject "System.Windows.Forms.Textbox",
	filter_button = dotNetObject "System.Windows.Forms.button",

	Source_Group =  dotNetObject "System.Windows.Forms.Groupbox",
	Source_ListView = dotNetObject "System.Windows.Forms.ListView",
	Info_Group =  dotNetObject "System.Windows.Forms.Groupbox",
	
	prefilter_Layout = dotNetObject "System.Windows.Forms.FlowLayoutPanel",
	
	prefilter_button_Painted = dotNetObject "System.Windows.Forms.button",
	prefilter_button_Metal = dotNetObject "System.Windows.Forms.button",
	prefilter_button_Rubber = dotNetObject "System.Windows.Forms.button",
	prefilter_button_Emissive = dotNetObject "System.Windows.Forms.button",
	prefilter_button_Glass = dotNetObject "System.Windows.Forms.button",
	prefilter_button_Atlas = dotNetObject "System.Windows.Forms.button",
	prefilter_button_Screen = dotNetObject "System.Windows.Forms.button",
	last_txt = "",
	
	fn populateSource =(

		Source_Listview.clear()
		dir = (trimright MyVRageCfg.PathModSDK "\\") + "\\OriginalContent\\Materials\\"
		files = getFiles (dir + "*.xml")

		for f in files do (
			fname = getFilenameFile f + ".xml"
			item = dotNetObject "System.Windows.Forms.ListViewItem" fname 0
			item.checked = True
			--item.SubItems.Add("1");
			--item.SubItems.Add("2");
			--item.SubItems.Add("3");
			Source_ListView.Items.Add item
		)
	),

	fn populateMats txt:"" cleanMats:true exactWord:false = (
		
		if cleanMats == true do Mat_Layout.controls.clear()
		if exactWord == true then ThePattern = txt else ThePattern = ( "*" + txt + "*" )

		for n in MyVrageMatLib.mat_names where matchpattern n pattern:ThePattern do ( 
			Mat_Layout.controls.add ( ( Vrage_MaterialButton name:n ).getButton())
		)
		
	),
	
	fn filter_box_ku sender eb = (
		if eb.KeyCode == eb.KeyCode.Enter and sender.text != last_txt do (
			eb.Handled = eb.SuppressKeyPress = true
			last_txt = sender.text
			populateMats txt:sender.text
			
		)
	),
	
	fn filter_box_click sender eb = (
		new_txt = filter_box.text
		if new_txt != last_txt do (
			last_txt = new_txt
			populateMats txt:new_txt
		)
	),

	fn filter_painted_click sender eb = (
		new_txt = "Painted"
		filter_box.text = "Painted"
		if new_txt != last_txt do (
			last_txt = new_txt
			populateMats txt:new_txt
			populateMats txt:"Conveyor" cleanMats:false exactWord:true
			populateMats txt:"Conveyor_Yellow" cleanMats:false exactWord:true
			populateMats txt:"Doodads" cleanMats:false
		)
	),

	fn filter_metal_click sender eb = (
		new_txt = "Metal"
		filter_box.text = "Metal"
		if new_txt != last_txt do (
			last_txt = new_txt
			populateMats txt:new_txt
			populateMats txt:"Exhaustpipe" cleanMats:false
			populateMats txt:"BraidedSteel" cleanMats:false exactWord:true
			populateMats txt:"Grating" cleanMats:false
			populateMats txt:"Chrome" cleanMats:false
			populateMats txt:"Construction" cleanMats:false
			populateMats txt:"Pipe" cleanMats:false
			

		)
	),

	fn filter_Rubber_click sender eb = (
		new_txt = "Non Metal"
		filter_box.text = "Rubber"
		if new_txt != last_txt do (
			last_txt = new_txt
			populateMats txt:"Rubber"
			populateMats txt:"Cloth" cleanMats:false
			populateMats txt:"Solarpanel" cleanMats:false
			populateMats txt:"Seat" cleanMats:false
			populateMats txt:"CameraLens" cleanMats:false
			--populateMats txt:"BlackMattePlastic" cleanMats:false
			populateMats txt:"Terminal" cleanMats:false
			populateMats txt:"Plastic" cleanMats:false
			populateMats txt:"ProgrammingBlock" cleanMats:false exactWord:true
			populateMats txt:"HydrogenThrusterNozzle" cleanMats:false exactWord:true
		)
	),

	fn filter_Emissive_click sender eb = (
		new_txt = "Emissive"
		filter_box.text = "Emissive"
		if new_txt != last_txt do (
			last_txt = new_txt
			populateMats txt:new_txt
		)
	),

	fn filter_Glass_click sender eb = (
		new_txt = "Glass"
		filter_box.text = "Glass"
		if new_txt != last_txt do (
			last_txt = new_txt
			populateMats txt:new_txt cleanMats:true
			populateMats txt:"window" cleanMats:false
		)
	),

	fn filter_Atlas_click sender eb = (
		new_txt = "Atlas"
		filter_box.text = ""
		if new_txt != last_txt do (
			last_txt = new_txt
			populateMats txt:new_txt cleanMats:true
			populateMats txt:"Decals" cleanMats:false
			populateMats txt:"Paneling" cleanMats:false
		)
	),

	fn filter_Screen_click sender eb = (
		new_txt = "Screen"
		filter_box.text = ""
		if new_txt != last_txt do (
			last_txt = new_txt
			populateMats txt:new_txt cleanMats:true
			--populateMats txt:"Decals" cleanMats:false
			--populateMats txt:"Paneling" cleanMats:false
		)
	),


	fn ResizeForm = 
	(
		MyVRageCfg.MatBrowserSizeX = hForm.Width 
		MyVRageCfg.MatBrowserSizeY = hForm.Height
		MyVRageCfg.save()
	),


	fn closeForm = (
		--Mat_Layout.dispose()
		--hForm.dispose()
		/*
		for i=1 to Mat_Layout.controls.count do (
			Mat_Layout.controls.item[i-1].ImageList.dispose()
		)
		*/
		( dotnetclass "system.gc" ).collect()
		gc()
	),
	
	fn getForm genThumbs:false = (
		
		if genThumbs do (
			Vrage_getMaterialThumbnails MyVrageMatLib.mat_names
		)
		
		/*Source Group*/
		Source_Group.location = dotNetObject "System.Drawing.Point" marginsize marginsize
		--Source_Group.size = dotNetObject "System.Drawing.Size" (form_size.x * .25 - marginsize * 2) (form_size.y - marginsize * 2)
		Source_Group.size = dotNetObject "System.Drawing.Size" (200) (form_size.y - marginsize * 2)
		Source_Group.Margin = Margin
		--Source_Group.padding = Padding
		Source_Group.Anchor = dotNet.combineEnums AnchorStyles.Top AnchorStyles.Left
		Source_Group.text = "Filter:"
		Source_Group.Dock = DockStyle.Left
		Source_Group.forecolor = Color.white
		Source_Group.flatStyle = Source_Group.flatStyle.System
		Mat_Group.Anchor = dotNet.combineEnums AnchorStyles.Top AnchorStyles.Left
		
		/*Filter_Group*/
		Filter_Group.location = dotNetObject "System.Drawing.Point" (Source_Group.location.x + Source_Group.size.width + marginsize * 6) Source_Group.location.y
		Filter_Group.size = dotNetObject "System.Drawing.Size" (form_size.x - Source_Group.size.width - marginsize * 4) 55
		Filter_Group.Margin = Margin
		Filter_Group.padding = Padding
		Filter_Group.Anchor = dotNet.combineEnums AnchorStyles.Top AnchorStyles.Left
		Filter_Group.flatStyle = Filter_Group.flatStyle.System
		Filter_Group.text = "Search:"
		Filter_Group.Dock = DockStyle.Top
		Filter_Group.forecolor = Color.white
		Mat_Group.Anchor = dotNet.combineEnums AnchorStyles.Top AnchorStyles.Left
		
		/*Mat_Group*/
		Mat_Group.location = dotNetObject "System.Drawing.Point" Filter_Group.location.x (Source_Group.location.y + Filter_Group.size.height + marginsize * 2)
		Mat_Group.size = dotNetObject "System.Drawing.Size" Filter_Group.size.width (form_size.y - marginsize * 4 - Filter_Group.size.height)
		Mat_Group.Margin = Margin
		--Mat_Group.padding = Padding
		Mat_Group.text = "Materials:"
		Mat_Group.Anchor = dotNet.combineEnums AnchorStyles.Top AnchorStyles.Left --AnchorStyles.Right AnchorStyles.Bottom
		Mat_Group.Dock = DockStyle.Fill
		Mat_Group.forecolor = Color.white
		Mat_Group.flatStyle = Mat_Group.flatStyle.System
		
		/*Mat_Layout*/
		
		Mat_Layout.location = dotNetObject "System.Drawing.Point" 0 (marginsize * 2)
		Mat_Layout.size = dotNetObject "System.Drawing.Size" (Mat_Group.size.width - marginsize * 2) (Mat_Group.size.height - marginsize * 2)
		
		Mat_Layout.AutoScroll = True
		Mat_Layout.text = "Materials:"
		Mat_Layout.Dock = DockStyle.Fill
		Mat_Layout.Margin = Margin
		Mat_Layout.padding = Padding
		Mat_Layout.Anchor = dotNet.combineEnums AnchorStyles.Top AnchorStyles.Left
		
		Mat_Group.controls.add Mat_Layout
		
		/*filter box*/
		filter_box.size = dotNetObject "System.Drawing.Size" ( Filter_Group.size.width * 0.8 ) 60
		filter_box.location = dotNetObject "System.Drawing.Point" (marginsize) (marginsize * 2)
		filter_box.Anchor = dotNet.combineEnums AnchorStyles.Left AnchorStyles.Top AnchorStyles.right
		
		filter_box.BackColor = getDnColor #background
		filter_box.ForeColor = getDnColor #Text
		dotNet.addEventHandler filter_box "keyUp" filter_box_ku
		filter_box.BorderStyle = filter_box.BorderStyle.FixedSingle
		dotNet.addEventHandler filter_box "KeyDown" filter_box_ku
		
		dotnet.setLifetimeControl filter_box #dotnet
		
		/*filter button*/
		filter_button.size = dotNetObject "System.Drawing.Size" ( Filter_Group.size.width - filter_box.size.width - marginsize * 3) 30
		filter_button.location = dotNetObject "System.Drawing.Point" ( filter_box.location.x + filter_box.size.width + marginsize) (filter_box.location.y - 5)
		filter_button.Dock = DockStyle.right
		filter_button.text = "Search"
		filter_button.Anchor = dotNet.combineEnums AnchorStyles.Top AnchorStyles.Right
		filter_button.flatStyle = filter_button.flatStyle.System
		filter_button.Margin = Margin
		filter_button.padding = Padding
		dotNet.addEventHandler filter_button "click" filter_box_click
		dotnet.setLifetimeControl filter_button #dotnet
		
		Filter_Group.controls.add filter_button
		Filter_Group.controls.add filter_box

		/*Source File List*/

		
		Source_ListView.View = View.List -- Set the view to show details.
		Source_ListView.LabelEdit = False -- Allow the user to edit item text.
		Source_ListView.AllowColumnReorder = False -- Allow the user to rearrange columns.
		Source_ListView.CheckBoxes = true -- Display check boxes.
		Source_ListView.FullRowSelect = true -- Select the item and subitems when selection is made.
		Source_ListView.GridLines = true -- Display grid lines.
		Source_ListView.Sorting = SortOrder.Ascending -- Sort the items in the list in ascending order.
		
		--Source_ListView.location = dotNetObject "System.Drawing.Point" 10 20
		Source_ListView.size = dotNetObject "System.Drawing.Size" (Source_Group.size.width - marginsize * 3) (Source_Group.size.height / 2 - marginsize * 3)
		--Source_ListView.bounds = (dotNetClass "System.Shapes.Rectangle") (dotNetObject "System.Drawing.Point" (Source_Group.location.x + 10) (Source_Group.location.y + 20)) (dotNetObject "System.Drawing.Size" (Source_Group.size.width - 30) (Source_Group.size.height * 2))
		--Source_ListView.Dock = DockStyle.Top
		
		Source_ListView.padding = Padding
		--Source_ListView.margin = Margin
		Source_ListView.Scrollable = True
		Source_ListView.Anchor = dotNet.combineEnums AnchorStyles.Top AnchorStyles.Left --AnchorStyles.Bottom --AnchorStyles.Right 
		
		Source_ListView.backcolor = getDnColor #background
		Source_ListView.forecolor = getDnColor #text
		
		Source_ListView.Columns.Add "File" 4 HorizontalAlignment.Left
		--Source_ListView.Columns.Add "Column 2" -2 HorizontalAlignment.Left
		--Source_ListView.Columns.Add "Column 3" -2 HorizontalAlignment.Left
		--Source_ListView.Columns.Add "Column 4" -2 HorizontalAlignment.Center
		
		/*prefilter_Layout*/
		prefilter_Layout.location = dotNetObject "System.Drawing.Point" ( Source_Group.location.x ) ( Source_Group.location.y + marginsize)
		prefilter_Layout.size = dotNetObject "System.Drawing.Size" (Source_Group.size.width - marginsize * 2) (Source_Group.size.height - marginsize * 4)
		prefilter_Layout.AutoScroll = True
		
		--prefilter_Layout.Margin = Margin
		--prefilter_Layout.padding = Padding
		
		prefilter_Layout.text = "Filters:"
		prefilter_Layout.Anchor = dotNet.combineEnums AnchorStyles.Bottom AnchorStyles.Left AnchorStyles.Top
		--prefilter_Layout.Dock = DockStyle.Bottom

		prefilter_width = Source_ListView.size.width/2 - marginsize /2

		prefilter_button_Painted.size = dotNetObject "System.Drawing.Size" prefilter_width 30

		prefilter_button_Painted.text = "Painted"
		prefilter_button_Painted.flatStyle = prefilter_button_Painted.flatStyle.System
		dotNet.addEventHandler prefilter_button_Painted "click" filter_painted_click
		dotnet.setLifetimeControl prefilter_button_Painted #dotnet

		prefilter_button_Metal.size = dotNetObject "System.Drawing.Size" prefilter_width 30

		prefilter_button_Metal.text = "Metal"
		prefilter_button_Metal.flatStyle = prefilter_button_Metal.flatStyle.System
		dotNet.addEventHandler prefilter_button_Metal "click" filter_metal_click
		dotnet.setLifetimeControl prefilter_button_Metal #dotnet

		prefilter_button_Rubber.size = dotNetObject "System.Drawing.Size" prefilter_width 30

		prefilter_button_Rubber.text = "Non Metal"
		prefilter_button_Rubber.flatStyle = prefilter_button_Rubber.flatStyle.System
		dotNet.addEventHandler prefilter_button_Rubber "click" filter_Rubber_click
		dotnet.setLifetimeControl prefilter_button_Rubber #dotnet

		prefilter_button_Emissive.size = dotNetObject "System.Drawing.Size" prefilter_width 30

		prefilter_button_Emissive.text = "Emissive"
		prefilter_button_Emissive.flatStyle = prefilter_button_Emissive.flatStyle.System
		dotNet.addEventHandler prefilter_button_Emissive "click" filter_Emissive_click
		dotnet.setLifetimeControl prefilter_button_Emissive #dotnet

		prefilter_button_Glass.size = dotNetObject "System.Drawing.Size" prefilter_width 30

		prefilter_button_Glass.text = "Glass"
		prefilter_button_Glass.flatStyle = prefilter_button_Glass.flatStyle.System
		dotNet.addEventHandler prefilter_button_Glass "click" filter_Glass_click
		dotnet.setLifetimeControl prefilter_button_Glass #dotnet

		prefilter_button_Atlas.size = dotNetObject "System.Drawing.Size" prefilter_width 30

		prefilter_button_Atlas.text = "Atlas"
		prefilter_button_Atlas.flatStyle = prefilter_button_Atlas.flatStyle.System
		dotNet.addEventHandler prefilter_button_Atlas "click" filter_Atlas_click
		dotnet.setLifetimeControl prefilter_button_Atlas #dotnet

		prefilter_button_Screen.size = dotNetObject "System.Drawing.Size" prefilter_width 30

		prefilter_button_Screen.text = "Screen"
		prefilter_button_Screen.flatStyle = prefilter_button_Screen.flatStyle.System
		dotNet.addEventHandler prefilter_button_Screen "click" filter_Screen_click
		dotnet.setLifetimeControl prefilter_button_Screen #dotnet

		

		prefilter_Layout.controls.add source_ListView
		Source_Group.controls.add prefilter_Layout
		
		prefilter_Layout.controls.add prefilter_button_Painted
		prefilter_Layout.controls.add prefilter_button_Metal
		prefilter_Layout.controls.add prefilter_button_Rubber
		prefilter_Layout.controls.add prefilter_button_Emissive
		prefilter_Layout.controls.add prefilter_button_Glass
		prefilter_Layout.controls.add prefilter_button_Atlas
		prefilter_Layout.controls.add prefilter_button_Screen
		
		
		/*
		Source_Group.controls.add prefilter_button_Painted
		Source_Group.controls.add prefilter_button_Metal
		Source_Group.controls.add prefilter_button_Rubber
		Source_Group.controls.add prefilter_button_Emissive
		Source_Group.controls.add prefilter_button_Glass
		Source_Group.controls.add prefilter_button_Atlas
		Source_Group.controls.add prefilter_button_Screen
		*/
		
		populateSource()
		
		hForm.text = "Vrage Material Browser"
		hForm.padding = Padding
		hForm.margin = Margin
		hForm.FormBorderStyle = hForm.FormBorderStyle.SizableToolWindow
		--Mat_Group.controls.add 
		
		hForm.controls.add Mat_Group
		hForm.controls.add Filter_Group
		hForm.controls.add Source_Group

		--populateMats()

		populateMats txt:"Painted"
		filter_box.text = "Painted"
		--hForm.controls.add Form_Layout
		--hForm.topmost = true
		
		nw = DotNetObject "System.Windows.Forms.NativeWindow"
		nw.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND()))
		
		hForm.backcolor = getDnColor #background
		
		dotNet.addEventHandler hForm "Closed" closeForm
		dotNet.addEventHandler hForm "SizeChanged" ResizeForm
		hForm.size = dotNetObject "System.Drawing.Size" form_size.x form_size.y
		--print hForm.size
		hForm.show ( nw )
		nw.releaseHandle()
		--hForm.topmost = true
		hForm
	)


)


struct Vrage_MaterialThumbRenderer (
	
	resolution = [150, 150],
	
	sceneObjects = #(),
	sceneLights = #(),
	
	thumbPrimitive = undefined,
	thumbCamera = undefined,
	thumbSceneObjects = #(),
	
	fn setupLights =(
		
		HDRI_Map = OSLMap OSLPath:(getDir #maxroot + "OSL\\HDRIEnviron.osl")
		HDRI_Map.HDRI = getDir #userscripts + @"VRageToolbox\Vrage_resources\myearth.hdr"
		
		tempLight = Omnilight multiplier:1.0 pos:[20, -40, 20]
		tempLight2 = Omnilight multiplier:1.0 pos:[-15, 0, -20]
		tempSky = Skylight sky_color_map_on:True sky_color_map:HDRI_Map
		
		append thumbSceneObjects tempLight
		append thumbSceneObjects tempLight2
		append thumbSceneObjects tempSky
	),
	
	fn setupPrimitive =(
		tsSegs = 12
		
		thumbPrimitive = box pos:[0,0,-12] width:24 length:24 height:24 mapcoords:on widthsegs:tsSegs lengthsegs:tsSegs heightsegs:tsSegs wirecolor:gray mpassEnabled:off mpassRenderPerPass:off 
		addModifier thumbPrimitive (Relax Relax_Value: 1 Keep_Boundary_Pts_Fixed:0) 
		addModifier thumbPrimitive (Spherify percent:100)
		addModifier thumbPrimitive (SmoothModifier smoothingBits:1)
		
		append thumbSceneObjects thumbPrimitive
	),
	
	fn setupCamera =(
		thumbCamera = Freecamera fov:45 targetDistance:50 nearclip:1 farclip:1000 nearrange:0 farrange:1000 mpassEnabled:off mpassRenderPerPass:off rotation:(quat 0.707107 0 0 0.707107) pos:[0, -40, 0]
		append thumbSceneObjects thumbCamera
	),
	
	fn SceneSetup =(
		
		sceneObjects = for o in objects where not o.isdeleted and not o.ishidden collect o
		sceneLights = for l in lights where o != undefined and not o.isdeleted collect l
		
		setupPrimitive()
		setupLights()
		setupCamera()
		
		hide sceneObjects
		
		for l in sceneLights do (
			append l.excludeList thumbPrimitive
		)
		
	),
	
	fn SceneReset =(
		unhide sceneObjects
		delete thumbSceneObjects
	),
	
	fn GetMaterialSample Filename = (
		result = render camera:thumbCamera outputsize:resolution vfb:false outputfile:Filename
		result
	),

	fn GenerateMatThumbnails names = (
		
		with redraw off
		with undo off
		(
			
			thumb_dir = MyVrageCfg.VrageConfigDir + "\\MaterialThumbnails\\"
			try ( makeDir thumb_dir ) catch()
			
			start = timestamp()
			
			if classOf names == String do (
				names = #( names )
			)
			progressStart "Generating Thumbnails"
			MyVRageLog.silent = True
			prog = 0.0
			limit = names.count as float

			cur_rdr = renderers.current
			new_rdr = Quicksilver_Hardware_Renderer()
			renderers.current = new_rdr

			new_rdr.AmbientOcclusionEnabled = true
			new_rdr.AmbientOcclusionIntensity = 2.0
			new_rdr.AmbientOcclusionRadius = 10.0
			new_rdr.IndirectIlluminationEnabled = true
			new_rdr.IndirectIlluminationMultiplier = 2.0
			-- Do Bloom if version is above 2021. 
			-- Bloom has beend implemented 2022
			if ( ( maxversion())[8] ) > 2021 then 
			(
				new_rdr.BloomEnabled = true	
			)

			pngio.setAlpha true
			
			SceneSetup()
			
			for n in names do (
				if getProgressCancel() do exit
				local fname = thumb_dir + n + ".png"
				thumbPrimitive.material = Vrage_getmatbyname n
				MaterialSample = ( GetMaterialSample fname )
				prog += 1.0
				progressUpdate ( prog / limit * 100.0 )
			)
			
			SceneReset()

			renderers.current = cur_rdr
			MyVRageLog.silent = false
			progressEnd()	
		)
	)

	
)

fn VRage_getMatByName name = (
	
	--Get Array of Materials in Scene
	sceneMats = for m in ( getClassInstances Standardmaterial ) where isProperty m #is_se_material and m.timeGen >= MyVRageMatLib.timeGen collect m
	
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

fn VRage_cleanMats obj_list = (
	
	if doesFileExist MyVrageCfg.PathToolsFolder then (
		obj_list = obj_list as array
		
		if not ( doesFileExist ( MyVrageCfg.PathToolsFolder + "\\Textures" ) ) and not MyVrageCfg.UseGameTextures do (
			return VrageLogSys.Error "Texture folder does not exist!"
		)
		
		MyVRageMatLib.get_tex_dir()
		
		undo "Vrage Clean Materials" on (
			with redraw off (
				for o in obj_list where not isDeleted o do (
					
					if o != undefined do Vrage_condenseMatIds o

					if classOf o.material == Multimaterial then (
						
						for m = 1 to o.material.materialList.count do (
							old_material = o.material.materialList[m]
							
							if old_material != undefined and ( custAttributes.get old_material VrageMaterial_CA ) == undefined do (
								
								new_material = VRage_getMatByName old_material.name
								
								if new_material != undefined then (
									
									o.material.materialList[m] = new_material
									
								)
								else (
									if not MatchPattern old_material.name pattern:"*_Blocks Slot #*" do (
										error_stream = "" as StringStream
										--format "No Material named \"%\" for object \"%\" in XML files" old_material.name o to:error_stream
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
								--format "No Material named \"%\" for object \"%\" in XML files" o.material.name o to:error_stream
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
		MyVrageLog.error "Tools Folder does not exist/is not set!\nOpen settings and correct your configuration!"
	)
)

fn VRage_JoinMaterials obj_mat new_mat = (
	
	if obj_mat != undefined then ( 
		case classOf obj_mat of (
			( multimaterial ): ( 
				temp_mat = obj_mat
				Matnames = for m in temp_mat.materiallist collect m.name
				MatIndex = findItem Matnames ( new_mat.name as string )	
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
				temp_mat = multimaterial numsubs:2 materiallist:#( obj_mat, new_mat ) names:#( obj_mat.name, new_mat.name )
				id = 2
			)
		)
	)
	else (
		temp_mat = multimaterial numsubs:1 materiallist:#( new_mat ) names:#( new_mat.name )
		id = 1
	)
	
	#( temp_mat, id )
)

fn VRage_write_material_xml obj_list = (
	
	material_names = #( )
	
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

	xmlDoc.save ( ( getDir #temp ) + "\\test.xml" )

	edit ( ( getDir #temp ) + "\\test.xml" )
	
)





fn VRage_Generate3dMaxMatLibrary Names Filepath=
(--can generated a Materialibrary. We won't use that.
	MyMaterials = #();
	MyLibrary = materialLibrary   (Vrage_getmatbyname Names[1]);

	for n in Names do 
	(
		append MyLibrary (Vrage_getmatbyname n)

	)
	saveTempMaterialLibrary  MyLibrary Filepath
	thing  = loadMaterialLibrary  Filepath
)

if MyVRageMatLib == undefined do (
	MyVRageMatLib = VRageMaterialLibrary()
	MyVRageMatLib.main()
)

/* Example Code to open Browser
MyVrageMatBrowser = (Vrage_MaterialBrowser()).getForm()
*/