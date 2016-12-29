&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_cartao_atualiza_telefone_pre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_cartao_atualiza_telefone_pre 
/* ..............................................................................

Procedure: cartao_atualiza_telefone_pre.w
Objetivo : Tela intermediaria para informar/confirmar telefone
Autor    : Guilherme/SUPERO
Data     : Novembro/2016

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

DEFINE INPUT  PARAM par_fltemfon       AS LOGICAL                    NO-UNDO.
DEFINE INPUT  PARAM par_nrdofone       AS CHAR                       NO-UNDO.
DEFINE OUTPUT PARAM par_continua       AS LOGICAL     INIT FALSE     NO-UNDO.

DEFINE VARIABLE aux_flgderro        AS LOGICAL              NO-UNDO.
DEFINE VARIABLE aux_flagsair        AS LOGICAL              NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_cartao_atualiza_telefone_pre

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-40 IMAGE-43 RECT-104 ed_mensagem_1 ~
ed_mensagem_2 ed_mensagem_3 Btn_D Btn_H 
&Scoped-Define DISPLAYED-OBJECTS ed_mensagem_1 ed_mensagem_2 ed_mensagem_3 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-2 ed_mensagem_2 ed_mensagem_3 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_cartao_atualiza_telefone_pre AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_D 
     LABEL "" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_H AUTO-END-KEY 
     LABEL "" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_mensagem_1 AS CHARACTER 
     VIEW-AS EDITOR NO-BOX
     SIZE 130 BY 1.57
     BGCOLOR 15 FGCOLOR 1 FONT 8 NO-UNDO.

DEFINE VARIABLE ed_mensagem_2 AS CHARACTER 
     VIEW-AS EDITOR NO-BOX
     SIZE 130 BY 1.57
     BGCOLOR 15 FGCOLOR 1 FONT 8 NO-UNDO.

DEFINE VARIABLE ed_mensagem_3 AS CHARACTER 
     VIEW-AS EDITOR NO-BOX
     SIZE 130 BY 2
     BGCOLOR 15 FGCOLOR 1 FONT 15 NO-UNDO.

DEFINE IMAGE IMAGE-40
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-43
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
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

DEFINE RECTANGLE RECT-104
     EDGE-PIXELS 2 GRAPHIC-EDGE   GROUP-BOX  ROUNDED 
     SIZE 132 BY 5.48.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_cartao_atualiza_telefone_pre
     ed_mensagem_1 AT ROW 10 COL 146 RIGHT-ALIGNED NO-LABEL WIDGET-ID 198 NO-TAB-STOP 
     ed_mensagem_2 AT ROW 11.52 COL 146 RIGHT-ALIGNED NO-LABEL WIDGET-ID 188 NO-TAB-STOP 
     ed_mensagem_3 AT ROW 13.1 COL 146 RIGHT-ALIGNED NO-LABEL WIDGET-ID 192 NO-TAB-STOP 
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 194
     Btn_H AT ROW 24.29 COL 94.4 WIDGET-ID 196
     "    ATUALIZAÇÃO TELEFONE" VIEW-AS TEXT
          SIZE 124 BY 3.33 AT ROW 1.48 COL 19 WIDGET-ID 128
          FGCOLOR 1 FONT 13
     RECT-101 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-102 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-103 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-40 AT ROW 24.24 COL 156 WIDGET-ID 200
     IMAGE-43 AT ROW 24.24 COL 1 WIDGET-ID 202
     RECT-104 AT ROW 9.81 COL 16 WIDGET-ID 190
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
  CREATE WINDOW w_cartao_atualiza_telefone_pre ASSIGN
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
ASSIGN w_cartao_atualiza_telefone_pre = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_cartao_atualiza_telefone_pre
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_cartao_atualiza_telefone_pre
   NOT-VISIBLE FRAME-NAME                                               */
/* SETTINGS FOR EDITOR ed_mensagem_1 IN FRAME f_cartao_atualiza_telefone_pre
   ALIGN-R                                                              */
ASSIGN 
       ed_mensagem_1:AUTO-INDENT IN FRAME f_cartao_atualiza_telefone_pre      = TRUE
       ed_mensagem_1:READ-ONLY IN FRAME f_cartao_atualiza_telefone_pre        = TRUE.

/* SETTINGS FOR EDITOR ed_mensagem_2 IN FRAME f_cartao_atualiza_telefone_pre
   ALIGN-R 2                                                            */
