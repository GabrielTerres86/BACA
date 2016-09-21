/* ............................................................................

   Programa: Fontes/crps346.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Junho/2003.                         Ultima atualizacao: 02/02/2016

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Processar as integracoes da compensacao do Banco do Brasil via
               arquivo DEB558.
               Emite relatorio 291.

   Alteracoes: 21/08/2003 - Enviar por email o relatorio da integracao para o
                            Financeiro da CECRED (Edson).

               04/09/2003 - Nao tratar mais o estorno de depositos (Edson).

               01/10/2003 - Corrigir erro no restart (Edson).

               02/10/2003 - Acertar para rodar tambem com o script
                            COMPEFORA (Margarete).

               15/10/2003 - Tirado o = (igual) na verificacao da conta-ordem
                            (Edson)
                            
               29/01/2004 - Nao enviar por email o relatorio de integracao.
                            (Ze Eduardo).

               30/01/2004 - Espec. cobranca eletronica(0624COBRANCA)(Mirtes)
               
               18/06/2004 - Listar o disponivel de todas as conta (Margarete).
               
               25/06/2004 - Eliminar a listagem de depositos (Ze Eduardo).
               
               13/08/2004 - Modificar formulario para duplex (Ze Eduardo).
               
               25/08/2004 - Nao esta mostrando o disponivel correto (Margarete)
               
               04/10/2004 - Gravacao de dados na tabela gntotpl do banco
                            generico, para relatorios gerenciais (Junior).
               
               06/10/2004 - Modificar o SUBSTR da conta base (Ze Eduardo).
               
               29/04/2005 - Modificacao para Conta-Integracao (Ze Eduardo).
               
               23/05/2005 - Incluir coop: 4,5,6 e 7 CTITG (Ze Eduardo).

               30/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craprej, craptab, crapdpb e craplcm (Diego).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               03/10/2005 - Alterado e_mail(Mirtes).
               
               17/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               20/10/2005 - Alteracao de Locks e blocos transacionais(SQLWorks).

               01/11/2005 - Uso da procedure digbbx.p para conversao de campo
                            inteiro para caracter (SQLWorks - Andre).

               10/11/2005 - Tratar campo cdcooper na leitura da tabela
                            crapcor (Edson).
                            
               08/12/2005 - Revisao do crapfdc (Ze).
               
               14/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               22/03/2006 - Acerto no Programa (Ze).
               
               23/05/2006 - Atualizacao dos historicos (Ze).
               
               09/06/2006 - Atualizacao dos historicos (Ze).

               13/02/2007 - Alterar consultas com indice crapfdc1 (David).
               
               04/06/2007 - Alteracao email administrativo para compe(Mirtes)
               
               11/11/2008 - Inlcuir tratamento para contas com digito X (Ze).
               
               11/12/2008 - Chamar BO de email. Alterar o email do rel291 para
                            ariana@viacredi.coop.br (Gabriel).
                            
               06/02/2009 - Acerto no envio do relatorio por email (Ze).
               
               19/03/2009 - Ajustes para unificacao dos bancos de dados
                            (Evandro).
                            
               16/04/2009 - Elimina arquivo de controle nao mais utilizado (Ze) 
 
               27/08/2009 - E_mail juliana.vieira@viacredi.coop.br(Mirtes)
               
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               11/01/2010 - Substituido comando "cat" por "mv" no momento da 
                            integracao do arquivo no sistema (Elton).
                            
               05/02/2010 - Alterado e-mail de juliana.vieira@viacredi.coop.br
                            para graziela.farias@viacredi.coop.br (Fernando).

               02/03/2010 - Ajuste para finalizar a execucao qdo nao existir
                            o arquivo (Ze Eduardo).
                            
               05/04/2010 - Quando der critica 258 enviar email para
                            Magui, Mirtes, Zé e cpd@cecred (Guilherme).   
                            
               12/04/2011 - Incluido o e-mail marilia.spies@viacredi.coop.br
                            para receber o relatorio 291 (Adriano).
                            
               16/05/2011 - Alterado para enviar o rel291 somente para o e-mail
                            marcela@cecred.coop.br (Adriano).
                            
               07/12/2011 - Sustação provisória (André R./Supero).             
                                         
               12/12/2011 - Retirar o email da Marcela - Trf. 43942 (ZE).
               
               15/05/2012 - substituição do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.)
                            
               07/08/2012 - Adicionado parametro "codigo do programa" a chamada
                            da funcao geradev. (Fabricio)
                            
               13/08/2012 - Enviar email quando houver Cheque VLB no arquivo.
                            (Fabricio)
                            
               04/09/2012 - Tratamento crapcop.nmrescop "x(20)" (Diego).             
               
               22/10/2012 - Quando der critica 258 enviar email para
                            Diego, David, Mirtes, Zé e cpd@cecred (Ze).
               
               10/06/2013 - Alteração função enviar_email_completo para
                            nova versão (Jean Michel).
                            
               13/08/2013 - Exclusao da alinea 29. (Fabricio)
               
               08/11/2013 - Adicionado o PA do cooperado ao conteudo do email
                            de notificacao de cheque VLB. (Fabricio)
                            
               21/01/2014 - Incluir VALIDATE craplot, craplcm, craptab, 
                            craprej, gntotpl, crapdpb (Lucas R.)
                            
               26/11/2014 - Ajustado para integrar arquivos da incorporacao.
                            (Reinert)
                            
               01/12/2014 - Ajustando a procedure lista_saldos para gravar os
			                registro na tabela gntotpl para exibir o valor do
							movimento do dia quando for rodado tanto o processo
							normal quanto o processo COMPEFORA. SD - 218189
							(Andre Santos - SUPERO).
                            
              09/04/2015 - Ajuste para não abortar programa pela critica 258
                           sem antes verificar se existe os arquivos para as 
                           coops incorporadas SD 274788 (Odirlei-AMcom)              

              09/11/2015 - Ajustar para sempre exibir a mensagem de arquivo 
                           processado com sucesso. A mensagem eh apenas para
                           saber que o processamento do arquivo foi finalizado.
                           (Douglas - Chamado 306964)

              23/12/2015 - Ajustar parametros da procedure geradev.p 
                         - Ajustar as alineas de acordo com a revisao de alineas
                           (Douglas - Melhoria 100)  

             02/02/2016 - Incluso novos e-mail na rotina de envio e-mail. (Daniel) 
............................................................................. */

DEF STREAM str_1.   /*  Para relatorio de criticas  */
DEF STREAM str_2.   /*  Para arquivo a integrar  */
DEF STREAM str_3.   /*  Para arquivos com os saldos das contas  */

DEF BUFFER crabfdc FOR crapfdc.

{ includes/var_batch.i }

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR tot_contareg AS INT                                   NO-UNDO.
DEF        VAR tot_vllanmto AS DECIMAL                               NO-UNDO.
DEF        VAR tot_vllandep AS DECIMAL                               NO-UNDO.
DEF        VAR tot_qtlandep AS INT                                   NO-UNDO.

DEF        VAR tot_nrdctabb AS INT                                   NO-UNDO.
DEF        VAR tot_dsintegr AS CHAR                                  NO-UNDO.

DEF        VAR tot_qtcompdb AS INT                                   NO-UNDO.
DEF        VAR tot_qtcompcr AS INT                                   NO-UNDO.

DEF        VAR tot_vlcompdb AS DECIMAL                               NO-UNDO.
DEF        VAR tot_vlcompcr AS DECIMAL                               NO-UNDO.

DEF        VAR ger_qtcompdb AS INT                                   NO-UNDO.
DEF        VAR ger_qtcompcr AS INT                                   NO-UNDO.

DEF        VAR ger_vlcompdb AS DECIMAL                               NO-UNDO.
DEF        VAR ger_vlcompcr AS DECIMAL                               NO-UNDO.

DEF        VAR lot_qtcompln AS INT                                   NO-UNDO.
DEF        VAR lot_vlcompdb AS DECIMAL                               NO-UNDO.

DEF        VAR ant_nrdctabb AS INT                                   NO-UNDO.
DEF        VAR ant_dtrefere AS CHAR                                  NO-UNDO.
DEF        VAR ant_dtretroa AS CHAR                                  NO-UNDO.
DEF        VAR ant_vldsaldo AS CHAR                                  NO-UNDO.

DEF        VAR aux_nmarqint AS CHAR    FORMAT "x(50)" EXTENT 99      NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR    FORMAT "x(20)" EXTENT 99      NO-UNDO.
DEF        VAR aux_nrdevias AS INT     FORMAT "z9"    EXTENT 99      NO-UNDO.

DEF        VAR aux_vlstotal AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlsdchsl AS DECIMAL                               NO-UNDO.
DEF        VAR aux_txdoipmf AS DECIMAL FORMAT "zzz,zz9.9999"         NO-UNDO.

DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgclote AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgentra AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgerros AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgarqvz AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgcontr AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgdepos AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgchequ AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgestor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgchqbb AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.

DEF        VAR aux_cobranca AS LOGICAL                               NO-UNDO.
DEF        VAR aux_dshstcob AS CHAR                                  NO-UNDO.
DEF        VAR aux_dsdctitg AS CHAR                                  NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_contaarq AS INT                                   NO-UNDO.

DEF        VAR aux_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdhistor AS INT                                   NO-UNDO.
DEF        VAR aux_nrdolote AS INT                                   NO-UNDO.
DEF        VAR aux_nrdiautl AS INT                                   NO-UNDO.

DEF        VAR aux_nrdctabb AS INT     FORMAT "99999999"             NO-UNDO.
DEF        VAR aux_nrdconta AS INT     FORMAT "99999999"             NO-UNDO.
DEF        VAR aux_nrseqint AS INT     FORMAT "999999"               NO-UNDO.
DEF        VAR aux_nrdocmto AS INT     FORMAT "99999999"             NO-UNDO.
DEF        VAR aux_nrdocmt2 AS INT     FORMAT "99999999"             NO-UNDO.
DEF        VAR aux_vllanmto AS DECIMAL FORMAT "99999999999999.99"    NO-UNDO.

DEF        VAR aux_lscontas AS CHAR                                  NO-UNDO.
DEF        VAR aux_lsconta1 AS CHAR                                  NO-UNDO.
DEF        VAR aux_lsconta2 AS CHAR                                  NO-UNDO.
DEF        VAR aux_lsconta3 AS CHAR                                  NO-UNDO.
DEF        VAR aux_lsconta4 AS CHAR                                  NO-UNDO.

DEF        VAR aux_dsdlinha AS CHAR    FORMAT "x(210)"               NO-UNDO.
DEF        VAR aux_cdpesqbb AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR aux_dshistor AS CHAR    FORMAT "x(29)"                NO-UNDO.
DEF        VAR aux_indebcre AS CHAR    FORMAT "x(1)"                 NO-UNDO.
DEF        VAR aux_dtrefere AS CHAR    FORMAT "x(10)"                NO-UNDO.
DEF        VAR aux_dtretroa AS CHAR    FORMAT "x(10)"                NO-UNDO.
DEF        VAR aux_vldsaldo AS CHAR    FORMAT "x(24)"                NO-UNDO.
DEF        VAR aux_dsageori AS CHAR    FORMAT "x(7)"                 NO-UNDO.

DEF        VAR aux_lsparame AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR aux_dshstchq AS CHAR                                  NO-UNDO.
DEF        VAR aux_dshstdep AS CHAR                                  NO-UNDO.
DEF        VAR aux_dshstblq AS CHAR                                  NO-UNDO.
DEF        VAR aux_dshstest AS CHAR                                  NO-UNDO.
DEF        VAR aux_dsestblq AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.

DEF        VAR aux_dsdemail AS CHAR                                  NO-UNDO.
DEF        VAR aux_lsdestin AS CHAR                                  NO-UNDO.
DEF        VAR aux_dtleiarq AS DATE                                  NO-UNDO.

/*  codigo de agencia com digito calculado: ex. 3164-01 = 3164012  */

DEF        VAR aux_lsagenci AS CHAR INIT
  "14077,16179,305057,3164012,405019,407020,410020,486019,562017,714020,828017" 
                                                                     NO-UNDO.

DEF        VAR aux_nmarqsld AS CHAR    INIT "arq/crps039.dat"        NO-UNDO.

DEF        VAR aux_vlmaichq AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR aux_vlsldneg AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.

DEF        VAR aux_dtliblan AS DATE                                  NO-UNDO.
DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.

DEF        VAR aux_indevchq AS INT                                   NO-UNDO.
DEF        VAR aux_cdalinea AS INT     INIT 0                        NO-UNDO.

DEF        VAR aux_lsconven AS CHAR                                  NO-UNDO.

DEF        VAR aux_nomedarq AS CHAR                                  NO-UNDO.

DEF        VAR h-b1wgen0011 AS HANDLE                                NO-UNDO.
DEF        VAR aux_conteudo AS CHAR                                  NO-UNDO.
DEF        VAR aux_vlchqvlb AS DECI                                  NO-UNDO.

DEF        VAR aux_cdcooper AS INTE EXTENT 2                         NO-UNDO.
DEF        VAR aux_flgarqui AS LOGICAL                               NO-UNDO.

DEF TEMP-TABLE crawtot                                               NO-UNDO
               FIELD nrdctabb AS INT 
               FIELD dshistor AS CHAR
               FIELD vllanmto AS DECIMAL
               FIELD qtlanmto AS INT
               FIELD indebcre AS CHAR
               INDEX somatoria1 AS PRIMARY nrdctabb dshistor.

