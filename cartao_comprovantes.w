&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_cartao_agendamento_lista
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_cartao_agendamento_lista 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 
  
  18/07/2013 - Correção número da agencia da cooperativa (Lucas).
  
  07/11/2013 - Alterado Posto de Atendimento ao Cooperado para
                               Posto de Atendimento "PA". (Jorge)
                               
  20/08/2015 - Adicionado SAC e OUVIDORIA nos comprovantes
               e visualização de impressão
              (Lucas Lunelli - Melhoria 83 [SD 279180])

  23/03/2017 - Adicionado recarga de celular nos comprovantes e 
                           visualização de impressão. (PRJ321 - Reinert)

  21/06/2017 - Ajustes PRJ340 - NPC(Odirlei AMcom).
  
  25/01/2018 - #824366 Inclusão da data de transferência na rotina
               imprime_transferencia (Carlos)

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

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }

DEF INPUT PARAM par_dtinipro AS DATE                            NO-UNDO.
DEF INPUT PARAM par_dtfimpro AS DATE                            NO-UNDO.

DEFINE TEMP-TABLE tt-comprovantes NO-UNDO                     
       FIELD dtmvtolt AS DATE  /* Data do comprovantes       */
       FIELD dscedent AS CHAR  /* Descricao do comprovante   */
       FIELD vldocmto AS DECI  /* Valor do documento         */
       FIELD dsinform AS CHAR  /* Tipo de pagamento          */
       FIELD lndigita AS CHAR  /* Linha digitavel            */
       FIELD nrtransf AS INTE  /* Conta transferencia        */
       FIELD nmtransf AS CHAR EXTENT 2  /* Nome conta acima  */
       FIELD tpdpagto AS CHAR
       FIELD dsprotoc AS CHAR
       FIELD cdbcoctl AS INTE  /* Banco 085 */
       FIELD cdagectl AS INTE  /* Agencia da cooperativa */
       FIELD dsagectl AS CHAR
           FIELD nrtelefo AS CHAR  /* Nr telefone */
       FIELD nmopetel AS CHAR  /* Nome operadora */
       FIELD dsnsuope AS CHAR /* NSU operadora */
       FIELD dspagador      AS CHAR  /* nome do pagador do boleto */
       FIELD nrcpfcgc_pagad AS CHAR  /* NRCPFCGC_PAGAD */
       FIELD dtvenctit      AS CHAR  /* vencimento do titulo */
       FIELD vlrtitulo      AS CHAR  /* valor do titulo */
       FIELD vlrjurmul      AS CHAR  /* valor de juros + multa */
       FIELD vlrdscaba      AS CHAR  /* valor de desconto + abatimento */
       FIELD nrcpfcgc_benef AS CHAR. /* CPF/CNPJ do beneficiario  */  

DEF TEMP-TABLE tt-bcomprovantes NO-UNDO LIKE tt-comprovantes.

/*
DEFINE TEMP-TABLE tt-comprovantes NO-UNDO                     
       FIELD dtmvtolt AS DATE   /* Data do comprovantes       */
       FIELD dscedent AS CHAR   /* Descricao do comprovante   */
       FIELD vldocmto AS DECI   /* Valor do documento         */
       FIELD dsinform AS CHAR   /* Tipo de pagamento          */
       FIELD lndigita AS CHAR   /* Linha digitavel            */
       FIELD nrtransf AS INTE   /* Conta transferencia        */
       FIELD nmtransf AS CHAR EXTENT 2  /* Nome conta acima  */ 
       FIELD tpdpagto AS CHAR
       FIELD dsprotoc AS CHAR
       FIELD cdbcoctl AS INTE
       FIELD cdagectl AS INTE
       FIELD dsagectl AS CHAR
       FIELD dspagador      AS CHAR  /* nome do pagador do boleto */
       FIELD nrcpfcgc_pagad AS CHAR  /* NRCPFCGC_PAGAD */
       FIELD dtvenctit      AS CHAR  /* vencimento do titulo */
       FIELD vlrtitulo      AS CHAR  /* valor do titulo */
       FIELD vlrjurmul      AS CHAR  /* valor de juros + multa */
       FIELD vlrdscaba      AS CHAR  /* valor de desconto + abatimento */
       FIELD nrcpfcgc_benef AS CHAR. /* CPF/CNPJ do beneficiario  */  
