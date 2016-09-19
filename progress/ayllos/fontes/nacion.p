/* .............................................................................

   Programa: Fontes/nacion.p.
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Setembro/91                      Ultima atualizacao: 22/10/2014

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Mostrar a lista de Nacionalidades disponiveis.
   
   Alteracoes: 07/05/2010 - Reestruturado para uso de BO (Jose Luis, DB1)
   
               13/05/2011 - Retirada mensagem repetida. (André - DB1)

               12/04/2013 - Desabilitada opcao "F8" para manutencao
                            das nacionalidades (Daniele).
                            
               22/10/2014 - Habilitado a opção "F8", onde é possível inserir
                            novas nacionalidades.
............................................................................. */

{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM }
{ includes/gg0000.i}

DEF SHARED VAR shr_dsnacion AS CHAR                                   NO-UNDO.

DEF VAR aux_dsdbusca            AS CHAR                               NO-UNDO.
DEF VAR p_cddopcao              AS CHAR  INIT "I"                     NO-UNDO.
DEF VAR p_dsnatnac              AS CHAR  INIT ""                      NO-UNDO.

DEF BUFFER crabnac FOR crapnac.

DEF QUERY q_nacion FOR tt-crapnac.

DEF BROWSE b_nacion QUERY q_nacion
    DISPLAY tt-crapnac.dsnacion   NO-LABEL   FORMAT "x(25)"
    WITH 11 DOWN NO-BOX.

FORM b_nacion  HELP "Escolha com as setas, pgant, pgseg e tecle <Entra>"
     WITH ROW 6 COLUMN 49 OVERLAY SIDE-LABELS TITLE " Nacionalidades "
          FRAME f_nacion.

FORM aux_dsdbusca                         FORMAT "x(29)"
     WITH ROW 19 COLUMN 49 OVERLAY NO-LABEL FRAME f_busca.

FORM p_cddopcao FORMAT "x"     LABEL "Opcao" AUTO-RETURN
                               HELP "Informe a opcao: I-Incluir / E-Excluir"
                               VALIDATE(p_cddopcao = "I" OR p_cddopcao = "E",
                                        "014 - Opcao errada")
     p_dsnatnac FORMAT "x(25)" LABEL "  Descricao"
                               VALIDATE(p_dsnatnac <> "","Deve ser informada")
     WITH ROW 10 SIDE-LABELS TITLE " Manutencao das Nacionalidades " OVERLAY
          FRAME f_alt_nacion.


ON 'CLEAR':U OF b_nacion
DO:
    RUN Processa_Nacion.
    RETURN NO-APPLY.
END.

ON ANY-KEY OF b_nacion IN FRAME f_nacion DO:

   IF   KEYFUNCTION(LASTKEY) = "RETURN"   AND
        AVAILABLE tt-crapnac              THEN
        DO:
            shr_dsnacion = tt-crapnac.dsnacion.
            APPLY "GO".
        END.
   ELSE
   IF   (LASTKEY >= 65 AND LASTKEY <= 90)    OR    /* Letras Maiusculas */
        (LASTKEY >= 97 AND LASTKEY <= 122)   THEN  /* Letras Minusculas */
        DO:
            aux_dsdbusca = aux_dsdbusca + KEYFUNCTION(LASTKEY).

            DISPLAY aux_dsdbusca WITH FRAME f_busca.

            FIND FIRST tt-crapnac WHERE tt-crapnac.dsnacion BEGINS aux_dsdbusca
                               NO-LOCK NO-ERROR.

            IF   AVAILABLE tt-crapnac   THEN
                 REPOSITION q_nacion TO ROWID ROWID(tt-crapnac).
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

MESSAGE "Tecle F8 para manutencao das Nacionalidades". 
OPEN QUERY q_nacion FOR EACH tt-crapnac. 

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    UPDATE b_nacion WITH FRAME f_nacion
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

HIDE FRAME f_nacion     NO-PAUSE.
HIDE FRAME f_busca      NO-PAUSE.
HIDE FRAME f_alt_nacion NO-PAUSE.

/* .......................................................................... */

PROCEDURE Busca_Dados:

    /* Verifica se o banco generico ja esta conectado */
    ASSIGN aux_flggener = f_verconexaogener().

    IF  aux_flggener OR f_conectagener()  THEN
        DO:
            IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
                RUN sistema/generico/procedures/b1wgen0059.p
                    PERSISTENT SET h-b1wgen0059.
        
            RUN busca-crapnac IN h-b1wgen0059
                ( INPUT 0,
                  INPUT "",
                  INPUT 999999,
                  INPUT 1,
                 OUTPUT aux_qtregist,
                 OUTPUT TABLE tt-crapnac ).
        
            DELETE PROCEDURE h-b1wgen0059.

            IF  NOT aux_flggener  THEN
                RUN p_desconectagener.
        END.

END PROCEDURE.

PROCEDURE Processa_Nacion:

    HIDE MESSAGE NO-PAUSE.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       UPDATE p_cddopcao p_dsnatnac WITH FRAME f_alt_nacion.

       DO WHILE TRUE:

          FIND crapnac WHERE crapnac.dsnacion = p_dsnatnac
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF   NOT AVAILABLE crapnac   THEN
               IF   LOCKED crapnac   THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
          LEAVE.
       END.
       
       IF   NOT AVAILABLE crapnac   THEN
            DO:
                IF   p_cddopcao = "E"   THEN
                     DO:
                         MESSAGE "Nacionalidade nao existente".
                         NEXT.
                     END.
                ELSE
                IF   p_cddopcao = "I"   THEN
                     DO:
                         p_dsnatnac = CAPS(p_dsnatnac).

                         CREATE crapnac.
                         ASSIGN crapnac.dsnacion =  p_dsnatnac.
                     END.
            END.
       ELSE
            DO:
                IF   p_cddopcao = "I"   THEN
                     DO:
                         MESSAGE "Nacionalidade ja existente".
                         NEXT.
                     END.
                ELSE
                     DELETE crapnac.
            END.
       
       LEAVE.
    END.  /*  Fim do DO WHILE TRUE  */

    RUN Busca_Dados.

    /* Atualiza a lista de Nacionalidades */
    CLOSE QUERY q_nacion.
    OPEN QUERY q_nacion FOR EACH tt-crapnac NO-LOCK.
    MESSAGE "Tecle F8 para manutencao das Nacionalidades".

    HIDE FRAME f_alt_nacion NO-PAUSE.

END PROCEDURE 

/* .......................................................................... */
