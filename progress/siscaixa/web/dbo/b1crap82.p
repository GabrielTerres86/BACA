/*----------------------------------------------------------------------------*/
/*  b1crap82.p - Pagamento GPS - Guias Previdencia Social                     */
/*  Autenticacao  - RC                                                        */
/*----------------------------------------------------------------------------*/
/*

    Alteracoes: 02/03/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
                
                26/12/2007 - Alterado para passar como paramentros os campos
                             Conta, Nome, Codigo e CPF/CNPJ na BO
                             valida-identificador (Elton).

                02/06/2008 - Incluida consistencias referentes as guias de GPS
                             (Elton).

                07/07/2008 - Alterada consistencias dos codigos relacionadas a
                             obrigatoriedade de preenchimento do campo
                             "ATM/Multa e Juros" (Elton).
                
                14/07/2008 - Comentada as criticas dos campos "Conta", "Nome" e
                             "CPF/CNPJ" (Elton).
                
                18/07/2008 - Alterada critica no campo "Valor INSS" para que 
                             em determinadas guias soh permita valores maiores
                             do que R$ 29,00 (Elton).
               
                25/08/2008 - Incluido novos parametros nas procedures
                             valida-valor-entidades e valida-atm-juros; 
                           - Incluido cddpagto nos find's da crapcgp e
                             craplgp (Elton).
                             
                16/12/2008 - Alterado procedure valida-atm-juros, conforme 
                             emenda 23.0 da GPS (Elton).             

                11/03/2009 - Ajustes para unificacao dos bancos de dados
                             (Evandro).
                             
                18/05/2011 - Consistir se a guia gps esta em debito automatico
                             (Guilherme).                             
                            
                17/10/2011 - Incluir novos codigos (Gabriel).    
                
                02/04/2012 - Incluido o tratamento para os codigos 1902, 1910
                             na procedure valida-competencia (Adriano).
                             
                01/06/2012 - Alterado regras de alguns codigos das Guias GPS.
                             (Fabricio)
                13/03/2013 - Alterado para atender a regra que ano/mes da
                             competencia + 1 mes, tem que ser maior ou igual ao
                             ano/mes de pagamento. (Rosangela)            
                             
                17/05/2013 - Incluido novo codigo (4367) de pagamento de gps
                             na procedure valida-competencia (Adriano).
             
                19/11/2014 - #219595 Criacao do procedimento msg-inicial para
                             avisar do bloqueio do pagamento a partir do dia 
                             28/11/2014 na CONCREDI devido a incorporação da 
                             cooperativa (Carlos)
                            
.............................................................................*/

{dbo/bo-erro1.i}
                                     
DEFINE VARIABLE i-cod-erro    AS INT                 NO-UNDO.
DEFINE VARIABLE c-desc-erro   AS CHAR                NO-UNDO.

DEF VAR i-nro-lote            AS INTE                NO-UNDO.

DEF VAR h_b2crap00            AS HANDLE              NO-UNDO.
DEF VAR h_b1crap00            AS HANDLE              NO-UNDO.

DEF VAR p-literal             AS CHAR                NO-UNDO.
DEF VAR p-ult-sequencia       AS INTE                NO-UNDO.
DEF VAR p-registro            AS Recid               NO-UNDO.
DEF VAR aux_mmaacomp          AS CHAR                NO-UNDO FORMAT "x(06)".
DEF VAR aux_dataref           AS DATE                NO-UNDO. 


PROCEDURE valida-identificador.
    
    DEF INPUT  PARAM p-cooper                AS CHAR.
    DEF INPUT  PARAM p-cod-agencia           AS INTEGER.  /* Cod. Agencia   */
    DEF INPUT  PARAM p-nro-caixa             AS INTEGER.  /* Numero Caixa   */
    DEF INPUT  PARAM p-identificador         AS DEC.        
    DEF INPUT  PARAM p-nrdconta              AS INTE. 
    DEF INPUT  PARAM p-nmprimtl              AS CHAR.
    DEF INPUT  PARAM p-codigo                AS INTE.      
    DEF INPUT  PARAM p-nrcpfcgc              AS DEC.         
    
               
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).           

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
    
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
    
    IF  crapcgp.flgrgatv <> YES THEN
        DO:
           ASSIGN i-cod-erro  =  0                                             
                  c-desc-erro = "Guia Nao Ativa".                    
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
        END.
     
    IF  crapcgp.cddpagto <> p-codigo THEN
        DO:
           ASSIGN i-cod-erro  =  0
                  c-desc-erro = "Codigo Invalido.".
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
        END.

    /* Consistir se a guia gps esta em debito automatico */
    IF  crapcgp.flgdbaut  THEN
    DO:
        ASSIGN i-cod-erro  =  0
               c-desc-erro = "Guia esta em debito automatico. " +
                             "Pagamento nao permitido".
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.

    IF  crapcgp.nrdconta > 0 THEN 
        DO:
           
           FIND crapass WHERE
                crapass.cdcooper = crapcop.cdcooper  AND
                crapass.nrdconta = crapcgp.nrdconta  NO-LOCK NO-ERROR.

           IF  AVAIL crapass THEN 
               ASSIGN p-nmprimtl = crapass.nmprimtl.
        END.
                  
    RETURN "OK".

END PROCEDURE.

