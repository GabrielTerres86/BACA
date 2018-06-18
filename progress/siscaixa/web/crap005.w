/* .............................................................................

   Programa: siscaixa/web/crap005.w
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 12/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Requisicao e entrega de taloes

   Alteracoes: 27/07/2005 - Tratamento DO TRANSACTION para a chamada das BO's
                            (Julio)
                            
               03/08/2005 - Excluir craperr para banco e caixa antes do CREATE
                            (Julio)

               31/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)

               09/03/2006 - Usar o codigo da cooperativa nas buscas (Evandro).
               
               12/02/2007 - Adequacao ao BANCOOB (Evandro).

               16/03/2007 - Passagem do nome do sistema por parametro para a 
                            BO (Evandro).
                            
               30/09/2009 -Adaptacoes projeto IF CECRED (Guilherme).
               
               23/09/2011 - Ajuste Lista Negra (Adriano).
               
               03/07/2012 - Ajuste operador como CHARACTER (Guilherme).
               
               13/03/2013 - Ajsutes realizados:
                             - No tratamento do RETURN-VALUE apos a chamada da 
                               procedure solicita-entrega-talao, foi retirado a
                               chamada da include i-erro.i no ELSE;
                             - Incluido a passagem de um novo parametro na 
                               na chamada da procedure valida-dados.  
                               (Adriano).
               
               12/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO)                 
                    
               27/06/2016 - Tratamentos para utilizaçao do Cartao CECRED e 
                            PinPad Novo (Lucas Lunelli - [PROJ290])
                    
............................................................................ */


&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD radio AS CHARACTER 
       FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
       FIELD v_numfin AS CHARACTER FORMAT "X(256)":U 
       FIELD v_numini AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
       FIELD v_talao AS CHARACTER FORMAT "X(256)":U 
       FIELD v_banco AS CHARACTER FORMAT "X(256)":U 
       FIELD v_agencia AS CHARACTER FORMAT "X(256)":U

       FIELD v_opcao AS CHARACTER FORMAT "X(256)":U       
       FIELD v_infocry     AS CHARACTER FORMAT "X(256)":U               
       FIELD v_chvcry      AS CHARACTER FORMAT "X(256)":U       
       FIELD v_nrdocard    AS CHARACTER FORMAT "X(256)":U 
       FIELD v_dssencrd AS CHARACTER FORMAT "X(256)":U       
       FIELD v_cartao AS CHARACTER FORMAT "X(256)":U
       FIELD v_nrcpfcgc AS CHARACTER FORMAT "X(256)":U
       FIELD v_dsnomter AS CHARACTER FORMAT "X(256)":U
       FIELD v_btn_ok AS CHARACTER FORMAT "X(256)":U
       FIELD v_btn_cancela AS CHARACTER FORMAT "X(256)":U
       FIELD v_nrtalao   AS CHARACTER FORMAT "X(256)":U       
       FIELD v_nrinicial AS CHARACTER FORMAT "X(256)":U       
       FIELD v_nrfinal   AS CHARACTER FORMAT "X(256)":U                     
       FIELD v_nrini_sel AS CHARACTER FORMAT "X(256)":U       
       FIELD v_nrfin_sel   AS CHARACTER FORMAT "X(256)":U
       FIELD v_tpentrega AS CHARACTER FORMAT "X(256)":U
       FIELD v_seleciona AS LOGICAL
       FIELD v_talao_sel AS CHARACTER FORMAT "X(256)":U.


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

DEFINE VARIABLE h-b1crap05 AS HANDLE              NO-UNDO.
DEFINE VARIABLE h-b1crap00 AS HANDLE              NO-UNDO.

DEF VAR l-houve-erro        AS LOG                NO-UNDO.
DEF VAR aux_tprequis        LIKE crapreq.tprequis NO-UNDO.
DEF VAR vetor               AS CHAR               NO-UNDO.

DEF VAR glb_nrcalcul        AS DECIMAL            NO-UNDO.
DEF VAR glb_dscalcul        AS CHAR               NO-UNDO.
DEF VAR glb_stsnrcal        AS LOGICAL            NO-UNDO.
DEF VAR par_cdagechq        AS INTEGER            NO-UNDO.

