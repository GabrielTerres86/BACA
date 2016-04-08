&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_cartao_transferencia
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_cartao_transferencia 
/* ..............................................................................

Procedure: cartao_transferencia.w
Objetivo : Tela para transferencia de valores
Autor    : Evandro
Data     : Janeiro 2010

Ultima alteraçao: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).
                  
                  29/08/2011 - Imprimir protocolo (Gabriel)
                  
                  08/05/2013 - Transferencia intercooperativa (Gabriel).
                  
                  18/07/2013 - Correçao número da agencia da cooperativa (Lucas).
                  
                  07/11/2013 - Alterado Posto de Atendimento ao Cooperado para
                               Posto de Atendimento "PA". (Jorge)
                               
                  05/12/2014 - Correçao para nao gerar comprovante sem efetivar
                               a operaçao (Lunelli SD 230613)
                               
                  20/08/2015 - Adicionado SAC e OUVIDORIA nos comprovantes
                               e visualizaçao de impressao
                               (Lucas Lunelli - Melhoria 83 [SD 279180])
                               
                  21/10/2015 - Correçao de Navegaçao na impressao de comprovante
                               (Lunelli)

                  24/12/2015 - Adicionado tratamento para contas com assinatura 
                               conjunta. (Reinert)

                  27/01/2016 - Adicionado novo parametro na chamada da procedure
                               busca_associado. (Reinert)
                               
                  29/01/2016 - Tratamento banners (Lucas Lunelli - PRJ261)

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
DEFINE INPUT    PARAM   par_flagenda    AS LOGICAL              NO-UNDO.
DEFINE INPUT    PARAM   par_cdagectl    AS INTEGER              NO-UNDO.
DEFINE INPUT    PARAM   par_nmrescop    AS CHARACTER            NO-UNDO.

/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }

DEFINE VARIABLE aux_flgderro        AS LOGICAL                  NO-UNDO.
DEFINE VARIABLE aux_dsprotoc        AS CHAR                     NO-UNDO.
DEFINE VARIABLE aux_cdagectl        AS INT                      NO-UNDO.
DEFINE VARIABLE aux_nmrescop        AS CHAR                     NO-UNDO.
DEFINE VARIABLE aux_nmtransf        AS CHAR         EXTENT 2    NO-UNDO.
DEFINE VARIABLE aux_dttransf        AS DATE                     NO-UNDO.
DEFINE VARIABLE aux_flgmigra        AS LOGICAL                  NO-UNDO.
DEFINE VARIABLE aux_flgbinss        AS LOGICAL                  NO-UNDO.
DEFINE VARIABLE aux_tpoperac        AS INTE                     NO-UNDO.
DEFINE VARIABLE aux_idastcjt        AS INTE                     NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_cartao_transferencia

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ed_nrtransf ed_vltransf ed_dttransf ~
ed_dsagectl Btn_G Btn_D Btn_H ed_nmtransf ed_cdagectl ed_nmrescop ~
ed_nrdconta ed_nmextttl RECT-127 RECT-128 RECT-142 IMAGE-37 IMAGE-40 ~
IMAGE-49 RECT-129 RECT-131 
&Scoped-Define DISPLAYED-OBJECTS ed_nrtransf ed_vltransf ed_dttransf ~
ed_dsagectl ed_nmtransf ed_cdagectl ed_nmrescop ed_nrdconta ed_nmextttl 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_cartao_transferencia AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_D 
     LABEL "CONFIRMAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_G 
     LABEL "CORRIGIR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_H 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_nmtransf AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 101 BY 3.14
     BGCOLOR 15 FGCOLOR 1 FONT 8 NO-UNDO.

DEFINE VARIABLE ed_cdagectl AS INTEGER FORMAT "9999":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 16 BY 1.29
     FONT 15 NO-UNDO.

DEFINE VARIABLE ed_dsagectl AS CHARACTER FORMAT "X(256)":U INITIAL "0" 
     VIEW-AS FILL-IN 
     SIZE 101 BY 1.95
     FONT 15 NO-UNDO.

DEFINE VARIABLE ed_dttransf AS CHARACTER FORMAT "xx/xx/xxxx":U 
     VIEW-AS FILL-IN 
     SIZE 46 BY 2.14
     FONT 13 NO-UNDO.

DEFINE VARIABLE ed_nmextttl AS CHARACTER FORMAT "X(26)":U 
      VIEW-AS TEXT 
     SIZE 68 BY 1.19
     FONT 8 NO-UNDO.

DEFINE VARIABLE ed_nmrescop AS CHARACTER FORMAT "X(15)":U 
      VIEW-AS TEXT 
     SIZE 68 BY 1.29
     FONT 15 NO-UNDO.

DEFINE VARIABLE ed_nrdconta AS INTEGER FORMAT "zzzz,zz9,9":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 24 BY 1.19
     FONT 8 NO-UNDO.

DEFINE VARIABLE ed_nrtransf AS INTEGER FORMAT "zzzz,zzz,9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1.95
     FONT 15 NO-UNDO.

DEFINE VARIABLE ed_vltransf AS DECIMAL FORMAT "zz,zz9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 46 BY 2.14
     FONT 13 NO-UNDO.

DEFINE IMAGE IMAGE-37
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-40
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-49
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE RECTANGLE RECT-100
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 2 .

DEFINE RECTANGLE RECT-127
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 42 BY 2.38.

DEFINE RECTANGLE RECT-128
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 48 BY 2.62.

DEFINE RECTANGLE RECT-129
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 48 BY 2.62.

DEFINE RECTANGLE RECT-131
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 102 BY 2.38.

DEFINE RECTANGLE RECT-142
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 103 BY 3.62.

DEFINE RECTANGLE RECT-98
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-99
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 14 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_cartao_transferencia
     ed_nrtransf AT ROW 11.81 COL 38 COLON-ALIGNED NO-LABEL WIDGET-ID 104
     ed_vltransf AT ROW 18.43 COL 38 COLON-ALIGNED NO-LABEL WIDGET-ID 106
     ed_dttransf AT ROW 21.33 COL 38 COLON-ALIGNED NO-LABEL WIDGET-ID 250
     ed_dsagectl AT ROW 9.14 COL 38 COLON-ALIGNED NO-LABEL WIDGET-ID 260
     Btn_G AT ROW 19.14 COL 94.4 WIDGET-ID 86
     Btn_D AT ROW 24.14 COL 6 WIDGET-ID 66
     Btn_H AT ROW 24.14 COL 94.4 WIDGET-ID 74
     ed_nmtransf AT ROW 14.48 COL 40 NO-LABEL WIDGET-ID 102 NO-TAB-STOP 
     ed_cdagectl AT ROW 6 COL 46 COLON-ALIGNED NO-LABEL WIDGET-ID 242 NO-TAB-STOP 
     ed_nmrescop AT ROW 6 COL 62 COLON-ALIGNED NO-LABEL WIDGET-ID 246 NO-TAB-STOP 
     ed_nrdconta AT ROW 7.38 COL 46 COLON-ALIGNED NO-LABEL WIDGET-ID 248 NO-TAB-STOP 
     ed_nmextttl AT ROW 7.38 COL 72 COLON-ALIGNED NO-LABEL WIDGET-ID 244 NO-TAB-STOP 
     "CONTAS-CORRENTES" VIEW-AS TEXT
          SIZE 42 BY .86 AT ROW 3.38 COL 101 WIDGET-ID 140
          FGCOLOR 1 FONT 14
     "Titular:" VIEW-AS TEXT
          SIZE 16 BY 1.19 AT ROW 14.43 COL 20 WIDGET-ID 112
          FONT 8
     "Valor:" VIEW-AS TEXT
          SIZE 13 BY 1.67 AT ROW 18.71 COL 22.2 WIDGET-ID 110
          FONT 8
     "TRANSFERENCIA" VIEW-AS TEXT
          SIZE 75 BY 3.33 AT ROW 1.48 COL 25 WIDGET-ID 136
          FGCOLOR 1 FONT 10
     "Conta:" VIEW-AS TEXT
          SIZE 17 BY 1.33 AT ROW 12.1 COL 21 WIDGET-ID 108
          FONT 8
     "Data da" VIEW-AS TEXT
          SIZE 18.2 BY 1.38 AT ROW 21.29 COL 17 WIDGET-ID 254
          FONT 8
     "Conta/Titular:" VIEW-AS TEXT
          SIZE 29 BY 1.19 AT ROW 7.38 COL 17 WIDGET-ID 238
          FONT 8
     "Para" VIEW-AS TEXT
          SIZE 11 BY 1.19 AT ROW 9.1 COL 23.6 WIDGET-ID 114
          FONT 8
     "Cooperativa:" VIEW-AS TEXT
          SIZE 28 BY 1.19 AT ROW 6 COL 18.6 WIDGET-ID 240
          FONT 8
     "Cooperativa:" VIEW-AS TEXT
          SIZE 28.6 BY 1.19 AT ROW 10.33 COL 7.4 WIDGET-ID 258
          FONT 8
     "Transferencia:" VIEW-AS TEXT
          SIZE 31.2 BY 1.14 AT ROW 22.38 COL 4 WIDGET-ID 256
          FONT 8
     "ENTRE" VIEW-AS TEXT
          SIZE 15 BY 1.14 AT ROW 1.95 COL 101.2 WIDGET-ID 138
          FGCOLOR 1 FONT 14
     RECT-127 AT ROW 11.52 COL 39 WIDGET-ID 94
     RECT-128 AT ROW 18.19 COL 39 WIDGET-ID 96
     RECT-142 AT ROW 14.24 COL 39 WIDGET-ID 100
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 134
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-37 AT ROW 24.29 COL 1 WIDGET-ID 148
     IMAGE-40 AT ROW 24.29 COL 156 WIDGET-ID 154
     IMAGE-49 AT ROW 19.29 COL 156 WIDGET-ID 156
     RECT-129 AT ROW 21.1 COL 39 WIDGET-ID 252
     RECT-131 AT ROW 8.95 COL 39 WIDGET-ID 262
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1.1
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
  CREATE WINDOW w_cartao_transferencia ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.62
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
ASSIGN w_cartao_transferencia = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_cartao_transferencia
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_cartao_transferencia
   FRAME-NAME Custom                                                    */
