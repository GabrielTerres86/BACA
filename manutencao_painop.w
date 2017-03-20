&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_manutencao_painop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_manutencao_painop 
/* ..............................................................................

Procedure: manutencao_painop.w
Objetivo : Tela oculta para controle do PAINOP
Autor    : Evandro
Data     : Agosto 2011

Ultima alteração: 27/08/2015 - Adicionado condicao para verificar se o cartao
                               eh magnetico. (James)
                               
                  04/07/2016 - #447974 Adicionada a mensagem IMPRESSORA INOPERANTE
                               quando houver esta ocorrencia (Carlos)

                  23/01/2017 - #537054 No procedimento menu_manutencao, retirada
                               a opcao FECHAMENTO - E (Carlos)

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
{ includes/var_xfs_lite.i }

DEFINE VARIABLE aux_flgderro        AS LOGICAL                  NO-UNDO.
DEFINE VARIABLE aux_flgvolta        AS LOGICAL                  NO-UNDO.
DEFINE VARIABLE aux_nmoperad        AS CHAR                     NO-UNDO.
DEFINE VARIABLE buff                AS CHAR     EXTENT 6        NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_manutencao_painop

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-104 INRECT-105 INRECT-106 ed_dscartao ~
ed_nrsencar ed_opcao_menu_manutencao ed_opcao_menu_configuracao ~
ed_opcao_menu_temporizador ed_hrininot ed_hrfimnot ed_vlsaqnot ~
ed_opcao_menu_recolhimento ed_opcao_situacao ed_qtnotk7A ed_vlnotk7A ~
ed_qtnotk7B ed_vlnotk7B ed_qtnotk7C ed_vlnotk7C ed_qtnotk7D ed_vlnotk7D ~
ed_opcao_suprimento 
&Scoped-Define DISPLAYED-OBJECTS ed_dscartao ed_nrsencar ~
ed_opcao_menu_manutencao ed_opcao_menu_configuracao ~
ed_opcao_menu_temporizador ed_hrininot ed_hrfimnot ed_vlsaqnot ~
ed_opcao_menu_recolhimento ed_opcao_situacao ed_qtnotk7A ed_vlnotk7A ~
ed_qtnotk7B ed_vlnotk7B ed_qtnotk7C ed_vlnotk7C ed_qtnotk7D ed_vlnotk7D ~
ed_opcao_suprimento 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_manutencao_painop AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE VARIABLE ed_dscartao AS CHARACTER FORMAT "X(256)":U 
     LABEL "Cartao" 
     VIEW-AS FILL-IN 
     SIZE 67 BY 1 NO-UNDO.

DEFINE VARIABLE ed_hrfimnot AS INTEGER FORMAT "9999":U INITIAL 0 
     LABEL "Final" 
     VIEW-AS FILL-IN 
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE ed_hrininot AS INTEGER FORMAT "9999":U INITIAL 0 
     LABEL "Inicio" 
     VIEW-AS FILL-IN 
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE ed_nrsencar AS INTEGER FORMAT "zzzzz9":U INITIAL 0 
     LABEL "Senha" 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE ed_opcao_menu_configuracao AS CHARACTER FORMAT "X(1)":U 
     LABEL "Opcao - Menu Configuracao" 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE ed_opcao_menu_manutencao AS CHARACTER FORMAT "X(1)":U 
     LABEL "Opcao - Menu Manutencao" 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE ed_opcao_menu_recolhimento AS CHARACTER FORMAT "X(1)":U 
     LABEL "Opcao - Menu Recolhimento" 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE ed_opcao_menu_temporizador AS CHARACTER FORMAT "X(1)":U 
     LABEL "Opcao - Menu Temporizador" 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE ed_opcao_situacao AS CHARACTER FORMAT "X(1)":U 
     LABEL "Opcao - Situacao" 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE ed_opcao_suprimento AS CHARACTER FORMAT "X(1)":U 
     LABEL "Opcao - Suprimento" 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE ed_qtnotk7A AS INTEGER FORMAT "z,zz9":U INITIAL 0 
     LABEL "K7A   -   Qtd" 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE ed_qtnotk7B AS INTEGER FORMAT "z,zz9":U INITIAL 0 
     LABEL "K7B   -   Qtd" 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE ed_qtnotk7C AS INTEGER FORMAT "z,zz9":U INITIAL 0 
     LABEL "K7C   -   Qtd" 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE ed_qtnotk7D AS INTEGER FORMAT "z,zz9":U INITIAL 0 
     LABEL "K7D   -   Qtd" 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE ed_vlnotk7A AS DECIMAL FORMAT "zz9.99":U INITIAL 10 
     LABEL "Valor" 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE ed_vlnotk7B AS DECIMAL FORMAT "zz9.99":U INITIAL 20 
     LABEL "Valor" 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE ed_vlnotk7C AS DECIMAL FORMAT "zz9.99":U INITIAL 50 
     LABEL "Valor" 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE ed_vlnotk7D AS DECIMAL FORMAT "zz9.99":U INITIAL 50 
     LABEL "Valor" 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE ed_vlsaqnot AS DECIMAL FORMAT "z,zz9.99":U INITIAL 0 
     LABEL "Valor" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE RECTANGLE INRECT-105
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 28 BY 4.52.

DEFINE RECTANGLE INRECT-106
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 44 BY 6.91.

DEFINE RECTANGLE RECT-104
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 78 BY 3.1.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_manutencao_painop
     ed_dscartao AT ROW 3.38 COL 49 COLON-ALIGNED WIDGET-ID 176
     ed_nrsencar AT ROW 4.57 COL 49 COLON-ALIGNED WIDGET-ID 178
     ed_opcao_menu_manutencao AT ROW 7.19 COL 85 COLON-ALIGNED WIDGET-ID 180
     ed_opcao_menu_configuracao AT ROW 8.62 COL 85 COLON-ALIGNED WIDGET-ID 184
     ed_opcao_menu_temporizador AT ROW 10.05 COL 85 COLON-ALIGNED WIDGET-ID 186
     ed_hrininot AT ROW 12.19 COL 67 COLON-ALIGNED WIDGET-ID 192
     ed_hrfimnot AT ROW 13.38 COL 67 COLON-ALIGNED WIDGET-ID 194
     ed_vlsaqnot AT ROW 14.57 COL 67 COLON-ALIGNED WIDGET-ID 196
     ed_opcao_menu_recolhimento AT ROW 16.71 COL 85 COLON-ALIGNED WIDGET-ID 198
     ed_opcao_situacao AT ROW 18.14 COL 85 COLON-ALIGNED WIDGET-ID 200
     ed_qtnotk7A AT ROW 20.29 COL 70 COLON-ALIGNED WIDGET-ID 204
     ed_vlnotk7A AT ROW 20.29 COL 86 COLON-ALIGNED WIDGET-ID 206
     ed_qtnotk7B AT ROW 21.48 COL 70 COLON-ALIGNED WIDGET-ID 208
     ed_vlnotk7B AT ROW 21.48 COL 86 COLON-ALIGNED WIDGET-ID 210
     ed_qtnotk7C AT ROW 22.67 COL 70 COLON-ALIGNED WIDGET-ID 212
     ed_vlnotk7C AT ROW 22.67 COL 86 COLON-ALIGNED WIDGET-ID 214
     ed_qtnotk7D AT ROW 23.86 COL 70 COLON-ALIGNED WIDGET-ID 216
     ed_vlnotk7D AT ROW 23.86 COL 86 COLON-ALIGNED WIDGET-ID 218
     ed_opcao_suprimento AT ROW 25.29 COL 86 COLON-ALIGNED WIDGET-ID 220
     RECT-104 AT ROW 2.91 COL 42 WIDGET-ID 188
     INRECT-105 AT ROW 11.71 COL 59 WIDGET-ID 190
     INRECT-106 AT ROW 19.57 COL 56 WIDGET-ID 202
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
  CREATE WINDOW w_manutencao_painop ASSIGN
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
ASSIGN w_manutencao_painop = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_manutencao_painop
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_manutencao_painop
   FRAME-NAME                                                           */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_manutencao_painop:HANDLE
       ROW             = 2.91
       COLUMN          = 136
       HEIGHT          = 1.67
       WIDTH           = 7
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_manutencao_painop */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_manutencao_painop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_manutencao_painop w_manutencao_painop
ON END-ERROR OF w_manutencao_painop
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_manutencao_painop w_manutencao_painop
ON WINDOW-CLOSE OF w_manutencao_painop
DO:
    /* habilita o teclado frontal */
    RUN WinAtualizaEstadoTeclados IN aux_xfsliteh (
        INPUT  1, /* teclado frontal */
        INPUT  1, /* habilita varredura */
        INPUT -1, /* StaBeep - nao altera */
        INPUT -1, /* Led1 - nao altera */
        INPUT -1, /* Led2 - nao altera */
        INPUT -1, /* FlickerCrt - nao altera */
        INPUT -1, /* FlickerDispCel - nao altera */
        INPUT -1, /* FlickerPtr - nao altera */
        INPUT -1, /* Solenoide - nao altera */
        OUTPUT LT_Resp).

    buff = "".
    RUN procedures/atualiza_painop.p (INPUT buff).

    buff[4] = "      TECLADO FRONTAL HABILITADO".
    RUN procedures/atualiza_painop.p (INPUT buff).


    PAUSE 2 NO-MESSAGE.

    buff = "".
    RUN procedures/atualiza_painop.p (INPUT buff).
    
    ASSIGN buff[1] = "                                " + STRING(glb_dsvertaa,"x(6)")
           buff[2] = "         CECRED - SISTEMA TAA".
    RUN procedures/atualiza_painop.p (INPUT buff).


    h_mensagem:HIDDEN = YES.

    /* This event will close the window and terminate the procedure.  */
    APPLY "CLOSE":U TO THIS-PROCEDURE.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_hrfimnot
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_hrfimnot w_manutencao_painop
ON ANY-KEY OF ed_hrfimnot IN FRAME f_manutencao_painop /* Final */
DO:
    /* reinicia o timeout a cada tecla */
    chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.

    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9,BACKSPACE,RETURN,H",KEYFUNCTION(LASTKEY))  THEN
        NEXT.

    IF  KEYFUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            aux_flgvolta = NO.
            APPLY "GO".
        END.

    IF  KEYFUNCTION(LASTKEY) = "H"  THEN
        DO:
            aux_flgvolta = YES.
            APPLY "GO".
        END.

    /* aplica o valor */
    APPLY LASTKEY.

    /* desenha a tela */
    ASSIGN buff[3] = "           FINAL:    " + STRING(ed_hrfimnot:SCREEN-VALUE,"xx:xx") + CHR(127).

    RUN procedures/atualiza_painop.p (INPUT buff).

    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_hrininot
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_hrininot w_manutencao_painop
ON ANY-KEY OF ed_hrininot IN FRAME f_manutencao_painop /* Inicio */
DO:
    /* reinicia o timeout a cada tecla */
    chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.

    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9,BACKSPACE,RETURN,H",KEYFUNCTION(LASTKEY))  THEN
        NEXT.

    IF  KEYFUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            aux_flgvolta = NO.
            APPLY "GO".
        END.

    IF  KEYFUNCTION(LASTKEY) = "H"  THEN
        DO:
            aux_flgvolta = YES.
            APPLY "GO".
        END.

    /* aplica o valor */
    APPLY LASTKEY.

    /* desenha a tela */
    ASSIGN buff[2] = "         INICIAL:    " + STRING(ed_hrininot:SCREEN-VALUE,"xx:xx") + CHR(127).

    RUN procedures/atualiza_painop.p (INPUT buff).

    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_nrsencar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_nrsencar w_manutencao_painop
