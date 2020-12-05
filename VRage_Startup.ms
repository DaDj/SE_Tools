global MyVRageRoot 

MyVRageRoot = pathConfig.removePathLeaf (getSourceFileName());

-- Struct of Global Scence Settings
struct MyVRageBlockdef
(
	i_LODS = 1, --number of Lods i-1 
	i_Buildstages = 1,
	i_BuildstagesLODS = 1,
	LodDistance1  = 10,
	LodDistance2 = 20,
	LodDistance3 = 40,
	LodDistance4 = 80,
	LodDistance5 = 100,
	LodDistance6 = 200,

	fn run filename =(	filein filename) 
)

--deklaration of the global
global MyVrageScene = MyVRageBlockdef()

fn Vrage_LoadToolbox =(

	fileIn "Vrage_Settings.ms"

	files = getFiles ((trimright MyVRageRoot "\\") +"\\*.ms")
	dirs = getDirectories ((trimright MyVRageRoot "\\") +"\\*")

	for d in dirs do (
		join dirs (getDirectories ((trimright d "\\") +"\\*"))
	)
	
	for d in dirs where not (matchpattern d pattern:"*vrage_testing*") and not (matchpattern d pattern:"*startup*") do (
		join files (getFiles ((trimright d "\\") +"\\*.ms"))
	)
		
	for f in files where matchpattern (getfilenamefile f) pattern:"*vrage*" do (
		
		fileIn f
		format "loaded script '%'\n" f
		
	)
)

Vrage_LoadToolbox()