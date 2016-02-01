&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME w_pre_aprovado_parcela
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_pre_aprovado_parcela 
/* ...........................................................................

Procedure: credito_pre_aprovado_parcelas.w
Objetivo : Tela para apresentar as parcelas do pre-aprovado
Autor    : James Prust Junior
Data     : Setembro 2014

Ultima alteração: 26/01/2016 - Reformulação crítica (Lucas Lunelli - PRJ261)

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

DEFINE TEMP-TABLE tt-parcelas-cpa NO-UNDO
    FIELD nrparepr AS INTE
    FIELD vlparepr AS DECI
    FIELD dtvencto AS DATE
    FIELD flgdispo AS LOG.

EMPTY TEMP-TABLE tt-parcelas-cpa.

DEFINE INPUT        PARAMETER par_vldiscrd AS DECI                NO-UNDO.
DEFINE INPUT        PARAMETER par_txmensal AS DECI                NO-UNDO.
DEFINE INPUT        PARAMETER par_vlemprst AS DECI                NO-UNDO.
DEFINE INPUT        PARAMETER par_diapagto AS INTE                NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER par_flgretur AS CHAR                NO-UNDO.

DEFINE VARIABLE aux_flgderro               AS LOGICAL             NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_pre_aprovado_parcela
&Scoped-define BROWSE-NAME b_parcelas

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-parcelas-cpa

/* Definitions for BROWSE b_parcelas                                    */
&Scoped-define FIELDS-IN-QUERY-b_parcelas tt-parcelas-cpa.nrparepr " X " "R$" tt-parcelas-cpa.vlparepr ""   
&Scoped-define ENABLED-FIELDS-IN-QUERY-b_parcelas   
&Scoped-define SELF-NAME b_parcelas
&Scoped-define OPEN-QUERY-b_parcelas DO:     OPEN QUERY b_parcelas FOR EACH tt-parcelas-cpa NO-LOCK INDEXED-REPOSITION.     APPLY "VALUE-CHANGED" TO b_parcelas. END.
&Scoped-define TABLES-IN-QUERY-b_parcelas tt-parcelas-cpa
&Scoped-define FIRST-TABLE-IN-QUERY-b_parcelas tt-parcelas-cpa


/* Definitions for FRAME f_pre_aprovado_parcela                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f_pre_aprovado_parcela ~
    ~{&OPEN-QUERY-b_parcelas}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_E Btn_F IMAGE-40 IMAGE-37 IMAGE-38 ~
IMAGE-39 RECT-128 b_parcelas Btn_D Btn_H 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_pre_aprovado_parcela AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_D 
     LABEL "CONFIRMAR" 
     SIZE 53 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_E 
     IMAGE-UP FILE "Imagens/seta_up.gif":U NO-FOCUS
     LABEL "SOBRE" 
     SIZE 13.4 BY 2.38
     FONT 8.

DEFINE BUTTON Btn_F 
     IMAGE-UP FILE "Imagens/seta_down.gif":U NO-FOCUS
     LABEL "DESCE" 
     SIZE 13.4 BY 2.29
     FONT 8.

DEFINE BUTTON Btn_H 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

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

DEFINE RECTANGLE RECT-128
     EDGE-PIXELS 1 GRAPHIC-EDGE    
     SIZE 123 BY 1.67.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b_parcelas FOR 
      tt-parcelas-cpa SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b_parcelas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b_parcelas w_pre_aprovado_parcela _FREEFORM
  QUERY b_parcelas DISPLAY
      tt-parcelas-cpa.nrparepr COLUMN-LABEL "Parcelas" FORMAT "zzzzzzzzzzzz99"
      " X "                                            FORMAT "x(15)"
      "R$"                                             FORMAT "x(3)"
      tt-parcelas-cpa.vlparepr COLUMN-LABEL "Valor"    FORMAT "zzz,zz9.99"
      ""                                               FORMAT "x(50)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-LABELS NO-ROW-MARKERS NO-SCROLLBAR-VERTICAL SIZE 123 BY 15.48
         FONT 14 ROW-HEIGHT-CHARS 1.29 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_pre_aprovado_parcela
     Btn_E AT ROW 9.62 COL 142 WIDGET-ID 68
     Btn_F AT ROW 14.67 COL 142 WIDGET-ID 220
     b_parcelas AT ROW 8.14 COL 18 WIDGET-ID 200
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 66
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 74
     "VALOR" VIEW-AS TEXT
          SIZE 14 BY 1.19 AT ROW 6.71 COL 81 WIDGET-ID 236
          BGCOLOR 15 FONT 21
     "PARCELA" VIEW-AS TEXT
          SIZE 19 BY 1.19 AT ROW 6.71 COL 38 WIDGET-ID 234
          BGCOLOR 15 FONT 21
     "PRÉ-APROVADO" VIEW-AS TEXT
          SIZE 75.2 BY 2.95 AT ROW 1.95 COL 43 WIDGET-ID 92
          FGCOLOR 1 FONT 10
     IMAGE-40 AT ROW 24.24 COL 156 WIDGET-ID 154
     RECT-101 AT ROW 5.05 COL 18 WIDGET-ID 118
     RECT-102 AT ROW 5.52 COL 18 WIDGET-ID 120
     RECT-103 AT ROW 5.29 COL 18 WIDGET-ID 116
     IMAGE-37 AT ROW 24.24 COL 1 WIDGET-ID 148
     IMAGE-38 AT ROW 9.29 COL 156 WIDGET-ID 150
     IMAGE-39 AT ROW 14.29 COL 156 WIDGET-ID 222
     RECT-128 AT ROW 6.48 COL 18 WIDGET-ID 160
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
  CREATE WINDOW w_pre_aprovado_parcela ASSIGN
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
ASSIGN w_pre_aprovado_parcela = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_pre_aprovado_parcela
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_pre_aprovado_parcela
   FRAME-NAME                                                           */
