/*---------------------------------------------------------------------

    b1crap81.p - Estorno Correspondente Bancario
    
    Ultima Atualizacao: 23/05/2012
    
    Alteracoes:
                02/03/2006 - Unificacao dos bancos - SQLWorks - Eder
                
                23/10/2006 - Criticar sabado, domingo, feriado ou horario > 21h
                             (Evandro).
                
                17/01/2007 - Eliminar tabela craptab "CORRESPOND" para cada PAC,
                             acessar campo crapage.cdagecbn (Evandro).

                17/10/2008 - Incluir leitura pelo modulo 11 quando 
                             Claro (Magui).

                09/12/2008 - Incluir parametro na chamada do programa pcrap03.p
                             (David).

                11/03/2009 - Ajustes para unificacao dos bancos de dados
                             (Evandro).
                             
                13/05/2009 - Verifcar se digito esta errado quando for 
                             modulo 11 (pcrap14.p) (David).
                             
                20/10/2010 - Incluido caminho completo nas referencias do 
                             diretorio spool (Elton).         
                             
                30/09/2011 - Alterar diretorio spool para 
                             /usr/coop/sistema/siscaixa/web/spool (Fernando).                              
                             
                23/05/2012 - Nova funcao muda_caracter para remocao de caracter
                             alfa no codigo do operador. (David Kruger).
                             
---------------------------------------------------------------------*/

{dbo/bo-erro1.i}

DEF VAR i-cod-erro          AS INTE.
DEF VAR c-desc-erro         AS CHAR.

DEF VAR h_b1crap00          AS HANDLE                               NO-UNDO.
DEF VAR p-literal           AS CHAR                                 NO-UNDO.
DEF VAR p-ult-sequencia     AS INTE                                 NO-UNDO.
DEF VAR p-registro          AS RECID                                NO-UNDO.

DEF VAR de-valor-calc       AS DEC                                  NO-UNDO.
DEF VAR p-nro-digito        AS INTE                                 NO-UNDO.
DEF VAR p-retorno           AS LOG                                  NO-UNDO.
DEF VAR i-nro-lote          LIKE craplft.nrdolote                   NO-UNDO.
DEF VAR p-valorpago         AS DEC                                  NO-UNDO.
DEF VAR in99                AS INT                                  NO-UNDO.

DEF VAR aux_nrconven        AS INTE   FORMAT "999999999" /* 9 N */  NO-UNDO.
DEF VAR aux_nragenci        AS INTE   FORMAT "9999"      /* 4 N */  NO-UNDO.
DEF VAR aux_nrdaloja        AS INTE   FORMAT "999999"    /* 6 N */  NO-UNDO.
DEF VAR aux_nrpdv           AS INTE   FORMAT "99999999"  /* 8 N */  NO-UNDO.
DEF VAR aux_cdoperad        AS DECI   FORMAT "999999999" /* 9 N */  NO-UNDO.
DEF VAR aux_nsupdv          AS INTE   FORMAT "99999999"  /* 8 N */  NO-UNDO.
DEF VAR aux_nrversao        AS INTE                                 NO-UNDO.
DEF VAR aux_codtrans        AS CHAR   FORMAT "x(03)"                NO-UNDO.
DEF VAR aux_erro            AS INTE                                 NO-UNDO.
DEF VAR aux_cod_agencia     AS INTE                                 NO-UNDO.
DEF VAR aux_nro_caixa       AS INTE                                 NO-UNDO.
DEF VAR aux_tipo_trn        AS CHAR   FORMAT "x(01)"                NO-UNDO.
DEF VAR aux_linha_envio     AS CHAR                                 NO-UNDO.
DEF VAR c_linha             AS CHAR                                 NO-UNDO.

DEF STREAM str_1.

DEF VAR aux_nmarquiv        AS CHAR                                 NO-UNDO.
DEF VAR aux_contador        AS INTE                                 NO-UNDO.
DEF VAR i-time              AS INTE                                 NO-UNDO.
DEF VAR aux_transacao       AS CHAR   FORMAT "x(03)"                NO-UNDO. 
DEF VAR aux_tppagto         AS INTE   FORMAT "9"                    NO-UNDO.
DEF VAR i-nro-rotulos       AS INTE                                 NO-UNDO.
DEF VAR aux_tam_payload     AS INTE                                 NO-UNDO.
DEF VAR aux_payload         AS CHAR                                 NO-UNDO.
DEF VAR aux_tam_campo       AS INTE                                 NO-UNDO.
DEF VAR aux_vldocto_int     AS INTE                                 NO-UNDO.
DEF VAR aux_vldocto_char    AS CHAR                                 NO-UNDO.
DEF VAR aux_tptransac       AS CHAR                                 NO-UNDO.
DEF VAR aux_tamanho         AS INTE                                 NO-UNDO.
DEF VAR aux_posicao         AS INTE                                 NO-UNDO.
DEF VAR aux_setlinha        AS CHAR                                 NO-UNDO.

