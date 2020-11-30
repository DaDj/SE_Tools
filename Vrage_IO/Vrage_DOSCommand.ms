
/*  
Example: 

python = SystemTools.GetEnvVariable "PYTHONPATH"
Dos_Command.run python arg_array:#("C:\path\to\script.py", "--argument 1.0", "-verbose")

*/

global Dos_Command
struct DOSCMD (
    fn run exe_path arg_array:undefined as_string:false =
    (
        local process = dotNetObject "System.Diagnostics.Process"

        process.StartInfo.UseShellExecute = false
        process.StartInfo.RedirectStandardOutput = true
        process.StartInfo.RedirectStandardError = true
        process.StartInfo.FileName = exe_path
        process.StartInfo.Arguments = ""
        
        if arg_array != undefined then
        (
        	for arg in arg_array do (process.StartInfo.Arguments += (" " + arg as string))
        )

        process.Start()
        process.WaitForExit()

        local _output = process.StandardOutput.ReadToEnd()
        local _error = process.StandardError.ReadToEnd()

        process.Close()
        process.Dispose()
        
        if _error == "" then
        (
            if as_string then return (trimRight _output "\r\n")
            else return (filterString _output "\r\n" splitEmptyTokens:false)
        )
        else
        (
            if as_string then return (trimRight _error "\r\n")
            else return (filterString _error "\r\n" splitEmptyTokens:false)
        )
    )
)
if Dos_Command == undefined then Dos_Command = DOSCMD()