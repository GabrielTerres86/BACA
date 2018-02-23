/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/saldo_epr.               | EMPR0001.pc_calc_saldo_epr        |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/





/* .............................................................................

   Programa: Fontes/saldo_epr.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Junho/2004.                         Ultima atualizacao: 23/02/2018

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Calcular o saldo devedor do emprestimo.

   Alteracoes:  Passado parametro quantidade prestacoes calculadas(Mirtes)
   
                26/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
                
                01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
                
                12/03/2012 - Declarado variaveis necessarias para utilizacao 
                             da include lelem.i (Tiago).
                             
                21/05/2012 - Buscar saldo do novo tipo de emprestimo
                             (Gabriel)
                             
                07/01/2014 - Declaracao variaveis necessarias para utilizacao
                             da include b1wgen0002a.i (James)
                           
                07/03/2014 - Incluir variaveis necessarias para utilizacao
                             da include b1wgen0002a.i (James)

                08/08/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)
                
                23/02/2018 - Ajuste no parametros de entrada. (James)

............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0084att.i }
{ sistema/generico/includes/var_oracle.i }

  
DEF INPUT  PARAM par_nrdconta AS INT                                   NO-UNDO.
DEF INPUT  PARAM par_nrctremp AS INT                                   NO-UNDO.
DEF OUTPUT PARAM par_vlsdeved AS DECIMAL                               NO-UNDO.
DEF OUTPUT PARAM par_qtprecal LIKE crapepr.qtprecal                    NO-UNDO.

DEF         VAR tab_diapagto  AS INT                                   NO-UNDO.
DEF         VAR tab_dtcalcul  AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF         VAR tab_flgfolha  AS LOGICAL                               NO-UNDO.
DEF         VAR tab_inusatab  AS LOGICAL                               NO-UNDO.

DEF         VAR aux_dtmesant  AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF         VAR aux_dtultpag  AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF         VAR aux_dtultdia  AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF         VAR aux_dtcalcul  AS DATE    FORMAT "99/99/9999"           NO-UNDO.
  
DEF         VAR aux_vljurmes  AS DECIMAL                               NO-UNDO.
DEF         VAR aux_vljuracu  AS DECIMAL                               NO-UNDO.
DEF         VAR aux_vlsdeved  AS DECIMAL                               NO-UNDO.
DEF         VAR aux_vlprepag  AS DECIMAL                               NO-UNDO.
DEF         VAR aux_txdjuros  AS DECIMAL DECIMALS 7                    NO-UNDO.

DEF         VAR aux_vlpreemp  LIKE crapepr.vlpreemp                    NO-UNDO.
DEF         VAR aux_qtprecal  LIKE crapepr.qtprecal                    NO-UNDO.
DEF         VAR aux_qtpreemp  LIKE crapepr.qtpreemp                    NO-UNDO.
DEF         VAR aux_qtmesdec  LIKE crapepr.qtmesdec                    NO-UNDO.

DEF         VAR aux_nrdconta  AS INT                                   NO-UNDO.
DEF         VAR aux_nrctremp  AS INT                                   NO-UNDO.
DEF         VAR aux_nrultdia  AS INT                                   NO-UNDO.
DEF         VAR aux_nrdiacal  AS INT                                   NO-UNDO.
DEF         VAR aux_nrdiames  AS INT                                   NO-UNDO.
DEF         VAR aux_nrdiamss  AS INT                                   NO-UNDO.
DEF         VAR aux_ddlanmto  AS INT                                   NO-UNDO.
DEF         VAR aux_qtprepag  AS INT                                   NO-UNDO.
DEF         VAR aux_cdcritic  AS INT                                   NO-UNDO.

DEF         VAR aux_inhst093  AS LOGICAL                               NO-UNDO.
DEF         VAR aux_cdempres  AS INT                                   NO-UNDO.

DEF         VAR par_cdcooper AS INTE                                   NO-UNDO.
DEF         VAR par_cdagenci AS INTE                                   NO-UNDO.
DEF         VAR par_nrdcaixa AS INTE                                   NO-UNDO.
DEF         VAR par_cdoperad AS CHAR                                   NO-UNDO.
DEF         VAR par_nmdatela AS CHAR                                   NO-UNDO.
DEF         VAR aux_dscritic AS CHAR                                   NO-UNDO.
DEF         VAR par_idorigem AS INTE                                   NO-UNDO.
DEF         VAR par_idseqttl AS INTE                                   NO-UNDO.
DEF         VAR par_dtmvtolt AS DATE                                   NO-UNDO.
DEF         VAR par_flgerlog AS LOGI                                   NO-UNDO.
DEF         VAR aux_vlmrapar LIKE crappep.vlmrapar                     NO-UNDO.
DEF         VAR aux_vlmtapar LIKE crappep.vlmtapar                     NO-UNDO.
DEF         VAR aux_vliofcpl LIKE crappep.vliofcpl                     NO-UNDO.
DEF         VAR aux_vlprvenc AS DECI                                   NO-UNDO.
DEF         VAR aux_vlpraven AS DECI                                   NO-UNDO.
DEF         VAR aux_vlpreapg AS DECI                                   NO-UNDO.
DEF         VAR h-b1wgen0084a AS HANDLE                                NO-UNDO.
  
  
FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 11            AND
                   craptab.cdacesso = "TAXATABELA"  AND
                   craptab.tpregist = 0             NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     tab_inusatab = FALSE.
ELSE
     tab_inusatab = IF SUBSTRING(craptab.dstextab,1,1) = "0"
                       THEN FALSE
                       ELSE TRUE.

FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                   crapass.nrdconta = par_nrdconta  NO-LOCK NO-ERROR.

IF  AVAILABLE crapass  THEN
    DO: 
        IF   crapass.inpessoa = 1   THEN
             DO:
                 FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper       AND
                                    crapttl.nrdconta = crapass.nrdconta   AND
                                    crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

                 IF   AVAIL crapttl  THEN
                      ASSIGN aux_cdempres = crapttl.cdempres.
             END.
        ELSE
             DO:
                  FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                     crapjur.nrdconta = crapass.nrdconta
                                     NO-LOCK NO-ERROR.

                  IF   AVAIL crapjur  THEN
                       ASSIGN aux_cdempres = crapjur.cdempres.
             END.
    END.

IF   NOT AVAILABLE crapass   THEN
     RETURN.
     
FIND craptab WHERE craptab.cdcooper = glb_cdcooper      AND
                   craptab.nmsistem = "CRED"            AND
                   craptab.tptabela = "GENERI"          AND
                   craptab.cdempres = 00                AND
                   craptab.cdacesso = "DIADOPAGTO"      AND
                   craptab.tpregist = aux_cdempres      NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 55.
         RETURN.
     END.

IF   CAN-DO("1,3,4",STRING(crapass.cdtipsfx))   THEN
     tab_diapagto = INTEGER(SUBSTRING(craptab.dstextab,4,2)).  /*  Mensal  */
