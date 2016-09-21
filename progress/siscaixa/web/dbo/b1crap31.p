/*----------------------------------------------------------------------------
    
    b1crap31.p - Controle Historico(Autenticacoes)
    
    Ultima Atualizacao: 05/08/2014
    
    Alteracoes: 23/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                18/12/2008 - Ajustes para unificacao dos bancos de dados
                             (Evandro).

                20/10/2010 - Incluido caminho completo nas referencias do 
                             diretorio spool (Elton).
                             
                23/05/2011 - Alterada a leitura da tabela craptab para a 
                             tabela crapope (Isara - RKAM).
                
                28/09/2011 - Incluido crapcop.dsdircop na geracao do relatorio 
                             em tela (Elton).
                         
                30/09/2011 - Alterar diretorio spool para
                             /usr/coop/sistema/siscaixa/web/spool (Fernando).
                             
                05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
----------------------------------------------------------------------------*/

{dbo/bo-erro1.i}

DEF VAR i-cod-erro      AS INTEGER.
DEF VAR c-desc-erro     AS CHAR.
DEF VAR i-cont          AS INT      FORMAT "zzzz9".
DEF VAR c-hist          AS CHAR     FORMAT "x(15)".
DEF STREAM str_1.

  
DEF VAR aux_nmarqimp    AS CHAR                                 NO-UNDO.
DEF VAR rel_nmresemp    AS CHAR     FORMAT "x(15)"              NO-UNDO.
DEF VAR rel_nmrelato    AS CHAR     FORMAT "x(40)"              NO-UNDO.
DEF VAR de-valor        AS DEC      FORMAT "zzzz,zzz,zz9.99-"   NO-UNDO.
DEF VAR c-hora          AS CHAR                                 NO-UNDO.      

DEF VAR aux_nmdafila    AS CHAR                                 NO-UNDO.
DEF VAR i-nro-vias      AS INTE                                 NO-UNDO.
DEF VAR aux_dscomand    AS CHAR                                 NO-UNDO.
     
FORM crapaut.cdhistor COLUMN-LABEL "Hist"
     c-hist           COLUMN-LABEL "Descricao"
     crapaut.nrsequen COLUMN-LABEL "Aut."
     c-hora           COLUMN-LABEL "Hora" 
     crapaut.nrdocmto COLUMN-LABEL "Docto"
     crapaut.vldocmto COLUMN-LABEL "Valor"
     crapaut.tpoperac COLUMN-LABEL " " FORMAT "PG/RC"
     crapaut.cdstatus COLUMN-LABEL "ST"
     crapaut.nrseqaut COLUMN-LABEL "Aut.!Est."
     WITH NO-BOX  DOWN FRAME f_historico STREAM-IO.

FORM crapaut.cdhistor COLUMN-LABEL "Historico"
     c-hist           COLUMN-LABEL "Descrição Hist."
     i-cont           COLUMN-LABEL "Qtd.!Lanç."
     de-valor         COLUMN-LABEL "Valor"
     WITH NO-BOX  DOWN FRAME f_historico-res STREAM-IO.

