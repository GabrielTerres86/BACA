/* ............................................................................

   Programa: Fontes/crps085.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/94.                         Ultima atualizacao: 26/09/2016

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 045.
               Processar as integracoes dos creditos de emprestimos.
               Emite relatorio 72.

   Alteracoes: 22/06/94 - Alterado para permitir utilizar a taxa do mes na li-
                          quidacao do emprestimo (Edson).

               30/06/94 - Alterado para colocar sempre tipo de debito 1
                          (moeda corrente)

               31/08/94 - Alterado para rejeitar credito para os associados que
                          tenham dtelimin (Deborah).

               11/01/95 - Alterado para trocar o codigo da empresa 1 para 10
                          na integracao do arquivo da HERCO (Edson).

               23/01/95 - Alterado para trocar o codigo da empresa 10 para 13
                          na integracao do arquivo da Associacao (Deborah).

               03/03/95 - Alterado para inclusao de novos campos no craplem:
                          dtpagemp e txjurepr (Edson).

               12/04/95 - Alterado para inclusao de novo campo no arquivo de
                          entrada e no crapass - vledvmto (valor do endevida-
                          mento) (Edson).

               16/01/95 - Alterado para tratar empresa 9 (Consumo, porque no
                          arquivo serq empresa 1. (Odair).

               11/06/96 - Alterado para alimentar o valor da prestacao no
                          craplem quando houver pagamento (Edson).

               19/11/96 - Alterar a mascara do campo nrctremp (Odair).

               24/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               09/11/98 - Tratar situacao em prejuizo (Deborah).

               12/11/98 - Tratar atendimento noturno (Deborah).

               23/10/2000 - Desmembrar a critica 95 conforme a situacao do 
                            titular (Eduardo).

               30/10/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               01/09/2004 - Tratamento para recebimento de arquivo padrao CNAB
                            (Julio)

               03/12/2004 - Alterado, arquivo ira conter um registro para cada
                            contrato (Julio)

               10/06/2005 - Tratamento de digito verificador para BIG TIMBER
                            (Julio)

               28/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplem e craprej (Diego).

               20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                          
               01/11/2005 - Alteracao na validacao da data de Geracao do
                            arquivo. (Julio)
             
               10/12/2005 - Atualizar craprej.nrdctabb (Magui).     
               
               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               24/05/2006 - Salvar o relatorio em "rlnsv" (Julio)
               
               06/06/2006 - Inclusao do numero do contrato e nome do associado no
                            relatorio de rejeitados. Alteracao do relatorio para
                            132 colunas (Julio)

               04/08/2006 - Tratamento para o caso de o arquivo nao possuir 
                            registro de rodape (Julio)

               06/12/2006 - Melhorias na transformacao do arquivo dos2ux, para 
                            nao ocorrer mais erro de permissao de arquivo (Julio).
                            
               08/04/2007 - Alterado o formato da variável "aux_qtprepag" de 
                            "999" para "zz9", conforme o formato do campo
                            "crapepr.qtprepag" da base de dados
                            - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               09/03/2012 - Declarado novas variaveis da include lelem.i (Tiago).
               
               26/03/2012 - Efetuar NEXT apos criticas 9, 695, 95, 410, 174 
                            (Diego).
                            
               11/01/2013 - Alterado o format na criação do relatório crrl072
                            para "999". (Irlan)
                                
               28/03/2013 - Retirar atribuicao do campo qtprepag. (Irlan)
               
               10/10/2013 - Possibilidade de imprimir o relatório direto da tela 
                            SOL045, na hora da solicitacao (N) (Carlos)
                            
               25/10/2013 - Copia o arquivo do dir rlnsv p/ o dir rl (Carlos)
               
               07/11/2013 - Retornada validacao do nome do arquivo com codigo da 
                            empresa "99" (Diego).
                            
               14/01/2014 - Inclusao de VALIDATE craplot, craplem, craprej (Carlos)
               
               20/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)

               20/05/2016 - Remover a include lelem.i e chamar a procedure 
                            b1wgen0002.leitura_lem. Cobranca de Multa e
                            Juros de Mora. (Jaison/James)
                            
               26/09/2016 - Inclusao de verificacao de contratos de acordos,
                            Prj. 302 (Jean Michel).

............................................................................. */

DEF STREAM str_1.  /*  Para relatorio de criticas da integracao  */
DEF STREAM str_2.  /*  Para o arquivo de entrada da integracao  */

{ includes/var_batch.i  {1} }
{ sistema/generico/includes/var_oracle.i }

DEF        VAR rel_nmresemp     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.

DEF        VAR rel_dsintegr     AS CHAR                              NO-UNDO.
DEF        VAR rel_nmempres     AS CHAR                              NO-UNDO.
DEF        VAR rel_qtdifeln     AS INT                               NO-UNDO.
DEF        VAR rel_vldifedb     AS DECIMAL                           NO-UNDO.
DEF        VAR rel_vldifecr     AS DECIMAL                           NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR tab_diapagto AS INT                                   NO-UNDO.
DEF        VAR tab_dtcalcul AS DATE                                  NO-UNDO.
DEF        VAR tab_dtpagemp AS DATE                                  NO-UNDO.
DEF        VAR tab_inusatab AS LOGICAL                               NO-UNDO.

DEF        VAR tab_ddpgtoms AS INT                                   NO-UNDO.
DEF        VAR tab_ddpgtohr AS INT                                   NO-UNDO.
DEF        VAR tab_ddmesnov AS INT                                   NO-UNDO.

DEF        VAR aux_nmarqint AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR aux_dsintegr AS CHAR                                  NO-UNDO.

DEF        VAR aux_nmarquiv AS CHAR    FORMAT "x(55)" EXTENT 99      NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.

DEF        VAR aux_nrdevias AS INT     FORMAT "z9"    EXTENT 99      NO-UNDO.

DEF        VAR aux_qtdifeln AS INT                                   NO-UNDO.
DEF        VAR aux_vldifedb AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vldifecr AS DECIMAL                               NO-UNDO.

DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgclote AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgdaurv AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.

DEF        VAR aux_dtintegr AS DATE                                  NO-UNDO.
DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.
DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR aux_dtmesnov AS DATE                                  NO-UNDO.

DEF        VAR aux_contaarq AS INT                                   NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT     INIT 100                      NO-UNDO.
DEF        VAR aux_nrdolote AS INT                                   NO-UNDO.
DEF        VAR aux_nrmesant AS INT                                   NO-UNDO.
DEF        VAR aux_nrdocmto AS INT                                   NO-UNDO.

DEF        VAR aux_tpregist   AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR aux_nrdconta   AS INT     FORMAT "99999999"             NO-UNDO.
DEF        VAR aux_cdhistor   AS INT     FORMAT "9999"                 NO-UNDO.
DEF        VAR aux_cdempres   AS INT     FORMAT "99999"                NO-UNDO.
DEF        VAR aux_cdempres_2 AS INT                                   NO-UNDO.
DEF        VAR aux_cdtipsfx   AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_nrseqint   AS INT     FORMAT "999999"               NO-UNDO.
DEF        VAR aux_vldaurvs   AS DECIMAL FORMAT "99999.99"             NO-UNDO.
DEF        VAR aux_vldescto   AS DECIMAL FORMAT "9999999999.99-"       NO-UNDO.
DEF        VAR aux_vledvmto   AS DECIMAL FORMAT "999999999.99"         NO-UNDO.
DEF        VAR aux_vldsobra   AS DECIMAL FORMAT "999999999.99"         NO-UNDO.

