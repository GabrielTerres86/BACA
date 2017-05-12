&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_cartao_data_agendamento_recarg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_cartao_data_agendamento_recarg 
/* ..............................................................................

Procedure: cartao_data_agendamento_recarga.w
Objetivo : Tela para apresentar resumo da opera�ao e definir data para recarga
Autor    : Lucas Reinert
Data     : Fevereiro/2017
Ultima altera��o: 
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

/* Parameters Definitions --                                           */
DEFINE INPUT PARAMETER par_nrdddcel AS INTEGER                  NO-UNDO.
DEFINE INPUT PARAMETER par_nrcelula AS DECIMAL                  NO-UNDO.
DEFINE INPUT PARAMETER par_cdoperadora AS INTEGER               NO-UNDO.
DEFINE INPUT PARAMETER par_nmoperadora AS CHAR                  NO-UNDO.
DEFINE INPUT PARAMETER par_cdproduto AS INTEGER                 NO-UNDO.
DEFINE INPUT PARAMETER par_vlrecarga AS DECIMAL                 NO-UNDO.

/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }

DEFINE VARIABLE aux_flgderro        AS LOGICAL                  NO-UNDO.
DEFINE VARIABLE aux_flgretur        AS LOGICAL                  NO-UNDO.
DEFINE VARIABLE aux_dtrecarga       AS DATE                     NO-UNDO.
DEFINE VARIABLE aux_lsdatagd        AS CHAR                     NO-UNDO.
DEFINE VARIABLE aux_idastcjt        AS INTE                     NO-UNDO.
DEFINE VARIABLE aux_dsprotoc        AS CHAR                     NO-UNDO.
DEFINE VARIABLE aux_dsnsuope        AS CHAR                     NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_data_agendamento_recarga

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-37 IMAGE-40 RECT-3 RECT-4 RECT-7 ~
RECT-8 IMAGE-49 RECT-5 RECT-6 RECT-11 ed_nmoperadora ed_nr_doddd ~
ed_nrdofone ed_vlrecarga ed_ddrecarga ed_mmrecarga ed_inirecarga Btn_G ~
Btn_D Btn_H 
&Scoped-Define DISPLAYED-OBJECTS ed_nmoperadora ed_nr_doddd ed_nrdofone ~
ed_vlrecarga ed_ddrecarga ed_mmrecarga ed_inirecarga 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_cartao_data_agendamento_recarg AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_D 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_G 
     LABEL "CORRIGIR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_H 
     LABEL "CONTINUAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_ddrecarga AS INTEGER FORMAT "z9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 11.2 BY 2.14
     FONT 13 NO-UNDO.

DEFINE VARIABLE ed_inirecarga AS CHARACTER FORMAT "xx/xxxx":U 
     VIEW-AS FILL-IN 
     SIZE 33 BY 2.14
     FONT 13 NO-UNDO.

DEFINE VARIABLE ed_mmrecarga AS INTEGER FORMAT "z9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 11.2 BY 2.14
     FONT 13 NO-UNDO.

DEFINE VARIABLE ed_nmoperadora AS CHARACTER FORMAT "X(20)":U 
     VIEW-AS FILL-IN 
     SIZE 49.2 BY 2.14
     FONT 13 NO-UNDO.

DEFINE VARIABLE ed_nrdofone AS CHARACTER FORMAT "XXXXX-XXXX":U 
     VIEW-AS FILL-IN 
     SIZE 49.2 BY 2.14
     FONT 13 NO-UNDO.

DEFINE VARIABLE ed_nr_doddd AS CHARACTER FORMAT "99":U 
     VIEW-AS FILL-IN 
     SIZE 11.2 BY 2.14
     FONT 13 NO-UNDO.

DEFINE VARIABLE ed_vlrecarga AS DECIMAL FORMAT ">>,>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 49.2 BY 2.14
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

DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 4 GRAPHIC-EDGE  NO-FILL   
     SIZE 35 BY 2.62.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 4 GRAPHIC-EDGE  NO-FILL   
     SIZE 13.2 BY 2.62.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 4 GRAPHIC-EDGE  NO-FILL   
     SIZE 51.4 BY 2.62.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 4 GRAPHIC-EDGE  NO-FILL   
     SIZE 13.2 BY 2.62.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 4 GRAPHIC-EDGE  NO-FILL   
     SIZE 13.2 BY 2.62.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 4 GRAPHIC-EDGE  NO-FILL   
     SIZE 51.4 BY 2.62.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 4 GRAPHIC-EDGE  NO-FILL   
     SIZE 51.4 BY 2.62.

