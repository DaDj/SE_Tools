
struct myGlobals
(
    -- General
    i_LODS = 0,


	fn run filename =
	(
		filein filename
	)

)

global MySE = myGlobals()

lbltext = #("0", "1", "2", "3", "4", "5")

rollout SETOOLS_SCENE "Set up Scene/Models" width:210 height:504
(
	button 'Prep_scene' "Pepare scene" width:185 height:25 toolTip:"Generates the basic Setup for working with SE)" align:#left
	on Prep_scene pressed do MySE.run "Scene_Setup.ms"		
		
	
	group "Level of Distance"	
	(
		label lbl "Number of LODS: " align:#left
		label lbl_LODCount "" align:#right offset:[0,-18]
        slider SliderLODCount "" orient:#horizontal type:#integer   ticks:5 range:[1,5,1] 
		
        on SliderLODCount changed val do 
        (
			lbl_LODCount.text = lbltext[val ]
            MySE.i_LODS = val
            MySE.run "Scene_Setup.ms"	
		)			
   
	
	on Cut_Names pressed do ( 
	try ( fileIn (scriptspath+"\\BTLC_TOOLKIT\\00_CUT_NAMES.ms") quiet:true   ) 
		catch messagebox "Error!" title:"Can't find script")		
	
	button 'Reord_Textures' "Re-order Textures"  width:185 height:25 toolTip:"Reorder Textures in Matlist(selected)" align:#left
	on Reord_Textures pressed do ( 
	try ( fileIn (scriptspath+"\\BTLC_TOOLKIT\\10_ReshuffleTextureorder.ms") quiet:true   ) 
		catch messagebox "Error!" title:"Can't find script" )			

	)
)
		
try (closeRolloutFloater SETOOLS) catch () 
SETOOLS = newRolloutFloater  "" 215 200 20 130 

addRollout SETOOLS_SCENE SETOOLS

-- cui.RegisterDialogBar SETOOLS style:#(#cui_floatable, #cui_dock_top) --minSize:[236,100] maxSize:[236,1600]
-- cui.DockDialogBar SETOOLS #cui_dock_top