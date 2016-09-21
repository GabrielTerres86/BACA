/* .............................................................................

   Programa: Fontes/email_ted.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Novembro/2002                       Ultima alteracao: 02/03/2006 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de envio de TED ao Financeiro.

   Alteracoes: 02/03/2006 - Unificacao dos bancos - SQLWorks - Fernando
   
               30/08/2010 - Incluido caminho completo na gravacao do arquivo
                            no diretorio "rl"  (Elton).
............................................................................. */

DEF STREAM str_1.

DEF INPUT  PARAM p-cooper     AS CHAR                                NO-UNDO.
DEF INPUT  PARAM par_tpdoctrf AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrdocmto AS INT                                 NO-UNDO.
DEF OUTPUT PARAM par_cdcritic AS INT                                 NO-UNDO.

DEF VAR          rel_dsfinrcb AS CHAR  FORMAT "x(25)"                NO-UNDO.
DEF VAR          rel_dsdctadb AS CHAR  FORMAT "x(25)"                NO-UNDO.
DEF VAR          rel_dsdctacr AS CHAR  FORMAT "x(25)"                NO-UNDO.
DEF VAR          rel_dspessdb AS CHAR  FORMAT "x(25)"                NO-UNDO.
DEF VAR          rel_dspesscr AS CHAR  FORMAT "x(25)"                NO-UNDO.
DEF VAR          rel_dsdagedb AS CHAR  FORMAT "x(30)"                NO-UNDO.
DEF VAR          rel_dsdagecr AS CHAR  FORMAT "x(30)"                NO-UNDO.

DEF VAR          aux_nmarquiv AS CHAR                                NO-UNDO. 
DEF VAR          aux_dsdemail AS CHAR                                NO-UNDO.
DEF VAR          aux_lsdestin AS CHAR                                NO-UNDO.

FIND crapcop NO-LOCK WHERE
     crapcop.nmrescop = p-cooper NO-ERROR.

/*  Dados do DOC/TED ........................................................ */

FIND craptvl WHERE craptvl.cdcooper = crapcop.cdcooper   AND
                   craptvl.tpdoctrf = par_tpdoctrf       AND
                   craptvl.nrdocmto = par_nrdocmto       NO-LOCK NO-ERROR.
                   
IF   NOT AVAILABLE craptvl   THEN
     DO:
         par_cdcritic = 22.
         RETURN.
     END.

ASSIGN rel_dspessdb = IF craptvl.flgpesdb
                         THEN "Pessoa Fisica (F)"
                         ELSE "Pessoa Juridica (J)"
                         
       rel_dspesscr = IF craptvl.flgpescr
                         THEN "Pessoa Fisica (F)"
                         ELSE "Pessoa Juridica (J)".

/*  Dados das agencias ORIGEM/DESTINO........................................ */

FIND crapagb WHERE crapagb.cdageban = 3420 AND
                   crapagb.cddbanco = 001 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapagb   THEN
     DO:
         par_cdcritic = 15.
         RETURN.
     END.

rel_dsdagedb = "- " + crapagb.nmageban.

FIND crapagb WHERE crapagb.cdageban = craptvl.cdagercb   AND 
                   crapagb.cddbanco = craptvl.cdbccrcb   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapagb   THEN
     DO:
         par_cdcritic = 15.
         RETURN.
     END.
    

rel_dsdagecr = "- " + crapagb.nmageban.

/*  Finalidade do DOC/TED ................................................... */

IF   craptvl.tpdoctrf = 1   OR    /* DOC C */
     craptvl.tpdoctrf = 2   THEN  /* DOC D */

     FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                        craptab.nmsistem = "CRED"            AND
                        craptab.tptabela = "GENERI"          AND
                        craptab.cdempres = 00                AND
                        craptab.cdacesso = "FINTRFDOCS"      AND 
                        craptab.tpregist = craptvl.cdfinrcb  NO-LOCK NO-ERROR.
                      
ELSE
     FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                        craptab.nmsistem = "CRED"            AND
                        craptab.tptabela = "GENERI"          AND
                        craptab.cdempres = 00                AND
                        craptab.cdacesso = "FINTRFTEDS"      AND
                        craptab.tpregist = craptvl.cdfinrcb  NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         par_cdcritic = 362.
         RETURN.
     END.
                    
rel_dsfinrcb = craptab.dstextab.

/*  Tipo de Conta Debitada / Creditada ...................................... */
                
