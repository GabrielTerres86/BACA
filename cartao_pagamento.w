&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_cartao_pagamento
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_cartao_pagamento 
/* ..............................................................................

Procedure: cartao_pagamento.w (antigo cartao_pagamento_convenio.w)
Objetivo : Tela para pagamento de convenios e titulos
Autor    : Evandro
Data     : Janeiro 2010

Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).
            
                  08/05/2013 - Transferencia intercooperativa (Gabriel).
                  
                  20/08/2015 - Unificado os fontes cartao_pagamento_titulo e 
                               cartao_pagamento_conveio, será verificado o tipo de
                               documento na digitação do codigo de barras ou linha digitavel.
                               Melhoria-21 SD278322 (Odirlei-AMcom)
                  
                  24/09/2015 - Alterado para desabilitar a leitora assim que 
                               pressionada uma tecla no campo de dscodbar e quando
                               o campo volta a ficar vazio habilita novamente(Odirlei-AMcom)
                  
                  30/09/2015 - Ajuste para na saida do campo dscodbar sempre ir para o campo
                               de valor caso seja um titulo (Odirlei-AMcom)  
                                                           
                              24/03/2015 - Ajustes referentes aos chamados 373337 e 416733, linha digitavel
                                               incompleta e pagamento de fatura com valor zerado (Tiago/Fabricio).

                                  03/10/2016 - Ajustes referente a melhoria M271. (Kelvin)

                          23/11/2016 - Ajustar validação do valor para carregar corretamente na tela
                                               (Douglas - Melhoria 271)
                               
                          20/01/2017 - Exibir nome do beneficiario e ajustes NPC.
                                       PRJ340 - NPC (Odirlei-AMcom)
                                       
                  28/08/2017 - #720031 Ajuste na rotina extrai_valor_codbar para nao
                               aceitar valor zerado e tambem nao permitir editar o 
                               campo valor caso seja uma fatura (Carlos)
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
DEF INPUT   PARAM par_flagenda   AS LOGICAL             NO-UNDO.

/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }
{ includes/var_xfs_lite.i }

DEFINE VARIABLE aux_flgderro        AS LOGICAL      NO-UNDO.
DEFINE VARIABLE aux_datpagto        AS DATE         NO-UNDO.
DEFINE VARIABLE aux_sfcodbar        AS CHAR         NO-UNDO.
DEFINE VARIABLE aux_valor           AS CHAR         NO-UNDO.
DEFINE VARIABLE aux_vlfatura        AS DECI         NO-UNDO.
DEFINE VARIABLE aux_vlrjuros        AS DECI         NO-UNDO.
DEFINE VARIABLE aux_vlrmulta        AS DECI         NO-UNDO.
DEFINE VARIABLE aux_fltitven        AS INTE         NO-UNDO.
DEFINE VARIABLE aux_inpesbnf        AS INTE         NO-UNDO.
DEFINE VARIABLE aux_nrdocbnf        AS DECI         NO-UNDO.
DEFINE VARIABLE aux_nmbenefi        AS CHAR         NO-UNDO.
DEFINE VARIABLE aux_nrctlnpc        AS CHAR         NO-UNDO.
DEFINE VARIABLE aux_dscritic        AS CHAR         NO-UNDO.                                                  
DEFINE VARIABLE aux_des_erro        AS CHAR         NO-UNDO.
DEFINE VARIABLE aux_flblqval        AS INTE         NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_cartao_pagamento

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-132 RECT-133 IMAGE-36 IMAGE-37 IMAGE-40 ~
RECT-134 ed_dscodbar ed_nmbenefi ed_vldpagto ed_datpagto Btn_C ed_mensagem ~
Btn_D Btn_H ed_cdagectl ed_nmrescop ed_nrdconta ed_nmextttl 
&Scoped-Define DISPLAYED-OBJECTS ed_dscodbar ed_vldpagto ed_datpagto ~
ed_mensagem ed_cdagectl ed_nmrescop ed_nrdconta ed_nmextttl 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_cartao_pagamento AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.
DEFINE VARIABLE temporizador_cod_barras AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador_cod_barras AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_C 
     LABEL "CORRIGE" 
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

DEFINE VARIABLE ed_datpagto AS CHARACTER FORMAT "xx/xx/xxxx":U 
     VIEW-AS FILL-IN 
     SIZE 23 BY 1.19
     FONT 14 NO-UNDO.

DEFINE VARIABLE ed_dscodbar AS CHARACTER FORMAT "x(44)":U 
     VIEW-AS FILL-IN 
     SIZE 108 BY 1.19
     FONT 14 NO-UNDO.

DEFINE VARIABLE ed_idtpdpag AS INTEGER FORMAT "Z":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 8.4 BY 1.19
     FONT 14 NO-UNDO.

DEFINE VARIABLE ed_nmbenefi AS CHARACTER FORMAT "x(60)":U 
     VIEW-AS FILL-IN 
     SIZE 108 BY 1.19
     BGCOLOR 15 FONT 14 NO-UNDO.

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

DEFINE VARIABLE ed_tpcptdoc AS INTEGER FORMAT "Z":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 8.4 BY 1.19
     FONT 14 NO-UNDO.

DEFINE VARIABLE ed_vldpagto AS DECIMAL FORMAT "zzz,zzz,zz9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 24.2 BY 1.19
     FONT 14 NO-UNDO.

DEFINE VARIABLE Label_nmbenefi AS CHARACTER FORMAT "x(60)":U 
     VIEW-AS FILL-IN 
     SIZE 22 BY 1.19
     FONT 14 NO-UNDO.

DEFINE IMAGE IMAGE-36
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-37
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-40
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE RECTANGLE F_nmbenefi
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 110 BY 1.67.

DEFINE RECTANGLE RECT-100
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 2 .

DEFINE RECTANGLE RECT-132
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 110 BY 1.67.

DEFINE RECTANGLE RECT-133
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 26.2 BY 1.67.

DEFINE RECTANGLE RECT-134
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 25 BY 1.67.

DEFINE RECTANGLE RECT-98
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-99
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .24
     BGCOLOR 14 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_cartao_pagamento
     ed_dscodbar AT ROW 10.76 COL 33 COLON-ALIGNED NO-LABEL WIDGET-ID 162
     Label_nmbenefi AT ROW 12.62 COL 31 RIGHT-ALIGNED NO-LABEL WIDGET-ID 262
     ed_nmbenefi AT ROW 12.62 COL 33 COLON-ALIGNED NO-LABEL WIDGET-ID 258
     ed_vldpagto AT ROW 15.52 COL 70 RIGHT-ALIGNED NO-LABEL WIDGET-ID 166
     ed_idtpdpag AT ROW 15.52 COL 140 COLON-ALIGNED NO-LABEL WIDGET-ID 256
     ed_tpcptdoc AT ROW 15.52 COL 150 COLON-ALIGNED NO-LABEL WIDGET-ID 254
     ed_datpagto AT ROW 17.38 COL 68.8 RIGHT-ALIGNED NO-LABEL WIDGET-ID 246
     Btn_C AT ROW 19.1 COL 6 WIDGET-ID 154
     ed_mensagem AT ROW 19.1 COL 94.4 NO-LABEL WIDGET-ID 164 NO-TAB-STOP 
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 156
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 158
     ed_cdagectl AT ROW 6 COL 46 COLON-ALIGNED NO-LABEL WIDGET-ID 238 NO-TAB-STOP 
     ed_nmrescop AT ROW 6 COL 62 COLON-ALIGNED NO-LABEL WIDGET-ID 242 NO-TAB-STOP 
     ed_nrdconta AT ROW 7.43 COL 46 COLON-ALIGNED NO-LABEL WIDGET-ID 244 NO-TAB-STOP 
     ed_nmextttl AT ROW 7.43 COL 72 COLON-ALIGNED NO-LABEL WIDGET-ID 240 NO-TAB-STOP 
     "Valor:" VIEW-AS TEXT
          SIZE 11 BY 1.19 AT ROW 15.76 COL 34.8 WIDGET-ID 152
          FONT 14
     "Cod. Barras /" VIEW-AS TEXT
          SIZE 26 BY 1.19 AT ROW 9.81 COL 7 WIDGET-ID 178
          FONT 14
     "Linha Digitável:" VIEW-AS TEXT
          SIZE 26 BY 1.19 AT ROW 11 COL 7 WIDGET-ID 176
          FONT 14
     "Conta/Titular:" VIEW-AS TEXT
          SIZE 29 BY 1.19 AT ROW 7.43 COL 17 WIDGET-ID 140
          FONT 8
     "Data do Pagamento:" VIEW-AS TEXT
          SIZE 35 BY 1.19 AT ROW 17.62 COL 10.4 WIDGET-ID 250
          FONT 14
     "Cooperativa:" VIEW-AS TEXT
          SIZE 28 BY 1.19 AT ROW 6 COL 18.6 WIDGET-ID 134
          FONT 8
     "        PAGAMENTO" VIEW-AS TEXT
          SIZE 100 BY 3.33 AT ROW 1.48 COL 31 WIDGET-ID 214
          FGCOLOR 1 FONT 10
     RECT-132 AT ROW 10.52 COL 34 WIDGET-ID 170
     RECT-133 AT ROW 15.29 COL 45.8 WIDGET-ID 172
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-36 AT ROW 19.24 COL 1 WIDGET-ID 146
     IMAGE-37 AT ROW 24.24 COL 1 WIDGET-ID 148
     IMAGE-40 AT ROW 24.24 COL 156 WIDGET-ID 218
     RECT-134 AT ROW 17.14 COL 45.8 WIDGET-ID 248
     F_nmbenefi AT ROW 12.38 COL 34 WIDGET-ID 260
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
  CREATE WINDOW w_cartao_pagamento ASSIGN
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
ASSIGN w_cartao_pagamento = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_cartao_pagamento
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_cartao_pagamento
   FRAME-NAME                                                           */
