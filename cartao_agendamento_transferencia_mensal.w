&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_cartao_agen_transf_mensal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_cartao_agen_transf_mensal 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 
  
  Alteracoes: 29/08/2011 - Incluir validacoes de quantidade maxima de meses
                           e data inicio maxima (Gabriel).
                           
              08/05/2013 - Transferencia intercooperativa (Gabriel).
              
              05/12/2014 - Correção para não gerar comprovante sem efetivar
                           a operação (Lunelli SD 230613)             

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

/* Parameters Definitions ---                                           */

DEFINE INPUT PARAM par_cdagectl AS INTEGER                      NO-UNDO.
DEFINE INPUT PARAM par_nmrescop AS CHARACTER                    NO-UNDO.


/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }



DEFINE VARIABLE aux_flgderro        AS LOGICAL                  NO-UNDO.
DEFINE VARIABLE aux_cdagectl        AS INT                      NO-UNDO.
DEFINE VARIABLE aux_nmrescop        AS CHAR                     NO-UNDO.
DEFINE VARIABLE aux_nmtransf        AS CHAR         EXTENT 2    NO-UNDO.
DEFINE VARIABLE aux_dttransf        AS DATE FORMAT "99/99/99"   NO-UNDO.
DEFINE VARIABLE aux_flgmigra        AS LOGICAL                  NO-UNDO.
DEFINE VARIABLE aux_flgdinss        AS LOGICAL                  NO-UNDO.
DEFINE VARIABLE aux_flgbinss        AS LOGICAL                  NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_cartao_agen_transf_mensal

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ed_nrtransf ed_ddtransf ed_mmtransf ~
ed_intransf ed_vltransf Btn_G Btn_D Btn_H ed_dsagectl ed_nmtransf ~
ed_cdagectl ed_nmrescop ed_nrdconta ed_nmextttl RECT-127 RECT-128 IMAGE-37 ~
IMAGE-40 IMAGE-49 RECT-145 RECT-146 RECT-129 RECT-130 
&Scoped-Define DISPLAYED-OBJECTS ed_nrtransf ed_ddtransf ed_mmtransf ~
ed_intransf ed_vltransf ed_dsagectl ed_nmtransf ed_cdagectl ed_nmrescop ~
ed_nrdconta ed_nmextttl 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_cartao_agen_transf_mensal AS WIDGET-HANDLE NO-UNDO.

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
     VIEW-AS EDITOR NO-BOX
     SIZE 67 BY 3.14
     FGCOLOR 1 FONT 8 NO-UNDO.

DEFINE VARIABLE ed_cdagectl AS INTEGER FORMAT "9999":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 16 BY 1.29
     FONT 15 NO-UNDO.

DEFINE VARIABLE ed_ddtransf AS INTEGER FORMAT "z9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 10.6 BY 2.14
     FONT 13 NO-UNDO.

DEFINE VARIABLE ed_dsagectl AS CHARACTER FORMAT "X(256)":U INITIAL "0" 
     VIEW-AS FILL-IN 
     SIZE 108.8 BY 1.95
     FONT 15 NO-UNDO.

DEFINE VARIABLE ed_intransf AS CHARACTER FORMAT "xx/xxxx":U 
     VIEW-AS FILL-IN 
     SIZE 32.6 BY 2.14
     FONT 13 NO-UNDO.

DEFINE VARIABLE ed_mmtransf AS INTEGER FORMAT "z9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 10.6 BY 2.14
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
     SIZE 41 BY 2.14
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
     SIZE 43 BY 2.62.

DEFINE RECTANGLE RECT-129
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 34.6 BY 2.62.

DEFINE RECTANGLE RECT-130
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 110.8 BY 2.38.

DEFINE RECTANGLE RECT-145
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 13 BY 2.38.

DEFINE RECTANGLE RECT-146
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 12 BY 2.38.

