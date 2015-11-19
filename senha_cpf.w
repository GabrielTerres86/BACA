&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_senha
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_senha 
/* ..............................................................................

Procedure: senha.w
Objetivo : Tela para verificação da senha
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

/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }

DEFINE OUTPUT PARAM par_flgderro        AS LOGICAL  INIT YES    NO-UNDO.

DEFINE VARIABLE     aux_tentativ        AS INTEGER              NO-UNDO.


DEFINE VARIABLE     tmp_nrcpf           AS CHAR                 NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_senha

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-2 RECT-4 ed_dssencar ed_nrcpf ~
Btn_H ed_label_cpf 
&Scoped-Define DISPLAYED-OBJECTS ed_dssencar ed_nrcpf ed_label_cpf 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_senha AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_H AUTO-END-KEY 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_dssencar AS CHARACTER FORMAT "X(6)":U 
     VIEW-AS FILL-IN 
     SIZE 36.2 BY 2.14
     BGCOLOR 15 FGCOLOR 1 FONT 10 NO-UNDO.

DEFINE VARIABLE ed_label_cpf AS CHARACTER FORMAT "X(256)":U INITIAL "Informe os 4 primeiros dígitos do seu CPF" 
      VIEW-AS TEXT 
     SIZE 92 BY 1.43
     FGCOLOR 1 FONT 8 NO-UNDO.

DEFINE VARIABLE ed_nrcpf AS CHARACTER FORMAT "X(4)":U 
     VIEW-AS FILL-IN 
     SIZE 19 BY 2.14
     BGCOLOR 15 FGCOLOR 1 FONT 13 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 6 GRAPHIC-EDGE  NO-FILL   
     SIZE 140 BY 6.91.

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

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 6 GRAPHIC-EDGE  NO-FILL   
     SIZE 71 BY 4.05.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 6 GRAPHIC-EDGE  NO-FILL   
     SIZE 140 BY 6.91.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_senha
     ed_dssencar AT ROW 8.24 COL 61 COLON-ALIGNED NO-LABEL WIDGET-ID 94 PASSWORD-FIELD 
     ed_nrcpf AT ROW 17.62 COL 69 COLON-ALIGNED NO-LABEL WIDGET-ID 174
     Btn_H AT ROW 24.1 COL 96 WIDGET-ID 88
     ed_label_cpf AT ROW 15.91 COL 33.2 COLON-ALIGNED NO-LABEL WIDGET-ID 184
     "Atenção! NÃO forneça a sua senha a estranhos!" VIEW-AS TEXT
          SIZE 105 BY 1.33 AT ROW 11.33 COL 32 WIDGET-ID 130
          FGCOLOR 1 FONT 8
     "DIGITE A SUA SENHA" VIEW-AS TEXT
          SIZE 94.4 BY 3.33 AT ROW 1.48 COL 33.8 WIDGET-ID 162
          FGCOLOR 1 FONT 10
     "Para continuar, tecle ENTRA" VIEW-AS TEXT
          SIZE 63.4 BY 1.67 AT ROW 24.81 COL 15 WIDGET-ID 128
          FGCOLOR 0 FONT 8
     RECT-1 AT ROW 6.81 COL 11 WIDGET-ID 116
     RECT-2 AT ROW 23.62 COL 11 WIDGET-ID 118
     RECT-101 AT ROW 5.05 COL 19.6 WIDGET-ID 158
     RECT-102 AT ROW 5.52 COL 19.6 WIDGET-ID 160
     RECT-103 AT ROW 5.29 COL 19.6 WIDGET-ID 156
     RECT-4 AT ROW 14.33 COL 11 WIDGET-ID 170
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
  CREATE WINDOW w_senha ASSIGN
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
ASSIGN w_senha = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_senha
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_senha
   FRAME-NAME                                                           */