/* SETTINGS FOR FILL-IN ed_datpagto IN FRAME f_cartao_pagamento
   ALIGN-R                                                              */
ASSIGN 
       ed_dscodbar:READ-ONLY IN FRAME f_cartao_pagamento        = TRUE.

/* SETTINGS FOR FILL-IN ed_idtpdpag IN FRAME f_cartao_pagamento
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       ed_idtpdpag:HIDDEN IN FRAME f_cartao_pagamento           = TRUE
       ed_idtpdpag:READ-ONLY IN FRAME f_cartao_pagamento        = TRUE.

ASSIGN 
       ed_mensagem:READ-ONLY IN FRAME f_cartao_pagamento        = TRUE.

/* SETTINGS FOR FILL-IN ed_nmbenefi IN FRAME f_cartao_pagamento
   NO-DISPLAY                                                           */
ASSIGN 
       ed_nmbenefi:HIDDEN IN FRAME f_cartao_pagamento           = TRUE
       ed_nmbenefi:READ-ONLY IN FRAME f_cartao_pagamento        = TRUE.

/* SETTINGS FOR FILL-IN ed_tpcptdoc IN FRAME f_cartao_pagamento
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       ed_tpcptdoc:HIDDEN IN FRAME f_cartao_pagamento           = TRUE
       ed_tpcptdoc:READ-ONLY IN FRAME f_cartao_pagamento        = TRUE.

/* SETTINGS FOR FILL-IN ed_vldpagto IN FRAME f_cartao_pagamento
   ALIGN-R                                                              */
/* SETTINGS FOR RECTANGLE F_nmbenefi IN FRAME f_cartao_pagamento
   NO-ENABLE                                                            */
ASSIGN 
       F_nmbenefi:HIDDEN IN FRAME f_cartao_pagamento           = TRUE.

/* SETTINGS FOR FILL-IN Label_nmbenefi IN FRAME f_cartao_pagamento
   NO-DISPLAY NO-ENABLE ALIGN-R                                         */
ASSIGN 
       Label_nmbenefi:HIDDEN IN FRAME f_cartao_pagamento           = TRUE
       Label_nmbenefi:READ-ONLY IN FRAME f_cartao_pagamento        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_cartao_pagamento
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_cartao_pagamento
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_cartao_pagamento
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_cartao_pagamento:HANDLE
       ROW             = 1.71
       COLUMN          = 17
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.

CREATE CONTROL-FRAME temporizador_cod_barras ASSIGN
       FRAME           = FRAME f_cartao_pagamento:HANDLE
       ROW             = 10.52
       COLUMN          = 146.4
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 174
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_pagamento */
/* temporizador_cod_barras OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cod_barras */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_cartao_pagamento
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_pagamento w_cartao_pagamento
ON END-ERROR OF w_cartao_pagamento
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_pagamento w_cartao_pagamento
ON WINDOW-CLOSE OF w_cartao_pagamento
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_C
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_C w_cartao_pagamento
ON ANY-KEY OF Btn_C IN FRAME f_cartao_pagamento /* CORRIGE */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_C w_cartao_pagamento
ON CHOOSE OF Btn_C IN FRAME f_cartao_pagamento /* CORRIGE */
DO:
    /* Reiniciar campos e posicionar no campo de codigo de barras */
    ASSIGN ed_dscodbar:SCREEN-VALUE = ""
           ed_tpcptdoc:SCREEN-VALUE = "0"
           ed_idtpdpag:SCREEN-VALUE = "0"
           ed_datpagto:SCREEN-VALUE = ""
           ed_nmbenefi:SCREEN-VALUE = ""
           Label_nmbenefi:SCREEN-VALUE = ""
           ed_dscodbar:FORMAT = "x(44)"
           aux_sfcodbar = "".
    ed_nmbenefi:HIDDEN    IN FRAME f_cartao_pagamento = TRUE.
    Label_nmbenefi:HIDDEN IN FRAME f_cartao_pagamento = TRUE.
    F_nmbenefi:HIDDEN     IN FRAME f_cartao_pagamento = TRUE.
    RUN habilita_campos.

    APPLY "ENTRY" TO ed_vldpagto.
    APPLY "ENTRY" TO ed_dscodbar.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_pagamento
ON ANY-KEY OF Btn_D IN FRAME f_cartao_pagamento /* CONFIRMAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_pagamento
ON CHOOSE OF Btn_D IN FRAME f_cartao_pagamento /* CONFIRMAR */
DO:
    /* ---------- */
    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).
    
    IF  aux_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.

