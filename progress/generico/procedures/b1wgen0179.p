/*.............................................................................
    Programa: sistema/generico/procedures/b1wgen0179.p
    Autor   : Jéssica Laverde Gracino (DB1)
    Data    : 27/09/2013                     Ultima atualizacao: 06/02/2017

    Objetivo  : Tranformacao BO tela HISTOR.

    Alteracoes: 11/03/2016 - Homologacao e ajustes da conversao da tela 
                             HISTOR para WEB (Douglas - Chamado 412552)
        
		        06/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                             departamento passando a considerar o código (Renato Darosci)

                06/02/2017 - #552068 Inclusao da descricao extensa do historico
                             na rotina Busca_Consulta (Carlos)
                             
                05/12/2017 - Melhoria 458 adicionado campo inmonpld - Antonio R. Jr (Mouts)
        
............................................................................*/

/*............................. DEFINICOES .................................*/
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0179tt.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.

DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_nrregist AS INTE                                        NO-UNDO.
DEF VAR aux_contador AS INTE                                        NO-UNDO.

DEF VAR aux_nmendter AS CHAR                                        NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.

DEF BUFFER b-craphis FOR craphis. 

/*................................ PROCEDURES ..............................*/

/* -------------------------------------------------------------------------- */
/*                  EFETUA A PESQUISA DE HISTORICOS NO SISTEMA                */
/* -------------------------------------------------------------------------- */

PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dshistor AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpltmvpq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdhinovo AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdgrphis AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-histor.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    /* Valores das tarifas*/
    DEF  VAR aux_vltarayl AS DECI FORMAT "zzz,zzz,zz9.99"           NO-UNDO.
    DEF  VAR aux_vltarint AS DECI FORMAT "zzz,zzz,zz9.99"           NO-UNDO.
    DEF  VAR aux_vltarcxo AS DECI FORMAT "zzz,zzz,zz9.99"           NO-UNDO.
    DEF  VAR aux_vltarcsh AS DECI FORMAT "zzz,zzz,zz9.99"           NO-UNDO.
    /* CPMF */
    DEF  VAR aux_dtinipmf AS DATE                                   NO-UNDO.
    DEF  VAR aux_dtfimpmf AS DATE                                   NO-UNDO.
    DEF  VAR aux_txcpmfcc AS DECIMAL                                NO-UNDO.
    DEF  VAR aux_txrdcpmf AS DECIMAL                                NO-UNDO.
    DEF  VAR aux_indabono AS INTE                                   NO-UNDO.
    DEF  VAR aux_dtiniabo AS DATE                                   NO-UNDO.
        
        
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "OK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Dados Historicos Do Sistema".              

    EMPTY TEMP-TABLE tt-histor.
    EMPTY TEMP-TABLE tt-erro.
    
    IF  NOT CAN-DO("A,B,C,I,O,X",par_cddopcao) THEN
        DO:
            ASSIGN aux_cdcritic = 014
                   aux_dscritic = "".
               
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
        
    IF par_cddopcao <> "B"   AND
       par_cddopcao <> "O"   AND
       par_cddopcao <> "C"   THEN
        IF par_cddepart = 20    OR   /* TI */
           par_cddepart = 6     OR   /* CONTABILIDADE */
           par_cddepart = 8   THEN   /* COORD.ADM/FINANCEIRO */
            .
        ELSE
        IF par_cdcooper <> 3   THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Opcao permitida apenas para a CECRED.".
                   
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.

    RUN carrega_cpmf (INPUT par_cdcooper,           
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_dtmvtolt,
                     OUTPUT aux_dtinipmf,
                     OUTPUT aux_dtfimpmf,
                     OUTPUT aux_txcpmfcc,
                     OUTPUT aux_txrdcpmf,
                     OUTPUT aux_indabono,
                     OUTPUT aux_dtiniabo,
                     OUTPUT TABLE tt-erro).

    IF RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    IF  par_cddopcao = "A" OR par_cddopcao = "I" OR par_cddopcao = "X" THEN DO:

        /* Validar se o Codigo Novo nao existe (apenas cddopcao = "I") */
        IF par_cddopcao = "I"  THEN
            DO:
                FIND FIRST craphis WHERE craphis.cdcooper = par_cdcooper 
                                     AND craphis.cdhistor = par_cdhinovo 
                                   NO-LOCK NO-ERROR.
    
                IF AVAILABLE craphis THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Codigo do Novo Historico ja esta em uso. " +
                                              STRING(craphis.cdhistor) + " - " + 
                                              craphis.dsexthst
                               par_nmdcampo = "cdhinovo".
    
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.
            END.

        /* Para as opcoes Incluir, Alterar e Replicar 
           deve carregar os dados do historico informado */
        RUN Busca_Historico
            ( INPUT par_cdcooper,
              INPUT par_cdagenci,
              INPUT par_nrdcaixa,
              INPUT par_cdhistor,
              INPUT aux_txcpmfcc,
             OUTPUT par_nmdcampo,
             OUTPUT TABLE tt-histor,
             OUTPUT TABLE tt-erro).

        IF RETURN-VALUE <> "OK" THEN
            RETURN "NOK".

        /* Gerar o Log da Busca */
        RUN gera_logtel (INPUT par_cdcooper,
                         INPUT par_cdoperad,
                         INPUT "Buscou os dados do historico " +
                               STRING(par_cdhistor)).

    END. /* Fim opcao A/I/X */
    ELSE IF par_cddopcao = "C" THEN DO:
        
        /* Consultar todos os historicos dos filtros informados */
        RUN Busca_Consulta
            ( INPUT par_cdcooper,           
              INPUT par_cdhistor,
              INPUT par_dshistor,
              INPUT par_tpltmvpq,
              INPUT par_cdgrphis,
              INPUT par_nrregist,
              INPUT par_nriniseq,
              INPUT aux_txcpmfcc,
             OUTPUT par_qtregist,
             OUTPUT TABLE tt-histor).

        IF  par_flgerlog THEN
        DO:
            /* Gerar o Log da Busca */
            RUN gera_logtel (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "Buscou os historicos do sistema." ).
        END.
    END.

    ELSE IF par_cddopcao = "B" THEN DO:
        /* Buscar os dados dos historicos utilizados no boletim de caixa */
        RUN Busca_Boletim
            ( INPUT par_cdcooper,
              INPUT par_nrregist,
              INPUT par_nriniseq,
             OUTPUT par_qtregist,
             OUTPUT TABLE tt-histor).

        IF  par_flgerlog THEN
        DO:
            /* Gerar o Log da Busca */
            RUN gera_logtel (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "Buscou os historicos aceitos na rotina 11 " +
                                   "- Boletim de Caixa do caixa on-line." ).
        END.
    END.

    ELSE IF par_cddopcao = "O" THEN DO:
        /* Buscar os dados dos historicos utilizados na tela outros */
        RUN Busca_Outros
            ( INPUT par_cdcooper,
              INPUT par_nrregist,
              INPUT par_nriniseq,
             OUTPUT par_qtregist,
             OUTPUT TABLE tt-histor).

        IF  par_flgerlog THEN
        DO:
            /* Gerar o Log da Busca */
            RUN gera_logtel (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "Buscou os historicos aceitos na rotina 56 " +
                                   "- Inclusao Outros do caixa on-line." ).
        END.
    END.

    RETURN "OK".

END PROCEDURE. /* Busca_Dados */


/* -------------------------------------------------------------------------- */
/*                 EFETUA A CONSULTA DE HISTORICOS NO SISTEMA                 */
/* -------------------------------------------------------------------------- */
PROCEDURE Busca_Consulta PRIVATE:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dshistor AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpltmvpq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdgrphis AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_txcpmfcc AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-histor.

    DEF VAR aux_flpagina AS LOGI                                    NO-UNDO.
    DEF VAR aux_nrseqatu AS INTE                                    NO-UNDO.
    DEF VAR aux_nrseqini AS INTE                                    NO-UNDO.
    DEF VAR aux_nrseqfim AS INTE                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-histor.

    ASSIGN aux_nrseqatu = 0
           aux_nrseqini = par_nriniseq
           aux_nrseqfim = par_nriniseq + par_nrregist
           aux_flpagina = IF par_nrregist > 0 THEN
                              TRUE
                          ELSE
                              FALSE.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:

        FOR EACH craphis WHERE   craphis.cdcooper = par_cdcooper                          
                           AND ((craphis.cdhistor = par_cdhistor    AND
                                 par_cdhistor <> 0) OR par_cdhistor = 0)
                           AND ((craphis.tplotmov = par_tpltmvpq    AND
                                 par_tpltmvpq <> 0) OR par_tpltmvpq = 0)
                           AND  (craphis.dshistor MATCHES "*" + TRIM(par_dshistor) + "*" OR
						         craphis.dsexthst MATCHES "*" + TRIM(par_dshistor) + "*" )
                           AND ((craphis.cdgrphis = par_cdgrphis    AND
                                 par_cdgrphis <> 0) OR par_cdgrphis = 0)
                         NO-LOCK
                         BY craphis.cdhistor:
            
            ASSIGN aux_nrseqatu = aux_nrseqatu + 1.

            /* Verificar se vamos paginar os registros */
            IF aux_flpagina THEN
                DO:
                    IF aux_nrseqatu < aux_nrseqini  OR
                       aux_nrseqatu >= aux_nrseqfim THEN
                        DO:
                            NEXT.
                        END.
                END.

            CREATE tt-histor.
            ASSIGN tt-histor.cdhistor = craphis.cdhistor
                   tt-histor.dshistor = craphis.dshistor
				   tt-histor.dsexthst = craphis.dsexthst
                   tt-histor.indebcre = craphis.indebcre
                   tt-histor.tplotmov = craphis.tplotmov
                   tt-histor.txcpmfcc = par_txcpmfcc
                   tt-histor.inavisar = craphis.inavisar
                   tt-histor.nrctadeb = craphis.nrctadeb
                   tt-histor.nrctacrd = craphis.nrctacrd.
        END.

        ASSIGN par_qtregist = aux_nrseqatu.

        LEAVE Busca.

    END. /* Busca */
    
    RETURN "OK".