/* BROWSE-TAB b_parcelas RECT-128 f_pre_aprovado_parcela */
/* SETTINGS FOR RECTANGLE RECT-101 IN FRAME f_pre_aprovado_parcela
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-102 IN FRAME f_pre_aprovado_parcela
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-103 IN FRAME f_pre_aprovado_parcela
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b_parcelas
/* Query rebuild information for BROWSE b_parcelas
     _START_FREEFORM
DO:
    OPEN QUERY b_parcelas FOR EACH tt-parcelas-cpa NO-LOCK INDEXED-REPOSITION.
    APPLY "VALUE-CHANGED" TO b_parcelas.
END.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b_parcelas */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_pre_aprovado_parcela:HANDLE
       ROW             = 1.71
       COLUMN          = 7
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_pre_aprovado_parcela */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_pre_aprovado_parcela
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_pre_aprovado_parcela w_pre_aprovado_parcela
ON END-ERROR OF w_pre_aprovado_parcela
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_pre_aprovado_parcela w_pre_aprovado_parcela
ON WINDOW-CLOSE OF w_pre_aprovado_parcela
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_pre_aprovado_parcela
ON ANY-KEY OF Btn_D IN FRAME f_pre_aprovado_parcela /* CONFIRMAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_pre_aprovado_parcela
ON CHOOSE OF Btn_D IN FRAME f_pre_aprovado_parcela /* CONFIRMAR */
DO:
    IF  NOT AVAIL tt-parcelas-cpa  THEN
        RETURN.

    IF NOT tt-parcelas-cpa.flgdispo THEN
       DO:
           RUN mensagem.w (INPUT NO,
                           INPUT "    ATENÇÃO  ",
                           INPUT "",
                           INPUT "",
                           INPUT "Essa opção não está disponivel para contratação.",
                           INPUT "",
                           INPUT "").

           PAUSE 3 NO-MESSAGE.
           h_mensagem:HIDDEN = YES.

           RETURN NO-APPLY.
       END.
    ELSE
       DO:
           RUN cartao_pre_aprovado_resumo.w (INPUT par_vldiscrd,
                                             INPUT par_txmensal,
                                             INPUT par_vlemprst,
                                             INPUT tt-parcelas-cpa.nrparepr,
                                             INPUT tt-parcelas-cpa.vlparepr,
                                             INPUT tt-parcelas-cpa.dtvencto,
                                             INPUT-OUTPUT par_flgretur).

           IF par_flgretur = "OK"  THEN
              DO:
                  APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                  RETURN "OK".
              END.
           ELSE
              DO:
                  /* joga o frame frente */
                  FRAME f_pre_aprovado_parcela:MOVE-TO-TOP().
                  APPLY "ENTRY" TO Btn_H.
                  RETURN NO-APPLY.
              END.
       END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_E
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_pre_aprovado_parcela
ON ANY-KEY OF Btn_E IN FRAME f_pre_aprovado_parcela /* SOBRE */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_pre_aprovado_parcela
ON CHOOSE OF Btn_E IN FRAME f_pre_aprovado_parcela /* SOBRE */
DO:
   APPLY "CURSOR-UP" TO b_parcelas.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_F
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_pre_aprovado_parcela
ON ANY-KEY OF Btn_F IN FRAME f_pre_aprovado_parcela /* DESCE */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_pre_aprovado_parcela
ON CHOOSE OF Btn_F IN FRAME f_pre_aprovado_parcela /* DESCE */
DO:
  APPLY "CURSOR-DOWN" TO b_parcelas.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_pre_aprovado_parcela
