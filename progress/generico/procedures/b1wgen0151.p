
/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0151.p
    Autor   : Gabriel Capoia (DB1)
    Data    : 07/02/2013                     Ultima atualizacao: 06/08/2019

    Objetivo  : Tranformacao BO tela PESQDP.

    Alteracoes: 
        
        24/05/2013 Alterado caminho de documentos temporários p/ impressão.(Jean)
        
        29/08/2013 Removido o bloqueio de cadastro (opcao I) quando a conta
                   informada ja tiver cadastro (Carlos)
                   
        03/09/2013 Incluida validacao da conta salario para as opcoes I e S
                   (Carlos)
                    
        04/09/2013 Na opcao I, retirada a validacao que impedia o cadastro de
                   conta salario para CPF que ja possuia alguma conta ativa.
                   (Carlos)
                   
        05/11/2013 Validando se a conta para transferencia esta encerrada,
                   procedure Valida_Conta_Salario. Validando se existe uma 
                   conta crapass ao incluir uma conta salario, procedure 
                   Busca_Dados (Carlos)
                   
        12/12/2013 Adicionado VALIDATE para CREATE. (Jorge)
        
        18/12/2013 Correcao na validacao de conta para transferencia com
                   situacao encerrada (Carlos)
                   
        07/01/2014 Criticas de busca de crapage alteradas de 15 para 962.
                   "Agencia Nao Cadastrada" para "PA Nao Cadastrado" (Carlos)
                   
        23/04/2015 Ajustando a tela CTASAL
                   Projeto 158 - Servico Folha de Pagto
                   (Andre Santos - SUPERO)

        20/04/2016 - Alterada a Valida_Conta_Salario para validar diretamente
                     no Oracle(pc_valida_lancto_folha) quando for banco 085
                     (Guilherme/SUPERO)

		29/08/2016 - Ajuste na procedure Gera_Impressao: aumento do format
		             do campo rel_nrctatrf, pois nao estava imprimindo o 
					 dv do numero da conta. (Chamado 499004) - (Fabricio)

		13/01/2017 - Ajustado o campo nrctatrf para DECIMAL pois 
 					 esta estourando o format pois deixa digitar 
					 maior que INTE na tela (Tiago/Thiago 581315).
        
        25/04/2017 - Adicionar conta na menssage da verificacao da conta salario
                     para mais de um cpf (Lucas Ranghetti #654576)
                     
        04/08/2017 - Alterado rotina grava-dados para gerar numero de conta 
                     automaticamente da mesma forma que a matrci faz 
                     (Tiago/Thiago #689996)
					 
		07/08/2017 - Ajuste realizado para gerar numero de conta automaticamente na
				     inclusao, conforme solicitado no chamado 689996. (Kelvin)
             
        14/05/2018 - Incluido novo campo "Tipo de Conta" (tpctatrf) na tela CTASAL
                     Projeto 479-Catalogo de Servicos SPB (Mateus Z - Mouts)
                           
		10/07/2018 - Gerando arquivo de log para as operacoes da tela. (INC0018421 - Kelvin) 
                           
        17/08/2018 - Removendo validacao do titular do javascript e colocando no
					 progress. (SCTASK002723 - Kelvin)

        06/08/2019 - Permitir inclusao de folha CTASAL apenas antes do horario
                     parametrisado na PAGFOL "Portabilidade (Pgto no dia):"
                     RITM0032122 - Lucas Ranghetti
............................................................................*/

/*............................. DEFINICOES .................................*/
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0151tt.i }
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
DEF VAR aux_nmendter AS CHAR                                        NO-UNDO.
DEF VAR aux_idorigem AS INTE                                        NO-UNDO.
DEF VAR aux_nrregist AS INTE                                        NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.

FUNCTION ValidaDigFun RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_cdagenci AS INTEGER,
      INPUT par_nrdcaixa AS INTEGER,
      INPUT par_nrdconta AS INTEGER ) FORWARD.

/*................................ PROCEDURES ..............................*/