DEF TEMP-TABLE crawdpb                                               NO-UNDO 
               FIELD nrdctabb AS INT
               FIELD vldispon AS DECIMAL
               FIELD vlblq001 AS DECIMAL
               FIELD vlblq002 AS DECIMAL
               FIELD vlblq003 AS DECIMAL
               FIELD vlblq004 AS DECIMAL
               FIELD vlblq999 AS DECIMAL
               INDEX bloqueio AS PRIMARY nrdctabb.

DEF TEMP-TABLE tt-crapcop
               FIELD cdcooper AS INTE
               FIELD cdconven AS INTE.

ASSIGN glb_cdprogra = "crps346"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

FORM "LANCAMENTOS COM CRITICAS:"
     SKIP(1)
     "SEQ.ARQ HISTORICO BB    CONTA BASE DATA REF    DOCUMENTO COD. PESQUISA"
      AT  1
     "VALOR DO LANCAMENTO    CONTA/DV CRITICA"                      AT 72
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_labelrej.

FORM craprej.nrseqdig AT   1 FORMAT "zzz,zz9"
     craprej.dshistor AT   9 FORMAT "x(15)"
     craprej.nrdctabb AT  25 FORMAT "zzzz,zz9,9"
     craprej.dtrefere AT  36 FORMAT "x(10)"
     craprej.nrdocmto AT  47 FORMAT "zzzz,zzz,9"
     craprej.cdpesqbb AT  58 FORMAT "x(13)"
     craprej.vllanmto AT  72 FORMAT "zzzzzzz,zzz,zz9.99"
     craprej.indebcre AT  91 FORMAT "x"
     craprej.nrdconta AT  93 FORMAT "zzzz,zzz,9"
     glb_dscritic     AT 104 FORMAT "x(29)"
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_rejeitados.

FORM SKIP(1)
     tot_contareg AT 1 FORMAT "zzz,zz9" LABEL "QUANTIDADE DE LANCAMENTOS"
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS WIDTH 132 FRAME f_totalrej.

FORM "LANCAMENTOS INTEGRADOS (CHEQUES MAIORES =" AT 1
     aux_vlmaichq     AT  43 NO-LABEL
     "):"             AT  61
     SKIP(1)
     craplot.dtmvtolt AT   1 LABEL "DATA" FORMAT "99/99/9999"
     craplot.cdagenci AT  21 LABEL "AGENCIA"
     craplot.cdbccxlt AT  39 LABEL "BANCO/CAIXA"
     craplot.nrdolote AT  61 LABEL "LOTE"
     craplot.qtcompln AT  77 LABEL "QTD."
     craplot.vlcompdb AT  96 LABEL "TOTAL"
     SKIP(1)
     "CONTA BASE         DOCUMENTO      CONTA/DV   HISTORICO" AT  10
     "VALOR DO LANCAMENTO    CODIGO PESQUISA     SEQ.INT"     AT  71
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS WIDTH 132 FRAME f_labelint.

FORM craplcm.nrdctabb AT  10 FORMAT "zzzz,zzz,9"
     craplcm.nrdocmto AT  24 FORMAT "zzzz,zzz,zzz,9"
     craplcm.nrdconta AT  42 FORMAT "zzzz,zzz,9"
     craplcm.cdhistor AT  58 FORMAT "zzz9"
     craplcm.vllanmto AT  68 FORMAT "zzz,zzz,zzz,zzz,zz9.99"
     craplcm.cdpesqbb AT  94 FORMAT "x(15)"
     craplcm.nrseqdig AT 114 FORMAT "zzz,zz9"
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_integrados.

FORM SKIP(1)
     tot_contareg AT  1 FORMAT "zz,zzz,zz9" LABEL "QUANTIDADE DE LANCAMENTOS"
     tot_vllanmto AT 59 FORMAT "z,zzz,zzz,zzz,zzz,zz9.99" LABEL "TOTAL"
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS WIDTH 132 FRAME f_totalint.

FORM "RESUMO PARA FECHAMENTO DE CONTA:" AT 1
     SKIP(1)
     "QUANTIDADE" AT  72
     "VALOR"      AT 102
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_labelres.

FORM tot_dsintegr          AT 27 FORMAT "x(20)"
     tot_nrdctabb          AT 47 FORMAT "zzzz,zzz,z"
     "A DEBITO:"           AT 61
     tot_qtcompdb          AT 75 FORMAT "zzz,zz9"
     tot_vlcompdb          AT 85 FORMAT "zzz,zzz,zzz,zzz,zz9.99"
     SKIP
     "A CREDITO:"          AT 61
     tot_qtcompcr          AT 75 FORMAT "zzz,zz9"
     tot_vlcompcr          AT 85 FORMAT "zzz,zzz,zzz,zzz,zz9.99"
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS DOWN WIDTH 132 FRAME f_resumo.

FORM SKIP(2)
     "RESUMO DE SALDO DAS CONTAS:" AT 1
     SKIP(1)
     "CONTA BASE   DATA REF                    SALDO" AT  61
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_labelsld.

FORM ant_nrdctabb AT 61 FORMAT "zzzz,zzz,9"
     ant_dtrefere AT 74 FORMAT "x(10)"
     ant_vldsaldo AT 85 FORMAT "x(24)"
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS DOWN WIDTH 132 FRAME f_saldos.

/*  Busca dados da cooperativa .............................................. */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.

/* .......................................................................... */

IF   glb_nmtelant = "COMPEFORA"   THEN
     ASSIGN aux_dtleiarq = glb_dtmvtoan.    
ELSE
     ASSIGN aux_dtleiarq = glb_dtmvtolt.

CREATE tt-crapcop.
ASSIGN tt-crapcop.cdcooper = glb_cdcooper.

IF  glb_cdcooper = 1 THEN
    DO:
        CREATE tt-crapcop.
        ASSIGN tt-crapcop.cdcooper = 4.  /* Incorporacao Concredi */
    END.
IF  glb_cdcooper = 13 THEN
    DO:
        CREATE tt-crapcop.
        ASSIGN tt-crapcop.cdcooper = 15. /* Incorporacao Credimilsul */
    END.

IF glb_inrestar = 0 THEN
    UNIX SILENT VALUE("rm integra/deb558* 2> /dev/null"). 

/* inicializar variavel de controle se existe algum arquivo a ser processado*/
ASSIGN aux_flgarqui = FALSE.

/*  Le tabela com as codigo do convenio do Banco do Brasil com a Coop.  */
FOR EACH tt-crapcop:
    FIND craptab WHERE craptab.cdcooper = tt-crapcop.cdcooper    AND
                       craptab.nmsistem = "CRED"                     AND
                       craptab.tptabela = "GENERI"                   AND
                       craptab.cdempres = 0                          AND
                       craptab.cdacesso = "COMPEARQBB"               AND
                       craptab.tpregist = 346 NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE craptab   THEN
         DO:
             glb_cdcritic = 55.
             RUN fontes/critic.p.
             UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                 glb_cdprogra + "' --> '" + glb_dscritic +
                                 "(COMPEARQBB) >> log/proc_batch.log").
             RETURN.
         END.
    ELSE
         ASSIGN tt-crapcop.cdconven = INT(SUBSTR(craptab.dstextab,1,9))
                aux_lsconven = IF aux_lsconven = "" THEN 
                                  SUBSTR(craptab.dstextab,1,9)
                               ELSE
                                  aux_lsconven + "," + SUBSTR(craptab.dstextab,1,9).

    IF   glb_inrestar > 0   AND   glb_nrctares = 0   THEN
         glb_inrestar = 0.
    
    IF   glb_inrestar = 0   THEN
         DO:                            
              /*  Concatena os arquivos DEB558 em um unico arquivo  */
              ASSIGN aux_nomedarq = "compbb/deb558*" + 
                                    STRING(aux_dtleiarq,"999999") + "*" +
                                    STRING(tt-crapcop.cdconven,"999999999") + "*".

              INPUT STREAM str_1 
                    THROUGH VALUE( "ls " + aux_nomedarq + " 2> /dev/null") NO-ECHO.
    
              DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
    
                 SET STREAM str_1 aux_nomedarq FORMAT "x(60)" .
              
              END. /*** Fim do DO WHILE TRUE ***/
    
              INPUT STREAM str_1 CLOSE.
        
              /*  Verifica se o arquivo a ser integrado existe em disco  */
              IF  SEARCH (aux_nomedarq)  =  ?  THEN
                  /* senao encontrou verificar o proximi*/
                  NEXT. /* critica 258*/
              ELSE  
                  /* se encontrou marcar flag que encontrou algum arquivo*/
                  ASSIGN aux_flgarqui = TRUE.
              
              UNIX SILENT VALUE ("mv " +  aux_nomedarq +
                                " integra/deb558_346_" +
                                STRING(YEAR(aux_dtleiarq),"9999")       +
                                STRING(MONTH(aux_dtleiarq),"99")        +
                                STRING(DAY(aux_dtleiarq),"99")          + 
                                "_" + STRING(tt-crapcop.cdcooper, "99") + 
                                ".bb 2> /dev/null").
         END.
END.  

/* se nao encontrou nenhum arquivo para processar
   deve abortar o programa */
IF NOT aux_flgarqui THEN
DO:
   glb_cdcritic = 258.
   RUN fontes/critic.p.
   UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
              glb_cdprogra + "' --> '" + glb_dscritic +
              " >> log/proc_batch.log").
   RUN enviar_email.
   RUN fontes/fimprg.p.
   RETURN.
END.

/*  Se a tabela abaixo existir, deve processar os arquivos de deposito  */
FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "GENERI"       AND
                   craptab.cdempres = 0              AND
                   craptab.cdacesso = "COMPECHQBB"   AND
                   craptab.tpregist = 0 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     aux_flgchqbb = FALSE.
ELSE
     aux_flgchqbb = TRUE.

/* .......................................................................... */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "USUARI"       AND
                   craptab.cdempres = 11             AND
                   craptab.cdacesso = "MAIORESCHQ"   AND
                   craptab.tpregist = 1 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     ASSIGN aux_vlmaichq =  1
            aux_vlsldneg = -1.
ELSE
     ASSIGN aux_vlmaichq = DECIMAL(SUBSTRING(craptab.dstextab,01,15))
            aux_vlsldneg = DECIMAL(SUBSTRING(craptab.dstextab,17,16)).

/* Valor dos maiores cheques do BB - 3000,00 - nao usa da tabela pois a 
   tabela eh usada em outros programas */
   
aux_vlmaichq = 3000.00.

/* .......................................................................... */

ASSIGN aux_lsparame = "integra/deb558*.bb"

       aux_dshstchq = "0002,0102,0102,0103,0113,0300,0452," +
                      "0033,0455,0456,0457,0458,0500"

       aux_dshstblq = "0511BL.1D UTIL,0512BL.2D UTIL,0513BL.3D UTIL," +
                      "0514BL.4D UTIL,0515BL.5D UTIL,0516BL.6D UTIL," +
                      "0517BL.7D UTIL,0518BL.8D UTIL,0519BL.9D UTIL," +
                      "0520DEP.BL.IND," +
                      "0911DEP.BL.1D,0912DEP.BL.2D,0913DEP.BL.3D," +
                      "0914DEP.BL.4D,0915DEP.BL.5D,0916DEP.BL.6D," +
                      "0917DEP.BL.7D,0918DEP.BL.8D,0919DEP.BL.9D," +
                      "0920DEP.BL.IND"

       /*  ATENCAO: O historico 623-DEP. COMPE nao sera tratado  */

       aux_dshstdep = "0502DEPOSITO,0505DEP.CHEQUE,0830DEP.ONLINE," +
                      "0870TRF.ONLINE," + aux_dshstblq

       aux_dsestblq = "0411EST.DEP.1D,0412EST.DEP.2D,0413EST.DEP.3D," +
                      "0414EST.DEP.4D,0415EST.DEP.5D,0416EST.DEP.6D," +
                      "0417EST.DEP.7D,0418EST.DEP.8D,0419EST.DEP.9D," +
                      "0420EST.BL.IND"
       /*                              Nao tratar mais o est.credto - Edson 
       aux_dshstest = "0080EST.AUT.RC,0280EST.CREDTO," + aux_dsestblq
       
       aux_dshstest = "0080EST.AUT.RC," + aux_dsestblq     */
       
       aux_dshstest = "NAO TRATA MAIS ESTORNO DE DEPOSITO"   /*  EDSON 04/09 */
               
       aux_dshstcob = "0624COBRANCA"  /* Especifica cobranca */
       
       aux_nrdevias = 1

       glb_cdempres = 11
       glb_nrdevias = 1.

/*  Carrega para uma tabela os arquivos a serem integrados  */

INPUT STREAM str_1 THROUGH VALUE("ls " + aux_lsparame) NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1
       aux_nmarquiv FORMAT "x(40)" WITH NO-BOX NO-LABELS FRAME f_ls.

   IF   aux_nmarquiv = aux_lsparame   THEN
        LEAVE.
   
   UNIX SILENT VALUE("quoter " + aux_nmarquiv + " > " + aux_nmarquiv +
                     ".q 2> /dev/null").
                        
   INPUT STREAM str_2 FROM VALUE(aux_nmarquiv + ".q") NO-ECHO.

   SET STREAM str_2 aux_dsdlinha WITH WIDTH 212.
   
   IF   NOT CAN-DO(aux_lsconven, SUBSTRING(aux_dsdlinha,38,09)) THEN
        DO:
             INPUT STREAM str_2 CLOSE.
             UNIX SILENT VALUE("rm " + aux_nmarquiv + ".q 2> /dev/null").
             NEXT.
        END.

   ASSIGN aux_regexist = TRUE
          aux_contaarq = aux_contaarq + 1
          aux_nmarqint[INT(SUBSTRING(aux_nmarquiv, 29, 2))] = aux_nmarquiv.
         
