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
	import_subparts = True,
	import_construction = True,
	import_LODs = True,

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
		FbxImporterSetParam "ConvertUnit" #custom_unit
		FbxImporterSetParam "FillTimeline" false
		FbxImporterSetParam "FilterKeyReducer" false
		FbxImporterSetParam "FilterKeySync" false
		FbxImporterSetParam "GenerateLog" true
		FbxImporterSetParam "ImportBoneAsDummy" true
		FbxImporterSetParam "KeepFrameRate" false
		FbxImporterSetParam "Lights" true
		FbxImporterSetParam "Markers" false
		FbxImporterSetParam "Mode" #merge
		FbxImporterSetParam "PointCache" true
		FbxImporterSetParam "Resampling" 30.0
		FbxImporterSetParam "ScaleConversion" true
		FbxImporterSetParam "ScaleFactor" 1.0
		FbxImporterSetParam "Shape" true
		FbxImporterSetParam "Skin" true
		FbxImporterSetParam "SmoothingGroups" false
		FbxImporterSetParam "UpAxis" #z
		
	),
	
	fn importFBX file root_layer:(LayerManager.getLayer 0) parent_layer:undefined parent_node:undefined = (
		
		fname = filenameFromPath file --getFilenameFile
		name = getFilenameFile file
			
		old_objects = objects as array
		
		importfile file #noPrompt using:FBXIMP
			
		imported = for o in objects where findItem old_objects o == 0 collect o
		
		if parent_layer == undefined then (
			parent_layer = layermanager.newLayerFromName name
			parent_layer.setParent root_layer
			lod0_layer = layermanager.newLayerFromName (name + " #LOD0")
			lod0_layer.setParent parent_layer
			dummy_layer = layermanager.newLayerFromName (name + " #Dummies")
			dummy_layer.setParent parent_layer
	
			for o in imported do (
				case (superclassOf o) of (
					GeometryClass: lod0_layer.addNode o
					helper: dummy_layer.addNode o
				)
				
				o.name += "#" + lod0_layer.name
			)
			
			if import_subparts do (
				subparts = for o in imported where (superclassOf o == helper) and (isProperty o "file") collect o
				
				if subparts.count > 0 do (
					sub_layer = layermanager.newLayerFromName (name + " #Subparts")
					sub_layer.setParent parent_layer
					
					for sub in subparts do (
						sub_file = getFilenamePath file + sub.file as string + ".fbx"
						if doesFileExist sub_file do (
							sub_imports = importFBX sub_file root_layer:sub_layer parent_node:sub
							join imported sub_imports
						)
					)
				)
			)
			
			if import_LODs do (
				lod_files = getFiles (getFilenamePath file + name + "_LOD*.FBX")
				
				for lod_file in lod_files do (
					lod_imports = importFBX lod_file parent_layer:parent_layer parent_node:parent_node
					
					join imported lod_imports
				)
			)

			if import_construction do (
				construction_files = getFiles (getFilenamePath file + getFilenameFile file + "Construction*.FBX") + getFiles (getFilenamePath file + getFilenameFile file + "_Construction*.FBX")
				
				if construction_files.count > 0 do (
					constr_layer = layermanager.newLayerFromName (name + " #Construction")
					constr_layer.setParent parent_layer
					constr_layer.ishidden  = True
					
					for constr in construction_files where not matchpattern constr pattern:"*_LOD*" do (
						constr_imports = importFBX constr root_layer:constr_layer parent_node:parent_node
						join imported constr_imports
					)
					
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
			lod_file_name = getFilenameFile file
			lod_name_index = FindString lod_file_name "_LOD"
			lod_name = subString lod_file_name (lod_name_index + 1) -1
			lod_owner = subString lod_file_name 1 (lod_name_index - 1)

			lod_layer = layermanager.newLayerFromName (lod_owner + " #" + lod_name)
			lod_layer.setParent parent_layer
			lod_layer.ishidden  = True
			
			for i = imported.count to 1 by -1 do (
				o = imported[i]
				case (superclassOf o) of (
					GeometryClass: lod_layer.addNode o
					helper: delete o
				)
				
				if not isdeleted o do o.name += "#" + lod_layer.name
				
			)
		)
		
		imported
	),

	fn import =(

		if doesFileExist filename then (
			max create mode
			--SetImportSettings()
			with redraw off (
				LastImport = importFBX filename
				
				LastImport = for o in lastimport where not isdeleted o collect o
				
				Vrage_cleanLayers()
				
				if Vrage_cleanMats == undefined do (
					fileIn (MyVRageRoot + "\\Vrage_IO\\VRage_MaterialLibrary.ms")
				)
				
				for o in LastImport do (
					o.name = trimright (filterstring o.name "#")[1]
				)
				
				Vrage_cleanMats LastImport
			)
			
			forceCompleteRedraw()
		)
		else (
			msg = "File \"" + filename + "\" does not exist and can not be imported"
			messageBox 
		)
	)
)