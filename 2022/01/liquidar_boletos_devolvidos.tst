PL/SQL Developer Test script 3.0
719
DECLARE
  --
  pr_cdcooper crapcop.cdcooper%TYPE := 1;
  pr_dtmvtolt crapdat.dtmvtolt%TYPE := TO_DATE('11/01/2022', 'DD/MM/YYYY');
  --
  vr_cdcritic  NUMBER;
  vr_dscritic  VARCHAR2(4000);
  vr_cdcritic2 INTEGER := 0;
  vr_dscritic2 VARCHAR2(4000);
  vr_des_erro  VARCHAR2(3);
  vr_exc_erro             EXCEPTION;
  vr_exc_proximo_registro EXCEPTION;
  --
  vr_vlliquid            NUMBER;
  vr_vldescto            NUMBER;
  vr_vlabatim            NUMBER;
  vr_vlrjuros            NUMBER;
  vr_vlrmulta            NUMBER;
  vr_nrretcoo            VARCHAR2(100);
  vr_nmtelant            VARCHAR2(30) := 'INC0122363';
  vr_dsmotivo            VARCHAR2(100);
  vr_cdagepag            INTEGER;
  vr_cdbanpag            NUMBER(05);
  vr_dtmvtaux            DATE;
  rw_crapdat             BTCH0001.cr_crapdat%ROWTYPE;
  vr_liqaposb            BOOLEAN;
  vr_tab_lcm_consolidada PAGA0001.typ_tab_lcm_consolidada;
  vr_tab_lat_consolidada PAGA0001.typ_tab_lat_consolidada;
  vr_tab_descontar       PAGA0001.typ_tab_titulos;
  vr_nrcnvcob            INTEGER;
  vr_nrdconta            INTEGER;
  vr_nrdocmto            INTEGER;
  vr_aux_cdocorre        NUMBER;
  vr_nrispbif_rec        crapban.nrispbif%TYPE;
  --
  ct_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'INC0122363';
  ct_cdoperad CONSTANT VARCHAR2(100) := '1';
  vr_idprglog tbgen_prglog.idprglog%TYPE;
  --
  CURSOR cr_devolucao(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    SELECT dev.dslinarq
      FROM tbcobran_devolucao dev
          ,crapban            ban
     WHERE dev.cdcooper = pr_cdcooper
       AND dev.dtmvtolt = pr_dtmvtolt
       AND ban.nrispbif(+) = dev.nrispbif
       AND ban.cdbccxlt(+) = decode(ban.nrispbif(+), 0, 1, ban.cdbccxlt(+))
       AND (dev.cdcooper, dev.nrdconta, dev.nrcnvcob, dev.nrdocmto) NOT IN
           ((1, 10622616, 101002, 733), (1, 13715968, 101002, 57));
  --
  -- Selecionar os dados da Cooperativa
  CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT cop.cdcooper
          ,cop.nmrescop
          ,cop.nrtelura
          ,cop.cdbcoctl
          ,cop.cdagectl
          ,cop.dsdircop
          ,cop.nrctactl
          ,cop.cdagedbb
          ,cop.cdageitg
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  --
  CURSOR cr_crapcob(pr_cdcooper IN crapcob.cdcooper%TYPE
                   ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                   ,pr_nrdconta IN crapcob.nrdconta%TYPE
                   ,pr_nrdocmto IN crapcob.nrdocmto%TYPE) IS
    SELECT crapcob.cdcooper
          ,crapcob.flgregis
          ,crapcob.incobran
          ,crapcob.insitcrt
          ,crapcob.cdtitprt
          ,crapcob.nrdconta
          ,crapcob.nrinssac
          ,crapcob.dsdoccop
          ,crapcob.dtvencto
          ,crapcob.vltitulo
          ,crapcob.vldescto
          ,crapcob.vlabatim
          ,crapcob.cdmensag
          ,crapcob.tpdmulta
          ,crapcob.tpjurmor
          ,crapcob.nrcnvcob
          ,crapcob.nrdocmto
          ,crapcob.vlrmulta
          ,crapcob.vljurdia
          ,crapcob.indpagto
          ,crapcob.dtmvtolt
          ,crapcob.rowid
          ,crapcob.inemiten
          ,crapcob.nrctremp
          ,crapcob.vldpagto
          ,crapcob.inserasa
          ,crapcob.dtvctori
          ,crapcob.nrdctabb
          ,crapcob.nrctasac
          ,crapcob.inpagdiv
          ,crapcob.vlminimo
      FROM crapcob
     WHERE crapcob.cdcooper = pr_cdcooper
       AND crapcob.nrcnvcob = pr_nrcnvcob
       AND crapcob.nrdconta = pr_nrdconta
       AND crapcob.nrdocmto = pr_nrdocmto;
  rw_crapcob cr_crapcob%ROWTYPE;
  --
  CURSOR cr_crapcob2(pr_cdcooper IN crapcob.cdcooper%TYPE
                    ,pr_cdbandoc IN crapcco.cddbanco%TYPE
                    ,pr_nrdctabb IN crapcco.nrdctabb%TYPE
                    ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                    ,pr_nrdconta IN crapcob.nrdconta%TYPE
                    ,pr_nrdocmto IN crapcob.nrdocmto%TYPE) IS
    SELECT crapcob.cdcooper
          ,crapcob.flgregis
          ,crapcob.incobran
          ,crapcob.insitcrt
          ,crapcob.cdtitprt
          ,crapcob.nrdconta
          ,crapcob.nrinssac
          ,crapcob.dsdoccop
          ,crapcob.dtvencto
          ,crapcob.vltitulo
          ,crapcob.vldescto
          ,crapcob.vlabatim
          ,crapcob.cdmensag
          ,crapcob.tpdmulta
          ,crapcob.tpjurmor
          ,crapcob.nrcnvcob
          ,crapcob.nrdocmto
          ,crapcob.vlrmulta
          ,crapcob.vljurdia
          ,crapcob.indpagto
          ,crapcob.dtmvtolt
          ,crapcob.rowid
          ,crapcob.inemiten
          ,crapcob.nrctremp
          ,crapcob.vldpagto
          ,crapcob.inserasa
          ,crapcob.dtvctori
          ,crapcob.nrdctabb
          ,crapcob.nrctasac
          ,crapcob.inpagdiv
          ,crapcob.vlminimo
      FROM crapcob
     WHERE crapcob.cdcooper = pr_cdcooper
       AND crapcob.cdbandoc = pr_cdbandoc
       AND crapcob.nrdctabb = pr_nrdctabb
       AND crapcob.nrcnvcob = pr_nrcnvcob
       AND crapcob.nrdconta = pr_nrdconta
       AND crapcob.nrdocmto = pr_nrdocmto;
  rw_crabcob cr_crapcob2%ROWTYPE;
  --
  CURSOR cr_crabcco2(pr_cdcooper IN crapcop.cdcooper%TYPE
                    ,pr_nrconven IN crapcco.nrconven%TYPE) IS
    SELECT crapcco.cdcooper
          ,crapcco.nrconven
          ,crapcco.nrdctabb
          ,crapcco.cddbanco
          ,COUNT(*) OVER(PARTITION BY crapcco.nrconven) qtdreg
      FROM crapcco
     WHERE crapcco.cdcooper = pr_cdcooper
       AND crapcco.nrconven = pr_nrconven;
  --
  rw_crabcco cr_crabcco2%ROWTYPE;
  --
  CURSOR cr_crapban(pr_nrispbif crapban.nrispbif%TYPE) IS
    SELECT ban.cdbccxlt FROM crapban ban WHERE ban.nrispbif = pr_nrispbif;
  --
  CURSOR cr_crapret(pr_cdcooper IN crapret.cdcooper%TYPE
                   ,pr_nrcnvcob IN crapret.nrcnvcob%TYPE
                   ,pr_nrdconta IN crapret.nrdconta%TYPE
                   ,pr_nrdocmto IN crapret.nrdocmto%TYPE
                   ,pr_dtocorre IN crapret.dtocorre%TYPE) IS
    SELECT 1
      FROM crapret ret
     WHERE ret.cdcooper = pr_cdcooper
       AND ret.nrcnvcob = pr_nrcnvcob
       AND ret.nrdconta = pr_nrdconta
       AND ret.nrdocmto = pr_nrdocmto
       AND ret.dtocorre = pr_dtocorre
       AND ret.cdocorre IN (6, 17, 76, 77);
  rw_crapret cr_crapret%ROWTYPE;
  --
  PROCEDURE logarProgramaLocal(pr_dstiplog     IN VARCHAR2
                              ,pr_tpocorrencia IN tbgen_prglog_ocorrencia.tpocorrencia%TYPE DEFAULT 4
                              ,pr_dsmensagem   IN tbgen_prglog_ocorrencia.dsmensagem%TYPE DEFAULT NULL
                              ,pr_idprglog     IN OUT tbgen_prglog.idprglog%TYPE) IS
  BEGIN
    SISTEMA.logarPrograma(pr_dstiplog     => pr_dstiplog
                         ,pr_cdprograma   => ct_cdprogra
                         ,pr_cdcooper     => pr_cdcooper
                         ,pr_tpexecucao   => 0 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         ,pr_tpocorrencia => pr_tpocorrencia
                         ,pr_dsmensagem   => pr_dsmensagem
                         ,pr_idprglog     => pr_idprglog);
  END logarProgramaLocal;
  --
BEGIN
  --
  logarProgramaLocal(pr_dstiplog => 'I', pr_idprglog => vr_idprglog);
  --
  logarProgramaLocal(pr_dstiplog   => 'O'
                    ,pr_dsmensagem => 'Buscando cooperativa ' || pr_cdcooper
                    ,pr_idprglog   => vr_idprglog);
  --
  OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
  FETCH cr_crapcop
    INTO rw_crapcop;
  --Se nao encontrou
  IF cr_crapcop%NOTFOUND THEN
    --Fechar Cursor
    CLOSE cr_crapcop;
    vr_cdcritic := 794;
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    RAISE vr_exc_erro;
  END IF;
  --Fechar Cursor
  CLOSE cr_crapcop;
  --
  logarProgramaLocal(pr_dstiplog   => 'O'
                    ,pr_dsmensagem => 'Buscando informacoes de datas'
                    ,pr_idprglog   => vr_idprglog);
  --
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
  FETCH BTCH0001.cr_crapdat
    INTO rw_crapdat;
  -- Se nao encontrar
  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois havera raise
    CLOSE BTCH0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic := 1;
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    RAISE vr_exc_erro;
  ELSE
    -- Apenas fechar o cursor
    CLOSE BTCH0001.cr_crapdat;
  END IF;
  --
  logarProgramaLocal(pr_dstiplog   => 'O'
                    ,pr_dsmensagem => 'Iniciando loop das devolucoes'
                    ,pr_idprglog   => vr_idprglog);
  --
  FOR rw_devolucao IN cr_devolucao(pr_cdcooper => rw_crapcop.cdcooper, pr_dtmvtolt => pr_dtmvtolt) LOOP
    BEGIN
      --
      logarProgramaLocal(pr_dstiplog   => 'O'
                        ,pr_dsmensagem => 'Extraindo campos necessarios da linha ' ||
                                          rw_devolucao.dslinarq
                        ,pr_idprglog   => vr_idprglog);
      --
      vr_vlliquid := TO_NUMBER(TRIM(SUBSTR(rw_devolucao.dslinarq, 85, 12))) / 100;
      vr_nrcnvcob := TO_NUMBER(TRIM(SUBSTR(rw_devolucao.dslinarq, 20, 6)));
      vr_nrdconta := TO_NUMBER(TRIM(SUBSTR(rw_devolucao.dslinarq, 26, 8)));
      vr_nrdocmto := TO_NUMBER(TRIM(SUBSTR(rw_devolucao.dslinarq, 34, 9)));
      --ISPB da recebedora
      vr_nrispbif_rec := SUBSTR(rw_devolucao.dslinarq, 132, 8);
      --
      vr_liqaposb := FALSE;
      vr_tab_lcm_consolidada.delete;
      vr_tab_lat_consolidada.delete;
      --
      logarProgramaLocal(pr_dstiplog   => 'O'
                        ,pr_dsmensagem => 'Verificando a crapret do boleto pr_cdcooper:' ||
                                          rw_crapcop.cdcooper || ',pr_nrcnvcob:' || vr_nrcnvcob ||
                                          ',pr_nrdconta:' || vr_nrdconta || ',pr_nrdocmto:' ||
                                          vr_nrdocmto
                        ,pr_idprglog   => vr_idprglog);
      --
      OPEN cr_crapret(pr_cdcooper => rw_crapcop.cdcooper
                     ,pr_nrcnvcob => vr_nrcnvcob
                     ,pr_nrdconta => vr_nrdconta
                     ,pr_nrdocmto => vr_nrdocmto
                     ,pr_dtocorre => rw_crapdat.dtmvtolt);
      FETCH cr_crapret
        INTO rw_crapret;
      IF cr_crapret%FOUND THEN
        --
        CLOSE cr_crapret;
        --
        logarProgramaLocal(pr_dstiplog   => 'O'
                          ,pr_dsmensagem => 'Crapret de liquidacao ja existe para o dia informado, passando para o proximo registro pr_cdcooper:' ||
                                            rw_crapcop.cdcooper || ',pr_nrcnvcob:' || vr_nrcnvcob ||
                                            ',pr_nrdconta:' || vr_nrdconta || ',pr_nrdocmto:' ||
                                            vr_nrdocmto
                          ,pr_idprglog   => vr_idprglog);
        --
        CONTINUE;
        --
      ELSE
        --
        CLOSE cr_crapret;
        --
      END IF;
      --
      logarProgramaLocal(pr_dstiplog   => 'O'
                        ,pr_dsmensagem => 'Buscando dados do boleto pr_cdcooper:' ||
                                          rw_crapcop.cdcooper || ',pr_nrcnvcob:' || vr_nrcnvcob ||
                                          ',pr_nrdconta:' || vr_nrdconta || ',pr_nrdocmto:' ||
                                          vr_nrdocmto
                        ,pr_idprglog   => vr_idprglog);
      --
      -- Validar se registro esta disponivel para pagto
      OPEN cr_crapcob(pr_cdcooper => rw_crapcop.cdcooper
                     ,pr_nrcnvcob => vr_nrcnvcob
                     ,pr_nrdconta => vr_nrdconta
                     ,pr_nrdocmto => vr_nrdocmto);
      FETCH cr_crapcob
        INTO rw_crapcob;
      CLOSE cr_crapcob;
      --
      -- aceita titulos em aberto, baixados e ja pagos
      IF rw_crapcob.incobran = 5 THEN
        --
        logarProgramaLocal(pr_dstiplog   => 'O'
                          ,pr_dsmensagem => 'Boleto ja pago:' || rw_crapcob.rowid
                          ,pr_idprglog   => vr_idprglog);
        --
        -- flg para realizar liquidacao apos baixa 
        vr_liqaposb := TRUE;
        -- Gerar LOG 085 
        IF nvl(rw_crapcob.flgregis, 0) = 1 THEN
          --
          logarProgramaLocal(pr_dstiplog   => 'O'
                            ,pr_dsmensagem => 'Gera log da liquidacao de boleto pago:' ||
                                              rw_crapcob.rowid
                            ,pr_idprglog   => vr_idprglog);
          --
          --Criar log Cobranca
          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                       ,pr_cdoperad => ct_cdoperad --Operador
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data movimento
                                       ,pr_dsmensag => 'Liquidacao de boleto pago' --Descricao Mensagem
                                       ,pr_des_erro => vr_des_erro --Indicador erro
                                       ,pr_dscritic => vr_dscritic); --Descricao erro
          --Se ocorreu erro
          IF vr_des_erro = 'NOK' THEN
            --
            logarProgramaLocal(pr_dstiplog     => 'E'
                              ,pr_tpocorrencia => 2
                              ,pr_dsmensagem   => '(1) vr_dscritic:' || vr_dscritic
                              ,pr_idprglog     => vr_idprglog);
            --
            --Levantar Excecao
            RAISE vr_exc_proximo_registro;
          END IF;
        END IF;
      END IF;
      --
      -- se titulo baixado p/ protesto (941) ou baixado (943), criticar... 
      IF nvl(rw_crapcob.flgregis, 0) = 1 AND rw_crapcob.incobran = 3 AND
         rw_crapcob.insitcrt IN (0, 1) THEN
        -- flg para realizar liquidacao apos baixa 
        vr_liqaposb := TRUE;
        IF rw_crapcob.insitcrt = 1 THEN
          --
          logarProgramaLocal(pr_dstiplog   => 'O'
                            ,pr_dsmensagem => 'Boleto com instrucao de protesto:' ||
                                              rw_crapcob.rowid
                            ,pr_idprglog   => vr_idprglog);
          --        
          -- se existir informacao do titulo enviado p/ protesto 
          IF TRIM(rw_crapcob.cdtitprt) IS NOT NULL THEN
            --Inicializar Valor Despesas
            --
            logarProgramaLocal(pr_dstiplog   => 'O'
                              ,pr_dsmensagem => 'Buscar convenio pr_cdcooper:' ||
                                                gene0002.fn_busca_entrada(1
                                                                         ,rw_crapcob.cdtitprt
                                                                         ,';') || ',pr_nrconven:' ||
                                                gene0002.fn_busca_entrada(3
                                                                         ,rw_crapcob.cdtitprt
                                                                         ,';')
                              ,pr_idprglog   => vr_idprglog);
            --        
            --Selecionar Convenio
            OPEN cr_crabcco2(pr_cdcooper => gene0002.fn_busca_entrada(1, rw_crapcob.cdtitprt, ';')
                            ,pr_nrconven => gene0002.fn_busca_entrada(3, rw_crapcob.cdtitprt, ';'));
            FETCH cr_crabcco2
              INTO rw_crabcco;
            --Se Encontrou Convenio
            IF cr_crabcco2%FOUND AND rw_crabcco.qtdreg = 1 THEN
              --Fechar Cursor
              CLOSE cr_crabcco2;
              --
              logarProgramaLocal(pr_dstiplog   => 'O'
                                ,pr_dsmensagem => 'Buscar boleto com instrucao de protesto:' ||
                                                  rw_crapcob.rowid
                                ,pr_idprglog   => vr_idprglog);
              --        
              --Encontrar Cobrancas
              OPEN cr_crapcob2(pr_cdcooper => gene0002.fn_busca_entrada(1, rw_crapcob.cdtitprt, ';')
                              ,pr_nrdconta => gene0002.fn_busca_entrada(2, rw_crapcob.cdtitprt, ';')
                              ,pr_nrcnvcob => gene0002.fn_busca_entrada(3, rw_crapcob.cdtitprt, ';')
                              ,pr_nrdocmto => gene0002.fn_busca_entrada(4, rw_crapcob.cdtitprt, ';')
                              ,pr_nrdctabb => rw_crabcco.nrdctabb
                              ,pr_cdbandoc => rw_crabcco.cddbanco);
              FETCH cr_crapcob2
                INTO rw_crabcob;
              --Se encontrou
              IF cr_crapcob2%FOUND THEN
                --Fechar Cursor
                CLOSE cr_crapcob2;
                -- Ajusta o parametro com a regra de evitar o nulo - 21/03/2019 - REQ0037942  
                --
                logarProgramaLocal(pr_dstiplog   => 'O'
                                  ,pr_dsmensagem => 'Sustar e baixar boleto:' || rw_crapcob.rowid
                                  ,pr_idprglog   => vr_idprglog);
                --        
                --Determinar a data para sustar
                vr_dtmvtaux := rw_crapdat.dtmvtolt;
                -- Sustar a baixa 
                COBR0007.pc_inst_sustar_baixar(pr_cdcooper            => rw_crabcob.cdcooper --Codigo Cooperativa
                                              ,pr_nrdconta            => rw_crabcob.nrdconta --Numero da Conta
                                              ,pr_nrcnvcob            => rw_crabcob.nrcnvcob --Numero Convenio
                                              ,pr_nrdocmto            => rw_crabcob.nrdocmto --Numero Documento
                                              ,pr_dtmvtolt            => vr_dtmvtaux --Data pagamento
                                              ,pr_cdoperad            => ct_cdoperad --Operador
                                              ,pr_nrremass            => 0 --Numero Remessa
                                              ,pr_tab_lat_consolidada => vr_tab_lat_consolidada
                                              ,pr_cdcritic            => vr_cdcritic2
                                              ,pr_dscritic            => vr_dscritic2);
                --Se ocorreu erro
                IF vr_cdcritic2 IS NOT NULL OR vr_dscritic2 IS NOT NULL THEN
                  --
                  logarProgramaLocal(pr_dstiplog     => 'E'
                                    ,pr_tpocorrencia => 2
                                    ,pr_dsmensagem   => '(2) vr_cdcritic2:' || vr_cdcritic2 ||
                                                        ',vr_dscritic2:' || vr_dscritic2
                                    ,pr_idprglog     => vr_idprglog);
                  --
                  NULL;
                END IF;
                --
                logarProgramaLocal(pr_dstiplog   => 'O'
                                  ,pr_dsmensagem => 'Gerar log de liquidacao apos baixa no boleto:' ||
                                                    rw_crapcob.rowid
                                  ,pr_idprglog   => vr_idprglog);
                --        
                -- Gerar LOG 085
                PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                             ,pr_cdoperad => ct_cdoperad --Operador
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data movimento
                                             ,pr_dsmensag => 'Liquidacao apos baixa' --Descricao Mensagem
                                             ,pr_des_erro => vr_des_erro --Indicador erro
                                             ,pr_dscritic => vr_dscritic2); --Descricao erro
                --Se ocorreu erro
                IF vr_des_erro = 'NOK' THEN
                  --
                  logarProgramaLocal(pr_dstiplog     => 'E'
                                    ,pr_tpocorrencia => 2
                                    ,pr_dsmensagem   => '(3) vr_dscritic2:' || vr_dscritic2
                                    ,pr_idprglog     => vr_idprglog);
                  --
                  --Levantar Excecao
                  RAISE vr_exc_proximo_registro;
                END IF;
                --
                logarProgramaLocal(pr_dstiplog   => 'O'
                                  ,pr_dsmensagem => 'Gerar log de liquidacao do boleto no convenio 085 no boleto:' ||
                                                    rw_crapcob.rowid
                                  ,pr_idprglog   => vr_idprglog);
                --        
                -- Gerar LOG 001 [BB]
                PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crabcob.rowid --ROWID da Cobranca
                                             ,pr_cdoperad => ct_cdoperad --Operador
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data movimento
                                             ,pr_dsmensag => 'Liquidacao do boleto no convenio 085' --Descricao Mensagem
                                             ,pr_des_erro => vr_des_erro --Indicador erro
                                             ,pr_dscritic => vr_dscritic2); --Descricao erro
                --Se ocorreu erro
                IF vr_des_erro = 'NOK' THEN
                  --
                  logarProgramaLocal(pr_dstiplog     => 'E'
                                    ,pr_tpocorrencia => 2
                                    ,pr_dsmensagem   => '(4) vr_dscritic2:' || vr_dscritic2
                                    ,pr_idprglog     => vr_idprglog);
                  --
                  --Levantar Excecao
                  RAISE vr_exc_proximo_registro;
                END IF;
                --
              END IF; --cr_crapcob2%FOUND
              --Fechar Cursor
              IF cr_crapcob2%ISOPEN THEN
                CLOSE cr_crapcob2;
              END IF;
            END IF; --cr_crabcco%FOUND
            --Fechar Cursor
            IF cr_crabcco2%ISOPEN THEN
              CLOSE cr_crabcco2;
            END IF;
            --
          END IF; --rw_crapcob.cdtitprt IS NOT NULL
        ELSIF rw_crapcob.insitcrt = 0 THEN
          --
          logarProgramaLocal(pr_dstiplog   => 'O'
                            ,pr_dsmensagem => 'Boleto ja baixado:' || rw_crapcob.rowid
                            ,pr_idprglog   => vr_idprglog);
          --        
          -- Gerar LOG 085 
          IF nvl(rw_crapcob.flgregis, 0) = 1 THEN
            --
            logarProgramaLocal(pr_dstiplog   => 'O'
                              ,pr_dsmensagem => 'Gerar log de liquidacao apos baixa:' ||
                                                rw_crapcob.rowid
                              ,pr_idprglog   => vr_idprglog);
            --        
            --Criar log Cobranca
            PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                         ,pr_cdoperad => ct_cdoperad --Operador
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data movimento
                                         ,pr_dsmensag => 'Liquidacao apos baixa' --Descricao Mensagem
                                         ,pr_des_erro => vr_des_erro --Indicador erro
                                         ,pr_dscritic => vr_dscritic2); --Descricao erro
            --Se ocorreu erro
            IF vr_des_erro = 'NOK' THEN
              --
              logarProgramaLocal(pr_dstiplog     => 'E'
                                ,pr_tpocorrencia => 2
                                ,pr_dsmensagem   => '(5) vr_dscritic2:' || vr_dscritic2
                                ,pr_idprglog     => vr_idprglog);
              --
              --Levantar Excecao
              RAISE vr_exc_proximo_registro;
            END IF;
            --
          END IF;
        END IF; --rw_crapcob.insitcrt = 1
        --
        --Inicializar variaveis erro
        vr_cdcritic := 0;
        vr_dscritic := NULL;
      END IF; --protesto (941 e 943)
      --
      --
      logarProgramaLocal(pr_dstiplog   => 'O'
                        ,pr_dsmensagem => 'Carregar dados da liquidacao:' || rw_crapcob.rowid
                        ,pr_idprglog   => vr_idprglog);
      --        
      vr_vlrjuros := 0;
      vr_vlrmulta := 0;
      vr_vldescto := 0;
      vr_vlabatim := rw_crapcob.vlabatim;
      --
      --Determinar o tipo de liquidacao
      CASE SUBSTR(rw_devolucao.dslinarq, 50, 1)
        WHEN '1' THEN
          vr_dsmotivo := '03'; --Liquidaçao no Guiche de Caixa
        WHEN '2' THEN
          vr_dsmotivo := '32'; --Liquidaçao Terminal de Auto-Atendimento
        WHEN '3' THEN
          vr_dsmotivo := '33'; --Liquidaçao na Internet (Home banking)
        WHEN '5' THEN
          vr_dsmotivo := '31'; --Liquidaçao Banco Correspondente
        WHEN '6' THEN
          vr_dsmotivo := '37'; --Liquidaçao por Telefone
        WHEN '7' THEN
          vr_dsmotivo := '06'; --Liquidaçao Arquivo Eletronico
        ELSE
          NULL;
      END CASE;
      --> Buscar codigo do banco recebedor
      vr_cdbanpag := NULL;
      OPEN cr_crapban(pr_nrispbif => vr_nrispbif_rec);
      FETCH cr_crapban
        INTO vr_cdbanpag;
      CLOSE cr_crapban;
      --
      -- buscar banco/agencia origem do pagamento (Rafael)
      BEGIN
        vr_cdagepag := TO_NUMBER(TRIM(SUBSTR(rw_devolucao.dslinarq, 57, 4)));
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
          CECRED.pc_internal_exception(pr_cdcooper => rw_crapcop.cdcooper);
          vr_cdbanpag := rw_crapcop.cdbcoctl;
          vr_cdagepag := rw_crapcop.cdagectl;
      END;
      --
      vr_dtmvtaux := rw_crapdat.dtmvtolt;
      -- se nao for liquidacao de titulo já pago, entao liq normal
      IF NOT vr_liqaposb THEN
        --
        logarProgramaLocal(pr_dstiplog   => 'O'
                          ,pr_dsmensagem => 'Liquidacao normal:' || rw_crapcob.rowid
                          ,pr_idprglog   => vr_idprglog);
        --        
        IF rw_crapcob.inemiten = 3 THEN
          vr_aux_cdocorre := 76;
        ELSE
          vr_aux_cdocorre := 6;
        END IF;
      
        -- Ajusta o parametro com a regra de evitar o nulo - 21/03/2019 - REQ0037942                   
        --Processar liquidacao
        PAGA0001.pc_processa_liquidacao(pr_idtabcob            => rw_crapcob.rowid --Rowid da Cobranca
                                       ,pr_nrnosnum            => 0 --Nosso Numero
                                       ,pr_nrispbpg            => vr_nrispbif_rec --Numero ISPB do pagador
                                       ,pr_cdbanpag            => vr_cdbanpag --Codigo banco pagamento
                                       ,pr_cdagepag            => vr_cdagepag --Codigo Agencia pagamento
                                       ,pr_vltitulo            => nvl(rw_crapcob.vltitulo, 0) --Valor do titulo
                                       ,pr_vlliquid            => 0 --Valor Liquidacao
                                       ,pr_vlrpagto            => nvl(vr_vlliquid, 0) --Valor pagamento
                                       ,pr_vlabatim            => 0 --Valor abatimento
                                       ,pr_vldescto            => nvl(vr_vldescto, 0) +
                                                                  nvl(vr_vlabatim, 0) --Valor desconto
                                       ,pr_vlrjuros            => nvl(vr_vlrjuros, 0) +
                                                                  nvl(vr_vlrmulta, 0) --Valor juros
                                       ,pr_vloutdeb            => 0 --Valor saida debito
                                       ,pr_vloutcre            => 0 --Valor saida credito
                                       ,pr_dtocorre            => vr_dtmvtaux --Data Ocorrencia
                                       ,pr_dtcredit            => rw_crapdat.dtmvtolt --Data Credito
                                       ,pr_cdocorre            => vr_aux_cdocorre --Codigo Ocorrencia
                                       ,pr_dsmotivo            => vr_dsmotivo --Descricao Motivo
                                       ,pr_dtmvtolt            => vr_dtmvtaux --Data movimento
                                       ,pr_cdoperad            => '1' --Codigo Operador
                                       ,pr_indpagto            => rw_crapcob.indpagto --Indicador pagamento -- 0-COMPE 1-Caixa On-Line 3-Internet 4-TAA 
                                       ,pr_ret_nrremret        => vr_nrretcoo --Numero remetente
                                       ,pr_nmtelant            => vr_nmtelant --Verificar COMPEFORA                                                   
                                       ,pr_cdcritic            => vr_cdcritic --Codigo Critica
                                       ,pr_dscritic            => vr_dscritic --Descricao Critica
                                       ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada --Tabela lancamentos consolidada
                                       ,pr_tab_descontar       => vr_tab_descontar); --Tabela de titulos
      ELSE
        --
        logarProgramaLocal(pr_dstiplog   => 'O'
                          ,pr_dsmensagem => 'Boleto liquidacao apos baixa:' || rw_crapcob.rowid
                          ,pr_idprglog   => vr_idprglog);
        --        
        IF rw_crapcob.inemiten = 3 THEN
          vr_aux_cdocorre := 77;
        ELSE
          vr_aux_cdocorre := 17;
        END IF;
      
        --Processar Liquidacao apos baixa
        PAGA0001.pc_proc_liquid_apos_baixa(pr_idtabcob            => rw_crapcob.rowid --Rowid da Cobranca
                                          ,pr_nrnosnum            => 0 --Nosso Numero
                                          ,pr_nrispbpg            => vr_nrispbif_rec --Numero ISPB do pagador
                                          ,pr_cdbanpag            => vr_cdbanpag --Codigo banco pagamento
                                          ,pr_cdagepag            => vr_cdagepag --Codigo Agencia pagamento
                                          ,pr_vltitulo            => nvl(rw_crapcob.vltitulo, 0) --Valor do titulo
                                          ,pr_vlliquid            => 0 --Valor Liquidacao
                                          ,pr_vlrpagto            => nvl(vr_vlliquid, 0) --Valor pagamento
                                          ,pr_vlabatim            => 0 --Valor abatimento
                                          ,pr_vldescto            => nvl(vr_vldescto, 0) +
                                                                     nvl(vr_vlabatim, 0) --Valor desconto
                                          ,pr_vlrjuros            => 0 --Valor juros
                                          ,pr_vloutdeb            => 0 --Valor saida debito
                                          ,pr_vloutcre            => 0 --Valor saida credito
                                          ,pr_dtocorre            => vr_dtmvtaux --Data Ocorrencia
                                          ,pr_dtcredit            => rw_crapdat.dtmvtolt --Data Credito
                                          ,pr_cdocorre            => vr_aux_cdocorre --Codigo Ocorrencia
                                          ,pr_dsmotivo            => vr_dsmotivo --Descricao Motivo
                                          ,pr_dtmvtolt            => vr_dtmvtaux --Data movimento
                                          ,pr_cdoperad            => '1' --Codigo Operador
                                          ,pr_indpagto            => rw_crapcob.indpagto --Indicador pagamento -- 0-COMPE 1-Caixa On-Line 3-Internet 4-TAA 
                                          ,pr_ret_nrremret        => vr_nrretcoo --Numero remetente
                                          ,pr_cdcritic            => vr_cdcritic --Codigo Critica
                                          ,pr_dscritic            => vr_dscritic --Descricao Critica
                                          ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada); --Tabela lancamentos consolidada
      END IF;
      --
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --
        logarProgramaLocal(pr_dstiplog     => 'E'
                          ,pr_tpocorrencia => 2
                          ,pr_dsmensagem   => '(6) vr_cdcritic:' || vr_cdcritic || ',vr_dscritic:' ||
                                              vr_dscritic
                          ,pr_idprglog     => vr_idprglog);
        --
        RAISE vr_exc_proximo_registro;
      END IF;
      --
    EXCEPTION
      WHEN vr_exc_proximo_registro THEN
        vr_cdcritic := 0;
        vr_dscritic := NULL;
    END;
  END LOOP;
  --
  COMMIT;
  --
  logarProgramaLocal(pr_dstiplog   => 'O'
                    ,pr_dsmensagem => 'Fim do processamento' || rw_crapcob.rowid
                    ,pr_idprglog   => vr_idprglog);
  --        
  logarProgramaLocal(pr_dstiplog => 'F', pr_idprglog => vr_idprglog);
  --
EXCEPTION
  WHEN vr_exc_erro THEN
    --
    logarProgramaLocal(pr_dstiplog     => 'E'
                      ,pr_tpocorrencia => 2
                      ,pr_dsmensagem   => '(12) vr_cdcritic:' || vr_cdcritic || ',vr_dscritic:' ||
                                          vr_dscritic
                      ,pr_idprglog     => vr_idprglog);
    --
    raise_application_error(-20501, vr_cdcritic || ' - ' || vr_dscritic);
    ROLLBACK;
    logarProgramaLocal(pr_dstiplog => 'F', pr_idprglog => vr_idprglog);
    --
  WHEN OTHERS THEN
    --
    SISTEMA.excecaoInterna;
    --
    logarProgramaLocal(pr_dstiplog     => 'E'
                      ,pr_tpocorrencia => 2
                      ,pr_dsmensagem   => '(13) SQLERRM:' || SQLERRM
                      ,pr_idprglog     => vr_idprglog);
    --
    raise_application_error(-20500, SQLERRM);
    ROLLBACK;
    logarProgramaLocal(pr_dstiplog => 'F', pr_idprglog => vr_idprglog);
    --
END;
0
0
