/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +----------------------------------------+--------------------------------------------------+
  | Rotina Progress                        | Rotina Oracle PLSQL                              |
  +----------------------------------------+--------------------------------------------------+
  | b1wgen0145.p                           | AVAL0001                                         |
  | Busca_Dados                            | AVAL0001.pc_busca_dados_contratos                |
  | Busca_Avalista                         | AVAL0001.pc_busca_dados_avalista                 |
  +----------------------------------------+--------------------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/


/*....................................................................................

    Programa: sistema/generico/procedures/b1wgen0145.p
    Autor   : Gabriel Capoia (DB1)
    Data    : 20/12/2012                     Ultima atualizacao: 06/05/2014

    Objetivo  : Tranformacao BO tela AVALIS.

    Alteracoes: 19/08/2013 - Inserido tratamento para preencher 2 ou mais 
                             caracteres no campo de nome do avalista (Jéssica DB1)
    
                07/03/2014 - Ajuste em proc. Busca_Dados, adicionado param
                             aux_regexist em condicao cpf/cnpj. (Jorge)
                             
                06/05/2014 - Removido a validação crapepr.inprejuz = 0
                             em proc. Busca_Dados (Douglas Quisinski)             
    
......................................................................................*/

/*............................. DEFINICOES ...........................................*/
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0145tt.i }
{ sistema/generico/includes/b1wgen0030tt.i }          
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                        NO-UNDO.
DEF VAR aux_idorigem AS INTE                                        NO-UNDO.
DEF VAR h-b1wgen0002 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                      NO-UNDO.

DEF VAR epr_nrctremp AS INTE                                        NO-UNDO.
DEF VAR epr_cdpesqui AS CHAR                                        NO-UNDO.
DEF VAR epr_nrdconta AS INTE                                        NO-UNDO.
DEF VAR epr_nmprimtl AS CHAR                                        NO-UNDO.
DEF VAR epr_vldivida AS CHAR                                        NO-UNDO.
DEF VAR epr_tpdcontr AS CHAR                                        NO-UNDO.

FUNCTION ValidaDigFun RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_cdagenci AS INTEGER,
      INPUT par_nrdcaixa AS INTEGER,
      INPUT par_nrdconta AS INTEGER ) FORWARD.

