/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0125.p
    Autor   : Rogerius Militao (DB1)
    Data    : Novembro/2011                     Ultima atualizacao: 03/07/2019

    Objetivo  : Tranformacao BO tela CONSCR

    Alteracoes: 30/05/2012 Incluido tratamento para tabela crapces (Tiago). 
    
                20/06/2012 Incluido na temp table tt-fluxo os registros
                           necessarios para coluna 'Limite credito' no
                           prg conscr.p (Tiago)
   
                07/08/2012 - Reajustado os forms de fluxo - impressao (Tiago).
                
                10/06/2013 - tt-complemento.dtrefaux em BuscaComplemento e
                             aux_dtrefris em Imprimir_Risco alteradas para 
                             par_dtmvtolt - DAY(par_dtmvtolt) (Carlos)
               
               13/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).  
                            
               14/01/2014 - Alterada procedure Imprimir_Risco para tratar com
                            critica quando PA nao estiver cadastrado.(Reinert)
                            
               26/03/2014 - Ajuste leitura crapopf para ganho performace no 
                            data server (Daniel). 
                            
               15/04/2014 - Correcao leitura crapopf. (Daniel)             

               02/08/2016 - Inclusao insitage 3-Temporariamente Indisponivel.
                            (Jaison/Anderson)
               03/07/2019 - Feito a chamada da procedure pc_descricao_tipo_conta, INC0018707
                            Bruno-Mout`S.

............................................................................*/

/*............................. DEFINICOES .................................*/

{ sistema/generico/includes/b1wgen0125tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.
DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                      NO-UNDO.

DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.

/*................................ PROCEDURES ..............................*/
 
/* ------------------------------------------------------------------------ */
/*         BUSCA DOS DADOS DA CONTA DO COOPERADO PARA CONSULTA SCR          */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

     DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
     DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_tpconsul AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
     DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
     DEF OUTPUT PARAM par_contador AS INTE                           NO-UNDO.
    
     DEF OUTPUT PARAM TABLE FOR tt-contas.
     DEF OUTPUT PARAM TABLE FOR tt-erro.
     
     DEF VAR aux_dtrefere AS DATE                                    NO-UNDO.
     DEF VAR par_dtrefere AS CHAR                                    NO-UNDO.
     DEF VAR aux_tpconsul AS CHAR                                    NO-UNDO.
     DEF VAR aux_regexist AS LOGI                                    NO-UNDO.
     DEF VAR aux_stsnrcal AS LOGI                                    NO-UNDO.
     DEF VAR aux_inpessoa AS INTE                                    NO-UNDO.

     EMPTY TEMP-TABLE tt-contas.
     EMPTY TEMP-TABLE tt-erro.

     ASSIGN aux_tpconsul = STRING(par_tpconsul)
            aux_dscritic = ""
            aux_cdcritic = 0
            aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
            aux_dstransa = "Busca dados do cooperado para consulta SCR".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:

        /* Valida a opção */
        IF  NOT CAN-DO("C,F,R,M,H",par_cddopcao) THEN
            DO:
                ASSIGN aux_cdcritic = 14.
                LEAVE Busca.
            END.

        /* Valida o tipo */
        IF  NOT CAN-DO("1,2,3",aux_tpconsul) THEN
            DO:
                ASSIGN aux_cdcritic = 14.
                LEAVE Busca.
            END.

        /*** Faz critica para as opcoes "C", "F", "M" e "H" 
             quando tipo de consulta for 3 (Por PAC) ***/ 
        IF  par_cddopcao <> "R" AND par_tpconsul = 3 THEN
            DO:
                ASSIGN aux_cdcritic = 14.
                LEAVE Busca.
            END.
        
        RUN verifica_data_base ( OUTPUT aux_dtrefere, OUTPUT par_dtrefere ).

        IF  par_tpconsul = 1 THEN   /**CPF/CNPJ**/
            DO:
                /***** VALIDA CPF *******/
                IF  par_nrcpfcgc = 0 THEN
                    DO:
                        ASSIGN aux_cdcritic = 780.
                        LEAVE Busca.                        
                    END.
                
                IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
                    RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.

                RUN valida-cpf-cnpj IN h-b1wgen9999 
                                    ( INPUT par_nrcpfcgc, 
                                     OUTPUT aux_stsnrcal, 
                                     OUTPUT aux_inpessoa).

                IF  VALID-HANDLE(h-b1wgen9999)  THEN
                    DELETE PROCEDURE h-b1wgen9999.

                IF  NOT aux_stsnrcal THEN
                    DO: 
                        ASSIGN aux_cdcritic = 27.
                        LEAVE Busca.
                    END.
            END.
        ELSE                  
        IF  par_tpconsul = 2 THEN   /**Conta**/
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta AND
                                   crapass.dtdemiss = ? 
                                   NO-LOCK NO-ERROR.
                
                IF  NOT AVAIL crapass THEN
                    DO:
                       ASSIGN aux_cdcritic = 064.
                       LEAVE Busca.                
                    END.
            END.

        /* Faz a busca dos dados */
        IF  par_tpconsul = 1 THEN    /** CPF/CNPJ **/
            DO: /** Pessoa Fisica **/             
                FOR EACH crapttl WHERE  
                         crapttl.cdcooper = par_cdcooper AND
                         crapttl.nrcpfcgc = par_nrcpfcgc NO-LOCK:

                    FIND crapass WHERE  
                         crapass.cdcooper = par_cdcooper         AND
                         crapass.nrdconta = crapttl.nrdconta     AND
                         crapass.dtdemiss = ?  NO-LOCK NO-ERROR.

                    IF  AVAIL crapass THEN
                        DO:                
   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_descricao_tipo_conta
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa,    /* tipo de pessoa */
                                         INPUT crapass.cdtipcta,    /* tipo de conta */
                                        OUTPUT "",   /* Descricao do tipo de conta */
                                        OUTPUT "",   /* Flag Erro */
                                        OUTPUT "").  /* Descriçao da crítica */
    
      CLOSE STORED-PROC pc_descricao_tipo_conta
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
                            IF  pc_descricao_tipo_conta.pr_dstipo_conta <> ? THEN     
                                DO:                    
                                    CREATE  tt-contas.
                                    ASSIGN  tt-contas.nrdconta = crapttl.nrdconta
                                            tt-contas.cdagenci = crapass.cdagenci
                                            tt-contas.nmprimtl = crapttl.nmextttl
                                            tt-contas.tpdconta = pc_descricao_tipo_conta.pr_dstipo_conta
                                            tt-contas.idseqttl = crapttl.idseqttl
                                            tt-contas.nrcpfcgc = crapttl.nrcpfcgc
                                            aux_regexist       = TRUE
                                            par_contador       = par_contador + 1.

                                END.
                            ELSE   
                                DO:
                                      ASSIGN aux_cdcritic = 17.
                                      LEAVE Busca.
                                END.
                        END.                                                   
                END.

                /*** Pessoa Juridica ***/
                FOR EACH crapass WHERE  crapass.cdcooper = par_cdcooper     AND
                                        crapass.nrcpfcgc = par_nrcpfcgc     AND
                                        crapass.inpessoa = 2                AND
                                        crapass.dtdemiss = ? NO-LOCK: 

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_descricao_tipo_conta
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa,    /* tipo de pessoa */
                                         INPUT crapass.cdtipcta,    /* tipo de conta */
                                        OUTPUT "",   /* Descricao do tipo de conta */
                                        OUTPUT "",   /* Flag Erro */
                                        OUTPUT "").  /* Descriçao da crítica */
    
      CLOSE STORED-PROC pc_descricao_tipo_conta
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
                            IF  pc_descricao_tipo_conta.pr_dstipo_conta <> ? THEN
                        DO:                    
                              CREATE  tt-contas.
                              ASSIGN  tt-contas.nrdconta = crapass.nrdconta
                                      tt-contas.cdagenci = crapass.cdagenci
                                      tt-contas.nmprimtl = crapass.nmprimtl
                                      tt-contas.tpdconta = pc_descricao_tipo_conta.pr_dstipo_conta
                                      tt-contas.nrcpfcgc = crapass.nrcpfcgc
                                      tt-contas.idseqttl = 1 
                                      aux_regexist       = TRUE
                                      par_contador       = par_contador + 1.

                        END.
                    ELSE   
                        DO: 
                            ASSIGN aux_cdcritic = 17.
                            LEAVE Busca.
                        END.    
                END.

                /** Verifica se existe CPF/CNPJ **/
                IF  aux_regexist = FALSE THEN 
                    DO:
                         ASSIGN aux_cdcritic = 780.
                         LEAVE Busca.                  
                    END.
            END. /*  IF  par_tpconsul = 1 THEN  */
        ELSE
            IF  par_tpconsul = 2 THEN    /** Conta **/
                DO:        
                    FOR EACH crapttl WHERE  crapttl.cdcooper = par_cdcooper  AND 
                                            crapttl.nrdconta = par_nrdconta:

                        
{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_descricao_tipo_conta
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa,    /* tipo de pessoa */
                                         INPUT crapass.cdtipcta,    /* tipo de conta */
                                        OUTPUT "",   /* Descricao do tipo de conta */
                                        OUTPUT "",   /* Flag Erro */
                                        OUTPUT "").  /* Descriçao da crítica */
    
      CLOSE STORED-PROC pc_descricao_tipo_conta
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
                            IF  pc_descricao_tipo_conta.pr_dstipo_conta <> ? THEN 
                             DO:                    
                                 CREATE tt-contas.
                                 ASSIGN tt-contas.nrdconta = crapttl.nrdconta
                                        tt-contas.cdagenci = crapass.cdagenci
                                        tt-contas.nmprimtl = crapttl.nmextttl
                                        tt-contas.tpdconta = pc_descricao_tipo_conta.pr_dstipo_conta
                                        tt-contas.idseqttl = crapttl.idseqttl
                                        tt-contas.nrcpfcgc = crapttl.nrcpfcgc
                                        par_contador       = par_contador + 1. 
                             END.
                         ELSE   
                             DO: 
                                ASSIGN aux_cdcritic = 17.
                                LEAVE Busca.
                             END.    
                    END.

                    /*** Pessoa Juridica ***/
                    FOR EACH crapass WHERE  
                             crapass.cdcooper = par_cdcooper     AND
                             crapass.nrdconta = par_nrdconta     AND
                             crapass.inpessoa = 2                AND
                             crapass.dtdemiss = ?            NO-LOCK:

                        
{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_descricao_tipo_conta
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa,    /* tipo de pessoa */
                                         INPUT crapass.cdtipcta,    /* tipo de conta */
                                        OUTPUT "",   /* Descricao do tipo de conta */
                                        OUTPUT "",   /* Flag Erro */
                                        OUTPUT "").  /* Descriçao da crítica */
    
      CLOSE STORED-PROC pc_descricao_tipo_conta
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
                            IF  pc_descricao_tipo_conta.pr_dstipo_conta <> ? THEN 
                            DO:                    
                                  CREATE  tt-contas.
                                  ASSIGN  tt-contas.nrdconta = crapass.nrdconta
                                          tt-contas.cdagenci = crapass.cdagenci
                                          tt-contas.nmprimtl = crapass.nmprimtl
                                          tt-contas.tpdconta = pc_descricao_tipo_conta.pr_dstipo_conta
                                          tt-contas.nrcpfcgc = crapass.nrcpfcgc
                                          tt-contas.idseqttl = 1. 

                                  ASSIGN par_contador = par_contador + 1. 
                            END.
                        ELSE   
                            DO: 
                                ASSIGN aux_cdcritic = 17.
                                LEAVE Busca.
                            END.   
                    END. 

                END. /* IF  tel_tpconsul = 2 THEN */


        LEAVE Busca.

     END. /*  Busca */

     IF  TEMP-TABLE tt-erro:HAS-RECORDS OR
         aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF  AVAIL tt-erro THEN
                 ASSIGN aux_dscritic = tt-erro.dscritic.
             ELSE 
                 RUN gera_erro ( INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic ).

             IF  par_flgerlog  THEN
                 RUN proc_gerar_log ( INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT 1,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                     OUTPUT aux_nrdrowid ).

             RETURN "NOK".
         END.
     
     RETURN "OK".

END PROCEDURE. /* Busca_Dados */


/* ------------------------------------------------------------------------ */
/*          CONSULTA DAS INFORMACOES DA CENTRAL DE RISCO DO COOPERADO       */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Complemento:
     
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgdelog AS LOGI                           NO-UNDO. 

    DEF OUTPUT PARAM par_msgretor AS CHAR                           NO-UNDO. 

    DEF OUTPUT PARAM TABLE FOR tt-complemento.                       
    DEF OUTPUT PARAM TABLE FOR tt-erro.
     
    EMPTY TEMP-TABLE tt-complemento.
    EMPTY TEMP-TABLE tt-erro.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        
        CREATE tt-complemento.

        /** Necessario verificar data base novamente no caso do usuario 
            consultar mais contas ou cpf's sem sair do browser **/
        RUN verifica_data_base (OUTPUT tt-complemento.dtrefaux, 
                                OUTPUT tt-complemento.dtrefere ).
        
        /** crapopf nao possui cdcooper **/     
        FIND LAST crapopf WHERE crapopf.nrcpfcgc  = par_nrcpfcgc   AND
                                crapopf.dtrefere >= tt-complemento.dtrefaux
                                NO-LOCK NO-ERROR.           

        IF  AVAIL crapopf THEN
            DO:  
                 ASSIGN tt-complemento.qtopesfn = crapopf.qtopesfn
                        tt-complemento.qtifssfn = crapopf.qtifssfn.

                 FOR EACH crapvop  WHERE  
                                   crapvop.nrcpfcgc = par_nrcpfcgc AND
                                   crapvop.dtrefere = crapopf.dtrefere
                                   NO-LOCK:

                     ASSIGN tt-complemento.vlopesfn = 
                            tt-complemento.vlopesfn + crapvop.vlvencto.

                     /** Operacoes vencidas **/
                     IF  crapvop.cdvencto >= 205 AND
                         crapvop.cdvencto <= 290 THEN
                         ASSIGN tt-complemento.vlopevnc = 
                            tt-complemento.vlopevnc + crapvop.vlvencto.

                     /** Operacoes em Prejuizo **/
                     IF  crapvop.cdvencto >= 310 AND
                         crapvop.cdvencto <= 330 THEN
                         ASSIGN tt-complemento.vlopeprj = 
                            tt-complemento.vlopeprj + crapvop.vlvencto.
                 END.

                 ASSIGN tt-complemento.dtrefaux = crapopf.dtrefere.       

                 /*** Operacoes Coop. Data Base ***/
                 FOR EACH crapris WHERE 
                          crapris.cdcooper = par_cdcooper               AND
                          crapris.nrcpfcgc = par_nrcpfcgc               AND
                          crapris.nrdconta = par_nrdconta               AND
                          crapris.dtrefere = tt-complemento.dtrefaux    AND
                          crapris.inddocto = 1 USE-INDEX crapris1  NO-LOCK:

                     ASSIGN  tt-complemento.vlopbase = tt-complemento.vlopbase + crapris.vldivida.

                 END.

            END. 
        ELSE
            DO:  
       
                FIND crapces WHERE crapces.nrcpfcgc  = par_nrcpfcgc AND
                                   crapces.dtrefere  = tt-complemento.dtrefaux
                                   NO-LOCK NO-ERROR.

                IF NOT AVAIL(crapces) THEN
                   ASSIGN par_msgretor = "Informacoes do BACEN deste CPF/CNPJ" +
                                         " nao estao disponiveis.".
            END.

        ASSIGN tt-complemento.dtrefaux = par_dtmvtolt - DAY(par_dtmvtolt).

        FOR EACH crapris WHERE crapris.cdcooper = par_cdcooper              AND
                               crapris.nrcpfcgc = par_nrcpfcgc              AND
                               crapris.dtrefere = tt-complemento.dtrefaux   AND
                               crapris.nrdconta = par_nrdconta              AND
                               crapris.inddocto = 1 
                               USE-INDEX crapris1 NO-LOCK:

            ASSIGN  tt-complemento.vlopcoop = 
                        tt-complemento.vlopcoop + crapris.vldivida.
        END.                   

        ASSIGN tt-complemento.dtrefer2 = tt-complemento.dtrefere. 
        LEAVE Busca.

    END. /* Busca */

    /* Gera log para tela LOGTEL */
    IF  par_flgdelog THEN
        RUN gera_log ( INPUT par_cdcooper,
                       INPUT 0,
                       INPUT par_cdoperad,
                       INPUT par_dtmvtolt,
                       INPUT par_cddopcao,
                       INPUT par_nrcpfcgc,
                       INPUT par_nrdconta).

    RETURN "OK".

END PROCEDURE. /* Busca_Complemento */


/* ------------------------------------------------------------------------ */
/*                  CONSULTAR FLUXO FINANCEIRO DO COOPERADO                 */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Fluxo:

     DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
     DEF OUTPUT PARAM par_msgretor AS CHAR                           NO-UNDO.
     
     DEF OUTPUT PARAM TABLE FOR tt-fluxo.                       
     DEF OUTPUT PARAM TABLE FOR tt-erro.

     DEF VAR aux_dtrefere AS DATE                                    NO-UNDO.
     DEF VAR par_dtrefere AS CHAR                                    NO-UNDO.

     EMPTY TEMP-TABLE tt-fluxo.
     EMPTY TEMP-TABLE tt-erro.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        
        RUN inicializa_fluxo( OUTPUT TABLE tt-fluxo ).
        /** Necessario verificar data base novamente no caso do usuario 
            consultar mais contas ou cpf's sem sair do browser **/
        RUN verifica_data_base ( OUTPUT aux_dtrefere, OUTPUT par_dtrefere ).
        
        /** crapopf nao possui cdcooper **/ 
        FOR LAST crapopf FIELDS(dtrefere)
               WHERE crapopf.nrcpfcgc = par_nrcpfcgc AND
        		     crapopf.dtrefere >= aux_dtrefere NO-LOCK: END.

        IF AVAIL crapopf THEN
        DO:  
            FOR EACH crapvop NO-LOCK 
               WHERE crapvop.nrcpfcgc = par_nrcpfcgc 
                 AND crapvop.dtrefere = crapopf.dtrefere:
                
                FIND FIRST tt-fluxo
                    WHERE tt-fluxo.cdvencto = crapvop.cdvencto NO-ERROR.
 
                IF  NOT AVAIL tt-fluxo  THEN
                    NEXT.

                ASSIGN tt-fluxo.cdvencto = crapvop.cdvencto
                       tt-fluxo.vlvencto = tt-fluxo.vlvencto + crapvop.vlvencto.
            END.
            
            ASSIGN aux_dtrefere = crapopf.dtrefere. 

        END. /** Fim avail crapopf **/
        ELSE 
            DO:
                FIND crapces WHERE crapces.nrcpfcgc  = par_nrcpfcgc AND
                                   crapces.dtrefere  = aux_dtrefere
                                   NO-LOCK NO-ERROR.

                IF NOT AVAIL(crapces) THEN
                   ASSIGN par_msgretor = "Informacoes do BACEN deste CPF/CNPJ" +
                                         " nao estao disponiveis.".
            END.

        LEAVE Busca.

    END. /* Busca */

    RETURN "OK".

END PROCEDURE. /* Busca_Fluxo */


/* ------------------------------------------------------------------------ */
/*           CONSULTAR FLUXO FINANCEIRO DE VENCIMENTO DO COOPERADO          */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Fluxo_Vencimento:

     DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
     DEF  INPUT PARAM par_cdvencto AS INTE                           NO-UNDO.
     
     DEF OUTPUT PARAM TABLE FOR tt-venc-fluxo.                       
     DEF OUTPUT PARAM TABLE FOR tt-erro.
     
     DEF VAR aux_vlvencto LIKE crapvop.vlvencto                      NO-UNDO.
     DEF VAR par_dtrefere AS CHAR                                    NO-UNDO.
     DEF VAR aux_dtrefere AS DATE                                    NO-UNDO.

     EMPTY TEMP-TABLE tt-venc-fluxo.
     EMPTY TEMP-TABLE tt-erro.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:

        RUN verifica_data_base ( OUTPUT aux_dtrefere, OUTPUT par_dtrefere ).

        ASSIGN aux_vlvencto = 0.

         FOR EACH crapvop  
           WHERE crapvop.nrcpfcgc = par_nrcpfcgc 
             AND crapvop.dtrefere = aux_dtrefere
             AND crapvop.cdvencto = par_cdvencto NO-LOCK
             BREAK BY SUBSTRING(crapvop.cdmodali,1,2):

            ASSIGN aux_vlvencto = aux_vlvencto + crapvop.vlvencto.

            IF LAST-OF(SUBSTRING(crapvop.cdmodali,1,2)) THEN
            DO:
                CREATE tt-venc-fluxo.
                ASSIGN tt-venc-fluxo.cdmodali = SUBSTRING(crapvop.cdmodali,1,2)
                       tt-venc-fluxo.vlvencto = aux_vlvencto
                       aux_vlvencto           = 0.

                FIND FIRST gnmodal NO-LOCK
                     WHERE gnmodal.cdmodali = 
                    SUBSTRING(crapvop.cdmodali,1,2) NO-ERROR.
                IF AVAIL gnmodal THEN
                    tt-venc-fluxo.dsmodali = gnmodal.dsmodali.
            END.
        END.

    END. /* Busca */

    RETURN "OK".

END PROCEDURE. /* Busca_Fluxo_Vencimento */


/* ------------------------------------------------------------------------ */
/*                 IMPRIMIR FLUXO FINANCEIRO DO COOPERADO                   */
/* ------------------------------------------------------------------------ */
PROCEDURE Imprimir_Fluxo:
               
     DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
     DEF  INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.  
     DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
     DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
     DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
     DEF  INPUT PARAM par_dsiduser AS CHAR                            NO-UNDO.
     DEF  INPUT PARAM par_nrcpfcgc AS DECI                            NO-UNDO.
     DEF  INPUT PARAM par_nmprimtl AS CHAR FORMAT "x(35)"             NO-UNDO.
     DEF  INPUT PARAM par_nrdconta AS INTE FORMAT "zzzz,zzz,z"        NO-UNDO.

     DEF OUTPUT PARAM aux_nmarqimp AS CHAR                            NO-UNDO.
     DEF OUTPUT PARAM aux_nmarqpdf AS CHAR                            NO-UNDO.
     DEF OUTPUT PARAM TABLE FOR tt-erro.
     
     DEF VAR par_dtrefere AS CHAR                                     NO-UNDO.
     DEF VAR aux_dtrefere AS DATE                                     NO-UNDO.
     DEF VAR aux_dsvencto AS CHAR  FORMAT "x(18)"          EXTENT 28  NO-UNDO.
     DEF VAR aux_vlvencto AS DECI  FORMAT "->>,>>>,>>9.99" EXTENT 28  NO-UNDO.
     DEF VAR aux_nmendter AS CHAR                                     NO-UNDO.
     DEF VAR aux_msgretor AS CHAR                                     NO-UNDO.

     FORM "CPF/CNPJ :"        par_nrcpfcgc  FORMAT "zzzzzzzzzzzzzzz" 
          "-" par_nmprimtl 
          SKIP
          "CONTA/DV :     "   par_nrdconta
          SKIP
          "DATA BASE:       " par_dtrefere  
          SKIP(1)
          WITH COLUMN 4 NO-LABEL NO-BOX FRAME f_fluxo_cab.

     FORM  
         "A VENCER"                                        AT 01
         "VALOR"                                           AT 30
         "LIMITE CREDITO"                                  AT 36
         "VALOR"                                           AT 65
         aux_dsvencto[1]                                   AT 01
         aux_vlvencto[1]  VIEW-AS FILL-IN NO-LABEL AT 21     
         aux_dsvencto[13]                                  AT 36     
         aux_vlvencto[13] VIEW-AS FILL-IN NO-LABEL AT 56      
         aux_dsvencto[2]                                   AT 01
         aux_vlvencto[2]  VIEW-AS FILL-IN NO-LABEL AT 21
         aux_dsvencto[14]                                  AT 36     
         aux_vlvencto[14] VIEW-AS FILL-IN NO-LABEL AT 56
         aux_dsvencto[3]                                   AT 01
         aux_vlvencto[3]  VIEW-AS FILL-IN NO-LABEL AT 21
         aux_dsvencto[15]                                  AT 36     
         aux_vlvencto[15] VIEW-AS FILL-IN NO-LABEL AT 56
         aux_dsvencto[4]                                   AT 01
         aux_vlvencto[4]  VIEW-AS FILL-IN NO-LABEL AT 21
         aux_dsvencto[16]                                  AT 36     
         aux_vlvencto[16] VIEW-AS FILL-IN NO-LABEL AT 56
         aux_dsvencto[5]                                   AT 01
         aux_vlvencto[5]  VIEW-AS FILL-IN NO-LABEL AT 21    
         ""                                                AT 36
         ""                                                AT 65
         aux_dsvencto[6]                                   AT 01
         aux_vlvencto[6]  VIEW-AS FILL-IN NO-LABEL AT 21
         "VENCIDOS"                                        AT 36
         ""                                                AT 65
         aux_dsvencto[7]                                   AT 01
         aux_vlvencto[7]  VIEW-AS FILL-IN NO-LABEL AT 21
         aux_dsvencto[17]                                  AT 36     
         aux_vlvencto[17] VIEW-AS FILL-IN NO-LABEL AT 56
         aux_dsvencto[8]                                   AT 01
         aux_vlvencto[8]  VIEW-AS FILL-IN NO-LABEL AT 21
         aux_dsvencto[18]                                  AT 36     
         aux_vlvencto[18] VIEW-AS FILL-IN NO-LABEL AT 56
         aux_dsvencto[9]                                   AT 01
         aux_vlvencto[9]  VIEW-AS FILL-IN NO-LABEL AT 21
         aux_dsvencto[19]                                  AT 36      
         aux_vlvencto[19] VIEW-AS FILL-IN NO-LABEL AT 56
         aux_dsvencto[10]                                   AT 01
         aux_vlvencto[10]  VIEW-AS FILL-IN NO-LABEL AT 21
         aux_dsvencto[20]                                  AT 36
         aux_vlvencto[20] VIEW-AS FILL-IN NO-LABEL AT 56
         aux_dsvencto[11]                                  AT 01
         aux_vlvencto[11] VIEW-AS FILL-IN NO-LABEL AT 21
         aux_dsvencto[21]                                  AT 36
         aux_vlvencto[21] VIEW-AS FILL-IN NO-LABEL AT 56
         aux_dsvencto[12]                                  AT 01
         aux_vlvencto[12] VIEW-AS FILL-IN NO-LABEL AT 21     
         aux_dsvencto[22]                                  AT 36
         aux_vlvencto[22] VIEW-AS FILL-IN NO-LABEL AT 56
         aux_dsvencto[23]                                  AT 36
         aux_vlvencto[23] VIEW-AS FILL-IN NO-LABEL AT 56     
         aux_dsvencto[24]                                  AT 36
         aux_vlvencto[24] VIEW-AS FILL-IN NO-LABEL AT 56
         aux_dsvencto[25]                                  AT 36
         aux_vlvencto[25] VIEW-AS FILL-IN NO-LABEL AT 56
         aux_dsvencto[26]                                  AT 36
         aux_vlvencto[26] VIEW-AS FILL-IN NO-LABEL AT 56
         aux_dsvencto[27]                                  AT 36
         aux_vlvencto[27] VIEW-AS FILL-IN NO-LABEL AT 56
         aux_dsvencto[28]                                  AT 36
         aux_vlvencto[28] VIEW-AS FILL-IN NO-LABEL AT 56
         SKIP(2)
         WITH NO-LABEL OVERLAY ROW 7 COLUMN 3 WIDTH 76 FRAME f_fluxo.   

     ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
            aux_dstransa = "Imprimir"
            aux_dscritic = ""
            aux_cdcritic = 0
            aux_returnvl = "NOK".

     EMPTY TEMP-TABLE tt-erro.

    Imprimir: DO ON ERROR UNDO Imprimir, LEAVE Imprimir:
        
        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
            
        ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop +
                              "/rl/" + par_dsiduser.

        IF   par_dsiduser <> ""  THEN
             UNIX SILENT VALUE("rm " + aux_nmendter + "* 2> /dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

        /* Cdempres = 11 , Relatorio 569 em 80 colunas */
        { sistema/generico/includes/b1cabrelvar.i }
        { sistema/generico/includes/b1cabrel080.i "11" "569" }

        VIEW STREAM str_1 FRAME f_cabrel.

        EMPTY TEMP-TABLE tt-fluxo.

        RUN verifica_data_base ( OUTPUT aux_dtrefere, OUTPUT par_dtrefere ).

        RUN Busca_Fluxo ( 
              INPUT par_nrcpfcgc,
             OUTPUT aux_msgretor,
             OUTPUT TABLE tt-fluxo,
             OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
            LEAVE Imprimir.

        DISPLAY STREAM str_1  par_nrcpfcgc
                              par_nmprimtl
                              par_nrdconta
                              par_dtrefere
                              WITH FRAME f_fluxo_cab.

        ASSIGN aux_dsvencto = "".
        ASSIGN aux_vlvencto = 0.

    	FOR EACH tt-fluxo:
    		ASSIGN aux_dsvencto[tt-fluxo.elemento] = tt-fluxo.dsvencto
    			   aux_vlvencto[tt-fluxo.elemento] = tt-fluxo.vlvencto.
    	END.

        DISPLAY STREAM str_1 aux_dsvencto aux_vlvencto WITH FRAME f_fluxo.

        OUTPUT STREAM str_1 CLOSE.
        
        ASSIGN aux_returnvl = "OK".
        LEAVE Imprimir.

    END. /* Imprimir */

    ASSIGN aux_returnvl = "OK".       

    IF  par_idorigem = 5  THEN  /** Ayllos Web **/
        DO:
            RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                SET h-b1wgen0024.

            IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                DO:
                    ASSIGN aux_dscritic = "Handle invalido para BO " +
                                          "b1wgen0024.".

                END.

            RUN envia-arquivo-web IN h-b1wgen0024 
                ( INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa,
                  INPUT aux_nmarqimp,
                 OUTPUT aux_nmarqpdf,
                 OUTPUT TABLE tt-erro ).

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.

            IF  RETURN-VALUE <> "OK" THEN
                ASSIGN aux_returnvl = "NOK".
        END.


    RETURN aux_returnvl.

END PROCEDURE. /* Imprimir_Fluxo */


/* ------------------------------------------------------------------------ */
/*           IMPRIMIR INFORMACOES DA CENTRAL DE RISCO DO COOPERADO.         */
/* ------------------------------------------------------------------------ */
PROCEDURE Imprimir_Risco:
     
     DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
     DEF  INPUT PARAM par_cdagencx AS INTE                                  NO-UNDO.
     DEF  INPUT PARAM par_nrdcaixa AS INTE                                  NO-UNDO.
     DEF  INPUT PARAM par_nmdatela AS CHAR                                  NO-UNDO.
     DEF  INPUT PARAM par_cdoperad AS CHAR                                  NO-UNDO.
     DEF  INPUT PARAM par_idorigem AS INTE                                  NO-UNDO.
     DEF  INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
     DEF  INPUT PARAM par_dsiduser AS CHAR                                  NO-UNDO.
     DEF  INPUT PARAM par_cddopcao AS CHAR                                  NO-UNDO.
     DEF  INPUT PARAM par_tpconsul AS INTE                                  NO-UNDO.
     DEF  INPUT PARAM par_nrcpfcgc AS DECIMAL FORMAT "zzzzzzzzzzzzz9"       NO-UNDO.
     DEF  INPUT PARAM par_nrdconta AS INT                                   NO-UNDO.
     DEF  INPUT PARAM par_cdagenci AS INT init 1                            NO-UNDO.
     DEF  INPUT PARAM par_flgerlog AS LOGICAL                               NO-UNDO. /* erro */                                                                   
     DEF  INPUT PARAM par_flgdelog AS LOGICAL                               NO-UNDO. /* log  */                                                                   

     DEF OUTPUT PARAM aux_nmarqimp AS CHAR                                  NO-UNDO.
     DEF OUTPUT PARAM aux_nmarqpdf AS CHAR                                  NO-UNDO.

     DEF OUTPUT PARAM TABLE FOR tt-erro.

     DEF VAR tel_dtrefere AS CHAR                                           NO-UNDO.
     
     DEF VAR aux_nrdconta AS INTE    FORMAT "zzzz,zzz,9"                    NO-UNDO.
     DEF VAR aux_nrcpfcgc LIKE crapass.nrcpfcgc                             NO-UNDO.
     DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
     DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
     
     DEF VAR aux_contador AS INT     FORMAT "zz9"                           NO-UNDO.
     DEF VAR aux_dtrefere AS DATE    FORMAT "99/99/9999"                    NO-UNDO.
     DEF VAR aux_dtrefris AS DATE    FORMAT "99/99/9999"                    NO-UNDO.
     DEF VAR aux_qtopesfn AS INTE                                           NO-UNDO.
     DEF VAR aux_qtifssfn AS INTE                                           NO-UNDO.
     DEF VAR aux_opfinanc AS DECI    FORMAT "z,zzz,zzz,zz9.99"              NO-UNDO.
     DEF VAR aux_opvencid AS DECI                                           NO-UNDO.
     DEF VAR aux_opcooper AS DECI    FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
     DEF VAR aux_oprejuiz AS DECI                                           NO-UNDO.
     DEF VAR aux_opdtbase AS DECI    FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
                                                                        
     DEF VAR aux_disponiv AS CHAR                                           NO-UNDO.
     
     /* Variaveis para impressao */                                     
     DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"          NO-UNDO.
     DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"          NO-UNDO.
     
     DEF VAR aux_nmendter AS CHAR                                           NO-UNDO.
     DEF VAR aux_flgescra AS LOGICAL                                        NO-UNDO.
     DEF VAR aux_dscomand AS CHARACTER                                      NO-UNDO.
     DEF VAR par_flgrodar AS LOGICAL                                        NO-UNDO.
     DEF VAR par_flgfirst AS LOGICAL                                        NO-UNDO.
     DEF VAR par_flgcance AS LOGICAL                                        NO-UNDO.

     DEF VAR aux_data     AS DATE                                           NO-UNDO.
                                                                         
     FORM "Consulta Central de Risco - Data Base Bacen:" tel_dtrefere SKIP(1)
         WITH 8 DOWN ROW 10 COLUMN 2 WIDTH 132 OVERLAY NO-BOX NO-LABEL FRAME f_titulo. 
     
     FORM aux_cdagenci LABEL "PA"                 FORMAT "zz9"                               
          aux_nrdconta LABEL "Conta"               FORMAT "zzzz,zzz,9"
          aux_nrcpfcgc LABEL "CPF/CNPJ"            FORMAT "zzzzzzzzzzzzz9"
          aux_nmprimtl LABEL "Nome"                FORMAT "x(10)" 
          aux_qtopesfn LABEL "QtOper"              FORMAT "zzz9"
          aux_qtifssfn LABEL "QtIfs"               FORMAT "zzz9"                               
          aux_opfinanc LABEL "Op.SFN"              FORMAT "z,zzz,zzz,zz9.99"        
          aux_opvencid LABEL "Op.Vencidas"         FORMAT "zzz,zzz,zz9.99"                           
          aux_oprejuiz LABEL "Op.Prejuizo"         FORMAT "zzz,zzz,zz9.99"                           
          aux_opcooper LABEL "Op.Coop. Atual"      FORMAT "zzz,zzz,zz9.99"                          
          aux_opdtbase LABEL "Op.Coop. Bacen"      FORMAT "zzz,zzz,zz9.99"                           
          WITH 8 DOWN ROW 13 COLUMN 2 WIDTH 132 OVERLAY NO-BOX NO-LABEL FRAME f_dados. 
     
     FORM aux_cdagenci LABEL "PA"                 FORMAT "zz9"                               
          aux_nrdconta LABEL "Conta"               FORMAT "zzzz,zzz,9"
          aux_nrcpfcgc LABEL "CPF/CNPJ"            FORMAT "zzzzzzzzzzzzz9"
          aux_nmprimtl LABEL "Nome"                FORMAT "x(40)"                SKIP  
          aux_disponiv LABEL ""                    FORMAT "x(14)"                AT 1     
          aux_qtopesfn LABEL "QtOper"              FORMAT "zzz9"                 AT 40
          aux_qtifssfn LABEL "QtIfs"               FORMAT "zzz9"                               
          aux_opfinanc LABEL "Op.SFN"              FORMAT "z,zzz,zzz,zz9.99"        
          aux_opvencid LABEL "Op.Vencidas"         FORMAT "zzz,zzz,zz9.99"                           
          aux_oprejuiz LABEL "Op.Prejuizo"         FORMAT "zzz,zzz,zz9.99"                           
          aux_opcooper LABEL "Op.Coop. Atual"      FORMAT "zzz,zzz,zz9.99"                          
          aux_opdtbase LABEL "Op.Coop. Bacen"      FORMAT "zzz,zzz,zz9.99"                                 
          WITH 8 DOWN  COLUMN 2 WIDTH 132 OVERLAY NO-BOX NO-LABEL FRAME f_dados2linhas. 
     
     ASSIGN aux_dscritic = ""
            aux_cdcritic = 0
            aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
            aux_dstransa = "Imprimir informacoes da Central de Risco" +
                           " do cooperado."
            aux_returnvl = "NOK".

     Imprimir: DO ON ERROR UNDO Imprimir, LEAVE Imprimir:
        
         IF  par_tpconsul = 3 THEN
             DO:
                 FIND crapage WHERE    crapage.cdcooper = par_cdcooper AND
                                       crapage.cdagenci = par_cdagenci                                       
                                       NO-LOCK NO-ERROR.

                 IF  NOT AVAIL crapage THEN
                     DO:
                          ASSIGN aux_cdcritic = 962.
                          LEAVE Imprimir.
                     END.
                 
                 FIND crapage WHERE    crapage.cdcooper = par_cdcooper AND
                                       crapage.cdagenci = par_cdagenci AND
                                      (crapage.insitage = 1 OR /* Ativo */
                                       crapage.insitage = 3)   /* Temporariamente Indisponivel */
                                       NO-LOCK NO-ERROR.
        
                 IF  NOT AVAIL crapage THEN
                     DO:
                          ASSIGN aux_cdcritic = 856.
                          LEAVE Imprimir.
                     END.

         END.

         FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

         ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop +
                               "/rl/" + par_dsiduser.

         IF   par_dsiduser <> ""  THEN
              UNIX SILENT VALUE("rm " + aux_nmendter + "* 2> /dev/null").

         ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
                aux_nmarqimp = aux_nmendter + ".ex"
                aux_nmarqpdf = aux_nmendter + ".pdf".

         OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp) PAGED PAGE-SIZE 80.
         
         /* Gera o cabecalho do arquivo */
         { sistema/generico/includes/b1cabrelvar.i }
         { sistema/generico/includes/b1cabrel132.i "11"  "569" }

         VIEW STREAM str_1 FRAME f_cabrel132_1.   
         
         ASSIGN aux_dtrefris = par_dtmvtolt - DAY(par_dtmvtolt).

         ASSIGN aux_data = ADD-INTERVAL (TODAY, -1, "MONTH").

         DO WHILE TRUE:

            /** Tabela crapopf nao possui cdcooper **/
           FIND LAST crapopf WHERE crapopf.dtrefere >= aux_data 
               USE-INDEX crapopf2 NO-LOCK NO-ERROR.
           
           IF   AVAIL crapopf   THEN DO:
                ASSIGN aux_dtrefere = crapopf.dtrefere.
                LEAVE.
           END.
           ELSE
                ASSIGN aux_data =  ADD-INTERVAL (aux_data, -1, "MONTH").
    
         END.
/*
         

         /** Tabela crapopf nao possui cdcooper **/
         FIND LAST crapopf WHERE crapopf.dtrefere >= aux_data 
            USE-INDEX crapopf2 NO-LOCK NO-ERROR.
            
         /*
         FIND LAST crapopf USE-INDEX crapopf2 NO-LOCK NO-ERROR.     */
         IF AVAILABLE crapopf THEN
             aux_dtrefere = crapopf.dtrefere.
*/         
         CASE (MONTH(aux_dtrefere)):    
             WHEN 1 THEN         
                 ASSIGN tel_dtrefere = "Jan/"+ STRING(YEAR(aux_dtrefere)).           
             WHEN 2 THEN         
                 ASSIGN tel_dtrefere = "Fev/"+ STRING(YEAR(aux_dtrefere)).          
             WHEN 3 THEN         
                 ASSIGN tel_dtrefere = "Mar/"+ STRING(YEAR(aux_dtrefere)).          
             WHEN 4 THEN         
                 ASSIGN tel_dtrefere = "Abr/"+ STRING(YEAR(aux_dtrefere)).        
             WHEN 5 THEN         
                 ASSIGN tel_dtrefere = "Mai/"+ STRING(YEAR(aux_dtrefere)).       
             WHEN 6 THEN         
                 ASSIGN tel_dtrefere = "Jun/"+ STRING(YEAR(aux_dtrefere)).        
             WHEN 7 THEN         
                 ASSIGN tel_dtrefere = "Jul/"+ STRING(YEAR(aux_dtrefere)).
             WHEN 8 THEN         
                 ASSIGN tel_dtrefere = "Ago/"+ STRING(YEAR(aux_dtrefere)).    
             WHEN 9 THEN         
                 ASSIGN tel_dtrefere = "Set/"+ STRING(YEAR(aux_dtrefere)).    
             WHEN 10 THEN         
                 ASSIGN tel_dtrefere = "Out/"+ STRING(YEAR(aux_dtrefere)).    
             WHEN 11 THEN         
                 ASSIGN tel_dtrefere = "Nov/"+ STRING(YEAR(aux_dtrefere)).          
             WHEN 12 THEN         
                 ASSIGN tel_dtrefere = "Dez/"+ STRING(YEAR(aux_dtrefere)).    
         END CASE.
         
         DISPLAY STREAM str_1 tel_dtrefere WITH FRAME f_titulo.
         
         /* Procura por CPF/CNPJ */
         IF par_nrcpfcgc <> 0 THEN
         DO:     
             FOR EACH crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                    crapttl.nrcpfcgc = par_nrcpfcgc AND 
                                    crapttl.nrdconta = par_nrdconta NO-LOCK:
         
                 FIND FIRST crapass WHERE 
                            crapass.cdcooper = crapttl.cdcooper AND
                            crapass.nrdconta = crapttl.nrdconta AND
                            crapass.dtdemiss = ?   NO-LOCK NO-ERROR.
                 
                 IF AVAILABLE crapass THEN
                 DO:
                     ASSIGN aux_opfinanc = 0
                            aux_opvencid = 0
                            aux_oprejuiz = 0
                            aux_opcooper = 0
                            aux_opdtbase = 0
                            aux_qtopesfn = 0
                            aux_qtifssfn = 0
                           
                            aux_disponiv = "".
                        
                     FIND LAST crapopf WHERE crapopf.dtrefere = aux_dtrefere AND
                                             crapopf.nrcpfcgc = crapttl.nrcpfcgc
                                       NO-LOCK NO-ERROR.
                     IF AVAILABLE crapopf THEN
                        DO:
                            ASSIGN aux_qtopesfn = crapopf.qtopesfn
                                   aux_qtifssfn = crapopf.qtifssfn.
             
                            FOR EACH crapvop WHERE 
                                crapvop.dtrefere = crapopf.dtrefere AND
                                crapvop.nrcpfcgc = crapttl.nrcpfcgc NO-LOCK:
                                ASSIGN aux_opfinanc = 
                                        aux_opfinanc + crapvop.vlvencto.
             
                                 /*Operações Vencidas*/
                                 IF crapvop.cdvencto >= 205 AND
                                    crapvop.cdvencto <= 290 THEN
                                    ASSIGN aux_opvencid = 
                                            aux_opvencid + crapvop.vlvencto.
             
                                 /*Operações Prejuizo */
                                 IF crapvop.cdvencto >= 310 AND
                                    crapvop.cdvencto <= 330 THEN
                                    ASSIGN aux_oprejuiz = 
                                            aux_oprejuiz + crapvop.vlvencto.
             
                            END. /* for each crapvop */
         
                            IF crapttl.idseqttl = 1 THEN
                                 /*Coop Data Base*/
                                  FOR EACH crapris WHERE 
                                   crapris.cdcooper = par_cdcooper      AND
                                   crapris.nrdconta = crapttl.nrdconta  AND
                                   crapris.dtrefere = aux_dtrefere      AND
                                   crapris.inddocto = 1 USE-INDEX crapris1 
                                                                    NO-LOCK:
         
                                      ASSIGN aux_opdtbase = 
                                                aux_opdtbase + crapris.vldivida.
                                 END.
                         
                        END. /*IF AVAILABLE crapopf*/
         
                     ELSE
                         DO:   
                            FIND crapces WHERE 
                                 crapces.nrcpfcgc  = crapttl.nrcpfcgc AND
                                 crapces.dtrefere  = aux_dtrefere
                                 NO-LOCK NO-ERROR.
                            
                            IF  NOT AVAIL(crapces) THEN
                                DO:
                                    ASSIGN aux_opfinanc = 0
                                           aux_opvencid = 0
                                           aux_oprejuiz = 0
                                           aux_qtopesfn = 9999
                                           aux_qtifssfn = 9999
    
                                           aux_disponiv = "NAO DISPONIVEL".
                                END.
                         END.
         
                     ASSIGN aux_cdagenci = crapass.cdagenci
                            aux_nrdconta = crapttl.nrdconta
                            aux_nrcpfcgc = crapttl.nrcpfcgc
                            aux_nmprimtl = crapttl.nmextttl.
         
                     /*Op Cooper*/
                     IF crapttl.idseqttl = 1 THEN
                             FOR EACH crapris WHERE 
                                      crapris.cdcooper = par_cdcooper     AND
                                      crapris.nrdconta = crapttl.nrdconta AND
                                      crapris.dtrefere = aux_dtrefris     AND
                                      crapris.inddocto = 1 USE-INDEX crapris1
                                                                      NO-LOCK:
                                 ASSIGN aux_opcooper = 
                                        aux_opcooper + crapris.vldivida.
                             END.
         
                     DISP STREAM str_1
                                 aux_cdagenci
                                 aux_nrdconta
                                 aux_nrcpfcgc
                                 aux_nmprimtl
                                 aux_disponiv
                                 aux_qtopesfn
                                 aux_qtifssfn
                                 aux_opfinanc
                                 aux_opvencid
                                 aux_oprejuiz
                                 aux_opcooper
                                 aux_opdtbase
                                 WITH FRAME f_dados2linhas.
                     DOWN STREAM str_1 WITH FRAME f_dados2linhas.
         
                 END. /*if available crapass*/
             END. /*crapttl*/
         
             FOR EACH crapass WHERE crapass.cdcooper = par_cdcooper AND
                                    crapass.nrcpfcgc = par_nrcpfcgc AND
                                    crapass.nrdconta = par_nrdconta AND
                                   (crapass.inpessoa = 2            OR
                                    crapass.inpessoa = 3)           AND
                                    crapass.dtdemiss = ? NO-LOCK:
             
                     ASSIGN aux_opfinanc = 0
                            aux_opvencid = 0
                            aux_oprejuiz = 0
                            aux_opcooper = 0
                            aux_opdtbase = 0
                            aux_qtopesfn = 0
                            aux_qtifssfn = 0
                         
                            aux_disponiv = "".
                        
                     FIND LAST crapopf WHERE 
                               crapopf.dtrefere = aux_dtrefere AND
                               crapopf.nrcpfcgc = crapass.nrcpfcgc
                                       NO-LOCK NO-ERROR.
                     IF AVAILABLE crapopf THEN
                        DO:
                            ASSIGN aux_qtopesfn = crapopf.qtopesfn
                                   aux_qtifssfn = crapopf.qtifssfn.
             
                            FOR EACH crapvop WHERE 
                                     crapvop.dtrefere = crapopf.dtrefere AND
                                     crapvop.nrcpfcgc = crapass.nrcpfcgc
                                                   NO-LOCK:
                                ASSIGN aux_opfinanc = 
                                        aux_opfinanc + crapvop.vlvencto.
             
                                 /*Operações Vencidas*/
                                 IF crapvop.cdvencto >= 205 AND
                                    crapvop.cdvencto <= 290 THEN
                                    ASSIGN aux_opvencid = 
                                            aux_opvencid + crapvop.vlvencto.
             
                                 /*Operações Prejuizo */
                                 IF crapvop.cdvencto >= 310 AND
                                    crapvop.cdvencto <= 330 THEN
                                    ASSIGN aux_oprejuiz = 
                                            aux_oprejuiz + crapvop.vlvencto.
             
                            END. /* for each crapvop */
             
                            /*Coop Data Base*/
                            FOR EACH crapris WHERE 
                                     crapris.cdcooper = par_cdcooper      AND
                                     crapris.nrdconta = crapass.nrdconta  AND
                                     crapris.dtrefere = aux_dtrefere      AND
                                     crapris.inddocto = 1 USE-INDEX crapris1
                                                                         NO-LOCK:
         
                                ASSIGN aux_opdtbase = 
                                        aux_opdtbase + crapris.vldivida.
                           END.
             
                        END. /*IF AVAILABLE crapopf*/
         
                    ELSE
                        DO:
                            FIND crapces WHERE 
                                 crapces.nrcpfcgc  = crapass.nrcpfcgc AND
                                 crapces.dtrefere  = aux_dtrefere
                                 NO-LOCK NO-ERROR.
                           
                            IF  NOT AVAIL(crapces) THEN
                                DO:
                                    ASSIGN aux_opfinanc = 0
                                           aux_opvencid = 0
                                           aux_oprejuiz = 0
                                           aux_qtopesfn = 9999
                                           aux_qtifssfn = 9999
    
                                           aux_disponiv = "NAO DISPONIVEL".
                                END.
                        END.
         
                     ASSIGN aux_cdagenci = crapass.cdagenci
                            aux_nrdconta = crapass.nrdconta
                            aux_nrcpfcgc = crapass.nrcpfcgc
                            aux_nmprimtl = crapass.nmprimtl.
         
                     /*Op Cooper*/
                     FOR EACH crapris WHERE 
                              crapris.cdcooper = par_cdcooper     AND
                              crapris.nrdconta = crapass.nrdconta AND
                              crapris.dtrefere = aux_dtrefris     AND
                              crapris.inddocto = 1 USE-INDEX crapris1
                                                                  NO-LOCK:
                         ASSIGN aux_opcooper = aux_opcooper + crapris.vldivida.
                     END.
         
                     DISP STREAM str_1
                                 aux_cdagenci
                                 aux_nrdconta
                                 aux_nrcpfcgc
                                 aux_nmprimtl
                                 aux_disponiv
                                 aux_qtopesfn
                                 aux_qtifssfn
                                 aux_opfinanc
                                 aux_opvencid
                                 aux_oprejuiz
                                 aux_opcooper
                                 aux_opdtbase
                                 WITH FRAME f_dados2linhas.
                     DOWN STREAM str_1 WITH FRAME f_dados2linhas.
                     
         
             END. /* for each crapass */
         END. /* if par_nrcpfcgc <> 0 */
         
         /* Procura por agencia */
         ELSE
         DO:
             FOR EACH crapass NO-LOCK WHERE crapass.cdcooper = par_cdcooper AND
                                          ( crapass.cdagenci = par_cdagenci OR
                                                par_cdagenci = 0 )          AND
                                            crapass.dtdemiss = ? 
                                            BY crapass.cdagenci
                                            BY crapass.nrdconta:
         
                 IF crapass.inpessoa = 1 THEN
                     FOR EACH crapttl WHERE 
                              crapttl.cdcooper = par_cdcooper AND
                              crapttl.nrdconta = crapass.nrdconta NO-LOCK:
         
                         ASSIGN aux_opfinanc = 0
                                aux_opvencid = 0
                                aux_oprejuiz = 0
                                aux_opcooper = 0
                                aux_opdtbase = 0
                                aux_qtopesfn = 0
                                aux_qtifssfn = 0
                             
                                aux_disponiv = "".
                            
                         FIND LAST crapopf WHERE 
                                   crapopf.dtrefere = aux_dtrefere AND
                                   crapopf.nrcpfcgc = crapttl.nrcpfcgc
                                           NO-LOCK NO-ERROR.
                         IF AVAILABLE crapopf THEN
                            DO:
                                ASSIGN aux_qtopesfn = crapopf.qtopesfn
                                       aux_qtifssfn = crapopf.qtifssfn.
         
                                FOR EACH crapvop WHERE 
                                         crapvop.nrcpfcgc = crapttl.nrcpfcgc AND
                                         crapvop.dtrefere = crapopf.dtrefere
                                                       NO-LOCK:
                                    ASSIGN aux_opfinanc = 
                                            aux_opfinanc + crapvop.vlvencto.
         
                                     /*Operações Vencidas*/
                                     IF crapvop.cdvencto >= 205 AND
                                        crapvop.cdvencto <= 290 THEN
                                        ASSIGN aux_opvencid = 
                                                aux_opvencid + crapvop.vlvencto.
         
                                     /*Operações Prejuizo */
                                     IF crapvop.cdvencto >= 310 AND
                                        crapvop.cdvencto <= 330 THEN
                                        ASSIGN aux_oprejuiz = 
                                            aux_oprejuiz + crapvop.vlvencto.
         
                                END. /* for each crapvop */
         
                                IF crapttl.idseqttl = 1 THEN
                                   /*Coop Data Base*/
                                   FOR EACH crapris WHERE 
                                            crapris.cdcooper = par_cdcooper  AND
                                            crapris.nrdconta = crapttl.nrdconta  AND
                                            crapris.dtrefere = aux_dtrefere  AND
                                            crapris.inddocto = 1                 
                                                          USE-INDEX crapris1
                                                          NO-LOCK:
         
                                       ASSIGN aux_opdtbase = 
                                                aux_opdtbase + crapris.vldivida.
                                   END.
                             
                            END. /*IF AVAILABLE crapopf*/
         
                         ELSE
                            DO:
                                FIND crapces WHERE 
                                     crapces.nrcpfcgc  = crapttl.nrcpfcgc AND
                                     crapces.dtrefere  = aux_dtrefere
                                     NO-LOCK NO-ERROR.
                                
                                IF  NOT AVAIL(crapces) THEN
                                    DO:
                                        ASSIGN aux_opfinanc = 0
                                               aux_opvencid = 0
                                               aux_oprejuiz = 0
                                               aux_qtopesfn = 9999
                                               aux_qtifssfn = 9999
    
                                               aux_disponiv = "NAO DISPONIVEL".
                                    END.
                            END.
         
                         ASSIGN aux_cdagenci = crapass.cdagenci
                                aux_nrdconta = crapttl.nrdconta
                                aux_nrcpfcgc = crapttl.nrcpfcgc
                                aux_nmprimtl = crapttl.nmextttl.
         
                         IF crapttl.idseqttl = 1 THEN
                             /*Op Cooper*/
                             FOR EACH crapris WHERE 
                                      crapris.cdcooper = par_cdcooper     AND
                                      crapris.nrdconta = crapttl.nrdconta AND
                                      crapris.dtrefere = aux_dtrefris     AND
                                      crapris.inddocto = 1 USE-INDEX crapris1
                                                    NO-LOCK:
                                 ASSIGN aux_opcooper = 
                                            aux_opcooper + crapris.vldivida.
                             END.
         
                         DISP STREAM str_1
                                     aux_cdagenci
                                     aux_nrdconta
                                     aux_nrcpfcgc
                                     aux_nmprimtl
                                     aux_disponiv
                                     aux_qtopesfn
                                     aux_qtifssfn
                                     aux_opfinanc
                                     aux_opvencid
                                     aux_oprejuiz
                                     aux_opcooper
                                     aux_opdtbase
                                     WITH FRAME f_dados2linhas.
                         DOWN STREAM str_1 WITH FRAME f_dados2linhas.
         
                     END. /*For each crapttl*/
                 ELSE
                     IF crapass.inpessoa <> 1 THEN
                     DO:
                         ASSIGN aux_opfinanc = 0
                                aux_opvencid = 0
                                aux_oprejuiz = 0
                                aux_opdtbase = 0
                                aux_qtopesfn = 0
                                aux_qtifssfn = 0
                             
                                aux_disponiv = "".
                            
                         FIND LAST crapopf WHERE 
                                   crapopf.dtrefere = aux_dtrefere AND
                                   crapopf.nrcpfcgc = crapass.nrcpfcgc
                                           NO-LOCK NO-ERROR.
                         IF AVAILABLE crapopf THEN
                            DO:
                                ASSIGN aux_qtopesfn = crapopf.qtopesfn
                                       aux_qtifssfn = crapopf.qtifssfn.
         
                                FOR EACH crapvop WHERE 
                                         crapvop.dtrefere = 
                                         crapopf.dtrefere AND
                                         crapvop.nrcpfcgc = crapass.nrcpfcgc
                                                       NO-LOCK:
                                    ASSIGN aux_opfinanc = 
                                                aux_opfinanc + crapvop.vlvencto.
         
                                     /*Operações Vencidas*/
                                     IF crapvop.cdvencto >= 205 AND
                                        crapvop.cdvencto <= 290 THEN
                                        ASSIGN aux_opvencid = 
                                                aux_opvencid + crapvop.vlvencto.
         
                                     /*Operações Prejuizo */
                                     IF crapvop.cdvencto >= 310 AND
                                        crapvop.cdvencto <= 330 THEN
                                        ASSIGN aux_oprejuiz = 
                                                aux_oprejuiz + crapvop.vlvencto.
         
                                END. /* for each crapvop */
         
                                /*Coop Data Base*/
                                FOR EACH crapris WHERE 
                                         crapris.cdcooper = par_cdcooper     AND
                                         crapris.nrdconta = crapass.nrdconta AND
                                         crapris.dtrefere = aux_dtrefere     AND
                                         crapris.inddocto = 1 USE-INDEX crapris1
                                                                NO-LOCK:
         
                                    ASSIGN aux_opdtbase = 
                                            aux_opdtbase + crapris.vldivida.
                               END.
         
                            END. /*IF AVAILABLE crapopf*/
         
                         ELSE
                            DO:
                                FIND crapces WHERE 
                                     crapces.nrcpfcgc  = crapass.nrcpfcgc AND
                                     crapces.dtrefere  = aux_dtrefere
                                     NO-LOCK NO-ERROR.
                                 
                                IF  NOT AVAIL(crapces) THEN
                                    DO:
                                        ASSIGN aux_opfinanc = 0
                                               aux_opvencid = 0
                                               aux_oprejuiz = 0
                                               aux_qtopesfn = 9999
                                               aux_qtifssfn = 9999
    
                                               aux_disponiv = "NAO DISPONIVEL".
                                    END.
                            END.
         
                         ASSIGN aux_cdagenci = crapass.cdagenci
                                aux_nrdconta = crapass.nrdconta
                                aux_nrcpfcgc = crapass.nrcpfcgc
                                aux_nmprimtl = crapass.nmprimtl.
         
                         /*Op Cooper*/
                         FOR EACH crapris WHERE crapris.cdcooper = 
                                                    par_cdcooper     AND
                                                crapris.nrdconta = 
                                                    crapass.nrdconta AND
                                                crapris.dtrefere = 
                                                    aux_dtrefris     AND
                                                crapris.inddocto = 1 
                                                USE-INDEX crapris1
                                                NO-LOCK:
                             ASSIGN aux_opcooper = 
                                    aux_opcooper + crapris.vldivida.
                         END.
         
                         DISP STREAM str_1
                                     aux_cdagenci
                                     aux_nrdconta
                                     aux_nrcpfcgc
                                     aux_nmprimtl
                                     aux_disponiv
                                     aux_qtopesfn
                                     aux_qtifssfn
                                     aux_opfinanc
                                     aux_opvencid
                                     aux_oprejuiz
                                     aux_opcooper
                                     aux_opdtbase
                                     WITH FRAME f_dados2linhas.
                         DOWN STREAM str_1 WITH FRAME f_dados2linhas.
         
                     END. /*crapass.inpessoa <> 1*/
             END. /* for each crapass */           
         END. /* if par_cdagenci <> 0 */
         
         OUTPUT STREAM str_1 CLOSE.

     END. /* Imprimir */

     /* Gera log para tela LOGTEL */
     IF  par_flgdelog THEN
         RUN gera_log ( INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_cdoperad,
                        INPUT par_dtmvtolt,
                        INPUT par_cddopcao,
                        INPUT par_nrcpfcgc,
                        INPUT par_nrdconta).


     /* Gera erro */
     IF  TEMP-TABLE tt-erro:HAS-RECORDS OR
         aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF  AVAIL tt-erro THEN
                 ASSIGN aux_dscritic = tt-erro.dscritic.
             ELSE 
                 RUN gera_erro ( INPUT par_cdcooper,
                                 INPUT par_cdagencx,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic ).

             IF  par_flgerlog  THEN
                 RUN proc_gerar_log ( INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT 1,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                     OUTPUT aux_nrdrowid ).

             RETURN "NOK".
         END.
     ELSE
         DO:
            
             ASSIGN aux_returnvl = "OK".       

             IF  par_idorigem = 5  THEN  /** Ayllos Web **/
                 DO:
                     RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                         SET h-b1wgen0024.

                     IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                         DO:
                             ASSIGN aux_dscritic = "Handle invalido para BO " +
                                                   "b1wgen0024.".

                         END.

                     RUN envia-arquivo-web IN h-b1wgen0024 
                         ( INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT aux_nmarqimp,
                          OUTPUT aux_nmarqpdf,
                          OUTPUT TABLE tt-erro ).

                     IF  VALID-HANDLE(h-b1wgen0024)  THEN
                         DELETE PROCEDURE h-b1wgen0024.

                     IF  RETURN-VALUE <> "OK" THEN
                         ASSIGN aux_returnvl = "NOK".
                 END.
         END.


    RETURN  aux_returnvl.

END PROCEDURE. /* Imprimir Risco */

/* ------------------------------------------------------------------------ */
/*          CONSULTAR O HISTORICO DA CENTRAL DE RISCO DO COOPERADO.         */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Historico:

     DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
     DEF OUTPUT PARAM TABLE FOR tt-historico.                       
     DEF OUTPUT PARAM TABLE FOR tt-erro.
     
     DEF VAR aux_contador AS INTE                                    NO-UNDO.
     DEF VAR aux_dtrefere AS DATE                                    NO-UNDO.
     DEF VAR par_dtrefere AS CHAR                                    NO-UNDO.
     DEF VAR aux_dtrefsum AS CHAR FORMAT "x(08)"                     NO-UNDO.
     DEF VAR aux_vlvencto LIKE crapvop.vlvencto                      NO-UNDO.
     DEF VAR aux_dtmesref AS INT                                     NO-UNDO.
     DEF VAR aux_dtanoref AS INT                                     NO-UNDO.
     DEF VAR aux_dtmesfim AS DATE                                    NO-UNDO.

     EMPTY TEMP-TABLE tt-historico.
     EMPTY TEMP-TABLE tt-erro.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:

        RUN verifica_data_base ( OUTPUT aux_dtrefere, OUTPUT par_dtrefere ).

        ASSIGN aux_dtmesref = MONTH(aux_dtrefere)
               aux_dtanoref =  YEAR(aux_dtrefere). 

        DO aux_contador = 1 TO 8:

            /************ ENCONTRA O ÚLTIMO DIA DE CADA MÊS ************/
            ASSIGN aux_dtmesfim = DATE(aux_dtmesref,01,aux_dtanoref) + 32        
                   aux_dtmesfim = aux_dtmesfim - DAY(aux_dtmesfim).  
            
            FIND LAST crapopf NO-LOCK
                 WHERE crapopf.nrcpfcgc = par_nrcpfcgc
                   AND crapopf.dtrefere = aux_dtmesfim NO-ERROR.
            IF AVAIL crapopf THEN
            DO: 
                ASSIGN aux_vlvencto = 0
                       aux_dtrefsum = "".
    
                FOR EACH crapvop NO-LOCK
                   WHERE crapvop.nrcpfcgc = crapopf.nrcpfcgc
                     AND crapvop.dtrefere = crapopf.dtrefere:
    
                    ASSIGN aux_vlvencto = aux_vlvencto + crapvop.vlvencto.
                END.
    
                RUN verifica_data_historico(INPUT crapopf.dtrefere, 
                                            OUTPUT aux_dtrefsum).
    
                CREATE tt-historico.
                ASSIGN tt-historico.dtrefere = aux_dtrefsum
                       tt-historico.vlvencto = aux_vlvencto
                       tt-historico.dsdbacen = ""
                       tt-historico.dtcomple = crapopf.dtrefere.
            END.
            ELSE
            DO:
                FIND crapces WHERE crapces.nrcpfcgc  = par_nrcpfcgc AND
                                   crapces.dtrefere  = aux_dtmesfim
                                   NO-LOCK NO-ERROR.
                
                IF  AVAIL(crapces) THEN
                    DO:
                        ASSIGN aux_vlvencto = 0
                               aux_dtrefsum = "".

                        RUN verifica_data_historico(INPUT crapces.dtrefere, 
                                                    OUTPUT aux_dtrefsum).
            
                        CREATE tt-historico.
                        ASSIGN tt-historico.dtrefere = aux_dtrefsum
                               tt-historico.vlvencto = aux_vlvencto
                               tt-historico.dsdbacen = ""
                               tt-historico.dtcomple = crapces.dtrefere.
                    END.
                ELSE
                    DO:
                        RUN verifica_data_historico(INPUT aux_dtmesfim, 
                                                    OUTPUT aux_dtrefsum).
    
                        CREATE tt-historico.
                        ASSIGN tt-historico.dtrefere = aux_dtrefsum
                               tt-historico.vlvencto = 0
                               tt-historico.dsdbacen = "Informacoes do BACEN " +
                                                       "nao estao disponiveis"
                               tt-historico.dtcomple = aux_dtmesfim.
                    END.

            END.

            IF aux_dtmesref = 1 THEN
                ASSIGN aux_dtmesref = 12
                       aux_dtanoref = aux_dtanoref - 1.  
            ELSE
                ASSIGN aux_dtmesref = aux_dtmesref - 1.
        END.

        LEAVE Busca.

    END. /* Busca */

    RETURN "OK".

END PROCEDURE. /* Busca_Historico */


/* ------------------------------------------------------------------------ */
/*        CONSULTAR AS MODALIDADES DA CENTRAL DE RISCO DO COOPERADO.        */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Modalidade:

     DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
     DEF OUTPUT PARAM par_msgretor AS CHAR                           NO-UNDO.
     DEF OUTPUT PARAM TABLE FOR tt-modalidade.                       
     DEF OUTPUT PARAM TABLE FOR tt-erro.

     DEF VAR aux_reganter AS CHAR FORMAT "x(02)"                     NO-UNDO.
     DEF VAR par_dtrefere AS CHAR                                    NO-UNDO.
     DEF VAR aux_dtrefere AS DATE                                    NO-UNDO.
 
     EMPTY TEMP-TABLE tt-modalidade.
     EMPTY TEMP-TABLE tt-erro.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:

        /** Necessario verificar data base novamente no caso do usuario 
            consultar mais contas ou cpf's sem sair do browser **/
        RUN verifica_data_base ( OUTPUT aux_dtrefere, OUTPUT par_dtrefere ).
        
        FIND LAST crapopf 
            WHERE crapopf.nrcpfcgc  = par_nrcpfcgc   
              AND crapopf.dtrefere >= aux_dtrefere NO-LOCK NO-ERROR. 
        IF AVAIL crapopf THEN
        DO: 
            ASSIGN aux_reganter = "".

            FOR EACH crapvop NO-LOCK
               WHERE crapvop.nrcpfcgc  = par_nrcpfcgc  
                 AND crapvop.dtrefere >= aux_dtrefere:

                IF NOT aux_reganter = SUBSTR(crapvop.cdmodali,1,2) THEN
                DO:
                    CREATE tt-modalidade.
                    ASSIGN tt-modalidade.cdmodali = 
                            SUBSTR(crapvop.cdmodali,1,2)
                           tt-modalidade.vlvencto = 
                            tt-modalidade.vlvencto + crapvop.vlvencto.

                    FOR LAST gnmodal FIELDS(dsmodali) NO-LOCK
                       WHERE gnmodal.cdmodali = SUBSTR(crapvop.cdmodali,1,2):
                        tt-modalidade.dsmodali = gnmodal.dsmodali.
                    END.
                END.
                ELSE
                    ASSIGN tt-modalidade.vlvencto = 
                        tt-modalidade.vlvencto + crapvop.vlvencto.

                ASSIGN aux_reganter = SUBSTR(crapvop.cdmodali,1,2).
            END.

        END.
        ELSE      
            DO:
                FIND crapces WHERE crapces.nrcpfcgc  = par_nrcpfcgc AND
                                   crapces.dtrefere  = aux_dtrefere
                                   NO-LOCK NO-ERROR.
              
                IF NOT AVAIL(crapces) THEN 
                   ASSIGN par_msgretor = "Informacoes do BACEN deste CPF/CNPJ" +
                                         " nao estao disponiveis.".
            END.

        LEAVE Busca.

    END. /* Busca */

    RETURN "OK".

END PROCEDURE. /* Busca_Modalidade */


/* ------------------------------------------------------------------------ */
/*   CONSULTAR OS DETALHES DA MODALIDADES DA CENTRAL DE RISCO DO COOPERADO. */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Modalidade_Detalhe:

     DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
     DEF  INPUT PARAM par_cdmodali AS CHAR                           NO-UNDO.

     DEF OUTPUT PARAM aux_cdmodali AS CHAR                           NO-UNDO.
     DEF OUTPUT PARAM aux_dsmodali AS CHAR                           NO-UNDO.

     DEF OUTPUT PARAM TABLE FOR tt-detmodal.                       
     DEF OUTPUT PARAM TABLE FOR tt-erro.

     DEF VAR par_dtrefere AS CHAR                                    NO-UNDO.
     DEF VAR aux_dtrefere AS DATE                                    NO-UNDO.

     EMPTY TEMP-TABLE tt-detmodal.
     EMPTY TEMP-TABLE tt-erro.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:

        RUN verifica_data_base ( OUTPUT aux_dtrefere, OUTPUT par_dtrefere ).
        
        FOR  LAST gnmodal FIELDS(cdmodali dsmodali) NO-LOCK
             WHERE gnmodal.cdmodali = SUBSTR(par_cdmodali,1,2):
             ASSIGN aux_cdmodali    = gnmodal.cdmodali
                    aux_dsmodali    = gnmodal.dsmodali.
        END.

        FOR  EACH crapvop NO-LOCK
             WHERE crapvop.nrcpfcgc             = par_nrcpfcgc  
             AND crapvop.dtrefere               >= aux_dtrefere
             AND SUBSTR(crapvop.cdmodali,1,2)   = par_cdmodali
             BREAK BY crapvop.cdmodali:

             IF FIRST-OF(crapvop.cdmodali) THEN
             DO:
                 CREATE tt-detmodal.
                 ASSIGN tt-detmodal.cdmodali = crapvop.cdmodali 
                        tt-detmodal.vlvencto = crapvop.vlvencto.
           
                 FOR  FIRST gnsbmod NO-LOCK
                      WHERE gnsbmod.cdmodali = SUBSTR(crapvop.cdmodali,1,2)
                      AND gnsbmod.cdsubmod = SUBSTR(crapvop.cdmodali,3,2):
                         ASSIGN tt-detmodal.dssubmod = gnsbmod.dssubmod.
                 END.
             END.
             ELSE
                 tt-detmodal.vlvencto = tt-detmodal.vlvencto + crapvop.vlvencto.
        END.

        LEAVE Busca.

    END. /* Busca */

    RETURN "OK".

END PROCEDURE. /* Busca_Modalidade_Detalhe */



/* ------------------------------------------------------------------------ */
/* CONSULTAR OS VENCIMENTOS DA MODALIDADES DA CENTRAL DE RISCO DO COOPERADO.*/
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Modalidade_Vencimento:

     DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
     DEF  INPUT PARAM par_cdmodali AS CHAR                           NO-UNDO.
     
     DEF OUTPUT PARAM aux_cdmodali LIKE crapvop.cdmodali             NO-UNDO. 
     DEF OUTPUT PARAM aux_dsmodali AS CHAR                           NO-UNDO.
     DEF OUTPUT PARAM aux_msgretor AS CHAR                           NO-UNDO.

     DEF OUTPUT PARAM TABLE FOR tt-fluxo.                       
     DEF OUTPUT PARAM TABLE FOR tt-erro.

     DEF VAR par_dtrefere AS CHAR                                    NO-UNDO.
     DEF VAR aux_dtrefere AS DATE                                    NO-UNDO.

     EMPTY TEMP-TABLE tt-fluxo.
     EMPTY TEMP-TABLE tt-erro.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        
        ASSIGN aux_cdmodali = ""
               aux_dsmodali = "". 

        RUN inicializa_fluxo( OUTPUT TABLE tt-fluxo ).

        /** Necessario verificar data base novamente no caso do usuario 
            consultar mais contas ou cpf's sem sair do browser **/
        RUN verifica_data_base ( OUTPUT aux_dtrefere, OUTPUT par_dtrefere ).
        
        FIND LAST crapopf NO-LOCK
            WHERE crapopf.nrcpfcgc             = par_nrcpfcgc   
              AND crapopf.dtrefere            >= aux_dtrefere NO-ERROR.           
        IF AVAIL crapopf THEN
        DO:
            IF LENGTH(par_cdmodali) = 2 THEN
            DO:
                FOR  EACH crapvop NO-LOCK
                     WHERE crapvop.nrcpfcgc           = crapopf.nrcpfcgc 
                     AND crapvop.dtrefere             = crapopf.dtrefere
                     AND SUBSTR(crapvop.cdmodali,1,2) = par_cdmodali:
                    
                        IF  aux_cdmodali = "" THEN
                            DO:
                                ASSIGN aux_cdmodali = par_cdmodali.
        
                                FOR  LAST gnmodal FIELDS(dsmodali) NO-LOCK
                                     WHERE gnmodal.cdmodali = 
                                     SUBSTR(crapvop.cdmodali,1,2):
                                     ASSIGN aux_dsmodali = gnmodal.dsmodali.
                                END.
                            END.

                        FIND FIRST tt-fluxo
                            WHERE tt-fluxo.cdvencto = crapvop.cdvencto NO-ERROR.
    
                        ASSIGN tt-fluxo.cdvencto = crapvop.cdvencto
                               tt-fluxo.vlvencto = 
                                tt-fluxo.vlvencto + crapvop.vlvencto.
                    
                END.
            END.
            ELSE
            DO:
                FOR  EACH crapvop NO-LOCK
                     WHERE crapvop.nrcpfcgc = crapopf.nrcpfcgc 
                     AND crapvop.dtrefere   = crapopf.dtrefere
                     AND crapvop.cdmodali   = par_cdmodali:
                    
                        IF  aux_cdmodali = "" THEN
                            DO:
                                ASSIGN aux_cdmodali = par_cdmodali.
    
                            FOR  FIRST gnsbmod FIELDS(dssubmod) NO-LOCK
                                 WHERE gnsbmod.cdmodali = 
                                    SUBSTR(crapvop.cdmodali,1,2)
                                 AND gnsbmod.cdsubmod   = 
                                    SUBSTR(crapvop.cdmodali,3,2):
                                     ASSIGN aux_dsmodali = gnsbmod.dssubmod.
                                END.
                            END.

                        FIND FIRST tt-fluxo
                            WHERE tt-fluxo.cdvencto = crapvop.cdvencto NO-ERROR.
    
                        ASSIGN tt-fluxo.cdvencto = crapvop.cdvencto
                               tt-fluxo.vlvencto = 
                                tt-fluxo.vlvencto + crapvop.vlvencto.

                    
                END.
            END.
            
            ASSIGN aux_dtrefere = crapopf.dtrefere.       
            
        END. /** Fim avail crapopf **/
        ELSE      
            DO:
                FIND crapces WHERE crapces.nrcpfcgc  = par_nrcpfcgc AND
                                   crapces.dtrefere  = aux_dtrefere
                                   NO-LOCK NO-ERROR.
               
                IF NOT AVAIL(crapces) THEN
                   ASSIGN aux_msgretor = "Informacoes do BACEN deste CPF/CNPJ" + 
                                         " nao estao disponiveis.".
            END.
        
        LEAVE Busca.

    END. /* Busca */

    RETURN "OK".

END PROCEDURE. /* Busca_Modalidade_Vencimento */

/*........................... PROCEDURE INTERNAS ...........................*/
/* ------------------------------------------------------------------------ */
/*                            VERIFICA A DATA BASE                          */
/* ------------------------------------------------------------------------ */
PROCEDURE verifica_data_base:
    
    DEF  OUTPUT PARAM aux_dtrefere AS DATE                            NO-UNDO.
    DEF  OUTPUT PARAM par_dtrefere AS CHAR                            NO-UNDO.

    DEF VAR aux_data AS DATE    NO-UNDO.

    ASSIGN aux_data =  ADD-INTERVAL (TODAY, -1, "MONTH").

    DO WHILE TRUE:

        /** Tabela crapopf nao possui cdcooper **/
       FIND LAST crapopf WHERE crapopf.dtrefere >= aux_data 
           USE-INDEX crapopf2 NO-LOCK NO-ERROR.
       
       IF   AVAIL crapopf   THEN DO:
            ASSIGN aux_dtrefere = crapopf.dtrefere.
            LEAVE.
       END.
       ELSE
            ASSIGN aux_data =  ADD-INTERVAL (aux_data, -1, "MONTH").

    END.
/*
    /** Tabela crapopf nao possui cdcooper **/
    FIND LAST crapopf WHERE crapopf.dtrefere >= aux_data 
        USE-INDEX crapopf2 NO-LOCK NO-ERROR.

    IF  AVAIL crapopf THEN
        ASSIGN aux_dtrefere = crapopf.dtrefere.                
*/           
    CASE (MONTH(aux_dtrefere)):    
        WHEN 1 THEN         
            ASSIGN par_dtrefere = "Jan/"+ STRING(YEAR(aux_dtrefere)).           
        WHEN 2 THEN         
            ASSIGN par_dtrefere = "Fev/"+ STRING(YEAR(aux_dtrefere)).          
        WHEN 3 THEN         
            ASSIGN par_dtrefere = "Mar/"+ STRING(YEAR(aux_dtrefere)).          
        WHEN 4 THEN         
            ASSIGN par_dtrefere = "Abr/"+ STRING(YEAR(aux_dtrefere)).        
        WHEN 5 THEN         
            ASSIGN par_dtrefere = "Mai/"+ STRING(YEAR(aux_dtrefere)).       
        WHEN 6 THEN         
            ASSIGN par_dtrefere = "Jun/"+ STRING(YEAR(aux_dtrefere)).        
        WHEN 7 THEN         
            ASSIGN par_dtrefere = "Jul/"+ STRING(YEAR(aux_dtrefere)).
        WHEN 8 THEN         
            ASSIGN par_dtrefere = "Ago/"+ STRING(YEAR(aux_dtrefere)).    
        WHEN 9 THEN         
            ASSIGN par_dtrefere = "Set/"+ STRING(YEAR(aux_dtrefere)).    
        WHEN 10 THEN         
            ASSIGN par_dtrefere = "Out/"+ STRING(YEAR(aux_dtrefere)).    
        WHEN 11 THEN         
            ASSIGN par_dtrefere = "Nov/"+ STRING(YEAR(aux_dtrefere)).          
        WHEN 12 THEN         
            ASSIGN par_dtrefere = "Dez/"+ STRING(YEAR(aux_dtrefere)).    
    END CASE.    
    
END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                         VERIFICA A DATA HISTORICO                        */
/* ------------------------------------------------------------------------ */
PROCEDURE verifica_data_historico:   

    DEF  INPUT PARAM par_dtrefere LIKE crapopf.dtrefere              NO-UNDO. 
    DEF OUTPUT PARAM aux_dtrefsum AS CHAR FORMAT "x(08)"             NO-UNDO.

    CASE (MONTH(par_dtrefere)):    
        WHEN 1 THEN         
            ASSIGN aux_dtrefsum = "Jan/"+ STRING(YEAR(par_dtrefere)).           
        WHEN 2 THEN         
            ASSIGN aux_dtrefsum = "Fev/"+ STRING(YEAR(par_dtrefere)).          
        WHEN 3 THEN         
            ASSIGN aux_dtrefsum = "Mar/"+ STRING(YEAR(par_dtrefere)).          
        WHEN 4 THEN         
            ASSIGN aux_dtrefsum = "Abr/"+ STRING(YEAR(par_dtrefere)).        
        WHEN 5 THEN         
            ASSIGN aux_dtrefsum = "Mai/"+ STRING(YEAR(par_dtrefere)).       
        WHEN 6 THEN         
            ASSIGN aux_dtrefsum = "Jun/"+ STRING(YEAR(par_dtrefere)).        
        WHEN 7 THEN         
            ASSIGN aux_dtrefsum = "Jul/"+ STRING(YEAR(par_dtrefere)).
        WHEN 8 THEN         
            ASSIGN aux_dtrefsum = "Ago/"+ STRING(YEAR(par_dtrefere)).    
        WHEN 9 THEN         
            ASSIGN aux_dtrefsum = "Set/"+ STRING(YEAR(par_dtrefere)).    
        WHEN 10 THEN         
            ASSIGN aux_dtrefsum = "Out/"+ STRING(YEAR(par_dtrefere)).    
        WHEN 11 THEN         
            ASSIGN aux_dtrefsum = "Nov/"+ STRING(YEAR(par_dtrefere)).          
        WHEN 12 THEN         
            ASSIGN aux_dtrefsum = "Dez/"+ STRING(YEAR(par_dtrefere)).    
    END CASE.    
    
END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                       GERA O LOG PARA TELA LOGTEL                        */
/* ------------------------------------------------------------------------ */
PROCEDURE gera_log:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.

    FOR FIRST crapcop WHERE 
              crapcop.cdcooper = par_cdcooper NO-LOCK: END.

    IF  par_cddopcao = "C" THEN
        DO:
             UNIX SILENT VALUE("echo " +    STRING(par_dtmvtolt,"99/99/9999") + 
                               " - " + STRING(TIME,"HH:MM:SS") +
                               " - CONSULTA ' --> '"  +
                               " Operador: " + par_cdoperad +
                               " consultou CPF_CNPJ: " +
                               STRING(par_nrcpfcgc, "zzzzzzzzzzzzzz9") +
                               " Conta: " + 
                               STRING(par_nrdconta, "zzzz,zz9,9") +
                               " >> /usr/coop/" + 
                               TRIM(crapcop.dsdircop) + 
                               "/log/conscr.log").
        END.
    ELSE 
        IF  par_cddopcao = "R" THEN
            DO:
                IF  par_cdagenci = 0  THEN
                    UNIX SILENT VALUE("echo " +  
                               STRING(par_dtmvtolt,"99/99/9999") + 
                               " - " + STRING(TIME,"HH:MM:SS") +
                               " - IMPRESSAO ' --> '"  +
                               " Operador: " + par_cdoperad +
                               " imprimiu CPF_CNPJ: " +
                               STRING(par_nrcpfcgc, "zzzzzzzzzzzzzz9") +
                               " Conta: " + 
                               STRING(par_nrdconta, "zzzz,zz9,9") +
                               " >> /usr/coop/" + 
                               TRIM(crapcop.dsdircop) + 
                               "/log/conscr.log").
                ELSE
                    UNIX SILENT VALUE("echo " +    
                               STRING(par_dtmvtolt,"99/99/9999") + 
                               " - " + STRING(TIME,"HH:MM:SS") +
                               " - IMPRESSAO ' --> '"  +
                               " Operador: " + par_cdoperad +
                               " imprimiu PA: " +
                               STRING(par_cdagenci, "zz9") +
                               " Cooperativa: " + 
                               STRING(par_cdcooper, "zz9") +
                               " >> /usr/coop/" + 
                               TRIM(crapcop.dsdircop) + 
                               "/log/conscr.log").
            END.

END PROCEDURE.


PROCEDURE inicializa_fluxo:

    DEF OUTPUT PARAM TABLE FOR tt-fluxo.                       

    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 110
           tt-fluxo.dsvencto = "Ate 30 dias"                        
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 1.                                   
    
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 120
           tt-fluxo.dsvencto = "de 31 a 60 dias"                    
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 2.                                   
                                                            
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 130
           tt-fluxo.dsvencto = "de 61 a 90 dias"                    
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 3.                                   
                                                            
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 140
           tt-fluxo.dsvencto = "de 91 a 180 dias"                   
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 4.                                   
                                                            
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 150
           tt-fluxo.dsvencto = "de 181 a 360 dias"                  
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 5.                                   
                                                            
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 160
           tt-fluxo.dsvencto = "de 361 a 720 dias"                  
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 6.                                   
                                                            
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 165
           tt-fluxo.dsvencto = "de 721 a 1080 dias"                 
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 7.                                   
                                                            
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 170
           tt-fluxo.dsvencto = "de 1081 a 1440 dias"                
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 8.                                   
                                                            
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 175
           tt-fluxo.dsvencto = "de 1441 a 1800 dias"                
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 9.                                   
                                                            
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 180
           tt-fluxo.dsvencto = "de 1801 a 5400 dias"                
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 10.                                  
                                                            
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 190
           tt-fluxo.dsvencto = "acima de 5400 dias"                 
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 11.                                  
                                                            
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 199
           tt-fluxo.dsvencto = "com prazo indeterm."                
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 12.                                  
    /*aqui tiago*/  
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 20
           tt-fluxo.dsvencto = "Vencim. ate 360 dias "                
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 13.

    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 40
           tt-fluxo.dsvencto = "Vencim. acima 360 d  "                
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 14.

    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 60
           tt-fluxo.dsvencto = "Cred a Lib ate 360 d "                
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 15.

    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 80
           tt-fluxo.dsvencto = "Cred a Lib acima 360 "                
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 16.

    /*tiago*/
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 205
           tt-fluxo.dsvencto = "de 1 a 14 dias"                     
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 17.                                  
                                                            
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 210
           tt-fluxo.dsvencto = "de 15 a 30 dias"                    
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 18.                                  
                                                            
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 220
           tt-fluxo.dsvencto = "de 31 a 60 dias"                    
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 19.                                  
                                                            
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 230
           tt-fluxo.dsvencto = "de 61 a 90 dias"                    
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 20.                                  
                                                            
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 240
           tt-fluxo.dsvencto = "de 91 a 120 dias"                   
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 21.                                  
                                                            
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 245
           tt-fluxo.dsvencto = "de 121 a 150 dias"                  
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 22.                                  
                                                            
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 250
           tt-fluxo.dsvencto = "de 151 a 180 dias"                  
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 23.                                  
                                                            
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 255
           tt-fluxo.dsvencto = "de 181 a 240 dias"                  
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 24.                                  
                                                            
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 260
           tt-fluxo.dsvencto = "de 241 a 300 dias"                  
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 25.                                  
                                                            
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 270
           tt-fluxo.dsvencto = "de 301 a 360 dias"                  
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 26.                                  
                                                            
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 280
           tt-fluxo.dsvencto = "de 361 a 540 dias"                  
           tt-fluxo.vlvencto = 0
           tt-fluxo.elemento = 27.                                  
                                                            
    CREATE tt-fluxo.
    ASSIGN tt-fluxo.cdvencto = 290
           tt-fluxo.dsvencto = "acima de 540 dias"                  
           tt-fluxo.vlvencto = 0 
           tt-fluxo.elemento = 28.                                  

  
END PROCEDURE.


