&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_cartao_pagto_convenio_dados
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_cartao_pagto_convenio_dados 
/* ..............................................................................

Procedure: cartao_pagamento_convenio_dados.w
Objetivo : Tela para exibir os dados do convenio a ser pago
Autor    : Evandro
Data     : Janeiro 2010

Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).
                  29/08/2011 - Incluir mensagem avisando quando o lancamento
                               sera feito na proxima data util (Gabriel)
                               
                  28/03/2012 - Dados de banco e agencia no comprovante de pagto
                               (Guilherme/Fabricio).
                               
                  08/05/2013 - Transferencia intercooperativa (Gabriel)  
                  
                  18/07/2013 - Correção número da agencia da cooperativa (Lucas).           
                  
                  07/11/2013 - Alterado Posto de Atendimento ao Cooperado para
                               Posto de Atendimento "PA". (Jorge)
                                                           
                  15/09/2014 - Alterações referentes ao Projeto Débito 
                               Automático Fácil (Lucas Lunelli - Out/2014)                               
                               
                  05/12/2014 - Correção para não gerar comprovante sem efetivar
                               a operação (Lunelli SD 230613)
                  
                  20/08/2015 - Inclusão do parametro para identificacao do tipo 
                               de captura 1- Codigo de barras 2-Linha digitavel 
                               Melhoria-21 SD278322 (Odirlei-AMcom)
                               
                  20/08/2015 - Adicionado SAC e OUVIDORIA nos comprovantes
                               e visualização de impressão
                               (Lucas Lunelli - Melhoria 83 [SD 279180])

                  24/12/2015 - Adicionado tratamento para contas com assinatura 
                               conjunta. (Reinert)
                               
                  30/05/2016 - Alteraçoes Oferta DEBAUT Sicredi (Lucas Lunelli - [PROJ320])
                  
                  14/06/2016 - #413717 Retirada a verificacao de impressora antes
                               da chamada da visualizacao da impressao (Carlos)

                  08/11/2016 - Alteracoes referentes a melhoria 165 - Lancamentos
                               Futuros. Lenilson (Mouts)
                               
                  03/07/2017 - Inclusao do parameto de controle consulta npc na chamada
                               da rotina efetua_pagamento.p, PRJ340 - NPC (Odirlei-AMcom)  
                               
                  28/08/2017 - #705000 Adicionado o nome do convenio e o codigo de barras
                               ao log (Carlos)
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

DEFINE TEMP-TABLE tt-debaut-consulta NO-UNDO
       FIELD nmempres AS CHAR
       FIELD cdempcon AS INTE
       FIELD cdsegmto AS INTE
       FIELD cdhistor AS INTE
       FIELD cdrefere AS CHAR
       FIELD desmaxdb AS CHAR
       FIELD nrsequen AS INTE
       FIELD inaltera AS CHAR.

EMPTY TEMP-TABLE tt-debaut-consulta.

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAM par_dscodbar     AS CHAR         NO-UNDO.
DEFINE INPUT PARAM par_cdbarra1     AS CHAR         NO-UNDO.
DEFINE INPUT PARAM par_cdbarra2     AS CHAR         NO-UNDO.
DEFINE INPUT PARAM par_cdbarra3     AS CHAR         NO-UNDO.
DEFINE INPUT PARAM par_cdbarra4     AS CHAR         NO-UNDO.
DEFINE INPUT PARAM par_vldpagto     AS DECI         NO-UNDO.
DEFINE INPUT PARAM par_datpagto     AS DATE         NO-UNDO.
DEFINE INPUT PARAM par_flagenda     AS LOGI         NO-UNDO.
DEFINE INPUT PARAM par_idtpdpag     AS INTE         NO-UNDO. /* 1- convenio 2-titulo */
DEFINE INPUT PARAM par_tpcptdoc     AS INTE         NO-UNDO. /* 1- Codigo de barras 2-Linha digitavel*/



/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }

DEFINE VARIABLE aux_flgderro        AS LOGICAL      NO-UNDO.
DEFINE VARIABLE aux_flgdbaut        AS LOGICAL      NO-UNDO.
DEFINE VARIABLE aux_vlsddisp        AS DECIMAL      NO-UNDO.  
DEFINE VARIABLE aux_vllautom        AS DECIMAL      NO-UNDO.  
DEFINE VARIABLE aux_vllaucre        AS DECIMAL      NO-UNDO.  
DEFINE VARIABLE aux_vlsdbloq        AS DECIMAL      NO-UNDO.  
DEFINE VARIABLE aux_vlblqtaa        AS DECIMAL      NO-UNDO.  
DEFINE VARIABLE aux_vlsdblpr        AS DECIMAL      NO-UNDO.  
DEFINE VARIABLE aux_vlsdblfp        AS DECIMAL      NO-UNDO.  
DEFINE VARIABLE aux_vlsdchsl        AS DECIMAL      NO-UNDO.  
DEFINE VARIABLE aux_cdbarras        AS CHARACTER    NO-UNDO.  
DEFINE VARIABLE aux_vllimcre        AS DECIMAL      NO-UNDO.
DEFINE VARIABLE aux_cdempcon        AS INTEGER      NO-UNDO.  
DEFINE VARIABLE aux_cdsegmto        AS INTEGER      NO-UNDO.
DEFINE VARIABLE aux_nmextcon        AS CHARACTER    NO-UNDO.
DEFINE VARIABLE aux_idastcjt        AS INTEGER      NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_cartao_pagto_convenio_dados

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-132 RECT-134 RECT-135 RECT-137 RECT-138 ~
IMAGE-37 IMAGE-40 ed_nmconven ed_dslindig ed_dttransa ed_dtdpagto ~
ed_vldpagto Btn_D Btn_H ed_titpagto ed_cdagectl ed_nmrescop ed_nrdconta ~
ed_nmextttl 
&Scoped-Define DISPLAYED-OBJECTS ed_nmconven ed_dslindig ed_dttransa ~
ed_dtdpagto ed_vldpagto ed_titpagto ed_cdagectl ed_nmrescop ed_nrdconta ~
ed_nmextttl 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_cartao_pagto_convenio_dados AS WIDGET-HANDLE NO-UNDO.

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
     SIZE 16 BY 1.29
     FONT 15 NO-UNDO.

DEFINE VARIABLE ed_dslindig AS CHARACTER FORMAT "x(60)":U 
     VIEW-AS FILL-IN 
     SIZE 106 BY 1.19
     FONT 14 NO-UNDO.

DEFINE VARIABLE ed_dtdpagto AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN 
     SIZE 26 BY 1.19
     FONT 14 NO-UNDO.

DEFINE VARIABLE ed_dttransa AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN 
     SIZE 26 BY 1.19
     FONT 14 NO-UNDO.

DEFINE VARIABLE ed_nmconven AS CHARACTER FORMAT "x(40)":U 
     VIEW-AS FILL-IN 
     SIZE 94 BY 1.19
     FONT 14 NO-UNDO.

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

DEFINE VARIABLE ed_titpagto AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 95 BY 3.33
     FGCOLOR 1 FONT 10 NO-UNDO.

DEFINE VARIABLE ed_vldpagto AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 23 BY 1.19
     FONT 14 NO-UNDO.

DEFINE IMAGE IMAGE-37
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE-40
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE RECTANGLE RECT-100
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 2 .

DEFINE RECTANGLE RECT-132
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 96 BY 1.67.

DEFINE RECTANGLE RECT-134
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 108 BY 1.67.

DEFINE RECTANGLE RECT-135
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 28 BY 1.67.

DEFINE RECTANGLE RECT-137
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 25 BY 1.67.

DEFINE RECTANGLE RECT-138
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 28 BY 1.67.

