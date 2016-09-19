/*-----------------------------------------------------------------------------
    
    Ultima Alteracao : 20/10/2008.

    Alteracoes: 20/10/2008 - Chamar BO que envia e-mails na procedure envia-email (Gabriel).

                10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
                
                04/05/2009 - Utilizar cdcooper = 0 nas consultas (David).
				
				05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
						     busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
                
-----------------------------------------------------------------------------*/


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
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lscuseve AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lsfselec AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_qtdevent AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_qtintegr AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_salcusto AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_vlcuseve AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_vlintegr AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_vlprogri AS CHARACTER FORMAT "X(256)":U 
       FIELD cdagenci AS CHARACTER FORMAT "X(256)":U .


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
DEFINE VARIABLE ProgramaEmUso         AS CHARACTER INITIAL ["wpgd0020"].
DEFINE VARIABLE NmeDoPrograma         AS CHARACTER INITIAL ["wpgd0020.w"].

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

/*** Declaração de BOs ***/
DEFINE VARIABLE h-b1wpgd0020          AS HANDLE                         NO-UNDO.
DEFINE VARIABLE h-b1wpgd0021a         AS HANDLE                         NO-UNDO.
DEFINE VARIABLE b1wgen0011            AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE crateap             LIKE crapeap.
DEFINE TEMP-TABLE cratagp             LIKE crapagp.

DEFINE VARIABLE aux_crapcop           AS CHAR                           NO-UNDO.
DEFINE VARIABLE aux_qttoteve          AS INTEGER                        NO-UNDO.

