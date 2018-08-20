/*---------------------------------------------------------------------------
     
      b1crap32.p - Controle Titulos
      
      Ultima Atualizacao: 22/06/2018
      
      Alteracoes: 23/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                  08/12/2008 - Incluir parametro na chamada do programa
                               pcrap03.p (David).

                  10/03/2009 - Ajuste para unificacao dos bancos de dados
                               (Evandro).
                               
                  20/10/2010 - Incluido caminho completo nas referencias do 
                               diretorio spool (Elton).  
                               
                  23/05/2011 - Alterada a leitura da tabela craptab para a 
                               tabela crapope (Isara - RKAM).      
                               
                  30/09/2011 - Alterar diretorio spool para
                               /usr/coop/sistema/siscaixa/web/spool (Fernando).
                               
                  05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).     

                  22/06/2018 - Alteracoes para usar as rotinas mesmo com o processo 
                               norturno rodando (Douglas Pagel - AMcom).
                               
---------------------------------------------------------------------------- **/

{dbo/bo-erro1.i}

DEF VAR i-cod-erro   AS INTEGER.
DEF VAR c-desc-erro  AS CHAR.

DEF STREAM str_1.

DEF VAR aux_nmarqimp AS CHAR                                NO-UNDO.
DEF VAR rel_nmresemp AS CHAR    FORMAT "x(15)"              NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)"              NO-UNDO.
DEF VAR lot_nmoperad AS CHAR                                NO-UNDO.

DEF VAR pac_qtdlotes AS INT     FORMAT "zzz,zz9"            NO-UNDO.
DEF VAR pac_qttitulo AS INT     FORMAT "zzz,zz9"            NO-UNDO.
DEF VAR pac_vltitulo AS DECIMAL FORMAT "zzz,zzz,zz9.99"     NO-UNDO.

DEF VAR tot_qtdlotes AS INT     FORMAT "zzz,zz9"            NO-UNDO.
DEF VAR tot_qttitulo AS INT     FORMAT "zzz,zz9"            NO-UNDO.
DEF VAR tot_vltitulo AS DECIMAL FORMAT "zzz,zzz,zz9.99"     NO-UNDO.  
DEF VAR tel_nrcampo1 AS DECIMAL FORMAT "9999999999"         NO-UNDO.
DEF VAR tel_nrcampo2 AS DECIMAL FORMAT "99999999999"        NO-UNDO.
DEF VAR tel_nrcampo3 AS DECIMAL FORMAT "99999999999"        NO-UNDO.
DEF VAR tel_nrcampo4 AS INT     FORMAT "9"                  NO-UNDO.
DEF VAR tel_nrcampo5 AS DECIMAL FORMAT "zzzzzzzzzzz999"     NO-UNDO.
DEF VAR tel_dscodbar AS CHAR    FORMAT "x(44)"              NO-UNDO.
DEF VAR l-retorno    AS LOG                                 NO-UNDO.
DEF VAR tel_dsdlinha AS CHAR                                NO-UNDO.
DEF VAR tel_qttitulo AS INTEGER                             NO-UNDO.
DEF VAR tel_vltitulo AS DECI                                NO-UNDO.

DEF VAR aux_nmdafila AS CHAR                                NO-UNDO.
DEF VAR i-nro-vias   AS INTE                                NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                NO-UNDO.

DEF VAR aux_flgtitcop AS CHAR                               NO-UNDO.

DEF TEMP-TABLE tt-lote                                      NO-UNDO
    FIELD cdagenci AS INT     FORMAT "zz9"
    FIELD cdbccxlt AS INT     FORMAT "zz9"
    FIELD nrdolote AS INT     FORMAT "zzz,zz9"
    FIELD qttitulo AS INT     FORMAT "zzz,zz9"
    FIELD vltitulo AS DECIMAL FORMAT "zzzz,zzz,zz9.99"
    FIELD nmoperad AS CHAR    FORMAT "x(10)"
    FIELD nmarquiv AS CHAR    FORMAT "x(24)".

