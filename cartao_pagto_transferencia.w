&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_pagto_transferencia
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_pagto_transferencia 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 
  
  Alteracoes : 29/08/2011 - Incluir rotina de COMPROVANTES (Gabriel)
  
               20/08/2015 - Alterado a tela devido a unificação do pagamento
                           de titulo e conveio na mesma tela Melhoria-21 SD278322
                           (Odirlei-AMcom)

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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_pagto_transferencia

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-34 IMAGE-38 IMAGE-40 IMAGE-45 IMAGE-46 ~
IMAGE-47 IMAGE-48 IMAGE-49 Btn_A Btn_B Btn_C Btn_D Btn_H 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_pagto_transferencia AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_A 
     LABEL "PAGAMENTOS" 
     SIZE 149 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_B 
     LABEL "TRANSFERÊNCIAS" 
     SIZE 149 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_C 
     LABEL "CONSULTA DE AGENDAMENTOS" 
     SIZE 149 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_D 
     LABEL "COMPROVANTES" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_H 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE IMAGE IMAGE-34
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-38
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-40
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-45
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-46
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-47
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-48
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-49
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE RECTANGLE RECT-101
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-102
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-103
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 2 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_pagto_transferencia
     Btn_A AT ROW 9.14 COL 6 WIDGET-ID 78
     Btn_B AT ROW 14.14 COL 6 WIDGET-ID 68
     Btn_C AT ROW 19.14 COL 6 WIDGET-ID 166
     Btn_D AT ROW 24.14 COL 6 WIDGET-ID 168
     Btn_H AT ROW 24.14 COL 94.4 WIDGET-ID 74
     "PAGAMENTOS/TRANSFERÊNCIAS" VIEW-AS TEXT
          SIZE 110 BY 2.14 AT ROW 2.95 COL 26 WIDGET-ID 92
          FGCOLOR 1 FONT 13
     IMAGE-34 AT ROW 9.29 COL 1 WIDGET-ID 142
     IMAGE-38 AT ROW 9.29 COL 156 WIDGET-ID 150
     IMAGE-40 AT ROW 24.29 COL 156 WIDGET-ID 154
     RECT-101 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-102 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-103 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-45 AT ROW 24.29 COL 1 WIDGET-ID 156
     IMAGE-46 AT ROW 19.29 COL 1 WIDGET-ID 158
     IMAGE-47 AT ROW 14.29 COL 1 WIDGET-ID 160
     IMAGE-48 AT ROW 14.29 COL 156 WIDGET-ID 162
     IMAGE-49 AT ROW 19.29 COL 156 WIDGET-ID 164
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
  CREATE WINDOW w_pagto_transferencia ASSIGN
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
ASSIGN w_pagto_transferencia = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_pagto_transferencia
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_pagto_transferencia
   FRAME-NAME                                                           */
/* SETTINGS FOR RECTANGLE RECT-101 IN FRAME f_pagto_transferencia
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-102 IN FRAME f_pagto_transferencia
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-103 IN FRAME f_pagto_transferencia
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_pagto_transferencia:HANDLE
       ROW             = 1.71
       COLUMN          = 7
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_pagto_transferencia */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_pagto_transferencia
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_pagto_transferencia w_pagto_transferencia
ON END-ERROR OF w_pagto_transferencia
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_pagto_transferencia w_pagto_transferencia
ON WINDOW-CLOSE OF w_pagto_transferencia
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_A
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_A w_pagto_transferencia
ON ANY-KEY OF Btn_A IN FRAME f_pagto_transferencia /* PAGAMENTOS */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_A w_pagto_transferencia
ON CHOOSE OF Btn_A IN FRAME f_pagto_transferencia /* PAGAMENTOS */
DO:
    RUN cartao_pagamento_data.w.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_B
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_B w_pagto_transferencia
ON ANY-KEY OF Btn_B IN FRAME f_pagto_transferencia /* TRANSFERÊNCIAS */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_B w_pagto_transferencia
ON CHOOSE OF Btn_B IN FRAME f_pagto_transferencia /* TRANSFERÊNCIAS */
DO:
    RUN cartao_transferencia_data.w.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_C
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_C w_pagto_transferencia
ON ANY-KEY OF Btn_C IN FRAME f_pagto_transferencia /* CONSULTA DE AGENDAMENTOS */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_C w_pagto_transferencia
ON CHOOSE OF Btn_C IN FRAME f_pagto_transferencia /* CONSULTA DE AGENDAMENTOS */
DO:
    RUN cartao_agendamento_lista.w.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_pagto_transferencia
