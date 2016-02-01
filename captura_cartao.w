&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_captura_cartao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_captura_cartao 
/* ..............................................................................

Procedure: captura_cartao.w
Objetivo : Tela para capturar o cartao
Autor    : Evandro
Data     : Janeiro 2010

Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

                  29/08/2011 - Ajuste para label de versao 4.0 (Gabriel)
                             - Inclusao de controles para PAINOP (Evandro).
                             
                  14/05/2013 - Transferencia intercooperativa (Gabriel).
                  
                  29/05/2015 - Adicionado atribuicao da variavel glb_flmsgtaa = NO
                               em procedure verifica_cartao_lido. (Jorge/Rodrigo)
                               
                  27/08/2015 - Adicionado condicao para verificar se o cartao
                               eh magnetico. (James)
                               
                  18/09/2015 - Corrigida implementação da utilização do 
                               PAINOP (traseiro) para TAAs sem depositário
                               (Lucas Lunelli SD 314201)              

                  27/01/2016 - Adicionado novo parametro na chamada da procedure
                               busca_associado. (Reinert)
                               
                  29/01/2016 - Tratamento banners (Lucas Lunelli - PRJ261)
                  
............................................................................... */

/*----------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }
{ includes/var_xfs_lite.i }

DEFINE VARIABLE aux_flgderro        AS LOGICAL      NO-UNDO.
DEFINE VARIABLE aux_flgderr2        AS LOGICAL      NO-UNDO.
DEFINE VARIABLE aux_contador        AS INTEGER      NO-UNDO.
DEFINE VARIABLE aux_contbann        AS INTEGER      NO-UNDO.
DEFINE VARIABLE aux_flcartao        AS LOGICAL      NO-UNDO.
DEFINE VARIABLE aux_dsdtecla        AS CHARACTER    NO-UNDO.
DEFINE VARIABLE aux_idbanner        AS CHARACTER    NO-UNDO.


/* Leitora de insercao */

/* para status */
DEFINE VARIABLE stsenso             AS MEMPTR       NO-UNDO.
DEFINE VARIABLE sttrava             AS MEMPTR       NO-UNDO.
DEFINE VARIABLE stbuff1             AS MEMPTR       NO-UNDO.
DEFINE VARIABLE stbuff2             AS MEMPTR       NO-UNDO.
DEFINE VARIABLE stbuff3             AS MEMPTR       NO-UNDO.

/* para comando de leitura */
DEFINE VARIABLE tbuff1              AS MEMPTR       NO-UNDO.
DEFINE VARIABLE tbuff2              AS MEMPTR       NO-UNDO.
DEFINE VARIABLE tbuff3              AS MEMPTR       NO-UNDO.
DEFINE VARIABLE buff1               AS MEMPTR       NO-UNDO.
DEFINE VARIABLE buff2               AS MEMPTR       NO-UNDO.
DEFINE VARIABLE buff3               AS MEMPTR       NO-UNDO.

/* Leitora de passagem */
DEFINE VARIABLE aux_qtcartao        AS INTEGER      NO-UNDO.
DEFINE VARIABLE mem_qtcartao        AS MEMPTR       NO-UNDO.
DEFINE VARIABLE mem_dscartao        AS MEMPTR       NO-UNDO.


/* Para o PAINOP */
DEFINE VARIABLE buff                AS CHAR EXTENT 6    NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_captura_cartao

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ed_dscartao ed_dsvertaa IMAGE-31 
&Scoped-Define DISPLAYED-OBJECTS ed_dscartao ed_dsvertaa 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_captura_cartao AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.
DEFINE VARIABLE temporizador2 AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador2 AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE VARIABLE ed_dscartao AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE ed_dsvertaa AS CHARACTER FORMAT "X(6)":U INITIAL "Versao" 
      VIEW-AS TEXT 
     SIZE 10 BY .62
     BGCOLOR 15 FGCOLOR 2 FONT 6 NO-UNDO.

DEFINE IMAGE IMAGE-31
     FILENAME "Imagens/logo_principal.jpg":U
     SIZE 160 BY 28.57.

DEFINE IMAGE IMAGE-27
     FILENAME "Imagens/btn_entra.jpg":U TRANSPARENT
     SIZE 17.8 BY 2.24.