/*................................ PROCEDURES ..............................*/
/* ------------------------------------------------------------------------ */
/*                EFETUA A CONSULTA DOS CONTRATOS AVALIZADOS                */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_nmprimtl AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_nrdconta AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM aux_nrcpfcgc AS DECI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-contras.
    DEF OUTPUT PARAM TABLE FOR tt-msgconta.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabass FOR crapass.

    DEF VAR aux_regexist AS LOGI                                    NO-UNDO.
    DEF VAR aux_vlsdeved AS DECI                                    NO-UNDO.
    DEF VAR aux_vltotpre AS DECI                                    NO-UNDO.
    DEF VAR aux_qtprecal AS INTE                                    NO-UNDO.
    DEF VAR aux_tpctrlim AS INTE                                    NO-UNDO. 
    DEF VAR aux_vldscchq AS DECI                                    NO-UNDO. 
    DEF VAR aux_vldsctit AS DECI                                    NO-UNDO. 
    DEF VAR aux_stsnrcal AS LOGI                                    NO-UNDO.
    DEF VAR aux_inpessoa AS INTE                                    NO-UNDO. 

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados Pesquisa de Contratos Avalizados"
           aux_nrdconta = par_nrdconta
           aux_nrcpfcgc = par_nrcpfcgc
           aux_nmprimtl = " "
           par_nmdcampo = "nrdconta".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-contras.
        EMPTY TEMP-TABLE tt-msgconta.
        EMPTY TEMP-TABLE w_contas.
        EMPTY TEMP-TABLE tt-erro.

        IF  par_nrdconta = 0 AND
            par_nrcpfcgc = 0 THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Informe Conta ou CPF"
                       par_nmdcampo = "nrdconta".
                LEAVE Busca.
            END.
        
        IF  par_nrdconta > 0 THEN DO:
            
            /* Validar o digito da conta */
            IF  NOT ValidaDigFun ( INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_nrdconta ) THEN
                DO:
                    ASSIGN aux_cdcritic = 8
                           aux_dscritic = ""
                           par_nmdcampo = "nrdconta".
                    LEAVE Busca.
                END.

        END. /* IF  par_nrdconta > 0 */

        IF par_nrcpfcgc > 0 THEN DO:

            FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                                     crapass.nrcpfcgc = par_nrcpfcgc AND
                                     crapass.dtdemiss = ? NO-LOCK NO-ERROR.

            IF  AVAIL crapass THEN
                 ASSIGN aux_nrdconta = crapass.nrdconta.
            ELSE ASSIGN aux_nrdconta = 0.

        END. /* IF par_nrcpfcgc > 0 */

        IF  NOT VALID-HANDLE(h-b1wgen0002) THEN
            RUN sistema/generico/procedures/b1wgen0002.p
                PERSISTENT SET h-b1wgen0002.

        IF  aux_nrdconta > 0 THEN DO:

            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                               crapass.nrdconta = aux_nrdconta 
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapass THEN
                DO:
                    ASSIGN aux_cdcritic = 9
                           aux_dscritic = ""
                           par_nmdcampo = "nrdconta".
                    LEAVE Busca.
                END.

            FOR EACH crabass WHERE 
                     crabass.cdcooper = par_cdcooper     AND
                     crabass.nrcpfcgc = crapass.nrcpfcgc NO-LOCK:
                CREATE w_contas.
                ASSIGN w_contas.nrdconta = crabass.nrdconta.
            END.

            FOR EACH w_contas NO-LOCK
                BREAK BY w_contas.nrdconta:
                IF  FIRST-OF(w_contas.nrdconta) THEN    
                    DO:
                        IF  w_contas.nrdconta <> aux_nrdconta THEN    
                            DO:
                                CREATE tt-msgconta.
                                ASSIGN tt-msgconta.msgconta = 
                                    "CPF tambem na conta = " + 
                                     STRING(w_contas.nrdconta).
                            END.
                    END.
            END.

            ASSIGN aux_nmprimtl = crapass.nmprimtl
                   aux_nrcpfcgc = crapass.nrcpfcgc.

            FOR EACH w_contas NO-LOCK,
                EACH crapavl WHERE 
                     crapavl.cdcooper = par_cdcooper         AND
                     crapavl.nrdconta = w_contas.nrdconta AND
                     crapavl.tpctrato = 1 USE-INDEX crapavl1 NO-LOCK:

                FIND crapepr WHERE
                     crapepr.cdcooper = par_cdcooper     AND
                     crapepr.nrdconta = crapavl.nrctaavd AND           
                     crapepr.nrctremp = crapavl.nrctravd
                     USE-INDEX crapepr2 NO-LOCK NO-ERROR.
                
                IF  AVAIL crapepr THEN 
                    DO:
                        IF  crapepr.inliquid <> 0 THEN
                            NEXT.
                        
                        ASSIGN epr_cdpesqui = 
                               STRING(crapepr.dtmvtolt,"99/99/9999")
                               + "-" +
                               STRING(crapepr.cdagenci,"999")      + "-" +
                               STRING(crapepr.cdbccxlt,"999")      + "-" +
                               STRING(crapepr.nrdolote,"999999").
                    END.               
                ELSE
                    NEXT.

                ASSIGN aux_regexist = TRUE.

                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = crapavl.nrctaavd 
                                   NO-LOCK NO-ERROR.

                IF  AVAIL crapass THEN
                    ASSIGN epr_nmprimtl = crapass.nmprimtl.
                ELSE
                    ASSIGN epr_nmprimtl = "ASSOC.NAO CADAST".

                ASSIGN epr_nrctremp = crapavl.nrctravd
                       epr_nrdconta = crapavl.nrctaavd
                       epr_tpdcontr = "EP".

                IF  NOT VALID-HANDLE(h-b1wgen0002) THEN
                    RUN sistema/generico/procedures/b1wgen0002.p
                        PERSISTENT SET h-b1wgen0002.

                RUN saldo-devedor-epr IN h-b1wgen0002 
                                    ( INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_idorigem,
                                      INPUT crapepr.nrdconta,
                                      INPUT 1, /* idseqttl */
                                      INPUT par_dtmvtolt,
                                      INPUT par_dtmvtopr,
                                      INPUT crapepr.nrctremp,
                                      INPUT "b1wgen0145.p",
                                      INPUT par_inproces,
                                      INPUT FALSE, /*flgerlog*/
                                     OUTPUT aux_vlsdeved,
                                     OUTPUT aux_vltotpre,
                                     OUTPUT aux_qtprecal,
                                     OUTPUT TABLE tt-erro).

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE Busca.

                IF  crapepr.inprejuz = 1 THEN
                    ASSIGN epr_vldivida = " Prejuizo".
                ELSE
                    ASSIGN epr_vldivida = STRING(aux_vlsdeved,"zz,zz9.99").

                CREATE tt-contras.
                ASSIGN tt-contras.nrctremp = epr_nrctremp
                       tt-contras.cdpesqui = epr_cdpesqui
                       tt-contras.nrdconta = epr_nrdconta
                       tt-contras.nmprimtl = epr_nmprimtl
                       tt-contras.tpdcontr = epr_tpdcontr
                       tt-contras.vldivida = epr_vldivida.

            END.  /* FOR EACH crapavl */

            FOR EACH w_contas NO-LOCK:

                FOR EACH crapavl WHERE 
                         crapavl.cdcooper = par_cdcooper         AND
                         crapavl.nrdconta = w_contas.nrdconta AND
                        (crapavl.tpctrato = 2                    OR /* Descto Cheques  */
                         crapavl.tpctrato = 3                    OR /* Cheque Especial */
                         crapavl.tpctrato = 8)                      /* Descto Titulos  */
                         NO-LOCK USE-INDEX crapavl1:


                    IF  crapavl.tpctrato  = 2 THEN   /* Descto Cheques */
                        ASSIGN aux_tpctrlim = 2
                               epr_tpdcontr = "DC".
                    ELSE
                    IF  crapavl.tpctrato  = 3 THEN
                        ASSIGN aux_tpctrlim = 1       /* Cheque Especial */ 
                               epr_tpdcontr = "LM".
                    ELSE
                        ASSIGN aux_tpctrlim = 3       /* Descto Titulos  */ 
                               epr_tpdcontr = "DT".

                    FIND craplim WHERE
                         craplim.cdcooper = par_cdcooper     AND
                         craplim.nrdconta = crapavl.nrctaavd AND
                         craplim.tpctrlim = aux_tpctrlim     AND
                         craplim.nrctrlim = crapavl.nrctravd 
                         USE-INDEX craplim1 NO-LOCK NO-ERROR.                

                    IF  AVAIL craplim THEN 
                        DO:

                            IF  craplim.insitlim <> 2  AND  /* Somente p/ Cheque Espec */
                                craplim.tpctrlim  = 1  THEN
                                NEXT.

                            FIND crapcdc WHERE
                                 crapcdc.cdcooper = par_cdcooper     AND
                                 crapcdc.nrdconta = craplim.nrdconta AND
                                 crapcdc.nrctrlim = craplim.nrctrlim AND
                                 crapcdc.tpctrlim = craplim.tpctrlim
                                 NO-LOCK NO-ERROR.

                            IF  AVAIL crapcdc THEN
                                ASSIGN epr_cdpesqui = 
                                       STRING(crapcdc.dtmvtolt,"99/99/9999")
                                       + "-" +
                                       STRING(crapcdc.cdagenci,"999")      + "-" +
                                       STRING(crapcdc.cdbccxlt,"999")      + "-" +
                                       STRING(crapcdc.nrdolote,"999999").
                            ELSE
                                ASSIGN epr_cdpesqui = 
                                       STRING(craplim.dtinivig,"99/99/9999") + " - " +
                                       STRING(craplim.nrctrlim).
                        END.               
                    ELSE
                        NEXT.

                    ASSIGN aux_regexist = TRUE.

                    FIND crapass WHERE
                         crapass.cdcooper = par_cdcooper     AND
                         crapass.nrdconta = crapavl.nrctaavd NO-LOCK NO-ERROR.

                    IF  AVAIL crapass THEN
                        ASSIGN epr_nmprimtl = crapass.nmprimtl.
                    ELSE
                        ASSIGN epr_nmprimtl = "ASSOC.NAO CADAST".

                    ASSIGN epr_nrctremp = crapavl.nrctravd
                           epr_nrdconta = crapavl.nrctaavd.

                    IF  crapavl.tpctrato = 2 THEN
                        DO:

                            ASSIGN aux_vldscchq = 0.

                            RUN totaliza_descto_cheques
                                ( INPUT par_cdcooper,
                                  INPUT par_dtmvtolt,
                                  INPUT craplim.nrdconta,
                                  INPUT craplim.nrctrlim,
                                 OUTPUT aux_vldscchq).

                            IF  aux_vldscchq = 0 THEN 
                                NEXT.

                            ASSIGN epr_vldivida = 
                                              STRING(aux_vldscchq,"zz,zz9.99").

                        END.
                    ELSE
                    IF  crapavl.tpctrato = 8 THEN
                        DO:
                            ASSIGN aux_vldsctit = 0.

                            RUN totaliza_descto_titulos
                                (  INPUT par_cdcooper,
                                   INPUT par_cdoperad,
                                   INPUT par_dtmvtolt,
                                   INPUT craplim.nrdconta,
                                   INPUT craplim.nrctrlim,
                                  OUTPUT aux_vldsctit).

                            IF  aux_vldsctit = 0 THEN 
                                NEXT.

                            ASSIGN epr_vldivida = 
                                              STRING(aux_vldsctit,"zz,zz9.99").

                        END.
                    ELSE
                        ASSIGN epr_vldivida = 
                                          STRING(craplim.vllimite,"zz,zz9.99").

                    CREATE tt-contras.
                    ASSIGN tt-contras.nrctremp = epr_nrctremp
                           tt-contras.cdpesqui = epr_cdpesqui
                           tt-contras.nrdconta = epr_nrdconta
                           tt-contras.nmprimtl = epr_nmprimtl
                           tt-contras.tpdcontr = epr_tpdcontr
                           tt-contras.vldivida = epr_vldivida.
                END.

            END. /* FIM FOR EACH w_contas */

            IF  NOT aux_regexist   THEN
                DO:
                    ASSIGN aux_cdcritic = 11
                           aux_dscritic = ""
                           par_nmdcampo = "nrdconta".
                    LEAVE Busca.
                END.

        END. /* IF  aux_nrdconta > 0 */ 

        IF  aux_nrcpfcgc > 0  THEN  DO:

            IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
                RUN sistema/generico/procedures/b1wgen9999.p
                    PERSISTENT SET h-b1wgen9999.

            RUN valida-cpf-cnpj IN h-b1wgen9999 
                                ( INPUT aux_nrcpfcgc, 
                                 OUTPUT aux_stsnrcal, 
                                 OUTPUT aux_inpessoa).

            IF  VALID-HANDLE(h-b1wgen9999)  THEN
                DELETE PROCEDURE h-b1wgen9999.

            IF  NOT aux_stsnrcal THEN
                DO: 
                    ASSIGN aux_cdcritic = 27
                           aux_dscritic = ""
                           par_nmdcampo = "nrcpfcgc".
                    LEAVE Busca.
                END.

            FIND FIRST crapavt WHERE crapavt.cdcooper = par_cdcooper AND
                                     crapavt.nrcpfcgc = aux_nrcpfcgc 
                                     USE-INDEX crapavt2 NO-LOCK NO-ERROR.

            IF  aux_nmprimtl = " " THEN
                ASSIGN aux_nmprimtl = crapavt.nmdavali WHEN AVAIL crapavt.

            FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper  AND
                                   crapavt.nrcpfcgc = aux_nrcpfcgc  AND
                                   crapavt.tpctrato = 1 /*  Emprestimo */
                                   USE-INDEX crapavt2  NO-LOCK:

                FIND crapepr WHERE crapepr.cdcooper = par_cdcooper      AND
                                   crapepr.nrdconta = crapavt.nrdconta  AND
                                   crapepr.nrctremp = crapavt.nrctremp
                                   USE-INDEX crapepr2 NO-LOCK NO-ERROR.

                IF  AVAIL crapepr THEN 
                    DO:
                        IF  crapepr.inliquid <> 0 THEN
                            NEXT.

                        ASSIGN epr_cdpesqui = 
                             STRING(crapepr.dtmvtolt,"99/99/9999") + "-" +
                             STRING(crapepr.cdagenci,"999")        + "-" +
                             STRING(crapepr.cdbccxlt,"999")        + "-" +
                             STRING(crapepr.nrdolote,"999999").
                    END.               
                ELSE
                    NEXT.

                ASSIGN aux_regexist = TRUE.

                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                                   crapass.nrdconta = crapavt.nrdconta 
                                   NO-LOCK NO-ERROR.

                IF   AVAIL crapass THEN
                     epr_nmprimtl = crapass.nmprimtl.
                ELSE
                     epr_nmprimtl = "ASSOC.NAO CADAST".

                ASSIGN epr_tpdcontr = "EP".

                ASSIGN epr_nrctremp = crapavt.nrctremp
                      epr_nrdconta = crapavt.nrdconta.

                IF  NOT VALID-HANDLE(h-b1wgen0002) THEN
                    RUN sistema/generico/procedures/b1wgen0002.p
                        PERSISTENT SET h-b1wgen0002.

                RUN saldo-devedor-epr IN h-b1wgen0002 
                                    ( INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_idorigem,
                                      INPUT crapepr.nrdconta,
                                      INPUT 1, /* idseqttl */
                                      INPUT par_dtmvtolt,
                                      INPUT par_dtmvtopr,
                                      INPUT crapepr.nrctremp,
                                      INPUT "b1wgen0145.p",
                                      INPUT par_inproces,
                                      INPUT FALSE, /*flgerlog*/
                                     OUTPUT aux_vlsdeved,
                                     OUTPUT aux_vltotpre,
                                     OUTPUT aux_qtprecal,
                                     OUTPUT TABLE tt-erro).

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE Busca.

                IF  crapepr.inprejuz = 1 THEN
                    ASSIGN epr_vldivida = " Prejuizo".
                ELSE
                    ASSIGN epr_vldivida = STRING(aux_vlsdeved,"zz,zz9.99").
                
                CREATE tt-contras.
                ASSIGN tt-contras.nrctremp = epr_nrctremp
                       tt-contras.cdpesqui = epr_cdpesqui
                       tt-contras.nrdconta = epr_nrdconta
                       tt-contras.nmprimtl = epr_nmprimtl
                       tt-contras.tpdcontr = epr_tpdcontr
                       tt-contras.vldivida = epr_vldivida.

            END. /*  FOR EACH crapavt */
            
            /*processa_outros_terceiros*/
            FOR EACH crapavt WHERE 
                     crapavt.cdcooper = par_cdcooper  AND
                     crapavt.nrcpfcgc = aux_nrcpfcgc  AND
                    (crapavt.tpctrato = 2  OR /* Descto Cheques  */
                     crapavt.tpctrato = 3  OR /* Cheque Especial */
                     crapavt.tpctrato = 8)    /* Descto Titulos  */
                     USE-INDEX crapavt2 NO-LOCK:

                IF  crapavt.tpctrato  = 2 THEN   /* Descto Cheques */
                    ASSIGN aux_tpctrlim = 2
                           epr_tpdcontr = "DC".
                ELSE
                IF  crapavt.tpctrato  = 8 THEN   /* Descto Titulos */
                    ASSIGN aux_tpctrlim = 3
                           epr_tpdcontr = "DT".
                ELSE
                    ASSIGN aux_tpctrlim = 1       /* Cheque Especial */ 
                           epr_tpdcontr = "LM".

                FIND craplim WHERE 
                     craplim.cdcooper = par_cdcooper     AND
                     craplim.nrdconta = crapavt.nrdconta AND
                     craplim.tpctrlim = aux_tpctrlim     AND
                     craplim.nrctrlim = crapavt.nrctremp 
                     USE-INDEX craplim1 NO-LOCK NO-ERROR.

                IF  AVAIL craplim THEN 
                    DO:

                        IF  craplim.insitlim <> 2 AND /* Somente p/ Cheque Especial */
                            craplim.tpctrlim = 1  THEN NEXT.

                        FIND crapcdc WHERE
                             crapcdc.cdcooper = par_cdcooper     AND
                             crapcdc.nrdconta = craplim.nrdconta AND
                             crapcdc.nrctrlim = craplim.nrctrlim AND
                             crapcdc.tpctrlim = craplim.tpctrlim
                             NO-LOCK NO-ERROR.

                        IF  AVAIL crapcdc THEN
                            ASSIGN epr_cdpesqui = 
                                   STRING(crapcdc.dtmvtolt,"99/99/9999")
                                   + "-" +
                                   STRING(crapcdc.cdagenci,"999")      + "-" +
                                   STRING(crapcdc.cdbccxlt,"999")      + "-" +
                                   STRING(crapcdc.nrdolote,"999999").
                        ELSE    
                            ASSIGN epr_cdpesqui = 
                                   STRING(craplim.dtinivig,"99/99/9999") + " - " +
                                   STRING(craplim.nrctrlim).

                    END. /* IF  AVAIL craplim */
                ELSE
                    NEXT.

                FIND crapass WHERE 
                     crapass.cdcooper = par_cdcooper     AND
                     crapass.nrdconta = crapavt.nrdconta NO-LOCK NO-ERROR.

                IF  AVAIL crapass THEN
                    ASSIGN epr_nmprimtl = crapass.nmprimtl.
                ELSE
                    ASSIGN epr_nmprimtl = "ASSOC.NAO CADAST".

                ASSIGN epr_nrctremp = crapavt.nrctremp
                      epr_nrdconta = crapavt.nrdconta.

                IF  crapavt.tpctrato = 2 THEN
                    DO:
                        ASSIGN aux_vldscchq = 0.

                        RUN totaliza_descto_cheques
                            ( INPUT par_cdcooper,
                              INPUT par_dtmvtolt,
                              INPUT aux_nrdconta,
                              INPUT craplim.nrctrlim,
                             OUTPUT aux_vldscchq).

                        IF  aux_vldscchq = 0 THEN 
                            NEXT.

                        ASSIGN epr_vldivida = STRING(aux_vldscchq,"zz,zz9.99").
                    END.
                ELSE
                IF  crapavt.tpctrato = 8 THEN
                    DO:
                        ASSIGN aux_vldsctit = 0.

                        RUN totaliza_descto_titulos
                            (  INPUT par_cdcooper,
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT craplim.nrdconta,
                               INPUT craplim.nrctrlim,
                              OUTPUT aux_vldsctit).

                        IF  aux_vldsctit = 0 THEN 
                            NEXT.

                        ASSIGN epr_vldivida = STRING(aux_vldsctit,"zz,zz9.99").

                    END.
                ELSE
                    ASSIGN  epr_vldivida =  STRING(craplim.vllimite,"zz,zz9.99").


                CREATE tt-contras.
                ASSIGN tt-contras.nrctremp = epr_nrctremp
                       tt-contras.cdpesqui = epr_cdpesqui
                       tt-contras.nrdconta = epr_nrdconta
                       tt-contras.nmprimtl = epr_nmprimtl
                       tt-contras.tpdcontr = epr_tpdcontr
                       tt-contras.vldivida = epr_vldivida.

            END. /* FOR EACH crapavt */

            FOR EACH crapavt WHERE 
                     crapavt.cdcooper = par_cdcooper  AND
                     crapavt.nrcpfcgc = aux_nrcpfcgc  AND
                     crapavt.tpctrato = 4        
                     USE-INDEX crapavt2 NO-LOCK:

                FIND crawcrd WHERE
                     crawcrd.cdcooper = par_cdcooper     AND
                     crawcrd.nrdconta = crapavt.nrdconta AND
                     crawcrd.nrctrcrd = crapavt.nrctremp 
                     NO-LOCK NO-ERROR.

                IF  AVAIL crawcrd THEN 
                    DO:

                        IF  crawcrd.insitcrd <> 4 THEN NEXT.

                        ASSIGN epr_cdpesqui = 
                               STRING(crawcrd.dtmvtolt,"99/99/9999")
                               + "-" +
                               STRING(crawcrd.cdagenci,"999")      + "-" +
                               STRING(crawcrd.cdbccxlt,"999")      + "-" +
                               STRING(crawcrd.nrdolote,"999999").
                    END.               
                ELSE
                    NEXT.

                ASSIGN aux_regexist = TRUE.

                FIND crapass WHERE
                     crapass.cdcooper = par_cdcooper     AND
                     crapass.nrdconta = crapavt.nrdconta NO-LOCK NO-ERROR.

                IF  AVAIL crapass THEN
                    ASSIGN epr_nmprimtl = crapass.nmprimtl.
                ELSE
                    ASSIGN epr_nmprimtl = "ASSOC.NAO CADAST".

                ASSIGN epr_nrctremp = crapavt.nrctremp
                       epr_nrdconta = crapavt.nrdconta
                       epr_vldivida = " ".

                FIND craptlc WHERE
                     craptlc.cdcooper = par_cdcooper     AND
                     craptlc.cdadmcrd = crawcrd.cdadmcrd AND
                     craptlc.tpcartao = crawcrd.tpcartao AND
                     craptlc.cdlimcrd = crawcrd.cdlimcrd AND
                     craptlc.dddebito = 0                NO-LOCK NO-ERROR.

                IF  AVAIL craptlc THEN
                    ASSIGN  epr_vldivida =  STRING(craptlc.vllimcrd,"zz,zz9.99").

                ASSIGN epr_tpdcontr = "CR".

                CREATE tt-contras.
                ASSIGN tt-contras.nrctremp = epr_nrctremp
                       tt-contras.cdpesqui = epr_cdpesqui
                       tt-contras.nrdconta = epr_nrdconta
                       tt-contras.nmprimtl = epr_nmprimtl
                       tt-contras.tpdcontr = epr_tpdcontr
                       tt-contras.vldivida = epr_vldivida.

            END. /* FOR EACH crapavt */

            IF  NOT aux_regexist   THEN
                DO:
                    ASSIGN aux_cdcritic = 11
                           aux_dscritic = ""
                           par_nmdcampo = "nrcpfcgc".
                    LEAVE Busca.
                END.

        END. /* IF  aux_nrcpfcgc > 0 */
            
        LEAVE Busca.

    END. /* Busca */

    IF  VALID-HANDLE(h-b1wgen0002) THEN
        DELETE PROCEDURE h-b1wgen0002.

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

