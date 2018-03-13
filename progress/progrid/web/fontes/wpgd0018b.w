/*...............................................................................
Alteraçoes: 04/05/2009 - Utilizar cdcooper = 0 nas consultas (David).

            22/12/2009 - Criada consistencia para a existencia da tabela 
                         crapedp (Elton).
						 
            05/06/2012 - Adaptaçao dos fontes para projeto Oracle. Alterado
                         busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
                         
            19/05/2016 - Alteraçoes para o Prj. 229 (Jean Michel).            

            02/08/2016 - Inclusao insitage 3-Temporariamente Indisponivel.
                         (Jaison/Anderson)

...............................................................................*/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME

&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_cdcooper AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_flgselec AS CHARACTER
       FIELD aux_flgtermo AS LOGICAL FORMAT "yes/no":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lscpfcgc AS CHARACTER
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspropos AS CHARACTER
       FIELD aux_nmpagina AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_vlrselec AS CHARACTER
       FIELD aux_vlrselec_termo AS CHARACTER FORMAT "X(256)":U 
       FIELD nmevento AS CHARACTER FORMAT "X(256)":U 
       FIELD nmrescop AS CHARACTER FORMAT "X(256)":U
       FIELD aux_qtmaxtur AS CHARACTER FORMAT "X(256)":U
       FIELD aux_qtdagenc AS CHARACTER FORMAT "X(256)":U
       FIELD aux_agerepli AS CHARACTER
       FIELD aux_vlrhonor AS CHARACTER FORMAT "X(256)":U
       FIELD aux_vloutros AS CHARACTER FORMAT "X(256)":U
       FIELD aux_lscpfcgc2 AS CHARACTER.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-html 
/*----------------------------------------------------------------------*/
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

DEFINE VARIABLE ProgramaEmUso         AS CHARACTER INITIAL ["wpgd0018"].
DEFINE VARIABLE NmeDoPrograma         AS CHARACTER INITIAL ["wpgd0018b.w"].

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

/*** Declaraçao de BOs ***/
DEFINE VARIABLE h-b1wpgd0018          AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratcdp NO-UNDO     LIKE crapcdp.
DEFINE TEMP-TABLE crabedp NO-UNDO     LIKE crapedp.

DEFINE VARIABLE vetorevento           AS CHAR                           NO-UNDO.
DEFINE VARIABLE vetortermo            AS CHAR                           NO-UNDO.
DEFINE VARIABLE aux_qtdiaeve          AS INTEGER                        NO-UNDO.
DEFINE VARIABLE aux_cdcidapa          AS INTEGER                        NO-UNDO.
DEFINE VARIABLE aux_cdcidafa          AS INTEGER                        NO-UNDO.
DEFINE VARIABLE aux_cdufdcop          AS CHAR                           NO-UNDO.
DEFINE VARIABLE aux_nmcidade          AS CHAR                           NO-UNDO.
DEFINE VARIABLE aux_cdagenci          AS INTEGER                        NO-UNDO.
  
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0018b.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS crapcdp.dtanoage 
&Scoped-define ENABLED-TABLES ab_unmap crapcdp
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapcdp
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_flgtermo ~
ab_unmap.aux_vlrselec_termo ab_unmap.aux_nmpagina ab_unmap.aux_lspropos ~
ab_unmap.aux_lscpfcgc ab_unmap.aux_flgselec ab_unmap.nmevento ~
ab_unmap.nmrescop ab_unmap.aux_vlrselec ab_unmap.aux_cdcooper ~
ab_unmap.aux_cddopcao ab_unmap.aux_cdevento ab_unmap.aux_dsendurl ~
ab_unmap.aux_dsretorn ab_unmap.aux_dtanoage ab_unmap.aux_idevento ~
ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ~
ab_unmap.aux_qtmaxtur ab_unmap.aux_lscpfcgc2 ab_unmap.aux_qtdagenc ~
ab_unmap.aux_agerepli ab_unmap.aux_vlrhonor ab_unmap.aux_vloutros
&Scoped-Define DISPLAYED-FIELDS crapcdp.dtanoage 
&Scoped-define DISPLAYED-TABLES ab_unmap crapcdp
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapcdp
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_flgtermo ~
ab_unmap.aux_vlrselec_termo ab_unmap.aux_nmpagina ab_unmap.aux_lspropos ~
ab_unmap.aux_lscpfcgc ab_unmap.aux_flgselec ab_unmap.nmevento ~
ab_unmap.nmrescop ab_unmap.aux_vlrselec ab_unmap.aux_cdcooper ~
ab_unmap.aux_cddopcao ab_unmap.aux_cdevento ab_unmap.aux_dsendurl ~
ab_unmap.aux_dsretorn ab_unmap.aux_dtanoage ab_unmap.aux_idevento ~
ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ~
ab_unmap.aux_qtmaxtur ab_unmap.aux_lscpfcgc2 ab_unmap.aux_qtdagenc ~
ab_unmap.aux_agerepli ab_unmap.aux_vlrhonor ab_unmap.aux_vloutros

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */
/* Definitions of the field level widgets                               */
/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.aux_flgtermo AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "yes/no":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_vlrselec_termo AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nmpagina AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lspropos AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1     
     ab_unmap.aux_lscpfcgc AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lscpfcgc2 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_flgselec AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.nmevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.nmrescop AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_vlrselec AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cddopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdevento AT ROW 1 COL 1 HELP
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
     ab_unmap.aux_dtanoage AT ROW 1 COL 1 HELP
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
     crapcdp.dtanoage AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_qtmaxtur AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_qtdagenc AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1  
     ab_unmap.aux_agerepli AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1   
     ab_unmap.aux_vlrhonor AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_vloutros AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 50.2 BY 25.67.

