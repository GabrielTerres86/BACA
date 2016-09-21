/*.............................................................................

   Programa: fontes/zoom_aplic_blqrgt.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Douglas Quisinski
   Data    : 21/05/2014                         Ultima alteracao:   /  /

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom para seleção de aplicações da tela de BLQRGT
   
   Alteracoes:
   
 ........................................................................... */

{ sistema/generico/includes/b1wgen0148tt.i }
{ sistema/generico/includes/var_internet.i }

DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
DEF  INPUT PARAM par_tpaplica AS INTE                           NO-UNDO.
DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
DEF  INPUT PARAM par_idtipapl AS CHAR                           NO-UNDO.

DEF OUTPUT PARAM par_nraplica AS INTE                           NO-UNDO.

DEF VAR aux_qtregist AS INTE                                    NO-UNDO.
DEF VAR aux_idtipapl AS CHAR                                    NO-UNDO.

DEF VAR h-b1wgen0148 AS HANDLE                                  NO-UNDO.

DEF QUERY  q_aplicacoes FOR tt-aplicacoes.
DEF BROWSE b_aplicacoes QUERY q_aplicacoes
      DISP tt-aplicacoes.dtmvtolt COLUMN-LABEL "Data"
           tt-aplicacoes.nraplica COLUMN-LABEL "Aplicacao" FORMAT "x(10)"
           tt-aplicacoes.sldresga COLUMN-LABEL "Valor"     FORMAT "x(32)"
           WITH CENTERED WIDTH 50 7 DOWN OVERLAY TITLE " Aplicacoes ".

FORM b_aplicacoes HELP "Pressione ENTER para selecionar ou F4 para sair."
          WITH NO-BOX CENTERED OVERLAY ROW 10 FRAME f_aplicacoes.

ON  END-ERROR OF b_aplicacoes
    DO:
        HIDE FRAME f_aplicacoes.
    END.

ON  RETURN OF b_aplicacoes
    DO:
       IF  AVAIL tt-aplicacoes THEN
           DO:
               ASSIGN par_nraplica = INTEGER(tt-aplicacoes.nraplica).

               CLOSE QUERY q_aplicacoes.

               APPLY "END-ERROR" TO b_aplicacoes.
           END.
    END.
    
    RUN sistema/generico/procedures/b1wgen0148.p
        PERSISTENT SET h-b1wgen0148.
    
    RUN lista-aplicacoes IN h-b1wgen0148( INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_cdoperad,
                                          INPUT par_nmdatela,
                                          INPUT 1, /* idorigem = AYLLOS */
                                          INPUT par_nrdconta,
                                          INPUT par_tpaplica,
                                          INPUT 0,  /* nraplica */
                                          INPUT 999999, /* nrregist */
                                          INPUT 0,  /* nriniseq */
                                          INPUT par_cddopcao,
                                          INPUT par_idtipapl,
                                         OUTPUT aux_qtregist,
                                         OUTPUT TABLE tt-aplicacoes,
                                         OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0148.
    
    IF RETURN-VALUE <> "OK" THEN
      RETURN "NOK".

    OPEN QUERY q_aplicacoes FOR EACH tt-aplicacoes NO-LOCK 
                                                   BY tt-aplicacoes.nraplica.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE :
        UPDATE b_aplicacoes WITH FRAME f_aplicacoes.
        LEAVE.
    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            EMPTY TEMP-TABLE tt-aplicacoes.

            HIDE FRAME f_aplicacoes NO-PAUSE.

            CLOSE QUERY q_aplicacoes.
        END.
/* ......................................................................... */