ON ANY-KEY OF ed_nrsencar IN FRAME f_manutencao_painop /* Senha */
DO:
    DEF VAR tmp_senha   AS CHAR     NO-UNDO.


    /* reinicia o timeout a cada tecla */
    chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.

    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9,BACKSPACE,RETURN,H",KEYFUNCTION(LASTKEY))  THEN
        NEXT.


    /* Encerra o UPDATE */
    IF  KEYFUNCTION(LASTKEY) = "RETURN"  THEN
        APPLY "GO".

    IF  KEYFUNCTION(LASTKEY) = "H" THEN
        DO:
            aux_flgvolta = YES.
            APPLY "GO".
        END.

    
    /* aplica o valor */
    APPLY LASTKEY.

    ASSIGN tmp_senha = FILL("*",LENGTH(TRIM(ed_nrsencar:SCREEN-VALUE)))
           tmp_senha = tmp_senha + FILL(" ",6 - LENGTH(tmp_senha))
           tmp_senha = IF  INT(ed_nrsencar:SCREEN-VALUE) = 0  THEN "      "
                       ELSE tmp_senha.
    


    /* desenha a tela */
    ASSIGN buff[2] = "OPERADOR: " + STRING(glb_nrdconta,"zzzzzzzzz9") + " - " +
                                    SUBSTRING(aux_nmoperad,1,16).
           buff[4] = "   SENHA: " + tmp_senha + " " + CHR(127).
    
    RUN procedures/atualiza_painop.p (INPUT buff).

    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_opcao_menu_configuracao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_opcao_menu_configuracao w_manutencao_painop
ON ANY-KEY OF ed_opcao_menu_configuracao IN FRAME f_manutencao_painop /* Opcao - Menu Configuracao */
DO:
    /* reinicia o timeout a cada tecla */
    chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.

    IF  NOT CAN-DO("A,E,H",KEYFUNCTION(LASTKEY))  THEN
        RETURN NO-APPLY.

    /* Encerra o UPDATE */
    APPLY "GO".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_opcao_menu_manutencao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_opcao_menu_manutencao w_manutencao_painop
ON ANY-KEY OF ed_opcao_menu_manutencao IN FRAME f_manutencao_painop /* Opcao - Menu Manutencao */
DO:
    /* reinicia o timeout a cada tecla */
    chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.

    IF  NOT CAN-DO("A,B,C,D,E,F,G,H",KEYFUNCTION(LASTKEY))  THEN
        RETURN NO-APPLY.


    /* Valida opcao escolhida conforme situacao do TAA */

    IF  (KEYFUNCTION(LASTKEY) = "A" AND glb_cdsittfn = 1) OR /* Ja esta Aberto */
        (KEYFUNCTION(LASTKEY) = "E" AND glb_cdsittfn = 2) OR /* Ja esta Fechado */
        (KEYFUNCTION(LASTKEY) = "F" AND glb_flgsupri)     OR /* Ja esta Suprido */
         
        /* Nao esta Suprido e nem tem Envelopes */
        (KEYFUNCTION(LASTKEY) = "B" AND
         NOT glb_flgsupri AND
         glb_qtenvelo = 0)                                 THEN
        RETURN NO-APPLY.

    /* encerra o UPDATE */
    APPLY "GO".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_opcao_menu_recolhimento
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_opcao_menu_recolhimento w_manutencao_painop
ON ANY-KEY OF ed_opcao_menu_recolhimento IN FRAME f_manutencao_painop /* Opcao - Menu Recolhimento */
DO:
    /* reinicia o timeout a cada tecla */
    chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.

    IF  NOT CAN-DO("A,E,H",KEYFUNCTION(LASTKEY))  THEN
        RETURN NO-APPLY.

    /* Encerra o UPDATE */
    APPLY "GO".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_opcao_menu_temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_opcao_menu_temporizador w_manutencao_painop
ON ANY-KEY OF ed_opcao_menu_temporizador IN FRAME f_manutencao_painop /* Opcao - Menu Temporizador */
DO:
    /* reinicia o timeout a cada tecla */
    chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.

    IF  NOT CAN-DO("A,B,C,H",KEYFUNCTION(LASTKEY))  THEN
        RETURN NO-APPLY.

    /* Encerra o UPDATE */
    APPLY "GO".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_opcao_situacao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_opcao_situacao w_manutencao_painop
