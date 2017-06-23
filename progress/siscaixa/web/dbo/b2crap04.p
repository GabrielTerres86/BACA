/*---------------------------------------------------------------*/
/*  b2crap004.p - Consulta Cartao                                */
/*---------------------------------------------------------------*/
/*
    
    Alteracoes: 02/03/2006 - Unificao dos Bancos - SQLWorks - Fernando.

                21/09/2007 - Retirar critica 624 que comparava senha nova com a
                             senha da URA (David).
                             
                23/05/2011 - Alterada a leitura da tabela craptab para a 
                             tabela crapope (Isara - RKAM).
                             
                19/01/2012 - Alterar nrsencar para dssencar (Guilherme).
                
                07/11/2013 - Adicionado chamada da proc. validar-hist-cartmagope
                             e gravar-hist-cartmagope para validar e gravar 
                             historico de senha do cartao magnetico
                             do operador. (Jorge)
                
                23/02/2016 - Alteraçao na rotina de alteraçao de senha 
                            (Lucas Lunelli - [PROJ290])
							
				30/05/2017 - Ajuste para remover a instrucao nrsencar solicitado no 
							 chamado 654467. (Kelvin)
                

                                                                           */ 
{dbo/bo-erro1.i}

DEF VAR i-cod-erro             AS INTEGER.
DEF VAR c-desc-erro            AS CHAR.
DEF VAR r-registro             AS RECID.


PROCEDURE busca-cartao:
    DEF INPUT  PARAM p-cooper      AS CHAR.
    DEF INPUT  PARAM prw-crapcrm   AS ROWID NO-UNDO.
    DEF OUTPUT PARAM p-nom-titular AS CHAR  NO-UNDO.
    DEF OUTPUT PARAM p-nro-cartao  AS CHAR  NO-UNDO.
    DEF OUTPUT PARAM p-situacao    AS CHAR  NO-UNDO.
    DEF OUTPUT PARAM p-d           AS CHAR  NO-UNDO.

  
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
 
    FIND crapcrm WHERE ROWID(crapcrm) = prw-crapcrm NO-LOCK NO-ERROR.

    IF  AVAIL crapcrm THEN
        DO:
            ASSIGN p-nom-titular = string(crapcrm.nmtitcrd,"x(28)")
                   p-nro-cartao  = STRING(crapcrm.nrcartao,
                                          "9999,9999,9999,9999")
                   p-situacao    = IF crapcrm.cdsitcar = 1 
                                      THEN "SOLICITADO" 
                                   ELSE "ENTREGUE".
 
            IF  crapcrm.cdsitcar = 1   THEN
                DO:
                    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                                       craptab.nmsistem = "CRED"          AND
                                       craptab.tptabela = "AUTOMA"        AND
                                       craptab.cdempres = 0               AND
                                       craptab.cdacesso = "CM" +
                                              STRING(crapcrm.dtemscar,
                                                     "99999999")  AND  
                                       craptab.tpregist = 0 
                                       NO-LOCK NO-ERROR.

        IF AVAILABLE craptab THEN
            ASSIGN p-d = IF TRIM(craptab.dstextab) = "1" THEN "D" ELSE ".".
    END.
END.

END PROCEDURE.

PROCEDURE grava-senha:
DEF INPUT PARAM p-cooper         AS CHAR.
DEF INPUT PARAM p-cod-agencia    AS INTEGER              NO-UNDO.                    
DEF INPUT PARAM p-nro-caixa      AS INTEGER FORMAT "999" NO-UNDO.       
DEF INPUT PARAM p-operador       AS CHAR                 NO-UNDO.
DEF INPUT PARAM p-rwcrapcrm      AS ROWID                NO-UNDO.
DEF INPUT PARAM p-alt-senha      AS LOG                  NO-UNDO.
DEF INPUT PARAM p-senha-atual    AS CHAR                 NO-UNDO.
DEF INPUT PARAM p-senha-nova     AS CHAR                 NO-UNDO.
DEF INPUT PARAM p-senha-conf     AS CHAR                 NO-UNDO.

DEF VAR h-b1wgen0032 AS HANDLE                           NO-UNDO.

