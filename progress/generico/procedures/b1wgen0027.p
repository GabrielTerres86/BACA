/* *****************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
+----------------------------------------+-------------------------------------+
| Rotina Progress                        | Rotina Oracle PLSQL                 |
+----------------------------------------+-------------------------------------+
| lista_estouros                         | EMPR0001.pc_lista_estouros          |
+----------------------------------------+-------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - Daniel Zimmermann    (CECRED)
   - Marcos Martini       (SUPERO)

****************************************************************************** */

/*..............................................................................

    Programa  : b1wgen0027.p
    Autor     : Guilherme
    Data      : Fevereiro/2008                Ultima Atualizacao: 24/01/2018
    
    Dados referentes ao programa:

    Objetivo  : BO ref. Rotina OCORRENCIAS da tela ATENDA.

    Alteracoes: 03/06/2008 - Incluir cdcooper nos FIND's da craphis (David).

                29/07/2008 - Correcao na procedure lista_emprestimos (David).
                
                10/11/2008 - Limpar variaveis de erro, dar return ok (Guilherme)

                04/03/2008 - Incluir rotina de extratos_emitidos_no_cash (Ze).

                28/04/2009 - Alimentar variavel aux_dsdrisco[10] = "H" (David).
                
                02/10/2009 - Aumento do campo nrterfin (Diego).
                
                23/11/2009 - Alteracao Codigo Historico (Kbase).
                
                04/12/2009 - Mudar o indrisco da crapass para crapnrc
                             (Gabriel).
                             
                18/08/2010 - Incluido os campos dtdrisco e qtdiaris na 
                             temp-table tt-ocorren referente a procedure
                             lista_ocorren (Elton).
                             
                06/10/2010 - Mostra risco e data do risco do cooperado na 
                             procedure lista_ocorren do mes atual  (Elton).
                             
                04/02/2011 - Incluir parametro par_flgcondc na procedure 
                             obtem-dados-emprestimos  (Gabriel - DB1).             
                             
                07/02/2011 - Nos extratos emitidos no TAA, mostrar a data do
                             dia que o extrato foi retirado e ajuste na busca
                             do PAC (Evandro)
                             
                04/03/2011 - Inclusao dos campos inrisctl e dtrisctl na 
                             temp-table tt-ocorren referente a procedure
                             lista_ocorren. (Fabricio)
                             
                19/04/2011 - Tratamento para o campo inrisctl na procedure
                             lista_ocorren, para não vir risco como 'AA'.
                             (Fabricio)
                             
                09/12/2011 - Sustação provisória (André R./Supero).
                
                04/07/2012 - Tratamento do cdoperad "operador" de INTE para CHAR.
                             (Lucas R.)    
                             
                30/07/2012 - Tratar prejuizo para o novo tipo de emprestimo
                             (Gabriel).    
                             
                29/11/2012 - Ajuste na procedure lista_ocorren para alimentar
                             o campo tt-ocorren.dsdrisgp - "Risco do Grupo" 
                             (Adriano). 
                                      
                06/02/2014 - Ajuste para carregar cash corretamente atraves da
                             Coop do TAA em proc extratos_emitidos_no_cash. 
                             (Jorge)
                             
                24/02/2014 - Adicionado param. de paginacao em procedure
                             obtem-dados-emprestimos em BO 0002.(Jorge)
                
                19/06/2015 - Ajuste para alimentar o campo tt-ocorren.innivris
                             na procedure lista_ocorren. (James)             

                30/01/2017 - Exibir mensagem de atrasado quando for produto Pos-Fixado.
                             (Jaison/James - PRJ298)
					 
                24/01/2018 - Ajuste na extratos_emitidos_no_cash para mostrar apenas
                             extratos com numero do terminal financeiro (Tiago #824708).
                              
                12/03/2018 - Alterado para buscar descricao do tipo de conta do oracle. 
                             PRJ366 (Lombardi).
                             
                09/01/2019 - P298.2.2 - Luciano (Supero) - Na tela Atenda > Ocorrencias> Prejuízo> 
                             deverá apresentar as informaçoes de prejuízo do contrato Pós-Fixado.

                09/04/2019 - Alterado na lista_ocorren, para buscar o risco a partir da rotina 
                             RATI0003.pc_ret_risco_tbrisco, em substituição a tabela crapnrc. 
                             P450-Rating (Elton/Amcom).

..............................................................................*/

