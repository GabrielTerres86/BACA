&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_debaut_exclusao_confirmar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_debaut_exclusao_confirmar 
/* ..............................................................................

Procedure: cartao_pagamento_debaut_exclusao_confirmar.w
Objetivo : Tela de confirmar exclusao de débito automático
Autor    : Lucas Lunelli
Data     : Setembro/2014

Ultima alteração: 30/05/2016 - Alteraçoes Oferta DEBAUT Sicredi (Lucas Lunelli - [PROJ320])

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

DEFINE INPUT  PARAM par_nmempres     AS CHAR         NO-UNDO.
DEFINE INPUT  PARAM par_cdrefere     AS CHAR         NO-UNDO.
DEFINE INPUT  PARAM par_cdhistor     AS INTE         NO-UNDO.
DEFINE INPUT  PARAM par_cdempcon     AS INTE         NO-UNDO.
DEFINE INPUT  PARAM par_cdsegmto     AS INTE         NO-UNDO.
DEFINE INPUT  PARAM par_idmotivo     AS INTE         NO-UNDO.
DEFINE OUTPUT PARAM par_flgderro     AS LOGI         NO-UNDO.

/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_debaut_exclusao_confirmar

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-37 IMAGE-40 RECT-133 RECT-134 Btn_D ~
Btn_H 
&Scoped-Define DISPLAYED-OBJECTS ed_nmempres ed_cdrefere 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_debaut_exclusao_confirmar AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_D 
     LABEL "CONFIRMAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_H 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_cdrefere AS CHARACTER FORMAT "x(17)":U 
     VIEW-AS FILL-IN 
     SIZE 75 BY 1.19
     FONT 14 NO-UNDO.

DEFINE VARIABLE ed_nmempres AS CHARACTER FORMAT "X(20)":U 
     VIEW-AS FILL-IN 
     SIZE 75.2 BY 1.19
     FONT 14 NO-UNDO.

DEFINE IMAGE IMAGE-37
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-40
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE RECTANGLE RECT-100
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 2 .

DEFINE RECTANGLE RECT-133
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 77.2 BY 1.67.

DEFINE RECTANGLE RECT-134
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 77 BY 1.67.

DEFINE RECTANGLE RECT-98
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-99
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_debaut_exclusao_confirmar
     ed_nmempres AT ROW 15.91 COL 50 COLON-ALIGNED NO-LABEL WIDGET-ID 256
     ed_cdrefere AT ROW 19.05 COL 126 RIGHT-ALIGNED NO-LABEL WIDGET-ID 254
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 156
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 158
     "DESEJA EXCLUIR A AUTORIZAÇÃO" VIEW-AS TEXT
          SIZE 138 BY 3.33 AT ROW 6.91 COL 12.2 WIDGET-ID 286
          FGCOLOR 1 FONT 19
     "Identificador:" VIEW-AS TEXT
          SIZE 22 BY 1.19 AT ROW 19.05 COL 29 WIDGET-ID 262
          FONT 14
     "DÉBITO AUTOMÁTICO" VIEW-AS TEXT
          SIZE 100 BY 3.33 AT ROW 1.48 COL 32 WIDGET-ID 214
          FGCOLOR 1 FONT 10
     "Empresa:" VIEW-AS TEXT
          SIZE 16.8 BY 1.19 AT ROW 16.14 COL 33.8 WIDGET-ID 264
          FONT 14
     "DE DÉBITO AUTOMÁTICO?" VIEW-AS TEXT
          SIZE 106 BY 3.33 AT ROW 10.71 COL 28.2 WIDGET-ID 288
          FGCOLOR 1 FONT 19
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-37 AT ROW 24.24 COL 1 WIDGET-ID 148
     IMAGE-40 AT ROW 24.24 COL 156 WIDGET-ID 218
     RECT-133 AT ROW 15.67 COL 51 WIDGET-ID 258
     RECT-134 AT ROW 18.81 COL 51 WIDGET-ID 260
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
  CREATE WINDOW w_debaut_exclusao_confirmar ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.57
         WIDTH              = 160
         MAX-HEIGHT         = 35.76
         MAX-WIDTH          = 272.8
         VIRTUAL-HEIGHT     = 35.76
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
ASSIGN w_debaut_exclusao_confirmar = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_debaut_exclusao_confirmar
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_debaut_exclusao_confirmar
   FRAME-NAME                                                           */