ASSIGN 
       ed_label_cpf:READ-ONLY IN FRAME f_senha        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-101 IN FRAME f_senha
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-102 IN FRAME f_senha
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-103 IN FRAME f_senha
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_senha:HANDLE
       ROW             = 1.95
       COLUMN          = 10
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_senha */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_senha
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_senha w_senha
ON END-ERROR OF w_senha
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_senha w_senha
ON WINDOW-CLOSE OF w_senha
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_senha
ON CHOOSE OF Btn_H IN FRAME f_senha /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_dssencar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_dssencar w_senha
ON ANY-KEY OF ed_dssencar IN FRAME f_senha
DO:
    chtemporizador:t_senha:INTERVAL = 0.
    
    IF  KEY-FUNCTION(LASTKEY) = "H"  THEN
        DO:
            par_flgderro = YES.
            APPLY "CHOOSE" TO Btn_H.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            IF  glb_inpessoa = 1  OR
                glb_inpessoa = 2   THEN
                APPLY "ENTRY" TO ed_nrcpf.
            ELSE
                DO:
                    /* operador */

                    /* maximo 3 tentativas */
                    aux_tentativ = aux_tentativ + 1.
                    
                    RUN procedures/valida_senha.p (INPUT ENCODE(ed_dssencar:SCREEN-VALUE),
                                                   INPUT "",
                                                   OUTPUT par_flgderro).

                    chtemporizador:t_senha:INTERVAL = glb_nrtempor.
                    
                    IF  par_flgderro      AND
                        aux_tentativ < 3  THEN
                        DO:
                            ASSIGN ed_dssencar:SCREEN-VALUE = ""
                                   ed_nrcpf:SCREEN-VALUE    = "".
                    
                            APPLY "ENTRY" TO ed_dssencar.
                            RETURN NO-APPLY.
                        END.
                    
                    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
                    RETURN "OK".
                END.
                    
            
            RETURN NO-APPLY.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            ASSIGN ed_dssencar:SCREEN-VALUE = ""
                   chtemporizador:t_senha:INTERVAL = glb_nrtempor.
            RETURN NO-APPLY.
        END.
    ELSE
    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))  THEN
        RETURN NO-APPLY.

    /******
              /* maximo 3 tentativas */
            aux_tentativ = aux_tentativ + 1.

            RUN procedures/valida_senha.p (INPUT ENCODE(ed_dssencar:SCREEN-VALUE),
                                           OUTPUT par_flgderro).

            IF  par_flgderro      AND
                aux_tentativ < 3  THEN
                DO:
                    ed_dssencar:SCREEN-VALUE = "".
                    RETURN NO-APPLY.
                END.
            
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
            RETURN "OK".
    *****/


    chtemporizador:t_senha:INTERVAL = glb_nrtempor.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_nrcpf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nrcpf w_senha
ON ANY-KEY OF ed_nrcpf IN FRAME f_senha
DO:
    chtemporizador:t_senha:INTERVAL = 0.
    
    IF  KEY-FUNCTION(LASTKEY) = "H"  THEN
        DO:
            par_flgderro = YES.
            APPLY "CHOOSE" TO Btn_H.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            /* maximo 3 tentativas */
            aux_tentativ = aux_tentativ + 1.

            

            RUN procedures/valida_senha_cpf.p (INPUT ENCODE(ed_dssencar:SCREEN-VALUE),
                                               INPUT ENCODE(tmp_nrcpf),
                                               OUTPUT par_flgderro).

            IF  par_flgderro      AND
                aux_tentativ < 3  THEN
                DO:
                    ASSIGN ed_dssencar:SCREEN-VALUE = ""
                           ed_nrcpf:SCREEN-VALUE    = ""
                           tmp_nrcpf                = "".

                           chtemporizador:t_senha:INTERVAL = glb_nrtempor.

                    APPLY "ENTRY" TO ed_dssencar.
                    RETURN NO-APPLY.
                END.
            
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
            RETURN "OK".
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            ASSIGN ed_nrcpf:SCREEN-VALUE = ""
                   tmp_nrcpf             = ""
                   chtemporizador:t_senha:INTERVAL = glb_nrtempor.

            RETURN NO-APPLY.
        END.
    ELSE
    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))  THEN
        RETURN NO-APPLY.
    ELSE
        DO:
            ASSIGN ed_nrcpf:SCREEN-VALUE = ed_nrcpf:SCREEN-VALUE + "*"
                   tmp_nrcpf             = tmp_nrcpf + KEY-FUNCTION(LASTKEY)
                   chtemporizador:t_senha:INTERVAL = glb_nrtempor.

            RETURN NO-APPLY.
        END.

    chtemporizador:t_senha:INTERVAL = glb_nrtempor.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_senha OCX.Tick
PROCEDURE temporizador.t_senha.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_senha.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_senha 


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
    FRAME f_senha:LOAD-MOUSE-POINTER("blank.cur").

    chtemporizador:t_senha:INTERVAL = glb_nrtempor.


    /* operador */
    IF  glb_inpessoa <> 1  AND
        glb_inpessoa <> 2  THEN
        HIDE ed_label_cpf ed_nrcpf RECT-4 IN FRAME f_senha.
        

    /* coloca o foco na senha */
    APPLY "ENTRY" TO ed_dssencar.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_senha  _CONTROL-LOAD
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

OCXFile = SEARCH( "senha_cpf.wrx":U ).
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
ELSE MESSAGE "senha_cpf.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_senha  _DEFAULT-DISABLE
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
  HIDE FRAME f_senha.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_senha  _DEFAULT-ENABLE
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
  DISPLAY ed_dssencar ed_nrcpf ed_label_cpf 
      WITH FRAME f_senha.
  ENABLE RECT-1 RECT-2 RECT-4 ed_dssencar ed_nrcpf Btn_H ed_label_cpf 
      WITH FRAME f_senha.
  {&OPEN-BROWSERS-IN-QUERY-f_senha}
  VIEW w_senha.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

