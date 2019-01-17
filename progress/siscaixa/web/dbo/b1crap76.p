
/*----------------------------------------------------------------------*/
/*  b1crap76.p - Outros  (Estorno)                                      */
/*----------------------------------------------------------------------*/

/* Alteracoes: 16/11/2005 - Alteracao de crapchq e crapcht p/ crapfdc
                            (SQLWorks - Eder).
               21/11/2005 - Adequacao ao padrao, analise de performance e dos
                            itens convertidos (SQLWorks - Andre)
               24/11/2005 - Nenhum historico de cheque mais entra (Magui).     

               02/03/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               09/04/2007 - Controlar horarios da conta salario somente para o
                            historico 561 (Evandro).

               22/12/2008 - Ajustes para unificacao dos bancos de dados
                            (Evandro).
                            
               23/12/2011 - Tratar historico 1030 (Gabriel).             
                            
               16/03/2018 - Substituida verificacao "cdtipcta = 6,7" pela
                            modalidade do tipo de conta igual a 3. PRJ366 (Lombardi).          
                            
               19/06/2018 - Alterado para considerar o campo crapdat.dtmvtocd como 
                            data de referencia - Everton Deserto(AMCOM).

               15/10/2018 - Troca DELETE CRAPLCM pela chamada da rotina estorna_lancamento_conta 
                            de dentro da b1wgen0200 
                            (Renato AMcom)
               
               16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
                     Heitor (Mouts)
*/
                            
{dbo/bo-erro1.i}
{ sistema/generico/includes/b1wgen0200tt.i }

DEFINE VARIABLE i-cod-erro   AS INTEGER    NO-UNDO.
DEFINE VARIABLE c-desc-erro  AS CHARACTER  NO-UNDO.

DEF VAR i-nro-lote           AS INTE           NO-UNDO.
DEF VAR h_b2crap00           AS HANDLE         NO-UNDO.
DEF VAR i_conta              AS DEC            NO-UNDO.

DEF VAR h-b1wgen0200         AS HANDLE         NO-UNDO.

DEF VAR aux_cdcritic         AS INTE           NO-UNDO.
DEF VAR aux_dscritic         AS CHAR           NO-UNDO.

DEF VAR i_nro-docto          AS INTE           NO-UNDO.

DEF VAR in99                 AS INTE           NO-UNDO.

