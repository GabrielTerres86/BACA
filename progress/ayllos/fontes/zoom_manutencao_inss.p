/*.............................................................................

   Programa: fontes/zoom_manutencao_inss.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : André (DB1)
   Data    : Maio/2011                   Ultima alteracao:  00/00/0000

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom para opcoes de alteracao.

   Alteracoes: 
............................................................................ */
{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM }
{ includes/gg0000.i}

DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
DEF  INPUT PARAM par_nmsistem AS CHAR                             NO-UNDO.
DEF  INPUT PARAM par_tptabela AS CHAR                             NO-UNDO.
DEF  INPUT PARAM par_cdempres AS INTE                             NO-UNDO.
DEF  INPUT PARAM par_cdacesso AS CHAR                             NO-UNDO.
DEF OUTPUT PARAM par_tpregist AS INTE                             NO-UNDO.
DEF OUTPUT PARAM par_dstextab AS CHAR                             NO-UNDO.
                 
DEF QUERY  q_manut-inss FOR tt-manut-inss. 
DEF BROWSE b_manut-inss QUERY q_manut-inss
      DISP tt-manut-inss.tpregist     FORMAT "z9"      COLUMN-LABEL "Tp"
           tt-manut-inss.dstextab     FORMAT "x(62)"   COLUMN-LABEL "Descricao"
           WITH 8 DOWN OVERLAY TITLE " Opcoes de ALteracao ".    
          
FORM b_manut-inss HELP "Pressione ENTER para selecionar ou F4 para sair."
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_opalt.    

IF  NOT aux_fezbusca THEN
    DO:
        /* Verifica se o banco generico ja esta conectado */
        ASSIGN aux_flggener = f_verconexaogener().

        IF  aux_flggener OR f_conectagener()  THEN
            DO:
                IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
                    RUN sistema/generico/procedures/b1wgen0059.p
                        PERSISTENT SET h-b1wgen0059.

                RUN busca-opcoes-manut-inss IN h-b1wgen0059
                    ( INPUT par_cdcooper,
                      INPUT par_nmsistem,
                      INPUT par_tptabela,
                      INPUT par_cdempres,
                      INPUT par_cdacesso,
                      INPUT 999999,
                      INPUT 1,
                     OUTPUT aux_qtregist,
                     OUTPUT TABLE tt-manut-inss ).
           
                DELETE PROCEDURE h-b1wgen0059.
        
                ASSIGN aux_fezbusca = YES.

                IF  NOT aux_flggener  THEN
                    RUN p_desconectagener.
            END.
    END.

ON  END-ERROR OF b_manut-inss
    DO:
        HIDE FRAME f_opalt.
    END.

ON  RETURN OF b_manut-inss 
    DO:
        IF  AVAIL tt-manut-inss THEN
            ASSIGN par_tpregist = tt-manut-inss.tpregist
                   par_dstextab = tt-manut-inss.dstextab.
           
        CLOSE QUERY q_manut-inss.               
        
        APPLY "END-ERROR" TO b_manut-inss.
                 
    END.

OPEN QUERY q_manut-inss FOR EACH tt-manut-inss NO-LOCK.

DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
    UPDATE b_manut-inss WITH FRAME f_opalt.
    LEAVE.
END.

HIDE FRAME f_opalt NO-PAUSE.

/* .......................................................................... */


