&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_envelope_deposito
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_envelope_deposito 
/* ..............................................................................

Procedure: envelope_deposito_dinheiro.w
Objetivo : Tela para depoistos em dinheiro
Autor    : Evandro
Data     : Janeiro 2010

Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

                  18/07/2013 - Correção número da agencia da cooperativa (Lucas).
                  
                  07/11/2013 - Alterado Posto de Atendimento ao Cooperado para
                               Posto de Atendimento "PA". (Jorge)
                               
                  03/06/2014 - Alterado para permitir o deposito intercooperativa.
                               (Reinert)
                               
                  20/08/2015 - Adicionado SAC e OUVIDORIA nos comprovantes
                               e visualização de impressão
                               (Lucas Lunelli - Melhoria 83 [SD 279180])

				  27/01/2016 - Adicionado novo parametro na chamada da procedure
							   busca_associado. (Reinert)

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

DEFINE INPUT  PARAM par_agctltfn    AS INTEGER                  NO-UNDO.
DEFINE INPUT  PARAM par_nmcoptfn    AS CHARACTER                NO-UNDO.
DEFINE OUTPUT PARAM par_flgderro    AS LOGICAL                  NO-UNDO.
DEFINE OUTPUT PARAM par_vlretorn    AS CHARACTER                NO-UNDO.

DEFINE VARIABLE aux_cdagectl        AS INT                      NO-UNDO.
DEFINE VARIABLE aux_nmrescop        AS CHARACTER                NO-UNDO.
DEFINE VARIABLE aux_nmtitula        AS CHARACTER    EXTENT 2    NO-UNDO.
DEFINE VARIABLE aux_flgmigra        AS LOGICAL                  NO-UNDO.
DEFINE VARIABLE aux_flgdinss        AS LOGICAL                  NO-UNDO.
DEFINE VARIABLE aux_flgbinss        AS LOGICAL                  NO-UNDO.
DEFINE VARIABLE aux_flgderro        AS LOGICAL                  NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_envelope_deposito_dinheiro

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-127 RECT-128 RECT-142 IMAGE-37 IMAGE-40 ~
IMAGE-44 ed_nrctafav ed_nmtitula ed_vldinhei Btn_G Btn_D Btn_H ed_agctltfn ~
ed_nmcoptfn 
&Scoped-Define DISPLAYED-OBJECTS ed_nrctafav ed_nmtitula ed_vldinhei ~
ed_agctltfn ed_nmcoptfn 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_envelope_deposito AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_D 
     LABEL "CONFIRMAR" 
     SIZE 53 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_G 
     LABEL "CORRIGIR" 
     SIZE 53 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_H 
     LABEL "VOLTAR" 
     SIZE 53 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_nmtitula AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 91 BY 3.1
     BGCOLOR 15 FGCOLOR 1 FONT 8 NO-UNDO.

DEFINE VARIABLE ed_agctltfn AS INTEGER FORMAT "9999":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 24 BY 1.24
     FONT 15 NO-UNDO.

DEFINE VARIABLE ed_nmcoptfn AS CHARACTER FORMAT "X(15)":U 
      VIEW-AS TEXT 
     SIZE 68 BY 1.24
     FONT 15 NO-UNDO.

DEFINE VARIABLE ed_nrctafav AS INTEGER FORMAT "zzzz,zzz,9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1.91
     FONT 15 NO-UNDO.

DEFINE VARIABLE ed_vldinhei AS DECIMAL FORMAT "zz,zz9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 41 BY 2.14
     FONT 13 NO-UNDO.

DEFINE IMAGE IMAGE-37
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-40
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-44
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE RECTANGLE RECT-100
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 2 .

DEFINE RECTANGLE RECT-127
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 42 BY 2.38.

DEFINE RECTANGLE RECT-128
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 43 BY 2.62.

DEFINE RECTANGLE RECT-142
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 93 BY 3.57.

DEFINE RECTANGLE RECT-98
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-99
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_envelope_deposito_dinheiro
     ed_nrctafav AT ROW 10.76 COL 50 COLON-ALIGNED NO-LABEL WIDGET-ID 104
     ed_nmtitula AT ROW 13.38 COL 52 NO-LABEL WIDGET-ID 102 NO-TAB-STOP 
     ed_vldinhei AT ROW 17.19 COL 50 COLON-ALIGNED NO-LABEL WIDGET-ID 106
     Btn_G AT ROW 19.1 COL 102.4 WIDGET-ID 86
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 66
     Btn_H AT ROW 24.1 COL 102.4 WIDGET-ID 74
     ed_agctltfn AT ROW 8.86 COL 50.4 COLON-ALIGNED NO-LABEL WIDGET-ID 232 NO-TAB-STOP 
     ed_nmcoptfn AT ROW 8.86 COL 76.4 COLON-ALIGNED NO-LABEL WIDGET-ID 234 NO-TAB-STOP 
     "DEPÓSITO EM DINHEIRO" VIEW-AS TEXT
          SIZE 111.4 BY 3.33 AT ROW 1.48 COL 25.4 WIDGET-ID 166
          FGCOLOR 1 FONT 10
     "Cooperativa:" VIEW-AS TEXT
          SIZE 28 BY 1.19 AT ROW 8.86 COL 23.2 WIDGET-ID 134
          FONT 8
     "Titular:" VIEW-AS TEXT
          SIZE 15 BY 1.19 AT ROW 13.62 COL 35 WIDGET-ID 112
          FONT 8
     "Valor:" VIEW-AS TEXT
          SIZE 13 BY 1.67 AT ROW 17.43 COL 37 WIDGET-ID 110
          FONT 8
     "Para a Conta:" VIEW-AS TEXT
          SIZE 29 BY 1.19 AT ROW 10.95 COL 22 WIDGET-ID 114
          FONT 8
     RECT-127 AT ROW 10.52 COL 51 WIDGET-ID 94
     RECT-128 AT ROW 16.95 COL 51 WIDGET-ID 96
     RECT-142 AT ROW 13.14 COL 51 WIDGET-ID 100
     IMAGE-37 AT ROW 24.24 COL 1 WIDGET-ID 148
     IMAGE-40 AT ROW 24.24 COL 156 WIDGET-ID 154
     IMAGE-44 AT ROW 19.24 COL 156 WIDGET-ID 156
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 164
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
  CREATE WINDOW w_envelope_deposito ASSIGN
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
ASSIGN w_envelope_deposito = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_envelope_deposito
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_envelope_deposito_dinheiro
   FRAME-NAME                                                           */
