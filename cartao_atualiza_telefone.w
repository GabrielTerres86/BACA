&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_cartao_atualiza_telefone
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_cartao_atualiza_telefone 
/* ..............................................................................

Procedure: cartao_atualiza_telefone.w
Objetivo : Tela para Atualizar telefone cooperado
Autor    : Guilherme/SUPERO
Data     : Novembro 2016

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
DEFINE OUTPUT PARAM par_continua    AS LOGICAL              NO-UNDO.

/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }

DEFINE VARIABLE aux_flgderro        AS LOGICAL              NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_cartao_atualiza_telefone

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-3 RECT-4 RECT-2 IMAGE-40 IMAGE-41 ~
ed_nr_doddd ed_nrdofone ed_mensagem Btn_G Btn_H 
&Scoped-Define DISPLAYED-OBJECTS ed_nr_doddd ed_nrdofone ed_mensagem 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_cartao_atualiza_telefone AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_G 
     LABEL "CONTINUAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_H AUTO-END-KEY 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_mensagem AS CHARACTER INITIAL "Informe seu número de telefone atualizado." 
     VIEW-AS EDITOR
     SIZE 61 BY 4.05
     BGCOLOR 7 FGCOLOR 14 FONT 14 NO-UNDO.

DEFINE VARIABLE ed_nrdofone AS CHARACTER FORMAT "9(9)":U 
     VIEW-AS FILL-IN 
     SIZE 44.2 BY 2.14
     FGCOLOR 1 FONT 13 NO-UNDO.

DEFINE VARIABLE ed_nr_doddd AS CHARACTER FORMAT "x(2)":U 
     VIEW-AS FILL-IN 
     SIZE 11.2 BY 2.14
     FGCOLOR 1 FONT 13 NO-UNDO.

DEFINE IMAGE IMAGE-40
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-41
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

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 6 GRAPHIC-EDGE  NO-FILL   
     SIZE 71 BY 3.33.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 4 GRAPHIC-EDGE  NO-FILL   
     SIZE 13.2 BY 2.62.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 4 GRAPHIC-EDGE  NO-FILL   
     SIZE 46.2 BY 2.62.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_cartao_atualiza_telefone
     ed_nr_doddd AT ROW 9.81 COL 70.8 COLON-ALIGNED NO-LABEL WIDGET-ID 142
     ed_nrdofone AT ROW 12.91 COL 70.8 COLON-ALIGNED NO-LABEL WIDGET-ID 146
     ed_mensagem AT ROW 18.29 COL 12 NO-LABEL WIDGET-ID 164 NO-TAB-STOP 
     Btn_G AT ROW 19.1 COL 94.4 WIDGET-ID 130
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 132
     "     DDD:" VIEW-AS TEXT
          SIZE 40 BY 2.38 AT ROW 9.62 COL 31 WIDGET-ID 152
          FGCOLOR 1 FONT 13
     "    ATUALIZAÇÃO TELEFONE" VIEW-AS TEXT
          SIZE 122 BY 3.33 AT ROW 1.48 COL 21 WIDGET-ID 128
          FGCOLOR 1 FONT 13
     "Para continuar, tecle ENTRA" VIEW-AS TEXT
          SIZE 63.4 BY 1.67 AT ROW 24.81 COL 16 WIDGET-ID 154
          FGCOLOR 0 FONT 8
     "TELEFONE:" VIEW-AS TEXT
          SIZE 40 BY 2.05 AT ROW 12.91 COL 70 RIGHT-ALIGNED WIDGET-ID 150
          FGCOLOR 1 FONT 13
     RECT-3 AT ROW 9.57 COL 71.8 WIDGET-ID 136
     RECT-4 AT ROW 12.67 COL 71.8 WIDGET-ID 138
     RECT-2 AT ROW 24.1 COL 12 WIDGET-ID 160
     RECT-101 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-102 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-103 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-40 AT ROW 24.24 COL 156 WIDGET-ID 174
     IMAGE-41 AT ROW 19.24 COL 156 WIDGET-ID 176
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
  CREATE WINDOW w_cartao_atualiza_telefone ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.57
         WIDTH              = 160
         MAX-HEIGHT         = 34.33
         MAX-WIDTH          = 272.8
         VIRTUAL-HEIGHT     = 34.33
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
ASSIGN w_cartao_atualiza_telefone = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_cartao_atualiza_telefone
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_cartao_atualiza_telefone
   NOT-VISIBLE FRAME-NAME                                               */
