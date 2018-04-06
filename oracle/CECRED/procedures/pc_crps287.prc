CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS287" (pr_cdcooper IN crapcop.cdcooper%TYPE
                                         ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                                         ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                         ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                         ,pr_dscritic OUT VARCHAR2) IS
  BEGIN

/* .............................................................................

   Programa: pc_crps287                      Antigo: Fontes/crps287.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Maio/2000.                      Ultima atualizacao: 06/06/2017

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 005.
               Liberar cheques em custodia.
               Emite relatorio 234.

   Alteracoes: 17/05/2000 - Alterado para emitir resumo contabil (Edson).

               23/10/2000 - Desmembrar a critica 95 conforme a situacao do
                            titular (Eduardo).

               06/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               07/06/2001 - Alterado para tratar tabela de custodia
                            (CRED-CUSTOD-00-nnnnnnnnnn-000) - Edson.

               10/07/2001 - Alterado para associar o cheque em custodia ao
                            deposito efetuado (Edson).

               21/05/2002 - Permitir qualquer dia para custodia(Margarete).

               25/06/2002 - Quando segunda-feira saldo anterior nao sai
                            correto (Margarete).

               28/10/2003 - Retirado use-index crapcst(Mirtes)

               30/10/2003 - Incluidas as informacoes referentes a desconto de
                            cheques. Substituicao da utilizacao do craprej por
                            uma TEMP-TABLE "crawtot" (Julio).

               09/06/2004 - Incluido Total Cheques Comp (Evandro).

               29/06/2004 - Ajuste na rotina do saldo contabil (Edson).

               30/06/2005 - Alimentado campo cdcooper das tabelas craplot
                            craplcm e crapdpb (Diego).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               11/03/2008 - Incluir "(CONTA BLOQUEADA)" nos casos de critica 95
                            e nao cancelar o programa (Evandro).

               19/08/2008 - Tratar pracas de compensacao (Magui).

               14/10/2009 - Reestruturacao do programa para o CAF (Guilherme).

               01/03/2010 - Alterado descricao da critica no log da procedure
                            calcula_bloqueio_cheque (Elton).

               17/03/2010 - Acerto na geracao da crawtot (David).

               22/03/2010 - Acerto no incremento para numero de documento
                            da crapdpb (David).

               15/06/2010 - Tratar nossa IF (Magui).

               01/12/2010 - Alteracao de Format (Kbase/Willian).
                            001 - Alterado para 50 posi??es, valor anterior 40.

               27/07/2012 - Ajuste do format no campo nmrescop (David Kruger).

               08/08/2013 - Convers?o Progress -> Oracle - Alisson (AMcom)

               25/11/2013 - Ajustes na passagem dos parâmetros para restart (Marcos-Supero)

               04/06/2014 - Aumento do format de vr_res_dschqcop para 29 e do nmrescop
                            para 20 (Carlos)

               10/12/2014 - Nao executar raise vr_exc_erro quando ocorrencia 684 para nao
                            interromper o processamento na cadeia. (Rafael)
                            
               22/06/2016 - Correcao para o uso de parte do indice da CRAPTAB nesta rotina.
                            (Carlos Rafael Tanholi).

               04/11/2016 - Ajustar cursor de custodia de cheques - Projeto 300 (Rafael) 
               
               06/06/2017 - Colocar saida da CCAF0001 para gravar LOG no padrão
                            tratada exceção 9999 ( Belli Envolti ) - Ch 665812
               
               20/09/2017 - Ajuste no cursor crapcst para nao mais efetuar validacao atraves
			                do nrborder = 0 e sim atraves de leitura da crapcdb quando o cheque
							nao tiver data de devolução. (Daniel) 
               
               21/09/2017 - Ajustado para não gravar nmarqlog, pois so gera a tbgen_prglog
                            (Ana - Envolti - Chamado 746134)
               12/01/2018 - Melhoria na gravacao de LOG ao gerar criticas no processamento dos cheques
                            Heitor (Mouts) - Chamado 827706
     ............................................................................. */

     DECLARE

       /* Tipos e registros da pc_crps287 */
       TYPE typ_reg_crawtot IS
         RECORD (dtmvtolt DATE
                ,nrdconta INTEGER
                ,qtresgat INTEGER
                ,vlresgat NUMBER
                ,qtcredit INTEGER
                ,vlcredit NUMBER
                ,qtcontra INTEGER
                ,vlcontra NUMBER
                ,qtproces INTEGER
                ,vlproces NUMBER);

       TYPE typ_reg_cheques IS
         RECORD (dtlibera DATE
                ,nrdocmto INTEGER
                ,vlcompel NUMBER
                ,qtcheque INTEGER
                ,nrdconta INTEGER
                ,nrdeposi INTEGER);

       TYPE typ_reg_crapass IS
         RECORD (cdsitdtl crapass.cdsitdtl%TYPE
                ,nmprimtl crapass.nmprimtl%TYPE);

       --Definicao do tipo de registro para tabela memoria saldo medio
       TYPE typ_tab_crawtot IS TABLE OF typ_reg_crawtot INDEX BY PLS_INTEGER;
       TYPE typ_tab_crapass IS TABLE OF typ_reg_crapass INDEX BY PLS_INTEGER;
       TYPE typ_tab_craptab IS TABLE OF craptab.dstextab%type INDEX BY PLS_INTEGER;
       TYPE typ_tab_doctpchq IS TABLE OF INTEGER INDEX BY PLS_INTEGER;
       TYPE typ_tab_cheques IS TABLE OF typ_reg_cheques INDEX BY VARCHAR2(30);

       --Definicao das tabelas de memoria
       vr_tab_crawtot  typ_tab_crawtot;
       vr_tab_crapass  typ_tab_crapass;
       vr_tab_craptab  typ_tab_craptab;
       vr_tab_craptrf  typ_tab_doctpchq;
       vr_tab_doctpchq typ_tab_doctpchq;
       vr_tab_crapage  typ_tab_doctpchq;
       vr_tab_cheques  typ_tab_cheques;

       vr_log_nrdconta crapass.nrdconta%type;
       vr_log_dsdocmc7 crapcst.dsdocmc7%type;
       /* Cursores da rotina crps287 */

       -- Selecionar os dados da Cooperativa
       CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
         SELECT cop.cdcooper
               ,cop.nmrescop
               ,cop.nrtelura
               ,cop.cdbcoctl
               ,cop.cdagectl
               ,cop.dsdircop
               ,cop.nrctactl
               ,cop.vlmaxleg
         FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
       rw_crapcop cr_crapcop%ROWTYPE;
       --Registro do tipo calendario
       rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

       --Selecionar os associados da cooperativa para loop final
       CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
         SELECT /*+ INDEX (crapass crapass##crapass6) */
                crapass.cdagenci
               ,crapass.nrdconta
               ,crapass.nrcpfcgc
               ,crapass.nmprimtl
               ,crapass.inpessoa
               ,crapass.cdsitdtl
         FROM crapass crapass
         WHERE crapass.cdcooper = pr_cdcooper;

       --Selecionar informacoes da agencia
       CURSOR cr_crapage (pr_cdcooper IN crapage.cdcooper%TYPE
                         ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
         SELECT  crapage.cdagenci
                ,crapage.nmresage
                ,crapage.cdbanchq
                ,crapage.cdcomchq
         FROM crapage crapage
         WHERE crapage.cdcooper = pr_cdcooper
         AND   crapage.cdagenci = pr_cdagenci;
       rw_crapage cr_crapage%ROWTYPE;

       --Selecionar todas as agencias da cooperativa
       CURSOR cr_crapage1 (pr_cdcooper IN crapage.cdcooper%TYPE) IS
         SELECT  crapage.cdagenci
                ,crapage.nmresage
                ,crapage.cdcomchq
         FROM crapage crapage
         WHERE crapage.cdcooper = pr_cdcooper;

       --Selecionar informacoes Custodia
       CURSOR cr_crapcst (pr_cdcooper  IN crapcst.cdcooper%type
                         ,pr_dtmvtolt  IN crapcst.dtlibera%type
                         ,pr_dtmvtopr  IN crapcst.dtlibera%type) IS
         SELECT /*+ INDEX (crapcst crapcst##crapcst3) */
                crapcst.nrdocmto
               ,crapcst.nrdconta
               ,crapcst.dtmvtolt
               ,crapcst.cdagenci
               ,crapcst.cdbccxlt
               ,crapcst.nrdolote
               ,crapcst.inchqcop
               ,crapcst.vlcheque
               ,crapcst.insitchq
               ,crapcst.cdbanchq
               ,crapcst.cdagechq
               ,crapcst.dsdocmc7
               ,crapcst.nrctachq
               ,crapcst.cdcmpchq
               ,crapcst.dtdevolu
               ,crapcst.dtlibera
               ,crapcst.ROWID
               ,Count(1) OVER (PARTITION BY crapcst.nrdconta) qtdreg
               ,Row_Number() OVER (PARTITION BY crapcst.nrdconta
                                   ORDER BY crapcst.nrdconta) nrseqreg
         FROM crapcst
         WHERE crapcst.cdcooper  = pr_cdcooper
         AND   crapcst.dtlibera  > pr_dtmvtolt
         AND   crapcst.dtlibera  <= pr_dtmvtopr

      --   AND   crapcst.nrborder = 0; -- cheque nao descontado 

		 AND  (crapcst.dtdevolu IS NOT NULL OR
                (crapcst.dtdevolu IS NULL  AND
                   --Ignorar cheques descontados
                   NOT EXISTS (SELECT 1
                                 FROM crapcdb cdb
                                WHERE cdb.cdcooper = crapcst.cdcooper
                                  AND cdb.nrdconta = crapcst.nrdconta
                                  AND cdb.dtlibera = crapcst.dtlibera
                                  AND cdb.dtlibbdc IS NOT NULL
                                  AND cdb.cdcmpchq = crapcst.cdcmpchq
                                  AND cdb.cdbanchq = crapcst.cdbanchq
                                  AND cdb.cdagechq = crapcst.cdagechq
                                  AND cdb.nrctachq = crapcst.nrctachq
                                  AND cdb.nrcheque = crapcst.nrcheque
                                  AND cdb.dtdevolu IS NULL)));


       rw_crapcst cr_crapcst%ROWTYPE;

       --Selecionar informacoes Custodia para relatório
       CURSOR cr_crapcst1 (pr_cdcooper IN crapcst.cdcooper%type
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%type
                          ,pr_dtmvtoan IN crapdat.dtmvtoan%type) IS
         SELECT /*+ INDEX (crapcst crapcst##crapcst6) */
                crapcst.nrdconta
               ,crapcst.inchqcop
               ,crapcst.insitchq
               ,crapcst.vlcheque
               ,crapcst.dtdevolu
               ,crapcst.dtlibera
               ,crapcst.dtmvtolt
         FROM crapcst crapcst
         WHERE crapcst.cdcooper  = pr_cdcooper
          AND  crapcst.nrborder  = 0 -- cheque nao descontado 
          AND (crapcst.dtdevolu >= pr_dtmvtolt OR
               crapcst.dtlibera >  pr_dtmvtoan OR
               crapcst.dtmvtolt <= pr_dtmvtolt);

       --Selecionar transferencias
       CURSOR cr_craptrf (pr_cdcooper IN craptrf.cdcooper%type
                         ,pr_tptransa IN craptrf.tptransa%type) IS
         SELECT  craptrf.nrdconta
                ,craptrf.nrsconta
         FROM craptrf
         WHERE  craptrf.cdcooper = pr_cdcooper
         AND    craptrf.tptransa = pr_tptransa
         ORDER BY craptrf.progress_recid ASC;
       --Buscar informacoes de lote
       CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                         ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                         ,pr_cdagenci IN craplot.cdagenci%TYPE
                         ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                         ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
         SELECT  craplot.nrdolote
                ,craplot.nrseqdig
                ,craplot.cdbccxlt
                ,craplot.tpdmoeda
                ,craplot.cdoperad
                ,craplot.tplotmov
                ,craplot.qtcompln
                ,craplot.cdagenci
                ,craplot.dtmvtolt
                ,craplot.vlinfocr
                ,craplot.vlcompcr
                ,craplot.qtinfoln
                ,craplot.rowid
         FROM craplot craplot
         WHERE craplot.cdcooper = pr_cdcooper
         AND   craplot.dtmvtolt = pr_dtmvtolt
         AND   craplot.cdagenci = pr_cdagenci
         AND   craplot.cdbccxlt = pr_cdbccxlt
         AND   craplot.nrdolote = pr_nrdolote;
       rw_craplot cr_craplot%ROWTYPE;

       --Selecionar parametros da conta
       CURSOR cr_craptab (pr_cdcooper IN craptab.cdcooper%type
                         ,pr_nmsistem IN craptab.nmsistem%type
                         ,pr_tptabela IN craptab.tptabela%type
                         ,pr_cdempres IN craptab.cdempres%type
                         ,pr_tpregist IN craptab.tpregist%type) IS
         SELECT craptab.cdacesso
               ,craptab.dstextab
         FROM craptab
         WHERE craptab.cdcooper = pr_cdcooper
         AND   UPPER(craptab.nmsistem) = pr_nmsistem
         AND   UPPER(craptab.tptabela) = pr_tptabela
         AND   craptab.cdempres = pr_cdempres
         AND   craptab.tpregist = pr_tpregist;

       --Registro do tipo lancamento
       rw_craplcm craplcm%ROWTYPE;

       --Variaveis Locais
       vr_tab_vlchqmai NUMBER;
       vr_tab_incrdcta INTEGER;
       vr_nrdconta     INTEGER;
       vr_nrdocmto     INTEGER;
       vr_nmprimtl     VARCHAR2(100);
       vr_dsbloqueio   VARCHAR2(20);
       vr_flgbloqu     BOOLEAN;
       vr_flgsair      BOOLEAN;
       vr_flgcraplot   BOOLEAN:= FALSE;
       vr_tot_qtproces INTEGER:= 0;
       vr_tot_qtresgat INTEGER:= 0;
       vr_tot_qtchqcrh INTEGER:= 0;
       vr_tot_qtchqmai INTEGER:= 0;
       vr_tot_qtchqmen INTEGER:= 0;
       vr_tot_qtchqfpr INTEGER:= 0;
       vr_tot_qtchcomp INTEGER:= 0;
       vr_tot_qtcontra INTEGER:= 0;
       vr_tot_qtdescon INTEGER:= 0;
       vr_cop_qtchqcop INTEGER:= 0;
       vr_cop_qtchqban INTEGER:= 0;
       vr_cop_qtchqdev INTEGER:= 0;
       vr_cop_qtcheque INTEGER:= 0;
       vr_cop_qtcredit INTEGER:= 0;
       vr_cop_qtsldant INTEGER:= 0;
       vr_cop_qtlibera INTEGER:= 0;
       vr_cop_qtdeschq INTEGER:= 0;
       vr_ass_qtchqcop INTEGER:= 0;
       vr_ass_qtchqban INTEGER:= 0;
       vr_ass_qtchqdev INTEGER:= 0;
       vr_ass_qtcheque INTEGER:= 0;
       vr_ass_qtcredit INTEGER:= 0;
       vr_ass_qtsldant INTEGER:= 0;
       vr_ass_qtlibera INTEGER:= 0;
       vr_ass_qtdeschq INTEGER:= 0;
       vr_tot_qtchqcop INTEGER:= 0;
       vr_tot_qtchqban INTEGER:= 0;
       vr_tot_qtchqdev INTEGER:= 0;
       vr_tot_qtcheque INTEGER:= 0;
       vr_tot_qtcredit INTEGER:= 0;
       vr_tot_qtsldant INTEGER:= 0;
       vr_tot_qtlibera INTEGER:= 0;
       vr_tot_qtdeschq INTEGER:= 0;
       vr_tot_vlproces NUMBER:= 0;
       vr_tot_vlresgat NUMBER:= 0;
       vr_tot_vlchqcrh NUMBER:= 0;
       vr_tot_vlchqmai NUMBER:= 0;
       vr_tot_vlchqmen NUMBER:= 0;
       vr_tot_vlchqfpr NUMBER:= 0;
       vr_tot_vlchcomp NUMBER:= 0;
       vr_tot_vlcontra NUMBER:= 0;
       vr_tot_vldescon NUMBER:= 0;
       vr_cop_vlchqcop NUMBER:= 0;
       vr_cop_vlchqban NUMBER:= 0;
       vr_cop_vlchqdev NUMBER:= 0;
       vr_cop_vlcheque NUMBER:= 0;
       vr_cop_vlcredit NUMBER:= 0;
       vr_cop_vlsldant NUMBER:= 0;
       vr_cop_vllibera NUMBER:= 0;
       vr_cop_vldeschq NUMBER:= 0;
       vr_ass_vlchqcop NUMBER:= 0;
       vr_ass_vlchqban NUMBER:= 0;
       vr_ass_vlchqdev NUMBER:= 0;
       vr_ass_vlcheque NUMBER:= 0;
       vr_ass_vlcredit NUMBER:= 0;
       vr_ass_vlsldant NUMBER:= 0;
       vr_ass_vllibera NUMBER:= 0;
       vr_ass_vldeschq NUMBER:= 0;
       vr_tot_vlchqcop NUMBER:= 0;
       vr_tot_vlchqban NUMBER:= 0;
       vr_tot_vlchqdev NUMBER:= 0;
       vr_tot_vlcheque NUMBER:= 0;
       vr_tot_vlcredit NUMBER:= 0;
       vr_tot_vlsldant NUMBER:= 0;
       vr_tot_vllibera NUMBER:= 0;
       vr_tot_vldeschq NUMBER:= 0;
       vr_dtlibchq     DATE;
       vr_tpcheque     INTEGER;
       vr_descrica     VARCHAR2(200);
       vr_cdhistor     INTEGER;
       vr_res_dschqcop VARCHAR2(29);
       vr_cdpesqbb     VARCHAR2(200);
       vr_cdprogra     VARCHAR2(10);
       vr_cdcritic     INTEGER;

       --Variaveis de Controle de Restart
       vr_nrctares  INTEGER:= 0;
       vr_inrestar  INTEGER:= 0;
       vr_dsrestar  crapres.dsrestar%TYPE;

       --Variavel usada para montar o indice da tabela de memoria
       vr_index_cheques VARCHAR2(30);
       vr_index_docmto  VARCHAR2(30);
       vr_index_crawtot VARCHAR2(10);

	     -- Vari?vel para armazenar as informa??es em XML
       vr_des_xml     CLOB;
       vr_nom_direto  VARCHAR2(100);
       vr_nom_arquivo VARCHAR2(100);

       --Variaveis para retorno de erro
       vr_des_erro        VARCHAR2(4000);
       vr_dstextab_cheque craptab.dstextab%TYPE;
       vr_tab_erro        GENE0001.typ_tab_erro;

       --Variaveis de Excecao
       vr_exc_erro  EXCEPTION;
       vr_exc_pula  EXCEPTION;   

       --Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_tabela IS
       BEGIN
         vr_tab_crawtot.DELETE;
         vr_tab_crapass.DELETE;
         vr_tab_craptab.DELETE;
         vr_tab_craptrf.DELETE;
         vr_tab_doctpchq.DELETE;
         vr_tab_crapage.DELETE;
         vr_tab_cheques.DELETE;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_des_erro:= 'Erro ao limpar tabelas de mem?ria. Rotina pc_crps287.pc_limpa_tabela. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_erro;
       END;

	     --Escrever no arquivo CLOB
	     PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
       BEGIN
         --Escrever no arquivo XML
         dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
       END;

	   -- Gerar LOG
	   PROCEDURE pc_log IS
     BEGIN
        -- ..........................................................................
        --
        --  Programa : pc_log
        --  Sistema : Conta-Corrente - Cooperativa de Credito
        --  Sigla    : CRED
        --  Autor    : Cesar Belli - Envolti
        --  Data     : Junho/2017              Ultima atualizacao: 06/06/2017
        --
        --  Dados referentes ao programa:
        --
        --  Frequencia: Sempre que for chamado
        --  Objetivo  : Gravar tabelas de logs TBEGN_PRGLOG e TBGEN_PRGLOG_OCORRENCIA
        --              conforme parâmetros
        -- ...........................................................................
        --          
       DECLARE
         vr_modulo           VARCHAR2   (100);
         vr_acao             VARCHAR2   (100);            
         vr_nmarqlog         VARCHAR2  (4000) := NULL;    
         vr_dstpocorrencia   varchar2  (4000);
         vr_des_log          varchar2  (4000);  
         vr_tpocorrencia     number       (5) := null; 
         vr_cdretorno        crapcri.cdcritic%TYPE;
         vr_dsretorno        crapcri.dscritic%TYPE;
         vr_idprglog         tbgen_prglog.idprglog%TYPE := 0;  
         pr_tab_crapcri      cecred.gene0001.typ_tab_crapcri;
         --
       BEGIN          
         --
         vr_tpocorrencia := 1; -- 1 erro de negócio
         IF vr_cdcritic > 0 THEN
            BEGIN
              -- Falta buscar vr_tpocorrencia  
              cecred.gene0001.pc_le_crapcri(
                                pr_cdcritic    => vr_cdcritic,
                                pr_tab_crapcri => pr_tab_crapcri,
                                pr_cdretorno   => vr_cdretorno,
                                pr_dsretorno   => vr_dsretorno);
                                                                      
              IF vr_cdretorno = 1 THEN
                 --Se possui erro na tabela erros
                 IF pr_tab_crapcri.Count > 0 THEN        
                     vr_tpocorrencia := pr_tab_crapcri(pr_tab_crapcri.first).tpcritic;
                 END IF;
              END IF;                           
              vr_tpocorrencia := NVL(vr_tpocorrencia,1);
            EXCEPTION
              WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('PC_CRPS287 - PC_LOG - gene0001.pc_le_crapcri' 
                || ' , vr_des_erro=' || vr_des_erro
                || ' , vr_cdcritic=' || vr_cdcritic
                 ); 
                DBMS_OUTPUT.PUT_LINE('PC_CRPS287 - PC_LOG - 1 - Verificar essa saida com erro=' || sqlerrm); 
                vr_tpocorrencia := 0;
            END;       
         END IF;
   
         if vr_tpocorrencia in (3, 4) then
                vr_dstpocorrencia := 'ALERTA: '; -- 4 mensagem
         elsif vr_tpocorrencia in (1, 2) then
                vr_dstpocorrencia := 'ERRO: '; -- 1 erro de negócio 
         else
                vr_dstpocorrencia := 'ALERTA: '; -- 4 mensagem
         end if;
         
         DBMS_APPLICATION_INFO.read_module(module_name => vr_modulo, action_name => vr_acao);
                           
         vr_des_log := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra 
         || ' --> ' 
         || vr_dstpocorrencia
         ||' Cta: '||vr_log_nrdconta||' - CMC7: '||vr_log_dsdocmc7||' - '
         || vr_des_erro                                  
         || ' - Module: ' || vr_modulo || ' - Action: ' || vr_acao;

         BEGIN
           cecred.pc_log_programa(
           pr_dstiplog      => 'O',              -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
           pr_cdprograma    => vr_cdprogra,      -- tbgen_prglog
           pr_cdcooper      => pr_cdcooper,      -- tbgen_prglog
           pr_tpexecucao    => 1,                -- tbgen_prglog  DEFAULT 1 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
           pr_tpocorrencia  => vr_tpocorrencia,  -- tbgen_prglog_ocorrencia
           pr_cdcriticidade => 0,                -- tbgen_prglog_ocorrencia DEFAULT 0 -- Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
           pr_dsmensagem    => vr_des_log,       -- tbgen_prglog_ocorrencia
           pr_flgsucesso    => 1,                -- tbgen_prglog  DEFAULT 1 -- Indicador de sucesso da execução
           pr_nmarqlog      => vr_nmarqlog,
           pr_idprglog      => vr_idprglog
           );
         EXCEPTION
           WHEN OTHERS THEN
             DBMS_OUTPUT.PUT_LINE('PC_CRPS287 - PC_LOG - cecred.pc_log_programa' 
             || ' , vr_des_log= '  || vr_des_log
             || ' , pr_cdcooper= ' || pr_cdcooper
             || ' , vr_cdcritic= ' || vr_cdcritic); 
             DBMS_OUTPUT.PUT_LINE('PC_CRPS287 - PC_LOG - 3 Verificar essa saida com erro=' || sqlerrm);
         END;
               
       EXCEPTION
           WHEN OTHERS THEN
             DBMS_OUTPUT.PUT_LINE('PC_CRPS287 - PC_LOG' 
             || ' , vr_des_erro= ' || vr_des_erro
             || ' , pr_cdcooper= ' || pr_cdcooper
             || ' , vr_cdcritic= ' || vr_cdcritic); 
             DBMS_OUTPUT.PUT_LINE('PC_CRPS287 - PC_LOG - Final - Verificar essa saida com erro=' || sqlerrm);                   
       END;
     END pc_log;
     --

     ---------------------------------------
     -- Inicio Bloco Principal pc_crps287
     ---------------------------------------
     BEGIN

       --Atribuir o nome do programa que est? executando
       vr_cdprogra:= 'CRPS287';

       -- Incluir nome do m?dulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS287'
                                 ,pr_action => NULL);

       -- Validacoes iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 1
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_cdcritic => vr_cdcritic);

       --Se retornou critica aborta programa
       IF vr_cdcritic <> 0 THEN
         --Sair do programa
         RAISE vr_exc_erro;
       END IF;

       -- Verifica se a cooperativa esta cadastrada
       OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapcop INTO rw_crapcop;
       -- Se n?o encontrar
       IF cr_crapcop%NOTFOUND THEN
         -- Fechar o cursor pois haver? raise
         CLOSE cr_crapcop;
         -- Montar mensagem de critica
         vr_cdcritic:= 651;
         vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_erro;
       ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
       END IF;

       -- Verifica se a data esta cadastrada
       OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
       -- Se n?o encontrar
       IF BTCH0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois haver? raise
         CLOSE BTCH0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic:= 1;
         vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_erro;
       ELSE
         -- Apenas fechar o cursor
         CLOSE BTCH0001.cr_crapdat;
       END IF;

       --Descricao Cheque Cooperativa
       vr_res_dschqcop:= 'CHEQUES '|| SUBSTR(rw_crapcop.nmrescop,1,20)||':';

       -- Os lotes criados sao sempre na agencia 1. Entao se a agencia ja estiver operando com
       -- a nossa IF sera o historico 881 senao continua usando o 357 que e Bancoob
       OPEN cr_crapage (pr_cdcooper => pr_cdcooper
                       ,pr_cdagenci => 1);
       --Posicionar no proximo registro
       FETCH cr_crapage INTO rw_crapage;
       --Se encontrar
       IF cr_crapage%FOUND AND rw_crapage.cdbanchq = rw_crapcop.cdbcoctl THEN
         --historico
         vr_cdhistor:= 881;
       ELSE
         vr_cdhistor:= 357;
       END IF;
       --Fechar Cursor
       CLOSE cr_crapage;

       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       --Carregar tabela memoria agencias cheque
       FOR rw_crapage1 IN cr_crapage1 (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapage(rw_crapage1.cdagenci):= rw_crapage1.cdcomchq;
       END LOOP;

       --Carregar tabela memoria associados
       FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapass(rw_crapass.nrdconta).cdsitdtl:= rw_crapass.cdsitdtl;
         vr_tab_crapass(rw_crapass.nrdconta).nmprimtl:= rw_crapass.nmprimtl;
       END LOOP;

       --Carregar tabela memoria parametros conta
       FOR rw_craptab IN cr_craptab (pr_cdcooper => pr_cdcooper
                                    ,pr_nmsistem => 'CRED'
                                    ,pr_tptabela => 'CUSTOD'
                                    ,pr_cdempres => 0
                                    ,pr_tpregist => 0) LOOP
         vr_tab_craptab(To_Number(rw_craptab.cdacesso)):= rw_craptab.dstextab;
       END LOOP;

       --Carregar tabela memoria transferencias
       FOR rw_craptrf IN cr_craptrf (pr_cdcooper => pr_cdcooper
                                    ,pr_tptransa => 1) LOOP
         IF NOT vr_tab_craptrf.EXISTS (rw_craptrf.nrdconta) THEN
           vr_tab_craptrf(rw_craptrf.nrdconta):= rw_craptrf.nrsconta;
         END IF;
       END LOOP;

       --Buscar parametro maiores cheques
       vr_dstextab_cheque:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                      ,pr_nmsistem => 'CRED'
                                                      ,pr_tptabela => 'USUARI'
                                                      ,pr_cdempres => 11
                                                      ,pr_cdacesso => 'MAIORESCHQ'
                                                      ,pr_tpregist => 1);
       --Se nao encontrou
       IF vr_dstextab_cheque IS NULL THEN
         -- Montar mensagem de critica
         vr_cdcritic:= 55;
         vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         vr_des_erro:= vr_des_erro||' CRED-USUARI-11-MAIORESCHQ-001';
         RAISE vr_exc_erro;
       ELSE
         --Valor maior cheque
         vr_tab_vlchqmai:= TO_NUMBER(SUBSTR(vr_dstextab_cheque,1,15));
       END IF;

       /* Tratamento e retorno de valores de restart */
       BTCH0001.pc_valida_restart(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_flgresta => pr_flgresta
                                 ,pr_nrctares => vr_nrctares
                                 ,pr_dsrestar => vr_dsrestar
                                 ,pr_inrestar => vr_inrestar
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_des_erro => vr_des_erro);
       --Se ocrreu erro na validacao do restart
       IF vr_des_erro IS NOT NULL THEN
         --Levantar Excecao
         RAISE vr_exc_erro;
       END IF;

       -- Busca do diret?rio base da cooperativa
       vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
       --Determinar o nome do arquivo que ser? gerado
       vr_nom_arquivo := 'crrl234';

       -- Inicializar o CLOB
       dbms_lob.createtemporary(vr_des_xml, TRUE);
       dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

       -- Inicilizar as informa??es do XML
       pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl234><contas dtmvtopr="'||
                      to_char(rw_crapdat.dtmvtopr,'DD/MM/RRRR')||'">');

       --Inicializar flag lote
       vr_flgcraplot:= FALSE;

       --Identificacao do loop para permitir Continue
        <<loop_crapcst>>
       --Selecionar Custodias
       FOR rw_crapcst IN cr_crapcst (pr_cdcooper  => pr_cdcooper
                                    ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                    ,pr_dtmvtopr  => rw_crapdat.dtmvtopr ) LOOP
         BEGIN
           vr_log_nrdconta := rw_crapcst.nrdconta;
           vr_log_dsdocmc7 := rw_crapcst.dsdocmc7;

           --Criar ponto de restauracao
           SAVEPOINT sv_crapcst;
           ---------------------------------------------
           -- FIRST-OF
           ---------------------------------------------
           --Se for primeiro registro da conta (first-of)
           IF rw_crapcst.nrseqreg = 1 THEN
             --Documento esta preenchido
             IF rw_crapcst.nrdocmto > 0 THEN
               vr_nrdocmto:= TO_NUMBER(vr_dsrestar);
             ELSE
               --Obtem numero randomico
               vr_nrdocmto:= Trunc(DBMS_RANDOM.Value(50000,99999));
             END IF;

             /********************************************************/
             /* Indices do array foram definidos com base nos tipos  */
             /* de depositos efetuados na rotina 51 do caixa on-line */
             /* Tipo 2 -> Cheque da cooperativa                      */
             /* Tipo 3 -> Cheque menor praca                         */
             /* Tipo 4 -> Cheque maior praca                         */
             /* Tipo 5 -> Cheque menor fora praca                    */
             /* Tipo 6 -> Cheque maior fora praca                    */
             /********************************************************/
             vr_tab_doctpchq(2):= vr_nrdocmto + 100000;
             vr_tab_doctpchq(3):= vr_nrdocmto + 200000;
             vr_tab_doctpchq(4):= vr_nrdocmto + 300000;
             vr_tab_doctpchq(5):= vr_nrdocmto + 400000;
             vr_tab_doctpchq(6):= vr_nrdocmto + 500000;

             --Numero da Conta
             vr_nrdconta:= rw_crapcst.nrdconta;
             --indicador Bloqueado
             vr_flgbloqu:= FALSE;
             --Codigo Critica
             vr_cdcritic:= 0;
             --Flag saida
             vr_flgsair:= FALSE;
             WHILE NOT vr_flgsair LOOP
               --Verificar se associado existe
               IF NOT vr_tab_crapass.EXISTS(vr_nrdconta) THEN
                 vr_cdcritic:= 9;
                 vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
               ELSE
                 IF vr_tab_crapass(vr_nrdconta).cdsitdtl IN (5,6,7,8) THEN
                   vr_cdcritic:= 695;
                   vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                   vr_des_erro:= vr_des_erro || gene0002.fn_mask_conta(vr_nrdconta);
                 ELSIF vr_tab_crapass(vr_nrdconta).cdsitdtl IN (2,4,5,6,7,8) THEN
                   --Verificar as transferencias
                   IF NOT vr_tab_craptrf.EXISTS(vr_nrdconta) THEN
                     vr_cdcritic:= 95;
                     vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                     vr_des_erro:= vr_des_erro || gene0002.fn_mask_conta(vr_nrdconta);
                     --Bloqueio
                     vr_flgbloqu:= TRUE;
                   ELSE
                     --Numero da conta encontrado
                     vr_nrdconta:= vr_tab_craptrf(vr_nrdconta);
                     vr_flgbloqu:= FALSE;
                     --Proximo registro loop
                     CONTINUE loop_crapcst;
                   END IF;
                 END IF;
               END IF;
               --Sair
               vr_flgsair:= TRUE;
             END LOOP;  --not vr_flg_sair

             --Se existir critica e nao for erro 95
             IF vr_cdcritic > 0 AND vr_cdcritic <> 95 THEN
               --Levantar Excecao
               RAISE vr_exc_erro;
             END IF;

             --Nome titular
             vr_nmprimtl:= vr_tab_crapass(vr_nrdconta).nmprimtl;
             --Zerar toalizadores da conta
             vr_tot_qtproces:= 0;
             vr_tot_vlproces:= 0;
             vr_tot_qtresgat:= 0;
             vr_tot_vlresgat:= 0;
             vr_tot_qtcontra:= 0;
             vr_tot_vlcontra:= 0;
             vr_tot_qtchqcrh:= 0;
             vr_tot_vlchqcrh:= 0;
             vr_tot_qtchqmai:= 0;
             vr_tot_vlchqmai:= 0;
             vr_tot_qtchqmen:= 0;
             vr_tot_vlchqmen:= 0;
             vr_tot_qtchqfpr:= 0;
             vr_tot_vlchqfpr:= 0;
             vr_tot_vlcredit:= 0;
             vr_tot_qtcredit:= 0;
             vr_tot_qtdescon:= 0;
             vr_tot_vldescon:= 0;
             vr_tot_qtchcomp:= 0;
             vr_tot_vlchcomp:= 0;

             --Encontrar parametro conta
             IF NOT vr_tab_craptab.EXISTS(vr_nrdconta) THEN
               vr_tab_incrdcta:= 1;
             ELSE
               vr_tab_incrdcta:= GENE0002.fn_char_para_number(SUBSTR(vr_tab_craptab(vr_nrdconta),05,01));
             END IF;
           END IF;  --(first-of)

           --Codigo Pesquisa
           vr_cdpesqbb:= TO_CHAR(rw_crapcst.dtmvtolt,'DD/MM/YYYY')|| '-'||
                         GENE0002.fn_mask(rw_crapcst.cdagenci,'999') ||'-'||
                         GENE0002.fn_mask(rw_crapcst.cdbccxlt,'999') ||'-'||
                         GENE0002.fn_mask(rw_crapcst.nrdolote,'999999');
           --Incrementar quantidade processos
           vr_tot_qtproces:= nvl(vr_tot_qtproces,0) + 1;
           --Acumular Valor Processo
           vr_tot_vlproces:= nvl(vr_tot_vlproces,0) + rw_crapcst.vlcheque;

           --Verificar se a agencia existe
           IF NOT vr_tab_crapage.EXISTS(rw_crapcst.cdagenci) THEN
             vr_cdcritic:= 0;
             vr_des_erro:= 'Agencia nao encontrada.';
             --Levantar Excecao
             RAISE vr_exc_erro;
           ELSE
             rw_crapage.cdagenci:= rw_crapcst.cdagenci;
             rw_crapage.cdcomchq:= vr_tab_crapage(rw_crapcst.cdagenci);
           END IF;

           --Verificar Situacao 0=Nao processado/2=processado
           IF rw_crapcst.insitchq IN (0,2,4) THEN
             --Cheque da cooperativa e nao processado
             IF rw_crapcst.inchqcop = 1 AND rw_crapcst.insitchq = 0 THEN
               --Montar Critica
               vr_cdcritic:= 684;
               vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
               --Levantar Excecao
               RAISE vr_exc_erro;
             ELSE
               --Incrementar total credito
               vr_tot_qtcredit:= Nvl(vr_tot_qtcredit,0) + 1;
               --Acumular total cheque
               vr_tot_vlcredit:= Nvl(vr_tot_vlcredit,0) + rw_crapcst.vlcheque;
               --Atualizar situacao cheque para processado
               BEGIN
                 UPDATE crapcst SET crapcst.insitchq = 2
                 WHERE crapcst.ROWID = rw_crapcst.ROWID;
               EXCEPTION
                 WHEN Others THEN
                   vr_cdcritic:= 0;
                   vr_des_erro:= 'Erro ao atualizar tabela crapcst. '||sqlerrm;
                   --Levantar Excecao
                   RAISE vr_exc_erro;
               END;
               --Se for cheque da cooperativa
               IF rw_crapcst.inchqcop = 1 THEN
                 --Incrementa Quantidade cheque
                 vr_tot_qtchqcrh:= Nvl(vr_tot_qtchqcrh,0) + 1;
                 --Incrementa Valor Cheque
                 vr_tot_vlchqcrh:= Nvl(vr_tot_vlchqcrh,0) + rw_crapcst.vlcheque;
                 --Atualizar documento cheque
                 BEGIN
                   UPDATE crapcst SET crapcst.nrdocmto = vr_tab_doctpchq(2)
                   WHERE crapcst.ROWID = rw_crapcst.ROWID;
                 EXCEPTION
                   WHEN Others THEN
                     vr_cdcritic:= 0;
                     vr_des_erro:= 'Erro ao atualizar tabela crapcst. '||sqlerrm;
                     --Levantar Excecao
                     RAISE vr_exc_erro;
                 END;
               ELSE

                 --Incrementa cheques compensados
                 vr_tot_qtchcomp:= Nvl(vr_tot_qtchcomp,0) + 1;
                 --Incrementa valor cheques compensados
                 vr_tot_vlchcomp:= Nvl(vr_tot_vlchcomp,0) + rw_crapcst.vlcheque;
                 --Limpar tabela erros
                 vr_tab_erro.DELETE;
                 --Calcular Bloqueio Cheques
                 CCAF0001.pc_calcula_bloqueio_cheque (pr_cdcooper => rw_crapcop.cdcooper  --Codigo Cooperativa
                                                     ,pr_dtrefere => rw_crapdat.dtmvtopr  --Data Deposito Cheque
                                                     ,pr_cdagenci => rw_crapage.cdagenci  --Codigo Agencia
                                                     ,pr_cdbanchq => rw_crapcst.cdbanchq  --Codigo Banco cheque
                                                     ,pr_cdagechq => rw_crapcst.cdagechq  --Codigo Agencia cheque
                                                     ,pr_vlcheque => rw_crapcst.vlcheque  --Valor Cheque
                                                     ,pr_dstextab => vr_dstextab_cheque   --Parametro Maiores Cheques
                                                     ,pr_dtblqchq => vr_dtlibchq          --Data Liberacao Bloq. Cheque
                                                     ,pr_cdcritic => vr_cdcritic          --Codigo erro
                                                     ,pr_dscritic => vr_des_erro          --Descricao erro
                                                     ,pr_tab_erro => vr_tab_erro);        --Tabela de erros

                 --Se Ocorreu erro
                 IF vr_cdcritic IS NOT NULL OR vr_des_erro IS NOT NULL THEN
                   --Se possui erro na tabela erros
                   IF vr_tab_erro.Count > 0 THEN
                     
                      -- Ignora descrição não tratada pois ela foi montada - ch 665812
                      if vr_cdcritic <> 9999 then
                          vr_des_erro:= vr_tab_erro(vr_tab_erro.LAST).dscritic;
                      end if;
                   ELSE
                     vr_des_erro:= 'Erro no calculo do bloqueio do cheque.';
                   END IF;
                   --Complementar mensagem erro
                   vr_des_erro:= vr_des_erro || ' - nrdconta: '||rw_crapcst.nrdconta||
                                              ' ,cdbanchq: '||rw_crapcst.cdbanchq||
                                              ' ,cdagechq: '||rw_crapcst.cdagechq||
                                              ' ,nrctachq: '||rw_crapcst.nrctachq||
                                              ' ,dsdocmc7: '||rw_crapcst.dsdocmc7||
                                              ' ,vlcheque: '||To_Char(rw_crapcst.vlcheque,'999g999g999g990d00');
                   
                   --Escrever erro log
                   pc_log;
                                                                                  
                   --Continuar processamento com proximo registro
                   CONTINUE loop_crapcst;
                 END IF;
                 --Inclusão nome do módulo logado - Chamado 696499
                 gene0001.pc_set_modulo(pr_module => 'PC_CRPS287'
                                       ,pr_action => null);

                 /* RUN deposito-bloqueado. */

                 --Se Codigo Compensacao Cheque for o mesmo da agencia
                 IF rw_crapcst.cdcmpchq = rw_crapage.cdcomchq  THEN
                   /* Cheque praca */
                   IF rw_crapcst.vlcheque < vr_tab_vlchqmai THEN
                     vr_tpcheque:= 3;  /* Menor praca */
                   ELSE
                     vr_tpcheque:= 4;  /* Maior praca */
                   END IF;
                 ELSE
                   /* Cheque fora praca */
                   IF rw_crapcst.vlcheque < vr_tab_vlchqmai  THEN
                     vr_tpcheque:= 5;  /* Menor fora praca */
                   ELSE
                     vr_tpcheque:= 6;  /* Maior fora praca */
                   END IF;
                 END IF;
                 --Montar Indice para tabela memoria cheques
                 vr_index_cheques:= LPad(vr_nrdconta,10,'0')||
                                    LPad(vr_tpcheque,10,'0')||
                                    To_Char(vr_dtlibchq,'YYYYMMDD');
                 --Verificar se o cheque ja existe
                 IF NOT vr_tab_cheques.EXISTS(vr_index_cheques) THEN

                   /*************************************************************/
                   /* Se ja existe cheque bloqueado para o tipo de cheque mas   */
                   /* para uma data de liberacao diferente incrementa documento */
                   /* pois os lancamentos sao gerados por data de liberacao.    */
                   /*************************************************************/

                   --Percorrer tabela memoria procurando pela conta e documento em outra data
                   vr_index_docmto:= vr_tab_cheques.FIRST;
                   WHILE vr_index_docmto IS NOT NULL LOOP
                     --Verificar conta e cheque
                     IF vr_tab_cheques(vr_index_docmto).nrdconta = vr_nrdconta AND
                       vr_tab_cheques(vr_index_docmto).nrdocmto = vr_tpcheque THEN
                       --Incrementar documentos por tipo cheque
                       vr_tab_doctpchq(vr_tpcheque):= nvl(vr_tab_doctpchq(vr_tpcheque),0) + 1;
                       --Sair Loop
                       vr_index_docmto:= NULL;
                     ELSE
                       --Encontrar proximo registro
                       vr_index_docmto:= vr_tab_cheques.NEXT(vr_index_docmto);
                     END IF;
                   END LOOP;
                   --Criar Cheque
                   vr_tab_cheques(vr_index_cheques).nrdconta:= vr_nrdconta;
                   vr_tab_cheques(vr_index_cheques).nrdocmto:= vr_tpcheque;
                   vr_tab_cheques(vr_index_cheques).dtlibera:= vr_dtlibchq;
                   vr_tab_cheques(vr_index_cheques).nrdeposi:= vr_tab_doctpchq(vr_tpcheque);
                   vr_tab_cheques(vr_index_cheques).vlcompel:= rw_crapcst.vlcheque;
                   vr_tab_cheques(vr_index_cheques).qtcheque:= 1;
                 ELSE
                   --Incrementar valor compensado e quantidade cheques
                   vr_tab_cheques(vr_index_cheques).vlcompel:= Nvl(vr_tab_cheques(vr_index_cheques).vlcompel,0) + rw_crapcst.vlcheque;
                   vr_tab_cheques(vr_index_cheques).qtcheque:= Nvl(vr_tab_cheques(vr_index_cheques).qtcheque,0) + 1;
                 END IF;
                 --Atualizar Custodia
                 BEGIN
                   UPDATE crapcst SET crapcst.nrdocmto = vr_tab_cheques(vr_index_cheques).nrdeposi
                   WHERE crapcst.ROWID = rw_crapcst.ROWID;
                 EXCEPTION
                   WHEN Others THEN
                     vr_cdcritic:= 0;
                     vr_des_erro:= 'Erro ao atualizar tabela crapcst. '||sqlerrm;
                     --Levantar Excecao
                     RAISE vr_exc_erro;
                 END;
               END IF;
             END IF;
           ELSIF rw_crapcst.insitchq = 1 THEN
             --Diminuir quantidade resgates
             vr_tot_qtresgat:= Nvl(vr_tot_qtresgat,0) - 1;
             --Diminuir valor resgatado
             vr_tot_vlresgat:= Nvl(vr_tot_vlresgat,0) - rw_crapcst.vlcheque;
           ELSIF rw_crapcst.insitchq = 3 THEN
             --Diminuir quantidade contra ordem
             vr_tot_qtcontra:= Nvl(vr_tot_qtcontra,0) - 1;
             --Diminuir valor contra ordem
             vr_tot_vlcontra:= Nvl(vr_tot_vlcontra,0) - rw_crapcst.vlcheque;
           ELSIF rw_crapcst.insitchq = 5 THEN
             --Diminuir quantidade descontado
             vr_tot_qtdescon:= Nvl(vr_tot_qtdescon,0) - 1;
             --Diminuir valor descontado
             vr_tot_vldescon:= Nvl(vr_tot_vldescon,0) - rw_crapcst.vlcheque;
           END IF;

           ---------------------------------------------
           -- LAST-OF
           ---------------------------------------------
           --Se for o ultimo registro da conta (last-of)
           IF rw_crapcst.qtdreg = rw_crapcst.nrseqreg THEN
             --Verificar se a conta esta bloqueada
             IF vr_flgbloqu THEN
               vr_dsbloqueio:= '(CONTA BLOQUEADA)';
             ELSE
               vr_dsbloqueio:= NULL;
             END IF;
             --Montar tag da conta para arquivo XML
             pc_escreve_xml
             ('<conta>
                <cta_nrdconta>'||GENE0002.fn_mask_conta(vr_nrdconta)||'</cta_nrdconta>
                <cta_nmprimtl>'||vr_nmprimtl||'</cta_nmprimtl>
                <cta_flgbloqu>'||vr_dsbloqueio||'</cta_flgbloqu>
                <cta_tot_qtproces>'||vr_tot_qtproces||'</cta_tot_qtproces>
                <cta_tot_vlproces>'||vr_tot_vlproces||'</cta_tot_vlproces>
                <cta_tot_qtresgat>'||vr_tot_qtresgat||'</cta_tot_qtresgat>
                <cta_tot_vlresgat>'||vr_tot_vlresgat||'</cta_tot_vlresgat>
                <cta_tot_qtcontra>'||vr_tot_qtcontra||'</cta_tot_qtcontra>
                <cta_tot_vlcontra>'||vr_tot_vlcontra||'</cta_tot_vlcontra>
                <cta_tot_qtdescon>'||vr_tot_qtdescon||'</cta_tot_qtdescon>
                <cta_tot_vldescon>'||vr_tot_vldescon||'</cta_tot_vldescon>
                <cta_res_dschqcop>'||vr_res_dschqcop||'</cta_res_dschqcop>
                <cta_tot_qtchqcrh>'||vr_tot_qtchqcrh||'</cta_tot_qtchqcrh>
                <cta_tot_vlchqcrh>'||vr_tot_vlchqcrh||'</cta_tot_vlchqcrh>');

             --Criar indice para registro total
             vr_index_crawtot:= LPad(vr_nrdconta,10,'0');
             --Criar registro total
             vr_tab_crawtot(vr_index_crawtot).dtmvtolt:= rw_crapdat.dtmvtolt;
             vr_tab_crawtot(vr_index_crawtot).nrdconta:= vr_nrdconta;
             vr_tab_crawtot(vr_index_crawtot).qtproces:= vr_tot_qtproces;
             vr_tab_crawtot(vr_index_crawtot).vlproces:= vr_tot_vlproces;
             vr_tab_crawtot(vr_index_crawtot).qtresgat:= vr_tot_qtresgat + vr_tot_qtdescon;
             vr_tab_crawtot(vr_index_crawtot).vlresgat:= vr_tot_vlresgat + vr_tot_vldescon;
             vr_tab_crawtot(vr_index_crawtot).qtcredit:= vr_tot_qtcredit;
             vr_tab_crawtot(vr_index_crawtot).vlcredit:= vr_tot_vlcredit;
             vr_tab_crawtot(vr_index_crawtot).qtcontra:= vr_tot_qtcontra;
             vr_tab_crawtot(vr_index_crawtot).vlcontra:= vr_tot_vlcontra;

             pc_escreve_xml('<descricoes>');
             --Percorrer tabela memoria procurando pela conta
             vr_index_docmto:= vr_tab_cheques.FIRST;
             WHILE vr_index_docmto IS NOT NULL LOOP
               --Verificar conta
               IF vr_tab_cheques(vr_index_docmto).nrdconta = vr_nrdconta THEN
                 --Verificar numero documento para determinar descricao
                 CASE vr_tab_cheques(vr_index_docmto).nrdocmto
                   WHEN 3 THEN vr_descrica:= '     CHEQUES MENOR PRACA:';
                   WHEN 4 THEN vr_descrica:= '     CHEQUES MAIOR PRACA:';
                   WHEN 5 THEN vr_descrica:= 'CHEQUES MENOR FORA PRACA:';
                   WHEN 6 THEN vr_descrica:= 'CHEQUES MAIOR FORA PRACA:';
                   ELSE NULL;
                 END CASE;

                 --Escrever linha descricao no relatorio

                 pc_escreve_xml
                 ('<descricao>
                   <descrica>'||vr_descrica||'</descrica>
                   <qtcheque>'||To_Char(vr_tab_cheques(vr_index_docmto).qtcheque,'999g990')||'</qtcheque>
                   <vlcompel>'||trim(To_Char(vr_tab_cheques(vr_index_docmto).vlcompel,'99g999g999g990d00'))||'</vlcompel>
                   <dtlibera>'||To_Char(vr_tab_cheques(vr_index_docmto).dtlibera,'DD/MM/YYYY')||'</dtlibera>
                  </descricao>');
               END IF;
               --Encontrar proximo registro
               vr_index_docmto:= vr_tab_cheques.NEXT(vr_index_docmto);
             END LOOP;
             --Finalizar tag descricoes
             pc_escreve_xml('</descricoes>');
             --Mostrar total
             pc_escreve_xml
             ('<cta_tot_qtchcomp>'||To_Char(vr_tot_qtchcomp,'999g990')||'</cta_tot_qtchcomp>
               <cta_tot_vlchcomp>'||To_Char(vr_tot_vlchcomp,'99g999g999g990d00')||'</cta_tot_vlchcomp>
               <cta_tot_qtcredit>'||To_Char(vr_tot_qtcredit,'999g990')||'</cta_tot_qtcredit>
               <cta_tot_vlcredit>'||To_Char(vr_tot_vlcredit,'99g999g999g990d00')||'</cta_tot_vlcredit>
             ');
             --Finalizar tag totais
             pc_escreve_xml('</conta>');

             /* Creditar na conta */
             IF vr_tab_incrdcta = 1 AND vr_nrctares < rw_crapcst.nrdconta THEN
               --Se o lote nao existe
               IF vr_flgcraplot = FALSE THEN

                 /* Leitura do lote */
                 OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtopr
                                 ,pr_cdagenci => 1
                                 ,pr_cdbccxlt => 100
                                 ,pr_nrdolote => 4500);
                 --Posicionar no proximo registro
                 FETCH cr_craplot INTO rw_craplot;
                 --Se encontrou registro
                 IF cr_craplot%NOTFOUND THEN
                   --Criar lote
                   BEGIN
                     INSERT INTO craplot
                             (craplot.cdcooper
                             ,craplot.dtmvtolt
                             ,craplot.cdagenci
                             ,craplot.cdbccxlt
                             ,craplot.nrdolote
                             ,craplot.tpdmoeda
                             ,craplot.cdoperad
                             ,craplot.tplotmov)
                     VALUES  (pr_cdcooper
                             ,rw_crapdat.dtmvtopr
                             ,1
                             ,100
                             ,4500
                             ,1
                             ,'1'
                             ,1)
                     RETURNING
                          ROWID
                         ,craplot.dtmvtolt
                         ,craplot.cdagenci
                         ,craplot.cdbccxlt
                         ,craplot.nrdolote
                         ,craplot.tpdmoeda
                         ,craplot.cdoperad
                         ,craplot.tplotmov
                         ,craplot.nrseqdig
                     INTO rw_craplot.ROWID
                         ,rw_craplot.dtmvtolt
                         ,rw_craplot.cdagenci
                         ,rw_craplot.cdbccxlt
                         ,rw_craplot.nrdolote
                         ,rw_craplot.tpdmoeda
                         ,rw_craplot.cdoperad
                         ,rw_craplot.tplotmov
                         ,rw_craplot.nrseqdig;
                   EXCEPTION
                     WHEN Dup_Val_On_Index THEN
                       pr_cdcritic:= 0;
                       pr_dscritic:= 'Lote ja cadastrado.';
                       RAISE vr_exc_erro;
                     WHEN OTHERS THEN
                       pr_cdcritic:= 0;
                       pr_dscritic:= 'Erro ao inserir na tabela de lotes. '||sqlerrm;
                       RAISE vr_exc_erro;
                   END;
                 END IF;
                 --Fechar Cursor
                 CLOSE cr_craplot;
                 --Marcar que o lote existe
                 vr_flgcraplot:= TRUE;
               END IF; --vr_flgcraplot=FALSE

              --Se valor total cheques maior 0
               IF vr_tot_vlchqcrh > 0 THEN
                 --Criar Lancamento
                 BEGIN
                   INSERT INTO craplcm
                     (craplcm.dtmvtolt
                     ,craplcm.cdagenci
                     ,craplcm.cdbccxlt
                     ,craplcm.nrdolote
                     ,craplcm.nrdconta
                     ,craplcm.nrdctabb
                     ,craplcm.nrdctitg
                     ,craplcm.cdhistor
                     ,craplcm.nrseqdig
                     ,craplcm.nrdocmto
                     ,craplcm.vllanmto
                     ,craplcm.cdpesqbb
                     ,craplcm.cdcooper)
                  VALUES
                     (rw_craplot.dtmvtolt
                     ,rw_craplot.cdagenci
                     ,rw_craplot.cdbccxlt
                     ,rw_craplot.nrdolote
                     ,vr_nrdconta
                     ,vr_nrdconta
                     ,GENE0002.fn_mask(vr_nrdconta,'99999999')
                     ,356
                     ,Nvl(rw_craplot.nrseqdig,0) + 1
                     ,vr_tab_doctpchq(2)
                     ,vr_tot_vlchqcrh
                     ,' '
                     ,pr_cdcooper)
                   RETURNING craplcm.vllanmto
                   INTO      rw_craplcm.vllanmto;
                 EXCEPTION
                   WHEN Others THEN
                     vr_cdcritic:= 0;

                     vr_des_erro:= 'Erro ao inserir na tabela craplcm(1). '||sqlerrm;
                     --Levantar Excecao
                     RAISE vr_exc_erro;
                 END;
                 --Atualizar Lotes
                 BEGIN
                   UPDATE craplot SET craplot.vlinfocr = Nvl(craplot.vlinfocr,0) + rw_craplcm.vllanmto
                                   ,craplot.vlcompcr = Nvl(craplot.vlcompcr,0) + rw_craplcm.vllanmto
                                   ,craplot.qtinfoln = Nvl(craplot.qtinfoln,0) + 1
                                   ,craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
                                   ,craplot.nrseqdig = Nvl(craplot.nrseqdig,0) + 1
                   WHERE craplot.ROWID = rw_craplot.ROWID
                   RETURNING
                         craplot.nrseqdig
                        ,craplot.vlinfocr
                        ,craplot.vlcompcr
                        ,craplot.qtinfoln
                        ,craplot.qtcompln
                    INTO rw_craplot.nrseqdig
                        ,rw_craplot.vlinfocr
                        ,rw_craplot.vlcompcr
                        ,rw_craplot.qtinfoln
                        ,rw_craplot.qtcompln;
                 EXCEPTION
                   WHEN Others THEN
                     vr_cdcritic:= 0;
                     vr_des_erro:= 'Erro ao atualizar tabela lote. '||sqlerrm;
                     --Levantar Excecao
                     RAISE vr_exc_erro;
                 END;
               END IF;

               /* Cheques Praca e Fora Praca */

               --Percorrer tabela memoria procurando pela conta
               vr_index_docmto:= vr_tab_cheques.FIRST;
               WHILE vr_index_docmto IS NOT NULL LOOP
                 --Verificar conta
                 IF vr_tab_cheques(vr_index_docmto).nrdconta = vr_nrdconta THEN
                   --Criar Lancamento
                   BEGIN
                     INSERT INTO craplcm
                       (craplcm.dtmvtolt
                       ,craplcm.cdagenci
                       ,craplcm.cdbccxlt
                       ,craplcm.nrdolote
                       ,craplcm.nrdconta
                       ,craplcm.nrdctabb
                       ,craplcm.nrdctitg
                       ,craplcm.cdhistor
                       ,craplcm.nrseqdig
                       ,craplcm.nrdocmto
                       ,craplcm.vllanmto
                       ,craplcm.cdpesqbb
                       ,craplcm.cdcooper)
                     VALUES
                       (rw_craplot.dtmvtolt
                       ,rw_craplot.cdagenci
                       ,rw_craplot.cdbccxlt
                       ,rw_craplot.nrdolote
                       ,vr_nrdconta
                       ,vr_nrdconta
                       ,GENE0002.fn_mask(vr_nrdconta,'99999999')
                       ,vr_cdhistor
                       ,Nvl(rw_craplot.nrseqdig,0) + 1
                       ,vr_tab_cheques(vr_index_docmto).nrdeposi
                       ,vr_tab_cheques(vr_index_docmto).vlcompel
                       ,' '
                       ,pr_cdcooper)
                     RETURNING
                           craplcm.vllanmto
                          ,craplcm.nrdconta
                          ,craplcm.cdhistor
                          ,craplcm.nrdocmto
                          ,craplcm.dtmvtolt
                          ,craplcm.cdagenci
                          ,craplcm.cdbccxlt
                          ,craplcm.nrdolote
                          ,craplcm.vllanmto
                     INTO  rw_craplcm.vllanmto
                          ,rw_craplcm.nrdconta
                          ,rw_craplcm.cdhistor
                          ,rw_craplcm.nrdocmto
                          ,rw_craplcm.dtmvtolt
                          ,rw_craplcm.cdagenci
                          ,rw_craplcm.cdbccxlt
                          ,rw_craplcm.nrdolote
                          ,rw_craplcm.vllanmto;
                   EXCEPTION
                     WHEN Others THEN
                       vr_cdcritic:= 0;

                       vr_des_erro:= 'Erro ao inserir na tabela craplcm(2). '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_erro;
                   END;
                   --Atualizar Lotes
                   BEGIN
                     UPDATE craplot SET craplot.vlinfocr = Nvl(craplot.vlinfocr,0) + rw_craplcm.vllanmto
                                     ,craplot.vlcompcr = Nvl(craplot.vlcompcr,0) + rw_craplcm.vllanmto
                                     ,craplot.qtinfoln = Nvl(craplot.qtinfoln,0) + 1
                                     ,craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
                                     ,craplot.nrseqdig = Nvl(craplot.nrseqdig,0) + 1
                     WHERE craplot.ROWID = rw_craplot.ROWID
                     RETURNING
                           craplot.nrseqdig
                          ,craplot.vlinfocr
                          ,craplot.vlcompcr
                          ,craplot.qtinfoln
                          ,craplot.qtcompln
                      INTO rw_craplot.nrseqdig
                          ,rw_craplot.vlinfocr
                          ,rw_craplot.vlcompcr
                          ,rw_craplot.qtinfoln
                          ,rw_craplot.qtcompln;
                   EXCEPTION
                     WHEN Others THEN
                       vr_cdcritic:= 0;
                       vr_des_erro:= 'Erro ao atualizar tabela lote. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_erro;
                   END;
                   --Inserir tabela crapdpb
                   BEGIN
                     INSERT INTO crapdpb
                       (crapdpb.nrdconta
                       ,crapdpb.dtliblan
                       ,crapdpb.cdhistor
                       ,crapdpb.nrdocmto
                       ,crapdpb.dtmvtolt
                       ,crapdpb.cdagenci
                       ,crapdpb.cdbccxlt
                       ,crapdpb.nrdolote
                       ,crapdpb.vllanmto
                       ,crapdpb.inlibera
                       ,crapdpb.cdcooper)
                     VALUES
                       (rw_craplcm.nrdconta
                       ,vr_tab_cheques(vr_index_docmto).dtlibera
                       ,rw_craplcm.cdhistor
                       ,rw_craplcm.nrdocmto
                       ,rw_craplcm.dtmvtolt
                       ,rw_craplcm.cdagenci
                       ,rw_craplcm.cdbccxlt
                       ,rw_craplcm.nrdolote
                       ,rw_craplcm.vllanmto
                       ,1
                       ,pr_cdcooper);
                   EXCEPTION
                     WHEN Others THEN
                       vr_cdcritic:= 0;

                       vr_des_erro:= 'Erro ao inserir na tabela crapdpb. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_erro;
                   END;
                 END IF;
                 --Selecionar proximo registro tabela memoria
                 vr_index_docmto:= vr_tab_cheques.NEXT(vr_index_docmto);
               END LOOP;
             END IF;

             -- Atualizar restart se a flag estiver ativa
             IF pr_flgresta = 1 THEN
               BEGIN
                 --Atualizar tabela de restart
                 UPDATE crapres SET crapres.nrdconta = rw_crapcst.nrdconta
                                 ,crapres.dsrestar = vr_nrdocmto
                 WHERE crapres.cdcooper = pr_cdcooper
                 AND   crapres.cdprogra = vr_cdprogra;
               EXCEPTION
                 WHEN Others THEN
                   vr_cdcritic:= 0;
                   vr_des_erro:= 'Erro ao atualizar tabela crapres. '||sqlerrm;
                   --Levantar Excecao
                   RAISE vr_exc_erro;
               END;

               --Salvar Informações no banco
               COMMIT;
             END IF;
           END IF; --last-of nrdconta
         EXCEPTION
           WHEN vr_exc_erro THEN
             -- Gera log
             pc_log;
             ROLLBACK TO SAVEPOINT sv_crapcst;
             --Levantar Excecao
             --Nao executar raise e pular para o proximo cheque
             --RAISE vr_exc_erro;
         END;
       END LOOP;   --rw_crapcst

       --Fechar tag contas e abrir tag cheques liberados
       pc_escreve_xml('</contas><cheques_liberados>');
       --Percorrer tabela memoria crawtot
       vr_index_crawtot:= vr_tab_crawtot.FIRST;
       WHILE vr_index_crawtot IS NOT NULL LOOP
         --Mostrar total
         pc_escreve_xml
           ('<cta_lib>
               <nrdconta_lib>'||gene0002.fn_mask_conta(vr_tab_crawtot(vr_index_crawtot).nrdconta)||'</nrdconta_lib>
               <qtproces_lib>'||To_Char(vr_tab_crawtot(vr_index_crawtot).qtproces,'999g990')||'</qtproces_lib>
               <vlproces_lib>'||To_Char(vr_tab_crawtot(vr_index_crawtot).vlproces,'99g999g999g990d00')||'</vlproces_lib>
               <qtresgat_lib>'||To_Char(vr_tab_crawtot(vr_index_crawtot).qtresgat,'999g990')||'</qtresgat_lib>
               <vlresgat_lib>'||To_Char(vr_tab_crawtot(vr_index_crawtot).vlresgat,'99g999g999g990d00')||'</vlresgat_lib>
               <qtcontra_lib>'||To_Char(vr_tab_crawtot(vr_index_crawtot).qtcontra,'999g990')||'</qtcontra_lib>
               <vlcontra_lib>'||To_Char(vr_tab_crawtot(vr_index_crawtot).vlcontra,'99g999g999g990d00')||'</vlcontra_lib>
               <qtcredit_lib>'||To_Char(vr_tab_crawtot(vr_index_crawtot).qtcredit,'999g990')||'</qtcredit_lib>
               <vlcredit_lib>'||To_Char(vr_tab_crawtot(vr_index_crawtot).vlcredit,'99g999g999g990d00')||'</vlcredit_lib>
             </cta_lib>');

         --Selecionar proximo registro
         vr_index_crawtot:= vr_tab_crawtot.NEXT(vr_index_crawtot);
       END LOOP;
       --Fechar tag cheques liberados
       pc_escreve_xml('</cheques_liberados>');

       /*  Saldo contabil  */
       FOR rw_crapcst IN cr_crapcst1 (pr_cdcooper => pr_cdcooper
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_dtmvtoan => rw_crapdat.dtmvtoan) LOOP
         --Data devolucao < data movimento ou data liberacao <= movimento anterior ou
         --Data Deposito > Data movimento
         IF rw_crapcst.dtdevolu < rw_crapdat.dtmvtolt OR
            rw_crapcst.dtlibera <= rw_crapdat.dtmvtoan OR
            rw_crapcst.dtmvtolt >  rw_crapdat.dtmvtolt THEN
           --Proximo registro cursor
           CONTINUE;
         END IF;

         /*  Saldo COOPER  */
         IF rw_crapcst.nrdconta = 85448 THEN
           --Data Liberacao maior data movimento
           IF rw_crapcst.dtlibera > rw_crapdat.dtmvtolt AND
              rw_crapcst.dtdevolu IS NULL THEN
             IF rw_crapcst.inchqcop = 1 THEN
               --Incrementar qtd cheques cooperativa
               vr_cop_qtchqcop:= Nvl(vr_cop_qtchqcop,0) + 1;
               --Incrementar total cheques
               vr_tot_qtchqcop:= Nvl(vr_tot_qtchqcop,0) + 1;
               --Acumular valor cheque cooperativa
               vr_cop_vlchqcop:= Nvl(vr_cop_vlchqcop,0) + rw_crapcst.vlcheque;
               --Acumular total cheque cooperativa
               vr_tot_vlchqcop:= Nvl(vr_tot_vlchqcop,0) + rw_crapcst.vlcheque;
             ELSE
               --Incrementar quantidade cheque
               vr_cop_qtchqban:= Nvl(vr_cop_qtchqban,0) + 1;
               --Incrementar quantidade cheque banco
               vr_tot_qtchqban:= Nvl(vr_tot_qtchqban,0) + 1;
               --Acumular valor cheque banco
               vr_cop_vlchqban:= Nvl(vr_cop_vlchqban,0) + rw_crapcst.vlcheque;
               --Acumular total cheque banco
               vr_tot_vlchqban:= Nvl(vr_tot_vlchqban,0) + rw_crapcst.vlcheque;
             END IF;
           END IF;
           --Data Deposito = Data Movimento
           IF rw_crapcst.dtmvtolt = rw_crapdat.dtmvtolt THEN
             --Incrementar Quantidade Cheque
             vr_cop_qtcheque:= Nvl(vr_cop_qtcheque,0) + 1;
             --Incrementar total cheque
             vr_tot_qtcheque:= Nvl(vr_tot_qtcheque,0) + 1;
             --Acumular valor cheque cooperativa
             vr_cop_vlcheque:= Nvl(vr_cop_vlcheque,0) + rw_crapcst.vlcheque;
             --Acumular valor total cheque
             vr_tot_vlcheque:= Nvl(vr_tot_vlcheque,0) + rw_crapcst.vlcheque;

             /*  Verifica se foi devolvido no mesmo dia  */
             IF  rw_crapcst.dtdevolu IS NOT NULL THEN
               --Diminuir cheques devolvidos
               vr_cop_qtchqdev:= Nvl(vr_cop_qtchqdev,0) - 1;
               --Diminuir quantidade total cheque devolvido
               vr_tot_qtchqdev:= Nvl(vr_tot_qtchqdev,0) - 1;
               --Diminuir valor cheque devolvido cooperativa
               vr_cop_vlchqdev:= Nvl(vr_cop_vlchqdev,0) - rw_crapcst.vlcheque;
               --Diminuir valor total cheque devolvido
               vr_tot_vlchqdev:= Nvl(vr_tot_vlchqdev,0) - rw_crapcst.vlcheque;
             END IF;
             --Proximo registro loop
             CONTINUE;
           END IF;
           --Incrementar quantidade saldo anterior cooperativa
           vr_cop_qtsldant:= Nvl(vr_cop_qtsldant,0) + 1;
           --Incrementar quantidade saldo anterior total
           vr_tot_qtsldant:= Nvl(vr_tot_qtsldant,0) + 1;
           --Acumular valor saldo anterior cooperativa
           vr_cop_vlsldant:= Nvl(vr_cop_vlsldant,0) + rw_crapcst.vlcheque;
           --Acumular valor saldo anterior total
           vr_tot_vlsldant:= Nvl(vr_tot_vlsldant,0) + rw_crapcst.vlcheque;
           --Data Liberacao maior ultimo movimento e menor igual movimento e
           -- nao tiver sido devolvido
           IF  rw_crapcst.dtlibera > rw_crapdat.dtmvtoan   AND
               rw_crapcst.dtlibera <= rw_crapdat.dtmvtolt  AND
               rw_crapcst.dtdevolu IS NULL THEN
             --Diminuir quantidade liberada cooperativa
             vr_cop_qtlibera:= Nvl(vr_cop_qtlibera,0) - 1;
             --Diminuir quantidade liberada total
             vr_tot_qtlibera:= Nvl(vr_tot_qtlibera,0) - 1;
             --Diminuir valor liberado cooperativa
             vr_cop_vllibera:= Nvl(vr_cop_vllibera,0) - rw_crapcst.vlcheque;
             --Diminuir valor liberado total
             vr_tot_vllibera:= Nvl(vr_tot_vllibera,0) - rw_crapcst.vlcheque;
           END IF;
           --Cheques Descontados
           IF rw_crapcst.insitchq = 5 THEN
             --Diminuir quantidade descontados cooperativa
             vr_cop_qtdeschq:= Nvl(vr_cop_qtdeschq,0) - 1;
             --Diminuir quantidade descontados total
             vr_tot_qtdeschq:= Nvl(vr_tot_qtdeschq,0) - 1;
             --Diminuir valor descontado cooperativa
             vr_cop_vldeschq:= Nvl(vr_cop_vldeschq,0) - rw_crapcst.vlcheque;
             --Diminuir valor descontado total
             vr_tot_vldeschq:= Nvl(vr_tot_vldeschq,0) - rw_crapcst.vlcheque;
             --Proximo registro
             CONTINUE;
           END IF;
           --Cheques Devolvidos e data devolucao igual movimento
           IF rw_crapcst.dtdevolu IS NOT NULL AND
              rw_crapcst.dtdevolu = rw_crapdat.dtmvtolt THEN
             --Diminuir quantidade devolvidos cooperativa
             vr_cop_qtchqdev:= Nvl(vr_cop_qtchqdev,0) - 1;
             --Diminuir quantidade devolvidos total
             vr_tot_qtchqdev:= Nvl(vr_tot_qtchqdev,0) - 1;
             --Diminuir valor devolvido cooperativa
             vr_cop_vlchqdev:= Nvl(vr_cop_vlchqdev,0) - rw_crapcst.vlcheque;
             --Diminuir valor devolvido total
             vr_tot_vlchqdev:= Nvl(vr_tot_vlchqdev,0) - rw_crapcst.vlcheque;
             --Proximo registro
             CONTINUE;
           END IF;
         ELSE  /*  Saldo DEMAIS ASSOCIADOS  */
           --Data Liberacao maior data movimento e sem devolucao
           IF rw_crapcst.dtlibera > rw_crapdat.dtmvtolt AND
              rw_crapcst.dtdevolu IS NULL THEN
             IF rw_crapcst.inchqcop = 1 THEN
               --Incrementar qtd cheques associados
               vr_ass_qtchqcop:= Nvl(vr_ass_qtchqcop,0) + 1;
               --Incrementar total cheques
               vr_tot_qtchqcop:= Nvl(vr_tot_qtchqcop,0) + 1;
               --Acumular valor cheque associados
               vr_ass_vlchqcop:= Nvl(vr_ass_vlchqcop,0) + rw_crapcst.vlcheque;
               --Acumular total cheque cooperativa
               vr_tot_vlchqcop:= Nvl(vr_tot_vlchqcop,0) + rw_crapcst.vlcheque;
             ELSE
               --Incrementar quantidade cheque associados
               vr_ass_qtchqban:= Nvl(vr_ass_qtchqban,0) + 1;
               --Incrementar quantidade cheque banco total
               vr_tot_qtchqban:= Nvl(vr_tot_qtchqban,0) + 1;
               --Acumular valor cheque banco associados
               vr_ass_vlchqban:= Nvl(vr_ass_vlchqban,0) + rw_crapcst.vlcheque;
               --Acumular total cheque banco total
               vr_tot_vlchqban:= Nvl(vr_tot_vlchqban,0) + rw_crapcst.vlcheque;
             END IF;
           END IF;
           --Data Deposito igual Data Movimento
           IF rw_crapcst.dtmvtolt = rw_crapdat.dtmvtolt THEN
             --Incrementar Quantidade Cheque associados
             vr_ass_qtcheque:= Nvl(vr_ass_qtcheque,0) + 1;
             --Incrementar total cheque
             vr_tot_qtcheque:= Nvl(vr_tot_qtcheque,0) + 1;
             --Acumular valor cheque associados
             vr_ass_vlcheque:= Nvl(vr_ass_vlcheque,0) + rw_crapcst.vlcheque;
             --Acumular valor total cheque
             vr_tot_vlcheque:= Nvl(vr_tot_vlcheque,0) + rw_crapcst.vlcheque;
             /*  Verifica se foi devolvido no mesmo dia  */
             IF  rw_crapcst.dtdevolu IS NOT NULL THEN
               --Diminuir cheques devolvidos associados
               vr_ass_qtchqdev:= Nvl(vr_ass_qtchqdev,0) - 1;
               --Diminuir quantidade total cheque devolvido
               vr_tot_qtchqdev:= Nvl(vr_tot_qtchqdev,0) - 1;
               --Diminuir valor cheque devolvido associados
               vr_ass_vlchqdev:= Nvl(vr_ass_vlchqdev,0) - rw_crapcst.vlcheque;
               --Diminuir valor total cheque devolvido
               vr_tot_vlchqdev:= Nvl(vr_tot_vlchqdev,0) - rw_crapcst.vlcheque;
             END IF;
             --Proximo registro loop
             CONTINUE;
           END IF;
           --Incrementar quantidade saldo anterior associados
           vr_ass_qtsldant:= Nvl(vr_ass_qtsldant,0) + 1;
           --Incrementar quantidade saldo anterior total
           vr_tot_qtsldant:= Nvl(vr_tot_qtsldant,0) + 1;
           --Acumular valor saldo anterior associados
           vr_ass_vlsldant:= Nvl(vr_ass_vlsldant,0) + rw_crapcst.vlcheque;
           --Acumular valor saldo anterior total
           vr_tot_vlsldant:= Nvl(vr_tot_vlsldant,0) + rw_crapcst.vlcheque;
           --Data liberacao maior que movimento anterior e menor igual movimento atual
           --e se devolucao
           IF  rw_crapcst.dtlibera > rw_crapdat.dtmvtoan   AND
               rw_crapcst.dtlibera <= rw_crapdat.dtmvtolt  AND
               rw_crapcst.dtdevolu IS NULL THEN
             --Diminuir quantidade liberada associados
             vr_ass_qtlibera:= Nvl(vr_ass_qtlibera,0) - 1;
             --Diminuir quantidade liberada total
             vr_tot_qtlibera:= Nvl(vr_tot_qtlibera,0) - 1;
             --Diminuir valor liberado associados
             vr_ass_vllibera:= Nvl(vr_ass_vllibera,0) - rw_crapcst.vlcheque;
             --Diminuir valor liberado total
             vr_tot_vllibera:= Nvl(vr_tot_vllibera,0) - rw_crapcst.vlcheque;
           END IF;
           --Cheques Descontados
           IF rw_crapcst.insitchq = 5 THEN
             --Diminuir quantidade descontados associados
             vr_ass_qtdeschq:= Nvl(vr_ass_qtdeschq,0) - 1;
             --Diminuir quantidade descontados total
             vr_tot_qtdeschq:= Nvl(vr_tot_qtdeschq,0) - 1;
             --Diminuir valor descontado associados
             vr_ass_vldeschq:= Nvl(vr_ass_vldeschq,0) - rw_crapcst.vlcheque;
             --Diminuir valor descontado total
             vr_tot_vldeschq:= Nvl(vr_tot_vldeschq,0) - rw_crapcst.vlcheque;
             --Proximo registro
             CONTINUE;
           END IF;
           --Cheques Devolvidos e devolvidos no dia do movimento
           IF rw_crapcst.dtdevolu IS NOT NULL AND
              rw_crapcst.dtdevolu = rw_crapdat.dtmvtolt THEN
             --Diminuir quantidade devolvidos associados
             vr_ass_qtchqdev:= Nvl(vr_ass_qtchqdev,0) - 1;
             --Diminuir quantidade devolvidos total
             vr_tot_qtchqdev:= Nvl(vr_tot_qtchqdev,0) - 1;
             --Diminuir valor devolvido associados
             vr_ass_vlchqdev:= Nvl(vr_ass_vlchqdev,0) - rw_crapcst.vlcheque;
             --Diminuir valor devolvido total
             vr_tot_vlchqdev:= Nvl(vr_tot_vlchqdev,0) - rw_crapcst.vlcheque;
             --Proximo registro
             CONTINUE;
           END IF;
         END IF;
       END LOOP; --rw_crapcst

       --Totalizadores quantidade creditos
       vr_cop_qtcredit:= Nvl(vr_cop_qtsldant,0) + Nvl(vr_cop_qtlibera,0) +
                         Nvl(vr_cop_qtcheque,0) + Nvl(vr_cop_qtchqdev,0) + Nvl(vr_cop_qtdeschq,0);
       --Totalizador valores creditos
       vr_cop_vlcredit:= Nvl(vr_cop_vlsldant,0) + Nvl(vr_cop_vllibera,0) +
                         Nvl(vr_cop_vlcheque,0) + Nvl(vr_cop_vlchqdev,0) + Nvl(vr_cop_vldeschq,0);
       --Totalizador quantidade credito associados
       vr_ass_qtcredit:= Nvl(vr_ass_qtsldant,0) + Nvl(vr_ass_qtlibera,0) +
                         Nvl(vr_ass_qtcheque,0) + Nvl(vr_ass_qtchqdev,0) + Nvl(vr_ass_qtdeschq,0);
       --Totalizador valor credito associado
       vr_ass_vlcredit:= Nvl(vr_ass_vlsldant,0) + Nvl(vr_ass_vllibera,0) +
                         Nvl(vr_ass_vlcheque,0) + Nvl(vr_ass_vlchqdev,0) + Nvl(vr_ass_vldeschq,0);
       --Totalizador quantidade credito total
       vr_tot_qtcredit:= Nvl(vr_tot_qtsldant,0) + Nvl(vr_tot_qtlibera,0) +
                         Nvl(vr_tot_qtcheque,0) + Nvl(vr_tot_qtchqdev,0) + Nvl(vr_tot_qtdeschq,0);
       --Totalizador valor creditos total
       vr_tot_vlcredit:= Nvl(vr_tot_vlsldant,0) + Nvl(vr_tot_vllibera,0) +
                         Nvl(vr_tot_vlcheque,0) + Nvl(vr_tot_vlchqdev,0) + Nvl(vr_tot_vldeschq,0);

       --Inicializar tag saldo contabil
       pc_escreve_xml('<saldo_contabil>');

       --Imprimir 2 vezes informacoes saldo contabil no relatorio
       FOR idx IN 1..2 LOOP

         --Mostrar total
         pc_escreve_xml
           ('<total_final>
               <quebra>'||idx||'</quebra>
               <glb_dtmvtolt>'||To_Char(rw_crapdat.dtmvtolt,'DD/MM/YYYY')||'</glb_dtmvtolt>
               <res_dschqcop>'||vr_res_dschqcop||'</res_dschqcop>
               <cop_qtsldant>'||To_Char(vr_cop_qtsldant,'999g990')||'</cop_qtsldant>
               <cop_vlsldant>'||To_Char(vr_cop_vlsldant,'99g999g999g990d00')||'</cop_vlsldant>
               <cop_qtlibera>'||To_Char(vr_cop_qtlibera,'999g990')||'</cop_qtlibera>
               <cop_vllibera>'||To_Char(vr_cop_vllibera,'99g999g999g990d00')||'</cop_vllibera>
               <cop_qtcheque>'||To_Char(vr_cop_qtcheque,'999g990')||'</cop_qtcheque>
               <cop_vlcheque>'||To_Char(vr_cop_vlcheque,'99g999g999g990d00')||'</cop_vlcheque>
               <cop_qtchqdev>'||To_Char(vr_cop_qtchqdev,'999g990')||'</cop_qtchqdev>
               <cop_vlchqdev>'||To_Char(vr_cop_vlchqdev,'99g999g999g990d00')||'</cop_vlchqdev>
               <cop_qtdeschq>'||To_Char(vr_cop_qtdeschq,'999g990')||'</cop_qtdeschq>
               <cop_vldeschq>'||To_Char(vr_cop_vldeschq,'99g999g999g990d00')||'</cop_vldeschq>
               <cop_qtcredit>'||To_Char(vr_cop_qtcredit,'999g990')||'</cop_qtcredit>
               <cop_vlcredit>'||To_Char(vr_cop_vlcredit,'99g999g999g990d00')||'</cop_vlcredit>
               <cop_qtchqcop>'||To_Char(vr_cop_qtchqcop,'999g990')||'</cop_qtchqcop>
               <cop_vlchqcop>'||To_Char(vr_cop_vlchqcop,'99g999g999g990d00')||'</cop_vlchqcop>
               <cop_qtchqban>'||To_Char(vr_cop_qtchqban,'999g990')||'</cop_qtchqban>
               <cop_vlchqban>'||To_Char(vr_cop_vlchqban,'99g999g999g990d00')||'</cop_vlchqban>
               <ass_qtsldant>'||To_Char(vr_ass_qtsldant,'999g990')||'</ass_qtsldant>
               <ass_vlsldant>'||To_Char(vr_ass_vlsldant,'99g999g999g990d00')||'</ass_vlsldant>
               <ass_qtlibera>'||To_Char(vr_ass_qtlibera,'999g990')||'</ass_qtlibera>
               <ass_vllibera>'||To_Char(vr_ass_vllibera,'99g999g999g990d00')||'</ass_vllibera>
               <ass_qtcheque>'||To_Char(vr_ass_qtcheque,'999g990')||'</ass_qtcheque>
               <ass_vlcheque>'||To_Char(vr_ass_vlcheque,'99g999g999g990d00')||'</ass_vlcheque>
               <ass_qtchqdev>'||To_Char(vr_ass_qtchqdev,'999g990')||'</ass_qtchqdev>
               <ass_vlchqdev>'||To_Char(vr_ass_vlchqdev,'99g999g999g990d00')||'</ass_vlchqdev>
               <ass_qtdeschq>'||To_Char(vr_ass_qtdeschq,'999g990')||'</ass_qtdeschq>
               <ass_vldeschq>'||To_Char(vr_ass_vldeschq,'99g999g999g990d00')||'</ass_vldeschq>
               <ass_qtcredit>'||To_Char(vr_ass_qtcredit,'999g990')||'</ass_qtcredit>
               <ass_vlcredit>'||To_Char(vr_ass_vlcredit,'99g999g999g990d00')||'</ass_vlcredit>
               <ass_qtchqcop>'||To_Char(vr_ass_qtchqcop,'999g990')||'</ass_qtchqcop>
               <ass_vlchqcop>'||To_Char(vr_ass_vlchqcop,'99g999g999g990d00')||'</ass_vlchqcop>
               <ass_qtchqban>'||To_Char(vr_ass_qtchqban,'999g990')||'</ass_qtchqban>
               <ass_vlchqban>'||To_Char(vr_ass_vlchqban,'99g999g999g990d00')||'</ass_vlchqban>
               <tot_qtsldant>'||To_Char(vr_tot_qtsldant,'999g990')||'</tot_qtsldant>
               <tot_vlsldant>'||To_Char(vr_tot_vlsldant,'99g999g999g990d00')||'</tot_vlsldant>
               <tot_qtlibera>'||To_Char(vr_tot_qtlibera,'999g990')||'</tot_qtlibera>
               <tot_vllibera>'||To_Char(vr_tot_vllibera,'99g999g999g990d00')||'</tot_vllibera>
               <tot_qtcheque>'||To_Char(vr_tot_qtcheque,'999g990')||'</tot_qtcheque>
               <tot_vlcheque>'||To_Char(vr_tot_vlcheque,'99g999g999g990d00')||'</tot_vlcheque>
               <tot_qtchqdev>'||To_Char(vr_tot_qtchqdev,'999g990')||'</tot_qtchqdev>
               <tot_vlchqdev>'||To_Char(vr_tot_vlchqdev,'99g999g999g990d00')||'</tot_vlchqdev>
               <tot_qtdeschq>'||To_Char(vr_tot_qtdeschq,'999g990')||'</tot_qtdeschq>
               <tot_vldeschq>'||To_Char(vr_tot_vldeschq,'99g999g999g990d00')||'</tot_vldeschq>
               <tot_qtcredit>'||To_Char(vr_tot_qtcredit,'999g990')||'</tot_qtcredit>
               <tot_vlcredit>'||To_Char(vr_tot_vlcredit,'99g999g999g990d00')||'</tot_vlcredit>
               <tot_qtchqcop>'||To_Char(vr_tot_qtchqcop,'999g990')||'</tot_qtchqcop>
               <tot_vlchqcop>'||To_Char(vr_tot_vlchqcop,'99g999g999g990d00')||'</tot_vlchqcop>
               <tot_qtchqban>'||To_Char(vr_tot_qtchqban,'999g990')||'</tot_qtchqban>
               <tot_vlchqban>'||To_Char(vr_tot_vlchqban,'99g999g999g990d00')||'</tot_vlchqban>
             </total_final>');
       END LOOP;
       --Finalizar tags saldo contabil e relatorio
       pc_escreve_xml('</saldo_contabil></crrl234>');

       -- Efetuar solicitacao de geracao de relatorio crrl234 --
       gene0002.pc_solicita_relato (pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl234'          --> N? base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl234.jasper'    --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL                --> Titulo do relat?rio
                                   ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final
                                   ,pr_qtcoluna  => 132                 --> 132 colunas
                                   ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                   ,pr_flg_impri => 'S'                 --> Chamar a impress?o (Imprim.p)
                                   ,pr_nmformul  => NULL                --> Nome do formul?rio para impress?o
                                   ,pr_nrcopias  => 1                   --> N?mero de c?pias
                                   ,pr_flg_gerar => 'N'                 --> gerar PDF
                                   ,pr_des_erro  => vr_des_erro);       --> Sa?da com erro

       -- Testar se houve erro
       IF vr_des_erro IS NOT NULL THEN
         -- Gerar excecao
         RAISE vr_exc_erro;
       END IF;

       -- Liberando a mem?ria alocada pro CLOB
       dbms_lob.close(vr_des_xml);
       dbms_lob.freetemporary(vr_des_xml);

       /* Eliminacao dos registros de restart */
       BTCH0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper
                                  ,pr_cdprogra => vr_cdprogra
                                  ,pr_flgresta => pr_flgresta
                                  ,pr_des_erro => vr_des_erro);
       --Se ocorreu erro
       IF vr_des_erro IS NOT NULL THEN
         --Levantar Excecao
         RAISE vr_exc_erro;
       END IF;

       -- Processo OK, devemos chamar a fimprg
       btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);
       --Salvar informacoes no banco de dados
       COMMIT;

     EXCEPTION
       WHEN vr_exc_erro THEN

         -- Se foi retornado apenas código
         IF nvl(vr_cdcritic,0) > 0 AND vr_des_erro IS NULL THEN
           -- Buscar a descrição
           vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         -- Devolvemos código e critica encontradas
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := vr_des_erro;

         --Zerar tabela de memoria auxiliar
         pc_limpa_tabela;

         -- Efetuar rollback
         ROLLBACK;


       WHEN OTHERS THEN
         -- Retornar texto do erro
         pr_cdcritic := 0;
         pr_dscritic := sqlerrm;

         --Zerar tabela de memoria auxiliar
         pc_limpa_tabela;

         -- Efetuar rollback
         ROLLBACK;
     END;
   END pc_crps287;
/
