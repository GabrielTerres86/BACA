/*..............................................................................

Programa: siscaixa/web/crap087.w
Sistema : CAIXA ON-LINE
Sigla   : CRED                               Ultima atualizacao: 27/08/2014
   
Dados referentes ao programa:

Objetivo  : Entrada de Arrecadacoes GPS - Faturas.

Alteracoes: 27/08/2014 - Ajustes referente a homologacao com o SICREDI
                        (Adriano).
            03/01/2018 - M307 - Solicitaçao de senha do coordenador quando 
                             valor do pagamento for superior ao limite cadastrado 
                             na CADCOP / CADPAC
                            (Diogo - MoutS)


..............................................................................*/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
    
/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD vh_foco         AS CHARACTER FORMAT "X(256)":U 
       FIELD vh_nome         AS CHARACTER FORMAT "X(256)":U    
       FIELD v_msg           AS CHARACTER FORMAT "X(256)":U 
       FIELD proximo         AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cntanter      AS CHARACTER FORMAT "X(256)":U
       FIELD v_coop          AS CHARACTER FORMAT "X(256)":U
       FIELD v_pac           AS CHARACTER FORMAT "X(256)":U
       FIELD v_caixa         AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador      AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data          AS CHARACTER FORMAT "X(256)":U
       FIELD v_conta         AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nome          AS CHARACTER FORMAT "X(256)":U 
       FIELD tpdpagto        AS CHARACTER FORMAT "X(256)":U 
       FIELD v_codbarras     AS CHARACTER FORMAT "X(256)":U
       FIELD v_codigo        AS CHARACTER FORMAT "X(256)":U 
       FIELD v_competencia   AS CHARACTER FORMAT "X(256)":U 
       FIELD v_identificador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_valorins      AS CHARACTER FORMAT "X(256)":U 
       FIELD v_valorout      AS CHARACTER FORMAT "X(256)":U
       FIELD v_valorjur      AS CHARACTER FORMAT "X(256)":U
       FIELD v_valortot      AS CHARACTER FORMAT "X(256)":U
       FIELD v_vencimento    AS CHARACTER FORMAT "X(256)":U 
       FIELD inpesgps        AS CHARACTER FORMAT "X(256)":U
       FIELD h_inpesgps      AS CHARACTER FORMAT "X(256)":U
       FIELD h_tpdpagto      AS CHARACTER FORMAT "X(256)":U
       FIELD h_idleitor      AS CHARACTER FORMAT "X(256)":U
       FIELD v_cod           AS CHARACTER FORMAT "X(256)":U
       FIELD v_senha         AS CHARACTER FORMAT "X(256)":U.

DEF TEMP-TABLE tt-conta
    FIELD situacao           as char format "x(21)"
    field tipo-conta         as char format "x(21)"
    field empresa            AS  char format "x(15)"
    field devolucoes         AS inte format "99"
    field agencia            AS char format "x(15)"
    field magnetico          as inte format "z9"     
    field estouros           as inte format "zzz9"
    field folhas             as inte format "zzz,zz9"
    field identidade         AS CHAR 
    field orgao              AS CHAR 
    field cpfcgc             AS CHAR 
    field disponivel         AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD bloqueado          AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    field bloq-praca         AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    field bloq-fora-praca    AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    field cheque-salario     AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    field saque-maximo       AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    field acerto-conta       AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    field db-cpmf            AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    field limite-credito     AS DEC 
    field ult-atualizacao    AS DATE
    field saldo-total        AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD nome-tit           AS CHAR
    FIELD nome-seg-tit       AS CHAR
    FIELD capital            AS DEC FORMAT "zzz,zzz,zzz,zz9.99-".

DEF VAR aux_linhadig AS CHAR NO-UNDO.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-html 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 

------------------------------------------------------------------------*/
/*           This .W file was created with AppBuilder.                  */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Preprocessor Definitions ---                                         */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

{dbo/bo-erro1.i}


DEF VAR h_b1crap87   AS HANDLE                                      NO-UNDO.
DEF VAR h_b1crap00   AS HANDLE                                      NO-UNDO.
DEF VAR h_b1crap02   AS HANDLE                                      NO-UNDO.
DEF VAR h_b1wgen0091 AS HANDLE                                      NO-UNDO.
                                                                      
DEF VAR p-literal        AS CHAR                                    NO-UNDO.
DEF VAR p-ult-sequencia  AS INTE                                    NO-UNDO.
DEF VAR c-fnc-javascript AS CHAR                                    NO-UNDO.
DEF VAR aux_codbarras    AS CHAR                                    NO-UNDO.
DEF VAR aux_msgalerta    AS CHAR                                    NO-UNDO.