DEFINE VARIABLE vetorpac              AS CHAR                           NO-UNDO.
DEFINE VARIABLE vetorevento           AS CHAR                           NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0020.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS 
&Scoped-define ENABLED-TABLES ab_unmap crapeap
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapeap
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_qtintegr ab_unmap.aux_vlintegr ab_unmap.aux_lscuseve ab_unmap.aux_lsfselec ab_unmap.aux_dtanoage ab_unmap.cdagenci ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_idevento ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ab_unmap.aux_qtdevent ab_unmap.aux_salcusto ab_unmap.aux_stdopcao ab_unmap.aux_vlcuseve ab_unmap.aux_vlprogri 
&Scoped-Define DISPLAYED-FIELDS 
&Scoped-define DISPLAYED-TABLES ab_unmap crapeap
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapeap
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_qtintegr ab_unmap.aux_vlintegr ab_unmap.aux_lscuseve ab_unmap.aux_lsfselec ab_unmap.aux_dtanoage ab_unmap.cdagenci ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_idevento ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ab_unmap.aux_qtdevent ab_unmap.aux_salcusto ab_unmap.aux_stdopcao ab_unmap.aux_vlcuseve ab_unmap.aux_vlprogri 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.aux_qtintegr AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_vlintegr AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lscuseve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lsfselec AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dtanoage AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.cdagenci AT ROW 1 COL 1 HELP
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
     ab_unmap.aux_qtdevent AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_salcusto AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_stdopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_vlcuseve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_vlprogri AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 71.4 BY 24.71.


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
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lscuseve AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lsfselec AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_qtdevent AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_qtintegr AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_salcusto AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_vlcuseve AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_vlintegr AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_vlprogri AS CHARACTER FORMAT "X(256)":U 
          FIELD cdagenci AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 24.71
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
/* SETTINGS FOR FILL-IN ab_unmap.aux_cddopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsretorn IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dtanoage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lscuseve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lsfselec IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_qtdevent IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_qtintegr IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_salcusto IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_vlcuseve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_vlintegr IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_vlprogri IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.cdagenci IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapeap.dtanoage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEventos w-html 
PROCEDURE CriaListaEventos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF VAR aux_tpevento AS CHAR NO-UNDO.
    DEF VAR aux_vlcuseve AS DEC  NO-UNDO.
    DEF VAR aux_vlcustot AS DEC  NO-UNDO.
    DEF VAR aux_qtcarhor AS CHAR NO-UNDO.
    DEF VAR aux_flgevobr AS CHAR NO-UNDO.
    DEF VAR aux_flgevsel AS CHAR NO-UNDO.
    DEF VAR aux_vlverbap AS CHAR NO-UNDO.
    DEF VAR aux_qtpreeve AS CHAR NO-UNDO.
    DEF VAR aux_flgcusfe AS CHAR NO-UNDO.
    DEF VAR vlintegr     AS DEC  NO-UNDO.
    DEF VAR qtintegr     AS CHAR NO-UNDO.
    
    DEFINE BUFFER bf-craptab FOR craptab.
    
    FOR EACH crapeap WHERE crapeap.dtanoage = INT(ab_unmap.aux_dtanoage)    AND
                           crapeap.idevento = INT(ab_unmap.aux_idevento)    AND
                           crapeap.cdcooper = INT(ab_unmap.aux_cdcooper)    AND
                           crapeap.cdagenci = INT(ab_unmap.cdagenci)        NO-LOCK:
    
        FIND FIRST crapagp WHERE crapagp.idevento = crapeap.idevento    AND
                                 crapagp.cdcooper = crapeap.cdcooper    AND
                                 crapagp.dtanoage = crapeap.dtanoage    AND
                                 crapagp.cdagenci = crapeap.cdagenci    NO-LOCK NO-ERROR.
    
        IF NOT AVAIL crapagp THEN NEXT.
        
        FIND FIRST crapedp WHERE crapedp.cdevento = crapeap.cdevento    AND
                                 crapedp.cdcooper = crapeap.cdcooper    AND
                                 crapedp.dtanoage = crapeap.dtanoage    AND
                                 crapedp.idevento = crapeap.idevento    NO-LOCK NO-ERROR.
    
        IF NOT AVAIL crapedp THEN NEXT.
    
        FIND FIRST gnapetp WHERE gnapetp.cdcooper = 0                AND
                                 gnapetp.cdeixtem = crapedp.cdeixtem NO-LOCK NO-ERROR.
    
        IF NOT AVAIL gnapetp THEN NEXT.
    
        FIND FIRST bf-craptab WHERE bf-craptab.cdcooper = 0             AND
                                    bf-craptab.nmsistem = "CRED"        AND
                                    bf-craptab.tptabela = "CONFIG"      AND
                                    bf-craptab.cdempres = 0             AND
                                    bf-craptab.cdacesso = "PGTPEVENTO"  AND
                                    bf-craptab.tpregist = 0             NO-LOCK NO-ERROR.
    
        IF AVAILABLE bf-craptab THEN
           ASSIGN aux_tpevento = ENTRY(LOOKUP(STRING(crapedp.tpevento), bf-craptab.dstextab) - 1, bf-craptab.dstextab).
    
        aux_flgevsel = IF crapeap.flgevsel THEN "checked" ELSE "".
        
        IF crapedp.flgtdpac THEN 
            ASSIGN aux_flgevobr = "disabled"
                   aux_flgevsel = "checked".
        ELSE 
            aux_flgevobr = "".
    
        FIND FIRST crapvdp WHERE crapvdp.idevento = crapeap.idevento    AND
                                 crapvdp.cdcooper = crapeap.cdcooper    AND
                                 crapvdp.cdagenci = crapeap.cdagenci    AND
                                 crapvdp.dtanoage = crapeap.dtanoage    NO-LOCK NO-ERROR.
    
        IF AVAIL crapvdp THEN
            aux_vlverbap = string(crapvdp.vlverbat).
        ELSE
            aux_vlverbap = "0,00".
    
    
        FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento)   AND
                                gnpapgd.cdcooper = crapeap.cdcooper             AND
                                gnpapgd.dtanonov = crapeap.dtanoage             NO-LOCK NO-ERROR.
    
        IF AVAIL gnpapgd THEN
            aux_qtpreeve = STRING(gnpapgd.qtpreeve).
        ELSE
            aux_qtpreeve = "0".
    
        /* Quantidade de integrações - é por cooperativa */
        IF AVAIL gnpapgd THEN
            ASSIGN qtintegr = STRING(gnpapgd.qtpreint).
        ELSE
            ASSIGN qtintegr = "0".
        
        aux_vlcuseve = 0.
        aux_qtcarhor = "0:00".
    
        /* usa os custos de todos os PACs agrupados */
        /*FOR EACH crapagp NO-LOCK WHERE
            crapagp.cdcooper = crapeap.cdcooper AND
            crapagp.idevento = crapeap.idevento:*/
        
    
        FOR EACH crapcdp WHERE crapcdp.idevento = crapeap.idevento  AND
                               crapcdp.cdcooper = crapeap.cdcooper  AND
                               crapcdp.cdagenci = crapeap.cdagenci  AND
                               crapcdp.dtanoage = crapeap.dtanoage  AND
                               crapcdp.tpcuseve = 1                 AND /* somente custos DIRETOS */
                               crapcdp.cdevento = crapeap.cdevento  NO-LOCK:
    
            /* Em honorários é que está gravado o fornecedor, e se tiver, a proposta */
            IF crapcdp.cdcuseve = 1 THEN
            DO:
                FIND FIRST gnappdp WHERE gnappdp.cdcooper = 0                   AND
                                         gnappdp.nrcpfcgc = crapcdp.nrcpfcgc    AND
                                         gnappdp.nrpropos = crapcdp.nrpropos    NO-LOCK NO-ERROR.
    
                IF AVAIL gnappdp THEN
                    aux_qtcarhor = string(gnappdp.qtcarhor, ">>>,>>9.99").
                ELSE
                    aux_qtcarhor = "0:00".
            END.
    
            ASSIGN aux_vlcuseve = aux_vlcuseve + crapcdp.vlcuseve.
    
            IF crapeap.flgevobr OR crapeap.flgevsel THEN
                ASSIGN aux_vlcustot = aux_vlcustot + crapcdp.vlcuseve.
    
        END.
        /* verifica a qtde de sugestoes de cada evento */
    
        ASSIGN aux_qttoteve = 0.
        FOR EACH crapsdp WHERE crapsdp.idevento = crapeap.idevento                AND
                               crapsdp.cdevento = crapeap.cdevento                AND
                               crapsdp.dtanoage = ?                               AND
                               crapsdp.cdcooper = crapeap.cdcooper                AND
                              (crapsdp.cdagenci = crapeap.cdagenci                OR
                               /* sugestoes comuns a todos os PAC'S */
                               crapsdp.cdagenci = 0)                              /*AND
                               crapsdp.flgsugca = NO    */                         NO-LOCK
                               BREAK BY crapsdp.cdevento:
                                     
            aux_qttoteve = aux_qttoteve + crapsdp.qtsugeve.
         
        END.
        /*END.*/
        
        /* Usa os PACs agrupados */
        ASSIGN aux_flgcusfe = "".
        /* Bloqueia as Flags, se o status da agenda não for 1 */
        IF crapagp.idstagen < 1 THEN
            ASSIGN aux_flgevobr = "disabled"
                   aux_flgcusfe = "1". /* nao está pronto */
        ELSE
        IF crapagp.idstagen > 1 THEN
            ASSIGN aux_flgevobr = "disabled"
                   aux_flgcusfe = "2". /* ja foi fechado*/

        IF  vetorevento = "" THEN DO:
            vetorevento = "~{" +
                          "cdagenci:'" +         STRING(crapeap.cdagenci)            + "'," + 
                          "cdcooper:'" +         STRING(crapeap.cdcooper)            + "'," +
                          "cdevento:'" +         STRING(crapeap.cdevento)            + "'," +
                          "nmevento:'" +         STRING(crapedp.nmevento)            + "'," +
                          "tpevento:'" +         STRING(aux_tpevento)                + "'," +
                          "dseixtem:'" +         STRING(gnapetp.dseixtem)            + "'," +
                          "dtanoage:'" +         STRING(crapeap.dtanoage)            + "'," +
                          "flgevobr:'" +         STRING(aux_flgevobr)                + "'," +
                          "flgevsel:'" +         STRING(aux_flgevsel)                + "'," +
                          "vlcuseve:'" +         STRING(aux_vlcuseve, "->>>,>>9.99") + "'," +
                          "qtcarhor:'" + REPLACE(STRING(aux_qtcarhor), ",", ":")     + "'," +
                          "vlverbap:'" +         STRING(aux_vlverbap)                + "'," +
                          "qtpreeve:'" +         STRING(aux_qtpreeve)                + "'," +
                          "flgcusfe:'" +         STRING(aux_flgcusfe)                + "'," +
                          "qtintegr:'" +         STRING(qtintegr)                    + "'," +
                          "ctevento:'" +         STRING(crapedp.tpevento)            + "'," +
                          "idevento:'" +         STRING(crapeap.idevento)            + "'," + 
                          "qttoteve:'" +         STRING(aux_qttoteve)                + "'"  + 
                          "~}".
        END.
        ELSE 
            vetorevento = vetorevento + ",~{" +
                          "cdagenci:'" +         STRING(crapeap.cdagenci)            + "'," + 
                          "cdcooper:'" +         STRING(crapeap.cdcooper)            + "'," +
                          "cdevento:'" +         STRING(crapeap.cdevento)            + "'," +
                          "nmevento:'" +         STRING(crapedp.nmevento)            + "'," +
                          "tpevento:'" +         STRING(aux_tpevento)                + "'," +
                          "dseixtem:'" +         STRING(gnapetp.dseixtem)            + "'," +
                          "dtanoage:'" +         STRING(crapeap.dtanoage)            + "'," +
                          "flgevobr:'" +         STRING(aux_flgevobr)                + "'," +
                          "flgevsel:'" +         STRING(aux_flgevsel)                + "'," +
                          "vlcuseve:'" +         STRING(aux_vlcuseve, "->>>,>>9.99") + "'," +
                          "qtcarhor:'" + REPLACE(STRING(aux_qtcarhor), ",", ":")     + "'," +
                          "vlverbap:'" +         STRING(aux_vlverbap)                + "'," +
                          "qtpreeve:'" +         STRING(aux_qtpreeve)                + "'," +
                          "flgcusfe:'" +         STRING(aux_flgcusfe)                + "'," +
                          "qtintegr:'" +         STRING(qtintegr)                    + "'," +
                          "ctevento:'" +         STRING(crapedp.tpevento)            + "'," +
                          "idevento:'" +         STRING(crapeap.idevento)            + "'," + 
                          "qttoteve:'" +         string(aux_qttoteve)                + "'"  + 
                          "~}".
    
    END.
    RUN RodaJavaScript("var mevento=new Array();mevento=["  + vetorevento + "]"). 

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

    {includes/wpgd0099.i ab_unmap.aux_dtanoage}
    
    RUN RodaJavaScript("var mpac=new Array();mpac=["  + vetorpac + "]"). 
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Encerra w-html 
PROCEDURE Encerra :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    FOR EACH crapagp WHERE crapagp.idevento = INT(ab_unmap.aux_idevento)    AND
                           crapagp.cdcooper = INT(ab_unmap.aux_cdcooper)    AND
                           crapagp.dtanoage = INT(ab_unmap.aux_dtanoage)    AND
                           crapagp.cdageagr = INT(ab_unmap.cdagenci)        NO-LOCK:
                                                                            
        /* Instancia a BO para executar as procedures */
        RUN dbo/b1wpgd0021a.p PERSISTENT SET h-b1wpgd0021a.
    
        /* Se BO foi instanciada */
        IF VALID-HANDLE(h-b1wpgd0021a) THEN
        DO:
           FOR EACH cratagp:
               DELETE cratagp.
           END.
    
           CREATE cratagp.
           BUFFER-COPY crapagp EXCEPT crapagp.idstagen TO cratagp.
           ASSIGN cratagp.idstagen = 2.
    
           RUN altera-registro IN h-b1wpgd0021a(INPUT TABLE cratagp, OUTPUT msg-erro).
           IF msg-erro <> "" THEN
              ASSIGN msg-erro-aux = 3.
           ELSE
              ASSIGN msg-erro-aux = 10.
    
           /* "mata" a instância da BO */
           DELETE PROCEDURE h-b1wpgd0021a NO-ERROR.
           RUN envia-email.
        END.
            
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE envia-email w-html 

