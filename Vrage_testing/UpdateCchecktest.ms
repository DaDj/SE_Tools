


thing = Dos_Command.run  "curl.exe" arg_array:#("-o C:\\Users\\patgr\\Desktop\\test3.txt https://api.github.com/repos/enenra/space-engineers-utilities/releases/latest" )
--hiddendoscommand   path_git
if doesFileExist ( "C:\\Users\\patgr\\Desktop\\test3.txt") == true do
(
	--local replaceTxt = ""
	fs = openFile  "C:\\Users\\patgr\\Desktop\\test3.txt"
	skip =  skipToString fs "\"tag_name\": \""
	if skip == undefined then (
		print "error while checking for updates. Try again later"
	)
	else if not eof fs do(
		Version = readline fs
		Version  = substituteString Version "\"" ""
		Version  = substituteString Version "," ""
		Version  = substituteString Version "v" ""
		if stricmp  Version "0.9.92" != 0 then (
			 messageBox "Newer version Found!"
			) else if stricmp  Version "0.9.92" == 0 then (
			 messageBox "VRagetoolbox is up to date"
			)
		
	)
	close fs
	
)