DEFINE RECTANGLE RECT-98
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-99
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 14 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_cartao_agen_transf_mensal
     ed_nrtransf AT ROW 12.86 COL 31.2 COLON-ALIGNED NO-LABEL WIDGET-ID 104
     ed_ddtransf AT ROW 15.57 COL 31.2 COLON-ALIGNED NO-LABEL WIDGET-ID 204
     ed_mmtransf AT ROW 15.71 COL 94.6 COLON-ALIGNED NO-LABEL WIDGET-ID 208
     ed_intransf AT ROW 18.62 COL 31.2 COLON-ALIGNED NO-LABEL WIDGET-ID 212
     ed_vltransf AT ROW 21.48 COL 31.2 COLON-ALIGNED NO-LABEL WIDGET-ID 106
     Btn_G AT ROW 19.14 COL 94.4 WIDGET-ID 86
     Btn_D AT ROW 24.14 COL 6 WIDGET-ID 66
     Btn_H AT ROW 24.14 COL 94.4 WIDGET-ID 74
     ed_dsagectl AT ROW 9.76 COL 31.2 COLON-ALIGNED NO-LABEL WIDGET-ID 252
     ed_nmtransf AT ROW 12.14 COL 76 NO-LABEL WIDGET-ID 102 NO-TAB-STOP 
     ed_cdagectl AT ROW 6 COL 46 COLON-ALIGNED NO-LABEL WIDGET-ID 242 NO-TAB-STOP 
     ed_nmrescop AT ROW 6 COL 62 COLON-ALIGNED NO-LABEL WIDGET-ID 246 NO-TAB-STOP 
     ed_nrdconta AT ROW 7.38 COL 46 COLON-ALIGNED NO-LABEL WIDGET-ID 248 NO-TAB-STOP 
     ed_nmextttl AT ROW 7.38 COL 72 COLON-ALIGNED NO-LABEL WIDGET-ID 244 NO-TAB-STOP 
     "TRANSFERÊNCIA" VIEW-AS TEXT
          SIZE 75 BY 3.33 AT ROW 1.48 COL 25 WIDGET-ID 128
          FGCOLOR 1 FONT 10
     "Cooperativa:" VIEW-AS TEXT
          SIZE 28 BY 1.19 AT ROW 6 COL 18.6 WIDGET-ID 190
          FONT 8
     "(Mês/Ano)" VIEW-AS TEXT
          SIZE 18.2 BY 1.67 AT ROW 18.86 COL 68.2 WIDGET-ID 218
          FONT 14
     "Conta:" VIEW-AS TEXT
          SIZE 13.4 BY 1.33 AT ROW 13.19 COL 16 WIDGET-ID 108
          FONT 8
     "meses" VIEW-AS TEXT
          SIZE 18.6 BY 1.67 AT ROW 15.81 COL 110.6 WIDGET-ID 200
          FONT 8
     "CONTAS-CORRENTES" VIEW-AS TEXT
          SIZE 42 BY .86 AT ROW 3.38 COL 101 WIDGET-ID 130
          FGCOLOR 1 FONT 14
     "Valor:" VIEW-AS TEXT
          SIZE 13 BY 1.67 AT ROW 21.71 COL 18 WIDGET-ID 110
          FONT 8
     "Conta/Titular:" VIEW-AS TEXT
          SIZE 29 BY 1.19 AT ROW 7.38 COL 17 WIDGET-ID 192
          FONT 8
     "Iniciar em:" VIEW-AS TEXT
          SIZE 21.2 BY 1.67 AT ROW 18.86 COL 10.4 WIDGET-ID 216
          FONT 8
     "Cooperativa:" VIEW-AS TEXT
          SIZE 29 BY 1.19 AT ROW 10.81 COL 30.4 RIGHT-ALIGNED WIDGET-ID 250
          FONT 8
     "de cada mês, durante" VIEW-AS TEXT
          SIZE 47.4 BY 1.67 AT ROW 15.81 COL 48.2 WIDGET-ID 198
          FONT 8
     "Para" VIEW-AS TEXT
          SIZE 11 BY 1.19 AT ROW 9.57 COL 18.4 WIDGET-ID 114
          FONT 8
     "ENTRE" VIEW-AS TEXT
          SIZE 15 BY 1.14 AT ROW 1.95 COL 101.2 WIDGET-ID 132
          FGCOLOR 1 FONT 14
     "No dia" VIEW-AS TEXT
          SIZE 15 BY 1.67 AT ROW 15.81 COL 16.2 WIDGET-ID 196
          FONT 8
     RECT-127 AT ROW 12.57 COL 32.2 WIDGET-ID 94
     RECT-128 AT ROW 21.24 COL 32.2 WIDGET-ID 96
     IMAGE-37 AT ROW 24.29 COL 1 WIDGET-ID 148
     IMAGE-40 AT ROW 24.29 COL 156 WIDGET-ID 154
     IMAGE-49 AT ROW 19.29 COL 156 WIDGET-ID 156
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     RECT-145 AT ROW 15.48 COL 32.2 WIDGET-ID 206
     RECT-146 AT ROW 15.52 COL 96 WIDGET-ID 210
     RECT-129 AT ROW 18.38 COL 32.2 WIDGET-ID 214
     RECT-130 AT ROW 9.57 COL 32.2 WIDGET-ID 254
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1.1
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
  CREATE WINDOW w_cartao_agen_transf_mensal ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.62
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
ASSIGN w_cartao_agen_transf_mensal = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_cartao_agen_transf_mensal
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_cartao_agen_transf_mensal
   FRAME-NAME Custom                                                    */
