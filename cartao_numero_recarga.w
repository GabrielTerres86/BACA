&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_cartao_numero_recarga
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_cartao_numero_recarga 
/* ..............................................................................

Procedure: cartao_numero_recarga.w
Objetivo : Tela para informar o numero de celular para recarga
Autor    : Lucas Reinert
Data     : Fevereiro/2017
Ultima alteração: 
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

DEFINE VARIABLE aux_flgderro        AS LOGICAL                  NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_numero_recarga

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-37 IMAGE-40 RECT-3 RECT-4 RECT-5 ~
RECT-6 ed_nr_doddd ed_nrdofone ed_nr_doddd2 ed_nrdofone2 Btn_D Btn_H 
&Scoped-Define DISPLAYED-OBJECTS ed_nr_doddd ed_nrdofone ed_nr_doddd2 ~
ed_nrdofone2 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_cartao_numero_recarga AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_D 
     LABEL "VOLTAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_H 
     LABEL "CONTINUAR" 
     SIZE 61 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_nrdofone AS CHARACTER FORMAT "XXXXX-XXXX":U 
     VIEW-AS FILL-IN 
     SIZE 49.2 BY 2.14
     FGCOLOR 0 FONT 13 NO-UNDO.

DEFINE VARIABLE ed_nrdofone2 AS CHARACTER FORMAT "XXXXX-XXXX":U 
     VIEW-AS FILL-IN 
     SIZE 49.2 BY 2.14
     FGCOLOR 0 FONT 13 NO-UNDO.

DEFINE VARIABLE ed_nr_doddd AS CHARACTER FORMAT "XX":U 
     VIEW-AS FILL-IN 
     SIZE 11.2 BY 2.14
     FGCOLOR 0 FONT 13 NO-UNDO.

DEFINE VARIABLE ed_nr_doddd2 AS CHARACTER FORMAT "XX":U 
     VIEW-AS FILL-IN 
     SIZE 11.2 BY 2.14
     FGCOLOR 0 FONT 13 NO-UNDO.

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

DEFINE FRAME f_numero_recarga
     ed_nr_doddd AT ROW 11.29 COL 70.8 COLON-ALIGNED NO-LABEL WIDGET-ID 142
     ed_nrdofone AT ROW 11.29 COL 89 COLON-ALIGNED NO-LABEL WIDGET-ID 146
     ed_nr_doddd2 AT ROW 16.29 COL 70.8 COLON-ALIGNED NO-LABEL WIDGET-ID 250
     ed_nrdofone2 AT ROW 16.29 COL 89 COLON-ALIGNED NO-LABEL WIDGET-ID 256
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 66
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 74
     "CONFIRME" VIEW-AS TEXT
          SIZE 36 BY 2.38 AT ROW 14.24 COL 57 RIGHT-ALIGNED WIDGET-ID 258
          FGCOLOR 0 FONT 13
     "-" VIEW-AS TEXT
          SIZE 5 BY 2.62 AT ROW 11.05 COL 84.8 WIDGET-ID 242
          FGCOLOR 0 FONT 13
     "DDD/TELEFONE:" VIEW-AS TEXT
          SIZE 56 BY 2.38 AT ROW 11.19 COL 68 RIGHT-ALIGNED WIDGET-ID 238
          FGCOLOR 0 FONT 13
     "-" VIEW-AS TEXT
          SIZE 5 BY 2.62 AT ROW 16.05 COL 84.8 WIDGET-ID 252
          FGCOLOR 0 FONT 13
     "RECARGA DE CELULAR" VIEW-AS TEXT
          SIZE 122 BY 2.14 AT ROW 2.43 COL 29.6 WIDGET-ID 226
          FGCOLOR 1 FONT 10
     "DDD/TELEFONE:" VIEW-AS TEXT
          SIZE 56 BY 2.38 AT ROW 16.19 COL 68 RIGHT-ALIGNED WIDGET-ID 246
          FGCOLOR 0 FONT 13
     IMAGE-37 AT ROW 24.29 COL 1 WIDGET-ID 148
     IMAGE-40 AT ROW 24.29 COL 156 WIDGET-ID 154
     RECT-98 AT ROW 5.05 COL 19.6 WIDGET-ID 118
     RECT-99 AT ROW 5.52 COL 19.6 WIDGET-ID 120
     RECT-100 AT ROW 5.29 COL 19.6 WIDGET-ID 116
     RECT-3 AT ROW 11.05 COL 71.8 WIDGET-ID 136
     RECT-4 AT ROW 11.05 COL 90 WIDGET-ID 138
     RECT-5 AT ROW 16.05 COL 71.8 WIDGET-ID 248
     RECT-6 AT ROW 16.05 COL 90 WIDGET-ID 254
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
  CREATE WINDOW w_cartao_numero_recarga ASSIGN
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
ASSIGN w_cartao_numero_recarga = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_cartao_numero_recarga
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_numero_recarga
   FRAME-NAME                                                           */
