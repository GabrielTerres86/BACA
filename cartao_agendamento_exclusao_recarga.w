&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_agen_exclusao_transf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_agen_exclusao_transf 
/* ..............................................................................

Procedure: cartao_agendamento_exclusao_recarga.w
Objetivo : Tela para excluir agendamento de recarga
Autor    : Lucas Reinert
Data     : Março 2017
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

/* Parameters Definitions ---      
                                     */
DEFINE INPUT    PARAM   par_nmoperadora  AS CHAR                 NO-UNDO.
DEFINE INPUT    PARAM   par_dtrecarga    AS DATE                 NO-UNDO.
DEFINE INPUT    PARAM   par_dtmvtolt     AS DATE                 NO-UNDO.
DEFINE INPUT    PARAM   par_nrdocmto     AS INTEGER              NO-UNDO.
DEFINE INPUT    PARAM   par_dstelefo     AS CHARACTER            NO-UNDO.
DEFINE INPUT    PARAM   par_vlrecarga    AS DECIMAL              NO-UNDO.


/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }

DEFINE VARIABLE aux_flgderro        AS LOGICAL                  NO-UNDO.
DEFINE VARIABLE aux_cdagectl        AS INT                      NO-UNDO.
DEFINE VARIABLE aux_nmrescop        AS CHAR                     NO-UNDO.
DEFINE VARIABLE aux_nmtransf        AS CHAR         EXTENT 2    NO-UNDO.
DEFINE VARIABLE aux_dttransf        AS DATE                     NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_agen_exclusao_transf

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-127 RECT-128 IMAGE-37 IMAGE-40 RECT-129 ~
RECT-130 ed_nmoperadora ed_dstelefo ed_vlrecarga ed_dtrecarga Btn_D Btn_H ~
ed_cdagectl ed_nmrescop ed_nrdconta ed_nmextttl 
&Scoped-Define DISPLAYED-OBJECTS ed_nmoperadora ed_dstelefo ed_vlrecarga ~
ed_dtrecarga ed_cdagectl ed_nmrescop ed_nrdconta ed_nmextttl 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_agen_exclusao_transf AS WIDGET-HANDLE NO-UNDO.

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

DEFINE VARIABLE ed_cdagectl AS INTEGER FORMAT "9999":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 16 BY 1.24
     FONT 15 NO-UNDO.

DEFINE VARIABLE ed_dstelefo AS CHARACTER FORMAT "X(256)":U INITIAL "0" 
     VIEW-AS FILL-IN 
     SIZE 109.6 BY 1.43
     FONT 14 NO-UNDO.

DEFINE VARIABLE ed_dtrecarga AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN 
     SIZE 23 BY 1.43
     FONT 14 NO-UNDO.

DEFINE VARIABLE ed_nmextttl AS CHARACTER FORMAT "X(26)":U 
      VIEW-AS TEXT 
     SIZE 68 BY 1.19
     FONT 8 NO-UNDO.

DEFINE VARIABLE ed_nmoperadora AS CHARACTER FORMAT "X(256)":U INITIAL "0" 
     VIEW-AS FILL-IN 
     SIZE 109.6 BY 1.43
     FONT 14 NO-UNDO.

DEFINE VARIABLE ed_nmrescop AS CHARACTER FORMAT "X(15)":U 
      VIEW-AS TEXT 
     SIZE 68 BY 1.24
     FONT 15 NO-UNDO.

DEFINE VARIABLE ed_nrdconta AS INTEGER FORMAT "zzzz,zz9,9":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 24 BY 1.19
     FONT 8 NO-UNDO.

DEFINE VARIABLE ed_vlrecarga AS DECIMAL FORMAT "zz,zz9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 23 BY 1.43
     FONT 14 NO-UNDO.

DEFINE IMAGE IMAGE-37
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-40
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE RECTANGLE RECT-100
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 2 .

DEFINE RECTANGLE RECT-127
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 111.6 BY 1.91.

DEFINE RECTANGLE RECT-128
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 25 BY 1.91.