DEF VAR aux_dsdpsrwd AS INTE                             NO-UNDO.
DEF VAR aux_ponteiro AS INTE                             NO-UNDO.
DEF VAR aux_nrsequen AS CHAR                             NO-UNDO.
                                                         
   FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
 
   RUN elimina-erro (INPUT p-cooper,
                     INPUT p-cod-agencia,
                     INPUT p-nro-caixa).

   FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                            NO-LOCK NO-ERROR.

   DO WHILE TRUE:
        FIND crapcrm WHERE ROWID(crapcrm) = p-rwcrapcrm 
             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
        IF   NOT AVAILABLE crapcrm THEN
            IF   LOCKED crapcrm   THEN
            DO:
                PAUSE 2 NO-MESSAGE.
                NEXT.
            END.
            ELSE
            DO:
                ASSIGN i-cod-erro  = 546
                       c-desc-erro = " ".           
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                RETURN "NOK".
            END.
        LEAVE.
   END.

   IF   crapcrm.cdsitcar > 2   THEN
   DO:
       ASSIGN i-cod-erro  = 625
              c-desc-erro = " ".           
       RUN cria-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa,
                      INPUT i-cod-erro,
                      INPUT c-desc-erro,
                      INPUT YES).
       RETURN "NOK".
   END.
        
   IF   ENCODE(p-senha-atual) <> crapcrm.dssencar  AND p-alt-senha THEN
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
  
   IF   p-senha-nova <> p-senha-conf   THEN
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
  
   IF   LENGTH(p-senha-nova) < 6   THEN
   DO:
       ASSIGN i-cod-erro  = 623
              c-desc-erro = " ".           
       RUN cria-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa,
                      INPUT i-cod-erro,
                      INPUT c-desc-erro,
                      INPUT YES).
       RETURN "NOK".
   END.
   
   /* se for cartao magnetico de operador */
   IF crapcrm.tptitcar = 9 THEN
   DO:
       IF  NOT VALID-HANDLE(h-b1wgen0032)  THEN
           RUN  sistema/generico/procedures/b1wgen0032.p 
                PERSISTENT SET h-b1wgen0032.
       
       RUN validar-hist-cartmagope IN h-b1wgen0032 (INPUT crapcrm.cdcooper,
                                                    INPUT crapcrm.nrdconta,
                                                    INPUT crapcrm.tpusucar,
                                                    INPUT p-senha-conf,
                                                    INPUT NO, /* nao vai encodada */
                                                   OUTPUT c-desc-erro).
       IF c-desc-erro <> "" THEN
       DO:
           DELETE PROCEDURE h-b1wgen0032.
           ASSIGN i-cod-erro  = 0.           
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
       END.

       RUN gravar-hist-cartmagope IN h-b1wgen0032 (INPUT crapcrm.cdcooper,
                                                   INPUT crapcrm.nrdconta,
                                                   INPUT crapcrm.tpusucar,
                                                   INPUT ENCODE(p-senha-conf),
                                                  OUTPUT c-desc-erro).
       DELETE PROCEDURE h-b1wgen0032.

       IF c-desc-erro <> "" THEN
       DO:
           ASSIGN i-cod-erro  = 0.           
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
       END.
   END.

   ASSIGN  crapcrm.dssencar = ENCODE(p-senha-conf)
           crapcrm.dttransa = crapdat.dtmvtolt
           crapcrm.hrtransa = TIME
           crapcrm.cdoperad = p-operador
           aux_dsdpsrwd     = INTE(p-senha-conf).

   IF aux_dsdpsrwd > 0 THEN
      DO:
          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
          
          RUN STORED-PROCEDURE pc_getPinBlockCripto
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT STRING(crapcrm.nrcartao)
                                              ,INPUT STRING(aux_dsdpsrwd)
                                              ,"").
                                              
          CLOSE STORED-PROC pc_getPinBlockCripto aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
          
          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
      
          ASSIGN aux_nrsequen = pc_getPinBlockCripto.pSenhaCrypto
                                WHEN pc_getPinBlockCripto.pSenhaCrypto <> ?.
                                
          IF  TRIM(aux_nrsequen) <> "" THEN
              ASSIGN crapcrm.dssenpin = TRIM(aux_nrsequen).
      END.
        
   RETURN "OK".
END PROCEDURE.

PROCEDURE grava-cartao.

DEF INPUT PARAM p-cooper         AS CHAR.
DEF INPUT PARAM p-cod-agencia    AS INTEGER              NO-UNDO.                    
DEF INPUT PARAM p-nro-caixa      AS INTEGER FORMAT "999" NO-UNDO.       
DEF INPUT PARAM p-operador       AS CHAR                 NO-UNDO.
DEF INPUT PARAM p-rwcrapcrm      AS ROWID                NO-UNDO.
/* */
DEF INPUT PARAM p-alt-senha      AS LOG                  NO-UNDO.
DEF INPUT PARAM p-senha-atual    AS CHAR                 NO-UNDO.
DEF INPUT PARAM p-senha-nova     AS CHAR                 NO-UNDO.
DEF INPUT PARAM p-senha-conf     AS CHAR                 NO-UNDO.