ASSIGN 
       ed_nmtitula:READ-ONLY IN FRAME f_envelope_deposito_dinheiro        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_envelope_deposito_dinheiro
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_envelope_deposito_dinheiro
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_envelope_deposito_dinheiro
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_envelope_deposito_dinheiro:HANDLE
       ROW             = 1.95
       COLUMN          = 7
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_envelope_deposito_dinheiro */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_envelope_deposito
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_envelope_deposito w_envelope_deposito
ON END-ERROR OF w_envelope_deposito
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_envelope_deposito w_envelope_deposito
ON WINDOW-CLOSE OF w_envelope_deposito
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE. 
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_envelope_deposito
ON ANY-KEY OF Btn_D IN FRAME f_envelope_deposito_dinheiro /* CONFIRMAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_envelope_deposito
ON CHOOSE OF Btn_D IN FRAME f_envelope_deposito_dinheiro /* CONFIRMAR */
DO:
    DEFINE VARIABLE aux_nrdocmto    AS INTEGER      NO-UNDO.
    DEFINE VARIABLE aux_dsprotoc    AS CHAR         NO-UNDO.

    /* ---------- */
    RUN procedures/verifica_autorizacao.p (OUTPUT par_flgderro).
    
    IF  par_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.

    ASSIGN ed_nrctafav
           ed_nmtitula
           ed_vldinhei.

    /* valida os dados */
    IF  ed_nrctafav = 0  OR
        ed_vldinhei = 0  THEN
        DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "      ERRO!",
                            INPUT "",
                            INPUT "",
                            INPUT "Dados Incorretos.",
                            INPUT "",
                            INPUT "").
            
            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.

            APPLY "CHOOSE" TO Btn_G.
            RETURN NO-APPLY.
        END.

    RUN procedures/grava_log.p (INPUT "Depósito em dinheiro identificado para C/C: " +
                                      STRING(ed_nrctafav,"zzzz,zzz,9") + " - " + ed_nmtitula + " - " +
                                      "Valor: " + STRING(ed_vldinhei,"zz,zz9.99") + "...").

    RUN envelope_entrega.w ( INPUT 8,            /* Deposito em C/C */
                             INPUT ed_nrctafav,  /* Conta Destino */
                             INPUT ed_vldinhei,  /* Dinheiro */
                             INPUT 0,            /* Cheque */
                             INPUT ed_agctltfn,  /* Coop. Destino */
                            OUTPUT aux_nrdocmto, /* Documento */
                            OUTPUT aux_dsprotoc, /* Protocolo */
                            OUTPUT par_flgderro).

    IF  par_flgderro  THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.        
        END.
    
   RUN procedures/inicializa_dispositivo.p ( INPUT 6,
                                             OUTPUT aux_flgderro).
    
    /* se a impressora estiver habilitada e com papel */
    IF  xfs_impressora       AND
        NOT xfs_impsempapel  THEN
        RUN imprime_comprovante (INPUT aux_nrdocmto,
                                 INPUT aux_dsprotoc).
    
    ASSIGN par_flgderro = NO
           par_vlretorn = "OK".
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
    RETURN "OK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_G
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_envelope_deposito
ON ANY-KEY OF Btn_G IN FRAME f_envelope_deposito_dinheiro /* CORRIGIR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_envelope_deposito
ON CHOOSE OF Btn_G IN FRAME f_envelope_deposito_dinheiro /* CORRIGIR */
DO:
    ASSIGN ed_nrctafav:SCREEN-VALUE = ""
           ed_nmtitula:SCREEN-VALUE = ""
           ed_vldinhei:SCREEN-VALUE = ""
           aux_nmtitula             = "".

    APPLY "ENTRY" TO ed_nrctafav.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_envelope_deposito
