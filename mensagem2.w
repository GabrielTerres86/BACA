&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_mensagem2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_mensagem2 
/* ..............................................................................

Procedure: mensagem2.w
Objetivo : Tela para exibir as mensagens  maiores do sistema
Autor    : Jorge
Data     : Abril 2015

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
DEFINE  INPUT PARAM par_flgderro    AS LOGICAL      NO-UNDO.
DEFINE  INPUT PARAM par_tlmensag    AS CHARACTER    NO-UNDO.
DEFINE  INPUT PARAM par_dsmensag1   AS CHARACTER    NO-UNDO.
DEFINE  INPUT PARAM par_dsmensag2   AS CHARACTER    NO-UNDO.
DEFINE  INPUT PARAM par_dsmensag3   AS CHARACTER    NO-UNDO.
DEFINE  INPUT PARAM par_dsmensag4   AS CHARACTER    NO-UNDO.
DEFINE  INPUT PARAM par_dsmensag5   AS CHARACTER    NO-UNDO.

DEFINE  VARIABLE aux_qtcaract       AS INTEGER      NO-UNDO.

/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }

/* Handle para a mensagem com grande conteudo ao usuario */
DEFINE  VAR h_mensagem2             AS HANDLE       NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_mensagem2

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-2 RECT-3 ed_tlmensag ed_dsmensag1 ~
ed_dsmensag2 ed_dsmensag3 ed_dsmensag4 ed_dsmensag5 
&Scoped-Define DISPLAYED-OBJECTS ed_tlmensag ed_dsmensag1 ed_dsmensag2 ~
ed_dsmensag3 ed_dsmensag4 ed_dsmensag5 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_mensagem2 AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE VARIABLE ed_dsmensag1 AS CHARACTER FORMAT "X(42)":U 
      VIEW-AS TEXT 
     SIZE 95 BY .95
     FGCOLOR 12 FONT 11 NO-UNDO.

DEFINE VARIABLE ed_dsmensag2 AS CHARACTER FORMAT "X(42)":U 
      VIEW-AS TEXT 
     SIZE 95 BY .95
     FGCOLOR 12 FONT 11 NO-UNDO.

DEFINE VARIABLE ed_dsmensag3 AS CHARACTER FORMAT "X(42)":U 
      VIEW-AS TEXT 
     SIZE 95 BY .95
     FGCOLOR 12 FONT 11 NO-UNDO.

DEFINE VARIABLE ed_dsmensag4 AS CHARACTER FORMAT "X(42)":U 
      VIEW-AS TEXT 
     SIZE 95 BY .95
     FGCOLOR 12 FONT 11 DROP-TARGET NO-UNDO.

DEFINE VARIABLE ed_dsmensag5 AS CHARACTER FORMAT "X(42)":U 
      VIEW-AS TEXT 
     SIZE 95 BY .95
     FGCOLOR 12 FONT 11 NO-UNDO.

DEFINE VARIABLE ed_tlmensag AS CHARACTER FORMAT "X(42)":U 
      VIEW-AS TEXT 
     SIZE 95 BY 3.1
     FGCOLOR 12 FONT 10 NO-UNDO.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 99 BY 10.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 97 BY 9.52.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_mensagem2
     ed_tlmensag AT ROW 1.48 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 12 NO-TAB-STOP 
     ed_dsmensag1 AT ROW 4.81 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 16 NO-TAB-STOP 
     ed_dsmensag2 AT ROW 6 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 18 NO-TAB-STOP 
     ed_dsmensag3 AT ROW 7.19 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 20 NO-TAB-STOP 
     ed_dsmensag4 AT ROW 8.38 COL 3 NO-LABEL WIDGET-ID 22 NO-TAB-STOP 
     ed_dsmensag5 AT ROW 9.48 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 24 NO-TAB-STOP 
     RECT-2 AT ROW 1 COL 1 WIDGET-ID 8
     RECT-3 AT ROW 1.24 COL 2 WIDGET-ID 10
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 31.6 ROW 10.29
         SIZE 99.2 BY 10.05 WIDGET-ID 100.


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
  CREATE WINDOW w_mensagem2 ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.57
         WIDTH              = 160
         MAX-HEIGHT         = 28.57
         MAX-WIDTH          = 160
         VIRTUAL-HEIGHT     = 28.57
         VIRTUAL-WIDTH      = 160
         SHOW-IN-TASKBAR    = no
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
ASSIGN w_mensagem2 = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_mensagem2
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_mensagem2
   FRAME-NAME                                                           */
