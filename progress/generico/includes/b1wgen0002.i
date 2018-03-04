/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
+--------------------------------------+--------------------------------------+
| Rotina Progress                      | Rotina Oracle PLSQL                  |
+--------------------------------------+--------------------------------------+
|sistema/generico/includes/b1wgen0002.i| empr0001.pc_calc_saldo_deved_epr_lem |
+--------------------------------------+--------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/









/*..............................................................................

   Programa: b1wgen0002.i                  
   Autora  : Mirtes.
   Data    : 14/09/2005                        Ultima atualizacao: 26/07/2017
    
   Dados referentes ao programa:

   Objetivo  : Include para calculo de saldo devedor em emprestimos.
               Baseado na includes/lelem.i.

   Alteracoes: 05/03/2008 - Adaptacao para alteracoes na BO b1wgen0002 (David).

               03/06/2008 - Incluir cdcooper nos FIND's da craphis (David).

               06/01/2011 - Se conta transferida nao deixar ler o craplem.
                            Lancamento do zeramento no 1 dia util (Magui).

               14/02/2011 - Igualar include a lelem.i (David).             

               19/03/2012 - Declarar a include b1wgen0002a.i (Tiago).

               18/06/2012 - Alteracao na leitura da craptco (David Kruger).

               26/11/2012 - Igualar inlcude a lelem.i (Oscar).

               21/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)

               15/05/2015 - Projeto 158 - Servico Folha de Pagto
                            (Andre Santos - SUPERO)
                            
               26/07/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)
                            
..............................................................................*/


DEF BUFFER crabemp FOR crapemp.
DEF BUFFER crabhis FOR craphis.

DEF VAR lem_dtmvtolt AS DATE                                           NO-UNDO.

DEF VAR lem_qtprecal AS DECI DECIMALS 4                                NO-UNDO.
DEF VAR lem_qtprepag AS DECI DECIMALS 4                                NO-UNDO.

DEF VAR lem_qtdpgmes AS INTE                                           NO-UNDO.
DEF VAR lem_varqtdpg AS INTE                                           NO-UNDO.

DEF VAR lem_exipgmes AS LOGI                                           NO-UNDO.

DEF VAR lem_vlrpgmes LIKE crapepr.vlpreemp EXTENT 30                   NO-UNDO.
                                                    
DEF        VAR lem_flctamig AS LOG                                     NO-UNDO.

IF  crapepr.tpemprst = 1 THEN  /* Price Pre-Fixada */
    DO:
       { sistema/generico/includes/b1wgen0002a.i } 
    END.