ASSIGN 
       ed_dsagectl:READ-ONLY IN FRAME f_cartao_agen_transf_mensal        = TRUE.

ASSIGN 
       ed_nmtransf:READ-ONLY IN FRAME f_cartao_agen_transf_mensal        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_cartao_agen_transf_mensal
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_cartao_agen_transf_mensal
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_cartao_agen_transf_mensal
   NO-ENABLE                                                            */
/* SETTINGS FOR TEXT-LITERAL "Cooperativa:"
          SIZE 29 BY 1.19 AT ROW 10.81 COL 30.4 RIGHT-ALIGNED           */

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_cartao_agen_transf_mensal:HANDLE
       ROW             = 1.95
       COLUMN          = 5
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_agen_transf_mensal */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_cartao_agen_transf_mensal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_agen_transf_mensal w_cartao_agen_transf_mensal
ON END-ERROR OF w_cartao_agen_transf_mensal
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_agen_transf_mensal w_cartao_agen_transf_mensal
ON WINDOW-CLOSE OF w_cartao_agen_transf_mensal
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_agen_transf_mensal
ON ANY-KEY OF Btn_D IN FRAME f_cartao_agen_transf_mensal /* CONFIRMAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_agen_transf_mensal
ON CHOOSE OF Btn_D IN FRAME f_cartao_agen_transf_mensal /* CONFIRMAR */
DO:
    /* ---------- */
    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).
    
    IF  aux_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.

    ASSIGN aux_dttransf = DATE(ed_ddtransf:SCREEN-VALUE + "/" + ed_intransf:SCREEN-VALUE) NO-ERROR.

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
        DO:
            IF  aux_dttransf < TODAY THEN
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

    IF  glb_cdagectl = par_cdagectl                   AND
        INT(ed_nrtransf:SCREEN-VALUE) = glb_nrdconta  THEN
        DO:
                RUN mensagem.w (INPUT YES,
                            INPUT "    Atenção!",
                            INPUT "",
                            INPUT "A conta de origem e destino",
                            INPUT "não podem ser iguais.",
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
                            INPUT "    Atenção!",
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
                            INPUT "    Atenção!",
                            INPUT "",
                            INPUT "",
                            INPUT "O valor deve ser informado.",
                            INPUT "",
                            INPUT "").
   
            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.
   
            aux_flgderro = YES.
    END.
    ELSE
    IF  INT(ed_ddtransf:SCREEN-VALUE) = 0  THEN
        DO:    
            RUN mensagem.w (INPUT YES,
                            INPUT "    Atenção!",
                            INPUT "",
                            INPUT "",
                            INPUT "O dia deve ser informado.",
                            INPUT "",
                            INPUT "").
   
            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.
   
            aux_flgderro = YES.
    END.
    ELSE
    IF  INT(ed_mmtransf:SCREEN-VALUE) = 0  THEN
        DO:    
            RUN mensagem.w (INPUT YES,
                            INPUT "    Atenção!",
                            INPUT "",
                            INPUT "",
                            INPUT "O mês deve ser informado.",
                            INPUT "",
                            INPUT "").

            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.
   
            aux_flgderro = YES.
    END.
    ELSE
    IF  INT(ed_mmtransf:SCREEN-VALUE) > 24  THEN
        DO:    
            RUN mensagem.w (INPUT YES,
                            INPUT "    Atenção!",
                            INPUT "",
                            INPUT "",
                            INPUT "A quantidade máxima de",
                            INPUT "meses é 24.",
                            INPUT "").

            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.
   
            aux_flgderro = YES.
    END.
    ELSE
    IF  ed_intransf:SCREEN-VALUE = ""  THEN
        DO:    
            RUN mensagem.w (INPUT YES,
                            INPUT "    Atenção!",
                            INPUT "",
                            INPUT "",
                            INPUT "O período inicial deve",
                            INPUT "ser informado.",
                            INPUT "").
   
            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.
   
            aux_flgderro = YES.
        END.
    ELSE
    IF   DATE(INTE(SUBSTR(ed_intransf:SCREEN-VALUE,1,2)), /* Dia */  
              INT(ed_ddtransf:SCREEN-VALUE),              /* Mes */
              INTE(SUBSTR(ed_intransf:SCREEN-VALUE,4,4))) > ADD-INTERVAL(glb_dtmvtolt,24,"months")   THEN
         DO:    
             RUN mensagem.w (INPUT YES,
                             INPUT "    Atenção!",
                             INPUT "",
                             INPUT "",
                             INPUT "O prazo máximo de inicio",
                             INPUT "é de 24 meses.",
                             INPUT "").
         
             PAUSE 3 NO-MESSAGE.
             h_mensagem:HIDDEN = YES.
         
             aux_flgderro = YES.
         END.    

            
    IF  aux_flgderro THEN
        DO:
            APPLY "CHOOSE" TO Btn_G.
            RETURN NO-APPLY.
        END.

    ASSIGN ed_nrtransf
           ed_vltransf
           ed_ddtransf
           ed_mmtransf
           ed_intransf.

    RUN cartao_agendamento_transferencia_mensal_dados.w 
                                    (INPUT par_cdagectl,
                                     INPUT ed_dsagectl,
                                     INPUT ed_nrtransf,    
                                     INPUT aux_nmtransf,   
                                     INPUT ed_vltransf,    
                                     INPUT ed_ddtransf,    
                                     INPUT ed_mmtransf,    
                                     INPUT STRING(ed_intransf,"xx/xx"),
                                     INPUT aux_dttransf,
                                    OUTPUT aux_flgderro).

    IF  RETURN-VALUE = "NOK" AND
        aux_flgderro         THEN
        DO:
            APPLY "CHOOSE" TO Btn_G.
            RETURN NO-APPLY.
        END.


    
    /* repassa o retorno */
    RETURN RETURN-VALUE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_G
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_cartao_agen_transf_mensal
ON ANY-KEY OF Btn_G IN FRAME f_cartao_agen_transf_mensal /* CORRIGIR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_cartao_agen_transf_mensal
ON CHOOSE OF Btn_G IN FRAME f_cartao_agen_transf_mensal /* CORRIGIR */
DO:
    ASSIGN ed_nrtransf:SCREEN-VALUE = ""
           ed_nmtransf:SCREEN-VALUE = ""
           ed_vltransf:SCREEN-VALUE = ""
           ed_ddtransf:SCREEN-VALUE = ""
           ed_mmtransf:SCREEN-VALUE = ""
           ed_intransf:SCREEN-VALUE = "".

    APPLY "ENTRY" TO ed_nrtransf.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_agen_transf_mensal