END.  /*  Fim do DO WHILE TRUE  --  Carga dos arquivos a serem integrados  */

INPUT STREAM str_1 CLOSE.

IF   NOT aux_regexist   THEN
     DO:
         glb_cdcritic = 258.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                            glb_cdprogra + "' --> '" + glb_dscritic +
                            " >> log/proc_batch.log").
         RUN enviar_email.
         RUN fontes/fimprg.p.
         RETURN.
     END.


/*   Verificar o valor VLB */
                  
FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "GENERI"       AND
                   craptab.cdempres = 0              AND
                   craptab.cdacesso = "VALORESVLB"   AND
                   craptab.tpregist = 0
                   NO-LOCK NO-ERROR.
                                 
IF   AVAILABLE craptab   THEN
     aux_vlchqvlb = DEC(ENTRY(2,craptab.dstextab,";")).
ELSE 
     aux_vlchqvlb = 0.



FOR EACH tt-crapcop:    /*  Arquivos a integrar  */

   /*  Le tabela com as contas convenio do Banco do Brasil - Geral ............. */
   RUN fontes/ver_ctace.p(INPUT tt-crapcop.cdcooper,
                          INPUT 0,
                          OUTPUT aux_lscontas).

   /*  Le tabela com as contas convenio do Banco do Brasil - talao normal ...... */
   RUN fontes/ver_ctace.p(INPUT tt-crapcop.cdcooper,
                          INPUT 1,
                          OUTPUT aux_lsconta1).

   /*  Le tabela com as contas convenio do Banco do Brasil - talao transf ...... */
   RUN fontes/ver_ctace.p(INPUT tt-crapcop.cdcooper,
                          INPUT 2,
                          OUTPUT aux_lsconta2).

   /*  Le tabela com as contas convenio do Banco do Brasil - chq.salario ....... */
   RUN fontes/ver_ctace.p(INPUT tt-crapcop.cdcooper,
                          INPUT 3,
                          OUTPUT aux_lsconta3).

    
   IF   aux_nmarqint[tt-crapcop.cdcooper] = ""   THEN
        NEXT.   

   ASSIGN glb_cdcritic = 0
          aux_nrdolote = 0

          aux_flgarqvz = TRUE
          aux_flgfirst = TRUE
          aux_flgentra = TRUE
          aux_flgretor = FALSE

          aux_nmarqimp[tt-crapcop.cdcooper] = "crrl291_" +
                                       STRING(tt-crapcop.cdcooper,"99") + ".lst".

   { includes/cabrel132_1.i }               /* Monta cabecalho do relatorio */

   /*  Verifica se o arquivo a ser integrado existe em disco  */

   IF   SEARCH(aux_nmarqint[tt-crapcop.cdcooper]) = ?   THEN
        DO:
            glb_cdcritic = 182.
            RUN fontes/critic.p.
            UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" +
                               glb_dscritic + "' --> '" +
                               aux_nmarqint[tt-crapcop.cdcooper] +
                               " >> log/proc_batch.log").
            RETURN.
        END.

   IF   glb_inrestar = 0   THEN
        DO TRANSACTION ON ERROR UNDO, RETURN:

           FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                  craptab.nmsistem = "CRED"       AND
                                  craptab.tptabela = "COMPBB"     AND
                                  craptab.cdempres = 0 EXCLUSIVE-LOCK:

               DELETE craptab.

           END.  /*  Fim do FOR EACH  */

           EMPTY TEMP-TABLE crawdpb.

           glb_cdcritic = 219.

           RUN fontes/critic.p.
           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                             glb_cdprogra + "' --> '" +
                             glb_dscritic + "' --> '" +
                             aux_nmarqint[tt-crapcop.cdcooper] +
                             " >> log/proc_batch.log").

        END.  /*  Fim da transacao  */

   INPUT STREAM str_2 FROM VALUE(aux_nmarqint[tt-crapcop.cdcooper] + ".q") NO-ECHO.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE ON ERROR UNDO, RETURN:

      IF   glb_inrestar <> 0   THEN
           DO:
               DO WHILE aux_nrseqint <> glb_nrctares:

                  IF   aux_flgretor   THEN
                       LEAVE.
                       
                  SET STREAM str_2 aux_dsdlinha WITH WIDTH 212.
              
                  aux_nrseqint = INT(SUBSTRING(aux_dsdlinha,195,6)).

                  IF   SUBSTRING(aux_dsdlinha,1,1) = "1"   THEN
                       DO:
                           IF   crapcop.cdcooper = 3   THEN
                                IF   SUBSTRING(aux_dsdlinha,37,5) = "5027X" THEN
                                     NEXT.
      
                           IF   SUBSTRING(aux_dsdlinha,41,01) = "X" THEN
                                aux_nrdctabb = 
                                   INT(STRING(SUBSTRING(aux_dsdlinha,33,08)) +
                                     "0").
                           ELSE     
                                aux_nrdctabb =
                                   INT(SUBSTRING(aux_dsdlinha,33,09)).
                           
                           RUN saldos.
                       END.
                       
               END.  /*  Fim do DO WHILE  */
           
               aux_flgretor = TRUE.
               
               UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                 " - " + glb_cdprogra + "' --> '" +
                                 "Posicionando-se no registro " +
                                 TRIM(STRING(glb_nrctares,"zzz,zz9")) + "." +
                                 " >> log/proc_batch.log").
           END.
           
      SET STREAM str_2 aux_dsdlinha WITH WIDTH 212.
      
      IF   SUBSTRING(aux_dsdlinha,1,1) <> "1"   THEN
           NEXT.

      /*  Conta da CECRED cancelada que ainda vem no arquivo  */
      
      IF   crapcop.cdcooper = 3   THEN
           IF   SUBSTRING(aux_dsdlinha,37,5) = "5027X"   THEN
                NEXT.
      
      IF   SUBSTRING(aux_dsdlinha,41,01) = "X" THEN
           aux_nrdctabb = INT(STRING(SUBSTRING(aux_dsdlinha,33,08)) + "0").
      ELSE     
           aux_nrdctabb = INT(SUBSTRING(aux_dsdlinha,33,09)).

      RUN saldos.                            

      IF   NOT CAN-DO(aux_lscontas,STRING(aux_nrdctabb))   THEN
           NEXT.

      aux_flgarqvz = FALSE.
     
      IF   SUBSTRING(aux_dsdlinha,42,1) <> "1"   THEN
           NEXT.
           
      ASSIGN aux_nrseqint = INT(SUBSTRING(aux_dsdlinha,195,6))
             aux_dshistor = TRIM(SUBSTRING(aux_dsdlinha,46,29))
             aux_nrdocmto = INT(SUBSTRING(aux_dsdlinha,75,6)) * 10
             aux_vllanmto = DECIMAL(SUBSTRING(aux_dsdlinha,87,18)) / 100

             aux_dtmvtolt = DATE(INT(SUBSTRING(aux_dsdlinha,184,2)),
                                 INT(SUBSTRING(aux_dsdlinha,182,2)),
                                 INT(SUBSTRING(aux_dsdlinha,186,4)))
             
             aux_indebcre = IF INT(SUBSTRING(aux_dsdlinha,43,3)) > 100   AND
                               INT(SUBSTRING(aux_dsdlinha,43,3)) < 200
                               THEN "D"
                               ELSE "C"
                    
             aux_cdpesqbb = SUBSTRING(aux_dsdlinha,111,5) + "-000-" +
                            SUBSTRING(aux_dsdlinha,120,3)
                                   
             aux_dsageori = SUBSTRING(aux_dsdlinha,116,4) + ".00"
             
             aux_dtrefere = 
                 IF INT(SUBSTRING(aux_dsdlinha,174,8)) > 0
                    THEN STRING(DATE(INT(SUBSTRING(aux_dsdlinha,176,2)),
                                     INT(SUBSTRING(aux_dsdlinha,174,2)),
                                     INT(SUBSTRING(aux_dsdlinha,178,4))),
                                     "99.99.9999")
                    ELSE "".

      
      /*  Calcula do digito verificador do numero do documento .............. */

      glb_nrcalcul = aux_nrdocmto.
      
      RUN fontes/digfun.p.
      
      aux_nrdocmto = glb_nrcalcul.

      /* .................................................................... */
      
      IF   glb_nmtelant = "COMPEFORA"   THEN
           DO:
               IF   aux_dtmvtolt <> glb_dtmvtoan   THEN
                    NEXT.
           END.
      ELSE
          IF   aux_dtmvtolt <> glb_dtmvtolt   THEN
                NEXT.
      
      IF   aux_flgfirst   THEN
           DO:
               /*  Le numero de lote a ser usado na integracao  */

               FIND craptab WHERE craptab.cdcooper = glb_cdcooper       AND
                                  craptab.nmsistem = "CRED"             AND
                                  craptab.tptabela = "GENERI"           AND
                                  craptab.cdempres = 0                  AND
                                  craptab.cdacesso = "NUMLOTECBB"       AND
                                  craptab.tpregist = 1
                                  USE-INDEX craptab1 NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE craptab   THEN

                    DO:
                        glb_cdcritic = 259.
                        RUN fontes/critic.p.
                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - " + glb_cdprogra + "' --> '" +
                                          glb_dscritic +
                                          " >> log/proc_batch.log").
                        RETURN.
                    END.
               ELSE
                    aux_nrdolote = INTEGER(craptab.dstextab).

               IF   glb_inrestar = 0   THEN
                    aux_flgclote = TRUE.

               aux_flgfirst = FALSE.
           END.

      ASSIGN glb_cdcritic = 0
             aux_nrdconta = 0
             aux_indevchq = 0
             aux_flgcontr = FALSE.

      IF   CAN-DO(aux_dshstdep,aux_dshistor)   THEN             /*  Deposito  */
           ASSIGN aux_flgdepos = TRUE
                  aux_flgchequ = FALSE
                  aux_flgestor = FALSE.
      ELSE
      IF   CAN-DO(aux_dshstchq,SUBSTR(aux_dshistor,1,4)) THEN    /*  Cheque  */
           ASSIGN aux_flgdepos = FALSE
                  aux_flgchequ = TRUE
                  aux_flgestor = FALSE.
      ELSE
      IF   CAN-DO(aux_dshstest,aux_dshistor)   THEN               /* Estorno */
           ASSIGN aux_flgdepos = FALSE
                  aux_flgchequ = FALSE
                  aux_flgestor = TRUE.
      ELSE
           ASSIGN glb_cdcritic = 245                              /*  Outros  */
                  aux_flgdepos = FALSE
                  aux_flgchequ = TRUE
                  aux_flgestor = FALSE.

      ASSIGN aux_cobranca = NO.        /* Verifica se movto cobranca 0624 */
      IF  glb_cdcritic = 245 THEN 
          DO:
            IF  CAN-DO(aux_dshstcob,aux_dshistor) THEN /* 0624COBRANCA */
                ASSIGN aux_cobranca = YES.
          END.

      IF   glb_cdcritic = 0   THEN
           IF   aux_nrdocmto = 0   THEN
                glb_cdcritic = 22.
           ELSE
                DO:
                    glb_nrcalcul = aux_nrdocmto.
                    RUN fontes/digfun.p.

                    IF   aux_flgdepos OR aux_flgestor   THEN
                         IF   CAN-DO(aux_lsagenci,STRING(glb_nrcalcul))   THEN
                              glb_cdcritic = 577.
                         ELSE
                              aux_nrdconta = INTEGER(glb_nrcalcul).
                    ELSE
                    IF   NOT glb_stsnrcal   THEN
                         glb_cdcritic = 8.

                    IF   aux_vllanmto = 0   THEN
                         glb_cdcritic = 91.
                END.

      IF   glb_cdcritic = 0 AND aux_flgchequ   THEN
           DO:
             RUN fontes/digbbx.p (INPUT  aux_nrdctabb,
                                  OUTPUT glb_dsdctitg,
                                  OUTPUT glb_stsnrcal).
                                  
             ASSIGN aux_dsdctitg = glb_dsdctitg
                    aux_nrdocmt2 = INT(SUBSTR(STRING(
                                              aux_nrdocmto,"9999999"),1,6)).

             IF   CAN-DO(aux_lsconta3,STRING(aux_nrdctabb)) THEN  /*  CHQ SAL */
                  DO:
                      FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper     AND
                                         crapfdc.cdbanchq = 1                AND
                                         crapfdc.cdagechq = crapcop.cdageitg AND
                                         crapfdc.nrctachq = aux_nrdctabb     AND
                                         crapfdc.nrcheque = aux_nrdocmt2
                                         USE-INDEX crapfdc1 NO-LOCK NO-ERROR.

                      IF   NOT AVAILABLE crapfdc   THEN
                           glb_cdcritic = 286.
                      ELSE
                           DO:
                              aux_nrdconta = crapfdc.nrdconta.

                              IF   crapfdc.nrdconta = 0   THEN
                                   glb_cdcritic = 286.
                              ELSE
                              IF   CAN-DO("5,6,7",STRING(crapfdc.incheque)) THEN
                                  glb_cdcritic = 97.
                              ELSE
                              IF   crapfdc.incheque = 1   THEN
                                   aux_flgcontr = TRUE.    /*  critica 96  */
                              ELSE
                              IF   crapfdc.incheque = 8   THEN
                                   glb_cdcritic = 320.
                              ELSE
                              IF   crapfdc.vlcheque <> aux_vllanmto   THEN
                                   glb_cdcritic = 269.
                           END.
                  END.
             ELSE
             IF   CAN-DO(aux_lsconta2,STRING(aux_nrdctabb))   THEN   /* TRF  */
                  DO:
                      FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper     AND
                                         crapfdc.cdbanchq = 1                AND
                                         crapfdc.cdagechq = crapcop.cdageitg AND
                                         crapfdc.nrctachq = aux_nrdctabb     AND
                                         crapfdc.nrcheque = aux_nrdocmt2
                                         USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
                    
                      IF   NOT AVAILABLE crapfdc   THEN
                           glb_cdcritic = 108.
                      ELSE
                           DO:
                              aux_nrdconta = crapfdc.nrdconta.

                              IF   crapfdc.dtemschq = ?   THEN
                                   glb_cdcritic = 108.
                              ELSE
                              IF   crapfdc.dtretchq = ?   THEN
                                   glb_cdcritic = 109.
                              ELSE
                              IF   CAN-DO("5,6,7",STRING(crapfdc.incheque)) THEN
                                   glb_cdcritic = 97.
                              ELSE
                              IF   crapfdc.incheque = 8   THEN
                                   glb_cdcritic = 320.
                           /* ELSE
                              IF   crapfdc.incheque = 1   THEN
                                   glb_cdcritic = 96. */

                           END.
                  END.
             ELSE
                  DO:                                    /*  Contas Normais  */
                      FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper     AND
                                         crapfdc.cdbanchq = 1                AND
                                         crapfdc.cdagechq = crapcop.cdageitg AND
                                         crapfdc.nrctachq = aux_nrdctabb     AND
                                         crapfdc.nrcheque = aux_nrdocmt2
                                         USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
                    
                      IF   NOT AVAILABLE crapfdc   THEN
                           glb_cdcritic = 108.
                      ELSE
                           DO:
                              aux_nrdconta = crapfdc.nrdconta.

                              IF   crapfdc.dtemschq = ?   THEN
                                   glb_cdcritic = 108.
                              ELSE
                              IF   crapfdc.dtretchq = ?   THEN
                                   glb_cdcritic = 109.
                              ELSE
                              IF   CAN-DO("5,6,7",STRING(crapfdc.incheque)) THEN
                                   glb_cdcritic = 97.
                              ELSE
                              IF   crapfdc.incheque = 8   THEN
                                   glb_cdcritic = 320.
                           /* ELSE
                              IF   crapfdc.incheque = 1   THEN
                                   glb_cdcritic = 96. */

                           END.
                  END.
           END.
           
      IF   glb_cdcritic = 0   THEN
           DO:
               FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                  crapass.nrdconta = aux_nrdconta
                                  USE-INDEX crapass1 NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE crapass   THEN
                    glb_cdcritic = 9.
               ELSE
               IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
                    glb_cdcritic = 695.
               ELSE
               IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN
                    glb_cdcritic = 95.
               ELSE
               IF   crapass.dtelimin <> ?   THEN
                    glb_cdcritic = 410.
           END.
      
      TRANS_1:

      DO TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

         FIND CURRENT craptab EXCLUSIVE-LOCK NO-ERROR.
         FIND CURRENT crapfdc EXCLUSIVE-LOCK NO-ERROR.

         IF   aux_flgclote   THEN
              DO:
                  aux_nrdolote = aux_nrdolote + 1.

                  IF   CAN-FIND(craplot WHERE 
                                craplot.cdcooper = glb_cdcooper   AND
                                craplot.dtmvtolt = glb_dtmvtolt   AND
                                craplot.cdagenci = aux_cdagenci   AND
                                craplot.cdbccxlt = aux_cdbccxlt   AND
                                craplot.nrdolote = aux_nrdolote
                                USE-INDEX craplot1)   THEN
                       DO:
                           glb_cdcritic = 59.
                           RUN fontes/critic.p.
                           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                             " - " + glb_cdprogra + "' --> '" +
                                             glb_dscritic +
                                             " COMPBB - LOTE = " +
                                             STRING(aux_nrdolote,"999,999") +
                                             " >> log/proc_batch.log").

                           UNDO TRANS_1, RETURN.
                       END.

                  CREATE craplot.
                  ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                         craplot.cdagenci = aux_cdagenci
                         craplot.cdbccxlt = aux_cdbccxlt
                         craplot.nrdolote = aux_nrdolote
                         craplot.tplotmov = 1
                         craptab.dstextab = STRING(aux_nrdolote,"9999")
                         aux_flgclote     = FALSE
                         craplot.cdcooper = glb_cdcooper.
                  VALIDATE craplot.
              END.
         ELSE
              DO:
                  FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                                     craplot.dtmvtolt = glb_dtmvtolt   AND
                                     craplot.cdagenci = aux_cdagenci   AND
                                     craplot.cdbccxlt = aux_cdbccxlt   AND
                                     craplot.nrdolote = aux_nrdolote
                                     USE-INDEX craplot1 EXCLUSIVE-LOCK NO-ERROR.

                  IF   NOT AVAILABLE craplot   THEN
                       DO:
                           glb_cdcritic = 60.
                           RUN fontes/critic.p.
                           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                             " - " + glb_cdprogra + "' --> '" +
                                             glb_dscritic +
                                             " COMPBB - LOTE = " +
                                             STRING(aux_nrdolote,"999,999") +
                                             " >> log/proc_batch.log").

                           UNDO TRANS_1, RETURN.
                       END.
              END.

         DO WHILE glb_cdcritic = 0   AND   aux_flgchequ:

            IF   CAN-FIND(craplcm WHERE craplcm.cdcooper = glb_cdcooper   AND
                                        craplcm.dtmvtolt = glb_dtmvtolt   AND
                                        craplcm.cdagenci = aux_cdagenci   AND
                                        craplcm.cdbccxlt = aux_cdbccxlt   AND
                                        craplcm.nrdolote = aux_nrdolote   AND
                                        craplcm.nrdctabb = aux_nrdctabb   AND
                                        craplcm.nrdocmto = aux_nrdocmto
                                        USE-INDEX craplcm1)   THEN
                 DO:
                     glb_cdcritic = 92.
                     LEAVE.
                 END.

            IF   CAN-DO(aux_lsconta3,STRING(aux_nrdctabb))   THEN
                 DO:
                     IF   crapfdc.incheque = 2   THEN
                          glb_cdcritic = 287.
                 END.
            ELSE
            IF   CAN-DO(aux_lsconta2,STRING(aux_nrdctabb))   THEN
                 DO:
                     IF   crapfdc.incheque = 2   THEN
                          glb_cdcritic = 257.
                     ELSE
                          IF   crapfdc.incheque = 1 THEN
                               ASSIGN glb_cdcritic = 096
                                      aux_indevchq = 3.
                 END.
            ELSE
                 IF   crapfdc.incheque = 2   THEN
                      glb_cdcritic = 257.
                 ELSE
                      IF   crapfdc.incheque = 1 THEN
                           DO:
                               FIND LAST craplcm WHERE
                                         craplcm.cdcooper = glb_cdcooper   AND
                                         craplcm.nrdconta = aux_nrdconta   AND
                                         craplcm.nrdocmto = aux_nrdocmto   AND
                                        (craplcm.cdhistor = 21 OR
                                         craplcm.cdhistor = 50)
                                         USE-INDEX craplcm2 NO-LOCK NO-ERROR.

                               IF   NOT AVAILABLE craplcm   THEN
                                    ASSIGN glb_cdcritic = 96
                                           aux_indevchq = 1
                                           aux_cdalinea = 0.
                               ELSE
                                    DO:
                                        FIND crapcor WHERE
                                         crapcor.cdcooper = glb_cdcooper     AND
                                         crapcor.cdbanchq = 1                AND
                                         crapcor.cdagechq = crapcop.cdageitg AND
                                         crapcor.nrctachq = aux_nrdctabb     AND
                                         crapcor.nrcheque = aux_nrdocmto     AND
                                         crapcor.flgativo = TRUE
                                         NO-LOCK NO-ERROR.

                                        IF   NOT AVAILABLE crapcor   THEN
                                             DO:
                                                 ASSIGN glb_cdcritic = 439
                                                        aux_indevchq = 1
                                                        aux_cdalinea = 49.
                                             END.
                                        ELSE
                                        IF   crapcor.dtvalcor >= 
                                                 glb_dtmvtolt THEN
                                             ASSIGN glb_cdcritic = 96
                                                    aux_indevchq = 
                                                     IF  crapfdc.tpcheque = 1 
                                                         THEN 1
                                                         ELSE 3
                                                    aux_cdalinea = 70.
                                        ELSE
         /*  Edson - 15/10/2003  */     IF   crapcor.dtemscor >    /*  =  */
                                             craplcm.dtmvtolt   THEN
                                             ASSIGN glb_cdcritic = 96
                                                    aux_indevchq = 1
                                                    aux_cdalinea = 0.
                                        ELSE
                                             ASSIGN glb_cdcritic = 439
                                                    aux_indevchq = 1
                                                    aux_cdalinea = 43.
                                    END.
                           END.

            LEAVE.

         END.  /*  Fim do DO WHILE  */

         /*  Monta a data de liberacao para depositos bloqueados  */

         IF   glb_cdcritic = 0   AND   aux_flgdepos   THEN
              DO:
                  IF   CAN-DO(aux_dshstblq,aux_dshistor)   THEN    /*  Bloq.  */
                       DO:
                           aux_nrdiautl = 0.

                           DO aux_contador = 1 TO LENGTH(aux_dshistor):

                              aux_nrdiautl = R-INDEX(aux_dshistor,
                                                  STRING(aux_contador) + "D").

                              IF   aux_nrdiautl > 0   THEN
                                   DO:
                                       aux_nrdiautl = aux_contador.
                                       LEAVE.
                                   END.

                           END.  /*  Fim do DO .. TO  */

                           IF   aux_nrdiautl = 0   THEN
                                glb_cdcritic = 245.
                           ELSE
                           IF   aux_nrdiautl = 1   THEN
                                ASSIGN aux_dtliblan = glb_dtmvtopr
                                       aux_cdhistor = 170.
                           ELSE
                                DO:

                                    ASSIGN aux_cdhistor = 170
                                           aux_dtliblan = glb_dtmvtopr.

                                    DO WHILE aux_nrdiautl > 1:

                                       aux_dtliblan = aux_dtliblan + 1.

                                       IF   CAN-DO("1,7",
                                            STRING(WEEKDAY(aux_dtliblan)))   OR
                                            CAN-FIND(crapfer WHERE
                                             crapfer.cdcooper = glb_cdcooper AND
                                             crapfer.dtferiad = aux_dtliblan)
                                            THEN NEXT.

                                       aux_nrdiautl = aux_nrdiautl - 1.

                                    END.  /*  Fim do DO WHILE  */
                                END.
                       END.
                  ELSE
                       ASSIGN aux_cdhistor = 169
                              aux_dtliblan = ?.

                  IF  glb_cdcritic = 0   THEN
                      glb_cdcritic = 762.
              END.

         IF   glb_cdcritic = 0   AND   aux_flgestor  THEN
              ASSIGN glb_cdcritic = 608
                     
                     /* Testa se estorno normal ou bloqueado */

                     aux_cdhistor = IF   CAN-DO(aux_dsestblq,aux_dshistor) 
                                         THEN 297     /* Est. Bloq */
                                         ELSE 290.    /* Normal */
                                         
         IF   glb_cdcritic > 0   OR   aux_flgcontr   THEN
              DO:
                  IF   aux_flgcontr   THEN
                       glb_cdcritic = 96.

                  IF   aux_cobranca = YES THEN
                       glb_cdcritic = 784. /* Processado via Cobranca */
                       
                  CREATE craprej.
                  ASSIGN craprej.dtmvtolt = craplot.dtmvtolt
                         craprej.cdagenci = craplot.cdagenci
                         craprej.cdbccxlt = craplot.cdbccxlt
                         craprej.nrdolote = craplot.nrdolote
                         craprej.tplotmov = craplot.tplotmov
                         craprej.nrdconta = aux_nrdconta
                         craprej.nrdctabb = aux_nrdctabb
                         craprej.nrdctitg = glb_dsdctitg
                         craprej.dshistor = STRING(aux_dshistor,"x(15)") +
                                            aux_dsageori
                         craprej.cdpesqbb = aux_cdpesqbb
                         craprej.nrseqdig = aux_nrseqint
                         craprej.nrdocmto = IF (glb_cdcritic = 762 OR
                                                glb_cdcritic = 608)
                                               THEN aux_nrseqint
                                               ELSE aux_nrdocmto
                         craprej.vllanmto = aux_vllanmto
                         craprej.indebcre = aux_indebcre
                         craprej.dtrefere = aux_dtrefere
                         craprej.cdcritic = glb_cdcritic
                         
                         craprej.dtdaviso = 
                                 IF TRIM(aux_dtrefere) <> ""
                                    THEN DATE(INT(SUBSTR(aux_dtrefere,4,2)),
                                              INT(SUBSTR(aux_dtrefere,1,2)),
                                              INT(SUBSTR(aux_dtrefere,7,4)))
                                    ELSE glb_dtmvtolt
                         
                         craprej.tpintegr = 1
                         craprej.cdcooper = glb_cdcooper.

                  VALIDATE craprej.

                  IF  CAN-DO("96,137,172,257,287,439,608",
                              STRING(glb_cdcritic)) THEN
                       IF   glb_cdcritic = 96   AND   
                            CAN-DO(aux_lsconta3,STRING(aux_nrdctabb))   THEN
                            ASSIGN glb_cdcritic = 0
                                   aux_flgentra = FALSE.
                       ELSE
                            ASSIGN glb_cdcritic = 0
                                   aux_flgentra = TRUE.
                  ELSE
                       ASSIGN glb_cdcritic = 0
                              aux_flgentra = FALSE.
              END.
         ELSE
         DO:
            /*  Critica quando o valor do lancamento for maior que o 
                param 2 do VALORESVLB */
         
             IF   aux_vllanmto >= aux_vlchqvlb THEN
                  DO:
                      CREATE craprej.
                      ASSIGN craprej.cdcooper = glb_cdcooper
                             craprej.dtmvtolt = glb_dtmvtolt
                             craprej.cdagenci = aux_cdagenci
                             craprej.cdbccxlt = aux_cdbccxlt
                             craprej.nrdolote = aux_nrdolote
                             craprej.tpintegr = 1
                             craprej.dtrefere = aux_dtrefere
                             craprej.nrdconta = aux_nrdconta
                             craprej.nrdctabb = aux_nrdctabb
                             craprej.nrdocmto = aux_nrdocmto 
                             craprej.vllanmto = aux_vllanmto
                             craprej.nrseqdig = aux_nrseqint
                             craprej.cdcritic = 929
                             craprej.cdpesqbb = aux_cdpesqbb
                             craprej.indebcre = aux_indebcre
                             craprej.dshistor = STRING(aux_dshistor,"x(15)") +
                                                aux_dsageori.
                      
                      VALIDATE craprej.

                      /* envia email informando sobre o cheque vlb */
                      RUN sistema/generico/procedures/b1wgen0011.p 
                               PERSISTENT SET h-b1wgen0011.

                      IF   NOT VALID-HANDLE(h-b1wgen0011) THEN
                           DO:
                               UNIX SILENT VALUE(
                                        "echo " + STRING(TIME,"HH:MM:SS")
                                        + " - " + glb_cdprogra + "' --> '" +
                                        "Handle invalido para h-b1wgen0011."
                                        + " >> log/proc_batch.log").
                           END.
                      ELSE
                           DO:
                               ASSIGN aux_conteudo = 
                                 "Segue dados do Cheque VLB:\n\n" +
                                 "Cooperativa: " + STRING(glb_cdcooper) +
                                 " - " + crapcop.nmrescop +
                                 "\nPA: " + TRIM(STRING(crapass.cdagenci)) +
                                 "\nBanco: " + 
                                 TRIM(STRING(aux_cdbccxlt, "zz9")) + "\n" +
                                 "Conta/dv: " + 
                                 TRIM(STRING(aux_nrdconta, "zzzz,zzz,9")) + 
                                 "\n" +
                                 "Cheque: " + 
                                 TRIM(STRING(aux_nrdocmto, "zzz,zz9,9")) +
                                 "\n" +
                                 "Valor: R$ " + 
                                 TRIM(STRING(aux_vllanmto, "zzz,zzz,zz9.99")) +
                                 "\n" +
                                 "Data: " + STRING(aux_dtleiarq, "99/99/9999").


                               RUN enviar_email_completo IN h-b1wgen0011 
                                      (glb_cdcooper,
                                       "crps346",
                                       "CECRED<cecred@cecred.coop.br>",
                                       "spb@cecred.coop.br," +
                                       "compe@cecred.coop.br", 
                                      ("Cheque VLB " +
                                       STRING(aux_cdbccxlt, "999") + " - " + 
                                       STRING(aux_dtleiarq, "99/99/9999")),
                                       "",
                                       "",
                                       aux_conteudo,
                                       TRUE).

                               DELETE PROCEDURE h-b1wgen0011.
                           END.    
                  END.  
         END.

         IF   aux_flgchequ THEN
              DO:
                  FOR EACH crapneg WHERE crapneg.cdcooper = glb_cdcooper AND
                                         crapneg.nrdconta = aux_nrdconta AND
                                         crapneg.nrdocmto = aux_nrdocmto AND
                                         crapneg.cdhisest = 1 NO-LOCK
                                         USE-INDEX crapneg1
                                         BY crapneg.nrseqdig DESCENDING: 
    
                      IF   CAN-DO("12,13", STRING(crapneg.cdobserv)) AND
                           crapneg.dtfimest = ?                      THEN
                           DO:
                                ASSIGN aux_indevchq = IF   crapfdc.tpcheque = 1
                                                           THEN 1
                                                           ELSE 3
                                       aux_cdalinea = 49
                                       aux_flgentra = TRUE.
                            
                                LEAVE.
                           END.
                  END.
              END.

         IF   aux_flgentra    AND    aux_flgchequ   THEN
              DO:
                  CREATE craplcm.
                  ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                         craplcm.dtrefere = aux_dtleiarq
                         craplcm.cdagenci = craplot.cdagenci
                         craplcm.cdbccxlt = craplot.cdbccxlt
                         craplcm.nrdolote = craplot.nrdolote
                         craplcm.nrdconta = aux_nrdconta
                         craplcm.nrdctabb = aux_nrdctabb
                         craplcm.nrdctitg = aux_dsdctitg
                         craplcm.nrdocmto = aux_nrdocmto
                         craplcm.cdcooper = glb_cdcooper
                         craplcm.cdhistor = 
                           IF CAN-DO(aux_lsconta3,STRING(aux_nrdctabb))
                              THEN 56
                              ELSE IF CAN-DO(aux_lsconta2,STRING(aux_nrdctabb))
                                      THEN 59
                                      ELSE 50
                         craplcm.vllanmto = aux_vllanmto
                         craplcm.nrseqdig = aux_nrseqint
                         craplcm.cdpesqbb = aux_cdpesqbb
                         craplcm.cdbanchq = crapfdc.cdbanchq
                         craplcm.cdagechq = crapfdc.cdagechq
                         craplcm.nrctachq = crapfdc.nrctachq
                         
                         craplot.qtinfoln = craplot.qtinfoln + 1
                         craplot.qtcompln = craplot.qtcompln + 1
                         craplot.vlinfodb = craplot.vlinfodb + aux_vllanmto
                         craplot.vlcompdb = craplot.vlcompdb + aux_vllanmto
                         craplot.nrseqdig = craplcm.nrseqdig

                         crapfdc.incheque = crapfdc.incheque + 5

                         crapfdc.vlcheque = aux_vllanmto
                         crapfdc.dtliqchq = glb_dtmvtolt
                         crapfdc.cdagedep = INTE(SUBSTR(aux_dsdlinha,116,4)).
                  
                  VALIDATE craplcm.

                  /* Se for devolucao de cheque verifica o indicador de
                     historico da contra-ordem. Se for 2, alimenta aux_cdalinea
                     com 28 para nao gerar taxa de devolucao */

                  IF   (aux_indevchq = 1 OR aux_indevchq = 3)   AND
                       (aux_cdalinea = 0)                       THEN
                       DO:
                           FIND crapcor WHERE
                                        crapcor.cdcooper = glb_cdcooper     AND
                                        crapcor.cdbanchq = 1                AND
                                        crapcor.cdagechq = crapcop.cdageitg AND
                                        crapcor.nrctachq = aux_nrdctabb     AND
                                        crapcor.nrcheque = aux_nrdocmto     AND
                                        crapcor.flgativo = TRUE
                                        NO-LOCK NO-ERROR.

                           IF   NOT AVAILABLE crapcor   THEN
                                DO:
                                    glb_cdcritic = 179.
                                    RUN fontes/critic.p.
                                    UNIX SILENT VALUE("echo " +
                                         STRING(TIME,"HH:MM:SS") +
                                         " - " + glb_cdprogra + "' --> '" +
                                         glb_dscritic + STRING(aux_nrdconta,
                                         "zzzz,zzz,9") + " Docmto = " +
                                         STRING(aux_nrdocmto,"zzz,zzz,9") +
                                         " Cta Base = " +
                                         STRING(aux_nrdctabb,"zzzz,zzz,9") +
                                         " >> log/proc_batch.log").
                                         UNDO TRANS_1, RETURN.
                                END.
                           ELSE
                                /* Contra Ordem Provisoria */
                                IF   crapcor.dtvalcor >= glb_dtmvtolt AND
                                     crapcor.dtvalcor <> ? THEN 
                                     ASSIGN aux_cdalinea = 70. 
                                ELSE
                                IF   crapcor.cdhistor = 835 THEN
                                     ASSIGN aux_cdalinea = 28.
                                ELSE
                                IF   crapcor.cdhistor = 815 THEN
                                     ASSIGN aux_cdalinea = 21.
                                ELSE
                                IF   crapcor.cdhistor = 818 THEN
                                     ASSIGN aux_cdalinea = 20.
                                ELSE
                                     aux_cdalinea = 21.
                       END.

                  IF   aux_indevchq > 0 THEN
                       DO:
                           RUN fontes/geradev.p (INPUT  glb_cdcooper,
                                                 INPUT  glb_dtmvtolt,
                                                 INPUT  1, /* banco brasil */
                                                 INPUT  aux_indevchq,
                                                 INPUT  aux_nrdconta,
                                                 INPUT  aux_nrdocmto,
                                                 INPUT  aux_dsdctitg,
                                                 INPUT  aux_vllanmto,
                                                 INPUT  aux_cdalinea,
                                                 INPUT  IF aux_indevchq = 1
                                                        THEN 191          
                                                        ELSE  78, /* HST */
                                                 INPUT  "1", /* operador */ 
                                                 INPUT  crapcop.cdageitg,
                                                 INPUT  aux_nrdctabb,
                                                 INPUT  "crps346",
                                                 OUTPUT glb_cdcritic,
                                                 OUTPUT glb_dscritic).

                           IF   glb_cdcritic > 0   OR
                                glb_dscritic <> "" THEN
                                DO:
                                    IF glb_dscritic = "" THEN
                                    RUN fontes/critic.p.

                                    UNIX SILENT VALUE
                                         ("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - " + glb_cdprogra + "' --> '" +
                                          glb_dscritic + "CONTA " +
                                          STRING(aux_nrdconta) + " DOCMTO " +
                                          STRING(aux_nrdocmto) + " CTA BASE " +
                                          STRING(aux_nrdctabb) +
                                          " >> log/proc_batch.log").
                                    UNDO TRANS_1, RETURN.
                                END.
                       END.

                  FIND craphis OF craplcm NO-LOCK NO-ERROR.

                  IF   NOT AVAILABLE craphis   THEN
                       DO:
                           glb_cdcritic = 80.
                           RUN fontes/critic.p.
                           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                             " - " + glb_cdprogra + "' --> '" +
                                             glb_dscritic + "HST = " +
                                             STRING(craplcm.cdhistor,"9999") +
                                             " >> log/proc_batch.log").
                           UNDO TRANS_1, RETURN.
                       END.

                  IF   craphis.indebcre = "D"   THEN             /*  Debitos  */
                       DO WHILE TRUE:

                          FIND craptab WHERE
                               craptab.cdcooper = glb_cdcooper           AND
                               craptab.nmsistem = "CRED"                 AND
                               craptab.tptabela = "COMPBB"               AND
                               craptab.cdempres = 0                      AND
                               craptab.cdacesso = STRING(aux_nrdctabb)   AND
                               craptab.tpregist = 1
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                          IF   NOT AVAILABLE craptab   THEN
                               IF   LOCKED craptab   THEN
                                    DO:
                                        PAUSE 2 NO-MESSAGE.
                                        NEXT.
                                    END.
                               ELSE
                                    DO:
                                        CREATE craptab.
                                        ASSIGN craptab.nmsistem = "CRED"
                                               craptab.tptabela = "COMPBB"
                                               craptab.cdempres = 0
                                               craptab.cdacesso =
                                                       STRING(aux_nrdctabb)
                                               craptab.tpregist = 1
                                               craptab.cdcooper = glb_cdcooper.
                                    END.

                          ASSIGN tot_vlcompdb = DECIMAL(SUBSTR(craptab.dstextab,
                                                               01,15))
                                 tot_qtcompdb = INTEGER(SUBSTR(craptab.dstextab,
                                                               17,06))

                                 tot_vlcompdb = tot_vlcompdb + aux_vllanmto
                                 tot_qtcompdb = tot_qtcompdb + 1

                                 craptab.dstextab = STRING(tot_vlcompdb,
                                                           "999999999999.99") +
                                                    " " +
                                                    STRING(tot_qtcompdb,
                                                           "999999").
                          VALIDATE craptab.

                          LEAVE.

                       END.  /*  Fim do DO WHILE TRUE  */
              END.
         ELSE
         IF   aux_flgentra   AND   aux_flgdepos   THEN
              DO:
                  FIND craphis WHERE craphis.cdcooper = glb_cdcooper   AND
                                     craphis.cdhistor = aux_cdhistor
                                     NO-LOCK NO-ERROR.

                  IF   NOT AVAILABLE craphis   THEN
                       DO:
                           glb_cdcritic = 80.
                           RUN fontes/critic.p.
                           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                             " - " + glb_cdprogra + "' --> '" +
                                             glb_dscritic + "HST = " +
                                             STRING(aux_cdhistor,"9999") +
                                             " >> log/proc_batch.log").
                           UNDO TRANS_1, RETURN.
                       END.

                  IF   aux_cdhistor = 170   THEN
                       DO:
                           CREATE crapdpb.
                           ASSIGN crapdpb.dtmvtolt = craplot.dtmvtolt
                                  crapdpb.cdagenci = craplot.cdagenci
                                  crapdpb.cdbccxlt = craplot.cdbccxlt
                                  crapdpb.nrdolote = craplot.nrdolote
                                  crapdpb.nrdconta = aux_nrdconta
                                  crapdpb.dtliblan = aux_dtliblan
                                  crapdpb.cdhistor = aux_cdhistor
                                  crapdpb.nrdocmto = aux_nrseqint
                                  crapdpb.vllanmto = aux_vllanmto
                                  crapdpb.inlibera = 1
                                  crapdpb.cdcooper = glb_cdcooper.
                           VALIDATE crapdpb.
                       END.

                  CREATE craplcm.
                  ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                         craplcm.cdagenci = craplot.cdagenci
                         craplcm.cdbccxlt = craplot.cdbccxlt
                         craplcm.nrdolote = craplot.nrdolote
                         craplcm.nrdconta = aux_nrdconta
                         craplcm.nrdctabb = aux_nrdctabb
                         craplcm.nrdctitg = aux_dsdctitg
                         craplcm.nrdocmto = aux_nrseqint

                         craplcm.cdhistor = aux_cdhistor

                         craplcm.vllanmto = aux_vllanmto
                         craplcm.nrseqdig = aux_nrseqint
                         craplcm.cdpesqbb = aux_cdpesqbb
                         craplcm.cdcooper = glb_cdcooper

                         craplot.qtinfoln = craplot.qtinfoln + 1
                         craplot.qtcompln = craplot.qtcompln + 1
                         craplot.vlinfocr = craplot.vlinfocr + aux_vllanmto
                         craplot.vlcompcr = craplot.vlcompcr + aux_vllanmto
                         craplot.nrseqdig = craplcm.nrseqdig.

                  VALIDATE craplcm.

                  IF   craphis.indebcre = "C"   THEN            /*  Creditos  */
                       DO WHILE TRUE:

                          FIND craptab WHERE
                               craptab.cdcooper = glb_cdcooper           AND
                               craptab.nmsistem = "CRED"                 AND
                               craptab.tptabela = "COMPBB"               AND
                               craptab.cdempres = 0                      AND
                               craptab.cdacesso = STRING(aux_nrdctabb)   AND
                               craptab.tpregist = 2
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                          IF   NOT AVAILABLE craptab   THEN
                               IF   LOCKED craptab   THEN
                                    DO:
                                        PAUSE 2 NO-MESSAGE.
                                        NEXT.
                                    END.
                               ELSE
                                    DO:
                                        CREATE craptab.
                                        ASSIGN craptab.nmsistem = "CRED"
                                               craptab.tptabela = "COMPBB"
                                               craptab.cdempres = 0
                                               craptab.cdacesso =
                                                       STRING(aux_nrdctabb)
                                               craptab.tpregist = 2
                                               craptab.cdcooper = glb_cdcooper.
                                    END.

                          ASSIGN tot_vlcompcr = DECIMAL(SUBSTR(craptab.dstextab,
                                                               01,15))
                                 tot_qtcompcr = INTEGER(SUBSTR(craptab.dstextab,
                                                               17,06))

                                 tot_vlcompcr = tot_vlcompcr + aux_vllanmto
                                 tot_qtcompcr = tot_qtcompcr + 1

                                 craptab.dstextab = STRING(tot_vlcompcr,
                                                           "999999999999.99") +
                                                    " " +
                                                    STRING(tot_qtcompcr,
                                                           "999999").
                          VALIDATE craptab.

                          LEAVE.

                       END.  /*  Fim do DO WHILE TRUE  */
              END.
         ELSE
         IF   aux_flgentra   AND   aux_flgestor   THEN
              DO:
                  FIND craphis WHERE craphis.cdcooper = glb_cdcooper   AND
                                     craphis.cdhistor = aux_cdhistor
                                     NO-LOCK NO-ERROR.

                  IF   NOT AVAILABLE craphis   THEN
                       DO:
                           glb_cdcritic = 80.
                           RUN fontes/critic.p.
                           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                             " - " + glb_cdprogra + "' --> '" +
                                             glb_dscritic + "HST = " +
                                             STRING(aux_cdhistor,"9999") +
                                             " >> log/proc_batch.log").
                           UNDO TRANS_1, RETURN.
                       END.

                  IF   aux_cdhistor = 297   THEN
                       DO:
                           FIND FIRST crapdpb WHERE 
                                      crapdpb.cdcooper = glb_cdcooper AND
                                      crapdpb.cdagenci = 1            AND
                                      crapdpb.cdbccxlt = 1            AND
                                      crapdpb.cdhistor = 170          AND
                                      crapdpb.inlibera = 1            AND
                                      crapdpb.nrdconta = aux_nrdconta AND
                                      crapdpb.vllanmto = aux_vllanmto
                                      EXCLUSIVE-LOCK NO-ERROR.           
                                      
                           IF   NOT AVAILABLE crapdpb THEN
                                aux_cdhistor = 290.
                           ELSE
                                crapdpb.inlibera = 2.
                       END.
                  ELSE
                       aux_cdhistor = 290.
                       
                  CREATE craplcm.
                  ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                         craplcm.cdagenci = craplot.cdagenci
                         craplcm.cdbccxlt = craplot.cdbccxlt
                         craplcm.nrdolote = craplot.nrdolote
                         craplcm.nrdconta = aux_nrdconta
                         craplcm.nrdctabb = aux_nrdctabb
                         craplcm.nrdctitg = aux_dsdctitg
                         craplcm.nrdocmto = aux_nrseqint

                         craplcm.cdhistor = aux_cdhistor

                         craplcm.vllanmto = aux_vllanmto
                         craplcm.nrseqdig = aux_nrseqint
                         craplcm.cdpesqbb = aux_cdpesqbb
                         craplcm.cdcooper = glb_cdcooper

                         craplot.qtinfoln = craplot.qtinfoln + 1
                         craplot.qtcompln = craplot.qtcompln + 1
                         craplot.vlinfodb = craplot.vlinfodb + aux_vllanmto
                         craplot.vlcompdb = craplot.vlcompdb + aux_vllanmto
                         craplot.nrseqdig = craplcm.nrseqdig.
                  
                  VALIDATE craplcm.

                  IF   craphis.indebcre = "D"   THEN            /*  Debitos   */
                       DO WHILE TRUE:

                          FIND craptab WHERE
                               craptab.cdcooper = glb_cdcooper           AND
                               craptab.nmsistem = "CRED"                 AND
                               craptab.tptabela = "COMPBB"               AND
                               craptab.cdempres = 0                      AND
                               craptab.cdacesso = STRING(aux_nrdctabb)   AND
                               craptab.tpregist = 1
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                          IF   NOT AVAILABLE craptab   THEN
                               IF   LOCKED craptab   THEN
                                    DO:
                                        PAUSE 2 NO-MESSAGE.
                                        NEXT.
                                    END.
                               ELSE
                                    DO:
                                        CREATE craptab.
                                        ASSIGN craptab.nmsistem = "CRED"
                                               craptab.tptabela = "COMPBB"
                                               craptab.cdempres = 0
                                               craptab.cdacesso =
                                                       STRING(aux_nrdctabb)
                                               craptab.tpregist = 1
                                               craptab.cdcooper = glb_cdcooper.
                                    END.

                          ASSIGN tot_vlcompdb = DECIMAL(SUBSTR(craptab.dstextab,
                                                               01,15))
                                 tot_qtcompdb = INTEGER(SUBSTR(craptab.dstextab,
                                                               17,06))

                                 tot_vlcompdb = tot_vlcompdb + aux_vllanmto
                                 tot_qtcompdb = tot_qtcompdb + 1

                                 craptab.dstextab = STRING(tot_vlcompdb,
                                                           "999999999999.99") +
                                                    " " +
                                                    STRING(tot_qtcompdb,
                                                           "999999").
                          VALIDATE craptab.

                          LEAVE.

                       END.  /*  Fim do DO WHILE TRUE  */
              END.
         ELSE
              DO:
                  IF   aux_indebcre = "D"   THEN
                       DO WHILE TRUE:

                          FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                             craptab.nmsistem = "CRED"       AND
                                             craptab.tptabela = "COMPBB"     AND
                                             craptab.cdempres = 0            AND
                                             craptab.cdacesso = "99999999"   AND
                                             craptab.tpregist = 1
                                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                          IF   NOT AVAILABLE craptab   THEN
                               IF   LOCKED craptab   THEN
                                    DO:
                                        PAUSE 2 NO-MESSAGE.
                                        NEXT.
                                    END.
                               ELSE
                                    DO:
                                        CREATE craptab.
                                        ASSIGN craptab.nmsistem = "CRED"
                                               craptab.tptabela = "COMPBB"
                                               craptab.cdempres = 0
                                               craptab.cdacesso = "99999999"
                                               craptab.tpregist = 1
                                               craptab.cdcooper = glb_cdcooper.
                                    END.

                          ASSIGN tot_vlcompdb = DECIMAL(SUBSTR(craptab.dstextab,
                                                               01,15))
                                 tot_qtcompdb = INTEGER(SUBSTR(craptab.dstextab,
                                                               17,06))

                                 tot_vlcompdb = tot_vlcompdb + aux_vllanmto
                                 tot_qtcompdb = tot_qtcompdb + 1

                                 craptab.dstextab = STRING(tot_vlcompdb,
                                                           "999999999999.99") +
                                                    " " +
                                                    STRING(tot_qtcompdb,
                                                           "999999").
                          VALIDATE craptab.

                          LEAVE.

                       END.  /*  Fim do DO WHILE TRUE  */
                  ELSE
                  IF   aux_indebcre = "C"   THEN
                       DO WHILE TRUE:

                          FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                             craptab.nmsistem = "CRED"       AND
                                             craptab.tptabela = "COMPBB"     AND
                                             craptab.cdempres = 0            AND
                                             craptab.cdacesso = "99999999"   AND
                                             craptab.tpregist = 2
                                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                          IF   NOT AVAILABLE craptab   THEN
                               IF   LOCKED craptab   THEN
                                    DO:
                                        PAUSE 2 NO-MESSAGE.
                                        NEXT.
                                    END.
                               ELSE
                                    DO:
                                        CREATE craptab.
                                        ASSIGN craptab.nmsistem = "CRED"
                                               craptab.tptabela = "COMPBB"
                                               craptab.cdempres = 0
                                               craptab.cdacesso = "99999999"
                                               craptab.tpregist = 2
                                               craptab.cdcooper = glb_cdcooper.
                                    END.

                          ASSIGN tot_vlcompcr = DECIMAL(SUBSTR(craptab.dstextab,
                                                               01,15))
                                 tot_qtcompcr = INTEGER(SUBSTR(craptab.dstextab,
                                                               17,06))

                                 tot_vlcompcr = tot_vlcompcr + aux_vllanmto
                                 tot_qtcompcr = tot_qtcompcr + 1

                                 craptab.dstextab = STRING(tot_vlcompcr,
                                                           "999999999999.99") +
                                                    " " +
                                                    STRING(tot_qtcompcr,
                                                           "999999").
                          VALIDATE craptab.

                          LEAVE.

                       END.  /*  Fim do DO WHILE TRUE  */
              
                 aux_flgentra = TRUE.
              END.
         
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
                          UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                            " - " + glb_cdprogra + "' --> '" +
                                            glb_dscritic +
                                            " >> log/proc_batch.log").
                          UNDO TRANS_1, RETURN.
                      END.

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

         ASSIGN crapres.nrdconta = aux_nrseqint
                glb_inrestar     = 0.

      END.  /*  Fim da Transacao  */

   END.   /*  Fim do DO WHILE TRUE  */

   INPUT STREAM str_2 CLOSE.

   IF   NOT aux_flgarqvz   THEN
        DO:
            /*  Emite resumo da integracao  */

            FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                               craplot.dtmvtolt = glb_dtmvtolt   AND
                               craplot.cdagenci = aux_cdagenci   AND
                               craplot.cdbccxlt = aux_cdbccxlt   AND
                               craplot.nrdolote = aux_nrdolote
                               USE-INDEX craplot1 NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craplot   THEN
                 IF   aux_nrdolote > 0   THEN
                      DO:
                          glb_cdcritic = 60.
                          RUN fontes/critic.p.
                          UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                            " - " + glb_cdprogra + "' --> '" +
                                            glb_dscritic + " COMPBB - LOTE = " +
                                            STRING(aux_nrdolote,"999,999") +
                                            " >> log/proc_batch.log").
                          RETURN.
                      END.

            ASSIGN aux_flgfirst = TRUE
                   aux_flgerros = FALSE

                   tot_contareg = 0
                   tot_vllanmto = 0
                   tot_qtcompdb = 0
                   tot_vlcompdb = 0
                   tot_qtcompcr = 0
                   tot_vlcompcr = 0
                   tot_vllandep = 0
                   tot_qtlandep = 0.

            OUTPUT STREAM str_1 TO VALUE("rl/" + aux_nmarqimp[tt-crapcop.cdcooper])
                   PAGED PAGE-SIZE 84.

            VIEW STREAM str_1 FRAME f_cabrel132_1.

            VIEW STREAM str_1 FRAME f_labelres.

            tot_dsintegr = "INTEGRADOS NA CONTA".
            
            /*  Leitura dos totais compensados  */

            FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                   craptab.nmsistem = "CRED"         AND
                                   craptab.tptabela = "COMPBB"       AND
                                   craptab.cdempres = 0 NO-LOCK
                                   BREAK BY INT(craptab.cdacesso):

               IF  craptab.tpregist = 1   THEN
                   ASSIGN tot_vlcompdb = DECIMAL(SUBSTR(craptab.dstextab,1,15))
                          tot_qtcompdb = INTEGER(SUBSTR(craptab.dstextab,17,6)).
               ELSE
                   ASSIGN tot_vlcompcr = DECIMAL(SUBSTR(craptab.dstextab,1,15))
                          tot_qtcompcr = INTEGER(SUBSTR(craptab.dstextab,17,6)).

               IF   NOT LAST-OF(INT(craptab.cdacesso))   THEN
                    NEXT.

               ASSIGN tot_nrdctabb = INTEGER(craptab.cdacesso)

                      ger_qtcompdb = ger_qtcompdb + tot_qtcompdb
                      ger_qtcompcr = ger_qtcompcr + tot_qtcompcr
                      
                      ger_vlcompdb = ger_vlcompdb + tot_vlcompdb
                      ger_vlcompcr = ger_vlcompcr + tot_vlcompcr.
                      
               IF   INT(craptab.cdacesso) = 99999999   THEN
                    ASSIGN tot_dsintegr = "NAO INTEGRADOS"
                           tot_nrdctabb = 0.
               
               DISPLAY STREAM str_1
                       tot_dsintegr  tot_nrdctabb
                       tot_qtcompdb  tot_vlcompdb
                       tot_qtcompcr  tot_vlcompcr
                       WITH FRAME f_resumo.

               DOWN STREAM str_1 WITH FRAME f_resumo.

               IF   LINE-COUNTER(str_1) > 80   THEN
                    DO:
                        PAGE STREAM str_1.

                        VIEW STREAM str_1 FRAME f_labelres.
                    END.

            END.  /*  Fim do FOR EACH  --  Leitura dos totais compensados  */

            tot_dsintegr = "TOTAL DA COMPE".

            DISPLAY STREAM str_1
                   tot_dsintegr  
                   tot_qtcompdb  
                   tot_vlcompdb
                   tot_qtcompcr  
                   tot_vlcompcr
                   WITH FRAME f_resumo.

            DOWN STREAM str_1 WITH FRAME f_resumo.

            /*  Saldos bloqueados nas contas  */

            RUN lista_saldos.

            PAGE STREAM str_1.
            
            FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper   AND
                                   craprej.dtmvtolt = glb_dtmvtolt   AND
                                   craprej.cdagenci = aux_cdagenci   AND
                                   craprej.cdbccxlt = aux_cdbccxlt   AND
                                   craprej.nrdolote = aux_nrdolote   AND
                                   craprej.tpintegr = 1              NO-LOCK
                                   BREAK BY craprej.dtmvtolt
                                         BY craprej.cdagenci
                                         BY craprej.cdbccxlt
                                         BY craprej.nrdolote
                                         BY craprej.tpintegr
                                         BY craprej.nrdctabb
                                         BY craprej.dtdaviso
                                         BY craprej.nrdocmto:

                IF   aux_flgfirst   THEN
                     DO:
                         VIEW STREAM str_1 FRAME f_labelrej.
                         ASSIGN aux_flgfirst = FALSE
                                aux_flgerros = TRUE.
                     END.

                IF   glb_cdcritic <> craprej.cdcritic   THEN
                     DO:
                         glb_cdcritic = craprej.cdcritic.

                         RUN fontes/critic.p.

                         glb_dscritic = SUBSTRING(glb_dscritic,7,50).

                         IF   CAN-DO("96,137,172,257,287,439,508,608",
                                     STRING(craprej.cdcritic))   THEN
                              glb_dscritic = "* " + glb_dscritic.
                     END.

                IF   NOT CAN-DO("96,137,172,257,287,439,508,608,762",
                                STRING(craprej.cdcritic))   THEN
                     tot_contareg = tot_contareg + 1.

                DISPLAY STREAM str_1
                        craprej.nrseqdig  craprej.dshistor  craprej.nrdctabb
                        craprej.dtrefere  craprej.nrdocmto  craprej.cdpesqbb
                        craprej.vllanmto  craprej.indebcre  craprej.nrdconta
                        glb_dscritic
                        WITH FRAME f_rejeitados.

                DOWN STREAM str_1 WITH FRAME f_rejeitados.

                IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                     DO:
                         PAGE STREAM str_1.

                         VIEW STREAM str_1 FRAME f_labelrej.
                     END.

            END.   /*  Fim do FOR EACH  --  Leitura dos rejeitados  */

            IF   aux_flgerros   THEN
                 DO:
                     IF   LINE-COUNTER(str_1) > 78   THEN
                          DO:
                              PAGE STREAM str_1.

                              VIEW STREAM str_1 FRAME f_labelrej.
                          END.

                     DISPLAY STREAM str_1
                             tot_contareg WITH FRAME f_totalrej.

                     ASSIGN tot_contareg = 0
                            tot_vllanmto = 0.

                     PAGE STREAM str_1.
                 END.

            IF   AVAILABLE craplot   THEN
                 DISPLAY STREAM str_1
                         aux_vlmaichq
                         craplot.dtmvtolt  craplot.cdagenci
                         craplot.cdbccxlt  craplot.nrdolote
                         craplot.qtcompln  craplot.vlcompdb
                         WITH FRAME f_labelint.

            /*  Leitura dos lancamentos integrados  --  Maiores cheques  */

            FOR EACH craplcm WHERE craplcm.cdcooper  = glb_cdcooper   AND
                                   craplcm.dtmvtolt  = glb_dtmvtolt   AND
                                   craplcm.cdagenci  = aux_cdagenci   AND
                                   craplcm.cdbccxlt  = aux_cdbccxlt   AND
                                   craplcm.nrdolote  = aux_nrdolote   AND
                                  (craplcm.cdhistor  = 50             OR
                                   craplcm.cdhistor  = 59)            AND
                                   craplcm.vllanmto >= aux_vlmaichq
                                   USE-INDEX craplcm3 NO-LOCK:

                DISPLAY STREAM str_1
                        craplcm.nrdctabb  craplcm.nrdocmto  craplcm.nrdconta
                        craplcm.cdhistor  craplcm.vllanmto  craplcm.cdpesqbb
                        craplcm.nrseqdig
                        WITH FRAME f_integrados.

                ASSIGN tot_contareg = tot_contareg + 1
                       tot_vllanmto = tot_vllanmto + craplcm.vllanmto.

                DOWN STREAM str_1 WITH FRAME f_integrados.

                IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                     DO:
                         PAGE STREAM str_1.

                         IF   AVAILABLE craplot   THEN
                              DISPLAY STREAM str_1
                                      aux_vlmaichq
                                      craplot.dtmvtolt  craplot.cdagenci
                                      craplot.cdbccxlt  craplot.nrdolote
                                      craplot.qtcompln  craplot.vlcompdb
                                      WITH FRAME f_labelint.
                     END.

            END.  /*  Fim do FOR EACH -- Leitura dos lancamentos integrados  */

            IF   LINE-COUNTER(str_1) > 78   THEN
                 DO:
                     PAGE STREAM str_1.

                     IF   AVAILABLE craplot   THEN
                          DISPLAY STREAM str_1
                                  aux_vlmaichq
                                  craplot.dtmvtolt  craplot.cdagenci
                                  craplot.cdbccxlt  craplot.nrdolote
                                  craplot.qtcompln  craplot.vlcompdb
                                  WITH FRAME f_labelint.
                 END.

            DISPLAY STREAM str_1
                    tot_contareg  tot_vllanmto
                    WITH FRAME f_totalint.

            OUTPUT STREAM str_1 CLOSE.

            ASSIGN glb_nrcopias = 1
                   glb_nmformul = "132dm"
                   glb_nmarqimp = "rl/" + aux_nmarqimp[tt-crapcop.cdcooper].
                       
            RUN fontes/imprim.p.
            
            IF   CAN-DO("3",STRING(crapcop.cdcooper))   THEN
                 DO:
                     RUN resumo_central(INPUT tt-crapcop.cdcooper).
                
                     /****
                     UNIX SILENT VALUE("mtsend.pl " +
                                       "--email rosangela@cecred.coop.br " +
                                       "--subject " +
                                       '"Integracao dos cheques da ' + 
                                       CAPS(crapcop.nmrescop) + '"' +
                                       " --body " + '"SEGUE ARQUIVO DA ' + 
                                       CAPS(crapcop.nmrescop) + ' EM ANEXO"' +
                                       " --attach " +
                                       aux_nmarqimp[tt-crapcop.cdcooper] + " &").
                     ****/
                 
                 END.
                   
            IF   aux_nrdolote > 0   THEN
                 ASSIGN lot_qtcompln = craplot.qtcompln
                        lot_vlcompdb = craplot.vlcompdb.
            ELSE
                 ASSIGN lot_qtcompln = 0
                        lot_vlcompdb = 0.
        END.
   ELSE
        DO:
            IF   aux_flgchqbb   THEN
                 DO:
                     glb_cdcritic = 263.
                     RUN fontes/critic.p.
                     UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                        " - " +
                                        glb_cdprogra + "' --> '" + 
                                        glb_dscritic + " '" +
                                        aux_nmarqint[tt-crapcop.cdcooper] + "'" +
                                        " >> log/proc_batch.log").
                     RETURN.
                 END.
        END.
        
   /* Alterado para sempre exibir a mensagem de processado com sucesso. 
      No log nao interessa se possui rejeitados ou nao, apenas se o arquivo foi processado */
   glb_cdcritic = 190.

   RUN fontes/critic.p.
   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                     " - " + glb_cdprogra + "' --> '" +
                     glb_dscritic + "' --> '" +
                     aux_nmarqint[tt-crapcop.cdcooper] + 
                     " >> log/proc_batch.log").

   /*  Move arquivo integrado para o diretorio salvar  */

   UNIX SILENT VALUE("mv " + aux_nmarqint[tt-crapcop.cdcooper] + " salvar").
   UNIX SILENT VALUE("rm " + aux_nmarqint[tt-crapcop.cdcooper] + ".q 2>/dev/null").
   
   UNIX SILENT VALUE("rm compbb/deb558*" + STRING(aux_dtleiarq,"999999") + "*"
                     + STRING(tt-crapcop.cdconven,"999999999") + "*" +
                     " 2>/dev/null").
   
   /*  Zera registro de restart  */

   TRANS_2:

   DO TRANSACTION ON ERROR UNDO TRANS_2, RETURN:

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
                       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                         " - " + glb_cdprogra + "' --> '" +
                                       glb_dscritic + " >> log/proc_batch.log").
                       UNDO TRANS_2, RETURN.
                   END.

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      crapres.nrdconta = 0.

   END.  /*  Fim da transacao  */

   ASSIGN glb_nrctares = 0
          glb_inrestar = 0.