DEFINE RECTANGLE RECT-98
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 14 .

DEFINE RECTANGLE RECT-99
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 123 BY .29
     BGCOLOR 14 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_data_agendamento_recarga
     ed_nmoperadora AT ROW 7.1 COL 66.6 COLON-ALIGNED NO-LABEL WIDGET-ID 260
     ed_nr_doddd AT ROW 10.1 COL 66.6 COLON-ALIGNED NO-LABEL WIDGET-ID 142
     ed_nrdofone AT ROW 10.1 COL 84.8 COLON-ALIGNED NO-LABEL WIDGET-ID 146
     ed_vlrecarga AT ROW 13.1 COL 66.6 COLON-ALIGNED NO-LABEL WIDGET-ID 266
     ed_ddrecarga AT ROW 16.1 COL 29.6 COLON-ALIGNED NO-LABEL WIDGET-ID 276
     ed_mmrecarga AT ROW 16.1 COL 93.6 COLON-ALIGNED NO-LABEL WIDGET-ID 282
     ed_inirecarga AT ROW 19.1 COL 29.6 COLON-ALIGNED NO-LABEL WIDGET-ID 294
     Btn_G AT ROW 19.14 COL 94.4 WIDGET-ID 86
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 66
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 74
     "RECARGA DE CELULAR" VIEW-AS TEXT
          SIZE 122 BY 2.14 AT ROW 2.43 COL 29.6 WIDGET-ID 226
          FGCOLOR 1 FONT 10
     "VALOR:" VIEW-AS TEXT
          SIZE 17 BY 2.38 AT ROW 13 COL 63.8 RIGHT-ALIGNED WIDGET-ID 264
          FONT 8
     "meses" VIEW-AS TEXT
          SIZE 14 BY 2.38 AT ROW 16 COL 122.6 RIGHT-ALIGNED WIDGET-ID 286
          FONT 8
     "Iniciar em:" VIEW-AS TEXT
          SIZE 21 BY 2.38 AT ROW 19 COL 27.6 RIGHT-ALIGNED WIDGET-ID 288
          FONT 8
     "OPERADORA:" VIEW-AS TEXT
          SIZE 32 BY 2.38 AT ROW 7 COL 63.8 RIGHT-ALIGNED WIDGET-ID 246
          FONT 8
     "-" VIEW-AS TEXT
          SIZE 5 BY 2.62 AT ROW 9.86 COL 80.6 WIDGET-ID 242
          FONT 13
     "DDD/TELEFONE:" VIEW-AS TEXT
          SIZE 39 BY 2.38 AT ROW 10 COL 63.8 RIGHT-ALIGNED WIDGET-ID 238
          FONT 8
     "de cada m�s, durante" VIEW-AS TEXT
          SIZE 48 BY 2.38 AT ROW 16 COL 93.6 RIGHT-ALIGNED WIDGET-ID 280
          FONT 8
     "(M�s/Ano)" VIEW-AS TEXT
          SIZE 23.2 BY 2.38 AT ROW 19 COL 89 RIGHT-ALIGNED WIDGET-ID 298
          FONT 8
     "No dia" VIEW-AS TEXT
          SIZE 14 BY 2.38 AT ROW 16 COL 27.6 RIGHT-ALIGNED WIDGET-ID 270
          FONT 8
     IMAGE-37 AT ROW 24.29 COL 1 WIDGET-ID 148
     IMAGE-40 AT ROW 24.29 COL 156 WIDGET-ID 154
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     RECT-3 AT ROW 9.86 COL 67.6 WIDGET-ID 136
     RECT-4 AT ROW 9.86 COL 85.8 WIDGET-ID 138
     RECT-7 AT ROW 6.86 COL 67.6 WIDGET-ID 262
     RECT-8 AT ROW 12.86 COL 67.6 WIDGET-ID 268
     IMAGE-49 AT ROW 19.29 COL 156 WIDGET-ID 156
     RECT-5 AT ROW 15.86 COL 30.6 WIDGET-ID 278
     RECT-6 AT ROW 15.86 COL 94.6 WIDGET-ID 284
     RECT-11 AT ROW 18.86 COL 30.6 WIDGET-ID 296
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
  CREATE WINDOW w_cartao_data_agendamento_recarg ASSIGN
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
ASSIGN w_cartao_data_agendamento_recarg = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_cartao_data_agendamento_recarg
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_data_agendamento_recarga
   FRAME-NAME                                                           */
