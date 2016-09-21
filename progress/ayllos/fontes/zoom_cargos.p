/*.............................................................................

   Programa: fontes/zoom_cargos.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jose Luis Marchezoni (DB1)
   Data    : Marco/2010                   Ultima alteracao: 10/03/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom da tabela de cargos 

   Alteracoes: 10/03/2010 - Adaptado para uso de BO (Jose Luis, DB1)
............................................................................. */
{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM}
{ includes/gg0000.i}

DEF OUTPUT PARAM par_dsdcargo AS CHAR                                 NO-UNDO.

DEF QUERY q_cargos FOR tt-cargos.
DEF BROWSE b_cargos QUERY q_cargos
    DISPLAY tt-cargos.dsdcargo  FORMAT "x(21)"
            WITH 3 DOWN NO-BOX NO-LABELS.
            
FORM b_cargos HELP "Pressione ENTER para selecionar ou F4 para sair."
     WITH  ROW 15 COLUMN 49 TITLE "Cargos" OVERLAY NO-LABELS 
          FRAME f_cargos.

IF  NOT aux_fezbusca THEN
    DO:
        /* Verifica se o banco generico ja esta conectado */
        ASSIGN aux_flggener = f_verconexaogener().
        
        IF  aux_flggener OR f_conectagener()  THEN
            DO:
                IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
                    RUN sistema/generico/procedures/b1wgen0059.p
                        PERSISTENT SET h-b1wgen0059.

                RUN busca-cargos IN h-b1wgen0059
                    ( INPUT 0,
                      INPUT "",
                      INPUT 999999,
                      INPUT 1,
                     OUTPUT aux_qtregist,
                     OUTPUT TABLE tt-cargos ).
            
                DELETE PROCEDURE h-b1wgen0059.

                ASSIGN aux_fezbusca = YES.

                IF  NOT aux_flggener  THEN
                    RUN p_desconectagener.
            END.
    END.
          
ON RETURN OF b_cargos DO:

   ASSIGN par_dsdcargo = tt-cargos.dsdcargo.

   APPLY "GO".
END.

OPEN QUERY q_cargos FOR EACH tt-cargos NO-LOCK.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   UPDATE b_cargos WITH FRAME f_cargos.
   LEAVE.
END.

HIDE FRAME f_cargos NO-PAUSE.