ASSIGN 
       ed_dsagectl:READ-ONLY IN FRAME f_cartao_transferencia        = TRUE.

ASSIGN 
       ed_nmtransf:READ-ONLY IN FRAME f_cartao_transferencia        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_cartao_transferencia
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_cartao_transferencia
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_cartao_transferencia
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_cartao_transferencia:HANDLE
       ROW             = 1.71
       COLUMN          = 6
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_transferencia */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_cartao_transferencia
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_transferencia w_cartao_transferencia
ON END-ERROR OF w_cartao_transferencia
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_transferencia w_cartao_transferencia
ON WINDOW-CLOSE OF w_cartao_transferencia
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_transferencia
ON ANY-KEY OF Btn_D IN FRAME f_cartao_transferencia /* CONFIRMAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_transferencia
ON CHOOSE OF Btn_D IN FRAME f_cartao_transferencia /* CONFIRMAR */
DO:
    /* ---------- */
    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).
    
    IF  aux_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.

    aux_flgderro = NO.

    IF  glb_cdagectl = par_cdagectl                   AND
        INT(ed_nrtransf:SCREEN-VALUE) = glb_nrdconta  THEN
        DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "    Atençao!",
                            INPUT "",
                            INPUT "A conta de origem e destino",
                            INPUT "nao podem ser iguais.",
                            INPUT "",
                            INPUT "").

            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.

            aux_flgderro = YES.
        END.
    ELSE
    IF  INT(ed_nrtransf:SCREEN-VALUE) = 0  THEN
        DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "    Atençao!",
                            INPUT "",
                            INPUT "",
                            INPUT "A conta deve ser informada.",
                            INPUT "",
                            INPUT "").

            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.

            aux_flgderro = YES.
        END.
    ELSE
    IF  DEC(ed_vltransf:SCREEN-VALUE) = 0  THEN
        DO:    
            RUN mensagem.w (INPUT YES,
                            INPUT "    Atençao!",
                            INPUT "",
                            INPUT "",
                            INPUT "O valor deve ser informado.",
                            INPUT "",
                            INPUT "").

            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.

            aux_flgderro = YES.
        END.

    ASSIGN aux_dttransf = DATE(ed_dttransf:SCREEN-VALUE) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "    Atençao!",
                            INPUT "",
                            INPUT "",
                            INPUT "Data inválida.",
                            INPUT "",
                            INPUT "").

            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.

            aux_flgderro = YES.

        END.
    ELSE
    IF  aux_dttransf = ? THEN
        DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "    Atençao!",
                            INPUT "",
                            INPUT "",
                            INPUT "A data deve ser informada.",
                            INPUT "",
                            INPUT "").

            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.

            aux_flgderro = YES.
        END.

    IF  par_flagenda THEN
        DO:    
            IF  aux_dttransf <= TODAY THEN
                DO:
                    RUN mensagem.w (INPUT YES,
                                    INPUT "    Atençao!",
                                    INPUT "",
                                    INPUT "",
                                    INPUT "A data deve ser superior",
                                    INPUT "a data atual.",
                                    INPUT "").
        
                    PAUSE 3 NO-MESSAGE.
                    h_mensagem:HIDDEN = YES.
        
                    aux_flgderro = YES.
        
                END.
        END.

    IF  aux_flgderro THEN
        DO:
            APPLY "CHOOSE" TO Btn_G.
            RETURN NO-APPLY.
        END.

    ASSIGN ed_nrtransf
           ed_vltransf
           ed_nmtransf.

    RUN procedures/verifica_transferencia.p ( INPUT par_cdagectl,
                                              INPUT ed_nrtransf,
                                              INPUT ed_vltransf,
                                              INPUT aux_dttransf,
                                              INPUT aux_tpoperac,
                                              INPUT par_flagenda,
                                             OUTPUT aux_flgderro).
    
    IF  aux_flgderro THEN
        DO:
            APPLY "CHOOSE" TO Btn_G.
            RETURN NO-APPLY.
        END.

    IF  par_flagenda THEN
        DO:
            RUN cartao_agendamento_transferencia_dados.w ( INPUT par_cdagectl,
                                                           INPUT ed_dsagectl,
                                                           INPUT ed_nrtransf,
                                                           INPUT aux_nmtransf,
                                                           INPUT ed_vltransf,
                                                           INPUT aux_dttransf,
                                                           INPUT aux_tpoperac,                                                           
                                                           INPUT par_flagenda,
                                                          OUTPUT aux_flgderro).

            IF  RETURN-VALUE = "NOK" AND
                aux_flgderro         THEN
                DO:
                    APPLY "CHOOSE" TO Btn_G.
                    RETURN NO-APPLY.
                END.
        END.
    ELSE
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
            
                    RUN procedures/efetua_transferencia.p (INPUT  par_cdagectl,
                                                           INPUT  ed_nrtransf,
                                                           INPUT  ed_vltransf,
                                                           INPUT  aux_dttransf,
                                                           INPUT  aux_tpoperac,
                                                           INPUT  par_flagenda,
                                                           OUTPUT aux_flgderro,
                                                           OUTPUT aux_dsprotoc,
                                                           OUTPUT aux_idastcjt).
                                                                                                                   
                    IF  NOT aux_flgderro THEN
                        DO:
                            RUN procedures/inicializa_dispositivo.p ( INPUT 6,
                                                                     OUTPUT aux_flgderro).
    
                            /* se a impressora estiver habilitada, com papel e 
                               transferencia efetuada com sucesso e nao exigir
                               assinatura conjunta */
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

                            APPLY "CHOOSE" TO Btn_G.
                       END.

                END.
        END.
    /* repassa o retorno */
    RETURN RETURN-VALUE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_G
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_cartao_transferencia
ON ANY-KEY OF Btn_G IN FRAME f_cartao_transferencia /* CORRIGIR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_cartao_transferencia
ON CHOOSE OF Btn_G IN FRAME f_cartao_transferencia /* CORRIGIR */
DO:
    ASSIGN ed_nrtransf:SCREEN-VALUE = ""
           ed_nmtransf:SCREEN-VALUE = ""
           ed_vltransf:SCREEN-VALUE = ""
           ed_dttransf:SCREEN-VALUE = "".

    APPLY "ENTRY" TO ed_nrtransf.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_transferencia
