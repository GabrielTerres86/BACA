&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_debaut_sms_cadastrar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_debaut_sms_cadastrar 
/* ..............................................................................

Procedure: cartao_pagamento_debaut_sms_cadastrar.w
Objetivo : Tela de cadastro de SMS de débito automático
Autor    : Lucas Lunelli
Data     : Abril/2016

Ultima alteração: 30/05/2016 - Alteraçoes Oferta DEBAUT Sicredi (Lucas Lunelli - [PROJ320])

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

DEFINE INPUT  PARAM par_idrotina     AS INTE         NO-UNDO.

/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }

DEFINE VARIABLE aux_nrDDD           AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE aux_nrtelefo        AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE aux_dsmsgsms        AS CHARACTER                NO-UNDO.
DEFINE VARIABLE aux_flgderro        AS LOGICAL                  NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_debaut_sms_cadastrar

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-37 IMAGE-40 RECT-133 RECT-134 RECT-135 ~
IMAGE-53 ed_dsmsgsms ed_nrDDD ed_nrtelefo Btn_G Btn_D Btn_H ed_cdagectl ~
ed_nmrescop ed_nrdconta ed_nmextttl 
&Scoped-Define DISPLAYED-OBJECTS ed_dsmsgsms ed_nrDDD ed_nrtelefo ~
ed_cdagectl ed_nmrescop ed_nrdconta ed_nmextttl 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_debaut_sms_cadastrar AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_D 
     LABEL "" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_G 
     LABEL "EXCLUIR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_H 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_dsmsgsms AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 148 BY 5.14
     FONT 14 NO-UNDO.

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

DEFINE VARIABLE ed_nrDDD AS CHARACTER FORMAT "x(2)":U 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1.19
     FONT 14 NO-UNDO.

DEFINE VARIABLE ed_nrtelefo AS CHARACTER FORMAT "x(9)":U 
     VIEW-AS FILL-IN 
     SIZE 28 BY 1.19
     FONT 14 NO-UNDO.

DEFINE IMAGE IMAGE-37
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-40
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-53
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE RECTANGLE RECT-100
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 2 .

DEFINE RECTANGLE RECT-133
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 151 BY 5.62.

DEFINE RECTANGLE RECT-134
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 17 BY 1.67.

DEFINE RECTANGLE RECT-135
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 30 BY 1.67.

DEFINE RECTANGLE RECT-98
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-99
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_debaut_sms_cadastrar
     ed_dsmsgsms AT ROW 9.57 COL 7.4 NO-LABEL WIDGET-ID 280 NO-TAB-STOP 
     ed_nrDDD AT ROW 16.19 COL 80.8 RIGHT-ALIGNED NO-LABEL WIDGET-ID 254
     ed_nrtelefo AT ROW 16.19 COL 111.8 RIGHT-ALIGNED NO-LABEL WIDGET-ID 272
     Btn_G AT ROW 19.14 COL 94.4 WIDGET-ID 278
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 156
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 158
     ed_cdagectl AT ROW 6 COL 46 COLON-ALIGNED NO-LABEL WIDGET-ID 238 NO-TAB-STOP 
     ed_nmrescop AT ROW 6 COL 62 COLON-ALIGNED NO-LABEL WIDGET-ID 242 NO-TAB-STOP 
     ed_nrdconta AT ROW 7.43 COL 46 COLON-ALIGNED NO-LABEL WIDGET-ID 244 NO-TAB-STOP 
     ed_nmextttl AT ROW 7.43 COL 72 COLON-ALIGNED NO-LABEL WIDGET-ID 240 NO-TAB-STOP 
     "DÉBITO AUTOMÁTICO" VIEW-AS TEXT
          SIZE 100 BY 3.33 AT ROW 1.48 COL 32 WIDGET-ID 214
          FGCOLOR 1 FONT 10
     "Cooperativa:" VIEW-AS TEXT
          SIZE 28 BY 1.19 AT ROW 6 COL 18.6 WIDGET-ID 134
          FONT 8
     "Conta/Titular:" VIEW-AS TEXT
          SIZE 29 BY 1.19 AT ROW 7.43 COL 17 WIDGET-ID 140
          FONT 8
     "Celular:" VIEW-AS TEXT
          SIZE 13 BY 1.19 AT ROW 16.14 COL 49.8 WIDGET-ID 262
          FONT 14
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-37 AT ROW 24.24 COL 1 WIDGET-ID 148
     IMAGE-40 AT ROW 24.24 COL 156 WIDGET-ID 218
     RECT-133 AT ROW 9.33 COL 6 WIDGET-ID 258
     RECT-134 AT ROW 15.95 COL 65.8 WIDGET-ID 260
     RECT-135 AT ROW 15.95 COL 83.8 WIDGET-ID 268
     IMAGE-53 AT ROW 19.29 COL 156 WIDGET-ID 280
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
  CREATE WINDOW w_debaut_sms_cadastrar ASSIGN
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
ASSIGN w_debaut_sms_cadastrar = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_debaut_sms_cadastrar
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_debaut_sms_cadastrar
   FRAME-NAME                                                           */
