&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_manutencao_suprimento
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_manutencao_suprimento 
/* ..............................................................................

Procedure: manutencao_suprimento.w
Objetivo : Tela para efetuar o suprimento do terminal
Autor    : Evandro
Data     : Janeiro 2010

Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

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
DEFINE INPUT PARAM  par_dsstatus    AS LOGICAL      NO-UNDO.

/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }

DEFINE VARIABLE aux_nmdohost        AS CHAR         NO-UNDO.
DEFINE VARIABLE aux_ipdohost        AS CHAR         NO-UNDO.

DEFINE VARIABLE aux_flgderro        AS LOGICAL      NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_manutencao_suprimento

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-33 IMAGE_D IMAGE-40 IMAGE_G ed_qtnotk7A ~
ed_vlnotk7A ed_vltotk7A ed_qtnotk7B ed_vlnotk7B ed_vltotk7B ed_qtnotk7C ~
ed_vlnotk7C ed_vltotk7C ed_qtnotk7D ed_vlnotk7D ed_vltotk7D ed_qtnotk7R ~
ed_vltotsup Btn_G Btn_D Btn_H ed_titulo 
&Scoped-Define DISPLAYED-OBJECTS ed_qtnotk7A ed_vlnotk7A ed_vltotk7A ~
ed_qtnotk7B ed_vlnotk7B ed_vltotk7B ed_qtnotk7C ed_vlnotk7C ed_vltotk7C ~
ed_qtnotk7D ed_vlnotk7D ed_vltotk7D ed_qtnotk7R ed_vltotsup ed_titulo 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_manutencao_suprimento AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE VARIABLE ed_qtenvelo AS INTEGER FORMAT "z,zz9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 24 BY 1.91
     FONT 13 NO-UNDO.

DEFINE RECTANGLE RECT-34
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 26 BY 2.62.

DEFINE BUTTON Btn_D 
     LABEL "ATUALIZAR" 
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

DEFINE VARIABLE ed_qtnotk7A AS INTEGER FORMAT "z,zz9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 24 BY 1.91
     FONT 13 NO-UNDO.

DEFINE VARIABLE ed_qtnotk7B AS INTEGER FORMAT "z,zz9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 24 BY 1.91
     FONT 13 NO-UNDO.

DEFINE VARIABLE ed_qtnotk7C AS INTEGER FORMAT "z,zz9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 24 BY 1.91
     FONT 13 NO-UNDO.

DEFINE VARIABLE ed_qtnotk7D AS INTEGER FORMAT "z,zz9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 24 BY 1.91
     FONT 13 NO-UNDO.

DEFINE VARIABLE ed_qtnotk7R AS INTEGER FORMAT "z,zz9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 24 BY 1.91
     FONT 13 NO-UNDO.

DEFINE VARIABLE ed_titulo AS CHARACTER FORMAT "X(30)":U INITIAL "SUPRIMENTO" 
      VIEW-AS TEXT 
     SIZE 58 BY 3
     FGCOLOR 1 FONT 10 NO-UNDO.

DEFINE VARIABLE ed_vlnotk7A AS DECIMAL FORMAT "zz9.99":U INITIAL 10 
     VIEW-AS FILL-IN 
     SIZE 28 BY 1.91
     FONT 13 NO-UNDO.

DEFINE VARIABLE ed_vlnotk7B AS DECIMAL FORMAT "zz9.99":U INITIAL 20 
     VIEW-AS FILL-IN 
     SIZE 28 BY 1.91
     FONT 13 NO-UNDO.

DEFINE VARIABLE ed_vlnotk7C AS DECIMAL FORMAT "zz9.99":U INITIAL 50 
     VIEW-AS FILL-IN 
     SIZE 28 BY 1.91
     FONT 13 NO-UNDO.

DEFINE VARIABLE ed_vlnotk7D AS DECIMAL FORMAT "zz9.99":U INITIAL 50 
     VIEW-AS FILL-IN 
     SIZE 28 BY 1.91
     FONT 13 NO-UNDO.

DEFINE VARIABLE ed_vltotk7A AS DECIMAL FORMAT "zzz,zz9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 46 BY 1.91
     FONT 13 NO-UNDO.

DEFINE VARIABLE ed_vltotk7B AS DECIMAL FORMAT "zzz,zz9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 46 BY 1.91
     FONT 13 NO-UNDO.

DEFINE VARIABLE ed_vltotk7C AS DECIMAL FORMAT "zzz,zz9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 46 BY 1.91
     FONT 13 NO-UNDO.

DEFINE VARIABLE ed_vltotk7D AS DECIMAL FORMAT "zzz,zz9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 46 BY 1.91
     FONT 13 NO-UNDO.

DEFINE VARIABLE ed_vltotsup AS DECIMAL FORMAT "ZZZ,ZZ9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 46 BY 1.91
     FONT 13 NO-UNDO.

DEFINE IMAGE IMAGE-40
     FILENAME "Imagens/seta_dir.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE_D
     FILENAME "Imagens/seta_esq.gif":U TRANSPARENT
     SIZE 5 BY 3.05.

DEFINE IMAGE IMAGE_G
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

DEFINE RECTANGLE RECT-33
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 117 BY 10.71.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_manutencao_suprimento
     ed_qtnotk7A AT ROW 9.1 COL 31 COLON-ALIGNED NO-LABEL WIDGET-ID 94
     ed_vlnotk7A AT ROW 9.1 COL 59 COLON-ALIGNED NO-LABEL WIDGET-ID 112
     ed_vltotk7A AT ROW 9.1 COL 91 COLON-ALIGNED NO-LABEL WIDGET-ID 126 NO-TAB-STOP 
     ed_qtnotk7B AT ROW 11 COL 31 COLON-ALIGNED NO-LABEL WIDGET-ID 96
     ed_vlnotk7B AT ROW 11 COL 59 COLON-ALIGNED NO-LABEL WIDGET-ID 114
     ed_vltotk7B AT ROW 11 COL 91 COLON-ALIGNED NO-LABEL WIDGET-ID 128 NO-TAB-STOP 
     ed_qtnotk7C AT ROW 12.91 COL 31 COLON-ALIGNED NO-LABEL WIDGET-ID 98
     ed_vlnotk7C AT ROW 12.91 COL 59 COLON-ALIGNED NO-LABEL WIDGET-ID 116
     ed_vltotk7C AT ROW 12.91 COL 91 COLON-ALIGNED NO-LABEL WIDGET-ID 130 NO-TAB-STOP 
     ed_qtnotk7D AT ROW 14.81 COL 31 COLON-ALIGNED NO-LABEL WIDGET-ID 100
     ed_vlnotk7D AT ROW 14.81 COL 59 COLON-ALIGNED NO-LABEL WIDGET-ID 118
     ed_vltotk7D AT ROW 14.81 COL 91 COLON-ALIGNED NO-LABEL WIDGET-ID 132 NO-TAB-STOP 
     ed_qtnotk7R AT ROW 16.71 COL 31 COLON-ALIGNED NO-LABEL WIDGET-ID 150 NO-TAB-STOP 
     ed_vltotsup AT ROW 16.95 COL 91 COLON-ALIGNED NO-LABEL WIDGET-ID 124 NO-TAB-STOP 
     Btn_G AT ROW 19.33 COL 94.4 WIDGET-ID 82
     Btn_D AT ROW 24.1 COL 6 WIDGET-ID 80
     Btn_H AT ROW 24.1 COL 94.4 WIDGET-ID 74
     ed_titulo AT ROW 1.71 COL 50 COLON-ALIGNED NO-LABEL WIDGET-ID 198 NO-TAB-STOP 
     "R" VIEW-AS TEXT
          SIZE 6.2 BY 2.1 AT ROW 17.1 COL 26 WIDGET-ID 90
          FONT 13
     " Quantidade de Notas" VIEW-AS TEXT
          SIZE 21.6 BY .62 AT ROW 8.14 COL 36 WIDGET-ID 102
     "=" VIEW-AS TEXT
          SIZE 3 BY .62 AT ROW 9.76 COL 89.6 WIDGET-ID 136
          FONT 8
     "D" VIEW-AS TEXT
          SIZE 6.2 BY 2.38 AT ROW 14.91 COL 26 WIDGET-ID 88
          FONT 13
     " Valor da Nota" VIEW-AS TEXT
          SIZE 15 BY .62 AT ROW 8.14 COL 74.2 WIDGET-ID 120
     "x" VIEW-AS TEXT
          SIZE 2.8 BY .95 AT ROW 9.43 COL 58 WIDGET-ID 104
          FONT 8
     "A" VIEW-AS TEXT
          SIZE 6.2 BY 2.38 AT ROW 9.05 COL 26 WIDGET-ID 92
          FONT 13
     "=" VIEW-AS TEXT
          SIZE 3 BY .62 AT ROW 11.67 COL 89.6 WIDGET-ID 138
          FONT 8
     "B" VIEW-AS TEXT
          SIZE 6.2 BY 2.38 AT ROW 11 COL 26 WIDGET-ID 84
          FONT 13
     "x" VIEW-AS TEXT
          SIZE 2.8 BY .95 AT ROW 15.19 COL 58 WIDGET-ID 110
          FONT 8
     "=" VIEW-AS TEXT
          SIZE 3 BY .62 AT ROW 13.57 COL 89.6 WIDGET-ID 140
          FONT 8
     "x" VIEW-AS TEXT
          SIZE 2.8 BY .95 AT ROW 13.29 COL 58 WIDGET-ID 108
          FONT 8
     " Valor Total" VIEW-AS TEXT
          SIZE 12 BY .62 AT ROW 8.14 COL 128 WIDGET-ID 134
     "TOTAL" VIEW-AS TEXT
          SIZE 29 BY 2.38 AT ROW 16.81 COL 61 WIDGET-ID 122
          FONT 10
     "=" VIEW-AS TEXT
          SIZE 3 BY .62 AT ROW 17.67 COL 89.6 WIDGET-ID 144
          FONT 8
     "=" VIEW-AS TEXT
          SIZE 3 BY .62 AT ROW 15.52 COL 89.6 WIDGET-ID 142
          FONT 8
     "x" VIEW-AS TEXT
          SIZE 2.8 BY .95 AT ROW 11.38 COL 58 WIDGET-ID 106
          FONT 8
     "C" VIEW-AS TEXT
          SIZE 6.2 BY 2.38 AT ROW 12.95 COL 26 WIDGET-ID 86
          FONT 13
     RECT-33 AT ROW 8.57 COL 24 WIDGET-ID 146
     IMAGE_D AT ROW 24.24 COL 1 WIDGET-ID 148
     IMAGE-40 AT ROW 24.24 COL 156 WIDGET-ID 154
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 160 BY 28.57 WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME f_manutencao_suprimento
     IMAGE_G AT ROW 19.48 COL 156 WIDGET-ID 182
     RECT-101 AT ROW 5.05 COL 19.6 WIDGET-ID 188
     RECT-102 AT ROW 5.52 COL 19.6 WIDGET-ID 190
     RECT-103 AT ROW 5.29 COL 19.6 WIDGET-ID 186
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 160 BY 28.57 WIDGET-ID 100.

DEFINE FRAME f_envelope
     ed_qtenvelo AT ROW 1.95 COL 2 NO-LABEL WIDGET-ID 154 NO-TAB-STOP 
     " Quantidade de Envelopes" VIEW-AS TEXT
          SIZE 25.6 BY .62 AT ROW 1 COL 1 WIDGET-ID 152
     RECT-34 AT ROW 1.48 COL 1 WIDGET-ID 156
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 23.8 ROW 19.48
         SIZE 26.8 BY 3.29 WIDGET-ID 200.


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
  CREATE WINDOW w_manutencao_suprimento ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.57
         WIDTH              = 160
         MAX-HEIGHT         = 28.57
         MAX-WIDTH          = 160
         VIRTUAL-HEIGHT     = 28.57
         VIRTUAL-WIDTH      = 160
         SHOW-IN-TASKBAR    = no
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
ASSIGN w_manutencao_suprimento = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_manutencao_suprimento
  VISIBLE,,RUN-PERSISTENT                                               */
