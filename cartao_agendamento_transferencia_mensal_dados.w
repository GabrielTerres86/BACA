&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_cartao_agen_trans_mensal_dados
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_cartao_agen_trans_mensal_dados 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 
  
  Alteracoes: 08/05/2013 - Transferencia intercooperativa (Gabriel).
  
              18/07/2013 - Correção número da agencia da cooperativa (Lucas).
              
              07/11/2013 - Alterado Posto de Atendimento ao Cooperado para
                           Posto de Atendimento "PA". (Jorge)
                           
              05/12/2014 - Correção para não gerar comprovante sem efetivar
                           a operação (Lunelli SD 230613)
                           
              20/08/2015 - Adicionado SAC e OUVIDORIA nos comprovantes
                           e visualização de impressão
                           (Lucas Lunelli - Melhoria 83 [SD 279180])
                           
              21/10/2015 - Correção de Navegação na impressão de comprovante
                           (Lunelli)
                           
              24/12/2015 - Adicionado tratamento para contas com assinatura 
                           conjunta. (Reinert)                           

		      27/01/2016 - Adicionado novo parametro na chamada da procedure
					       busca_associado. (Reinert)
	
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
DEFINE INPUT  PARAMETER par_cdagetra AS INTE.
DEFINE INPUT  PARAMETER par_dsagetra AS CHAR.
DEFINE INPUT  PARAMETER par_nrtransf AS INTE.
DEFINE INPUT  PARAMETER par_nmtransf AS CHAR EXTENT 2 .
DEFINE INPUT  PARAMETER par_vltransf AS DECI.
DEFINE INPUT  PARAMETER par_ddtransf AS INTE.
DEFINE INPUT  PARAMETER par_mmtransf AS INTE.
DEFINE INPUT  PARAMETER par_intransf AS CHAR.
DEFINE INPUT  PARAMETER par_dttransf AS DATE.
DEFINE OUTPUT PARAMETER par_flgderro AS LOGI.

    
/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }

DEFINE VARIABLE aux_flgderro        AS LOGICAL                  NO-UNDO.
DEFINE VARIABLE aux_nmtransf        AS CHAR         EXTENT 2    NO-UNDO.
DEFINE VARIABLE aux_cdagectl        AS INTEGER                  NO-UNDO.
DEFINE VARIABLE aux_nmrescop        AS CHARACTER                NO-UNDO.
DEFINE VARIABLE aux_lsdataqd        AS CHARACTER                NO-UNDO.
DEFINE VARIABLE aux_tpoperac        AS INTEGER                  NO-UNDO.
DEFINE VARIABLE aux_idastcjt        AS INTE                     NO-UNDO.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_cartao_agen_trans_mensal_dados

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-37 IMAGE-40 RECT-144 RECT-147 RECT-153 ~
RECT-154 RECT-155 RECT-156 ed_dscooper ed_nrtransf ed_nmtransf ed_vltransf ~
ed_dttransf Btn_D Btn_H 
&Scoped-Define DISPLAYED-OBJECTS ed_dscooper ed_nrtransf ed_nmtransf ~
ed_vltransf ed_dttransf 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_cartao_agen_trans_mensal_dados AS WIDGET-HANDLE NO-UNDO.

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

DEFINE VARIABLE ed_nmtransf AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 103.4 BY 3.1
     BGCOLOR 15 FGCOLOR 1 FONT 14 NO-UNDO.

DEFINE VARIABLE ed_dscooper AS CHARACTER FORMAT "X(40)":U 
     VIEW-AS FILL-IN 
     SIZE 46 BY 1.24
     BGCOLOR 15 FONT 14 NO-UNDO.

DEFINE VARIABLE ed_dttransf AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 119 BY 1.24
     BGCOLOR 15 FGCOLOR 1 FONT 14 NO-UNDO.

DEFINE VARIABLE ed_nrtransf AS INTEGER FORMAT "zzzz,zzz,9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 28.2 BY 1.24
     BGCOLOR 15 FONT 14 NO-UNDO.

DEFINE VARIABLE ed_vltransf AS DECIMAL FORMAT "zz,zz9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 27.4 BY 1.24
     BGCOLOR 15 FONT 14 NO-UNDO.

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

DEFINE RECTANGLE RECT-144
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 98 BY 4.52.

DEFINE RECTANGLE RECT-147
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 121 BY 1.62.