{ sistema/generico/includes/b1wgen0027tt.i }
{ sistema/generico/includes/b1wgen0002tt.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.

PROCEDURE lista_ocorren:

    DEF  INPUT  PARAM  par_cdcooper  AS  INTE                          NO-UNDO.
    DEF  INPUT  PARAM  par_cdagenci  AS  INTE /** 0-TODOS **/          NO-UNDO.
    DEF  INPUT  PARAM  par_nrdcaixa  AS  INTE                          NO-UNDO.
    DEF  INPUT  PARAM  par_cdoperad  AS  CHAR                          NO-UNDO.
    DEF  INPUT  PARAM  par_nrdconta  AS  INTE                          NO-UNDO.
    DEF  INPUT  PARAM  par_dtmvtolt  AS  DATE                          NO-UNDO.
    DEF  INPUT  PARAM  par_dtmvtopr  AS  DATE                          NO-UNDO.
    DEF  INPUT  PARAM  par_inproces  AS  INTE                          NO-UNDO.
    DEF  INPUT  PARAM  par_idorigem  AS  INTE                          NO-UNDO.
    DEF  INPUT  PARAM  par_idseqttl  AS  INTE                          NO-UNDO.
    DEF  INPUT  PARAM  par_nmdatela  AS  CHAR                          NO-UNDO.
    DEF  INPUT  PARAM  par_flgerlog  AS  LOGI                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-ocorren.

    DEF VAR aux_qtctrord AS INTE                                       NO-UNDO.
    DEF VAR aux_qtdevolu AS INTE                                       NO-UNDO.
    DEF VAR aux_flginadi AS LOGI                                       NO-UNDO.
    DEF VAR aux_flglbace AS LOGI                                       NO-UNDO.
    DEF VAR aux_flgeprat AS LOGI                                       NO-UNDO.
    DEF VAR aux_indrisco AS INTE                                       NO-UNDO.
    DEF VAR aux_nivrisco AS CHAR                                       NO-UNDO.
    DEF VAR aux_flgpreju AS LOGI                                       NO-UNDO.
    DEF VAR aux_flgjucta AS LOGI                                       NO-UNDO.
    DEF VAR aux_flgocorr AS LOGI                                       NO-UNDO.
    DEF VAR aux_dtdrisco AS DATE                                       NO-UNDO.
    DEF VAR aux_qtdiaris AS INTE                                       NO-UNDO.
    DEF VAR aux_dtrefere AS DATE                                       NO-UNDO.
    DEF VAR aux_nrdgrupo AS INT                                        NO-UNDO.
    DEF VAR aux_gergrupo AS CHAR                                       NO-UNDO.
    DEF VAR aux_dsdrisgp AS CHAR                                       NO-UNDO.


    DEF VAR aux_contador    AS INTE                                    NO-UNDO.
    DEF VAR aux_vlr_arrasto AS DECIMAL                                 NO-UNDO.
    DEF VAR aux_dsdrisco    AS CHAR   FORMAT "x(02)" EXTENT 20         NO-UNDO.
    DEF VAR aux_qtregist    AS INTE                                    NO-UNDO.
    DEF VAR aux_innivris    LIKE crapris.innivris                      NO-UNDO.
    
    /* Variaveis para rotina pc_ret_risco_tbrisco */
    DEF VAR aux_risco_rat          AS INTE                             NO-UNDO. /* P450 - Rating */
    DEF VAR aux_indrisco_rat       AS CHAR                             NO-UNDO. /* P450 - Rating */ 
    DEF VAR aux_habrat             AS CHAR                             NO-UNDO. /* P450 - Rating */
    
    DEF VAR h-b1wgen0002    AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0138    AS HANDLE                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-ocorren.

    /** Atribui descricao da origem e da transacao **/
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar ocorrencias.".

    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper
                             NO-LOCK NO-ERROR.
    
    IF   NOT AVAIL crapdat   THEN
         DO:
             ASSIGN aux_cdcritic = 1
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
                 
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_cdcritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT FALSE,
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).              
                           
             RETURN "NOK".
         END.

    
    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                             crapass.nrdconta = par_nrdconta
                             NO-LOCK NO-ERROR.
    
    IF   NOT AVAIL crapass   THEN
         DO:
             ASSIGN aux_cdcritic = 9
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
                 
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_cdcritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT FALSE,
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).              
                           
             RETURN "NOK".

         END.
    
    ASSIGN aux_flginadi = IF   crapass.inadimpl = 0 THEN
                               FALSE
                          ELSE 
                               TRUE
           aux_flglbace = IF   crapass.inlbacen = 0  THEN
                               FALSE
                          ELSE 
                               TRUE
           aux_flgjucta = IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl)) THEN
                               TRUE
                          ELSE 
                               FALSE
           aux_qtctrord = 0
           aux_qtdevolu = 0.
    
    FIND FIRST crapsld WHERE crapsld.cdcooper = par_cdcooper AND 
                             crapsld.nrdconta = crapass.nrdconta
                             NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapsld   THEN
         DO:
            ASSIGN aux_cdcritic = 10
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).        

            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT aux_cdcritic,
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT FALSE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
                           
            RETURN "NOK".

         END.

    FOR EACH crapcor WHERE crapcor.cdcooper = par_cdcooper      AND
                           crapcor.nrdconta = par_nrdconta      AND 
                           crapcor.flgativo = TRUE              
                           NO-LOCK:

        ASSIGN aux_qtctrord = aux_qtctrord + 1.

    END.

    FOR EACH crapneg WHERE crapneg.cdcooper = par_cdcooper             AND
                           crapneg.nrdconta = par_nrdconta             AND
                           crapneg.cdhisest = 1                        AND
                           CAN-DO("11,12,13",STRING(crapneg.cdobserv))
                           NO-LOCK USE-INDEX crapneg2:

        ASSIGN aux_qtdevolu = aux_qtdevolu + 1.

    END.
    
    ASSIGN aux_flglbace = IF   crapass.inlbacen = 0  THEN
                               FALSE
                          ELSE 
                               TRUE
           aux_flgeprat = FALSE.
    
                               
    RUN sistema/generico/procedures/b1wgen0002.p 
        PERSISTENT SET h-b1wgen0002.
        
    IF   NOT VALID-HANDLE(h-b1wgen0002)   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Handle invalido para h-b1wgen0002.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
                              
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_dscritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT FALSE,
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).
                                              
             RETURN "NOK".    

         END.
   
         
    RUN obtem-dados-emprestimos IN h-b1wgen0002 (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nmdatela,
                                                 INPUT par_idorigem,
                                                 INPUT par_nrdconta,
                                                 INPUT par_idseqttl,
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_dtmvtopr,
                                                 INPUT ?,
                                                 INPUT 0,
                                                 INPUT "b1wgen0027",
                                                 INPUT par_inproces,
                                                 INPUT FALSE,
                                                 INPUT FALSE, /*par_flgcondc*/
                                                 INPUT 0, /** nriniseq **/
                                                 INPUT 0, /** nrregist **/
                                                OUTPUT aux_qtregist,
                                                OUTPUT TABLE tt-erro,
                                                OUTPUT TABLE tt-dados-epr).
    
    DELETE PROCEDURE h-b1wgen0002.
    
   
    IF   RETURN-VALUE = "NOK" THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Conta: " + STRING(par_nrdconta) +
                                   " nao possui emprestimo.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
                                       
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_dscritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT FALSE,
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).               

             RETURN "NOK".    
    END.
                
    FIND FIRST tt-dados-epr WHERE (tt-dados-epr.tpemprst = 0   AND
                                   tt-dados-epr.vlpreapg > 0)  OR

                                 ((tt-dados-epr.tpemprst = 1   OR
								   tt-dados-epr.tpemprst = 2)  AND
                                   tt-dados-epr.flgatras)      AND                              

                                   tt-dados-epr.inprejuz = 0  
                                   NO-LOCK NO-ERROR.

    IF   AVAIL tt-dados-epr   THEN
         ASSIGN aux_flgeprat = TRUE.
    
    /* Obtem risco */
    FOR EACH craptab WHERE craptab.cdcooper = par_cdcooper AND
                           craptab.nmsistem = "CRED"       AND 
                           craptab.tptabela = "GENERI"     AND 
                           craptab.cdempres = 00           AND
                           craptab.cdacesso = "PROVISAOCL" NO-LOCK:
                                       
        ASSIGN aux_contador = INT(SUBSTR(craptab.dstextab,12,2))
               aux_dsdrisco[aux_contador] = TRIM(SUBSTR(craptab.dstextab,8,3)).
    END.
                              
    /* Alimentar variavel para nao ser preciso criar registro na PROVISAOCL */
    ASSIGN aux_dsdrisco[10] = "H".
                                
    ASSIGN aux_nivrisco = ""
           aux_dtdrisco = ?   
           aux_qtdiaris = 0. 

    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "USUARI"     AND
                       craptab.cdempres = 11           AND
                       craptab.cdacesso = "RISCOBACEN" AND
                       craptab.tpregist = 000 
                       NO-LOCK NO-ERROR.

    IF   NOT AVAIL craptab   THEN 
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = 
                    "NOT AVAIL craptab;CRED;USUARI;11;RISCOBACEN'".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
                                       
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_dscritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT FALSE,
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).               

             RETURN "NOK".   

    END.
 
    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    ASSIGN aux_dtrefere    = crapdat.dtultdma
           aux_innivris    = 2
           aux_vlr_arrasto = DEC(SUBSTRING(craptab.dstextab,3,9)).

    FIND LAST crapris WHERE crapris.cdcooper = par_cdcooper AND
                            crapris.nrdconta = par_nrdconta AND 
                            crapris.dtrefere = aux_dtrefere AND 
                            crapris.inddocto = 1            AND 
                            crapris.vldivida > aux_vlr_arrasto /*Valor arrasto*/
                            NO-LOCK NO-ERROR.
                            
    IF AVAIL crapris THEN
       ASSIGN aux_innivris = crapris.innivris.
    ELSE
      DO:
          FIND LAST crapris WHERE crapris.cdcooper = par_cdcooper AND
                                  crapris.nrdconta = par_nrdconta AND
                                  crapris.dtrefere = aux_dtrefere AND
                                  crapris.inddocto = 1 
                                  NO-LOCK NO-ERROR.
                                  
          /* Quando possuir operacao em Prejuizo, o risco da central sera H */
          IF AVAIL crapris AND crapris.innivris = 10 THEN
             ASSIGN aux_innivris = crapris.innivris.
      END.
                                
    IF  AVAIL crapris THEN
        DO:
           ASSIGN  aux_nivrisco = aux_dsdrisco[aux_innivris]
                   aux_dtdrisco = crapris.dtdrisco     
                   aux_qtdiaris = par_dtmvtolt - crapris.dtdrisco.

           IF  aux_nivrisco = "AA" THEN
               ASSIGN aux_nivrisco = "". /* Contratos Antigos */

        END.                               
    ELSE
      ASSIGN aux_nivrisco = aux_dsdrisco[aux_innivris].     
    
    ASSIGN aux_flgpreju = FALSE.    
    

    FOR EACH crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                           crapepr.nrdconta = par_nrdconta AND 
                           crapepr.inprejuz = 1            
                           NO-LOCK:

        ASSIGN aux_flgpreju = TRUE.

    END.    

    /* Busca do risco rating Efetivo ----  p450-rating   */
    FIND FIRST crapprm WHERE crapprm.nmsistem = 'CRED' AND
                             crapprm.cdacesso = 'HABILITA_RATING_NOVO' AND
                             crapprm.cdcooper = par_cdcooper
                             NO-LOCK NO-ERROR.
       
    ASSIGN aux_habrat = 'N'.
    IF AVAIL crapprm THEN DO:
      ASSIGN aux_habrat = crapprm.dsvlrprm.
    END.
       
    /* Habilita novo rating */
    IF aux_habrat = 'S' AND par_cdcooper <> 3 THEN DO:
      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

      RUN STORED-PROCEDURE pc_ret_risco_tbrisco
      aux_handproc = PROC-HANDLE
         ( INPUT  par_cdcooper      /* pr_cdcooper */
          ,INPUT  par_nrdconta      /* pr_nrdconta */
          ,INPUT  ?                 /* pr_tpctrato */
          ,INPUT  ?                 /* pr_nrctremp */
          ,INPUT  4                 /* pr_insit_rating  4- Efetivo */
          ,OUTPUT 0                /* pr_inrisco */
          ,OUTPUT 0                /* pr_cdcritic */
          ,OUTPUT ""               /* pr_dscritic */
          ).

      CLOSE STORED-PROCEDURE pc_ret_risco_tbrisco WHERE PROC-HANDLE = aux_handproc.
      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

      ASSIGN aux_cdcritic = 0
             aux_cdcritic = pc_ret_risco_tbrisco.pr_cdcritic
                           WHEN pc_ret_risco_tbrisco.pr_cdcritic <> ?
             aux_dscritic = ""
             aux_dscritic = pc_ret_risco_tbrisco.pr_dscritic
                           WHEN pc_ret_risco_tbrisco.pr_dscritic <> ?
             aux_risco_rat = 0
             aux_risco_rat = pc_ret_risco_tbrisco.pr_inrisco
                           WHEN pc_ret_risco_tbrisco.pr_inrisco <> ?.
                         
      IF aux_cdcritic > 0 OR 
        aux_dscritic <> "" THEN                       
      DO:
       RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,   /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).    	
       RETURN "NOK".
      END.
 
      CASE aux_risco_rat:
         WHEN 1  THEN ASSIGN aux_indrisco_rat = "AA".
         WHEN 2  THEN ASSIGN aux_indrisco_rat = "A" .
         WHEN 3  THEN ASSIGN aux_indrisco_rat = "B" .
         WHEN 4  THEN ASSIGN aux_indrisco_rat = "C" .
         WHEN 5  THEN ASSIGN aux_indrisco_rat = "D" .
         WHEN 6  THEN ASSIGN aux_indrisco_rat = "E" .
         WHEN 7  THEN ASSIGN aux_indrisco_rat = "F" .
         WHEN 8  THEN ASSIGN aux_indrisco_rat = "G" .
         WHEN 9  THEN ASSIGN aux_indrisco_rat = "H" .
         WHEN 10 THEN ASSIGN aux_indrisco_rat = "HH".
         OTHERWISE aux_indrisco_rat = "".
      END CASE.                        

      IF   aux_qtctrord      > 0   OR
           aux_qtdevolu      > 0   OR
           crapass.dtdsdspc <> ?   OR
           crapsld.qtddsdev  > 0   OR
           crapsld.qtddtdev  > 0   OR
           aux_flginadi            OR
           aux_flglbace            OR
           aux_flgeprat            OR
           aux_flgpreju            OR
        
          (aux_indrisco_rat <> "" AND  
           aux_indrisco_rat <> "A")  OR
        
          (aux_nivrisco     <> ""    AND
           aux_nivrisco     <> "A")  THEN
           ASSIGN aux_flgocorr = TRUE.
      ELSE
           ASSIGN aux_flgocorr = FALSE.
    
      IF NOT VALID-HANDLE(h-b1wgen0138) THEN
         RUN sistema/generico/procedures/b1wgen0138.p
             PERSISTENT SET h-b1wgen0138.

      DYNAMIC-FUNCTION("busca_grupo" IN h-b1wgen0138, INPUT par_cdcooper,
                                                      INPUT par_nrdconta,
                                                      OUTPUT aux_nrdgrupo,
                                                      OUTPUT aux_gergrupo,
                                                      OUTPUT aux_dsdrisgp).

      IF VALID-HANDLE(h-b1wgen0138) THEN
         DELETE OBJECT h-b1wgen0138.

      CREATE tt-ocorren.

      ASSIGN tt-ocorren.qtctrord = aux_qtctrord
             tt-ocorren.qtdevolu = aux_qtdevolu
             tt-ocorren.dtcnsspc = crapass.dtcnsspc
             tt-ocorren.dtdsdsps = crapass.dtdsdspc
             tt-ocorren.qtddsdev = crapsld.qtddsdev
             tt-ocorren.dtdsdclq = crapsld.dtdsdclq
             tt-ocorren.qtddtdev = crapsld.qtddtdev
             tt-ocorren.flginadi = aux_flginadi
             tt-ocorren.flglbace = aux_flglbace
             tt-ocorren.flgeprat = aux_flgeprat
             tt-ocorren.indrisco = aux_indrisco_rat
             tt-ocorren.nivrisco = aux_nivrisco
             tt-ocorren.flgpreju = aux_flgpreju
             tt-ocorren.flgjucta = aux_flgjucta
             tt-ocorren.flgocorr = aux_flgocorr
             tt-ocorren.dtdrisco = aux_dtdrisco
             tt-ocorren.qtdiaris = aux_qtdiaris
             tt-ocorren.inrisctl = IF crapass.inrisctl = "AA" THEN
                                      "A"
                                   ELSE
                                      crapass.inrisctl
             tt-ocorren.dtrisctl = crapass.dtrisctl
             tt-ocorren.dsdrisgp = aux_dsdrisgp
             tt-ocorren.innivris = aux_innivris.
    /* Habilita novo rating */
    END.
    ELSE DO:
      /* Rating efetivo */
      FIND crapnrc WHERE crapnrc.cdcooper = par_cdcooper   AND
                         crapnrc.nrdconta = par_nrdconta   AND
                         crapnrc.insitrat = 2     
                         NO-LOCK NO-ERROR.

      IF   aux_qtctrord      > 0   OR
           aux_qtdevolu      > 0   OR
           crapass.dtdsdspc <> ?   OR
           crapsld.qtddsdev  > 0   OR
           crapsld.qtddtdev  > 0   OR
           aux_flginadi            OR
           aux_flglbace            OR
           aux_flgeprat            OR
           aux_flgpreju            OR
        
        (AVAIL crapnrc          AND
         crapnrc.indrisco <> "" AND  
         crapnrc.indrisco <> "A")  OR
        
        (aux_nivrisco     <> ""    AND
         aux_nivrisco     <> "A")  THEN
         ASSIGN aux_flgocorr = TRUE.
      ELSE
         ASSIGN aux_flgocorr = FALSE.
    
      IF NOT VALID-HANDLE(h-b1wgen0138) THEN
         RUN sistema/generico/procedures/b1wgen0138.p
             PERSISTENT SET h-b1wgen0138.

      DYNAMIC-FUNCTION("busca_grupo" IN h-b1wgen0138, INPUT par_cdcooper,
                                                      INPUT par_nrdconta,
                                                      OUTPUT aux_nrdgrupo,
                                                      OUTPUT aux_gergrupo,
                                                      OUTPUT aux_dsdrisgp).

      IF VALID-HANDLE(h-b1wgen0138) THEN
         DELETE OBJECT h-b1wgen0138.

      CREATE tt-ocorren.

      ASSIGN tt-ocorren.qtctrord = aux_qtctrord
             tt-ocorren.qtdevolu = aux_qtdevolu
             tt-ocorren.dtcnsspc = crapass.dtcnsspc
             tt-ocorren.dtdsdsps = crapass.dtdsdspc
             tt-ocorren.qtddsdev = crapsld.qtddsdev
             tt-ocorren.dtdsdclq = crapsld.dtdsdclq
             tt-ocorren.qtddtdev = crapsld.qtddtdev
             tt-ocorren.flginadi = aux_flginadi
             tt-ocorren.flglbace = aux_flglbace
             tt-ocorren.flgeprat = aux_flgeprat
             tt-ocorren.indrisco = crapnrc.indrisco WHEN AVAIL crapnrc
             tt-ocorren.nivrisco = aux_nivrisco
             tt-ocorren.flgpreju = aux_flgpreju
             tt-ocorren.flgjucta = aux_flgjucta
             tt-ocorren.flgocorr = aux_flgocorr
             tt-ocorren.dtdrisco = aux_dtdrisco
             tt-ocorren.qtdiaris = aux_qtdiaris
             tt-ocorren.inrisctl = IF crapass.inrisctl = "AA" THEN
                                      "A"
                                   ELSE
                                      crapass.inrisctl
             tt-ocorren.dtrisctl = crapass.dtrisctl
             tt-ocorren.dsdrisgp = aux_dsdrisgp
             tt-ocorren.innivris = aux_innivris. 
    END.

    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

    RETURN "OK".

