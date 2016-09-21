   
/*------------------------------------------------------------*/
/*  b3crap13.p - Impressao Abertura  Boletim Caixa            */
/*------------------------------------------------------------*/
/*

    Alteracoes: 02/03/2006 - Unificacao dos Bancos - SQLWorks - Fernando
                
                20/10/2010 - Incluido caminho completo nas referencias do 
                             diretorio spool (Elton).
                             
                23/05/2011 - Alterada a leitura da tabela craptab para a 
                             tabela crapope (Isara - RKAM).
                             
                30/09/2011 - Alterar diretorio spool para
                             /usr/coop/sistema/siscaixa/web/spool (Fernando).
                             
                11/11/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (Guilherme Gielow)
              
                                                                            */


{dbo/bo-erro1.i}

DEF VAR i-cod-erro      AS INTEGER.
DEF VAR c-desc-erro     AS CHAR.

DEF BUFFER b-crapbcx FOR crapbcx.
DEF STREAM str_1.

DEF VAR rel_nmresemp    AS CHAR    FORMAT "x(15)"                   NO-UNDO.
DEF VAR rel_nmrelato    AS CHAR    FORMAT "x(40)"                   NO-UNDO.
DEF VAR aux_nmarqimp    AS CHAR                                     NO-UNDO.
DEF VAR ant_nrdlacre    LIKE crapbcx.nrdlacre                       NO-UNDO.

DEF VAR aux_nmdafila    AS CHAR                                     NO-UNDO.
DEF VAR i-nro-vias      AS INTE                                     NO-UNDO.
DEF VAR aux_dscomand    AS CHAR                                     NO-UNDO.

FORM "REFERENCIA:" crapbcx.dtmvtolt 
     "** TERMO DE ABERTURA **" AT 29 
     SKIP(1)
     "PA :" crapbcx.cdagenci "-" crapage.nmresage
     "OPERADOR:" crapbcx.cdopecxa "-" crapope.nmoperad
     SKIP(1)
     "CAIXA:" crapbcx.nrdcaixa "AUTENTICADORA:" AT 21 crapbcx.nrdmaqui
     "LACRE ANTERIOR:" AT 56 ant_nrdlacre
     SKIP(1)
      "--------------------------------------------------------------------------------"
     SKIP(1)
     "SALDO INICIAL" "------------------------------------------------"  ":" crapbcx.vldsdini
      SKIP(1)
      "--------------------------------------------------------------------------------"
      SKIP(1)
      "VISTOS: "
      SKIP(4)
      SPACE(10) "------------------------------"
      SPACE(6)  "------------------------------"
      SKIP   
      SPACE(17) "OPERADOR         " SPACE(22) "RESPONSAVEL"
      SKIP(3)
      SPACE(51) "AUTENTICACAO MECANICA"
      SKIP(4)
      "---<Corte aqui>" SPACE(0) "-----------------------------------------------------------------" 
     WITH NO-BOX COLUMN 1 NO-LABELS  FRAME f_termo STREAM-IO.

 
PROCEDURE impressao-abertura.
 
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-operador  AS char.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-rowid         AS ROWID.
    DEF INPUT  PARAM p-programa      AS CHAR.
   
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
     
    IF  p-rowid = ? THEN 
        DO:
 
            FIND LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper   AND
                                    crapbcx.dtmvtolt = crapdat.dtmvtolt   AND
                                    crapbcx.cdagenci = p-cod-agencia      AND
                                    crapbcx.nrdcaixa = p-nro-caixa        AND
                                    crapbcx.cdopecxa = p-cod-operador 
                                    USE-INDEX crapbcx2 NO-LOCK NO-ERROR.

        END.
    ELSE 
        DO:
             FIND  crapbcx WHERE ROWID(crapbcx) = p-rowid NO-LOCK NO-ERROR.
        END.
   
    IF  NOT AVAIL crapbcx   THEN 
        DO:
            ASSIGN i-cod-erro  = 90
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
            RETURN "NOK".
        END.
    
    FIND crapemp WHERE crapemp.cdcooper = crapcop.cdcooper  AND
                       crapemp.cdempres = 11                NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapemp   THEN
         ASSIGN rel_nmresemp = FILL("?",11).
    ELSE
         ASSIGN rel_nmresemp = SUBSTRING(crapemp.nmresemp,1,11).

    FIND craprel WHERE craprel.cdcooper = crapcop.cdcooper  AND
                       craprel.cdrelato = 258               NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craprel   THEN
         ASSIGN rel_nmrelato    = FILL("?",17).
    ELSE
         ASSIGN rel_nmrelato    = craprel.nmrelato.

    FORM HEADER 
         rel_nmresemp               FORMAT "x(11)"
         "-"
         rel_nmrelato               FORMAT "x(16)"
         "REF"                      
         crapdat.dtmvtolt           FORMAT "99/99/9999"
         "258/1 "                                     
         TODAY                      FORMAT "99/99/9999"
         STRING(TIME,"HH:MM")       FORMAT "x(5)"
         "PAG: "                   
         PAGE-NUMBER(str_1)         FORMAT "zz9"
         SKIP
         p-programa                 FORMAT "x(07)"      
         SKIP
         WITH PAGE-TOP NO-BOX NO-ATTR-SPACE FRAME f_cabrel080_1 STREAM-IO.
    
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
        
    ASSIGN aux_nmdafila =  LC(crapope.dsimpres). 

    ASSIGN aux_nmarqimp = "/usr/coop/sistema/siscaixa/web/spool/" +
                          crapcop.dsdircop +
                          STRING(p-cod-agencia) + 
                          string(p-nro-caixa) + "b1031.txt".  /* Nome Fixo  */
        
