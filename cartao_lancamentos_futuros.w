&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_cartao_extrato_meses
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_cartao_extrato_meses 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 

------------------------------------------------------------------------*/
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
DEFINE VARIABLE aux_vltarifa        AS DECIMAL      NO-UNDO.
DEFINE VARIABLE aux_inisenta        AS INTEGER      NO-UNDO.
DEFINE VARIABLE aux_dtextrat        AS DATE         NO-UNDO.
DEFINE VARIABLE aux_msextrat        AS INTEGER      NO-UNDO.
DEFINE VARIABLE aux_nomedmes        AS CHAR
                                    EXTENT 12
                                    INIT ["JANEIRO", "FEVEREIRO", "MARÇO",
                                          "ABRIL"  , "MAIO"     , "JUNHO",
                                          "JULHO"  , "AGOSTO"   , "SETEMBRO",
                                          "OUTUBRO", "NOVEMBRO" , "DEZEMBRO"]
                                                    NO-UNDO.

DEFINE VARIABLE tmp_dtiniext        AS DATE         NO-UNDO.
DEFINE VARIABLE tmp_dtfimext        AS DATE         NO-UNDO.
DEFINE VARIABLE tmp_tximpres        AS CHAR         NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_cartao_extrato_meses

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-34 IMAGE-38 IMAGE-40 IMAGE-35 IMAGE-36 ~
Btn_A Btn_E Btn_B Btn_C Btn_H 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_cartao_extrato_meses AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_A 
     LABEL "PRÓXIMOS 7 DIAS" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_B 
     LABEL "PRÓXIMOS 15 DIAS" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_C 
     LABEL "PRÓXIMOS 30 DIAS" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_E 
     LABEL "PRÓXIMOS 60 DIAS" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_H 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_dstarifa AS CHARACTER INITIAL "Extratos de Conta Corrente serão tarifados em R$" 
     VIEW-AS EDITOR
     SIZE 62 BY 2.62
     BGCOLOR 15 FGCOLOR 1 FONT 11 NO-UNDO.

DEFINE IMAGE IMAGE-34
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-35
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-36
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-38
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
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

DEFINE FRAME f_cartao_extrato_meses
     Btn_A AT ROW 9.1 COL 6 WIDGET-ID 78
     Btn_E AT ROW 9.1 COL 94.4 WIDGET-ID 68
     Btn_B AT ROW 14.1 COL 6 WIDGET-ID 62
     Btn_C AT ROW 19.1 COL 6 WIDGET-ID 64
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 74
     ed_dstarifa AT ROW 24.43 COL 5.4 NO-LABEL WIDGET-ID 96 NO-TAB-STOP 
     "LANÇAMENTOS FUTUROS" VIEW-AS TEXT
          SIZE 136 BY 3.33 AT ROW 1.48 COL 13 WIDGET-ID 158
          FGCOLOR 1 FONT 10
     IMAGE-34 AT ROW 9.24 COL 1 WIDGET-ID 142
     IMAGE-38 AT ROW 9.24 COL 156 WIDGET-ID 150
     IMAGE-40 AT ROW 24.24 COL 156 WIDGET-ID 154
     RECT-101 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-102 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-103 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-35 AT ROW 14.24 COL 1 WIDGET-ID 144
     IMAGE-36 AT ROW 19.24 COL 1 WIDGET-ID 146
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
  CREATE WINDOW w_cartao_extrato_meses ASSIGN
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
ASSIGN w_cartao_extrato_meses = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_cartao_extrato_meses
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_cartao_extrato_meses
   FRAME-NAME                                                           */