END PROCEDURE.

PROCEDURE lista_contra-ordem:

    DEF  INPUT PARAM par_cdcooper AS INTE NO-UNDO.                   
    DEF  INPUT PARAM par_cdagenci AS INTE NO-UNDO. /** 0-TODOS **/
    DEF  INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.                     
    DEF  INPUT PARAM par_cdoperad AS CHAR NO-UNDO.                
    DEF  INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-contra_ordem.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-contra_ordem.
    
    DEF VAR aux_dshistor AS CHAR NO-UNDO.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar ocorrencias de contra-ordens.".    
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper
                             NO-LOCK NO-ERROR.
    
    IF   NOT AVAIL crapdat   THEN
         DO:
             ASSIGN aux_cdcritic = 1
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
                 
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_cdcritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT FALSE,
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).              
                           
             RETURN "NOK".
         END.

    
    FOR EACH crapcor WHERE crapcor.cdcooper = par_cdcooper      AND
                           crapcor.nrdconta = par_nrdconta      AND 
                           crapcor.flgativo = TRUE              NO-LOCK:

        FIND craphis WHERE craphis.cdcooper = par_cdcooper     AND
                           craphis.cdhistor = crapcor.cdhistor NO-LOCK NO-ERROR.
        
        IF   NOT AVAILABLE craphis   THEN
             aux_dshistor = STRING(crapcor.cdhistor).
        ELSE
             aux_dshistor = STRING(craphis.cdhistor,"9999") + 
                            "-" + craphis.dshistor.

        CREATE tt-contra_ordem.
        ASSIGN tt-contra_ordem.cdbanchq = crapcor.cdbanchq
               tt-contra_ordem.cdagechq = crapcor.cdagechq
               tt-contra_ordem.nrctachq = crapcor.nrctachq
               tt-contra_ordem.cdoperad = crapcor.cdoperad
               tt-contra_ordem.nrcheque = crapcor.nrcheque
               tt-contra_ordem.dtemscor = crapcor.dtemscor
               tt-contra_ordem.dtmvtolt = crapcor.dtmvtolt
               tt-contra_ordem.dshistor = aux_dshistor.
               
    END.  /*  Fim do FOR EACH  --  crapcor  */
    
    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT "",
                        INPUT aux_dsorigem,
                        INPUT aux_dstransa,
                        INPUT TRUE,
                        INPUT par_idseqttl,
                        INPUT par_nmdatela,
                        INPUT par_nrdconta,
                       OUTPUT aux_nrdrowid).

    RETURN "OK".
    
