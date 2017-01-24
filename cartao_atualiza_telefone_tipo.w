&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_cartao_atualiza_telefone_tipo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_cartao_atualiza_telefone_tipo 
/* ..............................................................................

Procedure: cartao_atualiza_telefone_tipo.w
Objetivo : Tela para informar o tipo do Telefone alterado
Autor    : Guilherme/SUPERO
Data     : Novembro/2016

Ultima alteração:

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

DEFINE INPUT  PARAM par_nrdoddd         AS CHAR                         NO-UNDO.
DEFINE INPUT  PARAM par_nrdofone        AS CHAR                         NO-UNDO.
DEFINE OUTPUT PARAM par_continua        AS LOGICAL                      NO-UNDO.

DEFINE VARIABLE aux_flgderro            AS LOGICAL                      NO-UNDO.
DEFINE VARIABLE aux_flagsair            AS LOGICAL                      NO-UNDO.
DEFINE VARIABLE aux_tptelefo            AS INTEGER                      NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_cartao_atualiza_telefone_tipo

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-41 IMAGE-34 IMAGE-43 IMAGE-44 ~
ed_mensagem Btn_B Btn_F Btn_C Btn_D 
&Scoped-Define DISPLAYED-OBJECTS ed_mensagem 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_cartao_atualiza_telefone_tipo AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_B 
     LABEL "RESIDENCIAL" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_C 
     LABEL "CELULAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_D AUTO-END-KEY 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_F 
     LABEL "COMERCIAL" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_mensagem AS CHARACTER INITIAL "                                                                                                             Selecione a identificação do seu telefone:" 
     VIEW-AS EDITOR
     SIZE 119 BY 4.43
     BGCOLOR 7 FGCOLOR 14 FONT 8 NO-UNDO.

DEFINE IMAGE IMAGE-34
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-41
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-43
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-44
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE RECTANGLE RECT-101
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-102
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-103
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 2 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_cartao_atualiza_telefone_tipo
     ed_mensagem AT ROW 6.76 COL 139 RIGHT-ALIGNED NO-LABEL WIDGET-ID 164 NO-TAB-STOP 
     Btn_B AT ROW 14.1 COL 6 WIDGET-ID 178
     Btn_F AT ROW 14.1 COL 94.4 WIDGET-ID 130
     Btn_C AT ROW 19.1 COL 6 WIDGET-ID 184
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 132
     "    ATUALIZAÇÃO TELEFONE" VIEW-AS TEXT
          SIZE 122 BY 3.33 AT ROW 1.48 COL 21 WIDGET-ID 128
          FGCOLOR 1 FONT 13
     RECT-101 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-102 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-103 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-41 AT ROW 14.24 COL 156 WIDGET-ID 176
     IMAGE-34 AT ROW 14.24 COL 1 WIDGET-ID 182
     IMAGE-43 AT ROW 19.24 COL 1 WIDGET-ID 186
     IMAGE-44 AT ROW 24.29 COL 1 WIDGET-ID 188
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 160 BY 28.57 WIDGET-ID 100.


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
  CREATE WINDOW w_cartao_atualiza_telefone_tipo ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.57
         WIDTH              = 160
         MAX-HEIGHT         = 34.33
         MAX-WIDTH          = 272.8
         VIRTUAL-HEIGHT     = 34.33
         VIRTUAL-WIDTH      = 272.8
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
ASSIGN w_cartao_atualiza_telefone_tipo = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_cartao_atualiza_telefone_tipo
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_cartao_atualiza_telefone_tipo
   NOT-VISIBLE FRAME-NAME                                               */
/* SETTINGS FOR EDITOR ed_mensagem IN FRAME f_cartao_atualiza_telefone_tipo
   ALIGN-R                                                              */