/* ------------------------------------------------------------------------ */
/*                 EFETUA A PESQUISA DE CHEQUES DEPOSITADOS                 */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM aux_msgconfi AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-crapccs.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dsbccxlt AS CHAR                                    NO-UNDO.
    DEF VAR aux_lsdigctr AS CHAR                                    NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados Pesquisa de Cheques Depositados".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-crapccs.
        EMPTY TEMP-TABLE tt-erro.

        IF  par_cddopcao <> "I" THEN
            DO:
        /* Validar o digito da conta */
        IF  NOT ValidaDigFun ( INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_nrdconta ) THEN
            DO:
                ASSIGN aux_cdcritic = 8
                       aux_dscritic = "".
                LEAVE Busca.
            END.
            END.

        FIND crapccs WHERE crapccs.cdcooper = par_cdcooper AND
                           crapccs.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF  par_cddopcao = "I" THEN
            DO:
                IF  AVAIL crapccs THEN
                DO:
                    ASSIGN aux_cdcritic = 330
                           aux_dscritic = "".
                    LEAVE Busca.
                END.

                /* Valida se ja existe uma conta crapass ao incluir uma conta
                   salario */
                IF CAN-FIND(crapass WHERE 
                            crapass.cdcooper = par_cdcooper AND
                            crapass.nrdconta = par_nrdconta) THEN
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Conta ja existente de cooperado.".

                LEAVE Busca.
            END.

        IF  NOT AVAIL crapccs THEN
            DO:
                ASSIGN aux_cdcritic = 564
                       aux_dscritic = "".
                LEAVE Busca.
            END.

        CREATE tt-crapccs.
        ASSIGN tt-crapccs.cdagenci = crapccs.cdagenci                       
               tt-crapccs.cdempres = crapccs.cdempres                       
               tt-crapccs.cdagetrf = crapccs.cdagetrf                       
               tt-crapccs.cdbantrf = crapccs.cdbantrf                       
               tt-crapccs.nrdigtrf = crapccs.nrdigtrf                       
               tt-crapccs.nrctatrf = crapccs.nrctatrf                       
               tt-crapccs.nrcpfcgc = crapccs.nrcpfcgc
               tt-crapccs.nmfuncio = crapccs.nmfuncio                       
               tt-crapccs.dtcantrf = crapccs.dtcantrf                       
               tt-crapccs.dtadmiss = crapccs.dtadmiss                       
               tt-crapccs.cdsitcta = IF   crapccs.cdsitcta = 1 THEN         
                                          "ATIVO"                           
                                     ELSE "CANCELADO"
               tt-crapccs.tpctatrf = crapccs.tpctatrf.                      

         FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                            crapage.cdagenci = tt-crapccs.cdagenci
                            USE-INDEX crapage1 NO-LOCK NO-ERROR.

         IF  NOT AVAILABLE crapage THEN
             DO:
                 ASSIGN aux_cdcritic = 962
                        aux_dscritic = "".
                 LEAVE Busca.
             END.

         FIND crapemp WHERE crapemp.cdcooper = par_cdcooper AND
                            crapemp.cdempres = tt-crapccs.cdempres NO-LOCK NO-ERROR.

         IF  NOT AVAILABLE crapemp THEN
             DO:
                 ASSIGN aux_cdcritic = 40
                        aux_dscritic = "".
                 LEAVE Busca.
             END.

         FIND crapban WHERE crapban.cdbccxlt = tt-crapccs.cdbantrf NO-LOCK NO-ERROR.

         IF  NOT AVAILABLE crapban THEN
             DO:
                 ASSIGN aux_cdcritic = 57
                        aux_dscritic = "".
                 LEAVE Busca.
             END.
                       
         /* Validar o campo cdagetrf apenas se o tpctatrf for 1 (conta corrente) ou 2 (poupanca)*/    
         IF crapccs.tpctatrf = 1 OR crapccs.tpctatrf = 2 THEN
             DO:
                 FIND crapagb WHERE crapagb.cddbanco = tt-crapccs.cdbantrf AND
                                    crapagb.cdageban = tt-crapccs.cdagetrf NO-LOCK NO-ERROR.
                 
                 IF  NOT AVAILABLE crapagb THEN
                     DO:
                         ASSIGN aux_cdcritic = 15
                                aux_dscritic = "".
                         LEAVE Busca.
                     END.
             END.

         IF  par_idorigem <> 5 THEN
             ASSIGN tt-crapccs.nmresage = " - " + crapage.nmresage
                    tt-crapccs.nmresemp = " - " + crapemp.nmresemp
                    tt-crapccs.dsbantrf = " - " + crapban.nmresbcc
                    tt-crapccs.dsagetrf = " - " + STRING(crapagb.nmageban,"x(29)").
         ELSE
             ASSIGN tt-crapccs.nmresage = crapage.nmresage
                    tt-crapccs.nmresemp = crapemp.nmresemp
                    tt-crapccs.dsbantrf = crapban.nmresbcc
                    tt-crapccs.dsagetrf = STRING(crapagb.nmageban,"x(29)").

         IF  crapccs.cdsitcta = 2 AND
             CAN-DO("A,S",par_cddopcao) THEN 
             ASSIGN aux_msgconfi = "Nao e possivel alterar. Conta cancelada.".

        LEAVE Busca.

    END. /* Busca */

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

            IF  par_flgerlog THEN
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

PROCEDURE Valida_Conta_Salario:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenca AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbantrf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagetrf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctatrf AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdigtrf AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.

    DEF VAR aux_nrctatrf AS CHAR    NO-UNDO.
    DEF VAR aux_stsnrcal AS LOGICAL NO-UNDO.
    DEF VAR aux_dsalerta AS CHAR    NO-UNDO.
    
Valida_CS: DO ON ERROR UNDO Valida_CS, LEAVE Valida_CS:




/* Bloquear a permissão de transferir da conta salário para a conta de mesmo CPF 
   na mesma cooperativa ou conta integração BB para a mesma cooperativa. */
/*
1. Alterar o programa CTASAL.p para não permitir que o banco (cdbantrf = 085) 
esteja preenchido com 085 e agência igual da mesma cooperativa atual (através 
do glb_cdcooper pesquisar crapcop.cdagectl = digitado na tela) e conta com o 
mesmo CPF da nova conta-salário (CPF atual = crapass.cdcpfcgc de conta ativa),
apresentar a mensagem “Somente pode ser transferido para conta com CPF 
diferente ou para outra cooperativa.” */

    IF  par_cdbantrf = 085 THEN
        DO: 

            FOR EACH crapcop WHERE crapcop.cdagectl = par_cdagetrf 
                NO-LOCK:
    
                /* Valida se a conta para transferencia esta encerrada  */
                FIND FIRST crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                                         crapass.nrdconta = par_nrctatrf
                                         NO-LOCK NO-ERROR.

                IF  AVAIL crapass THEN DO:

                    /** Validar diretamente no ORACLE */
                    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
                    RUN STORED-PROCEDURE pc_valida_lancto_folha aux_handproc = PROC-HANDLE
                       NO-ERROR (INPUT crapcop.cdcooper,
                                 INPUT crapass.nrdconta,
                                 INPUT crapass.nrcpfcgc,
                                 INPUT ?, /* dtcredit */
                                 INPUT 'C',
                                 OUTPUT "",
                                 OUTPUT "",
                                 OUTPUT "").

                    CLOSE STORED-PROC pc_valida_lancto_folha aux_statproc = PROC-STATUS
                        WHERE PROC-HANDLE = aux_handproc.

                    ASSIGN aux_dscritic = ""
                           aux_dscritic = pc_valida_lancto_folha.pr_dscritic WHEN pc_valida_lancto_folha.pr_dscritic <> ?
                           aux_dsalerta = pc_valida_lancto_folha.pr_dsalerta WHEN pc_valida_lancto_folha.pr_dsalerta <> ?. 

                    IF  aux_dscritic <> ""  THEN DO:
                        ASSIGN aux_cdcritic = 0
                               par_nmdcampo = "nrctatrf".
                        LEAVE Valida_CS.
                    END.
                    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

                    IF  aux_dsalerta <> ""  THEN DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = aux_dsalerta
                               par_nmdcampo = "nrctatrf".
                        LEAVE Valida_CS.
                    END.  
                END.
                ELSE
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Conta inexistente na cooperativa informada."
                               par_nmdcampo = "nrctatrf".
                        LEAVE Valida_CS.
                    END.
            END.

            FOR EACH crapcop WHERE crapcop.cdagectl = par_cdagetrf 
                                   NO-LOCK:

                FIND FIRST crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                                         crapass.nrcpfcgc = par_nrcpfcgc     AND
                                         crapass.dtdemiss = ?
                                         NO-LOCK NO-ERROR.
                IF  AVAIL crapass AND
                          crapass.cdcooper = par_cdcooper THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Somente pode ser transferido para conta" +
                                              " com CPF diferente ou para outra cooperativa."
                               par_nmdcampo = "cdagetrf".
                        LEAVE Valida_CS.
                    END.
            END.
        END.
