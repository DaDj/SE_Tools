



Vrage_Logfile =  VRageConfigDir + "\\Info.log"
deletefile Vrage_Logfile
logsystem.logName Vrage_Logfile
logsystem.logEntry "Start Logging" debug:1 info:0 warning:0 error:0


rollout Rollout_VrageLog "VRage Utilies Log" width:900 height:500
(
	button btn_ClearLog "Clear Log" width:120 height:25 toolTip:"Clears the Logfile " align:#center
	on btn_ClearLog pressed do
	(		
		deletefile Vrage_Logfile
		logsystem.logEntry "Start Logging" debug:1 info:0 warning:0 error:0
		VRageLog_Show()
	)	
	
	dotNetControl textboxctrl "System.Windows.Forms.TextBox" width:850 height:450 align: #center
	
timer clock "testClock" interval:1000 --tick  every 2 sec
  on clock tick do
  (
	fs = openFile Vrage_Logfile
	  textboxctrl.text  = "";
	while not eof fs do
		( 
			Theline = readline fs
			Tmp = filterstring Theline " "
			--MyNewHeader = Tmp[1] + " | " + Tmp[2]  + " | " + Tmp[3]      
			MyNewHeader =  Tmp[2]  + " | " + Tmp[3]      
			MyNewText = ""
			for i = 6 to Tmp.count do MyNewText = MyNewText + " " + Tmp[i] 
			--2020/11/28 22:25:35 WRN: [08532] [07356] What the  actual thing ist this  
			textboxctrl.text =  MyNewHeader  +  MyNewText +"\r\n\r\n" + textboxctrl.text 
		)
		close fs
-- 		textboxctrl.SelectionStart = textboxctrl.Text.count;
-- 		textboxctrl.ScrollToCaret();
  )
	
	
	on Rollout_VrageLog open do
	(
	textboxctrl.AcceptsReturn = true;
	textboxctrl.AcceptsTab = true;
	textboxctrl.WordWrap = false;
	textboxctrl.Multiline = true;
	textboxctrl.ScrollBars = textboxctrl.ScrollBars.vertical;
	)
)


struct VrageLogSys
(

	fn Info Data =
	(
		logsystem.logEntry Data debug:0 info:1 warning:0 error:0
	),
	
	fn Warn Data =
	(
		logsystem.logEntry Data debug:0 info:0 warning:0 error:1
		messagebox  Data title:"Warning"
		Showlog()
	),

	fn Error Data =
	(
		logsystem.logEntry Data debug:0 info:0 warning:0 error:1
		messagebox  Data  title:"Error"
		Showlog()
	)
)




fn VRageLog_Show =
(
		try (closeRolloutFloater LogFloater) catch () 
	LogFloater = newRolloutFloater  "VRage Utilies Log" 900 520 
	addRollout Rollout_VrageLog LogFloater
)
		try (closeRolloutFloater LogFloater) catch () 
	LogFloater = newRolloutFloater  "VRage Utilies Log" 900 520 
	addRollout Rollout_VrageLog LogFloater



VRageLog =VrageLogSys()









