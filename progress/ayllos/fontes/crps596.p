/* ..........................................................................

   Programa: Fontes/crps596.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gati - Diego
   Data    : Maio/2011                       Ultima atualizacao: 20/02/2019
   
   Dados referentes ao programa:

   Frequencia: Semanal
   Objetivo  : Listar os novos seguros prestamistas contratados no Ayllos
   
   Alteracoes: 05/07/2011 - Enviar e-mail para jeicy@cecred.coop.br (Henrique)
   
               07/07/2011 - Gerar relatorio por PAC (Henrique).
               
               04/03/2013 - Substituido e-mail jeicy@cecred.coop.br por 
                            cecredseguros@cecred.coop.br (Daniele). 
               
               10/09/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero). 
                            
               06/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)
                            
               31/01/2014 - Remover a chamada da procedure "saldo_epr.p".(James)
               
               08/04/2014 - Inclusao dos emails sergio.buzzi elaine.silva e 
                            angelica.silva@mdsinsure.com (Carlos)
                            
               12/06/2014 - Atualizar envio de e-mail para 
                                sergio.buzzi@mdsinsure.com, 
                                elaine.silva@mdsinsure.com, 
                                pendencia.cecred@mdsinsure.com
                            (Douglas - Chamado 162075)

               04/09/2014 - Atualizar envio de e-mail para 
                                sergio.buzzi@mdsinsure.com
                                emissao.cecredseguros@mdsinsure.com
                                daniella.ferreira@mdsinsure.com
                                cecredseguros@cecred.coop.br
                            (Douglas - Chamado 194868)
                02/12/2014 - Atualizar envio de e-mail para
                                "sergio.buzzi@mdsinsure.com"                                "emissao.cecredseguros@mdsinsure.com,"
                                "daniella.ferreira@mdsinsure.com"
                                "ariana.barba@mdsinsure.com"
                                "pendencia.cecred@mdsinsure.com"
                                "cecredseguros@cecred.coop.br" 
                                (Felipe - Chamado 228940)  
                                
               07/04/2015 - Atualizar envio de e-mail para 
                                            sergio.buzzi@mdsinsure.com
                                            projetocecred@mdsinsure.com
                                            emissao.cecredseguros@mdsinsure.com
                                            ariana.barba@mdsinsure.com
                                            cecredseguros@cecred.coop.br
                            (Douglas - Chamado 271323)
                            
               21/05/2015 - Ajuste para nao somar o saldo devedor do emprestimo
                            quando a linha de credito nao cobra seguro 
                            prestamista. (James)
                            
               07/07/2015 - Remover email ariana.barba@mdsinsure.com
                            (Lucas Ranghetti #297888 )
                            
               25/09/2015 - Substituido os emails do SEGUROS PRESTAMISTAS
                            (Tiago/Gielow #332160).             
                            
               05/01/2016 - Adicionado coluna de pre-aprovado (Anderson)

			   26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).   
                             
               20/02/2019 - Inclusao de log de fim de execucao do programa 
                            (Belli - Envolti - Chamado REQ0039739)   

............................................................................. */

DEF STREAM str_1. /* GERAL */
DEF STREAM str_2. /* PA'S */

{ includes/var_batch.i "NEW" }

/* chamado oracle - 20/02/2019 - Chamado REQ0039739 */
{ sistema/generico/includes/var_oracle.i }

DEF TEMP-TABLE cratseg NO-UNDO LIKE crapseg
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD vlsdeved LIKE crapepr.vlsdeved
    FIELD temcrdpa AS LOGICAL
    INDEX ch_ordem cdagenci nrdconta.

DEF        VAR tab_dtiniseg AS DATE                                 NO-UNDO.
DEF        VAR rel_cdagenci AS INT                                  NO-UNDO.
DEF        VAR rel_nmprimtl AS CHAR                                 NO-UNDO.
DEF        VAR rel_vlsdeved AS DEC                                  NO-UNDO.
DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"               NO-UNDO.
DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"               NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5      NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                   NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                   INIT ["DEP. A VISTA   ","CAPITAL        ",
                                         "EMPRESTIMOS    ","DIGITACAO      ",
                                         "GENERICO       "]         NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                 NO-UNDO.
               
DEF        VAR rel_totsegpr AS INTE    FORMAT "zzz,zz9"             NO-UNDO.
DEF        VAR rel_totsgpac AS INTE    FORMAT "zzz,zz9"             NO-UNDO.
DEF        VAR h_b1wgen0011 AS HANDLE                               NO-UNDO.

DEF        VAR aux_dtiniref AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF        VAR aux_dtfimref AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF        VAR aux_regexist AS LOGI                                 NO-UNDO.
DEF        VAR aux_vlsdeved LIKE crapepr.vlsdeved                   NO-UNDO.
DEF        VAR aux_qtprecal LIKE crapepr.qtprecal                   NO-UNDO.
DEF        VAR aux_cdfinemp LIKE crapepr.cdfinemp                   NO-UNDO.
DEF        VAR aux_temcrdpa AS LOGICAL                              NO-UNDO.