ON ANY-KEY OF Btn_H IN FRAME f_envelope_deposito_dinheiro /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_envelope_deposito
ON CHOOSE OF Btn_H IN FRAME f_envelope_deposito_dinheiro /* VOLTAR */
DO:    
    ASSIGN par_flgderro = NO
           par_vlretorn = "NOK".
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_nrctafav
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nrctafav w_envelope_deposito
ON ANY-KEY OF ed_nrctafav IN FRAME f_envelope_deposito_dinheiro
DO:
    /* se estiver preenchendo a conta e pressionar "CONFIRMAR",
       efetua como se tivesse pressionado "ENTER" */
    IF  KEY-FUNCTION(LASTKEY) <> "D"  THEN
        RUN tecla.

    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  OR
        KEY-FUNCTION(LASTKEY) = "D"       THEN
        DO:
            RUN procedures/busca_associado.p (INPUT  INT(ed_nrctafav:SCREEN-VALUE),
                                              INPUT  par_agctltfn,
                                              OUTPUT aux_cdagectl,
                                              OUTPUT aux_nmrescop,
                                              OUTPUT aux_nmtitula,
                                              OUTPUT aux_flgmigra,
                                              OUTPUT aux_flgdinss,
                                              OUTPUT aux_flgbinss,
                                              OUTPUT par_flgderro).

            /* Controle para impedir depósito em contas migradas para outra cooperativa */
            IF  aux_flgmigra  THEN
                DO:
                    RUN mensagem.w (INPUT YES,
                                    INPUT "    ATENÇÃO",
                                    INPUT "",
                                    INPUT "Conta de outra Cooperativa.",
                                    INPUT "",
                                    INPUT "Informações no Atendimento!",
                                    INPUT "").

                    PAUSE 3 NO-MESSAGE.
                    ASSIGN h_mensagem:HIDDEN = YES
                           par_flgderro      = YES.
                END.

            IF  par_flgderro  THEN
                APPLY "CHOOSE" TO Btn_G.
            ELSE
                DO:
                    ed_nmtitula:SCREEN-VALUE = aux_nmtitula[1].

                    IF  aux_nmtitula[2] <> ""  THEN
                        ed_nmtitula:SCREEN-VALUE = ed_nmtitula:SCREEN-VALUE +
                                                   CHR(13) +
                                                   aux_nmtitula[2].

                    APPLY "ENTRY" TO ed_vldinhei.
                    RETURN NO-APPLY.
                END.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        ed_nrctafav:SCREEN-VALUE = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_vldinhei
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_vldinhei w_envelope_deposito
ON ANY-KEY OF ed_vldinhei IN FRAME f_envelope_deposito_dinheiro
DO:
    RUN tecla.

    IF  KEY-FUNCTION(LASTKEY) = "D"  THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "G"  THEN
        APPLY "CHOOSE" TO Btn_G.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        ed_vldinhei:SCREEN-VALUE = "".
    
    /* se nao digitou numeros ou cancelou, despreza */
    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9,H",KEY-FUNCTION(LASTKEY))  THEN
        RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_envelope_deposito OCX.Tick