ON ANY-KEY OF Btn_H IN FRAME f_cartao_transferencia /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_transferencia
ON CHOOSE OF Btn_H IN FRAME f_cartao_transferencia /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_dttransf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_dttransf w_cartao_transferencia
ON ANY-KEY OF ed_dttransf IN FRAME f_cartao_transferencia
DO:
    RUN tecla.

    IF  CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))  THEN
        DO:
            /* limite de caracteres */
            IF  LENGTH(ed_dttransf:SCREEN-VALUE) > 9  THEN
                RETURN NO-APPLY.

        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            ed_dttransf:SCREEN-VALUE = "".
            RETURN NO-APPLY.
        END.
    ELSE
        DO:
            /* se usou alguma opcao */
            IF  RETURN-VALUE = "OK"  THEN
                DO:
                    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                    RETURN "OK".
                END.
            ELSE
                RETURN NO-APPLY.
        END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_nrtransf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nrtransf w_cartao_transferencia
ON ANY-KEY OF ed_nrtransf IN FRAME f_cartao_transferencia
DO:
    RUN tecla.

    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            RUN procedures/busca_associado.p (INPUT  INT(ed_nrtransf:SCREEN-VALUE),
                                              INPUT  par_cdagectl,
                                              OUTPUT aux_cdagectl,
                                              OUTPUT aux_nmrescop,
                                              OUTPUT aux_nmtransf,
                                              OUTPUT aux_flgmigra,
                                              OUTPUT aux_flgbinss,
                                              OUTPUT aux_flgderro).

            IF  aux_flgderro  THEN
                APPLY "CHOOSE" TO Btn_G.
            ELSE
                DO:
                    ed_nmtransf:SCREEN-VALUE = aux_nmtransf[1].

                    IF  aux_nmtransf[2] <> ""  THEN
                        ed_nmtransf:SCREEN-VALUE = ed_nmtransf:SCREEN-VALUE +
                                                   CHR(13) +
                                                   aux_nmtransf[2].

                    IF  NOT par_flagenda THEN
                        DO:
                            ed_dttransf:SCREEN-VALUE = STRING(glb_dtmvtocd,"99/99/9999").
                            ed_dttransf:READ-ONLY    = YES.
                            ed_dttransf:BGCOLOR      = 8.
                        END.
                    
                    APPLY "ENTRY" TO ed_vltransf.
                    RETURN NO-APPLY.
                    
                END.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        ed_nrtransf:SCREEN-VALUE = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_vltransf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_vltransf w_cartao_transferencia
