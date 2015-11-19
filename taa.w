&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_taa
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_taa 
/* ..............................................................................

Procedure: taa.w
Objetivo : Tela para inicializacao do sistema e dos perifericos
Autor    : Evandro
Data     : Janeiro 2010

Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

                  09/04/2014 - Executar procedure atualiza_nmserver.p para
                               alterar nmserver para projeto Oracle (David).
                               
                  08/12/2014 - Instância de novo handle de frame para melhor
                               controle de navegação de tela em caso de erros
                               (Lunelli)

............................................................................... */

/*----------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
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
{ includes/var_taa.i "NEW" }
{ includes/var_xfs_lite.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_inicializando

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS img_cecred ed_status 
&Scoped-Define DISPLAYED-OBJECTS ed_status 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_taa AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE VARIABLE ed_status AS CHARACTER 
     VIEW-AS EDITOR NO-BOX
     SIZE 111 BY 13.1
     FGCOLOR 2 FONT 11 NO-UNDO.

DEFINE IMAGE img_cecred
     FILENAME "Imagens/logo_inicia.jpg":U
     SIZE 121 BY 8.57.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_inicializando
     ed_status AT ROW 15.29 COL 44 NO-LABEL WIDGET-ID 4 NO-TAB-STOP 
     img_cecred AT ROW 5.05 COL 21 WIDGET-ID 8
    WITH 1 DOWN NO-BOX OVERLAY 
         NO-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 160 BY 28.57
         BGCOLOR 15 .


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
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW w_taa ASSIGN
         HIDDEN             = YES
         TITLE              = "Autoatendimento"
         COLUMN             = 18
         ROW                = 6.52
         HEIGHT             = 28.57
         WIDTH              = 160
         MAX-HEIGHT         = 29.52
         MAX-WIDTH          = 204.8
         VIRTUAL-HEIGHT     = 29.52
         VIRTUAL-WIDTH      = 204.8
         SMALL-TITLE        = yes
         SHOW-IN-TASKBAR    = no
         CONTROL-BOX        = no
         MIN-BUTTON         = no
         MAX-BUTTON         = no
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR FRAME f_inicializando
   FRAME-NAME                                                           */
ASSIGN 
       FRAME f_inicializando:HIDDEN           = TRUE.

ASSIGN 
       ed_status:READ-ONLY IN FRAME f_inicializando        = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w_taa)
THEN w_taa:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME f_inicializando
/* Query rebuild information for FRAME f_inicializando
     _Query            is NOT OPENED
*/  /* FRAME f_inicializando */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_inicializando:HANDLE
       ROW             = 3.14
       COLUMN          = 9
       HEIGHT          = 1.43
       WIDTH           = 6
       TAB-STOP        = no
       WIDGET-ID       = 6
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: timer */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_taa
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_taa w_taa
ON END-ERROR OF w_taa /* Autoatendimento */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_taa w_taa
ON ERROR OF w_taa /* Autoatendimento */
ANYWHERE DO:

    APPLY 'WINDOW-CLOSE' TO CURRENT-WINDOW.
            
    RETURN NO-APPLY.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_taa w_taa
