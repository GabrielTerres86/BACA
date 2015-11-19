&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_envelope_entrega
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_envelope_entrega 
/* ..............................................................................

Procedure: envelope_entrega.w
Objetivo : Tela para receber o envelope de depositos
Autor    : Evandro
Data     : Janeiro 2010

Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

                  16/06/2014 - Alterada mensagem de deposito de cheque/dinheiro.
                               (Reinert)

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
DEFINE  INPUT PARAM par_tpdtrans    AS INT          NO-UNDO.
DEFINE  INPUT PARAM par_nrdconta    AS INT          NO-UNDO.
DEFINE  INPUT PARAM par_vldinhei    AS DECIMAL      NO-UNDO.
DEFINE  INPUT PARAM par_vlcheque    AS DECIMAL      NO-UNDO.
DEFINE  INPUT PARAM par_agctltfn    AS INTEGER      NO-UNDO.
DEFINE OUTPUT PARAM par_nrdocmto    AS INT          NO-UNDO.
DEFINE OUTPUT PARAM par_dsprotoc    AS CHAR         NO-UNDO.
DEFINE OUTPUT PARAM par_flgderro    AS LOGICAL      NO-UNDO.

/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_envelope_entrega

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-101 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_envelope_entrega AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE RECTANGLE RECT-100
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 2 .

DEFINE RECTANGLE RECT-101
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 134 BY 16.91
     BGCOLOR 7 .

DEFINE RECTANGLE RECT-98
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-99
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_envelope_entrega
     "Não   coloque   moedas.  Coloque   o   dinheiro/cheque   no" VIEW-AS TEXT
          SIZE 129 BY 1.67 AT ROW 18.86 COL 17 WIDGET-ID 124
          BGCOLOR 7 FGCOLOR 14 FONT 8
     "ENTREGA DE ENVELOPE" VIEW-AS TEXT
          SIZE 108.4 BY 3.33 AT ROW 1.48 COL 26.8 WIDGET-ID 142
          FGCOLOR 1 FONT 10
     "IMPORTANTE!" VIEW-AS TEXT
          SIZE 49 BY 1.67 AT ROW 10.52 COL 57 WIDGET-ID 110
          BGCOLOR 7 FGCOLOR 14 FONT 13
     "envelope sem dobrar." VIEW-AS TEXT
          SIZE 129 BY 1.67 AT ROW 20.76 COL 17 WIDGET-ID 126
          BGCOLOR 7 FGCOLOR 14 FONT 8
     "FAVOR INSERIR O ENVELOPE!" VIEW-AS TEXT
          SIZE 110 BY 1.67 AT ROW 24.33 COL 25 WIDGET-ID 128
          BGCOLOR 7 FGCOLOR 14 FONT 13
     "Havendo divergência entre o valor informado e  o  conteúdo" VIEW-AS TEXT
          SIZE 129 BY 1.67 AT ROW 13.14 COL 17 WIDGET-ID 112
          BGCOLOR 7 FGCOLOR 14 FONT 8
     "do envelope, o depósito será feito pelo valor  apurado  pela" VIEW-AS TEXT
          SIZE 129 BY 1.67 AT ROW 15.05 COL 17 WIDGET-ID 120
          BGCOLOR 7 FGCOLOR 14 FONT 8
     "cooperativa." VIEW-AS TEXT
          SIZE 129 BY 1.67 AT ROW 16.95 COL 17 WIDGET-ID 122
          BGCOLOR 7 FGCOLOR 14 FONT 8
     RECT-101 AT ROW 9.81 COL 14 WIDGET-ID 108
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 140
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 116
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
  CREATE WINDOW w_envelope_entrega ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.57
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
ASSIGN w_envelope_entrega = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_envelope_entrega
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_envelope_entrega
   FRAME-NAME                                                           */
/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_envelope_entrega
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_envelope_entrega
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_envelope_entrega
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_envelope_entrega
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_envelope_entrega w_envelope_entrega
ON END-ERROR OF w_envelope_entrega
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_envelope_entrega w_envelope_entrega
ON WINDOW-CLOSE OF w_envelope_entrega
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_envelope_entrega 


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
    FRAME f_envelope_entrega:LOAD-MOUSE-POINTER("blank.cur").

    RUN procedures/entrega_envelope.p ( INPUT par_tpdtrans,
                                        INPUT par_nrdconta,
                                        INPUT par_vldinhei,
                                        INPUT par_vlcheque,
                                        INPUT par_agctltfn, 
                                       OUTPUT par_nrdocmto,
                                       OUTPUT par_dsprotoc,
                                       OUTPUT par_flgderro).

    /* puxa o frame principal pra frente */
    h_principal:MOVE-TO-TOP().

    IF  par_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "NOK".
        END.
    ELSE
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "OK".
        END.    
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_envelope_entrega  _DEFAULT-DISABLE
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
  HIDE FRAME f_envelope_entrega.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_envelope_entrega  _DEFAULT-ENABLE
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
  ENABLE RECT-101 
      WITH FRAME f_envelope_entrega.
  {&OPEN-BROWSERS-IN-QUERY-f_envelope_entrega}
  VIEW w_envelope_entrega.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