ASSIGN 
       ed_dsmsgsms:AUTO-INDENT IN FRAME f_debaut_sms_cadastrar      = TRUE
       ed_dsmsgsms:READ-ONLY IN FRAME f_debaut_sms_cadastrar        = TRUE.

/* SETTINGS FOR FILL-IN ed_nrDDD IN FRAME f_debaut_sms_cadastrar
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN ed_nrtelefo IN FRAME f_debaut_sms_cadastrar
   ALIGN-R                                                              */
/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_debaut_sms_cadastrar
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_debaut_sms_cadastrar
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_debaut_sms_cadastrar
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_debaut_sms_cadastrar:HANDLE
       ROW             = 1.71
       COLUMN          = 17
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_debaut_sms_cadastrar */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_debaut_sms_cadastrar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_debaut_sms_cadastrar w_debaut_sms_cadastrar
ON END-ERROR OF w_debaut_sms_cadastrar
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_debaut_sms_cadastrar w_debaut_sms_cadastrar
ON WINDOW-CLOSE OF w_debaut_sms_cadastrar
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_debaut_sms_cadastrar
ON ANY-KEY OF Btn_D IN FRAME f_debaut_sms_cadastrar
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_debaut_sms_cadastrar
ON CHOOSE OF Btn_D IN FRAME f_debaut_sms_cadastrar
DO:
    IF  DECI(ed_nrDDD:SCREEN-VALUE)    <= 0 OR 
        DECI(ed_nrtelefo:SCREEN-VALUE) <= 0 THEN
        DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "    ATENÇÃO",
                            INPUT "",
                            INPUT "",
                            INPUT "Insira o número para envio de SMS.",
                            INPUT "",
                            INPUT "").
    
            PAUSE 4 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.
    
            APPLY "ENTRY" TO ed_nrDDD.
            RETURN NO-APPLY.
        END.
        
     IF  LENGTH(ed_nrtelefo:SCREEN-VALUE) < 8 THEN
         DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "    ATENÇÃO",
                            INPUT "",
                            INPUT "",
                            INPUT "Número inserido inválido.",
                            INPUT "",
                            INPUT "").
    
            PAUSE 4 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.
    
            APPLY "ENTRY" TO ed_nrtelefo.
            RETURN NO-APPLY.
        END.
        
     IF  LENGTH(ed_nrDDD:SCREEN-VALUE) < 2 THEN
         DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "    ATENÇÃO",
                            INPUT "",
                            INPUT "",
                            INPUT "DDD inserido inválido.",
                            INPUT "",
                            INPUT "").
    
            PAUSE 4 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.
    
            APPLY "ENTRY" TO ed_nrDDD.
            RETURN NO-APPLY.
        END.
        
    /* para quem nao tem letras, pede cpf */
    IF  NOT glb_idsenlet  THEN
        RUN senha_cpf.w (OUTPUT aux_flgderro).
    ELSE
        RUN senha.w (OUTPUT aux_flgderro).
        
    IF  NOT aux_flgderro  THEN
        DO:
            /* puxa o frame principal pra frente */
            h_principal:MOVE-TO-TOP().                  
             
            RUN procedures/altera_telefone_sms_debaut.p (INPUT DECI(ed_nrDDD:SCREEN-VALUE),
                                                         INPUT DECI(ed_nrtelefo:SCREEN-VALUE),
                                                        OUTPUT aux_flgderro).
            IF  aux_flgderro   THEN
                DO:
                    w_debaut_sms_cadastrar:MOVE-TO-TOP().

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
    ELSE 
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "NOK".
        END. 
        
    RETURN "OK".
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_G
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_debaut_sms_cadastrar
ON ANY-KEY OF Btn_G IN FRAME f_debaut_sms_cadastrar /* EXCLUIR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_debaut_sms_cadastrar
ON CHOOSE OF Btn_G IN FRAME f_debaut_sms_cadastrar /* EXCLUIR */
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
             
            RUN procedures/exclui_telefone_sms_debaut.p (OUTPUT aux_flgderro).
    
            IF  aux_flgderro   THEN
                DO:
                    w_debaut_sms_cadastrar:MOVE-TO-TOP().
        
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
    ELSE 
        DO:
            IF  RETURN-VALUE = "NOK" THEN
                DO:
                    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                    RETURN "NOK".
                END.
        END. 

    RETURN "OK".
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_debaut_sms_cadastrar
ON ANY-KEY OF Btn_H IN FRAME f_debaut_sms_cadastrar /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_debaut_sms_cadastrar
ON CHOOSE OF Btn_H IN FRAME f_debaut_sms_cadastrar /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_nrDDD
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nrDDD w_debaut_sms_cadastrar
ON ANY-KEY OF ed_nrDDD IN FRAME f_debaut_sms_cadastrar
DO:   
    RUN tecla.

    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            APPLY "ENTRY" TO ed_nrtelefo.
            RETURN NO-APPLY.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        ed_nrDDD:SCREEN-VALUE = "".
    ELSE
    IF  RETURN-VALUE = "OK"  THEN
        RETURN "OK".
    
    /* se nao digitou numeros, despreza */
    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))   OR
        LENGTH(ed_nrDDD:SCREEN-VALUE) >= 2                        THEN
        RETURN NO-APPLY.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_nrtelefo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nrtelefo w_debaut_sms_cadastrar