DEFINE VARIABLE ed_forma_cartao AS CHARACTER FORMAT "X(256)":U INITIAL "INSIRA" 
      VIEW-AS TEXT 
     SIZE 25 BY 1.71
     FONT 15 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_captura_cartao
     ed_dscartao AT ROW 25.76 COL 8 COLON-ALIGNED NO-LABEL WIDGET-ID 64
     ed_dsvertaa AT ROW 1.24 COL 148 COLON-ALIGNED NO-LABEL WIDGET-ID 124
     IMAGE-31 AT ROW 1 COL 1 WIDGET-ID 112
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 160 BY 28.57 WIDGET-ID 100.

DEFINE FRAME f_mensagem
     ed_forma_cartao AT ROW 1 COL 2.4 NO-LABEL WIDGET-ID 90 NO-TAB-STOP 
     "SEU CARTÃO" VIEW-AS TEXT
          SIZE 39 BY 1.71 AT ROW 1 COL 30.2 WIDGET-ID 86
          FONT 15
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 43 ROW 24.33
         SIZE 72 BY 2 WIDGET-ID 300.

DEFINE FRAME f_depositario
     "OU" VIEW-AS TEXT
          SIZE 9 BY 1.71 AT ROW 1 COL 81.6 WIDGET-ID 86
          FONT 15
     "TECLE" VIEW-AS TEXT
          SIZE 20 BY 1.71 AT ROW 3.29 COL 2 WIDGET-ID 88
          FONT 15
     "PARA DEPÓSITOS" VIEW-AS TEXT
          SIZE 54.8 BY 1.71 AT ROW 3.29 COL 41 WIDGET-ID 90
          FONT 15
     IMAGE-27 AT ROW 3 COL 22.4 WIDGET-ID 92
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 35 ROW 24.33
         SIZE 97 BY 4.52 WIDGET-ID 200.

DEFINE FRAME f_encobre_cartao
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 8 ROW 25.05
         SIZE 19 BY 2.38 WIDGET-ID 400.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* SUPPRESS Window definition (used by the UIB) 
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW w_captura_cartao ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.57
         WIDTH              = 160
         MAX-HEIGHT         = 33.14
         MAX-WIDTH          = 204.8
         VIRTUAL-HEIGHT     = 33.14
         VIRTUAL-WIDTH      = 204.8
         SHOW-IN-TASKBAR    = no
         CONTROL-BOX        = no
         MIN-BUTTON         = no
         MAX-BUTTON         = no
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
                                                                        */
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME
ASSIGN w_captura_cartao = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_captura_cartao
  VISIBLE,,RUN-PERSISTENT                                               */
/* REPARENT FRAME */
ASSIGN FRAME f_depositario:FRAME = FRAME f_captura_cartao:HANDLE
       FRAME f_encobre_cartao:FRAME = FRAME f_captura_cartao:HANDLE
       FRAME f_mensagem:FRAME = FRAME f_captura_cartao:HANDLE.

/* SETTINGS FOR FRAME f_captura_cartao
   FRAME-NAME Custom                                                    */
ASSIGN 
       ed_dscartao:READ-ONLY IN FRAME f_captura_cartao        = TRUE.

ASSIGN 
       ed_dsvertaa:READ-ONLY IN FRAME f_captura_cartao        = TRUE.

/* SETTINGS FOR FRAME f_depositario
                                                                        */
/* SETTINGS FOR FRAME f_encobre_cartao
                                                                        */
/* SETTINGS FOR FRAME f_mensagem
                                                                        */