ASSIGN 
       ed_nmoperadora:READ-ONLY IN FRAME f_data_agendamento_recarga        = TRUE.

ASSIGN 
       ed_nrdofone:READ-ONLY IN FRAME f_data_agendamento_recarga        = TRUE.

ASSIGN 
       ed_nr_doddd:READ-ONLY IN FRAME f_data_agendamento_recarga        = TRUE.

ASSIGN 
       ed_vlrecarga:READ-ONLY IN FRAME f_data_agendamento_recarga        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_data_agendamento_recarga
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_data_agendamento_recarga
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_data_agendamento_recarga
   NO-ENABLE                                                            */
/* SETTINGS FOR TEXT-LITERAL "OPERADORA:"
          SIZE 32 BY 2.38 AT ROW 7 COL 63.8 RIGHT-ALIGNED               */

/* SETTINGS FOR TEXT-LITERAL "DDD/TELEFONE:"
          SIZE 39 BY 2.38 AT ROW 10 COL 63.8 RIGHT-ALIGNED              */

/* SETTINGS FOR TEXT-LITERAL "VALOR:"
          SIZE 17 BY 2.38 AT ROW 13 COL 63.8 RIGHT-ALIGNED              */

/* SETTINGS FOR TEXT-LITERAL "No dia"
          SIZE 14 BY 2.38 AT ROW 16 COL 27.6 RIGHT-ALIGNED              */

/* SETTINGS FOR TEXT-LITERAL "de cada m�s, durante"
          SIZE 48 BY 2.38 AT ROW 16 COL 93.6 RIGHT-ALIGNED              */

/* SETTINGS FOR TEXT-LITERAL "meses"
          SIZE 14 BY 2.38 AT ROW 16 COL 122.6 RIGHT-ALIGNED             */

/* SETTINGS FOR TEXT-LITERAL "Iniciar em:"
          SIZE 21 BY 2.38 AT ROW 19 COL 27.6 RIGHT-ALIGNED              */

/* SETTINGS FOR TEXT-LITERAL "(M�s/Ano)"
          SIZE 23.2 BY 2.38 AT ROW 19 COL 89 RIGHT-ALIGNED              */

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_data_agendamento_recarga:HANDLE
       ROW             = 1.95
       COLUMN          = 5
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_data_agendamento_recarga */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_cartao_data_agendamento_recarg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_data_agendamento_recarg w_cartao_data_agendamento_recarg
ON END-ERROR OF w_cartao_data_agendamento_recarg
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_data_agendamento_recarg w_cartao_data_agendamento_recarg
ON WINDOW-CLOSE OF w_cartao_data_agendamento_recarg
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_data_agendamento_recarg
ON ANY-KEY OF Btn_D IN FRAME f_data_agendamento_recarga /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_data_agendamento_recarg
ON CHOOSE OF Btn_D IN FRAME f_data_agendamento_recarga /* VOLTAR */
DO:        
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_G
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_cartao_data_agendamento_recarg
ON ANY-KEY OF Btn_G IN FRAME f_data_agendamento_recarga /* CORRIGIR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_cartao_data_agendamento_recarg
ON CHOOSE OF Btn_G IN FRAME f_data_agendamento_recarga /* CORRIGIR */
DO:
    ASSIGN ed_ddrecarga:SCREEN-VALUE IN FRAME f_data_agendamento_recarga = ""
           ed_mmrecarga:SCREEN-VALUE IN FRAME f_data_agendamento_recarga = ""
           ed_inirecarga:SCREEN-VALUE IN FRAME f_data_agendamento_recarga = "".

    APPLY "ENTRY" TO ed_ddrecarga.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_data_agendamento_recarg
