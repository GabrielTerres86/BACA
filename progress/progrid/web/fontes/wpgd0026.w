/*...............................................................................

Altera��es: 10/12/2008 - Pagina��o (Diego);
                       - Melhoria de performance para a tabela gnapses (Evandro).
					   
            05/06/2012 - Adapta��o dos fontes para projeto Oracle. Alterado
                         busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).

            19/03/2015 - Inclusao de verificacao para PAs inativos somente se nao 
                         for progrid (Lucas R.)
                         
            05/10/2015 - Incluido nova consulta na crapeap para maximo de participantes
                         por evento (Jean Michel).
                         
            23/02/2016 - Incluido a op��o �Todos os PAS� no campo "PA".
                         Criados os campos Eixo, Tema, Evento, Tipo de 
                         Evento, Fornecedor e Data.
                         Alteradas as colunas Evento, Pr�-Insc e Conf. 
                         para n�o apresentar em forma de link quando o
                         tipo do evento for igual a 10 (EAD).
                         As includes da procedure "CriaListaPac" foram 
                         substitu�das pelas novas wpgd0200.i e wpgd0201.i.
                         Projeto 229 - Melhorias OQS (Lombardi)
                         
                         
            24/03/2016 - Ajustado leitura da crapldp para permitir agencia 0
                         representando todas os agencias PRJ243.2 (Odirlei-AMcom )  

            31/05/2016 - Ajustes de Homologa��o conforme email do M�rcio de 27/05 (Vanessa)

            02/08/2016 - Inclusao insitage 3-Temporariamente Indisponivel.
                         (Jaison/Anderson)

...............................................................................*/


&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
/* Connected Databases 
          banco            PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_cdagenci AS CHARACTER 
       FIELD aux_cdcooper AS CHARACTER 
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdevento AS CHARACTER 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD cdagenci     AS CHARACTER FORMAT "X(256)":U 
       FIELD cdevento     AS CHARACTER FORMAT "X(256)":U 
       FIELD pagina       AS CHARACTER FORMAT "X(256)":U
       FIELD aux_carregar AS CHARACTER
       FIELD aux_reginils AS CHARACTER
       FIELD aux_regfimls AS CHARACTER
       FIELD aux_contarow AS INT
       FIELD aux_maxrows  AS INT
       FIELD aux_cdevento_pa AS CHARACTER
       FIELD aux_nrseqtem AS CHARACTER
       FIELD aux_cdeixtem AS CHARACTER
       FIELD aux_nrcpfcgc AS CHARACTER
       FIELD aux_tpevento AS CHARACTER
       FIELD aux_dtinieve AS CHARACTER FORMAT "X(256)":U
       FIELD aux_dtfineve AS CHARACTER FORMAT "X(256)":U.

DEFINE TEMP-TABLE fornecedores
       FIELD nrcpfcgc AS CHARACTER 
       FIELD nmfornec AS CHARACTER.
         
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
DEFINE VARIABLE ProgramaEmUso         AS CHARACTER INITIAL ["wpgd0026"].
DEFINE VARIABLE NmeDoPrograma         AS CHARACTER INITIAL ["wpgd0026.w"].

DEFINE VARIABLE opcao                 AS CHARACTER.
DEFINE VARIABLE msg-erro              AS CHARACTER.
DEFINE VARIABLE msg-erro-aux          AS INTEGER.
DEFINE VARIABLE aux_nrdrowid-auxiliar AS CHARACTER.
DEFINE VARIABLE pesquisa              AS CHARACTER.     
DEFINE VARIABLE FlagPermissoes        AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER FORMAT "x(47)".
DEFINE VARIABLE vauxsenha             AS CHARACTER FORMAT "X(16)".

DEFINE VARIABLE i                     AS INTEGER                        NO-UNDO.
DEFINE VARIABLE m-erros               AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE v-qtdeerro            AS INTEGER                        NO-UNDO.
DEFINE VARIABLE v-descricaoerro       AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE v-identificacao       AS CHARACTER                      NO-UNDO.

/*** Declara��o de BOs ***/
DEFINE VARIABLE h-b1wpgd0026          AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE crateap             LIKE crapeap.
DEFINE BUFFER crabedp FOR crapedp.   

DEFINE VARIABLE aux_crapcop           AS CHAR                           NO-UNDO.

DEFINE VARIABLE vetorevento           AS CHAR                           NO-UNDO.
                                                                        