/* SETTINGS FOR FILL-IN ed_forma_cartao IN FRAME f_mensagem
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_captura_cartao:HANDLE
       ROW             = 3.86
       COLUMN          = 45
       HEIGHT          = 1.43
       WIDTH           = 6
       TAB-STOP        = no
       WIDGET-ID       = 6
       HIDDEN          = yes
       SENSITIVE       = yes.

CREATE CONTROL-FRAME temporizador2 ASSIGN
       FRAME           = FRAME f_captura_cartao:HANDLE
       ROW             = 3.86
       COLUMN          = 110
       HEIGHT          = 4.76
       WIDTH           = 20
       TAB-STOP        = no
       WIDGET-ID       = 116
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: timer */
/* temporizador2 OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: timer */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_captura_cartao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_captura_cartao w_captura_cartao
ON END-ERROR OF w_captura_cartao
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_captura_cartao w_captura_cartao
ON WINDOW-CLOSE OF w_captura_cartao
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f_captura_cartao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f_captura_cartao w_captura_cartao
ON ENTRY OF FRAME f_captura_cartao
DO:
    /* coloca o foco no campo para leitura do cartao */
    APPLY "ENTRY" TO ed_dscartao.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f_depositario
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f_depositario w_captura_cartao
ON ENTRY OF FRAME f_depositario
DO:
    /* mantem foco no frame principal */
    APPLY "ENTRY" TO FRAME f_captura_cartao.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f_encobre_cartao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f_encobre_cartao w_captura_cartao
ON ENTRY OF FRAME f_encobre_cartao
DO:
    /* mantem foco no frame principal */
    APPLY "ENTRY" TO FRAME f_captura_cartao.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f_mensagem
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f_mensagem w_captura_cartao
ON ENTRY OF FRAME f_mensagem
DO:
    /* mantem foco no frame principal */
    APPLY "ENTRY" TO FRAME f_captura_cartao.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_dscartao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_dscartao w_captura_cartao
ON ANY-KEY OF ed_dscartao IN FRAME f_captura_cartao
DO:
    /* guarda a tecla pressionada */
    aux_dsdtecla = KEYFUNCTION(LASTKEY).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_captura_cartao OCX.Tick
PROCEDURE temporizador.timer.Tick .
/* Chama a verificacao de autorizacao de 5 em 5 minutos.
       Serve para controle de TAA em funcionamnto, para Reboot e
       pode ser usado para implementar envio de situaçao do TAA */        
    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).

    /* Se houve erro de autorizacao, seta para encerrar e voltar
       para a tela inicial */
    aux_flgderr2 = aux_flgderro.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador2 w_captura_cartao OCX.Tick
