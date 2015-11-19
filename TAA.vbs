' --------------------------------------------------------------------------------
' 
'     Objetivo: Inicializar o sistema TAA.
'		Verificar se o sistema TAA está em execução.
'		Verificar se o sistema possui foco.
'
'	  Data: 25/01/2010
'        Autor: Henrique
' 
'   Observação: Verifica se o processo prowc.exe está em execução.
'		Caso não, finaliza os processos P32 e inicia o sistema.
'		A cada 2 minutos, verifica se a aplicação possui foco.
'
'   Alterações:
'   
'   11/03/2015 - Efetuar restart no serviço Diebold Devices Service [Dionathan]                   
'   
' --------------------------------------------------------------------------------

Set WshShell = WScript.CreateObject("WScript.Shell")
Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")

DO WHILE 1 = 1
	' Busca os processos.
	Set colPro =  objWMIService.Execquery ("SELECT * FROM Win32_Process WHERE caption = 'prowc.exe'")
	Set colP32 =  objWMIService.Execquery ("SELECT * FROM Win32_Process WHERE caption = 'P32*'")
	
	qryAmi = "SELECT * FROM Win32_Service WHERE Name = 'AMI Data Recorder Service'"	
	Set colAmi =  objWMIService.Execquery (qryAmi)
	
	qryDbd = "SELECT * FROM Win32_Service WHERE Name = 'Diebold Devices Service'"
	Set colDbd =  objWMIService.Execquery (qryDbd)
			
	verifica = FALSE
	' Verifica se o processo prowc está em execução.
	For each processo in colPro
		verifica = TRUE
	NEXT

	' Caso o prowc estiver fechado, finaliza os processos dos dispositivos 
	' e inicializa o sistema.
	IF NOT verifica THEN
		FOR EACH diebold IN colP32
			diebold.Terminate()
		NEXT
		
		WshShell.Run "SC.exe failure ""diebold devices service"" reset= 86400 actions= /1000"
		
		qrySC = "SELECT * FROM Win32_Process WHERE caption = 'SC.exe'"		
		DO UNTIL objWMIService.ExecQuery(qrySC).Count > 0								
			WScript.Sleep 100
		LOOP
		
		' Reinicia o processo Diebold Devices
		FOR EACH dbd IN colDbd						
			' Reinicia o processo AMI Data Recorder
			iniciaAMI = FALSE
			FOR EACH ami IN colAmi										
				IF ami.State = "Running" THEN				
					WshShell.Run "net stop ""AMI Data Recorder Service"""									
					iniciaAMI = TRUE
				END IF				
				
				DO UNTIL objWMIService.ExecQuery(qryAmi & " AND State='Stopped'").Count > 0								
					WScript.Sleep 100
				LOOP				
			NEXT							
						
			IF dbd.State = "Running" THEN
				WshShell.Run "net stop ""Diebold Devices Service"""				
			END IF
			
			DO UNTIL objWMIService.ExecQuery(qryDbd & " AND State='Stopped'").Count > 0			
				WScript.Sleep 100				
			LOOP	
											
			WshShell.Run "net start ""Diebold Devices Service"""						
			
			IF iniciaAMI THEN
				FOR EACH ami IN colAmi
					WshShell.Run "net start ""AMI Data Recorder Service"""					
				NEXT
			END IF						
		NEXT
		
		' Limpa arquivos criados pelo Progress
		' Executa o "CMD" e encerra ("/c") passando os comandos como parametro
		WshShell.Run "cmd /c del lbia* & del rcda* del srta* del DBI*"
		
		' Inicializa o Sistema TAA
		WshShell.Run "C:\Arquiv~1\Progre~1\WebClient\bin\prowc.exe -p taa.r"		
	END IF
	
	' A cada 2 minutos verifica o foco.
	foco = Minute(Now()) MOD 2
	IF foco = 0 THEN
		' Executa o "CMD" e encerra ("/c") passando o "START" como parametro
		' sem criar nova janela ("/b") executando o script oculto (",0")
		WshShell.Run "cmd /c start /b foco.vbs",0
	END IF
	
	' Aguarda 1 minuto para executar novamente.
	WScript.sleep 60000	
	LOOP