DEF        VAR aux_dtmesant AS DATE                                  NO-UNDO.
DEF        VAR aux_dtultpag AS DATE                                  NO-UNDO.
DEF        VAR aux_dtultdia AS DATE                                  NO-UNDO.
DEF        VAR aux_dtcalcul AS DATE                                  NO-UNDO.
                                                                             
DEF        VAR aux_vlpreemp LIKE crapepr.vlpreemp                    NO-UNDO.
DEF        VAR aux_qtprecal LIKE crapepr.qtprecal                    NO-UNDO.
DEF        VAR aux_qtpreemp LIKE crapepr.qtpreemp                    NO-UNDO.
DEF        VAR aux_qtmesdec LIKE crapepr.qtmesdec                    NO-UNDO.
                                                                             
DEF        VAR aux_vljurmes AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF        VAR aux_vljuracu AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF        VAR aux_vlsdeved AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF        VAR aux_vlprepag AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        var aux_vlpreapg AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR aux_txdjuros AS DECIMAL DECIMALS 7                    NO-UNDO.

DEF        VAR aux_inhst093 AS LOGICAL                               NO-UNDO.

DEF        VAR aux_nrctatos AS INT                                   NO-UNDO.
DEF        VAR aux_nrctremp AS INT                                   NO-UNDO.
DEF        VAR aux_nrultdia AS INT                                   NO-UNDO.
DEF        VAR aux_nrdiacal AS INT                                   NO-UNDO.
DEF        VAR aux_nrdiames AS INT                                   NO-UNDO.
DEF        VAR aux_nrdiamss AS INT                                   NO-UNDO.
DEF        VAR aux_ddlanmto AS INT                                   NO-UNDO.
DEF        VAR aux_inliquid AS INT                                   NO-UNDO.
DEF        VAR aux_qtprepag AS INT     FORMAT "zz9"                  NO-UNDO.

DEF        VAR aux_dsregist AS CHAR    FORMAT "x(240)"               NO-UNDO.
DEF        VAR aux_nrcadast AS INT                                   NO-UNDO.
DEF        VAR aux_nmprimtl AS CHAR    FORMAT "x(30)"                NO-UNDO.
DEF        VAR aux_nrctrarq AS DECI                                  NO-UNDO.

DEF        VAR aux_cdcritic AS INTE                                  NO-UNDO.
DEF        VAR aux_dscritic AS CHAR                                  NO-UNDO.

DEF        VAR h-b1wgen0002 AS HANDLE                                NO-UNDO.

/* vars para impressao.i */
DEF    VAR aux_nmendter AS CHAR    FORMAT "x(20)"                     NO-UNDO.
DEF    VAR par_flgrodar AS LOGICAL INIT TRUE                          NO-UNDO.
DEF    VAR aux_flgescra AS LOGICAL                                    NO-UNDO.
DEF    VAR aux_dscomand AS CHAR                                       NO-UNDO.
DEF    VAR par_flgfirst AS LOGICAL INIT TRUE                          NO-UNDO.
DEF    VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF    VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.
DEF    VAR par_flgcance AS LOGICAL                                    NO-UNDO.

DEF    VAR aux_flgativo AS INTEGER                                    NO-UNDO.

FORM rel_dsintegr     AT  1 FORMAT "x(25)"      LABEL "TIPO"
     rel_nmempres     AT 33 FORMAT "x(15)"      LABEL "EMPRESA"
     SKIP(1)
     craplot.dtmvtolt AT  1 FORMAT "99/99/9999" LABEL "DATA"
     craplot.cdagenci AT 18 FORMAT "zz9"        LABEL "AGENCIA"
     craplot.cdbccxlt AT 33 FORMAT "zz9"        LABEL "BANCO/CAIXA"
     craplot.nrdolote AT 52 FORMAT "zzz,zz9"    LABEL "LOTE"
     craplot.tplotmov AT 66 FORMAT "9"          LABEL "TIPO"
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS NO-LABELS  
                 WIDTH 132 FRAME f_integracao.

FORM craprej.nrdconta       FORMAT "zzzz,zz9,9"          LABEL "CONTA/DV"
     craprej.nrdctabb       FORMAT "zzz,zz9,9"           LABEL "CADASTRO"
     craprej.dshistor       FORMAT "x(30)"               LABEL "NOME"
     craprej.nrdocmto       FORMAT "zzzz,zz9,9"          LABEL "CONTRATO"
     craprej.cdhistor       FORMAT "zzz9"                LABEL "HST "
     craprej.vllanmto       FORMAT "zzz,zz9.99-"         LABEL "VALOR "
     glb_dscritic           FORMAT "x(40)"               LABEL "CRITICA"
     WITH NO-BOX NO-ATTR-SPACE DOWN NO-LABELS WIDTH 132  FRAME f_rejeitados.

FORM SKIP(1)
     "QTD               DEBITO               CREDITO" AT 26
     SKIP
     "A INTEGRAR: "     AT  9
     craplot.qtinfoln   AT 22 FORMAT "zzz,zz9-"
     craplot.vlinfodb   AT 32 FORMAT "zzz,zzz,zzz,zz9.99-"
     craplot.vlinfocr   AT 54 FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP
     "INTEGRADOS: "     AT  9
     craplot.qtcompln   AT 22 FORMAT "zzz,zz9-"
     craplot.vlcompdb   AT 32 FORMAT "zzz,zzz,zzz,zz9.99-"
     craplot.vlcompcr   AT 54 FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP(1)
     "REJEITADOS: "     AT  9
     rel_qtdifeln       AT 22 FORMAT "zzz,zz9-"
     rel_vldifedb       AT 32 FORMAT "zzz,zzz,zzz,zz9.99-"
     rel_vldifecr       AT 54 FORMAT "zzz,zzz,zzz,zz9.99-"
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 COLUMN 10 FRAME f_totais.

FORM aux_dsregist FORMAT "x(240)" WITH WIDTH 245 FRAME fr_arquivo.

ASSIGN glb_cdprogra = "crps085"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RETURN "651".
     END.

IF   glb_inrestar > 0   AND   glb_nrctares = 0   THEN
     glb_inrestar = 0.

ASSIGN aux_regexist = FALSE
       aux_dtintegr = IF   glb_inproces > 2 THEN
                           glb_dtmvtopr                       
                      ELSE
                      IF   glb_inproces = 1 THEN
                           glb_dtmvtolt
                      ELSE
                           ?
       aux_dtmvtolt = aux_dtintegr
       aux_nrmesant = IF MONTH(glb_dtmvtolt) = 1 THEN 
                         12
                      ELSE 
                         MONTH(glb_dtmvtolt) - 1.