*/
EMPTY TEMP-TABLE tt-comprovantes.

DEFINE VARIABLE aux_flgderro        AS LOGICAL                  NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_comprovantes_lista
&Scoped-define BROWSE-NAME b_comprovantes

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-comprovantes

/* Definitions for BROWSE b_comprovantes                                */
&Scoped-define FIELDS-IN-QUERY-b_comprovantes tt-comprovantes.dtmvtolt tt-comprovantes.dscedent tt-comprovantes.vldocmto tt-comprovantes.dsinform   
&Scoped-define ENABLED-FIELDS-IN-QUERY-b_comprovantes   
&Scoped-define SELF-NAME b_comprovantes
&Scoped-define OPEN-QUERY-b_comprovantes DO:     OPEN QUERY b_comprovantes FOR EACH tt-comprovantes NO-LOCK INDEXED-REPOSITION.     APPLY "VALUE-CHANGED" TO b_comprovantes. END.
&Scoped-define TABLES-IN-QUERY-b_comprovantes tt-comprovantes
&Scoped-define FIRST-TABLE-IN-QUERY-b_comprovantes tt-comprovantes


/* Definitions for FRAME f_comprovantes_lista                           */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f_comprovantes_lista ~
    ~{&OPEN-QUERY-b_comprovantes}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_E IMAGE-37 IMAGE-40 Btn_F IMAGE-38 ~
IMAGE-39 RECT-149 b_comprovantes Btn_D Btn_H ed_lndigita 
&Scoped-Define DISPLAYED-OBJECTS ed_lndigita 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_cartao_agendamento_lista AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_D 
     LABEL "IMPRIMIR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_E 
     IMAGE-UP FILE "Imagens/seta_up.gif":U NO-FOCUS
     LABEL "SOBRE" 
     SIZE 13.4 BY 2.38
     FONT 8.

DEFINE BUTTON Btn_F 
     IMAGE-UP FILE "Imagens/seta_down.gif":U NO-FOCUS
     LABEL "DESCE" 
     SIZE 13.4 BY 2.29
     FONT 8.

DEFINE BUTTON Btn_H 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_lndigita AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 140.4 BY 1.38
     FONT 14 NO-UNDO.

DEFINE IMAGE IMAGE-37
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-38
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-39
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-40
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE RECTANGLE RECT-100
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 2 .

DEFINE RECTANGLE RECT-149
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 136 BY 15.95.

DEFINE RECTANGLE RECT-98
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-99
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 14 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b_comprovantes FOR 
      tt-comprovantes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b_comprovantes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b_comprovantes w_cartao_agendamento_lista _FREEFORM
  QUERY b_comprovantes DISPLAY
      tt-comprovantes.dtmvtolt  COLUMN-LABEL "Data"      FORMAT "99/99/99"
