/*-----------------------------------------------------------------------------

    b1crap33.p - Controle Cheques (Impressao Detalhado/Resumido)
    
    Ultima Atualizacao: 05/08/2014
    
    Alteracoes:
                23/02/2006 - Unificacao dos bancos - SQLWorks - Eder
                
                20/10/2010 - Incluido caminho completo nas referencias do 
                             diretorio spool (Elton).
                             
                23/05/2011 - Alterada a leitura da tabela craptab para a 
                             tabela crapope (Isara - RKAM).
                             
                22/09/2011 - Incluir lote 28000 e 30000 ref rotina 66 LANCHQ
                             (Guilherme).
                             
                28/09/2011 - Incluido crapcop.dsdircop no caminho da geracao do
                             relatorio em tela (Elton).
                            
                30/09/2011 - Alterar diretorio spool para
                             /usr/coop/sistema/siscaixa/web/spool (Fernando).  
                             
                09/12/2013 - Alterado estrutura de leitura da tabela craplot (Daniel).     
                
                05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).        

                03/07/2017 - Remover separaçao de cheques Superiores e Inferiores na geraçao 
                             do relatório Resumido. PRJ367 - Compe Sessao Unica (Lombardi)       
                
                22/06/2018 - Alterado para considerar o campo crapdat.dtmvtocd 
                             como data de referencia - Everton Deserto(AMCOM).
                             
                16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
                     Heitor (Mouts)
                             
------------------------------------------------------------------------------ **/
{dbo/bo-erro1.i}

DEF VAR i-cod-erro   AS INTEGER.
DEF VAR c-desc-erro  AS CHAR.

DEF STREAM str_1.

DEF TEMP-TABLE tt-cheque                                        NO-UNDO
    FIELD cdagenci AS INT     FORMAT "zz9"
    FIELD cdbccxlt AS INT     FORMAT "zz9"
    FIELD nrdolote AS INT     FORMAT "zzz,zz9"
    FIELD tpdmovto AS INT     FORMAT "9"
    FIELD qtchdrec AS INT     FORMAT "zzz,zz9"
    FIELD vlchdrec AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"
    FIELD nmarquiv AS CHAR    FORMAT "x(25)".
  
DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
DEF VAR aux_qtchdrec AS INT                                     NO-UNDO.
DEF VAR aux_vlchdrec AS DEC                                     NO-UNDO.
DEF VAR pac_qtchdrec AS INT        FORMAT "zzz,zz9"             NO-UNDO.
DEF VAR pac_vlchdrec AS DEC        FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.

DEF VAR rel_nmresemp AS CHAR       FORMAT "x(15)"               NO-UNDO.
DEF VAR rel_nmrelato AS CHAR       FORMAT "x(40)"               NO-UNDO.
DEF VAR tab_vlchqmai AS DEC                                     NO-UNDO.

DEF VAR res_qtchqcop AS INT        FORMAT "zzz,zz9"             NO-UNDO.

DEF VAR res_vlchqcop AS DECIMAL    FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF VAR res_vlchqmen AS DECIMAL    FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF VAR res_vlchqmai AS DECIMAL    FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF VAR tot_qtcheque AS INT        FORMAT "zzz,zz9"             NO-UNDO.
DEF VAR tot_vlcheque AS DECIMAL    FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF VAR res_dschqcop AS CHAR       FORMAT "x(20)"               NO-UNDO.
DEF VAR aux_exarquiv AS CHAR                                    NO-UNDO.

DEF VAR aux_nmdafila AS CHAR                                    NO-UNDO.
DEF VAR i-nro-vias   AS INTE                                    NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                    NO-UNDO.

DEF VAR i-nrlote1    LIKE craplot.nrdolote                      NO-UNDO.
DEF VAR i-nrlote2    LIKE craplot.nrdolote                      NO-UNDO.
DEF VAR i-nrlote3    LIKE craplot.nrdolote                      NO-UNDO.
DEF VAR i-nrlote4    LIKE craplot.nrdolote                      NO-UNDO.

