&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_debaut_limite_alterar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_debaut_limite_alterar 
/* ..............................................................................

Procedure: cartao_pagamento_debaut_limite_alterar.w
Objetivo : Tela de alteração de limite de débito automático [PROJ320]
Autor    : Lucas Lunelli
Data     : Maio/2016

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

DEFINE INPUT  PARAM par_nmempres     AS CHAR         NO-UNDO.
DEFINE INPUT  PARAM par_cdrefere     AS CHAR         NO-UNDO.
DEFINE INPUT  PARAM par_cdhistor     AS INTE         NO-UNDO.
DEFINE INPUT  PARAM par_cdempcon     AS INTE         NO-UNDO.
DEFINE INPUT  PARAM par_cdsegmto     AS INTE         NO-UNDO.
DEFINE INPUT  PARAM par_desmaxdb     AS CHAR         NO-UNDO.
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
&Scoped-define FRAME-NAME f_debaut_limite_alterar

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-37 IMAGE-40 RECT-133 RECT-134 RECT-135 ~
ed_vlrmaxdb Btn_D Btn_H ed_cdagectl ed_nmrescop ed_nrdconta ed_nmextttl 
&Scoped-Define DISPLAYED-OBJECTS ed_nmempres ed_cdrefere ed_vlrmaxdb ~
ed_cdagectl ed_nmrescop ed_nrdconta ed_nmextttl 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_debaut_limite_alterar AS WIDGET-HANDLE NO-UNDO.

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

DEFINE VARIABLE ed_cdagectl AS INTEGER FORMAT "9999":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 16 BY 1.24
     FONT 15 NO-UNDO.

DEFINE VARIABLE ed_cdrefere AS CHARACTER FORMAT "x(17)":U 
     VIEW-AS FILL-IN 
     SIZE 75 BY 1.19
     FONT 14 NO-UNDO.

DEFINE VARIABLE ed_nmempres AS CHARACTER FORMAT "X(20)":U 
     VIEW-AS FILL-IN 
     SIZE 75.2 BY 1.19
     FONT 14 NO-UNDO.

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

DEFINE VARIABLE ed_vlrmaxdb AS DECIMAL FORMAT "zzz,zz9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 22.6 BY 1.19
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

DEFINE RECTANGLE RECT-135
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 24.6 BY 1.67.

DEFINE RECTANGLE RECT-98
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-99
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_debaut_limite_alterar
     ed_nmempres AT ROW 10.76 COL 56 COLON-ALIGNED NO-LABEL WIDGET-ID 256
     ed_cdrefere AT ROW 14.24 COL 132 RIGHT-ALIGNED NO-LABEL WIDGET-ID 254
     ed_vlrmaxdb AT ROW 17.24 COL 131.6 RIGHT-ALIGNED NO-LABEL WIDGET-ID 272
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 156
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 158
     ed_cdagectl AT ROW 6 COL 46 COLON-ALIGNED NO-LABEL WIDGET-ID 238 NO-TAB-STOP 
     ed_nmrescop AT ROW 6 COL 62 COLON-ALIGNED NO-LABEL WIDGET-ID 242 NO-TAB-STOP 
     ed_nrdconta AT ROW 7.43 COL 46 COLON-ALIGNED NO-LABEL WIDGET-ID 244 NO-TAB-STOP 
     ed_nmextttl AT ROW 7.43 COL 72 COLON-ALIGNED NO-LABEL WIDGET-ID 240 NO-TAB-STOP 
     "Empresa:" VIEW-AS TEXT
          SIZE 16.8 BY 1.19 AT ROW 11 COL 39.8 WIDGET-ID 264
          FONT 14
     "Cooperativa:" VIEW-AS TEXT
          SIZE 28 BY 1.19 AT ROW 6 COL 18.6 WIDGET-ID 134
          FONT 8
     "DÉBITO AUTOMÁTICO" VIEW-AS TEXT
          SIZE 100 BY 3.33 AT ROW 1.48 COL 32 WIDGET-ID 214
          FGCOLOR 1 FONT 10
     "Limite Máximo para Débito:" VIEW-AS TEXT
          SIZE 45.6 BY 1.19 AT ROW 17.29 COL 11.2 WIDGET-ID 270
          FONT 14
     "Identificador:" VIEW-AS TEXT
          SIZE 22 BY 1.19 AT ROW 14.19 COL 35 WIDGET-ID 262
          FONT 14
     "Conta/Titular:" VIEW-AS TEXT
          SIZE 29 BY 1.19 AT ROW 7.43 COL 17 WIDGET-ID 140
          FONT 8
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-37 AT ROW 24.24 COL 1 WIDGET-ID 148
     IMAGE-40 AT ROW 24.24 COL 156 WIDGET-ID 218
     RECT-133 AT ROW 10.52 COL 57 WIDGET-ID 258
     RECT-134 AT ROW 14 COL 57 WIDGET-ID 260
     RECT-135 AT ROW 17 COL 109 WIDGET-ID 268
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
  CREATE WINDOW w_debaut_limite_alterar ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.57
         WIDTH              = 160
         MAX-HEIGHT         = 35.76
         MAX-WIDTH          = 256
         VIRTUAL-HEIGHT     = 35.76
         VIRTUAL-WIDTH      = 256
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
ASSIGN w_debaut_limite_alterar = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_debaut_limite_alterar
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_debaut_limite_alterar
   FRAME-NAME                                                           */
