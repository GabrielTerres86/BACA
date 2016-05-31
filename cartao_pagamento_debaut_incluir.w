&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_debaut_incluir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_debaut_incluir 
/* ..............................................................................

Procedure: cartao_pagamento_debaut_incluir.w
Objetivo : Tela de inclusao de débito automático
Autor    : Lucas Lunelli
Data     : Setembro/2014

Ultima alteração: 10/11/2014 - Correção hint do campo Identif. Consumidor e 
                               Validação temporária para erro de ? (Lunelli)
                               
                  30/05/2016 - Alteraçoes Oferta DEBAUT Sicredi (Lucas Lunelli - [PROJ320])

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

/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }
{ includes/var_xfs_lite.i }

DEFINE INPUT  PARAM par_cdoperac     AS CHAR                 NO-UNDO.
DEFINE INPUT  PARAM par_cdbarra1     AS CHAR                 NO-UNDO.
DEFINE INPUT  PARAM par_cdbarra2     AS CHAR                 NO-UNDO.
DEFINE INPUT  PARAM par_cdbarra3     AS CHAR                 NO-UNDO.
DEFINE INPUT  PARAM par_cdbarra4     AS CHAR                 NO-UNDO.
DEFINE INPUT  PARAM par_dscodbar     AS CHAR                 NO-UNDO.
                                                             
DEFINE VARIABLE aux_flgderro        AS LOGICAL               NO-UNDO.
DEFINE VARIABLE aux_nmextcon        AS CHAR                  NO-UNDO.
DEFINE VARIABLE aux_datpagto        AS DATE                  NO-UNDO.
DEFINE VARIABLE aux_temporiz        AS LOGICAL INIT FALSE    NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_debaut_incluir

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-127 RECT-132 RECT-136 RECT-137 RECT-138 ~
IMAGE-36 IMAGE-37 IMAGE-40 RECT-133 RECT-134 ed_dscodbar ed_cdbarra1 ~
ed_cdbarra2 ed_cdbarra3 ed_cdbarra4 ed_cdrefere Btn_C ed_mensagem Btn_D ~
Btn_H ed_cdagectl ed_nmrescop ed_nrdconta ed_nmextttl 
&Scoped-Define DISPLAYED-OBJECTS ed_dscodbar ed_cdbarra1 ed_cdbarra2 ~
ed_cdbarra3 ed_cdbarra4 ed_nmempres ed_cdrefere ed_mensagem ed_cdagectl ~
ed_nmrescop ed_nrdconta ed_nmextttl 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_debaut_incluir AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.
DEFINE VARIABLE temporizador_cod_barras AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador_cod_barras AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_C 
     LABEL "INCLUSÃO MANUAL" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_D 
     LABEL "CONFIRMAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_H 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_mensagem AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 61 BY 4.05
     BGCOLOR 7 FGCOLOR 14 FONT 14 NO-UNDO.

DEFINE VARIABLE ed_cdagectl AS INTEGER FORMAT "9999":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 16 BY 1.24
     FONT 15 NO-UNDO.

DEFINE VARIABLE ed_cdbarra1 AS CHARACTER FORMAT "xxxxxxxxxxx.x":U 
     VIEW-AS FILL-IN 
     SIZE 27 BY 1.19
     FONT 14 NO-UNDO.

DEFINE VARIABLE ed_cdbarra2 AS CHARACTER FORMAT "xxxxxxxxxxx.x":U 
     VIEW-AS FILL-IN 
     SIZE 27 BY 1.19
     FONT 14 NO-UNDO.

DEFINE VARIABLE ed_cdbarra3 AS CHARACTER FORMAT "xxxxxxxxxxx.x":U 
     VIEW-AS FILL-IN 
     SIZE 27 BY 1.19
     FONT 14 NO-UNDO.

DEFINE VARIABLE ed_cdbarra4 AS CHARACTER FORMAT "xxxxxxxxxxx.x":U 
     VIEW-AS FILL-IN 
     SIZE 27 BY 1.19
     FONT 14 NO-UNDO.

DEFINE VARIABLE ed_cdrefere AS CHARACTER FORMAT "x(17)":U 
     VIEW-AS FILL-IN 
     SIZE 75 BY 1.19
     FONT 14 NO-UNDO.

DEFINE VARIABLE ed_dscodbar AS CHARACTER FORMAT "x(44)":U 
     VIEW-AS FILL-IN 
     SIZE 90 BY 1.19
     FONT 14 NO-UNDO.

DEFINE VARIABLE ed_nmempres AS CHARACTER FORMAT "X(30)":U 
     VIEW-AS FILL-IN 
     SIZE 75.2 BY 1.19
     FONT 14 NO-UNDO.

DEFINE VARIABLE ed_nmextttl AS CHARACTER FORMAT "X(26)":U 
      VIEW-AS TEXT 
     SIZE 68 BY 1.19
     FONT 8 NO-UNDO.

DEFINE VARIABLE ed_nmrescop AS CHARACTER FORMAT "X(15)":U 
      VIEW-AS TEXT 
     SIZE 68 BY 1.24
     FONT 15 NO-UNDO.

DEFINE VARIABLE ed_nrdconta AS INTEGER FORMAT "zzzz,zz9,9":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 24 BY 1.19
     FONT 8 NO-UNDO.

DEFINE IMAGE IMAGE-36
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

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
     SIZE 29 BY 1.67.

DEFINE RECTANGLE RECT-132
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 92 BY 1.67.

DEFINE RECTANGLE RECT-133
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 77.2 BY 1.67.

DEFINE RECTANGLE RECT-134
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 77 BY 1.67.

DEFINE RECTANGLE RECT-136
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 29 BY 1.67.

DEFINE RECTANGLE RECT-137
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 29 BY 1.67.

DEFINE RECTANGLE RECT-138
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 29 BY 1.67.

DEFINE RECTANGLE RECT-98
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-99
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_debaut_incluir
     ed_dscodbar AT ROW 10.76 COL 33 COLON-ALIGNED NO-LABEL WIDGET-ID 162
     ed_cdbarra1 AT ROW 12.76 COL 33 COLON-ALIGNED NO-LABEL WIDGET-ID 160
     ed_cdbarra2 AT ROW 12.76 COL 62 COLON-ALIGNED NO-LABEL WIDGET-ID 182
     ed_cdbarra3 AT ROW 12.76 COL 91 COLON-ALIGNED NO-LABEL WIDGET-ID 186
     ed_cdbarra4 AT ROW 12.76 COL 120 COLON-ALIGNED NO-LABEL WIDGET-ID 190
     ed_nmempres AT ROW 14.76 COL 33 COLON-ALIGNED NO-LABEL WIDGET-ID 256
     ed_cdrefere AT ROW 17.14 COL 109 RIGHT-ALIGNED NO-LABEL WIDGET-ID 254
     Btn_C AT ROW 19.1 COL 6 WIDGET-ID 154
     ed_mensagem AT ROW 19.1 COL 94.4 NO-LABEL WIDGET-ID 164 NO-TAB-STOP 
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 156
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 158
     ed_cdagectl AT ROW 6 COL 46 COLON-ALIGNED NO-LABEL WIDGET-ID 238 NO-TAB-STOP 
     ed_nmrescop AT ROW 6 COL 62 COLON-ALIGNED NO-LABEL WIDGET-ID 242 NO-TAB-STOP 
     ed_nrdconta AT ROW 7.43 COL 46 COLON-ALIGNED NO-LABEL WIDGET-ID 244 NO-TAB-STOP 
     ed_nmextttl AT ROW 7.43 COL 72 COLON-ALIGNED NO-LABEL WIDGET-ID 240 NO-TAB-STOP 
     "Conta/Titular:" VIEW-AS TEXT
          SIZE 29 BY 1.19 AT ROW 7.43 COL 17 WIDGET-ID 140
          FONT 8
     "Barras:" VIEW-AS TEXT
          SIZE 12 BY 1.19 AT ROW 11 COL 21 WIDGET-ID 176
          FONT 14
     "Código de" VIEW-AS TEXT
          SIZE 18 BY 1.19 AT ROW 9.81 COL 15 WIDGET-ID 178
          FONT 14
     "Linha Digitável:" VIEW-AS TEXT
          SIZE 26 BY 1.19 AT ROW 13 COL 8 WIDGET-ID 180
          FONT 14
     "DÉBITO AUTOMÁTICO" VIEW-AS TEXT
          SIZE 100 BY 3.33 AT ROW 1.48 COL 32 WIDGET-ID 214
          FGCOLOR 1 FONT 10
     "Identificador:" VIEW-AS TEXT
          SIZE 22.6 BY 1.19 AT ROW 17.1 COL 11.2 WIDGET-ID 262
          FONT 14
     "Empresa:" VIEW-AS TEXT
          SIZE 16.8 BY 1.19 AT ROW 15 COL 16.8 WIDGET-ID 264
          FONT 14
     "Cooperativa:" VIEW-AS TEXT
          SIZE 28 BY 1.19 AT ROW 6 COL 18.6 WIDGET-ID 134
          FONT 8
     RECT-127 AT ROW 12.52 COL 34 WIDGET-ID 168
     RECT-132 AT ROW 10.52 COL 34 WIDGET-ID 170
     RECT-136 AT ROW 12.52 COL 63 WIDGET-ID 184
     RECT-137 AT ROW 12.52 COL 92 WIDGET-ID 188
     RECT-138 AT ROW 12.52 COL 121 WIDGET-ID 192
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-36 AT ROW 19.24 COL 1 WIDGET-ID 146
     IMAGE-37 AT ROW 24.24 COL 1 WIDGET-ID 148
     IMAGE-40 AT ROW 24.24 COL 156 WIDGET-ID 218
     RECT-133 AT ROW 14.52 COL 34 WIDGET-ID 258
     RECT-134 AT ROW 16.91 COL 34 WIDGET-ID 260
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
  CREATE WINDOW w_debaut_incluir ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.57
         WIDTH              = 160
         MAX-HEIGHT         = 35.76
         MAX-WIDTH          = 256
         VIRTUAL-HEIGHT     = 35.76
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
ASSIGN w_debaut_incluir = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_debaut_incluir
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_debaut_incluir
   FRAME-NAME                                                           */
