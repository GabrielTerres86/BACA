/*..............................................................................

   Programa: fontes/contib.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Julho/2010                        Ultima atualizacao: 03/04/2012

   Dados referentes ao programa:

   Frequencia: Diario (On-Line).
   Objetivo  : Consulta de valores de TIB(Cheques/Docs/Titulos) e DDA
   
   Alteracoes: 13/08/2010 - Ajuste na Tela (Ze).
               
               03/04/2012 - TIB DDA - Alteracao pi_dda (Guilherme/Supero)

               16/04/2012 - Substituido codigo do fonte do programa contib.p 
                            pelo contibp.p (Elton).
..............................................................................*/

{ includes/var_online.i }

DEF VAR tel_nmdopcao AS CHAR        FORMAT "x(12)" VIEW-AS COMBO-BOX 
                      INNER-LINES 4                                    NO-UNDO.
DEF VAR tel_dtrefini AS DATE        FORMAT "99/99/9999"                NO-UNDO.
DEF VAR tel_dtreffim AS DATE        FORMAT "99/99/9999"                NO-UNDO.

DEF VAR aux_qtdtotal AS INT                                            NO-UNDO.
DEF VAR aux_vlrtotal AS DECI                                           NO-UNDO.
DEF VAR aux_dscopcao AS CHAR        FORMAT "x(10)"                     NO-UNDO.
DEF VAR aux_dscooper AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcooper AS INT                                            NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.

DEF VAR aux_vltarifa AS DEC                                            NO-UNDO.
DEF VAR aux_dstarifa AS CHAR                                           NO-UNDO.

DEF VAR tot_vlrnrfac AS DEC                                            NO-UNDO.
DEF VAR tot_vlrsrfac AS DEC                                            NO-UNDO.
DEF VAR tot_vlrnrroc AS DEC                                            NO-UNDO.
DEF VAR tot_vlrsrroc AS DEC                                            NO-UNDO.

DEF VAR tot_vltotfac AS DEC                                            NO-UNDO.
DEF VAR aux_vltotfac AS DEC                                            NO-UNDO.

DEF TEMP-TABLE tt-relatorio                                            NO-UNDO
    FIELD cdcooper AS INT
    FIELD dscooper AS CHAR
    FIELD qtdtotnr AS INT
    FIELD vlrtotnr AS DECI
    FIELD qtdtotsr AS INT
    FIELD vlrtotsr AS DECI
    FIELD qtdtotal AS INT.

FORM WITH NO-LABEL TITLE COLOR MESSAGE glb_tldatela
     ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 FRAME f_moldura.

FORM tel_nmdopcao AT 3  LABEL "Processar"
                  HELP "Selecione a Funcao para processar"
     tel_dtrefini AT 33 LABEL "Data Referencia" FORMAT "99/99/9999"
     tel_dtreffim AT 61 LABEL "ate" FORMAT "99/99/9999"
     WITH NO-LABEL SIDE-LABELS COLUMN 2 ROW 6 OVERLAY 
     WIDTH 75 NO-BOX FRAME f_opcao.

FORM aux_dstarifa    FORMAT "x(32)"                   AT 1
     aux_vltarifa    FORMAT "->>,>>>,>>9.99"          AT 42
     WITH ROW 18 CENTERED NO-LABELS OVERLAY NO-BOX FRAME f_tarifa_fac_1.

FORM aux_dstarifa    FORMAT "x(32)"                   AT 1
     aux_vltarifa    FORMAT "->>,>>>,>>9.99"          AT 42
     WITH ROW 19 CENTERED NO-LABELS OVERLAY NO-BOX FRAME f_tarifa_fac_2.

FORM "Total FAC"                                      AT 1
     aux_vltotfac    FORMAT "->>,>>>,>>9.99"          AT 42
     WITH ROW 20 CENTERED NO-LABELS OVERLAY NO-BOX FRAME f_total_fac.

