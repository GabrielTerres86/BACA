/*...............................................................................

Alterações: 10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).

            05/05/2009 - Utilizar cdcooper = 0 nas consultas (David).
                        
            09/12/2009 - Alterado para receber aux_dtanoage por parametro da URL (Diego).
                        
            05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                         busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).

            22/10/2012 - Ajustes para a nova estrutura gnappob(Gabriel).

            29/06/2015 - Incluido os campos de Dados do Fornecedor e Dados do Evento (Jean Michel).

            28/03/2016 - Ajustado para carregar dados existentes do evento EAD,
                         mesmo nao existindo proposta para o evento PRJ243.2 (Odirlei-AMcom)  

            19/04/2016 - Removi os campos de Publico Alvo (Carlos Rafael Tanholi). 	     
            
            31/05/2016 - Ajustes de Homologação conforme email do Márcio de 27/05 (Vanessa)

            24/06/2016 - Reformulação da tela conforme RF05  - Vanessa

            28/09/2016 - Ajuste no formato do telefone com 9 digitos (Diego).
            
            03/02/2016 - Incluida leitura de fornecedores pela CRAPADP, Prj. 229
                         (Jean Michel).
...............................................................................*/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME

&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_cdagenci        AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdcooper        AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cddopcao        AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdevento        AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsendurl        AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn        AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dtanoage        AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dtfineve        AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dtinieve        AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento        AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis        AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nmevento        AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid        AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrseqeve        AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao        AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsobjeti        AS CHARACTER FORMAT "X(256)":U
       FIELD dscurric 	         AS CHARACTER 
       FIELD dsfornec 	         AS CHARACTER
       FIELD nmfacili 	         AS CHARACTER 
       FIELD txaObservacoes 	   AS CHARACTER 
       FIELD txaPreRequisito   	 AS CHARACTER 
       FIELD txaPublicoAlvo 	   AS CHARACTER
       FIELD txtHonorarios 		   AS CHARACTER FORMAT "X(256)":U
       FIELD txtIdadePublicoAlvo AS CHARACTER FORMAT "X(256)":U
       FIELD txtQtdMaxTurma      AS CHARACTER FORMAT "X(256)":U
       FIELD txtQtdMinTurma      AS CHARACTER FORMAT "X(256)":U
       FIELD aux_idforrev        AS CHARACTER FORMAT "X(256)":U.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-html 

CREATE WIDGET-POOL.

DEFINE VARIABLE ProgramaEmUso AS CHARACTER INITIAL ["wpgd0026a"].
DEFINE VARIABLE NmeDoPrograma AS CHARACTER INITIAL ["wpgd0026a.w"].

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
DEFINE VARIABLE vetordados            AS CHAR                           NO-UNDO.


&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0026a.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS gnappdp.dsconteu gnappdp.qtcarhor gnappdp.dsmetodo 
&Scoped-define ENABLED-TABLES ab_unmap gnappdp
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE gnappdp
&Scoped-Define ENABLED-OBJECTS ab_unmap.nmfacili ab_unmap.aux_dtanoage ab_unmap.aux_dtfineve ab_unmap.aux_dtinieve ab_unmap.aux_nrseqeve ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ab_unmap.aux_cdevento ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_idevento ab_unmap.aux_lspermis ab_unmap.aux_nmevento ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ab_unmap.dscurric ab_unmap.dsfornec ab_unmap.txaObservacoes ab_unmap.txaPreRequisito ab_unmap.txtIdadePublicoAlvo ab_unmap.txaPublicoAlvo ab_unmap.txtHonorarios ab_unmap.txtQtdMaxTurma ab_unmap.txtQtdMinTurma ab_unmap.aux_idforrev
&Scoped-Define DISPLAYED-FIELDS gnappdp.dsconteu gnappdp.qtcarhor gnappdp.dsmetodo 
&Scoped-define DISPLAYED-TABLES ab_unmap gnappdp
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE gnappdp
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.nmfacili ab_unmap.aux_dtanoage ab_unmap.aux_dtfineve ab_unmap.aux_dtinieve ab_unmap.aux_nrseqeve ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ab_unmap.aux_cdevento ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_idevento ab_unmap.aux_lspermis ab_unmap.aux_nmevento ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ab_unmap.dscurric ab_unmap.dsfornec ab_unmap.txaObservacoes ab_unmap.txaPreRequisito ab_unmap.txtIdadePublicoAlvo ab_unmap.txaPublicoAlvo ab_unmap.txtHonorarios ab_unmap.txtQtdMaxTurma ab_unmap.txtQtdMinTurma ab_unmap.aux_idforrev

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */
/* Definitions of the field level widgets                               */
/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.nmfacili AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     ab_unmap.aux_dtanoage AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dtfineve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dtinieve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrseqeve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdagenci AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdevento AT ROW 1 COL 1 HELP
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
     ab_unmap.aux_nmevento AT ROW 1 COL 1 HELP
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
     gnappdp.dsconteu AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     ab_unmap.dscurric AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
	 ab_unmap.dsfornec AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4		  
	 ab_unmap.txtHonorarios AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
	 ab_unmap.txaObservacoes AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
	 ab_unmap.txaPreRequisito AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     ab_unmap.txtIdadePublicoAlvo AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_idforrev AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.txtQtdMaxTurma AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.txtQtdMinTurma AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.txaPublicoAlvo AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dsobjeti AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     gnappdp.qtcarhor AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnappdp.dsmetodo AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 71.4 BY 13.91.