IF  par_flagenda THEN
    DO:    
        ASSIGN aux_datpagto = DATE(ed_datpagto:SCREEN-VALUE) NO-ERROR.
        
        IF  ERROR-STATUS:ERROR THEN
            DO:
                RUN mensagem.w (INPUT YES,
                                    INPUT "    Atenção!",
                                    INPUT "",
                                    INPUT "Data inválida.",
                                    INPUT "",
                                    INPUT "",
                                    INPUT "").
                
                PAUSE 3 NO-MESSAGE.
                h_mensagem:HIDDEN = YES.
            
                aux_flgderro = YES.
            END.
        ELSE
        IF  aux_datpagto = ? THEN
            DO:
                RUN mensagem.w (INPUT YES,
                                        INPUT "    Atenção!",
                                        INPUT "",
                                        INPUT "Deve ser informada uma data.",
                                        INPUT "",
                                        INPUT "",
                                        INPUT "").
                    
                    PAUSE 3 NO-MESSAGE.
                    h_mensagem:HIDDEN = YES.
                
                    aux_flgderro = YES.
            END.
        ELSE
            DO:
                IF  aux_datpagto <= TODAY THEN
                    DO:
                        RUN mensagem.w (INPUT YES,
                                        INPUT "    Atenção!",
                                        INPUT "",
                                        INPUT "A data deve ser superior",
                                        INPUT "a data atual.",
                                        INPUT "",
                                        INPUT "").
                    
                        PAUSE 3 NO-MESSAGE.
                        h_mensagem:HIDDEN = YES.
                    
                        aux_flgderro = YES.
                    END.           
            END.
        /* se for problema da data, voltar o campo para a data */
        IF  aux_flgderro THEN
        DO:
            ASSIGN ed_datpagto:SCREEN-VALUE = "".
            APPLY "ENTRY" TO ed_datpagto.
            RETURN NO-APPLY.
        END.

            
    END.

    IF  aux_flgderro THEN
        DO:
            APPLY "CHOOSE" TO Btn_C.
            RETURN NO-APPLY.
        END.


    IF ed_idtpdpag:SCREEN-VALUE = "1" THEN /* CONVENIO */
    DO:  

        RUN cartao_pagamento_convenio_dados.w (INPUT ( IF ed_tpcptdoc:SCREEN-VALUE = "1" THEN ed_dscodbar:SCREEN-VALUE ELSE ""),
                                               INPUT ( IF ed_tpcptdoc:SCREEN-VALUE = "2" THEN SUBSTR(aux_sfcodbar, 1,12) ELSE ""),
                                               INPUT ( IF ed_tpcptdoc:SCREEN-VALUE = "2" THEN SUBSTR(aux_sfcodbar,13,12) ELSE ""),
                                               INPUT ( IF ed_tpcptdoc:SCREEN-VALUE = "2" THEN SUBSTR(aux_sfcodbar,25,12) ELSE ""),
                                               INPUT ( IF ed_tpcptdoc:SCREEN-VALUE = "2" THEN SUBSTR(aux_sfcodbar,37,12) ELSE ""),
                                               INPUT DEC(ed_vldpagto:SCREEN-VALUE),
                                               INPUT ed_datpagto:SCREEN-VALUE,
                                               INPUT par_flagenda,
                                               INPUT INT(ed_idtpdpag:SCREEN-VALUE),
                                               INPUT int(ed_tpcptdoc:SCREEN-VALUE)
                                               ).
        
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FRAME f_cartao_pagamento:MOVE-TO-TOP().
            
                RUN habilita_campos.    
            END.
        ELSE
            DO:
                APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                RETURN "OK".
            END.


    END.
    ELSE
        IF ed_idtpdpag:SCREEN-VALUE = "2" THEN /* TITULO */
        DO:

            RUN cartao_pagamento_titulo_dados.w (INPUT ( IF ed_tpcptdoc:SCREEN-VALUE = "1" THEN ed_dscodbar:SCREEN-VALUE ELSE ""),
                                                 INPUT ( IF ed_tpcptdoc:SCREEN-VALUE = "2" THEN SUBSTR(aux_sfcodbar, 1,10) ELSE ""),
                                                 INPUT ( IF ed_tpcptdoc:SCREEN-VALUE = "2" THEN SUBSTR(aux_sfcodbar, 11,11) ELSE ""),
                                                 INPUT ( IF ed_tpcptdoc:SCREEN-VALUE = "2" THEN SUBSTR(aux_sfcodbar, 22,11) ELSE ""),
                                                 INPUT ( IF ed_tpcptdoc:SCREEN-VALUE = "2" THEN SUBSTR(aux_sfcodbar, 33,1) ELSE ""),
                                                 INPUT ( IF ed_tpcptdoc:SCREEN-VALUE = "2" THEN SUBSTR(aux_sfcodbar, 34,14) ELSE ""),
                                                 INPUT DEC(ed_vldpagto:SCREEN-VALUE),
                                                 INPUT DATE(ed_datpagto:SCREEN-VALUE),
                                                 INPUT par_flagenda,
                                               INPUT INT(ed_idtpdpag:SCREEN-VALUE),
                                                 INPUT INT(ed_tpcptdoc:SCREEN-VALUE),
                                                 INPUT aux_nrctlnpc).
        
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    /* joga o frame frente */
                    FRAME f_cartao_pagamento:MOVE-TO-TOP().
                
                    RUN habilita_campos.
                END.
            ELSE
                DO:
                    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                    RETURN "OK".
                END.

        END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_pagamento
ON ENTRY OF Btn_D IN FRAME f_cartao_pagamento /* CONFIRMAR */
DO:
    ed_mensagem:SCREEN-VALUE = "Pressione ~"CONFIRMAR~"".
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_pagamento
ON ANY-KEY OF Btn_H IN FRAME f_cartao_pagamento /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_pagamento
ON CHOOSE OF Btn_H IN FRAME f_cartao_pagamento /* VOLTAR */
DO:
    ASSIGN ed_dscodbar:SCREEN-VALUE = ""
           ed_tpcptdoc:SCREEN-VALUE = "0"
           ed_idtpdpag:SCREEN-VALUE = "0"
           ed_dscodbar:FORMAT = "x(44)"
           aux_sfcodbar = "".

    /* desativa o temporizador do cod de barras */
    chtemporizador_cod_barras:t_cod_barras:INTERVAL = 0.

    /* cancela a leitora */
    RUN WinCancelaLeituraCodBarLcbCh IN aux_xfsliteh (OUTPUT LT_Resp).
            
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_datpagto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_datpagto w_cartao_pagamento
ON ANY-KEY OF ed_datpagto IN FRAME f_cartao_pagamento
DO:
    RUN tecla.

    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            APPLY "ENTRY" TO Btn_D.
            RETURN NO-APPLY.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        ed_datpagto:SCREEN-VALUE = "".
    ELSE
    IF  RETURN-VALUE = "OK"  THEN
        RETURN "OK".

    
    /* se nao digitou numeros, despreza */
    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))   OR
        LENGTH(ed_datpagto:SCREEN-VALUE) >= 10                    THEN
        RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_datpagto w_cartao_pagamento
ON ENTRY OF ed_datpagto IN FRAME f_cartao_pagamento
DO:
    ed_mensagem:SCREEN-VALUE = "Informe a data de pagamento e pressione ~"CONFIRMAR~"".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_dscodbar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_dscodbar w_cartao_pagamento
