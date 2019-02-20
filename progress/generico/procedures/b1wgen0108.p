/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0108.p
    Autor   : Gabriel Capoia dos Santos (DB1)
    Data    : Agosto/2011                        Ultima atualizacao: 13/12/2013

    Objetivo  : Tranformacao BO tela CONCBB

    Alteracoes: 
   
               23/05/2012 - Incluido Cod. Barras e Hora na conciliação Arquivos
                            BB. (Lucas R.)
               
               13/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).

               13/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle Inclusao do VALIDATE
                            ( Guilherme / SUPERO)
                
				26/12/2018 - Projeto 510 - Alterei a procedure busca_dados para retornar também o novo campo crapcbb.tppagmto (Daniel - Envolti)
				
............................................................................*/

/*............................. DEFINICOES .................................*/

{ sistema/generico/includes/b1wgen0108tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrregist AS INTE                                        NO-UNDO.
DEF VAR aux_nrsequen AS INTE                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                      NO-UNDO.

DEF STREAM str_1.
DEF STREAM str_2.

/*................................ PROCEDURES ..............................*/

/* ------------------------------------------------------------------------ */
/*                EFETUA A BUSCA DOS DADOS DO ASSOCIADO                     */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolx AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inss     AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_valorpag AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-concbb.
    DEF OUTPUT PARAM TABLE FOR tt-movimentos.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_tpdocmto AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdagefim AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdcaixa AS INTE                                    NO-UNDO.
     
    DEF BUFFER crabcbb FOR crapcbb.
    DEF BUFFER crabope FOR crapope.
     
    ASSIGN aux_nrregist = par_nrregist
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".
    
    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-concbb.
        EMPTY TEMP-TABLE tt-movimentos.
        EMPTY TEMP-TABLE tt-erro.
        
        IF  CAN-DO("V,D",par_cddopcao) THEN
            DO:              
                ASSIGN aux_cdagefim = IF par_cdagencx = 0
                                      THEN 9999
                                      ELSE par_cdagencx
                       aux_nrdcaixa = IF par_nrdcaixx = 0 
                                      THEN 9999
                                      ELSE par_nrdcaixx.
                  

                Movimentos: FOR EACH crabcbb FIELDS(cdagenci cdbccxlt cdopecxa
                                                    nrdcaixa nrdolote valordoc
                                                    valorpag flgrgatv cdbarras
                                                    dsdocmc7 vldescto nrautdoc
                                                    tpdocmto dtvencto tppagmto)
                               WHERE crabcbb.cdcooper =  par_cdcooper AND
                                     crabcbb.dtmvtolt =  par_dtmvtolx AND
                                     crabcbb.cdagenci >= par_cdagencx AND
                                     crabcbb.cdagenci <= aux_cdagefim AND
                                     crabcbb.nrdcaixa >= par_nrdcaixx AND
                                     crabcbb.nrdcaixa <= aux_nrdcaixa NO-LOCK,
        
                            FIRST crabope FIELDS(nmoperad)
                                    WHERE crabope.cdcooper = par_cdcooper AND
                                          crabope.cdoperad = crabcbb.cdopecxa
                                          NO-LOCK
                                              BY crabcbb.cdagenci
                                                  BY crabcbb.nrdolote
                                                      BY crabcbb.valordoc:
        
                    CASE par_cddopcao:
        
                        WHEN "V" THEN
                            DO:
                                IF  NOT ((crabcbb.tpdocmto < 3 AND 
                                          NOT par_inss ) OR
                                          par_inss) THEN
                                    NEXT Movimentos.
        
                                CASE crabcbb.tpdocmto:
                                    WHEN 1 THEN 
                                               ASSIGN aux_tpdocmto =  "TITULO".
                                    WHEN 2 THEN 
                                               ASSIGN aux_tpdocmto =  "FATURA".
                                    WHEN 3 THEN 
                                               ASSIGN aux_tpdocmto = "INSS".
                                END CASE.
                            END.
        
                        WHEN "D" THEN
                            DO:
                                IF  NOT(crabcbb.valorpag >= par_valorpag AND
                                        crabcbb.tpdocmto < 3 ) THEN
                                    NEXT Movimentos.

                                ASSIGN aux_tpdocmto = IF crabcbb.tpdocmto = 1
                                                      THEN "TITULO"
                                                      ELSE "FATURA".
                            END.

                    END CASE.

                    ASSIGN par_qtregist = par_qtregist + 1.

                    /* controles da paginação */
                    IF  (par_qtregist < par_nriniseq) OR
                        (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                        NEXT.

                    IF  aux_nrregist > 0 THEN
                        DO: 
                            CREATE tt-movimentos.
                            ASSIGN tt-movimentos.cdagenci = crabcbb.cdagenci
                                   tt-movimentos.cdbccxlt = crabcbb.cdbccxlt
                                   tt-movimentos.cdopecxa = crabcbb.cdopecxa
                                   tt-movimentos.nrdcaixa = crabcbb.nrdcaixa
                                   tt-movimentos.nrdolote = crabcbb.nrdolote
                                   tt-movimentos.valordoc = crabcbb.valordoc
                                   tt-movimentos.valorpag = crabcbb.valorpag
                                   tt-movimentos.flgrgatv = crabcbb.flgrgatv
                                   tt-movimentos.cdbarras = crabcbb.cdbarras
                                   tt-movimentos.dsdocmc7 = crabcbb.dsdocmc7
                                   tt-movimentos.vldescto = crabcbb.vldescto
                                   tt-movimentos.nrautdoc = crabcbb.nrautdoc
                                   tt-movimentos.tpdocmto = crabcbb.tpdocmto
                                   tt-movimentos.dtvencto = crabcbb.dtvencto
                                   tt-movimentos.nmoperad = crabope.nmoperad
                                   tt-movimentos.dsdocmto = aux_tpdocmto
                                   tt-movimentos.nrdrowid = ROWID(crabcbb)
								                   tt-movimentos.tppagmto = crabcbb.tppagmto.
                            
                            IF tt-movimentos.tppagmto = 0 THEN
                            DO:
                                tt-movimentos.dstppgto = 'CONTA'.
                            END.
                            ELSE
                            DO:
                                tt-movimentos.dstppgto = 'ESPECIE'.
                            END.                             
                                   
                                   
                        END.


                    ASSIGN aux_nrregist = aux_nrregist - 1.
        
                END. /* Movimentos */


            END. /* CAN-DO("V,D",par_cddopcao) */
        ELSE
        IF  par_cddopcao = "C" THEN
            DO:
                ASSIGN aux_cdagefim = IF par_cdagencx = 0
                                      THEN 9999
                                      ELSE par_cdagencx
                       aux_nrdcaixa = IF par_nrdcaixx = 0 
                                      THEN 9999
                                      ELSE par_nrdcaixx.

                CREATE tt-concbb.
                
                Movimentos: FOR EACH crabcbb WHERE 
                                     crabcbb.cdcooper =  par_cdcooper AND
                                     crabcbb.dtmvtolt =  par_dtmvtolx AND
                                     crabcbb.cdagenci >= par_cdagencx AND
                                     crabcbb.cdagenci <= aux_cdagefim AND
                                     crabcbb.nrdcaixa >= par_nrdcaixx AND
                                     crabcbb.nrdcaixa <= aux_nrdcaixa AND
                                   ((crabcbb.tpdocmto < 3             AND
                                     NOT par_inss )                   OR
                                     par_inss )                       NO-LOCK:

                    IF  crabcbb.tpdocmto = 1   THEN   /* Titulos */
                        DO:
                            ASSIGN tt-concbb.qttitrec = tt-concbb.qttitrec + 1

                                   tt-concbb.vltitrec = tt-concbb.vltitrec + 
                                                        crabcbb.valorpag. 
                            
                            IF  crabcbb.flgrgatv THEN 
                                ASSIGN tt-concbb.qttitliq = 
                                                         tt-concbb.qttitliq + 1

                                       tt-concbb.vltitliq = tt-concbb.vltitliq
                                                          + crabcbb.valorpag.
                            ELSE
                                ASSIGN tt-concbb.qttitcan = 
                                                         tt-concbb.qttitcan + 1

                                       tt-concbb.vltitcan = tt-concbb.vltitcan
                                                          + crabcbb.valorpag.
                        END.
                    ELSE
                        DO:                                              
                            IF  crabcbb.tpdocmto = 2 THEN /* Faturas */
                                DO:
                                    ASSIGN tt-concbb.qtfatrec = 
                                                         tt-concbb.qtfatrec + 1

                                           tt-concbb.vlfatrec = 
                                                           tt-concbb.vlfatrec +
                                                           crabcbb.valorpag.
                            
                                    IF  crabcbb.flgrgatv THEN 
                                        ASSIGN tt-concbb.qtfatliq = 
                                                         tt-concbb.qtfatliq + 1

                                               tt-concbb.vlfatliq = 
                                                           tt-concbb.vlfatliq +
                                                           crabcbb.valorpag.
                                    ELSE
                                        ASSIGN tt-concbb.qtfatcan = 
                                                         tt-concbb.qtfatcan + 1

                                               tt-concbb.vlfatcan = 
                                                           tt-concbb.vlfatcan +
                                                           crabcbb.valorpag.
                                END.             
                            ELSE
                                DO:      
                                    IF  crabcbb.flgrgatv THEN
                                          
                                        ASSIGN tt-concbb.qtinss = 
                                                           tt-concbb.qtinss + 1

                                               tt-concbb.vlinss = 
                                                            tt-concbb.vlinss + 
                                                            crabcbb.valorpag.
                                END.    
                         END.
                     
                    IF  NOT crabcbb.flgrgatv THEN 
                        NEXT Movimentos.

                    IF  crabcbb.tpdocmto = 3 THEN 
                        NEXT Movimentos.
                       
                    IF  crabcbb.dsdocmc7 = " " THEN 
                        ASSIGN tt-concbb.qtdinhei = tt-concbb.qtdinhei + 1 
                               tt-concbb.vldinhei = tt-concbb.vldinhei + 
                                                    crabcbb.valorpag.
                    ELSE
                        ASSIGN tt-concbb.qtcheque = tt-concbb.qtcheque + 1
                               tt-concbb.vlcheque = tt-concbb.vlcheque + 
                                                    crabcbb.valorpag.

                END. /* Movimentos */

            END. /* par_cddopcao = "C" */

        ASSIGN aux_returnvl = "OK".

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
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Dados */

/* ------------------------------------------------------------------------ */
/*         BUSCA VALORES DO MOVIMENTO LANÇADO PELO BB NO DIA ANTERIOR       */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Movimento:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolx AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flggeren AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM aux_mrsgetor AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_msgprint AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-total.
    DEF OUTPUT PARAM TABLE FOR tt-mensagens.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdagefim  AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdcaixa  AS INTE                                    NO-UNDO.
    DEF VAR aux_nmarqdat  AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarquiv  AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdageini  AS INTE                                    NO-UNDO.
    DEF VAR aux_flgfecha  AS LOGI                                    NO-UNDO.
    DEF VAR aux_cdagencia_fim AS INTE                                NO-UNDO.
    DEF VAR aux_valor_cooper  AS DECI                                NO-UNDO.
    DEF VAR aux_valor_coban   AS DECI                                NO-UNDO.
    
    DEF VAR aux_qttitrec  AS DECI   FORMAT "zzz,zz9"                 NO-UNDO.
    DEF VAR aux_vltitrec  AS DECI   FORMAT "zzz,zzz,zz9.99"          NO-UNDO.
    DEF VAR aux_qttitliq  AS DECI   FORMAT "zzz,zz9"                 NO-UNDO.
    DEF VAR aux_vltitliq  AS DECI   FORMAT "zzz,zzz,zz9.99"          NO-UNDO.
    DEF VAR aux_qttitcan  AS DECI   FORMAT "zzz,zz9"                 NO-UNDO.
    DEF VAR aux_vltitcan  AS DECI   FORMAT "zzz,zzz,zz9.99"          NO-UNDO.
    DEF VAR aux_qtfatrec  AS DECI   FORMAT "zzz,zz9"                 NO-UNDO.
    DEF VAR aux_vlfatrec  AS DECI   FORMAT "zzz,zzz,zz9.99"          NO-UNDO.
    DEF VAR aux_qtfatliq  AS DECI   FORMAT "zzz,zz9"                 NO-UNDO.
    DEF VAR aux_vlfatliq  AS DECI   FORMAT "zzz,zzz,zz9.99"          NO-UNDO.
    DEF VAR aux_qtfatcan  AS DECI   FORMAT "zzz,zz9"                 NO-UNDO.
    DEF VAR aux_vlfatcan  AS DECI   FORMAT "zzz,zzz,zz9.99"          NO-UNDO.
    DEF VAR aux_qtdinhei  AS DECI   FORMAT "zzz,zz9"                 NO-UNDO.
    DEF VAR aux_vldinhei  AS DECI   FORMAT "zzz,zzz,zz9.99"          NO-UNDO.
    DEF VAR aux_qtcheque  AS DECI   FORMAT "zzz,zz9"                 NO-UNDO.
    DEF VAR aux_vlcheque  AS DECI   FORMAT "zzz,zzz,zz9.99"          NO-UNDO.
    DEF VAR aux_qtinss    AS DECI   FORMAT "zzz,zz9"                 NO-UNDO.
    DEF VAR aux_vlinss    AS DECI   FORMAT "zzz,zzz,zz9.99"          NO-UNDO.
    DEF VAR aux_vlrepasse AS DECI                                    NO-UNDO.
    
  DEF VAR aux_hora_coban  AS INTE                                    NO-UNDO.


    DEF BUFFER crabcop FOR crapcop.
     
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_nrsequen = 0
           aux_returnvl = "NOK".
    
    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-arquivo.
        EMPTY TEMP-TABLE tt-movtos.
        EMPTY TEMP-TABLE tt-total.
        EMPTY TEMP-TABLE tt-mensagens.
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAIL crabcop THEN
            DO:
                ASSIGN aux_cdcritic = 651.
                LEAVE Busca.
            END.

        IF  par_cdagencx <> 0 THEN
            ASSIGN par_cdagencx = par_cdagencx + 100.
        
        ASSIGN aux_cdagefim = IF   par_cdagencx = 0 THEN 9999
                              ELSE par_cdagencx

               aux_nrdcaixa = IF   par_nrdcaixx = 0 THEN 999
                              ELSE par_nrdcaixx.

        /* Seleciona os Arquivos */

        IF  par_flggeren THEN
            ASSIGN aux_nmarqdat = "/micros/" + TRIM(crabcop.dsdircop) + 
                                  "/coban/CBF8*.RET".
        ELSE
            ASSIGN aux_nmarqdat = "compbb/" + "cbf80*".

        INPUT STREAM str_2 THROUGH 
              VALUE( "ls " + aux_nmarqdat + " 2> /dev/null") NO-ECHO.

        DO  WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

            SET STREAM str_2
                aux_nmarquiv FORMAT "x(70)" .

            CREATE tt-arquivo.
            ASSIGN tt-arquivo.nmarquivo = aux_nmarquiv.

        END.  /*  Fim do DO WHILE TRUE  */

        INPUT STREAM str_2 CLOSE.

        FOR EACH tt-arquivo NO-LOCK:
            RUN processa_arquivos( INPUT par_cdcooper,
                                   INPUT tt-arquivo.nmarquivo,
                                   INPUT par_dtmvtolt,
                                   INPUT par_flggeren ).
        END.

        /* Busca totais do arquivo importado - Retorno COBAN */ 
        RUN leitura_craprcb  ( INPUT par_cdcooper,
                               INPUT par_dtmvtolx,
                               INPUT par_cdagencx,
                               INPUT aux_cdagefim,
                               INPUT par_nrdcaixx,
                               INPUT aux_nrdcaixa,
                               OUTPUT TABLE tt-total).

        FIND FIRST tt-total NO-ERROR.
        

        ASSIGN aux_qttitrec = 0
               aux_vltitrec = 0
               aux_qttitliq = 0
               aux_vltitliq = 0
               aux_qttitcan = 0
               aux_vltitcan = 0
               aux_qtfatrec = 0
               aux_vlfatrec = 0
               aux_qtfatliq = 0
               aux_vlfatliq = 0
               aux_qtfatcan = 0
               aux_vlfatcan = 0
               aux_qtinss   = 0
               aux_vlinss   = 0
               aux_qtdinhei = 0
               aux_vldinhei = 0
               aux_qtcheque = 0
               aux_vlcheque = 0.

        ASSIGN aux_cdageini      = 0
               aux_cdagencia_fim = 999.

        IF  par_cdagencx <> 0 THEN
            ASSIGN aux_cdageini      = par_cdagencx - 100
                   aux_cdagencia_fim = par_cdagencx - 100.


        FOR EACH crapcbb WHERE crapcbb.cdcooper  = par_cdcooper        AND
                               crapcbb.dtmvtolt  = par_dtmvtolx        AND
                              (crapcbb.cdagenci >= aux_cdageini        AND
                               crapcbb.cdagenci <= aux_cdagencia_fim ) AND
                              (crapcbb.nrdcaixa >= par_nrdcaixx        AND
                               crapcbb.nrdcaixa <= aux_nrdcaixa)       NO-LOCK:

            IF  crapcbb.tpdocmto = 1 THEN   /* Titulos */
                DO:
                    ASSIGN aux_qttitrec = aux_qttitrec + 1
                           aux_vltitrec = aux_vltitrec + crapcbb.valorpag.

                    IF  crapcbb.flgrgatv THEN 
                        ASSIGN aux_qttitliq = aux_qttitliq + 1
                               aux_vltitliq = aux_vltitliq + crapcbb.valorpag.
                    ELSE
                        ASSIGN aux_qttitcan = aux_qttitcan + 1
                               aux_vltitcan = aux_vltitcan + crapcbb.valorpag.
                END.
            ELSE
                DO:  /* Faturas */
                    IF  crapcbb.tpdocmto = 2 THEN
                        DO:
                            ASSIGN aux_qtfatrec = aux_qtfatrec + 1
                                   aux_vlfatrec = aux_vlfatrec + 
                                                  crapcbb.valorpag. 
                
                        IF  crapcbb.flgrgatv THEN 
                            ASSIGN aux_qtfatliq = aux_qtfatliq + 1
                                   aux_vlfatliq = aux_vlfatliq +
                                                  crapcbb.valorpag.
                        ELSE
                           ASSIGN aux_qtfatcan = aux_qtfatcan + 1
                                  aux_vlfatcan = aux_vlfatcan +
                                                 crapcbb.valorpag.
                    END.
                ELSE
                    DO:
                        IF  crapcbb.flgrgatv THEN
                            ASSIGN aux_qtinss = aux_qtinss + 1
                                   aux_vlinss = aux_vlinss +
                                                crapcbb.valorpag.
                    END.    
            END.

            IF  NOT crapcbb.flgrgatv THEN 
                NEXT.
               
            IF  crapcbb.tpdocmto = 3 THEN 
                NEXT.
            
            IF  crapcbb.dsdocmc7 = " " THEN 
                ASSIGN aux_qtdinhei = aux_qtdinhei + 1           
                       aux_vldinhei = aux_vldinhei + crapcbb.valorpag.
            ELSE
                ASSIGN aux_qtcheque = aux_qtcheque + 1
                       aux_vlcheque = aux_vlcheque + crapcbb.valorpag.

   
        END.  /*  Fim do FOR EACH  --  Leitura do crapcbb  */
        
        ASSIGN aux_flgfecha = YES.

        IF  tt-total.qttitliq <> aux_qttitliq OR
            tt-total.vltitliq <> aux_vltitliq OR
            tt-total.qtfatliq <> aux_qtfatliq OR
            tt-total.vlfatliq <> aux_vlfatliq OR
            tt-total.qtinss   <> aux_qtinss   OR
            tt-total.vlinss   <> aux_vlinss   OR
            /*============================== COBAN nao grava cancelamentos
            tel_qttitrec <> aux_qttitrec OR
            tel_vltitrec <> aux_vltitrec OR
            tel_qttitcan <> aux_qttitcan OR
            tel_vltitcan <> aux_vltitcan OR
            tel_qtfatrec <> aux_qtfatrec OR
            tel_vlfatrec <> aux_vlfatrec OR
            tel_qtfatcan <> aux_qtfatcan OR
            tel_vlfatcan <> aux_vlfatcan OR
            ============================================================*/
            tt-total.qtdinhei <> aux_qtdinhei OR
            tt-total.vldinhei <> aux_vldinhei OR
            tt-total.qtcheque <> aux_qtcheque OR
            tt-total.vlcheque <> aux_vlcheque THEN 
            DO:
               ASSIGN aux_flgfecha = NO
                      aux_mrsgetor = "VALORES COM DIFERENCA - FAVOR VERIFICAR".
            END.
        ELSE
            ASSIGN aux_mrsgetor = "FECHAMENTO OK".

        IF  NOT aux_flgfecha THEN /* Verificar caixas cujo valores nao fecham*/
            DO:
                ASSIGN aux_valor_cooper = 0.
                
                FOR EACH crapcbb WHERE crapcbb.cdcooper  = par_cdcooper  AND
                                       crapcbb.dtmvtolt  = par_dtmvtolx  AND
                                      (crapcbb.cdagenci >= aux_cdageini  AND
                                       crapcbb.cdagenci <= 
                                                      aux_cdagencia_fim) AND
                                      (crapcbb.nrdcaixa >= par_nrdcaixx  AND
                                       crapcbb.nrdcaixa <= aux_nrdcaixa) AND
                                       crapcbb.flgrgatv NO-LOCK
                                       BREAK BY crapcbb.cdagenci
                                             BY crapcbb.nrdcaixa:
                    ASSIGN  aux_valor_cooper = aux_valor_cooper + 
                                               crapcbb.valorpag.

                    IF  LAST-OF(crapcbb.cdagenci) OR
                        LAST-OF(crapcbb.nrdcaixa) THEN
                        DO:
                            FOR EACH craprcb WHERE
                                     craprcb.cdcooper  = par_cdcooper     AND
                                     craprcb.dtmvtolt  = crapcbb.dtmvtolt AND
                                     craprcb.cdagenci  = 
                                                   crapcbb.cdagenci + 100 AND
                                     craprcb.nrdcaixa  = crapcbb.nrdcaixa AND
                                     craprcb.flgrgatv  NO-LOCK:

                                ASSIGN aux_valor_coban = aux_valor_coban + 
                                                         craprcb.valorpag.
                                        aux_hora_coban = craprcb.hrdmovto.

                                /*Registros encontrados da craprcb 
                                  em relacao a crapcbb*/
                                IF  NOT CAN-FIND(FIRST tt-rcb-rowid WHERE
                                                 tt-rcb-rowid.rowid = 
                                                                 ROWID(craprcb)
                                                 NO-LOCK)  THEN
                                    DO:
                                        CREATE tt-rcb-rowid.
                                        ASSIGN tt-rcb-rowid.rowid = 
                                                                ROWID(craprcb).
                                    END.
                            END.

                                    IF  aux_valor_cooper <> aux_valor_coban THEN
                                        RUN cria-registro-msg(
                                                "Verifique PA: " + 
                                                STRING(crapcbb.cdagenci) + " Caixa: " + 
                                                STRING(crapcbb.nrdcaixa) + " Cod. Barras: " +
                                                STRING(crapcbb.cdbarras) + " Hora: " +
                                                STRING(aux_hora_coban,"HH:MM:SS") ).
                                    
                        END.                  

                            ASSIGN aux_valor_coban  = 0
                                   aux_valor_cooper = 0.


                END.  /*  Fim do FOR EACH  --  Leitura do crapcbb  */
                
                
                /* Leitura do retorno do BB */
                /* Caso algum registro craprcb nao estive na temp-table
                   eh porque houve problema */
                FOR EACH craprcb WHERE 
                         craprcb.cdcooper = par_cdcooper                 AND
                         craprcb.dtmvtolt = par_dtmvtolx                 AND
                        (craprcb.cdtransa = '268' OR /* Titulos */
                         craprcb.cdtransa = '358' OR /* Faturas */
                         craprcb.cdtransa = '284')   /* Recebto INSS */  AND  
                         craprcb.cdagenci <> 9999
                         NO-LOCK:

                    IF  NOT CAN-FIND(tt-rcb-rowid WHERE
                                     tt-rcb-rowid.rowid = ROWID(craprcb))  THEN

                        /*Criar temp-table de msg*/
                        RUN cria-registro-msg(
                                 "Verifique PA: " +
                                 STRING((craprcb.cdagenci - 100),"zz9") + 
                                 " Caixa: " +
                                 STRING(craprcb.nrdcaixa,"zz9") + 
                                 " BB =t> " +
                                 STRING(craprcb.valorpag,"z,zzz,zz9.99") + 
                                 " Cod. Barras: " +
                                 STRING(craprcb.cdbarras) + 
                                 " Hora: " +
                                 STRING(craprcb.hrdmovto,"HH:MM:SS") ).   

                           
    
                END. /* Final da leitura da craprcb */
                
            END. /* NOT aux_flgfecha */

        ASSIGN aux_msgprint = "Deseja listar as faturas referentes a " +
                              "pesquisa(S/N)?:".
                              

        ASSIGN aux_returnvl = "OK".

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
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Movimento */

/* ------------------------------------------------------------------------ */
/*                                                   */
/* ------------------------------------------------------------------------ */
PROCEDURE Lista_Faturas:
         
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolx AS DATE                           NO-UNDO.
    
    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_nmendter AS CHAR                                    NO-UNDO.
    DEF VAR aux_dscritix AS CHAR FORMAT "x(40)"                     NO-UNDO.
    DEF VAR aux_flgexist AS LOGI INITIAL FALSE                      NO-UNDO.
    DEF VAR aux_cdagefim AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdcaixa AS INTE                                    NO-UNDO.
    
    DEF VAR rel_vltotpag    AS DECI FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
    DEF VAR rel_tpdocmto    AS CHAR                                 NO-UNDO.
    DEF VAR rel_flagcheq    AS LOGI FORMAT "S/N"                    NO-UNDO.
    DEF VAR rel_vltotpag_cx AS DECI FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
    DEF VAR rel_vltotpag_tt AS DECI FORMAT "zzz,zzz,zz9.99"         NO-UNDO.

    FORM craprcb.nmarquiv    COLUMN-LABEL "Arquivo" FORMAT "x(20)"
         craprcb.dtmvtolt    COLUMN-LABEL "Data Trans."
         craprcb.cdtransa    COLUMN-LABEL "Cod."
         craprcb.hrdmovto    COLUMN-LABEL "Hora Trans"
         craprcb.dtdmovto    COLUMN-LABEL "Data Movto"
         craprcb.valorpag    COLUMN-LABEL "Valor Pago"
         craprcb.cdagenci    COLUMN-LABEL "Loja"
         craprcb.nrdcaixa    COLUMN-LABEL "Caixa"
         craprcb.formaliq    COLUMN-LABEL "Pagto"
         craprcb.flgrgatv    COLUMN-LABEL "Ativo"
         rel_tpdocmto        COLUMN-LABEL "Tp.Docto"
         rel_flagcheq        COLUMN-LABEL "Cheque"
         craprcb.autchave    COLUMN-LABEL "SEQ"
         craprcb.cdagerel    COLUMN-LABEL "Ag.Rel."
         WITH DOWN NO-BOX WIDTH 132 FRAME f_lista.

    FORM "Qtd.               Valor" AT 36 
     tt-total.qttitrec AT 12 FORMAT "zzz,zz9" LABEL  "Titulos  Recebidos"
     tt-total.vltitrec AT 46 FORMAT "zzz,zzz,zz9.99" NO-LABEL
            
     tt-total.qttitliq AT 12 FORMAT "zzz,zz9-" LABEL "Titulos Liquidados"
     tt-total.vltitliq AT 46 FORMAT "zzz,zzz,zz9.99-" NO-LABEL
               
     tt-total.qttitcan AT 12 FORMAT "zzz,zz9-" LABEL "Titulos Cancelados"
     tt-total.vltitcan AT 46 FORMAT "zzz,zzz,zz9.99-" NO-LABEL
               
     tt-total.qtfatrec AT 12 FORMAT "zzz,zz9" LABEL  "Faturas  Recebidas"
     tt-total.vlfatrec AT 46 FORMAT "zzz,zzz,zz9.99" NO-LABEL
            
     tt-total.qtfatliq AT 12 FORMAT "zzz,zz9-" LABEL "Faturas Liquidadas"
     tt-total.vlfatliq AT 46 FORMAT "zzz,zzz,zz9.99-" NO-LABEL
                
     tt-total.qtfatcan AT 12 FORMAT "zzz,zz9-" LABEL "Faturas Canceladas"
     tt-total.vlfatcan AT 46 FORMAT "zzz,zzz,zz9.99-" NO-LABEL
     
     tt-total.qtinss   AT 12 FORMAT "zzz,zz9-" LABEL "Qtd.INSS          "
     tt-total.vlinss   AT 46 FORMAT "zzz,zzz,zz9.99-" NO-LABEL
     SKIP(1)

     tt-total.qtdinhei AT 12 FORMAT "zzz,zz9" LABEL  "Pago  Dinheiro"             
     tt-total.vldinhei AT 46 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tt-total.qtcheque AT 12 FORMAT "zzz,zz9" LABEL  "Pago    Cheque"             
     tt-total.vlcheque AT 46 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP(1)

     "REPASSE" AT 12
     tt-total.vlrepasse AT 46 FORMAT "zzz,zzz,zz9.99"  NO-LABEL
     SKIP
     WITH ROW 8 COLUMN 10 NO-BOX OVERLAY SIDE-LABELS FRAME f_total.

    FORM "PA - " craprcb.cdagenci
         SKIP(1)
         WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_pac.
         
    FORM "CAIXA - " craprcb.nrdcaixa
         SKIP(1)
         WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_caixa.
    
    DEF BUFFER crabcop FOR crapcop.
        
    ASSIGN aux_cdcritic = 0
           aux_dstransa = "Imprime Manutencao dos Talonarios"
           aux_dscritic = ""
           aux_returnvl = "NOK".
        
    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crabcop FIELDS(dsdircop) 
                          WHERE crabcop.cdcooper = par_cdcooper NO-LOCK:
        END.

        IF  NOT AVAILABLE crabcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        IF  par_cdagencx <> 0 THEN
            ASSIGN par_cdagencx = par_cdagencx + 100.

        ASSIGN aux_cdagefim = IF   par_cdagencx = 0 THEN 9999
                              ELSE par_cdagencx
               aux_nrdcaixa = IF   par_nrdcaixx = 0 THEN 999
                              ELSE par_nrdcaixx.
        
        /* Busca totais do arquivo importado - Retorno COBAN */
        RUN leitura_craprcb  ( INPUT par_cdcooper,
                               INPUT par_dtmvtolx,
                               INPUT par_cdagencx,
                               INPUT aux_cdagefim,
                               INPUT par_nrdcaixx,
                               INPUT aux_nrdcaixa,
                               OUTPUT TABLE tt-total).

        FIND FIRST tt-total NO-ERROR.
        
        ASSIGN aux_nmendter = "/usr/coop/" + crabcop.dsdircop + "/rl/" +
                              par_dsiduser.
        
        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

        /* Cdempres = 11 , Relatorio 366 em 132 colunas */
        { sistema/generico/includes/cabrel.i "11" "366" "132" }
       
        FOR EACH craprcb WHERE craprcb.cdcooper  = par_cdcooper   AND
                               craprcb.dtmvtolt  = par_dtmvtolx   AND
                              (craprcb.cdagenci >= par_cdagencx   AND
                               craprcb.cdagenci <= aux_cdagefim ) AND
                              (craprcb.nrdcaixa >= par_nrdcaixx   AND
                               craprcb.nrdcaixa <= aux_nrdcaixa)  AND
                               craprcb.cdtransa <> "284" 
                               BREAK BY craprcb.cdagenci
                                        BY craprcb.nrdcaixa
                                           BY craprcb.autchave:

            IF  LINE-COUNTER(str_1) >= (PAGE-SIZE(str_1) - 4)  THEN
                DO:
                    PAGE STREAM str_1.
                    VIEW STREAM str_1 FRAME f_cabrel132_1.
                END.

            IF  FIRST-OF (craprcb.cdagenci)   THEN
                DO:
                    ASSIGN rel_vltotpag = 0.
                    DISPLAY STREAM str_1  craprcb.cdagenci  WITH FRAME f_pac.
                    DOWN STREAM str_1 WITH FRAME f_pac.
                END.

            IF  FIRST-OF (craprcb.nrdcaixa)   THEN
                DO:
                    ASSIGN rel_vltotpag_cx = 0.
                    DISPLAY stream str_1  craprcb.nrdcaixa WITH FRAME f_caixa.
                END.

            ASSIGN rel_tpdocmto = IF  craprcb.cdtransa = '268' THEN "TITULO"
                                  ELSE 
                                  IF  craprcb.cdtransa = '358' THEN "FATURA"
                                  ELSE "INSS"
                   rel_flagcheq = IF   craprcb.formaliq = 2    THEN TRUE
                                  ELSE FALSE.
        
            IF  craprcb.flgrgatv  THEN
                ASSIGN rel_vltotpag    = rel_vltotpag    + craprcb.valorpag  
                       rel_vltotpag_cx = rel_vltotpag_cx + craprcb.valorpag
                       rel_vltotpag_tt = rel_vltotpag_tt + craprcb.valorpag.

            DISPLAY STREAM str_1 
                         craprcb.nmarquiv 
                         craprcb.dtmvtolt              
                         craprcb.cdtransa
                         STRING(craprcb.hrdmovto,"HH:MM:SS") @ craprcb.hrdmovto
                         craprcb.dtdmovto
                         craprcb.valorpag
                         craprcb.cdagenci
                         craprcb.nrdcaixa
                         craprcb.formaliq
                         craprcb.flgrgatv
                         rel_tpdocmto
                         rel_flagcheq
                         craprcb.autchave
                         craprcb.cdagerel
                         WITH FRAME f_lista.
            DOWN STREAM str_1 WITH FRAME f_lista.

            IF  LAST-OF(craprcb.nrdcaixa) THEN
                DO:                       
                    DISPLAY STREAM str_1 
                           " " @ craprcb.nmarquiv 
                           " " @ craprcb.dtmvtolt              
                           " " @ craprcb.cdtransa
                           " " @ craprcb.hrdmovto
                           " " @ craprcb.dtdmovto
                           rel_vltotpag_cx  @ craprcb.valorpag
                           " " @ craprcb.cdagenci
                           " " @ craprcb.nrdcaixa
                           " " @ craprcb.formaliq
                           " " @ craprcb.flgrgatv
                           " " @ rel_tpdocmto
                           " " @ rel_flagcheq
                           " " @ craprcb.autchave
                           " " @ craprcb.cdagerel
                           WITH FRAME f_lista.
                    DOWN STREAM str_1 WITH FRAME f_lista.
                END.
                
            IF  LAST-OF(craprcb.cdagenci) THEN
                DO:                       
                    DISPLAY STREAM str_1 
                           " " @ craprcb.nmarquiv 
                           " " @ craprcb.dtmvtolt              
                           " " @ craprcb.cdtransa
                           " " @ craprcb.hrdmovto
                           " " @ craprcb.dtdmovto
                           rel_vltotpag  @ craprcb.valorpag
                           " " @ craprcb.cdagenci
                           " " @ craprcb.nrdcaixa
                           " " @ craprcb.formaliq
                           " " @ craprcb.flgrgatv
                           " " @ rel_tpdocmto
                           " " @ rel_flagcheq
                           " " @ craprcb.autchave
                           " " @ craprcb.cdagerel
                           WITH FRAME f_lista.
                    DOWN STREAM str_1 WITH FRAME f_lista.
                END.
        END.

        DISPLAY STREAM str_1 
                      " " @ craprcb.nmarquiv 
                      " " @ craprcb.dtmvtolt              
                      " " @ craprcb.cdtransa
                      " " @ craprcb.dtdmovto
                      " " @ craprcb.hrdmovto
                      rel_vltotpag_tt @ craprcb.valorpag
                      " " @ craprcb.cdagenci
                      " " @ craprcb.nrdcaixa
                      " " @ craprcb.formaliq
                      " " @ craprcb.flgrgatv
                      " " @ rel_tpdocmto
                      " " @ rel_flagcheq
                      " " @ craprcb.cdagerel
                            WITH FRAME f_lista.
            DOWN STREAM str_1 WITH FRAME f_lista.

        /* INSS */
        ASSIGN rel_vltotpag    = 0                                      
               rel_vltotpag_cx = 0                                         
               rel_vltotpag_tt = 0.
        
        VIEW STREAM str_1 FRAME f_cabrel.

       FOR EACH craprcb WHERE craprcb.cdcooper  = par_cdcooper   AND
                               craprcb.dtmvtolt  = par_dtmvtolx   AND
                              (craprcb.cdagenci >= par_cdagencx   AND
                               craprcb.cdagenci <= aux_cdagefim ) AND
                              (craprcb.nrdcaixa >= par_nrdcaixx   AND
                               craprcb.nrdcaixa <= aux_nrdcaixa)  AND
                               craprcb.cdtransa = "284"           NO-LOCK
                               BREAK BY craprcb.cdagenci
                                        BY craprcb.nrdcaixa
                                           BY craprcb.autchave:

            IF  LINE-COUNTER(str_1) >= (PAGE-SIZE(str_1) - 4)  THEN
                DO:
                    PAGE STREAM str_1.
                    VIEW STREAM str_1 FRAME f_cabrel132_1.
                END.
        
            IF  FIRST-OF (craprcb.cdagenci)   THEN
                DO:
                    ASSIGN rel_vltotpag = 0.
                    DISPLAY STREAM str_1  craprcb.cdagenci  WITH FRAME f_pac.
                    DOWN STREAM str_1 WITH FRAME f_pac.
                END.

            IF  FIRST-OF (craprcb.nrdcaixa)   THEN
                DO:
                    ASSIGN rel_vltotpag_cx = 0.
                    DISPLAY stream str_1  craprcb.nrdcaixa WITH FRAME f_caixa.
                END.
                
            ASSIGN rel_tpdocmto = IF  craprcb.cdtransa = '268' THEN "TITULO"
                                  ELSE 
                                  IF  craprcb.cdtransa = '358' THEN "FATURA"
                                  ELSE "INSS"
                   rel_flagcheq = IF   craprcb.formaliq = 2    THEN TRUE
                                  ELSE FALSE.
        
            IF  craprcb.flgrgatv  THEN
                ASSIGN rel_vltotpag    = rel_vltotpag    + craprcb.valorpag  
                       rel_vltotpag_cx = rel_vltotpag_cx + craprcb.valorpag
                       rel_vltotpag_tt = rel_vltotpag_tt + craprcb.valorpag.

            DISPLAY STREAM str_1 
                         craprcb.nmarquiv 
                         craprcb.dtmvtolt              
                         craprcb.cdtransa
                         STRING(craprcb.hrdmovto,"HH:MM:SS") @ craprcb.hrdmovto
                         craprcb.dtdmovto
                         craprcb.valorpag
                         craprcb.cdagenci
                         craprcb.nrdcaixa
                         craprcb.formaliq
                         craprcb.flgrgatv
                         rel_tpdocmto
                         rel_flagcheq
                         craprcb.autchave
                         craprcb.cdagerel
                         WITH FRAME f_lista.
            DOWN STREAM str_1 WITH FRAME f_lista.
                
            IF  LAST-OF(craprcb.nrdcaixa) THEN
                DO:
                    DISPLAY STREAM str_1 
                            " " @ craprcb.nmarquiv 
                            " " @ craprcb.dtmvtolt              
                            " " @ craprcb.cdtransa
                            " " @ craprcb.hrdmovto
                            " " @ craprcb.dtdmovto
                            rel_vltotpag_cx  @ craprcb.valorpag
                            " " @ craprcb.cdagenci
                            " " @ craprcb.nrdcaixa
                            " " @ craprcb.formaliq
                            " " @ craprcb.flgrgatv
                            " " @ rel_tpdocmto
                            " " @ rel_flagcheq
                            " " @ craprcb.autchave
                            " " @ craprcb.cdagerel
                            WITH FRAME f_lista.
                    DOWN STREAM str_1 WITH FRAME f_lista.
                END.
                    
            IF  LAST-OF(craprcb.cdagenci) THEN
                DO:                       
                    DISPLAY STREAM str_1 
                           " " @ craprcb.nmarquiv 
                           " " @ craprcb.dtmvtolt              
                           " " @ craprcb.cdtransa
                           " " @ craprcb.hrdmovto
                           " " @ craprcb.dtdmovto
                           rel_vltotpag  @ craprcb.valorpag
                           " " @ craprcb.cdagenci
                           " " @ craprcb.nrdcaixa
                           " " @ craprcb.formaliq
                           " " @ craprcb.flgrgatv
                           " " @ rel_tpdocmto
                           " " @ rel_flagcheq
                           " " @ craprcb.autchave
                           " " @ craprcb.cdagerel
                           WITH FRAME f_lista.
                    DOWN STREAM str_1 WITH FRAME f_lista.
                END.
        END.

        DISPLAY STREAM str_1
                      " " @ craprcb.nmarquiv
                      " " @ craprcb.dtmvtolt
                      " " @ craprcb.cdtransa
                      " " @ craprcb.dtdmovto
                      " " @ craprcb.hrdmovto
                      rel_vltotpag_tt @ craprcb.valorpag
                      " " @ craprcb.cdagenci
                      " " @ craprcb.nrdcaixa
                      " " @ craprcb.formaliq
                      " " @ craprcb.flgrgatv
                      " " @ rel_tpdocmto
                      " " @ rel_flagcheq
                      " " @ craprcb.cdagerel
                            WITH FRAME f_lista.
            DOWN STREAM str_1 WITH FRAME f_lista.

        PUT STREAM str_1 SKIP(PAGE-SIZE(str_1) - LINE-COUNTER(str_1)).
        
        DISPLAY STREAM str_1
                     tt-total.qttitrec
                     tt-total.vltitrec
                     tt-total.qttitliq
                     tt-total.vltitliq
                     tt-total.qttitcan
                     tt-total.vltitcan
                     tt-total.qtfatrec
                     tt-total.vlfatrec
                     tt-total.qtfatliq
                     tt-total.vlfatliq
                     tt-total.qtfatcan
                     tt-total.vlfatcan
                     tt-total.qtdinhei
                     tt-total.vldinhei
                     tt-total.qtinss
                     tt-total.vlinss
                     tt-total.qtcheque
                     tt-total.vlcheque
                     tt-total.vlrepasse  WITH FRAME f_total.
        
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

        ASSIGN aux_returnvl = "OK".
        
        LEAVE Imprime.

    END. /*Imprime*/
    
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

END. /* Lista_Faturas */

/* ------------------------------------------------------------------------ */
/*                                                   */
/* ------------------------------------------------------------------------ */
PROCEDURE Lista_Lotes:
         
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolx AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_registro AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_inss     AS LOGI                           NO-UNDO.
    
    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmendter AS CHAR                                    NO-UNDO.
    DEF VAR aux_dscritix AS CHAR FORMAT "x(40)"                     NO-UNDO.
    DEF VAR aux_flgexist AS LOGI INITIAL FALSE                      NO-UNDO.
    DEF VAR aux_cdagefim AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdcaixa AS INTE                                    NO-UNDO.

    DEF VAR aux_qtpalavr AS INTE                                    NO-UNDO.
    DEF VAR aux_contapal AS INTE                                    NO-UNDO.

    DEF VAR rel_vltotpag    AS DECIMAL  FORMAT "zzz,zzz,zz9.99"     NO-UNDO.
    DEF VAR rel_vltotpag_cx AS DECIMAL  FORMAT "zzz,zzz,zz9.99"     NO-UNDO.
    DEF VAR rel_vltotpag_tt AS DECIMAL  FORMAT "zzz,zzz,zz9.99"     NO-UNDO.
    DEF VAR rel_qttotpag    AS INT                                  NO-UNDO.
    DEF VAR rel_qttotpag_cx AS INT                                  NO-UNDO.
    DEF VAR rel_qttotpag_tt AS INT                                  NO-UNDO.
    
    /* cancelados */
    DEF VAR rel_vltotcan    AS DECIMAL  FORMAT "zzz,zzz,zz9.99"     NO-UNDO.
    DEF VAR rel_vltotcan_cx AS DECIMAL  FORMAT "zzz,zzz,zz9.99"     NO-UNDO.
    DEF VAR rel_vltotcan_tt AS DECIMAL  FORMAT "zzz,zzz,zz9.99"     NO-UNDO.
    DEF VAR rel_qttotcan    AS INT                                  NO-UNDO.
    DEF VAR rel_qttotcan_cx AS INT                                  NO-UNDO.
    DEF VAR rel_qttotcan_tt AS INT                                  NO-UNDO.
    
    DEF VAR rel_tpdocmto    AS CHAR                                 NO-UNDO.
    DEF VAR rel_flagcheq    AS LOGICAL FORMAT "S/N"                 NO-UNDO.
    DEF VAR rel_ddmvtolt    AS INT     FORMAT "99"                  NO-UNDO.
    DEF VAR rel_aamvtolt    AS INT     FORMAT "9999"                NO-UNDO.
    DEF VAR rel_nmressbr    AS CHAR    EXTENT 2 FORMAT "x(60)"      NO-UNDO.
    DEF VAR rel_mmmvtolt    AS CHAR    FORMAT "x(17)"  EXTENT 12 
                                    INIT["de  Janeiro  de","de Fevereiro de",
                                         "de   Marco   de","de   Abril   de",
                                         "de   Maio    de","de   Junho   de",
                                         "de   Julho   de","de   Agosto  de",
                                         "de  Setembro de","de  Outubro  de",
                                         "de  Novembro de","de  Dezembro de"]
                                                                    NO-UNDO.

    DEF VAR aux_nmoperad AS CHAR    FORMAT "x(20)"                  NO-UNDO.

    /* valor por extenso */
    DEF     VAR rel_vlextens    AS CHAR     EXTENT 2                NO-UNDO.
    /* tipo de documento */
    DEF     VAR rel_dsdocmto    AS CHAR                             NO-UNDO.

    FORM "PA - " crapcbb.cdagenci
         SKIP(1)
         WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_pac.
         
    FORM "CAIXA - " crapcbb.nrdcaixa
         SKIP(1)
         WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_caixa.
         
    FORM 
       crapcbb.nrdolote   COLUMN-LABEL "Lote"
       rel_tpdocmto       COLUMN-LABEL "Tp.Docto"
       rel_flagcheq       COLUMN-LABEL "Cheque"
       crapcbb.valordoc   COLUMN-LABEL "Valor Docto"     FORMAT "z,zzz,zz9.99" 
       crapcbb.vldescto   COLUMN-LABEL "Valor Descto"    
       crapcbb.valorpag   COLUMN-LABEL "Valor Pago"      FORMAT "z,zzz,zz9.99"
       crapcbb.dtmvtolt   COLUMN-LABEL "Data Trans"      FORMAT "99/99/99"
       crapcbb.dtvencto   COLUMN-LABEL "Data Vencimento" FORMAT "99/99/99"
       crapcbb.nrautdoc   COLUMN-LABEL "Autent."
       crapcbb.autchave   COLUMN-LABEL "SEQ"
       crapcbb.flgrgatv   COLUMN-LABEL "Ativo"
       aux_nmoperad       COLUMN-LABEL "Operador"
       SKIP
       WITH DOWN NO-BOX  WIDTH 132 FRAME f_valores.

    DEF BUFFER crabcop FOR crapcop.

    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crabcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        ASSIGN aux_cdagefim = IF   par_cdagencx = 0 THEN 9999
                              ELSE par_cdagencx
               aux_nrdcaixa = IF   par_nrdcaixx = 0 THEN 999
                              ELSE par_nrdcaixx.

        ASSIGN aux_nmendter = "/usr/coop/" + crabcop.dsdircop + "/rl/" +
                              par_dsiduser.
        
        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

        IF  par_registro = ?   THEN
            DO:   /* Relatorio Normal */

                /* Cdempres = 11 , Relatorio 366 em 132 colunas */
                { sistema/generico/includes/cabrel.i "11" "365" "132" }


                FOR EACH crapcbb WHERE  crapcbb.cdcooper  = par_cdcooper AND
                                        crapcbb.dtmvtolt  = par_dtmvtolx AND 
                                        crapcbb.cdagenci >= par_cdagencx AND
                                        crapcbb.cdagenci <= aux_cdagefim AND
                                        crapcbb.nrdcaixa >= par_nrdcaixx AND
                                        crapcbb.nrdcaixa <= aux_nrdcaixa AND
                                        crapcbb.tpdocmto < 3         NO-LOCK,
                                   
                    FIRST crapope WHERE crapope.cdcooper = par_cdcooper AND
                                        crapope.cdoperad = crapcbb.cdopecxa
                                        NO-LOCK
                                      
                                BREAK BY crapcbb.cdagenci
                                         BY crapcbb.nrdcaixa
                                            BY crapcbb.nrdolote
                                               BY crapcbb.flgrgatv  DESCENDING
                                                  BY crapcbb.autchave
                                                     BY crapcbb.dtvencto
                                                        BY crapcbb.tpdocmto 
                                                           BY crapcbb.nrautdoc:

                    IF  LINE-COUNTER(str_1) >= (PAGE-SIZE(str_1) - 4)  THEN
                        DO:
                            PAGE STREAM str_1.
                            VIEW STREAM str_1 FRAME f_cabrel.
                        END.

                    IF  FIRST-OF (crapcbb.cdagenci) THEN
                        DO:
                            ASSIGN rel_vltotpag = 0
                                   rel_qttotpag = 0
                                   rel_vltotcan = 0
                                   rel_qttotcan = 0.
                            DISPLAY STREAM str_1 crapcbb.cdagenci 
                                                              WITH FRAME f_pac.
                            DOWN STREAM str_1 WITH FRAME f_pac.
                        END.

                    IF  FIRST-OF (crapcbb.nrdcaixa)   THEN
                        DO:
                            ASSIGN rel_vltotpag_cx = 0
                                   rel_qttotpag_cx = 0
                                   rel_vltotcan_cx = 0
                                   rel_qttotcan_cx = 0.
                           
                            DISPLAY STREAM str_1 crapcbb.nrdcaixa 
                                                            WITH FRAME f_caixa.
                        END.
             
                    IF  FIRST-OF (crapcbb.flgrgatv) AND
                        NOT crapcbb.flgrgatv THEN
                        PUT STREAM str_1 SKIP(3)
                                         "CANCELADOS"
                                         SKIP(2).

                    ASSIGN rel_tpdocmto = IF  crapcbb.tpdocmto = 1 THEN 
                                               "TITULO"
                                          ELSE 
                                          IF  crapcbb.tpdocmto = 2 THEN 
                                               "FATURA"
                                          ELSE "INSS"

                           rel_flagcheq = IF  crapcbb.dsdocmc7 <> " " THEN 
                                               TRUE
                                          ELSE FALSE

                           aux_nmoperad = crapcbb.cdopecxa + "-" + 
                                          crapope.nmoperad.
                                          
                    DISPLAY STREAM str_1  crapcbb.nrdolote  
                                          rel_tpdocmto  
                                          rel_flagcheq 
                                          crapcbb.valordoc 
                                          crapcbb.valorpag
                                          crapcbb.dtmvtolt
                                          crapcbb.dtvencto
                                          crapcbb.nrautdoc 
                                          crapcbb.flgrgatv 
                                          crapcbb.vldescto
                                          crapcbb.autchave
                                          aux_nmoperad
                                          WITH FRAME f_valores.
                    DOWN STREAM str_1 WITH FRAME f_valores.

                    /* ativos */
                    IF  crapcbb.flgrgatv THEN
                        ASSIGN rel_vltotpag = rel_vltotpag + crapcbb.valorpag
                               rel_vltotpag_cx = 
                                           rel_vltotpag_cx + crapcbb.valorpag
                               rel_vltotpag_tt = 
                                           rel_vltotpag_tt + crapcbb.valorpag
                               rel_qttotpag    = rel_qttotpag    + 1
                               rel_qttotpag_cx = rel_qttotpag_cx + 1
                               rel_qttotpag_tt = rel_qttotpag_tt + 1.
                    ELSE  /* cancelados */
                    IF  LAST-OF(crapcbb.nrautdoc) THEN
                        ASSIGN rel_vltotcan = rel_vltotcan + crapcbb.valorpag
                               rel_vltotcan_cx = 
                                           rel_vltotcan_cx + crapcbb.valorpag
                               rel_vltotcan_tt = 
                                           rel_vltotcan_tt + crapcbb.valorpag
                               rel_qttotcan    = rel_qttotcan    + 1
                               rel_qttotcan_cx = rel_qttotcan_cx + 1
                               rel_qttotcan_tt = rel_qttotcan_tt + 1.

                    /* total de ativos do caixa */
                    IF  LAST-OF (crapcbb.flgrgatv) AND crapcbb.flgrgatv  THEN
                        DO:
                            DISPLAY STREAM str_1 
                                          " " @ crapcbb.nrdolote  
                                          " " @ rel_tpdocmto  
                                          " " @ rel_flagcheq 
                                          " " @ crapcbb.valordoc 
                                          rel_vltotpag_cx @ crapcbb.valorpag
                                          "  Lanctos:"    @ crapcbb.dtmvtolt
                                          rel_qttotpag_cx @ crapcbb.dtvencto
                                          " " @ crapcbb.nrautdoc 
                                          " " @ crapcbb.flgrgatv 
                                          "Tot.Caixa(Ativ)" @ crapcbb.vldescto
                                          " " @ crapcbb.autchave
                                          " " @ aux_nmoperad
                                          WITH FRAME f_valores.
                            DOWN STREAM str_1 WITH FRAME f_valores.
                        END.

                    /* total de cancelados do caixa */
                    IF  LAST-OF (crapcbb.flgrgatv) AND
                        NOT crapcbb.flgrgatv THEN
                        DO:
                            DISPLAY STREAM str_1 
                                          " " @ crapcbb.nrdolote  
                                          " " @ rel_tpdocmto  
                                          " " @ rel_flagcheq 
                                          " " @ crapcbb.valordoc 
                                          rel_vltotcan_cx @ crapcbb.valorpag
                                          "  Lanctos:"    @ crapcbb.dtmvtolt
                                          rel_qttotcan_cx @ crapcbb.dtvencto
                                          " " @ crapcbb.nrautdoc 
                                          " " @ crapcbb.flgrgatv 
                                          "Tot.Caixa(Canc)" @ crapcbb.vldescto
                                          " " @ crapcbb.autchave
                                          " " @ aux_nmoperad
                                          WITH FRAME f_valores.
                            DOWN STREAM str_1 WITH FRAME f_valores.
                        END.

                    IF  LAST-OF (crapcbb.cdagenci)   THEN
                        DO:
                            DOWN 2 STREAM str_1 WITH FRAME f_valores.
                        
                            /* total ativo do PAC */
                            DISPLAY STREAM str_1 
                                           " " @ crapcbb.nrdolote  
                                           " " @ rel_tpdocmto  
                                           " " @ rel_flagcheq 
                                           " " @ crapcbb.valordoc 
                                           rel_vltotpag @ crapcbb.valorpag
                                           "  Lanctos:" @ crapcbb.dtmvtolt
                                           rel_qttotpag @ crapcbb.dtvencto
                                           " " @ crapcbb.nrautdoc 
                                           " " @ crapcbb.flgrgatv 
                                           "Tot.PA(Ativ)"  @ crapcbb.vldescto
                                           " " @ crapcbb.autchave
                                           " " @ aux_nmoperad
                                           WITH FRAME f_valores.
                            DOWN STREAM str_1 WITH FRAME f_valores.
                    
                            /* total cancelado do pac */
                            DISPLAY STREAM str_1 
                                          " " @ crapcbb.nrdolote  
                                          " " @ rel_tpdocmto  
                                          " " @ rel_flagcheq 
                                          " " @ crapcbb.valordoc 
                                          rel_vltotcan @ crapcbb.valorpag
                                          "  Lanctos:" @ crapcbb.dtmvtolt
                                          rel_qttotcan @ crapcbb.dtvencto
                                          " " @ crapcbb.nrautdoc 
                                          " " @ crapcbb.flgrgatv 
                                          "Tot.PA(Canc)"  @ crapcbb.vldescto
                                          " " @ crapcbb.autchave
                                          " " @ aux_nmoperad
                                          WITH FRAME f_valores.
                            DOWN STREAM str_1 WITH FRAME f_valores.
    
                        END.
                END.

                DOWN 2 STREAM str_1 WITH FRAME f_valores.
                /* total geral dos ativos */
                DISPLAY STREAM str_1 
                               " " @ crapcbb.nrdolote  
                               " " @ rel_tpdocmto  
                               " " @ rel_flagcheq 
                               " " @ crapcbb.valordoc 
                               rel_vltotpag_tt    @ crapcbb.valorpag
                               "  Lanctos:"       @ crapcbb.dtmvtolt
                               rel_qttotpag_tt    @ crapcbb.dtvencto
                               " " @ crapcbb.nrautdoc 
                               " " @ crapcbb.flgrgatv 
                               "Tot.Geral(Ativ)"  @ crapcbb.vldescto
                               " " @ crapcbb.autchave
                               " " @ aux_nmoperad
                               WITH FRAME f_valores.
                DOWN STREAM str_1 WITH FRAME f_valores.
    
                /* total geral dos cancelados */
                DISPLAY STREAM str_1 
                               " " @ crapcbb.nrdolote  
                               " " @ rel_tpdocmto  
                               " " @ rel_flagcheq 
                               " " @ crapcbb.valordoc 
                               rel_vltotcan_tt    @ crapcbb.valorpag
                               "  Lanctos:"       @ crapcbb.dtmvtolt
                               rel_qttotcan_tt    @ crapcbb.dtvencto
                               " " @ crapcbb.nrautdoc 
                               " " @ crapcbb.flgrgatv 
                               "Tot.Geral(Canc)"  @ crapcbb.vldescto
                               " " @ crapcbb.autchave
                               " " @ aux_nmoperad
                               WITH FRAME f_valores.
                DOWN STREAM str_1 WITH FRAME f_valores.

                DISPLAY STREAM str_1 " ".

                /* Listar INSS */
                ASSIGN  rel_vltotpag     = 0
                        rel_vltotpag_cx  = 0
                        rel_vltotpag_tt  = 0
                        rel_qttotpag     = 0
                        rel_qttotpag_cx  = 0
                        rel_qttotpag_tt  = 0 
                        rel_vltotcan     = 0    
                        rel_vltotcan_cx  = 0
                        rel_vltotcan_tt  = 0
                        rel_qttotcan     = 0
                        rel_qttotcan_cx  = 0
                        rel_qttotcan_tt  = 0.
    
                VIEW STREAM str_1 FRAME f_cabrel.

                FOR EACH crapcbb WHERE crapcbb.cdcooper  = par_cdcooper AND
                                       crapcbb.dtmvtolt  = par_dtmvtolx AND 
                                       crapcbb.cdagenci >= par_cdagencx AND
                                       crapcbb.cdagenci <= aux_cdagefim AND
                                       crapcbb.nrdcaixa >= par_nrdcaixx AND
                                       crapcbb.nrdcaixa <= aux_nrdcaixa AND
                                       crapcbb.tpdocmto = 3             AND
                                       par_inss                    NO-LOCK,
                        
                    FIRST crapope WHERE crapope.cdcooper = par_cdcooper AND
                                        crapope.cdoperad = crapcbb.cdopecxa

                                BREAK BY crapcbb.cdagenci
                                         BY crapcbb.nrdcaixa
                                            BY crapcbb.nrdolote
                                               BY crapcbb.flgrgatv  DESCENDING
                                                  BY crapcbb.autchave
                                                     BY crapcbb.dtvencto
                                                        BY crapcbb.tpdocmto
                                                           BY crapcbb.nrautdoc:

                    IF  LINE-COUNTER(str_1) >= (PAGE-SIZE(str_1) - 4)  THEN
                        DO:
                            PAGE STREAM str_1.
                            VIEW STREAM str_1 FRAME f_cabrel.
                        END.
    
                    IF  FIRST-OF (crapcbb.cdagenci) THEN
                        DO:
                            ASSIGN rel_vltotpag = 0
                                   rel_qttotpag = 0
                                   rel_vltotcan = 0
                                   rel_qttotcan = 0.
                            DISPLAY STREAM str_1 crapcbb.cdagenci 
                                                              WITH FRAME f_pac.
                            DOWN STREAM str_1 WITH FRAME f_pac.
                        END.

                    IF  FIRST-OF (crapcbb.nrdcaixa) THEN
                        DO:
                            ASSIGN rel_vltotpag_cx = 0
                                   rel_qttotpag_cx = 0
                                   rel_vltotcan_cx = 0
                                   rel_qttotcan_cx = 0.
                           
                            DISPLAY STREAM str_1 crapcbb.nrdcaixa 
                                                            WITH FRAME f_caixa.
                        END.
             
                    IF  FIRST-OF (crapcbb.flgrgatv) AND
                        NOT crapcbb.flgrgatv  THEN
                        PUT STREAM str_1 SKIP(3)
                                         "CANCELADOS"
                                         SKIP(2).

                    ASSIGN rel_tpdocmto = IF  crapcbb.tpdocmto = 1 THEN 
                                              "TITULO"
                                          ELSE 
                                          IF  crapcbb.tpdocmto = 2 THEN 
                                              "FATURA"
                                          ELSE "INSS"

                           rel_flagcheq = IF  crapcbb.dsdocmc7 <> " " THEN 
                                               TRUE
                                          ELSE FALSE

                           aux_nmoperad = crapcbb.cdopecxa + "-" + 
                                          crapope.nmoperad.

                    DISPLAY STREAM str_1  crapcbb.nrdolote  
                                          rel_tpdocmto  
                                          rel_flagcheq 
                                          crapcbb.valordoc 
                                          crapcbb.valorpag
                                          crapcbb.dtmvtolt
                                          crapcbb.dtvencto
                                          crapcbb.nrautdoc 
                                          crapcbb.flgrgatv 
                                          crapcbb.vldescto
                                          crapcbb.autchave
                                          aux_nmoperad
                                          WITH FRAME f_valores.
                    DOWN STREAM str_1 WITH FRAME f_valores.
        
                    /* ativos */
                    IF  crapcbb.flgrgatv = TRUE   THEN
                        ASSIGN rel_vltotpag = rel_vltotpag + crapcbb.valorpag
                               rel_vltotpag_cx = 
                                           rel_vltotpag_cx + crapcbb.valorpag
                               rel_vltotpag_tt = 
                                           rel_vltotpag_tt + crapcbb.valorpag
                               rel_qttotpag    = rel_qttotpag    + 1
                               rel_qttotpag_cx = rel_qttotpag_cx + 1
                               rel_qttotpag_tt = rel_qttotpag_tt + 1.

                    ELSE /* cancelados */
                    IF  LAST-OF(crapcbb.nrautdoc)   THEN
                        ASSIGN rel_vltotcan = rel_vltotcan + crapcbb.valorpag
                               rel_vltotcan_cx = rel_vltotcan_cx + 
                                                             crapcbb.valorpag
                               rel_vltotcan_tt = rel_vltotcan_tt + 
                                                             crapcbb.valorpag
                               rel_qttotcan    = rel_qttotcan    + 1
                               rel_qttotcan_cx = rel_qttotcan_cx + 1
                               rel_qttotcan_tt = rel_qttotcan_tt + 1.

                    /* total de ativos do caixa */
                    IF  LAST-OF (crapcbb.flgrgatv)   AND
                        crapcbb.flgrgatv = YES       THEN
                        DO:
                            DISPLAY STREAM str_1 
                                          " " @ crapcbb.nrdolote  
                                          " " @ rel_tpdocmto  
                                          " " @ rel_flagcheq 
                                          " " @ crapcbb.valordoc 
                                          rel_vltotpag_cx @ crapcbb.valorpag
                                          "  Lanctos:"    @ crapcbb.dtmvtolt
                                          rel_qttotpag_cx @ crapcbb.dtvencto
                                          " " @ crapcbb.nrautdoc 
                                          " " @ crapcbb.flgrgatv 
                                          "Tot.Caixa(Ativ)" @ crapcbb.vldescto
                                          " " @ crapcbb.autchave
                                          " " @ aux_nmoperad
                                          WITH FRAME f_valores.
                            DOWN STREAM str_1 WITH FRAME f_valores.
                        END.

                    /* total de cancelados do caixa */
                    IF  LAST-OF (crapcbb.flgrgatv) AND
                        crapcbb.flgrgatv = NO THEN
                        DO:
                            DISPLAY STREAM str_1 
                                          " " @ crapcbb.nrdolote  
                                          " " @ rel_tpdocmto  
                                          " " @ rel_flagcheq 
                                          " " @ crapcbb.valordoc 
                                          rel_vltotcan_cx @ crapcbb.valorpag
                                          "  Lanctos:"    @ crapcbb.dtmvtolt
                                          rel_qttotcan_cx @ crapcbb.dtvencto
                                          " " @ crapcbb.nrautdoc 
                                          " " @ crapcbb.flgrgatv 
                                          "Tot.Caixa(Canc)" @ crapcbb.vldescto
                                          " " @ crapcbb.autchave
                                          " " @ aux_nmoperad
                                          WITH FRAME f_valores.
                            DOWN STREAM str_1 WITH FRAME f_valores.
                        END.

                    IF  LAST-OF (crapcbb.cdagenci)   THEN
                        DO:
                            DOWN 2 STREAM str_1 WITH FRAME f_valores.
                        
                            /* total ativo do PAC */
                            DISPLAY STREAM str_1 
                                           " " @ crapcbb.nrdolote  
                                           " " @ rel_tpdocmto  
                                           " " @ rel_flagcheq 
                                           " " @ crapcbb.valordoc 
                                           rel_vltotpag @ crapcbb.valorpag
                                           "  Lanctos:" @ crapcbb.dtmvtolt
                                           rel_qttotpag @ crapcbb.dtvencto
                                           " " @ crapcbb.nrautdoc 
                                           " " @ crapcbb.flgrgatv 
                                           "Tot.PA(Ativ)"  @ crapcbb.vldescto
                                           " " @ crapcbb.autchave
                                           " " @ aux_nmoperad
                                           WITH FRAME f_valores.
                            DOWN STREAM str_1 WITH FRAME f_valores.
                
                            /* total cancelado do pac */
                            DISPLAY STREAM str_1 
                                          " " @ crapcbb.nrdolote  
                                          " " @ rel_tpdocmto  
                                          " " @ rel_flagcheq 
                                          " " @ crapcbb.valordoc 
                                          rel_vltotcan @ crapcbb.valorpag
                                          "  Lanctos:" @ crapcbb.dtmvtolt
                                          rel_qttotcan @ crapcbb.dtvencto
                                          " " @ crapcbb.nrautdoc 
                                          " " @ crapcbb.flgrgatv 
                                          "Tot.PA(Canc)"  @ crapcbb.vldescto
                                          " " @ crapcbb.autchave
                                          " " @ aux_nmoperad
                                          WITH FRAME f_valores.
                            DOWN STREAM str_1 WITH FRAME f_valores.
                        END.  
                END.

                DOWN 2 STREAM str_1 WITH FRAME f_valores.
    
                /* total geral dos ativos */
                DISPLAY STREAM str_1 
                               " " @ crapcbb.nrdolote  
                               " " @ rel_tpdocmto  
                               " " @ rel_flagcheq 
                               " " @ crapcbb.valordoc 
                               rel_vltotpag_tt    @ crapcbb.valorpag
                               "  Lanctos:"       @ crapcbb.dtmvtolt
                               rel_qttotpag_tt    @ crapcbb.dtvencto
                               " " @ crapcbb.nrautdoc 
                               " " @ crapcbb.flgrgatv 
                               "Tot.Geral(Ativ)"  @ crapcbb.vldescto
                               " " @ crapcbb.autchave
                               " " @ aux_nmoperad
                               WITH FRAME f_valores.
                DOWN STREAM str_1 WITH FRAME f_valores.
        
                /* total geral dos cancelados */
                DISPLAY STREAM str_1 
                               " " @ crapcbb.nrdolote  
                               " " @ rel_tpdocmto  
                               " " @ rel_flagcheq 
                               " " @ crapcbb.valordoc 
                               rel_vltotcan_tt    @ crapcbb.valorpag
                               "  Lanctos:"       @ crapcbb.dtmvtolt
                               rel_qttotcan_tt    @ crapcbb.dtvencto
                               " " @ crapcbb.nrautdoc 
                               " " @ crapcbb.flgrgatv 
                               "Tot.Geral(Canc)"  @ crapcbb.vldescto
                               " " @ crapcbb.autchave
                               " " @ aux_nmoperad
                               WITH FRAME f_valores.
                DOWN STREAM str_1 WITH FRAME f_valores.
    
                DISPLAY STREAM str_1 " ".
    
            END.
        ELSE
            DO:
                /* solicitacao de restituicao */
                FIND crapcbb WHERE ROWID(crapcbb) = par_registro 
                                                             NO-LOCK NO-ERROR.

                IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                    RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
                    
                IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                    DO:
                        ASSIGN aux_dscritic = 
                                         "Handle invalido para BO b1wgen9999.".
                               
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                        
                        RETURN "NOK".
                    END.
            
                RUN valor-extenso IN h-b1wgen9999 (INPUT crapcbb.valorpag,
                                                   INPUT 25,
                                                   INPUT 74,
                                                   INPUT "M",
                                                   OUTPUT rel_vlextens[1],
                                                   OUTPUT rel_vlextens[2]).
        
                IF  VALID-HANDLE(h-b1wgen9999)  THEN
                    DELETE PROCEDURE h-b1wgen9999.
                
                /******* Divide o campo crapcop.nmextcop em duas Strings *****/
                ASSIGN aux_qtpalavr = 
                                    NUM-ENTRIES(TRIM(crabcop.nmextcop)," ") / 2
                       rel_nmressbr = "".
                
                DO aux_contapal = 1 TO NUM-ENTRIES(TRIM(crabcop.nmextcop)," "):
                    IF  aux_contapal <= aux_qtpalavr   THEN
                        rel_nmressbr[1] = rel_nmressbr[1] +
                            (IF TRIM(rel_nmressbr[1]) = "" THEN "" ELSE " ") 
                            + ENTRY(aux_contapal,crabcop.nmextcop," ").
                    ELSE
                        rel_nmressbr[2] = rel_nmressbr[2] +
                            (IF TRIM(rel_nmressbr[2]) = "" THEN "" ELSE " ")
                            + ENTRY(aux_contapal,crabcop.nmextcop," ").
                END.  /*  Fim DO .. TO  */ 

                IF  crapcbb.tpdocmto = 1 THEN
                    ASSIGN rel_dsdocmto = "do  Titulo".
                ELSE
                IF  crapcbb.tpdocmto = 2   THEN
                    ASSIGN rel_dsdocmto = "da  Fatura".
                ELSE
                    ASSIGN rel_dsdocmto = "         ".
                
                ASSIGN rel_ddmvtolt = DAY(par_dtmvtolt)
                       rel_aamvtolt = YEAR(par_dtmvtolt).

                PUT STREAM str_1 "\022\024\033\120"     /* Reseta impressora */
                            SKIP(5)
                            crabcop.nmextcop                              AT 6
                            SKIP(8)                                      
                            "Ao BANCO DO BRASIL,"                         AT 6
                            SKIP(10)                                     
                            "Solicitamos a restituicao do valor R$ "      AT 6
                            "\033\105"                                   
                            crapcbb.valorpag FORMAT "zzz,zz9.99"         
                            "\033\106"                                   
                            " (" rel_vlextens[1] FORMAT "x(25)"          
                            SKIP(1)                                      
                            rel_vlextens[2]      FORMAT "x(74)"           AT 6
                            ")"
                            SKIP(1)
                            "referente  ao  pagamento  em  duplicidade  " AT 6
                            rel_dsdocmto         FORMAT "x(10)"
                            ",  codigo  de   barras"
                            SKIP(1)
                            crapcbb.cdbarras                              AT 6
                            ",  efetuado  em  "
                            crapcbb.dtmvtolt
                            "  na"
                            SKIP(1)
                            "loja "                                       AT 6
                            (crapcbb.cdagenci + 100) FORMAT "zz9"
                            ", caixa "
                            crapcbb.nrdcaixa         FORMAT "z9"
                            "."
                            SKIP(15)
                            "Atenciosamente,"                             AT 6
                            SKIP(7)                                    
                            TRIM(crabcop.nmcidade)                        AT 6
                            " " rel_ddmvtolt   " "                      
                            rel_mmmvtolt[MONTH(par_dtmvtolt)]           
                            rel_aamvtolt                                
                            "."                                         
                            " "                                           AT 6
                            " "                                           AT 6
                            " "                                           AT 6
                            "______________________________"              AT 6
                            SKIP                                        
                            rel_nmressbr[1]                               AT 6
                            SKIP                                        
                            rel_nmressbr[2]                               AT 6
                            SKIP.
                
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

            ASSIGN aux_returnvl = "OK".

            LEAVE Imprime.

    END. /*Imprime*/
    
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

END. /* Lista_Lotes */

/*............................ PROCEDURES INTERNAS ..........................*/

/* ------------------------------------------------------------------------- */
/*          Procedure para criar registro de uma mensagem de alerta          */
/* ------------------------------------------------------------------------- */
PROCEDURE cria-registro-msg:
    
    DEF  INPUT PARAM par_dsmensag AS CHAR                           NO-UNDO.

    CREATE tt-mensagens.
    ASSIGN aux_nrsequen = aux_nrsequen + 1
           tt-mensagens.nrsequen = aux_nrsequen
           tt-mensagens.dsmensag = par_dsmensag.

    RETURN "OK".
           
END PROCEDURE.

PROCEDURE processa_arquivos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmarquiv AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flggeren AS LOGI                           NO-UNDO.

    DEF BUFFER crabrcb FOR craprcb.

    DEF VAR aux_setlinha       AS CHAR FORMAT "x(80)"                NO-UNDO.
    DEF VAR aux_dia            AS INTE                               NO-UNDO.
    DEF VAR aux_mes            AS INTE                               NO-UNDO.
    DEF VAR aux_ano            AS INTE                               NO-UNDO.
    DEF VAR aux_datadarq       AS DATE                               NO-UNDO.
    DEF VAR aux_nrseqarq       AS INTE                               NO-UNDO.
    DEF VAR aux_iniarquiv      AS INTE                               NO-UNDO.
    DEF VAR aux_nmarqdat_salvo AS CHAR                               NO-UNDO.

    
    /*---- Importar Informacoes ---*/

    INPUT STREAM str_2 FROM VALUE(par_nmarquiv) NO-ECHO.

    SET STREAM str_2 aux_setlinha  WITH FRAME AA WIDTH 80.

    IF  SUBSTR(aux_setlinha,1,1) =  "0"  THEN  /* Header do Arquivo */
        DO:       
           ASSIGN aux_dia      = INT(SUBSTR(aux_setlinha,11,2))
                  aux_mes      = INT(SUBSTR(aux_setlinha,9,2))
                  aux_ano      = INT(SUBSTR(aux_setlinha,5,4))
                  aux_datadarq = DATE(aux_mes,aux_dia,aux_ano).

           ASSIGN aux_nrseqarq = INT(SUBSTR(aux_setlinha,28,9)).
        END.
        
    FOR FIRST crabrcb WHERE crabrcb.cdcooper = par_cdcooper AND
                            crabrcb.datadarq = aux_datadarq AND
                            crabrcb.nrseqarq = aux_nrseqarq NO-LOCK: END.

    IF  NOT AVAIL crabrcb THEN
        DO: 
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 241.
       
                IF  SUBSTR(aux_setlinha,1,1) = "1" THEN /* DETALHE 1 */
                    DO: 
              
                        CREATE tt-movtos.
              
                        ASSIGN tt-movtos.datadarq  = aux_datadarq
                               tt-movtos.nrseqarq  = aux_nrseqarq
                               tt-movtos.nmarquivo = par_nmarquiv.
  
                        ASSIGN aux_dia      = INT(SUBSTR(aux_setlinha,11,2))
                               aux_mes      = INT(SUBSTR(aux_setlinha,9,2))
                               aux_ano      = INT(SUBSTR(aux_setlinha,5,4))
                               tt-movtos.dtmvtolt = 
                                                  DATE(aux_mes,aux_dia,aux_ano)
                        
                               tt-movtos.cdchaveb = SUBSTR(aux_setlinha,17,8)
                               tt-movtos.autchave = 
                                                 INT(SUBSTR(aux_setlinha,25,4))
                               tt-movtos.cdtransa = SUBSTR(aux_setlinha,29,3)
                               tt-movtos.cdagerel = 
                                                 INT(SUBSTR(aux_setlinha,13,4))
                               aux_dia      = INT(SUBSTR(aux_setlinha,38,2))
                               aux_mes      = INT(SUBSTR(aux_setlinha,36,2))
                               aux_ano      = INT(SUBSTR(aux_setlinha,32,4))
                               tt-movtos.dtmovto = 
                                                  DATE(aux_mes,aux_dia,aux_ano)
                               tt-movtos.hora  = INT(SUBSTR(aux_setlinha,40,6))
                        
                               tt-movtos.valorpag = 
                                         (DEC(SUBSTR(aux_setlinha,46,17))/ 100)
                               tt-movtos.cdagenci = 
                                                 INT(SUBSTR(aux_setlinha,63,4))
                               tt-movtos.nrdcaixa = 
                                                 INT(SUBSTR(aux_setlinha,67,4))
                               tt-movtos.formaliq = 
                                                 INT(SUBSTR(aux_setlinha,71,2))
                               tt-movtos.flgrgatv = 
                                                INT(SUBSTR(aux_setlinha,73,3)).
                    END.
        
                IF  SUBSTR(aux_setlinha,1,1) = "2" THEN  /* Detalhe 2 */
                    ASSIGN tt-movtos.cdbarras = SUBSTR(aux_setlinha,5,45).
 
/*                 IF  SUBSTR(aux_setlinha,1,1) = "9" THEN /* Totais registros */ */
/*                     ASSIGN aux_tot_registro = DEC(SUBSTR(aux_setlinha,5,15)).  */
    
            END. /* DO WHILE TRUE  - processando um arquivo  */

        END.
    
    INPUT STREAM str_2 CLOSE.

    FOR EACH  tt-movtos NO-LOCK:
        
        CREATE craprcb. 
        ASSIGN craprcb.datadarq = tt-movtos.datadarq
               craprcb.nrseqarq = tt-movtos.nrseqarq
               craprcb.nmarquiv = tt-movtos.nmarquivo
               craprcb.dtmvtolt = tt-movtos.dtmvtolt
               craprcb.cdchaveb = tt-movtos.cdchaveb
               craprcb.cdtransa = tt-movtos.cdtransa
               craprcb.dtdmovto = tt-movtos.dtmovto
               craprcb.valorpag = tt-movtos.valorpag
               craprcb.cdagenci = tt-movtos.cdagenci
               craprcb.nrdcaixa = tt-movtos.nrdcaixa
               craprcb.formaliq = tt-movtos.formaliq
               craprcb.cdbarras = tt-movtos.cdbarras
               craprcb.hrdmovto = tt-movtos.hora
               craprcb.autchave = tt-movtos.autchave
               craprcb.cdagerel = tt-movtos.cdagerel
               craprcb.cdcooper = par_cdcooper.

        IF  tt-movtos.flgrgatv <> 3 THEN
            ASSIGN craprcb.flgrgatv = YES.
        ELSE
            ASSIGN craprcb.flgrgatv = NO.

        VALIDATE craprcb.
    END.           

    EMPTY TEMP-TABLE tt-movtos.
              
    ASSIGN aux_iniarquiv = LENGTH(TRIM(par_nmarquiv)) - 11. 
    ASSIGN aux_nmarqdat_salvo = "salvar/" + 
                                SUBSTR(par_nmarquiv,aux_iniarquiv,8) + 
                                "." +
                                STRING(YEAR(par_dtmvtolt),"9999") +
                                STRING(MONTH(par_dtmvtolt),"99") +
                                STRING(DAY(par_dtmvtolt),"99") + 
                                ".ret".

   IF  par_flggeren THEN  /* Se Gerenciador Financeiro  - Salvar dia */
       UNIX SILENT 
            VALUE("mv " + par_nmarquiv + " " + aux_nmarqdat_salvo ).
   ELSE
       UNIX SILENT VALUE("mv " + par_nmarquiv + " salvar").
               
END PROCEDURE. /* processa_arquivos */


PROCEDURE leitura_craprcb:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolx AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagefim AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-total.

    CREATE tt-total.
    ASSIGN tt-total.qttitrec = 0
           tt-total.vltitrec = 0
           tt-total.qttitliq = 0
           tt-total.vltitliq = 0
           tt-total.qttitcan = 0
           tt-total.vltitcan = 0
           tt-total.qtfatrec = 0
           tt-total.vlfatrec = 0
           tt-total.qtfatliq = 0
           tt-total.vlfatliq = 0
           tt-total.qtfatcan = 0
           tt-total.vlfatcan = 0
           tt-total.qtinss   = 0
           tt-total.vlinss   = 0
           tt-total.qtdinhei = 0
           tt-total.vldinhei = 0
           tt-total.qtcheque = 0
           tt-total.vlcheque = 0.

    FOR EACH craprcb WHERE craprcb.cdcooper  = par_cdcooper   AND
                           craprcb.dtmvtolt  = par_dtmvtolx   AND
                          (craprcb.cdagenci >= par_cdagencx   AND
                           craprcb.cdagenci <= par_cdagefim ) AND
                          (craprcb.nrdcaixa >= par_nrdcaixx   AND
                           craprcb.nrdcaixa <= par_nrdcaixa)  AND
                          (craprcb.cdtransa = '268'           OR /*Titulos*/
                           craprcb.cdtransa = '358'           OR /*Faturas*/
                           craprcb.cdtransa = '284')          AND
                           /* Recebto INSS */
                           craprcb.cdagenci <> 9999 NO-LOCK:
    
        IF  craprcb.cdtransa = "268"  THEN   /* Titulos */
            DO:
                ASSIGN tt-total.qttitrec = tt-total.qttitrec + 1
                       tt-total.vltitrec = tt-total.vltitrec + craprcb.valorpag.
    
                IF  craprcb.flgrgatv THEN
                    ASSIGN tt-total.qttitliq = tt-total.qttitliq + 1
                           tt-total.vltitliq = tt-total.vltitliq + craprcb.valorpag.
                ELSE
                    ASSIGN tt-total.qttitcan = tt-total.qttitcan + 1
                           tt-total.vltitcan = tt-total.vltitcan + craprcb.valorpag.
            END.
        ELSE
            DO:
                IF  craprcb.cdtransa = "358" THEN    /* Faturas */
                    DO: 
                        ASSIGN tt-total.qtfatrec = tt-total.qtfatrec + 1
                               tt-total.vlfatrec = tt-total.vlfatrec + 
                                              craprcb.valorpag. 
    
                        IF  craprcb.flgrgatv = YES THEN 
                            ASSIGN tt-total.qtfatliq = tt-total.qtfatliq + 1
                                   tt-total.vlfatliq = tt-total.vlfatliq + 
                                                  craprcb.valorpag.
                        ELSE
                            ASSIGN tt-total.qtfatcan = tt-total.qtfatcan + 1
                                   tt-total.vlfatcan = tt-total.vlfatcan + 
                                                  craprcb.valorpag.
                    END.
                ELSE
                    DO:
                        IF  craprcb.flgrgatv = YES THEN
                            ASSIGN tt-total.qtinss = tt-total.qtinss + 1
                                   tt-total.vlinss = tt-total.vlinss + 
                                                craprcb.valorpag.
                    END.
            END.
    
        IF  NOT craprcb.flgrgatv THEN 
            NEXT.
    
        IF  craprcb.cdtransa = '284' THEN 
            NEXT.
    
        IF  craprcb.formaliq = 1 THEN
            ASSIGN tt-total.qtdinhei = tt-total.qtdinhei + 1 
                   tt-total.vldinhei = tt-total.vldinhei + craprcb.valorpag.
        ELSE
            ASSIGN tt-total.qtcheque = tt-total.qtcheque + 1
                   tt-total.vlcheque = tt-total.vlcheque + craprcb.valorpag.
    
    END.  /*  Fim do FOR EACH  --  Leitura do craprcb  */
    
    ASSIGN  tt-total.vlrepasse  = (tt-total.vltitliq + tt-total.vlfatliq) - (tt-total.vlinss).


END PROCEDURE. /* leitura_craprcb */


/*.............................. PROCEDURES (FIM) ...........................*/
