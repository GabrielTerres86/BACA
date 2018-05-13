/*..............................................................................

    Programa: Fontes/logdda.p
    Sistema : Conta-Corrente - Cooperativa de Credito 
    Sigla   : CRED
    Autor   : David
    Data    : Marco/2011                      Ultima Atualizacao: 24/03/2016
             
    Dados referentes ao programa:
   
    Frequencia: Diario (on-line)
    Objetivo  : Mostrar a tela LOGDDA
                Visualizar log de erros nas transacoes com o servico DDA.
   
    Alteracoes: 24/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).

.............................................................................*/

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0078tt.i }
  
DEF VAR tel_dtmvtlog AS DATE FORMAT "99/99/9999"                       NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_dsderror AS CHAR EXTENT 2                                  NO-UNDO.
DEF VAR aux_qterrdda AS INTE                                           NO-UNDO.

DEF VAR h-b1wgen0078 AS HANDLE                                         NO-UNDO.

DEF QUERY q-logdda FOR tt-logdda.

DEF BROWSE b-logdda QUERY q-logdda
    DISP tt-logdda.hrtransa LABEL "Hora"     FORMAT "x(8)" 
         tt-logdda.nrdconta LABEL "Conta/dv" FORMAT "zzzz,zzz,9"
         tt-logdda.nmprimtl LABEL "Nome"     FORMAT "x(30)"
         tt-logdda.dsreserr LABEL "Erro"     FORMAT "x(23)"
         WITH 10 DOWN NO-BOX CENTERED.

FORM WITH ROW 4 OVERLAY SIZE 80 BY 18 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT 03 LABEL "Opcao"             AUTO-RETURN
        HELP "Informe a opcao desejada (C)."
     tel_dtmvtlog AT 15 LABEL "Data da Transacao" AUTO-RETURN
        HELP "Informe a data de referencia."
     WITH ROW 6 COL 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM b-logdda
     HELP "Tecle <ENTER> para maiores detalhes ou <END> para voltar."
     WITH ROW 8 NO-BOX CENTERED WIDTH 78 OVERLAY FRAME f_logdda.

FORM SKIP(1)
     tt-logdda.dttransa AT 07 LABEL "Data"     FORMAT "99/99/9999" SKIP
     tt-logdda.hrtransa AT 07 LABEL "Hora"     FORMAT "x(8)"       SKIP
     tt-logdda.nrdconta AT 03 LABEL "Conta/dv" FORMAT "zzzz,zzz,9" SKIP
     tt-logdda.nmprimtl AT 07 LABEL "Nome"     FORMAT "x(50)"      SKIP
     tt-logdda.dscpfcgc AT 03 LABEL "CPF/CNPJ" FORMAT "x(18)"      SKIP
     tt-logdda.nmmetodo AT 05 LABEL "Metodo"   FORMAT "x(40)"      SKIP
     tt-logdda.cdderror AT 03 LABEL "Cod.Erro" FORMAT "x(30)"      SKIP
     aux_dsderror[1]    AT 03 LABEL "Des.Erro" FORMAT "x(60)"      SKIP
     aux_dsderror[2]    AT 13 NO-LABEL         FORMAT "x(60)"
     SKIP(1)
     WITH ROW 8 CENTERED WIDTH 78 OVERLAY SIDE-LABELS TITLE "  DETALHAMENTO  " 
         FRAME f_detalhes.

ON RETURN OF b-logdda DO:

    IF  NOT AVAILABLE tt-logdda  THEN
        RETURN.

    ASSIGN aux_dsderror[1] = SUBSTR(tt-logdda.dsderror,1,62)
           aux_dsderror[2] = SUBSTR(tt-logdda.dsderror,63,62).

    DISPLAY tt-logdda.dttransa tt-logdda.hrtransa tt-logdda.nrdconta
            tt-logdda.nmprimtl tt-logdda.dscpfcgc tt-logdda.nmmetodo
            tt-logdda.cdderror aux_dsderror[1]    aux_dsderror[2]
            WITH FRAME f_detalhes.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        PAUSE MESSAGE "Tecle <END>/<F4> para voltar.".
        LEAVE.

    END.

    HIDE FRAME f_detalhes NO-PAUSE.