/* SETTINGS FOR RECTANGLE RECT-100 IN FRAME f_numero_recarga
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-98 IN FRAME f_numero_recarga
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-99 IN FRAME f_numero_recarga
   NO-ENABLE                                                            */
/* SETTINGS FOR TEXT-LITERAL "DDD/TELEFONE:"
          SIZE 56 BY 2.38 AT ROW 11.19 COL 68 RIGHT-ALIGNED             */

/* SETTINGS FOR TEXT-LITERAL "CONFIRME"
          SIZE 36 BY 2.38 AT ROW 14.24 COL 57 RIGHT-ALIGNED             */

/* SETTINGS FOR TEXT-LITERAL "DDD/TELEFONE:"
          SIZE 56 BY 2.38 AT ROW 16.19 COL 68 RIGHT-ALIGNED             */

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_numero_recarga:HANDLE
       ROW             = 1.95
       COLUMN          = 5
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_cartao_numero_recarga */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_cartao_numero_recarga
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_numero_recarga w_cartao_numero_recarga
ON END-ERROR OF w_cartao_numero_recarga
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_cartao_numero_recarga w_cartao_numero_recarga
ON WINDOW-CLOSE OF w_cartao_numero_recarga
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_numero_recarga
ON ANY-KEY OF Btn_D IN FRAME f_numero_recarga /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_cartao_numero_recarga
ON CHOOSE OF Btn_D IN FRAME f_numero_recarga /* VOLTAR */
DO:        
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_numero_recarga
ON ANY-KEY OF Btn_H IN FRAME f_numero_recarga /* CONTINUAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_cartao_numero_recarga
ON CHOOSE OF Btn_H IN FRAME f_numero_recarga /* CONTINUAR */
DO:
  IF  ed_nr_doddd:INPUT-VALUE = "" OR
      ed_nrdofone:INPUT-VALUE = "" THEN
      DO:
         IF ed_nr_doddd:INPUT-VALUE <> "" AND 
            LENGTH(ed_nr_doddd:INPUT-VALUE) < 2 THEN
            DO:
               RUN mensagem.w (INPUT YES,
                               INPUT "    ATENÇÃO  ",
                               INPUT "",
                               INPUT "",
                               INPUT "DDD inválido.",
                               INPUT "",
                               INPUT "").

               PAUSE 3 NO-MESSAGE.
               h_mensagem:HIDDEN = YES.

               APPLY "ENTRY" TO ed_nr_doddd.
            END.
         ELSE
            DO:
               RUN mensagem.w (INPUT YES,
                               INPUT "    ATENÇÃO  ",
                               INPUT "",
                               INPUT "",
                               INPUT "Informe o DDD/Telefone.",
                               INPUT "",
                               INPUT "").
                
               PAUSE 3 NO-MESSAGE.
               h_mensagem:HIDDEN = YES.
                
               APPLY "ENTRY" TO ed_nr_doddd.

            END.
      END.
  ELSE
  IF  LENGTH(ed_nr_doddd:INPUT-VALUE) < 2 THEN
      DO:
        RUN mensagem.w (INPUT YES,
                        INPUT "    ATENÇÃO  ",
                        INPUT "",
                        INPUT "",
                        INPUT "DDD inválido.",
                        INPUT "",
                        INPUT "").
    
        PAUSE 3 NO-MESSAGE.
        h_mensagem:HIDDEN = YES.
    
        APPLY "ENTRY" TO ed_nr_doddd.

      END.
  ELSE
  IF  LENGTH(ed_nrdofone:INPUT-VALUE) < 9 THEN 
      DO:
        RUN mensagem.w (INPUT YES,
                        INPUT "    ATENÇÃO  ",
                        INPUT "",
                        INPUT "",
                        INPUT "Telefone inválido.",
                        INPUT "",
                        INPUT "").

        PAUSE 3 NO-MESSAGE.
        h_mensagem:HIDDEN = YES.

        APPLY "ENTRY" TO ed_nrdofone.

      END.
  ELSE
  IF  ed_nr_doddd2:INPUT-VALUE = "" OR
      ed_nrdofone2:INPUT-VALUE = ""  THEN
      DO:
         IF ed_nr_doddd2:INPUT-VALUE <> "" AND 
            LENGTH(ed_nr_doddd2:INPUT-VALUE) < 2 THEN
            DO:
               RUN mensagem.w (INPUT YES,
                               INPUT "    ATENÇÃO  ",
                               INPUT "",
                               INPUT "",
                               INPUT "DDD inválido.",
                               INPUT "",
                               INPUT "").

               PAUSE 3 NO-MESSAGE.
               h_mensagem:HIDDEN = YES.
            
               APPLY "ENTRY" TO ed_nr_doddd2.
            END.
         ELSE
            DO:
                RUN mensagem.w (INPUT YES,
                                INPUT "    ATENÇÃO  ",
                                INPUT "",
                                INPUT "",
                                INPUT "Confirme o DDD/Telefone.",
                                INPUT "",
                                INPUT "").
                
                PAUSE 3 NO-MESSAGE.
                h_mensagem:HIDDEN = YES.

                APPLY "ENTRY" TO ed_nr_doddd2.
            END.
      END.
  ELSE
  IF  LENGTH(ed_nr_doddd2:INPUT-VALUE) < 2 THEN 
      DO:
        RUN mensagem.w (INPUT YES,
                        INPUT "    ATENÇÃO  ",
                        INPUT "",
                        INPUT "",
                        INPUT "DDD inválido.",
                        INPUT "",
                        INPUT "").

        PAUSE 3 NO-MESSAGE.
        h_mensagem:HIDDEN = YES.

        APPLY "ENTRY" TO ed_nr_doddd2.
      END.
  ELSE
  IF  LENGTH(ed_nrdofone2:INPUT-VALUE) < 9 THEN 
      DO:
          RUN mensagem.w (INPUT YES,
                          INPUT "    ATENÇÃO  ",
                          INPUT "",
                          INPUT "",
                          INPUT "Telefone inválido.",
                          INPUT "",
                          INPUT "").
        
          PAUSE 3 NO-MESSAGE.
          h_mensagem:HIDDEN = YES.
          
          APPLY "ENTRY" TO ed_nrdofone2.
      END.
  ELSE
  IF  ed_nr_doddd:INPUT-VALUE <> ed_nr_doddd2:INPUT-VALUE OR 
      ed_nrdofone:INPUT-VALUE <> ed_nrdofone2:INPUT-VALUE THEN
      DO:
         RUN mensagem.w (INPUT YES,
                         INPUT "    ATENÇÃO  ",
                         INPUT "",
                         INPUT "",
                         INPUT "Telefones não conferem.",
                         INPUT "",
                         INPUT "").
        
         PAUSE 3 NO-MESSAGE.
         h_mensagem:HIDDEN = YES.
        
         RUN limpa.
      END.
  ELSE 
      DO:
          RUN cartao_operadora_recarga.w(INPUT ed_nr_doddd:INPUT-VALUE
                                        ,INPUT ed_nrdofone:INPUT-VALUE).
                                        
          IF RETURN-VALUE = "OK" THEN
            DO:
              APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
              RETURN "OK".
            END.

      END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_nrdofone
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nrdofone w_cartao_numero_recarga
ON ANY-KEY OF ed_nrdofone IN FRAME f_numero_recarga
DO:
    RUN tecla.

    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN 
        DO:
           IF  LENGTH(ed_nrdofone:SCREEN-VALUE) < 10 THEN 
               DO:
                   RUN mensagem.w (INPUT YES,
                                   INPUT "    ATENÇÃO  ",
                                   INPUT "",
                                   INPUT "",
                                   INPUT "Telefone inválido.",
                                   INPUT "",
                                   INPUT "").
                
                   PAUSE 3 NO-MESSAGE.
                   h_mensagem:HIDDEN = YES.
                
                   APPLY "ENTRY" TO ed_nrdofone.
                   RETURN NO-APPLY.
               END.
           ELSE 
               DO:
                    APPLY "ENTRY" TO ed_nr_doddd2.
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
    /* se não foram digitados números, despreza */
    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))  THEN
        DO:
            /* se escolheu os botoes, repassa o retorno */
            IF  RETURN-VALUE <> ""  THEN
                RETURN RETURN-VALUE.
            ELSE
                /* senao somente despreza a tecla */
                RETURN NO-APPLY.
        END.        
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nrdofone w_cartao_numero_recarga
ON VALUE-CHANGED OF ed_nrdofone IN FRAME f_numero_recarga
DO:
    IF  LENGTH(ed_nrdofone:SCREEN-VALUE) = 10 THEN DO:
      APPLY "ENTRY" TO ed_nr_doddd2.
      RETURN NO-APPLY.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_nrdofone2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nrdofone2 w_cartao_numero_recarga