FORM aux_dstarifa    FORMAT "x(33)"                   AT 1
     aux_vltarifa    FORMAT "->>,>>>,>>9.99"          AT 42
     WITH ROW 18 CENTERED NO-LABELS OVERLAY NO-BOX FRAME f_tarifa_roc.


FORM "Total (NR e SR)" AT 01                                 
     aux_qtdtotal      AT 24 FORMAT "zz,zzz,zz9"      NO-LABEL
     aux_vlrtotal      AT 42 FORMAT "zzz,zzz,zz9.99-" NO-LABEL
     WITH ROW 16 SIDE-LABELS CENTERED OVERLAY NO-BOX FRAME f_tib_total.

FORM "Total"      AT 01
     aux_qtdtotal AT 27 FORMAT "zz,zzz,zz9"      NO-LABEL
     WITH ROW 20 CENTERED SIDE-LABELS OVERLAY NO-BOX FRAME f_dda_total.



DEF QUERY q_resultado FOR tt-relatorio
                  FIELDS(dscooper qtdtotnr vlrtotnr qtdtotsr vlrtotsr).
                                     
DEF BROWSE b_resultado QUERY q_resultado 
    DISP tt-relatorio.dscooper FORMAT "x(13)"              
                               COLUMN-LABEL "Cooperativa"
         tt-relatorio.qtdtotnr FORMAT "zzz,zz9"                  
                               COLUMN-LABEL "Qtd NR"
         tt-relatorio.vlrtotnr FORMAT "zzz,zzz,zzz,zz9.99-"      
                               COLUMN-LABEL "Total NR"
         tt-relatorio.qtdtotsr FORMAT "zzz,zz9"                  
                               COLUMN-LABEL "Qtd SR"
         tt-relatorio.vlrtotsr FORMAT "zzz,zzz,zzz,zz9.99-"
                               COLUMN-LABEL "Total SR"
                               WITH 4 DOWN.

DEF FRAME f_resultado_b  
          SKIP(1)
          b_resultado    HELP  "Pressione <F4> ou <END> p/finalizar"
          WITH NO-BOX CENTERED OVERLAY ROW 7.

DEF QUERY q_resul_dda FOR tt-relatorio
                  FIELDS(dscooper qtdtotal).
                                     
DEF BROWSE b_resul_dda QUERY q_resul_dda
    DISP  tt-relatorio.dscooper FORMAT "x(25)"    COLUMN-LABEL "Cooperativa"
          tt-relatorio.qtdtotal FORMAT ">>>,>>9"  COLUMN-LABEL "Quantidade"
          WITH 8 DOWN.

DEF FRAME f_resul_dda_b  
          SKIP(1)
          b_resul_dda    HELP  "Pressione <F4> ou <END> p/finalizar"
          WITH NO-BOX CENTERED OVERLAY ROW 7.


ASSIGN tel_nmdopcao:LIST-ITEMS = "TIB-CHEQUES,TIB-DOCTOS,TIB-TITULOS,DDA".

FUNCTION f_busca_dia_util RETURN DATE (INPUT p_data     AS DATE,
                                       INPUT p_cdcooper AS INT).

    DO WHILE TRUE:
    
        p_data = p_data + 1.
    
        IF   LOOKUP(STRING(WEEKDAY(p_data)),"1,7") <> 0   THEN
             NEXT.
        
        IF   CAN-FIND(crapfer WHERE crapfer.cdcooper = p_cdcooper AND
                                    crapfer.dtferiad = p_data)    THEN
             NEXT.
        LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    RETURN p_data. 

END. /* FUNCTION */


ON RETURN OF tel_nmdopcao DO:
  
   tel_nmdopcao = tel_nmdopcao:SCREEN-VALUE.

   APPLY "GO".
END.

VIEW FRAME f_moldura.

PAUSE(0).

RUN fontes/inicia.p.

ASSIGN tel_dtrefini = DATE(MONTH(glb_dtmvtoan),1,YEAR(glb_dtmvtoan))
       tel_dtreffim = glb_dtmvtoan.

