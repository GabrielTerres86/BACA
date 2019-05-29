{dbo/bo-erro1.i}

DEF VAR var_getPost as int no-undo.
def var var_cdcooper as int no-undo.
def var var_nrdconta as int no-undo.
def var var_nrdcaixa as int no-undo.
def var var_cdagenci as int no-undo.
def var v_saldoini as char no-undo.
def var v_operador as char no-undo.
def var v_autent as int no-undo.


DEF VAR i-cod-erro      AS INTEGER.
DEF VAR c-desc-erro     AS CHAR.

DEF VAR h-b1crap00   AS HANDLE  NO-UNDO.
DEF VAR h-b1crap12   AS HANDLE  NO-UNDO.

form var_getPost label "getPost" 
     "0 - GET / 1 - POST" skip(1)
       var_cdcooper label "Cooperativa" skip(1)
     /*  var_nrdconta label "Conta" skip(1)*/
       var_nrdcaixa label "Caixa" skip(1)
       var_cdagenci label "Agencia" skip(1)
       v_operador label "Operador" skip(1)
       WITH  WIDTH 78 SIDE-LABELS OVERLAY CENTERED FRAME f_update.

update var_getPost 
       var_cdcooper
       /*var_nrdconta*/
       var_nrdcaixa
       var_cdagenci
       v_operador
       with frame f_update.
       
find crapcop where crapcop.cdcooper = var_cdcooper no-lock no-error.