/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 25.67
         WIDTH              = 50.2.
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
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE LimpaCustosOrcados w-html 
PROCEDURE LimpaCustosOrcados:
  DEFINE INPUT PARAMETER par_cdagenci AS INTEGER NO-UNDO.
    
  FOR EACH crapcdp WHERE crapcdp.cdevento = INT(ab_unmap.aux_cdevento) 
                     AND crapcdp.idevento = INT(ab_unmap.aux_idevento)   
                     AND crapcdp.cdagenci = par_cdagenci
                     AND crapcdp.tpcuseve = 1 /* custos diretos */       
                     AND crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper)   
                     AND crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage) EXCLUSIVE-LOCK:
            
      ASSIGN crapcdp.nrcpfcgc = ?
             crapcdp.nrpropos = ""
             crapcdp.nrdocfmd = ?
             crapcdp.vlcuseve = 0.
      
      VALIDATE crapcdp.
  END.
  
  RETURN "OK".
    
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ListaCustosOrcados w-html 
PROCEDURE ListaCustosOrcados :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE aux_vlrcusto AS DEC  NO-UNDO.
    DEFINE VARIABLE aux_vlrtotal AS DEC  NO-UNDO.
    DEFINE VARIABLE aux_nrcpfcgc AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_nrpropos AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_nmfornec AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_flgfecha AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_envfecha AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_nmresage AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_cdageagr AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nmfordiv AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_nrdocfmd AS CHAR NO-UNDO.
    
    DEFINE VARIABLE aux_contador AS INT  NO-UNDO.
    DEFINE VARIABLE vetoreventos AS CHAR NO-UNDO.
    
    DEF VAR aux_lscpfcgc2 AS CHAR NO-UNDO.
    DEF VAR aux_lspropos AS CHAR NO-UNDO.
    DEF VAR aux_lscpfcgc AS CHAR NO-UNDO.
    DEF VAR aux_flgselec AS CHAR NO-UNDO.
    
    DEFINE VARIABLE var_nrcpfcgc AS CHAR NO-UNDO.  
    DEFINE VARIABLE var_nrpropos AS CHAR NO-UNDO.  
    DEFINE VARIABLE var_nrdocfmd AS CHAR NO-UNDO.
  
    DEFINE BUFFER bf-crapcdp FOR crapcdp.
    DEFINE BUFFER bf-crapagp FOR crapagp.
    DEFINE BUFFER bf-crapage FOR crapage.

    RUN RodaJavaScript("var mevento = new Array();").
        
    ASSIGN aux_contador = 0.    
    
    FIND bf-crapcdp WHERE bf-crapcdp.cdevento = INT(ab_unmap.aux_cdevento)  
                      AND bf-crapcdp.idevento = INT(ab_unmap.aux_idevento) 
                      AND bf-crapcdp.cdagenci = 0                          
                      AND bf-crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper) 
                      AND bf-crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage) 
                      AND bf-crapcdp.tpcuseve = 1 
                      AND bf-crapcdp.cdcuseve = 1 NO-LOCK.
                          
    IF AVAILABLE bf-crapcdp THEN                          
      ASSIGN var_nrcpfcgc = STRING(bf-crapcdp.nrcpfcgc)
             var_nrpropos = STRING(bf-crapcdp.nrpropos)
             var_nrdocfmd = STRING(bf-crapcdp.nrdocfmd).
                              
    FOR EACH crapcdp WHERE crapcdp.cdevento = INT(ab_unmap.aux_cdevento)  
                       AND crapcdp.idevento = INT(ab_unmap.aux_idevento) 
                       AND crapcdp.cdagenci = 0                          
                       AND crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper) 
                       AND crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage) 
                       AND crapcdp.tpcuseve = 1 EXCLUSIVE-LOCK:
                       
      ASSIGN crapcdp.nrcpfcgc = DEC(var_nrcpfcgc)
             crapcdp.nrpropos = STRING(var_nrpropos)
             crapcdp.nrdocfmd = DEC(var_nrdocfmd).
             
      VALIDATE crapcdp.                        
      
    END.
    
    /* Primeiro, monta a informaçao para o registro com PAC = 0 (modelo) */
    FOR EACH crapcdp WHERE crapcdp.cdevento = INT(ab_unmap.aux_cdevento)
                       AND crapcdp.idevento = INT(ab_unmap.aux_idevento)    
                       AND crapcdp.cdagenci = 0                             
                       AND crapcdp.tpcuseve = 1 /* custos diretos */        
                       AND crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper)    
                       AND crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage) NO-LOCK
                           BREAK BY crapcdp.cdcooper
                                    BY crapcdp.cdevento
                                       BY crapcdp.cdcuseve:

        ASSIGN aux_vlrcusto = crapcdp.vlcuseve
               aux_flgfecha = (IF crapcdp.flgfecha THEN "checked" ELSE "")
               aux_envfecha = (IF crapcdp.flgfecha THEN "disabled" ELSE "")
               aux_nrdocfmd = (IF crapcdp.nrdocfmd <> ? THEN STRING(crapcdp.nrdocfmd) ELSE "").

        IF REQUEST_METHOD = "GET":U THEN     
          DO:
            IF aux_lscpfcgc2 <> ? AND aux_lscpfcgc2 <> "" THEN
              ASSIGN aux_lscpfcgc2 = aux_lscpfcgc2 + ";".
            
            IF aux_lspropos <> ? AND aux_lspropos <> "" THEN
              ASSIGN aux_lspropos = aux_lspropos + ";".
              
            IF aux_lscpfcgc <> ? AND aux_lscpfcgc <> "" THEN
              ASSIGN aux_lscpfcgc = aux_lscpfcgc + ";".
              
            IF aux_flgselec <> ? AND aux_flgselec <> "" THEN
              ASSIGN aux_flgselec = aux_flgselec + ";".  
              
            ASSIGN aux_lscpfcgc2 = aux_lscpfcgc2 + STRING(crapcdp.nrcpfcgc)
                   aux_lspropos  = aux_lspropos  + STRING(crapcdp.nrdocfmd)
                   aux_lscpfcgc  = aux_lscpfcgc  + STRING(crapcdp.nrpropos)
                   aux_flgselec  = aux_flgselec  + "true".
                   
          END. 
          
        FIND FIRST gnapfdp WHERE gnapfdp.cdcooper = 0               
                             AND gnapfdp.nrcpfcgc = crapcdp.nrcpfcgc NO-LOCK NO-ERROR NO-WAIT.
        
        IF AVAILABLE gnapfdp THEN
          DO: 
            ASSIGN aux_nmfornec = gnapfdp.nmfornec.
          END.
        ELSE
            ASSIGN aux_nmfornec = "".
            
        /* Fornecedor de Material de Divulgaçao.*/
        FIND FIRST gnapfdp WHERE gnapfdp.cdcooper = 0
                             AND gnapfdp.nrcpfcgc = crapcdp.nrdocfmd NO-LOCK NO-ERROR NO-WAIT.
                             
        IF AVAILABLE gnapfdp THEN
        DO:
           IF gnapfdp.idtipfor = 2 THEN
              ASSIGN aux_nmfordiv = gnapfdp.nmfornec.
           ELSE
              ASSIGN aux_nmfordiv = "".
        END.      
        ELSE
            ASSIGN aux_nmfordiv =  "".

        /* Para cada evento que foi selecionado */
          IF FIRST-OF(crapcdp.cdevento) THEN
          DO:
            ASSIGN aux_vlrtotal = 0
                   aux_contador = aux_contador + 1.
            
            IF vetoreventos = "" THEN
                ASSIGN vetoreventos = "~{cdagenci:'0',nmresage:''".
              ELSE
                ASSIGN vetoreventos = vetoreventos + ",~{cdagenci:'',nmresage:''".
          END.

          IF aux_vlrtotal = ? THEN  
            DO:
              ASSIGN aux_vlrtotal = 0.
            END.
          
          ASSIGN aux_vlrtotal = aux_vlrtotal + crapcdp.vlcuseve.

          CASE crapcdp.cdcuseve:
              WHEN 1 THEN /* Honorários */
              DO:
                    ASSIGN aux_nrcpfcgc = (IF crapcdp.nrcpfcgc <> ? THEN STRING(crapcdp.nrcpfcgc) ELSE "")
                           aux_nrpropos = (IF crapcdp.nrpropos <> ? THEN STRING(crapcdp.nrpropos) ELSE "")
                           vetoreventos = vetoreventos + ",vlhonora:" + "'" + string(aux_vlrcusto,">>,>>9.99") + "'"
                                                       + ",nrcpfcgc:'" + TRIM(aux_nrcpfcgc) + "'"
                                                       + ",nrpropos:'" + TRIM(aux_nrpropos) + "'"
                                                       + ",nmfornec:'" + TRIM(aux_nmfornec) + "'"
                                                       + ",nmfordiv:'" + TRIM(aux_nmfordiv) + "'"
                                                       + ",nrdocfmd:'" + TRIM(aux_nrdocfmd) + "'"
                                                       + ",flgfecha:'" + TRIM(aux_flgfecha) + "'"
                                                       + ",envfecha:'" + TRIM(aux_envfecha) + "'".
              END.
              WHEN 2 THEN /* Local */
              DO:
                    vetoreventos = vetoreventos + ",vlrlocal:'" + TRIM(STRING(aux_vlrcusto,">>,>>9.99")) + "'".
              END.
              WHEN 3 THEN /* Alimentaçao */
              DO:
                    vetoreventos = vetoreventos + ",vlalimen:'" + TRIM(STRING(aux_vlrcusto,">>,>>9.99")) + "'".
              END.
              WHEN 4 THEN /* Material */
              DO:
                    vetoreventos = vetoreventos + ",vlmateri:'" + TRIM(STRING(aux_vlrcusto,">>,>>9.99")) + "'".
              END.
              WHEN 5 THEN /* Transportes */
              DO:
                    vetoreventos = vetoreventos + ",vltransp:'" + TRIM(STRING(aux_vlrcusto,">>,>>9.99")) + "'".
              END.
              WHEN 6 THEN /* Brindes */
              DO:
                    vetoreventos = vetoreventos + ",vlbrinde:'" + TRIM(STRING(aux_vlrcusto,">>,>>9.99")) + "'".
              END.
              WHEN 7 THEN /* Divulgaçao */
              DO:
                    vetoreventos = vetoreventos + ",vldivulg:'" + TRIM(STRING(aux_vlrcusto,">>,>>9.99")) + "'".
              END.
              WHEN 8 THEN /* Outros */
              DO:
                    ASSIGN vetoreventos = vetoreventos + ",vloutros:'" + TRIM(STRING(aux_vlrcusto,">>,>>9.99")) + 
                                          "',vlrtotal:'" + TRIM(STRING(aux_vlrtotal,">>,>>9.99")) + "'~}".
              END.
              OTHERWISE
                DO:
                  vetoreventos = vetoreventos + "".
                END.
          END CASE. /* CASE crapcdp.cdcuseve */
          
        IF aux_contador = 50 THEN
            DO:
              RUN RodaJavaScript("mevento.push(" + TRIM(STRING(vetoreventos)) + ");").
              
              ASSIGN aux_contador = 0
                     vetoreventos = "".                       
            END.
                   
    END. /* FOR EACH crapcdp */

  IF vetoreventos <> "" AND vetoreventos <> ? THEN
    RUN RodaJavaScript("mevento.push(" + TRIM(STRING(vetoreventos)) + ");").
      
    /* Verifica o PAC agrupador do PAC do usuario */
  FIND crapagp WHERE crapagp.idevento = INT(ab_unmap.aux_idevento)
                 AND crapagp.cdcooper = INT(ab_unmap.aux_cdcooper)
                 AND crapagp.dtanoage = INT(ab_unmap.aux_dtanoage)
                 AND crapagp.cdagenci = gnapses.cdagenci NO-LOCK NO-ERROR NO-WAIT.

  IF AVAILABLE crapagp   THEN
    ASSIGN aux_cdageagr = crapagp.cdageagr.
    ELSE
    ASSIGN aux_cdageagr = gnapses.cdagenci.    

  /* Segundo, monta as informaçoes relativas a cada PAC */
  ASSIGN aux_nrpropos = ""
         aux_contador = 0
         vetoreventos  = "".

  FOR EACH crapage WHERE crapage.cdcooper = INT(ab_unmap.aux_cdcooper)
                     AND (crapage.insitage = 1  OR  /* Ativo */
                          crapage.insitage = 3)     /* Temporariamente Indisponivel */
                     AND crapage.flgdopgd = TRUE NO-LOCK
                           BY crapage.nmresage:

    /* Controle de visualizaçao por PAC */
    IF (gnapses.nvoperad = 1    OR
             gnapses.nvoperad = 2)                  AND
             gnapses.cdagenci <> crapage.cdagenci   AND
             crapage.cdagenci <> aux_cdageagr       THEN
      DO:
             NEXT.
      END.

    /* Para Progrid, os PACs sao agrupados */
        FIND crapagp WHERE crapagp.idevento = INT(ab_unmap.aux_idevento)  AND
                           crapagp.cdcooper = INT(ab_unmap.aux_cdcooper)  AND
                           crapagp.dtanoage = INT(ab_unmap.aux_dtanoage)  AND
                           crapagp.cdagenci = crapage.cdagenci
                           NO-LOCK NO-ERROR NO-WAIT.

    IF INT(ab_unmap.aux_idevento) = 1   THEN
             DO:
        IF NOT AVAILABLE crapagp THEN
                      NEXT.  

        IF crapagp.cdagenci <> crapagp.cdageagr   THEN
                      NEXT.
             END.
        
    ASSIGN aux_nmresage = crapage.nmresage.

        /* Pega os PACS agrupados */
    IF INT(ab_unmap.aux_idevento) = 1   THEN
      FOR EACH bf-crapagp  WHERE bf-crapagp.idevento  = crapagp.idevento
                             AND bf-crapagp.cdcooper  = crapagp.cdcooper
                             AND bf-crapagp.dtanoage  = crapagp.dtanoage
                             AND bf-crapagp.cdageagr  = crapagp.cdagenci
                             AND bf-crapagp.cdagenci <> crapagp.cdagenci      NO-LOCK,
                 FIRST bf-crapage WHERE bf-crapage.cdagenci  = bf-crapagp.cdagenci   NO-LOCK 
                                        BY bf-crapage.nmresage:
           
                 ASSIGN aux_nmresage = aux_nmresage + " / " + bf-crapage.nmresage.
            END.
 
      FOR EACH crapcdp WHERE crapcdp.cdevento = INT(ab_unmap.aux_cdevento)
                         AND crapcdp.idevento = INT(ab_unmap.aux_idevento)
                         AND crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage)
                         AND crapcdp.tpcuseve = 1 /* custos diretos */    
                         AND crapcdp.cdagenci = 0                         
                         AND crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper)    NO-LOCK
                               BREAK BY crapcdp.cdcooper
                                        BY crapcdp.cdevento
                                           BY crapcdp.cdcuseve:
        
        ASSIGN aux_nmfordiv = ""
               aux_nrcpfcgc = ""
               aux_nrpropos = ""
               aux_nrdocfmd = "".
                   
          /* Verifica se já foi lançado custo para esse PAC */
        FIND FIRST bf-crapcdp WHERE bf-crapcdp.cdevento = crapcdp.cdevento            
                                AND bf-crapcdp.cdcuseve = crapcdp.cdcuseve            
                                AND bf-crapcdp.idevento = INT(ab_unmap.aux_idevento)  
                                AND bf-crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage)  
                                AND bf-crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper)  
                                AND bf-crapcdp.tpcuseve = 1 /* custos diretos */      
                                AND bf-crapcdp.cdagenci = crapage.cdagenci            NO-LOCK NO-ERROR NO-WAIT.

        /* Se tem custo lançado, pega de lá. Se nao tem, atribui 0 */
        IF AVAILABLE bf-crapcdp THEN  
          DO:
              /* Verifica se a agenda já foi enviada ao PAC */
            IF INT(ab_unmap.aux_idevento) = 1 THEN
                   DO:
                IF crapagp.idstagen <> 0 THEN 
                            aux_envfecha = "disabled". 
                       ELSE 
                            aux_envfecha = "".
                   END.

              FIND FIRST gnapfdp WHERE gnapfdp.cdcooper = 0
                                   AND gnapfdp.nrcpfcgc = bf-crapcdp.nrcpfcgc NO-LOCK NO-ERROR NO-WAIT.

              IF AVAILABLE gnapfdp THEN
                  ASSIGN aux_nmfornec = gnapfdp.nmfornec.
              ELSE
                  ASSIGN aux_nmfornec = "".
                  
             /* Fornecedor de Material de Divulgaçao.*/
              FIND FIRST gnapfdp WHERE gnapfdp.cdcooper = 0
                                   AND gnapfdp.nrcpfcgc = bf-crapcdp.nrdocfmd NO-LOCK NO-ERROR NO-WAIT.
                                   
              IF AVAILABLE gnapfdp THEN
                DO:
                   IF gnapfdp.idtipfor = 2 THEN
                      ASSIGN aux_nmfordiv = gnapfdp.nmfornec.
                   ELSE
                      ASSIGN aux_nmfordiv = "".
                END.      
              ELSE
                  ASSIGN aux_nmfordiv =  "".

              IF ab_unmap.aux_idevento = "2" THEN DO:              
                  ASSIGN aux_envfecha = IF bf-crapcdp.flgfecha THEN "disabled" ELSE "".
              END.
              
            ASSIGN aux_vlrcusto = (bf-crapcdp.vlcuseve)
                   aux_flgfecha = (IF bf-crapcdp.flgfecha THEN "checked" ELSE "")
                   aux_envfecha = (IF bf-crapcdp.flgfecha THEN "disabled" ELSE "")
                   aux_nrcpfcgc = (IF bf-crapcdp.nrcpfcgc <> ? THEN STRING(bf-crapcdp.nrcpfcgc) ELSE "")
                   aux_nrpropos = (IF bf-crapcdp.nrpropos <> ? THEN STRING(bf-crapcdp.nrpropos) ELSE "")
                   aux_nrdocfmd = (IF bf-crapcdp.nrdocfmd <> ? THEN STRING(bf-crapcdp.nrdocfmd) ELSE "").
              END.      
        ELSE /* IF AVAILABLE bf-crapcdp THEN   */
          DO:
            ASSIGN aux_vlrcusto = 0
                  aux_flgfecha = ""
                   aux_envfecha = ""
                   aux_nmfornec = "".
          END. 

        IF aux_vlrcusto = ? THEN
          ASSIGN aux_vlrcusto = 0.
          
          IF FIRST-OF(crapcdp.cdevento) THEN
            DO:
            ASSIGN aux_vlrtotal = 0
                   aux_contador = aux_contador + 1.

            IF vetoreventos <> "" AND vetoreventos <> ? THEN
              vetoreventos = vetoreventos + ",".
          
            vetoreventos = vetoreventos + "~{cdagenci:'" + string(crapage.cdagenci) + "',nmresage:'" + REPLACE(STRING(aux_nmresage),"'","`") + "'".
          END.
          
        IF STRING(aux_vlrtotal) = "" THEN 
          ASSIGN aux_vlrtotal = 0.
            
        ASSIGN aux_vlrtotal = aux_vlrtotal + aux_vlrcusto.
                  
          CASE crapcdp.cdcuseve:
              WHEN 1 THEN /* Honorários */
              DO:
                  vetoreventos = vetoreventos + ",vlhonora:" + "'" + string(aux_vlrcusto,">>,>>9.99") + "'"
                                              + ",nrcpfcgc:'" + TRIM(aux_nrcpfcgc) + "'"
                                              + ",nrpropos:'" + TRIM(aux_nrpropos) + "'"
                                              + ",nmfornec:'" + TRIM(aux_nmfornec) + "'"
                                              + ",nmfordiv:'" + TRIM(aux_nmfordiv) + "'"
                                              + ",nrdocfmd:'" + TRIM(aux_nrdocfmd) + "'"
                                              + ",flgfecha:'" + TRIM(aux_flgfecha) + "'"
                                              + ",envfecha:'" + TRIM(aux_envfecha) + "'".
              END.
              WHEN 2 THEN /* Local */
              DO:
                vetoreventos = vetoreventos + ",vlrlocal:'" + TRIM(STRING(aux_vlrcusto,">>,>>9.99")) + "'".
              END.
            WHEN 3 THEN /* Alimentaçao */
              DO:
                vetoreventos = vetoreventos + ",vlalimen:'" + TRIM(STRING(aux_vlrcusto,">>,>>9.99")) + "'".
              END.
              WHEN 4 THEN /* Material */
              DO:
                vetoreventos = vetoreventos + ",vlmateri:'" + TRIM(STRING(aux_vlrcusto,">>,>>9.99")) + "'".
              END.
              WHEN 5 THEN /* Transportes */
              DO:
                vetoreventos = vetoreventos + ",vltransp:'" + TRIM(STRING(aux_vlrcusto,">>,>>9.99")) + "'".
              END.
              WHEN 6 THEN /* Brindes */
              DO:
                  vetoreventos = vetoreventos + ",vlbrinde:'" + TRIM(STRING(aux_vlrcusto,">>,>>9.99")) + "'".
              END.
            WHEN 7 THEN /* Divulgaçao */
              DO:
                vetoreventos = vetoreventos + ",vldivulg:'" + TRIM(STRING(aux_vlrcusto,">>,>>9.99")) + "'".
              END.
              WHEN 8 THEN /* Outros */
              DO:
                vetoreventos = vetoreventos + ",vloutros:'" + TRIM(STRING(aux_vlrcusto,">>,>>9.99"))
                                          + "',vlrtotal:'" + TRIM(STRING(aux_vlrtotal,">>,>>9.99")) + "'~}".
              END.
          END CASE. /* CASE crapcdp.cdcuseve */

      END. /* FOR EACH crapcdp */

    IF aux_contador = 50 THEN
      DO:
        RUN RodaJavaScript("mevento.push(" + TRIM(STRING(vetoreventos)) + ");").
        
        ASSIGN aux_contador = 0
               vetoreventos = "".                       
      END.
          
   END. /* FOR EACH crapage */

  IF vetoreventos <> "" AND vetoreventos <> ? THEN
    RUN RodaJavaScript("mevento.push(" + TRIM(STRING(vetoreventos)) + ");").  
  
  IF REQUEST_METHOD = "GET":U THEN
    DO:
      ASSIGN ab_unmap.aux_lspropos  = aux_lspropos 
             ab_unmap.aux_lscpfcgc  = aux_lscpfcgc
             ab_unmap.aux_lscpfcgc2 = aux_lscpfcgc2
             ab_unmap.aux_flgselec  = aux_flgselec.
    END.
          
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CalculoCustosOrcados w-html 
PROCEDURE CalculoCustosOrcados:

  DEFINE INPUT PARAMETER par_cdagenci AS INTEGER NO-UNDO.
  
  DEFINE VARIABLE aux_vlrcusto AS DEC  NO-UNDO INIT 0.
  DEFINE VARIABLE aux_vlrtotal AS DEC  NO-UNDO INIT 0.
    DEFINE VARIABLE aux_nrcpfcgc AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_nrpropos AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_nmfornec AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_flgfecha AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_envfecha AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_nmresage AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_cdageagr AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nmfordiv AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_nrdocfmd AS CHAR NO-UNDO.   
  DEFINE VARIABLE aux_vlrlocal AS DEC  NO-UNDO INIT ?.
  DEFINE VARIABLE aux_vlalimen AS DEC  NO-UNDO INIT ?.
  DEFINE VARIABLE aux_vlmateri AS DEC  NO-UNDO INIT 0.
  DEFINE VARIABLE aux_vltransp AS DEC  NO-UNDO INIT 0.
  DEFINE VARIABLE aux_vlbrinde AS DEC  NO-UNDO INIT 0.
  DEFINE VARIABLE aux_vldivulg AS DEC  NO-UNDO INIT 0.
  DEFINE VARIABLE aux_vloutros AS DEC  NO-UNDO INIT 0.
  DEFINE VARIABLE aux_qtmaxtur AS DEC  NO-UNDO INIT 0.
  DEFINE VARIABLE aux_vlrecpor AS DEC  NO-UNDO INIT 0.   
  DEFINE VARIABLE aux_qtgrppar AS DEC  NO-UNDO INIT 0.
  DEFINE VARIABLE aux_vlporqui AS DEC  NO-UNDO INIT 0.       
  DEFINE VARIABLE aux_contador AS INTEGER NO-UNDO INIT 0.  
    
  DEFINE VARIABLE var_nrcpfcgc AS CHAR NO-UNDO.  
  DEFINE VARIABLE var_nrpropos AS CHAR NO-UNDO.  
  DEFINE VARIABLE var_nrdocfmd AS CHAR NO-UNDO. 
  DEFINE VARIABLE aux_flgerror AS LOGICAL NO-UNDO.
  
    DEFINE BUFFER bf-crapcdp FOR crapcdp.
    DEFINE BUFFER bf-crapagp FOR crapagp.
    DEFINE BUFFER bf-crapage FOR crapage.
  DEFINE BUFFER crabedp    FOR crapedp.

  ASSIGN aux_flgerror = FALSE
         aux_qtdiaeve = 0
         aux_contador = 0.
      
  RUN RodaJavaScript("var mevento = new Array();").
      
  TRANSACAO:
        
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
      
      /* Verifica quantidade de dias do evento */
      FIND FIRST crapedp WHERE crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)
                           AND crapedp.dtanoage = INT(ab_unmap.aux_dtanoage)
                           AND crapedp.cdevento = INT(ab_unmap.aux_cdevento) NO-LOCK NO-ERROR NO-WAIT.
    
      IF AVAILABLE crapedp THEN
        ASSIGN aux_qtdiaeve = crapedp.qtdiaeve.
      ELSE
        DO:
          /* Verifica quantidade de dias do evento */
          FIND FIRST crapedp WHERE crapedp.cdcooper = 0
                               AND crapedp.dtanoage = 0
                               AND crapedp.cdevento = INT(ab_unmap.aux_cdevento) NO-LOCK NO-ERROR NO-WAIT.

          IF AVAILABLE crapedp THEN
            ASSIGN aux_qtdiaeve = crapedp.qtdiaeve.
        END.
        
      IF aux_qtdiaeve = 0 THEN
        DO:
          RUN RodaJavaScript("alert('Quantidade de dias do evento não informada ou igual a zero.  Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.');").
          ASSIGN aux_flgerror = TRUE.
          UNDO TRANSACAO, LEAVE TRANSACAO.            
        END.      
            
      FOR EACH crapage WHERE crapage.cdcooper = INT(ab_unmap.aux_cdcooper)
                         AND crapage.cdagenci <> 90                       
                         AND crapage.cdagenci <> 91 
                         AND (crapage.cdagenci = par_cdagenci OR par_cdagenci = 0)
                         AND (crapage.insitage = 1  OR  /* Ativo */
                              crapage.insitage = 3)     /* Temporariamente Indisponivel */
                         AND crapage.flgdopgd = TRUE NO-LOCK:
            
        /* Para Progrid, os PACs sao agrupados */
        FIND FIRST crapagp WHERE crapagp.idevento = INT(ab_unmap.aux_idevento)
                             AND crapagp.cdcooper = INT(ab_unmap.aux_cdcooper)
                             AND crapagp.dtanoage = INT(ab_unmap.aux_dtanoage)
                             AND crapagp.cdagenci = crapage.cdagenci NO-LOCK NO-ERROR NO-WAIT.
                                 
        IF INT(ab_unmap.aux_idevento) = 1 THEN
        DO:
            IF NOT AVAILABLE crapagp THEN
              NEXT.  
        
            IF crapagp.cdagenci <> crapagp.cdageagr THEN
              NEXT.
          END.
           
        FOR EACH bf-crapcdp WHERE bf-crapcdp.cdevento = INT(ab_unmap.aux_cdevento)  
                              AND bf-crapcdp.idevento = INT(ab_unmap.aux_idevento) 
                              AND (bf-crapcdp.cdagenci = par_cdagenci OR par_cdagenci = 0)                          
                              AND bf-crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper) 
                              AND bf-crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage) 
                              AND bf-crapcdp.tpcuseve = 1 NO-LOCK:   
        
                  
          FIND FIRST crapcdp WHERE crapcdp.cdevento = bf-crapcdp.cdevento
                               AND crapcdp.idevento = bf-crapcdp.idevento 
                               AND crapcdp.cdagenci = crapage.cdagenci           
                               AND crapcdp.cdcooper = bf-crapcdp.cdcooper 
                               AND crapcdp.dtanoage = bf-crapcdp.dtanoage 
                               AND crapcdp.cdcuseve = bf-crapcdp.cdcuseve
                               AND crapcdp.tpcuseve = 1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT. 
                    
          IF AVAILABLE crapcdp THEN
              DO:                 
    
              ASSIGN crapcdp.flgfecha = FALSE.
              IF (crapcdp.nrpropos = "" OR crapcdp.nrpropos = ?) AND 
                  CAN-DO(STRING(ab_unmap.aux_agerepli),STRING(crapage.cdagenci)) THEN
              DO:
                  ASSIGN crapcdp.nrcpfcgc = DEC(bf-crapcdp.nrcpfcgc)
                         crapcdp.nrpropos = STRING(bf-crapcdp.nrpropos)
                         crapcdp.nrdocfmd = DEC(bf-crapcdp.nrdocfmd).
              END.
    
              VALIDATE crapcdp.
              NEXT.
              END.
          ELSE
              DO:
              ASSIGN var_nrcpfcgc = STRING(bf-crapcdp.nrcpfcgc)
                     var_nrpropos = STRING(bf-crapcdp.nrpropos)
                     var_nrdocfmd = STRING(bf-crapcdp.nrdocfmd).
    
              CREATE crapcdp NO-ERROR.
              BUFFER-COPY bf-crapcdp EXCEPT bf-crapcdp.cdagenci bf-crapcdp.vlcuseve bf-crapcdp.nrcpfcgc bf-crapcdp.nrpropos bf-crapcdp.nrdocfmd bf-crapcdp.flgfecha TO crapcdp.
              ASSIGN crapcdp.cdagenci = crapage.cdagenci
                     crapcdp.vlcuseve = 0
                     crapcdp.flgfecha = FALSE.
                     
              IF(CAN-DO(STRING(ab_unmap.aux_agerepli),STRING(crapage.cdagenci))) THEN
              DO:
                  ASSIGN crapcdp.nrcpfcgc = DEC(var_nrcpfcgc)
                         crapcdp.nrpropos = STRING(var_nrpropos)
                         crapcdp.nrdocfmd = DEC(var_nrdocfmd).
              END.
    
              VALIDATE crapcdp.
              END.
    
              END.
      END.    
    
    /* Primeiro, monta a informaçao para o registro com PAC = 0 (modelo) */
    FIND FIRST crapcdp WHERE crapcdp.cdevento = INT(ab_unmap.aux_cdevento) 
                         AND crapcdp.idevento = INT(ab_unmap.aux_idevento)   
                         AND crapcdp.cdagenci = (IF par_cdagenci = 0 THEN 0 ELSE INT(par_cdagenci))
                         AND crapcdp.tpcuseve = 1 /* custos diretos */       
                         AND crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper)   
                         AND crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage)
                         AND crapcdp.nrpropos <> ? NO-LOCK NO-ERROR NO-WAIT.
        
    IF AVAILABLE crapcdp THEN    
              DO:
        ASSIGN aux_nrcpfcgc = (IF crapcdp.nrcpfcgc <> ? THEN STRING(crapcdp.nrcpfcgc) ELSE "")
               aux_nrpropos = (IF crapcdp.nrpropos <> ? THEN STRING(crapcdp.nrpropos) ELSE "")
               aux_nrdocfmd = (IF crapcdp.nrdocfmd <> ? THEN STRING(crapcdp.nrdocfmd) ELSE "").
              END.
    
    /* Verifica o PAC agrupador do PAC do usuario */
    FIND FIRST crapagp WHERE crapagp.idevento = INT(ab_unmap.aux_idevento)
                         AND crapagp.cdcooper = INT(ab_unmap.aux_cdcooper)
                         AND crapagp.dtanoage = INT(ab_unmap.aux_dtanoage)
                         AND crapagp.cdagenci = gnapses.cdagenci 
                       NO-LOCK NO-ERROR NO-WAIT.

    IF AVAILABLE crapagp THEN
      ASSIGN aux_cdageagr = crapagp.cdageagr.
    ELSE
      ASSIGN aux_cdageagr = gnapses.cdagenci.    

    /* Segundo, monta as informaçoes relativas a cada PAC */
    ASSIGN aux_vlrecpor = 0.
    
    FOR EACH crapage WHERE crapage.cdcooper = INT(ab_unmap.aux_cdcooper)    
                       AND (crapage.insitage = 1  OR  /* Ativo */
                            crapage.insitage = 3)     /* Temporariamente Indisponivel */
                       AND crapage.flgdopgd = TRUE
                       AND (CAN-DO(STRING(par_cdagenci),STRING(crapage.cdagenci))
                          OR par_cdagenci = 0) NO-LOCK
                           BY crapage.nmresage:

        ASSIGN aux_vlrtotal = 0.
                
        /* Controle de visualizaçao por PAC */
        IF (gnapses.nvoperad = 1                 OR
            gnapses.nvoperad = 2)                AND
            gnapses.cdagenci <> crapage.cdagenci AND
            crapage.cdagenci <> aux_cdageagr     THEN
             NEXT.

        /* Para Progrid, os PACs sao agrupados */
        FIND FIRST crapagp WHERE crapagp.idevento = INT(ab_unmap.aux_idevento)
                             AND crapagp.cdcooper = INT(ab_unmap.aux_cdcooper)
                             AND crapagp.dtanoage = INT(ab_unmap.aux_dtanoage)
                             AND crapagp.cdagenci = crapage.cdagenci NO-LOCK NO-ERROR NO-WAIT.

        IF INT(ab_unmap.aux_idevento) = 1 THEN
             DO:
            IF NOT AVAILABLE crapagp   THEN
                      NEXT.  

            IF crapagp.cdagenci <> crapagp.cdageagr THEN
                      NEXT.
             END.
        
        ASSIGN aux_nmresage = crapage.nmresage
               aux_cdufdcop = crapage.cdufdcop
               aux_nmcidade = crapage.nmcidade
               aux_vldivulg = 0.
       
        FIND crapmun WHERE crapmun.cdestado = aux_cdufdcop
                       AND crapmun.dscidade = aux_nmcidade NO-LOCK NO-ERROR NO-WAIT.
                      
        IF AVAILABLE crapmun THEN
           ASSIGN aux_cdcidapa = crapmun.cdcidade.          
                  
        /* Pega os PACS agrupados aux_cdcidapa aux_cdcidafa aux_cdufdcop  aux_nmcidade */
        IF INT(ab_unmap.aux_idevento) = 1 THEN
          FOR EACH bf-crapagp  WHERE bf-crapagp.idevento  = crapagp.idevento      
                                 AND bf-crapagp.cdcooper  = crapagp.cdcooper   
                                 AND bf-crapagp.dtanoage  = crapagp.dtanoage   
                                 AND bf-crapagp.cdageagr  = crapagp.cdagenci   
                                 AND bf-crapagp.cdagenci <> crapagp.cdagenci NO-LOCK,
            FIRST bf-crapage WHERE bf-crapage.cdagenci  = bf-crapagp.cdagenci NO-LOCK 
                                        BY bf-crapage.nmresage:
           
                 ASSIGN aux_nmresage = aux_nmresage + " / " + bf-crapage.nmresage.
            END. 

        FOR EACH crapcdp WHERE crapcdp.cdevento = INT(ab_unmap.aux_cdevento)    
                           AND crapcdp.idevento = INT(ab_unmap.aux_idevento)    
                           AND crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage)    
                           AND crapcdp.tpcuseve = 1 /* custos diretos */        
                           AND crapcdp.cdagenci = crapagp.cdagenci              
                           AND crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper) EXCLUSIVE-LOCK
                               BREAK BY crapcdp.cdcooper
                                        BY crapcdp.cdevento
                                           BY crapcdp.cdcuseve:
          ASSIGN aux_vlrlocal = ?
                 aux_vlalimen = ?
                 aux_vlrecpor = 0
                 aux_vlmateri = 0
                 aux_qtgrppar = 0
                 aux_vlporqui = 0.
                              
          IF(CAN-DO(STRING(ab_unmap.aux_agerepli),STRING(crapage.cdagenci))) THEN
            DO:
              ASSIGN crapcdp.nrcpfcgc = DEC(aux_nrcpfcgc)
                     crapcdp.nrpropos = STRING(aux_nrpropos)
                     crapcdp.nrdocfmd = DEC(aux_nrdocfmd).

              /*CALCULA QUANTIDADE MAXIMA DA TURMA*/
              FIND FIRST crapeap WHERE crapeap.cdcooper = INT(ab_unmap.aux_cdcooper)
                                   AND crapeap.idevento = INT(ab_unmap.aux_idevento)                                     
                                   AND crapeap.cdevento = INT(ab_unmap.aux_cdevento)
                                   AND crapeap.dtanoage = INT(ab_unmap.aux_dtanoage)
                                   AND crapeap.cdagenci = crapage.cdagenci NO-LOCK NO-ERROR NO-WAIT.
               
              IF AVAILABLE crapeap THEN
            DO:
                  IF crapeap.qtmaxtur > 0 THEN
                     DO:
                      ASSIGN aux_qtmaxtur = crapeap.qtmaxtur.
                    END.           
                         ELSE 
                    DO:
                      /* para a frequencia minima */
                      FIND FIRST crabedp WHERE crabedp.idevento = INT(ab_unmap.aux_idevento) 
                                           AND crabedp.cdcooper = INT(ab_unmap.aux_cdcooper)
                                           AND crabedp.dtanoage = INT(ab_unmap.aux_dtanoage) 
                                           AND crabedp.cdevento = INT(ab_unmap.aux_cdevento) NO-LOCK NO-ERROR NO-WAIT.
                                           
                      IF AVAILABLE crabedp THEN
                        DO:                      
                          IF crabedp.qtmaxtur > 0 THEN
                            DO:
                              ASSIGN aux_qtmaxtur = crabedp.qtmaxtur.
                     END.
                          ELSE
                            DO:
                              FIND FIRST crabedp WHERE crabedp.idevento = INT(ab_unmap.aux_idevento)
                                                   AND crabedp.cdcooper = 0
                                                   AND crabedp.dtanoage = 0
                                                   AND crabedp.cdevento = INT(ab_unmap.aux_cdevento) NO-LOCK NO-ERROR NO-WAIT.

                              IF AVAILABLE crabedp THEN
                                DO:
                                  ASSIGN aux_qtmaxtur = crabedp.qtmaxtur.
                                END.       
                            END.
                        END.
                    END.
                END. /* AVAIL CRAPEAP*/ 
              ELSE /*NOT AVAILABLE crapeap */
                DO:
                  /* para a frequencia minima */
                  FIND FIRST crabedp WHERE crabedp.idevento = INT(ab_unmap.aux_idevento) AND 
                                           crabedp.cdcooper = INT(ab_unmap.aux_cdcooper) AND
                                           crabedp.dtanoage = INT(ab_unmap.aux_dtanoage) AND 
                                           crabedp.cdevento = INT(ab_unmap.aux_cdevento) NO-LOCK NO-ERROR NO-WAIT. 

                  IF AVAILABLE crabedp THEN
                DO:
                      IF crabedp.qtmaxtur > 0 THEN
                        DO:
                          ASSIGN aux_qtmaxtur = crabedp.qtmaxtur.
                END.    
                ELSE
                        DO:
                          FIND FIRST crabedp WHERE crabedp.idevento = INT(ab_unmap.aux_idevento)
                                               AND crabedp.cdcooper = 0
                                               AND crabedp.dtanoage = 0
                                               AND crabedp.cdevento = INT(ab_unmap.aux_cdevento) NO-LOCK NO-ERROR NO-WAIT.

                          IF AVAILABLE crabedp THEN
                            DO:
                              ASSIGN aux_qtmaxtur = crabedp.qtmaxtur.
                            END.         
                        END.
                    END.
                END. /*FIM VERIFICACAO DE QTD TURMAS */
                
              IF aux_qtmaxtur = 0  THEN
                DO:
                  RUN RodaJavaScript("alert('Quantidade de participantes do evento não cadastrada. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                  ASSIGN aux_flgerror = TRUE.
                  UNDO TRANSACAO, LEAVE TRANSACAO.
                END.
                
              IF crapcdp.cdcuseve = 2 THEN /* Calcula o Local */
                DO:
                  FIND FIRST crapppa WHERE crapppa.idevento = INT(ab_unmap.aux_idevento)
                                       AND crapppa.cdcooper = INT(ab_unmap.aux_cdcooper)
                                       AND crapppa.dtanoage = INT(ab_unmap.aux_dtanoage)
                                       AND crapppa.cdagenci = crapagp.cdagenci
                                       AND crapppa.vlaluloc <> ? NO-LOCK NO-ERROR NO-WAIT.
                 
                  IF AVAILABLE crapppa THEN
                DO:
                      ASSIGN aux_vlrlocal = (crapppa.vlaluloc * aux_qtdiaeve).
                END.      
                ELSE
                    DO: /* Regional*/
                      FIND FIRST crapppr WHERE crapppr.idevento = INT(ab_unmap.aux_idevento)
                                           AND crapppr.cdcooper = INT(ab_unmap.aux_cdcooper)
                                           AND crapppr.dtanoage = INT(ab_unmap.aux_dtanoage)
                                           AND crapppr.vlaluloc <> ? NO-LOCK NO-ERROR NO-WAIT.
                                           
                      IF AVAILABLE crapppr THEN
                        DO:
                          ASSIGN aux_vlrlocal =  (crapppr.vlaluloc * aux_qtdiaeve).
            END.
          ELSE
                        DO: /*Cooperativa*/
                          FIND FIRST crapppc WHERE crapppc.idevento = INT(ab_unmap.aux_idevento)
                                               AND crapppc.cdcooper = INT(ab_unmap.aux_cdcooper)
                                               AND crapppc.dtanoage = INT(ab_unmap.aux_dtanoage)
                                               AND crapppc.vlaluloc <> ? NO-LOCK NO-ERROR NO-WAIT.
             
                          IF AVAILABLE crapppc THEN
                            DO:
                              ASSIGN aux_vlrlocal = (crapppc.vlaluloc * aux_qtdiaeve).
                            END. 
                        END.                
                    END. 
                                   
                  IF aux_vlrlocal = ?  THEN
                    DO:
                      RUN RodaJavaScript("alert('Valor de local não cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                      ASSIGN aux_flgerror = TRUE.
                      UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.
                END. /* Fim Calcula o Local */
                                   
              IF crapcdp.cdcuseve = 3 THEN /* Calcula o Alimentacao */ 
                DO:
                  FIND FIRST crapppa WHERE crapppa.idevento = INT(ab_unmap.aux_idevento)
                                       AND crapppa.cdcooper = INT(ab_unmap.aux_cdcooper)
                                       AND crapppa.dtanoage = INT(ab_unmap.aux_dtanoage)
                                       AND crapppa.cdagenci = crapagp.cdagenci
                                       AND crapppa.vlporali <> ? NO-LOCK NO-ERROR NO-WAIT.
            
                  IF AVAILABLE crapppa THEN
                    DO:
                      ASSIGN aux_vlalimen =  crapppa.vlporali.
                    END.
                  ELSE
                    DO: 
                      /* Regional*/
                      FIND FIRST crapppr WHERE crapppr.idevento = INT(ab_unmap.aux_idevento)
                                           AND crapppr.cdcooper = INT(ab_unmap.aux_cdcooper)
                                           AND crapppr.dtanoage = INT(ab_unmap.aux_dtanoage)
                                           AND crapppr.vlporali <> ? NO-LOCK NO-ERROR NO-WAIT.
                                   
                      IF AVAILABLE crapppr THEN
                        DO:
                          ASSIGN aux_vlalimen = crapppr.vlporali.
            END.
                      ELSE
                        DO: 
                          /*Copperativa*/
                          FIND FIRST crapppc WHERE crapppc.idevento = INT(ab_unmap.aux_idevento)
                                               AND crapppc.cdcooper = INT(ab_unmap.aux_cdcooper)
                                               AND crapppc.dtanoage = INT(ab_unmap.aux_dtanoage)
                                               AND crapppc.vlporali <> ? NO-LOCK NO-ERROR NO-WAIT.
                                             
                          IF AVAILABLE crapppc THEN
                            DO:
                              ASSIGN aux_vlalimen = crapppc.vlporali.
          END.          
                        END.                
                    END. 
          
                  IF aux_vlalimen = ?  THEN
                    DO:
                      RUN RodaJavaScript("alert('Valor de alimentação não cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                      ASSIGN aux_flgerror = TRUE.
                      UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.
                END. /* Fim Calcula o Alimentacao */
                
          FIND FIRST crapppc WHERE crapppc.idevento = INT(ab_unmap.aux_idevento)
                               AND crapppc.cdcooper = INT(ab_unmap.aux_cdcooper)
                               AND crapppc.dtanoage = INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR NO-WAIT.                                   
                               
              IF AVAILABLE crapppc THEN
              ASSIGN aux_vlporqui = crapppc.vlporqui.         
              
              IF aux_vlporqui = 0 AND aux_cdcidafa <> aux_cdcidapa THEN
          DO:
                  RUN RodaJavaScript("alert('Valor por quilômetro não cadastrado para este Ano/Cooperativa. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                  ASSIGN aux_flgerror = TRUE.
                  UNDO TRANSACAO, LEAVE TRANSACAO.
          END.
          
              ASSIGN aux_vlalimen = (aux_vlalimen * aux_qtmaxtur * aux_qtdiaeve).           
              
              IF crapcdp.cdcuseve = 7 THEN /* MATERIAL DE DIVULGACAO */  
          DO:
                  /* POR EVENTO */
                  FOR EACH craprep WHERE craprep.idevento = INT(ab_unmap.aux_idevento) 
                                     AND craprep.cdcooper = 0
                                     AND craprep.cdevento = INT(ab_unmap.aux_cdevento) NO-LOCK:
                    
                    FIND gnaprdp WHERE gnaprdp.idevento = INTEGER(ab_unmap.aux_idevento)
                                   AND gnaprdp.cdcooper = 0
                                   AND gnaprdp.idsitrec = 1
                                   AND (gnaprdp.cdtiprec = ? OR gnaprdp.cdtiprec = 0)
                                   AND gnaprdp.nrseqdig = craprep.nrseqdig NO-LOCK NO-ERROR NO-WAIT.
                                   
                    IF AVAILABLE gnaprdp THEN               
                      DO:
                        RUN RodaJavaScript("alert('O recurso de divulgação do evento(" + STRING(UPPER(gnaprdp.dsrecurs)) + ") associado ao evento, não possui tipo de recurso cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                        ASSIGN aux_flgerror = TRUE.
                        UNDO TRANSACAO, LEAVE TRANSACAO.
          END.
          
                    FIND FIRST gnaprdp WHERE gnaprdp.idevento = INTEGER(ab_unmap.aux_idevento)
                                         AND gnaprdp.cdcooper = 0
                                         AND gnaprdp.idsitrec = 1
                                         AND gnaprdp.cdtiprec = 2
                                         AND gnaprdp.nrseqdig = craprep.nrseqdig NO-LOCK NO-ERROR NO-WAIT.
                    
                    IF AVAILABLE gnaprdp THEN
          DO:
                        IF aux_nrdocfmd = "" OR aux_nrdocfmd = ? OR aux_nrdocfmd = "0" THEN
                          DO:
                            RUN RodaJavaScript("alert('Este evento possui recursos de divulgação. Favor informar o FORNECEDOR DE DIVULGAÇÃO antes de informar o FORNECEDOR T&D.')").
                            ASSIGN aux_flgerror = TRUE.
                            UNDO TRANSACAO, LEAVE TRANSACAO.  
          END.
          
                        /* Busca o valor do Recurso por Ano*/
                        FIND crapvra WHERE crapvra.idevento = INT(ab_unmap.aux_idevento)
                                       AND crapvra.cdcooper = 0
                                       AND crapvra.nrseqdig = gnaprdp.nrseqdig
                                       AND crapvra.dtanoage = INT(ab_unmap.aux_dtanoage)
                                       AND crapvra.nrcpfcgc = DEC(aux_nrdocfmd) NO-LOCK NO-ERROR NO-WAIT.
      
                        IF NOT AVAILABLE crapvra THEN        
                          DO:
                            RUN RodaJavaScript("alert('O recurso de divulgação(" + STRING(UPPER(gnaprdp.dsrecurs)) + ") associado ao evento, não possui valor cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                            ASSIGN aux_flgerror = TRUE.
                            UNDO TRANSACAO, LEAVE TRANSACAO.
                          END.
                        
                        FIND FIRST crapedp WHERE crapedp.idevento = INT(ab_unmap.aux_idevento) 
                                             AND crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)
                                             AND crapedp.dtanoage = INT(ab_unmap.aux_dtanoage) 
                                             AND crapedp.cdevento = INT(ab_unmap.aux_cdevento) NO-LOCK NO-ERROR NO-WAIT.
                              
                        FIND FIRST crapqmd WHERE crapqmd.dtanoage = INT(ab_unmap.aux_dtanoage)
                                             AND crapqmd.cdcopqtd = INT(ab_unmap.aux_cdcooper)
                                             AND crapqmd.cdagenci = crapagp.cdagenci
                                             AND crapqmd.tpevento = crapedp.tpevento
                                             AND crapqmd.idevento = INT(ab_unmap.aux_idevento)
                                             AND crapqmd.cdcooper = 0
                                             AND crapqmd.nrseqdig = craprep.nrseqdig NO-LOCK NO-ERROR NO-WAIT.
          
                        IF NOT AVAILABLE crapqmd THEN        
          DO:
                        
                            RUN RodaJavaScript("alert('Quantidade de materiais de divulgação(" + STRING(UPPER(gnaprdp.dsrecurs)) + ") associado ao evento, não possui quantidade cadastrada. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                            ASSIGN aux_flgerror = TRUE.
                            UNDO TRANSACAO, LEAVE TRANSACAO.
                          END.
                        
                        IF aux_vldivulg = ? THEN
                          ASSIGN aux_vldivulg = 0.
                                          
                        ASSIGN aux_vldivulg = aux_vldivulg + (crapqmd.qtrecnes * crapvra.vlrecano).
                                      
          END.
                      
                  END. /* FIM POR EVENTO */
                                
                  /* POR PA */
                  FOR EACH craprpe WHERE craprpe.idevento = INT(ab_unmap.aux_idevento) 
                                     AND craprpe.cdcooper = 0
                                     AND craprpe.cdevento = INT(ab_unmap.aux_cdevento)
                                     AND craprpe.cdagenci = crapagp.cdagenci
                                     AND craprpe.cdcopage = INT(ab_unmap.aux_cdcooper) NO-LOCK:
                    
                    FIND gnaprdp WHERE gnaprdp.idevento = INTEGER(ab_unmap.aux_idevento)
                                   AND gnaprdp.cdcooper = 0
                                   AND gnaprdp.idsitrec = 1
                                   AND (gnaprdp.cdtiprec = ? OR gnaprdp.cdtiprec = 0)
                                   AND gnaprdp.nrseqdig = craprpe.nrseqdig NO-LOCK NO-ERROR NO-WAIT.
                                  
                    IF AVAILABLE gnaprdp THEN               
                      DO:
                        RUN RodaJavaScript("alert('O recurso de divulgação(" + STRING(UPPER(gnaprdp.dsrecurs)) + ") do PA(" + STRING(UPPER(crapage.nmresage)) + ") associado ao evento, não possui tipo de recurso cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                        ASSIGN aux_flgerror = TRUE.
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                      END.  
         
                    FIND FIRST gnaprdp WHERE gnaprdp.idevento = INTEGER(ab_unmap.aux_idevento)
                                         AND gnaprdp.cdcooper = 0
                                         AND gnaprdp.idsitrec = 1
                                         AND gnaprdp.cdtiprec = 2
                                         AND gnaprdp.nrseqdig = craprpe.nrseqdig NO-LOCK NO-ERROR NO-WAIT.
            
                    IF AVAILABLE gnaprdp THEN
                      DO: 
                        IF aux_nrdocfmd = "" OR aux_nrdocfmd = ? OR aux_nrdocfmd = "0" THEN
                          DO:
                            RUN RodaJavaScript("alert('Este evento possui recursos de divulgação. Favor informar o FORNECEDOR DE DIVULGAÇÃO antes de informar o FORNECEDOR T&D.')").
                            ASSIGN aux_flgerror = TRUE.
                            UNDO TRANSACAO, LEAVE TRANSACAO.  
                          END.

            /* Busca oo valor do Recurso por Ano*/
            FIND crapvra WHERE crapvra.idevento = INT(ab_unmap.aux_idevento)
                           AND crapvra.cdcooper = 0
                                       AND crapvra.nrseqdig = gnaprdp.nrseqdig
                           AND crapvra.dtanoage = INT(ab_unmap.aux_dtanoage)
                                       AND crapvra.nrcpfcgc = DEC(aux_nrdocfmd) NO-LOCK NO-ERROR NO-WAIT.
            
             IF NOT AVAILABLE crapvra THEN        
               DO:
                            RUN RodaJavaScript("alert('O recurso de divulgação(" + STRING(UPPER(gnaprdp.dsrecurs)) + ") do PA(" + STRING(UPPER(crapage.nmresage)) + ") associado ao evento não possui valor cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                            ASSIGN aux_flgerror = TRUE.
                            UNDO TRANSACAO, LEAVE TRANSACAO.
                          END.
                          
                        /* para a frequencia minima */
                        FIND FIRST crapedp WHERE crapedp.idevento = INT(ab_unmap.aux_idevento) 
                                             AND crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)
                                             AND crapedp.dtanoage = INT(ab_unmap.aux_dtanoage) 
                                             AND crapedp.cdevento = INT(ab_unmap.aux_cdevento) NO-LOCK NO-ERROR NO-WAIT.
                                               
                        FIND FIRST crapqmd WHERE crapqmd.dtanoage = INT(ab_unmap.aux_dtanoage)
                                             AND crapqmd.cdcopqtd = INT(ab_unmap.aux_cdcooper)
                                             AND crapqmd.cdagenci = crapagp.cdagenci
                                             AND crapqmd.tpevento = crapedp.tpevento
                                             AND crapqmd.idevento = INT(ab_unmap.aux_idevento)
                                             AND crapqmd.cdcooper = 0
                                             AND crapqmd.nrseqdig = craprpe.nrseqdig NO-LOCK NO-ERROR NO-WAIT.
                        
                        IF NOT AVAILABLE crapqmd THEN        
                          DO:
                            RUN RodaJavaScript("alert('Quantidade de materiais de divulgação(" + STRING(UPPER(gnaprdp.dsrecurs)) + ") do PA(" + STRING(UPPER(crapage.nmresage)) + ") associado ao evento, não possui quantidade cadastrada. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                            ASSIGN aux_flgerror = TRUE.
                            UNDO TRANSACAO, LEAVE TRANSACAO.
                          END.
                                        
                        IF aux_vldivulg = ? THEN
                          ASSIGN aux_vldivulg = 0.
                        
                        ASSIGN aux_vldivulg = aux_vldivulg + (crapqmd.qtrecnes * crapvra.vlrecano).
                                          
                      END.                
                  END.  /* FIM POR PA */
                  
                  /* DIVULGACAO POR FORNECEDOR */
                  FOR EACH craprdf WHERE craprdf.idevento = INTEGER(ab_unmap.aux_idevento)
                                     AND craprdf.cdcooper = 0
                                     AND craprdf.nrcpfcgc = DEC(crapcdp.nrcpfcgc)
                                     AND craprdf.dspropos = aux_nrpropos NO-LOCK:
                                    
                    FIND gnaprdp WHERE gnaprdp.idevento = INTEGER(ab_unmap.aux_idevento)
                                   AND gnaprdp.cdcooper = 0
                                   AND gnaprdp.idsitrec = 1
                                   AND (gnaprdp.cdtiprec = ? OR gnaprdp.cdtiprec = 0)
                                   AND gnaprdp.nrseqdig = craprdf.nrseqdig NO-LOCK NO-ERROR NO-WAIT.
                                   
                    IF AVAILABLE gnaprdp THEN               
                      DO:
                        RUN RodaJavaScript("alert('O recurso de divulgação(" + STRING(UPPER(gnaprdp.dsrecurs)) + ") do fornecedor associado ao evento, não possui tipo de recurso cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                        ASSIGN aux_flgerror = TRUE.
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                      END.  
                    
                    FIND FIRST gnaprdp WHERE gnaprdp.idevento = INTEGER(ab_unmap.aux_idevento)
                                         AND gnaprdp.cdcooper = 0
                                         AND gnaprdp.idsitrec = 1
                                         AND gnaprdp.cdtiprec = 2
                                         AND gnaprdp.nrseqdig = craprdf.nrseqdig NO-LOCK NO-ERROR NO-WAIT.
                    
                    IF AVAILABLE gnaprdp THEN
                      DO: 
                        IF aux_nrdocfmd = "" OR aux_nrdocfmd = ? OR aux_nrdocfmd = "0" THEN
                          DO:
                            RUN RodaJavaScript("alert('Este evento possui recursos de divulgação. Favor informar o FORNECEDOR DE DIVULGAÇÃO antes de informar o FORNECEDOR T&D.')").
                            ASSIGN aux_flgerror = TRUE.
                            UNDO TRANSACAO, LEAVE TRANSACAO.  
               END.
                
                        /* Busca oo valor do Recurso por Ano*/
                        FIND crapvra WHERE crapvra.idevento = INT(ab_unmap.aux_idevento)
                                       AND crapvra.cdcooper = 0
                                       AND crapvra.nrseqdig = gnaprdp.nrseqdig
                                       AND crapvra.dtanoage = INT(ab_unmap.aux_dtanoage)
                                       AND crapvra.nrcpfcgc = DEC(aux_nrdocfmd) NO-LOCK NO-ERROR NO-WAIT.
                            
                        IF NOT AVAILABLE crapvra THEN        
                          DO:
                            RUN RodaJavaScript("alert('O recurso de divulgação(" + STRING(UPPER(gnaprdp.dsrecurs)) + ") do fornecedor associado ao evento, não possui valor cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                            ASSIGN aux_flgerror = TRUE.
                            UNDO TRANSACAO, LEAVE TRANSACAO.
                          END.

                        /* para a frequencia minima */
                        FIND FIRST crapedp WHERE crapedp.idevento = INT(ab_unmap.aux_idevento) 
                                             AND crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)
                                             AND crapedp.dtanoage = INT(ab_unmap.aux_dtanoage) 
                                             AND crapedp.cdevento = INT(ab_unmap.aux_cdevento) NO-LOCK NO-ERROR NO-WAIT.
                                  
                        FIND FIRST crapqmd WHERE crapqmd.dtanoage = INT(ab_unmap.aux_dtanoage)
                                             AND crapqmd.cdcopqtd = INT(ab_unmap.aux_cdcooper)
                                             AND crapqmd.cdagenci = crapagp.cdagenci
                                             AND crapqmd.tpevento = crapedp.tpevento
                                             AND crapqmd.idevento = INT(ab_unmap.aux_idevento)
                                             AND crapqmd.cdcooper = 0
                                             AND crapqmd.nrseqdig = craprdf.nrseqdig NO-LOCK NO-ERROR NO-WAIT.
                                
                        IF NOT AVAILABLE crapqmd THEN        
              DO:
                            RUN RodaJavaScript("alert('Quantidade de materiais de divulgação(" + STRING(UPPER(gnaprdp.dsrecurs)) + ") associado ao evento, não possui quantidade cadastrada. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                            ASSIGN aux_flgerror = TRUE.
                            UNDO TRANSACAO, LEAVE TRANSACAO.
              END.
           
                        IF aux_vldivulg = ? THEN
                          ASSIGN aux_vldivulg = 0.
                                        
                        ASSIGN aux_vldivulg = aux_vldivulg + (crapqmd.qtrecnes * crapvra.vlrecano).
          
          END.
                  END. /* FIM DIVULGACAO POR FORNECEDOR */
                END. /* FIM MATERIAL DE DIVULGACAO */
       
              IF crapcdp.cdcuseve = 5 THEN /*TRANSPORTE*/
                DO:                  
        FIND gnappdp WHERE gnappdp.cdcooper = 0
                       AND gnappdp.idevento = INT(ab_unmap.aux_idevento)
                       AND gnappdp.cdevento = INT(ab_unmap.aux_cdevento)
                       AND gnappdp.nrcpfcgc = DEC(aux_nrcpfcgc)
                       AND gnappdp.nrpropos = aux_nrpropos NO-LOCK NO-ERROR NO-WAIT.
          
        IF AVAILABLE gnappdp THEN 
        DO:
                      IF gnappdp.idtrainc = "N" OR gnappdp.idtrainc = "" OR gnappdp.idtrainc = ? THEN
            DO:
                          FIND gnfacep WHERE gnfacep.cdcooper = 0               
                                         AND gnfacep.idevento = INTEGER(ab_unmap.aux_idevento)
                                         AND gnfacep.nrcpfcgc = DEC(aux_nrcpfcgc)
                                         AND gnfacep.nrpropos = aux_nrpropos NO-LOCK NO-ERROR NO-WAIT.
                    
                          IF AVAILABLE gnfacep THEN
                            DO:
                              FIND FIRST gnapfep WHERE gnapfep.idevento = INTEGER(ab_unmap.aux_idevento)
                                                   AND gnapfep.cdcooper = 0
                                                   AND gnapfep.nrcpfcgc = DECIMAL(aux_nrcpfcgc)
                                                   AND gnapfep.cdfacili = gnfacep.cdfacili NO-LOCK NO-ERROR NO-WAIT.
         
                              IF NOT AVAILABLE gnapfep THEN
                                DO:
                                  RUN RodaJavaScript("alert('Cidade do facilitador não cadastrada para a proposta do FORNECEDOR T&D. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                                  ASSIGN aux_flgerror = TRUE.
                                  UNDO TRANSACAO, LEAVE TRANSACAO.
                                END. 
                              ELSE
                                DO:
                                  IF gnapfep.cdcidade = 0 OR gnapfep.cdcidade = ? THEN
                                    DO:
                                      RUN RodaJavaScript("alert('Cidade do facilitador não cadastrada para a proposta do FORNECEDOR T&D. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                                      ASSIGN aux_flgerror = TRUE.
                                      UNDO TRANSACAO, LEAVE TRANSACAO.
                                    END.
                                  ELSE
                                    DO:
                                      ASSIGN aux_cdcidafa = gnapfep.cdcidade.
                                    END.
                                END.
                            END.
                          ELSE 
                    DO:
                              RUN RodaJavaScript("alert('Facilitador não cadastrado para a proposta do FORNECEDOR T&D. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                              ASSIGN aux_flgerror = TRUE.
                              UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.
                         
                          IF STRING(aux_cdcidafa) = "" OR STRING(aux_cdcidafa) = ? OR STRING(aux_cdcidafa) = "0" THEN
                            DO:
                              RUN RodaJavaScript("alert('Cadastre a cidade de origem do facilitador. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                              ASSIGN aux_flgerror = TRUE.
                              UNDO TRANSACAO, LEAVE TRANSACAO.
                END.
                            
                          IF aux_cdcidafa <> aux_cdcidapa THEN
                            DO:                              
                              FIND FIRST crapdod WHERE (crapdod.cdcidori = aux_cdcidafa AND crapdod.cdciddes = aux_cdcidapa) 
                                                    OR (crapdod.cdcidori = aux_cdcidapa AND crapdod.cdciddes = aux_cdcidafa) NO-LOCK NO-ERROR NO-WAIT.
                
                IF NOT AVAILABLE crapdod THEN
                DO:
                                  RUN RodaJavaScript("alert('Distância entre o Facilitador e o PA(" + UPPER(crapage.nmresage) + ") não cadastrada. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                                  ASSIGN aux_flgerror = TRUE.
                                  UNDO TRANSACAO, LEAVE TRANSACAO.
                END.
               
                ASSIGN aux_vltransp = (aux_qtdiaeve *(crapdod.qtquidod * aux_vlporqui)) * 2.
            END.
                          ELSE
                            ASSIGN aux_vltransp = 0.
                        END. /* FIM IF gnappdp.idtrainc = "N" */
                    END. /* FIM IF AVAILABLE gnappdp */
                END. /* FIM TRANSPORTE */ 
                
             IF crapcdp.cdcuseve = 4 THEN /* MATERIAIS */
               DO:
                 /* RECURSOS POR EVENTO */
                 ASSIGN aux_vlmateri = 0.
                 
                 FOR EACH craprep WHERE craprep.idevento = INT(ab_unmap.aux_idevento) 
                                    AND craprep.cdcooper = 0
                                    AND craprep.cdevento = INT(ab_unmap.aux_cdevento) NO-LOCK:
                    
                    FIND gnaprdp WHERE gnaprdp.idevento = INTEGER(ab_unmap.aux_idevento)
                                   AND gnaprdp.cdcooper = 0
                                   AND gnaprdp.idsitrec = 1
                                   AND (gnaprdp.cdtiprec = ? OR gnaprdp.cdtiprec = 0)
                                   AND gnaprdp.nrseqdig = craprep.nrseqdig NO-LOCK NO-ERROR NO-WAIT.
                                   
                    IF AVAILABLE gnaprdp THEN               
                      DO:
                        RUN RodaJavaScript("alert('O recurso por evento(" + STRING(UPPER(gnaprdp.dsrecurs)) + ") associado ao evento, não possui tipo de recurso cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                        ASSIGN aux_flgerror = TRUE.
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                      END.  
                                               
                    FIND FIRST gnaprdp WHERE gnaprdp.idevento = INTEGER(ab_unmap.aux_idevento)
                                         AND gnaprdp.cdcooper = 0
                                         AND gnaprdp.idsitrec = 1
                                         AND (gnaprdp.cdtiprec = 3 OR  gnaprdp.cdtiprec = 4) 
                                         AND gnaprdp.nrseqdig = craprep.nrseqdig NO-LOCK NO-ERROR NO-WAIT.
                    
                    IF AVAILABLE gnaprdp THEN
                      DO:
                        
                        /* Busca oo valor do Recurso por Ano*/
                        FIND crapvra WHERE crapvra.idevento = INT(ab_unmap.aux_idevento)
                                       AND crapvra.cdcooper = 0
                                       AND crapvra.nrseqdig = gnaprdp.nrseqdig
                                       AND crapvra.dtanoage = INT(ab_unmap.aux_dtanoage)
                                       AND crapvra.cdcopvlr = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR NO-WAIT.
                        
                        IF NOT AVAILABLE crapvra THEN        
                          DO:
                            RUN RodaJavaScript("alert('O recurso(" + STRING(UPPER(gnaprdp.dsrecurs)) + ") por evento associado ao evento, não possui valor cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                            ASSIGN aux_flgerror = TRUE.
                            UNDO TRANSACAO, LEAVE TRANSACAO.
                          END.
                        
                        IF gnaprdp.idrecpor = 1 THEN /* POR EVENTO*/
                          DO:
                            IF craprep.qtreceve = ? OR craprep.qtreceve = 0 THEN
                              DO:
                                RUN RodaJavaScript("alert('Quantidades de materiais por evento não cadastradas para o recurso(" + STRING(UPPER(gnaprdp.dsrecurs)) + "). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                                ASSIGN aux_flgerror = TRUE.
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                              END.
                            ASSIGN aux_vlrecpor = craprep.qtreceve.
                          END.
                        ELSE IF gnaprdp.idrecpor = 2 THEN /* POR PARTICIPANTES */
                          DO:
                            ASSIGN aux_vlrecpor = aux_qtmaxtur.
                          END.  
                        ELSE IF gnaprdp.idrecpor = 3 THEN /* POR GRUPO DE PARTICIPANTES */
                          DO:
                            IF craprep.qtreceve = ? OR craprep.qtreceve = 0 OR
                               craprep.qtgrppar = ? OR craprep.qtgrppar = 0 THEN
                              DO:
                                RUN RodaJavaScript("alert('Quantidades de materiais por grupo de participantes não cadastradas para o recurso(" + STRING(UPPER(gnaprdp.dsrecurs)) + "). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                                ASSIGN aux_flgerror = TRUE.
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                              END.
                            
                            ASSIGN aux_vlrecpor = (aux_qtmaxtur / craprep.qtgrppar) * craprep.qtreceve.  
                          END.
           
                        IF aux_vlmateri = ? THEN
                          ASSIGN aux_vlmateri = 0.
                          
                        IF aux_vlrecpor = ? THEN
                          ASSIGN aux_vlrecpor = 0.
                          
                        ASSIGN aux_vlmateri = aux_vlmateri + (aux_vlrecpor * (IF crapvra.vlrecano = ? THEN 0 ELSE crapvra.vlrecano)).
                      
        END. 
                 END. /* RECURSOS POR EVENTO */
             
                /* RECURSOS POR PA */
                FOR EACH craprpe WHERE craprpe.idevento = INT(ab_unmap.aux_idevento) 
                                   AND craprpe.cdcooper = 0
                           AND craprpe.cdevento = INT(ab_unmap.aux_cdevento)
                           AND craprpe.cdagenci = crapagp.cdagenci
                                   AND craprpe.cdcopage = INT(ab_unmap.aux_cdcooper) NO-LOCK:
                                 
                  FIND FIRST gnaprdp WHERE gnaprdp.idevento = INTEGER(ab_unmap.aux_idevento)
                                       AND gnaprdp.cdcooper = 0
                                       AND gnaprdp.idsitrec = 1
                                       AND (gnaprdp.cdtiprec = ? OR gnaprdp.cdtiprec = 0)
                                       AND gnaprdp.nrseqdig = craprpe.nrseqdig NO-LOCK NO-ERROR NO-WAIT.
                               
                  IF AVAILABLE gnaprdp THEN               
                    DO:
                      RUN RodaJavaScript("alert('O recurso(" + STRING(UPPER(gnaprdp.dsrecurs)) + ") do PA(" + UPPER(crapage.nmresage) + ") associado ao evento, não possui tipo de recurso cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                      ASSIGN aux_flgerror = TRUE.
                      UNDO TRANSACAO, LEAVE TRANSACAO.
                    END. 
                      
                  FIND gnaprdp WHERE gnaprdp.idevento = craprpe.idevento
                                 AND gnaprdp.cdcooper = 0
                                 AND gnaprdp.idsitrec = 1
                                 AND (gnaprdp.cdtiprec = 3 OR  gnaprdp.cdtiprec = 4) 
                                 AND gnaprdp.nrseqdig = craprpe.nrseqdig NO-LOCK NO-ERROR NO-WAIT.

                  IF AVAILABLE gnaprdp THEN
                    DO:                        
                      /* Busca oo valor do Recurso por Ano*/
                      FIND crapvra WHERE crapvra.idevento = INT(ab_unmap.aux_idevento)
                                     AND crapvra.cdcooper = 0
                                     AND crapvra.nrseqdig = gnaprdp.nrseqdig
                                     AND crapvra.dtanoage = INT(ab_unmap.aux_dtanoage)
                                     AND crapvra.cdcopvlr = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR NO-WAIT.
                      
                      IF NOT AVAILABLE crapvra THEN        
                        DO:
                          RUN RodaJavaScript("alert('O recurso do PA (" + STRING(UPPER(gnaprdp.dsrecurs)) + ") associado ao evento, não possui valor cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                          ASSIGN aux_flgerror = TRUE.
                          UNDO TRANSACAO, LEAVE TRANSACAO.
                        END.

                      IF gnaprdp.idrecpor = 1 THEN /* POR EVENTO*/
                        DO:
                          IF craprpe.qtrecage = ? OR craprpe.qtrecage = 0 THEN
                            DO:
                              RUN RodaJavaScript("alert('Quantidades de materiais não cadastradas por PA para o recurso(" + STRING(UPPER(gnaprdp.dsrecurs)) + "). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                              ASSIGN aux_flgerror = TRUE.
                              UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
                            
                          ASSIGN aux_vlrecpor = craprpe.qtrecage.
                        END.
                      ELSE IF gnaprdp.idrecpor = 2 THEN /* POR PARTICIPANTES */
                        DO:
                          ASSIGN aux_vlrecpor = aux_qtmaxtur.
                        END.  
                      ELSE IF gnaprdp.idrecpor = 3 THEN /* POR GRUPO DE PARTICIPANTES */
                        DO:
                          IF craprpe.qtrecage = ? OR craprpe.qtrecage = 0 OR
                             craprpe.qtgrppar = ? OR craprpe.qtgrppar = 0 THEN
                            DO:
                              RUN RodaJavaScript("alert('Quantidades de materiais não cadastradas por PA para o recurso(" + STRING(UPPER(gnaprdp.dsrecurs)) + "). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                              ASSIGN aux_flgerror = TRUE.
                              UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
                          ASSIGN aux_vlrecpor = (aux_qtmaxtur / craprpe.qtgrppar) * craprpe.qtrecage.  
                        END.
                    
                      IF aux_vlmateri = ? THEN
                        ASSIGN aux_vlmateri = 0.
                        
                      IF aux_vlrecpor = ? THEN
                        ASSIGN aux_vlrecpor = 0.
                            
                      ASSIGN aux_vlmateri = aux_vlmateri + (aux_vlrecpor * crapvra.vlrecano).
                      
                    END.
                END. /* FIM RECURSOS POR PA */
                  
                /* RECURSOS POR FORNECEDOR */
                FOR EACH craprdf WHERE craprdf.idevento = INTEGER(ab_unmap.aux_idevento)
                                   AND craprdf.cdcooper = 0
                                   AND craprdf.nrcpfcgc = DEC(aux_nrcpfcgc)
                                   AND craprdf.dspropos = aux_nrpropos NO-LOCK:
                                  
                  FIND FIRST gnaprdp WHERE gnaprdp.idevento = INTEGER(ab_unmap.aux_idevento)
                                       AND gnaprdp.cdcooper = 0
                                       AND gnaprdp.idsitrec = 1
                                       AND (gnaprdp.cdtiprec = ? OR gnaprdp.cdtiprec = 0)
                                       AND gnaprdp.nrseqdig = craprdf.nrseqdig NO-LOCK NO-ERROR NO-WAIT.
                               
                  IF AVAILABLE gnaprdp THEN               
                    DO:
                      RUN RodaJavaScript("alert('O recurso(" + STRING(UPPER(gnaprdp.dsrecurs)) + ") do fornecedor associado ao evento, não possui tipo de recurso cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                      ASSIGN aux_flgerror = TRUE.
                      UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.             
                                    
                  FIND gnaprdp WHERE gnaprdp.idevento = craprdf.idevento
                                 AND gnaprdp.cdcooper = 0
                                 AND gnaprdp.idsitrec = 1
                                 AND (gnaprdp.cdtiprec = 3 OR  gnaprdp.cdtiprec = 4) 
                                 AND gnaprdp.nrseqdig = craprdf.nrseqdig NO-LOCK NO-ERROR NO-WAIT.

                  IF AVAILABLE gnaprdp THEN
                    DO:                        
                      /* Busca oo valor do Recurso por Ano*/
                      FIND crapvra WHERE crapvra.idevento = INT(ab_unmap.aux_idevento)
                                     AND crapvra.cdcooper = 0
                                     AND crapvra.nrseqdig = gnaprdp.nrseqdig
                                     AND crapvra.dtanoage = INT(ab_unmap.aux_dtanoage)
                                     AND crapvra.cdcopvlr = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR NO-WAIT.

                      IF NOT AVAILABLE crapvra THEN        
                        DO:
                          RUN RodaJavaScript("alert('O recurso(" + STRING(UPPER(gnaprdp.dsrecurs)) + ") do fornecedor associado ao evento, não possui valor cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                          ASSIGN aux_flgerror = TRUE.
                          UNDO TRANSACAO, LEAVE TRANSACAO.
                        END.

                      IF gnaprdp.idrecpor = 1 THEN /* POR EVENTO*/
                        DO:
                          IF craprdf.qtrecfor = ? OR craprdf.qtrecfor = 0 THEN
                            DO:
                              RUN RodaJavaScript("alert('Quantidades de materiais não cadastradas por fornecedor para o recurso(" + STRING(UPPER(gnaprdp.dsrecurs)) + "). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                              ASSIGN aux_flgerror = TRUE.
                              UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
                            
                          ASSIGN aux_vlrecpor = craprdf.qtrecfor.
                        END.
                      ELSE IF gnaprdp.idrecpor = 2 THEN /* POR PARTICIPANTES */
                        DO:
                          ASSIGN aux_vlrecpor = aux_qtmaxtur.
                        END.  
                      ELSE IF gnaprdp.idrecpor = 3 THEN /* POR GRUPO DE PARTICIPANTES */
                        DO:
                          IF craprdf.qtrecfor = ? OR craprdf.qtrecfor = 0 OR 
                             craprdf.qtgrppar = ? OR craprdf.qtgrppar = 0 THEN
                            DO:
                              RUN RodaJavaScript("alert('Quantidades de materiais não cadastradas por fornecedor para o recurso(" + STRING(UPPER(gnaprdp.dsrecurs)) + "). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                              ASSIGN aux_flgerror = TRUE.
                              UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
                            
                          ASSIGN aux_vlrecpor = (aux_qtmaxtur / craprdf.qtgrppar) * craprdf.qtrecfor.
                        END.
                    
                      ASSIGN aux_vlmateri = aux_vlmateri + (aux_vlrecpor * (IF crapvra.vlrecano = ? THEN 0 ELSE crapvra.vlrecano)).
                      
                    END.            
                END. /* FIM RECURSOS POR FORNECEDOR */            
              END. /* FIM MATERIAIS */
            
            IF crapcdp.cdcuseve = 6 THEN /*BRINDES*/   
              DO:
                ASSIGN aux_vlbrinde = 0.
                
                /* POR EVENTO */
                FOR EACH craprep WHERE craprep.idevento = INT(ab_unmap.aux_idevento)
                                   AND craprep.cdcooper = 0
                                   AND craprep.cdevento = INT(ab_unmap.aux_cdevento) NO-LOCK:          
        
          FIND gnaprdp WHERE gnaprdp.idevento = INTEGER(ab_unmap.aux_idevento) AND
                             gnaprdp.cdcooper = 0                              AND   
                             gnaprdp.idsitrec = 1                              AND
                             gnaprdp.cdtiprec = 1                              AND
                                     gnaprdp.nrseqdig = craprep.nrseqdig NO-LOCK NO-ERROR NO-WAIT.
         
                  IF AVAILABLE gnaprdp THEN
                    DO:                                            
          /* Busca oo valor do Recurso por Ano*/
          FIND crapvra WHERE crapvra.idevento = INT(ab_unmap.aux_idevento)
                         AND crapvra.cdcooper = 0
                         AND crapvra.nrseqdig = gnaprdp.nrseqdig
                         AND crapvra.dtanoage = INT(ab_unmap.aux_dtanoage)
                         AND crapvra.cdcopvlr = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR NO-WAIT.
          
           IF NOT AVAILABLE crapvra THEN        
             DO:
                          RUN RodaJavaScript("alert('O brinde por evento(" + STRING(UPPER(gnaprdp.dsrecurs)) + ") associado ao evento, não possui valor cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                          ASSIGN aux_flgerror = TRUE.
                          UNDO TRANSACAO, LEAVE TRANSACAO.
                        END.
                                                                      
                      IF gnaprdp.idrecpor = 1 THEN /* POR EVENTO*/
                        DO:
                          IF craprep.qtreceve = ? OR craprep.qtreceve = 0 THEN
                            DO:
                              RUN RodaJavaScript("alert('Quantidades de brindes não cadastradas por evento para o recurso(" + STRING(UPPER(gnaprdp.dsrecurs)) + "). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                              ASSIGN aux_flgerror = TRUE.
                              UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
                      
                          ASSIGN aux_vlrecpor = craprep.qtreceve.
                        END.
                      ELSE IF gnaprdp.idrecpor = 2 THEN /* POR PARTICIPANTES */
                        DO:
                          ASSIGN aux_vlrecpor = aux_qtmaxtur.
                        END.  
                      ELSE IF gnaprdp.idrecpor = 3 THEN /* POR GRUPO DE PARTICIPANTES */
                        DO:
                          IF craprep.qtreceve = ? OR craprep.qtreceve = 0 OR
                             craprep.qtgrppar = ? OR craprep.qtgrppar = 0 THEN
                            DO:
                              RUN RodaJavaScript("alert('Quantidades de brindes não cadastradas por evento para o recurso(" + STRING(UPPER(gnaprdp.dsrecurs)) + "). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                              ASSIGN aux_flgerror = TRUE.
                              UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
                            
                          ASSIGN aux_vlrecpor = (aux_qtmaxtur / craprep.qtgrppar) * craprep.qtreceve.  
                        END.
                    
                    IF aux_vlbrinde = ? THEN
                      ASSIGN aux_vlbrinde = 0.
                    
                    IF aux_vlrecpor = ? THEN
                      ASSIGN aux_vlrecpor = 0.
                      
                    ASSIGN aux_vlbrinde = aux_vlbrinde + (aux_vlrecpor * crapvra.vlrecano).                  
                  END.                          
             END.         
                /* FIM BRINDES POR EVENTO */
              
                /* BRINDES POR PA */
                FOR EACH craprpe WHERE craprpe.idevento = INT(ab_unmap.aux_idevento) 
                                   AND craprpe.cdcooper = 0
                                   AND craprpe.cdevento = INT(ab_unmap.aux_cdevento)
                                   AND craprpe.cdagenci = crapagp.cdagenci
                                   AND craprpe.cdcopage = INT(ab_unmap.aux_cdcooper) NO-LOCK:
                          
                  FIND gnaprdp WHERE gnaprdp.idevento = craprpe.idevento
                                 AND gnaprdp.cdcooper = 0
                                 AND gnaprdp.idsitrec = 1
                                 AND gnaprdp.cdtiprec = 1
                                 AND gnaprdp.nrseqdig = craprpe.nrseqdig NO-LOCK NO-ERROR NO-WAIT.
                                     
                  IF AVAILABLE gnaprdp THEN
                    DO:
                      /* Busca oo valor do Recurso por Ano*/
                      FIND crapvra WHERE crapvra.idevento = INT(ab_unmap.aux_idevento)
                                     AND crapvra.cdcooper = 0
                                     AND crapvra.nrseqdig = gnaprdp.nrseqdig
                                     AND crapvra.dtanoage = INT(ab_unmap.aux_dtanoage)
                                     AND crapvra.cdcopvlr = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR NO-WAIT.

                      IF NOT AVAILABLE crapvra THEN        
                        DO:
                          RUN RodaJavaScript("alert('O brinde(" + STRING(UPPER(gnaprdp.dsrecurs)) + ") do PA(" + STRING(UPPER(crapage.nmresage)) + ") associado ao evento, não possui valor cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                          ASSIGN aux_flgerror = TRUE.
                          UNDO TRANSACAO, LEAVE TRANSACAO.
                        END.
                             
                      IF gnaprdp.idrecpor = 1 THEN /* POR EVENTO*/
                        DO:
                          IF craprpe.qtrecage = ? OR craprpe.qtrecage = 0 THEN
                            DO:
                              RUN RodaJavaScript("alert('Quantidades de brindes por PA não cadastradas para o recurso(" + STRING(UPPER(gnaprdp.dsrecurs)) + "). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                              ASSIGN aux_flgerror = TRUE.
                              UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
                            
                          ASSIGN aux_vlrecpor = craprpe.qtrecage.
                        END.
                      ELSE IF gnaprdp.idrecpor = 2 THEN /* POR PARTICIPANTES */
                        DO:
                          ASSIGN aux_vlrecpor = aux_qtmaxtur.
                        END.  
                      ELSE IF gnaprdp.idrecpor = 3 THEN /* POR GRUPO DE PARTICIPANTES */
                        DO:
                          IF craprpe.qtrecage = ? OR craprpe.qtrecage = 0 OR
                             craprpe.qtgrppar = ? OR craprpe.qtgrppar = 0 THEN
            DO:
                              RUN RodaJavaScript("alert('Quantidades de brindes por PA não cadastradas para o recurso(" + STRING(UPPER(gnaprdp.dsrecurs)) + "). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                              ASSIGN aux_flgerror = TRUE.
                              UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
                            
                          ASSIGN aux_vlrecpor = (aux_qtmaxtur / craprpe.qtgrppar) * craprpe.qtrecage.  
                        END.
                    
                      IF aux_vlbrinde = ? THEN
                        ASSIGN aux_vlbrinde = 0.
                      
                      IF aux_vlrecpor = ? THEN
                        ASSIGN aux_vlrecpor = 0.
                      
                      ASSIGN aux_vlbrinde = aux_vlbrinde + (aux_vlrecpor * crapvra.vlrecano).                  
            END.
                END. /* FIM BRINDES POR PA */
                
                /* BRINDES POR FORNECEDOR */
                FOR EACH craprdf WHERE craprdf.idevento = INT(ab_unmap.aux_idevento)
                                   AND craprdf.cdcooper = 0
                                   AND craprdf.nrcpfcgc = DEC(aux_nrcpfcgc)
                                   AND craprdf.dspropos = aux_nrpropos NO-LOCK:
                  
                  FIND gnaprdp WHERE gnaprdp.idevento = INTEGER(ab_unmap.aux_idevento) AND
                                     gnaprdp.cdcooper = 0                              AND   
                                     gnaprdp.idsitrec = 1                              AND
                                     gnaprdp.cdtiprec = 1                              AND
                                     gnaprdp.nrseqdig = craprdf.nrseqdig NO-LOCK NO-ERROR NO-WAIT.
                                    
                  IF AVAILABLE gnaprdp THEN
                    DO:
                      /* Busca oo valor do Recurso por Ano*/
                      FIND crapvra WHERE crapvra.idevento = INT(ab_unmap.aux_idevento)
                                     AND crapvra.cdcooper = 0
                                     AND crapvra.nrseqdig = gnaprdp.nrseqdig
                                     AND crapvra.dtanoage = INT(ab_unmap.aux_dtanoage)
                                     AND crapvra.cdcopvlr = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR NO-WAIT.
                    
                       IF NOT AVAILABLE crapvra THEN        
                         DO:
                           RUN RodaJavaScript("alert('O brinde(" + STRING(UPPER(gnaprdp.dsrecurs)) + ") por fornecedor associados ao evento, não possui valor cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                           ASSIGN aux_flgerror = TRUE.
                           UNDO TRANSACAO, LEAVE TRANSACAO.
        END.          
        
                      IF gnaprdp.idrecpor = 1 THEN /* POR EVENTO*/
                        DO:
                          IF craprdf.qtrecfor = ? OR craprdf.qtrecfor = 0 THEN
                            DO:
                              RUN RodaJavaScript("alert('Quantidades de brindes por fornecedor não cadastradas para o recurso(" + STRING(UPPER(gnaprdp.dsrecurs)) + "). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                              ASSIGN aux_flgerror = TRUE.
                              UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
       
                          ASSIGN aux_vlrecpor = craprdf.qtrecfor.
                        END.
                      ELSE IF gnaprdp.idrecpor = 2 THEN /* POR PARTICIPANTES */
                        DO:
                          ASSIGN aux_vlrecpor = aux_qtmaxtur.
                        END.  
                      ELSE IF gnaprdp.idrecpor = 3 THEN /* POR GRUPO DE PARTICIPANTES */
                        DO:
                          IF craprdf.qtrecfor = ? OR craprdf.qtrecfor = 0 OR
                             craprdf.qtgrppar = ? OR craprdf.qtgrppar = 0 THEN
        DO:
                              RUN RodaJavaScript("alert('Quantidades de brindes por fornecedor não cadastradas para o recurso(" + STRING(UPPER(gnaprdp.dsrecurs)) + "). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.')").
                              ASSIGN aux_flgerror = TRUE.
                              UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
                            
                          ASSIGN aux_vlrecpor = (aux_qtmaxtur / craprdf.qtgrppar) * craprdf.qtrecfor.
        END.
      
                      IF aux_vlbrinde = ? THEN
                        ASSIGN aux_vlbrinde = 0.
                              
                      IF aux_vlrecpor = ? THEN
                        ASSIGN aux_vlrecpor = 0.
                      
                      ASSIGN aux_vlbrinde = aux_vlbrinde + (aux_vlrecpor * crapvra.vlrecano).
                      
                    END.                      
                END. /* FIM BRINDES POR FORNECEDOR */
              END. /* FIM BRINDES */
          
        CASE crapcdp.cdcuseve:
            WHEN 1 THEN /* Honorários */
            DO:
                  IF par_cdagenci = 0 AND (CAN-DO(STRING(ab_unmap.aux_agerepli),STRING(crapage.cdagenci))) THEN
                    DO:
                      IF (aux_nrcpfcgc = "" OR aux_nrcpfcgc = ? OR aux_nrcpfcgc = "0")
                         AND (aux_nrdocfmd <> "" AND aux_nrdocfmd <> ? AND aux_nrdocfmd <> "0") THEN
                        DO:
                          ASSIGN crapcdp.vlcuseve = 0.
                        END.
                      ELSE
                        ASSIGN crapcdp.vlcuseve = DEC(ab_unmap.aux_vlrhonor).    
                    END.
            END.
            WHEN 2 THEN /* Local */
            DO:
                  IF (CAN-DO(STRING(ab_unmap.aux_agerepli),STRING(crapage.cdagenci))) THEN
                    DO:
                      IF (aux_nrcpfcgc = "" OR aux_nrcpfcgc = ? OR aux_nrcpfcgc = "0")
                         AND (aux_nrdocfmd <> "" AND aux_nrdocfmd <> ? AND aux_nrdocfmd <> "0") THEN
                        DO:
                          ASSIGN crapcdp.vlcuseve = 0.
                        END.
                      ELSE
                        ASSIGN crapcdp.vlcuseve = aux_vlrlocal.
                    END.
            END.
              WHEN 3 THEN /* Alimentaçao */
                DO: 
                  IF(CAN-DO(STRING(ab_unmap.aux_agerepli),STRING(crapage.cdagenci))) THEN
                    DO:
                      IF (aux_nrcpfcgc = "" OR aux_nrcpfcgc = ? OR aux_nrcpfcgc = "0")
                         AND (aux_nrdocfmd <> "" AND aux_nrdocfmd <> ? AND aux_nrdocfmd <> "0") THEN
            DO:
                          ASSIGN crapcdp.vlcuseve = 0.
                        END.
                      ELSE
                        ASSIGN crapcdp.vlcuseve = aux_vlalimen.
                    END.
            END.
            WHEN 4 THEN /* Material */
            DO:
                  IF(CAN-DO(STRING(ab_unmap.aux_agerepli),STRING(crapage.cdagenci))) THEN
                    DO:
                      IF (aux_nrcpfcgc = "" OR aux_nrcpfcgc = ? OR aux_nrcpfcgc = "0")
                         AND (aux_nrdocfmd <> "" AND aux_nrdocfmd <> ? AND aux_nrdocfmd <> "0") THEN
                        DO:
                          ASSIGN crapcdp.vlcuseve = 0.
                        END.
                      ELSE
                        ASSIGN crapcdp.vlcuseve = aux_vlmateri.
                    END.
            END.
            WHEN 5 THEN /* Transportes */
            DO:
                  IF(CAN-DO(STRING(ab_unmap.aux_agerepli),STRING(crapage.cdagenci))) THEN
                    DO:
                      IF (aux_nrcpfcgc = "" OR aux_nrcpfcgc = ? OR aux_nrcpfcgc = "0")
                         AND (aux_nrdocfmd <> "" AND aux_nrdocfmd <> ? AND aux_nrdocfmd <> "0") THEN
                        DO:
                          ASSIGN crapcdp.vlcuseve = 0.
                        END.
                      ELSE
                        ASSIGN crapcdp.vlcuseve = aux_vltransp.
                    END.
            END.
            WHEN 6 THEN /* Brindes */
            DO:
                  IF(CAN-DO(STRING(ab_unmap.aux_agerepli),STRING(crapage.cdagenci))) THEN
                    DO:
                      IF (aux_nrcpfcgc = "" OR aux_nrcpfcgc = ? OR aux_nrcpfcgc = "0")
                         AND (aux_nrdocfmd <> "" AND aux_nrdocfmd <> ? AND aux_nrdocfmd <> "0") THEN
                        DO:
                          ASSIGN crapcdp.vlcuseve = 0.
                        END.
                      ELSE
                        ASSIGN crapcdp.vlcuseve = aux_vlbrinde.
                    END.                    
            END.
              WHEN 7 THEN /* Divulgaçao */
                DO:
                  IF(CAN-DO(STRING(ab_unmap.aux_agerepli),STRING(crapage.cdagenci))) THEN
                    DO:
                      IF (aux_nrcpfcgc = "" OR aux_nrcpfcgc = ? OR aux_nrcpfcgc = "0")
                         AND (aux_nrdocfmd <> "" AND aux_nrdocfmd <> ? AND aux_nrdocfmd <> "0") THEN
            DO:
                          ASSIGN crapcdp.vlcuseve = 0.
                        END.
                      ELSE
                        ASSIGN crapcdp.vlcuseve = aux_vldivulg.
                    END.
            END.
            WHEN 8 THEN /* Outros */
            DO:
                  IF(CAN-DO(STRING(ab_unmap.aux_agerepli),STRING(crapage.cdagenci))) THEN
                    DO:
                      IF (aux_nrcpfcgc = "" OR aux_nrcpfcgc = ? OR aux_nrcpfcgc = "0")
                         AND (aux_nrdocfmd <> "" AND aux_nrdocfmd <> ? AND aux_nrdocfmd <> "0") THEN
                        DO:
                          ASSIGN crapcdp.vlcuseve = 0.
                        END.
                      ELSE
                        ASSIGN crapcdp.vlcuseve = DEC(ab_unmap.aux_vloutros).
                    END.
            END.
        END CASE. /* CASE crapcdp.cdcuseve */

          VALIDATE crapcdp.
        END. /* FIM VERIFICACAO DE PAS */
      END. /* FOR EACH crapcdp */

   END. /* FOR EACH crapage */

  END. /* TRANSACAO */

  IF aux_flgerror = TRUE THEN
    RETURN "NOK".
  ELSE
    RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaTermo w-html 
PROCEDURE CriaListaTermo :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE aux_nmresage AS CHAR                   NO-UNDO.
    DEFINE VARIABLE aux_vlcuseve LIKE crapcdp.vlcuseve     NO-UNDO.
    DEFINE VARIABLE aux_prdescon LIKE crapcdp.prdescon     NO-UNDO.
    DEFINE VARIABLE aux_cdageagr AS INT                    NO-UNDO.

    DEFINE BUFFER bf-crapcdp FOR crapcdp.
    DEFINE BUFFER bf-crapagp FOR crapagp.
    DEFINE BUFFER bf-crapage FOR crapage.

    /* Primeiro, monta a informaçao para o registro com PAC = 0 (modelo) */
    FOR EACH crapcdp WHERE string(crapcdp.cdevento) = ab_unmap.aux_cdevento AND 
                           crapcdp.idevento = INT(ab_unmap.aux_idevento)    AND
                           crapcdp.cdagenci = 0                             AND
                           crapcdp.tpcuseve = 4                             AND
                           crapcdp.cdcuseve = 1                             AND
                           crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper)    AND
                           crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage)
                           BREAK BY crapcdp.cdcooper
                                    BY crapcdp.cdevento
                                       BY crapcdp.cdcuseve:

        /* Para cada evento que foi selecionado */
        IF FIRST-OF(crapcdp.cdevento) THEN
          DO:
              IF  vetortermo = "" THEN
                  vetortermo = "~{" + 
                               "cdagenci:'0'," +
                               "nmresage:'',"  +
                               "vlcuseve:'" + TRIM(STRING(crapcdp.vlcuseve,"zzz,zz9.99")) + "'," +
                               "prdescon:'" + STRING(crapcdp.prdescon) + "'" +
                               "~}". 
              ELSE
                  vetortermo = vetortermo + 
                               ",~{" + 
                               "cdagenci:'0'," +
                               "nmresage:'',"  +
                               "vlcuseve:'" + TRIM(STRING(crapcdp.vlcuseve,"zzz,zz9.99")) + "'," +
                               "prdescon:'" + STRING(crapcdp.prdescon) + "'" +
                               "~}". 
          END.

    END. /* FOR EACH crapcdp */

    /* Verifica o PAC agrupador do PAC do usuario */
    FIND crapagp WHERE crapagp.idevento = INT(ab_unmap.aux_idevento)   AND
                       crapagp.cdcooper = INT(ab_unmap.aux_cdcooper)   AND
                       crapagp.dtanoage = INT(ab_unmap.aux_dtanoage)   AND
                       crapagp.cdagenci = gnapses.cdagenci
                       NO-LOCK NO-ERROR.

    IF   AVAILABLE crapagp   THEN
         aux_cdageagr = crapagp.cdageagr.
    ELSE
         aux_cdageagr = gnapses.cdagenci.    


    /* Segundo, monta as informaçoes relativas a cada PAC */
    FOR EACH crapage WHERE crapage.cdcooper = INT(ab_unmap.aux_cdcooper)    AND
                          (crapage.insitage = 1  OR       /* Ativo */
                           crapage.insitage = 3) NO-LOCK  /* Temporariamente Indisponivel */
                           BY crapage.nmresage:

        /* Controle de visualizaçao por PAC */
        IF  (gnapses.nvoperad = 1    OR
             gnapses.nvoperad = 2)                  AND
             gnapses.cdagenci <> crapage.cdagenci   AND
             crapage.cdagenci <> aux_cdageagr       THEN
             NEXT.

        /* Para Progrid, os PACs sao agrupados */
        FIND FIRST crapagp WHERE crapagp.idevento = INT(ab_unmap.aux_idevento)  AND
                                 crapagp.cdcooper = INT(ab_unmap.aux_cdcooper)  AND
                                 crapagp.dtanoage = INT(ab_unmap.aux_dtanoage)  AND
                                 crapagp.cdagenci = crapage.cdagenci            NO-LOCK NO-ERROR.

        IF   INT(ab_unmap.aux_idevento) = 1   THEN
             DO:
                 IF   NOT AVAIL crapagp   THEN
                      NEXT.  

                 IF   crapagp.cdagenci <> crapagp.cdageagr   THEN
                      NEXT.
             END.
        
        aux_nmresage = crapage.nmresage.

        /* Pega os PACS agrupados */
        IF   INT(ab_unmap.aux_idevento) = 1   THEN
             FOR EACH bf-crapagp  WHERE bf-crapagp.idevento  = crapagp.idevento      AND
                                        bf-crapagp.cdcooper  = crapagp.cdcooper      AND
                                        bf-crapagp.dtanoage  = crapagp.dtanoage      AND
                                        bf-crapagp.cdageagr  = crapagp.cdagenci      AND
                                        bf-crapagp.cdagenci <> crapagp.cdagenci      NO-LOCK,
                 FIRST bf-crapage WHERE bf-crapage.cdagenci  = bf-crapagp.cdagenci   NO-LOCK 
                                        BY bf-crapage.nmresage:
           
                 ASSIGN aux_nmresage = aux_nmresage + " / " + bf-crapage.nmresage.
            END.

        FIND crapcdp WHERE crapcdp.cdevento = INT(ab_unmap.aux_cdevento)    AND
                           crapcdp.idevento = INT(ab_unmap.aux_idevento)    AND
                           crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage)    AND
                           crapcdp.tpcuseve = 4                             AND
                           crapcdp.cdcuseve = 1                             AND
                           crapcdp.cdagenci = crapage.cdagenci              AND
                           crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper)    NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE crapcdp   THEN
             ASSIGN aux_vlcuseve = 0
                    aux_prdescon = 0.
        ELSE
             ASSIGN aux_vlcuseve = crapcdp.vlcuseve
                    aux_prdescon = crapcdp.prdescon.

        IF  vetortermo = "" THEN
            vetortermo = "~{" + 
                         "cdagenci:'" + STRING(crapage.cdagenci) + "'," +
                         "nmresage:'" + REPLACE(STRING(aux_nmresage),"'","`") + "',"  +
                         "vlcuseve:'" + TRIM(STRING(aux_vlcuseve,"zzz,zz9.99")) + "'," +
                         "prdescon:'" + STRING(aux_prdescon) + "'" +
                         "~}".
        ELSE
            vetortermo = vetortermo + 
                         ",~{" + 
                         "cdagenci:'" + STRING(crapage.cdagenci) + "'," +
                         "nmresage:'" + REPLACE(STRING(aux_nmresage),"'","`") + "',"  +
                         "vlcuseve:'" + TRIM(STRING(aux_vlcuseve,"zzz,zz9.99")) + "'," +
                         "prdescon:'" + STRING(aux_prdescon) + "'" +
                         "~}".

   END. /* FOR EACH crapage */

   RUN RodaJavaScript("var mtermo=new Array();mtermo=["  + vetortermo + "]").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE htmOffsets w-html  _WEB-HTM-OFFSETS
PROCEDURE htmOffsets :
  RUN readOffsets ("{&WEB-FILE}":U).
  RUN htmAssociate
    ("aux_cdcooper":U,"ab_unmap.aux_cdcooper":U,ab_unmap.aux_cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
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
    ("aux_flgselec":U,"ab_unmap.aux_flgselec":U,ab_unmap.aux_flgselec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_flgtermo":U,"ab_unmap.aux_flgtermo":U,ab_unmap.aux_flgtermo:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lscpfcgc":U,"ab_unmap.aux_lscpfcgc":U,ab_unmap.aux_lscpfcgc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lscpfcgc2":U,"ab_unmap.aux_lscpfcgc2":U,ab_unmap.aux_lscpfcgc2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspropos":U,"ab_unmap.aux_lspropos":U,ab_unmap.aux_lspropos:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nmpagina":U,"ab_unmap.aux_nmpagina":U,ab_unmap.aux_nmpagina:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_vlrselec":U,"ab_unmap.aux_vlrselec":U,ab_unmap.aux_vlrselec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_vlrselec_termo":U,"ab_unmap.aux_vlrselec_termo":U,ab_unmap.aux_vlrselec_termo:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dtanoage":U,"crapcdp.dtanoage":U,crapcdp.dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nmevento":U,"ab_unmap.nmevento":U,ab_unmap.nmevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nmrescop":U,"ab_unmap.nmrescop":U,ab_unmap.nmrescop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_qtmaxtur":U,"ab_unmap.aux_qtmaxtur":U,ab_unmap.aux_qtmaxtur:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_qtdagenc":U,"ab_unmap.aux_qtdagenc":U,ab_unmap.aux_qtdagenc:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("aux_agerepli":U,"ab_unmap.aux_agerepli":U,ab_unmap.aux_agerepli:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_vlrhonor":U,"ab_unmap.aux_vlrhonor":U,ab_unmap.aux_vlrhonor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_vloutros":U,"ab_unmap.aux_vloutros":U,ab_unmap.aux_vloutros:HANDLE IN FRAME {&FRAME-NAME}).  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
  
DEFINE INPUT PARAMETER opcao AS CHARACTER.
    
  DEF VAR aux_qtevesel AS INT  NO-UNDO.
  DEF VAR aux_tpcuseve AS INT  NO-UNDO.
  DEF VAR aux_msgderro AS CHAR NO-UNDO.
  DEF VAR aux_indselec AS INT  NO-UNDO.
    
    DEF VAR aux_vlrdecim LIKE crapcdp.vlcuseve NO-UNDO.
    
    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0018.p PERSISTENT SET h-b1wpgd0018.
    
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0018) THEN
       DO:
          DO WITH FRAME {&FRAME-NAME}:
             IF opcao = "inclusao" THEN
                DO: 
                    CREATE cratcdp.
    
                    RUN inclui-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT msg-erro, OUTPUT ab_unmap.aux_nrdrowid).
                END.
             ELSE  /* alteracao */
                DO: 
                    IF ab_unmap.aux_stdopcao = "al"   THEN /* Altera os custos */
                         DO:
                             FIND FIRST craptab WHERE craptab.cdcooper = 0            AND
                                                      craptab.nmsistem = "CRED"       AND
                                                      craptab.tptabela = "CONFIG"     AND
                                                      craptab.cdempres = 0            AND
                                                      craptab.cdacesso = "PGDCUSTEVE" AND
                                                      craptab.tpregist = 0            NO-LOCK NO-ERROR NO-WAIT.
                             
                           ASSIGN aux_indselec = 1.
                             
                             /* Para todos os PACs */
                             DO aux_qtevesel = 1 TO (NUM-ENTRIES(ab_unmap.aux_vlrselec, ";") / 9):
                                                          
                                 /* Para todos os tipos de custo dos eventos */
                                 DO aux_tpcuseve = 1 TO (NUM-ENTRIES(craptab.dstextab) / 2):
                             
                                   IF INT(ENTRY(aux_indselec, ab_unmap.aux_vlrselec, ";")) = 0 THEN 
                                     NEXT.
                                    
                                     FIND FIRST cratcdp NO-ERROR.
                                   
                                   IF AVAILABLE cratcdp THEN
                                         DELETE cratcdp.
                             
                                   ASSIGN aux_vlrdecim = DEC(ENTRY(aux_tpcuseve + aux_indselec, ab_unmap.aux_vlrselec, ";")).
                                     
                                     CREATE cratcdp.
                                     ASSIGN cratcdp.cdagenci = INT(ENTRY(aux_indselec, ab_unmap.aux_vlrselec, ";"))
                                            cratcdp.cdcooper = INT(ab_unmap.aux_cdcooper)
                                            cratcdp.cdcuseve = INT(ENTRY(aux_tpcuseve * 2, craptab.dstextab))
                                            cratcdp.cdevento = INT(ab_unmap.aux_cdevento)
                                            cratcdp.dtanoage = INT(ab_unmap.aux_dtanoage)
                                            cratcdp.idevento = INT(ab_unmap.aux_idevento)
                                            cratcdp.vlcuseve = aux_vlrdecim
                                            cratcdp.tpcuseve = 1 /* Este programa só lança custos diretos */
                                            cratcdp.flgfecha = IF ENTRY(aux_qtevesel, ab_unmap.aux_flgselec,";") = "true" THEN YES ELSE NO
                                            cratcdp.nrcpfcgc = DEC(ENTRY(aux_qtevesel, ab_unmap.aux_lscpfcgc,";"))
                                            cratcdp.nrdocfmd = DEC(ENTRY(aux_qtevesel, ab_unmap.aux_lscpfcgc2,";"))
                                            cratcdp.nrpropos = ENTRY(aux_qtevesel, ab_unmap.aux_lspropos,";").
                                                          
                                     FIND FIRST crapcdp WHERE crapcdp.idevento = cratcdp.idevento AND
                                                              crapcdp.cdcooper = cratcdp.cdcooper AND
                                                              crapcdp.cdagenci = cratcdp.cdagenci AND
                                                              crapcdp.cdevento = cratcdp.cdevento AND
                                                              crapcdp.cdcuseve = cratcdp.cdcuseve AND
                                                              crapcdp.tpcuseve = cratcdp.tpcuseve AND
                                                              crapcdp.dtanoage = cratcdp.dtanoage NO-LOCK NO-ERROR NO-WAIT.
                             
                                   IF AVAILABLE crapcdp THEN
                                     DO:
                                         RUN altera-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT aux_msgderro).
                                     END.
                                     ELSE
                                     DO:
                                         RUN inclui-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT aux_msgderro, OUTPUT ab_unmap.aux_nrdrowid).
                                     END.
                             
                                     ASSIGN msg-erro = msg-erro + aux_msgderro.
                             
                                 END. /* DO aux_tpcuseve */
                             
                               ASSIGN aux_indselec = aux_indselec + 9.
                             
                             END. /* DO aux_qtevesel */
                          END.
                    ELSE
                    /* Altera os termos de compromisso */
                          DO:
                             aux_indselec = 1.
                             
                             /* Para todos os PACs */
                             DO aux_qtevesel = 1 TO (NUM-ENTRIES(ab_unmap.aux_vlrselec_termo,";") / 3):

                                EMPTY TEMP-TABLE cratcdp.

                                CREATE cratcdp.
                                ASSIGN cratcdp.cdagenci = INT(ENTRY(aux_indselec, ab_unmap.aux_vlrselec_termo, ";"))
                                       cratcdp.cdcooper = INT(ab_unmap.aux_cdcooper)
                                       cratcdp.cdcuseve = 1
                                       cratcdp.cdevento = INT(ab_unmap.aux_cdevento)
                                       cratcdp.dtanoage = INT(ab_unmap.aux_dtanoage)
                                       cratcdp.idevento = INT(ab_unmap.aux_idevento)
                                       cratcdp.vlcuseve = DEC(ENTRY(aux_indselec + 1, ab_unmap.aux_vlrselec_termo, ";"))
                                       cratcdp.prdescon = INT(ENTRY(aux_indselec + 2, ab_unmap.aux_vlrselec_termo, ";"))
                                       cratcdp.tpcuseve = 4
                                       cratcdp.flgfecha = YES
                                       cratcdp.nrcpfcgc = 0
                                       cratcdp.nrpropos = "0".

                                FIND FIRST crapcdp WHERE crapcdp.idevento = cratcdp.idevento AND
                                                         crapcdp.cdcooper = cratcdp.cdcooper AND
                                                         crapcdp.cdagenci = cratcdp.cdagenci AND
                                                         crapcdp.cdevento = cratcdp.cdevento AND
                                                         crapcdp.cdcuseve = cratcdp.cdcuseve AND
                                                         crapcdp.tpcuseve = cratcdp.tpcuseve AND
                                                         crapcdp.dtanoage = cratcdp.dtanoage NO-LOCK NO-ERROR NO-WAIT.
                             
                              IF AVAIL crapcdp THEN
																DO:
                                    RUN altera-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT aux_msgderro).
                                END.
                                ELSE
                                DO:
                                    RUN inclui-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT aux_msgderro, OUTPUT ab_unmap.aux_nrdrowid).
                                END.
                             
                                ASSIGN msg-erro = msg-erro + aux_msgderro.
                             
                                aux_indselec = aux_indselec + 3.

                             END. /* DO aux_qtevesel */

                          END.
                END.    
          END. /* DO WITH FRAME {&FRAME-NAME} */
       
          /* "mata" a instância da BO */
          DELETE PROCEDURE h-b1wpgd0018 NO-ERROR.
       
       END. /* IF VALID-HANDLE(h-b1wpgd0018) */
      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
/* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0018.p PERSISTENT SET h-b1wpgd0018.
     
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0018) THEN
       DO:
          CREATE cratcdp.
          BUFFER-COPY crapcdp TO cratcdp.
              
          RUN exclui-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT msg-erro).
    
          /* "mata" a instância da BO */
          DELETE PROCEDURE h-b1wpgd0018 NO-ERROR.
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
  output-content-type ("text/html":U).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PermissaoDeAcesso w-html 
PROCEDURE PermissaoDeAcesso :
{includes/wpgd0009.i}
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-web-request w-html 
PROCEDURE process-web-request :
/*------------------------------------------------------------------------------
   Tipo: Procedure interna
     Nome: includes/webreq.i - Versao WebSpeed 2.1
  Autor: B&T/Solusoft
   Funçao: Processo de requisiçao web p/ cadastros simples na web - Versao WebSpeed 3.0
    Notas: Este é o procedimento principal onde terá as requisiçoes GET e POST.
         GET - É ativa quando o formulário é chamado pela 1a vez
         POST - Após o get somente ocorrerá POST no formulário      
         Caso seja necessário custimizá-lo para algum programa específico 
         Favor cópiar este procedimento para dentro do procedure process-web-requeste 
           faça lá alteraçoes necessárias.

  Alteraçoes: 10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
-------------------------------------------------------------------------------*/

v-identificacao = get-cookie("cookie-usuario-em-uso").

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + v-identificacao + "*" NO-LOCK:
    LEAVE.
END.
  
ASSIGN opcao                       = GET-FIELD("aux_cddopcao")
       FlagPermissoes              = GET-VALUE("aux_lspermis")
       msg-erro-aux                = 0
       ab_unmap.aux_idevento       = GET-VALUE("aux_idevento")
       ab_unmap.aux_dsendurl       = AppURL                        
       ab_unmap.aux_lspermis       = FlagPermissoes                
       ab_unmap.aux_nrdrowid       = GET-VALUE("aux_nrdrowid")         
       ab_unmap.aux_stdopcao       = GET-VALUE("aux_stdopcao")
       ab_unmap.aux_cdevento       = GET-VALUE("aux_cdevento")
       ab_unmap.aux_cdcooper       = GET-VALUE("aux_cdcooper")
       ab_unmap.aux_vlrselec       = GET-VALUE("aux_vlrselec")
       ab_unmap.aux_dtanoage       = GET-VALUE("aux_dtanoage")
       ab_unmap.aux_flgselec       = GET-VALUE("aux_flgselec")
         ab_unmap.aux_lscpfcgc       = REPLACE(REPLACE(REPLACE(GET-VALUE("aux_lscpfcgc"),".",""),"/",""),"-","")
       ab_unmap.aux_lspropos       = GET-VALUE("aux_lspropos")
       ab_unmap.aux_nmpagina       = GET-VALUE("aux_nmpagina")
       ab_unmap.aux_vlrselec_termo = GET-VALUE("aux_vlrselec_termo")
       ab_unmap.aux_qtmaxtur       = GET-VALUE("aux_qtmaxtur")
         ab_unmap.aux_qtdagenc       = GET-VALUE("aux_qtdagenc")
         ab_unmap.aux_agerepli       = GET-VALUE("aux_agerepli")
         ab_unmap.aux_lscpfcgc2      = REPLACE(REPLACE(REPLACE(GET-VALUE("aux_lscpfcgc2"),".",""),"/",""),"-","")
         ab_unmap.aux_vlrhonor       = GET-VALUE("aux_vlrhonor")
         ab_unmap.aux_vloutros       = GET-VALUE("aux_vloutros").

RUN outputHeader.

/* Preenche o nome do evento */ 
  /* Um evento pode ser incluído sem passar pela Sugestao de Eventos */
  /* Essa situaçao serve para acrescer eventos na agenda */
/* Alterado em 31/01/2007 - Rosangela */
FIND FIRST crapedp WHERE crapedp.cdcooper = INT(ab_unmap.aux_cdcooper) AND
                         crapedp.dtanoage = INT(ab_unmap.aux_dtanoage) AND
                         crapedp.cdevento = INT(ab_unmap.aux_cdevento) NO-LOCK NO-ERROR NO-WAIT.

  IF NOT AVAILABLE crapedp THEN
    DO:
          RUN RodaJavaScript("alert('O evento precisa constar na Seleçao de Sugestoes.');top.close();").
          /*LEAVE.*/
          RETURN "NOK".
    END.
 
  ASSIGN aux_qtmaxtur = STRING(crapedp.qtmaxtur).

ASSIGN ab_unmap.nmevento     = IF AVAIL crapedp THEN crapedp.nmevento ELSE ""
       ab_unmap.aux_qtmaxtur = IF AVAIL crapedp THEN STRING(crapedp.qtmaxtur) ELSE "".

/* Preenche o nome da cooperativa */                                                                       
FIND FIRST crapcop WHERE crapcop.cdcooper = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR NO-WAIT.

ASSIGN ab_unmap.nmrescop = IF AVAIL crapcop THEN crapcop.nmrescop ELSE "".
                           
/* Verifica se deve mostrar a aba de termos de compromisso */
IF ab_unmap.aux_idevento = "1" AND
   crapedp.flgcompr      = YES THEN
  ab_unmap.aux_flgtermo = YES.
ELSE                                
  ab_unmap.aux_flgtermo = NO.
                                     
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
                    ASSIGN msg-erro-aux = 3. /* erros da validaçao de dados */
                            ELSE 
                            DO:
                      ASSIGN msg-erro-aux = 10
                                   ab_unmap.aux_stdopcao = "al".
                            END.
                        END.  /* fim inclusao */
              ELSE     /* alteraçao */ 
                                  DO: 
                                  RUN local-assign-record ("alteracao"). 
                                  
                                  IF msg-erro = "" THEN
                    ASSIGN msg-erro-aux = 10. /* Solicitaçao realizada com sucesso */ 
                                  ELSE
                    ASSIGN msg-erro-aux = 3. /* erros da validaçao de dados */
                    
                END. /* fim alteraçao */
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
                  ASSIGN msg-erro-aux = 2. /* registro nao existe */
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
                          ASSIGN msg-erro-aux = 10. /* Solicitaçao realizada com sucesso */ 
                                   END.
                                ELSE
                                   ASSIGN msg-erro-aux = 3. /* Exclusao rejeitada */ 
                             END.
                          ELSE
                    ASSIGN msg-erro-aux = 3. /* erros da validaçao de dados */
                       END.  
                END. /* fim exclusao */
          WHEN "re" THEN /* Calcular Valores de Custos Orcados */
            DO:
              RUN CalculoCustosOrcados(INPUT 0).
            END.
          WHEN "ci" THEN /* Calcular Valores de Custos Orcados por PA Individual */
                DO:   
              RUN CalculoCustosOrcados(INPUT INT(ab_unmap.aux_agerepli)).

              IF RETURN-VALUE <> "OK" THEN
                DO:
                  RUN LimpaCustosOrcados(INPUT INT(ab_unmap.aux_agerepli)).
                END.
            END.
      END CASE.

        RUN ListaCustosOrcados.
      RUN CriaListaTermo.
      
      IF msg-erro-aux = 10 OR (opcao <> "sa" AND opcao <> "ex" AND opcao <> "in") THEN
          DO:
         RUN displayFields.
          END.
 
      RUN enableFields.
      RUN outputFields.

      CASE msg-erro-aux:
           WHEN 1 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                     v-descricaoerro = 'Registro esta em uso por outro usuário. Solicitaçao nao pode ser executada. Espere alguns instantes e tente novamente.'.

                    RUN RodaJavaScript('alert("'+ v-descricaoerro + '"); ').
                END.

           WHEN 2 THEN
                RUN RodaJavaScript("alert('Registro foi excluído. Solicitação não pode ser executada.')").
      
           WHEN 3 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = msg-erro.

                    RUN RodaJavaScript('alert("'+ v-descricaoerro + '"); ').
                END.

           WHEN 4 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = m-erros.

                    RUN RodaJavaScript('alert("'+ v-descricaoerro + '"); ').
                END.

          WHEN 10 THEN
            DO:
               RUN RodaJavaScript('window.opener.Recarrega();'). 
              RUN RodaJavaScript('alert("Atualização executada com sucesso.")'). 
           END.
         
      END CASE.     

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

                      RUN ListaCustosOrcados.
                    RUN CriaListaTermo.
                    RUN displayFields.
                    RUN enableFields.
                    RUN outputFields.
                    
                    IF GET-VALUE("LinkRowid") = "" THEN
                      DO:
                         RUN RodaJavaScript('Incluir();').                         
                      END.
                       
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