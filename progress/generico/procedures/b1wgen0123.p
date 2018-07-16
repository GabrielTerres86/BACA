/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0123.p
    Autor   : Gabriel Capoia dos Santos (DB1)
    Data    : Novembro/2011                     Ultima atualizacao: 25/07/2017

    Objetivo  : Tranformacao BO tela CASH

    Alteracoes: 14/06/2012 - Eliminar EXTENT vldmovto (Evandro).
    
                24/09/2012 - Aumentar formato do campo vlenvinf (Gabriel).
                
                19/10/2012 - Incluido include b1wgen0025tt.i (Oscar).
                
                16/07/2013 - Incluido a procedure 
                             "busca_dados_cartoes_magneticos". (James)
                             
                11/10/2013 - Adaptacao para uso das opcoes "A" e "I" pela
                             equipe do "SUPORTE" (Evandro).
                             
                23/10/2013 - Correcao da opcao "M" (Evandro).
                
                31/10/2013 - Criado proc. status_saque e alterar_status_saque.
                           - Adicionado campo flgblsaq em tt-terminal em 
                             proc. Busca_Dados  (Jorge).
                             
                12/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
                
                06/01/2014 - Criticas de busca de crapage alteradas de 15 para
                             962 (Carlos)
                             
                28/02/2014 - Liberação do campo PA para alteração e inclusao de
                             alteracoes no log. (Jean Michel)        
                             
                03/04/2014 - Ajuste na procedures "busca_dados_cartoes_magneticos"
                             para ganho performace no dataserver (Daniel).
                             
                27/05/2014 - Incluido a informação de espécie de deposito e
                             relatório do mesmo. (Andre Santos - SUPERO)                   
                             
                26/06/2014 - Ajuste em chamada da proc. Busca_impressao, faltou
                             passar 2 parametros de entrada (campos novos).
                             (Jorge/Rosangela) Emergencial             
                             
                05/08/2014 - Alterado para buscar envelopes depositados no 
                             caixa eletronico pela cooperativa acolhedora.
                             (Reinert)                            
                             
                11/08/2014 - Adicionado informacao de cooperativa de destino
                             da conta a receber deposito na temp-table 
                             tt-envelopes. (Reinert)]
               
                05/09/2014 - Ajuste no cmando ping da função M da tela cash
                             (Vanessa)
                             
                22/09/2014 - #187195 Tela CASH, opcoes de consulta e relatorio 
                             de depositos - inclusao dos totais de depositos 
                             em dinheiro e em cheque (Carlos)
                            
               22/04/2015 - Alteracao na formatacao do campo tt-envelopes.nrseqenv 
                            de 6 para 10 caracteres. (Jaison/Elton - SD: 276984)
                            
               05/08/2015 - Adicionado parametro de entrada em proc_log_do_dia
                            passando cdcooper, pois no ayllos web nao fica setado
                            a variavel EMPRESA, utilizado em BuscaArquivoTAA.sh.
                            (Jorge/Elton) - SD 300929

               27/07/2016 - Criacao da opcao 'S'. (Jaison/Anderson)

			   06/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                            departamento passando a considerar o código (Renato Darosci)
                            
               25/07/2017 - #712156 Melhoria 274, criação da rotina verifica_notas_cem,
                            operacao 75, para verificar se o TAA utiliza notas de cem;
                            Inclusão do par flgntcem na rotina Grava_Dados e campo 
							flgntcem na temp-table das opções A e C (Carlos)

............................................................................*/

/*............................. DEFINICOES .................................*/