tt-comprovantes.dscedent  COLUMN-LABEL "Descrição" FORMAT "x(28)"
tt-comprovantes.vldocmto  COLUMN-LABEL "Valor"     FORMAT "zzz,zz9.99"  
tt-comprovantes.dsinform  COLUMN-LABEL "Tipo"      FORMAT "x(20)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 134 BY 14.29
         FONT 14 ROW-HEIGHT-CHARS 1.29 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_comprovantes_lista
     Btn_E AT ROW 9.62 COL 142 WIDGET-ID 68
     Btn_F AT ROW 14.67 COL 142 WIDGET-ID 220
     b_comprovantes AT ROW 6.29 COL 6 WIDGET-ID 200
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 66
     Btn_H AT ROW 24.14 COL 94.4 WIDGET-ID 74
     ed_lndigita AT ROW 20.71 COL 3 COLON-ALIGNED NO-LABEL WIDGET-ID 216 NO-TAB-STOP 
     "COMPROVANTES" VIEW-AS TEXT
          SIZE 82 BY 2.14 AT ROW 1.95 COL 43 WIDGET-ID 226
          FGCOLOR 1 FONT 10
     "* Serão exibidos até 100 registros." VIEW-AS TEXT
          SIZE 79 BY 1.38 AT ROW 22.38 COL 5 WIDGET-ID 228
          FGCOLOR 7 FONT 11
     IMAGE-37 AT ROW 24.29 COL 1 WIDGET-ID 148
     IMAGE-40 AT ROW 24.29 COL 156 WIDGET-ID 154
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-38 AT ROW 9.29 COL 156 WIDGET-ID 150
     IMAGE-39 AT ROW 14.29 COL 156 WIDGET-ID 222
     RECT-149 AT ROW 6 COL 5 WIDGET-ID 224
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 160 BY 28.67 WIDGET-ID 100.


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
  CREATE WINDOW w_cartao_agendamento_lista ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.67
         WIDTH              = 160
         MAX-HEIGHT         = 34.29
         MAX-WIDTH          = 272.8
         VIRTUAL-HEIGHT     = 34.29
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
ASSIGN w_cartao_agendamento_lista = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_cartao_agendamento_lista
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_comprovantes_lista
   FRAME-NAME                                                           */
/* BROWSE-TAB b_comprovantes RECT-149 f_comprovantes_lista */
ASSIGN 
       ed_lndigita:READ-ONLY IN FRAME f_comprovantes_lista        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_comprovantes_lista
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_comprovantes_lista
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_comprovantes_lista
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b_comprovantes
/* Query rebuild information for BROWSE b_comprovantes
     _START_FREEFORM
DO:
    OPEN QUERY b_comprovantes FOR EACH tt-comprovantes NO-LOCK INDEXED-REPOSITION.
    APPLY "VALUE-CHANGED" TO b_comprovantes.
END.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b_comprovantes */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_comprovantes_lista:HANDLE
       ROW             = 1.95
       COLUMN          = 5
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_comprovantes_lista */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_cartao_agendamento_lista
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_agendamento_lista w_cartao_agendamento_lista
ON END-ERROR OF w_cartao_agendamento_lista
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_agendamento_lista w_cartao_agendamento_lista
ON WINDOW-CLOSE OF w_cartao_agendamento_lista
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_agendamento_lista
ON ANY-KEY OF Btn_D IN FRAME f_comprovantes_lista /* IMPRIMIR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_agendamento_lista
ON CHOOSE OF Btn_D IN FRAME f_comprovantes_lista /* IMPRIMIR */
DO:        
    IF   NOT AVAIL tt-comprovantes  THEN
         RETURN.       

    RUN procedures/inicializa_dispositivo.p ( INPUT 6,
                                             OUTPUT aux_flgderro).               

    /* Se impressora ok e tem papel */
    IF   xfs_impressora       AND
         NOT xfs_impsempapel  THEN      
         DO:
             /* puxa o frame principal */
             h_principal:MOVE-TO-TOP().

             RUN procedures/gera_estatistico.p (INPUT 15,
                                               OUTPUT aux_flgderro). 

             IF   NOT aux_flgderro   THEN
                  DO:                    
                      IF   tt-comprovantes.dsinform = "Transferencia"   THEN
                           RUN imprime_transferencia.
                      ELSE
                      IF   tt-comprovantes.dsinform BEGINS "Pagamento"   THEN
                           DO:
                               IF   TRIM(tt-comprovantes.tpdpagto) BEGINS "Banco"    THEN
                                    RUN imprime_pagamento_titulo.
                               ELSE
                               IF   TRIM(tt-comprovantes.tpdpagto) BEGINS "Convenio" THEN
                                    RUN imprime_pagamento_convenio.         
                           END.
                      ELSE
                      IF   tt-comprovantes.dsinform = "Recarga de celular" THEN
                           RUN imprime_recarga_celular.
                  END.
 
             APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.

             RETURN "OK".
                   
         END.

    RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_E
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_cartao_agendamento_lista
ON ANY-KEY OF Btn_E IN FRAME f_comprovantes_lista /* SOBRE */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_cartao_agendamento_lista
ON CHOOSE OF Btn_E IN FRAME f_comprovantes_lista /* SOBRE */
DO:
   APPLY "CURSOR-UP" TO b_comprovantes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_F
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_cartao_agendamento_lista
ON ANY-KEY OF Btn_F IN FRAME f_comprovantes_lista /* DESCE */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_cartao_agendamento_lista
ON CHOOSE OF Btn_F IN FRAME f_comprovantes_lista /* DESCE */
DO:
  APPLY "CURSOR-DOWN" TO b_comprovantes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_agendamento_lista