IF   craptvl.tpdoctrf = 2   OR     /*  DOC D  */
    (craptvl.tpdoctrf = 3   AND
     NOT craptvl.flgtitul)  THEN
     DO:
         /*  Tipo de Conta Debitada ......................................... */
         
         IF   craptvl.tpdoctrf = 2   THEN  /* DOC D */

              FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                                 craptab.nmsistem = "CRED"            AND
                                 craptab.tptabela = "GENERI"          AND
                                 craptab.cdempres = 00                AND
                                 craptab.cdacesso = "TPCTADBTRF"      AND
                                 craptab.tpregist = craptvl.tpdctadb
                                 NO-LOCK NO-ERROR.
         ELSE
              FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                                 craptab.nmsistem = "CRED"            AND
                                 craptab.tptabela = "GENERI"          AND
                                 craptab.cdempres = 00                AND
                                 craptab.cdacesso = "TPCTADBTED"      AND
                                 craptab.tpregist = craptvl.tpdctadb
                                 NO-LOCK NO-ERROR.   
         
         IF   NOT AVAILABLE craptab   THEN
              DO:
                  par_cdcritic = 017.
                  RETURN.
              END.
                    
         rel_dsdctadb = craptab.dstextab.
 
         /*  Tipo de Conta Creditada ........................................ */
                 
         IF   craptvl.tpdoctrf = 2   THEN  /* DOC D */
              FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                                 craptab.nmsistem = "CRED"            AND
                                 craptab.tptabela = "GENERI"          AND
                                 craptab.cdempres = 00                AND
                                 craptab.cdacesso = "TPCTACRTRF"      AND
                                 craptab.tpregist = craptvl.tpdctacr
                                 NO-LOCK NO-ERROR.
         ELSE
              FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                                 craptab.nmsistem = "CRED"            AND
                                 craptab.tptabela = "GENERI"          AND
                                 craptab.cdempres = 00                AND
                                 craptab.cdacesso = "TPCTACRTED"      AND
                                 craptab.tpregist = craptvl.tpdctacr 
                                 NO-LOCK NO-ERROR.
         
         IF   NOT AVAILABLE craptab   THEN
              DO:
                  par_cdcritic = 017.
                  RETURN.
              END.
                    
         rel_dsdctacr = craptab.dstextab.
     END.

/*  Banco destino ........................................................... */

FIND crapban WHERE crapban.cdbccxlt = craptvl.cdbccrcb NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapban   THEN
     DO:
         par_cdcritic = 017.
         RETURN.
     END.

/*  Dados do lote do TED .................................................... */

FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper   AND
                   craplot.dtmvtolt = craptvl.dtmvtolt   AND
                   craplot.cdagenci = craptvl.cdagenci   AND
                   craplot.cdbccxlt = craptvl.cdbccxlt   AND
                   craplot.nrdolote = craptvl.nrdolote 
                   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craplot   THEN
     DO:
         par_cdcritic = 60.
         RETURN.
     END.

FIND crapope WHERE crapope.cdcooper = crapcop.cdcooper  AND
                   crapope.cdoperad = craplot.cdopecxa  NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapope   THEN
     DO:
         par_cdcritic = 67.
         RETURN.
     END.

/*  Endereco de envio do e-mail ............................................. */

FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                   craptab.nmsistem = "CRED"            AND
                   craptab.tptabela = "CONFIG"          AND
                   craptab.cdempres = 0                 AND
                   craptab.cdacesso = "EMAILDOTED"      AND
                   craptab.tpregist = 0                 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     aux_lsdestin = "edson@viacredi.coop.br".
ELSE
     aux_lsdestin = LC(TRIM(craptab.dstextab)).

/*  Arquivo de saida ........................................................ */
                         
aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + 
               "/rl/TED-" + STRING(craptvl.nrdconta) + "-" +
                            STRING(craptvl.tpdoctrf) + "-" +
                            STRING(craptvl.nrdocmto) + ".txt".

OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv + ".ux").

DISPLAY STREAM str_1
        TRIM(crapcop.nmrescop) + " - " +
        "PROTOCOLO PARA TRANSIMISSAO DE TED VIA SPB" FORMAT "x(80)"      
        SKIP(2)
        "Caixa...................:" craplot.nrdcaixa                     SKIP
        "Autenticacao............:" craptvl.nrautdoc                     SKIP
        "Operador................:" TRIM(craplot.cdoperad) + " - " +
                                    crapope.nmoperad FORMAT "x(44)"      SKIP
        "Data....................:" craplot.dtmvtolt FORMAT "99/99/9999" SKIP
        "Hora....................:" STRING(craptvl.hrtransa,"HH:MM:SS")
        SKIP(2)           
        FILL("-",70) FORMAT "x(70)"
        SKIP(2)
        WITH COLUMN 3 NO-BOX NO-LABELS WIDTH 132 FRAME f_cabecalho.
RUN proc_outros_bancos.

OUTPUT STREAM str_1 CLOSE.

UNIX SILENT VALUE("ux2dos " + aux_nmarquiv + ".ux " +
                  '| tr -d "\032" > ' + aux_nmarquiv).

aux_dsdemail = "Envio de TED da conta " +
               TRIM(STRING(craptvl.nrdconta,"zzzz,zzz,9")).

UNIX SILENT VALUE("cat " + aux_nmarquiv + " | mailx -s " +
                  '"' + aux_dsdemail + '" ' + aux_lsdestin + " &").
