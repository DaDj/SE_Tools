::start "" "MwmBuilder.exe" /p /args
 
MwmBuilder  /o:".\out" /l:".\out\log.log" /x:"E:\Steam\SteamApps\common\SpaceEngineersModSDK\OriginalContent\Materials" /showWarnings /e /f 


GOTO EndComment1

Usage: MwmBuilder.exe [/s:SOURCE] [/o:OUTPUT] [/m:MASK] [/l:LOGFILE] 
		[/t:THREADS] [/e] [/a] [/u] [/f] [/g] [/checkOpenBoundaries] [/p] [/d:LODS]
    SOURCE - Path to source FBX file(s), directory or file. Directories are readrecursively. Defaults to current directory.
    OUTPUT - Path to output
    MASK - File mask of files to process, defaults to *.FBX
    LOGFILE - Path to logfile
    THREADS - Run model build on several threads
    /e - Force XML export
    /a - Split logfile to separate errors and warnings to separate logfiles .warn log and .err log
    /u - Log file when file is up to date
    /f - Rebuild files even when up-to-date
    /g - Don't compare app build date to files
    /checkOpenBoundaries - Warn if model contains open boundaries
    /p - Wait for key after build
    LODS - Float values separated by space, defining default values for LOD 1-n

:EndComment1