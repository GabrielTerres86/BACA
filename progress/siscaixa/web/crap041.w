/*..............................................................................

   Programa: siscaixa/web/crap041.w
   Sistema : Caixa On-Line
   Sigla   : CRED
   Autor   : 
   Data    :                                    Ultima atualizacao: 11/06/2015

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  :  Pagamento Guias DARF

   Alteracoes:  31/05/2013 - Impressão da autenticação de DARFs em
                             duas linhas (Lucas).
                             
                19/06/2013 - Tratamento para foco e validação de CPF/CNPJ de
                             acordo com o Tp de Tributo (Lucas).
                             
                11/06/2015 - Inclusão da validação de Boletim Fechado 
                            (Lunelli - SD. 295367)
                             
..............................................................................*/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW                             

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD opcao      AS CHARACTER FORMAT "X(256)":U 
       FIELD vh_foco    AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa    AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop     AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data     AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg      AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac      AS CHARACTER FORMAT "X(256)":U
       FIELD v_conta    AS CHARACTER FORMAT "X(256)":U 
       FIELD v_dtapurac AS CHARACTER FORMAT "X(256)":U
       FIELD v_nrcpfcgc AS CHARACTER FORMAT "X(256)":U
       FIELD v_cdtribut AS CHARACTER FORMAT "X(256)":U
       FIELD v_cdrefere AS CHARACTER FORMAT "X(256)":U
       FIELD v_dtlimite AS CHARACTER FORMAT "X(256)":U
       FIELD v_vlrecbru AS CHARACTER FORMAT "X(256)":U
       FIELD v_vlpercen AS CHARACTER FORMAT "X(256)":U
       FIELD v_vllanmto AS CHARACTER FORMAT "X(256)":U
       FIELD v_vlrmulta AS CHARACTER FORMAT "X(256)":U
       FIELD v_vlrjuros AS CHARACTER FORMAT "X(256)":U
       FIELD v_vlrtotal AS CHARACTER FORMAT "X(256)":U
       FIELD v_cod      AS CHARACTER FORMAT "X(256)":U
       FIELD v_senha    AS CHARACTER FORMAT "X(256)":U
       FIELD hdnEstorno    AS CHARACTER FORMAT "X(256)":U
       FIELD hdnVerifEstorno    AS CHARACTER FORMAT "X(256)":U
       FIELD hdnValorAcima AS CHARACTER FORMAT "X(256)":U.


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

DEFINE VARIABLE h_b1crap41   AS HANDLE     NO-UNDO.
DEFINE VARIABLE h-b1crap00   AS HANDLE     NO-UNDO.
DEF VAR p-literal            AS CHAR       NO-UNDO.
DEF VAR aux_foco             AS CHAR       NO-UNDO.
DEF VAR p-ult-sequencia      AS INTE       NO-UNDO.

