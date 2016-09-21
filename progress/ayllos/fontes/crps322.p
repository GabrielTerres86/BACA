/* .............................................................................

   Programa: Fontes/crps322.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Abril/2002.                         Ultima atualizacao: 25/01/2016
   
   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Controlar o processo Batch de Limpeza.


   Alteracoes: 05/09/2003 - Foi incluido a geracao das solicitacoes de limpeza:
                            13, 24, 25, 49, 51, 56 (Fernando).

               02/02/2005 - Colocar o dia da semana em uma variavel (Edson).
               
               30/06/2005 - Alimentado campo cdcooper da tabela crapsol (Diego).

               15/08/2005 - Capturar codigo da cooperativa da variavel de 
                            ambiente CDCOOPER (Edson).
                            
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder             

               24/11/2006 - Utilizar o arquivo PROC_cron.pf na chamada
                            dos programas paralelos (Edson).
                            
               09/09/2010 - Chamada da includes para conectar ao banco genérico
                            (Vitor).
                            
               05/10/2010 - Alteracao no mbpro para conexao no banco generico
                            (Ze).
                            
               15/07/2011 - Retirada conexão nas chamadas dos programas para o
                            banco gener (Fernando).
                            
               27/07/2012 - Ajuste do format no campo nmrescop (David Kruger).
               
               21/01/2014 - Incluir VALIDATE crapsol (Lucas R)
               
               05/01/2015 - Remover solicitações de microfilmegem pois os programas foram desativados:
                            024 -> solicitacao de microfilmagem do capital                            
                            051 -> solicitacao de microfilmagem do cadastro
                            SD368030 (Odirlei-AMcom)
                            
               25/01/2016 - Exclusao do proc_batch a critica 655.
                            (Jaison/Diego - SD: 365433)

............................................................................. */

{ includes/var_batch.i "NEW" }

{ includes/gg0000.i }

/*  .... Define a quantidade de programas que rodam na cadeia paralela .....  */

DEF            VAR aux_qtparale AS INT     INIT 2                    NO-UNDO.
DEF            VAR aux_contapar AS INT                               NO-UNDO.
DEF            VAR aux_cdprgpar AS CHAR    FORMAT "x(10)" EXTENT 2   NO-UNDO.

/*  ......................................................................... */

DEF            VAR aux_cadeiaex AS CHAR    FORMAT "x(2000)" INIT ""  NO-UNDO.
DEF            VAR aux_lscadeia AS CHAR    FORMAT "x(1000)"          NO-UNDO.
DEF            VAR aux_nrposprg AS INT     FORMAT "zz9" INIT 1       NO-UNDO.
DEF            VAR aux_qtprgpar AS INT                               NO-UNDO.
DEF            VAR aux_nrdiaexe AS INT                               NO-UNDO.
DEF            VAR aux_nmdobjet AS CHAR    FORMAT "x(20)"            NO-UNDO.
DEF            VAR aux_nmcobjet AS CHAR    FORMAT "x(80)"            NO-UNDO.
DEF            VAR aux_cdprogra AS CHAR    FORMAT "x(20)"            NO-UNDO.
DEF            VAR aux_nmarquiv AS CHAR    FORMAT "x(40)"            NO-UNDO.

DEF            VAR aux_dtmvtolt AS DATE                              NO-UNDO.
DEF            VAR aux_dtlimite AS DATE                              NO-UNDO.
DEF            VAR aux_dtavisos AS DATE                              NO-UNDO.
DEF            VAR aux_qtdiasut AS INT                               NO-UNDO.
DEF            VAR aux_dtavs001 AS DATE                              NO-UNDO.
DEF            VAR aux_dtlogant AS DATE                              NO-UNDO.

DEF            VAR tab_qtdiaper AS DECIMAL FORMAT "999"              NO-UNDO.

