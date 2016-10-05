/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps120_1.p              | pc_crps120_1                      |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/











/* ..........................................................................

   Programa: Fontes/crps120_1.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Maio/95.                            Ultima atualizacao: 26/09/2016

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado pelo crps120.
   Objetivo  : Processar os debitos de emprestimos.

   Alteracoes: 19/11/96 - Alterado a mascara do campo nrctremp (Odair).

               27/08/97 - Alterado para alimentar crapavs.flgproce quando
                          o debito for feito (Deborah).

               27/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               12/11/98 - Tratar atendimento noturno (Deborah).

               30/10/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               29/06/2005 - Alimentado campo cdcooper da tabela craplem (Diego).

               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               28/04/2006 - Controlar o valor minimo a ser debitado (Julio).
               
               23/01/2009 - Alteracao cdempres (Diego).
               
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               26/03/2010 - Desativar Rating quando liquidado
                            o emprestimo (Gabriel).
                            
               09/03/2012 - Declarado novas variaveis da include lelem.i
                            (Tiago).
                          
               17/10/2013 - GRAVAMES - Solicitacao Baixa Automatica
                            (Guilherme/SUPERO).
                            
               15/01/2014 - Inclusao de VALIDATE craplem (Carlos)
               
               05/06/2014 - Alterado format do cdlcremp de 3 para 4 
                            Softdesk 137074 (Lucas R.)
                            
               26/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)
                            
               26/09/2016 - Inclusao da validacao de contratos de acordos,
                            Prj. 302 (Jean Michel).
.............................................................................*/

DEF INPUT  PARAM par_nrdconta AS INT                                        .
DEF INPUT  PARAM par_nrctremp AS INT                                        .
DEF INPUT  PARAM par_nrdolote AS INT                                        .
DEF INPUT  PARAM par_inusatab AS LOGICAL                                    .
DEF INPUT  PARAM par_vldaviso AS DECIMAL                                    .
DEF INPUT  PARAM par_vlsalliq AS DECIMAL                                    .
DEF INPUT  PARAM par_dtintegr AS DATE                                       .
DEF INPUT  PARAM par_cdhistor AS INT                                        .
DEF OUTPUT PARAM par_insitavs AS INT                                        .
DEF OUTPUT PARAM par_vldebito AS DECIMAL                                    .
DEF OUTPUT PARAM par_vlestdif AS DECIMAL                                    .
DEF OUTPUT PARAM par_flgproce AS LOGICAL                                    .

{ includes/var_batch.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }

DEF        VAR tab_diapagto AS INT                                   NO-UNDO.
DEF        VAR tab_dtcalcul AS DATE                                  NO-UNDO.
DEF        VAR tab_dtpagemp AS DATE                                  NO-UNDO.
DEF        VAR tab_inusatab AS LOGICAL                               NO-UNDO.
DEF        VAR tab_vlmindeb AS DECIMAL                               NO-UNDO.

DEF        VAR aux_nmarqint AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR aux_dsintegr AS CHAR                                  NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR    FORMAT "x(20)" EXTENT 99      NO-UNDO.
DEF        VAR aux_nrdevias AS INT     FORMAT "z9"    EXTENT 99      NO-UNDO.

DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgclote AS LOGICAL                               NO-UNDO.

DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.
DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR aux_dtmesnov AS DATE                                  NO-UNDO.

DEF        VAR aux_contaarq AS INT                                   NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT     INIT 100                      NO-UNDO.
DEF        VAR aux_nrdolote AS INT                                   NO-UNDO.
DEF        VAR aux_nrmesant AS INT                                   NO-UNDO.
DEF        VAR aux_nrdocmto AS INT                                   NO-UNDO.

DEF        VAR aux_tpregist AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR aux_tpdebito AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR aux_nrdconta AS INT     FORMAT "99999999"             NO-UNDO.
DEF        VAR aux_cdhistor AS INT     FORMAT "9999"                 NO-UNDO.
DEF        VAR aux_dtmvtoin AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR aux_cdempres AS INT     FORMAT "99999"                NO-UNDO.
DEF        VAR aux_cdtipsfx AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_nrseqint AS INT     FORMAT "999999"               NO-UNDO.
DEF        VAR aux_vldaurvs AS DECIMAL FORMAT "99999.99"             NO-UNDO.
DEF        VAR aux_vldescto AS DECIMAL FORMAT "9999999999.99-"       NO-UNDO.
DEF        VAR aux_vllanmto AS DECIMAL FORMAT "9999999999.99-"       NO-UNDO.
DEF        VAR aux_vledvmto AS DECIMAL FORMAT "999999999.99"         NO-UNDO.

