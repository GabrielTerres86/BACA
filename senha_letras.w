&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_senha_letras
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_senha_letras 
/* ..............................................................................

Procedure: senha_letras.w
Objetivo : Tela para senha com letras randomicas
Autor    : Evandro
Data     : Dezembro 2011

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

DEFINE OUTPUT PARAM par_flgderro        AS LOGICAL  INIT YES    NO-UNDO.

DEFINE     VARIABLE aux_dsdgrup1        AS CHAR                 NO-UNDO.
DEFINE     VARIABLE aux_dsdgrup2        AS CHAR                 NO-UNDO.
DEFINE     VARIABLE aux_dsdgrup3        AS CHAR                 NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_senha_letras

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-34 IMAGE-35 IMAGE-36 IMAGE-37 IMAGE-38 ~
IMAGE-39 IMAGE-40 IMAGE-48 ed_dsdsenha Btn_A Btn_E Btn_B Btn_F Btn_C Btn_G ~
Btn_D Btn_H 
&Scoped-Define DISPLAYED-OBJECTS ed_dsdsenha 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_senha_letras AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_A 
     LABEL "" 
     SIZE 61 BY 3.33
     FONT 10.

DEFINE BUTTON Btn_B 
     LABEL "" 
     SIZE 61 BY 3.33
     FONT 10.

DEFINE BUTTON Btn_C 
     LABEL "" 
     SIZE 61 BY 3.33
     FONT 10.

DEFINE BUTTON Btn_D 
     LABEL "" 
     SIZE 61 BY 3.33
     FONT 10.

DEFINE BUTTON Btn_E 
     LABEL "" 
     SIZE 61 BY 3.33
     FONT 10.

DEFINE BUTTON Btn_F 
     LABEL "" 
     SIZE 61 BY 3.33
     FONT 10.

DEFINE BUTTON Btn_G 
     LABEL "" 
     SIZE 61 BY 3.33
     FONT 10.

DEFINE BUTTON Btn_H 
     LABEL "CANCELAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_dsdsenha AS CHARACTER FORMAT "X(6)":U 
     VIEW-AS FILL-IN 
     SIZE 29.2 BY 2.14
     BGCOLOR 15 FGCOLOR 1 FONT 10 NO-UNDO.

DEFINE IMAGE IMAGE-34
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-35
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-36
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

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

DEFINE IMAGE IMAGE-48
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


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_senha_letras
     ed_dsdsenha AT ROW 6.19 COL 64.4 COLON-ALIGNED NO-LABEL WIDGET-ID 94
     Btn_A AT ROW 9.1 COL 6 WIDGET-ID 78
     Btn_E AT ROW 9.1 COL 94.4 WIDGET-ID 68
     Btn_B AT ROW 14.1 COL 6 WIDGET-ID 84
     Btn_F AT ROW 14.1 COL 94.4 WIDGET-ID 70
     Btn_C AT ROW 19.1 COL 6 WIDGET-ID 82
     Btn_G AT ROW 19.1 COL 94.4 WIDGET-ID 86
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 66
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 74
     "LETRAS DE SEGURANÇA" VIEW-AS TEXT
          SIZE 110 BY 3.33 AT ROW 1.48 COL 26.6 WIDGET-ID 166
          FGCOLOR 1 FONT 10
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 162
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 164
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 160
     IMAGE-34 AT ROW 9.24 COL 1 WIDGET-ID 142
     IMAGE-35 AT ROW 14.24 COL 1 WIDGET-ID 144
     IMAGE-36 AT ROW 19.24 COL 1 WIDGET-ID 146
     IMAGE-37 AT ROW 24.24 COL 1 WIDGET-ID 148
     IMAGE-38 AT ROW 9.24 COL 156 WIDGET-ID 150
     IMAGE-39 AT ROW 14.24 COL 156 WIDGET-ID 152
     IMAGE-40 AT ROW 24.24 COL 156 WIDGET-ID 154
     IMAGE-48 AT ROW 19.24 COL 156 WIDGET-ID 156
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
  CREATE WINDOW w_senha_letras ASSIGN
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
ASSIGN w_senha_letras = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_senha_letras
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_senha_letras
   FRAME-NAME                                                           */
