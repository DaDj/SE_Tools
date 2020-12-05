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

Transparent_materials = @"C:\SteamLibrary\steamapps\common\SpaceEngineers\Content\Data\TransparentMaterials.sbc"

xmlDoc = dotNetObject "system.xml.xmlDocument"

xmlDoc.load Transparent_materials

Materials = xmlDoc.selectNodes "//TransparentMaterial"