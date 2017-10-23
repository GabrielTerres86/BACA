/*..............................................................................

Programa: siscaixa/web/crap014b.w
Sistema : Caixa On-line                                       
Sigla   : CRED    
                                             Ultima atualizacao: 20/10/2017
   
Dados referentes ao programa:

Objetivo  : Entrada de Arrecadacoes - Titulo

Alteracoes: 22/08/2007 - Alterado os parametros nas chamadas para as 
                         BO's do programa dbo/b2crap14.p (Elton).

            15/04/2008 - Adaptacao para agendamentos (David).

            16/12/2008 - Ajustes para unificacao dos bancos de dados (Evandro).
            
            20/10/2010 - Inclusao de parametros na procedure gera-titulos-iptu
                         (Vitor).
                         
            04/01/2011 - Tratamento para pagamento de titulos atraves de cheques
                         (Elton).
                         
            16/02/2011 - Tratamento para Projeto DDA (David).
            
            02/05/2011 - Incluso parametro pagamento por cheque na 
                         gera-titulos-iptu 
                       - Incluso parametros cobranca registrada na 
                         retorna-valores-titulo-iptu e gera-titulos-iptu  
                         (Guilherme).
                         
            12/07/2011 - Incluido novos parametros na procedure 
                         gera-titulos-iptu;
                       - Chamada para procedure liquidacao-intrabancaria-dda 
                         (Elton).
                         
            31/05/2013 - VR Boleto (Gabriel). 
            
            11/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita sera PA (Andre Euzebio - Supero). 
            
            12/12/2013 - Alteracao referente a integracao Progress X 
                         Dataserver Oracle 
                         Inclusao do VALIDATE ( Andre Euzebio / SUPERO) 
                         
            15/09/2014 - Alimentar nome e conta/dv vindo da Rotina 14
                         referente ao Projeto Débito Automático Fácil 
                         (Lucas Lunelli - Out/2014)
                                       
            16/09/2014 - Alterado forma de execução da procedure b2crap14
                         gera-titulos-iptu para procedure Oracle package
                         CXON0014.pc_gera_titulos_iptu_prog. 
                         (Rafael). Liberação Out/2014
                       - Alterado forma de execução da procedure b2crap14
                         retorna-valores-titulo-iptu para procedure Oracle 
                         package CXON0014.pc_retorna_vlr_titulo_iptu. 
                         (Rafael). Liberação Out/2014
                         
            06/11/2014 - Ajuste para quando chamar proc. liquidacao-intrabancaria-dda
                         pergar o ROWID corretamente atraves do RECID.
                         (Jorge/Rodrigo - SD 219830)             
            
            02/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                         Cedente por Beneficiário e  Sacado por Pagador 
                         Chamado 229313 (Jean Reddiga - RKAM).    
            
            11/09/2015 - Melhoria 21 (Tiago/Fabricio).               

            29/12/2016 - Tratamento Nova Plataforma de cobrança PRJ340 - NPC (Odirlei-AMcom)  

			20/10/2017 - Ajuste para pegar o erro corretamente ao retornar da pc_atualz_situac_titulo_sacado
			             (Adriano - SD 773635).
..............................................................................*/

{ sistema/generico/includes/var_oracle.i }

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
 
/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_codbarras AS CHARACTER FORMAT "X(256)":U 
       FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data AS CHARACTER FORMAT "X(256)":U 
       FIELD v_mensagem1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_mensagem2 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
       FIELD v_tit1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_tit2 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_tit3 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_tit4 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_tit5 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_valordoc AS CHARACTER FORMAT "X(256)":U 
       FIELD v_valorinf AS CHARACTER FORMAT "X(256)":U 
       FIELD v_intitcop AS CHARACTER FORMAT "X(256)":U
       FIELD v_cpfsacado  AS CHARACTER FORMAT "X(256)":U
       FIELD v_cpfcedente   AS CHARACTER FORMAT "X(256)":U
       FIELD v_nmbenefi     AS CHARACTER FORMAT "X(256)":U
       FIELD v_nrdocbnf     AS CHARACTER FORMAT "X(256)":U
       FIELD c_dsdocbnf     AS CHARACTER FORMAT "X(256)":U
       FIELD v_inpesbnf     AS CHARACTER FORMAT "X(256)":U
       FIELD v_cdctrlcs     AS CHARACTER FORMAT "X(256)":U
       FIELD v_cod          AS CHARACTER FORMAT "X(256)":U
       FIELD v_senha        AS CHARACTER FORMAT "X(256)":U.
       


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

DEFINE VARIABLE c_radio     AS CHARACTER  NO-UNDO.
DEFINE VARIABLE c_valorinf  AS CHARACTER  NO-UNDO.
DEFINE VARIABLE c_codbarras AS CHARACTER  NO-UNDO.
DEFINE VARIABLE c_intitcop  AS CHARACTER  NO-UNDO. 
DEFINE VARIABLE c_conta     AS CHARACTER  NO-UNDO.
DEFINE VARIABLE c_nome      AS CHARACTER  NO-UNDO.
DEFINE VARIABLE c_nmbenefi  AS CHARACTER  NO-UNDO.

DEFINE VARIABLE h_b1crap00   AS HANDLE    NO-UNDO.
DEFINE VARIABLE h-b1crap20   AS HANDLE    NO-UNDO.
DEFINE VARIABLE h_b2crap14   AS HANDLE    NO-UNDO.
DEFINE VARIABLE h-b1wgen0088 AS HANDLE    NO-UNDO. 
DEFINE VARIABLE h-b1wgen9999 AS HANDLE    NO-UNDO.

DEFINE VARIABLE p_valor     AS DECIMAL    NO-UNDO.
DEFINE VARIABLE p_confvalor AS LOGICAL    NO-UNDO.
DEFINE VARIABLE p_confdata  AS LOGICAL    NO-UNDO.

DEFINE VARIABLE de_tit1      AS DECIMAL   NO-UNDO.
DEFINE VARIABLE de_tit2      AS DECIMAL   NO-UNDO.
DEFINE VARIABLE de_tit3      AS DECIMAL   NO-UNDO.
DEFINE VARIABLE de_tit4      AS DECIMAL   NO-UNDO.
DEFINE VARIABLE de_tit5      AS DECIMAL   NO-UNDO.

DEFINE VARIABLE par_cobregis AS LOGICAL   NO-UNDO.
DEFINE VARIABLE par_msgalert AS CHARACTER NO-UNDO.
DEFINE VARIABLE par_vlrjuros AS DECIMAL   NO-UNDO.
DEFINE VARIABLE par_vlrmulta AS DECIMAL   NO-UNDO.
DEFINE VARIABLE par_vldescto AS DECIMAL   NO-UNDO.
DEFINE VARIABLE par_vlabatim AS DECIMAL   NO-UNDO.
DEFINE VARIABLE par_vloutdeb AS DECIMAL   NO-UNDO.
DEFINE VARIABLE par_vloutcre AS DECIMAL   NO-UNDO.


