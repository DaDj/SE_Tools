/*
Handles texture I/O :
- Generating .dds ICONS
- Converting .dds Materials as in ng,cm etc. dds files !!!todo!
*/

fn VrageTextureIO_ConvertSEtoReadable =
(-- Calls the Textureconverter consoleapp which converts the SE textures to tif for 3dsmax use.

	Program = MyVRageCfg.VRageScriptsDir + "\\Vrage_Tools\\SETexconv\\TextureConverter.exe" 
	if MyVRageCfg.PathTextures == undefined then 
	(
		-- implement error handling for missing here
	)
	if Program != undefined and MyVRageCfg.PathTextures != undefined and MyVRageCfg.PathTextures != "" then 
	(
		MyVRageLog.Info ( "Starting textureconversion" ) Show: false
		SETextureDir = "\"" + MyVRageCfg.PathGame + "\Content\Textures" + "\""
		Outputdir = "\"" + MyVRageCfg.PathTextures + "\Textures" + "\""

		arg_array = #( SETextureDir , Outputdir, @"\Models", @"\BackgroundCube", @"\Particles" )
		--	MyStartARg = ""
		--	for arg in arg_array do ( MyStartARg += ( " " + arg as string ) )
		--	ShellLaunch Program MyStartARg
		
		local process = dotNetObject "System.Diagnostics.Process"
		process.StartInfo.FileName = Program
		process.StartInfo.Arguments = ""
		
		if arg_array != undefined then
		(
			for arg in arg_array do ( process.StartInfo.Arguments += ( " " + arg as string ) )
		)
		process.Start()
		process.WaitForExit()
		answer = process.ExitCode
		process.Close()
		process.Dispose()

		if answer == 2 then 
		(
			MyVRageLog.Info ( "Texture conversion successfully finished" ) Show: false
		)
		else if answer == 4 then
		(
			MyVRageLog.Error ( "Texture conversion couldn't find command paths." ) Show: true
		)
		else 
		(
			MyVRageLog.Warn ( "Texture conversion didn't finish properly!" ) Show: true
		)
		
		answer
	)
)