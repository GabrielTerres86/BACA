CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS696(pr_cdcooper IN  crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                             ,pr_flgresta IN  PLS_INTEGER            --> Indicador para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
BEGIN
  
    /*..............................................................................

     Programa: pc_crps696
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Carlos Rafael Tanholi
     Data    : Agosto/2015                       Ultima atualizacao: 26/08/2015

     Dados referentes ao programa:

     Frequencia: Mensal.

     Objetivo  : Ler todas as contas ativas no sistema que utilizam serviço de malote, e criar
                 lançamento na tabela craplat, referente ao débito da tarifa.

     Alterações: 26/08/2015 - Inclusao do parametro pr_cdpesqbb na procedure
                              tari0001.pc_cria_lan_auto_tarifa, projeto de 
                              Tarifas-218(Jean Michel)                       
    ...............................................................................*/

    DECLARE
    
    ------------------------------- VARIAVEIS -------------------------------  
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS696';
    vr_email_dest VARCHAR2(80);
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_des_erro   VARCHAR2(4000);   
    -- Variaveis Tarifa
    vr_vltottar   NUMBER := 0;
    vr_vliofaux   NUMBER := 0;
    vr_cdhistor   craphis.cdhistor%TYPE;
    vr_cdhisest   craphis.cdhistor%TYPE;
    vr_dstextab   craptab.dstextab%TYPE;
    vr_dtdivulg   DATE;
    vr_dtvigenc   DATE;
    vr_cdfvlcop   crapfco.cdfvlcop%TYPE;
    vr_vlrtarif   crapfco.vltarifa%TYPE;
    vr_cdbattar   VARCHAR2(100) := ' ';
    vr_cdhistmp   craphis.cdhistor%TYPE;
    vr_cdfvltmp   crapfco.cdfvlcop%TYPE;
    -- Rowid de retorno lançamento de tarifa
    vr_rowid      ROWID;
    
    -------------------------- TABELAS TEMPORARIAS --------------------------
    -- Tabela Temporaria para erros
    vr_tab_erro GENE0001.typ_tab_erro;    

    
    ------------------------------- CURSORES --------------------------------  
    -- Cursor Genérico de Calendário
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;    
    
    -- cursor para filtrar os associados que utilizam o servico de malote
    CURSOR cr_crapass( pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapass.nrdconta
          ,crapass.nmprimtl
          ,crapass.inpessoa
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
       AND crapass.indserma = 1 
       AND crapass.dtdemiss IS NULL;
    
    rw_crapass cr_crapass%ROWTYPE;

    
    BEGIN
      
      -- VALIDAÇÕES INICIAIS DO PROGRAMA
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                                pr_flgbatch => 1,
                                pr_cdprogra => vr_cdprogra,
                                pr_infimsol => pr_infimsol,
                                pr_cdcritic => pr_cdcritic);

      IF vr_cdcritic <> 0 THEN
        -- SAIR DO PROCESSO RETORNANDO A CRITICA
        RAISE vr_exc_erro;
      END IF;
    
      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
       -- Fechar o cursor pois havera raise
       CLOSE BTCH0001.cr_crapdat;
       -- Montar mensagem de critica
       vr_cdcritic:= 1;
       vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       RAISE vr_exc_erro;
      ELSE
       -- Apenas fechar o cursor
       CLOSE BTCH0001.cr_crapdat;
      END IF;    
    
      -- Filtra os associados
      FOR rw_crapass IN cr_crapass(pr_cdcooper => pr_cdcooper) 
        LOOP          

          IF rw_crapass.inpessoa = 1 THEN
            --vr_cdbattar := 'TFMALOTEPF'; -- Tarifa Malote Pessoa Fisica
            vr_cdbattar := 'TFMALOTEPF'; -- Tarifa Malote Pessoa Fisica            
          ELSE
            vr_cdbattar := 'TFMALOTEPJ'; -- Tarifa Malote Pessoa Juridica
          END IF;
          -- busca dados do cadastro da tarifa de acordo com tipo pessoa (F/J)
          TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                               ,pr_cdbattar => vr_cdbattar
                                               ,pr_vllanmto => 0 --> faixa de valor 0..999
                                               ,pr_cdprogra => vr_cdprogra
                                               ,pr_cdhistor => vr_cdhistor
                                               ,pr_cdhisest => vr_cdhisest
                                               ,pr_vltarifa => vr_vlrtarif
                                               ,pr_dtdivulg => vr_dtdivulg
                                               ,pr_dtvigenc => vr_dtvigenc
                                               ,pr_cdfvlcop => vr_cdfvlcop
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic
                                               ,pr_tab_erro => vr_tab_erro);
                                                          
          --Se ocorreu erro
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Se possui erro no vetor
            IF vr_tab_erro.Count() > 0 THEN
              vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Nao foi possivel carregar a tarifa ('+vr_cdbattar+')';
            END IF;
            
            -- Recuperar emails de destino
            vr_email_dest:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'SIGLA_AREA');            
            
            -- Enviar e-mail para equipe de negocio
            gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                      ,pr_cdprogra        => vr_cdprogra
                                      ,pr_des_destino     => vr_email_dest
                                      ,pr_des_assunto     => 'Tarifa de Servico de Malote nao encontrada'
                                      ,pr_des_corpo       => vr_dscritic
                                      ,pr_des_anexo       => NULL
                                      ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                      ,pr_flg_remete_coop => 'N' --> Se o envio será do e-mail da Cooperativa
                                      ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                      ,pr_des_erro        => vr_des_erro);
                                      
            IF vr_des_erro IS NOT NULL  THEN
              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            || vr_cdprogra || ' --> '
                                                            || vr_des_erro );
              RAISE vr_exc_erro;
            END IF;
                          
            -- Apos enviar email aborta execucao e gera ROOLBACK
            RAISE vr_exc_erro;
            
          ELSE
            -- Criar Lançamento automatico tarifa
            TARI0001.pc_cria_lan_auto_tarifa( pr_cdcooper     => pr_cdcooper
                                            , pr_nrdconta     => rw_crapass.nrdconta
                                            , pr_dtmvtolt     => rw_crapdat.dtmvtolt
                                            , pr_cdhistor     => vr_cdhistor
                                            , pr_vllanaut     => vr_vlrtarif
                                            , pr_cdoperad     => '1'
                                            , pr_cdagenci     => 1
                                            , pr_cdbccxlt     => 100
                                            , pr_nrdolote     => 10135
                                            , pr_tpdolote     => 1
                                            , pr_nrdocmto     => 0 /*rw_crabepr.nrctremp*/
                                            , pr_nrdctabb     => rw_crapass.nrdconta
                                            , pr_nrdctitg     => gene0002.fn_mask(rw_crapass.nrdconta,'99999999')
                                            , pr_cdpesqbb     => 'Fato gerador tarifa:' || TO_CHAR(rw_crapdat.dtmvtolt,'MMYY')
                                            , pr_cdbanchq     => 0
                                            , pr_cdagechq     => 0
                                            , pr_nrctachq     => 0
                                            , pr_flgaviso     => FALSE
                                            , pr_tpdaviso     => 0
                                            , pr_cdfvlcop     => vr_cdfvlcop
                                            , pr_inproces     => rw_crapdat.inproces
                                            , pr_rowid_craplat=> vr_rowid
                                            , pr_tab_erro     => vr_tab_erro
                                            , pr_cdcritic     => vr_cdcritic
                                            , pr_dscritic     => vr_dscritic);
            --Se ocorreu erro
            IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              --Se possui erro no vetor
              IF vr_tab_erro.Count > 0 THEN
                vr_cdcritic:= vr_tab_erro(1).cdcritic;
                vr_dscritic:= vr_tab_erro(1).dscritic;
              ELSE
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro no lancamento tarifa adtivo.';
              END IF;
              -- gera log do erro ocorrido
              vr_dscritic:= vr_dscritic ||' Conta: '||gene0002.fn_mask_conta(rw_crapass.nrdconta)||' - '||vr_cdbattar;
              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || vr_dscritic );
            END IF;

          END IF;
    
        END LOOP;
        
        ----------------- ENCERRAMENTO DO PROGRAMA -------------------

        -- Processo OK, devemos chamar a fimprg
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);       
        
        -- Salva informacoes atualizadas
        COMMIT;
         
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 THEN
          -- Buscar a descrição
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        ELSE
          pr_cdcritic := 0;
          pr_dscritic := vr_dscritic;            
        END IF;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
    
END PC_CRPS696;
/