FORM crapdat.dtmvtocd  AT   1   LABEL "REFERENCIA"   FORMAT "99/99/9999"  /* 22/06/2018 - Alterado para o campo dtmvtocd - Everton(AMCOM).*/
     SKIP
     "PA   QTD. CHEQUES"         AT  1
     "VALOR " AT 33       
     SKIP(1)
     WITH SIDE-LABELS NO-BOX WIDTH 132 FRAME f_cab STREAM-IO.
      
FORM  tt-cheque.cdagenci AT  1               
      tt-cheque.qtchdrec AT 11               
      tt-cheque.vlchdrec AT 20     
      tt-cheque.nmarquiv AT 43 
      WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_lotes STREAM-IO.

FORM  SKIP(1)
      pac_qtchdrec        AT   11               NO-LABEL
      pac_vlchdrec        AT   20               NO-LABEL
      SKIP
      "--------------------------------------------------------------------------"
      WITH NO-LABELS NO-BOX  WIDTH 80 FRAME f_pac STREAM-IO.  

FORM crapchd.nrdconta FORMAT "zzzz,zzz,9"   LABEL "Conta/DV"
     crapchd.nrdocmto FORMAT "zzzzzz,zz9"   LABEL "Docmto"
     crapchd.cdcmpchq FORMAT "999"          LABEL "Cmp"
     crapchd.cdbanchq FORMAT "999"          LABEL "Bco"
     crapchd.cdagechq FORMAT "9999"         LABEL "Ag."
     crapchd.nrddigv1 FORMAT "Z9"           LABEL "C1"
     crapchd.nrctachq FORMAT "ZZZZZZZZZ9"   LABEL "Conta"
     crapchd.nrddigv2 FORMAT "Z9"           LABEL "C2"
     crapchd.nrcheque FORMAT "999999"       LABEL "Cheque"
     crapchd.nrddigv3 FORMAT "Z9"           LABEL "C3"
     crapchd.vlcheque FORMAT "ZZZZZ,ZZ9.99" LABEL "Valor"
     crapchd.nrseqdig FORMAT "Z,ZZ9"        LABEL "Seq."
     WITH NO-BOX NO-LABELS DOWN FRAME f_lanctos STREAM-IO.

FORM SKIP(1) WITH NO-BOX FRAME f_linha STREAM-IO.

FORM SKIP(1)
/*   res_dschqcop AT  3 NO-LABEL
     res_qtchqcop AT 24 NO-LABEL
     res_vlchqcop AT 34 NO-LABEL   */
     "** CARTA REMESSA **" AT 25
     SKIP(1)                           
     tot_qtcheque AT  8 LABEL "TOTAL DIGITADO"
     tot_vlcheque AT 34 NO-LABEL
     SKIP(1)
     WITH ROW 10 CENTERED SIDE-LABELS OVERLAY TITLE " Resumo da Digitacao " FRAME f_resumo STREAM-IO.