ASSIGN 
       ed_cdbarra1:READ-ONLY IN FRAME f_debaut_incluir        = TRUE.

ASSIGN 
       ed_cdbarra2:READ-ONLY IN FRAME f_debaut_incluir        = TRUE.

ASSIGN 
       ed_cdbarra3:READ-ONLY IN FRAME f_debaut_incluir        = TRUE.

ASSIGN 
       ed_cdbarra4:READ-ONLY IN FRAME f_debaut_incluir        = TRUE.

/* SETTINGS FOR FILL-IN ed_cdrefere IN FRAME f_debaut_incluir
   ALIGN-R                                                              */
ASSIGN 
       ed_dscodbar:READ-ONLY IN FRAME f_debaut_incluir        = TRUE.

ASSIGN 
       ed_mensagem:READ-ONLY IN FRAME f_debaut_incluir        = TRUE.

/* SETTINGS FOR FILL-IN ed_nmempres IN FRAME f_debaut_incluir
   NO-ENABLE                                                            */
ASSIGN 
       ed_nmempres:READ-ONLY IN FRAME f_debaut_incluir        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_debaut_incluir
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_debaut_incluir
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_debaut_incluir
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_debaut_incluir:HANDLE
       ROW             = 1.71
       COLUMN          = 17
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.

