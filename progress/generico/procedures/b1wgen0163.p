/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0163.p
    Autor   : Jéssica (DB1)
    Data    : 29/07/2013                     Ultima atualizacao: 02/09/2015 

    Objetivo  : Tranformacao BO tela ESTOUR.

    Alteracoes: 02/09/2015 - Ajustes para correcao da conversao realizada
                             pela DB1
                             (Adriano).	

                14/03/2018 - Ajuste para buscar a descricao do tipo de conta do oracle. 
                             PRJ366 (Lombardi)
        
............................................................................*/

/*............................. DEFINICOES .................................*/
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0163tt.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

/*................................ PROCEDURES ..............................*/

/* -------------------------------------------------------------------------- */
/*                 EFETUA A PESQUISA DE ESTOUROS E DEVOLUCOES                 */
/* -------------------------------------------------------------------------- */
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                             NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INT                              NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INT                              NO-UNDO.
                                                  
    DEF OUTPUT PARAM par_msgauxil AS CHAR                             NO-UNDO.
    DEF OUTPUT PARAM par_nmprimtl AS CHAR                             NO-UNDO.
    DEF OUTPUT PARAM par_qtddtdev AS INTE                             NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                             NO-UNDO.
    DEF OUTPUT PARAM par_qtregist AS INT                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-estour.         
    DEF OUTPUT PARAM TABLE FOR tt-erro.           
                                                  
    DEF VAR aux_cdhisest AS CHAR                                      NO-UNDO.
    DEF VAR aux_cdobserv AS CHAR                                      NO-UNDO.
    DEF VAR aux_dsobserv AS CHAR                                      NO-UNDO.
    DEF VAR aux_dscodant AS CHAR                                      NO-UNDO.
    DEF VAR aux_dscodatu AS CHAR                                      NO-UNDO.
    DEF VAR aux_nrdconta AS INTE                                      NO-UNDO.
    DEF VAR aux_regexist AS LOG                                       NO-UNDO.
    DEF VAR aux_dstransa AS CHAR                                      NO-UNDO.
    DEF VAR aux_dsorigem AS CHAR                                      NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                      NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                      NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                      NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                                     NO-UNDO.
    DEF VAR h-b1wgen9998 AS HANDLE                                    NO-UNDO.
    DEF VAR aux_nrregist AS INT                                       NO-UNDO.
    DEF VAR aux_dstipcta AS CHAR                                      NO-UNDO.
    DEF VAR aux_des_erro AS CHAR                                      NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados Estouros e Devolucoes"
           aux_regexist = FALSE
           aux_nrregist = par_nrregist.              

    EMPTY TEMP-TABLE tt-estour.
    EMPTY TEMP-TABLE tt-erro.

    Busca: 
    DO ON ERROR UNDO Busca, LEAVE Busca:

       /*Verifica se tem algo digitado*/
       IF par_nrdconta <= 0 THEN
          DO:
              ASSIGN aux_cdcritic = 008
                     aux_dscritic = ""
                     par_nmdcampo = "nrdconta".

              LEAVE Busca.

          END.

       FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                          crapass.nrdconta = par_nrdconta 
                          NO-LOCK NO-ERROR.


       IF NOT AVAIL crapass THEN
          DO:
              ASSIGN aux_cdcritic = 009
                     aux_dscritic = ""
                     par_nmdcampo = "nrdconta".

              LEAVE Busca.

          END.

       FIND crapsld WHERE crapsld.cdcooper = par_cdcooper AND
                          crapsld.nrdconta = par_nrdconta 
                          NO-LOCK NO-ERROR.

       IF NOT AVAIL crapsld THEN
          DO:
              ASSIGN aux_cdcritic = 009
                     aux_dscritic = ""
                     par_nmdcampo = "nrdconta".

              LEAVE Busca.

          END.

       FIND craptrf WHERE craptrf.cdcooper = par_cdcooper  AND
                          craptrf.nrsconta = par_nrdconta  AND
                          craptrf.tptransa = 1             AND
                          craptrf.insittrs = 2
                          NO-LOCK NO-ERROR.

       IF AVAILABLE craptrf THEN
          ASSIGN par_msgauxil = "Conta original do associado:" +
                                STRING(craptrf.nrdconta,"zzzz,zzz,9").

       ASSIGN par_nmprimtl = "- " + crapass.nmprimtl
              par_qtddtdev = crapsld.qtddtdev.

       FOR EACH crapneg WHERE crapneg.cdcooper = par_cdcooper  AND
                              crapneg.nrdconta = crapass.nrdconta
                              USE-INDEX crapneg1 NO-LOCK:
       
           ASSIGN aux_cdhisest = ""
                  aux_cdobserv = ""
                  aux_dsobserv = ""
                  aux_dscodant = ""
                  aux_dscodatu = ""
                  aux_regexist = TRUE
                  par_qtregist = par_qtregist + 1.

           /* controles da paginação */
           IF  (par_qtregist < par_nriniseq) OR
               (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.
    
           IF aux_nrregist > 0 THEN
              DO:
                 IF crapneg.cdhisest = 0 THEN
                    ASSIGN aux_cdhisest = "Admissao socio".
                 ELSE
                 IF crapneg.cdhisest = 1 THEN
                    ASSIGN aux_cdhisest = "Devolucao Chq.".
                 ELSE
                 IF crapneg.cdhisest = 2 THEN
                    ASSIGN aux_cdhisest = "Alt. Tipo Conta".
                 ELSE
                 IF crapneg.cdhisest = 3 THEN
                    ASSIGN aux_cdhisest = "Alt. Sit. Conta".
                 ELSE
                 IF crapneg.cdhisest = 4 THEN
                    ASSIGN aux_cdhisest = "Credito Liquid.".
                 ELSE
                 IF crapneg.cdhisest = 5 THEN
                    ASSIGN aux_cdhisest = "Estouro".
                 ELSE
                 IF crapneg.cdhisest = 6 THEN
                    ASSIGN aux_cdhisest = "Notificacao".
                 
                 IF (crapneg.cdhisest = 1   AND 
                     crapneg.dtfimest <> ?) THEN
                     ASSIGN aux_dscodatu = "  ACERTADO".
                 
                 IF (crapneg.cdhisest = 1   OR 
                    (crapneg.cdhisest = 5   AND
                     crapneg.cdobserv > 0)) THEN
                    DO:
                       FIND crapali WHERE crapali.cdalinea = crapneg.cdobserv 
                                          NO-LOCK NO-ERROR.
                 
                       IF NOT AVAILABLE crapali  THEN
                          IF crapneg.cdhisest = 1 THEN
                             ASSIGN aux_dsobserv = "Alinea "+ STRING(crapneg.cdobserv)
                                    aux_cdobserv = "".
                          ELSE
                             ASSIGN aux_cdobserv = ""
                                    aux_dsobserv = "" .
                       ELSE
                          ASSIGN aux_dsobserv = crapali.dsalinea
                                 aux_cdobserv = STRING(crapali.cdalinea).
                 
                    END.
                 
                 IF crapneg.cdhisest = 2 THEN
                    DO:
                       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
                       RUN STORED-PROCEDURE pc_descricao_tipo_conta
                         aux_handproc = PROC-HANDLE NO-ERROR
                                                 (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                                  INPUT crapneg.cdtctant, /* Tipo de conta */
                                                 OUTPUT "",               /* Descriçao do Tipo de conta */
                                                 OUTPUT "",               /* Flag Erro */
                                                 OUTPUT "").              /* Descriçao da crítica */
                       
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
                       
                       IF aux_des_erro = "NOK"  THEN
                          ASSIGN aux_dscodant = STRING(crapneg.cdtctant).
                       ELSE
                          ASSIGN aux_dscodant = aux_dstipcta.
                 
                       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
                       RUN STORED-PROCEDURE pc_descricao_tipo_conta
                         aux_handproc = PROC-HANDLE NO-ERROR
                                                 (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                                  INPUT crapneg.cdtctatu, /* Tipo de conta */
                                                 OUTPUT "",               /* Descriçao do Tipo de conta */
                                                 OUTPUT "",               /* Flag Erro */
                                                 OUTPUT "").              /* Descriçao da crítica */
                       
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
                       
                       IF aux_des_erro = "NOK"  THEN
                          ASSIGN aux_dscodatu = STRING(crapneg.cdtctatu).
                       ELSE
                          ASSIGN aux_dscodatu = aux_dstipcta.
                 
                    END.
                 
                 IF crapneg.cdhisest = 3 THEN
                    DO:
                       IF crapneg.cdtctant = 0  THEN
                          ASSIGN aux_dscodant = STRING(crapneg.cdtctant).
                       ELSE
                          IF crapneg.cdtctant = 1 THEN
                             ASSIGN aux_dscodant = "NORMAL".
                          ELSE
                             ASSIGN aux_dscodant = "ENCERRADA".
                 
                       IF crapneg.cdtctatu = 0  THEN
                          ASSIGN aux_dscodatu = STRING(crapneg.cdtctatu).
                       ELSE
                          IF crapneg.cdtctatu = 1 THEN
                             ASSIGN aux_dscodatu = "NORMAL".
                          ELSE
                             ASSIGN aux_dscodatu = "ENCERRADA".
                 
                    END.
                 
                 CREATE tt-estour.
                 
                 ASSIGN tt-estour.cdhisest = aux_cdhisest
                        tt-estour.dscodatu = aux_dscodatu
                        tt-estour.dsobserv = aux_dsobserv
                        tt-estour.cdobserv = aux_cdobserv
                        tt-estour.dscodant = aux_dscodant
                        tt-estour.nrdconta = par_nrdconta
                        tt-estour.nrseqdig = crapneg.nrseqdig
                        tt-estour.dtiniest = crapneg.dtiniest
                        tt-estour.qtdiaest = crapneg.qtdiaest
                        tt-estour.vlestour = crapneg.vlestour
                        tt-estour.nrdctabb = crapneg.nrdctabb
                        tt-estour.nrdocmto = crapneg.nrdocmto
                        tt-estour.vllimcre = crapneg.vllimcre.
                 
              END.

           ASSIGN aux_nrregist = aux_nrregist - 1.

       END. /*  Fim do FOR EACH  --  Leitura dos negativos automaticos  */
       
       IF NOT aux_regexist THEN
          DO:
              ASSIGN aux_cdcritic = 413
                     aux_dscritic = ""
                     par_nmdcampo = "nrdconta".

              LEAVE Busca.
          END.

       LEAVE Busca.

    END. /* Busca */

    IF aux_dscritic <> ""             OR
       aux_cdcritic <> 0              OR 
       TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO:
          ASSIGN aux_returnvl = "NOK".

          IF TEMP-TABLE tt-erro:HAS-RECORDS THEN
             DO:
                FIND FIRST tt-erro NO-ERROR.
                
                IF AVAIL tt-erro THEN
                   ASSIGN aux_dscritic = tt-erro.dscritic.

             END.
          ELSE
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

          IF par_flgerlog THEN
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_dscritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT NO,
                                 INPUT 1, /** idseqttl **/
                                 INPUT par_nmdatela,
                                 INPUT 0, /* nrdconta */
                                OUTPUT aux_nrdrowid).

       END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Dados */


/*.............................. PROCEDURES (FIM) ...........................*/
