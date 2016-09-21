CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS404(pr_cdcooper  IN crapcop.cdcooper%TYPE  -- Cooperativa solicitada
                                             ,pr_flgresta  IN PLS_INTEGER            -- Flag padr�o para utiliza��o de restart
                                             ,pr_stprogra OUT PLS_INTEGER            -- Sa�da de termino da execu��o
                                             ,pr_infimsol OUT PLS_INTEGER            -- Sa�da de termino da solicita��o
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  -- Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS           -- Texto de erro/critica encontrada
  BEGIN
    /* ..........................................................................

     Programa: PC_CRPS404  Antigo: (Fontes/crps404.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Edson
     Data    : Agosto/2004                     Ultima atualizacao: 25/03/2015

     Dados referentes ao programa:

     Frequencia: Diario.
     Objetivo  : Atende a solicitacao 001.
                 Lanca diariamente abono de CPMF sobre operacoes de credito no
                 CAPITAL (subscricao do capital e planos de capital).
                 
                 ** ESTE PROGRAMA FOI BASEADO NO CRPS182.P **
     
     Alteracoes: 01/07/2005 - Alimentado campo cdcooper da tabela craplot 
                              e do buffer crablcm (Diego).

                 17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
                 
                 13/01/2014 - Melhoria leitura craplcm (Daniel).

                 22/01/2014 - Incluir VALIDATE craplot, crablcm (Lucas R.) 

                 24/03/2015 - Convers�o Progress >> Oracle (Jean Michel).

    ............................................................................ */

    DECLARE

      -- Codigo do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'PC_CRPS404';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);

      -- Variaveis locais
      vr_dtinipmf DATE;
      vr_dtfimpmf DATE;
      vr_dtiniabo DATE;
      vr_auxrowid ROWID;
      vr_txcpmfcc NUMBER := 0;
      vr_txrdcpmf NUMBER := 0;
      vr_vldebcre NUMBER := 0;
      vr_indabono PLS_INTEGER := 0;

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Consulta se a cooperativa abona ou nao operacoes sobre o capital.
      CURSOR cr_crapmat(pr_cdcooper IN craptab.cdcooper%TYPE) IS -- Cooperativa conectada
        SELECT mat.flgabcap
          FROM crapmat mat
         WHERE mat.cdcooper = pr_cdcooper;

      rw_crapmat cr_crapmat%ROWTYPE;
    
      -- Consulta de lancamentos
      CURSOR cr_craplcm(pr_cdcooper IN craplcm.cdcooper%TYPE     -- Cooperativa conectada
                       ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE     -- Data de movimento atual
                       ,pr_cdhistor IN craplcm.cdhistor%TYPE) IS -- Codigo de historico
        SELECT /*+ INDEX (craplcm craplcm##craplcm4) */
               lcm.nrdconta
               ,lcm.vllanmto
               ,lcm.progress_recid
               ,MAX(lcm.progress_recid) OVER (PARTITION BY lcm.nrdconta) ultregis
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
               AND lcm.dtmvtolt = pr_dtmvtolt
               AND lcm.cdhistor = pr_cdhistor;
      
      rw_craplcm cr_craplcm%ROWTYPE;
    
      -- Consulta de cooperado
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE     -- Cooperativa conectada
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS -- Conta do cooperado
        SELECT ass.nrdconta
               ,ass.iniscpmf
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
               AND ass.nrdconta = pr_nrdconta;
      
      rw_crapass cr_crapass%ROWTYPE;     
      
      -- Consulta de lote
      CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE     -- Cooperativa conectada
                       ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE     -- Data de movimento atual
                       ,pr_cdagenci IN craplot.cdagenci%TYPE     -- Numero do PA
                       ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE     -- Numero do banco/caixa
                       ,pr_nrdolote IN craplot.nrdolote%TYPE) IS -- Numero do lote
        SELECT lot.dtmvtolt        
               ,lot.cdagenci
               ,lot.tplotmov
               ,lot.nrseqdig
               ,lot.vlinfocr
               ,lot.vlcompdb
               ,lot.vlinfodb
               ,lot.cdhistor
               ,lot.cdoperad
               ,lot.dtmvtopg
               ,lot.cdcooper             
               ,lot.qtcompln
               ,lot.vlcompcr
               ,lot.cdbccxlt
               ,lot.nrdolote
               ,lot.rowid
          FROM craplot lot
         WHERE lot.cdcooper = pr_cdcooper
               AND lot.dtmvtolt = pr_dtmvtolt
               AND lot.cdagenci = pr_cdagenci
               AND lot.cdbccxlt = pr_cdbccxlt
               AND lot.nrdolote = pr_nrdolote;

      rw_craplot cr_craplot%ROWTYPE;
            
      -- Cursor gen�rico de calend�rio
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    BEGIN

      -- Incluir nome do m�dulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;

      -- Se n�o encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calend�rio da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);

      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      -- Se n�o encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Valida��es iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);

      -- Verifica se hoive critica na validacao inicial do programa
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      -- Consulta sobre abono ou nao operacoes sobre o capital
      OPEN cr_crapmat(pr_cdcooper => pr_cdcooper);

      FETCH cr_crapmat INTO rw_crapmat;

      -- Verifica se nao abona o CPMF no capital
      IF rw_crapmat.flgabcap = 0 THEN
        -- Fechar o cursor pois haver� raise
        CLOSE cr_crapmat;  
        RAISE vr_exc_fimprg;
      END IF;

      -- Fechar cursor
      CLOSE cr_crapmat;
             
      -- Rotina de consulta de CPMF
      GENE0005.pc_busca_cpmf(pr_cdcooper => pr_cdcooper 
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                            ,pr_dtinipmf => vr_dtinipmf
                            ,pr_dtfimpmf => vr_dtfimpmf
                            ,pr_txcpmfcc => vr_txcpmfcc
                            ,pr_txrdcpmf => vr_txrdcpmf
                            ,pr_indabono => vr_indabono
                            ,pr_dtiniabo => vr_dtiniabo
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

      -- Verifica se hoive critica no processo de consulta de CPMF
      IF NVL(vr_cdcritic,0) > 0 OR
         vr_dscritic IS NOT NULL THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;
          
      -- Consulta de lancamentos efetuados
      FOR rw_craplcm IN cr_craplcm(pr_cdcooper => pr_cdcooper         -- Cooperativa conectada
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data de movimento atual
                                  ,pr_cdhistor => 127) LOOP           -- Codigo de hist�rico   

        -- Valor para credito que sera utilizado na criacao do lote
        vr_vldebcre := vr_vldebcre + ROUND(vr_txcpmfcc * rw_craplcm.vllanmto,2);

        -- Verifica se e o ultimo registro de lancamento da conta
        IF rw_craplcm.progress_recid <> rw_craplcm.ultregis THEN
          -- Vai para o proximo registro
          CONTINUE;
        END IF;

        -- Consulta para ver se conta de cooperado existe
        OPEN cr_crapass(pr_cdcooper => pr_cdcooper           -- Cooperativa conectado
                       ,pr_nrdconta => rw_craplcm.nrdconta); -- Conta do cooperado

        FETCH cr_crapass INTO rw_crapass;

        -- Verifica se encontrou registro, caso nao encontre gera critica
        IF cr_crapass%NOTFOUND THEN
          -- Fechar o cursor pois haver� raise
          CLOSE cr_crapass;

          -- Alimenta variaveis de critica
          vr_cdcritic := 251;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
          RAISE vr_exc_saida;
        END IF;               
        
        -- Fecha cursor
        CLOSE cr_crapass;

        -- Valor de credito para lote e se existe tributacao para CPFM          
        IF vr_vldebcre <> 0 AND rw_crapass.iniscpmf = 0 THEN

          -- Consulta e verifica se lote existe
          OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_cdagenci => 1
                         ,pr_cdbccxlt => 100
                         ,pr_nrdolote => 10103);

          FETCH cr_craplot INTO rw_craplot;

          -- Verifica se encotrou registro de lote
          IF cr_craplot%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_craplot;

            -- Insere novo registro de lote
            BEGIN
              INSERT INTO
                craplot(
                  dtmvtolt,
                  cdagenci,
                  cdbccxlt,
                  nrdolote,
                  tplotmov,
                  nrseqdig,
                  vlcompcr,
                  vlinfocr,
                  vlcompdb,
                  vlinfodb,
                  cdhistor,
                  cdoperad,
                  dtmvtopg,
                  cdcooper) VALUES(
                    rw_crapdat.dtmvtolt,
                    1,
                    100,
                    10103,
                    1,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    '1',
                    NULL,
                    pr_cdcooper)
                RETURNING 
                  dtmvtolt,cdagenci,cdbccxlt,nrdolote,tplotmov,
                  nrseqdig,vlcompcr,vlinfocr,vlcompdb,vlinfodb,
                  cdhistor,cdoperad,dtmvtopg,cdcooper,ROWID
                INTO 
                  rw_craplot.dtmvtolt,rw_craplot.cdagenci,rw_craplot.cdbccxlt,
                  rw_craplot.nrdolote,rw_craplot.tplotmov,rw_craplot.nrseqdig,
                  rw_craplot.vlcompcr,rw_craplot.vlinfocr,rw_craplot.vlcompdb,
                  rw_craplot.vlinfodb,rw_craplot.cdhistor,rw_craplot.cdoperad,
                  rw_craplot.dtmvtopg,rw_craplot.cdcooper,vr_auxrowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir registro de lote(CRAPLOT). Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
            
          END IF;

          -- Fechar cursor
          CLOSE cr_craplot;

          -- Atualiza registro de lote
          BEGIN
            UPDATE
              craplot
            SET
              craplot.nrseqdig = rw_craplot.nrseqdig + 1,
              craplot.qtcompln = rw_craplot.qtcompln + 1,
              craplot.qtinfoln = rw_craplot.qtcompln,
              craplot.vlcompdb = rw_craplot.vlcompdb + 0,
              craplot.vlinfodb = rw_craplot.vlcompdb,
              craplot.vlcompcr = rw_craplot.vlcompcr + vr_vldebcre,
              craplot.vlinfocr = rw_craplot.vlcompcr
            WHERE
              craplot.rowid = rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar registro de lote(CRAPLOT). Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
          
          -- Cria novo registro de lancamento
          BEGIN
            INSERT INTO
              craplcm(
                cdagenci,
                cdbccxlt,
                cdhistor,
                dtmvtolt,
                cdpesqbb,
                nrdconta,
                nrdctabb,
                nrdocmto,
                nrdolote,
                nrseqdig,
                vllanmto,
                cdcooper)
              VALUES(
                rw_craplot.cdagenci,
                rw_craplot.cdbccxlt,
                588,                -- Abono Capital
                rw_crapdat.dtmvtolt,
                '',
                rw_craplcm.nrdconta,
                rw_craplcm.nrdconta,
                rw_craplot.nrseqdig,
                rw_craplot.nrdolote,
                rw_craplot.nrseqdig,
                vr_vldebcre,
                pr_cdcooper);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registro de lancamento(CRAPLCM). Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

        END IF;

        -- Zera valor de credito para o lote
        vr_vldebcre := 0;

      END LOOP;                               
      
      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informa��es atualizadas
      COMMIT;
      
    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos c�digo e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro n�o tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;

  END PC_CRPS404;
/

