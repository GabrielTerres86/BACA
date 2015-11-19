&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_config
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_config 
/* ..............................................................................

Procedure: config.w
Objetivo : Tela de configuração do TAA
Autor    : Evandro
Data     : Janeiro 2010

Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

                  07/11/2013 - Alterado Posto de Atendimento ao Cooperado para
                               Posto de Atendimento "PA". (Jorge)

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
{ includes/var_taa.i "NEW" }

DEFINE VARIABLE aux_nmdohost        AS CHAR         NO-UNDO.
DEFINE VARIABLE aux_ipdohost        AS CHAR         NO-UNDO.

DEFINE VARIABLE aux_flgderro        AS LOGICAL      NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_config

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ed_cdcoptfn ed_nrterfin ed_cdagetfn ~
ed_ipterfin ed_nmserver ed_nmservic ed_tpleitor ed_tpenvelo Btn_salvar ~
Btn_fechar 
&Scoped-Define DISPLAYED-OBJECTS ed_cdcoptfn ed_nrterfin ed_cdagetfn ~
ed_ipterfin ed_nmserver ed_nmservic ed_tpleitor ed_tpenvelo 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_config AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_fechar 
     LABEL "Fechar" 
     SIZE 20 BY 2.14
     FONT 14.

DEFINE BUTTON Btn_salvar 
     LABEL "Salvar" 
     SIZE 20 BY 2.14
     FONT 14.

DEFINE VARIABLE ed_cdagetfn AS INTEGER FORMAT "zz9":U INITIAL 999 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1.67
     BGCOLOR 15 FONT 8 NO-UNDO.

DEFINE VARIABLE ed_cdcoptfn AS INTEGER FORMAT "zz9":U INITIAL 999 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1.67
     BGCOLOR 15 FONT 8 NO-UNDO.

DEFINE VARIABLE ed_ipterfin AS CHARACTER FORMAT "X(15)":U INITIAL "999.999.999.999" 
     VIEW-AS FILL-IN 
     SIZE 36 BY 1.67
     FONT 8 NO-UNDO.

DEFINE VARIABLE ed_nmserver AS CHARACTER FORMAT "X(15)":U INITIAL "servidor" 
     VIEW-AS FILL-IN 
     SIZE 36 BY 1.67
     BGCOLOR 15 FONT 8 NO-UNDO.

DEFINE VARIABLE ed_nmservic AS CHARACTER FORMAT "X(15)":U INITIAL "serviço" 
     VIEW-AS FILL-IN 
     SIZE 36 BY 1.67
     BGCOLOR 15 FONT 8 NO-UNDO.

DEFINE VARIABLE ed_nrterfin AS INTEGER FORMAT "zz9":U INITIAL 999 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1.67
     BGCOLOR 15 FONT 8 NO-UNDO.

DEFINE VARIABLE ed_tpenvelo AS INTEGER FORMAT "9":U INITIAL 9 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1.67
     BGCOLOR 15 FONT 8 NO-UNDO.

DEFINE VARIABLE ed_tpleitor AS INTEGER FORMAT "9":U INITIAL 9 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1.67
     BGCOLOR 15 FONT 8 NO-UNDO.

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

DEFINE FRAME f_config
     ed_cdcoptfn AT ROW 10.52 COL 39 COLON-ALIGNED NO-LABEL WIDGET-ID 14 AUTO-RETURN 
     ed_nrterfin AT ROW 10.52 COL 114 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     ed_cdagetfn AT ROW 12.67 COL 39 COLON-ALIGNED NO-LABEL WIDGET-ID 22
     ed_ipterfin AT ROW 12.67 COL 114 COLON-ALIGNED NO-LABEL WIDGET-ID 26 NO-TAB-STOP 
     ed_nmserver AT ROW 14.81 COL 39 COLON-ALIGNED NO-LABEL WIDGET-ID 30
     ed_nmservic AT ROW 14.81 COL 114 COLON-ALIGNED NO-LABEL WIDGET-ID 34
     ed_tpleitor AT ROW 17.91 COL 39 COLON-ALIGNED NO-LABEL WIDGET-ID 38
     ed_tpenvelo AT ROW 17.91 COL 114 COLON-ALIGNED NO-LABEL WIDGET-ID 46
     Btn_salvar AT ROW 24.57 COL 61 WIDGET-ID 56
     Btn_fechar AT ROW 24.57 COL 81 WIDGET-ID 58
     "Leitora de Cartão" VIEW-AS TEXT
          SIZE 37 BY 1.43 AT ROW 18.14 COL 3 WIDGET-ID 40
          FONT 8
     "2 - Passagem" VIEW-AS TEXT
          SIZE 21 BY 1.43 AT ROW 18.86 COL 49 WIDGET-ID 44
          FONT 12
     "Número" VIEW-AS TEXT
          SIZE 18 BY 1.43 AT ROW 10.76 COL 97 WIDGET-ID 20
          FONT 8
     "1 - Matricial" VIEW-AS TEXT
          SIZE 19 BY 1.43 AT ROW 18.14 COL 124 WIDGET-ID 50
          FONT 12
     "PA" VIEW-AS TEXT
          SIZE 10 BY 1.43 AT ROW 12.91 COL 30 WIDGET-ID 24
          FONT 8
     "CONFIGURAÇÃO TAA" VIEW-AS TEXT
          SIZE 102.6 BY 3.33 AT ROW 1.48 COL 29.8 WIDGET-ID 122
          FGCOLOR 1 FONT 10
     "IP" VIEW-AS TEXT
          SIZE 5 BY 1.43 AT ROW 12.91 COL 110 WIDGET-ID 28
          FONT 8
     "1 - Inserção" VIEW-AS TEXT
          SIZE 19 BY 1.43 AT ROW 17.43 COL 49 WIDGET-ID 42
          FONT 12
     "Depositário" VIEW-AS TEXT
          SIZE 25 BY 1.43 AT ROW 18.14 COL 90 WIDGET-ID 48
          FONT 8
     "0 - Sem Depositário" VIEW-AS TEXT
          SIZE 30 BY 1.43 AT ROW 16.71 COL 124 WIDGET-ID 54
          FONT 12
     "Cooperativa" VIEW-AS TEXT
          SIZE 26 BY 1.43 AT ROW 10.76 COL 14 WIDGET-ID 16
          FONT 8
     "2 - Jato de Tinta" VIEW-AS TEXT
          SIZE 25 BY 1.43 AT ROW 19.57 COL 124 WIDGET-ID 52
          FONT 12
     "Servidor" VIEW-AS TEXT
          SIZE 19 BY 1.43 AT ROW 15.05 COL 21 WIDGET-ID 32
          FONT 8
     "Serviço" VIEW-AS TEXT
          SIZE 17 BY 1.43 AT ROW 15.05 COL 98 WIDGET-ID 36
          FONT 8
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 120
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
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW w_config ASSIGN
         HIDDEN             = YES
         TITLE              = "Configuração"
         HEIGHT             = 28.57
         WIDTH              = 160
         MAX-HEIGHT         = 28.57
         MAX-WIDTH          = 160
         VIRTUAL-HEIGHT     = 28.57
         VIRTUAL-WIDTH      = 160
         SHOW-IN-TASKBAR    = no
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
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_config
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_config
   FRAME-NAME                                                           */