END.  /*  Fim do DO .. TO  --  Arquivos a integrar  */
                
RUN fontes/fimprg.p.

/* .......................................................................... */

PROCEDURE enviar_email:                           

    ASSIGN aux_conteudo = "".

    RUN sistema/generico/procedures/b1wgen0011.p 
        PERSISTENT SET h-b1wgen0011.

    IF  NOT VALID-HANDLE (h-b1wgen0011)  THEN
        DO:
            UNIX SILENT VALUE("echo "
                      + STRING(TIME,"HH:MM:SS") + " - "
                      + glb_cdprogra + "' --> '" 
                      + "Handle invalido para h-b1wgen0011."
                      + " >> log/proc_batch.log").
            QUIT.          
        END.

    ASSIGN aux_conteudo = 
           "ATENCAO!!\n\n Voce esta recebendo este e-mail pois o programa " +
           glb_cdprogra + " acusou critica " + glb_dscritic +
           "\n\nCOOPERATIVA: " + STRING(crapcop.cdcooper) + " - " +
           crapcop.nmrescop + ".\nData: " + STRING(glb_dtmvtolt,"99/99/9999") +
           "\nHora: " + STRING(TIME,"HH:MM:SS").

    RUN enviar_email_completo IN h-b1wgen0011
                (INPUT crapcop.cdcooper,
                 INPUT "crps346",
                 INPUT "CECRED<cecred@cecred.coop.br>",
                 INPUT "cpd@cecred.coop.br," +
                       "diego@cecred.coop.br," +
                       "eduardo@cecred.coop.br," +
                       "david.kistner@cecred.coop.br," +
                       "daniel.zimmermann@cecred.coop.br," +
                       "james.junior@cecred.coop.br," +
					   "elton@cecred.coop.br," +
                       "mirtes@cecred.coop.br",
                 INPUT "Processo da Cooperativa " +
                       STRING(crapcop.cdcooper) + " sem COMPE BB",
                 INPUT "",
                 INPUT "",
                 INPUT aux_conteudo,
                 INPUT FALSE).

    DELETE PROCEDURE h-b1wgen0011.