/* REPARENT FRAME */
ASSIGN FRAME f_envelope:FRAME = FRAME f_manutencao_suprimento:HANDLE.

/* SETTINGS FOR FRAME f_envelope
   NOT-VISIBLE                                                          */
ASSIGN 
       FRAME f_envelope:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN ed_qtenvelo IN FRAME f_envelope
   ALIGN-L                                                              */
ASSIGN 
       ed_qtenvelo:READ-ONLY IN FRAME f_envelope        = TRUE.

/* SETTINGS FOR FRAME f_manutencao_suprimento
   FRAME-NAME                                                           */
ASSIGN 
       ed_qtnotk7R:READ-ONLY IN FRAME f_manutencao_suprimento        = TRUE.

ASSIGN 
       ed_titulo:READ-ONLY IN FRAME f_manutencao_suprimento        = TRUE.

ASSIGN 
       ed_vlnotk7A:READ-ONLY IN FRAME f_manutencao_suprimento        = TRUE.

ASSIGN 
       ed_vlnotk7B:READ-ONLY IN FRAME f_manutencao_suprimento        = TRUE.

ASSIGN 
       ed_vlnotk7C:READ-ONLY IN FRAME f_manutencao_suprimento        = TRUE.

ASSIGN 
       ed_vlnotk7D:READ-ONLY IN FRAME f_manutencao_suprimento        = TRUE.