ELSE
     tab_diapagto = INTEGER(SUBSTRING(craptab.dstextab,7,2)).  /*  Horis.  */

/*  Verifica se a data do pagamento da empresa cai num dia util  */

tab_dtcalcul = DATE(MONTH(glb_dtmvtolt),tab_diapagto,YEAR(glb_dtmvtolt)).

DO WHILE TRUE:

   IF   WEEKDAY(tab_dtcalcul) = 1   OR
        WEEKDAY(tab_dtcalcul) = 7   THEN
        DO:
            tab_dtcalcul = tab_dtcalcul + 1.
            NEXT.
        END.

   FIND crapfer WHERE crapfer.cdcooper = glb_cdcooper   AND
                      crapfer.dtferiad = tab_dtcalcul   NO-LOCK NO-ERROR.

   IF   AVAILABLE crapfer   THEN
        DO:
            tab_dtcalcul = tab_dtcalcul + 1.
            NEXT.
        END.

   tab_diapagto = DAY(tab_dtcalcul).

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

tab_flgfolha = IF SUBSTRING(craptab.dstextab,14,1) = "0"
                  THEN FALSE
                  ELSE TRUE.

FIND crapepr WHERE crapepr.cdcooper = glb_cdcooper   AND
                   crapepr.nrdconta = par_nrdconta   AND
                   crapepr.nrctremp = par_nrctremp   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapepr   THEN
     DO:
         glb_cdcritic = 356.
         RETURN.
     END.
     
IF   tab_inusatab           AND
     crapepr.inliquid = 0   THEN
     DO:       
        FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper     AND  
                           craplcr.cdlcremp = crapepr.cdlcremp NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE craplcr   THEN
              DO:
                  glb_cdcritic = 363.
                  RETURN.
              END.
              
         aux_txdjuros = craplcr.txdiaria.
     END.
ELSE
     aux_txdjuros = crapepr.txjuremp.