DEFINE RECTANGLE RECT-153
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 48 BY 1.67.

DEFINE RECTANGLE RECT-154
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 30 BY 1.67.

DEFINE RECTANGLE RECT-155
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 29 BY 1.67.

DEFINE RECTANGLE RECT-156
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 105.4 BY 3.57.

DEFINE RECTANGLE RECT-98
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-99
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_cartao_agen_trans_mensal_dados
     ed_dscooper AT ROW 8 COL 46.4 COLON-ALIGNED NO-LABEL WIDGET-ID 214 NO-TAB-STOP 
     ed_nrtransf AT ROW 8 COL 110.2 COLON-ALIGNED NO-LABEL WIDGET-ID 212 NO-TAB-STOP 
     ed_nmtransf AT ROW 10 COL 36.6 NO-LABEL WIDGET-ID 102 NO-TAB-STOP 
     ed_vltransf AT ROW 13.81 COL 34.2 COLON-ALIGNED NO-LABEL WIDGET-ID 210 NO-TAB-STOP 
     ed_dttransf AT ROW 17.38 COL 19 COLON-ALIGNED NO-LABEL WIDGET-ID 216 NO-TAB-STOP 
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 66
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 74
     "A quitação efetiva deste agendamento" VIEW-AS TEXT
          SIZE 82.6 BY 1.29 AT ROW 19.48 COL 38 WIDGET-ID 196
          FGCOLOR 1 FONT 8
     "Data da Agendamento:" VIEW-AS TEXT
          SIZE 48.2 BY 1.67 AT ROW 15.48 COL 20 WIDGET-ID 194
          FONT 8
     "AGENDAMENTO" VIEW-AS TEXT
          SIZE 75 BY 3.33 AT ROW 1.48 COL 25 WIDGET-ID 128
          FGCOLOR 1 FONT 10
     "Conta:" VIEW-AS TEXT
          SIZE 13.8 BY 1.33 AT ROW 8 COL 96.6 WIDGET-ID 108
          FONT 8
     "TRANSFERÊNCIAS" VIEW-AS TEXT
          SIZE 42 BY 1.1 AT ROW 3.14 COL 101 WIDGET-ID 130
          FGCOLOR 1 FONT 14
     "conta corrente na data escolhida para débito." VIEW-AS TEXT
          SIZE 96 BY 1.1 AT ROW 22 COL 31.8 WIDGET-ID 200
          FGCOLOR 1 FONT 8
     "Titular:" VIEW-AS TEXT
          SIZE 16 BY 1.19 AT ROW 9.95 COL 19.6 WIDGET-ID 112
          FONT 8
     "Valor:" VIEW-AS TEXT
          SIZE 13 BY 1.67 AT ROW 13.52 COL 19.6 WIDGET-ID 110
          FONT 8
     "dependerá da existencia de saldo na sua" VIEW-AS TEXT
          SIZE 88.6 BY 1.1 AT ROW 20.81 COL 35 WIDGET-ID 198
          FGCOLOR 1 FONT 8
     "DE" VIEW-AS TEXT
          SIZE 15 BY 1.1 AT ROW 1.95 COL 101.2 WIDGET-ID 132
          FGCOLOR 1 FONT 14
     "Cooperativa:" VIEW-AS TEXT
          SIZE 28 BY 1.19 AT ROW 8 COL 19.4 WIDGET-ID 190
          FONT 8
     IMAGE-37 AT ROW 24.24 COL 1 WIDGET-ID 148
     IMAGE-40 AT ROW 24.24 COL 156 WIDGET-ID 154
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     RECT-144 AT ROW 19.14 COL 31 WIDGET-ID 202
     RECT-147 AT ROW 17.19 COL 20 WIDGET-ID 218
     RECT-153 AT ROW 7.76 COL 47.4 WIDGET-ID 220
     RECT-154 AT ROW 7.76 COL 111.2 WIDGET-ID 222
     RECT-155 AT ROW 13.57 COL 35.4 WIDGET-ID 224
     RECT-156 AT ROW 9.71 COL 35.6 WIDGET-ID 226
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
  CREATE WINDOW w_cartao_agen_trans_mensal_dados ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.57
         WIDTH              = 160
         MAX-HEIGHT         = 33.14
         MAX-WIDTH          = 256
         VIRTUAL-HEIGHT     = 33.14
         VIRTUAL-WIDTH      = 256
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
ASSIGN w_cartao_agen_trans_mensal_dados = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_cartao_agen_trans_mensal_dados
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_cartao_agen_trans_mensal_dados
   FRAME-NAME                                                           */