DEF            VAR aux_flglimpa AS LOGICAL                           NO-UNDO.
DEF            VAR aux_flgsol25 AS LOGICAL                           NO-UNDO.
DEF            VAR aux_flgsol49 AS LOGICAL                           NO-UNDO.
DEF            VAR aux_flgsol56 AS LOGICAL                           NO-UNDO.

ASSIGN aux_flglimpa = FALSE /* Solicitacao 013 */
       aux_flgsol25 = FALSE
       aux_flgsol49 = FALSE
       aux_flgsol56 = FALSE
       
       aux_nrdiaexe = 2.           /* 1 = DOMINGO
                                      2 = SEGUNDA-FEIRA
                                      3 = TERCA-FEIRA
       PADRAO = 2                     4 = QUARTA-FEIRA
                                      5 = QUINTA-FEIRA
                                      6 = SEXTA-FEIRA
                                      7 = SABADO      
    ATENCAO

    ** Se o valor da variavel "aux_nrdiaexe" for ALTERADO, deve-se modificar
       o CRONTAB que executa o shell PROCLPZ_cron.sh (para cada cooperativa) 
       e o programa fontes/crps000.p, rotina que cria o arquivos limpezafer **

*/
       
ASSIGN glb_cdprogra = "crps322"
       glb_flgbatch = FALSE.

/* Conecta o Banco Generico  */

IF   NOT f_conectagener() THEN
     DO:
         glb_cdcritic = 791.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " + 
                           glb_cdprogra + "' --> '"  + glb_dscritic + 
                           " Generico " + " >> log/proc_batch.log").
         QUIT.
     END.
       
/*  Captura codigo da cooperativa da variavel de ambiente CDCOOPER .......... */

glb_cdcooper = INT(OS-GETENV("CDCOOPER")).

IF   glb_cdcooper = ?   THEN
     glb_cdcooper = 0.

/*  Verifica se a cooperativa esta cadastrada ............................... */
   
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         QUIT.
     END.

DO WHILE TRUE:

   FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper
                            NO-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE crapdat   THEN
        IF   LOCKED crapdat   THEN
             DO:
                 PAUSE 1 NO-MESSAGE.
                 NEXT.
             END.
        ELSE
             glb_cdcritic = 1.
   ELSE
        ASSIGN glb_cdcritic = 0
               glb_dtmvtolt = crapdat.dtmvtolt.

   LEAVE.

END.

IF   WEEKDAY(glb_dtmvtolt) = aux_nrdiaexe   THEN /* verifica o dia da semana  */
     DO:
         FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                            craptab.nmsistem = "CRED"        AND
                            craptab.tptabela = "GENERI"      AND
                            craptab.cdempres = 00            AND
                            craptab.cdacesso = "EXELIMPEZA"  AND
                            craptab.tpregist = 001           NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE (craptab) THEN
              DO:
                  glb_cdcritic = 176.
                  QUIT.
              END.
         ELSE
              IF   craptab.dstextab = "0" THEN
                   aux_flglimpa = TRUE.
     END.

/* Verifica se e' mes de Maio e se e' Segunda-feira para solicitar a limpeza 
   dos lancamentos de capital do ano anterior */

IF   MONTH(glb_dtmvtolt)   = 05 AND
     WEEKDAY(glb_dtmvtolt) = aux_nrdiaexe   THEN
     DO:
         FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                            craptab.nmsistem = "CRED"        AND
                            craptab.tptabela = "GENERI"      AND
                            craptab.cdempres = 00            AND
                            craptab.cdacesso = "EXELIMPCOT"  AND
                            craptab.tpregist = 002           NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE (craptab) THEN
              DO:
                  glb_cdcritic = 178.
                  QUIT.
              END.
         ELSE
              IF   craptab.dstextab = "0" THEN
                   ASSIGN aux_flgsol25 = TRUE.
     END.

/* Verifica se e' mes de Junho e se e' Segunda-feira para solicitar a limpeza 
   dos dados dos associados eliminados */

