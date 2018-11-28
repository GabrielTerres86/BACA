&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_cartao_saldos_conta
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_cartao_saldos_conta 
/* ..............................................................................

Procedure: cartao_saldos.w
Objetivo : Tela para consulta e impressao de saldos
Autor    : Evandro
Data     : Janeiro 2010

Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

                  08/05/2013 - Transferencia intercooperativa (Gabriel).

                  27/01/2016 - Novo parâmetro na chamada imprime_saldo_limite.p
                               (Lucas Lunelli - PRJ261)
                                  
                                  08/11/2016 - Alteracoes referentes a melhoria 165 - Lancamentos
                               Futuros. Lenilson (Mouts)

                  07/12/2016 - alteracoes TAA chamado 564807
                  
                  07/06/2018 - Alterar campo "Emprestimos a liberar" para "Saldos a liberar". 
                               Gabriel (Mouts) - SCTASK0015667.

				  08/11/2018 - Ajuste no calculo do "Saldo Total", somando o valor de
				               "Saldos a Liberar" ao inves de subtrair do "Saldo Total". Jefferson (Mouts)

.............................................................................. */

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

DEFINE VARIABLE aux_flgderro        AS LOGICAL              NO-UNDO.
DEFINE VARIABLE aux_idastcjt        AS INTEGER                          NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_cartao_saldos_conta

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-15 RECT-16 ed_nmtitula ed_vlsddisp ~
ed_vllautom ed_valaucre ed_vlsdbloq ed_vlblqtaa ed_vlsdblpr ed_vlsdblfp ~
Btn_G ed_vlsdchsl ed_vlstotal ed_vllimcre Btn_H ed_vlcreddeb 
&Scoped-Define DISPLAYED-OBJECTS ed_nmtitula ed_vlsddisp ed_vllautom ~
ed_valaucre ed_vlsdbloq ed_vlblqtaa ed_vlsdblpr ed_vlsdblfp ed_vlsdchsl ~
ed_vlstotal ed_vllimcre ed_vlcreddeb 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_cartao_saldos_conta AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_G 
     LABEL "IMPRIMIR" 
     SIZE 41 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_H 
     LABEL "VOLTAR" 
     SIZE 41 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_nmtitula AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 96 BY 3.81
     BGCOLOR 15 FGCOLOR 1 FONT 11 NO-UNDO.

DEFINE VARIABLE ed_valaucre AS DECIMAL FORMAT "zz,zzz,zzz,zz9.99-":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1.19
     BGCOLOR 15 FGCOLOR 1 FONT 11 NO-UNDO.

DEFINE VARIABLE ed_vlblqtaa AS DECIMAL FORMAT "zz,zzz,zzz,zz9.99-":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1.19
     BGCOLOR 15 FGCOLOR 1 FONT 11 NO-UNDO.

DEFINE VARIABLE ed_vlcreddeb AS DECIMAL FORMAT "zz,zzz,zzz,zz9.99-":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1.19
     BGCOLOR 15 FGCOLOR 1 FONT 11 NO-UNDO.

DEFINE VARIABLE ed_vllautom AS DECIMAL FORMAT "zz,zzz,zzz,zz9.99-":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1.19
     BGCOLOR 15 FGCOLOR 1 FONT 11 NO-UNDO.

DEFINE VARIABLE ed_vllimcre AS DECIMAL FORMAT "zz,zzz,zzz,zz9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1.19
     BGCOLOR 15 FGCOLOR 1 FONT 11 NO-UNDO.

DEFINE VARIABLE ed_vlsdblfp AS DECIMAL FORMAT "zz,zzz,zzz,zz9.99-":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1.19
     BGCOLOR 15 FGCOLOR 1 FONT 11 NO-UNDO.

DEFINE VARIABLE ed_vlsdbloq AS DECIMAL FORMAT "zz,zzz,zzz,zz9.99-":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1.19
     BGCOLOR 15 FGCOLOR 1 FONT 11 NO-UNDO.

DEFINE VARIABLE ed_vlsdblpr AS DECIMAL FORMAT "zz,zzz,zzz,zz9.99-":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1.19
     BGCOLOR 15 FGCOLOR 1 FONT 11 NO-UNDO.

DEFINE VARIABLE ed_vlsdchsl AS DECIMAL FORMAT "zz,zzz,zzz,zz9.99-":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1.19
     BGCOLOR 15 FGCOLOR 1 FONT 11 NO-UNDO.