/* SETTINGS FOR EDITOR ed_dstarifa IN FRAME f_cartao_extrato_meses
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       ed_dstarifa:HIDDEN IN FRAME f_cartao_extrato_meses           = TRUE
       ed_dstarifa:READ-ONLY IN FRAME f_cartao_extrato_meses        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-101 IN FRAME f_cartao_extrato_meses
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-102 IN FRAME f_cartao_extrato_meses
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-103 IN FRAME f_cartao_extrato_meses
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_cartao_extrato_meses:HANDLE
       ROW             = 3.62
       COLUMN          = 2
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_extrato_meses */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_cartao_extrato_meses
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_extrato_meses w_cartao_extrato_meses
ON END-ERROR OF w_cartao_extrato_meses
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_extrato_meses w_cartao_extrato_meses
ON WINDOW-CLOSE OF w_cartao_extrato_meses
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_A
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_A w_cartao_extrato_meses
ON ANY-KEY OF Btn_A IN FRAME f_cartao_extrato_meses /* PRÓXIMOS 7 DIAS */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_A w_cartao_extrato_meses
ON CHOOSE OF Btn_A IN FRAME f_cartao_extrato_meses /* PRÓXIMOS 7 DIAS */
DO:
    ASSIGN tmp_dtfimext = (glb_dtmvtolt + 7)
           tmp_dtiniext = glb_dtmvtolt.

    h_principal:MOVE-TO-TOP().

    RUN procedures/obtem_lancamentos_futuros.p ( INPUT tmp_dtiniext,
                                                 INPUT tmp_dtfimext,
                                                 INPUT aux_inisenta,
                                                 OUTPUT tmp_tximpres,
                                                 OUTPUT aux_flgderro).

    IF  NOT aux_flgderro  THEN               
        RUN impressao_visualiza.w (INPUT "Lançamentos Futuros 7 dias...",
                                   INPUT tmp_tximpres,
                                   INPUT 1, /*Lançamentos*/
                                   INPUT STRING(tmp_dtiniext)).


    RETURN "OK". 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_B
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_B w_cartao_extrato_meses
ON ANY-KEY OF Btn_B IN FRAME f_cartao_extrato_meses /* PRÓXIMOS 15 DIAS */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_B w_cartao_extrato_meses
ON CHOOSE OF Btn_B IN FRAME f_cartao_extrato_meses /* PRÓXIMOS 15 DIAS */
DO:
    ASSIGN tmp_dtfimext = (glb_dtmvtolt + 15)
           tmp_dtiniext = glb_dtmvtolt.

    h_principal:MOVE-TO-TOP().

    RUN procedures/obtem_lancamentos_futuros.p ( INPUT tmp_dtiniext,
                                                 INPUT tmp_dtfimext,
                                                 INPUT aux_inisenta,
                                                 OUTPUT tmp_tximpres,
                                                 OUTPUT aux_flgderro).
    
    IF  NOT aux_flgderro  THEN               
        RUN impressao_visualiza.w (INPUT "Lançamentos Futuros 15 dias...",
                                   INPUT tmp_tximpres,
                                   INPUT 1, /*Lançamentos*/
                                   INPUT STRING(tmp_dtiniext)).
    RETURN "OK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_C
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_C w_cartao_extrato_meses
ON ANY-KEY OF Btn_C IN FRAME f_cartao_extrato_meses /* PRÓXIMOS 30 DIAS */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_C w_cartao_extrato_meses
ON CHOOSE OF Btn_C IN FRAME f_cartao_extrato_meses /* PRÓXIMOS 30 DIAS */
DO:
  ASSIGN tmp_dtfimext = (glb_dtmvtolt + 30)
         tmp_dtiniext = glb_dtmvtolt.
    
    h_principal:MOVE-TO-TOP().

   RUN procedures/obtem_lancamentos_futuros.p ( INPUT tmp_dtiniext,
                                                 INPUT tmp_dtfimext,
                                                 INPUT aux_inisenta,
                                                 OUTPUT tmp_tximpres,
                                                 OUTPUT aux_flgderro).
    
    IF  NOT aux_flgderro  THEN               
        RUN impressao_visualiza.w (INPUT "Lançamentos Futuros 30 dias...",
                                   INPUT tmp_tximpres,
                                   INPUT 1, /*Lançamentos*/
                                   INPUT STRING(tmp_dtiniext)).

    RETURN "OK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_E
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_cartao_extrato_meses
ON ANY-KEY OF Btn_E IN FRAME f_cartao_extrato_meses /* PRÓXIMOS 60 DIAS */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_cartao_extrato_meses
ON CHOOSE OF Btn_E IN FRAME f_cartao_extrato_meses /* PRÓXIMOS 60 DIAS */
DO:
    ASSIGN tmp_dtfimext = (glb_dtmvtolt + 60)
           tmp_dtiniext = glb_dtmvtolt.
    
    h_principal:MOVE-TO-TOP().
     
    RUN procedures/obtem_lancamentos_futuros.p ( INPUT tmp_dtiniext,
                                                 INPUT tmp_dtfimext,
                                                 INPUT aux_inisenta,
                                                 OUTPUT tmp_tximpres,
                                                 OUTPUT aux_flgderro).
    
    IF  NOT aux_flgderro  THEN               
        RUN impressao_visualiza.w (INPUT "Lançamentos Futuros 60 dias...",
                                   INPUT tmp_tximpres,
                                   INPUT 1, /*Lançamentos*/
                                   INPUT STRING(tmp_dtiniext)).

    RETURN "OK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_extrato_meses