ELSE IF crapepr.tpemprst = 2 THEN /* Price Pos-Fixado */
    DO:
       FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

       /* Efetuar a chamada a rotina Oracle  */
       RUN STORED-PROCEDURE pc_busca_prest_pago_mes_pos
           aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                                INPUT crapepr.nrdconta,
                                                INPUT crapepr.nrctremp,
                                                INPUT STRING(par_dtmvtolt),
                                               OUTPUT 0,   /* pr_vllanmto */
                                               OUTPUT 0,   /* pr_cdcritic */
                                               OUTPUT ""). /* pr_dscritic */  

       /* Fechar o procedimento para buscarmos o resultado */ 
       CLOSE STORED-PROC pc_busca_prest_pago_mes_pos
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

       ASSIGN aux_vlpreemp = crapepr.vlpreemp /* Valor da Prestacao do Emprestimo */
              aux_qtprecal = crapepr.qtprecal /* Prestacao Pagas */
              aux_vlprepag = 0
              aux_cdcritic = 0
              aux_dscritic = ""
              aux_vlprepag = pc_busca_prest_pago_mes_pos.pr_vllanmto
                             WHEN pc_busca_prest_pago_mes_pos.pr_vllanmto <> ?
              aux_cdcritic = INT(pc_busca_prest_pago_mes_pos.pr_cdcritic) 
                             WHEN pc_busca_prest_pago_mes_pos.pr_cdcritic <> ?
              aux_dscritic = pc_busca_prest_pago_mes_pos.pr_dscritic
                             WHEN pc_busca_prest_pago_mes_pos.pr_dscritic <> ?.

       IF   aux_cdcritic <> 0    OR
            aux_dscritic <> ""   THEN
            DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                
                RETURN "NOK".
            END.

       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

       /* Efetuar a chamada a rotina Oracle  */
       RUN STORED-PROCEDURE pc_busca_pagto_parc_pos_prog
           aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
												INPUT par_cdprogra,
                                                INPUT STRING(par_dtmvtolt),
                                                INPUT STRING(crapdat.dtmvtoan),
                                                INPUT crapepr.nrdconta,
                                                INPUT crapepr.nrctremp,
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

       ASSIGN aux_vlpreapg = 0
              aux_vlprvenc = 0
              aux_vlpraven = 0
              aux_vlmtapar = 0
              aux_vlmrapar = 0
              aux_cdcritic = 0
              aux_dscritic = ""
              aux_vlsdeved = pc_busca_pagto_parc_pos_prog.pr_vlsdeved
                             WHEN pc_busca_pagto_parc_pos_prog.pr_vlsdeved <> ?
              aux_vlprvenc = pc_busca_pagto_parc_pos_prog.pr_vlprvenc
                             WHEN pc_busca_pagto_parc_pos_prog.pr_vlprvenc <> ?
              aux_vlpreapg = aux_vlprvenc
              aux_vlpraven = pc_busca_pagto_parc_pos_prog.pr_vlpraven
                             WHEN pc_busca_pagto_parc_pos_prog.pr_vlpraven <> ?
              aux_vlmtapar = pc_busca_pagto_parc_pos_prog.pr_vlmtapar
                             WHEN pc_busca_pagto_parc_pos_prog.pr_vlmtapar <> ?
              aux_vlmrapar = pc_busca_pagto_parc_pos_prog.pr_vlmrapar
                             WHEN pc_busca_pagto_parc_pos_prog.pr_vlmrapar <> ?
              aux_cdcritic = INT(pc_busca_pagto_parc_pos_prog.pr_cdcritic) 
                             WHEN pc_busca_pagto_parc_pos_prog.pr_cdcritic <> ?
              aux_dscritic = pc_busca_pagto_parc_pos_prog.pr_dscritic
                             WHEN pc_busca_pagto_parc_pos_prog.pr_dscritic <> ?.

       IF   aux_cdcritic <> 0    OR
            aux_dscritic <> ""   THEN
            DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                
                RETURN "NOK".
            END.
  
    END.