RUN pi_oculta_frames.


DO WHILE TRUE:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE tel_nmdopcao WITH FRAME f_opcao.
        UPDATE tel_dtrefini tel_dtreffim WITH FRAME f_opcao.
        RUN pi_oculta_frames.
        LEAVE.
    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            RUN fontes/novatela.p.

            IF  CAPS(glb_nmdatela) <> "CONTIB"  THEN
                DO:
                    HIDE FRAME f_moldura NO-PAUSE.
                    HIDE FRAME f_opcao   NO-PAUSE.
                    RUN pi_oculta_frames.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF   aux_cddopcao <> glb_cddopcao  THEN
         DO:
             { includes/acesso.i }
             ASSIGN aux_cddopcao = glb_cddopcao.
         END.

    CASE tel_nmdopcao:
         WHEN "TIB-CHEQUES"  THEN  RUN pi_tib_cheques.
         WHEN "TIB-DOCTOS"   THEN  RUN pi_tib_doctos.
         WHEN "TIB-TITULOS"  THEN  RUN pi_tib_titulos.
         WHEN "DDA"          THEN  RUN pi_dda.
    END CASE.

    RUN pi_exibe_relatorio.

END. /* FIM do WHILE TRUE */




PROCEDURE pi_tib_cheques:

   RUN pi_oculta_frames.

   ASSIGN aux_dscopcao = "CHEQUES".

   EMPTY TEMP-TABLE tt-relatorio.

   RUN pi_busca_valores_gntarcp (INPUT "1,2,6,7"). /* CHEQUES NR e SR */

END PROCEDURE.



PROCEDURE pi_tib_doctos:

   RUN pi_oculta_frames.

   ASSIGN aux_dscopcao = "DOC".

   EMPTY TEMP-TABLE tt-relatorio.

   RUN pi_busca_valores_gntarcp (INPUT "5,8").  /* DOC NR / SR */

END PROCEDURE.




PROCEDURE pi_tib_titulos:

   RUN pi_oculta_frames.

   ASSIGN aux_dscopcao = "TITULOS".

   EMPTY TEMP-TABLE tt-relatorio.

   RUN pi_busca_valores_gntarcp (INPUT "3,4").  /* TITULO/COBRANCA */

END PROCEDURE.




PROCEDURE pi_dda:

   RUN pi_oculta_frames.

   ASSIGN aux_dscopcao = "DDA".

   EMPTY TEMP-TABLE tt-relatorio.

   RUN pi_busca_valores_gntarcp (INPUT "21,22,23,24"). 
   /* DDA NR(21,22) / DDA SR (23,24) */

END PROCEDURE.



