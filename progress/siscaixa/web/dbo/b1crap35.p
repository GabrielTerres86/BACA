/*----------------------------------------------------------------------------

    b1crap35.p - Controle Titulos/Faturas Coban
    
    Ultima Atualizacao: 05/08/2014
    
    Alteracoes: 23/02/2006 - Unificacao dos bancos - SQLWorks - Eder
    
                06/05/2009 - Tratamento para pagamentos não ativos (David).
                
                20/10/2010 - Incluido caminho completo nas referencias do 
                             diretorio spool (Elton).
                             
                23/05/2011 - Alterada a leitura da tabela craptab para a 
                             tabela crapope (Isara - RKAM).
                             
                28/09/2011 - Incluido crapcop.dsdircop na geracao do relatorio 
                              em tela (Elton).             
                
                30/09/2011 - Alterar diretorio spool para
                             /usr/coop/sistema/siscaixa/web/spool (Fernando).
                             
                05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
-----------------------------------------------------------------------------*/

{dbo/bo-erro1.i}

DEF  VAR i-cod-erro  AS INTEGER.
DEF  VAR c-desc-erro AS CHAR.

DEF STREAM str_1.

DEF VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF VAR aux_dssitpag AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF VAR lot_nmoperad AS CHAR                                  NO-UNDO.
DEF VAR aux_flgfirst AS LOGI                                  NO-UNDO.

DEF VAR aux_qttitulo AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF VAR aux_vltitulo AS DECI    FORMAT "zzz,zzz,zz9.99"       NO-UNDO.  
DEF VAR aux_qtfatura AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF VAR aux_vlfatura AS DECI    FORMAT "zzz,zzz,zz9.99"       NO-UNDO. 

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

FORM crapdat.dtmvtolt  AT 1   LABEL "REFERENCIA"   FORMAT "99/99/9999"
     SKIP(1)
     "PA  CXA    LOTE" AT 1
     "   QTD.           VALOR"        
     "OPERADOR      " 
     SKIP(1)
     WITH SIDE-LABELS NO-BOX WIDTH 132 FRAME f_cab STREAM-IO.
                                
FORM tt-lote.cdagenci AT  1              
     tt-lote.cdbccxlt AT  5               
     tt-lote.nrdolote AT  9 
     tt-lote.qttitulo AT 17               
     tt-lote.vltitulo AT 25             
     tt-lote.nmoperad AT 41           
     WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_lotes STREAM-IO.
      
FORM SKIP(2)
     aux_dssitpag NO-LABEL 
     SKIP(1)
     WITH COLUMN 4 NO-BOX FRAME f_situacao.      

FORM crapcbb.cdbarras FORMAT "x(56)"         COLUMN-LABEL "Codigo Barras"     
     crapcbb.valorpag FORMAT "zzzzzz,zz9.99" COLUMN-LABEL "Valor Pago"
     crapcbb.nrseqdig FORMAT "zzzz9"         COLUMN-LABEL "Seq."
     WITH COLUMN 4 NO-BOX
 
DOWN FRAME f_lanctos.

FORM SKIP(1) WITH NO-BOX FRAME f_linha STREAM-IO.