DEFINE RECTANGLE RECT-98
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-99
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-148
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 100 BY 4.38.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_cartao_pagto_convenio_dados
     ed_nmconven AT ROW 10.05 COL 45 COLON-ALIGNED NO-LABEL WIDGET-ID 194 NO-TAB-STOP 
     ed_dslindig AT ROW 11.95 COL 45 COLON-ALIGNED NO-LABEL WIDGET-ID 148 NO-TAB-STOP 
     ed_dttransa AT ROW 13.86 COL 45 COLON-ALIGNED NO-LABEL WIDGET-ID 150 NO-TAB-STOP 
     ed_dtdpagto AT ROW 15.71 COL 45 COLON-ALIGNED NO-LABEL WIDGET-ID 174 NO-TAB-STOP 
     ed_vldpagto AT ROW 17.67 COL 45 COLON-ALIGNED NO-LABEL WIDGET-ID 162 NO-TAB-STOP 
     Btn_D AT ROW 24.14 COL 6 WIDGET-ID 66
     Btn_H AT ROW 24.14 COL 94.4 WIDGET-ID 74
     ed_titpagto AT ROW 1.48 COL 31.6 COLON-ALIGNED NO-LABEL WIDGET-ID 222
     ed_cdagectl AT ROW 6 COL 46 COLON-ALIGNED NO-LABEL WIDGET-ID 238 NO-TAB-STOP 
     ed_nmrescop AT ROW 6 COL 62 COLON-ALIGNED NO-LABEL WIDGET-ID 242 NO-TAB-STOP 
     ed_nrdconta AT ROW 7.38 COL 46 COLON-ALIGNED NO-LABEL WIDGET-ID 244 NO-TAB-STOP 
     ed_nmextttl AT ROW 7.38 COL 72 COLON-ALIGNED NO-LABEL WIDGET-ID 240 NO-TAB-STOP 
     "Convênio:" VIEW-AS TEXT
          SIZE 18 BY .95 AT ROW 10.29 COL 28 WIDGET-ID 184
          FONT 14
     "Conta/Titular:" VIEW-AS TEXT
          SIZE 29 BY 1.19 AT ROW 7.38 COL 17 WIDGET-ID 140
          FONT 8
     "Data da Transação:" VIEW-AS TEXT
          SIZE 33 BY .95 AT ROW 14.14 COL 13 WIDGET-ID 188
          FONT 14
     "Linha Digitável:" VIEW-AS TEXT
          SIZE 26 BY .95 AT ROW 12.19 COL 20 WIDGET-ID 156
          FONT 14
     "Valor do Pagamento:" VIEW-AS TEXT
          SIZE 36 BY .95 AT ROW 17.95 COL 10 WIDGET-ID 192
          FONT 14
     "Cooperativa:" VIEW-AS TEXT
          SIZE 28 BY 1.19 AT ROW 6 COL 18.6 WIDGET-ID 134
          FONT 8
     "Data do Pagamento:" VIEW-AS TEXT
          SIZE 34 BY .95 AT ROW 16 COL 11.6 WIDGET-ID 190
          FONT 14
     RECT-132 AT ROW 9.81 COL 46 WIDGET-ID 198
     RECT-134 AT ROW 11.71 COL 46 WIDGET-ID 152
     RECT-135 AT ROW 13.62 COL 46 WIDGET-ID 154
     RECT-137 AT ROW 17.38 COL 46 WIDGET-ID 166
     RECT-138 AT ROW 15.52 COL 46 WIDGET-ID 176
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     IMAGE-37 AT ROW 24.29 COL 1 WIDGET-ID 218
     IMAGE-40 AT ROW 24.29 COL 156 WIDGET-ID 220
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 160 BY 28.52 WIDGET-ID 100.

DEFINE FRAME f_mensagem_agen
     "dependerá da existencia de saldo na sua" VIEW-AS TEXT
          SIZE 88.6 BY 1.14 AT ROW 2.71 COL 6.2 WIDGET-ID 222
          FGCOLOR 1 FONT 8
     "conta corrente na data escolhida para débito." VIEW-AS TEXT
          SIZE 96 BY 1.14 AT ROW 3.95 COL 3 WIDGET-ID 200
          FGCOLOR 1 FONT 8
     "A quitação efetiva deste agendamento" VIEW-AS TEXT
          SIZE 82.6 BY 1.33 AT ROW 1.33 COL 9 WIDGET-ID 196
          FGCOLOR 1 FONT 8
     RECT-148 AT ROW 1 COL 1 WIDGET-ID 224
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 35 ROW 19.33
         SIZE 101 BY 4.52 WIDGET-ID 200.


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
  CREATE WINDOW w_cartao_pagto_convenio_dados ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.52
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
ASSIGN w_cartao_pagto_convenio_dados = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_cartao_pagto_convenio_dados
  VISIBLE,,RUN-PERSISTENT                                               */
