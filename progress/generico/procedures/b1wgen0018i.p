/*.............................................................................

   Programa: b1wgen0018i.p                  
   Autor   : Gabriel Capoia - DB1.
   Data    : 05/01/2012                        Ultima atualizacao: 05/01/2012
    
   Dados referentes ao programa:

   Objetivo  : Tratar impressoes da BO 0018.
   
   Alteracoes: 12/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
               
               29/11/2013 - Retirado comentários e códigos comentados
                            desnecessários (Jéssica DB1).
                
               30/04/2015 - Alteracao da proc. conferencia_cheques_em_custodia 
                            sobre a forma de iteracao das contas da cooperativa 
                            e tambem do filtro para a conta 85448(Cooper).
                            (Carlos Rafael Tanholi - SM 281222).

               26/06/2017 - Retirada separaçao de cheques maiores e menores no 
                            relatório CRRL308. Criada nova coluna "Cheques Outros Bancos"
                            Retirado parâmetro Cheques Maiores apresentado no cabeçalho.
                            PRJ367. (Lombardi)
                            
              09/08/2019 - Alteracao da busca_cheques_em_custodia para considerar
                           a data de custodia ao inves da data de liberacao.
                           INC0016418 (Jefferson - Mout'S)
   
.............................................................................*/

/*................................ DEFINICOES ...............................*/
{ sistema/generico/includes/b1wgen0018tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1cabrelvar.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF STREAM str_1.

DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                        NO-UNDO.
DEF VAR aux_contador AS INTE                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrsequen AS INTE                                        NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.

DEF VAR tab_vlchqmai AS DECI FORMAT "zzz,zzz,zz9.99"                NO-UNDO.

DEF VAR rel_dtmvtolt AS DATE                                        NO-UNDO.
DEF VAR rel_dtmvtini AS DATE                                        NO-UNDO.
DEF VAR rel_dtmvtfim AS DATE                                        NO-UNDO.

DEF VAR aux_nrdconta AS INTE                                        NO-UNDO.

DEF VAR pac_vlchqcop AS DECI FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF VAR pac_vlcheque AS DECI FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF VAR pac_vlchqtot AS DECI FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF VAR pac_qtchqcop AS INTE FORMAT "zzz9"                          NO-UNDO.
DEF VAR pac_qtcheque AS INTE FORMAT "zzz9"                          NO-UNDO.
DEF VAR pac_qtchqtot AS INTE FORMAT "zzz9"                          NO-UNDO.
DEF VAR pac_qtdlotes AS INTE FORMAT "zz9"                           NO-UNDO.
DEF VAR pac_dsdtraco AS CHAR FORMAT "x(132)"                        NO-UNDO.
DEF VAR aux_vlchqmai AS DECI FORMAT "zzz,zzz,zz9.99"                NO-UNDO.

DEF VAR aux_dtliber1 AS DATE FORMAT "99/99/9999"                    NO-UNDO.
DEF VAR aux_dtliber2 AS DATE FORMAT "99/99/9999"                    NO-UNDO.

DEF VAR aux_geralchq AS DECI   FORMAT "zzzz,zzz,zz9.99"             NO-UNDO.

DEF VAR lot_vlchqcop AS DECI FORMAT "zzzz,zzz,zz9.99"               NO-UNDO.

DEF VAR lot_vlcheque AS DECI FORMAT "zzzz,zzz,zz9.99"               NO-UNDO.
DEF VAR lot_qtchqcop AS INTE FORMAT "zzz9"                          NO-UNDO.

DEF VAR lot_qtcheque AS INTE FORMAT "zzz9"                          NO-UNDO.
DEF VAR lot_nmoperad AS CHAR FORMAT "x(10)"                         NO-UNDO.

FORM crawlot.dtmvtolt
     crawlot.cdagenci
     crawlot.nrdolote
     crawlot.nrdconta
     crawlot.nrborder
     crawlot.qtchqcop
     crawlot.vlchqcop
     crawlot.qtcheque AT 69
     crawlot.vlcheque AT 73
     crawlot.qtchqtot AT 89
     crawlot.vlchqtot
     crawlot.nmoperad
     WITH NO-LABELS NO-BOX  WIDTH 132 FRAME f_lotes.

FORM rel_dtmvtolt            AT   1 LABEL "REFERENCIA"  FORMAT "99/99/9999"
     tt-relat-lotes.dsdsaldo AT  55 NO-LABEL            FORMAT "x(25)"
     SKIP(1)
     "  CHQS COOPERATIVA   CHEQUES OUTROS BANCOS" AT  46
     "------ TOTAL ------"   
     SKIP
     "DIGITADO EM PA     LOTE   CONTA/DV   BORDERO QTD.         VALOR" 
     "    QTD.         VALOR "
     "QTD.         VALOR OPERADOR"
     SKIP(1)
     WITH SIDE-LABELS NO-BOX WIDTH 132 FRAME f_cab.

FORM SKIP(1)
         "TOTAL DO PA  ==>"  AT    1               
         pac_qtdlotes        AT   19               NO-LABEL "LOTE(S)"
         pac_qtchqcop        AT   45               NO-LABEL
         pac_vlchqcop                              NO-LABEL
         pac_qtcheque        AT   68               NO-LABEL
         pac_vlcheque                              NO-LABEL
         pac_qtchqtot        AT   88               NO-LABEL
         pac_vlchqtot                              NO-LABEL
         SKIP(1)
         pac_dsdtraco        AT    1               NO-LABEL 
         SKIP(1)
         WITH NO-LABELS NO-BOX  WIDTH 132 FRAME f_pac.

/**************************************************/

FORM rel_dtmvtini             AT  1  LABEL "PERIODO"  FORMAT "99/99/9999" " a "
     rel_dtmvtfim                    NO-LABEL         FORMAT "99/99/9999"
     tt-relat-custod.dsdsaldo AT 55  NO-LABEL         FORMAT "x(25)"
     SKIP(1)
     " CHEQUES COOPERATIVA  CHEQUES OUTROS BANCOS" AT  24
     " ------ TOTAL ------"
     SKIP(1)
     WITH SIDE-LABELS NO-BOX WIDTH 132 FRAME f_cab_c.
      
FORM crawlot.cdagenci  LABEL "PA"        FORMAT "zz9"
     crawlot.nrdolote  LABEL "LOTE"          
     crawlot.nrdconta  LABEL "CONTA/DV"  
     crawlot.qtchqcop  LABEL "QTD"        FORMAT "zzz9"                
     crawlot.vlchqcop  LABEL "VALOR"      FORMAT "zzzz,zzz,zz9.99"
     crawlot.qtcheque  LABEL "QTD"        FORMAT "zzzzz9"                
     crawlot.vlcheque  LABEL "VALOR"      FORMAT "zzzz,zzz,zz9.99"
     crawlot.qtchqtot  LABEL "QTD"        FORMAT "zzz9"   
     crawlot.vlchqtot  LABEL "VALOR"      FORMAT "zzzz,zzz,zz9.99"
     crawlot.dtlibera  LABEL "LIBERACAO"                       
     crawlot.nmoperad  LABEL "OPERADOR"                    
     WITH NO-LABELS NO-BOX  DOWN WIDTH 132 FRAME f_lotes_c.
      
FORM SKIP(1)
     "DO PA "            AT    1               
     pac_qtdlotes        AT   11               NO-LABEL
     pac_qtchqcop        AT   24               NO-LABEL
     pac_vlchqcop        AT   30               NO-LABEL
     pac_qtcheque        AT   47               NO-LABEL
     pac_vlcheque        AT   53               NO-LABEL
     pac_qtchqtot        AT   68               NO-LABEL
     pac_vlchqtot        AT   74               NO-LABEL
     SKIP
     pac_dsdtraco        AT    1               NO-LABEL 
     WITH NO-LABELS NO-BOX  WIDTH 132 FRAME f_pac_c.
      
FORM SKIP(1)
     "GERAL"                         AT    1               
     tt-relat-custod.qtdlotes        AT   11               NO-LABEL
     tt-relat-custod.qtchqcop        AT   24               NO-LABEL
     tt-relat-custod.vlchqcop                              NO-LABEL
     tt-relat-custod.qtcheque                              NO-LABEL
     tt-relat-custod.vlcheque                              NO-LABEL
     tt-relat-custod.qtchqtot                              NO-LABEL
     tt-relat-custod.vlchqtot                              NO-LABEL
     WITH NO-LABELS NO-BOX WIDTH 132 FRAME f_tot.
      
FORM SKIP(1)
     "Liberar em"       AT  1
     "Banco"            AT 14
     "Comp."            AT 22
     "Agencia"          AT 30
     "Conta"            AT 51
     "Cheque"           AT 60
     "Valor"            AT 78
     "CMC7"             AT 99
     SKIP(1)
     WITH NO-LABEL NO-BOX WIDTH 132 FRAME f_titulo.

FORM crabcst.dtlibera   AT  1  
     crabcst.cdbanchq   AT 14
     crabcst.cdcmpchq   AT 22
     crabcst.cdagechq   AT 30
     crabcst.nrctachq   AT 40
     crabcst.nrcheque   AT 59
     crabcst.vlcheque   AT 69
     crabcst.dsdocmc7   AT 86
     WITH NO-LABELS DOWN NO-BOX WIDTH 132 FRAME f_detalhado.
      
FORM SKIP(1)
     "TOTAL GERAL PA'S:"       AT   72               
     aux_geralchq               AT   92  
     WITH NO-LABELS NO-BOX WIDTH 132 FRAME f_totgeral.

/*************************************************/

/*........................... PROCEDURES EXTERNAS ..........................*/

PROCEDURE gera-relatorio-lotes:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.

    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabcop FOR crapcop.
    
    FORM SKIP
         "TOTAL GERAL ==>"   AT    1               
         tt-relat-lotes.qtdlotes        AT   19           NO-LABEL "LOTE(S)"
         tt-relat-lotes.qtchqcop        AT   45           NO-LABEL
         tt-relat-lotes.vlchqcop                          NO-LABEL
         tt-relat-lotes.qtcheque        AT   68           NO-LABEL
         tt-relat-lotes.vlcheque                          NO-LABEL
         tt-relat-lotes.qtchqtot        AT   88           NO-LABEL
         tt-relat-lotes.vlchqtot                          NO-LABEL
         WITH NO-LABELS NO-BOX  WIDTH 132 FRAME f_tot.

    ASSIGN pac_dsdtraco = FILL("-",132).

    EMPTY TEMP-TABLE tt-erro.

    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        
        FOR FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crabcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.
        
        ASSIGN aux_nmendter = "/usr/coop/" + crabcop.dsdircop + "/rl/" +
                              par_dsiduser.

        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        RUN busca_lotes_descto
            ( INPUT par_cdcooper,
              INPUT par_cdagencx,
              INPUT par_cdprogra,
              INPUT par_dtmvtolt,
             OUTPUT aux_cdcritic,
             OUTPUT TABLE tt-erro,
             OUTPUT TABLE tt-relat-lotes,
             OUTPUT TABLE crawlot).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Imprime.

        FIND tt-relat-lotes NO-ERROR.

        IF  NOT AVAIL tt-relat-lotes   THEN
            LEAVE Imprime.

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

        PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
        PUT STREAM str_1 CONTROL "\0330\033x0\017"  NULL.

        /* Cdempres = 11 , Relatorio 308 em 132 colunas */
        { sistema/generico/includes/cabrel.i "11" "308" "132" }

        ASSIGN rel_dtmvtolt = par_dtmvtolt.

        DISPLAY STREAM 
                str_1 rel_dtmvtolt tt-relat-lotes.dsdsaldo WITH FRAME f_cab.    

        ASSIGN pac_qtdlotes = 0
               pac_qtchqcop = 0 
               pac_vlchqcop = 0
               pac_qtcheque = 0 
               pac_vlcheque = 0
               pac_qtchqtot = 0 
               pac_vlchqtot = 0.

        IF  par_cdcooper = 4 THEN
            RUN proc_lista_4.
        ELSE
            RUN proc_lista.


        IF  LINE-COUNTER(str_1) > 80  THEN
            DO:
                PAGE STREAM str_1.

                DISPLAY STREAM str_1 
                        rel_dtmvtolt tt-relat-lotes.dsdsaldo WITH FRAME f_cab.
            END.

        CLEAR FRAME f_tot.

        DISPLAY STREAM str_1 
                tt-relat-lotes.qtdlotes  
                tt-relat-lotes.qtchqcop WHEN tt-relat-lotes.qtchqcop > 0
                tt-relat-lotes.vlchqcop WHEN tt-relat-lotes.vlchqcop > 0
                tt-relat-lotes.qtcheque WHEN tt-relat-lotes.qtcheque > 0
                tt-relat-lotes.vlcheque WHEN tt-relat-lotes.vlcheque > 0
                tt-relat-lotes.qtchqtot  
                tt-relat-lotes.vlchqtot  
                WITH FRAME f_tot.
        
        IF  LINE-COUNTER(str_1) > 65  THEN
            PAGE STREAM str_1.

        DISPLAY STREAM str_1
                SKIP(5)
                "____________________________________" AT 97 SKIP
                "  CADASTRO E VISTO DO FUNCIONARIO   " AT 97
                WITH NO-LABELS NO-BOX WIDTH 132 FRAME f_visto.
        
        PAGE STREAM str_1.
        
        PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
        PUT STREAM str_1 CONTROL "\0330\033x0"      NULL.
        
        OUTPUT STREAM str_1 CLOSE.
        
        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
                IF  NOT VALID-HANDLE(h-b1wgen0024) THEN
                    RUN sistema/generico/procedures/b1wgen0024.p
                        PERSISTENT SET h-b1wgen0024.

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

        ASSIGN aux_returnvl = "OK".

        LEAVE Imprime.

    END. /*Imprime*/

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0 OR
        TEMP-TABLE tt-erro:HAS-RECORDS
        THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            FIND FIRST tt-erro NO-LOCK NO-ERROR.

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

END PROCEDURE. /* gera_relatorio_descto */

PROCEDURE gera-cheques-resgatados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inresgat AS LOGI                           NO-UNDO.
    
    DEF  INPUT PARAM TABLE FOR tt-crapass.

    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabcop FOR crapcop.

    DEF VAR tot_qtcheque AS INTE                                    NO-UNDO.
    DEF VAR tot_vlcheque AS DECI                                    NO-UNDO.

    FORM tt-crapcdb.dtmvtolt AT  1 LABEL "Recebido"   FORMAT "99/99/9999" 
         tt-crapcdb.dtlibera AT 12 LABEL "Liberar em" FORMAT "99/99/9999"
         tt-crapcdb.cdbanchq AT 23 LABEL "Bco"        FORMAT "zz9"
         tt-crapcdb.cdagechq AT 27 LABEL "Ag."        FORMAT "zzz9"
         tt-crapcdb.nrctachq AT 32 LABEL "Conta"      FORMAT "zzz,zzz,zzz,9"
         tt-crapcdb.nrcherel AT 46 LABEL "Cheque"     FORMAT "zzz,zzz,9"
         tt-crapcdb.vlcheque AT 56 LABEL "Valor"      FORMAT "zzz,zzz,zz9.99"
         tt-crapcdb.dtdevolu AT 71 LABEL "Resgatado"  FORMAT "99/99/9999"
         WITH NO-BOX NO-LABELS DOWN FRAME f_lanctos.
    
    FORM par_nrdconta        AT  1 LABEL "Conta/dv" FORMAT "zzzz,zzz,9"
         tt-crapass.nmprimtl AT 22 LABEL "Titular"  FORMAT "x(40)"
         SKIP(1)
         WITH NO-BOX NO-LABELS SIDE-LABELS FRAME f_descto.

    EMPTY TEMP-TABLE tt-erro.

    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        
        FOR FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crabcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        RUN busca_cheques_descontados_conta
            ( INPUT par_cdcooper,
              INPUT par_nrdconta,
              INPUT par_inresgat,
              INPUT par_dtmvtolt,
             OUTPUT TABLE tt-crapcdb).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Imprime.
        
        ASSIGN aux_nmendter = "/usr/coop/" + crabcop.dsdircop + "/rl/" +
                              par_dsiduser.

        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        FIND FIRST tt-crapass NO-ERROR.

        IF  NOT AVAIL tt-crapass THEN
            DO:
                ASSIGN aux_returnvl = "NOK".
                LEAVE Imprime.
            END.

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

        PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
        PUT STREAM str_1 CONTROL "\0330\033x0"      NULL.

        { sistema/generico/includes/b1cabrel080.i "11" "306" }

        DISPLAY STREAM str_1 par_nrdconta
                tt-crapass.nmprimtl WITH FRAME f_descto.

        FOR EACH tt-crapcdb USE-INDEX crapcdb2:

            IF  tt-crapcdb.dtdevolu = ? THEN
                ASSIGN tot_qtcheque = tot_qtcheque + 1
                       tot_vlcheque = tot_vlcheque + tt-crapcdb.vlcheque.

            DISPLAY STREAM str_1
                    tt-crapcdb.dtmvtolt tt-crapcdb.dtlibera  
                    tt-crapcdb.cdbanchq tt-crapcdb.cdagechq
                    tt-crapcdb.nrctachq tt-crapcdb.nrcherel
                    tt-crapcdb.vlcheque tt-crapcdb.dtdevolu
                    WITH FRAME f_lanctos.

            DOWN STREAM str_1 WITH FRAME f_lanctos.

            IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN
                DO:
                    PAGE STREAM str_1.

                    DISPLAY STREAM str_1 par_nrdconta
                                   tt-crapass.nmprimtl 
                                   WITH FRAME f_descto.
                END.                

        END.  /*  Fim do FOR EACH  */

        IF  tot_qtcheque > 0 THEN
            DISPLAY STREAM str_1
                    SKIP(1)
                    "TOTAIS ===>  "
                    tot_qtcheque FORMAT "zzz,zz9" "cheque(s)"
                    tot_vlcheque FORMAT "zzz,zzz,zz9.99" AT 56
                    WITH NO-BOX NO-LABELS FRAME f_total.
        ELSE
            DISPLAY STREAM str_1
                    "NAO HA CHEQUES DESCONTADOS!"
                    WITH NO-BOX FRAME f_sem_cheque.
        
        OUTPUT STREAM str_1 CLOSE.
        
        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
                IF  NOT VALID-HANDLE(h-b1wgen0024) THEN
                    RUN sistema/generico/procedures/b1wgen0024.p
                        PERSISTENT SET h-b1wgen0024.

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

        ASSIGN aux_returnvl = "OK".

        LEAVE Imprime.

    END. /*Imprime*/

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0 OR
        TEMP-TABLE tt-erro:HAS-RECORDS
        THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            FIND FIRST tt-erro NO-LOCK NO-ERROR.

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

END PROCEDURE. /* gera-cheques-resgatados */

PROCEDURE gera-cheques-resgatados-geral:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdctalis AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlsupinf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inchqcop AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM aux_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabcop FOR crapcop.

    DEF VAR rel_dsrefere AS CHAR                                    NO-UNDO.
    DEF VAR rel_qtcheque AS INTE                                    NO-UNDO.
    DEF VAR rel_vlcheque AS DECI                                    NO-UNDO.

    FORM "REFERENTE PERIODO DE" par_dtiniper FORMAT "99/99/9999" "ATE" 
         par_dtfimper FORMAT "99/99/9999" " - " rel_dsrefere FORMAT "x(60)"
         SKIP(2)
         WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_refere.
    
    FORM tt-crapcdb.dtlibera AT 01 LABEL "LIBERACAO"
         tt-crapcdb.dtmvtolt AT 13 LABEL "DIGITADO EM"
         tt-crapcdb.cdagenci AT 26 LABEL "PA"
         tt-crapcdb.nrdolote AT 31 LABEL "LOTE"
         tt-crapcdb.nrdconta AT 40 LABEL "CONTA/DV"
         tt-crapcdb.cdbanchq AT 52 LABEL "BANCO"
         tt-crapcdb.cdagechq AT 59 LABEL "AGENCIA"
         tt-crapcdb.nrctachq AT 68 LABEL "CTA CHQ"
         tt-crapcdb.nrcheque AT 86 LABEL "CHEQUE"
         tt-crapcdb.vlcheque AT 95 LABEL "VALOR"    FORMAT "zzz,zzz,zz9.99"
         WITH COLUMN 10 NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_cheques.
          
    FORM SKIP(1)
         "TOTAL ==>"  AT 68               
         rel_qtcheque AT 86 FORMAT "zzz,zz9"
         rel_vlcheque AT 95 FORMAT "zzz,zzz,zz9.99"
         WITH COLUMN 10 NO-BOX NO-LABELS WIDTH 132 FRAME f_total.

    EMPTY TEMP-TABLE tt-erro.

    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        
        FOR FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crabcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        ASSIGN aux_nmendter = "/usr/coop/" + crabcop.dsdircop + "/rl/" +
                              par_dsiduser.

        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        RUN busca_cheques_descontados_geral
            ( INPUT par_cdcooper,
              INPUT par_cdagenci,
              INPUT par_nrdcaixa,
              INPUT par_cdprogra,
              INPUT par_dtiniper,
              INPUT par_dtfimper,
              INPUT par_cdctalis,
              INPUT par_vlsupinf,
              INPUT par_inchqcop,
             OUTPUT TABLE tt-crapcdb,
             OUTPUT TABLE tt-erro,
             OUTPUT rel_dsrefere,
             OUTPUT aux_cdcritic) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN aux_dscritic = aux_dscritic + 
                                     ERROR-STATUS:GET-MESSAGE(1).
               LEAVE Imprime.
            END.

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Imprime.

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

        /* Cdempres = 11 , Relatorio 307 em 132 colunas */
        { sistema/generico/includes/cabrel.i "11" "307" "132" }

        DISPLAY STREAM str_1 par_dtiniper par_dtfimper
                             rel_dsrefere WITH FRAME f_refere.

        FOR EACH tt-crapcdb BY tt-crapcdb.nrcheque 
                            BY tt-crapcdb.cdbanchq
                            BY tt-crapcdb.nrctachq:

            ASSIGN rel_qtcheque = rel_qtcheque + 1
                   rel_vlcheque = rel_vlcheque + tt-crapcdb.vlcheque.
            
            DISPLAY STREAM str_1
                    tt-crapcdb.dtlibera tt-crapcdb.dtmvtolt 
                    tt-crapcdb.cdagenci tt-crapcdb.nrdolote
                    tt-crapcdb.nrdconta tt-crapcdb.cdbanchq
                    tt-crapcdb.cdagechq tt-crapcdb.nrctachq
                    tt-crapcdb.nrcheque tt-crapcdb.vlcheque
                    WITH FRAME f_cheques.

            DOWN STREAM str_1 WITH FRAME f_cheques.

            IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN
                DO:
                    PAGE STREAM str_1.

                    DISPLAY STREAM str_1 par_dtiniper par_dtfimper
                                         rel_dsrefere WITH FRAME f_refere.
                END.
        END.  /*  Fim do FOR EACH -- crapcdb  */

        IF  LINE-COUNTER(str_1) > 80  THEN
            DO:
                PAGE STREAM str_1.

                DISPLAY STREAM str_1 par_dtiniper par_dtfimper
                                     rel_dsrefere WITH FRAME f_refere.
            END.

        DISPLAY STREAM str_1 rel_qtcheque rel_vlcheque WITH FRAME f_total.

        OUTPUT STREAM str_1 CLOSE.
        
        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
                IF  NOT VALID-HANDLE(h-b1wgen0024) THEN
                    RUN sistema/generico/procedures/b1wgen0024.p
                        PERSISTENT SET h-b1wgen0024.

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

        ASSIGN aux_returnvl = "OK".

        LEAVE Imprime.

    END. /*Imprime*/

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0 OR
        TEMP-TABLE tt-erro:HAS-RECORDS
        THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            FIND FIRST tt-erro NO-LOCK NO-ERROR.

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
    
    RETURN aux_returnvl.

END PROCEDURE. /* gera-cheques-resgatados-geral */

PROCEDURE gera-conferencia-cheques:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM aux_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabcop FOR crapcop.

    DEF VAR aux_containi AS INTE                                    NO-UNDO.
    DEF VAR aux_contafim AS INTE                                    NO-UNDO.
    DEF VAR tot_vlchqcop AS DECI    FORMAT "zzzz,zzz,zz9.99"        NO-UNDO.
    DEF VAR tot_vlchqtot AS DECI    FORMAT "zzzz,zzz,zz9.99"        NO-UNDO.
    
    FORM HEADER "Periodo Solicitado: De" par_dtiniper FORMAT "99/99/9999"
         "Ate" par_dtfimper FORMAT "99/99/9999" SKIP(2)
         "PA    Conta/Dv Titular" SPACE(44) "Digitado em Liberacao  Banco"
         "Agencia  Cheque          Valor"  SKIP
         "--- ---------- --------------------------------------------------" 
         "----------- ---------- ----- ------- ------- --------------" SKIP
         WITH WIDTH 132 NO-BOX NO-LABELS FRAME f_cabecalho NO-ATTR-SPACE PAGE-TOP.
         
    FORM tt-crapcdb.cdagenci 
         tt-crapcdb.nrdconta 
         tt-crapcdb.nmprimtl 
         tt-crapcdb.dtmvtolt SPACE(2)
         tt-crapcdb.dtlibera 
         tt-crapcdb.cdbanchq SPACE(3)
         tt-crapcdb.cdagechq 
         tt-crapcdb.nrcheque 
         tt-crapcdb.vlcheque  
         WITH DOWN WIDTH 132 NO-BOX NO-LABELS FRAME f_descto.
    
    FORM SKIP(1)
         "TOTAL" AT 95 tot_vlchqcop
         SKIP(1)
         WITH WIDTH 132 NO-BOX NO-LABELS FRAME f_total_coop.
         
    FORM SKIP(1)
         "TOTAL GERAL" AT 89 tot_vlchqtot
         WITH WIDTH 132 NO-BOX NO-LABELS FRAME f_total_geral.

    ASSIGN aux_containi = par_nrdconta
           aux_contafim = IF par_nrdconta = 0 THEN 999999999
                             ELSE par_nrdconta.

    EMPTY TEMP-TABLE tt-erro.

    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        
        FOR FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crabcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        ASSIGN aux_nmendter = "/usr/coop/" + crabcop.dsdircop + "/rl/" +
                              par_dsiduser.

        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        RUN conferencia_cheques_descontados
            ( INPUT par_cdcooper,
              INPUT par_dtiniper,
              INPUT par_dtfimper,
              INPUT aux_containi,
              INPUT aux_contafim,
              INPUT par_cdagencx,
             OUTPUT TABLE tt-erro,
             OUTPUT TABLE tt-crapcdb).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Imprime.

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

        PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
        PUT STREAM str_1 CONTROL "\0330\033x0\017" NULL.

        /* Cdempres = 11 , Relatorio 307 em 132 colunas */
        { sistema/generico/includes/cabrel.i "11" "307" "132" }

        VIEW STREAM str_1 FRAME f_cabecalho.

        FOR EACH tt-crapcdb BREAK BY tt-crapcdb.cdcooper
                                  BY tt-crapcdb.cdagenci
                                  BY tt-crapcdb.nrdconta 
                                  BY tt-crapcdb.dtlibera
                                  BY tt-crapcdb.nrcheque:

            IF  FIRST-OF(tt-crapcdb.cdagenci)   THEN
                ASSIGN tot_vlchqcop = 0.

            ASSIGN tot_vlchqcop = tot_vlchqcop + tt-crapcdb.vlcheque.

            IF  LINE-COUNTER(str_1) > 80 THEN
                PAGE STREAM str_1.

            DISPLAY STREAM str_1
                    tt-crapcdb.cdagenci tt-crapcdb.nrdconta 
                    tt-crapcdb.nmprimtl tt-crapcdb.dtmvtolt 
                    tt-crapcdb.dtlibera tt-crapcdb.cdbanchq 
                    tt-crapcdb.cdagechq tt-crapcdb.nrcheque 
                    tt-crapcdb.vlcheque 
                    WITH FRAME f_descto.

            DOWN STREAM str_1 WITH FRAME f_descto.

            IF  LAST-OF(tt-crapcdb.cdagenci)   THEN
                DO:
                    ASSIGN tot_vlchqtot = tot_vlchqtot + tot_vlchqcop.

                    DISPLAY STREAM str_1 
                            tot_vlchqcop   
                            WITH FRAME f_total_coop.

                    DOWN STREAM str_1 WITH FRAME f_total_coop.
                END.

            IF  LAST(tt-crapcdb.cdagenci)              AND
                par_cdagencx = 0 /* Todos os PACs */   THEN
                DO:
                    DISPLAY STREAM str_1
                             tot_vlchqtot
                             WITH FRAME f_total_geral.

                    DOWN STREAM str_1 WITH FRAME f_total_geral.
                END.           

        END. /* FOR EACH tt-crapcdb */
        
        PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
        PUT STREAM str_1 CONTROL "\0330\033x0"      NULL.

        OUTPUT STREAM str_1 CLOSE.
        
        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
                IF  NOT VALID-HANDLE(h-b1wgen0024) THEN
                    RUN sistema/generico/procedures/b1wgen0024.p
                        PERSISTENT SET h-b1wgen0024.

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

        ASSIGN aux_returnvl = "OK".

        LEAVE Imprime.

    END. /*Imprime*/

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0 OR
        TEMP-TABLE tt-erro:HAS-RECORDS
        THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            FIND FIRST tt-erro NO-LOCK NO-ERROR.

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
    
    RETURN aux_returnvl.

END PROCEDURE. /* gera-conferencia-cheques */

PROCEDURE gera-relatorio-fechamento:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtlibera AS DATE FORMAT "99/99/9999"       NO-UNDO.
    
    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabcop FOR crapcop.

    DEF   VAR rel_qtcompln AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
    DEF   VAR rel_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.

    DEF   VAR aux_nmoperad AS CHAR    FORMAT "x(10)"                     NO-UNDO.
    DEF   VAR aux_totqtinf LIKE craplot.qtinfoln                         NO-UNDO.
    DEF   VAR aux_totvlcom LIKE craplot.vlcompdb                         NO-UNDO.
    DEF   VAR aux_qtdlotes LIKE craplot.nrdolote                         NO-UNDO.

    FORM "LIBERACAO PARA:" par_dtlibera  
         "** COOPER **" AT 69 SKIP(1)
         WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_cab_1.
          
    FORM crawlot.dtmvtolt AT 1  COLUMN-LABEL "DATA"
         crawlot.cdagenci AT 14 COLUMN-LABEL "PA"      FORMAT "zz9"
         crawlot.cdbccxlt AT 19 COLUMN-LABEL "CXA"
         crawlot.nrdolote AT 24 COLUMN-LABEL "   LOTE"
         crawlot.qtcompln AT 32 COLUMN-LABEL "QTD."     FORMAT "zzz,zz9"
         crawlot.vlcompdb AT 42 COLUMN-LABEL "VALOR"    FORMAT "zzz,zzz,zzz,zz9.99"
         crawlot.nmoperad AT 62 COLUMN-LABEL "DIGITADO POR"           
         WITH DOWN NO-BOX WIDTH 80 FRAME f_lotes_1.
    
    FORM  SKIP(1)
          tt-relat-lotes.qtdlotes AT 24                 FORMAT "zzz,zz9" 
          tt-relat-lotes.qtchqtot AT 32                 FORMAT "zz,zz9"
          tt-relat-lotes.vlchqtot AT 42                 FORMAT "zzz,zzz,zzz,zz9.99"
          WITH NO-LABEL NO-BOX WIDTH 80 FRAME f_total_1.

    EMPTY TEMP-TABLE tt-erro.

    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        
        FOR FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crabcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        ASSIGN aux_nmendter = "/usr/coop/" + crabcop.dsdircop + "/rl/" +
                              par_dsiduser.

        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        RUN busca_lotes_custodia
            ( INPUT par_cdcooper,
              INPUT par_cdagenci,
              INPUT par_nrdcaixa,
              INPUT par_dtlibera,
             OUTPUT TABLE tt-relat-lotes,
             OUTPUT TABLE crawlot).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Imprime.

        FIND tt-relat-lotes NO-ERROR.

        IF  NOT AVAIL tt-relat-lotes THEN
            LEAVE Imprime.

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

        PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
        PUT STREAM str_1 CONTROL "\0330\033x0"      NULL.

        { sistema/generico/includes/b1cabrel080.i "11" "246" }

        DISPLAY STREAM str_1 par_dtlibera WITH FRAME f_cab_1.

        FOR EACH crawlot BREAK BY crawlot.dtmvtolt
                               BY crawlot.cdagenci
                               BY crawlot.dtmvtolt
                               BY crawlot.nrdolote:

            IF  LINE-COUNTER(str_1) > 80  THEN
                DO:
                    PAGE STREAM str_1.
                    DISPLAY STREAM str_1 par_dtlibera 
                        WITH FRAME f_cab_1.
                END.

            DISPLAY STREAM str_1 crawlot.dtmvtolt 
                crawlot.cdagenci
                crawlot.cdbccxlt
                crawlot.nrdolote
                crawlot.qtcompln
                crawlot.vlcompdb
                crawlot.nmoperad
                WITH FRAME f_lotes_1.
        
            DOWN STREAM str_1 WITH FRAME f_lotes_1.

        END.  /*  Fim do FOR EACH  */

        IF  LINE-COUNTER(str_1) > 80 THEN
            DO:
                PAGE STREAM str_1.
                DISPLAY STREAM str_1 par_dtlibera 
                    WITH FRAME f_cab_1.
            END.

        DISPLAY STREAM str_1
            tt-relat-lotes.qtdlotes tt-relat-lotes.qtchqtot 
            tt-relat-lotes.vlchqtot WITH FRAME f_total_1.

        DOWN STREAM str_1 WITH FRAME f_total_1.        
         
        PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
        PUT STREAM str_1 CONTROL "\0330\033x0"      NULL.

        OUTPUT STREAM str_1 CLOSE.
        
        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
                IF  NOT VALID-HANDLE(h-b1wgen0024) THEN
                    RUN sistema/generico/procedures/b1wgen0024.p
                        PERSISTENT SET h-b1wgen0024.

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

        ASSIGN aux_returnvl = "OK".

        LEAVE Imprime.

    END. /*Imprime*/

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0 OR
        TEMP-TABLE tt-erro:HAS-RECORDS
        THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            FIND FIRST tt-erro NO-LOCK NO-ERROR.

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
    
    RETURN aux_returnvl.

END PROCEDURE. /* gera-relatorio-fechamento */

PROCEDURE gera-lotes-custodia:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtini AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtfim AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdopcao AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgrelat AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.

    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_msgretur AS CHAR                          NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabcop FOR crapcop.

    DEF VAR aux_nmdireto AS CHAR                                    NO-UNDO.
    
    ASSIGN pac_dsdtraco = FILL("-",132)
           rel_dtmvtini = par_dtmvtini
           rel_dtmvtfim = par_dtmvtfim.

    EMPTY TEMP-TABLE tt-erro.
    
    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        
        FOR FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crabcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        IF  par_nmdopcao /* Arquivo */ THEN
            DO:
                ASSIGN aux_nmdireto = "/micros/" + crabcop.dsdircop + "/"
                       par_dsiduser = REPLACE(par_dsiduser," ","").

                IF  par_dsiduser = "" THEN 
                    DO:
                        ASSIGN aux_dscritic = "Arquivo nao informado !!".
                        LEAVE Imprime.
                    END.
        
                 ASSIGN aux_nmarqimp = aux_nmdireto + par_dsiduser + ".ex".
                 
             END. /* IF   par_nmdopcao  /* Arquivo */ */
        ELSE
            DO:
                ASSIGN aux_nmendter = "/usr/coop/" + crabcop.dsdircop + "/rl/" +
                                      par_dsiduser.

                UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
                
                ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
                       aux_nmarqimp = aux_nmendter + ".ex"
                       aux_nmarqpdf = aux_nmendter + ".pdf".
            END.

        IF  RETURN-VALUE <> "OK" THEN
            DO:
                FIND FIRST tt-erro NO-ERROR.

                IF  NOT AVAIL tt-erro THEN
                    IF  aux_cdcritic <> 0 THEN
                        DO:  
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                            
                            UNIX SILENT VALUE
                                ("echo " + STRING(TIME,"HH:MM:SS") + " - "  +
                                  par_cdprogra + "' --> '" + aux_dscritic   +
                                  " CRED-USUARI-11-MAIORESCHQ-001 "         +
                                  " >> /usr/coop/" + TRIM(crabcop.dsdircop) +
                                  "/log/proc_batch.log").
                        END.

                LEAVE Imprime.    
            END.

        RUN busca_informacoes_relatorio_custodia
            ( INPUT par_cdcooper,
              INPUT par_cdagencx,
              INPUT par_cdprogra,
              INPUT par_dtmvtini,
              INPUT par_dtmvtfim,
             OUTPUT aux_cdcritic,
             OUTPUT TABLE tt-relat-custod,
             OUTPUT TABLE crawlot,
             OUTPUT TABLE crabcst,
             OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Imprime.

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

        /* Cdempres = 11 , Relatorio 233 em 132 colunas */
        { sistema/generico/includes/cabrel.i "11" "233" "132" }

        FOR EACH tt-relat-custod:

            DISPLAY STREAM str_1 
                    rel_dtmvtini 
                    rel_dtmvtfim 
                    tt-relat-custod.dsdsaldo  
                    WITH FRAME f_cab_c.
        
            ASSIGN pac_qtdlotes = 0
                   pac_qtchqcop = 0 
                   pac_vlchqcop = 0
                   pac_qtcheque = 0 
                   pac_vlcheque = 0
                   pac_qtchqtot = 0 
                   pac_vlchqtot = 0.
                
            IF  par_cdcooper = 4 THEN
                RUN proc_lista_4_custod
                    (INPUT par_dtmvtini,
                     INPUT par_dtmvtfim,
                     INPUT par_flgrelat).
            ELSE
                RUN proc_lista_custod
                    (INPUT par_dtmvtini,
                     INPUT par_dtmvtfim,
                     INPUT par_flgrelat).

            IF  LINE-COUNTER(str_1) > 80  THEN
                DO:
                    PAGE STREAM str_1.

                    DISPLAY STREAM str_1 
                            rel_dtmvtini 
                            rel_dtmvtfim 
                            tt-relat-custod.dsdsaldo 
                            WITH FRAME f_cab_c.
                END.

            DISPLAY STREAM str_1 aux_geralchq WITH FRAME f_totgeral.

            DISPLAY STREAM str_1
                    SKIP(5)
                    "____________________________________" AT 97 SKIP
                    "  CADASTRO E VISTO DO FUNCIONARIO   " AT 97
                    WITH NO-LABELS NO-BOX WIDTH 132 FRAME f_visto.

            ASSIGN aux_geralchq = 0.
            
            PAGE STREAM str_1.

        END.  /*  Fim FOR EACH tt-relat-custod:  */

        OUTPUT STREAM str_1 CLOSE.

        IF  par_nmdopcao THEN
            DO:
                UNIX SILENT VALUE("cp " + aux_nmarqimp + " " + aux_nmarqimp + 
                                  "_copy").

                UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + "_copy" +
                                  ' | tr -d "\032" > ' + aux_nmarqimp + 
                                  " 2>/dev/null").

                UNIX SILENT VALUE("rm " + aux_nmarqimp + "_copy").

                ASSIGN aux_msgretur = "Arquivo gerado com sucesso no " +
                                      "diretorio: " + aux_nmarqimp.

                ASSIGN aux_returnvl = "OK".

                LEAVE Imprime.

            END.
        
        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
                IF  NOT VALID-HANDLE(h-b1wgen0024) THEN
                    RUN sistema/generico/procedures/b1wgen0024.p
                        PERSISTENT SET h-b1wgen0024.

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
                    LEAVE Imprime.
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Imprime.

    END. /*Imprime*/

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0 OR
        TEMP-TABLE tt-erro:HAS-RECORDS
        THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            FIND FIRST tt-erro NO-LOCK NO-ERROR.

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
    
    RETURN aux_returnvl.

END PROCEDURE. /* gera-lotes-custodia */

PROCEDURE gera-custodia-cheques:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcusini AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcusfim AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inresgat AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.

    DEF  INPUT PARAM TABLE FOR tt-crapass.

    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.
    
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabcop FOR crapcop.

    DEF VAR tot_qtcheque AS INTE                                    NO-UNDO.
    DEF VAR tot_vlcheque AS DECI                                    NO-UNDO.

    FORM tt-crapcst.dtmvtolt AT  1 LABEL "Recebido"   FORMAT "99/99/9999" 
         tt-crapcst.dtlibera AT 12 LABEL "Liberar em" FORMAT "99/99/9999"
         tt-crapcst.cdbanchq AT 23 LABEL "Bco"        FORMAT "zz9"
         tt-crapcst.cdagechq AT 27 LABEL "Ag."        FORMAT "zzz9"
         tt-crapcst.nrctachq AT 32 LABEL "Conta"      FORMAT "zzz,zzz,zzz,9"
         tt-crapcst.nrcherel AT 46 LABEL "Cheque"     FORMAT "zzz,zzz,9"
         tt-crapcst.vlcheque AT 56 LABEL "Valor"      FORMAT "zzz,zzz,zz9.99"
         tt-crapcst.dtdevolu AT 71 LABEL "Resg/Desc"  FORMAT "99/99/9999"
         WITH NO-BOX NO-LABELS DOWN FRAME f_lanctos.
    
    FORM par_nrdconta        AT  1 LABEL "Conta/dv" FORMAT "zzzz,zzz,9"
         tt-crapass.nmprimtl AT 22 LABEL "Titular"  FORMAT "x(40)"
         SKIP(1)
         WITH NO-BOX NO-LABELS SIDE-LABELS FRAME f_custodia.

    EMPTY TEMP-TABLE tt-erro.

    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        
        FOR FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crabcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        ASSIGN aux_nmendter = "/usr/coop/" + crabcop.dsdircop + "/rl/" +
                              par_dsiduser.

        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        FIND tt-crapass NO-ERROR.

        IF  NOT AVAIL tt-crapass THEN
            LEAVE Imprime.

        RUN busca_cheques_em_custodia
            ( INPUT par_cdcooper,
              INPUT par_nrdconta,
              INPUT par_inresgat,
              INPUT par_dtmvtolt,
              INPUT par_dtcusini,
              INPUT par_dtcusfim,                                       
             OUTPUT TABLE tt-crapcst,
             OUTPUT TABLE tt-erro).

        MESSAGE RETURN-VALUE.

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Imprime.

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

        PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
        PUT STREAM str_1 CONTROL "\0330\033x0"      NULL.

        { sistema/generico/includes/b1cabrel080.i "11" "261" }

        DISPLAY STREAM str_1 par_nrdconta
            tt-crapass.nmprimtl WITH FRAME f_custodia.

        FOR EACH tt-crapcst USE-INDEX crapcst2:

            IF  tt-crapcst.dtdevolu = ?   THEN
                ASSIGN tot_qtcheque = tot_qtcheque + 1
                       tot_vlcheque = tot_vlcheque + tt-crapcst.vlcheque.

            DISPLAY STREAM str_1
                    tt-crapcst.dtmvtolt   tt-crapcst.dtlibera  
                    tt-crapcst.cdbanchq   tt-crapcst.cdagechq
                    tt-crapcst.nrctachq   tt-crapcst.nrcherel
                    tt-crapcst.vlcheque   tt-crapcst.dtdevolu
                    WITH FRAME f_lanctos.
        
            DOWN STREAM str_1 WITH FRAME f_lanctos.

            IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                DO:
                    PAGE STREAM str_1.

                    DISPLAY STREAM str_1 par_nrdconta
                        tt-crapass.nmprimtl WITH FRAME f_custodia.

                END.

        END.  /*  Fim do FOR EACH  */

        IF  tot_qtcheque > 0   THEN
            DISPLAY STREAM str_1
                    SKIP(1)
                    "TOTAIS ===>  "
                    tot_qtcheque FORMAT "zzz,zz9" "cheque(s)"
                    tot_vlcheque FORMAT "zzz,zzz,zz9.99" AT 56
                    WITH NO-BOX NO-LABELS FRAME f_total.
        ELSE
            DISPLAY STREAM str_1
                    "NAO HA CHEQUES EM CUSTODIA!"
                    WITH NO-BOX FRAME f_sem_cheque.

        OUTPUT STREAM str_1 CLOSE.
        
        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
                IF  NOT VALID-HANDLE(h-b1wgen0024) THEN
                    RUN sistema/generico/procedures/b1wgen0024.p
                        PERSISTENT SET h-b1wgen0024.

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

        ASSIGN aux_returnvl = "OK".

        LEAVE Imprime.

    END. /*Imprime*/

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0 OR
        TEMP-TABLE tt-erro:HAS-RECORDS
        THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            FIND FIRST tt-erro NO-LOCK NO-ERROR.

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
    
    RETURN aux_returnvl.

END PROCEDURE. /* gera-custodia-cheques */

PROCEDURE gera-conferencia-custodia:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM aux_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabcop FOR crapcop.

    DEF VAR aux_containi AS INTE                                    NO-UNDO.
    DEF VAR aux_contafim AS INTE                                    NO-UNDO.
    DEF VAR tot_vlchqcop AS DECI      FORMAT "zzzz,zzz,zz9.99"      NO-UNDO.
    DEF VAR tot_vlchqtot AS DECI      FORMAT "zzzz,zzz,zz9.99"      NO-UNDO.

    FORM HEADER "Periodo Solicitado: De" par_dtiniper FORMAT "99/99/9999"
         "Ate" par_dtfimper FORMAT "99/99/9999" SKIP(2)
         "PA    Conta/Dv Titular" SPACE(22) "Digitado em Liberacao  Banco"
         "Comp. Agencia            Conta  Cheque          Valor"  SKIP
         "------------------------------------------- ----------------------" 
         "-----------------------------------------------------------" SKIP 
         WITH WIDTH 132 NO-BOX NO-LABELS FRAME f_cabecalho NO-ATTR-SPACE PAGE-TOP.

    FORM tt-crapcst.cdagenci 
         tt-crapcst.nrdconta 
         tt-crapcst.nmprimtl FORMAT "x(28)"
         tt-crapcst.dtmvtolt SPACE(2)
         tt-crapcst.dtlibera 
         tt-crapcst.cdbanchq  
         tt-crapcst.cdcmpchq SPACE(3)
         tt-crapcst.cdagechq 
         tt-crapcst.nrctachq  /* Mirtes */
         tt-crapcst.nrcheque 
         tt-crapcst.vlcheque  
         WITH DOWN WIDTH 132 NO-BOX NO-LABELS FRAME f_custodia.

    FORM SKIP(1)
         "TOTAL" AT 106 tot_vlchqcop
         SKIP(1)
         WITH WIDTH 132 NO-BOX NO-LABELS FRAME f_total_coop.
         
    FORM SKIP(1)
         "TOTAL GERAL" AT 100 tot_vlchqtot
         WITH WIDTH 132 NO-BOX NO-LABELS FRAME f_total_geral.
            
    ASSIGN aux_containi = par_nrdconta
           aux_contafim = IF par_nrdconta = 0 THEN 999999999
                             ELSE par_nrdconta.

    EMPTY TEMP-TABLE tt-erro.

    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:

        FOR FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crabcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        ASSIGN aux_nmendter = "/usr/coop/" + crabcop.dsdircop + "/rl/" +
                              par_dsiduser.

        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").

        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        RUN conferencia_cheques_em_custodia
            ( INPUT par_cdcooper,
              INPUT par_dtiniper,
              INPUT par_dtfimper,
              INPUT aux_containi,
              INPUT aux_contafim,
              INPUT par_cdagencx,
             OUTPUT TABLE tt-erro,
             OUTPUT TABLE tt-crapcst) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
    		DO:
                MESSAGE ERROR-STATUS:GET-MESSAGE(1)
                    VIEW-AS ALERT-BOX INFO BUTTONS OK.
                
    		END.

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Imprime.

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

        PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
        PUT STREAM str_1 CONTROL "\0330\033x0\017"  NULL.
        
        /* Cdempres = 11 , Relatorio 289 em 132 colunas */
        { sistema/generico/includes/cabrel.i "11" "289" "132" }

        VIEW STREAM str_1 FRAME f_cabecalho.

        FOR EACH tt-crapcst USE-INDEX crapcst3 BREAK BY tt-crapcst.nrdconta 
                                                     BY tt-crapcst.dtlibera:

            IF  FIRST-OF(tt-crapcst.dtlibera) THEN
                ASSIGN tot_vlchqcop = 0.

            ASSIGN tot_vlchqcop = tot_vlchqcop + tt-crapcst.vlcheque.

            IF  LINE-COUNTER(str_1) > 80 THEN
                PAGE STREAM str_1.

            DISPLAY STREAM str_1 
                    tt-crapcst.cdagenci   tt-crapcst.nrdconta 
                    tt-crapcst.nmprimtl   tt-crapcst.dtmvtolt
                    tt-crapcst.dtlibera   tt-crapcst.cdbanchq
                    tt-crapcst.cdcmpchq   tt-crapcst.cdagechq 
                    tt-crapcst.nrctachq   tt-crapcst.nrcheque 
                    tt-crapcst.vlcheque  
                    WITH FRAME f_custodia.

            DOWN STREAM str_1 WITH FRAME f_custodia.

            IF  LAST-OF(tt-crapcst.dtlibera)   THEN /* ultimo por data */
                DO:
                    ASSIGN tot_vlchqtot = tot_vlchqtot + tot_vlchqcop.
                     
                    DISPLAY STREAM str_1 
                             tot_vlchqcop   
                             WITH FRAME f_total_coop.
                     
                    DOWN STREAM str_1 WITH FRAME f_total_coop.
                END.   

            IF  LAST(tt-crapcst.dtlibera)   THEN /* ultimo da selecao */
                DO:
                    DISPLAY STREAM str_1
                            tot_vlchqtot
                            WITH FRAME f_total_geral.

                    DOWN STREAM str_1 WITH FRAME f_total_geral.
                END.
        
        END. /* FOR EACH tt-crapcst */

        PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
        PUT STREAM str_1 CONTROL "\0330\033x0"      NULL.

        OUTPUT STREAM str_1 CLOSE.
        
        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
                IF  NOT VALID-HANDLE(h-b1wgen0024) THEN
                    RUN sistema/generico/procedures/b1wgen0024.p
                        PERSISTENT SET h-b1wgen0024.

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

        ASSIGN aux_returnvl = "OK".

        LEAVE Imprime.

    END. /*Imprime*/

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0 OR
        TEMP-TABLE tt-erro:HAS-RECORDS
        THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            FIND FIRST tt-erro NO-LOCK NO-ERROR.

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
    
    RETURN aux_returnvl.

END PROCEDURE. /* gera-conferencia-custodia */

PROCEDURE gera-cheques-tranferidos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.

    DEF  INPUT PARAM TABLE FOR tt-crapbdc.
    
    DEF OUTPUT PARAM aux_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabcop FOR crapcop.

    DEF   VAR rel_dspesqui AS CHAR                                  NO-UNDO.

    DEF   VAR tot_qtcheque AS INTE                                  NO-UNDO.
    DEF   VAR tot_vlcheque AS DECI                                  NO-UNDO.
    
    DEF   VAR ger_qtcheque AS INTE                                  NO-UNDO.
    DEF   VAR ger_vlcheque AS DECI                                  NO-UNDO.

    FORM "CUSTODIA DO DIA" 
         tt-crapbdc.dtlibera FORMAT "99/99/9999" NO-LABEL
    
         "TRANSFERIDA PARA DESCONTO - BORDERO" 
         tt-crapbdc.nrborder NO-LABEL FORMAT "z,zzz,zz9"
         SKIP(1)
         tt-crapbdc.nrdconta LABEL "CONTA/DV" "-"
         tt-crapbdc.nmprimtl NO-LABEL
         SKIP(2)
         WITH SIDE-LABELS NO-BOX WIDTH 80 FRAME f_conta.
    
    FORM rel_dspesqui AT 10 LABEL "PROTOCOLO UTILIZADO" FORMAT "x(30)"
         tot_qtcheque AT 41 LABEL "QTD."                FORMAT "zzz,zz9"
         tot_vlcheque AT 51 LABEL "VALOR"               FORMAT "zzz,zzz,zz9.99"
         WITH NO-BOX WIDTH 80 DOWN FRAME f_protocolo.
     
    FORM SKIP(1)
         "TOTAL GERAL ===>" AT 23
         ger_qtcheque AT 41 FORMAT "zzz,zz9"
         ger_vlcheque AT 51 FORMAT "zzz,zzz,zz9.99"
         WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_total_geral.

    EMPTY TEMP-TABLE tt-erro.

    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        
        FOR FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crabcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        ASSIGN aux_nmendter = "/usr/coop/" + crabcop.dsdircop + "/rl/" +
                              par_dsiduser.

        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        RUN busca_relatorio_desconto_custodia
            ( INPUT par_cdcooper,
              INPUT par_cdagenci,
              INPUT par_nrdcaixa,
       INPUT-OUTPUT TABLE tt-crapbdc,
             OUTPUT TABLE tt-crapcst,
             OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Imprime.

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

        FOR EACH tt-crapbdc:

            PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
            PUT STREAM str_1 CONTROL "\0330\033x0"      NULL.

            { sistema/generico/includes/b1cabrel080.i "11" "315" }

            DISPLAY STREAM str_1 
                    tt-crapbdc.dtlibera   tt-crapbdc.nrborder
                    tt-crapbdc.nrdconta   tt-crapbdc.nmprimtl 
                    WITH FRAME f_conta.

            FOR EACH tt-crapcst WHERE 
                     tt-crapcst.cdcooper = tt-crapbdc.cdcooper   AND
                     tt-crapcst.nrborder = tt-crapbdc.nrborder   
                     BREAK BY tt-crapcst.dtmvtolt
                          BY tt-crapcst.cdagenci
                          BY tt-crapcst.cdbccxlt 
                          BY tt-crapcst.nrdolote:

                ASSIGN tot_qtcheque = tot_qtcheque + 1
                       tot_vlcheque = tot_vlcheque + tt-crapcst.vlcheque
                     
                       ger_qtcheque = ger_qtcheque + 1
                       ger_vlcheque = ger_vlcheque + tt-crapcst.vlcheque.

                IF  LAST-OF(tt-crapcst.dtmvtolt)   OR
                    LAST-OF(tt-crapcst.cdagenci)   OR
                    LAST-OF(tt-crapcst.cdbccxlt)   OR
                    LAST-OF(tt-crapcst.nrdolote)   THEN
                    DO:
                        IF  LINE-COUNTER(str_1) > (PAGE-SIZE(str_1) - 2) THEN
                            DO:
                                PAGE STREAM str_1.

                                DISPLAY STREAM str_1 
                                         tt-crapbdc.dtlibera
                                         tt-crapbdc.nrborder
                                         tt-crapbdc.nrdconta
                                         tt-crapbdc.nmprimtl 
                                         WITH FRAME f_conta.
                            END.

                        ASSIGN rel_dspesqui = 
                               STRING(tt-crapcst.dtmvtolt,"99/99/9999") + "-" +
                               STRING(tt-crapcst.cdagenci,"999")        + "-" +
                               STRING(tt-crapcst.cdbccxlt,"999")        + "-" +
                               STRING(tt-crapcst.nrdolote,"999999").
                         
                        IF  LINE-COUNTER(str_1) > (PAGE-SIZE(str_1) - 2) THEN
                            DO:
                                PAGE STREAM str_1.

                                DISPLAY STREAM str_1 
                                        tt-crapbdc.dtlibera
                                        tt-crapbdc.nrborder
                                        tt-crapbdc.nrdconta
                                        tt-crapbdc.nmprimtl 
                                        WITH FRAME f_conta.
                            END.

                        DISPLAY STREAM str_1   
                             rel_dspesqui tot_qtcheque  tot_vlcheque  
                             WITH FRAME f_protocolo.

                        DOWN 2 STREAM str_1 WITH FRAME f_protocolo.

                        ASSIGN tot_qtcheque = 0
                               tot_vlcheque = 0.

                    END. /* IF  LAST-OF(tt-crapcst.dtmvtolt) */

            END.  /*  Fim do FOR EACH -- Leitura da custodia  */

            IF  LINE-COUNTER(str_1) > (PAGE-SIZE(str_1) - 10) THEN
                DO:
                    PAGE STREAM str_1.
                 
                    DISPLAY STREAM str_1 
                            tt-crapbdc.dtlibera   tt-crapbdc.nrborder  
                            tt-crapbdc.nrdconta   tt-crapbdc.nmprimtl 
                            WITH FRAME f_conta.
                END.

            DISPLAY STREAM str_1   
                ger_qtcheque  ger_vlcheque WITH FRAME f_total_geral.

            DISPLAY STREAM str_1
                   SKIP(5)
                   "____________________________________" AT 29 SKIP
                   "  CADASTRO E VISTO DO FUNCIONARIO   " AT 29
                   WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_visto.

            ASSIGN ger_qtcheque = 0
                   ger_vlcheque = 0.

            PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
            PUT STREAM str_1 CONTROL "\0330\033x0"      NULL.

            PAGE STREAM str_1.

        END.  /*  Fim do DO .. TO  */

        OUTPUT STREAM str_1 CLOSE.
        
        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
                IF  NOT VALID-HANDLE(h-b1wgen0024) THEN
                    RUN sistema/generico/procedures/b1wgen0024.p
                        PERSISTENT SET h-b1wgen0024.

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

        ASSIGN aux_returnvl = "OK".

        LEAVE Imprime.

    END. /*Imprime*/

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0 OR
        TEMP-TABLE tt-erro:HAS-RECORDS
        THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            FIND FIRST tt-erro NO-LOCK NO-ERROR.

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
    
    RETURN aux_returnvl.

END PROCEDURE. /* gera-cheques-tranferidos */

/*........................... PROCEDURES INTERNAS ..........................*/

PROCEDURE busca_lotes_descto PRIVATE:
    /************************************************************************
        Objetivo: Buscar informacoes para montagem do relatorio de lotes
                  (Opcao "R" da tela DESCTO)
    ************************************************************************/
    DEF INPUT  PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                       NO-UNDO.
    DEF INPUT  PARAM par_cdprogra AS CHAR                       NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                       NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                       NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-relat-lotes.
    DEF OUTPUT PARAM TABLE FOR crawlot.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-relat-lotes.
    EMPTY TEMP-TABLE crawlot.
    
    /* Busca valor dos cheques maiores */
    RUN busca_maiores_cheques_craptab (INPUT  par_cdcooper,
                                       INPUT  par_cdprogra,
                                       OUTPUT tab_vlchqmai,
                                       OUTPUT par_cdcritic,
                                       OUTPUT TABLE tt-erro).

    IF   RETURN-VALUE = "NOK"   THEN
         RETURN "NOK".
    /***********************************/

    CREATE tt-relat-lotes.
    ASSIGN tt-relat-lotes.dsdsaldo = IF par_cdagenci > 0 THEN 
                         "    ** DO PA " + STRING(par_cdagenci,"zz9") + " **"
                                   ELSE "      ** GERAL **"
           tt-relat-lotes.vlchmatb = tab_vlchqmai.                        

    FOR EACH crapbdc WHERE 
             crapbdc.cdcooper = par_cdcooper       AND
             crapbdc.dtlibbdc = par_dtmvtolt       NO-LOCK,
        EACH crapcdb WHERE 
             crapcdb.cdcooper = crapbdc.cdcooper   AND
             crapcdb.nrdconta = crapbdc.nrdconta   AND
             crapcdb.nrborder = crapbdc.nrborder   NO-LOCK 
        BREAK BY crapcdb.dtmvtolt
              BY crapcdb.cdagenci
              BY crapcdb.cdbccxlt
              BY crapcdb.nrdolote:

        IF   par_cdagenci      > 0              AND
             crapcdb.cdagenci <> par_cdagenci   THEN
             NEXT.

        FIND crawlot WHERE 
             crawlot.dtmvtolt = crapcdb.dtmvtolt   AND
             crawlot.cdagenci = crapcdb.cdagenci   AND
             crawlot.nrdolote = crapcdb.nrdolote   NO-ERROR.

        IF   NOT AVAILABLE crawlot   THEN
             DO:
                 CREATE crawlot.
                 ASSIGN crawlot.dtmvtolt = crapcdb.dtmvtolt
                        crawlot.cdagenci = crapcdb.cdagenci
                        crawlot.nrdconta = crapcdb.nrdconta
                        crawlot.nrdolote = crapcdb.nrdolote
                        crawlot.nrborder = crapcdb.nrborder.

                 FIND crapope WHERE 
                      crapope.cdcooper = crapcdb.cdcooper  AND
                      crapope.cdoperad = crapcdb.cdoperad  NO-LOCK NO-ERROR.

                 IF   NOT AVAILABLE crapope   THEN
                      ASSIGN crawlot.nmoperad = crapcdb.cdoperad.
                 ELSE
                      ASSIGN crawlot.nmoperad = ENTRY(1,crapope.nmoperad," ").
             END.

        ASSIGN crawlot.qtchqtot = crawlot.qtchqtot + 1
               crawlot.vlchqtot = crawlot.vlchqtot + crapcdb.vlcheque.

        IF   crapcdb.inchqcop = 1   THEN
             ASSIGN crawlot.vlchqcop = crawlot.vlchqcop + crapcdb.vlcheque
                    crawlot.qtchqcop = crawlot.qtchqcop + 1.
        ELSE
             DO:
                 ASSIGN crawlot.vlcheque = crawlot.vlcheque + crapcdb.vlcheque
                        crawlot.qtcheque = crawlot.qtcheque + 1.
             END.
 
    END. /* Fim do FOR EACH  crapbdc --  Leitura dos lotes do dia  */

    /* Gravacao dos totais do relatorio */
    FOR EACH crawlot:
        ASSIGN 
          tt-relat-lotes.qtdlotes = tt-relat-lotes.qtdlotes + 1
          tt-relat-lotes.qtchqcop = tt-relat-lotes.qtchqcop + crawlot.qtchqcop
          tt-relat-lotes.qtcheque = tt-relat-lotes.qtcheque + crawlot.qtcheque
          tt-relat-lotes.qtchqtot = tt-relat-lotes.qtchqtot + crawlot.qtchqtot
           
          tt-relat-lotes.vlchqcop = tt-relat-lotes.vlchqcop + crawlot.vlchqcop 
          tt-relat-lotes.vlcheque = tt-relat-lotes.vlcheque + crawlot.vlcheque 
          tt-relat-lotes.vlchqtot = tt-relat-lotes.vlchqtot + crawlot.vlchqtot.
    END.

    RETURN "OK".

END PROCEDURE. /* busca_lotes_descto */

PROCEDURE busca_maiores_cheques_craptab PRIVATE:
    /************************************************************************
        Objetivo: Buscar informacoes dos maiores cheques na tabela craptab
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER par_vlchmatb AS DECIMAL     NO-UNDO.
    DEFINE OUTPUT PARAMETER par_criticas AS INT         NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "USUARI"      AND
                       craptab.cdempres = 11            AND
                       craptab.cdacesso = "MAIORESCHQ"  AND
                       craptab.tpregist = 1             NO-LOCK NO-ERROR.
    IF   NOT AVAILABLE craptab   THEN
         DO:
             par_criticas = 55.

             RETURN "NOK".

         END.

    ASSIGN par_vlchmatb = DECI(SUBSTR(craptab.dstextab,1,15)).

    RETURN "OK".

END PROCEDURE. /* busca_maiores_cheques_craptab */

PROCEDURE proc_lista PRIVATE:

    FOR EACH crawlot BREAK BY crawlot.cdagenci
                              BY crawlot.dtmvtolt
                                 BY crawlot.nrdolote:
        RUN gera-lista
            (INPUT FIRST-OF(crawlot.cdagenci),
             INPUT LAST-OF(crawlot.cdagenci)).

    END.  /* FOR EACH crawlot */

    RETURN.

END PROCEDURE. /* proc_lista */

PROCEDURE proc_lista_4 PRIVATE:

    FOR EACH crawlot BREAK BY crawlot.cdagenci
                              BY crawlot.dtmvtolt
                                 BY crawlot.nrdconta:

        RUN gera-lista
            (INPUT FIRST-OF(crawlot.cdagenci),
             INPUT LAST-OF(crawlot.cdagenci)).

    END.  /* FOR EACH crawlot */

    RETURN.

END PROCEDURE. /* proc_lista_4 */

PROCEDURE gera-lista PRIVATE:

    DEF INPUT PARAM par_firstofl AS LOGI        NO-UNDO.
    DEF INPUT PARAM par_lastoflt AS LOGI        NO-UNDO.
    
    IF  par_firstofl THEN
        DO:
            IF  LINE-COUNTER(str_1) > 80 THEN
                DO:
                    PAGE STREAM str_1.

                    DISPLAY STREAM str_1 
                            rel_dtmvtolt tt-relat-lotes.dsdsaldo WITH FRAME f_cab.
                END.
        END.

    CLEAR FRAME f_lotes.

    DISPLAY STREAM str_1  
           crawlot.dtmvtolt
           crawlot.cdagenci  
           crawlot.nrdconta  
           crawlot.nrborder
           crawlot.nrdolote 
           crawlot.qtchqcop  WHEN crawlot.qtchqcop > 0
           crawlot.vlchqcop  WHEN crawlot.vlchqcop > 0 
           crawlot.qtcheque  WHEN crawlot.qtcheque > 0
           crawlot.vlcheque  WHEN crawlot.vlcheque > 0
           crawlot.qtchqtot 
           crawlot.vlchqtot 
           crawlot.nmoperad
           WITH FRAME f_lotes.

    ASSIGN pac_qtdlotes = pac_qtdlotes + 1
           pac_qtchqcop = pac_qtchqcop + crawlot.qtchqcop
           pac_qtcheque = pac_qtcheque + crawlot.qtcheque
           pac_qtchqtot = pac_qtchqtot + crawlot.qtchqtot
           
           pac_vlchqcop = pac_vlchqcop + crawlot.vlchqcop 
           pac_vlcheque = pac_vlcheque + crawlot.vlcheque 
           pac_vlchqtot = pac_vlchqtot + crawlot.vlchqtot.

    DOWN STREAM str_1 WITH FRAME f_lotes.                      

    IF  NOT par_lastoflt THEN
        RETURN "OK".

    CLEAR FRAME f_pac.

    DISPLAY STREAM str_1 
            pac_qtdlotes  
            pac_qtchqcop WHEN pac_qtchqcop > 0
            pac_vlchqcop WHEN pac_vlchqcop > 0
            pac_qtcheque WHEN pac_qtcheque > 0
            pac_vlcheque WHEN pac_vlcheque > 0
            pac_qtchqtot  
            pac_vlchqtot
            pac_dsdtraco
            WITH FRAME f_pac.

    IF  LINE-COUNTER(str_1) > 80  THEN
        DO:
            PAGE STREAM str_1.
                   
            DISPLAY STREAM str_1 
                    rel_dtmvtolt tt-relat-lotes.dsdsaldo WITH FRAME f_cab.
        END.

    ASSIGN pac_qtdlotes = 0
           pac_qtchqcop = 0 
           pac_qtcheque = 0 
           pac_qtchqtot = 0 
           
           pac_vlchqcop = 0
           pac_vlcheque = 0 
           pac_vlchqtot = 0.

    RETURN "OK".

END PROCEDURE. /* gera-lista */

PROCEDURE proc_lista_custod PRIVATE:

    DEF INPUT PARAM par_dtmvtini AS DATE        NO-UNDO.
    DEF INPUT PARAM par_dtmvtfim AS DATE        NO-UNDO.
    DEF INPUT PARAM par_flgrelat AS LOGI        NO-UNDO.

    FOR EACH crawlot WHERE
             crawlot.indrelat = tt-relat-custod.indrelat
             BREAK BY crawlot.cdagenci
                   BY crawlot.nrdolote:
        RUN gera-lista-custod
            (INPUT par_dtmvtini,
             INPUT par_dtmvtfim,
             INPUT FIRST-OF(crawlot.cdagenci),
             INPUT LAST-OF(crawlot.cdagenci),
             INPUT par_flgrelat ).

    END.  /* FOR EACH crawlot */

    RETURN.

END PROCEDURE. /* proc_lista_custod */

PROCEDURE proc_lista_4_custod PRIVATE:

    DEF INPUT PARAM par_dtmvtini AS DATE        NO-UNDO.
    DEF INPUT PARAM par_dtmvtfim AS DATE        NO-UNDO.
    DEF INPUT PARAM par_flgrelat AS LOGI        NO-UNDO.

    FOR EACH crawlot WHERE
             crawlot.indrelat = tt-relat-custod.indrelat
             BREAK BY crawlot.cdagenci
                   BY crawlot.nrdconta:

        RUN gera-lista-custod
            (INPUT par_dtmvtini,
             INPUT par_dtmvtfim,
             INPUT FIRST-OF(crawlot.cdagenci),
             INPUT LAST-OF(crawlot.cdagenci),
             INPUT par_flgrelat ).

    END.  /* FOR EACH crawlot */

    RETURN.

END PROCEDURE. /* proc_lista_4_custod */

PROCEDURE gera-lista-custod PRIVATE:

    DEF INPUT PARAM par_dtmvtini AS DATE        NO-UNDO.
    DEF INPUT PARAM par_dtmvtfim AS DATE        NO-UNDO.
    DEF INPUT PARAM par_firstofl AS LOGI        NO-UNDO.
    DEF INPUT PARAM par_lastoflt AS LOGI        NO-UNDO.
    DEF INPUT PARAM par_flgrelat AS LOGI        NO-UNDO.
    
    IF  par_firstofl THEN
        DO:
            IF  LINE-COUNTER(str_1) > 80  THEN
                DO:
                    PAGE STREAM str_1.

                    DISPLAY STREAM str_1 
                             rel_dtmvtini 
                             rel_dtmvtfim 
                             tt-relat-custod.dsdsaldo 
                             WITH FRAME f_cab_c.
                END.
        END.

    CLEAR FRAME f_lotes_c.

    DISPLAY STREAM str_1  
            crawlot.cdagenci  
            crawlot.nrdconta  
            crawlot.nrdolote 
            crawlot.qtchqcop  WHEN crawlot.qtchqcop > 0
            crawlot.vlchqcop  WHEN crawlot.vlchqcop > 0 
            crawlot.qtcheque  WHEN crawlot.qtcheque > 0
            crawlot.vlcheque  WHEN crawlot.vlcheque > 0
            crawlot.qtchqtot 
            crawlot.vlchqtot 
            crawlot.dtlibera 
            crawlot.nmoperad
            WITH FRAME f_lotes_c.

    IF  par_flgrelat THEN
        DO:
            IF  LINE-COUNTER(str_1) > 75  THEN
                PAGE STREAM str_1.

            DISPLAY STREAM str_1 WITH FRAME f_titulo.

            FOR EACH crabcst WHERE crabcst.indrelat = crawlot.indrelat AND
                                   crabcst.cdagenci = crawlot.cdagenci AND
                                   crabcst.nrdconta = crawlot.nrdconta AND
                                   crabcst.nrdolote = crawlot.nrdolote
                                   BREAK BY crabcst.nrdolote:
                
                DISPLAY STREAM str_1
                               crabcst.dtlibera
                               crabcst.cdcmpchq
                               crabcst.cdbanchq
                               crabcst.cdagechq
                               crabcst.nrctachq
                               crabcst.nrcheque 
                               crabcst.vlcheque 
                               crabcst.dsdocmc7 WITH FRAME f_detalhado.

                DOWN STREAM str_1 WITH FRAME f_detalhado.   
                
                IF  LAST-OF(crabcst.nrdolote) THEN
                    DOWN 2 STREAM str_1 WITH FRAME f_detalhado.

                IF  LINE-COUNTER(str_1) > 80 THEN
                    PAGE STREAM str_1.

            END. /* FOR EACH crabcst */

        END. /* IF  par_flgrelat */

    ASSIGN pac_qtdlotes = pac_qtdlotes + 1
           pac_qtchqcop = pac_qtchqcop + crawlot.qtchqcop
           pac_qtcheque = pac_qtcheque + crawlot.qtcheque 
           pac_qtchqtot = pac_qtchqtot + crawlot.qtchqtot
      
           pac_vlchqcop = pac_vlchqcop + crawlot.vlchqcop 
           pac_vlcheque = pac_vlcheque + crawlot.vlcheque 
           pac_vlchqtot = pac_vlchqtot + crawlot.vlchqtot.

    DOWN STREAM str_1 WITH FRAME f_lotes_c.

    IF  NOT par_lastoflt THEN
        RETURN "OK".

    CLEAR FRAME f_pac_c.

    IF  LINE-COUNTER(str_1) > 72  THEN
        PAGE STREAM str_1.

    DISPLAY STREAM str_1 
            pac_qtdlotes  
            pac_qtchqcop WHEN pac_qtchqcop > 0
            pac_vlchqcop WHEN pac_vlchqcop > 0
            pac_qtcheque WHEN pac_qtcheque > 0
            pac_vlcheque WHEN pac_vlcheque > 0
            pac_qtchqtot  
            pac_vlchqtot
            pac_dsdtraco
            WITH FRAME f_pac_c.

    ASSIGN aux_geralchq = aux_geralchq +  pac_vlchqtot.

    IF  LINE-COUNTER(str_1) > 80  THEN
        DO:
            PAGE STREAM str_1.
                   
            DISPLAY STREAM str_1 rel_dtmvtini 
                                 rel_dtmvtfim 
                                 tt-relat-custod.dsdsaldo 
                                 WITH FRAME f_cab_c.
        END.
   
   ASSIGN pac_qtdlotes = 0
          pac_qtchqcop = 0 
          pac_qtcheque = 0 
          pac_qtchqtot = 0 

          pac_vlchqcop = 0
          pac_vlcheque = 0 
          pac_vlchqtot = 0.

    RETURN "OK".

END PROCEDURE. /* gera-lista-custod */

PROCEDURE busca_cheques_descontados_conta PRIVATE:
    /************************************************************************
        Objetivo: Buscar cheques descontados por conta (Opcao "M" da tela 
                  DESCTO)
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_inresgat AS LOGICAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-crapcdb.

    EMPTY TEMP-TABLE tt-crapcdb.

    FOR EACH crapcdb WHERE crapcdb.cdcooper =  par_cdcooper AND
                           crapcdb.nrdconta =  par_nrdconta AND
                           crapcdb.dtlibera >  par_dtmvtolt AND
                           crapcdb.dtlibbdc <> ?            NO-LOCK:
    
        IF  NOT par_inresgat      AND
            crapcdb.dtdevolu <> ? THEN
            NEXT.

        CREATE tt-crapcdb.
        BUFFER-COPY crapcdb TO tt-crapcdb.
    
        ASSIGN tt-crapcdb.nrcherel = INT(STRING(crapcdb.nrcheque,"999999") +
                                         STRING(crapcdb.nrddigc3,"9")).
        
    END.  /*  Fim do FOR EACH  */

    RETURN "OK".

END PROCEDURE. /* busca_cheques_descontados_conta */

PROCEDURE busca_cheques_descontados_geral PRIVATE:
    /************************************************************************
        Objetivo: Buscar cheques descontados - geral (Opcao "M" da tela 
                  DESCTO)
      Parametros: par_cdctalis: Contas
                    - 1: Cooper; 2: Demais Associados; 3: Total Geral
                  par_vlsupinf: 
                    - 1: Qualquer Valor; 2: Inferiores; 3: Superiores
                  par_inchqcop:
                    - 1: Qualquer Cheque; 2: Outros Bancos; 3: Cooperativa
    ************************************************************************/
    DEF  INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                       NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                       NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                       NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                       NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                       NO-UNDO.
    DEF  INPUT PARAM par_cdctalis AS INTE                       NO-UNDO.
    DEF  INPUT PARAM par_vlsupinf AS INTE                       NO-UNDO.
    DEF  INPUT PARAM par_inchqcop AS INTE                       NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-crapcdb.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF OUTPUT PARAM par_dsrefere AS CHAR                       NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                       NO-UNDO.

    EMPTY TEMP-TABLE tt-crapcdb.

    RUN busca_maiores_cheques_craptab 
        ( INPUT  par_cdcooper,
          INPUT  par_cdprogra,
         OUTPUT aux_vlchqmai,
         OUTPUT par_cdcritic,
         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    IF  par_cdctalis < 1 OR par_cdctalis > 3 THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Valor invalido para Tipo de Contas".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    IF  par_vlsupinf < 1 OR par_vlsupinf > 3 THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Valor invalido para Valor de Cheque".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    IF  par_inchqcop < 1 OR par_inchqcop > 3 THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Valor invalido para Tipo de Cheque".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    CASE par_cdctalis:
        WHEN 1 THEN ASSIGN par_dsrefere = "SOMENTE COOPER, ".
        WHEN 2 THEN ASSIGN par_dsrefere = "SOMENTE ASSOCIADOS, ".
        WHEN 3 THEN ASSIGN par_dsrefere = "TODAS AS CONTAS, ".
    END CASE.

    CASE par_vlsupinf:
        WHEN 1 THEN ASSIGN par_dsrefere = par_dsrefere + "TODOS OS CHEQUES".
        WHEN 2 THEN ASSIGN par_dsrefere = par_dsrefere + "CHEQUES INFERIORES".
        WHEN 3 THEN ASSIGN par_dsrefere = par_dsrefere + "CHEQUES SUPERIORES".
    END CASE.

    CASE par_inchqcop:
        WHEN 1 THEN ASSIGN par_dsrefere = par_dsrefere + ".".
        WHEN 2 THEN ASSIGN par_dsrefere = par_dsrefere + " DE OUTROS BANCOS.".
        WHEN 3 THEN ASSIGN par_dsrefere = par_dsrefere + " DA COOPERATIVA.".
    END CASE.

    FOR EACH crapcdb USE-INDEX crapcdb6
       WHERE crapcdb.cdcooper =  par_cdcooper AND
        (crapcdb.dtlibera >= par_dtiniper   AND 
         crapcdb.dtlibera <= par_dtfimper)  AND 
         crapcdb.dtlibbdc <> ?              AND   
         crapcdb.dtdevolu = ?               NO-LOCK:

        IF  par_cdctalis = 1 AND crapcdb.nrdconta <> 85448 THEN NEXT.
        IF  par_cdctalis = 2 AND crapcdb.nrdconta  = 85448 THEN NEXT.

        IF  par_vlsupinf = 2 AND crapcdb.vlcheque >= aux_vlchqmai THEN NEXT.
        IF  par_vlsupinf = 3 AND crapcdb.vlcheque  < aux_vlchqmai THEN NEXT.

        IF  par_inchqcop = 2 AND crapcdb.inchqcop <> 0 THEN NEXT.
        IF  par_inchqcop = 3 AND crapcdb.inchqcop  = 0 THEN NEXT.

        CREATE tt-crapcdb.
        BUFFER-COPY crapcdb TO tt-crapcdb.

    END.  /*  Fim do FOR EACH -- crapcdb  */                       

    RETURN "OK".

END PROCEDURE. /* busca_cheques_descontados_geral */

PROCEDURE conferencia_cheques_descontados PRIVATE:
    /************************************************************************
        Objetivo: Buscar informacoes dos cheques descontados pelo bordero
    ************************************************************************/
    DEF  INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                       NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                       NO-UNDO.
    DEF  INPUT PARAM par_containi AS INTE                       NO-UNDO.
    DEF  INPUT PARAM par_contafim AS INTE                       NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                       NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-crapcdb.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapcdb.

    FOR EACH crapcdb USE-INDEX crapcdb3 WHERE 
             crapcdb.cdcooper  = par_cdcooper  AND
             crapcdb.dtlibera >= par_dtiniper  AND 
             crapcdb.dtlibera <= par_dtfimper  AND 
             crapcdb.dtdevolu = ?              AND 
            (crapcdb.nrdconta >= par_containi  AND
             crapcdb.nrdconta <= par_contafim) AND
             crapcdb.dtlibbdc <> ?             NO-LOCK:

        /* Quando informado PAC, filtra */
        IF par_cdagenci <> 0 AND crapcdb.cdagenci <> par_cdagenci THEN NEXT.
        
        CREATE tt-crapcdb.
        BUFFER-COPY crapcdb TO tt-crapcdb.

        FIND crapass WHERE 
             crapass.cdcooper = crapcdb.cdcooper  AND
             crapass.nrdconta = crapcdb.nrdconta  NO-LOCK NO-ERROR.
        IF   AVAIL crapass   THEN
             ASSIGN tt-crapcdb.nmprimtl = crapass.nmprimtl.

    END. /* FOR EACH crapcdb */

    RETURN "OK".
    
END PROCEDURE. /* conferencia_cheques_descontados */

PROCEDURE busca_lotes_custodia PRIVATE:
    /************************************************************************
        Objetivo  : Buscar informacoes para montagem do relatorio de lotes de
                    custodia (Opcao "F" da tela CUSTOD - Conta 85448)
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtlibera AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-relat-lotes.
    DEFINE OUTPUT PARAMETER TABLE FOR crawlot.

    EMPTY TEMP-TABLE tt-relat-lotes.
    EMPTY TEMP-TABLE crawlot.

    DEF VAR h-b1wgen0018 AS HANDLE                      NO-UNDO.
    DEF VAR aux_dtmvtolt AS DATE                        NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen0018) THEN
        RUN sistema/generico/procedures/b1wgen0018.p 
            PERSISTENT SET h-b1wgen0018.

    RUN pi_calcula_datas_liberacao IN h-b1wgen0018
                                 ( INPUT par_cdcooper,
                                   INPUT par_dtlibera,
                                  OUTPUT aux_dtliber1,
                                  OUTPUT aux_dtliber2).

    IF  VALID-HANDLE(h-b1wgen0018) THEN
        DELETE PROCEDURE h-b1wgen0018.

    CREATE tt-relat-lotes.

    FOR EACH crapage WHERE crapage.cdcooper = par_cdcooper NO-LOCK:
 
        DO aux_dtmvtolt = aux_dtliber1 + 1 TO par_dtlibera:
 
            FOR EACH craplot WHERE
                     craplot.cdcooper = par_cdcooper AND
                     craplot.cdagenci = crapage.cdagenci AND
                     craplot.dtmvtopg = aux_dtmvtolt AND
                     craplot.cdbccxlt = 600 AND
                     craplot.tplotmov = 19 NO-LOCK:

                FIND FIRST crapcst WHERE crapcst.cdcooper = craplot.cdcooper AND
                                         crapcst.dtmvtolt = craplot.dtmvtolt AND
                                         crapcst.cdagenci = craplot.cdagenci AND
                                         crapcst.cdbccxlt = craplot.cdbccxlt AND
                                         crapcst.nrdolote = craplot.nrdolote   
                                         USE-INDEX crapcst1 NO-LOCK NO-ERROR.
                
                IF   NOT AVAILABLE crapcst      THEN NEXT.
                IF   crapcst.nrdconta <> 85448  THEN NEXT.
                IF   crapcst.insitchq  = 5      THEN NEXT.
        
                CREATE crawlot.
                ASSIGN crawlot.dtmvtolt = craplot.dtmvtolt
                       crawlot.cdagenci = craplot.cdagenci
                       crawlot.cdbccxlt = craplot.cdbccxlt
                       crawlot.nrdolote = craplot.nrdolote.
                 
                FIND crapope WHERE 
                     crapope.cdcooper = craplot.cdcooper   AND
                     crapope.cdoperad = craplot.cdoperad   NO-LOCK NO-ERROR.
                
                IF   NOT AVAILABLE crapope   THEN
                     ASSIGN crawlot.nmoperad = craplot.cdoperad.
                ELSE
                     ASSIGN crawlot.nmoperad = ENTRY(1,crapope.nmoperad," ").
            
                FOR EACH crapcst WHERE crapcst.cdcooper = par_cdcooper     AND
                                       crapcst.dtmvtolt = craplot.dtmvtolt AND
                                       crapcst.cdagenci = craplot.cdagenci AND
                                       crapcst.cdbccxlt = craplot.cdbccxlt AND
                                       crapcst.nrdolote = craplot.nrdolote AND
                                       crapcst.dtdevolu = ?
                                       USE-INDEX crapcst1 NO-LOCK:
                 
                    ASSIGN crawlot.qtcompln = crawlot.qtcompln + 1
                           crawlot.vlcompdb = crawlot.vlcompdb + crapcst.vlcheque.
                
                END.  /*  Fim do FOR EACH -- crapcst  */
                
                ASSIGN tt-relat-lotes.qtdlotes = tt-relat-lotes.qtdlotes  + 1
                       tt-relat-lotes.qtchqtot = tt-relat-lotes.qtchqtot + 
                                                 crawlot.qtcompln
                       tt-relat-lotes.vlchqtot = tt-relat-lotes.vlchqtot + 
                                                 crawlot.vlcompdb.
        
            END.  /*  Fim do FOR EACH  --  Leitura dos lotes do dia  */    

        END. /* DO aux_dtmvtolt To ... */

    END. /* FOR EACH crapage */
    
    RETURN "OK".

END PROCEDURE. /* busca_lotes_custodia */

PROCEDURE busca_informacoes_relatorio_custodia PRIVATE:
    /************************************************************************
        Objetivo  : Buscar informacoes para montagem do relatorio de cheques em
                    custodia (Opcao "R" da tela CUSTOD)
        Observacao: Indicador de Relatorio (Campo indrelat):
                    1) Informacoes da Cooper
                    2) Informacoes dos demais associados
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtini AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtfim AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER par_cdcritic AS INT         NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-relat-custod.
    DEFINE OUTPUT PARAMETER TABLE FOR crawlot.
    DEFINE OUTPUT PARAMETER TABLE FOR crabcst.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-relat-custod.
    EMPTY TEMP-TABLE crawlot.
    EMPTY TEMP-TABLE crabcst.

    DEF VAR aux_dtmvtolt AS DATE                        NO-UNDO.
    
    /* Busca valor dos cheques maiores */
    RUN busca_maiores_cheques_craptab (INPUT  par_cdcooper,
                                       INPUT  par_cdprogra,
                                       OUTPUT tab_vlchqmai,
                                       OUTPUT par_cdcritic,
                                       OUTPUT TABLE tt-erro).

    IF   RETURN-VALUE = "NOK"   THEN
         RETURN "NOK".
    /***********************************/     

    DO aux_contador = 1 TO 2:

        CREATE tt-relat-custod.
        ASSIGN tt-relat-custod.indrelat = aux_contador
               tt-relat-custod.dsdsaldo = IF aux_contador = 1 THEN 
                                             "     ** COOPER **"
                                          ELSE
                                             "** DEMAIS ASSOCIADOS ** ".

        FOR EACH crapage WHERE crapage.cdcooper = par_cdcooper NO-LOCK:

            DO aux_dtmvtolt = par_dtmvtini TO par_dtmvtfim:

                FOR EACH craplot WHERE
                         craplot.cdcooper = par_cdcooper AND
                         craplot.cdagenci = crapage.cdagenci AND
                         craplot.dtmvtolt = aux_dtmvtolt AND
                         craplot.cdbccxlt = 600 AND
                         craplot.tplotmov = 19 NO-LOCK:
                 
                    ASSIGN lot_qtchqcop = 0                
                           lot_vlchqcop = 0 
                           lot_qtcheque = 0 
                           lot_vlcheque = 0 
                           aux_nrdconta = 0.

                    FOR EACH crapcst WHERE 
                            crapcst.cdcooper = craplot.cdcooper AND
                            crapcst.dtmvtolt = craplot.dtmvtolt AND
                            crapcst.cdagenci = craplot.cdagenci AND
                            crapcst.cdbccxlt = craplot.cdbccxlt AND
                            crapcst.nrdolote = craplot.nrdolote NO-LOCK:

                        IF  par_cdagenci > 0   THEN
                            IF  crapcst.cdagenci <> par_cdagenci THEN
                                NEXT.

                        IF  aux_contador = 1 THEN /*  Saldo COOPER  */
                            DO:

                                IF  crapcst.nrdconta <> 85448   THEN
                                    NEXT.
                            END.
                        ELSE
                        IF  aux_contador = 2 THEN /*  Saldo DEMAIS ASSOC.  */
                            DO:
                                IF  crapcst.nrdconta = 85448 THEN
                                    NEXT.
                            END.

                        ASSIGN aux_nrdconta = crapcst.nrdconta.

                        IF  crapcst.inchqcop = 1 THEN
                            ASSIGN lot_vlchqcop = lot_vlchqcop +
                                                  crapcst.vlcheque
                                   lot_qtchqcop = lot_qtchqcop + 1.
                        ELSE 
                            DO:
                                ASSIGN lot_vlcheque = lot_vlcheque + crapcst.vlcheque
                                       lot_qtcheque = lot_qtcheque + 1.
                            END.

                        CREATE crabcst.
                        ASSIGN crabcst.indrelat = aux_contador
                               crabcst.cdagenci = crapcst.cdagenci 
                               crabcst.nrdconta = crapcst.nrdconta
                               crabcst.nrdolote = crapcst.nrdolote
                               crabcst.cdbccxlt = crapcst.cdbccxlt
                               crabcst.dtlibera = crapcst.dtlibera
                               crabcst.cdcmpchq = crapcst.cdcmpchq
                               crabcst.cdbanchq = crapcst.cdbanchq
                               crabcst.cdagechq = crapcst.cdagechq
                               crabcst.nrctachq = crapcst.nrctachq
                               crabcst.nrcheque = crapcst.nrcheque 
                               crabcst.vlcheque = crapcst.vlcheque
                               crabcst.dsdocmc7 = crapcst.dsdocmc7.

                    END.  /*  Fim do FOR EACH -- Leitura da custodia  */
           
                    IF  lot_qtchqcop = 0   AND 
                        lot_qtcheque = 0   THEN
                        NEXT.
                        
                    FIND crapope WHERE 
                         crapope.cdcooper = par_cdcooper       AND
                         crapope.cdoperad = craplot.cdoperad   NO-LOCK NO-ERROR.
                    IF   NOT AVAILABLE crapope   THEN
                         lot_nmoperad = craplot.cdoperad.
                    ELSE
                         lot_nmoperad = ENTRY(1,crapope.nmoperad," ").
                         
                    CREATE crawlot.
                    ASSIGN crawlot.indrelat = aux_contador
                           crawlot.cdagenci = craplot.cdagenci
                           crawlot.nrdconta = aux_nrdconta
                           crawlot.nrdolote = craplot.nrdolote
                           crawlot.qtchqcop = lot_qtchqcop
                           crawlot.qtcheque = lot_qtcheque
                           crawlot.qtchqtot = craplot.qtcompln
                           crawlot.vlchqcop = lot_vlchqcop
                           crawlot.vlcheque = lot_vlcheque
                           crawlot.vlchqtot = craplot.vlcompdb
                           crawlot.dtlibera = craplot.dtmvtopg
                           crawlot.nmoperad = lot_nmoperad.
                    
                    ASSIGN tt-relat-custod.qtdlotes = tt-relat-custod.qtdlotes + 1
                           tt-relat-custod.qtchqcop = tt-relat-custod.qtchqcop + 
                                                      crawlot.qtchqcop
                           tt-relat-custod.qtcheque = tt-relat-custod.qtcheque + 
                                                      crawlot.qtcheque
                           tt-relat-custod.qtchqtot = tt-relat-custod.qtchqtot + 
                                                      crawlot.qtchqtot
                           tt-relat-custod.vlchqcop = tt-relat-custod.vlchqcop + 
                                                      crawlot.vlchqcop 
                           tt-relat-custod.vlcheque = tt-relat-custod.vlcheque + 
                                                      crawlot.vlcheque 
                           tt-relat-custod.vlchqtot = tt-relat-custod.vlchqtot + 
                                                      crawlot.vlchqtot.
   
                END.  /*  Fim do FOR EACH  --  Leitura dos lotes do dia  */    
    
            END. /* DO aux_dtmvtolt */

        END. /* FOR EACH crapage */

    END.  /*  Fim do DO .. TO  */

    RETURN "OK".

END PROCEDURE. /* busca_informacoes_relatorio_custodia */

PROCEDURE busca_cheques_em_custodia PRIVATE:
    /************************************************************************
        Objetivo: Buscar cheques em custodia (Opcao "M" da tela CUSTOD)
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_inresgat AS LOGICAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtcusini AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtcusfim AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-crapcst.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
        
    EMPTY TEMP-TABLE tt-crapcst.

    IF  (par_dtcusini <> ?  AND par_dtcusfim  = ?) OR 
        (par_dtcusini  = ?  AND par_dtcusfim <> ?) THEN
        DO:

             ASSIGN aux_cdcritic = 0
                    aux_dscritic = IF par_dtcusini = ? THEN
                                      "Informe a data inicial."
                                   ELSE
                                      "Informe a data final."
                    aux_nrsequen = aux_nrsequen + 1.
           
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT 0,
                            INPUT 0,
                            INPUT aux_nrsequen, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
            
             RETURN "NOK".

        END.

    IF  par_dtcusini = ? THEN
        DO:

            FOR EACH crapcst WHERE crapcst.cdcooper =  par_cdcooper   AND
                                   crapcst.nrdconta =  par_nrdconta   AND
                                   crapcst.dtlibera >  par_dtmvtolt   AND
                                   crapcst.insitchq <> 2              NO-LOCK:
        
                IF   NOT par_inresgat   AND crapcst.dtdevolu <> ?   THEN NEXT.
        
                CREATE tt-crapcst.
                BUFFER-COPY crapcst TO tt-crapcst.
            
                ASSIGN tt-crapcst.nrcherel = 
                                  INTEGER(STRING(crapcst.nrcheque,"999999") + 
                                          STRING(crapcst.nrddigc3,"9")).
                     
            END.  /*  Fim do FOR EACH  */

        END.
    ELSE
        DO:

            FOR EACH crapcst WHERE crapcst.cdcooper =  par_cdcooper   AND
                                   crapcst.nrdconta =  par_nrdconta   AND
                                   crapcst.dtmvtolt >= par_dtcusini   AND
                                   crapcst.dtmvtolt <= par_dtcusfim   AND
                                   crapcst.insitchq <> 2              NO-LOCK:
    
                IF   NOT par_inresgat   AND crapcst.dtdevolu <> ?   THEN NEXT.
    
                CREATE tt-crapcst.
                BUFFER-COPY crapcst TO tt-crapcst.
    
                ASSIGN tt-crapcst.nrcherel = 
                                  INTEGER(STRING(crapcst.nrcheque,"999999") + 
                                          STRING(crapcst.nrddigc3,"9")).
    
            END.  /*  Fim do FOR EACH  */

        END.

    RETURN "OK".

END PROCEDURE. /* busca_cheques_em_custodia */

PROCEDURE conferencia_cheques_em_custodia PRIVATE:
    /************************************************************************
        Objetivo: Buscar informacoes dos cheques em custodia
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtiniper AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtfimper AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_containi AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_contafim AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-crapcst.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapcst.

    FOR EACH crapcst WHERE crapcst.cdcooper = par_cdcooper AND
                           crapcst.dtlibera >= par_dtiniper AND
                           crapcst.dtlibera <= par_dtfimper AND
                           crapcst.dtdevolu = ? AND
                           crapcst.nrdconta <> 85448 AND 
                           (par_containi = 0 OR crapcst.nrdconta = par_containi)
                           NO-LOCK:

        /* Quando informado PAC, filtra */
        IF  par_cdagenci <> 0 AND crapcst.cdagenci <> par_cdagenci THEN NEXT.

        CREATE tt-crapcst.
        BUFFER-COPY crapcst TO tt-crapcst.

        FIND crapass WHERE 
             crapass.cdcooper = crapcst.cdcooper  AND
             crapass.nrdconta = crapcst.nrdconta  NO-LOCK NO-ERROR.
        IF   AVAIL crapass   THEN
             ASSIGN tt-crapcst.nmprimtl = crapass.nmprimtl.

    END. /* FOR EACH crapcst */

    RETURN "OK".
    
END PROCEDURE. /* conferencia_cheques_em_custodia */

PROCEDURE busca_relatorio_desconto_custodia PRIVATE:
    /************************************************************************
        Objetivo: Buscar informacoes para apresentacao de relatorio de 
                  desconto de cheques em custodia - Opcao "D" da tela CUSTOD
     Observacoes: Temp-table tt-crapbdc precisa estar carregada com as 
                  chaves dos borderos a serem impressos
    ************************************************************************/
    DEFINE INPUT         PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT         PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT         PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT-OUTPUT  PARAMETER TABLE FOR tt-crapbdc.
    DEFINE OUTPUT        PARAMETER TABLE FOR tt-crapcst.
    DEFINE OUTPUT        PARAMETER TABLE FOR tt-erro.

    FOR EACH tt-crapbdc:

        FIND crapbdc WHERE 
             crapbdc.cdcooper = tt-crapbdc.cdcooper   AND
             crapbdc.nrborder = tt-crapbdc.nrborder   NO-LOCK NO-ERROR.
        IF   AVAIL crapbdc   THEN
             DO:
                 FIND crapass WHERE 
                      crapass.cdcooper = tt-crapbdc.cdcooper   AND
                      crapass.nrdconta = tt-crapbdc.nrdconta   
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
                          RETURN "NOK".
                      END.

                 FIND FIRST crapcdb WHERE 
                            crapcdb.cdcooper = crapbdc.cdcooper   AND
                            crapcdb.nrdconta = crapbdc.nrdconta   AND
                            crapcdb.dtmvtolt = crapbdc.dtmvtolt   AND
                            crapcdb.nrborder = crapbdc.nrborder   
                            NO-LOCK NO-ERROR.
                 IF   NOT AVAILABLE crapcdb   THEN
                      DO:
                          ASSIGN aux_cdcritic = 0
                                 aux_dscritic = "Bordero nao possui " + 
                                                "cheques descontados".
                          RUN gera_erro (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT 1,            /** Sequencia **/
                                         INPUT aux_cdcritic,
                                         INPUT-OUTPUT aux_dscritic).
                          RETURN "NOK".
                      END.

                 BUFFER-COPY crapbdc TO tt-crapbdc.
                 ASSIGN tt-crapbdc.nmprimtl = crapass.nmprimtl
                        tt-crapbdc.dtlibera = crapcdb.dtlibera.

                 FOR EACH crapcst WHERE 
                          crapcst.cdcooper = crapbdc.cdcooper   AND
                          crapcst.dtdevolu = crapbdc.dtmvtolt   AND
                          crapcst.nrborder = crapbdc.nrborder   AND
                          crapcst.insitchq = 5                  NO-LOCK:

                     CREATE tt-crapcst.
                     BUFFER-COPY crapcst TO tt-crapcst.

                 END. /* FOR EACH crapcst */
             END. /* IF   AVAIL crapbdc */
    END. /* FOR EACH tt-crapbdc */

    RETURN "OK".

END PROCEDURE. /* busca_relatorio_desconto_custodia */

/*.............................. FIM PROCEDURES .............................*/