ELSE IF crapepr.tpemprst = 0 THEN /* Price TR */
DO:
    
        
    FIND crabemp WHERE crabemp.cdcooper = par_cdcooper     AND
                       crabemp.cdempres = crapepr.cdempres NO-LOCK NO-ERROR. 
    
    IF  AVAILABLE crabemp  THEN
        IF  (NOT crabemp.flgpagto OR NOT crabemp.flgpgtib)  THEN
            tab_diapagto = 0.
    
    IF  (tab_diapagto > 0) AND (NOT crapepr.flgpagto)  THEN
        tab_diapagto = 0.
    
    ASSIGN lem_dtmvtolt = par_dtmvtolt
           lem_flctamig = NO
           lem_qtprecal = 0
           lem_vlrpgmes = 0
           lem_qtdpgmes = 0
           aux_dtmesant = lem_dtmvtolt - DAY(lem_dtmvtolt)
           aux_nrdiacal = IF  MONTH(crapepr.dtmvtolt) = MONTH(lem_dtmvtolt)  AND
                              YEAR(crapepr.dtmvtolt)  = YEAR(lem_dtmvtolt)   THEN
                              DAY(crapepr.dtmvtolt)
                          ELSE 
                              0
           aux_vlprepag = 0
           aux_vljurmes = 0
           aux_inhst093 = FALSE
           aux_cdcritic = 0.
    
    /** Testa se esta rodando no batch e e' mensal **/
    IF  par_inproces > 2  THEN
        IF  CAN-DO("CRPS080,CRPS085,CRPS120",par_cdprogra)  THEN
            IF  MONTH(lem_dtmvtolt) <> MONTH(par_dtmvtopr)  THEN
                ASSIGN lem_dtmvtolt = aux_dtultdia
                       aux_dtmesant = aux_dtultdia
                       aux_nrdiacal = 0.
    
    
    IF  crapepr.inliquid = 1   AND
        crapepr.vlsdeved = 0   THEN
        DO:
            FIND craptco WHERE craptco.cdcopant = crapepr.cdcooper AND
                               craptco.nrctaant = crapepr.nrdconta AND
                               craptco.tpctatrf = 1                AND
                               craptco.flgativo = TRUE
                               NO-LOCK NO-ERROR.
            IF   AVAILABLE craptco   THEN
                 DO:
                     FIND LAST craplem
                         WHERE craplem.cdcooper = crapepr.cdcooper   AND
                               craplem.nrdconta = crapepr.nrdconta   AND
                               craplem.nrctremp = crapepr.nrctremp   AND
                               craplem.cdhistor = 921 /* zerado pela migracao */
                               NO-LOCK NO-ERROR.
                     IF   AVAILABLE craplem  THEN
                          ASSIGN lem_flctamig = YES.
                 END.
        END.
    
    DO WHILE TRUE:
       
        FOR EACH craplem WHERE craplem.cdcooper = par_cdcooper AND
                               craplem.nrdconta = aux_nrdconta AND
                               craplem.nrctremp = aux_nrctremp AND
                               CAN-DO("88,91,92,93,94,95,120,277,349,353,392,393,507,395,441,443", STRING(craplem.cdhistor)) AND
                               craplem.dtmvtolt > aux_dtmesant
                               NO-LOCK:

                                                                           
            /*** Conta migrada teve o seu zeramento no primeiro dia util do
                 mes seguinte ***/
            IF  lem_flctamig THEN
                NEXT.
             
            IF NOT CAN-FIND(crabhis WHERE crabhis.cdcooper = par_cdcooper     AND
                                          crabhis.cdhistor = craplem.cdhistor NO-LOCK) THEN
               DO:
                   aux_cdcritic = 80.
                   LEAVE.
               END.
    
            /** Calcula percentual pago na prestacao e/ou acerto **/

            IF  CAN-DO("88,91,92,93,94,95,120,277,349,353,392,393,507",
                       STRING(craplem.cdhistor))  THEN
                DO:
                    
                    IF  craplem.vlpreemp > 0  THEN
                        lem_qtprepag = ROUND(craplem.vllanmto /
                                             craplem.vlpreemp,4).

                    IF  CAN-DO("88,120,507",STRING(craplem.cdhistor))  THEN
                        lem_qtprecal = lem_qtprecal - lem_qtprepag.
                    ELSE
                        lem_qtprecal = lem_qtprecal + lem_qtprepag.
                END.
    
            aux_ddlanmto = DAY(craplem.dtmvtolt).
    
            IF  CAN-DO("91,92,94,277,349,353,392,393",STRING(craplem.cdhistor)) THEN
                DO:
                    aux_dtultpag = craplem.dtmvtolt.
    
                    IF  aux_vlsdeved > 0  THEN
                        IF  aux_nrdiacal > aux_ddlanmto  THEN
                            aux_vljurmes = aux_vljurmes + (craplem.vllanmto *
                                           aux_txdjuros * (aux_ddlanmto -
                                           aux_nrdiacal)).
                        ELSE
                            aux_vljurmes = aux_vljurmes + (aux_vlsdeved *
                                           aux_txdjuros * (aux_ddlanmto -
                                           aux_nrdiacal)).
    
                    aux_nrdiacal = IF  aux_nrdiacal > aux_ddlanmto  THEN
                                       aux_nrdiacal
                                   ELSE 
                                       aux_ddlanmto.
    
                    ASSIGN aux_vlsdeved = aux_vlsdeved - craplem.vllanmto
                           aux_vlprepag = aux_vlprepag + craplem.vllanmto
                           lem_qtdpgmes = lem_qtdpgmes + 1
                           lem_vlrpgmes[lem_qtdpgmes] = craplem.vllanmto.
                END.
            ELSE
            IF  craplem.cdhistor = 93 OR craplem.cdhistor = 95  THEN
                DO:
                    aux_dtultpag = craplem.dtmvtolt.
    
                    IF  aux_ddlanmto > tab_diapagto  THEN
                        IF  aux_vlsdeved > 0  THEN
                            ASSIGN aux_vljurmes = aux_vljurmes + (aux_vlsdeved *
                                                  aux_txdjuros * (aux_ddlanmto -
                                                  aux_nrdiacal))
                                   aux_nrdiacal = aux_ddlanmto.
                        ELSE
                            aux_nrdiacal = aux_ddlanmto.
                    ELSE
                        IF  aux_vlsdeved > 0  THEN
                            ASSIGN aux_vljurmes = aux_vljurmes + (aux_vlsdeved *
                                                  aux_txdjuros * (tab_diapagto - 
                                                  aux_nrdiacal))
                                   aux_nrdiacal = tab_diapagto
                                   aux_inhst093 = TRUE.
                        ELSE
                            aux_nrdiacal = tab_diapagto.
    
                    ASSIGN /*** aux_qtprepag = aux_qtprepag + 1 ***/
                           aux_vlsdeved = aux_vlsdeved - craplem.vllanmto
                           aux_vlprepag = aux_vlprepag + craplem.vllanmto
                           lem_qtdpgmes = lem_qtdpgmes + 1
                           lem_vlrpgmes[lem_qtdpgmes] = craplem.vllanmto.
                END.
            ELSE
            IF  CAN-DO("88,395,441,443,507",STRING(craplem.cdhistor))  THEN
                DO:
                    IF  aux_vlsdeved > 0  THEN
                        IF  aux_ddlanmto < tab_diapagto  THEN
                            IF  aux_nrdiacal = tab_diapagto  THEN
                                aux_vljurmes = aux_vljurmes +
                                               (craplem.vllanmto * aux_txdjuros *
                                               (tab_diapagto - aux_ddlanmto)).
                            ELSE
                                ASSIGN aux_vljurmes = aux_vljurmes + (aux_vlsdeved *
                                                      aux_txdjuros * (aux_ddlanmto -
                                                      aux_nrdiacal))
                                       aux_nrdiacal = aux_ddlanmto.
                        ELSE
                        IF  aux_ddlanmto > tab_diapagto  THEN
                            ASSIGN aux_vljurmes = aux_vljurmes +
                                                  (aux_vlsdeved * aux_txdjuros *
                                                  (aux_ddlanmto - aux_nrdiacal))
                                   aux_nrdiacal = aux_ddlanmto.
                        ELSE 
                            .
                    ELSE
                        aux_nrdiacal = IF  aux_nrdiacal > aux_ddlanmto  THEN
                                           aux_nrdiacal
                                       ELSE 
                                           aux_ddlanmto.
                    
                    IF  craplem.cdhistor = 88   OR
                        craplem.cdhistor = 507  THEN /** estorno de pagamento **/
                        DO:
                            ASSIGN aux_vlprepag = aux_vlprepag - craplem.vllanmto.
                             
                            IF  aux_vlprepag < 0  THEN
                                aux_vlprepag = 0.
                        END.
                         
                    ASSIGN aux_vlsdeved = aux_vlsdeved + craplem.vllanmto
                           lem_exipgmes = NO.
    
                    DO lem_varqtdpg = 1 TO lem_qtdpgmes:
                       
                        IF  lem_vlrpgmes[lem_varqtdpg] = craplem.vllanmto  THEN
                            DO:
                                ASSIGN lem_exipgmes = YES.
                                LEAVE.
                            END.    
                    END. 
                    
                    IF  lem_exipgmes  THEN
                        DO:
                            IF  craplem.cdhistor <> 88   AND
                                craplem.cdhistor <> 507  THEN
                                aux_vlprepag = IF aux_vlprepag >= craplem.vllanmto
                                               THEN aux_vlprepag - craplem.vllanmto
                                               ELSE 0.
    
                        END.
                END.
    
        END. /** Fim do FOR EACH craplem **/
    
        IF  aux_cdcritic > 0  THEN
            LEAVE.
    
        IF  par_inproces > 2  THEN
            IF  CAN-DO("CRPS080,CRPS085,CRPS120",par_cdprogra)  THEN
                IF  MONTH(lem_dtmvtolt) <> MONTH(par_dtmvtopr)  THEN
                    aux_nrdiacal = 0.
                ELSE
                    aux_nrdiacal = DAY(lem_dtmvtolt) - aux_nrdiacal.
            ELSE
                IF  MONTH(lem_dtmvtolt) <> MONTH(par_dtmvtopr)  THEN
                    aux_nrdiacal = DAY(aux_dtultdia) - aux_nrdiacal.
                ELSE
                    aux_nrdiacal = DAY(lem_dtmvtolt) - aux_nrdiacal.
        ELSE
            aux_nrdiacal = DAY(lem_dtmvtolt) - aux_nrdiacal.
    
        ASSIGN aux_vljurmes = IF  aux_vlsdeved > 0  THEN
                                  aux_vljurmes + (aux_vlsdeved * aux_txdjuros *
                                  aux_nrdiacal)
                              ELSE 
                                  aux_vljurmes
    
               aux_qtprepag = TRUNCATE(lem_qtprecal,0).
    
        LEAVE.
    
    END. /** Fim do DO WHILE TRUE **/
    
    aux_nrdiacal = 0.
    
    IF  aux_dtcalcul <> ?  AND
        aux_vlsdeved  > 0  THEN
        DO:
            ASSIGN aux_nrdiacal = aux_dtcalcul - lem_dtmvtolt
                   aux_nrdiames = IF  aux_dtcalcul > aux_dtultdia  THEN
                                      DAY(aux_dtultdia) - DAY(lem_dtmvtolt)
                                  ELSE 
                                      aux_nrdiacal
                   aux_nrdiamss = IF  aux_dtcalcul > aux_dtultdia  THEN
                                      aux_nrdiacal - aux_nrdiames
                                  ELSE 
                                      0.
    
            IF  aux_nrdiamss = 0  THEN
                aux_vljurmes = aux_vljurmes + (aux_vlsdeved *
                               aux_txdjuros * aux_nrdiames).
            ELSE
                ASSIGN aux_vljurmes = aux_vljurmes + (aux_vlsdeved *
                                      aux_txdjuros * aux_nrdiames)
                       aux_vljurmes = ROUND(aux_vljurmes,2)
                       aux_vlsdeved = aux_vlsdeved + aux_vljurmes
                       aux_vljuracu = aux_vljuracu + aux_vljurmes
                       aux_vljurmes = aux_vlsdeved * aux_txdjuros * aux_nrdiamss.
    
            ASSIGN aux_nrdiacal = IF  DAY(aux_dtcalcul) < tab_diapagto  THEN
                                      tab_diapagto - DAY(aux_dtcalcul)
                                  ELSE 
                                      0.
        END.
    ELSE
        IF  DAY(lem_dtmvtolt) < tab_diapagto  AND
            par_inproces < 3                  AND
            aux_vlsdeved > 0                  AND
            NOT aux_inhst093                  THEN
            aux_nrdiacal = tab_diapagto - DAY(lem_dtmvtolt).
        ELSE
            aux_nrdiacal = 0.
    
    /** Calcula juros sobre a prest. quando a consulta e' menor que o data pagto **/
    IF  aux_nrdiacal > 0 AND crapepr.dtdpagto <= aux_dtultdia  THEN
        IF  aux_vlsdeved > crapepr.vlpreemp  THEN
            aux_vljurmes = aux_vljurmes + (crapepr.vlpreemp * aux_txdjuros *
                                           aux_nrdiacal).
        ELSE
            aux_vljurmes = aux_vljurmes + (aux_vlsdeved * aux_txdjuros *
                                           aux_nrdiacal).
    
    ASSIGN aux_vljurmes = ROUND(aux_vljurmes,2)
           aux_vljuracu = aux_vljuracu + aux_vljurmes
           aux_vlsdeved = aux_vlsdeved + aux_vljurmes.
    
    IF  aux_vlsdeved > 0 AND crapepr.inliquid > 0  THEN
        DO:
            IF  par_inproces > 2 AND par_cdprogra = "crps078"  THEN
                DO:
                    IF  aux_vljurmes >= aux_vlsdeved  THEN
                        DO:
                            ASSIGN aux_vljurmes = aux_vljurmes - aux_vlsdeved
                                   aux_vljuracu = aux_vljuracu - aux_vlsdeved
                                   aux_vlsdeved = 0.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "ATENCAO: NAO FOI POSSIVEL " +
                                                  "ZERAR O SALDO - CONTA = " +
                                                  STRING(crapepr.nrdconta,
                                                         "zzzz,zzz,9") +
                                                  " CONTRATO = " +
                                                  STRING(crapepr.nrctremp,
                                                         "zz,zzz,zz9") +
                                                  " SALDO = " +
                                                  STRING(aux_vlsdeved,
                                                         "zzz,zz9.99").
                                   
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,            /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                            
                            RETURN "NOK".
                        END.  
                END.
            ELSE
                ASSIGN aux_vljurmes = aux_vljurmes - aux_vlsdeved
                       aux_vljuracu = aux_vljuracu - aux_vlsdeved
                       aux_vlsdeved = 0.
        END.
END.
/*............................................................................*/    