PROCEDURE valida-competencia.
      
    DEF INPUT  PARAM p-cooper                AS CHAR. 
    DEF INPUT  PARAM p-cod-agencia           AS INTEGER.  /* Cod. Agencia   */
    DEF INPUT  PARAM p-nro-caixa             AS INTEGER.  /* Numero Caixa   */
    DEF INPUT  PARAM p-codigo                AS INTE.
    DEF INPUT  PARAM p-mesref                AS INTE.
    DEF INPUT  PARAM p-anoref                AS INTE.    
    DEF VARIABLE     aux_valida              AS LOG   INIT FALSE.
    
    RUN elimina-erro (INPUT p-cooper,   
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
    
    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.
    
    IF  p-mesref   = 0  OR
        p-anoref   = 0 THEN
        DO:
           ASSIGN i-cod-erro  = 0
                  c-desc-erro = 
                             'Campo "Mes/Ano Competencia" deve ser informado.'.
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
        END.
    ELSE
    IF CAN-DO("1007,1163,1236,1287,1406,1473,1503,1686,1805",
                                                        STRING(p-codigo)) THEN
        DO:
           IF p-mesref >= 1 AND p-mesref <= 12 THEN
              DO: 
                  IF p-anoref > YEAR(crapdat.dtmvtolt) THEN
                      ASSIGN aux_valida = FALSE.
                  
                  IF  p-anoref = YEAR(crapdat.dtmvtolt) + 1               AND
                       ((MONTH(crapdat.dtmvtolt) > 10) AND (p-mesref < 3)) THEN
                        ASSIGN aux_valida = TRUE.
                  ELSE
                  IF (p-mesref + 1 >= MONTH(crapdat.dtmvtolt)   AND
                      p-anoref     =  YEAR(crapdat.dtmvtolt))   OR
                     (p-mesref = 12                             AND
                      MONTH(crapdat.dtmvtolt) = 01              AND
                      p-anoref + 1 = YEAR(crapdat.dtmvtolt))    THEN
                      ASSIGN aux_valida = TRUE.

              END.
        END.
    ELSE
    IF  CAN-DO("1104,1147,1180,1198,1228,1252,1260,1457,1490,1554,1678,1694," +
               "1813,1848,1937,1953",STRING(p-codigo)) THEN
        DO:                      
            IF  CAN-DO("3,6,9,12",STRING(p-mesref)) THEN
            DO:
                IF (p-mesref > MONTH(crapdat.dtmvtolt) AND
                    p-anoref =  YEAR(crapdat.dtmvtolt)) OR
                   (p-anoref >  YEAR(crapdat.dtmvtolt)) THEN
                    ASSIGN aux_valida = FALSE.
                ELSE
                IF (p-mesref + 1 >= MONTH(crapdat.dtmvtolt)   AND
                    p-anoref     =  YEAR(crapdat.dtmvtolt))   OR
                   (p-mesref = 12                             AND
                    MONTH(crapdat.dtmvtolt) = 01              AND
                    p-anoref + 1 = YEAR(crapdat.dtmvtolt))    THEN
                    ASSIGN aux_valida = TRUE.
            END.
        END.
    ELSE     
    IF  p-codigo = 1651 THEN 
        DO:
            IF  CAN-DO("3,6,9,12,13",STRING(p-mesref)) THEN
                DO:
                    IF (p-mesref > MONTH(crapdat.dtmvtolt) AND
                        p-anoref =  YEAR(crapdat.dtmvtolt)) OR
                       (p-anoref >  YEAR(crapdat.dtmvtolt)) THEN
                        ASSIGN aux_valida = FALSE.
                    
                    IF p-mesref = 13 AND 
                                    (YEAR(crapdat.dtmvtolt) = p-anoref) THEN
                        ASSIGN aux_valida = TRUE.
                    ELSE
                    IF (p-mesref + 1 >= MONTH(crapdat.dtmvtolt)   AND
                        p-anoref     =  YEAR(crapdat.dtmvtolt))   OR
                       (p-mesref = 12                             AND 
                        MONTH(crapdat.dtmvtolt) = 01              AND
                        p-anoref + 1 = YEAR(crapdat.dtmvtolt))    THEN
                        ASSIGN aux_valida = TRUE.
                END.
        END.
    ELSE
    IF  p-codigo = 1201 THEN
        DO:
            IF p-mesref >= 1    AND p-mesref <= 12                       AND
               p-anoref >= 2000 AND p-anoref <= (YEAR(crapdat.dtmvtolt)) THEN
               DO:
                   ASSIGN aux_valida = TRUE.
               END.
        END.
    ELSE
    IF  CAN-DO("1120,1929",STRING(p-codigo)) THEN
        DO:
            IF p-mesref >= 1 AND p-mesref <= 12 THEN
            DO:
                IF p-anoref > YEAR(crapdat.dtmvtolt) THEN
                      ASSIGN aux_valida = FALSE.
                ELSE
                IF (p-mesref + 1 >= MONTH(crapdat.dtmvtolt)   AND
                    p-anoref      =  YEAR(crapdat.dtmvtolt))  OR
                   (p-mesref = 12                             AND
                    MONTH(crapdat.dtmvtolt) = 01              AND
                    p-anoref + 1 =  YEAR(crapdat.dtmvtolt))   THEN
                    ASSIGN aux_valida = TRUE.
            END.
        END.
    ELSE
    IF  CAN-DO("1600,1619",STRING(p-codigo)) THEN
        DO:
            IF  p-mesref >= 1 AND p-mesref <= 13 THEN
                DO:
                    IF p-anoref > YEAR(crapdat.dtmvtolt) THEN
                        ASSIGN aux_valida = FALSE.
                    
                    IF  p-anoref = YEAR(crapdat.dtmvtolt) + 1               AND
                       ((MONTH(crapdat.dtmvtolt) > 10) AND (p-mesref < 3)) THEN
                        ASSIGN aux_valida = TRUE.
                    ELSE
                    IF p-mesref = 13 AND (YEAR(crapdat.dtmvtolt) > p-anoref OR
                                          YEAR(crapdat.dtmvtolt) < p-anoref) THEN
                        ASSIGN aux_valida = FALSE.
                    ELSE
                    IF (p-mesref + 1 >= MONTH(crapdat.dtmvtolt)   AND
                        p-anoref     =  YEAR(crapdat.dtmvtolt))   OR
                       (p-mesref = 12                             AND 
                        MONTH(crapdat.dtmvtolt) = 01              AND
                        p-anoref + 1 = YEAR(crapdat.dtmvtolt))    THEN
                      ASSIGN aux_valida = TRUE.
                END.

        END.
    ELSE
    IF  p-codigo = 1708 THEN
        DO:
            IF p-mesref >= 1 AND p-mesref <= 13 THEN
                DO:
                    IF p-anoref > YEAR(crapdat.dtmvtolt) THEN
                        ASSIGN aux_valida = FALSE.
                    ELSE
                    IF p-mesref = 13 AND (YEAR(crapdat.dtmvtolt) > p-anoref OR
                                          YEAR(crapdat.dtmvtolt) < p-anoref) THEN
                        ASSIGN aux_valida = FALSE.
                    ELSE
                    IF (p-mesref + 1 >= MONTH(crapdat.dtmvtolt)   AND
                        p-anoref     =  YEAR(crapdat.dtmvtolt))   OR
                       (p-mesref = 12                             AND 
                        MONTH(crapdat.dtmvtolt) = 01              AND
                        p-anoref + 1 = YEAR(crapdat.dtmvtolt))    THEN
                      ASSIGN aux_valida = TRUE.
                END.
        END.
    ELSE
    IF  CAN-DO("1759,1902",STRING(p-codigo)) THEN
        DO:
            IF p-mesref >= 1 AND p-mesref <= 13 THEN
                DO:
                    IF (p-mesref > MONTH(crapdat.dtmvtolt) AND
                        p-anoref =  YEAR(crapdat.dtmvtolt)) OR
                       (p-anoref >  YEAR(crapdat.dtmvtolt)) THEN
                        ASSIGN aux_valida = FALSE.
                    
                    IF p-mesref = 13 AND 
                                    (YEAR(crapdat.dtmvtolt) = p-anoref) THEN
                        ASSIGN aux_valida = TRUE.
                    ELSE
                    IF (p-mesref + 1 >= MONTH(crapdat.dtmvtolt)   AND
                        p-anoref     =  YEAR(crapdat.dtmvtolt))   OR
                       (p-mesref = 12                             AND 
                        MONTH(crapdat.dtmvtolt) = 01              AND
                        p-anoref + 1 = YEAR(crapdat.dtmvtolt))    THEN
                      ASSIGN aux_valida = TRUE.
                END.
        END.
    ELSE
    IF  p-codigo = 2003 THEN
        DO:
            IF (p-mesref >= 1    AND p-mesref <= 13                        AND
                p-anoref >= 1997 AND p-anoref <= (YEAR(crapdat.dtmvtolt))) THEN
                DO:
                    ASSIGN aux_valida = TRUE.
                    IF   p-anoref =  YEAR(crapdat.dtmvtolt)   AND
                        (p-mesref >  MONTH(crapdat.dtmvtolt)  AND 
                         p-mesref <> 13 )                     THEN
                         ASSIGN aux_valida = FALSE.
                END.
        END.
    ELSE
    IF  p-codigo = 2550 THEN
        DO:
            IF (p-mesref >= 1     AND 
                p-mesref <= 12)   AND  
                p-anoref >= 1998  THEN
                ASSIGN aux_valida = TRUE.
        END.
    ELSE
    IF  CAN-DO("2852,2879,2950,2976",STRING(p-codigo)) THEN
        DO:
            IF  (p-mesref >= 1    AND p-mesref <= 13)                     AND 
                (p-anoref >= 1999 AND p-anoref <= YEAR(crapdat.dtmvtolt)) THEN
                 DO:
                    ASSIGN aux_valida = TRUE.
                    IF  p-anoref  = YEAR(crapdat.dtmvtolt)    AND
                        p-mesref  > MONTH(crapdat.dtmvtolt)   AND
                        p-mesref <> 13                        THEN
                        ASSIGN aux_valida = FALSE.
                 END.
        END.
    ELSE 
    IF  CAN-DO("2437,2445",STRING(p-codigo)) THEN
        DO:
            IF  (p-mesref >= 1    AND p-mesref <= 12) AND 
                (p-anoref >= 1966 AND p-anoref <= YEAR(crapdat.dtmvtolt)) THEN
                 DO:
                    ASSIGN aux_valida = TRUE.
                    IF (p-anoref = YEAR(crapdat.dtmvtolt)    AND
                        p-mesref > MONTH(crapdat.dtmvtolt)) THEN
                        ASSIGN aux_valida = FALSE.
                 END.
        END.
    ELSE
    IF  CAN-DO("2011,2020",STRING(p-codigo)) THEN
        DO:
            IF  (p-mesref >= 1    AND p-mesref <= 12)                     AND
                (p-anoref >= 1997 AND p-anoref <= YEAR(crapdat.dtmvtolt)) THEN
                 DO:
                    ASSIGN aux_valida = TRUE.
                    IF  p-anoref = YEAR(crapdat.dtmvtolt)  AND
                        p-mesref > MONTH(crapdat.dtmvtolt) THEN
                        ASSIGN aux_valida = FALSE. 
                 END.
        END.
    ELSE
    IF  p-codigo = 2127  THEN
        DO:
            IF  (p-mesref >= 1    AND p-mesref <= 12)  AND
                (p-anoref >= 2003 AND p-anoref <= YEAR(crapdat.dtmvtolt)) THEN
                 DO:
                    ASSIGN aux_valida = TRUE.
                    IF (p-anoref = 2003 AND p-mesref < 4)   THEN
                        ASSIGN aux_valida = FALSE.
                 END.
        END.
    ELSE
    IF  CAN-DO("2143,2240",STRING(p-codigo)) THEN
        DO:
            IF  (p-mesref >= 1     AND  p-mesref <= 13)    AND
                (p-anoref >= 1964  AND  p-anoref <= 2006)  THEN
                 DO:
                    ASSIGN aux_valida = TRUE.
                    IF  (p-anoref = 1964  AND  p-mesref < 10) THEN
                        ASSIGN aux_valida = FALSE.
                 END.
        END.
    ELSE
    IF  p-codigo = 4316  THEN
        DO:
            IF  (p-mesref >= 1    AND p-mesref <= 12) AND
                (p-anoref >= 1993 AND p-anoref <= YEAR(crapdat.dtmvtolt)) THEN
                 DO:
                    ASSIGN aux_valida = TRUE.
                    IF  p-anoref = YEAR(crapdat.dtmvtolt)  AND
                        p-mesref > MONTH(crapdat.dtmvtolt) THEN
                        ASSIGN aux_valida = FALSE.
                 END.
        END.
    ELSE
    IF  p-codigo = 4324  THEN
        DO:
            IF  (p-mesref >= 1    AND p-mesref <= 12)    AND
                (p-anoref >= 2007 AND p-anoref <= YEAR(crapdat.dtmvtolt)) THEN
                 DO:
                    ASSIGN aux_valida = TRUE.
                    IF  (p-anoref = 2007  AND  p-mesref < 6) THEN
                        ASSIGN aux_valida = FALSE.
                 END.       
        END.
    ELSE
    IF  p-codigo = 4332  THEN
        DO:        
            IF  (p-mesref >= 1    AND p-mesref <= 12)    AND
                (p-anoref >= 2007 AND p-anoref <= YEAR(crapdat.dtmvtolt)) THEN
                 DO:
                    ASSIGN aux_valida = TRUE.
                    IF  (p-anoref = 2007  AND  p-mesref < 8) THEN
                        ASSIGN aux_valida = FALSE.             
                 END.         
        END.
    ELSE
    IF  CAN-DO("5037,5045,5053,5061,5070,5088," +
               "5096,5100,5118,5126,5134",STRING(p-codigo))  THEN         
        DO:
            IF (p-mesref >= 1    AND p-mesref <= 12)    AND
               (p-anoref >= 2000 AND p-anoref <= YEAR(crapdat.dtmvtolt)) THEN
                DO:
                    ASSIGN aux_valida = TRUE.
                    IF  p-anoref = YEAR(crapdat.dtmvtolt)  AND
                        p-mesref > MONTH(crapdat.dtmvtolt) THEN
                        ASSIGN aux_valida = FALSE.
                END. 
        END.
    ELSE
    IF  CAN-DO("7315,6513,6505",STRING(p-codigo)) THEN
        DO:
            IF (p-mesref >= 1    AND p-mesref <= 12)    AND
               (p-anoref >= 2003 AND p-anoref <= YEAR(crapdat.dtmvtolt)) THEN
                DO:
                    ASSIGN aux_valida = TRUE.
                    IF  (p-anoref = 2003  AND 
                         p-mesref < 10)                       OR
                        (p-anoref = YEAR(crapdat.dtmvtolt)    AND
                         p-mesref > MONTH(crapdat.dtmvtolt))  THEN
                         ASSIGN aux_valida = FALSE.
                END.
        END.
    ELSE
    IF  p-codigo = 7307 THEN
        DO:
            IF (p-mesref >= 1    AND p-mesref <= 12)                     AND
               (p-anoref >= 1999 AND p-anoref <= YEAR(crapdat.dtmvtolt)) THEN
                DO:
                    ASSIGN aux_valida = TRUE.
                    IF  (p-anoref = 1999  AND 
                         p-mesref < 5)                        OR
                        (p-anoref = YEAR(crapdat.dtmvtolt)    AND
                         p-mesref > MONTH(crapdat.dtmvtolt))  THEN
                         ASSIGN aux_valida = FALSE.            
                END. 
        END.
    ELSE
    IF  CAN-DO("1244,1295,1830,1910,1945",STRING(p-codigo))   THEN
        DO:
            IF p-mesref >= 1 AND p-mesref <= 12 THEN
            DO:
                IF (p-mesref > MONTH(crapdat.dtmvtolt) AND
                    p-anoref =  YEAR(crapdat.dtmvtolt)) OR
                   (p-anoref >  YEAR(crapdat.dtmvtolt)) THEN
                    ASSIGN aux_valida = FALSE.
                ELSE
                IF (p-mesref + 1 >= MONTH(crapdat.dtmvtolt)   AND
                    p-anoref     =  YEAR(crapdat.dtmvtolt))   OR
                   (p-mesref = 12                             AND 
                    MONTH(crapdat.dtmvtolt) = 01              AND
                    p-anoref + 1 = YEAR(crapdat.dtmvtolt))    THEN
                      ASSIGN aux_valida = TRUE.
            END.
        END.
    ELSE
    IF  p-codigo = 1821 THEN
        DO:
            IF p-mesref >= 1 AND p-mesref <= 12 THEN
            DO:
                IF (p-mesref > MONTH(crapdat.dtmvtolt) AND
                    p-anoref =  YEAR(crapdat.dtmvtolt)) OR
                   (p-anoref >  YEAR(crapdat.dtmvtolt)) THEN
                    ASSIGN aux_valida = FALSE.
                ELSE
                IF (p-mesref > 1 AND p-anoref >= 1998) AND
                   ((p-mesref < 10 AND p-anoref = 2004) OR
                   (p-anoref < 2004)) THEN
                    ASSIGN aux_valida = TRUE.
            END.
        END.
    ELSE
    IF p-codigo = 4367 THEN
       DO:
          IF p-mesref >= 1 AND p-mesref <= 12       AND
             p-anoref <= YEAR(crapdat.dtmvtolt)     AND 
           ((p-anoref >= 2013 AND p-mesref >= 3)    OR 
            (p-mesref < 3     AND p-anoref > 2013)) THEN  
             ASSIGN aux_valida = TRUE.

       END.
    ELSE
    IF (p-mesref >= 1      AND  p-mesref <= 13) AND
       (p-anoref >= 1966   AND  p-anoref <= YEAR(crapdat.dtmvtolt)) THEN
        DO: 
            ASSIGN aux_valida = TRUE.
            IF  (p-anoref =  YEAR(crapdat.dtmvtolt)  AND
                 p-mesref >  MONTH(crapdat.dtmvtolt) AND
                 p-mesref <> 13)                     THEN
                 ASSIGN aux_valida = FALSE.

        END.
    
    IF  aux_valida = FALSE THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = '"Mes/Ano Competencia" invalido para ' +
                                 'este codigo.'.
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE  valida-valor-entidades.

    DEF INPUT  PARAM p-cooper                AS CHAR.
    DEF INPUT  PARAM p-cod-agencia           AS INTE.
    DEF INPUT  PARAM p-nro-caixa             AS INTEGER. /* Numero Caixa   */
    DEF INPUT  PARAM p-codigo                AS DEC.     
    DEF INPUT  PARAM p-valorout              AS DEC.
    DEF OUTPUT PARAM p-dsobserv              AS CHAR. 
    DEF OUTPUT PARAM p-verdbaut              AS LOG. 
    
    RUN elimina-erro (INPUT p-cooper,   
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
    
    IF  CAN-DO("2020,2119,2143,2216,2240,2615,2712,2810,"  + 
               "2879,2917,2976",STRING(p-codigo))     THEN  
        DO: 
            IF  p-valorout = 0 THEN DO:
                
                ASSIGN 
                   p-dsobserv = '"Valor Outras Entidades" deve ser informado.'.
          
                IF  p-cod-agencia = 999 THEN /** Chamada pela tela MOVGPS **/
                    DO:                   
                        ASSIGN p-verdbaut = TRUE. 
                        RETURN "OK". 
                    END.

                ASSIGN  i-cod-erro  = 0
                        c-desc-erro = p-dsobserv. 
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
    IF  NOT CAN-DO("2011,2100,2127,2208,2305,2321,2437,2445," +
                   "2500,2607,2704,2801,2852,2909,2950",STRING(p-codigo))THEN
        DO:        
            IF  p-valorout <> 0 THEN           
                DO:
                 
                 ASSIGN p-dsobserv = 
                                  '"Outras Entidades" nao deve ser informado.'.
                               
                 IF  p-cod-agencia = 999 THEN /** Chamada pela tela CADGPS **/
                     DO:                   
                        ASSIGN p-verdbaut = TRUE. 
                        RETURN "OK". 
                     END.
                    
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = p-dsobserv.
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

PROCEDURE valida-atm-juros.
    
    DEF INPUT  PARAM p-cooper                AS CHAR.
    DEF INPUT  PARAM p-cod-agencia           AS INTEGER.
    DEF INPUT  PARAM p-nro-caixa             AS INTEGER. /* Numero Caixa   */
    DEF INPUT  PARAM p-codigo                AS INTEGER.
    DEF INPUT  PARAM p-mesref                AS INTEGER.
    DEF INPUT  PARAM p-anoref                AS INTEGER.
    DEF INPUT  PARAM p-valorjur              AS DECIMAL.     
    DEF INPUT  PARAM p-inpessoa              AS INTEGER. 
    DEF OUTPUT PARAM p-dsobserv              AS CHAR.    
    DEF OUTPUT PARAM p-verdbaut              AS LOGICAL. 

    DEF VARIABLE     p-atraso                AS LOGICAL. 
    DEF VARIABLE     aux_contador            AS INTEGER.    
    DEF VARIABLE     aux_dtmvtolt            AS DATE. 
    
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,   
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).           

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.
 
    ASSIGN p-atraso = FALSE.
    
    IF  p-cod-agencia = 999 THEN   /** Tratamento para MOVGPS **/
        DO: 
            /* Busca e monta a data de quitacao para agendamento*/
            FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper   AND
                               craptab.nmsistem = "CRED"             AND
                               craptab.tptabela = "GENERI"           AND
                               craptab.cdempres = 0                  AND
                               craptab.cdacesso = "GPSAGEBCOB"       AND
                               craptab.tpregist = p-inpessoa   
                               NO-LOCK NO-ERROR.
            
            ASSIGN aux_dtmvtolt = DATE(MONTH(crapdat.dtmvtolt),
                                       INT(SUBSTRING(craptab.dstextab,1,2)),
                                       YEAR(crapdat.dtmvtolt)).
        END.
    ELSE
        ASSIGN aux_dtmvtolt = crapdat.dtmvtolt. 

    
    IF  CAN-DO("1759,3000,3107,1201",STRING(p-codigo)) THEN
        DO:                 
            IF  p-valorjur = 0 THEN
                DO:
                    
                    ASSIGN p-dsobserv = '"ATM/Multa/Juros" eh obrigatorio.'.
                    
                    IF  p-cod-agencia = 888 THEN  /* Tratamento para CADGPS */
                        DO:
                            ASSIGN p-verdbaut = TRUE.
                            RETURN "OK".
                        END.
                    
                    IF  p-cod-agencia = 999 THEN  /* Tratamento para MOVGPS */
                        DO: 
                            ASSIGN p-verdbaut = TRUE.  
                            RETURN "OK".
                        END.
                    
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro =  p-dsobserv. 
                    
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
        END. 
    ELSE   /** Posterior ao dia 10 do mes subsequente da competencia **/
    IF  CAN-DO("2801,2810,2909,2917",STRING(p-codigo)) THEN
        DO:                                     
            IF  p-mesref = 13 THEN
                ASSIGN p-atraso = FALSE.      
            ELSE                                  
                DO:   
                   IF  p-mesref  = 12 THEN
                       aux_dataref = DATE("10/1/" + STRING(p-anoref + 1)). 
                   ELSE
                       aux_dataref = DATE("10/" + STRING(p-mesref + 1) + "/" +
                                     STRING(p-anoref)).
            
                   RUN verifica-dia-util.
            
                   IF  aux_dtmvtolt > aux_dataref    AND   
                       p-valorjur = 0                THEN
                       ASSIGN p-atraso = TRUE.
                END.
        END.
    ELSE  /** Posterior ao dia 15 do mes subsequente da competencia **/
    IF  CAN-DO("1007,1104,1120,1147,1163,1180,1198,1228,1244,1252,1260,1287," +
               "1295,1406,1457,1473,1490,1503,1554,1600,1619,1651,1678,1686," +
               "1694,1805,1813,1821", STRING(p-codigo))  THEN
        DO:
            IF  p-mesref = 13 THEN
                DO:
                    IF  CAN-DO("1600,1651",STRING(p-codigo)) THEN
                        DO:             
                             IF  aux_dtmvtolt > DATE("20/12/" + 
                                                     STRING(p-anoref)) AND
                                 p-valorjur = 0                      THEN
                                 ASSIGN  p-atraso = TRUE.
                        END.
                    ELSE
                        ASSIGN p-atraso = FALSE.
                END.
            ELSE    
                DO:
                    IF  p-mesref  =  12  THEN
                        aux_dataref = DATE("15/1/" + STRING(p-anoref + 1)). 
                    ELSE
                        aux_dataref = DATE("15/" + STRING(p-mesref + 1) + "/" +
                                      STRING(p-anoref)).
            
                    RUN verifica-dia-util.
            
                    IF  aux_dtmvtolt  > aux_dataref    AND    
                        p-valorjur = 0                 THEN
                        ASSIGN p-atraso = TRUE.
                END.
        END.
    ELSE    /*** Posterior ao 5o. dia util do mes subsequente ***/
    IF  CAN-DO("7315,7307",STRING(p-codigo)) THEN
        DO:
            IF  p-mesref = 13  THEN
                ASSIGN  p-atraso = FALSE.
            ELSE
                DO:
                    IF  p-mesref  =  12  THEN
                        aux_dataref = DATE("1/1/" + STRING(p-anoref + 1)). 
                    ELSE
                        aux_dataref = DATE("1/" + STRING(p-mesref + 1) + "/" +
                                      STRING(p-anoref)). 
        
                    RUN verifica-dia-util.
            
                    DO  aux_contador = 1 to 4 :
                        ASSIGN aux_dataref = aux_dataref + 1.
                        RUN verifica-dia-util.     
                    END.
        
                    IF  aux_dtmvtolt    > aux_dataref  AND  
                        p-valorjur      = 0            THEN
                        ASSIGN p-atraso = TRUE.
                END.
        END.
    ELSE    /** Pagto apos o ultimo dia util do mes posterior da guia **/
    IF  p-codigo = 6513   THEN
        DO:
            IF  p-mesref = 13 THEN
                ASSIGN  p-atraso = FALSE.
            ELSE
                DO:
                    IF  p-mesref  =  11   THEN
                        aux_dataref = DATE("1/1/" + STRING(p-anoref + 1)). 
                    IF  p-mesref  =  12   THEN
                        aux_dataref = DATE("1/2/" + STRING(p-anoref + 1)).
                    ELSE
                        aux_dataref =  DATE("1/" + STRING(p-mesref + 2) + "/" + 
                                       STRING(p-anoref)). 
        
                    IF  aux_dtmvtolt >= aux_dataref  AND  
                        p-valorjur    = 0            THEN
                        ASSIGN p-atraso = TRUE.
                END.
        END.        
    ELSE /** Posterior ao dia 20 do mes subsequente da competencia da guia **/
    IF  CAN-DO("2003,2011,2020,2127,2143,2100,2119,2208,2216,2240,2305" +
               "2321,2402,2429,2437,2445,2500,2607,2615,2631,2640,2658" +
               "2682,2704,2712,2852,2879,2950,2976,6505",STRING(p-codigo)) THEN 
        DO:
            IF  p-mesref = 13 THEN DO:
                IF  CAN-DO ("2003,2100,2119,2208,2216,2305," + 
                            "2321,2402,2429",STRING(p-codigo)) THEN  
                    DO:                   
                       IF  aux_dtmvtolt > DATE("20/12/" + 
                                               STRING(p-anoref)) AND
                           p-valorjur = 0                        THEN
                           ASSIGN  p-atraso = TRUE.
                    END.        
                ELSE
                    ASSIGN p-atraso = FALSE.
            END.
            ELSE
            DO:
                IF  p-mesref  =  12  THEN
                    aux_dataref = DATE("20/1/" + STRING(p-anoref + 1)). 
                ELSE
                    aux_dataref = DATE("20/" + STRING(p-mesref + 1) + "/" +
                                  STRING(p-anoref)).
                
                IF  p-codigo = 6505 THEN
                    RUN verifica-dia-util.
                
                IF  CAN-DO("2100,2119,2208,2216,2305,2321,2500,2607,2615," +
                          "2704,2712,2852,2879,2950,2976",STRING(p-codigo)) AND
                    aux_dtmvtolt <= aux_dataref                             AND
                    p-valorjur   >  0                                       THEN
                    DO:
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = 
                                    'Guia nao esta em Atraso!! "ATM ' +
                                    '/ Multa e Juros" nao deve ser informado.'.

                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                    END.
                ELSE               
                    IF  aux_dtmvtolt  >    aux_dataref  AND
                        p-valorjur    =    0            THEN
                        ASSIGN p-atraso = TRUE.
            
            END. /** Fim ELSE **/
        END.

    IF  p-atraso = TRUE  THEN
        DO: 
            ASSIGN p-dsobserv = 'Guia em atraso!! Informe "ATM/Multa/Juros".'.

            IF  p-cod-agencia = 999 THEN   /** Tratamento para MOVGPS **/
                DO: 
                    ASSIGN p-verdbaut = TRUE.  
                    RETURN "OK".
                END.
            
            ASSIGN  i-cod-erro  = 0
                    c-desc-erro = p-dsobserv.
                    
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

    
PROCEDURE valida-valores.                  
      
    DEF INPUT  PARAM p-cooper                AS CHAR.
    DEF INPUT  PARAM p-cod-agencia           AS INTE.
    DEF INPUT  PARAM p-nro-caixa             AS INTEGER. /* Numero Caixa   */
    DEF INPUT  PARAM p-identificador         AS DEC.     
    DEF INPUT  PARAM p-codigo                AS INT.  
    DEF INPUT  PARAM p-valorins              AS DEC.  
    DEF INPUT  PARAM p-valorjur              AS DEC. 
    DEF INPUT  PARAM p-valorout              AS DEC. 
    DEF INPUT  PARAM p-valortot              AS DEC.  

    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.
    
    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).            
     
    IF  CAN-DO("1759,2020,2119,2143,2216,2240,2615,2712,2810,2879," + 
               "2917,2976,3000,3107",STRING(p-codigo))               THEN
        DO:
            IF  p-valorins > 0 THEN
                DO:
                     ASSIGN i-cod-erro  = 0
                            c-desc-erro = "Valor INSS nao deve ser informado.".
                                                    
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
    IF  NOT CAN-DO("1201,2011,2445,2437",STRING(p-codigo)) THEN
        DO:
            IF  p-valorins = 0 THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = 
                                  "Valor INSS deve ser informado.".
                
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".        
                END.
        END.
    
    IF  p-valortot  <  10 THEN         
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = 
                          "Valor Total deve ser maior ou igual a R$ 10,00.".
                
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
    
    IF  p-valortot <> (p-valorins + p-valorjur + p-valorout) OR
        p-valortot = 0                                       THEN 
        DO:
           ASSIGN i-cod-erro  = 0
                  c-desc-erro = "Valor Total invalido.".               
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE atualiza-pagamento.
    
    DEF INPUT  PARAM p-cooper             AS CHAR.
    DEF INPUT  PARAM p-cod-agencia        AS INTEGER.   /* Cod. Agencia     */
    DEF INPUT  PARAM p-nro-caixa          AS INTEGER.   /* Numero Caixa     */
    DEF INPUT  PARAM p-cod-operador       AS CHAR.
    DEF INPUT  PARAM p-identificador      AS DEC.   
    DEF INPUT  PARAM p-codigo             AS INTE.  
    DEF INPUT  PARAM p-mesref             AS INTE.
    DEF INPUT  PARAM p-anoref             AS INTE.
    DEF INPUT  PARAM p-valorins           AS DEC.  
    DEF INPUT  PARAM p-valorjur           AS DEC. 
    DEF INPUT  PARAM p-valorout           AS DEC. 
    DEF INPUT  PARAM p-valortot           AS DEC.  
    DEF OUTPUT PARAM p-literal            AS CHAR.
    DEF OUTPUT PARAM p-ult-sequencia      AS INTE.
    DEF OUTPUT PARAM p-docto              AS DEC.

    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN i-nro-lote = 24000 + p-nro-caixa.
  
    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.

    ASSIGN  aux_mmaacomp = SUBSTR(STRING(p-mesref,"99"),1,2) + 
                           SUBSTR(STRING(p-anoref,"9999"),1,4).     

    FIND FIRST craplgp WHERE
               craplgp.cdcooper = crapcop.cdcooper                     AND
               craplgp.dtmvtolt = crapdat.dtmvtolt                     AND
               craplgp.cdagenci = p-cod-agencia                        AND
               craplgp.cdbccxlt = 11                   /* Fixo */      AND 
               craplgp.nrdolote = i-nro-lote                           AND
               craplgp.cdidenti = p-identificador                      AND
               craplgp.cddpagto = p-codigo                             AND
               craplgp.mmaacomp = INTE(STRING(aux_mmaacomp,"999999"))  AND
               craplgp.vlrtotal = p-valortot 
               NO-LOCK NO-ERROR. 

    IF   AVAIL craplgp THEN DO:
         ASSIGN i-cod-erro  = 92           
                c-desc-erro = " ".
         RUN cria-erro (INPUT p-cooper,
                        INPUT p-cod-agencia,
                        INPUT p-nro-caixa,
                        INPUT i-cod-erro,
                        INPUT c-desc-erro,
                        INPUT YES).
         RETURN "NOK".
    END. 
    
    FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper   AND
                       craplot.dtmvtolt = crapdat.dtmvtolt   AND
                       craplot.cdagenci = p-cod-agencia      AND
                       craplot.cdbccxlt = 11                 AND  /* Fixo */
                       craplot.nrdolote = i-nro-lote         NO-ERROR.
         
    IF  NOT AVAIL craplot THEN do:
        CREATE craplot.
        ASSIGN craplot.dtmvtolt = crapdat.dtmvtolt
               craplot.cdagenci = p-cod-agencia   
               craplot.cdbccxlt = 11              
               craplot.nrdolote = i-nro-lote
               craplot.tplotmov = 30 
               craplot.cdoperad = p-cod-operador
               /* Historico BANCOOB e BB */
               craplot.cdhistor = IF crapcop.cdcrdarr <> 0 THEN 582 ELSE 458
               /* Pagto GPS */
               craplot.nrdcaixa = p-nro-caixa
               craplot.cdopecxa = p-cod-operador 
               craplot.cdcooper = crapcop.cdcooper.
    END.

    CREATE craplgp.
    ASSIGN craplgp.cdcooper = crapcop.cdcooper
           craplgp.dtmvtolt = craplot.dtmvtolt
           craplgp.cdagenci = craplot.cdagenci
           craplgp.cdbccxlt = craplot.cdbccxlt
           craplgp.nrdolote = craplot.nrdolote
           craplgp.cdopecxa = p-cod-operador 
           craplgp.nrdcaixa = p-nro-caixa
           craplgp.nrdmaqui = p-nro-caixa
           craplgp.cdidenti = p-identificador 
           craplgp.cddpagto = p-codigo          
           aux_mmaacomp = SUBSTR(STRING(p-mesref,"99"),1,2) + 
                          SUBSTR(STRING(p-anoref,"9999"),1,4)      
           craplgp.mmaacomp = INTE(STRING(aux_mmaacomp,"999999"))           
           craplgp.vlrdinss = p-valorins   
           craplgp.vlrouent = p-valorout
           craplgp.vlrjuros = p-valorjur 
           craplgp.vlrtotal = p-valortot                                  
           craplgp.nrseqdig = craplot.nrseqdig + 1   
           craplgp.hrtransa = TIME.

    ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
           craplot.qtcompln = craplot.qtcompln + 1
           craplot.qtinfoln = craplot.qtinfoln + 1
           craplot.vlcompdb = craplot.vlcompdb + p-valortot    
           craplot.vlinfodb = craplot.vlinfodb + p-valortot.   

    /*--- Grava Autenticacao Arquivo/Spool --*/
    RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
    RUN grava-autenticacao 
               IN h_b1crap00 (INPUT p-cooper,
                              INPUT p-cod-agencia,
                              INPUT p-nro-caixa,
                              INPUT p-cod-operador,
                              INPUT p-valortot,
                              INPUT DEC(craplgp.nrseqdig),
                              INPUT NO, /* YES (PG), NO (REC) */
                              INPUT "1",  /* On-line            */  
                              INPUT NO,   /* Nao estorno        */
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
    /*------*/
    
    ASSIGN craplgp.nrautdoc = p-ult-sequencia.
    
    ASSIGN p-docto    = craplgp.nrseqdig.
   
   RELEASE craplgp.
    
   RELEASE craplot.

   RETURN "OK".

END PROCEDURE.

PROCEDURE verifica-dia-util. 

    DO  WHILE TRUE:
    
        IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dataref))) OR
            CAN-FIND(crapfer WHERE  crapfer.cdcooper = crapcop.cdcooper  AND
                                    crapfer.dtferiad = aux_dataref)      THEN
            DO:
                 ASSIGN aux_dataref = aux_dataref + 1.
                 NEXT.
            END.
        LEAVE.  
    END.
END.

/* #TODO APOS A INCORPORACAO (28/11/2014), REMOVER ESTE PROCEDIMENTO */
PROCEDURE msg-inicial:

    DEF INPUT PARAM par_nmrescop   AS CHAR               NO-UNDO.
    DEF INPUT PARAM par_cdagenci   AS INTE               NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa   AS INTE               NO-UNDO.

    RUN elimina-erro (INPUT par_nmrescop,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa).

    ASSIGN i-cod-erro  = 0 
           c-desc-erro = "Rotina bloqueada para cooperativa.".

    RUN cria-erro (INPUT par_nmrescop,
                   INPUT par_cdagenci,
                   INPUT par_nrdcaixa,
                   INPUT i-cod-erro,
                   INPUT c-desc-erro,
                   INPUT YES).
    RETURN "MSG".

END PROCEDURE.