ON WINDOW-CLOSE OF w_taa /* Autoatendimento */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_taa OCX.Tick
PROCEDURE temporizador.timer.Tick .
DEFINE VARIABLE aux_interval AS INTEGER                 NO-UNDO.
    DEFINE VARIABLE aux_flgderro AS LOGICAL     INIT NO     NO-UNDO.
    
    /* coloca a janela no canto superior esquerdo */
    ASSIGN CURRENT-WINDOW:X = 0
           CURRENT-WINDOW:Y = -12
           ed_status:SCREEN-VALUE IN FRAME f_inicializando = "Aguarde..."
            
           /* Limpa os dados */
           glb_cdcooper = 0
           glb_nrcartao = 0
           glb_nrdconta = 0.


    /* pausa o temporizador */
    ASSIGN aux_interval                  = chtemporizador:timer:INTERVAL
           chtemporizador:timer:INTERVAL = 0.
    
    /* deixa o mouse transparente */
    FRAME f_inicializando:LOAD-MOUSE-POINTER("blank.cur").
    
    /* apaga o cursor que fica piscando quando campo de edicao */
    RUN procedures/xfs_lite.p PERSISTENT SET aux_xfsliteh.
    RUN apaga_cursor.


    /* ativa o controle de foco */
    RUN procedures/controle_foco.p (INPUT YES).


    RUN procedures/grava_log.p (INPUT "Inicializando sistema...").
    
    DO  WHILE TRUE:
        
        /* ---------- */
        ed_status:INSERT-STRING("Carregando Configurações...").
        RUN procedures/carrega_config.p (OUTPUT aux_flgderro).
    
        IF  aux_flgderro  THEN
            DO:
                ed_status:INSERT-STRING("NOK" + CHR(13)).
                LEAVE.
            END.
        ELSE
            ed_status:INSERT-STRING("OK" + CHR(13)).
    
    
        /* ---------- */
        ed_status:INSERT-STRING("Verificando Autorização...").
        RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).
    
        IF  aux_flgderro   THEN
            DO:
                ed_status:INSERT-STRING("NOK" + CHR(13)).
                LEAVE.
            END.
        ELSE
            DO:
                ed_status:INSERT-STRING("OK" + CHR(13)).


                /* verifica se deve fazer reboot do TAA */
                IF  glb_flreboot  THEN
                    DO:
                        /* verifica se acabou de efetuar o reboot */
                        RUN procedures/verifica_reboot.p (OUTPUT aux_flgderro).

                        /* se nao fez o reboot, faz */
                        IF  aux_flgderro          OR
                            RETURN-VALUE = "NOK"  THEN
                            RUN procedures/efetua_reboot.p.
                    END.
                ELSE
                /* verifica se deve atualizar o sistema */
                IF  glb_flupdate  THEN
                    RUN atualiza_sistema.w (INPUT YES).
            END.


        /* ---------- */
        ed_status:INSERT-STRING("Verificando Pendências...").
        RUN procedures/verifica_pendencias.p (OUTPUT aux_flgderro).
    
        IF  aux_flgderro   THEN
            DO:
                ed_status:INSERT-STRING("NOK" + CHR(13)).
                LEAVE.
            END.
        ELSE
            ed_status:INSERT-STRING("OK" + CHR(13)).

        
        /* ---------- */
        ed_status:INSERT-STRING("Inicializando Dispositivos:" + CHR(13)).


        /* ---------- */
        ed_status:INSERT-STRING("   Iniciando Teclados...").
        RUN procedures/inicializa_dispositivo.p (INPUT 8,
                                                 OUTPUT aux_flgderro).
    
        IF  aux_flgderro   THEN
            ed_status:INSERT-STRING("NOK" + CHR(13)).
        ELSE
            ed_status:INSERT-STRING("OK" + CHR(13)).



        /* ---------- */
        ed_status:INSERT-STRING("   Verificando PAINOP...").
        RUN procedures/inicializa_dispositivo.p (INPUT 9,
                                                 OUTPUT aux_flgderro).
    
        IF  aux_flgderro   THEN
            ed_status:INSERT-STRING("NOK" + CHR(13)).
        ELSE
            ed_status:INSERT-STRING("OK" + CHR(13)).


        /* Se o PAINOP estiver presente, configura o teclado do mesmo */
        IF  xfs_painop  THEN
            DO:
                ed_status:INSERT-STRING("   Configurando PAINOP...").    
            
                RUN configura_painop (OUTPUT aux_flgderro).

                IF  aux_flgderro   THEN
                    ed_status:INSERT-STRING("NOK" + CHR(13)).
                ELSE
                    ed_status:INSERT-STRING("OK" + CHR(13)).
            END.

        
        /* pelo sistema, considerar cassetes ok */
        sis_cassetes = YES.

        /* ---------- */
        ed_status:INSERT-STRING("   Abrindo Dispensador...").
        RUN procedures/inicializa_dispositivo.p (INPUT 1,
                                                 OUTPUT aux_flgderro).
    
        IF  aux_flgderro   THEN
            ed_status:INSERT-STRING("NOK" + CHR(13)).
        ELSE
            ed_status:INSERT-STRING("OK" + CHR(13)).


        /* ---------- */
        ed_status:INSERT-STRING("   Verificando Cassetes...").
        RUN procedures/inicializa_dispositivo.p (INPUT 2,
                                                 OUTPUT aux_flgderro).
    
        IF  aux_flgderro   THEN
            ed_status:INSERT-STRING("NOK" + CHR(13)).
        ELSE
            ed_status:INSERT-STRING("OK" + CHR(13)).


        /* ---------- */
        IF  glb_tpenvelo <> 0  THEN
            DO:
                ed_status:INSERT-STRING("   Abrindo Depositário...").
                RUN procedures/inicializa_dispositivo.p (INPUT 3,
                                                         OUTPUT aux_flgderro).
                
                IF  aux_flgderro   THEN
                    ed_status:INSERT-STRING("NOK" + CHR(13)).
                ELSE
                    ed_status:INSERT-STRING("OK" + CHR(13)).
            END.


        /* ---------- */
        ed_status:INSERT-STRING("   Verificando Leitora de Cartão...").
        RUN procedures/inicializa_dispositivo.p (INPUT 4,
                                                 OUTPUT aux_flgderro).
    
        IF  aux_flgderro   THEN
            ed_status:INSERT-STRING("NOK" + CHR(13)).
        ELSE
            ed_status:INSERT-STRING("OK" + CHR(13)).



        /* ---------- */
        ed_status:INSERT-STRING("   Verificando Leitora de Cod. Barras...").
        RUN procedures/inicializa_dispositivo.p (INPUT 7,
                                                 OUTPUT aux_flgderro).
    
        IF  aux_flgderro   THEN
            ed_status:INSERT-STRING("NOK" + CHR(13)).
        ELSE
            ed_status:INSERT-STRING("OK" + CHR(13)).


        /* ---------- */
        ed_status:INSERT-STRING("   Abrindo a Impressora...").
        RUN procedures/inicializa_dispositivo.p (INPUT 5,
                                                 OUTPUT aux_flgderro).
    
        IF  aux_flgderro   THEN
            ed_status:INSERT-STRING("NOK" + CHR(13)).
        ELSE
            ed_status:INSERT-STRING("OK" + CHR(13)).


        /* ---------- */
        ed_status:INSERT-STRING("   Verificando a Impressora...").
        RUN procedures/inicializa_dispositivo.p (INPUT 6,
                                                 OUTPUT aux_flgderro).
    
        IF  aux_flgderro   THEN
            ed_status:INSERT-STRING("NOK" + CHR(13)).
        ELSE
            ed_status:INSERT-STRING("OK" + CHR(13)).


        /* ---------- */
        ed_status:INSERT-STRING("Carregando o Suprimento...").
        RUN procedures/carrega_suprimento.p (OUTPUT aux_flgderro).

        IF  aux_flgderro   THEN
            DO:
                ed_status:INSERT-STRING("NOK" + CHR(13)).
                LEAVE.
            END.
        ELSE
            ed_status:INSERT-STRING("OK" + CHR(13)).

                /*****************************************************************/
        /** Solução temporária para alterar nome do domínio do WebSpeed **/
        /** de pkgprod.cecred.coop.br para taa.cecred.coop.br.          **/
        /** Alteração necessária para migração Oracle                   **/
        /*****************************************************************/
        IF  glb_nmserver = "pkgprod"  THEN
            DO:
                ed_status:INSERT-STRING("Atualizando o name server...").

                RUN procedures/atualiza_nmserver.p (OUTPUT aux_flgderro).    

                IF  aux_flgderro  THEN
                    DO:
                        ed_status:INSERT-STRING("NOK" + CHR(13)).
                        LEAVE.
                    END.
            END.

        LEAVE.
                
    END. /* Fim do WHILE */
    
    IF  NOT aux_flgderro   THEN
        DO:         
            RUN captura_cartao.w.

            chtemporizador:timer:INTERVAL = 5000. /* 5s */
        END.
    ELSE
        DO:
            /* Caso haja erro, aumenta o tempo de espera ate chegar em 5 min */
            IF  aux_interval < 300000  THEN /* 300s - 5min */
                chtemporizador:timer:INTERVAL = aux_interval + 5000. /* + 5s */
            ELSE
                /* Mantem o tempo máximo de 300s - 5min */
                chtemporizador:timer:INTERVAL = aux_interval.
        END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_taa 


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

    /* coloca a janela no canto superior esquerdo */
    ASSIGN CURRENT-WINDOW:X = 0
           CURRENT-WINDOW:Y = 0.

    ASSIGN h_inicializando = FRAME f_inicializando:HANDLE.

    ed_status:SCREEN-VALUE = "Aguarde...".
    chtemporizador:timer:INTERVAL = 5000. /* 5s */

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Apaga_cursor w_taa 
PROCEDURE Apaga_cursor :
/*------------------------------------------------------------------------------
  Purpose:     Apagar o cursor do mouse
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEF VAR aux_cddsumiu AS INT                                          NO-UNDO.

DO WHILE aux_cddsumiu >= 0:

   RUN ShowCursor IN aux_xfsliteh (INPUT 0, OUTPUT aux_cddsumiu).

END.  /*  Fim do DO WHILE  */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE configura_painop w_taa 
PROCEDURE configura_painop :
DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL  INIT NO     NO-UNDO.