DEF VAR l-houve-erro     AS LOG                                     NO-UNDO.
DEF VAR lstLib           AS CHAR                                    NO-UNDO.

DEF TEMP-TABLE tt-erro NO-UNDO LIKE craperr.

DEF TEMP-TABLE w-craperr  NO-UNDO
     FIELD cdcooper   LIKE craperr.cdcooper
     FIELD cdagenci   LIKE craperr.cdagenc
     FIELD nrdcaixa   LIKE craperr.nrdcaixa
     FIELD nrsequen   LIKE craperr.nrsequen
     FIELD cdcritic   LIKE craperr.cdcritic
     FIELD dscritic   LIKE craperr.dscritic
     FIELD erro       LIKE craperr.erro.


/***********************************************************************
 * GLOBAIS carregadas dentro de i-global.i que eh chamado dentro de    *
 * process-web-request                                                 *
 ***********************************************************************/
DEFINE VARIABLE glb_cdcooper LIKE crapcop.cdcooper              NO-UNDO.
DEFINE VARIABLE glb_nmrescop LIKE crapcop.nmrescop              NO-UNDO.
DEFINE VARIABLE glb_dtmvtolt LIKE crapdat.dtmvtolt              NO-UNDO.
DEFINE VARIABLE glb_dtmvtopr LIKE crapdat.dtmvtopr              NO-UNDO.
DEFINE VARIABLE glb_dtmvtoan LIKE crapdat.dtmvtoan              NO-UNDO.
DEFINE VARIABLE glb_cdagenci LIKE crapass.cdagenci              NO-UNDO.
DEFINE VARIABLE glb_cdbccxlt LIKE craptit.cdbccxlt              NO-UNDO.
DEFINE VARIABLE glb_cdoperad LIKE crapope.cdoperad              NO-UNDO.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE crap087.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS   ab_unmap.vh_foco  ab_unmap.vh_nome  ab_unmap.v_msg  ab_unmap.proximo  ab_unmap.v_cntanter  ab_unmap.v_coop  ab_unmap.v_pac  ab_unmap.v_caixa  ab_unmap.v_operador  ab_unmap.v_data  ab_unmap.v_conta ab_unmap.v_nome  ab_unmap.tpdpagto  ab_unmap.v_codbarras  ab_unmap.v_codigo  ab_unmap.v_competencia  ab_unmap.v_identificador  ab_unmap.v_valorins  ab_unmap.v_valorout  ab_unmap.v_valorjur  ab_unmap.v_valortot  ab_unmap.v_vencimento  ab_unmap.inpesgps ab_unmap.h_inpesgps ab_unmap.h_tpdpagto ab_unmap.h_idleitor ab_unmap.v_cod ab_unmap.v_senha
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.vh_foco  ab_unmap.vh_nome  ab_unmap.v_msg  ab_unmap.proximo  ab_unmap.v_cntanter  ab_unmap.v_coop  ab_unmap.v_pac  ab_unmap.v_caixa  ab_unmap.v_operador  ab_unmap.v_data  ab_unmap.v_conta ab_unmap.v_nome  ab_unmap.tpdpagto  ab_unmap.v_codbarras  ab_unmap.v_codigo  ab_unmap.v_competencia  ab_unmap.v_identificador  ab_unmap.v_valorins  ab_unmap.v_valorout  ab_unmap.v_valorjur  ab_unmap.v_valortot  ab_unmap.v_vencimento  ab_unmap.inpesgps ab_unmap.h_inpesgps ab_unmap.h_tpdpagto ab_unmap.h_idleitor ab_unmap.v_cod ab_unmap.v_senha

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.vh_foco AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1    
    ab_unmap.vh_nome AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_msg AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.proximo AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_cntanter AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_coop AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_pac AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_caixa AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_operador AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_data AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_conta AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_nome AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.tpdpagto AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
                    "radio 0", "1":U,
                    "radio 1", "2":U,
                    "radio",   "0":U
          SIZE 20 BY 4
    ab_unmap.v_codbarras  AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 60 BY 1
    ab_unmap.v_codigo AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1 
    ab_unmap.v_competencia AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN
          SIZE 20 BY 1
    ab_unmap.v_identificador AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_valorins AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1 
    ab_unmap.v_valorout AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_valorjur AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_valortot AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_vencimento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.h_inpesgps AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.h_tpdpagto AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.h_idleitor AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.inpesgps AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
                    "radio", "1":U,
                    "radio", "2":U,
                    "radio", "0":U
          SIZE 20 BY 3
    ab_unmap.v_cod AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_senha AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1          
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 60.6 BY 14.19.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Web-Object
   Allow: Query
   Frames: 1
   Add Fields to: Neither
   Editing: Special-Events-Only
   Events: web.output,web.input
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: ab_unmap W "?" ?  
      ADDITIONAL-FIELDS:
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD tpdpagto AS CHARACTER 
          FIELD inpesgps AS CHARACTER
          FIELD h_inpesgps AS CHARACTER
          FIELD h_tpdpagto AS CHARACTER          
          FIELD h_idleitor AS CHARACTER
          FIELD v_codbarras AS CHARACTER FORMAT "X(256)":U
          FIELD v_codigo AS CHARACTER FORMAT "X(256)":U 
          FIELD v_mes AS CHARACTER FORMAT "X(256)":U 
          FIELD v_ano AS CHARACTER FORMAT "X(256)":U 
          FIELD v_identificador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_vencimento AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valorins AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valorout AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valorjur AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valortot AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cod AS CHARACTER FORMAT "X(256)":U 
          FIELD v_senha AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 14.19
         WIDTH              = 60.6.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-html 
