&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_cartao_saque
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_cartao_saque 
/* ..............................................................................

Procedure: cartao_saque.w
Objetivo : Tela para saque
Autor    : Evandro
Data     : Janeiro 2010

Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

                  08/05/2013 - Transferencia intercooperativa (Gabriel).
                  
                  20/08/2015 - Visualização de impressão
                               (Lucas Lunelli - Melhoria 83 [SD 279180])

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


/* para organizacao das notas */
DEFINE TEMP-TABLE tt_notas      NO-UNDO
       FIELD vldnotas   AS DECIMAL
       INDEX tt_notas1  AS PRIMARY UNIQUE vldnotas.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_cartao_saque

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-34 IMAGE-35 IMAGE-36 IMAGE-37 IMAGE-38 ~
IMAGE-39 IMAGE-40 IMAGE-48 Btn_A Btn_E Btn_B Btn_F Btn_C Btn_G Btn_D Btn_H ~
ed_cdagectl ed_nmrescop ed_nrdconta ed_nmextttl 
&Scoped-Define DISPLAYED-OBJECTS ed_cdagectl ed_nmrescop ed_nrdconta ~
ed_nmextttl 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_cartao_saque AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_A 
     LABEL "0,00" 
     SIZE 61 BY 3.33
     FONT 10.

DEFINE BUTTON Btn_B 
     LABEL "0,00" 
     SIZE 61 BY 3.33
     FONT 10.

DEFINE BUTTON Btn_C 
     LABEL "0,00" 
     SIZE 61 BY 3.33
     FONT 10.

DEFINE BUTTON Btn_D 
     LABEL "0,00" 
     SIZE 61 BY 3.33
     FONT 10.

DEFINE BUTTON Btn_E 
     LABEL "0,00" 
     SIZE 61 BY 3.33
     FONT 10.

DEFINE BUTTON Btn_F 
     LABEL "0,00" 
     SIZE 61 BY 3.33
     FONT 10.

DEFINE BUTTON Btn_G 
     LABEL "OUTRO VALOR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_H 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_cdagectl AS INTEGER FORMAT "9999":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 16 BY 1.24
     FONT 15 NO-UNDO.

DEFINE VARIABLE ed_nmextttl AS CHARACTER FORMAT "X(26)":U 
      VIEW-AS TEXT 
     SIZE 68 BY 1.19
     FONT 8 NO-UNDO.

DEFINE VARIABLE ed_nmrescop AS CHARACTER FORMAT "X(15)":U 
      VIEW-AS TEXT 
     SIZE 68 BY 1.24
     FONT 15 NO-UNDO.

DEFINE VARIABLE ed_nrdconta AS INTEGER FORMAT "zzzz,zz9,9":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 24 BY 1.19
     FONT 8 NO-UNDO.

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

DEFINE FRAME f_cartao_saque
     Btn_A AT ROW 9.1 COL 6 WIDGET-ID 78
     Btn_E AT ROW 9.1 COL 94.4 WIDGET-ID 68
     Btn_B AT ROW 14.1 COL 6 WIDGET-ID 84
     Btn_F AT ROW 14.1 COL 94.4 WIDGET-ID 70
     Btn_C AT ROW 19.1 COL 6 WIDGET-ID 82
     Btn_G AT ROW 19.1 COL 94.4 WIDGET-ID 86
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 66
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 74
     ed_cdagectl AT ROW 6 COL 46 COLON-ALIGNED NO-LABEL WIDGET-ID 228 NO-TAB-STOP 
     ed_nmrescop AT ROW 6 COL 62 COLON-ALIGNED NO-LABEL WIDGET-ID 230 NO-TAB-STOP 
     ed_nrdconta AT ROW 7.43 COL 46 COLON-ALIGNED NO-LABEL WIDGET-ID 232 NO-TAB-STOP 
     ed_nmextttl AT ROW 7.43 COL 72 COLON-ALIGNED NO-LABEL WIDGET-ID 236 NO-TAB-STOP 
     "Cooperativa:" VIEW-AS TEXT
          SIZE 28 BY 1.19 AT ROW 6 COL 18.6 WIDGET-ID 134
          FONT 8
     "MENU DE SAQUE" VIEW-AS TEXT
          SIZE 78 BY 3.33 AT ROW 1.48 COL 42 WIDGET-ID 166
          FGCOLOR 1 FONT 10
     "Conta/Titular:" VIEW-AS TEXT
          SIZE 29 BY 1.19 AT ROW 7.43 COL 17 WIDGET-ID 140
          FONT 8
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
  CREATE WINDOW w_cartao_saque ASSIGN
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
ASSIGN w_cartao_saque = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_cartao_saque
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_cartao_saque
   FRAME-NAME                                                           */
