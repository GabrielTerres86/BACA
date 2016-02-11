&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_beneficiarios
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_beneficiarios 
/* ..............................................................................

Procedure: envelope_deposito_cooperativa.w
Objetivo : Tela para selecionar o beneficiario do inss
Autor    : Lucas Reinert
Data     : Junho 2014

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

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

{ includes/var_taa.i }
    
DEFINE INPUT  PARAM par_dtcompet        AS CHAR                       NO-UNDO.
                                                                     
DEFINE VARIABLE aux_novoben             AS INTEGER  INIT 1            NO-UNDO.
DEFINE VARIABLE aux_flgderro            AS LOGICAL                    NO-UNDO.
DEFINE VARIABLE aux_dsextrat            AS CHAR                       NO-UNDO.

DEFINE TEMP-TABLE tt-dcb NO-UNDO
       FIELD nrrecben AS DECI  /* Numero do recebimento do beneficiario    */
       FIELD nmbenefi AS CHAR  /* Nome do beneficiario*/
       FIELD dtcompet AS CHAR  /* Data de competencia */
       FIELD vlliquid AS DECI. /* Valor liquido */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_beneficiarios

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-34 IMAGE-35 IMAGE-36 IMAGE-37 IMAGE-38 ~
IMAGE-39 IMAGE-40 IMAGE-48 Btn_A Btn_E Btn_B Btn_F Btn_C Btn_G Btn_D Btn_H 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_beneficiarios AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_A 
     LABEL "" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_B 
     LABEL "" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_C 
     LABEL "" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_D 
     LABEL "" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_E 
     LABEL "" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_F 
     LABEL "" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_G 
     LABEL "" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_H 
     LABEL "" 
     SIZE 61 BY 3.33
     FONT 8.

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

DEFINE FRAME f_beneficiarios
     Btn_A AT ROW 9.1 COL 6 WIDGET-ID 78
     Btn_E AT ROW 9.1 COL 94.4 WIDGET-ID 68
     Btn_B AT ROW 14.1 COL 6 WIDGET-ID 84
     Btn_F AT ROW 14.1 COL 94.4 WIDGET-ID 70
     Btn_C AT ROW 19.1 COL 6 WIDGET-ID 82
     Btn_G AT ROW 19.1 COL 94.4 WIDGET-ID 86
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 66
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 74
     "BENEFICIÁRIOS" VIEW-AS TEXT
          SIZE 69.8 BY 3.33 AT ROW 1.48 COL 50.4 WIDGET-ID 166
          FGCOLOR 1 FONT 10
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
  CREATE WINDOW w_beneficiarios ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.57
         WIDTH              = 160
         MAX-HEIGHT         = 35.67
         MAX-WIDTH          = 272.8
         VIRTUAL-HEIGHT     = 35.67
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
ASSIGN w_beneficiarios = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_beneficiarios
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_beneficiarios
   FRAME-NAME                                                           */
/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_beneficiarios
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_beneficiarios
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_beneficiarios
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_beneficiarios:HANDLE
       ROW             = 1.71
       COLUMN          = 4
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_beneficiarios */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_beneficiarios
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_beneficiarios w_beneficiarios
ON END-ERROR OF w_beneficiarios
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_beneficiarios w_beneficiarios
ON WINDOW-CLOSE OF w_beneficiarios
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_A
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_A w_beneficiarios
ON ANY-KEY OF Btn_A IN FRAME f_beneficiarios
DO:
  RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_A w_beneficiarios
ON CHOOSE OF Btn_A IN FRAME f_beneficiarios
DO:
    IF   Btn_A:VISIBLE IN FRAME f_beneficiarios  THEN
         DO:

            RUN procedures/obtem_demonstrativo_beneficiarios.p
                (INPUT par_dtcompet,
                 INPUT DECI(Btn_A:LABEL IN FRAME f_beneficiarios),
                 OUTPUT aux_flgderro,
                 OUTPUT aux_dsextrat).

            IF  NOT aux_flgderro  THEN
                RUN impressao_visualiza.w (INPUT "Demonstrativo INSS...",
                                           INPUT aux_dsextrat,
                                           INPUT 0, /*Extrato*/
                                           INPUT "").

         END.               
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_B
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_B w_beneficiarios
ON ANY-KEY OF Btn_B IN FRAME f_beneficiarios
DO:
  RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_B w_beneficiarios