PROCEDURE temporizador2.timer.Tick .
/* em caso de erro da autorizacao, fecha a janela */
    IF  aux_flgderr2  THEN
        DO:
            RUN ativa_sonda (INPUT NO).
            RUN ativa_captura (INPUT NO).

            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN.
        END.


    /* se tem PAINOP */
    IF  xfs_painop  THEN
        DO:
            ASSIGN buff[1] = ""
                   buff[2] = ""
                   buff[3] = ""
                   buff[4] = ""
                   buff[5] = "  PRESSIONE ~"PAUSA~" PARA MANUTENCAO   "
                   buff[6] = "".

            RUN procedures/atualiza_painop.p (INPUT buff).
        END.


    /* coloca o foco no campo para leitura do cartao */
    APPLY "ENTRY" TO ed_dscartao IN FRAME f_captura_cartao.

    
    /* Leitora de Inserção */
    IF  xfs_leitoraDIP  THEN
        DO:
            /* efetua leitura do cartao */
            SET-SIZE(tbuff1) = 5.
            SET-SIZE(tbuff2) = 5.
            SET-SIZE(tbuff3) = 5.
            SET-SIZE(buff1) = 156.
            SET-SIZE(buff2) = 156.
            SET-SIZE(buff3) = 156.

            /* verifica se deve fazer reboot ou atualizacao do TAA */
            IF  glb_flreboot  THEN
                RUN procedures/efetua_reboot.p.
            ELSE
            IF  glb_flupdate  THEN
                DO:
                    RUN ativa_sonda (INPUT NO).
                    RUN ativa_captura (INPUT NO).

                    RUN atualiza_sistema.w (INPUT YES).
                END.

            ed_forma_cartao:SCREEN-VALUE IN FRAME f_mensagem= "INSIRA".

            /* possui depositário */
            IF  glb_tpenvelo <> 0  THEN
                FRAME f_depositario:VISIBLE = YES.

            ASSIGN FRAME f_mensagem:VISIBLE    = NO
                   FRAME f_mensagem:VISIBLE    = YES.
            
            PUT-STRING(tbuff1,1) = '155'.
            PUT-STRING(tbuff2,1) = '155'.
            PUT-STRING(tbuff3,1) = '155'.
            PUT-STRING(buff1,1) = ' '.
            PUT-STRING(buff2,1) = ' '.
            PUT-STRING(buff3,1) = ' '.

            RUN verifica_insercao.

            /* somente chama a leitura se o cartao foi inserido */
            IF  aux_flcartao  THEN
                DO:

                    /* se tem PAINOP */
                    IF  xfs_painop  THEN
                        DO:
                            ASSIGN buff[1] = ""
                                   buff[2] = ""
                                   buff[3] = ""
                                   buff[4] = ""
                                   buff[5] = "     TERMINAL EM USO, AGUARDE...      "
                                   buff[6] = "".
    
                            RUN procedures/atualiza_painop.p (INPUT buff).
                        END.


                    RUN WinLeSincronoCmgLDIP IN aux_xfsliteh 
                          (INPUT 5, /* time-out: 5s */
                           INPUT GET-POINTER-VALUE(tbuff1),
                           INPUT GET-POINTER-VALUE(tbuff2),
                           INPUT GET-POINTER-VALUE(tbuff3),
                           INPUT GET-POINTER-VALUE(buff1),
                           INPUT GET-POINTER-VALUE(buff2),
                           INPUT GET-POINTER-VALUE(buff3),
                           OUTPUT LT_Resp). 

                    IF  LT_Resp <> 0  THEN
                        DO:
                            /* libera memória */
                            SET-SIZE(tbuff1) = 0.
                            SET-SIZE(tbuff2) = 0.
                            SET-SIZE(tbuff3) = 0.
                            SET-SIZE(buff1)  = 0.
                            SET-SIZE(buff2)  = 0.
                            SET-SIZE(buff3)  = 0.

                            RETURN.
                        END.
                END.
            ELSE
                DO:
                    /* se tem depositario */
                    IF  FRAME f_depositario:VISIBLE  THEN
                        DO:
                            /* verifica se apertou ENTER */
                            IF  aux_dsdtecla = "RETURN"  THEN
                                DO:
                                    /* desativa o controle de foco */
                                    RUN procedures/controle_foco.p (INPUT NO).

                                    RUN ativa_captura (INPUT NO).


                                    /* se tem PAINOP */
                                    IF  xfs_painop  THEN
                                        DO:
                                            ASSIGN buff[1] = ""
                                                   buff[2] = ""
                                                   buff[3] = ""
                                                   buff[4] = ""
                                                   buff[5] = "     TERMINAL EM USO, AGUARDE...      "
                                                   buff[6] = "".
                                
                                            RUN procedures/atualiza_painop.p (INPUT buff).
                                        END.

                                    RUN envelope_aviso.w.

                                    RUN ativa_captura (INPUT YES).

                                    /* ativa o controle de foco */
                                    RUN procedures/controle_foco.p (INPUT YES).
                                END.
                            ELSE
                            /* verifica se apertou PAUSA no PAINOP */
                            IF  aux_dsdtecla = "P"  THEN
                                DO:
                                    /* desativa o controle de foco */
                                    RUN procedures/controle_foco.p (INPUT NO).
                                    
                                    RUN ativa_captura (INPUT NO).

                                    /* esconde as mensagens de depositario e cartao,
                                       mostra que esta em manutencao */
                                    ASSIGN FRAME f_depositario:VISIBLE = NO
                                           FRAME f_mensagem:VISIBLE    = NO
                                           xfs_painop_em_uso           = YES.
                                        
                                    RUN  manutencao_painop.w.

                                    xfs_painop_em_uso = NO.
                                    
                                    RUN ativa_captura (INPUT YES).
                                    
                                    /* ativa o controle de foco */
                                    RUN procedures/controle_foco.p (INPUT YES).
                                END.


                            aux_dsdtecla = "".
                        END.
                    /* Não possui depositário */
                    ELSE
                        DO:
                            /* verifica se apertou PAUSA no PAINOP */
                            IF  aux_dsdtecla = "P"  THEN
                                DO:
                                    /* desativa o controle de foco */
                                    RUN procedures/controle_foco.p (INPUT NO).
                                    
                                    RUN ativa_captura (INPUT NO).

                                    /* esconde as mensagens de depositario e cartao,
                                       mostra que esta em manutencao */
                                    ASSIGN FRAME f_depositario:VISIBLE = NO
                                           FRAME f_mensagem:VISIBLE    = NO
                                           xfs_painop_em_uso           = YES.

                                    RUN  manutencao_painop.w.

                                    xfs_painop_em_uso = NO.
                                    
                                    RUN ativa_captura (INPUT YES).
                                    
                                    /* ativa o controle de foco */
                                    RUN procedures/controle_foco.p (INPUT YES).
                                END.

                            aux_dsdtecla = "".
                        END.    
                    
                    /* libera memória */
                    SET-SIZE(tbuff1) = 0.
                    SET-SIZE(tbuff2) = 0.
                    SET-SIZE(tbuff3) = 0.
                    SET-SIZE(buff1)  = 0.
                    SET-SIZE(buff2)  = 0.
                    SET-SIZE(buff3)  = 0.
                    
                    RETURN.
                END.
                
            ed_dscartao = '2ç' + TRIM(GET-STRING(buff2,1)) + ':'.
            
            RUN ativa_captura (INPUT NO).
            
            RUN verifica_cartao_lido.

            RUN ativa_captura (INPUT YES).
    
            /* libera memória */
            SET-SIZE(tbuff1) = 0.
            SET-SIZE(tbuff2) = 0.
            SET-SIZE(tbuff3) = 0.
            SET-SIZE(buff1)  = 0.
            SET-SIZE(buff2)  = 0.
            SET-SIZE(buff3)  = 0.
        END.
    ELSE   
        /* Leitora de Passagem */
        DO:
            ed_forma_cartao:SCREEN-VALUE IN FRAME f_mensagem= " PASSE".
            
            SET-SIZE(mem_qtcartao) = 10.       /* 9 posições + "\0"  */
            SET-SIZE(mem_dscartao) = 51.       /* 50 posições + "\0"  */
            
            /* verifica se deve fazer reboot ou atualizacao do TAA */
            IF  glb_flreboot  THEN
                RUN procedures/efetua_reboot.p.
            ELSE
            IF  glb_flupdate  THEN
                DO:
                    RUN ativa_sonda (INPUT NO).
                    RUN ativa_captura (INPUT NO).

                    RUN atualiza_sistema.w (INPUT YES).
                END.


            /* mostra o "Passe seu cartao" */
            FRAME f_mensagem:VISIBLE    = YES.
            
            PUT-STRING(mem_qtcartao,1)= '10'.
            PUT-STRING(mem_dscartao,1)= '51'.
            
            RUN WinLeSincronoCartaoPassagem IN aux_xfsliteh
                (INPUT 10,
                 INPUT GET-POINTER-VALUE(mem_qtcartao),
                 INPUT GET-POINTER-VALUE(mem_dscartao),
                 OUTPUT LT_Resp).


            ASSIGN ed_dscartao  = '2ç' + TRIM(GET-STRING(mem_dscartao,1)) + ':' 
                   aux_qtcartao = ASC(GET-STRING(mem_qtcartao,1)).

            /* Houve time-out e nao possui depositario, entao fica lendo cartao */
            IF  aux_qtcartao < 0  AND
                glb_tpenvelo = 0  THEN
                DO:
                    /* Libera a memória */
                    SET-SIZE(mem_qtcartao) = 0.
                    SET-SIZE(mem_dscartao) = 0.

                    RETURN.
                END.

            RUN ativa_captura (INPUT NO).

            RUN verifica_cartao_lido.

            RUN ativa_captura (INPUT YES).

        
            /* Libera a memória */
            SET-SIZE(mem_qtcartao) = 0.
            SET-SIZE(mem_dscartao) = 0.
        END.
                                             
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_captura_cartao 


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO  ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  
    RUN enable_UI.
   
    /* deixa o mouse transparente */
    FRAME f_captura_cartao:LOAD-MOUSE-POINTER("blank.cur").
    FRAME f_depositario:LOAD-MOUSE-POINTER("blank.cur").
    FRAME f_mensagem:LOAD-MOUSE-POINTER("blank.cur").
    FRAME f_encobre_cartao:LOAD-MOUSE-POINTER("blank.cur").

           /* Handle do frame principal */
    ASSIGN h_principal = FRAME f_captura_cartao:HANDLE
           /* versao do sistema */
           ed_dsvertaa:SCREEN-VALUE = glb_dsvertaa.

    RUN ativa_sonda (INPUT YES).
    RUN ativa_captura (INPUT YES).


    /* não possui depositário */
    IF  glb_tpenvelo = 0  THEN
        FRAME f_depositario:VISIBLE = NO.

    /* ativa o controle de foco */
    RUN procedures/controle_foco.p (INPUT YES).

    /* ativa o teclado frontal */
    RUN WinAtualizaEstadoTeclados IN aux_xfsliteh (
        INPUT  1, /* teclado frontal */
        INPUT  1, /* habilita varredura */
        INPUT -1, /* StaBeep - nao altera */
        INPUT -1, /* Led1 - nao altera */
        INPUT -1, /* Led2 - nao altera */
        INPUT -1, /* FlickerCrt - nao altera */
        INPUT -1, /* FlickerDispCel - nao altera */
        INPUT -1, /* FlickerPtr - nao altera */
        INPUT -1, /* Solenoide - nao altera */
        OUTPUT LT_Resp).


    /* coloca foco no frame */
    APPLY "ENTRY" TO FRAME f_captura_cartao.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ativa_captura w_captura_cartao 