DEFINE VARIABLE LayTec                  AS MEMPTR               NO-UNDO.
DEFINE VARIABLE buff                    AS CHAR     EXTENT 6    NO-UNDO.
    
    SET-SIZE(LayTec) = 30.

    
    PUT-BYTE(LayTec,06) = 30. /* A */
    PUT-BYTE(LayTec,07) = 48. /* B */
    PUT-BYTE(LayTec,08) = 46. /* C */
    PUT-BYTE(LayTec,09) = 32. /* D */
    
    PUT-BYTE(LayTec,10) = 18. /* E */
    PUT-BYTE(LayTec,04) = 33. /* F */
    PUT-BYTE(LayTec,03) = 34. /* G */
    PUT-BYTE(LayTec,02) = 14. /* CORRIGE - BACKSPACE */

    PUT-BYTE(LayTec,01) = 57. /* I - Nao usado */
    PUT-BYTE(LayTec,05) = 57. /* J - Nao usado */
    PUT-BYTE(LayTec,14) = 25. /* PAUSA - P */


    PUT-BYTE(LayTec,19) = 02. /* 1 */
    PUT-BYTE(LayTec,20) = 03. /* 2 */
    PUT-BYTE(LayTec,21) = 04. /* 3 */
    PUT-BYTE(LayTec,15) = 05. /* 4 */
    PUT-BYTE(LayTec,16) = 06. /* 5 */
    PUT-BYTE(LayTec,17) = 07. /* 6 */
    PUT-BYTE(LayTec,11) = 08. /* 7 */
    PUT-BYTE(LayTec,12) = 09. /* 8 */
    PUT-BYTE(LayTec,13) = 10. /* 9 */
    PUT-BYTE(LayTec,24) = 11. /* 0 */

    PUT-BYTE(LayTec,23) = 35. /* ANULA - H */
    PUT-BYTE(LayTec,25) = 28. /* ENTRA - ENTER */

    /* Valores Padroes */
    PUT-BYTE(LayTec,18) = 57.
    PUT-BYTE(LayTec,22) = 57.
    PUT-BYTE(LayTec,26) = 0.
    PUT-BYTE(LayTec,27) = 0.
    PUT-BYTE(LayTec,28) = 0.
    PUT-BYTE(LayTec,29) = 0.
    PUT-BYTE(LayTec,30) = 0.


    RUN WinGravaConfiguraTeclados IN aux_xfsliteh (
        INPUT  2, /* Teclado PAINOP */
        INPUT -1, /* Nao Altera - Sem Smart */
        INPUT -1, /* Nao Altera - Cartao de Passagem */
        INPUT -1, /* Nao Altera - So le a trilha 2 */
        INPUT  4, /* Layout Customizado */
        INPUT GET-POINTER-VALUE(LayTec), /* Layout Customizado */
        INPUT -1, /* Nao Altera - StartCode */
        INPUT -1, /* Nao Altera - StopCode */
        OUTPUT LT_Resp).



    buff = "".
    RUN procedures/atualiza_painop.p (INPUT buff).

    ASSIGN buff[1] = "                                " + STRING(glb_dsvertaa,"x(6)")
           buff[2] = "         CECRED - SISTEMA TAA".

    RUN procedures/atualiza_painop.p (INPUT buff).


    IF  LT_Resp = 0  THEN
        RETURN "OK".
    ELSE
        RETURN "NOK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_taa  _CONTROL-LOAD
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