/* SETTINGS FOR FILL-IN ed_cdrefere IN FRAME f_debaut_limite_alterar
   NO-ENABLE ALIGN-R                                                    */
/* SETTINGS FOR FILL-IN ed_nmempres IN FRAME f_debaut_limite_alterar
   NO-ENABLE                                                            */
ASSIGN 
       ed_nmempres:READ-ONLY IN FRAME f_debaut_limite_alterar        = TRUE.

/* SETTINGS FOR FILL-IN ed_vlrmaxdb IN FRAME f_debaut_limite_alterar
   ALIGN-R                                                              */
/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_debaut_limite_alterar
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_debaut_limite_alterar
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_debaut_limite_alterar
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_debaut_limite_alterar:HANDLE
       ROW             = 1.71
       COLUMN          = 17
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_debaut_limite_alterar */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_debaut_limite_alterar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_debaut_limite_alterar w_debaut_limite_alterar
ON END-ERROR OF w_debaut_limite_alterar
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_debaut_limite_alterar w_debaut_limite_alterar
ON WINDOW-CLOSE OF w_debaut_limite_alterar
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_debaut_limite_alterar
ON ANY-KEY OF Btn_D IN FRAME f_debaut_limite_alterar /* CONFIRMAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_debaut_limite_alterar
ON CHOOSE OF Btn_D IN FRAME f_debaut_limite_alterar /* CONFIRMAR */
DO:
    IF  DECI(ed_vlrmaxdb:SCREEN-VALUE) <= 0 THEN
        DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "    ATENÇÃO",
                            INPUT "",
                            INPUT "",
                            INPUT "Valor deve ser informado.",
                            INPUT "",
                            INPUT "").
    
            PAUSE 4 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.
    
            APPLY "ENTRY" TO ed_vlrmaxdb.
            RETURN NO-APPLY.
        END.

    /* puxa o frame principal */
     h_principal:MOVE-TO-TOP().

    RUN procedures/altera_autorizacao_debito.p (INPUT par_cdrefere,
                                                INPUT par_cdhistor,                                                
                                                INPUT DECI(ed_vlrmaxdb:SCREEN-VALUE),
                                               OUTPUT par_flgderro).

    IF  par_flgderro   THEN
        DO:
            w_debaut_limite_alterar:MOVE-TO-TOP().

            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "NOK".
        END.
    ELSE
        DO:
            /* puxa o frame principal pra frente */
            h_principal:MOVE-TO-TOP().           
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
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_debaut_limite_alterar
ON ANY-KEY OF Btn_H IN FRAME f_debaut_limite_alterar /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_debaut_limite_alterar
ON CHOOSE OF Btn_H IN FRAME f_debaut_limite_alterar /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_vlrmaxdb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_vlrmaxdb w_debaut_limite_alterar
ON ANY-KEY OF ed_vlrmaxdb IN FRAME f_debaut_limite_alterar
DO:
    RUN tecla.

    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            APPLY "ENTRY" TO Btn_D.
            RETURN NO-APPLY.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        ed_vlrmaxdb:SCREEN-VALUE = "".
    ELSE
    IF  RETURN-VALUE = "OK"  THEN
        RETURN "OK".
    
    /* se nao digitou numeros, despreza */
    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))   OR
        LENGTH(ed_vlrmaxdb:SCREEN-VALUE) >= 10                    THEN
        RETURN NO-APPLY.
    ELSE
        DO:
            /* controle para permitir centavos */
            ed_vlrmaxdb:SCREEN-VALUE = STRING(DECIMAL(ed_vlrmaxdb:SCREEN-VALUE +
                                              KEY-FUNCTION(LASTKEY)) * 10).

            RETURN NO-APPLY.
        END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_debaut_limite_alterar OCX.Tick
