&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME w_debaut_motivos_exclusao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_debaut_motivos_exclusao 
/*------------------------------------------------------------------------

Procedure: cartao_pagamento_debaut_motivo_exclusao.w
Objetivo : Tela de motivos da exclusão do DEBAUT [PROJ320]
Autor    : Lucas Lunelli
Data     : Maio/2016

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

DEFINE INPUT  PARAM par_nmempres     AS CHAR         NO-UNDO.
DEFINE INPUT  PARAM par_cdrefere     AS CHAR         NO-UNDO.
DEFINE INPUT  PARAM par_cdhistor     AS INTE         NO-UNDO.
DEFINE INPUT  PARAM par_cdempcon     AS INTE         NO-UNDO.
DEFINE INPUT  PARAM par_cdsegmto     AS INTE         NO-UNDO.
DEFINE OUTPUT PARAM par_flgderro     AS LOGI         NO-UNDO.

/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }

DEF TEMP-TABLE tt-motivos-cancel-debaut NO-UNDO
    FIELD idmotivo AS INTEGER
    FIELD dsmotivo AS CHARACTER.

EMPTY TEMP-TABLE tt-motivos-cancel-debaut.

DEFINE VARIABLE aux_flgderro        AS LOGICAL                  NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_debaut_motivos_exclusao
&Scoped-define BROWSE-NAME b_debaut_motivos_exclusao

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-motivos-cancel-debaut

/* Definitions for BROWSE b_debaut_motivos_exclusao                     */
&Scoped-define FIELDS-IN-QUERY-b_debaut_motivos_exclusao tt-motivos-cancel-debaut.dsmotivo   
&Scoped-define ENABLED-FIELDS-IN-QUERY-b_debaut_motivos_exclusao   
&Scoped-define SELF-NAME b_debaut_motivos_exclusao
&Scoped-define OPEN-QUERY-b_debaut_motivos_exclusao DO:     OPEN QUERY b_debaut_motivos_exclusao FOR EACH tt-motivos-cancel-debaut NO-LOCK INDEXED-REPOSITION.     APPLY "VALUE-CHANGED" TO b_debaut_motivos_exclusao. END.
&Scoped-define TABLES-IN-QUERY-b_debaut_motivos_exclusao ~
tt-motivos-cancel-debaut
&Scoped-define FIRST-TABLE-IN-QUERY-b_debaut_motivos_exclusao tt-motivos-cancel-debaut


/* Definitions for FRAME f_debaut_motivos_exclusao                      */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f_debaut_motivos_exclusao ~
    ~{&OPEN-QUERY-b_debaut_motivos_exclusao}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_E Btn_F IMAGE-40 IMAGE-38 IMAGE-39 ~
RECT-149 IMAGE-37 b_debaut_motivos_exclusao Btn_D Btn_H ed_lndigita 
&Scoped-Define DISPLAYED-OBJECTS ed_lndigita 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_debaut_motivos_exclusao AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_D 
     LABEL "CONFIRMAR" 
     SIZE 61 BY 3.33
     FONT 8.

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