PROCEDURE ativa_captura :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAM par_flgativa     AS LOGICAL          NO-UNDO.

/* leitura de cartao ou teclado a cada 1s */
IF  par_flgativa  THEN
    chtemporizador2:timer:INTERVAL = 1000.
ELSE
    chtemporizador2:timer:INTERVAL = 0.

APPLY "ENTRY" TO FRAME f_captura_cartao.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ativa_sonda w_captura_cartao 
PROCEDURE ativa_sonda :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAM par_flgativa     AS LOGICAL          NO-UNDO.

/* sonda a cada 5min */
IF  par_flgativa  THEN
    chtemporizador:timer:INTERVAL = 300000.
ELSE
    chtemporizador:timer:INTERVAL = 0.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_captura_cartao  _CONTROL-LOAD
PROCEDURE control_load :
/*------------------------------------------------------------------------------
  Purpose:     Load the OCXs    
  Parameters:  <none>
  Notes:       Here we load, initialize and make visible the 
               OCXs in the interface.                        
------------------------------------------------------------------------------*/

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN
DEFINE VARIABLE UIB_S    AS LOGICAL    NO-UNDO.
DEFINE VARIABLE OCXFile  AS CHARACTER  NO-UNDO.

OCXFile = SEARCH( "captura_cartao.wrx":U ).
IF OCXFile = ? THEN
  OCXFile = SEARCH(SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1,
                     R-INDEX(THIS-PROCEDURE:FILE-NAME, ".":U), "CHARACTER":U) + "wrx":U).