PROCEDURE temporizador.t_debaut_limite_alterar.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_debaut_limite_alterar.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_debaut_limite_alterar 


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
    FRAME f_debaut_limite_alterar:LOAD-MOUSE-POINTER("blank.cur").

    ASSIGN chtemporizador:t_debaut_limite_alterar:INTERVAL = glb_nrtempor

           /* Dados do associado */
           ed_cdagectl = glb_cdagectl
           ed_nmrescop = " - " + glb_nmrescop
           ed_nrdconta = glb_nrdconta
           ed_nmextttl = glb_nmtitula[1].

    DISPLAY ed_cdagectl  ed_nmrescop
            ed_nrdconta  ed_nmextttl
            WITH FRAME f_debaut_limite_alterar.

    ASSIGN ed_nmempres:SCREEN-VALUE = par_nmempres
           ed_cdrefere:SCREEN-VALUE = par_cdrefere
           ed_vlrmaxdb:SCREEN-VALUE = par_desmaxdb.

    APPLY "ENTRY" TO ed_vlrmaxdb.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_debaut_limite_alterar  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_pagamento_debaut_limite_alterar.wrx":U ).
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
ELSE MESSAGE "cartao_pagamento_debaut_limite_alterar.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_debaut_limite_alterar  _DEFAULT-DISABLE
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
  HIDE FRAME f_debaut_limite_alterar.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_debaut_limite_alterar  _DEFAULT-ENABLE
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
  DISPLAY ed_nmempres ed_cdrefere ed_vlrmaxdb ed_cdagectl ed_nmrescop 
          ed_nrdconta ed_nmextttl 
      WITH FRAME f_debaut_limite_alterar.
  ENABLE IMAGE-37 IMAGE-40 RECT-133 RECT-134 RECT-135 ed_vlrmaxdb Btn_D Btn_H 
         ed_cdagectl ed_nmrescop ed_nrdconta ed_nmextttl 
      WITH FRAME f_debaut_limite_alterar.
  {&OPEN-BROWSERS-IN-QUERY-f_debaut_limite_alterar}
  VIEW w_debaut_limite_alterar.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_debaut_limite_alterar 
PROCEDURE tecla :
chtemporizador:t_debaut_limite_alterar:INTERVAL = 0.

    IF  KEY-FUNCTION(LASTKEY) = "D"                           AND
        Btn_D:SENSITIVE IN FRAME f_debaut_limite_alterar  THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                           AND
        Btn_H:SENSITIVE IN FRAME f_debaut_limite_alterar  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_debaut_limite_alterar:INTERVAL = glb_nrtempor.
    
    
    IF  RETURN-VALUE = "OK"  THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.    
            RETURN "OK".
        END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