PROCEDURE envia-email :

/*------------------------------------------------------------------------------
  
  Purpose:     
  Parameters:  <none>
  Notes: Envia e-mail para a central comunicando que foi fechada a lista de 
         eventos

------------------------------------------------------------------------------*/
  
    FIND FIRST crapcop WHERE crapcop.cdcooper = INT(ab_unmap.aux_cdcooper)  
                             NO-LOCK NO-ERROR.
    
    FIND FIRST crapage WHERE crapage.cdcooper = INT(ab_unmap.aux_cdcooper)  AND
                             crapage.cdagenci = INT(ab_unmap.cdagenci)      
                             NO-LOCK NO-ERROR.
    
    IF   AVAIL crapcop   AND   AVAIL crapage THEN
         DO:
             RUN sistema/generico/procedures/b1wgen0011.p
                 PERSISTENT SET b1wgen0011.
            
             IF   VALID-HANDLE (b1wgen0011)   THEN
                  DO:                  
                      RUN enviar_email IN b1wgen0011 
                                      (INPUT crapcop.cdcooper,
                                       INPUT "wpgd0020",
                                       INPUT "progrid@cecred.coop.br",
                                       INPUT "PROGRID - EVENTOS SELECIONADOS"  +
                                             " - " + crapcop.nmrescop + " - " +
                                             crapage.nmresage,
                                       INPUT "",
                                       INPUT FALSE).

                      DELETE PROCEDURE b1wgen0011.
                  END.
         END.
                      
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
    ("aux_cddopcao":U,"ab_unmap.aux_cddopcao":U,ab_unmap.aux_cddopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsretorn":U,"ab_unmap.aux_dsretorn":U,ab_unmap.aux_dsretorn:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtanoage":U,"ab_unmap.aux_dtanoage":U,ab_unmap.aux_dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lscuseve":U,"ab_unmap.aux_lscuseve":U,ab_unmap.aux_lscuseve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lsfselec":U,"ab_unmap.aux_lsfselec":U,ab_unmap.aux_lsfselec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_qtdevent":U,"ab_unmap.aux_qtdevent":U,ab_unmap.aux_qtdevent:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_qtintegr":U,"ab_unmap.aux_qtintegr":U,ab_unmap.aux_qtintegr:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_salcusto":U,"ab_unmap.aux_salcusto":U,ab_unmap.aux_salcusto:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_vlcuseve":U,"ab_unmap.aux_vlcuseve":U,ab_unmap.aux_vlcuseve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_vlintegr":U,"ab_unmap.aux_vlintegr":U,ab_unmap.aux_vlintegr:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_vlprogri":U,"ab_unmap.aux_vlprogri":U,ab_unmap.aux_vlprogri:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdagenci":U,"ab_unmap.cdagenci":U,ab_unmap.cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
DEFINE INPUT PARAMETER opcao AS CHARACTER.
    
    DEFINE VARIABLE i AS INTEGER NO-UNDO.
    
    /* Salva a informação de evento selecionado */
    DO WITH FRAME {&FRAME-NAME}:
    
        DO i = 1 TO NUM-ENTRIES(ab_unmap.aux_lscuseve, ";"):
            FIND FIRST crapeap WHERE crapeap.idevento = INT(ab_unmap.aux_idevento)                  AND
                                     crapeap.cdcooper = INT(ab_unmap.aux_cdcooper)                  AND
                                     crapeap.dtanoage = INT(ab_unmap.aux_dtanoage)                  AND
                                     crapeap.cdevento = INT(ENTRY(i, ab_unmap.aux_lscuseve, ";"))   AND
                                     crapeap.cdagenci = INT(ab_unmap.cdagenci)                  
                                     EXCLUSIVE-LOCK NO-ERROR.
    
            IF AVAIL crapeap THEN
            DO:
                IF ENTRY(i, ab_unmap.aux_lsfselec, ";") = "true" THEN
                    ASSIGN crapeap.flgevsel = YES.
                ELSE
                    ASSIGN crapeap.flgevsel = NO.
    
                ab_unmap.cdagenci = STRING(crapeap.cdagenci).
    
            END.
            ELSE
                ASSIGN
                    msg-erro = msg-erro + "Evento não encontrado.".
        END.
    END. /* DO WITH FRAME {&FRAME-NAME} */
   
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
/* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0020.p PERSISTENT SET h-b1wpgd0020.
     
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0020) THEN
       DO:
          CREATE crateap.
          BUFFER-COPY crapeap TO crateap.
              
          RUN exclui-registro IN h-b1wpgd0020(INPUT TABLE crateap, OUTPUT msg-erro).
    
          /* "mata" a instância da BO */
          DELETE PROCEDURE h-b1wpgd0020 NO-ERROR.
       END.

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
               RUN RodaJavaScript("alert('Este já é o primeiro registro.')"). 
               
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

/* Não traz inicialmente nenhum registro */ 
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
               RUN RodaJavaScript("alert('Este já é o último registro.')").

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
   Nome: includes/webreq.i - Versão WebSpeed 2.1
  Autor: B&T/Solusoft
 Função: Processo de requisição web p/ cadastros simples na web - Versão WebSpeed 3.0
  Notas: Este é o procedimento principal onde terá as requisições GET e POST.
         GET - É ativa quando o formulário é chamado pela 1a vez
         POST - Após o get somente ocorrerá POST no formulário      
         Caso seja necessário custimizá-lo para algum programa específico 
         Favor cópiar este procedimento para dentro do procedure process-web-requeste 
         faça lá alterações necessárias.
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
       ab_unmap.aux_cdcooper    = GET-VALUE("aux_cdcooper")
       ab_unmap.aux_dtanoage    = GET-VALUE("aux_dtanoage")
       ab_unmap.aux_lsfselec    = GET-VALUE("aux_lsfselec")
       ab_unmap.aux_lscuseve    = GET-VALUE("aux_lscuseve")
       ab_unmap.cdagenci        = GET-VALUE("cdagenci").

RUN outputHeader.

{includes/wpgd0098.i}

ab_unmap.aux_cdcooper:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapcop.

/* Se a cooperativa ainda não foi escolhida, pega a da sessão do usuário */
IF   INT(ab_unmap.aux_cdcooper) = 0   THEN
     ab_unmap.aux_cdcooper = STRING(gnapses.cdcooper).

/* Se o PAC ainda não foi escolhido, pega o da sessão do usuário */
IF   INT(ab_unmap.cdagenci) = 0   THEN
     ab_unmap.cdagenci = STRING(gnapses.cdagenci).

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
   ASSIGN ab_unmap.aux_dtanoage = STRING(gnpapgd.dtanonov).
ELSE
   ASSIGN ab_unmap.aux_dtanoage = "".

/*******/   

RUN CriaListaPac.

/* método POST */
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
                               ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                            ELSE 
                            DO:
                               ASSIGN 
                                   msg-erro-aux = 10
                                   ab_unmap.aux_stdopcao = "al".
                               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

                            END.
                        END.  /* fim inclusao */
                    ELSE     /* alteração */ 
                        DO:
                            RUN local-assign-record ("alteracao").  
                            IF msg-erro = "" THEN
                               ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
                            ELSE
                               ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
    
                        END. /* fim alteração */
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

                    /* busca o próximo registro para fazer o reposicionamento */
                    FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

                    IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                       ASSIGN aux_nrdrowid-auxiliar = STRING(ROWID({&SECOND-ENABLED-TABLE})).
                    ELSE
                       DO:
                           /* nao encontrou próximo registro então procura pelo registro anterior para o reposicionamento */
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
                              ASSIGN msg-erro-aux = 1. /* registro em uso por outro usuário */ 
                              FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                          END.
                       ELSE
                          ASSIGN msg-erro-aux = 2. /* registro não existe */
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
                                          
                                       ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
                                   END.
                                ELSE
                                   ASSIGN msg-erro-aux = 3. /* Exclusao rejeitada */ 
                             END.
                          ELSE
                             ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
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

          WHEN "enc" THEN DO:
              RUN local-assign-record ("alteracao").  
              IF msg-erro = "" THEN DO:
                  RUN Encerra.
                  ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
              END.
              ELSE
                 ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
          END.
    
      END CASE.

      RUN CriaListaEventos.

      IF msg-erro-aux = 10 OR (opcao <> "sa" AND opcao <> "ex" AND opcao <> "in") THEN
         RUN displayFields.
 
      RUN enableFields.
      RUN outputFields.

      CASE msg-erro-aux:
           WHEN 1 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = 'Registro esta em uso por outro usuário. Solicitação não pode ser executada. Espere alguns instantes e tente novamente.'.

                    RUN RodaJavaScript(' top.frames[0].MostraResultado(' + STRING(v-qtdeerro) + ',"'+ v-descricaoerro + '"); ').
                END.

           WHEN 2 THEN
                RUN RodaJavaScript(" top.frames[0].MostraMsg('Registro foi excluído. Solicitação não pode ser executada.')").
      
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

      RUN RodaJavaScript('PosicionaPAC();').

      /*RUN RodaJavaScript('top.frames[0].ZeraOp()').  */ 

   END. /* Fim do método POST */
ELSE /* Método GET */ 
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

                    RUN CriaListaEventos.

                    RUN displayFields.
                    RUN enableFields.
                    RUN outputFields.
                    RUN RodaJavaScript('top.frcod.FechaZoom()').
                    RUN RodaJavaScript('CarregaPrincipal()').
                    
                    IF GET-VALUE("LinkRowid") = "" THEN
                    DO:
                        RUN RodaJavaScript('LimparCampos();').
                        RUN RodaJavaScript('top.frcod.Incluir();').
                        
                    END.

                    RUN RodaJavaScript('PosicionaPAC();').

                END. /* fim otherwise */                  
      END CASE. 
END. /* fim do método GET */

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

