&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_manutencao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_manutencao 
/* ..............................................................................

Procedure: manutencao.w
Objetivo : Tela para exibir o menu de manutencao do TAA
Autor    : Evandro
Data     : Janeiro 2010

Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

                  23/01/2017 - #561094 e #537054 Alterado o botao de Fechamento
                              (Btn_E) para ser usado como opcao de Diagnosticos 
                              do TAA (Carlos)

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

DEFINE VARIABLE aux_nmdohost        AS CHAR         NO-UNDO.
DEFINE VARIABLE aux_ipdohost        AS CHAR         NO-UNDO.

DEFINE VARIABLE aux_flgderro        AS LOGICAL      NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_manutencao

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-34 IMAGE-35 IMAGE-36 IMAGE-37 IMAGE-38 ~
IMAGE-39 IMAGE-40 IMAGE-43 Btn_A Btn_E Btn_B Btn_F Btn_C Btn_G Btn_D Btn_H 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_manutencao AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_A 
     LABEL "ABERTURA" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_B 
     LABEL "RECOLHIMENTO" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_C 
     LABEL "SITUAÇÃO" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_D 
     LABEL "CONFIGURAÇÃO" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_E 
     LABEL "DIAGNOSTICOS" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_F 
     LABEL "SUPRIMENTO" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_G 
     LABEL "REINICIAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_H 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

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

DEFINE IMAGE IMAGE-43
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

DEFINE FRAME f_manutencao
     Btn_A AT ROW 9.1 COL 6 WIDGET-ID 60
     Btn_E AT ROW 9.1 COL 94.4 WIDGET-ID 68
     Btn_B AT ROW 14.1 COL 6 WIDGET-ID 62
     Btn_F AT ROW 14.1 COL 94.4 WIDGET-ID 70
     Btn_C AT ROW 19.1 COL 6 WIDGET-ID 64
     Btn_G AT ROW 19.1 COL 94.4 WIDGET-ID 72
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 66
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 74
     "MENU DE MANUTENÇÃO" VIEW-AS TEXT
          SIZE 114 BY 3.33 AT ROW 1.48 COL 24 WIDGET-ID 174
          FGCOLOR 1 FONT 10
     IMAGE-34 AT ROW 9.24 COL 1 WIDGET-ID 142
     IMAGE-35 AT ROW 14.24 COL 1 WIDGET-ID 144
     IMAGE-36 AT ROW 19.24 COL 1 WIDGET-ID 146
     IMAGE-37 AT ROW 24.24 COL 1 WIDGET-ID 148
     IMAGE-38 AT ROW 9.24 COL 156 WIDGET-ID 150
     IMAGE-39 AT ROW 14.24 COL 156 WIDGET-ID 152
     IMAGE-40 AT ROW 24.24 COL 156 WIDGET-ID 154
     IMAGE-43 AT ROW 19.24 COL 156 WIDGET-ID 156
     RECT-101 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-102 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-103 AT ROW 5.29 COL 19.6 WIDGET-ID 116
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
  CREATE WINDOW w_manutencao ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.57
         WIDTH              = 160
         MAX-HEIGHT         = 28.57
         MAX-WIDTH          = 160
         VIRTUAL-HEIGHT     = 28.57
         VIRTUAL-WIDTH      = 160
         SHOW-IN-TASKBAR    = no
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
ASSIGN w_manutencao = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_manutencao
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_manutencao
   FRAME-NAME                                                           */
/* SETTINGS FOR RECTANGLE RECT-101 IN FRAME f_manutencao
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-102 IN FRAME f_manutencao
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-103 IN FRAME f_manutencao
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_manutencao:HANDLE
       ROW             = 1.71
       COLUMN          = 4
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_manutencao */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_manutencao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_manutencao w_manutencao
ON END-ERROR OF w_manutencao
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_manutencao w_manutencao
ON WINDOW-CLOSE OF w_manutencao
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_A
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_A w_manutencao
ON ANY-KEY OF Btn_A IN FRAME f_manutencao /* ABERTURA */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_A w_manutencao
ON CHOOSE OF Btn_A IN FRAME f_manutencao /* ABERTURA */
DO:
    RUN procedures/efetua_abertura.p (OUTPUT aux_flgderro).

    IF  aux_flgderro  THEN
        DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "    ATENÇÃO",
                            INPUT "",
                            INPUT "Não foi possível efetuar",
                            INPUT "a abertura.",
                            INPUT "",
                            INPUT "").
            
            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.

            RETURN.
        END.

    RUN procedures/carrega_suprimento.p (OUTPUT aux_flgderro).

    RUN habilita_opcoes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_B
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_B w_manutencao
ON ANY-KEY OF Btn_B IN FRAME f_manutencao /* RECOLHIMENTO */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_B w_manutencao
ON CHOOSE OF Btn_B IN FRAME f_manutencao /* RECOLHIMENTO */
DO:
    RUN procedures/inicializa_dispositivo.p ( INPUT 6,
                                             OUTPUT aux_flgderro).            

    IF  NOT xfs_impressora   OR   /* nao habilitada ou gerou algum erro */
        xfs_impsempapel      THEN /* sem papel */
        DO:
            RUN mensagem.w (INPUT NO,
                            INPUT "    Atenção!",
                            INPUT "",
                            INPUT "Este terminal não possui papel",
                            INPUT "para impressão do comprovante.",
                            INPUT "",
                            INPUT "Verifique a impressora.").
            
            PAUSE 10 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.            
        END.


    RUN manutencao_recolhimento.w.

    RUN habilita_opcoes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_C
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_C w_manutencao
ON ANY-KEY OF Btn_C IN FRAME f_manutencao /* SITUAÇÃO */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_C w_manutencao
ON CHOOSE OF Btn_C IN FRAME f_manutencao /* SITUAÇÃO */
DO:
    RUN manutencao_suprimento (INPUT YES).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_manutencao