FORM crapdat.dtmvtocd  AT   1   LABEL "REFERENCIA"   FORMAT "99/99/9999"
     SKIP(1)
     "PA CXA    LOTE"           AT  1
     "   QTD.           VALOR"        
     "OPERADOR      ARQUIVO BANCOOB" 
     SKIP(1)
     WITH SIDE-LABELS NO-BOX WIDTH 132 FRAME f_cab STREAM-IO.
      
FORM crapaut.cdhistor COLUMN-LABEL "Hist"
     crapaut.nrsequen COLUMN-LABEL "Seq."
     crapaut.hrautent COLUMN-LABEL "Hora" 
     crapaut.nrdocmto COLUMN-LABEL "Docto"
     crapaut.vldocmto COLUMN-LABEL "Valor"
     crapaut.tpoperac COLUMN-LABEL " " FORMAT "PG/RC"
     crapaut.cdstatus COLUMN-LABEL "ST"
     crapaut.estorno  COLUMN-LABEL "Estorno" FORMAT "Sim/Nao"
     crapaut.nrseqaut COLUMN-LABEL "Seq.!Orig."
     WITH NO-BOX  DOWN FRAME f_historico STREAM-IO.

FORM  tt-lote.cdagenci AT  1              
      tt-lote.cdbccxlt AT  5               
      tt-lote.nrdolote AT  9 
      tt-lote.qttitulo AT 17               
      tt-lote.vltitulo AT 25             
      tt-lote.nmoperad AT 41           
      tt-lote.nmarquiv AT 55 
      WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_lotes STREAM-IO.

FORM tel_dsdlinha     FORMAT "x(56)"          LABEL "Linha digitavel"
     craptit.vldpagto FORMAT "zzzzz,zz9.99"   LABEL "Valor Pago"
     craptit.nrseqdig FORMAT "zzzz9"          LABEL "Seq."
     aux_flgtitcop    FORMAT "x(01)"          LABEL "C"
     WITH COLUMN 4 NO-LABEL NO-BOX DOWN FRAME f_lanctos.

FORM SKIP(1)
     "Quantidade de Titulos:"   tel_qttitulo     FORMAT "zzzzz,zz9.99"
     "        Valor Total:"     tel_vltitulo     FORMAT "zzzzz,zz9.99"   
     WITH COLUMN 4 NO-LABEL NO-BOX FRAME f_totais.

FORM SKIP(2) 
     "-----TITULOS DA COOPERATIVA------"
     SKIP(1) WITH COLUMN 4 NO-LABEL NO-BOX FRAME f_titcop.

FORM SKIP(1) WITH NO-BOX FRAME f_linha STREAM-IO.