IF   crapepr.tpemprst = 0 THEN /* TR */
     DO:
         ASSIGN aux_nrdconta = crapepr.nrdconta
                aux_nrctremp = crapepr.nrctremp
                aux_vlsdeved = crapepr.vlsdeved
                aux_vljuracu = crapepr.vljuracu
                aux_dtcalcul = ?
         
                aux_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) +
                                      4) - DAY(DATE(MONTH(glb_dtmvtolt),28,                           
                                        YEAR(glb_dtmvtolt)) + 4)).
         
         { includes/lelem.i }    /*  Rotina para calculo do saldo devedor  */
         
         ASSIGN par_vlsdeved = aux_vlsdeved
                par_qtprecal = lem_qtprecal.
     END.
ELSE IF crapepr.tpemprst = 1 THEN /* PP */
     DO:
         ASSIGN par_cdcooper = glb_cdcooper
                par_cdoperad = glb_cdoperad
                par_nmdatela = glb_nmdatela
                par_idorigem = 1
                par_idseqttl = 1
                par_dtmvtolt = glb_dtmvtolt
                par_flgerlog = FALSE.
         
         { sistema/generico/includes/b1wgen0002a.i }

         ASSIGN par_vlsdeved = aux_vlsdeved
                par_qtprecal = aux_qtprecal.
     END.
ELSE IF crapepr.tpemprst = 2 THEN /* POS */
     DO:
         { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

         /* Efetuar a chamada a rotina Oracle  */
         RUN STORED-PROCEDURE pc_busca_pagto_parc_pos_prog
             aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper,
                                                  INPUT STRING(glb_dtmvtolt),
                                                  INPUT STRING(glb_dtmvtoan),
                                                  INPUT par_nrdconta,
                                                  INPUT par_nrctremp,                                                  
                                                 OUTPUT 0,   /* pr_vlpreapg */
                                                 OUTPUT 0,   /* pr_vlprvenc */
                                                 OUTPUT 0,   /* pr_vlpraven */
                                                 OUTPUT 0,   /* pr_vlmtapar */
                                                 OUTPUT 0,   /* pr_vlmrapar */
                                                 OUTPUT 0,   /* pr_vliofcpl */
                                                 OUTPUT 0,   /* pr_cdcritic */
                                                 OUTPUT ""). /* pr_dscritic */  

         /* Fechar o procedimento para buscarmos o resultado */ 
         CLOSE STORED-PROC pc_busca_pagto_parc_pos_prog
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

         ASSIGN aux_vlprvenc = 0
                aux_vlpraven = 0
                aux_vlmtapar = 0
                aux_vlmrapar = 0
                aux_cdcritic = 0
                aux_dscritic = ""
                par_vlsdeved = pc_busca_pagto_parc_pos_prog.pr_vlsdeved
                               WHEN pc_busca_pagto_parc_pos_prog.pr_vlsdeved <> ?
                aux_vlprvenc = pc_busca_pagto_parc_pos_prog.pr_vlprvenc
                               WHEN pc_busca_pagto_parc_pos_prog.pr_vlprvenc <> ?
                aux_vlpraven = pc_busca_pagto_parc_pos_prog.pr_vlpraven
                               WHEN pc_busca_pagto_parc_pos_prog.pr_vlpraven <> ?
                aux_vlmtapar = pc_busca_pagto_parc_pos_prog.pr_vlmtapar
                               WHEN pc_busca_pagto_parc_pos_prog.pr_vlmtapar <> ?
                aux_vlmrapar = pc_busca_pagto_parc_pos_prog.pr_vlmrapar
                               WHEN pc_busca_pagto_parc_pos_prog.pr_vlmrapar <> ?
                aux_vliofcpl = pc_busca_pagto_parc_pos_prog.pr_vliofcpl
                               WHEN pc_busca_pagto_parc_pos_prog.pr_vliofcpl <> ?               
                aux_cdcritic = INT(pc_busca_pagto_parc_pos_prog.pr_cdcritic) 
                               WHEN pc_busca_pagto_parc_pos_prog.pr_cdcritic <> ?
                aux_dscritic = pc_busca_pagto_parc_pos_prog.pr_dscritic
                               WHEN pc_busca_pagto_parc_pos_prog.pr_dscritic <> ?.

         IF   aux_cdcritic <> 0    OR
              aux_dscritic <> ""   THEN
              DO:
                  glb_cdcritic = aux_cdcritic.
                  glb_dscritic = aux_dscritic.
                  RETURN.
              END.

         ASSIGN par_qtprecal = crapepr.qtprecal.
     END.

/* .......................................................................... */