ON ANY-KEY OF Btn_H IN FRAME f_pre_aprovado_parcela /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_pre_aprovado_parcela
ON CHOOSE OF Btn_H IN FRAME f_pre_aprovado_parcela /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_pre_aprovado_parcela OCX.Tick
PROCEDURE temporizador.t_pre_aprovado_parcela.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_pre_aprovado_parcela.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b_parcelas
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_pre_aprovado_parcela 


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

    RUN procedures/obtem_parcelas_pre_aprovado.p (INPUT par_vlemprst,
                                                  INPUT par_diapagto,
                                                  OUTPUT aux_flgderro,
                                                  OUTPUT TABLE tt-parcelas-cpa).
                                                  
    IF NOT aux_flgderro THEN
       DO:
           IF  CAN-FIND(FIRST tt-parcelas-cpa) THEN
               DO:
                   APPLY "OPEN_QUERY" TO b_parcelas.
               END.
           ELSE
               DO:
                   RUN mensagem.w (INPUT YES,
                                   INPUT "    ATENÇÃO",
                                   INPUT "",
                                   INPUT "",
                                   INPUT "Não é possível calcular parcela para o vencimento/valor informado, realize alteração no vencimento/valor.",
                                   INPUT "",
                                   INPUT "").
                   
                   PAUSE 4 NO-MESSAGE.
                   h_mensagem:HIDDEN = YES.
                   
                   APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                   RETURN "NOK".
               END.

       END. /* END IF NOT aux_flgderro THEN */

    RUN enable_UI.

    APPLY "ENTRY" TO Btn_H.

    /* deixa o mouse transparente */
    FRAME f_pre_aprovado_parcela:LOAD-MOUSE-POINTER("blank.cur").
    b_parcelas:LOAD-MOUSE-POINTER("blank.cur").

    chtemporizador:t_pre_aprovado_parcela:INTERVAL = glb_nrtempor.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_pre_aprovado_parcela  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_pre_aprovado_parcelas.wrx":U ).
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
ELSE MESSAGE "cartao_pre_aprovado_parcelas.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_pre_aprovado_parcela  _DEFAULT-DISABLE
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
  HIDE FRAME f_pre_aprovado_parcela.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_pre_aprovado_parcela  _DEFAULT-ENABLE
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
  ENABLE Btn_E Btn_F IMAGE-40 IMAGE-37 IMAGE-38 IMAGE-39 RECT-128 b_parcelas 
         Btn_D Btn_H 
      WITH FRAME f_pre_aprovado_parcela.
  {&OPEN-BROWSERS-IN-QUERY-f_pre_aprovado_parcela}
  VIEW w_pre_aprovado_parcela.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_pre_aprovado_parcela 
PROCEDURE tecla :
chtemporizador:t_pre_aprovado_parcela:INTERVAL = 0.

    IF  KEY-FUNCTION(LASTKEY) = "D"                     AND
        Btn_D:SENSITIVE IN FRAME f_pre_aprovado_parcela THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "E"                     AND
        Btn_E:SENSITIVE IN FRAME f_pre_aprovado_parcela THEN
        APPLY "CHOOSE" TO Btn_E.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "F"                     AND
        Btn_F:SENSITIVE IN FRAME f_pre_aprovado_parcela THEN
        APPLY "CHOOSE" TO Btn_F.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                     AND
        Btn_H:SENSITIVE IN FRAME f_pre_aprovado_parcela THEN
        APPLY "CHOOSE" TO Btn_H.
    
    chtemporizador:t_pre_aprovado_parcela:INTERVAL = glb_nrtempor.

    IF NOT CAN-DO("D,E,F,H",KEY-FUNCTION(LASTKEY)) THEN
       RETURN NO-APPLY.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