ON ANY-KEY OF Btn_H IN FRAME f_comprovantes_lista /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_agendamento_lista
ON CHOOSE OF Btn_H IN FRAME f_comprovantes_lista /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b_comprovantes
&Scoped-define SELF-NAME b_comprovantes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_comprovantes w_cartao_agendamento_lista
ON VALUE-CHANGED OF b_comprovantes IN FRAME f_comprovantes_lista
DO:
    ed_lndigita:SCREEN-VALUE = tt-comprovantes.lndigita.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_cartao_agendamento_lista OCX.Tick
PROCEDURE temporizador.t_cartao_comprovantes_lista.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_comprovantes_lista.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_cartao_agendamento_lista 


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

     /* Se periodo nao informado, colocar o 1 dia do mes corrente e dia corrente*/
    IF  par_dtinipro = ?   AND
        par_dtfimpro = ?   THEN
        DO:
            ASSIGN par_dtinipro = DATE(MONTH(glb_dtmvtolt),
                                       1,
                                       YEAR(glb_dtmvtolt))
                   par_dtfimpro = glb_dtmvtolt.
        END.
     
    RUN procedures/obtem_comprovantes.p (INPUT par_dtinipro,
                                         INPUT par_dtfimpro,
                                        OUTPUT aux_flgderro,
                                        OUTPUT TABLE tt-comprovantes).

    IF  NOT aux_flgderro THEN
        IF  CAN-FIND(FIRST tt-comprovantes) THEN
            DO:
                APPLY "OPEN_QUERY" TO b_comprovantes.
            END.
        ELSE
            DO:    
                RUN mensagem.w (INPUT YES,
                                INPUT "    ATENÇÃO",
                                INPUT "",
                                INPUT "",
                                INPUT "Não existem comprovantes",
                                INPUT "para serem listados.",
                                INPUT "").
                
                PAUSE 4 NO-MESSAGE.
                h_mensagem:HIDDEN = YES.
                
                APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                RETURN "NOK".
            END.
        
    RUN enable_UI.
        
    RUN procedures/inicializa_dispositivo.p ( INPUT 6,
                                             OUTPUT aux_flgderro).

    /* se a impressora estiver desabilitada ou sem papel */ 
    IF  NOT xfs_impressora  OR 
        xfs_impsempapel     THEN
        DISABLE Btn_D WITH FRAME f_comprovantes_lista.
      
    APPLY "ENTRY" TO Btn_H.          

    /* deixa o mouse transparente */
    b_comprovantes:LOAD-MOUSE-POINTER("blank.cur").
    FRAME f_comprovantes_lista:LOAD-MOUSE-POINTER("blank.cur").
    
    chtemporizador:t_cartao_comprovantes_lista:INTERVAL = glb_nrtempor.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_cartao_agendamento_lista  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_comprovantes.wrx":U ).
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
ELSE MESSAGE "cartao_comprovantes.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_cartao_agendamento_lista  _DEFAULT-DISABLE
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
  HIDE FRAME f_comprovantes_lista.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_cartao_agendamento_lista  _DEFAULT-ENABLE
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
  DISPLAY ed_lndigita 
      WITH FRAME f_comprovantes_lista.
  ENABLE Btn_E IMAGE-37 IMAGE-40 Btn_F IMAGE-38 IMAGE-39 RECT-149 
         b_comprovantes Btn_D Btn_H ed_lndigita 
      WITH FRAME f_comprovantes_lista.
  {&OPEN-BROWSERS-IN-QUERY-f_comprovantes_lista}
  VIEW w_cartao_agendamento_lista.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE imprime_pagamento_convenio w_cartao_agendamento_lista 