ASSIGN 
       ed_dsdsenha:READ-ONLY IN FRAME f_senha_letras        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_senha_letras
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_senha_letras
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_senha_letras
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_senha_letras:HANDLE
       ROW             = 1.71
       COLUMN          = 4
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_senha_letras */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_senha_letras
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_senha_letras w_senha_letras
ON END-ERROR OF w_senha_letras
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_senha_letras w_senha_letras
ON WINDOW-CLOSE OF w_senha_letras
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_A
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_A w_senha_letras
ON ANY-KEY OF Btn_A IN FRAME f_senha_letras
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_A w_senha_letras
ON CHOOSE OF Btn_A IN FRAME f_senha_letras
DO:
    RUN armazena_grupo(INPUT SELF:LABEL).
    RUN sorteia.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_B
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_B w_senha_letras
ON ANY-KEY OF Btn_B IN FRAME f_senha_letras
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_B w_senha_letras
ON CHOOSE OF Btn_B IN FRAME f_senha_letras
DO:
    RUN armazena_grupo(INPUT SELF:LABEL).
    RUN sorteia.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_C
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_C w_senha_letras
ON ANY-KEY OF Btn_C IN FRAME f_senha_letras
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_C w_senha_letras
ON CHOOSE OF Btn_C IN FRAME f_senha_letras
DO:
    RUN armazena_grupo(INPUT SELF:LABEL).
    RUN sorteia.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_senha_letras
ON ANY-KEY OF Btn_D IN FRAME f_senha_letras
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_senha_letras
ON CHOOSE OF Btn_D IN FRAME f_senha_letras
DO:
    RUN armazena_grupo(INPUT SELF:LABEL).
    RUN sorteia.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_E
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_senha_letras
ON ANY-KEY OF Btn_E IN FRAME f_senha_letras
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_senha_letras
ON CHOOSE OF Btn_E IN FRAME f_senha_letras
DO:
    RUN armazena_grupo(INPUT SELF:LABEL).
    RUN sorteia.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_F
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_senha_letras
ON ANY-KEY OF Btn_F IN FRAME f_senha_letras
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_senha_letras
ON CHOOSE OF Btn_F IN FRAME f_senha_letras
DO:
    RUN armazena_grupo(INPUT SELF:LABEL).
    RUN sorteia.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_G
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_senha_letras
ON ANY-KEY OF Btn_G IN FRAME f_senha_letras
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_senha_letras
ON CHOOSE OF Btn_G IN FRAME f_senha_letras
DO:
    RUN armazena_grupo(INPUT SELF:LABEL).
    RUN sorteia.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_senha_letras
ON ANY-KEY OF Btn_H IN FRAME f_senha_letras /* CANCELAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_senha_letras
ON CHOOSE OF Btn_H IN FRAME f_senha_letras /* CANCELAR */
DO:
    par_flgderro = YES.
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_senha_letras OCX.Tick
PROCEDURE temporizador.t_senha_letras.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_senha_letras.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_senha_letras 


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
    FRAME f_senha_letras:LOAD-MOUSE-POINTER("blank.cur").

    ASSIGN chtemporizador:t_senha_letras:INTERVAL = glb_nrtempor
           ed_dsdsenha:SCREEN-VALUE = "".

    RUN sorteia.
                   
    /* coloca o foco no botao H */
    APPLY "ENTRY" TO Btn_H.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE armazena_grupo w_senha_letras 
PROCEDURE armazena_grupo :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE INPUT PARAM par_dsdgrupo     AS CHAR     NO-UNDO.


/* coloca um "*" para visualizar que já fez a escolha */
DO  WITH FRAME f_senha_letras:
    ed_dsdsenha:SCREEN-VALUE = ed_dsdsenha:SCREEN-VALUE + " *".
END.

/* remove a 4a letra FAKE do grupo */
ASSIGN par_dsdgrupo = REPLACE(par_dsdgrupo,"V-","")
       par_dsdgrupo = REPLACE(par_dsdgrupo,"W-","")
       par_dsdgrupo = REPLACE(par_dsdgrupo,"X-","")
       par_dsdgrupo = REPLACE(par_dsdgrupo,"Y-","")
       par_dsdgrupo = REPLACE(par_dsdgrupo,"Z-","")

       par_dsdgrupo = REPLACE(par_dsdgrupo,"-V","")
       par_dsdgrupo = REPLACE(par_dsdgrupo,"-W","")
       par_dsdgrupo = REPLACE(par_dsdgrupo,"-X","")
       par_dsdgrupo = REPLACE(par_dsdgrupo,"-Y","")
       par_dsdgrupo = REPLACE(par_dsdgrupo,"-Z","").


