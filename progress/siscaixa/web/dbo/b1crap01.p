/* .............................................................................

   Programa: siscaixa/web/dbo/b1crap01.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 20/10/2009.

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Validacao Acesso Usuario ao Sistema

   Alteracoes: 09/08/2005 - Passar codigo da cooperativa como parametro para
                            as procedures (Julio)
                            
               22/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               16/10/2007 - Nao permite aos operadores "1" e "888" logarem no
                            sistema (Elton).
                            
               25/05/2009 - Alteracao CDOPERAD (Kbase).

               20/10/2009 - No valida-supervisor o Siscaixa pode cadastrar
                            sem ser supervisor. Como supervisor permitia
                            outras operacoes no caixa (Magui).

			   06/12/2016 - P341-Automatização BACENJUD - Alterada a validação 
			                do departamento para que a mesma seja feita através
							do código e não da descrição (Renato Darosci)
............................................................................ */


/*---------------------------------------------------------------*/
/*  b1crap01.p - Validacao Acesso Usuario ao Sistema             */
/*---------------------------------------------------------------*/

{dbo/bo-erro1.i}

DEF VAR i-cod-erro  AS INTEGER.
DEF VAR c-desc-erro AS CHAR.


PROCEDURE valida-operador:
    DEF INPUT PARAM p-cooper        AS CHAR.    
    DEF INPUT PARAM p-cod-operador  AS char.
    DEF INPUT PARAM p-senha         AS CHAR.
    DEF INPUT PARAM p-cod-agencia   AS INTE.
    DEF INPUT PARAM p-nro-caixa     AS INTE.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
    
    FIND crapope WHERE crapope.cdcooper = crapcop.cdcooper  AND
                       crapope.cdoperad = p-cod-operador    NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapope   THEN
         DO:
             ASSIGN i-cod-erro  = 67
                    c-desc-erro = " ".
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
             IF   crapope.cddepart = 17  OR    /* SISCAIXA */ 
                  crapope.cddepart = 20  THEN  /* TI */
                  DO:
                      ASSIGN i-cod-erro  = 67
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

    IF  p-senha <> crapope.cddsenha  THEN 
        DO:
            ASSIGN i-cod-erro  = 3
                   c-desc-erro = " ".
                   
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    IF  AVAIL crapdat                                               AND
      ((crapdat.dtmvtolt - crapope.dtaltsnh) >= crapope.nrdedias)   THEN 
        DO:
            ASSIGN i-cod-erro  = 4
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
    
    IF  crapope.cdsitope <> 1 THEN 
        DO:
            ASSIGN i-cod-erro  = 627
                   c-desc-erro = " ". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa, 
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.

    IF  crapope.tpoperad <> 1   AND
        crapope.tpoperad <> 3   THEN 
        DO:
            ASSIGN i-cod-erro  = 36 
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.

    RUN verifica-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa).
                       
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    RETURN "OK".
    
END PROCEDURE.

PROCEDURE valida-supervisor:
    DEF INPUT PARAM p-cooper        AS CHAR.
    DEF INPUT PARAM p-cod-operador  AS char.
    DEF INPUT PARAM p-senha         AS CHAR.
    DEF INPUT PARAM p-cod-agencia   AS INTE.
    DEF INPUT PARAM p-nro-caixa     AS INTE.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
     
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
    
    FIND crapope WHERE crapope.cdcooper = crapcop.cdcooper  AND
                       crapope.cdoperad = p-cod-operador    NO-LOCK NO-ERROR.
         
    IF  NOT AVAIL crapope THEN 
        DO:
            ASSIGN i-cod-erro  = 67
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
        
    IF  p-senha <> crapope.cddsenha  THEN 
        DO:
            ASSIGN i-cod-erro  = 3
                   c-desc-erro = " ".
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
                             
    IF  AVAIL crapdat                                               AND
      ((crapdat.dtmvtolt - crapope.dtaltsnh) >= crapope.nrdedias)   THEN 
        DO:
            ASSIGN i-cod-erro  = 4
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
        
    IF  crapope.cdsitope <> 1 THEN 
        DO:
            ASSIGN i-cod-erro  = 627
                   c-desc-erro = " ". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa, 
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.

    IF  crapope.cddepart <> 17 AND   /* SISCAIXA */
       (crapope.nvoperad <> 2  /* Nivel Operador - 2 = Supervisor */ AND
        crapope.nvoperad <> 3)  /*                - 3 = Gerente    */ THEN 
        DO: 
            ASSIGN i-cod-erro  = 36
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
   
          
    RUN verifica-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa).
                       
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    RETURN "OK".
END PROCEDURE.

