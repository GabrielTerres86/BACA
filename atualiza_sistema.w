&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_atualizacao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_atualizacao 
/* ..............................................................................

Procedure: mensagem.w
Objetivo : Tela para exibir as mensagens do sistema
Autor    : Evandro
Data     : Janeiro 2010

Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

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
DEFINE INPUT PARAM par_flreboot     AS LOGICAL              NO-UNDO.

/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }


DEFINE STREAM str_1.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_atualiza_sistema

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ed_log 
&Scoped-Define DISPLAYED-OBJECTS ed_log 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_atualizacao AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE VARIABLE ed_log AS CHARACTER 
     VIEW-AS EDITOR NO-BOX
     SIZE 80 BY 27.62
     FGCOLOR 2  NO-UNDO.

DEFINE VARIABLE ed_dsmensag2 AS CHARACTER FORMAT "X(30)":U 
      VIEW-AS TEXT 
     SIZE 67 BY .95
     BGCOLOR 8 FGCOLOR 12 FONT 11 NO-UNDO.

DEFINE VARIABLE ed_dsmensag4 AS CHARACTER FORMAT "X(30)":U 
      VIEW-AS TEXT 
     SIZE 67 BY .95
     BGCOLOR 8 FGCOLOR 12 FONT 11 NO-UNDO.

DEFINE VARIABLE ed_tlmensag AS CHARACTER FORMAT "X(30)":U 
      VIEW-AS TEXT 
     SIZE 50.2 BY 3.1
     BGCOLOR 8 FGCOLOR 12 FONT 10 NO-UNDO.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 71 BY 10
     BGCOLOR 8 .

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 69 BY 9.52
     BGCOLOR 8 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_atualiza_sistema
     ed_log AT ROW 1 COL 1 NO-LABEL WIDGET-ID 26
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 160 BY 28.57
         BGCOLOR 15  WIDGET-ID 100.

DEFINE FRAME f_mensagem
     ed_tlmensag AT ROW 1.52 COL 9 COLON-ALIGNED NO-LABEL WIDGET-ID 32 NO-TAB-STOP 
     ed_dsmensag2 AT ROW 6 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 28 NO-TAB-STOP 
     ed_dsmensag4 AT ROW 8.38 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 30 NO-TAB-STOP 
     RECT-2 AT ROW 1.05 COL 1.2 WIDGET-ID 8
     RECT-3 AT ROW 1.29 COL 2.2 WIDGET-ID 10
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 44.8 ROW 10.24
         SIZE 79 BY 10.05
         BGCOLOR 15  WIDGET-ID 200.


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
  CREATE WINDOW w_atualizacao ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.57
         WIDTH              = 160
         MAX-HEIGHT         = 28.57
         MAX-WIDTH          = 160
         VIRTUAL-HEIGHT     = 28.57
         VIRTUAL-WIDTH      = 160
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
                                                                        */
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME
ASSIGN w_atualizacao = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_atualizacao
  VISIBLE,,RUN-PERSISTENT                                               */
/* REPARENT FRAME */
ASSIGN FRAME f_mensagem:FRAME = FRAME f_atualiza_sistema:HANDLE.

/* SETTINGS FOR FRAME f_atualiza_sistema
   FRAME-NAME                                                           */
ASSIGN 
       ed_log:READ-ONLY IN FRAME f_atualiza_sistema        = TRUE.

/* SETTINGS FOR FRAME f_mensagem
                                                                        */
ASSIGN 
       ed_dsmensag2:READ-ONLY IN FRAME f_mensagem        = TRUE.

ASSIGN 
       ed_dsmensag4:READ-ONLY IN FRAME f_mensagem        = TRUE.

ASSIGN 
       ed_tlmensag:READ-ONLY IN FRAME f_mensagem        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_atualiza_sistema:HANDLE
       ROW             = 2.43
       COLUMN          = 141
       HEIGHT          = 4.76
       WIDTH           = 20
       WIDGET-ID       = 28
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: tempo */
      temporizador:MOVE-AFTER(ed_log:HANDLE IN FRAME f_atualiza_sistema).

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_atualizacao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_atualizacao w_atualizacao
ON END-ERROR OF w_atualizacao
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_atualizacao w_atualizacao
ON WINDOW-CLOSE OF w_atualizacao
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_atualizacao OCX.Tick
PROCEDURE temporizador.tempo.Tick .
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  None required for OCX.
  Notes:       