ON ANY-KEY OF Btn_H IN FRAME f_cartao_agen_transf_mensal /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_agen_transf_mensal
ON CHOOSE OF Btn_H IN FRAME f_cartao_agen_transf_mensal /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_ddtransf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_ddtransf w_cartao_agen_transf_mensal
ON ANY-KEY OF ed_ddtransf IN FRAME f_cartao_agen_transf_mensal
DO:
    RUN tecla.

    IF  CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))  THEN
        DO:
            /* limite de caracteres */
            IF  LENGTH(ed_ddtransf:SCREEN-VALUE) > 3  THEN
                RETURN NO-APPLY.
    END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            ed_ddtransf:SCREEN-VALUE = "".
            RETURN NO-APPLY.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:

            APPLY "ENTRY" TO ed_mmtransf.
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


&Scoped-define SELF-NAME ed_intransf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_intransf w_cartao_agen_transf_mensal
ON ANY-KEY OF ed_intransf IN FRAME f_cartao_agen_transf_mensal
DO:
    RUN tecla.

    IF  CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))  THEN
        DO:
            /* limite de caracteres */
            IF  LENGTH(ed_intransf:SCREEN-VALUE) > 7  THEN
                RETURN NO-APPLY.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            ed_intransf:SCREEN-VALUE = "".
            RETURN NO-APPLY.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:                                     
            APPLY "ENTRY" TO ed_vltransf.
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


