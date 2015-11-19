@ECHO OFF


SET CAMINHO=\\pkgdesen\micros\cecred\TAA
SET TENTATIVA=1

:INICIO


REM --- Verifica se deve instalar ou atualizar ---
IF NOT EXIST C:\TAA (
   SET aux_operacao=INSTALAR
) ELSE (
IF NOT EXIST C:\TAA\Banco (
  SET aux_operacao=INSTALAR
) ELSE (
  SET aux_operacao=ATUALIZAR
))


IF %aux_operacao% == INSTALAR (
   ECHO Preparando Instalacao... Tentativa %TENTATIVA% de 5.
   GOTO INSTALAR
) ELSE (
   ECHO Preparando Atualizacao... Tentativa %TENTATIVA% de 5.
   GOTO ATUALIZAR
)




:INSTALAR

REM --- Apaga tudo ---
ECHO Removendo arquivos
RMDIR /S /Q C:\TAA


REM --- Cria o diretorio principal e do LOG ---
MKDIR C:\TAA
MKDIR C:\TAA\LOG






:ATUALIZAR

REM --- Posiciona no diretorio ---
CD C:\TAA


REM --- Apaga os fontes ---
ECHO Removendo arquivos
DEL /Q *.*
DEL /Q Imagens\*.*
DEL /Q procedures\*.*


REM --- Baixa o programa para descompactar ---
ECHO Baixando descompactador
XCOPY /Y /Q %CAMINHO%\unzip.exe .\


IF %aux_operacao% == INSTALAR (

   REM --- Baixa o Banco de Dados ---
   ECHO Baixando o Banco de Dados
   XCOPY /Y /Q %CAMINHO%\Banco.zip .\


   ECHO Testando o arquivo
   C:\TAA\unzip.exe -t Banco.zip > C:\TAA\teste_zip.log

   FOR /F "delims=," %%i IN (C:\TAA\teste_zip.log) DO (
       IF "%%i" EQU "No errors detected in compressed data of Banco.zip." (

          ECHO Arquivo baixado com sucesso!

          REM --- Descompacta o Banco de Dados ---
          ECHO Descompactando o Banco de Dados
          C:\TAA\unzip.exe -o Banco.zip

          REM --- Remove ZIP ---
          DEL /Q C:\TAA\Banco.zip

          GOTO ATUALIZAR2
       )
   )

   IF EXIST C:\TAA\teste_zip.log (
      DEL /Q C:\TAA\teste_zip.log
   )

   ECHO Arquivo invalido!
   SET /A TENTATIVA=%TENTATIVA% + 1

   IF %TENTATIVA% LSS 5 (
      GOTO INICIO
   ) ELSE (
      ECHO Atualizacao Abortada

      IF EXIST C:\TAA\Banco.zip (
         DEL /Q C:\TAA\Banco.zip
      )

      GOTO FIM
   )
)



:ATUALIZAR2

IF EXIST C:\TAA\teste_zip.log (
   DEL /Q C:\TAA\teste_zip.log
)

REM --- Baixa os fontes ---
ECHO Baixando os fontes
XCOPY /Y /Q %CAMINHO%\TAA.zip .\


ECHO Testando o arquivo
C:\TAA\unzip.exe -t TAA.zip > C:\TAA\teste_zip.log

FOR /F "delims=," %%i IN (C:\TAA\teste_zip.log) DO (
    IF "%%i" EQU "No errors detected in compressed data of TAA.zip." (

       ECHO Arquivo baixado com sucesso!


       REM --- Descompacta os fontes ---
       ECHO Descompactando os fontes
       C:\TAA\unzip.exe -o TAA.zip

       REM --- Remove ZIP ---
       DEL /Q C:\TAA\TAA.zip

       GOTO ATUALIZAR3
    )
)

IF EXIST C:\TAA\teste_zip.log (
   DEL /Q C:\TAA\teste_zip.log
)

ECHO Arquivo invalido!
SET /A TENTATIVA=%TENTATIVA% + 1

IF %TENTATIVA% LEQ 5 (
   GOTO INICIO
) ELSE (
   ECHO Atualizacao Abortada

   IF EXIST C:\TAA\TAA.zip (
      DEL /Q C:\TAA\TAA.zip
   )

   GOTO FIM
)


:ATUALIZAR3

IF EXIST C:\TAA\teste_zip.log (
   DEL /Q C:\TAA\teste_zip.log
)

REM --- Remove o descompactador ---
DEL /Q C:\TAA\unzip.exe

REM --- Verifica se Existe .reg de Fontes TrueType para Atualizar e executa .vbs ---
IF  EXIST "C:\TAA\Fontes - TTF\fontes101C-WebClient.reg" (
		
	CD "C:\TAA\Fontes - TTF"
		
	XCOPY /Y /Q %CAMINHO%"\Fontes - TTF\atualizaFontesTAA.vbs" .\
	
	IF  EXIST "C:\TAA\Fontes - TTF\atualizaFontesTAA.vbs" (
	
		START atuali~1.vbs
		
		:DEL_ATUALIZAFONTES
	    IF EXIST "C:\TAA\Fontes - TTF\fontes101C-WebClient.reg" (
		  GOTO DEL_ATUALIZAFONTES
	    )		
	)
	
	CD C:\TAA
	RMDIR /S /Q "C:\TAA\Fontes - TTF"
)

REM --- Coloca o atalho no inicializar ---
XCOPY /Y /Q "C:\TAA\TAA.lnk" "C:\Documents and Settings\All Users\Menu Iniciar\Programas\Inicializar"


REM --- Mensagem final ---
ECHO Operacao Concluida



REM --- Na Instalacao abre o Config automaticamente ---
IF %aux_operacao% == INSTALAR (
   :CONFIG
   IF NOT EXIST "C:\TAA\Config - TAA.exe" (
      GOTO CONFIG
   )
   
   REM --- Passa "NO" para o script nao atualizar novamente ---
   CALL "C:\TAA\Config - TAA.exe" NO
)



:FIM
EXIT