ON ANY-KEY OF ed_dscodbar IN FRAME f_cartao_pagamento
DO:
    IF  KEY-FUNCTION(LASTKEY) = "D" THEN
        RETURN NO-APPLY.
    IF KEY-FUNCTION(LASTKEY) = "C" THEN
        APPLY "CHOOSE" TO Btn_C.
    ELSE 
    DO:
        RUN tecla.
        
        /* Se for o primeiro digito, verificar qual o formato a ser utilizado*/
        IF TRIM(ed_dscodbar:SCREEN-VALUE) = "" THEN
            DO:
                
                /* Se o campo estava em branco e é digitado a primeira tecla
                   deve cancelar a leitora */
                IF CAN-DO("0,1,2,3,4,5,6,7,8,9,RETURN",KEY-FUNCTION(LASTKEY)) THEN
                  DO: 
                    /* desativa o temporizador do cod de barras */
                    chtemporizador_cod_barras:t_cod_barras:INTERVAL = 0. 

                    RUN WinCancelaLeituraCodBarLcbCh IN aux_xfsliteh (OUTPUT LT_Resp). 
                  END. 

                /*Se a tecla for 8 é convenio*/
                IF KEY-FUNCTION(LASTKEY) = "8" THEN
                  DO:
    
                    ed_dscodbar:FORMAT = "99999999999-9 99999999999-9 99999999999-9 99999999999-9".
                    ASSIGN ed_tpcptdoc:SCREEN-VALUE = "2"  /* LINHA DIGITAVEL */
                           ed_idtpdpag:SCREEN-VALUE = "1". /*FATURA*/
    
    
                  END.
                ELSE  /*se for numeros menos o 8 é titulo*/
                  IF CAN-DO("0,1,2,3,4,5,6,7,9,RETURN",KEY-FUNCTION(LASTKEY)) THEN
                    DO:
    
                      ed_dscodbar:FORMAT = "99999.99999 99999.999999 99999.999999 9 99999999999999".
                      ASSIGN ed_tpcptdoc:SCREEN-VALUE = "2" /* LINHA DIGITAVEL */
                             ed_idtpdpag:SCREEN-VALUE = "2". /*TITULO*/
        
                    END.
                  ELSE 
                    RETURN NO-APPLY.
            END.
        ELSE
        DO:
            IF ed_tpcptdoc:SCREEN-VALUE = "2"   AND  
               ed_idtpdpag:SCREEN-VALUE = "2"   AND 
               KEY-FUNCTION(LASTKEY) = "RETURN" THEN
            DO:
                APPLY "LEAVE" TO ed_dscodbar.
            END.                             
        END.


        APPLY KEY-FUNCTION(LASTKEY).

        IF TRIM(REPLACE(REPLACE(ed_dscodbar:SCREEN-VALUE,".",""),"-","")) = "" THEN
            DO:
                ASSIGN ed_dscodbar:FORMAT = "x(44)"
                       ed_dscodbar:SCREEN-VALUE = ""
                       aux_sfcodbar = "".

                /* se o campo voltou a estar vazio
                   pode iniciar a leitura assincrona */
                LT_resp = 0.       
                RUN WinStartLeAssincronoCodBarLcbCh IN aux_xfsliteh (INPUT 15, /* timeout 15s */
                                                                     INPUT 0,  /* tamanho variavel */
                                                                     OUTPUT LT_Resp).
            
                /* OK */
                IF  LT_Resp = 1  THEN
                    chtemporizador_cod_barras:t_cod_barras:INTERVAL = 1000 . 

            END.

        /*se for o ultimo caracter deve pular para o proximo campo*/
        IF  ed_tpcptdoc:SCREEN-VALUE = "2" AND 
           ((ed_idtpdpag:SCREEN-VALUE = "2" AND LENGTH(ed_dscodbar:SCREEN-VALUE) >= 54) OR 
            (ed_idtpdpag:SCREEN-VALUE = "1" AND LENGTH(ed_dscodbar:SCREEN-VALUE) >= 55)
           ) THEN
        DO:
          APPLY "LEAVE" TO ed_dscodbar. 
        END.
    END.
    
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_dscodbar w_cartao_pagamento
ON ENTRY OF ed_dscodbar IN FRAME f_cartao_pagamento
DO:
  
    /* durante a criação do frame chama o ENTRY, desconsiderar */
    IF  FRAME-NAME <> "f_cartao_pagamento"  THEN
        RETURN.
    
    ed_mensagem:SCREEN-VALUE = "Posicione o código de barras no feixe de luz " + CHR(13) +
                                "ou Informe a linha digitável...".

    /* desativa o temporizador de tela */
    chtemporizador:t_cartao_pagamento:INTERVAL = 0.
    
    IF TRIM(REPLACE(REPLACE(ed_dscodbar:SCREEN-VALUE,".",""),"-","")) = "" THEN
    DO:
        ASSIGN ed_dscodbar:FORMAT = "x(44)"
               ed_dscodbar:SCREEN-VALUE = ""
               aux_sfcodbar = "".

    END.

    /* inicia a leitura assincrona */
    LT_resp = 0.       
           
    RUN WinStartLeAssincronoCodBarLcbCh IN aux_xfsliteh (INPUT 15, /* timeout 15s */
                                                         INPUT 0,  /* tamanho variavel */
                                                         OUTPUT LT_Resp).

    /* OK */
    IF  LT_Resp = 1  THEN
        chtemporizador_cod_barras:t_cod_barras:INTERVAL = 1000 .   
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_dscodbar w_cartao_pagamento
ON LEAVE OF ed_dscodbar IN FRAME f_cartao_pagamento
DO:     

    IF  NOT par_flagenda  THEN
        DO:
            ed_datpagto:SCREEN-VALUE = STRING(glb_dtmvtocd, "99/99/9999").
            ed_datpagto:READ-ONLY    = YES.
            ed_datpagto:BGCOLOR      = 8.
        END.

    ASSIGN aux_sfcodbar = REPLACE(REPLACE(REPLACE(ed_dscodbar:SCREEN-VALUE,".",""),"-","")," ","").

    /* se estiver saindo do campo e o mesmo estiver nulo, deve retirar a mascara*/
    IF  TRIM(aux_sfcodbar) = "" THEN
    DO:
        ed_dscodbar:FORMAT = "x(44)".
    END.

    /* validar o codigo de barras/linha digitavel*/
    RUN valida_codbar.

    IF aux_flgderro THEN
        RETURN NO-APPLY.

    /* Extrair valor do titulo/fatura */
    RUN extrai_valor_codbar.   
    IF aux_flgderro THEN
        RETURN NO-APPLY.

    /* se for titulo sempre vai para o campo de valor*/
    IF  ed_idtpdpag:SCREEN-VALUE = "2" AND 
        /* E o campo não estiver bloqueado */
        aux_flblqval <> 1 THEN
        DO:      
            APPLY "ENTRY" TO ed_vldpagto.
        END.        
        
    ELSE 
    IF  par_flagenda                       THEN
        APPLY "ENTRY" TO ed_datpagto.         
    ELSE /* nao permite alterar o valor em caso de fatura */
    IF  DEC(ed_vldpagto:SCREEN-VALUE) > 0  THEN
        APPLY "ENTRY" TO Btn_D.
    ELSE 
        APPLY "ENTRY" TO ed_vldpagto.
                           
        
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_nmbenefi
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nmbenefi w_cartao_pagamento
ON ANY-KEY OF ed_nmbenefi IN FRAME f_cartao_pagamento
DO:
    IF  KEY-FUNCTION(LASTKEY) = "D" THEN
        RETURN NO-APPLY.
    IF KEY-FUNCTION(LASTKEY) = "C" THEN
        APPLY "CHOOSE" TO Btn_C.
    ELSE 
    DO:
        RUN tecla.
        
        /* Se for o primeiro digito, verificar qual o formato a ser utilizado*/
        IF TRIM(ed_dscodbar:SCREEN-VALUE) = "" THEN
            DO:
                
                /* Se o campo estava em branco e é digitado a primeira tecla
                   deve cancelar a leitora */
                IF CAN-DO("0,1,2,3,4,5,6,7,8,9,RETURN",KEY-FUNCTION(LASTKEY)) THEN
                  DO: 
                    /* desativa o temporizador do cod de barras */
                    chtemporizador_cod_barras:t_cod_barras:INTERVAL = 0. 

                    RUN WinCancelaLeituraCodBarLcbCh IN aux_xfsliteh (OUTPUT LT_Resp). 
                  END. 

                /*Se a tecla for 8 é convenio*/
                IF KEY-FUNCTION(LASTKEY) = "8" THEN
                  DO:
    
                    ed_dscodbar:FORMAT = "99999999999-9 99999999999-9 99999999999-9 99999999999-9".
                    ASSIGN ed_tpcptdoc:SCREEN-VALUE = "2"  /* LINHA DIGITAVEL */
                           ed_idtpdpag:SCREEN-VALUE = "1". /*FATURA*/
    
    
                  END.
                ELSE  /*se for numeros menos o 8 é titulo*/
                  IF CAN-DO("0,1,2,3,4,5,6,7,9,RETURN",KEY-FUNCTION(LASTKEY)) THEN
                    DO:
    
                      ed_dscodbar:FORMAT = "99999.99999 99999.999999 99999.999999 9 99999999999999".
                      ASSIGN ed_tpcptdoc:SCREEN-VALUE = "2" /* LINHA DIGITAVEL */
                             ed_idtpdpag:SCREEN-VALUE = "2". /*TITULO*/
        
                    END.
                  ELSE 
                    RETURN NO-APPLY.
            END.
        ELSE
        DO:
            IF ed_tpcptdoc:SCREEN-VALUE = "2"   AND  
               ed_idtpdpag:SCREEN-VALUE = "2"   AND 
               KEY-FUNCTION(LASTKEY) = "RETURN" THEN
            DO:
                APPLY "LEAVE" TO ed_dscodbar.
            END.                             
        END.


        APPLY KEY-FUNCTION(LASTKEY).

        IF TRIM(REPLACE(REPLACE(ed_dscodbar:SCREEN-VALUE,".",""),"-","")) = "" THEN
            DO:
                ASSIGN ed_dscodbar:FORMAT = "x(44)"
                       ed_dscodbar:SCREEN-VALUE = ""
                       aux_sfcodbar = "".

                /* se o campo voltou a estar vazio
                   pode iniciar a leitura assincrona */
                LT_resp = 0.       
                RUN WinStartLeAssincronoCodBarLcbCh IN aux_xfsliteh (INPUT 15, /* timeout 15s */
                                                                     INPUT 0,  /* tamanho variavel */
                                                                     OUTPUT LT_Resp).
            
                /* OK */
                IF  LT_Resp = 1  THEN
                    chtemporizador_cod_barras:t_cod_barras:INTERVAL = 1000 . 

            END.

        /*se for o ultimo caracter deve pular para o proximo campo*/
        IF  ed_tpcptdoc:SCREEN-VALUE = "2" AND 
           ((ed_idtpdpag:SCREEN-VALUE = "2" AND LENGTH(ed_dscodbar:SCREEN-VALUE) >= 54) OR 
            (ed_idtpdpag:SCREEN-VALUE = "1" AND LENGTH(ed_dscodbar:SCREEN-VALUE) >= 55)
           ) THEN
        DO:
          APPLY "LEAVE" TO ed_dscodbar. 
        END.
    END.
    
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nmbenefi w_cartao_pagamento
ON ENTRY OF ed_nmbenefi IN FRAME f_cartao_pagamento
DO:
    
    /* durante a criação do frame chama o ENTRY, desconsiderar */
    IF  FRAME-NAME <> "f_cartao_pagamento"  THEN
        RETURN.
    
    ed_mensagem:SCREEN-VALUE = "Posicione o código de barras no feixe de luz " + CHR(13) +
                                "ou Informe a linha digitável...".

    /* desativa o temporizador de tela */
    chtemporizador:t_cartao_pagamento:INTERVAL = 0.
    
    IF TRIM(REPLACE(REPLACE(ed_dscodbar:SCREEN-VALUE,".",""),"-","")) = "" THEN
    DO:
        ASSIGN ed_dscodbar:FORMAT = "x(44)"
               ed_dscodbar:SCREEN-VALUE = ""
               aux_sfcodbar = "".

    END.

    /* inicia a leitura assincrona */
    LT_resp = 0.       
           
    RUN WinStartLeAssincronoCodBarLcbCh IN aux_xfsliteh (INPUT 15, /* timeout 15s */
                                                         INPUT 0,  /* tamanho variavel */
                                                         OUTPUT LT_Resp).

    /* OK */
    IF  LT_Resp = 1  THEN
        chtemporizador_cod_barras:t_cod_barras:INTERVAL = 1000 .   
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nmbenefi w_cartao_pagamento
ON LEAVE OF ed_nmbenefi IN FRAME f_cartao_pagamento
DO:     

    IF  NOT par_flagenda  THEN
        DO:
            ed_datpagto:SCREEN-VALUE = STRING(glb_dtmvtocd, "99/99/9999").
            ed_datpagto:READ-ONLY    = YES.
            ed_datpagto:BGCOLOR      = 8.
        END.

    ASSIGN aux_sfcodbar = REPLACE(REPLACE(REPLACE(ed_dscodbar:SCREEN-VALUE,".",""),"-","")," ","").

    /* se estiver saindo do campo e o mesmo estiver nulo, deve retirar a mascara*/
    IF  TRIM(aux_sfcodbar) = "" THEN
    DO:
        ed_dscodbar:FORMAT = "x(44)".
    END.

    /* validar o codigo de barras/linha digitavel*/
    RUN valida_codbar.

    IF aux_flgderro THEN
        RETURN NO-APPLY.

    /* Extrair valor do titulo/fatura */
    RUN extrai_valor_codbar.   
    IF aux_flgderro THEN
        RETURN NO-APPLY.

    /* se for titulo sempre vai para o campo de valor*/
    IF  ed_idtpdpag:SCREEN-VALUE = "2"    THEN
        DO:      
            APPLY "ENTRY" TO ed_vldpagto.
        END.        
        
    ELSE 
    IF  par_flagenda                       THEN
        APPLY "ENTRY" TO ed_datpagto.         
    ELSE /* nao permite alterar o valor em caso de fatura */
    IF  DEC(ed_vldpagto:SCREEN-VALUE) > 0  THEN
        APPLY "ENTRY" TO Btn_D.
    ELSE 
        APPLY "ENTRY" TO ed_vldpagto.
                           
        
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_vldpagto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_vldpagto w_cartao_pagamento
ON ANY-KEY OF ed_vldpagto IN FRAME f_cartao_pagamento
DO:
    IF  par_flagenda THEN
        IF  KEY-FUNCTION(LASTKEY) = "D" THEN
            RETURN NO-APPLY.
        ELSE
            RUN tecla.
    ELSE
        RUN tecla.

    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            IF  par_flagenda THEN
                DO:
                    APPLY "ENTRY" TO ed_datpagto.
                    RETURN NO-APPLY.
                END.
            ELSE
                DO:
                    APPLY "ENTRY" TO Btn_D.
                    RETURN NO-APPLY.
                END.

        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        ed_vldpagto:SCREEN-VALUE = "".

    
    /* se nao digitou numeros, despreza */
    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))   OR
        LENGTH(ed_vldpagto:SCREEN-VALUE) >= 10                    THEN
        RETURN NO-APPLY.
    ELSE
        DO:
            /* controle para permitir centavos */
            ed_vldpagto:SCREEN-VALUE = STRING(DECIMAL(ed_vldpagto:SCREEN-VALUE +
                                              KEY-FUNCTION(LASTKEY)) * 10).

            RETURN NO-APPLY.
        END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_vldpagto w_cartao_pagamento