ASSIGN 
       ed_ipterfin:READ-ONLY IN FRAME f_config        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_config
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_config
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_config
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w_config)
THEN w_config:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_config
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_config w_config
ON END-ERROR OF w_config /* Configuração */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_config w_config
ON WINDOW-CLOSE OF w_config /* Configuração */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_fechar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_fechar w_config
ON CHOOSE OF Btn_fechar IN FRAME f_config /* Fechar */
DO:
    QUIT.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_salvar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_salvar w_config
ON CHOOSE OF Btn_salvar IN FRAME f_config /* Salvar */
DO:
    IF  NOT CAN-DO("1,2",ed_tpleitor:SCREEN-VALUE)  THEN
        DO:
            ed_tpleitor:SCREEN-VALUE = "9".
            APPLY "ENTRY" TO ed_tpleitor.
            RETURN NO-APPLY.
        END.

    IF  NOT CAN-DO("0,1,2",ed_tpenvelo:SCREEN-VALUE)  THEN
        DO:
            ed_tpenvelo:SCREEN-VALUE = "9".
            APPLY "ENTRY" TO ed_tpenvelo.
            RETURN NO-APPLY.
        END.

    /* atribui os campos */
    ASSIGN ed_cdcoptfn
           ed_nrterfin
           ed_cdagetfn
           ed_ipterfin
           ed_nmserver
           ed_nmservic
           ed_tpleitor
           ed_tpenvelo.


   RUN procedures/efetua_config.p ( INPUT ed_cdcoptfn,
                                    INPUT ed_nrterfin,
                                    INPUT ed_cdagetfn,
                                    INPUT ed_ipterfin,
                                    INPUT ed_nmserver,
                                    INPUT ed_nmservic,
                                    INPUT ed_tpleitor,
                                    INPUT ed_tpenvelo,
                                   OUTPUT aux_flgderro).
    
    IF  aux_flgderro  THEN
        DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "    ATENÇÃO",
                            INPUT "",
                            INPUT "Não foi possível efetuar",
                            INPUT "a configuração.",
                            INPUT "",
                            INPUT "").
            
            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.

            RETURN.
        END.

   
    RUN procedures/carrega_config.p (OUTPUT aux_flgderro).


    /* Desabilita os campos e troca a cor */
    ASSIGN ed_cdcoptfn:SCREEN-VALUE = STRING(glb_cdcoptfn)
           ed_cdcoptfn:BGCOLOR      = 8
           ed_cdcoptfn:READ-ONLY    = YES

           ed_nrterfin:SCREEN-VALUE = STRING(glb_nrterfin)
           ed_nrterfin:BGCOLOR      = 8
           ed_nrterfin:READ-ONLY    = YES

           ed_cdagetfn:SCREEN-VALUE = STRING(glb_cdagetfn)
           ed_cdagetfn:BGCOLOR      = 8
           ed_cdagetfn:READ-ONLY    = YES

           ed_ipterfin:SCREEN-VALUE = glb_ipterfin
        
           ed_nmserver:SCREEN-VALUE = glb_nmserver
           ed_nmserver:BGCOLOR      = 8
           ed_nmserver:READ-ONLY    = YES

           ed_nmservic:SCREEN-VALUE = glb_nmservic
           ed_nmservic:BGCOLOR      = 8
           ed_nmservic:READ-ONLY    = YES

           ed_tpleitor:SCREEN-VALUE = STRING(glb_tpleitor)
           ed_tpleitor:BGCOLOR      = 8
           ed_tpleitor:READ-ONLY    = YES

           ed_tpenvelo:SCREEN-VALUE = STRING(glb_tpenvelo)
           ed_tpenvelo:BGCOLOR      = 8
           ed_tpenvelo:READ-ONLY    = YES.

    DISABLE Btn_salvar WITH FRAME f_config.

    APPLY "ENTRY" TO Btn_fechar.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_cdagetfn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_cdagetfn w_config