CREATE CONTROL-FRAME temporizador_cod_barras ASSIGN
       FRAME           = FRAME f_debaut_incluir:HANDLE
       ROW             = 10.52
       COLUMN          = 126
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 174
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_debaut_incluir */
/* temporizador_cod_barras OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cod_barras */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_debaut_incluir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_debaut_incluir w_debaut_incluir
ON END-ERROR OF w_debaut_incluir
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_debaut_incluir w_debaut_incluir
ON WINDOW-CLOSE OF w_debaut_incluir
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_C
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_C w_debaut_incluir
ON ANY-KEY OF Btn_C IN FRAME f_debaut_incluir /* INCLUSÃO MANUAL */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_C w_debaut_incluir
ON CHOOSE OF Btn_C IN FRAME f_debaut_incluir /* INCLUSÃO MANUAL */
DO:
    /* este botao executa a funcao de troca para modo MANUAL e
       CORRIGIR caso ja esteja no modo manual */
    IF  SELF:LABEL = "INCLUSÃO MANUAL"  THEN
        DO:
            /* desativa o temporizador do cod de barras */
            chtemporizador_cod_barras:t_cod_barras:INTERVAL = 0.

            /* cancela a leitora */
            RUN WinCancelaLeituraCodBarLcbCh IN aux_xfsliteh (OUTPUT LT_Resp).

            RUN habilita_manual.
        END.
    ELSE
        ASSIGN ed_cdbarra1:SCREEN-VALUE = ""
               ed_cdbarra2:SCREEN-VALUE = ""
               ed_cdbarra3:SCREEN-VALUE = ""
               ed_cdbarra4:SCREEN-VALUE = ""
               ed_nmempres:SCREEN-VALUE = ""
               ed_cdrefere:SCREEN-VALUE = ""
               ed_dscodbar:SCREEN-VALUE = "".
    
    APPLY "ENTRY" TO ed_cdbarra1.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_debaut_incluir
ON ANY-KEY OF Btn_D IN FRAME f_debaut_incluir /* CONFIRMAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_debaut_incluir
ON CHOOSE OF Btn_D IN FRAME f_debaut_incluir /* CONFIRMAR */
DO:
    /* ---------- */
    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).
    
    IF  aux_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.

    /* Validação temporária para erro de ? */
    IF  (ed_cdrefere:SCREEN-VALUE = ?) THEN
        DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "    ATENÇÃO",
                            INPUT "",
                            INPUT "",
                            INPUT "Erro na operação.",
                            INPUT "Tente novamente.",
                            INPUT "").
            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.

            ASSIGN ed_cdbarra1:SCREEN-VALUE = ""
                   ed_cdbarra2:SCREEN-VALUE = ""
                   ed_cdbarra3:SCREEN-VALUE = ""
                   ed_cdbarra4:SCREEN-VALUE = ""
                   ed_nmempres:SCREEN-VALUE = ""
                   ed_dscodbar:SCREEN-VALUE = "".

            IF  xfs_lcbarras  THEN
                DO:
                    RUN habilita_leitora.
                    APPLY "ENTRY" TO Btn_H.
                END.
            ELSE
                DO:
                    RUN habilita_manual.
                    APPLY "ENTRY" TO ed_cdbarra1.
                END.

            RETURN NO-APPLY.
        END.

    IF  ed_cdrefere:SCREEN-VALUE = "" THEN
        DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "    ATENÇÃO",
                            INPUT "",
                            INPUT "",
                            INPUT "Identificação do Consumidor",
                            INPUT "não informada.",
                            INPUT "").
            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.

            APPLY "ENTRY" TO ed_cdrefere.
            RETURN NO-APPLY.
        END.

    IF  LENGTH(ed_cdrefere:SCREEN-VALUE) < 2 THEN
        DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "    ATENÇÃO",
                            INPUT "",
                            INPUT "",
                            INPUT "Identificação do Consumidor",
                            INPUT "inválida.",
                            INPUT "").
            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.

            APPLY "ENTRY" TO ed_cdrefere.
            RETURN NO-APPLY.

        END.
           
    
    /* nos codigos digitaveis, nao passa os "." */
    RUN cartao_pagamento_debaut_limite.w (INPUT ed_dscodbar:SCREEN-VALUE,
                                          INPUT TRIM(REPLACE(ed_cdbarra1:SCREEN-VALUE,".","")),
                                          INPUT TRIM(REPLACE(ed_cdbarra2:SCREEN-VALUE,".","")),
                                          INPUT TRIM(REPLACE(ed_cdbarra3:SCREEN-VALUE,".","")),
                                          INPUT TRIM(REPLACE(ed_cdbarra4:SCREEN-VALUE,".","")),
                                          INPUT ed_nmempres:SCREEN-VALUE,
                                          INPUT ed_cdrefere:SCREEN-VALUE).
    IF  RETURN-VALUE = "NOK"  THEN
        DO:            
            FRAME f_debaut_incluir:MOVE-TO-TOP().

            ASSIGN ed_cdbarra1:SCREEN-VALUE = ""
                   ed_cdbarra2:SCREEN-VALUE = ""
                   ed_cdbarra3:SCREEN-VALUE = ""
                   ed_cdbarra4:SCREEN-VALUE = ""
                   ed_nmempres:SCREEN-VALUE = ""
                   ed_cdrefere:SCREEN-VALUE = ""
                   ed_dscodbar:SCREEN-VALUE = "".

            IF  xfs_lcbarras  THEN
                DO:
                    RUN habilita_leitora.
                    APPLY "ENTRY" TO Btn_H.
                END.
            ELSE
                DO:
                    RUN habilita_manual.
                    APPLY "ENTRY" TO ed_cdbarra1.
                END.
                
        END.
    ELSE
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN "OK".
        END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_debaut_incluir
