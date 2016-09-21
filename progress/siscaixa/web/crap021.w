/*.............................................................................

   Programa: siscaixa/web/crap021.w
   Sistema : Caixa On-Line
   Sigla   : CRED
                                                Ultima atualizacao: 13/12/2013

   Dados referentes ao programa:

   Frequencia:  Diario (on-line)
   Objetivo  :  Estorno DOC/TED 

  
    Alteracoes:  14/12/2009 - Criado radio com TED C e TED D. Ajustado
                              fonte para tratar os TEDS - SPB (Fernando).
                              
                 29/03/2011 - Inclusao parametros para validadcao do valor/senha
                              do operador (Guilherme).
                 
                 13/12/2013 - Alteracao referente a integracao Progress X 
                              Dataserver Oracle 
                              Inclusao do VALIDATE ( Andre Euzebio / SUPERO)              
-----------------------------------------------------------------------------*/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD R1 AS CHARACTER
       FIELD RP AS CHARACTER 
       FIELD RP1 AS CHARACTER 
       FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
       FIELD v_agencia AS CHARACTER FORMAT "X(256)":U 
       FIELD v_banco AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_ccred AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cpfcgcde AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cpfcgcde1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data AS CHARACTER FORMAT "X(256)":U 
       FIELD v_deschistorico AS CHARACTER FORMAT "X(256)":U 
       FIELD v_descricaocontacredito AS CHARACTER FORMAT "X(256)":U 
       FIELD v_descricaocontadebito AS CHARACTER FORMAT "X(256)":U 
       FIELD v_descricaofinalidade AS CHARACTER FORMAT "X(256)":U 
       FIELD v_doc AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nomeagencia AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nomebanco AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nomede AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nomede1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nomepara AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nrocontade AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nrocontapara AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
       FIELD v_paracpfcgc AS CHARACTER FORMAT "X(256)":U 
       FIELD v_paracpfcgc1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_paranome1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_tipocontacredito AS CHARACTER FORMAT "X(256)":U 
       FIELD v_tipocontadebito AS CHARACTER FORMAT "X(256)":U 
       FIELD v_valordocumento AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cod AS CHARACTER FORMAT "X(256)":U 
       FIELD v_senha AS CHARACTER FORMAT "X(256)":U.


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


DEF VAR i-tipo-doc    AS INTE NO-UNDO.
DEF VAR l-titular     AS LOG  NO-UNDO.
DEF VAR p-histor      AS INTE NO-UNDO.
DEF VAR p-histor-lcm  AS INTE NO-UNDO.
DEF VAR p-val-doc-lcm AS DECI NO-UNDO.
DEF VAR p-literal     AS CHAR           NO-UNDO.
DEF VAR p-literal-lcm AS CHAR           NO-UNDO.
DEF VAR p-ult-sequencia     AS INTE         NO-UNDO.
DEF VAR p-ult-sequencia-lcm AS INTE         NO-UNDO.
DEF VAR p-registro          AS RECID        NO-UNDO.

DEF VAR h-b1crap21 AS HANDLE            NO-UNDO.
DEF VAR h-b1crap20 AS HANDLE            NO-UNDO.
DEF VAR h-b1crap00 AS HANDLE            NO-UNDO.

DEF VAR l-houve-erro    AS LOG          NO-UNDO.

DEF TEMP-TABLE w-craperr  NO-UNDO
     FIELD cdagenci   LIKE craperr.cdagenc
     FIELD nrdcaixa   LIKE craperr.nrdcaixa
     FIELD nrsequen   LIKE craperr.nrsequen
     FIELD cdcritic   LIKE craperr.cdcritic
     FIELD dscritic   LIKE craperr.dscritic
     FIELD erro       LIKE craperr.erro.