DEF        VAR aux_dtmesant AS DATE                                  NO-UNDO.
DEF        VAR aux_dtultpag AS DATE                                  NO-UNDO.
DEF        VAR aux_dtultdia AS DATE                                  NO-UNDO.
DEF        VAR aux_dtcalcul AS DATE                                  NO-UNDO.

DEF        VAR aux_vlpreemp LIKE crapepr.vlpreemp                    NO-UNDO.
DEF        VAR aux_qtprecal LIKE crapepr.qtprecal                    NO-UNDO.
DEF        VAR aux_qtpreemp LIKE crapepr.qtpreemp                    NO-UNDO.
DEF        VAR aux_qtmesdec LIKE crapepr.qtmesdec                    NO-UNDO.

DEF        VAR aux_vljurmes AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF        VAR aux_vljuracu AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF        VAR aux_vlsdeved AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF        VAR aux_vlprepag AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR aux_txdjuros AS DECIMAL DECIMALS 7                    NO-UNDO.

DEF        VAR aux_inhst093 AS LOGICAL                               NO-UNDO.

DEF        VAR aux_nrctremp AS INT                                   NO-UNDO.
DEF        VAR aux_nrultdia AS INT                                   NO-UNDO.
DEF        VAR aux_nrdiacal AS INT                                   NO-UNDO.
DEF        VAR aux_nrdiames AS INT                                   NO-UNDO.
DEF        VAR aux_nrdiamss AS INT                                   NO-UNDO.
DEF        VAR aux_ddlanmto AS INT                                   NO-UNDO.
DEF        VAR aux_inliquid AS INT                                   NO-UNDO.
DEF        VAR aux_qtprepag AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR aux_flgativo AS INT                                   NO-UNDO. 

ASSIGN glb_cdcritic = 0
       par_vldebito = 0
       par_flgproce = FALSE.

/* Valor minimo para debito dos atrasos das prestacoes */
FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "GENERI"      AND
                   craptab.cdempres = 0             AND
                   craptab.cdacesso = "VLMINDEBTO"  AND
                   craptab.tpregist = 0             NO-LOCK NO-ERROR.
                   
IF   NOT AVAILABLE craptab THEN
     ASSIGN tab_vlmindeb = 0.
ELSE
     ASSIGN tab_vlmindeb = DEC(craptab.dstextab).                              
/*  Leitura do contrato de emprestimo  */

DO WHILE TRUE:

  /* Verifica se possui contrato de acordo */
  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

  /* Verifica se ha contratos de acordo */
  RUN STORED-PROCEDURE pc_verifica_acordo_ativo
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper
                                        ,INPUT par_nrdconta
                                        ,INPUT par_nrctremp
                                        ,0
                                        ,0
                                        ,"").

  CLOSE STORED-PROC pc_verifica_acordo_ativo
    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

  ASSIGN glb_cdcritic = 0
         glb_dscritic = ""
         glb_cdcritic = INT(pc_verifica_acordo_ativo.pr_cdcritic) WHEN pc_verifica_acordo_ativo.pr_cdcritic <> ?
         glb_dscritic = pc_verifica_acordo_ativo.pr_dscritic WHEN pc_verifica_acordo_ativo.pr_dscritic <> ?
         aux_flgativo = INT(pc_verifica_acordo_ativo.pr_flgativo).

  IF glb_cdcritic > 0 THEN
    DO:
      RUN fontes/critic.p.
      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                        glb_cdprogra + "' --> '" + glb_dscritic +
                        " >> log/proc_batch.log").
      RETURN.
    END.
  ELSE IF glb_dscritic <> ? AND glb_dscritic <> "" THEN
    DO:
      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                        glb_cdprogra + "' --> '" + glb_dscritic +
                        " >> log/proc_batch.log").
      RETURN.
    END.
    
  IF aux_flgativo = 1 THEN
	DO:
	 ASSIGN par_insitavs = 0.
     RETURN.
    END.
  /* Fim verifica se possui contrato de acordo */

   FIND crapepr WHERE crapepr.cdcooper = glb_cdcooper   AND   
                      crapepr.nrdconta = par_nrdconta   AND
                      crapepr.nrctremp = par_nrctremp
                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE crapepr   THEN
        IF   LOCKED crapepr   THEN
             DO:
                 PAUSE 2 NO-MESSAGE.
                 NEXT.
             END.
        ELSE
             DO:
                 glb_cdcritic = 356.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                   glb_cdprogra + "' --> '" + glb_dscritic +
                                   " CTA: " + STRING(par_nrdconta,"zzzzzzz,9") +
                                   " CTR: " + STRING(par_nrctremp,"zz,zzz,zz9") +
                                   " >> log/proc_batch.log").
                 RETURN.
             END.

   IF   crapepr.inliquid > 0   THEN
        DO:
            ASSIGN par_insitavs = 1
                   par_vlestdif = par_vldaviso
                   par_flgproce = TRUE.
            RETURN.
        END.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