IF   MONTH(glb_dtmvtolt)   = 06 AND
     WEEKDAY(glb_dtmvtolt) = aux_nrdiaexe   THEN
     DO:
         FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                            craptab.nmsistem = "CRED"        AND
                            craptab.tptabela = "GENERI"      AND
                            craptab.cdempres = 00            AND
                            craptab.cdacesso = "EXELIMPCAD"  AND
                            craptab.tpregist = 001           NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE (craptab) THEN
              DO:
                  glb_cdcritic = 387.
                  QUIT.
              END.
         ELSE
              IF   craptab.dstextab = "0" THEN
                   ASSIGN aux_flgsol49 = TRUE.

     END.

/* Verifica se e mes de fevereiro e se e segunda-feira para solicitar a limpeza
   do crapneg  */

IF   MONTH(glb_dtmvtolt)   = 2   AND
     WEEKDAY(glb_dtmvtolt) = aux_nrdiaexe   THEN
     DO:
         FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                            craptab.nmsistem = "CRED"        AND
                            craptab.tptabela = "GENERI"      AND
                            craptab.cdempres = 00            AND
                            craptab.cdacesso = "EXELIMPNEG"  AND
                            craptab.tpregist = 001           NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE (craptab) THEN
              DO:
                  glb_cdcritic = 420.
                  QUIT.
              END.
         ELSE
              IF   craptab.dstextab = "0" THEN
                   ASSIGN aux_flgsol56 = TRUE.
     END.


DO TRANSACTION:

   /* Cria solicitacao de limpeza as Sextas-feiras */
   IF   aux_flglimpa THEN
        DO:
            CREATE crapsol.
            ASSIGN crapsol.nrsolici = 013
                   crapsol.dtrefere = glb_dtmvtolt
                   crapsol.nrseqsol = 01
                   crapsol.cdempres = 11
                   crapsol.dsparame = " "
                   crapsol.insitsol = 1
                   crapsol.nrdevias = 1
                   crapsol.cdcooper = glb_cdcooper.
            VALIDATE crapsol.
        END.   
   
   /* Cria solicitacao de limpeza do capital */
   IF   aux_flgsol25 THEN
        DO:
            CREATE crapsol.
            ASSIGN crapsol.nrsolici = 025
                   crapsol.dtrefere = glb_dtmvtolt
                   crapsol.nrseqsol = 01
                   crapsol.cdempres = 11
                   crapsol.dsparame = ""
                   crapsol.insitsol = 1
                   crapsol.nrdevias = 1
                   crapsol.cdcooper = glb_cdcooper.
            VALIDATE crapsol.
        END.

   /* Cria solicitacao de limpeza do cadastro de socios */
   IF   aux_flgsol49 THEN
        DO:
            CREATE crapsol.
            ASSIGN crapsol.nrsolici = 049
                   crapsol.dtrefere = glb_dtmvtolt
                   crapsol.nrseqsol = 01
                   crapsol.cdempres = 11
                   crapsol.dsparame = ""
                   crapsol.insitsol = 1
                   crapsol.nrdevias = 1
                   crapsol.cdcooper = glb_cdcooper.
            VALIDATE crapsol.
        END.

   /* Cria solicitacao de limpeza do crapneg */
   IF   aux_flgsol56 THEN
        DO:
            CREATE crapsol.
            ASSIGN crapsol.nrsolici = 056
                   crapsol.dtrefere = glb_dtmvtolt
                   crapsol.nrseqsol = 01
                   crapsol.cdempres = 11
                   crapsol.dsparame = ""
                   crapsol.insitsol = 1
                   crapsol.nrdevias = 1
                   crapsol.cdcooper = glb_cdcooper.
            VALIDATE crapsol.
        END.

END.  /* Fim do DO TRANSACTION */

