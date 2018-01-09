/* .............................................................................

   Programa: siscaixa/web/crap054.w
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 10/10/2016

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Movimentacoes  - Cheque Avulso (Historico 22)

   Alteracoes: 25/08/2005 - Passar codigo da cooperativa como parametro para
                            as procedures (Julio)

               13/03/2006 - Acrescentada leitura do campo cdcooper nas tabelas
                            (Diego).
                            
               25/10/2006 - Controle para exclusao das instancias das BO's
                            (Evandro).
                            
               18/12/2009 - Adicionado numero do lote na chamada da rotina
                            crap051f.w (Fernando).    
                            
               04/05 /2010 - Adicionado parametro flgrebcc na chamada da rotina
                            crap051f (Fernando).                       
                            
               13/12/2011 - Saque com o cartao magnetico (Gabriel).
               
               19/01/2012 - Alterado nrsencar para dssencar (Guilherme). 2317346
               
               04/06/2013 - Alterações p/ visualização de informações no PINPAD (Jean Michel).
               
               13/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO) 
                            
               18/03/2015 - Adicionado recebimento de parâmetros de Conta/nome para
                            Melhoria SD 260475 (Lunelli).
               
               23/11/2015 - #351803 Ajuste na verificacao dos retornos de erros
                            para verificar RETURN-VALUE <> "OK" (Carlos)
                            
               23/02/2016 - Tratamentos para utilizaçao do Cartao CECRED e 
                            PinPad Novo (Lucas Lunelli - [PROJ290])
                            
               10/10/2016 - Incluir log na chamada da rotina crap051f - Controle 
                            de movimentacao em especie (Lucas Ranghetti #463572)
............................................................................ */

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions */
DEFINE TEMP-TABLE ab_unmap
       FIELD cancela       AS CHARACTER FORMAT "X(256)":U 
       FIELD ok            AS CHARACTER FORMAT "X(256)":U 
       FIELD vh_foco       AS CHARACTER FORMAT "X(256)":U 
       FIELD v_action      AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa       AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cod         AS CHARACTER FORMAT "X(256)":U 
       FIELD v_conta       AS CHARACTER FORMAT "X(256)":U
       FIELD v_opcao       AS CHARACTER FORMAT "X(256)":U
       FIELD v_cartao      AS CHARACTER FORMAT "X(256)":U
       FIELD v_coop        AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data        AS CHARACTER FORMAT "X(256)":U 
       FIELD v_mensagem    AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg         AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msgtrf      AS CHARACTER FORMAT "X(256)":U 
       FIELD v_senhaCartao AS CHARACTER FORMAT "X(256)":U 
       FIELD v_infocry     AS CHARACTER FORMAT "X(256)":U               
       FIELD v_chvcry      AS CHARACTER FORMAT "X(256)":U       
       FIELD v_nrdocard    AS CHARACTER FORMAT "X(256)":U               
       FIELD v_nome        AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador    AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac         AS CHARACTER FORMAT "X(256)":U 
       FIELD v_senha       AS CHARACTER FORMAT "X(256)":U 
       FIELD v_valor       AS CHARACTER FORMAT "X(256)":U 
       FIELD v_habilita    AS CHARACTER FORMAT "X(256)":U INIT "no"
       FIELD v_coordenador AS CHARACTER FORMAT "X(256)":U INIT "no"
       FIELD v_saldo_conta AS CHARACTER FORMAT "X(256)":U.  
DEFINE VARIABLE v_mensagem_bkp AS CHARACTER   NO-UNDO.

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

DEF VAR h-b1crap54 AS HANDLE            NO-UNDO.
DEF VAR h-b1crap00 AS HANDLE            NO-UNDO.

