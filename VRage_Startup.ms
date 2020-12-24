global MyVRageRoot 

MyVRageRoot = pathConfig.removePathLeaf (getSourceFileName());

-- Struct of Global Scence Settings
struct MyVRageSceneDef
(
	i_LODS = 1, --number of Lods i-1 
	i_Construction = 1,
	i_ConstructionLODS = 1,
	i_Subparts = 0,
	Scenetype = 1,  --1 = Block, --2 == Character , 3 = Animation
	ModelName = "MySEModel",
	OldModelname = "MySEModel",
	LodDistance1  = 10,
	LodDistance2 = 20,
	LodDistance3 = 40,
	LodDistance4 = 80,
	LodDistance5 = 100,
	LodDistance6 = 200
)

--deklaration of the global
global MyVrageScene = MyVRageSceneDef()

fn Vrage_LoadToolbox =(

	fileIn (MyVRageRoot  + "\\Vrage_Common.ms")
	format "loaded script '%'\n"  "\\Vrage_Common.ms"
	fileIn (MyVRageRoot + "\\Vrage_Settings.ms")
	format "loaded script '%'\n"  "\\Vrage_Settings.ms"
	fileIn (MyVRageRoot + "\\Vrage_Logging.ms")
	format "loaded script '%'\n"   "\\Vrage_Logging.ms"
	fileIn (MyVRageRoot + "\\Vrage_LayerHandle.ms")
	format "loaded script '%'\n"   "\\Vrage_LayerHandle.ms"
	fileIn (MyVRageRoot + "\\Vrage_IO\\Vrage_MaterialLibrary.ms")
	format "loaded script '%'\n"  "\\Vrage_IO\\Vrage_MaterialLibrary.ms"
	--fileIn "Vrage_MainUI"


	files = #()
	dirs = getDirectories ((trimright MyVRageRoot "\\") +"\\*")

	for d in dirs do (
		join dirs (getDirectories ((trimright d "\\") +"\\*"))
	)
	
	for d in dirs where not (matchpattern d pattern:"*vrage_testing*") do (
		join files (getFiles ((trimright d "\\") +"\\*.ms"))
	)
		
	for f in files where matchpattern (getfilenamefile f) pattern:"*vrage*" do (
		
		fileIn f
		format "loaded script '%'\n" f
		
	)
)

Vrage_LoadToolbox()