UNIX SILENT VALUE("mtsend.pl" + 
                  " --email " + "edson@viacredi.coop.br" + 
                  " --email " + "deborah@viacredi.coop.br" +
                  " --subject " + '"' + aux_dsdemail + '"' + 
                  " --attach " + aux_nmarquiv + " &").
UNIX SILENT VALUE("rm " + aux_nmarquiv + ".ux").
                                                  
/* .......................................................................... */

PROCEDURE proc_outros_bancos:

    IF   NOT craptvl.flgtitul   THEN        /*  STR0009 - Mesma titularidade  */
         DO:
             DISPLAY STREAM str_1
                     "Servico.................: STR"                   SKIP
                     "Codigo Mensagem.........: STR0009"               SKIP(1)
                     "ISPB IF Debitado........: 02038232"              skip
                     "Agencia Debitada........:" crapcop.cdagedbb 
                                                 rel_dsdagedb          skip
                     "Tipo Conta Debitada.....:" rel_dsdctadb          skip
                     "Conta Debitada..........:" craptvl.nrdconta      skip
                     "Tipo Pessoa Debitada....:" rel_dspessdb          skip
                     "CNPJ/CPF Cliente"                                skip
                     "Debitado - Titular 1....:" craptvl.cpfcgemi      skip
                     "Nome Cliente Debitado"                           skip
                     "Titular 1...............:" craptvl.nmpesemi      skip
                     "CNPJ/CPF Cliente"                                skip
                     "Debitado - Titular 2....:" craptvl.cpfsgemi      skip
                     "Nome Cliente Debitado"                           skip
                     "Titular 2...............:" craptvl.nmsegemi      skip
                     "Agencia Creditada.......:" craptvl.cdagercb 
                                                 rel_dsdagecr          skip
                     "ISPB IF Creditada.......:" crapban.nmextbcc      skip
                     "Tipo Conta Creditada....:" rel_dsdctacr          skip
                     "Conta Creditada.........:" craptvl.nrcctrcb      skip
                     "Valor Lancamento........:" craptvl.vldocrcb      skip(1)
                     "Finalidade..............:" rel_dsfinrcb          skip
                     "Historico...............:" 
                          SUBSTR(craptvl.dshistor,001,50) FORMAT "x(50)" skip
                       SPACE(26)
                          SUBSTR(craptvl.dshistor,051,50) FORMAT "x(50)" skip
                       SPACE(26)
                          SUBSTR(craptvl.dshistor,101,50) FORMAT "x(50)" skip
                       SPACE(26)
                          SUBSTR(craptvl.dshistor,151,50) FORMAT "x(50)" skip
                     WITH COLUMN 3 NO-BOX NO-LABELS WIDTH 132
                          FRAME f_outros_mesma_tit.
         END.
    ELSE                              /*  STR0008 - Diferentes titularidades  */
         DO:
             DISPLAY STREAM str_1
                     "Servico.................: STR"                   SKIP
                     "Codigo Mensagem.........: STR0008"               SKIP(1)
                     "ISPB IF Debitado........: 02038232"              skip
                     "Agencia Debitada........:" crapcop.cdagedbb  
                                                 rel_dsdagedb          skip
                     "Tipo Conta Debitada.....:" rel_dsdctadb          skip
                     "Conta Debitada..........:" craptvl.nrdconta      skip
                     "Tipo Pessoa Debitada....:" rel_dspessdb          skip
                     "CNPJ/CPF Debitado.......:" craptvl.cpfcgemi      skip
                     "Nome Cliente Debitado...:" craptvl.nmpesemi      skip
                     "ISPB IF Creditada.......:" crapban.nmextbcc      skip
                     "Agencia Creditada.......:" craptvl.cdagercb 
                                                 rel_dsdagecr          skip
                     "Tipo Conta Creditada....:" rel_dsdctacr          skip
                     "Conta Creditada.........:" craptvl.nrcctrcb      skip
                     "Tipo Pessoa Creditada...:" rel_dspesscr          skip
                     "CNPJ/CPF Creditado......:" craptvl.cpfcgrcb      skip
                     "Nome Cliente Creditado..:" craptvl.nmpesrcb      skip
                     "Valor Lancamento........:" craptvl.vldocrcb      skip(1)
                     "Finalidade..............:" rel_dsfinrcb          skip
                     "Historico...............:" 
                          SUBSTR(craptvl.dshistor,001,50) FORMAT "x(50)" skip
                       SPACE(26)
                          SUBSTR(craptvl.dshistor,051,50) FORMAT "x(50)" skip
                       SPACE(26)
                          SUBSTR(craptvl.dshistor,101,50) FORMAT "x(50)" skip
                       SPACE(26)
                          SUBSTR(craptvl.dshistor,151,50) FORMAT "x(50)" skip
                      WITH COLUMN 3 NO-BOX NO-LABELS WIDTH 132
                           FRAME f_outros_dif_tit.
         END.
         
END PROCEDURE.

/* .......................................................................... */

