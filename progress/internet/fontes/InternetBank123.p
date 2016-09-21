/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank123.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : James Prust Junior
   Data    : Setembro/2014.                       Ultima atualizacao: 18/01/2016
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Calcula a taxa da operacao do credito pre-aprovado
   
   Alteracoes: 18/01/2016 - Adicionar parâmetro vlliquid na chamada da BO188
                            e retorno da mesma no xml (Anderson).

..............................................................................*/

CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0188tt.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0188 AS HANDLE                                         NO-UNDO.

DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdagenci AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdoperad AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nmdatela AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_vlemprst AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_vlparepr AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_nrparepr AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dtvencto AS DATE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_vlrtarif LIKE crapepr.vltarifa                             NO-UNDO.
DEF VAR aux_percetop LIKE crawepr.percetop                             NO-UNDO.
DEF VAR aux_vltaxiof LIKE crapepr.vltaxiof                             NO-UNDO.
DEF VAR aux_vltariof LIKE crapepr.vltariof                             NO-UNDO.
DEF VAR aux_vlliquid AS DECI                                           NO-UNDO.

RUN sistema/generico/procedures/b1wgen0188.p PERSISTENT SET h-b1wgen0188.
                
IF VALID-HANDLE(h-b1wgen0188) THEN
   DO: 
       RUN calcula_taxa_emprestimo IN h-b1wgen0188 (INPUT par_cdcooper,
                                                    INPUT par_cdagenci,
                                                    INPUT par_nrdcaixa,
                                                    INPUT par_cdoperad,
                                                    INPUT par_nmdatela,
                                                    INPUT 3, /* par_cdorigem */
                                                    INPUT par_nrdconta,
                                                    INPUT par_dtmvtolt,
                                                    INPUT par_vlemprst,
                                                    INPUT par_vlparepr,
                                                    INPUT par_nrparepr,
                                                    INPUT par_dtvencto,
                                                    OUTPUT aux_vlrtarif,
                                                    OUTPUT aux_percetop,
                                                    OUTPUT aux_vltaxiof,
                                                    OUTPUT aux_vltariof,
                                                    OUTPUT aux_vlliquid,
                                                    OUTPUT TABLE tt-erro).
       
       DELETE PROCEDURE h-b1wgen0188.
       IF RETURN-VALUE <> "OK" THEN
          DO:
              ASSIGN xml_dsmsgerr = "<dsmsgerr>Não foi possível calcular as " +
                                    "taxas do crédito pré-aprovado.</dsmsgerr>".
              RETURN "NOK".
          END.

       CREATE xml_operacao.
       ASSIGN xml_operacao.dslinxml = 
          "<DADOS>"      +
            "<vlrtarif>" + STRING(aux_vlrtarif,"zzz,zzz,zz9.99-")   + "</vlrtarif>" +
            "<percetop>" + STRING(aux_percetop,"zzz,zzz,zz9.99-")   + "</percetop>" +
            "<vltaxiof>" + STRING(aux_vltaxiof,"zzz,zzz,zz9.9999-") + "</vltaxiof>" +
            "<vltariof>" + STRING(aux_vltariof,"zzz,zzz,zz9.99-")   + "</vltariof>" +
            "<vlliquid>" + STRING(aux_vlliquid,"zzz,zzz,zz9.99-")   + "</vlliquid>" +
          "</DADOS>".

       RETURN "OK".
       
   END.

/*...........................................................................*/