PROCEDURE imprime_pagamento_convenio :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


DEFINE VARIABLE    tmp_tximpres     AS CHARACTER                NO-UNDO.
DEFINE VARIABLE    tmp_inestorn     AS INT                      NO-UNDO.

DEFINE VARIABLE    aux_nrtelsac     AS CHARACTER                NO-UNDO.
DEFINE VARIABLE    aux_nrtelouv     AS CHARACTER                NO-UNDO.

/* São 48 caracteres */

RUN procedures/obtem_informacoes_comprovante.p (OUTPUT aux_nrtelsac,
                                                OUTPUT aux_nrtelouv,
                                                OUTPUT aux_flgderro).

/* centraliza o cabeçalho - Coop do Associado */

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
                      "                                                "
       tmp_tximpres = tmp_tximpres +
                      "            COMPROVANTE DE PAGAMENTO            "

       tmp_tximpres = tmp_tximpres +
                      "                                                " +
                      "  BANCO: " + STRING(tt-comprovantes.cdbcoctl, "999")

        tmp_tximpres = tmp_tximpres +
                      "                                    "             +
                      "AGENCIA: " + STRING(tt-comprovantes.cdagectl, "9999")
    
       tmp_tximpres = tmp_tximpres +
                      "                                   "              +
                      "  CONTA: " + STRING(glb_nrdconta,"zzzz,zzz,9")    +
                      " - " + STRING(glb_nmtitula[1],"x(26)").

/* Segundo titular */
IF  glb_nmtitula[2] <> ""  THEN
    tmp_tximpres = tmp_tximpres +
                   "                    " + STRING(glb_nmtitula[2],"x(28)").

ASSIGN tmp_tximpres = tmp_tximpres +
               "                                                " +
               "                                                " +
               CAPS(STRING(tt-comprovantes.tpdpagto,"x(48)"))     +  
               "                                                ".

       tmp_tximpres = tmp_tximpres +
               "  DATA DO PAGAMENTO: "  +
               STRING(tt-comprovantes.dtmvtolt,"99/99/9999") +                                                   
               "                 ".

ASSIGN tmp_tximpres = tmp_tximpres +
               "                                                " +
               " VALOR DO PAGAMENTO: " + 
               STRING(tt-comprovantes.vldocmto,"zz,zz9.99")       + 
                                             "                  " +
               "                                                " +
               CAPS(SUBSTRING(tt-comprovantes.lndigita,1,44))     + "    " +
               "                 " + 
               SUBSTRING(tt-comprovantes.lndigita,46,27) + "    " +         
               "                                                " +
               "   PROTOCOLO: " + STRING(tt-comprovantes.dsprotoc,"x(29)") + 
               "     "

       tmp_inestorn = INDEX(tt-comprovantes.dsprotoc,"ESTORNADO").


IF  tmp_inestorn > 0  THEN
    tmp_tximpres = tmp_tximpres + "              " +
                   STRING(SUBSTRING(tt-comprovantes.dsprotoc,tmp_inestorn),"x(33)") +
                   " ".
       
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE imprime_pagamento_titulo w_cartao_agendamento_lista 
PROCEDURE imprime_pagamento_titulo :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/



DEFINE VARIABLE    tmp_tximpres     AS CHARACTER                NO-UNDO.
DEFINE VARIABLE    tmp_inestorn     AS INT                      NO-UNDO.

DEFINE VARIABLE    aux_nrtelsac     AS CHARACTER                NO-UNDO.
DEFINE VARIABLE    aux_nrtelouv     AS CHARACTER                NO-UNDO.


EMPTY TEMP-TABLE tt-bcomprovantes.
CREATE tt-bcomprovantes.
BUFFER-COPY tt-comprovantes TO tt-bcomprovantes.