END PROCEDURE.

PROCEDURE lista_emprestimos:

    DEF  INPUT PARAM par_cdcooper AS INTE NO-UNDO.                   
    DEF  INPUT PARAM par_cdagenci AS INTE NO-UNDO. /** 0-TODOS **/
    DEF  INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.                     
    DEF  INPUT PARAM par_cdoperad AS CHAR NO-UNDO.                
    DEF  INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE NO-UNDO.    
    DEF  INPUT PARAM par_idorigem AS INTE NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR NO-UNDO.
       
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-emprestimos.
        
    DEF VAR aux_qtregist AS INTE NO-UNDO.

    DEF VAR h-b1wgen0002 AS HANDLE NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-emprestimos.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar ocorrencias de emprestimos.".

    RUN sistema/generico/procedures/b1wgen0002.p 
        PERSISTENT SET h-b1wgen0002.
        
    IF   NOT VALID-HANDLE(h-b1wgen0002)   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Handle invalido para h-b1wgen0002.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
                              
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_dscritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT FALSE,
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).
                                              
             RETURN "NOK".    
         END.
         
    RUN obtem-dados-emprestimos IN h-b1wgen0002 (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nmdatela,
                                                 INPUT par_idorigem,
                                                 INPUT par_nrdconta,
                                                 INPUT par_idseqttl,
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_dtmvtopr,
                                                 INPUT ?,
                                                 INPUT 0,
                                                 INPUT "b1wgen0027",
                                                 INPUT par_inproces,
                                                 INPUT FALSE,
                                                 INPUT FALSE, /*par_flgcondc*/
                                                 INPUT 0, /** nriniseq **/
                                                 INPUT 0, /** nrregist **/
                                                OUTPUT aux_qtregist,
                                                OUTPUT TABLE tt-erro,
                                                OUTPUT TABLE tt-dados-epr).
     
    DELETE PROCEDURE h-b1wgen0002.
    
    IF   RETURN-VALUE = "NOK" THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Conta: " + STRING(par_nrdconta) +
                                   " nao possui emprestimo.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
                                       
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_dscritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT FALSE,
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).               

             RETURN "NOK".    
    END.    

    FOR EACH tt-dados-epr WHERE tt-dados-epr.vlpreapg > 0 AND
                                tt-dados-epr.inprejuz = 0 NO-LOCK:

        CREATE tt-emprestimos. 
        ASSIGN tt-emprestimos.cdpesqui = SUBSTR(tt-dados-epr.cdpesqui,1,10)
               tt-emprestimos.nrctremp = tt-dados-epr.nrctremp
               tt-emprestimos.vlemprst = tt-dados-epr.vlemprst
               tt-emprestimos.vlsdeved = tt-dados-epr.vlsdeved
               tt-emprestimos.vlpreapg = tt-dados-epr.vlpreapg
              tt-emprestimos.dtultpag = tt-dados-epr.dtultpag.
    END.
                                   
    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT "",
                        INPUT aux_dsorigem,
                        INPUT aux_dstransa,
                        INPUT TRUE,
                        INPUT par_idseqttl,
                        INPUT par_nmdatela,
                        INPUT par_nrdconta,
                       OUTPUT aux_nrdrowid).

    RETURN "OK".

