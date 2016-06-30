&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w_impressao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w_impressao 
/* ..............................................................................

Procedure: impressao_visualiza.w
Objetivo : Visualização EM TELA
Autor    : Lucas Lunelli
Data     : Agosto 2015

Ultima alteração: 

29/06/2016 #413717 Desabilitado o botao imprimir (Btn_G) quando houver problema 
           na impressora. Alterado o label de "Voltar" para "Finalizar" (Carlos)

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
DEFINE INPUT PARAM  par_dsdocmto    AS CHAR                     NO-UNDO.
DEFINE INPUT PARAM  par_tximpres    AS CHAR                     NO-UNDO.
DEFINE INPUT PARAM  par_tpimpres    AS INTE                     NO-UNDO. /* Tipo de Impressão */
DEFINE INPUT PARAM  par_dsdparam    AS CHAR                     NO-UNDO. /* Parâmetro Genérico, varia da acordo com par_tpimpres */

/* Local Variable Definitions ---                                       */
{ includes/var_taa.i }
{ includes/var_xfs_lite.i }

DEFINE VARIABLE     aux_contador    AS INTEGER                  NO-UNDO.
DEFINE VARIABLE     aux_txtimpre    AS CHARACTER                NO-UNDO. /* Texto a ser Impresso */
DEFINE VARIABLE     aux_txtdispl    AS CHARACTER                NO-UNDO. /* Texto a ser Exibido */
DEFINE VARIABLE     aux_posatual    AS INTEGER INIT 0           NO-UNDO. /* Retorno de posição para paginação */
DEFINE VARIABLE     imp_dadosimp    AS MEMPTR                   NO-UNDO.
DEFINE VARIABLE     aux_flgderro    AS LOGICAL                  NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f_impressao

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_E ed_impressao Btn_G Btn_H Btn_F 
&Scoped-Define DISPLAYED-OBJECTS ed_impressao 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w_impressao AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE temporizador AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chtemporizador AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_E 
     IMAGE-UP FILE "Imagens/seta_up.gif":U NO-FOCUS
     LABEL "SOBRE" 
     SIZE 13.4 BY 2.38
     FONT 8.

DEFINE BUTTON Btn_F 
     IMAGE-UP FILE "Imagens/seta_down.gif":U NO-FOCUS
     LABEL "DESCE" 
     SIZE 13.4 BY 2.29
     FONT 8.

DEFINE BUTTON Btn_G 
     LABEL "IMPRIMIR" 
     SIZE 41 BY 3.33
     FONT 8.

DEFINE BUTTON Btn_H 
     LABEL "FINALIZAR" 
     SIZE 41 BY 3.33
     FONT 8.

DEFINE VARIABLE ed_impressao AS CHARACTER 
     VIEW-AS EDITOR NO-WORD-WRAP
     SIZE 69 BY 27.38
     BGCOLOR 15 FONT 0 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f_impressao
     Btn_E AT ROW 9.62 COL 124.6 WIDGET-ID 68
     ed_impressao AT ROW 1.52 COL 25 NO-LABEL WIDGET-ID 2
     Btn_G AT ROW 19.1 COL 110 WIDGET-ID 86
     Btn_H AT ROW 24.1 COL 110 WIDGET-ID 74
     Btn_F AT ROW 14.67 COL 124.6 WIDGET-ID 220
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
  CREATE WINDOW w_impressao ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 28.57
         WIDTH              = 160
         MAX-HEIGHT         = 29.05
         MAX-WIDTH          = 184.8
         VIRTUAL-HEIGHT     = 29.05
         VIRTUAL-WIDTH      = 184.8
         SHOW-IN-TASKBAR    = no
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
ASSIGN w_impressao = CURRENT-WINDOW.




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w_impressao
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f_impressao
   NOT-VISIBLE FRAME-NAME                                               */