PROCEDURE temporizador.t_envelope_deposito_dinheiro.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_envelope_deposito_dinheiro.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_envelope_deposito 


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
    FRAME f_envelope_deposito_dinheiro:LOAD-MOUSE-POINTER("blank.cur").

    chtemporizador:t_envelope_deposito_dinheiro:INTERVAL = glb_nrtempor.

    ASSIGN chtemporizador:t_envelope_deposito_dinheiro:INTERVAL = glb_nrtempor
           
           /* a cooperativa para depósito é a proprietaria do taa */
           glb_cdcooper = glb_cdcoptfn
           glb_nmrescop = glb_nmcoptfn
           
           ed_nmcoptfn = par_nmcoptfn
           ed_agctltfn = par_agctltfn.

    DISPLAY ed_nmcoptfn
            ed_agctltfn WITH FRAME f_envelope_deposito_dinheiro.

    /* coloca o foco na conta */
    APPLY "ENTRY" TO ed_nrctafav.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_envelope_deposito  _CONTROL-LOAD
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

OCXFile = SEARCH( "envelope_deposito_dinheiro.wrx":U ).
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
ELSE MESSAGE "envelope_deposito_dinheiro.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_envelope_deposito  _DEFAULT-DISABLE
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
  HIDE FRAME f_envelope_deposito_dinheiro.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_envelope_deposito  _DEFAULT-ENABLE
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
  DISPLAY ed_nrctafav ed_nmtitula ed_vldinhei ed_agctltfn ed_nmcoptfn 
      WITH FRAME f_envelope_deposito_dinheiro.
  ENABLE RECT-127 RECT-128 RECT-142 IMAGE-37 IMAGE-40 IMAGE-44 ed_nrctafav 
         ed_nmtitula ed_vldinhei Btn_G Btn_D Btn_H ed_agctltfn ed_nmcoptfn 
      WITH FRAME f_envelope_deposito_dinheiro.
  {&OPEN-BROWSERS-IN-QUERY-f_envelope_deposito_dinheiro}
  VIEW w_envelope_deposito.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE imprime_comprovante w_envelope_deposito 
PROCEDURE imprime_comprovante :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE INPUT PARAM par_nrdocmto     AS INT          NO-UNDO.
DEFINE INPUT PARAM par_dsprotoc     AS CHARACTER    NO-UNDO.

DEFINE VARIABLE    tmp_tximpres     AS CHARACTER    NO-UNDO.
DEFINE VARIABLE    aux_nrtelsac     AS CHARACTER    NO-UNDO.
DEFINE VARIABLE    aux_nrtelouv     AS CHARACTER    NO-UNDO.


/* São 48 caracteres */

RUN procedures/obtem_informacoes_comprovante.p (OUTPUT aux_nrtelsac,
                                                OUTPUT aux_nrtelouv,
                                                OUTPUT aux_flgderro).

/* centraliza o cabeçalho */
                      /* Coop do associado */