DEF VAR h-b1wgen0032 AS HANDLE                           NO-UNDO.
DEF VAR aux_dsdpsrwd AS INTE                             NO-UNDO.
DEF VAR aux_ponteiro AS INTE                             NO-UNDO.
DEF VAR aux_nrsequen AS CHAR                             NO-UNDO.

    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.
   
   RUN elimina-erro (INPUT p-cooper,
                     INPUT p-cod-agencia,
                     INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper 
                             NO-LOCK NO-ERROR.

    DO WHILE TRUE:

        FIND crapcrm WHERE rowid(crapcrm) = p-rwcrapcrm
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAILABLE crapcrm THEN
             IF   LOCKED crapcrm   THEN
             DO:
                 PAUSE 2 NO-MESSAGE.
                 NEXT.
             END.
             ELSE
             DO:
                 ASSIGN i-cod-erro  = 546
                        c-desc-erro = " ".           
                 RUN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT p-nro-caixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                 RETURN "NOK".
             END.
        LEAVE.
    END.

    /* Cartao */
    IF  crapcrm.cdsitcar = 2   THEN
    DO:
        ASSIGN i-cod-erro  = 552
               c-desc-erro = " ".           
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.

   /* Senha */
    IF   crapcrm.cdsitcar > 2   THEN
    DO:
        ASSIGN i-cod-erro  = 625
               c-desc-erro = " ".           
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.
    
    IF   ENCODE(p-senha-atual) <> crapcrm.dssencar  AND p-alt-senha THEN
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
    
    IF   p-senha-nova <> p-senha-conf   THEN
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
    
    IF   LENGTH(p-senha-nova) < 6   THEN
    DO:
        ASSIGN i-cod-erro  = 623
               c-desc-erro = " ".           
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.
    
    /* Impressora */
    FIND FIRST crapope NO-LOCK
         WHERE crapope.cdcooper = crapcop.cdcooper
           AND crapope.cdoperad = p-operador NO-ERROR.
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
    
    /* se for cartao magnetico de operador */
    IF crapcrm.tptitcar = 9 THEN
    DO:
        IF  NOT VALID-HANDLE(h-b1wgen0032)  THEN
            RUN  sistema/generico/procedures/b1wgen0032.p 
                 PERSISTENT SET h-b1wgen0032.

        RUN validar-hist-cartmagope IN h-b1wgen0032 (INPUT crapcrm.cdcooper,
                                                     INPUT crapcrm.nrdconta,
                                                     INPUT crapcrm.tpusucar,
                                                     INPUT p-senha-conf,
                                                     INPUT NO, /* nao encodada */
                                                    OUTPUT c-desc-erro).
        IF c-desc-erro <> "" THEN
        DO:
            DELETE PROCEDURE h-b1wgen0032.
            ASSIGN i-cod-erro  = 0.           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

        RUN gravar-hist-cartmagope IN h-b1wgen0032 (INPUT crapcrm.cdcooper,
                                                    INPUT crapcrm.nrdconta,
                                                    INPUT crapcrm.tpusucar,
                                                    INPUT ENCODE(p-senha-conf),
                                                   OUTPUT c-desc-erro).
        DELETE PROCEDURE h-b1wgen0032.

        IF c-desc-erro <> "" THEN
        DO:
            ASSIGN i-cod-erro  = 0.           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
    END.

    /*--- Atualizacao - Impressao do Termo - Entrega ---*/
    /* Cartao */

    ASSIGN crapcrm.dtcancel = ?
           crapcrm.cdsitcar = 2
           crapcrm.dtentcrm = IF crapcrm.dtentcrm = ?
                                 THEN crapdat.dtmvtolt
                                 ELSE crapcrm.dtentcrm.
   /* Senha */
    ASSIGN  crapcrm.dssencar = ENCODE(p-senha-conf)
            crapcrm.dttransa = crapdat.dtmvtolt
            crapcrm.hrtransa = TIME
            crapcrm.cdoperad = p-operador
            aux_dsdpsrwd     = INTE(p-senha-conf).

   IF aux_dsdpsrwd > 0 THEN
      DO:
          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
          
          RUN STORED-PROCEDURE pc_getPinBlockCripto
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT STRING(crapcrm.nrcartao)
                                              ,INPUT STRING(aux_dsdpsrwd)
                                              ,"").
                                              
          CLOSE STORED-PROC pc_getPinBlockCripto aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
          
          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
      
          ASSIGN aux_nrsequen = pc_getPinBlockCripto.pSenhaCrypto
                                WHEN pc_getPinBlockCripto.pSenhaCrypto <> ?.
                                
          IF  TRIM(aux_nrsequen) <> "" THEN
              ASSIGN crapcrm.dssenpin = TRIM(aux_nrsequen).
      END.
       
   ASSIGN r-registro = RECID(crapcrm).

    /*--- Impressao do Termo - Entrega - Cartao  --*/
    RUN dbo/pcrap11.p (INPUT p-cooper,
                       INPUT r-registro,
                       INPUT p-operador,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa).
    RETURN "OK".

END PROCEDURE.

PROCEDURE verifica-senha-atual.

DEF INPUT  PARAM p-cooper     AS CHAR.
DEF INPUT  PARAM p-rwcrapcrm  AS ROWID NO-UNDO.
DEF OUTPUT PARAM p-sen-antiga AS LOG   NO-UNDO.

    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.
 
FIND crapcrm WHERE
     ROWID(crapcrm) = p-rwcrapcrm NO-LOCK NO-ERROR.

ASSIGN p-sen-antiga = NO.
	  
END PROCEDURE.

/* b2crap004.p */        