DEFINE VARIABLE vetorevcoop           AS CHAR                           NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0026.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS crapeap.dtanoage 
&Scoped-define ENABLED-TABLES ab_unmap crapeap
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapeap
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_cdevento ab_unmap.cdevento ~
ab_unmap.pagina ab_unmap.cdagenci ab_unmap.aux_dtanoage ab_unmap.aux_cdagenci ~
ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ~
ab_unmap.aux_dsretorn ab_unmap.aux_idevento ab_unmap.aux_lspermis ~
ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ab_unmap.aux_carregar ~
ab_unmap.aux_reginils ab_unmap.aux_regfimls ab_unmap.aux_contarow ~
ab_unmap.aux_maxrows ab_unmap.aux_cdeixtem ab_unmap.aux_cdevento_pa ~
ab_unmap.aux_nrseqtem ab_unmap.aux_nrcpfcgc ab_unmap.aux_dtinieve ~
ab_unmap.aux_dtfineve ab_unmap.aux_tpevento
&Scoped-Define DISPLAYED-FIELDS crapeap.dtanoage 
&Scoped-define DISPLAYED-TABLES ab_unmap crapeap
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapeap
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_cdevento ab_unmap.cdevento ~
ab_unmap.pagina ab_unmap.cdagenci ab_unmap.aux_dtanoage ab_unmap.aux_cdagenci ~
ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ~
ab_unmap.aux_dsretorn ab_unmap.aux_idevento ab_unmap.aux_lspermis ~
ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ab_unmap.aux_carregar ~
ab_unmap.aux_reginils ab_unmap.aux_regfimls ab_unmap.aux_contarow ~
ab_unmap.aux_maxrows ab_unmap.aux_cdeixtem ab_unmap.aux_cdevento_pa ~
ab_unmap.aux_nrseqtem ab_unmap.aux_nrcpfcgc ab_unmap.aux_dtinieve ~
ab_unmap.aux_dtfineve ab_unmap.aux_tpevento

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.aux_cdevento AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.cdevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.pagina AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.cdagenci AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dtanoage AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdagenci AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_cdevento_pa AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_nrseqtem AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_cdeixtem AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_nrcpfcgc AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_tpevento AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_dtinieve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dtfineve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cddopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dsendurl AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dsretorn AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_idevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lspermis AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrdrowid AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_stdopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapeap.dtanoage AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_carregar AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_reginils AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_regfimls AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
         ab_unmap.aux_contarow AT ROW 1 COL 1 HELP
          "" NO-LABEL 
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
         ab_unmap.aux_maxrows AT ROW 1 COL 1 HELP
          "" NO-LABEL 
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 71.4 BY 17.91.


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
          FIELD aux_cdagenci AS CHARACTER 
          FIELD aux_cdcooper AS CHARACTER 
          FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cdevento AS CHARACTER 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD cdagenci AS CHARACTER FORMAT "X(256)":U 
          FIELD cdevento AS CHARACTER FORMAT "X(256)":U 
          FIELD pagina AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cdevento_pa AS CHARACTER
          FIELD aux_nrseqtem AS CHARACTER
          FIELD aux_cdeixtem AS CHARACTER
          FIELD aux_nrcpfcgc AS CHARACTER
          FIELD aux_tpevento AS CHARACTER
          FIELD aux_dtinieve AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dtfineve AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 17.91
         WIDTH              = 71.4.
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
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdagenci IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdcooper IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdevento_pa IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_nrseqtem IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdeixtem IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_nrcpfcgc IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_tpevento IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dtinieve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dtfineve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cddopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdevento IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsretorn IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dtanoage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.cdagenci IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.cdevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapeap.dtanoage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN ab_unmap.pagina IN FRAME Web-Frame
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEvCoop w-html 
PROCEDURE CriaListaEvCoop :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE aux_nrdturma AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nmevento AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_cdevento AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_cdevento_pa AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_nrseqtem AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_cdeixtem AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_nrcpfcgc AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_tpevento AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_lsevento AS CHAR NO-UNDO.
    
    ASSIGN aux_cdeixtem    = "�TODOS --,-1"
           aux_nrseqtem    = "�TODOS --,-1"
           aux_cdevento    = "--Selecione Evento --,0"
           aux_cdevento_pa = "�TODOS --,-1"
           aux_nrcpfcgc    = "�TODOS --,-1"
           aux_tpevento    = "�TODOS --,-1"
           aux_lsevento    = "".
    
    /* EIXOS */
    FOR EACH gnapetp WHERE gnapetp.idevento = INT(ab_unmap.aux_idevento)      AND
                           gnapetp.flgativo = TRUE                            NO-LOCK
                           BY gnapetp.dseixtem:
        FOR EACH  craptem WHERE craptem.idevento = gnapetp.idevento           AND
                                craptem.cdeixtem = gnapetp.cdeixtem           AND
                                craptem.idsittem = "A"                        NO-LOCK,
            EACH  crapedp WHERE crapedp.idevento = craptem.idevento           AND
                                crapedp.nrseqtem = craptem.nrseqtem           AND
                                crapedp.cdcooper = INT(ab_unmap.aux_cdcooper) AND
                                crapedp.dtanoage = INT(ab_unmap.aux_dtanoage) NO-LOCK,
            EACH  crapeap WHERE crapeap.idevento = crapedp.idevento           AND
                                crapeap.cdcooper = crapedp.cdcooper           AND
                                crapeap.dtanoage = crapedp.dtanoage           AND
                                crapeap.cdevento = crapedp.cdevento           AND
                               (INT(ab_unmap.aux_cdagenci) = -1               OR
                                crapeap.cdagenci = INT(ab_unmap.cdagenci))    AND
                                crapeap.flgevsel = YES                        NO-LOCK,
            FIRST crapadp WHERE crapadp.idevento = crapeap.idevento           AND
                                crapadp.cdcooper = crapeap.cdcooper           AND
                                crapadp.dtanoage = crapeap.dtanoage           AND
                                crapadp.cdevento = crapeap.cdevento           AND
                                crapadp.cdagenci = crapeap.cdagenci           NO-LOCK:
              
              ASSIGN aux_cdeixtem = aux_cdeixtem + "," + gnapetp.dseixtem + "," + STRING(gnapetp.cdeixtem).
              LEAVE.
        END.
    END.
    /* TEMAS */
    FOR EACH craptem WHERE (INT(ab_unmap.aux_cdeixtem) < 1                 OR 
                           craptem.cdeixtem = INT(ab_unmap.aux_cdeixtem))  AND
                           craptem.idevento = INT(ab_unmap.aux_idevento)   AND
                           craptem.idsittem = "A"                          NO-LOCK
                           BY craptem.dstemeix:
        FOR EACH crapedp WHERE crapedp.idevento = craptem.idevento             AND
                               crapedp.nrseqtem = craptem.nrseqtem             AND
                               crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)   AND
                               crapedp.dtanoage = INT(ab_unmap.aux_dtanoage)   NO-LOCK,
            EACH crapeap WHERE crapeap.idevento = crapedp.idevento             AND
                               crapeap.cdcooper = crapedp.cdcooper             AND
                               crapeap.dtanoage = crapedp.dtanoage             AND
                               crapeap.cdevento = crapedp.cdevento             AND
                              (INT(ab_unmap.aux_cdagenci) = -1                 OR
                               crapeap.cdagenci = INT(ab_unmap.cdagenci))  AND
                               crapeap.flgevsel = YES                          NO-LOCK,
            FIRST crapadp WHERE crapadp.idevento = crapeap.idevento           AND
                                crapadp.cdcooper = crapeap.cdcooper           AND
                                crapadp.dtanoage = crapeap.dtanoage           AND
                                crapadp.cdevento = crapeap.cdevento           AND
                                crapadp.cdagenci = crapeap.cdagenci           NO-LOCK:
        
              ASSIGN aux_nrseqtem = aux_nrseqtem + "," + craptem.dstemeix + "," + STRING(craptem.nrseqtem).
              LEAVE.
        END.
    END.
    DEF VAR aux_contador AS INT.
    
    ASSIGN aux_contador = 0.
    /* EVENTOS */
    FOR EACH  crapedp WHERE crapedp.idevento = INT(ab_unmap.aux_idevento)  AND
                           (INT(ab_unmap.aux_nrseqtem) < 1                 OR 
                            crapedp.nrseqtem = INT(ab_unmap.aux_nrseqtem)) AND
                            crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)  AND
                            crapedp.dtanoage = INT(ab_unmap.aux_dtanoage)  NO-LOCK,
        FIRST crapeap WHERE crapeap.idevento = crapedp.idevento            AND
                            crapeap.cdcooper = crapedp.cdcooper            AND
                            crapeap.dtanoage = crapedp.dtanoage            AND
                            crapeap.cdevento = crapedp.cdevento            AND
                           (INT(ab_unmap.aux_cdagenci) = -1                OR
                            crapeap.cdagenci = INT(ab_unmap.cdagenci))     AND
                            crapeap.flgevsel = YES                         NO-LOCK 
                            BY crapedp.nmevento:
              
              FIND FIRST crapadp WHERE crapadp.idevento = crapeap.idevento AND
                                       crapadp.cdcooper = crapeap.cdcooper AND
                                       crapadp.dtanoage = crapeap.dtanoage AND
                                       crapadp.cdevento = crapeap.cdevento AND
                                       crapadp.cdagenci = crapeap.cdagenci NO-LOCK no-error.
              
              IF NOT AVAILABLE crapadp THEN
                    NEXT.
              
              IF INT(ab_unmap.aux_nrseqtem) < 1 AND INT(ab_unmap.aux_cdeixtem) > 0 THEN DO:
                    FOR EACH  gnapetp WHERE gnapetp.idevento = INT(ab_unmap.aux_idevento) AND
                                            gnapetp.flgativo = TRUE                       AND
                                            gnapetp.cdeixtem = INT(ab_unmap.aux_cdeixtem) NO-LOCK,
                        FIRST craptem WHERE craptem.idevento = gnapetp.idevento           AND
                                            craptem.cdeixtem = gnapetp.cdeixtem           AND
                                            craptem.idsittem = "A"                        AND
                                            craptem.nrseqtem = crapedp.nrseqtem           NO-LOCK:
                          ASSIGN aux_cdevento_pa = aux_cdevento_pa + "," + REPLACE(crapedp.nmevent, ",", ".") + "," + STRING(crapedp.cdevento).
                          IF aux_lsevento <> "" THEN aux_lsevento = aux_lsevento + ",".
                          aux_lsevento = aux_lsevento + STRING(crapedp.cdevento).
                          LEAVE.
                    END.
                 END.
              ELSE DO:
                ASSIGN aux_cdevento_pa = aux_cdevento_pa + "," + REPLACE(crapedp.nmevent, ",", ".") + "," + STRING(crapedp.cdevento).
                IF aux_lsevento <> "" THEN aux_lsevento = aux_lsevento + ",".
                aux_lsevento = aux_lsevento + STRING(crapedp.cdevento).
              END.
    END.
    /* EVENTOS - SEM PA*/
    FOR EACH  crapedp WHERE crapedp.idevento = INT(ab_unmap.aux_idevento)  AND
                           (INT(ab_unmap.aux_nrseqtem) < 1                 OR 
                            crapedp.nrseqtem = INT(ab_unmap.aux_nrseqtem)) AND
                            crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)  AND
                            crapedp.dtanoage = INT(ab_unmap.aux_dtanoage)  NO-LOCK,
        FIRST crapeap WHERE crapeap.idevento = crapedp.idevento            AND
                            crapeap.cdcooper = crapedp.cdcooper            AND
                            crapeap.dtanoage = crapedp.dtanoage            AND
                            crapeap.cdevento = crapedp.cdevento            AND
                            crapeap.flgevsel = YES                         NO-LOCK 
                            BY crapedp.nmevento:
              
              FIND FIRST crapadp WHERE crapadp.idevento = crapeap.idevento AND
                                       crapadp.cdcooper = crapeap.cdcooper AND
                                       crapadp.dtanoage = crapeap.dtanoage AND
                                       crapadp.cdevento = crapeap.cdevento AND
                                       crapadp.cdagenci = crapeap.cdagenci NO-LOCK NO-ERROR.
              
              IF NOT AVAILABLE crapadp THEN
                    NEXT.
              
              IF INT(ab_unmap.aux_nrseqtem) < 1 AND INT(ab_unmap.aux_cdeixtem) > 0 THEN DO:
                    FOR EACH  gnapetp WHERE gnapetp.idevento = INT(ab_unmap.aux_idevento) AND
                                            gnapetp.flgativo = TRUE                       AND
                                            gnapetp.cdeixtem = INT(ab_unmap.aux_cdeixtem) NO-LOCK,
                        FIRST craptem WHERE craptem.idevento = gnapetp.idevento           AND
                                            craptem.cdeixtem = gnapetp.cdeixtem           AND
                                            craptem.idsittem = "A"                        AND
                                            craptem.nrseqtem = crapedp.nrseqtem           NO-LOCK:
                          ASSIGN aux_cdevento = aux_cdevento + "," + REPLACE(crapedp.nmevent, ",", ".") + "," + STRING(crapedp.cdevento).
                          LEAVE.
                    END.
                 END.
              ELSE 
                ASSIGN aux_cdevento = aux_cdevento + "," + REPLACE(crapedp.nmevent, ",", ".") + "," + STRING(crapedp.cdevento).
    END.
    /* FORNECEDORES */
    FOR EACH crapcdp WHERE crapcdp.idevento = INT(ab_unmap.aux_idevento)     AND
                           crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper)     AND
                           crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage)     AND
                           crapcdp.tpcuseve = 1                              AND
                          (ab_unmap.pagina = "divConfirma"                   OR
                           INT(ab_unmap.aux_cdagenci) = -1                   OR
                           crapcdp.cdagenci = INT(ab_unmap.aux_cdagenci))    AND
                           LOOKUP(STRING(crapcdp.cdevento), aux_lsevento, ",") > 0
                           NO-LOCK BREAK BY crapcdp.nrcpfcgc :
      IF FIRST-OF(crapcdp.nrcpfcgc) THEN DO:
        FIND gnapfdp WHERE gnapfdp.idevento = INT(ab_unmap.aux_idevento) AND
                           gnapfdp.nrcpfcgc = crapcdp.nrcpfcgc           NO-LOCK NO-ERROR.
        IF AVAILABLE gnapfdp THEN
          CREATE fornecedores.
          ASSIGN fornecedores.nrcpfcgc = STRING(gnapfdp.nrcpfcgc)
                 fornecedores.nmfornec = STRING(gnapfdp.nmfornec).       
          
      END.
    END.
    
    /* Percorre a Temp table para ordena��o*/
     FOR EACH fornecedores NO-LOCK  BY fornecedores.nmfornec:
        ASSIGN aux_nrcpfcgc = aux_nrcpfcgc + "," + REPLACE(fornecedores.nmfornec,",",".") + "," + STRING(fornecedores.nrcpfcgc). 
     END.
     
     
    /* Busca as listas de Tipo de Evento, Participacao Permitida e Eixos Tematicos */
    FIND FIRST craptab WHERE craptab.cdcooper = 0               AND
                             craptab.nmsistem = "CRED"          AND
                             craptab.tptabela = "CONFIG"        AND
                             craptab.cdempres = 0               AND
                             craptab.cdacesso = "PGTPEVENTO"    AND
                             craptab.tpregist = 0               NO-LOCK NO-ERROR.
    
    IF   AVAILABLE craptab   THEN
         ASSIGN aux_tpevento = aux_tpevento + "," + craptab.dstextab.
    
    ASSIGN
    ab_unmap.aux_cdeixtem:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_cdeixtem
    ab_unmap.aux_nrseqtem:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_nrseqtem
    ab_unmap.aux_cdevento_pa:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_cdevento_pa
    ab_unmap.aux_cdevento:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_cdevento
    ab_unmap.aux_nrcpfcgc:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_nrcpfcgc
    ab_unmap.aux_tpevento:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_tpevento.
    
    /********* L�gica para diferenciar tipos de evento em Progrid e Assembl�ia *********/
    /* Para todos os tipos de evento da CRAPTAB */
    DO i = 1 TO (NUM-ENTRIES(aux_tpevento) / 2):

        /* Se for Progrid */
        IF   ab_unmap.aux_idevento = "1" THEN
            DO:
                IF   ENTRY(i * 2, aux_tpevento) = "7"   OR 
                     ENTRY(i * 2, aux_tpevento) = "8"   OR 
                     ENTRY(i * 2, aux_tpevento) = "11"  THEN
                     DO:
                         ab_unmap.aux_tpevento:DELETE(ENTRY(i * 2, aux_tpevento))
                              IN FRAME {&FRAME-NAME}.
                     END.
            END.
        /* Assembl�ias */
        ELSE 
            DO:
                IF   ENTRY(i * 2, aux_tpevento) <> "-1"  AND
                     ENTRY(i * 2, aux_tpevento) <> "7"   AND
                     ENTRY(i * 2, aux_tpevento) <> "8"   AND
                     ENTRY(i * 2, aux_tpevento) <> "11"  THEN
                     DO:
                         ab_unmap.aux_tpevento:DELETE(ENTRY(i * 2, aux_tpevento)).
                     END.
            
            END.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEventos w-html 
