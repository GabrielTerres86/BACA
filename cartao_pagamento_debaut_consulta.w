&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME w_debaut_consulta
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_debaut_consulta 
/*------------------------------------------------------------------------
Procedure: cartao_pagamento_debaut_consulta.w
Objetivo : Tela de consulta de débito automático
Autor    : Lucas Lunelli
Data     : Setembro/2014

Ultima alteração: 

------------------------------------------------------------------------*/
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

DEFINE TEMP-TABLE tt-debaut-consulta NO-UNDO
       FIELD nmempres AS CHAR
       FIELD cdempcon AS INTE
       FIELD cdsegmto AS INTE
       FIELD cdhistor AS INTE
       FIELD cdrefere AS CHAR
       FIELD desmaxdb AS CHAR
       FIELD nrsequen AS INTE.

EMPTY TEMP-TABLE tt-debaut-consulta.

DEFINE VARIABLE aux_flgderro        AS LOGICAL                  NO-UNDO.
DEFINE VARIABLE aux_flgdbaut        AS LOGICAL                  NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_debaut_consulta
&Scoped-define BROWSE-NAME b_debaut_consulta

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-debaut-consulta

/* Definitions for BROWSE b_debaut_consulta                             */
&Scoped-define FIELDS-IN-QUERY-b_debaut_consulta tt-debaut-consulta.nmempres tt-debaut-consulta.cdrefere tt-debaut-consulta.desmaxdb   
&Scoped-define ENABLED-FIELDS-IN-QUERY-b_debaut_consulta   
&Scoped-define SELF-NAME b_debaut_consulta
&Scoped-define OPEN-QUERY-b_debaut_consulta DO:     OPEN QUERY b_debaut_consulta FOR EACH tt-debaut-consulta NO-LOCK INDEXED-REPOSITION.     APPLY "VALUE-CHANGED" TO b_debaut_consulta. END.
&Scoped-define TABLES-IN-QUERY-b_debaut_consulta tt-debaut-consulta
&Scoped-define FIRST-TABLE-IN-QUERY-b_debaut_consulta tt-debaut-consulta


/* Definitions for FRAME f_debaut_consulta                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f_debaut_consulta ~
    ~{&OPEN-QUERY-b_debaut_consulta}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_E Btn_F IMAGE-40 IMAGE-38 IMAGE-39 ~
RECT-149 b_debaut_consulta Btn_H ed_lndigita 
&Scoped-Define DISPLAYED-OBJECTS ed_lndigita 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_debaut_consulta AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_E 
     IMAGE-UP FILE "Imagens/seta_up.gif":U NO-FOCUS
     LABEL "SOBRE" 
     SIZE 13.4 BY 2.38
     FONT 8.

DEFINE BUTTON Btn_F 
     IMAGE-UP FILE "Imagens/seta_down.gif":U NO-FOCUS
     LABEL "DESCE" 
     SIZE 13.4 BY 2.29
     FONT 8.

DEFINE BUTTON Btn_H 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_lndigita AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 140.4 BY 1.38
     FONT 14 NO-UNDO.

DEFINE IMAGE IMAGE-38
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-39
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-40
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE RECTANGLE RECT-100
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 2 .

DEFINE RECTANGLE RECT-149
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 136 BY 15.95.

DEFINE RECTANGLE RECT-98
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-99
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 14 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b_debaut_consulta FOR 
      tt-debaut-consulta SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b_debaut_consulta
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b_debaut_consulta w_debaut_consulta _FREEFORM
  QUERY b_debaut_consulta DISPLAY
      tt-debaut-consulta.nmempres  COLUMN-LABEL "Empresa"             FORMAT "x(35)"
      tt-debaut-consulta.cdrefere  COLUMN-LABEL "Identificação"       FORMAT "x(17)"
      tt-debaut-consulta.desmaxdb  COLUMN-LABEL "Valor Máx. Definido" FORMAT "x(10)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 134 BY 14.29
         FONT 14 ROW-HEIGHT-CHARS 1.29 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_debaut_consulta
     Btn_E AT ROW 9.62 COL 142 WIDGET-ID 68
     Btn_F AT ROW 14.67 COL 142 WIDGET-ID 220
     b_debaut_consulta AT ROW 6.29 COL 6 WIDGET-ID 200
     Btn_H AT ROW 24.14 COL 94.4 WIDGET-ID 74
     ed_lndigita AT ROW 20.71 COL 3 COLON-ALIGNED NO-LABEL WIDGET-ID 216 NO-TAB-STOP 
     "* Serão exibidos até 100 registros." VIEW-AS TEXT
          SIZE 79 BY 1.38 AT ROW 22.38 COL 5 WIDGET-ID 228
          FGCOLOR 7 FONT 11
     "CONSULTA AUTORIZAÇÕES" VIEW-AS TEXT
          SIZE 124.2 BY 3.1 AT ROW 1.24 COL 19.4 WIDGET-ID 226
          FGCOLOR 1 FONT 10
     IMAGE-40 AT ROW 24.29 COL 156 WIDGET-ID 154
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-38 AT ROW 9.29 COL 156 WIDGET-ID 150
     IMAGE-39 AT ROW 14.29 COL 156 WIDGET-ID 222
     RECT-149 AT ROW 6 COL 5 WIDGET-ID 224
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 160 BY 28.67 WIDGET-ID 100.


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
  CREATE WINDOW w_debaut_consulta ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.67
         WIDTH              = 160
         MAX-HEIGHT         = 34.29
         MAX-WIDTH          = 272.8
         VIRTUAL-HEIGHT     = 34.29
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
ASSIGN w_debaut_consulta = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_debaut_consulta
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_debaut_consulta
   FRAME-NAME                                                           */