ASSIGN 
       ed_impressao:READ-ONLY IN FRAME f_impressao        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME temporizador ASSIGN
       FRAME           = FRAME f_impressao:HANDLE
       ROW             = 2.19
       COLUMN          = 9
       HEIGHT          = 1.67
       WIDTH           = 7
       TAB-STOP        = no
       WIDGET-ID       = 76
       HIDDEN          = yes
       SENSITIVE       = yes.
/* temporizador OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: t_impressao */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w_impressao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_impressao w_impressao
ON END-ERROR OF w_impressao
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w_impressao w_impressao
ON WINDOW-CLOSE OF w_impressao
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_E
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_impressao
ON ANY-KEY OF Btn_E IN FRAME f_impressao /* SOBRE */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_E w_impressao
ON CHOOSE OF Btn_E IN FRAME f_impressao /* SOBRE */
DO:
    RUN paginacao (INPUT par_tximpres,
                   INPUT FALSE, /* SOBE */
                   INPUT-OUTPUT aux_posatual,
                  OUTPUT aux_txtdispl).

    IF  RETURN-VALUE = "OK"  THEN
        DO:
            ed_impressao:SCREEN-VALUE = "".
            ed_impressao:INSERT-STRING(aux_txtdispl).
        END.

    RETURN "OK".
   
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_F
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_impressao
ON ANY-KEY OF Btn_F IN FRAME f_impressao /* DESCE */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_F w_impressao
ON CHOOSE OF Btn_F IN FRAME f_impressao /* DESCE */
DO:    
    RUN paginacao (INPUT par_tximpres,
                   INPUT TRUE, /* DESCE */
                   INPUT-OUTPUT aux_posatual,
                  OUTPUT aux_txtdispl).

    IF  RETURN-VALUE = "OK"  THEN
        DO:
            ed_impressao:SCREEN-VALUE = "".
            ed_impressao:INSERT-STRING(aux_txtdispl).
        END.

    RETURN "OK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_G
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_impressao
ON ANY-KEY OF Btn_G IN FRAME f_impressao /* IMPRIMIR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_G w_impressao
ON CHOOSE OF Btn_G IN FRAME f_impressao /* IMPRIMIR */
DO:
    IF  par_tpimpres = 1 THEN
        RUN procedures/lanca_tarifa_extrato.p ( INPUT DATE(par_dsdparam), /* dtiniext */
                                               OUTPUT aux_flgderro).

    /* monta var de texto para impressao separado por "ENTER" */
    DO  aux_contador = 1 TO LENGTH(par_tximpres) BY 48:
        aux_txtimpre = aux_txtimpre + (SUBSTRING(par_tximpres,aux_contador,48) + CHR(13)).
    END.

    RUN realiza-impressao (INPUT aux_txtimpre).

    ASSIGN aux_txtimpre = "".

    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
    RETURN "OK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_H
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_impressao
ON ANY-KEY OF Btn_H IN FRAME f_impressao /* FINALIZAR */
DO:
    RUN tecla.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_H w_impressao
ON CHOOSE OF Btn_H IN FRAME f_impressao /* FINALIZAR */
DO:
    APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.  
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temporizador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temporizador w_impressao OCX.Tick
PROCEDURE temporizador.t_impressao.Tick .
APPLY "CHOOSE" TO Btn_H IN FRAME f_impressao.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w_impressao 


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

