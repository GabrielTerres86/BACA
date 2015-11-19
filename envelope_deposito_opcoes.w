&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_envelope_opcoes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_envelope_opcoes 
/* ..............................................................................

Procedure: envelope_deposito_opcoes.w
Objetivo : Tela para apresentar o menu de opcoes para depositos
Autor    : Evandro
Data     : Janeiro 2010

Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).
                  
                  03/06/2014 - Alterado para permitir o deposito intercooperativa.
                               (Reinert)

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

DEFINE OUTPUT PARAM par_flgderro        AS LOGICAL      NO-UNDO.
DEFINE OUTPUT PARAM par_vlretorn        AS CHARACTER    NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_envelope_deposito_opcoes

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-34 IMAGE-38 IMAGE-40 Btn_A Btn_E Btn_H 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_envelope_opcoes AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_A 
     LABEL "CHEQUES" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_E 
     LABEL "DINHEIRO" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_H 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE IMAGE IMAGE-34
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-38
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-40
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE RECTANGLE RECT-100
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 2 .

DEFINE RECTANGLE RECT-98
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-99
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-143
     EDGE-PIXELS 3 GRAPHIC-EDGE    
     SIZE 59 BY 5.71
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_envelope_deposito_opcoes
     Btn_A AT ROW 9.1 COL 6 WIDGET-ID 78
     Btn_E AT ROW 9.1 COL 94.4 WIDGET-ID 68
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 74
     "MENU DE DEPÓSITOS" VIEW-AS TEXT
          SIZE 98 BY 3.33 AT ROW 1.48 COL 32 WIDGET-ID 162
          FGCOLOR 1 FONT 10
     IMAGE-34 AT ROW 9.24 COL 1 WIDGET-ID 142
     IMAGE-38 AT ROW 9.24 COL 156 WIDGET-ID 150
     IMAGE-40 AT ROW 24.24 COL 156 WIDGET-ID 154
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 116
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 160 BY 28.57 WIDGET-ID 100.

DEFINE FRAME f_horario
     "Envelopes  depositados  a  partir" VIEW-AS TEXT
          SIZE 55 BY 1.19 AT ROW 2.95 COL 3.2 WIDGET-ID 104
          BGCOLOR 7 FGCOLOR 14 FONT 14
     "no próximo dia útil." VIEW-AS TEXT
          SIZE 56 BY 1.19 AT ROW 5.33 COL 3.2 WIDGET-ID 106
          BGCOLOR 7 FGCOLOR 14 FONT 14
     "deste horário serão processados" VIEW-AS TEXT
          SIZE 56 BY 1.19 AT ROW 4.14 COL 3.2 WIDGET-ID 110
          BGCOLOR 7 FGCOLOR 14 FONT 14
     "Atenção!" VIEW-AS TEXT
          SIZE 16 BY 1.43 AT ROW 1.24 COL 22.6 WIDGET-ID 102
          BGCOLOR 7 FGCOLOR 14 FONT 14
     RECT-143 AT ROW 1.05 COL 1.2 WIDGET-ID 108
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 6 ROW 21.71
         SIZE 60.6 BY 6.43 WIDGET-ID 200.


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
  CREATE WINDOW w_envelope_opcoes ASSIGN
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
ASSIGN w_envelope_opcoes = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_envelope_opcoes
  VISIBLE,,RUN-PERSISTENT                                               */
/* REPARENT FRAME */
ASSIGN FRAME f_horario:FRAME = FRAME f_envelope_deposito_opcoes:HANDLE.

/* SETTINGS FOR FRAME f_envelope_deposito_opcoes
   FRAME-NAME                                                           */
