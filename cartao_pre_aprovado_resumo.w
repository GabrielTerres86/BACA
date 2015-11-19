&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_pre_aprovado_resumo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_pre_aprovado_resumo 
/* ...........................................................................

Procedure: credito_pre_aprovado_resumo.w
Objetivo : Tela para apresentar o resumo do pre-aprovado
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

DEFINE INPUT        PARAMETER par_vldiscrd AS DECI                   NO-UNDO.
DEFINE INPUT        PARAMETER par_txmensal AS DECI                   NO-UNDO.
DEFINE INPUT        PARAMETER par_vlemprst AS DECI                   NO-UNDO.
DEFINE INPUT        PARAMETER par_nrparepr AS INTE                   NO-UNDO.
DEFINE INPUT        PARAMETER par_vlparepr AS DECI                   NO-UNDO.
DEFINE INPUT        PARAMETER par_dtvencto AS DATE                   NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER par_flgretur AS CHAR                   NO-UNDO.

DEFINE VARIABLE aux_flgderro    AS LOGICAL                           NO-UNDO.
DEFINE VARIABLE aux_vlrtarif    AS DECIMAL  INIT 0                   NO-UNDO.
DEFINE VARIABLE aux_percetop    AS DECIMAL  INIT 0                   NO-UNDO.
DEFINE VARIABLE aux_vltaxiof    AS DECIMAL  INIT 0                   NO-UNDO.
DEFINE VARIABLE aux_vltariof    AS DECIMAL  INIT 0                   NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_pre_aprovado_resumo

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-40 IMAGE-37 Btn_D Btn_H ed_vlemprst ~
ed_nrparepr ed_vlparepr ed_dtvencto ed_vlrtarif ed_txmensal ed_percetop ~
ed_vltariof 
&Scoped-Define DISPLAYED-OBJECTS ed_vlemprst ed_nrparepr ed_vlparepr ~
ed_dtvencto ed_vlrtarif ed_txmensal ed_percetop ed_vltariof 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_pre_aprovado_resumo AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_D 
     LABEL "CONFIRMAR" 
     SIZE 53 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_H 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_dtvencto AS DATE FORMAT "99/99/9999":U 
      VIEW-AS TEXT 
     SIZE 30 BY 1.19
     FONT 20 NO-UNDO.

DEFINE VARIABLE ed_nrparepr AS INTEGER FORMAT "zzzzzzzz99":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 30 BY 1.19
     FONT 20 NO-UNDO.

DEFINE VARIABLE ed_percetop AS DECIMAL FORMAT "zzz,zz9.99":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 30 BY 1.19
     FONT 20 NO-UNDO.

DEFINE VARIABLE ed_txmensal AS DECIMAL FORMAT "zzz,zz9.99":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 30 BY 1.19
     FONT 20 NO-UNDO.

DEFINE VARIABLE ed_vlemprst AS DECIMAL FORMAT "zzz,zz9.99":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 30 BY 1.19
     FONT 20 NO-UNDO.

DEFINE VARIABLE ed_vlparepr AS DECIMAL FORMAT "zzz,zz9.99":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 30 BY 1.19
     FONT 20 NO-UNDO.

DEFINE VARIABLE ed_vlrtarif AS DECIMAL FORMAT "zzz,zz9.99":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 30 BY 1.19
     FONT 20 NO-UNDO.

DEFINE VARIABLE ed_vltariof AS DECIMAL FORMAT "zzz,zz9.99":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 30 BY 1.19
     FONT 20 NO-UNDO.

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


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_pre_aprovado_resumo
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 66
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 74
     ed_vlemprst AT ROW 7.81 COL 101 COLON-ALIGNED NO-LABEL WIDGET-ID 258 NO-TAB-STOP 
     ed_nrparepr AT ROW 9.62 COL 101 COLON-ALIGNED NO-LABEL WIDGET-ID 280 NO-TAB-STOP 
     ed_vlparepr AT ROW 11.43 COL 101 COLON-ALIGNED NO-LABEL WIDGET-ID 272 NO-TAB-STOP 
     ed_dtvencto AT ROW 13.24 COL 101 COLON-ALIGNED NO-LABEL WIDGET-ID 282 NO-TAB-STOP 
     ed_vlrtarif AT ROW 15.05 COL 103 NO-LABEL WIDGET-ID 274 NO-TAB-STOP 
     ed_txmensal AT ROW 16.86 COL 103 NO-LABEL WIDGET-ID 276 NO-TAB-STOP 
     ed_percetop AT ROW 18.67 COL 101 COLON-ALIGNED NO-LABEL WIDGET-ID 278 NO-TAB-STOP 
     ed_vltariof AT ROW 20.52 COL 101 COLON-ALIGNED NO-LABEL WIDGET-ID 284 NO-TAB-STOP 
     "Taxa:" VIEW-AS TEXT
          SIZE 13.4 BY 1.19 AT ROW 16.86 COL 79.6 WIDGET-ID 268
          FONT 20
     "Tarifa: R$" VIEW-AS TEXT
          SIZE 28 BY 1.19 AT ROW 15.05 COL 74 WIDGET-ID 266
          FONT 20
     "Número de parcelas:" VIEW-AS TEXT
          SIZE 52.8 BY 1.19 AT ROW 9.62 COL 40.2 WIDGET-ID 260
          FONT 20
     "% a.m." VIEW-AS TEXT
          SIZE 17 BY 1.38 AT ROW 16.86 COL 133 WIDGET-ID 290
          FONT 20
     "% a.a." VIEW-AS TEXT
          SIZE 16 BY 1.19 AT ROW 18.67 COL 133 WIDGET-ID 288
          FONT 20
     "CET:" VIEW-AS TEXT
          SIZE 10.6 BY 1.19 AT ROW 18.67 COL 82.4 WIDGET-ID 270
          FONT 20
     "PRÉ-APROVADO" VIEW-AS TEXT
          SIZE 76.4 BY 2.95 AT ROW 1.95 COL 43 WIDGET-ID 92
          FGCOLOR 1 FONT 10
     "IOF: R$" VIEW-AS TEXT
          SIZE 19.6 BY 1.19 AT ROW 20.52 COL 82.4 WIDGET-ID 286
          FONT 20
     "Valor da parcela: R$" VIEW-AS TEXT
          SIZE 56 BY 1.19 AT ROW 11.43 COL 46 WIDGET-ID 262
          FONT 20
     "Vencimento da 1ª parcela:" VIEW-AS TEXT
          SIZE 69.4 BY 1.19 AT ROW 13.24 COL 23.6 WIDGET-ID 264
          FONT 20
     "Valor Financiado: R$" VIEW-AS TEXT
          SIZE 56 BY 1.19 AT ROW 7.81 COL 46 WIDGET-ID 234
          FONT 20
     IMAGE-40 AT ROW 24.24 COL 156 WIDGET-ID 154
     RECT-101 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-102 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-103 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-37 AT ROW 24.24 COL 1 WIDGET-ID 148
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
  CREATE WINDOW w_pre_aprovado_resumo ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 26.76
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
ASSIGN w_pre_aprovado_resumo = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_pre_aprovado_resumo
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_pre_aprovado_resumo
   FRAME-NAME                                                           */