PROCEDURE pi_busca_valores_gntarcp:

 DEF INPUT PARAM par_cdtipdoc   AS CHAR                        NO-UNDO.

    FOR EACH gntarcp WHERE gntarcp.dtmvtolt >= tel_dtrefini   AND
                           gntarcp.dtmvtolt <= tel_dtreffim   AND
                           CAN-DO(par_cdtipdoc,STRING(gntarcp.cdtipdoc))
                           NO-LOCK BREAK BY gntarcp.cdcooper:
    
        FIND FIRST crapcop WHERE crapcop.cdcooper = gntarcp.cdcooper
                                 NO-LOCK NO-ERROR.
    
        IF   AVAILABLE crapcop THEN
             ASSIGN aux_dscooper = crapcop.nmrescop
                    aux_cdcooper = crapcop.cdcooper.
        ELSE
             ASSIGN aux_dscooper = "Sem Identific."
                    aux_cdcooper = 0.
        
    
        FIND FIRST tt-relatorio WHERE tt-relatorio.cdcooper = aux_cdcooper
                                      NO-LOCK NO-ERROR.
            
        IF   NOT AVAIL tt-relatorio THEN 
             DO:
                 CREATE tt-relatorio.
                 ASSIGN tt-relatorio.dscooper = aux_dscooper
                        tt-relatorio.cdcooper = aux_cdcooper.
             END.


        CASE gntarcp.cdtipdoc:
        
             /* CHEQUES NR */
             WHEN 1 OR WHEN 2 THEN
                  ASSIGN tt-relatorio.vlrtotnr = tt-relatorio.vlrtotnr +
                                                 gntarcp.vldocmto
                         tt-relatorio.qtdtotnr = tt-relatorio.qtdtotnr +
                                                 gntarcp.qtdocmto.
                  
             /* CHEQUES SR */
             WHEN 6 OR WHEN 7 THEN
                  ASSIGN tt-relatorio.vlrtotsr = tt-relatorio.vlrtotsr -
                                                 gntarcp.vldocmto
                         tt-relatorio.qtdtotsr = tt-relatorio.qtdtotsr +
                                                 gntarcp.qtdocmto.
        
             /* TITULO/COBRANCA */
             WHEN 3 OR WHEN 4 THEN 
                  ASSIGN tt-relatorio.vlrtotnr = tt-relatorio.vlrtotnr + 
                                                 gntarcp.vldocmto
                         tt-relatorio.qtdtotnr = tt-relatorio.qtdtotnr +
                                                 gntarcp.qtdocmto.
        
             /* DOC NR */
             WHEN 5 THEN 
                  ASSIGN tt-relatorio.qtdtotnr = tt-relatorio.qtdtotnr + 
                                                 gntarcp.qtdocmto
                         tt-relatorio.vlrtotnr = tt-relatorio.vlrtotnr -
                                                 gntarcp.vldocmto.
                  
             /* DOC NR / SR */
             WHEN 8 THEN 
                  ASSIGN tt-relatorio.qtdtotsr = tt-relatorio.qtdtotsr + 
                                                 gntarcp.qtdocmto
                         tt-relatorio.vlrtotsr = tt-relatorio.vlrtotsr +
                                                 gntarcp.vldocmto.
        END CASE.

    END. /* END FOR EACH gntarcp */ 

END PROCEDURE.




PROCEDURE pi_exibe_relatorio:

   DEF VAR aux_contador AS INT  INIT 0                         NO-UNDO.

   ASSIGN aux_qtdtotal = 0
          aux_vlrtotal = 0.

   /* Exibe FAC/ROC - APENAS quando TIB */
   CASE aux_dscopcao:
       WHEN "CHEQUES" THEN  RUN pi_tarifas_cheques.
       WHEN "DOC"     THEN  RUN pi_tarifas_doc.
       WHEN "TITULOS" THEN  RUN pi_tarifas_titulos.
   END CASE.

   IF   tel_nmdopcao = "DDA" THEN
        DO:
            OPEN QUERY q_resul_dda FOR EACH tt-relatorio NO-LOCK 
                                             BY tt-relatorio.cdcooper.

            IF   NUM-RESULTS("q_resul_dda") > 0 THEN 
                 DO:
                     ENABLE b_resul_dda WITH FRAME f_resul_dda_b.

                     DO aux_contador = 1 TO NUM-RESULTS("q_resul_dda"):
                        ASSIGN aux_qtdtotal = aux_qtdtotal +
                                              tt-relatorio.qtdtotal.
                        QUERY q_resul_dda:GET-NEXT().
                     END.

                     DISPLAY aux_qtdtotal WITH FRAME f_dda_total.

                     WAIT-FOR END-ERROR OF DEFAULT-WINDOW.

                     RUN pi_oculta_frames.

                     HIDE MESSAGE NO-PAUSE.
                 END.
            ELSE 
                 DO:
                     glb_cdcritic = 11.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                 END.
        END.
   ELSE
        DO:
            OPEN QUERY q_resultado FOR EACH tt-relatorio NO-LOCK 
                                            BY tt-relatorio.cdcooper.

            IF   NUM-RESULTS("q_resultado") > 0 THEN 
                 DO:
                     ENABLE b_resultado WITH FRAME f_resultado_b.

                     DO aux_contador = 1 TO NUM-RESULTS("q_resultado"):
                        ASSIGN aux_qtdtotal = aux_qtdtotal +
                                              tt-relatorio.qtdtotnr +
                                              tt-relatorio.qtdtotsr
                               aux_vlrtotal = aux_vlrtotal +
                                              tt-relatorio.vlrtotnr +
                                              tt-relatorio.vlrtotsr.
                        QUERY q_resultado:GET-NEXT().
                     END.

                     DISPLAY aux_qtdtotal aux_vlrtotal WITH FRAME f_tib_total.

                     WAIT-FOR END-ERROR OF DEFAULT-WINDOW.

                     RUN pi_oculta_frames.

                     HIDE MESSAGE NO-PAUSE.
                 END.
            ELSE 
                 DO:
                     glb_cdcritic = 11.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                 END.
        END.