IF   aux_dtintegr = ?   THEN
     DO:
         ASSIGN glb_cdcritic = 138.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                            glb_cdprogra + "' --> '" + glb_dscritic +
                          " >> log/proc_batch.log").
         RUN fontes/fimprg.p.
         RETURN "138".                 
     END.

/*  Inicializacao das variaves para a rotina de calculo - parte 1  */

aux_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) + 4) -
                            DAY(DATE(MONTH(glb_dtmvtolt),28,
                                      YEAR(glb_dtmvtolt)) + 4)).

FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                   craptab.nmsistem = "CRED"          AND
                   craptab.tptabela = "USUARI"        AND
                   craptab.cdempres = 11              AND
                   craptab.cdacesso = "TAXATABELA"    AND
                   craptab.tpregist = 0               NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     tab_inusatab = FALSE.
ELSE
     tab_inusatab = IF SUBSTRING(craptab.dstextab,1,1) = "0" THEN 
                       FALSE
                    ELSE 
                       TRUE.

IF   NOT VALID-HANDLE(h-b1wgen0002)   THEN
     RUN sistema/generico/procedures/b1wgen0002.p
     PERSISTENT SET h-b1wgen0002.

/*  Leitura das solicitacoes de integracao  */

FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                       crapsol.dtrefere = glb_dtmvtolt   AND
                       crapsol.nrsolici = 45             AND
                       crapsol.insitsol = 1:

    IF   glb_dtmvtolt = aux_dtintegr   THEN     /* Testa integ. por fora */
         IF   SUBSTRING(crapsol.dsparame,15,1) = "1"  THEN
              NEXT.

    /*  Leitura da data de pagamento da empresa  */

    FIND craptab WHERE craptab.cdcooper = glb_cdcooper       AND
                       craptab.nmsistem = "CRED"             AND
                       craptab.tptabela = "GENERI"           AND
                       craptab.cdempres = 0                  AND
                       craptab.cdacesso = "DIADOPAGTO"       AND
                       craptab.tpregist = crapsol.cdempres   NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptab   THEN
         DO:
             glb_cdcritic = 55.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" + glb_dscritic +
                               "CRED-GENERI-00-DIADOPAGTO DA EMPRESA " +
                               STRING(crapsol.cdempres,"99999") +    
                               " >> log/proc_batch.log").
             IF   glb_inproces = 1   THEN
                  RETURN "55".
             ELSE
                  NEXT.  /* Le proxima solicitacao */
         END.

    ASSIGN tab_ddmesnov = INTEGER(SUBSTRING(craptab.dstextab,1,2))
           tab_ddpgtoms = INTEGER(SUBSTRING(craptab.dstextab,4,2))
           tab_ddpgtohr = INTEGER(SUBSTRING(craptab.dstextab,7,2))

           glb_cdcritic = 0
           glb_cdempres = 11
           glb_nrdevias = crapsol.nrdevias.

    /*  Monta data do mes novo  */

    IF   tab_ddmesnov > DAY(glb_dtmvtolt)   THEN
         aux_dtmesnov = DATE(MONTH(glb_dtmvtolt - DAY(glb_dtmvtolt)),
                             tab_ddmesnov,
                             YEAR(glb_dtmvtolt - DAY(glb_dtmvtolt))).
    ELSE
         aux_dtmesnov = DATE(MONTH(glb_dtmvtolt),tab_ddmesnov,
                              YEAR(glb_dtmvtolt)).

    { includes/cabrel132_1.i }               /* Monta cabecalho do relatorio */

    ASSIGN aux_regexist = TRUE
           aux_flgfirst = TRUE
           aux_flgclote = IF glb_inrestar = 0
                             THEN TRUE
                             ELSE FALSE

           aux_contaarq = aux_contaarq + 1

           aux_nmarquiv[aux_contaarq] = "rlnsv/crrl072_" +
                                        STRING(crapsol.nrseqsol,"999") + ".lst"
           aux_nrdevias[aux_contaarq] = crapsol.nrdevias

           aux_dtrefere = DATE(INTEGER(SUBSTRING(crapsol.dsparame,4,2)),
                               INTEGER(SUBSTRING(crapsol.dsparame,1,2)),
                               INTEGER(SUBSTRING(crapsol.dsparame,7,4)))
            
           /* integra/e00104 10 08 2013 */
           aux_nmarqint = "integra/e" +
                          STRING(crapsol.cdempres,"99999") +  
                          STRING(DAY(aux_dtrefere),"99") +
                          STRING(MONTH(aux_dtrefere),"99") +
                          STRING(YEAR(aux_dtrefere),"9999")

           aux_vledvmto = 0.

    /*  Verifica se o arquivo a ser integrado existe em disco  */
    IF  SEARCH(aux_nmarqint) = ?   THEN
        DO:
            ASSIGN aux_nmarqint = aux_nmarqint + ".dat".

            IF  SEARCH(aux_nmarqint) = ?   THEN
                DO:
                    ASSIGN aux_nmarqint = "integra/e" +
                                          STRING(crapsol.cdempres,"999") +  
                                          STRING(DAY(aux_dtrefere),"99") +
                                          STRING(MONTH(aux_dtrefere),"99") +
                                          STRING(YEAR(aux_dtrefere),"9999").

                    IF  SEARCH(aux_nmarqint) = ?   THEN
                        DO:
                            ASSIGN aux_nmarqint = aux_nmarqint + ".dat".
                                              
                            IF  SEARCH(aux_nmarqint) = ?   THEN
                                DO:
                                    ASSIGN aux_nmarqint = "integra/e" +
                                             STRING(crapsol.cdempres,"99") +  
                                             STRING(DAY(aux_dtrefere),"99") +
                                             STRING(MONTH(aux_dtrefere),"99") +
                                             STRING(YEAR(aux_dtrefere),"9999").

                                    IF  SEARCH(aux_nmarqint) = ?   THEN
                                        DO:
                                            ASSIGN aux_nmarqint = 
                                                       aux_nmarqint + ".dat".
                                                              
                                            IF  SEARCH(aux_nmarqint) = ?   THEN
                                                DO:
                                                   glb_cdcritic = 182.
                                                   RUN fontes/critic.p.
                                                   UNIX SILENT VALUE
                                          ("echo " + STRING(TIME,"HH:MM:SS") + 
                                           " - " + glb_cdprogra + "' --> '" +
                                           glb_dscritic + "' --> '" + 
                                           aux_nmarqint + 
                                           " >> log/proc_batch.log").
                                                       
                                                   IF   glb_inproces = 1   THEN
                                                        RETURN "182".
                                                   ELSE
                                                        NEXT.  
                                                   /* Le proxima solicitacao */
                                                END.
                                        END.
                                END.
                        END.
                END.
        END.
    /*  Le numero de lote a ser usado na integracao  */

    FIND craptab WHERE craptab.cdcooper = glb_cdcooper       AND
                       craptab.nmsistem = "CRED"             AND
                       craptab.tptabela = "GENERI"           AND
                       craptab.cdempres = 0                  AND
                       craptab.cdacesso = "NUMLOTEEMP"       AND
                       craptab.tpregist = crapsol.cdempres   NO-ERROR.

    IF   NOT AVAILABLE craptab   THEN
         DO:
             glb_cdcritic = 175.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                glb_cdprogra + "' --> '" + glb_dscritic +
                               " EMPRESA = " + STRING(crapsol.cdempres,"99999")
                                + " >> log/proc_batch.log").
             IF   glb_inproces = 1   THEN
                  RETURN "175".
             ELSE
                  NEXT.  /* Le proxima solicitacao */
         END.
    ELSE
         aux_nrdolote = INTEGER(craptab.dstextab).

    UNIX SILENT VALUE("dos2ux " + aux_nmarqint + " > " + aux_nmarqint + "_ux").
    UNIX SILENT VALUE("quoter " + aux_nmarqint + "_ux > " + 
                      aux_nmarqint + ".q").
    UNIX SILENT VALUE("rm " + aux_nmarqint + "_ux").

    INPUT STREAM str_2 FROM VALUE(aux_nmarqint + ".q") NO-ECHO.

    glb_cdcritic = 219.
    RUN fontes/critic.p.
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '" +
                       glb_dscritic + "' --> '" + aux_nmarqint +
                       " >> log/proc_batch.log").

    glb_cdcritic = 0.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE ON ERROR UNDO, RETURN:

       IF   glb_cdcritic > 0  THEN
            DO:
                RUN fontes/critic.p.  
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - " + glb_cdprogra + "' --> '" +
                              glb_dscritic + "' --> '" + STRING(aux_nrdconta) + 
                              " >> log/proc_batch.log").
            END.
            
       glb_cdcritic = 0.

       IF   glb_inrestar = 0   THEN
            DO:  
                SET STREAM str_2 aux_dsregist WITH FRAME fr_arquivo.   

                ASSIGN aux_tpregist = INT(SUBSTR(aux_dsregist, 8, 1)).

                IF   aux_tpregist = 0   THEN
                     DO:   
                         IF   INT(SUBSTR(aux_dsregist, 143, 1)) <> 1   THEN
                              LEAVE.

                     END.
                ELSE
                IF   aux_tpregist = 1   THEN
                     DO:
                         aux_cdempres = INT(SUBSTR(aux_dsregist, 47, 6)). 
                         
                         IF   aux_cdempres <> crapsol.cdempres   THEN
                              DO:
                                 UNIX SILENT VALUE("rm " + 
                                             aux_nmarqint + ".q 2>/dev/null").
                                 UNIX SILENT VALUE("mv " + 
                                                    aux_nmarqint + " " + 
                                                    SUBSTR(aux_nmarqint,1,8) +  
                                                    "err" + 
                                                    SUBSTR(aux_nmarqint,9,15)).

                                 IF   glb_inproces = 1   THEN
                                      RETURN "173".
                                 ELSE
                                      glb_cdcritic = 173.
                              END.
                     END.

                
                IF   glb_cdcritic > 0   THEN
                     DO:
                         RUN fontes/critic.p.
                         UNIX SILENT VALUE("echo " +
                                           STRING(TIME,"HH:MM:SS") +
                                           " - " + glb_cdprogra +
                                           "' --> '" + glb_dscritic +
                                           " EMPRESA = " +
                                           STRING(crapsol.cdempres,"99999") +  
                                           " >> log/proc_batch.log").
                         LEAVE.      /* Le proxima solicitacao */
                     END.   
               
                IF   aux_tpregist = 9   THEN
                     LEAVE.
                ELSE
                IF   aux_tpregist <> 3   THEN
                     NEXT.
            END.
       ELSE
            DO:
                
                DO WHILE aux_nrseqint <> glb_nrctares:
                   SET STREAM str_2 aux_dsregist WITH FRAME fr_arquivo.
                END.

                IF   aux_tpregist = 9   THEN
                     LEAVE.
            END.

       aux_flgfirst = FALSE.

       ASSIGN aux_nrseqint = INT(SUBSTR(aux_dsregist, 9, 5)) 
              aux_vldescto = DECI(SUBSTR(aux_dsregist, 144, 9)) / 100
              aux_cdhistor = 93 
              aux_cdtipsfx = 1
              aux_nrctremp = INT(SUBSTR(aux_dsregist, 162, 20))
              aux_vledvmto = DECI(SUBSTR(aux_dsregist, 79, 9)) / 100
              aux_nrcadast = INT(SUBSTR(aux_dsregist, 63, 12))
              aux_nmprimtl = SUBSTR(aux_dsregist, 16, 30)
              aux_nrctrarq = DECI(SUBSTR(aux_dsregist, 162, 20)).
 
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        /* Verifica se ha contratos de acordo */
        RUN STORED-PROCEDURE pc_verifica_acordo_ativo
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper
                                              ,INPUT aux_nrdconta
                                              ,INPUT aux_nrctremp
                                              ,0
                                              ,0
                                              ,"").

        CLOSE STORED-PROC pc_verifica_acordo_ativo
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN glb_cdcritic = 0
               glb_dscritic = ""
               glb_cdcritic = INT(pc_verifica_acordo_ativo.pr_cdcritic) WHEN pc_verifica_acordo_ativo.pr_cdcritic <> ?
               glb_dscritic = pc_verifica_acordo_ativo.pr_dscritic WHEN pc_verifica_acordo_ativo.pr_dscritic <> ?
               aux_flgativo = INT(pc_verifica_acordo_ativo.pr_flgativo) WHEN pc_verifica_acordo_ativo.pr_flgativo <> ?.
               
        IF glb_cdcritic > 0 THEN
          DO:
            RUN fontes/critic.p.
            UNIX SILENT VALUE("echo " +
                            STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '" +
                            glb_dscritic + " >> log/proc_batch.log").
            NEXT.                
          END.
        ELSE IF glb_dscritic <> ? AND glb_dscritic <> "" THEN
          DO:
            UNIX SILENT VALUE("echo " +
                              STRING(TIME,"HH:MM:SS") +
                              " - " + glb_cdprogra + "' --> '" +
                              glb_dscritic + " >> log/proc_batch.log").
            NEXT.                  
          END.
          
        IF aux_flgativo = 1 THEN
          NEXT.
          
        /* Fim Verifica se ha contratos de acordo */
        
       /* Se for Big Timber entao deve incluir o digito verificador no numero
          do cadastro, pois eles estao mandando os arquivos sem o digito */

       IF   crapcop.cdcooper = 1 AND aux_cdempres = 57   THEN        
            DO:
                ASSIGN glb_nrcalcul = INT(TRIM(STRING(aux_nrcadast)) + "0")
                       glb_cdcritic = 0.
                 
                RUN fontes/digfun.p.
                    
                ASSIGN aux_nrcadast = glb_nrcalcul.
            END.
            
       TRANS_1:
       DO TRANSACTION ON ERROR UNDO TRANS_1, RETURN:
        
          IF   aux_flgclote   THEN
               DO:
                   aux_nrdolote = aux_nrdolote + 1.

                   IF   CAN-FIND(craplot WHERE
                                 craplot.cdcooper = glb_cdcooper   AND
                                 craplot.dtmvtolt = aux_dtintegr   AND
                                 craplot.cdagenci = aux_cdagenci   AND
                                 craplot.cdbccxlt = aux_cdbccxlt   AND
                                 craplot.nrdolote = aux_nrdolote
                                 USE-INDEX craplot1)   THEN
                        DO:
                            glb_cdcritic = 59.
                            RUN fontes/critic.p.
                            UNIX SILENT VALUE("echo " +
                                              STRING(TIME,"HH:MM:SS") +
                                              " - " + glb_cdprogra + "' --> '" +
                                              glb_dscritic + " EMPRESA = " +
                                              STRING(crapsol.cdempres,"99999")
                                              + " LOTE = " +
                                              STRING(aux_nrdolote,"999,999") +
                                              " >> log/proc_batch.log").

                            UNIX SILENT VALUE("rm " + aux_nmarqint + 
                                              ".q 2>/dev/null").
                            UNIX SILENT VALUE("mv " + 
                                              aux_nmarqint + " " + 
                                              SUBSTR(aux_nmarqint,1,8) +  
                                              "err" + 
                                              SUBSTR(aux_nmarqint,9,15)).

                            IF   glb_inproces = 1   THEN
                                 RETURN "59".
                            ELSE
                                 LEAVE.      /* Le proxima solicitacao */
                        END.

                   CREATE craplot.
                   ASSIGN craplot.dtmvtolt = aux_dtintegr
                          craplot.cdagenci = aux_cdagenci
                          craplot.cdbccxlt = aux_cdbccxlt
                          craplot.nrdolote = aux_nrdolote
                          craplot.tplotmov = 5
                          craptab.dstextab = STRING(aux_nrdolote,"999999")
                          aux_flgclote     = FALSE
                          craplot.cdcooper = glb_cdcooper.
                   VALIDATE craplot.
               END.
          ELSE
               DO:

                   FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                                      craplot.dtmvtolt = aux_dtintegr   AND
                                      craplot.cdagenci = aux_cdagenci   AND
                                      craplot.cdbccxlt = aux_cdbccxlt   AND
                                      craplot.nrdolote = aux_nrdolote
                                      USE-INDEX craplot1 
                                      NO-ERROR.

                   IF   NOT AVAILABLE craplot   THEN
                        DO:
                            glb_cdcritic = 60.
                            RUN fontes/critic.p.
                            UNIX SILENT VALUE("echo " +
                                              STRING(TIME,"HH:MM:SS") +
                                              " - " + glb_cdprogra + "' --> '" +
                                              glb_dscritic + " EMPRESA = " +
                                              STRING(crapsol.cdempres,"99999")
                                              + " LOTE = " +
                                              STRING(aux_nrdolote,"999,999") +
                                              " >> log/proc_batch.log").

                            UNIX SILENT VALUE("rm " + aux_nmarqint + 
                                              ".q 2>/dev/null").
                            UNIX SILENT VALUE("mv " + 
                                              aux_nmarqint + " " + 
                                              SUBSTR(aux_nmarqint,1,8) +  
                                              "err" + 
                                              SUBSTR(aux_nmarqint,9,15)).

                            IF   glb_inproces = 1   THEN
                                 RETURN "60".
                            ELSE
                                 LEAVE.      /* Le proxima solicitacao */
                        END.
               END.

          ASSIGN aux_nrdocmto = 0
                 aux_flgretor = FALSE.
               
          FIND crapepr WHERE crapepr.cdcooper = glb_cdcooper  AND
                             crapepr.cdempres = aux_cdempres  AND
                             crapepr.nrcadast = aux_nrcadast  AND
                             crapepr.nrctremp = aux_nrctremp  AND
                             crapepr.tpdescto = 2             AND
                             crapepr.inliquid = 0             
                             EXCLUSIVE-LOCK NO-ERROR.

          IF   NOT AVAILABLE crapepr   THEN
               DO:
                   ASSIGN glb_cdcritic = 356
                          aux_nrdconta = 0.
                   RUN p_cria_rejeitados.
                   NEXT.
               END.

          ASSIGN aux_nrdconta = crapepr.nrdconta.                   

          DO WHILE TRUE:

             FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                                crapass.nrdconta = aux_nrdconta
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

             IF  AVAILABLE crapass  THEN
                 DO:
                     ASSIGN aux_cdempres_2 = 0.
                     IF   crapass.inpessoa = 1   THEN 
                          DO:
                              FIND crapttl WHERE 
                                   crapttl.cdcooper = glb_cdcooper       AND
                                   crapttl.nrdconta = crapass.nrdconta   AND
                                   crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
            
                              IF   AVAIL crapttl  THEN
                                   ASSIGN aux_cdempres_2 = crapttl.cdempres.
                          END.
                     ELSE
                          DO:
                              FIND crapjur WHERE 
                                   crapjur.cdcooper = glb_cdcooper  AND
                                   crapjur.nrdconta = crapass.nrdconta
                                   NO-LOCK NO-ERROR.
            
                              IF   AVAIL crapjur  THEN
                                   ASSIGN aux_cdempres_2 = crapjur.cdempres.
                          END.
                 END.

             IF   NOT AVAILABLE crapass   THEN
                  IF   LOCKED crapass   THEN
                       DO:
                           PAUSE 1 NO-MESSAGE.
                           NEXT.
                       END.
                  ELSE
                       glb_cdcritic = 9.
             ELSE
                  DO:                    
                      IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
                           glb_cdcritic = 695.
                      ELSE
                      IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN
                           glb_cdcritic = 95.
                      ELSE
                      IF   crapass.dtelimin <> ?  THEN
                           glb_cdcritic = 410.
                      ELSE
                      IF   aux_cdempres_2 <> aux_cdempres   THEN
                           glb_cdcritic = 174.

                      ASSIGN crapass.vledvmto = aux_vledvmto
                             crapass.cdtipsfx = aux_cdtipsfx
                             crapass.dtedvmto = aux_dtrefere.
                  END.

             LEAVE.

          END.  /*  Fim do DO WHILE TRUE  */

          IF   glb_cdcritic > 0   THEN
               DO:
                   RUN p_cria_rejeitados.
                   NEXT.
               END.
          
          IF   aux_vldescto = 0   THEN
               DO:
                   ASSIGN glb_cdcritic = 91.
                   RUN p_cria_rejeitados.
                   NEXT.
               END.
               
          IF   tab_inusatab  THEN
               DO:
                   /*FIND craplcr OF crapepr NO-LOCK NO-ERROR.*/
                   FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper AND
                                      craplcr.cdlcremp = crapepr.cdlcremp
                                      NO-LOCK NO-ERROR.

                   IF   NOT AVAILABLE craplcr   THEN
                        DO:
                            glb_cdcritic = 363.
                            NEXT.
                        END.
                   ELSE
                        aux_txdjuros = craplcr.txdiaria.
               END.
          ELSE
               aux_txdjuros = crapepr.txjuremp.

          /*  Inicializacao das variaves de calculo - parte 2  */

          ASSIGN aux_nrdconta = crapepr.nrdconta
                 aux_vlsdeved = crapepr.vlsdeved
                 aux_vljuracu = crapepr.vljuracu
                 aux_dtultpag = crapepr.dtultpag
                 aux_inliquid = crapepr.inliquid
                 aux_qtprepag = crapepr.qtprepag
                 aux_vljurmes = crapepr.vljurmes
                 tab_diapagto = IF  CAN-DO("1,3,4",STRING(aux_cdtipsfx))
                                    THEN tab_ddpgtoms
                                    ELSE tab_ddpgtohr.

          IF   MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtopr)   THEN
               DO:
                   aux_dtcalcul = DATE(MONTH(glb_dtmvtopr),tab_diapagto,
                                       YEAR(glb_dtmvtopr)).

                   IF   glb_dtmvtopr > aux_dtcalcul   THEN
                        aux_dtcalcul = glb_dtmvtopr.
               END.
          ELSE
               DO:
                   aux_dtcalcul = DATE(MONTH(glb_dtmvtolt),tab_diapagto,
                                       YEAR(glb_dtmvtolt)).

                   IF   glb_inproces > 2   THEN
                        DO:
                            IF   glb_dtmvtopr > aux_dtcalcul   THEN
                                 aux_dtcalcul = glb_dtmvtopr.
                        END.
                   ELSE
                   IF   glb_dtmvtolt > aux_dtcalcul   THEN
                        ASSIGN tab_dtcalcul = aux_dtcalcul
                               aux_dtcalcul = ?.
               END.

          IF   aux_dtcalcul <> ?   THEN
               DO WHILE TRUE:

                  IF   WEEKDAY(aux_dtcalcul) = 1   OR
                       WEEKDAY(aux_dtcalcul) = 7   THEN
                       DO:
                           aux_dtcalcul = aux_dtcalcul + 1.
                           NEXT.
                       END.

                  FIND crapfer WHERE crapfer.cdcooper = glb_cdcooper  AND
                                     crapfer.dtferiad = aux_dtcalcul
                                     NO-LOCK NO-ERROR.

                  IF   AVAILABLE crapfer   THEN
                       DO:
                           aux_dtcalcul = aux_dtcalcul + 1.
                           NEXT.
                       END.

                  ASSIGN tab_diapagto = DAY(aux_dtcalcul)
                         tab_dtpagemp = aux_dtcalcul.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */
          ELSE
               DO WHILE TRUE:

                  IF   WEEKDAY(tab_dtcalcul) = 1   OR
                       WEEKDAY(tab_dtcalcul) = 7   THEN
                       DO:
                           tab_dtcalcul = tab_dtcalcul + 1.
                           NEXT.
                       END.

                  FIND crapfer WHERE crapfer.cdcooper = glb_cdcooper AND
                                     crapfer.dtferiad = tab_dtcalcul
                                     NO-LOCK NO-ERROR.

                  IF   AVAILABLE crapfer   THEN
                       DO:
                           tab_dtcalcul = tab_dtcalcul + 1.
                           NEXT.
                       END.

                  ASSIGN tab_diapagto = DAY(tab_dtcalcul)
                         tab_dtpagemp = tab_dtcalcul.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

          RUN leitura_lem IN h-b1wgen0002
                  ( INPUT        glb_cdcooper,     /* Cooperativa conectada */
                    INPUT        glb_cdprogra,     /* Codigo do programa corrente */
                    INPUT        aux_nrdconta,     /* Conta do associado */
                    INPUT        crapepr.nrctremp, /* Numero Contrato */
                    INPUT        tab_dtcalcul,     /* Data para calculo do emprestimo */
                    INPUT        crapepr.qtprecal, /* Quantidade de prestacoes calculadas ate momento */

                    INPUT-OUTPUT tab_diapagto,     /* Dia para pagamento */
                    INPUT-OUTPUT aux_txdjuros,     /* Taxa de juros aplicada */
                    INPUT-OUTPUT aux_qtprepag,     /* Quantidade de prestacoes paga ate momento */
                    INPUT-OUTPUT aux_vlprepag,     /* Valor acumulado pago no mes */
                    INPUT-OUTPUT aux_vljurmes,     /* Juros no mes corrente */
                    INPUT-OUTPUT aux_vljuracu,     /* Juros acumulados total */
                    INPUT-OUTPUT aux_vlsdeved,     /* Saldo devedor acumulado */
                    INPUT-OUTPUT aux_dtultpag,     /* Ultimo dia de pagamento das prestacoes */

                    OUTPUT       aux_qtmesdec,     /* Quantidade de meses decorridos */
                    OUTPUT       aux_vlpreapg,     /* Valor a pagar */
                    OUTPUT       aux_cdcritic,     /* Codigo da critica  */
                    OUTPUT       aux_dscritic ).   /* Descricao da critica */

          IF  RETURN-VALUE <> "OK"  THEN
              DO:
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                   " - " + glb_cdprogra + "' --> '" +
                                   "Nao foi possivel calcular o emprestimo. " +
                                   "Conta: " + STRING(aux_nrdconta) + ", " +
                                   "Contrato: " + STRING(crapepr.nrctremp) + ". " +
                                   "Critica: " + aux_dscritic + "' --> '" +
                                   " >> log/proc_batch.log").
                
                 ASSIGN aux_cdcritic = 0
                        aux_dscritic = "".
                        
                 UNDO TRANS_1, NEXT.
              END.

          ASSIGN aux_nrdocmto = aux_nrdocmto + 1.
              
          FIND craplem WHERE 
               craplem.cdcooper = glb_cdcooper       AND 
               craplem.dtmvtolt = craplot.dtmvtolt   AND
               craplem.cdagenci = craplot.cdagenci   AND
               craplem.cdbccxlt = craplot.cdbccxlt   AND
               craplem.nrdolote = craplot.nrdolote   AND
               craplem.nrdconta = aux_nrdconta       AND
               craplem.nrdocmto = INT(STRING(aux_nrdocmto,"99") +
                                  STRING(crapepr.nrctremp,"99999999"))
               EXCLUSIVE-LOCK NO-ERROR.
                         
          IF   NOT AVAILABLE craplem   THEN
               CREATE craplem.
          ASSIGN craplem.dtmvtolt = craplot.dtmvtolt
                 craplem.cdagenci = craplot.cdagenci
                 craplem.cdbccxlt = craplot.cdbccxlt
                 craplem.nrdolote = craplot.nrdolote
                 craplem.nrdconta = aux_nrdconta
                 craplem.nrctremp = crapepr.nrctremp
                 craplem.nrdocmto = INTEGER(STRING(aux_nrdocmto,"99") +
                                    STRING(crapepr.nrctremp,"99999999"))
                 craplem.vllanmto = aux_vldescto
                 craplem.cdhistor = aux_cdhistor
                 craplem.nrseqdig = craplot.nrseqdig + 1
                 craplem.dtpagemp = tab_dtpagemp
                 craplem.txjurepr = aux_txdjuros
                 craplem.vlpreemp = crapepr.vlpreemp
                 craplem.cdcooper = glb_cdcooper

                 craplot.qtinfoln = craplot.qtinfoln + 1
                 craplot.qtcompln = craplot.qtcompln + 1
                 craplot.vlinfocr = craplot.vlinfocr + aux_vldescto
                 craplot.vlcompcr = craplot.vlcompcr + aux_vldescto
                 craplot.nrseqdig = craplem.nrseqdig.
          VALIDATE craplem.

          /* Caso pagamento seja menor que data atual */
          IF  crapepr.dtdpagto < aux_dtmvtolt  THEN
              DO:
          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

          /* Efetuar a chamada a rotina Oracle */ 
          RUN STORED-PROCEDURE pc_efetiva_pag_atraso_tr
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper,          /* Cooperativa conectada */
                                                 INPUT craplot.cdagenci,      /* Codigo da agencia */
                                                 INPUT craplot.cdbccxlt,      /* Numero do caixa */
                                                 INPUT "1",                   /* Codigo do operador */
                                                 INPUT glb_cdprogra,          /* Nome da tela */
                                                 INPUT 1,                     /* Origem=Ayllos */
                                                 INPUT aux_nrdconta,          /* Conta do associado */
                                                 INPUT crapepr.nrctremp,      /* Numero Contrato */
                                                 INPUT aux_vlpreapg,          /* Valor a pagar */
                                                 INPUT aux_qtmesdec,          /* Quantidade de meses decorridos */
                                                 INPUT crapepr.qtprecal,      /* Quantidade de prestacoes calculadas */
                                                 INPUT aux_vldescto,          /* Valor de pagamento da parcela */
                                                 INPUT ?,                     /* Valor Saldo Disponivel */
                                                OUTPUT 0,                     /* Historico da Multa */
                                                OUTPUT 0,                     /* Valor da Multa */
                                                OUTPUT 0,                     /* Historico Juros de Mora */
                                                OUTPUT 0,                     /* Valor Juros de Mora */
                                                OUTPUT 0,                     /* Codigo da critica */
                                                OUTPUT "").                   /* Descricao da critica */

          /* Fechar o procedimento para buscarmos o resultado */ 
          CLOSE STORED-PROC pc_efetiva_pag_atraso_tr
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

          ASSIGN aux_cdcritic = 0
                 aux_dscritic = ""
                 aux_cdcritic = pc_efetiva_pag_atraso_tr.pr_cdcritic
                                   WHEN pc_efetiva_pag_atraso_tr.pr_cdcritic <> ?
                 aux_dscritic = pc_efetiva_pag_atraso_tr.pr_dscritic
                                           WHEN pc_efetiva_pag_atraso_tr.pr_dscritic <> ?.

          IF  aux_cdcritic <> 0   OR
              aux_dscritic <> ""  THEN
              DO:
                  UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                    " - " + glb_cdprogra + "' --> '" +
                                    "Erro ao debitar multa e juros de mora. " +
                                    "Conta: " + STRING(aux_nrdconta) + ", " +
                                    "Contrato: " + STRING(crapepr.nrctremp) + ". " +
                                    "Critica: " + aux_dscritic + "' --> '" +
                                    " >> log/proc_batch.log").

                  ASSIGN aux_cdcritic = 0
                         aux_dscritic = "".
              END.

             END.

          ASSIGN crapepr.dtultpag = craplot.dtmvtolt
                 crapepr.txjuremp = aux_txdjuros
                 aux_vldescto     = aux_vldescto - crapepr.vlpreemp
                 aux_regexist     = TRUE
                 aux_flgretor     = TRUE.

          IF   NOT aux_regexist   THEN
               ASSIGN glb_cdcritic = IF aux_flgretor THEN 358 ELSE 355
                      aux_regexist = TRUE. /* Flega para o valor anterior */
                                                                
          IF   glb_cdcritic > 0   OR   aux_vldescto > 0   THEN
               RUN p_cria_rejeitados.

          DO WHILE TRUE:

             FIND crapres WHERE crapres.cdcooper = glb_cdcooper  AND
                                crapres.cdprogra = glb_cdprogra
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

             IF   NOT AVAILABLE crapres   THEN
                  IF   LOCKED crapres   THEN
                       DO:
                           PAUSE 1 NO-MESSAGE.
                           NEXT.
                       END.
                  ELSE
                       DO:
                           glb_cdcritic = 151.
                           RUN fontes/critic.p.
                           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                             " - " + glb_cdprogra + "' --> '" +
                                             glb_dscritic +
                                             " >> log/proc_batch.log").
                           UNDO TRANS_1, RETURN.
                       END.

             LEAVE.

          END.  /*  Fim do DO WHILE TRUE  */

          ASSIGN crapres.nrdconta = aux_nrseqint.
       END.  /*  Fim da Transacao  */
      
    END.   /*  Fim do DO WHILE TRUE  */
      
    INPUT STREAM str_2 CLOSE.

    IF   glb_cdcritic = 0   THEN
         DO:
             FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                                craplot.dtmvtolt = aux_dtmvtolt   AND
                                craplot.cdagenci = aux_cdagenci   AND
                                craplot.cdbccxlt = aux_cdbccxlt   AND
                                craplot.nrdolote = aux_nrdolote
                                USE-INDEX craplot1 NO-LOCK NO-ERROR.

             IF   NOT AVAILABLE craplot   THEN
                  DO:
                      glb_cdcritic = 60.
                      RUN fontes/critic.p.
                      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                        " - " + glb_cdprogra + "' --> '" +
                                        glb_dscritic + " EMPRESA = " +
                                        STRING(crapsol.cdempres,"99999") +  
                                        " LOTE = " +
                                        STRING(aux_nrdolote,"999,999") +
                                        " >> log/proc_batch.log").
                      RUN fontes/fimprg.p.                
                      UNIX SILENT VALUE("rm " + aux_nmarqint + 
                                        ".q 2>/dev/null").
                      UNIX SILENT VALUE("mv " + aux_nmarqint + " " + 
                                        SUBSTR(aux_nmarqint,1,8) + "err" + 
                                        SUBSTR(aux_nmarqint,9,15)).
                      RETURN "60".
                  END.
             ELSE
                  ASSIGN rel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
                         rel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
                         rel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

             OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv[aux_contaarq])
                    PAGED PAGE-SIZE 84.

             VIEW STREAM str_1 FRAME f_cabrel132_1.

             FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper  AND
                                crapemp.cdempres = aux_cdempres
                                NO-LOCK NO-ERROR.

             IF   NOT AVAILABLE crapemp   THEN
                  rel_nmempres = FILL("*",20).
             ELSE
                  rel_nmempres = crapemp.nmresemp.

             rel_dsintegr = "CREDITO DE EMPRESTIMOS".

             DISPLAY STREAM str_1
                     rel_dsintegr      rel_nmempres
                     craplot.dtmvtolt  craplot.cdagenci
                     craplot.cdbccxlt  craplot.nrdolote
                     craplot.tplotmov
                     WITH FRAME f_integracao.

             FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper   AND
                                    craprej.dtmvtolt = aux_dtmvtolt   AND
                                    craprej.cdagenci = aux_cdagenci   AND
                                    craprej.cdbccxlt = aux_cdbccxlt   AND
                                    craprej.nrdolote = aux_nrdolote   AND
                                    craprej.cdempres = aux_cdempres   AND
                                    craprej.tpintegr = 5              NO-LOCK
                                    BREAK BY craprej.dtmvtolt  
                                             BY craprej.cdagenci
                                                BY craprej.cdbccxlt 
                                                   BY craprej.nrdolote
                                                      BY craprej.cdempres 
                                                         BY craprej.tpintegr
                                                            BY craprej.nrdconta:

                 IF   glb_cdcritic <> craprej.cdcritic   THEN
                      DO:
                          glb_cdcritic = craprej.cdcritic.
                          RUN fontes/critic.p.
                          IF   glb_cdcritic = 211   THEN
                               glb_dscritic = glb_dscritic + " URV do dia " +
                                              STRING(aux_dtintegr,"99/99/9999").
                      END.

                 DISPLAY STREAM str_1 craprej.nrdconta craprej.cdhistor 
                                      craprej.nrdctabb craprej.dshistor
                                      craprej.nrdocmto craprej.vllanmto  
                                      glb_dscritic     WITH FRAME f_rejeitados.

                 DOWN STREAM str_1 WITH FRAME f_rejeitados.

                 IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                      DO:
                          PAGE STREAM str_1.

                          DISPLAY STREAM str_1
                                  rel_dsintegr      rel_nmempres
                                  craplot.dtmvtolt  craplot.cdagenci
                                  craplot.cdbccxlt  craplot.nrdolote
                                  craplot.tplotmov
                                  WITH FRAME f_integracao.
                      END.

             END.   /*  Fim do FOR EACH  --  Leitura dos rejeitados  */

             IF   LINE-COUNTER(str_1) > 78   THEN
                  DO:
                      PAGE STREAM str_1.

                      DISPLAY STREAM str_1
                              rel_dsintegr      rel_nmempres
                              craplot.dtmvtolt  craplot.cdagenci
                              craplot.cdbccxlt  craplot.nrdolote
                              craplot.tplotmov
                              WITH FRAME f_integracao.
                  END.

             DISPLAY STREAM str_1
                     craplot.qtinfoln  craplot.vlinfodb
                     craplot.vlinfocr  craplot.qtcompln
                     craplot.vlcompdb  craplot.vlcompcr
                     rel_qtdifeln      rel_vldifedb
                     rel_vldifecr
                     WITH FRAME f_totais.

             OUTPUT STREAM str_1 CLOSE.

             glb_cdcritic = IF rel_qtdifeln = 0 THEN 190 ELSE 191.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" +
                               glb_dscritic + "' --> '" + aux_nmarqint +
                               " >> log/proc_batch.log").

             ASSIGN glb_nrcopias = 1
                    glb_nmformul = "132col"
                                 /*  IF aux_nrdevias[aux_contaarq] > 1
                                      THEN STRING(aux_nrdevias[aux_contaarq]) +
                                           "vias"
                                      ELSE " "*/
                    glb_nmarqimp = aux_nmarquiv[aux_contaarq]
                    aux_nmarqimp = glb_nmarqimp.

             /* Imprime na hora da solicitacao da tela SOL045 ou vai 
                para batch noturno */
             IF  glb_inproces = 1  THEN
                 RUN gerar_impressao.
             ELSE
                 RUN fontes/imprim.p.
             
             /*  Exclusao dos rejeitados apos a impressao  */

             TRANS_2:

             FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper   AND
                                    craprej.dtmvtolt = aux_dtmvtolt   AND
                                    craprej.cdagenci = aux_cdagenci   AND
                                    craprej.cdbccxlt = aux_cdbccxlt   AND
                                    craprej.nrdolote = aux_nrdolote   AND
                                    craprej.cdempres = aux_cdempres   AND
                                    craprej.tpintegr = 5
                                    TRANSACTION ON ERROR UNDO TRANS_2, RETURN:

                 DELETE craprej.

             END.  /*  Fim do FOR EACH  --  Exclusao dos rejeitados  */

             TRANS_3:

             DO TRANSACTION ON ERROR UNDO TRANS_3, RETURN:

                DO WHILE TRUE:

                   FIND crapres WHERE crapres.cdcooper = glb_cdcooper AND
                                      crapres.cdprogra = glb_cdprogra
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE crapres   THEN
                        IF   LOCKED crapres   THEN
                             DO:
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 glb_cdcritic = 151.
                                 RUN fontes/critic.p.
                                 UNIX SILENT VALUE("echo " +
                                                   STRING(TIME,"HH:MM:SS") +
                                                   " - " + glb_cdprogra +
                                                   "' --> '" + glb_dscritic +
                                                   " >> log/proc_batch.log").
                                 UNDO TRANS_3, RETURN.
                             END.

                   LEAVE.

                END.  /*  Fim do DO WHILE TRUE  */

                ASSIGN crapres.nrdconta = 0
                       crapsol.insitsol = 2.

             END.  /*  Fim da transacao  */

         END.  /*  Fim da impressao do relatorio  */

    ASSIGN glb_nrctares = 0
           glb_inrestar = 0.

    /*  Move arquivo integrado para o diretorio salvar  */
    UNIX SILENT VALUE("mv " + aux_nmarqint + " salvar").

    /*  Copia relatorio para o diretorio rl */
    UNIX SILENT VALUE("cp " + aux_nmarqimp + " rl").

    UNIX SILENT VALUE("rm " + aux_nmarqint + ".q 2>/dev/null").