ON ENTRY OF Btn_D IN FRAME f_debaut_incluir /* CONFIRMAR */
DO:
    ed_mensagem:SCREEN-VALUE = "Pressione ~"CONFIRMAR~"".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_debaut_incluir
ON ANY-KEY OF Btn_H IN FRAME f_debaut_incluir /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_debaut_incluir
ON CHOOSE OF Btn_H IN FRAME f_debaut_incluir /* VOLTAR */
DO:
    /* desativa o temporizador do cod de barras */
    chtemporizador_cod_barras:t_cod_barras:INTERVAL = 0.

    /* cancela a leitora */
    RUN WinCancelaLeituraCodBarLcbCh IN aux_xfsliteh (OUTPUT LT_Resp).

    IF  NOT (par_cdoperac = "P") THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
            RETURN "NOK".
        END.
    ELSE
        DO:
            IF  aux_temporiz THEN
                DO:
                    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
                    RETURN "NOK".
                END.
        END.

    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "OK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_cdbarra1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_cdbarra1 w_debaut_incluir
ON ANY-KEY OF ed_cdbarra1 IN FRAME f_debaut_incluir
DO:
    IF  KEY-FUNCTION(LASTKEY) = "D" THEN
        RETURN NO-APPLY.
    ELSE
        DO:
            RUN tecla.
        END.

    IF  CAN-DO("0,1,2,3,4,5,6,7,8,9,RETURN",KEY-FUNCTION(LASTKEY))  THEN
        DO:
            IF  LENGTH(REPLACE(ed_cdbarra1:SCREEN-VALUE," ","")) >= 12  THEN
                DO:
                    APPLY LASTKEY.
                    APPLY "ENTRY" TO ed_cdbarra2.
                    RETURN NO-APPLY.

                END.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        .
    ELSE
        /* Ignora */
        RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_cdbarra2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_cdbarra2 w_debaut_incluir
ON ANY-KEY OF ed_cdbarra2 IN FRAME f_debaut_incluir
DO:
    IF  KEY-FUNCTION(LASTKEY) = "D" THEN
        RETURN NO-APPLY.
    ELSE
        DO:
            RUN tecla.
        END.

    IF  CAN-DO("0,1,2,3,4,5,6,7,8,9,RETURN",KEY-FUNCTION(LASTKEY))  THEN
        DO:
            IF  LENGTH(REPLACE(ed_cdbarra2:SCREEN-VALUE," ","")) >= 12  THEN
                DO:
                    APPLY LASTKEY.
                    APPLY "ENTRY" TO ed_cdbarra3.
                    RETURN NO-APPLY.
                END.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            IF  LENGTH(TRIM(ed_cdbarra2:SCREEN-VALUE)) = 1  THEN
                DO:
                    APPLY "ENTRY" TO ed_cdbarra1.
                    APPLY "END" TO ed_cdbarra1.
                    RETURN NO-APPLY.
                END.
        END.
    ELSE
        /* Ignora */
        RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_cdbarra3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_cdbarra3 w_debaut_incluir
