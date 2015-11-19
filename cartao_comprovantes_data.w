&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_cartao_comprovantes

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-37 IMAGE-40 RECT-133 RECT-134 ~
ed_dtinipro ed_dtfimpro Btn_D Btn_H 
&Scoped-Define DISPLAYED-OBJECTS ed_dtinipro ed_dtfimpro 

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
     LABEL "CONFIRMAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_H 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_dtfimpro AS CHARACTER FORMAT "xx/xx/xxxx":U 
     VIEW-AS FILL-IN 
     SIZE 25 BY 1.48
     FONT 8 NO-UNDO.

DEFINE VARIABLE ed_dtinipro AS CHARACTER FORMAT "xx/xx/xxxx":U 
     VIEW-AS FILL-IN 
     SIZE 25 BY 1.48
     FONT 8 NO-UNDO.

DEFINE IMAGE IMAGE-37
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-40
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE RECTANGLE RECT-100
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 2 .

DEFINE RECTANGLE RECT-133
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 27 BY 1.91.

DEFINE RECTANGLE RECT-134
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 27 BY 1.91.

DEFINE RECTANGLE RECT-98
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-99
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 14 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_cartao_comprovantes
     ed_dtinipro AT ROW 10.71 COL 52 COLON-ALIGNED NO-LABEL WIDGET-ID 166
     ed_dtfimpro AT ROW 10.71 COL 87 COLON-ALIGNED NO-LABEL WIDGET-ID 244
     Btn_D AT ROW 24.14 COL 6 WIDGET-ID 66
     Btn_H AT ROW 24.14 COL 94.4 WIDGET-ID 74
     "a" VIEW-AS TEXT
          SIZE 4 BY 1.38 AT ROW 10.71 COL 82 WIDGET-ID 242
          FONT 8
     "COMPROVANTES" VIEW-AS TEXT
          SIZE 82 BY 2.14 AT ROW 1.95 COL 43 WIDGET-ID 92
          FGCOLOR 1 FONT 10
     "Informe o período a ser consultado:" VIEW-AS TEXT
          SIZE 76 BY 1.67 AT ROW 7.67 COL 43 WIDGET-ID 226
          FONT 8
     "De:" VIEW-AS TEXT
          SIZE 7 BY 1.38 AT ROW 10.71 COL 45 WIDGET-ID 240
          FONT 8
     IMAGE-37 AT ROW 24.29 COL 1 WIDGET-ID 148
     IMAGE-40 AT ROW 24.29 COL 156 WIDGET-ID 154
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     RECT-133 AT ROW 10.52 COL 53 WIDGET-ID 172
     RECT-134 AT ROW 10.52 COL 88 WIDGET-ID 246
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
         HEIGHT             = 28.52
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
/* SETTINGS FOR FRAME f_cartao_comprovantes
   FRAME-NAME                                                           */