DEFINE RECTANGLE RECT-129
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 25 BY 1.91.

DEFINE RECTANGLE RECT-130
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 111.6 BY 1.91.

DEFINE RECTANGLE RECT-98
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-99
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_agen_exclusao_transf
     ed_nmoperadora AT ROW 9.43 COL 30.4 COLON-ALIGNED NO-LABEL WIDGET-ID 256
     ed_dstelefo AT ROW 11.86 COL 30.4 COLON-ALIGNED NO-LABEL WIDGET-ID 104
     ed_vlrecarga AT ROW 14.29 COL 30.4 COLON-ALIGNED NO-LABEL WIDGET-ID 106
     ed_dtrecarga AT ROW 16.76 COL 30.4 COLON-ALIGNED NO-LABEL WIDGET-ID 250
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 66
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 74
     ed_cdagectl AT ROW 6 COL 46 COLON-ALIGNED NO-LABEL WIDGET-ID 242 NO-TAB-STOP 
     ed_nmrescop AT ROW 6 COL 62 COLON-ALIGNED NO-LABEL WIDGET-ID 246 NO-TAB-STOP 
     ed_nrdconta AT ROW 7.43 COL 46 COLON-ALIGNED NO-LABEL WIDGET-ID 248 NO-TAB-STOP 
     ed_nmextttl AT ROW 7.43 COL 72 COLON-ALIGNED NO-LABEL WIDGET-ID 244 NO-TAB-STOP 
     "EXCLUSÃO DE AGENDAMENTO" VIEW-AS TEXT
          SIZE 143 BY 3.57 AT ROW 1.24 COL 9.6 WIDGET-ID 224
          FGCOLOR 1 FONT 10
     "CONFIRMA A EXCLUSÃO DO AGENDAMENTO?" VIEW-AS TEXT
          SIZE 107 BY 1.1 AT ROW 21.52 COL 27.6 WIDGET-ID 228
          FGCOLOR 1 FONT 8
     "Conta/Titular:" VIEW-AS TEXT
          SIZE 29 BY 1.19 AT ROW 7.43 COL 17 WIDGET-ID 238
          FONT 8
     "DDD/Telefone:" VIEW-AS TEXT
          SIZE 27.4 BY 1.1 AT ROW 12 COL 3 WIDGET-ID 108
          FONT 14
     "Data:" VIEW-AS TEXT
          SIZE 9 BY 1.38 AT ROW 16.81 COL 19.2 WIDGET-ID 254
          FONT 14
     "Operadora:" VIEW-AS TEXT
          SIZE 22 BY 1.19 AT ROW 9.57 COL 9 WIDGET-ID 260
          FONT 14
     "Valor:" VIEW-AS TEXT
          SIZE 10.6 BY 1 AT ROW 14.52 COL 17.8 WIDGET-ID 110
          FONT 14
     "Cooperativa:" VIEW-AS TEXT
          SIZE 28 BY 1.19 AT ROW 6 COL 18.6 WIDGET-ID 240
          FONT 8
     RECT-127 AT ROW 11.62 COL 31.4 WIDGET-ID 94
     RECT-128 AT ROW 14.05 COL 31.4 WIDGET-ID 96
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 134
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-37 AT ROW 24.24 COL 1 WIDGET-ID 148
     IMAGE-40 AT ROW 24.24 COL 156 WIDGET-ID 154
     RECT-129 AT ROW 16.52 COL 31.4 WIDGET-ID 252
     RECT-130 AT ROW 9.19 COL 31.4 WIDGET-ID 258
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1.05
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
  CREATE WINDOW w_agen_exclusao_transf ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.57
         WIDTH              = 160
         MAX-HEIGHT         = 33.57
         MAX-WIDTH          = 272.8
         VIRTUAL-HEIGHT     = 33.57
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
ASSIGN w_agen_exclusao_transf = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_agen_exclusao_transf
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_agen_exclusao_transf
   FRAME-NAME                                                           */