ON ANY-KEY OF ed_cdbarra3 IN FRAME f_debaut_incluir
DO:
    IF  KEY-FUNCTION(LASTKEY) = "D" THEN
        RETURN NO-APPLY.
    ELSE
        DO:
            RUN tecla.
        END.

    IF  CAN-DO("0,1,2,3,4,5,6,7,8,9,RETURN",KEY-FUNCTION(LASTKEY))  THEN
        DO:
            IF  LENGTH(REPLACE(ed_cdbarra3:SCREEN-VALUE," ","")) >= 12  THEN
                DO:
                    APPLY LASTKEY.
                    APPLY "ENTRY" TO ed_cdbarra4.
                    RETURN NO-APPLY.
                END.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            IF  LENGTH(TRIM(ed_cdbarra3:SCREEN-VALUE)) = 1  THEN
                DO:
                    APPLY "ENTRY" TO ed_cdbarra2.
                    APPLY "END" TO ed_cdbarra2.
                    RETURN NO-APPLY.
                END.
        END.
    ELSE
        /* Ignora */
        RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_cdbarra4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_cdbarra4 w_debaut_incluir
ON ANY-KEY OF ed_cdbarra4 IN FRAME f_debaut_incluir
DO:
    RUN tecla.

    IF  CAN-DO("0,1,2,3,4,5,6,7,8,9,RETURN",KEY-FUNCTION(LASTKEY))  THEN
        DO:
            IF  LENGTH(REPLACE(ed_cdbarra4:SCREEN-VALUE," ","")) >= 12  THEN
                DO:
                    APPLY LASTKEY.

                    /* verifica se o valor esta correto, caso contrario o documento
                     pode ser invalido. tamanho maximo zzz.zz9,99 */
                    IF  LENGTH(STRING(DECIMAL(SUBSTRING(
                                              SUBSTRING(ed_cdbarra1:SCREEN-VALUE,1,11) +
                                              ed_cdbarra2:SCREEN-VALUE,5,11)) / 100)) > 8  THEN
                        DO:
                            RUN mensagem.w (INPUT YES,
                                            INPUT "    ATENÇÃO",
                                            INPUT "",
                                            INPUT "",
                                            INPUT "Documento Inválido",
                                            INPUT "Valor Incorreto",
                                            INPUT "").
                            PAUSE 3 NO-MESSAGE.
                            h_mensagem:HIDDEN = YES.

                            APPLY "CHOOSE" TO Btn_C.
                            RETURN NO-APPLY.
                        END.

                    ASSIGN aux_temporiz = FALSE.

                    /* Buscar nome da empresa */
                    RUN procedures/busca_convenios_codbarras.p(INPUT TRIM(REPLACE(ed_cdbarra1:SCREEN-VALUE,".","")),
                                                               INPUT TRIM(REPLACE(ed_cdbarra2:SCREEN-VALUE,".","")),
                                                               INPUT TRIM(REPLACE(ed_cdbarra3:SCREEN-VALUE,".","")),
                                                               INPUT TRIM(REPLACE(ed_cdbarra4:SCREEN-VALUE,".","")),
                                                               INPUT ed_dscodbar:SCREEN-VALUE,
                                                               INPUT "I",
                                                               OUTPUT aux_nmextcon,
                                                               OUTPUT aux_flgderro).

                    IF  RETURN-VALUE = "OK" AND NOT aux_flgderro THEN
                        DO:                            
                            ed_nmempres:SCREEN-VALUE = aux_nmextcon.

                            APPLY "ENTRY" TO ed_cdrefere.
                            RETURN NO-APPLY.
                        END.
                    ELSE
                        DO:
                            ASSIGN ed_cdbarra1:SCREEN-VALUE = ""
                                   ed_cdbarra2:SCREEN-VALUE = ""
                                   ed_cdbarra3:SCREEN-VALUE = ""
                                   ed_cdbarra4:SCREEN-VALUE = "".
                                   ed_nmempres:SCREEN-VALUE = "".

                            APPLY "ENTRY" TO ed_cdbarra1.
                            RETURN NO-APPLY.
                        END.
                END.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            IF  LENGTH(TRIM(ed_cdbarra4:SCREEN-VALUE)) = 1  THEN
                DO:
                    APPLY "ENTRY" TO ed_cdbarra3.
                    APPLY "END" TO ed_cdbarra3.
                    RETURN NO-APPLY.
                END.
        END.
    ELSE
        /* Ignora */
        RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_cdrefere
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_cdrefere w_debaut_incluir
ON ANY-KEY OF ed_cdrefere IN FRAME f_debaut_incluir
DO:
    RUN tecla.

    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            APPLY "ENTRY" TO Btn_D.
            RETURN NO-APPLY.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        ed_cdrefere:SCREEN-VALUE = "".
    ELSE
    IF  RETURN-VALUE = "OK"  THEN
        RETURN "OK".

    
    /* se nao digitou numeros, despreza */
    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))   OR
        LENGTH(ed_cdrefere:SCREEN-VALUE) >= 17                    THEN
        RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_cdrefere w_debaut_incluir
ON ENTRY OF ed_cdrefere IN FRAME f_debaut_incluir
DO:
    ed_mensagem:SCREEN-VALUE = "Informe a identificação do consumidor e pressione ~"CONFIRMAR~"".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_dscodbar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_dscodbar w_debaut_incluir
ON ANY-KEY OF ed_dscodbar IN FRAME f_debaut_incluir
DO:
    IF  KEY-FUNCTION(LASTKEY) = "D" THEN
        RETURN NO-APPLY.
    ELSE
        DO:
            RUN tecla.
            RETURN NO-APPLY.
        END.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_dscodbar w_debaut_incluir