/* SETTINGS FOR FILL-IN ed_cdrefere IN FRAME f_debaut_exclusao_confirmar
   NO-ENABLE ALIGN-R                                                    */
/* SETTINGS FOR FILL-IN ed_nmempres IN FRAME f_debaut_exclusao_confirmar
   NO-ENABLE                                                            */
ASSIGN 
       ed_nmempres:READ-ONLY IN FRAME f_debaut_exclusao_confirmar        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_debaut_exclusao_confirmar
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_debaut_exclusao_confirmar
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_debaut_exclusao_confirmar
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_debaut_exclusao_confirmar:HANDLE
       ROW             = 1.71
       COLUMN          = 17
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_debaut_exclusao_confirmar */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_debaut_exclusao_confirmar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_debaut_exclusao_confirmar w_debaut_exclusao_confirmar
ON END-ERROR OF w_debaut_exclusao_confirmar
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_debaut_exclusao_confirmar w_debaut_exclusao_confirmar
ON WINDOW-CLOSE OF w_debaut_exclusao_confirmar
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_debaut_exclusao_confirmar
ON ANY-KEY OF Btn_D IN FRAME f_debaut_exclusao_confirmar /* CONFIRMAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_debaut_exclusao_confirmar
ON CHOOSE OF Btn_D IN FRAME f_debaut_exclusao_confirmar /* CONFIRMAR */
DO:
    RUN procedures/exclui_autorizacao_debito.p (INPUT par_nmempres, 
                                                INPUT par_cdrefere,
                                                INPUT par_cdhistor,
                                                INPUT par_cdempcon,
                                                INPUT par_cdsegmto,
                                                INPUT par_idmotivo,
                                               OUTPUT par_flgderro).
    IF  par_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "NOK".
        END.

    /* verifica se finalizou a operacao */
    IF  RETURN-VALUE = "OK"  THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "OK".
        END.
    ELSE
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "NOK".
        END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_debaut_exclusao_confirmar
ON ANY-KEY OF Btn_H IN FRAME f_debaut_exclusao_confirmar /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_debaut_exclusao_confirmar
ON CHOOSE OF Btn_H IN FRAME f_debaut_exclusao_confirmar /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_debaut_exclusao_confirmar OCX.Tick
PROCEDURE temporizador.t_debaut_exclusao_confirmar.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_debaut_exclusao_confirmar.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_debaut_exclusao_confirmar 


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
    FRAME f_debaut_exclusao_confirmar:LOAD-MOUSE-POINTER("blank.cur").

    ASSIGN chtemporizador:t_debaut_exclusao_confirmar:INTERVAL = glb_nrtempor.

    ASSIGN ed_nmempres:SCREEN-VALUE = par_nmempres
           ed_cdrefere:SCREEN-VALUE = par_cdrefere.

    APPLY "ENTRY" TO Btn_H.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_debaut_exclusao_confirmar  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_pagamento_debaut_exclusao_confirmar.wrx":U ).
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
ELSE MESSAGE "cartao_pagamento_debaut_exclusao_confirmar.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_debaut_exclusao_confirmar  _DEFAULT-DISABLE
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
  HIDE FRAME f_debaut_exclusao_confirmar.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_debaut_exclusao_confirmar  _DEFAULT-ENABLE
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
  DISPLAY ed_nmempres ed_cdrefere 
      WITH FRAME f_debaut_exclusao_confirmar.
  ENABLE IMAGE-37 IMAGE-40 RECT-133 RECT-134 Btn_D Btn_H 
      WITH FRAME f_debaut_exclusao_confirmar.
  {&OPEN-BROWSERS-IN-QUERY-f_debaut_exclusao_confirmar}
  VIEW w_debaut_exclusao_confirmar.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_debaut_exclusao_confirmar 
PROCEDURE tecla :
chtemporizador:t_debaut_exclusao_confirmar:INTERVAL = 0.

    IF  KEY-FUNCTION(LASTKEY) = "D"                           AND
        Btn_D:SENSITIVE IN FRAME f_debaut_exclusao_confirmar  THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                           AND
        Btn_H:SENSITIVE IN FRAME f_debaut_exclusao_confirmar  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_debaut_exclusao_confirmar:INTERVAL = glb_nrtempor.    
    
    IF  RETURN-VALUE = "OK"  THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.    
            RETURN "OK".
        END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