ASSIGN 
       ed_vltotk7A:READ-ONLY IN FRAME f_manutencao_suprimento        = TRUE.

ASSIGN 
       ed_vltotk7B:READ-ONLY IN FRAME f_manutencao_suprimento        = TRUE.

ASSIGN 
       ed_vltotk7C:READ-ONLY IN FRAME f_manutencao_suprimento        = TRUE.

ASSIGN 
       ed_vltotk7D:READ-ONLY IN FRAME f_manutencao_suprimento        = TRUE.

ASSIGN 
       ed_vltotsup:READ-ONLY IN FRAME f_manutencao_suprimento        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-101 IN FRAME f_manutencao_suprimento
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-102 IN FRAME f_manutencao_suprimento
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-103 IN FRAME f_manutencao_suprimento
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_manutencao_suprimento:HANDLE
       ROW             = 2.19
       COLUMN          = 9
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_manutencao_suprimento */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_manutencao_suprimento
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_manutencao_suprimento w_manutencao_suprimento
ON END-ERROR OF w_manutencao_suprimento
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_manutencao_suprimento w_manutencao_suprimento
ON WINDOW-CLOSE OF w_manutencao_suprimento
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_manutencao_suprimento
ON ANY-KEY OF Btn_D IN FRAME f_manutencao_suprimento /* ATUALIZAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_D w_manutencao_suprimento
ON CHOOSE OF Btn_D IN FRAME f_manutencao_suprimento /* ATUALIZAR */
DO:
    /* ---------- */
    RUN procedures/verifica_autorizacao.p (OUTPUT aux_flgderro).
    
    IF  aux_flgderro   THEN
        DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
            RETURN NO-APPLY.
        END.

    /* atribui nos campos o valor da tela */
    ASSIGN ed_qtnotK7A
           ed_qtnotK7B
           ed_qtnotK7C
           ed_qtnotK7D

           ed_vlnotK7A
           ed_vlnotK7B
           ed_vlnotK7C
           ed_vlnotK7D

           /* contabiliza os totais caso nao tenha passado por todos os campos */
           ed_vltotK7A:SCREEN-VALUE = STRING(ed_qtnotK7A * ed_vlnotK7A)
           ed_vltotK7B:SCREEN-VALUE = STRING(ed_qtnotK7B * ed_vlnotK7B)
           ed_vltotK7C:SCREEN-VALUE = STRING(ed_qtnotK7C * ed_vlnotK7C)
           ed_vltotK7D:SCREEN-VALUE = STRING(ed_qtnotK7D * ed_vlnotK7D)

           ed_vltotsup:SCREEN-VALUE = STRING(DEC(ed_vltotK7A:SCREEN-VALUE) +
                                             DEC(ed_vltotK7B:SCREEN-VALUE) +
                                             DEC(ed_vltotK7C:SCREEN-VALUE) +
                                             DEC(ed_vltotK7D:SCREEN-VALUE)).
    
    /* valida os valores ***** opção comentada em 29/08/2013 devido ao valor fixo dos K7s *****
    aux_flgderro = NO.

    /* K7A */
    IF  (ed_qtnotK7A > 0 AND ed_vlnotK7A = 0)                   OR
        (ed_qtnotK7A = 0 AND ed_vlnotK7A > 0)                   OR
        NOT CAN-DO("0,1,2,5,10,20,50,100",STRING(ed_vlnotK7A))  THEN
        aux_flgderro = YES.

    /* K7B */
    IF  (ed_qtnotK7B > 0 AND ed_vlnotK7B = 0)                   OR
        (ed_qtnotK7B = 0 AND ed_vlnotK7B > 0)                   OR
        NOT CAN-DO("0,1,2,5,10,20,50,100",STRING(ed_vlnotK7B))  THEN
        aux_flgderro = YES.
    
    /* K7C */
    IF  (ed_qtnotK7C > 0 AND ed_vlnotK7C = 0)                   OR
        (ed_qtnotK7C = 0 AND ed_vlnotK7C > 0)                   OR
        NOT CAN-DO("0,1,2,5,10,20,50,100",STRING(ed_vlnotK7C))  THEN
        aux_flgderro = YES.

    /* K7D */
    IF  (ed_qtnotK7D > 0 AND ed_vlnotK7D = 0)                   OR
        (ed_qtnotK7D = 0 AND ed_vlnotK7D > 0)                   OR
        NOT CAN-DO("0,1,2,5,10,20,50,100",STRING(ed_vlnotK7D))  THEN
        aux_flgderro = YES.

    *****/

    /* Suprimento Zerado */
    IF  ed_qtnotK7A = 0  AND
        ed_qtnotK7B = 0  AND
        ed_qtnotK7C = 0  AND
        ed_qtnotK7D = 0  THEN
        DO:
            RUN mensagem.w (INPUT YES,
                            INPUT "    ATENÇÃO",
                            INPUT "",
                            INPUT "Suprimento Zerado!",
                            INPUT "",
                            INPUT "",
                            INPUT "").

            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.

            APPLY "CHOOSE" TO Btn_G.
            RETURN NO-APPLY.
        END.




    /* alimenta as variaveis para atualizar o TAA */
    ASSIGN  glb_qtnotK7A = ed_qtnotK7A
            glb_qtnotK7B = ed_qtnotK7B
            glb_qtnotK7C = ed_qtnotK7C
            glb_qtnotK7D = ed_qtnotK7D
                                   
            glb_vlnotK7A = ed_vlnotK7A
            glb_vlnotK7B = ed_vlnotK7B
            glb_vlnotK7C = ed_vlnotK7C
            glb_vlnotK7D = ed_vlnotK7D.

    RUN procedures/efetua_suprimento.p (OUTPUT aux_flgderro).

    IF  aux_flgderro  THEN
        DO:
            APPLY "CHOOSE" TO Btn_G.
            RETURN NO-APPLY.
        END.

    RUN procedures/carrega_suprimento.p (OUTPUT aux_flgderro).

    RUN mostra_suprimento.

    DISABLE Btn_D   Btn_G WITH FRAME f_manutencao_suprimento.

    ASSIGN Btn_H:LABEL = "VOLTAR".

    APPLY "ENTRY" TO Btn_H.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_G
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_manutencao_suprimento
ON ANY-KEY OF Btn_G IN FRAME f_manutencao_suprimento /* CORRIGIR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_manutencao_suprimento
ON CHOOSE OF Btn_G IN FRAME f_manutencao_suprimento /* CORRIGIR */
DO:
    ASSIGN  ed_qtnotK7A:SCREEN-VALUE = ""
            ed_qtnotK7B:SCREEN-VALUE = ""
            ed_qtnotK7C:SCREEN-VALUE = ""
            ed_qtnotK7D:SCREEN-VALUE = ""

            ed_vltotK7A:SCREEN-VALUE = ""
            ed_vltotK7B:SCREEN-VALUE = ""
            ed_vltotK7C:SCREEN-VALUE = ""
            ed_vltotK7D:SCREEN-VALUE = ""

            ed_vltotsup:SCREEN-VALUE = "".

    APPLY "ENTRY" TO ed_qtnotK7A.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_manutencao_suprimento
