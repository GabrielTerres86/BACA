/* .............................................................................

   Programa: Fontes/dsctit_limite.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Agosto/2008                    Ultima atualizacao: 10/09/2012    

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratar LIMITES DE DESCONTOS DE TITULOS
               para a tela ATENDA.

   Alteracoes: 06/04/2009 - Inclusao da tt-dados_cecred_dsctit na
                            busca_parametros_dsctit (Guilherme).
                            
               22/10/2009 - Gerar impressao do rating (Gabriel).     
               
               25/02/2010 - Esconder frame do browse para mostrar as
                            criticas do Rating (Gabriel).       
                            
               23/06/2010 - Mostrar campo de envio a sede (Gabrie).  
               
               23/09/2010 - Ajustar parametros para destit_limite_m.p (David).
               
               10/09/2012 - Ordenar limites por Dt. de Inicio de Vig. e Nr. do
                            Contrato (Lucas).
   
............................................................................. */

{ includes/var_online.i }
{ includes/var_atenda.i }
{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_dsctit.i "NEW" }

DEFINE VARIABLE reg_dsdopcao  AS CHAR EXTENT 6 INIT
    ["Alterar","Cancelar","Consultar","Excluir","Incluir","Imprimir"] NO-UNDO.

DEFINE VARIABLE tab_cddopcao AS CHAR EXTENT 6 INIT
                               ["A","X","C","E","I","M"].
                                
DEF VAR reg_contador AS INTE   NO-UNDO.                                
DEF VAR h-b1wgen0030 AS HANDLE NO-UNDO.
DEF VAR aux_nrdlinha AS INTE   NO-UNDO.
DEF VAR aux_nrctrlim AS INTE   NO-UNDO.
DEF VAR flg_primeira AS LOGI   NO-UNDO.
DEF VAR aux_regalias AS CHAR   NO-UNDO.

FORM SPACE(11)
     reg_dsdopcao[1] FORMAT "x(7)"
     reg_dsdopcao[2] FORMAT "x(8)"
     reg_dsdopcao[3] FORMAT "x(9)"
     reg_dsdopcao[4] FORMAT "x(7)"
     reg_dsdopcao[5] FORMAT "x(7)"
     reg_dsdopcao[6] FORMAT "x(8)"
     WITH ROW 20 NO-BOX WIDTH 73 OVERLAY CENTERED NO-LABEL FRAME f_opcoes.

DEF QUERY q_titulos FOR tt-limite_tit.

DEF BROWSE b_titulos QUERY q_titulos
    DISP tt-limite_tit.dtpropos COLUMN-LABEL "Proposta"   FORMAT "99/99/99"
         tt-limite_tit.dtinivig COLUMN-LABEL "Ini.Vigen." FORMAT "99/99/99"
         tt-limite_tit.nrctrlim COLUMN-LABEL "Contrato"   FORMAT "z,zzz,zz9"
         tt-limite_tit.vllimite COLUMN-LABEL "Limite"     FORMAT "zzz,zzz,zz9.99"
         tt-limite_tit.qtdiavig COLUMN-LABEL "Vig"        FORMAT "zz9"
         tt-limite_tit.cddlinha COLUMN-LABEL "LD"         FORMAT "zz9"
         tt-limite_tit.dssitlim COLUMN-LABEL "Situacao"   FORMAT "x(10)"
         tt-limite_tit.flgenvio COLUMN-LABEL "Comite"     FORMAT "x(3)"
         WITH 6 DOWN NO-BOX.

FORM b_titulos HELP "Pressione ENTER para selecionar / F4 ou END para sair."
     WITH ROW 10 OVERLAY CENTERED TITLE " Desconto de Titulos - Limite "
     FRAME f_browse.