PROCEDURE Impressao:

    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-operador  AS char.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-nro-lote      AS INTE.
    DEF INPUT  PARAM p-impressao     AS LOG.
    def OUTPUT PARAM p-nome-arquivo  AS CHAR.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
     
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).    
    
    IF  p-nro-lote = 0 THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Lote deve ser Informado".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK". 
        END.           

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.      

    IF  p-impressao = YES  THEN  
        DO:  /* Impressao */
        
            /* Impressora */
            FIND FIRST crapope NO-LOCK
                 WHERE crapope.cdcooper = crapcop.cdcooper
                   AND crapope.cdoperad = p-cod-operador NO-ERROR.
            IF NOT AVAIL crapope THEN
                DO:
                    ASSIGN i-cod-erro  = 67
                           c-desc-erro = "".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".  
                END.
            ELSE
            DO:
                IF crapope.dsimpres = "" THEN
                DO:                          
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = 
                                "Registro de impressora nao encontrado para o Operador".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
            END.
        
            ASSIGN aux_nmdafila = LC(crapope.dsimpres).   
        
            ASSIGN aux_nmarqimp = "/usr/coop/sistema/siscaixa/web/spool/" +
                                  crapcop.dsdircop +
                                  STRING(p-cod-agencia) + 
                                  STRING(p-nro-caixa) + 
                                  "b1032.txt".  /* Nome Fixo  */
        END.
    ELSE 
        DO:
            ASSIGN aux_nmarqimp = "/usr/coop/sistema/siscaixa/web/spool/" + 
                                  crapcop.dsdircop + 
                                  STRING(p-cod-agencia) + 
                                  STRING(p-nro-caixa) + 
                                  "b1032.txt".  /* Nome Fixo  */
                                  
         ASSIGN p-nome-arquivo = "spool/" + crapcop.dsdircop + 
                                 STRING(p-cod-agencia) + STRING(p-nro-caixa) + 
                                    "b1032.txt".  /* Nome Fixo  */.
        END.

    FIND crapemp WHERE crapemp.cdcooper = crapcop.cdcooper  AND
                       crapemp.cdempres = 11                NO-LOCK NO-ERROR.
         
    IF  NOT AVAIL crapemp   THEN
        ASSIGN rel_nmresemp = FILL("?",11).
    ELSE
        ASSIGN rel_nmresemp = SUBSTRING(crapemp.nmresemp,1,11).
    
    ASSIGN rel_nmrelato = "Titulos".
     
    FORM HEADER 
         rel_nmresemp               FORMAT "x(11)"
         "-"
         rel_nmrelato               FORMAT "x(36)"
         "REF P032 "
         STRING(TIME,"HH:MM")       FORMAT "x(5)"
         "PAG: "                   
         PAGE-NUMBER(str_1)         FORMAT "zz9"
         
         WITH PAGE-TOP NO-BOX NO-ATTR-SPACE FRAME f_cabrel080_1 STREAM-IO.
                                           
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
    
    IF  p-impressao = YES  THEN 
        DO:
      
            PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
            PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
        
            VIEW STREAM str_1 FRAME f_cabrel080_1.
        END.

    DISPLAY STREAM str_1  crapdat.dtmvtocd WITH FRAME f_cab. 
    
    /*
    FOR  EACH tt-lote:
         DELETE tt-lote.
    END.  /*  Fim do FOR EACH  */
    */
    
    EMPTY TEMP-TABLE tt-lote.
   
    FOR EACH craplot WHERE (craplot.cdcooper = crapcop.cdcooper      AND
                            craplot.cdagenci = p-cod-agencia         AND
                            craplot.dtmvtolt = crapdat.dtmvtocd      AND
                            craplot.cdbccxlt = 11                    AND
                            craplot.tplotmov = 20)                   OR
                           (craplot.cdcooper = crapcop.cdcooper      AND
                            craplot.cdagenci = p-cod-agencia         AND
                            craplot.dtmvtopg = crapdat.dtmvtocd      AND 
                            craplot.tplotmov = 20)                    NO-LOCK
                           BREAK BY craplot.cdagenci
                                    BY craplot.cdbccxlt
                                       BY craplot.nrdolote:

        IF  p-nro-lote <> craplot.nrdolote   THEN  NEXT.
     
        /* FIND crapope OF craplot NO-LOCK NO-ERROR. */
        FIND crapope WHERE crapope.cdcooper = crapcop.cdcooper  AND
                           crapope.cdoperad = craplot.cdoperad  
                           NO-LOCK NO-ERROR.
        IF  NOT AVAILABLE crapope   THEN
            lot_nmoperad = craplot.cdoperad.
        ELSE
            lot_nmoperad = ENTRY(1,crapope.nmoperad," ").

       CREATE tt-lote.
       ASSIGN tt-lote.cdagenci = craplot.cdagenci
              tt-lote.cdbccxlt = craplot.cdbccxlt
              tt-lote.nrdolote = craplot.nrdolote
              tt-lote.qttitulo = craplot.qtinfoln
              tt-lote.vltitulo = craplot.vlcompcr              
              tt-lote.nmoperad = lot_nmoperad
              tt-lote.nmarquiv = STRING(crapcop.cdagebcb,"9999") +
                                 STRING(MONTH(crapdat.dtmvtocd),"99") +
                                 STRING(DAY(crapdat.dtmvtocd),"99") +
                                 STRING(craplot.cdagenci,"999") +
                                 STRING(craplot.cdbccxlt,"999") +
                                 STRING(craplot.nrdolote,"999999") + ".CBE".
       RUN proc_resgates.
   
   END.  /*  for each craplot */
  
   ASSIGN pac_qtdlotes = 0
          pac_qttitulo = 0
          pac_vltitulo = 0 
          tot_qtdlotes = 0 
          tot_qttitulo = 0
          tot_vltitulo = 0.
    
    FOR EACH tt-lote BREAK BY tt-lote.cdagenci
                             BY tt-lote.cdbccxlt 
                                BY tt-lote.nrdolote:
       
        IF  FIRST-OF(tt-lote.cdagenci)   THEN 
            DO:
                IF  LINE-COUNTER(str_1) > 80  THEN 
                    DO:
                        PAGE STREAM str_1.
                       
                        DISPLAY STREAM str_1 
                                crapdat.dtmvtocd WITH FRAME f_cab.
                    END.
            END.
   
        CLEAR FRAME f_lotes.
       
        DISPLAY STREAM str_1  
                tt-lote.cdagenci  
                tt-lote.cdbccxlt  
                tt-lote.nrdolote 
                tt-lote.qttitulo
                tt-lote.vltitulo 
                tt-lote.nmoperad
                tt-lote.nmarquiv
                WITH FRAME f_lotes.

        ASSIGN pac_qtdlotes = pac_qtdlotes + 1
               pac_qttitulo = pac_qttitulo + tt-lote.qttitulo
               pac_vltitulo = pac_vltitulo + tt-lote.vltitulo.

        DOWN STREAM str_1 WITH FRAME f_lotes.                     
    
        RUN proc_lista. 
   
    END.  /* FOR EACH tt-lote */
   
    PAGE STREAM str_1.
   
    IF  p-impressao = YES  THEN 
        DO:
            PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
            PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
        END.

    OUTPUT  STREAM str_1 CLOSE.

    IF  p-impressao = YES  THEN  
        DO:
            ASSIGN i-nro-vias = 1
                   aux_dscomand = "lp -d" + aux_nmdafila        +
                                  " -n" + STRING(i-nro-vias)    +   
                                  " -oMTl88 " + aux_nmarqimp    +     
                                  " > /dev/null".

            UNIX SILENT VALUE(aux_dscomand).
      
        END.  /* impressora */
   
   RETURN "OK".
   
