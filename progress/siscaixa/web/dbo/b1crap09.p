/* .............................................................................

   Programa: siscaixa/web/dbo/b1crap09.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 19/03/2009.

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Consulta Lancamento Boletim Caixa 

   Alteracoes: 01/09/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)
                            
               23/02/2006 - Unificacao dos bancos - SQLWorks - Eder            
                
               19/03/2009 - Ajustes para unificacao dos bancos de dados
                            (Evandro).
............................................................................ */

/*------------------------------------------------------------*/
/*  b1crap09.p - Consulta Lancamento Boletim Caixa            */
/*------------------------------------------------------------*/
DEF TEMP-TABLE tt-lancamento
    FIELD cdcooper    AS INTE
    FIELD controle    AS INTE
    FIELD cdhistor  LIKE craplcx.cdhistor      
    FIELD dshistor  LIKE craphis.dshistor
    FIELD dsdcompl    AS CHAR FORMAT "x(50)"                     
    FIELD nrdocmto  LIKE craplcx.nrdocmto
    FIELD vldocmto  LIKE craplcx.vldocmto   
    FIELD nrseqdig  LIKE craplcx.nrseqdig.    

PROCEDURE consulta-lancamento-boletim:
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-operador  AS char.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF OUTPUT PARAM TABLE FOR  tt-lancamento.
           
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
 
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    FOR EACH tt-lancamento:
        DELETE tt-lancamento.
    END.

    FOR EACH  craplcx WHERE craplcx.cdcooper = crapcop.cdcooper     AND
                            craplcx.dtmvtolt = crapdat.dtmvtolt     AND
                            craplcx.cdagenci = p-cod-agencia        AND
                            craplcx.nrdcaixa = p-nro-caixa          AND
                            craplcx.cdopecxa = p-cod-operador       NO-LOCK,
        FIRST craphis WHERE craphis.cdcooper = craplcx.cdcooper     AND
                            craphis.cdhistor = craplcx.cdhistor     NO-LOCK:
        
        CREATE tt-lancamento.
        ASSIGN tt-lancamento.cdcooper = crapcop.cdcooper
               tt-lancamento.controle  = 1
               tt-lancamento.cdhistor  = craplcx.cdhistor      
               tt-lancamento.dshistor  = craphis.dshistor      
               tt-lancamento.dsdcompl  = craplcx.dsdcompl   
               tt-lancamento.nrdocmto  = craplcx.nrdocmto    
               tt-lancamento.vldocmto  = craplcx.vldocmto   
               tt-lancamento.nrseqdig  = craplcx.nrseqdig.
    END.

    RETURN "OK".
END.

/* b1crap09.p */
  
/* ......................................................................... */
        
