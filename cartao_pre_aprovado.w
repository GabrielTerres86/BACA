&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_pre_aprovado
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_pre_aprovado 
/* ...........................................................................

Procedure: credito_pre_aprovado.w
Objetivo : Tela para apresentar o menu do Pre-Aprovado
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

DEF TEMP-TABLE tt-dados-cpa NO-UNDO
    FIELD vldiscrd AS DECI
    FIELD txmensal AS DECI.

EMPTY TEMP-TABLE tt-dados-cpa.

DEFINE INPUT-OUTPUT PARAMETER par_flgretur AS CHAR                NO-UNDO.

DEFINE VARIABLE aux_flgderro AS LOGICAL                           NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_pre_aprovado

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-40 IMAGE-37 RECT-128 RECT-127 ~
ed_vlemprst ed_diapagto Btn_D Btn_H ed_vllimdis ed_txmensal 
&Scoped-Define DISPLAYED-OBJECTS ed_vlemprst ed_diapagto ed_vllimdis ~
ed_txmensal 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_pre_aprovado AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_D 
     LABEL "CALCULAR" 
     SIZE 53 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_H 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_diapagto AS INTEGER FORMAT "99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 41 BY 2.14
     FONT 15 NO-UNDO.

DEFINE VARIABLE ed_txmensal AS DECIMAL FORMAT "zz,zz9.99":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 41 BY 1.95
     FONT 15 NO-UNDO.

DEFINE VARIABLE ed_vlemprst AS DECIMAL FORMAT "zz,zz9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 41 BY 2.14
     FONT 15 NO-UNDO.

DEFINE VARIABLE ed_vllimdis AS DECIMAL FORMAT "zz,zz9.99":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 41 BY 1.95
     FONT 15 NO-UNDO.

DEFINE IMAGE IMAGE-37
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
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

DEFINE RECTANGLE RECT-127
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 43 BY 2.62.

DEFINE RECTANGLE RECT-128
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 43 BY 2.62.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_pre_aprovado
     ed_vlemprst AT ROW 13.81 COL 84 COLON-ALIGNED NO-LABEL WIDGET-ID 158
     ed_diapagto AT ROW 17.67 COL 84 COLON-ALIGNED NO-LABEL WIDGET-ID 176
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 66
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 74
     ed_vllimdis AT ROW 8 COL 84 COLON-ALIGNED NO-LABEL WIDGET-ID 258 NO-TAB-STOP 
     ed_txmensal AT ROW 10.86 COL 84 COLON-ALIGNED NO-LABEL WIDGET-ID 256 NO-TAB-STOP 
     "automática em sua conta corrente)." VIEW-AS TEXT
          SIZE 72 BY .71 AT ROW 21 COL 11.2 WIDGET-ID 252
          FONT 0
     "Valor da Operação:" VIEW-AS TEXT
          SIZE 50.2 BY 1.19 AT ROW 14.38 COL 33 WIDGET-ID 126
          FONT 20
     "PRÉ-APROVADO" VIEW-AS TEXT
          SIZE 76.4 BY 2.71 AT ROW 2.19 COL 43 WIDGET-ID 92
          FGCOLOR 1 FONT 10
     "Taxa Mensal:" VIEW-AS TEXT
          SIZE 33.2 BY 1.19 AT ROW 11.24 COL 50 WIDGET-ID 236
          FONT 20
     "O débito das parcelas ocorrerá mensalmente de forma" VIEW-AS TEXT
          SIZE 72 BY .71 AT ROW 20.05 COL 11.2 WIDGET-ID 250
          FONT 0
     "Dia do Vencimento:" VIEW-AS TEXT
          SIZE 50.2 BY 1.19 AT ROW 17.91 COL 33 WIDGET-ID 128
          FONT 20
     "(Informe a melhor data para vencimento das parcelas." VIEW-AS TEXT
          SIZE 72 BY .71 AT ROW 19.1 COL 11.2 WIDGET-ID 248
          FONT 0
     "Limite Disponível:" VIEW-AS TEXT
          SIZE 50.2 BY 1.19 AT ROW 8.38 COL 33 WIDGET-ID 234
          FONT 20
     "(Informe o valor que deseja contratar)" VIEW-AS TEXT
          SIZE 53.2 BY .71 AT ROW 15.52 COL 30 WIDGET-ID 246
          FONT 0
     IMAGE-40 AT ROW 24.24 COL 156 WIDGET-ID 154
     RECT-101 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-102 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-103 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-37 AT ROW 24.24 COL 1 WIDGET-ID 148
     RECT-128 AT ROW 13.62 COL 85 WIDGET-ID 160
     RECT-127 AT ROW 17.43 COL 85 WIDGET-ID 178
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
  CREATE WINDOW w_pre_aprovado ASSIGN
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
ASSIGN w_pre_aprovado = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_pre_aprovado
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_pre_aprovado
   FRAME-NAME                                                           */