PROCEDURE valida-outros:
    
    DEF INPUT  PARAM p-cooper          AS CHAR NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia     AS INTE NO-UNDO.  
    DEF INPUT  PARAM p-nro-caixa       AS INTE NO-UNDO.
    DEF INPUT  PARAM p-nro-conta       AS INTE NO-UNDO.
    DEF INPUT  PARAM p-nro-docto       AS INTE NO-UNDO.
    DEF OUTPUT PARAM p-cdhistor        AS INTE NO-UNDO.
    DEF OUTPUT PARAM p-nome-titular    AS CHAR NO-UNDO.
    DEF OUTPUT PARAM p-poupanca        AS LOG  NO-UNDO.
    DEF OUTPUT PARAM p-valor           AS DEC  NO-UNDO.
    DEF OUTPUT PARAM p-dtliblan        AS DATE NO-UNDO.
      
    DEF VAR aux_dshistor               AS CHAR NO-UNDO.         
	DEF VAR aux_cdmodali               AS INTE NO-UNDO.
    DEF VAR aux_des_erro               AS CHAR NO-UNDO.
    DEF VAR aux_dscritic               AS CHAR NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    ASSIGN p-nro-conta = INT(REPLACE(STRING(p-nro-conta),".",""))
           p-poupanca = NO
           p-dtliblan = ?.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper 
                             NO-LOCK NO-ERROR.
         
    IF   p-nro-conta = 0   THEN  
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Informe Conta ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

     RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.
     ASSIGN i_conta = p-nro-conta.
     RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT-OUTPUT i_conta).
     DELETE PROCEDURE h_b2crap00.

     IF  RETURN-VALUE = "NOK" THEN
         RETURN "NOK".
     
    IF   p-nro-docto = 0   THEN  DO:
         ASSIGN i-cod-erro  = 22
                c-desc-erro = " ".           
         RUN cria-erro (INPUT p-cooper,
                        INPUT p-cod-agencia,
                        INPUT p-nro-caixa,
                        INPUT i-cod-erro,
                        INPUT c-desc-erro,
                        INPUT YES).
         RETURN "NOK".
    END.


    FIND crapccs NO-LOCK WHERE
         crapccs.cdcooper = crapcop.cdcooper AND
         crapccs.nrdconta = p-nro-conta NO-ERROR.
    IF   NOT  AVAIL crapccs THEN
         DO:

            FIND  crapass WHERE
                  crapass.cdcooper = crapcop.cdcooper  AND
                  crapass.nrdconta = p-nro-conta       NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapass THEN     
                DO:
                    ASSIGN i-cod-erro  = 9
                           c-desc-erro = " ".           
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
 

            ASSIGN i-nro-lote = 11000 + p-nro-caixa.

            FIND FIRST craplot WHERE
                       craplot.cdcooper = crapcop.cdcooper  AND
                       craplot.dtmvtolt = crapdat.dtmvtocd  AND /* 19/06/2018 - Alterado para considerar o campo dtmvtocd - Everton Deserto(AMCOM).*/
                       craplot.cdagenci = p-cod-agencia     AND
                       craplot.cdbccxlt = 11                AND  /* Fixo */
                       craplot.nrdolote = i-nro-lote        NO-LOCK NO-ERROR .

            IF   NOT AVAIL   craplot   THEN  DO:
                 ASSIGN i-cod-erro  = 60
                        c-desc-erro = " ".           
                 RUN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT p-nro-caixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                 RETURN "NOK".
            END.

            
            FIND FIRST craplcm WHERE
                       craplcm.cdcooper = crapcop.cdcooper   AND
                       craplcm.dtmvtolt = crapdat.dtmvtocd   AND /* 19/06/2018 - Alterado para considerar o campo dtmvtocd - Everton Deserto(AMCOM).*/
                       craplcm.cdagenci = p-cod-agencia      AND
                       craplcm.cdbccxlt = 11                 AND /* Fixo */
                       craplcm.nrdolote = i-nro-lote         AND
                       craplcm.nrdctabb = p-nro-conta        AND
                       craplcm.nrdocmto = p-nro-docto  USE-INDEX craplcm1
                       NO-LOCK NO-ERROR.
 
            IF   NOT AVAIL  craplcm   THEN
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

            ASSIGN p-cdhistor     =  craplcm.cdhistor
                   p-valor        =  craplcm.vllanmto  
                   p-nome-titular =  crapass.nmprimtl.
          END.
    ELSE
         DO:

            ASSIGN i-nro-lote = 26000 + p-nro-caixa.
            
            FIND FIRST craplot WHERE
                       craplot.cdcooper = crapcop.cdcooper  AND
                       craplot.dtmvtolt = crapdat.dtmvtocd  AND /* 19/06/2018 - Alterado para considerar o campo dtmvtocd - Everton Deserto(AMCOM).*/
                       craplot.cdagenci = p-cod-agencia     AND
                       craplot.cdbccxlt = 11                AND  /* Fixo */
                       craplot.nrdolote = i-nro-lote        NO-LOCK NO-ERROR .

            IF   NOT AVAIL   craplot   THEN  DO:
                 ASSIGN i-cod-erro  = 60
                        c-desc-erro = " ".           
                 RUN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT p-nro-caixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                 RETURN "NOK".
             END.

            
            FIND FIRST craplcs WHERE
                       craplcs.cdcooper = crapcop.cdcooper   AND
                       craplcs.dtmvtolt = crapdat.dtmvtocd   AND  /* 19/06/2018 - Alterado para considerar o campo dtmvtocd - Everton Deserto(AMCOM).*/
                       craplcs.nrdconta = p-nro-conta        AND
                       craplcs.nrdocmto = p-nro-docto  USE-INDEX craplcs1
                       NO-LOCK NO-ERROR.
            IF   NOT AVAIL  craplcs   THEN
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
            
            IF  craplcs.flgenvio = YES THEN
                DO:
                   ASSIGN i-cod-erro  = 0 
                          c-desc-erro = "Ted ja enviado ao BB".
                   RUN cria-erro (INPUT p-cooper,
                                  INPUT p-cod-agencia,
                                  INPUT p-nro-caixa,
                                  INPUT i-cod-erro,
                                  INPUT c-desc-erro,
                                  INPUT YES).
                   RETURN "NOK".  
                END.
            
            ASSIGN p-cdhistor     =  craplcs.cdhistor               
                   p-valor        =  craplcs.vllanmto 
                   p-nome-titular =  crapccs.nmfuncio.
 

            /* Se for histor 561 - CONTA SALARIO, verifica horario dos TEDS */
            IF   craplcs.cdhistor = 561   THEN
                 DO:
                     /* Verif. horario de corte  */
                     FIND craptab WHERE 
                          craptab.cdcooper = crapcop.cdcooper AND
                          craptab.nmsistem = "CRED"           AND
                          craptab.tptabela = "GENERI"         AND
                          craptab.cdempres = 0                AND
                          craptab.cdacesso = "HRTRCTASAL"     AND
                          craptab.tpregist = 0                NO-LOCK NO-ERROR.

                     IF  NOT AVAIL craptab THEN 
                         DO:
                             ASSIGN i-cod-erro  = 676
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
                            IF  INT(SUBSTR(craptab.dstextab,1,5)) <= TIME  THEN
                                DO:
                                   ASSIGN i-cod-erro  = 676
                                          c-desc-erro = "". 
                                   RUN cria-erro (INPUT p-cooper,
                                                  INPUT p-cod-agencia,
                                                  INPUT p-nro-caixa,
                                                  INPUT i-cod-erro,
                                                  INPUT c-desc-erro,
                                                  INPUT YES).
                                   RETURN "NOK".
                                END.
                         END.
                 END.
         END.
 
     ASSIGN aux_dshistor = "1,386,3,4,403,404,21,26,22,372,1030".

     IF   CAN-DO(aux_dshistor,STRING(p-cdhistor))   THEN  
          DO:  
             ASSIGN i-cod-erro  = 93 /* Historico Errado */
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
          END.
   
     FIND FIRST craphis WHERE craphis.cdcooper = crapcop.cdcooper   AND
                              craphis.cdhistor = p-cdhistor
                              NO-LOCK NO-ERROR.

     IF  NOT AVAIL craphis  THEN DO:
         ASSIGN i-cod-erro  = 93
                c-desc-erro = " ".           
         RUN cria-erro (INPUT p-cooper,
                        INPUT p-cod-agencia,
                        INPUT p-nro-caixa,
                        INPUT i-cod-erro,
                        INPUT c-desc-erro,
                        INPUT YES).
         RETURN "NOK".
     END.

     IF  craphis.tplotmov <> 1   AND
         craphis.tplotmov <> 32  THEN DO:    /* Historico 561 */
         ASSIGN i-cod-erro  = 94
                c-desc-erro = " ".           
         RUN cria-erro (INPUT p-cooper,
                        INPUT p-cod-agencia,
                        INPUT p-nro-caixa,
                        INPUT i-cod-erro,
                        INPUT c-desc-erro,
                        INPUT YES).
         RETURN "NOK".
     END.

     IF  craphis.tpctbcxa   <> 2 AND
         craphis.tpctbcxa   <> 3 THEN DO:
         ASSIGN i-cod-erro  = 689
                c-desc-erro = " ".           
         RUN cria-erro (INPUT p-cooper,
                        INPUT p-cod-agencia,
                        INPUT p-nro-caixa,
                        INPUT i-cod-erro,
                        INPUT c-desc-erro,
                        INPUT YES).
         RETURN "NOK".
     END.
   
     IF   craphis.indebcre  = "C"   AND
          craphis.cdhistor <> 561   THEN DO:
          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

          RUN STORED-PROCEDURE pc_busca_modalidade_tipo
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                               INPUT crapass.cdtipcta, /* Tipo de conta */
                                              OUTPUT 0,                /* Modalidade */
                                              OUTPUT "",               /* Flag Erro */
                                              OUTPUT "").              /* Descriçao da crítica */

          CLOSE STORED-PROC pc_busca_modalidade_tipo
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

          ASSIGN aux_cdmodali = 0
                 aux_des_erro = ""
                 aux_dscritic = ""
                 aux_cdmodali = pc_busca_modalidade_tipo.pr_cdmodalidade_tipo 
                                WHEN pc_busca_modalidade_tipo.pr_cdmodalidade_tipo <> ?
                 aux_des_erro = pc_busca_modalidade_tipo.pr_des_erro 
                                WHEN pc_busca_modalidade_tipo.pr_des_erro <> ?
                 aux_dscritic = pc_busca_modalidade_tipo.pr_dscritic
                                WHEN pc_busca_modalidade_tipo.pr_dscritic <> ?.
          
          IF aux_des_erro = "NOK"  THEN
              DO:
                  ASSIGN i-cod-erro  = 0
                         c-desc-erro = aux_dscritic.
                  RUN cria-erro (INPUT p-cooper,
                                 INPUT p-cod-agencia,
                                 INPUT p-nro-caixa,
                                 INPUT i-cod-erro,
                                 INPUT c-desc-erro,
                                 INPUT YES).
                  RETURN "NOK".
              END.
          
          IF   aux_cdmodali = 3 THEN  DO: /* Conta tipo Poupan‡a */
               ASSIGN p-poupanca = YES.
          END.
     END.
    
    IF   CAN-DO("3,4,5",STRING(craphis.inhistor))   THEN DO:
     
         FIND FIRST crapdpb WHERE
                    crapdpb.cdcooper = crapcop.cdcooper  AND 
                    crapdpb.dtmvtolt = crapdat.dtmvtocd  AND /* 19/06/2018 - Alterado para considerar o campo dtmvtocd - Everton Deserto(AMCOM).*/
                    crapdpb.cdagenci = p-cod-agencia     AND
                    crapdpb.cdbccxlt = 11                AND  /* Fixo */
                    crapdpb.nrdolote = i-nro-lote        AND
                    crapdpb.nrdconta = craplcm.nrdconta  AND
                    crapdpb.nrdocmto = p-nro-docto 
                    USE-INDEX crapdpb1 NO-LOCK NO-ERROR.

         IF  NOT AVAIL crapdpb THEN DO: 
              ASSIGN i-cod-erro  = 82
                     c-desc-erro = " ".           
              RUN cria-erro (INPUT p-cooper,
                             INPUT p-cod-agencia,
                             INPUT p-nro-caixa,
                             INPUT i-cod-erro,
                             INPUT c-desc-erro,
                             INPUT YES).
              RETURN "NOK".
          END.
          IF  crapdpb.inlibera = 2   THEN DO:
              ASSIGN i-cod-erro  = 220
                     c-desc-erro = " ".           
              RUN cria-erro (INPUT p-cooper,
                             INPUT p-cod-agencia,
                             INPUT p-nro-caixa,
                             INPUT i-cod-erro,
                             INPUT c-desc-erro,
                             INPUT YES).
              RETURN "NOK".
          END.
           ASSIGN p-dtliblan = crapdpb.dtliblan.
    END.

    IF   CAN-DO("13,14,15",STRING(craphis.inhistor))   THEN DO:
        
         FIND FIRST crapdpb WHERE
                    crapdpb.cdcooper = crapcop.cdcooper  AND
                    crapdpb.nrdconta = craplcm.nrdconta  AND
                    crapdpb.nrdocmto = p-nro-docto       AND
                    crapdpb.dtliblan > crapdat.dtmvtocd   /* 19/06/2018 - Alterado para considerar o campo dtmvtocd - Everton Deserto(AMCOM).*/
                    USE-INDEX crapdpb2 NO-LOCK NO-ERROR.

         IF  NOT AVAIL crapdpb THEN DO: 
              ASSIGN i-cod-erro  = 82
                     c-desc-erro = " ".           
              RUN cria-erro (INPUT p-cooper,
                             INPUT p-cod-agencia,
                             INPUT p-nro-caixa,
                             INPUT i-cod-erro,
                             INPUT c-desc-erro,
                             INPUT YES).
              RETURN "NOK".
          END.
          IF  crapdpb.inlibera = 1   THEN DO:
              ASSIGN i-cod-erro  = 220
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
    
    IF  craphis.inavisar = 1   THEN DO:
            
        FIND FIRST crapavs WHERE
                   crapavs.cdcooper = crapcop.cdcooper   AND
                   crapavs.dtmvtolt = craplcm.dtmvtolt   AND
                   crapavs.cdempres = 0                  AND
                   crapavs.cdagenci = crapass.cdagenci   AND
                   crapavs.cdsecext = crapass.cdsecext   AND
                   crapavs.nrdconta = craplcm.nrdconta   AND
                   crapavs.dtdebito = craplcm.dtmvtolt   AND
                   crapavs.cdhistor = craplcm.cdhistor   AND
                   crapavs.nrdocmto = craplcm.nrdocmto   NO-LOCK NO-ERROR.
       
        IF  NOT AVAIL crapavs  THEN DO:
            IF  (craplcm.nrdolote > 6499    AND
                 craplcm.nrdolote < 7000)   OR
                 CAN-DO("147,165,166,167,192,193,194,195" + 
                        ",254",STRING(craplcm.cdhistor))  THEN DO:
                 .
            END.
            ELSE DO:
                 ASSIGN i-cod-erro = 448.
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
    END.

    RETURN "OK".

