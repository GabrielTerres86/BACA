/* .............................................................................

   Programa: siscaixa/web/dbo/b1crap03.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 10/10/2012.

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Consulta Extrato

   Alteracoes: 31/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)                            
                            
               22/02/2006 - Unificacao dos bancos - SQLWorks - Eder             

               24/07/2007 - Incluidos historicos de transferencia pela internet
                            (Evandro).

               09/09/2009 - Incluir historico de transferencia de credito de 
                            salario (David). 

               23/11/2009 - Alteracao Codigo Historico (Kbase).
               
               19/05/2010 - Acerto no SUBSTRING do campo craplcm.cdpesqbb
                            (Diego).
                            
               10/10/2012 - Tratamento para novo campo da 'craphis' de descrição
                            do histórico em extratos (Lucas) [Projeto Tarifas].
                            
............................................................................ */

/*---------------------------------------------------------------*/
/*  b1crap03.p - Consulta Extrato                                */
/*---------------------------------------------------------------*/

DEF TEMP-TABLE tt-extrato
    FIELD conta    AS INTE
    FIELD dtmvtolt AS DATE    FORMAT "99/99/9999"
    FIELD nrdocmto AS CHAR    FORMAT "x(11)"
    FIELD indebcre AS CHAR    FORMAT " x "
    fIELD vllanmto AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD dsextrat LIKE craphis.dsextrat.

PROCEDURE consulta-extrato.
    DEF INPUT        PARAM p-cooper        AS CHAR. 
    DEF INPUT        PARAM p-nro-conta     AS INTE.
    DEF INPUT        PARAM p-data          AS date.
    DEF OUTPUT       PARAM TABLE FOR  tt-extrato.

    DEF VAR dt-inipesq   AS DATE NO-UNDO.
    DEF VAR aux_lshistor AS CHAR NO-UNDO.
    DEF VAR aux_dslibera AS CHAR NO-UNDO.
    DEF VAR aux_dsextrat AS CHAR NO-UNDO.
  
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
   
    IF  MONTH(crapdat.dtmvtolt) = 1 THEN
        ASSIGN dt-inipesq = DATE(12,1,YEAR(crapdat.dtmvtolt) - 1).
    ELSE
        ASSIGN dt-inipesq = DATE(MONTH(crapdat.dtmvtolt )- 1,1,
                                 YEAR(crapdat.dtmvtolt)).
  
    IF  p-data = ? THEN
        ASSIGN p-data = (crapdat.dtmvtolt - DAY(crapdat.dtmvtolt)) + 1.

    IF  p-data  < dt-inipesq  THEN
        ASSIGN p-data  = dt-inipesq.    
        
    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                       craptab.nmsistem = "CRED"            AND
                       craptab.tptabela = "GENERI"          AND
                       craptab.cdempres = 0                 AND
                       craptab.cdacesso = "HSTCHEQUES"      AND
                       craptab.tpregist = 0                 NO-LOCK NO-ERROR.
                
    IF  AVAILABLE craptab   THEN
        aux_lshistor = craptab.dstextab.
    ELSE
        aux_lshistor = "999".
        
    FOR EACH tt-extrato:
        DELETE tt-extrato.
    END.

    FOR EACH craplcm WHERE craplcm.cdcooper  = crapcop.cdcooper     AND
                           craplcm.nrdconta  =  p-nro-conta         AND
                           craplcm.dtmvtolt >=  p-data              AND
                           craplcm.cdhistor <> 289                  
                           USE-INDEX craplcm2 NO-LOCK:

        CREATE tt-extrato.
        ASSIGN tt-extrato.conta    = craplcm.nrdconta
               tt-extrato.dtmvtolt = craplcm.dtmvtolt
               tt-extrato.vllanmto = craplcm.vllanmto

               tt-extrato.nrdocmto = IF  CAN-DO(aux_lshistor,
                                                STRING(craplcm.cdhistor)) THEN
                                         STRING(craplcm.nrdocmto,"zzzzz,zz9,9")
                                     ELSE 
                                         IF  LENGTH(STRING(craplcm.nrdocmto)) <
                                             10  THEN
                                             STRING(craplcm.nrdocmto,
                                                    "zzzzzzz,zz9")
                                         ELSE 
                                             SUBSTR(STRING(craplcm.nrdocmto,
                                                    "99999999999999"),4,11).
                
        IF   CAN-DO("375,376,377,537,538,539,771,772",
                    STRING(craplcm.cdhistor))   THEN
             tt-extrato.nrdocmto = STRING(INT(SUBSTR(craplcm.cdpesqbb,45,8)),
                                                              "zzzzz,zzz,9").
                               
        FIND craphis OF craplcm NO-LOCK NO-ERROR.

        IF   NOT AVAIL craphis   THEN
             ASSIGN tt-extrato.indebcre = "?"
                    tt-extrato.dsextrat = STRING(craplcm.cdhistor,"9999") +  
                                          "-" + "Nao cadastrado!".
        ELSE DO:
             ASSIGN  aux_dslibera = "".
             IF   CAN-DO("3,4,5",STRING(craphis.inhistor))   THEN DO:
                  FIND crapdpb WHERE crapdpb.cdcooper = crapcop.cdcooper    AND
                                     crapdpb.dtmvtolt = craplcm.dtmvtolt    AND
                                     crapdpb.cdagenci = craplcm.cdagenci    AND
                                     crapdpb.cdbccxlt = craplcm.cdbccxlt    AND
                                     crapdpb.nrdolote = craplcm.nrdolote    AND
                                     crapdpb.nrdconta = p-nro-conta         AND
                                     crapdpb.nrdocmto = craplcm.nrdocmto 
                                     NO-LOCK NO-ERROR.
                                                       
                  IF   NOT AVAIL crapdpb   THEN
                       ASSIGN aux_dslibera = "(**/**)".
                  ELSE
                       IF   crapdpb.inlibera = 1 THEN
                            ASSIGN aux_dslibera = "(" + 
                                                  SUBSTRING(STRING(
                                                  crapdpb.dtliblan),1,5)+ ")".
                       ELSE
                            ASSIGN aux_dslibera = "(Estorno)".
             END.

             ASSIGN aux_dsextrat = STRING(craplcm.cdhistor,"9999") + "-"
                                        + craphis.dsextrat +
                                     (IF (craplcm.cdhistor = 47 OR
                                          craplcm.cdhistor = 78 OR
                                          craplcm.cdhistor = 191) 
                                     THEN craplcm.cdpesqbb
                                      ELSE "") + " " + aux_dslibera.
                                    
             /* Se pagamento de percela, insere num da parcela da descr. do extrato */
             IF  craplcm.nrparepr > 0 THEN
                 DO:
                     FIND crapepr WHERE crapepr.cdcooper = craplcm.cdcooper AND
                                        crapepr.nrdconta = craplcm.nrdconta AND
                                        crapepr.nrctremp = INT(craplcm.cdpesqbb)
                                        NO-LOCK NO-ERROR NO-WAIT.
             
                     IF AVAIL crapepr THEN
                         ASSIGN aux_dsextrat = SUBSTRING(aux_dsextrat,1,18) + " "
                                               + STRING(craplcm.nrparepr,"999") 
                                               + "/" + STRING(crapepr.qtpreemp,"999").
             
                 END.

             ASSIGN tt-extrato.indebcre = craphis.indebcre
                    tt-extrato.dsextrat = aux_dsextrat.
        END.

    END.  /*  for each   */

    RETURN "OK".
END PROCEDURE.

/* b1crap03.p */        

/* ......................................................................... */