&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-html 
/* *********************** Included-Libraries ************************* */
{src/web2/html-map.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-html 

{src/web2/template/hmapmain.i}

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

ASSIGN 
    v-identificacao = get-cookie("cookie-usuario-em-uso")
    v-permissoes    = "IAEPLU".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PreencheDados w-html 
PROCEDURE PreencheDados:

  DEFINE VARIABLE aux_contador AS INTEGER            NO-UNDO.
  DEFINE VARIABLE aux_temfones AS LOGICAL            NO-UNDO.
  DEFINE VARIABLE vetordados   AS CHAR               NO-UNDO.
  DEFINE VARIABLE aux_dados    AS CHAR               NO-UNDO.
  DEFINE VARIABLE aux_dsconteu AS CHAR               NO-UNDO.
  DEFINE VARIABLE aux_cdeixtem AS CHAR    INIT " - " NO-UNDO.
  DEFINE VARIABLE aux_nrseqtem AS CHAR    INIT " - " NO-UNDO.
  DEFINE VARIABLE aux_nrcpfcgc AS DECIMAL INIT 0     NO-UNDO.
  DEFINE VARIABLE aux_nrpropos AS CHAR    INIT ""    NO-UNDO.

  ASSIGN ab_unmap.aux_nmevento = ""
         ab_unmap.nmfacili = ""
         ab_unmap.dscurric = ""
         ab_unmap.dsfornec = ""
         ab_unmap.txaObservacoes = ""
         ab_unmap.txaPreRequisito = ""
         ab_unmap.txtIdadePublicoAlvo = ""
         ab_unmap.aux_idforrev = ""
         ab_unmap.txaPublicoAlvo = ""
         ab_unmap.txtHonorarios = ""
         ab_unmap.txtQtdMaxTurma = ""
         ab_unmap.txtQtdMinTurma = ""
         ab_unmap.aux_dsobjeti = ""
         aux_dsconteu = "".
         
  RUN RodaJavaScript("var mdadoseve = new Array();"). 

  FIND FIRST crapedp WHERE crapedp.cdevento = INT(ab_unmap.aux_cdevento)
                       AND crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)
                       AND crapedp.dtanoage = INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR.

  IF AVAILABLE crapedp THEN
    DO: 
      /* Verificar se é um evento EAD, caso for nao precisar verificar proposta pois nao existe
         apenas carregar informacoes existentes */
      IF crapedp.tpevento <> 10 THEN
        DO:
          IF NOT AVAILABLE gnappdp THEN 
            DO:
              LEAVE.
            END.
        END.
        
      ASSIGN ab_unmap.aux_nmevento = crapedp.nmevento.
      
      /* Eixo e Tema*/ 
      FOR FIRST craptem WHERE craptem.idevento = crapedp.idevento
                          AND craptem.idsittem = "A"             
                          AND craptem.nrseqtem = crapedp.nrseqtem
                          AND craptem.cdeixtem =  crapedp.cdeixtem NO-LOCK,
        FIRST gnapetp WHERE gnapetp.idevento = craptem.idevento
                        AND gnapetp.cdeixtem = craptem.cdeixtem
                        AND gnapetp.flgativo = TRUE NO-LOCK:                                              
        
          ASSIGN aux_cdeixtem  = gnapetp.dseixtem
                 aux_nrseqtem  = craptem.dstemeix.      
      END.
    END.
    
  FIND gnappob WHERE gnappob.idevento = gnappdp.idevento
                 AND gnappob.cdcooper = gnappdp.cdcooper
                 AND gnappob.nrcpfcgc = gnappdp.nrcpfcgc
                 AND gnappob.nrpropos = gnappdp.nrpropos NO-LOCK NO-ERROR.

  IF AVAILABLE gnappob THEN
    ASSIGN ab_unmap.aux_dsobjeti = gnappob.dsobjeti.

  FIND FIRST crapadp WHERE crapadp.cdcooper = INT(ab_unmap.aux_cdcooper)
                       AND crapadp.cdagenci = INT(ab_unmap.aux_cdagenci)
                       AND crapadp.dtanoage = INT(ab_unmap.aux_dtanoage)
                       AND crapadp.nrseqdig = INT(ab_unmap.aux_nrseqeve) NO-LOCK NO-ERROR.

  IF AVAILABLE crapadp THEN
    DO:
      ASSIGN aux_nrcpfcgc = crapadp.nrcpfcgc
             aux_nrpropos = crapadp.nrpropos.
						 ab_unmap.txaObservacoes  = STRING(crapadp.dsobsloc).
      
      IF crapadp.dtinieve = ? then
        ASSIGN ab_unmap.aux_dtinieve = "".
      ELSE
        ASSIGN ab_unmap.aux_dtinieve = STRING(crapadp.dtinieve, "99/99/9999").
      IF crapadp.dtfineve = ? THEN
        ASSIGN ab_unmap.aux_dtfineve = "".
      ELSE
        ASSIGN ab_unmap.aux_dtfineve = STRING(crapadp.dtfineve, "99/99/9999").
    END.

  IF aux_nrcpfcgc = 0 OR aux_nrcpfcgc = ? THEN
    DO:
      /* Dados do Fornecedor */
      FIND FIRST crapcdp WHERE crapcdp.idevento = gnappdp.idevento
                           AND crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper)
                           AND crapcdp.cdevento = INT(ab_unmap.aux_cdevento)
                           AND crapcdp.cdagenci = INT(ab_unmap.aux_cdagenci)
                           AND crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR.

      IF AVAILABLE crapcdp THEN
        DO:	
          ASSIGN aux_nrcpfcgc = crapcdp.nrcpfcgc
                 aux_nrpropos = crapcdp.nrpropos.
        END.  
    END. /* IF aux_nrcpfcgc = 0 OR aux_nrcpfcgc = ? */
      
  FIND gnapfdp WHERE gnapfdp.idevento = 1
                 AND gnapfdp.nrcpfcgc = aux_nrcpfcgc NO-LOCK NO-ERROR.

  IF AVAILABLE gnapfdp THEN
    ASSIGN ab_unmap.dsfornec = "Nome: " 	 	+ STRING(gnapfdp.nmfornec) + " <br> " + 
                               "DDD/Fone: (" 	+ STRING(gnapfdp.cddddfor) + ") " + STRING(gnapfdp.nrfonfor) + " <br> " + 
                               "DDD/Celular: (" + STRING(gnapfdp.cddddfax) + ") "  + STRING(gnapfdp.nrfaxfor).
    
  /* Fim Dados do Fornecedor */

  /* Dados do Evento */
  FIND FIRST gnappdp WHERE gnappdp.idevento = 1
         AND gnappdp.cdcooper = 0
         AND gnappdp.nrcpfcgc = aux_nrcpfcgc
         AND gnappdp.nrpropos = aux_nrpropos NO-LOCK NO-ERROR.

  IF AVAILABLE gnappdp THEN
    DO:       
      ASSIGN	/*ab_unmap.txaObservacoes  = STRING(gnappdp.dsobserv)*/
              ab_unmap.txaPreRequisito = STRING(gnappdp.dsprereq)
              aux_dsconteu             = TRIM(STRING(REPLACE(gnappdp.dsconteu,"\n","<br>")))            
              ab_unmap.txtHonorarios 	 = TRIM(STRING(gnappdp.vlinvest,"->>>,>>9.99")).
              
      CASE gnappdp.idforrev:
        WHEN 1 THEN
          ab_unmap.aux_idforrev = "PRESENCIAL".
        WHEN 2 THEN
          ab_unmap.aux_idforrev = "EAD".
        WHEN 3 THEN
          ab_unmap.aux_idforrev  = "HIBRIDO".
      END CASE.
    END.
    
  FIND FIRST crapeap WHERE crapeap.idevento = INT(ab_unmap.aux_idevento)
                       AND crapeap.cdcooper = INT(ab_unmap.aux_cdcooper)
                       AND crapeap.dtanoage = INT(ab_unmap.aux_dtanoage)
                       AND crapeap.cdagenci = INT(ab_unmap.aux_cdagenci)
                       AND crapeap.cdevento = INT(ab_unmap.aux_cdevento) NO-LOCK NO-ERROR.

  IF AVAILABLE crapeap AND crapeap.qtmaxtur <> 0 AND crapeap.qtmaxtur <> ? THEN
    ASSIGN ab_unmap.txtQtdMaxTurma = STRING(crapeap.qtmaxtur).

  FIND FIRST crapedp WHERE crapedp.idevento = INT(ab_unmap.aux_idevento)
                       AND crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)
                       AND crapedp.dtanoage = INT(ab_unmap.aux_dtanoage)
                       AND crapedp.cdevento = INT(ab_unmap.aux_cdevento) NO-LOCK NO-ERROR.

  IF AVAILABLE crapedp THEN
    DO:
      IF ab_unmap.txtQtdMaxTurma = "" THEN
        ASSIGN ab_unmap.txtQtdMaxTurma = STRING(crapedp.qtmaxtur).
      
      ASSIGN ab_unmap.txtQtdMinTurma = STRING(crapedp.qtmintur).
    END.
    
  /* Fim Dados do Evento */

  FOR EACH gnfacep WHERE gnfacep.cdcooper = 0
                     AND gnfacep.nrcpfcgc = gnappdp.nrcpfcgc
                     AND gnfacep.nrpropos = gnappdp.nrpropos NO-LOCK:

    FOR EACH gnapfep WHERE gnapfep.cdcooper = 0
                       AND gnapfep.nrcpfcgc = gnfacep.nrcpfcgc
                       AND gnapfep.cdfacili = gnfacep.cdfacili NO-LOCK:

      ASSIGN ab_unmap.nmfacili = ab_unmap.nmfacili + "\n- " + gnapfep.nmfacili
             ab_unmap.dscurric = ab_unmap.dscurric + "\n- " + gnapfep.dscurric
             aux_temfones = NO.

      /* Telefone dos facilitadores */
      DO aux_contador = 1 TO 3:
        IF gnapfep.nrdddfon[aux_contador] <> 0   AND
           gnapfep.nrtelefo[aux_contador] <> 0   THEN
          DO:
            IF aux_temfones THEN
              ASSIGN ab_unmap.nmfacili = ab_unmap.nmfacili + " / (" + STRING(gnapfep.nrdddfon[aux_contador]) + ") " + STRING(gnapfep.nrtelefo[aux_contador],"z9999,9999").
            ELSE 
              DO:
                ASSIGN ab_unmap.nmfacili = ab_unmap.nmfacili + " - DDD/Fone(s): (" + STRING(gnapfep.nrdddfon[aux_contador]) + ") " + STRING(gnapfep.nrtelefo[aux_contador],"z9999,9999")
                       aux_temfones = YES.
              END.
          END.
      END. /* DO aux_contador = 1 TO 3: */
    END. /* FOR EACH gnapfep */
  END. /* FOR EACH gnfacep */

  /*Publico Alvo*/
  FOR EACH crappap NO-LOCK BY crappap.dspubalv:
    FIND FIRST crapedp WHERE crapedp.idevento = 1
                         AND crapedp.cdcooper = 0
                         AND crapedp.dtanoage = 0
                         AND crapedp.cdevento = INT(ab_unmap.aux_cdevento) NO-LOCK NO-ERROR.
                         
    IF AVAILABLE crapedp THEN
      DO: 

        FOR EACH crappae WHERE crappae.idevento = crapedp.idevento
                           AND crappae.cdcooper = crapedp.cdcooper
                           AND crappae.dtanoage = crapedp.dtanoage
                           AND crappae.cdevento = crapedp.cdevento NO-LOCK :

          IF crappap.nrseqpap = crappae.nrseqpap THEN
            DO:
              IF ab_unmap.txaPublicoAlvo = "" THEN
                ASSIGN ab_unmap.txaPublicoAlvo = crappap.dspubalv.
              ELSE
                ASSIGN ab_unmap.txaPublicoAlvo = ab_unmap.txaPublicoAlvo + "<br> " + crappap.dspubalv.
            END.
        END. /* FOR EACH crappae */
      END. /* IF AVAILABLE crapedp THEN */    
  END.
                         
  ASSIGN aux_dados = "~{cdeixtem:'" + TRIM(STRING(aux_cdeixtem))
                   + "',nrseqtem:'"  + TRIM(STRING(aux_nrseqtem))
                   + "',nmevento:'"  + TRIM(STRING(ab_unmap.aux_nmevento))
                   + "',nmfacili:'"  + TRIM(STRING(ab_unmap.nmfacili))
                   + "',dscurric:'"  + TRIM(STRING(ab_unmap.dscurric))
                   + "',dsfornec:'"  + TRIM(STRING(ab_unmap.dsfornec))
                   + "',observac:'"  + TRIM(STRING(ab_unmap.txaObservacoes))
                   + "',prerequi:'"  + TRIM(STRING(ab_unmap.txaPreRequisito))
                   + "',idapubal:'"  + TRIM(STRING(ab_unmap.txtIdadePublicoAlvo))
                   + "',idforrev:'"  + TRIM(STRING(ab_unmap.aux_idforrev))
                   + "',publalvo:'"  + TRIM(STRING(ab_unmap.txaPublicoAlvo))
                   + "',honorari:'"  + TRIM(STRING(ab_unmap.txtHonorarios))
                   + "',qtdmaxtu:'"  + TRIM(STRING(ab_unmap.txtQtdMaxTurma))
                   + "',qtdmintu:'"  + TRIM(STRING(ab_unmap.txtQtdMinTurma ))
                   + "',dsconteu:'"  + TRIM(STRING(aux_dsconteu))
                   + "',qtcarhor:'"  + TRIM(STRING(gnappdp.qtcarhor,">>,>>9.99"))
                   + "',dsmetodo:'"  + TRIM(STRING(gnappdp.dsmetodo))
                   + "',dtinieve:'"  + TRIM(STRING(ab_unmap.aux_dtinieve))
                   + "',dtfimeve:'"  + TRIM(STRING(ab_unmap.aux_dtfineve))
                   + "',dsobjeti:'"  + TRIM(STRING(ab_unmap.aux_dsobjeti)) + "'~}".

  ASSIGN vetordados = REPLACE(aux_dados,'\n','<br>').
  
  RUN RodaJavaScript("mdadoseve.push(" + vetordados + ");"). 
  
