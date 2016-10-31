/*----------------------------------------------------------------------------

    b1crap36. - Controle Lancamentos GPS
    
    Ultima Atualizacao: 06/10/2016
    
    Alteracoes:
                23/02/2006 - Unificacao dos bancos - SQLWorks - Eder
                
                13/01/2009 - Inclusao de novas colunas no relatorio (Elton).
                
                20/10/2010 - Incluido caminho completo nas referencias do 
                             diretorio spool (Elton).
                             
                23/05/2011 - Alterada a leitura da tabela craptab para a 
                             tabela crapope (Isara - RKAM).
                             
                28/09/2011 - Incluido crapcop.dsdircop na geracao do relatorio em
                             tela (Elton).
                             
                30/09/2011 - Alterar diretorio spool para
                             /usr/coop/sistema/siscaixa/web/spool (Fernando).
                             
                30/05/2014 - Ajuste de display de crapcgp.nmprimtl para mostrar
                             apenas WHEN AVAIL crapcgp (Carlos)
                             
                05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).

                06/10/2016 - SD 489677 - Inclusao do flgativo na CRAPLGP
                             (Guilherme/SUPERO)
-----------------------------------------------------------------------------*/
{dbo/bo-erro1.i}

DEF  VAR i-cod-erro  AS INTEGER.
DEF  VAR c-desc-erro AS CHAR.

DEF STREAM str_1.

DEF VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF VAR lot_nmoperad AS CHAR                                  NO-UNDO.

DEF VAR pac_qtdlotes AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF VAR pac_qtgps    AS INT     FORMAT "zzz,zz9"                NO-UNDO.
DEF VAR pac_vlgps    AS DECIMAL FORMAT "zzz,zzz,zz9.99"       NO-UNDO.

DEF VAR aux_qtgps    AS INT     FORMAT "zzzz9"              NO-UNDO.
DEF VAR aux_vlgps    AS DECIMAL FORMAT "zzz,zzz,zz9.99"       NO-UNDO.  

DEF VAR aux_nmdafila AS CHAR                                  NO-UNDO.
DEF VAR i-nro-vias   AS INTE                                  NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                  NO-UNDO.

DEF TEMP-TABLE tt-lote                                        NO-UNDO
    FIELD cdagenci AS INT     FORMAT "zz9"
    FIELD cdbccxlt AS INT     FORMAT "zz9"
    FIELD nrdolote AS INT     FORMAT "zzz,zz9"
    FIELD qttitulo AS INT     FORMAT "zzz,zz9"
    FIELD vltitulo AS DECIMAL FORMAT "zzzz,zzz,zz9.99"
    FIELD nmoperad AS CHAR    FORMAT "x(10)".

FORM crapdat.dtmvtolt  AT   1   LABEL "REFERENCIA"   FORMAT "99/99/9999"
     SKIP(1)
     "PA  CXA    LOTE"           AT  1
     "   QTD.           VALOR"        
     "OPERADOR      " 
     SKIP(1)
     WITH SIDE-LABELS NO-BOX WIDTH 132 FRAME f_cab STREAM-IO.
                                
FORM  tt-lote.cdagenci AT  1              
      tt-lote.cdbccxlt AT  5               
      tt-lote.nrdolote AT  9 
      tt-lote.qttitulo AT 17               
      tt-lote.vltitulo AT 25             
      tt-lote.nmoperad AT 41           
      WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_lotes STREAM-IO.

FORM craplgp.cdidenti                         COLUMN-LABEL "Identificador"     
     craplgp.cddpagto                         COLUMN-LABEL "Codigo"
     crapcgp.nmprimtl FORMAT "x(33)"          COLUMN-LABEL "Contribuinte"
     craplgp.mmaacomp                         COLUMN-LABEL "Competencia"
     craplgp.vlrdinss FORMAT "zz,zzz,zz9.99"  COLUMN-LABEL "Valor INSS"
     craplgp.vlrouent FORMAT "zz,zzz,zz9.99"  COLUMN-LABEL "Vlr Entidades"
     craplgp.vlrjuros FORMAT "zz,zzz,zz9.99"  COLUMN-LABEL "Valor Juros"
     craplgp.vlrtotal FORMAT "zzz,zzz,zz9.99" COLUMN-LABEL "Valor Total"
     craplgp.nrseqdig FORMAT "zzzz9"          COLUMN-LABEL "Seq."
     WITH  NO-BOX DOWN WIDTH 132 FRAME f_lanctos.

FORM SKIP(1) WITH NO-BOX FRAME f_linha STREAM-IO.