END PROCEDURE. /* Busca_Consulta */

/* -------------------------------------------------------------------------- */
/*                        LISTA HISTORICOS DA ROTINA 56                       */
/* -------------------------------------------------------------------------- */
PROCEDURE Busca_Boletim PRIVATE:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-histor.

    DEF VAR aux_flpagina AS LOGI                                    NO-UNDO.
    DEF VAR aux_nrseqatu AS INTE                                    NO-UNDO.
    DEF VAR aux_nrseqini AS INTE                                    NO-UNDO.
    DEF VAR aux_nrseqfim AS INTE                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-histor.

    ASSIGN aux_nrseqatu = 0
           aux_nrseqini = par_nriniseq
           aux_nrseqfim = par_nriniseq + par_nrregist
           aux_flpagina = IF par_nrregist > 0 THEN
                              TRUE
                          ELSE
                              FALSE.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        
        FOR EACH craphis WHERE craphis.cdcooper = par_cdcooper 
                           AND craphis.cdhistor > 700 
                           AND craphis.cdhistor < 800 
                           AND craphis.tplotmov = 22 
                         NO-LOCK 
                         BY craphis.indebcre
                         BY craphis.cdhistor:

            ASSIGN aux_nrseqatu = aux_nrseqatu + 1.

            /* Verificar se vamos paginar os registros */
            IF aux_flpagina THEN
                DO:
                    IF aux_nrseqatu < aux_nrseqini  OR
                       aux_nrseqatu >= aux_nrseqfim THEN
                        DO:
                            NEXT.
                        END.
                END.

            CREATE tt-histor.
            ASSIGN tt-histor.cdhistor = craphis.cdhistor
                   tt-histor.dshistor = craphis.dshistor
                   tt-histor.indebcre = craphis.indebcre
                   tt-histor.tplotmov = craphis.tplotmov
                   tt-histor.inavisar = craphis.inavisar
                   tt-histor.nrctadeb = craphis.nrctadeb
                   tt-histor.nrctacrd = craphis.nrctacrd.            

        END.

        ASSIGN par_qtregist = aux_nrseqatu.

        LEAVE Busca.

    END. /* Busca */

    RETURN "OK".

END PROCEDURE. /* Busca_Boletim */

/* -------------------------------------------------------------------------- */
/*                             LISTA HISTORICOS                               */
/* -------------------------------------------------------------------------- */
PROCEDURE Busca_Outros PRIVATE:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-histor.

    DEF VAR aux_flpagina AS LOGI                                    NO-UNDO.
    DEF VAR aux_nrseqatu AS INTE                                    NO-UNDO.
    DEF VAR aux_nrseqini AS INTE                                    NO-UNDO.
    DEF VAR aux_nrseqfim AS INTE                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-histor.

    ASSIGN aux_nrseqatu = 0
           aux_nrseqini = par_nriniseq
           aux_nrseqfim = par_nriniseq + par_nrregist
           aux_flpagina = IF par_nrregist > 0 THEN
                              TRUE
                          ELSE
                              FALSE.
    
        
    /* Crap51 - Depositos com Captura      -> cdhistor = 1, 386, 3, 4 
       Crap52 - Depositos sem Captura      -> cdhistor = 403, 404
       Crap53 - Pagto de Cheque            -> cdhistor = 21, 26
       Crap54 - Cheque Avulso              -> cdhistor = 22 
       Crap54 - Cheque Avulso (Cartao Mag) -> cdhistor = 1030
       Crap55 - Cheque Liberado            -> cdhistor = 372 */

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        
        FOR EACH craphis WHERE craphis.cdcooper = par_cdcooper 
                           AND craphis.tplotmov = 1 
                           AND (craphis.tpctbcxa = 2 OR
                                craphis.tpctbcxa = 3)
                           AND NOT CAN-DO ("1,386,3,4,403,404,21,26,22,372,1030",
                                           STRING(craphis.cdhistor)) 
                         NO-LOCK
                         BY craphis.indebcre
                         BY craphis.cdhistor: 
            
            ASSIGN aux_nrseqatu = aux_nrseqatu + 1.

            /* Verificar se vamos paginar os registros */
            IF aux_flpagina THEN
                DO:
                    IF aux_nrseqatu < aux_nrseqini  OR
                       aux_nrseqatu >= aux_nrseqfim THEN
                        DO:
                            NEXT.
                        END.
                END.

            CREATE tt-histor.
            ASSIGN tt-histor.cdhistor = craphis.cdhistor
                   tt-histor.dshistor = craphis.dshistor
                   tt-histor.indebcre = craphis.indebcre
                   tt-histor.tplotmov = craphis.tplotmov
                   tt-histor.inavisar = craphis.inavisar
                   tt-histor.nrctadeb = craphis.nrctadeb
                   tt-histor.nrctacrd = craphis.nrctacrd.
        END.

        ASSIGN par_qtregist = aux_nrseqatu.

        LEAVE Busca.

    END. /* Busca */

    RETURN "OK".

END PROCEDURE. /* Busca_Outros */

