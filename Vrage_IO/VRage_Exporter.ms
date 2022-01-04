struct VRageExporter (

	Filepath = undefined,
	Filename = undefined,

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

	fn Create_MWM_XML MyModelName DestPath =
	(

	),

	fn ExportFBX MyObjects DestPath =
	(
		pluginManager.loadClass FbxExporter
		FBXSettings()

		select MyObjects
		exportFile (DestPath) #noprompt selectedOnly:on using:FBXEXPORTER  
	),

	fn ExportModel MyObjects Path =
	(
		--Path = Path + ".fbx"
		ExportFBX MyObjects Path
	),

	fn Generate_HKT SrcPath DestPath = ( 
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
	
	fn ExportCollision MyObjects TmpFilePath DestPath = (		

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
		ExportFBX MyObjects TmpFilePath

		-- set pivot of objs to their own center, kinda reverting the step from before.
		for obj in MyObjects do obj.pivot = obj.center

		--2. Generate Havok .hkt file from the Fbx
		Error =  Generate_HKT TmpFilePath DestPath 
		MyVRageLog.Info ("VRageExp_Generate_HKT exited with Code: " +  Error as string  + "   (1 = success, -1= fail)")
		return Error
	),
	

	fn Generate_MWM SrcPath Destpath = (

		--MwmBuilder  /o:".\out" /l:".\out\log.log" /x:"E:\Steam\SteamApps\common\SpaceEngineersModSDK\OriginalContent\Materials" /showWarnings /e /f 

		MyVRageLog.Info "Starting MwmBuilder.exe" 
		Materialspath =  MyVRageCfg.PathModSDK + "\\OriginalContent\\Materials" 
		Logdata = Dos_Command.run MyVRageCfg.PathMwmBuilder arg_array:#(" \""  +  "/s:" + SrcPath + "\"", "/x:" + Materialspath, "/o:" + Destpath + " ", "/f","/e","/gss")
		
		Tool_Success = 1
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

	fn Export = (
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

	
	fn ShowUI = (

		rollout rollExpUI "VRage Export Scene" width:400 height:200
		(
			button 'Btn_export' "Export" width:200 height:40 toolTip:"Generates  MWM file/s from the selected Block/s" align:#center  across:2
			--	on Btn_export pressed do OpenVrageExport()
			button 'Btn_exportsel' "Export Selected only" width:200 height:40 toolTip:"Generates  MWM file/s from the selected Block/s" align:#center 
			on rollExpUI open do 
			(

			
			)
		)

		try (cui.UnRegisterDialogBar ExportUI) catch () 
		try (DestroyDialog  ExportUI) catch ()

		ExportUI = newRolloutFloater "VRAGE Scene Settings" 500 200
		addRollout rollExpUI ExportUI
		addRollout (VrageScene.GetExportRollout()) ExportUI

		cui.RegisterDialogBar ExportUI  style:#(#cui_floatable)

	)
	
)