DEF VAR v_nmtitular1        AS CHAR               NO-UNDO.  
DEF VAR v_nrcpfcgc1         AS CHAR               NO-UNDO.
DEF VAR v_nmtitular2        AS CHAR               NO-UNDO.  
DEF VAR v_nrcpfcgc2         AS CHAR               NO-UNDO.
DEF VAR aux_nrdconta        AS CHAR               NO-UNDO.

DEF TEMP-TABLE w-craperr  NO-UNDO FIELD cdcooper   LIKE craperr.cdcooper
                                  FIELD cdagenci   LIKE craperr.cdagenc
                                  FIELD nrdcaixa   LIKE craperr.nrdcaixa
                                  FIELD nrsequen   LIKE craperr.nrsequen
                                  FIELD cdcritic   LIKE craperr.cdcritic
                                  FIELD dscritic   LIKE craperr.dscritic
                                  FIELD erro       LIKE craperr.erro.

DEF TEMP-TABLE tt-taloes
    FIELD nrtalao           AS DECI
    FIELD nrinicial         AS DECI
    FIELD nrfinal           AS DECI.
    
DEF TEMP-TABLE tt-taloes-processar LIKE tt-taloes.
    
    /* field devolucoes         AS inte format "99"
    field agencia            AS char format "x(15)"
    field magnetico          as inte format "z9"     
    field estouros           as inte format "zzz9"
    field folhas             as inte format "zzz,zz9"
    field disponivel         AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE crap005.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.vh_foco ab_unmap.v_nome ab_unmap.v_msg ab_unmap.radio ab_unmap.v_caixa ab_unmap.v_conta ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_numfin ab_unmap.v_numini ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_talao ab_unmap.v_banco ab_unmap.v_agencia ab_unmap.v_opcao ab_unmap.v_infocry ab_unmap.v_chvcry ab_unmap.v_nrdocard ab_unmap.v_dssencrd ab_unmap.v_cartao ab_unmap.v_nrcpfcgc ab_unmap.v_dsnomter ab_unmap.v_btn_ok ab_unmap.v_btn_cancela ab_unmap.v_nrtalao ab_unmap.v_nrinicial ab_unmap.v_nrfinal ab_unmap.v_nrini_sel ab_unmap.v_nrfin_sel ab_unmap.v_tpentrega ab_unmap.v_seleciona ab_unmap.v_talao_sel
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.vh_foco ab_unmap.v_nome ab_unmap.v_msg ab_unmap.radio ab_unmap.v_caixa ab_unmap.v_conta ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_numfin ab_unmap.v_numini ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_talao ab_unmap.v_banco ab_unmap.v_agencia ab_unmap.v_opcao ab_unmap.v_infocry ab_unmap.v_chvcry ab_unmap.v_nrdocard ab_unmap.v_dssencrd ab_unmap.v_cartao ab_unmap.v_nrcpfcgc ab_unmap.v_dsnomter ab_unmap.v_btn_ok ab_unmap.v_btn_cancela ab_unmap.v_nrtalao ab_unmap.v_nrinicial ab_unmap.v_nrfinal ab_unmap.v_nrini_sel ab_unmap.v_nrfin_sel ab_unmap.v_tpentrega ab_unmap.v_seleciona ab_unmap.v_talao_sel

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
     ab_unmap.v_nome AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_msg AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.radio AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
                    "radio 1", "yes":U,
"radio 2", "no":U
          SIZE 20 BY 3
     ab_unmap.v_caixa AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_conta AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_coop AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_data AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_numfin AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_numini AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_operador AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_pac AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_talao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_banco AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_agencia AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_opcao AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
           "v_opcao 1", "R":U,
           "v_opcao 2", "C":U 
           SIZE 20 BY 2
     ab_unmap.v_infocry AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1      
     ab_unmap.v_chvcry AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1  
     ab_unmap.v_nrdocard AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1                            
     ab_unmap.v_dssencrd AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1     
     ab_unmap.v_cartao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nrcpfcgc AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_dsnomter AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_btn_ok AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_btn_cancela AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nrtalao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nrinicial AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nrfinal AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nrini_sel AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nrfin_sel AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_tpentrega AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
          "v_tpentrega 1", "yes":U,
          "v_tpentrega 2", "no":U
          SIZE 20 BY 3
     ab_unmap.v_seleciona AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 3
     ab_unmap.v_talao_sel AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 60.57 BY 14.14.


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
          FIELD radio AS CHARACTER 
          FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
          FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
          FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
          FIELD v_numfin AS CHARACTER FORMAT "X(256)":U 
          FIELD v_numini AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD v_talao AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 14.14
         WIDTH              = 60.57.
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
/* SETTINGS FOR RADIO-SET ab_unmap.radio IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.vh_foco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_caixa IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_conta IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nome IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_numfin IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_numini IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_talao IN FRAME Web-Frame
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE htmOffsets w-html  _WEB-HTM-OFFSETS
PROCEDURE htmOffsets :
/*------------------------------------------------------------------------------
  Purpose:     Runs procedure to associate each HTML field with its
               corresponding widget name and handle.
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
  RUN readOffsets ("{&WEB-FILE}":U).
  RUN htmAssociate
    ("radio":U,"ab_unmap.radio":U,ab_unmap.radio:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("vh_foco":U,"ab_unmap.vh_foco":U,ab_unmap.vh_foco:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_caixa":U,"ab_unmap.v_caixa":U,ab_unmap.v_caixa:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_conta":U,"ab_unmap.v_conta":U,ab_unmap.v_conta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nome":U,"ab_unmap.v_nome":U,ab_unmap.v_nome:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_numfin":U,"ab_unmap.v_numfin":U,ab_unmap.v_numfin:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_numini":U,"ab_unmap.v_numini":U,ab_unmap.v_numini:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_talao":U,"ab_unmap.v_talao":U,ab_unmap.v_talao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_banco":U,"ab_unmap.v_banco":U,ab_unmap.v_banco:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_agencia":U,"ab_unmap.v_agencia":U,ab_unmap.v_agencia:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_opcao":U,"ab_unmap.v_opcao":U,ab_unmap.v_opcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_infocry":U,"ab_unmap.v_infocry":U,ab_unmap.v_infocry:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_chvcry":U,"ab_unmap.v_chvcry":U,ab_unmap.v_chvcry:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nrdocard":U,"ab_unmap.v_nrdocard":U,ab_unmap.v_nrdocard:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_dssencrd":U,"ab_unmap.v_dssencrd":U,ab_unmap.v_dssencrd:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cartao":U,"ab_unmap.v_cartao":U,ab_unmap.v_cartao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nrcpfcgc":U,"ab_unmap.v_nrcpfcgc":U,ab_unmap.v_nrcpfcgc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_dsnomter":U,"ab_unmap.v_dsnomter":U,ab_unmap.v_dsnomter:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_btn_ok":U,"ab_unmap.v_btn_ok":U,ab_unmap.v_btn_ok:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_btn_cancela":U,"ab_unmap.v_btn_cancela":U,ab_unmap.v_btn_cancela:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nrtalao":U,"ab_unmap.v_nrtalao":U,ab_unmap.v_nrtalao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nrinicial":U,"ab_unmap.v_nrinicial":U,ab_unmap.v_nrinicial:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nrfinal":U,"ab_unmap.v_nrfinal":U,ab_unmap.v_nrfinal:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nrini_sel":U,"ab_unmap.v_nrini_sel":U,ab_unmap.v_nrini_sel:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nrfin_sel":U,"ab_unmap.v_nrfin_sel":U,ab_unmap.v_nrfin_sel:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_tpentrega":U,"ab_unmap.v_tpentrega":U,ab_unmap.v_tpentrega:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_seleciona":U,"ab_unmap.v_seleciona":U,ab_unmap.v_seleciona:HANDLE IN FRAME {&FRAME-NAME}).      
  RUN htmAssociate
    ("v_talao_sel":U,"ab_unmap.v_talao_sel":U,ab_unmap.v_talao_sel:HANDLE IN FRAME {&FRAME-NAME}).    
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
     
  /* STEP 0 -
   * Output the MIME header and set up the object as state-less or state-aware. 
   * This is required if any HTML is to be returned to the browser. 
   *
   * NOTE: Move 'RUN outputHeader.' to the GET section below if you are going
   * to simulate another Web request by running a Web Object from this
   * procedure.  Running outputHeader precludes setting any additional cookie
   * information.
   */ 
   
  DEFINE VARIABLE aux_nrcartao    AS DECIMAL      NO-UNDO .
  DEFINE VARIABLE aux_idtipcar    AS INTEGER      NO-UNDO .
  DEFINE VARIABLE aux_contador    AS INTEGER      NO-UNDO .
    
    
  RUN outputHeader.
  {include/i-global.i}
  
  /* Describe whether to receive FORM input for all the fields.  For example,
   * check particular input fields (using GetField in web-utilities-hdl). 
   * Here we look at REQUEST_METHOD. 
   */
  
  IF REQUEST_METHOD = "POST":U THEN DO:
    /* STEP 1 -
     * Copy HTML input field values to the Progress form buffer. */
    RUN inputFields.
    
    /* STEP 2 -
     * Open the database or SDO query and and fetch the first record. 
    RUN findRecords.                                                  */
    
    /* STEP 3 -    
     * AssignFields will save the data in the frame.
     * (it automatically upgrades the lock to exclusive while doing the update)
     * 
     *  If a new record needs to be created set AddMode to true before 
        running assignFields.  
     *     setAddMode(TRUE).   */

     /* Colocado a chamada do assignFields dentro da include */
     {include/assignfields.i} 

     RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
  
     IF v_btn_cancela <> "" THEN 
        DO:
           ASSIGN v_conta   = ""
                  v_nome    = ""
                  radio     = "YES"
                  v_talao   = ""
                  v_numini  = ""
                  v_numfin  = ""
                  v_banco   = ""
                  v_agencia = ""
                  vh_foco   = "25"

                  v_nrtalao        = ''
                  v_nrinicial      = ''
                  v_nrfinal        = ''
                  v_opcao          = "R"     
                  v_tpentrega      = 'yes'
                  v_dssencrd       = ''
                  v_nrdocard       = ""
                  v_infocry        = ""
                  v_chvcry         = ""
                  v_cartao         = ""
                  v_dsnomter       = ''
                  v_nrcpfcgc       = ''
                  v_btn_ok         = ''
                  v_btn_cancela    = ''
                  v_nrini_sel      = ''
                  v_nrfin_sel      = ''
                  v_talao_sel      = ''.

     END.
     ELSE 
        DO:
           RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                             INPUT int(v_pac),
                                             INPUT int(v_caixa)).
    
    
           IF RETURN-VALUE = "NOK" THEN DO:
              {include/i-erro.i}
           END.
           ELSE   
              DO:
                  RUN verifica-abertura-boletim IN h-b1crap00(INPUT v_coop,
                                                              INPUT INT(v_pac),
                                                              INPUT INT(v_caixa),
                                                              INPUT v_operador).
                  IF RETURN-VALUE = "NOK" THEN DO:
                     {include/i-erro.i}
                  END.
                  ELSE  
                     DO:
                         ASSIGN aux_tprequis = 0
                                l-houve-erro = FALSE.
                     
                         IF get-value("radio") = "YES"   THEN
                            ASSIGN aux_tprequis = 1. /* Normal */ 
                         ELSE
                            ASSIGN aux_tprequis = 2. /* TB */
                     
                        IF  v_cartao <> '' THEN 
                            DO:
                                RUN dbo/b1crap05.p PERSISTENT SET h-b1crap05.
                                
                                RUN retorna-conta-cartao IN h-b1crap05 (INPUT v_coop,
                                                                        INPUT v_pac,
                                                                        INPUT v_caixa,
                                                                        INPUT DECI(v_cartao),
                                                                       OUTPUT v_conta,
                                                                       OUTPUT aux_nrcartao,
                                                                       OUTPUT aux_idtipcar).
                                DELETE PROCEDURE h-b1crap05.

                                IF  RETURN-VALUE = "NOK" THEN DO:

                                    ASSIGN l-houve-erro = TRUE.
                                    
                                    {include/i-erro.i}

                                END.  
                            END.
                                                       
                         IF v_nrcpfcgc <> ''  AND 
                            v_dsnomter =  ''  THEN
                                  DO:
                                RUN dbo/b1crap05.p PERSISTENT SET h-b1crap05.
                     
                                RUN busca-info-terceiro IN h-b1crap05 (INPUT v_coop,
                                                                       INPUT INTEGER(v_pac),
                                                                       INPUT INTEGER(v_caixa),
                                                                       INPUT-OUTPUT v_nrcpfcgc,
                                                                       OUTPUT v_dsnomter,
                                                                       OUTPUT aux_nrdconta).
                                DELETE PROCEDURE h-b1crap05.
                     
                                IF  RETURN-VALUE = "NOK" THEN DO:
                     
                                    ASSIGN l-houve-erro = TRUE
                                           v_nmtitular1 = ''
                                           v_nrcpfcgc   = ''
                                           vh_foco      = "27".
                                           
                                    {include/i-erro.i}
                     
                                  END.
                               ELSE
                                    IF v_dsnomter <> "" THEN
                                       ASSIGN vh_foco  = "25".
                                    ELSE 
                                       ASSIGN vh_foco  = "23".
                            END.
                                                        
                         /* Terceiro */
                         IF  get-value("v_tpentrega") = "no"  AND
                             NOT l-houve-erro                 THEN
                               DO:
                                  IF (v_nrcpfcgc    = ""  AND
                                      v_dsnomter    = "") OR
                                     (v_nrcpfcgc   <> ""  AND
                                      v_conta      <> ""  AND
                                      v_dsnomter    = "") THEN
                               DO:
                                      RUN elimina-erro(INPUT v_coop,
                                                       INPUT v_pac,
                                                       INPUT v_caixa).

                                      RUN cria-erro (INPUT v_coop,
                                                     INPUT v_pac,
                                                     INPUT v_caixa,
                                                     INPUT 0,
                                                     INPUT "Informe CPF e Nome do Terceiro.",
                                                     INPUT YES).

                                      ASSIGN l-houve-erro = YES
                                             v_conta      = "".
                                             
                                     IF v_nrcpfcgc <> "" THEN
                                        ASSIGN vh_foco  = "23".
                                  ELSE
                                        ASSIGN vh_foco  = "22".

                                      {include/i-erro.i}
                                  END.
                                     END.

                        IF  v_conta     <> ''   AND 
                            NOT l-houve-erro    THEN 
                            DO:                                                                              
                                RUN dbo/b1crap05.p PERSISTENT SET h-b1crap05.
                                
                                RUN verifica-conta IN h-b1crap05 (INPUT v_coop,
                                                                  INPUT INTEGER(v_pac),
                                                                  INPUT INTEGER(v_caixa),
                                                                  INPUT INTEGER(v_conta),
                                                                  OUTPUT v_nmtitular1,
                                                                  OUTPUT v_nrcpfcgc1,
                                                                  OUTPUT v_nmtitular2,
                                                                  OUTPUT v_nrcpfcgc2).
                                DELETE PROCEDURE h-b1crap05.
                                
                                IF  RETURN-VALUE = "NOK" THEN DO:

                                    ASSIGN l-houve-erro = TRUE
                                           v_conta      = ''.                                           

                                    {include/i-erro.i}
                                     END.
                                ELSE DO:
                                
                                    ASSIGN vh_foco  = "29".
                                
                                    IF  INTEGER(GET-VALUE("v_banco")) <> 0  THEN
                                        DO:
                                            RUN dbo/b1crap05.p PERSISTENT SET h-b1crap05.
                                            
                                            RUN calcula-digito IN h-b1crap05 (INPUT v_coop,
                                                                              INPUT INTEGER(v_pac),
                                                                              INPUT INTEGER(v_caixa),
                                                                              INPUT INTEGER(v_conta),
                                                                              INPUT INTEGER(GET-VALUE("v_banco")),
                                                                              OUTPUT glb_dscalcul,
                                                                              OUTPUT v_agencia).
                                            DELETE PROCEDURE h-b1crap05.
                                            
                                            IF  RETURN-VALUE = "NOK" THEN DO:

                                                ASSIGN l-houve-erro = TRUE.
                                                
                                                {include/i-erro.i}

                               END.
                                            ELSE
                                                DO:
                                                    ASSIGN vh_foco  = "30".
                                                    
                                                    RUN dbo/b1crap05.p PERSISTENT SET h-b1crap05.
                                                    
                                                    RUN retorna-taloes IN h-b1crap05 (INPUT v_coop,
                                                                                      INPUT INTEGER(v_pac),
                                                                                      INPUT INTEGER(v_caixa),
                                                                                      INPUT INTEGER(v_conta),
                                                                                      INPUT INTEGER(GET-VALUE("v_banco")),
                                                                                      INPUT aux_tprequis,
                                                                                      OUTPUT TABLE tt-taloes).
                                                    DELETE PROCEDURE h-b1crap05.

                                                    IF  RETURN-VALUE = "NOK" THEN DO:

                                                        ASSIGN l-houve-erro = TRUE.

                                                        {include/i-erro.i}
                            END.
                         ELSE
                            DO:
                                                           {&OUT} '<script> tmp_objtaloes = new Array();'.

                                                           FOR EACH tt-taloes NO-LOCK:
                                                            
                                                              vetor = vetor + "~{" +
                                                                      "nrtalao:'" +   STRING(tt-taloes.nrtalao)   + "'," + 
                                                                      "nrinicial:'" + STRING(tt-taloes.nrinicial) + "'," + 
                                                                      "nrfinal:'" +   STRING(tt-taloes.nrfinal)   + "'"  + "~}".
                                                           
                                                              {&OUT} 'tmp_objtaloes.push("' + STRING(vetor) + '");'.
                                                              
                                                              ASSIGN vetor = "".

                            END.

                                                           {&OUT} '</script>'.

                            END.
                                                END.
                                        END. /* banco <> 0 */ 
                                    
                                ASSIGN v_nome  = v_nmtitular1.

                                END.
                            END.

                         /* Validaçao caso: Taloes Selecionados */
                         IF  v_talao_sel <> '' THEN 
                            DO: 
                                EMPTY TEMP-TABLE tt-taloes-processar.

                                DO aux_contador = 1 TO NUM-ENTRIES(v_talao_sel):

                                    FIND FIRST tt-taloes WHERE tt-taloes.nrtalao = INTEGER(ENTRY(aux_contador,v_talao_sel)) 
                                                                                   NO-LOCK NO-ERROR NO-WAIT.                                                                                           
                                    IF  AVAIL tt-taloes THEN
                                        DO:
                                            CREATE tt-taloes-processar.
                                            ASSIGN tt-taloes-processar.nrtalao   = tt-taloes.nrtalao
                                                   tt-taloes-processar.nrinicial = tt-taloes.nrinicial
                                                   tt-taloes-processar.nrfinal   = tt-taloes.nrfinal.
                                END.
                                END. /* do to */
                     
                                FOR EACH tt-taloes-processar NO-LOCK:
                                
                                   RUN dbo/b1crap05.p PERSISTENT SET h-b1crap05.
                                   
                                   IF   VALID-HANDLE(h-b1crap05)   THEN
                                        DO:
                                           RUN valida-dados IN h-b1crap05 (INPUT v_coop,
                                                                           INPUT INT(v_pac),
                                                                           INPUT INT(v_caixa),
                                                                           INPUT INT(v_conta),
                                                                           INPUT aux_tprequis,
                                                                           INPUT INT(v_talao),
                                                                           INPUT INT(v_banco),
                                                                           INPUT INT(v_agencia),
                                                                           INPUT DECI(tt-taloes-processar.nrinicial),
                                                                           INPUT DECI(tt-taloes-processar.nrfinal),
                                                                           INPUT "CAIXA",
                                                                           INPUT v_operador,
                                                                          OUTPUT par_cdagechq).
                                           IF  RETURN-VALUE <> "OK" THEN DO:
                     
                                               ASSIGN l-houve-erro = YES.                                                                                                                                                            

                                {include/i-erro.i}

                            END.
                                        END.                                        
                                END. /* FOR EACH */
                             END.
                     
                         /* Validaçao caso: Formulario continuo ou 
                            Solicitaçao de Taloes */
                         IF  INT(v_numini) > 0 OR 
                             INT(v_talao)  > 0 THEN
                            DO:
                                IF  INT(v_numfin) = 0 THEN 
                                    ASSIGN v_numfin = v_numini.
                                
                                RUN dbo/b1crap05.p PERSISTENT SET h-b1crap05.
                     
                                IF VALID-HANDLE(h-b1crap05)   THEN
                                   DO:
                                      RUN valida-dados IN h-b1crap05
                                                       (INPUT v_coop,
                                                        INPUT INT(v_pac),
                                                        INPUT INT(v_caixa),
                                                        INPUT INT(v_conta),
                                                        INPUT aux_tprequis,
                                                        INPUT INT(v_talao),
                                                        INPUT INT(v_banco),
                                                        INPUT INT(v_agencia),
                                                        INPUT INT(v_numini),
                                                        INPUT INT(v_numfin),
                                                        INPUT "CAIXA",
                                                        INPUT v_operador,
                                                        OUTPUT par_cdagechq).
                     
                                        IF  RETURN-VALUE <> "OK" THEN DO:
                                            ASSIGN l-houve-erro = YES.
                                            {include/i-erro.i}
                                        END.                                            
                                     END.                                                                                                            
                             END.
                             
                         ASSIGN v_nrdocard   = STRING(aux_nrcartao). 
                     
                         IF v_btn_ok <> ''    AND
                            NOT l-houve-erro  THEN
                            DO:
                                ASSIGN v_btn_ok = "".
                                
                                IF  v_conta = ""  THEN 
                                    DO:
                                        RUN elimina-erro(INPUT v_coop,
                                                         INPUT v_pac,
                                                         INPUT v_caixa).

                                        RUN cria-erro (INPUT v_coop,
                                                       INPUT v_pac,
                                                       INPUT v_caixa,
                                                       INPUT 0,
                                                       INPUT "Informe a conta/dv.",
                                                       INPUT YES).
                                                       
                                        ASSIGN l-houve-erro = YES
                                               vh_foco      = "25".
                                                       
                                        {include/i-erro.i}
                                    END.                                                            
                            
                                IF  NOT l-houve-erro  THEN
                                    DO:
                                      IF  v_talao_sel = ""  AND
                                          v_talao     = ""  AND 
                                          v_numini    = ""  THEN 
                                          DO:
                                              RUN elimina-erro(INPUT v_coop,
                                                               INPUT v_pac,
                                                               INPUT v_caixa).

                                              RUN cria-erro (INPUT v_coop,
                                                             INPUT v_pac,
                                                             INPUT v_caixa,
                                                             INPUT 0,
                                                             INPUT "Operacao invalida.",
                                                             INPUT YES).
                                                             
                                              ASSIGN l-houve-erro = YES.
                                                             
                                              {include/i-erro.i}
                                          END.
                                    END.
                             
                                IF  v_opcao = "C"          AND 
                                    NOT l-houve-erro       THEN
                                    DO:
                                        RUN dbo/b1crap05.p PERSISTENT SET h-b1crap05.
                                        
                                        RUN valida_senha_cartao IN h-b1crap05 (INPUT v_coop,
                                                                               INPUT v_pac,
                                                                               INPUT v_caixa,
                                                                               INPUT INT(v_conta),
                                                                               INPUT DECI(aux_nrcartao),
                                                                               INPUT v_opcao,
                                                                               INPUT v_dssencrd,
                                                                               INPUT aux_idtipcar,
                                                                               INPUT v_infocry,
                                                                               INPUT v_chvcry). 
                                        DELETE PROCEDURE h-b1crap05.
                                        
                                        IF  RETURN-VALUE <> "OK" THEN DO:

                                            ASSIGN l-houve-erro = YES
                                                   v_btn_ok      = ''
                                                   v_btn_cancela = ''
                                                   v_dssencrd    = ''                                                
                                                   v_opcao       = "C".                          
                                                   
                                            {include/i-erro.i}
                                        END.                        
                                    END.
                                    
                                IF  NOT l-houve-erro  THEN
                                    DO:
                                        EMPTY TEMP-TABLE tt-taloes-processar.
                                        
                                        /* Taloes selecionados */
                                        IF  v_talao_sel <> '' THEN
                                            DO:          
                                                DO aux_contador = 1 TO NUM-ENTRIES(v_talao_sel):
                                                
                                                    FIND FIRST tt-taloes WHERE tt-taloes.nrtalao = INTEGER(ENTRY(aux_contador,v_talao_sel)) 
                                                                                                   NO-LOCK NO-ERROR NO-WAIT.                                                                                           
                                                    IF  AVAIL tt-taloes THEN
                                                        DO:
                                                            CREATE tt-taloes-processar.
                                                            ASSIGN tt-taloes-processar.nrtalao   = tt-taloes.nrtalao
                                                                   tt-taloes-processar.nrinicial = tt-taloes.nrinicial
                                                                   tt-taloes-processar.nrfinal   = tt-taloes.nrfinal.
                                                        END.
                                                END.
                                            END.
                                        /* Formulario continuo */
                                        ELSE                                           
                                            IF  INT(v_numini) > 0 AND 
                                                INT(v_numfin) = 0 THEN
                                                    ASSIGN v_numfin = v_numini.
                                                    
                                        RUN dbo/b1crap05.p PERSISTENT SET h-b1crap05.
                             
                                        IF VALID-HANDLE(h-b1crap05)   THEN
                                           DO:
                                         RUN solicita-entrega-talao IN h-b1crap05
                                                      (INPUT v_coop,
                                                       INPUT INT(v_pac),
                                                       INPUT INT(v_caixa),
                                                       INPUT INT(v_conta),
                                                       INPUT aux_tprequis,
                                                       INPUT INT(v_talao),
                                                       INPUT INT(v_banco),
                                                       INPUT INT(v_agencia),
                                                       INPUT INT(v_numini),
                                                       INPUT INT(v_numfin),
                                                       INPUT v_operador,
                                                             INPUT "CAIXA",
                                                             INPUT v_nrcpfcgc,
                                                             INPUT v_dsnomter,
                                                             INPUT DECI(aux_nrcartao),
                                                             INPUT aux_idtipcar,
                                                             INPUT TABLE tt-taloes-processar).
                     
                                      DELETE PROCEDURE h-b1crap05.

                                IF RETURN-VALUE = "NOK"   THEN
                                   {include/i-erro.i}
                                ELSE
                                                  DO:
                                                      {include/i-erro.i}
                                                      
                                  ASSIGN v_conta   = ""
                                         v_nome    = ""
                                         radio     = "YES"
                                         v_talao   = ""
                                         v_numini  = ""
                                         v_numfin  = ""
                                         v_banco   = ""
                                         v_agencia = ""
                                                             vh_foco   = "25"
                                  
                                                             v_nrtalao        = ''
                                                             v_nrinicial      = ''
                                                             v_nrfinal        = ''
                                                             v_opcao          = "R"
                                                             v_tpentrega      = 'yes'
                                                             v_dssencrd       = ''
                                                             v_nrdocard       = ""
                                                             v_infocry        = ""
                                                             v_chvcry         = ""
                                                             v_cartao         = ""
                                                             v_dsnomter       = ''
                                                             v_nrcpfcgc       = ''
                                                             v_btn_ok         = ''                                                 
                                                             v_btn_cancela    = ''
                                                             v_nrini_sel      = ''
                                                             v_nrfin_sel      = ''
                                                             v_talao_sel      = ''.
                                  
                                                      EMPTY TEMP-TABLE tt-taloes-processar.
                                                      EMPTY TEMP-TABLE tt-taloes.
                            END.

                                              {&OUT} '<script> tmp_objtaloes = new Array();</script>'.

              END.
                                    END. /* NOT l-houve-erro */
                            END. /* ok */
                     END. /* verifica-abertura-boletim */
              END. /* valida-transacao */
     END.

     DELETE PROCEDURE h-b1crap00.

    


















    
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
   
    /* STEP 4.2b -
     * Enable objects that should be enabled. */
    RUN enableFields.

    /* STEP 4.2c -
     * OUTPUT the Progress form buffer to the WEB stream. */
    RUN outputFields.


  END. /* Form has been submitted. */
 
  /* REQUEST-METHOD = GET */ 
  ELSE DO:
    /* This is the first time that the form has been called. Just return the
     * form.  Move 'RUN outputHeader.' here if you are going to simulate
     * another Web request. */ 
   
    /* STEP 1 -
     * Open the database or SDO query and and fetch the first record. */ 
    RUN findRecords.
    
    ASSIGN vh_foco = "25".
    
    /* Return the form again. Set data values, display them, and output them
     * to the WEB stream.  
     *
     * STEP 2a -
     * Set any values that need to be set, then display them. */
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

