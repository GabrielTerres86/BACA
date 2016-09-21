/* ............................................................................

   Programa: fontes/prcbnd.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fabricio
   Data    : Maio/2013                      Ultima atualizacao: 26/07/2013
         
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Importar arquivos BNDES.

   Alteracoes: 26/07/2013 - Removido temporariamente a opcao
                            "Liquidar/Estornar Parcela". (Fabricio)
               
............................................................................. */

{ includes/var_batch.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0147tt.i }

DEF STREAM str_1.

DEF VAR h-b1wgen0147 AS HANDLE NO-UNDO.

DEF VAR aux_cddopcao AS CHAR            NO-UNDO.
DEF VAR aux_nmdirarq AS CHAR            NO-UNDO.
DEF VAR aux_dtmvtolt AS CHAR            NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR            NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!" NO-UNDO.

DEF VAR tel_tipopera AS CHAR FORMAT "x(25)"
               VIEW-AS COMBO-BOX LIST-ITEMS "Atualizar Operacoes",
                                           /* "Liquidar/Estornar Parcela", */
                                            "Central de Risco"
                                            PFCOLOR 2                NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT 03 LABEL "Opcao"         AUTO-RETURN
                       VALIDATE (glb_cddopcao = "I",
                                 "014 - Opcao errada.")
        HELP "Informe a opcao desejada (I)."
    WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_opcao.

FORM tel_tipopera AT 03 LABEL "Tipo de Operacao"
        HELP "Informe o tipo de operacao"
    WITH ROW 6 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_tipopera.

ON RETURN OF tel_tipopera
DO:
    APPLY "GO".
END.

VIEW FRAME f_moldura.

PAUSE(0).

ASSIGN glb_cddopcao = ""
       aux_nmdirarq = "/micros/cecred/bndes/recepcao/"
       aux_dtmvtolt = STRING(YEAR(glb_dtmvtolt), "9999") +
                      STRING(MONTH(glb_dtmvtolt), "99")  +
                      STRING(DAY(glb_dtmvtolt), "99").

DO WHILE TRUE:

    RUN fontes/inicia.p.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        HIDE FRAME f_tipopera.

        UPDATE glb_cddopcao WITH FRAME f_opcao.

        LEAVE.

    END.

    IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
    DO:
        RUN fontes/novatela.p.

        IF glb_nmdatela <> "prcbnd" THEN
        DO:
            RETURN.
        END.
        ELSE
            NEXT.
    END.

    IF aux_cddopcao <> glb_cddopcao THEN
    DO:
        { includes/acesso.i }
            
        ASSIGN aux_cddopcao = glb_cddopcao.
    END.

    ASSIGN aux_nmarquiv = "".

    DISPLAY glb_cddopcao WITH FRAME f_opcao.

    UPDATE tel_tipopera WITH FRAME f_tipopera.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        ASSIGN aux_confirma = "N".
                   
        MESSAGE "Confirma a operacao? S/N:" UPDATE aux_confirma.

        LEAVE.

    END.

    IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR aux_confirma <> "S" THEN
    DO:
        HIDE MESSAGE NO-PAUSE.
        MESSAGE "Operacao nao efetuada!".
        NEXT.
    END.

    RUN sistema/generico/procedures/b1wgen0147.p PERSISTENT SET h-b1wgen0147.

    IF NOT VALID-HANDLE(h-b1wgen0147) THEN
    DO:
        BELL.
        MESSAGE "HANDLE invalido para BO b1wgen9090.".
        PAUSE 3 NO-MESSAGE.
        RETURN.
    END.

    MESSAGE "Processando arquivo(s) ...".

    CASE tel_tipopera:SCREEN-VALUE:
        
        WHEN "Atualizar Operacoes" THEN
        DO:
            RUN busca-arquivos IN h-b1wgen0147 (INPUT aux_nmdirarq         + 
                                                "OPERACOES" +
                                                STRING(DAY(glb_dtmvtolt), "99") +
                                                STRING(MONTH(glb_dtmvtolt), "99")
                                                + ".*",
                                               OUTPUT TABLE tt-arq-imp).
            IF RETURN-VALUE = "NOK" THEN
            DO:
                MESSAGE "Nao existe arquivo para integrar.".
                PAUSE 5 NO-MESSAGE.
                RETURN.
            END.
            
            RUN atualiza-operacoes IN h-b1wgen0147 (INPUT glb_cdagenci,
                                                    INPUT 0, /* nrdcaixa */
                                                    INPUT glb_cdoperad,
                                                    INPUT glb_dtmvtolt,
                                                    INPUT glb_dtmvtopr,
                                                    INPUT TABLE tt-arq-imp,
                                                   OUTPUT TABLE tt-erro).

        END.

        WHEN "Liquidar/Estornar Parcela" THEN
        DO:

            RUN busca-arquivos IN h-b1wgen0147 (INPUT aux_nmdirarq + 
                                                      "BAIXA_PARCELAS" +
                                                STRING(DAY(glb_dtmvtolt), "99") +
                                                STRING(MONTH(glb_dtmvtolt), "99")
                                                + ".*",
                                               OUTPUT TABLE tt-arq-imp).

            IF RETURN-VALUE = "NOK" THEN
            DO:
                MESSAGE "Nao existe arquivo para integrar.".
                PAUSE 5 NO-MESSAGE.
                RETURN.
            END.

            RUN liquida-parcela IN h-b1wgen0147 (INPUT glb_cdagenci,
                                                 INPUT 0, /* nrdcaixa */
                                                 INPUT glb_dtmvtolt,
                                                 INPUT glb_cdoperad,
                                                 INPUT TABLE tt-arq-imp,
                                                OUTPUT TABLE tt-erro).
        END.

        WHEN "Central de Risco" THEN
        DO:
            RUN busca-arquivos IN h-b1wgen0147 (INPUT aux_nmdirarq + 
                                                "CENTRAL_RIS" + 
                                           STRING(DAY(glb_dtmvtolt), "99")   +
                                           STRING(MONTH(glb_dtmvtolt), "99") +
                                                ".*",
                                               OUTPUT TABLE tt-arq-imp).

            IF RETURN-VALUE = "NOK" THEN
            DO:
                MESSAGE "Nao existe arquivo para integrar.".
                PAUSE 5 NO-MESSAGE.
                RETURN.
            END.

            RUN atualiza-central-risco IN h-b1wgen0147(INPUT glb_cdagenci,
                                                       INPUT 0, /* nrdcaixa */
                                                       INPUT glb_cdoperad,
                                                       INPUT TABLE tt-arq-imp,
                                                      OUTPUT TABLE tt-erro).
        END.

    END CASE.

    DELETE PROCEDURE h-b1wgen0147.

    IF RETURN-VALUE <> "OK" THEN
    DO:
        MESSAGE "Arquivo(s) processado(s) com erros. Verifique o log.".
        PAUSE 5 NO-MESSAGE.
        RETURN.
    END.
    ELSE
    DO:
        MESSAGE "Arquivo(s) processado(s) com sucesso.".
        PAUSE 5 NO-MESSAGE.
        RETURN.
    END.

END.
