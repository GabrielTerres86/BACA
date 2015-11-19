&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_impressao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_impressao 
/* ..............................................................................

Procedure: impressao.w
Objetivo : Tela para montar os comprovantes de impressao
Autor    : Evandro
Data     : Janeiro 2010

Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

                  13/10/2014 - Incluir mensagem para retirada de papel da
                                               impressora (David).

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
DEFINE INPUT PARAM  par_dsdocmto    AS CHAR                     NO-UNDO.
DEFINE INPUT PARAM  par_tximpres    AS CHAR                     NO-UNDO.


/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }
{ includes/var_xfs_lite.i }

DEFINE VARIABLE     aux_contador    AS INTEGER                  NO-UNDO.
DEFINE VARIABLE     imp_dadosimp    AS MEMPTR                   NO-UNDO.
DEFINE VARIABLE     aux_flgderro    AS LOGICAL                  NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_impressao

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_impressao AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE VARIABLE ed_impressao AS CHARACTER 
     VIEW-AS EDITOR NO-WORD-WRAP
     SIZE 69 BY 27.38
     BGCOLOR 15 FONT 0 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_impressao
     ed_impressao AT ROW 1 COL 1 NO-LABEL WIDGET-ID 2
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 46.8 ROW 1.62
         SIZE 69.2 BY 27.43 WIDGET-ID 100.


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
  CREATE WINDOW w_impressao ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.57
         WIDTH              = 160
         MAX-HEIGHT         = 29.05
         MAX-WIDTH          = 184.8
         VIRTUAL-HEIGHT     = 29.05
         VIRTUAL-WIDTH      = 184.8
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
ASSIGN w_impressao = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_impressao
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_impressao
   NOT-VISIBLE FRAME-NAME                                               */
/* SETTINGS FOR EDITOR ed_impressao IN FRAME f_impressao
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       ed_impressao:HIDDEN IN FRAME f_impressao           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_impressao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_impressao w_impressao
ON END-ERROR OF w_impressao
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_impressao w_impressao
ON WINDOW-CLOSE OF w_impressao
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_impressao 


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

RUN enable_UI.

/* deixa o mouse transparente */
FRAME f_impressao:LOAD-MOUSE-POINTER("blank.cur").

/* monta o editor */
DO  aux_contador = 1 TO LENGTH(par_tximpres) BY 48:
    ed_impressao:INSERT-STRING(SUBSTRING(par_tximpres,aux_contador,48) + CHR(13)).
END.


IF  NOT xfs_painop_em_uso  THEN
    DO:
        RUN mensagem.w (INPUT NO,
                        INPUT " IMPRIMINDO",
                        INPUT "",
                        INPUT "",
                        INPUT par_dsdocmto,
                        INPUT "",
                        INPUT "").
        
        PAUSE 3 NO-MESSAGE.
        h_mensagem:HIDDEN = YES.
    END.


IF  xfs_impressora       AND
    NOT xfs_impsempapel  THEN
    DO:
        SET-SIZE(imp_dadosimp) = LENGTH(ed_impressao:SCREEN-VALUE) + 1.
         
        PUT-STRING(imp_dadosimp,1) = ed_impressao:SCREEN-VALUE + CHR(0).

        RUN WinImprimePrtCh IN aux_xfsliteh 
            (INPUT  0,
             INPUT  GET-POINTER-VALUE(imp_dadosimp),
             INPUT  LENGTH(ed_impressao:SCREEN-VALUE) + 1,
             OUTPUT LT_Resp).
         
        SET-SIZE(imp_dadosimp) = 0.
         
        IF  LT_Resp <> 0  THEN
            DO: 
                IF  NOT xfs_painop_em_uso  THEN
                    DO:
                        RUN mensagem.w (INPUT YES,
                                        INPUT "   ATENÇÃO",
                                        INPUT "",
                                        INPUT "",
                                        INPUT "Erro na impressão.",
                                        INPUT "",
                                        INPUT "").
                        
                        PAUSE 3 NO-MESSAGE.
                        h_mensagem:HIDDEN = YES.
                    END.
            END.
         ELSE
            DO:
                RUN WinCutPrtCh IN aux_xfsliteh (OUTPUT LT_Resp).

                IF  LT_Resp <> 0  THEN
                    DO: 
                        IF  NOT xfs_painop_em_uso  THEN
                            DO:
                                RUN mensagem.w (INPUT YES,
                                                INPUT "   ATENÇÃO",
                                                INPUT "",
                                                INPUT "",
                                                INPUT "Erro no corte do papel.",
                                                INPUT "",
                                                INPUT "").
                                
                                PAUSE 3 NO-MESSAGE.
                                h_mensagem:HIDDEN = YES.
                            END.
                    END.
                ELSE
                                IF  NOT xfs_painop_em_uso  THEN
                    DO:
                        aux_contador = 0.

                        DO WHILE TRUE:

                            IF  aux_contador = 5  THEN
                                DO:
                                    h_mensagem:HIDDEN = YES.
                                    LEAVE.
                                END.

                            IF  aux_contador = 0  THEN
                                RUN mensagem.w (INPUT NO,
                                                INPUT "   ATENÇÃO",
                                                INPUT "",
                                                INPUT "",
                                                INPUT "Retire o papel da impressão.",
                                                INPUT "",
                                                INPUT "").

                            RUN procedures/inicializa_dispositivo.p (INPUT 6,
                                                         OUTPUT aux_flgderro).

                            IF  NOT xfs_imppapelsaida  THEN
                                DO:
                                    h_mensagem:HIDDEN = YES.
                                    LEAVE.
                                END.
                            ELSE
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    aux_contador = aux_contador + 1.
                                    NEXT.
                                END.

                        END.
                    END.
            END.
    END.

APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
RETURN "OK".

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_impressao  _DEFAULT-DISABLE
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
  HIDE FRAME f_impressao.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_impressao  _DEFAULT-ENABLE
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
  {&OPEN-BROWSERS-IN-QUERY-f_impressao}
  VIEW w_impressao.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