ON ANY-KEY OF ed_opcao_situacao IN FRAME f_manutencao_painop /* Opcao - Situacao */
DO:
    /* reinicia o timeout a cada tecla */
    chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.

    IF  NOT CAN-DO("RETURN",KEYFUNCTION(LASTKEY))  THEN
        RETURN NO-APPLY.

    /* Encerra o UPDATE */
    APPLY "GO".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_opcao_suprimento
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_opcao_suprimento w_manutencao_painop
ON ANY-KEY OF ed_opcao_suprimento IN FRAME f_manutencao_painop /* Opcao - Suprimento */
DO:
    /* reinicia o timeout a cada tecla */
    chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.

    IF  NOT CAN-DO("H,RETURN",KEYFUNCTION(LASTKEY))  THEN
        RETURN NO-APPLY.

    IF  KEYFUNCTION(LASTKEY) = "H"  THEN
        aux_flgvolta = YES.

    /* Encerra o UPDATE */
    APPLY "GO".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_qtnotk7A
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_qtnotk7A w_manutencao_painop
ON ANY-KEY OF ed_qtnotk7A IN FRAME f_manutencao_painop /* K7A   -   Qtd */
DO:
    /* reinicia o timeout a cada tecla */
    chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.

    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9,BACKSPACE,RETURN,H",KEYFUNCTION(LASTKEY))  THEN
        NEXT.

    IF  KEYFUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            aux_flgvolta = NO.
            APPLY "GO".
        END.

    IF  KEYFUNCTION(LASTKEY) = "H"  THEN
        DO:
            aux_flgvolta = YES.
            APPLY "GO".
        END.

    /* aplica o valor */
    APPLY LASTKEY.

    buff[2] = "      A   " + STRING(INT(ed_qtnotK7A:SCREEN-VALUE),"z,zz9")  + CHR(127) + "  "  +
                             STRING(DEC(ed_vlnotK7A:SCREEN-VALUE),"zz9.99") + "    " +
                             STRING(INT(ed_qtnotK7A:SCREEN-VALUE) * DEC(ed_vlnotK7A:SCREEN-VALUE),"zzz,zz9.99").

    RUN procedures/atualiza_painop.p (INPUT buff).

    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_qtnotk7B
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_qtnotk7B w_manutencao_painop
ON ANY-KEY OF ed_qtnotk7B IN FRAME f_manutencao_painop /* K7B   -   Qtd */
DO:
    /* reinicia o timeout a cada tecla */
    chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.

    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9,BACKSPACE,RETURN,H",KEYFUNCTION(LASTKEY))  THEN
        NEXT.

    IF  KEYFUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            aux_flgvolta = NO.
            APPLY "GO".
        END.

    IF  KEYFUNCTION(LASTKEY) = "H"  THEN
        DO:
            aux_flgvolta = YES.
            APPLY "GO".
        END.

    /* aplica o valor */
    APPLY LASTKEY.

    buff[3] = "      B   " + STRING(INT(ed_qtnotK7B:SCREEN-VALUE),"z,zz9")  + CHR(127) + "  "  +
                             STRING(DEC(ed_vlnotK7B:SCREEN-VALUE),"zz9.99") + "    " +
                             STRING(INT(ed_qtnotK7B:SCREEN-VALUE) * DEC(ed_vlnotK7B:SCREEN-VALUE),"zzz,zz9.99").

    RUN procedures/atualiza_painop.p (INPUT buff).

    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_qtnotk7C
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_qtnotk7C w_manutencao_painop
ON ANY-KEY OF ed_qtnotk7C IN FRAME f_manutencao_painop /* K7C   -   Qtd */
DO:
    /* reinicia o timeout a cada tecla */
    chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.

    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9,BACKSPACE,RETURN,H",KEYFUNCTION(LASTKEY))  THEN
        NEXT.

    IF  KEYFUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            aux_flgvolta = NO.
            APPLY "GO".
        END.

    IF  KEYFUNCTION(LASTKEY) = "H"  THEN
        DO:
            aux_flgvolta = YES.
            APPLY "GO".
        END.

    /* aplica o valor */
    APPLY LASTKEY.

    buff[4] = "      C   " + STRING(INT(ed_qtnotK7C:SCREEN-VALUE),"z,zz9")  + CHR(127) + "  "  +
                             STRING(DEC(ed_vlnotK7C:SCREEN-VALUE),"zz9.99") + "    " +
                             STRING(INT(ed_qtnotK7C:SCREEN-VALUE) * DEC(ed_vlnotK7C:SCREEN-VALUE),"zzz,zz9.99").

    RUN procedures/atualiza_painop.p (INPUT buff).

    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_qtnotk7D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_qtnotk7D w_manutencao_painop
ON ANY-KEY OF ed_qtnotk7D IN FRAME f_manutencao_painop /* K7D   -   Qtd */
DO:
    /* reinicia o timeout a cada tecla */
    chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.

    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9,BACKSPACE,RETURN,H",KEYFUNCTION(LASTKEY))  THEN
        NEXT.

    IF  KEYFUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            aux_flgvolta = NO.
            APPLY "GO".
        END.

    IF  KEYFUNCTION(LASTKEY) = "H"  THEN
        DO:
            aux_flgvolta = YES.
            APPLY "GO".
        END.

    /* aplica o valor */
    APPLY LASTKEY.

    buff[5] = "      D   " + STRING(INT(ed_qtnotK7D:SCREEN-VALUE),"z,zz9")  + CHR(127) + "  "  +
                             STRING(DEC(ed_vlnotK7D:SCREEN-VALUE),"zz9.99") + "    " +
                             STRING(INT(ed_qtnotK7D:SCREEN-VALUE) * DEC(ed_vlnotK7D:SCREEN-VALUE),"zzz,zz9.99").

    RUN procedures/atualiza_painop.p (INPUT buff).

    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_vlnotk7A
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_vlnotk7A w_manutencao_painop
ON ANY-KEY OF ed_vlnotk7A IN FRAME f_manutencao_painop /* Valor */
DO:
    /***** nao permitido alterar o valor das notas a partir de 29/08/2013 *****
    
    /* reinicia o timeout a cada tecla */
    chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.

    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9,BACKSPACE,RETURN,H",KEYFUNCTION(LASTKEY))  THEN
        NEXT.

    IF  KEYFUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            aux_flgvolta = NO.
            APPLY "GO".
        END.

    IF  KEYFUNCTION(LASTKEY) = "H"  THEN
        DO:
            aux_flgvolta = YES.
            APPLY "GO".
        END.

    /* aplica o valor */
    APPLY LASTKEY.

    buff[2] = "      A   " + STRING(INT(ed_qtnotK7A:SCREEN-VALUE),"z,zz9")  + "   "  +
                             STRING(DEC(ed_vlnotK7A:SCREEN-VALUE),"zz9.99") + CHR(127) + "   " +
                             STRING(INT(ed_qtnotK7A:SCREEN-VALUE) * DEC(ed_vlnotK7A:SCREEN-VALUE),"zzz,zz9.99").

    RUN procedures/atualiza_painop.p (INPUT buff).

    RETURN NO-APPLY.
    *****/
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_vlnotk7B
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_vlnotk7B w_manutencao_painop
ON ANY-KEY OF ed_vlnotk7B IN FRAME f_manutencao_painop /* Valor */
DO:
    /***** nao permitido alterar o valor das notas a partir de 29/08/2013 *****
    
    /* reinicia o timeout a cada tecla */
    chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.

    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9,BACKSPACE,RETURN,H",KEYFUNCTION(LASTKEY))  THEN
        NEXT.

    IF  KEYFUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            aux_flgvolta = NO.
            APPLY "GO".
        END.

    IF  KEYFUNCTION(LASTKEY) = "H"  THEN
        DO:
            aux_flgvolta = YES.
            APPLY "GO".
        END.

    /* aplica o valor */
    APPLY LASTKEY.

    buff[3] = "      B   " + STRING(INT(ed_qtnotK7B:SCREEN-VALUE),"z,zz9")  + "   "  +
                             STRING(DEC(ed_vlnotK7B:SCREEN-VALUE),"zz9.99") + CHR(127) + "   " +
                             STRING(INT(ed_qtnotK7B:SCREEN-VALUE) * DEC(ed_vlnotK7B:SCREEN-VALUE),"zzz,zz9.99").

    RUN procedures/atualiza_painop.p (INPUT buff).

    RETURN NO-APPLY.
    
    *****/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_vlnotk7C
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_vlnotk7C w_manutencao_painop
ON ANY-KEY OF ed_vlnotk7C IN FRAME f_manutencao_painop /* Valor */
DO:
    /***** nao permitido alterar o valor das notas a partir de 29/08/2013 *****
    
    /* reinicia o timeout a cada tecla */
    chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.

    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9,BACKSPACE,RETURN,H",KEYFUNCTION(LASTKEY))  THEN
        NEXT.

    IF  KEYFUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            aux_flgvolta = NO.
            APPLY "GO".
        END.

    IF  KEYFUNCTION(LASTKEY) = "H"  THEN
        DO:
            aux_flgvolta = YES.
            APPLY "GO".
        END.

    /* aplica o valor */
    APPLY LASTKEY.

    buff[4] = "      C   " + STRING(INT(ed_qtnotK7C:SCREEN-VALUE),"z,zz9")  + "   "  +
                             STRING(DEC(ed_vlnotK7C:SCREEN-VALUE),"zz9.99") + CHR(127) + "   " +
                             STRING(INT(ed_qtnotK7C:SCREEN-VALUE) * DEC(ed_vlnotK7C:SCREEN-VALUE),"zzz,zz9.99").

    RUN procedures/atualiza_painop.p (INPUT buff).

    RETURN NO-APPLY.
    
    *****/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_vlnotk7D
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_vlnotk7D w_manutencao_painop
ON ANY-KEY OF ed_vlnotk7D IN FRAME f_manutencao_painop /* Valor */
DO:
    /***** nao permitido alterar o valor das notas a partir de 29/08/2013 *****
    
    /* reinicia o timeout a cada tecla */
    chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.

    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9,BACKSPACE,RETURN,H",KEYFUNCTION(LASTKEY))  THEN
        NEXT.

    IF  KEYFUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            aux_flgvolta = NO.
            APPLY "GO".
        END.

    IF  KEYFUNCTION(LASTKEY) = "H"  THEN
        DO:
            aux_flgvolta = YES.
            APPLY "GO".
        END.

    /* aplica o valor */
    APPLY LASTKEY.

    buff[5] = "      D   " + STRING(INT(ed_qtnotK7D:SCREEN-VALUE),"z,zz9")  + "   "  +
                             STRING(DEC(ed_vlnotK7D:SCREEN-VALUE),"zz9.99") + CHR(127) + "   " +
                             STRING(INT(ed_qtnotK7D:SCREEN-VALUE) * DEC(ed_vlnotK7D:SCREEN-VALUE),"zzz,zz9.99").

    RUN procedures/atualiza_painop.p (INPUT buff).

    RETURN NO-APPLY.
    
    *****/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed_vlsaqnot
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed_vlsaqnot w_manutencao_painop
ON ANY-KEY OF ed_vlsaqnot IN FRAME f_manutencao_painop /* Valor */
DO:
    /* reinicia o timeout a cada tecla */
    chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.

    IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9,BACKSPACE,RETURN,H",KEYFUNCTION(LASTKEY))  THEN
        NEXT.

    IF  KEYFUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            aux_flgvolta = NO.
            APPLY "GO".
        END.

    IF  KEYFUNCTION(LASTKEY) = "H"  THEN
        DO:
            aux_flgvolta = YES.
            APPLY "GO".
        END.

    /* aplica o valor */
    APPLY LASTKEY.

    /* desenha a tela */
    ASSIGN buff[4] = "           VALOR: "    + STRING(INT(ed_vlsaqnot:SCREEN-VALUE),"z,zz9.99") + CHR(127).

    RUN procedures/atualiza_painop.p (INPUT buff).

    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_manutencao_painop OCX.Tick