IF  aux_dsdgrup1 = ""  THEN
    aux_dsdgrup1 = par_dsdgrupo.
ELSE
IF  aux_dsdgrup2 = ""  THEN
    aux_dsdgrup2 = par_dsdgrupo.
ELSE
IF  aux_dsdgrup3 = ""  THEN
    DO:
        aux_dsdgrup3 = par_dsdgrupo.

        RUN procedures/valida_senha_letras.p (INPUT aux_dsdgrup1,
                                              INPUT aux_dsdgrup2,
                                              INPUT aux_dsdgrup3,
                                              OUTPUT par_flgderro).

        IF  par_flgderro  THEN
            DO:
                APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
                RETURN "NOK".
            END.
        ELSE
            DO:
                APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
                RETURN "OK".
            END.
    END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_senha_letras  _CONTROL-LOAD
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

OCXFile = SEARCH( "senha_letras.wrx":U ).
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
ELSE MESSAGE "senha_letras.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_senha_letras  _DEFAULT-DISABLE
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
  HIDE FRAME f_senha_letras.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_senha_letras  _DEFAULT-ENABLE
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
  DISPLAY ed_dsdsenha 
      WITH FRAME f_senha_letras.
  ENABLE IMAGE-34 IMAGE-35 IMAGE-36 IMAGE-37 IMAGE-38 IMAGE-39 IMAGE-40 
         IMAGE-48 ed_dsdsenha Btn_A Btn_E Btn_B Btn_F Btn_C Btn_G Btn_D Btn_H 
      WITH FRAME f_senha_letras.
  {&OPEN-BROWSERS-IN-QUERY-f_senha_letras}
  VIEW w_senha_letras.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sorteia w_senha_letras 
PROCEDURE sorteia :
DEF VAR aux_dsdletra    AS CHAR     NO-UNDO.
DEF VAR aux_nrdletra    AS INT      NO-UNDO.
DEF VAR aux_nrrandom    AS INT      NO-UNDO.

ASSIGN aux_dsdletra = "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U".

DO WITH FRAME f_senha_letras:
END.

ASSIGN btn_A:LABEL = ""
       btn_B:LABEL = ""
       btn_C:LABEL = ""
       btn_D:LABEL = ""
       btn_E:LABEL = ""
       btn_F:LABEL = ""
       btn_G:LABEL = "".

DO WHILE TRUE:

    aux_nrdletra = RANDOM(1,21).

    IF  ENTRY(aux_nrdletra,aux_dsdletra) <> ""  THEN
        DO:
            IF  NUM-ENTRIES(btn_A:LABEL,"-") <= 3  THEN
                btn_A:LABEL = btn_A:LABEL + ENTRY(aux_nrdletra,aux_dsdletra) + "-".
            ELSE
            IF  NUM-ENTRIES(btn_B:LABEL,"-") <= 3  THEN
                btn_B:LABEL = btn_B:LABEL + ENTRY(aux_nrdletra,aux_dsdletra) + "-".
            ELSE
            IF  NUM-ENTRIES(btn_C:LABEL,"-") <= 3  THEN
                btn_C:LABEL = btn_C:LABEL + ENTRY(aux_nrdletra,aux_dsdletra) + "-".
            ELSE
            IF  NUM-ENTRIES(btn_D:LABEL,"-") <= 3  THEN
                btn_D:LABEL = btn_D:LABEL + ENTRY(aux_nrdletra,aux_dsdletra) + "-".
            ELSE
            IF  NUM-ENTRIES(btn_E:LABEL,"-") <= 3  THEN
                btn_E:LABEL = btn_E:LABEL + ENTRY(aux_nrdletra,aux_dsdletra) + "-".
            ELSE
            IF  NUM-ENTRIES(btn_F:LABEL,"-") <= 3  THEN
                btn_F:LABEL = btn_F:LABEL + ENTRY(aux_nrdletra,aux_dsdletra) + "-".
            ELSE
            IF  NUM-ENTRIES(btn_G:LABEL,"-") <= 3  THEN
                btn_G:LABEL = btn_G:LABEL + ENTRY(aux_nrdletra,aux_dsdletra) + "-".
            
            ENTRY(aux_nrdletra,aux_dsdletra) = "".
        END.

    /* Se preencheu todas */
    IF  NUM-ENTRIES(btn_G:LABEL,"-") > 3  THEN
        LEAVE.