/*    ASSIGN aux_nmarqimp = "Printer".  /* Retirar Printer */  */
    
    /* Obter n£mero Lacre = Anterior */

    FIND LAST b-crapbcx WHERE b-crapbcx.cdcooper = crapcop.cdcooper  AND
                              b-crapbcx.dtmvtolt = crapdat.dtmvtolt  AND
                              b-crapbcx.cdagenci = p-cod-agencia     AND
                              b-crapbcx.nrdcaixa = p-nro-caixa       AND
                              b-crapbcx.cdsitbcx = 2
                              USE-INDEX crapbcx1 NO-LOCK NO-ERROR. /* Fechado */
    
    IF  NOT AVAIL b-crapbcx  THEN 
        DO:
            FIND LAST b-crapbcx  WHERE
                      b-crapbcx.cdcooper  = crapcop.cdcooper  AND
                      b-crapbcx.dtmvtolt <  crapdat.dtmvtolt  AND
                      b-crapbcx.cdagenci  = p-cod-agencia     AND
                      b-crapbcx.nrdcaixa  = p-nro-caixa       AND
                      b-crapbcx.cdsitbcx  = 2
                      USE-INDEX crapbcx1 NO-LOCK NO-ERROR. /* Fechado */
    END.
    IF  AVAIL b-crapbcx THEN 
        ASSIGN ant_nrdlacre = b-crapbcx.nrdlacre.
    ELSE 
        ASSIGN ant_nrdlacre = 0.
    
    FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper  AND
                       crapage.cdagenci = crapbcx.cdagenci  NO-LOCK NO-ERROR.
        
    IF  NOT AVAIL crapbcx   THEN 
        DO:
           ASSIGN i-cod-erro  = 15
                  c-desc-erro = " ".
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
            RETURN "NOK".
    END.

    FIND crapope WHERE crapope.cdcooper = crapcop.cdcooper  AND
                       crapope.cdoperad = crapbcx.cdopecxa  NO-ERROR.

    IF  NOT AVAIL crapbcx   THEN 
        DO:
            ASSIGN i-cod-erro  = 702
                   c-desc-erro = " ".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
        END.

    IF  p-rowid = ? THEN 
        DO:
            FIND LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper  AND
                                    crapbcx.dtmvtolt = crapdat.dtmvtolt  AND
                                    crapbcx.cdagenci = p-cod-agencia     AND
                                    crapbcx.nrdcaixa = p-nro-caixa       AND
                                    crapbcx.cdopecxa = p-cod-operador 
                                    USE-INDEX crapbcx2 NO-LOCK NO-ERROR.
                  
            IF  NOT AVAIL crapbcx THEN 
                DO:
                    ASSIGN i-cod-erro  = 90
                           c-desc-erro = " ".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.

        END.

    OUTPUT STREAM str_1 TO  VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
    
    VIEW STREAM str_1 FRAME f_cabrel080_1.

    /*  Configura a impressora para 1/8"  */
   
    PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
    PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
    
    DISPLAY STREAM str_1
            crapbcx.dtmvtolt 
            crapbcx.cdagenci 
            crapage.nmresage
            crapbcx.cdopecxa
            crapope.nmoperad
            crapbcx.nrdcaixa
            crapbcx.nrdmaqui
            ant_nrdlacre
            crapbcx.vldsdini
            WITH FRAME f_termo.
    DOWN STREAM str_1 WITH FRAME f_termo.        
    PAGE STREAM str_1.
     
    OUTPUT STREAM str_1 CLOSE.
   
    assign i-nro-vias = 1.
    aux_dscomand = "lp -d" + aux_nmdafila +
                   " -n" + STRING(i-nro-vias) +   
                   " -oMTl88 " + aux_nmarqimp +     
                   " > /dev/null".

    UNIX SILENT VALUE(aux_dscomand).
    
    RETURN "OK".
 
END PROCEDURE.
 
/*  b3crap13.p */

