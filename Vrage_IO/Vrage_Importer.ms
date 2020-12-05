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

struct VrageFBXImporter (

	filename = undefined,

	fn showCurrentSettings =(

		Settings = #(
			"Animation",
			"AxisConversion",
			"BakeAnimationLayers",
			"Cameras",
			"ConvertUnit",
			"FillTimeline",
			"FilterKeyReducer",
			"FilterKeySync",
			"GenerateLog",
			"ImportBoneAsDummy",
			"KeepFrameRate",
			"Lights",
			"LoadImportPresetFile",
			"Markers",
			"Mode",
			"PopSettings",
			"PushSettings",
			"PointCache",
			"Resampling",
			"ResetImport",
			"ScaleConversion",
			"ScaleFactor",
			"Shape",
			"Skin",
			"SmoothingGroups",
			"TakeCount",
			"TakeIndex",
			"UpAxis"
		)
		
		for setting in Settings do format "FbxImporterSetParam \"%\" %\n" setting (FbxImporterGetParam setting)
	),

	fn SetImportSettings =(
			
		FbxImporterSetParam "Animation" true
		FbxImporterSetParam "AxisConversion" true
		FbxImporterSetParam "BakeAnimationLayers" true
		FbxImporterSetParam "Cameras" true
		FbxImporterSetParam "ConvertUnit" #custom unit
		FbxImporterSetParam "FillTimeline" false
		FbxImporterSetParam "FilterKeyReducer" false
		FbxImporterSetParam "FilterKeySync" false
		FbxImporterSetParam "GenerateLog" true
		FbxImporterSetParam "ImportBoneAsDummy" true
		FbxImporterSetParam "KeepFrameRate" false
		FbxImporterSetParam "Lights" true
		FbxImporterSetParam "LoadImportPresetFile" unsupplied
		FbxImporterSetParam "Markers" false
		FbxImporterSetParam "Mode" #merge
		FbxImporterSetParam "PopSettings" unsupplied
		FbxImporterSetParam "PushSettings" unsupplied
		FbxImporterSetParam "PointCache" true
		FbxImporterSetParam "Resampling" 30.0
		FbxImporterSetParam "ResetImport" unsupplied
		FbxImporterSetParam "ScaleConversion" true
		FbxImporterSetParam "ScaleFactor" 1.0
		FbxImporterSetParam "Shape" true
		FbxImporterSetParam "Skin" true
		FbxImporterSetParam "SmoothingGroups" false
		FbxImporterSetParam "TakeCount" unsupplied
		FbxImporterSetParam "TakeIndex" unsupplied
		FbxImporterSetParam "UpAxis" #z
		
	),
	
	fn importFBX file root_layer:(LayerManager.getLayer 0) parent_layer:undefined parent_node:undefined = (

		fname = filenameFromPath file --getFilenameFile
		name = getFilenameFile file
			
		old_objects = objects as array
		
		importfile file #noPrompt using:FBXIMP
			
		imported = for o in objects where findItem old_objects o == 0 collect o
		
		if parent_layer == undefined then (
			parent_layer = layermanager.newLayerFromName fname
			parent_layer.setParent root_layer
			lod0_layer = layermanager.newLayerFromName ("LOD0 (" + fname + ")")
			lod0_layer.setParent parent_layer
			dummy_layer = layermanager.newLayerFromName ("Dummies (" + fname + ")")
			dummy_layer.setParent parent_layer
	
			for o in imported do (
				case (superclassOf o) of (
					GeometryClass: lod0_layer.addNode o
					helper: dummy_layer.addNode o
				)
			)
				
			subparts = for o in imported where (superclassOf o == helper) and (isProperty o "file") collect o
			
			if subparts.count > 0 do (
				sub_layer = layermanager.newLayerFromName ("Subparts (" + fname + ")")
				sub_layer.setParent parent_layer
				
				for sub in subparts do (
					sub_file = getFilenamePath file + sub.file as string + ".fbx"
					if doesFileExist sub_file do (
						sub_imports = importFBX sub_file root_layer:sub_layer parent_node:sub			
						join imported sub_imports
					)
				)
			)
			
			lod_files = getFiles (getFilenamePath file + name + "_LOD*.FBX")
			
			for lod_file in lod_files do (
				lod_imports = importFBX lod_file parent_layer:parent_layer parent_node:parent_node
				join imported lod_imports
			)
			
			construction_files = getFiles (getFilenamePath file + getFilenameFile file + "Construction*.FBX") + getFiles (getFilenamePath file + getFilenameFile file + "_Construction*.FBX")
			
			if construction_files.count > 0 do (
				constr_layer = layermanager.newLayerFromName ("Construction (" + fname + ")")
				constr_layer.setParent parent_layer
				constr_layer.ishidden  = True
				
				for constr in construction_files where not matchpattern constr pattern:"*_LOD*" do (
					constr_imports = importFBX constr root_layer:constr_layer parent_node:parent_node
					join imported constr_imports
				)
				
			)
				
			if parent_node != undefined do (
				for o in imported where o.parent == undefined do (
					o.position = parent_node.position
					o.parent = parent_node
				)
			)
		)
		else (
			lod_name = getFilenameFile file
			lod_name = subString lod_name (1 + FindString lod_name "_LOD") -1
				
			lod_layer = layermanager.newLayerFromName (lod_name + " (" + fname + ")")
			lod_layer.setParent parent_layer
			lod_layer.ishidden  = True
			
			for i = imported.count to 1 by -1 do (
				o = imported[i]
				case (superclassOf o) of (
					GeometryClass: lod_layer.addNode o
					helper: delete o
				)			
			)
		)
		
		imported
	),

	fn import =(

		if doesFileExist filename then (

			SetImportSettings()

			LastImport = importFBX (filename)
			Vrage_cleanLayers()

			Vrage_cleanMats LastImport
		)
		else (
			msg = "File \"" + filename + "\" does not exist and can not be imported"
			messageBox 
		)
	)
)