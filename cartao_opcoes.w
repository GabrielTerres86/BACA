&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_cartao_opcoes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_cartao_opcoes 
/* ..............................................................................

Procedure: cartao_opcoes.w
Objetivo : Tela para apresentar o menu de opcoes do cartao
Autor    : Evandro
Data     : Janeiro 2010

Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

                  04/10/2013 - Ajustes para bloqueio de saque (Jorge).
                  
                  16/09/2014 - Incluido o botao credito pre-aprovado. (James)
                                  
                  13/10/2014 - Incluir mensagem para retirada de papel da
                               impressora (David).

                  13/04/2015 - Adicionado procedure de verificacao de mensagem
                               (emprestimo em atraso) (Jorge/Rodrigo)
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

DEF TEMP-TABLE tt-dados-cpa NO-UNDO
    FIELD vldiscrd AS DECI
    FIELD txmensal AS DECI.

EMPTY TEMP-TABLE tt-dados-cpa.

DEFINE VARIABLE aux_flgderro        AS LOGICAL              NO-UNDO.
DEFINE VARIABLE aux_flagsair        AS LOGICAL              NO-UNDO.
DEFINE VARIABLE aux_flgblsaq        AS LOGICAL              NO-UNDO.
DEFINE VARIABLE aux_flmsgimp        AS LOGICAL      NO-UNDO.
DEFINE VARIABLE aux_contador        AS INTEGER      NO-UNDO.
DEFINE VARIABLE aux_flgblpre        AS LOGICAL              NO-UNDO.
DEFINE VARIABLE aux_flgretur        AS CHAR    INIT "NOK"   NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_cartao_opcoes

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-31 IMAGE-34 IMAGE-35 IMAGE-37 IMAGE-38 ~
IMAGE-40 IMAGE-41 Btn_A Btn_E Btn_B Btn_D Btn_H 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_cartao_opcoes AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_A 
     LABEL "SAQUE" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_B 
     LABEL "PAGAMENTO/TRANSFERÊNCIA" 
     SIZE 61 BY 3.33
     FONT 14.

DEFINE BUTTON Btn_D 
     LABEL "ALTERAÇÃO DE SENHA" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_E 
     LABEL "SALDOS/EXTRATOS" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_F 
     LABEL "CRÉDITO PRÉ-APROVADO" 
     SIZE 61 BY 3.33
     FONT 14.

DEFINE BUTTON Btn_H 
     LABEL "CANCELAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE IMAGE IMAGE-31
     FILENAME "Imagens/logo_interno.jpg":U
     SIZE 63.4 BY 3.57.

DEFINE IMAGE IMAGE-34
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-35
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-37
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-38
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-40
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-41
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

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

DEFINE FRAME f_cartao_opcoes
     Btn_A AT ROW 9.1 COL 6 WIDGET-ID 78
     Btn_E AT ROW 9.1 COL 94.4 WIDGET-ID 68
     Btn_B AT ROW 14.1 COL 6 WIDGET-ID 94
     Btn_F AT ROW 14.1 COL 94.4 WIDGET-ID 156
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 66
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 74
     IMAGE-31 AT ROW 1.48 COL 49.6 WIDGET-ID 112
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-34 AT ROW 9.24 COL 1 WIDGET-ID 142
     IMAGE-35 AT ROW 14.24 COL 1 WIDGET-ID 144
     IMAGE-37 AT ROW 24.24 COL 1 WIDGET-ID 148
     IMAGE-38 AT ROW 9.24 COL 156 WIDGET-ID 150
     IMAGE-40 AT ROW 24.24 COL 156 WIDGET-ID 154
     IMAGE-41 AT ROW 14.24 COL 156 WIDGET-ID 158
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
  CREATE WINDOW w_cartao_opcoes ASSIGN
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
ASSIGN w_cartao_opcoes = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_cartao_opcoes
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_cartao_opcoes
   FRAME-NAME                                                           */