RUN procedures/imprime_comprov_pag_titulo.p (INPUT "",
                                             INPUT TABLE tt-bcomprovantes,
                                             OUTPUT aux_flgderro).


/* São 48 caracteres */
/*
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
                                                             "         "
       tmp_tximpres = tmp_tximpres +
                      "                                                " +
                      "            COMPROVANTE DE PAGAMENTO            " +
                      "                                                "

       tmp_tximpres = tmp_tximpres +
                      "  BANCO: " + STRING(tt-comprovantes.cdbcoctl, "999")

        tmp_tximpres = tmp_tximpres +
                      "                                    "             +
                      "AGENCIA: " + STRING(tt-comprovantes.cdagectl, "9999")
    
       tmp_tximpres = tmp_tximpres +
                      "                                   "              +
                      "  CONTA: " + STRING(glb_nrdconta,"zzzz,zzz,9")    +
                      " - " + STRING(glb_nmtitula[1],"x(26)").

/* Segundo titular */
IF  glb_nmtitula[2] <> ""  THEN
    tmp_tximpres = tmp_tximpres +
                   "                    " + STRING(glb_nmtitula[2],"x(28)").


ASSIGN tmp_tximpres = tmp_tximpres +
               "                                                " +
               "                                                " +
               CAPS(STRING(tt-comprovantes.tpdpagto,"x(48)"))     +
               "                                                "
       tmp_tximpres = tmp_tximpres +
                       "  DATA DO PAGAMENTO: " + 
                       STRING(tt-comprovantes.dtmvtolt,"99/99/9999") +
                       "                 "
       tmp_tximpres = tmp_tximpres +               
               "                                                "   +
               " VALOR DO PAGAMENTO: " + 
               STRING(tt-comprovantes.vldocmto,"zz,zzz,zz9.99")     +
               "              " +
               "                                                "   +
               CAPS(SUBSTRING(tt-comprovantes.lndigit,1,41))        +
                "       " +  "                 " +
               SUBSTRING(tt-comprovantes.lndigit,43,29) + "  "      +
               "                                                "

       tmp_tximpres = tmp_tximpres +
               "   PROTOCOLO: " + STRING(tt-comprovantes.dsprotoc,"x(29)") + 
               "     "

       tmp_inestorn = INDEX(tt-comprovantes.dsprotoc,"ESTORNADO").

IF  tmp_inestorn > 0  THEN
    tmp_tximpres = tmp_tximpres + "              " +
                   STRING(SUBSTRING(tt-comprovantes.dsprotoc,tmp_inestorn),"x(33)") +
                   " ".

ASSIGN tmp_tximpres = tmp_tximpres +
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
*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE imprime_recarga_celular w_cartao_agendamento_lista 
PROCEDURE imprime_recarga_celular :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEF VAR tmp_tximpres    AS CHAR                     NO-UNDO.
DEF VAR aux_nmtitula    AS CHAR     EXTENT 2        NO-UNDO.
DEFINE VARIABLE    aux_nrtelsac     AS CHARACTER                NO-UNDO.
DEFINE VARIABLE    aux_nrtelouv     AS CHARACTER                NO-UNDO.


/* Sao 48 caracteres */

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
                                                             "         " +
                      "                                                "
       tmp_tximpres = tmp_tximpres +
                      "        COMPROVANTE DE RECARGA DE CELULAR       "
       tmp_tximpres = tmp_tximpres +
                      "                                                " + 
                      "CONTA: " + STRING(glb_nrdconta,"zzzz,zzz,9")      +
                          " - " + STRING(glb_nmtitula[1],"x(28)") +
                      "                                                " +
                      "                  VALOR: " + STRING(tt-comprovantes.vldocmto, "zzz,zz9.99") +
                      "             " +
                      "              OPERADORA: " + STRING(tt-comprovantes.nmopetel, "x(23)") +
                      "           DDD/TELEFONE: " + tt-comprovantes.nrtelefo +
                      "         " + 
                      "          NSU OPERADORA: " + STRING(tt-comprovantes.dsnsuope, "x(23)")
       tmp_tximpres = tmp_tximpres +
                      "                                                " + 
                      "PROTOCOLO: " + STRING(tt-comprovantes.dsprotoc,"x(37)") + 

                      "                                                " +
                      " * A RESPONSABILIDADE DOS DADOS INFORMADOS E DO " +
                      "   COOPERADO;                                   " +
                      " * NAO HA ESTORNO APOS A REALIZACAO DA RECARGA; " +
                      " * EM CASOS DE ERROS NA RECARGA, ENTRE EM       " +
                      "   CONTATO COM A OPERADORA INFORMANDO O NSU.    " +
                      "                                                " +
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE imprime_transferencia w_cartao_agendamento_lista 
PROCEDURE imprime_transferencia :
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