END.

/* remove os ultimos "-" */
ASSIGN btn_A:LABEL = SUBSTRING(btn_A:LABEL,1,LENGTH(btn_A:LABEL) - 1)
       btn_B:LABEL = SUBSTRING(btn_B:LABEL,1,LENGTH(btn_B:LABEL) - 1)
       btn_C:LABEL = SUBSTRING(btn_C:LABEL,1,LENGTH(btn_C:LABEL) - 1)
       btn_D:LABEL = SUBSTRING(btn_D:LABEL,1,LENGTH(btn_D:LABEL) - 1)
       btn_E:LABEL = SUBSTRING(btn_E:LABEL,1,LENGTH(btn_E:LABEL) - 1)
       btn_F:LABEL = SUBSTRING(btn_F:LABEL,1,LENGTH(btn_F:LABEL) - 1)
       btn_G:LABEL = SUBSTRING(btn_G:LABEL,1,LENGTH(btn_G:LABEL) - 1).


/* coloca a 4a letra FAKE no grupo */
ASSIGN aux_dsdletra = "V,W,X,Y,Z".

DO WHILE TRUE:

    aux_nrdletra = RANDOM(1,5).

    IF  ENTRY(aux_nrdletra,aux_dsdletra) <> ""  THEN
        DO:
            aux_nrrandom = RANDOM(1,4).

            /* coloca a letra FAKE misturada nas demais */
            IF  NUM-ENTRIES(btn_A:LABEL,"-") <= 3  THEN
                DO:
                    IF  aux_nrrandom = 1  THEN
                        btn_A:LABEL = ENTRY(aux_nrdletra,aux_dsdletra) + "-" + btn_A:LABEL.
                    ELSE
                    IF  aux_nrrandom = 2  THEN
                        btn_A:LABEL = ENTRY(1,btn_A:LABEL,"-") + "-" + 
                                      ENTRY(aux_nrdletra,aux_dsdletra) + "-" + 
                                      ENTRY(2,btn_A:LABEL,"-") + "-" + 
                                      ENTRY(3,btn_A:LABEL,"-").
                    ELSE
                    IF  aux_nrrandom = 3  THEN
                        btn_A:LABEL = ENTRY(1,btn_A:LABEL,"-") + "-" + 
                                      ENTRY(2,btn_A:LABEL,"-") + "-" + 
                                      ENTRY(aux_nrdletra,aux_dsdletra) + "-" + 
                                      ENTRY(3,btn_A:LABEL,"-").
                    ELSE
                        btn_A:LABEL = btn_A:LABEL + "-" + ENTRY(aux_nrdletra,aux_dsdletra).
                END.
            ELSE
            IF  NUM-ENTRIES(btn_B:LABEL,"-") <= 3  THEN
                DO:
                    IF  aux_nrrandom = 1  THEN
                        btn_B:LABEL = ENTRY(aux_nrdletra,aux_dsdletra) + "-" + btn_B:LABEL.
                    ELSE
                    IF  aux_nrrandom = 2  THEN
                        btn_B:LABEL = ENTRY(1,btn_B:LABEL,"-") + "-" + 
                                      ENTRY(aux_nrdletra,aux_dsdletra) + "-" + 
                                      ENTRY(2,btn_B:LABEL,"-") + "-" + 
                                      ENTRY(3,btn_B:LABEL,"-").
                    ELSE
                    IF  aux_nrrandom = 3  THEN
                        btn_B:LABEL = ENTRY(1,btn_B:LABEL,"-") + "-" + 
                                      ENTRY(2,btn_B:LABEL,"-") + "-" + 
                                      ENTRY(aux_nrdletra,aux_dsdletra) + "-" + 
                                      ENTRY(3,btn_B:LABEL,"-").
                    ELSE
                        btn_B:LABEL = btn_B:LABEL + "-" + ENTRY(aux_nrdletra,aux_dsdletra).
                END.
            ELSE
            IF  NUM-ENTRIES(btn_C:LABEL,"-") <= 3  THEN
                DO:
                    IF  aux_nrrandom = 1  THEN
                        btn_C:LABEL = ENTRY(aux_nrdletra,aux_dsdletra) + "-" + btn_C:LABEL.
                    ELSE
                    IF  aux_nrrandom = 2  THEN
                        btn_C:LABEL = ENTRY(1,btn_C:LABEL,"-") + "-" + 
                                      ENTRY(aux_nrdletra,aux_dsdletra) + "-" + 
                                      ENTRY(2,btn_C:LABEL,"-") + "-" + 
                                      ENTRY(3,btn_C:LABEL,"-").
                    ELSE
                    IF  aux_nrrandom = 3  THEN
                        btn_C:LABEL = ENTRY(1,btn_C:LABEL,"-") + "-" + 
                                      ENTRY(2,btn_C:LABEL,"-") + "-" + 
                                      ENTRY(aux_nrdletra,aux_dsdletra) + "-" + 
                                      ENTRY(3,btn_C:LABEL,"-").
                    ELSE
                        btn_C:LABEL = btn_C:LABEL + "-" + ENTRY(aux_nrdletra,aux_dsdletra).
                END.
            ELSE
            IF  NUM-ENTRIES(btn_D:LABEL,"-") <= 3  THEN
                DO:
                    IF  aux_nrrandom = 1  THEN
                        btn_D:LABEL = ENTRY(aux_nrdletra,aux_dsdletra) + "-" + btn_D:LABEL.
                    ELSE
                    IF  aux_nrrandom = 2  THEN
                        btn_D:LABEL = ENTRY(1,btn_D:LABEL,"-") + "-" + 
                                      ENTRY(aux_nrdletra,aux_dsdletra) + "-" + 
                                      ENTRY(2,btn_D:LABEL,"-") + "-" + 
                                      ENTRY(3,btn_D:LABEL,"-").
                    ELSE
                    IF  aux_nrrandom = 3  THEN
                        btn_D:LABEL = ENTRY(1,btn_D:LABEL,"-") + "-" + 
                                      ENTRY(2,btn_D:LABEL,"-") + "-" + 
                                      ENTRY(aux_nrdletra,aux_dsdletra) + "-" + 
                                      ENTRY(3,btn_D:LABEL,"-").
                    ELSE
                        btn_D:LABEL = btn_D:LABEL + "-" + ENTRY(aux_nrdletra,aux_dsdletra).
                END.
            ELSE
            IF  NUM-ENTRIES(btn_E:LABEL,"-") <= 3  THEN
                DO:
                    IF  aux_nrrandom = 1  THEN
                        btn_E:LABEL = ENTRY(aux_nrdletra,aux_dsdletra) + "-" + btn_E:LABEL.
                    ELSE
                    IF  aux_nrrandom = 2  THEN
                        btn_E:LABEL = ENTRY(1,btn_E:LABEL,"-") + "-" + 
                                      ENTRY(aux_nrdletra,aux_dsdletra) + "-" + 
                                      ENTRY(2,btn_E:LABEL,"-") + "-" + 
                                      ENTRY(3,btn_E:LABEL,"-").
                    ELSE
                    IF  aux_nrrandom = 3  THEN
                        btn_E:LABEL = ENTRY(1,btn_E:LABEL,"-") + "-" + 
                                      ENTRY(2,btn_E:LABEL,"-") + "-" + 
                                      ENTRY(aux_nrdletra,aux_dsdletra) + "-" + 
                                      ENTRY(3,btn_E:LABEL,"-").
                    ELSE
                        btn_E:LABEL = btn_E:LABEL + "-" + ENTRY(aux_nrdletra,aux_dsdletra).
                END.
            ELSE
            IF  NUM-ENTRIES(btn_F:LABEL,"-") <= 3  THEN
                DO:
                    IF  aux_nrrandom = 1  THEN
                        btn_F:LABEL = ENTRY(aux_nrdletra,aux_dsdletra) + "-" + btn_F:LABEL.
                    ELSE
                    IF  aux_nrrandom = 2  THEN
                        btn_F:LABEL = ENTRY(1,btn_F:LABEL,"-") + "-" + 
                                      ENTRY(aux_nrdletra,aux_dsdletra) + "-" + 
                                      ENTRY(2,btn_F:LABEL,"-") + "-" + 
                                      ENTRY(3,btn_F:LABEL,"-").
                    ELSE
                    IF  aux_nrrandom = 3  THEN
                        btn_F:LABEL = ENTRY(1,btn_F:LABEL,"-") + "-" + 
                                      ENTRY(2,btn_F:LABEL,"-") + "-" + 
                                      ENTRY(aux_nrdletra,aux_dsdletra) + "-" + 
                                      ENTRY(3,btn_F:LABEL,"-").
                    ELSE
                        btn_F:LABEL = btn_F:LABEL + "-" + ENTRY(aux_nrdletra,aux_dsdletra).
                END.
            ELSE
            IF  NUM-ENTRIES(btn_G:LABEL,"-") <= 3  THEN
                DO:
                    IF  aux_nrrandom = 1  THEN
                        btn_G:LABEL = ENTRY(aux_nrdletra,aux_dsdletra) + "-" + btn_G:LABEL.
                    ELSE
                    IF  aux_nrrandom = 2  THEN
                        btn_G:LABEL = ENTRY(1,btn_G:LABEL,"-") + "-" + 
                                      ENTRY(aux_nrdletra,aux_dsdletra) + "-" + 
                                      ENTRY(2,btn_G:LABEL,"-") + "-" + 
                                      ENTRY(3,btn_G:LABEL,"-").
                    ELSE
                    IF  aux_nrrandom = 3  THEN
                        btn_G:LABEL = ENTRY(1,btn_G:LABEL,"-") + "-" + 
                                      ENTRY(2,btn_G:LABEL,"-") + "-" + 
                                      ENTRY(aux_nrdletra,aux_dsdletra) + "-" + 
                                      ENTRY(3,btn_G:LABEL,"-").
                    ELSE
                        btn_G:LABEL = btn_G:LABEL + "-" + ENTRY(aux_nrdletra,aux_dsdletra).
                END.
            ELSE
                LEAVE.
            
            ENTRY(aux_nrdletra,aux_dsdletra) = "".

            /* Se zerou o grupo, reinicia */
            IF  REPLACE(aux_dsdletra,",","") = "" THEN
                ASSIGN aux_dsdletra = "V,W,X,Y,Z".
        END.

    /* Se preencheu todas */
    IF  NUM-ENTRIES(btn_G:LABEL,"-") > 4  THEN
        LEAVE.