PROCEDURE CriaListaEventos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF VAR aux_tpevento AS CHAR                        NO-UNDO.
    DEF VAR aux_qtmaxtur AS INT                         NO-UNDO.
    DEF VAR aux_nrinscri AS INT                         NO-UNDO.
    DEF VAR aux_nrconfir AS INT                         NO-UNDO.
    DEF VAR aux_idpropos AS CHAR                        NO-UNDO.
    DEF VAR aux_nmresage AS CHAR                        NO-UNDO.
    DEF VAR aux_dslocali AS CHAR                        NO-UNDO.
    DEF VAR aux_enlocali AS CHAR                        NO-UNDO.
    DEF VAR aux_idstaeve AS CHAR                        NO-UNDO.
    DEF VAR aux_dtevento AS CHAR                        NO-UNDO.
    DEF VAR aux_nmevento AS CHAR                        NO-UNDO.
    DEF VAR aux_dados    AS CHAR                        NO-UNDO.
    DEF VAR aux_cdeveant AS INT                         NO-UNDO.
    DEF VAR aux_cdageant AS INT                         NO-UNDO.
    DEF VAR aux_contador AS INT                         NO-UNDO.
    DEF VAR aux_qtpagina AS INT  INIT 30                NO-UNDO.
    DEF VAR aux_qtregist AS INT  INIT 0                 NO-UNDO.
    DEF VAR aux_procregi AS LOGICAL                     NO-UNDO.

    DEF VAR vetorevento  AS CHAR                        NO-UNDO.
    
    DEF VAR vetormes     AS CHAR EXTENT 12
        INITIAL ["Janeiro","Fevereiro","Mar�o","Abril","Maio","Junho",
                 "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"].
                 
    DEF QUERY q_crapadp FOR crapadp, crapedp SCROLLING.

    OPEN QUERY q_crapadp FOR EACH crapadp WHERE crapadp.idevento = INT(ab_unmap.aux_idevento)      AND
                                                crapadp.cdcooper = INT(ab_unmap.aux_cdcooper)      AND
                                                crapadp.dtanoage = INT(ab_unmap.aux_dtanoage)      AND
                                              ((ab_unmap.pagina = "divInscrito"                    AND
                                               (INT(ab_unmap.aux_cdevento_pa) = -1                 OR
                                                crapadp.cdevento = INT(ab_unmap.aux_cdevento_pa))) OR
                                               (ab_unmap.pagina = "divConfirma"                    AND
                                                crapadp.cdevento = INT(ab_unmap.cdevento)))        AND
                                               (ab_unmap.pagina = "divConfirma"                    OR
                                                INT(ab_unmap.cdagenci) = -1                        OR
                                                crapadp.cdagenci = INT(ab_unmap.cdagenci))         NO-LOCK,
                            FIRST crapedp WHERE crapedp.idevento = crapadp.idevento                AND
                                                crapedp.cdcooper = crapadp.cdcooper                AND
                                                crapedp.dtanoage = crapadp.dtanoage                AND
                                                crapedp.cdevento = crapadp.cdevento                AND
                                               (INT(ab_unmap.aux_tpevento) = -1                    OR
                                                crapedp.tpevento = INT(ab_unmap.aux_tpevento)) NO-LOCK 
                                                BY crapadp.nrmeseve
                                                BY crapadp.dtinieve                                                                                             
                                                BY crapedp.nmevento
                                                BY crapadp.cdagenci  
                                                INDEXED-REPOSITION.
                                             /* INDEXED-REPOSITION MAX-ROWS aux_qtpagina. */

    ASSIGN aux_cdeveant = ?
           aux_cdageant = ?.

    /* Descri��o do status do evento */
    FIND craptab WHERE craptab.cdcooper = 0             AND  
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "CONFIG"      AND
                       craptab.cdempres = 0             AND
                       craptab.cdacesso = "PGSTEVENTO"  AND
                       craptab.tpregist = 0             NO-LOCK NO-ERROR NO-WAIT.

    IF   ab_unmap.aux_carregar = "proximos"   THEN
         DO:
            REPOSITION q_crapadp TO ROWID TO-ROWID(ab_unmap.aux_regfimls).
            REPOSITION q_crapadp FORWARDS aux_qtpagina.
            REPOSITION q_crapadp TO ROWID TO-ROWID(ab_unmap.aux_regfimls).
         END.
    ELSE
    IF   ab_unmap.aux_carregar = "anteriores"   THEN
         DO:
            REPOSITION q_crapadp TO ROWID TO-ROWID(ab_unmap.aux_reginils).
            REPOSITION q_crapadp BACKWARDS aux_qtpagina - 1.
         END.

    ASSIGN ab_unmap.aux_maxrows  = 30
           ab_unmap.aux_contarow = 0. 
    
    /* Verifica se a Query abriu */
    IF   NUM-RESULTS("q_crapadp") <> ?   THEN 
         DO aux_qtregist = 1 TO aux_qtpagina:
            
            GET NEXT q_crapadp.

            IF   AVAILABLE crapadp   THEN
                 DO:
                     ASSIGN aux_procregi = TRUE.
                     
                     IF INT(ab_unmap.aux_cdevento_pa) < 1 AND
                        INT(ab_unmap.aux_cdevento) < 1    THEN DO:
                       IF INT(ab_unmap.aux_nrseqtem) > 0 THEN DO:
                         ASSIGN aux_procregi = FALSE.
                         FOR FIRST crapedp WHERE crapedp.idevento = crapadp.idevento           AND
                                                 crapedp.cdevento = crapadp.cdevento           AND
                                                 crapedp.cdcooper = crapadp.cdcooper           AND
                                                 crapedp.dtanoage = crapadp.dtanoage           AND
                                                 crapedp.nrseqtem = INT(ab_unmap.aux_nrseqtem) NO-LOCK:
                             ASSIGN aux_procregi = TRUE.
                         END.
                       END.
                       ELSE IF INT(ab_unmap.aux_cdeixtem) > 0 THEN DO:
                         ASSIGN aux_procregi = FALSE.
                         FOR FIRST crapedp WHERE crapedp.idevento = crapadp.idevento           AND
                                                 crapedp.cdevento = crapadp.cdevento           AND
                                                 crapedp.cdcooper = crapadp.cdcooper           AND
                                                 crapedp.dtanoage = crapadp.dtanoage           NO-LOCK,
                             FIRST craptem WHERE craptem.idevento = crapedp.idevento           AND
                                                 craptem.idsittem = "A"                        AND
                                                 craptem.nrseqtem = crapedp.nrseqtem           AND
                                                 craptem.cdeixtem = INT(ab_unmap.aux_cdeixtem) NO-LOCK,
                             FIRST gnapetp where gnapetp.idevento = craptem.idevento           AND
                                                 gnapetp.cdeixtem = craptem.cdeixtem           AND
                                                 gnapetp.flgativo = TRUE                       NO-LOCK:
                             ASSIGN aux_procregi = TRUE.
                         END.
                       END.
                     END.

                     IF DEC(ab_unmap.aux_nrcpfcgc) > 0 AND aux_procregi = TRUE THEN DO:
                       ASSIGN aux_procregi = FALSE.
                       FOR FIRST gnapfdp WHERE gnapfdp.idevento = crapadp.idevento           AND
                                               gnapfdp.nrcpfcgc = DEC(ab_unmap.aux_nrcpfcgc) NO-LOCK,
                           FIRST crapcdp WHERE crapcdp.nrcpfcgc = gnapfdp.nrcpfcgc           AND
                                               crapcdp.idevento = crapadp.idevento           AND
                                               crapcdp.cdcooper = crapadp.cdcooper           AND
                                               crapcdp.dtanoage = crapadp.dtanoage           AND
                                               crapcdp.cdagenci = crapadp.cdagenci           AND
                                               crapcdp.cdevento = crapadp.cdevento           NO-LOCK:
                         ASSIGN aux_procregi = TRUE.
                       END.
                     END.
                       
                     IF aux_procregi = TRUE THEN DO:
                       IF   aux_qtregist = 1   THEN
                            ab_unmap.aux_reginils = STRING(CURRENT-RESULT-ROW("q_crapadp")).

                       ASSIGN ab_unmap.aux_regfimls = STRING(ROWID(crapadp))
                              ab_unmap.aux_contarow = ab_unmap.aux_contarow + 1.

                        
                       /* Nome do evento */
                       IF   aux_cdeveant <> crapadp.cdevento   THEN
                            DO:
                                  FIND FIRST crapedp WHERE crapedp.idevento = crapadp.idevento            AND
                                                           crapedp.cdcooper = crapadp.cdcooper            AND
                                                           crapedp.dtanoage = crapadp.dtanoage            AND
                                                           crapedp.cdevento = crapadp.cdevento            
                                                           NO-LOCK NO-ERROR NO-WAIT.

                                  IF AVAILABLE crapedp THEN
                                    DO:
                                      ASSIGN aux_nmevento = crapedp.nmevento
                                              aux_tpevento = STRING(crapedp.tpevento).
                                        
                                    END.
                                  ELSE
                                    DO:
                                       ASSIGN aux_nmevento = "** NAO ENCONTRADO **"
                                              aux_tpevento = "".
                                    END.
                                  
                                aux_cdeveant = crapadp.cdevento.
                            END. 
                        ELSE
                          DO:
                            
                              FIND FIRST crapedp WHERE crapedp.idevento = crapadp.idevento   AND
                                                       crapedp.cdcooper = crapadp.cdcooper   AND
                                                       crapedp.dtanoage = crapadp.dtanoage   AND
                                                       crapedp.cdevento = crapadp.cdevento
                                                       NO-LOCK NO-ERROR NO-WAIT.

                              IF AVAILABLE crapedp THEN
                                DO:
                                  ASSIGN aux_nmevento = crapedp.nmevento
                                          aux_tpevento = STRING(crapedp.tpevento).
                                                                    
                                END.
                              ELSE
                                DO:
                                   ASSIGN aux_nmevento = "** NAO ENCONTRADO **"
                                          aux_tpevento = "".
                                END.
                          END.
                       
                        /***************/
                        ASSIGN aux_qtmaxtur = 0.
                        
                        FIND FIRST crapeap WHERE crapeap.cdcooper = crapadp.cdcooper AND
                                                 crapeap.idevento = crapadp.idevento AND                                     
                                                 crapeap.cdevento = crapadp.cdevento AND
                                                 crapeap.dtanoage = crapadp.dtanoage AND
                                                 crapeap.cdagenci = crapadp.cdagenci NO-LOCK NO-ERROR NO-WAIT.
                         
                        IF AVAILABLE crapeap THEN
                          DO:
                            IF crapeap.qtmaxtur > 0 THEN
                              ASSIGN aux_qtmaxtur = aux_qtmaxtur + crapeap.qtmaxtur.
                            ELSE
                              DO:
                                /* para a frequencia minima */
                                FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento AND 
                                                         crabedp.cdcooper = crapadp.cdcooper AND
                                                         crabedp.dtanoage = crapadp.dtanoage AND 
                                                         crabedp.cdevento = crapadp.cdevento NO-LOCK NO-ERROR NO-WAIT.
                                IF AVAILABLE crabedp THEN
                                  DO:
                                    IF crabedp.qtmaxtur > 0 THEN
                                      ASSIGN aux_qtmaxtur = aux_qtmaxtur + crabedp.qtmaxtur.
                                    ELSE
                                      DO:
                                        FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento AND 
                                                             crabedp.cdcooper = 0 AND
                                                             crabedp.dtanoage = 0 AND 
                                                             crabedp.cdevento = crapadp.cdevento NO-LOCK NO-ERROR NO-WAIT.
                                                            
                                        IF AVAILABLE crabedp THEN
                                          ASSIGN aux_qtmaxtur = aux_qtmaxtur + crabedp.qtmaxtur.
                                      END.
                                  END.
                              END.
                          END.
                        ELSE
                          DO:
                            /* para a frequencia minima */
                            FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento AND 
                                                     crabedp.cdcooper = crapadp.cdcooper AND
                                                     crabedp.dtanoage = crapadp.dtanoage AND 
                                                     crabedp.cdevento = crapadp.cdevento NO-LOCK NO-ERROR NO-WAIT. 
                            IF AVAILABLE crabedp THEN
                              DO:
                                IF crabedp.qtmaxtur > 0 THEN
                                  ASSIGN aux_qtmaxtur = aux_qtmaxtur + crabedp.qtmaxtur.
                                ELSE
                                  DO:
                                    FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento AND 
                                                         crabedp.cdcooper = 0 AND
                                                         crabedp.dtanoage = 0 AND 
                                                         crabedp.cdevento = crapadp.cdevento NO-LOCK NO-ERROR NO-WAIT.
                                                        
                                    IF AVAILABLE crapedp THEN
                                      ASSIGN aux_qtmaxtur = aux_qtmaxtur + crabedp.qtmaxtur.
                                  END.
                              END.
                          END.
                      /****************/
                      
                       /* Proposta */
                       aux_idpropos = "".
                       DO aux_contador = 1 TO 4:
                                   
                          FIND FIRST crapcdp WHERE crapcdp.idevento = crapadp.idevento  AND    
                           crapcdp.cdcooper = crapadp.cdcooper  AND
                           crapcdp.cdagenci = crapadp.cdagenci  AND
                           crapcdp.dtanoage = crapadp.dtanoage  AND
                           crapcdp.tpcuseve = aux_contador      AND
                           crapcdp.cdevento = crapadp.cdevento
                           NO-LOCK NO-ERROR NO-WAIT.

                          IF   AVAIL crapcdp   THEN
                               DO: 
                                   FIND FIRST gnappdp WHERE gnappdp.cdcooper = 0                 AND
                                                            gnappdp.idevento = crapcdp.idevento  AND
                                                            gnappdp.nrcpfcgc = crapcdp.nrcpfcgc  AND
                                                            gnappdp.nrpropos = crapcdp.nrpropos  NO-LOCK NO-ERROR NO-WAIT.
                                       
                                                               IF   AVAIL gnappdp   THEN 
                                        ASSIGN aux_idpropos = STRING(ROWID(gnappdp)).
                                                                          
                               END.
                                           END.

                       /* Nome do PA */
                       IF   aux_cdageant <> crapadp.cdagenci   THEN
                            DO:
                                FIND crapage WHERE crapage.cdcooper = crapadp.cdcooper   AND
                                                   crapage.cdagenci = crapadp.cdagenci   
                                                   NO-LOCK NO-ERROR NO-WAIT.
                                
                                IF   AVAIL crapage   THEN
                                     DO:
                                         
                                         /* Se o PA nao esta ativo e n�o for progrid, despreza */
                                         IF   crapage.insitage <> 1  AND  /* Ativo */
                                              crapage.insitage <> 3  AND  /* Temporariamente Indisponivel */
                                              INT(ab_unmap.aux_idevento) <> 1 THEN
                                              NEXT. 

                                         aux_nmresage = crapage.nmresage.
                                     END.
                                ELSE
                                IF   INT(ab_unmap.cdagenci) = 0   THEN
                                     aux_nmresage = "TODOS".
                                ELSE
                                     aux_nmresage = "** NAO ENCONTRADO **".

                                aux_cdageant = crapadp.cdagenci.
                            END.

                       /* Data do Evento */
                       IF   crapadp.dtinieve = ?   THEN
                            DO:
                                IF   crapadp.nrmeseve <> 0   THEN 
                                     aux_dtevento = vetormes[crapadp.nrmeseve].
                            END.
                       ELSE 
                            aux_dtevento = STRING(crapadp.dtinieve, "99/99/9999").

                       IF   aux_dtevento = ?   THEN
                            aux_dtevento = "".
                       
                       
                       
                       IF (aux_dtevento = "" OR crapadp.dtinieve = ? ) AND (ab_unmap.aux_dtinieve <> "" OR ab_unmap.aux_dtfineve <> "") THEN DO:
                         ASSIGN aux_qtregist = aux_qtregist - 1. 
                         NEXT.
                       END.
                       
                       IF ab_unmap.aux_dtinieve <> "" AND  DATE(STRING(crapadp.dtinieve, "99/99/9999")) < DATE(ab_unmap.aux_dtinieve) THEN DO:
                         ASSIGN aux_qtregist = aux_qtregist - 1. 
                         NEXT.
                       END.
                       
                       IF ab_unmap.aux_dtfineve <> "" AND  DATE(STRING(crapadp.dtfineve, "99/99/9999")) > DATE(ab_unmap.aux_dtfineve) THEN DO:
                         ASSIGN aux_qtregist = aux_qtregist - 1. 
                         NEXT.
                       END.
                      
                       /* Local */
                       IF crapadp.cdagenci = 0 THEN
                           FIND FIRST crapldp WHERE crapldp.cdcooper = crapadp.cdcooper  AND
                                                    crapldp.idevento = 1 /* IDEVENTO � sempre 1 para locais */  AND
                                                    crapldp.nrseqdig = crapadp.cdlocali  NO-LOCK NO-ERROR NO-WAIT.
                       ELSE 
                           FIND FIRST crapldp WHERE crapldp.cdcooper = crapadp.cdcooper  AND
                                                    crapldp.idevento = 1 /* IDEVENTO � sempre 1 para locais */  AND
                                                    crapldp.cdagenci = crapadp.cdagenci  AND
                                                    crapldp.nrseqdig = crapadp.cdlocali  NO-LOCK NO-ERROR NO-WAIT.
                       IF   NOT AVAIL crapldp   THEN
                       DO :
                           FIND FIRST crapldp WHERE crapldp.cdcooper = crapadp.cdcooper  AND
                                                    crapldp.idevento = 1 /* IDEVENTO � sempre 1 para locais */  AND
                                                    crapldp.cdagenci = 0  AND /* para EAD*/
                                                    crapldp.nrseqdig = crapadp.cdlocali  NO-LOCK NO-ERROR NO-WAIT.
                           
                           IF   NOT AVAIL crapldp   THEN
                                ASSIGN aux_dslocali = ""
                                       aux_enlocali = "".
                           ELSE
                                DO:
                                    ASSIGN aux_dslocali = crapldp.dslocali
                                           aux_enlocali = crapldp.dsendloc.

                                    /* Se tiver o bairro, coloca junto com o endere�o, pra aparecer no tooltip */
                                    IF   TRIM(crapldp.nmbailoc) <> ""   THEN
                                          ASSIGN aux_enlocali = aux_enlocali + " - " + crapldp.nmbailoc.
                                END.
                       
                       END.     
                       ELSE /*------*/
                            DO:
                                ASSIGN aux_dslocali = crapldp.dslocali
                                       aux_enlocali = crapldp.dsendloc.

                                /* Se tiver o bairro, coloca junto com o endere�o, pra aparecer no tooltip */
                                IF   TRIM(crapldp.nmbailoc) <> ""   THEN
                                      ASSIGN aux_enlocali = aux_enlocali + " - " + crapldp.nmbailoc.
                            END.
                       
                       /* Inscritos e confirmados */
                       ASSIGN aux_nrinscri = 0
                              aux_nrconfir = 0.

                           FOR EACH crapidp WHERE crapidp.idevento = crapadp.idevento  AND
                                              crapidp.cdcooper = crapadp.cdcooper  AND 
                                                  crapidp.dtanoage = crapadp.dtanoage  AND
                                                                        crapidp.cdagenci = crapadp.cdagenci  AND
                                                                        crapidp.cdevento = crapadp.cdevento  AND                 
                                                                        crapidp.nrseqeve = crapadp.nrseqdig
                                                                        USE-INDEX crapidp1 NO-LOCK:

                           /* Para Assembl�ias - somar as inscri��es e confirma��es de todos os pas */
                           IF   crapidp.cdageins <> crapadp.cdagenci   AND
                                crapadp.cdagenci <> 0                  THEN
                                NEXT.
                       
                           /* Pendentes e Confirmados */
                           IF   crapidp.idstains < 5   THEN
                                aux_nrinscri = aux_nrinscri + 1.

                           /* Somente Confirmados */            
                           IF   crapidp.idstains = 2   THEN
                                aux_nrconfir = aux_nrconfir + 1.
                       END.
                       
                       /* Situacao do evento */
                       IF   AVAILABLE craptab       AND
                            crapadp.idstaeve <> 0   THEN 
                            aux_idstaeve = ENTRY(LOOKUP(STRING(crapadp.idstaeve),craptab.dstextab) - 1,craptab.dstextab).

                       IF   aux_idstaeve = ?   THEN
                            aux_idstaeve = "".
                      
                       ASSIGN aux_dados = "~{" +
                                          "cdagenci:'" +  TRIM(STRING(crapadp.cdagenci)) + "'," + 
                                          "cdcooper:'" +  TRIM(STRING(crapadp.cdcooper)) + "'," +
                                          "cdevento:'" +  TRIM(STRING(crapadp.cdevento)) + "'," +
                                          "nrseqeve:'" +  TRIM(STRING(crapadp.nrseqdig)) + "'," +
                                          "nmevento:'" +  TRIM(STRING(aux_nmevento))     + "'," +
                                          "tpevento:'" +  TRIM(STRING(aux_tpevento))     + "'," +
                                          "nmresage:'" +  TRIM(STRING(aux_nmresage))     + "'," +
                                          "idpropos:'" +  TRIM(STRING(aux_idpropos))     + "'," +
                                          "dtevento:'" +  TRIM(STRING(aux_dtevento))     + "'," +
                                          "dslocali:'" +  TRIM(STRING(aux_dslocali))     + "'," +
                                          "dshroeve:'" +  TRIM(crapadp.dshroeve)         + "'," +
                                          "qtmaxtur:'" +  TRIM(STRING(aux_qtmaxtur))     + "'," +
                                          "nrinscri:'" +  TRIM(STRING(aux_nrinscri))     + "'," +
                                          "idstaeve:'" +  TRIM(STRING(aux_idstaeve))     + "'," +
                                          "enlocali:'" +  TRIM(STRING(aux_enlocali))     + "'," +
                                          "nrconfir:'" +  TRIM(STRING(aux_nrconfir))     + "'," +
                                          "nrdrowid:'" +  STRING(ROWID(crapadp))         + "'"  + "~}".        
                       
                       IF  vetorevento = '' THEN
                           vetorevento = aux_dados.
                       ELSE
                           vetorevento = vetorevento + ',' + aux_dados.
                     END.
                     ELSE DO:
                       ASSIGN aux_qtregist = aux_qtregist - 1.
                     END.
                 END.
         END.

    CLOSE QUERY q_crapadp.

    RUN RodaJavaScript("var mevento=new Array(" + vetorevento + ");"). 

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaPac w-html 
PROCEDURE CriaListaPac :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEF VAR aux_cdagenci AS CHAR NO-UNDO.

    /* Progrid - Agrupa os PAs */
    IF  INT(ab_unmap.aux_idevento) = 1   THEN
        DO: 
           /* PA TODOS */        
           aux_cdagenci = "--Selecione PA--,0,Todos os PAS,-1".
           
           { includes/wpgd0200.i ab_unmap.aux_dtanoage }
        END.
    /* Assembleias - N�o Agrupa os PAs */
    ELSE 
        DO: 
           /* PA TODOS */        
           aux_cdagenci = "--Selecione PA--,0,Todos os PAS,-1".
           
           { includes/wpgd0201.i ab_unmap.aux_dtanoage }
           
        END.
    
    ab_unmap.aux_cdagenci:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_cdagenci.
 
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
    ("aux_cdagenci":U,"ab_unmap.aux_cdagenci":U,ab_unmap.aux_cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcooper":U,"ab_unmap.aux_cdcooper":U,ab_unmap.aux_cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdevento_pa":U,"ab_unmap.aux_cdevento_pa":U,ab_unmap.aux_cdevento_pa:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrseqtem":U,"ab_unmap.aux_nrseqtem":U,ab_unmap.aux_nrseqtem:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdeixtem":U,"ab_unmap.aux_cdeixtem":U,ab_unmap.aux_cdeixtem:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrcpfcgc":U,"ab_unmap.aux_nrcpfcgc":U,ab_unmap.aux_nrcpfcgc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_tpevento":U,"ab_unmap.aux_tpevento":U,ab_unmap.aux_tpevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtinieve":U,"ab_unmap.aux_dtinieve":U,ab_unmap.aux_dtinieve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtfineve":U,"ab_unmap.aux_dtfineve":U,ab_unmap.aux_dtfineve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cddopcao":U,"ab_unmap.aux_cddopcao":U,ab_unmap.aux_cddopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdevento":U,"ab_unmap.aux_cdevento":U,ab_unmap.aux_cdevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsretorn":U,"ab_unmap.aux_dsretorn":U,ab_unmap.aux_dsretorn:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtanoage":U,"ab_unmap.aux_dtanoage":U,ab_unmap.aux_dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdagenci":U,"ab_unmap.cdagenci":U,ab_unmap.cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdevento":U,"ab_unmap.cdevento":U,ab_unmap.cdevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dtanoage":U,"crapeap.dtanoage":U,crapeap.dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("pagina":U,"ab_unmap.pagina":U,ab_unmap.pagina:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_carregar":U,"ab_unmap.aux_carregar":U,ab_unmap.aux_carregar:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_reginils":U,"ab_unmap.aux_reginils":U,ab_unmap.aux_reginils:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_regfimls":U,"ab_unmap.aux_regfimls":U,ab_unmap.aux_regfimls:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_contarow":U,"ab_unmap.aux_contarow":U,ab_unmap.aux_contarow:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_maxrows":U,"ab_unmap.aux_maxrows":U,ab_unmap.aux_maxrows:HANDLE IN FRAME {&FRAME-NAME}).