/* *********************** Included-Libraries ************************* */

{src/web2/html-map.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-html
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME Web-Frame
   UNDERLINE                                                            */
/* SETTINGS FOR FILL-IN ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.vh_foco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_caixa IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR RADIO-SET ab_unmap.tpdpagto IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR RADIO-SET ab_unmap.inpesgps IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR RADIO-SET ab_unmap.h_inpesgps IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR RADIO-SET ab_unmap.h_tpdpagto IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR RADIO-SET ab_unmap.h_idleitor IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.v_codbarras IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_codigo IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_mes IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_ano IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_identificador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_vencimento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_valorins IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_valorout IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_valorjur IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_valortot IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cod IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_senha IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-html 


/* ************************  Main Code Block  ************************* */

/* Standard Main Block that runs adm-create-objects, initializeObject 
 * and process-web-request.
 * The bulk of the web processing is in the Procedure process-web-request
 * elsewhere in this Web object.
 */
{src/web2/template/hmapmain.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects w-html  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE carregaCooperativa w-html 

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE htmOffsets w-html  _WEB-HTM-OFFSETS
PROCEDURE htmOffsets :
/*------------------------------------------------------------------------------
  Purpose:     Runs procedure to associate each HTML field with its
               corresponding widget name and handle.
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
  RUN readOffsets ("{&WEB-FILE}":U).

  RUN htmAssociate ("vh_foco":U,"ab_unmap.vh_foco":U,ab_unmap.vh_foco:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("vh_nome":U,"ab_unmap.vh_nome":U,ab_unmap.vh_nome:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("proximo":U,"ab_unmap.proximo":U,ab_unmap.proximo:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("v_cntanter":U,"ab_unmap.v_cntanter":U,ab_unmap.v_cntanter:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate ("v_caixa":U,"ab_unmap.v_caixa":U,ab_unmap.v_caixa:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("v_conta":U,"ab_unmap.v_conta":U,ab_unmap.v_conta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("v_nome":U,"ab_unmap.v_nome":U,ab_unmap.v_nome:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("tpdpagto":U,"ab_unmap.tpdpagto":U,ab_unmap.tpdpagto:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("v_codbarras":U,"ab_unmap.v_codbarras":U,ab_unmap.v_codbarras:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("v_codigo":U,"ab_unmap.v_codigo":U,ab_unmap.v_codigo:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("v_competencia":U,"ab_unmap.v_competencia":U,ab_unmap.v_competencia:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("v_identificador":U,"ab_unmap.v_identificador":U,ab_unmap.v_identificador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("v_valorins":U,"ab_unmap.v_valorins":U,ab_unmap.v_valorins:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("v_valorout":U,"ab_unmap.v_valorout":U,ab_unmap.v_valorout:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("v_valorjur":U,"ab_unmap.v_valorjur":U,ab_unmap.v_valorjur:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("v_valortot":U,"ab_unmap.v_valortot":U,ab_unmap.v_valortot:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("v_vencimento":U,"ab_unmap.v_vencimento":U,ab_unmap.v_vencimento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("inpesgps":U,"ab_unmap.inpesgps":U,ab_unmap.inpesgps:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("h_inpesgps":U,"ab_unmap.h_inpesgps":U,ab_unmap.h_inpesgps:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("h_tpdpagto":U,"ab_unmap.h_tpdpagto":U,ab_unmap.h_tpdpagto:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("h_idleitor":U,"ab_unmap.h_idleitor":U,ab_unmap.h_idleitor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("v_cod":U,"ab_unmap.v_cod":U,ab_unmap.v_cod:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate ("v_senha":U,"ab_unmap.v_senha":U,ab_unmap.v_senha:HANDLE IN FRAME {&FRAME-NAME}).

END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE outputHeader w-html 
PROCEDURE outputHeader :
/*------------------------------------------------------------------------
  Purpose:     Output the MIME header, and any "cookie" information needed 
               by this procedure.  
  Parameters:  <none>
  Notes:       In the event that this Web object is state-aware, this is 
               a good place to set the WebState and WebTimeout attributes.
------------------------------------------------------------------------*/

  /* To make this a state-aware Web object, pass in the timeout period
   * (in minutes) before running outputContentType.  If you supply a 
   * timeout period greater than 0, the Web object becomes state-aware 
   * and the following happens:
   *
   *   - 4GL variables webState and webTimeout are set
   *   - a cookie is created for the broker to id the client on the return trip
   *   - a cookie is created to id the correct procedure on the return trip
   *
   * If you supply a timeout period less than 1, the following happens:
   *
   *   - 4GL variables webState and webTimeout are set to an empty string
   *   - a cookie is killed for the broker to id the client on the return trip
   *   - a cookie is killed to id the correct procedure on the return trip
   *
   * For example, set the timeout period to 5 minutes.
   *
   *   setWebState (5.0).
   */
    
  /* Output additional cookie information here before running outputContentType.
   *   For more information about the Netscape Cookie Specification, see
   *   http://home.netscape.com/newsref/std/cookie_spec.html  
   *   
   *   Name         - name of the cookie
   *   Value        - value of the cookie
   *   Expires date - Date to expire (optional). See TODAY function.
   *   Expires time - Time to expire (optional). See TIME function.
   *   Path         - Override default URL path (optional)
   *   Domain       - Override default domain (optional)
   *   Secure       - "secure" or unknown (optional)
   * 
   *   The following example sets custNum=23 and expires tomorrow at (about)
   *   the same time but only for secure (https) connections.
   *      
   *   RUN SetCookie IN web-utilities-hdl 
   *     ("custNum":U, "23":U, TODAY + 1, TIME, ?, ?, "secure":U).
   */ 
  output-content-type ("text/html":U).
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-web-request w-html 
PROCEDURE process-web-request :
/*------------------------------------------------------------------------
  Purpose:     Process the web request.
  Notes:       
------------------------------------------------------------------------*/
    DEF VAR aux_des_erro      AS CHARACTER     NO-UNDO.
    DEF VAR aux_dscritic      AS CHARACTER     NO-UNDO.
    DEF VAR aux_inssenha      AS INTEGER       NO-UNDO.
     
  /* STEP 0 -
   * Output the MIME header and set up the object as state-less or state-aware. 
   * This is required if any HTML is to be returned to the browser. 
   *
   * NOTE: Move 'RUN outputHeader.' to the GET section below if you are going
   * to simulate another Web request by running a Web Object from this
   * procedure.  Running outputHeader precludes setting any additional cookie
   * information.
   */ 

  RUN outputHeader.


   /*******************************************************************
   *                   IMPORTANTE                                    *
   ******************************************************************* 
   *  Include Carrega dados da cooperativa e da data de movimento    *
   *  para temp-table ab_unmap (include/i-global.i)                  *
   *******************************************************************/
  {include/i-global.i}
  /*******************************************************************
   * Estes dados foram carregados para variaveis criadas com prefixo *
   * de "glb_" para simplicar o uso dentro do fonte seguindo padrao  *
   * do ayllos, o find das tabelas esta dentro da include            *
   * (include/i-global.i)                                            *
   *******************************************************************/
  ASSIGN glb_cdcooper = crapcop.cdcooper
         glb_nmrescop = crapcop.nmrescop
         glb_dtmvtolt = crapdat.dtmvtolt
         glb_dtmvtopr = crapdat.dtmvtopr
         glb_dtmvtoan = crapdat.dtmvtoan
         glb_cdagenci = INTE(get-value("user_pac"))
         glb_cdbccxlt = INTE(get-value("user_cx"))
         glb_cdoperad = get-value("operador").


   /* Describe whether to receive FORM input for all the fields.  For example,
   * check particular input fields (using GetField in web-utilities-hdl). 
   * Here we look at REQUEST_METHOD. 
   */

  /* apaga tabela de erros include dbo/bo-erro1.i */
  RUN elimina-erro(INPUT glb_nmrescop,
                   INPUT glb_cdagenci,
                   INPUT glb_cdbccxlt).

  ASSIGN vh_foco          = "13"
         c-fnc-javascript = "".


  IF  REQUEST_METHOD = "POST":U THEN DO:
      /* STEP 1 -
       * Copy HTML input field values to the Progress form buffer. */
      RUN inputFields.

      
      /* STEP 2 -
       * Open the database or SDO query and and fetch the first record. */ 
      /* RUN findRecords. */
      
      /* STEP 3 -    
       * AssignFields will save the data in the frame.
       * (it automatically upgrades the lock to exclusive while doing the update)
       * 
       *  If a new record needs to be created set AddMode to true before 
          running assignFields.  
       *     setAddMode(TRUE).   
       * RUN assignFields. */
      
      {include/assignfields.i}

      RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
                

      /* STEP 4.2b -
       * Enable objects that should be enabled. */
      RUN enableFields.

      IF  get-value("b_cancelar") <> "" THEN DO:
          ASSIGN v_conta     = "0"
                 v_cntanter  = ""
                 v_nome      = ""
                 vh_nome     = ""
                 vh_foco     = "13"
                 proximo     = "0"
                 tpdpagto    = "0"
                 inpesgps    = "0"
                 h_inpesgps  = "0"
                 h_tpdpagto  = "0"
                 h_idleitor  = "0".
      END.
      ELSE
      IF  get-value("b_confirmar") <> "" AND get-value("v_conta") <> "" THEN DO:

          /* Validacao da GPS */
          RUN dbo/b1crap87.p PERSISTENT SET h_b1crap87.
          RUN validar-gps IN h_b1crap87(INPUT v_coop,
                                        INPUT v_pac,
                                        INPUT v_caixa,
                                        INPUT DECI(v_conta),
                                        INPUT v_codbarras,
                                        INPUT h_tpdpagto,
                                        INPUT v_identificador,
                                        INPUT v_codigo,
                                        INPUT v_competencia,
                                        INPUT h_inpesgps,
                                        INPUT v_vencimento,
                                        INPUT v_valorins,
                                        INPUT v_valorout,
                                        INPUT v_valorjur,
                                        INPUT v_valortot,
                                        OUTPUT vh_foco).
          DELETE PROCEDURE h_b1crap87.

          IF  RETURN-VALUE = "NOK" THEN DO:
              ASSIGN proximo = IF h_tpdpagto = "1" THEN "998" ELSE "999".
              /* Exibir o erro */
              {include/i-erro.i}
          END.
          ELSE DO:
          
              RUN valida-valor-limite(INPUT v_coop,
                                      INPUT ab_unmap.v_cod,
                                      INPUT v_pac,
                                      INPUT v_caixa,
                                      INPUT v_valortot,
                                      INPUT ab_unmap.v_senha,
                                      OUTPUT aux_des_erro,
                                      OUTPUT aux_dscritic,
                                      OUTPUT aux_inssenha).
              IF RETURN-VALUE = 'NOK' THEN  
                DO:
                  ASSIGN proximo = IF h_tpdpagto = "1" THEN "998" ELSE "999".
                  {include/i-erro.i}
               END.
              ELSE
                 DO:                           
              /* Efetua o Pagamento */
              RUN dbo/b1crap87.p PERSISTENT SET h_b1crap87.
              RUN pc-efetua-gps-pagamento IN h_b1crap87
                                         (INPUT v_coop,
                                          INPUT v_pac,
                                          INPUT v_caixa,
                                          INPUT v_operador, /* operador */
                                          INPUT v_conta,
                                          INPUT h_tpdpagto,
                                          INPUT h_idleitor, /* idleitur */
                                          INPUT v_codbarras,
                                          INPUT v_codigo,
                                          INPUT v_competencia,
                                          INPUT v_identificador,
                                          INPUT v_valorins,
                                          INPUT v_valorout,
                                          INPUT v_valorjur,
                                          INPUT v_valortot,
                                          INPUT v_vencimento,
                                          INPUT h_inpesgps,
                                          OUTPUT p-literal,
                                          OUTPUT p-ult-sequencia).
              DELETE PROCEDURE h_b1crap87.

              IF  RETURN-VALUE = "NOK" THEN DO:
                  ASSIGN vh_foco = "27"
                         proximo = IF h_tpdpagto = "1" THEN "998" ELSE "999".
                  /* Exibir o erro */
                  {include/i-erro.i}
              END.
              ELSE DO:
                  {&OUT}
                        '<script>window.open("autentica.html?v_plit=" + "' STRING(p-literal) '" + 
                         "&v_pseq=" + "' STRING(p-ult-sequencia) '" + "&v_prec=" + "GPS1"  + "&v_psetcook=" + "YES","waut","width=250,height=145,scrollbars=auto,alwaysRaised=true")
                        </script>'.
                  
                  /* Chama tela de principal */
                  {&OUT} "<script>window.location='crap087.w?redir=1'</script>".
              END.
          END.
      END.
      END.
      ELSE
      IF  get-value("v_codbarras") <> "" AND get-value("b_confirmar") = "" AND INT(ab_unmap.v_cntanter) = INT(ab_unmap.v_conta) THEN DO:

          /* Validacao do Cod.Barras */
          RUN dbo/b1crap87.p PERSISTENT SET h_b1crap87.
          RUN valida-cdbarras-lindigit IN h_b1crap87
                                      (INPUT v_coop,
                                       INPUT v_pac,
                                       INPUT v_caixa,
                                       INPUT v_codbarras,
                                       INPUT 2,
                                       OUTPUT aux_codbarras).
          DELETE PROCEDURE h_b1crap87.
          
          IF  RETURN-VALUE = "NOK" THEN DO:
              ASSIGN v_codbarras = ""
                     proximo = IF h_tpdpagto = "1" THEN "998" ELSE "999".
                     /* Exibir o erro */
                     {include/i-erro.i}
          END.
          ELSE DO:

              /* Atualiza os campos */
              ASSIGN proximo         = "997"
                     vh_foco         = "27"
                     v_codigo        = SUBSTR(aux_codbarras,20,4)
                     v_competencia   = SUBSTR(aux_codbarras,42,2) + "/" + SUBSTR(aux_codbarras,38,4)
                     v_identificador = SUBSTR(aux_codbarras,24,14)
                     v_valorins      = STRING(DECI(SUBSTR(aux_codbarras,5,11)) / 100,"zzz,zzz,zz9.99")
                     v_valorout      = "0,00"
                     v_valorjur      = "0,00"
                     v_valortot      = STRING(DECI(SUBSTR(aux_codbarras,5,11)) / 100,"zzz,zzz,zz9.99").
          END.
      END.
      ELSE DO:

          /** Digitou a conta */
          IF  get-value("v_conta") <> ""  THEN DO:

              IF  NOT VALID-HANDLE(h_b1crap00) THEN
                  RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
        
              RUN valida-transacao IN h_b1crap00(INPUT v_coop,
                                                 INPUT v_pac,
                                                 INPUT v_caixa).
        
              IF  VALID-HANDLE(h_b1crap00) THEN
                  DELETE OBJECT h_b1crap00.
              
              IF RETURN-VALUE = "NOK" THEN 
                 DO: 
                    {include/i-erro.i} 
                 END.
              ELSE DO:
                  IF  NOT VALID-HANDLE(h_b1crap00) THEN
                      RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
        
                  RUN verifica-abertura-boletim IN h_b1crap00(INPUT v_coop,
                                                              INPUT v_pac,
                                                              INPUT v_caixa,
                                                              INPUT v_operador).
        
                  IF  VALID-HANDLE(h_b1crap00) THEN
                      DELETE PROCEDURE h_b1crap00.
                  
                  IF  RETURN-VALUE = "NOK" THEN DO:
                      {include/i-erro.i}
                  END.
                  ELSE  DO: 

                      IF  NOT VALID-HANDLE(h_b1crap00) THEN
                          RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
        
                      RUN verifica-horario-gps IN h_b1crap00(INPUT v_coop,
                                                             INPUT v_pac,
                                                             INPUT v_caixa).
                     
                      IF  VALID-HANDLE(h_b1crap00) THEN
                          DELETE OBJECT h_b1crap00.
                  
                      IF  RETURN-VALUE = "NOK" THEN DO:
                          {include/i-erro.i}
                     END.
                  END.
              END.
              
              IF  INT(get-value("v_conta")) > 0 THEN DO:
                  /* Se Contas mudarem */
                  IF  INT(ab_unmap.v_cntanter) <> INT(ab_unmap.v_conta) THEN DO:
                                        
                      IF  NOT VALID-HANDLE(h_b1crap02) THEN
                          RUN dbo/b1crap02.p PERSISTENT SET h_b1crap02.

                      EMPTY TEMP-TABLE tt-conta.

                      RUN consulta-conta IN h_b1crap02 (INPUT v_coop,         
                                                        INPUT INT(v_pac),
                                                        INPUT INT(v_caixa),
                                                        INPUT INT(v_conta ),
                                                        OUTPUT TABLE tt-conta).
                      IF  VALID-HANDLE(h_b1crap02) THEN
                          DELETE PROCEDURE h_b1crap02.
                      
                      IF  RETURN-VALUE = "NOK" THEN DO: 
                          ASSIGN v_conta     = "0"
                                 v_nome      = " "
                                 v_cntanter  = ""
                                 proximo     = "99"
                                 vh_foco     = "13".
                          {include/i-erro.i}
                      END.
                      ELSE DO:
                          FIND FIRST tt-conta NO-LOCK NO-ERROR.
                          IF  AVAIL tt-conta  THEN
                              ASSIGN v_nome      = "DÉBITO EM CONTA / " + tt-conta.nome-tit
                                     vh_nome     = v_nome
                                     vh_foco     = "13"
                                     v_cntanter  = v_conta
                                     proximo     = "1".
                      END.
                  END.
                  ELSE
                      ASSIGN v_nome = vh_nome.
              END.
              ELSE
                  IF  INT(get-value("v_conta")) = 0  THEN
                      ASSIGN v_nome      = "PAGAMENTO EM ESPÉCIE"
                             vh_nome     = v_nome
                             vh_foco     = "13"
                             v_cntanter  = "0"
                             proximo     = "2".


          END.  /** FIM - Digitacao Conta **/
          ELSE
              ASSIGN v_conta     = "0"
                     v_nome      = "PAGAMENTO EM ESPÉCIE"
                     vh_nome     = v_nome
                     vh_foco     = "13"
                     v_cntanter  = "0"
                     proximo     = "2".

      END.

      IF  VALID-HANDLE(h_b1crap00) THEN
          DELETE PROCEDURE h_b1crap00.
      IF  VALID-HANDLE(h_b1crap02) THEN
          DELETE PROCEDURE h_b1crap02.

      /* STEP 4 -
       * Decide what HTML to return to the user. Choose STEP 4.1 to simulate
       * another Web request -OR- STEP 4.2 to return the original form (the
       * default action).
       *
       * STEP 4.1 -
       * To simulate another Web request, change the REQUEST_METHOD to GET
       * and RUN the Web object here.  For example,
       *
       *  ASSIGN REQUEST_METHOD = "GET":U.
       *  RUN run-web-object IN web-utilities-hdl ("myobject.w":U).
       */
       
      /* STEP 4.2 -
       * To return the form again, set data values, display them, and output 
       * them to the WEB stream.  
       *
       * STEP 4.2a -
       * Set any values that need to be set, then display them. */

      RUN displayFields.

      /* STEP 4.2c -
       * OUTPUT the Progress form buffer to the WEB stream. */      
      RUN outputFields.

      IF c-fnc-javascript <> ""  THEN
          {&OUT} "<script>" + c-fnc-javascript + "</script>".

  END. /* Form has been submitted. => FIM REQUEST-METHOD = POST */
  ELSE DO: /* REQUEST-METHOD = GET */ 

    /* This is the first time that the form has been called. Just return the
     * form.  Move 'RUN outputHeader.' here if you are going to simulate
     * another Web request. */

      IF  NOT VALID-HANDLE(h_b1crap00) THEN
          RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.

      RUN verifica-abertura-boletim IN h_b1crap00(INPUT v_coop,
                                                  INPUT v_pac,
                                                  INPUT v_caixa,
                                                  INPUT v_operador).
      IF  VALID-HANDLE(h_b1crap00) THEN
          DELETE PROCEDURE h_b1crap00.
        
      IF  RETURN-VALUE = "NOK" THEN DO:
          {include/i-erro.i}
      END.
      ELSE DO:
          /** NAO PERMITIR ACESSO SE COOPERATIVA NAO TEM 
              CAMPO SICREDI DEFINIDO NA CADCOP **/
          IF  crapcop.cdcrdins = 0 THEN DO:
        
              RUN cria-erro (INPUT v_coop,
                             INPUT v_pac,
                             INPUT v_caixa,
                             INPUT 0,
                             INPUT "Cooperativa não liberada para Pagamento GPS via SICREDI",
                             INPUT YES).
              {include/i-erro.i}
              /* REDIRECIONA PARA TELA PRINCIPAL - CRAP002 */
              {&out} '<script language="javascript">top.frames[1].window.location.href="crap002.html"</script>'.
              ASSIGN vh_foco      = "0"
                     proximo      = "9999"
                     inpesgps     = "0"
                     h_inpesgps   = "0"
                     h_tpdpagto   = "0"
                     h_idleitor   = "0".
          END.
          ELSE DO:

              IF  TIME < crapcop.hrinigps
              OR  TIME > crapcop.hrfimgps THEN DO:
                  /** VALIDACAO DO HORARIO AO ENTRAR NA TELA **/
                  ASSIGN aux_msgalerta = "Horario esgotado para arrecadação de GPS!" +
                                         " (De " + STRING(crapcop.hrinigps,"hh:mm") + "h até " +
                                         STRING(crapcop.hrfimgps,"hh:mm") + "h".
                  RUN cria-erro (INPUT v_coop,
                                 INPUT v_pac,
                                 INPUT v_caixa,
                                 INPUT 0,
                                 INPUT aux_msgalerta,
                                 INPUT YES).
                  {include/i-erro.i}
        
        
                  ASSIGN vh_foco      = "0"
                         proximo      = "9999"
                         inpesgps     = "0"
                         h_inpesgps   = "0"
                         h_tpdpagto   = "0"
                         h_idleitor   = "0".
              END.
              ELSE DO:

                  IF  get-value("redir") = "" THEN DO:
                      /** MENSAGEM AVISO INICIAL AO ENTRAR NA TELA **/
                      ASSIGN aux_msgalerta = "ATENCAO - Utilize essa rotina apenas para efetuar " +
                                             "pagamento de GPS(Guia Previdência Social). "        +
                                             "Esta guia deve conter duas autenticações.".
                      RUN cria-erro (INPUT v_coop,
                                     INPUT v_pac,
                                     INPUT v_caixa,
                                     INPUT 0,
                                     INPUT aux_msgalerta,
                                     INPUT YES).
                      {include/i-erro.i}
                  END.

                  ASSIGN proximo      = "0"
                         v_conta      = "0"
                         inpesgps     = "0"
                         h_inpesgps   = "0"
                         h_tpdpagto   = "0"
                         h_idleitor   = "0".
              END.
          END.

      END. /** FIM ELSE DO **/


    /* STEP 1 -
     * Open the database or SDO query and and fetch the first record. */ 

    /* RUN findRecords. */

    
    /* Return the form again. Set data values, display them, and output them
     * to the WEB stream.  
     *
     * STEP 2a -
     * Set any values that need to be set, then display them. */
    ASSIGN vh_foco = "13".
    
    RUN displayFields.

    /* STEP 2b -
     * Enable objects that should be enabled. */
    RUN enableFields.
    
    /* STEP 2c -
     * OUTPUT the Progress from buffer to the WEB stream. */
    RUN outputFields.

  END.

  /* Show error messages. */
  IF AnyMessage() THEN 
  DO:
     /* ShowDataMessage may return a Progress column name. This means you
      * can use the function as a parameter to HTMLSetFocus instead of 
      * calling it directly.  The first parameter is the form name.   
      *
      * HTMLSetFocus("document.DetailForm",ShowDataMessages()). */
     ShowDataMessages().
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE valida-valor-limite w-html 

/* valida o valor recebido como parâmetro com o limite da agencia / cooperativa e solicita senha do coordenador se for maior */
PROCEDURE valida-valor-limite:

    DEF INPUT PARAM par_nmrescop  AS CHARACTER                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad  AS CHARACTER                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci  AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_nrocaixa  AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_vltitfat  AS DECIMAL                         NO-UNDO.
    DEF INPUT PARAM par_senha     AS CHARACTER                       NO-UNDO.
    DEF OUTPUT PARAM par_des_erro AS CHARACTER                       NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHARACTER                       NO-UNDO.
    DEF OUTPUT PARAM par_inssenha AS INTEGER                         NO-UNDO.

    DEF VAR aux_inssenha          AS INTEGER                         NO-UNDO.
    DEF VAR h_b1crap87            AS HANDLE                          NO-UNDO.
    
    RUN dbo/b1crap87.p PERSISTENT SET h_b1crap87.
                           
    RUN validar-valor-limite IN h_b1crap87(INPUT par_nmrescop,
                                           INPUT par_cdoperad,
                                           INPUT par_cdagenci,
                                           INPUT par_nrocaixa,
                                           INPUT par_vltitfat,
                                           INPUT par_senha,
                                           OUTPUT par_des_erro,
                                           OUTPUT par_dscritic,
                                           OUTPUT par_inssenha).
                                          
    DELETE PROCEDURE h_b1crap87.
    
    IF RETURN-VALUE = 'NOK' THEN  
     DO:
        RETURN "NOK".
     END.
           
     /* Solicita confirmaçao operacao depois de inserida a senha DO coordenador */
     IF par_inssenha > 0 THEN
        DO: 
           {&out}   '<script>if (confirm("Confirma operaçao?")) ~{' +
                    'document.forms[0].submit();' +   
                    '~} else ~{' +
                    ' window.location = "crap087.html";' +
                    '~}</script>'. 
        END.
        
    RETURN "OK".
END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
