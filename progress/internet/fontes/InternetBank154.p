
/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank154.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Daniel Zimmermann
   Data    : Setembro/2015.                       Ultima atualizacao: 08/11/2017
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Busca contratos
   
   Alteracoes: 08/11/2017 - Retornar nome do produto e separar codigo e descricao
                            da linha de credito e finalidade (David).
                            
               29/01/2019 - INC0031641 - Ajustes na exibiçao de contratos de empréstimo
                            com mais de 8 digitos (Jefferson - MoutS)

..............................................................................*/

CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0002 AS HANDLE                                         NO-UNDO.

DEF VAR aux_qtregist AS INTE NO-UNDO.
DEF VAR aux_idemprtr AS INTE NO-UNDO.

DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdagenci AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdoperad AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nmdatela AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_idseqttl AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrcpfope AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_dtmvtopr AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_inproces AS INTE                                  NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT SET h-b1wgen0002.

IF VALID-HANDLE(h-b1wgen0002) THEN
   DO: 
      IF  par_inproces <> 1  THEN
      DO:
          ASSIGN xml_dsmsgerr = "<processo>ERRO</processo>".
          RETURN "NOK".
      END.

      RUN obtem-dados-emprestimos IN h-b1wgen0002
                                 (INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_cdoperad,
                                  INPUT par_nmdatela,
                                  INPUT 3, /* aux_idorigem, */
                                  INPUT par_nrdconta,
                                  INPUT par_idseqttl,
                                  INPUT par_dtmvtolt,
                                  INPUT par_dtmvtopr,
                                  INPUT ?,
                                  INPUT 0, /* aux_nrctremp, */
                                  INPUT "", /* aux_cdprogra, */
                                  INPUT par_inproces,
                                  INPUT FALSE, /*  aux_flgerlog, */
                                  INPUT FALSE, /* aux_flgcondc, */
                                  INPUT 1, /* aux_nriniseq, */
                                  INPUT 9999, /* aux_nrregist, */
                                 OUTPUT aux_qtregist,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-dados-epr).
       
       DELETE PROCEDURE h-b1wgen0002.

       IF RETURN-VALUE = "NOK" THEN
          DO:
              ASSIGN xml_dsmsgerr = "<dsmsgerr>Não foi possível consultar os " +
                                    "contratos.</dsmsgerr>".
              RETURN "NOK".
          END.

       ASSIGN aux_idemprtr = 0.

       CREATE xml_operacao.
       ASSIGN xml_operacao.dslinxml = "<EMPRESTIMOS>".

       FOR EACH tt-dados-epr 
           WHERE tt-dados-epr.vlsdeved > 0 NO-LOCK:

           IF tt-dados-epr.dtmvtolt = par_dtmvtolt THEN
               NEXT.

           IF tt-dados-epr.tpemprst = 1 THEN
           DO:
            CREATE xml_operacao.
            ASSIGN xml_operacao.dslinxml =  "<EMPRESTIMO>"
                   + "<nrctremp>" + TRIM(STRING(tt-dados-epr.nrctremp,"zzz,zzz,zzz,zz9")) + "</nrctremp>" 
                   + "<qtpreemp>" + STRING(tt-dados-epr.qtpreemp,"zz9") + "</qtpreemp>"
                   + "<vlemprst>" + TRIM(STRING(tt-dados-epr.vlemprst,"zzz,zzz,zzz,zz9.99")) + "</vlemprst>"
                   + "<vlpreemp>" + STRING(tt-dados-epr.vlpreemp,"zzz,zzz,zzz,zz9.99") + "</vlpreemp>"
                   + "<vlsdeved>" + TRIM(STRING(tt-dados-epr.vlsdeved,"zzz,zzz,zzz,zz9.99")) + "</vlsdeved>"
                   + "<dtmvtolt>" + STRING(tt-dados-epr.dtmvtolt,"99/99/9999") + "</dtmvtolt>"     
                   + "<nmprimtl>" + TRIM(tt-dados-epr.nmprimtl) + "</nmprimtl>"       
                   + "<qtprecal>" + TRIM(STRING(tt-dados-epr.qtprecal,"zzz,zz9.9999-")) + "</qtprecal>"
                   + "<dslcremp>" + TRIM(tt-dados-epr.dslcremp) + "</dslcremp>"
                   + "<dsfinemp>" + TRIM(tt-dados-epr.dsfinemp) + "</dsfinemp>"
                   + "<tpemprst>" + STRING(tt-dados-epr.tpemprst,"9") + "</tpemprst>"
                   + "<flgpreap>" + STRING(tt-dados-epr.flgpreap) + "</flgpreap>"
                   + "<cdorigem>" + STRING(tt-dados-epr.cdorigem) + "</cdorigem>"
                   + "<diavenct>" + STRING(DAY(tt-dados-epr.dtdpagto)) + "</diavenct>"
                         + "<dsprodut>" + (IF tt-dados-epr.tpemprst = 1 THEN "Price Pré-Fixado" ELSE IF tt-dados-epr.tpemprst = 2 THEN "Price Pós-Fixado" ELSE "Price TR") + "</dsprodut>"
                   + "<qtpreres>" + STRING(tt-dados-epr.qtpreemp - tt-dados-epr.qtprecal) + "</qtpreres>"
                         + "<cddlinha>" + STRING(tt-dados-epr.cdlcremp) + "</cddlinha>"
                         + "<dsdlinha>" + TRIM(SUBSTR(tt-dados-epr.dslcremp,INDEX(tt-dados-epr.dslcremp,"-",1) + 1)) + "</dsdlinha>" 
                         + "<cdfinali>" + STRING(tt-dados-epr.cdfinemp) + "</cdfinali>"
                         + "<dsfinali>" + TRIM(SUBSTR(tt-dados-epr.dsfinemp,INDEX(tt-dados-epr.dsfinemp,"-",1) + 1)) + "</dsfinali>"
                         + "<inproces>" + (IF par_inproces = 1 THEN "1" ELSE "0") + "</inproces>"
                   + "</EMPRESTIMO>".
            END.

            IF tt-dados-epr.tpemprst = 0 THEN
            ASSIGN aux_idemprtr = 1.

       END.

       CREATE xml_operacao.
       ASSIGN xml_operacao.dslinxml = "</EMPRESTIMOS>"
                                    + "<idemprtr>" + STRING(aux_idemprtr) + "</idemprtr>".
       
       RETURN "OK".
   END.

/*...........................................................................*/

