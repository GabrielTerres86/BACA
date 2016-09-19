/*------------------------------------------------------------------
 b2crap00.p - Calcular e conferir o digito modulo onze (Antigo digfun)
 
                                              Ultima atualizacao: 14/06/2010

 Alteracoes: 15/08/2007 - Criada a procedure verifica-digito-internet para o
                          tratamento para os erros da internet (Evandro).
                          
             14/06/2010 - Tratamento para PAC 91, conforme PAC 90 (Elton).

----------------------------------------------------------------------*/
{dbo/bo-erro1.i}

DEF VAR i-cod-erro  AS INTEGER.
DEF VAR c-desc-erro AS CHAR.

DEF  VAR aux_digito   AS INT     INIT 0  NO-UNDO.
DEF  VAR aux_posicao  AS INT     INIT 0  NO-UNDO.
DEF  VAR aux_peso     AS INT     INIT 9  NO-UNDO.
DEF  VAR aux_calculo  AS INT     INIT 0  NO-UNDO.
DEF  VAR aux_resto    AS INT     INIT 0  NO-UNDO.

PROCEDURE verifica-digito.
      
    DEF INPUT  PARAM p-cooper              AS CHAR.
    DEF INPUT  PARAM p-cod-agencia         AS INTE.
    DEF INPUT  PARAM p-nro-caixa           AS INTE.
    DEF INPUT-OUTPUT  PARAM p-nro-conta AS DECIMAL FORMAT ">>>>>>>>>>>>>9".

    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    /*Identifica conta do convenio com a Caixa-Concredi*/
    IF p-nro-conta = 030035008 THEN
        RETURN 'OK'.

    ASSIGN i-cod-erro = 0.

    IF  LENGTH(STRING(p-nro-conta)) < 2   THEN DO:
        ASSIGN i-cod-erro  = 8
               c-desc-erro = " ".   
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        
        RETURN "NOK".
    END.

    DO  aux_posicao = (LENGTH(STRING(p-nro-conta)) - 1) TO 1 BY -1:
        aux_calculo = aux_calculo + (INTEGER(SUBSTRING(STRING(p-nro-conta),aux_posicao,1)) * aux_peso).
        aux_peso    = aux_peso - 1.
        IF   aux_peso = 1   THEN
             aux_peso = 9.
    END.  

    aux_resto = aux_calculo MODULO 11.

    IF  aux_resto > 9   THEN
        aux_digito = 0.
    ELSE
        aux_digito = aux_resto.

    IF  (INTEGER(SUBSTRING(STRING(p-nro-conta),
         LENGTH(STRING(p-nro-conta)),1))) <> aux_digito   THEN DO:
         ASSIGN i-cod-erro  = 8
                c-desc-erro = " ".

        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        
    END.
    p-nro-conta =
     DEC(SUBSTR(STRING(p-nro-conta),1,LENGTH(STRING(p-nro-conta)) - 1) +
                      STRING(aux_digito)).
    
    IF  i-cod-erro > 0  THEN DO:
        RETURN "NOK".
    END.
    ELSE
        RETURN "OK".
END PROCEDURE.


PROCEDURE verifica-digito-internet.

    DEF INPUT  PARAM p-cooper              AS CHAR.
    DEF INPUT  PARAM p-nrdconta            AS INTE.
    DEF INPUT  PARAM p-idseqttl            LIKE crapttl.idseqttl.
    DEF INPUT  PARAM p-cod-agencia         AS INTE.
    DEF INPUT  PARAM p-nro-caixa           AS INTE.
    DEF INPUT-OUTPUT  PARAM p-nro-conta AS DECIMAL FORMAT ">>>>>>>>>>>>>9".

    DEFINE  VARIABLE aux_nrdcaixa          LIKE crapaut.nrdcaixa       NO-UNDO.
    
    /* Tratamento de erros para internet e TAA */
    IF   p-cod-agencia = 90   OR   /** Internet **/
         p-cod-agencia = 91   THEN /** TAA **/
         aux_nrdcaixa = INT(STRING(p-nrdconta) + STRING(p-idseqttl)).
    ELSE
         aux_nrdcaixa = p-nro-caixa.


    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT aux_nrdcaixa).


    /*Identifica conta do convenio com a Caixa-Concredi*/
    IF p-nro-conta = 030035008 THEN
        RETURN 'OK'.

    ASSIGN i-cod-erro = 0.

    IF  LENGTH(STRING(p-nro-conta)) < 2   THEN DO:
        ASSIGN i-cod-erro  = 8
               c-desc-erro = " ".   
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT aux_nrdcaixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        
        RETURN "NOK".
    END.

    DO  aux_posicao = (LENGTH(STRING(p-nro-conta)) - 1) TO 1 BY -1:
        aux_calculo = aux_calculo + (INTEGER(SUBSTRING(STRING(p-nro-conta),aux_~posicao,1)) * aux_peso).
        aux_peso    = aux_peso - 1.
        IF   aux_peso = 1   THEN
             aux_peso = 9.
    END.  

    aux_resto = aux_calculo MODULO 11.

    IF  aux_resto > 9   THEN
        aux_digito = 0.
    ELSE
        aux_digito = aux_resto.

    IF  (INTEGER(SUBSTRING(STRING(p-nro-conta),
         LENGTH(STRING(p-nro-conta)),1))) <> aux_digito   THEN DO:
         ASSIGN i-cod-erro  = 8
                c-desc-erro = " ".

        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT aux_nrdcaixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        
    END.
    p-nro-conta =
     DEC(SUBSTR(STRING(p-nro-conta),1,LENGTH(STRING(p-nro-conta)) - 1) +
                      STRING(aux_digito)).
    
    IF  i-cod-erro > 0  THEN DO:
        RETURN "NOK".
    END.
    ELSE
        RETURN "OK".
END PROCEDURE.

/* b2crap00.p */