DEFINE VARIABLE ed_vlsddisp AS DECIMAL FORMAT "zz,zzz,zzz,zz9.99-":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1.19
     FGCOLOR 1 FONT 11 NO-UNDO.

DEFINE VARIABLE ed_vlstotal AS DECIMAL FORMAT "zz,zzz,zzz,zz9.99-":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1.19
     BGCOLOR 15 FGCOLOR 1 FONT 11 NO-UNDO.

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

DEFINE RECTANGLE RECT-15
     EDGE-PIXELS 4 GRAPHIC-EDGE  NO-FILL   
     SIZE 102 BY 21.43.

DEFINE RECTANGLE RECT-16
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 97 BY .24
     BGCOLOR 8 .

DEFINE RECTANGLE RECT-122
     EDGE-PIXELS 4 GRAPHIC-EDGE  NO-FILL   
     SIZE 35 BY 9.29.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_cartao_saldos_conta
     ed_nmtitula AT ROW 8.29 COL 14 NO-LABEL WIDGET-ID 96
     ed_vlsddisp AT ROW 12.33 COL 109 RIGHT-ALIGNED NO-LABEL WIDGET-ID 110
     ed_vllautom AT ROW 13.76 COL 109 RIGHT-ALIGNED NO-LABEL WIDGET-ID 98
     ed_valaucre AT ROW 15.1 COL 68 COLON-ALIGNED NO-LABEL WIDGET-ID 168
     ed_vlsdbloq AT ROW 16.48 COL 109 RIGHT-ALIGNED NO-LABEL WIDGET-ID 104
     ed_vlblqtaa AT ROW 17.91 COL 109 RIGHT-ALIGNED NO-LABEL WIDGET-ID 140
     ed_vlsdblpr AT ROW 19.33 COL 109 RIGHT-ALIGNED NO-LABEL WIDGET-ID 106
     ed_vlsdblfp AT ROW 20.76 COL 109 RIGHT-ALIGNED NO-LABEL WIDGET-ID 102
     Btn_G AT ROW 21.95 COL 116 WIDGET-ID 86
     ed_vlsdchsl AT ROW 22.19 COL 109 RIGHT-ALIGNED NO-LABEL WIDGET-ID 108
     ed_vlstotal AT ROW 24.1 COL 109 RIGHT-ALIGNED NO-LABEL WIDGET-ID 112
     ed_vllimcre AT ROW 25.52 COL 109 RIGHT-ALIGNED NO-LABEL WIDGET-ID 100
     Btn_H AT ROW 25.62 COL 116 WIDGET-ID 74
     ed_vlcreddeb AT ROW 26.91 COL 109 RIGHT-ALIGNED NO-LABEL WIDGET-ID 172
     "ao mês atual." VIEW-AS TEXT
          SIZE 44 BY 1.19 AT ROW 18.95 COL 115 WIDGET-ID 178
          FONT 14
     "Disponível para Saque:" VIEW-AS TEXT
          SIZE 40 BY 1.19 AT ROW 12.33 COL 29 WIDGET-ID 126
          FONT 14
     "Em Cheques da Praça:" VIEW-AS TEXT
          SIZE 40 BY 1.19 AT ROW 19.33 COL 29 WIDGET-ID 142
          FONT 14
     "CONSULTA DE SALDOS" VIEW-AS TEXT
          SIZE 106 BY 3.33 AT ROW 1.48 COL 28 WIDGET-ID 166
          FGCOLOR 1 FONT 10
     "Saldo Total:" VIEW-AS TEXT
          SIZE 21 BY 1.19 AT ROW 24.1 COL 48 WIDGET-ID 114
          FONT 14
     "Saldos a Liberar:" VIEW-AS TEXT
          SIZE 29 BY 1.19 AT ROW 16.48 COL 40 WIDGET-ID 122
          FONT 14
     "Limite Cheque Especial:" VIEW-AS TEXT
          SIZE 42.8 BY 1.19 AT ROW 25.52 COL 27 WIDGET-ID 118
          FONT 14
     "Saldo Com Créditos e Débitos:" VIEW-AS TEXT
          SIZE 52.8 BY 1.19 AT ROW 26.91 COL 17 WIDGET-ID 174
          FONT 14
     "Depósitos TAA a Confirmar:" VIEW-AS TEXT
          SIZE 47 BY 1.19 AT ROW 17.91 COL 21.6 WIDGET-ID 124
          FONT 14
     "Em Cheques Fora Praça:" VIEW-AS TEXT
          SIZE 44 BY 1.19 AT ROW 20.76 COL 68 RIGHT-ALIGNED WIDGET-ID 116
          FONT 14
     "Cheque Salário:" VIEW-AS TEXT
          SIZE 28 BY 1.19 AT ROW 22.19 COL 41 WIDGET-ID 120
          FONT 14
     "Lançamentos Futuros a Crédito*:" VIEW-AS TEXT
          SIZE 55.2 BY 1.19 AT ROW 15.1 COL 13 WIDGET-ID 170
          FONT 14
     "Lançamentos Futuros a Débito*:" VIEW-AS TEXT
          SIZE 54.8 BY 1.19 AT ROW 13.76 COL 14 WIDGET-ID 128
          FONT 14
     "*Lançamentos Referente" VIEW-AS TEXT
          SIZE 44 BY 1.19 AT ROW 17.67 COL 115 WIDGET-ID 176
          FONT 14
     RECT-15 AT ROW 7.91 COL 11 WIDGET-ID 92
     RECT-16 AT ROW 23.62 COL 13 WIDGET-ID 94
     RECT-101 AT ROW 5.05 COL 19.6 WIDGET-ID 162
     RECT-102 AT ROW 5.52 COL 19.6 WIDGET-ID 164
     RECT-103 AT ROW 5.29 COL 19.6 WIDGET-ID 160
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 160 BY 28.57 WIDGET-ID 100.

