/* .............................................................................

   Programa: Includes/listafun.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Desconhecido
   Data    :      /  .                           Ultima atualizacao: 02/06/2014
     
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : 

   Alteracoes: 01/09/2008 - Alteracao cdempres (Kbase IT) - Eduardo Silva.
   
               11/05/2009 - Alteracao CDOPERAD (Kbase).
               
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).

			   08/12/2016 - P341-Automatização BACENJUD - Realizar a validação 
			                do departamento pelo código do mesmo (Renato Darosci)
............................................................................ */

DEF VAR aux_server   AS CHAR                                    NO-UNDO.

IF   (CAN-DO("11,50",STRING(aux_cdempres)))  AND 
     (glb_nmoperad <> crapass.nmprimtl)      AND
     (glb_cddepart <> 20)   /* TI */         THEN
     DO:
         DEF VAR aux_terminal AS CHAR FORMAT "x(20)".

         INPUT THROUGH basename `tty` NO-ECHO.

            SET aux_terminal WITH FRAME f_lista.
                
         INPUT CLOSE.

         INPUT THROUGH basename `hostname -s` NO-ECHO.
         IMPORT UNFORMATTED aux_server.
         INPUT CLOSE.
         
         aux_terminal = substr(aux_server,length(aux_server) - 1) +
                               aux_terminal.

         UNIX SILENT VALUE("echo " + STRING(YEAR(glb_dtmvtolt),"9999") +
                            STRING(MONTH(glb_dtmvtolt),"99") +
                            STRING(DAY(glb_dtmvtolt),"99") + " " +
                            STRING(glb_cdoperad,"x(10)")  + " " +
                            STRING(glb_nmoperad,"x(15)") + " " + 
                            STRING(crapass.nrdconta,"99999999") + ' "' +
                            STRING(crapass.nmprimtl,"x(15)") + '" ' +
                            STRING(TIME,"HH:MM:SS") + " " +
                            STRING(aux_terminal,"x(15)") + " " +
                            STRING(PROGRAM-NAME(1),"x(30)") +
                            " >> arq/.acessos.dat").
     END.
 