FUNCTION muda_caracter RETURN DECIMAL
    (INPUT  p-cod-operador AS CHARACTER) FORWARD.

FORM aux_setlinha  FORMAT "x(150)"
     WITH FRAME AA WIDTH 150 NO-BOX NO-LABELS.

PROCEDURE retorna-valores-titulo:

    DEF INPUT  PARAM p-cooper              AS CHAR.
    DEF INPUT  PARAM p-cod-operador        AS CHAR.
    DEF INPUT  PARAM p-cod-agencia         AS INTE.
    DEF INPUT  PARAM p-nro-caixa           AS INTE.
    DEF INPUT-OUTPUT PARAM p-titulo1       AS DEC. /* FORMAT "99999,99999"  */ 
    DEF INPUT-OUTPUT PARAM p-titulo2       AS DEC. /* FORMAT "99999,999999" */  
    DEF INPUT-OUTPUT PARAM p-titulo3       AS DEC. /* FORMAT "99999,999999" */ 
    DEF INPUT-OUTPUT PARAM p-titulo4       AS DEC. /* FORMAT "9"            */
    DEF INPUT-OUTPUT PARAM p-titulo5       AS DEC. 
                                              /* FORMAT "zz,zzz,zzz,zzz999" */
    DEF INPUT-OUTPUT PARAM p-codigo-barras AS CHAR.
    DEF OUTPUT       PARAM p-valor-pago    AS DEC.
    DEF OUTPUT       PARAM p-valordoc      AS DEC.
    DEF OUTPUT       PARAM p-autchave      AS INTE.
    DEF OUTPUT       PARAM p-cdchave       AS CHAR.
    
    ASSIGN p-valordoc    = 0
           p-valor-pago  = 0.
               
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
    
    /* Verifica se eh dia util e se esta dentro do horario (ate 21:00) */
         /* sabado ou domingo */
    IF   CAN-DO("1,7",STRING(WEEKDAY(TODAY)))   OR 
         /* feriado */
         CAN-FIND(crapfer WHERE crapfer.cdcooper = crapcop.cdcooper AND
                                crapfer.dtferiad = TODAY
                                NO-LOCK)        OR 
         /* passou das 21h */
         STRING(TIME,"HH:MM") > "21:00"         THEN
         DO:
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT 0,
                            INPUT "Data/Horario fora do estabelecido",
                            INPUT YES).
             RETURN "NOK".
         END.

    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                       craptab.nmsistem = "CRED"            AND
                       craptab.tptabela = "USUARI"          AND
                       craptab.cdempres = 11                AND
                       craptab.cdacesso = "CORRESPOND"      AND
                       craptab.tpregist = 000               NO-LOCK NO-ERROR.
                       
    IF  NOT AVAIL craptab THEN
        DO:
           ASSIGN i-cod-erro = 0
                  c-desc-erro = 
                      "Convenio nao Parametrizado. TAB.CORRESPOND". 
           RUN cria-erro (INPUT  p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
        END.
    
    FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper   AND
                       crapage.cdagenci = p-cod-agencia      NO-LOCK NO-ERROR.
                       
    IF   NOT AVAILABLE crapage   THEN
         DO:
            ASSIGN i-cod-erro = 15
                   c-desc-erro = "". 
                  
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

    ASSIGN i-nro-lote = 22000 + p-nro-caixa.
        
    IF  p-titulo1 <> 0  OR
        p-titulo2 <> 0  OR
        p-titulo3 <> 0  OR
        p-titulo4 <> 0  OR
        p-titulo5 <> 0  THEN 
        DO:
          
            ASSIGN de-valor-calc = p-titulo1. 
            RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                               INPUT        TRUE,  /* Verificar zeros */      
                                     OUTPUT p-nro-digito,
                                     OUTPUT p-retorno).
            
            IF  p-retorno = NO  THEN 
                DO:
                    ASSIGN i-cod-erro  = 8           
                           c-desc-erro = " ".
                    RUN cria-erro (INPUT  p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
        
            ASSIGN de-valor-calc = p-titulo2. 
            RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                               INPUT        FALSE,  /* Verificar zeros */
                                     OUTPUT p-nro-digito,
                                     OUTPUT p-retorno).
                               
            IF  p-retorno = NO  THEN 
                DO:
                    ASSIGN i-cod-erro  = 8           
                           c-desc-erro = " ".
                    RUN cria-erro (INPUT  p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
       
            ASSIGN de-valor-calc = p-titulo3. 
            RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                               INPUT        FALSE,  /* Verificar zeros */
                                     OUTPUT p-nro-digito,
                                     OUTPUT p-retorno).
                               
            IF  p-retorno = NO  THEN 
                DO:
                    ASSIGN i-cod-erro  = 8           
                           c-desc-erro = " ".
                    RUN cria-erro (INPUT  p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
        
            /*  Compoe o codigo de barras atraves da linha digitavel  */
            ASSIGN p-codigo-barras =
                    SUBSTR(STRING(p-titulo1,"9999999999"),1,4)   +
                           STRING(p-titulo4,"9")                 +
                           STRING(p-titulo5,"99999999999999")    +
                    SUBSTR(STRING(p-titulo1,"9999999999"),5,1)   +
                    SUBSTR(STRING(p-titulo1,"9999999999"),6,4)   +
                    SUBSTR(STRING(p-titulo2,"99999999999"),1,10) +
                    SUBSTR(STRING(p-titulo3,"99999999999"),1,10).
        END.
    ELSE 
        DO:   
            ASSIGN p-titulo1 = DEC(SUBSTR(p-codigo-barras,01,04) +
                                   SUBSTR(p-codigo-barras,20,01) +
                                   SUBSTR(p-codigo-barras,21,04) + "0")
                   p-titulo2 = DEC(SUBSTR(p-codigo-barras,25,10) + "0")
                   p-titulo3 = DEC(SUBSTR(p-codigo-barras,35,10) + "0")
                   p-titulo4 = INT(SUBSTR(p-codigo-barras,05,01))
                   p-titulo5 = DEC(SUBSTR(p-codigo-barras,06,14)).

            ASSIGN de-valor-calc = p-titulo1.
            RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                               INPUT        TRUE,  /* Verificar zeros */
                                     OUTPUT p-nro-digito,
                                     OUTPUT p-retorno).
            ASSIGN p-titulo1 = de-valor-calc.
            /*
            IF  p-retorno = NO  THEN 
                DO:
                    ASSIGN i-cod-erro  = 8           
                           c-desc-erro = " ".
                    RUN cria-erro (INPUT  p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
            */
            ASSIGN de-valor-calc = p-titulo2. 
            RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                               INPUT        FALSE,  /* Verificar zeros */
                                     OUTPUT p-nro-digito,
                                     OUTPUT p-retorno).
            ASSIGN p-titulo2 = de-valor-calc.
            /*
            IF  p-retorno = NO  THEN 
                DO:
                    ASSIGN i-cod-erro  = 8           
                           c-desc-erro = " ".
                    RUN cria-erro (INPUT  p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
            */
            ASSIGN de-valor-calc = p-titulo3. 
            RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                               INPUT        FALSE,  /* Verificar zeros */
                                     OUTPUT p-nro-digito,
                                     OUTPUT p-retorno).
            ASSIGN p-titulo3 = de-valor-calc.
            /*
            IF  p-retorno = NO  THEN 
                DO:
                    ASSIGN i-cod-erro  = 8           
                           c-desc-erro = " ".
                    RUN cria-erro (INPUT  p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
            */ 
        END.        
      
    ASSIGN de-valor-calc = DEC(p-codigo-barras).

    RUN dbo/pcrap05.p (INPUT de-valor-calc,  
                       OUTPUT p-retorno).
                       
    IF  p-retorno = NO  THEN 
        DO:
            ASSIGN i-cod-erro  = 8           
                   c-desc-erro = " ".
            RUN cria-erro (INPUT  p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END. 

    ASSIGN p-valordoc =
             DEC(SUBSTR(STRING(p-titulo5, "99999999999999"),5,10)) / 100.

    FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                       craplot.dtmvtolt = crapdat.dtmvtolt  AND
                       craplot.cdagenci = p-cod-agencia     AND
                       craplot.cdbccxlt = 11                AND  /* Fixo */
                       craplot.nrdolote = i-nro-lote 
                       NO-LOCK NO-ERROR.
         
    IF  NOT AVAIL craplot THEN 
        DO:
            ASSIGN i-cod-erro  = 90           
                   c-desc-erro = " ".
            RUN cria-erro (INPUT  p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END. 
    
    FIND FIRST crapcbb WHERE crapcbb.cdcooper = crapcop.cdcooper  AND
                             crapcbb.dtmvtolt = crapdat.dtmvtolt  AND
                             crapcbb.cdagenci = p-cod-agencia     AND
                             crapcbb.cdbccxlt = 11                AND /* FIXO */
                             crapcbb.nrdolote = i-nro-lote        AND
                             crapcbb.cdbarras = p-codigo-barras   AND
                             crapcbb.flgrgatv = YES         
                             NO-LOCK NO-ERROR.
         
    IF  NOT AVAIL crapcbb  THEN  
        DO:
            ASSIGN i-cod-erro  = 90           
                   c-desc-erro = " ".
            RUN cria-erro (INPUT  p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END. 
    
    ASSIGN p-valor-pago  =  crapcbb.valorpag.  /* Valor pago */

    IF  crapcbb.valordoc  <> p-valordoc AND
        p-valordoc         > 0          THEN 
        DO:
            ASSIGN i-cod-erro  = 0           
                   c-desc-erro = "Valor Docto nao confere com vlr. gravado  ".
            RUN cria-erro (INPUT  p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
    
    ASSIGN p-autchave = crapcbb.autchave. /* Nro aut. Correspond.Bancario */
    ASSIGN p-cdchave  = crapcbb.cdchaveb. /* Chave comunicacao com banco*/
   
    RETURN "OK".
        
END PROCEDURE.

PROCEDURE retorna-valores-fatura:
                                          
    DEF INPUT         PARAM p-cooper        AS CHAR.
    DEF INPUT         PARAM p-cod-operador  AS CHAR.
    DEF INPUT         PARAM p-cod-agencia   AS INTE.
    DEF INPUT         PARAM p-nro-caixa     AS INTE.
    DEF INPUT         param p-fatura1       AS dec.
    DEF INPUT         PARAM p-fatura2       AS DEC. 
    DEF INPUT         param p-fatura3       AS DEC.
    DEF INPUT         PARAM p-fatura4       AS DEC.
    DEF INPUT-OUTPUT  PARAM p-codigo-barras AS CHAR.
    DEF OUTPUT        PARAM p-valor-pago    AS DEC.
    DEF OUTPUT        PARAM p-valordoc      AS DEC.
    DEF OUTPUT        PARAM p-autchave      AS INTE.
    DEF OUTPUT        PARAM p-cdchave       AS CHAR.
           
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    /* Verifica se eh dia util e se esta dentro do horario (ate 21:00) */
         /* sabado ou domingo */
    IF   CAN-DO("1,7",STRING(WEEKDAY(TODAY)))   OR 
         /* feriado */
         CAN-FIND(crapfer WHERE crapfer.cdcooper = crapcop.cdcooper AND
                                crapfer.dtferiad = TODAY
                                NO-LOCK)        OR 
         /* passou das 21h */
         STRING(TIME,"HH:MM") > "21:00"         THEN
         DO:
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT 0,
                            INPUT "Data/Horario fora do estabelecido",
                            INPUT YES).
             RETURN "NOK".
         END.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.
        
    ASSIGN   p-valor-pago = 0
             p-valordoc   = 0.
             
    IF  p-fatura1 <> 0  OR
        p-fatura2 <> 0  OR
        p-fatura3 <> 0  OR
        p-fatura4 <> 0  THEN  
        DO:
            ASSIGN de-valor-calc  =
                        DEC(SUBSTR(STRING(p-fatura1,"999999999999"),1,11) + 
                            SUBSTR(STRING(p-fatura2,"999999999999"),1,11) + 
                            SUBSTR(STRING(p-fatura3,"999999999999"),1,11) + 
                            SUBSTR(STRING(p-fatura4,"999999999999"),1,11)).
                                               
            ASSIGN p-codigo-barras = string(de-valor-calc).
        END.
    

    ASSIGN de-valor-calc = DEC(p-codigo-barras).
    
    /* Calculo Digito Verificador */
    RUN dbo/pcrap04.p (INPUT-OUTPUT de-valor-calc,
                       OUTPUT p-nro-digito,
                       OUTPUT p-retorno).
    IF  p-retorno = NO  THEN 
        DO:
            IF  SUBSTR(p-codigo-barras,16,4) = "0163"   THEN /* CLARO */
                DO:
                    RUN dbo/pcrap14.p (INPUT-OUTPUT p-codigo-barras,
                                             OUTPUT p-nro-digito,
                                             OUTPUT p-retorno).
                END.
            IF  p-retorno = NO                      AND
                SUBSTR(p-codigo-barras,2,1) <> "5"  THEN /*Orgao Governamental*/
                DO:                                     /* Devido DAS - Simples */
                    ASSIGN i-cod-erro  = 8           
                           c-desc-erro = "".
                    RUN cria-erro (INPUT  p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
        END.
    
    ASSIGN p-valordoc =  DEC(SUBSTR(p-codigo-barras,5,11)) / 100.
                                        
    ASSIGN i-nro-lote = 22000 + p-nro-caixa.

    FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                       craplot.dtmvtolt = crapdat.dtmvtolt  AND
                       craplot.cdagenci = p-cod-agencia     AND
                       craplot.cdbccxlt = 11                AND  /* Fixo */
                       craplot.nrdolote = i-nro-lote        NO-LOCK NO-ERROR.
         
    IF  NOT AVAIL craplot THEN 
        DO:
            ASSIGN i-cod-erro  = 90           
                   c-desc-erro = " ".
            RUN cria-erro (INPUT  p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END. 
    
    FIND FIRST crapcbb WHERE crapcbb.cdcooper = crapcop.cdcooper  AND
                             crapcbb.dtmvtolt = crapdat.dtmvtolt  AND
                             crapcbb.cdagenci = p-cod-agencia     AND
                             crapcbb.cdbccxlt = 11                AND /* FIXO */
                             crapcbb.nrdolote = i-nro-lote        AND
                             crapcbb.cdbarras = p-codigo-barras   AND
                             crapcbb.flgrgatv = YES 
                             NO-LOCK NO-ERROR.
         
    IF  NOT AVAIL crapcbb  THEN  
        DO:
            ASSIGN i-cod-erro  = 90          
                   c-desc-erro = STRING(p-codigo-barras).
            RUN cria-erro (INPUT  p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END. 
    
    ASSIGN p-valor-pago  =  crapcbb.valorpag.  /* Valor pago */

    IF  crapcbb.valordoc <> p-valordoc  AND
        p-valordoc        > 0           THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Valor Docto nao confere com vlr. gravado  ".
            RUN cria-erro (INPUT  p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
    
    ASSIGN p-autchave = crapcbb.autchave. /* Nro aut. Correspond.Bancario */
    ASSIGN p-cdchave  = crapcbb.cdchaveb. /* Chave comunicacao com banco*/
   
    RETURN "OK".
END PROCEDURE.

PROCEDURE estorna-titulos-fatura:
    
    DEF INPUT  PARAM p-cooper            AS CHAR.
    DEF INPUT  PARAM p-cod-operador      AS CHAR.
    DEF INPUT  PARAM p-cod-agencia       AS INTE.
    DEF INPUT  PARAM p-nro-caixa         AS INTE.
    DEF INPUT  PARAM p-codigo-barras     AS CHAR.
    DEF INPUT  PARAM p-tpdocmto          AS INTE.
    DEF OUTPUT PARAM p-histor            AS INTE.
    DEF OUTPUT PARAM p-pg                AS LOG.
    DEF OUTPUT PARAM p-docto             AS DEC.
    DEF OUTPUT PARAM p-literal-r         AS CHAR.
    DEF OUTPUT PARAM p-ult-sequencia-r   AS INTE.
    
               
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
     
    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
           
    ASSIGN i-nro-lote = 22000 + p-nro-caixa.  

    ASSIGN in99 = 0.
    DO  WHILE TRUE:
       
        ASSIGN in99 = in99 + 1.
        FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                           craplot.dtmvtolt = crapdat.dtmvtolt  AND
                           craplot.cdagenci = p-cod-agencia     AND
                           craplot.cdbccxlt = 11                AND  /* Fixo */
                           craplot.nrdolote = i-nro-lote 
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
        IF  NOT AVAILABLE craplot   THEN  
            DO:
                IF  LOCKED craplot     THEN 
                    DO:
                        IF  in99 <  100  THEN 
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                        ELSE 
                            DO:
                                ASSIGN i-cod-erro  = 0
                                       c-desc-erro = "Tabela CRAPLOT em uso ".
                                RUN cria-erro (INPUT  p-cooper,
                                               INPUT p-cod-agencia,
                                               INPUT p-nro-caixa,
                                               INPUT i-cod-erro,
                                               INPUT c-desc-erro,
                                               INPUT YES).
                                RETURN "NOK".
                            END.
                    END.
                ELSE 
                    DO:
                        ASSIGN i-cod-erro  = 60
                               c-desc-erro = " ".           
                        RUN cria-erro (INPUT  p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                    END.
            END.
        LEAVE.
    END.  /*  DO WHILE */

    ASSIGN in99 = 0.
    DO WHILE TRUE:

        FIND FIRST crapcbb WHERE crapcbb.cdcooper = crapcop.cdcooper    AND
                                 crapcbb.dtmvtolt = crapdat.dtmvtolt    AND
                                 crapcbb.cdagenci = craplot.cdagenci    AND
                                 crapcbb.cdbccxlt = craplot.cdbccxlt    AND
                                 crapcbb.nrdolote = craplot.nrdolote    AND
                                 crapcbb.cdbarras = p-codigo-barras     AND
                                 crapcbb.flgrgatv = YES 
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        ASSIGN in99 = in99 + 1.
        IF  NOT AVAILABLE crapcbb THEN 
            DO:
                IF  LOCKED crapcbb   THEN 
                    DO:
                        IF  in99 <  100  THEN 
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                        ELSE 
                            DO:
                                ASSIGN i-cod-erro  = 0
                                       c-desc-erro = "Tabela CRAPCBB em uso ".
                                RUN cria-erro (INPUT  p-cooper,
                                               INPUT p-cod-agencia,
                                               INPUT p-nro-caixa,
                                               INPUT i-cod-erro,
                                               INPUT c-desc-erro,
                                               INPUT YES).
                                RETURN "NOK".
                            END.
                    END.
                ELSE  
                    DO:
                        ASSIGN i-cod-erro  = 90
                               c-desc-erro = " ".           
                        RUN cria-erro (INPUT  p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                    END.
            END.
   
       LEAVE.
    END.  /*  DO WHILE */
                
    ASSIGN craplot.vlcompcr = craplot.vlcompcr - crapcbb.valorpag
           craplot.qtcompln = craplot.qtcompln - 1

           craplot.vlinfocr = craplot.vlinfocr - crapcbb.valorpag 
           craplot.qtinfoln = craplot.qtinfoln - 1.

    ASSIGN p-pg        = NO
           p-docto     = crapcbb.nrseqdig
           p-histor    = 750
           p-valorpago = crapcbb.valorpag.
    
   IF  craplot.vlcompdb = 0 AND
       craplot.vlinfodb = 0 AND
       craplot.vlcompcr = 0 AND
       craplot.vlinfocr = 0 THEN
       DELETE craplot.
   
   ASSIGN crapcbb.nrsequen = TIME.                   
   ASSIGN crapcbb.flgrgatv  = NO. /* Primeiro Cancelamento  - Reg.Ativo*/

   RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.

   RUN grava-autenticacao 
         IN h_b1crap00 (INPUT p-cooper,
                        INPUT p-cod-agencia,
                        INPUT p-nro-caixa,
                        INPUT p-cod-operador,
                        INPUT p-valorpago,
                        INPUT p-docto, 
                        INPUT p-pg, /* YES (PG), NO (REC) */
                        INPUT "1",  /* On-line            */         
                        INPUT YES,   /* Estorno        */
                        INPUT p-histor, 
                        INPUT ?, /* Data off-line */
                        INPUT 0, /* Sequencia off-line */
                        INPUT 0, /* Hora off-line */
                        INPUT 0, /* Seq.orig.Off-line */
                        OUTPUT p-literal,
                        OUTPUT p-ult-sequencia,
                        OUTPUT p-registro).
 
   DELETE PROCEDURE h_b1crap00.

   IF  RETURN-VALUE = "NOK" THEN
       RETURN "NOK".

   ASSIGN p-ult-sequencia-r = p-ult-sequencia
          p-literal-r       = p-literal.

   RELEASE crapcbb.
    
   RELEASE craplot.

   RETURN "OK".

END PROCEDURE.

PROCEDURE gera-estorno-correspondente:
    
    DEF INPUT  PARAM p-cooper           AS CHAR.
    DEF INPUT  PARAM p-cod-operador     AS CHAR.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
    DEF INPUT  PARAM p-vlpagto          AS DEC.  /* valor pago      */
    DEF INPUT  PARAM p-tpdocmto         AS INTE. /* 1 - titulo/ 2 - fatura */
    DEF INPUT  PARAM p-autchave         AS INTE. /* Nro Aut.Correspondente */
    DEF INPUT  PARAM p-cdchave          AS CHAR. /* Chave usuario  no banco */

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.

    FIND  LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper    AND
                             crapbcx.dtmvtolt = crapdat.dtmvtolt    AND
                             crapbcx.cdagenci = p-cod-agencia       AND
                             crapbcx.nrdcaixa = p-nro-caixa         AND
                             crapbcx.cdopecxa = p-cod-operador      AND
                             crapbcx.cdsitbcx = 1  NO-ERROR. 
    ASSIGN crapbcx.nrsequni= crapbcx.nrsequni + 1.
              
    ASSIGN aux_nrconven  =  0
           aux_nrversao  =  0.

    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                       craptab.nmsistem = "CRED"            AND
                       craptab.tptabela = "USUARI"          AND
                       craptab.cdempres = 11                AND
                       craptab.cdacesso = "CORRESPOND"      AND
                       craptab.tpregist = 000               NO-LOCK NO-ERROR.
                       
    IF AVAIL craptab   THEN                    
       ASSIGN aux_nrconven = INT(SUBSTR(craptab.dstextab,1,9))
              aux_nrversao = INT(SUBSTR(craptab.dstextab,11,3)).
         
    ASSIGN aux_nragenci = 0
           aux_nrdaloja = 100 + p-cod-agencia.

    FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper   AND
                       crapage.cdagenci = p-cod-agencia      NO-LOCK NO-ERROR.
         
    IF   AVAILABLE crapage   THEN   
         ASSIGN aux_nragenci = crapage.cdagecbn.
     
    ASSIGN  aux_nrpdv      =  p-nro-caixa 
            aux_nsupdv     =  crapbcx.nrsequni + 1 
            aux_cdoperad   =  muda_caracter(p-cod-operador)
            aux_transacao  =  "315".
           /* Cancelamento */
 
    IF  p-tpdocmto = 1  THEN  /* Titulo */
        ASSIGN aux_codtrans = "268". /* Titulo */
    ELSE                       
        ASSIGN aux_codtrans = "358". /* Fatura */
    
    /*---  Formacao do campo payload  ---*/
    ASSIGN aux_payload  = "00001"     +     /* Fixo */
                          "00122"     +     /* Rotulo chave usuario   */ 
                          "0008"      +     /* Tamanho campo chave usuario */
                          STRING(SUBSTR(p-cdchave,1,8),"x(8)") + 
                          "00032"     +     /* Rotulo aut.chave */
                          "0004"      +     /* Tamanho aut.chave */
                          STRING(p-autchave,"9999").
    
    ASSIGN aux_tam_payload = 35.
    
    ASSIGN i-nro-rotulos   = 4. /* codigo barras e forma de pagto */
   
    ASSIGN aux_vldocto_int  = p-vlpagto  * 100. /* Valor documento */
    ASSIGN aux_vldocto_char = STRING(aux_vldocto_int).
    ASSIGN aux_tam_campo    = LENGTH(aux_vldocto_char).
    ASSIGN aux_tam_payload  = aux_tam_payload + aux_tam_campo.
    ASSIGN aux_tam_payload  = aux_tam_payload + 9. /* Tamanho Rotulo */
    ASSIGN aux_payload = aux_payload + 
                        "00113"      +  /* Rotulo Valor Documento          */
                        STRING(aux_tam_campo,"9999") + /* Tamanho vlr.docto*/
                        aux_vldocto_char + 
                        "00123"     +
                        "0003"      +
                        aux_codtrans.
                        
    ASSIGN aux_tam_payload = aux_tam_payload + 12. /* rotulo 123 */                    
    ASSIGN aux_tam_payload = aux_tam_payload + 1.  /* campo @ */

    ASSIGN aux_tipo_trn = "C".
    
    ASSIGN i-time = TIME.
    ASSIGN c_linha = " ".
    RUN processa_envio_recebimento ( INPUT  p-cooper,
                                     INPUT  p-cod-agencia,
                                     INPUT  p-nro-caixa,
                                     OUTPUT p-autchave,    
                                     OUTPUT p-cdchave).  
   
    IF c-desc-erro <> " " THEN
       RETURN "NOK".
    
    IF   c_linha      = " " AND
         aux_setlinha = " " THEN /* TIME OUT */ 
         DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Tempo Excedido - Execute Pendencias ".
            RUN cria-erro (INPUT  p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    RETURN "OK". 
    
END PROCEDURE.

PROCEDURE processa_envio_recebimento:

    DEF INPUT  PARAM p-cooper           AS CHAR.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
    DEF OUTPUT PARAM p-autchave         AS INTE. /* Nro Aut.Correspondente */
    DEF OUTPUT PARAM p-cdchave          AS CHAR. /* Chave Correspondente */

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    /*---- ENVIO ----*/
    ASSIGN aux_linha_envio = 
               STRING(aux_nrconven,"999999999") +        
               STRING(aux_nragenci,"9999")      +         
               STRING(aux_nrdaloja,"999999")    +       
               STRING(aux_nrpdv,"99999999")     +      
               STRING(aux_cdoperad,"999999999") +          
               STRING(aux_nsupdv,"99999999")    +       
               "00000000"                       +                     
               "0000"                           +                      
               "0000"                           +                      
               STRING(SUBSTR(aux_transacao,1,4),"x(04)")      +   
               STRING(aux_nrversao,"999")       +                             
               STRING(aux_tipo_trn,"x")         +                    
               "0"                              +                      
               "000"                            +                       
               STRING(i-nro-rotulos,"999")      +
               STRING(aux_vldocto_int,"99999999999999999") +              
               STRING(aux_tam_payload,"999999999").  
   
    IF  aux_tipo_trn = "C" THEN 
        DO:  
            ASSIGN aux_contador = 1.
            DO  WHILE aux_contador LE (aux_tam_payload - 1):
                ASSIGN aux_linha_envio = aux_linha_envio + 
                                     SUBSTR(aux_payload,aux_contador,1).
                ASSIGN aux_contador = aux_contador + 1.
            END.
            ASSIGN aux_linha_envio = aux_linha_envio + "@".
        END.
     
    ASSIGN aux_nmarquiv = "/usr/coop/sistema/siscaixa/web/spool/" +
                          crapcop.dsdircop            +
                          STRING(p-cod-agencia,"999") + 
                          STRING(p-nro-caixa,"999")   +
                          STRING(i-time,"99999")      + 
                          ".ret".

    ASSIGN aux_setlinha  = " ".
    UNIX SILENT VALUE("/usr/local/bin/mtcoban.sh "  +
                      '"' + STRING(aux_linha_envio) + '" '   +
                      '"' + TRIM(aux_nmarquiv)      + '" '   +
                      '"' + TRIM(crapcop.dsdircop)  + '"').

    /*--- RECEBIMENTO  --*/
    
    ASSIGN aux_contador = 1.
    
    ASSIGN c-desc-erro  = " ".

    RETORNO:
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE RETORNO:
      
         IF SEARCH (aux_nmarquiv) <> ?  THEN 
            DO:
          
                INPUT STREAM str_1 FROM VALUE(aux_nmarquiv) NO-ECHO.
                SET   STREAM str_1 aux_setlinha  WITH FRAME AA WIDTH 150.
                /* Primeira linha - Tamanho 102 */
  
                IF  SUBSTR(aux_setlinha,70,3) <> "000" THEN 
                    DO: 
                        /* Retorno com erro */     
                        ASSIGN aux_erro        = INT(SUBSTR(aux_setlinha,70,3))
                               aux_cod_agencia = p-cod-agencia
                               aux_nro_caixa   = p-nro-caixa.
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "Erro nao previsto " +
                                             STRING(aux_erro,"999").
                     
                    END. 

                ASSIGN  p-cdchave       = SUBSTR(aux_setlinha,45,8)
                        p-autchave      = INT(SUBSTR(aux_setlinha,57,4))
                        aux_tam_payload = INT(SUBSTR(aux_setlinha,93,9))
                        aux_tptransac   = SUBSTR(aux_setlinha,61,4)
                        c_linha         = "".

                SET   STREAM str_1 aux_setlinha  WITH FRAME AA WIDTH 150.
                /* Demais linhas - tamanho 38 */

                DO  WHILE TRUE   ON ENDKEY UNDO, LEAVE  RETORNO: 
                    ASSIGN c_linha = c_linha + 
                           STRING(SUBSTR(aux_setlinha,1,38),"x(38)").
                    SET   STREAM str_1 aux_setlinha  WITH FRAME AA WIDTH 150.

                END.  /* Do while */
              
                LEAVE RETORNO.
              
            END. /* IF SEARCH (aux_nmarquiv) <> ? */

         ASSIGN aux_contador = aux_contador + 1.
         IF  aux_contador > 900 THEN
             LEAVE RETORNO.

    END.   /* Do while */

    INPUT STREAM str_1 CLOSE.
    
    /* Mirtes
    UNIX SILENT VALUE("rm " + aux_nmarquiv + 
                      " 2>/dev/null").
    */

    IF  c-desc-erro <> " "  THEN 
        DO:
            IF  aux_tam_payload     > 0     AND
                SUBSTR(c_linha,1,1) = "Z"   THEN  /* Mensagem de ERRO COBAN */
                DO:
                    ASSIGN c-desc-erro = SUBSTR(c_linha,9,3) + "  - " +
                                         TRIM(SUBSTR(c_linha,15,40)).
   
                    RUN cria-erro (INPUT  p-cooper,
                                   INPUT aux_cod_agencia,
                                   INPUT aux_nro_caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                END.
            ELSE
                DO:
                    FIND crapcbe WHERE crapcbe.cdcooper = crapcop.cdcooper  AND
                                       crapcbe.cdcritic = aux_erro 
                                       NO-LOCK NO-ERROR.
                                       
                    IF  AVAIL crapcbe THEN 
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = STRING(crapcbe.cdcritic,"999") + 
                                             "-" + 
                                             STRING(crapcbe.cdorigem,"9")  + 
                                             "-" +
                                             crapcbe.dscritic.
   
                    RUN cria-erro (INPUT  p-cooper,
                                   INPUT aux_cod_agencia,
                                   INPUT aux_nro_caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                END.
        END.    

END PROCEDURE.

/********************************************************************************
 Função que muda caracter alfa para numerico.
*********************************************************************************/

FUNCTION muda_caracter RETURN DECIMAL
    (INPUT p-cod-operador AS CHARACTER):

DEF VAR aux_cont     AS INTE NO-UNDO.
DEF VAR converte     AS CHAR NO-UNDO.
DEF VAR aux_int      AS DECI NO-UNDO.
DEF VAR aux_result   AS CHAR NO-UNDO.

DEF VAR aux_cont2    AS INTE NO-UNDO.

  ASSIGN aux_cont  = 0
         aux_int   = 0
         aux_cont2 = 0.

  IF  LENGTH(p-cod-operador) > 9 THEN
      DO:
        ASSIGN aux_cont2 = LENGTH(p-cod-operador)
               aux_cont2 = aux_cont2 - 8        
               p-cod-operador = SUBSTRING(p-cod-operador, aux_cont2,
                                          LENGTH(p-cod-operador)).
      END.

  DO aux_cont = 1 TO LENGTH(p-cod-operador):

     converte = SUBSTR(p-cod-operador,aux_cont,1).

     aux_int = DECI(converte) NO-ERROR.

     IF ERROR-STATUS:ERROR THEN
        DO:
          aux_result = aux_result + "0".
        END.
     ELSE
       aux_result = aux_result + converte.
  END.

    RETURN DECI(aux_result).

END FUNCTION.

/* b1crap81.p */

/* .......................................................................... */