/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_cartao_saque
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_cartao_saque
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_cartao_saque
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_cartao_saque:HANDLE
       ROW             = 1.71
       COLUMN          = 4
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_saque */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_cartao_saque
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_saque w_cartao_saque
ON END-ERROR OF w_cartao_saque
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_saque w_cartao_saque
ON WINDOW-CLOSE OF w_cartao_saque
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_A
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_A w_cartao_saque
ON ANY-KEY OF Btn_A IN FRAME f_cartao_saque /* 0,00 */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_A w_cartao_saque
ON CHOOSE OF Btn_A IN FRAME f_cartao_saque /* 0,00 */
DO:
    RUN efetua_saque(INPUT DEC(SELF:LABEL)).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_B
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_B w_cartao_saque
ON ANY-KEY OF Btn_B IN FRAME f_cartao_saque /* 0,00 */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_B w_cartao_saque
ON CHOOSE OF Btn_B IN FRAME f_cartao_saque /* 0,00 */
DO:
    RUN efetua_saque(INPUT DEC(SELF:LABEL)).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_C
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_C w_cartao_saque
ON ANY-KEY OF Btn_C IN FRAME f_cartao_saque /* 0,00 */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_C w_cartao_saque
ON CHOOSE OF Btn_C IN FRAME f_cartao_saque /* 0,00 */
DO:
    RUN efetua_saque(INPUT DEC(SELF:LABEL)).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_saque
ON ANY-KEY OF Btn_D IN FRAME f_cartao_saque /* 0,00 */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_saque
ON CHOOSE OF Btn_D IN FRAME f_cartao_saque /* 0,00 */
DO:
    RUN efetua_saque(INPUT DEC(SELF:LABEL)).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_E
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_cartao_saque
ON ANY-KEY OF Btn_E IN FRAME f_cartao_saque /* 0,00 */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_cartao_saque
ON CHOOSE OF Btn_E IN FRAME f_cartao_saque /* 0,00 */
DO:
    RUN efetua_saque(INPUT DEC(SELF:LABEL)).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_F
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_cartao_saque
ON ANY-KEY OF Btn_F IN FRAME f_cartao_saque /* 0,00 */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_cartao_saque
ON CHOOSE OF Btn_F IN FRAME f_cartao_saque /* 0,00 */
DO:
    RUN efetua_saque(INPUT DEC(SELF:LABEL)).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_G
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_cartao_saque
ON ANY-KEY OF Btn_G IN FRAME f_cartao_saque /* OUTRO VALOR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_cartao_saque
ON CHOOSE OF Btn_G IN FRAME f_cartao_saque /* OUTRO VALOR */
DO:
    RUN cartao_saque_valor.w.
    
    /* repassa o retorno */
    RETURN RETURN-VALUE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_saque
ON ANY-KEY OF Btn_H IN FRAME f_cartao_saque /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_saque
ON CHOOSE OF Btn_H IN FRAME f_cartao_saque /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_cartao_saque OCX.Tick
PROCEDURE temporizador.t_cartao_saque.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_cartao_saque.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_cartao_saque 


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
    FRAME f_cartao_saque:LOAD-MOUSE-POINTER("blank.cur").

    ASSIGN chtemporizador:t_cartao_saque:INTERVAL = glb_nrtempor
                   
           /* Dados do associado */
           ed_cdagectl = glb_cdagectl
           ed_nmrescop = " - " + glb_nmrescop
           ed_nrdconta = glb_nrdconta
           ed_nmextttl = glb_nmtitula[1].

    DISPLAY ed_cdagectl  ed_nmrescop
            ed_nrdconta  ed_nmextttl
            WITH FRAME f_cartao_saque.


    RUN valores_saque.


    /* coloca o foco no botao H */
    APPLY "ENTRY" TO Btn_H.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_cartao_saque  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_saque.wrx":U ).
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
ELSE MESSAGE "cartao_saque.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_cartao_saque  _DEFAULT-DISABLE
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
  HIDE FRAME f_cartao_saque.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE efetua_saque w_cartao_saque 