/* SETTINGS FOR BUTTON Btn_F IN FRAME f_cartao_opcoes
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_cartao_opcoes
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_cartao_opcoes
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_cartao_opcoes
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_cartao_opcoes:HANDLE
       ROW             = 2.19
       COLUMN          = 28
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_opcoes */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_cartao_opcoes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_opcoes w_cartao_opcoes
ON END-ERROR OF w_cartao_opcoes
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_opcoes w_cartao_opcoes
ON WINDOW-CLOSE OF w_cartao_opcoes
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_A
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_A w_cartao_opcoes
ON ANY-KEY OF Btn_A IN FRAME f_cartao_opcoes /* SAQUE */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_A w_cartao_opcoes
ON CHOOSE OF Btn_A IN FRAME f_cartao_opcoes /* SAQUE */
DO:
    RUN cartao_saque.w.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_B
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_B w_cartao_opcoes
ON ANY-KEY OF Btn_B IN FRAME f_cartao_opcoes /* PAGAMENTO/TRANSFERÊNCIA */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_B w_cartao_opcoes
ON CHOOSE OF Btn_B IN FRAME f_cartao_opcoes /* PAGAMENTO/TRANSFERÊNCIA */
DO:
    /* verifica o status */
    RUN procedures/inicializa_dispositivo.p ( INPUT 6,
                                             OUTPUT aux_flgderro).
            

    IF  NOT xfs_impressora  THEN  /* nao habilitada ou gerou algum erro */
        DO:
            IF  xfs_imppapelsaida  THEN  
                RUN mensagem.w (INPUT NO,
                                INPUT "    Atenção!",
                                INPUT "",
                                INPUT "Para impressão do comprovante,",
                                INPUT "retire o papel da impressão",
                                INPUT "anterior.",
                                INPUT "").
            ELSE
                RUN mensagem.w (INPUT NO,
                                INPUT "    Atenção!",
                                INPUT "",
                                INPUT "Este terminal não possui papel",
                                INPUT "para impressão do comprovante.",
                                INPUT "O comprovante poderá ser",
                                INPUT "impresso na sua cooperativa.").
            
            PAUSE 10 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.            
        END.

    RUN cartao_pagto_transferencia.w.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_opcoes
ON ANY-KEY OF Btn_D IN FRAME f_cartao_opcoes /* ALTERAÇÃO DE SENHA */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_opcoes
ON CHOOSE OF Btn_D IN FRAME f_cartao_opcoes /* ALTERAÇÃO DE SENHA */
DO:
    
    /* para quem nao tem letras, pede cpf */
    IF  NOT glb_idsenlet  THEN
        RUN cartao_alterar_senha_cpf.w.
    ELSE
        RUN cartao_alterar_senha.w.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_E
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_cartao_opcoes
ON ANY-KEY OF Btn_E IN FRAME f_cartao_opcoes /* SALDOS/EXTRATOS */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_cartao_opcoes
ON CHOOSE OF Btn_E IN FRAME f_cartao_opcoes /* SALDOS/EXTRATOS */
DO:
    RUN cartao_saldos_extratos.w.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_F
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_cartao_opcoes
ON ANY-KEY OF Btn_F IN FRAME f_cartao_opcoes /* CRÉDITO PRÉ-APROVADO */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_cartao_opcoes
ON CHOOSE OF Btn_F IN FRAME f_cartao_opcoes /* CRÉDITO PRÉ-APROVADO */
DO:
    /* Abre a tela do pre-aprovado */
    RUN cartao_pre_aprovado.w (INPUT-OUTPUT aux_flgretur).

    IF aux_flgretur = "OK" THEN
       DO:
           RETURN "OK".
       END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_opcoes