END PROCEDURE.

PROCEDURE resumo_central:

   DEF INPUT PARAMETER par_contaarq AS INTE                          NO-UNDO.

   DEF VAR tot_vldebito AS DECIMAL                                   NO-UNDO.
   DEF VAR tot_vlcredit AS DECIMAL                                   NO-UNDO.
  
   INPUT STREAM str_2 FROM VALUE(aux_nmarqint[par_contaarq] + ".q") NO-ECHO.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE ON ERROR UNDO, RETURN:

      SET STREAM str_2 aux_dsdlinha WITH WIDTH 212.
      
      IF   SUBSTRING(aux_dsdlinha,1,1) <> "1"   THEN
           NEXT.
      
      /*     
      RUN saldos.
      
      IF   SUBSTRING(aux_dsdlinha,42,1) = "0"   THEN   /*  Registro de saldo  */
           DO:
               DO WHILE TRUE TRANSACTION ON ERROR UNDO, RETURN:
               
                  FIND crawdpb WHERE crawdpb.nrdctabb = aux_nrdctabb 
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                     
                  IF   NOT AVAILABLE crawdpb   THEN
                       IF   LOCKED crawdpb   THEN
                            DO:
                                PAUSE 2 NO-MESSAGE.
                                NEXT.
                            END.   
                       ELSE
                            DO:
                                CREATE crawdpb.
                                ASSIGN crawdpb.nrdctabb = aux_nrdctabb.
                            END.
               
                  ASSIGN crawdpb.vldispon = crawdpb.vldispon +
                               (DECIMAL(SUBSTRING(aux_dsdlinha,087,18)) / 100)
                         crawdpb.vlblq001 = crawdpb.vlblq001 +
                               (DECIMAL(SUBSTRING(aux_dsdlinha,157,17)) / 100)
                         crawdpb.vlblq002 = crawdpb.vlblq002 +
                               (DECIMAL(SUBSTRING(aux_dsdlinha,140,17)) / 100)
                         crawdpb.vlblq003 = crawdpb.vlblq003 +
                               (DECIMAL(SUBSTRING(aux_dsdlinha,123,17)) / 100)
                         crawdpb.vlblq004 = crawdpb.vlblq004 +
                               (DECIMAL(SUBSTRING(aux_dsdlinha,106,17)) / 100)
                         crawdpb.vlblq999 = crawdpb.vlblq999 +
                               (DECIMAL(SUBSTRING(aux_dsdlinha,043,17)) / 100).
                  
                  LEAVE.
                  
               END.  /*  Fim do DO WHILE TRUE  */
           END.
      */
      IF   SUBSTRING(aux_dsdlinha,42,1) <> "1"   THEN
           NEXT.
           
      IF   SUBSTRING(aux_dsdlinha,41,01) = "X" THEN
           aux_nrdctabb = INT(STRING(SUBSTRING(aux_dsdlinha,33,08)) + "0").
      ELSE     
           aux_nrdctabb = INT(SUBSTRING(aux_dsdlinha,33,09)).
      
      ASSIGN aux_nrseqint = INT(SUBSTRING(aux_dsdlinha,195,6))
             aux_dshistor = TRIM(SUBSTRING(aux_dsdlinha,46,29))
             aux_nrdocmto = INT(SUBSTRING(aux_dsdlinha,75,6)) * 10
             aux_vllanmto = DECIMAL(SUBSTRING(aux_dsdlinha,87,18)) / 100

             aux_dtmvtolt = DATE(INT(SUBSTRING(aux_dsdlinha,184,2)),
                                 INT(SUBSTRING(aux_dsdlinha,182,2)),
                                 INT(SUBSTRING(aux_dsdlinha,186,4)))
                                 
             aux_indebcre = IF INT(SUBSTRING(aux_dsdlinha,43,3)) > 100   AND
                               INT(SUBSTRING(aux_dsdlinha,43,3)) < 200
                               THEN "D"
                               ELSE "C".

      DO WHILE TRUE TRANSACTION ON ERROR UNDO, RETURN:
      
         FIND crawtot WHERE crawtot.nrdctabb = aux_nrdctabb   AND
                            crawtot.dshistor = aux_dshistor
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                            
         IF   NOT AVAILABLE crawtot   THEN
              IF   LOCKED crawtot   THEN
                   NEXT.
              ELSE
                   DO:
                       CREATE crawtot.
                       ASSIGN crawtot.nrdctabb = aux_nrdctabb
                              crawtot.dshistor = aux_dshistor
                              crawtot.indebcre = aux_indebcre.
                   END.

         ASSIGN crawtot.qtlanmto = crawtot.qtlanmto + 1
                crawtot.vllanmto = crawtot.vllanmto + aux_vllanmto.
   
         LEAVE.

      END.  /*  Fim do DO WHILE TRUE e da transacao  */
   
   END.  /*  Fim do DO WHILE TRUE  */

   INPUT STREAM str_2 CLOSE.

   ASSIGN aux_nmarquiv = "arq/346tmp_" + STRING(par_contaarq,"999") + ".lst"
   
          tot_vldebito = 0
          tot_vlcredit = 0.

   OUTPUT STREAM str_3 TO VALUE(aux_nmarquiv + ".ux").

   FOR EACH crawtot NO-LOCK BREAK BY crawtot.nrdctabb BY crawtot.dshistor.
       
       IF   NOT CAN-DO("0229TRANSFEREN,0729TRANSFRCIA,0055PAGTOS.DIV," +
                       "0631DESBL.DEP",crawtot.dshistor)   THEN
            DO:
                IF   crawtot.indebcre = "D"   THEN
                     tot_vldebito = tot_vldebito + crawtot.vllanmto.
                ELSE
                     tot_vlcredit = tot_vlcredit + crawtot.vllanmto.
            END.
       ELSE
            NEXT.
            
       DISPLAY STREAM str_3 
               crawtot.nrdctabb LABEL "Conta Base" 
                                FORMAT "zzzz,zzz,9"
               crawtot.dshistor LABEL "Historico" 
                                FORMAT "xxxx-xxxxxxxxxxxxxxxxxxxx"
               crawtot.qtlanmto LABEL "Qtd" 
                                FORMAT "zzz,zz9"
               crawtot.vllanmto LABEL "Valor" 
                                FORMAT "zzz,zzz,zz9.99"
               crawtot.indebcre LABEL "D/C" 
                                FORMAT " x "
               WITH DOWN FRAME f_central 
                    TITLE "Resumo de Historico Por Conta-corrente - " +
                          CAPS(STRING(crapcop.nmrescop,"X(20)")) + "\n\n".
               
       DOWN STREAM str_3 WITH FRAME f_central.
   
   END.  /*  Fim do FOR EACH  */

   DISPLAY STREAM str_3 
           SKIP(1)
           tot_vldebito LABEL " TOTAL A DEBITO" FORMAT "zzz,zzz,zz9.99"
           SKIP
           tot_vlcredit LABEL "TOTAL A CREDITO" FORMAT "zzz,zzz,zz9.99"
           WITH SIDE-LABELS WIDTH 80 FRAME f_total_resumo.

   OUTPUT STREAM str_3 CLOSE.
   
   UNIX SILENT VALUE("ux2dos " + aux_nmarquiv + ".ux " +
                     '| tr -d "\032" > ' + aux_nmarquiv).

   /******
   ASSIGN aux_dsdemail = "Resumo da COMPBB da " + CAPS(crapcop.nmrescop) +
                         " Ref. " + STRING(glb_dtmvtolt,"99/99/9999")
                         
          aux_lsdestin = "rosangela@cecred.coop.br".

   UNIX SILENT VALUE("cat " + aux_nmarquiv + " | mailx -s " +
                     '"' + aux_dsdemail + '" ' + aux_lsdestin + " &").
 
   UNIX SILENT VALUE("mtsend.pl " + " --email rosangela@cecred.coop.br" +
                                    " --subject " +
                                    '"' + aux_dsdemail + '"' +
                                    " --body " + '"SEGUE ARQUIVO DA ' + 
                                    CAPS(crapcop.nmrescop) + ' EM ANEXO"' +
                                    " --attach " +
                                    aux_nmarquiv + " &").
   *******/