ON ANY-KEY OF ed_vltransf IN FRAME f_cartao_transferencia
DO:
    IF  par_flagenda THEN
        IF  KEY-FUNCTION(LASTKEY) = "D" THEN
            RETURN NO-APPLY.
        ELSE
            RUN tecla.
    ELSE
        RUN tecla.

    IF  CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))  THEN
        DO:
            /* limite de caracteres */
            IF  LENGTH(ed_vltransf:SCREEN-VALUE) > 8  THEN
                RETURN NO-APPLY.


            /* controle para permitir centavos */
            ed_vltransf:SCREEN-VALUE = STRING(DECIMAL(ed_vltransf:SCREEN-VALUE +
                                              KEY-FUNCTION(LASTKEY)) * 10).

            RETURN NO-APPLY.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            ed_vltransf:SCREEN-VALUE = "".
            RETURN NO-APPLY.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            IF  par_flagenda THEN
                DO:
                    APPLY "ENTRY" TO ed_dttransf.
                    RETURN NO-APPLY.
                END.
        END.
    ELSE
        DO:
            /* se usou alguma opcao */
            IF  RETURN-VALUE = "OK"  THEN
                DO:
                    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                    RETURN "OK".
                END.
            ELSE
                RETURN NO-APPLY.
        END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_cartao_transferencia OCX.Tick
