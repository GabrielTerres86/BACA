/*.............................................................................

   Programa: fontes/zoom_poupanca.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel Capoia - DB1
   Data    : Julho/2011                           Ultima alteracao: 00/00/0000

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom para seleção de contrato de poupança programada.

   Alteracoes:
 ........................................................................... */

{ sistema/generico/includes/b1wgen0006tt.i }
{ sistema/generico/includes/var_internet.i }

DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
DEF OUTPUT PARAM par_nrctrrpp AS INTE                           NO-UNDO.

DEF VAR h-b1wgen0006 AS HANDLE                                   NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                     NO-UNDO.
DEF VAR aux_vltotrpp AS INTE                                     NO-UNDO.

DEF QUERY  q_craprpp FOR tt-dados-rpp.
DEF BROWSE b_craprpp QUERY q_craprpp
      DISP tt-dados-rpp.dtmvtolt COLUMN-LABEL "Data movto."
           tt-dados-rpp.nrctrrpp COLUMN-LABEL "Poup. Programada"
           tt-dados-rpp.indiadeb COLUMN-LABEL "Dia debito"
           tt-dados-rpp.vlprerpp COLUMN-LABEL "Vl. Prestacao"
           WITH 9 DOWN OVERLAY TITLE " Poupanca Programada ".

FORM b_craprpp HELP "Pressione ENTER para selecionar ou F4 para sair."
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_poupanca.


ON  END-ERROR OF b_craprpp
    DO:
        HIDE FRAME f_poupanca.
    END.

ON  RETURN OF b_craprpp
    DO:
       IF  AVAIL tt-dados-rpp THEN
           DO:
               ASSIGN par_nrctrrpp = tt-dados-rpp.nrctrrpp.
               CLOSE QUERY q_craprpp.

               APPLY "END-ERROR" TO b_craprpp.
           END.
    END.


    IF  NOT VALID-HANDLE(h-b1wgen0006)  THEN
        RUN sistema/generico/procedures/b1wgen0006.p
            PERSISTENT SET h-b1wgen0006.

    RUN consulta-poupanca IN h-b1wgen0006 
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,
                          INPUT par_nrctrrpp,
                          INPUT par_dtmvtolt,
                          INPUT par_dtmvtopr,
                          INPUT par_inproces,
                          INPUT par_cdprogra,
                          INPUT FALSE, /* flgerlog */
                         OUTPUT aux_vltotrpp,
                         OUTPUT TABLE tt-erro,
                         OUTPUT TABLE tt-dados-rpp ).
    
    IF  VALID-HANDLE(h-b1wgen0006)  THEN
        DELETE PROCEDURE h-b1wgen0006.
    
    OPEN QUERY q_craprpp FOR EACH tt-dados-rpp NO-LOCK.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE :
        UPDATE b_craprpp WITH FRAME f_poupanca.
        LEAVE.
    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            EMPTY TEMP-TABLE tt-dados-rpp.

            HIDE FRAME f_poupanca NO-PAUSE.

            CLOSE QUERY q_craprpp.
        END.
/* ......................................................................... */