{ sistema/generico/includes/b1wgen0025tt.i }
{ sistema/generico/includes/b1wgen0123tt.i }
{ sistema/generico/includes/b1wgen0059tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF STREAM str_1.

DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_idorigem AS INTE                                        NO-UNDO.
DEF VAR h-b1wgen0025 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0059 AS HANDLE                                      NO-UNDO.

DEF VAR aux_dstitulo AS CHAR   FORMAT "X(80)"                       NO-UNDO.
DEF VAR tot_qtdecoop AS INT                                         NO-UNDO.
DEF VAR tot_qtdmovto AS INT                                         NO-UNDO.
DEF VAR tot_vlrtotal AS DECI                                        NO-UNDO.
DEF VAR tot_vlrtarif AS DECI                                        NO-UNDO.
DEF VAR aux_dssubtit AS CHAR   FORMAT "X(100)"                      NO-UNDO.
DEF VAR aux_qtdecoop AS INT                                         NO-UNDO.
DEF VAR aux_qtdmovto AS INT                                         NO-UNDO.
DEF VAR aux_vlrtotal AS DECI                                        NO-UNDO.
DEF VAR aux_vlrtarif AS DECI                                        NO-UNDO.
DEF VAR aux_dscooper AS CHAR   FORMAT "X(20)"                       NO-UNDO.
DEF VAR aux_setlinha AS CHAR                                        NO-UNDO.
DEF VAR aux_semdados AS CHAR INIT "SEM DADOS PARA EXIBICAO"         NO-UNDO.
DEF VAR tot_qtsitenv AS INTE                                        NO-UNDO.
DEF VAR tot_vlenvinf AS DECI   FORMAT "z,zzz,zz9.99"                NO-UNDO.
DEF VAR tot_vlenvcmp AS DECI   FORMAT "z,zzz,zz9.99"                NO-UNDO.

DEF VAR tot_vldininf AS DECI   FORMAT "z,zzz,zz9.99"                NO-UNDO.
DEF VAR tot_vlchqinf AS DECI   FORMAT "z,zzz,zz9.99"                NO-UNDO.
/* totais gerais dinheiro e cheque */
DEF VAR tot_vlgerdin AS DECI   FORMAT "z,zzz,zz9.99"                NO-UNDO.
DEF VAR tot_vlgerchq AS DECI   FORMAT "z,zzz,zz9.99"                NO-UNDO.
DEF VAR tot_qtsittot AS INTE                                        NO-UNDO.

DEF VAR aux_flgblsaq AS LOGICAL                                     NO-UNDO.

DEF VAR aux_dslogtel AS CHAR  INIT ""                               NO-UNDO.

FORM aux_dstitulo       AT 1 NO-LABEL  FORMAT "x(80)"
     SKIP(1)
     WITH COLUMN 1 DOWN NO-BOX FRAME f_tela_titulo.

FORM aux_dssubtit       AT 1 NO-LABEL
     SKIP
     WITH COLUMN 1 WIDTH 110 DOWN NO-BOX FRAME f_tela_subtit.

FORM aux_semdados       AT 5 NO-LABEL FORMAT "x(25)"
     SKIP(2)
     WITH COLUMN 1 WIDTH 110 DOWN NO-BOX FRAME f_tela_semdados.

/**** FRAMES P/ TAAs *****/
FORM aux_dscooper        AT  1 LABEL "Cooperativa" FORMAT "x(14)"
     aux_qtdecoop        AT 22 LABEL "Qtd. Coop."  FORMAT "zzzz9"
     aux_qtdmovto        AT 33 LABEL "Qtd. Movtos" FORMAT "zzzz9"
     aux_vlrtotal        AT 45 LABEL "Valor Total" FORMAT "zzzz,zzz,zz9.99"
     aux_vlrtarif        AT 61 LABEL "Vlr Tarifa"  FORMAT "zzzz,zzz,zz9.99"
    WITH COLUMN 1 OVERLAY DOWN NO-BOX FRAME f_tela_dados_taa.

FORM tt-lanctos.cdagetfn AT  1 LABEL "PA"          FORMAT "zz9"
     aux_dscooper        AT  7 LABEL "Cooperativa" FORMAT "x(14)"
     aux_qtdecoop        AT 22 LABEL "Qtd. Coop."  FORMAT "zzzz9"
     aux_qtdmovto        AT 33 LABEL "Qtd. Movtos" FORMAT "zzzz9"
     aux_vlrtotal        AT 45 LABEL "Valor Total" FORMAT "zzzz,zzz,zz9.99"
     aux_vlrtarif        AT 61 LABEL "Vlr Tarifa"  FORMAT "zzzz,zzz,zz9.99"
    WITH COLUMN 1 OVERLAY DOWN NO-BOX FRAME f_tela_dados_taa_pac.

/**** FRAMES P/ OUTRAS COOPS ******/
FORM aux_dscooper        AT  1 LABEL "Cooperativa" FORMAT "x(14)"
     aux_qtdecoop        AT 22 LABEL "Qtd. Coop."  FORMAT "zzzz9"
     aux_qtdmovto        AT 33 LABEL "Qtd. Movtos" FORMAT "zzzz9"
     aux_vlrtotal        AT 45 LABEL "Valor Total" FORMAT "zzzz,zzz,zz9.99"
     aux_vlrtarif        AT 61 LABEL "Vlr Tarifa"  FORMAT "zzzz,zzz,zz9.99"
    WITH COLUMN 1 OVERLAY DOWN NO-BOX FRAME f_tela_dados_outras.

FORM aux_dscooper        AT  1 LABEL "Cooperativa" FORMAT "x(14)"
     tt-lanctos.cdagetfn AT 16 LABEL "PA"          FORMAT "zz9"
     aux_qtdecoop        AT 22 LABEL "Qtd. Coop."  FORMAT "zzzz9"
     aux_qtdmovto        AT 33 LABEL "Qtd. Movtos" FORMAT "zzzz9"
     aux_vlrtotal        AT 45 LABEL "Valor Total" FORMAT "zzzz,zzz,zz9.99"
     aux_vlrtarif        AT 61 LABEL "Vlr Tarifa"  FORMAT "zzzz,zzz,zz9.99"
    WITH COLUMN 1 OVERLAY DOWN NO-BOX FRAME f_tela_dados_outras_pac.

/**** FRAME P/ TOTAIS ******/
FORM aux_setlinha       AT  1 NO-LABEL  FORMAT "x(75)" SKIP
     "TOTAL"            AT  1
     tot_qtdecoop       AT 27 NO-LABEL  FORMAT "zzzz9"
     tot_qtdmovto       AT 39 NO-LABEL  FORMAT "zzzz9"
     tot_vlrtotal       AT 45 NO-LABEL  FORMAT "zzzz,zzz,zz9.99"
     tot_vlrtarif       AT 61 NO-LABEL  FORMAT "zzzz,zzz,zz9.99"
     SKIP(2)
    WITH COLUMN 1 DOWN NO-BOX FRAME f_tela_totais.

DEF BUFFER crabcop FOR crapcop.

FUNCTION LockTabela   RETURNS CHARACTER PRIVATE 
    ( INPUT par_cddrecid AS RECID,
      INPUT par_nmtabela AS CHAR ) FORWARD.

/*................................ PROCEDURES ..............................*/

/* ------------------------------------------------------------------------ */
/*                     EFETUA A BUSCA                       */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrterfin AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flsistaa AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_mmtramax AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtini AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtfim AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddoptel AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_lgagetfn AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_tiprelat AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cdagetfn AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitenv AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_opcaorel AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-terminal.
    DEF OUTPUT PARAM TABLE FOR crattfn.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmoperad AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdispen AS CHAR                                    NO-UNDO.
    DEF VAR aux_dssittfn AS CHAR                                    NO-UNDO.
    DEF VAR aux_dstramax AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdlinha AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdcoptfn AS INTE                                    NO-UNDO.
    DEF VAR aux_cdagetfn AS INTE                                    NO-UNDO.
    DEF VAR aux_nrterfin AS INTE                                    NO-UNDO. 
    DEF VAR aux_nmresage AS CHAR                                    NO-UNDO.
    DEF VAR aux_dstransa AS CHAR                                    NO-UNDO.
    DEF VAR aux_posini   AS INTE                                    NO-UNDO.
    DEF VAR aux_posfim   AS INTE                                    NO-UNDO.
    DEF VAR aux_nmendter AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsheader AS CHAR                                    NO-UNDO.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados "
           aux_setlinha = FILL("-",75)
           aux_cdagetfn = IF par_cdagetfn = 0 THEN 9999 ELSE par_cdagetfn.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-terminal.
        EMPTY TEMP-TABLE tt-lanctos.
        EMPTY TEMP-TABLE crattfn.
        EMPTY TEMP-TABLE tt-erro.

        IF  CAN-DO("A,I",par_cddopcao) AND
            par_cddepart <> 20   AND  /* TI */
            par_cddepart <> 18  THEN  /* SUPORTE */
            DO:
                ASSIGN aux_dscritic = "Apenas CONSULTA esta liberada para" +
                                      " esta tela.".
                LEAVE Busca.
            END.

        CASE par_cddopcao:
            WHEN "C" THEN
                DO:
                    FOR FIRST craptfn WHERE 
                              craptfn.cdcooper = par_cdcooper AND
                              craptfn.nrterfin = par_nrterfin NO-LOCK: END.

                    IF  NOT AVAIL craptfn THEN
                        DO:
                            ASSIGN aux_dscritic = "Terminal financeiro nao " +
                                                  "cadastrado!".
                            LEAVE Busca.
                        END.

                    FOR FIRST crapope WHERE
                              crapope.cdcooper = par_cdcooper     AND
                              crapope.cdoperad = craptfn.cdoperad NO-LOCK: END.

                    IF  NOT AVAIL crapope THEN
                        ASSIGN aux_nmoperad = STRING(craptfn.cdoperad,"x(10)") +
                                              " - NAO CADASTRADO".
                    ELSE
                        ASSIGN aux_nmoperad = crapope.nmoperad.

                    CASE craptfn.tpdispen:
                       WHEN 1 THEN ASSIGN aux_dsdispen = "MAIOR VALOR".
                       WHEN 2 THEN ASSIGN aux_dsdispen = "CASSETES BALANCEADOS".
                       WHEN 3 THEN ASSIGN aux_dsdispen = "PAGAMENTO BALANCEADO".
                       OTHERWISE   ASSIGN aux_dsdispen = "** INDEFINIDO **".
                    END CASE.

                    CASE craptfn.cdsitfin:
                        WHEN 1 THEN ASSIGN aux_dssittfn = "ABERTO".
                        WHEN 2 THEN ASSIGN aux_dssittfn = "FECHADO".
                        WHEN 3 THEN ASSIGN aux_dssittfn = "BLOQUEADO".
                        WHEN 4 THEN ASSIGN aux_dssittfn = "SUPRIDO".
                        WHEN 5 THEN ASSIGN aux_dssittfn = "RECOLHIDO".

                        /* Estado temporario, nao usado */
                        WHEN 6 THEN ASSIGN aux_dssittfn = "DESBLOQUEADO".

                        WHEN 7 THEN ASSIGN aux_dssittfn = "EM TRANSPORTE".
                        OTHERWISE   ASSIGN aux_dssittfn = "DESATIVADO".
                    END CASE.
                    
                    CREATE tt-terminal.
                    ASSIGN tt-terminal.nmoperad = aux_nmoperad
                           tt-terminal.dsterfin = " - " + craptfn.nmterfin
                           tt-terminal.dstempor = STRING(craptfn.nrtempor) + 
                                                                 " SEGUNDOS"
                           tt-terminal.nmterfin = craptfn.nmterfin
                           tt-terminal.nrtempor = craptfn.nrtempor
                           tt-terminal.tpdispen = craptfn.tpdispen
                           tt-terminal.cdagenci = craptfn.cdagenci
                           tt-terminal.cdsitfin = craptfn.cdsitfin
                           tt-terminal.dsfabtfn = craptfn.dsfabtfn
                           tt-terminal.dsmodelo = craptfn.dsmodelo
                           tt-terminal.dsdserie = craptfn.dsdserie
                           tt-terminal.nmnarede = TRIM(craptfn.nmnarede)
                           tt-terminal.nrdendip = TRIM(craptfn.nrdendip)
                           tt-terminal.qtcasset = craptfn.qtcasset
                           tt-terminal.dsininot = STRING(craptfn.hrininot,
                                                                    "HH:MM:SS")
                           tt-terminal.dsfimnot = STRING(craptfn.hrfimnot,
                                                                    "HH:MM:SS")
                           tt-terminal.dssaqnot = "R$ " + TRIM(STRING(
                                                craptfn.vlsaqnot,"zzz,zz9.99"))

                           tt-terminal.nrdlacre[1] = craptfn.nrdlacre[1]
                           tt-terminal.qtnotcas[1] = craptfn.qtnotcas[1]
                           tt-terminal.vlnotcas[1] = craptfn.vlnotcas[1]
                           tt-terminal.vltotcas[1] = craptfn.vltotcas[1]
                                                                        
                           tt-terminal.nrdlacre[2] = craptfn.nrdlacre[2]
                           tt-terminal.qtnotcas[2] = craptfn.qtnotcas[2]
                           tt-terminal.vlnotcas[2] = craptfn.vlnotcas[2]
                           tt-terminal.vltotcas[2] = craptfn.vltotcas[2]
                                                                        
                           tt-terminal.nrdlacre[3] = craptfn.nrdlacre[3]
                           tt-terminal.qtnotcas[3] = craptfn.qtnotcas[3]
                           tt-terminal.vlnotcas[3] = craptfn.vlnotcas[3]
                           tt-terminal.vltotcas[3] = craptfn.vltotcas[3]
                                                                        
                           tt-terminal.nrdlacre[4] = craptfn.nrdlacre[4]
                           tt-terminal.qtnotcas[4] = craptfn.qtnotcas[4]
                           tt-terminal.vlnotcas[4] = craptfn.vlnotcas[4]
                           tt-terminal.vltotcas[4] = craptfn.vltotcas[4]

                           tt-terminal.nrdlacre[5] = craptfn.nrdlacre[5]
                           tt-terminal.qtnotcas[5] = craptfn.qtnotcas[5]
                           tt-terminal.vltotcas[5] = craptfn.vlnotcas[5]

                           tt-terminal.qtenvelo = craptfn.qtenvelo
                           tt-terminal.dssittfn = aux_dssittfn
                           tt-terminal.dsdispen = aux_dsdispen
                           tt-terminal.qtdnotag = craptfn.qtnotcas[1] +
                                                  craptfn.qtnotcas[2] +
                                                  craptfn.qtnotcas[3] +
                                                  craptfn.qtnotcas[4] +
                                                  craptfn.qtnotcas[5]

                           tt-terminal.vltotalG = craptfn.vltotcas[1] +
                                                  craptfn.vltotcas[2] +
                                                  craptfn.vltotcas[3] +
                                                  craptfn.vltotcas[4] +
                                                  craptfn.vlnotcas[5]
                            
                           tt-terminal.vltotalP = 0
                           tt-terminal.flgblsaq = craptfn.flgblsaq
                           tt-terminal.flgntcem = craptfn.flgntcem.
            
                    /* se o terminal possui sistema antigo, calcula a
                      quantidade de envelopes */
                    IF  NOT craptfn.flsistaa THEN
                        RUN proc_depositos_efetuados
                        ( INPUT par_cdcooper,
                          INPUT craptfn.nrterfin,
                         OUTPUT tt-terminal.qtenvelo).

                END. /* par_cddopcao = C */
            WHEN "A" THEN
                DO:

                    FOR FIRST craptfn WHERE 
                              craptfn.cdcooper = par_cdcooper AND
                              craptfn.nrterfin = par_nrterfin NO-LOCK: END.

                    IF  NOT AVAIL craptfn THEN
                        DO:
                            ASSIGN aux_dscritic = "Terminal financeiro nao " +
                                                  "cadastrado!".
                            LEAVE Busca.
                        END.

                    CASE craptfn.tpdispen:
                       WHEN 1 THEN ASSIGN aux_dsdispen = "MAIOR VALOR".
                       WHEN 2 THEN ASSIGN aux_dsdispen = "CASSETES BALANCEADOS".
                       WHEN 3 THEN ASSIGN aux_dsdispen = "PAGAMENTO BALANCEADO".
                       OTHERWISE   ASSIGN aux_dsdispen = "** INDEFINIDO **".
                    END CASE.

                    CASE craptfn.cdsitfin:
                        WHEN 1 THEN ASSIGN aux_dssittfn = "ABERTO".
                        WHEN 2 THEN ASSIGN aux_dssittfn = "FECHADO".
                        WHEN 3 THEN ASSIGN aux_dssittfn = "BLOQUEADO".
                        WHEN 4 THEN ASSIGN aux_dssittfn = "SUPRIDO".
                        WHEN 5 THEN ASSIGN aux_dssittfn = "RECOLHIDO".

                        /* Estado temporario, nao usado */
                        WHEN 6 THEN ASSIGN aux_dssittfn = "DESBLOQUEADO".

                        WHEN 7 THEN ASSIGN aux_dssittfn = "EM TRANSPORTE".
                        OTHERWISE   ASSIGN aux_dssittfn = "DESATIVADO".
                    END CASE.

                    CREATE tt-terminal.
                    ASSIGN tt-terminal.nmterfin = craptfn.nmterfin
                           tt-terminal.dsterfin = " - " + craptfn.nmterfin
                           tt-terminal.dstempor = STRING(craptfn.nrtempor) + 
                                                                 " SEGUNDOS"
                           tt-terminal.nrtempor = craptfn.nrtempor
                           tt-terminal.dsdispen = aux_dsdispen
                           tt-terminal.dssittfn = aux_dssittfn
                           tt-terminal.cdagenci = craptfn.cdagenci
                           tt-terminal.dsfabtfn = craptfn.dsfabtfn
                           tt-terminal.dsmodelo = craptfn.dsmodelo
                           tt-terminal.dsdserie = craptfn.dsdserie
                           tt-terminal.nmnarede = TRIM(craptfn.nmnarede)
                           tt-terminal.nrdendip = TRIM(craptfn.nrdendip)
                           tt-terminal.qtcasset = craptfn.qtcasset
                           tt-terminal.cdsitfin = craptfn.cdsitfin
                           tt-terminal.dsininot = STRING(craptfn.hrininot,
                                                                    "HH:MM:SS")
                           tt-terminal.dsfimnot = STRING(craptfn.hrfimnot,
                                                                    "HH:MM:SS")
                           tt-terminal.dssaqnot = "R$ " + TRIM(STRING(
                                               craptfn.vlsaqnot,"zzz,zz9.99"))
                           tt-terminal.flgntcem = craptfn.flgntcem.

                END. /* par_cddopcao = A */
            WHEN "S" THEN
                DO:
                    FOR FIRST craptfn WHERE 
                              craptfn.cdcooper = par_cdcooper AND
                              craptfn.nrterfin = par_nrterfin NO-LOCK: END.

                    IF  NOT AVAIL craptfn THEN
                        DO:
                            ASSIGN aux_dscritic = "Terminal financeiro nao " +
                                                  "cadastrado!".
                            LEAVE Busca.
                        END.

                    CREATE tt-terminal.
                    ASSIGN tt-terminal.nmterfin = craptfn.nmterfin
                           tt-terminal.dsterfin = " - " + craptfn.nmterfin
                           tt-terminal.cdagenci = craptfn.cdagenci.
                    
                END. /* par_cddopcao = S */
            WHEN "B" THEN
                DO:
                    /* Liberacao apenas para TI, SUPORTE e operador do SUPORTE TECNICO */
                    IF  par_cddepart <> 20     AND  /* TI */ 
                        par_cddepart <> 18     AND  /* SUPORTE */
                        par_cdoperad <> "200" THEN 
                        DO:
                           ASSIGN aux_dscritic = "Apenas CONSULTA esta " +
                                                 "liberada para esta tela.".
                           LEAVE Busca.
                       END.

                    IF  par_nrterfin = 0 THEN
                        FOR EACH craptfn FIELDS(nrterfin nmterfin flsistaa)
                           WHERE craptfn.cdcooper = par_cdcooper AND
                                 craptfn.flsistaa = par_flsistaa NO-LOCK:
                            CREATE tt-terminal.
                            ASSIGN tt-terminal.dsterfin = 
                                      STRING(craptfn.nrterfin,"zzz9") + " - " +
                                                               craptfn.nmterfin
                                   tt-terminal.flsistaa = craptfn.flsistaa.
                        END. /* FOR EACH craptfn */
                    ELSE
                        DO:
                            FOR FIRST craptfn FIELDS(nrterfin nmterfin flsistaa)
                                WHERE craptfn.cdcooper = par_cdcooper AND
                                      craptfn.nrterfin = par_nrterfin NO-LOCK.
                            END.

                            IF  NOT AVAIL craptfn THEN
                                DO:
                                    ASSIGN aux_dscritic = "Terminal financeiro"
                                                          + " nao cadastrado!".
                                    LEAVE Busca.
                                END.

                            CREATE tt-terminal.
                            ASSIGN tt-terminal.dsterfin = " - " + craptfn.nmterfin
                                   tt-terminal.flsistaa = craptfn.flsistaa.
                        END.

                END. /* par_cddopcao = B */
            WHEN "I" THEN
                DO:
                    /* Vem zerado quando entra na opcao I para carregar o proximo
                       numero de TAA */
                    IF  par_nrterfin = 0  THEN
                        DO:
                            FOR LAST craptfn FIELDS(nrterfin)
                                WHERE craptfn.cdcooper = par_cdcooper NO-LOCK.
                            END.

                            CREATE crattfn.
                            ASSIGN crattfn.nrterfin = IF AVAIL craptfn THEN
                                                         craptfn.nrterfin + 1
                                                      ELSE 1.
                        END.
                    ELSE
                        DO:
                            IF  CAN-FIND(craptfn WHERE 
                                         craptfn.cdcooper = par_cdcooper AND
                                         craptfn.nrterfin = par_nrterfin    ) THEN
                                DO:
                                    ASSIGN aux_dscritic = "Terminal financeiro" +
                                                          " ja cadastrado!".
                                    LEAVE Busca.
                                END.
                        END.
                END. /* par_cddopcao = I */
            WHEN "M" THEN
                DO:
                    IF  par_cdcooper <> 3 THEN
                        DO:
                            ASSIGN aux_dscritic = "Monitoramento apenas na " +
                                                  "CECRED.".
                            LEAVE Busca.
                        END.

                    ASSIGN aux_dstramax = STRING(TIME - 
                                                (par_mmtramax * 60),"hh:mm:ss")

                        aux_nmarquiv = "TAA_autorizador_" +
                                          STRING(YEAR(TODAY),"9999") +
                                          STRING(MONTH(TODAY),"99") +
                                          STRING(DAY(TODAY),"99") +
                                          ".log".

                    /* Verifica se existe e cria uma copia do log para poder
                      verificar as ultimas solicitacoes de autorizacao,
                      operacao 9999 de cada TAA cadastrado no sistema */

                    IF  SEARCH("/usr/coop/cecred/log/TAA/" + aux_nmarquiv) = ? 
                        THEN DO:
                        ASSIGN aux_dscritic = "Arquivo de LOG nao encontrado.".
                        LEAVE Busca.
                        END.
                    ELSE
                        UNIX SILENT VALUE("cp /usr/coop/cecred/log/TAA/" +
                        aux_nmarquiv + " /usr/coop/cecred/arq/" + aux_nmarquiv).

                    INPUT STREAM str_1 FROM VALUE ("/usr/coop/cecred/arq/"
                                                           + aux_nmarquiv).

                    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE
                                   ON ERROR  UNDO, LEAVE:

                        IMPORT STREAM str_1 UNFORMATTED aux_dsdlinha.

                        /* operacao de autorizacao */
                        IF  aux_dsdlinha MATCHES "*<TAA>*"                     AND
                            aux_dsdlinha MATCHES "*<OPERACAO>9999</OPERACAO>*" THEN
                            DO:

                                ASSIGN aux_posini   = 
                                          INDEX(aux_dsdlinha,"<CDCOPTFN>") + 10

                                       aux_posfim   = 
                                           INDEX(aux_dsdlinha,"</CDCOPTFN>") - 
                                                                    aux_posini
                                       aux_cdcoptfn = 
                                                    INT(SUBSTRING(aux_dsdlinha,
                                                       aux_posini, aux_posfim))
                                                                      NO-ERROR.
                                       
                                ASSIGN aux_posini   =
                                          INDEX(aux_dsdlinha,"<CDAGETFN>") + 10

                                       aux_posfim   = 
                                          INDEX(aux_dsdlinha,"</CDAGETFN>") -
                                                                    aux_posini

                                       aux_cdagetfn = 
                                                    INT(SUBSTRING(aux_dsdlinha,
                                                       aux_posini, aux_posfim))
                                                    NO-ERROR.

                                ASSIGN aux_posini   =
                                         INDEX(aux_dsdlinha,"<NRTERFIN>") + 10

                                       aux_posfim   =
                                         INDEX(aux_dsdlinha,"</NRTERFIN>") -
                                                                    aux_posini
                                       aux_nrterfin =
                                                    INT(SUBSTRING(aux_dsdlinha,
                                                       aux_posini, aux_posfim))
                                                                      NO-ERROR.

                                aux_dstransa = SUBSTRING(aux_dsdlinha,14,8).

                                /* se nao montou um horario valido, limpa */
                                IF  SUBSTRING(aux_dstransa,3,1) <> ":" OR
                                    SUBSTRING(aux_dstransa,6,1) <> ":" THEN
                                    ASSIGN aux_dstransa = "".

                                IF  ERROR-STATUS:ERROR OR
                                    aux_dstransa = ""  THEN
                                    NEXT.

                                FIND crattfn WHERE 
                                     crattfn.cdcoptfn = aux_cdcoptfn AND
                                     crattfn.nrterfin = aux_nrterfin
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                IF  NOT AVAIL crattfn THEN
                                    DO:
                                        CREATE crattfn.
                                        ASSIGN crattfn.cdcoptfn = aux_cdcoptfn
                                               crattfn.cdagetfn = aux_cdagetfn
                                               crattfn.nrterfin = aux_nrterfin.
                                    END.

                                ASSIGN crattfn.dstransa = aux_dstransa.

                            END. /* FIM operacao de autorizacao */
                            
                    END. /* Fim importacao */

                    INPUT STREAM str_1 CLOSE.

                    /* Remove o arquivo temporario */
                    UNIX SILENT VALUE("rm /usr/coop/cecred/arq/" + aux_nmarquiv).
                    
                    /* confronta com os TAAs ativos cadastrados no sistema */
                    FOR EACH craptfn WHERE
                             craptfn.cdsitfin <> 8 /* 8-Desativado */
                             NO-LOCK BREAK BY craptfn.cdagenci:

                        IF  FIRST-OF(craptfn.cdagenci)  THEN
                            FIND crapage WHERE 
                                 crapage.cdcooper = craptfn.cdcooper AND
                                 crapage.cdagenci = craptfn.cdagenci
                                 NO-LOCK NO-ERROR.

                        IF  AVAIL crapage THEN
                            ASSIGN aux_nmresage = crapage.nmresage.
                        ELSE 
                            ASSIGN aux_nmresage = "".

                        FIND crattfn WHERE
                             crattfn.cdcoptfn = craptfn.cdcooper AND
                             crattfn.nrterfin = craptfn.nrterfin
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                        IF  NOT AVAIL crattfn THEN
                            DO:
                                CREATE crattfn.
                                ASSIGN crattfn.cdcoptfn = craptfn.cdcooper
                                       crattfn.cdagetfn = craptfn.cdagenci
                                       crattfn.nrterfin = craptfn.nrterfin
                                       crattfn.dstransa = "00:00:00".
                            END.

                        ASSIGN crattfn.nmnarede = craptfn.nmnarede
                               crattfn.nmagetfn = STRING(crattfn.cdagetfn,"zz9")
                                                  + "-" + aux_nmresage.

                        /* Para os TAAs que estao abaixo do horario de
                         tolerancia, executa o PING para verificar se estao na
                         rede e deleta os demais para nao aparecerem no browse*/

                        IF  crattfn.dstransa < aux_dstramax  THEN
                            RUN verifica_ping(INPUT crattfn.nmnarede).
                        ELSE
                            DELETE crattfn.

                    END. /* FOR EACH craptfn  */
                    
                END. /* par_cddopcao = M */
            WHEN "L" THEN
                DO:
                    IF (par_cddepart <> 20   AND   /* TI */
                        par_cddepart <> 18) THEN   /* SUPORTE */
                        DO:
                            ASSIGN aux_dscritic = "Opcao nao liberada para" +
                                                  " esta tela.".
                            LEAVE Busca.
                        END.
                    
                    FOR FIRST craptfn WHERE 
                              craptfn.cdcooper = par_cdcooper AND
                              craptfn.nrterfin = par_nrterfin NO-LOCK: END.

                    IF  NOT AVAIL craptfn THEN
                        DO:
                            ASSIGN aux_dscritic = "Terminal financeiro nao " +
                                                  "cadastrado!".
                            LEAVE Busca.
                        END.

                    FIND crapope WHERE crapope.cdcooper = par_cdcooper     AND
                                       crapope.cdoperad = craptfn.cdoperad 
                                       NO-LOCK NO-ERROR.

                    IF  NOT AVAIL crapope THEN
                        ASSIGN aux_nmoperad = STRING(craptfn.cdoperad,"x(10)") +
                                              " - NAO CADASTRADO".
                    ELSE
                        ASSIGN aux_nmoperad = crapope.nmoperad.

                    CASE craptfn.cdsitfin:
                        WHEN 1 THEN ASSIGN aux_dssittfn = "ABERTO".
                        WHEN 2 THEN ASSIGN aux_dssittfn = "FECHADO".
                        WHEN 3 THEN ASSIGN aux_dssittfn = "BLOQUEADO".
                        WHEN 4 THEN ASSIGN aux_dssittfn = "SUPRIDO".
                        WHEN 5 THEN ASSIGN aux_dssittfn = "RECOLHIDO".

                        /* Estado temporario, nao usado */
                        WHEN 6 THEN ASSIGN aux_dssittfn = "DESBLOQUEADO".

                        WHEN 7 THEN ASSIGN aux_dssittfn = "EM TRANSPORTE".
                        OTHERWISE   ASSIGN aux_dssittfn = "DESATIVADO".
                    END CASE.

                    CREATE tt-terminal.
                    ASSIGN tt-terminal.nmoperad = aux_nmoperad
                           tt-terminal.dsterfin = " - " + craptfn.nmterfin
                           
                           tt-terminal.nrdlacre[1] = craptfn.nrdlacre[1]
                           tt-terminal.qtnotcas[1] = craptfn.qtnotcas[1]
                           tt-terminal.vlnotcas[1] = craptfn.vlnotcas[1]
                           tt-terminal.vltotcas[1] = craptfn.vltotcas[1]
                                                                        
                           tt-terminal.nrdlacre[2] = craptfn.nrdlacre[2]
                           tt-terminal.qtnotcas[2] = craptfn.qtnotcas[2]
                           tt-terminal.vlnotcas[2] = craptfn.vlnotcas[2]
                           tt-terminal.vltotcas[2] = craptfn.vltotcas[2]
                                                                        
                           tt-terminal.nrdlacre[3] = craptfn.nrdlacre[3]
                           tt-terminal.qtnotcas[3] = craptfn.qtnotcas[3]
                           tt-terminal.vlnotcas[3] = craptfn.vlnotcas[3]
                           tt-terminal.vltotcas[3] = craptfn.vltotcas[3]
                                                                        
                           tt-terminal.nrdlacre[4] = craptfn.nrdlacre[4]
                           tt-terminal.qtnotcas[4] = craptfn.qtnotcas[4]
                           tt-terminal.vlnotcas[4] = craptfn.vlnotcas[4]
                           tt-terminal.vltotcas[4] = craptfn.vltotcas[4]

                           tt-terminal.nrdlacre[5] = craptfn.nrdlacre[5]
                           tt-terminal.qtnotcas[5] = craptfn.qtnotcas[5]
                           tt-terminal.vltotcas[5] = craptfn.vlnotcas[5]

                           tt-terminal.qtenvelo = craptfn.qtenvelo

                           tt-terminal.dssittfn = aux_dssittfn

                           tt-terminal.qtdnotag = craptfn.qtnotcas[1] +
                                                  craptfn.qtnotcas[2] +
                                                  craptfn.qtnotcas[3] +
                                                  craptfn.qtnotcas[4] +
                                                  craptfn.qtnotcas[5]

                           tt-terminal.vltotalG = craptfn.vltotcas[1] +
                                                  craptfn.vltotcas[2] +
                                                  craptfn.vltotcas[3] +
                                                  craptfn.vltotcas[4] +
                                                  craptfn.vlnotcas[5]
                            
                           tt-terminal.vltotalP = 0.

                    /* se o terminal possui sistema antigo, calcula a
                      quantidade de envelopes */
                    IF  NOT craptfn.flsistaa THEN
                        RUN proc_depositos_efetuados
                        ( INPUT par_cdcooper,
                          INPUT craptfn.nrterfin,
                         OUTPUT tt-terminal.qtenvelo).
                    
                END. /* par_cddopcao = L */
            WHEN "R" THEN
                DO:
                    FIND FIRST crapcop WHERE 
                               crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

                    IF  NOT AVAIL crapcop THEN
                        DO:
                            ASSIGN aux_cdcritic = 651.
                            LEAVE Busca.
                        END.

                    /* Tipo de Rel. Depositos */
                    IF  par_opcaorel <> "Depositos" THEN DO:
                        
                        RUN processa_opcaor
                            ( INPUT par_cdcooper,
                              INPUT par_cdprogra,
                              INPUT par_dtmvtini,
                              INPUT par_dtmvtfim ).
                    END.

                    IF  par_cddoptel = "T" THEN
                        DO:

                            ASSIGN aux_nmendter = "/usr/coop/" + 
                                                  crapcop.dsdircop +
                                                  "/arq/cash-" +
                                                  TRIM(STRING(YEAR(TODAY)) +
                                                  STRING(MONTH(TODAY)) +
                                                  STRING(DAY(TODAY)) +
                                                  STRING(TIME)).

                            UNIX SILENT VALUE("rm " + aux_nmendter +
                                                     "* 2>/dev/null").
                            
                            ASSIGN aux_nmarqimp = aux_nmendter + ".ex"
                                   aux_nmarqpdf = aux_nmendter + ".pdf".

                            OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp)
                                 PAGED PAGE-SIZE 84.
                        
                            /* Tipo de Rel. Depositos */
                            IF  par_opcaorel = "Depositos" THEN DO:

                                RUN pi_impressao_relat_depositos(INPUT par_cdcooper,
                                                                 INPUT par_dtmvtolt,
                                                                 INPUT par_nrterfin,
                                                                 INPUT par_dtmvtini,
                                                                 INPUT par_dtmvtfim,
                                                                 INPUT par_cdsitenv,
                                                                 OUTPUT TABLE tt-erro).

                                IF  RETURN-VALUE <> "OK" THEN DO:
                                    ASSIGN aux_dscritic = "Nao foi possivel gerar o relatorio.".
                                    
                                    LEAVE Busca.
                                END.

                            END.
                            ELSE DO: /* Tipo de Rel. Movimentacoes */
    
                                 /* Se informou PAC, mostra com Analitico */
                                IF  par_lgagetfn THEN
                                    ASSIGN par_tiprelat = TRUE.
    
                                 /* Analitico*/
                                IF  par_tiprelat THEN
                                    DO:
                                        /** SAQUES INTERCOOP - TAA **/
                                        RUN pi_opcaor_tela_taa_analit 
                                            (INPUT 1,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                         /** SQ INTERCOOP - OUTRAS **/
                                        RUN pi_opcaor_tela_outras_coop
                                            (INPUT 2,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                         /** PAGAMENTOS - TAA **/
                                        RUN pi_opcaor_tela_taa_analit
                                            (INPUT 3,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                        RUN pi_opcaor_tela_outras_coop
                                            (INPUT 4,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                         /** CONSULTA DE SALDOS - TAA */
                                        RUN pi_opcaor_tela_taa_analit
                                            (INPUT 5,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                        RUN pi_opcaor_tela_outras_coop
                                            (INPUT 6,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                         /** IMPRESSAO DE SALDO - TAA */
                                        RUN pi_opcaor_tela_taa_analit
                                            (INPUT 7,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                        RUN pi_opcaor_tela_outras_coop
                                            (INPUT 8,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                         /** IMPRESSAO DE EXTR. - TAA */
                                        RUN pi_opcaor_tela_taa_analit
                                            (INPUT 9,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                        RUN pi_opcaor_tela_outras_coop
                                            (INPUT 10,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                         /* IMPR. EXTR. APLIC. - TAA */
                                        RUN pi_opcaor_tela_taa_analit
                                            (INPUT 11,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                        RUN pi_opcaor_tela_outras_coop
                                            (INPUT 12,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                         /* CONSULTA DE AGENDAMENTOS - TAA */
                                        RUN pi_opcaor_tela_taa_analit
                                            (INPUT 13,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                        RUN pi_opcaor_tela_outras_coop
                                            (INPUT 14,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                         /* EXCLUSAO DE AGENDAMENTOS - TAA */
                                        RUN pi_opcaor_tela_taa_analit
                                            (INPUT 15,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                        RUN pi_opcaor_tela_outras_coop
                                            (INPUT 16,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                         /* AGEND.PAGTOS - TAA */
                                        RUN pi_opcaor_tela_taa_analit
                                            (INPUT 17,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                        RUN pi_opcaor_tela_outras_coop
                                            (INPUT 18,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                         /* TRANSFERENCIAS - TAA */
                                        RUN pi_opcaor_tela_taa_analit
                                            (INPUT 19,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                        RUN pi_opcaor_tela_outras_coop
                                            (INPUT 20,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                         /* AGEND. TRANSFERENCIAS - TAA */
                                        RUN pi_opcaor_tela_taa_analit
                                            (INPUT 21,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                        RUN pi_opcaor_tela_outras_coop
                                            (INPUT 22,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                         /* IMPRESSAO DE COMPROVANTES - TAA */
                                        RUN pi_opcaor_tela_taa_analit
                                            (INPUT 23,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                        RUN pi_opcaor_tela_outras_coop
                                            (INPUT 24,
                                             INPUT par_lgagetfn,
                                             INPUT par_cdagetfn,
                                             INPUT aux_cdagetfn).
    
                                    END.
                                ELSE
                                    RUN pi_opcaor_tela_taa_sintet
                                        (INPUT par_dtmvtini,
                                         INPUT par_dtmvtfim,   
                                         INPUT par_lgagetfn,   
                                         INPUT par_cdagetfn,   
                                         INPUT aux_cdagetfn).
                            
                            END. /* Fim do IF de Opcoes de Impressao */ 
                            
                            OUTPUT STREAM str_1 CLOSE.

                            IF  par_idorigem = 5 THEN  /** Ayllos Web **/
                                DO: 
                                    IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                                        RUN sistema/generico/procedures/b1wgen0024.p 
                                            PERSISTENT SET h-b1wgen0024.

                                    IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                                        DO:
                                            ASSIGN aux_dscritic = "Handle invalido para BO " +
                                                                  "b1wgen0024.".
                                            LEAVE Busca.
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
                                        LEAVE Busca.
                                END.

                        END. /* IF  par_cddoptel = "T" */
                    ELSE 
                    IF  par_cddoptel = "A" THEN
                        DO:
                            ASSIGN aux_nmarquiv = "/micros/" + 
                                                  crapcop.dsdircop + "/" +
                                                  par_nmarqimp.
                               
                            RUN pi_opcaor_zera_vars.

                            ASSIGN aux_nmarqimp = aux_nmarquiv + ".txt"
                                   aux_nmarqpdf = aux_nmarquiv + ".pdf".
                               
                            OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv + "_1")
                                 PAGED PAGE-SIZE 84.

                            /* Tipo de Rel. Depositos */
                            IF  par_opcaorel = "Depositos" THEN DO:

                                RUN pi_impressao_relat_depositos(INPUT par_cdcooper,
                                                                 INPUT par_dtmvtolt,
                                                                 INPUT par_nrterfin,
                                                                 INPUT par_dtmvtini,
                                                                 INPUT par_dtmvtfim,
                                                                 INPUT par_cdsitenv,
                                                                 OUTPUT TABLE tt-erro).

                                IF  RETURN-VALUE <> "OK" THEN DO:
                                    ASSIGN aux_dscritic = "Nao foi possivel gerar o relatorio.".
                                    
                                    LEAVE Busca.
                                END.

                            END.
                            ELSE DO: /* Rel de Movimentacoes */
                                IF  par_tiprelat THEN DO: /* Analitico */
    
                                    IF  par_lgagetfn THEN DO:
                                        ASSIGN aux_dsheader = 
                                        "Data Inicial;Data Final;Referencia;" +
                                        "PA da Operacao;Operacao;Tp.Consulta;" + 
                                       "Cooperativa;QtdCooperados;QtdMovimentos;" +
                                        "VlrTotal;VlrTarifa;".
                                        PUT STREAM str_1 aux_dsheader
                                            FORMAT "x(200)" SKIP.
                                    END.
                                    ELSE DO:
    
                                        ASSIGN aux_dsheader = 
                                            "Data Inicial;Data Final;Referencia;" +
                                            "Operacao;Tp.Consulta;Cooperativa;"   +
                                            "QtdCooperados;QtdMovimentos;"        +
                                            "VlrTotal;VlrTarifa;".
                                        PUT STREAM str_1 aux_dsheader 
                                            FORMAT "x(200)" SKIP.
                                    END.
                                    RUN pi_opcaor_arquivo_analitico
                                        (INPUT par_dtmvtini,
                                         INPUT par_dtmvtfim,   
                                         INPUT par_lgagetfn,   
                                         INPUT par_cdagetfn,   
                                         INPUT aux_cdagetfn).
                                END.
                                ELSE DO: /* Sintetico */
    
                                    ASSIGN aux_dsheader = 
                                        "Data Inicial;Data Final;Referencia;" +
                                        "Tipo;Cooperativa;"   +
                                        "QtdCooperados;QtdMovimentos;"        +
                                        "VlrTotal;VlrTarifa;".
                                        PUT STREAM str_1 aux_dsheader
                                            FORMAT "x(200)" SKIP.
    
                                    RUN pi_opcaor_arquivo_sintetico
                                        (INPUT par_dtmvtini,
                                         INPUT par_dtmvtfim).
                                END.
                            END.

                            OUTPUT STREAM str_1 CLOSE.

                            UNIX SILENT VALUE("ux2dos " + aux_nmarquiv    + 
                                              "_1" + " > " + aux_nmarqimp +
                                              " 2>/dev/null").
                 
                            UNIX SILENT VALUE("rm " + aux_nmarquiv +
                                              "_1 2>/dev/null").
                            
                        END.
                    
                END. /* par_cddopcao = R */
        END CASE.

        LEAVE Busca.
        
    END. /* Busca */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

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

PROCEDURE busca_dados_cartoes_magneticos:
          
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_lgagetfn AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cdagetfn AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddoptel AS CHAR                           NO-UNDO.

    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_cdagetfn AS INTE                                    NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmendter AS CHAR                                    NO-UNDO.
    DEF VAR aux_dstelefo AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsheader AS CHAR                                    NO-UNDO.

    DEF VAR aux_cdagenci LIKE crapass.cdagenci                      NO-UNDO.

    EMPTY TEMP-TABLE tt-crapcrm.

    Busca: 
    DO ON ERROR UNDO Busca, LEAVE Busca:

       EMPTY TEMP-TABLE tt-erro.
       
       FIND FIRST crapcop 
                  WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
       IF NOT AVAIL crapcop THEN
          DO:
              ASSIGN aux_cdcritic = 651.
              LEAVE Busca.
          END.

       ASSIGN aux_cdagetfn = IF par_cdagetfn = 0 THEN 9999 ELSE par_cdagetfn.

       /* Terminal */ 
       IF par_cddoptel = "T" THEN
          DO:
              ASSIGN aux_dstitulo = "RELATORIO CARTOES MAGNETICOS DISPONIVEIS"
                     aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + 
                                    "/arq/"      + par_nmarqimp
                     aux_nmarqimp = aux_nmarquiv + ".ex"
                     aux_nmarqpdf = aux_nmarquiv + ".pdf".

              UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
              
              OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp).
        
              DISPLAY STREAM str_1 
                             aux_dstitulo
                             WITH FRAME f_tela_titulo.
          END.
       ELSE
          DO:
              ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + "/" +
                                    par_nmarqimp
                     aux_nmarqimp = aux_nmarquiv + ".txt"
                     aux_nmarqpdf = aux_nmarquiv + ".pdf"
                     aux_dsheader = "Coop;PA;Conta/Dv.;Tit.Conta;Tit.Crd;" +
                                    "Dt.Solicitacao;Dt.Emissao;Validade;"   +
                                    "Telefone;".

              OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv + "_1").
              
              PUT STREAM str_1 aux_dsheader FORMAT "x(600)" SKIP.
          END.

       FOR EACH crapcrm FIELD(cdcooper nrdconta dtemscar nrcartao nmtitcrd dttransa dtvalcar)
          WHERE crapcrm.cdcooper = crapcop.cdcooper  AND
                crapcrm.cdsitcar = 1                 AND
                crapcrm.dtvalcar > par_dtmvtolt      
                NO-LOCK,

           FIRST crapass FIELDS(cdcooper cdagenci nrdconta nmprimtl) WHERE 
                               crapass.cdcooper = crapcrm.cdcooper AND
                               crapass.nrdconta = crapcrm.nrdconta AND
                               crapass.cdagenci >= par_cdagetfn    AND
                               crapass.cdagenci <= aux_cdagetfn    
                               NO-LOCK:
           /*
           FIRST crapage WHERE crapage.cdcooper = crapass.cdcooper AND
                               crapage.cdagenci = crapass.cdagenci 
                               NO-LOCK  BREAK BY crapcop.cdcooper
                                               BY crapass.cdagenci
                                                BY crapass.nrdconta
                                                 BY crapcrm.nrcartao:
           */
                 /* Verifica se a remessa ja chegou */
                 FIND craptab WHERE craptab.cdcooper = crapcrm.cdcooper AND
                                    craptab.nmsistem = "CRED"           AND
                                    craptab.tptabela = "AUTOMA"         AND
                                    craptab.cdempres = 0                AND
                                    craptab.cdacesso = "CM" +
                                                       STRING(crapcrm.dtemscar,
                                                              "99999999") AND
                                    craptab.tpregist = 0 
                                    NO-LOCK NO-ERROR.
                
                 IF NOT AVAILABLE craptab         OR 
                    TRIM(craptab.dstextab) <> "1" THEN
                    NEXT.

                 ASSIGN aux_dstelefo = "".

                 FOR EACH craptfc WHERE craptfc.cdcooper = crapcrm.cdcooper  AND
                                        craptfc.nrdconta = crapcrm.nrdconta  AND
                                        craptfc.idseqttl = 1                 
                                        NO-LOCK:

                     ASSIGN aux_dstelefo = aux_dstelefo +
                                           STRING(craptfc.nrdddtfc) + "-" +
                                           STRING(craptfc.nrtelefo) + " / ".
                 END.

                 ASSIGN aux_dstelefo = SUBSTRING(aux_dstelefo,1,
                                       LENGTH(aux_dstelefo) - 3).

                 CREATE tt-crapcrm.
                 ASSIGN tt-crapcrm.cdcooper = crapcop.cdcooper
                        tt-crapcrm.nmrescop = crapcop.nmrescop
                        tt-crapcrm.cdagenci = crapass.cdagenci
                        tt-crapcrm.nrdconta = crapcrm.nrdconta
                        tt-crapcrm.nmprimtl = crapass.nmprimtl
                        tt-crapcrm.nrcartao = crapcrm.nrcartao
                        tt-crapcrm.nmtitcrd = crapcrm.nmtitcrd
                        tt-crapcrm.dttransa = crapcrm.dttransa
                        tt-crapcrm.dtemscar = crapcrm.dtemscar
                        tt-crapcrm.dtvalcar = crapcrm.dtvalcar
                        tt-crapcrm.dstelefo = aux_dstelefo.
                      
                 
       END.

       ASSIGN aux_cdagenci = 0.

       FOR EACH tt-crapcrm NO-LOCK.

           IF tt-crapcrm.cdagenci <> aux_cdagenci  THEN DO:

               FIND FIRST crapage WHERE 
                          crapage.cdcooper = tt-crapcrm.cdcooper AND
                          crapage.cdagenci = tt-crapcrm.cdagenci 
                          NO-LOCK NO-ERROR.

               ASSIGN aux_cdagenci = tt-crapcrm.cdagenci.

           END.

             /* Terminal */ 
             IF par_cddoptel = "T" THEN
                DISPLAY STREAM str_1
                        STRING(tt-crapcrm.cdcooper) + "-" + tt-crapcrm.nmrescop
                          FORMAT "x(15)" COLUMN-LABEL "Coop."
                        STRING(tt-crapcrm.cdagenci) + "-" + crapage.nmresage 
                          FORMAT "x(18)" COLUMN-LABEL "PA"
                        tt-crapcrm.nrdconta COLUMN-LABEL "Conta/Dv."
                        tt-crapcrm.nmprimtl COLUMN-LABEL "Tit.Conta"
                        tt-crapcrm.nrcartao
                        tt-crapcrm.nmtitcrd COLUMN-LABEL "Tit.Crd"
                        tt-crapcrm.dttransa COLUMN-LABEL "Dt.Solicitacao"
                        tt-crapcrm.dtemscar COLUMN-LABEL "Dt.Emissao"
                        tt-crapcrm.dtvalcar COLUMN-LABEL "Validade"
                        tt-crapcrm.dstelefo     COLUMN-LABEL "Telefone"    
                            FORMAT "x(60)" WITH WIDTH 600.
             ELSE
                /* Arquivo */  
                PUT STREAM str_1 
                    STRING(tt-crapcrm.cdcooper) + "-" + tt-crapcrm.nmrescop
                      FORMAT "x(15)" ";"
                    STRING(tt-crapcrm.cdagenci) + "-" + crapage.nmresage 
                      FORMAT "x(18)" ";"
                    tt-crapcrm.nrdconta ";"
                    tt-crapcrm.nmprimtl ";"
                    tt-crapcrm.nrcartao ";"
                    tt-crapcrm.nmtitcrd ";"
                    tt-crapcrm.dttransa FORMAT "99/99/9999" ";"
                    tt-crapcrm.dtemscar FORMAT "99/99/9999" ";"
                    tt-crapcrm.dtvalcar FORMAT "99/99/9999" ";"
                    tt-crapcrm.dstelefo     FORMAT "x(60)" ";" 
                    SKIP.

       END.
           
       OUTPUT STREAM str_1 CLOSE.
       
       /** Terminal e Ayllos Web */
       IF par_cddoptel = "T" AND par_idorigem = 5 THEN
          DO:
              IF NOT VALID-HANDLE(h-b1wgen0024) THEN
                 RUN sistema/generico/procedures/b1wgen0024.p 
                 PERSISTENT SET h-b1wgen0024.
                    
              IF NOT VALID-HANDLE(h-b1wgen0024)  THEN
                 DO:
                     ASSIGN aux_dscritic = "Handle invalido " +
                                           "para BO b1wgen0024.".
                     LEAVE Busca.
                 END.
                    
              RUN envia-arquivo-web IN h-b1wgen0024 
                ( INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa,
                  INPUT aux_nmarqimp,
                  OUTPUT aux_nmarqpdf,
                  OUTPUT TABLE tt-erro ).
                    
              IF VALID-HANDLE(h-b1wgen0024) THEN
                 DELETE PROCEDURE h-b1wgen0024.
                    
              IF RETURN-VALUE <> "OK" THEN
                 LEAVE Busca.
          END.
       ELSE
          IF par_cddoptel = "A" THEN
             DO:
                 UNIX SILENT VALUE("ux2dos " + aux_nmarquiv  + "_1" +
                                   " > " + aux_nmarqimp + " 2>/dev/null").
              
                 UNIX SILENT VALUE("rm " + aux_nmarquiv  + "_1 2>/dev/null").
             END.
                        
       LEAVE Busca.

    END.
        
    IF aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
       DO:
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
    
END PROCEDURE. /* busca_dados_cartoes_magneticos */

/* ------------------------------------------------------------------------- */
/*                  Efetua a Validação dos dados informados                  */
/* ------------------------------------------------------------------------- */
PROCEDURE Valida_Pac:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagetfn AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_lgagetfn AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM aux_nmdireto AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_dsagetfn AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Valida Situacao dos Terminais Financeiros"
           aux_cdcritic = 0
           aux_returnvl = "NOK".
    
    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.

        FIND FIRST crapcop WHERE 
                   crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapcop THEN
            DO:
                ASSIGN aux_cdcritic = 651.
                LEAVE Valida.
            END.

        ASSIGN aux_nmdireto = "/micros/" + crapcop.dsdircop + "/".

        IF  NOT par_lgagetfn THEN
            LEAVE Valida.

        IF  par_cdagetfn <> 0 THEN
            DO:
                FOR FIRST crapage FIELDS(nmresage)
                    WHERE crapage.cdcooper = par_cdcooper AND
                          crapage.cdagenci = par_cdagetfn NO-LOCK: END.

                IF  NOT AVAIL crapage THEN
                    DO:
                        ASSIGN aux_cdcritic = 962.
                        LEAVE Valida.
                    END.

                ASSIGN aux_dsagetfn = crapage.nmresage.
                
            END.
        ELSE
            ASSIGN aux_dsagetfn = "TODOS".


        LEAVE Valida.

    END. /* Valida */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
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

END PROCEDURE. /* Valida_Pac */

/* ------------------------------------------------------------------------ */
/*                     EFETUA A BUSCA                                       */
/* ------------------------------------------------------------------------ */
PROCEDURE Opcao_Transacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddoptrs AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrterfin AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtlimite AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitfin AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtinicio AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdfinal AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitenv AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM aux_dtlimite AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM aux_qtsaques AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM aux_vlsaques AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM aux_qtestorn AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM aux_vlestorn AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM aux_cdsitfin AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM aux_flgblsaq AS LOGICAL                        NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-transacao.
    DEF OUTPUT PARAM TABLE FOR tt-envelopes.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgexist AS LOGI                                    NO-UNDO.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_flgexist = NO
           aux_dstransa = "Busca Dados ".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-transacao.
        EMPTY TEMP-TABLE tt-envelopes.
        EMPTY TEMP-TABLE tt-erro.
        
        IF  par_cddoptrs = "L" THEN /* Lista das Transacoes */
            DO:

                /* */
                IF  par_dtlimite = ?              OR
                    par_dtlimite > par_dtmvtopr   THEN
                    par_dtlimite = par_dtmvtolt.


                FOR EACH crapltr WHERE crapltr.cdcoptfn = par_cdcooper AND
                                       crapltr.dtmvtolt = par_dtlimite AND
                                       crapltr.nrterfin = par_nrterfin
                                       NO-LOCK BREAK BY crapltr.dtmvtolt
                                                       BY crapltr.nrsequni:

                    CASE crapltr.cdhistor:
                        WHEN 316 THEN 
                            ASSIGN aux_dstransa = "Saque".
                        WHEN 918 THEN
                            ASSIGN aux_dstransa = "Saque (COOP " + 
                                   STRING(crapltr.cdcooper) + ")".
                        WHEN 418 THEN
                            ASSIGN aux_dstransa = "Tarifa extrato".
                        WHEN 698 THEN
                            ASSIGN aux_dstransa = "Envelope".
                        WHEN 767 OR WHEN 359 THEN
                            ASSIGN aux_dstransa = "Estorno".
                        WHEN 920 THEN
                            ASSIGN aux_dstransa = "Estorno (COOP " +
                                      STRING(crapltr.cdcooper) + ")".
                        OTHERWISE
                            ASSIGN aux_dstransa = "Transf. C/C".
                    END CASE.

                    CREATE tt-transacao.
                    ASSIGN tt-transacao.dttransa = crapltr.dttransa
                           tt-transacao.dtmvtolt = crapltr.dtmvtolt
                           tt-transacao.hrtransa = STRING(crapltr.hrtransa,
                                                                    "HH:MM:SS")
                           tt-transacao.nrdconta = crapltr.nrdconta
                           tt-transacao.nrdocmto = crapltr.nrdocmto
                           tt-transacao.nrsequni = crapltr.nrsequni
                           tt-transacao.vllanmto = crapltr.vllanmto
                           tt-transacao.nrcartao = crapltr.nrcartao
                           tt-transacao.dstransa = aux_dstransa

                           aux_qtsaques = aux_qtsaques + 
                                                 (IF  crapltr.cdhistor = 698 OR
                                                      crapltr.cdhistor = 767 OR
                                                      crapltr.cdhistor = 359
                                                      THEN 0
                                                  ELSE 1)
                                             
                           aux_vlsaques = aux_vlsaques + 
                                                 (IF  crapltr.cdhistor = 316 OR 
                                                      crapltr.cdhistor = 918
                                                      THEN crapltr.vllanmto
                                                  ELSE 0)
                                                          
                           aux_qtestorn = aux_qtestorn + 
                                                 (IF  crapltr.cdhistor = 767 OR
                                                      crapltr.cdhistor = 359 OR
                                                      crapltr.cdhistor = 920
                                                      THEN 1
                                                  ELSE 0)

                           aux_vlestorn = aux_vlestorn + 
                                                 (IF  crapltr.cdhistor = 767 OR
                                                      crapltr.cdhistor = 359 OR
                                                      crapltr.cdhistor = 920
                                                      THEN crapltr.vllanmto 
                                                  ELSE 0)
                           aux_flgexist = YES.

                END. /* FOR EACH crapltr */

                IF  NOT aux_flgexist THEN
                    DO:
                        ASSIGN aux_dscritic = "Nao ha registros nesta data.".
                        LEAVE Busca.
                    END.
                
                ASSIGN aux_dtlimite = par_dtlimite.

            END. /* IF  par_cddoptrs = "L" */
        ELSE
        IF  par_cddoptrs = "B" THEN /* Bloquear/Desbloquear Cash */
            DO:
                ASSIGN aux_cdsitfin = par_cdsitfin.

                IF  par_cdsitfin = 3 THEN
                    DO:
                        /* verifica a situacao anterior ao bloqueio */
                        FOR EACH craplfn WHERE 
                                 craplfn.cdcooper =  par_cdcooper  AND
                                 craplfn.nrterfin =  par_nrterfin  AND
                                 /* bloqueio */
                                 craplfn.tpdtrans <> 3             AND
                                 /* desbloqueio */
                                 craplfn.tpdtrans <> 6             NO-LOCK
                                 BREAK BY craplfn.dttransa DESC
                                          BY craplfn.hrtransa DESC:
                            ASSIGN aux_cdsitfin = craplfn.tpdtrans.
                            LEAVE.
                        END. /* FOR EACH craplfn */

                        /* se nao achou situacao anterior */
                        IF  aux_cdsitfin = 3 THEN
                            ASSIGN aux_cdsitfin = 2. /* Fechado */
                    END.
                ELSE
                /* Bloqueando */
                ASSIGN aux_cdsitfin = 3.

                IF  NOT VALID-HANDLE(h-b1wgen0025) THEN
                    RUN sistema/generico/procedures/b1wgen0025.p
                        PERSISTENT SET h-b1wgen0025.

                RUN altera_situacao IN h-b1wgen0025 
                    ( INPUT par_cdcooper,
                      INPUT par_nrterfin,
                      INPUT aux_cdsitfin,
                      INPUT par_cdoperad,
                      INPUT par_dtmvtolt,
                      INPUT 0, /* Valor */
                     OUTPUT aux_dscritic).

                DELETE PROCEDURE h-b1wgen0025.

                IF  aux_dscritic <> "" THEN
                    LEAVE Busca.

            END. /* IF  par_cddoptrs = "B" */
        ELSE
        IF  par_cddoptrs = "S" THEN /* Bloquear/Desbloquear Saque */
            DO:
                RUN alterar_status_saque(INPUT par_cdcooper,
                                         INPUT par_cdoperad,
                                         INPUT par_nrterfin,
                                        OUTPUT aux_dscritic).
                
                IF  aux_dscritic <> "" THEN
                    LEAVE Busca.

                RUN status_saque(INPUT par_cdcooper,
                                 INPUT par_nrterfin,
                                OUTPUT aux_flgblsaq).

            END. /* IF  par_cddoptrs = "S" */
        ELSE
        IF  par_cddoptrs = "D" THEN /* Depositos */
            DO:
                IF (par_dtinicio <> ? AND par_dtdfinal = ?)  OR
                   (par_dtdfinal <> ? AND par_dtinicio = ?)  OR
                   (par_dtdfinal < par_dtinicio)             THEN
                   DO:
                       ASSIGN aux_cdcritic = 13.
                       LEAVE Busca.
                   END.
                ELSE
                IF (par_dtinicio < par_dtmvtolt - 60)  OR
                   (par_dtdfinal < par_dtmvtolt - 60)  THEN
                   DO:
                       ASSIGN aux_dscritic = "Data errada. Maximo 60 dias.".
                       LEAVE Busca.
                   END.
                
                IF  par_dtinicio = ?  AND
                    par_dtdfinal = ?  THEN
                    ASSIGN par_dtinicio = par_dtmvtolt
                           par_dtdfinal = par_dtmvtolt.

                IF  par_dtinicio <> ? THEN
                    FOR EACH crapenl WHERE
                             crapenl.cdcoptfn  = par_cdcooper AND
                             crapenl.nrterfin  = par_nrterfin AND
                             crapenl.dtmvtolt >= par_dtinicio AND
                             crapenl.dtmvtolt <= par_dtdfinal AND
                            (crapenl.cdsitenv  = par_cdsitenv OR
                             par_cdsitenv      = 9) /* Todos */
                             NO-LOCK BREAK BY crapenl.cdsitenv
                                               BY crapenl.dtmvtolt:

                        IF  FIRST-OF(crapenl.cdsitenv) THEN
                            ASSIGN tot_qtsitenv = 1
                                   tot_vlenvinf = 0
                                   tot_vlenvcmp = 0
                                   tot_vlchqinf = 0
                                   tot_vldininf = 0.

                        RUN cria_tt-envelopes.

                        IF  LAST-OF(crapenl.cdsitenv) THEN
                            DO:
                                CREATE tt-envelopes.
                                
                                CREATE tt-envelopes.
                                ASSIGN tt-envelopes.dtmvtolt = ""
                                       tt-envelopes.hrtransa = ""
                                       tt-envelopes.nrdconta = "     TOTAL"
                                       /* Desconsidera a ultima linha em branco */ 
                                       tt-envelopes.nrseqenv = 
                                             STRING(tot_qtsitenv - 1)

                                       tt-envelopes.dsespeci = "CH:"
                                       tt-envelopes.vlenvinf = STRING(tot_vlchqinf,"z,zzz,zz9.99")
                                       tt-envelopes.vlenvcmp = "      DN:"
                                       tt-envelopes.dssitenv = STRING(tot_vldininf,"z,zzz,zz9.99").
                    
                                CREATE tt-envelopes.
                            END.
                    END. /* FOR EACH crapenl */
                ELSE
                    FOR EACH crapenl WHERE 
                             crapenl.cdcoptfn  = par_cdcooper  AND
                             crapenl.nrterfin  = par_nrterfin  AND
                            (crapenl.cdsitenv  = par_cdsitenv  OR
                             par_cdsitenv      = 9) /* Todos */
                             NO-LOCK BREAK BY crapenl.cdsitenv
                                               BY crapenl.dtmvtolt:

                        IF  FIRST-OF(crapenl.cdsitenv) THEN
                            ASSIGN tot_qtsitenv = 1
                                   tot_vlenvinf = 0
                                   tot_vlenvcmp = 0
                                   tot_vldininf = 0
                                   tot_vlchqinf = 0.

                        RUN cria_tt-envelopes.

                        IF  LAST-OF(crapenl.cdsitenv) THEN
                            DO:
                                CREATE tt-envelopes.
                                
                                CREATE tt-envelopes.
                                ASSIGN tt-envelopes.dtmvtolt = ""
                                       tt-envelopes.hrtransa = ""
                                       tt-envelopes.nrdconta = "     TOTAL"
                                       /* Desconsidera a ultima linha em branco */ 
                                       tt-envelopes.nrseqenv = 
                                                       STRING(tot_qtsitenv - 1)

                                       tt-envelopes.dsespeci = "CH:"
                                       tt-envelopes.vlenvinf = STRING(tot_vlchqinf,"z,zzz,zz9.99")
                                       tt-envelopes.vlenvcmp = "      DN:"
                                       tt-envelopes.dssitenv = STRING(tot_vldininf,"z,zzz,zz9.99").
                    
                                CREATE tt-envelopes.
                            END.
                    END. /* FOR EACH crapenl */

                ASSIGN tt-envelopes.dtmvtolt = ""
                       tt-envelopes.hrtransa = "" 
                       tt-envelopes.nrdconta = "TOT. GERAL"
                       /* Desconsidera a ultima linha em branco */ 
                       tt-envelopes.nrseqenv = STRING(tot_qtsittot)
                       tt-envelopes.dsespeci = "CH:"
                       tt-envelopes.vlenvinf = STRING(tot_vlgerchq,"z,zzz,zz9.99")
                       tt-envelopes.vlenvcmp = "      DN:"
                       tt-envelopes.dssitenv = STRING(tot_vlgerdin,"z,zzz,zz9.99").
            END. /* IF  par_cddoptrs = "D" */

            ASSIGN tot_vlgerchq = 0
                   tot_vlgerdin = 0.

        LEAVE Busca.
        
    END. /* Busca */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

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

END PROCEDURE. /* Opcao_Transacao */

/* ------------------------------------------------------------------------ */
/*                     EFETUA A BUSCA                       */
/* ------------------------------------------------------------------------ */
PROCEDURE Opcao_Operacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtlimite AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrterfin AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM aux_dtlimite AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-transacao.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgexist AS LOGI                                    NO-UNDO.
    DEF VAR aux_dsoperad AS CHAR                                    NO-UNDO.
    DEF VAR aux_dstarefa AS CHAR EXTENT 6 INIT ["Abertura",         
                                                "Fechamento",
                                                "Bloqueio",
                                                "Suprimento",
                                                "Recolhimento",
                                                "Desbloqueio"]      NO-UNDO.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_flgexist = NO
           aux_dstransa = "Busca Dados ".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-transacao.
        EMPTY TEMP-TABLE tt-erro.

        /**/
        IF  par_dtlimite = ?              OR
            par_dtlimite > par_dtmvtopr   THEN
            par_dtlimite = par_dtmvtolt.

        FOR EACH craplfn WHERE craplfn.cdcooper = par_cdcooper AND
                               craplfn.dtmvtolt = par_dtlimite AND
                               craplfn.nrterfin = par_nrterfin 
                               NO-LOCK BY craplfn.dttransa
                                       BY craplfn.hrtransa:

            FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                               crapope.cdoperad = craplfn.cdoperad
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapope THEN
                ASSIGN aux_dsoperad = STRING(craplfn.cdoperad,"x(10)")
                                      + "-NAO CADASTRADO!".
            ELSE
                ASSIGN aux_dsoperad = STRING(craplfn.cdoperad,"x(10)")
                                          + "-" + crapope.nmoperad.

            CREATE tt-transacao.
            ASSIGN tt-transacao.dttransa = craplfn.dttransa
                   tt-transacao.dsoperad = aux_dsoperad
                   tt-transacao.vllanmto = craplfn.vltransa
                   tt-transacao.hrtransa = STRING(craplfn.hrtransa,"HH:MM:SS")
                   tt-transacao.dstarefa = aux_dstarefa[craplfn.tpdtrans]
                   aux_flgexist          = YES.

        END. /* FOR EACH craplfn */

        IF  NOT aux_flgexist THEN
            DO:
                ASSIGN aux_dscritic = "Nao ha registros nesta data.".
                LEAVE Busca.
            END.
        
        ASSIGN aux_dtlimite = par_dtlimite.
        LEAVE Busca.
        
    END. /* Busca */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

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

END PROCEDURE. /* Opcao_Operacao */

/* ------------------------------------------------------------------------ */
/*                     EFETUA A BUSCA                       */
/* ------------------------------------------------------------------------ */
PROCEDURE Opcao_Sensores:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrterfin AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-sensores.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dslocala AS CHAR                                    NO-UNDO.
    DEF VAR aux_dssensor AS CHAR                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    DEF VAR aux_dslocali AS CHAR EXTENT 15
                                       INIT ["Porta do Cofre",
                                             "Fechadura do Cofre",
                                             "Impressora",
                                             "Temperatura",
                                             "Modulo do Dispensador",
                                             "Vibracao",
                                             "Leitora de Codigo de Barras",
                                             "Saldo",
                                             "Depositario",
                                             "A definir",
                                             "A definir",
                                             "A definir",
                                             "A definir",
                                             "A definir",
                                             "A definir"]           NO-UNDO.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados ".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-sensores.
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST craptfn WHERE craptfn.cdcooper = par_cdcooper AND
                                craptfn.nrterfin = par_nrterfin NO-LOCK: END.

        IF  NOT AVAIL craptfn THEN
            DO:
                ASSIGN aux_dscritic = "Terminal financeiro nao " +
                                      "cadastrado!".
                LEAVE Busca.
            END.

        DO aux_contador = 1 TO 15:

            ASSIGN aux_dslocala = aux_dslocali[aux_contador].

            IF  craptfn.insensor[aux_contador] = 0 THEN
                ASSIGN aux_dssensor = "OK".
            ELSE
            IF  aux_contador = 1 THEN
                ASSIGN aux_dssensor = "ABERTA".
            ELSE
            IF  aux_contador = 2   THEN
                ASSIGN aux_dssensor = "ABERTA".
            ELSE
            IF  aux_contador = 3   THEN
                ASSIGN aux_dssensor =  IF  craptfn.insensor[3] = -2
                                           THEN "ERRO DE HARDWARE"
                                       ELSE
                                       IF  craptfn.insensor[3] = 101
                                           THEN "SEM PAPEL"
                                       ELSE 
                                       IF  craptfn.insensor[3] = 102
                                           THEN "DESLIGADA"
                                       ELSE
                                       IF  craptfn.insensor[3] = 103
                                           THEN "OFF LINE"
                                       ELSE
                                       IF  craptfn.insensor[3] = 104
                                           THEN "OCUPADA"
                                       ELSE
                                      IF  craptfn.insensor[3] = 106
                                          THEN "POUCO PAPEL"
                                      ELSE STRING(craptfn.insensor[3]) +
                                           " (INDETERM.)".
            ELSE
            IF  aux_contador = 4   THEN
                ASSIGN aux_dssensor = "ALTA".
            ELSE
            IF  aux_contador = 5   THEN
                ASSIGN aux_dssensor = "NAO ESTA TRAVADO".
            ELSE
            IF  aux_contador = 6   THEN
                ASSIGN aux_dssensor = "ALTA".
            ELSE
            IF  aux_contador = 8   THEN
                ASSIGN aux_dssensor = "** COM DIFERENCA **".
            ELSE
                ASSIGN aux_dssensor = IF  craptfn.insensor[aux_contador] = 0
                                          THEN "OK"
                                      ELSE
                                        STRING(craptfn.insensor[aux_contador]).

            CREATE tt-sensores.
            ASSIGN tt-sensores.dslocali = aux_dslocala
                   tt-sensores.dssensor = aux_dssensor.

        END. /* DO aux_contador */

        LEAVE Busca.
        
    END. /* Busca */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

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

END PROCEDURE. /* Opcao_Sensores */

PROCEDURE Opcao_Saldos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtlimite AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrterfin AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM aux_dtlimite AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-saldos.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados ".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-saldos.
        EMPTY TEMP-TABLE tt-erro.

        /**/
        IF  par_dtlimite = ?              OR
            par_dtlimite > par_dtmvtopr   THEN
            par_dtlimite = par_dtmvtolt.

        FOR FIRST crapstf WHERE crapstf.cdcooper = par_cdcooper   AND
                                crapstf.nrterfin = par_nrterfin   AND
                                crapstf.dtmvtolt = par_dtlimite
                                NO-LOCK: END.

        IF  NOT AVAILABLE crapstf THEN
            LEAVE Busca.

        CREATE tt-saldos.
        ASSIGN tt-saldos.vldsdini = crapstf.vldsdini
               tt-saldos.vldsdfin = crapstf.vldsdfin
               tt-saldos.vlsuprim = 0
               tt-saldos.vlrecolh = 0.

        /* saques */
        RUN verifica_movimento(INPUT crapstf.cdcooper,
                               INPUT crapstf.dtmvtolt,
                               INPUT crapstf.nrterfin,
                               INPUT 316).

        IF  AVAIL crapstd  THEN
            tt-saldos.vldsaque = tt-saldos.vldsaque + crapstd.vldmovto.

        RUN verifica_movimento(INPUT crapstf.cdcooper,
                               INPUT crapstf.dtmvtolt,
                               INPUT crapstf.nrterfin,
                               INPUT 918).

        IF  AVAIL crapstd  THEN
            tt-saldos.vldsaque = tt-saldos.vldsaque + crapstd.vldmovto.


        /* estornos */
        RUN verifica_movimento(INPUT crapstf.cdcooper,
                               INPUT crapstf.dtmvtolt,
                               INPUT crapstf.nrterfin,
                               INPUT 767).

        IF  AVAIL crapstd  THEN
            tt-saldos.vlestorn = tt-saldos.vlestorn + crapstd.vldmovto.

        RUN verifica_movimento(INPUT crapstf.cdcooper,
                               INPUT crapstf.dtmvtolt,
                               INPUT crapstf.nrterfin,
                               INPUT 359).

        IF  AVAIL crapstd  THEN
            tt-saldos.vlestorn = tt-saldos.vlestorn + crapstd.vldmovto.


        RUN verifica_movimento(INPUT crapstf.cdcooper,
                               INPUT crapstf.dtmvtolt,
                               INPUT crapstf.nrterfin,
                               INPUT 920).

        IF  AVAIL crapstd  THEN
            tt-saldos.vlestorn = tt-saldos.vlestorn + crapstd.vldmovto.


        /* rejeitados */
        RUN verifica_movimento(INPUT crapstf.cdcooper,
                               INPUT crapstf.dtmvtolt,
                               INPUT crapstf.nrterfin,
                               INPUT 9999).

        IF  AVAIL crapstd  THEN
            tt-saldos.vlrejeit = tt-saldos.vlrejeit + crapstd.vldmovto.


        FOR EACH craplfn WHERE craplfn.cdcooper = par_cdcooper AND
                               craplfn.nrterfin = par_nrterfin AND
                               craplfn.dtmvtolt = par_dtlimite NO-LOCK:

            IF  craplfn.tpdtrans = 4   THEN
                ASSIGN tt-saldos.vlsuprim = tt-saldos.vlsuprim +
                                            craplfn.vltransa.
            ELSE
            IF  craplfn.tpdtrans = 5   THEN
                ASSIGN tt-saldos.vlrecolh = tt-saldos.vlrecolh +
                                            craplfn.vltransa.

        END.  /*  Fim do FOR EACH - Leitura do log de operacao  */

        IF  (tt-saldos.vldsdini - tt-saldos.vldsaque +
             tt-saldos.vlsuprim - tt-saldos.vlrecolh +
             tt-saldos.vlestorn) <> tt-saldos.vldsdfin THEN
            ASSIGN tt-saldos.dsobserv = "** SALDO COM DIFERENCA **".
        ELSE
            ASSIGN tt-saldos.dsobserv = "     ** SALDO OK **".
        
        ASSIGN aux_dtlimite = par_dtlimite.
        LEAVE Busca.
        
    END. /* Busca */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

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

END PROCEDURE. /* Opcao_Saldos */

PROCEDURE Opcao_Log:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtlimite AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrterfin AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF  OUTPUT PARAM par_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM par_nmarqpdf AS CHAR                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_nmarqlog AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmendter AS CHAR                                    NO-UNDO.
    DEF VAR aux_dscomand AS CHAR                                    NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados ".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-erro.

        IF  par_dtlimite = ?              OR
            par_dtlimite > par_dtmvtopr   THEN
            par_dtlimite = par_dtmvtolt.

        FOR FIRST crabcop FIELDS(dsdircop) 
                          WHERE crabcop.cdcooper = par_cdcooper NO-LOCK:
        END.

        IF  NOT AVAILABLE crabcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651.
                LEAVE Busca.
            END.

        ASSIGN aux_nmendter = "/usr/coop/" + crabcop.dsdircop + "/rl/" +
                               par_dsiduser.
    
        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               par_nmarqimp = aux_nmendter + ".ex"
               par_nmarqpdf = aux_nmendter + ".pdf".

        FOR FIRST craptfn WHERE craptfn.cdcooper = par_cdcooper AND
                                craptfn.nrterfin = par_nrterfin NO-LOCK: END.

        IF  NOT AVAIL craptfn THEN
            DO:
                ASSIGN aux_dscritic = "Terminal financeiro nao" +
                                      " cadastrado!".
                LEAVE Busca.
           END.

        DO aux_contador = 1 TO 2:
            
            IF  aux_contador = 1 THEN  /*  Primeira Tentativa  */
                DO:
                    /* sistema TAA */
                    IF  craptfn.flsistaa  THEN
                        ASSIGN aux_nmarqlog = "/usr/coop/" + crabcop.dsdircop +
                                              "/log/cash/LG".
                    ELSE
                        ASSIGN aux_nmarqlog = "/usr/coop/" + crabcop.dsdircop +
                                              "/log/cash/lg".

                    ASSIGN aux_nmarqlog = aux_nmarqlog +
                                 STRING(par_nrterfin,"9999") + "_" +
                                 STRING(YEAR(par_dtlimite),"9999") +
                                 STRING(MONTH(par_dtlimite),"99") +
                                 STRING(DAY(par_dtlimite),"99") +
                                 ".log".
                    
                    IF  par_dtlimite = par_dtmvtolt THEN
                        DO:

                            RUN proc_log_do_dia( INPUT par_cdcooper,
                                                 INPUT par_dtmvtolt ).

                            IF  SEARCH(aux_nmarqlog) = ?   THEN
                                DO:
                                    ASSIGN aux_dscritic = "Problemas na" +
                                                    " atualizacao do log" +
                                                    " do dia!".
                                    LEAVE Busca.
                                END.

                        END.
                END.
            ELSE  /* 2a Tentativa para Logs anteriores a 13/10/09 */
                DO:
                    /* sistema TAA */
                    IF  craptfn.flsistaa  THEN
                        ASSIGN aux_nmarqlog = "log/cash/LG".
                    ELSE
                        ASSIGN aux_nmarqlog = "log/cash/lg".

                    ASSIGN aux_nmarqlog = aux_nmarqlog +
                                         STRING(par_nrterfin,"999") + "_" +
                                         STRING(YEAR(par_dtlimite),"9999") +
                                         STRING(MONTH(par_dtlimite),"99") +
                                         STRING(DAY(par_dtlimite),"99") +
                                         ".log".
                END.

            IF  SEARCH(aux_nmarqlog) = ? THEN
                DO:
                    IF  aux_contador = 2 THEN
                        DO:
                            ASSIGN aux_dscritic = "Log do dia " +
                                              STRING(par_dtlimite,"99/99/9999")
                                              + " nao encontrado.".
                            LEAVE Busca.
                        END.
                END.
            ELSE
                LEAVE.

        END. /* Fim DO..TO */

        ASSIGN aux_dscomand = "cp " + aux_nmarqlog + " " + par_nmarqimp
                                  + " 2> /dev/null".
        UNIX SILENT VALUE(aux_dscomand).

        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO: 
                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    RUN sistema/generico/procedures/b1wgen0024.p 
                        PERSISTENT SET h-b1wgen0024.

                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE Busca.
                    END.

                RUN envia-arquivo-web IN h-b1wgen0024 
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_nmarqimp,
                     OUTPUT par_nmarqpdf,
                     OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen0024)  THEN
                    DELETE PROCEDURE h-b1wgen0024.

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE Busca.
            END.

        LEAVE Busca.
        
    END. /* Busca */

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS
        THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
            ELSE
                DO:
                    FIND FIRST tt-erro NO-ERROR.

                    IF  AVAIL tt-erro THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                END.

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

END PROCEDURE. /* Opcao_Log */

/* ------------------------------------------------------------------------- */
/*                  Efetua a Validação dos dados informados                  */
/* ------------------------------------------------------------------------- */
PROCEDURE Valida_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrterfin AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitfin AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtcasset AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Valida Situacao dos Terminais Financeiros"
           aux_cdcritic = 0
           aux_returnvl = "NOK".
    
    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.

        CASE par_cddopcao:
            WHEN "A" THEN
                DO:
                    FOR FIRST craptfn FIELDS(cdsitfin)
                        WHERE craptfn.cdcooper = par_cdcooper AND
                              craptfn.nrterfin = par_nrterfin NO-LOCK: END.

                    IF  NOT AVAIL craptfn THEN
                        DO:
                            ASSIGN aux_dscritic = "Terminal financeiro nao " +
                                                  "cadastrado!".
                            LEAVE Valida.
                        END.

                    /* somente controla a situacao se o operador alterou ela */
                    IF  par_cdsitfin <> craptfn.cdsitfin  THEN
                        DO:
                            IF  NOT CAN-DO("2,8",STRING(par_cdsitfin)) THEN
                                DO:
                                    ASSIGN aux_dscritic = "Somente eh possivel modificar"
                                                        + " para a situacao 2 ou 8.".
                                    LEAVE Valida.
                                END.
                            
                            IF  craptfn.cdsitfin = 1 THEN
                                DO:
                                    ASSIGN aux_dscritic = "E necessario que o operador" +
                                                          " realize o fechamento.".
                                    LEAVE Valida.
                                END.
                        END.

                END. /* par_cddopcao = A */
            WHEN "I" THEN
                DO:
                    IF NOT CAN-FIND(crapage WHERE 
                                    crapage.cdcooper = par_cdcooper AND
                                    crapage.cdagenci = par_cdagencx) THEN
                        DO:
                            ASSIGN aux_cdcritic = 962.
                            LEAVE Valida.
                        END.

                    IF  par_qtcasset = 0 THEN
                        DO: 
                            ASSIGN aux_cdcritic = 375.
                            LEAVE Valida.
                        END.

                END. /* par_cddopcao = I */
        END CASE.

        LEAVE Valida.

    END. /* Valida */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
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

END PROCEDURE. /* Valida_Dados */

/* ------------------------------------------------------------------------- */
/*                 REALIZA A GRAVACAO DOS DADOS DA TELA BCAIXA               */
/* ------------------------------------------------------------------------- */
PROCEDURE Grava_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrterfin AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsfabtfn AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsmodelo AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdserie AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmnarede AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdendip AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitfin AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flsistaa AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsterfin AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_qtcasset AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtoan AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tprecolh AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_qttotalp AS INTE FORMAT "z,zz9"            NO-UNDO.
    DEF  INPUT PARAM par_flgntcem AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    
    DEF VAR aux_qtdnotaa AS INTE                                    NO-UNDO.
    DEF VAR aux_vldnotaa AS DECI                                    NO-UNDO.
    DEF VAR aux_vltotala AS DECI                                    NO-UNDO.
    DEF VAR aux_qtdnotab AS INTE                                    NO-UNDO.
    DEF VAR aux_vldnotab AS DECI                                    NO-UNDO.
    DEF VAR aux_vltotalb AS DECI                                    NO-UNDO.
    DEF VAR aux_qtdnotac AS INTE                                    NO-UNDO.
    DEF VAR aux_vldnotac AS DECI                                    NO-UNDO.
    DEF VAR aux_vltotalc AS DECI                                    NO-UNDO.
    DEF VAR aux_qtdnotad AS INTE                                    NO-UNDO.
    DEF VAR aux_vldnotad AS DECI                                    NO-UNDO.
    DEF VAR aux_vltotald AS DECI                                    NO-UNDO.
    DEF VAR aux_qtdnotag AS INTE                                    NO-UNDO.
    DEF VAR aux_vltotalg AS DECI                                    NO-UNDO.
    DEF VAR aux_qtdnotar AS INTE                                    NO-UNDO.
    DEF VAR aux_vltotalr AS DECI                                    NO-UNDO.
    DEF VAR aux_vlrecolh AS DECI FORMAT "zzz,zz9.99"                NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Grava Situacao dos Terminais Financeiros"
           aux_cdcritic = 0
           aux_flgtrans = FALSE
           aux_idorigem = par_idorigem
           aux_nmarqimp = ""
           aux_nmarqpdf = "".

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        CASE par_cddopcao:
            WHEN "A" THEN
                DO:  
                    Contador: DO aux_contador = 1 TO 10:

                        FIND craptfn WHERE craptfn.cdcooper = par_cdcooper AND
                                           craptfn.nrterfin = par_nrterfin
                                           EXCLUSIVE-LOCK NO-ERROR.
            
                        IF  NOT AVAIL craptfn THEN
                            DO:
                                IF  LOCKED(craptfn) THEN
                                    DO:
                                        IF  aux_contador = 10 THEN
                                            DO:
                                                FIND craptfn WHERE 
                                                     craptfn.cdcooper = 
                                                               par_cdcooper AND
                                                     craptfn.nrterfin = 
                                                                   par_nrterfin
                                                     NO-LOCK NO-ERROR.
                                                
                                                /* encontra o usuario que esta 
                                                   travando */
                                                ASSIGN aux_dscritic = 
                                              LockTabela( INPUT RECID(craptfn),
                                                             INPUT "craptfn").
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
                                        ASSIGN aux_dscritic = "Terminal " +
                                                  "financeiro nao cadastrado!".
                                        LEAVE Contador.
                                    END.
                            END.
                        ELSE
                            LEAVE Contador.
            
                    END. /* Contador */
    
                    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                        UNDO Grava, LEAVE Grava.
                     
                    FIND crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK 
                        NO-ERROR NO-WAIT.
                    
                    IF  NOT AVAIL crabcop  THEN
                        DO:
                            ASSIGN aux_dscritic = "Cooperativa nao cadastrada.".
                            UNDO Grava, LEAVE Grava.
                    END.
                    
                    /* Logar alteracao de PA */
                    IF  craptfn.cdagenci <> par_cdagencx  THEN
                    DO:
                        ASSIGN aux_dslogtel = aux_dslogtel + 
                            STRING(TODAY,"99/99/9999") + " - "   +
                            STRING(TIME,"HH:MM:SS") + " - "      +
                            "TAA: " + STRING(par_nrterfin) + " " +
                            par_dsterfin + " - " + "Operador "   + 
                            par_cdoperad + "-" + par_nmoperad    +
                            " efetuou alteracao no cadastro. De PA: " +
                            STRING(craptfn.cdagenci) + " para PA: " + 
                            STRING(par_cdagencx).
                    END.

                    /* Logar alteracao de uso de nota de cem */
                    IF  craptfn.flgntcem <> par_flgntcem  THEN
                    DO:
                        IF aux_dslogtel <> "" THEN
                            ASSIGN aux_dslogtel = aux_dslogtel + "'\r\n'".
                        ASSIGN aux_dslogtel = aux_dslogtel + 
                            STRING(TODAY,"99/99/9999") + " - "   +
                            STRING(TIME,"HH:MM:SS") + " - "      +
                            "TAA: " + STRING(par_nrterfin) + " " +
                            par_dsterfin + " - " + "Operador "   + 
                            par_cdoperad + "-" + par_nmoperad    +
                            " efetuou alteracao no cadastro. Campo: Usa notas de cem, de: " +
                            STRING(craptfn.flgntcem,'Sim/Nao') + " para: " + 
                            STRING(par_flgntcem,'Sim/Nao').
                    END.
                    
                    IF aux_dslogtel <> "" THEN
                        UNIX SILENT VALUE("echo " +
                        aux_dslogtel              +
                        " >> /usr/coop/"          + 
                        TRIM(crabcop.dsdircop)    + 
                        "/log/cash.log").

                    ASSIGN craptfn.dsfabtfn = CAPS(par_dsfabtfn)
                           craptfn.dsmodelo = CAPS(par_dsmodelo)
                           craptfn.dsdserie = par_dsdserie
                           craptfn.nmnarede = LC(TRIM(par_nmnarede))
                           craptfn.nrdendip = TRIM(par_nrdendip)
                           craptfn.cdsitfin = par_cdsitfin
                           craptfn.cdagenci = par_cdagencx
                           craptfn.flgntcem = par_flgntcem.
                    
                    
                END. /* par_cddopcao = A */
            WHEN "B" THEN
                DO:
                    Contador: DO aux_contador = 1 TO 10:

                        FIND craptfn WHERE craptfn.cdcooper = par_cdcooper AND
                                           craptfn.nrterfin = par_nrterfin
                                           EXCLUSIVE-LOCK NO-ERROR.
            
                        IF  NOT AVAIL craptfn THEN
                            DO:
                                IF  LOCKED(craptfn) THEN
                                    DO:
                                        IF  aux_contador = 10 THEN
                                            DO:
                                                FIND craptfn WHERE 
                                                     craptfn.cdcooper = 
                                                               par_cdcooper AND
                                                     craptfn.nrterfin = 
                                                                   par_nrterfin
                                                     NO-LOCK NO-ERROR.
                                                
                                                /* encontra o usuario que esta 
                                                   travando */
                                                ASSIGN aux_dscritic = 
                                              LockTabela( INPUT RECID(craptfn),
                                                             INPUT "craptfn").
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
                                        ASSIGN aux_dscritic = "Terminal " +
                                                  "financeiro nao cadastrado!".
                                        LEAVE Contador.
                                    END.
                            END.
                        ELSE
                            LEAVE Contador.
            
                    END. /* Contador */
    
                    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                        UNDO Grava, LEAVE Grava.

                    ASSIGN craptfn.flsistaa = par_flsistaa.
                END. /* par_cddopcao = B */
            WHEN "I" THEN
                DO:
                    CREATE craptfn.
                    ASSIGN craptfn.cdcooper = par_cdcooper
                           craptfn.cdagenci = par_cdagencx
                           craptfn.cdoperad = par_cdoperad  
                           craptfn.cdsitfin = 8 /* Desativado */
                           craptfn.nrterfin = par_nrterfin
                           craptfn.tpterfin = 6
                           craptfn.nmnarede = LC(TRIM(par_nmnarede))
                           craptfn.nrdendip = TRIM(par_nrdendip)
                           craptfn.nmterfin = STRING(CAPS(par_dsterfin),"x(25)")
                           craptfn.nrtempor = 20
                           craptfn.qtcasset = par_qtcasset
                           craptfn.dsfabtfn = CAPS(par_dsfabtfn)
                           craptfn.dsmodelo = CAPS(par_dsmodelo)
                           craptfn.dsdserie = par_dsdserie
                           craptfn.flsistaa = NO   /* inicial bloqueado */
                           craptfn.flupdate = YES  /* atualizar */
                           craptfn.flgntcem = par_flgntcem.
                    VALIDATE craptfn.
                    
                    CREATE crapstf.
                    ASSIGN crapstf.cdcooper = par_cdcooper
                           crapstf.nrterfin = craptfn.nrterfin
                           crapstf.dtmvtolt = par_dtmvtolt.
                    VALIDATE crapstf.
                                      
                    CREATE crapstf.
                    ASSIGN crapstf.cdcooper = par_cdcooper
                           crapstf.nrterfin = craptfn.nrterfin
                           crapstf.dtmvtolt = par_dtmvtoan.
                    VALIDATE crapstf.

                    FIND craptfn WHERE 
                         craptfn.cdcooper = par_cdcooper AND
                         craptfn.nrterfin = par_nrterfin NO-LOCK NO-ERROR.

                    IF  NOT AVAIL craptfn THEN
                        DO:
                            ASSIGN aux_dscritic = "Erro ao incluir o terminal!".
                            UNDO Grava, LEAVE Grava.
                        END.
                END. /* par_cddopcao = I */
            WHEN "L" THEN
                DO:
                    FOR FIRST crabcop WHERE 
                              crabcop.cdcooper = par_cdcooper NO-LOCK: END.

                    IF  par_tprecolh THEN
                        UNIX SILENT VALUE("echo "                             +
                                         STRING(TODAY,"99/99/9999") + " - "   +
                                         STRING(TIME,"HH:MM:SS") + " - "      +
                                         "TAA: " + STRING(par_nrterfin) + " " +
                                         par_dsterfin + " - " + "Operador "   + 
                                         par_cdoperad + "-" + par_nmoperad    +
                                         " efetuou o recolhimento de "        +
                                         STRING(par_qttotalp) + " envelopes." +
                                         " >> /usr/coop/" + 
                                         TRIM(crabcop.dsdircop) + 
                                         "/log/cash.log").
                    ELSE
                        DO: 
                            RUN Busca_Dados ( INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_cdoperad,
                                              INPUT par_cdprogra,
                                              INPUT par_idorigem,
                                              INPUT par_dtmvtolt,
                                              INPUT par_dtmvtopr,
                                              INPUT par_nmdatela,
                                              INPUT par_cddepart,
                                              INPUT par_cddopcao,
                                              INPUT par_nrterfin,
                                              INPUT NO, /* flsistaa */
                                              INPUT NO, /* mmtramax */
                                              INPUT "", /* dtmvtini */
                                              INPUT "", /* dtmvtfim */
                                              INPUT "", /* cddoptel */
                                              INPUT NO, /* lgagetfn */
                                              INPUT NO, /* tiprelat */
                                              INPUT 0,  /* cdagetfn */
                                              INPUT "",  /* nmarqimp */
                                              INPUT "",  /* cdsitenv */
                                              INPUT "",  /* opcaorel */
                                              INPUT TRUE, /* flgerlog */
                                             OUTPUT aux_nmarqimp,
                                             OUTPUT aux_nmarqpdf,
                                             OUTPUT TABLE tt-terminal,
                                             OUTPUT TABLE crattfn,
                                             OUTPUT TABLE tt-erro).

                            IF  RETURN-VALUE <> "OK" THEN
                                UNDO Grava, LEAVE Grava.

                            FIND FIRST tt-terminal NO-ERROR.

                            ASSIGN aux_qtdnotaa = tt-terminal.qtnotcas[1]
                                   aux_vldnotaa = tt-terminal.vlnotcas[1]
                                   aux_vltotala = tt-terminal.vltotcas[1]

                                   aux_qtdnotab = tt-terminal.qtnotcas[2]
                                   aux_vldnotab = tt-terminal.vlnotcas[2]
                                   aux_vltotalb = tt-terminal.vltotcas[2]

                                   aux_qtdnotac = tt-terminal.qtnotcas[3]
                                   aux_vldnotac = tt-terminal.vlnotcas[3]
                                   aux_vltotalc = tt-terminal.vltotcas[3]
                                   
                                   aux_qtdnotad = tt-terminal.qtnotcas[4]
                                   aux_vldnotad = tt-terminal.vlnotcas[4]
                                   aux_vltotald = tt-terminal.vltotcas[4]

                                   aux_qtdnotar = tt-terminal.qtnotcas[5]
                                   aux_vltotalr = tt-terminal.vltotcas[5]

                                   aux_qtdnotag = tt-terminal.qtdnotag
                                   aux_vltotalg = tt-terminal.vltotalg.
                            

                            UNIX SILENT VALUE("echo "                         +
                                STRING(TODAY,"99/99/9999") + " - "            +
                                STRING(TIME,"HH:MM:SS") + " - "               +
                                "TAA: " + STRING(par_nrterfin) + " "          +
                                par_dsterfin + " - " + "Operador "            + 
                                par_cdoperad + "-" + par_nmoperad             +
                                " efetuou o recolhimento de "                 +
                                "numerarios no valor de: '\\n'"               +
                                "'        QTD    Valor \\n'"                  +
                                "'  K7A:" + STRING(aux_qtdnotaa,"zzzz9")      +
                                " x " + STRING(aux_vldnotaa,"zz9.99")         +
                                " = " + STRING(aux_vltotala,"zzz,zzz,zz9.99") +
                                "\\n'"                                        +
                                "'  K7B:" + STRING(aux_qtdnotab,"zzzz9")      +
                                " x " + STRING(aux_vldnotab,"zz9.99")         +
                                " = " + STRING(aux_vltotalb,"zzz,zzz,zz9.99") +
                                "\\n'"                                        +
                                "'  K7C:" + STRING(aux_qtdnotac,"zzzz9")      + 
                                " x " + STRING(aux_vldnotac,"zz9.99")         +
                                " = " + STRING(aux_vltotalc,"zzz,zzz,zz9.99") +
                                "\\n'"                                        +
                                "'  K7D:" + STRING(aux_qtdnotad,"zzzz9")      +
                                " x " + STRING(aux_vldnotad,"zz9.99")         +
                                " = " + STRING(aux_vltotald,"zzz,zzz,zz9.99") +
                                "\\n'"                                        +
                                "'  Rej:" + STRING(aux_qtdnotar,"zzzz9")      +
                                "          = "                                +
                                STRING(aux_vltotalr,"zzz,zzz,zz9.99")         +
                                "\\n'"                                        +
                                "'TOTAL:"  + STRING(aux_qtdnotag,"zzzz9")     + 
                                "          = "                                + 
                                STRING(aux_vltotalg,"zzz,zzz,zz9.99") + "'"   +
                                " >> /usr/coop/" + TRIM(crabcop.dsdircop)     + 
                                "/log/cash.log").

                        END.
                    
                    IF  NOT VALID-HANDLE(h-b1wgen0025) THEN
                        RUN sistema/generico/procedures/b1wgen0025.p
                            PERSISTENT SET h-b1wgen0025.

                    RUN efetua_recolhimento IN h-b1wgen0025 
                        ( INPUT par_cdcooper,
                          INPUT par_nrterfin,
                          INPUT par_cdoperad,
                          INPUT (IF par_tprecolh THEN 2 ELSE 1),
                         OUTPUT aux_vlrecolh,
                         OUTPUT aux_dscritic).

                    IF  RETURN-VALUE <> "OK" THEN
                        DO: 
                            DELETE PROCEDURE h-b1wgen0025.
                            ASSIGN aux_dscritic = "Problemas no recolhimento.".
                            UNDO Grava, LEAVE Grava.
                        END.

                    IF  NOT par_tprecolh THEN
                        RUN altera_situacao IN h-b1wgen0025
                            ( INPUT par_cdcooper,
                              INPUT par_nrterfin,
                              INPUT "5",
                              INPUT par_cdoperad,
                              INPUT TODAY,
                              INPUT aux_vlrecolh,
                             OUTPUT aux_dscritic).

                    DELETE PROCEDURE h-b1wgen0025.

                    IF  RETURN-VALUE = "NOK" THEN
                        DO:
                            ASSIGN aux_dscritic = "Problemas na atualizacao " +
                                                  "da situacao do TAA.".
                            UNDO Grava, LEAVE Grava.
                        END.
                END. /* par_cddopcao = L */
        END CASE.
        
        ASSIGN aux_flgtrans = TRUE.

        LEAVE Grava.

    END. /* Grava */

    IF  VALID-HANDLE(h-b1wgen0025)  THEN
        DELETE PROCEDURE h-b1wgen0025.

    IF  AVAILABLE craptfn  THEN
        DO:
            FIND CURRENT craptfn NO-LOCK NO-ERROR.
            RELEASE craptfn.
        END.

    IF  AVAILABLE crapstf  THEN
        DO:
            FIND CURRENT crapstf NO-LOCK NO-ERROR.
            RELEASE crapstf.
        END.
    
    IF  NOT aux_flgtrans  THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  aux_dscritic = "" AND aux_cdcritic = 0  THEN
                ASSIGN aux_dscritic = "Nao foi possivel finalizar a operacao.".
            
            IF  NOT TEMP-TABLE tt-erro:HAS-RECORDS  THEN
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

/*............................. PROCEDURES INTERNAS .........................*/

PROCEDURE cria_tt-envelopes:

    DEF VAR aux_dssitenv AS CHAR                                 NO-UNDO.

    CASE crapenl.cdsitenv:
        WHEN 0 THEN ASSIGN aux_dssitenv = "0-Nao Liberado".
        WHEN 1 THEN ASSIGN aux_dssitenv = "1-Liberado".
        WHEN 3 THEN ASSIGN aux_dssitenv = "3-Recolhido".
        OTHERWISE   ASSIGN aux_dssitenv = "2-Descartado".
    END CASE.

    CREATE tt-envelopes.
    ASSIGN tt-envelopes.dtmvtolt = STRING(crapenl.dtmvtolt,"99/99/99")
           tt-envelopes.hrtransa = STRING(crapenl.hrtransa,"HH:MM")
           tt-envelopes.nrdconta = IF crapenl.cdcooper <> crapenl.cdcoptfn THEN
                                      STRING(crapenl.nrdconta,"zzzz,zzz,9") + 
                                      " (COOP " + STRING(crapenl.cdcooper, "99") + 
                                      ")"
                                   ELSE
                                       STRING(crapenl.nrdconta,"zzzz,zzz,9")
           tt-envelopes.nrseqenv = STRING(crapenl.nrseqenv,"zzzzzzzzzz").

    IF  crapenl.vldininf <> 0 THEN
        tt-envelopes.dsespeci = "DN".

    IF  crapenl.vlchqinf <> 0 THEN
        tt-envelopes.dsespeci = "CH".

    ASSIGN tt-envelopes.vlenvinf = STRING((crapenl.vldininf + crapenl.vlchqinf),
                                                                   "z,zzz,zz9.99")
           tt-envelopes.vlenvcmp = STRING((crapenl.vldincmp + crapenl.vlchqcmp),
                                                                   "z,zzz,zz9.99")
           tt-envelopes.dssitenv = aux_dssitenv
           tot_qtsitenv = tot_qtsitenv + 1
           tot_qtsittot = tot_qtsittot + 1

           tot_vldininf = tot_vldininf + crapenl.vldininf
           tot_vlchqinf = tot_vlchqinf + crapenl.vlchqinf

           tot_vlgerdin = tot_vlgerdin + crapenl.vldininf
           tot_vlgerchq = tot_vlgerchq + crapenl.vlchqinf
           .

END PROCEDURE. /* cria_tt-envelopes */

PROCEDURE processa_opcaor:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtini AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtfim AS DATE                           NO-UNDO.
                     
    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    /* Instancia a BO */
    IF  NOT VALID-HANDLE(h-b1wgen0025) THEN
        RUN sistema/generico/procedures/b1wgen0025.p
            PERSISTENT SET h-b1wgen0025.
    
    IF  NOT VALID-HANDLE (h-b1wgen0025)  THEN
        DO:
            UNIX SILENT VALUE("echo "
                      + STRING(TIME,"HH:MM:SS") + " - "
                      + par_cdprogra + "' --> '"
                      + "Handle invalido para h-b1wgen0025."
                      + " >> log/proc_batch.log").
            RETURN.
        END.

    /*************** Tarifas para Saques de Numerarios ***************/
    RUN busca_movto_saque_cooperativa
        IN h-b1wgen0025 ( INPUT 0,  /* Saques de meus Ass. em outros TAAs */
                          INPUT crapcop.cdcooper,    /* Saques no meu TAA */
                          INPUT par_dtmvtini,
                          INPUT par_dtmvtfim,
                          INPUT 1,
                         OUTPUT TABLE tt-lancamentos).
    RUN atualiza_lanctos(INPUT 1,
                                   INPUT 913). /* Historico de DEB */
    /* Tarifas para Saques de Numerarios */
    RUN busca_movto_saque_cooperativa
        IN h-b1wgen0025 ( INPUT crapcop.cdcooper, /*Saques meus Ass. out. TAAs*/
                          INPUT 0,    /* Saques no meu TAA */
                          INPUT par_dtmvtini,
                          INPUT par_dtmvtfim,
                          INPUT 2,
                         OUTPUT TABLE tt-lancamentos).
    RUN atualiza_lanctos(INPUT 2,
                                   INPUT 913). /* Historico de DEB */
    /************* Fim Tarifas para Saques de Numerarios *************/


    /************* Tarifas para Pagto de Titulos e Convenios *************/
    RUN taa_lancto_titulos_convenios
        IN h-b1wgen0025 ( INPUT 0,  /* Pagtos de meus Ass. em outros TAAs */
                          INPUT crapcop.cdcooper,    /* Pagtos no meu TAA */
                          INPUT par_dtmvtini,
                          INPUT par_dtmvtfim,
                          INPUT 3,
                         OUTPUT TABLE tt-lancamentos).
    RUN atualiza_lanctos(INPUT 3,
                                   INPUT 915). /* Historico de DEB */

    RUN taa_lancto_titulos_convenios
        IN h-b1wgen0025 ( INPUT crapcop.cdcooper, /*Pagtos meus Ass. out. TAAs*/
                          INPUT 0,                /* Pagtos no meu TAA */
                          INPUT par_dtmvtini,
                          INPUT par_dtmvtfim,
                          INPUT 4,
                         OUTPUT TABLE tt-lancamentos).
    RUN atualiza_lanctos(INPUT 4,
                                   INPUT 915). /* Historico de DEB */
    /*********** Fim Tarifas para Pagto de Titulos e Convenios ***********/

    /*********** Tarifas para Consulta de Saldo (tpextrat = 10) ***********/
    RUN taa_lancamento_tarifas_ext
        IN h-b1wgen0025 ( INPUT 0,  /* Saldo de meus Ass. em outros TAAs */
                          INPUT crapcop.cdcooper, /* Saldo no meu TAA */
                          INPUT 10,               /* tpextrat */
                          INPUT "",               /* insitext */
                          INPUT par_dtmvtini,
                          INPUT par_dtmvtfim,
                          INPUT "",         /* cdhistor */
                          INPUT 5,
                         OUTPUT TABLE tt-lancamentos).
    RUN atualiza_lanctos(INPUT 5,
                                   INPUT 905). /* Historico de DEB */

    RUN taa_lancamento_tarifas_ext
        IN h-b1wgen0025 ( INPUT crapcop.cdcooper, /*Saldo meus Ass. out. TAAs*/
                          INPUT 0,                /* Saldo no meu TAA */
                          INPUT 10,               /* tpextrat */
                          INPUT "",               /* insitext */
                          INPUT par_dtmvtini,
                          INPUT par_dtmvtfim,
                          INPUT "",         /* cdhistor */
                          INPUT 6,
                         OUTPUT TABLE tt-lancamentos).
    RUN atualiza_lanctos(INPUT 6,
                                   INPUT 905). /* Historico de DEB */
    /********* Fim Tarifas para Consulta de Saldo (tpextrat = 10) *********/

    /*********** Tarifas para Impressao de Saldo (tpextrat = 11) ***********/
    RUN taa_lancamento_tarifas_ext
        IN h-b1wgen0025 ( INPUT 0,  /* Impres. de meus Ass. em outros TAAs */
                          INPUT crapcop.cdcooper, /* Impres. no meu TAA */
                          INPUT 11,               /* tpextrat */
                          INPUT "",               /* insitext */
                          INPUT par_dtmvtini,
                          INPUT par_dtmvtfim,
                          INPUT "",         /* cdhistor */
                          INPUT 7,
                         OUTPUT TABLE tt-lancamentos).
    RUN atualiza_lanctos(INPUT 7,
                                   INPUT 907). /* Historico de DEB */

    RUN taa_lancamento_tarifas_ext
        IN h-b1wgen0025 ( INPUT crapcop.cdcooper, /*Impres meus Ass. out. TAAs*/
                          INPUT 0,                /* Impres no meu TAA */
                          INPUT 11,               /* tpextrat */
                          INPUT "",               /* insitext */
                          INPUT par_dtmvtini,
                          INPUT par_dtmvtfim,
                          INPUT "",         /* cdhistor */
                          INPUT 8,
                         OUTPUT TABLE tt-lancamentos).
    RUN atualiza_lanctos(INPUT 8,
                                   INPUT 907). /* Historico de DEB */
    /********* Fim Tarifas para Impressao de Saldo (tpextrat = 11) *********/

    /**** Tarifas para Impressao Extrato (tpextrat = 1 e insitext = 5) ****/
    RUN taa_lancamento_tarifas_ext
         IN h-b1wgen0025 ( INPUT 0,  /* Impres de meus Ass. em outros TAAs */
                           INPUT crapcop.cdcooper, /* Impres no meu TAA */
                           INPUT 1,                /* tpextrat */
                           INPUT "1,5",            /* insitext */
                           INPUT par_dtmvtini,
                           INPUT par_dtmvtfim,
                           INPUT "",               /* cdhistor */
                           INPUT 9,
                          OUTPUT TABLE tt-lancamentos).
    /** PI recebe o cdhistor, busca valor tarifa e atualiza na TT **/
    RUN atualiza_lanctos(INPUT 9,
                                   INPUT 909). /* Historico de DEB */

    RUN taa_lancamento_tarifas_ext
         IN h-b1wgen0025 ( INPUT crapcop.cdcooper, /*Impres meus Ass. out. TAAs*/
                           INPUT 0,                /* Impres no meu TAA */
                           INPUT 1,                /* tpextrat */
                           INPUT "1,5",            /* insitext */
                           INPUT par_dtmvtini,
                           INPUT par_dtmvtfim,
                           INPUT "",               /* cdhistor */
                           INPUT 10,
                          OUTPUT TABLE tt-lancamentos).
    RUN atualiza_lanctos(INPUT 10,
                                   INPUT 909). /* Historico de DEB */
    /**** Fim Tarifas para Impressao Extrato (tpextrat = 1 e insitext = 5) ****/



    
    /**** Tarifas para Impressao Extrato Aplicacao (tpextrat = 12) ****/
    RUN taa_lancamento_tarifas_ext
         IN h-b1wgen0025 ( INPUT 0,  /* Impres de meus Ass. em outros TAAs */
                           INPUT crapcop.cdcooper, /* Impres no meu TAA */
                           INPUT 12,         /* tpextrat */
                           INPUT "",         /* insitext */
                           INPUT par_dtmvtini,
                           INPUT par_dtmvtfim,
                           INPUT "",         /* cdhistor */
                           INPUT 11,
                          OUTPUT TABLE tt-lancamentos).
    /** PI recebe o cdhistor, busca valor tarifa e atualiza na TT **/
    RUN atualiza_lanctos(INPUT 11,
                                   INPUT 911). /* Historico de DEB */

    RUN taa_lancamento_tarifas_ext
         IN h-b1wgen0025 ( INPUT crapcop.cdcooper, /*Impres meus Ass. out. TAAs*/
                           INPUT 0,                /* Impres no meu TAA */
                           INPUT 12,         /* tpextrat */
                           INPUT "",         /* insitext */
                           INPUT par_dtmvtini,
                           INPUT par_dtmvtfim,
                           INPUT "",         /* cdhistor */
                           INPUT 12,
                          OUTPUT TABLE tt-lancamentos).
    /** PI recebe o cdhistor, busca valor tarifa e atualiza na TT **/
    RUN atualiza_lanctos(INPUT 12,
                                   INPUT 911). /* Historico de DEB */
    /**** Fim Tarifas para Impressao Extrato Aplicacao (tpextrat = 12) ****/


    /*********Tarifas para Consulta de Agendamentos (tpextrat = 13)**********/
    RUN taa_lancamento_tarifas_ext
        IN h-b1wgen0025 ( INPUT 0,  /* Consultas de meus Ass. outros TAAs */
                          INPUT crapcop.cdcooper, /* Saques no meu TAA */
                          INPUT 13,               /* tpextrat */
                          INPUT "",               /* insitext */
                          INPUT par_dtmvtini,
                          INPUT par_dtmvtfim,
                          INPUT "",         /* cdhistor */
                          INPUT 13,
                         OUTPUT TABLE tt-lancamentos).  

    /** PI recebe o cdhistor, busca valor tarifa e atualiza na TT **/
    RUN atualiza_lanctos(INPUT 13,
                                   INPUT 949). /* Historico de DEB */

    RUN taa_lancamento_tarifas_ext
        IN h-b1wgen0025 ( INPUT crapcop.cdcooper,  /* Consultas de meus Ass. outros TAAs */
                          INPUT 0, /* Saques no meu TAA */
                          INPUT 13,               /* tpextrat */
                          INPUT "",               /* insitext */
                          INPUT par_dtmvtini,
                          INPUT par_dtmvtfim,
                          INPUT "",         /* cdhistor */
                          INPUT 14,
                         OUTPUT TABLE tt-lancamentos).  

    /** PI recebe o cdhistor, busca valor tarifa e atualiza na TT **/
    RUN atualiza_lanctos(INPUT 14,
                                   INPUT 949). /* Historico de DEB */

    /******* Fim Tarifas para Consulta de Agendamentos (tpextrat = 13) ********/


    /********** Tarifas para Exclusao de Agendamentos (tpextrat = 14)**********/
    RUN taa_lancamento_tarifas_ext
        IN h-b1wgen0025 ( INPUT 0,  /* Exclusoes de meus Ass. outros TAAs */
                          INPUT crapcop.cdcooper, /* Saques no meu TAA */
                          INPUT 14,               /* tpextrat */
                          INPUT "",               /* insitext */
                          INPUT par_dtmvtini,
                          INPUT par_dtmvtfim,
                          INPUT "",         /* cdhistor */
                          INPUT 15,
                         OUTPUT TABLE tt-lancamentos).

    /** PI recebe o cdhistor, busca valor tarifa e atualiza na TT **/
    RUN atualiza_lanctos(INPUT 15,
                                   INPUT 951). /* Historico de DEB */

    RUN taa_lancamento_tarifas_ext
        IN h-b1wgen0025 ( INPUT crapcop.cdcooper,  /* Exclusoes de meus Ass. outros TAAs */
                          INPUT 0, /* Saques no meu TAA */
                          INPUT 14,               /* tpextrat */
                          INPUT "",               /* insitext */
                          INPUT par_dtmvtini,
                          INPUT par_dtmvtfim,
                          INPUT "",         /* cdhistor */
                          INPUT 16,
                         OUTPUT TABLE tt-lancamentos).

    /** PI recebe o cdhistor, busca valor tarifa e atualiza na TT **/
    RUN atualiza_lanctos(INPUT 16,
                                   INPUT 951). /* Historico de DEB */
    /******** Fim Tarifas para Exclusao de Agendamentos (tpextrat = 14) ********/


    /********** Tarifas para Impressao de comprovantes (tpextrat = 15)********/
    
    RUN taa_lancamento_tarifas_ext
        IN h-b1wgen0025 ( INPUT 0,  /* Exclusoes de meus Ass. outros TAAs */
                          INPUT crapcop.cdcooper, /* Saques no meu TAA */
                          INPUT 15,               /* tpextrat */
                          INPUT "",               /* insitext */
                          INPUT par_dtmvtini,
                          INPUT par_dtmvtfim,
                          INPUT "",         /* cdhistor */
                          INPUT 23,
                         OUTPUT TABLE tt-lancamentos).

    /** PI recebe o cdhistor, busca valor tarifa e atualiza na TT **/

    RUN atualiza_lanctos(INPUT 23,
                                   INPUT 1001). /* Historico de DEB */

    RUN taa_lancamento_tarifas_ext
        IN h-b1wgen0025 ( INPUT crapcop.cdcooper,  /* Exclusoes de meus Ass. outros TAAs */
                          INPUT 0, /* Saques no meu TAA */
                          INPUT 15,               /* tpextrat */
                          INPUT "",               /* insitext */
                          INPUT par_dtmvtini,
                          INPUT par_dtmvtfim,
                          INPUT "",         /* cdhistor */
                          INPUT 24,
                         OUTPUT TABLE tt-lancamentos).

    /** PI recebe o cdhistor, busca valor tarifa e atualiza na TT **/

    RUN atualiza_lanctos(INPUT 24,
                                   INPUT 1001). /* Historico de DEB */
    
    /******** Fim Tarifas para Impressao de comprovantes (tpextrat = 15) *****/
    
    
    /*************** Tarifas para Agendamento de Pagamentos ***************/
    RUN taa_agenda_titulos_convenios
        IN h-b1wgen0025 ( INPUT 0,  /* Impres de meus Ass. em outros TAAs */
                          INPUT crapcop.cdcooper,    /* Impres no meu TAA */
                          INPUT par_dtmvtini,
                          INPUT par_dtmvtfim,
                          INPUT 17,
                         OUTPUT TABLE tt-lancamentos).                          

    /** PI recebe o cdhistor, busca valor tarifa e atualiza na TT **/
    RUN atualiza_lanctos(INPUT 17,
                                   INPUT 943). /* Historico de DEB */

    RUN taa_agenda_titulos_convenios
        IN h-b1wgen0025 ( INPUT crapcop.cdcooper,  /* Impres de meus Ass. em outros TAAs */
                          INPUT 0,                 /* Impres no meu TAA */
                          INPUT par_dtmvtini,
                          INPUT par_dtmvtfim,
                          INPUT 18,
                         OUTPUT TABLE tt-lancamentos).
                          
    /** PI recebe o cdhistor, busca valor tarifa e atualiza na TT **/
    RUN atualiza_lanctos(INPUT 18,
                                   INPUT 943). /* Historico de DEB */
    /************* Fim Tarifas para Agendamento de Pagamentos *************/


    /*************** Tarifas para Transferencias (propria coop) ***************/
    RUN taa_transferencias 
        IN h-b1wgen0025 ( INPUT 0,  /* Saques de meus Ass. outros TAAs */
                          INPUT crapcop.cdcooper,    /* Saques no meu TAA */
                          INPUT par_dtmvtini,
                          INPUT par_dtmvtfim,
                          INPUT 19,
                         OUTPUT TABLE tt-lancamentos).

    /** PI recebe o cdhistor, busca valor tarifa e atualiza na TT **/
    RUN atualiza_lanctos(INPUT 19,
                                   INPUT 945). /* Historico de DEB */

    RUN taa_transferencias 
        IN h-b1wgen0025 ( INPUT crapcop.cdcooper,  /* Saques de meus Ass. outros TAAs */
                          INPUT 0,                 /* Saques no meu TAA */
                          INPUT par_dtmvtini,
                          INPUT par_dtmvtfim,
                          INPUT 20,
                         OUTPUT TABLE tt-lancamentos).

    /** PI recebe o cdhistor, busca valor tarifa e atualiza na TT **/
    RUN atualiza_lanctos(INPUT 20,
                                   INPUT 945). /* Historico de DEB */
    /************* Fim Tarifas para Transferencias (propria coop) *************/


    /********* Tarifas para Agendamento de Transferencias (propria coop) *********/
    RUN taa_agenda_transferencias
        IN h-b1wgen0025 ( INPUT 0,  /* Saques de meus Ass. outros TAAs */
                          INPUT crapcop.cdcooper,    /* Saques no meu TAA */
                          INPUT par_dtmvtini,
                          INPUT par_dtmvtfim,
                          INPUT 21,
                         OUTPUT TABLE tt-lancamentos).

    /** PI recebe o cdhistor, busca valor tarifa e atualiza na TT **/
    RUN atualiza_lanctos(INPUT 21,
                                   INPUT 947). /* Historico de DEB */

    RUN taa_agenda_transferencias
        IN h-b1wgen0025 ( INPUT crapcop.cdcooper,  /* Saques de meus Ass. outros TAAs */
                          INPUT 0,    /* Saques no meu TAA */
                          INPUT par_dtmvtini,
                          INPUT par_dtmvtfim,
                          INPUT 22,
                         OUTPUT TABLE tt-lancamentos).

    /** PI recebe o cdhistor, busca valor tarifa e atualiza na TT **/
    RUN atualiza_lanctos(INPUT 22,
                                   INPUT 947). /* Historico de DEB */
    /******* Fim Tarifas para Agendamento de Transferencias (propria coop) *******/

    IF  VALID-HANDLE(h-b1wgen0025) THEN
        DELETE PROCEDURE h-b1wgen0025.

END PROCEDURE.

PROCEDURE atualiza_lanctos:

    DEF INPUT PARAM par_cdtplanc AS INT                     NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INT                     NO-UNDO.

    DEF         VAR aux_vltarifa AS DECI   INIT 0           NO-UNDO.
    DEF         VAR aux_dscooper AS CHAR                    NO-UNDO.
    DEF         VAR aux_dscoptfn AS CHAR                    NO-UNDO.

    /**** BUSCA DO VALOR DA TARIFA *****/
    FIND FIRST crapthi NO-LOCK
         WHERE crapthi.cdcooper = 3 /* Sempre pela cooper 3 */
           AND crapthi.cdhistor = par_cdhistor
           AND crapthi.dsorigem = "CASH" NO-ERROR.

    IF  AVAIL crapthi THEN
        ASSIGN aux_vltarifa = crapthi.vltarifa.
    /**** FIM BUSCA DO VALOR DA TARIFA *****/

    FOR EACH tt-lancamentos WHERE
             tt-lancamentos.cdtplanc = par_cdtplanc NO-LOCK:

        FIND FIRST crabcop WHERE
                   crabcop.cdcooper = tt-lancamentos.cdcooper NO-LOCK NO-ERROR.

        IF  AVAIL crabcop THEN
            ASSIGN aux_dscooper = crabcop.nmrescop.
        ELSE
            ASSIGN aux_dscooper = "NAO ENCONTRADA".

        FIND FIRST crabcop WHERE
                   crabcop.cdcooper = tt-lancamentos.cdcoptfn NO-LOCK NO-ERROR.

        IF  AVAIL crabcop THEN
            ASSIGN aux_dscoptfn = crabcop.nmrescop.
        ELSE
            ASSIGN aux_dscoptfn = "NAO ENCONTRADA".

        CREATE tt-lanctos.
        ASSIGN tt-lanctos.cdtplanc = tt-lancamentos.cdtplanc
               tt-lanctos.dstplanc = tt-lancamentos.dstplanc
               tt-lanctos.cdcooper = tt-lancamentos.cdcooper
               tt-lanctos.cdcoptfn = tt-lancamentos.cdcoptfn
               tt-lanctos.cdagetfn = tt-lancamentos.cdagetfn
               tt-lanctos.dscooper = aux_dscooper
               tt-lanctos.dscoptfn = aux_dscoptfn
               tt-lanctos.tpconsul = tt-lancamentos.tpconsul
               tt-lanctos.qtdecoop = tt-lancamentos.qtdecoop
               tt-lanctos.qtdmovto = tt-lancamentos.qtdmovto
               tt-lanctos.vlrtotal = tt-lancamentos.vlrtotal
               tt-lanctos.vlrtarif = tt-lancamentos.qtdmovto * aux_vltarifa.

    END. /* FOR EACH tt-lancamentos */

    EMPTY TEMP-TABLE tt-lancamentos.

END PROCEDURE.

PROCEDURE pi_opcaor_tela_taa_sintet:

    DEF INPUT PARAM par_dtmvtini AS DATE                        NO-UNDO.
    DEF INPUT PARAM par_dtmvtfim AS DATE                        NO-UNDO.
    DEF INPUT PARAM par_lgagetfn AS LOGI                        NO-UNDO.
    DEF INPUT PARAM par_cdagetfn AS INTE                        NO-UNDO.
    DEF INPUT PARAM aux_cdagetfn AS INTE                        NO-UNDO.

    ASSIGN aux_dstitulo = "RELATORIO SINTETICO DE MOVIMENTACOES DOS TAAs - " +
                    STRING(par_dtmvtini) + " Ate " + STRING(par_dtmvtfim).

    DEF VAR aux_contador AS INTE                                NO-UNDO.

    DISPLAY STREAM str_1 aux_dstitulo
              WITH FRAME f_tela_titulo.

    IF par_lgagetfn THEN DO: /* Informou o PAC em tela */

        ASSIGN aux_dssubtit = "A PAGAR - TAAs Outras Cooperativas".
    
        DISPLAY STREAM str_1 aux_dssubtit
                  WITH FRAME f_tela_subtit.
    
        /* A PAGAR */
        FOR EACH tt-lanctos NO-LOCK
           WHERE tt-lanctos.tpconsul  = "Outras Coop"
             AND tt-lanctos.cdagetfn >= par_cdagetfn
             AND tt-lanctos.cdagetfn <= aux_cdagetfn
           BREAK BY tt-lanctos.cdcoptfn
                 BY tt-lanctos.nrdconta:

            ASSIGN aux_qtdmovto = aux_qtdmovto + tt-lanctos.qtdmovto
                   aux_vlrtotal = aux_vlrtotal + tt-lanctos.vlrtotal
                   aux_vlrtarif = aux_vlrtarif + tt-lanctos.vlrtarif
                   aux_contador = aux_contador + 1
                   aux_qtdecoop = aux_qtdecoop + tt-lanctos.qtdecoop.

            IF LAST-OF(tt-lanctos.cdcoptfn) THEN DO:
    
               ASSIGN tot_qtdmovto = tot_qtdmovto + aux_qtdmovto
                      tot_qtdecoop = tot_qtdecoop + aux_qtdecoop
                      tot_vlrtotal = tot_vlrtotal + aux_vlrtotal 
                      tot_vlrtarif = tot_vlrtarif + aux_vlrtarif.
               ASSIGN aux_dscooper = tt-lanctos.dscoptfn.
    
               DISPLAY STREAM str_1 tt-lanctos.cdagetfn
                                    aux_dscooper
                                    aux_qtdecoop
                                    aux_qtdmovto
                                    aux_vlrtotal
                                    aux_vlrtarif
                         WITH FRAME f_tela_dados_outras_pac.
               DOWN STREAM str_1 WITH FRAME f_tela_dados_outras_pac.
               RUN pi_opcaor_zera_vars.
            END.
        END.  /* Fim do FOR EACH */
    
        IF aux_contador > 0 THEN
            DISPLAY STREAM str_1 aux_setlinha
                                 tot_qtdecoop tot_qtdmovto
                                 tot_vlrtotal tot_vlrtarif
                WITH FRAME f_tela_totais.
        ELSE
            DISPLAY STREAM str_1 aux_semdados
                WITH FRAME f_tela_semdados.
    
        RUN pi_opcaor_zera_vars.
    
        ASSIGN tot_qtdecoop = 0 tot_qtdmovto = 0
               tot_vlrtotal = 0 tot_vlrtarif = 0
               aux_contador = 0.
    
        RUN pi_opcaor_zera_vars.
    
        ASSIGN aux_dssubtit = "A RECEBER - Cooperados Outras Cooperativas".
    
        DISPLAY STREAM str_1 aux_dssubtit
                  WITH FRAME f_tela_subtit.
    
        /* A RECEBER */
        FOR EACH tt-lanctos NO-LOCK
           WHERE tt-lanctos.tpconsul  = "TAA"
             AND tt-lanctos.cdagetfn >= par_cdagetfn
             AND tt-lanctos.cdagetfn <= aux_cdagetfn
           BREAK BY tt-lanctos.cdcooper
                 BY tt-lanctos.nrdconta:

            ASSIGN aux_qtdmovto = aux_qtdmovto + tt-lanctos.qtdmovto
                   aux_vlrtotal = aux_vlrtotal + tt-lanctos.vlrtotal
                   aux_vlrtarif = aux_vlrtarif + tt-lanctos.vlrtarif
                   aux_contador = aux_contador + 1
                   aux_qtdecoop = aux_qtdecoop + tt-lanctos.qtdecoop.

            IF LAST-OF(tt-lanctos.cdcooper) THEN DO:

               ASSIGN tot_qtdmovto = tot_qtdmovto + aux_qtdmovto
                      tot_qtdecoop = tot_qtdecoop + aux_qtdecoop
                      tot_vlrtotal = tot_vlrtotal + aux_vlrtotal 
                      tot_vlrtarif = tot_vlrtarif + aux_vlrtarif.
               ASSIGN aux_dscooper = tt-lanctos.dscooper.
    
               DISPLAY STREAM str_1 tt-lanctos.cdagetfn
                                    aux_dscooper
                                    aux_qtdecoop
                                    aux_qtdmovto
                                    aux_vlrtotal
                                    aux_vlrtarif
                         WITH FRAME f_tela_dados_taa_pac.
               DOWN STREAM str_1 WITH FRAME f_tela_dados_taa_pac.
               RUN pi_opcaor_zera_vars.
           END.

        END.  /* Fim do FOR EACH */
    
        IF aux_contador > 0 THEN
            DISPLAY STREAM str_1 aux_setlinha
                                 tot_qtdecoop tot_qtdmovto
                                 tot_vlrtotal tot_vlrtarif
                WITH FRAME f_tela_totais.
        ELSE
            DISPLAY STREAM str_1 aux_semdados
                WITH FRAME f_tela_semdados.
    
        RUN pi_opcaor_zera_vars.
    
        ASSIGN tot_qtdecoop = 0 tot_qtdmovto = 0
               tot_vlrtotal = 0 tot_vlrtarif = 0
               aux_contador = 0.
    END.
    ELSE DO: /* Nao Informou o PAC em tela */

        ASSIGN aux_dssubtit = "A PAGAR - TAAs Outras Cooperativas".

            DISPLAY STREAM str_1 aux_dssubtit
                      WITH FRAME f_tela_subtit.

            /* A PAGAR */
            FOR EACH tt-lanctos NO-LOCK
               WHERE tt-lanctos.tpconsul  = "Outras Coop"
               BREAK BY tt-lanctos.cdcoptfn
                     BY tt-lanctos.nrdconta:

                ASSIGN aux_qtdmovto = aux_qtdmovto + tt-lanctos.qtdmovto
                       aux_vlrtotal = aux_vlrtotal + tt-lanctos.vlrtotal
                       aux_vlrtarif = aux_vlrtarif + tt-lanctos.vlrtarif
                       aux_contador = aux_contador + 1
                       aux_qtdecoop = aux_qtdecoop + tt-lanctos.qtdecoop.

                IF LAST-OF(tt-lanctos.cdcoptfn) THEN DO:

                   ASSIGN tot_qtdecoop = tot_qtdecoop + aux_qtdecoop
                          tot_qtdmovto = tot_qtdmovto + aux_qtdmovto
                          tot_vlrtotal = tot_vlrtotal + aux_vlrtotal 
                          tot_vlrtarif = tot_vlrtarif + aux_vlrtarif.
                   ASSIGN aux_dscooper = tt-lanctos.dscoptfn.

                   DISPLAY STREAM str_1 aux_dscooper
                                        aux_qtdecoop
                                        aux_qtdmovto
                                        aux_vlrtotal
                                        aux_vlrtarif
                             WITH FRAME f_tela_dados_outras.
                   DOWN STREAM str_1 WITH FRAME f_tela_dados_outras.
                   RUN pi_opcaor_zera_vars.
                END.
            END.  /* Fim do FOR EACH */

            IF aux_contador > 0 THEN
                DISPLAY STREAM str_1 aux_setlinha
                                     tot_qtdecoop tot_qtdmovto
                                     tot_vlrtotal tot_vlrtarif
                    WITH FRAME f_tela_totais.
            ELSE
                DISPLAY STREAM str_1 aux_semdados
                    WITH FRAME f_tela_semdados.

            RUN pi_opcaor_zera_vars.

            ASSIGN tot_qtdecoop = 0 tot_qtdmovto = 0
                   tot_vlrtotal = 0 tot_vlrtarif = 0
                   aux_contador = 0.





            RUN pi_opcaor_zera_vars.

            ASSIGN aux_dssubtit = "A RECEBER - Cooperados Outras Cooperativas".

            DISPLAY STREAM str_1 aux_dssubtit
                      WITH FRAME f_tela_subtit.

            /* A RECEBER */
            FOR EACH tt-lanctos NO-LOCK
               WHERE tt-lanctos.tpconsul  = "TAA"
               BREAK BY tt-lanctos.cdcooper
                     BY tt-lanctos.nrdconta:

                ASSIGN aux_qtdmovto = aux_qtdmovto + tt-lanctos.qtdmovto
                       aux_vlrtotal = aux_vlrtotal + tt-lanctos.vlrtotal
                       aux_vlrtarif = aux_vlrtarif + tt-lanctos.vlrtarif
                       aux_contador = aux_contador + 1
                       aux_qtdecoop = aux_qtdecoop + tt-lanctos.qtdecoop.

                IF LAST-OF(tt-lanctos.cdcooper) THEN DO:

                   ASSIGN tot_qtdecoop = tot_qtdecoop + aux_qtdecoop
                          tot_qtdmovto = tot_qtdmovto + aux_qtdmovto
                          tot_vlrtotal = tot_vlrtotal + aux_vlrtotal 
                          tot_vlrtarif = tot_vlrtarif + aux_vlrtarif.
                   ASSIGN aux_dscooper = tt-lanctos.dscooper.

                   DISPLAY STREAM str_1 aux_dscooper
                                        aux_qtdecoop
                                        aux_qtdmovto
                                        aux_vlrtotal
                                        aux_vlrtarif 
                             WITH FRAME f_tela_dados_taa.
                   DOWN STREAM str_1 WITH FRAME f_tela_dados_taa.
                   RUN pi_opcaor_zera_vars.
                END.
            END.  /* Fim do FOR EACH */

            IF aux_contador > 0 THEN
                DISPLAY STREAM str_1 aux_setlinha
                                     tot_qtdecoop tot_qtdmovto
                                     tot_vlrtotal tot_vlrtarif
                    WITH FRAME f_tela_totais.
            ELSE
                DISPLAY STREAM str_1 aux_semdados
                    WITH FRAME f_tela_semdados.

            RUN pi_opcaor_zera_vars.

            ASSIGN tot_qtdecoop = 0 tot_qtdmovto = 0
                   tot_vlrtotal = 0 tot_vlrtarif = 0
                   aux_contador = 0.

    END.

END PROCEDURE.

PROCEDURE pi_opcaor_tela_taa_analit:

    DEF INPUT PARAM par_cdtplanc AS INT                 NO-UNDO.
    DEF INPUT PARAM par_lgagetfn AS LOGI                NO-UNDO.
    DEF INPUT PARAM par_cdagetfn AS INTE                NO-UNDO.
    DEF INPUT PARAM aux_cdagetfn AS INTE                NO-UNDO.

    DEF VAR aux_contador AS INTE                        NO-UNDO.

    RUN pi_opcaor_zera_vars.

    CASE par_cdtplanc:
        WHEN  1 THEN aux_dstitulo = "------ SAQUES INTERCOOPERATIVAS".
        WHEN  3 THEN aux_dstitulo = "------ PAGAMENTOS INTERCOOPERATIVAS".
        WHEN  5 THEN aux_dstitulo = "------ CONSULTA DE SALDO " +
                                    "INTERCOOPERATIVAS".
        WHEN  7 THEN aux_dstitulo = "------ IMPRESSAO DE SALDO " +
                                    "INTERCOOPERATIVAS".
        WHEN  9 THEN aux_dstitulo = "------ IMPRESSAO DE EXTRATO " +
                                    "INTERCOOPERATIVAS".
        WHEN 11 THEN aux_dstitulo = "------ IMPRESSAO EXTRATO APLICACAO " +
                                    "INTERCOOPERATIVAS".
        WHEN 13 THEN aux_dstitulo = "------ CONSULTA DE AGENDAMENTOS " +
                                    "INTERCOOPERATIVAS".
        WHEN 15 THEN aux_dstitulo = "------ EXCLUSAO DE AGENDAMENTOS " +
                                    "INTERCOOPERATIVAS".
        WHEN 17 THEN aux_dstitulo = "------ AGENDAMENTOS DE PAGAMENTOS " +
                                    "INTERCOOPERATIVAS".    
        WHEN 19 THEN aux_dstitulo = "------ TRANSFERENCIAS (PROPRIA COOP) " +
                                    "INTERCOOPERATIVAS".
        WHEN 21 THEN aux_dstitulo = "------ AGENDAMENTOS DE TRANSFERENCIAS " +
                                    "(PROPRIA COOP) INTERCOOPERATIVAS".
        WHEN 23 THEN aux_dstitulo = "------ IMPRESSAO DE COMPROVANTES " +
                                    "INTERCOOPERATIVAS".
        OTHERWISE aux_dstitulo = "".
    END CASE.


    ASSIGN tot_qtdecoop = 0 tot_qtdmovto = 0
           tot_vlrtotal = 0 tot_vlrtarif = 0
           aux_contador = 0.


    DISPLAY STREAM str_1 aux_dstitulo
              WITH FRAME f_tela_titulo.

    ASSIGN aux_dssubtit = "TAA " + crapcop.nmrescop.

    DISPLAY STREAM str_1 aux_dssubtit
              WITH FRAME f_tela_subtit.

    IF par_lgagetfn THEN DO: /* TRUE - Informou PAC */

        FOR EACH tt-lanctos NO-LOCK
           WHERE tt-lanctos.cdtplanc  = par_cdtplanc
             AND tt-lanctos.cdagetfn >= par_cdagetfn
             AND tt-lanctos.cdagetfn <= aux_cdagetfn
           BREAK BY tt-lanctos.cdcooper
                 BY tt-lanctos.cdagetfn:
    
            ASSIGN aux_qtdecoop = aux_qtdecoop + tt-lanctos.qtdecoop
                   aux_qtdmovto = aux_qtdmovto + tt-lanctos.qtdmovto
                   aux_vlrtotal = aux_vlrtotal + tt-lanctos.vlrtotal
                   aux_vlrtarif = aux_vlrtarif + tt-lanctos.vlrtarif
                   aux_contador = aux_contador + 1.

            IF LAST-OF(tt-lanctos.cdcooper) THEN
               ASSIGN aux_dscooper = TRIM(tt-lanctos.dscooper).

            IF LAST-OF(tt-lanctos.cdagetfn) THEN DO:

               ASSIGN tot_qtdecoop = tot_qtdecoop + aux_qtdecoop
                      tot_qtdmovto = tot_qtdmovto + aux_qtdmovto
                      tot_vlrtotal = tot_vlrtotal + aux_vlrtotal 
                      tot_vlrtarif = tot_vlrtarif + aux_vlrtarif.
    
               DISPLAY STREAM str_1 tt-lanctos.cdagetfn
                                    aux_dscooper
                                    aux_qtdecoop
                                    aux_qtdmovto
                                    aux_vlrtotal
                                    aux_vlrtarif
                         WITH FRAME f_tela_dados_taa_pac.
                  DOWN STREAM str_1 WITH FRAME f_tela_dados_taa_pac.
                  RUN pi_opcaor_zera_vars.

            END.
        END.  /* Fim do FOR EACH */

        IF aux_contador > 0 THEN
            DISPLAY STREAM str_1 aux_setlinha
                                 tot_qtdecoop tot_qtdmovto
                                 tot_vlrtotal tot_vlrtarif
                WITH FRAME f_tela_totais.
        ELSE
            DISPLAY STREAM str_1 aux_semdados
                WITH FRAME f_tela_semdados.

        RUN pi_opcaor_zera_vars.
        ASSIGN tot_qtdecoop = 0 tot_qtdmovto = 0
               tot_vlrtotal = 0 tot_vlrtarif = 0
               aux_contador = 0.

    END.
    ELSE DO:  /* FALSE - Nao Informou PAC */

        FOR EACH tt-lanctos NO-LOCK
           WHERE tt-lanctos.cdtplanc = par_cdtplanc
           BREAK BY tt-lanctos.cdcooper:
    
            ASSIGN aux_qtdecoop = aux_qtdecoop + tt-lanctos.qtdecoop
                   aux_qtdmovto = aux_qtdmovto + tt-lanctos.qtdmovto
                   aux_vlrtotal = aux_vlrtotal + tt-lanctos.vlrtotal
                   aux_vlrtarif = aux_vlrtarif + tt-lanctos.vlrtarif
                   aux_contador = aux_contador + 1.

            IF LAST-OF(tt-lanctos.cdcooper) THEN DO:

               ASSIGN tot_qtdecoop = tot_qtdecoop + aux_qtdecoop
                      tot_qtdmovto = tot_qtdmovto + aux_qtdmovto
                      tot_vlrtotal = tot_vlrtotal + aux_vlrtotal 
                      tot_vlrtarif = tot_vlrtarif + aux_vlrtarif.
               ASSIGN aux_dscooper = tt-lanctos.dscooper.

               DISPLAY STREAM str_1 aux_dscooper
                                    aux_qtdecoop
                                    aux_qtdmovto
                                    aux_vlrtotal
                                    aux_vlrtarif
                         WITH FRAME f_tela_dados_taa.
               DOWN STREAM str_1 WITH FRAME f_tela_dados_taa.
               RUN pi_opcaor_zera_vars.
            END.
        END.  /* Fim do FOR EACH */

        IF aux_contador > 0 THEN
            DISPLAY STREAM str_1 aux_setlinha
                                 tot_qtdecoop tot_qtdmovto
                                 tot_vlrtotal tot_vlrtarif
                WITH FRAME f_tela_totais.
        ELSE
            DISPLAY STREAM str_1 aux_semdados
                WITH FRAME f_tela_semdados.

        RUN pi_opcaor_zera_vars.
        ASSIGN tot_qtdecoop = 0 tot_qtdmovto = 0
               tot_vlrtotal = 0 tot_vlrtarif = 0
               aux_contador = 0.
    END.

END PROCEDURE.

PROCEDURE pi_impressao_relat_depositos:

    DEF INPUT PARAM par_cdcooper AS INTE                NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                NO-UNDO.
    DEF INPUT PARAM par_nrterfin AS INTE                NO-UNDO.
    DEF INPUT PARAM par_dtmvtini AS DATE                NO-UNDO.
    DEF INPUT PARAM par_dtmvtfim AS DATE                NO-UNDO.
    DEF INPUT PARAM par_cdsitenv AS INTE                NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE                        NO-UNDO.
    DEF VAR aux_dsterfin AS CHAR FORMAT "x(30)"         NO-UNDO.
    DEF VAR aux_dssituac AS CHAR FORMAT "x(30)"         NO-UNDO.

    FORM SKIP(2)
         "Numero do Terminal de Saque:"              AT 1
         par_nrterfin           FORMAT "zzz9"        AT 30
         aux_dsterfin           FORMAT "x(30)"       AT 35
         SKIP   
         "Data:"                                     AT 24
         par_dtmvtini                                AT 30
         "Ate:"                                      AT 39
         par_dtmvtfim                                AT 44
         SKIP
         "Situacao:"                                 AT 20
         par_cdsitenv           FORMAT "9"           AT 30
         aux_dssituac           FORMAT "x(30)"       AT 33
         SKIP(2)
        WITH FRAME f_param NO-LABEL NO-BOX WIDTH 132.

    /**** FRAME P/ REL DEPOSITO ******/
    FORM SKIP
         "SITUACAO"                                  AT 3
         tt-envelopes.dssitenv   FORMAT "x(15)"      AT 12
         SKIP
        WITH NO-BOX NO-LABEL DOWN FRAME f_rel WIDTH 132.

    /**** FRAME P/ REL DEPOSITO ******/
    FORM tt-envelopes.dtmvtolt   LABEL "Data"         FORMAT "x(8)" 
         tt-envelopes.hrtransa   LABEL "Hora"                       
         tt-envelopes.nrdconta   LABEL "Conta Fav."   FORMAT "x(18)"
         tt-envelopes.nrseqenv   LABEL "Envelope"     FORMAT "x(10)"
         tt-envelopes.dsespeci   LABEL "ESP"          FORMAT "x(3)" 
         tt-envelopes.vlenvinf   LABEL "Valor Inf"    FORMAT "x(12)"
         tt-envelopes.vlenvcmp   LABEL "Valor Comp"   FORMAT "x(12)"
         tt-envelopes.dssitenv   LABEL "Situacao"     FORMAT "x(14)"
        WITH NO-BOX NO-LABEL DOWN FRAME f_rel_deposito WIDTH 132.

    EMPTY TEMP-TABLE tt-erro.

    CASE par_cdsitenv:
        WHEN 0 THEN aux_dssituac = "Nao Liberado".
        WHEN 1 THEN aux_dssituac = "Liberado".
        WHEN 2 THEN aux_dssituac = "Descartado".
        WHEN 3 THEN aux_dssituac = "Recolhido".
        WHEN 9 THEN aux_dssituac = "TODOS".
        OTHERWISE aux_dssituac = "".
    END CASE.

    IF  (par_dtmvtini <> ? AND par_dtmvtini = ?)  OR
        (par_dtmvtfim <> ? AND par_dtmvtfim = ?)  OR
        (par_dtmvtfim < par_dtmvtini)             THEN DO:
        ASSIGN aux_cdcritic = 13
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1,
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        
        RETURN "NOK".
    END.
    ELSE DO:
        IF  (par_dtmvtini < par_dtmvtolt - 60)  OR
            (par_dtmvtfim < par_dtmvtolt - 60)  THEN DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Data errada. Maximo 60 dias.".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 2,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            RETURN "NOK".
        END.
    END.

    IF  par_dtmvtini = ?  AND
        par_dtmvtfim = ?  THEN
        ASSIGN par_dtmvtini = par_dtmvtolt
               par_dtmvtfim = par_dtmvtolt.

    IF  par_dtmvtini <> ? THEN DO:
        FOR EACH crapenl WHERE crapenl.cdcoptfn  = par_cdcooper
                           AND crapenl.nrterfin  = par_nrterfin
                           AND crapenl.dtmvtolt >= par_dtmvtini
                           AND crapenl.dtmvtolt <= par_dtmvtfim
                           AND (crapenl.cdsitenv  = par_cdsitenv
                            OR par_cdsitenv       = 9) /* Todos */
                            NO-LOCK BREAK BY crapenl.cdsitenv
                                          BY crapenl.dtmvtolt:

            IF  FIRST-OF(crapenl.cdsitenv) THEN DO:
                ASSIGN tot_qtsitenv = 1
                       tot_vlenvinf = 0
                       tot_vlenvcmp = 0
                       tot_vldininf = 0
                       tot_vlchqinf = 0.
            END.

            RUN cria_tt-envelopes.

            IF  LAST-OF(crapenl.cdsitenv) THEN DO:
                CREATE tt-envelopes.
                
                CREATE tt-envelopes.
                ASSIGN tt-envelopes.dtmvtolt = ""
                       tt-envelopes.hrtransa = ""
                       tt-envelopes.nrdconta = "     TOTAL"
                       /* Desconsidera a ultima linha em branco */ 
                       tt-envelopes.nrseqenv = STRING(tot_qtsitenv - 1)

                       tt-envelopes.dsespeci = "CH:"
                       tt-envelopes.vlenvinf = STRING(tot_vlchqinf,"z,zzz,zz9.99")
                       tt-envelopes.vlenvcmp = "      DN:"
                       tt-envelopes.dssitenv = STRING(tot_vldininf,"z,zzz,zz9.99").
            
                CREATE tt-envelopes.
            END.
            
        END. /* FOR EACH crapenl */
      ASSIGN tt-envelopes.dtmvtolt = ""
             tt-envelopes.hrtransa = ""
             tt-envelopes.nrdconta = "TOT. GERAL"
             tt-envelopes.nrseqenv = STRING(tot_qtsittot)
             tt-envelopes.dsespeci = "CH:"
             tt-envelopes.vlenvinf = STRING(tot_vlgerchq,"z,zzz,zz9.99")
             tt-envelopes.vlenvcmp = "      DN:"
             tt-envelopes.dssitenv = STRING(tot_vlgerdin,"z,zzz,zz9.99").
    END.
    ELSE DO:
        FOR EACH crapenl WHERE crapenl.cdcoptfn  = par_cdcooper
                           AND crapenl.nrterfin  = par_nrterfin
                           AND (crapenl.cdsitenv  = par_cdsitenv
                            OR par_cdsitenv       = 9) /* Todos */
                            NO-LOCK BREAK BY crapenl.cdsitenv
                                          BY crapenl.dtmvtolt:

            IF  FIRST-OF(crapenl.cdsitenv) THEN DO:
                ASSIGN tot_qtsitenv = 1
                       tot_vlenvinf = 0
                       tot_vlenvcmp = 0
                       tot_vldininf = 0
                       tot_vlchqinf = 0.
            END.

            RUN cria_tt-envelopes.

            /* se valor em din incrementa vl total din, senao incrementa vl total chq */
            IF  crapenl.vldininf <> 0 THEN
                ASSIGN tot_vldininf = tot_vldininf + crapenl.vldininf.
            ELSE
                ASSIGN tot_vlchqinf = tot_vlchqinf + crapenl.vlchqinf.

            IF  LAST-OF(crapenl.cdsitenv) THEN DO:
                CREATE tt-envelopes.
                        
                CREATE tt-envelopes.
                ASSIGN tt-envelopes.dtmvtolt = ""
                       tt-envelopes.hrtransa = ""
                       tt-envelopes.nrdconta = "     TOTAL"
                       /* Desconsidera a ultima linha em branco */ 
                       tt-envelopes.nrseqenv = STRING(tot_qtsitenv - 1)

                       tt-envelopes.dsespeci = "CH:"
                       tt-envelopes.vlenvinf = STRING(tot_vlchqinf,"z,zzz,zz9.99") 
                       tt-envelopes.vlenvcmp = "      DN:"
                       tt-envelopes.dssitenv = STRING(tot_vldininf,"z,zzz,zz9.99").
            
                CREATE tt-envelopes.
            END.
        END. /* FOR EACH crapenl */
        
        ASSIGN tot_vlgerchq = 0
               tot_vlgerdin = 0.
    END.

    /*** Inicio do relatório ***/

    ASSIGN aux_dsterfin = "".

    FIND FIRST craptfn WHERE craptfn.cdcooper = par_cdcooper
                         AND craptfn.nrterfin = par_nrterfin
                         NO-LOCK NO-ERROR.

    IF  AVAIL craptfn THEN
        ASSIGN aux_dsterfin = " - " + craptfn.nmterfin.

    DISPLAY STREAM str_1 par_nrterfin
                         aux_dsterfin
                         par_dtmvtini   
                         par_dtmvtfim
                         par_cdsitenv
                         aux_dssituac    
                         WITH FRAME f_param.

    FOR EACH tt-envelopes:

        DISPLAY STREAM str_1 tt-envelopes.dtmvtolt tt-envelopes.hrtransa
                             tt-envelopes.nrdconta tt-envelopes.nrseqenv
                             tt-envelopes.dsespeci tt-envelopes.vlenvinf
                             tt-envelopes.vlenvcmp tt-envelopes.dssitenv
                            WITH FRAME f_rel_deposito.

        DOWN STREAM str_1 WITH FRAME f_rel_deposito.
        
    END.  /* Fim do FOR EACH */

    RETURN "OK".

END PROCEDURE.

PROCEDURE pi_opcaor_tela_outras_coop:

    DEF INPUT PARAM par_cdtplanc AS INT                 NO-UNDO.
    DEF INPUT PARAM par_lgagetfn AS LOGI                NO-UNDO.
    DEF INPUT PARAM par_cdagetfn AS INTE                NO-UNDO.
    DEF INPUT PARAM aux_cdagetfn AS INTE                NO-UNDO.

    DEF VAR aux_contador AS INTE                        NO-UNDO.


    RUN pi_opcaor_zera_vars.

    ASSIGN tot_qtdecoop = 0 tot_qtdmovto = 0
           tot_vlrtotal = 0 tot_vlrtarif = 0
           aux_contador = 0.


    ASSIGN aux_dssubtit = "Movimentacoes realizadas em TAAs de outras " 
                          + "cooperativas".
    DISPLAY STREAM str_1 SKIP(2) aux_dssubtit
              WITH FRAME f_tela_subtit.

    IF  par_lgagetfn THEN DO: /* TRUE - Informou PAC */

        FOR EACH tt-lanctos NO-LOCK
           WHERE tt-lanctos.cdtplanc  = par_cdtplanc
             AND tt-lanctos.cdagetfn >= par_cdagetfn
             AND tt-lanctos.cdagetfn <= aux_cdagetfn
           BREAK BY tt-lanctos.cdcoptfn
                 BY tt-lanctos.cdagetfn:
    
            ASSIGN aux_qtdecoop = aux_qtdecoop + tt-lanctos.qtdecoop
                   aux_qtdmovto = aux_qtdmovto + tt-lanctos.qtdmovto
                   aux_vlrtotal = aux_vlrtotal + tt-lanctos.vlrtotal
                   aux_vlrtarif = aux_vlrtarif + tt-lanctos.vlrtarif
                   aux_contador = aux_contador + 1.
                                                 
            IF LAST-OF(tt-lanctos.cdagetfn) THEN DO:
               ASSIGN tot_qtdecoop = tot_qtdecoop + aux_qtdecoop
                      tot_qtdmovto = tot_qtdmovto + aux_qtdmovto
                      tot_vlrtotal = tot_vlrtotal + aux_vlrtotal 
                      tot_vlrtarif = tot_vlrtarif + aux_vlrtarif.
               
               ASSIGN aux_dscooper = TRIM(tt-lanctos.dscoptfn).
    
               DISPLAY STREAM str_1 aux_dscooper
                                    tt-lanctos.cdagetfn
                                    aux_qtdecoop
                                    aux_qtdmovto
                                    aux_vlrtotal
                                    aux_vlrtarif 
                         WITH FRAME f_tela_dados_outras_pac.
                  DOWN STREAM str_1 WITH FRAME f_tela_dados_outras_pac.
                  RUN pi_opcaor_zera_vars.

            END.
        END.  /* Fim do FOR EACH */

        IF aux_contador > 0 THEN
            DISPLAY STREAM str_1 aux_setlinha
                                 tot_qtdecoop tot_qtdmovto
                                 tot_vlrtotal tot_vlrtarif
                WITH FRAME f_tela_totais.
        ELSE
            DISPLAY STREAM str_1 aux_semdados
                WITH FRAME f_tela_semdados.

        RUN pi_opcaor_zera_vars.
        ASSIGN tot_qtdecoop = 0 tot_qtdmovto = 0
               tot_vlrtotal = 0 tot_vlrtarif = 0
               aux_contador = 0.

    END.
    ELSE DO:  /* FALSE - Nao Informou PAC */

        FOR EACH tt-lanctos NO-LOCK
           WHERE tt-lanctos.cdtplanc = par_cdtplanc
           BREAK BY tt-lanctos.cdcoptfn:
    
            ASSIGN aux_qtdecoop = aux_qtdecoop + tt-lanctos.qtdecoop
                   aux_qtdmovto = aux_qtdmovto + tt-lanctos.qtdmovto
                   aux_vlrtotal = aux_vlrtotal + tt-lanctos.vlrtotal
                   aux_vlrtarif = aux_vlrtarif + tt-lanctos.vlrtarif
                   aux_contador = aux_contador + 1.
                                                 
            IF LAST-OF(tt-lanctos.cdcoptfn) THEN DO:
               ASSIGN tot_qtdecoop = tot_qtdecoop + aux_qtdecoop
                      tot_qtdmovto = tot_qtdmovto + aux_qtdmovto
                      tot_vlrtotal = tot_vlrtotal + aux_vlrtotal 
                      tot_vlrtarif = tot_vlrtarif + aux_vlrtarif.

               ASSIGN aux_dscooper = tt-lanctos.dscoptfn.

               DISPLAY STREAM str_1 aux_dscooper
                                    aux_qtdecoop
                                    aux_qtdmovto
                                    aux_vlrtotal
                                    aux_vlrtarif
                         WITH FRAME f_tela_dados_outras.
                    DOWN STREAM str_1 WITH FRAME f_tela_dados_outras.
               RUN pi_opcaor_zera_vars.

            END.
        END.  /* Fim do FOR EACH */

        IF aux_contador > 0 THEN
            DISPLAY STREAM str_1 aux_setlinha
                                 tot_qtdecoop tot_qtdmovto
                                 tot_vlrtotal tot_vlrtarif
                WITH FRAME f_tela_totais.
        ELSE
            DISPLAY STREAM str_1 aux_semdados
                WITH FRAME f_tela_semdados.

        RUN pi_opcaor_zera_vars.
        ASSIGN tot_qtdecoop = 0 tot_qtdmovto = 0
               tot_vlrtotal = 0 tot_vlrtarif = 0
               aux_contador = 0.
    END.

END PROCEDURE.

PROCEDURE pi_opcaor_arquivo_analitico:
    /* Quebra por operacao */
    
    DEF INPUT PARAM par_dtmvtini AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtfim AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_lgagetfn AS LOGI                    NO-UNDO.
    DEF INPUT PARAM par_cdagetfn AS INTE                    NO-UNDO.
    DEF INPUT PARAM aux_cdagetfn AS INTE                    NO-UNDO.
    
    DEF VAR  aux_dscoprel  AS CHAR                       NO-UNDO.

    IF  par_lgagetfn THEN
        DO:
            FOR EACH tt-lanctos NO-LOCK
               WHERE tt-lanctos.cdagetfn >= par_cdagetfn
                 AND tt-lanctos.cdagetfn <= aux_cdagetfn
/*              AND tt-lanctos.tpconsul = "Outras Coop" */
                  BY tt-lanctos.cdagetfn
                  BY tt-lanctos.cdtplanc
                  BY tt-lanctos.tpconsul
                  BY tt-lanctos.cdcoptfn:
            
            ASSIGN aux_qtdecoop = aux_qtdecoop + tt-lanctos.qtdecoop
                   aux_qtdmovto = aux_qtdmovto + tt-lanctos.qtdmovto
                   aux_vlrtotal = aux_vlrtotal + tt-lanctos.vlrtotal
                   aux_vlrtarif = aux_vlrtarif + tt-lanctos.vlrtarif.

            IF  tt-lanctos.tpconsul = "TAA" THEN
                aux_dscoprel = tt-lanctos.dscooper.
            ELSE 
                aux_dscoprel = tt-lanctos.dscoptfn.
    

           PUT STREAM str_1 par_dtmvtini        FORMAT "99/99/9999" ";"
                            par_dtmvtfim        FORMAT "99/99/9999" ";"
                            crapcop.nmrescop    FORMAT "x(18)"      ";"
                            tt-lanctos.cdagetfn FORMAT "zzz9"       ";"
                            tt-lanctos.dstplanc FORMAT "x(18)"      ";"
                            tt-lanctos.tpconsul FORMAT "x(12)"      ";"
                            aux_dscoprel        FORMAT "x(18)" ";"
                            aux_qtdecoop        FORMAT "zzzz9" ";"
                            aux_qtdmovto        FORMAT "zzzz9" ";"
                            aux_vlrtotal        FORMAT "zzzz,zzz,zz9.99" ";"
                            aux_vlrtarif        FORMAT "zzzz,zzz,zz9.99" ";"
               SKIP.
           RUN pi_opcaor_zera_vars.
    
        END.
    
        RUN pi_opcaor_zera_vars.

    END.
    ELSE DO:

        FOR EACH tt-lanctos NO-LOCK
           WHERE tt-lanctos.cdagetfn >= par_cdagetfn
             AND tt-lanctos.cdagetfn <= aux_cdagetfn
/*              AND tt-lanctos.tpconsul = "Outras Coop" */
              BY tt-lanctos.cdtplanc
              BY tt-lanctos.tpconsul DESC
              BY tt-lanctos.cdcoptfn:
            
            ASSIGN aux_qtdecoop = aux_qtdecoop + tt-lanctos.qtdecoop
                   aux_qtdmovto = aux_qtdmovto + tt-lanctos.qtdmovto
                   aux_vlrtotal = aux_vlrtotal + tt-lanctos.vlrtotal
                   aux_vlrtarif = aux_vlrtarif + tt-lanctos.vlrtarif.

            IF  tt-lanctos.tpconsul = "TAA" THEN
                aux_dscoprel = tt-lanctos.dscooper.
            ELSE 
                aux_dscoprel = tt-lanctos.dscoptfn.

           PUT STREAM str_1 par_dtmvtini        FORMAT "99/99/9999" ";"
                            par_dtmvtfim        FORMAT "99/99/9999" ";"
                            crapcop.nmrescop    FORMAT "x(18)"      ";"
                            tt-lanctos.dstplanc FORMAT "x(18)"      ";"
                            tt-lanctos.tpconsul FORMAT "x(12)"      ";"
                            aux_dscoprel        FORMAT "x(18)" ";"
                            aux_qtdecoop        FORMAT "zzzz9" ";"
                            aux_qtdmovto        FORMAT "zzzz9" ";"
                            aux_vlrtotal        FORMAT "zzzz,zzz,zz9.99" ";"
                            aux_vlrtarif        FORMAT "zzzz,zzz,zz9.99" ";"
               SKIP.
           RUN pi_opcaor_zera_vars.
    
        END.
    
        RUN pi_opcaor_zera_vars.

    END.


END PROCEDURE.

PROCEDURE pi_opcaor_arquivo_sintetico:

    DEF INPUT PARAM par_dtmvtini AS DATE                        NO-UNDO.
    DEF INPUT PARAM par_dtmvtfim AS DATE                        NO-UNDO.
                    
    /* Quebra por COP e COPTFN */
    DEFINE VARIABLE icont AS INTEGER    NO-UNDO.

    /* A PAGAR */
    FOR EACH tt-lanctos NO-LOCK
       WHERE tt-lanctos.tpconsul  = "Outras Coop"
       BREAK BY tt-lanctos.cdcoptfn:

        ASSIGN aux_qtdecoop = aux_qtdecoop + tt-lanctos.qtdecoop
               aux_qtdmovto = aux_qtdmovto + tt-lanctos.qtdmovto
               aux_vlrtotal = aux_vlrtotal + tt-lanctos.vlrtotal
               aux_vlrtarif = aux_vlrtarif + tt-lanctos.vlrtarif.

        IF LAST-OF(tt-lanctos.cdcoptfn) THEN DO:
           PUT STREAM str_1 par_dtmvtini        FORMAT "99/99/9999" ";"
                            par_dtmvtfim        FORMAT "99/99/9999" ";"
                            crapcop.nmrescop    FORMAT "x(18)" ";"
                            "A PAGAR - TAAs Outras Cooperativas;"
                            tt-lanctos.dscoptfn FORMAT "x(18)" ";"
                            aux_qtdecoop        FORMAT "zzzz9" ";"
                            aux_qtdmovto        FORMAT "zzzz9" ";"
                            aux_vlrtotal        FORMAT "zzzz,zzz,zz9.99" ";"
                            aux_vlrtarif        FORMAT "zzzz,zzz,zz9.99" ";"
               SKIP.
           RUN pi_opcaor_zera_vars.
        END.

    END.

    RUN pi_opcaor_zera_vars.

    /* A RECEBER */
    FOR EACH tt-lanctos NO-LOCK
       WHERE tt-lanctos.tpconsul  = "TAA"
       BREAK BY tt-lanctos.cdcooper:


        ASSIGN aux_qtdecoop = aux_qtdecoop + tt-lanctos.qtdecoop
               aux_qtdmovto = aux_qtdmovto + tt-lanctos.qtdmovto
               aux_vlrtotal = aux_vlrtotal + tt-lanctos.vlrtotal
               aux_vlrtarif = aux_vlrtarif + tt-lanctos.vlrtarif.

        IF LAST-OF(tt-lanctos.cdcooper) THEN DO:
           PUT STREAM str_1 par_dtmvtini        FORMAT "99/99/9999" ";"
                            par_dtmvtfim        FORMAT "99/99/9999" ";"
                            crapcop.nmrescop    FORMAT "x(18)" ";"
                            "A RECEBER - Cooperados Outras Cooperativas;"
                            tt-lanctos.dscooper FORMAT "x(18)" ";"
                            aux_qtdecoop        FORMAT "zzzz9" ";"
                            aux_qtdmovto        FORMAT "zzzz9" ";"
                            aux_vlrtotal        FORMAT "zzzz,zzz,zz9.99" ";"
                            aux_vlrtarif        FORMAT "zzzz,zzz,zz9.99" ";"
               SKIP.
           RUN pi_opcaor_zera_vars.
        END.

    END.



END PROCEDURE.

PROCEDURE pi_opcaor_zera_vars:

    ASSIGN aux_qtdecoop = 0
           aux_qtdmovto = 0
           aux_vlrtotal = 0
           aux_vlrtarif = 0
           aux_dstitulo = "".

END PROCEDURE.

PROCEDURE proc_log_do_dia:

    DEF INPUT PARAM par_cdcooper AS INTE            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE            NO-UNDO.

    DEFINE VARIABLE aux_nmusuari    AS CHAR         NO-UNDO.
    DEFINE VARIABLE aux_dsdsenha    AS CHAR         NO-UNDO.
    DEFINE VARIABLE aux_nmdireto    AS CHAR         NO-UNDO.
    DEFINE VARIABLE aux_nmarqlog    AS CHAR         NO-UNDO.
    DEFINE VARIABLE aux_dscomand    AS CHAR         NO-UNDO.
    DEFINE VARIABLE aux_nmrescop    AS CHAR         NO-UNDO.
    
    FOR FIRST crabcop FIELDS(nmrescop) 
                      WHERE crabcop.cdcooper = par_cdcooper NO-LOCK:
        ASSIGN aux_nmrescop = LOWER(crabcop.nmrescop).
    END.
        
    /* sistema TAA */
    IF  craptfn.flsistaa  THEN
        ASSIGN aux_nmusuari = "ftp_cash"
               aux_dsdsenha = "cash$"
               aux_nmdireto = "LOG"
               aux_nmarqlog = "LG" +
                              STRING(craptfn.nrterfin,"9999") + "_" + 
                              STRING(YEAR(par_dtmvtolt),"9999") +
                              STRING(MONTH(par_dtmvtolt),"99")  +
                              STRING(DAY(par_dtmvtolt),"99")    +
                              ".log"
               
               aux_dscomand = "BuscaArquivoTAA.sh"            + " " +
                              TRIM(craptfn.nmnarede)          + " " +
                              aux_nmdireto                    + " " +
                              aux_dsdsenha                    + " " +
                              aux_nmusuari                    + " " +
                              aux_nmarqlog                    + " " +
                              STRING(craptfn.nrterfin,"9999") + " " +
                              aux_nmrescop                    + " " +
                              "1>/dev/null 2>/dev/null".
    ELSE
        ASSIGN aux_dscomand = "BuscaArquivoPC.sh "   +
                               craptfn.nmnarede + " " +
                               "LOGDIARIO$ " +
                               "ftp_cash " +
                               "ftpserver " +
                               "lg" + STRING(craptfn.nrterfin,"9999") + "_" +
                               STRING(YEAR(par_dtmvtolt),"9999") +
                               STRING(MONTH(par_dtmvtolt),"99") +
                               STRING(DAY(par_dtmvtolt),"99") + ".log " +
                               STRING(craptfn.nrterfin,"9999") +
                               " 1>/dev/null 2>/dev/null".
    
    UNIX SILENT VALUE(aux_dscomand).
    
END PROCEDURE.

PROCEDURE verifica_ping:

    DEFINE INPUT PARAM par_nmnarede    AS CHAR          NO-UNDO.

    DEFINE VARIABLE    aux_dsdlinha    AS CHAR          NO-UNDO.
    
    INPUT STREAM str_1 THROUGH VALUE ("ping -c 1 " + par_nmnarede) NO-ECHO.
   
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE
                  ON ERROR  UNDO, LEAVE:

        IMPORT STREAM str_1 UNFORMATTED aux_dsdlinha.

        IF  aux_dsdlinha MATCHES "*packets transmitted*"  THEN
            ASSIGN crattfn.dsdoping = TRIM(aux_dsdlinha).
        ELSE
            IF  aux_dsdlinha MATCHES "*unknown host*"  THEN
                ASSIGN crattfn.dsdoping = "Nao encontrado".
       

       

         
        

    END.

    INPUT STREAM str_1 CLOSE.
        
END PROCEDURE. /* verifica_ping */

PROCEDURE proc_depositos_efetuados:

    DEF  INPUT PARAM par_cdcooper AS INTE       NO-UNDO.
    DEF  INPUT PARAM par_nrterfin AS INTE       NO-UNDO.
    DEF OUTPUT PARAM par_qtenvelo AS INTE       NO-UNDO. 

    DEF VAR lfn_dttransa          AS DATE       NO-UNDO.
    DEF VAR lfn_hrtransa          AS INTE       NO-UNDO.
    
    FIND LAST craplfn WHERE craplfn.cdcooper = par_cdcooper AND
                            craplfn.nrterfin = par_nrterfin AND
                            craplfn.tpdtrans = 6 
                            USE-INDEX craplfn2 NO-LOCK NO-ERROR.
                              
    /* Se nunca houve Recolhimento de envelopes */ 
    IF  NOT AVAILABLE craplfn   THEN
        DO:
            FIND FIRST crapltr WHERE 
                       crapltr.cdcooper = par_cdcooper AND
                       crapltr.nrterfin = par_nrterfin AND
                       crapltr.cdhistor = 698  
                       USE-INDEX crapltr6 NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapltr  THEN
                ASSIGN lfn_dttransa = TODAY
                       lfn_hrtransa = TIME.
            ELSE
                ASSIGN lfn_dttransa = crapltr.dttransa
                       lfn_hrtransa = crapltr.hrtransa. 
        END.
    ELSE
        ASSIGN lfn_dttransa = craplfn.dttransa
               lfn_hrtransa = craplfn.hrtransa.

    FOR EACH crapltr WHERE crapltr.cdcooper  = par_cdcooper AND
                           crapltr.dttransa >= lfn_dttransa AND
                           crapltr.nrterfin  = par_nrterfin AND
                           crapltr.cdhistor  = 698
                           USE-INDEX crapltr6 NO-LOCK:

        IF  crapltr.dttransa = lfn_dttransa   THEN
            IF  crapltr.hrtransa <= lfn_hrtransa   THEN
                NEXT.

        ASSIGN par_qtenvelo = par_qtenvelo + 1.
        
    END. /* FOR EACH crapltr */

    RETURN "OK".
    
END PROCEDURE. /* proc_depositos_efetuados */

PROCEDURE verifica_movimento:

    DEF INPUT   PARAM par_cdcooper AS INT                           NO-UNDO.
    DEF INPUT   PARAM par_dtmvtolt AS DATE                          NO-UNDO.
    DEF INPUT   PARAM par_nrterfin AS INT                           NO-UNDO.
    DEF INPUT   PARAM par_cdhistor AS INT                           NO-UNDO.

    /* procura o registro */
    FIND crapstd WHERE crapstd.cdcooper = par_cdcooper  AND
                       crapstd.dtmvtolt = par_dtmvtolt  AND
                       crapstd.nrterfin = par_nrterfin  AND
                       crapstd.cdhistor = par_cdhistor
                       NO-LOCK  NO-ERROR.

    RETURN "OK".

END.


PROCEDURE status_saque:

    DEF INPUT   PARAM par_cdcooper AS INTE                          NO-UNDO.
    DEF INPUT   PARAM par_nrterfin AS INTE                          NO-UNDO.
    DEF OUTPUT  PARAM par_flgblsaq AS LOGICAL                       NO-UNDO.

    /* verifica se o terminal esta bloqueado para saque */
    FIND FIRST craptfn WHERE craptfn.cdcooper = par_cdcooper
                         AND craptfn.nrterfin = par_nrterfin
                             NO-LOCK  NO-ERROR.
    
    IF AVAIL craptfn THEN
        ASSIGN par_flgblsaq = craptfn.flgblsaq.
    ELSE
        ASSIGN par_flgblsaq = FALSE.

    RETURN "OK".
END. /* fim status_saque */


PROCEDURE alterar_status_saque:

    DEF INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF INPUT  PARAM par_nrterfin AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    
    DEF VAR aux_realizou AS CHAR                                    NO-UNDO.
    DEF VAR aux_dslogtaa AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmoperad AS CHAR                                    NO-UNDO.
    
    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcop THEN
    DO:
        ASSIGN par_dscritic = "Cooperativa nao encontrada".
        RETURN "NOK".
    END.

    FIND FIRST craptfn WHERE craptfn.cdcooper = par_cdcooper
                         AND craptfn.nrterfin = par_nrterfin
                         EXCLUSIVE-LOCK NO-ERROR.

    IF NOT AVAIL craptfn THEN
    DO:
        ASSIGN par_dscritic = "TAA " + STRING(par_nrterfin) + "nao encontrado".
        RETURN "NOK".
    END.
    
    FIND FIRST crapope WHERE crapope.cdcooper = par_cdcooper
                         AND crapope.cdoperad = par_cdoperad
                         NO-LOCK NO-ERROR.
    IF NOT AVAIL crapope THEN
    DO:
        ASSIGN par_dscritic = "Operador nao encontrado.".
        RETURN "NOK".
    END.
    
    IF craptfn.flgblsaq THEN
        ASSIGN craptfn.flgblsaq = FALSE
               aux_realizou = "Desbloqueou Saque em TAA " + 
                              STRING(par_nrterfin).
    ELSE
        ASSIGN craptfn.flgblsaq = TRUE
               aux_realizou = "Bloqueou Saque em TAA " + 
                              STRING(par_nrterfin).

    ASSIGN aux_dslogtaa = STRING(TODAY,"99/99/9999") + " - "      +
                          STRING(TIME,"HH:MM:SS") + " - "         +
                          "TAA: " + STRING(par_nrterfin) + " - "  +
                          craptfn.nmterfin + " - " + "Operador "  + 
                          par_cdoperad + " - " + crapope.nmoperad +
                          " " + aux_realizou + ".".
    
    UNIX SILENT VALUE("echo " + aux_dslogtaa +
                     " >> /usr/coop/" + TRIM(crapcop.dsdircop) + 
                     "/log/cash.log").

    RETURN "OK".

END. /* fim alterar_status_saque */

/* Verifica se o TAA usa notas de R$100,00. TAA_autorizador, operacao 75 */
PROCEDURE verifica_notas_cem:

    DEF INPUT   PARAM par_cdcooper AS INTE                          NO-UNDO.
    DEF INPUT   PARAM par_nrterfin AS INTE                          NO-UNDO.
    DEF OUTPUT  PARAM par_flgntcem AS LOGICAL                       NO-UNDO.

    FIND FIRST craptfn WHERE craptfn.cdcooper = par_cdcooper
                         AND craptfn.nrterfin = par_nrterfin
    NO-LOCK NO-ERROR.

    IF AVAIL craptfn THEN
        ASSIGN par_flgntcem = craptfn.flgntcem.
    ELSE
        ASSIGN par_flgntcem = FALSE.

    RETURN "OK".
END.
/* fim verifica_notas_cem */


/*.............................. PROCEDURES (FIM) ...........................*/

/*................................ FUNCTIONS ................................*/

FUNCTION LockTabela RETURNS CHARACTER PRIVATE 
    ( INPUT par_cddrecid AS RECID,
      INPUT par_nmtabela AS CHAR ):
/*-----------------------------------------------------------------------------
  Objetivo:  Identifica o usuario que esta locando o registro
     Notas:  
-----------------------------------------------------------------------------*/

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_loginusr AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmusuari AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdevice AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtconnec AS CHAR                                    NO-UNDO.
    DEF VAR aux_numipusr AS CHAR                                    NO-UNDO.
    DEF VAR aux_mslocktb AS CHAR                                    NO-UNDO.

    ASSIGN aux_mslocktb = "Registro sendo alterado em outro terminal " +
                          "(" + par_nmtabela + ").".

    IF  aux_idorigem = 3  THEN  /** InternetBank **/
        RETURN aux_mslocktb.

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
    
    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        RETURN aux_mslocktb.

    RUN acha-lock IN h-b1wgen9999 (INPUT par_cddrecid,
                                   INPUT "banco",
                                   INPUT par_nmtabela,
                                  OUTPUT aux_loginusr,
                                  OUTPUT aux_nmusuari,
                                  OUTPUT aux_dsdevice,
                                  OUTPUT aux_dtconnec, 
                                  OUTPUT aux_numipusr).

    DELETE OBJECT h-b1wgen9999.

    ASSIGN aux_mslocktb = aux_mslocktb + " Operador: " + 
                          aux_loginusr + " - " + aux_nmusuari.

    RETURN aux_mslocktb.   /* Function return value. */

END FUNCTION.