ASSIGN 
       ed_mensagem:AUTO-INDENT IN FRAME f_cartao_atualiza_telefone_tipo      = TRUE
       ed_mensagem:READ-ONLY IN FRAME f_cartao_atualiza_telefone_tipo        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-101 IN FRAME f_cartao_atualiza_telefone_tipo
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-102 IN FRAME f_cartao_atualiza_telefone_tipo
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-103 IN FRAME f_cartao_atualiza_telefone_tipo
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_cartao_atualiza_telefone_tipo:HANDLE
       ROW             = 2.43
       COLUMN          = 10
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_atualiza_telefone_tipo */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_cartao_atualiza_telefone_tipo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_atualiza_telefone_tipo w_cartao_atualiza_telefone_tipo
ON END-ERROR OF w_cartao_atualiza_telefone_tipo
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_atualiza_telefone_tipo w_cartao_atualiza_telefone_tipo
ON WINDOW-CLOSE OF w_cartao_atualiza_telefone_tipo
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_B
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_B w_cartao_atualiza_telefone_tipo
ON ANY-KEY OF Btn_B IN FRAME f_cartao_atualiza_telefone_tipo /* RESIDENCIAL */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_B w_cartao_atualiza_telefone_tipo
ON CHOOSE OF Btn_B IN FRAME f_cartao_atualiza_telefone_tipo /* RESIDENCIAL */
DO:
    ASSIGN aux_tptelefo = 1. /* 1-RESIDENCIAL */

    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).

    par_continua = TRUE.

    IF  NOT aux_flgderro  THEN DO:
        /* puxa o frame principal pra frente */
/*         h_principal:MOVE-TO-TOP(). */

        RUN procedures/atualiza_telefone.p (INPUT  par_nrdoddd,
                                            INPUT  par_nrdofone,
                                            INPUT  aux_tptelefo,
                                            OUTPUT aux_flgderro).
        IF  aux_flgderro   THEN DO:
            par_continua = FALSE.
            w_cartao_atualiza_telefone_tipo:MOVE-TO-TOP().

            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "NOK".
        END.
        ELSE DO:
            /* puxa o frame principal pra frente */
/*             h_principal:MOVE-TO-TOP(). */
        END.

        w_cartao_atualiza_telefone_tipo:MOVE-TO-TOP().

        APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
        RETURN "OK".
    END.
    ELSE DO:

        w_cartao_atualiza_telefone_tipo:MOVE-TO-TOP().
        par_continua = FALSE.
        APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
        RETURN "OK".
    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_C
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_C w_cartao_atualiza_telefone_tipo
ON ANY-KEY OF Btn_C IN FRAME f_cartao_atualiza_telefone_tipo /* CELULAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_C w_cartao_atualiza_telefone_tipo
ON CHOOSE OF Btn_C IN FRAME f_cartao_atualiza_telefone_tipo /* CELULAR */
DO:
    ASSIGN aux_tptelefo = 2. /* 2-CELULAR */


    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).

    par_continua = TRUE.

    IF  NOT aux_flgderro  THEN DO:
        /* puxa o frame principal pra frente */
/*         h_principal:MOVE-TO-TOP(). */

        RUN procedures/atualiza_telefone.p (INPUT  par_nrdoddd,
                                            INPUT  par_nrdofone,
                                            INPUT  aux_tptelefo,
                                            OUTPUT aux_flgderro).
        IF  aux_flgderro   THEN DO:
            par_continua = FALSE.
            w_cartao_atualiza_telefone_tipo:MOVE-TO-TOP().

            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "NOK".
        END.
        ELSE DO:
            /* puxa o frame principal pra frente */
/*             h_principal:MOVE-TO-TOP(). */
        END.

        w_cartao_atualiza_telefone_tipo:MOVE-TO-TOP().

        APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
        RETURN "OK".
    END.
    ELSE DO:

        w_cartao_atualiza_telefone_tipo:MOVE-TO-TOP().
        par_continua = FALSE.
        APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
        RETURN "OK".
    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_atualiza_telefone_tipo
ON ANY-KEY OF Btn_D IN FRAME f_cartao_atualiza_telefone_tipo /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_atualiza_telefone_tipo
ON CHOOSE OF Btn_D IN FRAME f_cartao_atualiza_telefone_tipo /* VOLTAR */
DO:

    par_continua = FALSE.

    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_F
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_cartao_atualiza_telefone_tipo
ON ANY-KEY OF Btn_F IN FRAME f_cartao_atualiza_telefone_tipo /* COMERCIAL */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_cartao_atualiza_telefone_tipo
ON CHOOSE OF Btn_F IN FRAME f_cartao_atualiza_telefone_tipo /* COMERCIAL */
DO:
    ASSIGN aux_tptelefo = 3. /* 3-COMERCIAL */


    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).

    par_continua = TRUE.

    IF  NOT aux_flgderro  THEN DO:
        /* puxa o frame principal pra frente */
