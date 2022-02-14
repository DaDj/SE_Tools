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
		Outputdir =  "\"" + MyVRageCfg.PathTextures + "\Textures" + "\""

		
		--Answer = Dos_Command.run Program arg_array:#(SETextureDir , MyVRageCfg.PathTextures , @"\Models", @"\BackgroundCube", @"\Particles" )
		arg_array = #( SETextureDir ,Outputdir, @"\Models", @"\BackgroundCube", @"\Particles" )
		MyStartARg = ""
		for arg in arg_array do ( MyStartARg += ( " " + arg as string ) )
		ShellLaunch Program MyStartARg
	)
)