END PROCEDURE.
                    
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
                    
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-web-request w-html 
PROCEDURE process-web-request :

v-identificacao = get-cookie("cookie-usuario-em-uso").
                                              
/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + v-identificacao + "*" NO-LOCK:
    LEAVE.
                                          END.   
                                          
ASSIGN opcao                 = GET-FIELD("aux_cddopcao")
       FlagPermissoes        = GET-VALUE("aux_lspermis")
       msg-erro-aux          = 0
       ab_unmap.aux_idevento = GET-VALUE("aux_idevento")
       ab_unmap.aux_dsendurl = AppURL                        
       ab_unmap.aux_lspermis = FlagPermissoes                
       ab_unmap.aux_nrdrowid = GET-VALUE("aux_nrdrowid")         
       ab_unmap.aux_stdopcao = GET-VALUE("aux_stdopcao")
       ab_unmap.aux_cdcooper = GET-VALUE("aux_cdcooper")
       ab_unmap.aux_cdagenci = GET-VALUE("aux_cdagenci")
       ab_unmap.aux_cdevento = GET-VALUE("aux_cdevento")
       ab_unmap.aux_nrseqeve = GET-VALUE("aux_nrseqeve")
       ab_unmap.aux_dtanoage = GET-VALUE("aux_dtanoage").

RUN outputHeader.

/* método POST */
IF REQUEST_METHOD = "POST":U THEN 
                DO:
      RUN inputFields.

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

      RUN RodaJavaScript('top.frames[0].ZeraOp()').   

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

                    RUN PreencheDados.
                    
                    RUN displayFields.
                    RUN enableFields.
                    RUN outputFields.
                   /* RUN RodaJavaScript('CarregaPrincipal()').*/
                
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