DEF VAR p-literal            AS CHAR    NO-UNDO.
DEF VAR p-conta              AS DECI    NO-UNDO.
DEF VAR p-ult-sequencia      AS INTE    NO-UNDO.
DEF VAR p-registro           AS RECID   NO-UNDO.
DEF VAR c-autentica          AS CHAR    FORMAT "x(58)" NO-UNDO.
DEF VAR p-mensagem-saldo     AS CHAR    FORMAT "x(50)" NO-UNDO.
DEF VAR p-valor-disponivel   AS DEC     NO-UNDO.
DEF VAR p-saldo-conta        AS CHAR    NO-UNDO.
DEF VAR p-nrdocmto           AS INTE    NO-UNDO.
DEF VAR p-nrdolote           AS INTE    NO-UNDO.
DEF VAR flgsubopcao          AS LOGI    NO-UNDO.
DEF VAR p-programa           AS CHAR INITIAL "CRAP054".
DEF VAR p-flgdebcc           AS LOGI INITIAL FALSE.

DEF VAR aux_nrdconta    AS INTE.
DEF VAR aux_vllanmto    LIKE craplcm.vllanmto.
DEF VAR aux_nmarqlog    AS CHAR         NO-UNDO.

DEF VAR l-houve-erro    AS LOG          NO-UNDO.

DEF TEMP-TABLE w-craperr  NO-UNDO
     FIELD cdcooper   LIKE craperr.cdcooper
     FIELD cdagenci   LIKE craperr.cdagenc
     FIELD nrdcaixa   LIKE craperr.nrdcaixa
     FIELD nrsequen   LIKE craperr.nrsequen
     FIELD cdcritic   LIKE craperr.cdcritic
     FIELD dscritic   LIKE craperr.dscritic
     FIELD erro       LIKE craperr.erro.