/* ------------------------------------------------------------------------ */
/*                      EFETUA A CONSULTA DOS AVALISTAS                     */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Avalista:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdavali AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    
    DEF OUTPUT PARAM TABLE FOR tt-avalistas.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados Pesquisa de Avaistas".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-avalistas.
        EMPTY TEMP-TABLE tt-erro.

        /*Alterado Jéssica 19/08/2013*/
        IF  par_nmdavali = "" THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Informe o Avalista".
                LEAVE Busca.
            END.
        /*Fim da alteração 19/08/2013*/

        /*Alterado Jéssica 19/08/2013*/
        IF  LENGTH(par_nmdavali, "CHARACTER") < 2  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Informe 2 ou mais caracteres".
                LEAVE Busca.
            END.
        /*Fim da alteração 19/08/2013*/

        Avalistas: FOR EACH crapavt WHERE
                 crapavt.cdcooper = par_cdcooper               AND
                 crapavt.nmdavali MATCHES("*" + par_nmdavali + "*") NO-LOCK:

            FIND tt-avalistas WHERE 
                 tt-avalistas.nrdconta = crapavt.nrdconta AND
                 tt-avalistas.nmdavali = crapavt.nmdavali NO-LOCK NO-ERROR.

            IF  AVAIL tt-avalistas OR crapavt.nrcpfcgc = 0 THEN
                NEXT Avalistas.

            CREATE tt-avalistas.
            ASSIGN tt-avalistas.nrdconta = crapavt.nrdconta
                   tt-avalistas.nmdavali = crapavt.nmdavali
                   tt-avalistas.nrcpfcgc = crapavt.nrcpfcgc.

        END. /* Fim do FOR EACH - crapavt */

        Titular: FOR EACH crapttl WHERE 
                 crapttl.cdcooper = par_cdcooper     AND
                 crapttl.nmextttl MATCHES("*" + par_nmdavali + "*") NO-LOCK,

            EACH crapavl WHERE 
                 crapavl.cdcooper = crapttl.cdcooper AND
                 crapavl.nrdconta = crapttl.nrdconta NO-LOCK: 

            FIND FIRST tt-avalistas WHERE
                       tt-avalistas.nmdavali = crapttl.nmextttl NO-LOCK NO-ERROR.

            IF  AVAIL tt-avalistas THEN
                NEXT Titular.

            CREATE tt-avalistas.
            ASSIGN tt-avalistas.nrdconta = crapavl.nrdconta
                   tt-avalistas.nmdavali = crapttl.nmextttl
                   tt-avalistas.nrcpfcgc = crapttl.nrcpfcgc. 

        END. /* Fim do FOR EACH - crapttl */

        Juridicas: FOR EACH crapjur WHERE 
                 crapjur.cdcooper = par_cdcooper        AND
                 crapjur.nmextttl MATCHES("*" + par_nmdavali + "*") NO-LOCK,

            EACH crapavl WHERE crapavl.cdcooper = crapttl.cdcooper AND
                               crapavl.nrdconta = crapttl.nrdconta NO-LOCK:

            FIND FIRST tt-avalistas WHERE 
                       tt-avalistas.nmdavali = crapjur.nmextttl NO-LOCK NO-ERROR.

            IF  AVAIL tt-avalistas THEN
                NEXT Juridicas.

            FIND crapass WHERE
                 crapass.cdcooper = crapjur.cdcooper AND
                 crapass.nrdconta = crapjur.nrdconta NO-LOCK NO-ERROR.

            CREATE tt-avalistas.
            ASSIGN tt-avalistas.nrdconta = crapavl.nrdconta
                   tt-avalistas.nmdavali = crapjur.nmextttl
                   tt-avalistas.nrcpfcgc = crapass.nrcpfcgc. 

        END. /* Fim do FOR EACH - crapjur */

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

