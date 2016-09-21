/* ..........................................................................

   Programa: fontes/dirfi.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio/Evandro
   Data    : Janeiro/2005                       Ultima atualizacao: 12/09/2006

   Dados referentes ao programa:

   Frequencia: Ayllos.
   Objetivo  : Atende a solicitacao 50 ordem _. 
               Tela para digitacao dos dados para DIRF, importacao e geracao
               de arquivo.

   Alteracoes: 27/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               27/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               12/09/2006 - Alteracao dos helps dos campos da tela (Elton).

............................................................................ */

{ includes/var_online.i }

DEF VAR tel_nmarqint AS CHAR      FORMAT "x(68)"                     NO-UNDO.
DEF VAR tel_nranocal AS INT       FORMAT "9999"                      NO-UNDO.

DEF VAR aux_confirma AS CHARACTER FORMAT "!(1)"                      NO-UNDO.

FORM SKIP(4)
     tel_nranocal   AT 7  LABEL "Ano Calendario"
                          HELP  "Informe o ano referente a declaracao."
                          VALIDATE(INPUT tel_nranocal > 1900 AND 
                                   NOT CAN-FIND(crapdrf WHERE 
                                   crapdrf.cdcooper = glb_cdcooper       AND
                                   crapdrf.nranocal = INPUT tel_nranocal AND
                                   crapdrf.tpregist = 1                  AND
                                   TRIM(crapdrf.dsobserv) <> ""     NO-LOCK),
                  "A DIRF para o ano calendario informado ja esta finalizada!")
     SKIP(2)                                  
     "Nome do arquivo:" AT 5
     SKIP
     tel_nmarqint   AT 5  NO-LABEL
                    HELP  "Informe o nome do arquivo a ser integrado."
                    VALIDATE(INPUT tel_nmarqint <> "", 
                             "375 - O campo deve ser preenchido.")
     SKIP(6)
     WITH WIDTH 78 OVERLAY ROW 5 CENTERED SIDE-LABELS 
          TITLE "INTEGRACAO DE ARQUIVO" FRAME fr_integra_arq.


ASSIGN glb_cddopcao = "I".

{ includes/acesso.i }

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop   THEN
     RETURN.

HIDE MESSAGE NO-PAUSE.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   UPDATE tel_nranocal tel_nmarqint WITH FRAME fr_integra_arq.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      aux_confirma = "N".
      glb_cdcritic = 78.
      RUN fontes/critic.p.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      glb_cdcritic = 0.
      LEAVE.
   END.

   IF   aux_confirma <> "S"   THEN
        NEXT.
   
   RUN fontes/integra_arq_dirf.p (tel_nmarqint, tel_nranocal).
   
   
   IF   glb_cdcritic <> 0   THEN   /* se arquivo nao foi encontrado ou erro */
        DO:
            /* apaga o arquivo QUOTER */
            UNIX SILENT VALUE("rm /micros/" + crapcop.dsdircop +
                              "/dirf/integrar/" + tel_nmarqint + "_ux_q" +
                              " 2> /dev/null").

            /* apaga o arquivo UNIX */
            UNIX SILENT VALUE("rm /micros/" + crapcop.dsdircop +
                              "/dirf/integrar/" + tel_nmarqint + "_ux" +
                              " 2> /dev/null").
            
            glb_cdcritic = 0.
            NEXT.
        END.
   
   HIDE MESSAGE NO-PAUSE.
   HIDE FRAME f_integra_arq.
   LEAVE.
   
END.

/* ......................................................................... */