ON ANY-KEY OF Btn_H IN FRAME f_data_agendamento_recarga /* CONTINUAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_data_agendamento_recarg
ON CHOOSE OF Btn_H IN FRAME f_data_agendamento_recarga /* CONTINUAR */
DO:
    /* ---------- */
    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).
    
    IF  aux_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.

    ASSIGN aux_dtrecarga = DATE(ed_ddrecarga:SCREEN-VALUE + "/" + ed_inirecarga:SCREEN-VALUE) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
            RUN mensagem.w (INPUT YES,
                                INPUT "    Aten��o!",
                                INPUT "",
                                INPUT "Data inv�lida.",
                                INPUT "",
                                INPUT "",
                                INPUT "").
            
            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.
        
            aux_flgderro = YES.

            RETURN NO-APPLY.
        END.
    ELSE
        IF  aux_dtrecarga < TODAY THEN
            DO:
                RUN mensagem.w (INPUT YES,
                                INPUT "    Aten��o!",
                                INPUT "",
                                INPUT "A data deve ser superior",
                                INPUT "a data atual.",
                                INPUT "",
                                INPUT "").
            
                PAUSE 3 NO-MESSAGE.
                h_mensagem:HIDDEN = YES.
            
                aux_flgderro = YES.

                RETURN NO-APPLY.
            END.
    ELSE
    IF  INT(ed_ddrecarga:SCREEN-VALUE) = 0  THEN
        DO:    
            RUN mensagem.w (INPUT YES,
                            INPUT "    Aten��o!",
                            INPUT "",
                            INPUT "",
                            INPUT "O dia deve ser informado.",
                            INPUT "",
                            INPUT "").
   
            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.
   
            aux_flgderro = YES.

            RETURN NO-APPLY.
        END.
    ELSE
    IF  INT(ed_mmrecarga:SCREEN-VALUE) = 0  THEN
        DO:    
            RUN mensagem.w (INPUT YES,
                            INPUT "    Aten��o!",
                            INPUT "",
                            INPUT "",
                            INPUT "O m�s deve ser informado.",
                            INPUT "",
                            INPUT "").

            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.
   
            aux_flgderro = YES.

            RETURN NO-APPLY.
        END.
    ELSE
    IF  ed_inirecarga:SCREEN-VALUE = ""  THEN
        DO:    
            RUN mensagem.w (INPUT YES,
                            INPUT "    Aten��o!",
                            INPUT "",
                            INPUT "",
                            INPUT "O per�odo inicial deve",
                            INPUT "ser informado.",
                            INPUT "").
   
            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.
   
            aux_flgderro = YES.

            RETURN NO-APPLY.
        END.

  RUN procedures/verifica_recarga.p (INPUT par_nrdddcel 
                                    ,INPUT par_nrcelula 
                                    ,INPUT aux_dtrecarga
                                    ,INPUT INT(ed_mmrecarga:SCREEN-VALUE)
                                    ,INPUT 3
                                    ,OUTPUT aux_flgderro
                                    ,OUTPUT aux_lsdatagd
                                    ,OUTPUT aux_flgretur).

  IF NOT aux_flgderro THEN
     DO:  
       /* para quem nao tem letras, pede cpf */
       IF NOT glb_idsenlet THEN
           RUN senha_cpf.w (OUTPUT aux_flgderro).
       ELSE
           RUN senha.w (OUTPUT aux_flgderro).     

       IF NOT aux_flgderro THEN
          DO:
            /* puxa o frame principal */
            h_principal:MOVE-TO-TOP().

            RUN procedures/efetua_recarga.p (INPUT par_cdoperadora
                                            ,INPUT par_cdproduto
                                            ,INPUT par_nrdddcel 
                                            ,INPUT par_nrcelula 
                                            ,INPUT aux_dtrecarga
                                            ,INPUT par_vlrecarga
                                            ,INPUT aux_lsdatagd
                                            ,INPUT 3
                                           ,OUTPUT aux_flgderro
                                           ,OUTPUT aux_idastcjt
                                           ,OUTPUT aux_dsprotoc
                                           ,OUTPUT aux_dsnsuope).

            IF NOT aux_flgderro THEN
               DO: 
                 RUN procedures/inicializa_dispositivo.p ( INPUT 6,
                                                           OUTPUT aux_flgderro).
                 /* se recarga efetuada com sucesso e nao exigir assinatura conjunta */
                 IF aux_idastcjt = 0 THEN
                    RUN imprime_comprovante.
                 ELSE
                    DO:                 
                        APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                        RETURN "OK".
                    END.
               END.
            ELSE /* Erro na rotina */
               DO:
                 APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
                 RETURN "OK".
               END.
         END.                                         
     END.   
     
  IF aux_flgretur THEN
     DO:
       /* puxa o frame principal */
       h_principal:MOVE-TO-TOP().

       APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
       RETURN "OK".
     END.
     

  /* repassa o retorno */
  RETURN RETURN-VALUE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_ddrecarga
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_ddrecarga w_cartao_data_agendamento_recarg
ON ANY-KEY OF ed_ddrecarga IN FRAME f_data_agendamento_recarga
DO:
    RUN tecla.

    IF  CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))  THEN
        DO:
            /* limite de caracteres */
            IF  LENGTH(ed_ddrecarga:SCREEN-VALUE) > 3  THEN
                RETURN NO-APPLY.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            ed_ddrecarga:SCREEN-VALUE = "".
            RETURN NO-APPLY.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:

            APPLY "ENTRY" TO ed_mmrecarga.
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