ON ANY-KEY OF ed_nrtelefo IN FRAME f_debaut_sms_cadastrar
DO:   
    RUN tecla.

    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            APPLY "ENTRY" TO Btn_D.
            RETURN NO-APPLY.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        ed_nrtelefo:SCREEN-VALUE = "".
    ELSE
    IF  RETURN-VALUE = "OK"  THEN
        RETURN "OK".
    
    /* se nao digitou numeros, despreza */
    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))   OR
        LENGTH(ed_nrtelefo:SCREEN-VALUE) >= 9                     THEN
        RETURN NO-APPLY.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_debaut_sms_cadastrar OCX.Tick
PROCEDURE temporizador.t_debaut_sms_cadastrar.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_debaut_sms_cadastrar.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_debaut_sms_cadastrar 


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

    RUN procedures/obtem_telefone_sms_debaut.p (OUTPUT aux_nrDDD,
                                                OUTPUT aux_nrtelefo,
                                                OUTPUT aux_dsmsgsms,
                                                OUTPUT aux_flgderro).

    IF  NOT aux_flgderro THEN
        DO:
            IF  aux_nrDDD > 0 AND aux_nrtelefo > 0  THEN
                ASSIGN ed_nrDDD:SCREEN-VALUE = STRING(aux_nrDDD)
                       ed_nrtelefo:SCREEN-VALUE = STRING(aux_nrtelefo).                
        END.
    ELSE
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "NOK".
        END.        

    IF (aux_nrDDD = 0 OR aux_nrtelefo = 0)  OR 
        par_idrotina = 2                    THEN
        DO:
            ASSIGN Btn_D:LABEL IN FRAME f_debaut_sms_cadastrar = "INCLUIR".
            DISABLE Btn_G WITH FRAME f_debaut_sms_cadastrar.
        END.
    ELSE
        ASSIGN Btn_D:LABEL IN FRAME f_debaut_sms_cadastrar = "ALTERAR".
        

    /* deixa o mouse transparente */
    FRAME f_debaut_sms_cadastrar:LOAD-MOUSE-POINTER("blank.cur").

    ASSIGN chtemporizador:t_debaut_sms_cadastrar:INTERVAL = glb_nrtempor

           /* Dados do associado */
           ed_cdagectl = glb_cdagectl
           ed_nmrescop = " - " + glb_nmrescop
           ed_nrdconta = glb_nrdconta
           ed_nmextttl = glb_nmtitula[1]
           ed_dsmsgsms:SCREEN-VALUE = aux_dsmsgsms.
           /*ed_dsmsgsms:SCREEN-VALUE = SUBSTRING(aux_dsmsgsms, 1, (INDEX(aux_dsmsgsms, "#") - 1)).*/

    DISPLAY ed_cdagectl  ed_nmrescop
            ed_nrdconta  ed_nmextttl
            WITH FRAME f_debaut_sms_cadastrar.
    
    APPLY "ENTRY" TO ed_nrDDD.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_debaut_sms_cadastrar  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_pagamento_debaut_sms_cadastrar.wrx":U ).
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
ELSE MESSAGE "cartao_pagamento_debaut_sms_cadastrar.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_debaut_sms_cadastrar  _DEFAULT-DISABLE
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
  HIDE FRAME f_debaut_sms_cadastrar.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_debaut_sms_cadastrar  _DEFAULT-ENABLE
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
  DISPLAY ed_dsmsgsms ed_nrDDD ed_nrtelefo ed_cdagectl ed_nmrescop ed_nrdconta 
          ed_nmextttl 
      WITH FRAME f_debaut_sms_cadastrar.
  ENABLE IMAGE-37 IMAGE-40 RECT-133 RECT-134 RECT-135 IMAGE-53 ed_dsmsgsms 
         ed_nrDDD ed_nrtelefo Btn_G Btn_D Btn_H ed_cdagectl ed_nmrescop 
         ed_nrdconta ed_nmextttl 
      WITH FRAME f_debaut_sms_cadastrar.
  {&OPEN-BROWSERS-IN-QUERY-f_debaut_sms_cadastrar}
  VIEW w_debaut_sms_cadastrar.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_debaut_sms_cadastrar 
PROCEDURE tecla :
chtemporizador:t_debaut_sms_cadastrar:INTERVAL = 0.

    IF  KEY-FUNCTION(LASTKEY) = "D"                           AND
        Btn_D:SENSITIVE IN FRAME f_debaut_sms_cadastrar  THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                           AND
        Btn_H:SENSITIVE IN FRAME f_debaut_sms_cadastrar  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "G"                           AND
        Btn_G:SENSITIVE IN FRAME f_debaut_sms_cadastrar  THEN
        APPLY "CHOOSE" TO Btn_G.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_debaut_sms_cadastrar:INTERVAL = glb_nrtempor.
    
    
    IF  RETURN-VALUE = "OK"  THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.    
            RETURN "OK".
        END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