/* -------------------------------------------------------------------------- */
/*                  EFETUA A CONSULTA DO HISTORICO NO SISTEMA                 */
/* -------------------------------------------------------------------------- */
PROCEDURE Busca_Historico:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_txcpmfcc AS DECI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-histor.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

    DEF VAR aux_dsgrphis AS CHAR                                    NO-UNDO.
    DEF VAR aux_des_erro AS CHAR                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-histor.
    EMPTY TEMP-TABLE tt-erro.

    IF par_cdhistor = 0 THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Codigo do Historico nao pode ser zero."
                   par_nmdcampo = "cdhistor".
                
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
            
    FIND FIRST craphis WHERE craphis.cdcooper = par_cdcooper 
                         AND craphis.cdhistor = par_cdhistor 
                       NO-LOCK NO-ERROR.
                              
    IF NOT AVAILABLE craphis THEN
        DO:
            ASSIGN aux_cdcritic = 526
                   aux_dscritic = ""
                   par_nmdcampo = "cdhistor".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    CREATE tt-histor.
    ASSIGN tt-histor.cdhistor = craphis.cdhistor
           tt-histor.dshistor = craphis.dshistor
           tt-histor.indebcre = craphis.indebcre
           tt-histor.tplotmov = craphis.tplotmov
           tt-histor.txcpmfcc = par_txcpmfcc
           tt-histor.inavisar = craphis.inavisar
           tt-histor.nrctadeb = craphis.nrctadeb
           tt-histor.nrctacrd = craphis.nrctacrd
           tt-histor.cdhstctb = craphis.cdhstctb
           tt-histor.dsexthst = craphis.dsexthst
           tt-histor.inautori = craphis.inautori   
           tt-histor.inclasse = craphis.inclasse   
           tt-histor.incremes = craphis.incremes   
           tt-histor.inmonpld = craphis.inmonpld
           tt-histor.indcompl = craphis.indcompl   
           tt-histor.indebcta = craphis.indebcta   
           tt-histor.indebfol = craphis.indebfol   
           tt-histor.indoipmf = craphis.indoipmf   
           tt-histor.inhistor = craphis.inhistor   
           tt-histor.nmestrut = craphis.nmestrut   
           tt-histor.nrctatrc = craphis.nrctatrc   
           tt-histor.nrctatrd = craphis.nrctatrd   
           tt-histor.tpctbccu = craphis.tpctbccu   
           tt-histor.tpctbcxa = craphis.tpctbcxa   
           tt-histor.txdoipmf = craphis.txdoipmf   
           tt-histor.ingercre = craphis.ingercre   
           tt-histor.ingerdeb = craphis.ingerdeb   
           tt-histor.dsextrat = craphis.dsextrat
           tt-histor.flgsenha = IF craphis.flgsenha THEN
                                    1
                                ELSE
                                    0. 

        IF craphis.cdgrphis > 0 THEN
            DO:
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                /* Procedure para buscar as informacoes da CPMF da cooperativa */
                RUN STORED-PROCEDURE pc_descricao_grupo_historico
                    aux_handproc = PROC-HANDLE NO-ERROR
                                            (INPUT craphis.cdgrphis, /* pr_cdgrupo_historico */
                                             OUTPUT "",  /* pr_dsgrupo_historico */
                                             OUTPUT "",  /* pr_des_erro */
                                             OUTPUT ""). /* pr_dscritic */
                
                CLOSE STORED-PROC pc_descricao_grupo_historico
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                
                ASSIGN aux_dsgrphis = ""
                       aux_des_erro = ""
                       aux_dscritic = ""
                       aux_dsgrphis = pc_descricao_grupo_historico.pr_dsgrupo_historico
                                          WHEN pc_descricao_grupo_historico.pr_dsgrupo_historico <> ?
                       aux_des_erro = pc_descricao_grupo_historico.pr_des_erro
                                          WHEN pc_descricao_grupo_historico.pr_des_erro <> ?
                       aux_dscritic = pc_descricao_grupo_historico.pr_dscritic
                                          WHEN pc_descricao_grupo_historico.pr_dscritic <> ?.
                
                IF aux_des_erro = "NOK" THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               par_nmdcampo = "cdgrupo_historico".
                
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.
            END.
        ASSIGN tt-histor.cdgrphis = craphis.cdgrphis
               tt-histor.dsgrphis = aux_dsgrphis.
            
    FOR EACH crapthi WHERE crapthi.cdcooper = craphis.cdcooper   
                       AND crapthi.cdhistor = craphis.cdhistor   
                     NO-LOCK:
                                                         
        IF   crapthi.dsorigem = "AYLLOS"   THEN                          
             ASSIGN tt-histor.vltarayl = crapthi.vltarifa.                     
        ELSE                                                             
        IF   crapthi.dsorigem = "CAIXA"   THEN          
             ASSIGN tt-histor.vltarcxo = crapthi.vltarifa.           
        ELSE                                           
        IF   crapthi.dsorigem = "INTERNET"   THEN
             ASSIGN tt-histor.vltarint = crapthi.vltarifa.
        ELSE
        IF   crapthi.dsorigem = "CASH"   THEN                
             ASSIGN tt-histor.vltarcsh = crapthi.vltarifa.                
                                                             
    END. 

    FIND crapprd WHERE crapprd.cdprodut = craphis.cdprodut NO-LOCK NO-ERROR.
    IF  AVAIL crapprd THEN
        DO:
            ASSIGN tt-histor.cdprodut = craphis.cdprodut        
                   tt-histor.dsprodut = crapprd.dsprodut.       
        END.

    FIND crapagr WHERE crapagr.cdagrupa = craphis.cdagrupa NO-LOCK NO-ERROR.
    IF  AVAIL crapagr THEN
        DO:
            ASSIGN tt-histor.cdagrupa = craphis.cdagrupa
                   tt-histor.dsagrupa = crapagr.dsagrupa.
        END.

    RETURN "OK".

END PROCEDURE. /* Busca_Historico*/



/* -------------------------------------------------------------------------- */
/*            EFETUA A CONSULTA DE PRODUTOS DO HISTORICO NO SISTEMA           */
/* -------------------------------------------------------------------------- */
PROCEDURE Busca_Produto:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprodut AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsprodut AS CHAR                           NO-UNDO.
   
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-produto.

    DEF VAR aux_nrseqatu AS INTE                                    NO-UNDO.
    DEF VAR aux_nrseqini AS INTE                                    NO-UNDO.
    DEF VAR aux_nrseqfim AS INTE                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-produto.

    ASSIGN aux_nrseqatu = 0
           aux_nrseqini = par_nriniseq
           aux_nrseqfim = par_nriniseq + par_nrregist.
    
    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        
        FOR EACH crapprd WHERE (crapprd.cdprodut = par_cdprodut OR par_cdprodut = 0)
                           AND (crapprd.dsprodut MATCHES "*" + TRIM(par_dsprodut) + "*")
                         NO-LOCK 
                         BY crapprd.cdprodut:
            
            ASSIGN aux_nrseqatu = aux_nrseqatu + 1.

            IF aux_nrseqatu >= aux_nrseqini AND
               aux_nrseqatu < aux_nrseqfim THEN
                DO:
                    CREATE tt-produto.
                    ASSIGN tt-produto.cdprodut = crapprd.cdprodut
                           tt-produto.dsprodut = crapprd.dsprodut.
                END.
        END. 

        ASSIGN par_qtregist = aux_nrseqatu.
        
        LEAVE Busca.

    END. /* Busca */

    RETURN "OK".

END PROCEDURE. /* Busca_Produto */

/* -------------------------------------------------------------------------- */
/*           EFETUA A CONSULTA DE GRUPOS DO HISTORICO NO SISTEMA              */
/* -------------------------------------------------------------------------- */
PROCEDURE Busca_Grupo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagrupa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsagrupa AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-agrupamento.

    DEF VAR aux_nrseqatu AS INTE                                    NO-UNDO.
    DEF VAR aux_nrseqini AS INTE                                    NO-UNDO.
    DEF VAR aux_nrseqfim AS INTE                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-agrupamento.

    ASSIGN aux_nrseqatu = 0
           aux_nrseqini = par_nriniseq
           aux_nrseqfim = par_nriniseq + par_nrregist.
    
    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        
        FOR EACH crapagr WHERE (crapagr.cdagrupa = par_cdagrupa OR par_cdagrupa = 0)
                           AND (crapagr.dsagrupa MATCHES "*" + TRIM(par_dsagrupa) + "*")
                         NO-LOCK 
                         BY crapagr.cdagrupa:
            
            ASSIGN aux_nrseqatu = aux_nrseqatu + 1.

            IF aux_nrseqatu >= aux_nrseqini AND
               aux_nrseqatu < aux_nrseqfim THEN
                DO:
                CREATE tt-agrupamento.
                ASSIGN tt-agrupamento.cdagrupa = crapagr.cdagrupa
                       tt-agrupamento.dsagrupa = crapagr.dsagrupa.
                END.
        END. 

        ASSIGN par_qtregist = aux_nrseqatu.

    END. /* Busca */

    RETURN "OK".

END PROCEDURE. /* Busca_Grupo */