/*
2. Não permitir também  que o banco (campo cdbantrf = 001) e agência 
integração da cooperativa atual (através do glb_cdcooper pesquisar 
crapcop.cdageitg = digitado na tela) e conta integração com o mesmo
CPF da nova conta salário (através da conta integração crapass.nrdctitg 
(integração ativa) pesquisar o CPF atual = crapass.cdcpfcgc de conta ativa), 
apresentar a mensagem “Somente pode ser transferido para conta integração com 
CPF diferente ou para outra cooperativa.” */
    IF  par_cdbantrf = 001 THEN
        DO: 
            FOR EACH crapcop WHERE crapcop.cdageitg = par_cdagetrf
                                   NO-LOCK:

                ASSIGN aux_nrctatrf = FILL("0", 7 - LENGTH(STRING(par_nrctatrf))) + STRING(par_nrctatrf).

                FIND FIRST crapass WHERE 
                                   crapass.cdcooper = crapcop.cdcooper AND
                                   crapass.nrdctitg = aux_nrctatrf + par_nrdigtrf AND
                                   crapass.dtdemiss = ?
                                   NO-LOCK NO-ERROR.

                IF  AVAIL crapass AND
                          (crapass.cdsitdct = 2 OR
                           crapass.cdsitdct = 3 OR
                           crapass.cdsitdct = 4 OR
                           crapass.cdsitdct = 5 OR
                           crapass.cdsitdct = 9) THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Conta para transferencia esta encerrada."
                               par_nmdcampo = "nrctatrf".
                        LEAVE Valida_CS.
                    END.

                IF  AVAIL crapass   AND
                          crapass.nrcpfcgc = par_nrcpfcgc AND
                          crapass.cdcooper = par_cdcooper THEN
                    DO:

                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Somente pode ser transferido para" +
                                              " conta integracao com CPF"         + 
                                              " diferente ou para outra cooperativa."
                               par_nmdcampo = "cdagetrf".
                        LEAVE Valida_CS.
                    END.
            END.
        END.
END. /* Valida_CS */

IF  aux_dscritic <> "" THEN
    DO:
        RETURN "NOK".
    END.

END PROCEDURE. /* fim Valida_Conta_Salario */


/* ------------------------------------------------------------------------ */
/*                 EFETUA A PESQUISA DE CHEQUES DEPOSITADOS                 */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenca AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbantrf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagetrf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctatrf AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdigtrf AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpctatrf AS INTE                           NO-UNDO.
	DEF  INPUT PARAM par_nmfuncio AS CHAR                           NO-UNDO.

    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dsbccxlt AS CHAR                                    NO-UNDO.
    DEF VAR aux_lsdigctr AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgdecpf AS LOGI                                    NO-UNDO.
    DEF VAR aux_stsnrcal AS LOGI                                    NO-UNDO.
    DEF VAR aux_inpessoa AS INTE                                    NO-UNDO. 
    
    DEFINE BUFFER crabcop FOR crapcop.
    DEFINE BUFFER crabass FOR crapass.
        
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados Pesquisa de Cheques Depositados".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.

        IF  par_cddopcao = "S" THEN
            DO:
                
                /* Validar o campo cdagetrf apenas se o tpctatrf for 1 (conta corrente) ou 2 (poupanca)*/    
                IF par_tpctatrf = 1 OR par_tpctatrf = 2 THEN
                    DO:
                        FIND crapagb WHERE crapagb.cddbanco = par_cdbantrf AND
                                           crapagb.cdageban = par_cdagetrf
                                           NO-LOCK NO-ERROR.

                        IF  NOT AVAIL crapagb THEN
                            DO:
                                ASSIGN aux_cdcritic = 15
                                       aux_dscritic = ""
                                       par_nmdcampo = "cdagetrf".
                                LEAVE Valida.
                            END.
                    END.
            
                RUN Valida_Conta_Salario(
                    INPUT par_cdcooper,
                    INPUT par_cdagenci,
                    INPUT par_nrdcaixa,
                    INPUT par_idorigem,
                    INPUT par_nrdconta,
                    INPUT par_cddopcao,
                    INPUT par_cdagenca,
                    INPUT par_cdempres,
                    INPUT par_cdbantrf,
                    INPUT par_cdagetrf,
                    INPUT par_nrctatrf,
                    INPUT par_nrdigtrf,
                    INPUT par_nrcpfcgc,
                    OUTPUT par_nmdcampo
                ).
    
                IF  RETURN-VALUE = "NOK" THEN
                LEAVE Valida.
            END.

        IF  CAN-DO("I,X",par_cddopcao) THEN
            DO:
                
                IF  par_cddopcao = "I" THEN
                    DO:
						IF par_nmfuncio = "" THEN
							DO:
								ASSIGN aux_cdcritic = 0
									   aux_dscritic = "Informe o titular."
									   par_nmdcampo = "nmfuncio".
								LEAVE Valida.
						   
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
                                ASSIGN aux_cdcritic = 27
                                       aux_dscritic = ""
                                       par_nmdcampo = "nrcpfcgc".
                                LEAVE Valida.
                            END.

                        IF  aux_inpessoa <> 1 THEN
                            DO: 
                                ASSIGN aux_cdcritic = 833
                                       aux_dscritic = ""
                                       par_nmdcampo = "nrcpfcgc".
                                LEAVE Valida.
                            END.

                        RUN Valida_Conta_Salario(
                            INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_idorigem,
                            INPUT par_nrdconta,
                            INPUT par_cddopcao,
                            INPUT par_cdagenca,
                            INPUT par_cdempres,
                            INPUT par_cdbantrf,
                            INPUT par_cdagetrf,
                            INPUT par_nrctatrf,
                            INPUT par_nrdigtrf,
                            INPUT par_nrcpfcgc,
                            OUTPUT par_nmdcampo
                        ).

                        IF  RETURN-VALUE = "NOK" THEN
                        LEAVE Valida.
                END.

                IF  par_cddopcao = "X" THEN
                    LEAVE Valida.

                /* Verifica se o CPF ja possui uma conta salario */
                FIND crapccs WHERE 
                     crapccs.cdcooper = par_cdcooper AND
                     crapccs.nrcpfcgc = par_nrcpfcgc NO-LOCK NO-ERROR.

                IF  AVAIL crapccs THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Este CPF ja esta associado a conta salario " +
                                              STRING(crapccs.nrdconta,"zzzz,zzz,z").
                               par_nmdcampo = "nrcpfcgc".
                        LEAVE Valida.
                    END.
                
            END. /* IF  par_cddopcao = "I" */

        FIND crapage WHERE 
             crapage.cdcooper = par_cdcooper AND
             crapage.cdagenci = par_cdagenca 
             USE-INDEX crapage1 NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapage THEN
            DO:
                ASSIGN aux_cdcritic = 962
                       aux_dscritic = ""
                       par_nmdcampo = "cdagenca".
                LEAVE Valida.
            END.


        /* Empresa */
        FIND FIRST crapemp WHERE 
                   crapemp.cdcooper = par_cdcooper AND
                   crapemp.cdempres = par_cdempres NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapemp THEN
            DO:
                ASSIGN aux_cdcritic = 40
                       aux_dscritic = ""
                       par_nmdcampo = "cdempres".
                LEAVE Valida.
            END.

        IF  CAN-DO("A,I",par_cddopcao) THEN
            DO:
				IF par_nmfuncio = "" THEN
					DO:
						ASSIGN aux_cdcritic = 0
							   aux_dscritic = "Informe o titular."
							   par_nmdcampo = "nmfuncio".
						LEAVE Valida.
				   
					END.
					
                FIND crapban WHERE 
                     crapban.cdbccxlt = par_cdbantrf NO-LOCK NO-ERROR.

                IF  NOT AVAIL crapban THEN
                    DO:
                        ASSIGN aux_cdcritic = 57
                               aux_dscritic = ""
                               par_nmdcampo = "cdbantrf".
                        LEAVE Valida.
                        
                    END.
                    
                /* Validar o campo cdagetrf apenas se o tpctatrf for 1 (conta corrente) ou 2 (poupanca)*/    
                IF par_tpctatrf = 1 OR par_tpctatrf = 2 THEN
                    DO:
                        FIND crapagb WHERE crapagb.cddbanco = par_cdbantrf AND
                                           crapagb.cdageban = par_cdagetrf
                                           NO-LOCK NO-ERROR.

                        IF  NOT AVAIL crapagb THEN
                            DO:
                                ASSIGN aux_cdcritic = 15
                                       aux_dscritic = ""
                                       par_nmdcampo = "cdagetrf".
                                LEAVE Valida.
                            END.
                    END.    

                IF  par_cdbantrf = 85 THEN DO:

                    FIND crabcop WHERE 
                         crabcop.cdagectl = par_cdagetrf NO-LOCK NO-ERROR.

                    FIND crabass WHERE 
                         crabass.cdcooper = crabcop.cdcooper AND
                         crabass.nrdconta = par_nrctatrf NO-LOCK NO-ERROR.

                    IF  NOT AVAIL crabass THEN
                        DO:
                            ASSIGN aux_cdcritic = 9
                                   aux_dscritic = ""
                                   par_nmdcampo = "nrctatrf".
                            LEAVE Valida.
                        END.     

                        ASSIGN aux_flgdecpf = NO.

                        FOR EACH crapttl WHERE 
                                 crapttl.cdcooper = crabcop.cdcooper AND
                                 crapttl.nrdconta = par_nrctatrf NO-LOCK:

                            IF  crapttl.nrcpfcgc = par_nrcpfcgc THEN
                                ASSIGN aux_flgdecpf = TRUE.
                        END.

                        IF  NOT aux_flgdecpf THEN
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "CPF de destino nao confere com o remetente."
                                       par_nmdcampo = "nrctatrf".
                                LEAVE Valida.
                            END.

                END. /* IF  par_cdbantrf = 85 */

            END. /* IF  par_cddopcao = "I" */

        LEAVE Valida.

    END. /* Valida */

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
    
    RETURN aux_returnvl.