PROCEDURE temporizador.t_manutencao_painop.Tick .
aux_flgvolta = YES.

/* cancela o que estiver fazendo */
APPLY "END-ERROR".

APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_manutencao_painop 


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


RUN enable_UI.
           
h_principal:MOVE-TO-TOP().

ASSIGN chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor
       aux_flgvolta = NO.

RUN mensagem.w (INPUT YES,
                INPUT "    ATENÇÃO",
                INPUT "",
                INPUT "",
                INPUT "TAA em Manutenção!",
                INPUT "",
                INPUT "").

/* desabilita o teclado frontal */
RUN WinAtualizaEstadoTeclados IN aux_xfsliteh (
    INPUT  1, /* teclado frontal */
    INPUT  0, /* desabilita varredura */
    INPUT -1, /* StaBeep - nao altera */
    INPUT -1, /* Led1 - nao altera */
    INPUT -1, /* Led2 - nao altera */
    INPUT -1, /* FlickerCrt - nao altera */
    INPUT -1, /* FlickerDispCel - nao altera */
    INPUT -1, /* FlickerPtr - nao altera */
    INPUT -1, /* Solenoide - nao altera */
    OUTPUT LT_Resp).

buff = "".
RUN procedures/atualiza_painop.p (INPUT buff).

buff[4] = "     TECLADO FRONTAL DESABILITADO".
RUN procedures/atualiza_painop.p (INPUT buff).

PAUSE 2 NO-MESSAGE.

IF NOT xfs_impressora  OR
   xfs_impsempapel  THEN
DO:
    ASSIGN buff = "".
    RUN procedures/atualiza_painop.p (INPUT buff).
    
    ASSIGN buff[2] = "             AGUARDE..."
           buff[4] = "       IMPRESSORA INOPERANTE".
    RUN procedures/atualiza_painop.p (INPUT buff).
    
    PAUSE 3 NO-MESSAGE.
END.


/* verifica o status da impressora */
RUN procedures/inicializa_dispositivo.p ( INPUT 6,
                                         OUTPUT aux_flgderro).


RUN leitura_cartao (OUTPUT aux_flgderro).

IF  NOT aux_flgderro THEN
    DO  WHILE TRUE:

        RUN pede_senha (OUTPUT aux_flgderro).

        IF  aux_flgderro  THEN
            NEXT.
        
        RUN menu_manutencao.

        IF  aux_flgvolta  THEN
            LEAVE.
    END.

  
APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE abertura w_manutencao_painop 
PROCEDURE abertura :
RUN procedures/efetua_abertura.p (OUTPUT aux_flgderro).

    buff = "".
    RUN procedures/atualiza_painop.p (INPUT buff).

    IF  aux_flgderro  THEN
        ASSIGN buff[2] = "      NAO FOI POSSIVEL EFETUAR"
               buff[4] = "              A ABERTURA".
    ELSE
        ASSIGN buff[4] = "    ABERTURA EFETUADA COM SUCESSO".
            
        
    RUN procedures/atualiza_painop.p (INPUT buff).
    PAUSE 2 NO-MESSAGE.

    RUN procedures/carrega_suprimento.p (OUTPUT aux_flgderro).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_manutencao_painop  _CONTROL-LOAD
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

OCXFile = SEARCH( "manutencao_painop.wrx":U ).
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
ELSE MESSAGE "manutencao_painop.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_manutencao_painop  _DEFAULT-DISABLE
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
  HIDE FRAME f_manutencao_painop.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_manutencao_painop  _DEFAULT-ENABLE
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
  DISPLAY ed_dscartao ed_nrsencar ed_opcao_menu_manutencao 
          ed_opcao_menu_configuracao ed_opcao_menu_temporizador ed_hrininot 
          ed_hrfimnot ed_vlsaqnot ed_opcao_menu_recolhimento ed_opcao_situacao 
          ed_qtnotk7A ed_vlnotk7A ed_qtnotk7B ed_vlnotk7B ed_qtnotk7C 
          ed_vlnotk7C ed_qtnotk7D ed_vlnotk7D ed_opcao_suprimento 
      WITH FRAME f_manutencao_painop.
  ENABLE RECT-104 INRECT-105 INRECT-106 ed_dscartao ed_nrsencar 
         ed_opcao_menu_manutencao ed_opcao_menu_configuracao 
         ed_opcao_menu_temporizador ed_hrininot ed_hrfimnot ed_vlsaqnot 
         ed_opcao_menu_recolhimento ed_opcao_situacao ed_qtnotk7A ed_vlnotk7A 
         ed_qtnotk7B ed_vlnotk7B ed_qtnotk7C ed_vlnotk7C ed_qtnotk7D 
         ed_vlnotk7D ed_opcao_suprimento 
      WITH FRAME f_manutencao_painop.
  {&OPEN-BROWSERS-IN-QUERY-f_manutencao_painop}
  VIEW w_manutencao_painop.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fechamento w_manutencao_painop 
PROCEDURE fechamento :
RUN procedures/efetua_fechamento.p (OUTPUT aux_flgderro).

    buff = "".
    RUN procedures/atualiza_painop.p (INPUT buff).

    IF  aux_flgderro  THEN
        ASSIGN buff[2] = "      NAO FOI POSSIVEL EFETUAR"
               buff[4] = "             O FECHAMENTO".
    ELSE
        ASSIGN buff[4] = "   FECHAMENTO EFETUADO COM SUCESSO".
            
        
    RUN procedures/atualiza_painop.p (INPUT buff).
    PAUSE 2 NO-MESSAGE.

    RUN procedures/carrega_suprimento.p (OUTPUT aux_flgderro).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE leitura_cartao w_manutencao_painop 
