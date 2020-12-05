fn Vrage_importFBX file root_layer:(LayerManager.getLayer 0) parent_layer:undefined parent_node:undefined = (

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
					sub_imports = Vrage_importFBX sub_file root_layer:sub_layer parent_node:sub			
					join imported sub_imports
				)
			)
		)
		
		lod_files = getFiles (getFilenamePath file + name + "_LOD*.FBX")
		
		for lod_file in lod_files do (
			lod_imports = Vrage_importFBX lod_file parent_layer:parent_layer parent_node:parent_node
			join imported lod_imports
		)
		
		construction_files = getFiles (getFilenamePath file + getFilenameFile file + "Construction*.FBX") + getFiles (getFilenamePath file + getFilenameFile file + "_Construction*.FBX")
		
		if construction_files.count > 0 do (
			constr_layer = layermanager.newLayerFromName ("Construction (" + fname + ")")
			constr_layer.setParent parent_layer
			constr_layer.ishidden  = True
			
			for constr in construction_files where not matchpattern constr pattern:"*_LOD*" do (
				constr_imports = Vrage_importFBX constr root_layer:constr_layer parent_node:parent_node
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
)

dir = @"E:\Program Files (x86)\Steam\SteamApps\common\SpaceEngineersModSDK\OriginalContent\Models\Cubes\large\"

fname1 = "SlideDoor.FBX"

LastImport = Vrage_importFBX (dir + fname1)
cleanLayers()

Vrage_cleanMats LastImport
