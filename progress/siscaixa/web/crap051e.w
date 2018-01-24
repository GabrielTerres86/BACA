/* .............................................................................

   Programa: Web/crap051e.w
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Agosto/2003                     Ultima atualizacao: 04/10/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Controle de movimentacao em especie - Depositos.

   Alteracoes: 29/09/2003 - Nao registrar acima de 100.000 quando pessoa
                            juridica (Margarete)

               13/03/2006 - Acrescentada leitura do campo cdcooper as tabelas
                            (Diego).
                            
               13/10/2006 - Controle para exclusao das instancias das BO's
                            (Evandro).
                            
               20/05/2011 - Tirar campo 'Registrar'.
                            Incluir campo 'Informações não prestadas pelo
                            cooperado'. Retirar destinatario (Gabriel).  
                            
               04/08/2011 - Retirar a impressao (Gabriel).   
               
               19/09/2011 - Retirar tipo de pessoa (Gabriel).   
               
               13/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)                     

               04/10/2016 - Verificar se existe  registro criado na tabela de controle de 
                            movimentacoes em especie. (Lucas Ranghetti #463572)
                            
               08/12/2017 - Melhoria 458, ajustar fonte para receber variavel v_tpdocmto
                            Antonio R. Jr (mouts)
............................................................................. */

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg AS CHARACTER FORMAT "x(256)":U
       FIELD v_nrccdrcb AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nmpesrcb AS CHARACTER FORMAT "X(256)":U 
       FIELD v_inpesrcb AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cpfcgrcb AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nridercb AS CHARACTER FORMAT "X(256)":U 
       FIELD v_dtnasrcb AS CHARACTER FORMAT "X(256)":U 
       FIELD v_desenrcb AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nmcidrcb AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cdufdrcb AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nrceprcb AS CHARACTER FORMAT "X(256)":U 
       FIELD v_recursos AS CHARACTER FORMAT "X(256)":U        
       FIELD flinfdst   AS CHAR.

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


DEFINE VARIABLE h-b1crap51 AS HANDLE     NO-UNDO.
DEFINE VARIABLE h-bo-depos AS HANDLE     NO-UNDO.

DEF VAR p-aux-indevchq   AS INTE NO-UNDO.
DEF VAR p-nrdocmto       AS INTE NO-UNDO.
DEF VAR p-conta-atualiza AS INTE no-undo.
DEF VAR p-histor         AS INTE NO-UNDO.
DEF VAR p-nmarqimp       AS CHAR NO-UNDO.

DEF VAR p-literal        AS CHAR  NO-UNDO.
DEF VAR p-ult-sequencia  AS INTE  NO-UNDO.
DEF var p-registro       AS RECID NO-UNDO.

DEF VAR aux_flgconta     AS LOGICAL NO-UNDO.
DEF VAR aux_focoerro     AS CHAR    NO-UNDO.

DEF VAR l-houve-erro    AS LOG          NO-UNDO.
DEF VAR i-cod-erro      AS INTE         NO-UNDO.

DEF TEMP-TABLE w-craperr  NO-UNDO
     FIELD cdagenci   LIKE craperr.cdagenc
     FIELD nrdcaixa   LIKE craperr.nrdcaixa
     FIELD nrsequen   LIKE craperr.nrsequen
     FIELD cdcritic   LIKE craperr.cdcritic
     FIELD dscritic   LIKE craperr.dscritic
     FIELD erro       LIKE craperr.erro.

DEF VAR v_mensagem1 AS CHAR NO-UNDO.
DEF VAR v_mensagem2 AS CHAR NO-UNDO.
DEF VAR v_vlmincen  AS DEC  NO-UNDO.
DEF VAR v_nrdctabb  AS CHAR NO-UNDO.
DEF VAR v_nrdocmto  AS CHAR NO-UNDO.

DEF VAR v_nome      AS CHAR NO-UNDO.
DEF VAR v_poupanca  AS CHAR no-undo.
DEF VAR v_valor     AS CHAR NO-UNDO.
DEF VAR v_valor1    AS CHAR NO-UNDO.
DEF VAR v_programa  AS CHAR NO-UNDO.
DEF VAR aux_nrdctabb AS DECI NO-UNDO.
DEF VAR aux_nrdocmto AS DECI NO-UNDO.
DEF VAR aux_nmarqlog AS CHAR NO-UNDO.
DEF VAR v_tpdocmto    AS INTE NO-UNDO.
DEF VAR v_vlcontresp  AS CHAR NO-UNDO.