IF OCXFile <> ? THEN
DO:
  ASSIGN
    chtemporizador = temporizador:COM-HANDLE
    UIB_S = chtemporizador:LoadControls( OCXFile, "temporizador":U)
    temporizador:NAME = "temporizador":U
    chtemporizador2 = temporizador2:COM-HANDLE
    UIB_S = chtemporizador2:LoadControls( OCXFile, "temporizador2":U)
    temporizador2:NAME = "temporizador2":U
  .
  RUN initialize-controls IN THIS-PROCEDURE NO-ERROR.
END.
ELSE MESSAGE "captura_cartao.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_captura_cartao  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME f_captura_cartao.
  HIDE FRAME f_depositario.
  HIDE FRAME f_encobre_cartao.
  HIDE FRAME f_mensagem.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_captura_cartao  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other 
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  RUN control_load.
  DISPLAY ed_dscartao ed_dsvertaa 
      WITH FRAME f_captura_cartao.
  ENABLE ed_dscartao ed_dsvertaa IMAGE-31 
      WITH FRAME f_captura_cartao.
  {&OPEN-BROWSERS-IN-QUERY-f_captura_cartao}
  ENABLE IMAGE-27 
      WITH FRAME f_depositario.
  {&OPEN-BROWSERS-IN-QUERY-f_depositario}
  DISPLAY ed_forma_cartao 
      WITH FRAME f_mensagem.
  ENABLE ed_forma_cartao 
      WITH FRAME f_mensagem.
  {&OPEN-BROWSERS-IN-QUERY-f_mensagem}
  VIEW FRAME f_encobre_cartao.
  {&OPEN-BROWSERS-IN-QUERY-f_encobre_cartao}
  VIEW w_captura_cartao.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verifica_cartao_lido w_captura_cartao 