/* SETTINGS FOR FILL-IN ed_txmensal IN FRAME f_pre_aprovado_resumo
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN ed_vlrtarif IN FRAME f_pre_aprovado_resumo
   ALIGN-L                                                              */
/* SETTINGS FOR RECTANGLE RECT-101 IN FRAME f_pre_aprovado_resumo
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-102 IN FRAME f_pre_aprovado_resumo
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-103 IN FRAME f_pre_aprovado_resumo
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_pre_aprovado_resumo:HANDLE
       ROW             = 1.71
       COLUMN          = 7
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_pre_aprovado_resumo */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_pre_aprovado_resumo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_pre_aprovado_resumo w_pre_aprovado_resumo
ON END-ERROR OF w_pre_aprovado_resumo
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_pre_aprovado_resumo w_pre_aprovado_resumo
ON WINDOW-CLOSE OF w_pre_aprovado_resumo
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_pre_aprovado_resumo
ON ANY-KEY OF Btn_D IN FRAME f_pre_aprovado_resumo /* CONFIRMAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_pre_aprovado_resumo
ON CHOOSE OF Btn_D IN FRAME f_pre_aprovado_resumo /* CONFIRMAR */
DO:
  RUN cartao_pre_aprovado_extrato.w (INPUT par_vlemprst,
                                     INPUT par_txmensal,
                                     INPUT par_nrparepr,
                                     INPUT par_vlparepr,
                                     INPUT aux_percetop,
                                     INPUT aux_vlrtarif,
                                     INPUT par_dtvencto,
                                     INPUT aux_vltaxiof,
                                     INPUT aux_vltariof,
                                     INPUT-OUTPUT par_flgretur).

  IF par_flgretur = "OK"  THEN
     DO:
         APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
         RETURN "OK".
     END.
  ELSE
     DO:
         /* joga o frame frente */
         FRAME f_pre_aprovado_resumo:MOVE-TO-TOP().
         APPLY "ENTRY" TO Btn_H.
         RETURN NO-APPLY.
     END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_pre_aprovado_resumo