PROCEDURE leitura_cartao :
DEF OUTPUT PARAM par_flgderro   AS LOGICAL  INIT YES        NO-UNDO.    
    
    /* limpa os dados de cartao ja lido pelo sistema */
    ASSIGN glb_cdcooper = 0
           glb_cdagectl = 0
           glb_nmrescop = ""
           glb_nrcartao = 0
           glb_nrdconta = 0
           glb_nmtitula = "".


    /* Variaveis para a Leitora de passagem */
    DEFINE VARIABLE aux_qtcartao         AS INTEGER      NO-UNDO.
    DEFINE VARIABLE mem_qtcartao1        AS MEMPTR       NO-UNDO.
    DEFINE VARIABLE mem_dscartao1        AS MEMPTR       NO-UNDO.
    DEFINE VARIABLE mem_qtcartao2        AS MEMPTR       NO-UNDO.
    DEFINE VARIABLE mem_dscartao2        AS MEMPTR       NO-UNDO.
    DEFINE VARIABLE mem_qtcartao3        AS MEMPTR       NO-UNDO.
    DEFINE VARIABLE mem_dscartao3        AS MEMPTR       NO-UNDO.

    DO  WHILE TRUE:

        /* reinicia o timeout para nova tentativa */
        chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.


        buff = "".
        RUN procedures/atualiza_painop.p (INPUT buff).
        
        
        ASSIGN buff[3] = "          PASSE SEU CARTAO".
        RUN procedures/atualiza_painop.p (INPUT buff).
        
        
        SET-SIZE(mem_qtcartao1) = 10.       /* 9 posições + "\0"  */
        SET-SIZE(mem_dscartao1) = 51.       /* 50 posições + "\0"  */
        SET-SIZE(mem_qtcartao2) = 10.       /* 9 posições + "\0"  */
        SET-SIZE(mem_dscartao2) = 51.       /* 50 posições + "\0"  */
        SET-SIZE(mem_qtcartao3) = 10.       /* 9 posições + "\0"  */
        SET-SIZE(mem_dscartao3) = 51.       /* 50 posições + "\0"  */
        
        /* nao le trilha 1 */
        PUT-STRING(mem_qtcartao2,1)= '0'.
        PUT-STRING(mem_dscartao2,1)= ''.
        
        /* le trilha 2 */
        PUT-STRING(mem_qtcartao2,1)= '10'.
        PUT-STRING(mem_dscartao2,1)= '51'.
        
        /* nao le trilha 3 */
        PUT-STRING(mem_qtcartao2,1)= '0'.
        PUT-STRING(mem_dscartao2,1)= ''.
        
        
        RUN WinLeSincronoCartaoPassagemEx IN aux_xfsliteh
            (INPUT 2, /* teclado PAINOP */
             INPUT 3, /* timeout 3s */
             INPUT GET-POINTER-VALUE(mem_qtcartao1),
             INPUT GET-POINTER-VALUE(mem_dscartao1),
             INPUT GET-POINTER-VALUE(mem_qtcartao2),
             INPUT GET-POINTER-VALUE(mem_dscartao2),
             INPUT GET-POINTER-VALUE(mem_qtcartao3),
             INPUT GET-POINTER-VALUE(mem_dscartao3),
             OUTPUT LT_Resp).
        
        
        ASSIGN ed_dscartao:SCREEN-VALUE IN FRAME f_manutencao_painop =
                              '2ç' + TRIM(GET-STRING(mem_dscartao2,1)) + ':' 
               aux_qtcartao = ASC(GET-STRING(mem_qtcartao2,1)).
        
        
        /* Libera a memória */
        SET-SIZE(mem_qtcartao1) = 0.
        SET-SIZE(mem_dscartao1) = 0.
        SET-SIZE(mem_qtcartao2) = 0.
        SET-SIZE(mem_dscartao2) = 0.
        SET-SIZE(mem_qtcartao3) = 0.
        SET-SIZE(mem_dscartao3) = 0.


        /* se deu erro que nao seja timeout */
        IF  LT_Resp <> 0   AND
            LT_Resp <> 54  THEN
            DO:
                ASSIGN buff[5]      = "  ERRO DE LEITURA! TENTE NOVAMENTE!"
                       par_flgderro = YES.
                
                RUN procedures/atualiza_painop.p (INPUT buff).
                PAUSE 2 NO-MESSAGE.

                NEXT.
            END.

        
        /* cartao lido com sucesso */
        IF  LT_resp = 0  THEN
            DO:
                RUN procedures/valida_cartao.p (INPUT  ed_dscartao:SCREEN-VALUE,
                                                OUTPUT glb_idsenlet,
                                                OUTPUT par_flgderro).
        
                IF  par_flgderro  THEN
                    NEXT.

                /* Verifica se eh cartao magnetico e somente cartão de operador */
                IF  glb_idtipcar = 2 OR (glb_idtipcar = 1 AND SUBSTRING(STRING(glb_nrcartao),1,1) <> "9")  THEN /* cartão de usuário */
                    DO:
                        ASSIGN buff[5]      = "           CARTAO INVALIDO"
                               par_flgderro = YES.

                        RUN procedures/atualiza_painop.p (INPUT buff).
                        PAUSE 2 NO-MESSAGE.
                        NEXT.
                    END.
            END.

        LEAVE.

    END. /* Fim do WHILE */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE menu_configuracao w_manutencao_painop 
PROCEDURE menu_configuracao :
DO  WHILE TRUE:

        /* reinicia o timeout */
        chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.
    
        buff = "".
        RUN procedures/atualiza_painop.p (INPUT buff).
    
        ASSIGN buff[1] = "         MENU DE CONFIGURACAO"
               buff[2] = "A - TEMPORIZADOR     SAQUE NOTURNO - E"
               buff[6] = "ESCOLHA A OPCAO |  ~"ANULA~" P/ RETORNAR".
    
        RUN procedures/atualiza_painop.p (INPUT buff).
    
        UPDATE ed_opcao_menu_configuracao WITH FRAME f_manutencao_painop.    
    
    
        /* TEMPORIZADOR */
        IF  KEYFUNCTION(LASTKEY) = "A"  THEN
            RUN menu_temporizador.
        ELSE
        /* SAQUE NOTURNO */
        IF  KEYFUNCTION(LASTKEY) = "E"  THEN
            RUN menu_saque_noturno.
        ELSE
        /* VOLTAR */
        IF  KEYFUNCTION(LASTKEY) = "H"  THEN
            DO:
                aux_flgvolta = YES.
                LEAVE.
            END.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE menu_manutencao w_manutencao_painop 
PROCEDURE menu_manutencao :
DEFINE VARIABLE aux_flgopcaoA AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE aux_flgopcaoB AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE aux_flgopcaoE AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE aux_flgopcaoF AS LOGICAL     NO-UNDO.

    DO  WHILE TRUE:
    
        /* reinicia o timeout */
        chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.
    
        ASSIGN buff = ""
               aux_flgopcaoA = NO
               aux_flgopcaoB = NO
               aux_flgopcaoE = NO
               aux_flgopcaoF = NO.

        RUN procedures/atualiza_painop.p (INPUT buff).
    
    
        /* Situações do TAA */

        /* Fechado */
        IF  glb_cdsittfn = 2  THEN
            ASSIGN buff[2]       = "A - ABERTURA                          "
                   aux_flgopcaoA = YES.
    
                                   
        /* Suprido */
        IF  glb_flgsupri  THEN
            ASSIGN buff[3]       = "B - RECOLHIMENTO                      "
                   aux_flgopcaoB = YES.
        ELSE
            DO:
                /* se nao estiver suprido e nao tiver envelopes */
                IF  glb_qtenvelo = 0  THEN
                    ASSIGN buff[3]       = "                        SUPRIMENTO - F"
                           aux_flgopcaoF = YES.
                ELSE
                    ASSIGN buff[3]       = "B - RECOLHIMENTO        SUPRIMENTO - F"
                           aux_flgopcaoB = YES
                           aux_flgopcaoF = YES.
            END.

    
    
        ASSIGN buff[1] = "         MENU DE MANUTENCAO"
               buff[4] = "C - SITUACAO             REINICIAR - G"
               buff[5] = "D - CONFIGURACAO"
               buff[6] = "ESCOLHA A OPCAO |  ~"ANULA~" P/ RETORNAR".
    
        RUN procedures/atualiza_painop.p (INPUT buff).
    
        UPDATE ed_opcao_menu_manutencao WITH FRAME f_manutencao_painop.
    

        /* zera o timeout */
        chtemporizador:t_manutencao_painop:INTERVAL = 0.


        /* ABERTURA */
        IF  KEYFUNCTION(LASTKEY) = "A"  AND
            aux_flgopcaoA               THEN
            RUN abertura.
        ELSE
        IF  KEYFUNCTION(LASTKEY) = "B"  AND
            aux_flgopcaoB               THEN
            RUN menu_recolhimento.
        ELSE
        IF  KEYFUNCTION(LASTKEY) = "C"  THEN
            RUN situacao.
        ELSE
        IF  KEYFUNCTION(LASTKEY) = "D"  THEN
            RUN menu_configuracao.
        ELSE
        IF  KEYFUNCTION(LASTKEY) = "F"   AND
            aux_flgopcaoF                THEN
            RUN suprimento.
        ELSE
        /* REINICIAR */
        IF  KEYFUNCTION(LASTKEY) = "G"  THEN
            RUN procedures/efetua_reboot.p.
        ELSE
        /* VOLTAR */
        IF  KEYFUNCTION(LASTKEY) = "H"  THEN
            DO:
                aux_flgvolta = YES.
                LEAVE.
            END.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE menu_recolhimento w_manutencao_painop 