END PROCEDURE. /* Valida_Dados */

	
PROCEDURE Gera_arquivo_log:
	DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
	DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
	DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
	DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
	DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
	DEF  INPUT PARAM par_campolog AS CHAR                           NO-UNDO.
	DEF  INPUT PARAM par_valornov AS CHAR                           NO-UNDO.
	DEF  INPUT PARAM par_valorvel AS CHAR                           NO-UNDO.
	
	
	DEF VAR aux_dsdircop AS CHAR FORMAT "x(20)" 					NO-UNDO.
	
	FOR FIRST crapcop FIELD(crapcop.dsdircop) 
        WHERE crapcop.cdcooper = par_cdcooper NO-LOCK:
        ASSIGN aux_dsdircop = crapcop.dsdircop.
    END.
	
	CASE par_cddopcao:
		WHEN "I" THEN DO:
			UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt, "99/99/9999") + " " +
							  STRING(TIME,"HH:MM:SS") + "' --> '" + 
							  " Operador " + par_cdoperad  +
							  " incluiu  o campo " + "'" + par_campolog + "'" + 
							  " com o valor " + "'" + par_valornov + "'" + 
							  " na empresa " + STRING(par_cdempres)  + 
							  " >> /usr/coop/"   + 
							  aux_dsdircop       +
							  "/log/ctasal.log").
		END.
		WHEN "A" THEN DO:
			UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt, "99/99/9999") + " " +
							  STRING(TIME,"HH:MM:SS") + "' --> '" + 
							  " Operador " + par_cdoperad  +
							  " alterou  o campo "  +  "'" + par_campolog  + "'" +
							  " de " + "'" + par_valorvel + "'" + "  para   " + "'" +
							  par_valornov + "'" + " na empresa " + STRING(par_cdempres)  + 
							  " >> /usr/coop/"   + 
							  aux_dsdircop       +  
							  "/log/ctasal.log").
		END.
		WHEN "E" THEN DO:
			UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt, "99/99/9999") + " " +
							  STRING(TIME,"HH:MM:SS") + "' --> '" + 
							  " Operador " + par_cdoperad  +
							  " excluiu a empresa " + STRING(par_cdempres)  + 
							  " >> /usr/coop/"   + 
							  aux_dsdircop       +  
							  "/log/ctasal.log").
		END.
		WHEN "S" THEN DO:
			UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt, "99/99/9999") + " " +
							  STRING(TIME,"HH:MM:SS") + "' --> '" + 
							  " Operador " + par_cdoperad  +
							  " alterou  o campo "  +  "'" + par_campolog  + "'" +
							  " de " + "'" + par_valorvel + "'" + "  para   " + "'" +
							  par_valornov + "'" + " na empresa " + STRING(par_cdempres)  + 
							  " >> /usr/coop/"   + 
							  aux_dsdircop       +  
							  "/log/ctasal.log").
		END.
		WHEN "X" THEN DO:
			UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt, "99/99/9999") + " " +
							  STRING(TIME,"HH:MM:SS") + "' --> '" + 
							  " Operador " + par_cdoperad  +
							  " reativou a empresa " + STRING(par_cdempres)  + 
							  " >> /usr/coop/"   + 
							  aux_dsdircop       +  
							  "/log/ctasal.log").
		END.
	END CASE.		
	

