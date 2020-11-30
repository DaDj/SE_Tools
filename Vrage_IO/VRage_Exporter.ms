	
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
	FBXExporterSetParam "AxisConversionMethod" "None"
	FBXExporterSetParam "UpAxis" "Y" 
	--UI----------------------------------------------------------------
	FBXExporterSetParam "ShowWarnings" true
	FBXExporterSetParam "GenerateLog" false
	--FBX File Format----------------------------------------------------------------
	FBXExporterSetParam "ASCII" true
	FBXExporterSetParam "FileVersion" "FBX201300"
	)
	
	--OpenFbxSetting()
	
	
	fn VRageExp_ExportFBX =
	(
		pluginManager.loadClass FbxExporter
		VRageExp_FBXSettings()
		exportFile (theFileName) #noprompt selectedOnly:on using:FBXEXPORTER  
	)
	
	fn VRageExp_Collision =
	(
		-- VRageExp_ExportFBX
		-- VRageExp_Generate_HKT
	)
	
	fn VRageExp_Generate_HKT SrcPath DestPath =
	( 
	-- 1. generate an readable HKT from exprted .fbx	
		logsystem.logEntry "Starting Fbximport.exe " debug:0 info:1 warning:0 error:0	
		
		Logdata = Dos_Command.run VRageCfg.PathFBXImporter arg_array:#("C:\Users\patgr\Desktop\hkt.FBX", "C:\\Users\\patgr\\Desktop\\result.hkt")
		
		Tool_Success = 0
		for i = 1 to Logdata.count do 
		(
			VrageLog.Info Logdata[i]
			 if matchPattern Logdata[i]  pattern: "Saved tag file:*" do Tool_Success = 1
			--if matchPattern Logdata[i]  pattern: "Output path:*" do	logsystem.logEntry Logdata[i] debug:0 info:1 warning:0 error:0	
		)			
		LogMessage = "FBXimporter Failed to Export:  " + "C:\\Users\\patgr\\Desktop\\result.hkt"
		if  Tool_Success == 0 do VrageLog.Error LogMessage
	
		
		 
	-- 2. Generate and bianry hkt from the readable hkt
		-- VRageCfg.PathHavokContentTools 
		
			 --"C:\\Program Files\\Havok\\HavokContentTools\\hctStandAloneFilterManager.exe"  -s "C:\\Users\\patgr\\Desktop\\SE_Config.hko" -i -o "C:\\Users\\patgr\\Desktop\\done\\" -p  "test.hkt"  "hkt.hkt"
	
	)
	
	fn VRageEXP_Generate_MWM =
	(
		
	)