global MyVrageFontLib


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

struct VrageFontCharacter (
	
	Name="",
	min = [0,0,0],
	mx =  [1,1,0],
	offset = [0,0,0]

)

struct VrageFont (
	
	name = "",
	chars = #(),
	padding = 0,
	space = 0,
	caseType = "",
	avgHeight = 1,
	material_name = "",
	atlasSize = [1024, 1024],
	xmlDoc,
	file,
	
	fn dump_xml=(
		
		xmlDoc = dotNetObject "system.xml.xmlDocument"

		/* create header */
		header = xmlDoc.CreateXmlDeclaration "1.0" "" ""
		xmlDoc.AppendChild header

		root = xmlDoc.createElement "Font"
		root.SetAttribute "Name" name
		root.SetAttribute "Kerning" (kerning as string)
		root.SetAttribute "Padding" (padding as string)
		root.SetAttribute "Material" material_name
		root.SetAttribute "Space" (space as string)
		root.SetAttribute "AtlasSize" (atlasSize.x as string + " " + atlasSize.y as string)
		if caseType != "" do root.SetAttribute "CaseType" caseType
		
		xmlDoc.appendChild root

		for c in chars do (
			newChar = xmlDoc.createElement "Char"
			newChar.SetAttribute "Name" c.name
			
			newMin = xmlDoc.createElement "Min"
			newMax = xmlDoc.createElement "Max"
			newOffset = xmlDoc.createElement "Offset"
			
			axis = #("x", "y", "z")
			
			for i = 1 to 3 do (
				newMin.SetAttribute axis[i] (c.min[i] as string)
				newMax.SetAttribute axis[i] (c.mx[i] as string)
				newOffset.SetAttribute axis[i] (c.offset[i] as string)
			)
			
			newChar.appendChild newMin
			newChar.appendChild newMax
			newChar.appendChild newOffset
			
			root.appendChild newChar
		)

		xmlDoc.save file

		edit file
		
	),
	
	fn load_xml =(
		
		if doesFileExist file then (
			xmlDoc = dotNetObject "system.xml.xmlDocument"
			xmlDoc.load file
			
			root = xmlDoc.selectSingleNode "//Font"
			
			for a = 0 to root.attributes.count-1 do (
				
				val = root.attributes.ItemOf[a].value
				
				case root.attributes.ItemOf[a].name of (
					"Name": name = val
					"Kerning": kerning = val as integer
					"Padding": padding = val as integer
					"Material": material_name = val
					"Space": space = val as integer
					"AtlasSize": atlasSize = [(filterString val " ")[1] as integer, (filterString val " ")[2] as integer]
					"CaseType": caseType = val
					"AvgHeight": avgHeight = (val as integer)
				)
			)
		)
		else ()
	),
	
	fn getMesh char pos:[0,0,0] size:1=(
		
		case caseType of (
			"Upper": char = toUpper char
			"Lower": char = toLower char
		)
		
		xpath = "//Char[@Name='" + char + "']"
		
		xml_char = xmlDoc.selectSingleNode xpath
		
		if xml_char != undefined then (
		
			xml_min = (xml_char.Item["Min"]).attributes
			xml_max = (xml_char.Item["Max"]).attributes
			xml_offset = (xml_char.Item["Offset"]).attributes
			
			min = [xml_min.itemOf["x"].value as float, xml_min.itemOf["y"].value as float, xml_min.itemOf["z"].value as float]
			mx = [xml_max.itemOf["x"].value as float, xml_max.itemOf["y"].value as float, xml_max.itemOf["z"].value as float]
			offset = [xml_offset.itemOf["x"].value as float, xml_offset.itemOf["y"].value as float, xml_offset.itemOf["z"].value as float]
			
			uv_div = [1/atlasSize.x, 1/atlasSize.y, 0]
			
			trans = transMatrix pos

			v1 = ([min.x - padding, min.y - padding, 0] + offset - min) * 1./avgHeight * size * trans
			v2 = ([min.x - padding, mx.y + padding, 0] + offset - min) * 1./avgHeight * size * trans
			v3 = ([mx.x + padding, mx.y + padding, 0] + offset - min) * 1./avgHeight * size * trans
			v4 = ([mx.x + padding, min.y - padding, 0] + offset - min) * 1./avgHeight * size * trans
			
			uv1 = [min.x - padding, min.y - padding, 0] * uv_div
			uv2 = [min.x - padding, mx.y + padding, 0] * uv_div
			uv3 = [mx.x + padding, mx.y + padding, 0] * uv_div
			uv4 = [mx.x + padding, min.y - padding, 0] * uv_div
			
			f1 = [3, 2, 1]
			f2 = [1, 4, 3]
			
			out_mesh = trimesh()
			setNumVerts out_mesh 4
			setNumTVerts out_mesh 4
			setNumFaces out_mesh 2
			
			for i = 1 to 4 do setVert out_mesh i #(v1, v2, v3, v4)[i]
			for i = 1 to 4 do setTVert out_mesh i #(uv1, uv2, uv3, uv4)[i]			
			
			for i = 1 to 2 do setFace out_mesh i #(f1, f2)[i]
			
			buildTVFaces out_mesh
			for i = 1 to 2 do setTVFace out_mesh i #(f1, f2)[i]
			out_mesh
		)
		else (
			trimesh()
		)
	),
	
	fn getWidth char =(
		
		case caseType of (
			"Upper": char = toUpper char
			"Lower": char = toLower char
		)
		
		xpath = "//Char[@Name='" + char + "']"
		
		xml_char = xmlDoc.selectSingleNode xpath
		
		if xml_char != undefined then (
			xml_char.Item["Max"].attributes.ItemOf["x"].value as integer - xml_char.Item["Min"].attributes.ItemOf["x"].value as integer
		)
		else (
			space
		)
	),
	
	fn getHeight char =(
		case caseType of (
			"Upper": char = toUpper char
			"Lower": char = toLower char
		)
		
		xpath = "//Char[@Name='" + char + "']"
		
		xml_char = xmlDoc.selectSingleNode xpath
		
		if xml_char != undefined then (
			xml_char.Item["Max"].attributes.ItemOf["y"].value as integer - xml_char.Item["Min"].attributes.ItemOf["y"].value as integer
		)
		else (
			0
		)
	),
	
	fn getChars =(
		
		chars = xpath = "//Char"
		
		xml_chars = xmlDoc.selectNodes xpath
		
		char_list = for i = 0 to xml_chars.count-1 collect xml_chars.ItemOf[i].attributes.ItemOf["Name"].value		
		char_list
	)
	
)

