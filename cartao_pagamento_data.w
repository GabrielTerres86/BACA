&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_cartao_pagamento_data
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_cartao_pagamento_data 
/* ..............................................................................

Procedure: cartao_pagamento_data.w
Objetivo : Tela para escolher o tipo de pagamento
Autor    : Evandro
Data     : Janeiro 2010

Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).
                  29/08/2011 - Incluir tratamento para final de semana ou
                               feriado (Gabriel)  
                  17/04/2013 - Alteração na mensagem de horario limite para
                               pagamentos (Lucas)
                  07/08/2014 - Nao permitir efetuar pagamentos no final de semana,
                                               somente agendamentos (Andrino-RKAM)
                  15/09/2014 - Alterações referentes ao Projeto Débito 
                               Automático Fácil (Lucas Lunelli - Out/2014)
                               
                  12/11/2014 - Esconder botão de debaut para títulos (Lunelli).
                  
                  20/08/2015 - Alterado a tela devido a unificação do pagamento
                               de titulo e conveio na mesma tela Melhoria-21 SD278322
                               (Odirlei-AMcom)
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


/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }

DEFINE VARIABLE aux_flgderro        AS LOGICAL      NO-UNDO.
DEFINE VARIABLE aux_hrinipag        AS INT          NO-UNDO.
DEFINE VARIABLE aux_hrfimpag        AS INT          NO-UNDO.
DEFINE VARIABLE aux_hrservid        AS INT          NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_cartao_pagamento_data

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-34 IMAGE-38 IMAGE-40 IMAGE-41 Btn_A ~
Btn_E ed_horarios Btn_D Btn_H ed_titpagto 
&Scoped-Define DISPLAYED-OBJECTS ed_horarios ed_titpagto 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_cartao_pagamento_data AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_A 
     LABEL "PARA ESTA DATA" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_D 
     LABEL "DÉBITO AUTOMÁTICO" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_E 
     LABEL "PARA DATA FUTURA" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_H 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_horarios AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 82 BY 6.43
     BGCOLOR 7 FGCOLOR 14 FONT 11 NO-UNDO.

DEFINE VARIABLE ed_titpagto AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 95 BY 3.33
     FGCOLOR 1 FONT 10 NO-UNDO.

DEFINE IMAGE IMAGE-34
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-38
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-40
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-41
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
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

DEFINE FRAME f_cartao_pagamento_data
     Btn_A AT ROW 9.14 COL 6 WIDGET-ID 78
     Btn_E AT ROW 9.14 COL 94.4 WIDGET-ID 68
     ed_horarios AT ROW 14.1 COL 42 NO-LABEL WIDGET-ID 96 NO-TAB-STOP 
     Btn_D AT ROW 24.1 COL 6.2 WIDGET-ID 224
     Btn_H AT ROW 24.14 COL 94.4 WIDGET-ID 74
     ed_titpagto AT ROW 1.48 COL 31.6 COLON-ALIGNED NO-LABEL WIDGET-ID 222
     "(Luz, água, telefone)" VIEW-AS TEXT
          SIZE 35 BY 1.19 AT ROW 27.43 COL 16.8 WIDGET-ID 94
          FONT 14
     RECT-101 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-102 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-103 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-34 AT ROW 9.29 COL 1 WIDGET-ID 142
     IMAGE-38 AT ROW 9.29 COL 156 WIDGET-ID 150
     IMAGE-40 AT ROW 24.29 COL 156 WIDGET-ID 154
     IMAGE-41 AT ROW 24.24 COL 1.2 WIDGET-ID 226
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
  CREATE WINDOW w_cartao_pagamento_data ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.62
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
ASSIGN w_cartao_pagamento_data = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_cartao_pagamento_data
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_cartao_pagamento_data
   FRAME-NAME                                                           */
ASSIGN 
       ed_horarios:READ-ONLY IN FRAME f_cartao_pagamento_data        = TRUE.

ASSIGN 
       ed_titpagto:READ-ONLY IN FRAME f_cartao_pagamento_data        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-101 IN FRAME f_cartao_pagamento_data
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-102 IN FRAME f_cartao_pagamento_data
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-103 IN FRAME f_cartao_pagamento_data
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_cartao_pagamento_data:HANDLE
       ROW             = 2.19
       COLUMN          = 21
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_pagamento_data */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_cartao_pagamento_data
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_pagamento_data w_cartao_pagamento_data
ON END-ERROR OF w_cartao_pagamento_data
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_pagamento_data w_cartao_pagamento_data
ON WINDOW-CLOSE OF w_cartao_pagamento_data
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_A
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_A w_cartao_pagamento_data
ON ANY-KEY OF Btn_A IN FRAME f_cartao_pagamento_data /* PARA ESTA DATA */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_A w_cartao_pagamento_data
ON CHOOSE OF Btn_A IN FRAME f_cartao_pagamento_data /* PARA ESTA DATA */
DO:
  RUN cartao_pagamento.w (INPUT FALSE).    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_pagamento_data
