VRage_ROOTPATH = pathConfig.removePathLeaf (getSourceFileName());

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
global VrageScene = MyVRageBlockdef()

filein "Vrage_Settings.ms"

filein "Vrage_IO\\Vrage_DOSCommand.ms"
filein  "Vrage_testing\\Logging.ms"

filein "Vrage_Havok\\Vrage_CollisionPlugins.ms"
filein "Vrage_Havok\\Vrage_RigidBodies.ms"

--Load all Plugins to keep scenes from breaking upon opening
for f in (getFiles "Vrage_Plugins\\*.ms") do fileIn f

