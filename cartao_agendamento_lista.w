&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME w_cartao_agendamento_lista
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_cartao_agendamento_lista 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 
  
  Alteracoes: 29/08/2011 - Incluir descricao de listagem maxima de 100
                           registros (Gabriel)

			  23/03/2017 - Tratado para listar agendamentos de recarga de 
						   celular. (PRJ321 - Reinert)
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

DEFINE TEMP-TABLE tt-dados-agendamento NO-UNDO
       FIELD dtmvtolt AS DATE   /* Data do agendamento                   */
       FIELD dtmvtopg AS DATE   /* Data de pagamento do agendamento      */
       FIELD nrdocmto AS INTE   /* Descrição do agendamento              */
       FIELD vllanaut AS DECI   /* Valor do agendamento                  */
       FIELD cdtiptra AS INTE   /* Tipo de agendamento                   */
       FIELD dstiptra AS CHAR   /* Tipo de agendamento                   */
       FIELD dssitlau AS CHAR   /* 1-Pendente                            */
       FIELD linhadig AS CHAR   /* Linha digitável do documento.         */
       FIELD dsagenda AS CHAR   /* Cedente ou conta destino              */
       FIELD dsageban AS CHAR   /* Cooperativa destino                   */
       FIELD nmoperadora AS CHAR /* Operadora (Recarga de celular)      */
       FIELD dstelefo AS CHAR. /* Telefone (Recarga de celular)      */

EMPTY TEMP-TABLE tt-dados-agendamento.

DEFINE VARIABLE aux_flgderro        AS LOGICAL                  NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_cartao_agendamento_lista
&Scoped-define BROWSE-NAME b_agendamentos

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-dados-agendamento

/* Definitions for BROWSE b_agendamentos                                */
&Scoped-define FIELDS-IN-QUERY-b_agendamentos tt-dados-agendamento.dtmvtopg tt-dados-agendamento.dsagenda tt-dados-agendamento.vllanaut tt-dados-agendamento.dssitlau tt-dados-agendamento.dstiptra   
&Scoped-define ENABLED-FIELDS-IN-QUERY-b_agendamentos   
&Scoped-define SELF-NAME b_agendamentos
&Scoped-define OPEN-QUERY-b_agendamentos DO:     OPEN QUERY b_agendamentos FOR EACH tt-dados-agendamento NO-LOCK INDEXED-REPOSITION.     APPLY "VALUE-CHANGED" TO b_agendamentos. END.
&Scoped-define TABLES-IN-QUERY-b_agendamentos tt-dados-agendamento
&Scoped-define FIRST-TABLE-IN-QUERY-b_agendamentos tt-dados-agendamento


/* Definitions for FRAME f_cartao_agendamento_lista                     */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f_cartao_agendamento_lista ~
    ~{&OPEN-QUERY-b_agendamentos}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_E IMAGE-37 IMAGE-40 Btn_F IMAGE-38 ~
IMAGE-39 RECT-149 b_agendamentos Btn_D Btn_H ed_linhadig 
&Scoped-Define DISPLAYED-OBJECTS ed_linhadig 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_cartao_agendamento_lista AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_D 
     LABEL "EXCLUIR" 
     SIZE 61 BY 3.33
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

DEFINE VARIABLE ed_linhadig AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 140.4 BY 1.38
     FONT 14 NO-UNDO.

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

DEFINE RECTANGLE RECT-100
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 2 .

DEFINE RECTANGLE RECT-149
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 136 BY 15.95.

DEFINE RECTANGLE RECT-98
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-99
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 14 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b_agendamentos FOR 
      tt-dados-agendamento SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b_agendamentos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b_agendamentos w_cartao_agendamento_lista _FREEFORM
  QUERY b_agendamentos DISPLAY
      tt-dados-agendamento.dtmvtopg  COLUMN-LABEL "Data"      FORMAT "99/99/99"