ON ANY-KEY OF Btn_H IN FRAME f_cartao_opcoes /* CANCELAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_opcoes
ON CHOOSE OF Btn_H IN FRAME f_cartao_opcoes /* CANCELAR */
DO:
    /* para nao solicitar se deseja nova operacao */
    IF  aux_flagsair  THEN
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


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_cartao_opcoes OCX.Tick
PROCEDURE temporizador.t_cartao_opcoes.Tick .
aux_flagsair = YES.
APPLY "CHOOSE" TO Btn_H IN FRAME f_cartao_opcoes.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_cartao_opcoes 


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

    ASSIGN Btn_F:VISIBLE    IN FRAME f_cartao_opcoes = FALSE
           IMAGE-41:VISIBLE IN FRAME f_cartao_opcoes = FALSE.
    
    /* deixa o mouse transparente */
    FRAME f_cartao_opcoes:LOAD-MOUSE-POINTER("blank.cur").

    RUN mensagem.w (INPUT NO,
                    INPUT "   Aguarde...",
                    INPUT "",
                    INPUT "",
                    INPUT "Carregando...",
                    INPUT "",
                    INPUT "").

    /* Verifica o status dos cassetes */
    RUN procedures/inicializa_dispositivo.p ( INPUT 2,
                                             OUTPUT aux_flgderro).

    /* Verifica bloqueio de saque */
    RUN procedures/verifica_bloqueio_saque.p(OUTPUT aux_flgblsaq,
                                             OUTPUT aux_flgderro).
    
    /* Verifica se possui notas para liberar o saque */
    IF ((glb_qtnotk7A = 0  OR  NOT glb_cassetes[1])  AND
        (glb_qtnotk7B = 0  OR  NOT glb_cassetes[2])  AND
        (glb_qtnotk7C = 0  OR  NOT glb_cassetes[3])  AND
        (glb_qtnotk7D = 0  OR  NOT glb_cassetes[4]))         OR

        /* K7R desabilitado */
        NOT glb_cassetes[5]                                  OR
         
        /* Sem Suprimento */
        glb_flgsupri = NO                                    OR
         
        /* Situacao 2-Fechado */
        glb_cdsittfn = 2                                     OR 
        
        /* Saque bloqueado */
        aux_flgblsaq                                         THEN
        DISABLE Btn_A WITH FRAME f_cartao_opcoes.
    
    IF NOT glb_flmsgtaa THEN
    DO:
        /* verifica mensagem de alerta ( operacao de credito em atraso) */
        RUN procedures/verifica_mensagem_alerta.p (INPUT glb_nrdconta,
                                                  OUTPUT aux_flgderro).
        ASSIGN glb_flmsgtaa = YES.
    END.

    /* Verifica se possui saldo disponivel para a contratacao do pre-aprovado */
    RUN procedures/busca_saldo_pre_aprovado.p(OUTPUT aux_flgderro,
                                              OUTPUT TABLE tt-dados-cpa).

    IF NOT aux_flgderro THEN
       DO:
           /* Verifica se possui saldo para o Pre-Aprovado */
           FIND FIRST tt-dados-cpa NO-LOCK NO-ERROR.
           IF AVAIL tt-dados-cpa AND tt-dados-cpa.vldiscrd > 0 THEN
              DO:
                  ASSIGN Btn_F:VISIBLE    IN FRAME f_cartao_opcoes = TRUE
                         IMAGE-41:VISIBLE IN FRAME f_cartao_opcoes = TRUE.

                  ENABLE Btn_F WITH FRAME f_cartao_opcoes.
              END.
       END.

    chtemporizador:t_cartao_opcoes:INTERVAL = glb_nrtempor.
    
    aux_flmsgimp = YES.
    aux_contador = 0.
        
    DO WHILE TRUE:
        
        IF  aux_contador = 5  THEN
            DO:
                h_mensagem:HIDDEN = YES.
                LEAVE.
            END.

        /* verifica o status da impressora */
        RUN procedures/inicializa_dispositivo.p ( INPUT 6,
                                                 OUTPUT aux_flgderro).
        
        IF  xfs_imppapelsaida  THEN 
            DO: 
                IF  aux_flmsgimp  THEN
                    DO: 
                        h_mensagem:HIDDEN = YES.

                        RUN mensagem.w (INPUT NO,
                                        INPUT "   ATENÇÃO",
                                        INPUT "",
                                        INPUT "",
                                        INPUT "Retire o papel da impressão.",
                                        INPUT "",
                                        INPUT "").
                        
                        aux_flmsgimp = NO.
                    END. 

                PAUSE 1 NO-MESSAGE.
                aux_contador = aux_contador + 1.
                NEXT.
            END.                                                                            
        ELSE
            DO:
                h_mensagem:HIDDEN = YES.
                LEAVE.
            END.      

    END.

    /* coloca o foco no botao H */
    APPLY "ENTRY" TO Btn_H.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_cartao_opcoes  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_opcoes.wrx":U ).
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
ELSE MESSAGE "cartao_opcoes.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_cartao_opcoes  _DEFAULT-DISABLE
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
  HIDE FRAME f_cartao_opcoes.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_cartao_opcoes  _DEFAULT-ENABLE
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
  ENABLE IMAGE-31 IMAGE-34 IMAGE-35 IMAGE-37 IMAGE-38 IMAGE-40 IMAGE-41 Btn_A 
         Btn_E Btn_B Btn_D Btn_H 
      WITH FRAME f_cartao_opcoes.
  {&OPEN-BROWSERS-IN-QUERY-f_cartao_opcoes}
  VIEW w_cartao_opcoes.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_cartao_opcoes 
PROCEDURE tecla :
ASSIGN chtemporizador:t_cartao_opcoes:INTERVAL = 0
           aux_flagsair = NO.

    /* ---------- */
    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).
    
    IF  aux_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.

    IF  KEY-FUNCTION(LASTKEY) = "A"               AND
        Btn_A:SENSITIVE IN FRAME f_cartao_opcoes  THEN
        APPLY "CHOOSE" TO Btn_A.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "B"               AND
        Btn_B:SENSITIVE IN FRAME f_cartao_opcoes  THEN
        APPLY "CHOOSE" TO Btn_B.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "D"               AND
        Btn_D:SENSITIVE IN FRAME f_cartao_opcoes  THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "E"               AND
        Btn_E:SENSITIVE IN FRAME f_cartao_opcoes  THEN
        APPLY "CHOOSE" TO Btn_E.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "F"               AND
        Btn_F:SENSITIVE IN FRAME f_cartao_opcoes  THEN
        APPLY "CHOOSE" TO Btn_F.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"               AND
        Btn_H:SENSITIVE IN FRAME f_cartao_opcoes  THEN
        DO:
            aux_flagsair = YES.
            APPLY "CHOOSE" TO Btn_H.
        END.
    ELSE
        RETURN NO-APPLY.


    chtemporizador:t_cartao_opcoes:INTERVAL = glb_nrtempor.


    /* Se utilizou alguma opcao, fecha a tela */
    IF  RETURN-VALUE = "OK"  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        DO:
            /* joga o frame frente */
            FRAME f_cartao_opcoes:MOVE-TO-TOP().

            APPLY "ENTRY" TO Btn_H.
        END.
        



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