MAIN-BLOCK:
DO  ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    RUN enable_UI.

    /* deixa o mouse transparente */
    FRAME f_impressao:LOAD-MOUSE-POINTER("blank.cur").

    /* Se a impressora nao estiver disponivel, 
       desabilita o botao de impressao */
    IF    xfs_painop_em_uso OR 
      NOT xfs_impressora    OR
          xfs_impsempapel  THEN    
    DISABLE Btn_G WITH FRAME f_impressao.

    IF  LENGTH(par_tximpres) > 1872 THEN
        ASSIGN Btn_E:VISIBLE IN FRAME f_impressao = TRUE
               Btn_F:VISIBLE IN FRAME f_impressao = TRUE.
    ELSE 
        ASSIGN Btn_E:VISIBLE IN FRAME f_impressao = FALSE
               Btn_F:VISIBLE IN FRAME f_impressao = FALSE.

    RUN paginacao (INPUT par_tximpres,
                   INPUT TRUE, /* DESCE */
                   INPUT-OUTPUT aux_posatual,
                  OUTPUT aux_txtdispl).

    ed_impressao:INSERT-STRING(aux_txtdispl).

    chtemporizador:t_impressao:INTERVAL = glb_nrtempor + 5000. /* + 5s */.

    /* coloca o foco na conta */
    APPLY "ENTRY" TO Btn_H.

    IF  NOT THIS-PROCEDURE:PERSISTENT  THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.        
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load w_impressao  _CONTROL-LOAD
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

OCXFile = SEARCH( "impressao_visualiza.wrx":U ).
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
ELSE MESSAGE "impressao_visualiza.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w_impressao  _DEFAULT-DISABLE
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
  HIDE FRAME f_impressao.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w_impressao  _DEFAULT-ENABLE
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
  DISPLAY ed_impressao 
      WITH FRAME f_impressao.
  ENABLE Btn_E ed_impressao Btn_G Btn_H Btn_F 
      WITH FRAME f_impressao.
  {&OPEN-BROWSERS-IN-QUERY-f_impressao}
  VIEW w_impressao.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE paginacao w_impressao 
