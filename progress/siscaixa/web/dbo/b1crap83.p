/*---------------------------------------------------------------------------*/
/*  b1crap83.p - Estorno Pagamento GPS - Guias Previdencia Social            */
/*  Autenticacao  - RC                                                       */
/*---------------------------------------------------------------------------*/
/*
    
    Alteracoes: 02/03/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
    
                27/03/2008 - Tratamento para as GPS-BANCOOB - historico 582
                             (Evandro).
    
                29/08/2008 -  Incluido nos FIND's da crapcgp e da craplgp o
                              campo cddpagto;
                           -  Alterado para ser INPUT o parametro p-codigo na
                              procedure valida-existencia-lancamento e incluido
                              p-codigo na procedure estorna-pagamento (Elton).

                30/01/2009 -  Alterada mensagem da critica da guia que ja foi
                              transmitida e nao pode ser estornada (Elton).

............................................................................*/

{dbo/bo-erro1.i}
                                               
DEFINE VARIABLE i-cod-erro      AS INT         NO-UNDO.
DEFINE VARIABLE c-desc-erro     AS CHAR        NO-UNDO.

DEF VAR i-nro-lote              AS INTE        NO-UNDO.
DEF VAR in99                    AS INTE        NO-UNDO.

DEF VAR h_b2crap00              AS HANDLE      NO-UNDO.
DEF VAR h_b1crap00              AS HANDLE      NO-UNDO.

DEF VAR p-literal               AS CHAR        NO-UNDO.
DEF VAR p-ult-sequencia         AS INTE        NO-UNDO.
DEF VAR p-registro              AS Recid       NO-UNDO.
DEF VAR i-nro-docto             AS INTE        NO-UNDO. 
DEF VAR aux_mmaacomp            AS CHAR        NO-UNDO FORMAT "x(06)".

PROCEDURE valida-existencia-lancamento.
    
    DEF INPUT  PARAM p-cooper                AS CHAR.
    DEF INPUT  PARAM p-cod-agencia           AS INTEGER.  /* Cod. Agencia   */
    DEF INPUT  PARAM p-nro-caixa             AS INTEGER.  /* Numero Caixa   */
    DEF INPUT  PARAM p-identificador         AS DEC.
    DEF INPUT  PARAM p-valortot              AS DEC.
    DEF OUTPUT PARAM p-nrdconta              AS INTE.
    DEF OUTPUT PARAM p-nmprimtl              AS CHAR.
    DEF INPUT  PARAM p-codigo                AS INTE.   
    DEF INPUT  PARAM p-mesref                AS INTE.
    DEF INPUT  PARAM p-anoref                AS INTE.
    DEF OUTPUT PARAM p-valorins              AS DEC.
    DEF OUTPUT PARAM p-valorjur              AS DEC.
    DEF OUTPUT PARAM p-valorout              AS DEC.
    
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.
     
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).           

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
                                              
    ASSIGN i-nro-lote = 24000 + p-nro-caixa.
    
    ASSIGN  aux_mmaacomp = SUBSTR(STRING(p-mesref,"99"),1,2) + 
                           SUBSTR(STRING(p-anoref,"9999"),1,4).     

    FIND FIRST craplgp WHERE
               craplgp.cdcooper = crapcop.cdcooper    AND
               craplgp.dtmvtolt = crapdat.dtmvtolt    AND
               craplgp.cdagenci = p-cod-agencia       AND
               craplgp.cdbccxlt = 11                  AND /* FIXO  */
               craplgp.nrdolote = i-nro-lote          AND
               craplgp.cdidenti = p-identificador     AND             
               craplgp.cddpagto = p-codigo            AND 
               craplgp.mmaacomp = INTE(aux_mmaacomp)  AND         
               craplgp.vlrtotal = p-valortot 
               NO-LOCK NO-ERROR.  

    IF  NOT AVAIL craplgp  THEN  
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
 
    IF   craplgp.flgenvio = YES THEN DO:
         ASSIGN i-cod-erro  = 0   /* Arquivo ja Transmitido */
             c-desc-erro = "GUIA ja transmitida. Estorno nao permitido.".
         RUN cria-erro (INPUT p-cooper,
                        INPUT p-cod-agencia,
                        INPUT p-nro-caixa,
                        INPUT i-cod-erro,
                        INPUT c-desc-erro,
                        INPUT YES).
         RETURN "NOK".
    END.

    
    /*  Tabela com o horario limite para digitacao  */

    FIND craptab WHERE 
         craptab.cdcooper = crapcop.cdcooper  AND
         craptab.nmsistem = "CRED"            AND
         craptab.tptabela = "GENERI"          AND
         craptab.cdempres = 0                 AND
         craptab.cdacesso = "HRGUIASGPS"      AND
         craptab.tpregist = p-cod-agencia     NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL craptab  THEN  
        DO:
           ASSIGN i-cod-erro  = 676           
                  c-desc-erro = " ".
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
        END.
        
    IF   TIME >= INT(SUBSTRING(craptab.dstextab,3,5))  THEN 
         DO:
            ASSIGN i-cod-erro  = 676           
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
         END.
 

    FIND crapcgp WHERE
         crapcgp.cdcooper = crapcop.cdcooper  AND
         crapcgp.cdidenti = p-identificador   AND
         crapcgp.cddpagto = p-codigo          NO-LOCK NO-ERROR.  

    IF  NOT AVAIL crapcgp  THEN
        DO:      
           ASSIGN i-cod-erro  =  855               /* Guia nao Cadastrada */
                  c-desc-erro = " ".                                 
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
        END.

    ASSIGN p-nrdconta = crapcgp.nrdconta 
           p-nmprimtl = crapcgp.nmprimtl.
    
    IF  crapcgp.nrdconta > 0 THEN 
        DO:

           FIND crapass WHERE
                crapass.cdcooper = crapcop.cdcooper  AND
                crapass.nrdconta = crapcgp.nrdconta  NO-LOCK NO-ERROR.

           IF  AVAIL crapass THEN 
               ASSIGN p-nmprimtl = crapass.nmprimtl.
        END.

    ASSIGN p-valorins = craplgp.vlrdinss  
           p-valorout = craplgp.vlrouent
           p-valorjur = craplgp.vlrjuros
           p-valortot = craplgp.vlrtotal
           p-mesref   = INTE(SUBSTR(STRING(craplgp.mmaacomp,"999999"),1,2))
           p-anoref   = INTE(SUBSTR(STRING(craplgp.mmaacomp,"999999"),3,4)).
                  
    RETURN "OK".