PROCEDURE Impressao:

    DEF  INPUT PARAM p-cooper        AS CHAR.
    DEF  INPUT PARAM p-cod-operador  AS CHAR.
    DEF  INPUT PARAM p-cod-agencia   AS INTE.
    DEF  INPUT PARAM p-nro-caixa     AS INTE.
    DEF  INPUT PARAM p-nro-lote      AS INTE.
    DEF  INPUT PARAM p-impressao     AS LOGI.
    DEF OUTPUT PARAM p-nome-arquivo  AS CHAR.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

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

    IF  p-impressao = YES  THEN  /* Impressao */  
        DO:              
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
            
            ASSIGN aux_nmdafila = LC(crapope.dsimpres)            
                   aux_nmarqimp = "/usr/coop/sistema/siscaixa/web/spool/" + 
                                  crapcop.dsdircop +  
                                  STRING(p-cod-agencia) +
                                  STRING(p-nro-caixa) + 
                                  "b1035.txt".  /* Nome Fixo  */        
        END.
    ELSE 
        DO:
            ASSIGN aux_nmarqimp   = "/usr/coop/sistema/siscaixa/web/spool/" +
                                    crapcop.dsdircop + 
                                    STRING(p-cod-agencia) + 
                                    STRING(p-nro-caixa) +
                                    "b1035.txt"  /* Nome Fixo  */
                   p-nome-arquivo = "spool/" +
                                    crapcop.dsdircop + 
                                    STRING(p-cod-agencia) + 
                                    STRING(p-nro-caixa) +
                                    "b1035.txt".
        END.

    FIND crapemp WHERE crapemp.cdcooper = crapcop.cdcooper AND
                       crapemp.cdempres  = 11              NO-LOCK NO-ERROR.
         
    IF  NOT AVAIL crapemp  THEN
        ASSIGN rel_nmresemp = FILL("?",11).
    ELSE
        ASSIGN rel_nmresemp = SUBSTRING(crapemp.nmresemp,1,11).
    
    ASSIGN rel_nmrelato      = "COBAN".

    FORM HEADER 
         rel_nmresemp               FORMAT "x(11)"
         "-"
         rel_nmrelato               FORMAT "x(36)"
         "REF P035 "
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

    DISPLAY STREAM str_1 crapdat.dtmvtolt WITH FRAME f_cab.    

    EMPTY TEMP-TABLE tt-lote.
   
    FOR EACH craplot WHERE (craplot.cdcooper = crapcop.cdcooper      AND
                            craplot.dtmvtolt = crapdat.dtmvtolt      AND                            
                            craplot.cdagenci = p-cod-agencia         AND
                            craplot.cdbccxlt = 11                    AND
                            craplot.tplotmov = 28)                   OR                    
                           (craplot.cdcooper = crapcop.cdcooper      AND
                            craplot.dtmvtopg = crapdat.dtmvtolt      AND
                            craplot.cdagenci = p-cod-agencia         AND
                            craplot.tplotmov = 28)               
                            NO-LOCK BREAK BY craplot.cdagenci
                                             BY craplot.cdbccxlt
                                                BY craplot.nrdolote:

        IF  p-nro-lote <> craplot.nrdolote  THEN  
            NEXT.
     
        FIND crapope WHERE crapope.cdcooper = crapcop.cdcooper AND
                           crapope.cdoperad = craplot.cdoperad NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE crapope  THEN
            lot_nmoperad = craplot.cdoperad.
        ELSE
            lot_nmoperad = ENTRY(1,crapope.nmoperad," ").

        CREATE tt-lote.
        ASSIGN tt-lote.cdagenci = craplot.cdagenci
               tt-lote.cdbccxlt = craplot.cdbccxlt
               tt-lote.nrdolote = craplot.nrdolote
               tt-lote.qttitulo = craplot.qtinfoln
               tt-lote.vltitulo = craplot.vlcompcr              
               tt-lote.nmoperad = lot_nmoperad.            
   
    END.  /*  for each craplot */
        
    FOR EACH tt-lote BREAK BY tt-lote.cdagenci
                              BY tt-lote.cdbccxlt 
                                 BY tt-lote.nrdolote:
       
        IF  FIRST-OF(tt-lote.cdagenci)  THEN 
            DO:
                IF  LINE-COUNTER(str_1) > 80  THEN 
                    DO:
                        PAGE STREAM str_1.
                               
                        DISPLAY STREAM str_1 crapdat.dtmvtolt WITH FRAME f_cab.
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
            ASSIGN i-nro-vias   = 1
                   aux_dscomand = "lp -d" + aux_nmdafila +
                   " -n" + STRING(i-nro-vias) +   
                   " -oMTl88 " + aux_nmarqimp +     
                   " > /dev/null".
                   
            UNIX SILENT VALUE(aux_dscomand).      
        END.   

    RETURN "OK".
   
END PROCEDURE.

/* Procedures Internas */
   
