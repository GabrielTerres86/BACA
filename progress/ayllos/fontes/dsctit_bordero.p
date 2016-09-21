/* .............................................................................

   Programa: Fontes/dsctit_bordero.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Agosto/2008                    Ultima atualizacao: 10/08/2012 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratar BORDEROS DE DESCONTOS DE TITULOS
               para a tela ATENDA.

   Alteracoes: 10/08/2012 - Alterado nome do campo de "ANALISAR" para
                            "PRE-ANALISE"
                          - Adicionado parametro 'nrdconta' na chamada do
                            fonte 'dsctit_bordero_m.p' (Lucas).
   
............................................................................. */

{ includes/var_online.i }
{ includes/var_atenda.i }
{ sistema/generico/includes/b1wgen0030tt.i }
{ includes/var_dsctit.i "NEW" }

DEFINE VARIABLE reg_dsdopcao  AS CHAR EXTENT 5 INIT
       ["Pre-Analise","Consultar","Excluir","Imprimir","Liberar"]  NO-UNDO.

DEFINE VARIABLE tab_cddopcao AS CHAR EXTENT 5 INIT
                                ["N","C","E","M","L"] NO-UNDO.
                                
DEF VAR reg_contador AS INTE   NO-UNDO.                                
DEF VAR h-b1wgen0030 AS HANDLE NO-UNDO.
DEF VAR aux_nrdlinha AS INTE   NO-UNDO.
DEF VAR aux_nrborder AS INTE   NO-UNDO.
DEF VAR opcao        AS INTE   NO-UNDO.

FORM SKIP(8)
     SPACE(15)
     reg_dsdopcao[1] FORMAT "x(11)"
     reg_dsdopcao[2] FORMAT "x(9)"
     reg_dsdopcao[3] FORMAT "x(7)"
     reg_dsdopcao[4] FORMAT "x(8)"
     reg_dsdopcao[5] FORMAT "x(7)"
     WITH ROW 10 WIDTH 73 OVERLAY CENTERED NO-LABEL TITLE
              " Desconto de Titulos - Bordero " FRAME f_opcoes.

DEF QUERY q_borderos FOR tt-bordero_tit.

DEF BROWSE b_borderos QUERY q_borderos
    DISP tt-bordero_tit.dtmvtolt COLUMN-LABEL "Data"     FORMAT "99/99/9999"
         tt-bordero_tit.nrborder COLUMN-LABEL "Bordero"  FORMAT "zzz,zz9"
         tt-bordero_tit.nrctrlim COLUMN-LABEL "Contrato" FORMAT "z,zzz,zz9"
         tt-bordero_tit.qtcompln COLUMN-LABEL "Qt.Tits"  FORMAT "zzz,zz9"
         tt-bordero_tit.vlcompcr COLUMN-LABEL "Valor"    FORMAT "zzz,zzz,zz9.99"
         tt-bordero_tit.dssitbdt COLUMN-LABEL "Situacao" FORMAT "x(9)"
         WITH 5 DOWN NO-BOX.

FORM b_borderos HELP "Pressione ENTER para selecionar / F4 ou END para sair."
     WITH ROW 11 COLUMN 2 OVERLAY NO-BOX CENTERED FRAME f_browse.

ON ANY-KEY OF b_borderos IN FRAME f_browse DO:

   IF   KEY-FUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
        DO:
            reg_contador = reg_contador + 1.

            IF   reg_contador > 5   THEN
                 reg_contador = 1.
                 
            glb_cddopcao = tab_cddopcao[reg_contador].
        END.
   ELSE        
   IF   KEY-FUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
        DO:
            reg_contador = reg_contador - 1.

            IF   reg_contador < 1   THEN
                 reg_contador = 5.
                 
            glb_cddopcao = tab_cddopcao[reg_contador].
        END.
   ELSE
   IF   KEY-FUNCTION(LASTKEY) = "HELP"   THEN
        APPLY LASTKEY.
   ELSE
   IF   KEY-FUNCTION(LASTKEY) = "RETURN"   THEN
        DO:
           IF   AVAILABLE tt-bordero_tit  THEN
                DO:
                    ASSIGN aux_nrborder = tt-bordero_tit.nrborder
                           aux_nrdlinha = CURRENT-RESULT-ROW("q_borderos").

                    /*Desmarca todas as linhas do browse para poder remarcar*/
                    b_borderos:DESELECT-ROWS().
                END.
           ELSE
                ASSIGN aux_nrborder = 0 
                       aux_nrdlinha = 0.
                         
           APPLY "GO".
        END.
   ELSE
        RETURN.
            
   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_opcoes.
END.

ASSIGN reg_contador = 1
       glb_cddopcao = tab_cddopcao[reg_contador].

/* Escolher o a opcao */
DISPLAY reg_dsdopcao WITH FRAME f_opcoes.
CHOOSE FIELD reg_dsdopcao[1] PAUSE 0 WITH FRAME f_opcoes.

DO WHILE TRUE:

    ASSIGN glb_nmrotina = "DSC TITS - BORDERO".

    /* Somente para marcar a opcao escolhida */
    DISPLAY reg_dsdopcao WITH FRAME f_opcoes.
    CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_opcoes.

    RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.
    
    IF  VALID-HANDLE(h-b1wgen0030)  THEN
        DO:
            RUN busca_borderos IN h-b1wgen0030 (INPUT glb_cdcooper,
                                                INPUT tel_nrdconta,
                                                INPUT glb_dtmvtolt,
                                               OUTPUT TABLE tt-bordero_tit).
            DELETE PROCEDURE h-b1wgen0030.
        END.
    ELSE
        DO:
            MESSAGE "Handle Invalido para b1wgen0030".
            RETURN. 
        END.
    
    OPEN QUERY q_borderos FOR EACH tt-bordero_tit NO-LOCK.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       UPDATE b_borderos WITH FRAME f_browse.
       LEAVE.
    END.
   
    IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
        LEAVE.
   
    /* Deixa o browse visivel e marca a linha que tinha sido selecionada */
    VIEW FRAME f_browse.
    IF  aux_nrdlinha > 0   THEN
        REPOSITION q_borderos TO ROW(aux_nrdlinha).
    
    { includes/acesso.i }

    /* Analisar */
    IF  glb_cddopcao = "N"  THEN
        DO:
            RUN fontes/dsctit_bordero_ln.p (INPUT aux_nrborder,
                                            INPUT "N").
        END.
    ELSE
    /* Consultar */
    IF  glb_cddopcao = "C"  THEN
        DO:
            RUN fontes/dsctit_bordero_c.p (INPUT aux_nrborder).
            
        END.
    ELSE
    /* Excluir */
    IF  glb_cddopcao = "E"  THEN
        DO:
            RUN fontes/dsctit_bordero_e.p (INPUT aux_nrborder).
        END.
    ELSE
    /* Imprimir */
    IF  glb_cddopcao = "M"  THEN
        DO:
            RUN fontes/dsctit_bordero_m.p (INPUT tel_nrdconta,
                                           INPUT aux_nrborder).
        END.
    ELSE
    /* Liberar */
    IF  glb_cddopcao = "L"  THEN
        DO:
            RUN fontes/dsctit_bordero_ln.p (INPUT aux_nrborder,
                                            INPUT "L").
            
        END.

END. /* Final do DO WHILE */    

HIDE FRAME f_browse NO-PAUSE.
HIDE FRAME f_opcoes NO-PAUSE.

/* .......................................................................... */