ON ANY-KEY OF ed_nrdofone2 IN FRAME f_numero_recarga
DO:
    RUN tecla.

    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
           IF  LENGTH(ed_nrdofone2:SCREEN-VALUE) < 10 THEN 
               DO:
                   RUN mensagem.w (INPUT YES,
                                   INPUT "    ATENÇÃO  ",
                                   INPUT "",
                                   INPUT "",
                                   INPUT "Telefone inválido.",
                                   INPUT "",
                                   INPUT "").
                
                   PAUSE 3 NO-MESSAGE.
                   h_mensagem:HIDDEN = YES.
                
                   APPLY "ENTRY" TO ed_nrdofone2.
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
    /* se não foram digitados números, despreza */
    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))  THEN
        DO:
            /* se escolheu os botoes, repassa o retorno */
            IF  RETURN-VALUE <> ""  THEN
                RETURN RETURN-VALUE.
            ELSE
                /* senao somente despreza a tecla */
                RETURN NO-APPLY.
        END.                
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_nr_doddd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nr_doddd w_cartao_numero_recarga
ON ANY-KEY OF ed_nr_doddd IN FRAME f_numero_recarga
DO:
    RUN tecla.

    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN DO:
        IF  LENGTH(ed_nr_doddd:SCREEN-VALUE) < 2 THEN DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "    ATENÇÃO  ",
                            INPUT "",
                            INPUT "",
                            INPUT "DDD inválido.",
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
    /* se não foram digitados números, despreza */
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nr_doddd w_cartao_numero_recarga
ON VALUE-CHANGED OF ed_nr_doddd IN FRAME f_numero_recarga
DO:
  IF  LENGTH(ed_nr_doddd:SCREEN-VALUE) = 2 THEN DO:
      APPLY "ENTRY" TO ed_nrdofone.
      RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_nr_doddd2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nr_doddd2 w_cartao_numero_recarga