/* SETTINGS FOR RECTANGLE RECT-101 IN FRAME f_pre_aprovado
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-102 IN FRAME f_pre_aprovado
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-103 IN FRAME f_pre_aprovado
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_pre_aprovado:HANDLE
       ROW             = 1.71
       COLUMN          = 7
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_pre_aprovado */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_pre_aprovado
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_pre_aprovado w_pre_aprovado
ON END-ERROR OF w_pre_aprovado
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_pre_aprovado w_pre_aprovado
ON WINDOW-CLOSE OF w_pre_aprovado
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_pre_aprovado
ON ANY-KEY OF Btn_D IN FRAME f_pre_aprovado /* CALCULAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_pre_aprovado
ON CHOOSE OF Btn_D IN FRAME f_pre_aprovado /* CALCULAR */
DO:
    IF DECI(ed_vlemprst:SCREEN-VALUE) <= 0 THEN
       DO:
           RUN mensagem.w (INPUT NO,
                           INPUT "    ATENÇÃO  ",
                           INPUT "",
                           INPUT "",
                           INPUT "Informe o campo Valor da Operação.",
                           INPUT "",
                           INPUT "").

           PAUSE 3 NO-MESSAGE.
           h_mensagem:HIDDEN = YES.

           APPLY "ENTRY" TO ed_vlemprst.
           RETURN NO-APPLY.
       END.
    
    IF INT(ed_diapagto:SCREEN-VALUE) <= 0 THEN
       DO:
           RUN mensagem.w (INPUT NO,
                           INPUT "    ATENÇÃO  ",
                           INPUT "",
                           INPUT "",
                           INPUT "Informe o campo Dia do Vencimento.",
                           INPUT "",
                           INPUT "").

           PAUSE 3 NO-MESSAGE.
           h_mensagem:HIDDEN = YES.

           APPLY "ENTRY" TO ed_diapagto.
           RETURN NO-APPLY.
       END.

    /* Valida os dados informados em Tela */
    RUN procedures/valida_dados_pre_aprovado.p(INPUT DECI(ed_vlemprst:SCREEN-VALUE),
                                               INPUT INTE(ed_diapagto:SCREEN-VALUE),
                                               OUTPUT aux_flgderro).

    IF aux_flgderro THEN
       DO:
           APPLY "ENTRY" TO ed_vlemprst.
           RETURN NO-APPLY.
       END.
    ELSE
       DO: 
           FIND FIRST tt-dados-cpa NO-LOCK NO-ERROR.
           /* Passa os valores para a tela das parcelas do pre-aprovado */
           RUN cartao_pre_aprovado_parcelas.w (INPUT tt-dados-cpa.vldiscrd,
                                               INPUT tt-dados-cpa.txmensal,
                                               INPUT ed_vlemprst:SCREEN-VALUE,
                                               INPUT ed_diapagto:SCREEN-VALUE,
                                               INPUT-OUTPUT par_flgretur).
           
           IF par_flgretur = "OK"  THEN
              DO:
                  APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                  RETURN "OK".
              END.
           ELSE
              DO:
                  /* joga o frame frente */
                  FRAME f_pre_aprovado:MOVE-TO-TOP().
                  APPLY "ENTRY" TO ed_vlemprst.
                  RETURN NO-APPLY.
              END.
       END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_pre_aprovado
