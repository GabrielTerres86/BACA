&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_cartao_saque_valor
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_cartao_saque_valor 
/* ..............................................................................

Procedure: cartao_saque_valor.w
Objetivo : Tela para saque de outros valores
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
DEFINE VARIABLE aux_contador        AS INT          NO-UNDO.

DEFINE VARIABLE tmp_dsdnotas        AS CHARACTER    NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_cartao_saque_valor

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-18 RECT-19 RECT-63 aux_dsdnotaA ~
aux_dsdnotaB ed_vldsaque aux_dsdnotaC aux_dsdnotaD Btn_H ed_cdagectl ~
ed_nmrescop ed_nrdconta ed_nmextttl 
&Scoped-Define DISPLAYED-OBJECTS aux_dsdnotaA aux_dsdnotaB ed_vldsaque ~
aux_dsdnotaC aux_dsdnotaD ed_cdagectl ed_nmrescop ed_nrdconta ed_nmextttl 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_cartao_saque_valor AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_H 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE VARIABLE aux_dsdnotaA AS CHARACTER FORMAT "X(256)":U INITIAL "R$ 999,99" 
     VIEW-AS FILL-IN 
     SIZE 21 BY 1.19
     BGCOLOR 15 FGCOLOR 1 FONT 11 NO-UNDO.

DEFINE VARIABLE aux_dsdnotaB AS CHARACTER FORMAT "X(256)":U INITIAL "R$ 999,99" 
     VIEW-AS FILL-IN 
     SIZE 21 BY 1.19
     BGCOLOR 15 FGCOLOR 1 FONT 11 NO-UNDO.

DEFINE VARIABLE aux_dsdnotaC AS CHARACTER FORMAT "X(256)":U INITIAL "R$ 999,99" 
     VIEW-AS FILL-IN 
     SIZE 21 BY 1.19
     BGCOLOR 15 FGCOLOR 1 FONT 11 NO-UNDO.

DEFINE VARIABLE aux_dsdnotaD AS CHARACTER FORMAT "X(256)":U INITIAL "R$ 999,99" 
     VIEW-AS FILL-IN 
     SIZE 21 BY 1.19
     BGCOLOR 15 FGCOLOR 1 FONT 11 NO-UNDO.

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

DEFINE VARIABLE ed_vldsaque AS DECIMAL FORMAT "z,zz9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 38 BY 2.14
     BGCOLOR 15 FONT 13 NO-UNDO.

DEFINE RECTANGLE RECT-100
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 2 .

DEFINE RECTANGLE RECT-18
     EDGE-PIXELS 6 GRAPHIC-EDGE  NO-FILL   
     SIZE 98 BY 9.19.

DEFINE RECTANGLE RECT-19
     EDGE-PIXELS 4 GRAPHIC-EDGE  NO-FILL   
     SIZE 40 BY 2.62.

DEFINE RECTANGLE RECT-63
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 100 BY 9.67.

DEFINE RECTANGLE RECT-98
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-99
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .

DEFINE VARIABLE ed_dssaqmax AS CHARACTER FORMAT "X(50)":U 
      VIEW-AS TEXT 
     SIZE 94 BY 1.19
     FGCOLOR 1 FONT 8 NO-UNDO.

DEFINE RECTANGLE RECT-20
     EDGE-PIXELS 6 GRAPHIC-EDGE  NO-FILL   
     SIZE 98 BY 2.86.

DEFINE RECTANGLE RECT-65
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 100 BY 3.33.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_cartao_saque_valor
     aux_dsdnotaA AT ROW 11.67 COL 4.2 COLON-ALIGNED NO-LABEL WIDGET-ID 162 NO-TAB-STOP 
     aux_dsdnotaB AT ROW 13.05 COL 4.2 COLON-ALIGNED NO-LABEL WIDGET-ID 164 NO-TAB-STOP 
     ed_vldsaque AT ROW 13.95 COL 64 COLON-ALIGNED NO-LABEL WIDGET-ID 90
     aux_dsdnotaC AT ROW 14.43 COL 4.2 COLON-ALIGNED NO-LABEL WIDGET-ID 166 NO-TAB-STOP 
     aux_dsdnotaD AT ROW 15.76 COL 4.2 COLON-ALIGNED NO-LABEL WIDGET-ID 168 NO-TAB-STOP 
     Btn_H AT ROW 24.1 COL 96 WIDGET-ID 74
     ed_cdagectl AT ROW 6 COL 46 COLON-ALIGNED NO-LABEL WIDGET-ID 238 NO-TAB-STOP 
     ed_nmrescop AT ROW 6 COL 62 COLON-ALIGNED NO-LABEL WIDGET-ID 242 NO-TAB-STOP 
     ed_nrdconta AT ROW 7.43 COL 46 COLON-ALIGNED NO-LABEL WIDGET-ID 244 NO-TAB-STOP 
     ed_nmextttl AT ROW 7.43 COL 72 COLON-ALIGNED NO-LABEL WIDGET-ID 240 NO-TAB-STOP 
     " Notas Disponíveis" VIEW-AS TEXT
          SIZE 23 BY 1.1 AT ROW 10.43 COL 5.6 WIDGET-ID 204
          FGCOLOR 1 FONT 6
     "Conta/Titular:" VIEW-AS TEXT
          SIZE 29 BY 1.19 AT ROW 7.43 COL 17 WIDGET-ID 140
          FONT 8
     "DIGITE O VALOR DESEJADO" VIEW-AS TEXT
          SIZE 66 BY 1.91 AT ROW 11 COL 49 WIDGET-ID 206
          FGCOLOR 1 FONT 8
     "Cooperativa:" VIEW-AS TEXT
          SIZE 28 BY 1.19 AT ROW 6 COL 18.6 WIDGET-ID 134
          FONT 8
     "TECLE ENTRA PARA CONTINUAR" VIEW-AS TEXT
          SIZE 78 BY 1.43 AT ROW 16.95 COL 42 WIDGET-ID 198
          FGCOLOR 1 FONT 8
     "SAQUE - OUTRO VALOR" VIEW-AS TEXT
          SIZE 109 BY 3.33 AT ROW 1.48 COL 28 WIDGET-ID 96
          FGCOLOR 1 FONT 10
     "R$" VIEW-AS TEXT
          SIZE 12 BY 2.62 AT ROW 13.62 COL 52 WIDGET-ID 202
          FGCOLOR 0 FONT 10
     RECT-18 AT ROW 10.05 COL 32 WIDGET-ID 176
     RECT-19 AT ROW 13.62 COL 65 WIDGET-ID 178
     RECT-63 AT ROW 9.81 COL 31 WIDGET-ID 180
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 116
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 160 BY 28.57 WIDGET-ID 100.

DEFINE FRAME f_limite
     ed_dssaqmax AT ROW 2.19 COL 4 NO-LABEL WIDGET-ID 194
     RECT-65 AT ROW 1 COL 1 WIDGET-ID 184
     RECT-20 AT ROW 1.24 COL 2.2 WIDGET-ID 176
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 31 ROW 19.67
         SIZE 100 BY 3.71 WIDGET-ID 200.


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
  CREATE WINDOW w_cartao_saque_valor ASSIGN
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
ASSIGN w_cartao_saque_valor = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_cartao_saque_valor
  VISIBLE,,RUN-PERSISTENT                                               */