ON ANY-KEY OF ed_nr_doddd2 IN FRAME f_numero_recarga
DO:
    RUN tecla.

    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN DO:
        IF  LENGTH(ed_nr_doddd2:SCREEN-VALUE) < 2 THEN DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "    ATENÇÃO  ",
                            INPUT "",
                            INPUT "",
                            INPUT "DDD inválido.",
                            INPUT "",
                            INPUT "").

            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.

            APPLY "ENTRY" TO ed_nr_doddd2.
            RETURN NO-APPLY.
        END.
        ELSE DO:
            APPLY "ENTRY" TO ed_nrdofone2.
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
    /* se não foram digitados números, despreza */
    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9",KEY-FUNCTION(LASTKEY))  THEN
        DO:
            /* se escolheu os botoes, repassa o retorno */
            IF  RETURN-VALUE <> ""  THEN
                RETURN RETURN-VALUE.
            ELSE
                /* senao somente despreza a tecla */
                RETURN NO-APPLY.
        END.        
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nr_doddd2 w_cartao_numero_recarga
ON VALUE-CHANGED OF ed_nr_doddd2 IN FRAME f_numero_recarga
DO:
  IF  LENGTH(ed_nr_doddd2:SCREEN-VALUE) = 2 THEN DO:
      APPLY "ENTRY" TO ed_nrdofone2.
      RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_cartao_numero_recarga OCX.Tick