/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_agen_exclusao_transf
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_agen_exclusao_transf
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_agen_exclusao_transf
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_agen_exclusao_transf:HANDLE
       ROW             = 1.71
       COLUMN          = 2
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_agen_exclusao_transf */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_agen_exclusao_transf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_agen_exclusao_transf w_agen_exclusao_transf
ON END-ERROR OF w_agen_exclusao_transf
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_agen_exclusao_transf w_agen_exclusao_transf
ON WINDOW-CLOSE OF w_agen_exclusao_transf
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_agen_exclusao_transf
ON ANY-KEY OF Btn_D IN FRAME f_agen_exclusao_transf /* CONFIRMAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_agen_exclusao_transf
ON CHOOSE OF Btn_D IN FRAME f_agen_exclusao_transf /* CONFIRMAR */
DO:
    /* ---------- */
    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).
    
    IF  aux_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.

    /* para quem nao tem letras, pede cpf */
    IF  NOT glb_idsenlet  THEN
        RUN senha_cpf.w (OUTPUT aux_flgderro).
    ELSE
        RUN senha.w (OUTPUT aux_flgderro).
        
    IF  NOT aux_flgderro THEN
        DO:
            /* puxa o frame principal */
            h_principal:MOVE-TO-TOP().

            RUN procedures/exclui_agendamento_recarga.p (INPUT  par_dtmvtolt,
                                                         INPUT  par_dtrecarga,
                                                         INPUT  par_nrdocmto,
                                                         INPUT  par_vlrecarga,
                                                         OUTPUT aux_flgderro).
                                                                                                 
             IF  NOT aux_flgderro THEN
                 DO:
                   RUN procedures/inicializa_dispositivo.p ( INPUT 6,
                                                             OUTPUT aux_flgderro).
                     /* se a impressora estiver habilitada, com papel e 
                       transferencia efetuada com sucesso */
                    IF  xfs_impressora       AND
                        NOT xfs_impsempapel  AND
                        NOT aux_flgderro     THEN
                        RUN imprime_comprovante.        
                END.
            ELSE /* Erro na rotina */
                DO:
                     h_principal:MOVE-TO-BOTTOM().
                     h_inicializando:MOVE-TO-BOTTOM().
                END.                      
        END.    

    /* repassa o retorno */
    IF  RETURN-VALUE = "OK"  THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "OK".
        END.
    ELSE
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "NOK".
        END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_agen_exclusao_transf
ON ANY-KEY OF Btn_H IN FRAME f_agen_exclusao_transf /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_agen_exclusao_transf
ON CHOOSE OF Btn_H IN FRAME f_agen_exclusao_transf /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_agen_exclusao_transf OCX.Tick
PROCEDURE temporizador.t_agen_exclusao_transf.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_agen_exclusao_transf.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_agen_exclusao_transf 


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
    FRAME f_agen_exclusao_transf:LOAD-MOUSE-POINTER("blank.cur").

    ASSIGN chtemporizador:t_agen_exclusao_transf:INTERVAL = glb_nrtempor.
                   
    /* Dados do associado */
    ed_cdagectl = glb_cdagectl.
    ed_nmrescop = " - " + glb_nmrescop.
    ed_nrdconta = glb_nrdconta.
    ed_nmextttl = glb_nmtitula[1].

    DISPLAY ed_cdagectl  ed_nmrescop
            ed_nrdconta  ed_nmextttl
            WITH FRAME f_agen_exclusao_transf.

    /* exibe informações na tela */
    ASSIGN ed_dtrecarga = par_dtrecarga
           ed_nmoperadora = par_nmoperadora
           ed_dstelefo = par_dstelefo
           ed_vlrecarga = par_vlrecarga. 

    DISP ed_dtrecarga 
         ed_nmoperadora
         ed_dstelefo
         ed_vlrecarga  
         WITH FRAME f_agen_exclusao_transf.
    /* coloca o foco no botão */
    APPLY "ENTRY" TO Btn_D.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_agen_exclusao_transf  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_agendamento_exclusao_recarga.wrx":U ).
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
ELSE MESSAGE "cartao_agendamento_exclusao_recarga.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_agen_exclusao_transf  _DEFAULT-DISABLE
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
  HIDE FRAME f_agen_exclusao_transf.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_agen_exclusao_transf  _DEFAULT-ENABLE
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
  DISPLAY ed_nmoperadora ed_dstelefo ed_vlrecarga ed_dtrecarga ed_cdagectl 
          ed_nmrescop ed_nrdconta ed_nmextttl 
      WITH FRAME f_agen_exclusao_transf.
  ENABLE RECT-127 RECT-128 IMAGE-37 IMAGE-40 RECT-129 RECT-130 ed_nmoperadora 
         ed_dstelefo ed_vlrecarga ed_dtrecarga Btn_D Btn_H ed_cdagectl 
         ed_nmrescop ed_nrdconta ed_nmextttl 
      WITH FRAME f_agen_exclusao_transf.
  {&OPEN-BROWSERS-IN-QUERY-f_agen_exclusao_transf}
  VIEW w_agen_exclusao_transf.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE imprime_comprovante w_agen_exclusao_transf 
