&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_debaut_aceite
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_debaut_aceite 
/* ...........................................................................

Procedure: cartao_pagamento_debaut_cadastrar_aceite.w
Objetivo : Tela para apresentar o termo de aceite na contratação do Deb. Aut. [PROJ320]
Autor    : Lucas Lunelli
Data     : Maio/2016

Ultima alteração: 

............................................................................ */

/*------------------------------------------------------------------------*/
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

DEFINE INPUT  PARAM par_dscodbar    AS CHAR                       NO-UNDO.
DEFINE INPUT  PARAM par_cdbarra1    AS CHAR                       NO-UNDO.
DEFINE INPUT  PARAM par_cdbarra2    AS CHAR                       NO-UNDO.
DEFINE INPUT  PARAM par_cdbarra3    AS CHAR                       NO-UNDO.
DEFINE INPUT  PARAM par_cdbarra4    AS CHAR                       NO-UNDO.
DEFINE INPUT  PARAM par_cdrefere    AS CHAR                       NO-UNDO.
DEFINE INPUT  PARAM par_vlrmaxdb    AS CHAR                       NO-UNDO.
DEFINE OUTPUT PARAM par_flgderro    AS LOGI                       NO-UNDO.

DEFINE VARIABLE aux_nrDDD           AS DECIMAL                    NO-UNDO.
DEFINE VARIABLE aux_nrtelefo        AS DECIMAL                    NO-UNDO.
DEFINE VARIABLE aux_dsmsgsms        AS CHARACTER                  NO-UNDO.
DEFINE VARIABLE aux_flgderro        AS LOGICAL                    NO-UNDO.
DEFINE VARIABLE aux_nrtelsac        AS CHARACTER                  NO-UNDO.
DEFINE VARIABLE aux_nrtelouv        AS CHARACTER                  NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_debaut_aceite

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_E Btn_F IMAGE-40 IMAGE-37 IMAGE-38 ~
IMAGE-39 ed_aceite Btn_D Btn_H 
&Scoped-Define DISPLAYED-OBJECTS ed_aceite 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_debaut_aceite AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_D 
     LABEL "CONFIRMAR" 
     SIZE 53 BY 3.33
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

DEFINE VARIABLE ed_aceite AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 129 BY 16.67
     FONT 22 NO-UNDO.

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


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_debaut_aceite
     Btn_E AT ROW 9.62 COL 142 WIDGET-ID 68
     Btn_F AT ROW 14.67 COL 142 WIDGET-ID 220
     ed_aceite AT ROW 6.48 COL 11 NO-LABEL WIDGET-ID 228 NO-TAB-STOP 
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 66
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 74
     "DÉBITO AUTOMÁTICO" VIEW-AS TEXT
          SIZE 99 BY 2.95 AT ROW 1.95 COL 31.6 WIDGET-ID 92
          FGCOLOR 1 FONT 10
     IMAGE-40 AT ROW 24.24 COL 156 WIDGET-ID 154
     RECT-101 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-102 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-103 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-37 AT ROW 24.24 COL 1 WIDGET-ID 148
     IMAGE-38 AT ROW 9.29 COL 156 WIDGET-ID 150
     IMAGE-39 AT ROW 14.29 COL 156 WIDGET-ID 222
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 160.2 BY 28.57 WIDGET-ID 100.


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
  CREATE WINDOW w_debaut_aceite ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.57
         WIDTH              = 160
         MAX-HEIGHT         = 34.24
         MAX-WIDTH          = 272.8
         VIRTUAL-HEIGHT     = 34.24
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
ASSIGN w_debaut_aceite = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_debaut_aceite
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_debaut_aceite
   FRAME-NAME                                                           */
