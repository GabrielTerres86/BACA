/*...............................................................................
	Alterações:
...............................................................................*/


&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME

&Scoped-define WINDOW-NAME CURRENT-WINDOW
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
       FIELD aux_dtfineve AS CHARACTER FORMAT "X(256)":U
       FIELD aux_cdoperad AS CHARACTER FORMAT "X(256)":U
       FIELD aux_cdcopope AS CHARACTER FORMAT "X(256)":U.

DEFINE TEMP-TABLE fornecedores
       FIELD nrcpfcgc AS CHARACTER 
       FIELD nmfornec AS CHARACTER.
         
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-html 

CREATE WIDGET-POOL.

DEFINE VARIABLE ProgramaEmUso         AS CHARACTER INITIAL ["wpgd0060"].
DEFINE VARIABLE NmeDoPrograma         AS CHARACTER INITIAL ["wpgd0060.w"].

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
DEFINE VARIABLE h-b1wpgd0060          AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE crateap             LIKE crapeap.
DEFINE BUFFER crabedp FOR crapedp.   

DEFINE VARIABLE aux_crapcop           AS CHAR                           NO-UNDO.
DEFINE VARIABLE vetorevcoop           AS CHAR                           NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0060.htm

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
ab_unmap.aux_maxrows  ab_unmap.aux_cdeixtem ab_unmap.aux_cdevento_pa ~
ab_unmap.aux_nrseqtem ab_unmap.aux_nrcpfcgc ab_unmap.aux_dtinieve ~
ab_unmap.aux_dtfineve ab_unmap.aux_tpevento ab_unmap.aux_cdoperad ~
ab_unmap.aux_cdcopope
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
ab_unmap.aux_maxrows  ab_unmap.aux_cdeixtem ab_unmap.aux_cdevento_pa ~
ab_unmap.aux_nrseqtem ab_unmap.aux_nrcpfcgc ab_unmap.aux_dtinieve ~
ab_unmap.aux_dtfineve ab_unmap.aux_tpevento ab_unmap.aux_cdoperad ~
ab_unmap.aux_cdcopope


&ANALYZE-RESUME

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
     ab_unmap.aux_cdoperad AT ROW 1 COL 1 HELP
          "" NO-LABEL 
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     
     ab_unmap.aux_cdcopope AT ROW 1 COL 1 HELP
          "" NO-LABEL 
          VIEW-AS FILL-IN 
          SIZE 20 BY 1    
    
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 71.4 BY 17.91.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-html 
/* *********************** Included-Libraries ************************* */