ON ANY-KEY OF Btn_H IN FRAME f_pre_aprovado_resumo /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_pre_aprovado_resumo
ON CHOOSE OF Btn_H IN FRAME f_pre_aprovado_resumo /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_pre_aprovado_resumo OCX.Tick
PROCEDURE temporizador.t_pre_aprovado_resumo.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_pre_aprovado_resumo.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_pre_aprovado_resumo 


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

    /* Busca as taxas do credito pre-aprovado */
    RUN procedures/obtem_taxas_pre_aprovado.p (INPUT par_vlemprst,
                                               INPUT par_vlparepr,
                                               INPUT par_nrparepr,
                                               INPUT par_dtvencto,
                                               OUTPUT aux_vlrtarif,
                                               OUTPUT aux_percetop,
                                               OUTPUT aux_vltaxiof,
                                               OUTPUT aux_vltariof,
                                               OUTPUT aux_flgderro).

    RUN enable_UI.

    IF NOT aux_flgderro THEN
       DO:
           /* Mostra os valores do pre-aprovado */
           ASSIGN ed_vlemprst:SCREEN-VALUE = STRING(par_vlemprst)
                  ed_nrparepr:SCREEN-VALUE = STRING(par_nrparepr)
                  ed_vlparepr:SCREEN-VALUE = STRING(par_vlparepr)
                  ed_dtvencto:SCREEN-VALUE = STRING(par_dtvencto)
                  ed_txmensal:SCREEN-VALUE = STRING(par_txmensal)
                  ed_vlrtarif:SCREEN-VALUE = STRING(aux_vlrtarif)
                  ed_percetop:SCREEN-VALUE = STRING(aux_percetop)
                  ed_vltariof:SCREEN-VALUE = STRING(aux_vltariof).
       END.

    /* deixa o mouse transparente */
    FRAME f_pre_aprovado_resumo:LOAD-MOUSE-POINTER("blank.cur").
    chtemporizador:t_pre_aprovado_resumo:INTERVAL = glb_nrtempor.

    /* coloca o foco no botao H */
    APPLY "ENTRY" TO Btn_H.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_pre_aprovado_resumo  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_pre_aprovado_resumo.wrx":U ).
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
ELSE MESSAGE "cartao_pre_aprovado_resumo.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_pre_aprovado_resumo  _DEFAULT-DISABLE
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
  HIDE FRAME f_pre_aprovado_resumo.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_pre_aprovado_resumo  _DEFAULT-ENABLE
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
  DISPLAY ed_vlemprst ed_nrparepr ed_vlparepr ed_dtvencto ed_vlrtarif 
          ed_txmensal ed_percetop ed_vltariof 
      WITH FRAME f_pre_aprovado_resumo.
  ENABLE IMAGE-40 IMAGE-37 Btn_D Btn_H ed_vlemprst ed_nrparepr ed_vlparepr 
         ed_dtvencto ed_vlrtarif ed_txmensal ed_percetop ed_vltariof 
      WITH FRAME f_pre_aprovado_resumo.
  {&OPEN-BROWSERS-IN-QUERY-f_pre_aprovado_resumo}
  VIEW w_pre_aprovado_resumo.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_pre_aprovado_resumo 
PROCEDURE tecla :
chtemporizador:t_pre_aprovado_resumo:INTERVAL = 0.

    IF  KEY-FUNCTION(LASTKEY) = "D"                     AND
        Btn_D:SENSITIVE IN FRAME f_pre_aprovado_resumo THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                     AND
        Btn_H:SENSITIVE IN FRAME f_pre_aprovado_resumo THEN
        APPLY "CHOOSE" TO Btn_H.

    chtemporizador:t_pre_aprovado_resumo:INTERVAL = glb_nrtempor.

    IF NOT CAN-DO("D,H",KEY-FUNCTION(LASTKEY)) THEN
       RETURN NO-APPLY.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