ON CHOOSE OF Btn_B IN FRAME f_beneficiarios
DO:
   IF   Btn_B:VISIBLE IN FRAME f_beneficiarios  THEN
        DO:
           RUN procedures/obtem_demonstrativo_beneficiarios.p
               (INPUT par_dtcompet,
                INPUT DECI(Btn_B:LABEL IN FRAME f_beneficiarios),
                OUTPUT aux_flgderro,
                OUTPUT aux_dsextrat).
            
            IF  NOT aux_flgderro  THEN
               RUN impressao_visualiza.w (INPUT "Demonstrativo INSS...",
                                          INPUT aux_dsextrat,
                                          INPUT 0, /*Extrato*/
                                          INPUT "").


        END.          
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_C
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_C w_beneficiarios
ON ANY-KEY OF Btn_C IN FRAME f_beneficiarios
DO:
  RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_C w_beneficiarios
ON CHOOSE OF Btn_C IN FRAME f_beneficiarios
DO:
   IF   Btn_C:VISIBLE IN FRAME f_beneficiarios  THEN
        DO:
           RUN procedures/obtem_demonstrativo_beneficiarios.p
               (INPUT par_dtcompet,
                INPUT DECI(Btn_C:LABEL IN FRAME f_beneficiarios),
                OUTPUT aux_flgderro,
                OUTPUT aux_dsextrat).
            
            IF  NOT aux_flgderro  THEN
               RUN impressao_visualiza.w (INPUT "Demonstrativo INSS...",
                                          INPUT aux_dsextrat,
                                          INPUT 0, /*Extrato*/
                                          INPUT "").

        END.           
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_beneficiarios
ON ANY-KEY OF Btn_D IN FRAME f_beneficiarios
DO:
  RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_beneficiarios
ON CHOOSE OF Btn_D IN FRAME f_beneficiarios
DO:
   RUN inicializa_beneficiarios.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_E
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_beneficiarios
ON ANY-KEY OF Btn_E IN FRAME f_beneficiarios
DO:
  RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_beneficiarios
ON CHOOSE OF Btn_E IN FRAME f_beneficiarios
DO:
    IF   Btn_E:VISIBLE IN FRAME f_beneficiarios  THEN
         DO:
            RUN procedures/obtem_demonstrativo_beneficiarios.p
                (INPUT par_dtcompet,
                 INPUT DECI(Btn_E:LABEL IN FRAME f_beneficiarios),
                 OUTPUT aux_flgderro,
                 OUTPUT aux_dsextrat).
            
            IF  NOT aux_flgderro  THEN
                RUN impressao_visualiza.w (INPUT "Demonstrativo INSS...",
                                           INPUT aux_dsextrat,
                                           INPUT 0, /*Extrato*/
                                           INPUT "").

         END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_F
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_beneficiarios
ON ANY-KEY OF Btn_F IN FRAME f_beneficiarios
DO:
  RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_beneficiarios
ON CHOOSE OF Btn_F IN FRAME f_beneficiarios
DO:
    IF   Btn_F:VISIBLE IN FRAME f_beneficiarios  THEN
         DO:
            RUN procedures/obtem_demonstrativo_beneficiarios.p
                (INPUT par_dtcompet,
                 INPUT DECI(Btn_F:LABEL IN FRAME f_beneficiarios),
                 OUTPUT aux_flgderro,
                 OUTPUT aux_dsextrat).
                
            IF  NOT aux_flgderro  THEN
                RUN impressao_visualiza.w (INPUT "Demonstrativo INSS...",
                                           INPUT aux_dsextrat,
                                           INPUT 0, /*Extrato*/
                                           INPUT "").


         END.   
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_G
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_beneficiarios
ON ANY-KEY OF Btn_G IN FRAME f_beneficiarios
DO:
  RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_beneficiarios
ON CHOOSE OF Btn_G IN FRAME f_beneficiarios
DO:
   IF   Btn_G:VISIBLE IN FRAME f_beneficiarios  THEN
        DO:
           RUN procedures/obtem_demonstrativo_beneficiarios.p
                (INPUT par_dtcompet,
                INPUT DECI(Btn_G:LABEL IN FRAME f_beneficiarios),
                OUTPUT aux_flgderro,
                OUTPUT aux_dsextrat).
            
           IF  NOT aux_flgderro  THEN
                RUN impressao_visualiza.w (INPUT "Demonstrativo INSS...",
                                          INPUT aux_dsextrat,
                                          INPUT 0, /*Extrato*/
                                          INPUT "").


        END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_beneficiarios
ON ANY-KEY OF Btn_H IN FRAME f_beneficiarios
DO:
  RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_beneficiarios
