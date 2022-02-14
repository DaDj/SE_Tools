global MyVRageRoot = pathConfig.removePathLeaf ( getSourceFileName()) ;
global VRageIcons = GetDir #userScripts + "\\VRageToolbox\\Vrage_resources\\VrageIcons.bmp"
global VRageIcoLeng = 37

fn Vrage_LoadToolbox = (

	fileIn ( MyVRageRoot + "\\Vrage_Common.ms" )
	format "loaded script '%'\n" "\\Vrage_Common.ms"

	fileIn ( MyVRageRoot + "\\Vrage_Settings.ms" )
	format "loaded script '%'\n" "\\Vrage_Settings.ms"

	fileIn ( MyVRageRoot + "\\Vrage_scene\\Vrage_SceneData.ms" )
	format "loaded script '%'\n"  "\\Vrage_scene\\Vrage_SceneData.ms"

	fileIn ( MyVRageRoot + "\\Vrage_Logging.ms" )
	format "loaded script '%'\n" "\\Vrage_Logging.ms"

	fileIn ( MyVRageRoot + "\\Vrage_Havok\\Vrage_CollisionPlugins.ms" )
	format "loaded script '%'\n" "\\Vrage_Havok\\Vrage_CollisionPlugins.ms"

	fileIn ( MyVRageRoot + "\\VRage_Dummies.ms" )
	format "loaded script '%'\n" "\\VRage_Dummies.ms"

	fileIn ( MyVRageRoot + "\\Vrage_IO\\Vrage_MaterialLibrary.ms" )
	format "loaded script '%'\n" "\\Vrage_IO\\Vrage_MaterialLibrary.ms"

	fileIn ( MyVRageRoot + "\\VRage_Layers.ms" )
	format "loaded script '%'\n" "\\VRage_Layers.ms"

	fileIn ( MyVRageRoot + "\\Vrage_IO\\VRage_Exporter.ms" )
	format "loaded script '%'\n" "\\Vrage_IO\\VRage_Exporter.ms"

	fileIn ( MyVRageRoot + "\\Vrage_IO\\Vrage_Importer.ms" )
	format "loaded script '%'\n" "\\Vrage_IO\\Vrage_Importer.ms"

	fileIn ( MyVRageRoot + "\\VRage_UI.ms" )
	format "loaded script '%'\n" "\\VRage_UI.ms"
	
	--Copy the No Thumbnail to the Thumbnails folder
	noThumbSrc = MyVRageRoot + "\\Vrage_resources\\" + "NoThumbnail.jpg"
	noThumbTrg = GetDir #plugcfg + "\\VRageUtilities" + "\\MaterialThumbnails\\" + "NoThumbnail.jpg"
	copyFile noThumbSrc noThumbTrg
	
	
	files = #( )
	dirs = getDirectories ( ( trimright MyVRageRoot "\\" ) + "\\*" )

	for d in dirs do (
		join dirs ( getDirectories ( ( trimright d "\\" ) + "\\*" ) )
	)
	
	for d in dirs where not ( matchpattern d pattern:"*vrage_testing*" ) do (
		join files ( getFiles ( ( trimright d "\\" ) + "\\*.ms" ) )
	)
	for f in files where matchpattern ( getfilenamefile f ) pattern:"*vrage*" do (
		
		fileIn f
		format "loaded script '%'\n" f
		
	)
)

Vrage_LoadToolbox()