ASSIGN 
       ed_mensagem:READ-ONLY IN FRAME f_cartao_atualiza_telefone        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-101 IN FRAME f_cartao_atualiza_telefone
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-102 IN FRAME f_cartao_atualiza_telefone
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-103 IN FRAME f_cartao_atualiza_telefone
   NO-ENABLE                                                            */
/* SETTINGS FOR TEXT-LITERAL "TELEFONE:"
          SIZE 40 BY 2.05 AT ROW 12.91 COL 70 RIGHT-ALIGNED             */

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_cartao_atualiza_telefone:HANDLE
       ROW             = 2.43
       COLUMN          = 10
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_atualiza_telefone */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_cartao_atualiza_telefone
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_atualiza_telefone w_cartao_atualiza_telefone
ON END-ERROR OF w_cartao_atualiza_telefone
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_atualiza_telefone w_cartao_atualiza_telefone
ON WINDOW-CLOSE OF w_cartao_atualiza_telefone
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f_cartao_atualiza_telefone
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f_cartao_atualiza_telefone w_cartao_atualiza_telefone
ON ANY-KEY OF FRAME f_cartao_atualiza_telefone
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_G
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_cartao_atualiza_telefone
ON ANY-KEY OF Btn_G IN FRAME f_cartao_atualiza_telefone /* CONTINUAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_cartao_atualiza_telefone
ON CHOOSE OF Btn_G IN FRAME f_cartao_atualiza_telefone /* CONTINUAR */
DO:

    /* Verifica se usuario informou o DDD */
    IF  LENGTH(ed_nr_doddd:SCREEN-VALUE) < 2 THEN DO:
        RUN mensagem.w (INPUT YES,
                        INPUT "    ATENÇÃO  ",
                        INPUT "",
                        INPUT "",
                        INPUT "DDD inválido.",
                        INPUT "",
                        INPUT "").

        PAUSE 3 NO-MESSAGE.
        h_mensagem:HIDDEN = YES.

        APPLY "ENTRY" TO ed_nr_doddd.

        aux_flgderro = YES.
    END.
    ELSE
    /* Verifica se usuario informou o Nr Telefone */
    IF  LENGTH(ed_nrdofone:SCREEN-VALUE) < 8 THEN DO:
        RUN mensagem.w (INPUT YES,
                        INPUT "    ATENÇÃO  ",
                        INPUT "",
                        INPUT "",
                        INPUT "Telefone inválido.",
                        INPUT "",
                        INPUT "").

        PAUSE 3 NO-MESSAGE.
        h_mensagem:HIDDEN = YES.

        aux_flgderro = YES.
    END.


    IF  aux_flgderro  THEN DO:
        aux_flgderro = NO.
        RETURN NO-APPLY.
    END.

    RUN cartao_atualiza_telefone_tipo.w ( INPUT ed_nr_doddd:SCREEN-VALUE
                                        , INPUT ed_nrdofone:SCREEN-VALUE
                                        ,OUTPUT par_continua).

    IF  NOT par_continua THEN DO:
        w_cartao_atualiza_telefone:MOVE-TO-TOP().
        RETURN NO-APPLY.
    END.
    ELSE
        RETURN "OK".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_atualiza_telefone