DEF VAR p-mensagem         AS CHAR no-undo.

DEF VAR p-mensagem1        AS CHAR NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE crap051e.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.v_nrccdrcb ab_unmap.v_nmpesrcb ab_unmap.v_cpfcgrcb ab_unmap.v_nridercb ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_dtnasrcb ab_unmap.v_desenrcb ab_unmap.v_data ab_unmap.v_nmcidrcb ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_cdufdrcb ab_unmap.v_nrceprcb ab_unmap.v_recursos ab_unmap.v_nrccddst ab_unmap.v_nmpesdst ab_unmap.v_inpesdst ab_unmap.v_cpfcgdst ab_unmap.v_nridedst ab_unmap.v_dtnasdst ab_unmap.v_desendst ab_unmap.v_nmciddst ab_unmap.v_cdufddst ab_unmap.v_nrcepdst ab_unmap.v_coop ab_unmap.v_msg ab_unmap.flinfdst 
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.v_nrccdrcb ab_unmap.v_nmpesrcb ab_unmap.v_cpfcgrcb ab_unmap.v_nridercb ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_dtnasrcb ab_unmap.v_desenrcb ab_unmap.v_data ab_unmap.v_nmcidrcb ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_cdufdrcb ab_unmap.v_nrceprcb ab_unmap.v_recursos ab_unmap.v_nrccddst ab_unmap.v_nmpesdst ab_unmap.v_inpesdst ab_unmap.v_cpfcgdst ab_unmap.v_nridedst ab_unmap.v_dtnasdst ab_unmap.v_desendst ab_unmap.v_nmciddst ab_unmap.v_cdufddst ab_unmap.v_nrcepdst ab_unmap.v_coop ab_unmap.v_msg ab_unmap.flinfdst

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.v_coop AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_msg AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nrccdrcb AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nmpesrcb AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cpfcgrcb AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nridercb AT ROW 1 COL 1 HELP
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
     ab_unmap.v_dtnasrcb AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_desenrcb AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_data AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nmcidrcb AT ROW 1 COL 1 HELP
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
     ab_unmap.v_nrceprcb AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_recursos AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cdufdrcb AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.flinfdst AT ROW 1 COL 1 HELP
          "" NO-LABEL 
           VIEW-AS RADIO-SET VERTICAL
           RADIO-BUTTONS 
           "flinfdst 1", "S":U,                 
           "flinfdst 2", "N":U   
           SIZE 20 BY 3
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 65.8 BY 13.67.


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
       FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop AS CHARACTER FORMAT "X(256)":U
       FIELD v_msg  AS CHARACTER FORMAT "X(256)":U
       FIELD v_nrccdrcb AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nmpesrcb AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cpfcgrcb AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nridercb AS CHARACTER FORMAT "X(256)":U 
       FIELD v_dtnasrcb AS CHARACTER FORMAT "X(256)":U 
       FIELD v_desenrcb AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nmcidrcb AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cdufdrcb AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nrceprcb AS CHARACTER FORMAT "X(256)":U 
       FIELD v_recursos AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nrccddst AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nmpesdst AS CHARACTER FORMAT "X(256)":U 
       FIELD v_inpesdst AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cpfcgdst AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nridedst AS CHARACTER FORMAT "X(256)":U 
       FIELD v_dtnasdst AS CHARACTER FORMAT "X(256)":U 
       FIELD v_desendst AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nmciddst AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cdufddst AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nrcepdst AS CHARACTER FORMAT "X(256)":U
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 13.67
         WIDTH              = 65.8.
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
/* SETTINGS FOR FILL-IN ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.vh_foco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_caixa IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nrccdrcb IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nmpesrcb IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cpfcgrcb IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nridercb IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_dtnasrcb IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_desenrcb IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nmcidrcb IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cdufdrcb IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nrceprcb IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_recursos IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nrccddst IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nmpesdst IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_inpesdst IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cpfcgdst IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nridedst IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_dtnasdst IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_desendst IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nmciddst IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cdufddst IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nrcepdst IN FRAME Web-Frame
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
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("vh_foco":U,"ab_unmap.vh_foco":U,ab_unmap.vh_foco:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_caixa":U,"ab_unmap.v_caixa":U,ab_unmap.v_caixa:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nrccdrcb":U,"ab_unmap.v_nrccdrcb":U,ab_unmap.v_nrccdrcb:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nmpesrcb":U,"ab_unmap.v_nmpesrcb":U,ab_unmap.v_nmpesrcb:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cpfcgrcb":U,"ab_unmap.v_cpfcgrcb":U,ab_unmap.v_cpfcgrcb:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nridercb":U,"ab_unmap.v_nridercb":U,ab_unmap.v_nridercb:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_dtnasrcb":U,"ab_unmap.v_dtnasrcb":U,ab_unmap.v_dtnasrcb:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_desenrcb":U,"ab_unmap.v_desenrcb":U,ab_unmap.v_desenrcb:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nmcidrcb":U,"ab_unmap.v_nmcidrcb":U,ab_unmap.v_nmcidrcb:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cdufdrcb":U,"ab_unmap.v_cdufdrcb":U,ab_unmap.v_cdufdrcb:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nrceprcb":U,"ab_unmap.v_nrceprcb":U,ab_unmap.v_nrceprcb:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_recursos":U,"ab_unmap.v_recursos":U,ab_unmap.v_recursos:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
         ("flinfdst":U,"ab_unmap.flinfdst":U,ab_unmap.flinfdst:HANDLE IN FRAME {&FRAME-NAME}). 

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

RUN outputHeader.
{include/i-global.i}

FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                   craptab.nmsistem = "CRED"            AND
                   craptab.tptabela = "GENERI"          AND
                   craptab.cdempres = 0                 AND
                   craptab.cdacesso = "VMINCTRCEN"      AND
                   craptab.tpregist = 0   NO-LOCK NO-ERROR.
               
ASSIGN v_vlmincen       = DECIMAL(craptab.dstextab)
       v_valor          = get-value("v_pvalor")
       p-ult-sequencia  = INTE(get-value("v_pult_sequencia"))
       p-conta-atualiza = INTE(get-value("v_pconta"))
       v_nome           = get-value("v_pnome")
       v_poupanca       = get-value("v_ppoup")
       v_valor1   = string(dec(get-value("v_pvalor1")),"zzz,zzz,zzz,zz9.99")
       v_programa = get-value("v_pprograma")
       v_tpdocmto = INTE(get-value("v_ptpdocmto"))
       v_vlcontresp = STRING(dec(get-value("v_pvlcontresp")),"zzz,zzz,zzz,zz9.99").
       
IF REQUEST_METHOD = 'POST':U   THEN
   DO:

      RUN inputFields.

      {include/assignfields.i}

      ASSIGN aux_nmarqlog = "/usr/coop/" + crapcop.dsdircop + 
                            "/log/caixa_online_"            +
                            STRING(YEAR(TODAY),"9999")      +
                            STRING(MONTH(TODAY),"99")       +
                            STRING(DAY(TODAY),"99") + ".log".           
     
      IF get-value('cancela') <> ''   THEN
         DO:
            ASSIGN vh_foco     = '9'     flinfdst    = 'S'
                   v_nrccdrcb  = ''      v_nmpesrcb  = ''
                   v_cpfcgrcb  = ''
                   v_nridercb  = ''      v_dtnasrcb  = ''
                   v_desenrcb  = ''      v_nmcidrcb  = ''
                   v_cdufdrcb  = ''      v_nrceprcb  = ''
                   v_recursos  = ''.                    
         END.
      ELSE 
         DO:
         
            ASSIGN v_nrccdrcb = REPLACE(v_nrccdrcb,'.','')
                  v_cpfcgrcb = REPLACE(v_cpfcgrcb,'/','')
                   v_cpfcgrcb = REPLACE(v_cpfcgrcb,'.','')
                   v_cpfcgrcb = REPLACE(v_cpfcgrcb,'-','')
                   v_nrceprcb = REPLACE(v_nrceprcb,'-','').                      
            
                           
            RUN dbo/b1crap51.p PERSISTENT SET h-b1crap51.
            RUN elimina-erro 
                IN h-b1crap51 ( INPUT v_coop,
                                INTEGER(v_pac), INTEGER(v_caixa)).
            DELETE PROCEDURE h-b1crap51.

            ASSIGN l-houve-erro = NO
                   aux_focoerro = ''.

            IF v_programa <> 'CRAP014' THEN DO: 
            FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                               crapass.nrdconta = p-conta-atualiza
                         NO-LOCK NO-ERROR.
            IF NOT AVAILABLE crapass   THEN
               DO:
                   ASSIGN i-cod-erro   = 9
                          l-houve-erro = YES
                          vh_foco      = '9'.
                   {include/i-erro.i}
               END.
            END.
                          
            IF v_nrccdrcb <> ''   THEN DO:
               RUN dbo/bo_controla_depositos.p PERSISTENT SET h-bo-depos.
               RUN retorna-depositante-sacador
                           IN h-bo-depos (INPUT v_coop,
                                          INPUT INTE(v_pac),
                                          INPUT INTE(v_caixa),
                                          INPUT INTE(v_nrccdrcb),
                                          OUTPUT v_nmpesrcb,
                                          OUTPUT v_cpfcgrcb,
                                          OUTPUT v_inpesrcb,
                                          OUTPUT v_nridercb,
                                          OUTPUT v_dtnasrcb,
                                          OUTPUT v_desenrcb,
                                          OUTPUT v_nmcidrcb,
                                          OUTPUT v_cdufdrcb,
                                          OUTPUT v_nrceprcb,
                                          OUTPUT aux_focoerro).
               DELETE PROCEDURE h-bo-depos.
            END.                                          
            ELSE DO:
               RUN dbo/bo_controla_depositos.p PERSISTENT SET h-bo-depos.
               RUN valida-depositante-sacador
                          IN h-bo-depos (INPUT v_coop,
                                         INPUT INTE(v_pac),
                                         INPUT INTE(v_caixa),
                                         INPUT v_nmpesrcb,
                                         INPUT v_cpfcgrcb,
                                         INPUT "Fisica",
                                         INPUT v_nridercb,
                                         INPUT v_dtnasrcb,
                                         INPUT v_desenrcb,
                                         INPUT v_nmcidrcb,
                                         INPUT v_cdufdrcb,
                                         INPUT v_nrceprcb,
                                         OUTPUT aux_focoerro).
               DELETE PROCEDURE h-bo-depos.
            END.
                           
            IF RETURN-VALUE = 'NOK'   THEN
               DO:
                  ASSIGN l-houve-erro = YES
                         vh_foco      = aux_focoerro.
                  {include/i-erro.i}
               END.
               
            ELSE
            DO:
               IF v_recursos <> ''   THEN DO:
                  RUN dbo/bo_controla_depositos.p PERSISTENT SET h-bo-depos.
                  RUN valida-recurso IN h-bo-depos (INPUT v_coop,
                                                    INPUT INTE(v_pac),
                                                    INPUT INTE(v_caixa),
                                                    INPUT v_recursos, 
                                                    INPUT flinfdst).
                  DELETE PROCEDURE h-bo-depos.
               END.
               
               IF RETURN-VALUE = 'NOK'   THEN
                  DO:
                      ASSIGN l-houve-erro = YES
                             vh_foco      = '19'.
                      {include/i-erro.i}
                  END.
                    
               IF get-value('Ok') <> '' AND 
                  NOT l-houve-erro THEN 
                  DO:
                      RUN dbo/bo_controla_depositos.p 
                          PERSISTENT SET h-bo-depos.
                      RUN valida-recurso 
                                 IN h-bo-depos (INPUT v_coop,
                                                INPUT INTE(v_pac),
                                                INPUT INTE(v_caixa),
                                                INPUT v_recursos,
                                                INPUT flinfdst).

                      DELETE PROCEDURE h-bo-depos.
               
                      IF RETURN-VALUE = 'NOK'   THEN
                         DO:
                            ASSIGN l-houve-erro = YES
                                   vh_foco      = '19'.
                            {include/i-erro.i}
                         END. 
                     
                      IF   NOT l-houve-erro   THEN
                      DO:
                      DO TRANSACTION ON ERROR UNDO:
                          
                         ASSIGN l-houve-erro = NO.

                         IF v_programa = 'CRAP014' THEN
                            DO:
                         RUN dbo/bo_controla_depositos.p 
                                    PERSISTENT SET h-bo-depos.
                                RUN atualiza-crapcme-pagamento
                                            IN h-bo-depos(INPUT v_coop,
                                                          INPUT int(v_pac),
                                                          INPUT int(v_caixa),
                                                          INPUT v_operador,
                                                          INPUT v_vlmincen,
                                                          INPUT p-ult-sequencia,
                                                          INPUT INTE(v_nrccdrcb),
                                                          INPUT v_nmpesrcb,
                                                          INPUT v_cpfcgrcb,
                                                          INPUT "Fisica",
                                                          INPUT v_nridercb,
                                                          INPUT DATE(v_dtnasrcb),
                                                          INPUT v_desenrcb,
                                                          INPUT v_nmcidrcb,
                                                          INPUT v_cdufdrcb,
                                                          INPUT INTE(v_nrceprcb),
                                                          INPUT v_recursos,
                                                          INPUT "",
                                                          INPUT flinfdst,
                                                          INPUT v_tpdocmto).
                                                          
                                DELETE PROCEDURE h-bo-depos.

                                IF RETURN-VALUE = 'NOK' THEN
                                   DO:
                                     ASSIGN l-houve-erro = YES.
                                     FOR EACH w-craperr:
                                           DELETE w-craperr.
                                     END.
                                     
                                     FOR EACH craperr NO-LOCK WHERE
                                              craperr.cdcooper = crapcop.cdcooper AND
                                              craperr.cdagenci = INT(v_pac) AND
                                              craperr.nrdcaixa = INT(v_caixa):
                                        CREATE w-craperr.
                                        ASSIGN w-craperr.cdagenci = craperr.cdagenc
                                               w-craperr.nrdcaixa = craperr.nrdcaixa
                                               w-craperr.nrsequen = craperr.nrsequen
                                               w-craperr.cdcritic = craperr.cdcritic
                                               w-craperr.dscritic = craperr.dscritic
                                               w-craperr.erro = craperr.erro.
                                     END.
                                     UNDO.
                                   END.
                            END.
                        ELSE
                          DO:                                                                        
                             RUN dbo/bo_controla_depositos.p 
                             PERSISTENT SET h-bo-depos.
                         RUN atualiza-crapcme
                                   IN  h-bo-depos(INPUT v_coop,
                                                  INPUT int(v_pac),
                                                  INPUT int(v_caixa),
                                                  INPUT v_operador,
                                                  INPUT v_vlmincen,
                                                  INPUT p-ult-sequencia,
                                                  INPUT INTE(v_nrccdrcb),
                                                  INPUT v_nmpesrcb,
                                                  INPUT v_cpfcgrcb,
                                                  INPUT "Fisica",
                                                  INPUT v_nridercb,
                                                  INPUT DATE(v_dtnasrcb),
                                                  INPUT v_desenrcb,
                                                  INPUT v_nmcidrcb,
                                                  INPUT v_cdufdrcb,
                                                  INPUT INTE(v_nrceprcb),
                                                  INPUT v_recursos,
                                                  INPUT "", 
                                                  INPUT flinfdst).

                         DELETE PROCEDURE h-bo-depos.
                   
                             IF RETURN-VALUE = 'NOK' THEN
                                DO:
                                 ASSIGN l-houve-erro = YES.
                                 FOR EACH w-craperr:
                                     DELETE w-craperr.
                                 END.
                                 FOR EACH craperr NO-LOCK WHERE
                                          craperr.cdcooper = 
                                            crapcop.cdcooper  AND
                                          craperr.cdagenci =  
                                            INT(v_pac)        AND
                                          craperr.nrdcaixa =
                                            INT(v_caixa):
                                     CREATE w-craperr.
                                     ASSIGN w-craperr.cdagenci   = 
                                                      craperr.cdagenc
                                            w-craperr.nrdcaixa   =
                                                      craperr.nrdcaixa
                                            w-craperr.nrsequen   = 
                                                      craperr.nrsequen
                                            w-craperr.cdcritic   = 
                                                      craperr.cdcritic
                                            w-craperr.dscritic   = 
                                                      craperr.dscritic
                                            w-craperr.erro       = 
                                                      craperr.erro.
                                 END.
                                 UNDO.
                             END.
                          END.
                             IF  v_programa = "CRAP051" AND
                                 NOT l-houve-erro THEN
                                 DO:
                                     /* Forçar a verificação da tabela crapcme para garantirmos que o operador irá ter 
                                        digitado as informações */
                                     FOR EACH craplcm WHERE craplcm.cdcooper = crapcop.cdcooper   AND
                                                            craplcm.dtmvtolt = DATE(v_data)       AND
                                                            craplcm.cdagenci = inte(v_pac)        AND
                                                            craplcm.cdbccxlt = 11                 AND
                                                            craplcm.nrdolote = 11000 + inte(v_caixa) AND
                                                            craplcm.nrautdoc = p-ult-sequencia    AND
                                                            craplcm.cdhistor = 1 USE-INDEX craplcm3  NO-LOCK:

                                         ASSIGN aux_nrdctabb = craplcm.nrdctabb
                                                aux_nrdocmto = craplcm.nrdocmto.
                                     END. 
                                 
                                     FIND crapcme WHERE crapcme.cdcooper = crapcop.cdcooper   AND
                                                        crapcme.dtmvtolt = DATE(v_data)       AND
                                                        crapcme.cdagenci = inte(v_pac)        AND
                                                        crapcme.cdbccxlt = 11                 AND
                                                        crapcme.nrdolote = 11000 + inte(v_caixa)   AND
                                                        crapcme.nrdctabb = aux_nrdctabb        AND
                                                        crapcme.nrdocmto = aux_nrdocmto   
                                                        NO-LOCK NO-ERROR.
                                                             
                                     IF  NOT AVAILABLE crapcme   THEN
                                         DO:
                                             ASSIGN l-houve-erro = YES.
                                             FOR EACH w-craperr:
                                                 DELETE w-craperr.
                                             END.
                                         
                                             FIND FIRST w-craperr WHERE                                                  
                                                        w-craperr.cdagenci = INT(v_pac)        AND
                                                        w-craperr.nrdcaixa = INT(v_caixa) 
                                                        NO-LOCK NO-ERROR.
                                                        
                                             IF  NOT AVAILABLE w-craperr THEN
                                                 DO:
                                                     CREATE w-craperr.
                                                     ASSIGN w-craperr.cdagenci = INT(v_pac) 
                                                            w-craperr.nrdcaixa = INT(v_caixa)
                                                            w-craperr.nrsequen = p-ult-sequencia 
                                                            w-craperr.cdcritic = 0
                                                            w-craperr.dscritic = "Controle de movimentacao em especie inexistente.".
                                                 END.                                             
                                         END.
                                 END.
                      END. /*transaction*/
                      
                      /* Se clicou no OK */           
                      IF  get-value('ok') <> '' THEN                           
                          UNIX SILENT VALUE("echo " +  
                                            STRING(TIME,"HH:MM:SS") + "' --> '" +
                                            "ROTINA: " + CAPS(v_programa) +  "/CRAP051e"   +                                      
                                            " PA: " + STRING(v_pac)             +
                                            " CAIXA: " + STRING(v_caixa)        +
                                            " OPERADOR: " + STRING(v_operador)  +
                                            " CONTA DEPOSITANTE: " + STRING(INTE(v_nrccdrcb),"zzzz,zzz,9") +
                                            " NOME DEPOSITANTE: " + v_nmpesrcb  +
                                            " VALOR: " + STRING(v_valor)        + 
                                            " >> " + aux_nmarqlog).     
                      
                      IF l-houve-erro THEN
                         DO:
  
                           FOR EACH craperr WHERE 
                                    craperr.cdcooper = crapcop.cdcooper  AND
                                    craperr.cdagenci = INTE(v_pac)       AND
                                    craperr.nrdcaixa = INTE(v_caixa)
                                    EXCLUSIVE-LOCK:
                              DELETE craperr.
                           END.
                           FOR EACH w-craperr NO-LOCK:
                                 CREATE craperr.
                                 ASSIGN craperr.cdcooper =
                                                crapcop.cdcooper
                                        craperr.cdagenci = 
                                                w-craperr.cdagenc
                                        craperr.nrdcaixa   = 
                                                w-craperr.nrdcaixa
                                        craperr.nrsequen   = 
                                                w-craperr.nrsequen
                                        craperr.cdcritic   =
                                                w-craperr.cdcritic
                                        craperr.dscritic   = 
                                                w-craperr.dscritic
                                        craperr.erro       = 
                                                w-craperr.erro.
                                 VALIDATE craperr.
                             END.

                             {include/i-erro.i}
                         END.
                      ELSE
                         DO:
                             IF  v_programa = "CRAP051"   THEN
                                 DO:
                                     {&OUT}
                        '<script> window.location = "crap051.w" </script>'.  
                                 END.
                             ELSE
                             IF   v_programa = "CRAP057"   THEN
                                  DO:
                                     {&OUT}
                        '<script> window.location = "crap057.w" </script>'.  
                                  END.
                             ELSE
                             IF   v_programa = "CRAP055"   THEN
                                  DO:
                                     {&OUT}
                        '<script> window.location = "crap055.w" </script>'.  
                                  END.            
                             ELSE
                               IF v_programa = "CRAP014" THEN
                                 DO:
                                   {&OUT}
                                   '<script> window.location = "crap014.w" </script>'.
                         END.
                         END.
                       END. /* mAGUI ultimo */
                  END.
            END.        

        END.

        RUN displayFields.
        RUN enableFields.

        RUN outputFields.
       
   END. /* Form has been submitted. */
    /* REQUEST-METHOD = GET */ 
   ELSE DO:

        ASSIGN vh_foco = '9'.

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


