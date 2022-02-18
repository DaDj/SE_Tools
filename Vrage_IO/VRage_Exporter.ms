struct VRageExporter (

	Filepath = undefined,
	Filename = undefined,
	TempDirHKT = "",
	TempDirModels = "",

	fn FBXSettings = (
		--Geometry------------------------------------------------------------------------
		FBXExporterSetParam "SmoothingGroups" true
		FBXExporterSetParam "NormalsPerPoly" false
		FBXExporterSetParam "TangentsandBinormals" true
		FBXExporterSetParam "SmoothMesh" false
		FBXExporterSetParam "Instances" true
		FBXExporterSetParam "SelectionSetExport" true
		FBXExporterSetParam "MaxBoneAsBone" true
		FBXExporterSetParam "Triangulate" false
		FBXExporterSetParam "PreserveEdgeOrientation" true
		--Animation------------------------------------------------------------------------
		FBXExporterSetParam "Animation" false
		--Cameras------------------------------------------------------------------------
		FBXExporterSetParam "Cameras" false
		--Lights------------------------------------------------------------------------
		FBXExporterSetParam "Lights" false
		--Embed Media--------------------------------------------------------------------
		FBXExporterSetParam "EmbedTextures" false
		--Units----------------------------------------------------------------------------
		FBXExporterSetParam "ConvertUnit" "m"
		--Axis Conversion-----------------------------------------------------------------
		FBXExporterSetParam "AxisConversionMethod" "Animation"
		FBXExporterSetParam "UpAxis" "Y" 
		--UI----------------------------------------------------------------
		FBXExporterSetParam "ShowWarnings" true
		FBXExporterSetParam "GenerateLog" false
		--FBX File Format----------------------------------------------------------------
		FBXExporterSetParam "ASCII" true
		FBXExporterSetParam "FileVersion" "FBX201300"
	),

	fn Create_MWM_XML ModelName material_names OutPath LodData:undefined=
	(
		xmlDoc = dotNetObject "system.xml.xmlDocument"

		/* create header */
		header = xmlDoc.CreateXmlDeclaration "1.0" "" ""
		xmlDoc.AppendChild header
		
		root = xmlDoc.createElement "Model"
		root.SetAttribute "Name" "Default"
		xmlDoc.appendChild root
		
		newRef = xmlDoc.createElement "Parameter"
		newRef.SetAttribute "Name" "RescaleFactor"
		newRef.InnerText = "1.0"
		root.appendChild newRef
		for n in material_names do (
			
			newRef = xmlDoc.createElement "MaterialRef"
			newRef.SetAttribute "Name" n
			root.appendChild newRef
		)

		if (LodData != undefined) and (LodData.count > 1) then 
		( 
			for i=2 to LodData.count do 
			(
				newRef = xmlDoc.createElement "LOD"
				newRef.SetAttribute "Distance" (LodData[i] as string)
				root.appendChild newRef
				ModelRef = 	xmlDoc.createElement "Model"
				ModelRef.InnerText = @"Models\Cubes\" + ModelName + "_LOD" + ((i-1) as string)
				newRef.appendChild ModelRef
			)
			
		)
		
		xmlDoc.save ( OutPath + "\\" + ModelName + ".xml" )
	),

	fn SetTempDirs = 
	(
		TempDirHKT = MyVRageCfg.PathToolsFolder + @"\Temp" --Tempfolder for hkt creation
		TempDirModels = MyVRageCfg.PathToolsFolder + @"\Temp\Expo\Content\Models"  -- Basically folder for mwmbuilder
		try ( makedir TempDirHKT )	catch (	MyVRageLog.Error ("Permission Error while trying to create: " + TempDirHKT) )
		try ( makedir TempDirModels ) catch (MyVRageLog.Error ("Permission Error while trying to create: " + TempDirModels) )
	),

	fn ExportFBX MyObjects DestPath =
	(
		pluginManager.loadClass FbxExporter
		FBXSettings()

		select MyObjects
		exportFile (DestPath) #noprompt selectedOnly:true using:FBXEXPORTER  
	),

	fn ExportModel MyObjects Path =
	(
		fileType = getFilenameType Path
		if fileType != ".fbx" then Path = (getFilenamePath Path)+ (getFilenameFile Path)+ ".fbx"
		ExportFBX MyObjects Path
	),

	fn Generate_HKT SrcPath DestPath = 
	( 
		-- 1. generate an readable HKT from exprted .fbx	
		MyVRageLog.Info "Starting Fbximport.exe " 
		TmpHktPath =" \"" + MyVRageCfg.PathToolsFolder +  "\\Temp\\Tmp.hkt" + "\""
		SrcPath = " \"" + SrcPath + " \"" 
		Logdata = Dos_Command.run MyVRageCfg.PathFBXImporter arg_array:#(SrcPath,TmpHktPath)
		
		Tool_Success = 0
		for i = 1 to Logdata.count do 
		(
			MyVRageLog.Info Logdata[i]
			if matchPattern Logdata[i]  pattern: "Saved tag file:*" do Tool_Success = 1
		)			
		
		if  Tool_Success == 0 do
		(
			LogMessage = "FBXimporter Failed to Export:  " + TmpHktPath
			MyVRageLog.Error LogMessage
			return -1
		)
		-- 2. Generate an binary hkt from the readable hkt
		MyVRageLog.Info ("Starting hctStandAloneFilterManager "  + DestPath)
		PathHavokConfig = " \"" + GetDir #userScripts + "\\VRageToolbox\\Vrage_Havok\\VRage_FilterConfig.hko" + "\""
		Program = MyVRageCfg.PathHavokContentTools + "\\hctStandAloneFilterManager.exe"

		DestPath = " \"" + DestPath + " \"" 
		Logdata = Dos_Command.run Program arg_array:#("-t","-s", PathHavokConfig, "-p", DestPath, TmpHktPath)
		Tool_Success = 0

		for i = 1 to Logdata.count do 
		(
			MyVRageLog.Info Logdata[i]
			if matchPattern Logdata[i]  pattern: "*0 Errors*" do Tool_Success = 1
		)

		if  Tool_Success == 0 do
		(
			LogMessage = "hctStandAloneFilterManager Failed to Export:  " + DestPath
			MyVRageLog.Error LogMessage
			return -1
		)
		return 1
	),
	
	fn ExportCollision MyObjects  DestPath = 
	(		
		-- here we also want to check if all selected objects are indeed rigid bodies
		for obj in MyObjects do (

			if isProperty obj #hkTypeRigidBody  then ( 	continue)
			else (
				MyVRageLog.Warn ("Object is not a Havok Collider " + obj.name) 
			) 
		) 

		if MyObjects.count > 10 do MyVRageLog.Warn ("More than 10 Collisionshapes in " + LayerManager.current.name ) 
		-- set pivto of objs to world origin , needed for havok
		MyObjects.pivot = [0,0,0]

		--1. Export an FBX with the Collision Data
		ExportFBX MyObjects (TempDirHKT + @"\Tmp_HKT.fbx")

		-- set pivot of objs to their own center, kinda reverting the step from before.
		for obj in MyObjects do obj.pivot = obj.center

		--2. Generate Havok .hkt file from the Fbx
		Error =  Generate_HKT (TempDirHKT + @"\Tmp_HKT.fbx") (DestPath +  ".hkt")
		MyVRageLog.Info ("VRageExp_Generate_HKT exited with Code: " +  Error as string  + "   (1 = success, -1= fail)")
		return Error
	),
	
	fn Generate_MWM SrcPath Destpath = 
	(
		--MwmBuilder  /o:".\out" /l:".\out\log.log" /x:"E:\Steam\SteamApps\common\SpaceEngineersModSDK\OriginalContent\Materials" /showWarnings /e /f 
		MyVRageLog.Info "Starting MwmBuilder.exe" 
		Materialspath =  "\"" + MyVRageCfg.PathModSDK + "\\OriginalContent\\Materials" + "\""
		Logdata = Dos_Command.run MyVRageCfg.PathMwmBuilder arg_array:#("/s:\"" + SrcPath + "\"", "/x:" + Materialspath, "/o:" + Destpath + " ", "/f","/e","/gss")
		
		Tool_Success = 0
		for i = 1 to Logdata.count do 
		(
			MyVRageLog.Info Logdata[i]
			if matchPattern Logdata[i]  pattern: "Finished :*" do Tool_Success = 1
		)			
		
		if  Tool_Success == 0 do
		(
			LogMessage = "MwmBuilder Failed to Export:  " + Destpath
			MyVRageLog.Error LogMessage
			return -1
		)
		MyVRageLog.Info ("MwmBuilder succesfully exported to: " + Destpath) Show: false
		return 1
	),

	fn Export_ALayer = 
	( -- deprecated
		TmpFileDir = MyVRageCfg.PathToolsFolder + @"\Temp" --Tempfolder for hkt creation
		TmpFileDir2 = MyVRageCfg.PathToolsFolder + @"\Temp\Expo\Content\Models"  -- Basically folder for mwmbuilder
		try ( makedir TmpFileDir )	catch (	 MyVRageLog.Error ("Permission Error while trying to create: " + TmpFileDir) )
		try ( makedir TmpFileDir2 )	catch (	 MyVRageLog.Error ("Permission Error while trying to create: " + TmpFileDir2) )
		
		MyVRageLog.Info ("Starting Export to "  + Filepath) Show: true

		--1. Get the Layers correctly ( Main Model , Lod1-n , Construction1-n, Collsion Layer, Mountpoints, Dummies  )
		deselect selection

		Destpath = Filepath + "\\" + Filename 
		--2. Export the Main Model  Lod0 and dummies
		DestPathModel = TmpFileDir2 + @"\" + Filename +  ".fbx"

		Layer = Vrage_SetLayerbyName("#TestLayer")
		if Layer == undefined then (
			MyVRageLog.Error ("Testlayer not found ") 
			return -1
		)
		Layer.select true;
		myObjs = selection as array
		ExportModel myObjs DestPathModel 
		deselect selection

		--3. Export Collision
		TmpFilePath = TmpFileDir + @"\Tmp_HKT.fbx"
		DestPathCol = TmpFileDir2 + @"\" + Filename +  ".hkt"
		
		Layer = Vrage_SetLayerbyName("Collision")
		if Layer == undefined then (
			MyVRageLog.Error ("Collision Layer not found ") 
			return -1
		)
		Layer.select true;


		CollisionObjs = selection as array
		--print CollisionObjs
		Error = ExportCollision  CollisionObjs TmpFilePath DestPathCol
		if Error == 1 then MyVRageLog.Info ("Successfully Exported Collision "  + DestPathCol) Show: false else MyVRageLog.Error ("Failed Collsion export "  + DestPathCol)


		--4.Build MWM'S
		Error = Generate_MWM TmpFileDir2 Filepath
		if Error == 1 then MyVRageLog.Info ("Successfully build Model "  + Filepath) Show: true else MyVRageLog.Error ("Failed Model Build "  + Filepath)

	),

	fn Export_LODs TheMainLayer  = 
	(
		TheMainName = TheMainLayer.Name
		TheLods = VRLayers.GetChildofType TheMainLayer (VRLayers.LOD) 	
		if (TheLods.count == 0) then (MyVRageLog.Warn ("Export: No Lods found. Nothing will be exported") ) 
		if (TheLods.count > 0) then 
		(
			-- Get the Lod Distances
			TheLodDistances = #()
			TheLodDistances.count = TheLods.count
			for OneLod in TheLods do 
			(	
				tmplod = OneLod.layerAsRefTarg
				TheLodDistances[tmplod.VrageLayer_LODData.LODID +1] = tmplod.VrageLayer_LODData.DrawDistance
			)

			-- Get the objs in Lod and export to fbx
			for OneLod in TheLods do 
			(	
				OneLod.ishidden = false
				OneLodObjs = VRLayers.GetObjsOfLayer OneLod
				-- Lod 0 is special. No Lod in name and dummies and collision included
				if (OneLod.layerAsRefTarg).VrageLayer_LODData.LODID == 0 then 
				(	
					TheName = TheMainName
					Create_MWM_XML TheName (GetObjsMats OneLodObjs) TempDirModels LodData:TheLodDistances
				)
				else 
				(
					TheName = TheMainName +"_LOD" + ((OneLod.layerAsRefTarg).VrageLayer_LODData.LODID as string) 
					Create_MWM_XML TheName (GetObjsMats OneLodObjs) TempDirModels			
				)
				print ( OneLod.name + "::" +  (OneLodObjs.count as string) )
				
				ExportModel OneLodObjs (TempDirModels + "\\" + TheName)
			)
		)
	),

	fn Export_Constructions TheArrayLayer TheMainName CollisionPath:undefined = 
	(
		TheConstructions = VRLayers.GetChildofType TheArrayLayer (VRLayers.Construction) 

		for CurrentConst in TheConstructions do 
		(
			if (CollisionPath != undefined) then 
			(--try copying the collision from main Model to construction.
				try(copyFile (CollisionPath + ".hkt") (TempDirModels +  "\\" + CurrentConst.name + ".hkt") ) catch()
			) 
			Export_LODs CurrentConst
		)
	),

	fn Export_MainType TheMainLayer  =
	(--must be recursive for subparts later!!
		TheMainName = TheMainLayer.Name
		TheName = ""
		CollisionFilePath = undefined
		--1. Get Collision Layer and set as current Collision
		CurrentCollision = VRLayers.GetChildofType TheMainLayer (VRLayers.Collision) 
		if (CurrentCollision.count == 0) then (MyVRageLog.Warn ("Export: No Collision found. Standard Cube will be set.") ) 
		if (CurrentCollision.count > 0) then 
		(
			CollisionObjs =  VRLayers.GetObjsOfLayer CurrentCollision[1]
			Error = ExportCollision CollisionObjs  (TempDirModels +  "\\" + TheMainName)
			if Error == 1 then MyVRageLog.Info ("Successfully Exported Collision "  + TheMainName) Show: false else MyVRageLog.Error ("Failed Collsion export "  + TheMainName)
			if Error == 1 then CollisionFilePath = (TempDirModels +  "\\" + TheMainName)
		)
		--2. Find all LOD layers --> also write the distances etc for xmls 
		Export_LODs TheMainLayer

		--4. Find Lods in ConstructionLayer  --> as lods above.
		CurrentConstructionArray = VRLayers.GetChildofType TheMainLayer (VRLayers.ConstructArray)
		if (CurrentConstructionArray.count == 0) then (MyVRageLog.Info ("Export: No Construction found.") ) 
		if (CurrentConstructionArray.count > 0) then Export_Constructions CurrentConstructionArray[1] TheMainName  CollisionPath:CollisionFilePath

		--5. Find the subparts --> call itself.

	),

	fn Export Selection:undefined = 
	(
		SetTempDirs()
		TheObjectArray = #()
		if Selection != undefined then 
		(
			if IsMainType Selection then  TheObjectArray = Selection	-- check if its a block or stuff
		)
		else 
		(
			TheObjectArray = VRLayers.FindMainTypes()	-- find valid layers
		)
		try(deselect $selection) catch()

		if TheObjectArray.count == 0 then MyVRageLog.Error ("Export: No Valid MainType found") 
		else
		(

			for TheMain in TheObjectArray do 
			(
				Export_MainType TheMain
			)
	
			Error = Generate_MWM TempDirModels Filepath
			if Error == 1 then MyVRageLog.Info ("Successfully build Model "  + Filepath) Show: true else MyVRageLog.Error ("Failed Model Build "  + Filepath)
		)

	),

	fn ShowUI = 
	(

		rollout rollExpUI "VRage Export Scene" width:400 height:200
		(
			button Btn_export "Export" width:200 height:40 toolTip:"Generates  MWM file/s from the selected Block/s" align:#center  across:2
			--button Btn_exportsel "Export Selected only" width:200 height:40 toolTip:"Generates  MWM file/s from the selected Block/s" align:#center 
			
			on Btn_export pressed do 
			(
				Expo = VRageExporter Filepath:((VrageScene.get()).ModDir) 
				Expo.Export()
			)
		--	on rollExpUI open do ()
		)

		try (cui.UnRegisterDialogBar ExportUI) catch () 
		try (DestroyDialog  ExportUI) catch ()

		ExportUI = newRolloutFloater "VRAGE Scene Settings" 500 200
		addRollout rollExpUI ExportUI
		addRollout (VrageScene.GetExportRollout()) ExportUI

		cui.RegisterDialogBar ExportUI  style:#(#cui_floatable)
	)
)