PROCEDURE valida-gerente:
    DEF INPUT PARAM p-cooper        AS CHAR.
    DEF INPUT PARAM p-cod-operador  AS char.
    DEF INPUT PARAM p-senha         AS CHAR.
    DEF INPUT PARAM p-cod-agencia   AS INTE.
    DEF INPUT PARAM p-nro-caixa     AS INTE.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
     
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
    
    FIND crapope WHERE crapope.cdcooper = crapcop.cdcooper  AND
                       crapope.cdoperad = p-cod-operador    NO-LOCK NO-ERROR.
                       
    IF  NOT AVAIL crapope THEN 
        DO:
            ASSIGN i-cod-erro  = 67
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
    
    IF  p-senha <> crapope.cddsenha  THEN 
        DO:
            ASSIGN i-cod-erro  = 3
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
   
    IF  AVAIL crapdat                                               AND
      ((crapdat.dtmvtolt - crapope.dtaltsnh) >= crapope.nrdedias)   THEN 
        DO:
            ASSIGN i-cod-erro  = 4
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
    
    IF  crapope.cdsitope <> 1 THEN 
        DO:
            ASSIGN i-cod-erro  = 627
                   c-desc-erro = " ". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa, 
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.

    IF  crapope.nvoperad <> 2   AND
        crapope.nvoperad <> 3   THEN 
        DO:         
            ASSIGN i-cod-erro  = 36
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.

    RUN verifica-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa).
                       
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    RETURN "OK".
END PROCEDURE.

PROCEDURE valida-caixa-aberto:
    DEF INPUT PARAM p-cooper        AS CHAR.
    DEF INPUT PARAM p-cod-operador  AS char.
    DEF INPUT PARAM p-cod-agencia   AS INTE.
    DEF INPUT PARAM p-nro-caixa     AS INTE.
               
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
     
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
          
    /* Verifica se o caixa ja foi aberto hoje, nao pode por enquanto
       e necessario alterar o programa do boletim */
    FIND LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper     AND
                            crapbcx.dtmvtolt = crapdat.dtmvtolt     AND
                            crapbcx.cdagenci = p-cod-agencia        AND
                            crapbcx.nrdcaixa = p-nro-caixa          AND
                            crapbcx.cdopecxa <> p-cod-operador      AND
                            crapbcx.cdsitbcx = 2  
                            NO-LOCK NO-ERROR. 
                            
    IF  AVAIL crapbcx  THEN 
        DO:
            ASSIGN i-cod-erro  = 836
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
    
    /* Verifica se Usuario abriu caixa em outro terminal */
    FIND first crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper    AND
                             crapbcx.dtmvtolt = crapdat.dtmvtolt    AND
                             crapbcx.cdopecxa = p-cod-operador      AND
                             crapbcx.cdsitbcx = 1 
                             USE-INDEX crapbcx3 NO-LOCK NO-ERROR.
     
    IF  AVAIL crapbcx  THEN 
        DO:
            IF  p-nro-caixa <> crapbcx.nrdcaixa  THEN 
                DO:
    
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = 
                                 "Operador ja esta utilizando outro caixa ".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.       
        END.
          
    RETURN "OK".
    
END PROCEDURE.

/* b1crap01.p */

/* .......................................................................... */

 