ON ANY-KEY OF Btn_D IN FRAME f_manutencao /* CONFIGURAÇÃO */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_manutencao
ON CHOOSE OF Btn_D IN FRAME f_manutencao /* CONFIGURAÇÃO */
DO:
    RUN manutencao_configuracao.w.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_E
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_manutencao
ON ANY-KEY OF Btn_E IN FRAME f_manutencao /* DIAGNOSTICOS */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_manutencao
ON CHOOSE OF Btn_E IN FRAME f_manutencao /* DIAGNOSTICOS */
DO:
    RUN manutencao_diagnosticos.w.

    RUN habilita_opcoes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_F
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_manutencao
ON ANY-KEY OF Btn_F IN FRAME f_manutencao /* SUPRIMENTO */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_manutencao
ON CHOOSE OF Btn_F IN FRAME f_manutencao /* SUPRIMENTO */
DO:    
    RUN procedures/inicializa_dispositivo.p ( INPUT 6,
                                             OUTPUT aux_flgderro).            

    IF  NOT xfs_impressora   OR   /* nao habilitada ou gerou algum erro */
        xfs_impsempapel      THEN /* sem papel */
        DO:
            RUN mensagem.w (INPUT NO,
                            INPUT "    Atenção!",
                            INPUT "",
                            INPUT "Este terminal não possui papel",
                            INPUT "para impressão do comprovante.",
                            INPUT "",
                            INPUT "Verifique a impressora.").
            
            PAUSE 10 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.            
        END.

    RUN manutencao_suprimento.w (INPUT NO).

    RUN habilita_opcoes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_G
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_manutencao
ON ANY-KEY OF Btn_G IN FRAME f_manutencao /* REINICIAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_manutencao
ON CHOOSE OF Btn_G IN FRAME f_manutencao /* REINICIAR */
DO:
    RUN procedures/efetua_reboot.p.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_manutencao
ON ANY-KEY OF Btn_H IN FRAME f_manutencao /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_manutencao
ON CHOOSE OF Btn_H IN FRAME f_manutencao /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_manutencao OCX.Tick
PROCEDURE temporizador.t_manutencao.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_manutencao.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_manutencao 


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
    FRAME f_manutencao:LOAD-MOUSE-POINTER("blank.cur").

    chtemporizador:t_manutencao:INTERVAL = glb_nrtempor.

    RUN habilita_opcoes.

    /* coloca o foco no botao H */
    APPLY "ENTRY" TO Btn_H.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_manutencao  _CONTROL-LOAD
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

OCXFile = SEARCH( "manutencao.wrx":U ).
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
ELSE MESSAGE "manutencao.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_manutencao  _DEFAULT-DISABLE
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
  HIDE FRAME f_manutencao.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_manutencao  _DEFAULT-ENABLE
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
  ENABLE IMAGE-34 IMAGE-35 IMAGE-36 IMAGE-37 IMAGE-38 IMAGE-39 IMAGE-40 
         IMAGE-43 Btn_A Btn_E Btn_B Btn_F Btn_C Btn_G Btn_D Btn_H 
      WITH FRAME f_manutencao.
  {&OPEN-BROWSERS-IN-QUERY-f_manutencao}
  VIEW w_manutencao.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE habilita_opcoes w_manutencao 
PROCEDURE habilita_opcoes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    ENABLE Btn_A
           Btn_B
           Btn_C
           Btn_D
           Btn_E
           Btn_F
           Btn_G
           Btn_H WITH FRAME f_manutencao.

    /* Situações do TAA */

    /* Aberto */
    IF  glb_cdsittfn = 1  THEN
        DISABLE Btn_A WITH FRAME f_manutencao.

    /* Suprido */
    IF  glb_flgsupri  THEN
        DISABLE Btn_F WITH FRAME f_manutencao.
    ELSE
    /* se nao estiver suprido e nao tiver envelopes */
    IF  glb_qtenvelo = 0  THEN
        DISABLE Btn_B WITH FRAME f_manutencao.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_manutencao 
PROCEDURE tecla :
chtemporizador:t_manutencao:INTERVAL = 0.

    /* ---------- */
    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).
    
    IF  aux_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.

    IF  KEY-FUNCTION(LASTKEY) = "A"          AND
        Btn_A:SENSITIVE IN FRAME f_manutencao  THEN
        APPLY "CHOOSE" TO Btn_A.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "B"          AND
        Btn_B:SENSITIVE IN FRAME f_manutencao  THEN
        APPLY "CHOOSE" TO Btn_B.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "C"          AND
        Btn_C:SENSITIVE IN FRAME f_manutencao  THEN
        APPLY "CHOOSE" TO Btn_C.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "D"          AND
        Btn_D:SENSITIVE IN FRAME f_manutencao  THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "E"          AND
        Btn_E:SENSITIVE IN FRAME f_manutencao  THEN
        APPLY "CHOOSE" TO Btn_E.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "F"          AND
        Btn_F:SENSITIVE IN FRAME f_manutencao  THEN
        APPLY "CHOOSE" TO Btn_F.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "G"          AND
        Btn_G:SENSITIVE IN FRAME f_manutencao  THEN
        APPLY "CHOOSE" TO Btn_G.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"          AND
        Btn_H:SENSITIVE IN FRAME f_manutencao  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_manutencao:INTERVAL = glb_nrtempor.

    /* coloca o foco no botao H */
    APPLY "ENTRY" TO Btn_H.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