------------------------------------------------------------------------------*/

    DO WITH FRAME f_atualiza_sistema:

        /* gera uma copia do log para conseguir ler enquanto o mesmo eh atualizado */
        UNIX SILENT VALUE("COPY C:\Temp\download.log C:\Temp\download2.log").

        ed_log:READ-FILE("C:\Temp\download2.log").
        ed_log:MOVE-TO-EOF().
    END.

    /* Verifica LOG */
    IF  ed_log:SCREEN-VALUE MATCHES("*Operacao Concluida*")  THEN
        DO:
            UNIX SILENT VALUE("DEL /Q C:\Temp\download.log C:\Temp\download2.log").

            /* se estiver configurado, confirma update */
            IF  glb_cdcoptfn <> 0  AND
                glb_nrterfin <> 0  AND
                glb_cdagetfn <> 0  THEN
                RUN procedures/confirma_update.p.
            
            IF  par_flreboot  THEN
                RUN procedures/efetua_reboot.p.
            
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN.
        END.
    ELSE
    IF  ed_log:SCREEN-VALUE MATCHES("*Atualizacao Abortada*")  THEN
        DO WITH FRAME f_mensagem:
            /* Pára a atualizacao da tela */
            ASSIGN chtemporizador:tempo:INTERVAL = 0
                   ed_tlmensag:SCREEN-VALUE  = "    ERRO!"
                   ed_dsmensag2:SCREEN-VALUE = "   Problemas na Atualização."
                   ed_dsmensag4:SCREEN-VALUE = "     Terminal Indisponível.".
        END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_atualizacao 


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}
       CURRENT-WINDOW:X              = 0
       CURRENT-WINDOW:Y              = -12.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.


MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    RUN enable_UI.

    FRAME f_atualiza_sistema:LOAD-MOUSE-POINTER("blank.cur").
    FRAME f_mensagem:LOAD-MOUSE-POINTER("blank.cur").

    ASSIGN ed_tlmensag:SCREEN-VALUE  = " ATENÇÃO"
           ed_dsmensag2:SCREEN-VALUE = "   Sistema sendo atualizado."
           ed_dsmensag4:SCREEN-VALUE = "           Aguarde...".


    /* Derruba o script que controla o sistema aberto */
    DOS SILENT VALUE("TASKKILL /F /IM wscript.exe").

    /* Chama o script de atualizacao e joga saida para um log */
    DOS SILENT VALUE("START /B C:\TAA\atualiza_sistema.exe > C:\Temp\download.log").

      
    /* Atualiza o log na tela a cada 0,2s */
    chtemporizador:tempo:INTERVAL = 200.
    

    IF NOT THIS-PROCEDURE:PERSISTENT THEN
       WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_atualizacao  _CONTROL-LOAD
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

OCXFile = SEARCH( "atualiza_sistema.wrx":U ).
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
ELSE MESSAGE "atualiza_sistema.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_atualizacao  _DEFAULT-DISABLE
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
  HIDE FRAME f_atualiza_sistema.
  HIDE FRAME f_mensagem.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_atualizacao  _DEFAULT-ENABLE
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
  DISPLAY ed_log 
      WITH FRAME f_atualiza_sistema.
  ENABLE ed_log 
      WITH FRAME f_atualiza_sistema.
  {&OPEN-BROWSERS-IN-QUERY-f_atualiza_sistema}
  DISPLAY ed_tlmensag ed_dsmensag2 ed_dsmensag4 
      WITH FRAME f_mensagem.
  ENABLE RECT-2 RECT-3 ed_tlmensag ed_dsmensag2 ed_dsmensag4 
      WITH FRAME f_mensagem.
  {&OPEN-BROWSERS-IN-QUERY-f_mensagem}
  VIEW w_atualizacao.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