ON ANY-KEY OF Btn_H IN FRAME f_cartao_extrato_meses /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_extrato_meses
ON CHOOSE OF Btn_H IN FRAME f_cartao_extrato_meses /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_cartao_extrato_meses OCX.Tick
PROCEDURE temporizador.t_cartao_extrato_meses.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_cartao_extrato_meses.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_cartao_extrato_meses 


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
    FRAME f_cartao_extrato_meses:LOAD-MOUSE-POINTER("blank.cur").

    chtemporizador:t_cartao_extrato_meses:INTERVAL = glb_nrtempor.

    
        /* verifica se o extrato sera tarifado */
    RUN procedures/obtem_tarifa_extrato.p (OUTPUT aux_vltarifa,
                                           OUTPUT aux_flgderro).

    IF  aux_vltarifa > 0  THEN
        DO:
            /* se retorna valor, deve cobrar */
            ASSIGN ed_dstarifa  = ed_dstarifa + STRING(aux_vltarifa,"z9.99")
                   aux_inisenta = 0.

            ENABLE ed_dstarifa WITH FRAME f_cartao_extrato_meses.
            DISPLAY ed_dstarifa WITH FRAME f_cartao_extrato_meses.
        END.
    ELSE
        /* extrato isento */
        aux_inisenta = 1.


    /* coloca o foco no botao H */
    APPLY "ENTRY" TO Btn_H.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_cartao_extrato_meses  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_lancamentos_futuros.wrx":U ).
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
ELSE MESSAGE "cartao_lancamentos_futuros.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_cartao_extrato_meses  _DEFAULT-DISABLE
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
  HIDE FRAME f_cartao_extrato_meses.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_cartao_extrato_meses  _DEFAULT-ENABLE
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
  ENABLE IMAGE-34 IMAGE-38 IMAGE-40 IMAGE-35 IMAGE-36 Btn_A Btn_E Btn_B Btn_C 
         Btn_H 
      WITH FRAME f_cartao_extrato_meses.
  {&OPEN-BROWSERS-IN-QUERY-f_cartao_extrato_meses}
  VIEW w_cartao_extrato_meses.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_cartao_extrato_meses 
PROCEDURE tecla :
chtemporizador:t_cartao_extrato_meses:INTERVAL = 0.

    /* ---------- */
    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).
    
    IF  aux_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.
    
    IF  KEY-FUNCTION(LASTKEY) = "A"                      AND
        Btn_A:SENSITIVE IN FRAME f_cartao_extrato_meses  THEN
        APPLY "CHOOSE" TO Btn_A.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "B"                      AND
        Btn_B:SENSITIVE IN FRAME f_cartao_extrato_meses  THEN
        APPLY "CHOOSE" TO Btn_B.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "C"                      AND
        Btn_B:SENSITIVE IN FRAME f_cartao_extrato_meses  THEN
        APPLY "CHOOSE" TO Btn_C.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "E"                      AND
        Btn_E:SENSITIVE IN FRAME f_cartao_extrato_meses  THEN
        APPLY "CHOOSE" TO Btn_E.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                      AND
        Btn_H:SENSITIVE IN FRAME f_cartao_extrato_meses  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_cartao_extrato_meses:INTERVAL = glb_nrtempor.

    /* repassa o retorno */
    IF  RETURN-VALUE = "OK"  THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "OK".
        END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