ASSIGN 
       ed_dscooper:READ-ONLY IN FRAME f_cartao_agen_trans_mensal_dados        = TRUE.

ASSIGN 
       ed_dttransf:READ-ONLY IN FRAME f_cartao_agen_trans_mensal_dados        = TRUE.

ASSIGN 
       ed_nmtransf:READ-ONLY IN FRAME f_cartao_agen_trans_mensal_dados        = TRUE.

ASSIGN 
       ed_nrtransf:READ-ONLY IN FRAME f_cartao_agen_trans_mensal_dados        = TRUE.

ASSIGN 
       ed_vltransf:READ-ONLY IN FRAME f_cartao_agen_trans_mensal_dados        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_cartao_agen_trans_mensal_dados
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_cartao_agen_trans_mensal_dados
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_cartao_agen_trans_mensal_dados
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_cartao_agen_trans_mensal_dados:HANDLE
       ROW             = 1.95
       COLUMN          = 5
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_agen_trans_mensal_dados */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_cartao_agen_trans_mensal_dados
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_agen_trans_mensal_dados w_cartao_agen_trans_mensal_dados
ON END-ERROR OF w_cartao_agen_trans_mensal_dados
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_agen_trans_mensal_dados w_cartao_agen_trans_mensal_dados
ON WINDOW-CLOSE OF w_cartao_agen_trans_mensal_dados
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_agen_trans_mensal_dados
ON ANY-KEY OF Btn_D IN FRAME f_cartao_agen_trans_mensal_dados /* CONFIRMAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_agen_trans_mensal_dados
ON CHOOSE OF Btn_D IN FRAME f_cartao_agen_trans_mensal_dados /* CONFIRMAR */
DO:
    /* ---------- */
    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).
    
    IF  aux_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.

    RUN procedures/verifica_transferencia_mensal.p (INPUT  par_cdagetra,
                                                    INPUT  par_nrtransf,
                                                    INPUT  par_vltransf,
                                                    INPUT  par_dttransf,
                                                    INPUT  par_mmtransf,
                                                    INPUT  aux_tpoperac,
                                                    OUTPUT aux_lsdataqd,
                                                    OUTPUT aux_flgderro).

    IF  NOT aux_flgderro THEN
        DO:
    
            /* para quem nao tem letras, pede cpf */
            IF  NOT glb_idsenlet  THEN
                RUN senha_cpf.w (OUTPUT aux_flgderro).
            ELSE
                RUN senha.w (OUTPUT aux_flgderro).
        
            IF  NOT aux_flgderro THEN
                DO:
                    /* puxa o frame principal */
                    h_principal:MOVE-TO-TOP().
        
                    RUN procedures/efetua_transferencia_mensal.p (INPUT  par_cdagetra,
                                                                  INPUT  par_nrtransf,
                                                                  INPUT  par_vltransf,
                                                                  INPUT  par_dttransf, 
                                                                  INPUT  par_mmtransf,
                                                                  INPUT  aux_lsdataqd, 
                                                                  INPUT  aux_tpoperac,
                                                                  OUTPUT aux_flgderro,
                                                                  OUTPUT aux_idastcjt).
                    
                    IF  NOT aux_flgderro THEN
                        DO:
                                                RUN procedures/inicializa_dispositivo.p ( INPUT 6,
                                                                     OUTPUT aux_flgderro).
                
                            /* se a impressora estiver habilitada, com papel e 
                               transferencia efetuada com sucesso */
                            IF  xfs_impressora       AND
                                NOT xfs_impsempapel  AND
                                NOT aux_flgderro     AND 
                                aux_idastcjt = 0     THEN
                                RUN imprime_comprovante.
                        END.
                    ELSE /* Erro na rotina */
                        DO:
                            h_principal:MOVE-TO-BOTTOM().
                            h_inicializando:MOVE-TO-BOTTOM().

                            ASSIGN par_flgderro = aux_flgderro.

                            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
                            RETURN "NOK".
                        END.
                END.
        END.
    /* repassa o retorno */
    RETURN RETURN-VALUE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_agen_trans_mensal_dados
