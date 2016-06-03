' ----------------------------------------------------------
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
' ----------------------------------------------------------

Set WshShell = WScript.CreateObject("WScript.Shell")
Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")

DO WHILE 1 = 1
	' Busca os processos.
	Set colPro =  objWMIService.Execquery ("select * from Win32_Process where caption = 'prowc.exe'")
	Set colP32 =  objWMIService.Execquery ("select * from Win32_Process where caption = 'P32*'")
	
	verifica = FALSE
	' Verifica se o processo prowc está em execução.
	For each processo in colPro
		verifica = TRUE
	Next

	' Caso o prowc estiver fechado, finaliza os processos dos dispositivos 
	' e inicializa o sistema.
	IF NOT verifica THEN
		FOR EACH diebold IN colP32
			diebold.Terminate()
		Next
		
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