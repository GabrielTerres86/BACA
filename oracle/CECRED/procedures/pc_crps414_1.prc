CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS414_1 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                                ,pr_idparale IN crappar.idparale%TYPE   --> ID do paralelo em execução
                                                ,pr_idprogra IN crappar.idprogra%TYPE   --> ID do PAC em execução
                                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                                ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
BEGIN
  /* ..........................................................................

     Programa: pc_crps414_1 (Antigo Fontes/crps414_1.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Evandro
     Data    : Agosto/2011.                   Ultima atualizacao: 21/03/2017

     Dados referentes ao programa:

     Frequencia: Diario (Batch - Background).
     Objetivo  : Gerar informacoes sobre emprestimos, cotas, desconto de cheques,
                 aplicacoes, para os relatorios gerenciais.

     Alteracoes: 10/02/2012 - Utilizar variavel glb_flgresta para nao efetuar
                              controle de restart (David).

                 30/01/2013 - Criar registro da gninfpl para cada PAC mesmo que
                              seja com valores zerado, exceto 90 e 91 (Evandro).

                 04/02/2013 - Conversão Progress >> Oracle PLSQL (Marcos-Supero)

                 08/02/2013 - Atualizar o novo campo crapsda.vlsdcota com o saldo
                              das cotas do dia (Marcos-Supero)

                 16/09/2013 - Tratamento para Imunidade Tributaria (Ze).

                 30/10/2013 - Incluir chamada da procedure controla_imunidade
                             (Lucas R.)

                 25/11/2013 - Limpar parametros de saida de critica no caso da
                              exceção vr_exc_fimprg (Marcos-Supero)
                 
                 22/01/2014 - Incluir VALIDATE gnlcred, gninfpl (Lucas R.).
               
                 03/02/2014 - Remover a chamada da procedure "saldo_epr.p".(James)             
                  
                 21/02/2014 - Replicação da manutenção progress(Odirlei-AMcom)
                 
                 29/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                              posicoes (Tiago/Gielow SD137074).	 

				 13/05/2014 - Alterado o nome do log especifico do programa para CRPS414_AAAAMMDD(dtmvtolt)
                             e incluido a gravação do log nos exceptions, pois como o programa é executado 
                             via job os parametros não retornam para nenhum programa (Odirlei - Amcom)
														 
				 19/09/2014 - Adicionado tratamento para aplicações dos produtos de captação. (Reinert)     
				 
				 16/10/2014 - Modificado a forma de atualizar a tabela crapsda para agilizar o processamento
                              e evitar locks nessa tabela. Foi retirado o update na crapsda dentro do loop e 
                              utilizado o comando forall.

         04/12/2015 - #369383 retirado a atualização da crapsda em função do saldo de cotas e implementado 
                      na rotina para popular este campo no PC_CRPS001, diretamente na criação do registro na tabela.
                      (Carlos)

         02/08/2016 - Inclusao insitage 3-Temporariamente Indisponivel.
                        (Jaison/Anderson)

         04/01/2017 - Ajuste para melhoria de performance (Adriano - SD 470708).
               
         21/03/2017 - #455742 Ajuste de passagem dos parâmetros inpessoa e nrcpfcgc para não
                      consultar novamente o associado no pkg apli0001 (Carlos)

   ............................................................................ */
  DECLARE

    -- Código do programa
    vr_cdprogra crapprg.cdprogra%TYPE;
    vr_logprogr VARCHAR2(200) := NULL;
    
    -- Tratamento de erros
    vr_exc_fimprg EXCEPTION;
    vr_exc_saida  EXCEPTION;
    vr_exc_forall EXCEPTION;
    -- Erro em chamadas da pc_gera_erro
    vr_des_reto VARCHAR2(3);
    vr_tab_erro GENE0001.typ_tab_erro;
		vr_cdcritic NUMBER;
		vr_dscritic VARCHAR2(4000);
    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.nmrescop
            ,cop.nrtelura
            ,cop.dsdircop
            ,cop.cdbcoctl
            ,cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    /* Cursor genérico de calendário */
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    vr_dstextab craptab.dstextab%TYPE := NULL;

    -- Buscar todos os associados do PAC
    CURSOR cr_crapass IS
      SELECT ass.nrdconta
            ,ass.cdagenci
            ,ass.dtdemiss
            ,ass.inmatric
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.cdagenci = pr_idprogra; --and ass.nrdconta = 154385;
    -- Busca de todos os empréstimos em aberto da conta
    CURSOR cr_crapepr(pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT epr.cdlcremp
            ,epr.nrctremp
            ,epr.vlsdeved
            ,epr.vlsdevat
            ,epr.tpemprst
            ,epr.qtlcalat
            ,epr.qtpcalat
            ,COUNT (1)
              OVER (partition by epr.cdlcremp)
              qtemplin --> Faz uma conta a cada quebra de linha de crédito
        FROM crapepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.inliquid <> 1 -- Não liquidado
       ORDER BY epr.cdlcremp;
    -- Controle de quebra por linha de crédito
    vr_cdlcremp crapepr.cdlcremp%TYPE;
    -- Contadores para os empréstimos
    vr_qtemplin NUMBER;                --> Quantidade de registros de empréstimo
    vr_qtctremp NUMBER;                --> Quantidade de empréstimos com saldo devedor
    vr_vlemprst crapepr.vlsdeved%TYPE; --> Totalizador de saldo devedor
    vr_vlsdeved crapepr.vlsdeved%TYPE; --> Saldo devedor empréstimo a empréstimo
    vr_qtprecal crapepr.qtprecal%TYPE; --> Qtde de parcelas pendentes
    -- Buscar descrição da linha de crédito
    CURSOR cr_craplcr(pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
      SELECT lcr.dslcremp
        FROM craplcr lcr
       WHERE lcr.cdcooper = pr_cdcooper
         AND lcr.cdlcremp = pr_cdlcremp;
    vr_dslcremp VARCHAR2(40);
    -- Busca das cotas do associado
    CURSOR cr_crapcot(pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT cot.vldcotas
        FROM crapcot cot
       WHERE cot.cdcooper = pr_cdcooper
         AND cot.nrdconta = pr_nrdconta;
    vr_vldcotas crapcot.vldcotas%TYPE;
    -- Contabilização de cotas
    vr_res_vlcapati NUMBER(14,2) := 0; -- Contabilização de valor de cotas
    vr_age_qtcapati INTEGER := 0;      -- Contador de cotas para matriculas originais
    -- Totaliza o montante de cheques descontados por agencia
    CURSOR cr_crapcdb(pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT SUM(NVL(cdb.vlcheque,0))
        FROM crapcdb cdb
       WHERE cdb.cdcooper = pr_cdcooper          --> Coop conectada
         AND cdb.nrdconta = pr_nrdconta          --> Conta do associado
         AND cdb.insitchq = 2                    --> Processado
         AND cdb.dtlibera > rw_crapdat.dtmvtolt; --> Data superior ao movimento atual
    vr_vlcheque crapcdb.vlcheque%TYPE;      --> Sumarizador por conta
    vr_vldscchq crapcdb.vlcheque%TYPE := 0; --> Totalizador geral
    -- Busca o montante de titulos descontados por agencia
    CURSOR cr_craptdb (pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT tdb.insittit
            ,tdb.vltitulo
            ,tdb.cdbandoc
            ,tdb.nrdctabb
            ,tdb.nrcnvcob
            ,tdb.nrdocmto
            ,rowid
        FROM craptdb tdb
       WHERE tdb.cdcooper = pr_cdcooper --> Coop conectada
         AND tdb.nrdconta = pr_nrdconta --> Conta do associado
         AND (  (tdb.insittit = 4 AND tdb.dtvencto >= rw_crapdat.dtmvtolt)    --> Liberado e data vcto >= data atual
              OR
                (tdb.insittit = 2 AND tdb.dtdpagto = rw_crapdat.dtmvtolt)    --> Processado e data vcto = data atual
             );
    -- Acumular dos lançamentos
    vr_vldsctit craptdb.vltitulo%TYPE := 0;
    -- Busca do bloqueto correspondente ao lançamento passado
    CURSOR cr_crapcob(pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_cdbandoc IN craptdb.cdbandoc%TYPE
                     ,pr_nrdctabb IN craptdb.nrdctabb%TYPE
                     ,pr_nrcnvcob IN craptdb.nrcnvcob%TYPE
                     ,pr_nrdocmto IN craptdb.nrdocmto%TYPE) IS
      SELECT cob.indpagto
        FROM crapcob cob
       WHERE cob.cdcooper = pr_cdcooper
         AND cob.cdbandoc = pr_cdbandoc
         AND cob.nrdctabb = pr_nrdctabb
         AND cob.nrcnvcob = pr_nrcnvcob
         AND cob.nrdconta = pr_nrdconta
         AND cob.nrdocmto = pr_nrdocmto;
    rw_crapcob cr_crapcob%ROWTYPE;
    -- Busca das aplicações RDCA30 e RDCA60 por PAC
    CURSOR cr_craprda(pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_cdagenci IN crapass.cdagenci%TYPE) IS
      SELECT rda.tpaplica
            ,rda.nrdconta
            ,rda.nraplica
            ,rda.dtvencto
            ,rda.dtmvtolt
            ,rda.vlsdrdca
            ,rda.qtdiauti
            ,rda.vlsltxmm
            ,rda.dtatslmm
            ,rda.vlsltxmx
            ,rda.dtatslmx
            ,lap.txaplica
            ,lap.txaplmes
            ,ass.inpessoa
            ,ass.nrcpfcgc
        FROM craprda rda
            ,craplap lap
            ,crapass ass
       WHERE rda.cdcooper = pr_cdcooper  -- Coop conectada
         AND rda.nrdconta = pr_nrdconta  -- Conta do associado
         AND rda.cdageass = pr_cdagenci  -- Agencia do associado
         AND rda.insaqtot = 0            -- Não sacado totalmente
         AND lap.cdcooper = rda.cdcooper 
         AND lap.dtmvtolt = rda.dtmvtolt
         AND lap.cdagenci = rda.cdagenci
         AND lap.cdbccxlt = rda.cdbccxlt
         AND lap.nrdolote = rda.nrdolote
         AND lap.nrdconta = rda.nrdconta 
         AND lap.nrdocmto = rda.nraplica
				 
         AND ass.cdcooper = rda.cdcooper
         AND ass.nrdconta = rda.nrdconta;
		
    TYPE typ_rec_craprda IS TABLE OF cr_craprda%ROWTYPE
         INDEX BY PLS_INTEGER;
    vr_tab_craprda typ_rec_craprda;
				 
		-- Busca aplicações de captação
    CURSOR cr_craprac(pr_cdcooper IN craprac.cdcooper%TYPE
		                 ,pr_nrdconta IN craprac.nrdconta%TYPE)	IS
      SELECT rac.nrdconta
			      ,rac.nraplica
						,rac.cdprodut
						,rac.idblqrgt
						,cpc.idtippro
				FROM craprac rac
				    ,crapcpc cpc
			 WHERE rac.cdcooper = pr_cdcooper    -- Cooperativa
			   AND rac.nrdconta = pr_nrdconta    -- Nr. da conta
				 AND rac.idsaqtot = 0              -- Indicador de saque total
				 AND cpc.cdprodut = rac.cdprodut;  -- Código do produto
										 
    -- Variáveis para acumulo das aplicações RDC
    vr_vlsdrdca     NUMBER(18,8); --> Saldo da aplicação
    vr_vlsldapl     NUMBER(18,8); --> Saldo da aplicação RDCA
    vr_vldperda     NUMBER(18,8); --> Valor calculado da perda
    vr_apl_txaplica NUMBER(18,8); --> Taxa da aplicação
    vr_vlsldrdc     NUMBER(18,8) := 0; --> Saldo de aplicação RDC
    vr_perirrgt     NUMBER(18,2);          --> % de IR Resgatado
    vr_vlrentot     NUMBER(18,8);          --> Totalizador dos rendimentos
    vr_vlrdirrf     craplap.vllanmto%TYPE; --> Valor do irrf sobre o rendimento
    vr_sldpresg_tmp craplap.vllanmto%TYPE; --> Valor saldo de resgate
    vr_dup_vlsdrdca craplap.vllanmto%TYPE; --> Acumulo do saldo da aplicacao RDCA
    -- Totalizadores das aplicações RDC e RDCA
    vr_vltotrdc     NUMBER(18,8) := 0; --> Total Saldo de aplicações RDCA
    vr_vltotrii     NUMBER(18,8) := 0; --> Total Saldo de aplicações RDCAII
    vr_vlrdcpre     NUMBER(18,8) := 0; --> Total Saldo de aplicações RDCPre
    vr_vlrdcpos     NUMBER(18,8) := 0; --> Total Saldo de aplicações RDCPos
    vr_infimsol     PLS_INTEGER;       --> Variavel para receber o retorno na iniprg
    vr_stprogra     PLS_INTEGER;       --> Variavel para receber o retorno na fimprg
		-- Variáveis de retorno da procedure apli0005.pc_busca_saldo_aplicacoes
		vr_vlsldtot     NUMBER;
		vr_vlsldrgt     NUMBER;
		
	-- Definicao do tipo para a tabela de aplicações
    vr_craprda apli0001.typ_tab_craprda;
		
    -- Busca do tipo de captação
    CURSOR cr_crapdtc(pr_tpaplica craprda.tpaplica%TYPE) IS
      SELECT dtc.tpaplrdc
            ,dtc.dsaplica
        FROM crapdtc dtc
       WHERE dtc.cdcooper = pr_cdcooper
         AND dtc.tpaplica = pr_tpaplica;
    rw_crapdtc cr_crapdtc%ROWTYPE;
    -- Data de fim e inicio da utilizacao da taxa de poupanca.
    -- Utiliza-se essa data quando o rendimento da aplicacao for menor que
    --  a poupanca, a cooperativa opta por usar ou nao.
    -- Buscar a descrição das faixas contido na craptab
    vr_dtinitax     DATE;                  --> Data de inicio da utilizacao da taxa de poupanca.
    vr_dtfimtax     DATE;                  --> Data de fim da utilizacao da taxa de poupanca.
    -- Buscar situação da agência
    CURSOR cr_crapage IS
      SELECT age.insitage
        FROM crapage age
       WHERE age.cdcooper = pr_cdcooper
         AND age.cdagenci = pr_idprogra;
    vr_insitage crapage.insitage%TYPE;
	vr_result varchar2(5000);
	
  BEGIN
    -- Código do programa
    vr_cdprogra := 'CRPS414';
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS414'
                              ,pr_action => 'PC_CRPS414_1');
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      pr_cdcritic := 651;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      pr_cdcritic := 1;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    -- Definir nome do arquivo de log     
    vr_logprogr :=  vr_cdprogra||'_'||to_char(rw_crapdat.dtmvtolt,'RRRRMMDD');
    
    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => vr_infimsol
                             ,pr_cdcritic => pr_cdcritic);
    -- Se a variavel de erro é <> 0
    IF pr_cdcritic <> 0 THEN
      -- Buscar descrição da crítica
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> Coop. --> '||pr_cdcooper||' --> PAC --> '||lpad(pr_idprogra,2,'0')||' --> Erro tratado no processo paralelo: '
                                                 || pr_dscritic
                                ,pr_nmarqlog     => vr_logprogr); --> Log específico deste programa
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;

    -- Data de fim e inicio da utilizacao da taxa de poupanca.
    -- Utiliza-se essa data quando o rendimento da aplicacao for menor que
    --  a poupanca, a cooperativa opta por usar ou nao.
    -- Buscar a descrição das faixas contido na craptab
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                         ,pr_nmsistem => 'CRED'
                                         ,pr_tptabela => 'USUARI'
                                         ,pr_cdempres => 11
                                         ,pr_cdacesso => 'MXRENDIPOS'
                                         ,pr_tpregist => 1);
    -- Se não encontrar
    IF trim(vr_dstextab) IS NULL THEN
      -- Utilizar datas padrão
      vr_dtinitax := to_date('01/01/9999','dd/mm/yyyy');
      vr_dtfimtax := to_date('01/01/9999','dd/mm/yyyy');
    ELSE
      -- Utilizar datas da tabela
      vr_dtinitax := TO_DATE(gene0002.fn_busca_entrada(1,vr_dstextab,';'),'DD/MM/YYYY');
      vr_dtfimtax := TO_DATE(gene0002.fn_busca_entrada(2,vr_dstextab,';'),'DD/MM/YYYY');
    END IF;
    -- Buscar todas os associados do PAC
    FOR rw_crapass IN cr_crapass LOOP
      -- Reiniciar controle de quebra por linha de crédito
      vr_cdlcremp := 0;
      -- Reiniciar contador de empréstimos por linha de crédito
      vr_qtemplin := 0;
      -- Busca de todos os empréstimos em aberto para a conta
      FOR rw_crapepr IN cr_crapepr(pr_nrdconta => rw_crapass.nrdconta) LOOP
        -- Se mudou a linha de crédito
        IF vr_cdlcremp <> rw_crapepr.cdlcremp THEN
          -- Reiniciar contadores
          vr_qtemplin := 0;
          vr_qtctremp := 0;
          vr_vlemprst := 0;
          -- Guardar a linha de crédito do registro atual
          vr_cdlcremp := rw_crapepr.cdlcremp;
        END IF;
        -- Incrementar a quantidade de emprestimos da linha
        vr_qtemplin := vr_qtemplin + 1;
        -- Se estamos processando o Mensal
        IF trunc(rw_crapdat.dtmvtolt,'mm') <> trunc(rw_crapdat.dtmvtopr,'mm') THEN
          -- Saldo calculado pelo 78
          vr_vlsdeved := rw_crapepr.vlsdeved;
        ELSE
          /* Saldo calculado pelo crps616.p e crps665.p */
          vr_vlsdeved := rw_crapepr.vlsdevat;
                
          IF rw_crapepr.tpemprst = 0 THEN
             vr_qtprecal := rw_crapepr.qtlcalat;
          ELSE
             vr_qtprecal := rw_crapepr.qtpcalat;
          END IF;   
        END IF;
        -- Contabilizar somente se o emprestimo tem saldo
        IF vr_vlsdeved > 0 THEN
          -- Acumular totalizadores
          vr_qtctremp := vr_qtctremp + 1;
          vr_vlemprst := vr_vlemprst + vr_vlsdeved;
        END IF;
        -- Se a quantidade de emprestimos da linha, for maior ou igual ao total,
        -- ou seja, estamos processando o ultimo emprestimo da linha
        IF vr_qtemplin >= rw_crapepr.qtemplin THEN
          -- Somente continuar se teve valor calculado
          IF vr_vlemprst > 0 THEN
            -- Buscar descrição da linha de crédito
            vr_dslcremp := NULL;
            OPEN cr_craplcr(pr_cdlcremp => rw_crapepr.cdlcremp);
            FETCH cr_craplcr
             INTO vr_dslcremp;
            CLOSE cr_craplcr;
            -- Se não encontrou nenhum descrição
            IF trim(vr_dslcremp) IS NULL THEN
              -- Utilizar descrição genérica
              vr_dslcremp := 'NAO CADASTRADA!';
            END IF;
            -- Adicionar a descrição o código da linha de crédito
            vr_dslcremp := SUBSTR(to_char(rw_crapepr.cdlcremp,'FM0000')||' - '||vr_dslcremp,1,36);
            -- Gravar a tabela GNLCRED - Totais de empréstimo por linha de credito
            DECLARE
              vr_dsopera VARCHAR2(30);
            BEGIN
              -- Tenta atualizar as informações
              vr_dsopera := 'Atualizar';
              UPDATE gnlcred
                 SET qtassoci = NVL(qtassoci,0) + 1
                    ,qtctremp = NVL(qtctremp,0) + vr_qtctremp
                    ,vlemprst = NVL(vlemprst,0) + vr_vlemprst
                    ,dslcremp = vr_dslcremp
               WHERE cdcooper = pr_cdcooper          --> Cooperativa conectada
                 AND cdagenci = rw_crapass.cdagenci  --> Agencia do associado
                 AND dtmvtolt = rw_crapdat.dtmvtolt  --> Data atual
                 AND cdlcremp = rw_crapepr.cdlcremp; --> LInha de crédito do empréstimo
              -- Se não conseguiu atualizar nenhum registro
              IF SQL%ROWCOUNT = 0 THEN
                -- Não encontrou nada para atualizar, então inserimos
                vr_dsopera := 'Inserir';
                INSERT INTO gnlcred
                           (cdcooper
                           ,cdagenci
                           ,dtmvtolt
                           ,cdlcremp
                           ,qtassoci
                           ,qtctremp
                           ,vlemprst
                           ,dslcremp)
                     VALUES(pr_cdcooper         --> Coop conectada
                           ,rw_crapass.cdagenci --> Agencia do associado
                           ,rw_crapdat.dtmvtolt --> Data atual
                           ,rw_crapepr.cdlcremp --> Linha de crédito do empréstimo
                           ,1                   --> Valor inicial
                           ,vr_qtctremp         --> Quantidade calculada
                           ,vr_vlemprst         --> Valor acumulado
                           ,vr_dslcremp);       --> Descrição
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Erro ao '||vr_dsopera||' as informações na tabela GNLCRED: '||sqlerrm;
                RAISE vr_exc_saida;
            END;
          END IF;
        END IF;
      END LOOP;
      -- Se o associado não está demitido
      IF rw_crapass.dtdemiss IS NULL THEN
        -- Buscar as cotas do associado
        vr_vldcotas := 0;
        OPEN cr_crapcot(pr_nrdconta => rw_crapass.nrdconta);
        FETCH cr_crapcot
         INTO vr_vldcotas;
        CLOSE cr_crapcot;
        -- Acumular no totalizador de cotas
        vr_res_vlcapati := NVL(vr_res_vlcapati,0) + vr_vldcotas;
        -- Se a matricula do associado é original
        IF rw_crapass.inmatric = 1 THEN
          -- Acumular contador
          vr_age_qtcapati := NVL(vr_age_qtcapati,0) + 1;
        END IF;
		
      END IF;
      -- Buscar o montante de cheques descontados por agencia
      OPEN cr_crapcdb(pr_nrdconta => rw_crapass.nrdconta);
      FETCH cr_crapcdb
       INTO vr_vlcheque;
      CLOSE cr_crapcdb;
      -- Acumular no total
      vr_vldscchq := NVL(vr_vldscchq,0) + NVL(vr_vlcheque,0);
      -- Buscar o montante de titulos descontados por agencia
      FOR rw_craptdb IN cr_craptdb(pr_nrdconta => rw_crapass.nrdconta) LOOP
        -- Para cada titulo, buscar o Bloqueto de Cobrança
        OPEN cr_crapcob(pr_nrdconta => rw_crapass.nrdconta
                       ,pr_cdbandoc => rw_craptdb.cdbandoc
                       ,pr_nrdctabb => rw_craptdb.nrdctabb
                       ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                       ,pr_nrdocmto => rw_craptdb.nrdocmto);
        FETCH cr_crapcob
         INTO rw_crapcob;
        -- Se não encontrar
        IF cr_crapcob%NOTFOUND THEN
          -- Adicionar LOG ao processo batch
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 1 -- Processo normal
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '|| vr_cdprogra || ' --> Titulo em desconto nao encontrado no crapcob - ROWID(craptdb) = '||rw_craptdb.rowid);
        ELSE
          -- Se foi pago via CAIXA, InternetBank ou TAA
          -- Despreza, pois ja esta pago, o dinheiro ja entrou para a cooperativa
          IF rw_craptdb.insittit = 2  AND rw_crapcob.indpagto IN(1,3,4) THEN  -- TAA
            NULL; --> Ignorar
          ELSE
            -- Acumular o lançamento
            vr_vldsctit := NVL(vr_vldsctit,0) + NVL(rw_craptdb.vltitulo,0);
          END IF;
        END IF;
        -- Fechar o cursor
        CLOSE cr_crapcob;
      END LOOP;
      -- Calcula aplicacoes RDCA30 e RDCA60 por PAC
      -- Carregar PL Table com dados da tabela CRAPRDA
      OPEN cr_craprda(pr_nrdconta => rw_crapass.nrdconta
                     ,pr_cdagenci => rw_crapass.cdagenci);
      LOOP
        FETCH cr_craprda BULK COLLECT INTO vr_tab_craprda LIMIT 100000;
              
        EXIT WHEN vr_tab_craprda.COUNT = 0;

        FOR idx IN vr_tab_craprda.first..vr_tab_craprda.last LOOP
                
          --Limpa a tabela
          vr_craprda.delete;
                
          --Alimenta PLTABLE com as informações da aplicação
          vr_craprda(1).dtvencto:= vr_tab_craprda(idx).dtvencto;
          vr_craprda(1).dtmvtolt:= vr_tab_craprda(idx).dtmvtolt;
          vr_craprda(1).vlsdrdca:= vr_tab_craprda(idx).vlsdrdca;
          vr_craprda(1).qtdiauti:= vr_tab_craprda(idx).qtdiauti;
          vr_craprda(1).vlsltxmm:= vr_tab_craprda(idx).vlsltxmm;
          vr_craprda(1).dtatslmm:= vr_tab_craprda(idx).dtatslmm;
          vr_craprda(1).vlsltxmx:= vr_tab_craprda(idx).vlsltxmx;
          vr_craprda(1).dtatslmx:= vr_tab_craprda(idx).dtatslmx;
          vr_craprda(1).tpaplica:= vr_tab_craprda(idx).tpaplica;          
          vr_craprda(1).txaplica:= vr_tab_craprda(idx).txaplica;
          vr_craprda(1).txaplmes:= vr_tab_craprda(idx).txaplmes;
          
        -- Para RDCA
        IF vr_tab_craprda(idx).tpaplica = 3 THEN --> RDCA
          -- Consultar o saldo da aplicação
          apli0001.pc_consul_saldo_aplic_rdca30(pr_cdcooper => pr_cdcooper         --> Cooperativa
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data do processo
                                               ,pr_inproces => rw_crapdat.inproces --> Indicador do processo
                                               ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> Próximo dia util
                                               ,pr_cdprogra => vr_cdprogra         --> Programa em execução
                                               ,pr_cdagenci => 1                   --> Código da agência
                                               ,pr_nrdcaixa => 999                 --> Número do caixa
                                               ,pr_nrdconta => vr_tab_craprda(idx).nrdconta --> Nro da conta da aplicação RDCA
                                               ,pr_nraplica => vr_tab_craprda(idx).nraplica --> Nro da aplicação RDCA
                                               ,pr_vlsdrdca => vr_vlsdrdca         --> Saldo da aplicação
                                               ,pr_vlsldapl => vr_vlsldapl         --> Saldo da aplicacao RDCA
                                               ,pr_sldpresg => vr_sldpresg_tmp     --> Valor saldo de resgate
                                               ,pr_dup_vlsdrdca => vr_dup_vlsdrdca --> Acumulo do saldo da aplicacao RDCA
                                               ,pr_vldperda => vr_vldperda         --> Valor calculado da perda
                                               ,pr_txaplica => vr_apl_txaplica     --> TAxa utilizada
                                               ,pr_des_reto => vr_des_reto         --> OK ou NOK
                                               ,pr_tab_erro => vr_tab_erro);       --> Tabela com erros
          -- Se retornar erro
          IF vr_des_reto = 'NOK' THEN
            -- Se veio erro na tabela
            IF vr_tab_erro.COUNT > 0 then
              -- Montar erro
              pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            ELSE
              -- Por algum motivo retornou erro mais a tabela veio vazia
              pr_dscritic := 'Tab.Erro vazia - não é possível retornar o erro';
            END IF;
            -- Enviar ao Log Batch
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Processo com erro
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_cdprogra
                                                       || ' --> '||pr_dscritic|| ' ContaConta/dv: ' || gene0002.fn_mask_conta(rw_crapass.nrdconta)
                                                       || ' Nr.Aplicacao: '||gene0002.fn_mask(vr_tab_craprda(idx).nraplica,'zzz.zz9'));
            -- Limpar variavel de erro
            pr_dscritic := NULL;
          ELSE
            -- Se retornou saldo
            IF vr_vlsdrdca > 0 THEN
              -- Acumular ao total
              vr_vltotrdc := NVL(vr_vltotrdc,0) + NVL(vr_vlsdrdca,0);
            END IF;
          END IF;
        ELSIF vr_tab_craprda(idx).tpaplica = 5 THEN --> RDCAII
          -- Rotina de calculo do aniversario do RDCA2
          apli0001.pc_calc_aniver_rdca2c(pr_cdcooper => pr_cdcooper  --> Cooperativa
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data do processo
                                        ,pr_nrdconta => vr_tab_craprda(idx).nrdconta --> Nro da conta da aplicação RDCA
                                        ,pr_nraplica => vr_tab_craprda(idx).nraplica --> Nro da aplicação RDCA
                                        ,pr_vlsdrdca => vr_vlsdrdca         --> Saldo da aplicação pós cálculo
                                        ,pr_des_erro => pr_dscritic);       --> Saida com com erros;
          -- Testar saida com erro
          IF pr_dscritic IS NOT NULL THEN
            -- Enviar ao Log Batch
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Processo com erro
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_cdprogra
                                                       || ' --> '||pr_dscritic|| ' ContaConta/dv: ' || gene0002.fn_mask_conta(rw_crapass.nrdconta)
                                                       || ' Nr.Aplicacao: '||gene0002.fn_mask(vr_tab_craprda(idx).nraplica,'zzz.zz9'));
            -- Limpar variavel de erro
            pr_dscritic := NULL;
          ELSE
            -- Se retornou saldo
            IF vr_vlsdrdca > 0 THEN
              -- Acumular ao total
              vr_vltotrii := NVL(vr_vltotrii,0) + NVL(vr_vlsdrdca,0);
            END IF;
          END IF;
        ELSIF vr_tab_craprda(idx).tpaplica IN(7,8) THEN --> RDC
          -- Busca do tipo de captação
          OPEN cr_crapdtc(pr_tpaplica => vr_tab_craprda(idx).tpaplica);
          FETCH cr_crapdtc
           INTO rw_crapdtc;
          -- Somente continuar se encontrar
          IF cr_crapdtc%FOUND THEN
            -- Fechar o cursor e continuar
            CLOSE cr_crapdtc;
            -- Para o tipo de aplicação 1 - RDCPRE
            IF rw_crapdtc.tpaplrdc = 1 THEN
              -- Calcular saldo atualizado da aplicação
              APLI0001.pc_saldo_rdc_pre(pr_cdcooper => pr_cdcooper         --> Cooperativa
                                       ,pr_nrdconta => vr_tab_craprda(idx).nrdconta --> Nro da conta da aplicação RDC
                                       ,pr_nraplica => vr_tab_craprda(idx).nraplica --> Nro da aplicação RDC
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data do movimento atual
                                       ,pr_dtiniper => NULL                --> Data de início da aplicação
                                       ,pr_dtfimper => NULL                --> Data de término da aplicação
                                       ,pr_txaplica => 0                   --> Taxa aplicada
                                       ,pr_flggrvir => FALSE               --> Identificador se deve gravar valor insento
                                       ,pr_tab_crapdat => rw_crapdat      --> Tabela com datas do movimento
                                       ,pr_inpessoa => vr_tab_craprda(idx).inpessoa
                                       ,pr_nrcpfcgc => vr_tab_craprda(idx).nrcpfcgc
                                       ,pr_vlsdrdca => vr_vlsldrdc         --> Saldo da aplicação pós cálculo
                                       ,pr_vlrdirrf => vr_vlrdirrf         --> Valor de IR
                                       ,pr_perirrgt => vr_perirrgt         --> Percentual de IR resgatado
                                       ,pr_des_reto => vr_des_reto         --> OK ou NOK
                                       ,pr_tab_erro => vr_tab_erro);       --> Tabela com erros
              -- Se retornar erro
              IF vr_des_reto = 'NOK' THEN
                -- Se veio erro na tabela
                IF vr_tab_erro.COUNT > 0 then
                  -- Montar erro
                  pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                  pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                ELSE
                  -- Por algum motivo retornou erro mais a tabela veio vazia
                  pr_dscritic := 'Tab.Erro vazia - não é possível retornar o erro';
                END IF;
                -- Enviar ao Log Batch
                BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 2 -- Processo com erro
                                          ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_cdprogra
                                                           || ' --> '||pr_dscritic|| ' Conta/dv: ' || gene0002.fn_mask_conta(rw_crapass.nrdconta)
                                                           || ' Nr.Aplicacao: '||gene0002.fn_mask(vr_tab_craprda(idx).nraplica,'zzz.zz9'));
                -- Limpar variavel de erro
                pr_dscritic := NULL;
              ELSE
                -- Se houver saldo calculado
                IF vr_vlsldrdc > 0 THEN
                  -- Utilizar o saldo para resgate calculado da RDC
                  vr_vlrdcpre := NVL(vr_vlrdcpre,0) + NVL(vr_vlsldrdc,0);
                END IF;
              END IF;
            -- Para o tipo da aplicação 2 - RDCPOS
            ELSIF rw_crapdtc.tpaplrdc = 2 THEN
              -- Rotina de calculo do saldo das aplicacoes RDC POS
              APLI0001.pc_saldo_rdc_pos(pr_cdcooper => pr_cdcooper         --> Cooperativa
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Movimento atual
                                       ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> Proximo dia util
                                       ,pr_nrdconta => vr_tab_craprda(idx).nrdconta --> Nro da conta da aplicação RDC
                                       ,pr_craprda  => vr_craprda          --> Informações da aplicação
                                       ,pr_dtmvtpap => rw_crapdat.dtmvtolt --> Data do movimento atual
                                       ,pr_dtcalsld => rw_crapdat.dtmvtolt --> Data do movimento atual
                                       ,pr_flantven => FALSE               --> Flag antecede vencimento
                                       ,pr_flggrvir => FALSE               --> Identificador se deve gravar valor insento
                                       ,pr_dtinitax => vr_dtinitax         --> Data de inicio da utilizacao da taxa de poupanca.
                                       ,pr_dtfimtax => vr_dtfimtax         --> Data de fim da utilizacao da taxa de poupanca.
                                       ,pr_cdprogra => vr_cdprogra         --> Código do programa
                                       ,pr_inpessoa => vr_tab_craprda(idx).inpessoa
                                       ,pr_nrcpfcgc => vr_tab_craprda(idx).nrcpfcgc
                                       ,pr_vlsdrdca => vr_vlsldrdc         --> Saldo da aplicação pós cálculo
                                       ,pr_vlrentot => vr_vlrentot         --> Saldo da aplicação pós cálculo
                                       ,pr_vlrdirrf => vr_vlrdirrf         --> Valor de IR
                                       ,pr_perirrgt => vr_perirrgt         --> Percentual de IR resgatado
                                       ,pr_des_reto => vr_des_reto         --> OK ou NOK
                                       ,pr_tab_erro => vr_tab_erro);       --> Tabela com erros
              -- Se retornar erro
              IF vr_des_reto = 'NOK' THEN
                -- Se veio erro na tabela
                IF vr_tab_erro.COUNT > 0 then
                  -- Montar erro
                  pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                  pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                ELSE
                  -- Por algum motivo retornou erro mais a tabela veio vazia
                  pr_dscritic := 'Tab.Erro vazia - não é possível retornar o erro';
                END IF;
                -- Enviar ao Log Batch
                BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 2 -- Processo com erro
                                          ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_cdprogra
                                                           || ' --> '||pr_dscritic|| ' Conta/dv: ' || gene0002.fn_mask_conta(rw_crapass.nrdconta)
                                                           || ' Nr.Aplicacao: '||gene0002.fn_mask(vr_tab_craprda(idx).nraplica,'zzz.zz9'));
                -- Limpar variavel de erro
                pr_dscritic := NULL;
              ELSE
                -- Se houver saldo calculado
                IF vr_vlsldrdc > 0 THEN
                  -- Utilizar o saldo para resgate calculado da RDC
                  vr_vlrdcpos := NVL(vr_vlrdcpos,0) + NVL(vr_vlsldrdc,0);
                END IF;
              END IF;
            END IF;
          ELSE
            -- Fechar o cursor pois teremos RAISE
            CLOSE cr_crapdtc;
            -- Montar erro
            pr_dscritic := gene0001.fn_busca_critica(346);
            -- Enviar ao Log Batch
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Processo com erro
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_cdprogra
                                                       || ' --> '||pr_dscritic|| ' ContaConta/dv: ' || gene0002.fn_mask_conta(rw_crapass.nrdconta)
                                                       || ' Nr.Aplicacao: '||gene0002.fn_mask(vr_tab_craprda(idx).nraplica,'zzz.zz9'));
            -- Limpar variavel de erro
            pr_dscritic := NULL;
          END IF;
        END IF; -- Tipos de aplicação
      END LOOP;

	  END LOOP;

      CLOSE cr_craprda;

      vr_tab_craprda.delete; -- limpa dados do bulk ja armazenado em outra pl table   
      
			
			FOR rw_craprac IN cr_craprac(pr_cdcooper => pr_cdcooper
				                          ,pr_nrdconta => rw_crapass.nrdconta) LOOP
																	
				APLI0005.pc_busca_saldo_aplicacoes(pr_cdcooper => pr_cdcooper           --> Código da Cooperativa
																					,pr_cdoperad => '1'                   --> Código do Operador
																					,pr_nmdatela => 'pc_crps414_1'        --> Nome da Tela
																					,pr_idorigem => 1                     --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
																					,pr_nrdconta => rw_craprac.nrdconta   --> Número da Conta
																					,pr_idseqttl => 1                     --> Titular da Conta
																					,pr_nraplica => rw_craprac.nraplica   --> Número da Aplicação / Parâmetro Opcional
																					,pr_dtmvtolt => rw_crapdat.dtmvtolt   --> Data de Movimento
																					,pr_cdprodut => rw_craprac.cdprodut   --> Código do Produto -–> Parâmetro Opcional
																					,pr_idblqrgt => 1                     --> Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas)
																					,pr_idgerlog => 0                     --> Identificador de Log (0 – Não / 1 – Sim)
																					,pr_vlsldtot => vr_vlsldtot           --> Saldo Total da Aplicação
																					,pr_vlsldrgt => vr_vlsldrgt           --> Saldo Total para Resgate
																					,pr_cdcritic => vr_cdcritic           --> Código da crítica
																					,pr_dscritic => vr_dscritic);
																	
				IF rw_craprac.idtippro = 1 THEN -- Pré-fixada
				  vr_vlrdcpre := vr_vlrdcpre + vr_vlsldtot;
				ELSIF rw_craprac.idtippro = 2 THEN -- Pós-fixada
				  vr_vlrdcpos := vr_vlrdcpos + vr_vlsldtot;	
				END IF;
			END LOOP;
    END LOOP;
    -- Buscar situação da agência
    OPEN cr_crapage;
    FETCH cr_crapage
     INTO vr_insitage;
    CLOSE cr_crapage;
    /* Se contabilizou algo OU é PAC ATIVO, grava as contabilizacoes na tabela */
    IF ( vr_age_qtcapati + vr_res_vlcapati + vr_vldscchq + vr_vldsctit
       + vr_vltotrdc + vr_vltotrii + vr_vlrdcpre + vr_vlrdcpos > 0)
    OR (pr_idprogra NOT IN(90,91) AND vr_insitage IN (1,3)) THEN -- INTERNET e TAA e PAC 1-Ativo ou 3-Temporariamente Indisponivel
      -- Gravar a tabela GNINFPL - Informações detalhadas para os relatórios da Intranet
      DECLARE
        vr_dsopera VARCHAR2(30);
      BEGIN
        -- Tenta atualizar as informações
        vr_dsopera := 'Atualizar';
        UPDATE gninfpl
           SET qtcotati = vr_age_qtcapati
              ,vldcotas = vr_res_vlcapati
              ,vltotdsc = vr_vldscchq
              ,vltottit = vr_vldsctit
              ,vlrdca30 = vr_vltotrdc
              ,vlrdca60 = vr_vltotrii
              ,vlrdcpre = vr_vlrdcpre
              ,vlrdcpos = vr_vlrdcpos
         WHERE cdcooper = pr_cdcooper          --> Cooperativa conectada
           AND cdagenci = pr_idprogra          --> Agencia do processo
           AND dtmvtolt = rw_crapdat.dtmvtolt;  --> Data atual
        -- Se não conseguiu atualizar nenhum registro
        IF SQL%ROWCOUNT = 0 THEN
          -- Não encontrou nada para atualizar, então inserimos
          vr_dsopera := 'Inserir';
          INSERT INTO gninfpl
                     (cdcooper
                     ,cdagenci
                     ,dtmvtolt
                     ,qtcotati
                     ,vldcotas
                     ,vltotdsc
                     ,vltottit
                     ,vlrdca30
                     ,vlrdca60
                     ,vlrdcpre
                     ,vlrdcpos)
               VALUES(pr_cdcooper         --> Coop conectada
                     ,pr_idprogra         --> Agencia do procsso
                     ,rw_crapdat.dtmvtolt --> Data atual
                     ,vr_age_qtcapati
                     ,vr_res_vlcapati
                     ,vr_vldscchq
                     ,vr_vldsctit
                     ,vr_vltotrdc
                     ,vr_vltotrii
                     ,vr_vlrdcpre
                     ,vr_vlrdcpos);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao '||vr_dsopera||' as informações na tabela GNINFPL: '||sqlerrm;
          RAISE vr_exc_saida;
      END;
    END IF;
	
    -- Iniciar LOG de execução
    BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 1 -- Processo normal
                              ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy') || ' - ' || 
							                      to_char(sysdate,'hh24:mi:ss')||' - '|| vr_cdprogra ||
												  ' --> Fim da execução paralela  - PA --> '||lpad(pr_idprogra,3,'0')
                              ,pr_nmarqlog     => vr_logprogr); --> Log específico deste programa
    -- Encerrar o job do processamento paralelo dessa agência
    gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                ,pr_idprogra => pr_idprogra
                                ,pr_des_erro => pr_dscritic);
    -- Testar saida com erro
    IF pr_dscritic IS NOT NULL THEN
      -- Levantar exceçao
      RAISE vr_exc_saida;
    END IF;

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => vr_infimsol
                             ,pr_stprogra => vr_stprogra); 
    -- Efetuar commit das alterações
    COMMIT;
  EXCEPTION
    WHEN vr_exc_fimprg THEN

      -- Buscar a descrição
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic, pr_dscritic);

      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratado
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || pr_dscritic );
      -- Novament tenta encerrar o JOB
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => pr_idprogra
                                  ,pr_des_erro => pr_dscritic);
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => vr_infimsol
                               ,pr_stprogra => vr_stprogra);
      -- Limpar variaveis de saida de critica
      pr_cdcritic := 0;
      pr_dscritic := null;
      -- Efetuar commit
      COMMIT;
    WHEN vr_exc_forall THEN
      -- Efetuar rollback
      ROLLBACK;
      -- Iniciar LOG de execução
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratado
                                ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_cdprogra ||' --> '||pr_dscritic
                                ,pr_nmarqlog     => nvl(vr_logprogr,vr_cdprogra)); --> Log específico deste programa

      --Mostrar mensagens de erro no log
      FOR i IN 1..SQL%BULK_EXCEPTIONS.count LOOP
        -- Montar Mensagem
        vr_result:= 'Erro: '||i|| ' Indice: '||SQL%BULK_EXCEPTIONS(i).error_index ||' - '|| 
                    SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE);     
        -- Iniciar LOG de execução
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratado
                                  ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_cdprogra ||' --> '||vr_result
                                  ,pr_nmarqlog     => nvl(vr_logprogr,vr_cdprogra)); --> Log específico deste programa

      END LOOP;
      -- Novament tenta encerrar o JOB
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => pr_idprogra
                                  ,pr_des_erro => pr_dscritic);
    WHEN vr_exc_saida THEN

      -- Buscar a descrição
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic, pr_dscritic);

      -- Efetuar rollback
      ROLLBACK;
      -- Iniciar LOG de execução
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratado
                                ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_cdprogra ||' --> '||pr_dscritic
                                ,pr_nmarqlog     => nvl(vr_logprogr,vr_cdprogra)); --> Log específico deste programa
      
      -- Novament tenta encerrar o JOB
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => pr_idprogra
                                  ,pr_des_erro => pr_dscritic);
    WHEN OTHERS THEN

      cecred.pc_internal_exception(pr_cdcooper);

      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Iniciar LOG de execução
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 3 -- Erro não tratado
                                ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_cdprogra ||' --> '||pr_dscritic
                                ,pr_nmarqlog     => nvl(vr_logprogr,vr_cdprogra)); --> Log específico deste programa
      -- Efetuar rollback
      ROLLBACK;
      -- Novament tenta encerrar o JOB
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => pr_idprogra
                                  ,pr_des_erro => pr_dscritic);
  END;
END pc_crps414_1;
/