ASSIGN 
       ed_aceite:AUTO-INDENT IN FRAME f_debaut_aceite      = TRUE
       ed_aceite:READ-ONLY IN FRAME f_debaut_aceite        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-101 IN FRAME f_debaut_aceite
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-102 IN FRAME f_debaut_aceite
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-103 IN FRAME f_debaut_aceite
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_debaut_aceite:HANDLE
       ROW             = 1.71
       COLUMN          = 7
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_debaut_aceite */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_debaut_aceite
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_debaut_aceite w_debaut_aceite
ON END-ERROR OF w_debaut_aceite
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_debaut_aceite w_debaut_aceite
ON WINDOW-CLOSE OF w_debaut_aceite
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_debaut_aceite
ON ANY-KEY OF Btn_D IN FRAME f_debaut_aceite /* CONFIRMAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_debaut_aceite
ON CHOOSE OF Btn_D IN FRAME f_debaut_aceite /* CONFIRMAR */
DO:
    /* para quem nao tem letras, pede cpf */
    IF  NOT glb_idsenlet  THEN
        RUN senha_cpf.w (OUTPUT aux_flgderro).
    ELSE
        RUN senha.w (OUTPUT aux_flgderro).

    IF  NOT aux_flgderro  THEN
        DO:
             /* puxa o frame principal */
             h_principal:MOVE-TO-TOP().
        
            RUN procedures/inclui_autorizacao_debito.p (INPUT par_dscodbar, 
                                                        INPUT par_cdbarra1, 
                                                        INPUT par_cdbarra2, 
                                                        INPUT par_cdbarra3, 
                                                        INPUT par_cdbarra4,                                                
                                                        INPUT par_cdrefere,
                                                        INPUT par_vlrmaxdb,
                                                       OUTPUT par_flgderro).
            IF  par_flgderro   THEN
                DO:            
                    w_debaut_aceite:MOVE-TO-TOP().
        
                    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                    RETURN "NOK".            
                END.
            ELSE
                DO:
                    /* puxa o frame principal pra frente */
                    h_principal:MOVE-TO-TOP().           
                END.

            /* verifica se finalizou a operacao */
            IF  RETURN-VALUE = "OK"  THEN
                DO:
                    /* puxa o frame principal pra frente */
                    h_principal:MOVE-TO-TOP().   
        
        
                    RUN procedures/obtem_telefone_sms_debaut.p (OUTPUT aux_nrDDD,
                                                                OUTPUT aux_nrtelefo,
                                                                OUTPUT aux_dsmsgsms,
                                                                OUTPUT par_flgderro).
        
                    IF  par_flgderro OR RETURN-VALUE = "NOK" THEN
                        DO:
                            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                            RETURN "NOK".
                        END.
                
                    IF  aux_nrDDD = 0 AND aux_nrtelefo = 0  THEN
                        DO:
                            RUN cartao_pagamento_debaut_oferta_sms.w.

                            IF  RETURN-VALUE = "NOK"  THEN
                                ASSIGN par_flgderro = YES.
                            ELSE
                                ASSIGN par_flgderro = NO.

                            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                            RETURN "OK".
                        END.
                    ELSE 
                        DO:
                            ASSIGN par_flgderro = YES.

                            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                            RETURN "OK".
                        END.
                END.
            ELSE
                DO:
                    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                    RETURN "NOK".
                END.

        END. /* END IF  NOT aux_flgderro  THEN */
        
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_E
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_debaut_aceite
ON ANY-KEY OF Btn_E IN FRAME f_debaut_aceite /* SOBRE */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_debaut_aceite
ON CHOOSE OF Btn_E IN FRAME f_debaut_aceite /* SOBRE */
DO:
    ed_aceite:CURSOR-LINE = 1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_F
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_debaut_aceite
ON ANY-KEY OF Btn_F IN FRAME f_debaut_aceite /* DESCE */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_debaut_aceite
ON CHOOSE OF Btn_F IN FRAME f_debaut_aceite /* DESCE */
DO:
    ed_aceite:CURSOR-LINE = ed_aceite:NUM-LINES.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_debaut_aceite