ON ANY-KEY OF Btn_D IN FRAME f_cartao_pagamento_data /* DÉBITO AUTOMÁTICO */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_pagamento_data
ON CHOOSE OF Btn_D IN FRAME f_cartao_pagamento_data /* DÉBITO AUTOMÁTICO */
DO:
    RUN cartao_pagamento_debaut.w.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_E
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_cartao_pagamento_data
ON ANY-KEY OF Btn_E IN FRAME f_cartao_pagamento_data /* PARA DATA FUTURA */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_cartao_pagamento_data
ON CHOOSE OF Btn_E IN FRAME f_cartao_pagamento_data /* PARA DATA FUTURA */
DO:
  RUN cartao_pagamento.w (INPUT TRUE).    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_pagamento_data
ON ANY-KEY OF Btn_H IN FRAME f_cartao_pagamento_data /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_pagamento_data
ON CHOOSE OF Btn_H IN FRAME f_cartao_pagamento_data /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_cartao_pagamento_data OCX.Tick
PROCEDURE temporizador.t_cartao_pagamento_data.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_cartao_pagamento_data.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_cartao_pagamento_data 


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
    FRAME f_cartao_pagamento_data:LOAD-MOUSE-POINTER("blank.cur").

    chtemporizador:t_cartao_pagamento_data:INTERVAL = glb_nrtempor.

    ed_titpagto:SCREEN-VALUE = "      PAGAMENTO".
    
    /* verifica o horário de corte */
    RUN procedures/horario_pagamento.p (OUTPUT aux_hrinipag,
                                        OUTPUT aux_hrfimpag,
                                        OUTPUT aux_hrservid,
                                        OUTPUT aux_flgderro).

    IF  aux_flgderro  THEN
        DO:
            APPLY "CHOOSE" TO Btn_H.
            RETURN NO-APPLY.
        END.

    ed_horarios:SCREEN-VALUE = " Horário permitido para pagamento de " + CHR(13) +
                               " títulos das " + STRING(aux_hrinipag,"HH:MM") + 
                               " às " + STRING(aux_hrfimpag,"HH:MM") + CHR(13) + 
                               " (Horário de Brasília)" + CHR(13) + 
                               " Horário para pagamento de convênio" + CHR(13) +
                               " varia de acordo com o convênio.".


                
    /* Se fora do horario e se nao é fim de semana/gferiado */
        /* Ajustado por Andrino */
    IF  (aux_hrservid < aux_hrinipag   OR
         aux_hrservid > aux_hrfimpag)  OR 
        glb_dtmvtocd > TODAY           THEN
        DO:
            DISABLE Btn_A WITH FRAME f_cartao_pagamento_data.
        END.
    /* Fim do ajuste do Andrino */
        
    /* coloca o foco no botao H */
    APPLY "ENTRY" TO Btn_H.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_cartao_pagamento_data  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_pagamento_data.wrx":U ).
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
ELSE MESSAGE "cartao_pagamento_data.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_cartao_pagamento_data  _DEFAULT-DISABLE
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
  HIDE FRAME f_cartao_pagamento_data.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_cartao_pagamento_data  _DEFAULT-ENABLE
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
  DISPLAY ed_horarios ed_titpagto 
      WITH FRAME f_cartao_pagamento_data.
  ENABLE IMAGE-34 IMAGE-38 IMAGE-40 IMAGE-41 Btn_A Btn_E ed_horarios Btn_D 
         Btn_H ed_titpagto 
      WITH FRAME f_cartao_pagamento_data.
  {&OPEN-BROWSERS-IN-QUERY-f_cartao_pagamento_data}
  VIEW w_cartao_pagamento_data.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_cartao_pagamento_data 
PROCEDURE tecla :
chtemporizador:t_cartao_pagamento_data:INTERVAL = 0.

    /* ---------- */
    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).
    
    IF  aux_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.

    IF  KEY-FUNCTION(LASTKEY) = "A"                       AND
        Btn_A:SENSITIVE IN FRAME f_cartao_pagamento_data  THEN
        APPLY "CHOOSE" TO Btn_A.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "D"                       AND
        Btn_D:SENSITIVE IN FRAME f_cartao_pagamento_data  THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "E"                       AND
        Btn_E:SENSITIVE IN FRAME f_cartao_pagamento_data  THEN
        APPLY "CHOOSE" TO Btn_E.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                       AND
        Btn_H:SENSITIVE IN FRAME f_cartao_pagamento_data  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_cartao_pagamento_data:INTERVAL = glb_nrtempor.


    /* repassa o retorno */
    IF  RETURN-VALUE = "OK"  THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "OK".
        END.
    ELSE
        DO:
            /* joga o frame frente */
            FRAME f_cartao_pagamento_data:MOVE-TO-TOP().

            APPLY "ENTRY" TO Btn_H.
             
        END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

