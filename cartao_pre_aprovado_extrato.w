&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_pre_aprovado_extrato
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_pre_aprovado_extrato 
/* ...........................................................................

Procedure: credito_pre_aprovado_extrato.w
Objetivo : Tela para apresentar o extrato do pre-aprovado
Autor    : James Prust Junior
Data     : Setembro 2014

Ultima alteração: 

............................................................................ */

/*------------------------------------------------------------------------*/
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

DEFINE INPUT        PARAMETER par_vlemprst AS DECI                NO-UNDO.
DEFINE INPUT        PARAMETER par_txmensal AS DECI                NO-UNDO.
DEFINE INPUT        PARAMETER par_qtpreemp AS INTE                NO-UNDO.
DEFINE INPUT        PARAMETER par_vlpreemp AS DECI                NO-UNDO.
DEFINE INPUT        PARAMETER par_percetop AS DECI                NO-UNDO.
DEFINE INPUT        PARAMETER par_vlrtarif AS DECI                NO-UNDO.
DEFINE INPUT        PARAMETER par_dtdpagto AS DATE                NO-UNDO.
DEFINE INPUT        PARAMETER par_vltaxiof AS DECI                NO-UNDO.
DEFINE INPUT        PARAMETER par_vltariof AS DECI                NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER par_flgretur AS CHAR                NO-UNDO.

DEFINE VARIABLE aux_flgderro        AS LOGICAL                    NO-UNDO.
DEFINE VARIABLE aux_conteudo        AS CHAR                       NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_pre_aprovado_extrato

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_E Btn_F IMAGE-40 IMAGE-37 IMAGE-38 ~
IMAGE-39 ed_extrato Btn_D Btn_H 
&Scoped-Define DISPLAYED-OBJECTS ed_extrato 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_pre_aprovado_extrato AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_D 
     LABEL "CONFIRMAR" 
     SIZE 53 BY 3.33
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

DEFINE VARIABLE ed_extrato AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 129 BY 16.67
     FONT 22 NO-UNDO.

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

DEFINE FRAME f_pre_aprovado_extrato
     Btn_E AT ROW 9.62 COL 142 WIDGET-ID 68
     Btn_F AT ROW 14.67 COL 142 WIDGET-ID 220
     ed_extrato AT ROW 6.48 COL 11 NO-LABEL WIDGET-ID 228 NO-TAB-STOP 
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 66
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 74
     "PRÉ-APROVADO" VIEW-AS TEXT
          SIZE 76.4 BY 2.95 AT ROW 1.95 COL 43 WIDGET-ID 92
          FGCOLOR 1 FONT 10
     IMAGE-40 AT ROW 24.24 COL 156 WIDGET-ID 154
     RECT-101 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-102 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-103 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-37 AT ROW 24.24 COL 1 WIDGET-ID 148
     IMAGE-38 AT ROW 9.29 COL 156 WIDGET-ID 150
     IMAGE-39 AT ROW 14.29 COL 156 WIDGET-ID 222
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 160.2 BY 28.57 WIDGET-ID 100.


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
  CREATE WINDOW w_pre_aprovado_extrato ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.57
         WIDTH              = 160
         MAX-HEIGHT         = 34.24
         MAX-WIDTH          = 272.8
         VIRTUAL-HEIGHT     = 34.24
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
ASSIGN w_pre_aprovado_extrato = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_pre_aprovado_extrato
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_pre_aprovado_extrato
   FRAME-NAME                                                           */
ASSIGN 
       ed_extrato:AUTO-INDENT IN FRAME f_pre_aprovado_extrato      = TRUE
       ed_extrato:READ-ONLY IN FRAME f_pre_aprovado_extrato        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-101 IN FRAME f_pre_aprovado_extrato
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-102 IN FRAME f_pre_aprovado_extrato
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-103 IN FRAME f_pre_aprovado_extrato
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_pre_aprovado_extrato:HANDLE
       ROW             = 1.71
       COLUMN          = 7
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_pre_aprovado_extrato */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_pre_aprovado_extrato
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_pre_aprovado_extrato w_pre_aprovado_extrato
ON END-ERROR OF w_pre_aprovado_extrato
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_pre_aprovado_extrato w_pre_aprovado_extrato
ON WINDOW-CLOSE OF w_pre_aprovado_extrato
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_pre_aprovado_extrato
ON ANY-KEY OF Btn_D IN FRAME f_pre_aprovado_extrato /* CONFIRMAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_pre_aprovado_extrato
ON CHOOSE OF Btn_D IN FRAME f_pre_aprovado_extrato /* CONFIRMAR */
DO:
    /* para quem nao tem letras, pede cpf */
    IF  NOT glb_idsenlet  THEN
        RUN senha_cpf.w (OUTPUT aux_flgderro).
    ELSE
        RUN senha.w (OUTPUT aux_flgderro).

    IF  NOT aux_flgderro  THEN
        DO:
            /* puxa o frame principal pra frente */
            h_principal:MOVE-TO-TOP().

            RUN procedures/grava_dados_pre_aprovado.p(INPUT par_qtpreemp,
                                                      INPUT par_vlpreemp,
                                                      INPUT par_vlemprst,
                                                      INPUT par_dtdpagto,
                                                      INPUT par_percetop,
                                                      OUTPUT aux_flgderro).

            /*h_principal:MOVE-TO-BOTTOM().*/

            IF NOT aux_flgderro THEN
               DO:
                   RUN cartao_pre_aprovado_sucesso.w (INPUT-OUTPUT par_flgretur).
                           
                   IF  par_flgretur = "OK"  THEN
                       DO:
                           APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                           RETURN "OK".
                       END.
                   ELSE
                      DO:
                          /* joga o frame frente */
                          FRAME f_pre_aprovado_extrato:MOVE-TO-TOP().
                          APPLY "ENTRY" TO Btn_H.
                          RETURN NO-APPLY.
                      END.
                   
               END.
            ELSE
               DO:
                   /* joga o frame frente */
                   FRAME f_pre_aprovado_extrato:MOVE-TO-TOP().
                   APPLY "ENTRY" TO Btn_H.
                   RETURN NO-APPLY.
               END.

        END. /* END IF  NOT aux_flgderro  THEN */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_E
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_pre_aprovado_extrato
ON ANY-KEY OF Btn_E IN FRAME f_pre_aprovado_extrato /* SOBRE */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_pre_aprovado_extrato
ON CHOOSE OF Btn_E IN FRAME f_pre_aprovado_extrato /* SOBRE */
DO:
    ed_extrato:CURSOR-LINE = 1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_F
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_pre_aprovado_extrato
ON ANY-KEY OF Btn_F IN FRAME f_pre_aprovado_extrato /* DESCE */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_pre_aprovado_extrato
ON CHOOSE OF Btn_F IN FRAME f_pre_aprovado_extrato /* DESCE */
DO:
    ed_extrato:CURSOR-LINE = ed_extrato:NUM-LINES.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_pre_aprovado_extrato