END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
DEFINE INPUT PARAMETER opcao AS CHARACTER.
    
    /*/* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0026.p PERSISTENT SET h-b1wpgd0026.
    
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0026) THEN
       DO:
          DO WITH FRAME {&FRAME-NAME}:
             IF opcao = "inclusao" THEN
                DO: 
                    CREATE crateap.
                    ASSIGN crateap.campo = INPUT crapeap.campo.
    
                    RUN inclui-registro IN h-b1wpgd0026(INPUT TABLE crateap, OUTPUT msg-erro, OUTPUT ab_unmap.aux_nrdrowid).
                END.
             ELSE  /* alteracao */
                DO:
                    /* cria a temp-table e joga o novo valor digitado para o campo */
                    CREATE crateap.
                    BUFFER-COPY crapeap EXCEPT crapeap.campox TO crateap.
    
                    ASSIGN crateap.campo = INPUT crapeap.campo.
                     
                    RUN altera-registro IN h-b1wpgd0026(INPUT TABLE crateap, OUTPUT msg-erro).
                END.    
          END. /* DO WITH FRAME {&FRAME-NAME} */
       
          /* "mata" a inst�ncia da BO */
          DELETE PROCEDURE h-b1wpgd0026 NO-ERROR.
       
       END. /* IF VALID-HANDLE(h-b1wpgd0026) */*/
      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
