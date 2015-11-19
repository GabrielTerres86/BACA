&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_cartao_alterar_senha
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_cartao_alterar_senha 
/* ..............................................................................

Procedure: cartao_alterar_senha.w
Objetivo : Tela para alterar a senha do cartao
Autor    : Evandro
Data     : Janeiro 2010

Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).
                
                  15/10/2015 - Ajustes para TAA PRJ 215, incluido verificacao
                               de senhas (Jean Michel).  

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

DEFINE VARIABLE aux_flgderro        AS LOGICAL      NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_cartao_alterar_senha

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-3 RECT-4 RECT-5 RECT-2 IMAGE-40 ~
IMAGE-41 ed_dsdsenan ed_dsdsennv ed_dsdsencf Btn_G Btn_H 
&Scoped-Define DISPLAYED-OBJECTS ed_dsdsenan ed_dsdsennv ed_dsdsencf 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_cartao_alterar_senha AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_G 
     LABEL "CONFIRMAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_H AUTO-END-KEY 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_dsdsenan AS CHARACTER FORMAT "X(6)":U 
     VIEW-AS FILL-IN 
     SIZE 36.2 BY 2.14
     FGCOLOR 1 FONT 10 NO-UNDO.

DEFINE VARIABLE ed_dsdsencf AS CHARACTER FORMAT "X(6)":U 
     VIEW-AS FILL-IN 
     SIZE 36.2 BY 2.14
     FGCOLOR 1 FONT 10 NO-UNDO.

DEFINE VARIABLE ed_dsdsennv AS CHARACTER FORMAT "X(6)":U 
     VIEW-AS FILL-IN 
     SIZE 36.2 BY 2.14
     FGCOLOR 1 FONT 10 NO-UNDO.

DEFINE IMAGE IMAGE-40
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-41
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

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 6 GRAPHIC-EDGE  NO-FILL   
     SIZE 71 BY 3.33.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 4 GRAPHIC-EDGE  NO-FILL   
     SIZE 38.6 BY 2.62.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 4 GRAPHIC-EDGE  NO-FILL   
     SIZE 38.6 BY 2.62.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 4 GRAPHIC-EDGE  NO-FILL   
     SIZE 38.6 BY 2.62.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_cartao_alterar_senha
     ed_dsdsenan AT ROW 9.81 COL 112 COLON-ALIGNED NO-LABEL WIDGET-ID 142 PASSWORD-FIELD 
     ed_dsdsennv AT ROW 12.91 COL 112 COLON-ALIGNED NO-LABEL WIDGET-ID 146 PASSWORD-FIELD 
     ed_dsdsencf AT ROW 16 COL 112 COLON-ALIGNED NO-LABEL WIDGET-ID 144 PASSWORD-FIELD 
     Btn_G AT ROW 19.1 COL 94.4 WIDGET-ID 130
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 132
     "  SENHA ATUAL:" VIEW-AS TEXT
          SIZE 62 BY 2.38 AT ROW 9.62 COL 41 WIDGET-ID 152
          FGCOLOR 1 FONT 13
     "REPITA A NOVA SENHA:" VIEW-AS TEXT
          SIZE 88 BY 2.05 AT ROW 16 COL 15 WIDGET-ID 148
          FGCOLOR 1 FONT 13
     "ALTERAÇÃO DE SENHA" VIEW-AS TEXT
          SIZE 105 BY 3.33 AT ROW 1.48 COL 28.6 WIDGET-ID 128
          FGCOLOR 1 FONT 10
     "Para continuar, tecle ENTRA" VIEW-AS TEXT
          SIZE 63.4 BY 1.67 AT ROW 24.81 COL 16 WIDGET-ID 154
          FGCOLOR 0 FONT 8
     "         NOVA SENHA:" VIEW-AS TEXT
          SIZE 89 BY 2.05 AT ROW 12.91 COL 15 WIDGET-ID 150
          FGCOLOR 1 FONT 13
     RECT-3 AT ROW 9.57 COL 113 WIDGET-ID 136
     RECT-4 AT ROW 12.67 COL 113 WIDGET-ID 138
     RECT-5 AT ROW 15.76 COL 113 WIDGET-ID 140
     RECT-2 AT ROW 24.1 COL 12 WIDGET-ID 160
     RECT-101 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-102 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-103 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-40 AT ROW 24.24 COL 156 WIDGET-ID 174
     IMAGE-41 AT ROW 19.24 COL 156 WIDGET-ID 176
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
  CREATE WINDOW w_cartao_alterar_senha ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.57
         WIDTH              = 160
         MAX-HEIGHT         = 34.33
         MAX-WIDTH          = 272
         VIRTUAL-HEIGHT     = 34.33
         VIRTUAL-WIDTH      = 272
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
ASSIGN w_cartao_alterar_senha = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_cartao_alterar_senha
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_cartao_alterar_senha
   NOT-VISIBLE FRAME-NAME                                               */