/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_cartao_comprovantes
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_cartao_comprovantes
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_cartao_comprovantes
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_cartao_comprovantes:HANDLE
       ROW             = 1.95
       COLUMN          = 5
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_comprovantes */

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
ON ANY-KEY OF Btn_D IN FRAME f_cartao_comprovantes /* CONFIRMAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_agendamento_lista
ON CHOOSE OF Btn_D IN FRAME f_cartao_comprovantes /* CONFIRMAR */
DO:
    /* Se data inicial em branco e data final prenchida */
    IF   DATE(ed_dtinipro:SCREEN-VALUE) =  ?   AND
         DATE(ed_dtfimpro:SCREEN-VALUE) <> ?   THEN
         DO:
             RUN mensagem.w (INPUT YES,
                             INPUT "    Atenção!",
                             INPUT "",
                             INPUT "A data inicial deve ser",
                             INPUT "prenchida.",
                             INPUT "",
                             INPUT "").

             PAUSE 3 NO-MESSAGE.
             h_mensagem:HIDDEN = YES.


             APPLY "ENTRY" TO ed_dtinipro.
             RETURN NO-APPLY.
         END.

    /* Se data inicial prenchida e data final em branco */
    IF   DATE(ed_dtinipro:SCREEN-VALUE) <> ?   AND
         DATE(ed_dtfimpro:SCREEN-VALUE)  = ?   THEN
         DO:
             RUN mensagem.w (INPUT YES,
                             INPUT "    Atenção!",
                             INPUT "",
                             INPUT "A data final deve ser",
                             INPUT "prenchida.",
                             INPUT "",
                             INPUT "").

             PAUSE 3 NO-MESSAGE.
             h_mensagem:HIDDEN = YES.

             APPLY "ENTRY" TO ed_dtfimpro.
             RETURN NO-APPLY.
         END.

     /* Criticar consultas anteriores com mais de dois anos*/
    IF   ADD-INTERVAL(DATE(ed_dtinipro:SCREEN-VALUE),2,"years") < glb_dtmvtolt   THEN
         DO:
             RUN mensagem.w (INPUT YES,
                             INPUT "    Atenção!",
                             INPUT "",
                             INPUT "A consulta deve ser de",
                             INPUT "até 2(dois) anos atrás.",
                             INPUT "",
                             INPUT "").

             PAUSE 3 NO-MESSAGE.
             h_mensagem:HIDDEN = YES.

             RETURN NO-APPLY.
         END.
    
    /* Se data inicio maior que data final */
    IF   DATE(ed_dtinipro:SCREEN-VALUE) > DATE(ed_dtfimpro:SCREEN-VALUE)   THEN
         DO:
             RUN mensagem.w (INPUT YES,
                             INPUT "    Atenção!",
                             INPUT "",
                             INPUT "A data final deve ser maior",
                             INPUT "ou igual a data de inicio.",
                             INPUT "",
                             INPUT "").

             PAUSE 3 NO-MESSAGE.
             h_mensagem:HIDDEN = YES.

             RETURN NO-APPLY.
         END.


    /* Se datas nao informadas */
    IF   DATE(ed_dtinipro:SCREEN-VALUE) = ?   OR 
         DATE(ed_dtfimpro:SCREEN-VALUE) = ?  THEN
         DO:
             IF   DATE(ed_dtinipro:SCREEN-VALUE) = ?   THEN
                  ASSIGN ed_dtinipro:SCREEN-VALUE = "01/" + 
                                           STRING(MONTH(glb_dtmvtolt),"99") + 
                                           "/"  +
                                           STRING(YEAR(glb_dtmvtolt),"9999").

             IF   DATE(ed_dtfimpro:SCREEN-VALUE) = ?   THEN
                  ASSIGN ed_dtfimpro:SCREEN-VALUE = 
                                           STRING(DAY(glb_dtmvtolt),"99")   +
                                           "/" + 
                                           STRING(MONTH(glb_dtmvtolt),"99") + 
                                           "/" + 
                                           STRING(YEAR(glb_dtmvtolt),"9999").
             PAUSE 3 NO-MESSAGE.
         END.

    RUN cartao_comprovantes.w (INPUT DATE(ed_dtinipro:SCREEN-VALUE),
                               INPUT DATE(ed_dtfimpro:SCREEN-VALUE)).

    APPLY "ENTRY" TO Btn_H.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            /* joga o frame frente */
            FRAME f_cartao_comprovantes:MOVE-TO-TOP(). 

            ASSIGN ed_dtinipro:SCREEN-VALUE = ""
                   ed_dtfimpro:SCREEN-VALUE = "".

            APPLY "ENTRY" TO ed_dtinipro IN FRAME f_cartao_comprovantes.
        END.
    ELSE
        DO:                
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
                 
            RETURN "OK".
        END.          
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_agendamento_lista
ON ANY-KEY OF Btn_H IN FRAME f_cartao_comprovantes /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_agendamento_lista
ON CHOOSE OF Btn_H IN FRAME f_cartao_comprovantes /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_dtfimpro
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_dtfimpro w_cartao_agendamento_lista
ON ANY-KEY OF ed_dtfimpro IN FRAME f_cartao_comprovantes
DO:
    RUN tecla.

    IF  CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))  THEN
        DO:
            /* limite de caracteres */
            IF  LENGTH(ed_dtfimpro:SCREEN-VALUE) > 9  THEN
                RETURN NO-APPLY.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            APPLY "CHOOSE" TO Btn_D. 
            RETURN NO-APPLY.               
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            /* Se BackSpace e nao tiver valor , voltar ao primeiro campo */
            IF  TRIM(TRIM(ed_dtfimpro:SCREEN-VALUE),"/") = "" THEN
                DO:
                    APPLY "ENTRY" TO ed_dtinipro.

                    RETURN NO-APPLY.                    
                END.  

            /* Se valor */
            /* Deixar sem nenhuma instrucao o 'BackSpace' , pois se */
            /* Colocarmos 'APPLY LASTKEY' ele apaga dois caracteres */
            /* por vez , e se dermos 'RETURN NO-APPLY' ele nao ira  */
            /* fazer nada. */

        END.       
    ELSE
        DO:
            /* se usou alguma opcao */
            IF  RETURN-VALUE = "OK"  THEN
                DO:
                    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                    RETURN "OK".
                END.
            ELSE
                RETURN NO-APPLY.
        END.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_dtinipro
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_dtinipro w_cartao_agendamento_lista
ON ANY-KEY OF ed_dtinipro IN FRAME f_cartao_comprovantes
DO:
    RUN tecla.

    IF  CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))  THEN
        DO:
            /* limite de caracteres */
            IF  LENGTH(ed_dtinipro:SCREEN-VALUE) > 9  THEN
                RETURN NO-APPLY.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            APPLY "ENTRY" TO ed_dtfimpro.
            RETURN NO-APPLY.               
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            /* Deixar sem nenhuma instrucao o 'BackSpace' , pois se */
            /* Colocarmos 'APPLY LASTKEY' ele apaga dois caracteres */
            /* por vez , e se dermos 'RETURN NO-APPLY' ele nao ira  */
            /* fazer nada. */
        END.
    ELSE
        DO:
            /* se usou alguma opcao */
            IF  RETURN-VALUE = "OK"  THEN
                DO:
                    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                    RETURN "OK".
                END.
            ELSE
                RETURN NO-APPLY.
        END.        
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_cartao_agendamento_lista OCX.Tick
PROCEDURE temporizador.t_cartao_comprovantes.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_cartao_comprovantes.
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
  
    RUN enable_UI.

    APPLY "ENTRY" TO Btn_H.
    
    /* deixa o mouse transparente */
    FRAME f_cartao_comprovantes:LOAD-MOUSE-POINTER("blank.cur").
    
    chtemporizador:t_cartao_comprovantes:INTERVAL = glb_nrtempor.  

    APPLY "ENTRY" TO ed_dtinipro.

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