/*
    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0026.p PERSISTENT SET h-b1wpgd0026.
     
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0026) THEN
       DO:
          CREATE crateap.
          BUFFER-COPY crapeap TO crateap.
              
          RUN exclui-registro IN h-b1wpgd0026(INPUT TABLE crateap, OUTPUT msg-erro).
    
          /* "mata" a inst�ncia da BO */
          DELETE PROCEDURE h-b1wpgd0026 NO-ERROR.
       END.
    */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-display-fields w-html 
PROCEDURE local-display-fields :
RUN displayFields.

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

  output-content-type ("text/html":U).
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PermissaoDeAcesso w-html 
PROCEDURE PermissaoDeAcesso :
{includes/wpgd0009.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoAnterior w-html 
PROCEDURE PosicionaNoAnterior :
/* O pre-processador {&SECOND-ENABLED-TABLE} tem como valor, o nome da tabela usada */

FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
   DO:
       FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

       IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
           DO:
               ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE})).

               FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

               IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN ab_unmap.aux_stdopcao = "".
               ELSE
                   ASSIGN ab_unmap.aux_stdopcao = "".

               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
           END.
       ELSE
           DO:
               RUN RodaJavaScript("alert('Este j� � o primeiro registro.')"). 
               
               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

               IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN ab_unmap.aux_stdopcao = "".
               ELSE
                   ASSIGN ab_unmap.aux_stdopcao = "?".

           END.
   END.