/* SETTINGS FOR RECTANGLE RECT-101 IN FRAME f_cartao_alterar_senha
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-102 IN FRAME f_cartao_alterar_senha
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-103 IN FRAME f_cartao_alterar_senha
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_cartao_alterar_senha:HANDLE
       ROW             = 2.43
       COLUMN          = 10
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_alterar_senha */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_cartao_alterar_senha
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_alterar_senha w_cartao_alterar_senha
ON END-ERROR OF w_cartao_alterar_senha
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_alterar_senha w_cartao_alterar_senha
ON WINDOW-CLOSE OF w_cartao_alterar_senha
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_G
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_cartao_alterar_senha
ON CHOOSE OF Btn_G IN FRAME f_cartao_alterar_senha /* CONFIRMAR */
DO:
    /* ---------- */
    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).
    
    IF  aux_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.

    aux_flgderro = NO.
    
    /* Verifica se usuario informou a senha atual */
    IF LENGTH(ed_dsdsenan:SCREEN-VALUE) < 6 THEN
        DO:
           RUN mensagem.w (INPUT NO,
                           INPUT "    ATENÇÃO  ",
                           INPUT "",
                           INPUT "",
                           INPUT "Informe a senha atual.",
                           INPUT "",
                           INPUT "").
    
           PAUSE 3 NO-MESSAGE.
           h_mensagem:HIDDEN = YES.
    
           APPLY "ENTRY" TO ed_dsdsenan.
           RETURN NO-APPLY.
       END.

    /* Verifica se usuario informou a nova senha */
    IF LENGTH(ed_dsdsennv:SCREEN-VALUE) < 6 THEN
        DO:
           RUN mensagem.w (INPUT NO,
                           INPUT "    ATENÇÃO  ",
                           INPUT "",
                           INPUT "",
                           INPUT "Informe a nova senha.",
                           INPUT "",
                           INPUT "").
    
           PAUSE 3 NO-MESSAGE.
           h_mensagem:HIDDEN = YES.
    
           APPLY "ENTRY" TO ed_dsdsenan.
           RETURN NO-APPLY.
       END.

    /* Verifica se usuario informou a confirmacao de senha */
    IF LENGTH(ed_dsdsencf:SCREEN-VALUE) < 6 THEN
        DO:
           RUN mensagem.w (INPUT NO,
                           INPUT "    ATENÇÃO  ",
                           INPUT "",
                           INPUT "",
                           INPUT "Informe a senha de confirmação.",
                           INPUT "",
                           INPUT "").
    
           PAUSE 3 NO-MESSAGE.
           h_mensagem:HIDDEN = YES.
    
           APPLY "ENTRY" TO ed_dsdsenan.
           RETURN NO-APPLY.
       END.
    /* valida a digitacao das senhas */
    IF  ed_dsdsenan:SCREEN-VALUE = ed_dsdsennv:SCREEN-VALUE  THEN
        DO: 
            RUN mensagem.w (INPUT YES,
                            INPUT "    ATENÇÃO",
                            INPUT "",
                            INPUT "A nova senha deve ser",
                            INPUT "diferente da senha atual.",
                            INPUT "",
                            INPUT "").

            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.

            aux_flgderro = YES.
        END.
    ELSE
    IF  ed_dsdsennv:SCREEN-VALUE <> ed_dsdsencf:SCREEN-VALUE  THEN
        DO: 
            RUN mensagem.w (INPUT YES,
                            INPUT "    ATENÇÃO",
                            INPUT "",
                            INPUT "Senhas não conferem.",
                            INPUT "",
                            INPUT "",
                            INPUT "").

            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.

            aux_flgderro = YES.
        END.
    ELSE
    IF  SUBSTRING(ed_dsdsennv:SCREEN-VALUE,1,1) = "0"  THEN
        DO: 
            RUN mensagem.w (INPUT YES,
                            INPUT "    ATENÇÃO",
                            INPUT "",
                            INPUT "A senha não pode iniciar com o",
                            INPUT "número ZERO.",
                            INPUT "",
                            INPUT "").

            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.

            aux_flgderro = YES.
        END.
    ELSE
    IF  LENGTH(ed_dsdsennv:SCREEN-VALUE) <> 6  THEN
        DO: 
            RUN mensagem.w (INPUT YES,
                            INPUT "    ATENÇÃO",
                            INPUT "",
                            INPUT "",
                            INPUT "A senha deve conter 6 dígitos",
                            INPUT "",
                            INPUT "").

            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.

            aux_flgderro = YES.
        END.

    IF  aux_flgderro  THEN
        DO:
            RUN limpa.
            RETURN NO-APPLY.
        END.

    /* valida a senha atual */
    RUN procedures/valida_senha.p ( INPUT ENCODE(ed_dsdsenan:SCREEN-VALUE),
                                   OUTPUT aux_flgderro).

    IF  aux_flgderro  THEN
        DO:
            RUN limpa.
            RETURN NO-APPLY.
        END.

        
    RUN procedures/altera_senha.p( INPUT ed_dsdsennv:SCREEN-VALUE,
                                  OUTPUT aux_flgderro).


    IF  NOT aux_flgderro  THEN
        DO:
            RUN mensagem.w (INPUT NO,
                            INPUT "      SENHA",
                            INPUT "",
                            INPUT "Alterada com sucesso!",
                            INPUT "",
                            INPUT "",
                            INPUT "").

            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.
        END.


    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
    RETURN "OK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_alterar_senha