DEFINE FRAME f_saldo_madrugada
     "    ATENÇÃO" VIEW-AS TEXT
          SIZE 33 BY 1.67 AT ROW 1.48 COL 3
          BGCOLOR 14 FGCOLOR 12 FONT 8
     "SUJEITO A" VIEW-AS TEXT
          SIZE 31 BY .95 AT ROW 8.38 COL 4
          FGCOLOR 9 FONT 11
     "CHEQUES." VIEW-AS TEXT
          SIZE 31 BY .95 AT ROW 6.71 COL 4
          FGCOLOR 9 FONT 11
     "ALTERAÇÃO" VIEW-AS TEXT
          SIZE 31 BY .95 AT ROW 9.33 COL 4
          FGCOLOR 9 FONT 11
     "DIÁRIA DOS" VIEW-AS TEXT
          SIZE 31 BY .95 AT ROW 5.76 COL 4
          FGCOLOR 9 FONT 11
     "SALDO ANTES DA" VIEW-AS TEXT
          SIZE 31 BY .95 AT ROW 3.86 COL 4
          FGCOLOR 9 FONT 11
     "COMPENSAÇÃO" VIEW-AS TEXT
          SIZE 31 BY .95 AT ROW 4.81 COL 4
          FGCOLOR 9 FONT 11
     RECT-122 AT ROW 1.24 COL 2
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         NO-LABELS SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 115 ROW 7.43
         SIZE 37 BY 9.76 WIDGET-ID 200.


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
  CREATE WINDOW w_cartao_saldos_conta ASSIGN
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
ASSIGN w_cartao_saldos_conta = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_cartao_saldos_conta
  VISIBLE,,RUN-PERSISTENT                                               */
/* REPARENT FRAME */
ASSIGN FRAME f_saldo_madrugada:FRAME = FRAME f_cartao_saldos_conta:HANDLE.

/* SETTINGS FOR FRAME f_cartao_saldos_conta
   NOT-VISIBLE FRAME-NAME                                               */
/* SETTINGS FOR FILL-IN ed_vlblqtaa IN FRAME f_cartao_saldos_conta
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN ed_vlcreddeb IN FRAME f_cartao_saldos_conta
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN ed_vllautom IN FRAME f_cartao_saldos_conta
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN ed_vllimcre IN FRAME f_cartao_saldos_conta
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN ed_vlsdblfp IN FRAME f_cartao_saldos_conta
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN ed_vlsdbloq IN FRAME f_cartao_saldos_conta
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN ed_vlsdblpr IN FRAME f_cartao_saldos_conta
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN ed_vlsdchsl IN FRAME f_cartao_saldos_conta
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN ed_vlsddisp IN FRAME f_cartao_saldos_conta
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN ed_vlstotal IN FRAME f_cartao_saldos_conta
   ALIGN-R                                                              */
/* SETTINGS FOR RECTANGLE RECT-101 IN FRAME f_cartao_saldos_conta
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-102 IN FRAME f_cartao_saldos_conta
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-103 IN FRAME f_cartao_saldos_conta
   NO-ENABLE                                                            */