PROCEDURE temporizador.t_cartao_transferencia.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_cartao_transferencia.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_cartao_transferencia 


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
    FRAME f_cartao_transferencia:LOAD-MOUSE-POINTER("blank.cur").

    ASSIGN chtemporizador:t_cartao_transferencia:INTERVAL = glb_nrtempor
                   
           /* Dados do associado */
           ed_cdagectl = glb_cdagectl
           ed_nmrescop = " - " + glb_nmrescop
           ed_dsagectl = STRING(par_cdagectl,"9999") + " - " + par_nmrescop 
           ed_nrdconta = glb_nrdconta
           ed_nmextttl = glb_nmtitula[1]
           
           aux_tpoperac = IF  (glb_cdagectl = par_cdagectl)   THEN   
                              1   /* Intra Coop. */
                          ELSE
                              5.  /* Inter Coop. */  

    DISPLAY ed_cdagectl  ed_nmrescop
            ed_dsagectl  ed_nrdconta  
            ed_nmextttl
            WITH FRAME f_cartao_transferencia.

    /* coloca o foco na conta */
    APPLY "ENTRY" TO ed_nrtransf.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_cartao_transferencia  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_transferencia.wrx":U ).
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
ELSE MESSAGE "cartao_transferencia.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_cartao_transferencia  _DEFAULT-DISABLE
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
  HIDE FRAME f_cartao_transferencia.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_cartao_transferencia  _DEFAULT-ENABLE
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
  DISPLAY ed_nrtransf ed_vltransf ed_dttransf ed_dsagectl ed_nmtransf 
          ed_cdagectl ed_nmrescop ed_nrdconta ed_nmextttl 
      WITH FRAME f_cartao_transferencia.
  ENABLE ed_nrtransf ed_vltransf ed_dttransf ed_dsagectl Btn_G Btn_D Btn_H 
         ed_nmtransf ed_cdagectl ed_nmrescop ed_nrdconta ed_nmextttl RECT-127 
         RECT-128 RECT-142 IMAGE-37 IMAGE-40 IMAGE-49 RECT-129 RECT-131 
      WITH FRAME f_cartao_transferencia.
  {&OPEN-BROWSERS-IN-QUERY-f_cartao_transferencia}
  VIEW w_cartao_transferencia.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE imprime_comprovante w_cartao_transferencia 
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
                      "                                                ".