/* REPARENT FRAME */
ASSIGN FRAME f_mensagem_agen:FRAME = FRAME f_cartao_pagto_convenio_dados:HANDLE.

/* SETTINGS FOR FRAME f_cartao_pagto_convenio_dados
   FRAME-NAME                                                           */
ASSIGN 
       ed_titpagto:READ-ONLY IN FRAME f_cartao_pagto_convenio_dados        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_cartao_pagto_convenio_dados
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_cartao_pagto_convenio_dados
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_cartao_pagto_convenio_dados
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME f_mensagem_agen
   NOT-VISIBLE                                                          */
ASSIGN 
       FRAME f_mensagem_agen:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_cartao_pagto_convenio_dados:HANDLE
       ROW             = 1.71
       COLUMN          = 6
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_pagto_convenio_dados */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_cartao_pagto_convenio_dados
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_pagto_convenio_dados w_cartao_pagto_convenio_dados
ON END-ERROR OF w_cartao_pagto_convenio_dados
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_pagto_convenio_dados w_cartao_pagto_convenio_dados
ON WINDOW-CLOSE OF w_cartao_pagto_convenio_dados
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_pagto_convenio_dados
ON ANY-KEY OF Btn_D IN FRAME f_cartao_pagto_convenio_dados /* CONFIRMAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_pagto_convenio_dados
ON CHOOSE OF Btn_D IN FRAME f_cartao_pagto_convenio_dados /* CONFIRMAR */
DO:
    DEFINE VARIABLE aux_dsprotoc    AS CHAR         NO-UNDO.
    DEFINE VARIABLE aux_cdbcoctl    AS CHAR         NO-UNDO.
    DEFINE VARIABLE aux_cdagectl    AS CHAR         NO-UNDO.

    /* ---------- */
    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).
    
    IF  aux_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.

    IF  NOT par_flagenda THEN
        DO:
            /* verifica o saldo - nao logar */
            RUN procedures/obtem_saldo_limite.p ( INPUT 0,
                                                 OUTPUT aux_vlsddisp,
                                                 OUTPUT aux_vllautom,
                                                 OUTPUT aux_vllaucre,
                                                 OUTPUT aux_vlsdbloq,
                                                 OUTPUT aux_vlblqtaa,
                                                 OUTPUT aux_vlsdblpr,
                                                 OUTPUT aux_vlsdblfp,
                                                 OUTPUT aux_vlsdchsl,
                                                 OUTPUT aux_vllimcre,
                                                 OUTPUT aux_idastcjt,
                                                 OUTPUT aux_flgderro).
            
            /* Operacao nao eh em conjunto */
            IF  aux_idastcjt = 0 THEN
                DO:            
                  IF  aux_flgderro   OR
                      par_vldpagto > (aux_vlsddisp + aux_vllimcre)  THEN
                      DO:
                          RUN mensagem.w (INPUT YES,
                                          INPUT "    ATENÇÃO",
                                          INPUT "",
                                          INPUT "",
                                          INPUT "Não há saldo suficiente",
                                          INPUT "para a operação",
                                          INPUT "").
                  
                          PAUSE 4 NO-MESSAGE.
                          h_mensagem:HIDDEN = YES.
                  
                          APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                          RETURN "NOK".
                      END.
                END.
        END.   

    /* para quem nao tem letras, pede cpf */
    IF  NOT glb_idsenlet  THEN
        RUN senha_cpf.w (OUTPUT aux_flgderro).
    ELSE
        RUN senha.w (OUTPUT aux_flgderro).
    
    IF  NOT aux_flgderro THEN
        DO:
            /* puxa o frame principal pra frente */
            h_principal:MOVE-TO-TOP().
            
            /* Pegar nome do convenio */
            RUN procedures/busca_convenios_codbarras.p(INPUT par_cdbarra1,
                                                       INPUT par_cdbarra2,
                                                       INPUT par_cdbarra3,
                                                       INPUT par_cdbarra4,
                                                       INPUT par_dscodbar,
                                                       INPUT "V",
                                                       OUTPUT aux_nmextcon,
                                                       OUTPUT aux_flgderro).
            IF aux_flgderro OR aux_nmextcon = "" THEN
                RUN procedures/grava_log.p (INPUT "Convenio nao encontrado.").
            ELSE
                RUN procedures/grava_log.p (INPUT "Convenio: " + aux_nmextcon).

            RUN procedures/grava_log.p (INPUT "Codigo de Barras: " + 
                                        par_cdbarra1 +
                                        par_cdbarra2 +
                                        par_cdbarra3 +
                                        par_cdbarra4 + " " +
                                        par_dscodbar).

            /* verifica e retorna os dados do titulo */
            RUN procedures/efetua_pagamento.p (  INPUT par_cdbarra1,
                                                 INPUT par_cdbarra2,
                                                 INPUT par_cdbarra3,
                                                 INPUT par_cdbarra4,
                                                 INPUT "",
                                                 INPUT par_dscodbar,
                                                 INPUT par_vldpagto,
                                                 INPUT par_datpagto,
                                                 INPUT "",
                                                 INPUT par_flagenda,
                                                 INPUT par_idtpdpag,
                                                 INPUT par_tpcptdoc,
                                                 INPUT "", /* nrctrnpc */
                                                OUTPUT aux_dsprotoc,
                                                OUTPUT aux_cdbcoctl,
                                                OUTPUT aux_cdagectl,
                                                OUTPUT aux_idastcjt,
                                                OUTPUT aux_flgderro).

            IF  NOT aux_flgderro THEN
                DO:
                    RUN procedures/inicializa_dispositivo.p ( INPUT 6,
                                                             OUTPUT aux_flgderro).
                    IF  aux_idastcjt = 0     THEN
                        RUN imprime_comprovante (INPUT aux_dsprotoc,
                                                 INPUT aux_cdbcoctl,
                                                 INPUT aux_cdagectl).
                END.
            ELSE /* Erro na rotina */
                DO:
                    h_principal:MOVE-TO-BOTTOM().
                    h_inicializando:MOVE-TO-BOTTOM().
                END.
        END.
        
    /* verifica se finalizou a operacao */
    IF  RETURN-VALUE = "OK"  THEN
        DO:
            ASSIGN aux_cdbarras = SUBSTR(par_cdbarra1, 1 ,11) + par_cdbarra2.

            IF  par_dscodbar <> "" THEN
                ASSIGN aux_cdempcon  = INT(SUBSTR(par_dscodbar,16,4)) 
                       aux_cdsegmto  = INT(SUBSTR(par_dscodbar,2,1)). 
            ELSE
                ASSIGN aux_cdempcon = INT(SUBSTR(aux_cdbarras,16,4))
                       aux_cdsegmto = INT(SUBSTR(aux_cdbarras,2,1)).

            RUN procedures/busca_convenios_codbarras.p(INPUT par_cdbarra1,
                                                       INPUT par_cdbarra2,
                                                       INPUT par_cdbarra3,
                                                       INPUT par_cdbarra4,
                                                       INPUT par_dscodbar,
                                                       INPUT "P",
                                                       OUTPUT aux_nmextcon,
                                                       OUTPUT aux_flgderro).

            IF  aux_flgderro      OR
                aux_nmextcon = "" THEN /* Convenio não encontrado (SICREDI) */
                DO:
                    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                    RETURN "OK".
                END.

            RUN procedures/obtem_autorizacoes_debito.p (INPUT "P",
                                                        INPUT  aux_cdempcon,
                                                        INPUT  aux_cdsegmto, 
                                                        OUTPUT aux_flgdbaut,
                                                        OUTPUT aux_flgderro,
                                                        OUTPUT TABLE tt-debaut-consulta).
            IF  aux_flgdbaut THEN
                DO:
                    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                    RETURN "OK".
                END.
            ELSE
                DO:
                    RUN cartao_pagamento_convenio_debaut.w (INPUT "P",
                                                            INPUT par_cdbarra1,
                                                            INPUT par_cdbarra2,
                                                            INPUT par_cdbarra3,
                                                            INPUT par_cdbarra4,
                                                            INPUT par_dscodbar).
                    IF  RETURN-VALUE = "OK"  THEN
                        DO:
                            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                            RETURN "OK".
                        END.
                END.
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
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_pagto_convenio_dados
ON ANY-KEY OF Btn_H IN FRAME f_cartao_pagto_convenio_dados /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_pagto_convenio_dados
ON CHOOSE OF Btn_H IN FRAME f_cartao_pagto_convenio_dados /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_cartao_pagto_convenio_dados OCX.Tick
PROCEDURE temporizador.t_cartao_pagto_convenio_dados.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_cartao_pagto_convenio_dados.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_cartao_pagto_convenio_dados 


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
    FRAME f_cartao_pagto_convenio_dados:LOAD-MOUSE-POINTER("blank.cur").
    FRAME f_mensagem_agen:LOAD-MOUSE-POINTER("blank.cur").

    ASSIGN chtemporizador:t_cartao_pagto_convenio_dados:INTERVAL = glb_nrtempor
           ed_dttransa = TODAY
           ed_dtdpagto = par_datpagto
           ed_vldpagto = par_vldpagto

           /* Dados do associado */
           ed_cdagectl = glb_cdagectl
           ed_nmrescop = " - " + glb_nmrescop
           ed_nrdconta = glb_nrdconta
           ed_nmextttl = glb_nmtitula[1].

    DISPLAY ed_cdagectl  ed_nmrescop
            ed_nrdconta  ed_nmextttl
            WITH FRAME f_cartao_pagto_convenio_dados.

    IF  par_flagenda THEN
        ASSIGN ed_titpagto:SCREEN-VALUE = "   AGENDAMENTO  "
               FRAME f_mensagem_agen:VISIBLE = TRUE.
    ELSE
        ASSIGN ed_titpagto:SCREEN-VALUE = "PAG. DE CONVÊNIO"
               FRAME f_mensagem_agen:VISIBLE = FALSE.

    /* verifica e retorna os dados do convenio */
    RUN procedures/verifica_convenio.p ( INPUT par_cdbarra1,
                                         INPUT par_cdbarra2,
                                         INPUT par_cdbarra3,
                                         INPUT par_cdbarra4,
                                         INPUT par_dscodbar,
                                         INPUT par_vldpagto,
                                         INPUT par_datpagto,
                                         INPUT par_flagenda,
                                        OUTPUT ed_nmconven,
                                        OUTPUT ed_dslindig,
                                        OUTPUT aux_flgderro).
    IF  aux_flgderro  THEN
        DO:
            APPLY "CHOOSE" TO Btn_H.
            RETURN "NOK".
        END.
    ELSE
        DO:
            DISPLAY ed_nmconven
                    ed_dslindig
                    ed_dttransa
                    ed_dtdpagto
                    ed_vldpagto
                    WITH FRAME f_cartao_pagto_convenio_dados.
        END.

    APPLY "ENTRY" TO Btn_H.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_cartao_pagto_convenio_dados  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_pagamento_convenio_dados.wrx":U ).
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
ELSE MESSAGE "cartao_pagamento_convenio_dados.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_cartao_pagto_convenio_dados  _DEFAULT-DISABLE
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
  HIDE FRAME f_cartao_pagto_convenio_dados.
  HIDE FRAME f_mensagem_agen.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_cartao_pagto_convenio_dados  _DEFAULT-ENABLE
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
  DISPLAY ed_nmconven ed_dslindig ed_dttransa ed_dtdpagto ed_vldpagto 
          ed_titpagto ed_cdagectl ed_nmrescop ed_nrdconta ed_nmextttl 
      WITH FRAME f_cartao_pagto_convenio_dados.
  ENABLE RECT-132 RECT-134 RECT-135 RECT-137 RECT-138 IMAGE-37 IMAGE-40 
         ed_nmconven ed_dslindig ed_dttransa ed_dtdpagto ed_vldpagto Btn_D 
         Btn_H ed_titpagto ed_cdagectl ed_nmrescop ed_nrdconta ed_nmextttl 
      WITH FRAME f_cartao_pagto_convenio_dados.
  {&OPEN-BROWSERS-IN-QUERY-f_cartao_pagto_convenio_dados}
  ENABLE RECT-148 
      WITH FRAME f_mensagem_agen.
  {&OPEN-BROWSERS-IN-QUERY-f_mensagem_agen}
  VIEW w_cartao_pagto_convenio_dados.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE imprime_comprovante w_cartao_pagto_convenio_dados 