PROCEDURE verifica_cartao_lido :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    /* O cartão deve ter 40 caracteres */
    IF  LENGTH(ed_dscartao) <> 40  THEN
        DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "    ATENÇÃO",
                            INPUT "",
                            INPUT "",
                            INPUT "Erro de Leitura!",
                            INPUT "",
                            INPUT "").
    
            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.
    
            RETURN.
        END.
    
    RUN procedures/valida_cartao.p (INPUT  ed_dscartao,
                                    OUTPUT glb_idsenlet,
                                    OUTPUT aux_flgderro).
                                                                        
        RUN procedures/grava_log.p (INPUT "Cartão valido - " + STRING(aux_flgderro,"NAO/SIM")).    
    
    IF  NOT aux_flgderro  THEN
        DO:
                        RUN procedures/grava_log.p (INPUT "Chamada para Controle de Foco").
                        
            /* desativa o controle de foco */
            RUN procedures/controle_foco.p (INPUT NO).
                        
                        RUN procedures/grava_log.p (INPUT "Controle Foco - OK").

            /* esconde a mensagem de "RETIRE O SEU CARTAO" */
            FRAME f_mensagem:VISIBLE = NO.

            /* verifica se tem senha de letras ou não */
            IF  glb_idtipcar = 2 OR (glb_idtipcar = 1 AND SUBSTRING(STRING(glb_nrcartao),1,1) <> "9")  THEN /* cartão de usuário */
                DO:
                    /* para quem nao tem letras, pede cpf */
                    IF  NOT glb_idsenlet  THEN
                        DO:
                            RUN procedures/grava_log.p (INPUT "Solicitacao CPF").
                                                        
                            RUN senha_cpf.w (OUTPUT aux_flgderro).
                                                        
                            RUN procedures/grava_log.p (INPUT "CPF - " + STRING(aux_flgderro,"NOK/OK")).

                            /* se pasosu a senha com CPF, informa sobre as letras */
                            IF  NOT aux_flgderro  THEN
                                DO:
                                    RUN procedures/grava_log.p (INPUT "Solicitacao Letras").                                                                        
                                    
                                    RUN senha_letras_mensagem.w (OUTPUT aux_flgderro).
                                    
                                    RUN procedures/grava_log.p (INPUT "Letras - " + STRING(aux_flgderro,"NOK/OK")).
                                END.
                        END.
                    ELSE
                        DO:
                            RUN procedures/grava_log.p (INPUT "Solicitacao Senha Numérica").
                                                        
                            RUN senha.w (OUTPUT aux_flgderro).
                                                        
                            RUN procedures/grava_log.p (INPUT "Senha Numérica - " + STRING(aux_flgderro,"NOK/OK")).

                            /* como eh o "login", solicita senha de letras */
                            IF  NOT aux_flgderro  THEN
                                DO:
                                    RUN procedures/grava_log.p (INPUT "Solicitacao Letras").                                                                        
                                    
                                    RUN senha_letras.w (OUTPUT aux_flgderro).
                                    
                                    RUN procedures/grava_log.p (INPUT "Letras - " + STRING(aux_flgderro,"NOK/OK")).
                                END.
                                                                        
                    END.
                END.
    
            IF  NOT aux_flgderro  THEN
                DO:
                    /* Verifica se eh Cartao Magnetico e Cartão de operador */
                    IF  glb_idtipcar = 1 AND SUBSTRING(STRING(glb_nrcartao),1,1) = "9"  THEN
                        DO:
                            RUN senha.w (OUTPUT aux_flgderro).

                            IF  NOT aux_flgderro  THEN
                                RUN manutencao.w.
                        END.
                    ELSE
                        DO:
                            /* carrega os dados do associado */
                            RUN procedures/busca_associado.p ( INPUT glb_nrdconta,
                                                               INPUT 0,
                                                              OUTPUT glb_cdagectl,  
                                                              OUTPUT glb_nmrescop,  
                                                              OUTPUT glb_nmtitula,
                                                              OUTPUT glb_flgmigra,                                                              
                                                              OUTPUT glb_flgbinss,
                                                              OUTPUT aux_flgderro).

                            IF  aux_flgderro  THEN
                                DO:
                                    RUN mensagem.w (INPUT YES,
                                                    INPUT "    ATENÇÃO",
                                                    INPUT "",
                                                    INPUT "",
                                                    INPUT "Erro na verificação",
                                                    INPUT "dos dados.",
                                                    INPUT "").
                                    
                                    PAUSE 3 NO-MESSAGE.
                                    h_mensagem:HIDDEN = YES.

                                    /* ativa o controle de foco */
                                    RUN procedures/controle_foco.p (INPUT YES).
                                    
                                    RETURN.
                                END.

                            /* verifica se existem banner a ser exibido ao cooperado */
                            RUN procedures/verifica_banner.p (INPUT glb_nrdconta,
                                                              INPUT glb_tpusucar,
                                                             OUTPUT aux_idbanner,
                                                             OUTPUT aux_flgderro).

                            /* verifica se deve mostrar banner  */
                            DO aux_contbann = 1 TO NUM-ENTRIES(aux_idbanner, ","):
                                
                                /* Se retornar ID da Prova de Vida, associa var global */
                                IF  INTE(ENTRY(aux_contbann, aux_idbanner, ",")) = 1 THEN 
                                    ASSIGN glb_flgdinss = YES.

                                RUN exibe_banner.w (INPUT INTEGER(ENTRY(aux_contbann, aux_idbanner, ",")),
                                                   OUTPUT aux_flgderro).
                            END.
                            
                            DO WHILE TRUE:

                                RUN cartao_opcoes.w.
                                    
                                IF  RETURN-VALUE = "OK"  THEN
                                    DO:
                                        RUN cartao_aviso_continuar.w.

                                        IF  RETURN-VALUE = "OK"  THEN
                                            NEXT.
                                    END.
                                LEAVE.
                                    
                            END.
                        END.
                END.

            /* ativa o controle de foco */
            RUN procedures/controle_foco.p (INPUT YES).

            /* limpa os dados do associado */
            ASSIGN glb_cdcooper = 0
                   glb_cdagectl = 0
                   glb_nmrescop = ""
                   glb_nrcartao = 0
                   glb_nrdconta = 0
                   glb_nmtitula = ""
                   glb_flgmigra = NO
                   glb_flgdinss = NO
                   glb_flmsgtaa = NO.
        END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verifica_insercao w_captura_cartao 
