&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME w_cartao_operadora_recarga
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_cartao_operadora_recarga 
/* ..............................................................................

Procedure: cartao_operadora_recarga.w
Objetivo : Tela para apresentar as operadoras de celulares para recarga
Autor    : Lucas Reinert
Data     : Fevereiro/2017
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

/* Usada para exibir as operadoras para recarga */
DEFINE TEMP-TABLE tt-operadoras-recarga NO-UNDO
       FIELD cdoperadora AS INTE  /* Cod. operadora */
       FIELD nmoperadora AS CHAR  /* Nome operadora */
       FIELD cdproduto   AS INTE  /* Cod. produto   */
       FIELD nmproduto   AS CHAR. /* Nome produto */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER par_nrdddcel AS INTEGER                  NO-UNDO.
DEFINE INPUT PARAMETER par_nrcelula AS DECIMAL                  NO-UNDO.
/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }

DEFINE VARIABLE aux_flgderro        AS LOGICAL                  NO-UNDO.
DEFINE VARIABLE aux_cdoperadora     AS INTEGER                  NO-UNDO.
DEFINE VARIABLE aux_cdproduto       AS INTEGER                  NO-UNDO.
DEFINE VARIABLE aux_nmoperadora     AS CHAR                     NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_operadora_recarga
&Scoped-define BROWSE-NAME b_operadoras

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-operadoras-recarga

/* Definitions for BROWSE b_operadoras                                  */
&Scoped-define FIELDS-IN-QUERY-b_operadoras tt-operadoras-recarga.nmproduto   
&Scoped-define ENABLED-FIELDS-IN-QUERY-b_operadoras   
&Scoped-define SELF-NAME b_operadoras
&Scoped-define OPEN-QUERY-b_operadoras DO:     OPEN QUERY b_operadoras FOR EACH tt-operadoras-recarga NO-LOCK INDEXED-REPOSITION.     APPLY "VALUE-CHANGED" TO b_operadoras. END.
&Scoped-define TABLES-IN-QUERY-b_operadoras tt-operadoras-recarga
&Scoped-define FIRST-TABLE-IN-QUERY-b_operadoras tt-operadoras-recarga


/* Definitions for FRAME f_operadora_recarga                            */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f_operadora_recarga ~
    ~{&OPEN-QUERY-b_operadoras}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_E Btn_F IMAGE-37 IMAGE-40 IMAGE-38 ~
IMAGE-39 RECT-149 b_operadoras Btn_D Btn_H 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_cartao_operadora_recarga AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_D 
     LABEL "VOLTAR" 
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
     LABEL "CONTINUAR" 
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

DEFINE RECTANGLE RECT-100
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 2 .

DEFINE RECTANGLE RECT-149
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 84 BY 15.48.

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
DEFINE QUERY b_operadoras FOR 
      tt-operadoras-recarga SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b_operadoras
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b_operadoras w_cartao_operadora_recarga _FREEFORM
  QUERY b_operadoras DISPLAY
      tt-operadoras-recarga.nmproduto
    COLUMN-LABEL "Selecione a operadora:" FORMAT "x(48)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 82 BY 14.91
         FONT 14 ROW-HEIGHT-CHARS 1.29 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_operadora_recarga
     Btn_E AT ROW 9.62 COL 142 WIDGET-ID 68
     Btn_F AT ROW 14.67 COL 142 WIDGET-ID 220
     b_operadoras AT ROW 7.24 COL 40.2 WIDGET-ID 200
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 66
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 74
     "RECARGA DE CELULAR" VIEW-AS TEXT
          SIZE 122 BY 2.14 AT ROW 2.43 COL 29.6 WIDGET-ID 226
          FGCOLOR 1 FONT 10
     IMAGE-37 AT ROW 24.29 COL 1 WIDGET-ID 148
     IMAGE-40 AT ROW 24.29 COL 156 WIDGET-ID 154
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-38 AT ROW 9.29 COL 156 WIDGET-ID 150
     IMAGE-39 AT ROW 14.29 COL 156 WIDGET-ID 222
     RECT-149 AT ROW 6.95 COL 39.2 WIDGET-ID 224
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 160 BY 28.67 WIDGET-ID 100.


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
  CREATE WINDOW w_cartao_operadora_recarga ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.67
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
ASSIGN w_cartao_operadora_recarga = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_cartao_operadora_recarga
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_operadora_recarga
   FRAME-NAME                                                           */
/* BROWSE-TAB b_operadoras RECT-149 f_operadora_recarga */
/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_operadora_recarga
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_operadora_recarga
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_operadora_recarga
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b_operadoras
/* Query rebuild information for BROWSE b_operadoras
     _START_FREEFORM
DO:
    OPEN QUERY b_operadoras FOR EACH tt-operadoras-recarga NO-LOCK INDEXED-REPOSITION.
    APPLY "VALUE-CHANGED" TO b_operadoras.
END.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b_operadoras */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_operadora_recarga:HANDLE
       ROW             = 1.95
       COLUMN          = 5
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_operadora_recarga */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_cartao_operadora_recarga
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_operadora_recarga w_cartao_operadora_recarga
ON END-ERROR OF w_cartao_operadora_recarga
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_operadora_recarga w_cartao_operadora_recarga
ON WINDOW-CLOSE OF w_cartao_operadora_recarga
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_operadora_recarga
ON ANY-KEY OF Btn_D IN FRAME f_operadora_recarga /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_operadora_recarga
ON CHOOSE OF Btn_D IN FRAME f_operadora_recarga /* VOLTAR */
DO:        
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_E
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_cartao_operadora_recarga
ON ANY-KEY OF Btn_E IN FRAME f_operadora_recarga /* SOBRE */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_cartao_operadora_recarga
ON CHOOSE OF Btn_E IN FRAME f_operadora_recarga /* SOBRE */
DO:
   APPLY "CURSOR-UP" TO b_operadoras.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_F
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_cartao_operadora_recarga
ON ANY-KEY OF Btn_F IN FRAME f_operadora_recarga /* DESCE */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_cartao_operadora_recarga
ON CHOOSE OF Btn_F IN FRAME f_operadora_recarga /* DESCE */
DO:
  APPLY "CURSOR-DOWN" TO b_operadoras.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_operadora_recarga