PROCEDURE imprime_comprovante :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE INPUT PARAM par_dsprotoc     AS CHARACTER                NO-UNDO.
DEFINE INPUT PARAM par_cdbcoctl     AS CHARACTER                NO-UNDO.
DEFINE INPUT PARAM par_cdagectl     AS CHARACTER                NO-UNDO.

DEFINE VARIABLE    tmp_tximpres     AS CHARACTER                NO-UNDO.
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
                                                             "         " +
                      "                                                ".
IF par_flagenda THEN
DO:
tmp_tximpres = tmp_tximpres +
                      "           COMPROVANTE DE AGENDAMENTO           ".
END.
ELSE
DO:
tmp_tximpres = tmp_tximpres +
                      "            COMPROVANTE DE PAGAMENTO            ".
END.
 
IF NOT par_flagenda THEN
    ASSIGN tmp_tximpres = tmp_tximpres +
              "                                                " +
              "  BANCO: " + STRING(par_cdbcoctl, "999")
           tmp_tximpres = tmp_tximpres +
              "                                    "             +
              "AGENCIA: " + STRING(par_cdagectl, "9999")

           tmp_tximpres = tmp_tximpres +
              "                                   ".
ELSE
    ASSIGN tmp_tximpres = tmp_tximpres +
              "                                                ".