if not avail crapcop then
   do:
       message "Nao encontrou a crapcop".
       pause.
       return.
       
   end.   

  /*Valida o POST */
  IF var_getPost = 1 THEN DO:
    
     message "POST".
     /*
    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
     
    RUN valida-transacao2    /* 14/06/2018 - Alterado para chamar a procedure valida-transacao2 - Everton Deserto(AMCOM).*/      
                         IN h-b1crap00(INPUT v_coop,
                                       INPUT v_pac,
                                       INPUT v_caixa).
 
    IF  RETURN-VALUE = "NOK" THEN DO:
         
        {include/i-erro.i}
    END.
    ELSE DO:
 
        IF  get-value("cancela") <> "" THEN DO:
                 
            RUN dbo/b1crap12.p PERSISTENT SET h-b1crap12.
                         
            RUN retorna-dados-fechamento IN h-b1crap12 (INPUT v_coop,
                                                        INPUT v_operador,
                                                        INPUT int(v_pac),
                                                        INPUT int(v_caixa),
                                                        OUTPUT v_autent,
                                                        OUTPUT v_saldoini).
            
                        IF  RETURN-VALUE = "NOK" THEN  DO:
                {include/i-erro.i}
            END.
                         
            DELETE PROCEDURE h-b1crap12.
            ASSIGN v_saldofin  = ""
                   v_lacre     = ""
                   vh_foco     = "8".
        END.
        ELSE DO:
 
             RUN dbo/b2crap01.p PERSISTENT SET h-b2crap01.
                 
             RUN GetCookie IN web-utilities-hdl
                 ( INPUT "Autenticacao" ,
                   OUTPUT p-autentica).
 
             RUN  verifica-importacao-fechamento 
                IN h-b2crap01 (INPUT v_coop,
                               INPUT INT(get-value("user_pac")),
                               INPUT INT(get-value("user_cx")),
                               INPUT INT(p-autentica)).
             
                         DELETE PROCEDURE h-b2crap01.
                 
             IF  RETURN-VALUE = "NOK"  THEN DO:
                 {include/i-erro.i}  
             END.

             ELSE DO:
                 
                                 RUN dbo/b1crap12.p PERSISTENT SET h-b1crap12.
                                 
                 RUN retorna-dados-fechamento IN h-b1crap12 (INPUT v_coop,
                                                             INPUT v_operador,
                                                             INPUT int(v_pac),
                                                             INPUT int(v_caixa),
                                                             OUTPUT v_autent,
                                                             OUTPUT v_saldoini).
                                  
                                 IF  RETURN-VALUE = "NOK" THEN  DO:
                                  
                     {include/i-erro.i}
                 END.
                              
              
                 ELSE DO:
                 
                      /*=============Verificar Pendencias =======*/
                      FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper AND
                                         crapage.cdagenci = INT(v_pac)
                                         NO-LOCK NO-ERROR.
                      
                      
                                          IF AVAIL crapage THEN                   
                         IF crapage.cdagecbn <> 0   AND
                            crapage.vercoban = TRUE THEN
                            DO:  /*
                                 RUN dbo/b1crap80.p PERSISTENT SET h-b1crap80.
                                 RUN executa-pendencias-fechamento
                                    IN h-b1crap80(INPUT v_coop,
                                                  INPUT INT(v_pac),
                                                  INPUT INT(v_caixa),
                                                  INPUT v_operador,
                                                  OUTPUT p-autchave,
                                                  OUTPUT p-cdchave).
                                          
                                 DELETE PROCEDURE h-b1crap80. */
                                 
                            END. 
                                         
                 IF   RETURN-VALUE =  "NOK" THEN DO:
                     {include/i-erro.i}
                 END.
                                      
                 ELSE DO:
                           
                      IF  get-value("ok") <> "" THEN DO:
                                           
                          RUN  fechamento-boletim-caixa 
                             IN h-b1crap12 (INPUT v_coop,
                                            INPUT v_operador,
                                            INPUT INT(v_pac),
                                            INPUT INT(v_caixa),
                                            INPUT DEC(v_saldofin),
                                            INPUT INT(v_lacre)).
                          IF  RETURN-VALUE = "NOK" THEN  DO:
                              {include/i-erro.i}
                          END.                                       
                          ELSE DO: 
     
                              ASSIGN l-houve-erro = NO.
                              
                              DO TRANSACTION:
                                                           
                                 RUN atualiza-fechamento 
                                     IN h-b1crap12 (INPUT v_coop,
                                                    INPUT v_operador,
                                                    INPUT INT(v_pac),
                                                    INPUT INT(v_caixa),
                                                    INPUT DEC(v_saldofin),
                                                    INPUT INT(v_lacre),
                                                    INPUT INT(v_autent)).
    
                                 IF  RETURN-VALUE = "NOK" THEN DO:
                                     ASSIGN l-houve-erro = YES.
                                     FOR EACH w-craperr:
                                         DELETE w-craperr.
                                     END.
                                      
                                                                         FOR EACH craperr NO-LOCK WHERE
                                              craperr.cdcooper =
                                                      crapcop.cdcooper      AND
                                              craperr.cdagenci = INT(v_pac) AND
                                              craperr.nrdcaixa =  INT(v_caixa):

                                         CREATE w-craperr.
                                         ASSIGN w-craperr.cdcooper
                                                = craperr.cdcooper
                                                w-craperr.cdagenci 
                                                = craperr.cdagenc
                                                w-craperr.nrdcaixa  
                                                = craperr.nrdcaixa
                                                w-craperr.nrsequen 
                                                = craperr.nrsequen
                                                w-craperr.cdcritic  
                                                = craperr.cdcritic
                                                w-craperr.dscritic
                                                = craperr.dscritic
                                                w-craperr.erro   
                                                = craperr.erro.
                                     END.
                                     UNDO.
                                 END.     
                              END.
    
                              IF  l-houve-erro = YES  THEN DO:

 
                                  FOR EACH craperr WHERE 
                                     craperr.cdcooper = crapcop.cdcooper  AND
                                     craperr.cdagenci = INTE(v_pac)       AND
                                     craperr.nrdcaixa = INTE(v_caixa)
                                     EXCLUSIVE-LOCK:
                                     DELETE craperr.
                                  END.
 
                                  FOR EACH w-craperr NO-LOCK:
                                      CREATE craperr.
                                      ASSIGN craperr.cdcooper
                                              = w-craperr.cdcooper
                                             craperr.cdagenci  
                                              = w-craperr.cdagenc
                                             craperr.nrdcaixa 
                                              = w-craperr.nrdcaixa
                                             craperr.nrsequen  
                                              = w-craperr.nrsequen
                                             craperr.cdcritic 
                                              = w-craperr.cdcritic
                                             craperr.dscritic 
                                               = w-craperr.dscritic
                                             craperr.erro  
                                                  = w-craperr.erro.
                                      VALIDATE craperr.
                                  END.
                                  {include/i-erro.i}
                              END.
                              ELSE DO:
  
                                   {&OUT}
                              "<script>alert('Fechamento efetuado com sucesso.')
                                    </script>".   
                                  
                              END.


                          END.
                      END.    
                 END.

                 END.

                 DELETE PROCEDURE h-b1crap12.

             END.
        END.
    END.
         
  */  
  END. 
  
  
 
  /* REQUEST-METHOD = GET */ 
  ELSE DO:
        
    Message ">>>>>>>    GET 1  <<<<<<<<".    
    
    /*RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.*/
         
    Message ">>>>>>>    GET 2  <<<<<<<<". 
    
    RUN valida-transacao2 (INPUT crapcop.nmrescop, /* 14/06/2018 - Alterado para chamar a procedure valida-transacao2 - Everton Deserto(AMCOM)*/
                                       INPUT var_cdagenci,
                                       INPUT var_nrdcaixa).
                                       
    Message ">>>>>>>    GET 3  <<<<<<<<". 
    
        /*DELETE PROCEDURE h-b1crap00.*/
    
    Message ">>>>>>>    GET 4  <<<<<<<<". 
    
    IF RETURN-VALUE = "NOK" THEN
    DO:
        Message ">>>>>>>    GET 5  <<<<<<<<". 
         
        /*{include/i-erro.i}*/
        FIND FIRST craperr NO-LOCK  where
                   craperr.cdcooper = crapcop.cdcooper AND
                   craperr.cdagenci = var_cdagenci   and
                   craperr.nrdcaixa = var_nrdcaixa no-error.
        
        Message ">>>>>>>    GET 6  <<<<<<<<". 
 
        IF AVAIL craperr THEN DO:
            message "1. Achou o erro:" + craperr.dsCritic.       
        END.

    END.
    ELSE DO:
                
         Message ">>>>>>>    GET 7  <<<<<<<<". 
          
         /*RUN dbo/b1crap12.p PERSISTENT SET h-b1crap12.*/
         
          Message ">>>>>>>    GET 8  <<<<<<<<". 
                 
         RUN retorna-dados-fechamento               (INPUT crapcop.nmrescop,
                                                     INPUT v_operador,
                                                     INPUT var_cdagenci,
                                                     INPUT var_nrdcaixa,
                                                     OUTPUT v_autent,
                                                     OUTPUT v_saldoini).
         Message ">>>>>>>    GET 9  <<<<<<<<". 
         
         ASSIGN v_saldoini = trim(string(dec(v_saldoini),"zzz,zzz,zz9.99")).
         
         Message ">>>>>>>    GET 10  <<<<<<<<". 
         
                 IF  RETURN-VALUE = "NOK" THEN  DO:
             /*{include/i-erro.i}*/
             
             Message ">>>>>>>    GET 11  <<<<<<<<". 
             
             FIND FIRST craperr NO-LOCK  where
                       craperr.cdcooper = crapcop.cdcooper AND
                       craperr.cdagenci = var_cdagenci   and
                       craperr.nrdcaixa = var_nrdcaixa no-error.
              
             Message ">>>>>>>    GET 12  <<<<<<<<". 
             
            IF AVAIL craperr THEN DO:
                message "2 Achou o erro: " + craperr.dsCritic.       
            END.
            
         END.
         
         Message ">>>>>>>    GET 13  <<<<<<<<". 
         
         /*DELETE PROCEDURE h-b1crap12.*/
         
         Message ">>>>>>>    GET 14  <<<<<<<<". 
         
     END.
         
  END. 
  
  
  
  
  PROCEDURE retorna-dados-fechamento:
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-operador  AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF OUTPUT PARAM p-autenticacoes AS INTE.
    DEF OUTPUT PARAM p-saldo-inicial AS DEC.
                                  
    DEF VAR i-autenticacoes AS INTE NO-UNDO.

    Message ">>>>>>>    retorna-dados-fechamento 1  <<<<<<<<". 
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
     
     Message ">>>>>>>    retorna-dados-fechamento 2  <<<<<<<<". 
     
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    Message ">>>>>>>    retorna-dados-fechamento 3  <<<<<<<<". 
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    Message ">>>>>>>    retorna-dados-fechamento 4  <<<<<<<<". 
    
	IF p-nro-caixa = 900 THEN
	DO:
        Message ">>>>>>>    retorna-dados-fechamento 5  <<<<<<<<". 
        
		FIND LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper     AND
								crapbcx.dtmvtolt = crapdat.dtmvtolt     AND
								crapbcx.cdagenci = p-cod-agencia        AND
								crapbcx.nrdcaixa = p-nro-caixa          AND
								crapbcx.cdopecxa = p-cod-operador       AND
								crapbcx.cdsitbcx = 1 
								USE-INDEX crapbcx1 NO-LOCK NO-ERROR. 
                                
        Message ">>>>>>>    retorna-dados-fechamento 6  <<<<<<<<". 
        
	END.
	ELSE
	DO:
    
    Message ">>>>>>>    retorna-dados-fechamento 7  <<<<<<<<". 
    
    FIND LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper     AND
                            crapbcx.dtmvtolt = crapdat.dtmvtocd     AND /* 14/06/2018 - Alterado para considerar dtmvtocd - Everton Deserto*/
                            crapbcx.cdagenci = p-cod-agencia        AND
                            crapbcx.nrdcaixa = p-nro-caixa          AND
                            crapbcx.cdopecxa = p-cod-operador       AND
                            crapbcx.cdsitbcx = 1 
                            USE-INDEX crapbcx1 NO-LOCK NO-ERROR. 
                            
    Message ">>>>>>>    retorna-dados-fechamento 8  <<<<<<<<". 
    
	END.
                            
    IF  NOT AVAIL crapbcx  THEN 
        DO:
            Message ">>>>>>>    retorna-dados-fechamento 9  <<<<<<<<". 
            
            ASSIGN i-cod-erro  = 698
                   c-desc-erro = " ".      

            Message ">>>>>>>    retorna-dados-fechamento 10  <<<<<<<<". 
            
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
                           
             Message ">>>>>>>    retorna-dados-fechamento 11  <<<<<<<<". 
             
            RETURN "NOK".
            
            Message ">>>>>>>    retorna-dados-fechamento 12  <<<<<<<<". 
            
        END.
   
     Message ">>>>>>>    retorna-dados-fechamento 13  <<<<<<<<". 
     
    ASSIGN i-autenticacoes = 0.
    
     Message ">>>>>>>    retorna-dados-fechamento 14  <<<<<<<<". 
     
    FOR EACH crapaut WHERE crapaut.cdcooper = crapcop.cdcooper  AND
                           crapaut.cdagenci = p-cod-agencia     AND
                           crapaut.nrdcaixa = p-nro-caixa       AND 
                           crapaut.cdopecxa = p-cod-operador    AND
                           crapaut.dtmvtolt = crapdat.dtmvtocd  NO-LOCK:  /* 14/06/2018 - Alterado para considerar dtmvtocd - Everton Deserto*/
          Message ">>>>>>>    retorna-dados-fechamento 15  <<<<<<<<". 
          
        ASSIGN i-autenticacoes = i-autenticacoes + 1.
         Message ">>>>>>>    retorna-dados-fechamento 16  <<<<<<<<". 
    END.

     Message ">>>>>>>    retorna-dados-fechamento 17  <<<<<<<<". 
     
    ASSIGN p-autenticacoes = i-autenticacoes
           p-saldo-inicial = crapbcx.vldsdini.

     Message ">>>>>>>    retorna-dados-fechamento 18  <<<<<<<<". 
     
    RETURN "OK".

    