ON ANY-KEY OF Btn_H IN FRAME f_operadora_recarga /* CONTINUAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_operadora_recarga
ON CHOOSE OF Btn_H IN FRAME f_operadora_recarga /* CONTINUAR */
DO:
  RUN cartao_valores_recarga.w(INPUT par_nrdddcel
                              ,INPUT par_nrcelula
                              ,INPUT aux_cdoperadora
                              ,INPUT aux_nmoperadora
                              ,INPUT aux_cdproduto).
                              
  IF RETURN-VALUE = "OK" THEN
    DO:
      APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
      RETURN "OK".
    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b_operadoras
&Scoped-define SELF-NAME b_operadoras
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_operadoras w_cartao_operadora_recarga
ON VALUE-CHANGED OF b_operadoras IN FRAME f_operadora_recarga
DO:
    ASSIGN aux_cdoperadora = tt-operadoras-recarga.cdoperadora
           aux_cdproduto   = tt-operadoras-recarga.cdproduto
           aux_nmoperadora = tt-operadoras-recarga.nmoperadora.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_cartao_operadora_recarga OCX.Tick
PROCEDURE temporizador.t_cartao_operadora_recarga.Tick .
APPLY "CHOOSE" TO Btn_D IN FRAME f_operadora_recarga.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_cartao_operadora_recarga 


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

    RUN procedures/obtem_operadoras_recarga(OUTPUT aux_flgderro
                                           ,OUTPUT TABLE tt-operadoras-recarga).

    IF  NOT aux_flgderro AND CAN-FIND(FIRST tt-operadoras-recarga) THEN
        DO:
            APPLY "OPEN_QUERY" TO b_operadoras.
        END.
    ELSE
        DO:    
            RUN mensagem.w (INPUT YES,
                            INPUT "    ATENÇÃO",
                            INPUT "",
                            INPUT "",
                            INPUT "Não existem operadoras",
                            INPUT "para serem listadas.",
                            INPUT "").
            
            PAUSE 4 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.
            
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "NOK".
        END.
        
    RUN enable_UI.
              
    APPLY "ENTRY" TO Btn_D.          

    /* deixa o mouse transparente */
    b_operadoras:LOAD-MOUSE-POINTER("blank.cur").
    FRAME f_operadora_recarga:LOAD-MOUSE-POINTER("blank.cur").
    
    chtemporizador:t_cartao_operadora_recarga:INTERVAL = glb_nrtempor.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_cartao_operadora_recarga  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_operadora_recarga.wrx":U ).
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
ELSE MESSAGE "cartao_operadora_recarga.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_cartao_operadora_recarga  _DEFAULT-DISABLE
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
  HIDE FRAME f_operadora_recarga.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_cartao_operadora_recarga  _DEFAULT-ENABLE
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
  ENABLE Btn_E Btn_F IMAGE-37 IMAGE-40 IMAGE-38 IMAGE-39 RECT-149 b_operadoras 
         Btn_D Btn_H 
      WITH FRAME f_operadora_recarga.
  {&OPEN-BROWSERS-IN-QUERY-f_operadora_recarga}
  VIEW w_cartao_operadora_recarga.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_cartao_operadora_recarga 
PROCEDURE tecla :
chtemporizador:t_cartao_operadora_recarga:INTERVAL = 0.
 
    IF  KEY-FUNCTION(LASTKEY) = "D"                    AND    /* Voltar*/
        Btn_D:SENSITIVE IN FRAME f_operadora_recarga  THEN
        DO:
            APPLY "CHOOSE" TO Btn_D.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "E"                    AND    /* Sobe */
        Btn_E:SENSITIVE IN FRAME f_operadora_recarga  THEN
        DO:       
            APPLY "CHOOSE" TO Btn_E.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "F"                    AND    /* Desce */
        Btn_F:SENSITIVE IN FRAME f_operadora_recarga  THEN
        DO:         
            APPLY "CHOOSE" TO Btn_F.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                    AND    /* Selecionar Telefone*/
        Btn_H:SENSITIVE IN FRAME f_operadora_recarga  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        DO:
            chtemporizador:t_cartao_operadora_recarga:INTERVAL = glb_nrtempor.
            RETURN NO-APPLY.
        END.

    chtemporizador:t_cartao_operadora_recarga:INTERVAL = glb_nrtempor.

    /* Se utilizou alguma opcao, fecha a tela */
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            /* joga o frame frente */
            FRAME f_operadora_recarga:MOVE-TO-TOP().

            APPLY "ENTRY" TO Btn_D.
        END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