ASSIGN tmp_tximpres = tmp_tximpres +
              "  CONTA: " + STRING(glb_nrdconta,"zzzz,zzz,9")    +
              " - " + STRING(glb_nmtitula[1],"x(26)").


/* Segundo titular */
IF  glb_nmtitula[2] <> ""  THEN
    tmp_tximpres = tmp_tximpres +
                   "                    " + STRING(glb_nmtitula[2],"x(28)").


tmp_tximpres = tmp_tximpres +
               "                                                " +
               "                                                " +
               "CONVENIO: " + STRING(ed_nmconven,"x(38)") +
               "                                                ".
IF par_flagenda THEN
    DO:
        tmp_tximpres = tmp_tximpres +
               "DATA DO AGENDAMENTO: " + STRING(ed_dtdpagto,"99/99/9999") +
                                                       "                 ".
    END.
ELSE
    DO:
        tmp_tximpres = tmp_tximpres +
               "  DATA DO PAGAMENTO: " + STRING(ed_dtdpagto,"99/99/9999") +
                                                      "                 ".
    END.

tmp_tximpres = tmp_tximpres +
               "                                                " +
               " VALOR DO PAGAMENTO: " + STRING(ed_vldpagto,"zz,zz9.99")  +
                                             "                  " +
               "                                                " +
               "LINHA DIGITAVEL: " + SUBSTRING(ed_dslindig,1,27)  + "    " +
               "                 " + SUBSTRING(ed_dslindig,29,27) + "    " +
               "                                                ".