END PROCEDURE.



PROCEDURE pi_tarifas_cheques:

    DEF VAR aux_dtcalini AS DATE                            NO-UNDO.
    DEF VAR aux_dtcalfim AS DATE                            NO-UNDO.

    ASSIGN aux_dtcalini = ?
           aux_dtcalfim = ?
           tot_vlrnrfac = 0
           tot_vlrsrfac = 0
           aux_vltarifa = 0
           aux_vltotfac = 0
           tot_vltotfac = 0.

    /*** FAC ***/
    FOR EACH gnfcomp WHERE gnfcomp.cdcooper  = 3            AND
                           gnfcomp.dtmvtolt >= tel_dtrefini AND
                           gnfcomp.dtmvtolt <= tel_dtreffim AND
                           gnfcomp.cdtipfec  = 1            AND
                           gnfcomp.idregist  = 1            AND
                           gnfcomp.cdtipdoc  = 16           NO-LOCK:
       
        ASSIGN tot_vlrnrfac = tot_vlrnrfac + gnfcomp.vlremdoc         /* NR */
               tot_vlrsrfac = tot_vlrsrfac + (gnfcomp.vlrecdoc * -1). /* SR */
    END.
    
    ASSIGN aux_vltarifa = tot_vlrnrfac + tot_vlrsrfac
           tot_vltotfac = tot_vltotfac + aux_vltarifa.

    IF   aux_vltarifa <> 0 THEN
         DO: 
             ASSIGN aux_dstarifa = "FAC: 016-TARIFA INTERBANC. (TIB)"
                    aux_vltotfac = aux_vltotfac + aux_vltarifa.
     
             DISPLAY aux_dstarifa aux_vltarifa  WITH FRAME f_tarifa_fac_1.
         END.

    ASSIGN aux_vltarifa = 0
           tot_vlrnrfac = 0
           tot_vlrsrfac = 0.

    /*  aux_dtcalini e aux_dtcalfim eh data calculada. Soma-se 1 dia nas datas
        informadas no parametro de tela. Valida se o dia somado eh dia util  */
    ASSIGN aux_dtcalini = f_busca_dia_util(tel_dtrefini, 3)
           aux_dtcalfim = f_busca_dia_util(tel_dtreffim, 3).

    /*** FAC  ***/
    FOR EACH gnfcomp WHERE gnfcomp.cdcooper  = 3            AND
                           gnfcomp.dtmvtolt >= aux_dtcalini AND
                           gnfcomp.dtmvtolt <= aux_dtcalfim AND
                           gnfcomp.cdtipfec  = 1            AND
                           gnfcomp.idregist  = 1            AND
                           gnfcomp.cdtipdoc  = 18           NO-LOCK
                           BREAK BY gnfcomp.cdtipdoc:
       
        ASSIGN tot_vlrnrfac = tot_vlrnrfac + gnfcomp.vlremdoc         /* NR */
               tot_vlrsrfac = tot_vlrsrfac + (gnfcomp.vlrecdoc * -1). /* SR */
    END.
    
    ASSIGN aux_vltarifa = tot_vlrnrfac + tot_vlrsrfac
           tot_vltotfac = tot_vltotfac + aux_vltarifa.
    
    IF   aux_vltarifa <> 0 THEN
         DO:
              ASSIGN aux_dstarifa = "FAC: 018-TARIFA INTERBANC. MVR"
                     aux_vltotfac = aux_vltotfac + aux_vltarifa.
     
              DISPLAY aux_dstarifa aux_vltarifa WITH FRAME f_tarifa_fac_2.
         END.
         
    IF   aux_vltotfac <> 0 THEN
         DISPLAY aux_vltotfac WITH FRAME f_total_fac.