ON ANY-KEY OF Btn_H IN FRAME f_pre_aprovado_extrato /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_pre_aprovado_extrato
ON CHOOSE OF Btn_H IN FRAME f_pre_aprovado_extrato /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_pre_aprovado_extrato OCX.Tick
PROCEDURE temporizador.t_pre_aprovado_extrato.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_pre_aprovado_extrato.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_pre_aprovado_extrato 


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

    /* Busca o extrato do pre-aprovado */
    RUN procedures/obtem_extrato_pre_aprovado.p (INPUT par_vlemprst,
                                                 INPUT par_txmensal,
                                                 INPUT par_qtpreemp,
                                                 INPUT par_vlpreemp,
                                                 INPUT par_percetop,
                                                 INPUT par_vlrtarif,
                                                 INPUT par_dtdpagto,
                                                 INPUT par_vltaxiof,
                                                 INPUT par_vltariof,
                                                 OUTPUT aux_flgderro,
                                                 OUTPUT aux_conteudo).

    RUN enable_UI.

    IF NOT aux_flgderro THEN
       DO:
           /* Carrega o extrato no editor */ 
           ASSIGN ed_extrato:SCREEN-VALUE = aux_conteudo.
       END.

    APPLY "ENTRY" TO Btn_H.

    /* deixa o mouse transparente */
    FRAME f_pre_aprovado_extrato:LOAD-MOUSE-POINTER("blank.cur").

    RUN reset_temporizador.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_pre_aprovado_extrato  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_pre_aprovado_extrato.wrx":U ).
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
ELSE MESSAGE "cartao_pre_aprovado_extrato.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_pre_aprovado_extrato  _DEFAULT-DISABLE
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
  HIDE FRAME f_pre_aprovado_extrato.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_pre_aprovado_extrato  _DEFAULT-ENABLE
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
  DISPLAY ed_extrato 
      WITH FRAME f_pre_aprovado_extrato.
  ENABLE Btn_E Btn_F IMAGE-40 IMAGE-37 IMAGE-38 IMAGE-39 ed_extrato Btn_D Btn_H 
      WITH FRAME f_pre_aprovado_extrato.
  {&OPEN-BROWSERS-IN-QUERY-f_pre_aprovado_extrato}
  VIEW w_pre_aprovado_extrato.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reset_temporizador w_pre_aprovado_extrato 
PROCEDURE reset_temporizador :
chtemporizador:t_pre_aprovado_extrato:INTERVAL = 60000. /* 60 segundos */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_pre_aprovado_extrato 
PROCEDURE tecla :
chtemporizador:t_pre_aprovado_extrato:INTERVAL = 0.

    IF  KEY-FUNCTION(LASTKEY) = "D"                     AND
        Btn_D:SENSITIVE IN FRAME f_pre_aprovado_extrato THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "E"                     AND
        Btn_E:SENSITIVE IN FRAME f_pre_aprovado_extrato THEN
        APPLY "CHOOSE" TO Btn_E.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "F"                     AND
        Btn_F:SENSITIVE IN FRAME f_pre_aprovado_extrato THEN
        APPLY "CHOOSE" TO Btn_F.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                     AND
        Btn_H:SENSITIVE IN FRAME f_pre_aprovado_extrato THEN
        APPLY "CHOOSE" TO Btn_H.
    
    RUN reset_temporizador.

    IF NOT CAN-DO("D,E,F,H",KEY-FUNCTION(LASTKEY)) THEN
       RETURN NO-APPLY.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