END PROCEDURE.

/* Procedures Internas */
   
PROCEDURE mostra_dados:

    DEF VAR aux_nrdigito AS INT                                      NO-UNDO.

    /*  Compoe a linha digitavel atraves do codigo de barras  */

    ASSIGN tel_nrcampo1 = DECIMAL(SUBSTRING(tel_dscodbar,01,04) +
                                  SUBSTRING(tel_dscodbar,20,01) +
                                  SUBSTRING(tel_dscodbar,21,04) + "0")
                                  
           tel_nrcampo2 = DECIMAL(SUBSTRING(tel_dscodbar,25,10) + "0")
           tel_nrcampo3 = DECIMAL(SUBSTRING(tel_dscodbar,35,10) + "0")
           tel_nrcampo4 = INTEGER(SUBSTRING(tel_dscodbar,05,01))
           tel_nrcampo5 = DECIMAL(SUBSTRING(tel_dscodbar,06,14)).
           
    RUN dbo/pcrap03.p (INPUT-OUTPUT tel_nrcampo1,      
                       INPUT        TRUE,              /* Validar zeros */      
                             OUTPUT aux_nrdigito,      /* Sem uso       */
                             OUTPUT l-retorno).
                              
    RUN dbo/pcrap03.p (INPUT-OUTPUT tel_nrcampo2,      
                       INPUT        FALSE,             /* Validar zeros */ 
                             OUTPUT aux_nrdigito,      /* Sem uso       */
                             OUTPUT l-retorno).
                              
    RUN dbo/pcrap03.p (INPUT-OUTPUT tel_nrcampo3,      
                       INPUT        FALSE,             /* Validar zeros */
                             OUTPUT aux_nrdigito,      /* Sem uso       */
                             OUTPUT l-retorno).

    tel_dsdlinha = STRING(tel_nrcampo1,"99999,99999")  + " " +
                   STRING(tel_nrcampo2,"99999,999999") + " " +
                   STRING(tel_nrcampo3,"99999,999999") + " " +
                   STRING(tel_nrcampo4,"9")            + " " +
                   STRING(tel_nrcampo5,"zzzzzzzzzzz999"). 