IF   glb_cdcritic > 0   THEN
     DO:
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" + glb_dscritic +
                           " >> log/proc_batch.log").
         PAUSE 2 NO-MESSAGE.
         QUIT.
     END.

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                  " Inicio do processo batch de limpeza referente " +
                  (IF glb_dtmvtolt <> ?
                      THEN STRING(glb_dtmvtolt,"99/99/9999")
                      ELSE "'*** Sistema sem data! ***'") +
                  " em " + STRING(TODAY,"99/99/9999") + 
                  " da " + STRING(crapcop.nmrescop,"x(20)") +
                  " >> log/proc_batch.log").

FOR EACH crapord WHERE crapord.cdcooper = glb_cdcooper  AND
                       crapord.tpcadeia = 2             NO-LOCK:

    FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper      AND
                           crapsol.nrsolici = crapord.nrsolici  AND
                           crapsol.dtrefere = glb_dtmvtolt      AND
                           crapsol.insitsol = 1                 NO-LOCK:

        FOR EACH crapprg WHERE crapprg.cdcooper = glb_cdcooper      AND
                               crapprg.nrsolici = crapsol.nrsolici
                               USE-INDEX crapprg2 NO-LOCK:

            IF   crapprg.inctrprg = 1   THEN
                 DO:
                     IF   crapprg.cdprogra = aux_cdprogra   THEN
                          NEXT.

                     ASSIGN aux_cadeiaex = aux_cadeiaex + crapprg.cdprogra +
                                           STRING(crapord.inexclus)
                            aux_cdprogra = crapprg.cdprogra

                            aux_lscadeia = aux_lscadeia +
                                           SUBSTRING(crapprg.cdprogra,5,3) +
                                           IF crapord.inexclus = 1
                                              THEN "e "
                                              ELSE "p ".
                 END.
            ELSE
                 DO:
                     glb_cdcritic = 147.
                     RUN fontes/critic.p.
                     UNIX SILENT VALUE("echo " +
                                        STRING(TIME,"HH:MM:SS") + " - " +
                                        glb_cdprogra + "' --> '" +
                                        glb_dscritic + " - "     +
                                        crapprg.cdprogra +
                                        " >> log/proc_batch.log").
                     PAUSE 2 NO-MESSAGE.
                     QUIT.
                 END.
                 
        END.  /*  Fim do FOR EACH -- Leitura do cadastro de programas  */
    END.  /*  Fim do FOR EACH -- Leitura do cadastro de solicitacoes  */
END.  /*  Fim do FOR EACH -- Leitura do cadastro de ordem de execucao  */

IF   aux_cadeiaex = ""   THEN
     DO:
         glb_cdcritic = 142.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         UNIX SILENT VALUE("echo " +
                           STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" +
                           glb_dscritic +
                           " >> log/proc_batch.log").
         PAUSE 2 NO-MESSAGE.                  
         QUIT.
     END.