ON ANY-KEY OF Btn_H IN FRAME f_pre_aprovado /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_pre_aprovado
ON CHOOSE OF Btn_H IN FRAME f_pre_aprovado /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_diapagto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_diapagto w_pre_aprovado
ON ANY-KEY OF ed_diapagto IN FRAME f_pre_aprovado
DO:
    RUN tecla.

    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            ed_diapagto:SCREEN-VALUE = "".
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


&Scoped-define SELF-NAME ed_vlemprst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_vlemprst w_pre_aprovado
ON ANY-KEY OF ed_vlemprst IN FRAME f_pre_aprovado
DO:
    RUN tecla.
        
    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            APPLY "ENTRY" TO ed_diapagto.
            RETURN NO-APPLY.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            ed_vlemprst:SCREEN-VALUE = "".
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
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_pre_aprovado OCX.Tick
PROCEDURE temporizador.t_pre_aprovado.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_pre_aprovado.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_pre_aprovado 


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

    RUN mensagem.w (INPUT NO,
                    INPUT "   Aguarde...",
                    INPUT "",
                    INPUT "",
                    INPUT "Carregando...",
                    INPUT "",
                    INPUT "").
    PAUSE 1 NO-MESSAGE.

    /* Busca o saldo do credito pre-aprovado */
    RUN procedures/busca_saldo_pre_aprovado.p (OUTPUT aux_flgderro,
                                               OUTPUT TABLE tt-dados-cpa).

    h_mensagem:HIDDEN = YES.

    RUN enable_UI.

    /* deixa o mouse transparente */
    FRAME f_pre_aprovado:LOAD-MOUSE-POINTER("blank.cur").
    ASSIGN chtemporizador:t_pre_aprovado:INTERVAL = glb_nrtempor.

    /* Busca os valores do pre-aprovado */
    FIND FIRST tt-dados-cpa NO-LOCK NO-ERROR.
    IF AVAIL tt-dados-cpa THEN
       DO:
           ASSIGN ed_vllimdis = tt-dados-cpa.vldiscrd
                  ed_txmensal = tt-dados-cpa.txmensal.
       END.

    /* Mostra os valores do pre-aprovado */
    DISPLAY ed_vllimdis
            ed_txmensal
            WITH FRAME f_pre_aprovado.

    /* coloca o foco no campo Valor a Contratar */
    APPLY "ENTRY" TO ed_vlemprst.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_pre_aprovado  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_pre_aprovado.wrx":U ).
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
ELSE MESSAGE "cartao_pre_aprovado.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_pre_aprovado  _DEFAULT-DISABLE
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
  HIDE FRAME f_pre_aprovado.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_pre_aprovado  _DEFAULT-ENABLE
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
  DISPLAY ed_vlemprst ed_diapagto ed_vllimdis ed_txmensal 
      WITH FRAME f_pre_aprovado.
  ENABLE IMAGE-40 IMAGE-37 RECT-128 RECT-127 ed_vlemprst ed_diapagto Btn_D 
         Btn_H ed_vllimdis ed_txmensal 
      WITH FRAME f_pre_aprovado.
  {&OPEN-BROWSERS-IN-QUERY-f_pre_aprovado}
  VIEW w_pre_aprovado.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_pre_aprovado 
PROCEDURE tecla :
chtemporizador:t_pre_aprovado:INTERVAL = 0.

    IF  KEY-FUNCTION(LASTKEY) = "D"             AND
        Btn_D:SENSITIVE IN FRAME f_pre_aprovado THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"             AND
        Btn_H:SENSITIVE IN FRAME f_pre_aprovado THEN
        APPLY "CHOOSE" TO Btn_H.
    
    chtemporizador:t_pre_aprovado:INTERVAL = glb_nrtempor.

    IF NOT CAN-DO("D,H",KEY-FUNCTION(LASTKEY)) THEN
       RETURN NO-APPLY.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