IF   par_inusatab           AND
     crapepr.inliquid = 0   THEN
     DO:
         FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper     AND
                            craplcr.cdlcremp = crapepr.cdlcremp 
                            NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE craplcr   THEN
              DO:
                  glb_cdcritic = 363.
                  RUN fontes/critic.p.
                  UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                    glb_cdprogra + "' --> '" + glb_dscritic +
                                    " LCR: " + STRING(crapepr.cdlcremp,"zzz9") +
                                    " >> log/proc_batch.log").
                  RETURN.
              END.
         ELSE
              aux_txdjuros = craplcr.txdiaria.
     END.
ELSE
     aux_txdjuros = crapepr.txjuremp.

/*  Inicializacao das variaves de calculo  */

ASSIGN aux_nrdconta = crapepr.nrdconta
       aux_nrctremp = crapepr.nrctremp
       aux_vlsdeved = crapepr.vlsdeved
       aux_vljuracu = crapepr.vljuracu
       aux_dtultpag = crapepr.dtultpag
       aux_inliquid = crapepr.inliquid
       aux_qtprepag = crapepr.qtprepag

       aux_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) + 4) -
                             DAY(DATE(MONTH(glb_dtmvtolt),28,
                                      YEAR(glb_dtmvtolt)) + 4))

       aux_dtcalcul = IF glb_inproces > 2
                         THEN par_dtintegr
                         ELSE ?

       tab_diapagto = 0.

{ includes/lelem.i }                  /*  Rotina de calculo  */

IF   glb_cdcritic > 0   THEN
     DO:
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" + glb_dscritic +
                           " >> log/proc_batch.log").
         RETURN.
     END.

IF   aux_vlsdeved <= 0   THEN 
     DO:
       
         ASSIGN crapepr.inliquid = 1
                par_vlestdif     = par_vldaviso
                par_insitavs     = 1
                par_flgproce     = TRUE.

         RUN desativa_rating(INPUT glb_cdcooper,
                             INPUT crapepr.nrdconta,
                             INPUT crapepr.nrctremp).

         RUN solicita_baixa_automatica (INPUT glb_cdcooper,
                                        INPUT crapepr.nrdconta,
                                        INPUT crapepr.nrctremp).
         RETURN.
     END.

IF   aux_vlsdeved > par_vldaviso   THEN
     DO:
        IF   par_vldaviso > par_vlsalliq   THEN
             ASSIGN aux_vllanmto = par_vlsalliq
                    par_vlestdif = par_vlsalliq - par_vldaviso
                    par_insitavs = 0.
        ELSE
             ASSIGN aux_vllanmto = par_vldaviso
                    par_vlestdif = 0
                    par_insitavs = 1
                    par_flgproce = TRUE.
                    
        IF   aux_vllanmto < tab_vlmindeb   THEN
             DO:
                 ASSIGN par_vlestdif = par_vldaviso * -1
                        par_insitavs = 0
                        par_flgproce = FALSE.
                        
                 RETURN.
             END.
     END.
ELSE
     IF   aux_vlsdeved > par_vlsalliq   THEN
          ASSIGN aux_vllanmto = par_vlsalliq
                 par_vlestdif = par_vlsalliq - aux_vlsdeved
                 par_insitavs = 0.
     ELSE
          ASSIGN aux_vllanmto = aux_vlsdeved
                 par_vlestdif = par_vldaviso - aux_vlsdeved
                 par_insitavs = 1
                 par_flgproce = TRUE.