/* -------------------------------------------------------------------------- */
/*                         GRAVA DADOS DO HISTORICO                           */
/* -------------------------------------------------------------------------- */
PROCEDURE Grava_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    
    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdhinovo AS INTE                           NO-UNDO.

    DEF  INPUT PARAM par_cdhstctb AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsexthst AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dshistor AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inautori AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inavisar AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inclasse AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_incremes AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inmonpld AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_indcompl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_indebcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_indoipmf AS INTE                           NO-UNDO.
    
    DEF  INPUT PARAM par_inhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_indebcre AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmestrut AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrctacrd AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctatrc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctadeb AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctatrd AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctbccu AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tplotmov AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctbcxa AS INTE                           NO-UNDO.
    
    DEF  INPUT PARAM par_ingercre AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_ingerdeb AS INTE                           NO-UNDO.
    
    DEF  INPUT PARAM par_cdgrphis AS INTE                           NO-UNDO.
    
    DEF  INPUT PARAM par_flgsenha AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprodut AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagrupa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsextrat AS CHAR                           NO-UNDO.

    DEF  INPUT PARAM par_vltarayl AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vltarcxo AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vltarint AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vltarcsh AS DECI                           NO-UNDO.

    DEF  INPUT PARAM par_indebfol AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_txdoipmf AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    /* Valores das tarifas */ 
    DEF  VAR aux_vltarayl AS DECI                                   NO-UNDO.
    DEF  VAR aux_vltarcxo AS DECI                                   NO-UNDO.
    DEF  VAR aux_vltarint AS DECI                                   NO-UNDO.
    DEF  VAR aux_vltarcsh AS DECI                                   NO-UNDO.
    DEF  VAR aux_flgsenha AS LOGI                                   NO-UNDO.
    DEF  VAR aux_flggphis AS CHAR                                   NO-UNDO.
    DEF  VAR aux_des_erro AS CHAR                                   NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Grava Manutencao de Historicos"
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        IF par_cdhistor = 0 THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Codigo do historico invalido."
                       par_nmdcampo = "cdhistor".
                LEAVE Grava.
            END.


        IF par_dshistor = "" THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Nome do historico invalido."
                       par_nmdcampo = "dshistor".
                LEAVE Grava.
            END.

        IF NOT CAN-DO("C,D",par_indebcre) THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Debito/Credito invalido."
                       par_nmdcampo = "indebcre".
                LEAVE Grava.
            END.

        IF NOT CAN-DO("000,001,002,003,004,005,006,"+
                      "007,008,009,010,011,012,013,"+
                      "014,015,016,017,018,019,020,"+
                      "021,022,023,024,025,028,029, "+
                      "030,031,032,122,124,125",
                      STRING(par_tplotmov,"999")) THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Tipo do Lote invalido."
                       par_nmdcampo = "tplotmov".
                LEAVE Grava.
            END.


        IF NOT CAN-FIND(crapfhs WHERE crapfhs.cdcooper = par_cdcooper  AND
                                      crapfhs.inhistor = par_inhistor) THEN
            DO:
                ASSIGN aux_cdcritic = 044
                       aux_dscritic = ""
                       par_nmdcampo = "inhistor".
                LEAVE Grava.
            END.

        IF par_dsexthst = "" THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Descricao extensa invalida."
                       par_nmdcampo = "dsexthst".
                LEAVE Grava.
            END.

        IF par_dsextrat = "" THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Descricao extrato invalida."
                       par_nmdcampo = "dsextrat".
                LEAVE Grava.
            END.

        IF  par_indoipmf <> 0 AND par_indoipmf <> 1 AND 
            par_indoipmf <> 2 THEN
            DO:
                ASSIGN aux_cdcritic = 014
                       aux_dscritic = ""
                       par_nmdcampo = "indoipmf".
                LEAVE Grava.
            END.

        IF par_inautori <> 0 AND par_inautori <> 1 THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Indicador para autorizacao de debito invalido."
                       par_nmdcampo = "inautori".
                LEAVE Grava.
            END.

        IF par_inavisar <> 0 AND par_inavisar <> 1 THEN
            DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Indicador de aviso para debito invalido."
                   par_nmdcampo = "inavisar".
            LEAVE Grava.
            END.

        IF par_indcompl <> 0 AND par_indcompl <> 1 THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Indicador de complemento invalido."
                       par_nmdcampo = "indcompl".
                LEAVE Grava.
            END.

        IF par_indebcta <> 0 AND par_indebcta <> 1 THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Indicador debito em conta invalido."
                       par_nmdcampo = "indebcta".
                LEAVE Grava.
            END.

        IF par_incremes <> 0 AND par_incremes <> 1 THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Indicador para estatistica de credito do mes invalido."
                       par_nmdcampo = "incremes".
                LEAVE Grava.
            END.

        IF par_inmonpld <> 0 AND par_inmonpld <> 1 THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Indicador para monitoramento invalido."
                       par_nmdcampo = "inmonpld".
                LEAVE Grava.
            END.

        IF par_tpctbccu <> 0 AND par_tpctbccu <> 1 THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Tipo de contabilizacao no centro de custo invalido."
                       par_nmdcampo = "tpctbccu".
                LEAVE Grava.
            END.

        IF NOT CAN-DO("0,1,2,3,4,5,6",STRING(par_tpctbcxa,"9")) THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Tipo de contabilizacao no caixa invalida."
                       par_nmdcampo = "tpctbcxa".
                LEAVE Grava.
            END.

        IF NOT CAN-DO("1,2,3",STRING(par_ingercre,"9")) THEN
            DO:
                ASSIGN aux_cdcritic = 380
                       aux_dscritic = ""
                       par_nmdcampo = "ingercre".
                LEAVE Grava.
            END.

        IF NOT CAN-DO("1,2,3",STRING(par_ingerdeb,"9")) THEN
            DO:
                ASSIGN aux_cdcritic = 380
                       aux_dscritic = ""
                       par_nmdcampo = "ingerdeb".
                LEAVE Grava.
            END.
        
        IF par_cdgrphis > 0 THEN
            DO:
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                
                /* Procedure para buscar as informacoes da CPMF da cooperativa */
                RUN STORED-PROCEDURE pc_valida_grupo_historico
                    aux_handproc = PROC-HANDLE NO-ERROR
                                            (INPUT par_cdgrphis, /* pr_cdgrupo_historico */
                                             OUTPUT "",  /* pr_flggphis */
                                             OUTPUT "",  /* pr_des_erro */
                                             OUTPUT ""). /* pr_dscritic */
                
                CLOSE STORED-PROC pc_valida_grupo_historico
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                
                ASSIGN aux_flggphis = ""
                       aux_des_erro = ""
                       aux_dscritic = ""
                       aux_flggphis = pc_valida_grupo_historico.pr_flggphis
                                          WHEN pc_valida_grupo_historico.pr_flggphis <> ?
                       aux_des_erro = pc_valida_grupo_historico.pr_des_erro
                                          WHEN pc_valida_grupo_historico.pr_des_erro <> ?
                       aux_dscritic = pc_valida_grupo_historico.pr_dscritic
                                          WHEN pc_valida_grupo_historico.pr_dscritic <> ?.
                
                IF aux_des_erro = "NOK" THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               par_nmdcampo = "cdgrupo_historico".
                        LEAVE Grava.
                    END.
        
                IF aux_flggphis = "N" THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Grupo de Historico informado nao encontrado."
                               par_nmdcampo = "cdgrupo_historico".
                        LEAVE Grava.
            END.

            END.
            
        IF par_cdprodut <> ? AND par_cdprodut <> 0 THEN
            DO:
                FIND FIRST crapprd WHERE crapprd.cdprodut = par_cdprodut        
                                   NO-LOCK NO-ERROR.
                IF NOT AVAIL crapprd THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Codigo Produto nao cadastrado."
                               par_nmdcampo = "cdprodut".
                        LEAVE Grava.
                    END.
            END. 
        
        IF par_cdagrupa <> ? AND par_cdagrupa <> 0 THEN
            DO:
                FIND FIRST crapagr WHERE crapagr.cdagrupa = par_cdagrupa        
                                   NO-LOCK NO-ERROR.
                IF NOT AVAIL crapagr THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Codigo Agrupamento nao cadastrado."
                               par_nmdcampo = "cdagrupa".
                        LEAVE Grava.
                    END.
            END. 

        IF par_tplotmov = 1 THEN
            ASSIGN aux_flgsenha = NO.
        ELSE
        DO:
            IF par_flgsenha = 1 THEN
                ASSIGN aux_flgsenha = TRUE.
            ELSE
                ASSIGN aux_flgsenha = NO.
        END.

        /*  Campos sem validacao:
                - nmestrut
                - inclasse
                - cdhstctb
                - nrctacre
                - nrctadeb
                - nrctatrc
                - nrctatrd
                - vltarayl
                - vltarcxo
                - vltarint
                - vltarcsh
        */

        /* carregar as informacoes das tarifas que estao cadastradas */
        FOR EACH crapthi WHERE crapthi.cdcooper = par_cdcooper AND
                               crapthi.cdhistor = par_cdhistor NO-LOCK:
        
            IF   crapthi.dsorigem = "AYLLOS"   THEN
                 ASSIGN aux_vltarayl = crapthi.vltarifa.
            ELSE
            IF   crapthi.dsorigem = "CAIXA"   THEN
                 ASSIGN aux_vltarcxo = crapthi.vltarifa.
            ELSE
            IF   crapthi.dsorigem = "INTERNET"   THEN
                 ASSIGN aux_vltarint = crapthi.vltarifa.
            ELSE
            IF   crapthi.dsorigem = "CASH"   THEN
                 ASSIGN aux_vltarcsh = crapthi.vltarifa.
        END.

        /* Quando opcao "I" tratar o campo cdhinovo e
           verificar se o historico nao existe */
        IF  par_cddopcao = "I"  THEN
            DO:
                IF par_cdhinovo = 0 THEN
                    DO:
                        ASSIGN aux_cdcritic = 0 
                               aux_dscritic = "Novo codigo do historico nao pode ser zero."
                               par_nmdcampo = "cdhinovo".
                        LEAVE Grava.
                    END.
                ELSE    
                    DO:
                        FIND FIRST craphis WHERE craphis.cdcooper = par_cdcooper 
                                             AND craphis.cdhistor = par_cdhinovo 
                                           NO-LOCK NO-ERROR.

                        IF AVAILABLE craphis THEN
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Codigo do Novo Historico ja esta em uso. " +
                                                      STRING(craphis.cdhistor) + " - " + 
                                                      craphis.dsexthst
                                       par_nmdcampo = "cdhinovo".
                                LEAVE Grava.
                            END.
                    END.

                /* Criar o registro do historico */
                CREATE craphis.
                ASSIGN craphis.cdcooper = par_cdcooper
                       craphis.cdhistor = par_cdhinovo.
            END.

            /* Quando opcao "A", lock no historico para que sejam atualizados os campos */
            IF par_cddopcao = "A" THEN
                DO:
                    
                    Contador: DO aux_contador = 1 TO 10:

                        FIND craphis WHERE craphis.cdcooper = par_cdcooper AND 
                                           craphis.cdhistor = par_cdhistor 
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                        IF  NOT AVAIL craphis THEN
                            DO:
                                IF  LOCKED(craphis) THEN
                                    DO:
                                        IF  aux_contador = 10 THEN
                                            DO: 
                                                ASSIGN aux_cdcritic = 341 /* Tabela Sendo Alterada */
                                                       aux_dscritic = "".
                                                LEAVE Contador.

                                            END.
                                        ELSE 
                                            DO:
                                                PAUSE 1 NO-MESSAGE.
                                                NEXT Contador.
                                            END.
                                    END.
                                ELSE
                                    DO:
                                        ASSIGN aux_cdcritic = 245 /* codigo do historico nao Cadastrado */
                                               aux_dscritic = "".

                                        LEAVE Contador.
                                    END.
                            END.
                        ELSE
                            LEAVE Contador.
                    END. /* Contador */

                    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                        UNDO Grava, LEAVE Grava.
                                
                    /* Gerar o log de alteracao do historico*/
                    RUN gera_item_log (INPUT par_cdhistor,
                                       INPUT par_dshistor,
                                       INPUT par_indebcre,
                                       INPUT par_tplotmov,
                                       INPUT par_inhistor,
                                       INPUT par_dsexthst,
                                       INPUT par_nmestrut,
                                       INPUT par_cdhstctb,
                                       INPUT par_indoipmf,
                                       INPUT par_inclasse,
                                       INPUT par_inautori,
                                       INPUT par_inavisar,
                                       INPUT par_indcompl,
                                       INPUT par_indebcta,
                                       INPUT par_incremes,
                                       INPUT par_inmonpld,
                                       INPUT par_tpctbcxa,
                                       INPUT par_vltarayl,
                                       INPUT par_vltarcxo,
                                       INPUT par_vltarint,
                                       INPUT par_vltarcsh,
                                       INPUT par_tpctbccu,
                                       INPUT par_nrctacrd,
                                       INPUT par_nrctadeb,
                                       INPUT par_ingercre,
                                       INPUT par_ingerdeb,
                                       INPUT par_nrctatrc,
                                       INPUT par_nrctatrd,
                                       INPUT aux_flgsenha,
                                       INPUT par_cdprodut,
                                       INPUT par_cdagrupa,
                                       INPUT par_indebfol,
                                       INPUT par_txdoipmf,
                                       INPUT par_dsextrat,
                                       INPUT par_cdcooper,
                                       INPUT par_cdoperad,
                                       INPUT aux_vltarayl,
                                       INPUT aux_vltarcxo,
                                       INPUT aux_vltarint,
                                       INPUT aux_vltarcsh,
                                       INPUT 0). /* cdcoprep */
                     /* Codigo da cooperativa que esta replicando eh 0
                        esta alterando o historico */
                END.

            IF par_cddopcao = "A" OR par_cddopcao = "I"  THEN
                DO:
                    /* Atualizar o historico */
                    ASSIGN craphis.cdhstctb  =  par_cdhstctb
                           craphis.dsexthst  =  CAPS(par_dsexthst)
                           craphis.dshistor  =  CAPS(par_dshistor)
                           craphis.inautori  =  par_inautori
                           craphis.inavisar  =  par_inavisar
                           craphis.inclasse  =  par_inclasse
                           craphis.incremes  =  par_incremes
                           craphis.inmonpld  =  par_inmonpld
                           craphis.indcompl  =  par_indcompl
                           craphis.indebcta  =  par_indebcta
                           craphis.indebfol  =  0 
                           craphis.indoipmf  =  par_indoipmf
                           craphis.inhistor  =  par_inhistor
                           craphis.indebcre  =  CAPS(par_indebcre)
                           craphis.nmestrut  =  TRIM(CAPS(par_nmestrut))
                           craphis.nrctacrd  =  par_nrctacrd
                           craphis.nrctatrc  =  par_nrctatrc
                           craphis.nrctadeb  =  par_nrctadeb
                           craphis.nrctatrd  =  par_nrctatrd
                           craphis.tpctbccu  =  par_tpctbccu
                           craphis.tplotmov  =  par_tplotmov
                           craphis.tpctbcxa  =  par_tpctbcxa
                           craphis.txdoipmf  =  0 
                           craphis.ingercre  =  par_ingercre
                           craphis.ingerdeb  =  par_ingerdeb
                           craphis.cdprodut  =  par_cdprodut
                           craphis.cdagrupa  =  par_cdagrupa
                           craphis.dsextrat  =  CAPS(par_dsextrat)
                           craphis.flgsenha  =  aux_flgsenha
                           craphis.cdgrphis  =  par_cdgrphis.
    
                    /* Atualizar as informacoes das tarifas */
                    FIND FIRST crapthi WHERE crapthi.cdcooper = craphis.cdcooper
                                         AND crapthi.cdhistor = craphis.cdhistor
                                       NO-LOCK NO-ERROR.
                      
                    IF  NOT AVAILABLE crapthi  THEN
                        DO:
                            CREATE crapthi.
                            ASSIGN crapthi.cdcooper = craphis.cdcooper
                                   crapthi.cdhistor = craphis.cdhistor
                                   crapthi.dsorigem = "AYLLOS"
                                   crapthi.vltarifa = par_vltarayl.
                                    
                            CREATE crapthi.
                            ASSIGN crapthi.cdcooper = craphis.cdcooper
                                   crapthi.cdhistor = craphis.cdhistor
                                   crapthi.dsorigem = "CAIXA"
                                   crapthi.vltarifa = par_vltarcxo.
                                           
                            CREATE crapthi.
                            ASSIGN crapthi.cdcooper = craphis.cdcooper
                                   crapthi.cdhistor = craphis.cdhistor
                                   crapthi.dsorigem = "INTERNET"
                                   crapthi.vltarifa = par_vltarint.
                                                   
                            CREATE crapthi.
                            ASSIGN crapthi.cdcooper = craphis.cdcooper
                                   crapthi.cdhistor = craphis.cdhistor
                                   crapthi.dsorigem = "CASH"
                                   crapthi.vltarifa = par_vltarcsh.
                        END.
                    ELSE
                        FOR EACH crapthi WHERE crapthi.cdcooper = craphis.cdcooper
                                           AND crapthi.cdhistor = craphis.cdhistor 
                                         EXCLUSIVE-LOCK:
                          
                            IF  crapthi.dsorigem = "AYLLOS"  THEN
                                crapthi.vltarifa = par_vltarayl.
                            ELSE
                            IF  crapthi.dsorigem = "CAIXA"  THEN
                                crapthi.vltarifa = par_vltarcxo.
                            ELSE
                            IF  crapthi.dsorigem = "INTERNET" THEN
                                crapthi.vltarifa = par_vltarint.
                            ELSE
                            IF  crapthi.dsorigem = "CASH"  THEN
                                crapthi.vltarifa = par_vltarcsh.
    
                        END. /** Fim do FOR EACH crapthi **/
    
                    /* Atualizar as tarifas */
                    RUN Atualiza_Tarifa (INPUT craphis.cdhistor,
                                         INPUT par_vltarcxo,
                                         INPUT par_vltarint,
                                         INPUT par_vltarayl,
                                         INPUT par_vltarcsh).
                END.
            
            /* Gerar log da inclusao */
            IF par_cddopcao = "I" THEN
                DO:
                    /* Gerar o Log da Busca */
                    RUN gera_logtel (INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT "Incluiu o historico de codigo " +
                                           STRING(craphis.cdhistor)).
                END.

            /* Replicar o historico para as outras cooperativas */
            IF par_cddopcao = "X" THEN 
                DO:
                    RUN Replica_Dados (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT par_cdoperad,
                                       INPUT par_nmdatela,
                                       INPUT par_idorigem,
                                       INPUT par_dtmvtolt,
                                       INPUT par_cddopcao,
                                       INPUT par_cdhistor,
                                       INPUT TRUE,
                                      OUTPUT TABLE tt-crapthi,
                                      OUTPUT TABLE tt-erro).
                END.

        LEAVE Grava.
        
    END. /* Grava */

    IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN
        ASSIGN aux_returnvl = "NOK".
    ELSE 
        IF  aux_cdcritic <> 0  OR
            aux_dscritic <> "" THEN
        DO:
            ASSIGN aux_returnvl = "NOK".
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE. /* Grava_Dados */


