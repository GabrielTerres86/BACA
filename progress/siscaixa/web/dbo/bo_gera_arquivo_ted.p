/* .............................................................................

   Programa: Fontes/bo_gera_arquivo_ted.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes   
   Data    : Janeiro/2004                    Ultima atualizacao: 30/08/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Gerar arquivo com TED a fim de ser transmitido via          
               Gerenciador Banco Brasil.

   Alteracoes: 02/03/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
   
               30/08/2010 - Incluido caminho completo na gravacao dos arquivos
                            no diretorio "arq" (Elton).
............................................................................. */

{dbo/bo-erro1.i}

DEF        VAR i-cod-erro    AS INTE                                  NO-UNDO.
DEF        VAR c-desc-erro   AS CHAR                                  NO-UNDO.

DEF        VAR aux_nrconven  AS CHAR                                  NO-UNDO.
DEF        VAR aux_cdsequen  AS INT                                   NO-UNDO.
DEF        VAR aux_cdseqarq  AS INT                                   NO-UNDO.
DEF        VAR aux_nrdolote  AS INTE FORMAT "999999"                  NO-UNDO.
DEF        VAR aux_dtmvtolt  AS CHAR                                  NO-UNDO. 
DEF        VAR aux_qtregarq  AS INT                                   NO-UNDO.
DEF        VAR aux_hrarquiv  AS CHAR                                  NO-UNDO.
DEF        VAR aux_qtdoclot  AS INT                                   NO-UNDO.
DEF        VAR aux_nmarquiv  AS CHAR                                  NO-UNDO.
DEF        VAR aux_vltotlot  AS DECIMAL                               NO-UNDO.
DEF        VAR aux_qtlinarq  AS INT                                   NO-UNDO.
DEF        VAR in99          AS INT                                   NO-UNDO.
DEF        VAR aux_tppessoa  AS INT                                   NO-UNDO.
DEF        VAR aux_digitage  AS CHAR                                  NO-UNDO.
DEF        VAR aux_valor     AS CHAR FORMAT "X(07)"                   NO-UNDO.
DEF        VAR aux_valor2    AS CHAR FORMAT "X(06)"                   NO-UNDO.
                             
DEF STREAM str_1.

PROCEDURE bo_gera_arq_ted:
DEF INPUT  PARAM p-cooper        AS CHAR.
DEF INPUT  PARAM par_cdopecxa    LIKE crapbcx.cdopecxa.
DEF INPUT  PARAM par_cdagenci    LIKE craplcm.cdagenci.
DEF INPUT  PARAM par_nrdcaixa    LIKE craplot.nrdcaixa.
DEF INPUT  PARAM p-registro      AS RECID.

FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

RUN elimina-erro (INPUT p-cooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa).    

FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper  NO-LOCK NO-ERROR.

FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper   AND
                   craptab.nmsistem = "CRED"             AND
                   craptab.tptabela = "GENERI"           AND
                   craptab.cdempres = 00                 AND
                   craptab.cdacesso = "HRTRCOMPEL"       AND
                   craptab.tpregist = par_cdagenci       NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
        ASSIGN i-cod-erro  = 55
               c-desc-erro = " ".
        RUN cria-erro (INPUT p-cooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK". 
     END.  

 IF  INTE(SUBSTR(craptab.dstextab,03,05)) <= TIME   THEN
     DO:
        ASSIGN i-cod-erro  = 676
               c-desc-erro = " ".
        RUN cria-erro (INPUT p-cooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK". 
     END.  
  
FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                   craptab.nmsistem = "CRED"            AND
                   craptab.tptabela = "CONFIG"          AND
                   craptab.cdempres = 00                AND
                   craptab.cdacesso = "COMPELBBDC"      AND
                   craptab.tpregist = 000
                   NO-LOCK NO-ERROR NO-WAIT.

IF   NOT AVAILABLE craptab   THEN
     DO:

        ASSIGN i-cod-erro  = 55
               c-desc-erro = " ".
        RUN cria-erro (INPUT p-cooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK". 
     END.  
                            
ASSIGN aux_nrconven = SUBSTR(craptab.dstextab,1,20)
       aux_cdsequen = INTEGER(SUBSTR(craptab.dstextab,22,06)) 
                     /* Sequencial a  cada Header */
       aux_cdseqarq = INTEGER(SUBSTR(craptab.dstextab,29,06)). 
                      /* Sequencial  arquivo - Zera a cada dia */

ASSIGN aux_cdseqarq = aux_cdseqarq  + 1
       aux_cdsequen = aux_cdsequen  + 1
       aux_nrdolote = 1.
       
ASSIGN aux_dtmvtolt = STRING(DAY(crapdat.dtmvtolt),"99")   +
                      STRING(MONTH(crapdat.dtmvtolt),"99") +
                      STRING(YEAR(crapdat.dtmvtolt),"9999").

ASSIGN aux_qtregarq = 0.

FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper  AND
                   crapage.cdagenci = par_cdagenci      NO-LOCK NO-ERROR.
       
IF   NOT AVAILABLE crapage THEN
     DO:
                        
        ASSIGN i-cod-erro  = 015
               c-desc-erro = " ".
        RUN cria-erro (INPUT p-cooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK". 
     END.  

FIND craptvl WHERE RECID(craptvl) = p-registro EXCLUSIVE-LOCK NO-ERROR.

IF   NOT AVAILABLE craptvl THEN
     DO:
                
        ASSIGN i-cod-erro  = 781
               c-desc-erro = " ".
        RUN cria-erro (INPUT p-cooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK". 
     END.  
                 
ASSIGN aux_qtregarq = 0
       aux_hrarquiv = SUBSTR(STRING(time, "HH:MM:SS"), 1,2) +
                      SUBSTR(STRING(time, "HH:MM:SS"), 4,2) +
                      SUBSTR(STRING(time, "HH:MM:SS"), 7,2)
       aux_nmarquiv = "td" +
                      STRING(craptvl.nrdocmto, "9999999")  + 
                      STRING(DAY(crapdat.dtmvtolt),"99")   + 
                      STRING(MONTH(crapdat.dtmvtolt),"99") +
                      STRING(craptvl.cdagenci, "99") +
                      ".rem".

IF   SEARCH("/usr/coop/" + TRIM(crapcop.dsdircop) +    
            "/arq/" + aux_nmarquiv) <> ?          THEN
     DO:
                          
        ASSIGN i-cod-erro  = 459
               c-desc-erro = " ".
        RUN cria-erro (INPUt p-cooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK". 
     END.  
 
OUTPUT STREAM str_1 TO VALUE("/usr/coop/" + TRIM(crapcop.dsdircop) +  
                             "/arq/" + aux_nmarquiv).
                
/*   Header do Arquivo    */
                
PUT STREAM str_1
                 "00100000"
                 FILL(" ",09)      FORMAT "x(09)"
                 "2"
                 crapcop.nrdocnpj  FORMAT "99999999999999"
                 aux_nrconven      FORMAT "x(20)"
                 crapcop.cdagedbb  FORMAT "999999"
                 crapcop.nrctabbd  FORMAT "9999999999999"
                 " "               FORMAT "x(01)"
                 crapcop.nmrescop  FORMAT "x(30)"
                 "BANCO DO BRASIL"
                 FILL(" ",25)      FORMAT "x(25)"
                 "1"
                 aux_dtmvtolt      FORMAT "x(08)"
                 aux_hrarquiv      FORMAT "x(06)"
                 aux_cdsequen      FORMAT "999999"
                 "03000000"
                 FILL(" ",54)      FORMAT "x(54)" 
                 "000000000000000" SKIP.

ASSIGN aux_qtdoclot = 0
       aux_vltotlot = 0.
                                       
/*   Header do Lote    */
                
ASSIGN  aux_valor2 =  "1C9803".
IF  craptvl.cdbccrc = 1 THEN
    ASSIGN aux_valor2  = "1C9801".  /* BANCO BRASIL */
 
PUT STREAM str_1
                 "001"
                 aux_nrdolote      FORMAT "9999"
                 aux_valor2        FORMAT "x(06)"
                 "020 2"
                 crapcop.nrdocnpj  FORMAT "99999999999999"
                 aux_nrconven      FORMAT "x(20)"
                 crapcop.cdagedbb  FORMAT "999999"
                 crapcop.nrctabbd  FORMAT "9999999999999"
                 " "               FORMAT "x(01)"
                 crapcop.nmrescop  FORMAT "x(30)"
                 FILL(" ",40)      FORMAT "x(40)"
                 crapcop.dsendcop  FORMAT "x(30)"
                 crapcop.nrendcop  FORMAT "99999"
                 FILL(" ",15)      FORMAT "x(15)"
                 crapcop.nmcidade  FORMAT "x(20)"
                 crapcop.nrcepend  FORMAT "99999999" 
                 crapcop.cdufdcop  FORMAT "!(2)"
                 FILL(" ",08)      FORMAT "x(08)" 
                 "0000000000"      SKIP.
       
ASSIGN aux_qtdoclot = aux_qtdoclot + 1
       aux_vltotlot = aux_vltotlot + craptvl.vldocrcb.
       aux_qtregarq = aux_qtregarq + 1.
       
/*--- Pesquisar Agencia do Banco Recebimento(Apenas qdo Transf.) --*/
ASSIGN aux_digitage = " ".

FIND crapagb WHERE crapagb.cdageban = craptvl.cdagercb   AND 
                   crapagb.cddbanco = craptvl.cdbccrcb   NO-LOCK NO-ERROR.

IF  AVAIL crapagb THEN
    ASSIGN aux_digitage = crapagb.dgagenci.
        
ASSIGN aux_valor = "A000018".
IF craptvl.cdbccrcb = 1 THEN        /* BANCO BRASIL */
   ASSIGN aux_valor = "A000000".

PUT STREAM str_1 "001"
                 aux_nrdolote                   FORMAT "9999"
                 "3"
                 aux_qtdoclot                   FORMAT "99999"
                 aux_valor                      FORMAT "x(07)"
                 craptvl.cdbccrcb               FORMAT "999"
/* Ag.s/Digito*/      craptvl.cdagercb               FORMAT "99999"
/* Dig.Agencia*/      aux_digitage                   FORMAT "x(01)"
/* Cta c/Digito */    craptvl.nrcctrcb               FORMAT "9999999999999"
/* Dig.Ag/Conta */   " "                        FORMAT "x(01)"
                 craptvl.nmpesrcb               FORMAT "x(30)"
                 STRING(craptvl.nrdocmto)       FORMAT "x(20)"
                 DAY(craptvl.dtmvtolt)          FORMAT "99"
                 MONTH(craptvl.dtmvtolt)        FORMAT "99"
                 YEAR(craptvl.dtmvtolt)         FORMAT "9999"
                 "BRL"
                 "000000000000000"
                 craptvl.vldocrcb * 100         FORMAT "999999999999999"
                 FILL(" ",20)      FORMAT "x(20)"
                 FILL(" ",8)       FORMAT "x(08)"
                 "000000000000000"
                 FILL(" ",52)      FORMAT "x(52)"
                 "0"
                 "0000000000"      SKIP.

ASSIGN aux_qtdoclot = aux_qtdoclot + 1
       aux_qtregarq = aux_qtregarq + 1.

IF  craptvl.flgpescr = YES THEN   /* Pessoa Fisica */
    ASSIGN aux_tppessoa = 1.
ELSE
    ASSIGN aux_tppessoa = 2.      /* Pessoa Juridica */
            
PUT STREAM str_1 "001"
                 aux_nrdolote                   FORMAT "9999"
                 "3"
                 aux_qtdoclot                   FORMAT "99999"
                 "B   "
                 aux_tppessoa                   FORMAT "9"
                 craptvl.cpfcgrcb               FORMAT "99999999999999"
                 FILL(" ",30)                   FORMAT "x(30)"
                 "00000"                        FORMAT "99999"
                 FILL(" ",50)                   FORMAT "x(50)"
                 "00000"                        FORMAT "99999"
                 "     "                        FORMAT "x(05)"
                 "00000000"                     FORMAT "99999999"
                 "000000000000000"              FORMAT "999999999999999"
                 "000000000000000"              FORMAT "999999999999999"
                 "000000000000000"              FORMAT "999999999999999"
                 "000000000000000"              FORMAT "999999999999999"
                 "000000000000000"              FORMAT "999999999999999"
                 FILL(" ",30)                   FORMAT "x(30)" SKIP.  
 
/*   Trailer do Lote   */

PUT STREAM str_1 "001"
                  aux_nrdolote       FORMAT "9999"
                  "5         "
                  (aux_qtdoclot + 2) FORMAT "999999"
                  (aux_vltotlot * 100)  
                                     FORMAT "999999999999999999"
                  "000000000000000000000000"
                  FILL(" ",165)      FORMAT "x(165)"
                  "0000000000"    SKIP.

ASSIGN   aux_qtlinarq = aux_qtregarq +  2.
                
/*   Trailer do Arquivo   */
                
PUT STREAM str_1 "00199999         "
/* Qtd.Lotes*/    aux_nrdolote        FORMAT "999999"
                  aux_qtlinarq        FORMAT "999999"
                  "000000"
                  FILL(" ",205)       FORMAT "x(205)"  SKIP.
                
OUTPUT STREAM str_1 CLOSE.

ASSIGN craptvl.flgenvio = TRUE.

RELEASE craptvl.       

UNIX SILENT VALUE("ux2dos /usr/coop/" + TRIM(crapcop.dsdircop) +   
                  "/arq/" + aux_nmarquiv + 
                  " > /micros/" + crapcop.dsdircop + 
                  "/compel/" + aux_nmarquiv + " 2>/dev/null").

UNIX SILENT VALUE("mv /usr/coop/" + TRIM(crapcop.dsdircop) +    
                  "/arq/" + aux_nmarquiv + " /usr/coop/" + 
                  TRIM(crapcop.dsdircop) + "/salvar 2>/dev/null").

/*  Gravar Tabela Parametro - Sequencia */

ASSIGN in99 = 0. 
DO  WHILE TRUE:
        
    ASSIGN in99 = in99 + 1.
    
    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper    AND
                       craptab.nmsistem = "CRED"              AND
                       craptab.tptabela = "CONFIG"            AND
                       craptab.cdempres = 00                  AND
                       craptab.cdacesso = "COMPELBBDC"        AND
                       craptab.tpregist = 000
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF   NOT AVAIL   craptab   THEN 
         DO:
            IF   LOCKED craptab   THEN
                 DO:
                    IF  in99 <  100  THEN
                        DO:
                           PAUSE 1 NO-MESSAGE.
                           NEXT.
                        END.
                    ELSE
                        DO:
                           ASSIGN i-cod-erro  = 0
                                  c-desc-erro = "Tabela CRAPTAB em uso ". 
                           RUN cria-erro (INPUT p-cooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT i-cod-erro,
                                          INPUT c-desc-erro,
                                          INPUT YES).
                           RETURN "NOK".
                        END.
                 END.
            ELSE
                 DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro =
                            "Erro Sistema - CRAPTAB nao Encontrado ".    
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                 END.
         END.
    ELSE 
         DO:
          
            ASSIGN craptab.dstextab =
                           SUBSTR(craptab.dstextab,1,20)  + " " +
                           STRING(aux_cdsequen,"999999")  + " " +
                           STRING(aux_cdseqarq,"999999").
            RELEASE craptab.
            LEAVE.
         END.
END.

RETURN "OK".

END PROCEDURE.