PROCEDURE efetua_saque :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE INPUT PARAM par_vldsaque     AS DECIMAL      NO-UNDO.

    DEFINE VARIABLE    aux_dssaqmax     AS CHAR         NO-UNDO.
    DEFINE VARIABLE    aux_flgcompr     AS LOGICAL      NO-UNDO.
    DEFINE VARIABLE    aux_tximpres     AS CHAR         NO-UNDO.
    

    /* verifica se o pagamento eh possivel */
    RUN procedures/dispensa_notas.p ( INPUT par_vldsaque,
                                      INPUT NO, /* nao pagar */
                                      INPUT "",
                                     OUTPUT aux_flgderro).

    IF  aux_flgderro  THEN
        RETURN "NOK".



    /* verifica se pode sacar */
    RUN procedures/verifica_saque.p ( INPUT par_vldsaque,
                                     OUTPUT aux_dssaqmax,
                                     OUTPUT aux_flgcompr,
                                     OUTPUT aux_flgderro).

    IF  aux_flgderro  THEN
        RETURN "NOK".



    /* para quem nao tem letras, pede cpf */
    IF  NOT glb_idsenlet  THEN
        RUN senha_cpf.w (OUTPUT aux_flgderro).
    ELSE
        RUN senha.w (OUTPUT aux_flgderro).

    IF  NOT aux_flgderro  THEN
        DO:
            /* puxa o frame principal pra frente */
            h_principal:MOVE-TO-TOP().                  

            RUN procedures/efetua_saque.p ( INPUT par_vldsaque,
                                           OUTPUT aux_tximpres,
                                           OUTPUT aux_flgderro).
            
            IF  aux_tximpres <> ""  THEN
                DO:
                    RUN procedures/inicializa_dispositivo.p ( INPUT 6,
                                                              OUTPUT aux_flgderro).
                                                           
                    RUN impressao_visualiza.w (INPUT "Comprovante de Saque...",
                                               INPUT  aux_tximpres,
                                               INPUT 0, /*Comprovante*/
                                               INPUT "").
                END.

            RETURN "OK".
        END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_cartao_saque  _DEFAULT-ENABLE
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
  DISPLAY ed_cdagectl ed_nmrescop ed_nrdconta ed_nmextttl 
      WITH FRAME f_cartao_saque.
  ENABLE IMAGE-34 IMAGE-35 IMAGE-36 IMAGE-37 IMAGE-38 IMAGE-39 IMAGE-40 
         IMAGE-48 Btn_A Btn_E Btn_B Btn_F Btn_C Btn_G Btn_D Btn_H ed_cdagectl 
         ed_nmrescop ed_nrdconta ed_nmextttl 
      WITH FRAME f_cartao_saque.
  {&OPEN-BROWSERS-IN-QUERY-f_cartao_saque}
  VIEW w_cartao_saque.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_cartao_saque 
PROCEDURE tecla :
chtemporizador:t_cartao_saque:INTERVAL = 0.

    /* ---------- */
    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).
    
    IF  aux_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.

    IF  KEY-FUNCTION(LASTKEY) = "A"              AND
        Btn_A:SENSITIVE IN FRAME f_cartao_saque  THEN
        APPLY "CHOOSE" TO Btn_A.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "B"              AND
        Btn_B:SENSITIVE IN FRAME f_cartao_saque  THEN
        APPLY "CHOOSE" TO Btn_B.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "C"              AND
        Btn_C:SENSITIVE IN FRAME f_cartao_saque  THEN
        APPLY "CHOOSE" TO Btn_C.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "D"              AND
        Btn_D:SENSITIVE IN FRAME f_cartao_saque  THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "E"              AND
        Btn_E:SENSITIVE IN FRAME f_cartao_saque  THEN
        APPLY "CHOOSE" TO Btn_E.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "F"              AND
        Btn_F:SENSITIVE IN FRAME f_cartao_saque  THEN
        APPLY "CHOOSE" TO Btn_F.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "G"              AND
        Btn_G:SENSITIVE IN FRAME f_cartao_saque  THEN
        APPLY "CHOOSE" TO Btn_G.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"              AND
        Btn_H:SENSITIVE IN FRAME f_cartao_saque  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_cartao_saque:INTERVAL = glb_nrtempor.

    /* se usou alguma opcao */
    IF  RETURN-VALUE = "OK"  THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "OK".
        END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE valores_saque w_cartao_saque 
PROCEDURE valores_saque :
/*------------------------------------------------------------------------------
  Purpose: Calcula os valores dos botões conforme as notas supridas disponiveis
  Parameters:  <none>
  Notes: Para notas de varios valores, o calculo começa com a MENOR nota e
         segue somando seu valor ate a nota seguinte, e assim sucessivamente.
------------------------------------------------------------------------------*/

DEFINE VARIABLE aux_contador    AS INTEGER      NO-UNDO.

DEFINE VARIABLE aux_vldanota    AS DECIMAL      NO-UNDO.
DEFINE VARIABLE aux_vlultnot    AS DECIMAL      NO-UNDO.

EMPTY TEMP-TABLE tt_notas.


aux_contador = 0.

/* valores de notas disponiveis */
IF  glb_vlnotk7A > 0  AND
    glb_qtnotk7A > 0  AND
    glb_cassetes[1]   THEN
    DO:
        FIND tt_notas WHERE tt_notas.vldnotas = glb_vlnotk7A
                            NO-LOCK NO-ERROR.
        
        IF  NOT AVAILABLE tt_notas  THEN
            DO:
                CREATE tt_notas.
                ASSIGN tt_notas.vldnotas = glb_vlnotk7A
                       aux_contador      = aux_contador + 1.
            END.
    END.