ON ANY-KEY OF Btn_H IN FRAME f_manutencao_suprimento /* VOLTAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_manutencao_suprimento
ON CHOOSE OF Btn_H IN FRAME f_manutencao_suprimento /* VOLTAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_qtnotk7A
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_qtnotk7A w_manutencao_suprimento
ON ANY-KEY OF ed_qtnotk7A IN FRAME f_manutencao_suprimento
DO:
    RUN tecla.

    /* nao tenta aplicar LETRAS nos campos de NUMEROS */
    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9,BACKSPACE",KEY-FUNCTION(LASTKEY))  THEN
        RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_qtnotk7A w_manutencao_suprimento
ON RETURN OF ed_qtnotk7A IN FRAME f_manutencao_suprimento
DO:
    ed_vltotK7A:SCREEN-VALUE = STRING(INT(ed_qtnotK7A:SCREEN-VALUE) *
                                      DEC(ed_vlnotK7A:SCREEN-VALUE)).

    APPLY "ENTRY" TO ed_qtnotk7B.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_qtnotk7B
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_qtnotk7B w_manutencao_suprimento
ON ANY-KEY OF ed_qtnotk7B IN FRAME f_manutencao_suprimento
DO:
    RUN tecla.

    /* nao tenta aplicar LETRAS nos campos de NUMEROS */
    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9,BACKSPACE",KEY-FUNCTION(LASTKEY))  THEN
        RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_qtnotk7B w_manutencao_suprimento