/* -------------------------------------------------------------------------- */
/*                EFETUA A REPLICACAO DE HISTORICOS NO SISTEMA                */
/* -------------------------------------------------------------------------- */
PROCEDURE Replica_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    
    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-crapthi.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_geralog  AS LOGI                                   NO-UNDO.
    /* Valor para atualizar as tarifas */
    DEF  VAR aux_vltarayl AS DECI                                   NO-UNDO.
    DEF  VAR aux_vltarcxo AS DECI                                   NO-UNDO.
    DEF  VAR aux_vltarint AS DECI                                   NO-UNDO.
    DEF  VAR aux_vltarcsh AS DECI                                   NO-UNDO.
    /* Valor atual das tarifas do historico */
    DEF  VAR log_vltarayl AS DECI                                   NO-UNDO.
    DEF  VAR log_vltarcxo AS DECI                                   NO-UNDO.
    DEF  VAR log_vltarint AS DECI                                   NO-UNDO.
    DEF  VAR log_vltarcsh AS DECI                                   NO-UNDO.

    DEFINE BUFFER bf-craphis FOR craphis.
    DEFINE BUFFER bf-crapthi FOR crapthi.

    EMPTY TEMP-TABLE tt-crapthi.
    EMPTY TEMP-TABLE tt-erro.

    FIND FIRST craphis WHERE craphis.cdcooper = par_cdcooper
                         AND craphis.cdhistor = par_cdhistor
                       NO-LOCK NO-ERROR.

    IF NOT AVAILABLE craphis THEN
        RETURN "OK".
            
    /* copia o historico das taxas */
    EMPTY TEMP-TABLE tt-crapthi.
    FOR EACH crapthi WHERE
             crapthi.cdcooper = par_cdcooper AND
             crapthi.cdhistor = par_cdhistor EXCLUSIVE-LOCK:
        CREATE tt-crapthi.
        BUFFER-COPY crapthi TO tt-crapthi.

        IF crapthi.dsorigem = "AYLLOS"   THEN                          
            ASSIGN aux_vltarayl = crapthi.vltarifa.                     
        ELSE                                                             
        IF crapthi.dsorigem = "CAIXA"   THEN          
            ASSIGN aux_vltarcxo = crapthi.vltarifa.           
        ELSE                                           
        IF crapthi.dsorigem = "INTERNET"   THEN
            ASSIGN aux_vltarint = crapthi.vltarifa.
        ELSE
        IF crapthi.dsorigem = "CASH"   THEN                
            ASSIGN aux_vltarcsh = crapthi.vltarifa.                
    END.
    
    FOR EACH crapcop FIELDS (cdcooper) NO-LOCK:

        IF crapcop.cdcooper = par_cdcooper THEN
           NEXT.

        ASSIGN aux_geralog = TRUE.

        FIND bf-craphis WHERE 
             bf-craphis.cdcooper = crapcop.cdcooper AND 
             bf-craphis.cdhistor = par_cdhistor EXCLUSIVE-LOCK NO-ERROR.
        IF NOT AVAILABLE bf-craphis THEN
        DO:
            CREATE bf-craphis.
            ASSIGN aux_geralog = FALSE.
        END.

        IF aux_geralog  THEN
        DO:
            /* cria o historico das taxas */
            FOR EACH bf-crapthi WHERE bf-crapthi.cdcooper = crapcop.cdcooper 
                                  AND bf-crapthi.cdhistor = tt-crapthi.cdhistor 
                                NO-LOCK:
                IF bf-crapthi.dsorigem = "AYLLOS"   THEN                          
                    ASSIGN log_vltarayl = bf-crapthi.vltarifa.                     
                ELSE                                                             
                IF bf-crapthi.dsorigem = "CAIXA"   THEN          
                    ASSIGN log_vltarcxo = bf-crapthi.vltarifa.           
                ELSE                                           
                IF bf-crapthi.dsorigem = "INTERNET"   THEN
                    ASSIGN log_vltarint = bf-crapthi.vltarifa.
                ELSE
                IF bf-crapthi.dsorigem = "CASH"   THEN                
                    ASSIGN log_vltarcsh = bf-crapthi.vltarifa.                
            END.

            /* Gerar o log de alteracao do historico*/
            RUN gera_item_log (INPUT craphis.cdhistor,
                               INPUT craphis.dshistor,
                               INPUT craphis.indebcre,
                               INPUT craphis.tplotmov,
                               INPUT craphis.inhistor,
                               INPUT craphis.dsexthst,
                               INPUT craphis.nmestrut,
                               INPUT craphis.cdhstctb,
                               INPUT craphis.indoipmf,
                               INPUT craphis.inclasse,
                               INPUT craphis.inautori,
                               INPUT craphis.inavisar,
                               INPUT craphis.indcompl,
                               INPUT craphis.indebcta,
                               INPUT craphis.incremes,
                               INPUT craphis.inmonpld,
                               INPUT craphis.tpctbcxa,
                               INPUT aux_vltarayl,
                               INPUT aux_vltarcxo,
                               INPUT aux_vltarint,
                               INPUT aux_vltarcsh,
                               INPUT craphis.tpctbccu,
                               INPUT craphis.nrctacrd,
                               INPUT craphis.nrctadeb,
                               INPUT craphis.ingercre,
                               INPUT craphis.ingerdeb,
                               INPUT craphis.nrctatrc,
                               INPUT craphis.nrctatrd,
                               INPUT craphis.flgsenha,
                               INPUT craphis.cdprodut,
                               INPUT craphis.cdagrupa,
                               INPUT craphis.indebfol,
                               INPUT craphis.txdoipmf,
                               INPUT craphis.dsextrat,
                               INPUT crapcop.cdcooper,
                               INPUT par_cdoperad,
                               INPUT log_vltarayl,
                               INPUT log_vltarcxo,
                               INPUT log_vltarint,
                               INPUT log_vltarcsh,
                               INPUT par_cdcooper). /* cdcoprep */
            /* passar o codigo da cooperativa 
              que estamos replicando o historico */
        END.

        BUFFER-COPY craphis EXCEPT cdcooper TO bf-craphis
            ASSIGN bf-craphis.cdcooper  = crapcop.cdcooper.

        /* cria o historico das taxas */
        FOR EACH tt-crapthi:
            FIND bf-crapthi WHERE
                 bf-crapthi.cdcooper = crapcop.cdcooper AND
                 bf-crapthi.cdhistor = tt-crapthi.cdhistor AND
                 bf-crapthi.dsorigem = tt-crapthi.dsorigem EXCLUSIVE-LOCK NO-ERROR.
            IF NOT AVAILABLE bf-crapthi THEN 
               DO:
                    CREATE bf-crapthi.
                    ASSIGN bf-crapthi.cdcooper = crapcop.cdcooper
                           bf-crapthi.cdhistor = tt-crapthi.cdhistor  
                           bf-crapthi.dsorigem = tt-crapthi.dsorigem.

               END.
            ASSIGN bf-crapthi.vltarifa = tt-crapthi.vltarifa.
        END.
        RELEASE bf-craphis.
    END.

    IF  par_flgerlog THEN
    DO:
        /* Gerar o Log da Busca */
        RUN gera_logtel (INPUT par_cdcooper,
                         INPUT par_cdoperad,
                         INPUT "Replicou o historico de codigo " +
                               STRING(craphis.cdhistor)).
    END.

    RETURN "OK".