ASSIGN 
       ed_dsmensag1:READ-ONLY IN FRAME f_mensagem2        = TRUE.

ASSIGN 
       ed_dsmensag2:READ-ONLY IN FRAME f_mensagem2        = TRUE.

ASSIGN 
       ed_dsmensag3:READ-ONLY IN FRAME f_mensagem2        = TRUE.

/* SETTINGS FOR FILL-IN ed_dsmensag4 IN FRAME f_mensagem2
   ALIGN-L                                                              */
ASSIGN 
       ed_dsmensag4:READ-ONLY IN FRAME f_mensagem2        = TRUE.

ASSIGN 
       ed_dsmensag5:READ-ONLY IN FRAME f_mensagem2        = TRUE.

ASSIGN 
       ed_tlmensag:READ-ONLY IN FRAME f_mensagem2        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_mensagem2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_mensagem2 w_mensagem2
ON END-ERROR OF w_mensagem2
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_mensagem2 w_mensagem2
ON WINDOW-CLOSE OF w_mensagem2
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_mensagem2 


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}
       h_mensagem2                   = FRAME f_mensagem2:HANDLE.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

RUN enable_UI.

/* deixa o mouse transparente */
FRAME f_mensagem2:LOAD-MOUSE-POINTER("blank.cur").

IF   par_flgderro   THEN
     /* vermelho */
     ASSIGN ed_tlmensag:FGCOLOR  = 12
            ed_dsmensag1:FGCOLOR = 12
            ed_dsmensag2:FGCOLOR = 12
            ed_dsmensag3:FGCOLOR = 12
            ed_dsmensag4:FGCOLOR = 12
            ed_dsmensag5:FGCOLOR = 12.
ELSE
     /* azul */
     ASSIGN ed_tlmensag:FGCOLOR  = 1
            ed_dsmensag1:FGCOLOR = 1
            ed_dsmensag2:FGCOLOR = 1
            ed_dsmensag3:FGCOLOR = 1
            ed_dsmensag4:FGCOLOR = 1
            ed_dsmensag5:FGCOLOR = 1.


ed_tlmensag:SCREEN-VALUE = par_tlmensag.

/* qtd de caracteres que cabe na linha */
ASSIGN aux_qtcaract = 42.

/* verifica se veio uma mensagem maior que 30 caracteres em uma das linhas e quebra ela */
IF  par_dsmensag1 <> "" AND LENGTH(par_dsmensag1) > aux_qtcaract  THEN
    RUN quebra_msg (INPUT par_dsmensag1).
ELSE
IF  par_dsmensag2 <> "" AND LENGTH(par_dsmensag2) > aux_qtcaract  THEN
    RUN quebra_msg (INPUT par_dsmensag2).
ELSE
IF  par_dsmensag3 <> "" AND LENGTH(par_dsmensag3) > aux_qtcaract  THEN
    RUN quebra_msg (INPUT par_dsmensag3).
ELSE
IF  par_dsmensag4 <> "" AND LENGTH(par_dsmensag4) > aux_qtcaract  THEN
    RUN quebra_msg (INPUT par_dsmensag4).
ELSE
IF  par_dsmensag5 <> "" AND LENGTH(par_dsmensag5) > aux_qtcaract  THEN
    RUN quebra_msg (INPUT par_dsmensag5).