PROCEDURE menu_recolhimento :
DEFINE VARIABLE aux_flgopcaoA AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE aux_flgopcaoE AS LOGICAL     NO-UNDO.

    DO  WHILE TRUE:

        /* reinicia o timeout */
        ASSIGN chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor
               aux_flgopcaoA = NO
               aux_flgopcaoE = NO.
    
        buff = "".
        RUN procedures/atualiza_painop.p (INPUT buff).
    
        ASSIGN buff[1] = "         MENU DE RECOLHIMENTO".

        /* TAA suprido - Com envelopes */
        IF  glb_flgsupri AND glb_qtenvelo > 0  THEN
            ASSIGN buff[2]       = "A - NUMERARIOS           ENVELOPES - E"
                   aux_flgopcaoA = YES
                   aux_flgopcaoE = YES.
        ELSE
        /* TAA suprido - Sem envelopes */
        IF  glb_flgsupri AND glb_qtenvelo = 0  THEN
            ASSIGN buff[2]       = "A - NUMERARIOS"
                   aux_flgopcaoA = YES.
        ELSE
        /* TAA nao suprido - Com envelopes */
        IF  NOT glb_flgsupri AND glb_qtenvelo > 0  THEN
            ASSIGN buff[2]       = "                         ENVELOPES - E"
                   aux_flgopcaoE = YES.

        ASSIGN buff[4] = "ATENCAO! PUXE A IMPRESSORA PARA PEGAR"
               buff[5] = "    O COMPROVANTE DE RECOLHIMENTO"
               buff[6] = "ESCOLHA A OPCAO |  ~"ANULA~" P/ RETORNAR".
    
        RUN procedures/atualiza_painop.p (INPUT buff).
    
        UPDATE ed_opcao_menu_recolhimento WITH FRAME f_manutencao_painop.    

        /* zera o timeout */
        chtemporizador:t_manutencao_painop:INTERVAL = 0.
    
    
        /* VOLTAR */
        IF  KEYFUNCTION(LASTKEY) = "H"  THEN
            DO:
                aux_flgvolta = YES.
                LEAVE.
            END.
        ELSE
        /* Se tiver alguma opcao para escolher */
        IF  glb_flgsupri OR glb_qtenvelo > 0  THEN
            DO:
                /* NUMERARIOS */
                IF  KEYFUNCTION(LASTKEY) = "A"  AND
                    aux_flgopcaoA               THEN
                    RUN procedures/efetua_recolhimento.p ( INPUT 1,
                                                          OUTPUT aux_flgderro).
                ELSE
                /* ENVELOPES */
                IF  KEYFUNCTION(LASTKEY) = "E"  AND 
                    aux_flgopcaoE               THEN
                    RUN procedures/efetua_recolhimento.p ( INPUT 2,
                                                          OUTPUT aux_flgderro).
                ELSE
                    NEXT.

                IF  NOT aux_flgderro  THEN
                    DO:
                        buff = "".
                        RUN procedures/atualiza_painop.p (INPUT buff).

                        buff[4] = "  RECOLHIMENTO EFETUADO COM SUCESSO".

                        RUN procedures/atualiza_painop.p (INPUT buff).
                        PAUSE 2 NO-MESSAGE.
                    END.


                RUN procedures/carrega_suprimento.p (OUTPUT aux_flgderro).
            END.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE menu_saque_noturno w_manutencao_painop 
PROCEDURE menu_saque_noturno :
DO  WITH FRAME f_manutencao_painop:
    
    /* reinicia o timeout */
    chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.



    /* carrega os dados */
    ASSIGN ed_hrininot:SCREEN-VALUE = SUBSTRING(STRING(glb_hrininot,"HH:MM:SS"),1,2) +
                                      SUBSTRING(STRING(glb_hrininot,"HH:MM:SS"),4,2)

           ed_hrfimnot:SCREEN-VALUE = SUBSTRING(STRING(glb_hrfimnot,"HH:MM:SS"),1,2) + 
                                      SUBSTRING(STRING(glb_hrfimnot,"HH:MM:SS"),4,2)
        
           ed_vlsaqnot:SCREEN-VALUE = STRING(glb_vlsaqnot).

    /* grava o valor nos campos */
    ASSIGN ed_hrininot
           ed_hrfimnot
           ed_vlsaqnot.


    buff = "".
    RUN procedures/atualiza_painop.p (INPUT buff).
    

    ASSIGN buff[1] = "    CONFIGURACAO DO SAQUE NOTURNO"
           buff[2] = "         INICIAL:    " + STRING(ed_hrininot:SCREEN-VALUE,"xx:xx") + CHR(127)
           buff[3] = "           FINAL:    " + STRING(ed_hrfimnot:SCREEN-VALUE,"xx:xx") + " "
           buff[4] = "           VALOR: "    + STRING(INT(ed_vlsaqnot:SCREEN-VALUE),"z,zz9.99") + " "
           buff[6] = "INFORME OS DADOS | ~"ANULA~" P/ RETORNAR".

    RUN procedures/atualiza_painop.p (INPUT buff).

    UPDATE ed_hrininot WITH FRAME f_manutencao_painop.

    IF  aux_flgvolta  THEN
        LEAVE.
    
    ASSIGN buff[2] = "         INICIAL:    " + STRING(ed_hrininot:SCREEN-VALUE,"xx:xx") + " "
           buff[3] = "           FINAL:    " + STRING(ed_hrfimnot:SCREEN-VALUE,"xx:xx") + CHR(127)
           buff[4] = "           VALOR: "    + STRING(INT(ed_vlsaqnot:SCREEN-VALUE),"z,zz9.99") + " ".

    RUN procedures/atualiza_painop.p (INPUT buff).

    UPDATE ed_hrfimnot WITH FRAME f_manutencao_painop.

    IF  aux_flgvolta  THEN
        LEAVE.
    
    ASSIGN buff[2] = "         INICIAL:    " + STRING(ed_hrininot:SCREEN-VALUE,"xx:xx") + " "
           buff[3] = "           FINAL:    " + STRING(ed_hrfimnot:SCREEN-VALUE,"xx:xx") + " "
           buff[4] = "           VALOR: "    + STRING(INT(ed_vlsaqnot:SCREEN-VALUE),"z,zz9.99") + CHR(127).

    RUN procedures/atualiza_painop.p (INPUT buff).

    UPDATE ed_vlsaqnot WITH FRAME f_manutencao_painop.

    IF  aux_flgvolta  THEN
        LEAVE.

    /* zera o timeout */
    chtemporizador:t_manutencao_painop:INTERVAL = 0.

    RUN procedures/configura_saque_noturno.p ( INPUT INT(SUBSTRING(ed_hrininot:SCREEN-VALUE,1,2)),
                                               INPUT INT(SUBSTRING(ed_hrininot:SCREEN-VALUE,3,2)),
                                               INPUT INT(SUBSTRING(ed_hrfimnot:SCREEN-VALUE,1,2)),
                                               INPUT INT(SUBSTRING(ed_hrfimnot:SCREEN-VALUE,3,2)),
                                               INPUT DEC(ed_vlsaqnot:SCREEN-VALUE),
                                               OUTPUT aux_flgderro).


    IF  NOT aux_flgderro  THEN
        DO:
            buff = "".
            RUN procedures/atualiza_painop.p (INPUT buff).

            ASSIGN buff[2] = "       CONFIGURACOES EFETUADAS"
                   buff[4] = "             COM SUCESSO".
            
            RUN procedures/atualiza_painop.p (INPUT buff).    

            PAUSE 2 NO-MESSAGE.
        END.
