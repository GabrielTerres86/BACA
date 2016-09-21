/* .............................................................................

   Programa: siscaixa/web/dbo/b1crap04.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 22/02/2006.

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Entrega Cartao

   Alteracoes: 31/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)
                            
               22/02/2006 - Unificacao dos bancos - SQLWorks - Eder             
............................................................................ */

/*---------------------------------------------------------------*/
/*  b1crap04.p - Entrega Cartao                                  */
/*---------------------------------------------------------------*/

{dbo/bo-erro1.i}

DEF VAR i-cod-erro  AS INTEGER.
DEF VAR c-desc-erro AS CHAR.

DEF TEMP-TABLE tt-cartao
    FIELD id          AS INTEGER
    FIELD nom-titular AS CHAR FORMAT "x(28)"
    FIELD nro-cartao  AS CHAR FORMAT "9999,9999,9999,9999"
    FIELD situacao    AS CHAR FORMAT "x(30)"
    FIELD d           AS CHAR FORMAT "x(01)" INIT "."
    FIELD rwcrapcrm   AS ROWID.

PROCEDURE consulta-cartao.
   DEF INPUT  PARAM p-cooper    AS CHAR    NO-UNDO.
   DEF INPUT  PARAM p-nro-conta AS INTEGER NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-cartao.

   DEF VAR  i-ident AS INTEGER    NO-UNDO INIT 1.
     
   FIND crapcop WHERE crapcop.nmrescop = p-cooper   NO-LOCK NO-ERROR.
   
   FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                            NO-LOCK NO-ERROR.

   FOR EACH crapcrm WHERE crapcrm.cdcooper = crapcop.cdcooper   AND
                          crapcrm.nrdconta = p-nro-conta        AND
                          crapcrm.cdsitcar < 3                  NO-LOCK:

       IF   crapcrm.cdsitcar = 2                    AND
            crapcrm.dtvalcar < crapdat.dtmvtolt     THEN 
            NEXT.

       CREATE tt-cartao.
       ASSIGN tt-cartao.id          = i-ident
              tt-cartao.nom-titular = string(crapcrm.nmtitcrd,"x(28)")
              tt-cartao.nro-cartao  = STRING(crapcrm.nrcartao,
                                             "9999,9999,9999,9999")
              tt-cartao.situacao    = IF crapcrm.cdsitcar = 1 THEN 
                                         "SOLICITADO" 
                                      ELSE 
                                         "ENTREGUE"
              tt-cartao.rwcrapcrm   = ROWID(crapcrm).

       IF   crapcrm.cdsitcar = 1 THEN
            DO:
                FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper   AND
                                   craptab.nmsistem = "CRED"             AND
                                   craptab.tptabela = "AUTOMA"           AND
                                   craptab.cdempres = 0                  AND
                                   craptab.cdacesso = "CM" + 
                                                      STRING(crapcrm.dtemscar, 
                                                             "99999999") AND  
                                   craptab.tpregist = 0 
                                   NO-LOCK NO-ERROR.

                IF  AVAILABLE craptab THEN
                    ASSIGN tt-cartao.d = IF TRIM(craptab.dstextab) = "1" THEN 
                                            "D" 
                                         ELSE 
                                            ".".
            END.
    
       ASSIGN i-ident = i-ident + 1. 

       IF  tt-cartao.d <> "."  THEN
           ASSIGN tt-cartao.situacao = TRIM(tt-cartao.situacao) + 
                                       "(" + tt-cartao.d + ")".
   END.

END PROCEDURE.
       
/* b1crap04.p */        

/* ......................................................................... */

