/*.............................................................................

   Programa: fontes/zoom_emprestimos.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel Capoia - DB1
   Data    : Julho/2011                           Ultima alteracao: 21/01/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom para seleção de emprestimos.

   Alteracoes: 24/04/2014 - Adicionado param. de paginacao em procedure
                            obtem-dados-emprestimos em BO 0002.(Jorge)
                            
               28/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074).
               
               21/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)             
 ........................................................................... */

{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/var_internet.i }

DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
DEF OUTPUT PARAM par_nrctremp AS INTE                           NO-UNDO.

DEF VAR h-b1wgen0002 AS HANDLE                                  NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                    NO-UNDO.
DEF VAR aux_vltotrpp AS INTE                                    NO-UNDO.
DEF VAR aux_qtregist AS INTE                                    NO-UNDO.

DEF QUERY  q_crapepr FOR tt-dados-epr.
DEF BROWSE b_crapepr QUERY q_crapepr
      DISP tt-dados-epr.nrctremp COLUMN-LABEL "Contrato"   FORMAT "zz,zzz,zz9"
           tt-dados-epr.dtmvtolt COLUMN-LABEL "Data"       FORMAT "99/99/99" 
           tt-dados-epr.vlemprst COLUMN-LABEL "Emprestado" FORMAT "zzz,zzz,zz9.99"
           tt-dados-epr.qtpreemp COLUMN-LABEL "Parcelas"   FORMAT "zz9"
           tt-dados-epr.vlpreemp COLUMN-LABEL "Valor"      FORMAT "zzz,zzz,zz9.99"
           tt-dados-epr.cdlcremp COLUMN-LABEL "LC"         FORMAT "9999"
           tt-dados-epr.cdfinemp COLUMN-LABEL "Fin"        FORMAT "999"
           WITH CENTERED WIDTH 70 8 DOWN OVERLAY TITLE " Contratos ".

FORM b_crapepr HELP "Pressione ENTER para selecionar ou F4 para sair."
          WITH NO-BOX CENTERED OVERLAY ROW 7 FRAME f_contratos.


ON  END-ERROR OF b_crapepr
    DO:
        HIDE FRAME f_contratos.
    END.

ON  RETURN OF b_crapepr
    DO:
       IF  AVAIL tt-dados-epr THEN
           DO:
               ASSIGN par_nrctremp = tt-dados-epr.nrctremp.
               CLOSE QUERY q_crapepr.

               APPLY "END-ERROR" TO b_crapepr.
           END.
    END.

IF  NOT VALID-HANDLE(h-b1wgen0002)  THEN
    RUN sistema/generico/procedures/b1wgen0002.p
        PERSISTENT SET h-b1wgen0002.

RUN obtem-dados-emprestimos IN h-b1wgen0002
                          ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT "EXTEMP",
                            INPUT 1,  /** origem **/
                            INPUT par_nrdconta,
                            INPUT 1,  /** idseqttl **/
                            INPUT par_dtmvtolt,
                            INPUT par_dtmvtopr,
                            INPUT ?, /*dtcalcul*/
                            INPUT 0, /** Contrato **/
                            INPUT "zoom_emprestimos.p",
                            INPUT par_inproces,
                            INPUT FALSE, /** Log **/
                            INPUT TRUE,
                            INPUT 0, /** nriniseq **/
                            INPUT 0, /** nrregist **/
                           OUTPUT aux_qtregist,
                           OUTPUT TABLE tt-erro,
                           OUTPUT TABLE tt-dados-epr ).

IF  VALID-HANDLE(h-b1wgen0002)  THEN
    DELETE PROCEDURE h-b1wgen0002.

OPEN QUERY q_crapepr FOR EACH tt-dados-epr NO-LOCK 
                                           BY tt-dados-epr.nrctremp.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE :
    UPDATE b_crapepr WITH FRAME f_contratos.
    LEAVE.
END.

IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
    DO:
        EMPTY TEMP-TABLE tt-dados-epr.

        HIDE FRAME f_contratos NO-PAUSE.

        CLOSE QUERY q_crapepr.
    END.
/* ......................................................................... */
