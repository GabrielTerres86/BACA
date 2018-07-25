/* .............................................................................

   Programa: siscaixa/web/dbo/b1crap01.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 17/04/2018

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

			   06/12/2016 - P341-Automatiza��o BACENJUD - Alterada a valida��o 
			                do departamento para que a mesma seja feita atrav�s
							do c�digo e n�o da descri��o (Renato Darosci)

			   23/08/2017 - Alterado para validar as informacoes do operador 
							pelo AD. (PRJ339 - Reinert)
              
              17/04/2018 - Utiliza�ao do Caixa Online mesmo com o processo 
                           noturno executando (Fabio Adriano - AMCom).
............................................................................ **/


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

/* PRJ339 - REINERT (INICIO) */         
   /* Validacao de senha do usuario no AD somente no ambiente de producao */
   IF TRIM(OS-GETENV("PKGNAME")) = "pkgprod" THEN                
        DO:

       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

       /* Efetuar a chamada da rotina Oracle */ 
       RUN STORED-PROCEDURE pc_valida_senha_AD
           aux_handproc = PROC-HANDLE NO-ERROR(INPUT crapcop.cdcooper, /*Cooperativa*/
                                               INPUT p-cod-operador,   /*Operador   */
                                               INPUT p-senha,          /*Nr.da Senha*/
                                              OUTPUT 0,                /*Cod. critica */
                                              OUTPUT "").              /*Desc. critica*/

       /* Fechar o procedimento para buscarmos o resultado */ 
       CLOSE STORED-PROC pc_valida_senha_AD
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

       HIDE MESSAGE NO-PAUSE.

       /* Busca poss�veis erros */ 
       ASSIGN i-cod-erro  = 0
              c-desc-erro = ""
              i-cod-erro  = pc_valida_senha_AD.pr_cdcritic 
                            WHEN pc_valida_senha_AD.pr_cdcritic <> ?
              c-desc-erro = pc_valida_senha_AD.pr_dscritic 
                            WHEN pc_valida_senha_AD.pr_dscritic <> ?.
                            
      /* Apresenta a cr�tica */
      IF  i-cod-erro <> 0 OR c-desc-erro <> "" THEN
          DO: 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                             INPUT "",
                           INPUT YES).

            RETURN "NOK".
        END.
        END.
/* PRJ339 - REINERT (FIM) */
    
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
        
    /* Validacao de senha do usuario no AD somente no ambiente de producao */
    IF TRIM(OS-GETENV("PKGNAME")) = "pkgprod" THEN                
        DO:

       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

       /* Efetuar a chamada da rotina Oracle */ 
       RUN STORED-PROCEDURE pc_valida_senha_AD
           aux_handproc = PROC-HANDLE NO-ERROR(INPUT crapcop.cdcooper, /*Cooperativa*/
                                               INPUT p-cod-operador,   /*Operador   */
                                               INPUT p-senha,          /*Nr.da Senha*/
                                              OUTPUT 0,                /*Cod. critica */
                                              OUTPUT "").              /*Desc. critica*/

       /* Fechar o procedimento para buscarmos o resultado */ 
       CLOSE STORED-PROC pc_valida_senha_AD
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

       HIDE MESSAGE NO-PAUSE.

       /* Busca poss�veis erros */ 
       ASSIGN i-cod-erro  = 0
              c-desc-erro = ""
              i-cod-erro  = pc_valida_senha_AD.pr_cdcritic 
                            WHEN pc_valida_senha_AD.pr_cdcritic <> ?
              c-desc-erro = pc_valida_senha_AD.pr_dscritic 
                            WHEN pc_valida_senha_AD.pr_dscritic <> ?.
                            
      /* Apresenta a cr�tica */
      IF  i-cod-erro <> 0 OR c-desc-erro <> "" THEN
          DO: 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                             INPUT "",
                           INPUT YES).

            RETURN "NOK".
        END.
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
    
    /* Validacao de senha do usuario no AD somente no ambiente de producao */
    IF TRIM(OS-GETENV("PKGNAME")) = "pkgprod" THEN                
        DO:

       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

       /* Efetuar a chamada da rotina Oracle */ 
       RUN STORED-PROCEDURE pc_valida_senha_AD
           aux_handproc = PROC-HANDLE NO-ERROR(INPUT crapcop.cdcooper, /*Cooperativa*/
                                               INPUT p-cod-operador,   /*Operador   */
                                               INPUT p-senha,          /*Nr.da Senha*/
                                              OUTPUT 0,                /*Cod. critica */
                                              OUTPUT "").              /*Desc. critica*/

       /* Fechar o procedimento para buscarmos o resultado */ 
       CLOSE STORED-PROC pc_valida_senha_AD
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

       HIDE MESSAGE NO-PAUSE.

       /* Busca poss�veis erros */ 
       ASSIGN i-cod-erro  = 0
              c-desc-erro = ""
              i-cod-erro  = pc_valida_senha_AD.pr_cdcritic 
                            WHEN pc_valida_senha_AD.pr_cdcritic <> ?
              c-desc-erro = pc_valida_senha_AD.pr_dscritic 
                            WHEN pc_valida_senha_AD.pr_dscritic <> ?.
                            
      /* Apresenta a cr�tica */
      IF  i-cod-erro <> 0 OR c-desc-erro <> "" THEN
          DO: 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                             INPUT "",
                           INPUT YES).

            RETURN "NOK".
        END.
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
                            crapbcx.dtmvtolt = crapdat.dtmvtocd     AND
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
                             crapbcx.dtmvtolt = crapdat.dtmvtocd    AND
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
                            

 