IF  par_flagenda THEN
    tmp_tximpres = tmp_tximpres +
                   "  COMPROVANTE DE AGENDAMENTO DE TRANSFERENCIA   ".       
ELSE
    tmp_tximpres = tmp_tximpres +
                   "          COMPROVANTE DE TRANSFERENCIA          ".

       
ASSIGN tmp_tximpres = tmp_tximpres +
                      "                                                "   + 
                      "DE                                              "   +
                      "COOPERATIVA: " + STRING(ed_cdagectl,"9999")         +
                                        STRING(ed_nmrescop,"x(31)")        +

                      "CONTA: " + STRING(glb_nrdconta,"zzzz,zzz,9")        +
                          " - " + STRING(glb_nmtitula[1],"x(28)").

IF  glb_nmtitula[2] <> ""  THEN
    tmp_tximpres = tmp_tximpres +
                   "                    " + STRING(glb_nmtitula[2],"x(28)").


tmp_tximpres = tmp_tximpres +               
               "                                                " +
               "PARA                                            " +
               "COOPERATIVA: " + STRING(ed_dsagectl,"x(35)")      +  
               "CONTA: " + STRING(ed_nrtransf,"zzzz,zzz,9")       +
               " - " + STRING(aux_nmtransf[1],"x(25)").


IF  aux_nmtransf[2] <> ""  THEN
    tmp_tximpres = tmp_tximpres +
                   "                       " +
                   STRING(aux_nmtransf[2],"x(25)").

IF par_flagenda THEN
    DO:
        tmp_tximpres = tmp_tximpres +
                       "DATA DO AGENDAMENTO: " + STRING(aux_dttransf, "99/99/9999")+
                                                      "                 " +
                       "                                                ".
    END.
ELSE
    DO: 
        tmp_tximpres = tmp_tximpres +
                   "                                                " + 
                   "   PROTOCOLO: " + STRING(aux_dsprotoc,"x(29)") + 
                   "     " +
                   "                                                ".
    END.

    
tmp_tximpres = tmp_tximpres +
               "              VALOR: " + STRING(ed_vltransf,"zz,zz9.99")   +
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_cartao_transferencia 
PROCEDURE tecla :
chtemporizador:t_cartao_transferencia:INTERVAL = 0.

    IF  KEY-FUNCTION(LASTKEY) = "D"                      AND
        Btn_D:SENSITIVE IN FRAME f_cartao_transferencia  THEN
        DO:
            APPLY "CHOOSE" TO Btn_D.

            IF  RETURN-VALUE = "OK"  THEN
                DO:
                    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
                    RETURN "OK".
                END.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "G"                      AND
        Btn_G:SENSITIVE IN FRAME f_cartao_transferencia  THEN
        APPLY "CHOOSE" TO Btn_G.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                      AND
        Btn_H:SENSITIVE IN FRAME f_cartao_transferencia  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_cartao_transferencia:INTERVAL = glb_nrtempor.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