END.

IF  glb_dsdepart <> "TI"       AND 
    glb_dsdepart <> "CANAIS"   AND
    glb_dsdepart <> "PRODUTOS" AND
    glb_dsdepart <> "COMPE"    THEN
    DO:
        ASSIGN glb_cdcritic = 36.
        RUN fontes/critic.p.
        ASSIGN glb_cdcritic = 0
               glb_nmdatela = "MENU00".
        
        BELL.
        MESSAGE glb_dscritic.
        PAUSE 3 NO-MESSAGE.
        
        RETURN.
    END.

RUN fontes/inicia.p.

VIEW FRAME f_moldura.
PAUSE(0).

ASSIGN glb_cddopcao = "C"
       tel_dtmvtlog = glb_dtmvtolt.

DISPLAY glb_cddopcao tel_dtmvtlog WITH FRAME f_opcao.      

DO WHILE TRUE:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE glb_cddopcao tel_dtmvtlog WITH FRAME f_opcao.

        IF  NOT CAN-DO("C",glb_cddopcao)  THEN
            DO:
                ASSIGN glb_cdcritic = 14.
                RUN fontes/critic.p.
                ASSIGN glb_cdcritic = 0.

                BELL.
                MESSAGE glb_dscritic.

                NEXT-PROMPT glb_cddopcao WITH FRAME f_opcao.
                NEXT.
            END.

        IF  tel_dtmvtlog = ?  THEN
            DO:
                ASSIGN glb_cdcritic = 13.
                RUN fontes/critic.p.
                ASSIGN glb_cdcritic = 0.

                BELL.
                MESSAGE glb_dscritic.

                NEXT-PROMPT tel_dtmvtlog WITH FRAME f_opcao.
                NEXT.
            END.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            RUN fontes/novatela.p.
                       
            IF  CAPS(glb_nmdatela) <> "LOGDDA"  THEN
                DO:
                    HIDE FRAME f_moldura NO-PAUSE.
                    HIDE FRAME f_opcao   NO-PAUSE.
                    HIDE FRAME f_logdda  NO-PAUSE.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao  THEN
        DO:
            { includes/acesso.i }
            
            ASSIGN aux_cddopcao = glb_cddopcao.
        END.

    RUN sistema/generico/procedures/b1wgen0078.p PERSISTENT SET h-b1wgen0078.

    IF  NOT VALID-HANDLE(h-b1wgen0078)  THEN
        DO:
            BELL.
            MESSAGE "Handle invalido para BO b1wgen0078.".
            NEXT.
        END.
        
    RUN lista-erros-dda IN h-b1wgen0078 (INPUT glb_cdcooper, 
                                         INPUT 0, 
                                         INPUT 0, 
                                         INPUT glb_cdoperad, 
                                         INPUT glb_nmdatela, 
                                         INPUT 1, 
                                         INPUT tel_dtmvtlog, 
                                         INPUT 0, 
                                         INPUT 0, 
                                        OUTPUT aux_qterrdda, 
                                        OUTPUT TABLE tt-logdda,
                                        OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0078.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro  THEN
                ASSIGN glb_dscritic = tt-erro.dscritic.
            ELSE
                ASSIGN glb_dscritic = "Nao foi possivel concluir a " +
                                      "requisicao.".

            BELL.
            MESSAGE glb_dscritic.

            NEXT.
        END.

    IF  aux_qterrdda = 0  THEN
        DO:
            BELL.
            MESSAGE "Nenhum registro de erro foi encontrado.".
            NEXT.
        END.

    OPEN QUERY q-logdda FOR EACH tt-logdda NO-LOCK.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE b-logdda WITH FRAME f_logdda.
        LEAVE.                         

    END. /** Fim do DO WHILE TRUE **/
                        
    HIDE FRAME f_logdda NO-PAUSE.
            
    CLOSE QUERY q-logdda.
                    
END. /** Fim do DO WHILE TRUE **/

/*............................................................................*/