struct VrageFontLibrary (
	fonts = #(),
	
	fn loadFonts =(
		
		font_files = getFiles (MyVRageRoot + @"\Vrage_Plugins\Fonts\*.xml")
		
		fonts = for f in font_files collect VrageFont file:f
		for f in fonts do f.load_xml()
	)

)

fn Vrage_TextMeshDataFromAtlas tex_path =(
    tex_bmp = openBitmap tex_path
    tex_size = [tex_bmp.width, tex_bmp.height]
    
    char_rows = #()
    this_row = #()

    for r = 0 to tex_size.y-1 do(
        /*Get Row pixels */
        pxls = for p in (getPixels tex_bmp [0, r] tex_size.x) collect p as point3
				
        /*Check if row is blank -> all black*/
        sum = (Vrage_sumArray (for p in pxls collect length(p)))
		
        if sum == 0 then (
            /*if Current row of characters is not empty append it to the list */
            if this_row.count > 0 do (
                append char_rows this_row
                this_row = #()
            )
        )
        else (
            /* Append the row index + row pixels to this_row*/
            append this_row #(r, pxls)
        )
		
    )
	
	if this_row.count > 0 do (
		append char_rows #(this_row)
	)
    
    char_list = #()
	
    for row in char_rows do (
		indices = for r in row collect r[1]
		
		this_char = [0, 0]
		these_chars = #()
		
		for i = 1 to tex_size.x do (
			
			col_pxls = for r in row collect r[2][i]
				
			sum = Vrage_sumArray (for p in col_pxls collect length(p))
			
			if sum == 0 then (
				if this_char != [0, 0] do (
					append these_chars this_char
					this_char = [0, 0]
				)
			)
			else (
				if this_char.x <= 0 then (
					this_char.x = i - 1
				)
				else (
					this_char.y = i
				)
			)
		)
		
		if this_char != [0, 0] do (
			append these_chars this_char
		)
		
		row_chars = #()
		row_offsets = #()
		for c = 1 to these_chars.count do (
			char = these_chars[c]
			
			char_width = char.y - char.x
			char_height = indices[indices.count] - indices[1] +1
			char_start = indices[1]
			char_end = indices[indices.count]
			new_start = char_start
			new_end = char_end
			trimmed_height = #()
			
			sum0 = Vrage_sumArray (for p in (getPixels tex_bmp [char.x, char_start] char_width) collect length(p as point3))
			sum1 = Vrage_sumArray (for p in (getPixels tex_bmp [char.x, char_end] char_width) collect length(p as point3))
			
			count = char_start
			for i = char_start to char_end while sum0 == 0 do (
				count = i
				sum0 = Vrage_sumArray (for p in (getPixels tex_bmp [char.x, i] char_width) collect length(p as point3))
			)
			new_start = count
			
			count = char_end
			for j = char_end to char_start by -1 while sum1 == 0 do (
				count = j
				sum1 = Vrage_sumArray (for p in (getPixels tex_bmp [char.x, j] char_width) collect length(p as point3))
			)
			new_end = count
			
			
			char_y_bounds = [tex_size.y - new_start, tex_size.y - new_end - 1]
			
			new_char = VrageFontCharacter()
			new_char.min = [(char.x as float), (char_y_bounds.y as float), 0]
			new_char.mx = [(char.y as float), (char_y_bounds.x as float), 0]
			new_char.w = new_char.mx.x - new_char.min.x
			new_char.h = new_char.mx.y - new_char.min.y

			new_char.offset = [0, char_end - new_end, 0]
			
			append row_chars new_char
			append row_offsets (char_end - new_end)
			
			
		)
		
		for c = 1 to row_chars.count do row_chars[c].offset.y = row_chars[c].offset.y - amax(row_offsets)
		
		join char_list row_chars
    )
	
	Font = VrageFont chars:char_list kerning:25
	Font
)