ON ANY-KEY OF Btn_H IN FRAME f_debaut_aceite /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_debaut_aceite
ON CHOOSE OF Btn_H IN FRAME f_debaut_aceite /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_debaut_aceite OCX.Tick
PROCEDURE temporizador.t_debaut_aceite.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_debaut_aceite.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_debaut_aceite 


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

    RUN procedures/obtem_informacoes_comprovante.p (OUTPUT aux_nrtelsac,
                                                    OUTPUT aux_nrtelouv,
                                                    OUTPUT aux_flgderro).
    IF  aux_flgderro THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "NOK".
        END.

    IF NOT aux_flgderro THEN
       DO:
           /* Carrega o extrato no editor */ 
           ASSIGN ed_aceite:SCREEN-VALUE =
                "ACEITE/CONFIRMAÇÃO DA AUTORIZAÇÃO DE DÉBITO AUTOMÁTICO " + CHR(13) + CHR(13) +
                "De acordo com o Contrato de Abertura de Conta Corrente que dispõe sobre a " +
                "contratação dos serviços de Débitos Automáticos, e com o Termo de Responsabilidade " +
                "para Acesso e Movimentação da Conta por Meio dos Canais de Autoatendimento, autorizo " +
                "a realização dos débitos em minha conta, provenientes da empresa conveniada " + 
                "devidamente selecionada por mim indicada neste ato." + CHR(13) +
                "Declaro que estou ciente e concordo com as seguintes condições relacionadas " + 
                "ao serviço de débito automático:" + CHR(13) + CHR(13) +
                "- Realizado o cadastro e a confirmação do débito automático, o primeiro pagamento " + 
                "ocorrerá apenas após o agendamento do débito pela empresa conveniada, o qual pode ser " +
                "acompanhado pela conta corrente;" + CHR(13) +
                "- É de minha responsabilidade o acompanhamento, bem como a confirmação dos débitos " + 
                "automáticos cadastrados. Constatando a não ocorrência do primeiro débito, deverei " +
                "entrar em contato com o meu Posto de Atendimento ou ainda com o SAC (Serviço de " + 
                "Atendimento ao Cooperado), através do telefone " + TRIM(STRING(aux_nrtelsac, "x(20)"))  + ";" + CHR(13) +
                "- Os valores e datas de vencimentos das faturas são de responsabilidade da empresa " + 
                "prestadora do serviço, por mim indicada neste ato;" + CHR(13) +
                "- Os valores das faturas apenas serão debitados caso a conta corrente apresente saldo " +
                "suficiente no dia de vencimento, e desde que o valor por mim definido como limite " + 
                "máximo para débitos não seja ultrapassado, ficando sob minha responsabilidade o " +
                "pagamento das faturas por outros meios;" + CHR(13) +
                "- A solicitação de débito automático autorizada diretamente na Cooperativa, poderá " +
                "ser cancelada de forma presencial, por meio da conta online ou pelos terminais de " + 
                "autoatendimento, por solicitação da empresa conveniada ou ainda, pela Cooperativa " + 
                "por falta de movimentação de débito." + CHR(13) +
                "- Caso a solicitação de débito automático seja autorizada diretamente na empresa " + 
                "conveniada, essa somente poderá ser cancelada, mediante solicitação a própria empresa." + CHR(13) + CHR(13) +
                "Esta autorização surtirá efeitos a partir da data da confirmação, por meio de digitação " +
                "de minha senha de uso pessoal e intransferível, e vigorará por prazo indeterminado.".
       END.

    APPLY "ENTRY" TO Btn_H.

    /* deixa o mouse transparente */
    FRAME f_debaut_aceite:LOAD-MOUSE-POINTER("blank.cur").

    RUN reset_temporizador.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_debaut_aceite  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_pagamento_debaut_cadastrar_aceite.wrx":U ).
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
ELSE MESSAGE "cartao_pagamento_debaut_cadastrar_aceite.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_debaut_aceite  _DEFAULT-DISABLE
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
  HIDE FRAME f_debaut_aceite.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_debaut_aceite  _DEFAULT-ENABLE
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
  DISPLAY ed_aceite 
      WITH FRAME f_debaut_aceite.
  ENABLE Btn_E Btn_F IMAGE-40 IMAGE-37 IMAGE-38 IMAGE-39 ed_aceite Btn_D Btn_H 
      WITH FRAME f_debaut_aceite.
  {&OPEN-BROWSERS-IN-QUERY-f_debaut_aceite}
  VIEW w_debaut_aceite.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reset_temporizador w_debaut_aceite 
PROCEDURE reset_temporizador :
chtemporizador:t_debaut_aceite:INTERVAL = 60000. /* 60 segundos */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_debaut_aceite 
PROCEDURE tecla :
chtemporizador:t_debaut_aceite:INTERVAL = 0.

    IF  KEY-FUNCTION(LASTKEY) = "D"                     AND
        Btn_D:SENSITIVE IN FRAME f_debaut_aceite THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "E"                     AND
        Btn_E:SENSITIVE IN FRAME f_debaut_aceite THEN
        APPLY "CHOOSE" TO Btn_E.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "F"                     AND
        Btn_F:SENSITIVE IN FRAME f_debaut_aceite THEN
        APPLY "CHOOSE" TO Btn_F.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                     AND
        Btn_H:SENSITIVE IN FRAME f_debaut_aceite THEN
        APPLY "CHOOSE" TO Btn_H.
    
    RUN reset_temporizador.

    IF NOT CAN-DO("D,E,F,H",KEY-FUNCTION(LASTKEY)) THEN
       RETURN NO-APPLY.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