END PROCEDURE.

PROCEDURE saldos:

   IF   SUBSTRING(aux_dsdlinha,42,1) = "0"   OR
        SUBSTRING(aux_dsdlinha,42,1) = "2"   THEN   /*  Registro de saldo  */
        DO:
            FIND crawdpb WHERE crawdpb.nrdctabb = aux_nrdctabb 
                               EXCLUSIVE-LOCK NO-ERROR.
                                     
            IF   NOT AVAILABLE crawdpb   THEN
                 DO:
                     CREATE crawdpb.
                     ASSIGN crawdpb.nrdctabb = aux_nrdctabb.
                 END.
              
            IF   SUBSTRING(aux_dsdlinha,42,1) = "2"   THEN
                 ASSIGN crawdpb.vldispon = crawdpb.vldispon +
                              (DECIMAL(SUBSTRING(aux_dsdlinha,087,18)) / 100).
            ELSE                    
                 ASSIGN crawdpb.vlblq001 = crawdpb.vlblq001 +
                              (DECIMAL(SUBSTRING(aux_dsdlinha,157,17)) / 100)
                        crawdpb.vlblq002 = crawdpb.vlblq002 +
                              (DECIMAL(SUBSTRING(aux_dsdlinha,140,17)) / 100)
                        crawdpb.vlblq003 = crawdpb.vlblq003 +
                              (DECIMAL(SUBSTRING(aux_dsdlinha,123,17)) / 100)
                        crawdpb.vlblq004 = crawdpb.vlblq004 +
                              (DECIMAL(SUBSTRING(aux_dsdlinha,106,17)) / 100)
                        crawdpb.vlblq999 = crawdpb.vlblq999 +
                              (DECIMAL(SUBSTRING(aux_dsdlinha,043,17)) / 100).
        END.

