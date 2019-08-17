PL/SQL Developer Test script 3.0
666
DECLARE 
  W_GLB_IDARQUIVO NUMBER := 0; 
  
  procedure pc_credito_manual_ASLC024(pr_dtprocesso IN crapdat.dtmvtolt%TYPE) is
  begin
  DECLARE
      vr_tab_retorno    LANC0001.typ_reg_retorno;
      vr_incrineg       INTEGER;  --> Indicador de crítica de negócio para uso com a "pc_gerar_lancamento_conta"
      rw_crapdat cecred.btch0001.cr_crapdat%ROWTYPE;
      pr_cdcritic number := null;
      pr_dscritic  VARCHAR2(3000);
      
      -- Cursor sobre os registros pendentes
      CURSOR cr_lancamento IS
        SELECT  arq.idarquivo
               ,arq.nmarquivo_origem
               ,lct.nrcnpj_credenciador
               ,lct.nrcnpjbase_principal
               ,arq.tparquivo
               ,to_date(arq.dtreferencia,'YYYY-MM-DD') dtreferencia
               ,lct.dhprocessamento
               ,lct.idlancto
               ,pdv.dtpagamento
               ,pdv.tpforma_transf
               ,sum(pdv.vlpagamento) vlpagamento
           FROM tbdomic_liqtrans_lancto lct
               ,tbdomic_liqtrans_arquivo arq
               ,tbdomic_liqtrans_centraliza ctz
               ,tbdomic_liqtrans_pdv pdv
          WHERE 
          lct.idarquivo = arq.idarquivo  AND 
          ARQ.IDARQUIVO = W_GLB_IDARQUIVO --> Global criada neste BACA para evitar esequecer de mudar o arquivo !!!!!!!!!!!!! 
            AND ctz.idlancto = lct.idlancto
            AND pdv.idcentraliza = ctz.idcentraliza
            -- Registros enviados para CIP/Aguardando Aprovação
            -- No final será alterado a situacao para 2-Processado
       GROUP BY arq.idarquivo,arq.nmarquivo_origem,
                lct.nrcnpj_credenciador, lct.nrcnpjbase_principal, arq.tparquivo, to_date(arq.dtreferencia,'YYYY-MM-DD'), lct.dhprocessamento, lct.idlancto
                ,pdv.dtpagamento
                ,pdv.tpforma_transf
       ORDER BY arq.tparquivo,lct.nrcnpj_credenciador, lct.nrcnpjbase_principal, to_date(arq.dtreferencia,'YYYY-MM-DD');

      -- Cursor para informações dos lançamentos
      CURSOR cr_tabela(pr_idlancto tbdomic_liqtrans_lancto.idlancto%TYPE,pr_tpforma_transf tbdomic_liqtrans_pdv.tpforma_transf%TYPE) IS         
      SELECT pdv.nrliquidacao
            ,ctz.nrcnpjcpf_centraliza
            ,ctz.tppessoa_centraliza
            ,ctz.cdagencia_centraliza
            ,ctz.nrcta_centraliza
            ,pdv.vlpagamento
            /*Devido ao script estar sendo executado dia no seguinte ao recebimento do arquivo origem (ASLC032), 
              precisamos forçar a data de pagamento com a data atual. Desta forma, todos os pagamentos serão 
              efetuados na data corrente.
            OBS.: Caso não for forçado a data, todos os pagamentos serão considerados como agendamento e isto não pode 
                  ocorrer, pois este script está efetuando o lançamento referente ao arquivo de antecipação.
            */
            --,to_date(pdv.dtpagamento,'YYYY-MM-DD') dtpagamento 
            ,trunc(SYSDATE) dtpagamento            
            ,pdv.idpdv
            ,pdv.cdocorrencia
            ,pdv.cdocorrencia_retorno
            ,pdv.dserro
            ,pdv.dsocorrencia_retorno
            ,pdv.tpforma_transf
        FROM tbdomic_liqtrans_centraliza ctz
            ,tbdomic_liqtrans_pdv pdv
            ,tbdomic_liqtrans_lancto lct
            ,tbdomic_liqtrans_arquivo arq
       WHERE ctz.idlancto = pr_idlancto
         AND pdv.idcentraliza = ctz.idcentraliza
         AND lct.idarquivo = arq.idarquivo
         AND ctz.idlancto = lct.idlancto
         AND arq.tparquivo = 3 --Apenas arquivos de antecipação
         AND pdv.dsocorrencia_retorno IS NULL            --Só vai atualizar os registros que não retornaram com erro da CIP
       ORDER BY ctz.cdagencia_centraliza,ctz.nrcta_centraliza,to_date(pdv.dtpagamento,'YYYY-MM-DD');


      -- Cursor sobre as agencias
      CURSOR cr_crapcop IS
        SELECT cdcooper,
               cdagectl,
               nmrescop,
               flgativo
          FROM crapcop;

      CURSOR cr_craptco (pr_cdcopant IN crapcop.cdcooper%TYPE,
                         pr_nrctaant IN craptco.nrctaant%TYPE) IS
        SELECT tco.nrdconta,
               tco.cdcooper
          FROM craptco tco
         WHERE tco.cdcopant = pr_cdcopant
           AND tco.nrctaant = pr_nrctaant;
      rw_craptco cr_craptco%ROWTYPE;

      -- PL/Table para armazenar as agencias
      type typ_crapcop IS RECORD (cdcooper crapcop.cdcooper%TYPE,
                                  nmrescop crapcop.nmrescop%TYPE,
                                  flgativo crapcop.flgativo%TYPE);
      type typ_tab_crapcop IS TABLE OF typ_crapcop INDEX BY PLS_INTEGER;
      vr_crapcop       typ_tab_crapcop;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(32000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_erro          EXCEPTION;

      -- Variaveis gerais
      vr_nrseqdiglcm   craplcm.nrseqdig%TYPE;
      vr_nrseqdiglau   craplau.nrseqdig%TYPE;
      vr_dserro        VARCHAR2(100);         --> Variavel de erro
      vr_dserro_arq    VARCHAR2(100);         --> Variavel de erro do reg arquivo
      vr_cdocorr       VARCHAR2(2) := NULL;   --> Código de ocorrencia do pdv
      vr_cdocorr_arq   VARCHAR2(2) := NULL;   --> Código de ocorrencia do reg arquivo
      vr_inpessoa      crapass.inpessoa%TYPE; --> Indicador de tipo de pessoa
      vr_cdcooper      crapcop.cdcooper%TYPE; --> Codigo da cooperativa
      vr_cdhistor      craphis.cdhistor%TYPE; --> Codigo do historico do lancamento
      vr_nrdolote      craplcm.nrdolote%TYPE; --> Numero do lote
      vr_qterros       PLS_INTEGER := 0;      --> Quantidade de registros com erro
      vr_qtprocessados PLS_INTEGER := 0;      --> Quantidade de registros processados
      vr_qtfuturos     PLS_INTEGER := 0;      --> Quantidade de lancamentos futuros processados
      vr_inlctfut      VARCHAR2(01);          --> Indicador de lancamento futuro

      vr_coopdest      crapcop.cdcooper%TYPE; --> coop destino (incorporacao/migracao)
      vr_nrdconta      crapass.nrdconta%TYPE;
      vr_cdcooper_lcm  craplcm.cdcooper%TYPE; --> Variável para controle de quebra na gravacao da craplcm
      vr_cdcooper_lau  craplau.cdcooper%TYPE; --> Variável para controle de quebra na gravacao da craplcm
      vr_dtprocesso    crapdat.dtmvtolt%TYPE; --> Data da cooperativa
      vr_qtproclancto  PLS_INTEGER := 0;      --> Quantidade de registros lidos do lancamento

      -- Variáveis email
      vr_para              varchar2(300);
      vr_assunto           varchar2(300);
      vr_mensagem          varchar2(32767);



    PROCEDURE pc_procura_ultseq_craplcm (pr_cdcooper IN  crapcop.cdcooper%TYPE
                                        ,pr_dtmvtolt IN  craplcm.dtmvtolt%TYPE
                                        ,pr_cdagenci IN  craplcm.cdagenci%TYPE
                                        ,pr_cdbccxlt IN  craplcm.cdbccxlt%TYPE
                                        ,pr_nrdolote IN  craplcm.nrdolote%TYPE
                                        ,pr_nrseqdiglcm OUT craplcm.nrseqdig%TYPE
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                        ,pr_dscritic OUT VARCHAR2)  IS

      -- Cursor para buscar ultimo documento

      CURSOR cr_ult_craplcm(pr_cdcooper IN  crapcop.cdcooper%TYPE
                           ,pr_dtmvtolt IN  craplcm.dtmvtolt%TYPE
                           ,pr_cdagenci IN  craplcm.cdagenci%TYPE
                           ,pr_cdbccxlt IN  craplcm.cdbccxlt%TYPE
                           ,pr_nrdolote IN  craplcm.nrdolote%TYPE) IS
        SELECT  MAX(lcm.nrseqdig) nrseqdig
           FROM craplcm lcm
          WHERE lcm.cdcooper = pr_cdcooper
            AND lcm.dtmvtolt = pr_dtmvtolt
            AND lcm.cdagenci = pr_cdagenci
            AND lcm.cdbccxlt = pr_cdbccxlt
            AND lcm.nrdolote = pr_nrdolote;

       rw_ult_craplcm cr_ult_craplcm%ROWTYPE;

    BEGIN
      OPEN cr_ult_craplcm(pr_cdcooper, pr_dtmvtolt, pr_cdagenci, pr_cdbccxlt, pr_nrdolote);
      FETCH cr_ult_craplcm INTO rw_ult_craplcm;
      IF cr_ult_craplcm%NOTFOUND THEN
         pr_nrseqdiglcm := 1;
      ELSE
         pr_nrseqdiglcm := nvl(rw_ult_craplcm.nrseqdig,0) + 1;
      END IF;
      CLOSE cr_ult_craplcm;

    EXCEPTION
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
    END; --pc_procura_ultseq_craplcm

    PROCEDURE pc_procura_ultseq_craplau(pr_cdcooper IN  crapcop.cdcooper%TYPE
                                       ,pr_dtmvtolt IN  craplau.dtmvtolt%TYPE
                                       ,pr_cdagenci IN  craplau.cdagenci%TYPE
                                       ,pr_cdbccxlt IN  craplau.cdbccxlt%TYPE
                                       ,pr_nrdolote IN  craplau.nrdolote%TYPE
                                       ,pr_nrseqdiglau OUT craplau.nrseqdig%TYPE
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                       ,pr_dscritic OUT VARCHAR2) IS

      -- Cursor para buscar ultimo documento

      CURSOR cr_ult_craplau(pr_cdcooper IN  crapcop.cdcooper%TYPE
                           ,pr_dtmvtolt IN  craplau.dtmvtolt%TYPE
                           ,pr_cdagenci IN  craplau.cdagenci%TYPE
                           ,pr_cdbccxlt IN  craplau.cdbccxlt%TYPE
                           ,pr_nrdolote IN  craplau.nrdolote%TYPE) IS
        SELECT  MAX(lau.nrseqdig) nrseqdig
           FROM craplau lau
          WHERE lau.cdcooper = pr_cdcooper
            AND lau.dtmvtolt = pr_dtmvtolt
            and lau.cdagenci = pr_cdagenci
            AND lau.cdbccxlt = pr_cdbccxlt
            AND lau.nrdolote = pr_nrdolote;

       rw_ult_craplau cr_ult_craplau%ROWTYPE;

    BEGIN
      OPEN cr_ult_craplau(pr_cdcooper, pr_dtmvtolt, pr_cdagenci, pr_cdbccxlt, pr_nrdolote);
      FETCH cr_ult_craplau INTO rw_ult_craplau;
      IF cr_ult_craplau%NOTFOUND THEN
         pr_nrseqdiglau := 1;
      ELSE
         pr_nrseqdiglau := nvl(rw_ult_craplau.nrseqdig,0) + 1;
      END IF;
      CLOSE cr_ult_craplau;

    EXCEPTION
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
    END; --pc_procura_ultseq_craplau

BEGIN
  dbms_output.enable(10000000);

      -- Popula a pl/table de agencia
      FOR rw_crapcop IN cr_crapcop LOOP
        vr_crapcop(rw_crapcop.cdagectl).cdcooper := rw_crapcop.cdcooper;
        vr_crapcop(rw_crapcop.cdagectl).nmrescop := rw_crapcop.nmrescop;
        vr_crapcop(rw_crapcop.cdagectl).flgativo := rw_crapcop.flgativo;
      END LOOP;

      -- Efetua loop sobre os registros pendentes
      FOR rw_lancamento IN cr_lancamento LOOP


        -- Limpa variaveis de controle de quebra para gravacao da craplcm e craplau
        -- Como trata-se de um novo tipo de arquivo precisa-se limpar pois o numero
        -- do lote será alterado.
        vr_cdcooper_lcm := 0;
        vr_cdcooper_lau := 0;

        -- Limpa a variavel de erro
        vr_dserro_arq   := NULL;
        vr_cdocorr_arq  := NULL;
        -- Criticar tipo de arquivo.
        IF rw_lancamento.tparquivo NOT in (1,2,3) THEN
          vr_dserro_arq  := 'Tipo de arquivo ('||rw_lancamento.tparquivo||') nao previsto.';
          vr_cdocorr_arq := '99';
        END IF;


          vr_qtproclancto := 0;

          FOR rw_tabela IN cr_tabela(rw_lancamento.idlancto,rw_lancamento.tpforma_transf) LOOP
            -- Limpa a variavel de erro
            vr_dserro  := NULL;
            vr_cdocorr := NULL;
            vr_qtproclancto := vr_qtproclancto + 1;

            -- Efetua todas as consistencias dentro deste BEGIN
            BEGIN

              -- se existe erro a nível de arquivo/lancamento jogará para todos os
              -- registros PDV este erro
              IF NVL(vr_cdocorr_arq,'00') <> '00' THEN
                vr_dserro  := vr_dserro_arq;
                vr_cdocorr := vr_cdocorr_arq;
                RAISE vr_erro;
              END IF;

              IF vr_crapcop(rw_tabela.cdagencia_centraliza).flgativo = 0 THEN

                OPEN cr_craptco (pr_cdcopant => vr_crapcop(rw_tabela.cdagencia_centraliza).cdcooper,
                                 pr_nrctaant => rw_tabela.nrcta_centraliza);
                FETCH cr_craptco INTO rw_craptco;

                IF cr_craptco%FOUND THEN
                  vr_nrdconta := rw_craptco.nrdconta;
                  vr_coopdest := rw_craptco.cdcooper;
                ELSE
                  vr_nrdconta := 0;
                  vr_coopdest := 0;
                END IF;

                CLOSE cr_craptco;

              ELSE
                vr_nrdconta := rw_tabela.nrcta_centraliza;
                vr_coopdest := vr_crapcop(rw_tabela.cdagencia_centraliza).cdcooper;
               
                 
                
              END IF;

              -- Busca a data da cooperativa
              -- foi incluido aqui pois pode existir contas transferidas
              OPEN btch0001.cr_crapdat(vr_coopdest);
              FETCH btch0001.cr_crapdat INTO rw_crapdat;
              CLOSE btch0001.cr_crapdat;

              --Alterado para utilizar a data do parâmetro, se for diferente de NULL
              --IF vr_database_name = 'AYLLOSD' THEN
              IF pr_dtprocesso IS NULL THEN
                IF rw_crapdat.inproces > 1 THEN  -- Está executando cadeia
                  vr_dtprocesso := rw_crapdat.dtmvtopr;
                ELSE
                  vr_dtprocesso := rw_crapdat.dtmvtolt;
                END IF;
              ELSE
                vr_dtprocesso   := trunc(nvl(pr_dtprocesso,sysdate));
              END IF;

            EXCEPTION
              WHEN vr_erro THEN
                NULL;
            END;

            vr_nrdolote := 9666;  -- Conforme validado em 22/11/2017

            -- Atualiza os historicos de lancamento
            IF rw_lancamento.tparquivo = 1 THEN    -- crédito
               IF rw_lancamento.nrcnpj_credenciador = 59438325000101 THEN -- BRADESCO
                 vr_cdhistor := 2444;
               ELSIF rw_lancamento.nrcnpj_credenciador = 01027058000191 THEN -- CIELO
                 vr_cdhistor := 2546;
               ELSIF rw_lancamento.nrcnpj_credenciador = 02038232000164 THEN -- SIPAG
                 vr_cdhistor := 2443;
               ELSIF rw_lancamento.nrcnpj_credenciador = 01425787000104 THEN -- REDECARD
                 vr_cdhistor := 2442;
               ELSIF rw_lancamento.nrcnpj_credenciador = 16501555000157 THEN -- STONE
                 vr_cdhistor := 2450;
               ELSIF rw_lancamento.nrcnpj_credenciador = 12592831000189 THEN -- ELAVON
                 vr_cdhistor := 2453;
               ELSIF rw_lancamento.nrcnpj_credenciador = 92934215000106 THEN -- VERO
                 vr_cdhistor := 2478;
               ELSIF rw_lancamento.nrcnpj_credenciador = 28127603000178 THEN -- BANESCARD
                 vr_cdhistor := 2484;
               ELSIF rw_lancamento.nrcnpj_credenciador = 60114865000100 THEN -- SOROCRED
                 vr_cdhistor := 2485;
               ELSIF rw_lancamento.nrcnpj_credenciador = 01722480000167 THEN -- VERDECARD
                 vr_cdhistor := 2486;
               ELSIF rw_lancamento.nrcnpj_credenciador = 04670195000138 THEN -- CREDSYSTEM
                 vr_cdhistor := 2487;
               ELSIF rw_lancamento.nrcnpj_credenciador = 08561701000101 THEN -- PAGSEGURO
                 vr_cdhistor := 2488;
               ELSIF rw_lancamento.nrcnpj_credenciador = 10440482000154 THEN -- GETNET
                 vr_cdhistor := 2489;
               ELSIF rw_lancamento.nrcnpj_credenciador = 17887874000105 THEN -- GLOBAL PAYMENTS
                 vr_cdhistor := 2490;
               ELSIF rw_lancamento.nrcnpj_credenciador = 20520298000178 THEN -- ADYEN
                 vr_cdhistor := 2491;
               ELSIF rw_lancamento.nrcnpj_credenciador = 58160789000128 THEN -- SAFRAPAY
                 vr_cdhistor := 2492;
               ELSE  -- OUTROS CREDENCIADORES
                 vr_cdhistor := 2445;
               END IF;
            ELSIF rw_lancamento.tparquivo = 2 THEN -- débito
               IF rw_lancamento.nrcnpj_credenciador = 59438325000101 THEN -- BRADESCO
                 vr_cdhistor := 2448;
               ELSIF rw_lancamento.nrcnpj_credenciador = 01027058000191 THEN -- CIELO
                 vr_cdhistor := 2547;
               ELSIF rw_lancamento.nrcnpj_credenciador = 02038232000164 THEN -- SIPAG
                 vr_cdhistor := 2447;
               ELSIF rw_lancamento.nrcnpj_credenciador = 01425787000104 THEN -- REDECARD
                 vr_cdhistor := 2446;
               ELSIF rw_lancamento.nrcnpj_credenciador = 16501555000157 THEN -- STONE
                 vr_cdhistor := 2451;
               ELSIF rw_lancamento.nrcnpj_credenciador = 12592831000189 THEN -- ELAVON
                 vr_cdhistor := 2413;
               ELSIF rw_lancamento.nrcnpj_credenciador = 92934215000106 THEN -- BANRISUL
                 vr_cdhistor := 2479;
               ELSIF rw_lancamento.nrcnpj_credenciador = 28127603000178 THEN -- BANESCARD
                 vr_cdhistor := 2493;
               ELSIF rw_lancamento.nrcnpj_credenciador = 60114865000100 THEN -- SOROCRED
                 vr_cdhistor := 2494;
               ELSIF rw_lancamento.nrcnpj_credenciador = 01722480000167 THEN -- VERDECARD
                 vr_cdhistor := 2495;
               ELSIF rw_lancamento.nrcnpj_credenciador = 04670195000138 THEN -- CREDSYSTEM
                 vr_cdhistor := 2496;
               ELSIF rw_lancamento.nrcnpj_credenciador = 08561701000101 THEN -- PAGSEGURO
                 vr_cdhistor := 2497;
               ELSIF rw_lancamento.nrcnpj_credenciador = 10440482000154 THEN -- GETNET
                 vr_cdhistor := 2498;
               ELSIF rw_lancamento.nrcnpj_credenciador = 17887874000105 THEN -- GLOBAL PAYMENTS
                 vr_cdhistor := 2499;
               ELSIF rw_lancamento.nrcnpj_credenciador = 20520298000178 THEN -- ADYEN
                 vr_cdhistor := 2500;
               ELSIF rw_lancamento.nrcnpj_credenciador = 58160789000128 THEN -- ADYEN
                 vr_cdhistor := 2501;
               ELSE  -- OUTROS CREDENCIADORES
                 vr_cdhistor := 2449;
               END IF;
            ELSE                                 -- antecipação
               IF rw_lancamento.nrcnpj_credenciador = 59438325000101 THEN -- BRADESCO
                 vr_cdhistor := 2456;
               ELSIF rw_lancamento.nrcnpj_credenciador = 01027058000191 THEN -- CIELO
                 vr_cdhistor := 2548;
               ELSIF rw_lancamento.nrcnpj_credenciador = 02038232000164 THEN -- SIPAG
                 vr_cdhistor := 2455;
               ELSIF rw_lancamento.nrcnpj_credenciador = 01425787000104 THEN -- REDECARD
                 vr_cdhistor := 2454;
               ELSIF rw_lancamento.nrcnpj_credenciador = 16501555000157 THEN -- STONE
                 vr_cdhistor := 2452;
               ELSIF rw_lancamento.nrcnpj_credenciador = 12592831000189 THEN -- ELAVON
                 vr_cdhistor := 2414;
               ELSIF rw_lancamento.nrcnpj_credenciador = 92934215000106 THEN -- BANRISUL / VERO
                 vr_cdhistor := 2480;
               ELSIF rw_lancamento.nrcnpj_credenciador = 28127603000178 THEN -- BANESCARD
                 vr_cdhistor := 2502;
               ELSIF rw_lancamento.nrcnpj_credenciador = 60114865000100 THEN -- SOROCRED
                 vr_cdhistor := 2503;
               ELSIF rw_lancamento.nrcnpj_credenciador = 01722480000167 THEN -- VERDECARD
                 vr_cdhistor := 2504;
               ELSIF rw_lancamento.nrcnpj_credenciador = 04670195000138 THEN -- CREDSYSTEM
                 vr_cdhistor := 2505;
               ELSIF rw_lancamento.nrcnpj_credenciador = 08561701000101 THEN -- PAGSEGURO
                 vr_cdhistor := 2506;
               ELSIF rw_lancamento.nrcnpj_credenciador = 10440482000154 THEN -- GETNET
                 vr_cdhistor := 2507;
               ELSIF rw_lancamento.nrcnpj_credenciador = 17887874000105 THEN -- GLOBAL PAYMENTS
                 vr_cdhistor := 2508;
               ELSIF rw_lancamento.nrcnpj_credenciador = 20520298000178 THEN -- ADYEN
                 vr_cdhistor := 2509;
               ELSIF rw_lancamento.nrcnpj_credenciador = 58160789000128 THEN -- ADYEN
                 vr_cdhistor := 2510;
               ELSE  -- OUTROS CREDENCIADORES
                 vr_cdhistor := 2457;
               END IF;
            END IF;


            -- Se nao existir erro, insere o lancamento
            IF vr_cdocorr IS NULL AND
               trunc(rw_tabela.dtpagamento) = trunc(nvl(vr_dtprocesso,sysdate)) THEN -- Integrar na craplcm e atualizar
                                                                                     -- dtdebito se existir na craplau

              -- Atualiza a cooperativa
              vr_cdcooper := vr_coopdest;

              -- procura ultima sequencia do lote pra jogar em vr_nrseqdiglcm
              pr_cdcritic := null;
              vr_dscritic := null;
              vr_cdcooper_lcm := vr_cdcooper; -- salva a nova cooperativa para a quebra
              pc_procura_ultseq_craplcm (pr_cdcooper    => vr_cdcooper
                                        ,pr_dtmvtolt    => vr_dtprocesso
                                        ,pr_cdagenci    => 1
                                        ,pr_cdbccxlt    => 100
                                        ,pr_nrdolote    => vr_nrdolote
                                        ,pr_nrseqdiglcm => vr_nrseqdiglcm
                                        ,pr_cdcritic    => vr_cdcritic
                                        ,pr_dscritic    => vr_dscritic);

              IF vr_dscritic is not null then
                RAISE vr_exc_saida;
              END IF;

              BEGIN
              -- insere o registro na tabela de lancamentos
                LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt =>trunc(vr_dtprocesso)    -- dtmvtolt
                                                  ,pr_cdagenci=>1                        -- cdagenci
                                                  ,pr_cdbccxlt =>100                     -- cdbccxlt
                                                  ,pr_nrdolote =>vr_nrdolote             -- nrdolote 
                                                  ,pr_nrdconta =>vr_nrdconta             -- nrdconta 
                                                  ,pr_nrdocmto =>vr_nrseqdiglcm          -- nrdocmto 
                                                  ,pr_cdhistor =>vr_cdhistor             -- cdhistor
                                                  ,pr_nrseqdig =>vr_nrseqdiglcm          -- nrseqdig
                                                  ,pr_vllanmto =>rw_tabela.vlpagamento   -- vllanmto 
                                                  ,pr_nrdctabb =>vr_nrdconta             -- nrdctabb
                                                  ,pr_nrdctitg =>GENE0002.fn_mask(vr_nrdconta,'99999999') -- nrdctitg 
                                                  ,pr_cdcooper =>vr_cdcooper             -- cdcooper
                                                  ,pr_dtrefere =>rw_tabela.dtpagamento   -- dtrefere
                                                  ,pr_cdoperad =>1                       -- cdoperad
                                                  ,pr_cdpesqbb =>rw_tabela.nrliquidacao  -- cdpesqbb                                                                                                
                                                  -- OUTPUT --
                                                  ,pr_tab_retorno => vr_tab_retorno
                                                  ,pr_incrineg => vr_incrineg
                                                  ,pr_cdcritic => vr_cdcritic
                                                  ,pr_dscritic => vr_dscritic);

                IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                   RAISE vr_exc_saida;
                END IF;

                dbms_output.put_line('progress_recid: '||vr_tab_retorno.progress_recid_lcm);
                   
              EXCEPTION
                WHEN vr_exc_saida THEN
                  raise vr_exc_saida; -- Apenas passar a critica 
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir CRAPLCM: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;

              -- Atualiza data de débito na craplau
              BEGIN
                UPDATE craplau
                   SET dtdebito = trunc(vr_dtprocesso)
                 WHERE cdcooper = vr_cdcooper
                   AND dtmvtopg = rw_tabela.dtpagamento
                   AND nrdconta = vr_nrdconta
                   AND cdseqtel = rw_tabela.nrliquidacao;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar tabela CRAPLAU - dtdebito : '||SQLERRM;
                  RAISE vr_exc_saida;
              END;

              vr_qtprocessados := vr_qtprocessados + 1;

            END IF;

            /*IF vr_cdocorr IS NULL AND
               trunc(rw_tabela.dtpagamento) > trunc(vr_dtprocesso) THEN -- Integrar na craplau

              -- Atualiza a cooperativa
              vr_cdcooper := vr_coopdest;

              -- procura ultima sequencia do lote pra jogar em vr_nrseqdiglcm
              vr_cdcritic := null;
              vr_dscritic := null;
              vr_cdcooper_lau := vr_cdcooper;

              pc_procura_ultseq_craplau (pr_cdcooper    => vr_cdcooper
                                        ,pr_dtmvtolt    => vr_dtprocesso
                                        ,pr_cdagenci    => 1
                                        ,pr_cdbccxlt    => 100
                                        ,pr_nrdolote    => vr_nrdolote
                                        ,pr_nrseqdiglau => vr_nrseqdiglau
                                        ,pr_cdcritic    => vr_cdcritic
                                        ,pr_dscritic    => vr_dscritic);

              IF vr_dscritic is not null then
                RAISE vr_exc_saida;
              END IF;
              --dbms_output.put_line('vai inserir craplau');
              -- insere o registro na tabela de lancamentos
              BEGIN
                INSERT INTO craplau
                  (dtmvtolt,
                   cdagenci,
                   cdbccxlt,
                   nrdolote,
                   nrdconta,
                   nrdocmto,
                   cdhistor,
                   nrseqdig,
                   vllanaut,
                   nrdctabb,
                   nrdctitg,
                   cdcooper,
                   dtmvtopg,
    --               cdoperad,
                   cdseqtel,
                   dsorigem)
                VALUES
                  (trunc(vr_dtprocesso),                                     --dtmvtolt
                   1,                                                 --cdagenci
                   100,                                               --cdbccxlt
                   vr_nrdolote,                                       --nrdolote
                   vr_nrdconta,                                       --nrdconta
                   vr_nrseqdiglau,                                    --nrdocmto
                   vr_cdhistor,                                       --cdhistor
                   vr_nrseqdiglau,                                    --nrseqdig
                   rw_tabela.vlpagamento,                             --vllanaut
                   vr_nrdconta,                                       --nrdctabb
                   GENE0002.fn_mask(vr_nrdconta,'99999999'),          --nrdctitg
                   vr_cdcooper,                                       --cdcooper
                   rw_tabela.dtpagamento,                             --dtrefere
    --               '1',                                               --cdoperad
                   rw_tabela.nrliquidacao,                            --cdseqtel
                   'DOMICILIO');                                      --dsorigem
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir CRAPLAU: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;

              vr_qtfuturos := vr_qtfuturos + 1;

            END IF;*/

            IF nvl(vr_cdocorr,'00') <> '00' THEN
              vr_qterros := vr_qterros + 1;
            END IF;

            IF nvl(vr_cdocorr,'00') = '00' THEN
              IF rw_tabela.dtpagamento > vr_dtprocesso THEN
                 IF rw_lancamento.tparquivo = 1 THEN    -- crédito
                    vr_cdocorr := '01'; -- agendamento de transação efetuado com sucesso --
                 END IF;
              END IF;
            END IF;

          END LOOP;  -- loop cr_tabela

          -- Efetua a atualizacao da situacao na tabela de lancamentos
          -- Se encontrar algum registro sem erro no lancto, atualiza situação para 2
          -- Com isso, se tiver apenas 1 PDV sem erro dentro de um lançamento considera todo o lançamento como processado
          IF vr_qtproclancto > 0 THEN
            BEGIN
              UPDATE tbdomic_liqtrans_lancto
                 SET insituacao = 2 -- processado
                    ,dhprocessamento = SYSDATE
               WHERE idlancto = rw_lancamento.idlancto;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar tabela tbdomic_liqtrans_lancto: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF;

        --END IF;
      END LOOP;  -- loop cr_lancamento
      
      dbms_output.put_line('Executou até o fim.');


      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;
        cecred.pc_internal_exception;
        
        -- Efetuar rollback
        ROLLBACK;
        raise_application_error(-20001,'pc_efetiva_reg_pendentes vr_exc_saida'||' '||pr_cdcritic ||' '||sqlerrm);

      WHEN OTHERS THEN
        raise_application_error(-20001,'pc_efetiva_reg_pendentes '||sqlerrm);
        cecred.pc_internal_exception;
        
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
  END;

  end pc_credito_manual_ASLC024;

BEGIN
   
   -- código do arquivo
   W_GLB_IDARQUIVO := 97464;
   --
   -- Avaliar a data desejada do pagamento no cursor, dtpagamento.
   --
   -- Executa a geracao dos lcms
   pc_credito_manual_ASLC024(pr_dtprocesso => TRUNC(SYSDATE));

END;
0
0