/* centraliza o cabeçalho */  /* Coop do Associado */
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
                      "                                                "
        tmp_tximpres = tmp_tximpres +
                       "          COMPROVANTE DE TRANSFERENCIA          " +
                       "                                                "
        
        tmp_tximpres = tmp_tximpres +
                       "DATA: " + STRING(tt-comprovantes.dtmvtolt,"99/99/9999") + 
                       "                                "

        tmp_tximpres = tmp_tximpres +
                       "                                                "   + 
                       "DE                                              "   +   
                       "COOPERATIVA: " + STRING(glb_cdagectl,"9999")        +
                       " - "           + STRING(glb_nmrescop,"x(28)")       +     
                       "CONTA: " + STRING(glb_nrdconta,"zzzz,zzz,9")  +
                       " - " + STRING(glb_nmtitula[1],"x(28)").

IF  glb_nmtitula[2] <> ""  THEN
    tmp_tximpres = tmp_tximpres +
                   "                    " + STRING(glb_nmtitula[2],"x(28)").

tmp_tximpres = tmp_tximpres +               
               "                                                " +

               "PARA                                            " +
               "COOPERATIVA: " + STRING(tt-comprovantes.dsagectl,"x(35)")               +  
               "CONTA: " +  STRING(tt-comprovantes.nrtransf,"zzzz,zzz,9") + 
               " - " + STRING(tt-comprovantes.nmtransf[1],"x(28)").

                  
IF  tt-comprovantes.nmtransf[2] <> ""  THEN  
    tmp_tximpres = tmp_tximpres +
                   "                   " +
                   STRING(tt-comprovantes.nmtransf[2],"x(28)").
             
tmp_tximpres = tmp_tximpres +
                   "                                                " + 
                   "   PROTOCOLO: " + STRING(tt-comprovantes.dsprotoc,"x(29)") + 
                   "     " +
                   "                                                ". 

tmp_tximpres = tmp_tximpres +
     "              VALOR: " + STRING(tt-comprovantes.vldocmto,"zz,zz9.99")   +
     "                  " +
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_cartao_agendamento_lista 
PROCEDURE tecla :
chtemporizador:t_cartao_comprovantes_lista:INTERVAL = 0.
 
    IF  KEY-FUNCTION(LASTKEY) = "D"                    AND    /* Imprime*/
        Btn_D:SENSITIVE IN FRAME f_comprovantes_lista  THEN
        DO:
            APPLY "CHOOSE" TO Btn_D.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "E"                    AND    /* Sobe */
        Btn_E:SENSITIVE IN FRAME f_comprovantes_lista  THEN
        DO:       
            APPLY "CHOOSE" TO Btn_E.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "F"                    AND    /* Desce */
        Btn_F:SENSITIVE IN FRAME f_comprovantes_lista  THEN
        DO:         
            APPLY "CHOOSE" TO Btn_F.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                    AND    /* Volta*/
        Btn_H:SENSITIVE IN FRAME f_comprovantes_lista  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        DO:
            chtemporizador:t_cartao_comprovantes_lista:INTERVAL = glb_nrtempor.
            RETURN NO-APPLY.
        END.

    chtemporizador:t_cartao_comprovantes_lista:INTERVAL = glb_nrtempor.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