&Scoped-define SELF-NAME ed_mmtransf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_mmtransf w_cartao_agen_transf_mensal
ON ANY-KEY OF ed_mmtransf IN FRAME f_cartao_agen_transf_mensal
DO:
    RUN tecla.

    IF  CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))  THEN
        DO:
            /* limite de caracteres */
            IF  LENGTH(ed_mmtransf:SCREEN-VALUE) > 3  THEN
                RETURN NO-APPLY.

        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            ed_mmtransf:SCREEN-VALUE = "".
            RETURN NO-APPLY.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:                                     
            APPLY "ENTRY" TO ed_intransf.
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
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nrtransf w_cartao_agen_transf_mensal
ON ANY-KEY OF ed_nrtransf IN FRAME f_cartao_agen_transf_mensal
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
                                              OUTPUT aux_flgdinss,
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

                    APPLY "ENTRY" TO ed_ddtransf.
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
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_vltransf w_cartao_agen_transf_mensal
ON ANY-KEY OF ed_vltransf IN FRAME f_cartao_agen_transf_mensal
DO:
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
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_cartao_agen_transf_mensal OCX.Tick
PROCEDURE temporizador.t_cartao_agen_transf_mensal.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_cartao_agen_transf_mensal.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_cartao_agen_transf_mensal 


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
    FRAME f_cartao_agen_transf_mensal:LOAD-MOUSE-POINTER("blank.cur").

    chtemporizador:t_cartao_agen_transf_mensal:INTERVAL = glb_nrtempor.

    /* Dados do associado */
    ASSIGN ed_cdagectl = glb_cdagectl
           ed_nmrescop = " - " + glb_nmrescop
           ed_dsagectl = STRING(par_cdagectl,"9999") + " - " + par_nmrescop
           ed_nrdconta = glb_nrdconta
           ed_nmextttl = glb_nmtitula[1].

    DISP ed_cdagectl 
         ed_nmrescop
         ed_dsagectl
         ed_nrdconta
         ed_nmextttl WITH FRAME f_cartao_agen_transf_mensal.

    /* coloca o foco na conta */
    APPLY "ENTRY" TO ed_nrtransf.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_cartao_agen_transf_mensal  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_agendamento_transferencia_mensal.wrx":U ).
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
ELSE MESSAGE "cartao_agendamento_transferencia_mensal.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_cartao_agen_transf_mensal  _DEFAULT-DISABLE
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
  HIDE FRAME f_cartao_agen_transf_mensal.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_cartao_agen_transf_mensal  _DEFAULT-ENABLE
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
  DISPLAY ed_nrtransf ed_ddtransf ed_mmtransf ed_intransf ed_vltransf 
          ed_dsagectl ed_nmtransf ed_cdagectl ed_nmrescop ed_nrdconta 
          ed_nmextttl 
      WITH FRAME f_cartao_agen_transf_mensal.
  ENABLE ed_nrtransf ed_ddtransf ed_mmtransf ed_intransf ed_vltransf Btn_G 
         Btn_D Btn_H ed_dsagectl ed_nmtransf ed_cdagectl ed_nmrescop 
         ed_nrdconta ed_nmextttl RECT-127 RECT-128 IMAGE-37 IMAGE-40 IMAGE-49 
         RECT-145 RECT-146 RECT-129 RECT-130 
      WITH FRAME f_cartao_agen_transf_mensal.
  {&OPEN-BROWSERS-IN-QUERY-f_cartao_agen_transf_mensal}
  VIEW w_cartao_agen_transf_mensal.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_cartao_agen_transf_mensal 
PROCEDURE tecla :
chtemporizador:t_cartao_agen_transf_mensal:INTERVAL = 0.

    IF  KEY-FUNCTION(LASTKEY) = "D"                           AND
        Btn_D:SENSITIVE IN FRAME f_cartao_agen_transf_mensal  THEN
        DO:
            APPLY "CHOOSE" TO Btn_D.

            IF  RETURN-VALUE = "OK"  THEN
                DO:
                    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
                    RETURN "OK".
                END.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "G"                           AND
        Btn_G:SENSITIVE IN FRAME f_cartao_agen_transf_mensal  THEN
        APPLY "CHOOSE" TO Btn_G.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                           AND
        Btn_H:SENSITIVE IN FRAME f_cartao_agen_transf_mensal  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_cartao_agen_transf_mensal:INTERVAL = glb_nrtempor.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