/* REPARENT FRAME */
ASSIGN FRAME f_limite:FRAME = FRAME f_cartao_saque_valor:HANDLE.

/* SETTINGS FOR FRAME f_cartao_saque_valor
   FRAME-NAME                                                           */
ASSIGN 
       aux_dsdnotaA:READ-ONLY IN FRAME f_cartao_saque_valor        = TRUE.

ASSIGN 
       aux_dsdnotaB:READ-ONLY IN FRAME f_cartao_saque_valor        = TRUE.

ASSIGN 
       aux_dsdnotaC:READ-ONLY IN FRAME f_cartao_saque_valor        = TRUE.

ASSIGN 
       aux_dsdnotaD:READ-ONLY IN FRAME f_cartao_saque_valor        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_cartao_saque_valor
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_cartao_saque_valor
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_cartao_saque_valor
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME f_limite
   NOT-VISIBLE                                                          */
ASSIGN 
       FRAME f_limite:HIDDEN           = TRUE
       FRAME f_limite:SENSITIVE        = FALSE.

/* SETTINGS FOR FILL-IN ed_dssaqmax IN FRAME f_limite
   ALIGN-L                                                              */
ASSIGN 
       ed_dssaqmax:HIDDEN IN FRAME f_limite           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_cartao_saque_valor:HANDLE
       ROW             = 1.95
       COLUMN          = 7
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_saque_valor */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_cartao_saque_valor
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_saque_valor w_cartao_saque_valor
ON END-ERROR OF w_cartao_saque_valor
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_saque_valor w_cartao_saque_valor
ON WINDOW-CLOSE OF w_cartao_saque_valor
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_saque_valor
ON CHOOSE OF Btn_H IN FRAME f_cartao_saque_valor /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_vldsaque
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_vldsaque w_cartao_saque_valor
ON ANY-KEY OF ed_vldsaque IN FRAME f_cartao_saque_valor
DO:
    chtemporizador:t_cartao_saque_valor:INTERVAL = 0.

    IF  KEY-FUNCTION(LASTKEY) = "H"  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            RUN efetua_saque (INPUT DECIMAL(ed_vldsaque:SCREEN-VALUE)).
            
            IF  RETURN-VALUE = "OK"  THEN
                DO:
                    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
                    RETURN "OK".
                END.
            ELSE
                APPLY "ENTRY" TO ed_vldsaque.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        ed_vldsaque:SCREEN-VALUE = "".

    chtemporizador:t_cartao_saque_valor:INTERVAL = glb_nrtempor.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_cartao_saque_valor OCX.Tick