IF  NOT par_flagenda THEN
    DO:
        tmp_tximpres = tmp_tximpres +
              "   PROTOCOLO: " + STRING(par_dsprotoc,"x(29)") + "     ".

        IF   glb_dtmvtocd > TODAY   THEN
             tmp_tximpres = tmp_tximpres +
              "ESTE PAGAMENTO SERA PROCESSADO NO PROXIMO DIA   " + 
              "UTIL.                                           ".  

        tmp_tximpres = tmp_tximpres +
              "                                                ".
    END.
ELSE
    tmp_tximpres = tmp_tximpres +
              " A QUITACAO EFETIVA DESTE AGENDAMENTO DEPENDERA " +
              "DA EXISTENCIA DE SALDO NA SUA CONTA CORRENTE NA " +
              "          DATA ESCOLHIDA PARA DEBITO.           " +
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

RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_cartao_pagto_convenio_dados 
PROCEDURE tecla :
chtemporizador:t_cartao_pagto_convenio_dados:INTERVAL = 0.

    IF  KEY-FUNCTION(LASTKEY) = "D"                             AND
        Btn_D:SENSITIVE IN FRAME f_cartao_pagto_convenio_dados  THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                             AND
        Btn_H:SENSITIVE IN FRAME f_cartao_pagto_convenio_dados  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_cartao_pagto_convenio_dados:INTERVAL = glb_nrtempor.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

