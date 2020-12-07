/*

	NO DMAP GlassInside: Path:"", Tech:GLASS
	NO DMAP WindowInside: Path:"", Tech:GLASS
	NO DMAP WindowRectangularOutside: Path:"", Tech:GLASS
	NO DMAP WindowRectangularInside: Path:"", Tech:GLASS
	NO DMAP WindowTriangularOutside: Path:"", Tech:GLASS
	NO DMAP WindowTriangularInside: Path:"", Tech:GLASS
	NO DMAP GlassOutside: Path:"", Tech:GLASS
	NO DMAP FrostedGlass: Path:"", Tech:GLASS
	NO DMAP FrostedGlassLarger: Path:"", Tech:GLASS
	NO DMAP CockpitGlassInside: Path:"", Tech:GLASS
	NO DMAP CockpitGlassOutside: Path:"", Tech:GLASS
	NO DMAP CockpitFighterGlassInside: Path:"", Tech:GLASS
	NO DMAP CockpitFighterGlassOutside: Path:"", Tech:GLASS
	NO DMAP CockpitIndustrialGlassOutside: Path:"", Tech:GLASS
	NO DMAP CockpitIndustrialGlassInside: Path:"", Tech:GLASS
	NO DMAP GenericGlass: Path:"", Tech:GLASS
	NO DMAP SafeZoneShieldGlass: Path:"", Tech:GLASS
	NO DMAP SafeZoneShield: Path:"", Tech:GLASS
	NO DMAP RockDebris: Path:"", Tech:MESH
	NO DMAP TransparentScreenArea: Path:"", Tech:HOLO
	NO DMAP TransparentScreenArea90: Path:"", Tech:HOLO
	NO DMAP TransparentScreenArea180: Path:"", Tech:HOLO
	NO DMAP TransparentScreenArea270: Path:"", Tech:HOLO
	NO DMAP TransparentScreenArea_Outside: Path:"", Tech:GLASS

*/

clearListener()
Transparent_materials = @"C:\SteamLibrary\steamapps\common\SpaceEngineers\Content\Data\TransparentMaterials.sbc"

tex_dir = MyVrageCfg.PathTextures
tex_ext = MyVrageCfg.TextureType

xmlDoc = dotNetObject "system.xml.xmlDocument"

xmlDoc.load Transparent_materials

/*
ColX = xmlDoc.selectNodes "//TransparentMaterial/Color/X"
ColY = xmlDoc.selectNodes "//TransparentMaterial/Color/Y"
ColZ = xmlDoc.selectNodes "//TransparentMaterial/Color/Z"

for c = 0 to Cols.count-1 do (
	format "%\n" [ColX.itemOf[c].innertext as float, ColY.itemOf[c].innertext as float, ColZ.itemOf[c].innertext as float]
)
*/


fn get_TransMatByName n =(
	
	xpath = "//TransparentMaterial[Id/SubtypeId[contains(text(),'" + n + "')]]"
	
	m = xmlDoc.selectSingleNode xpath
	name = (m.selectSingleNode "Id/SubtypeId").innertext
	t = m.selectSingleNode "Texture"
	g= m.selectSingleNode "GlossTexture"
	ga= m.selectSingleNode "GlossTextureAdd"
	
	c=  m.selectSingleNode "Color"
	ca=  m.selectSingleNode "ColorAdd"
	uvs= m.selectSingleNode "UVSize"
	uvo= m.selectSingleNode "UVOffset"
	ref = m.selectSingleNode "Reflectivity"
	
	if (t != undefined or g != undefined) and matchpattern name pattern:"*glass*" do (
		format "%: %\n" m.Name name
		if t != undefined do format "\tTexture: %\n" t.innertext
		if g != undefined do format "\tGlossTexture: %\n" g.innertext
		if ga != undefined do format "\tGlossTextureAdd %\n" ga.innertext
			
		if c!= undefined do format "\tColor R:% G:% B% A:%\n" c.item["X"].innertext c.item["Y"].innertext c.item["Z"].innertext c.item["W"].innertext
		if ca!= undefined do format "\tColorAdd R:% G:% B% A:%\n" ca.item["X"].innertext ca.item["Y"].innertext ca.item["Z"].innertext ca.item["W"].innertext
		
		if uvs != undefined do format "\tUVSize %\n" [uvs.item["X"].innertext as float, uvs.item["Y"].innertext as float]
		if uvo != undefined do format "\tUVOffset %\n" [uvo.item["X"].innertext as float, uvo.item["Y"].innertext as float]
		format "\n"
	)
	
	m
)

OutMat = VrageMaterial xml_mat:(get_TransMatByName "GlassOutside")
InMat = VrageMaterial xml_mat:(get_TransMatByName "GlassInside")

$Sphere001.material = OutMat.get_material()

$Sphere001.material = InMat.get_material()