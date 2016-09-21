/* .............................................................................

   Programa: Fontes/natura.p.
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                     Ultima atualizacao: 16/04/2010

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas (on-line)
   Objetivo  : Mostrar a lista de naturalidades disponiveis.
   
   Alteracoes: 20/05/2008 - Recriada a estrutura da tela porque estava
                            ocorrendo estouro de variaveis (Evandro).
                            
               16/04/2010 - Adaptado para uso de BO (Jose Luis, DB1)
               
               16/12/2013 - Inclusao de VALIDATE crapnat (Carlos)
                            
............................................................................. */

{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM}
{ includes/gg0000.i}

DEF OUTPUT PARAM par_dsnatura   LIKE crapnat.dsnatura                 NO-UNDO.

DEF VAR aux_dsdbusca            AS CHAR                               NO-UNDO.
DEF VAR p_cddopcao              AS CHAR  INIT "I"                     NO-UNDO.
DEF VAR p_dsnatnac              AS CHAR  INIT ""                      NO-UNDO.

DEF BUFFER crabnat FOR crapnat.

DEF QUERY q_natura FOR tt-crapnat.

DEF BROWSE b_natura QUERY q_natura
    DISPLAY tt-crapnat.dsnatura   NO-LABEL   FORMAT "x(25)"
    WITH 11 DOWN NO-BOX.

FORM b_natura  HELP "Escolha com as setas, pgant, pgseg e tecle <Entra>"
     WITH ROW 6 COLUMN 49 OVERLAY SIDE-LABELS TITLE " Naturalidades "
          FRAME f_natura.

FORM aux_dsdbusca                         FORMAT "x(29)"
     WITH ROW 19 COLUMN 49 OVERLAY NO-LABEL FRAME f_busca.

FORM p_cddopcao FORMAT "x"     LABEL "Opcao" AUTO-RETURN
                               HELP "Informe a opcao: I-Incluir / E-Excluir"
                               VALIDATE(p_cddopcao = "I" OR p_cddopcao = "E",
                                        "014 - Opcao errada")
     p_dsnatnac FORMAT "x(25)" LABEL "  Descricao"
                               VALIDATE(p_dsnatnac <> "","Deve ser informada")
     WITH ROW 10 SIDE-LABELS TITLE " Manutencao das Naturalidades " OVERLAY
          FRAME f_alt_natura.

ON 'CLEAR':U OF b_natura
DO:
    RUN Processa_Natura.
    RETURN NO-APPLY.
END.

ON ANY-KEY OF b_natura IN FRAME f_natura DO:

   IF   KEYFUNCTION(LASTKEY) = "RETURN"   AND
        AVAILABLE tt-crapnat                 THEN
        DO:
            par_dsnatura = tt-crapnat.dsnatura.
            APPLY "GO".
        END.
   ELSE
   IF   (LASTKEY >= 65 AND LASTKEY <= 90)    OR    /* Letras Maiusculas */
        (LASTKEY >= 97 AND LASTKEY <= 122)   THEN  /* Letras Minusculas */
        DO:
            aux_dsdbusca = aux_dsdbusca + KEYFUNCTION(LASTKEY).

            DISPLAY aux_dsdbusca WITH FRAME f_busca.

            FIND FIRST tt-crapnat WHERE tt-crapnat.dsnatura BEGINS aux_dsdbusca
                               NO-LOCK NO-ERROR.

            IF   AVAILABLE tt-crapnat   THEN
                 REPOSITION q_natura TO ROWID ROWID(tt-crapnat).
        END.
   ELSE
        DO:
            aux_dsdbusca = "".
            HIDE FRAME f_busca NO-PAUSE.
        END.
END.

IF  NOT aux_fezbusca THEN
    DO:
       RUN Busca_Dados.
       ASSIGN aux_fezbusca = YES.
    END.

MESSAGE "Tecle F8 para manutencao das Naturalidades".
OPEN QUERY q_natura FOR EACH tt-crapnat. 

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    UPDATE b_natura WITH FRAME f_natura
    EDITING:          
        READKEY PAUSE 1.
        
        /* se nao teclar nada oculta a busca */
        IF   LASTKEY = -1   THEN
             DO:
                aux_dsdbusca = "".
                HIDE FRAME f_busca NO-PAUSE.
             END.
        
        APPLY LASTKEY.
    END.

    LEAVE.

END.

HIDE FRAME f_natura     NO-PAUSE.
HIDE FRAME f_busca      NO-PAUSE.
HIDE FRAME f_alt_natura NO-PAUSE.

/* .......................................................................... */
PROCEDURE Busca_Dados:

    /* Verifica se o banco generico ja esta conectado */
    ASSIGN aux_flggener = f_verconexaogener().

    IF  aux_flggener OR f_conectagener()  THEN
        DO:
            IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
                RUN sistema/generico/procedures/b1wgen0059.p
                    PERSISTENT SET h-b1wgen0059.

            RUN busca-crapnat IN h-b1wgen0059
                ( INPUT "",
                  INPUT 999999,
                  INPUT 1,
                 OUTPUT aux_qtregist,
                 OUTPUT TABLE tt-crapnat ).

            DELETE PROCEDURE h-b1wgen0059.

            IF  NOT aux_flggener  THEN
                RUN p_desconectagener.
        END.

END PROCEDURE.

PROCEDURE Processa_Natura:

    HIDE MESSAGE NO-PAUSE.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       UPDATE p_cddopcao p_dsnatnac WITH FRAME f_alt_natura.

       DO WHILE TRUE:

          FIND crapnat WHERE crapnat.dsnatura = p_dsnatnac
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF   NOT AVAILABLE crapnat   THEN
               IF   LOCKED crapnat   THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
          LEAVE.
       END.
       
       IF   NOT AVAILABLE crapnat   THEN
            DO:
                IF   p_cddopcao = "E"   THEN
                     DO:
                         MESSAGE "Naturalidade nao existente".
                         NEXT.
                     END.
                ELSE
                IF   p_cddopcao = "I"   THEN
                     DO:
                         p_dsnatnac = CAPS(p_dsnatnac).

                         CREATE crapnat.
                         ASSIGN crapnat.dsnatura =  p_dsnatnac.
                         VALIDATE crapnat.
                     END.
            END.
       ELSE
            DO:
                IF   p_cddopcao = "I"   THEN
                     DO:
                         MESSAGE "Naturalidade ja existente".
                         NEXT.
                     END.
                ELSE
                     DELETE crapnat.
            END.
       
       LEAVE.
    END.  /*  Fim do DO WHILE TRUE  */

    RUN Busca_Dados.

    /* Atualiza a lista de naturalidades */
    CLOSE QUERY q_natura.
    OPEN QUERY q_natura FOR EACH tt-crapnat NO-LOCK.
    MESSAGE "Tecle F8 para manutencao das Naturalidades".

    HIDE FRAME f_alt_natura NO-PAUSE.

END PROCEDURE