END PROCEDURE.

PROCEDURE lista_prejuizos:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.                   
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO. /** 0-TODOS **/
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.                     
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.                
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_dtmvtopr AS DATE NO-UNDO.
    DEF INPUT PARAM par_inproces AS INTE NO-UNDO.    
    DEF INPUT PARAM par_idorigem AS INTE NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR NO-UNDO.
        
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-prejuizos.
        
    DEF VAR h-b1wgen0002 AS HANDLE NO-UNDO.

    DEF VAR aux_qtregist AS INTE NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-prejuizos.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar ocorrencias de prejuizos.".
    
    RUN sistema/generico/procedures/b1wgen0002.p 
        PERSISTENT SET h-b1wgen0002.
        
    IF   NOT VALID-HANDLE(h-b1wgen0002)   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Handle invalido para h-b1wgen0002.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
                              
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_dscritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT FALSE,
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).
                                              
             RETURN "NOK".    
         END.
         
    RUN obtem-dados-emprestimos IN h-b1wgen0002 (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nmdatela,
                                                 INPUT par_idorigem,
                                                 INPUT par_nrdconta,
                                                 INPUT par_idseqttl,
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_dtmvtopr,
                                                 INPUT ?,
                                                 INPUT 0,
                                                 INPUT "b1wgen0027",
                                                 INPUT par_inproces,
                                                 INPUT FALSE,
                                                 INPUT FALSE, /*par_flgcondc*/
                                                 INPUT 0, /** nriniseq **/
                                                 INPUT 0, /** nrregist **/
                                                OUTPUT aux_qtregist,
                                                OUTPUT TABLE tt-erro,
                                                OUTPUT TABLE tt-dados-epr).
     
    DELETE PROCEDURE h-b1wgen0002.
    
    IF   RETURN-VALUE = "NOK" THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Conta: " + STRING(par_nrdconta) +
                                   " nao possui emprestimo.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
                                       
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_dscritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT FALSE,
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).               

             RETURN "NOK".    
    END.    

    FOR EACH tt-dados-epr WHERE tt-dados-epr.inprejuz > 0:

        CREATE tt-prejuizos. 
        ASSIGN tt-prejuizos.cdpesqui = SUBSTR(tt-dados-epr.cdpesqui,1,10)
               tt-prejuizos.nrctremp = tt-dados-epr.nrctremp
               tt-prejuizos.dtprejuz = tt-dados-epr.dtprejuz
               tt-prejuizos.vlprejuz = tt-dados-epr.vlprejuz
               tt-prejuizos.vlsdprej = tt-dados-epr.slprjori
               tt-prejuizos.nrdiaatr = IF tt-dados-epr.dtprejuz - tt-dados-epr.dtdpagto <0 THEN
                                          0
                                       ELSE
                                          tt-dados-epr.dtprejuz - tt-dados-epr.dtdpagto 
               tt-prejuizos.nrdiaprj = par_dtmvtolt - tt-dados-epr.dtprejuz
               tt-prejuizos.nrdiatot = tt-prejuizos.nrdiaatr + tt-prejuizos.nrdiaprj 
               tt-prejuizos.vljrmprj = tt-dados-epr.vljrmprj
               tt-prejuizos.vlttmupr = tt-dados-epr.vlttmupr
               tt-prejuizos.vlttjmpr = tt-dados-epr.vlttjmpr
               tt-prejuizos.vltiofpr = tt-dados-epr.vltiofpr
               tt-prejuizos.vlrpagos = tt-dados-epr.vlrpagos
               tt-prejuizos.vlrabono = tt-dados-epr.vlrabono
               tt-prejuizos.vlsaldev = tt-dados-epr.vlsdprej.
    END.
                                   
    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT "",
                        INPUT aux_dsorigem,
                        INPUT aux_dstransa,
                        INPUT TRUE,
                        INPUT par_idseqttl,
                        INPUT par_nmdatela,
                        INPUT par_nrdconta,
                       OUTPUT aux_nrdrowid).

    RETURN "OK".

END PROCEDURE.

PROCEDURE lista_spc:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.                   
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO. /** 0-TODOS **/
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.                     
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.                
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE NO-UNDO. 
    DEF INPUT PARAM par_idseqttl AS INTE NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-spc.
    
    DEF VAR aux_flginadi AS LOGICAL                                 NO-UNDO.
    DEF VAR aux_tpidenti AS CHAR    EXTENT 4 INIT ["Dev1-","Dev2-",
                                                   "Fia1-","Fia2-"] NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-spc.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar ocorrencias de SPC.".
    
    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND 
                             crapass.nrdconta = par_nrdconta 
                             NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapass   THEN
         DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).        
                           
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT aux_cdcritic,
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT FALSE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).                           
                           
            RETURN "NOK".
         END.                         
    
    ASSIGN aux_flginadi = IF   crapass.inadimpl = 0  THEN
                               FALSE   
                          ELSE TRUE.    
        
    IF   aux_flginadi   THEN
         FOR EACH crapspc WHERE crapspc.cdcooper = par_cdcooper   AND
                               (crapspc.nrdconta = par_nrdconta   OR
                                crapspc.nrcpfcgc = crapass.nrcpfcgc) 
                                NO-LOCK:
                      
             CREATE tt-spc.
             ASSIGN tt-spc.nrctremp = crapspc.nrctremp
                    tt-spc.dsidenti = aux_tpidenti[crapspc.tpidenti]  
                    tt-spc.dtvencto = crapspc.dtvencto
                    tt-spc.dtinclus = crapspc.dtinclus
                    tt-spc.vldivida = crapspc.vldivida
                    tt-spc.nrctrspc = crapspc.nrctrspc
                    tt-spc.dtdbaixa = crapspc.dtdbaixa.

             IF   crapspc.cdorigem = 1   THEN
                  ASSIGN tt-spc.dsorigem = "CONTA".
             ELSE
             IF   crapspc.cdorigem = 2   THEN
                  ASSIGN tt-spc.dsorigem = "DESCTO".
             ELSE
             IF   crapspc.cdorigem = 3   THEN
                  ASSIGN tt-spc.dsorigem = "EMPRES".

             FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper   AND
                                      crapass.nrcpfcgc = crapspc.nrcpfcgc
                                      NO-LOCK NO-ERROR.
             IF   AVAILABLE crapass   THEN                          
                  ASSIGN tt-spc.dsidenti = tt-spc.dsidenti + "Cta " +
                                STRING(crapass.nrdconta,"zzzz,zzz,9").
             ELSE
                  ASSIGN tt-spc.dsidenti = tt-spc.dsidenti + "Cpf " +
                                STRING(crapspc.nrcpfcgc).
         END.
    
    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT "",
                        INPUT aux_dsorigem,
                        INPUT aux_dstransa,
                        INPUT TRUE,
                        INPUT par_idseqttl,
                        INPUT par_nmdatela,
                        INPUT par_nrdconta,
                       OUTPUT aux_nrdrowid).

    RETURN "OK".