ASSIGN 
       ed_mensagem_2:AUTO-INDENT IN FRAME f_cartao_atualiza_telefone_pre      = TRUE
       ed_mensagem_2:READ-ONLY IN FRAME f_cartao_atualiza_telefone_pre        = TRUE.

/* SETTINGS FOR EDITOR ed_mensagem_3 IN FRAME f_cartao_atualiza_telefone_pre
   ALIGN-R 2                                                            */
ASSIGN 
       ed_mensagem_3:AUTO-INDENT IN FRAME f_cartao_atualiza_telefone_pre      = TRUE
       ed_mensagem_3:READ-ONLY IN FRAME f_cartao_atualiza_telefone_pre        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-101 IN FRAME f_cartao_atualiza_telefone_pre
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-102 IN FRAME f_cartao_atualiza_telefone_pre
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-103 IN FRAME f_cartao_atualiza_telefone_pre
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_cartao_atualiza_telefone_pre:HANDLE
       ROW             = 2.43
       COLUMN          = 10
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_atualiza_telefone_pre */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_cartao_atualiza_telefone_pre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_atualiza_telefone_pre w_cartao_atualiza_telefone_pre
ON END-ERROR OF w_cartao_atualiza_telefone_pre
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_atualiza_telefone_pre w_cartao_atualiza_telefone_pre
ON WINDOW-CLOSE OF w_cartao_atualiza_telefone_pre
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f_cartao_atualiza_telefone_pre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f_cartao_atualiza_telefone_pre w_cartao_atualiza_telefone_pre
ON ANY-KEY OF FRAME f_cartao_atualiza_telefone_pre
DO:
  RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_atualiza_telefone_pre
ON ANY-KEY OF Btn_D IN FRAME f_cartao_atualiza_telefone_pre
DO:
  RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_atualiza_telefone_pre
ON CHOOSE OF Btn_D IN FRAME f_cartao_atualiza_telefone_pre
DO:
    /* LEMBRAR MAIS TARDE */
    /* CONFIRMAR          */
    par_continua = TRUE.

    IF Btn_D:LABEL = 'CONFIRMAR' THEN DO:

        RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).
        
        IF  NOT aux_flgderro  THEN DO:
            /* puxa o frame principal pra frente */
            h_principal:MOVE-TO-TOP().

            RUN procedures/atualiza_data_telefone.p (OUTPUT aux_flgderro).

            IF  aux_flgderro   THEN DO:
                w_cartao_atualiza_telefone_pre:MOVE-TO-TOP().

                par_continua = FALSE. /* SE DEU ERRO, NAO SEGUE ?? */
        
                APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                RETURN NO-APPLY. /* "NOK". */
            END.
            ELSE DO:
                w_cartao_atualiza_telefone_pre:MOVE-TO-TOP().

                APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                RETURN NO-APPLY. /* "NOK". */
            END.
        
        END.
        ELSE DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY. /* "OK". */
        END.     

    END.
    
    /** Quando LEMBRAR MAIS TARDE, nao faz nada, apenas fecha a tela atual */

    /** APENAS ENVIA COMANDO PARA RETORNAR PARA TELA ANTERIOR */
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
    RETURN NO-APPLY. /*"OK".*/ /* "NOK". */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_atualiza_telefone_pre
ON ANY-KEY OF Btn_H IN FRAME f_cartao_atualiza_telefone_pre
DO:
  RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_atualiza_telefone_pre
ON CHOOSE OF Btn_H IN FRAME f_cartao_atualiza_telefone_pre
DO:
    /* CADASTRAR */
    /* ATUALIZAR */

    /* SE O INTERVAL DO TEMPORIZADOR É DIFERENTE DE ZERO, É PQ VEIO 
       PELO ESTOURO DO TEMPO DO INTERVALO, FALSE
       SE FOR ZERO, É PQ CLICOU NO BOTAO, ENTAO, CONTINUA, TRUE     */
    par_continua = (chtemporizador:t_cartao_atualiza_telefone_pre:INTERVAL = 0).

    /* Se foi por CLIQUE chama tela atualizacao telefone.
       Caso contrario, apenas fecha a tela e retorna.   */
    IF  par_continua THEN DO:

        RUN cartao_atualiza_telefone.w (OUTPUT par_continua).

    END.

    IF  NOT par_continua THEN DO:
        w_cartao_atualiza_telefone_pre:MOVE-TO-TOP().
        RETURN NO-APPLY.
    END.
    ELSE
        APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.

    RETURN NO-APPLY. /* "NOK". */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_cartao_atualiza_telefone_pre OCX.Tick