PROCEDURE verifica_insercao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

     /* verifica se o cartao foi inserido */
     SET-SIZE(stsenso) = 1.
     SET-SIZE(sttrava) = 1.
     SET-SIZE(stbuff1) = 1.
     SET-SIZE(stbuff2) = 1.
     SET-SIZE(stbuff3) = 1.

     aux_flcartao = NO.
     
         RUN WinStatusLDIP IN aux_xfsliteh
                    (INPUT GET-POINTER-VALUE(stsenso),
                     INPUT GET-POINTER-VALUE(sttrava), 
                     INPUT GET-POINTER-VALUE(stbuff1), 
                     INPUT GET-POINTER-VALUE(stbuff2), 
                     INPUT GET-POINTER-VALUE(stbuff3), 
                     OUTPUT LT_Resp).

         /* cartao inserido */
         IF  GET-BYTE(stsenso,1) = 3  THEN
             DO:
                 ASSIGN aux_flcartao = YES
                        ed_forma_cartao:SCREEN-VALUE IN FRAME f_mensagem = "RETIRE".

                 FRAME f_depositario:VISIBLE = NO.
                 LEAVE.
             END.

     SET-SIZE(stsenso) = 0.
     SET-SIZE(sttrava) = 0.
     SET-SIZE(stbuff1) = 0.
     SET-SIZE(stbuff2) = 0.
     SET-SIZE(stbuff3) = 0.

     
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