/* SETTINGS FOR TEXT-LITERAL "Em Cheques Fora Praça:"
          SIZE 44 BY 1.19 AT ROW 20.76 COL 68 RIGHT-ALIGNED             */

/* SETTINGS FOR FRAME f_saldo_madrugada
   NOT-VISIBLE                                                          */
ASSIGN 
       FRAME f_saldo_madrugada:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME f_saldo_madrugada
/* Query rebuild information for FRAME f_saldo_madrugada
     _Query            is NOT OPENED
*/  /* FRAME f_saldo_madrugada */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_cartao_saldos_conta:HANDLE
       ROW             = 2.19
       COLUMN          = 9
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_saldos_conta */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_cartao_saldos_conta
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_saldos_conta w_cartao_saldos_conta
ON END-ERROR OF w_cartao_saldos_conta
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_saldos_conta w_cartao_saldos_conta
ON WINDOW-CLOSE OF w_cartao_saldos_conta
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_G
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_cartao_saldos_conta
ON ANY-KEY OF Btn_G IN FRAME f_cartao_saldos_conta /* IMPRIMIR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_cartao_saldos_conta
ON CHOOSE OF Btn_G IN FRAME f_cartao_saldos_conta /* IMPRIMIR */
DO:
    DEF VAR tmp_tximpres    AS CHAR         NO-UNDO.    

    
    h_principal:MOVE-TO-TOP().


    /* obtem o saldo - logar impressao de saldo */
    RUN procedures/obtem_saldo_limite.p ( INPUT 2,
                                         OUTPUT ed_vlsddisp,
                                         OUTPUT ed_vllautom,
                                         OUTPUT ed_valaucre,
                                         OUTPUT ed_vlsdbloq,
                                         OUTPUT ed_vlblqtaa,
                                         OUTPUT ed_vlsdblpr,
                                         OUTPUT ed_vlsdblfp,
                                         OUTPUT ed_vlsdchsl,
                                         OUTPUT ed_vllimcre,
                                                                                 OUTPUT aux_idastcjt,
                                         OUTPUT aux_flgderro).
    
    /* monta o comprovante do saldo */
    RUN procedures/imprime_saldo_limite_lanc.p ( INPUT glb_nmtitula,
                                            INPUT ed_vlsddisp, 
                                            INPUT ed_vllautom, 
                                            INPUT ed_valaucre,
                                            INPUT ed_vlsdbloq, 
                                            INPUT ed_vlblqtaa,
                                            INPUT ed_vlsdblpr, 
                                            INPUT ed_vlsdblfp, 
                                            INPUT ed_vlsdchsl, 
                                            INPUT ed_vllimcre,
                                            INPUT 0, /* pré-aprovado */
                                            INPUT ed_vlstotal,
                                            INPUT ed_vlstotal + ed_valaucre - ed_vllautom,
                                           OUTPUT tmp_tximpres).

    RUN procedures/inicializa_dispositivo.p ( INPUT 6,
                                             OUTPUT aux_flgderro).                                                                             
                                                                                 
    RUN impressao.w (INPUT "Saldo de Conta Corrente...",
                     INPUT tmp_tximpres).
    

    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "OK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_saldos_conta