ON RETURN OF ed_qtnotk7B IN FRAME f_manutencao_suprimento
DO:
    ed_vltotK7B:SCREEN-VALUE = STRING(INT(ed_qtnotK7B:SCREEN-VALUE) *
                                      DEC(ed_vlnotK7B:SCREEN-VALUE)).

    APPLY "ENTRY" TO ed_qtnotk7C.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_qtnotk7C
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_qtnotk7C w_manutencao_suprimento
ON ANY-KEY OF ed_qtnotk7C IN FRAME f_manutencao_suprimento
DO:
    RUN tecla.

    /* nao tenta aplicar LETRAS nos campos de NUMEROS */
    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9,BACKSPACE",KEY-FUNCTION(LASTKEY))  THEN
        RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_qtnotk7C w_manutencao_suprimento
ON RETURN OF ed_qtnotk7C IN FRAME f_manutencao_suprimento
DO:
    ed_vltotK7C:SCREEN-VALUE = STRING(INT(ed_qtnotK7C:SCREEN-VALUE) *
                                      DEC(ed_vlnotK7C:SCREEN-VALUE)).

    APPLY "ENTRY" TO ed_qtnotk7D.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_qtnotk7D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_qtnotk7D w_manutencao_suprimento
ON ANY-KEY OF ed_qtnotk7D IN FRAME f_manutencao_suprimento
DO:
    RUN tecla.

    /* nao tenta aplicar LETRAS nos campos de NUMEROS */
    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9,BACKSPACE",KEY-FUNCTION(LASTKEY))  THEN
        RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_qtnotk7D w_manutencao_suprimento
