


struct VrageLodDef
(
	Title = "",
	Id = 0,
	DrawDistance = 20
)

struct VrageLods 
(
	List = #(),

	fn compareLodDistance v1 v2 =
(
	if v1 == undefined do return 0
	if v2 == undefined do return 0
	local d = (v1.DrawDistance)-(v2.DrawDistance)
	case of
	(
		(d < 0.): -1
		(d > 0.): 1
		default: 0
	)
),
	
	fn InitLods n_Lods =
    (
		local LodArray = #()
        for i = 1 to n_Lods do 
        (
            LodArray[i] = VrageLodDef()
            LodArray[i].ID = i-1
            LodArray[i].DrawDistance = (20 * i)
        )
		List = LodArray
	),
	
	fn AddLod DD= 
    (
		MaxiLod = 0
        for i = 1 to List.count do 
		(
			print List[i].id
			MaxiLod = amax #(MaxiLod, List[i].id)
			
		)
		MaxiLod = MaxiLod +1
		LodiD = List.count + 1
        List[LodiD] = VrageLodDef()
        List[LodiD].ID = MaxiLod
		List[LodiD].DrawDistance  = DD
		qsort  List compareLodDistance 
	),
	
	fn RemoveLod = 
	(	
		-- Deletes the top most LOD Level
		deleteItem List List.Count
	)
)

struct VrageConstructionDef
(
	Title = "",
	Id = 0,
	Percent = 10,	
	Lods = VrageLods(),
	LayerID = undefined
)

struct VRageModelDef
(   
	Title = "",
	Lods = VrageLods(),
	Constructions = #(),
	Subparts = #(),
	LayerInfos = #(),
	LayerID = undefined,
    Typeof = undefined,

    fn Init n_Lods n_Constructions n_ConstructionsLods = 
    (
        Lods.InitLods n_Lods

        for i = 1 to n_Constructions do 
        (
            Constructions[i] = VrageConstructionDef()
            Constructions[i].ID = i
            Constructions[i].Percent = (amin (100/n_Constructions * i) 100)
            Constructions[i].Lods.InitLods n_ConstructionsLods
        ) 
    )
)

struct VRageCubeBlock 
(
	DisplayName = "",
	Mountpoints = #(),
    ModelDef =  VRageModelDef(),
    
    fn CreatDef n_Lods n_Constructions n_ConstructionsLods =
    (
        ModelDef.Init n_Lods n_Constructions n_ConstructionsLods
    )
)

Mything = VRageCubeBlock()
Mything.CreatDef 2 3 2

--Adds root nodes to treeView.
fn populateTreeView theTv=
(
	--Loop through all the objects in the scene. 
	for i = 0 to layerManager.count-1 do
	(
		ilayer = layerManager.getLayer i
		--Create a treeViewNode and add it to the treeView control
		theTv.nodes.add (dotNetObject "System.Windows.Forms.TreeNode"  ilayer.name) 
	)
)



rollout VrageModels "ModelData" width:500 height:200
(
	--dropdownlist Model_DD "Model" items:#("1/2", "1/4", "1/8", "1/16")
    	dotnetcontrol tv "TreeView" width:240 height:400  pos:[0, 20]
		label t1 "MyModel" pos:[250, 20] 
		label t3 "Lods:" pos:[250, 50] 
		label t4 "5" pos:[280, 50] 
		button theButton "+"   width:30 height:30 toolTip:"Apply new name" pos:[300, 40] 
		button theButton1 "-" width:30 height:30 toolTip:"Apply new name" pos:[330, 40] 
	
	
	--	listbox objectToKill "Objects:" items:(for o in objects collect o.name)

	--button testButton "Test"
	on testButton pressed do
	(
		showProperties tv
	)
	on VrageModels open do (
		populateTreeView tv
		
		local textColor   = MXSColor_to_dotNetColor (((colorman.getColor #text  )*255) as color)
		local windowColor = MXSColor_to_dotNetColor (((colorman.getColor #window)*255) as color)
		
		tv.backColor = windowColor
		tv.foreColor = textColor
	)
)

layerExplorer = SceneExplorerManager.GetActiveExplorer()
items = layerExplorer.SelectedItems()
for i in items where isKindOf i Base_Layer do
(
    FullNameToFind =  i.name
    print FullNameToFind  

)

-- try (cui.UnRegisterDialogBar VRAGE_ModelUI) catch () 	
-- --Create a rollout
-- try (closeRolloutFloater VRAGE_ModelUI) catch () 

-- VRAGE_ModelUI = newRolloutFloater  "VRage Utilies" 500 800 800 600 
-- addRollout VrageModels VRAGE_ModelUI border:true
-- cui.RegisterDialogBar VRAGE_ModelUI style:#(#cui_floatable)

--clearListener()

 
 