plugin simpleObject VRageTextDecal
name:"Text Decal"
category:"VRage Tool"
classID:#(0x7db4d221, 0x27f7b37b)
(
	parameters main rollout:r_TextDecal (
		font_id type:#integer default:1 ui:ddl_Font
		textStr type:#string default:"TextDecal" ui:et_text
		font_size type:#float default:25.0 ui:sp_fontSize
		justification type:#integer default:1 ui:rb_justification
		small_caps type:#Boolean default:False ui:cx_small_caps
	)
	parameters advanced rollout:r_advanced (
		kerning type:#float default:25 ui:sp_kerning
		leading type:#float default:20 ui:sp_leading
	)
	
	rollout r_TextDecal "Text Decal"(
		
		group "Font:" (
			dropdownList ddl_Font "" items:(for f in MyVrageFontLib.fonts collect f.name)
			spinner sp_fontSize "Size: " type:#worldunits range:[0.0, 100., 15.0] align:#left fieldwidth:(ddl_Font.width-38)
			checkbox cx_small_caps "Small Caps"
		)

		group "Justification:" (
			checkbutton cb_left "Left" across:3 width:45 align:#left
			checkbutton cb_center "Center" width:45 align:#center
			checkbutton cb_right "Right" width:45 align:#right
		)
		
		group "Text:" (
			edittext et_text "" height:60 labelontop:true
			radiobuttons rb_justification labels:#("1", "2", "3") columns:3 visible:false offset:[0,-20]
		)
		
		fn just_buttons =(
			case justification of (
				1: (
					cb_left.checked = True
					cb_center.checked = False
					cb_right.checked = False
				)
				2:(
					cb_left.checked = False
					cb_center.checked = True
					cb_right.checked = False
				)
				3:(
					cb_left.checked = False
					cb_center.checked = False
					cb_right.checked = True
				)
			)
		)
		
		on r_TextDecal open do (
			ddl_Font.items = (for f in MyVrageFontLib.fonts collect f.name) as array
			just_buttons()
		)
		
		on ddl_Font selected sel do (
			ddl_Font.items = (for f in MyVrageFontLib.fonts collect f.name) as array
		)
		
		on cb_left changed state do (
			rb_justification.state = 1
			just_buttons()
		)
		
		on cb_center changed state do (
			rb_justification.state = 2
			just_buttons()
		)
		
		on cb_right changed state do (
			rb_justification.state = 3
			just_buttons()
		)
		
	)
	
	rollout r_advanced "Advanced Settings" (
		spinner sp_kerning "Kerning" range:[-1000, 1000., 10.0]
		spinner sp_leading "Leading" range:[-1000, 1000., 10.0]
	)
	
	on hasUVW do true 

	on setGenUVW bool do true
	
	on buildMesh do (
		
		font = if font_id <= MyVrageFontLib.fonts.count then MyVrageFontLib.fonts[font_id] else undefined
		small_caps_size = 0.7

		if font != undefined then (
			font.load_xml()
			
			if textStr == "" do textStr = "TextDecal"
			
			txt_mesh = trimesh()
			txt_width = 0
			txt_height = 0

			splitText = filterString textStr "\n\r"
			
			count = 0
			
			for l = 1 to splitText.count do (
				
				txt = splitText[l]
				
				txt_size = (if small_Caps and txt[1] == (toLower txt[1]) then small_caps_size else 1)

				row_mesh = font.getMesh txt[1] pos:[0, -(1. + leading/100.) * (l - 1), count] size:txt_size
				row_width = (font.getWidth txt[1])/(font.avgHeight as float) * txt_size + (kerning/100. * font.space/(font.avgHeight as float))
				
				count += 1
					
				for i = 2 to txt.count do (
					txt_size = (if small_Caps and txt[i] == (toLower txt[i]) then small_caps_size else 1)
					row_mesh += (font.getMesh txt[i] pos:[row_width, -(1. + leading/100.) * (l - 1), count] size:txt_size)
					row_width += (font.getWidth txt[i])/(font.avgHeight as float) * txt_size + (kerning/100. * font.space/(font.avgHeight as float))
					count += 1
				)
				
				if justification != 1 do (
					
					shift = [(row_width - (kerning/100. * font.space/(font.avgHeight as float)))/2 * (justification - 1), 0, 0]
					for v=1 to row_mesh.numverts do setVert row_mesh v (getVert row_mesh v - shift)
					
				)
				
				txt_mesh += row_mesh
			)
			
			max_width = amax width_list
			
			verts = for v = 1 to (getNumVerts txt_mesh) collect ((getVert txt_mesh v) * [font_size, font_size, 0])
			faces = for f = 1 to (getNumFaces txt_mesh) collect getFace txt_mesh f
			t_verts = for v = 1 to (getNumVerts txt_mesh) collect getTVert txt_mesh v
				
			setMesh mesh vertices:verts faces:faces
			meshop.setMapSupport mesh 1 false
			meshop.setMapSupport mesh 1 true
			meshop.setNumMapVerts mesh 1 mesh.numverts
			meshop.setNumMapFaces mesh 1 mesh.numfaces
			meshop.buildMapFaces mesh 1
			
			for v = 1 to mesh.numverts do meshop.setmapvert mesh 1 v (getTVert txt_mesh v)
			
			--for i = 1 to mesh.numfaces do( setTVFace mesh i (getFace mesh i))
			meshop.autoEdge mesh mesh.Edges 1.0
			update mesh
			selfnode = (refs.dependentnodes this)[1]
			
			if MyVRageMatLib.mat_list.count == 0 do (
				MyVRageMatLib.main()
			)
			
			try selfnode.material = MyVRageMatLib.get_mat_by_name font.material_name catch()
		)
		else (
			setMesh mesh width:10 length:10 widthsegs:1 lengthsegs:1
		)
	)
	
	tool create (
		on mousePoint click do
		(
			case click of
			(
				1: nodeTM.translation = gridPoint
				2: #stop
			)
		)
	)
	
)

MyVrageFontLib = VrageFontLibrary()
MyVrageFontLib.loadFonts()