/* centraliza o texto de cada linha */
ASSIGN par_dsmensag1 = FILL(" ",INT((aux_qtcaract - LENGTH(par_dsmensag1)) / 2)) + par_dsmensag1
       par_dsmensag2 = FILL(" ",INT((aux_qtcaract - LENGTH(par_dsmensag2)) / 2)) + par_dsmensag2
       par_dsmensag3 = FILL(" ",INT((aux_qtcaract - LENGTH(par_dsmensag3)) / 2)) + par_dsmensag3
       par_dsmensag4 = FILL(" ",INT((aux_qtcaract - LENGTH(par_dsmensag4)) / 2)) + par_dsmensag4
       par_dsmensag5 = FILL(" ",INT((aux_qtcaract - LENGTH(par_dsmensag5)) / 2)) + par_dsmensag5.


/* alimenta a mensagem de erro, cada linha pode ter 30 caracteres */
ed_dsmensag1:SCREEN-VALUE = par_dsmensag1.
ed_dsmensag2:SCREEN-VALUE = par_dsmensag2.
ed_dsmensag3:SCREEN-VALUE = par_dsmensag3.
ed_dsmensag4:SCREEN-VALUE = par_dsmensag4.
ed_dsmensag5:SCREEN-VALUE = par_dsmensag5.


PAUSE 15 NO-MESSAGE.
h_mensagem2:HIDDEN = YES.
HIDE FRAME f_mensagem2.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_mensagem2  _DEFAULT-DISABLE
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
  HIDE FRAME f_mensagem2.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_mensagem2  _DEFAULT-ENABLE
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
  DISPLAY ed_tlmensag ed_dsmensag1 ed_dsmensag2 ed_dsmensag3 ed_dsmensag4 
          ed_dsmensag5 
      WITH FRAME f_mensagem2.
  ENABLE RECT-2 RECT-3 ed_tlmensag ed_dsmensag1 ed_dsmensag2 ed_dsmensag3 
         ed_dsmensag4 ed_dsmensag5 
      WITH FRAME f_mensagem2.
  {&OPEN-BROWSERS-IN-QUERY-f_mensagem2}
  VIEW w_mensagem2.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE quebra_msg w_mensagem2 
PROCEDURE quebra_msg :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAM  par_msg         AS CHAR     NO-UNDO.

DEFINE VARIABLE     tmp_msg         AS CHAR     NO-UNDO.
DEFINE VARIABLE     tmp_indice      AS INT      NO-UNDO.


/* limpa as mensgens para poder colocar elas ja quebradas */
ASSIGN par_dsmensag1 = ""
       par_dsmensag2 = ""
       par_dsmensag3 = ""
       par_dsmensag4 = ""
       par_dsmensag5 = ""
       par_msg       = par_msg + " ".


DO  WHILE TRUE:


    ASSIGN /* comeca do caractere 1 */
           tmp_indice = 1
           /* pega os aux_qtcaract caracteres */
           tmp_msg    = SUBSTRING(par_msg,tmp_indice,aux_qtcaract)
           /* volta ate a ultima palavra completa */
           tmp_indice = R-INDEX(tmp_msg," ") - 1
           /* separa ate a ultima palavra completa */
           tmp_msg    = SUBSTRING(tmp_msg,1,tmp_indice)
           /* guarda o que sobrou */
           par_msg    = SUBSTRING(par_msg,tmp_indice + 2).


    /* preenche cada linha */
    IF  par_dsmensag1 = ""  THEN
        par_dsmensag1 = tmp_msg.
    ELSE
    IF  par_dsmensag2 = ""  THEN
        par_dsmensag2 = tmp_msg.
    ELSE
    IF  par_dsmensag3 = ""  THEN
        par_dsmensag3 = tmp_msg.
    ELSE
    IF  par_dsmensag4 = ""  THEN
        par_dsmensag4 = tmp_msg.
    ELSE
    IF  par_dsmensag5 = ""  THEN
        par_dsmensag5 = tmp_msg.

    IF  tmp_indice = -1  THEN
        LEAVE.

END. /* Fim WHILE */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