DO WHILE TRUE:

   FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                      craplot.dtmvtolt = par_dtintegr   AND
                      craplot.cdagenci = aux_cdagenci   AND
                      craplot.cdbccxlt = aux_cdbccxlt   AND
                      craplot.nrdolote = par_nrdolote
                      USE-INDEX craplot1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE craplot   THEN
        IF   LOCKED craplot   THEN
             DO:
                 PAUSE 1 NO-MESSAGE.
                 NEXT.
             END.
        ELSE
             DO:
                 glb_cdcritic = 60.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                   glb_cdprogra + "' --> '" + glb_dscritic +
                                   " AG: 001 BCX: 100 LOTE: " +
                                   STRING(par_nrdolote,"999999") +
                                   " >> log/proc_batch.log").
                 RETURN.
             END.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

CREATE craplem.
ASSIGN aux_nrdocmto     = aux_nrdocmto + 1
       craplem.dtmvtolt = craplot.dtmvtolt
       craplem.cdagenci = craplot.cdagenci
       craplem.cdbccxlt = craplot.cdbccxlt
       craplem.nrdolote = craplot.nrdolote
       craplem.nrdconta = aux_nrdconta
       craplem.nrctremp = crapepr.nrctremp
       craplem.nrdocmto = craplot.nrseqdig + 1
       craplem.vllanmto = aux_vllanmto
       craplem.cdhistor = par_cdhistor
       craplem.nrseqdig = craplot.nrseqdig + 1
       craplem.dtpagemp = craplot.dtmvtolt
       craplem.txjurepr = aux_txdjuros
       craplem.cdcooper = glb_cdcooper

       craplem.vlpreemp = crapepr.vlpreemp

       craplot.qtinfoln = craplot.qtinfoln + 1
       craplot.qtcompln = craplot.qtcompln + 1
       craplot.vlinfocr = craplot.vlinfocr + aux_vllanmto
       craplot.vlcompcr = craplot.vlcompcr + aux_vllanmto
       craplot.nrseqdig = craplem.nrseqdig

       crapepr.dtultpag = craplot.dtmvtolt
       crapepr.txjuremp = aux_txdjuros
       crapepr.inliquid = IF (aux_vlsdeved - aux_vllanmto) > 0 THEN 0 ELSE 1

       par_vldebito     = aux_vllanmto.
VALIDATE craplem.

IF    crapepr.inliquid = 1 THEN DO:

      RUN desativa_rating (INPUT glb_cdcooper,
                           INPUT crapepr.nrdconta,
                           INPUT crapepr.nrctremp).

      RUN solicita_baixa_automatica (INPUT glb_cdcooper,
                                     INPUT crapepr.nrdconta,
                                     INPUT crapepr.nrctremp).
END.

      
/* .......................................................................... */

PROCEDURE desativa_rating: 
/* Desativar o Rating desta proposta quando liquidado o contrato */

    DEF INPUT PARAM par_cdcooper AS INTE    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE    NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE    NO-UNDO.

    DEF VAR h-b1wgen0043         AS HANDLE  NO-UNDO.


    RUN sistema/generico/procedures/b1wgen0043.p
                         PERSISTENT SET h-b1wgen0043.

    RUN desativa_rating IN h-b1wgen0043 (INPUT par_cdcooper,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT glb_cdoperad,
                                         INPUT glb_dtmvtolt,
                                         INPUT glb_dtmvtopr,
                                         INPUT par_nrdconta,
                                         INPUT 90,
                                         INPUT par_nrctremp,
                                         INPUT TRUE,
                                         INPUT 1,
                                         INPUT 1,
                                         INPUT glb_nmdatela,
                                         INPUT glb_inproces,
                                         INPUT FALSE,
                                         OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0043.

END PROCEDURE.

/* .......................................................................... */

PROCEDURE solicita_baixa_automatica:

    DEF INPUT PARAM par_cdcooper AS INTE    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE    NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE    NO-UNDO.

    DEF VAR h-b1wgen0171         AS HANDLE  NO-UNDO.


    RUN sistema/generico/procedures/b1wgen0171.p
                         PERSISTENT SET h-b1wgen0171.

    RUN solicita_baixa_automatica IN h-b1wgen0171
                 (INPUT par_cdcooper,
                  INPUT par_nrdconta,
                  INPUT par_nrctremp,
                  INPUT glb_dtmvtolt,
                 OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0171.

END PROCEDURE.

/* .......................................................................... */