END PROCEDURE.

/* ------------------------------------------------------------------------- */
/*               REALIZA A GRAVACAO DOS DADOS DA OPCAO TITULAR               */
/* ------------------------------------------------------------------------- */
PROCEDURE Grava_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenca AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmfuncio AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagetrf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbantrf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdigtrf AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrctatrf AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpctatrf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_dtcantrf AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM aux_dtadmiss AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM aux_cdsitcta AS CHAR                           NO-UNDO.
	DEF OUTPUT PARAM aux_nrdconrt LIKE crapass.nrdconta 			NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR h-b1wgen0052 AS HANDLE                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Grava Manutencao do CCF - Titular"
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_idorigem = par_idorigem.

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        IF  par_cddopcao = "I" THEN DO:

            RUN sistema/generico/procedures/b1wgen0052.p PERSISTENT SET h-b1wgen0052.
             
            RUN Retorna_Conta IN h-b1wgen0052 (INPUT par_cdcooper,
                                               INPUT par_idorigem,
                                              OUTPUT aux_nrdconrt).
                   
            DELETE PROCEDURE h-b1wgen0052.
              
            IF  aux_nrdconrt <= 0  THEN
                DO:
                  ASSIGN aux_cdcritic = 0
                         aux_dscritic = "Nao foi possivel gerar numero de conta".
                          
                  LEAVE Grava.
                END.

            CREATE crapccs.
            ASSIGN crapccs.cdagenci = par_cdagenca
                   crapccs.cdempres = par_cdempres
                   crapccs.cdagetrf = par_cdagetrf
                   crapccs.cdbantrf = par_cdbantrf
                   crapccs.cdcooper = par_cdcooper
                   crapccs.cdopeadm = par_cdoperad
                   crapccs.cdopecan = ""
                   crapccs.nrdigtrf = par_nrdigtrf
                   crapccs.nrdconta = aux_nrdconrt
                   crapccs.nrctatrf = par_nrctatrf
                   crapccs.nrcpfcgc = par_nrcpfcgc
                   crapccs.nmfuncio = par_nmfuncio
                   crapccs.dtcantrf = ?
                   crapccs.cdsitcta = 1
                   crapccs.dtadmiss = par_dtmvtolt
                   crapccs.tpctatrf = par_tpctatrf.
            VALIDATE crapccs.

			RUN Gera_arquivo_log(INPUT par_cdcooper
			                    ,INPUT par_cddopcao
			                    ,INPUT par_cdoperad
			                    ,INPUT par_cdempres
								,INPUT par_dtmvtolt
			                    ,INPUT "cdagenca"
			                    ,INPUT par_cdagenca
			                    ,INPUT "").
			
            RUN Gera_arquivo_log(INPUT par_cdcooper
			                    ,INPUT par_cddopcao
			                    ,INPUT par_cdoperad
			                    ,INPUT par_cdempres
								,INPUT par_dtmvtolt
			                    ,INPUT "cdempres"
			                    ,INPUT par_cdempres
			                    ,INPUT "").
								 
			RUN Gera_arquivo_log(INPUT par_cdcooper
								,INPUT par_cddopcao
								,INPUT par_cdoperad
								,INPUT par_cdempres
								,INPUT par_dtmvtolt
								,INPUT "cdagetrf"
								,INPUT par_cdagetrf
								,INPUT "").			
								 
			RUN Gera_arquivo_log(INPUT par_cdcooper
								,INPUT par_cddopcao
								,INPUT par_cdoperad
								,INPUT par_cdempres
								,INPUT par_dtmvtolt
								,INPUT "cdbantrf"
								,INPUT par_cdbantrf
								,INPUT "").
			
			RUN Gera_arquivo_log(INPUT par_cdcooper
								,INPUT par_cddopcao
								,INPUT par_cdoperad
								,INPUT par_cdempres
								,INPUT par_dtmvtolt
								,INPUT "nrdigtrf"
								,INPUT par_nrdigtrf
								,INPUT "").
								
			RUN Gera_arquivo_log(INPUT par_cdcooper
								,INPUT par_cddopcao
								,INPUT par_cdoperad
								,INPUT par_cdempres
								,INPUT par_dtmvtolt
								,INPUT "nrdconrt"
								,INPUT aux_nrdconrt
								,INPUT "").
			
			RUN Gera_arquivo_log(INPUT par_cdcooper
								,INPUT par_cddopcao
								,INPUT par_cdoperad
								,INPUT par_cdempres
								,INPUT par_dtmvtolt
								,INPUT "nrcpfcgc"
								,INPUT par_nrcpfcgc
								,INPUT "").
			
			RUN Gera_arquivo_log(INPUT par_cdcooper
								,INPUT par_cddopcao
								,INPUT par_cdoperad
								,INPUT par_cdempres
								,INPUT par_dtmvtolt
								,INPUT "nmfuncio"
								,INPUT par_nmfuncio
								,INPUT "").
			
			RUN Gera_arquivo_log(INPUT par_cdcooper
								,INPUT par_cddopcao
								,INPUT par_cdoperad
								,INPUT par_cdempres
								,INPUT par_dtmvtolt
								,INPUT "dtmvtolt"
								,INPUT par_dtmvtolt
								,INPUT "").
			
			RUN Gera_arquivo_log(INPUT par_cdcooper
								,INPUT par_cddopcao
								,INPUT par_cdoperad
								,INPUT par_cdempres
								,INPUT par_dtmvtolt
								,INPUT "tpctatrf"
								,INPUT par_tpctatrf
								,INPUT "").
			
            LEAVE Grava.

        END.

        Contador: DO aux_contador = 1 TO 10:

            FIND crapccs WHERE crapccs.cdcooper = par_cdcooper  AND
                               crapccs.nrdconta = par_nrdconta 
                               EXCLUSIVE-LOCK NO-ERROR.

            IF  NOT AVAIL crapccs THEN
                DO:
                    IF  LOCKED(crapccs)   THEN
                        DO:
                            IF  aux_contador = 10 THEN
                                DO:
                                    ASSIGN aux_cdcritic = 72.
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
                            ASSIGN aux_cdcritic = 9.
                            LEAVE Contador.
                        END.
                END.
            ELSE
                LEAVE Contador.
                
        END. /* Contador */

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        CASE par_cddopcao:
            WHEN "A" THEN DO:
        
				IF crapccs.nmfuncio <> par_nmfuncio THEN
					DO:
						RUN Gera_arquivo_log(INPUT par_cdcooper
											,INPUT par_cddopcao
											,INPUT par_cdoperad
											,INPUT crapccs.cdempres
											,INPUT par_dtmvtolt
											,INPUT "nmfuncio"
											,INPUT par_nmfuncio
											,INPUT crapccs.nmfuncio).								
					END.
				
				IF crapccs.cdagenci <> par_cdagenca THEN
					DO:
						RUN Gera_arquivo_log(INPUT par_cdcooper
											,INPUT par_cddopcao
											,INPUT par_cdoperad
											,INPUT crapccs.cdempres
											,INPUT par_dtmvtolt
											,INPUT "cdagenca"
											,INPUT par_cdagenca
											,INPUT crapccs.cdagenci).								
					END.
				
				IF crapccs.cdempres <> par_cdempres THEN
					DO:
						RUN Gera_arquivo_log(INPUT par_cdcooper
											,INPUT par_cddopcao
											,INPUT par_cdoperad
											,INPUT crapccs.cdempres
											,INPUT par_dtmvtolt
											,INPUT "cdempres"
											,INPUT par_cdempres
											,INPUT crapccs.cdempres).								
					END.
				
                ASSIGN crapccs.nmfuncio = par_nmfuncio
                       crapccs.cdagenci = par_cdagenca.
                       crapccs.cdempres = par_cdempres.

            END. /* par_cddopcao = A */

            WHEN "E" THEN DO:
			
				RUN Gera_arquivo_log(INPUT par_cdcooper
									,INPUT par_cddopcao
									,INPUT par_cdoperad
									,INPUT par_cdempres
									,INPUT par_dtmvtolt
									,INPUT ""
									,INPUT ""
									,INPUT "").
											
                ASSIGN crapccs.cdsitcta = 2
                       crapccs.dtcantrf = par_dtmvtolt
                       crapccs.cdopecan = par_cdoperad
                       aux_dtcantrf     = par_dtmvtolt
                       aux_cdsitcta     = "CANCELADO".

            END. /* par_cddopcao = E */

            WHEN "S" THEN DO:
			
				IF crapccs.cdbantrf <> par_cdbantrf THEN
					DO:
						RUN Gera_arquivo_log(INPUT par_cdcooper
											,INPUT par_cddopcao
											,INPUT par_cdoperad
											,INPUT par_cdempres
											,INPUT par_dtmvtolt
											,INPUT "cdbantrf"
											,INPUT par_cdbantrf
											,INPUT crapccs.cdbantrf).								
					END.
				
				IF crapccs.cdagetrf <> par_cdagetrf THEN
					DO:
						RUN Gera_arquivo_log(INPUT par_cdcooper
											,INPUT par_cddopcao
											,INPUT par_cdoperad
											,INPUT par_cdempres
											,INPUT par_dtmvtolt
											,INPUT "cdagetrf"
											,INPUT par_cdagetrf
											,INPUT crapccs.cdagetrf).								
					END.
				
				IF crapccs.nrctatrf <> par_nrctatrf THEN
					DO:
						RUN Gera_arquivo_log(INPUT par_cdcooper
											,INPUT par_cddopcao
											,INPUT par_cdoperad
											,INPUT par_cdempres
											,INPUT par_dtmvtolt
											,INPUT "nrctatrf"
											,INPUT par_nrctatrf
											,INPUT crapccs.nrctatrf).								
					END.
					
				IF crapccs.nrdigtrf <> par_nrdigtrf THEN
					DO:
						RUN Gera_arquivo_log(INPUT par_cdcooper
											,INPUT par_cddopcao
											,INPUT par_cdoperad
											,INPUT par_cdempres
											,INPUT par_dtmvtolt
											,INPUT "nrdigtrf"
											,INPUT par_nrdigtrf
											,INPUT crapccs.nrdigtrf).								
					END.
				
				IF crapccs.tpctatrf <> par_tpctatrf THEN
					DO:
						RUN Gera_arquivo_log(INPUT par_cdcooper
											,INPUT par_cddopcao
											,INPUT par_cdoperad
											,INPUT par_cdempres
											,INPUT par_dtmvtolt
											,INPUT "tpctatrf"
											,INPUT par_tpctatrf
											,INPUT crapccs.tpctatrf).								
					END.
				
                ASSIGN crapccs.cdbantrf = par_cdbantrf
                       crapccs.cdagetrf = par_cdagetrf
                       crapccs.nrctatrf = par_nrctatrf
                       crapccs.nrdigtrf = par_nrdigtrf
                       crapccs.tpctatrf = par_tpctatrf.

            END. /* par_cddopcao = S */

            WHEN "X" THEN DO:
			
				RUN Gera_arquivo_log(INPUT par_cdcooper
									,INPUT par_cddopcao
									,INPUT par_cdoperad
									,INPUT par_cdempres
									,INPUT par_dtmvtolt
									,INPUT ""
									,INPUT ""
									,INPUT "").
									
                ASSIGN crapccs.cdsitcta = 1
                       crapccs.dtcantrf = ?
                       crapccs.cdopecan = ""
                       crapccs.dtadmiss = par_dtmvtolt
                       crapccs.cdopeadm = par_cdoperad
                       aux_dtadmiss     = par_dtmvtolt
                       aux_dtcantrf     = ?
                       aux_cdsitcta     = "ATIVO".

            END. /* par_cddopcao = S */

        END CASE.

        LEAVE Grava.

    END. /* Grava */
    
    ASSIGN aux_returnvl = "OK".

    IF  aux_dscritic <> "" OR 
        aux_cdcritic <> 0  THEN
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
        DO:        
            IF TEMP-TABLE tt-erro:HAS-RECORDS THEN
                ASSIGN aux_returnvl = "NOK".
                
        END.

    RETURN aux_returnvl.