END PROCEDURE.
 
PROCEDURE valida-transacao2:

    DEF INPUT  PARAM p-cooper              AS CHAR.
    DEF INPUT  PARAM p-cod-agencia         AS INTE.
    DEF INPUT  PARAM p-nro-caixa           AS INTE.

    DEF VAR dt-dia-util   AS DATE                                 NO-UNDO.
    
     Message ">>>>>>>    valida-transacao2 1  <<<<<<<<".
     
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
     Message ">>>>>>>    valida-transacao2 2  <<<<<<<<".
     
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
    
     Message ">>>>>>>    valida-transacao2 3  <<<<<<<<".
     
    IF  SEARCH("../../arquivos/cred_bloq") <> ? THEN
        DO:
             Message ">>>>>>>    valida-transacao2 4  <<<<<<<<".
             
           ASSIGN i-cod-erro  = 0
                  c-desc-erro = "Sistema Bloqueado ".
                  
             Message ">>>>>>>    valida-transacao2 5  <<<<<<<<".
             
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
                          
              Message ">>>>>>>    valida-transacao2 6  <<<<<<<<".
              
           RETURN "NOK".
        END.
    
     Message ">>>>>>>    valida-transacao2 7  <<<<<<<<".
     
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
     
    Message ">>>>>>>    valida-transacao2 8  <<<<<<<<".
 
    IF  NOT AVAIL crapdat THEN 
        DO:
            Message ">>>>>>>    valida-transacao2 9  <<<<<<<<".
            
            ASSIGN i-cod-erro  = 1
                   c-desc-erro = " ".
                   
            Message ">>>>>>>    valida-transacao2 10  <<<<<<<<".
            
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            Message ">>>>>>>    valida-transacao2 11  <<<<<<<<".
            
            RETURN "NOK".

        END. 

    Message ">>>>>>>    valida-transacao2 12 <<<<<<<<".

    /** --- Verifica se eh ultimo dia util do ano --- **/
    ASSIGN dt-dia-util = DATE(12,31,YEAR(TODAY)).
    
    Message ">>>>>>>    valida-transacao2 13  <<<<<<<<".
    
    /** Se dia 31/12 for domingo, o ultimo dia util e 29/12 **/
    IF  WEEKDAY(dt-dia-util) = 1  THEN
        dt-dia-util = DATE(12,29,YEAR(crapdat.dtmvtoan)).
    
    Message ">>>>>>>    valida-transacao2 14  <<<<<<<<".
    
    /** Se dia 31/12 for sabado, o ultimo dia util e 30/12 **/
    IF  WEEKDAY(dt-dia-util) = 7  THEN
        dt-dia-util = DATE(12,30,YEAR(crapdat.dtmvtoan)).
     
    Message ">>>>>>>    valida-transacao2 15  <<<<<<<<".
     
    IF  TODAY = dt-dia-util  THEN
        DO:
			Message ">>>>>>>    valida-transacao2 16  <<<<<<<<".
			
            ASSIGN i-cod-erro  = 914
                   c-desc-erro = " ".

		Message ">>>>>>>    valida-transacao2 17  <<<<<<<<".
		
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
					   
		Message ">>>>>>>    valida-transacao2 18  <<<<<<<<".
		
    END. 
	
	Message ">>>>>>>    valida-transacao2 19  <<<<<<<<".
    
    /* Validar o horario minimo login - SCTASK0027519 */
    IF  TIME < crapcop.hrinicxa  THEN
        DO:
			Message ">>>>>>>    valida-transacao2 20  <<<<<<<<".
			
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Login permitido a partir das " + STRING(crapcop.hrinicxa, "HH:MM") + ".".

			Message ">>>>>>>    valida-transacao2 21  <<<<<<<<".
			
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
						   
			Message ">>>>>>>    valida-transacao2 22  <<<<<<<<".
			
        END.
   
   Message ">>>>>>>    valida-transacao2 23  <<<<<<<<".
   
    RUN verifica-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa).
                        
	Message ">>>>>>>    valida-transacao2 24  <<<<<<<<".
	
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

	Message ">>>>>>>    valida-transacao2 25  <<<<<<<<".
	
    RETURN "OK".
         
END PROCEDURE.