ON CHOOSE OF Btn_H IN FRAME f_cartao_alterar_senha /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_dsdsenan
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_dsdsenan w_cartao_alterar_senha
ON ANY-KEY OF ed_dsdsenan IN FRAME f_cartao_alterar_senha
DO:
    RUN tecla.

    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            IF LENGTH(ed_dsdsenan:SCREEN-VALUE) < 6 THEN
                DO:
                   RUN mensagem.w (INPUT NO,
                                   INPUT "    ATENÇÃO  ",
                                   INPUT "",
                                   INPUT "",
                                   INPUT "Informe a senha atual.",
                                   INPUT "",
                                   INPUT "").
        
                   PAUSE 3 NO-MESSAGE.
                   h_mensagem:HIDDEN = YES.
        
                   APPLY "ENTRY" TO ed_dsdsenan.
                   RETURN NO-APPLY.
               END.
             ELSE
                DO:
                    APPLY "ENTRY" TO ed_dsdsennv.
                    RETURN NO-APPLY.
                END.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            RUN limpa.
            RETURN NO-APPLY.
        END.
    ELSE
    /* se não foram digitados números, despreza */
    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))  THEN
        DO:
            /* se escolheu os botoes, repassa o retorno */
            IF  RETURN-VALUE <> ""  THEN
                RETURN RETURN-VALUE.
            ELSE
                /* senao somente despreza a tecla */
                RETURN NO-APPLY.
        END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_dsdsencf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_dsdsencf w_cartao_alterar_senha
ON ANY-KEY OF ed_dsdsencf IN FRAME f_cartao_alterar_senha
DO:
    RUN tecla.

    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            IF LENGTH(ed_dsdsencf:SCREEN-VALUE) < 6 THEN
                DO:
                   RUN mensagem.w (INPUT NO,
                                   INPUT "    ATENÇÃO  ",
                                   INPUT "",
                                   INPUT "",
                                   INPUT "Informe a senha de confirmação.",
                                   INPUT "",
                                   INPUT "").
        
                   PAUSE 3 NO-MESSAGE.
                   h_mensagem:HIDDEN = YES.
        
                   APPLY "ENTRY" TO ed_dsdsencf.
                   RETURN NO-APPLY.
               END.
             ELSE
                DO:
                    RUN limpa.
                    RETURN NO-APPLY.
                END.
        END.
    ELSE
    /* se não foram digitados números, despreza */
    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))  THEN
        DO:
            /* se escolheu os botoes, repassa o retorno */
            IF  RETURN-VALUE <> ""  THEN
                RETURN RETURN-VALUE.
            ELSE
                /* senao somente despreza a tecla */
                RETURN NO-APPLY.
        END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_dsdsennv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_dsdsennv w_cartao_alterar_senha