ON CHOOSE OF Btn_H IN FRAME f_beneficiarios
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_beneficiarios OCX.Tick
PROCEDURE temporizador.t_beneficiarios.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_beneficiarios.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_beneficiarios 


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
    FRAME f_beneficiarios:LOAD-MOUSE-POINTER("blank.cur").

    ASSIGN chtemporizador:t_beneficiarios:INTERVAL = glb_nrtempor.
           
    RUN procedures/carrega_beneficiarios.p (INPUT par_dtcompet,
                                            OUTPUT aux_flgderro,
                                            OUTPUT TABLE tt-dcb).

    FOR FIRST tt-dcb NO-LOCK BY tt-dcb.nrrecben:

        ASSIGN  Btn_A:LABEL IN FRAME f_beneficiarios
                            = STRING(tt-dcb.nrrecben).
    END.
        
    IF  NOT CAN-FIND(FIRST tt-dcb)THEN
        DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "      Erro!",
                            INPUT "",
                            INPUT "Nenhum beneficiário encontrado.",
                            INPUT "",
                            INPUT "",
                            INPUT "").

            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.

            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
            RETURN "NOK".    
        END.        
    
    ASSIGN Btn_D:LABEL IN FRAME f_beneficiarios =
                   "OUTROS BENEFICIÁRIOS"

           Btn_H:LABEL IN FRAME f_beneficiarios = "VOLTAR".

    RUN inicializa_beneficiarios.
               
    /* coloca o foco no botao H */
    APPLY "ENTRY" TO Btn_H.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_beneficiarios  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_inss_beneficiarios.wrx":U ).
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
ELSE MESSAGE "cartao_inss_beneficiarios.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_beneficiarios  _DEFAULT-DISABLE
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
  HIDE FRAME f_beneficiarios.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_beneficiarios  _DEFAULT-ENABLE
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
  ENABLE IMAGE-34 IMAGE-35 IMAGE-36 IMAGE-37 IMAGE-38 IMAGE-39 IMAGE-40 
         IMAGE-48 Btn_A Btn_E Btn_B Btn_F Btn_C Btn_G Btn_D Btn_H 
      WITH FRAME f_beneficiarios.
  {&OPEN-BROWSERS-IN-QUERY-f_beneficiarios}
  VIEW w_beneficiarios.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE esconde_botoes w_beneficiarios 
PROCEDURE esconde_botoes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEF INPUT PARAM par_contador AS INTE                                   NO-UNDO.

IF   par_contador < 6   THEN
     ASSIGN Btn_G:VISIBLE IN FRAME f_beneficiarios = FALSE
            IMAGE-48:VISIBLE IN FRAME f_beneficiarios = FALSE.

IF   par_contador < 5   THEN     
     ASSIGN Btn_F:VISIBLE IN FRAME f_beneficiarios = FALSE
            IMAGE-39:VISIBLE IN FRAME f_beneficiarios = FALSE.
          
IF   par_contador < 4   THEN
     ASSIGN Btn_E:VISIBLE IN FRAME f_beneficiarios = FALSE
           IMAGE-38:VISIBLE IN FRAME f_beneficiarios = FALSE.

IF   par_contador < 3   THEN
     ASSIGN Btn_C:VISIBLE IN FRAME f_beneficiarios = FALSE
            IMAGE-36:VISIBLE IN FRAME f_beneficiarios = FALSE.

IF   par_contador < 2   THEN      
     ASSIGN Btn_B:VISIBLE IN FRAME f_beneficiarios = FALSE
            IMAGE-35:VISIBLE IN FRAME f_beneficiarios = FALSE.

IF   par_contador < 1   THEN
     ASSIGN Btn_A:VISIBLE IN FRAME f_beneficiarios = FALSE
            IMAGE-34:VISIBLE IN FRAME f_beneficiarios = FALSE.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE inicializa_beneficiarios w_beneficiarios 
PROCEDURE inicializa_beneficiarios :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE VARIABLE aux_contador AS INTEGER INIT 1                  NO-UNDO.
DEFINE VARIABLE aux_flgcondi AS LOGICAL                         NO-UNDO.
DEFINE VARIABLE aux_flgregis AS LOGICAL                         NO-UNDO.         
                                            