DEFINE VARIABLE p-nrcnvbol   AS INTE      NO-UNDO. 
DEFINE VARIABLE p-nrctabol   AS INTE      NO-UNDO.
DEFINE VARIABLE p-nrboleto   AS INTE      NO-UNDO.
DEFINE VARIABLE p-rowidcob   AS ROWID     NO-UNDO.  
DEFINE VARIABLE p-indpagto   AS INTE      NO-UNDO.
DEFINE VARIABLE ret_dsinserr AS CHAR      NO-UNDO.
DEFINE VARIABLE p-histor     AS INTEGER   NO-UNDO.
DEFINE VARIABLE p-pg         AS LOGICAL   NO-UNDO.
DEFINE VARIABLE p-docto      AS INTEGER   NO-UNDO.
DEFINE VARIABLE p-registro   AS RECID     NO-UNDO.      
DEFINE VARIABLE p-stsnrcal   AS LOGI      NO-UNDO.  
DEFINE VARIABLE p-inpessoa   AS INTE      NO-UNDO.
DEFINE VARIABLE p-nmprimtl   AS CHAR      NO-UNDO.

DEF VAR p-literal       AS CHAR           NO-UNDO.
DEF VAR p-ult-sequencia AS INTE           NO-UNDO.
                                          
DEF VAR l-houve-erro    AS LOG            NO-UNDO.
                                      