OCXFile = SEARCH( "cartao_comprovantes_data.wrx":U ).
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
ELSE MESSAGE "cartao_comprovantes_data.wrx":U SKIP(1)
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
  HIDE FRAME f_cartao_comprovantes.
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
  DISPLAY ed_dtinipro ed_dtfimpro 
      WITH FRAME f_cartao_comprovantes.
  ENABLE IMAGE-37 IMAGE-40 RECT-133 RECT-134 ed_dtinipro ed_dtfimpro Btn_D 
         Btn_H 
      WITH FRAME f_cartao_comprovantes.
  {&OPEN-BROWSERS-IN-QUERY-f_cartao_comprovantes}
  VIEW w_cartao_agendamento_lista.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_cartao_agendamento_lista 
PROCEDURE tecla :
chtemporizador:t_cartao_comprovantes:INTERVAL = 0. 
    
    IF  KEY-FUNCTION(LASTKEY) = "D"                     AND
        Btn_D:SENSITIVE IN FRAME f_cartao_comprovantes  THEN
        DO:
            APPLY "CHOOSE" TO Btn_D.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                     AND
        Btn_H:SENSITIVE IN FRAME f_cartao_comprovantes  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE /* If so para contabilizar no temporizador */ 
    IF  CAN-DO("0,1,2,3,4,5,6,7,8,9,BACKSPACE",KEY-FUNCTION(LASTKEY)) THEN
        DO:
        END.
    ELSE 
        DO:
            RETURN NO-APPLY.
        END.
  
    chtemporizador:t_cartao_comprovantes:INTERVAL = glb_nrtempor.                    

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