END PROCEDURE. /* Replica_Dados */

/* ------------------------------------------------------------------------- */
/*            ATUALIZA AS TARIFAS NA TABELA GENERICA DE CONVENIOS            */
/* ------------------------------------------------------------------------- */
PROCEDURE Atualiza_Tarifa:

    DEF INPUT PARAM par_cdhistor AS INTE                                   NO-UNDO.
    DEF INPUT PARAM par_vltrfcxa AS DECI                                   NO-UNDO.
    DEF INPUT PARAM par_vltrfnet AS DECI                                   NO-UNDO.
    DEF INPUT PARAM par_vltrfdeb AS DECI                                   NO-UNDO.
    DEF INPUT PARAM par_vltrftaa AS DECI                                   NO-UNDO.
    
    FOR EACH gnconve WHERE (gnconve.cdhiscxa = par_cdhistor  OR
                            gnconve.cdhisdeb = par_cdhistor) EXCLUSIVE-LOCK:
    
        IF  gnconve.cdhiscxa = par_cdhistor  THEN
            ASSIGN gnconve.vltrfcxa = par_vltrfcxa
                   gnconve.vltrfnet = par_vltrfnet 
                   gnconve.vltrftaa = par_vltrftaa.
    
        IF  gnconve.cdhisdeb = par_cdhistor  THEN
            ASSIGN gnconve.vltrfdeb = par_vltrfdeb.
    
    END.

END PROCEDURE. /*Atualiza_Tarifa*/