FORM cratseg.cdagenci  COLUMN-LABEL "PA"                
     cratseg.nrdconta  COLUMN-LABEL "Conta/dv"           
     cratseg.nrctrseg  COLUMN-LABEL "Proposta"           
     cratseg.dtinivig  COLUMN-LABEL "Inicio da Vigencia" 
     cratseg.nmprimtl  COLUMN-LABEL "Titular" FORMAT 'x(40)'    
     cratseg.vlsdeved  COLUMN-LABEL "Saldo Devedor"
     cratseg.temcrdpa  COLUMN-LABEL "Pre-Aprovado" FORMAT "Sim/Nao"
     WITH NO-BOX NO-ATTR-SPACE DOWN WIDTH 132 FRAME f_prestamistas.

FORM SKIP(1)
     rel_totsegpr  AT 9 LABEL "QUANTIDADE DE SEGUROS CONTRATADOS"
     WITH NO-BOX SIDE-LABELS WIDTH 80 FRAME f_totsegpre.

FORM "PERIODO:" AT 23
     aux_dtiniref FORMAT "99/99/9999" 
     "A"
     aux_dtfimref FORMAT "99/99/9999" 
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_periodo.


ASSIGN glb_cdprogra    = "crps596"
       aux_nmarqimp    = "rl/crrl597_999.lst"
       glb_cdrelato = 597
       rel_totsegpr = 0.  

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0   THEN
     QUIT.	 
  
{ includes/cabrel132_1.i }          /*  Monta cabecalho do relatorio  */

FIND craptab WHERE 
     craptab.cdcooper = glb_cdcooper   AND
     craptab.nmsistem = "CRED"         AND
     craptab.tptabela = "USUARI"       AND
     craptab.cdempres = 11             AND
     craptab.cdacesso = "SEGPRESTAM"   AND
     craptab.tpregist = 0              NO-LOCK NO-ERROR.

IF   AVAIL craptab   THEN
     ASSIGN tab_dtiniseg = DATE(INTEGER(SUBSTRING(craptab.dstextab,43,2)),
                                INTEGER(SUBSTRING(craptab.dstextab,40,2)),
                                INTEGER(SUBSTRING(craptab.dstextab,46,4))).

ASSIGN aux_dtiniref = (glb_dtmvtoan - WEEKDAY(glb_dtmvtoan)) + 2
       aux_dtfimref = glb_dtmvtoan.

/* Vamos buscar a finalidade de empréstimo do pre-aprovado pessoa fisica */
FOR crappre FIELDS (cdfinemp)
            WHERE crappre.cdcooper = glb_cdcooper AND 
                  crappre.inpessoa = 1 /* Pessoa Fisica */
            NO-LOCK: END.
IF  AVAIL crappre THEN
    ASSIGN aux_cdfinemp = crappre.cdfinemp.
ELSE 
    ASSIGN aux_cdfinemp = 0.

FOR EACH crapseg WHERE 
         crapseg.cdcooper  = glb_cdcooper   AND
         crapseg.dtinivig >= aux_dtiniref   AND           
         crapseg.dtinivig <= aux_dtfimref   AND
         crapseg.tpseguro  = 4              NO-LOCK:

    FIND crapass WHERE    
         crapass.cdcooper = crapseg.cdcooper   AND
         crapass.nrdconta = crapseg.nrdconta   NO-LOCK NO-ERROR.
    IF   AVAIL crapass   THEN 
         ASSIGN rel_cdagenci = crapass.cdagenci
                rel_nmprimtl = crapass.nmprimtl .
    ELSE 
         ASSIGN rel_cdagenci = 0
                rel_nmprimtl =  "".

    ASSIGN rel_vlsdeved = 0
           aux_temcrdpa = FALSE.

    FOR EACH crapepr WHERE 
             crapepr.cdcooper  = glb_cdcooper      AND
             crapepr.dtmvtolt >= tab_dtiniseg      AND
             crapepr.nrdconta  = crapass.nrdconta  AND
             crapepr.inliquid  = 0                 NO-LOCK:

        FOR FIRST craplcr FIELDS(flgsegpr)
                          WHERE craplcr.cdcooper = crapepr.cdcooper AND
                                craplcr.cdlcremp = crapepr.cdlcremp
                                NO-LOCK: END.

        /* Caso a linha nao cobrar seguro prestamistas, vamos ignorar no relatorio */
        IF AVAIL craplcr AND NOT craplcr.flgsegpr THEN
           NEXT.

        /* Saldo calculado pelo crps616.p e crps665.p */
        ASSIGN aux_vlsdeved = crapepr.vlsdevat.
        
        IF crapepr.tpemprst = 0 THEN
           ASSIGN aux_qtprecal = crapepr.qtlcalat.
        ELSE
           ASSIGN aux_qtprecal = crapepr.qtpcalat.

        ASSIGN rel_vlsdeved = rel_vlsdeved  + aux_vlsdeved.
    END.

    FOR FIRST crapepr WHERE 
              crapepr.cdcooper  = glb_cdcooper      AND
              crapepr.nrdconta  = crapseg.nrdconta  AND
              crapepr.dtmvtolt >= aux_dtiniref      AND           
              crapepr.dtmvtolt <= aux_dtfimref      AND
              crapepr.cdfinemp  = aux_cdfinemp      AND
              crapepr.inliquid  = 0                 NO-LOCK: END.
    IF AVAIL crapepr THEN
      ASSIGN aux_temcrdpa = TRUE.

    CREATE cratseg.
    BUFFER-COPY crapseg TO cratseg
        ASSIGN cratseg.cdagenci = rel_cdagenci
               cratseg.nmprimtl = rel_nmprimtl
               cratseg.vlsdeved = rel_vlsdeved
               cratseg.temcrdpa = aux_temcrdpa.