PROCEDURE temporizador.t_cartao_numero_recarga.Tick .
APPLY "CHOOSE" TO Btn_D IN FRAME f_numero_recarga.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_cartao_numero_recarga 


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
              
    RUN limpa.

    /* deixa o mouse transparente */
    FRAME f_numero_recarga:LOAD-MOUSE-POINTER("blank.cur").
    
    chtemporizador:t_cartao_numero_recarga:INTERVAL = glb_nrtempor.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_cartao_numero_recarga  _CONTROL-LOAD
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

OCXFile = SEARCH( "cartao_numero_recarga.wrx":U ).
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
ELSE MESSAGE "cartao_numero_recarga.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_cartao_numero_recarga  _DEFAULT-DISABLE
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
  HIDE FRAME f_numero_recarga.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_cartao_numero_recarga  _DEFAULT-ENABLE
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
  DISPLAY ed_nr_doddd ed_nrdofone ed_nr_doddd2 ed_nrdofone2 
      WITH FRAME f_numero_recarga.
  ENABLE IMAGE-37 IMAGE-40 RECT-3 RECT-4 RECT-5 RECT-6 ed_nr_doddd ed_nrdofone 
         ed_nr_doddd2 ed_nrdofone2 Btn_D Btn_H 
      WITH FRAME f_numero_recarga.
  {&OPEN-BROWSERS-IN-QUERY-f_numero_recarga}
  VIEW w_cartao_numero_recarga.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE limpa w_cartao_numero_recarga 
PROCEDURE limpa :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

    ASSIGN  ed_nr_doddd:SCREEN-VALUE IN FRAME f_numero_recarga = ""
            ed_nrdofone:SCREEN-VALUE IN FRAME f_numero_recarga = ""
            ed_nr_doddd2:SCREEN-VALUE IN FRAME f_numero_recarga = ""
            ed_nrdofone2:SCREEN-VALUE IN FRAME f_numero_recarga = "" NO-ERROR.

    APPLY "ENTRY" TO ed_nr_doddd.
    RETURN NO-APPLY.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_cartao_numero_recarga 
PROCEDURE tecla :
chtemporizador:t_cartao_numero_recarga:INTERVAL = 0.
 
    IF  KEY-FUNCTION(LASTKEY) = "D"                    AND    /* Voltar*/
        Btn_D:SENSITIVE IN FRAME f_numero_recarga  THEN
        DO:
            APPLY "CHOOSE" TO Btn_D.
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                    AND    /* Continuar*/
        Btn_H:SENSITIVE IN FRAME f_numero_recarga  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
        DO:
            chtemporizador:t_cartao_numero_recarga:INTERVAL = glb_nrtempor.
            RETURN NO-APPLY.
        END.

    chtemporizador:t_cartao_numero_recarga:INTERVAL = glb_nrtempor.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            /* joga o frame frente */
            FRAME f_numero_recarga:MOVE-TO-TOP().

            APPLY "ENTRY" TO Btn_D.
        END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