DEF TEMP-TABLE w-craperr  NO-UNDO
     FIELD cdagenci   LIKE craperr.cdagenc
     FIELD nrdcaixa   LIKE craperr.nrdcaixa
     FIELD nrsequen   LIKE craperr.nrsequen
     FIELD cdcritic   LIKE craperr.cdcritic
     FIELD dscritic   LIKE craperr.dscritic
     FIELD erro       LIKE craperr.erro.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE crap014b.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS   ab_unmap.v_nome ab_unmap.v_conta ab_unmap.v_mensagem1 ab_unmap.v_mensagem2  ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_codbarras ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_tit1 ab_unmap.v_tit2 ab_unmap.v_tit3 ab_unmap.v_tit4 ab_unmap.v_tit5 ab_unmap.v_valordoc ab_unmap.v_valorinf ab_unmap.v_intitcop ab_unmap.v_cpfcedente ab_unmap.v_nmbenefi ab_unmap.v_nrdocbnf ab_unmap.c_dsdocbnf ab_unmap.v_inpesbnf ab_unmap.v_cdctrlcs ab_unmap.v_cpfsacado ab_unmap.v_cod ab_unmap.v_senha  
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.v_nome ab_unmap.v_conta ab_unmap.v_mensagem1 ab_unmap.v_mensagem2  ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_codbarras ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_tit1 ab_unmap.v_tit2 ab_unmap.v_tit3 ab_unmap.v_tit4 ab_unmap.v_tit5 ab_unmap.v_valordoc ab_unmap.v_valorinf ab_unmap.v_intitcop ab_unmap.v_cpfcedente ab_unmap.v_nmbenefi ab_unmap.v_nrdocbnf ab_unmap.c_dsdocbnf ab_unmap.v_inpesbnf ab_unmap.v_cdctrlcs ab_unmap.v_cpfsacado ab_unmap.v_cod ab_unmap.v_senha

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.v_nome AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_conta AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_mensagem1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_mensagem2 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.vh_foco AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_caixa AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_codbarras AT ROW 1 COL 1 HELP
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
     ab_unmap.v_msg AT ROW 1 COL 1 HELP
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
     ab_unmap.v_tit1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_tit2 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_tit3 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_tit4 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_tit5 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_valordoc AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_valorinf AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_intitcop AT ROW 1 COL 1 HELP 
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_cpfcedente AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_nmbenefi AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1      
    ab_unmap.v_nrdocbnf AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1   
    ab_unmap.c_dsdocbnf AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1         
    ab_unmap.v_inpesbnf AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1         
    ab_unmap.v_cdctrlcs AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1      
    ab_unmap.v_cpfsacado AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_cod         AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_senha       AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 55.2 BY 19.43.


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
          FIELD v_codbarras AS CHARACTER FORMAT "X(256)":U 
          FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_mensagem1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_mensagem2 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD v_tit1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_tit2 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_tit3 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_tit4 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_tit5 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valordoc AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valorinf AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 19.43
         WIDTH              = 55.2.
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
/* SETTINGS FOR FILL-IN ab_unmap.v_codbarras IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_conta IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_mensagem1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_mensagem2 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nome IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_tit1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_tit2 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_tit3 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_tit4 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_tit5 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_valordoc IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_valorinf IN FRAME Web-Frame
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
    ("vh_foco":U,"ab_unmap.vh_foco":U,ab_unmap.vh_foco:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_caixa":U,"ab_unmap.v_caixa":U,ab_unmap.v_caixa:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_codbarras":U,"ab_unmap.v_codbarras":U,ab_unmap.v_codbarras:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_conta":U,"ab_unmap.v_conta":U,ab_unmap.v_conta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_mensagem1":U,"ab_unmap.v_mensagem1":U,ab_unmap.v_mensagem1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_mensagem2":U,"ab_unmap.v_mensagem2":U,ab_unmap.v_mensagem2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nome":U,"ab_unmap.v_nome":U,ab_unmap.v_nome:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_tit1":U,"ab_unmap.v_tit1":U,ab_unmap.v_tit1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_tit2":U,"ab_unmap.v_tit2":U,ab_unmap.v_tit2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_tit3":U,"ab_unmap.v_tit3":U,ab_unmap.v_tit3:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_tit4":U,"ab_unmap.v_tit4":U,ab_unmap.v_tit4:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_tit5":U,"ab_unmap.v_tit5":U,ab_unmap.v_tit5:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_valordoc":U,"ab_unmap.v_valordoc":U,ab_unmap.v_valordoc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_valorinf":U,"ab_unmap.v_valorinf":U,ab_unmap.v_valorinf:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_intitcop":U,"ab_unmap.v_intitcop":U,ab_unmap.v_intitcop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
   ("v_cpfcedente":U,"ab_unmap.v_cpfcedente":U,ab_unmap.v_cpfcedente:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
   ("v_nmbenefi":U,"ab_unmap.v_nmbenefi":U,ab_unmap.v_nmbenefi:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
   ("v_nrdocbnf":U,"ab_unmap.v_nrdocbnf":U,ab_unmap.v_nrdocbnf:HANDLE IN FRAME {&FRAME-NAME}).  
   RUN htmAssociate
   ("c_dsdocbnf":U,"ab_unmap.c_dsdocbnf":U,ab_unmap.c_dsdocbnf:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
   ("v_inpesbnf":U,"ab_unmap.v_inpesbnf":U,ab_unmap.v_inpesbnf:HANDLE IN FRAME {&FRAME-NAME}).   
  RUN htmAssociate
   ("v_cdctrlcs":U,"ab_unmap.v_cdctrlcs":U,ab_unmap.v_cdctrlcs:HANDLE IN FRAME {&FRAME-NAME}).     
  RUN htmAssociate
   ("v_cpfsacado":U,"ab_unmap.v_cpfsacado":U,ab_unmap.v_cpfsacado:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
   ("v_cod":U,"ab_unmap.v_cod":U,ab_unmap.v_cod:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
  ("v_senha":U,"ab_unmap.v_senha":U,ab_unmap.v_senha:HANDLE IN FRAME {&FRAME-NAME}).       
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
   *   - a cookie is created for the broker to id the client on the return tr
   *   - a cookie is created to id the correct procedure on the return trip
   *
   * If you supply a timeout period less than 1, the following happens:
   *
   *   - 4GL variables webState and webTimeout are set to an empty string
   *   - a cookie is killed for the broker to id the client on the return tr
   *   - a cookie is killed to id the correct procedure on the return trip
   *
   * For example, set the timeout period to 5 minutes.
   *
   *   setWebState (5.0).
   */
    
  /* Output additional cookie information here before running outputContentTye.
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
   * Output the MIME header and set up the object as state-less or state-aware 
   * This is required if any HTML is to be returned to the browser. 
   *
   * NOTE: Move 'RUN outputHeader.' to the GET section below if you are going
   * to simulate another Web request by running a Web Object from this
   * procedure.  Running outputHeader precludes setting any additional cookie
   * information.
   */ 

  DEFINE VARIABLE aux-nrdconta-cob AS INTEGER.
  DEFINE VARIABLE aux-bloqueto     AS DECIMAL.
  DEFINE VARIABLE aux-contaconve   AS INTEGER.
  DEFINE VARIABLE aux-convenio     AS DECIMAL.
  DEFINE VARIABLE aux-insittit     AS INTEGER.
  DEFINE VARIABLE aux-intitcop     AS INTEGER.

  DEFINE VARIABLE aux_cdcoptfn     AS INTEGER.     
  DEFINE VARIABLE aux_cdagetfn     AS INTEGER.     
  DEFINE VARIABLE aux_nrterfin     AS INTEGER.     
  DEFINE VARIABLE aux_dtdifere     AS INTEGER.
  DEFINE VARIABLE aux_vldifere     AS INTEGER.
  DEFINE VARIABLE aux_cobregis     AS INTEGER.
  DEFINE VARIABLE aux_cdcritic     AS INTEGER.
  DEFINE VARIABLE aux_dscritic     AS CHAR.
  DEFINE VARIABLE aux_recidcob     AS INT64.
  DEFINE VARIABLE aux_dsmanual     AS CHAR.
  DEFINE VARIABLE aux_tpcptdoc     AS INTE.
  DEFINE VARIABLE aux_cdsittit     AS INTE.

  RUN outputHeader.
  {include/i-global.i}
  
  /* Describe whether to receive FORM input for all the fields.  For example,
   * check particular input fields (using GetField in web-utilities-hdl). 
   * Here we look at REQUEST_METHOD. 
   */
         
  ASSIGN c_valorinf   = get-value("v_pvalor") 
         c_codbarras  = get-value("v_pbarras") 
         c_conta      = get-value("v_pconta") 
         c_nome       = get-value("v_pnome")
         c_intitcop   = get-value("v_intitcop") 
         v_nrdocbnf   = get-value("v_nrdocbnf")
         v_nmbenefi   = get-value("v_nmbenefi")
         v_inpesbnf   = get-value("v_inpesbnf")
         v_cdctrlcs   = get-value("v_cdctrlcs")
         aux_dsmanual = get-value("manual") 
         vh_foco     = "21".

  IF v_nrdocbnf <> "" THEN DO:
    IF v_cpfcedente = "" THEN
    DO:
      ASSIGN v_cpfcedente = v_nrdocbnf.
    END.
  
    IF v_inpesbnf = "1" THEN
         ASSIGN c_dsdocbnf = STRING(DEC(v_nrdocbnf),"99999999999")
                c_dsdocbnf = STRING(c_dsdocbnf,"xxx.xxx.xxx-xx").
    ELSE
         ASSIGN c_dsdocbnf = STRING(DEC(v_nrdocbnf),"99999999999999")
                c_dsdocbnf = STRING(c_dsdocbnf,"xx.xxx.xxx/xxxx-xx").  
  END.
  

  IF REQUEST_METHOD = "POST":U THEN DO:    
    /* STEP 1 -
     * Copy HTML input field values to the Progress form buffer. */
    RUN inputFields.
    
    /* STEP 2 -
     * Open the database or SDO query and and fetch the first record. */ 
    /*RUN findRecords.*/
    
    /* STEP 3 -    
     * AssignFields will save the data in the frame.
     * (it automatically upgrades the lock to exclusive while doing the update)
     * 
     *  If a new record needs to be created set AddMode to true before 
        running assignFields.  
     *     setAddMode(TRUE).   
     * RUN assignFields. */

    ASSIGN p_confvalor = NO
           p_confdata  = NO.
    
    IF  get-value("retorna") <> "" THEN DO:
        {&OUT}
            '<script>window.location = "crap014.html"
            </script>'.
    END.
    ELSE  DO:
        {include/assignfields.i}

        ASSIGN v_valorinf  = c_valorinf
               v_codbarras = c_codbarras
               v_intitcop  = c_intitcop 
               v_conta     = c_conta
               v_nome      = c_nome
               aux_tpcptdoc = 1. /*1-Leitora 2-Digitado*/

        ASSIGN de_tit1     = 0
               de_tit2     = 0
               de_tit3     = 0
               de_tit4     = 0
               de_tit5     = 0.

        
          /* Popular campo novamente caso apresente erro e 
            necessite apresentar na tela*/
          IF v_nrdocbnf <> "" THEN DO:
  
            IF v_inpesbnf = "1" THEN
                 ASSIGN c_dsdocbnf = STRING(DEC(v_nrdocbnf),"99999999999")
                        c_dsdocbnf = STRING(c_dsdocbnf,"xxx.xxx.xxx-xx").
            ELSE
                 ASSIGN c_dsdocbnf = STRING(DEC(v_nrdocbnf),"99999999999999")
                        c_dsdocbnf = STRING(c_dsdocbnf,"xx.xxx.xxx/xxxx-xx").  
          END.
          
        /* Se possui consulta NPC é necessario informar pagador*/
        IF v_cdctrlcs <> "" THEN
        DO:
          
          /* Nao deve ser obrigado campo do CPF/CNPJ ou conta
          IF INT(v_conta) = 0 AND 
             (DECI(v_cpfsacado) = 0 OR 
              v_cpfsacado = "" )THEN
          DO:   
            
            {&out} '<script>alert("Favor informar Conta ou CPF\CNPJ do Pagador.");</script>' SKIP.         
             RUN displayFields.
             RUN enableFields.
             RUN outputFields.
             NEXT. 
          END.
          */
          
          /* Validar CPF/CNPJ Pagador */
          IF (DECI(v_cpfsacado) > 0 )THEN
          DO: 
            RUN sistema/generico/procedures/b1wgen9999.p
               PERSISTENT SET h-b1wgen9999.

            RUN valida-cpf-cnpj IN h-b1wgen9999
                                (INPUT DECI(v_cpfsacado),
                                OUTPUT p-stsnrcal,
                                OUTPUT p-inpessoa).
                               
            DELETE PROCEDURE h-b1wgen9999.

            IF   NOT p-stsnrcal    THEN
                 DO:
                     {&out} '<script>alert("CPF/CNPJ do pagador com erro.");</script>' SKIP.         
                     RUN displayFields.
                     RUN enableFields.
                     RUN outputFields.
                     NEXT.
                 END.  
          END.     
        END.
        
        
        IF  UPPER(aux_dsmanual) = "MANUAL" THEN
            DO:
                ASSIGN de_tit1     = DECIMAL(get-value("ptitulo1"))
                       de_tit2     = DECIMAL(get-value("ptitulo2"))
                       de_tit3     = DECIMAL(get-value("ptitulo3"))
                       de_tit4     = DECIMAL(get-value("ptitulo4"))
                       de_tit5     = DECIMAL(get-value("ptitulo5"))
                       /* c_codbarras = "" */
                       aux_tpcptdoc = 2. /*1-Leitora 2-Digitado*/
            END.


        IF   DEC(v_valorinf) >= 250000   THEN /* SE VR Boleto */
             DO:
                 RUN sistema/generico/procedures/b1wgen9999.p
                         PERSISTENT SET h-b1wgen9999.

                 RUN valida-cpf-cnpj IN h-b1wgen9999
                                         (INPUT DECI(v_cpfcedente),
                                         OUTPUT p-stsnrcal,
                                         OUTPUT p-inpessoa).

                 DELETE PROCEDURE h-b1wgen9999.

                 IF   NOT p-stsnrcal    THEN
                      DO:
                          {&out} '<script>alert("027 - CPF/CNPJ do beneficiario com erro.");</script>' SKIP.         
                          RUN displayFields.
                          RUN enableFields.
                          RUN outputFields.
                          NEXT.
                      END.

                 RUN sistema/generico/procedures/b1wgen9999.p
                     PERSISTENT SET h-b1wgen9999.

                 RUN valida-cpf-cnpj IN h-b1wgen9999
                                     (INPUT DECI(v_cpfsacado),
                                     OUTPUT p-stsnrcal,
                                     OUTPUT p-inpessoa).
                                     
                 DELETE PROCEDURE h-b1wgen9999.

                 IF   NOT p-stsnrcal    THEN
                      DO:
                          {&out} '<script>alert("CPF/CNPJ do pagador com erro.");</script>' SKIP.         
                          RUN displayFields.
                          RUN enableFields.
                          RUN outputFields.
                          NEXT.
                      END.    

                 IF  DECI(v_cpfcedente) = DECI(v_cpfsacado)  THEN
                     DO:
                         {&out} '<script>alert("CPF/CNPJ nao podem ser iguais.");</script>' SKIP.         
                          RUN displayFields.
                          RUN enableFields.
                          RUN outputFields.
                          NEXT.
                     END.
             END.

        DO TRANSACTION ON ERROR UNDO:
        
            FOR FIRST crapcop FIELDS (cdcooper) 
                 WHERE crapcop.nmrescop = v_coop
                    NO-LOCK.
            END.

             { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        
             RUN STORED-PROCEDURE pc_retorna_vlr_titulo_iptu
                 aux_handproc = PROC-HANDLE NO-ERROR
                (INPUT crapcop.cdcooper,
                 INPUT INT(v_conta),
                 INPUT 0,   
                 INPUT v_operador,
                 INPUT int(v_pac),
                 INPUT int(v_caixa),
                 INPUT de_tit1,
                 INPUT de_tit2,
                 INPUT de_tit3,
                 INPUT de_tit4,
                 INPUT de_tit5,
                 INPUT c_codbarras,
                 INPUT 0, /* NO */
                 INPUT DEC(v_valorinf),
                 INPUT 0,
                 INPUT 0,
                 INPUT ?,
                 INPUT v_cdctrlcs, /*pr_cdctrlcs*/
                 OUTPUT 0,
                 OUTPUT 0,
                 OUTPUT 0,
                 OUTPUT 0,
                 OUTPUT 0,
                 OUTPUT 0,
                 OUTPUT 0,
                 OUTPUT 0,
                 OUTPUT 0,
                 OUTPUT 0,
                 OUTPUT "",
                 OUTPUT 0,
                 OUTPUT 0,
                 OUTPUT 0,
                 OUTPUT 0,
                 OUTPUT 0,
                 OUTPUT 0,
                 OUTPUT 0,
                 OUTPUT "").
        
             CLOSE STORED-PROC pc_retorna_vlr_titulo_iptu
                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
        
            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
            ASSIGN de_tit1 = pc_retorna_vlr_titulo_iptu.pr_titulo1  /*       IN OUT NUMBER             -- FORMAT "99999,99999" */
                   de_tit2 = pc_retorna_vlr_titulo_iptu.pr_titulo2  /*       IN OUT NUMBER             -- FORMAT "99999,999999"  */
                   de_tit3 = pc_retorna_vlr_titulo_iptu.pr_titulo3  /*       IN OUT NUMBER             -- FORMAT "99999,999999"  */
                   de_tit4 = pc_retorna_vlr_titulo_iptu.pr_titulo4  /*       IN OUT NUMBER             -- FORMAT "9"            */
                   de_tit5 = pc_retorna_vlr_titulo_iptu.pr_titulo5  /*       IN OUT NUMBER             -- FORMAT "zz,zzz,zzz,zzz999" */
                   c_codbarras = pc_retorna_vlr_titulo_iptu.pr_codigo_barras  /*  IN OUT VARCHAR2     --Codigo de Barras */
                   p_valor = pc_retorna_vlr_titulo_iptu.pr_vlfatura  /*      OUT NUMBER          --Valor da Fatura  */
                   aux_dtdifere = pc_retorna_vlr_titulo_iptu.pr_outra_data /*     OUT PLS_INTEGER        --Outra data  */ 
                   aux_vldifere = pc_retorna_vlr_titulo_iptu.pr_outro_valor /*    OUT PLS_INTEGER        --Outro valor   */ 
                   aux-nrdconta-cob = pc_retorna_vlr_titulo_iptu.pr_nrdconta_cob /*   OUT INTEGER        --Numero Conta Cobranca */
                   aux-insittit = pc_retorna_vlr_titulo_iptu.pr_insittit    /*    OUT INTEGER        --Situacao Titulo       */
                   aux-intitcop = pc_retorna_vlr_titulo_iptu.pr_intitcop    /*    OUT INTEGER        --Titulo da Cooperativa */
                   aux-convenio = pc_retorna_vlr_titulo_iptu.pr_convenio   /*     OUT NUMBER         --Numero Convenio       */
                   aux-bloqueto = pc_retorna_vlr_titulo_iptu.pr_bloqueto   /*     OUT NUMBER         --Numero Bloqueto       */
                   aux-contaconve = pc_retorna_vlr_titulo_iptu.pr_contaconve /*     OUT INTEGER        --Numero Conta Convenio */
                   aux_cobregis = pc_retorna_vlr_titulo_iptu.pr_cobregis   /*     OUT PLS_INTEGER    --Cobranca Registrada   */
                   par_msgalert = pc_retorna_vlr_titulo_iptu.pr_msgalert   /*     OUT VARCHAR2       --Mensagem de alerta    */
                   par_vlrjuros = pc_retorna_vlr_titulo_iptu.pr_vlrjuros   /*     OUT NUMBER         --Valor dos Juros       */
                   par_vlrmulta = pc_retorna_vlr_titulo_iptu.pr_vlrmulta   /*     OUT NUMBER         --Valor da Multa        */
                   par_vldescto = pc_retorna_vlr_titulo_iptu.pr_vldescto   /*     OUT NUMBER         --Valor do Desconto     */
                   par_vlabatim = pc_retorna_vlr_titulo_iptu.pr_vlabatim   /*     OUT NUMBER         --Valor do Abatimento   */
                   par_vloutdeb = pc_retorna_vlr_titulo_iptu.pr_vloutdeb   /*     OUT NUMBER         --Valor Saida Debitado  */
                   par_vloutcre = pc_retorna_vlr_titulo_iptu.pr_vloutcre   /*     OUT NUMBER         --Valor Saida Creditado */
                   
                   aux_cdcritic = 0
                   aux_dscritic = ""
                   aux_cdcritic = pc_retorna_vlr_titulo_iptu.pr_cdcritic 
                                  WHEN pc_retorna_vlr_titulo_iptu.pr_cdcritic <> ?
                   aux_dscritic = pc_retorna_vlr_titulo_iptu.pr_dscritic 
                                  WHEN pc_retorna_vlr_titulo_iptu.pr_dscritic <> ?.
        
            ASSIGN p_confdata   = (aux_dtdifere = 1)
                   p_confvalor  = (aux_vldifere = 1)
                   par_cobregis = (aux_cobregis = 1).
        
        END. /* fim transaction */

        IF par_msgalert = ? THEN
           par_msgalert = " ".

        IF v_mensagem1 = ? THEN
           v_mensagem1 = " ".

        IF v_mensagem2 = ? THEN
           v_mensagem2 = " ".

        IF p_confvalor AND v_cdctrlcs = "" THEN
            ASSIGN v_mensagem1 =
             "O Valor Digitado difere do Valor Codificado".

        IF p_confdata THEN
           DO:
              IF aux-intitcop = 0   THEN
                 ASSIGN v_mensagem2 = "Documento Digitado em Outra Data".
              ELSE
                 ASSIGN v_mensagem2 = 
                               "Documento Vencido. Observe instruções " + 
                                       "para cobrança de juros e multa.".
           END.
        ELSE
           ASSIGN v_mensagem2 = par_msgalert.



       ASSIGN v_tit1 = STRING(de_tit1,"99999,99999")
              v_tit2 = STRING(de_tit2,"99999,999999")
              v_tit3 = STRING(de_tit3,"99999,999999")
              v_tit4 = STRING(de_tit4,"9")
              v_tit5 = STRING(de_tit5,"zz,zzz,zzz,zzz999")
              v_valorinf = STRING(DEC(v_valorinf),"zzz,zzz,zzz,zz9.99")
              v_valordoc = STRING(p_valor,"zzz,zzz,zzz,zz9.99").

        IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
        DO: 
            {include/i-erro.i}
        END.
        ELSE DO:

            IF  get-value("ok") <> "" THEN DO:  
                    
                 ASSIGN l-houve-erro = NO.
                 
                 /* SE VR Boleto */
                 IF   DEC(v_valorinf) >= 250000   THEN 
                      DO:
                          RUN dbo/b1crap20.p PERSISTENT SET h-b1crap20.

                          RUN verifica-operador IN h-b1crap20
                                            (INPUT v_coop,
                                             INPUT INT(v_pac),
                                             INPUT INT(v_caixa),
                                             INPUT v_cod,
                                             INPUT v_senha,
                                             INPUT 0,
                                             INPUT 0).

                          DELETE PROCEDURE h-b1crap20.
                         
                          IF   RETURN-VALUE = 'NOK' THEN  
                               DO:
                                   {include/i-erro.i}
                                   RUN displayFields.
                                   RUN enableFields.
                                   RUN outputFields.
                                   NEXT.
                               END.
                      END.

                 DO  TRANSACTION ON ERROR UNDO:

                        FOR FIRST crapcop FIELDS (cdcooper) 
                             WHERE crapcop.nmrescop = v_coop
                                NO-LOCK.
                        END.

                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                         RUN STORED-PROCEDURE pc_gera_titulos_iptu_prog
                             aux_handproc = PROC-HANDLE NO-ERROR
                              (INPUT crapcop.cdcooper,
                               INPUT INT(v_conta),
                               INPUT 0,   
                               INPUT v_operador,
                               INPUT INT(v_pac),
                               INPUT INT(v_caixa),
                               INPUT DECI (v_cpfcedente),
                               INPUT 0,
                               INPUT DECI (v_cpfsacado),
                               INPUT 0,
                               INPUT de_tit1,
                               INPUT de_tit2,
                               INPUT de_tit3,
                               INPUT de_tit4,
                               INPUT de_tit5,
                               INPUT 0, /*NO,*/
                               INPUT 0, /*NO,*/
                               INPUT c_codbarras,
                               INPUT DEC(v_valorinf),
                               INPUT DEC(v_valordoc),
                               INPUT aux-nrdconta-cob,
                               INPUT aux-insittit,
                               INPUT aux-intitcop,
                               INPUT aux-convenio,
                               INPUT aux-bloqueto,
                               INPUT aux-contaconve,
                               INPUT aux_cdcoptfn,
                               INPUT aux_cdagetfn,
                               INPUT aux_nrterfin,
                               INPUT 0, /*FALSE, PG chq */
                               INPUT par_vlrjuros,
                               INPUT par_vlrmulta,
                               INPUT par_vldescto,
                               INPUT par_vlabatim,
                               INPUT par_vloutdeb,
                               INPUT par_vloutcre,
                               INPUT aux_tpcptdoc, 
                               INPUT v_cdctrlcs, /* pr_cdctrlcs*/
                               OUTPUT 0, /* aux_rowidcob, */
                               OUTPUT 0, /*aux_indpagto,*/
                               OUTPUT 0, /*aux_nrcnvbol,*/
                               OUTPUT 0, /*aux_nrctabol,*/
                               OUTPUT 0, /*aux_nrboleto,*/
                               OUTPUT 0, /*aux_cdhistor,*/
                               OUTPUT 0, /*aux_flgpagto,*/
                               OUTPUT 0, /*aux_nrdocmto,*/
                               OUTPUT "", /*aux_dslitera,*/
                               OUTPUT 0,/*aux_sequenci*/
                               OUTPUT 0,/*par_cdcritic*/
                               OUTPUT "" /*par_dscritic*/
                               ).

                         CLOSE STORED-PROC pc_gera_titulos_iptu_prog
                               aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                        ASSIGN aux_recidcob = ?
                               aux_recidcob = pc_gera_titulos_iptu_prog.pr_recidcob
                                              WHEN pc_gera_titulos_iptu_prog.pr_recidcob <> ?
                               p-indpagto = pc_gera_titulos_iptu_prog.pr_indpagto
                                              WHEN pc_gera_titulos_iptu_prog.pr_indpagto <> ?
                               p-nrcnvbol = pc_gera_titulos_iptu_prog.pr_nrcnvbol
                                              WHEN pc_gera_titulos_iptu_prog.pr_nrcnvbol <> ?
                               p-nrctabol = pc_gera_titulos_iptu_prog.pr_nrctabol
                                              WHEN pc_gera_titulos_iptu_prog.pr_nrctabol <> ?
                               p-nrboleto = pc_gera_titulos_iptu_prog.pr_nrboleto 
                                              WHEN pc_gera_titulos_iptu_prog.pr_nrboleto <> ? 
                               p-histor = pc_gera_titulos_iptu_prog.pr_histor 
                                              WHEN pc_gera_titulos_iptu_prog.pr_histor <> ?
                               p-pg = IF pc_gera_titulos_iptu_prog.pr_pg = 1 THEN TRUE ELSE FALSE
                                              WHEN pc_gera_titulos_iptu_prog.pr_pg <> ?   
                               p-docto = pc_gera_titulos_iptu_prog.pr_docto 
                                              WHEN pc_gera_titulos_iptu_prog.pr_docto <> ? 
                               p-literal = pc_gera_titulos_iptu_prog.pr_literal
                                              WHEN pc_gera_titulos_iptu_prog.pr_literal <> ? 
                               p-ult-sequencia = pc_gera_titulos_iptu_prog.pr_ult_sequencia
                                              WHEN pc_gera_titulos_iptu_prog.pr_ult_sequencia <> ?
                               aux_cdcritic = 0
                               aux_dscritic = ""
                               aux_cdcritic = pc_gera_titulos_iptu_prog.pr_cdcritic 
                                              WHEN pc_gera_titulos_iptu_prog.pr_cdcritic <> ?
                               aux_dscritic = pc_gera_titulos_iptu_prog.pr_dscritic 
                                              WHEN pc_gera_titulos_iptu_prog.pr_dscritic <> ?.

                                                          
                     ASSIGN v_valorinf =
                         STRING(DEC(v_valorinf),"zzz,zzz,zzz,zz9.99").
                  
                     IF  aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:
                         ASSIGN l-houve-erro = YES.
                         FOR EACH w-craperr:
                             DELETE w-craperr.
                         END.
                          FOR EACH craperr NO-LOCK WHERE
                                   craperr.cdcooper = crapcop.cdcooper  AND
                                   craperr.cdagenci =  INT(v_pac)       AND
                                   craperr.nrdcaixa =  INT(v_caixa):

                             CREATE w-craperr.
                             ASSIGN w-craperr.cdagenci   = craperr.cdagenc
                                    w-craperr.nrdcaixa   = craperr.nrdcaixa
                                    w-craperr.nrsequen   = craperr.nrsequen
                                    w-craperr.cdcritic   = craperr.cdcritic
                                    w-craperr.dscritic   = craperr.dscritic
                                    w-craperr.erro       = craperr.erro.
                         END.
                         UNDO.
                     END.     
                     
                     /* Se for um titulo NPC*/
                     IF l-houve-erro = NO AND 
                        TRIM(v_cdctrlcs) <> "" THEN
                     DO:
                      
                       /* Determinar situacao titulo */
                       IF aux-intitcop = 1 THEN
                          ASSIGN aux_cdsittit = 3.  /* Pg.IntraBanc. */
                       ELSE
                          ASSIGN aux_cdsittit = 4. /* Pg.InterBanc. */
                       
                       
                       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                       RUN STORED-PROCEDURE pc_atualz_situac_titulo_sacado
                           aux_handproc = PROC-HANDLE NO-ERROR
                              (  INPUT crapcop.cdcooper  /* pr_cdcooper */ 
                                ,INPUT INT(v_pac)        /* pr_cdagecxa */ 
                                ,INPUT INT(v_caixa)      /* pr_nrdcaixa */ 
                                ,INPUT v_operador        /* pr_cdopecxa */ 
                                ,INPUT "CRAP014"         /* pr_nmdatela */ 
                                ,INPUT 2  /* caixa */    /* pr_idorigem */ 
                                ,INPUT INT(v_conta)      /* pr_nrdconta */ 
                                ,INPUT 0                 /* pr_idseqttl */ 
                                ,INPUT ""                 /* pr_idtitdda */ 
                                ,INPUT aux_cdsittit      /* pr_cdsittit */ 
                                ,INPUT 0                 /* pr_flgerlog */ 
                                ,INPUT crapdat.dtmvtolt  /* pr_dtmvtolt */  
                                ,INPUT c_codbarras       /* pr_dscodbar */ 
                                ,INPUT v_cdctrlcs        /* pr_cdctrlcs */ 
                               ,OUTPUT 0                 /* pr_cdcritic */ 
                               ,OUTPUT "" ).             /* pr_dscritic */ 
                             

                       CLOSE STORED-PROC pc_atualz_situac_titulo_sacado
                             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

                       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                       
                       ASSIGN  aux_cdcritic = 0
                               aux_dscritic = ""
                               aux_cdcritic = pc_atualz_situac_titulo_sacado.pr_cdcritic 
                                              WHEN pc_atualz_situac_titulo_sacado.pr_cdcritic <> ?
                               aux_dscritic = pc_atualz_situac_titulo_sacado.pr_dscritic 
                                              WHEN pc_atualz_situac_titulo_sacado.pr_dscritic <> ?.
                       
                       
                       IF  aux_cdcritic > 0 OR aux_dscritic <> "" THEN 
					   DO:
                           ASSIGN l-houve-erro = YES.
                           FOR EACH w-craperr:
                               DELETE w-craperr.
                           END.
                           
						   CREATE w-craperr.
                           ASSIGN w-craperr.cdagenci = INT(v_pac) 
                                  w-craperr.nrdcaixa = INT(v_caixa)
                                  w-craperr.nrsequen = 1
                                  w-craperr.cdcritic = aux_cdcritic
                                  w-craperr.dscritic = aux_dscritic.

                           UNDO.

                       END.
                     
                     END. /* Fim atualizar titulo CIP */
                     
                     
                 END.  /* do transaction */
                 
                 IF  l-houve-erro = NO AND 
                     p-indpagto <> 0 THEN 
                     DO: 
                         /*** No caso de erro, somente mostra message no log pois a 
                         procedure abaixo nao interfere no pagamento do titulo ***/
                         RUN sistema/generico/procedures/b1wgen0088.p 
                             PERSISTENT SET h-b1wgen0088.
                         
                         IF  VALID-HANDLE(h-b1wgen0088) THEN
                             DO:
                                 FOR FIRST crapcob FIELDS (cdcooper) 
                                     WHERE RECID(crapcob) = aux_recidcob
                                       NO-LOCK:
                                     p-rowidcob = ROWID(crapcob).
                                 END.

                                 RUN liquidacao-intrabancaria-dda IN h-b1wgen0088(INPUT crapcop.cdcooper,
                                                                                  INPUT crapdat.dtmvtolt,
                                                                                  INPUT aux_recidcob,   
                                                                                  OUTPUT ret_dsinserr).
                
                                 DELETE PROCEDURE h-b1wgen0088.
                                 
                                 IF  RETURN-VALUE <> "OK"  THEN
                                     MESSAGE ret_dsinserr.
                             END. 
                         ELSE
                             MESSAGE "Handle invalido para b1wgen0088".
                     END.                                    
                   
                 IF  l-houve-erro = YES  THEN  DO:
                 
                     RUN verifica-erro (INPUT v_pac, INPUT v_caixa).
                 END.
                 
                 IF  l-houve-erro = NO THEN do:   

                       {&OUT}
                       '<script>window.open("autentica.html?v_plit=" +
                        "' p-literal '" + "&v_pseq=" +
                        "' p-ult-sequencia '" + "&v_prec=" + "NO"  + 
                        "&v_psetcook=" + 
                        "yes","waut","width=250,height=145,
                             scrollbars=auto,alwaysRaised=true")
                       </script>'.

                        {&OUT}
                    '<script> window.location = "crap014.html" </script>'.
                 END.
            END.   /*get-value "ok" */   
        END.                           
    END.
    

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
/*    RUN findRecords.*/
    
    /* Return the form again. Set data values, display them, and output them
     * to the WEB stream.  
     *
     * STEP 2a -
     * Set any values that need to be set, then display them. */

    ASSIGN v_valorinf  = c_valorinf 
           v_codbarras = c_codbarras
           v_intitcop  = c_intitcop 
           v_conta     = c_conta
           v_nome      = c_nome.

    ASSIGN p_confvalor = NO
           p_confdata  = NO
           de_tit1     = 0
           de_tit2     = 0
           de_tit3     = 0
           de_tit4     = 0
           de_tit5     = 0.

    IF  UPPER(aux_dsmanual) = "MANUAL" THEN
        DO:
            ASSIGN de_tit1     = DECIMAL(get-value("ptitulo1"))
                   de_tit2     = DECIMAL(get-value("ptitulo2"))
                   de_tit3     = DECIMAL(get-value("ptitulo3"))
                   de_tit4     = DECIMAL(get-value("ptitulo4"))
                   de_tit5     = DECIMAL(get-value("ptitulo5"))
                   /* c_codbarras = "" */
                   aux_tpcptdoc = 2. /*1-Leitora 2-Digitado*/
        END.


    DO TRANSACTION ON ERROR UNDO:
    
        FOR FIRST crapcop FIELDS (cdcooper) 
             WHERE crapcop.nmrescop = v_coop
                NO-LOCK.
        END.
    
         { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
         RUN STORED-PROCEDURE pc_retorna_vlr_titulo_iptu
             aux_handproc = PROC-HANDLE NO-ERROR
            (INPUT crapcop.cdcooper,
             INPUT INT(v_conta),
             INPUT 0,   
             INPUT v_operador,
             INPUT int(v_pac),
             INPUT int(v_caixa),
             INPUT de_tit1,
             INPUT de_tit2,
             INPUT de_tit3,
             INPUT de_tit4,
             INPUT de_tit5,
             INPUT c_codbarras,
             INPUT 0, /* NO */
             INPUT DEC(v_valorinf),
             INPUT 0,
             INPUT 0,
             INPUT ?,
             INPUT v_cdctrlcs, /* pr_cdctrlcs */
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT "",
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT "").
    
         CLOSE STORED-PROC pc_retorna_vlr_titulo_iptu
               aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
    
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
        ASSIGN de_tit1 = pc_retorna_vlr_titulo_iptu.pr_titulo1  /*       IN OUT NUMBER             -- FORMAT "99999,99999" */
               de_tit2 = pc_retorna_vlr_titulo_iptu.pr_titulo2  /*       IN OUT NUMBER             -- FORMAT "99999,999999"  */
               de_tit3 = pc_retorna_vlr_titulo_iptu.pr_titulo3  /*       IN OUT NUMBER             -- FORMAT "99999,999999"  */
               de_tit4 = pc_retorna_vlr_titulo_iptu.pr_titulo4  /*       IN OUT NUMBER             -- FORMAT "9"            */
               de_tit5 = pc_retorna_vlr_titulo_iptu.pr_titulo5  /*       IN OUT NUMBER             -- FORMAT "zz,zzz,zzz,zzz999" */
               c_codbarras = pc_retorna_vlr_titulo_iptu.pr_codigo_barras  /*  IN OUT VARCHAR2     --Codigo de Barras */
               p_valor = pc_retorna_vlr_titulo_iptu.pr_vlfatura  /*      OUT NUMBER          --Valor da Fatura  */
               aux_dtdifere = pc_retorna_vlr_titulo_iptu.pr_outra_data /*     OUT PLS_INTEGER        --Outra data  */ 
               aux_vldifere = pc_retorna_vlr_titulo_iptu.pr_outro_valor /*    OUT PLS_INTEGER        --Outro valor   */ 
               aux-nrdconta-cob = pc_retorna_vlr_titulo_iptu.pr_nrdconta_cob /*   OUT INTEGER        --Numero Conta Cobranca */
               aux-insittit = pc_retorna_vlr_titulo_iptu.pr_insittit    /*    OUT INTEGER        --Situacao Titulo       */
               aux-intitcop = pc_retorna_vlr_titulo_iptu.pr_intitcop    /*    OUT INTEGER        --Titulo da Cooperativa */
               aux-convenio = pc_retorna_vlr_titulo_iptu.pr_convenio   /*     OUT NUMBER         --Numero Convenio       */
               aux-bloqueto = pc_retorna_vlr_titulo_iptu.pr_bloqueto   /*     OUT NUMBER         --Numero Bloqueto       */
               aux-contaconve = pc_retorna_vlr_titulo_iptu.pr_contaconve /*     OUT INTEGER        --Numero Conta Convenio */
               aux_cobregis = pc_retorna_vlr_titulo_iptu.pr_cobregis   /*     OUT PLS_INTEGER    --Cobranca Registrada   */
               par_msgalert = pc_retorna_vlr_titulo_iptu.pr_msgalert   /*     OUT VARCHAR2       --Mensagem de alerta    */
               par_vlrjuros = pc_retorna_vlr_titulo_iptu.pr_vlrjuros   /*     OUT NUMBER         --Valor dos Juros       */
               par_vlrmulta = pc_retorna_vlr_titulo_iptu.pr_vlrmulta   /*     OUT NUMBER         --Valor da Multa        */
               par_vldescto = pc_retorna_vlr_titulo_iptu.pr_vldescto   /*     OUT NUMBER         --Valor do Desconto     */
               par_vlabatim = pc_retorna_vlr_titulo_iptu.pr_vlabatim   /*     OUT NUMBER         --Valor do Abatimento   */
               par_vloutdeb = pc_retorna_vlr_titulo_iptu.pr_vloutdeb   /*     OUT NUMBER         --Valor Saida Debitado  */
               par_vloutcre = pc_retorna_vlr_titulo_iptu.pr_vloutcre   /*     OUT NUMBER         --Valor Saida Creditado */
               
               aux_cdcritic = 0
               aux_dscritic = ""
               aux_cdcritic = pc_retorna_vlr_titulo_iptu.pr_cdcritic 
                              WHEN pc_retorna_vlr_titulo_iptu.pr_cdcritic <> ?
               aux_dscritic = pc_retorna_vlr_titulo_iptu.pr_dscritic 
                              WHEN pc_retorna_vlr_titulo_iptu.pr_dscritic <> ?.
    
        ASSIGN p_confdata   = (aux_dtdifere = 1)
               p_confvalor  = (aux_vldifere = 1)
               par_cobregis = (aux_cobregis = 1).
    
    END. /* fim transaction */

    IF par_msgalert = ? THEN
       par_msgalert = " ".

    IF v_mensagem1 = ? THEN
       v_mensagem1 = " ".

    IF v_mensagem2 = ? THEN
       v_mensagem2 = " ".

    IF p_confvalor AND v_cdctrlcs = "" THEN
       ASSIGN v_mensagem1 = "O Valor Digitado difere do Valor Codificado".
    
    IF p_confdata THEN
       DO:
          IF   aux-intitcop = 0   THEN
               ASSIGN v_mensagem2 = "Documento Digitado em Outra Data".
          ELSE
               ASSIGN v_mensagem2 = "Documento Vencido. Observe instruções " + 
                                    "para cobrança de juros e multa.".
       END.
    ELSE
       ASSIGN v_mensagem2 = par_msgalert.

    ASSIGN v_tit1 = STRING(de_tit1,"99999,99999")
           v_tit2 = STRING(de_tit2,"99999,999999")
           v_tit3 = STRING(de_tit3,"99999,999999")
           v_tit4 = STRING(de_tit4,"9")
           v_tit5 = STRING(de_tit5,"zz,zzz,zzz,zzz999")
       
           v_valordoc = STRING(p_valor,"zzz,zzz,zzz,zz9.99").
    ASSIGN v_valorinf = STRING(DEC(v_valorinf),"zzz,zzz,zzz,zz9.99").
    IF RETURN-VALUE = "NOK" THEN
    DO:
        {include/i-erro.i}
            /* Retornar p/ tela anterior */
    END.

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


                   
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verifica-erro w-html 

PROCEDURE verifica-erro: 

 DEF INPUT PARAM v_pac   AS CHAR.
 DEF INPUT PARAM v_caixa AS CHAR.

 
 FOR EACH craperr WHERE
          craperr.cdcooper = crapcop.cdcooper  AND
          craperr.cdagenci = INTE(v_pac)       AND
          craperr.nrdcaixa = INTE(v_caixa) 
          EXCLUSIVE-LOCK:
     DELETE craperr.
 END.
                                      
 FIND FIRST w-craperr NO-LOCK NO-ERROR.
 IF  NOT AVAILABLE w-craperr THEN DO:
     CREATE craperr.
     ASSIGN craperr.cdcooper   = crapcop.cdcooper 
            craperr.cdagenci   = INTE(v_pac)
            craperr.nrdcaixa   = INTE(v_caixa)      
            craperr.nrsequen   = 1
            craperr.cdcritic   = 0
            craperr.dscritic   = 
  "ERRO!!! PA ZERADO. FECHE O CAIXA E AVISE O CPD"
            craperr.erro       = YES.
     VALIDATE craperr.

 END.
 ELSE
   FOR EACH w-craperr NO-LOCK WHERE
             w-craperr.cdagenci =  INT(v_pac)   AND
             w-craperr.nrdcaixa =  INT(v_caixa):

        CREATE craperr.
        ASSIGN craperr.cdcooper   = crapcop.cdcooper
               craperr.cdagenci   = w-craperr.cdagenc
               craperr.nrdcaixa   = w-craperr.nrdcaixa
               craperr.nrsequen   = w-craperr.nrsequen
               craperr.cdcritic   = w-craperr.cdcritic
               craperr.dscritic   = w-craperr.dscritic
               craperr.erro       = w-craperr.erro.
        VALIDATE craperr.

    END.
  {include/i-erro.i}                               

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

                       