ON RETURN OF ed_qtnotk7D IN FRAME f_manutencao_suprimento
DO:
    ASSIGN ed_vltotK7D:SCREEN-VALUE = STRING(INT(ed_qtnotK7D:SCREEN-VALUE) *
                                             DEC(ed_vlnotK7D:SCREEN-VALUE))
                                                                     
           ed_vltotsup:SCREEN-VALUE = STRING(DEC(ed_vltotK7A:SCREEN-VALUE) +
                                             DEC(ed_vltotK7B:SCREEN-VALUE) +
                                             DEC(ed_vltotK7C:SCREEN-VALUE) +
                                             DEC(ed_vltotK7D:SCREEN-VALUE)).

    APPLY "ENTRY" TO Btn_D.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_manutencao_suprimento OCX.Tick
PROCEDURE temporizador.t_manutencao_suprimento.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_manutencao_suprimento.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_manutencao_suprimento 


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
    FRAME f_manutencao_suprimento:LOAD-MOUSE-POINTER("blank.cur").
    FRAME f_envelope:LOAD-MOUSE-POINTER("blank.cur").

    chtemporizador:t_manutencao_suprimento:INTERVAL = glb_nrtempor.

    /* Somente visualização do status do TAA */
    IF  par_dsstatus = YES  THEN
        DO:
            RUN procedures/grava_log.p (INPUT "Verificando situação do terminal...").

            HIDE Btn_D IMAGE_D
                 Btn_G IMAGE_G IN FRAME f_manutencao_suprimento.

            ASSIGN Btn_H:LABEL            = "RETORNAR"
                   ed_titulo:SCREEN-VALUE = "   SITUAÇÃO".

            VIEW FRAME f_envelope.

            RUN mostra_suprimento.

            /* coloca o foco no botao H */
            APPLY "ENTRY" TO Btn_H.
        END.
    ELSE
        /* coloca o foco na qtd de notas do cassete A */
        APPLY "ENTRY" TO ed_qtnotk7A.
 
    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_manutencao_suprimento  _CONTROL-LOAD
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

