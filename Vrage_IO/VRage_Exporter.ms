	
fn VRageExp_FBXSettings =
	(
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
	)
	
	--OpenFbxSetting()
	fn VRageExp_ExportModel =
	(
		SourcePath = @"C:\Users\patgr\Desktop\test.FBX"
		VRageExp_ExportFBX SourcePath
	)
	
	fn VRageExp_ExportFBX DestPath =
	(
		pluginManager.loadClass FbxExporter
		VRageExp_FBXSettings()

		exportFile (DestPath) #noprompt selectedOnly:on using:FBXEXPORTER  
	)
	
	fn VRageExp_Collision =
	(		SourcePath = "C:\Users\patgr\Desktop\hkt.FBX"
			DestPath =  "C:\\Users\\patgr\\Desktop\\test.hkt"
		--1. Export an FBX with the Collision Data
			VRageExp_ExportFBX SourcePath
		--2. Generate Havok .hkt file from the Fbx


		Error = VRageExp_Generate_HKT SourcePath DestPath
		VrageLog.Info ("VRageExp_Generate_HKT exited with Code: " +  Error as string  + "   (1 = success, -1= fail)")
	)
	
	fn VRageExp_Generate_HKT SrcPath DestPath =
	( 
	-- 1. generate an readable HKT from exprted .fbx	
		VrageLog.Info "Starting Fbximport.exe " 
		
		TmpHktPath =" \"" + GetDir #plugcfg +  "\\VRageUtilities\\Tmp.hkt" + "\""
		Logdata = Dos_Command.run MyVRageCfg.PathFBXImporter arg_array:#(SrcPath,TmpHktPath)
		
		Tool_Success = 0
		for i = 1 to Logdata.count do 
		(
			VrageLog.Info Logdata[i]
			if matchPattern Logdata[i]  pattern: "Saved tag file:*" do Tool_Success = 1
		)			
	
		if  Tool_Success == 0 do
		(
			LogMessage = "FBXimporter Failed to Export:  " + TmpHktPath
			VrageLog.Error LogMessage
			return -1
		)

		 
	-- 2. Generate an binary hkt from the readable hkt
		VrageLog.Info ("hctStandAloneFilterManager "  + DestPath)
		PathHavokConfig = " \"" + GetDir #userScripts + "\\VRageToolbox\\Vrage_Havok\\VRage_FilterConfig.hko" + "\""
		Program = MyVRageCfg.PathHavokContentTools + "\\hctStandAloneFilterManager.exe"

		Logdata = Dos_Command.run Program arg_array:#("-t","-s", PathHavokConfig, "-p", DestPath, TmpHktPath)
		Tool_Success = 0

		for i = 1 to Logdata.count do 
		(
			VrageLog.Info Logdata[i]
			if matchPattern Logdata[i]  pattern: "*0 Errors*" do Tool_Success = 1
		)

		if  Tool_Success == 0 do
		(
			LogMessage = "hctStandAloneFilterManager Failed to Export:  " + DestPath
			VrageLog.Error LogMessage
			return -1
		)
		return 1
	)
	
	fn VRageEXP_Generate_MWM =
	(
		---\MwmBuilder.exe  /o:".\out" /l:".\out\log.log" /x:"E:\Steam\SteamApps\common\SpaceEngineersModSDK\OriginalContent\Materials" /showWarnings /e /f
		---\MwmBuilder.exe  /o:".\out" /l:".\out\log.log" /x:"(MyVRageCfg.ModSDK + \\OriginalContent\\Materials)" /showWarnings /e /f
		
	)