DO WHILE INTEGER(SUBSTRING(aux_cadeiaex,aux_nrposprg + 7,1)) = 2:

   ASSIGN aux_nmdobjet = "fontes/" +
                          LC(SUBSTRING(aux_cadeiaex,aux_nrposprg,7) + ".p")

          aux_nmcobjet = SEARCH(aux_nmdobjet).

   IF   aux_nmcobjet <> ?   THEN
        DO:
            FIND FIRST crapprg WHERE 
                       crapprg.cdcooper = glb_cdcooper    AND
                       crapprg.cdprogra = 
                               LC(SUBSTRING(aux_cadeiaex,aux_nrposprg,7))
                       NO-LOCK NO-ERROR.
                       
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                              glb_cdprogra + "' --> '" +
                              "Inicio da execucao paralela: " +
                              LC(SUBSTRING(aux_cadeiaex,aux_nrposprg,7)) +
                              (IF AVAILABLE crapprg
                                  THEN " - '" + LC(crapprg.dsprogra[1]) + "'"  
                                  ELSE "") +
                              " >> log/proc_batch.log").

            UNIX SILENT VALUE
                 ("mbpro" + 
                  " -pf arquivos/PROC_cron.pf " +
                  " -s 100 -p fontes/" + 
                  LC(SUBSTR(aux_cadeiaex,aux_nrposprg,7) + ".p")).
        END.
   ELSE
        DO:
            glb_cdcritic = 153.
            RUN fontes/critic.p.
            MESSAGE glb_dscritic.
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" + aux_nmdobjet + " - " +
                               glb_dscritic + " >> log/proc_batch.log").
            PAUSE 2 NO-MESSAGE.
        END.

   DO aux_contapar = 1 TO aux_qtparale:
   
      IF   aux_cdprgpar[aux_contapar] <> ""   THEN
           NEXT.

      aux_cdprgpar[aux_contapar] = SUBSTRING(aux_cadeiaex,aux_nrposprg,7).

      LEAVE.
   
   END.  /*  Fim do DO .. TO  */

   ASSIGN aux_qtprgpar = aux_qtprgpar + 1
          aux_nrposprg = aux_nrposprg + 8.

   DO WHILE aux_qtprgpar = aux_qtparale:

      DO aux_contapar = 1 TO aux_qtparale:
        
         FIND crapprg WHERE crapprg.cdcooper = glb_cdcooper                 AND
                            crapprg.cdprogra = aux_cdprgpar[aux_contapar]   AND
                            crapprg.nmsistem = "CRED"
                            USE-INDEX crapprg1 NO-LOCK NO-ERROR.

         IF   AVAILABLE crapprg   THEN
              IF   crapprg.inctrprg = 2 THEN /* Magui 1 para testes */
                   DO:
                       UNIX SILENT VALUE("echo " +
                                         STRING(TIME,"HH:MM:SS") + " - " +
                                         LC(aux_cdprgpar[aux_contapar]) + 
                                         "' --> '" + "Execucao ok " +
                                         " >> log/proc_batch.log").

                       ASSIGN aux_cdprgpar[aux_contapar] = ""
                              aux_qtprgpar = aux_qtprgpar - 1.
                   END.
      
      END.  /*  Fim do DO .. TO  */
      
      PAUSE 5 NO-MESSAGE.

   END.  /*  Fim do DO WHILE  */

END.  /*  Fim do DO WHILE TRUE  */

DO WHILE aux_qtprgpar > 0:      /* Espera os paralelos terminarem */

   DO aux_contapar = 1 TO aux_qtparale:

      IF   aux_cdprgpar[aux_contapar] <> ""   THEN
           DO:
               FIND crapprg WHERE 
                    crapprg.cdcooper = glb_cdcooper                 AND
                    crapprg.cdprogra = aux_cdprgpar[aux_contapar]   AND
                    crapprg.nmsistem = "CRED"
                    USE-INDEX crapprg1 NO-LOCK NO-ERROR.

               IF   AVAILABLE crapprg   THEN
                    IF   crapprg.inctrprg = 2 THEN /*Magui1 para testes */
                         DO:
                             UNIX SILENT VALUE("echo " +
                                            STRING(TIME,"HH:MM:SS") + " - " +
                                            LC(aux_cdprgpar[aux_contapar]) + 
                                            "' --> '" + "Execucao ok " +
                                            " >> log/proc_batch.log").

                             ASSIGN aux_cdprgpar[aux_contapar] = ""
                                    aux_qtprgpar = aux_qtprgpar - 1.
                         END.
           END.

   END.  /*  Fim do DO .. TO  */

   PAUSE 5 NO-MESSAGE.

END.  /*  Fim do DO WHILE  */

UNIX SILENT VALUE("> arquivos/.limpezaok 2>/dev/null").

/*  Registra fim do processo BATCH  */
UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                  " Fim do processo batch de limpeza referente " +
                  STRING(glb_dtmvtolt,"99/99/9999") +
                  " >> log/proc_batch.log").
                                                                               
/* ...........................................................................*/

