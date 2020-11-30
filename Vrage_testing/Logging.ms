
Vrage_Logfile = "c:\\extra3.log"
deletefile Vrage_Logfile
logsystem.logName Vrage_Logfile
logsystem.logEntry "Start Logging" debug:1 info:0 warning:0 error:0



rollout Rollout_VragLog "VRage Utilies Log" width:900 height:500
(
	
	
	button btn_ClearLog "Clear Log" width:120 height:25 toolTip:"Clears the Logfile " align:#center
	on btn_ClearLog pressed do
	(		
		deletefile Vrage_Logfile
		logsystem.logEntry "Start Logging" debug:1 info:0 warning:0 error:0
		Showlog()
	)	
	
	dotNetControl textboxctrl "System.Windows.Forms.TextBox" width:850 height:450 align: #center
	
	on Rollout_VragLog open do
	(
	textboxctrl.AcceptsReturn = true;
	textboxctrl.AcceptsTab = true;
	textboxctrl.WordWrap = false;
	textboxctrl.Multiline = true;
	textboxctrl.ScrollBars = textboxctrl.ScrollBars.vertical;
		
	fs = openFile Vrage_Logfile
	while not eof fs do
		(
			Theline = readline fs
		
			Tmp = filterstring Theline " "

			
			--MyNewHeader = Tmp[1] + " | " + Tmp[2]  + " | " + Tmp[3]      
			MyNewHeader =  Tmp[2]  + " | " + Tmp[3]      
			MyNewText = ""
			for i = 6 to Tmp.count do MyNewText = MyNewText + " " + Tmp[i] 
			

			
			--2020/11/28 22:25:35 WRN: [08532] [07356] What the  actual thing ist this  
			textboxctrl.text = textboxctrl.text + MyNewHeader  +  MyNewText +"\r\n\r\n"
		)
		close fs
	)

)

--showmethods (dotNetObject "TextBox")


fn Vrage_LogWarning Data =
(
	logsystem.logEntry Data debug:0 info:0 warning:0 error:1
	messagebox  Data title:"Warning"
	Showlog()
)

fn Vrage_LogError Data =
(
	logsystem.logEntry Data debug:0 info:0 warning:0 error:1
	messagebox  Data  title:"Error"
	Showlog()
)



fn Showlog = 
(
try (closeRolloutFloater LogFloater) catch () 
LogFloater = newRolloutFloater  "VRage Utilies Log" 900 520 
addRollout Rollout_VragLog LogFloater
	)