/* ------------------------------------------------------------------------- */
/*                   GERA IMPRESSÃO DOS HISTORICOS OPCAO B                   */
/* ------------------------------------------------------------------------- */
PROCEDURE Gera_ImpressaoB:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_indebcre AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_qtregist AS INTE                                    NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados Manutencao do Historico".

    EMPTY TEMP-TABLE tt-erro.

    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        
        FOR FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK: END.
           
        ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser.
        
        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

        /* Buscar os dados dos historicos utilizados no boletim de caixa */
        RUN Busca_Boletim
            ( INPUT par_cdcooper,
              INPUT 0,
              INPUT 0,
             OUTPUT aux_qtregist,
             OUTPUT TABLE tt-histor).

        FOR EACH tt-histor NO-LOCK
                           BY tt-histor.indebcre
                           BY tt-histor.cdhistor:
            
            DISPLAY STREAM str_1
                           tt-histor.cdhistor LABEL "Historico"
                           tt-histor.dshistor LABEL "Descricao" FORMAT "x(30)"
                           tt-histor.indebcre LABEL "D/C"       FORMAT " x "
                           WITH NO-LABEL CENTERED 
                           TITLE "HISTORICOS BOLETIM CAIXA\n\n".
        END.

        OUTPUT STREAM str_1 CLOSE.
        
        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO: 
                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.

                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE Imprime.
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
                    RETURN "NOK".
            END.
        
        LEAVE Imprime.

    END. /* Imprime */

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN

                FIND FIRST tt-erro NO-ERROR.

                IF  AVAIL tt-erro THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.
                
            ELSE
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    IF  par_flgerlog THEN
    DO:
        /* Gerar o Log da Busca */
        RUN gera_logtel (INPUT par_cdcooper,
                         INPUT par_cdoperad,
                         INPUT "Imprimiu relatorio dos historicos aceitos " +
                               "na rotina 11 - Boletim de Caixa do caixa " +
                               "on-line." ).
    END.

    RETURN aux_returnvl.

END PROCEDURE. /* Gera_ImpressaoB*/


/* ------------------------------------------------------------------------- */
/*                   GERA IMPRESSÃO DOS HISTORICOS OPCAO O                   */
/* ------------------------------------------------------------------------- */
PROCEDURE Gera_ImpressaoO:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_qtregist AS INTE                                    NO-UNDO.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados Manutencao do CCF".

    EMPTY TEMP-TABLE tt-erro.
                
    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        
        FOR FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK: END.

        ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser.
        
        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        
        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
    
        /* Buscar os dados dos historicos utilizados no tela outros  */
        RUN Busca_Outros
            ( INPUT par_cdcooper,
              INPUT 0,
              INPUT 0,
             OUTPUT aux_qtregist,
             OUTPUT TABLE tt-histor).

        FOR EACH tt-histor NO-LOCK
                           BY tt-histor.indebcre
                           BY tt-histor.cdhistor:

            DISPLAY STREAM str_1
                       tt-histor.cdhistor LABEL "Historico"
                       tt-histor.dshistor LABEL "Descricao" FORMAT "x(30)"
                       tt-histor.indebcre LABEL "D/C"       FORMAT " x "
                       WITH NO-LABEL CENTERED 
                       TITLE "HISTORICOS VALIDOS NA TELA OUTROS\n\n".

        END.
        
        OUTPUT  STREAM str_1 CLOSE.
        
        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO: 
                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.

                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE Imprime.
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
                    RETURN "NOK".
            END.
        
        LEAVE Imprime.

    END. /* Imprime */

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN

                FIND FIRST tt-erro NO-ERROR.

                IF  AVAIL tt-erro THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.
                
            ELSE
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    IF  par_flgerlog THEN
    DO:
        /* Gerar o Log da Busca */
        RUN gera_logtel (INPUT par_cdcooper,
                         INPUT par_cdoperad,
                         INPUT "Imprimiu relatorio historicos aceitos na "+
                               "rotina 56 - Inclusao Outros do caixa on-line." ).
    END.

    RETURN aux_returnvl.

END PROCEDURE. /* Gera_ImpressaoO */


PROCEDURE carrega_cpmf:
    
    DEF   INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF   INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF   INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF   INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF  OUTPUT PARAM par_dtinipmf AS DATE                           NO-UNDO.
    DEF  OUTPUT PARAM par_dtfimpmf AS DATE                           NO-UNDO.
    DEF  OUTPUT PARAM par_txcpmfcc AS DECIMAL                        NO-UNDO.
    DEF  OUTPUT PARAM par_txrdcpmf AS DECIMAL                        NO-UNDO.
    DEF  OUTPUT PARAM par_indabono AS INTE                           NO-UNDO.
    DEF  OUTPUT PARAM par_dtiniabo AS DATE                           NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
    
    /* Procedure para buscar as informacoes da CPMF da cooperativa */
    RUN STORED-PROCEDURE pc_busca_cpmf
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper, /* pr_cdcooper */
                                 INPUT par_dtmvtolt, /* pr_dtmvtolt */
                                 OUTPUT ?,  /* pr_dtinipmf */
                                 OUTPUT ?,  /* pr_dtfimpmf */
                                 OUTPUT ?,  /* pr_txcpmfcc */
                                 OUTPUT ?,  /* pr_txrdcpmf */
                                 OUTPUT ?,  /* pr_indabono */
                                 OUTPUT ?,  /* pr_dtiniabo */
                                 OUTPUT ?,  /* pr_cdcritic */
                                 OUTPUT ?). /* pr_dscritic */
    
    CLOSE STORED-PROC pc_busca_cpmf
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN par_dtinipmf = ?
           par_dtfimpmf = ?
           par_txcpmfcc = 0
           par_txrdcpmf = 0
           par_indabono = ?
           par_dtiniabo = ?
           aux_cdcritic = 0
           aux_dscritic = ""
           par_dtinipmf = pc_busca_cpmf.pr_dtinipmf
                              WHEN pc_busca_cpmf.pr_dtinipmf <> ?
           par_dtfimpmf = pc_busca_cpmf.pr_dtfimpmf
                              WHEN pc_busca_cpmf.pr_dtfimpmf <> ?
           par_txcpmfcc = pc_busca_cpmf.pr_txcpmfcc
                              WHEN pc_busca_cpmf.pr_txcpmfcc <> ?
           par_txrdcpmf = pc_busca_cpmf.pr_txrdcpmf
                              WHEN pc_busca_cpmf.pr_txrdcpmf <> ?
           par_indabono = pc_busca_cpmf.pr_indabono
                              WHEN pc_busca_cpmf.pr_indabono <> ?
           par_dtiniabo = pc_busca_cpmf.pr_dtiniabo
                              WHEN pc_busca_cpmf.pr_dtiniabo <> ?
           aux_cdcritic = pc_busca_cpmf.pr_cdcritic 
                              WHEN pc_busca_cpmf.pr_cdcritic <> ?
           aux_dscritic = pc_busca_cpmf.pr_dscritic
                              WHEN pc_busca_cpmf.pr_dscritic <> ?.           

    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
        DO:
            IF  aux_dscritic = "" THEN
               ASSIGN aux_dscritic =  "Nao foi possivel carregar as " +
                                      "informacoes de CPMF.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE. /* carrega_cpmf */