OCXFile = SEARCH( "manutencao_suprimento.wrx":U ).
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
ELSE MESSAGE "manutencao_suprimento.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_manutencao_suprimento  _DEFAULT-DISABLE
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
  HIDE FRAME f_envelope.
  HIDE FRAME f_manutencao_suprimento.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_manutencao_suprimento  _DEFAULT-ENABLE
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
  DISPLAY ed_qtnotk7A ed_vlnotk7A ed_vltotk7A ed_qtnotk7B ed_vlnotk7B 
          ed_vltotk7B ed_qtnotk7C ed_vlnotk7C ed_vltotk7C ed_qtnotk7D 
          ed_vlnotk7D ed_vltotk7D ed_qtnotk7R ed_vltotsup ed_titulo 
      WITH FRAME f_manutencao_suprimento.
  ENABLE RECT-33 IMAGE_D IMAGE-40 IMAGE_G ed_qtnotk7A ed_vlnotk7A ed_vltotk7A 
         ed_qtnotk7B ed_vlnotk7B ed_vltotk7B ed_qtnotk7C ed_vlnotk7C 
         ed_vltotk7C ed_qtnotk7D ed_vlnotk7D ed_vltotk7D ed_qtnotk7R 
         ed_vltotsup Btn_G Btn_D Btn_H ed_titulo 
      WITH FRAME f_manutencao_suprimento.
  {&OPEN-BROWSERS-IN-QUERY-f_manutencao_suprimento}
  DISPLAY ed_qtenvelo 
      WITH FRAME f_envelope.
  ENABLE RECT-34 ed_qtenvelo 
      WITH FRAME f_envelope.
  {&OPEN-BROWSERS-IN-QUERY-f_envelope}
  VIEW w_manutencao_suprimento.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mostra_suprimento w_manutencao_suprimento 