FORM  SKIP(2)
      "TOTAL GPS:" AT 102                              
      aux_vlgps    AT 113 NO-LABEL      
      aux_qtgps    AT 128 NO-LABEL      
      WITH NO-BOX DOWN WIDTH 132 FRAME f_total STREAM-IO.


FORM SKIP(2) "Conferente:_______________________________________" SKIP
             WITH NO-BOX WIDTH 132 FRAME f_conferente STREAM-IO.



PROCEDURE Impressao:

    DEF INPUT  param p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-operador  AS CHAR.
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

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
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
        
            ASSIGN aux_nmarqimp =  "/usr/coop/sistema/siscaixa/web/spool/" +
                                   crapcop.dsdircop +  
                                   STRING(p-cod-agencia) +
                                   STRING(p-nro-caixa) + 
                                   "b1036.txt".  /* Nome Fixo  */
        END.
    ELSE 
        DO:
            ASSIGN aux_nmarqimp   = "/usr/coop/sistema/siscaixa/web/spool/" +
                                    crapcop.dsdircop +  
                                    STRING(p-cod-agencia) + 
                                    STRING(p-nro-caixa) +
                                    "b1036.txt".  /* Nome Fixo  */

            ASSIGN p-nome-arquivo = "spool/" + crapcop.dsdircop + 
                                    STRING(p-cod-agencia) + 
                                    STRING(p-nro-caixa) + "b1036.txt".
        END.

    FIND crapemp WHERE crapemp.cdcooper = crapcop.cdcooper  AND
                       crapemp.cdempres = 11                NO-LOCK NO-ERROR.
    IF   NOT AVAIL crapemp   THEN
         ASSIGN rel_nmresemp = FILL("?",11).
    ELSE
         ASSIGN rel_nmresemp = SUBSTRING(crapemp.nmresemp,1,11).
    
    ASSIGN rel_nmrelato      = "GPS".  

    FORM HEADER 
         rel_nmresemp               FORMAT "x(11)"
         "-"
         rel_nmrelato               FORMAT "x(36)"
         "REF P036 "
         STRING(TIME,"HH:MM")       FORMAT "x(5)"
         "PAG: "                   
         PAGE-NUMBER(str_1)         FORMAT "zz9"
         
         WITH PAGE-TOP NO-BOX NO-ATTR-SPACE FRAME f_cabrel080_1 STREAM-IO.
                                           
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
    
    IF  p-impressao = YES  THEN 
        VIEW STREAM str_1 FRAME f_cabrel080_1.

    DISPLAY STREAM str_1  crapdat.dtmvtolt WITH FRAME f_cab.
    
    /*
    FOR  EACH tt-lote:
         DELETE tt-lote.
    END.  /*  Fim do FOR EACH  */
    */
    EMPTY TEMP-TABLE tt-lote.
   
    FOR EACH craplot WHERE (craplot.cdcooper = crapcop.cdcooper      AND
                            craplot.dtmvtolt = crapdat.dtmvtolt      AND
                            craplot.cdagenci = p-cod-agencia         AND
                            craplot.cdbccxlt = 11                    AND
                            craplot.tplotmov = 30)                    OR

                           (craplot.cdcooper = crapcop.cdcooper      AND
                            craplot.dtmvtopg = crapdat.dtmvtolt      AND
                            craplot.cdagenci = p-cod-agencia         AND
                            craplot.tplotmov = 30)               NO-LOCK
                           BREAK BY craplot.cdagenci
                                    BY craplot.cdbccxlt
                                       BY craplot.nrdolote:
                                       

       IF   p-nro-lote <> craplot.nrdolote   THEN  NEXT.
     
       /* FIND crapope OF craplot NO-LOCK NO-ERROR. */
       FIND crapope WHERE crapope.cdcooper = crapcop.cdcooper   AND
                          crapope.cdoperad = craplot.cdoperad   
                          NO-LOCK NO-ERROR.
    
       IF   NOT AVAILABLE crapope   THEN
            lot_nmoperad = craplot.cdoperad.
       ELSE
            lot_nmoperad = ENTRY(1,crapope.nmoperad," ").

       CREATE tt-lote.
       ASSIGN tt-lote.cdagenci = craplot.cdagenci
              tt-lote.cdbccxlt = craplot.cdbccxlt
              tt-lote.nrdolote = craplot.nrdolote
              tt-lote.qttitulo = craplot.qtinfoln
              tt-lote.vltitulo = craplot.vlcompdb              
              tt-lote.nmoperad = lot_nmoperad.
      
       RUN proc_gps.               
   
   END.  /*  for each craplot */
  
   ASSIGN pac_qtdlotes = 0
          pac_qtgps    = 0
          pac_vlgps    = 0.
    
   FOR EACH tt-lote BREAK BY tt-lote.cdagenci
                             BY tt-lote.cdbccxlt 
                                BY tt-lote.nrdolote:
       
       IF   FIRST-OF(tt-lote.cdagenci)   THEN 
            DO:
                IF  LINE-COUNTER(str_1) > 80  THEN 
                    DO:
                        PAGE STREAM str_1.
                       
                        DISPLAY STREAM str_1 
                                crapdat.dtmvtolt WITH FRAME f_cab.
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
               WITH FRAME f_lotes.

       ASSIGN pac_qtdlotes = pac_qtdlotes + 1
              pac_qtgps    = pac_qtgps    + tt-lote.qttitulo
              pac_vlgps    = pac_vlgps    + tt-lote.vltitulo.

       DOWN STREAM str_1 WITH FRAME f_lotes.                     
    
       RUN proc_lista. 
   
   END.  /* FOR EACH tt-lote */
   
   PAGE STREAM str_1.
   
   OUTPUT  STREAM str_1 CLOSE.
   
   IF  p-impressao = YES  THEN  DO:
       assign i-nro-vias = 1.
       aux_dscomand = "lp -d" + aux_nmdafila +
                      " -n" + STRING(i-nro-vias) +   
                      " -oMTl88 " + " -oMTf" + "132col" + " " + 
                      aux_nmarqimp +      
                      " > /dev/null".

       UNIX SILENT VALUE(aux_dscomand).
      
   END.  /* impressora */
   
   RETURN "OK".