ON ANY-KEY OF Btn_H IN FRAME f_cartao_agen_trans_mensal_dados /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_agen_trans_mensal_dados
ON CHOOSE OF Btn_H IN FRAME f_cartao_agen_trans_mensal_dados /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_cartao_agen_trans_mensal_dados OCX.Tick
PROCEDURE temporizador.t_cartao_agen_trans_mensal_dados.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_cartao_agen_trans_mensal_dados.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_cartao_agen_trans_mensal_dados 


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
                                                    
    /* carrega dados */                             
    aux_tpoperac = IF (glb_cdagectl = par_cdagetra) THEN
                      1  /* Intra Coop. */
                   ELSE
                      5. /* Inter Coop. */

    ed_dscooper = par_dsagetra.
    ed_nrtransf = par_nrtransf.
    ed_nmtransf = par_nmtransf[1].

    IF  aux_nmtransf[2] <> ""  THEN
        ed_nmtransf = ed_nmtransf + CHR(13) + aux_nmtransf[2].

    ed_vltransf = par_vltransf.

    ed_dttransf = "No dia " + STRING(par_ddtransf) + " de cada mês" +
                                ", durante " + STRING(par_mmtransf) + " meses, " +
                                "iniciando em " + STRING(MONTH(par_dttransf),"99") + "/" +
                                                  STRING(YEAR(par_dttransf),"9999").
                                     
    DISPLAY ed_dscooper
            ed_nrtransf
            ed_nmtransf 
            ed_vltransf
            ed_dttransf WITH FRAME f_cartao_agen_trans_mensal_dados.

    /* deixa o mouse transparente */
    FRAME f_cartao_agen_trans_mensal_dados:LOAD-MOUSE-POINTER("blank.cur").
    
    chtemporizador:t_cartao_agen_trans_mensal_dados:INTERVAL = glb_nrtempor.
    
    APPLY "ENTRY" TO Btn_H.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_cartao_agen_trans_mensal_dados  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_agendamento_transferencia_mensal_dados.wrx":U ).
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
ELSE MESSAGE "cartao_agendamento_transferencia_mensal_dados.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_cartao_agen_trans_mensal_dados  _DEFAULT-DISABLE
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
  HIDE FRAME f_cartao_agen_trans_mensal_dados.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_cartao_agen_trans_mensal_dados  _DEFAULT-ENABLE
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
  DISPLAY ed_dscooper ed_nrtransf ed_nmtransf ed_vltransf ed_dttransf 
      WITH FRAME f_cartao_agen_trans_mensal_dados.
  ENABLE IMAGE-37 IMAGE-40 RECT-144 RECT-147 RECT-153 RECT-154 RECT-155 
         RECT-156 ed_dscooper ed_nrtransf ed_nmtransf ed_vltransf ed_dttransf 
         Btn_D Btn_H 
      WITH FRAME f_cartao_agen_trans_mensal_dados.
  {&OPEN-BROWSERS-IN-QUERY-f_cartao_agen_trans_mensal_dados}
  VIEW w_cartao_agen_trans_mensal_dados.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE imprime_comprovante w_cartao_agen_trans_mensal_dados 
PROCEDURE imprime_comprovante :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEF VAR tmp_tximpres    AS CHAR                     NO-UNDO.
DEF VAR aux_nmtitula    AS CHAR     EXTENT 2        NO-UNDO.
DEF VAR aux_flgmigra    AS LOGICAL                  NO-UNDO.
DEF VAR aux_flgdinss    AS LOGICAL                  NO-UNDO.
DEF VAR aux_flgbinss    AS LOGICAL                  NO-UNDO.

DEFINE VARIABLE    aux_nrtelsac     AS CHARACTER                NO-UNDO.
DEFINE VARIABLE    aux_nrtelouv     AS CHARACTER                NO-UNDO.

RUN procedures/obtem_informacoes_comprovante.p (OUTPUT aux_nrtelsac,
                                                OUTPUT aux_nrtelouv,
                                                OUTPUT aux_flgderro).

RUN procedures/busca_associado.p (INPUT  par_nrtransf,
                                  INPUT  par_cdagetra, /* DADOS */
                                  OUTPUT aux_cdagectl,
                                  OUTPUT aux_nmrescop,
                                  OUTPUT aux_nmtransf,
                                  OUTPUT aux_flgmigra,
                                  OUTPUT aux_flgdinss,
                                  OUTPUT aux_flgbinss,
                                  OUTPUT aux_flgderro).