PROCEDURE Impressao:

    DEF INPUT  PARAM p-cooper           AS CHAR.
    DEF INPUT  PARAM p-cod-operador     AS char.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
    DEF INPUT  PARAM p-nro-lote         AS INTE.
    DEF INPUT  PARAM p-detalhado        AS LOG.
    DEF OUTPUT param p-arquivoResumido  AS CHAR.
    DEF OUTPUT PARAM p-arquivoAbsoluto  AS CHAR.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).    

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.      
    
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

    IF  p-detalhado = YES THEN  /* Detalhado - Ser  sempre na Impressora */
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
        
            ASSIGN aux_nmdafila = LC(crapope.dsimpres).  
       
            ASSIGN aux_nmarqimp = "/usr/coop/sistema/siscaixa/web/spool/" +
                                   crapcop.dsdircop + STRING(p-cod-agencia) +
                                   STRING(p-nro-caixa) + "b1033.txt".
        
            FIND crapemp WHERE crapemp.cdcooper = crapcop.cdcooper  AND
                               crapemp.cdempres = 11   
                               NO-LOCK NO-ERROR.
                               
            IF  NOT AVAIL crapemp   THEN
                ASSIGN rel_nmresemp = FILL("?",11).
            ELSE
                ASSIGN rel_nmresemp = SUBSTRING(crapemp.nmresemp,1,11).
    
            ASSIGN rel_nmrelato    = "Comp.Eletronica".

            FORM HEADER 
               rel_nmresemp               FORMAT "x(11)"
               "-"
               rel_nmrelato               FORMAT "x(39)"
               TODAY                      FORMAT "99/99/9999"
               STRING(TIME,"HH:MM")       FORMAT "x(5)"
               "PAG: "                   
               PAGE-NUMBER(str_1)         FORMAT "zz9"
               SKIP
               "CRAP033"      
               SKIP
               WITH PAGE-TOP NO-BOX NO-ATTR-SPACE FRAME f_cabrel080_1 STREAM-IO.
                                           
            OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
      
            PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
            PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
       
            VIEW STREAM str_1 FRAME f_cabrel080_1.
 
            DISPLAY STREAM str_1  crapdat.dtmvtocd WITH FRAME f_cab.      /* 22/06/2018 - Alterado para o campo dtmvtocd - Everton(AMCOM).*/
            
            /*
            FOR EACH tt-cheque:
                DELETE tt-cheque.
            END.
            */
            
            EMPTY TEMP-TABLE tt-cheque.

            ASSIGN i-nrlote1 = 11000 + p-nro-lote
                   i-nrlote2 = 23000 + p-nro-lote
                   i-nrlote3 = 28000 + p-nro-lote
                   i-nrlote4 = 30000 + p-nro-lote.
        
            FOR EACH craplot WHERE (craplot.cdcooper = crapcop.cdcooper AND
                                    craplot.dtmvtolt = crapdat.dtmvtocd AND /* 22/06/2018 - Alterado para o campo dtmvtocd - Everton(AMCOM).*/
                                    craplot.cdagenci = p-cod-agencia    AND
                                    craplot.cdbccxlt = 11               AND
                                    craplot.nrdolote = i-nrlote1        AND
                                    craplot.nrdcaixa = p-nro-lote) OR
                                    
                                   (craplot.cdcooper = crapcop.cdcooper AND
                                    craplot.dtmvtolt = crapdat.dtmvtocd AND /* 22/06/2018 - Alterado para o campo dtmvtocd - Everton(AMCOM).*/
                                    craplot.cdagenci = p-cod-agencia    AND
                                    craplot.cdbccxlt = 11               AND
                                    craplot.nrdolote = i-nrlote2        AND
                                    craplot.nrdcaixa = p-nro-lote) OR
                                    
                                   (craplot.cdcooper = crapcop.cdcooper AND
                                    craplot.dtmvtolt = crapdat.dtmvtocd AND /* 22/06/2018 - Alterado para o campo dtmvtocd - Everton(AMCOM).*/
                                    craplot.cdagenci = p-cod-agencia    AND
                                    craplot.cdbccxlt = 11               AND
                                    craplot.nrdolote = i-nrlote3        AND
                                    craplot.nrdcaixa = p-nro-lote) OR
                                    
                                   (craplot.cdcooper = crapcop.cdcooper AND
                                    craplot.dtmvtolt = crapdat.dtmvtocd AND /* 22/06/2018 - Alterado para o campo dtmvtocd - Everton(AMCOM).*/
                                    craplot.cdagenci = p-cod-agencia    AND
                                    craplot.cdbccxlt = 11               AND
                                    craplot.nrdolote = i-nrlote4        AND
                                    craplot.nrdcaixa = p-nro-lote) OR
                                    
                                   (craplot.cdcooper = crapcop.cdcooper AND
                                    craplot.dtmvtolt = crapdat.dtmvtocd AND /* 22/06/2018 - Alterado para o campo dtmvtocd - Everton(AMCOM).*/
                                    craplot.cdagenci = p-cod-agencia    AND
                                    craplot.cdbccxlt = 500              AND
                                    craplot.nrdcaixa = p-nro-lote) NO-LOCK,
            EACH crapchd WHERE
                 crapchd.cdcooper = crapcop.cdcooper    AND
                 crapchd.dtmvtolt = craplot.dtmvtolt    AND
                 crapchd.cdagenci = craplot.cdagenci    AND
                 crapchd.nrdolote = craplot.nrdolote    AND
                 crapchd.cdbccxlt = craplot.cdbccxlt    AND
                 crapchd.inchqcop = 0                   AND
                 crapchd.insitchq <> 3
                 USE-INDEX crapchd3 NO-LOCK
                 BREAK BY crapchd.tpdmovto
                          BY crapchd.cdagenci
                             BY crapchd.cdbccxlt
                                BY crapchd.nrdolote:
        
            IF  FIRST-OF(crapchd.nrdolote)   THEN          /*  Por lote  */
                ASSIGN aux_qtchdrec = 0
                       aux_vlchdrec = 0.

            ASSIGN aux_qtchdrec = aux_qtchdrec + 1
                   aux_vlchdrec = aux_vlchdrec + crapchd.vlcheque.
              
            IF  LAST-OF(crapchd.nrdolote) THEN  
                DO:
                    IF  aux_qtchdrec > 0  THEN 
                        DO:

                            IF  crapchd.tpdmovto = 1   THEN
                                ASSIGN aux_exarquiv = ".sup".
                            ELSE
                                ASSIGN aux_exarquiv = ".inf".
                         
                            CREATE tt-cheque.
                            ASSIGN tt-cheque.cdagenci = crapchd.cdagenci
                                   tt-cheque.cdbccxlt = crapchd.cdbccxlt
                                   tt-cheque.nrdolote = crapchd.nrdolote
                                   tt-cheque.tpdmovto = crapchd.tpdmovto
                                   tt-cheque.qtchdrec = aux_qtchdrec
                                   tt-cheque.vlchdrec = aux_vlchdrec
                                   tt-cheque.nmarquiv = 
                                        STRING(crapcop.cdagebcb,"9999")      +
                                        STRING(DAY(crapdat.dtmvtocd),"99")   +    /* 22/06/2018 - Alterado para o campo dtmvtocd - Everton(AMCOM).*/
                                        STRING(MONTH(crapdat.dtmvtocd),"99") +    /* 22/06/2018 - Alterado para o campo dtmvtocd - Everton(AMCOM).*/
                                        STRING(crapchd.cdagenci,"999")       +
                                        STRING(crapchd.tpdmovto,"9")         +
                                        STRING(aux_exarquiv,"x(04)").
                        END.
                END. 
        END.      /*   For each crapchd  */    

        ASSIGN pac_qtchdrec = 0
               pac_vlchdrec = 0.

        FOR EACH tt-cheque BREAK BY tt-cheque.cdagenci
                                    BY tt-cheque.cdbccxlt 
                                       BY tt-cheque.nrdolote
                                          BY tt-cheque.tpdmovto:
       
            IF  FIRST-OF(tt-cheque.cdagenci)  THEN 
                DO:
                    IF  LINE-COUNTER(str_1) > 80  THEN 
                        DO:
                            PAGE STREAM str_1. 
                            DISPLAY STREAM str_1 
                                    crapdat.dtmvtocd WITH FRAME f_cab.    /* 22/06/2018 - Alterado para o campo dtmvtocd - Everton(AMCOM).*/
                        END.
                END.
   
            CLEAR FRAME f_lotes.
       
            DISPLAY STREAM str_1  
                    tt-cheque.cdagenci  
                    tt-cheque.qtchdrec
                    tt-cheque.vlchdrec 
                    WITH FRAME f_lotes.

            DISPLAY STREAM str_1
                    STRING(crapdat.dtmvtocd,"99/99/9999") + "-" +   /* 22/06/2018 - Alterado para o campo dtmvtocd - Everton(AMCOM).*/
                    STRING(p-cod-agencia,"999")           + "-" +
                    STRING(tt-cheque.cdbccxlt,"999")        + "-" +
                    STRING(p-nro-lote,"999999")  @ tt-cheque.nmarquiv
                    WITH FRAME f_lotes.            
            
            ASSIGN pac_qtchdrec = pac_qtchdrec + tt-cheque.qtchdrec
                   pac_vlchdrec = pac_vlchdrec + tt-cheque.vlchdrec.
              
            DOWN STREAM str_1 WITH FRAME f_lotes.                      

            RUN proc_lista.
            PAGE STREAM str_1.
            DISPLAY STREAM str_1 crapdat.dtmvtocd WITH FRAME f_cab.   /* 22/06/2018 - Alterado para o campo dtmvtocd - Everton(AMCOM).*/
                             
            IF  NOT LAST-OF(tt-cheque.cdagenci)  THEN NEXT.   
               
            CLEAR FRAME f_pac.
       
            DISPLAY STREAM str_1 
                    pac_qtchdrec
                    pac_vlchdrec
                    WITH FRAME f_pac.

            IF  LINE-COUNTER(str_1) > 80  THEN 
                DO:
                    PAGE STREAM str_1.
                    DISPLAY STREAM str_1 crapdat.dtmvtocd WITH FRAME f_cab. /* 22/06/2018 - Alterado para o campo dtmvtocd - Everton(AMCOM).*/
                END.
          
           ASSIGN pac_qtchdrec = 0 
                  pac_vlchdrec = 0.
   
       END.  /* FOR EACH tt-cheque */
    END.
        
    ELSE DO:            /* Resumido - Visualizacao */
        
       ASSIGN p-arquivoResumido =  "spool/" + crapcop.dsdircop + 
                                   STRING(p-cod-agencia) + 
                                   STRING(p-nro-caixa) + 
                                   "b1033.txt".  /* Nome Fixo  */

       ASSIGN aux_nmarqimp      = "/usr/coop/sistema/siscaixa/web/spool/" + 
                                  crapcop.dsdircop + STRING(p-cod-agencia) + 
                                  STRING(p-nro-caixa) + "b1033.txt" /* Nome Fixo  */
              p-arquivoAbsoluto = aux_nmarqimp.

       OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp). 

       ASSIGN res_dschqcop = "Cheques " +
                           STRING(crapcop.nmrescop,"x(11)") + ":".





        ASSIGN i-nrlote1 = 11000 + p-nro-lote 
               i-nrlote2 = 23000 + p-nro-lote
               i-nrlote3 = 28000 + p-nro-lote
               i-nrlote4 = 30000 + p-nro-lote
               tot_qtcheque = 0
               tot_vlcheque = 0.
        
        FOR EACH craplot WHERE 
                 craplot.cdcooper = crapcop.cdcooper    AND
                 craplot.dtmvtolt = crapdat.dtmvtocd    AND  /* 22/06/2018 - Alterado para o campo dtmvtocd - Everton(AMCOM).*/
                 craplot.cdagenci = p-cod-agencia       AND
                 craplot.nrdcaixa = p-nro-lote          AND  /* Nro Caixa */
                (craplot.nrdolote = i-nrlote1           OR
                 craplot.nrdolote = i-nrlote2           OR
                 craplot.nrdolote = i-nrlote3           OR
                 craplot.nrdolote = i-nrlote4           OR
                 craplot.cdbccxlt = 500)                NO-LOCK,
            EACH crapchd WHERE
                 crapchd.cdcooper = crapcop.cdcooper    AND
                 crapchd.dtmvtolt = craplot.dtmvtolt    AND
                 crapchd.cdagenci = craplot.cdagenci    AND
                 crapchd.nrdolote = craplot.nrdolote    AND
                 crapchd.cdbccxlt = craplot.cdbccxlt
                 USE-INDEX crapchd3 NO-LOCK:

           IF  crapchd.inchqcop = 1  THEN 
               DO:   /*  Cheque da Cooperativa  */
                    ASSIGN res_qtchqcop = res_qtchqcop + 1
                           res_vlchqcop = res_vlchqcop + crapchd.vlcheque.
                    NEXT.
                END.

           ASSIGN tot_qtcheque = tot_qtcheque + 1
                  tot_vlcheque = tot_vlcheque + crapchd.vlcheque.

        END.  /*  for each crapchd */

        

        IF   tot_qtcheque > 0  THEN   DO:
             DISPLAY STREAM str_1
                     /* res_qtchqcop */
                     
                     /* res_vlchqcop */
                     
                     tot_qtcheque 
                     tot_vlcheque 
                     
                     /* res_dschqcop */
                     WITH FRAME f_resumo.
        END.
      
    END.

   PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
   PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
  
   OUTPUT  STREAM str_1 CLOSE.
   
    IF  p-detalhado = YES  THEN  
        DO:
            ASSIGN i-nro-vias = 1.
                   aux_dscomand = "lp -d" + aux_nmdafila +
                                  " -n" + STRING(i-nro-vias) +   
                                  " -oMTl88 " + aux_nmarqimp +     
                                  " > /dev/null".

            UNIX SILENT VALUE(aux_dscomand).
      
   END.  /* impressora */
    

   RETURN "OK".