PROCEDURE temporizador.t_cartao_saque_valor.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_cartao_saque_valor.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_cartao_saque_valor 


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
    FRAME f_cartao_saque_valor:LOAD-MOUSE-POINTER("blank.cur").
    FRAME f_limite:LOAD-MOUSE-POINTER("blank.cur").

    ASSIGN chtemporizador:t_cartao_saque_valor:INTERVAL = glb_nrtempor
                   
           /* Dados do associado */
           ed_cdagectl = glb_cdagectl
           ed_nmrescop = " - " + glb_nmrescop
           ed_nrdconta = glb_nrdconta
           ed_nmextttl = glb_nmtitula[1].

    DISPLAY ed_cdagectl  ed_nmrescop
            ed_nrdconta  ed_nmextttl
            WITH FRAME f_cartao_saque_valor.

    RUN valores_disponiveis.

    /* coloca o foco no botao H */
    APPLY "ENTRY" TO ed_vldsaque.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_cartao_saque_valor  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_saque_valor.wrx":U ).
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
ELSE MESSAGE "cartao_saque_valor.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_cartao_saque_valor  _DEFAULT-DISABLE
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
  HIDE FRAME f_cartao_saque_valor.
  HIDE FRAME f_limite.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE efetua_saque w_cartao_saque_valor 