&Scoped-define SELF-NAME ed_inirecarga
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_inirecarga w_cartao_data_agendamento_recarg
ON ANY-KEY OF ed_inirecarga IN FRAME f_data_agendamento_recarga
DO:
    RUN tecla.

    IF  CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))  THEN
        DO:
            /* limite de caracteres */
            IF  LENGTH(ed_inirecarga:SCREEN-VALUE) > 7  THEN
                RETURN NO-APPLY.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            ed_inirecarga:SCREEN-VALUE = "".
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


&Scoped-define SELF-NAME ed_mmrecarga
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_mmrecarga w_cartao_data_agendamento_recarg
ON ANY-KEY OF ed_mmrecarga IN FRAME f_data_agendamento_recarga
DO:
    RUN tecla.
      IF  CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))  THEN
        DO:
            /* limite de caracteres */
            IF  LENGTH(ed_mmrecarga:SCREEN-VALUE) > 3  THEN
                RETURN NO-APPLY.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            ed_mmrecarga:SCREEN-VALUE = "".
            RETURN NO-APPLY.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:

            APPLY "ENTRY" TO ed_inirecarga.
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


&Scoped-define SELF-NAME ed_nmoperadora
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nmoperadora w_cartao_data_agendamento_recarg
ON ANY-KEY OF ed_nmoperadora IN FRAME f_data_agendamento_recarga
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_nrdofone
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nrdofone w_cartao_data_agendamento_recarg
ON ANY-KEY OF ed_nrdofone IN FRAME f_data_agendamento_recarga
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_nr_doddd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nr_doddd w_cartao_data_agendamento_recarg
ON ANY-KEY OF ed_nr_doddd IN FRAME f_data_agendamento_recarga
DO:
    RUN tecla.

    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN DO:
        IF  LENGTH(ed_nr_doddd:SCREEN-VALUE) < 2 THEN DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "    ATEN��O  ",
                            INPUT "",
                            INPUT "",
                            INPUT "DDD inv�lido.",
                            INPUT "",
                            INPUT "").

            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.

            APPLY "ENTRY" TO ed_nr_doddd.
            RETURN NO-APPLY.
        END.
        ELSE DO:
            APPLY "ENTRY" TO ed_nrdofone.
            RETURN NO-APPLY.
        END.
    END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
        DO:
            RUN limpa.
            RETURN NO-APPLY.
        END.
    ELSE
    /* se n�o foram digitados n�meros, despreza */
    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))  THEN
        DO:
            /* se escolheu os botoes, repassa o retorno */
            IF  RETURN-VALUE <> "" THEN
                RETURN RETURN-VALUE.
            ELSE
                /* senao somente despreza a tecla */
                RETURN NO-APPLY.
        END.        
      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_vlrecarga
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_vlrecarga w_cartao_data_agendamento_recarg
ON ANY-KEY OF ed_vlrecarga IN FRAME f_data_agendamento_recarga
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_cartao_data_agendamento_recarg OCX.Tick
PROCEDURE temporizador.t_cartao_data_agendamento_recarga.Tick .
APPLY "CHOOSE" TO Btn_D IN FRAME f_data_agendamento_recarga.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_cartao_data_agendamento_recarg 


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
    
    ASSIGN ed_nmoperadora:SCREEN-VALUE IN FRAME f_data_agendamento_recarga = par_nmoperadora
           ed_nr_doddd:SCREEN-VALUE IN FRAME f_data_agendamento_recarga = STRING(par_nrdddcel, "99")
           ed_nrdofone:SCREEN-VALUE IN FRAME f_data_agendamento_recarga = STRING(par_nrcelula)
           ed_vlrecarga:SCREEN-VALUE IN FRAME f_data_agendamento_recarga = STRING(par_vlrecarga).

    APPLY "ENTRY" TO ed_ddrecarga.

    /* deixa o mouse transparente */
    FRAME f_data_agendamento_recarga:LOAD-MOUSE-POINTER("blank.cur").
    
    chtemporizador:t_cartao_data_agendamento_recarga:INTERVAL = glb_nrtempor.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_cartao_data_agendamento_recarg  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_data_agendamento_recarga.wrx":U ).
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
ELSE MESSAGE "cartao_data_agendamento_recarga.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_cartao_data_agendamento_recarg  _DEFAULT-DISABLE
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
  HIDE FRAME f_data_agendamento_recarga.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_cartao_data_agendamento_recarg  _DEFAULT-ENABLE
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
  DISPLAY ed_nmoperadora ed_nr_doddd ed_nrdofone ed_vlrecarga ed_ddrecarga 
          ed_mmrecarga ed_inirecarga 
      WITH FRAME f_data_agendamento_recarga.
  ENABLE IMAGE-37 IMAGE-40 RECT-3 RECT-4 RECT-7 RECT-8 IMAGE-49 RECT-5 RECT-6 
         RECT-11 ed_nmoperadora ed_nr_doddd ed_nrdofone ed_vlrecarga 
         ed_ddrecarga ed_mmrecarga ed_inirecarga Btn_G Btn_D Btn_H 
      WITH FRAME f_data_agendamento_recarga.
  {&OPEN-BROWSERS-IN-QUERY-f_data_agendamento_recarga}
  VIEW w_cartao_data_agendamento_recarg.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE imprime_comprovante w_cartao_data_agendamento_recarg 
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