/*........................... PROCEDURES INTERNAS ...........................*/

PROCEDURE totaliza_descto_cheques:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrctrlim AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM par_vlsdeved AS DECI                            NO-UNDO.

    DEF VAR aux_vldscchq AS DEC                                      NO-UNDO.

    FIND craplim WHERE 
         craplim.cdcooper = par_cdcooper  AND
         craplim.nrdconta = par_nrdconta  AND
         craplim.tpctrlim = 2             AND
         craplim.nrctrlim = par_nrctrlim  NO-LOCK
         USE-INDEX craplim1 NO-ERROR.

    IF  AVAIL craplim THEN 
        DO:

            /*  Totaliza o montante de cheques descontados  */
            FOR EACH crapbdc USE-INDEX crapbdc2
               WHERE crapbdc.cdcooper = par_cdcooper       AND
                     crapbdc.nrdconta = craplim.nrdconta   AND
                     crapbdc.nrctrlim = craplim.nrctrlim   NO-LOCK,
                EACH crapcdb WHERE 
                     crapcdb.cdcooper = par_cdcooper       AND
                     crapcdb.nrdconta = crapbdc.nrdconta   AND
                     crapcdb.nrborder = crapbdc.nrborder   AND
                     crapcdb.nrctrlim = crapbdc.nrctrlim   AND
                     crapcdb.insitchq = 2                  AND
                     crapcdb.dtlibera > par_dtmvtolt       NO-LOCK
                     USE-INDEX crapcdb7: 

                ASSIGN aux_vldscchq = aux_vldscchq + crapcdb.vlcheque.

            END. /* FOR EACH crapbdc */

        END. /* IF  AVAIL craplim */

    ASSIGN  par_vlsdeved = aux_vldscchq.

    RETURN "OK".