ON ANY-KEY OF Btn_H IN FRAME f_cartao_saldos_conta /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_saldos_conta
ON CHOOSE OF Btn_H IN FRAME f_cartao_saldos_conta /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_cartao_saldos_conta OCX.Tick
PROCEDURE temporizador.t_cartao_saldos_conta.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_cartao_saldos_conta.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_cartao_saldos_conta 


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
    FRAME f_cartao_saldos_conta:LOAD-MOUSE-POINTER("blank.cur").
    FRAME f_saldo_madrugada:LOAD-MOUSE-POINTER("blank.cur").

    /* saldo na madrugada */
    IF  glb_dtmvtolt <> glb_dtmvtocd  THEN
        VIEW FRAME f_saldo_madrugada.

    RUN procedures/inicializa_dispositivo.p ( INPUT 6,
                                             OUTPUT aux_flgderro).
                
    /* se a impressora estiver desabilitada ou sem papel */
    IF  NOT xfs_impressora  OR 
        xfs_impsempapel     THEN
        DISABLE Btn_G WITH FRAME f_cartao_saldos_conta.



    IF  aux_flgderro  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        DO:
            ed_nmtitula = "    " +
                          STRING(glb_cdagectl,"9999") + " - " + glb_nmrescop + CHR(13) +
                          STRING(glb_nrdconta,"zzzz,zz9,9") + "  " + SUBSTRING(glb_nmtitula[1],1,30).

            IF  glb_nmtitula[2] <> ""  THEN
                ed_nmtitula = ed_nmtitula + CHR(13) + 
                              "            " + SUBSTRING(glb_nmtitula[2],1,30).

            DISPLAY ed_nmtitula WITH FRAME f_cartao_saldos_conta.
        END.


    /* obtem o saldo - logar consulta de saldo */
    RUN procedures/obtem_saldo_limite.p ( INPUT 1,
                                         OUTPUT ed_vlsddisp,
                                         OUTPUT ed_vllautom,
                                         OUTPUT ed_valaucre,
                                         OUTPUT ed_vlsdbloq,
                                         OUTPUT ed_vlblqtaa,
                                         OUTPUT ed_vlsdblpr,
                                         OUTPUT ed_vlsdblfp,
                                         OUTPUT ed_vlsdchsl,
                                         OUTPUT ed_vllimcre,
                                                                                 OUTPUT aux_idastcjt,
                                         OUTPUT aux_flgderro).

    IF  aux_flgderro  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        DO:
            ed_vlstotal = ed_vlsddisp + ed_vlsdbloq +
                          ed_vlsdblpr + ed_vlsdblfp + ed_vlsdchsl.

            ed_vlcreddeb = ed_vlstotal + ed_valaucre - ed_vllautom.
                                        

            IF  ed_vlsddisp < 0  THEN
                ed_vlsddisp:FGCOLOR = 12.

            IF  ed_vlstotal < 0  THEN
                ed_vlstotal:FGCOLOR = 12.

            IF  ed_vlcreddeb < 0  THEN
                ed_vlcreddeb:FGCOLOR = 12.    

            IF  ed_vllautom > 0  THEN
                ed_vllautom:FGCOLOR = 12.

            DISPLAY ed_vlsddisp
                    ed_vllautom
                    ed_valaucre
                    ed_vlsdbloq
                    ed_vlblqtaa
                    ed_vlsdblpr
                    ed_vlsdblfp
                    ed_vlsdchsl
                    ed_vlstotal
                    ed_vlcreddeb
                    ed_vllimcre
                    WITH FRAME f_cartao_saldos_conta.
        END.


    chtemporizador:t_cartao_saldos_conta:INTERVAL = glb_nrtempor.

    /* coloca o foco no botao H */
    APPLY "ENTRY" TO Btn_H.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_cartao_saldos_conta  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_saldos_conta.wrx":U ).
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
ELSE MESSAGE "cartao_saldos_conta.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_cartao_saldos_conta  _DEFAULT-DISABLE
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
  HIDE FRAME f_cartao_saldos_conta.
  HIDE FRAME f_saldo_madrugada.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_cartao_saldos_conta  _DEFAULT-ENABLE
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
  DISPLAY ed_nmtitula ed_vlsddisp ed_vllautom ed_valaucre ed_vlsdbloq 
          ed_vlblqtaa ed_vlsdblpr ed_vlsdblfp ed_vlsdchsl ed_vlstotal 
          ed_vllimcre ed_vlcreddeb 
      WITH FRAME f_cartao_saldos_conta.
  ENABLE RECT-15 RECT-16 ed_nmtitula ed_vlsddisp ed_vllautom ed_valaucre 
         ed_vlsdbloq ed_vlblqtaa ed_vlsdblpr ed_vlsdblfp Btn_G ed_vlsdchsl 
         ed_vlstotal ed_vllimcre Btn_H ed_vlcreddeb 
      WITH FRAME f_cartao_saldos_conta.
  {&OPEN-BROWSERS-IN-QUERY-f_cartao_saldos_conta}
  ENABLE RECT-122 
      WITH FRAME f_saldo_madrugada.
  {&OPEN-BROWSERS-IN-QUERY-f_saldo_madrugada}
  VIEW w_cartao_saldos_conta.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_cartao_saldos_conta 
PROCEDURE tecla :
chtemporizador:t_cartao_saldos_conta:INTERVAL = 0.

    /* ---------- */
    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).
    
    IF  aux_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.

    IF  KEY-FUNCTION(LASTKEY) = "G"                     AND
        Btn_G:SENSITIVE IN FRAME f_cartao_saldos_conta  THEN
        APPLY "CHOOSE" TO Btn_G.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                     AND
        Btn_H:SENSITIVE IN FRAME f_cartao_saldos_conta  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_cartao_saldos_conta:INTERVAL = glb_nrtempor.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

