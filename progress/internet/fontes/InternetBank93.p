/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank93.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : James Prust Junior
   Data    : Agosto/2014.                       Ultima atualizacao: 21/02/2019
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Imprime o extrato de contratacao
   
   Alteracoes: 09/04/2018 - Ajuste para que o caixa eletronico possa utilizar o mesmo
                            servico da conta online (PRJ 363 - Rafael Muniz Monteiro)
							
			   21/02/2019 - P442 - Passar vazio em campos da aprovacao 
                            quando somente previa (Marcos-Envolti)

..............................................................................*/

CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0188tt.i }
{ sistema/generico/includes/var_internet.i }

DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdagenci AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdoperad AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nmdatela AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_idseqttl AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_nrctremp AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_vlemprst AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_txmensal AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_qtpreemp AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_vlpreemp AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_percetop AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_vlrtarif AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_dtdpagto AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_vltaxiof AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_vltariof AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_flgprevi AS LOG                                   NO-UNDO.
/* Projeto 363 - Novo ATM */
DEF  INPUT PARAM par_cdorigem AS INT                                   NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR par_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_setlinha AS CHAR    FORMAT "x(200)"                        NO-UNDO.
DEF VAR aux_setlinha_1 AS CHAR  FORMAT "x(200)"                        NO-UNDO.
DEF VAR h-b1wgen0188 AS HANDLE                                         NO-UNDO.

DEF STREAM str_1.

IF NOT VALID-HANDLE(h-b1wgen0188) THEN
   RUN sistema/generico/procedures/b1wgen0188.p PERSISTENT SET h-b1wgen0188.
                
IF VALID-HANDLE(h-b1wgen0188) THEN
   DO: 
       /* Verifica se imprime a previa com os campos na tela ou 
          imprime com os dados que estao gravados */ 
       IF par_flgprevi THEN
          DO:
              RUN imprime_previa_demonstrativo IN h-b1wgen0188 
                                                        (INPUT par_cdcooper,
                                                         INPUT par_cdagenci,
                                                         INPUT par_nrdcaixa,
                                                         INPUT par_cdoperad,
                                                         INPUT par_nmdatela,
                                                         INPUT 3, /* par_cdorigem */
                                                         INPUT par_nrdconta,
                                                         INPUT par_idseqttl,
                                                         INPUT par_dtmvtolt,
                                                         INPUT 0, /* par_nrctremp */
                                                         INPUT par_vlemprst,
                                                         INPUT par_txmensal,
                                                         INPUT par_qtpreemp,
                                                         INPUT par_vlpreemp,
                                                         INPUT par_percetop,
                                                         INPUT par_vlrtarif,
                                                         INPUT par_dtdpagto,
                                                         INPUT par_vltaxiof,
                                                         INPUT par_vltariof,
                                                         INPUT ?,
                                                         INPUT 0,
                                                         OUTPUT par_nmarqimp,
                                                         OUTPUT TABLE tt-erro).
          END. /* END IF par_flgprevi THEN */
       ELSE
          DO:
              RUN imprime_demonstrativo IN h-b1wgen0188 (INPUT par_cdcooper,
                                                         INPUT par_cdagenci,
                                                         INPUT par_nrdcaixa,
                                                         INPUT par_cdoperad,
                                                         INPUT par_nmdatela,
                                                         INPUT par_cdorigem, /* Projeto 363 - Novo ATM -> estava fixo 3,*/ /* par_cdorigem */
                                                         INPUT par_nrdconta,
                                                         INPUT par_idseqttl,
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_nrctremp,
                                                         OUTPUT par_nmarqimp,
                                                         OUTPUT TABLE tt-erro).
          END.
       
       DELETE PROCEDURE h-b1wgen0188.
       IF RETURN-VALUE = "NOK" THEN
          DO:
              ASSIGN xml_dsmsgerr = "<dsmsgerr>Não foi possível imprimir o " +
                                    "crédito pré-aprovado.</dsmsgerr>".
              RETURN "NOK".
          END.

       /* Le o arquivo formatado */
       INPUT STREAM str_1 FROM VALUE(par_nmarqimp) NO-ECHO.

       CREATE xml_operacao.
       ASSIGN xml_operacao.dslinxml = "<DADOS><PARAGRAFO>".

       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

          IMPORT STREAM str_1 UNFORMATTED aux_setlinha.

          IF aux_setlinha = "" THEN
             DO:
                 CREATE xml_operacao.
                 ASSIGN xml_operacao.dslinxml = "</PARAGRAFO><PARAGRAFO>".
             END.
          ELSE
             DO:
                 CREATE xml_operacao.
                 ASSIGN xml_operacao.dslinxml = "<conteudo>" + aux_setlinha + "</conteudo>".
             END.

       END.   /*  Fim do DO WHILE TRUE  */

       INPUT STREAM str_1 CLOSE.

       CREATE xml_operacao.
       ASSIGN xml_operacao.dslinxml = "</PARAGRAFO></DADOS>".

       RETURN "OK".
       
   END.

/*...........................................................................*/