tt-dados-agendamento.dsagenda  COLUMN-LABEL "Descrição" FORMAT "x(28)"
tt-dados-agendamento.vllanaut  COLUMN-LABEL "Valor"     FORMAT "zzz,zz9.99"
tt-dados-agendamento.dssitlau  COLUMN-LABEL "Situação"  FORMAT "x(10)"
tt-dados-agendamento.dstiptra  COLUMN-LABEL "Tipo"      FORMAT "x(13)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 134 BY 14.29
         FONT 14 ROW-HEIGHT-CHARS 1.29 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_cartao_agendamento_lista
     Btn_E AT ROW 9.62 COL 142 WIDGET-ID 68
     Btn_F AT ROW 14.67 COL 142 WIDGET-ID 220
     b_agendamentos AT ROW 6.29 COL 6 WIDGET-ID 200
     Btn_D AT ROW 24.14 COL 6 WIDGET-ID 66
     Btn_H AT ROW 24.14 COL 94.4 WIDGET-ID 74
     ed_linhadig AT ROW 20.71 COL 3 COLON-ALIGNED NO-LABEL WIDGET-ID 216 NO-TAB-STOP 
     " AGENDAMENTOS" VIEW-AS TEXT
          SIZE 85 BY 3.33 AT ROW 1.48 COL 38.6 WIDGET-ID 128
          FGCOLOR 1 FONT 10
     "* Serão exibidos até 100 registros." VIEW-AS TEXT
          SIZE 79 BY 1.38 AT ROW 22.38 COL 5 WIDGET-ID 228
          FGCOLOR 7 FONT 11
     IMAGE-37 AT ROW 24.29 COL 1 WIDGET-ID 148
     IMAGE-40 AT ROW 24.29 COL 156 WIDGET-ID 154
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-38 AT ROW 9.29 COL 156 WIDGET-ID 150
     IMAGE-39 AT ROW 14.29 COL 156 WIDGET-ID 222
     RECT-149 AT ROW 6 COL 5 WIDGET-ID 224
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
  CREATE WINDOW w_cartao_agendamento_lista ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.62
         WIDTH              = 160
         MAX-HEIGHT         = 34.29
         MAX-WIDTH          = 272.8
         VIRTUAL-HEIGHT     = 34.29
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
ASSIGN w_cartao_agendamento_lista = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_cartao_agendamento_lista
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_cartao_agendamento_lista
   FRAME-NAME                                                           */
/* BROWSE-TAB b_agendamentos RECT-149 f_cartao_agendamento_lista */
ASSIGN 
       ed_linhadig:READ-ONLY IN FRAME f_cartao_agendamento_lista        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_cartao_agendamento_lista
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_cartao_agendamento_lista
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_cartao_agendamento_lista
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b_agendamentos
/* Query rebuild information for BROWSE b_agendamentos
     _START_FREEFORM
DO:
    OPEN QUERY b_agendamentos FOR EACH tt-dados-agendamento NO-LOCK INDEXED-REPOSITION.
    APPLY "VALUE-CHANGED" TO b_agendamentos.
END.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b_agendamentos */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_cartao_agendamento_lista:HANDLE
       ROW             = 1.95
       COLUMN          = 5
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_agendamento_lista */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_cartao_agendamento_lista
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_agendamento_lista w_cartao_agendamento_lista
ON END-ERROR OF w_cartao_agendamento_lista
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_agendamento_lista w_cartao_agendamento_lista
ON WINDOW-CLOSE OF w_cartao_agendamento_lista
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_agendamento_lista
ON ANY-KEY OF Btn_D IN FRAME f_cartao_agendamento_lista /* EXCLUIR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_agendamento_lista
ON CHOOSE OF Btn_D IN FRAME f_cartao_agendamento_lista /* EXCLUIR */
DO:
    IF  NOT AVAIL tt-dados-agendamento  THEN
        RETURN.

    IF tt-dados-agendamento.dstiptra = "Pagamento" THEN
        RUN cartao_agendamento_exclusao_pagamento.w (INPUT tt-dados-agendamento.dtmvtopg,
                                                     INPUT tt-dados-agendamento.dtmvtolt,
                                                     INPUT tt-dados-agendamento.nrdocmto,
                                                     INPUT tt-dados-agendamento.dsagenda,
                                                     INPUT tt-dados-agendamento.vllanaut,
                                                     INPUT tt-dados-agendamento.linhadig).
    ELSE
    IF tt-dados-agendamento.dstiptra = "Transferencia" THEN
        RUN cartao_agendamento_exclusao_transferencia.w (INPUT tt-dados-agendamento.dsageban,
                                                         INPUT tt-dados-agendamento.dtmvtopg,
                                                         INPUT tt-dados-agendamento.dtmvtolt,
                                                         INPUT tt-dados-agendamento.nrdocmto,
                                                         INPUT tt-dados-agendamento.dsagenda,
                                                         INPUT tt-dados-agendamento.vllanaut).
    ELSE
    IF tt-dados-agendamento.dstiptra = "Recarga de celular" THEN
        RUN cartao_agendamento_exclusao_recarga.w (INPUT tt-dados-agendamento.nmoperadora,
                                                   INPUT tt-dados-agendamento.dtmvtopg,
                                                   INPUT tt-dados-agendamento.dtmvtolt,
                                                   INPUT tt-dados-agendamento.nrdocmto,
                                                   INPUT tt-dados-agendamento.dstelefo,
                                                   INPUT tt-dados-agendamento.vllanaut).
    APPLY "ENTRY" TO Btn_H.
    
    IF  RETURN-VALUE = "OK" THEN
        DO:
            DELETE tt-dados-agendamento.
            b_agendamentos:DELETE-CURRENT-ROW().
            ed_linhadig:SCREEN-VALUE = "".
                    
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW. 
            RETURN "OK".
            
        END.
    ELSE
        DO:
            /* joga o frame frente */
            FRAME f_cartao_agendamento_lista:MOVE-TO-TOP().    
        END.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_E
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_cartao_agendamento_lista
ON ANY-KEY OF Btn_E IN FRAME f_cartao_agendamento_lista /* SOBRE */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_cartao_agendamento_lista
ON CHOOSE OF Btn_E IN FRAME f_cartao_agendamento_lista /* SOBRE */
DO:
   APPLY "CURSOR-UP" TO b_agendamentos.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_F
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_cartao_agendamento_lista
ON ANY-KEY OF Btn_F IN FRAME f_cartao_agendamento_lista /* DESCE */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_cartao_agendamento_lista
ON CHOOSE OF Btn_F IN FRAME f_cartao_agendamento_lista /* DESCE */
DO:
  APPLY "CURSOR-DOWN" TO b_agendamentos.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_agendamento_lista