END PROCEDURE.



PROCEDURE estorna-outros.
    
    DEF INPUT  PARAM p-cooper          AS CHAR NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia     AS INT  NO-UNDO. 
    DEF INPUT  PARAM p-nro-caixa       AS INT  NO-UNDO.     
    DEF INPUT  PARAM p-cod-operador    AS CHAR NO-UNDO.
    DEF INPUT  PARAM p-nro-conta       AS INT  NO-UNDO.  
    DEF INPUT  PARAM p-cdhistor        AS INT  NO-UNDO.    
    DEF INPUT  PARAM p-nro-docto       AS INT  NO-UNDO.
    DEF INPUT  PARAM p-valor           AS DEC  NO-UNDO.
    DEF OUTPUT PARAM p-pg              AS LOG  NO-UNDO.
    DEF OUTPUT PARAM p-autestorno      AS INTE NO-UNDO.
  
    FIND crapcop WHERE
         crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
 
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN p-nro-conta = INT(REPLACE(STRING(p-nro-conta),".","")).

    IF  p-cdhistor <> 561 THEN
        ASSIGN i-nro-lote = 11000 + p-nro-caixa.
    ELSE
        ASSIGN i-nro-lote = 26000 + p-nro-caixa.
 
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper 
                             NO-LOCK NO-ERROR.

    FIND FIRST craphis WHERE craphis.cdcooper = crapcop.cdcooper   AND
                             craphis.cdhistor = p-cdhistor
                             NO-LOCK NO-ERROR.

    IF  NOT AVAIL craphis  THEN DO:
        ASSIGN i-cod-erro  = 93
               c-desc-erro = " ".           
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.


    /* Se for histórico 561 - CONTA SALARIO, verifica horario dos TEDS */
    IF   craphis.cdhistor = 561   THEN
         DO:
             /* Verif. horario de corte  */
             FIND craptab WHERE 
                  craptab.cdcooper = crapcop.cdcooper AND
                  craptab.nmsistem = "CRED"           AND
                  craptab.tptabela = "GENERI"         AND
                  craptab.cdempres = 0                AND
                  craptab.cdacesso = "HRTRCTASAL"     AND
                  craptab.tpregist = 0                NO-LOCK NO-ERROR.

             IF  NOT AVAIL craptab THEN 
                 DO:
                     ASSIGN i-cod-erro  = 676
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
                    IF  INT(SUBSTR(craptab.dstextab,1,5)) <= TIME   THEN
                        DO:
                           ASSIGN i-cod-erro  = 676
                                  c-desc-erro = "". 
                           RUN cria-erro (INPUT p-cooper,
                                          INPUT p-cod-agencia,
                                          INPUT p-nro-caixa,
                                          INPUT i-cod-erro,
                                          INPUT c-desc-erro,
                                          INPUT YES).
                           RETURN "NOK".
                        END.
                 END.
         END.
    
 
    ASSIGN  in99 = 0.
    DO  WHILE TRUE:
       
        FIND FIRST craplot WHERE
                   craplot.cdcooper = crapcop.cdcooper  AND
                   craplot.dtmvtolt = crapdat.dtmvtocd  AND /* 19/06/2018 - Alterado para considerar o campo dtmvtocd - Everton Deserto(AMCOM).*/
                   craplot.cdagenci = p-cod-agencia     AND
                   craplot.cdbccxlt = 11                AND  /* Fixo */
                   craplot.nrdolote = i-nro-lote 
                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
          
        ASSIGN in99 = in99 + 1.

        IF   NOT AVAIL   craplot   THEN DO:
             IF   LOCKED craplot   THEN DO:
                  IF  in99 <  100  THEN DO:
                      PAUSE 1 NO-MESSAGE.
                      NEXT.
                  END.
                  ELSE DO:
                      ASSIGN i-cod-erro  = 0
                             c-desc-erro = "Tabela CRAPLOT em uso ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                    INPUT YES).
                      RETURN "NOK".
                  END.
             END.

             ELSE DO:
                  ASSIGN i-cod-erro  = 60
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
        LEAVE.
    END.  /*  DO WHILE */

    IF  p-cdhistor <> 561 THEN      /* Contas Cooperados */
        DO:
           ASSIGN in99 = 0.
           DO  WHILE TRUE:
   
               FIND FIRST
                   craplcm WHERE
                   craplcm.cdcooper = crapcop.cdcooper  AND
                   craplcm.dtmvtolt = crapdat.dtmvtocd  AND  /* 19/06/2018 - Alterado para considerar o campo dtmvtocd - Everton Deserto(AMCOM).*/
                   craplcm.cdagenci = p-cod-agencia     AND
                   craplcm.cdbccxlt = 11                AND /* Fixo */
                   craplcm.nrdolote = i-nro-lote        AND
                   craplcm.nrdctabb = p-nro-conta       AND
                   craplcm.nrdocmto = p-nro-docto  USE-INDEX craplcm1
                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               ASSIGN in99 = in99 + 1.
               IF   NOT AVAILABLE craplcm THEN DO:

                    IF   LOCKED craplcm     THEN DO:
                         IF  in99 <  100  THEN DO:
                             PAUSE 1 NO-MESSAGE.
                             NEXT.
                         END.
                    ELSE DO:
                         ASSIGN i-cod-erro  = 0
                                c-desc-erro = "Tabela CRAPLCM em uso ".           
                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT p-nro-caixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).
                         RETURN "NOK".
                    END.
               END.
             
               ELSE  DO:
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
           LEAVE.
       END.  /*  DO WHILE */
    END.
    ELSE DO:

           ASSIGN in99 = 0.
           DO  WHILE TRUE:
   
               FIND FIRST
                   craplcs WHERE
                   craplcs.cdcooper = crapcop.cdcooper  AND
                   craplcs.dtmvtolt = crapdat.dtmvtocd  AND /* 19/06/2018 - Alterado para considerar o campo dtmvtocd - Everton Deserto(AMCOM).*/
                   craplcs.nrdconta = p-nro-conta       AND
                   craplcs.nrdocmto = p-nro-docto  USE-INDEX craplcs1
                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               ASSIGN in99 = in99 + 1.
               IF   NOT AVAILABLE craplcs THEN DO:

                    IF   LOCKED craplcs     THEN DO:
                         IF  in99 <  100  THEN DO:
                             PAUSE 1 NO-MESSAGE.
                             NEXT.
                         END.
                    ELSE DO:
                         ASSIGN i-cod-erro  = 0
                                c-desc-erro = "Tabela CRAPLCS em uso ".  
                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT p-nro-caixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).
                         RETURN "NOK".
                    END.
               END.
             
               ELSE  DO:
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
           LEAVE.
       END.  /*  DO WHILE */
             
        
    END.                       

    /*-----------*/        
    IF  craphis.inavisar = 1   THEN DO:
       
        FIND FIRST crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                                 crapass.nrdconta = craplcm.nrdconta
                                 NO-LOCK NO-ERROR.
        
        IF  NOT AVAIL crapass  THEN  DO:
            ASSIGN i-cod-erro  = 9
                   c-desc-erro = " ".           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

        ASSIGN in99 = 0.
        DO  WHILE TRUE:
         
            FIND FIRST crapavs WHERE
                       crapavs.cdcooper = crapcop.cdcooper   AND
                       crapavs.dtmvtolt = craplcm.dtmvtolt   AND
                       crapavs.cdempres = 0                  AND
                       crapavs.cdagenci = crapass.cdagenci   AND
                       crapavs.cdsecext = crapass.cdsecext   AND
                       crapavs.nrdconta = craplcm.nrdconta   AND
                       crapavs.dtdebito = craplcm.dtmvtolt   AND
                       crapavs.cdhistor = craplcm.cdhistor   AND
                       crapavs.nrdocmto = craplcm.nrdocmto   
                       EXCLUSIVE-LOCK NO-ERROR.
             
            IF  NOT AVAILABLE crapavs THEN DO:

                IF  LOCKED crapavs     THEN DO:
                    IF  in99 <  100  THEN DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                    ELSE DO:
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "Tabela CRAPAVS em uso ".           
                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                    END.
                END.
                ELSE DO:
                    IF  (craplcm.nrdolote > 6499    AND
                         craplcm.nrdolote < 7000)   OR
                         CAN-DO("147,165,166,167,192,193,194,195" +
                          ",254",STRING(craplcm.cdhistor))  THEN DO:
                          .
                    END.
                    ELSE DO:
                         ASSIGN i-cod-erro = 448.
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
            END.
            ELSE 
                 DELETE crapavs.
            
            LEAVE.
       END. /* do while */
    END.
   /*--------------------*/

    IF   CAN-DO("3,4,5",STRING(craphis.inhistor))   THEN DO:
         ASSIGN in99 = 0.
         DO  WHILE TRUE:

             FIND FIRST crapdpb WHERE
                        crapdpb.cdcooper = crapcop.cdcooper  AND
                        crapdpb.dtmvtolt = crapdat.dtmvtocd  AND /* 19/06/2018 - Alterado para considerar o campo dtmvtocd - Everton Deserto(AMCOM).*/
                        crapdpb.cdagenci = p-cod-agencia     AND
                        crapdpb.cdbccxlt = 11                AND  /* Fixo */
                        crapdpb.nrdolote = i-nro-lote        AND
                        crapdpb.nrdconta = craplcm.nrdconta  AND
                        crapdpb.nrdocmto = p-nro-docto 
                        USE-INDEX crapdpb1 
                        EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

             ASSIGN in99 = in99 + 1.
             IF   NOT AVAILABLE crapdpb THEN DO:
                  IF   LOCKED crapdpb   THEN DO:
                       IF  in99 <  100  THEN DO:
                           PAUSE 1 NO-MESSAGE.
                           NEXT.
                       END.
                       ELSE DO:
                            ASSIGN i-cod-erro  = 0
                                   c-desc-erro = "Tabela CRAPDPB em uso ".           
                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).
                            RETURN "NOK".
                        END.
                  END.

                  ELSE  DO:
                       ASSIGN i-cod-erro  = 82
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
             LEAVE.
         END.  
         DELETE crapdpb.
    END.

    IF   CAN-DO("13,14,15",STRING(craphis.inhistor))   THEN DO:

         ASSIGN in99 = 0.
         DO  WHILE TRUE:
             ASSIGN in99 = in99 + 1.
             FIND FIRST crapdpb WHERE
                        crapdpb.cdcooper = crapcop.cdcooper  AND
                        crapdpb.nrdconta = craplcm.nrdconta  AND
                        crapdpb.nrdocmto = p-nro-docto       AND
                        crapdpb.dtliblan > crapdat.dtmvtocd     /* 19/06/2018 - Alterado para considerar o campo dtmvtocd - Everton Deserto(AMCOM).*/
                        USE-INDEX crapdpb1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                        

             IF   NOT AVAILABLE crapdpb THEN DO:
                  IF   LOCKED crapdpb   THEN DO:
                       IF  in99 <  100  THEN DO:
                           PAUSE 1 NO-MESSAGE.
                           NEXT.
                       END.
                       ELSE DO:
                           ASSIGN i-cod-erro  = 0
                                  c-desc-erro = "Tabela CRAPDPB em uso ".          
                           RUN cria-erro (INPUT p-cooper,
                                          INPUT p-cod-agencia,
                                          INPUT p-nro-caixa,
                                          INPUT i-cod-erro,
                                          INPUT c-desc-erro,
                                          INPUT YES).
                           RETURN "NOK".
                       END.
                      
                  END.
                  ELSE  DO:
                       ASSIGN i-cod-erro  = 82
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
             LEAVE.
         END.  
         ASSIGN crapdpb.inlibera = 1.
         RELEASE crapdpb.
   END.
   
   IF  p-cdhistor <> 561 THEN
       DO:
         ASSIGN p-autestorno = craplcm.nrautdoc.
         IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
            RUN sistema/generico/procedures/b1wgen0200.p PERSISTENT SET h-b1wgen0200.
                  
         RUN estorna_lancamento_conta IN h-b1wgen0200 
           (INPUT craplcm.cdcooper               /* par_cdcooper */
           ,INPUT craplcm.dtmvtolt               /* par_dtmvtolt */
           ,INPUT craplcm.cdagenci               /* par_cdagenci*/
           ,INPUT craplcm.cdbccxlt               /* par_cdbccxlt */
           ,INPUT craplcm.nrdolote               /* par_nrdolote */
           ,INPUT craplcm.nrdctabb               /* par_nrdctabb */
           ,INPUT craplcm.nrdocmto               /* par_nrdocmto */
           ,INPUT craplcm.cdhistor               /* par_cdhistor */
           ,INPUT craplcm.nrctachq               /* PAR_nrctachq */
           ,INPUT craplcm.nrdconta               /* PAR_nrdconta */
           ,INPUT craplcm.cdpesqbb               /* PAR_cdpesqbb */
           ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
           ,OUTPUT aux_dscritic).                /* Descricao da critica                          */
                
         IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
            DO: 
                /* Tratamento de erros conforme anteriores */
                ASSIGN i-cod-erro  = aux_cdcritic
                       c-desc-erro = aux_dscritic.
                      
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                RETURN "NOK".
            END.   
                
         IF  VALID-HANDLE(h-b1wgen0200) THEN
           DELETE PROCEDURE h-b1wgen0200.
       END.
   ELSE
       DO:
          ASSIGN p-autestorno = craplcs.nrautdoc.
          DELETE craplcs.
       END.
   
   IF  craphis.indebcre = "D" THEN 
       ASSIGN craplot.vlcompdb  = craplot.vlcompdb - p-valor
              craplot.vlinfodb  = craplot.vlinfodb - p-valor
              p-pg              = YES.
   ELSE

       ASSIGN craplot.vlcompcr  = craplot.vlcompcr - p-valor
              craplot.vlinfocr  = craplot.vlinfocr - p-valor
              p-pg              = NO.

    ASSIGN craplot.qtcompln  = craplot.qtcompln - 1
           craplot.qtinfoln  = craplot.qtinfoln - 1.

   IF  craplot.vlcompdb = 0 AND
       craplot.vlinfodb = 0 AND
       craplot.vlcompcr = 0 AND
       craplot.vlinfocr = 0 THEN
       DELETE craplot.
   ELSE
      RELEASE craplot.
      
   RETURN "OK".
END PROCEDURE.

/* b1crap76.p */

