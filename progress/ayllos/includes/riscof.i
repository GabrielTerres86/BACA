/* .............................................................................

   Programa: Includes/riscof.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Junho/2001                      Ultima Alteracao: 18/01/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de finalizacao da tela RISCO.


   Alteracoes: 13/11/2001 - Gerar uma unica transacao (Margarete).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando 
               
               18/01/2010 - Criacao de log para verificar a data e o usuario
                            que executou essa funcao (GATI - Daniel)
............................................................................. */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND 
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "USUARI"     AND
                   craptab.cdempres = 11           AND
                   craptab.cdacesso = "RISCOBACEN" AND
                   craptab.tpregist = 000          NO-LOCK NO-ERROR.
                   
IF   NOT AVAILABLE craptab   THEN                   
     DO:
         glb_cdcritic = 055.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '" +
                            glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.

      RUN fontes/critic.p.
      BELL.
      MESSAGE "VERIFIQUE SE MOVTOS FORAM CONTABILIZADOS".
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.

END.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
     aux_confirma <> "S" THEN
     DO:
         glb_cdcritic = 79.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         NEXT.
     END.
 
DO TRANSACTION:   
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "USUARI"       AND
                      craptab.cdempres = 11             AND
                      craptab.cdacesso = "RISCOBACEN"   AND
                      craptab.tpregist = 000            EXCLUSIVE-LOCK NO-ERROR.

   ASSIGN SUBSTR(craptab.dstextab,1,1)  = "1".
END.

UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                  " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                  "Operador " + glb_cdoperad +
                  " executou a funcao F - Finalizacao" +
                  " >> log/risco.log").
     
DISP WITH FRAME f_encerra.
PAUSE 3 NO-MESSAGE.

/* .......................................................................... */