ON ANY-KEY OF b_titulos IN FRAME f_browse DO:

   IF   KEY-FUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
        DO:
            reg_contador = reg_contador + 1.

            IF   reg_contador > 6   THEN
                 reg_contador = 1.
                 
            glb_cddopcao = tab_cddopcao[reg_contador].
        END.
   ELSE        
   IF   KEY-FUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
        DO:
            reg_contador = reg_contador - 1.

            IF   reg_contador < 1   THEN
                 reg_contador = 6.
                 
            glb_cddopcao = tab_cddopcao[reg_contador].
        END.
   ELSE
   IF   KEY-FUNCTION(LASTKEY) = "HELP"   THEN
        APPLY LASTKEY.
   ELSE
   IF   KEY-FUNCTION(LASTKEY) = "RETURN"   THEN
        DO:
           IF   AVAILABLE tt-limite_tit  THEN
                DO:
                    ASSIGN aux_nrctrlim = tt-limite_tit.nrctrlim
                           aux_nrdlinha = CURRENT-RESULT-ROW("q_titulos").

                    /*Desmarca todas as linhas do browse para poder remarcar*/
                    b_titulos:DESELECT-ROWS().
                END.
           ELSE
                ASSIGN aux_nrctrlim = 0 
                       aux_nrdlinha = 0.
                         
           APPLY "GO".
        END.
   ELSE
        RETURN.

   /* Marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_opcoes.
END.

ASSIGN flg_primeira = TRUE.

DO WHILE TRUE:

    ASSIGN glb_nmrotina = "DSC TITS - LIMITE".
   
    RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.
    
    IF  VALID-HANDLE(h-b1wgen0030)  THEN
        DO:
            RUN busca_limites IN h-b1wgen0030 (INPUT glb_cdcooper,
                                               INPUT tel_nrdconta,
                                               INPUT glb_dtmvtolt,
                                              OUTPUT TABLE tt-limite_tit).
            DELETE PROCEDURE h-b1wgen0030.
        END.
    ELSE
        DO:
            MESSAGE "Handle Invalido para b1wgen0030".
            RETURN. 
        END.
    
    IF  flg_primeira  THEN
        DO:
            IF  CAN-FIND(FIRST tt-limite_tit NO-LOCK)  THEN
                DO:
                    /* Foco na consulta */
                    DISPLAY reg_dsdopcao WITH FRAME f_opcoes.
                    CHOOSE FIELD reg_dsdopcao[3] PAUSE 0 WITH FRAME f_opcoes.
                    ASSIGN reg_contador = 3.
                           glb_cddopcao = "C".
                END.
            ELSE
                DO:
                    /* Foco na inclusao */
                    DISPLAY reg_dsdopcao WITH FRAME f_opcoes.
                    CHOOSE FIELD reg_dsdopcao[5] PAUSE 0 WITH FRAME f_opcoes.
                    ASSIGN reg_contador = 5.
                           glb_cddopcao = "I".
                END.

            ASSIGN flg_primeira = FALSE.
        
        END.

    OPEN QUERY q_titulos FOR EACH tt-limite_tit NO-LOCK
                               BY tt-limite_tit.dtinivig DESC
                               BY tt-limite_tit.nrctrlim.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       UPDATE b_titulos WITH FRAME f_browse.
       LEAVE.

    END.
   
    IF KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
       LEAVE.                                  
   
    { includes/acesso.i }

    /* Alterar */
    IF  glb_cddopcao = "A"  THEN
        DO:
            RUN fontes/dsctit_limite_a.p (INPUT aux_nrctrlim).         
        END.
    ELSE
    /* Cancelar */
    IF  glb_cddopcao = "X"  THEN
        DO:
            RUN fontes/dsctit_limite_x.p (INPUT aux_nrctrlim).     
        END.
    ELSE
    /* Consultar */
    IF  glb_cddopcao = "C"  THEN
        DO:
            RUN fontes/dsctit_limite_c.p (INPUT aux_nrctrlim).
        END.
    ELSE
    /* Excluir */
    IF  glb_cddopcao = "E"  THEN
        DO:
            RUN fontes/dsctit_limite_e.p (INPUT aux_nrctrlim).            
        END.
    ELSE
    /* Incluir */
    IF  glb_cddopcao = "I"  THEN
        DO:
            RUN fontes/dsctit_limite_i.p.
        END.
    /* Imprimir */
    IF  glb_cddopcao = "M"  THEN
        DO: 
            HIDE FRAME f_opcoes NO-PAUSE.
            HIDE FRAME f_browse NO-PAUSE. 
            
            RUN fontes/dsctit_limite_m.p (INPUT tel_nrdconta,
                                          INPUT aux_nrctrlim).

            PAUSE 0.
            VIEW FRAME f_opcoes.

            PAUSE 0.
            VIEW FRAME f_browse.
        END.        

END. /* Final do DO WHILE */    

HIDE FRAME f_browse NO-PAUSE.
HIDE FRAME f_opcoes NO-PAUSE.

/* .......................................................................... */

