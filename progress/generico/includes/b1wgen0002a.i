/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
+---------------------------------------+--------------------------------------+
| Rotina Progress                       | Rotina Oracle PLSQL                  |
+---------------------------------------+--------------------------------------+
|sistema/generico/includes/b1wgen0002a.i| Não necessário                                     |
+---------------------------------------+--------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/




/*..............................................................................

   Programa: b1wgen0002a.i                  
   Autor   : Tiago.
   Data    : 06/03/2012                        Ultima atualizacao: 29/06/2015
    
   Dados referentes ao programa:

   Objetivo  : Include para busca de dados da prestacao quando tpemprst = 1.

   Alteracoes: 07/01/2014 - Ajuste para melhorar a performance (James).
   
               15/01/2014 - Ajuste para inicializar as variaveis com 0 (James).
               
               05/03/2014 - Ajuste para calcular multa e Juros de Mora (James).
               
               12/03/2014 - Ajuste para pegar o prazo de atraso da tabela
                            crapepr.qttolatr e nao mais da tab089. (James)
                            
               25/03/2014 - Ajuste para calcular o valor vencido e o valor a 
                            vencer para a tela LAUTOM. (James)
                            
               02/05/2014 - Ajuste no calculo da tolerancia da multa e Juros
                            de Mora.(James)
                            
               12/06/2014 - Ajuste no calculo para pagamento de avalista. (James)
               
               31/07/2014 - Ajuste para filtrar a parcela na tabela craplem.
                            (James)
                            
               30/03/2015 - Remover a verificacao se a linha de credito eh
                            emprestimo ou financimanento. (James)
                            
               21/05/2015 - Ajuste para verificar se a Linha de Credito
                            Cobra Multa. (James)
                            
               29/06/2015 - Projeto 215 - DV 3 (Daniel) 
               
               09/10/2015 - Incluir históricos de Estorno PP (Oscar).
               
..............................................................................*/
DEF VAR aux_flgtrans AS LOGI                                        NO-UNDO.
DEF VAR aux_ehmensal AS LOGI INIT FALSE                             NO-UNDO.
DEF VAR aux_dtmvtolt AS DATE                                        NO-UNDO.
DEF VAR aux_dtdpagto AS DATE                                        NO-UNDO.
DEF VAR aux_dtdfinal AS DATE                                        NO-UNDO.
DEF VAR aux_dtdinici AS DATE                                        NO-UNDO.
DEF VAR aux_vlatupar AS DECI FORMAT "zzz,zzz,zz9.99" DECIMALS 2     NO-UNDO.
DEF VAR aux_vlsderel AS DECI                                        NO-UNDO.
DEF VAR aux_qtdianor AS DECI                                        NO-UNDO.
DEF VAR aux_qtdiamor AS DECI                                        NO-UNDO.
DEF VAR aux_prtljuro AS DECI                                        NO-UNDO.
DEF VAR aux_percmult AS DECI                                        NO-UNDO.
DEF VAR aux_txdiaria AS DECI DECIMALS 10                            NO-UNDO.
DEF VAR aux_qtdedias AS INTE                                        NO-UNDO.
DEF VAR aux_nrdolote AS INTE EXTENT 3                               NO-UNDO.
DEF VAR aux_cdhistor LIKE craplem.cdhistor EXTENT 8                 NO-UNDO.
DEF VAR aux_diapagto AS INTE                                        NO-UNDO.
DEF VAR aux_anofinal AS INTE                                        NO-UNDO.
DEF VAR aux_mesfinal AS INTE                                        NO-UNDO.
DEF VAR aux_diafinal AS INTE                                        NO-UNDO.
DEF VAR aux_anoinici AS INTE                                        NO-UNDO.
DEF VAR aux_mesinici AS INTE                                        NO-UNDO.
DEF VAR aux_diainici AS INTE                                        NO-UNDO.
DEF VAR aux_nrdiamta AS INTE                                        NO-UNDO.
DEF VAR aux_conthist AS INTE                                        NO-UNDO.
DEF VAR aux_contlote AS INTE                                        NO-UNDO.
/* DEF VAR aux_vliofcpl AS DECI                                        NO-UNDO. */
DEF VAR aux_vlbaseiof AS DECI                                        NO-UNDO.

DEF BUFFER crabhis_1 FOR craphis.

ASSIGN aux_vlsdeved = crapepr.vlsdeved  
       aux_vlpreemp = crapepr.vlpreemp 
       aux_qtprecal = crapepr.qtprecal
       aux_vljuracu = crapepr.vljuracu
       aux_qtpreemp = crapepr.qtpreemp 
       aux_qtmesdec = crapepr.qtmesdec
       aux_vlatupar = 0
       aux_vlpreapg = 0
       aux_vlsderel = 0
       aux_vlprepag = 0
       aux_vlprvenc = 0
       aux_vlpraven = 0
       aux_vliofcpl = 0
       aux_vlbaseiof = 0.
      
FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

BUSCA:
DO ON ERROR UNDO , LEAVE:

   FIND craplcr WHERE craplcr.cdcooper = crapepr.cdcooper AND
                      craplcr.cdlcremp = crapepr.cdlcremp
                      NO-LOCK NO-ERROR.

   IF NOT AVAIL craplcr THEN
      DO:
          ASSIGN aux_cdcritic = 363.
          LEAVE BUSCA.
      END.

   /* Verifica se a Linha de Credito Cobra Multa */
   IF craplcr.flgcobmu THEN
      DO:
          /* Obter o % de multa da CECRED - TAB090 */
          FIND craptab WHERE craptab.cdcooper = 3           AND
                             craptab.nmsistem = "CRED"      AND
                             craptab.tptabela = "USUARI"    AND
                             craptab.cdempres = 11          AND
                             craptab.cdacesso = "PAREMPCTL" AND
                             craptab.tpregist = 01
                             NO-LOCK NO-ERROR.
        
          IF NOT AVAIL craptab THEN
             DO:
                 ASSIGN aux_cdcritic = 55.
                 LEAVE BUSCA.
             END.

          ASSIGN aux_percmult = DEC(SUBSTRING(craptab.dstextab,1,6)).

      END. /* END IF craplcr.flgcobmu THEN */
   ELSE
      ASSIGN aux_percmult = 0.

   ASSIGN /* Prazo para tolerancia da multa */
          aux_nrdiamta = crapepr.qttolatr
          /* Prazo de tolerancia para incidencia de juros de mora */
          aux_prtljuro = aux_nrdiamta.

   FIND crawepr WHERE crawepr.cdcooper = crapepr.cdcooper AND
                      crawepr.nrdconta = crapepr.nrdconta AND
                      crawepr.nrctremp = crapepr.nrctremp
                      NO-LOCK NO-ERROR.
                      
   IF NOT AVAIL crawepr THEN
      DO:
          ASSIGN aux_cdcritic = 535.
          LEAVE BUSCA.
      END.

   FOR EACH crappep WHERE crappep.cdcooper = crapepr.cdcooper AND
                          crappep.nrdconta = crapepr.nrdconta AND
                          crappep.nrctremp = crapepr.nrctremp AND 
                          crappep.inliquid = 0 /* nao liquidada */ 
                          NO-LOCK:

       IF par_dtmvtolt <= crawepr.dtlibera THEN /* Nao liberado */
          DO:
              ASSIGN aux_vlatupar = crapepr.vlemprst / crapepr.qtpreemp.
          END.
       ELSE    
          IF crappep.dtvencto > crapdat.dtmvtoan AND 
             crappep.dtvencto <= par_dtmvtolt    THEN /* Parcela em dia */
             DO:
                 ASSIGN aux_vlatupar = crappep.vlsdvpar
                        aux_vlpreapg = aux_vlpreapg + aux_vlatupar
                        aux_vlpraven = aux_vlpraven + aux_vlatupar.
             END.
       ELSE
          IF crappep.dtvencto < par_dtmvtolt   THEN /* Parcela Vencida */
             DO:
                 /* Se ainda nao pagou nada da parcela, pegar a data 
                    de vencimento dela */
                 IF crappep.dtultpag = ?                OR
                    crappep.dtultpag < crappep.dtvencto THEN
                    DO:
                        ASSIGN aux_dtmvtolt = crappep.dtvencto.
                    END.
                 ELSE
                    DO: /* Senao pegar a ultima data que pagou a parcela  */
                        ASSIGN aux_dtmvtolt = crappep.dtultpag. 
                    END.
                        
                 ASSIGN aux_dtdpagto = crapepr.dtdpagto
                        aux_dtdinici = aux_dtmvtolt
                        aux_dtdfinal = par_dtmvtolt.

                 /** Rotina para calculo dias360 **/
                 { includes/dias360.i }

                 /* Calcula quantos dias passaram do vencimento até o parametro 
                    par_dtmvtolt será usado para comparar se a quantidade de 
                    dias que passou está dentro da tolerância */
                 ASSIGN aux_qtdianor = par_dtmvtolt - crappep.dtvencto.

                 /* Se ainda nao pagou nada da parcela, pegar a data de 
                    vencimento dela */
                 IF crappep.dtultpag <> ? OR crappep.vlpagmra > 0 THEN
                    DO: 
                               /* Financiamento */
                        ASSIGN aux_cdhistor[1] = 1078
                               aux_cdhistor[2] = 1620

                               /* Emprestimo */
                               aux_cdhistor[3] = 1077
                               aux_cdhistor[4] = 1619.
                        
                        DO aux_conthist = 1 TO 4:

                           /* Obter ultimo lancamento de juro do contrato */
                           FOR EACH craplem FIELDS(dtmvtolt)
                              WHERE craplem.cdcooper = crapepr.cdcooper AND
                                    craplem.nrdconta = crapepr.nrdconta AND
                                    craplem.nrctremp = crapepr.nrctremp AND
                                    craplem.nrparepr = crappep.nrparepr AND
                                    craplem.cdhistor = aux_cdhistor[aux_conthist]
                                    NO-LOCK:
                           
                               IF craplem.dtmvtolt > aux_dtmvtolt OR
                                  aux_dtmvtolt = ?                THEN
                                  ASSIGN aux_dtmvtolt = craplem.dtmvtolt.
                           
                           END. /* END FOR EACH craplem */

                        END. /* END DO aux_conthist */

                    END. /* END IF crabpep.dtultpag <> ? */

                 /* Calcular quantidade de dias para o juros de mora desde 
                    o ultima ocorrência de juros de mora/vencimento até o 
                    par_dtmvtolt */
                 ASSIGN aux_qtdiamor = par_dtmvtolt - aux_dtmvtolt.  

                 /* Verifica se esta na tolerancia da multa, 
                    aux_qtdianor é quantidade de dias que passaram 
                    aux_nrdiamta é quantidade de dias de tolerância parametrizada */
                 ASSIGN aux_percmult = IF aux_qtdianor <= aux_nrdiamta THEN
                                          0
                                       ELSE 
                                          aux_percmult
                        
                        aux_vlmtapar = aux_vlmtapar + 
                                       ROUND(crappep.vlparepr * aux_percmult / 100,2) - 
                                       crappep.vlpagmta
                        
                        aux_vlatupar = crappep.vlsdvpar * 
                                       EXP((1 + crapepr.txmensal / 100), 
                                           ( aux_qtdedias / 30) )
                        aux_vlpreapg = aux_vlpreapg + aux_vlatupar
                        aux_vlprvenc = aux_vlprvenc + aux_vlatupar.
                  
                 /* Verifica se esta na tolerancia dos juros de mora, 
                    aux_qtdianor é quantidade de dias que passaram 
                    aux_prtljuro é quantidade de dias de tolerância 
                    parametrizada */
                 IF aux_qtdianor <= aux_prtljuro THEN
                    DO:
                        ASSIGN aux_vlmrapar = aux_vlmrapar + 0.
                    END.
                 ELSE
                    DO:
                        ASSIGN aux_txdiaria = 
                                  ROUND((100 * (EXP((craplcr.perjurmo / 100) + 1,
                                                    (1 / 30)) - 1)),10)
            
                               aux_txdiaria = aux_txdiaria / 100
                               aux_vlmrapar = aux_vlmrapar + 
                                              (crappep.vlsdvsji * 
                                               aux_txdiaria     * 
                                               aux_qtdiamor).
                    END.

                    
                  /* Verifica se ha contratos de acordo */            
                 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
                 aux_vlbaseiof = ROUND(crappep.vlsdvpar / ((EXP(( 1 + crapepr.txmensal / 100), 
                                (crapepr.qtpreemp - crappep.nrparepr + 1) ))), 2).
                                
                          
                 RUN STORED-PROCEDURE pc_calcula_valor_iof_epr
                    aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapepr.cdcooper
                                                        ,INPUT crapepr.nrdconta
                                                        ,INPUT crapepr.nrctremp
                                                        ,INPUT aux_vlbaseiof /* vr_vlbaseiof */
                                                        ,INPUT aux_vlbaseiof /* vr_vlbaseiof */
                                                        ,INPUT ""
                                                        ,INPUT crapepr.cdlcremp /* pr_cdlcremp */
                                                        ,INPUT par_dtmvtolt /* pr_dtmvtolt */
                                                        ,INPUT aux_qtdianor /* vr_qtdiamor */
                                                        ,OUTPUT 0 /* pr_vliofpri */
                                                        ,OUTPUT 0 /* pr_vliofadi */
                                                        ,OUTPUT 0 /* pr_vliofcpl */
                                                        ,OUTPUT 0 /* pr_vltaxa_iof_principal */
                                                        ,OUTPUT 0 /* pr_flgimune */
                                                        ,OUTPUT "" /* pr_dscritic */).
                                                      
                CLOSE STORED-PROC pc_calcula_valor_iof_epr
                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                ASSIGN aux_vliofcpl = aux_vliofcpl + pc_calcula_valor_iof_epr.pr_vliofcpl WHEN pc_calcula_valor_iof_epr.pr_vliofcpl <> ?.

             END. /* END Parcela Vencida */
       ELSE
          IF crappep.dtvencto > par_dtmvtolt THEN /* Parcela a Vencer */
             DO: 
                 ASSIGN aux_dtdpagto = crapepr.dtdpagto
                        aux_dtdinici = par_dtmvtolt
                        aux_dtdfinal = crappep.dtvencto.

                 /** Rotina para calculo dias360 **/
                 { includes/dias360.i }

                 ASSIGN aux_vlatupar = ROUND(crappep.vlsdvpar * 
                                             EXP(1 + (crapepr.txmensal / 100),
                                                 - aux_qtdedias / 30),2).

                 /* Valor a vencer dentro do mes */
                 IF ((MONTH(crappep.dtvencto) = MONTH(par_dtmvtolt)) AND 
                     (YEAR(crappep.dtvencto)  = YEAR(par_dtmvtolt))) THEN
                    DO:
                        ASSIGN aux_vlpraven = aux_vlpraven + crappep.vlsdvpar.
                    END.

             END. /* END Parcela a Vencer */

       IF NOT par_dtmvtolt <= crawepr.dtlibera THEN /* Se liberado */
          DO:
              /* Saldo devedor */
              ASSIGN aux_vlsderel = aux_vlsderel + aux_vlatupar.
          END.
             
   END. /* END FOR EACH crappep */
   
          /* Financiamento */
   ASSIGN aux_nrdolote[1] = 600013
          /* Emprestimo */
          aux_nrdolote[2] = 600012
          /* Estorno */
          aux_nrdolote[3] = 600031

          /* Financiamento */
          aux_cdhistor[1] = 1039
          aux_cdhistor[2] = 1057
          /* Emprestimo */
          aux_cdhistor[3] = 1044
          aux_cdhistor[4] = 1045

          /* Estorno Financiamento */
          aux_cdhistor[5] = 1716
          aux_cdhistor[6] = 1707

          /* Estorno Emprestimo */
          aux_cdhistor[7] = 1714
          aux_cdhistor[8] = 1705.

   
   DO aux_contlote = 1 TO 3:

       DO aux_conthist = 1 TO 8:
              
          /* Total pago no mes */
          FOR EACH craplem 
              WHERE craplem.cdcooper = crapepr.cdcooper           AND
                    craplem.nrdconta = crapepr.nrdconta           AND
                    craplem.nrctremp = crapepr.nrctremp           AND
                    craplem.nrdolote = aux_nrdolote[aux_contlote] AND
                    craplem.cdhistor = aux_cdhistor[aux_conthist]
                    NO-LOCK:
    
              IF YEAR(par_dtmvtolt)  = YEAR(craplem.dtmvtolt)  AND
                 MONTH(par_dtmvtolt) = MONTH(craplem.dtmvtolt) THEN
                 DO:
                   FOR FIRST crabhis_1 FIELDS(indebcre)
                       WHERE crabhis_1.cdcooper = craplem.cdcooper
                         AND crabhis_1.cdhistor = craplem.cdhistor 
                   NO-LOCK: END.

                   IF NOT AVAIL(crabhis_1) THEN
                      DO:
                         ASSIGN aux_cdcritic = 356
                                aux_dscritic = "".

                         RUN gera_erro (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT 1, 
                                        INPUT aux_cdcritic,
                                        INPUT-OUTPUT aux_dscritic).
                         RETURN "NOK".
                      END.
                   
                   IF (crabhis_1.indebcre = "C") THEN
                      ASSIGN aux_vlprepag = aux_vlprepag + craplem.vllanmto.
                   ELSE
                   IF (crabhis_1.indebcre = "D") THEN
                      ASSIGN aux_vlprepag = aux_vlprepag - craplem.vllanmto.

                 END.

          END. /* FOR EACH craplem */

       END. /* END DO aux_conthist */

   END. /* END DO aux_contlote */

   IF (par_dtmvtolt <= crawepr.dtlibera) AND crapepr.inliquid <> 1 THEN /* Nao liberado */
      DO:
          ASSIGN aux_vlsdeved = crapepr.vlemprst
                 aux_vlprepag = 0 
                 aux_vlpreapg = 0.
				 
		  /* Projeto 410 - Se financia IOF, incrementar IOF + Tarifa ao saldo devedor */		 
	      IF crawepr.idfiniof = 1 THEN
		     ASSIGN aux_vlsdeved = crapepr.vlemprst + crapepr.vliofepr + crapepr.vltarifa.
      END.
   ELSE
      DO:
          ASSIGN aux_vlsdeved = aux_vlsderel + aux_vliofcpl.
      END.

   ASSIGN aux_flgtrans = TRUE.

END. /* END BUSCA */

IF NOT aux_flgtrans THEN
   DO:
       RUN gera_erro (INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT 1, 
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).
       RETURN "NOK".
   END.
/* ......................................................................... */