OCXFile = SEARCH( "taa.wrx":U ).
IF OCXFile = ? THEN
  OCXFile = SEARCH(SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1,
                     R-INDEX(THIS-PROCEDURE:FILE-NAME, ".":U), "CHARACTER":U) + "wrx":U).

IF OCXFile <> ? THEN
DO:
  ASSIGN
    chtemporizador = temporizador:COM-HANDLE
    UIB_S = chtemporizador:LoadControls( OCXFile, "temporizador":U)
    temporizador:NAME = "temporizador":U
  .
  RUN initialize-controls IN THIS-PROCEDURE NO-ERROR.
END.
ELSE MESSAGE "taa.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_taa  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w_taa)
  THEN DELETE WIDGET w_taa.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_taa  _DEFAULT-ENABLE
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
  DISPLAY ed_status 
      WITH FRAME f_inicializando IN WINDOW w_taa.
  ENABLE img_cecred ed_status 
      WITH FRAME f_inicializando IN WINDOW w_taa.
  VIEW FRAME f_inicializando IN WINDOW w_taa.
  {&OPEN-BROWSERS-IN-QUERY-f_inicializando}
  VIEW w_taa.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Mostra_cursor w_taa 
PROCEDURE Mostra_cursor :
/*------------------------------------------------------------------------------
  Purpose:     Mostrar o cursor do mouse.
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEF VAR aux_cddsumiu AS INT        INIT -1                           NO-UNDO.

DO WHILE aux_cddsumiu < 0:

   RUN ShowCursor IN aux_xfsliteh (INPUT 1, OUTPUT aux_cddsumiu).

END.  /*  Fim do DO WHILE  */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