/*         h_principal:MOVE-TO-TOP(). */

        RUN procedures/atualiza_telefone.p (INPUT  par_nrdoddd,
                                            INPUT  par_nrdofone,
                                            INPUT  aux_tptelefo,
                                            OUTPUT aux_flgderro).
        IF  aux_flgderro   THEN DO:
            par_continua = FALSE.
            w_cartao_atualiza_telefone_tipo:MOVE-TO-TOP().

            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "NOK".
        END.
        ELSE DO:
            /* puxa o frame principal pra frente */
/*             h_principal:MOVE-TO-TOP(). */
        END.

        w_cartao_atualiza_telefone_tipo:MOVE-TO-TOP().

        APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
        RETURN "OK".
    END.
    ELSE DO:

        w_cartao_atualiza_telefone_tipo:MOVE-TO-TOP().
        par_continua = FALSE.
        APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
        RETURN "OK".
    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_cartao_atualiza_telefone_tipo OCX.Tick
PROCEDURE temporizador.t_cartao_atualiza_telefone_tipo.Tick .
APPLY "CHOOSE" TO Btn_D IN FRAME f_cartao_atualiza_telefone_tipo.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_cartao_atualiza_telefone_tipo 


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
    FRAME f_cartao_atualiza_telefone_tipo:LOAD-MOUSE-POINTER("blank.cur").

    chtemporizador:t_cartao_atualiza_telefone_tipo:INTERVAL = glb_nrtempor.

    /* coloca o foco na senha */
    APPLY "ENTRY" TO Btn_D.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_cartao_atualiza_telefone_tipo  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_atualiza_telefone_tipo.wrx":U ).
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
ELSE MESSAGE "cartao_atualiza_telefone_tipo.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_cartao_atualiza_telefone_tipo  _DEFAULT-DISABLE
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
  HIDE FRAME f_cartao_atualiza_telefone_tipo.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_cartao_atualiza_telefone_tipo  _DEFAULT-ENABLE
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
  DISPLAY ed_mensagem 
      WITH FRAME f_cartao_atualiza_telefone_tipo.
  ENABLE IMAGE-41 IMAGE-34 IMAGE-43 IMAGE-44 ed_mensagem Btn_B Btn_F Btn_C 
         Btn_D 
      WITH FRAME f_cartao_atualiza_telefone_tipo.
  {&OPEN-BROWSERS-IN-QUERY-f_cartao_atualiza_telefone_tipo}
  VIEW w_cartao_atualiza_telefone_tipo.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE limpa w_cartao_atualiza_telefone_tipo 
PROCEDURE limpa :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_cartao_atualiza_telefone_tipo 
PROCEDURE tecla :
ASSIGN chtemporizador:t_cartao_atualiza_telefone_tipo:INTERVAL = 0.

    IF  KEY-FUNCTION(LASTKEY) = "B"               AND
        Btn_B:SENSITIVE IN FRAME f_cartao_atualiza_telefone_tipo  THEN
        APPLY "CHOOSE" TO Btn_B.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "C"               AND
        Btn_C:SENSITIVE IN FRAME f_cartao_atualiza_telefone_tipo  THEN
        APPLY "CHOOSE" TO Btn_C.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "F"               AND
        Btn_F:SENSITIVE IN FRAME f_cartao_atualiza_telefone_tipo  THEN
        APPLY "CHOOSE" TO Btn_F.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "D"               AND
        Btn_D:SENSITIVE IN FRAME f_cartao_atualiza_telefone_tipo  THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_cartao_atualiza_telefone_tipo:INTERVAL = glb_nrtempor.

    IF  RETURN-VALUE = "OK"  THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.    
            RETURN "OK".
        END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