ON ENTRY OF ed_dscodbar IN FRAME f_debaut_incluir
DO:
    /* durante a criação do frame chama o ENTRY, desconsiderar */
    IF  FRAME-NAME <> "f_debaut_incluir"  THEN
        RETURN.

    /* desativa o temporizador de tela */
    chtemporizador:t_debaut_incluir:INTERVAL = 0.


    /* inicia a leitura assincrona */
    LT_resp = 0.       
           
    RUN WinStartLeAssincronoCodBarLcbCh IN aux_xfsliteh (INPUT 15, /* timeout 15s */
                                                         INPUT 0,  /* tamanho variavel */
                                                         OUTPUT LT_Resp).


    /* OK */
    IF  LT_Resp = 1  THEN
        DO:    
            chtemporizador_cod_barras:t_cod_barras:INTERVAL = 1000.
        END.
    ELSE
        DO:
            APPLY "CHOOSE" TO Btn_C.
            RETURN NO-APPLY.
        END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_debaut_incluir OCX.Tick
PROCEDURE temporizador.t_debaut_incluir.Tick .
ASSIGN aux_temporiz = TRUE.
    APPLY "CHOOSE" TO Btn_H IN FRAME f_debaut_incluir.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador_cod_barras
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador_cod_barras w_debaut_incluir OCX.Tick
PROCEDURE temporizador_cod_barras.t_cod_barras.Tick .
DEFINE VARIABLE buf_cddbarra     AS MEMPTR   NO-UNDO.
                
    SET-SIZE(buf_cddbarra) = 44.
    
    LT_resp = 0.
           
    RUN WinLeAssincronoCodBarLcbCh IN aux_xfsliteh (INPUT GET-POINTER-VALUE(buf_cddbarra),
                                                    OUTPUT LT_Resp).
    
    /* 1 - leitura com sucesso */
    IF  LT_Resp = 1 THEN
        DO:
            /* desativa o temporizador do cod de barras */
            chtemporizador_cod_barras:t_cod_barras:INTERVAL = 0.

            /* ativa o temporizador de tela */
            chtemporizador:t_debaut_incluir:INTERVAL = glb_nrtempor.

            ed_dscodbar:SCREEN-VALUE IN FRAME f_debaut_incluir = GET-STRING(buf_cddbarra,1).

            /* verifica se o valor esta correto, caso contrario o documento
               pode ser invalido. tamanho maximo zzz.zz9,99 */
            IF  LENGTH(STRING(DECIMAL(SUBSTRING(ed_dscodbar:SCREEN-VALUE,5,11)) / 100)) > 8  THEN
                DO:                
                    RUN mensagem.w (INPUT YES,
                                    INPUT "    ATENÇÃO",
                                    INPUT "",
                                    INPUT "",
                                    INPUT "Documento Inválido",
                                    INPUT "Valor Incorreto",
                                    INPUT "").
                    PAUSE 3 NO-MESSAGE.
                    h_mensagem:HIDDEN = YES.

                    APPLY "CHOOSE" TO Btn_C.
                    RETURN NO-APPLY.
                END.

            /* Buscar nome da empresa */
            RUN procedures/busca_convenios_codbarras.p(INPUT TRIM(REPLACE(ed_cdbarra1:SCREEN-VALUE,".","")),
                                                       INPUT TRIM(REPLACE(ed_cdbarra2:SCREEN-VALUE,".","")),
                                                       INPUT TRIM(REPLACE(ed_cdbarra3:SCREEN-VALUE,".","")),
                                                       INPUT TRIM(REPLACE(ed_cdbarra4:SCREEN-VALUE,".","")),
                                                       INPUT ed_dscodbar:SCREEN-VALUE,
                                                       INPUT "I",
                                                       OUTPUT aux_nmextcon,
                                                       OUTPUT aux_flgderro).

            IF  RETURN-VALUE = "OK" AND NOT aux_flgderro THEN
                DO:
                    ed_nmempres:SCREEN-VALUE = aux_nmextcon.
                    APPLY "ENTRY" TO ed_cdrefere.                    
                    RETURN NO-APPLY.
                END.
            ELSE
                DO:
                    ASSIGN ed_dscodbar:SCREEN-VALUE = "".
                    APPLY "ENTRY" TO ed_dscodbar.
                    RETURN NO-APPLY.
                END.            
        END.
    ELSE
    /* 12 - operacao em andamento */
    IF  LT_Resp <> 12   THEN 
        DO: 
            /* cancela a leitora */
            RUN WinCancelaLeituraCodBarLcbCh IN aux_xfsliteh (OUTPUT LT_Resp).

            /* desativa o temporizador do cod de barras */
            chtemporizador_cod_barras:t_cod_barras:INTERVAL = 0.

            /* ativa o temporizador de tela */
            chtemporizador:t_debaut_incluir:INTERVAL = glb_nrtempor.

            APPLY "CHOOSE" TO Btn_C IN FRAME f_debaut_incluir.
        END.
    
    SET-SIZE(buf_cddbarra) = 0.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_debaut_incluir 


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
    FRAME f_debaut_incluir:LOAD-MOUSE-POINTER("blank.cur").

    ASSIGN chtemporizador:t_debaut_incluir:INTERVAL = glb_nrtempor

           /* Dados do associado */
           ed_cdagectl = glb_cdagectl
           ed_nmrescop = " - " + glb_nmrescop
           ed_nrdconta = glb_nrdconta
           ed_nmextttl = glb_nmtitula[1].

    DISPLAY ed_cdagectl  ed_nmrescop
            ed_nrdconta  ed_nmextttl
            WITH FRAME f_debaut_incluir.    

    IF  par_cdbarra1 <> ""  AND
        par_cdbarra2 <> ""  AND
        par_cdbarra3 <> ""  AND
        par_cdbarra4 <> ""  THEN
        DO:
            ASSIGN ed_cdbarra1:SCREEN-VALUE = par_cdbarra1
                   ed_cdbarra2:SCREEN-VALUE = par_cdbarra2
                   ed_cdbarra3:SCREEN-VALUE = par_cdbarra3
                   ed_cdbarra4:SCREEN-VALUE = par_cdbarra4
                   ed_dscodbar:SCREEN-VALUE = "".

            RUN procedures/busca_convenios_codbarras.p(INPUT TRIM(REPLACE(ed_cdbarra1:SCREEN-VALUE,".","")),
                                                       INPUT TRIM(REPLACE(ed_cdbarra2:SCREEN-VALUE,".","")),
                                                       INPUT TRIM(REPLACE(ed_cdbarra3:SCREEN-VALUE,".","")),
                                                       INPUT TRIM(REPLACE(ed_cdbarra4:SCREEN-VALUE,".","")),
                                                       INPUT ed_dscodbar:SCREEN-VALUE,
                                                       INPUT "I",
                                                       OUTPUT aux_nmextcon,
                                                       OUTPUT aux_flgderro).

            IF  RETURN-VALUE = "OK" AND NOT aux_flgderro THEN
                DO:
                    ed_nmempres:SCREEN-VALUE = aux_nmextcon.

                    chtemporizador:t_debaut_incluir:INTERVAL = 0.
                    chtemporizador:t_debaut_incluir:INTERVAL = glb_nrtempor.

                    APPLY "ENTRY" TO ed_cdrefere.
                END.
            ELSE
                DO:
                    ASSIGN ed_cdbarra1:SCREEN-VALUE = ""
                           ed_cdbarra2:SCREEN-VALUE = ""
                           ed_cdbarra3:SCREEN-VALUE = ""
                           ed_cdbarra4:SCREEN-VALUE = ""
                           ed_nmempres:SCREEN-VALUE = ""
                           ed_dscodbar:SCREEN-VALUE = "".

                    RUN habilita_manual.

                    APPLY "ENTRY" TO ed_cdbarra1.
                END.
        END.
    ELSE 
    IF (par_dscodbar <> "" OR 
        ed_dscodbar:SCREEN-VALUE <> "") AND
        ed_cdrefere:SCREEN-VALUE = ""   THEN
        DO:
            ASSIGN ed_cdbarra1:SCREEN-VALUE = ""
                   ed_cdbarra2:SCREEN-VALUE = ""
                   ed_cdbarra3:SCREEN-VALUE = ""
                   ed_cdbarra4:SCREEN-VALUE = ""
                   ed_dscodbar:SCREEN-VALUE = par_dscodbar.

            RUN procedures/busca_convenios_codbarras.p(INPUT TRIM(REPLACE(ed_cdbarra1:SCREEN-VALUE,".","")),
                                                       INPUT TRIM(REPLACE(ed_cdbarra2:SCREEN-VALUE,".","")),
                                                       INPUT TRIM(REPLACE(ed_cdbarra3:SCREEN-VALUE,".","")),
                                                       INPUT TRIM(REPLACE(ed_cdbarra4:SCREEN-VALUE,".","")),
                                                       INPUT ed_dscodbar:SCREEN-VALUE,
                                                       INPUT "I",
                                                       OUTPUT aux_nmextcon,
                                                       OUTPUT aux_flgderro).

            IF  RETURN-VALUE = "OK" AND NOT aux_flgderro THEN
                DO:
                    ed_nmempres:SCREEN-VALUE = aux_nmextcon.

                    chtemporizador:t_debaut_incluir:INTERVAL = 0.
                    chtemporizador:t_debaut_incluir:INTERVAL = glb_nrtempor.

                    APPLY "ENTRY" TO ed_cdrefere.
                END.
            ELSE
                DO:
                    ASSIGN ed_cdbarra1:SCREEN-VALUE = ""
                           ed_cdbarra2:SCREEN-VALUE = ""
                           ed_cdbarra3:SCREEN-VALUE = ""
                           ed_cdbarra4:SCREEN-VALUE = ""
                           ed_nmempres:SCREEN-VALUE = ""
                           ed_dscodbar:SCREEN-VALUE = "".

                    IF  xfs_lcbarras  THEN
                        RUN habilita_leitora.
                    ELSE
                        RUN habilita_manual.
                END.
        END.
    ELSE
        DO:
            IF  xfs_lcbarras  THEN
                RUN habilita_leitora.
            ELSE
                RUN habilita_manual.
        END.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_debaut_incluir  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_pagamento_debaut_incluir.wrx":U ).