END PROCEDURE. /* Grava_Dados */

/* ------------------------------------------------------------------------- */
/*                           GERA IMPRESSÃO DAS CARTAS                       */
/* ------------------------------------------------------------------------- */
PROCEDURE Gera_Impressao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenca AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbantrf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagetrf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgsolic AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_tpctatrf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR rel_nrcpfcgc AS CHAR    FORMAT "x(18)"                  NO-UNDO.
    DEF VAR rel_nmextemp AS CHAR                                    NO-UNDO.
    DEF VAR rel_nmresage AS CHAR                                    NO-UNDO.
    DEF VAR rel_nmbanco1 AS CHAR                                    NO-UNDO.
    DEF VAR rel_nrctatrf AS CHAR                                    NO-UNDO.
    DEF VAR rel_dsmvtolt AS CHAR                                    NO-UNDO.
    DEF VAR rel_nmoperad AS CHAR                                    NO-UNDO.
    DEF VAR rel_nmextcop AS CHAR    FORMAT "x(50)"                  NO-UNDO.
    DEF VAR rel_datahora AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsmesref AS CHAR                                    NO-UNDO.
    
    FORM SKIP(2)
         crapcop.nmextcop   FORMAT "x(50)" NO-LABEL 
         SKIP(3)
         "T E R M O    D E    S O L I C I T A C A O" AT 23
         SKIP(3)
         "Eu, "              
         crapccs.nmfuncio   FORMAT "x(40)"
         ",   CPF   no  "   
         rel_nrcpfcgc       FORMAT "x(14)"
         " ,"              
         SKIP
         "solicito, nos termos da Resolucao no 3.402/06"  
         " do  Banco  Central  do  Brasil,"                   
         SKIP
         "que  o  valor  total  das  verbas  salariais  que" 
         " vierem  a  ser   creditados"                      
         SKIP
         "pela Empresa"    
         rel_nmextemp       FORMAT "x(35)"
         "em  minha  Conta  Salario  no" 
         SKIP
         crapccs.nrdconta   FORMAT "zzzz,zzz,9"
         ",mantida junto a" 
         rel_nmextcop       FORMAT "x(49)"
         ","
         SKIP
         "seja transferido,de forma permanente, ao"  
         rel_nmbanco1       FORMAT "x(35)"
         ","
         SKIP
         "Agencia "         
         crapccs.cdagetrf   FORMAT "z,zz9"
         ", Conta-Corrente no"
         rel_nrctatrf       FORMAT "x(20)"
         "da qual sou titular." 
         SKIP(3)
         WITH COLUMN 3 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_solicitacao.    
    
    FORM SKIP(2)
         crapcop.nmextcop   FORMAT "x(50)" NO-LABEL 
         SKIP(3)
      "T E R M O    D E   C A N C E L A M E N T O    D A    S O L I C I T A C A O"
         AT 05
         SKIP(3)
         "Eu, "              
         crapccs.nmfuncio   FORMAT "x(40)"
         ",   CPF   no  "    
         rel_nrcpfcgc       FORMAT "x(14)"
         " ,"                
         SKIP
         "solicito, a partir desta data, o" 
         "cancelamento das  transferencias  que  vinham" 
         SKIP
         "sendo efetuadas da minha Conta Salario no" 
         crapccs.nrdconta   FORMAT "zzzz,zzz,9"
         ",  mantida  junto  a  esta" 
         SKIP
         "cooperativa ,  para  o " 
         rel_nmbanco1       FORMAT "x(35)"
         ",  Agencia" crapccs.cdagetrf   FORMAT "z,zz9"
         "," 
         "Conta-Corrente" 
         rel_nrctatrf       FORMAT "x(20)"
         ", tambem de minha  titularidade, quando do"
         SKIP
         "credito das verbas salariais pela Empresa " 
         rel_nmextemp       FORMAT "x(35)"
         SKIP 
         "na forma da Resolucao no 3.402/06 do Banco Central do Brasil."      
         SKIP(3)
         WITH COLUMN 3 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_cancelamento.
    
    FORM SKIP(2)
         rel_dsmvtolt     FORMAT "x(45)" NO-LABEL AT 04
         SKIP(3)
         "TITULAR"                                AT 04
         "OPERADOR"                               AT 45
         SKIP(5)
         "------------------------------------"   AT 04
         "------------------------------------"   AT 45
         SKIP
         crapccs.nmfuncio FORMAT "x(36)" NO-LABEL AT 04
         rel_nmoperad     FORMAT "x(36)" NO-LABEL AT 45
         SKIP
         crapccs.nrdconta LABEL "Conta/dv"        AT 04
         rel_datahora     FORMAT "x(33)" NO-LABEL AT 45            
         SKIP(3)
         WITH COLUMN 1 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_assinar.
    
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados Manutencao do CCF".
     
    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crapcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser.
        
        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        FIND crapccs WHERE crapccs.cdcooper = par_cdcooper AND
                           crapccs.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapccs THEN
            DO:
                ASSIGN aux_cdcritic = 564
                       aux_dscritic = "".
            END.

        FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                           crapage.cdagenci = par_cdagenca
                           USE-INDEX crapage1 NO-LOCK NO-ERROR.

         IF  NOT AVAILABLE crapage THEN
             DO:
                 ASSIGN aux_cdcritic = 962
                        aux_dscritic = "".
             END.

         FIND crapemp WHERE crapemp.cdcooper = par_cdcooper AND
                            crapemp.cdempres = par_cdempres NO-LOCK NO-ERROR.

         IF  NOT AVAILABLE crapemp THEN
             DO:
                 ASSIGN aux_cdcritic = 40
                        aux_dscritic = "".
             END.

         FIND crapban WHERE crapban.cdbccxlt = par_cdbantrf NO-LOCK NO-ERROR.

         IF  NOT AVAILABLE crapban THEN
             DO:
                 ASSIGN aux_cdcritic = 57
                        aux_dscritic = "".
             END.
             
         /* Validar o campo cdagetrf apenas se o tpctatrf for 1 (conta corrente) ou 2 (poupanca)*/    
         IF par_tpctatrf = 1 OR par_tpctatrf = 2 THEN
             DO:
                 FIND crapagb WHERE crapagb.cddbanco = par_cdbantrf AND
                                    crapagb.cdageban = par_cdagetrf NO-LOCK NO-ERROR.

                 IF  NOT AVAILABLE crapagb THEN
                     DO:
                         ASSIGN aux_cdcritic = 15
                                aux_dscritic = "".
                     END.
             END.    
		 
         ASSIGN aux_dsmesref = "JANEIRO,FEVEREIRO,MARCO,ABRIL,MAIO,JUNHO," +
                        "JULHO,AGOSTO,SETEMBRO,OUTUBRO,NOVEMBRO,DEZEMBRO"
				
                rel_nrcpfcgc = STRING(STRING(crapccs.nrcpfcgc,
                                                "99999999999"),"999.999.999-99")
                rel_nrctatrf = STRING(crapccs.nrctatrf,"zz,zzz,zzz,zzz,9") 
                
                rel_nrctatrf = IF    crapccs.nrdigtrf <> ""   THEN
                                     rel_nrctatrf + " - " +  
                                     STRING(crapccs.nrdigtrf,"9")
                               ELSE 
                                     rel_nrctatrf
                
                rel_dsmvtolt = CAPS(TRIM(crapcop.nmcidade) 
                               + ", "  +  
                               STRING(DAY(par_dtmvtolt),"99") 
                               +  " DE " +
                               STRING(ENTRY(MONTH(par_dtmvtolt),aux_dsmesref),"x(9)") 
                               + " DE " +
                               STRING(YEAR(par_dtmvtolt),"9999") + ".")
                rel_nmresage = IF   AVAILABLE crapage THEN 
                                    STRING(crapage.cdagenci,"999") + " - " +
                                    crapage.nmextage
                               ELSE 
                                    " PA Nao Cadastrado"
                rel_nmextemp = IF   AVAILABLE crapemp THEN 
                                    crapemp.nmextemp
                               ELSE 
                                    " Empresa Nao Cadastrada"
                rel_nmbanco1 = IF   AVAILABLE crapban THEN 
                                    crapban.nmextbcc
                               ELSE 
                                    " Banco Nao Cadastrado"
                rel_nmextcop = crapcop.nmextcop
                rel_datahora = "Data: " + STRING(par_dtmvtolt,"99/99/99")  +
                               "  Hora: " + STRING(TIME,"HH:MM:SS").

         FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                            crapope.cdoperad = par_cdoperad
                            NO-LOCK NO-ERROR.

         IF  NOT AVAILABLE crapope THEN
             ASSIGN rel_nmoperad = STRING(par_cdoperad,"x(10)") + " - NAO ENCONTRADO!".
         ELSE
             ASSIGN rel_nmoperad = STRING(par_cdoperad) + " - " + TRIM(crapope.nmoperad).
        
        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84 APPEND.
  
        PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
                 
        PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
        
        IF  par_flgsolic THEN
            DO:
                DISPLAY STREAM str_1  crapcop.nmextcop   crapccs.nmfuncio   
                                      rel_nrcpfcgc       rel_nmextemp       
                                      crapccs.nrdconta   rel_nmextcop
                                      rel_nmbanco1       rel_nmbanco1       
                                      crapccs.cdagetrf   rel_nrctatrf       
                                      WITH FRAME f_solicitacao.
                 
                DOWN STREAM str_1 WITH FRAME f_solicitacao.
            END.                          
        ELSE 
            DO:
                DISPLAY STREAM str_1  crapcop.nmextcop   crapccs.nmfuncio   
                                      rel_nrcpfcgc       crapccs.nrdconta   
                                      rel_nmbanco1       crapccs.cdagetrf
                                      rel_nrctatrf       rel_nmextemp       
                                      WITH FRAME f_cancelamento.
        
                DOWN STREAM str_1 WITH FRAME f_cancelamento.
            END.        

        DISPLAY STREAM str_1  rel_dsmvtolt   crapccs.nmfuncio   
                              rel_nmoperad   crapccs.nrdconta   
                              rel_dsmvtolt   rel_datahora
                              WITH FRAME f_assinar.
        
        DOWN STREAM str_1 WITH FRAME f_assinar.

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

            IF  par_flgerlog THEN
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