DEF VAR p-pessoa-de AS INTE NO-UNDO.
DEF VAR p-pessoa-para AS INTE NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE crap021.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.v_paranome1 ab_unmap.RP ab_unmap.RP1 ab_unmap.v_cpfcgcde1 ab_unmap.v_nomede1 ab_unmap.v_paracpfcgc ab_unmap.v_paracpfcgc1 ab_unmap.v_doc ab_unmap.R1 ab_unmap.vh_foco ab_unmap.v_agencia ab_unmap.v_banco ab_unmap.v_caixa ab_unmap.v_ccred ab_unmap.v_coop ab_unmap.v_cpfcgcde ab_unmap.v_data ab_unmap.v_deschistorico ab_unmap.v_descricaocontacredito ab_unmap.v_descricaocontadebito ab_unmap.v_descricaofinalidade ab_unmap.v_msg ab_unmap.v_nomeagencia ab_unmap.v_nomebanco ab_unmap.v_nomede ab_unmap.v_nomepara ab_unmap.v_nrocontade ab_unmap.v_nrocontapara ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_tipocontacredito ab_unmap.v_tipocontadebito ab_unmap.v_valordocumento ab_unmap.v_cod ab_unmap.v_senha
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.v_paranome1 ab_unmap.RP ab_unmap.RP1 ab_unmap.v_cpfcgcde1 ab_unmap.v_nomede1 ab_unmap.v_paracpfcgc ab_unmap.v_paracpfcgc1 ab_unmap.v_doc ab_unmap.R1 ab_unmap.vh_foco ab_unmap.v_agencia ab_unmap.v_banco ab_unmap.v_caixa ab_unmap.v_ccred ab_unmap.v_coop ab_unmap.v_cpfcgcde ab_unmap.v_data ab_unmap.v_deschistorico ab_unmap.v_descricaocontacredito ab_unmap.v_descricaocontadebito ab_unmap.v_descricaofinalidade ab_unmap.v_msg ab_unmap.v_nomeagencia ab_unmap.v_nomebanco ab_unmap.v_nomede ab_unmap.v_nomepara ab_unmap.v_nrocontade ab_unmap.v_nrocontapara ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_tipocontacredito ab_unmap.v_tipocontadebito ab_unmap.v_valordocumento ab_unmap.v_cod ab_unmap.v_senha 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.v_paranome1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.RP AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
          "RP 1", "v1":U,
          "RP 2", "v2":U
          SIZE 20 BY 3
     ab_unmap.RP1 AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
          "RP1 1", "v1":U,
          "RP1 2", "v2":U
          SIZE 20 BY 3
     ab_unmap.v_cpfcgcde1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nomede1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_paracpfcgc AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_paracpfcgc1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_doc AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.R1 AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
          "R1 1", "v1":U,
          "R1 2", "v2":U,
          "R1 3", "v3":U,
          "R1 4", "v4":U
          SIZE 20 BY 5
     ab_unmap.vh_foco AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_agencia AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_banco AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_caixa AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_ccred AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_coop AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cpfcgcde AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_data AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_deschistorico AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_descricaocontacredito AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_descricaocontadebito AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 60.6 BY 14.14.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Web-Frame
     ab_unmap.v_msg AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nomeagencia AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nomebanco AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nomede AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nomepara AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nrocontade AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nrocontapara AT ROW 1 COL 1 HELP
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
     ab_unmap.v_tipocontacredito AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_tipocontadebito AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_valordocumento AT ROW 1 COL 1 HELP
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
    ab_unmap.v_descricaofinalidade AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 60.6 BY 14.14.


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
          FIELD R1 AS CHARACTER 
          FIELD rad1 AS CHARACTER 
          FIELD RP AS CHARACTER 
          FIELD RP1 AS CHARACTER 
          FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
          FIELD v_agencia AS CHARACTER FORMAT "X(256)":U 
          FIELD v_banco AS CHARACTER FORMAT "X(256)":U 
          FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
          FIELD v_ccred AS CHARACTER FORMAT "X(256)":U 
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cpfcgcde AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cpfcgcde1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_deschistorico AS CHARACTER FORMAT "X(256)":U 
          FIELD v_descricaocontacredito AS CHARACTER FORMAT "X(256)":U 
          FIELD v_descricaocontadebito AS CHARACTER FORMAT "X(256)":U 
          FIELD v_descricaofinalidade AS CHARACTER FORMAT "X(256)":U 
          FIELD v_doc AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nomeagencia AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nomebanco AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nomede AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nomede1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nomepara AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nrocontade AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nrocontapara AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD v_paracpfcgc AS CHARACTER FORMAT "X(256)":U 
          FIELD v_paracpfcgc1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_paranome1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_tipocontacredito AS CHARACTER FORMAT "X(256)":U 
          FIELD v_tipocontadebito AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valordocumento AS CHARACTER FORMAT "X(256)":U 
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
/* SETTINGS FOR RADIO-SET ab_unmap.R1 IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR RADIO-SET ab_unmap.rad1 IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR RADIO-SET ab_unmap.RP IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR RADIO-SET ab_unmap.RP1 IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.vh_foco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_agencia IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_banco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_caixa IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_ccred IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cpfcgcde IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cpfcgcde1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_deschistorico IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_descricaocontacredito IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_descricaocontadebito IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_descricaofinalidade IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_doc IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nomeagencia IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nomebanco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nomede IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nomede1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nomepara IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nrocontade IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nrocontapara IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_paracpfcgc IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_paracpfcgc1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_paranome1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_tipocontacredito IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_tipocontadebito IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_valordocumento IN FRAME Web-Frame
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
    ("R1":U,"ab_unmap.R1":U,ab_unmap.R1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("RP":U,"ab_unmap.RP":U,ab_unmap.RP:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("RP1":U,"ab_unmap.RP1":U,ab_unmap.RP1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("vh_foco":U,"ab_unmap.vh_foco":U,ab_unmap.vh_foco:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_agencia":U,"ab_unmap.v_agencia":U,ab_unmap.v_agencia:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_banco":U,"ab_unmap.v_banco":U,ab_unmap.v_banco:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_caixa":U,"ab_unmap.v_caixa":U,ab_unmap.v_caixa:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_ccred":U,"ab_unmap.v_ccred":U,ab_unmap.v_ccred:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cpfcgcde":U,"ab_unmap.v_cpfcgcde":U,ab_unmap.v_cpfcgcde:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cpfcgcde1":U,"ab_unmap.v_cpfcgcde1":U,ab_unmap.v_cpfcgcde1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_deschistorico":U,"ab_unmap.v_deschistorico":U,ab_unmap.v_deschistorico:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_descricaocontacredito":U,"ab_unmap.v_descricaocontacredito":U,ab_unmap.v_descricaocontacredito:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_descricaocontadebito":U,"ab_unmap.v_descricaocontadebito":U,ab_unmap.v_descricaocontadebito:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_descricaofinalidade":U,"ab_unmap.v_descricaofinalidade":U,ab_unmap.v_descricaofinalidade:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_doc":U,"ab_unmap.v_doc":U,ab_unmap.v_doc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nomeagencia":U,"ab_unmap.v_nomeagencia":U,ab_unmap.v_nomeagencia:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nomebanco":U,"ab_unmap.v_nomebanco":U,ab_unmap.v_nomebanco:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nomede":U,"ab_unmap.v_nomede":U,ab_unmap.v_nomede:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nomede1":U,"ab_unmap.v_nomede1":U,ab_unmap.v_nomede1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nomepara":U,"ab_unmap.v_nomepara":U,ab_unmap.v_nomepara:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nrocontade":U,"ab_unmap.v_nrocontade":U,ab_unmap.v_nrocontade:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nrocontapara":U,"ab_unmap.v_nrocontapara":U,ab_unmap.v_nrocontapara:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_paracpfcgc":U,"ab_unmap.v_paracpfcgc":U,ab_unmap.v_paracpfcgc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_paracpfcgc1":U,"ab_unmap.v_paracpfcgc1":U,ab_unmap.v_paracpfcgc1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_paranome1":U,"ab_unmap.v_paranome1":U,ab_unmap.v_paranome1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_tipocontacredito":U,"ab_unmap.v_tipocontacredito":U,ab_unmap.v_tipocontacredito:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_tipocontadebito":U,"ab_unmap.v_tipocontadebito":U,ab_unmap.v_tipocontadebito:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_valordocumento":U,"ab_unmap.v_valordocumento":U,ab_unmap.v_valordocumento:HANDLE IN FRAME {&FRAME-NAME}).
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
    RUN findRecords.*/
    
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
     IF  get-value("cancela") <> "" THEN DO:
            ASSIGN R1               = "v1"
                   v_doc            = " "
                   v_valordocumento = ""
                   v_nrocontade     = ""
                   v_nomede         = ""
                   v_nomede1        = ""
                   v_nomepara       = " "
                   v_paranome1      = " "
                   v_cpfcgcde       = ""
                   v_cpfcgcde1      = ""
                   v_banco          = ""
                   v_nomebanco      = ""
                   v_agencia        = ""
                   v_nomeagencia    = ""
                   v_nrocontapara   = ""
                   v_paracpfcgc     = ""
                   v_paracpfcgc1    = ""
                   v_ccred          = ""
                   v_descricaofinalidade   = ""
                   v_tipocontadebito       = ""
                   v_descricaocontadebito  = ""
                   v_tipocontacredito      = ""
                   v_descricaocontacredito = ""
                   v_deschistorico         = "".
     END.
     ELSE DO:
       
       RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                          INPUT v_pac,
                                          INPUT v_caixa).
       IF  RETURN-VALUE = "OK"  THEN DO:
          
           RUN  verifica-abertura-boletim IN h-b1crap00 (INPUT v_coop,
                                                         INPUT v_pac,
                                                         INPUT v_caixa,
                                                         INPUT v_operador).
       END.

       IF  RETURN-VALUE = "NOK" THEN DO:
           {include/i-erro.i}
       END.
       ELSE DO:
         
          IF get-value("R1") = "v1" THEN
             ASSIGN i-tipo-doc = 1.
          ELSE IF get-value("R1") = "v2" THEN
                  ASSIGN i-tipo-doc = 2.
               ELSE 
                   ASSIGN i-tipo-doc = 3.
           
          RUN dbo/b1crap21.p PERSISTENT SET h-b1crap21.
            
          RUN critica-retorna-valores
              IN  h-b1crap21(INPUT v_coop,
                             INPUT v_pac,
                             INPUT v_caixa,
                             INPUT i-tipo-doc,
                             INPUT v_doc,
                             OUTPUT l-titular,
                             OUTPUT v_ccred,
                             OUTPUT v_tipocontadebito,
                             OUTPUT v_tipocontacredito,
                             OUTPUT v_nrocontade,
                             OUTPUT v_nomede,
                             OUTPUT v_nomede1,
                             OUTPUT v_cpfcgcde,
                             OUTPUT v_cpfcgcde1,
                             OUTPUT v_banco,
                             OUTPUT v_agencia,
                             OUTPUT v_nrocontapara,
                             OUTPUT v_nomepara,
                             OUTPUT v_paranome1,
                             OUTPUT v_paracpfcgc,
                             OUTPUT v_paracpfcgc1,
                             OUTPUT v_valordocumento,
                             OUTPUT v_deschistorico,
                             OUTPUT v_nomebanco,
                             OUTPUT v_nomeagencia,
                             OUTPUT v_descricaofinalidade,
                             OUTPUT v_descricaocontadebito,
                             OUTPUT v_descricaocontacredito,
                             OUTPUT p-pessoa-de,
                             OUTPUT p-pessoa-para).
              
          IF  p-pessoa-de = 1  THEN
              ASSIGN RP = "v1".
          ELSE 
              ASSIGN RP = "v2".
            
          IF  p-pessoa-para = 1  THEN
              ASSIGN RP1 = "v1".
          ELSE 
              ASSIGN RP1 = "v2".
            
          ASSIGN v_valordocumento =
                 STRING(DEC(v_valordocumento),"zzz,zzz,zzz,zz9.99").
          ASSIGN v_nrocontade     =
                 STRING(INT(v_nrocontade),">>>>,>>>,9")
          v_nrocontapara   = STRING(DEC(v_nrocontapara),">>>>>>>>>>>>>9").
            
          IF RETURN-VALUE = "NOK" THEN  DO:
             ASSIGN vh_foco = "7".
             {include/i-erro.i}
          END.
          ELSE DO: 
                
             IF  get-value("ok") <> "" AND (get-value("R1") = "v3" OR
                                            get-value("R1") = "v4")  THEN DO:
                 
                 RUN dbo/b1crap20.p PERSISTENT SET h-b1crap20.
                 
                 RUN verifica-operador IN h-b1crap20(INPUT v_coop,
                                                     INPUT INT(v_pac),
                                                     INPUT INT(v_caixa),
                                                     INPUT v_cod,
                                                     INPUT v_senha,
                                                     INPUT 0,
                                                     INPUT 0).
                 
                 DELETE PROCEDURE h-b1crap20.
             END.

             IF RETURN-VALUE = 'NOK' THEN  DO:
                 vh_foco = '38'. 
                {include/i-erro.i}
             END.
             ELSE DO:
                  
                  ASSIGN vh_foco = '38'.
                  IF l-titular AND i-tipo-doc = 3 THEN
                     ASSIGN R1 = "v4".
                  ELSE
                      IF i-tipo-doc = 3 THEN
                         ASSIGN R1 = "v3".
            
                 IF  get-value("ok") <> "" THEN DO:
                      
                      ASSIGN l-houve-erro = NO.
                       
                      DO  TRANSACTION:
                  
                          RUN estorna-doc-ted
                            IN  h-b1crap21(INPUT v_coop,
                                           INPUT v_pac,
                                           INPUT v_caixa,
                                           INPUT i-tipo-doc,
                                           INPUT v_doc,
                                           INPUT dec(v_valordocumento),
                                           OUTPUT p-histor,
                                           OUTPUT p-histor-lcm,
                                           OUTPUT p-val-doc-lcm).
                          
                          IF  RETURN-VALUE = "OK" THEN DO:
                              RUN grava-autenticacao 
                                  IN h-b1crap00 (INPUT v_coop,
                                                 INPUT int(v_pac),
                                                 INPUT int(v_caixa),
                                                 INPUT v_operador,
                                                 INPUT dec(v_valordocumento),
                                                 INPUT dec(v_doc),
                                                 INPUT no, /*YES(PG),NO(REC)*/
                                                 INPUT "1",  /* On-line    */ 
                                                 INPUT yes,  
                                                 INPUT p-histor, 
                                                 INPUT ?, /* Data off-line */
                                                 INPUT 0, /* Seq off-line */
                                                 INPUT 0, /* Hora off-line */
                                                 INPUT 0,
                                                 OUTPUT p-literal,
                                                 OUTPUT p-ult-sequencia,
                                                 OUTPUT p-registro).

                              IF p-histor-lcm <> 0 THEN
                                 /* Estorno do lancamento */
                                 RUN grava-autenticacao 
                                     IN h-b1crap00 (INPUT v_coop,
                                                   INPUT int(v_pac),
                                                   INPUT int(v_caixa),
                                                   INPUT v_operador,
                                                   INPUT p-val-doc-lcm,
                                                   INPUT dec(v_doc),
                                                   INPUT YES,/*YES(PG),NO(REC)*/
                                                   INPUT "1",  /* On-line    */ 
                                                   INPUT YES, /* Estorno */ 
                                                   INPUT p-histor-lcm, 
                                                   INPUT ?, /* Data off-line */
                                                   INPUT 0, /* Seq off-line */
                                                   INPUT 0, /* Hora off-line */
                                                   INPUT 0,
                                                   OUTPUT p-literal-lcm,
                                                   OUTPUT p-ult-sequencia-lcm,
                                                   OUTPUT p-registro).
                          END.
                          
                          ASSIGN v_valordocumento =
                            STRING(DEC(v_valordocumento),"zzz,zzz,zzz,zz9.99").
                          
                          IF  RETURN-VALUE = "NOK" THEN DO:
                              ASSIGN l-houve-erro = YES.
                              FOR EACH w-craperr:
                                  DELETE w-craperr.
                              END.
                              FOR EACH craperr NO-LOCK WHERE
                                       craperr.cdcooper = crapcop.cdcooper AND
                                       craperr.cdagenci = INT(v_pac)       AND
                                       craperr.nrdcaixa = INT(v_caixa):
                  
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
                      END.
                  
                      IF  l-houve-erro = YES  THEN DO:
                          FOR EACH w-craperr NO-LOCK:
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
                      END.
                  
                      IF  l-houve-erro = NO THEN do:     
                           
                           {&OUT}
                             '<script>window.open("autentica.html?v_plit=" + "'p-literal '" +
                             "&v_pseq=" + "' p-ult-sequencia '" + "&v_prec=" + "NO"  + "&v_psetcook=" + "yes","waut","width=250,height=145,scrollbars=auto,alwaysRaised=true,left=0,top=0")
                              </script>'.
                               
                           IF   p-histor-lcm <> 0   THEN
                                DO:
                                   {&OUT}
                                      '<script>window.open("autentica.html?v_plit=" + "'p-literal-lcm '" +
                                      "&v_pseq=" + "' p-ult-sequencia-lcm '" + "&v_prec=" + "NO"  + "&v_psetcook=" + "yes","waut2","width=250,height=145,scrollbars=auto,alwaysRaised=true")
                                     </script>'.
                                END.

                           ASSIGN R1               = "v1"
                                  v_doc            = " "
                                  v_valordocumento = ""
                                  v_nrocontade     = ""
                                  v_nomede         = ""
                                  v_nomede1        = ""
                                  v_cpfcgcde       = ""
                                  v_cpfcgcde1      = ""
                                  v_banco          = ""
                                  v_nomebanco      = ""
                                  v_agencia        = ""
                                  v_nomeagencia    = ""
                                  v_nrocontapara   = ""
                                  v_nomepara       = " "
                                  v_paranome1      = " "
                                  v_paracpfcgc     = ""
                                  v_paracpfcgc1    = ""
                                  v_ccred          = ""
                                  v_descricaofinalidade   = ""
                                  v_tipocontadebito       = ""
                                  v_descricaocontadebito  = ""
                                  v_tipocontacredito      = ""
                                  v_descricaocontacredito = ""
                                  v_deschistorico         = ""
                                  v_cod                   = "" 
                                  v_senha                 = ""
                                  vh_foco                 = "7".

                      END.
                  END.
             END.
          END.
          DELETE PROCEDURE h-b1crap21.
       END.
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

    IF  get-value("R1") = "v3" OR  get-value("R1") = "v4" THEN
        ENABLE v_cod v_senha WITH FRAME {&FRAME-NAME}.
    ELSE
        DISABLE v_cod v_senha WITH FRAME {&FRAME-NAME}.

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
    
    /* Return the form again. Set data values, display them, and output them
     * to the WEB stream.  
     *
     * STEP 2a -
     * Set any values that need to be set, then display them. */
    ASSIGN vh_foco = "7".
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