END PROCEDURE.

PROCEDURE lista_estouros:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.                   
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO. /** 0-TODOS **/
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.                     
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.                
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE NO-UNDO. 
    DEF INPUT PARAM par_idseqttl AS INTE NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-estouros.
    
    DEF VAR aux_cdhisest AS CHAR NO-UNDO.
    DEF VAR aux_dsobserv AS CHAR NO-UNDO.
    DEF VAR aux_cdobserv AS CHAR NO-UNDO.
    DEF VAR aux_dscodant AS CHAR NO-UNDO.
    DEF VAR aux_dscodatu AS CHAR NO-UNDO.
    DEF VAR aux_dstipcta AS CHAR NO-UNDO.
    DEF VAR aux_des_erro AS CHAR NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-estouros.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar estouros de conta.".
    
    FOR EACH crapneg WHERE crapneg.cdcooper = par_cdcooper  AND
                           crapneg.nrdconta = par_nrdconta
                           USE-INDEX crapneg1 NO-LOCK:

        ASSIGN aux_cdhisest = ""
               aux_cdobserv = ""
               aux_dsobserv = ""
               aux_dscodant = ""
               aux_dscodatu = "".

        IF   crapneg.cdhisest = 0   THEN
             aux_cdhisest = "Admissao socio".
        ELSE
        IF   crapneg.cdhisest = 1   THEN
             aux_cdhisest = "Devolucao Chq.".
        ELSE
        IF   crapneg.cdhisest = 2   THEN
             aux_cdhisest = "Alt. Tipo Conta".
        ELSE
        IF   crapneg.cdhisest = 3   THEN
             aux_cdhisest = "Alt. Sit. Conta".
        ELSE
        IF   crapneg.cdhisest = 4   THEN
             aux_cdhisest = "Credito Liquid.".
        ELSE
        IF   crapneg.cdhisest = 5   THEN
             aux_cdhisest = "Estouro".
        ELSE
        IF   crapneg.cdhisest = 6   THEN
             aux_cdhisest = "Notificacao".

        IF   (crapneg.cdhisest = 1 AND crapneg.dtfimest <> ?) THEN
             aux_dscodatu = "  ACERTADO".
                            
        IF   (crapneg.cdhisest = 1 OR (crapneg.cdhisest = 5 AND
             crapneg.cdobserv > 0))   THEN
             DO:
                 FIND crapali WHERE crapali.cdalinea = crapneg.cdobserv 
                                    NO-LOCK NO-ERROR.

                 IF   NOT AVAILABLE crapali  THEN
                      IF    crapneg.cdhisest = 1 THEN
                            ASSIGN aux_dsobserv = 
                                       "Alinea "+ STRING(crapneg.cdobserv)
                                   aux_cdobserv = "".
                      ELSE
                            ASSIGN aux_cdobserv = ""
                                   aux_dsobserv = "" .
                 ELSE
                      DO:
                         ASSIGN aux_dsobserv = crapali.dsalinea
                                aux_cdobserv = STRING(crapali.cdalinea).
                      END.
             END.

        IF   crapneg.cdhisest = 2   THEN
             DO:
                 FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                    crapass.nrdconta = par_nrdconta
                                    NO-LOCK NO-ERROR.
            
                 IF AVAILABLE crapass THEN
                     DO:
                         { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                         
                         RUN STORED-PROCEDURE pc_descricao_tipo_conta
                         aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa,    /* tipo de pessoa */
                                                              INPUT crapneg.cdtctant,    /* tipo de conta */
                                                             OUTPUT "",   /* Descricao do tipo de conta */
                                                             OUTPUT "",   /* Flag Erro */
                                                             OUTPUT "").  /* Descrição da crítica */
                         
                         CLOSE STORED-PROC pc_descricao_tipo_conta
                               aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                         
                         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                         
                         ASSIGN aux_dstipcta = ""
                                aux_des_erro = ""
                                aux_dscritic = ""
                                aux_dstipcta = pc_descricao_tipo_conta.pr_dstipo_conta 
                                               WHEN pc_descricao_tipo_conta.pr_dstipo_conta <> ?
                                aux_des_erro = pc_descricao_tipo_conta.pr_des_erro 
                                               WHEN pc_descricao_tipo_conta.pr_des_erro <> ?
                                aux_dscritic = pc_descricao_tipo_conta.pr_dscritic
                                               WHEN pc_descricao_tipo_conta.pr_dscritic <> ?.
                         
                         IF aux_des_erro = "NOK" or 
                            aux_dstipcta = ""    THEN
                      aux_dscodant = STRING(crapneg.cdtctant).
                 ELSE
                             aux_dscodant =  aux_dstipcta.
                         
                         { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                         
                         RUN STORED-PROCEDURE pc_descricao_tipo_conta
                         aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa,    /* tipo de pessoa */
                                                              INPUT crapneg.cdtctatu,    /* tipo de conta */
                                                             OUTPUT "",   /* Descricao do tipo de conta */
                                                             OUTPUT "",   /* Flag Erro */
                                                             OUTPUT "").  /* Descrição da crítica */
                         
                         CLOSE STORED-PROC pc_descricao_tipo_conta
                               aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                         
                         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
 
                         ASSIGN aux_dstipcta = ""
                                aux_des_erro = ""
                                aux_dscritic = ""
                                aux_dstipcta = pc_descricao_tipo_conta.pr_dstipo_conta 
                                               WHEN pc_descricao_tipo_conta.pr_dstipo_conta <> ?
                                aux_des_erro = pc_descricao_tipo_conta.pr_des_erro 
                                               WHEN pc_descricao_tipo_conta.pr_des_erro <> ?
                                aux_dscritic = pc_descricao_tipo_conta.pr_dscritic
                                               WHEN pc_descricao_tipo_conta.pr_dscritic <> ?.

                         IF aux_des_erro = "NOK" OR 
                            aux_dstipcta = ""    THEN
                      aux_dscodatu = STRING(crapneg.cdtctatu).
                 ELSE
                             aux_dscodatu =  aux_dstipcta.
                     end.
                 ELSE
                     do:
                         ASSIGN aux_cdcritic = 9
                                aux_dscritic = "".

                         RUN gera_erro (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT 1,            /** Sequencia **/
                                        INPUT aux_cdcritic,
                                        INPUT-OUTPUT aux_dscritic).        
                                                   
                         RUN proc_gerar_log (INPUT par_cdcooper,
                                             INPUT par_cdoperad,
                                             INPUT aux_dscritic,
                                             INPUT aux_dsorigem,
                                             INPUT aux_dstransa,
                                             INPUT FALSE,
                                             INPUT par_idseqttl,
                                             INPUT par_nmdatela,
                                             INPUT par_nrdconta,
                                            OUTPUT aux_nrdrowid).               

                         RETURN "NOK".  
                     end.
             END.
      
        IF   crapneg.cdhisest = 3 THEN
             DO:
                 IF   crapneg.cdtctant = 0  THEN
                      aux_dscodant = STRING(crapneg.cdtctant).
                 ELSE
                      IF   crapneg.cdtctant = 1 THEN
                           aux_dscodant = "NORMAL".
                      ELSE
                           aux_dscodant = "ENCERRADA".
  
                 IF   crapneg.cdtctatu = 0  THEN
                      aux_dscodatu = STRING(crapneg.cdtctatu).
                 ELSE
                      IF   crapneg.cdtctatu = 1 THEN
                           aux_dscodatu = "NORMAL".
                      ELSE
                           aux_dscodatu = "ENCERRADA".
             END.

        CREATE tt-estouros.
        ASSIGN tt-estouros.nrseqdig = crapneg.nrseqdig
               tt-estouros.dtiniest = crapneg.dtiniest
               tt-estouros.qtdiaest = crapneg.qtdiaest
               tt-estouros.cdhisest = aux_cdhisest
               tt-estouros.vlestour = crapneg.vlestour
               tt-estouros.nrdctabb = crapneg.nrdctabb
               tt-estouros.nrdocmto = crapneg.nrdocmto
               tt-estouros.cdobserv = aux_cdobserv
               tt-estouros.dsobserv = aux_dsobserv
               tt-estouros.vllimcre = crapneg.vllimcre
               tt-estouros.dscodant = aux_dscodant
               tt-estouros.dscodatu = aux_dscodatu.

   END.
   
   RUN proc_gerar_log (INPUT par_cdcooper,
                       INPUT par_cdoperad,
                       INPUT "",
                       INPUT aux_dsorigem,
                       INPUT aux_dstransa,
                       INPUT TRUE,
                       INPUT par_idseqttl,
                       INPUT par_nmdatela,
                       INPUT par_nrdconta,
                      OUTPUT aux_nrdrowid).

    RETURN "OK".