ASSIGN tmp_tximpres = TRIM(glb_nmrescop) + " AUTOATENDIMENTO"
       tmp_tximpres = FILL(" ",INT((48 - LENGTH(tmp_tximpres)) / 2)) + tmp_tximpres
       tmp_tximpres = tmp_tximpres + FILL(" ",48 - length(tmp_tximpres))
       tmp_tximpres = tmp_tximpres +
                      "                                                "   +
                      "EMISSAO: " + STRING(TODAY,"99/99/9999") + "      "  +
                              "               " + STRING(TIME,'HH:MM:SS')  +
                      "                                                "   +
                      /* dados do TAA */             /* agencia na central, sem digito */
                      "COOPERATIVA/PA/TERMINAL: " + STRING(glb_agctltfn,"9999") + "/" +
                                                    STRING(glb_cdagetfn,"9999") + "/" +
                                                    STRING(glb_nrterfin,"9999") +
                                                             "         " +
                      "                                                " +
                      "      COMPROVANTE DE DEPOSITO EM DINHEIRO       " +
                      "                                                " +
                      "   DOCUMENTO: " +
                      STRING(par_nrdocmto,"99999") +
                                         "                             " +
                      "                                                " +
                      "PARA                                            " +
                      "COOPERATIVA: " +
                      STRING(ed_agctltfn, "9999")  + " - " +
                      STRING(ed_nmcoptfn, "x(15)") + FILL(" ", 13) +
                      "CONTA: " +
                      STRING(ed_nrctafav,"zzzz,zzz,9") + " - " +
                      STRING(aux_nmtitula[1],"x(21)").

IF  aux_nmtitula[2] <> ""  THEN
    tmp_tximpres = tmp_tximpres +
                   "                           " +
                   STRING(aux_nmtitula[2],"x(21)").

tmp_tximpres = tmp_tximpres +
               FILL(" ", 7) +
               "                                                " +
               "       VALOR: " + STRING(ed_vldinhei,"zz,zz9.99") +
                                      "                         " +
               "                                                " +
               "   PROTOCOLO: " + STRING(par_dsprotoc,"x(29)") + 
                                                          "     " +
               "                                                " +
               "                                                " +
               "A CONFIRMACAO DO DEPOSITO NA CONTA DO FAVORECIDO" +
               "SERA EFETUADA APOS A ABERTURA DO  ENVELOPE  E  A" +
               "VERIFICACAO DOS VALORES CONTIDOS.               " +
               "                                                ".


/* verifica horário de corte para depositos */
RUN procedures/horario_deposito.p (OUTPUT par_flgderro).
    
IF  RETURN-VALUE = "NOK"  THEN
    tmp_tximpres = tmp_tximpres +
                   "                                                " + 
                   "        ESTE ENVELOPE SERA PROCESSADO NO        " +
                   "                PROXIMO DIA UTIL                " +
                   "                                                ".
        
tmp_tximpres = tmp_tximpres +
               "    SAC - Servico de Atendimento ao Cooperado   " +

             FILL(" ", 14) + STRING(aux_nrtelsac, "x(20)") + FILL(" ", 14) +

               "     Atendimento todos os dias das 6h as 22h    " +
               "                                                " +
               "                   OUVIDORIA                    " +

             FILL(" ", 14) + STRING(aux_nrtelouv, "x(20)") + FILL(" ", 14) +               
    
               "    Atendimento nos dias uteis das 8h as 17h    " +
               "                                                " +
               "            **  FIM DA IMPRESSAO  **            " +
               "                                                " +
               "                                                ".
                                                                                 
RUN impressao_visualiza.w (INPUT "Comprovante...",
                           INPUT  tmp_tximpres,
                           INPUT 0, /*Comprovante*/
                           INPUT "").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_envelope_deposito 
PROCEDURE tecla :
chtemporizador:t_envelope_deposito_dinheiro:INTERVAL = 0.

    IF  KEY-FUNCTION(LASTKEY) = "D"                            AND
        Btn_D:SENSITIVE IN FRAME f_envelope_deposito_dinheiro  THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "G"                            AND
        Btn_G:SENSITIVE IN FRAME f_envelope_deposito_dinheiro  THEN
        APPLY "CHOOSE" TO Btn_G.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                            AND
        Btn_H:SENSITIVE IN FRAME f_envelope_deposito_dinheiro  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_envelope_deposito_dinheiro:INTERVAL = glb_nrtempor.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