END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE menu_temporizador w_manutencao_painop 
PROCEDURE menu_temporizador :
DO  WHILE TRUE:
    
        /* reinicia o timeout */
        chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.
    
        buff = "".
        RUN procedures/atualiza_painop.p (INPUT buff).
    
        ASSIGN buff[1] = "     CONFIGURACAO DO TEPORIZADOR"
               buff[2] = "A - 10 SEGUNDOS"
               buff[3] = "B - 20 SEGUNDOS"
               buff[4] = "C - 30 SEGUNDOS"
               buff[6] = "ESCOLHA A OPCAO |  ~"ANULA~" P/ RETORNAR".
    
        RUN procedures/atualiza_painop.p (INPUT buff).
    
        UPDATE ed_opcao_menu_temporizador WITH FRAME f_manutencao_painop.    

        /* zera o timeout */
        chtemporizador:t_manutencao_painop:INTERVAL = 0.
    
    
        IF  KEYFUNCTION(LASTKEY) = "A"  THEN
            RUN procedures/configura_temporizador( INPUT 10,
                                                  OUTPUT aux_flgderro).
        ELSE
        IF  KEYFUNCTION(LASTKEY) = "B"  THEN
            RUN procedures/configura_temporizador( INPUT 20,
                                                  OUTPUT aux_flgderro).
        ELSE
        IF  KEYFUNCTION(LASTKEY) = "C"  THEN
            RUN procedures/configura_temporizador( INPUT 30,
                                                  OUTPUT aux_flgderro).
        ELSE
        /* VOLTAR */
        IF  KEYFUNCTION(LASTKEY) = "H"  THEN
            DO:
                aux_flgvolta = YES.
                LEAVE.
            END.

    
        IF  NOT aux_flgderro  THEN
            DO:
                buff = "".
                RUN procedures/atualiza_painop.p (INPUT buff).
    
                ASSIGN buff[2] = "       CONFIGURACOES EFETUADAS"
                       buff[4] = "             COM SUCESSO".
                
                RUN procedures/atualiza_painop.p (INPUT buff).    
    
                PAUSE 2 NO-MESSAGE.
            END.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pede_senha w_manutencao_painop 
PROCEDURE pede_senha :
DEF OUTPUT PARAM par_flgderro   AS LOGICAL  INIT YES        NO-UNDO.        

    /* reinicia o timeout */
    ASSIGN chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor
           aux_flgvolta = NO.

    RUN procedures/busca_operador ( INPUT STRING(glb_nrdconta),
                                    OUTPUT aux_nmoperad,
                                    OUTPUT par_flgderro).

    buff = "".
    RUN procedures/atualiza_painop.p (INPUT buff).

    ASSIGN buff[2] = "OPERADOR: " + STRING(glb_nrdconta,"zzzzzzzzz9") + " - " +
                                    SUBSTRING(aux_nmoperad,1,16)
           buff[4] = "   SENHA:        " + CHR(127)

           /* default, erro, se senha estiver ok, fica NO */
           par_flgderro = YES.

    RUN procedures/atualiza_painop.p (INPUT buff).  

    UPDATE ed_nrsencar WITH FRAME f_manutencao_painop.

    
    IF  NOT aux_flgvolta  THEN
        RUN procedures/valida_senha.p (INPUT ENCODE(ed_nrsencar:SCREEN-VALUE),
                                       OUTPUT par_flgderro).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE situacao w_manutencao_painop 
PROCEDURE situacao :
/* reinicia o timeout */
    chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor.
    
    buff = "".
    RUN procedures/atualiza_painop.p (INPUT buff).
    
    ASSIGN buff[1] = "CASSETE     QTD    VALOR         TOTAL"

           buff[2] = "      A   " + STRING(glb_qtnotK7A,"z,zz9")  + "   "  +
                                    STRING(glb_vlnotK7A,"zz9.99") + "    " +
                                    STRING(glb_qtnotK7A * glb_vlnotK7A,"zzz,zz9.99")

           buff[3] = "      B   " + STRING(glb_qtnotK7B,"z,zz9")  + "   "  +
                                    STRING(glb_vlnotK7B,"zz9.99") + "    " +
                                    STRING(glb_qtnotK7B * glb_vlnotK7B,"zzz,zz9.99")
           
           buff[4] = "      C   " + STRING(glb_qtnotK7C,"z,zz9")  + "   "  +
                                    STRING(glb_vlnotK7C,"zz9.99") + "    " +
                                    STRING(glb_qtnotK7C * glb_vlnotK7C,"zzz,zz9.99")

           buff[5] = "      D   " + STRING(glb_qtnotK7D,"z,zz9")  + "   "  +
                                    STRING(glb_vlnotK7D,"zz9.99") + "    " +
                                    STRING(glb_qtnotK7D * glb_vlnotK7D,"zzz,zz9.99")

           buff[6] = "   PRESSIONE ~"ENTRA~" PARA CONTINUAR".

    RUN procedures/atualiza_painop.p (INPUT buff).
    
    UPDATE ed_opcao_situacao WITH FRAME f_manutencao_painop.






    buff = "".
    RUN procedures/atualiza_painop.p (INPUT buff).

    ASSIGN buff[1] = "CASSETE     QTD    VALOR         TOTAL"

           buff[2] = "      R   " + STRING(glb_qtnotK7R,"z,zz9")  + "             " +
                                    STRING(glb_vlnotK7R,"zzz,zz9.99")
        
           buff[3] = "  TOTAL   " + "                  " +
                                    STRING((glb_qtnotK7A * glb_vlnotK7A) +
                                           (glb_qtnotK7B * glb_vlnotK7B) +
                                           (glb_qtnotK7C * glb_vlnotK7C) +
                                           (glb_qtnotK7D * glb_vlnotK7D) +
                                            glb_vlnotK7R,"zzz,zz9.99")

           buff[4] = "ENVELOPES: " + STRING(glb_qtenvelo,"z,zz9")

           buff[6] = "   PRESSIONE ~"ENTRA~" PARA RETORNAR".

    RUN procedures/atualiza_painop.p (INPUT buff).
    
    UPDATE ed_opcao_situacao WITH FRAME f_manutencao_painop.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE suprimento w_manutencao_painop 
PROCEDURE suprimento :
DO  WITH FRAME f_manutencao_painop:

DO  WHILE TRUE:
    
    /* reinicia o timeout */
    ASSIGN chtemporizador:t_manutencao_painop:INTERVAL = glb_nrtempor
           aux_flgderro = NO.
    
    buff = "".
    RUN procedures/atualiza_painop.p (INPUT buff).
    
    /* Desenha a tela inicial */
    ASSIGN buff[1] = "CASSETE     QTD    VALOR         TOTAL"
           buff[2] = "      A   " + STRING(INT(ed_qtnotK7A:SCREEN-VALUE),"z,zz9")  + "   "  +
                                    STRING(DEC(ed_vlnotK7A:SCREEN-VALUE),"zz9.99") + "    " +
                                    STRING(INT(ed_qtnotK7A:SCREEN-VALUE) * DEC(ed_vlnotK7A:SCREEN-VALUE),"zzz,zz9.99")

           buff[3] = "      B   " + STRING(INT(ed_qtnotK7B:SCREEN-VALUE),"z,zz9")  + "   "  +
                                    STRING(DEC(ed_vlnotK7B:SCREEN-VALUE),"zz9.99") + "    " +
                                    STRING(INT(ed_qtnotK7B:SCREEN-VALUE) * DEC(ed_vlnotK7B:SCREEN-VALUE),"zzz,zz9.99")

           buff[4] = "      C   " + STRING(INT(ed_qtnotK7C:SCREEN-VALUE),"z,zz9")  + "   "  +
                                    STRING(DEC(ed_vlnotK7C:SCREEN-VALUE),"zz9.99") + "    " +
                                    STRING(INT(ed_qtnotK7C:SCREEN-VALUE) * DEC(ed_vlnotK7C:SCREEN-VALUE),"zzz,zz9.99")
           
           buff[5] = "      D   " + STRING(INT(ed_qtnotK7D:SCREEN-VALUE),"z,zz9")  + "   "  +
                                    STRING(DEC(ed_vlnotK7D:SCREEN-VALUE),"zz9.99") + "    " +
                                    STRING(INT(ed_qtnotK7D:SCREEN-VALUE) * DEC(ed_vlnotK7D:SCREEN-VALUE),"zzz,zz9.99")
           buff[6] = "INFORME OS DADOS | ~"ANULA~" P/ RETORNAR".

    RUN procedures/atualiza_painop.p (INPUT buff).
    





    /* Desenha com foco no campo */
    buff[2] = "      A   " + STRING(INT(ed_qtnotK7A:SCREEN-VALUE),"z,zz9")  + CHR(127) + "  "  +
                             STRING(DEC(ed_vlnotK7A:SCREEN-VALUE),"zz9.99") + "    " +
                             STRING(INT(ed_qtnotK7A:SCREEN-VALUE) * DEC(ed_vlnotK7A:SCREEN-VALUE),"zzz,zz9.99").

    RUN procedures/atualiza_painop.p (INPUT buff).

    UPDATE ed_qtnotk7A WITH FRAME f_manutencao_painop.

    IF  aux_flgvolta  THEN
        LEAVE.




    /***** nao permitido alterar o valor das notas a partir de 29/08/2013 *****
    
    /* Desenha com foco no campo */
    buff[2] = "      A   " + STRING(INT(ed_qtnotK7A:SCREEN-VALUE),"z,zz9")  + "   "  +
                             STRING(DEC(ed_vlnotK7A:SCREEN-VALUE),"zz9.99") + CHR(127) + "   " +
                             STRING(INT(ed_qtnotK7A:SCREEN-VALUE) * DEC(ed_vlnotK7A:SCREEN-VALUE),"zzz,zz9.99").

    RUN procedures/atualiza_painop.p (INPUT buff).

    UPDATE ed_vlnotk7A WITH FRAME f_manutencao_painop.

    IF  aux_flgvolta  THEN
        LEAVE.
        
    *****/





    /* Desenha com foco no campo */
    ASSIGN buff[2] = "      A   " + STRING(INT(ed_qtnotK7A:SCREEN-VALUE),"z,zz9")  + "   "  +
                                    STRING(DEC(ed_vlnotK7A:SCREEN-VALUE),"zz9.99") + "    " +
                                    STRING(INT(ed_qtnotK7A:SCREEN-VALUE) * DEC(ed_vlnotK7A:SCREEN-VALUE),"zzz,zz9.99")
         
           buff[3] = "      B   " + STRING(INT(ed_qtnotK7B:SCREEN-VALUE),"z,zz9")  + CHR(127) + "  "  +
                                    STRING(DEC(ed_vlnotK7B:SCREEN-VALUE),"zz9.99") + "    " +
                                    STRING(INT(ed_qtnotK7B:SCREEN-VALUE) * DEC(ed_vlnotK7B:SCREEN-VALUE),"zzz,zz9.99").

    RUN procedures/atualiza_painop.p (INPUT buff).

    UPDATE ed_qtnotk7B WITH FRAME f_manutencao_painop.

    IF  aux_flgvolta  THEN
        LEAVE.



    /***** nao permitido alterar o valor das notas a partir de 29/08/2013 *****

    /* Desenha com foco no campo */
    buff[3] = "      B   " + STRING(INT(ed_qtnotK7B:SCREEN-VALUE),"z,zz9")  + "   "  +
                             STRING(DEC(ed_vlnotK7B:SCREEN-VALUE),"zz9.99") + CHR(127) + "   " +
                             STRING(INT(ed_qtnotK7B:SCREEN-VALUE) * DEC(ed_vlnotK7B:SCREEN-VALUE),"zzz,zz9.99").

    RUN procedures/atualiza_painop.p (INPUT buff).

    UPDATE ed_vlnotk7B WITH FRAME f_manutencao_painop.

    IF  aux_flgvolta  THEN
        LEAVE.

    *****/




    /* Desenha com foco no campo */
    ASSIGN buff[3] = "      B   " + STRING(INT(ed_qtnotK7B:SCREEN-VALUE),"z,zz9")  + "   "  +
                                    STRING(DEC(ed_vlnotK7B:SCREEN-VALUE),"zz9.99") + "    " +
                                    STRING(INT(ed_qtnotK7B:SCREEN-VALUE) * DEC(ed_vlnotK7B:SCREEN-VALUE),"zzz,zz9.99")

           buff[4] = "      C   " + STRING(INT(ed_qtnotK7C:SCREEN-VALUE),"z,zz9")  + CHR(127) + "  "  +
                                    STRING(DEC(ed_vlnotK7C:SCREEN-VALUE),"zz9.99") + "    " +
                                    STRING(INT(ed_qtnotK7C:SCREEN-VALUE) * DEC(ed_vlnotK7C:SCREEN-VALUE),"zzz,zz9.99").
           
    RUN procedures/atualiza_painop.p (INPUT buff).

    UPDATE ed_qtnotk7C WITH FRAME f_manutencao_painop.

    IF  aux_flgvolta  THEN
        LEAVE.



    /***** nao permitido alterar o valor das notas a partir de 29/08/2013 *****

    /* Desenha com foco no campo */
    buff[4] = "      C   " + STRING(INT(ed_qtnotK7C:SCREEN-VALUE),"z,zz9")  + "   "  +
                             STRING(DEC(ed_vlnotK7C:SCREEN-VALUE),"zz9.99") + CHR(127) + "   " +
                             STRING(INT(ed_qtnotK7C:SCREEN-VALUE) * DEC(ed_vlnotK7C:SCREEN-VALUE),"zzz,zz9.99").

    RUN procedures/atualiza_painop.p (INPUT buff).

    UPDATE ed_vlnotk7C WITH FRAME f_manutencao_painop.

    IF  aux_flgvolta  THEN
        LEAVE.

    *****/




    /* Desenha com foco no campo */
    ASSIGN buff[4] = "      C   " + STRING(INT(ed_qtnotK7C:SCREEN-VALUE),"z,zz9")  + "   "  +
                                    STRING(DEC(ed_vlnotK7C:SCREEN-VALUE),"zz9.99") + "    " +
                                    STRING(INT(ed_qtnotK7C:SCREEN-VALUE) * DEC(ed_vlnotK7C:SCREEN-VALUE),"zzz,zz9.99").
       
           buff[5] = "      D   " + STRING(INT(ed_qtnotK7D:SCREEN-VALUE),"z,zz9")  + CHR(127) + "  "  +
                                    STRING(DEC(ed_vlnotK7D:SCREEN-VALUE),"zz9.99") + "    " +
                                    STRING(INT(ed_qtnotK7D:SCREEN-VALUE) * DEC(ed_vlnotK7D:SCREEN-VALUE),"zzz,zz9.99").
       
    RUN procedures/atualiza_painop.p (INPUT buff).

    UPDATE ed_qtnotk7D WITH FRAME f_manutencao_painop.

    IF  aux_flgvolta  THEN
        LEAVE.





    /***** nao permitido alterar o valor das notas a partir de 29/08/2013 *****

    /* Desenha com foco no campo */
    buff[5] = "      D   " + STRING(INT(ed_qtnotK7D:SCREEN-VALUE),"z,zz9")  + "   "  +
                             STRING(DEC(ed_vlnotK7D:SCREEN-VALUE),"zz9.99") + CHR(127) + "   " +
                             STRING(INT(ed_qtnotK7D:SCREEN-VALUE) * DEC(ed_vlnotK7D:SCREEN-VALUE),"zzz,zz9.99").

    RUN procedures/atualiza_painop.p (INPUT buff).

    UPDATE ed_vlnotk7D WITH FRAME f_manutencao_painop.

    IF  aux_flgvolta  THEN
        LEAVE.

    *****/



    ASSIGN ed_qtnotK7A
           ed_qtnotK7B
           ed_qtnotK7C
           ed_qtnotK7D
           
           ed_vlnotK7A
           ed_vlnotK7B
           ed_vlnotK7C
           ed_vlnotK7D.



    /***** nao permitido alterar o valor das notas a partir de 29/08/2013 *****
    
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

    IF  aux_flgderro  THEN
        DO:
            buff = "".
            RUN procedures/atualiza_painop.p (INPUT buff).

            buff[4] = "          VALORES INVALIDOS".
            RUN procedures/atualiza_painop.p (INPUT buff).

            PAUSE 2 NO-MESSAGE.
            NEXT.
        END.
        
    *****/

    /* Suprimento Zerado */
    IF  ed_qtnotK7A = 0  AND
        ed_qtnotK7B = 0  AND
        ed_qtnotK7C = 0  AND
        ed_qtnotK7D = 0  THEN
        DO:
            buff = "".
            RUN procedures/atualiza_painop.p (INPUT buff).
                                       
            buff[4] = "           SUPRIMENTO ZERADO".
            RUN procedures/atualiza_painop.p (INPUT buff).
    
            PAUSE 2 NO-MESSAGE.
            NEXT.
        END.



    buff = "".
    RUN procedures/atualiza_painop.p (INPUT buff).

    ASSIGN buff[1] = "        CONFIRMA SUPRIMENTO NO"
           buff[2] = "          VALOR DE " + STRING((ed_qtnotK7A * ed_vlnotK7A) +
                                                    (ed_qtnotK7B * ed_vlnotK7B) +
                                                    (ed_qtnotK7C * ed_vlnotK7C) +
                                                    (ed_qtnotK7D * ed_vlnotK7D),"zzz,zz9.99")
           buff[4] = "ATENCAO! PUXE A IMPRESSORA PARA PEGAR"
           buff[5] = "     O COMPROVANTE DE SUPRIMENTO"
           buff[6] = "~"ENTER~"-CONFIRMAR  |  ~"ANULA~"-RETORNAR".

    RUN procedures/atualiza_painop.p (INPUT buff).

    UPDATE ed_opcao_suprimento WITH FRAME f_manutencao_painop.

    IF  aux_flgvolta  THEN
        LEAVE.


    /* zera o timeout */
    chtemporizador:t_manutencao_painop:INTERVAL = 0.

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

    RUN procedures/carrega_suprimento.p (OUTPUT aux_flgderro).
    

    LEAVE.

END. /* Fim WHILE */

END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