PROCEDURE Impressao:

    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-operador  AS char.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-imprime       AS LOG.
    DEF INPUT  PARAM p-detalhado     AS LOG.
    DEF OUTPUT param p-arquivo       AS CHAR.
                                       
    FORM "Referencia  - "  AT 1 crapdat.dtmvtolt  NO-LABEL  FORMAT "99/99/9999"
         "PA          - "  p-cod-agencia     NO-LABEL 
         "Caixa       - "  p-nro-caixa       no-label
         SKIP(1)
         WITH SIDE-LABELS NO-BOX WIDTH 132 FRAME f_cab STREAM-IO.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).    

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.      
   
    IF  p-imprime = YES THEN  /* Impressora */
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
                                  crapcop.dsdircop +  STRING(p-cod-agencia) +
                                  STRING(p-nro-caixa) + 
                                  "b1031.txt".  /* Nome Fixo  */
        END.
    ELSE 
        DO:
            IF  p-detalhado = YES THEN
                ASSIGN  aux_nmarqimp = "/usr/coop/sistema/siscaixa/web/spool/" +
                                       crapcop.dsdircop +  STRING(p-cod-agencia) + 
                                       STRING(p-nro-caixa) + 
                                       "b1031d.txt"  /* Nome Fixo  */
                        p-arquivo    = "spool/" + crapcop.dsdircop +  STRING(p-cod-agencia) + 
                                       STRING(p-nro-caixa) + 
                                       "b1031d.txt".  /* Nome Fixo  */
            ELSE
                ASSIGN aux_nmarqimp = "/usr/coop/sistema/siscaixa/web/spool/" +
                                      crapcop.dsdircop +  STRING(p-cod-agencia) + 
                                      STRING(p-nro-caixa) + 
                                      "b1031r.txt"  /* Nome Fixo  */
                       p-arquivo    = "spool/" + crapcop.dsdircop +  STRING(p-cod-agencia) + 
                                      STRING(p-nro-caixa) + 
                                      "b1031r.txt".  /* Nome Fixo  */
        END.
        
    FIND crapemp WHERE crapemp.cdcooper = crapcop.cdcooper  AND
                       crapemp.cdempres = 11                NO-LOCK NO-ERROR.
                       
    IF  NOT AVAIL crapemp   THEN
        ASSIGN rel_nmresemp = FILL("?",11).
    ELSE
        ASSIGN rel_nmresemp = SUBSTRING(crapemp.nmresemp,1,11).
        
    ASSIGN rel_nmrelato = "Controle Historico".

    FORM HEADER 
         rel_nmresemp               FORMAT "x(11)"
         "-"
         rel_nmrelato               FORMAT "x(36)"
         "REF P031 "
         STRING(TIME,"HH:MM")       FORMAT "x(5)"
         "PAG: "                   
         PAGE-NUMBER(str_1)         FORMAT "zz9"
         SKIP
         WITH PAGE-TOP NO-BOX NO-ATTR-SPACE FRAME f_cabrel080_1 STREAM-IO.
                                           
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

    IF  p-imprime = YES  THEN  
        DO:
            PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
            PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
            VIEW STREAM str_1 FRAME f_cabrel080_1.
        END.

    DISPLAY STREAM str_1 
            p-cod-agencia
            p-nro-caixa
            crapdat.dtmvtolt WITH FRAME f_cab. 

    IF  p-detalhado = YES  THEN   /* Detalhado */ 
        DO:
            FOR EACH crapaut WHERE crapaut.cdcooper = crapcop.cdcooper  AND
                                   crapaut.cdagenci = p-cod-agencia     AND
                                   crapaut.nrdcaixa = p-nro-caixa       AND
                                   crapaut.dtmvtolt = crapdat.dtmvtolt  NO-LOCK
                                   BREAK BY crapaut.cdhistor
                                            BY crapaut.nrsequen:
            
                FIND FIRST craphis WHERE craphis.cdcooper = crapcop.cdcooper   AND
                                         craphis.cdhistor = crapaut.cdhistor
                                         NO-LOCK NO-ERROR.
                                         
                IF  AVAIL craphis THEN
                    ASSIGN c-hist = craphis.dshistor.
                ELSE 
                    ASSIGN c-hist = "".

                ASSIGN c-hora = string(crapaut.hrautent,"HH:MM").

                DISP STREAM str_1 
                     crapaut.cdhistor
                     c-hist
                     crapaut.nrsequen
                     c-hora
                     crapaut.nrdocmto
                     crapaut.vldocmto
                     crapaut.tpoperac
                     crapaut.cdstatus
                     crapaut.nrseqaut
                     WITH FRAME f_historico.
                DOWN WITH FRAME f_historico.
                
            END.  /* FOR EACH crapaut */
        END.
        
    ELSE /* Resumido */ 
        DO:
        
            FOR EACH crapaut WHERE crapaut.cdcooper = crapcop.cdcooper  AND
                                   crapaut.cdagenci = p-cod-agencia     AND
                                   crapaut.nrdcaixa = p-nro-caixa       AND
                                   crapaut.dtmvtolt = crapdat.dtmvtolt  NO-LOCK
                                   BREAK BY crapaut.cdhistor
                                            BY crapaut.nrsequen:
                                            
                IF  FIRST-OF(crapaut.cdhistor) THEN  
                    DO:
                        ASSIGN de-valor = 0
                               i-cont   = 0.
                    END.
                ASSIGN i-cont = i-cont + 1.

                FIND FIRST craphis WHERE craphis.cdcooper = crapcop.cdcooper   AND
                                         craphis.cdhistor = crapaut.cdhistor
                                         NO-LOCK NO-ERROR.
                IF AVAIL craphis THEN
                    ASSIGN c-hist = craphis.dshistor.
                ELSE 
                    ASSIGN c-hist = "".

                IF  crapaut.tpoperac = YES  THEN  /* PG */
                    DO:
                        IF  crapaut.estorno = no THEN
                            ASSIGN de-valor = de-valor + crapaut.vldocmto.
                        ELSE  
                            ASSIGN de-valor = de-valor - crapaut.vldocmto.
                    END.
                ELSE                              /* RC */
                    DO:
                        IF  crapaut.estorno = NO THEN   
                            ASSIGN de-valor = de-valor + crapaut.vldocmto.
                        ELSE 
                            ASSIGN de-valor = de-valor - crapaut.vldocmto.
                    END.
                IF  LAST-OF(crapaut.cdhistor) THEN 
                    DO:
                        DISP STREAM str_1
                             crapaut.cdhistor
                             c-hist
                             i-cont
                             de-valor
                             WITH FRAME f_historico-res.
                        DOWN WITH FRAME f_historico-res.
                    END.
            END.  /* FOR EACH crapaut */
        END.


    IF  p-imprime = YES  THEN  
        DO:
   
            PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
            PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
        END.

    OUTPUT  STREAM str_1 CLOSE.
   
    IF  p-imprime = YES  THEN  
        DO:
            ASSIGN i-nro-vias   = 1
                   aux_dscomand = "lp -d" + aux_nmdafila +
                                  " -n" + STRING(i-nro-vias) +   
                                  " -oMTl88 " + aux_nmarqimp +     
                                  " > /dev/null".

            UNIX SILENT VALUE(aux_dscomand).
      
        END.  /* impressora */

   RETURN "OK".

END PROCEDURE.
            

/* b1crap31.p */

/* .......................................................................... */