ELSE 
   RUN PosicionaNoPrimeiro.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoPrimeiro w-html 
PROCEDURE PosicionaNoPrimeiro :
FIND FIRST {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.


IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
    ASSIGN ab_unmap.aux_nrdrowid  = "?"
           ab_unmap.aux_stdopcao = "".
ELSE
    ASSIGN ab_unmap.aux_nrdrowid  = STRING(ROWID({&SECOND-ENABLED-TABLE}))
           ab_unmap.aux_stdopcao = "".  /* aqui p */

/* N�o traz inicialmente nenhum registro */ 
RELEASE {&SECOND-ENABLED-TABLE}.

ASSIGN ab_unmap.aux_nrdrowid  = "?"
       ab_unmap.aux_stdopcao = "".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoSeguinte w-html 
PROCEDURE PosicionaNoSeguinte :
FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.


IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
    DO:
       FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

       IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
           DO:
               ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE})).

               FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

               IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN ab_unmap.aux_stdopcao = "".
               ELSE
                   ASSIGN ab_unmap.aux_stdopcao = "".

               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
           END.
       ELSE
           DO:
               RUN RodaJavaScript("alert('Este j� � o �ltimo registro.')").

               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

               IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN ab_unmap.aux_stdopcao = "".
               ELSE
                   ASSIGN ab_unmap.aux_stdopcao = "?".
           END.
    END.
