/*.............................................................................

   Programa: fontes/zoom_turnos.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jose Luis Marchezoni (DB1)
   Data    : Marco/2010                   Ultima alteracao: 15/03/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom da tabela de turnos 

   Alteracoes: 15/03/2010 - Adaptado para usar BO (Jose Luis, DB1)
............................................................................. */
{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM }
{ includes/gg0000.i}

DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
DEF OUTPUT PARAM par_cdturnos LIKE crapttl.cdturnos             NO-UNDO.
DEF OUTPUT PARAM par_dsturnos AS CHAR                           NO-UNDO.

DEF QUERY q_turnos FOR tt-turnos.
DEF BROWSE b_turnos QUERY q_turnos
    DISPLAY tt-turnos.cdturnos   COLUMN-LABEL "Codigo"      FORMAT "zz9"
            tt-turnos.dsturnos   COLUMN-LABEL "Descricao"   FORMAT "x(25)"
            WITH 5 DOWN NO-BOX.
            
FORM b_turnos HELP "Pressione ENTER para selecionar ou F4 para sair."
     WITH ROW 9 CENTERED TITLE "TURNOS" OVERLAY NO-LABELS 
          FRAME f_turnos.

IF  NOT aux_fezbusca  THEN
    DO:
        /* Verifica se o banco generico ja esta conectado */
        ASSIGN aux_flggener = f_verconexaogener().
        
        IF  aux_flggener OR f_conectagener()  THEN
            DO:
                IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
                    RUN sistema/generico/procedures/b1wgen0059.p
                        PERSISTENT SET h-b1wgen0059.
             
                RUN busca-turnos IN h-b1wgen0059
                    ( INPUT par_cdcooper,
                      INPUT 0,
                      INPUT "",
                      INPUT 999999,
                      INPUT 1,
                     OUTPUT aux_qtregist,
                     OUTPUT TABLE tt-turnos ).
             
                DELETE PROCEDURE h-b1wgen0059.

                ASSIGN aux_fezbusca = YES.

                IF  NOT aux_flggener  THEN
                    RUN p_desconectagener.
            END.
    END.
          
ON RETURN OF b_turnos DO:

   ASSIGN par_cdturnos = tt-turnos.cdturnos
          par_dsturnos = tt-turnos.dsturnos.

   APPLY "GO".
END.

OPEN QUERY q_turnos FOR EACH tt-turnos NO-LOCK.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   UPDATE b_turnos WITH FRAME f_turnos.
   LEAVE.
END.

HIDE FRAME f_turnos NO-PAUSE.
