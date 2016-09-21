/*.............................................................................

   Programa: fontes/zoom_historicos.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Junho/2005                           Ultima alteracao: 13/05/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom do cadastro de historicos.

   Alteracoes:  05/10/2005 - Alterado para ser chamado pela tela DCTROR(Mirtes)
   
                09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                             par_cdcooper) no "for each" da tabela CRAPHIS.
                           - Incluido parametro par_cdcooper para possibilitar
                             a chamada do zoom pelos programas pai.
                           - Kbase IT Solutions - Eduardo Silva.
                           
                16/03/2010 - Adaptado para ser utilizado na tela LOTE e 
                             LANAUT (Gabriel).           
                             
                01/02/2011 - Aumento FORMAT do campo dshistor para 50 (Diego).
                
                13/05/2011 - Adaptacao para uso de BO. (André - DB1)
 ........................................................................... */
{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM }
{ includes/gg0000.i}

DEF INPUT  PARAM par_cdcooper AS INT                             NO-UNDO.
DEF INPUT  PARAM par_flglanca AS LOGI                            NO-UNDO.
DEF INPUT  PARAM par_inautori AS INT                             NO-UNDO.
DEF OUTPUT PARAM par_cdhistor AS INT                             NO-UNDO.
                 
DEF QUERY  q_craphis FOR tt-craphis. 
DEF BROWSE b_craphis QUERY q_craphis
      DISP tt-craphis.cdhistor                      COLUMN-LABEL "Cod"
           tt-craphis.dshistor     FORMAT "x(50)"   COLUMN-LABEL "Descricao"
           WITH 10 DOWN OVERLAY TITLE " Historicos ".    
          
FORM b_craphis HELP "Pressione ENTER para selecionar ou F4 para sair." 
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_histor.          

IF  NOT aux_fezbusca THEN
    DO:
        /* Verifica se o banco generico ja esta conectado */
        ASSIGN aux_flggener = f_verconexaogener().

        IF  aux_flggener OR f_conectagener()  THEN
            DO:
                IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
                    RUN sistema/generico/procedures/b1wgen0059.p
                        PERSISTENT SET h-b1wgen0059.

                RUN busca-historico IN h-b1wgen0059
                    ( INPUT par_cdcooper,
                      INPUT 0,
                      INPUT "",
                      INPUT par_flglanca,
                      INPUT par_inautori,
                      INPUT 999999,
                      INPUT 1,
                     OUTPUT aux_qtregist,
                     OUTPUT TABLE tt-craphis ).
           
                DELETE PROCEDURE h-b1wgen0059.
        
                ASSIGN aux_fezbusca = YES.

                IF  NOT aux_flggener  THEN
                    RUN p_desconectagener.
            END.
    END.

ON  END-ERROR OF b_craphis
    DO:
        HIDE FRAME f_craphis.
    END.

ON  RETURN OF b_craphis 
    DO:
        IF  AVAIL tt-craphis THEN
            ASSIGN par_cdhistor = tt-craphis.cdhistor.
           
        CLOSE QUERY q_craphis.               
        
        APPLY "END-ERROR" TO b_craphis.
                 
    END.

OPEN QUERY q_craphis FOR EACH tt-craphis NO-LOCK.

DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
    UPDATE b_craphis WITH FRAME f_histor.
    LEAVE.
END.

HIDE FRAME f_histor NO-PAUSE.

/* .......................................................................... */