END PROCEDURE. /* Gera_Impressao */

/* ------------------------------------------------------------------------ */
/*                 EFETUA A PESQUISA DE CHEQUES DEPOSITADOS                 */
/* ------------------------------------------------------------------------ */
PROCEDURE Pesquisa_Nome:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-crapccs.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-crapccs.
        EMPTY TEMP-TABLE tt-erro.

        IF  TRIM(par_nmprimtl) = "" THEN
            ASSIGN par_nmprimtl = "* *".
        ELSE
            ASSIGN par_nmprimtl = "*" + CAPS(TRIM(par_nmprimtl)) + "*".

        FOR EACH crapccs WHERE 
                 crapccs.cdcooper = par_cdcooper AND
                 crapccs.nmfuncio MATCHES par_nmprimtl NO-LOCK:
            CREATE tt-crapccs.
            ASSIGN tt-crapccs.nrdconta = crapccs.nrdconta
                   tt-crapccs.nmfuncio = crapccs.nmfuncio.
        END.

        LEAVE Busca.

    END. /* Busca */

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
    
    RETURN aux_returnvl.

END PROCEDURE. /* Pesquisa_Nome */


/*.............................. PROCEDURES (FIM) ...........................*/

/*................................ FUNCTIONS ................................*/

FUNCTION ValidaDigFun RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_cdagenci AS INTEGER,
      INPUT par_nrdcaixa AS INTEGER,
      INPUT par_nrdconta AS INTEGER ):
/*-----------------------------------------------------------------------------
  Objetivo:  Valida o digita verificador
     Notas:  
-----------------------------------------------------------------------------*/

    DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE aux_nrdconta AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE aux_vlresult AS LOGICAL     NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

    ASSIGN 
        aux_nrdconta = par_nrdconta
        aux_vlresult = TRUE.

    RUN dig_fun IN h-b1wgen9999 
        ( INPUT par_cdcooper,
          INPUT par_cdagenci,
          INPUT par_nrdcaixa,
          INPUT-OUTPUT aux_nrdconta,
         OUTPUT TABLE tt-erro ).
    
    DELETE OBJECT h-b1wgen9999.

    /* verifica se o digito foi informado corretamente */
    IF  RETURN-VALUE <> "OK" THEN
        ASSIGN aux_vlresult = FALSE.

    FIND FIRST tt-erro NO-ERROR.

    IF  AVAILABLE tt-erro THEN
        ASSIGN aux_vlresult = FALSE.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_nrdconta <> par_nrdconta THEN
        ASSIGN aux_vlresult = FALSE.

   RETURN aux_vlresult.
        
END FUNCTION.