DEFINE VARIABLE vr_cdcriticEstorno AS INTEGER NO-UNDO INIT 0.
DEFINE VARIABLE vr_cdcriticValorAcima AS INTEGER NO-UNDO INIT 0.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE F:/web/crap041.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.v_dtapurac ab_unmap.v_conta ab_unmap.v_nrcpfcgc ab_unmap.v_cdtribut ab_unmap.v_cdrefere ab_unmap.v_dtlimite ab_unmap.v_vlrecbru ab_unmap.v_vlpercen ab_unmap.v_vllanmto ab_unmap.v_vlrmulta ab_unmap.v_vlrjuros ab_unmap.v_vlrtotal ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.opcao ab_unmap.v_coop ab_unmap.v_data  ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_cod ab_unmap.v_senha ab_unmap.hdnEstorno ab_unmap.hdnVerifEstorno ab_unmap.hdnValorAcima
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.v_dtapurac ab_unmap.v_conta ab_unmap.v_nrcpfcgc ab_unmap.v_cdtribut ab_unmap.v_cdrefere ab_unmap.v_dtlimite ab_unmap.v_vlrecbru ab_unmap.v_vlpercen ab_unmap.v_vllanmto ab_unmap.v_vlrmulta ab_unmap.v_vlrjuros ab_unmap.v_vlrtotal ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.opcao ab_unmap.v_coop ab_unmap.v_data  ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_cod ab_unmap.v_senha ab_unmap.hdnEstorno ab_unmap.hdnVerifEstorno ab_unmap.hdnValorAcima

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.v_dtapurac AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_conta AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_nrcpfcgc AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_cdtribut AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_cdrefere AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_dtlimite AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_vlrecbru AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_vlpercen AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_vllanmto AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_vlrmulta AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_vlrjuros AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_vlrtotal AT ROW 1 COL 1 HELP
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
    ab_unmap.opcao AT ROW 1 COL 1 HELP
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
    ab_unmap.v_cod AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_senha AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.hdnEstorno AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN
          SIZE 20 BY 1 
     ab_unmap.hdnVerifEstorno AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN
          SIZE 20 BY 1 
     ab_unmap.hdnValorAcima AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN
          SIZE 20 BY 1      
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 80 BY 20.


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
            FIELD dtapurac AS CHARACTER FORMAT "X(256)":U
            FIELD nrcpfcgc AS CHARACTER FORMAT "X(256)":U
            FIELD cdtribut AS CHARACTER FORMAT "X(256)":U
            FIELD cdrefere AS CHARACTER FORMAT "X(256)":U
            FIELD dtlimite AS CHARACTER FORMAT "X(256)":U
            FIELD vlrecbru AS CHARACTER FORMAT "X(256)":U
            FIELD vlpercen AS CHARACTER FORMAT "X(256)":U
            FIELD vllanmto AS CHARACTER FORMAT "X(256)":U
            FIELD vlrmulta AS CHARACTER FORMAT "X(256)":U
            FIELD vlrjuros AS CHARACTER FORMAT "X(256)":U
            FIELD vlrtotal AS CHARACTER FORMAT "X(256)":U.
	        FIELD vh_foco    AS CHARACTER FORMAT "X(256)":U 
            FIELD v_caixa    AS CHARACTER FORMAT "X(256)":U 
            FIELD v_conta    AS CHARACTER FORMAT "X(256)":U 
            FIELD v_coop     AS CHARACTER FORMAT "X(256)":U 
            FIELD v_data     AS CHARACTER FORMAT "X(256)":U 
            FIELD v_msg      AS CHARACTER FORMAT "X(256)":U 
            FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
            FIELD v_pac      AS CHARACTER FORMAT "X(256)":U 
            FIELD v_cod      AS CHARACTER FORMAT "X(256)":U 
            FIELD v_senha      AS CHARACTER FORMAT "X(256)":U
            FIELD hdnEstorno AS CHARACTER FORMAT "X(256)":U
            FIELD hdnVerifEstorno AS CHARACTER FORMAT "X(256)":U
            FIELD hdnValorAcima AS CHARACTER FORMAT "X(256)":U
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 14.14
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
/* SETTINGS FOR fill-in ab_unmap.ok IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.vh_foco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_ano IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_caixa IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_codigo IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_conta IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_identificador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_v_nrcpfcgc IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */   
/* SETTINGS FOR fill-in ab_unmap.v_mes IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_nome IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_valorins IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_valorjur IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_valorout IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_valortot IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_cod IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_senha IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.hdnEstorno IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.hdnVerifEstorno IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.hdnValorAcima IN FRAME Web-Frame
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
    ("v_dtapurac":U,"ab_unmap.v_dtapurac":U,ab_unmap.v_dtapurac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nrcpfcgc":U,"ab_unmap.v_nrcpfcgc":U,ab_unmap.v_nrcpfcgc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cdtribut":U,"ab_unmap.v_cdtribut":U,ab_unmap.v_cdtribut:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cdrefere":U,"ab_unmap.v_cdrefere":U,ab_unmap.v_cdrefere:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_dtlimite":U,"ab_unmap.v_dtlimite":U,ab_unmap.v_dtlimite:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_vlrecbru":U,"ab_unmap.v_vlrecbru":U,ab_unmap.v_vlrecbru:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_vlpercen":U,"ab_unmap.v_vlpercen":U,ab_unmap.v_vlpercen:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_vllanmto":U,"ab_unmap.v_vllanmto":U,ab_unmap.v_vllanmto:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_vlrmulta":U,"ab_unmap.v_vlrmulta":U,ab_unmap.v_vlrmulta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_vlrjuros":U,"ab_unmap.v_vlrjuros":U,ab_unmap.v_vlrjuros:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_vlrtotal":U,"ab_unmap.v_vlrtotal":U,ab_unmap.v_vlrtotal:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("vh_foco":U,"ab_unmap.vh_foco":U,ab_unmap.vh_foco:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_caixa":U,"ab_unmap.v_caixa":U,ab_unmap.v_caixa:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("opcao":U,"ab_unmap.opcao":U,ab_unmap.opcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_conta":U,"ab_unmap.v_conta":U,ab_unmap.v_conta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cod":U,"ab_unmap.v_cod":U,ab_unmap.v_cod:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_senha":U,"ab_unmap.v_senha":U,ab_unmap.v_senha:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("hdnEstorno":U,"ab_unmap.hdnEstorno":U,ab_unmap.hdnEstorno:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("hdnVerifEstorno":U,"ab_unmap.hdnVerifEstorno":U,ab_unmap.hdnVerifEstorno:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("hdnValorAcima":U,"ab_unmap.hdnValorAcima":U,ab_unmap.hdnValorAcima:HANDLE IN FRAME {&FRAME-NAME}).
  
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
  
  DEFINE VARIABLE aux_inssenha      AS INTEGER        NO-UNDO.
  DEFINE VARIABLE aux_des_erro      AS CHARACTER      NO-UNDO.
  DEFINE VARIABLE aux_dscritic      AS CHARACTER      NO-UNDO.
  DEF VAR         hdnEstorno        AS  CHAR          NO-UNDO.
  DEF VAR         hdnVerifEstorno   AS  CHAR          NO-UNDO.
  DEF VAR         hdnValorAcima     AS  CHAR          NO-UNDO.
  
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

  {include/i-global.i}

  ASSIGN ab_unmap.hdnVerifEstorno = get-value("hdnVerifEstorno ").

  /* Describe whether to receive FORM input for all the fields.  For example,
   * check particular input fields (using GetField in web-utilities-hdl). 
   * Here we look at REQUEST_METHOD. 
   */
    
    IF REQUEST_METHOD = "POST":U THEN DO:
    /* STEP 1 -
     * Copy HTML input field values to the Progress form buffer. */
    
    RUN inputFields.
    
    /* STEP 2 -
     * Open the database or SDO query and and fetch the first record. */ 
    RUN findRecords.
    
    /* STEP 3 -    
     * AssignFields will save the data in the frame.
     * (it automatically upgrades the lock to exclusive while doing the update)
     * 
     *  If a new record needs to be created set AddMode to true before 
        running assignFields.  
     *     setAddMode(TRUE).   
     * RUN assignFields. */
    
     {include/assignfields.i} 

    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
    RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                       INPUT v_pac,
                                       INPUT v_caixa).
    DELETE PROCEDURE h-b1crap00.
    
    IF RETURN-VALUE = "NOK" THEN DO:
       {include/i-erro.i}
    END.
    ELSE  DO:
        RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
        RUN verifica-abertura-boletim IN h-b1crap00(INPUT v_coop,
                                                    INPUT v_pac,
                                                    INPUT v_caixa,
                                                    INPUT v_operador).
        DELETE PROCEDURE h-b1crap00.

        IF RETURN-VALUE = "NOK" THEN DO:
            {include/i-erro.i}
        END.
        ELSE DO:
            IF  ab_unmap.opcao <> "" THEN
                DO:
                    IF  ab_unmap.opcao = "cpfcnpj"  THEN
                        DO:
                            ASSIGN opcao       = "".
                            RUN dbo/b1crap41.p PERSISTENT SET h_b1crap41.
                    
                            /* Valida se CPF ou CNPJ inseridos correspondem ao Cod. do Tributo */
                            RUN valida-cpfcnpj-cdtrib IN h_b1crap41 (INPUT STRING(ab_unmap.v_coop),
                                                                     INPUT INTE(ab_unmap.v_pac),
                                                                     INPUT INTE(ab_unmap.v_caixa),
                                                                     INPUT STRING(ab_unmap.v_cdtribut),
                                                                     INPUT STRING(ab_unmap.v_nrcpfcgc),
                                                                    OUTPUT aux_foco).
        
                            IF  VALID-HANDLE(h_b1crap41) THEN
                                DELETE PROCEDURE h_b1crap41.
                           
                            IF  RETURN-VALUE = "NOK" THEN
                                DO: 
                                  {include/i-erro.i}
                                   ASSIGN vh_foco = aux_foco.
                                END.
                            ELSE
                                ASSIGN vh_foco = "12".
                        END.
                    ELSE
                        DO:
                            IF  ab_unmap.opcao = "v_vllanmto" THEN
                                ASSIGN vh_foco = "15".
                            
                            IF  ab_unmap.opcao = "v_vlrmulta" THEN
                                ASSIGN vh_foco = "16".
                            
                            IF  ab_unmap.opcao = "v_vlrjuros" THEN
                                ASSIGN vh_foco = "17".
                            
                            ASSIGN v_dtapurac  = ab_unmap.v_dtapurac
                                   v_conta     = ab_unmap.v_conta
                                   opcao       = ""
                                   v_nrcpfcgc  = ab_unmap.v_nrcpfcgc
                                   v_cdtribut  = ab_unmap.v_cdtribut
                                   v_cdrefere  = ab_unmap.v_cdrefere
                                   v_dtlimite  = ab_unmap.v_dtlimite
                                   v_vlrecbru  = ab_unmap.v_vlrecbru
                                   v_vlpercen  = ab_unmap.v_vlpercen
                                   v_vllanmto  = ab_unmap.v_vllanmto
                                   v_vlrmulta  = ab_unmap.v_vlrmulta
                                   v_vlrjuros  = ab_unmap.v_vlrjuros
                                   v_vlrtotal  = STRING(DECI(ab_unmap.v_vllanmto) + DECI(ab_unmap.v_vlrmulta) + DECI(ab_unmap.v_vlrjuros), "zzz,zzz,zzz,zz9.99").
                        END.
                END.
            ELSE
            IF  GET-VALUE("cancela") <> "" THEN
                ASSIGN v_dtapurac  = ""
                       v_conta     = ""
                       v_nrcpfcgc  = ""
                       v_cdtribut  = ""
                       v_cdrefere  = ""
                       v_dtlimite  = ""
                       v_vlrecbru  = ""
                       v_vlpercen  = ""
                       v_vllanmto  = ""
                       v_vlrmulta  = ""
                       v_vlrjuros  = ""
                       v_vlrtotal  = ""
                       opcao       = ""
                       vh_foco     = "9".
             ELSE
                DO:
                     ASSIGN opcao    = ""
                            aux_foco = "".
        
                     RUN dbo/b1crap41.p PERSISTENT SET h_b1crap41.
                    
                     /* Valida dados do recebimento da DARF antes do pagamento */
                     RUN valida-pagamento-darf IN h_b1crap41 (INPUT STRING(ab_unmap.v_coop),
                                                              INPUT INTE(ab_unmap.v_pac),
                                                              INPUT INTE(ab_unmap.v_caixa),
                                                              INPUT STRING(ab_unmap.v_cdtribut),
                                                              INPUT STRING(ab_unmap.v_nrcpfcgc),
                                                              INPUT STRING(ab_unmap.v_dtapurac),
                                                              INPUT STRING(ab_unmap.v_dtlimite),
                                                              INPUT STRING(ab_unmap.v_cdrefere),
                                                              INPUT DECI(ab_unmap.v_vlrecbru),
                                                              INPUT DECI(ab_unmap.v_vlpercen),
                                                              INPUT DECI(ab_unmap.v_vllanmto),
                                                              INPUT DECI(ab_unmap.v_vlrmulta),
                                                              INPUT DECI(ab_unmap.v_vlrjuros),
                                                              OUTPUT aux_foco).

                     IF  VALID-HANDLE(h_b1crap41) THEN
                         DELETE PROCEDURE h_b1crap41.

                     IF  RETURN-VALUE = "NOK" THEN
                         DO: 
                           {include/i-erro.i}
                           ASSIGN vh_foco = aux_foco.
                         END.
                     ELSE
                        DO:

                           RUN validar-valor-limite (INPUT STRING(ab_unmap.v_coop),
                                                     INPUT STRING(ab_unmap.v_cod),
                                                     INPUT INTE(ab_unmap.v_pac),
                                                     INPUT INTE(ab_unmap.v_caixa),
                                                     INPUT (DECI(ab_unmap.v_vllanmto) + DECI(ab_unmap.v_vlrmulta)+ DECI(ab_unmap.v_vlrjuros)),
                                                     INPUT STRING(ab_unmap.v_senha),
                                                     OUTPUT aux_des_erro,
                                                     OUTPUT aux_dscritic,
                                                     OUTPUT aux_inssenha).
                           IF RETURN-VALUE = 'NOK' THEN  
                            DO:
                               ASSIGN ab_unmap.vh_foco = "10".
                               {include/i-erro.i}
                            END.
                           ELSE
                             DO:                           
                           RUN dbo/b1crap41.p PERSISTENT SET h_b1crap41.
                           RUN paga-darf IN h_b1crap41 (INPUT STRING(ab_unmap.v_coop),
                                                        INPUT INTE(ab_unmap.v_conta),
                                                        INPUT 0,
                                                        INPUT INTE(ab_unmap.v_pac),
                                                        INPUT INTE(ab_unmap.v_caixa),
                                                        INPUT ab_unmap.v_operador,
                                                        INPUT DATE(ab_unmap.v_dtapurac),
                                                        INPUT STRING(ab_unmap.v_nrcpfcgc),
                                                        INPUT STRING(ab_unmap.v_cdtribut),
                                                        INPUT STRING(ab_unmap.v_cdrefere),
                                                        INPUT DATE(ab_unmap.v_dtlimite),
                                                        INPUT DECI(ab_unmap.v_vlrecbru),
                                                        INPUT DECI(ab_unmap.v_vlpercen),
                                                        INPUT DECI(ab_unmap.v_vllanmto),
                                                        INPUT DECI(ab_unmap.v_vlrmulta),
                                                        INPUT DECI(ab_unmap.v_vlrjuros),
                                                       OUTPUT aux_foco,
                                                       OUTPUT p-literal,
                                                       OUTPUT p-ult-sequencia).

                           IF  VALID-HANDLE(h_b1crap41) THEN
                               DELETE PROCEDURE h_b1crap41.
                           
                           IF  RETURN-VALUE = "NOK" THEN
                               DO: 
                                 {include/i-erro.i}
                                 ASSIGN vh_foco = aux_foco.
                               END.
                           ELSE
                               DO:
                                   IF  LENGTH(p-literal) > 120 THEN
                                       DO:
                                           {&OUT}
                                           '<script>window.open("autentica.html?v_plit=" + "' p-literal '" + 
                                             "&v_pseq=" + "' p-ult-sequencia '" + "&v_prec=" + "YES"  +
                                             "&v_psetcook=" +         "yes","waut","width=250,height=145,scrollbars=auto,alwaysRaised=true")
                                            </script>'.
                                       END.
                                   ELSE
                                       DO:
                                           IF  SUBSTRING(p-literal, 1, 8) = "BCS00089" THEN
                                               DO:
                                                   {&OUT}
                                                   '<script>window.open("autentica.html?v_plit=" + "' p-literal '" + 
                                                     "&v_pseq=" + "' p-ult-sequencia '" + "&v_prec=" + "NO3" + "&vias=" + "1"  + 
                                                     "&v_psetcook=" +         "YES","_blank","width=250,height=145,scrollbars=auto,alwaysRaised=true")
                                                   </script>'.
                                               END.
                                       END.
                                   
                                       {&OUT}
                                       '<script> window.location = "crap041.html" </script>'.
        
                               END.
                            END. /* ELSE RUN validar-valor-limite  */
                        END.                                         
                END.
        END. /* RETURN "OK" verifica-abertura-boletim FIM */
    END. /* RETURN "OK" valida-transacao FIM */

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

    IF vr_cdcriticEstorno = 1 AND INT(ab_unmap.hdnVerifEstorno) = 0 THEN
      DO:
        {&out} '<script>var conf = confirm("ATENCAO, este pagamento nao pode ser estornado, deseja continuar?");</script>'.
        {&out} '<script>((!conf) ? $("#hdnVerifEstorno").val(0) : $("#hdnVerifEstorno").val(1))</script>'.
        {&out} '<script>((!conf) ? window.location = "crap041.html" : document.forms[0].submit())</script>'.
      END.     
       
     IF vr_cdcriticValorAcima = 1 THEN
       {&out} '<script>$("#hdnValorAcima").val(1);</script>'.
     ELSE
       {&out} '<script>$("#hdnValorAcima").val(0);</script>'.       
     
     {&out} '<script>habilitarCampos();</script>'.

  END. /* Form has been submitted. */
 
  /* REQUEST-METHOD = GET */ 
  ELSE DO:

    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
    RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                       INPUT v_pac,
                                       INPUT v_caixa).
    DELETE PROCEDURE h-b1crap00.
    
    IF RETURN-VALUE = "NOK" THEN DO:
       {include/i-erro.i}
    END.
    ELSE DO:

        RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
        RUN verifica-abertura-boletim IN h-b1crap00(INPUT v_coop,
                                                    INPUT v_pac,
                                                    INPUT v_caixa,
                                                    INPUT v_operador).
        DELETE PROCEDURE h-b1crap00.

        IF RETURN-VALUE = "NOK" THEN DO:
            {include/i-erro.i}
        END.
        ELSE DO:

             ASSIGN vh_foco = "8".
        
             IF GET-VALUE("v_aviso") <> "" THEN
                DO:       
                   RUN dbo/b1crap41.p PERSISTENT SET h_b1crap41.
        
                   RUN msg-inicial IN h_b1crap41 (INPUT STRING(ab_unmap.v_coop),
                                                  INPUT INTE(ab_unmap.v_pac), 
                                                  INPUT INTE(ab_unmap.v_caixa)).
        
                   IF  VALID-HANDLE(h_b1crap41) THEN
                       DELETE PROCEDURE h_b1crap41.
                   
                   IF  RETURN-VALUE = "MAX" THEN
                       DO:
                           {include/i-erro.i}
                   
                           {&OUT}
                                '<script> window.location = "crap041.html" </script>'.
                       
                       END.          
                END.
        END.
    END.

    /* This is the first time that the form has been called. Just return the
     * form.  Move 'RUN outputHeader.' here if you are going to simulate
     * another Web request. */ 
   
    /* STEP 1 -
     * Open the database or SDO query and and fetch the first record. */ 
    RUN findRecords.
    
            
    /* ASSIGN vh_foco  = "7". */

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
    
    IF vr_cdcriticEstorno = 1 AND INT(ab_unmap.hdnVerifEstorno) = 0 THEN
      DO:
        {&out} '<script>var conf = confirm("ATENCAO, este pagamento nao pode ser estornado, deseja continuar?");</script>'.
        {&out} '<script>((!conf) ? $("#hdnVerifEstorno").val(0) : $("#hdnVerifEstorno").val(1))</script>'.
        {&out} '<script>((!conf) ? window.location = "crap041.html" : document.forms[0].submit())</script>'.
      END.
    
    IF vr_cdcriticValorAcima = 1 THEN
       DO:
         {&out} '<script>$("#hdnValorAcima").val(1);</script>'.
       END.
     ELSE
       DO:
         {&out} '<script>$("#hdnValorAcima").val(0);</script>'.
  END. 
  
     {&out} '<script>habilitarCampos();</script>'.
    
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validar-valor-limite w-html 