DEFINE IMAGE IMAGE-37
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

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
DEFINE QUERY b_debaut_motivos_exclusao FOR 
      tt-motivos-cancel-debaut SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b_debaut_motivos_exclusao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b_debaut_motivos_exclusao w_debaut_motivos_exclusao _FREEFORM
  QUERY b_debaut_motivos_exclusao DISPLAY
      tt-motivos-cancel-debaut.dsmotivo  COLUMN-LABEL "Motivo"             FORMAT "x(50)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 134 BY 14.29
         FONT 14 ROW-HEIGHT-CHARS 1.29 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_debaut_motivos_exclusao
     Btn_E AT ROW 9.62 COL 142 WIDGET-ID 68
     Btn_F AT ROW 14.67 COL 142 WIDGET-ID 220
     b_debaut_motivos_exclusao AT ROW 6.29 COL 6 WIDGET-ID 200
     Btn_D AT ROW 24.14 COL 6 WIDGET-ID 156
     Btn_H AT ROW 24.14 COL 94.4 WIDGET-ID 74
     ed_lndigita AT ROW 20.71 COL 3 COLON-ALIGNED NO-LABEL WIDGET-ID 216 NO-TAB-STOP 
     "MOTIVO DA EXCLUSÃO DA AUTORIZAÇÃO" VIEW-AS TEXT
          SIZE 109.6 BY 3.1 AT ROW 1.24 COL 26.4 WIDGET-ID 226
          FGCOLOR 1 FONT 10
     IMAGE-40 AT ROW 24.29 COL 156 WIDGET-ID 154
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-38 AT ROW 9.29 COL 156 WIDGET-ID 150
     IMAGE-39 AT ROW 14.29 COL 156 WIDGET-ID 222
     RECT-149 AT ROW 6 COL 5 WIDGET-ID 224
     IMAGE-37 AT ROW 24.29 COL 1 WIDGET-ID 148
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
  CREATE WINDOW w_debaut_motivos_exclusao ASSIGN
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
ASSIGN w_debaut_motivos_exclusao = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_debaut_motivos_exclusao
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_debaut_motivos_exclusao
   FRAME-NAME                                                           */
/* BROWSE-TAB b_debaut_motivos_exclusao IMAGE-37 f_debaut_motivos_exclusao */
ASSIGN 
       ed_lndigita:READ-ONLY IN FRAME f_debaut_motivos_exclusao        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_debaut_motivos_exclusao
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_debaut_motivos_exclusao
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_debaut_motivos_exclusao
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b_debaut_motivos_exclusao
/* Query rebuild information for BROWSE b_debaut_motivos_exclusao
     _START_FREEFORM
DO:
    OPEN QUERY b_debaut_motivos_exclusao FOR EACH tt-motivos-cancel-debaut NO-LOCK INDEXED-REPOSITION.
    APPLY "VALUE-CHANGED" TO b_debaut_motivos_exclusao.
END.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b_debaut_motivos_exclusao */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_debaut_motivos_exclusao:HANDLE
       ROW             = 1.95
       COLUMN          = 5
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_debaut_motivos_exclusao */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_debaut_motivos_exclusao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_debaut_motivos_exclusao w_debaut_motivos_exclusao
ON END-ERROR OF w_debaut_motivos_exclusao
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_debaut_motivos_exclusao w_debaut_motivos_exclusao
ON WINDOW-CLOSE OF w_debaut_motivos_exclusao
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_debaut_motivos_exclusao
ON ANY-KEY OF Btn_D IN FRAME f_debaut_motivos_exclusao /* CONFIRMAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_debaut_motivos_exclusao
ON CHOOSE OF Btn_D IN FRAME f_debaut_motivos_exclusao /* CONFIRMAR */
DO:
    RUN cartao_pagamento_debaut_exclusao_confirmar.w(INPUT par_nmempres,
                                                     INPUT par_cdrefere,
                                                     INPUT par_cdhistor,
                                                     INPUT par_cdempcon,
                                                     INPUT par_cdsegmto,
                                                     INPUT tt-motivos-cancel-debaut.idmotivo,
                                                    OUTPUT par_flgderro).
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


&Scoped-define SELF-NAME Btn_E
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_debaut_motivos_exclusao
ON ANY-KEY OF Btn_E IN FRAME f_debaut_motivos_exclusao /* SOBRE */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_debaut_motivos_exclusao
ON CHOOSE OF Btn_E IN FRAME f_debaut_motivos_exclusao /* SOBRE */
DO:
   APPLY "CURSOR-UP" TO b_debaut_motivos_exclusao.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_F
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_debaut_motivos_exclusao
ON ANY-KEY OF Btn_F IN FRAME f_debaut_motivos_exclusao /* DESCE */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_debaut_motivos_exclusao
ON CHOOSE OF Btn_F IN FRAME f_debaut_motivos_exclusao /* DESCE */
DO:
  APPLY "CURSOR-DOWN" TO b_debaut_motivos_exclusao.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_debaut_motivos_exclusao