END.

ASSIGN aux_regexist = FALSE.

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 80.

VIEW STREAM str_1 FRAME f_cabrel132_1.

FOR EACH cratseg BREAK BY cratseg.cdagenci BY cratseg.nrdconta:

    IF  FIRST-OF(cratseg.cdagenci) THEN
        DO:
            OUTPUT STREAM str_2 TO VALUE("rl/crrl597_" + 
                                         STRING(cratseg.cdagenci, "999") +
                                         ".lst") PAGED PAGE-SIZE 80.            

            VIEW STREAM str_2 FRAME f_cabrel132_1.
        END.

    IF  NOT aux_regexist            OR
        LINE-COUNTER(str_1) >= 80   THEN
        DO:
            IF   aux_regexist   THEN
                 PAGE STREAM str_1.
                 
            DISPLAY STREAM str_1 aux_dtiniref aux_dtfimref WITH FRAME f_periodo.
            aux_regexist = TRUE.
        END.
    
    /* RELATORIO GERAL */
    DISPLAY STREAM str_1
            cratseg.cdagenci   
            cratseg.nrdconta   
            cratseg.nrctrseg   
            cratseg.dtinivig   
            cratseg.nmprimtl
            cratseg.vlsdeved
            cratseg.temcrdpa
            WITH FRAME f_prestamistas.

    DOWN STREAM str_1 WITH FRAME f_prestamistas.

    /*RELATORIO PA */
    DISPLAY STREAM str_2
            cratseg.cdagenci   
            cratseg.nrdconta   
            cratseg.nrctrseg   
            cratseg.dtinivig   
            cratseg.nmprimtl
            cratseg.vlsdeved
            cratseg.temcrdpa
            WITH FRAME f_prestamistas.

    DOWN STREAM str_2 WITH FRAME f_prestamistas.

    ASSIGN rel_totsegpr = rel_totsegpr + 1
           rel_totsgpac = rel_totsgpac + 1.

    IF  LAST-OF(cratseg.cdagenci) THEN
        DO:
            DISPLAY STREAM str_2 rel_totsgpac @ rel_totsegpr 
                    WITH FRAME f_totsegpre.
        
            ASSIGN rel_totsgpac = 0.

            OUTPUT STREAM str_2 CLOSE.
        END.

END.

IF   rel_totsegpr > 0   THEN
     DO:
         DISPLAY STREAM str_1 rel_totsegpr WITH FRAME f_totsegpre.

         PAGE STREAM str_1.
     END.

OUTPUT STREAM str_1 CLOSE.

IF   rel_totsegpr > 0   THEN
     DO:
         ASSIGN glb_nmformul = "132col"
                glb_nmarqimp = aux_nmarqimp
                glb_nrcopias = 1.
                   
         RUN fontes/imprim.p.   

         /* Enviar e-mail */ 
         RUN sistema/generico/procedures/b1wgen0011.p 
                                         PERSISTENT SET h_b1wgen0011.
             
         RUN converte_arquivo IN h_b1wgen0011
                                (INPUT glb_cdcooper,
                                 INPUT aux_nmarqimp,
                                 INPUT SUBSTRING(aux_nmarqimp,4,7) + ".txt").
                                   
         RUN enviar_email IN h_b1wgen0011
                            (INPUT glb_cdcooper,
                             INPUT glb_cdprogra,
                             INPUT "projetocecred@mdsinsure.com," +
                                   "seguros@ailos.coop.br",
                             INPUT "SEGUROS PRESTAMISTAS",
                             INPUT SUBSTRING(aux_nmarqimp,4,7) + ".txt",
                             INPUT FALSE).
                                   
         DELETE PROCEDURE h_b1wgen0011.
     END.
ELSE
     /* Remove o arquivo vazio */
     UNIX SILENT VALUE("rm " + aux_nmarqimp + " 2>/dev/null").

/* Inclusao de log de fim de execucao do programa -  20/02/2019 - Chamado REQ0039739 */

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "O",
    INPUT "CRPS596.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 912,
    input "912 - FINALIZADO LEGAL",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "PF",
    INPUT "CRPS596.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 0,
    input "",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }   
                         
RUN fontes/fimprg.p.

/* .......................................................................... */