END.







END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_senha_letras 
PROCEDURE tecla :
chtemporizador:t_senha_letras:INTERVAL = 0.

    /* ---------- *
    RUN procedures/verifica_autorizacao.p (OUTPUT par_flgderro).
    
    IF  par_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.
    ****/
        

    IF  KEY-FUNCTION(LASTKEY) = "A"              AND
        Btn_A:SENSITIVE IN FRAME f_senha_letras  THEN
        APPLY "CHOOSE" TO Btn_A.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "B"              AND
        Btn_B:SENSITIVE IN FRAME f_senha_letras  THEN
        APPLY "CHOOSE" TO Btn_B.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "C"              AND
        Btn_C:SENSITIVE IN FRAME f_senha_letras  THEN
        APPLY "CHOOSE" TO Btn_C.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "D"              AND
        Btn_D:SENSITIVE IN FRAME f_senha_letras  THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "E"              AND
        Btn_E:SENSITIVE IN FRAME f_senha_letras  THEN
        APPLY "CHOOSE" TO Btn_E.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "F"              AND
        Btn_F:SENSITIVE IN FRAME f_senha_letras  THEN
        APPLY "CHOOSE" TO Btn_F.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "G"              AND
        Btn_G:SENSITIVE IN FRAME f_senha_letras  THEN
        APPLY "CHOOSE" TO Btn_G.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"              AND
        Btn_H:SENSITIVE IN FRAME f_senha_letras  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            /* limpa a senha para escolher novamente */
            ASSIGN ed_dsdsenha:SCREEN-VALUE = ""
                   aux_dsdgrup1 = ""
                   aux_dsdgrup2 = ""
                   aux_dsdgrup3 = "".

            RUN sorteia.

            RETURN NO-APPLY.
        END.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_senha_letras:INTERVAL = glb_nrtempor.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