/* valida o valor recebido como parâmetro com o limite da agencia / cooperativa e solicita senha do coordenador se for maior */
PROCEDURE validar-valor-limite:

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
    DEF VAR h_b1crap41            AS HANDLE                          NO-UNDO.
    
    RUN dbo/b1crap41.p PERSISTENT SET h_b1crap41.
                           
    RUN validar-valor-limite IN h_b1crap41(INPUT par_nmrescop,
                                           INPUT par_cdoperad,
                                           INPUT par_cdagenci,
                                           INPUT par_nrocaixa,
                                           INPUT par_vltitfat,
                                           INPUT par_senha,
                                           OUTPUT par_des_erro,
                                           OUTPUT par_dscritic,
                                           OUTPUT par_inssenha).
                                          
    DELETE PROCEDURE h_b1crap41.
    
    IF RETURN-VALUE = 'NOK' THEN  
     DO:
        
        ASSIGN vr_cdcriticValorAcima = 1.
     
        RETURN "NOK".
     END.
        
     ASSIGN vr_cdcriticValorAcima = 0.

     /* Solicita confirmaçao operacao depois de inserida a senha DO coordenador, mas apenas para os pagamentos que nao podem ser estornados */
     IF par_inssenha > 0 THEN
       DO:
         IF INT(ab_unmap.hdnVerifEstorno) = 1 THEN
          DO:
            RETURN "OK".
          END.
         ELSE
           DO:
             ASSIGN vr_cdcriticEstorno = 1.
             RETURN "NOK".
           END.         
       END.
        
    RETURN "OK".
END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME