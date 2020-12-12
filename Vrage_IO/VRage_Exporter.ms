


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

	fn ExportFBX DestPath =
	(
		pluginManager.loadClass FbxExporter
		FBXSettings()

		exportFile (DestPath) #noprompt selectedOnly:on using:FBXEXPORTER  
	),

	fn ExportModel Path =
	(
		--Path = Path + ".fbx"
		ExportFBX Path
	),

	fn Generate_HKT SrcPath DestPath = ( 
		-- 1. generate an readable HKT from exprted .fbx	
		MyVRageLog.Info "Starting Fbximport.exe " 
		TmpHktPath =" \"" + GetDir #plugcfg +  "\\VRageUtilities\\Temp\\Tmp.hkt" + "\""
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
	
	fn ExportCollision TmpFilePath DestPath = (		

		Layer = Vrage_SetLayerbyName("Collision")
		if Layer == undefined then (
		 MyVRageLog.Error ("Collision Layer not found ") 
			return -1
		)
		Layer.select true;
		-- here we also want to check if all selected objects are indeed rigid bodies
		for obj in selection do (

			if isProperty obj #hkTypeRigidBody  then ( 	continue)
			else (
				MyVRageLog.Error ("Object is not a Havok Collider " + obj.name) 
				return -1
			) 
			-- objcasnames = for ca in (custattributes.getdefs obj) collect ca.name
			-- if finditem objcasnames "rigidbody" > 0 then ( 
			-- 	continue
			-- )
			-- else (
			-- 	myvragelog.error ("object is not a havok collider " + obj.name) 
			-- 	return -1
			-- )
		) 

		--1. Export an FBX with the Collision Data
		ExportFBX TmpFilePath


		--2. Generate Havok .hkt file from the Fbx
		Error =  Generate_HKT TmpFilePath DestPath 
		MyVRageLog.Info ("VRageExp_Generate_HKT exited with Code: " +  Error as string  + "   (1 = success, -1= fail)")
		return Error
	),
	

	fn Generate_MWM = (
		---\MwmBuilder.exe  /o:".\out" /l:".\out\log.log" /x:"E:\Steam\SteamApps\common\SpaceEngineersModSDK\OriginalContent\Materials" /showWarnings /e /f
		---\MwmBuilder.exe  /o:".\out" /l:".\out\log.log" /x:"(MyVRageCfg.ModSDK + \\OriginalContent\\Materials)" /showWarnings /e /f
		
	),

	fn Export = (
		--1. Get the Layers correctly ( Main Model , Lod1-n , Construction1-n, Collsion Layer, Mountpoints, Dummies  )


		TmpFileDir = MyVRageCfg.VRageConfigDir + @"\Temp" --Tempfolder for hkt creation
		TmpFileDir2 = MyVRageCfg.VRageConfigDir + @"\Temp\Expo\Content\Models"  -- Basically folder for mwmbuilder
		try ( makedir TmpFileDir )	catch (	 MyVRageLog.Error ("Permission Error while trying to create: " + TmpFileDir) )
		try ( makedir TmpFileDir2 )	catch (	 MyVRageLog.Error ("Permission Error while trying to create: " + TmpFileDir2) )
		
		Destpath = Filepath + "\\" + Filename 
		--2. Export the Main Model  Lod0 and dummies
		DestPathModel = TmpFileDir2 + @"\" + Filename +  ".fbx"
		ExportModel DestPathModel 

		
		--3. Export Collision
		TmpFilePath = TmpFileDir + @"\Tmp_HKT.fbx"
		DestPathCol = TmpFileDir2 + @"\" + Filename +  ".hkt"
		Error = ExportCollision TmpFilePath DestPathCol
		if Error == 1 then MyVRageLog.Info ("Successfully Exported Collision "  + DestPathCol) else MyVRageLog.Error ("Failed Collsion export "  + DestPathCol)


		--4.Build MWM'S
	

	)

)


	
	

	