END PROCEDURE.

/* Procedures Internas */
   
PROCEDURE proc_gps:              

    FOR EACH craplgp WHERE craplgp.cdcooper = crapcop.cdcooper  AND
                           craplgp.dtmvtolt = craplot.dtmvtolt  AND
                           craplgp.cdagenci = craplot.cdagenci  AND
                           craplgp.cdbccxlt = craplot.cdbccxlt  AND
                           craplgp.nrdolote = craplot.nrdolote
                       AND craplgp.flgativo = YES               NO-LOCK:
                           
        ASSIGN aux_qtgps    = aux_qtgps     + 1
               aux_vlgps    = aux_vlgps     + craplgp.vlrtotal.

    END.  /*  for each craplgp */

END PROCEDURE.

PROCEDURE proc_lista:

    VIEW STREAM str_1 FRAME f_linha.
    
    FOR EACH craplgp WHERE craplgp.cdcooper = crapcop.cdcooper  AND
                           craplgp.dtmvtolt = crapdat.dtmvtolt  AND
                           craplgp.cdagenci = tt-lote.cdagenci  AND
                           craplgp.cdbccxlt = tt-lote.cdbccxlt  AND
                           craplgp.nrdolote = tt-lote.nrdolote
                       AND craplgp.flgativo = YES               NO-LOCK
                           BY craplgp.nrseqdig:

        FIND crapcgp WHERE  crapcgp.cdcooper = craplgp.cdcooper AND
                            crapcgp.cdidenti = craplgp.cdidenti AND
                            crapcgp.cddpagto = craplgp.cddpagto 
                            NO-LOCK NO-ERROR.
        
        DISPLAY STREAM str_1 
                craplgp.cdidenti   
                craplgp.cddpagto
                crapcgp.nmprimtl WHEN AVAIL crapcgp
                craplgp.mmaacomp
                craplgp.vlrdinss
                craplgp.vlrouent
                craplgp.vlrjuros
                craplgp.vlrtotal
                craplgp.nrseqdig
                WITH FRAME f_lanctos STREAM-IO.

        DOWN STREAM str_1 WITH FRAME f_lanctos.

        IF   LINE-COUNTER(str_1) > 80  THEN DO:
             PAGE STREAM str_1.
             DISPLAY STREAM str_1 crapdat.dtmvtolt WITH FRAME f_cab.
            
             DISPLAY STREAM str_1  
                     tt-lote.cdagenci 
                     tt-lote.cdbccxlt  
                     tt-lote.nrdolote 
                     tt-lote.qttitulo
                     tt-lote.vltitulo
                     tt-lote.nmoperad
                     WITH FRAME f_lotes. 
            VIEW STREAM str_1 FRAME f_linha.
         END.

    END.  /*  for each   */
    
    DISPLAY STREAM str_1 aux_vlgps aux_qtgps WITH FRAME f_total.
        
    VIEW STREAM str_1 FRAME f_linha.
    
    VIEW STREAM str_1 FRAME f_conferente.
    
END PROCEDURE.

/* b1crap36.p */

/* .......................................................................... */

