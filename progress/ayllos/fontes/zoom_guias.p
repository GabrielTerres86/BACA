/*.............................................................................

   Programa: fontes/zoom_guias.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : André - DB1
   Data    : Junho/2011                           Ultima alteracao: 07/06/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom de identificadores de guias.

   Alteracoes:
 ........................................................................... */

{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM }
{ includes/gg0000.i}
{ sistema/generico/includes/var_internet.i }

DEF INPUT         PARAM par_cdcooper AS INTE                     NO-UNDO.
DEF INPUT-OUTPUT  PARAM par_cdidenti AS DECI                     NO-UNDO.
DEF OUTPUT        PARAM par_cddpagto AS INTE                     NO-UNDO.

DEF VAR h-b1wgen0093 AS HANDLE                                   NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                     NO-UNDO.

DEF QUERY  q_crapcgp FOR tt-crapcgp.
DEF BROWSE b_crapcgp QUERY q_crapcgp
      DISP tt-crapcgp.cdidenti
                      COLUMN-LABEL "Identificador" FORMAT "zzzzzzzzzzzzzzz9"
           tt-crapcgp.cddpagto COLUMN-LABEL "Cd.Pgto"
           tt-crapcgp.nrdconta COLUMN-LABEL "Conta/dv"
           tt-crapcgp.nmprimtl COLUMN-LABEL "Nome"  FORMAT "x(28)"
           WITH 9 DOWN OVERLAY TITLE " Guias ".

FORM b_crapcgp HELP "Pressione ENTER para selecionar ou F4 para sair."
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_guias.


ON  END-ERROR OF b_crapcgp
    DO:
        HIDE FRAME f_guias.
    END.

ON  RETURN OF b_crapcgp
    DO:
        IF  NOT VALID-HANDLE(h-b1wgen0093)  THEN
            RUN sistema/generico/procedures/b1wgen0093.p
                PERSISTENT SET h-b1wgen0093.
    
        RUN valida-identificador IN h-b1wgen0093
            ( INPUT par_cdcooper,
              INPUT 0,
              INPUT 0,
              INPUT tt-crapcgp.cdidenti,
              INPUT tt-crapcgp.cddpagto,
             OUTPUT aux_nmdcampo,
             OUTPUT TABLE tt-erro ).
    
        IF  VALID-HANDLE(h-b1wgen0093)  THEN
            DELETE PROCEDURE h-b1wgen0093.
    
        IF  RETURN-VALUE <> "OK" THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                IF  AVAIL tt-erro THEN
                    MESSAGE tt-erro.dscritic.
            END.
        ELSE 
            DO:
                IF  AVAIL tt-crapcgp THEN
                    DO:
                        ASSIGN par_cddpagto = tt-crapcgp.cddpagto
                               par_cdidenti = tt-crapcgp.cdidenti.

                        CLOSE QUERY q_crapcgp.

                        APPLY "END-ERROR" TO b_crapcgp.
                    END.
            END.
    END.

IF  NOT aux_fezbusca THEN
    DO:
        /* Verifica se o banco generico ja esta conectado */
        ASSIGN aux_flggener = f_verconexaogener().

        IF  aux_flggener OR f_conectagener()  THEN
            DO:
                IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
                    RUN sistema/generico/procedures/b1wgen0059.p
                        PERSISTENT SET h-b1wgen0059.

                MESSAGE "Aguarde... buscando guias.".

                RUN busca-crapcgp IN h-b1wgen0059
                    ( INPUT par_cdcooper,
                      INPUT par_cdidenti,
                      INPUT 999999,
                      INPUT 1,
                     OUTPUT aux_qtregist,
                     OUTPUT TABLE tt-crapcgp ).

                HIDE MESSAGE NO-PAUSE.

                DELETE PROCEDURE h-b1wgen0059.

                ASSIGN aux_fezbusca = YES.

                IF  NOT aux_flggener  THEN
                    RUN p_desconectagener.
            END.
    END.

IF  par_cdidenti <> 0 THEN
    DO:
        FIND tt-crapcgp
            WHERE tt-crapcgp.cdidenti = par_cdidenti NO-LOCK NO-ERROR.

        IF  AVAIL tt-crapcgp THEN
            ASSIGN par_cdidenti = tt-crapcgp.cdidenti
                   par_cddpagto = tt-crapcgp.cddpagto.
    END.

IF  (par_cdidenti = 0) OR (AMBIGUOUS tt-crapcgp) THEN
    DO:
        OPEN QUERY q_crapcgp FOR EACH tt-crapcgp NO-LOCK.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE :

            UPDATE b_crapcgp WITH FRAME f_guias.
            LEAVE.
        END.

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
            DO:
                EMPTY TEMP-TABLE tt-crapcgp.

                HIDE FRAME f_guias NO-PAUSE.

                CLOSE QUERY q_crapcgp.
            END.
END.
/* ......................................................................... */




