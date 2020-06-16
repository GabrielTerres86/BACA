PL/SQL Developer Test script 3.0
305
-- \micros\cpd\bacas\INC0051255\listagem-tarifas.csv
DECLARE
    vr_rootmicros VARCHAR2(5000) := gene0001.fn_param_sistema('CRED', 3, 'ROOT_MICROS');
    vr_nmdireto   VARCHAR2(4000) := vr_rootmicros || 'cpd/bacas/INC0051255';
    vr_nomearq    VARCHAR2(100) := 'listagem-tarifas.csv';

    vr_nmarqimp  VARCHAR2(100) := 'listagem-tarifas-log.txt';
    vr_nmarqimp2 VARCHAR2(100) := 'listagem-tarifas-sucesso.txt';
    vr_nmarqimp3 VARCHAR2(100) := 'listagem-tarifas-falha.txt';
    vr_nmarqimp4 VARCHAR2(100) := 'listagem-tarifas-backup.txt';

    vr_ind_arquiv  utl_file.file_type;
    vr_ind_arquiv2 utl_file.file_type;
    vr_ind_arquiv3 utl_file.file_type;
    vr_ind_arquiv4 utl_file.file_type;

    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_excsaida EXCEPTION;
    rw_crapdat     btch0001.cr_crapdat%ROWTYPE;
    vr_utl_file    utl_file.file_type;
    vr_dslinha     VARCHAR2(32767);
    vr_txretorn    gene0002.typ_split; --> Separação da linha em vetor
    vr_tab_retorno lanc0001.typ_reg_retorno;
    vr_tmp_craplot lote0001.cr_craplot_sem_lock%ROWTYPE;
    vr_incrineg    INTEGER;
    vr_nrseqdig    craplot.nrseqdig%TYPE;
    vr_vltotal     craplcm.vllanmto%TYPE;
    vr_cdcopant    crapcop.cdcooper%TYPE;

    vr_cdmodalidade_tipo tbcc_tipo_conta.cdmodalidade_tipo%TYPE;

    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_des_erro VARCHAR2(100);

    -- Variaveis Tarifa
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_nrdconta crapass.nrdconta%TYPE;

    vr_cdhistor craphis.cdhistor%TYPE;
    vr_cdfvlcop crapfco.cdfvlcop%TYPE;
    vr_vlrtarif crapfco.vltarifa%TYPE;
    vr_cdbattar VARCHAR2(100) := ' ';
    vr_cdpesqbb VARCHAR2(4);

    -- Rowid de retorno lançamento de tarifa
    vr_rowid ROWID;

    vr_idx PLS_INTEGER;

    -------------------------- TABELAS TEMPORARIAS --------------------------
    -- Tabela Temporaria para erros
    vr_tab_erro      gene0001.typ_tab_erro;
    vr_tab_tari_pend tari0001.typ_tab_tarifas_pend;

    FUNCTION formata(pr_valor NUMERIC) RETURN VARCHAR2 IS
    BEGIN
        RETURN REPLACE(pr_valor, ',', '.');
    END;

    PROCEDURE loga(pr_msg VARCHAR2) IS
    BEGIN
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv
                                      ,to_char(SYSDATE, 'ddmmyyyy_hh24miss') || ' - ' || pr_msg);
    END;

    PROCEDURE sucesso(pr_msg VARCHAR2) IS
    BEGIN
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv2
                                      ,to_char(SYSDATE, 'ddmmyyyy_hh24miss') || ' - ' || pr_msg);
    END;

    PROCEDURE falha(pr_msg VARCHAR2) IS
    BEGIN
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv3
                                      ,to_char(SYSDATE, 'ddmmyyyy_hh24miss') || ' - ' || pr_msg);
        loga(pr_msg);
    END;

    PROCEDURE backup(pr_msg VARCHAR2) IS
    BEGIN
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv4, pr_msg);
    END;