PROCEDURE paginacao :
/* Pagina impressao */

    DEFINE INPUT        PARAM  par_impressao   AS CHAR               NO-UNDO.
    DEFINE INPUT        PARAM  par_flgorien    AS LOGI               NO-UNDO.
    DEFINE INPUT-OUTPUT PARAM  par_posatual    AS INTE               NO-UNDO.
    DEFINE OUTPUT       PARAM  par_txtdispl    AS CHAR               NO-UNDO.
    
    DEFINE VARIABLE     aux_cntposic     AS INTE                     NO-UNDO.
    DEFINE VARIABLE     tmp_posatual     AS INTE                     NO-UNDO.
    DEFINE VARIABLE     aux_tmptexto     AS CHAR                     NO-UNDO.

    IF  par_flgorien = FALSE        AND /* SOBE */
       (par_posatual -  1872) <= 0  THEN       
        RETURN "NOK".

    ASSIGN tmp_posatual = par_posatual.

    IF  par_posatual > 0 THEN
        DO:
            IF  par_flgorien = TRUE THEN
                ASSIGN par_posatual = par_posatual + 1872.
            ELSE
                ASSIGN par_posatual = par_posatual - 1872.
        END.
    ELSE
        ASSIGN par_posatual = 1.

    aux_tmptexto = SUBSTRING(par_impressao, par_posatual, 1872).

    IF  LENGTH(aux_tmptexto) <= 0 THEN
        DO:
            ASSIGN par_posatual = tmp_posatual.
            RETURN "NOK".
        END.
        

    DO  aux_cntposic = 1 TO LENGTH(aux_tmptexto) BY 48:
        par_txtdispl = par_txtdispl + SUBSTRING(aux_tmptexto,aux_cntposic,48) + CHR(13).
    END.

    RETURN "OK".
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE realiza-impressao w_impressao 
PROCEDURE realiza-impressao :
DEFINE INPUT PARAM  par_impressao    AS CHAR                     NO-UNDO.

    IF  NOT xfs_painop_em_uso  THEN
        DO:
            RUN mensagem.w (INPUT NO,
                            INPUT " IMPRIMINDO",
                            INPUT "",
                            INPUT "",
                            INPUT par_dsdocmto,
                            INPUT "",
                            INPUT "").
            
            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.
        END.
    
    
    IF  xfs_impressora       AND
        NOT xfs_impsempapel  THEN
        DO:
            SET-SIZE(imp_dadosimp) = LENGTH(par_impressao) + 1.
             
            PUT-STRING(imp_dadosimp,1) = par_impressao + CHR(0).
    
            RUN WinImprimePrtCh IN aux_xfsliteh 
                (INPUT  0,
                 INPUT  GET-POINTER-VALUE(imp_dadosimp),
                 INPUT  LENGTH(par_impressao) + 1,
                 OUTPUT LT_Resp).
             
            SET-SIZE(imp_dadosimp) = 0.
             
            IF  LT_Resp <> 0  THEN
                DO: 
                    IF  NOT xfs_painop_em_uso  THEN
                        DO:
                            RUN mensagem.w (INPUT YES,
                                            INPUT "   ATENÇÃO",
                                            INPUT "",
                                            INPUT "",
                                            INPUT "Erro na impressão.",
                                            INPUT "",
                                            INPUT "").
                            
                            PAUSE 3 NO-MESSAGE.
                            h_mensagem:HIDDEN = YES.
                        END.
                END.
             ELSE
                DO:
                    RUN WinCutPrtCh IN aux_xfsliteh (OUTPUT LT_Resp).
    
                    IF  LT_Resp <> 0  THEN
                        DO: 
                            IF  NOT xfs_painop_em_uso  THEN
                                DO:
                                    RUN mensagem.w (INPUT YES,
                                                    INPUT "   ATENÇÃO",
                                                    INPUT "",
                                                    INPUT "",
                                                    INPUT "Erro no corte do papel.",
                                                    INPUT "",
                                                    INPUT "").
                                    
                                    PAUSE 3 NO-MESSAGE.
                                    h_mensagem:HIDDEN = YES.
                                END.
                        END.
                    ELSE
                        IF  NOT xfs_painop_em_uso  THEN
                            DO:
                                aux_contador = 0.
        
                                DO WHILE TRUE:
        
                                    IF  aux_contador = 5  THEN
                                        DO:
                                            h_mensagem:HIDDEN = YES.
                                            LEAVE.
                                        END.
        
                                    IF  aux_contador = 0  THEN
                                        RUN mensagem.w (INPUT NO,
                                                        INPUT "   ATENÇÃO",
                                                        INPUT "",
                                                        INPUT "",
                                                        INPUT "Retire o papel da impressão.",
                                                        INPUT "",
                                                        INPUT "").
        
                                    RUN procedures/inicializa_dispositivo.p (INPUT 6,
                                                                            OUTPUT aux_flgderro).
        
                                    IF  NOT xfs_imppapelsaida  THEN
                                        DO:
                                            h_mensagem:HIDDEN = YES.
                                            LEAVE.
                                        END.
                                    ELSE
                                        DO:
                                            PAUSE 1 NO-MESSAGE.
                                            aux_contador = aux_contador + 1.
                                            NEXT.
                                        END.
        
                                END.
                            END.
                END.
        END.

    RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tecla w_impressao 
PROCEDURE tecla :
chtemporizador:t_impressao:INTERVAL = 0.

    IF  KEY-FUNCTION(LASTKEY) = "G"                     AND
        Btn_G:SENSITIVE IN FRAME f_impressao  THEN
        APPLY "CHOOSE" TO Btn_G.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "H"                     AND
        Btn_H:SENSITIVE IN FRAME f_impressao  THEN
        APPLY "CHOOSE" TO Btn_H.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "E"                     AND    /* Sobe */
        Btn_E:SENSITIVE IN FRAME f_impressao  THEN
        APPLY "CHOOSE" TO Btn_E.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "F"                     AND    /* Desce */
        Btn_F:SENSITIVE IN FRAME f_impressao  THEN
        APPLY "CHOOSE" TO Btn_F.
    ELSE
        RETURN NO-APPLY.

    chtemporizador:t_impressao:INTERVAL = glb_nrtempor + 5000. /* + 5s */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