ON ENTRY OF ed_vldpagto IN FRAME f_cartao_pagamento
DO:
    ed_mensagem:SCREEN-VALUE = "Informe o valor do " +  
                                IF ed_idtpdpag:SCREEN-VALUE = "1" THEN "convênio"
                                ELSE "título".
                                  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Label_nmbenefi
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Label_nmbenefi w_cartao_pagamento
ON ANY-KEY OF Label_nmbenefi IN FRAME f_cartao_pagamento
DO:
    IF  KEY-FUNCTION(LASTKEY) = "D" THEN
        RETURN NO-APPLY.
    IF KEY-FUNCTION(LASTKEY) = "C" THEN
        APPLY "CHOOSE" TO Btn_C.
    ELSE 
    DO:
        RUN tecla.
        
        /* Se for o primeiro digito, verificar qual o formato a ser utilizado*/
        IF TRIM(ed_dscodbar:SCREEN-VALUE) = "" THEN
            DO:
                
                /* Se o campo estava em branco e é digitado a primeira tecla
                   deve cancelar a leitora */
                IF CAN-DO("0,1,2,3,4,5,6,7,8,9,RETURN",KEY-FUNCTION(LASTKEY)) THEN
                  DO: 
                    /* desativa o temporizador do cod de barras */
                    chtemporizador_cod_barras:t_cod_barras:INTERVAL = 0. 

                    RUN WinCancelaLeituraCodBarLcbCh IN aux_xfsliteh (OUTPUT LT_Resp). 
                  END. 

                /*Se a tecla for 8 é convenio*/
                IF KEY-FUNCTION(LASTKEY) = "8" THEN
                  DO:
    
                    ed_dscodbar:FORMAT = "99999999999-9 99999999999-9 99999999999-9 99999999999-9".
                    ASSIGN ed_tpcptdoc:SCREEN-VALUE = "2"  /* LINHA DIGITAVEL */
                           ed_idtpdpag:SCREEN-VALUE = "1". /*FATURA*/
    
    
                  END.
                ELSE  /*se for numeros menos o 8 é titulo*/
                  IF CAN-DO("0,1,2,3,4,5,6,7,9,RETURN",KEY-FUNCTION(LASTKEY)) THEN
                    DO:
    
                      ed_dscodbar:FORMAT = "99999.99999 99999.999999 99999.999999 9 99999999999999".
                      ASSIGN ed_tpcptdoc:SCREEN-VALUE = "2" /* LINHA DIGITAVEL */
                             ed_idtpdpag:SCREEN-VALUE = "2". /*TITULO*/
        
                    END.
                  ELSE 
                    RETURN NO-APPLY.
            END.
        ELSE
        DO:
            IF ed_tpcptdoc:SCREEN-VALUE = "2"   AND  
               ed_idtpdpag:SCREEN-VALUE = "2"   AND 
               KEY-FUNCTION(LASTKEY) = "RETURN" THEN
            DO:
                APPLY "LEAVE" TO ed_dscodbar.
            END.                             
        END.


        APPLY KEY-FUNCTION(LASTKEY).

        IF TRIM(REPLACE(REPLACE(ed_dscodbar:SCREEN-VALUE,".",""),"-","")) = "" THEN
            DO:
                ASSIGN ed_dscodbar:FORMAT = "x(44)"
                       ed_dscodbar:SCREEN-VALUE = ""
                       aux_sfcodbar = "".

                /* se o campo voltou a estar vazio
                   pode iniciar a leitura assincrona */
                LT_resp = 0.       
                RUN WinStartLeAssincronoCodBarLcbCh IN aux_xfsliteh (INPUT 15, /* timeout 15s */
                                                                     INPUT 0,  /* tamanho variavel */
                                                                     OUTPUT LT_Resp).
            
                /* OK */
                IF  LT_Resp = 1  THEN
                    chtemporizador_cod_barras:t_cod_barras:INTERVAL = 1000 . 

            END.

        /*se for o ultimo caracter deve pular para o proximo campo*/
        IF  ed_tpcptdoc:SCREEN-VALUE = "2" AND 
           ((ed_idtpdpag:SCREEN-VALUE = "2" AND LENGTH(ed_dscodbar:SCREEN-VALUE) >= 54) OR 
            (ed_idtpdpag:SCREEN-VALUE = "1" AND LENGTH(ed_dscodbar:SCREEN-VALUE) >= 55)
           ) THEN
        DO:
          APPLY "LEAVE" TO ed_dscodbar. 
        END.
    END.
    
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Label_nmbenefi w_cartao_pagamento
ON ENTRY OF Label_nmbenefi IN FRAME f_cartao_pagamento
DO:
    
    /* durante a criação do frame chama o ENTRY, desconsiderar */
    IF  FRAME-NAME <> "f_cartao_pagamento"  THEN
        RETURN.
    
    ed_mensagem:SCREEN-VALUE = "Posicione o código de barras no feixe de luz " + CHR(13) +
                                "ou Informe a linha digitável...".

    /* desativa o temporizador de tela */
    chtemporizador:t_cartao_pagamento:INTERVAL = 0.
    
    IF TRIM(REPLACE(REPLACE(ed_dscodbar:SCREEN-VALUE,".",""),"-","")) = "" THEN
    DO:
        ASSIGN ed_dscodbar:FORMAT = "x(44)"
               ed_dscodbar:SCREEN-VALUE = ""
               aux_sfcodbar = "".

    END.

    /* inicia a leitura assincrona */
    LT_resp = 0.       
           
    RUN WinStartLeAssincronoCodBarLcbCh IN aux_xfsliteh (INPUT 15, /* timeout 15s */
                                                         INPUT 0,  /* tamanho variavel */
                                                         OUTPUT LT_Resp).

    /* OK */
    IF  LT_Resp = 1  THEN
        chtemporizador_cod_barras:t_cod_barras:INTERVAL = 1000 .   
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Label_nmbenefi w_cartao_pagamento
ON LEAVE OF Label_nmbenefi IN FRAME f_cartao_pagamento
DO:     

    IF  NOT par_flagenda  THEN
        DO:
            ed_datpagto:SCREEN-VALUE = STRING(glb_dtmvtocd, "99/99/9999").
            ed_datpagto:READ-ONLY    = YES.
            ed_datpagto:BGCOLOR      = 8.
        END.

    ASSIGN aux_sfcodbar = REPLACE(REPLACE(REPLACE(ed_dscodbar:SCREEN-VALUE,".",""),"-","")," ","").

    /* se estiver saindo do campo e o mesmo estiver nulo, deve retirar a mascara*/
    IF  TRIM(aux_sfcodbar) = "" THEN
    DO:
        ed_dscodbar:FORMAT = "x(44)".
    END.

    /* validar o codigo de barras/linha digitavel*/
    RUN valida_codbar.

    IF aux_flgderro THEN
        RETURN NO-APPLY.

    /* Extrair valor do titulo/fatura */
    RUN extrai_valor_codbar.   
    IF aux_flgderro THEN
        RETURN NO-APPLY.

    /* se for titulo sempre vai para o campo de valor*/
    IF  ed_idtpdpag:SCREEN-VALUE = "2"    THEN
        DO:      
            APPLY "ENTRY" TO ed_vldpagto.
        END.        
        
    ELSE 
    IF  par_flagenda                       THEN
        APPLY "ENTRY" TO ed_datpagto.         
    ELSE /* nao permite alterar o valor em caso de fatura */
    IF  DEC(ed_vldpagto:SCREEN-VALUE) > 0  THEN
        APPLY "ENTRY" TO Btn_D.
    ELSE 
        APPLY "ENTRY" TO ed_vldpagto.
                           
        
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_cartao_pagamento OCX.Tick
PROCEDURE temporizador.t_cartao_pagamento.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_cartao_pagamento.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador_cod_barras
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador_cod_barras w_cartao_pagamento OCX.Tick
PROCEDURE temporizador_cod_barras.t_cod_barras.Tick .
DEFINE VARIABLE buf_cddbarra     AS MEMPTR   NO-UNDO.
                
    SET-SIZE(buf_cddbarra) = 44.
    
    LT_resp = 0.       
           
    RUN WinLeAssincronoCodBarLcbCh IN aux_xfsliteh (INPUT GET-POINTER-VALUE(buf_cddbarra),
                                                    OUTPUT LT_Resp).
    

    /* 1 - leitura com sucesso */
    IF  LT_Resp = 1 THEN
        DO:
            IF  GET-STRING(buf_cddbarra,1) <> "" THEN
                DO:
                   /* desativa o temporizador do cod de barras */
                    chtemporizador_cod_barras:t_cod_barras:INTERVAL = 0.
        
                    /* ativa o temporizador de tela */
                    chtemporizador:t_cartao_pagamento:INTERVAL = glb_nrtempor.
        
                    /* Alterar mascara para mascara de codbarras e marcar indicador de leitora */
                    ed_dscodbar:FORMAT IN FRAME f_cartao_pagamento = "x(44)".
                    ed_tpcptdoc:SCREEN-VALUE IN FRAME f_cartao_pagamento = "1".
                    ed_dscodbar:SCREEN-VALUE IN FRAME f_cartao_pagamento = "".
        
                    /* atribuir valor*/
                    ed_dscodbar:SCREEN-VALUE IN FRAME f_cartao_pagamento = GET-STRING(buf_cddbarra,1).
        
                    /*guardar tipo de documento*/
                    IF SUBSTR(ed_dscodbar:SCREEN-VALUE,1,1) = "8"  THEN /* FATURA */
                        ed_idtpdpag:SCREEN-VALUE IN FRAME f_cartao_pagamento = "1".
                    ELSE /* TITULO */
                        ed_idtpdpag:SCREEN-VALUE IN FRAME f_cartao_pagamento = "2".
        
                    APPLY "LEAVE" TO ed_dscodbar.
                END.
        END.
    ELSE 
        DO:
            /*Se for timeout da operacao de leitura ou
              o leitor ja estiver cancelado*/
            IF LT_Resp = 11 OR LT_Resp = 17 THEN
                DO:
                    /* reiniciar a leitora */
                    RUN WinStartLeAssincronoCodBarLcbCh IN aux_xfsliteh (INPUT 15, /* timeout 15s */
                                                                         INPUT 0,  /* tamanho variavel */
                                                                         OUTPUT LT_Resp).
                   
                END.
            ELSE
                DO:
                    /* 12 - operacao em andamento */
                    IF  LT_Resp <> 12   THEN
                        DO: 

                            /* cancela a leitora */
                            RUN WinCancelaLeituraCodBarLcbCh IN aux_xfsliteh (OUTPUT LT_Resp).
                
                            /* desativa o temporizador do cod de barras */
                            chtemporizador_cod_barras:t_cod_barras:INTERVAL = 0.
                
                            /* ativa o temporizador de tela */
                            chtemporizador:t_cartao_pagamento:INTERVAL = glb_nrtempor.
                            APPLY "CHOOSE" TO Btn_C IN FRAME f_cartao_pagamento.

                        END.
                END.
        END.

    
    SET-SIZE(buf_cddbarra) = 0.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_cartao_pagamento 


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
    FRAME f_cartao_pagamento:LOAD-MOUSE-POINTER("blank.cur").

    ASSIGN chtemporizador:t_cartao_pagamento:INTERVAL = glb_nrtempor

           /* Dados do associado */
           ed_cdagectl = glb_cdagectl
           ed_nmrescop = " - " + glb_nmrescop
           ed_nrdconta = glb_nrdconta
           ed_nmextttl = glb_nmtitula[1].

    DISPLAY ed_cdagectl  ed_nmrescop
            ed_nrdconta  ed_nmextttl
            WITH FRAME f_cartao_pagamento.

    RUN habilita_campos.

    IF  NOT par_flagenda THEN
        ed_datpagto:READ-ONLY.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calcula_valor_titulo w_cartao_pagamento 