PROCEDURE mostra_suprimento :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DO WITH FRAME f_manutencao_suprimento:

    /* alimenta as variaveis para mostrar na tela */
            /* Quantidade das notas */
    ASSIGN  ed_qtnotK7A:SCREEN-VALUE = STRING(glb_qtnotK7A)
            ed_qtnotK7A:READ-ONLY    = YES
            ed_qtnotK7A:BGCOLOR      = ?

            ed_qtnotK7B:SCREEN-VALUE = STRING(glb_qtnotK7B)
            ed_qtnotK7B:READ-ONLY    = YES
            ed_qtnotK7B:BGCOLOR      = ?

            ed_qtnotK7C:SCREEN-VALUE = STRING(glb_qtnotK7C)
            ed_qtnotK7C:READ-ONLY    = YES
            ed_qtnotK7C:BGCOLOR      = ?

            ed_qtnotK7D:SCREEN-VALUE = STRING(glb_qtnotK7D)
            ed_qtnotK7D:READ-ONLY    = YES
            ed_qtnotK7D:BGCOLOR      = ?

            ed_qtnotK7R:SCREEN-VALUE = STRING(glb_qtnotK7R)
            ed_qtnotK7R:READ-ONLY    = YES
            ed_qtnotK7R:BGCOLOR      = ?



            /* Valor das Notas */
            ed_vlnotK7A:SCREEN-VALUE = STRING(glb_vlnotK7A)
            ed_vlnotK7A:READ-ONLY    = YES
            ed_vlnotK7A:BGCOLOR      = ?

            ed_vlnotK7B:SCREEN-VALUE = STRING(glb_vlnotK7B)
            ed_vlnotK7B:READ-ONLY    = YES
            ed_vlnotK7B:BGCOLOR      = ?

            ed_vlnotK7C:SCREEN-VALUE = STRING(glb_vlnotK7C)
            ed_vlnotK7C:READ-ONLY    = YES
            ed_vlnotK7C:BGCOLOR      = ?

            ed_vlnotK7D:SCREEN-VALUE = STRING(glb_vlnotK7D)
            ed_vlnotK7D:READ-ONLY    = YES
            ed_vlnotK7D:BGCOLOR      = ?
        
            /* Totais */
            ed_vltotK7A:SCREEN-VALUE = STRING(glb_qtnotK7A * glb_vlnotK7A)
            ed_vltotK7B:SCREEN-VALUE = STRING(glb_qtnotK7B * glb_vlnotK7B)
            ed_vltotK7C:SCREEN-VALUE = STRING(glb_qtnotK7C * glb_vlnotK7C)
            ed_vltotK7D:SCREEN-VALUE = STRING(glb_qtnotK7D * glb_vlnotK7D)

            ed_vltotsup:SCREEN-VALUE = STRING(DEC(ed_vltotK7A:SCREEN-VALUE) + 
                                              DEC(ed_vltotK7B:SCREEN-VALUE) +
                                              DEC(ed_vltotK7C:SCREEN-VALUE) +
                                              DEC(ed_vltotK7D:SCREEN-VALUE) +
                                              glb_vlnotK7R).



    RUN procedures/grava_log.p (INPUT "K7A - Quantidade: " + ed_qtnotK7A:SCREEN-VALUE + " - " + 
                                                 "Valor: " + ed_vlnotK7A:SCREEN-VALUE + " - " +
                                                 "Total: " + ed_vltotK7A:SCREEN-VALUE).

    RUN procedures/grava_log.p (INPUT "K7B - Quantidade: " + ed_qtnotK7B:SCREEN-VALUE + " - " + 
                                                 "Valor: " + ed_vlnotK7B:SCREEN-VALUE + " - " +
                                                 "Total: " + ed_vltotK7B:SCREEN-VALUE).

    RUN procedures/grava_log.p (INPUT "K7C - Quantidade: " + ed_qtnotK7C:SCREEN-VALUE + " - " + 
                                                 "Valor: " + ed_vlnotK7C:SCREEN-VALUE + " - " +
                                                 "Total: " + ed_vltotK7C:SCREEN-VALUE).

    RUN procedures/grava_log.p (INPUT "K7D - Quantidade: " + ed_qtnotK7D:SCREEN-VALUE + " - " + 
                                                 "Valor: " + ed_vlnotK7D:SCREEN-VALUE + " - " +
                                                 "Total: " + ed_vltotK7D:SCREEN-VALUE).

    RUN procedures/grava_log.p (INPUT "Total do suprimento: " + ed_vltotsup:SCREEN-VALUE).
END.

/* Envelopes */
ed_qtenvelo:SCREEN-VALUE IN FRAME f_envelope = STRING(glb_qtenvelo).

RUN procedures/grava_log.p (INPUT "Envelopes: " + ed_qtenvelo:SCREEN-VALUE).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_manutencao_suprimento 
PROCEDURE tecla :
chtemporizador:t_manutencao_suprimento:INTERVAL = 0.
    
    IF  KEY-FUNCTION(LASTKEY) = "D"                       AND
        Btn_D:SENSITIVE IN FRAME f_manutencao_suprimento  THEN
        APPLY "CHOOSE" TO Btn_D.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "G"                       AND
        Btn_G:SENSITIVE IN FRAME f_manutencao_suprimento  THEN
        APPLY "CHOOSE" TO Btn_G.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                       AND
        Btn_H:SENSITIVE IN FRAME f_manutencao_suprimento  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE 
        RETURN NO-APPLY.

    chtemporizador:t_manutencao_suprimento:INTERVAL = glb_nrtempor.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