END.  /*  Fim do FOR EACH  -- Leitura das solicitacoes --  */

IF   VALID-HANDLE(h-b1wgen0002)   THEN
     DELETE OBJECT h-b1wgen0002.

IF   NOT aux_regexist   THEN
     DO:
         glb_cdcritic = 157.
         RUN fontes/critic.p.

         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" + glb_dscritic +
                           " - SOL045" + " >> log/proc_batch.log").
         RUN fontes/fimprg.p.
         RETURN "0".
     END.

RUN fontes/fimprg.p.

RETURN "0".

PROCEDURE p_cria_rejeitados.

    CREATE craprej.
    ASSIGN craprej.dtmvtolt = craplot.dtmvtolt
           craprej.cdagenci = craplot.cdagenci
           craprej.cdbccxlt = craplot.cdbccxlt
           craprej.nrdolote = craplot.nrdolote
           craprej.tplotmov = craplot.tplotmov
           craprej.nrdconta = aux_nrdconta
           craprej.nrdctabb = aux_nrcadast
           craprej.dshistor = aux_nmprimtl
           craprej.nrdocmto = aux_nrctrarq
           craprej.nrdctitg = STRING(aux_nrcadast,"99999999")
           craprej.cdempres = aux_cdempres
           craprej.cdhistor = aux_cdhistor
           craprej.vllanmto = aux_vldescto
           craprej.cdcritic = glb_cdcritic
           craprej.tpintegr = 5
           craprej.cdcooper = glb_cdcooper

           craplot.qtinfoln = craplot.qtinfoln + 1
           craplot.vlinfocr = craplot.vlinfocr + aux_vldescto

           glb_cdcritic     = 0.
    VALIDATE craprej.
END.

PROCEDURE gerar_impressao.
    { includes/impressao.i }
END.

/* ......................................................................... */