PROCEDURE proc_lista:
  
    ASSIGN aux_flgfirst = TRUE
           aux_dssitpag = "EFETIVADOS"
           aux_qttitulo = 0
           aux_vltitulo = 0
           aux_qtfatura = 0
           aux_vlfatura = 0.
    
    FOR EACH crapcbb WHERE crapcbb.cdcooper = crapcop.cdcooper  AND
                           crapcbb.dtmvtolt = crapdat.dtmvtolt  AND                           
                           crapcbb.cdagenci = tt-lote.cdagenci  AND
                           crapcbb.cdbccxlt = tt-lote.cdbccxlt  AND
                           crapcbb.nrdolote = tt-lote.nrdolote  AND
                           crapcbb.flgrgatv = TRUE              AND
                           crapcbb.flgrgfim = TRUE              NO-LOCK:   
                               
        RUN proc_lista_detalhado.

    END. 

    IF  NOT aux_flgfirst  THEN
        RUN proc_lista_totais.   
    
    ASSIGN aux_flgfirst = TRUE
           aux_dssitpag = "NAO EFETIVADOS"
           aux_qttitulo = 0
           aux_vltitulo = 0
           aux_qtfatura = 0
           aux_vlfatura = 0.
    
    FOR EACH crapcbb WHERE crapcbb.cdcooper = crapcop.cdcooper  AND
                           crapcbb.dtmvtolt = crapdat.dtmvtolt  AND                           
                           crapcbb.cdagenci = tt-lote.cdagenci  AND
                           crapcbb.cdbccxlt = tt-lote.cdbccxlt  AND
                           crapcbb.nrdolote = tt-lote.nrdolote  AND
                           crapcbb.flgrgatv = TRUE              AND
                           crapcbb.flgrgfim = FALSE             NO-LOCK:   
                               
        RUN proc_lista_detalhado.

    END. 

    IF  NOT aux_flgfirst  THEN
        RUN proc_lista_totais.
   
END PROCEDURE.

PROCEDURE proc_lista_detalhado:
    
    IF  crapcbb.tpdocmto = 1  THEN   /* Titulo */
        ASSIGN aux_qttitulo = aux_qttitulo + 1
               aux_vltitulo = aux_vltitulo + crapcbb.valorpag.
    ELSE
        ASSIGN aux_qtfatura = aux_qtfatura + 1
               aux_vlfatura = aux_vlfatura + crapcbb.valorpag.
                           
    IF  aux_flgfirst  THEN
        DO:
            DISPLAY STREAM str_1 aux_dssitpag WITH FRAME f_situacao.
            
            aux_flgfirst = FALSE.
        END.                           

    DISPLAY STREAM str_1 crapcbb.cdbarras COLUMN-LABEL "Codigo"
                         crapcbb.valorpag COLUMN-LABEL "Valor"
                         crapcbb.nrseqdig
                         WITH FRAME f_lanctos STREAM-IO.

    DOWN STREAM str_1 WITH FRAME f_lanctos.

    IF  LINE-COUNTER(str_1) > 80  THEN 
        DO:
            PAGE STREAM str_1.
                 
            DISPLAY STREAM str_1 crapdat.dtmvtolt WITH FRAME f_cab.
                
            DISPLAY STREAM str_1 tt-lote.cdagenci 
                                 tt-lote.cdbccxlt  
                                 tt-lote.nrdolote 
                                 tt-lote.qttitulo
                                 tt-lote.vltitulo
                                 tt-lote.nmoperad
                                 WITH FRAME f_lotes. 
                
            VIEW STREAM str_1 FRAME f_linha.
                 
            DISPLAY STREAM str_1 aux_dssitpag WITH FRAME f_situacao.
        END.
    
END PROCEDURE.

PROCEDURE proc_lista_totais:     
            
    DISPLAY STREAM str_1 
        "TOTAL Titulos" @ crapcbb.cdbarras   
        aux_vltitulo    @ crapcbb.valorpag  
        aux_qttitulo    @ crapcbb.nrseqdig
        WITH FRAME f_lanctos STREAM-IO.
        
    DOWN STREAM str_1 WITH FRAME f_lanctos.
     
    DISPLAY STREAM str_1 
        "TOTAL Faturas" @ crapcbb.cdbarras                         
        aux_vlfatura    @ crapcbb.valorpag   
        aux_qtfatura    @ crapcbb.nrseqdig
        WITH FRAME f_lanctos STREAM-IO.
        
    DOWN STREAM str_1 WITH FRAME f_lanctos.
    
    DISPLAY STREAM str_1 
        "TOTAL Geral"                 @ crapcbb.cdbarras                         
        (aux_vlfatura + aux_vltitulo) @ crapcbb.valorpag   
        (aux_qtfatura + aux_qttitulo) @ crapcbb.nrseqdig
        WITH FRAME f_lanctos STREAM-IO.
        
    DOWN STREAM str_1 WITH FRAME f_lanctos.        
    
END PROCEDURE.

/* b1crap35.p */

/* .......................................................................... */

