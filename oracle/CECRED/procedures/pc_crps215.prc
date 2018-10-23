CREATE OR REPLACE PROCEDURE CECRED.pc_crps215 (pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                              ,pr_cdoperad  IN crapope.cdoperad%TYPE  --> Codigo operador
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
    /* .............................................................................

       Programa: pc_crps215       (Fontes/crps215.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odair
       Data    : Novembro/97.                    Ultima atualizacao: 15/02/2016

       Dados referentes ao programa:

       Frequencia: Diario (Batch).
       Objetivo  : Atende a solicitacao 001.
                   Creditar em conta corrente os lancamentos de cobranca.

       Alteracoes: 24/09/2004 - Incluir mais duas posicoes do Nro Convenio (Ze).

                   30/06/2005 - Alimentado campo cdcooper das tabelas craplot
                                e craplcm (Diego).

                   10/12/2005 - Atualizar craplcm.nrdctitg (magui).
                   
                   18/01/2006 - Aumento no campo nrdocmto (Ze).
                   
                   16/02/2006 - Unificacao dos bancos - SQLWorks - Eder
                   
                   27/03/2006 - Acerto no programa (Ze). 
                   
                   08/11/2006 - Aumentei o tamanho da mascara na atribuicao do 
                                craplcb.nrdocmto para o craplcm.cdpesqbb (Julio)
                                
                   23/07/2008 - Correcao na atualizacao da capa de lote (Magui).     
                   
                   
                   20/06/2013 - Retirado processo de geracao tarifa na craplcm e 
                                incluso processo de geracao tarifa usando b1wgen0153.
                                (Daniel)   
                   
                   11/10/2013 - Incluido parametro cdprogra nas procedures da 
                                b1wgen0153 que carregam dados de tarifas (Tiago).
                                
                   16/01/2014 - Inclusao de VALIDATE craplot e craplcm (Carlos)
                   
                   14/04/2015 - Conversão Progress -> Oracle (Odirlei-AMcom)

                   15/02/2016 - Inclusao do parametro conta na chamada da
                                TARI0001.pc_carrega_dados_tarifa_cobr. (Jaison/Marcos)

    ............................................................................ */
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS215';

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    -- Buscar lotes
    CURSOR cr_crablot (pr_cdcooper craplot.cdcooper%TYPE,
                       pr_dtmvtolt craplot.dtmvtolt%TYPE)IS 
      SELECT craplot.dtmvtolt
            ,craplot.cdcooper
            ,craplot.cdagenci
            ,craplot.cdbccxlt
            ,craplot.nrdolote
        FROM craplot
       WHERE craplot.cdcooper = pr_cdcooper
         AND craplot.dtmvtolt = pr_dtmvtolt
         AND craplot.tplotmov = 18;
         
    -- Buscar lancamentos de cobrança
    CURSOR cr_craplcb (pr_cdcooper craplot.cdcooper%TYPE,
                       pr_dtmvtolt craplot.dtmvtolt%TYPE,
                       pr_cdagenci craplcb.cdagenci%TYPE,
                       pr_cdbccxlt craplcb.cdbccxlt%TYPE,
                       pr_nrdolote craplcb.nrdolote%TYPE)IS 
                       
      SELECT /*+ index_asc (craplcb craplcb##craplcb3)*/
             craplcb.cdcooper,
             craplcb.nrdocmto,
             craplcb.nrdctabb,
             craplcb.vllanmto,
             craplcb.nrcnvcob,
             craplcb.nrdconta,
             craplcb.cdbancob
        FROM craplcb
       WHERE craplcb.cdcooper = pr_cdcooper
         AND craplcb.dtmvtolt = pr_dtmvtolt
         AND craplcb.cdagenci = pr_cdagenci
         AND craplcb.cdbccxlt = pr_cdbccxlt
         AND craplcb.nrdolote = pr_nrdolote;
    
    /* buscar lote para gerar lcm */
    CURSOR cr_craplot (pr_cdcooper craplot.cdcooper%TYPE,
                       pr_dtmvtolt craplot.dtmvtolt%TYPE)IS 
      SELECT craplot.rowid
            ,craplot.dtmvtolt
            ,craplot.cdagenci
            ,craplot.cdbccxlt
            ,craplot.nrdolote
            ,craplot.tpdmoeda
            ,craplot.cdoperad
            ,craplot.tplotmov
            ,craplot.cdcooper
            ,craplot.nrseqdig
        FROM craplot
       WHERE craplot.cdcooper = pr_cdcooper
         AND craplot.dtmvtolt = pr_dtmvtolt
         AND craplot.cdagenci = 1
         AND craplot.cdbccxlt = 100
         AND craplot.nrdolote = 8463;
    rw_craplot cr_craplot%ROWTYPE;
    
    -- Verificar lancamentos
    CURSOR cr_craplcm (pr_cdcooper craplcm.cdcooper%TYPE,
                       pr_dtmvtolt craplcm.dtmvtolt%TYPE,
                       pr_cdagenci craplcm.cdagenci%TYPE,
                       pr_cdbccxlt craplcm.cdbccxlt%TYPE,
                       pr_nrdolote craplcm.nrdolote%TYPE,
                       pr_nrdctabb craplcm.nrdctabb%TYPE,
                       pr_nrdocmto craplcm.nrdocmto%TYPE)IS 
                       
      SELECT /*+ index (craplcm craplcm##craplcm1)*/
             craplcm.cdcooper
        FROM craplcm craplcm
       WHERE craplcm.cdcooper = pr_cdcooper
         AND craplcm.dtmvtolt = pr_dtmvtolt
         AND craplcm.cdagenci = pr_cdagenci
         AND craplcm.cdbccxlt = pr_cdbccxlt
         AND craplcm.nrdolote = pr_nrdolote
         AND craplcm.nrdctabb = pr_nrdctabb
         AND craplcm.nrdocmto = pr_nrdocmto;
    rw_craplcm cr_craplcm%ROWTYPE;
    
    -- Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS  
      SELECT crapass.inpessoa
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    
    -- Buscar dados de cobrança e verificar se esta com lock
    CURSOR cr_crapcob (pr_cdcooper crapcob.cdcooper%TYPE,
                       pr_cdbancob crapcob.cdbandoc%TYPE,
                       pr_nrdctabb crapcob.nrdctabb%TYPE,
                       pr_nrcnvcob crapcob.nrcnvcob%TYPE,
                       pr_nrdconta crapcob.nrdconta%TYPE,
                       pr_nrdocmto crapcob.nrdocmto%TYPE)IS  
      SELECT /*+ index (crapcob crapcob##crapcob1)*/
              crapcob.rowid
        FROM crapcob crapcob
       WHERE crapcob.cdcooper = pr_cdcooper
         AND crapcob.cdbandoc = pr_cdbancob
         AND crapcob.nrdctabb = pr_nrdctabb
         AND crapcob.nrcnvcob = pr_nrcnvcob
         AND crapcob.nrdconta = pr_nrdconta
         AND crapcob.nrdocmto = pr_nrdocmto
         FOR UPDATE NOWAIT;
    rw_crapcob cr_crapcob%ROWTYPE;
                             
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    vr_tab_erro   gene0001.typ_tab_erro;
    
    ------------------------------- VARIAVEIS -------------------------------
    vr_nrdocmt2   craplcm.nrdocmto%TYPE;
    vr_inpessoa   crapass.inpessoa%TYPE;
    vr_cdhistor   INTEGER;
    vr_cdhisest   INTEGER;
    vr_vltarifa   NUMBER;
    vr_dtdivulg   DATE;
    vr_dtvigenc   DATE;
    vr_cdfvlcop   INTEGER;
    vr_rowid_craplat ROWID;
    
    vr_incrineg  INTEGER;
    
    vr_rw_craplot  lanc0001.cr_craplot%ROWTYPE;
    vr_tab_retorno lanc0001.typ_reg_retorno;
    --------------------------- SUBROTINAS INTERNAS --------------------------

  BEGIN

    --------------- VALIDACOES INICIAIS -----------------

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
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
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro é <> 0
    IF vr_cdcritic <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
    -- buscar lotes
    FOR rw_crablot IN cr_crablot (pr_cdcooper => pr_cdcooper,
                                  pr_dtmvtolt => rw_crapdat.dtmvtolt)LOOP
      
      -- Buscar lançamentos de cobrança
      FOR rw_craplcb IN cr_craplcb ( pr_cdcooper => rw_crablot.cdcooper,
                                     pr_dtmvtolt => rw_crablot.dtmvtolt,
                                     pr_cdagenci => rw_crablot.cdagenci,
                                     pr_cdbccxlt => rw_crablot.cdbccxlt,
                                     pr_nrdolote => rw_crablot.nrdolote) LOOP
                                     
        -- buscar lote para gerar lcm                             
        OPEN cr_craplot (pr_cdcooper => pr_cdcooper,
                         pr_dtmvtolt => rw_crapdat.dtmvtolt);
        FETCH cr_craplot INTO rw_craplot;
        
        -- se nao encontrar o lote, deve criar novo
        IF cr_craplot%NOTFOUND THEN
          CLOSE cr_craplot;
          BEGIN
             lanc0001.pc_incluir_lote( pr_cdcooper => pr_cdcooper,
                                       pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                       pr_cdagenci => 1,
                                       pr_cdbccxlt => 100,
                                       pr_nrdolote => 8463,
                                       pr_tpdmoeda => 1,
                                       pr_cdoperad => '1',
                                       pr_tplotmov => 1,
                                       pr_rw_craplot => vr_rw_craplot,
                                       pr_cdcritic   => pr_cdcritic,
                                       pr_dscritic   => pr_dscritic
                                       );
                                       
              if (nvl(pr_cdcritic,0) <>0 or pr_dscritic is not null) then
                 RAISE vr_exc_saida;
              end if;
              
              rw_craplot.rowid    := vr_rw_craplot.rowid;
              rw_craplot.dtmvtolt := vr_rw_craplot.dtmvtolt;
              rw_craplot.cdagenci := vr_rw_craplot.cdagenci;
              rw_craplot.cdbccxlt := vr_rw_craplot.cdbccxlt;
              rw_craplot.nrdolote := vr_rw_craplot.nrdolote;
    
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir lote 8463: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
          
        ELSE
          -- fechar cursor
          CLOSE cr_craplot;
        END IF;
        
        -- Definir numero de documento
        vr_nrdocmt2 := rw_craplcb.nrdocmto;
        LOOP
          -- Verificar lancamentos
          OPEN cr_craplcm (pr_cdcooper => rw_craplot.cdcooper,
                           pr_dtmvtolt => rw_craplot.dtmvtolt,
                           pr_cdagenci => rw_craplot.cdagenci,
                           pr_cdbccxlt => rw_craplot.cdbccxlt,
                           pr_nrdolote => rw_craplot.nrdolote,
                           pr_nrdctabb => rw_craplcb.nrdctabb,
                           pr_nrdocmto => vr_nrdocmt2);
          FETCH cr_craplcm INTO rw_craplcm;
          IF cr_craplcm%FOUND THEN
            CLOSE cr_craplcm;
            -- incrementar numero do documento
            vr_nrdocmt2 := (vr_nrdocmt2 + 1000000);
          ELSE
            CLOSE cr_craplcm;
            EXIT;
          END IF;
        END LOOP;
        
        BEGIN
          -- atualizar craplot
          UPDATE craplot
             SET craplot.vlinfocr = nvl(craplot.vlinfocr,0) + rw_craplcb.vllanmto,
                 craplot.vlcompcr = nvl(craplot.vlcompcr,0) + rw_craplcb.vllanmto,
                 craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1,
                 craplot.qtcompln = nvl(craplot.qtcompln,0) + 1,
                 craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
           WHERE craplot.rowid = rw_craplot.rowid
       RETURNING craplot.rowid,    craplot.dtmvtolt,
                 craplot.cdagenci, craplot.cdbccxlt,
                 craplot.nrdolote, craplot.nrseqdig
            INTO rw_craplot.rowid ,  rw_craplot.dtmvtolt,
                 rw_craplot.cdagenci,rw_craplot.cdbccxlt,
                 rw_craplot.nrdolote,rw_craplot.nrseqdig;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar lote 8463: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        -- incluir craplcm
        BEGIN
           lanc0001.pc_gerar_lancamento_conta(
                                              pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                             ,pr_cdagenci => rw_craplot.cdagenci
                                             ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                             ,pr_nrdolote => rw_craplot.nrdolote
                                             ,pr_nrdconta => rw_craplcb.nrdconta 
                                             ,pr_nrdctabb => rw_craplcb.nrdctabb
                                             ,pr_nrdctitg => gene0002.fn_mask(rw_craplcb.nrdctabb,'99999999')
                                             ,pr_nrdocmto => vr_nrdocmt2
                                             ,pr_cdhistor => 266
                                             ,pr_nrseqdig => rw_craplot.nrseqdig
                                             ,pr_vllanmto => rw_craplcb.vllanmto
                                             ,pr_cdpesqbb => gene0002.fn_mask(rw_craplcb.nrcnvcob,'999999999')
                                             ,pr_tab_retorno => vr_tab_retorno
                                             ,pr_incrineg => vr_incrineg
                                             ,pr_cdcritic => pr_cdcritic
                                             ,pr_dscritic => pr_dscritic
                      );

           if (nvl(pr_cdcritic,0) <> 0 or pr_dscritic is not null) then
              RAISE vr_exc_saida;
           end if;
          
        EXCEPTION
          WHEN vr_exc_saida THEN  
            raise vr_exc_saida;
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir lancamento nrdconta = '||rw_craplcb.nrdconta||
                                                     ' vllanmto = '||rw_craplcb.vllanmto||' : '||SQLERRM;
            RAISE vr_exc_saida;
        END;
      
        -- Buscar dados do associado
        OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => rw_craplcb.nrdconta);
        FETCH cr_crapass INTO vr_inpessoa;
        IF cr_crapass%NOTFOUND THEN
          --Caso nao encontre associado, assume como pessoa juridica
          vr_inpessoa := 2;
        END IF;  
        CLOSE cr_crapass;
        
        -- Busca informacoes tarifa 
        TARI0001.pc_carrega_dados_tarifa_cobr ( pr_cdcooper  => pr_cdcooper            -- Codigo Cooperativa
                                               ,pr_nrdconta  => rw_craplcb.nrdconta	   -- Numero Conta
                                               ,pr_nrconven  => rw_craplcb.nrcnvcob    -- Numero Convenio
                                               ,pr_dsincide  => 'RET'                  -- Descricao Incidencia
                                               ,pr_cdocorre  => 0                      -- Codigo Ocorrencia
                                               ,pr_cdmotivo  => '31' /* Outras instituicoes financeiras (Correspondente)*/ --Codigo Motivo
                                               ,pr_inpessoa  => vr_inpessoa            -- Tipo Pessoa
                                               ,pr_vllanmto  => 1                      -- Valor Lancamento
                                               ,pr_cdprogra  => vr_cdprogra            -- Nome do programa
                                               ,pr_flaputar  => 1                      -- Apurar
											   ,pr_cdhistor  => vr_cdhistor            -- Codigo Historico
                                               ,pr_cdhisest  => vr_cdhisest            -- Historico Estorno
                                               ,pr_vltarifa  => vr_vltarifa            -- Valor Tarifa
                                               ,pr_dtdivulg  => vr_dtdivulg            -- Data Divulgacao
                                               ,pr_dtvigenc  => vr_dtvigenc            -- Data Vigencia
                                               ,pr_cdfvlcop  => vr_cdfvlcop            -- Codigo Cooperativa
                                               ,pr_cdcritic  => pr_cdcritic            -- Codigo Critica
                                               ,pr_dscritic  => pr_dscritic);          -- Descricao Critica
        -- Se retornar com erro
        IF trim(pr_dscritic) IS NOT NULL THEN
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                     || pr_dscritic
                                                         || 'Convenio: '|| rw_craplcb.nrcnvcob
                                                         || ' Pessoa: ' || vr_inpessoa );
        ELSE -- Se retornou com sucesso
          IF vr_vltarifa > 0 THEN
            --Inicializar variavel retorno erro
            TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper => pr_cdcooper               -- Codigo Cooperativa
                                             ,pr_nrdconta => rw_craplcb.nrdconta       -- Numero da Conta
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt       -- Data Lancamento
                                             ,pr_cdhistor => vr_cdhistor               -- Codigo Historico
                                             ,pr_vllanaut => vr_vltarifa               -- Valor lancamento automatico
                                             ,pr_cdoperad => pr_cdoperad               -- Codigo Operador
                                             ,pr_cdagenci => rw_craplot.cdagenci       -- Codigo Agencia
                                             ,pr_cdbccxlt => rw_craplot.cdbccxlt       -- Codigo banco caixa
                                             ,pr_nrdolote => rw_craplot.nrdolote       -- Numero do lote
                                             ,pr_tpdolote => 1                         -- Tipo do lote
                                             ,pr_nrdocmto => 0                         -- Numero do documento
                                             ,pr_nrdctabb => rw_craplcb.nrdconta       -- Numero da conta
                                             ,pr_nrdctitg => gene0002.fn_mask(rw_craplcb.nrdconta,'99999999')   --Numero da conta integracao
                                             ,pr_cdpesqbb => ' '                       -- Codigo pesquisa
                                             ,pr_cdbanchq => 0                         -- Codigo Banco Cheque
                                             ,pr_cdagechq => 0                         -- Codigo Agencia Cheque
                                             ,pr_nrctachq => 0                         -- Numero Conta Cheque
                                             ,pr_flgaviso => FALSE                     -- Flag aviso
                                             ,pr_tpdaviso => 0                         -- Tipo aviso
                                             ,pr_cdfvlcop => vr_cdfvlcop               -- Codigo cooperativa
                                             ,pr_inproces => rw_crapdat.inproces       -- Indicador processo
                                             ,pr_rowid_craplat => vr_rowid_craplat     -- Rowid do lancamento tarifa
                                             ,pr_tab_erro => vr_tab_erro               -- Tabela retorno erro
                                             ,pr_cdcritic => vr_cdcritic               -- Codigo Critica
                                             ,pr_dscritic => vr_dscritic);             -- Descricao Critica
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;                    
          
            FOR i IN 1..10 LOOP
              -- Buscar dados de cobrança e verificar se esta com lock
              BEGIN
                OPEN cr_crapcob (pr_cdcooper => pr_cdcooper,
                                 pr_cdbancob => rw_craplcb.cdbancob,
                                 pr_nrdctabb => rw_craplcb.nrdctabb,
                                 pr_nrcnvcob => rw_craplcb.nrcnvcob,
                                 pr_nrdconta => rw_craplcb.nrdconta,
                                 pr_nrdocmto => rw_craplcb.nrdocmto);
                FETCH cr_crapcob INTO rw_crapcob;   
                -- se localizou deve alterar
                IF cr_crapcob%FOUND THEN
                  BEGIN
                    UPDATE crapcob
                       SET crapcob.vltarifa = vr_vltarifa
                     WHERE crapcob.rowid = rw_crapcob.rowid;
                  EXCEPTION
                    WHEN OTHERS THEN                      
                      vr_dscritic := 'Erro ao atualizar valor da tarifa da cobrança (rowid:'||rw_crapcob.rowid||') : '||SQLERRM;
                      CLOSE cr_crapcob;
                      RAISE vr_exc_saida;   
                  END;                  
                END IF;
                CLOSE cr_crapcob;
                -- se conseguiu alterar deve sair do loop
                EXIT;
                 
              EXCEPTION 
                WHEN OTHERS THEN
                 IF cr_crapcob%ISOPEN THEN
                   CLOSE cr_crapcob;
                 END IF;
                 -- se tentou 10x e ainda continua em lock
                 IF i = 10 THEN
                   --gerar log e sair
                   btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                             ,pr_ind_tipo_log => 2 -- Erro tratato
                                             ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '||
                                                                 vr_cdprogra || ' --> Erro atualizacao crapcob valor tarifa '||
                                                                 ' Conta/dv: '||gene0002.fn_mask_conta(rw_craplcb.nrdconta)||
                                                                 ' - '||rw_craplcb.nrdocmto);
                   EXIT;
                 END IF;
                 
                 -- aguardar 1 seg. antes de tentar novamente
                 sys.dbms_lock.sleep(1);  
              END;             
           END LOOP;
          
          END IF; -- Fim IF vr_vltarifa > 0
        END IF;
        
      END LOOP;  /*Fim loop craplcb*/                           
    END LOOP;    /*Fim loop crablot*/                          
    

    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    -- Salvar informações atualizadas
    COMMIT;

  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
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
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;

  END pc_crps215;
/