DEF VAR i-campo      AS INT NO-UNDO.
DEF VAR de-valor     AS DEC NO-UNDO.
DEF VAR p-nrcartao   AS DEC NO-UNDO.
DEF VAR p-idtipcar   AS INT NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE web/crap054.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.cancela ab_unmap.ok ab_unmap.v_msgtrf ab_unmap.v_senhaCartao ab_unmap.v_nrdocard  ab_unmap.v_infocry ab_unmap.v_chvcry ab_unmap.v_action ab_unmap.v_cod ab_unmap.v_senha ab_unmap.v_nome ab_unmap.v_mensagem ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_opcao  ab_unmap.v_cartao ab_unmap.v_conta ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_valor ab_unmap.v_habilita ab_unmap.v_coordenador ab_unmap.v_saldo_conta
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.cancela ab_unmap.ok ab_unmap.v_msgtrf ab_unmap.v_senhaCartao ab_unmap.v_nrdocard ab_unmap.v_infocry ab_unmap.v_chvcry ab_unmap.v_action ab_unmap.v_cod ab_unmap.v_senha ab_unmap.v_nome ab_unmap.v_mensagem ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_opcao ab_unmap.v_cartao ab_unmap.v_conta ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_valor ab_unmap.v_habilita ab_unmap.v_coordenador ab_unmap.v_saldo_conta

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.cancela AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.ok AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_senhaCartao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_infocry AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1          
     ab_unmap.v_nrdocard AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1                   
     ab_unmap.v_chvcry AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1          
     ab_unmap.v_msgtrf AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_action AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cod AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_senha AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nome AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_mensagem AT ROW 1 COL 1 HELP
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
      ab_unmap.v_opcao AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
           "v_opcao 1", "R":U,
           "v_opcao 2", "C":U 
           SIZE 20 BY 2
    ab_unmap.v_cartao AT ROW 1 COL 1 HELP
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
     ab_unmap.v_valor AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_habilita AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_coordenador AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_saldo_conta AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 45.2 BY 10.76.
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
          FIELD cancela AS CHARACTER FORMAT "X(256)":U 
          FIELD ok AS CHARACTER FORMAT "X(256)":U 
          FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
          FIELD v_action AS CHARACTER FORMAT "X(256)":U 
          FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cod AS CHARACTER FORMAT "X(256)":U 
          FIELD v_opcao AS CHARACTER FORMAT "X(256)":U 
          FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_mensagem AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msgtrf AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD v_senha AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valor AS CHARACTER FORMAT "X(256)":U 
          FIELD v_saldo_conta AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 10.76
         WIDTH              = 45.2.
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
/* SETTINGS FOR FILL-IN ab_unmap.cancela IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.ok IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.vh_foco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_action IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_caixa IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cod IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP  
/* SETTINGS FOR FILL-IN ab_unmap.v_opcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */                              */
/* SETTINGS FOR FILL-IN ab_unmap.v_conta IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_mensagem IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_msgtrf IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nome IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_senha IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_valor IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_saldo_conta IN FRAME Web-Frame
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
    ("cancela":U,"ab_unmap.cancela":U,ab_unmap.cancela:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("ok":U,"ab_unmap.ok":U,ab_unmap.ok:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("vh_foco":U,"ab_unmap.vh_foco":U,ab_unmap.vh_foco:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_action":U,"ab_unmap.v_action":U,ab_unmap.v_action:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_caixa":U,"ab_unmap.v_caixa":U,ab_unmap.v_caixa:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cod":U,"ab_unmap.v_cod":U,ab_unmap.v_cod:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_opcao":U,"ab_unmap.v_opcao":U,ab_unmap.v_opcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cartao":U,"ab_unmap.v_cartao":U,ab_unmap.v_cartao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_conta":U,"ab_unmap.v_conta":U,ab_unmap.v_conta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_mensagem":U,"ab_unmap.v_mensagem":U,ab_unmap.v_mensagem:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msgtrf":U,"ab_unmap.v_msgtrf":U,ab_unmap.v_msgtrf:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
      ("v_senhaCartao":U,"ab_unmap.v_senhaCartao":U,ab_unmap.v_senhaCartao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_infocry":U,"ab_unmap.v_infocry":U,ab_unmap.v_infocry:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("v_chvcry":U,"ab_unmap.v_chvcry":U,ab_unmap.v_chvcry:HANDLE IN FRAME {&FRAME-NAME}).            
  RUN htmAssociate
    ("v_nrdocard":U,"ab_unmap.v_nrdocard":U,ab_unmap.v_nrdocard:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nome":U,"ab_unmap.v_nome":U,ab_unmap.v_nome:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_senha":U,"ab_unmap.v_senha":U,ab_unmap.v_senha:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_valor":U,"ab_unmap.v_valor":U,ab_unmap.v_valor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_habilita":U,"ab_unmap.v_habilita":U,ab_unmap.v_habilita:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("v_coordenador":U,"ab_unmap.v_coordenador":U,ab_unmap.v_coordenador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_saldo_conta":U,"ab_unmap.v_saldo_conta":U,ab_unmap.v_saldo_conta:HANDLE IN FRAME {&FRAME-NAME}).
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

    DEFINE VARIABLE lOpenAutentica  AS LOGICAL      NO-UNDO INITIAL NO.
    DEFINE VARIABLE lValorOk        AS LOGICAL      NO-UNDO.
    DEFINE VARIABLE cMsgAux         AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cMsgSaldo         AS CHARACTER    NO-UNDO.

    RUN outputHeader.
    {include/i-global.i}

    IF REQUEST_METHOD = "POST":U THEN DO:
           
        RUN inputFields.
   
        RUN findRecords.
        
        {include/assignfields.i}

        RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.

        RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                           INPUT int(v_pac), 
                                           INPUT int(v_caixa)).
        DELETE PROCEDURE h-b1crap00.

        IF RETURN-VALUE = "NOK" THEN DO:
            {include/i-erro.i}
        END.
            
        ELSE DO:
            IF get-value("cancela") <> "" THEN DO:
                ASSIGN v_opcao     = "R"
                       v_conta     = ""
                       v_nome      = ""
                       v_mensagem  = ''
                       v_saldo_conta = ''
                       v_msgtrf    = ''
                       v_valor     = ""
                       v_cod       = ""
                       v_senha     = "" 
                       vh_foco     = "12"
                       v_action    = ""
                       v_nrdocard  = ""
                       v_infocry   = ""
                       v_chvcry    = ""
                       flgsubopcao = FALSE
                       OK = ''
                       cancela = ''.
                
            END.
            ELSE DO:
                RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
                RUN verifica-abertura-boletim IN h-b1crap00(INPUT v_coop,
                                                            INPUT int(v_pac),
                                                            INPUT int(v_caixa),
                                                            INPUT v_operador).

                DELETE PROCEDURE h-b1crap00.
                
                IF  RETURN-VALUE <> "OK" THEN DO:
                    ASSIGN v_cod       = ""
                           v_senha     = "".
                    {include/i-erro.i}
                END.
                ELSE DO:
                    ASSIGN p-conta = DECI(v_conta).

                    RUN dbo/b1crap54.p PERSISTENT SET h-b1crap54.

                    RUN valida-cheque-avulso-conta IN h-b1crap54(
                                                        INPUT  v_coop,      
                                                        INPUT  INT(v_pac),    
                                                        INPUT  INT(v_caixa),
                                                        INPUT  v_opcao,
                                                        INPUT  DEC(v_cartao),
                                                 INPUT-OUTPUT  p-conta,
                                                        OUTPUT v_nome,
                                                        OUTPUT v_msgtrf,
                                                        OUTPUT p-nrcartao,
                                                        OUTPUT p-idtipcar).
                    DELETE PROCEDURE h-b1crap54.

                    IF  RETURN-VALUE <> "OK" THEN DO:
                        ASSIGN v_conta = "" 
                               v_cod       = ""
                               v_senha     = ""
                               v_nrdocard  = "".
                       
                        {include/i-erro.i}
                    END.
                        
                    ELSE DO:
                        
                        ASSIGN v_conta = STRING(p-conta,"zzzz,zzz,9")
                            v_nrdocard = STRING(p-nrcartao).
                                                
                        RUN dbo/b1crap54.p PERSISTENT SET h-b1crap54.
                        RUN lista-saldo-conta IN  h-b1crap54(
                                                         INPUT  v_coop,    
                                                         INPUT  INT(v_pac),    
                                                         INPUT  INT(v_caixa),
                                                         INPUT  DEC(v_conta),
                                                         INPUT  DEC(v_valor),
                                                         OUTPUT v_mensagem,
                                                         OUTPUT v_saldo_conta).
                        
                        DELETE PROCEDURE h-b1crap54.
                        
                        IF  RETURN-VALUE <> "OK" THEN DO:
                            ASSIGN v_conta = ""
                                   v_cod       = ""
                                   v_senha     = "".
                            {include/i-erro.i}
                        END.
                            
                        ELSE DO:
                            
                            

                            ASSIGN lValorOk = YES.
                            IF v_action <> 'LeaveConta'   AND 
                               v_action <> 'LeaveCartao'  THEN DO:
                                RUN dbo/b1crap54.p PERSISTENT SET h-b1crap54.
                                RUN valida-cheque-avulso-valor IN h-b1crap54(
                                                         INPUT v_coop,      
                                                         INPUT INT(v_pac),
                                                         INPUT INT(v_caixa),
                                                         INPUT DEC(v_valor)).
                                DELETE PROCEDURE h-b1crap54.

                                IF RETURN-VALUE = "NOK" THEN DO:
                                    {include/i-erro.i}
                                    ASSIGN v_cod       = ""
                                           v_senha     = "" 
                                           lValorOk = NO.
                                END.
                            END.

                            IF lValorOk THEN DO:
                                RUN dbo/b1crap54.p PERSISTENT SET h-b1crap54.
                                
                                RUN valida-saldo-conta IN h-b1crap54(
                                               INPUT  v_coop,       
                                               INPUT  INT(v_pac),    
                                               INPUT  INT(v_caixa),
                                               INPUT  DEC(v_conta),
                                               INPUT  DEC(v_valor),
                                               OUTPUT cMsgAux,
                                               OUTPUT p-valor-disponivel).
                                DELETE PROCEDURE h-b1crap54.
                                
                                IF RETURN-VALUE = "NOK" THEN DO:
                                    ASSIGN v_cod   = ""
                                           v_senha = "".
                                    
                                    {include/i-erro.i}
                                END.
                                ELSE DO:
                                    IF cMsgAux <> ""  THEN
                                     DO: 
                                          ASSIGN v_habilita = 'yes'
                                               v_mensagem = cMsgAux.
                                               
                                    END.
                                              
                                    ELSE 
                                        ASSIGN  v_habilita = 'no'.

                                    IF v_action = 'LeaveConta' THEN DO:
                                        ASSIGN v_action = ''.                          
                                    END.
                                    ELSE DO:
                                        IF get-value("ok") <> "" THEN DO:

                                            ASSIGN v_mensagem_bkp = v_mensagem.

                                            /* limpar msg para validar nao coord */
                                            IF v_habilita <> 'yes' THEN
                                               ASSIGN v_mensagem = "".
                                                      
                                            RUN dbo/b1crap54.p 
                                                PERSISTENT SET h-b1crap54.
                                            
                                            RUN valida-permissao-saldo-conta 
                                                IN h-b1crap54(
                                                   INPUT  v_coop,       
                                                   INPUT  INT(v_pac),
                                                   INPUT  INT(v_caixa),
                                                   INPUT  DEC(v_valor),
                                                   INPUT  v_operador,
                                                   INPUT DEC(v_conta),
                                                   INPUT p-nrcartao,
                                                   INPUT v_opcao,
                                                   INPUT  v_senhaCartao,
                                                   INPUT  v_cod,
                                                   INPUT  v_senha,
                                                   INPUT  p-valor-disponivel,
                                                   INPUT  v_mensagem,
                                                   INPUT  p-idtipcar,
                                                   INPUT  v_infocry,
                                                   INPUT  v_chvcry).
                                            
                                            DELETE PROCEDURE h-b1crap54.
                                            
                                            ASSIGN v_mensagem = v_mensagem_bkp.

                                            IF RETURN-VALUE = 'NOK' THEN DO:
                                                
                                                ASSIGN v_cod   = ""
                                                       v_senha = ""
                                                       vh_foco = "19". 
                                                {include/i-erro.i}                       
                                            END.
                                            ELSE DO:
                                                ASSIGN l-houve-erro = NO
                                                       v_action = 'Ok'.
                                                DO TRANSACTION ON ERROR UNDO:

                                                RUN dbo/b1crap54.p 
                                                  PERSISTENT SET h-b1crap54.
                                              
                                                RUN atualiza-cheque-avulso
                                                    IN h-b1crap54(
                                                         INPUT v_coop,       
                                                         INPUT INT(v_pac),
                                                         INPUT INT(v_caixa),
                                                         INPUT v_operador,
                                                         INPUT v_cod,
                                                         INPUT v_opcao,
                                                         INPUT p-nrcartao,
                                                         INPUT p-idtipcar,
                                                         INPUT DEC(v_conta),
                                                         INPUT DEC(v_valor),
                                                        OUTPUT p-nrdocmto,
                                                        OUTPUT p-literal,
                                                        OUTPUT p-ult-sequencia).

                                                DELETE PROCEDURE h-b1crap54.

                                                IF RETURN-VALUE = "NOK" THEN DO:
                                                   ASSIGN l-houve-erro = YES.
                                                        
                                                   EMPTY TEMP-TABLE w-craperr.
                                                   
                                                   FOR EACH craperr 
                                                            NO-LOCK WHERE
                                                       craperr.cdcooper =
                                                               crapcop.cdcooper
                                                       AND  
                                                       craperr.cdagenci =
                                                               INT(v_pac) 
                                                       AND
                                                       craperr.nrdcaixa =
                                                               INT(v_caixa):

                                                       CREATE w-craperr.
                                                       ASSIGN 
                                                            w-craperr.cdcooper =
                                                              craperr.cdcooper
                                                            w-craperr.cdagenci =
                                                              craperr.cdagenc
                                                            w-craperr.nrdcaixa =
                                                              craperr.nrdcaixa
                                                            w-craperr.nrsequen =
                                                              craperr.nrsequen
                                                            w-craperr.cdcritic =
                                                              craperr.cdcritic
                                                            w-craperr.dscritic =
                                                              craperr.dscritic
                                                            w-craperr.erro    =
                                                              craperr.erro.
                                                   END.
                                                   UNDO.
                                                     
                                                END.
                                                ELSE
                                                   DO:
                                                        IF   v_opcao = "C"   THEN
                                                            {&OUT}
                                                            "<script>           
                                                                alert('Saque efetuado com sucesso'); 
                                                            </script>".  
                                                   END.
                                                    
                                                END. /* do transaction */

                                                IF l-houve-erro = YES  THEN DO:
                                                    FOR EACH w-craperr NO-LOCK:
                                                        CREATE craperr.
                                                        ASSIGN 
                                                        craperr.cdcooper =
                                                           w-craperr.cdcooper
                                                        craperr.cdagenci =
                                                           w-craperr.cdagenc
                                                        craperr.nrdcaixa =
                                                           w-craperr.nrdcaixa
                                                        craperr.nrsequen =
                                                           w-craperr.nrsequen
                                                        craperr.cdcritic =
                                                           w-craperr.cdcritic
                                                        craperr.dscritic =
                                                           w-craperr.dscritic
                                                        craperr.erro     =
                                                           w-craperr.erro.
                                                        VALIDATE craperr.
                                                    END.
                                                    ASSIGN v_cod       = ""
                                                           v_senha     = "".
                                                    
                                                    {include/i-erro.i}
                                                END.

                                                IF l-houve-erro = NO THEN do:     
                                                    ASSIGN lOpenAutentica = YES.

                                                    ASSIGN aux_nrdconta =
                                                               INTE(v_conta)
                                                           aux_vllanmto =
                                                               DEC(v_valor) 
                                                           v_conta     = ""
                                                           v_nome      = ""
                                                           v_valor     = ""
                                                           v_mensagem  = ""
                                                           v_saldo_conta = ""
                                                           v_msgtrf    = ''
                                                           v_cod       = ""
                                                           v_senha     = "" 
                                                           v_action    = ""
                                                           v_habilita  = 'no'
                                                           v_cartao    = ""
                                                           v_senhaCartao = ""
                                                           v_infocry    = ""
                                                           v_chvcry     = ""
                                                           flgsubopcao  = TRUE
                                                           v_nrdocard   = ""
                                                           OK = ''.
                                                END.
                                            END.

                                        END. /*ok*/

                                    END. /*leaveConta*/

                                END.
                            END.
                        END.
                    END.
                END.

            END.
        END.

        
    
        IF lOpenAutentica THEN DO:

            IF   v_opcao = "R"   THEN
                 {&OUT}
                '<script>window.open("autentica.html?v_plit=" + "' p-literal '" + 
                "&v_pseq=" + "' p-ult-sequencia '" + "&v_prec=" + "yes"  + "&v_psetcook=" + "yes","waut","width=250,height=145,scrollbars=auto,alwaysRaised=true")
                 </script>'.

            /*** Incluido por Magui 19/08/2003 ***/
            IF   aux_vllanmto <> 0   THEN
                 DO:                                  
                    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                                       craptab.nmsistem = "CRED"            AND
                                       craptab.tptabela = "GENERI"          AND
                                       craptab.cdempres = 0                 AND
                                       craptab.cdacesso = "VLCTRMVESP"      AND
                                       craptab.tpregist = 0   NO-LOCK NO-ERROR.

                    IF   AVAILABLE craptab   THEN             
                         DO:
                             IF  aux_vllanmto >= DEC(craptab.dstextab)   THEN
                                 DO:
                                 
                                     ASSIGN aux_nmarqlog = "/usr/coop/" + crapcop.dsdircop + 
                                                           "/log/caixa_online_"            +
                                                           STRING(YEAR(TODAY),"9999")      +
                                                           STRING(MONTH(TODAY),"99")       +
                                                           STRING(DAY(TODAY),"99") + ".log".      
                                                           
                                     UNIX SILENT VALUE("echo " +  
                                                        STRING(TIME,"HH:MM:SS") + "' --> '"          +
                                                        "ROTINA: " + CAPS(p-programa) +  "/CRAP051f" +                                      
                                                        " PA: " + STRING(v_pac)                      +
                                                        " CAIXA: " + STRING(v_caixa)                 +
                                                        " OPERADOR: " + STRING(v_operador)           +
                                                        " CONTA SAQUE: " + STRING(aux_nrdconta,"zzzz,zzz,z") +
                                                        " VALOR: " + STRING(aux_vllanmto,"zzz,zzz,zz9.99")                 +
                                                        " AUTENTICACAO: " + STRING(p-ult-sequencia)  +
                                                        " - ROTINA: CONTROLE DE MOVIMENTACAO EM ESPECIE" +
                                                        " >> " + aux_nmarqlog).    
                                 
                                     ASSIGN p-nrdolote = 11000 + INT(v_caixa). 
                                               
                                     {&OUT}
                                '<script> window.location=
                        "crap051f.w?v_pconta=' + STRING(aux_nrdconta) '" + 
                        "&v_pvalor=" + "' aux_vllanmto '" +
                        "&v_pnrdocmto=" + "' p-nrdocmto '" +
                        "&v_pult_sequencia=" + "' p-ult-sequencia '" +
                        "&v_pconta_base=" + "' STRING(aux_nrdconta) '" +
                        "&v_nrdolote=" + "' STRING(p-nrdolote) '" +  
                        "&v_pprograma=" + "' p-programa '" +
                        "&v_flgdebcc=" + "' p-flgdebcc '" </script>'.
                                                                        
                                 END.
                          END.
                 END.         
        END.

        IF  flgsubopcao THEN 
            ASSIGN v_opcao      = "R".                      
        
        RUN displayFields.
        RUN enableFields.
        RUN outputFields.

    END. /* Form has been submitted. */
 
    /* REQUEST-METHOD = GET */ 
    ELSE DO:

        ASSIGN v_mensagem = "".

        IF  DECI(GET-VALUE("v_vlr_sacar")) > 0 THEN
            ASSIGN v_valor     = TRIM(GET-VALUE("v_vlr_sacar"))
                   vh_foco     = "16".

        /* Vinda da Rotina do BL (BLSAL) */
        IF  INTE(GET-VALUE("v_conta")) > 0 THEN
            DO:
                ASSIGN v_conta     = STRING(INTE(GET-VALUE("v_conta")), "zzzz,zz9,9")
                       v_nome      = GET-VALUE("v_nome").

                RUN dbo/b1crap54.p PERSISTENT SET h-b1crap54.
                RUN lista-saldo-conta IN  h-b1crap54(
                                                 INPUT  v_coop,    
                                                 INPUT  INT(v_pac),    
                                                 INPUT  INT(v_caixa),
                                                 INPUT  DEC(v_conta),
                                                 INPUT  DEC(v_valor),
                                                 OUTPUT v_mensagem,
                                                 OUTPUT v_saldo_conta).
                
                DELETE PROCEDURE h-b1crap54.
                
                IF  RETURN-VALUE = "NOK" THEN DO:
                    ASSIGN v_conta = ""
                           v_cod       = ""
                           v_senha     = "".
                    {include/i-erro.i}
                END.

            END.

        RUN findRecords.       
        RUN displayFields.
        RUN enableFields.
        RUN outputFields.
    END.

    /* Show error messages. */
    IF AnyMessage() THEN DO:
        ShowDataMessages().
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