END PROCEDURE.
    

PROCEDURE estorna-pagamento.
    
    DEF INPUT  PARAM p-cooper             AS CHAR.
    DEF INPUT  PARAM p-cod-agencia        AS INTEGER.   /* Cod. Agencia     */
    DEF INPUT  PARAM p-nro-caixa          AS INTEGER.   /* Numero Caixa     */
    DEF INPUT  PARAM p-cod-operador       AS CHAR.
    DEF INPUT  PARAM p-identificador      AS DEC.   
    DEF INPUT  PARAM p-codigo             AS INT.  
    DEF INPUT  PARAM p-mesref             AS INTE.
    DEF INPUT  PARAM p-anoref             AS INTE.
    DEF INPUT  PARAM p-valorins           AS DEC.  
    DEF INPUT  PARAM p-valorjur           AS DEC. 
    DEF INPUT  PARAM p-valorout           AS DEC. 
    DEF INPUT  PARAM p-valortot           AS DEC.  
    DEF  OUTPUT PARAM p-literal           AS CHAR.
    DEF  OUTPUT PARAM p-ult-sequencia     AS INTE.
    DEF  OUTPUT PARAM p-docto             AS DEC.
    
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN i-nro-lote = 24000 + p-nro-caixa.
  
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
    
    ASSIGN  aux_mmaacomp = SUBSTR(STRING(p-mesref,"99"),1,2) + 
                           SUBSTR(STRING(p-anoref,"9999"),1,4).     

    ASSIGN in99 = 0.
    DO  WHILE TRUE:
       
        ASSIGN in99 = in99 + 1.
 
        FIND craplot WHERE
             craplot.cdcooper = crapcop.cdcooper  AND
             craplot.dtmvtolt = crapdat.dtmvtolt  AND
             craplot.cdagenci = p-cod-agencia     AND
             craplot.cdbccxlt = 11                AND  /* Fixo */
             craplot.nrdolote = i-nro-lote        
             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
        IF   NOT AVAILABLE craplot   THEN  
             DO:
                  IF   LOCKED craplot     THEN 
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
                                RUN cria-erro (INPUT p-cooper,
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

    ASSIGN in99 = 0.
    DO WHILE TRUE:

        FIND FIRST craplgp WHERE
                   craplgp.cdcooper = crapcop.cdcooper    AND
                   craplgp.dtmvtolt = crapdat.dtmvtolt    AND
                   craplgp.cdagenci = craplot.cdagenci    AND
                   craplgp.cdbccxlt = craplot.cdbccxlt    AND
                   craplgp.nrdolote = craplot.nrdolote    AND
                   craplgp.cdidenti = p-identificador     AND
                   craplgp.cddpagto = p-codigo            AND 
                   craplgp.mmaacomp = INTE(aux_mmaacomp)  AND
                   craplgp.vlrtotal = p-valortot 
                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        ASSIGN in99 = in99 + 1.
        IF    NOT AVAILABLE craplgp THEN 
              DO:
                 IF   LOCKED craplgp   THEN 
                    DO:
                       IF  in99 <  100  THEN 
                         DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                         END.
                       ELSE 
                        DO:
                            ASSIGN i-cod-erro  = 0
                                   c-desc-erro = "Tabela CRAPLGP em uso ".
                            RUN cria-erro (INPUT p-cooper,
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
                
    ASSIGN craplot.vlcompdb = craplot.vlcompdb - craplgp.vlrtotal
           craplot.qtcompln = craplot.qtcompln - 1

           craplot.vlinfodb = craplot.vlinfodb - craplgp.vlrtotal 
           craplot.qtinfoln = craplot.qtinfoln - 1.

   RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.

   RUN grava-autenticacao 
         IN h_b1crap00 (INPUT p-cooper,
                        INPUT p-cod-agencia,
                        INPUT p-nro-caixa,
                        INPUT p-cod-operador,
                        INPUT craplgp.vlrtotal,
                        INPUT craplgp.nrseqdig,
                        INPUT NO, /* YES (PG), NO (REC) */
                        INPUT "1",  /* On-line            */         
                        INPUT YES,   /* Estorno        */
                        /* Historico BANCOOB e BB */
                        INPUT IF crapcop.cdcrdarr <> 0 THEN 582 ELSE 458,
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
   
   IF  craplot.vlcompdb = 0 and
       craplot.vlinfodb = 0 and
       craplot.vlcompcr = 0 and
       craplot.vlinfocr = 0 THEN
       DELETE craplot.
    ELSE
       RELEASE craplot.
              
    DELETE craplgp.
                 
    RETURN "OK".
                    
END PROCEDURE.