ELSE
    RUN PosicionaNoUltimo.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoUltimo w-html 
PROCEDURE PosicionaNoUltimo :
FIND LAST {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
    ASSIGN ab_unmap.aux_nrdrowid = "?".
ELSE
    ASSIGN ab_unmap.aux_nrdrowid  = STRING(ROWID({&SECOND-ENABLED-TABLE}))
           ab_unmap.aux_stdopcao = "".   /* aqui u */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-web-request w-html 
PROCEDURE process-web-request :
/*------------------------------------------------------------------------------
   Tipo: Procedure interna
   Nome: includes/webreq.i - Vers�o WebSpeed 2.1
  Autor: B&T/Solusoft
 Fun��o: Processo de requisi��o web p/ cadastros simples na web - Vers�o WebSpeed 3.0
  Notas: Este � o procedimento principal onde ter� as requisi��es GET e POST.
         GET - � ativa quando o formul�rio � chamado pela 1a vez
         POST - Ap�s o get somente ocorrer� POST no formul�rio      
         Caso seja necess�rio custimiz�-lo para algum programa espec�fico 
         Favor c�piar este procedimento para dentro do procedure process-web-requeste 
         fa�a l� altera��es necess�rias.
-------------------------------------------------------------------------------*/

v-identificacao = get-cookie("cookie-usuario-em-uso").

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + v-identificacao + "*" NO-LOCK:
    LEAVE.
END.

ASSIGN opcao                    = GET-FIELD("aux_cddopcao")
       FlagPermissoes           = GET-VALUE("aux_lspermis")
       msg-erro-aux             = 0
       ab_unmap.aux_idevento    = GET-VALUE("aux_idevento")
       ab_unmap.aux_dsendurl    = AppURL                        
       ab_unmap.aux_lspermis    = FlagPermissoes                
       ab_unmap.aux_nrdrowid    = GET-VALUE("aux_nrdrowid")         
       ab_unmap.aux_stdopcao    = GET-VALUE("aux_stdopcao")
       ab_unmap.cdagenci        = GET-VALUE("cdagenci")
       ab_unmap.cdevento        = GET-VALUE("cdevento")
       ab_unmap.pagina          = GET-VALUE("pagina")
       ab_unmap.aux_cdcooper    = GET-VALUE("aux_cdcooper")
       ab_unmap.aux_cdevento_pa = GET-VALUE("aux_cdevento_pa")
       ab_unmap.aux_cdevento    = GET-VALUE("aux_cdevento")
       ab_unmap.aux_nrseqtem    = GET-VALUE("aux_nrseqtem")
       ab_unmap.aux_cdeixtem    = GET-VALUE("aux_cdeixtem")
       ab_unmap.aux_nrcpfcgc    = GET-VALUE("aux_nrcpfcgc")
       ab_unmap.aux_tpevento    = GET-VALUE("aux_tpevento")
       ab_unmap.aux_dtinieve    = GET-VALUE("aux_dtinieve")
       ab_unmap.aux_dtfineve    = GET-VALUE("aux_dtfineve")
       ab_unmap.aux_cdagenci    = GET-VALUE("aux_cdagenci")
       ab_unmap.aux_dtanoage    = GET-VALUE("aux_dtanoage")
       ab_unmap.aux_carregar    = GET-VALUE("aux_carregar")
       ab_unmap.aux_reginils    = GET-VALUE("aux_reginils")
       ab_unmap.aux_regfimls    = GET-VALUE("aux_regfimls")
       ab_unmap.aux_contarow    = INT(GET-VALUE("aux_contarow"))
       ab_unmap.aux_maxrows     = INT(GET-VALUE("aux_maxrows")).

RUN outputHeader.

{includes/wpgd0098.i}

ab_unmap.aux_cdcooper:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapcop.

/* Se a cooperativa ainda n�o foi escolhida, pega a da sess�o do usu�rio */
IF   INT(ab_unmap.aux_cdcooper) = 0   THEN
     ab_unmap.aux_cdcooper = STRING(gnapses.cdcooper).


/* Posiciona por default, na agenda atual */
IF   ab_unmap.aux_dtanoage = ""   THEN
     FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                             gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper) AND 
                             gnpapgd.dtanoage = INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR.
ELSE
     /* Se informou a data da agenda, permite que veja a agenda de um ano n�o atual */
     FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                             gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper) AND 
                             gnpapgd.dtanonov = INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR.

IF NOT AVAILABLE gnpapgd THEN
   DO:
      IF   ab_unmap.aux_dtanoage <> ""   THEN
           DO:
               RUN RodaJavaScript("alert('Nao existe agenda para o ano (" + ab_unmap.aux_dtanoage + ") informado!');").
               opcao = "".
           END.

      FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                              gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR.

   END.

IF AVAILABLE gnpapgd THEN
   DO:
       IF   ab_unmap.aux_dtanoage = ""   THEN
            ab_unmap.aux_dtanoage = STRING(gnpapgd.dtanoage).
       ELSE
            ab_unmap.aux_dtanoage = STRING(gnpapgd.dtanonov).
   END.
ELSE
   ASSIGN ab_unmap.aux_dtanoage = "".

/*******/   
RUN CriaListaPac.