PROCEDURE efetua_saque :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE INPUT PARAM par_vldsaque     AS DECIMAL      NO-UNDO.

    DEFINE VARIABLE    aux_flgcompr     AS LOGICAL      NO-UNDO.
    DEFINE VARIABLE    aux_tximpres     AS CHAR         NO-UNDO.

    /* ---------- */
    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).
    
    IF  aux_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.


    /* nao pode efetuar saque zerado */
    IF  par_vldsaque = 0  THEN
        DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "    Atenção!",
                            INPUT "",
                            INPUT "",
                            INPUT "O valor não pode ser ZERO.",
                            INPUT "",
                            INPUT "").

            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.
            RETURN "NOK".
        END.


    /* verifica se o pagamento eh possivel */
    RUN procedures/dispensa_notas.p ( INPUT par_vldsaque,
                                      INPUT NO, /* nao pagar */
                                      INPUT "",
                                     OUTPUT aux_flgderro).

    IF  aux_flgderro  THEN
        RETURN "NOK".


    /* verifica se pode sacar */
    RUN procedures/verifica_saque.p ( INPUT par_vldsaque,
                                     OUTPUT ed_dssaqmax,
                                     OUTPUT aux_flgcompr,
                                     OUTPUT aux_flgderro).

    IF  aux_flgderro  THEN
        DO:
            IF  ed_dssaqmax <> ""  THEN
                DO:
                    /* mostra o limite */
                    VIEW FRAME f_limite.
                    DISPLAY ed_dssaqmax WITH FRAME f_limite.
                END.

            RETURN "NOK".
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

            RUN procedures/efetua_saque.p (INPUT  par_vldsaque,
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_cartao_saque_valor  _DEFAULT-ENABLE
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
  DISPLAY aux_dsdnotaA aux_dsdnotaB ed_vldsaque aux_dsdnotaC aux_dsdnotaD 
          ed_cdagectl ed_nmrescop ed_nrdconta ed_nmextttl 
      WITH FRAME f_cartao_saque_valor.
  ENABLE RECT-18 RECT-19 RECT-63 aux_dsdnotaA aux_dsdnotaB ed_vldsaque 
         aux_dsdnotaC aux_dsdnotaD Btn_H ed_cdagectl ed_nmrescop ed_nrdconta 
         ed_nmextttl 
      WITH FRAME f_cartao_saque_valor.
  {&OPEN-BROWSERS-IN-QUERY-f_cartao_saque_valor}
  DISPLAY ed_dssaqmax 
      WITH FRAME f_limite.
  ENABLE RECT-65 RECT-20 ed_dssaqmax 
      WITH FRAME f_limite.
  {&OPEN-BROWSERS-IN-QUERY-f_limite}
  FRAME f_limite:SENSITIVE = NO.
  VIEW w_cartao_saque_valor.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE valores_disponiveis w_cartao_saque_valor 
PROCEDURE valores_disponiveis :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

/* K7A */
IF  glb_vlnotK7A > 0  AND
    glb_qtnotK7A > 0  AND
    glb_cassetes[1]   THEN
    aux_dsdnotaA = "R$ " + STRING(glb_vlnotK7A,"zz9.99").

/* K7B */
IF  glb_vlnotK7B > 0  AND
    glb_qtnotK7B > 0  AND
    glb_cassetes[2]   THEN
    aux_dsdnotaB = "R$ " + STRING(glb_vlnotK7B,"zz9.99").

/* K7C */
IF  glb_vlnotK7C > 0  AND
    glb_qtnotK7C > 0  AND
    glb_cassetes[3]   THEN
    aux_dsdnotaC = "R$ " + STRING(glb_vlnotK7C,"zz9.99").

/* K7D */
IF  glb_vlnotK7D > 0  AND
    glb_qtnotK7D > 0  AND
    glb_cassetes[4]   THEN
    aux_dsdnotaD = "R$ " + STRING(glb_vlnotK7D,"zz9.99").

/* ordena por valor */
DO  aux_contador = 1 TO 4:

    IF  aux_dsdnotaA >= aux_dsdnotaB  THEN
        IF  aux_dsdnotaA = aux_dsdnotaB  THEN
            aux_dsdnotaB = "R$ 999,99".
        ELSE
            ASSIGN tmp_dsdnotas = aux_dsdnotaA
                   aux_dsdnotaA = aux_dsdnotaB
                   aux_dsdnotaB = tmp_dsdnotas.

    IF  aux_dsdnotaB >= aux_dsdnotaC  THEN
        IF  aux_dsdnotaB = aux_dsdnotaC  THEN
            aux_dsdnotaC = "R$ 999,99".
        ELSE
            ASSIGN tmp_dsdnotas = aux_dsdnotaB
                   aux_dsdnotaB = aux_dsdnotaC
                   aux_dsdnotaC = tmp_dsdnotas.

    IF  aux_dsdnotaC >= aux_dsdnotaD  THEN
        IF  aux_dsdnotaC = aux_dsdnotaD  THEN
            aux_dsdnotaD = "R$ 999,99".
        ELSE
            ASSIGN tmp_dsdnotas = aux_dsdnotaC
                   aux_dsdnotaC = aux_dsdnotaD
                   aux_dsdnotaD = tmp_dsdnotas.
END.

DISPLAY aux_dsdnotaA    aux_dsdnotaB
        aux_dsdnotaC    aux_dsdnotaD
        WITH FRAME f_cartao_saque_valor.

/* esconde os campos das notas nao disponiveis */
IF  aux_dsdnotaA = "R$ 999,99"  THEN
    HIDE aux_dsdnotaA IN FRAME f_cartao_saque_valor.

IF  aux_dsdnotaB = "R$ 999,99"  THEN
    HIDE aux_dsdnotaB IN FRAME f_cartao_saque_valor.

IF  aux_dsdnotaC = "R$ 999,99"  THEN
    HIDE aux_dsdnotaC IN FRAME f_cartao_saque_valor.

IF  aux_dsdnotaD = "R$ 999,99"  THEN
    HIDE aux_dsdnotaD IN FRAME f_cartao_saque_valor.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