END PROCEDURE.

PROCEDURE totaliza_descto_titulos:

    DEF  INPUT PARAM par_cdcooper AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                         NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                         NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_nrctrlim AS INTE                         NO-UNDO.

    DEF OUTPUT PARAM aux_vldsctit AS DECI                         NO-UNDO.


    DEF VAR h-b1wgen0030 AS HANDLE                                NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen0030) THEN
        RUN sistema/generico/procedures/b1wgen0030.p
            PERSISTENT SET h-b1wgen0030.
        
    IF  VALID-HANDLE(h-b1wgen0030)  THEN
        DO:
            RUN busca_total_descto_lim IN h-b1wgen0030 
                                   ( INPUT par_cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT par_cdoperad,
                                     INPUT par_dtmvtolt,
                                     INPUT par_nrdconta,
                                     INPUT 1,
                                     INPUT 1,
                                     INPUT "AVALIS",
                                     INPUT par_nrctrlim,
                                     INPUT FALSE, /* LOG */
                                    OUTPUT TABLE tt-tot_descontos).

            FIND FIRST tt-tot_descontos NO-LOCK NO-ERROR.

            IF  AVAIL tt-tot_descontos  THEN
                aux_vldsctit = tt-tot_descontos.vltotdsc.

            IF  VALID-HANDLE(h-b1wgen0030) THEN
                DELETE PROCEDURE h-b1wgen0030.    

        END.

END PROCEDURE.

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