/* m�todo POST */
IF REQUEST_METHOD = "POST":U THEN 
   DO:
          RUN inputFields.

      CASE opcao:
           WHEN "sa" THEN /* salvar */
                DO:
                    IF ab_unmap.aux_stdopcao = "i" THEN /* inclusao */
                        DO:
                            RUN local-assign-record ("inclusao"). 
                            IF msg-erro <> "" THEN
                               ASSIGN msg-erro-aux = 3. /* erros da valida��o de dados */
                            ELSE 
                            DO:
                               ASSIGN 
                                   msg-erro-aux = 10
                                   ab_unmap.aux_stdopcao = "al".
                               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

                               IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                  IF LOCKED {&SECOND-ENABLED-TABLE} THEN
                                     DO:
                                         ASSIGN msg-erro-aux = 1. /* registro em uso por outro usu�rio */  
                                         FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                     END.
                                  ELSE
                                     DO: 
                                         ASSIGN msg-erro-aux = 2. /* registro n�o existe */
                                         RUN PosicionaNoSeguinte.
                                     END.

                            END.
                        END.  /* fim inclusao */
                    ELSE     /* altera��o */ 
                        DO: 
                            FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

                            IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                               IF LOCKED {&SECOND-ENABLED-TABLE} THEN
                                  DO:
                                      ASSIGN msg-erro-aux = 1. /* registro em uso por outro usu�rio */  
                                      FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                  END.
                               ELSE
                                  DO: 
                                      ASSIGN msg-erro-aux = 2. /* registro n�o existe */
                                      RUN PosicionaNoSeguinte.
                                  END.
                            ELSE
                               DO:
                                  RUN local-assign-record ("alteracao").  
                                  IF msg-erro = "" THEN
                                     ASSIGN msg-erro-aux = 10. /* Solicita��o realizada com sucesso */ 
                                  ELSE
                                     ASSIGN msg-erro-aux = 3. /* erros da valida��o de dados */
                               END.     
                        END. /* fim altera��o */
                END. /* fim salvar */

           WHEN "in" THEN /* inclusao */
                DO:
                    IF ab_unmap.aux_stdopcao <> "i" THEN
                       DO:
                          CLEAR FRAME {&FRAME-NAME}.
                          ASSIGN ab_unmap.aux_stdopcao = "i".
                       END.
                END. /* fim inclusao */

           WHEN "ex" THEN /* exclusao */
                DO:
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

                    /* busca o pr�ximo registro para fazer o reposicionamento */
                    FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

                    IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                       ASSIGN aux_nrdrowid-auxiliar = STRING(ROWID({&SECOND-ENABLED-TABLE})).
                    ELSE
                       DO:
                           /* nao encontrou pr�ximo registro ent�o procura pelo registro anterior para o reposicionamento */
                           FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                           
                           FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

                           IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                              ASSIGN aux_nrdrowid-auxiliar = STRING(ROWID({&SECOND-ENABLED-TABLE})).
                           ELSE
                              ASSIGN aux_nrdrowid-auxiliar = "?".
                       END.          
                       
                    /*** PROCURA TABELA PARA VALIDAR -> COM NO-LOCK ***/
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                    
                    /*** PROCURA TABELA PARA EXCLUIR -> COM EXCLUSIVE-LOCK ***/
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                    
                    IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                       IF LOCKED {&SECOND-ENABLED-TABLE} THEN
                          DO:
                              ASSIGN msg-erro-aux = 1. /* registro em uso por outro usu�rio */ 
                              FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                          END.
                       ELSE
                          ASSIGN msg-erro-aux = 2. /* registro n�o existe */
                    ELSE
                       DO:
                          IF msg-erro = "" THEN
                             DO:
                                RUN local-delete-record.
                                DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
                                   ASSIGN msg-erro = msg-erro + ERROR-STATUS:GET-MESSAGE(i).
                                END.    

                                IF msg-erro = " " THEN
                                   DO:
                                       IF aux_nrdrowid-auxiliar = "?" THEN
                                          RUN PosicionaNoPrimeiro.
                                       ELSE
                                          DO:
                                              ASSIGN ab_unmap.aux_nrdrowid = aux_nrdrowid-auxiliar.
                                              FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                              
                                              IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                                 RUN PosicionaNoSeguinte.
                                          END.   
                                          
                                       ASSIGN msg-erro-aux = 10. /* Solicita��o realizada com sucesso */ 
                                   END.
                                ELSE
                                   ASSIGN msg-erro-aux = 3. /* Exclusao rejeitada */ 
                             END.
                          ELSE
                             ASSIGN msg-erro-aux = 3. /* erros da valida��o de dados */
                       END.  
                END. /* fim exclusao */

           WHEN "pe" THEN /* pesquisar */
                DO:   
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                    IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN 
                       RUN PosicionaNoSeguinte.
                END. /* fim pesquisar */

           WHEN "li" THEN /* listar */
                DO:
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                    IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN 
                       RUN PosicionaNoSeguinte.
                END. /* fim listar */

           WHEN "pr" THEN /* primeiro */
                RUN PosicionaNoPrimeiro.
      
           WHEN "ul" THEN /* ultimo */
                RUN PosicionaNoUltimo.
      
           WHEN "an" THEN /* anterior */
                RUN PosicionaNoAnterior.
      
           WHEN "se" THEN /* seguinte */
                RUN PosicionaNoSeguinte.
    
      END CASE.

      RUN CriaListaEvCoop.

      RUN CriaListaEventos. 
      
      IF msg-erro-aux = 10 OR (opcao <> "sa" AND opcao <> "ex" AND opcao <> "in") THEN
         RUN displayFields.
 
      RUN enableFields.
      RUN outputFields.

      CASE msg-erro-aux:
           WHEN 1 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = 'Registro esta em uso por outro usu�rio. Solicita��o n�o pode ser executada. Espere alguns instantes e tente novamente.'.

                    RUN RodaJavaScript(' top.frames[0].MostraResultado(' + STRING(v-qtdeerro) + ',"'+ v-descricaoerro + '"); ').
                END.

           WHEN 2 THEN
                RUN RodaJavaScript(" top.frames[0].MostraMsg('Registro foi exclu�do. Solicita��o n�o pode ser executada.')").
      
           WHEN 3 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = msg-erro.

                    RUN RodaJavaScript('top.frames[0].MostraResultado(' + STRING(v-qtdeerro) + ',"'+ v-descricaoerro + '"); ').
                END.

           WHEN 4 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = m-erros.

                    RUN RodaJavaScript('top.frames[0].MostraResultado(' + STRING(v-qtdeerro) + ',"'+ v-descricaoerro + '"); ').
                END.

           WHEN 10 THEN
                RUN RodaJavaScript('alert("Atualizacao executada com sucesso.")'). 
         
      END CASE.
/*
      IF ab_unmap.pagina = "divConfirma" THEN
          RUN RodaJavaScript('PosicionaEve()').   
      ELSE
          RUN RodaJavaScript('PosicionaPAC()').
*/
   END. /* Fim do m�todo POST */
ELSE /* M�todo GET */ 
   DO:
      
      RUN PermissaoDeAcesso(INPUT ProgramaEmUso, OUTPUT IdentificacaoDaSessao, OUTPUT ab_unmap.aux_lspermis).
      
      CASE ab_unmap.aux_lspermis:
           WHEN "1" THEN /* get-cookie em usuario-em-uso voltou valor nulo */
                RUN RodaJavaScript('top.close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').

           WHEN "2" THEN /* identificacao vinda do cookie bao existe na tabela de log de sessao */ 
                DO: 
                    DELETE-COOKIE("cookie-usuario-em-uso",?,?).
                    RUN RodaJavaScript('top.close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').
                END.
  
           WHEN "3" THEN /* usuario nao tem permissao para acessa o programa */
                RUN RodaJavaScript('window.location.href = "' + ab_unmap.aux_dsendurl + '/gerenciador/negado"').
          
           OTHERWISE
                DO:
                    IF GET-VALUE("LinkRowid") <> "" THEN
                       DO:
                           FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(GET-VALUE("LinkRowid")) NO-LOCK NO-WAIT NO-ERROR.
                           
                           IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                              DO:
                                  ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE}))
                                         ab_unmap.aux_idevento = STRING({&SECOND-ENABLED-TABLE}.idevento).

                                  FIND NEXT {&SECOND-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.

                                  IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                     ASSIGN ab_unmap.aux_stdopcao = "u".
                                  ELSE
                                     DO:
                                         FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                         
                                         FIND PREV {&SECOND-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.

                                         IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                            ASSIGN ab_unmap.aux_stdopcao = "p".        
                                         ELSE
                                            ASSIGN ab_unmap.aux_stdopcao = "?".
                                     END.

                                  FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                              END.  
                           ELSE
                              ASSIGN ab_unmap.aux_nrdrowid = "?"
                                     ab_unmap.aux_stdopcao = "?".
                       END.  
                    ELSE                    
                       RUN PosicionaNoPrimeiro.
                    
                    RUN CriaListaEvCoop.                                        
                    RUN CriaListaEventos.
                    RUN displayFields.
                    RUN enableFields.
                    RUN outputFields.


                  /*  RUN RodaJavaScript('top.frcod.FechaZoom()').*/
                    RUN RodaJavaScript('CarregaPrincipal()').
                    
                    IF GET-VALUE("LinkRowid") = "" THEN
                       DO:
                      /*  RUN RodaJavaScript('document.form.aux_cdcooper.value="";'). */
                        
                        /*   RUN RodaJavaScript('LimparCampos();').
                           RUN RodaJavaScript('top.frcod.Incluir();').*/
                       END.
                END. /* fim otherwise */                  
      END CASE. 
      
END. /* fim do m�todo GET */

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RodaJavaScript w-html 
PROCEDURE RodaJavaScript :
{includes/rodajava.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