ON ANY-KEY OF Btn_H IN FRAME f_debaut_motivos_exclusao /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_debaut_motivos_exclusao
ON CHOOSE OF Btn_H IN FRAME f_debaut_motivos_exclusao /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_debaut_motivos_exclusao OCX.Tick
PROCEDURE temporizador.t_cartao_debaut_motivos_exclusao.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_debaut_motivos_exclusao.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b_debaut_motivos_exclusao
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_debaut_motivos_exclusao 


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

    RUN procedures/busca_motivos_exclusao_debaut.p (OUTPUT par_flgderro,
                                                    OUTPUT TABLE tt-motivos-cancel-debaut).
    IF  NOT par_flgderro THEN
        DO:
            IF  CAN-FIND(FIRST tt-motivos-cancel-debaut) THEN
                DO:
                    APPLY "OPEN_QUERY" TO b_debaut_motivos_exclusao.
                END.
        END.
    ELSE
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "NOK".
        END.
        
    RUN enable_UI.
                                                            
    /* deixa o mouse transparente */
    b_debaut_motivos_exclusao:LOAD-MOUSE-POINTER("blank.cur").
    FRAME f_debaut_motivos_exclusao:LOAD-MOUSE-POINTER("blank.cur").
    
    chtemporizador:t_cartao_debaut_motivos_exclusao:INTERVAL = glb_nrtempor.

    APPLY "ENTRY" TO Btn_H.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_debaut_motivos_exclusao  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_pagamento_debaut_motivo_exclusao.wrx":U ).
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
ELSE MESSAGE "cartao_pagamento_debaut_motivo_exclusao.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_debaut_motivos_exclusao  _DEFAULT-DISABLE
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
  HIDE FRAME f_debaut_motivos_exclusao.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_debaut_motivos_exclusao  _DEFAULT-ENABLE
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
      WITH FRAME f_debaut_motivos_exclusao.
  ENABLE Btn_E Btn_F IMAGE-40 IMAGE-38 IMAGE-39 RECT-149 IMAGE-37 
         b_debaut_motivos_exclusao Btn_D Btn_H ed_lndigita 
      WITH FRAME f_debaut_motivos_exclusao.
  {&OPEN-BROWSERS-IN-QUERY-f_debaut_motivos_exclusao}
  VIEW w_debaut_motivos_exclusao.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_debaut_motivos_exclusao 
PROCEDURE tecla :
chtemporizador:t_cartao_debaut_motivos_exclusao:INTERVAL = 0.
 
    IF  KEY-FUNCTION(LASTKEY) = "E"                    AND    /* Sobe */
        Btn_E:SENSITIVE IN FRAME f_debaut_motivos_exclusao  THEN
        DO:       
            APPLY "CHOOSE" TO Btn_E.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "D"                    AND    /* Excluir */
        Btn_D:SENSITIVE IN FRAME f_debaut_motivos_exclusao  THEN
        DO:       
            APPLY "CHOOSE" TO Btn_D.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "F"                    AND    /* Desce */
        Btn_F:SENSITIVE IN FRAME f_debaut_motivos_exclusao  THEN
        DO:         
            APPLY "CHOOSE" TO Btn_F.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                    AND    /* Volta*/
        Btn_H:SENSITIVE IN FRAME f_debaut_motivos_exclusao  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        DO:
            chtemporizador:t_cartao_debaut_motivos_exclusao:INTERVAL = glb_nrtempor.
            RETURN NO-APPLY.
        END.

    chtemporizador:t_cartao_debaut_motivos_exclusao:INTERVAL = glb_nrtempor.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

