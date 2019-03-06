CREATE OR REPLACE PROCEDURE CECRED.pc_crps781(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa solicitada
                                             ,pr_flgresta  IN PLS_INTEGER           --> Flag padrão para utilização de restart
                                             ,pr_cdoperad IN VARCHAR2                --> Codigo Operador
                                             ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps781 
       Sistema : 
       Sigla   : CRED
       Autor   : Paulo Martins - Mouts
       Data    : Agosto/2018                    Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia : Mensal. 
       Objetivo   : Realizar cancelamentos de seguros prestamistas que não atendem mais as regras do Seguro.
       
       Alteracoes: --/--/---- - 
    ............................................................................ */

    DECLARE 

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS781';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
              ,cop.cdagectl
              ,cop.cdbcoctl
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Seguros residenciais vencidos
       CURSOR cr_crapseg IS
        SELECT pseg.nrdconta,
               pseg.nrctrseg,
               pseg.vlslddev,
               pseg.rowid,
               wseg.nrctrato
          FROM crapseg  pseg,
               crawseg  wseg
         WHERE pseg.cdcooper = pr_cdcooper
           AND pseg.tpseguro = 4  /* Prestamista */
           AND pseg.cdsitseg = 1  /* Ativo */
           AND pseg.nrdconta = wseg.nrdconta
           AND pseg.cdcooper = wseg.cdcooper
           AND pseg.nrctrseg = wseg.nrctrseg
           AND wseg.nrctrato > 0;  
       
      -- Variaveis auxiliares
      vr_flgprestamista varchar2(1) := 'S';        
      vr_flgdps         varchar2(1);
      vr_vlproposta     crawseg.vlseguro%type;  
      vr_dsmotcan  VARCHAR2(60);        
      vr_nrdrowid       ROWID;        
      
    BEGIN

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => NULL);

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

      -- Busca Seguros residenciais vencidos
      FOR rw_seg IN cr_crapseg LOOP        
        --
          segu0003.pc_validar_prestamista(pr_cdcooper => pr_cdcooper
                                        , pr_nrdconta => rw_seg.nrdconta
                                        , pr_nrctremp => rw_seg.nrctrato
                                        , pr_cdagenci => 0
                                        , pr_nrdcaixa => 0
                                        , pr_cdoperad => pr_cdoperad
                                        , pr_nmdatela => 'PC_CRPS781'
                                        , pr_idorigem => 1
                                        , pr_valida_proposta => 'N' -- Não vai somar propostas na validação
                                        , pr_sld_devedor => vr_vlproposta                                       
                                        , pr_flgprestamista => vr_flgprestamista
                                        , pr_flgdps => vr_flgdps
                                        , pr_dsmotcan => vr_dsmotcan
                                        , pr_cdcritic => vr_cdcritic
                                        , pr_dscritic => vr_dscritic);
          --Se ocorreu erro
          IF vr_dscritic IS NULL and vr_flgprestamista = 'N' THEN

          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => ''
                              ,pr_dsorigem => 'Batch'
                              ,pr_dstransa => 'Cancelamento de Prestamista'
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 1
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => 1
                              ,pr_nmdatela => 'CRPS781'
                              ,pr_nrdconta => rw_seg.nrdconta
                              ,pr_nrdrowid => vr_nrdrowid); 
                                    
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'ROWID',
                                    pr_dsdadant => 'ND',
                                    pr_dsdadatu => rw_seg.rowid); 

          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Conta',
                                    pr_dsdadant => 'ND',
                                    pr_dsdadatu => rw_seg.nrdconta); 
                                    
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Contrato',
                                    pr_dsdadant => 'ND',
                                    pr_dsdadatu => rw_seg.nrctrato);                                    

          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Saldo Devedor',
                                    pr_dsdadant => 'ND',
                                    pr_dsdadatu => vr_vlproposta); 
                                      
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Flag DPS',
                                    pr_dsdadant => 'ND',
                                    pr_dsdadatu => vr_flgdps); 

          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Motivo Cancel.',
                                    pr_dsdadant => 'ND',
                                    pr_dsdadatu => vr_dsmotcan);                                    
            --  
            begin
              update crapseg s
                 set s.cdsitseg = 2, -- Cancelado
                     s.dtcancel = rw_crapdat.dtmvtopr,
                     s.dtfimvig = rw_crapdat.dtmvtopr
                    -- s.dsmotcan = vr_dsmotcan
               where s.rowid = rw_seg.rowid;
            exception
            when others then
              vr_dscritic := sqlerrm;
            end;
            --
          END IF;
          --
          IF vr_dscritic IS NOT NULL THEN
            -- Incrementar a critica
            vr_dscritic := 'Nao foi cancelar seguro prestamista. '
                        || ' Conta: ' || rw_seg.nrdconta ||'. Critica: '||vr_dscritic;
            -- Gerar  LOG          
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );          
            -- Ir ao próximo registro
            continue;                   
            
          END IF;
      END LOOP; 
     
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
    END;

  END pc_crps781;
/