ON RETURN OF ed_cdagetfn IN FRAME f_config
DO:
    APPLY "TAB".
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_cdcoptfn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_cdcoptfn w_config
ON RETURN OF ed_cdcoptfn IN FRAME f_config
DO:
    APPLY "TAB".
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_nmserver
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nmserver w_config
ON RETURN OF ed_nmserver IN FRAME f_config
DO:
    APPLY "TAB".
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_nmservic
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nmservic w_config
ON RETURN OF ed_nmservic IN FRAME f_config
DO:
    APPLY "TAB".
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_nrterfin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nrterfin w_config
ON RETURN OF ed_nrterfin IN FRAME f_config
DO:
    APPLY "TAB".
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_tpenvelo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_tpenvelo w_config
ON RETURN OF ed_tpenvelo IN FRAME f_config
DO:
    APPLY "TAB".
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_tpleitor
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_tpleitor w_config
ON RETURN OF ed_tpleitor IN FRAME f_config
DO:
    APPLY "TAB".
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_config 


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

    ASSIGN CURRENT-WINDOW:X = 0
           CURRENT-WINDOW:Y = 0.

    /* Na INSTALACAO do sistema, ja atualiza direto pelo script,
       entao nao precisa chamar novamente no config... */
    IF  SESSION:PARAMETER <> "NO"  THEN
        /* solicita atualizacao do sistema, sem reboot */
        RUN atualiza_sistema.w (INPUT NO).
    
    RUN procedures/carrega_config.p (OUTPUT aux_flgderro).

    IF  aux_flgderro  THEN
        DO:
            RUN procedures/ver_ip_host.p (OUTPUT aux_nmdohost,
                                          OUTPUT aux_ipdohost).
            
            ed_ipterfin:SCREEN-VALUE = aux_ipdohost.
        END.
    ELSE
        ed_ipterfin:SCREEN-VALUE = glb_ipterfin.


    ASSIGN ed_cdcoptfn:SCREEN-VALUE = STRING(glb_cdcoptfn)
           ed_nrterfin:SCREEN-VALUE = STRING(glb_nrterfin)
           ed_cdagetfn:SCREEN-VALUE = STRING(glb_cdagetfn)
           ed_nmserver:SCREEN-VALUE = glb_nmserver
           ed_nmservic:SCREEN-VALUE = glb_nmservic
           ed_tpleitor:SCREEN-VALUE = STRING(glb_tpleitor)
           ed_tpenvelo:SCREEN-VALUE = STRING(glb_tpenvelo).


    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_config  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w_config)
  THEN DELETE WIDGET w_config.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_config  _DEFAULT-ENABLE
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
  DISPLAY ed_cdcoptfn ed_nrterfin ed_cdagetfn ed_ipterfin ed_nmserver 
          ed_nmservic ed_tpleitor ed_tpenvelo 
      WITH FRAME f_config IN WINDOW w_config.
  ENABLE ed_cdcoptfn ed_nrterfin ed_cdagetfn ed_ipterfin ed_nmserver 
         ed_nmservic ed_tpleitor ed_tpenvelo Btn_salvar Btn_fechar 
      WITH FRAME f_config IN WINDOW w_config.
  {&OPEN-BROWSERS-IN-QUERY-f_config}
  VIEW w_config.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