PROCEDURE calcula_valor_titulo :
/*------------------------------------------------------------------------------
  Purpose: Retornar o valor de titulos contendo juros/multas    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEF INPUT  PARAM pr_cdcooper        AS INTE         NO-UNDO.
DEF INPUT  PARAM pr_nrdconta        AS INTE         NO-UNDO.
DEF INPUT  PARAM pr_idseqttl        AS INTE         NO-UNDO.
DEF INPUT  PARAM pr_cdagenci        AS INTE         NO-UNDO.
DEF INPUT  PARAM pr_nrdcaixa        AS INTE         NO-UNDO.
        
DEF INPUT  PARAM pr_titulo1         AS DECI         NO-UNDO.
DEF INPUT  PARAM pr_titulo2         AS DECI         NO-UNDO.
DEF INPUT  PARAM pr_titulo3         AS DECI         NO-UNDO.
DEF INPUT  PARAM pr_titulo4         AS DECI         NO-UNDO.
DEF INPUT  PARAM pr_titulo5         AS DECI         NO-UNDO.
DEF INPUT  PARAM pr_codigo_barras   AS CHAR         NO-UNDO.
DEF OUTPUT  PARAM pr_vlfatura       AS DECI         NO-UNDO.
DEF OUTPUT  PARAM pr_vlrjuros       AS DECI         NO-UNDO.
DEF OUTPUT  PARAM pr_vlrmulta       AS DECI         NO-UNDO.
DEF OUTPUT  PARAM pr_fltitven       AS INTE         NO-UNDO.
DEF OUTPUT  PARAM pr_inpesbnf       AS INTE         NO-UNDO.
DEF OUTPUT  PARAM pr_nrdocbnf       AS DECI         NO-UNDO. 
DEF OUTPUT  PARAM pr_nmbenefi       AS CHAR         NO-UNDO. 
DEF OUTPUT  PARAM pr_nrctlnpc       AS CHAR         NO-UNDO.
DEF OUTPUT  PARAM pr_des_erro       AS CHAR         NO-UNDO.
DEF OUTPUT  PARAM pr_dscritic       AS CHAR         NO-UNDO.


DO  WITH FRAME f_cartao_pagamento:
    RUN procedures/calcula_valor_titulo.p (INPUT pr_cdcooper,
                                                   INPUT pr_nrdconta, 
                                                   INPUT pr_idseqttl,
                                                   INPUT pr_cdagenci,
                                                   INPUT pr_nrdcaixa,
                                                   INPUT pr_titulo1,
                                                   INPUT pr_titulo2,
                                                   INPUT pr_titulo3,
                                                   INPUT pr_titulo4,
                                                   INPUT pr_titulo5,
                                                   INPUT pr_codigo_barras,
                                                  OUTPUT pr_vlfatura,
                                                  OUTPUT pr_vlrjuros,
                                                  OUTPUT pr_vlrmulta,
                                                  OUTPUT pr_fltitven,
                                                  OUTPUT aux_flblqval,
                                                  OUTPUT pr_inpesbnf,
                                                  OUTPUT pr_nrdocbnf,
                                                  OUTPUT pr_nmbenefi,
                                                  OUTPUT pr_nrctlnpc,                                      
                                                  OUTPUT pr_des_erro,
                                                  OUTPUT pr_dscritic).
     
    IF pr_dscritic <> ""  THEN
    DO:
         APPLY "CHOOSE" TO Btn_C.         
         ASSIGN aux_flgderro = TRUE.
         RETURN NO-APPLY.
    END.

    IF aux_flblqval = 1 THEN
    DO:

        ed_vldpagto:READ-ONLY    = YES.
        ed_vldpagto:BGCOLOR      = 8.
    END.

    chtemporizador:t_cartao_pagamento:INTERVAL = glb_nrtempor.

   
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_cartao_pagamento  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_pagamento.wrx":U ).
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
ELSE MESSAGE "cartao_pagamento.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_cartao_pagamento  _DEFAULT-DISABLE
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
  HIDE FRAME f_cartao_pagamento.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_cartao_pagamento  _DEFAULT-ENABLE
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
  DISPLAY ed_dscodbar ed_vldpagto ed_datpagto ed_mensagem ed_cdagectl 
          ed_nmrescop ed_nrdconta ed_nmextttl 
      WITH FRAME f_cartao_pagamento.
  ENABLE RECT-132 RECT-133 IMAGE-36 IMAGE-37 IMAGE-40 RECT-134 ed_dscodbar 
         ed_nmbenefi ed_vldpagto ed_datpagto Btn_C ed_mensagem Btn_D Btn_H 
         ed_cdagectl ed_nmrescop ed_nrdconta ed_nmextttl 
      WITH FRAME f_cartao_pagamento.
  {&OPEN-BROWSERS-IN-QUERY-f_cartao_pagamento}
  VIEW w_cartao_pagamento.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE extrai_valor_codbar w_cartao_pagamento 
PROCEDURE extrai_valor_codbar :
/*------------------------------------------------------------------------------
  Purpose: Extrair valor da fatura/titulo do codigo de barras ou linha digitavel     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DO  WITH FRAME f_cartao_pagamento:

        ASSIGN aux_valor    = ""
               aux_flgderro = NO.

        /* Caso nao possua codbar, deve sair da rotina */
        IF aux_sfcodbar = "" THEN
        DO:
            RETURN.
        END.

        /* se o tipo de captura for leitora*/
        IF ed_tpcptdoc:SCREEN-VALUE = "1" THEN  
        DO:
           /* CONVENIO*/
           IF ed_idtpdpag:SCREEN-VALUE = "1" THEN
           DO:
              
              ASSIGN aux_valor = SUBSTR(aux_sfcodbar,5,11).

              /* Validar valor zerado */
              IF DECIMAL(aux_valor) = 0 THEN
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
                aux_flgderro = YES.
               
                RETURN NO-APPLY.
              END.

              /* Pular campo valor pois o mesmo nao sera alterado*/
              ASSIGN aux_flblqval          = 1
                     ed_vldpagto:READ-ONLY = YES
                     ed_vldpagto:BGCOLOR   = 8.

           END. /* Titulos */
           ELSE IF ed_idtpdpag:SCREEN-VALUE = "2"  THEN
           DO:
              RUN calcula_valor_titulo(INPUT glb_cdcooper,
                                               INPUT glb_nrdconta,
                                               INPUT 1,
                                               INPUT 91,
                                               INPUT 0,
                                               INPUT 0,
                                               INPUT 0,
                                               INPUT 0,
                                               INPUT 0,
                                               INPUT 0,
                                               INPUT aux_sfcodbar,
                                              OUTPUT aux_vlfatura,
                                              OUTPUT aux_vlrjuros,
                                              OUTPUT aux_vlrmulta,
                                              OUTPUT aux_fltitven,
                                              OUTPUT aux_inpesbnf,
                                              OUTPUT aux_nrdocbnf,
                                              OUTPUT aux_nmbenefi,
                                              OUTPUT aux_nrctlnpc,
                                              OUTPUT aux_des_erro,
                                              OUTPUT aux_dscritic).
              IF aux_dscritic <> "" THEN
              DO:
                APPLY "ENTRY" TO ed_dscodbar.               
                RETURN NO-APPLY.               
              END.

              ASSIGN aux_valor = STRING(aux_vlfatura,"zz,zzz,z99.99").
          
           END.
        END.
        ELSE /* Se for linha Digitavel*/
            IF ed_tpcptdoc:SCREEN-VALUE = "2" THEN
            DO:
                /* CONVENIO*/
               IF ed_idtpdpag:SCREEN-VALUE = "1" THEN
               DO:                  
                 ASSIGN aux_valor = SUBSTR(aux_sfcodbar,5,7) + SUBSTR(aux_sfcodbar,13,4).
                  
                 IF DECIMAL(aux_valor) = 0 THEN
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
                     aux_flgderro = YES.
                     
                     RETURN NO-APPLY.
                 END.

                 /* Pular campo valor pois o mesmo nao sera alterado*/
                 ASSIGN aux_flblqval          = 1
                        ed_vldpagto:READ-ONLY = YES
                        ed_vldpagto:BGCOLOR   = 8.

               END. /* Titulos */
               ELSE IF ed_idtpdpag:SCREEN-VALUE = "2"  THEN
               DO:                  
                  RUN calcula_valor_titulo ( INPUT glb_cdcooper,
                                                   INPUT glb_nrdconta,
                                                   INPUT 1,
                                                   INPUT 91,
                                                   INPUT 0,
                                                   INPUT DEC(SUBSTR(aux_sfcodbar,1,10)),
                                                   INPUT DEC(SUBSTR(aux_sfcodbar,11,11)),
                                                   INPUT DEC(SUBSTR(aux_sfcodbar,22,11)),
                                                   INPUT DEC(SUBSTR(aux_sfcodbar,33,1)),
                                                   INPUT DEC(SUBSTR(aux_sfcodbar,34,14)),
                                                   INPUT 0,
                                                  OUTPUT aux_vlfatura,
                                                  OUTPUT aux_vlrjuros,
                                                  OUTPUT aux_vlrmulta,
                                                  OUTPUT aux_fltitven,
                                                  OUTPUT aux_inpesbnf,
                                                  OUTPUT aux_nrdocbnf,
                                                  OUTPUT aux_nmbenefi,
                                                  OUTPUT aux_nrctlnpc,
                                                  OUTPUT aux_des_erro,
                                                  OUTPUT aux_dscritic). 
                  
                 
                  IF aux_dscritic <> "" THEN
                  DO:
                    APPLY "ENTRY" TO ed_dscodbar.
                    RETURN NO-APPLY. 
                  END.

                  ASSIGN aux_valor = STRING(aux_vlfatura,"zzz,zzz,z99.99").

               END.
    
            END.
        
       IF aux_nmbenefi <> "" AND aux_nmbenefi <> ? THEN
          DO:
            ASSIGN ed_nmbenefi:SCREEN-VALUE = aux_nmbenefi
                   Label_nmbenefi:SCREEN-VALUE = "Beneficiário:".
            Label_nmbenefi:HIDDEN IN FRAME f_cartao_pagamento = FALSE.
            F_nmbenefi:HIDDEN     IN FRAME f_cartao_pagamento = FALSE.
            ed_nmbenefi:HIDDEN    IN FRAME f_cartao_pagamento = FALSE.
            /*ed_nmbenefi:ENABLED   = TRUE. */
          END.

       IF TRIM(aux_valor) <> ""  THEN
       DO:
         /* verifica se o valor esta correto, caso contrario o documento
           pode ser invalido. tamanho maximo zz.zzz.zz9,99 */
         IF  LENGTH(STRING(DECIMAL(aux_valor) / 100)) > 8  THEN
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
                aux_flgderro = YES.
        
                /*APPLY "CHOOSE" TO Btn_C.*/
                RETURN NO-APPLY.
            END.
         
         /*Se o valor veio do oracle, passa normal*/
         IF aux_vlfatura <> 0  AND
            aux_vlfatura <> ?  THEN
            ASSIGN ed_vldpagto:SCREEN-VALUE = STRING(aux_valor).   
         ELSE
             ASSIGN ed_vldpagto:SCREEN-VALUE = STRING(DECI(aux_valor) / 100).   
       END.
       
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE habilita_campos w_cartao_pagamento 
PROCEDURE habilita_campos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DO  WITH FRAME f_cartao_pagamento:
    
        ASSIGN ed_dscodbar:READ-ONLY    = NO
               ed_dscodbar:BGCOLOR      = ?
               ed_dscodbar:SCREEN-VALUE = ""
               ed_datpagto:SCREEN-VALUE = ""
               ed_vldpagto:SCREEN-VALUE = ""
               ed_mensagem:SCREEN-VALUE = "Posicione o código de barras no feixe de luz " + CHR(13) +
                                          "ou Informe a linha digitável...".
        
        ed_nmbenefi:HIDDEN    IN FRAME f_cartao_pagamento = TRUE.
        Label_nmbenefi:HIDDEN IN FRAME f_cartao_pagamento = TRUE.
        F_nmbenefi:HIDDEN     IN FRAME f_cartao_pagamento = TRUE.
        APPLY "ENTRY" TO ed_dscodbar.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_cartao_pagamento 