PROCEDURE gera_item_log:

    DEF INPUT PARAM par_cdhistor AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_dshistor AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_indebcre AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_tplotmov AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_inhistor AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_dsexthst AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nmestrut AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_cdhstctb AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_indoipmf AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_inclasse AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_inautori AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_inavisar AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_indcompl AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_indebcta AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_incremes AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_inmonpld AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_tpctbcxa AS INTE                            NO-UNDO.
    DEF INPUT PARAM aux_vltarayl AS DECI                            NO-UNDO.
    DEF INPUT PARAM aux_vltarcxo AS DECI                            NO-UNDO.
    DEF INPUT PARAM aux_vltarint AS DECI                            NO-UNDO.
    DEF INPUT PARAM aux_vltarcsh AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_tpctbccu AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrctacrd AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrctadeb AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_ingercre AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_ingerdeb AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrctatrc AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrctatrd AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_flgsenha AS LOGI                            NO-UNDO.
    DEF INPUT PARAM par_cdprodut AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdagrupa AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_indebfol AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_txdoipmf AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_dsextrat AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF INPUT PARAM log_vltarayl AS DECI                            NO-UNDO.
    DEF INPUT PARAM log_vltarcxo AS DECI                            NO-UNDO.
    DEF INPUT PARAM log_vltarint AS DECI                            NO-UNDO.
    DEF INPUT PARAM log_vltarcsh AS DECI                            NO-UNDO.
    /* Codigo da cooperativa que replicou os dados */
    DEF INPUT PARAM par_cdcoprep AS INTE NO-UNDO.

    FOR FIRST b-craphis WHERE b-craphis.cdcooper = par_cdcooper
                          AND b-craphis.cdhistor = par_cdhistor NO-LOCK: END.
    
    IF CAPS(par_dshistor) <> CAPS(b-craphis.dshistor) THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Historico",
                      INPUT CAPS(b-craphis.dshistor),
                      INPUT CAPS(par_dshistor)).

    IF par_indebcre <> b-craphis.indebcre THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Indicador de D/C",
                      INPUT b-craphis.indebcre,
                      INPUT par_indebcre).
 
    IF par_tplotmov <> b-craphis.tplotmov THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Tipo do lote",
                      INPUT STRING(b-craphis.tplotmov),
                      INPUT STRING(par_tplotmov)).
       
    IF par_inhistor <> b-craphis.inhistor THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Ind. Funcao",
                      INPUT STRING(b-craphis.inhistor),
                      INPUT STRING(par_inhistor)).
       
    IF par_dsexthst <> b-craphis.dsexthst THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Descricao extensa",
                      INPUT b-craphis.dsexthst,
                      INPUT par_dsexthst).
 
    IF TRIM(CAPS(par_nmestrut)) <> TRIM(CAPS(b-craphis.nmestrut)) THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Nome da estrutura",
                      INPUT TRIM(CAPS(b-craphis.nmestrut)),
                      INPUT TRIM(CAPS(par_nmestrut))).
 
    IF par_cdhstctb <> b-craphis.cdhstctb THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Historico contabilidade",
                      INPUT STRING(b-craphis.cdhstctb),
                      INPUT STRING(par_cdhstctb)).
 
    IF par_indoipmf <> b-craphis.indoipmf THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Indicador de incidencia IPMF",
                      INPUT STRING(b-craphis.indoipmf),
                      INPUT STRING(par_indoipmf)).
 
    IF par_inclasse <> b-craphis.inclasse THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Classe CPMF",
                      INPUT STRING(b-craphis.inclasse),
                      INPUT STRING(par_inclasse)).
 
    IF par_inautori <> b-craphis.inautori THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Ind. p/autorizacao debito",
                      INPUT STRING(b-craphis.inautori),
                      INPUT STRING(par_inautori)).
 
    IF par_inavisar <> b-craphis.inavisar THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Ind. de aviso p/debito",
                      INPUT STRING(b-craphis.inavisar),
                      INPUT STRING(par_inavisar)).
 
    IF par_indcompl <> b-craphis.indcompl THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Indicador de Complemento",
                      INPUT STRING(b-craphis.indcompl),   
                      INPUT STRING(par_indcompl)).
    
    IF par_indebcta <> b-craphis.indebcta THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Ind. debito em conta",
                      INPUT STRING(b-craphis.indebcta),
                      INPUT STRING(par_indebcta)).
 
    IF par_incremes <> b-craphis.incremes THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Ind. p/estat. credito do mes",
                      INPUT STRING(b-craphis.incremes),
                      INPUT STRING(par_incremes)).
 
    IF par_inmonpld <> b-craphis.inmonpld THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Ind. Monitoramento",
                      INPUT STRING(b-craphis.inmonpld),
                      INPUT STRING(par_inmonpld)).
 
    IF par_tpctbcxa <> b-craphis.tpctbcxa THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Tipo contab. caixa",
                      INPUT STRING(b-craphis.tpctbcxa),
                      INPUT STRING(par_tpctbcxa)).
        
    IF aux_vltarayl <> log_vltarayl THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Tarifa Ayllos",
                      INPUT STRING(log_vltarayl,"zzz,zzz,zz9.99"),
                      INPUT STRING(aux_vltarayl,"zzz,zzz,zz9.99")).
 
    IF aux_vltarcxo <> log_vltarcxo THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Tarifa Caixa",
                      INPUT STRING(log_vltarcxo,"zzz,zzz,zz9.99"),
                      INPUT STRING(aux_vltarcxo,"zzz,zzz,zz9.99")).
 
    IF aux_vltarint <> log_vltarint THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Tarifa Internet",
                      INPUT STRING(log_vltarint,"zzz,zzz,zz9.99"),
                      INPUT STRING(aux_vltarint,"zzz,zzz,zz9.99")).
 
    IF aux_vltarcsh <> log_vltarcsh THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Tarifa Cash",
                      INPUT STRING(log_vltarcsh,"zzz,zzz,zz9.99"),
                      INPUT STRING(aux_vltarcsh,"zzz,zzz,zz9.99")).
       
       
 
    IF par_tpctbccu <> b-craphis.tpctbccu THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Tipo de contab. centro custo",
                      INPUT STRING(b-craphis.tpctbccu),
                      INPUT STRING(par_tpctbccu)).
       
    IF par_nrctacrd <> b-craphis.nrctacrd THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Conta a creditar",
                      INPUT STRING(b-craphis.nrctacrd),
                      INPUT STRING(par_nrctacrd)).
 
    IF par_nrctadeb <> b-craphis.nrctadeb THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Conta a debitar",
                      INPUT STRING(b-craphis.nrctadeb),
                      INPUT STRING(par_nrctadeb)).
 
    IF par_ingercre <> b-craphis.ingercre THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Gerencial a Credito",
                      INPUT STRING(b-craphis.ingercre),
                      INPUT STRING(par_ingercre)).
       
    IF par_ingerdeb <> b-craphis.ingerdeb THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Gerencial a Debito",
                      INPUT STRING(b-craphis.ingerdeb),
                      INPUT STRING(par_ingerdeb)).
       
    IF par_nrctatrc <> b-craphis.nrctatrc THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Conta Tarifa Credito",
                      INPUT STRING(b-craphis.nrctatrc),
                      INPUT STRING(par_nrctatrc)).
       
    IF par_nrctatrd <> b-craphis.nrctatrd THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Conta Tarifa Debito",
                      INPUT STRING(b-craphis.nrctatrd),
                      INPUT STRING(par_nrctatrd)).
       
    IF par_flgsenha <> b-craphis.flgsenha THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Solicitar Senha",
                      INPUT (IF b-craphis.flgsenha = TRUE THEN
                                "Sim" 
                             ELSE
                                "Nao"), 
                      INPUT (IF par_flgsenha = TRUE THEN
                                "Sim"
                             ELSE 
                                "Nao")).
       
    IF par_cdprodut <> b-craphis.cdprodut THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Codigo Produto",
                      INPUT STRING(b-craphis.cdprodut),
                      INPUT STRING(par_cdprodut)).
 
    IF par_cdagrupa <> b-craphis.cdagrupa THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Codigo Agrupamento",
                      INPUT STRING(b-craphis.cdagrupa),
                      INPUT STRING(par_cdagrupa)).
 
    IF par_indebfol <> b-craphis.indebfol THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Ind. debito em folha",
                      INPUT STRING(b-craphis.indebfol),
                      INPUT STRING(par_indebfol)).
       
    IF par_txdoipmf <> b-craphis.txdoipmf THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Aliquota do IPMF",
                      INPUT STRING(b-craphis.txdoipmf),
                      INPUT STRING(par_txdoipmf)).
 
    IF par_dsextrat <> b-craphis.dsextrat  THEN
        RUN gera_log (INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT par_cdhistor,
                      INPUT par_cdcoprep,
                      INPUT "Descricao Extrato",
                      INPUT b-craphis.dsextrat,
                      INPUT par_dsextrat).
 
END PROCEDURE. /* Fim da procedure gera_item_log */


PROCEDURE gera_log:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE NO-UNDO.

    /* Codigo da cooperativa que replicou os dados */
    DEF INPUT PARAM par_cdcoprep AS INTE NO-UNDO.

    DEF INPUT PARAM par_dsdcampo AS CHAR NO-UNDO.
    DEF INPUT PARAM par_vlrantes AS CHAR NO-UNDO.
    DEF INPUT PARAM par_vlrdepoi AS CHAR NO-UNDO.

    IF par_cdcoprep > 0 THEN
        DO:
            RUN gera_logtel (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "Replicou o historico de codigo "   + 
                                   STRING(par_cdhistor) + ". " +
                                   "Cooperativa Origem: " + 
                                   STRING(par_cdcoprep) + "." +
                                   " Campo " + par_dsdcampo + " de "  +
                                   par_vlrantes + " para " + 
                                   par_vlrdepoi + "." ).
        END.
    ELSE 
        DO:
            RUN gera_logtel (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "Alterou o historico de codigo "   + 
                                   STRING(par_cdhistor) + ". "        +
                                   " Campo " + par_dsdcampo + " de "  +
                                   par_vlrantes + " para " + 
                                   par_vlrdepoi + "." ).
        END.

END PROCEDURE. /* Fim da procedure gera_log */


PROCEDURE gera_logtel:
    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dslog    AS CHAR NO-UNDO.

    FOR FIRST crapcop WHERE 
              crapcop.cdcooper = par_cdcooper NO-LOCK: END.

    UNIX SILENT VALUE("echo " +
                      STRING(TODAY,"99/99/9999") + " "   +
                      STRING(TIME,"HH:MM:SS")    + " - " +
                      "Operador " + par_cdoperad + " - " +
                      par_dslog   +
                      " >> /usr/coop/" +  
                      TRIM(crapcop.dsdircop) + 
                      "/log/histor.log").

END PROCEDURE.