PROCEDURE temporizador.t_cartao_atualiza_telefone_pre.Tick .
/* APPLY "CHOOSE" TO Btn_H IN FRAME f_cartao_atualiza_telefone_pre. */

    
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_cartao_atualiza_telefone_pre 


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
    FRAME f_cartao_atualiza_telefone_pre:LOAD-MOUSE-POINTER("blank.cur").

    chtemporizador:t_cartao_atualiza_telefone_pre:INTERVAL = glb_nrtempor.

    IF  par_fltemfon THEN DO:
        /** Tem telefone */
        ed_mensagem_1:SCREEN-VALUE = "Cooperado, seu número de telefone precisa ser atualizado.".
        ed_mensagem_2:SCREEN-VALUE = FILL(" ",34) + "Seu número atual é o ".
        ed_mensagem_3:SCREEN-VALUE = FILL(" ",8) + par_nrdofone + " ?".

        Btn_D:LABEL = 'CONFIRMAR'.
        Btn_H:LABEL = 'ATUALIZAR'.
    END.
    ELSE DO:
        /** NAO Tem telefone */
        ed_mensagem_1:SCREEN-VALUE = "Cooperado,".
        ed_mensagem_2:SCREEN-VALUE = "você não possui nenhum número de telefone cadastrado.".
        ed_mensagem_3:SCREEN-VALUE = "".

        Btn_D:LABEL = 'LEMBRAR MAIS TARDE'.
        Btn_H:LABEL = 'CADASTRAR'.
    END.

    /* coloca o foco no botao H */
    APPLY "ENTRY" TO Btn_H.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_cartao_atualiza_telefone_pre  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_atualiza_telefone_pre.wrx":U ).
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
ELSE MESSAGE "cartao_atualiza_telefone_pre.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_cartao_atualiza_telefone_pre  _DEFAULT-DISABLE
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
  HIDE FRAME f_cartao_atualiza_telefone_pre.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_cartao_atualiza_telefone_pre  _DEFAULT-ENABLE
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
  DISPLAY ed_mensagem_1 ed_mensagem_2 ed_mensagem_3 
      WITH FRAME f_cartao_atualiza_telefone_pre.
  ENABLE IMAGE-40 IMAGE-43 RECT-104 ed_mensagem_1 ed_mensagem_2 ed_mensagem_3 
         Btn_D Btn_H 
      WITH FRAME f_cartao_atualiza_telefone_pre.
  {&OPEN-BROWSERS-IN-QUERY-f_cartao_atualiza_telefone_pre}
  VIEW w_cartao_atualiza_telefone_pre.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE limpa w_cartao_atualiza_telefone_pre 
PROCEDURE limpa :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_cartao_atualiza_telefone_pre 
PROCEDURE tecla :
ASSIGN chtemporizador:t_cartao_atualiza_telefone_pre:INTERVAL = 0
           aux_flagsair = NO.

    /* ---------- */
    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).
    
    IF  aux_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.

    IF  KEY-FUNCTION(LASTKEY) = "D"               AND
        Btn_D:SENSITIVE IN FRAME f_cartao_atualiza_telefone_pre  THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"               AND
        Btn_H:SENSITIVE IN FRAME f_cartao_atualiza_telefone_pre  THEN
        DO:
            aux_flagsair = YES.
            APPLY "CHOOSE" TO Btn_H.
        END.
    ELSE
        RETURN NO-APPLY.


    chtemporizador:t_cartao_atualiza_telefone_pre:INTERVAL = glb_nrtempor.


    /* Se utilizou alguma opcao, fecha a tela */
    IF  RETURN-VALUE = "OK"  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        DO:
            /* joga o frame frente */
            FRAME f_cartao_atualiza_telefone_pre:MOVE-TO-TOP().

            APPLY "ENTRY" TO Btn_H.
        END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE valida_grava_telefone w_cartao_atualiza_telefone_pre 
PROCEDURE valida_grava_telefone :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEF INPUT PARAM par_nrdddfon AS INTE NO-UNDO.
DEF INPUT PARAM par_nrtelefo AS INTE NO-UNDO.
DEF INPUT PARAM par_tptelefo AS INTE NO-UNDO.



    
RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