IF  glb_vlnotk7B > 0  AND
    glb_qtnotk7B > 0  AND
    glb_cassetes[2]   THEN
    DO:
        FIND tt_notas WHERE tt_notas.vldnotas = glb_vlnotk7B
                            NO-LOCK NO-ERROR.
        
        IF  NOT AVAILABLE tt_notas  THEN
            DO:
                CREATE tt_notas.
                ASSIGN tt_notas.vldnotas = glb_vlnotk7B
                       aux_contador      = aux_contador + 1.
            END.
    END.

IF  glb_vlnotk7C > 0  AND
    glb_qtnotk7C > 0  AND
    glb_cassetes[3]   THEN
    DO:
        FIND tt_notas WHERE tt_notas.vldnotas = glb_vlnotk7C
                            NO-LOCK NO-ERROR.
        
        IF  NOT AVAILABLE tt_notas  THEN
            DO:
                CREATE tt_notas.
                ASSIGN tt_notas.vldnotas = glb_vlnotk7C
                       aux_contador      = aux_contador + 1.
            END.
    END.

IF  glb_vlnotk7D > 0  AND
    glb_qtnotk7D > 0  AND
    glb_cassetes[4]   THEN
    DO:
        FIND tt_notas WHERE tt_notas.vldnotas = glb_vlnotk7D
                            NO-LOCK NO-ERROR.
        
        IF  NOT AVAILABLE tt_notas  THEN
            DO:
                CREATE tt_notas.
                ASSIGN tt_notas.vldnotas = glb_vlnotk7D
                       aux_contador      = aux_contador + 1.
            END.
    END.


/* calcula os 6 valores sugeridos para saque */
FIND FIRST tt_notas NO-LOCK NO-ERROR.

IF  AVAILABLE tt_notas  THEN
    ASSIGN aux_vldanota = tt_notas.vldnotas
           aux_vlultnot = aux_vldanota.
ELSE
    DO:
        /* Não há notas para saque */
        aux_flgderro = YES.
        RETURN "NOK".
    END.


DO  WHILE aux_contador < 6:

    FIND FIRST tt_notas WHERE tt_notas.vldnotas > aux_vlultnot NO-LOCK NO-ERROR.

    /* existe nota superior a nota atual */
    IF  AVAILABLE tt_notas  THEN
        DO:
            /* verifica a soma de mais uma cedula da nota atual é menor que a proxima nota */
            IF  (aux_vlultnot + aux_vldanota) < tt_notas.vldnotas  THEN
                DO:
                    CREATE tt_notas.
                    ASSIGN tt_notas.vldnotas = aux_vlultnot + aux_vldanota
                           aux_vlultnot      = tt_notas.vldnotas
                           aux_contador      = aux_contador + 1.
                END.
            ELSE
                /* pega a próxima nota */
                ASSIGN aux_vldanota = tt_notas.vldnotas
                       aux_vlultnot = aux_vldanota.
        END.
    ELSE
        /* segue somando o valor da ultima nota */
        DO:
            CREATE tt_notas.
            ASSIGN tt_notas.vldnotas = aux_vlultnot + aux_vldanota
                   aux_vlultnot      = tt_notas.vldnotas
                   aux_contador      = aux_contador + 1.
        END.
END.





aux_contador = 0.
FOR EACH tt_notas BY tt_notas.vldnotas:

    aux_contador = aux_contador + 1.

    IF aux_contador = 1 THEN
       Btn_A:LABEL IN FRAME f_cartao_saque = STRING(tt_notas.vldnotas,"zz9.99").
    ELSE
    IF aux_contador = 2 THEN
       Btn_B:LABEL IN FRAME f_cartao_saque = STRING(tt_notas.vldnotas,"zz9.99").
    ELSE
    IF aux_contador = 3 THEN
       Btn_C:LABEL IN FRAME f_cartao_saque = STRING(tt_notas.vldnotas,"zz9.99").
    ELSE
    IF aux_contador = 4 THEN
       Btn_D:LABEL IN FRAME f_cartao_saque = STRING(tt_notas.vldnotas,"zz9.99").
    ELSE
    IF aux_contador = 5 THEN
       Btn_E:LABEL IN FRAME f_cartao_saque = STRING(tt_notas.vldnotas,"zz9.99").
    ELSE
    IF aux_contador = 6 THEN
       Btn_F:LABEL IN FRAME f_cartao_saque = STRING(tt_notas.vldnotas,"zz9.99").
END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