PROCEDURE tecla :
chtemporizador:t_cartao_pagamento:INTERVAL = 0.

    IF  KEY-FUNCTION(LASTKEY) = "C"                           AND
        Btn_C:SENSITIVE IN FRAME f_cartao_pagamento  THEN
        APPLY "CHOOSE" TO Btn_C.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "D"                           AND
        Btn_D:SENSITIVE IN FRAME f_cartao_pagamento  THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                           AND
        Btn_H:SENSITIVE IN FRAME f_cartao_pagamento  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
    DO:
        chtemporizador:t_cartao_pagamento:INTERVAL = glb_nrtempor.
        RETURN NO-APPLY.
    END.
        
    chtemporizador:t_cartao_pagamento:INTERVAL = glb_nrtempor.
    
    
    IF  RETURN-VALUE = "OK"  THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.    
            RETURN "OK".
        END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE valida_codbar w_cartao_pagamento 
PROCEDURE valida_codbar :
/*------------------------------------------------------------------------------
  Purpose: Validar tamanho do codigo de barras ou linha digitavel     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DO  WITH FRAME f_cartao_pagamento:
        aux_dscritic = "".
        aux_flgderro = NO.

        IF aux_sfcodbar = "" THEN
          RETURN NO-APPLY.

        /* se o tipo de captura for leitora*/
        IF ed_tpcptdoc:SCREEN-VALUE = "1" THEN  
        DO:
           /*verificar se contem a qtd certa de caracteres*/
            IF LENGTH(ed_dscodbar:SCREEN-VALUE) <> 44 THEN
            DO:
              ASSIGN aux_dscritic = 'Código de barras inválido.'.
            END.
        END.
        ELSE /* Se for linha Digitavel*/
            IF ed_tpcptdoc:SCREEN-VALUE = "2" THEN
            DO:
                  /*TITULO*/
               IF (ed_idtpdpag:SCREEN-VALUE = "2" AND LENGTH(aux_sfcodbar) <> 47) THEN
               DO: 
                  ASSIGN aux_sfcodbar = aux_sfcodbar + FILL("0", (47 - LENGTH(aux_sfcodbar))).     
                  ASSIGN ed_dscodbar:SCREEN-VALUE = aux_sfcodbar.
               END.

                   /* CONVENIO */
               IF (ed_idtpdpag:SCREEN-VALUE = "1" AND LENGTH(aux_sfcodbar) <> 48) THEN
               DO:
                  ASSIGN aux_dscritic = 'Linha digitavel inválida.'.  
               END. 
             END.

        IF aux_dscritic <> "" THEN
        DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "    Atenção!",
                            INPUT "",
                            INPUT aux_dscritic,
                            INPUT "",
                            INPUT "",
                            INPUT "").
                    
            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.
            aux_dscritic = "".   
            aux_flgderro = YES.
        END.

    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