/* BROWSE-TAB b_debaut_consulta RECT-149 f_debaut_consulta */
ASSIGN 
       ed_lndigita:READ-ONLY IN FRAME f_debaut_consulta        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_debaut_consulta
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_debaut_consulta
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_debaut_consulta
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b_debaut_consulta
/* Query rebuild information for BROWSE b_debaut_consulta
     _START_FREEFORM
DO:
    OPEN QUERY b_debaut_consulta FOR EACH tt-debaut-consulta NO-LOCK INDEXED-REPOSITION.
    APPLY "VALUE-CHANGED" TO b_debaut_consulta.
END.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b_debaut_consulta */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_debaut_consulta:HANDLE
       ROW             = 1.95
       COLUMN          = 5
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_debaut_consulta */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_debaut_consulta
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_debaut_consulta w_debaut_consulta
ON END-ERROR OF w_debaut_consulta
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_debaut_consulta w_debaut_consulta
ON WINDOW-CLOSE OF w_debaut_consulta
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_E
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_debaut_consulta
ON ANY-KEY OF Btn_E IN FRAME f_debaut_consulta /* SOBRE */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_debaut_consulta
ON CHOOSE OF Btn_E IN FRAME f_debaut_consulta /* SOBRE */
DO:
   APPLY "CURSOR-UP" TO b_debaut_consulta.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_F
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_debaut_consulta
ON ANY-KEY OF Btn_F IN FRAME f_debaut_consulta /* DESCE */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_debaut_consulta
ON CHOOSE OF Btn_F IN FRAME f_debaut_consulta /* DESCE */
DO:
  APPLY "CURSOR-DOWN" TO b_debaut_consulta.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_debaut_consulta
ON ANY-KEY OF Btn_H IN FRAME f_debaut_consulta /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_debaut_consulta
ON CHOOSE OF Btn_H IN FRAME f_debaut_consulta /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_debaut_consulta OCX.Tick
PROCEDURE temporizador.t_cartao_debaut_consulta.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_debaut_consulta.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b_debaut_consulta
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_debaut_consulta 


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

    RUN procedures/obtem_autorizacoes_debito.p (INPUT "C",
                                                INPUT  0,
                                                INPUT  0,
                                                OUTPUT aux_flgdbaut,
                                                OUTPUT aux_flgderro,
                                                OUTPUT TABLE tt-debaut-consulta).

    IF  NOT aux_flgderro THEN
        DO:
            IF  CAN-FIND(FIRST tt-debaut-consulta) THEN
                DO:
                    APPLY "OPEN_QUERY" TO b_debaut_consulta.
                END.
        END.
    ELSE
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "NOK".
        END.
        
    RUN enable_UI.
                                                            
    /* deixa o mouse transparente */
    b_debaut_consulta:LOAD-MOUSE-POINTER("blank.cur").
    FRAME f_debaut_consulta:LOAD-MOUSE-POINTER("blank.cur").
    
    chtemporizador:t_cartao_debaut_consulta:INTERVAL = glb_nrtempor.

    APPLY "ENTRY" TO Btn_H.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_debaut_consulta  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_pagamento_debaut_consulta.wrx":U ).
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
ELSE MESSAGE "cartao_pagamento_debaut_consulta.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_debaut_consulta  _DEFAULT-DISABLE
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
  HIDE FRAME f_debaut_consulta.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_debaut_consulta  _DEFAULT-ENABLE
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
  DISPLAY ed_lndigita 
      WITH FRAME f_debaut_consulta.
  ENABLE Btn_E Btn_F IMAGE-40 IMAGE-38 IMAGE-39 RECT-149 b_debaut_consulta 
         Btn_H ed_lndigita 
      WITH FRAME f_debaut_consulta.
  {&OPEN-BROWSERS-IN-QUERY-f_debaut_consulta}
  VIEW w_debaut_consulta.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_debaut_consulta 
PROCEDURE tecla :
chtemporizador:t_cartao_debaut_consulta:INTERVAL = 0.
 
    IF  KEY-FUNCTION(LASTKEY) = "E"                    AND    /* Sobe */
        Btn_E:SENSITIVE IN FRAME f_debaut_consulta  THEN
        DO:       
            APPLY "CHOOSE" TO Btn_E.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "F"                    AND    /* Desce */
        Btn_F:SENSITIVE IN FRAME f_debaut_consulta  THEN
        DO:         
            APPLY "CHOOSE" TO Btn_F.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                    AND    /* Volta*/
        Btn_H:SENSITIVE IN FRAME f_debaut_consulta  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        DO:
            chtemporizador:t_cartao_debaut_consulta:INTERVAL = glb_nrtempor.
            RETURN NO-APPLY.
        END.

    chtemporizador:t_cartao_debaut_consulta:INTERVAL = glb_nrtempor.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