ON ANY-KEY OF Btn_H IN FRAME f_cartao_agendamento_lista /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_agendamento_lista
ON CHOOSE OF Btn_H IN FRAME f_cartao_agendamento_lista /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b_agendamentos
&Scoped-define SELF-NAME b_agendamentos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_agendamentos w_cartao_agendamento_lista
ON VALUE-CHANGED OF b_agendamentos IN FRAME f_cartao_agendamento_lista
DO:
    ed_linhadig:SCREEN-VALUE = tt-dados-agendamento.linhadig.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_cartao_agendamento_lista OCX.Tick
PROCEDURE temporizador.t_cartao_agendamento_lista.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_cartao_agendamento_lista.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_cartao_agendamento_lista 


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

    RUN procedures/obtem_agendamentos.p (OUTPUT aux_flgderro,
                                         OUTPUT TABLE tt-dados-agendamento).

    IF NOT aux_flgderro THEN
        IF  CAN-FIND(FIRST tt-dados-agendamento) THEN
            DO:
                APPLY "OPEN_QUERY" TO b_agendamentos.
            END.
        ELSE
            DO:
                
                RUN mensagem.w (INPUT YES,
                                INPUT "    ATENÇÃO",
                                INPUT "",
                                INPUT "",
                                INPUT "Não existem agendamentos",
                                INPUT "para serem listados.",
                                INPUT "").
                
                PAUSE 4 NO-MESSAGE.
                h_mensagem:HIDDEN = YES.
                
                APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                RETURN "NOK".
            END.

    RUN enable_UI.

    APPLY "ENTRY" TO Btn_H.
    
    /* deixa o mouse transparente */
    FRAME f_cartao_agendamento_lista:LOAD-MOUSE-POINTER("blank.cur").
    b_agendamentos:LOAD-MOUSE-POINTER("blank.cur").
    
    chtemporizador:t_cartao_agendamento_lista:INTERVAL = glb_nrtempor.

    

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_cartao_agendamento_lista  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_agendamento_lista.wrx":U ).
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
ELSE MESSAGE "cartao_agendamento_lista.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_cartao_agendamento_lista  _DEFAULT-DISABLE
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
  HIDE FRAME f_cartao_agendamento_lista.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_cartao_agendamento_lista  _DEFAULT-ENABLE
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
  DISPLAY ed_linhadig 
      WITH FRAME f_cartao_agendamento_lista.
  ENABLE Btn_E IMAGE-37 IMAGE-40 Btn_F IMAGE-38 IMAGE-39 RECT-149 
         b_agendamentos Btn_D Btn_H ed_linhadig 
      WITH FRAME f_cartao_agendamento_lista.
  {&OPEN-BROWSERS-IN-QUERY-f_cartao_agendamento_lista}
  VIEW w_cartao_agendamento_lista.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_cartao_agendamento_lista 
PROCEDURE tecla :
chtemporizador:t_cartao_agendamento_lista:INTERVAL = 0.
        
    IF  KEY-FUNCTION(LASTKEY) = "D"                          AND
        Btn_D:SENSITIVE IN FRAME f_cartao_agendamento_lista  THEN
        DO:
            APPLY "CHOOSE" TO Btn_D.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "E"                          AND
        Btn_D:SENSITIVE IN FRAME f_cartao_agendamento_lista  THEN
        DO:
            APPLY "CHOOSE" TO Btn_E.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "F"                          AND
        Btn_D:SENSITIVE IN FRAME f_cartao_agendamento_lista  THEN
        DO:
            APPLY "CHOOSE" TO Btn_F.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                          AND
        Btn_H:SENSITIVE IN FRAME f_cartao_agendamento_lista  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_cartao_agendamento_lista:INTERVAL = glb_nrtempor.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