ON ANY-KEY OF ed_dsdsennv IN FRAME f_cartao_alterar_senha
DO:
    RUN tecla.

    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            IF LENGTH(ed_dsdsennv:SCREEN-VALUE) < 6 THEN
                DO:
                   RUN mensagem.w (INPUT NO,
                                   INPUT "    ATENÇÃO  ",
                                   INPUT "",
                                   INPUT "",
                                   INPUT "Informe a nova senha.",
                                   INPUT "",
                                   INPUT "").
        
                   PAUSE 3 NO-MESSAGE.
                   h_mensagem:HIDDEN = YES.
        
                   APPLY "ENTRY" TO ed_dsdsennv.
                   RETURN NO-APPLY.
               END.
             ELSE
                DO:
                    APPLY "ENTRY" TO ed_dsdsencf.
                    RETURN NO-APPLY.
                END.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            RUN limpa.
            RETURN NO-APPLY.
        END.
    ELSE
    /* se não foram digitados números, despreza */
    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))  THEN
        DO:
            /* se escolheu os botoes, repassa o retorno */
            IF  RETURN-VALUE <> ""  THEN
                RETURN RETURN-VALUE.
            ELSE
                /* senao somente despreza a tecla */
                RETURN NO-APPLY.
        END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_cartao_alterar_senha OCX.Tick
PROCEDURE temporizador.t_cartao_alterar_senha.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_cartao_alterar_senha.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_cartao_alterar_senha 


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
    FRAME f_cartao_alterar_senha:LOAD-MOUSE-POINTER("blank.cur").

    chtemporizador:t_cartao_alterar_senha:INTERVAL = glb_nrtempor.

    /* coloca o foco na senha */
    APPLY "ENTRY" TO ed_dsdsenan.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_cartao_alterar_senha  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_alterar_senha.wrx":U ).
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
ELSE MESSAGE "cartao_alterar_senha.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_cartao_alterar_senha  _DEFAULT-DISABLE
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
  HIDE FRAME f_cartao_alterar_senha.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_cartao_alterar_senha  _DEFAULT-ENABLE
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
  DISPLAY ed_dsdsenan ed_dsdsennv ed_dsdsencf 
      WITH FRAME f_cartao_alterar_senha.
  ENABLE RECT-3 RECT-4 RECT-5 RECT-2 IMAGE-40 IMAGE-41 ed_dsdsenan ed_dsdsennv 
         ed_dsdsencf Btn_G Btn_H 
      WITH FRAME f_cartao_alterar_senha.
  {&OPEN-BROWSERS-IN-QUERY-f_cartao_alterar_senha}
  VIEW w_cartao_alterar_senha.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE limpa w_cartao_alterar_senha 
PROCEDURE limpa :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    ASSIGN  ed_dsdsenan:SCREEN-VALUE IN FRAME f_cartao_alterar_senha = ""
            ed_dsdsennv:SCREEN-VALUE IN FRAME f_cartao_alterar_senha = ""
            ed_dsdsencf:SCREEN-VALUE IN FRAME f_cartao_alterar_senha = "".

    APPLY "ENTRY" TO ed_dsdsenan.
    RETURN NO-APPLY.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_cartao_alterar_senha 
PROCEDURE tecla :
chtemporizador:t_cartao_alterar_senha:INTERVAL = 0.

    IF  KEY-FUNCTION(LASTKEY) = "G"                      AND
        Btn_G:SENSITIVE IN FRAME f_cartao_alterar_senha  THEN
        APPLY "CHOOSE" TO Btn_G.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                      AND
        Btn_H:SENSITIVE IN FRAME f_cartao_alterar_senha  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_cartao_alterar_senha:INTERVAL = glb_nrtempor.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