{src/web2/html-map.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-html 
{src/web2/template/hmapmain.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEvCoop w-html 
PROCEDURE CriaListaEvCoop :

    DEFINE VARIABLE aux_nrdturma AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nmevento AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_cdevento AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_cdevento_pa AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_nrseqtem AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_cdeixtem AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_nrcpfcgc AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_tpevento AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_lstpeven AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_lsevento AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_fcrapeap AS INT  NO-UNDO.
    
    ASSIGN aux_cdeixtem    = "—TODOS --,-1"
           aux_nrseqtem    = "—TODOS --,-1"
           aux_cdevento    = "--Selecione Evento --,0"
           aux_cdevento_pa = "—TODOS --,-1"
           aux_nrcpfcgc    = "—TODOS --,-1"
           aux_tpevento    = "—TODOS --,-1"
           aux_lsevento    = ""
           aux_lstpeven    = ""
           aux_fcrapeap    = 0.
    
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
                            crapedp.dtanoage = INT(ab_unmap.aux_dtanoage)  NO-LOCK  BY crapedp.nmevento:
       
       ASSIGN aux_fcrapeap = 0.
       
       FOR EACH crapeap WHERE crapeap.idevento = crapedp.idevento            AND
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
              DO:  		
				         ASSIGN aux_fcrapeap = 0.
                    NEXT.
              END.
               ELSE
                 DO:
									ASSIGN aux_fcrapeap = 1.
									LEAVE.
								END.
        END. /* FOR EACH crapeap */
              
        IF aux_fcrapeap = 1 THEN 
        DO: 

  			
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
                          
                          /* Cria a lista de tipo de Eventos*/
                          IF aux_lstpeven <> "" THEN 
                          DO:
                            IF NOT CAN-DO(aux_lstpeven,STRING(crapedp.tpevento)) THEN
                               aux_lstpeven = aux_lstpeven + "," + STRING(crapedp.tpevento).
                            
                          END.
                          ELSE               
                             ASSIGN aux_lstpeven = STRING(crapedp.tpevento).
                          
                          LEAVE.
                    END.
                 END.
              ELSE DO:
			   
                ASSIGN aux_cdevento_pa = aux_cdevento_pa + "," + REPLACE(crapedp.nmevent, ",", ".") + "," + STRING(crapedp.cdevento).
                
                IF aux_lsevento <> "" THEN aux_lsevento = aux_lsevento + ",".
               
                /* Cria a lista de tipo de Eventos*/
                IF aux_lstpeven <> "" THEN 
                DO: 
                  IF NOT CAN-DO(aux_lstpeven,STRING(crapedp.tpevento)) THEN
                     aux_lstpeven = aux_lstpeven + "," + STRING(crapedp.tpevento).                  
              END.
                ELSE DO:               
                   ASSIGN aux_lstpeven = STRING(crapedp.tpevento).
                  
    END.
                
              END.
        END. /* FIM aux_fcrapeap*/   
		
    END. /* Fim FOR EACH crapedp*/
     
    
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
                          /* Cria a lista de tipo de Eventos*/
                          IF aux_lstpeven <> "" THEN 
                          DO:
                            IF NOT CAN-DO(aux_lstpeven,STRING(crapedp.tpevento)) THEN
                               aux_lstpeven = aux_lstpeven + "," + STRING(crapedp.tpevento).                  
                          END.
                          ELSE               
                             ASSIGN aux_lstpeven = STRING(crapedp.tpevento).
                   
                          LEAVE.
                    END.
                 END.
              ELSE DO:
                ASSIGN aux_cdevento = aux_cdevento + "," + REPLACE(crapedp.nmevent, ",", ".") + "," + STRING(crapedp.cdevento).
                
              END.
    END.

    /* FORNECEDORES */
    FOR EACH  crapedp WHERE crapedp.idevento = INT(ab_unmap.aux_idevento)   AND
                             crapedp.cdcooper = INT(ab_unmap.aux_cdcooper) AND
                             crapedp.dtanoage = INT(ab_unmap.aux_dtanoage) AND
                             (crapedp.cdevento = INT(ab_unmap.aux_cdevento_pa) OR INT(ab_unmap.aux_cdevento_pa) = -1) AND 
                             (INT(ab_unmap.aux_cdeixtem) = -1 OR crapedp.cdeixtem = INT(ab_unmap.aux_cdeixtem)) AND 
                             (INT(ab_unmap.aux_nrseqtem) = -1 OR crapedp.nrseqtem = INT(ab_unmap.aux_nrseqtem)) AND 
                             (INT(ab_unmap.aux_tpevento) = -1 OR crapedp.tpevento = INT(ab_unmap.aux_tpevento))   NO-LOCK:
       
        FIND FIRST crapadp WHERE crapadp.idevento = crapedp.idevento AND
                                 crapadp.cdcooper = crapedp.cdcooper AND
                                 crapadp.dtanoage = crapedp.dtanoage AND
                                 crapadp.cdevento = crapedp.cdevento AND
                                 (INT(ab_unmap.aux_cdagenci) = -1                   OR
                                 crapadp.cdagenci = INT(ab_unmap.aux_cdagenci)) NO-LOCK NO-ERROR.
                
        IF NOT AVAILABLE crapadp THEN
           NEXT. 
        ELSE 
          DO: 
          
            /* Se selecionado o evento pega apenas o tipo do evento selecionado para o filtro.*/
            IF INT(ab_unmap.aux_cdevento_pa) <> -1 THEN
              ASSIGN aux_lstpeven = STRING(crapedp.tpevento).               
            
            FOR EACH crapcdp WHERE crapcdp.idevento = crapedp.idevento 
                               AND crapcdp.cdcooper = crapedp.cdcooper 
                               AND crapcdp.dtanoage = crapedp.dtanoage 
                               AND crapcdp.tpcuseve = 1                
                               AND crapcdp.cdcuseve = 1                
                               AND crapcdp.cdevento = crapedp.cdevento  
                               AND (ab_unmap.pagina = "divConfirma"    
                                OR INT(ab_unmap.aux_cdagenci) = -1
                                OR crapcdp.cdagenci = INT(ab_unmap.aux_cdagenci))    
                                /*LOOKUP(STRING(crapcdp.cdevento), aux_lsevento, ",") > 0*/
                                NO-LOCK BREAK BY crapcdp.nrcpfcgc:
                 
              IF FIRST-OF(crapcdp.nrcpfcgc) THEN 
                DO:
                  FIND gnapfdp WHERE gnapfdp.idevento = crapcdp.idevento
                                 AND gnapfdp.nrcpfcgc = crapcdp.nrcpfcgc NO-LOCK NO-ERROR.
                 
                  IF AVAILABLE gnapfdp THEN
                    DO: 
                      CREATE fornecedores.
                      ASSIGN fornecedores.nrcpfcgc = STRING(gnapfdp.nrcpfcgc)
                             fornecedores.nmfornec = STRING(gnapfdp.nmfornec).       
          
                    END. /* IF AVAILABLE gnapfdp */
                END. /* FIRST-OF */
             END. /* FOR EACH crapcdp */
             
           /* ADP */
           FOR EACH crapadp WHERE crapadp.idevento = crapedp.idevento 
                              AND crapadp.cdcooper = crapedp.cdcooper 
                              AND crapadp.dtanoage = crapedp.dtanoage 
                              /*AND crapadp.tpcuseve = 1                
                              AND crapadp.cdcuseve = 1                */
                              AND crapadp.cdevento = crapedp.cdevento  
                              AND (ab_unmap.pagina = "divConfirma"    
                               OR INT(ab_unmap.aux_cdagenci) = -1
                               OR crapadp.cdagenci = INT(ab_unmap.aux_cdagenci))    
                               /*LOOKUP(STRING(crapcdp.cdevento), aux_lsevento, ",") > 0*/
                               NO-LOCK BREAK BY crapadp.nrcpfcgc:
                 
              IF FIRST-OF(crapadp.nrcpfcgc) THEN 
                DO:
                  FIND gnapfdp WHERE gnapfdp.idevento = crapadp.idevento
                                 AND gnapfdp.nrcpfcgc = crapadp.nrcpfcgc NO-LOCK NO-ERROR.
                 
                  IF AVAILABLE gnapfdp THEN
                    DO: 
                    
                      FIND fornecedores where fornecedores.nrcpfcgc = STRING(gnapfdp.nrcpfcgc) NO-LOCK NO-ERROR NO-WAIT.
                      
                      IF NOT AVAILABLE fornecedores THEN
                        DO:
                          CREATE fornecedores.
                          ASSIGN fornecedores.nrcpfcgc = STRING(gnapfdp.nrcpfcgc)
                                 fornecedores.nmfornec = STRING(gnapfdp.nmfornec).       
                        END.
          
                    END. /* IF AVAILABLE gnapfdp */
                END. /* FIRST-OF */
             END. /* FOR EACH crapcdp */
             
             /* ADP */
         END.
    END.
    
   
    /* Percorre a Temp table para ordenação*/
     FOR EACH fornecedores NO-LOCK  BREAK BY fornecedores.nmfornec:
        IF FIRST-OF(fornecedores.nmfornec) THEN 
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
    
    /********* Lógica para diferenciar tipos de evento em Progrid e Assembléia *********/
    /* Para todos os tipos de evento da CRAPTAB */
    DO i = 1 TO (NUM-ENTRIES(aux_tpevento) / 2):
                
      IF ENTRY(i * 2, aux_tpevento) <> "-1" AND
         ENTRY(i * 2, aux_tpevento) <> "7"  AND
         ENTRY(i * 2, aux_tpevento) <> "8"  AND
         ENTRY(i * 2, aux_tpevento) <> "12" AND
         ENTRY(i * 2, aux_tpevento) <> "13" AND
         ENTRY(i * 2, aux_tpevento) <> "14" AND
         ENTRY(i * 2, aux_tpevento) <> "15" AND
         ENTRY(i * 2, aux_tpevento) <> "16" THEN
           DO:
             ab_unmap.aux_tpevento:DELETE(ENTRY(i * 2, aux_tpevento)).
           END.
        
         /* Retira os Tipos de eventos de acordo com os filtros */
         IF NOT CAN-DO(aux_lstpeven,ENTRY(i * 2, aux_tpevento)) AND ENTRY(i * 2, aux_tpevento) <> "-1" THEN
          DO:
            ab_unmap.aux_tpevento:DELETE(ENTRY(i * 2, aux_tpevento)).
          END.
    END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEventos w-html 
PROCEDURE CriaListaEventos :

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
    DEF VAR aux_cdeveant AS INT                         NO-UNDO.
    DEF VAR aux_cdageant AS INT                         NO-UNDO.
    DEF VAR aux_contador AS INT                         NO-UNDO.
    DEF VAR aux_qtpagina AS INT  INIT 150               NO-UNDO.
    DEF VAR aux_qtregist AS INT  INIT 0                 NO-UNDO.
    DEF VAR aux_procregi AS LOGICAL                     NO-UNDO.
    DEF VAR aux_contregi AS INT  INIT 0                 NO-UNDO.
    DEF VAR aux_exibefle AS INT  INIT 0                 NO-UNDO.
		
		DEF VAR aux_dsrecurs AS CHAR                        NO-UNDO.
    DEF VAR aux_mesafaci AS CHAR                        NO-UNDO.
    DEF VAR aux_nrseqfea AS INT                        NO-UNDO.
    
    DEF VAR vetormes     AS CHAR EXTENT 12
        INITIAL ["Janeiro","Fevereiro","Março","Abril","Maio","Junho",
                 "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"].
                 
    DEF QUERY q_crapadp FOR crapadp, crapedp SCROLLING.

    RUN RodaJavaScript("var mevento = new Array(); var aux_exibedir = 0;").

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

    /* Descrição do status do evento */
    FIND craptab WHERE craptab.cdcooper = 0             AND  
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "CONFIG"      AND
                       craptab.cdempres = 0             AND
                       craptab.cdacesso = "PGSTEVENTO"  AND
                       craptab.tpregist = 0             NO-LOCK NO-ERROR NO-WAIT.

    
   
    IF   ab_unmap.aux_carregar = "proximos"   THEN
         DO:
            ASSIGN aux_exibefle = 1.
            REPOSITION q_crapadp TO ROWID TO-ROWID(ab_unmap.aux_regfimls).
            REPOSITION q_crapadp FORWARDS aux_qtpagina - 1.
            REPOSITION q_crapadp TO ROWID TO-ROWID(ab_unmap.aux_regfimls).
         END.
    ELSE
    IF   ab_unmap.aux_carregar = "anteriores"   THEN
         DO:
            ASSIGN aux_exibefle = 1.
            REPOSITION q_crapadp TO ROWID TO-ROWID(ab_unmap.aux_reginils).
            REPOSITION q_crapadp BACKWARDS aux_qtpagina - 1.
           
         END.

    ASSIGN ab_unmap.aux_contarow = 0. 
    
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
                                               crapcdp.cdevento = crapadp.cdevento           AND
                                               crapcdp.tpcuseve = 1                          AND
                                               crapcdp.cdcuseve = 1 NO-LOCK:
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
                                       
                                     IF AVAIL gnappdp   THEN 
                                        ASSIGN aux_idpropos = STRING(ROWID(gnappdp)).
                                                                          
                               END.
                                           END.

                       /* Nome do PA */
                       IF   aux_cdageant <> crapadp.cdagenci   THEN
                            DO:
                                FIND crapage WHERE crapage.cdcooper = crapadp.cdcooper   AND
                                                   crapage.cdagenci = crapadp.cdagenci   
                                                   NO-LOCK NO-ERROR NO-WAIT.
                                
                                IF AVAILABLE crapage THEN
                                     DO:
                                        ASSIGN aux_nmresage = crapage.nmresage.
                                     END.
                                ELSE
                                IF   INT(ab_unmap.cdagenci) = 0   THEN
                                     aux_nmresage = "TODOS".
                                ELSE
																	DO:
																		IF INT(aux_tpevento) = 7 OR INT(aux_tpevento) = 12 THEN
																			DO:
																				ASSIGN aux_nmresage = "*TODOS OS PAs".
																			END.
																		ELSE
																			DO:
																			  ASSIGN aux_nmresage = "** NAO ENCONTRADO **".
																			END.
																	END.

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
                       
                       
                       /* Para eventos com meses apenas*/
                       IF (aux_dtevento = "" OR crapadp.dtinieve = ? ) AND (ab_unmap.aux_dtinieve <> "" OR ab_unmap.aux_dtfineve <> "") THEN DO:
                         IF crapadp.dtinieve = ? THEN
                         DO:
                           IF  INT(SUBSTRING(ab_unmap.aux_dtinieve,4,2)) < INT(crapadp.nrmeseve) THEN
                           DO:
                              IF INT(SUBSTRING(ab_unmap.aux_dtinieve,4,2)) < INT(crapadp.nrmeseve) AND INT(crapadp.nrmeseve) > INT(SUBSTRING(ab_unmap.aux_dtfineve,4,2)) THEN 
                              DO:
                                ASSIGN aux_qtregist = aux_qtregist - 1. 
                                NEXT.
                              END.
                           END.
                           ELSE DO:
                              IF INT(SUBSTRING(ab_unmap.aux_dtinieve,4,2)) > INT(crapadp.nrmeseve) AND INT(crapadp.nrmeseve) < INT(SUBSTRING(ab_unmap.aux_dtfineve,4,2)) THEN 
                              DO:
                                ASSIGN aux_qtregist = aux_qtregist - 1. 
                                NEXT.
                              END.
                           
                           END.
                       
                       
                         END.
                         ELSE DO:
                         ASSIGN aux_qtregist = aux_qtregist - 1. 
                         NEXT.
                       END.
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
                                                    crapldp.idevento = 1 /* IDEVENTO é sempre 1 para locais */  AND
                                                    crapldp.nrseqdig = crapadp.cdlocali NO-LOCK NO-ERROR NO-WAIT.
                       ELSE 
                           FIND FIRST crapldp WHERE crapldp.cdcooper = crapadp.cdcooper  AND
                                                    crapldp.idevento = 1 /* IDEVENTO é sempre 1 para locais */  AND
                                                    crapldp.cdagenci = crapadp.cdagenci  AND
                                                    crapldp.nrseqdig = crapadp.cdlocali  NO-LOCK NO-ERROR NO-WAIT.
                       IF   NOT AVAIL crapldp   THEN
                       DO :
                           FIND FIRST crapldp WHERE crapldp.cdcooper = crapadp.cdcooper  AND
                                                    crapldp.idevento = 1 /* IDEVENTO é sempre 1 para locais */  AND
                                                    crapldp.cdagenci = 0  AND /* para EAD*/
                                                    crapldp.nrseqdig = crapadp.cdlocali NO-LOCK NO-ERROR NO-WAIT.
                           
                           IF   NOT AVAIL crapldp   THEN
                                ASSIGN aux_dslocali = ""
                                       aux_enlocali = "".
                           ELSE
                                DO:
                                    ASSIGN aux_dslocali = crapldp.dslocali
                                           aux_enlocali = crapldp.dsendloc.

                                    /* Se tiver o bairro, coloca junto com o endereço, pra aparecer no tooltip */
                                    IF   TRIM(crapldp.nmbailoc) <> ""   THEN
                                          ASSIGN aux_enlocali = aux_enlocali + " - " + crapldp.nmbailoc.
                                END.
                       
                       END.     
                       ELSE /*------*/
                            DO:
                                ASSIGN aux_dslocali = crapldp.dslocali
                                       aux_enlocali = crapldp.dsendloc.

                                /* Se tiver o bairro, coloca junto com o endereço, pra aparecer no tooltip */
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

                           /* Para Assembléias - somar as inscrições e confirmações de todos os pas */
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
														
											ASSIGN aux_dsrecurs = "".

											FIND FIRST crapree WHERE crapree.nrsdieve	= crapadp.nrseqdig NO-LOCK NO-ERROR NO-WAIT.
											  
											IF AVAILABLE crapree THEN
											  ASSIGN aux_dsrecurs = "Visualizar".
											ELSE
											 ASSIGN aux_dsrecurs = "Selecionar".

                      ASSIGN aux_mesafaci = ""
                             aux_nrseqfea = 0.
                      
                      IF INT(aux_tpevento) = 7 OR INT(aux_tpevento) = 12 THEN
                        DO:
                      
                          FOR EACH crapcmp WHERE crapcmp.idevento = crapadp.idevento
                                             AND crapcmp.cdcooper = crapadp.cdcooper
                                             AND crapcmp.dtanoage = crapadp.dtanoage
                                             AND crapcmp.cdagenci = crapadp.cdagenci
                                             AND crapcmp.cdevento = crapadp.cdevento
                                             AND crapcmp.nrseqdig = crapadp.nrseqdig NO-LOCK:
                            
                            FIND FIRST crapcma WHERE crapcma.nrseqcma = crapcmp.nrseqcma NO-LOCK NO-ERROR NO-WAIT.
                            
                            IF AVAILABLE crapcma THEN
                              DO:
                                IF aux_mesafaci <> "" AND aux_mesafaci <> ? THEN
                                  ASSIGN aux_mesafaci = aux_mesafaci + " / ".
                                  
                                ASSIGN aux_mesafaci = aux_mesafaci + crapcma.nmcompon.
                              END.
                          END.
                        END.
                      ELSE IF INT(aux_tpevento) = 8 OR INT(aux_tpevento) = 13 OR
                              INT(aux_tpevento) = 14 OR INT(aux_tpevento) = 15 OR 
                              INT(aux_tpevento) = 16 THEN
                        DO:
                      
                          FIND FIRST crapfea WHERE crapfea.nrseqfea = crapadp.nrseqfea NO-LOCK NO-ERROR NO-WAIT.
                          
                          IF AVAILABLE crapfea THEN
                            DO:
                              ASSIGN aux_mesafaci = crapfea.nmfacili
                                     aux_nrseqfea = crapadp.nrseqfea.
                            END.
                        END.
                                            
                      IF aux_mesafaci = "" OR aux_mesafaci = ? THEN
                        ASSIGN aux_mesafaci = "Selecionar".
                       
											RUN RodaJavaScript("mevento.push(~{cdagenci:'" + TRIM(STRING(crapadp.cdagenci))  
																										+ "',cdcooper:'" + TRIM(STRING(crapadp.cdcooper))
																										+ "',cdevento:'" + TRIM(STRING(crapadp.cdevento))
																										+ "',nrseqeve:'" + TRIM(STRING(crapadp.nrseqdig))
																										+ "',nmevento:'" + TRIM(SUBSTRING(aux_nmevento,1,37))
																										+ "',tpevento:'" + TRIM(STRING(aux_tpevento))    
																										+ "',nmresage:'" + TRIM(SUBSTRING(aux_nmresage,1,14))    
																										+ "',idpropos:'" + TRIM(STRING(aux_idpropos))    
																										+ "',dtevento:'" + TRIM(STRING(aux_dtevento))    
																										+ "',dslocali:'" + TRIM(STRING(aux_dslocali))    
																										+ "',dshroeve:'" + TRIM(STRING(crapadp.dshroeve))
																										+ "',qtmaxtur:'" + TRIM(STRING(crapadp.qtparpre))																			
																										+ "',nrinscri:'" + TRIM(STRING(aux_nrinscri))    
																										+ "',idstaeve:'" + TRIM(STRING(aux_idstaeve))    
																										+ "',enlocali:'" + TRIM(STRING(aux_enlocali))    
																										+ "',nrconfir:'" + TRIM(STRING(aux_nrconfir))    
																										+ "',dsrecurs:'" + TRIM(STRING(aux_dsrecurs))    
																										+ "',nrseqfea:'" + TRIM(STRING(aux_nrseqfea))    
																										+ "',mesafaci:'" + TRIM(STRING(aux_mesafaci))    
																										+ "',nrdrowid:'" + STRING(ROWID(crapadp)) + "'~});").
											   
                       ASSIGN aux_contregi = aux_contregi + 1.                       
                      
                     END.
									 ELSE DO:
										 ASSIGN aux_qtregist = aux_qtregist - 1.
									 END.
                 END.
                    
         END.

    CLOSE QUERY q_crapadp.

    IF aux_contregi <= aux_qtpagina AND aux_exibefle = 1 THEN
      RUN RodaJavaScript(" aux_exibedir = 1").  

END PROCEDURE.

&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaPac w-html 
PROCEDURE CriaListaPac :

  DEF VAR aux_cdagenci AS CHAR NO-UNDO.

   
  /* PA TODOS */        
  aux_cdagenci = "--Selecione PA--,0,Todos os PAS,-1".

  { includes/wpgd0201.i ab_unmap.aux_dtanoage }
        
  ab_unmap.aux_cdagenci:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_cdagenci.
 
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE htmOffsets w-html  _WEB-HTM-OFFSETS
PROCEDURE htmOffsets :

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
  RUN htmAssociate
    ("aux_cdoperad":U,"ab_unmap.aux_cdoperad":U,ab_unmap.aux_cdoperad:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcopope":U,"ab_unmap.aux_cdcopope":U,ab_unmap.aux_cdcopope:HANDLE IN FRAME {&FRAME-NAME}).

END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
DEFINE INPUT PARAMETER opcao AS CHARACTER.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
    
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
         ab_unmap.aux_maxrows     = INT(GET-VALUE("aux_maxrows"))
         ab_unmap.aux_cdcopope    = GET-VALUE("aux_cdcopope")
         ab_unmap.aux_cdoperad    = GET-VALUE("aux_cdoperad").

RUN outputHeader.

{includes/wpgd0098.i}

ab_unmap.aux_cdcooper:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapcop.

/* Se a cooperativa ainda não foi escolhida, pega a da sessão do usuário */
IF   INT(ab_unmap.aux_cdcooper) = 0   THEN
     ab_unmap.aux_cdcooper = STRING(gnapses.cdcooper).


/* Posiciona por default, na agenda atual */
IF   ab_unmap.aux_dtanoage = ""   THEN
     FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                             gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper) AND 
                             gnpapgd.dtanoage = INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR.
ELSE
     /* Se informou a data da agenda, permite que veja a agenda de um ano não atual */
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

                               IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                  IF LOCKED {&SECOND-ENABLED-TABLE} THEN
                                     DO:
                                         ASSIGN msg-erro-aux = 1. /* registro em uso por outro usuário */  
                                         FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                     END.
                                  ELSE
                                     DO: 
                                         ASSIGN msg-erro-aux = 2. /* registro não existe */
                                         RUN PosicionaNoSeguinte.
                                     END.

                            END.
                        END.  /* fim inclusao */
                    ELSE     /* alteração */ 
                        DO: 
                            FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

                            IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                               IF LOCKED {&SECOND-ENABLED-TABLE} THEN
                                  DO:
                                      ASSIGN msg-erro-aux = 1. /* registro em uso por outro usuário */  
                                      FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                  END.
                               ELSE
                                  DO: 
                                      ASSIGN msg-erro-aux = 2. /* registro não existe */
                                      RUN PosicionaNoSeguinte.
                                  END.
                            ELSE
                               DO:
                                  RUN local-assign-record ("alteracao").  
                                  IF msg-erro = "" THEN
                                     ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
                                  ELSE
                                     ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                               END.     
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
                    
                    RUN CriaListaEvCoop.                                        
                    RUN CriaListaEventos.
                    RUN displayFields.
                    RUN enableFields.
                    RUN outputFields.
                    RUN RodaJavaScript('CarregaPrincipal()').
                    
                END. /* fim otherwise */                  
      END CASE. 
      
END. /* fim do método GET */

/* Show error messages. */
IF AnyMessage() THEN 
DO:
   
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