END PROCEDURE.

PROCEDURE lista_saldos:

   DEF VAR rel_vlbloque AS DECIMAL                                   NO-UNDO.
   DEF VAR ger_vldispon AS DECIMAL                                   NO-UNDO.
   DEF VAR ger_vlblq001 AS DECIMAL                                   NO-UNDO.
   DEF VAR ger_vlblq002 AS DECIMAL                                   NO-UNDO.
   DEF VAR ger_vlblq003 AS DECIMAL                                   NO-UNDO.
   DEF VAR ger_vlblq004 AS DECIMAL                                   NO-UNDO.
   DEF VAR ger_vlblq999 AS DECIMAL                                   NO-UNDO.
   DEF VAR ger_vlbloque AS DECIMAL                                   NO-UNDO.

   DISPLAY STREAM str_1
           SKIP(1)
           "SALDOS NO BANCO DO BRASIL"
           SKIP(1)
           WITH WIDTH 132 FRAME f_label_resumo.
           
   FOR EACH crawdpb NO-LOCK:

       rel_vlbloque = crawdpb.vlblq001 + crawdpb.vlblq002 +
                      crawdpb.vlblq003 + crawdpb.vlblq004 +
                      crawdpb.vlblq999 + crawdpb.vldispon.
             
       ASSIGN ger_vlbloque = ger_vlbloque + rel_vlbloque
              ger_vldispon = ger_vldispon + crawdpb.vldispon
              ger_vlblq001 = ger_vlblq001 + crawdpb.vlblq001 
              ger_vlblq002 = ger_vlblq002 + crawdpb.vlblq002
              ger_vlblq003 = ger_vlblq003 + crawdpb.vlblq003 
              ger_vlblq004 = ger_vlblq004 + crawdpb.vlblq004 
              ger_vlblq999 = ger_vlblq999 + crawdpb.vlblq999.
       
       DISPLAY STREAM str_1
               crawdpb.nrdctabb LABEL "CONTA BASE"    FORMAT "zzzz,zzz,9"
               crawdpb.vldispon LABEL "DISPONIVEL"    FORMAT "zzz,zzz,zz9.99"
               crawdpb.vlblq001 LABEL "1 DIA"         FORMAT "zzz,zzz,zz9.99"
               crawdpb.vlblq002 LABEL "2 DIAS"        FORMAT "zzz,zzz,zz9.99"
               crawdpb.vlblq003 LABEL "3 DIAS"        FORMAT "zzz,zzz,zz9.99"
               crawdpb.vlblq004 LABEL "4 DIAS"        FORMAT "zzz,zzz,zz9.99"
               crawdpb.vlblq999 LABEL "INDETERMINADO" FORMAT "zzz,zzz,zz9.99"
               rel_vlbloque     LABEL "TOTAL"         FORMAT "zzz,zzz,zz9.99"
               WITH NO-BOX DOWN WIDTH 132 FRAME f_bloque.
              
       DOWN STREAM str_1 WITH FRAME f_bloque.     
           
   END.  /*  Fim do FOR EACH  */

   DISPLAY STREAM str_1
           SKIP(1)
           "TOTAL ===>"
           ger_vldispon FORMAT "zzz,zzz,zz9.99"
           ger_vlblq001 FORMAT "zzz,zzz,zz9.99"
           ger_vlblq002 FORMAT "zzz,zzz,zz9.99"
           ger_vlblq003 FORMAT "zzz,zzz,zz9.99"
           ger_vlblq004 FORMAT "zzz,zzz,zz9.99"
           ger_vlblq999 FORMAT "zzz,zzz,zz9.99"
           ger_vlbloque FORMAT "zzz,zzz,zz9.99"
           WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_tot_geral.

   /* Gravacao de dados no banco GENERICO - Relatorios Gerenciais */
            
   DO WHILE TRUE:

      /* Consulta ajustada para gravar os dados com base no processo 
	  que será executado. DTMVTOLT - Processo Normal
	                      DTMVTAON - Processo COMPEFORA.
						  
	  Obs: O processo COMPEFORA eh executado quando os arquivos deb558*
	  nao chegam a tempo de ser executado no processo NOTURNO. Falar
	  com o Devid G. Kistner sobre mais detalhes desse processo.
      
	  Esse ajuste foi discutido com o solicitante Fernando - Controles 
	  Internos junto ao analista responsavel para gravar os dados 
	  totalizadores no dia anterior para que os dados sejam mantidos visiveis
	  no demostrativo na intranet. Antes essa variavel era gravada no
	  mesmo dia que o processo noturno seria executado, com isso o registro
	  era sobrescrito e a informacao era perdida. Para a area de controle
	  esse valor nao eh critico, se trata de um demonstrativo do dia que
	  eh mostrado no painel gerencial da intranet.
	  */

      FIND gntotpl WHERE gntotpl.cdcooper = crapcop.cdcooper AND
                         gntotpl.dtmvtolt = aux_dtleiarq
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE gntotpl THEN
           IF   LOCKED gntotpl THEN
                DO:
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
           ELSE
                DO:
                    CREATE gntotpl.
                    ASSIGN gntotpl.cdcooper = crapcop.cdcooper
                           gntotpl.dtmvtolt = aux_dtleiarq.
                END.

      LEAVE.

   END. /* Fim do DO WHILE TRUE */

   ASSIGN gntotpl.vlslddbb = ger_vlbloque.

   VALIDATE gntotpl.
 
   /* Fim da gravacao */

END PROCEDURE.

/* .......................................................................... */