/* São 48 caracteres */

/* centraliza o cabeçalho */
ASSIGN tmp_tximpres = TRIM(glb_nmrescop) + " AUTOATENDIMENTO"
       tmp_tximpres = FILL(" ",INT((48 - LENGTH(tmp_tximpres)) / 2)) + tmp_tximpres
       tmp_tximpres = tmp_tximpres + FILL(" ",48 - length(tmp_tximpres))
       tmp_tximpres = tmp_tximpres +
                      "                                                "   +
                      "EMISSAO: " + STRING(TODAY,"99/99/9999") + "      "  +
                              "               " + STRING(TIME,'HH:MM:SS')  +
                      "                                                "   +
                      "COOPERATIVA/PA/TERMINAL: " + STRING(glb_agctltfn,"9999") + "/" +
                                                    STRING(glb_cdagetfn,"9999") + "/" +
                                                    STRING(glb_nrterfin,"9999") +
                                                             "         " +
                      "                                                " +
                      "                                                " +
                      "          COMPROVANTE DE AGENDAMENTO DE         " +
                      "               TRANSFERENCIA MENSAL             " +
                      "                                                " + 
                      "DE                                              " + 
                      "COOPERATIVA: " + STRING(glb_cdagectl,"9999")      +
                      " - "           + STRING(glb_nmrescop,"x(28)")     +
                      "CONTA: " + STRING(glb_nrdconta,"zzzz,zzz,9")      +
                          " - " + STRING(glb_nmtitula[1],"x(28)").

IF  glb_nmtitula[2] <> ""  THEN
    tmp_tximpres = tmp_tximpres +
                   "                    " + STRING(glb_nmtitula[2],"x(28)").


tmp_tximpres = tmp_tximpres +               
               "                                                "  +
               "PARA                                            "  +
               "COOPERATIVA: " + STRING(ed_dscooper,"x(35)")       +  
               "CONTA: " + STRING(par_nrtransf,"zzzz,zzz,9")       +
               " - " + STRING(aux_nmtransf[1],"x(28)").


IF  par_nmtransf[2] <> ""  THEN
    tmp_tximpres = tmp_tximpres +
                   "                    " + 
                   STRING(aux_nmtransf[2],"x(28)").
                   
tmp_tximpres = tmp_tximpres +
               "                                                " +
               "DATA DO AGENDAMENTO:                            " +
               "                                                " +
               "     NO DIA " + STRING(par_ddtransf, "z9")        +
               " DE CADA MES, DURANTE " + STRING(par_mmtransf, "z9") +
               " MESES,   "                                       +
               "     INICIANDO EM " + STRING(MONTH(par_dttransf),"99") + "/" +
                                      STRING(YEAR(par_dttransf),"9999") +
                                        "                       " +
               "                                                " +           
               "     VALOR: " + STRING(par_vltransf,"zz,zz9.99")  +
                                    "                           " +
               "                                                " +
               " A QUITACAO EFETIVA DESTE AGENDAMENTO DEPENDERA " +
               "DA EXISTENCIA DE SALDO NA SUA CONTA CORRENTE NA " +
               "          DATA ESCOLHIDA PARA DEBITO.           " +
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
    DO: 
        RUN impressao_visualiza.w (INPUT "Comprovante...",
                                   INPUT  tmp_tximpres,
                                   INPUT 0, /*Comprovante*/
                                   INPUT "").
        APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
        RETURN "OK".
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_cartao_agen_trans_mensal_dados 
PROCEDURE tecla :
chtemporizador:t_cartao_agen_trans_mensal_dados:INTERVAL = 0.
        
    IF  KEY-FUNCTION(LASTKEY) = "D"                                AND
        Btn_D:SENSITIVE IN FRAME f_cartao_agen_trans_mensal_dados  THEN
        DO:
           
            APPLY "CHOOSE" TO Btn_D.

            IF  RETURN-VALUE = "OK"  THEN
                DO:
                    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
                    RETURN "OK".
                END.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                                AND
        Btn_H:SENSITIVE IN FRAME f_cartao_agen_trans_mensal_dados  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_cartao_agen_trans_mensal_dados:INTERVAL = glb_nrtempor.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