ON ANY-KEY OF Btn_H IN FRAME f_cartao_atualiza_telefone /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_atualiza_telefone
ON CHOOSE OF Btn_H IN FRAME f_cartao_atualiza_telefone /* VOLTAR */
DO:

    /* NAO DEIXAR SEGUIR A DIANTE SE CLICOU EM VOLTAR */
    par_continua = FALSE.


    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_nrdofone
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nrdofone w_cartao_atualiza_telefone
ON ANY-KEY OF ed_nrdofone IN FRAME f_cartao_atualiza_telefone
DO:
    RUN tecla.

    IF  KEY-FUNCTION(LASTKEY) = "G"  THEN
        DO:
            APPLY "CHOOSE" TO Btn_G.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            RUN limpa.
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


&Scoped-define SELF-NAME ed_nr_doddd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nr_doddd w_cartao_atualiza_telefone
ON ANY-KEY OF ed_nr_doddd IN FRAME f_cartao_atualiza_telefone
DO:
    RUN tecla.

    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN DO:
        IF  LENGTH(ed_nr_doddd:SCREEN-VALUE) < 2 THEN DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "    ATENÇÃO  ",
                            INPUT "",
                            INPUT "",
                            INPUT "DDD inválido.",
                            INPUT "",
                            INPUT "").

            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.

            APPLY "ENTRY" TO ed_nr_doddd.
            RETURN NO-APPLY.
        END.
        ELSE DO:
            APPLY "ENTRY" TO ed_nrdofone.
            RETURN NO-APPLY.
        END.
    END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            RUN limpa.
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
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_cartao_atualiza_telefone OCX.Tick
PROCEDURE temporizador.t_cartao_atualiza_telefone.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_cartao_atualiza_telefone.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_cartao_atualiza_telefone 


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
    FRAME f_cartao_atualiza_telefone:LOAD-MOUSE-POINTER("blank.cur").


    chtemporizador:t_cartao_atualiza_telefone:INTERVAL = glb_nrtempor.

    /* coloca o foco no DDD */
    APPLY "ENTRY" TO ed_nr_doddd.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_cartao_atualiza_telefone  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_atualiza_telefone.wrx":U ).
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
ELSE MESSAGE "cartao_atualiza_telefone.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_cartao_atualiza_telefone  _DEFAULT-DISABLE
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
  HIDE FRAME f_cartao_atualiza_telefone.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_cartao_atualiza_telefone  _DEFAULT-ENABLE
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
  DISPLAY ed_nr_doddd ed_nrdofone ed_mensagem 
      WITH FRAME f_cartao_atualiza_telefone.
  ENABLE RECT-3 RECT-4 RECT-2 IMAGE-40 IMAGE-41 ed_nr_doddd ed_nrdofone 
         ed_mensagem Btn_G Btn_H 
      WITH FRAME f_cartao_atualiza_telefone.
  {&OPEN-BROWSERS-IN-QUERY-f_cartao_atualiza_telefone}
  VIEW w_cartao_atualiza_telefone.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE limpa w_cartao_atualiza_telefone 
PROCEDURE limpa :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    ASSIGN  ed_nr_doddd:SCREEN-VALUE IN FRAME f_cartao_atualiza_telefone = ""
            ed_nrdofone:SCREEN-VALUE IN FRAME f_cartao_atualiza_telefone = "".

    APPLY "ENTRY" TO ed_nr_doddd.
    RETURN NO-APPLY.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_cartao_atualiza_telefone 
PROCEDURE tecla :
ASSIGN chtemporizador:t_cartao_atualiza_telefone:INTERVAL = 0.

    IF  KEY-FUNCTION(LASTKEY) = "G"                      AND
        Btn_G:SENSITIVE IN FRAME f_cartao_atualiza_telefone  THEN
        APPLY "CHOOSE" TO Btn_G.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                      AND
        Btn_H:SENSITIVE IN FRAME f_cartao_atualiza_telefone  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_cartao_atualiza_telefone:INTERVAL = glb_nrtempor.

    /* repassa o retorno */
    IF  RETURN-VALUE = "OK"  THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "OK".
        END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