END PROCEDURE.



PROCEDURE pi_tarifas_doc:

    /* ROC */
    ASSIGN tot_vlrnrroc = 0
           tot_vlrsrroc = 0
           aux_vltarifa = 0.

    FOR EACH gnfcomp WHERE gnfcomp.cdcooper  = 3            AND
                           gnfcomp.dtmvtolt >= tel_dtrefini AND
                           gnfcomp.dtmvtolt <= tel_dtreffim AND
                           gnfcomp.cdtipfec  = 2            AND
                           gnfcomp.idregist  = 1            AND
                           gnfcomp.cdtipdoc  = 7            NO-LOCK
                           BREAK BY gnfcomp.cdtipdoc:

        ASSIGN tot_vlrnrroc = tot_vlrnrroc + gnfcomp.vlremdoc         /* NR */
               tot_vlrsrroc = tot_vlrsrroc + (gnfcomp.vlrecdoc * -1). /* SR */

    END.

    ASSIGN aux_vltarifa = aux_vltarifa + tot_vlrnrroc + tot_vlrsrroc.

    IF   aux_vltarifa <> 0 THEN 
         DO:
             ASSIGN aux_dstarifa = "ROC: 007-TARIFA INTERB. DE DOC".
 
             DISPLAY aux_dstarifa aux_vltarifa WITH FRAME f_tarifa_roc.
             DOWN WITH FRAME f_tarifas.
         END.

END PROCEDURE.




PROCEDURE pi_tarifas_titulos:

    /* ROC */
    ASSIGN tot_vlrnrroc = 0
           tot_vlrsrroc = 0
           aux_vltarifa = 0.

    FOR EACH gnfcomp WHERE gnfcomp.cdcooper  = 3            AND
                           gnfcomp.dtmvtolt >= tel_dtrefini AND
                           gnfcomp.dtmvtolt <= tel_dtreffim AND
                           gnfcomp.cdtipfec  = 2            AND
                           gnfcomp.idregist  = 1            AND
                           gnfcomp.cdtipdoc  = 15           NO-LOCK
                           BREAK BY gnfcomp.cdtipdoc:

        ASSIGN tot_vlrnrroc = tot_vlrnrroc + gnfcomp.vlremdoc         /* NR */
               tot_vlrsrroc = tot_vlrsrroc + (gnfcomp.vlrecdoc * -1). /* SR */
    END.

    ASSIGN aux_vltarifa = aux_vltarifa + tot_vlrnrroc + tot_vlrsrroc.

    IF   aux_vltarifa <> 0 THEN 
         DO:
             ASSIGN aux_dstarifa = "ROC: 015-TARIFA INTERB. COBRANCAS".

             DISPLAY aux_dstarifa aux_vltarifa WITH FRAME f_tarifa_roc.
             DOWN WITH FRAME f_tarifas.
         END.


END PROCEDURE.



PROCEDURE pi_oculta_frames:

    HIDE FRAME f_tib_total.
    HIDE FRAME f_resultado_b.
    HIDE FRAME f_resul_dda_b.
    HIDE FRAME f_dda_total.
    HIDE FRAME f_tarifa_fac_1.
    HIDE FRAME f_tarifa_fac_2.
    HIDE FRAME f_total_fac.
    HIDE FRAME f_tarifa_roc.
    HIDE MESSAGE NO-PAUSE.

END PROCEDURE.

/*............................................................................*/