PROCEDURE imprime_comprovante :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEF VAR tmp_tximpres    AS CHAR                     NO-UNDO.
DEF VAR aux_nmtitula    AS CHAR     EXTENT 2        NO-UNDO.

DEFINE VARIABLE    aux_nrtelsac     AS CHARACTER                NO-UNDO.
DEFINE VARIABLE    aux_nrtelouv     AS CHARACTER                NO-UNDO.

/* São 48 caracteres */

RUN procedures/obtem_informacoes_comprovante.p (OUTPUT aux_nrtelsac,
                                                OUTPUT aux_nrtelouv,
                                                OUTPUT aux_flgderro).

/* centraliza o cabeçalho */
                      /* Coop do Associado */
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
                                                             "         "  +
                      "                                                "  +
                      "       COMPROVANTE EXCLUSAO DE AGENDAMENTO      "  +      
                      "                                                "  + 
                      "CONTA: " + STRING(glb_nrdconta,"zzzz,zzz,9")       +
                          " - " + STRING(glb_nmtitula[1],"x(28)").

IF  glb_nmtitula[2] <> ""  THEN
    tmp_tximpres = tmp_tximpres +
                   "                    " + STRING(glb_nmtitula[2],"x(28)").


tmp_tximpres = tmp_tximpres +               
               "                                                " + 
               "   OPERADORA: " + STRING(ed_nmoperadora, "x(34)") +
               "                                                " +
               "DDD/TELEFONE: " + STRING(ed_dstelefo, "x(34)")   +
               "                                                " +
               "        DATA: " + STRING(ed_dtrecarga, "99/99/9999") +
                                       "                        " +
               "                                                " +
               "       VALOR: " + STRING(ed_vlrecarga,"zz,zz9.99")   +
                                      "                         " +
               "                                                " +
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
                                                                                 
/* se a impressora estiver habilitada e com papel */
IF  xfs_impressora       AND
    NOT xfs_impsempapel  THEN
    RUN impressao_visualiza.w (INPUT "Comprovante...",
                               INPUT  tmp_tximpres,
                               INPUT 0, /*Comprovante*/
                               INPUT "").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_agen_exclusao_transf 
PROCEDURE tecla :
chtemporizador:t_agen_exclusao_transf:INTERVAL = 0.

    IF  KEY-FUNCTION(LASTKEY) = "D"                      AND
        Btn_D:SENSITIVE IN FRAME f_agen_exclusao_transf  THEN
        DO:
            APPLY "CHOOSE" TO Btn_D.

            IF  RETURN-VALUE = "OK"  THEN
                DO:
                    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
                    RETURN "OK".
                END.
            ELSE
                RETURN "NOK".
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                      AND
        Btn_H:SENSITIVE IN FRAME f_agen_exclusao_transf  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
            RETURN NO-APPLY.

    chtemporizador:t_agen_exclusao_transf:INTERVAL = glb_nrtempor.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