BEGIN
    --Criar arquivo
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto --> Diretorio do arquivo
                            ,pr_nmarquiv => vr_nmarqimp --> Nome do arquivo
                            ,pr_tipabert => 'W' --> modo de abertura (r,w,a)
                            ,pr_utlfileh => vr_ind_arquiv --> handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic); --> erro
    -- em caso de crítica
    IF vr_dscritic IS NOT NULL THEN
        RAISE vr_excsaida;
    END IF;

    --Criar arquivo
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto --> Diretorio do arquivo
                            ,pr_nmarquiv => vr_nmarqimp2 --> Nome do arquivo
                            ,pr_tipabert => 'W' --> modo de abertura (r,w,a)
                            ,pr_utlfileh => vr_ind_arquiv2 --> handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic); --> erro
    -- em caso de crítica
    IF vr_dscritic IS NOT NULL THEN
        RAISE vr_excsaida;
    END IF;

    --Criar arquivo
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto --> Diretorio do arquivo
                            ,pr_nmarquiv => vr_nmarqimp3 --> Nome do arquivo
                            ,pr_tipabert => 'W' --> modo de abertura (r,w,a)
                            ,pr_utlfileh => vr_ind_arquiv3 --> handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic); --> erro
    -- em caso de crítica
    IF vr_dscritic IS NOT NULL THEN
        RAISE vr_excsaida;
    END IF;

    --Criar arquivo
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto --> Diretorio do arquivo
                            ,pr_nmarquiv => vr_nmarqimp4 --> Nome do arquivo
                            ,pr_tipabert => 'W' --> modo de abertura (r,w,a)
                            ,pr_utlfileh => vr_ind_arquiv4 --> handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic); --> erro
    -- em caso de crítica
    IF vr_dscritic IS NOT NULL THEN
        RAISE vr_excsaida;
    END IF;

    loga('Inicio Processo - Importacao CSV');

    -- Abrir arquivo das tarifas para debito
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                            ,pr_nmarquiv => vr_nomearq
                            ,pr_tipabert => 'R'
                            ,pr_utlfileh => vr_utl_file
                            ,pr_des_erro => vr_dscritic);
    -- Se houve erro, parar o processo
    IF vr_dscritic IS NOT NULL THEN
        -- Retornar com a critica
        RAISE vr_excsaida;
    END IF;

    vr_idx := 0;
    LOOP
        BEGIN
            vr_idx := vr_idx + 1;
            -- le linha do arquivo
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_utl_file, pr_des_text => vr_dslinha);
        
            -- Ignora cabecalho
            IF vr_idx = 1 THEN
                CONTINUE;
            END IF;
        
            -- Estrutura ficara posicao 1-nrdconta, 2-tppessoa, 3-cdcooper, 4-nmrescop, 5-mesref, 6-vltarifa
            vr_txretorn := gene0002.fn_quebra_string(vr_dslinha, ';');
        
            vr_cdcooper := vr_txretorn(3);
            vr_nrdconta := vr_txretorn(1);
            vr_vlrtarif := trim(translate(vr_txretorn(6), chr(10) || chr(13) || chr(09), ' '));
            
            IF btch0001.cr_crapdat%ISOPEN THEN
               CLOSE btch0001.cr_crapdat;
            END IF;
            
            -- Leitura do calendário da cooperativa
            OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
            FETCH btch0001.cr_crapdat INTO rw_crapdat;

            -- Se não encontrar
            IF btch0001.cr_crapdat%NOTFOUND THEN
              CLOSE btch0001.cr_crapdat;
            END IF;
            
            CLOSE btch0001.cr_crapdat;
        
            cada0006.pc_busca_modalidade_conta(pr_cdcooper          => vr_cdcooper
                                              ,pr_nrdconta          => vr_nrdconta
                                              ,pr_cdmodalidade_tipo => vr_cdmodalidade_tipo
                                              ,pr_des_erro          => vr_des_erro
                                              ,pr_dscritic          => vr_dscritic);
            IF vr_des_erro <> 'OK' THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao buscar modalidade conta. Conta: ' || gene0002.fn_mask_conta(vr_nrdconta) || ' - ' || vr_dscritic;
                -- Envio centralizado de log de erro
                falha(vr_dscritic);
                -- Limpa valores das variaveis de critica
                vr_cdcritic := 0;
                vr_dscritic := NULL;
                CONTINUE;
            END IF;
            
            vr_cdhistor := 1792;
            vr_cdfvlcop := 361;
        
            CASE
                WHEN vr_txretorn(2) = 'PF' THEN
                    vr_cdbattar := 'TFCTAITGPF';
                    vr_cdhistor := 1790;
                    vr_cdfvlcop := 360;
                WHEN vr_txretorn(2) = 'PJ' AND vr_cdmodalidade_tipo = 4 THEN
                    -- Entes publicos
                    vr_cdbattar := 'TFCTAITGEP';
                ELSE
                    vr_cdbattar := 'TFCTAITGPJ';
                    
            END CASE;
        
            -- Zera valor do rowid
            vr_rowid := NULL;

            vr_cdpesqbb := lpad(vr_txretorn(5), 2, '0') || '20';
            
            -- Criar Lançamento automatico tarifa
            tari0001.pc_cria_lan_auto_tarifa(pr_cdcooper      => vr_cdcooper
                                            ,pr_nrdconta      => vr_nrdconta
                                            ,pr_dtmvtolt      => rw_crapdat.dtmvtolt
                                            ,pr_cdhistor      => vr_cdhistor
                                            ,pr_vllanaut      => vr_vlrtarif
                                            ,pr_cdoperad      => '1'
                                            ,pr_cdagenci      => 1
                                            ,pr_cdbccxlt      => 100
                                            ,pr_nrdolote      => 10138
                                            ,pr_tpdolote      => 1
                                            ,pr_nrdocmto      => 0 /*rw_crabepr.nrctremp*/
                                            ,pr_nrdctabb      => vr_nrdconta
                                            ,pr_nrdctitg      => gene0002.fn_mask(vr_nrdconta, '99999999')
                                            ,pr_cdpesqbb      => 'Fato gerador tarifa:' || vr_cdpesqbb
                                            ,pr_cdbanchq      => 0
                                            ,pr_cdagechq      => 0
                                            ,pr_nrctachq      => 0
                                            ,pr_flgaviso      => FALSE
                                            ,pr_tpdaviso      => 0
                                            ,pr_cdfvlcop      => vr_cdfvlcop
                                            ,pr_inproces      => rw_crapdat.inproces
                                            ,pr_rowid_craplat => vr_rowid
                                            ,pr_tab_erro      => vr_tab_erro
                                            ,pr_cdcritic      => vr_cdcritic
                                            ,pr_dscritic      => vr_dscritic);
                                            
            --Se ocorreu erro
            IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                --Se possui erro no vetor
                IF vr_tab_erro.count > 0 THEN
                    vr_cdcritic := vr_tab_erro(1).cdcritic;
                    vr_dscritic := vr_tab_erro(1).dscritic;
                ELSE
                    vr_cdcritic := 0;
                    vr_dscritic := 'Erro no lancamento tarifa.';
                END IF;
                -- gera log do erro ocorrido
                vr_dscritic := vr_dscritic || ' Conta: ' || gene0002.fn_mask_conta(vr_nrdconta) || ' - ' ||
                               vr_cdbattar;
                -- Envio centralizado de log de erro
                falha(vr_dscritic);
                CONTINUE;
            END IF;
        
            backup('DELETE FROM craplat WHERE rowid = ''' || vr_rowid || ''';');
        
            sucesso(vr_cdcooper || ';' || vr_nrdconta || ';' || formata(vr_vlrtarif));
        
        EXCEPTION
            WHEN no_data_found THEN
                EXIT;
        END;
    END LOOP;

    :vr_dscritic := 'SUCESSO';

    COMMIT;

    loga('Fim Processo - Importacao CSV');
    
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utl_file); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;    

EXCEPTION
    WHEN vr_excsaida THEN
        :vr_dscritic := 'ERRO ' || vr_dscritic;
        ROLLBACK;
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utl_file); --> Handle do arquivo aberto;  
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;    

    WHEN OTHERS THEN
        loga(vr_dscritic);
        loga(SQLERRM);
        :vr_dscritic := 'ERRO ' || nvl(vr_dscritic, ' ') || SQLERRM;
        ROLLBACK;
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utl_file); --> Handle do arquivo aberto;  
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto; 
END;
1
vr_dscritic
1
SUCESSO
5
1
vr_vlrtarif