/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_envelope_deposito_opcoes
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_envelope_deposito_opcoes
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_envelope_deposito_opcoes
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME f_horario
                                                                        */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_envelope_deposito_opcoes:HANDLE
       ROW             = 2.19
       COLUMN          = 8
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_envelope_deposito_opcoes */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_envelope_opcoes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_envelope_opcoes w_envelope_opcoes
ON END-ERROR OF w_envelope_opcoes
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_envelope_opcoes w_envelope_opcoes
ON WINDOW-CLOSE OF w_envelope_opcoes
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_A
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_A w_envelope_opcoes
ON ANY-KEY OF Btn_A IN FRAME f_envelope_deposito_opcoes /* CHEQUES */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_A w_envelope_opcoes
ON CHOOSE OF Btn_A IN FRAME f_envelope_deposito_opcoes /* CHEQUES */
DO:
    RUN envelope_deposito_cooperativa.w (INPUT 1
                                        ,OUTPUT par_flgderro
                                        ,OUTPUT par_vlretorn).

    IF  par_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.

    IF  par_vlretorn = "OK" THEN
        DO:            
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "OK".
        END.                 
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_E
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_envelope_opcoes
ON ANY-KEY OF Btn_E IN FRAME f_envelope_deposito_opcoes /* DINHEIRO */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_envelope_opcoes
ON CHOOSE OF Btn_E IN FRAME f_envelope_deposito_opcoes /* DINHEIRO */
DO:
    RUN envelope_deposito_cooperativa.w (INPUT 2
                                        ,OUTPUT par_flgderro
                                        ,OUTPUT par_vlretorn).

    IF  par_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.

    IF  par_vlretorn = "OK" THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "OK".
        END.                 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_envelope_opcoes
ON ANY-KEY OF Btn_H IN FRAME f_envelope_deposito_opcoes /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_envelope_opcoes
ON CHOOSE OF Btn_H IN FRAME f_envelope_deposito_opcoes /* VOLTAR */
DO:    
    ASSIGN par_flgderro = NO
           par_vlretorn = "NOK".
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_envelope_opcoes OCX.Tick
PROCEDURE temporizador.t_envelope_deposito_opcoes.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_envelope_deposito_opcoes.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_envelope_opcoes 


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
    FRAME f_envelope_deposito_opcoes:LOAD-MOUSE-POINTER("blank.cur").
    FRAME f_horario:LOAD-MOUSE-POINTER("blank.cur").
    

    chtemporizador:t_envelope_deposito_opcoes:INTERVAL = glb_nrtempor.


    /* verifica horário de corte para depositos */
    RUN procedures/horario_deposito.p (OUTPUT par_flgderro).
    
    IF  RETURN-VALUE = "OK"  THEN
        HIDE FRAME f_horario.


    /* coloca o foco no botao H */
    APPLY "ENTRY" TO Btn_H.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_envelope_opcoes  _CONTROL-LOAD
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

OCXFile = SEARCH( "envelope_deposito_opcoes.wrx":U ).
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
ELSE MESSAGE "envelope_deposito_opcoes.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_envelope_opcoes  _DEFAULT-DISABLE
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
  HIDE FRAME f_envelope_deposito_opcoes.
  HIDE FRAME f_horario.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_envelope_opcoes  _DEFAULT-ENABLE
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
  ENABLE IMAGE-34 IMAGE-38 IMAGE-40 Btn_A Btn_E Btn_H 
      WITH FRAME f_envelope_deposito_opcoes.
  {&OPEN-BROWSERS-IN-QUERY-f_envelope_deposito_opcoes}
  ENABLE RECT-143 
      WITH FRAME f_horario.
  {&OPEN-BROWSERS-IN-QUERY-f_horario}
  VIEW w_envelope_opcoes.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_envelope_opcoes 
PROCEDURE tecla :
chtemporizador:t_envelope_deposito_opcoes:INTERVAL = 0.

    /* ---------- */
    RUN procedures/verifica_autorizacao.p (OUTPUT par_flgderro).
    
    IF  par_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.

    IF  KEY-FUNCTION(LASTKEY) = "A"                          AND
        Btn_A:SENSITIVE IN FRAME f_envelope_deposito_opcoes  THEN
        APPLY "CHOOSE" TO Btn_A.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "E"                          AND
        Btn_E:SENSITIVE IN FRAME f_envelope_deposito_opcoes  THEN
        APPLY "CHOOSE" TO Btn_E.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                          AND
        Btn_H:SENSITIVE IN FRAME f_envelope_deposito_opcoes  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_envelope_deposito_opcoes:INTERVAL = glb_nrtempor.    

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