/* centraliza o cabe�alho */
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
                      "         COMPROVANTE DE AGENDAMENTO DE          " +
                      "              RECARGA DE CELULAR                "
       tmp_tximpres = tmp_tximpres +
                      "                                                " + 
                      "CONTA: " + STRING(glb_nrdconta,"zzzz,zzz,9")      +
                          " - " + STRING(glb_nmtitula[1],"x(28)") +
                      "                                                " +
                      "    DATA DO AGENDAMENTO:                        " +
                      "                                                " +
                      "     NO DIA " + STRING(ed_ddrecarga:SCREEN-VALUE IN FRAME f_data_agendamento_recarga, "XX") +
                      " DE CADA MES, DURANTE " + STRING(ed_mmrecarga:SCREEN-VALUE IN FRAME f_data_agendamento_recarga, "XX") +
                      " MESES,   " +
                      "     INICIANDO EM " + STRING(ed_inirecarga:SCREEN-VALUE IN FRAME f_data_agendamento_recarga, "XXXXXXX") +
                      "                       " +
                      "                                                " +
                      "                  VALOR: " + STRING(par_vlrecarga, "zzz,zz9.99") +
                      "             " +
                      "              OPERADORA: " + STRING(par_nmoperadora, "x(23)") +
                      "           DDD/TELEFONE: (" + STRING(par_nrdddcel, "99") + ")" +
                      STRING(STRING(par_nrcelula), "XXXXX-XXXX") + 
                      "         " + 
                      "                                                " + 
                      "                                                " +
                      " * A RESPONSABILIDADE DOS DADOS INFORMADOS E DO " +
                      "   COOPERADO;                                   " +
                      " * TRANSACAO ACEITA MEDIANTE SALDO EM CONTA     " +
                      "   CORRENTE;                                    " +
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

        RUN impressao_visualiza.w (INPUT "Comprovante...",
                                   INPUT  tmp_tximpres,
                                   INPUT 0, /*Comprovante*/
                                   INPUT "").

        APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
        RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_cartao_data_agendamento_recarg 
PROCEDURE tecla :
chtemporizador:t_cartao_data_agendamento_recarga:INTERVAL = 0.
 
    IF  KEY-FUNCTION(LASTKEY) = "D"                    AND    /* Voltar*/
        Btn_D:SENSITIVE IN FRAME f_data_agendamento_recarga  THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "G"                    AND    /* Continuar*/
        Btn_G:SENSITIVE IN FRAME f_data_agendamento_recarga  THEN
        APPLY "CHOOSE" TO Btn_G.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                    AND    /* Continuar*/
        Btn_H:SENSITIVE IN FRAME f_data_agendamento_recarga  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        DO:
            chtemporizador:t_cartao_data_agendamento_recarga:INTERVAL = glb_nrtempor.
            RETURN NO-APPLY.
        END.

    chtemporizador:t_cartao_data_agendamento_recarga:INTERVAL = glb_nrtempor.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            /* joga o frame frente */
            FRAME f_data_agendamento_recarga:MOVE-TO-TOP().

            APPLY "ENTRY" TO Btn_D.
        END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