IF OCXFile = ? THEN
  OCXFile = SEARCH(SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1,
                     R-INDEX(THIS-PROCEDURE:FILE-NAME, ".":U), "CHARACTER":U) + "wrx":U).

IF OCXFile <> ? THEN
DO:
  ASSIGN
    chtemporizador = temporizador:COM-HANDLE
    UIB_S = chtemporizador:LoadControls( OCXFile, "temporizador":U)
    temporizador:NAME = "temporizador":U
    chtemporizador_cod_barras = temporizador_cod_barras:COM-HANDLE
    UIB_S = chtemporizador_cod_barras:LoadControls( OCXFile, "temporizador_cod_barras":U)
    temporizador_cod_barras:NAME = "temporizador_cod_barras":U
  .
  RUN initialize-controls IN THIS-PROCEDURE NO-ERROR.
END.
ELSE MESSAGE "cartao_pagamento_debaut_incluir.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_debaut_incluir  _DEFAULT-DISABLE
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
  HIDE FRAME f_debaut_incluir.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_debaut_incluir  _DEFAULT-ENABLE
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
  DISPLAY ed_dscodbar ed_cdbarra1 ed_cdbarra2 ed_cdbarra3 ed_cdbarra4 
          ed_nmempres ed_cdrefere ed_mensagem ed_cdagectl ed_nmrescop 
          ed_nrdconta ed_nmextttl 
      WITH FRAME f_debaut_incluir.
  ENABLE RECT-127 RECT-132 RECT-136 RECT-137 RECT-138 IMAGE-36 IMAGE-37 
         IMAGE-40 RECT-133 RECT-134 ed_dscodbar ed_cdbarra1 ed_cdbarra2 
         ed_cdbarra3 ed_cdbarra4 ed_cdrefere Btn_C ed_mensagem Btn_D Btn_H 
         ed_cdagectl ed_nmrescop ed_nrdconta ed_nmextttl 
      WITH FRAME f_debaut_incluir.
  {&OPEN-BROWSERS-IN-QUERY-f_debaut_incluir}
  VIEW w_debaut_incluir.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE habilita_leitora w_debaut_incluir 