FOR EACH tt-dcb BY tt-dcb.nrrecben:

    IF Btn_A:LABEL IN FRAME f_beneficiarios = STRING(tt-dcb.nrrecben) THEN
       NEXT.
    
    ASSIGN aux_contador = aux_contador + 1.

    /* Desconsiderar os beneficiarios ja exibidos */
    IF   NOT aux_contador >= aux_novoben   AND 
         NOT aux_flgcondi                  THEN
         NEXT.         

    /* Alimentar primeiro botao somente quanto click em OUTROS BENEFICIARIOS */
    IF   aux_contador = aux_novoben THEN 
         DO:            
            ASSIGN  Btn_A:LABEL IN FRAME f_beneficiarios
                            = STRING(tt-dcb.nrrecben)
                    aux_flgcondi = TRUE
                    aux_contador = 1.
            NEXT.
         END.    

    ASSIGN aux_flgregis = TRUE.
      
    CASE aux_contador:
                        
        WHEN 2 THEN Btn_B:LABEL IN FRAME f_beneficiarios
                                = STRING(tt-dcb.nrrecben).

        WHEN 3 THEN Btn_C:LABEL IN FRAME f_beneficiarios
                                = STRING(tt-dcb.nrrecben).

        WHEN 4 THEN Btn_E:LABEL IN FRAME f_beneficiarios
                                = STRING(tt-dcb.nrrecben).

        WHEN 5 THEN Btn_F:LABEL IN FRAME f_beneficiarios
                                = STRING(tt-dcb.nrrecben).

        WHEN 6 THEN Btn_G:LABEL IN FRAME f_beneficiarios
                                = STRING(tt-dcb.nrrecben).

    END CASE.       

    IF  aux_contador = 6   THEN
        LEAVE.         

END.

/* Se nao achou nada, entao mostra desde o primeiro beneficiario */
IF   NOT aux_flgregis  THEN
     DO:
        /* Zerar indice de novo beneficiario */
        ASSIGN aux_novoben = 1.
                
        FOR FIRST tt-dcb NO-LOCK BY tt-dcb.nrrecben:

            ASSIGN  Btn_A:LABEL IN FRAME f_beneficiarios
                            = STRING(tt-dcb.nrrecben).
        END.

         /* Mostrar todos os botoes novamente */
        RUN mostra_botoes.

        /* Chamada recursiva pra mostrar as cooperativas iniciais */
        RUN inicializa_beneficiarios.

        RETURN.
     END.

/* Guardar qual vai ser o prox. beneficiario a ser mostrado */
ASSIGN aux_novoben =  aux_novoben + aux_contador.

/* Esconder os botoes onde nao tem beneficiario a ser mostrado */
RUN esconde_botoes (INPUT aux_contador).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mostra_botoes w_beneficiarios 
PROCEDURE mostra_botoes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

ASSIGN Btn_G:VISIBLE IN FRAME f_beneficiarios = TRUE
       IMAGE-48:VISIBLE IN FRAME f_beneficiarios = TRUE

       Btn_F:VISIBLE IN FRAME f_beneficiarios = TRUE
       IMAGE-39:VISIBLE IN FRAME f_beneficiarios = TRUE
          
       Btn_E:VISIBLE IN FRAME f_beneficiarios = TRUE
       IMAGE-38:VISIBLE IN FRAME f_beneficiarios = TRUE

       Btn_C:VISIBLE IN FRAME f_beneficiarios = TRUE
       IMAGE-36:VISIBLE IN FRAME f_beneficiarios = TRUE

       Btn_B:VISIBLE IN FRAME f_beneficiarios = TRUE
       IMAGE-35:VISIBLE IN FRAME f_beneficiarios = TRUE

       Btn_A:VISIBLE IN FRAME f_beneficiarios = TRUE
       IMAGE-34:VISIBLE IN FRAME f_beneficiarios = TRUE.                         
              
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_beneficiarios 
PROCEDURE tecla :
chtemporizador:t_beneficiarios:INTERVAL = 0.

    /* ---------- */
    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).
    
    IF  aux_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.
    
    IF  KEY-FUNCTION(LASTKEY) = "A"                      AND
        Btn_A:SENSITIVE IN FRAME f_beneficiarios  THEN
        APPLY "CHOOSE" TO Btn_A.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "B"                      AND
        Btn_B:SENSITIVE IN FRAME f_beneficiarios  THEN
        APPLY "CHOOSE" TO Btn_B.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "C"                      AND
        Btn_C:SENSITIVE IN FRAME f_beneficiarios  THEN
        APPLY "CHOOSE" TO Btn_C.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "D"                      AND
        Btn_D:SENSITIVE IN FRAME f_beneficiarios  THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "E"                      AND
        Btn_E:SENSITIVE IN FRAME f_beneficiarios  THEN
        APPLY "CHOOSE" TO Btn_E.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "F"                      AND
        Btn_F:SENSITIVE IN FRAME f_beneficiarios  THEN
        APPLY "CHOOSE" TO Btn_F.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "G"                      AND
        Btn_G:SENSITIVE IN FRAME f_beneficiarios  THEN
        APPLY "CHOOSE" TO Btn_G.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                      AND
        Btn_H:SENSITIVE IN FRAME f_beneficiarios  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_beneficiarios:INTERVAL = glb_nrtempor.

    /* repassa o retorno */
    IF  RETURN-VALUE = "OK"  THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "OK".
        END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