ON ANY-KEY OF Btn_D IN FRAME f_pagto_transferencia /* COMPROVANTES */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_pagto_transferencia
ON CHOOSE OF Btn_D IN FRAME f_pagto_transferencia /* COMPROVANTES */
DO:
    RUN cartao_comprovantes_data.w.

    /* Se esta voltando atras , fica na tela */
    IF   KEYFUNCTION(LASTKEY) <> "H"  AND
         RETURN-VALUE <> "NOK"        THEN
         DO:
             APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.           
             RETURN "OK".
         END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_pagto_transferencia
ON ANY-KEY OF Btn_H IN FRAME f_pagto_transferencia /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_pagto_transferencia
ON CHOOSE OF Btn_H IN FRAME f_pagto_transferencia /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_pagto_transferencia OCX.Tick
PROCEDURE temporizador.t_pagto_transferencia.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_pagto_transferencia.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_pagto_transferencia 


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
    FRAME f_pagto_transferencia:LOAD-MOUSE-POINTER("blank.cur").

    chtemporizador:t_pagto_transferencia:INTERVAL = glb_nrtempor.

    IF  aux_flgderro  THEN
        DO:
            APPLY "CHOOSE" TO Btn_H.
            RETURN NO-APPLY.
        END.

    /* coloca o foco no botao H */
    APPLY "ENTRY" TO Btn_H.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_pagto_transferencia  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_pagto_transferencia.wrx":U ).
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
ELSE MESSAGE "cartao_pagto_transferencia.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_pagto_transferencia  _DEFAULT-DISABLE
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
  HIDE FRAME f_pagto_transferencia.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_pagto_transferencia  _DEFAULT-ENABLE
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
  ENABLE IMAGE-34 IMAGE-38 IMAGE-40 IMAGE-45 IMAGE-46 IMAGE-47 IMAGE-48 
         IMAGE-49 Btn_A Btn_B Btn_C Btn_D Btn_H 
      WITH FRAME f_pagto_transferencia.
  {&OPEN-BROWSERS-IN-QUERY-f_pagto_transferencia}
  VIEW w_pagto_transferencia.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_pagto_transferencia 
PROCEDURE tecla :
chtemporizador:t_pagto_transferencia:INTERVAL = 0.

    IF  KEY-FUNCTION(LASTKEY) = "A"                    AND
        Btn_A:SENSITIVE IN FRAME f_pagto_transferencia THEN
        APPLY "CHOOSE" TO Btn_A.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "B"                    AND
        Btn_A:SENSITIVE IN FRAME f_pagto_transferencia THEN
        APPLY "CHOOSE" TO Btn_B.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "C"                    AND
        Btn_A:SENSITIVE IN FRAME f_pagto_transferencia THEN
        APPLY "CHOOSE" TO Btn_C.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "D"                    AND
        Btn_A:SENSITIVE IN FRAME f_pagto_transferencia THEN
        APPLY "CHOOSE" TO Btn_D.  /* Botao Ccomprovantes */
    ELSE  
    IF  KEY-FUNCTION(LASTKEY) = "E"                    AND
        Btn_A:SENSITIVE IN FRAME f_pagto_transferencia THEN
        APPLY "CHOOSE" TO Btn_A. /* Botão Pagamentos */
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "F"                    AND
        Btn_A:SENSITIVE IN FRAME f_pagto_transferencia THEN
        APPLY "CHOOSE" TO Btn_B. /* Botão Tranferências */
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "G"                    AND
        Btn_A:SENSITIVE IN FRAME f_pagto_transferencia THEN
        APPLY "CHOOSE" TO Btn_C. /* Botão de Consultas */
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                    AND
        Btn_H:SENSITIVE IN FRAME f_pagto_transferencia THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_pagto_transferencia:INTERVAL = glb_nrtempor.


    /* repassa o retorno */
    IF  RETURN-VALUE = "OK"  THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "OK".
        END.
    ELSE
        DO:
            /* joga o frame frente */
            FRAME f_pagto_transferencia:MOVE-TO-TOP().   

            APPLY "ENTRY" TO Btn_H.    
        END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