PROCEDURE habilita_leitora :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DO  WITH FRAME f_debaut_incluir:

        Btn_C:LABEL = "INCLUSÃO MANUAL".
    
        /* desativa os campos manuais */
        ASSIGN ed_cdbarra1:READ-ONLY    = YES
               ed_cdbarra1:BGCOLOR      = 8
               ed_cdbarra1:SCREEN-VALUE = ""
        
               ed_cdbarra2:READ-ONLY    = YES
               ed_cdbarra2:BGCOLOR      = 8
               ed_cdbarra2:SCREEN-VALUE = ""
                                        
               ed_cdbarra3:READ-ONLY    = YES
               ed_cdbarra3:BGCOLOR      = 8
               ed_cdbarra3:SCREEN-VALUE = ""
                                        
               ed_cdbarra4:READ-ONLY    = YES
               ed_cdbarra4:BGCOLOR      = 8
               ed_cdbarra4:SCREEN-VALUE = ""
                                        
               ed_dscodbar:READ-ONLY    = NO
               ed_dscodbar:BGCOLOR      = ?
               ed_dscodbar:SCREEN-VALUE = ""

               ed_nmempres:SCREEN-VALUE = ""
               ed_cdrefere:SCREEN-VALUE = ""

               ed_mensagem:SCREEN-VALUE = "Posicione o código de barras no feixe de luz...".
        
        APPLY "ENTRY" TO ed_dscodbar.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE habilita_manual w_debaut_incluir 
PROCEDURE habilita_manual :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DO  WITH FRAME f_debaut_incluir:

        Btn_C:LABEL = "CORRIGE".
    
        /* desativa os campos manuais */
        ASSIGN ed_cdbarra1:READ-ONLY    = NO
               ed_cdbarra1:BGCOLOR      = ?
                                        
               ed_cdbarra2:READ-ONLY    = NO
               ed_cdbarra2:BGCOLOR      = ?
                                        
               ed_cdbarra3:READ-ONLY    = NO
               ed_cdbarra3:BGCOLOR      = ?
                                        
               ed_cdbarra4:READ-ONLY    = NO
               ed_cdbarra4:BGCOLOR      = ?
                                        
               ed_dscodbar:READ-ONLY    = YES
               ed_dscodbar:BGCOLOR      = 8
               ed_dscodbar:SCREEN-VALUE = ""

               ed_nmempres:SCREEN-VALUE = ""
               ed_cdrefere:SCREEN-VALUE = ""

               ed_mensagem:SCREEN-VALUE = "Informe a linha digitável...".
        
        APPLY "ENTRY" TO ed_cdbarra1.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_debaut_incluir 
PROCEDURE tecla :
chtemporizador:t_debaut_incluir:INTERVAL = 0.

    IF  KEY-FUNCTION(LASTKEY) = "C"                           AND
        Btn_C:SENSITIVE IN FRAME f_debaut_incluir  THEN
        APPLY "CHOOSE" TO Btn_C.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "D"                           AND
        Btn_D:SENSITIVE IN FRAME f_debaut_incluir  THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                           AND
        Btn_H:SENSITIVE IN FRAME f_debaut_incluir  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_debaut_incluir:INTERVAL = glb_nrtempor.
    
    
    IF  RETURN-VALUE = "OK"  THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.    
            RETURN "OK".
        END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