END PROCEDURE.


PROCEDURE extratos_emitidos_no_cash:
  
    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.                   
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.                     
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dtrefere AS DATE NO-UNDO.                     
    DEF INPUT PARAM par_idorigem AS INTE NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-extcash.

    DEF VAR aux_inisenta AS LOGI                                       NO-UNDO.
    DEF VAR aux_dtmesano AS CHAR                                       NO-UNDO.
    DEF VAR aux_nrnmterm AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdagenci AS INT                                        NO-UNDO.
    DEF VAR aux_vetormes AS CHAR          EXTENT 12
                         INIT ["JAN","FEV","MAR","ABR","MAIO","JUN",
                               "JUL","AGO","SET","OUT","NOV","DEZ"]    NO-UNDO.
             
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-extcash.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar extratos emitidos no CASH.".    
    
    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                             crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
    
    IF   NOT AVAIL crapass   THEN
         DO:
             ASSIGN aux_cdcritic = 9
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        

             IF  par_flgerlog  THEN                            
                 RUN proc_gerar_log (INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_cdcritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid).             
             RETURN "NOK".
         END.
    
    FIND crapage WHERE crapage.cdcooper = par_cdcooper     AND
                       crapage.cdagenci = crapass.cdagenci NO-LOCK NO-ERROR.
                      
    IF   NOT AVAILABLE crapage THEN
         DO:
             ASSIGN aux_cdcritic = 15
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
             
             IF  par_flgerlog  THEN                            
                 RUN proc_gerar_log (INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_cdcritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid).                      
                            
             RETURN "NOK".
         END.

    FOR EACH crapext WHERE crapext.cdcooper =  par_cdcooper            AND
                           crapext.dtreffim >= par_dtrefere            AND
                           crapext.nrdconta =  crapass.nrdconta        AND
                           crapext.tpextrat =  1 /* C/C */             AND
                           crapext.nrterfin > 0                        AND
                          (crapext.insitext =  1    OR 
                           crapext.insitext =  5)                  NO-LOCK  
                           BY crapext.dtrefere:
                               
        FIND craptfn WHERE craptfn.cdcooper = crapext.cdcoptfn  AND
                           craptfn.nrterfin = crapext.nrterfin
                           NO-LOCK No-ERROR.
                             
        IF   AVAILABLE craptfn THEN
             ASSIGN aux_cdagenci = craptfn.cdagenci
                    aux_nrnmterm = STRING(craptfn.nrterfin,"9999") + " - " +
                                   craptfn.nmterfin.
        ELSE
             ASSIGN aux_cdagenci = crapass.cdagenci
                    aux_nrnmterm = "9999 - NAO ENCONTRADO".
        
        /* referencia, inicio do periodo do extrato */
        ASSIGN aux_dtmesano = aux_vetormes[MONTH(crapext.dtrefere)] +
                              "/" + STRING(YEAR(crapext.dtrefere)).
        
        IF   crapext.inisenta = 0   THEN
             aux_inisenta = TRUE.
        ELSE
        IF   crapext.inisenta = 1   THEN
             aux_inisenta = FALSE.
        
        CREATE tt-extcash.
        ASSIGN tt-extcash.dtrefere = crapext.dtreffim /* dia que foi retirado */
               tt-extcash.dtmesano = aux_dtmesano
               tt-extcash.cdagenci = aux_cdagenci
               tt-extcash.nrnmterm = aux_nrnmterm
               tt-extcash.inisenta = aux_inisenta.
    END.
                  
    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT "",
                        INPUT aux_dsorigem,
                        INPUT aux_dstransa,
                        INPUT TRUE,
                        INPUT par_idseqttl,
                        INPUT par_nmdatela,
                        INPUT par_nrdconta,
                       OUTPUT aux_nrdrowid).
    
    RETURN "OK".
       
END PROCEDURE.

/* ......................................................................... */