END PROCEDURE.

PROCEDURE proc_resgates:

    FOR EACH craptit WHERE craptit.cdcooper  = crapcop.cdcooper     AND
                           craptit.dtmvtolt  = craplot.dtmvtolt     AND
                           craptit.cdagenci  = craplot.cdagenci     AND
                           craptit.cdbccxlt  = craplot.cdbccxlt     AND
                           craptit.nrdolote  = craplot.nrdolote     AND
                           craptit.dtdevolu <> ?                    NO-LOCK:
    
        ASSIGN tt-lote.qttitulo = tt-lote.qttitulo - 1
               tt-lote.vltitulo = tt-lote.vltitulo - craptit.vldpagto.
    
    END.  /*  for each craptit */

END PROCEDURE.

PROCEDURE proc_lista:

    VIEW STREAM str_1 FRAME f_linha.
    
    FOR EACH craptit WHERE craptit.cdcooper = crapcop.cdcooper  AND
                           craptit.dtmvtolt = crapdat.dtmvtocd  AND
                           craptit.cdagenci = tt-lote.cdagenci  AND
                           craptit.cdbccxlt = tt-lote.cdbccxlt  AND
                           craptit.nrdolote = tt-lote.nrdolote  NO-LOCK
                           BREAK BY craptit.intitcop:
                                                    
        IF   FIRST-OF(craptit.intitcop)   THEN
             DO:
                 IF craptit.intitcop = 1 THEN
                    VIEW STREAM str_1 FRAME f_titcop.

                 ASSIGN tel_qttitulo = 0
                        tel_vltitulo = 0.
             END.                                   

        ASSIGN tel_dscodbar = craptit.dscodbar.

        RUN mostra_dados.
        ASSIGN aux_flgtitcop = "N".
        IF craptit.intitcop = 1 THEN
           ASSIGN aux_flgtitcop = "S".
           
        DISPLAY STREAM str_1 
                tel_dsdlinha       COLUMN-LABEL "Codigo"
                craptit.vldpagto 
                craptit.nrseqdig
                aux_flgtitcop
                WITH FRAME f_lanctos STREAM-IO.

        DOWN STREAM str_1 WITH FRAME f_lanctos.

        ASSIGN tel_qttitulo = tel_qttitulo + 1
               tel_vltitulo = tel_vltitulo + craptit.vldpagto.

        IF   LINE-COUNTER(str_1) > 80  THEN DO:
             PAGE STREAM str_1.
             DISPLAY STREAM str_1 crapdat.dtmvtocd WITH FRAME f_cab.
            
             DISPLAY STREAM str_1  
                     tt-lote.cdagenci 
                     tt-lote.cdbccxlt  
                     tt-lote.nrdolote 
                     tt-lote.qttitulo
                     tt-lote.vltitulo
                     tt-lote.nmoperad
                     tt-lote.nmarquiv
                     WITH FRAME f_lotes. 
            VIEW STREAM str_1 FRAME f_linha.
        END.
                                                          
        IF   LAST-OF(craptit.intitcop)   THEN
             DISPLAY STREAM str_1 tel_qttitulo tel_vltitulo 
                     WITH FRAME f_totais.                   

    END.  /*  for each   */
    
    ASSIGN tel_dscodbar = "".

    VIEW STREAM str_1 FRAME f_linha.
    
END PROCEDURE.

/* b1crap32.p */

/* .......................................................................... */