END PROCEDURE.

                         
/* Procedures Internas */
   
PROCEDURE proc_lista:

    VIEW STREAM str_1 FRAME f_linha.
    
    FOR EACH crapchd WHERE crapchd.cdcooper = crapcop.cdcooper      AND
                           crapchd.dtmvtolt = crapdat.dtmvtocd      AND /* 22/06/2018 - Alterado para o campo dtmvtocd - Everton(AMCOM).*/
                           crapchd.cdagenci = tt-cheque.cdagenci    AND
                           crapchd.cdbccxlt = tt-cheque.cdbccxlt    AND
                           crapchd.nrdolote = tt-cheque.nrdolote    AND
                           crapchd.inchqcop = 0
                           USE-INDEX crapchd3 NO-LOCK
                           BY crapchd.nrseqdig:
                           
        IF   crapchd.tpdmovto <> tt-cheque.tpdmovto   THEN NEXT.
          
        DISPLAY STREAM str_1 
                crapchd.nrdconta
                crapchd.nrdocmto
                crapchd.cdcmpchq
                crapchd.cdbanchq
                crapchd.cdagechq
                crapchd.nrddigv1
                crapchd.nrctachq
                crapchd.nrddigv2
                crapchd.nrcheque
                crapchd.nrddigv3
                crapchd.vlcheque
                crapchd.nrseqdig
                WITH FRAME f_lanctos.

        DOWN STREAM str_1 WITH FRAME f_lanctos.

        IF   LINE-COUNTER(str_1) > 80  THEN DO:
             PAGE STREAM str_1.
                        
             DISPLAY STREAM str_1 crapdat.dtmvtocd WITH FRAME f_cab.    /* 22/06/2018 - Alterado para o campo dtmvtocd - Everton(AMCOM).*/
            
             DISPLAY STREAM str_1  
                     tt-cheque.cdagenci 
                     tt-cheque.qtchdrec
                     tt-cheque.vlchdrec 
                     tt-cheque.nmarquiv
                     WITH FRAME f_lotes.
                 
             VIEW STREAM str_1 FRAME f_linha.
        END.

    END.  /*  Fim do FOR EACH  */
    
    VIEW STREAM str_1 FRAME f_linha.
    
END PROCEDURE.

/* b1crap33.p */

/* .......................................................................... */

