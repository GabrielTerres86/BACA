PL/SQL Developer Test script 3.0
293
-- Created on 09/07/2019 by F0030794 
declare 
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/rend3112';
  vr_nomearq         VARCHAR2(100)  := 'listagem-aplicacoes-resgatadas-menor-v3.csv';
  vr_dstitulo        VARCHAR2(500)  := 'rendimento-3112';
  vr_nmarqimp        VARCHAR2(100)  := vr_dstitulo||'-log.txt';
  vr_nmarqimp2       VARCHAR2(100)  := vr_dstitulo||'-sucesso.txt';
  vr_nmarqimp3       VARCHAR2(100)  := vr_dstitulo||'-falha.txt';
  vr_nmarqimp4       VARCHAR2(100)  := vr_dstitulo||'-backup.txt';
  vr_cdhistor        craphis.cdhistor%TYPE := 362;
  vr_ind_arquiv      utl_file.file_type;
  vr_ind_arquiv2     utl_file.file_type;
  vr_ind_arquiv3     utl_file.file_type;
  vr_ind_arquiv4     utl_file.file_type;
  
  vr_cdcritic        crapcri.cdcritic%TYPE;
  vr_dscritic        crapcri.dscritic%TYPE;
  vr_excsaida        EXCEPTION;
  rw_crapdat         btch0001.cr_crapdat%ROWTYPE;
  vr_utl_file        utl_file.file_type;
  vr_dslinha         VARCHAR2(32767);
  vr_txretorn        gene0002.typ_split; --> Separação da linha em vetor
  vr_tab_retorno     LANC0001.typ_reg_retorno;
  vr_tmp_craplot     lote0001.cr_craplot_sem_lock%ROWTYPE;
  vr_incrineg        INTEGER;
  vr_nrseqdig        craplot.nrseqdig%TYPE;
  vr_vltotal         craplcm.vllanmto%TYPE;
  vr_cdcopant        crapcop.cdcooper%TYPE;

  TYPE typ_tab_reg_lanctos IS
    RECORD (cdcooper crapcop.cdcooper%TYPE
           ,nrdconta crapass.nrdconta%TYPE
           ,nraplica craprda.nraplica%TYPE
           ,vllanmto craplcm.vllanmto%TYPE);
                
  TYPE typ_reg_lanctos IS
    TABLE OF typ_tab_reg_lanctos
    INDEX BY VARCHAR2(12);
    
  vr_tab_lanctos typ_reg_lanctos;
  vr_idx_tab VARCHAR2(12);    
  vr_idx     PLS_INTEGER;

  function formata(pr_valor NUMERIC) RETURN VARCHAR2 is
  BEGIN
    return replace(pr_valor,',','.');
  END;

  procedure loga(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, to_char(sysdate,'ddmmyyyy_hh24miss')||' - '|| pr_msg);
  END;
    
  procedure sucesso(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv2, to_char(sysdate,'ddmmyyyy_hh24miss')||' - '|| pr_msg);
  END;
  
  procedure falha(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv3, to_char(sysdate,'ddmmyyyy_hh24miss')||' - '|| pr_msg);
    loga(pr_msg);
  END;
  
  procedure backup(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv4, pr_msg);
  END;
  
begin  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp2       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv2     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp3       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv3     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp4       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv4     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
    
  loga('Inicio Processo - importacao CSV');

  -- Abrir arquivo com os lancamentos para credito
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
  
  vr_tab_lanctos.delete;
  vr_idx := 0;
  vr_idx_tab := '';
  LOOP
    BEGIN
      vr_idx := vr_idx + 1;
      -- le linha do arquivo
      gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_utl_file
                                  ,pr_des_text => vr_dslinha);
      
      -- Ignora cabecalho
      IF vr_idx = 1 THEN
        continue;
      END IF;
      
      -- Estrutura ficara posicao 1-cooper, 2-nrdconta, 3-nraplica, 4-vllanmto
      vr_txretorn := gene0002.fn_quebra_string(vr_dslinha, ';');

      --Monta a chave cooper || nrdconta
      vr_idx_tab := lpad(vr_txretorn(1),2,'0')||lpad(vr_txretorn(2),10,'0');
      
      IF vr_tab_lanctos.exists(vr_idx_tab) THEN
        vr_tab_lanctos(vr_idx_tab).vllanmto := vr_tab_lanctos(vr_idx_tab).vllanmto + replace(vr_txretorn(4),'.',',');
      ELSE
        vr_tab_lanctos(vr_idx_tab).cdcooper := vr_txretorn(1);
        vr_tab_lanctos(vr_idx_tab).nrdconta := vr_txretorn(2);
        vr_tab_lanctos(vr_idx_tab).nraplica := vr_txretorn(3);
        vr_tab_lanctos(vr_idx_tab).vllanmto := replace(vr_txretorn(4),'.',',');
      END IF;

    EXCEPTION
      WHEN no_data_found THEN
        EXIT;
    END;
  END LOOP;
  
  loga('Importado '|| vr_idx || ' registros - com '|| vr_tab_lanctos.count() || ' lancamentos');
  loga('Fim Processo - importacao CSV');
  
  IF vr_tab_lanctos.count() > 18179 THEN
    vr_dscritic := 'Estouro validacao de seguranca 1 - '||formata(vr_tab_lanctos.count());
    RAISE vr_excsaida;
  END IF;
  
  loga('Inicio Processo - efetua lancamento');
   
  vr_vltotal  := 0;
  vr_cdcopant := 0;
  vr_idx_tab := vr_tab_lanctos.FIRST;
  WHILE vr_idx_tab IS NOT NULL LOOP
    
    -- Se mudou a cooperativa, vamos buscar a data novamente
    IF vr_tab_lanctos(vr_idx_tab).cdcooper <> vr_cdcopant THEN
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_tab_lanctos(vr_idx_tab).cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      IF btch0001.cr_crapdat%NOTFOUND THEN
        CLOSE btch0001.cr_crapdat;
        vr_cdcritic := 1;
        RAISE vr_excsaida;
      ELSE
        CLOSE btch0001.cr_crapdat;
      END IF;
      vr_cdcopant := vr_tab_lanctos(vr_idx_tab).cdcooper;
    END IF;
  
    -- Mesmo lote utilizado para resgate de aplicação pcapta - apli0005 - porem com outra agencia
    lote0001.pc_insere_lote_rvt(pr_cdcooper => vr_tab_lanctos(vr_idx_tab).cdcooper
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_cdagenci => 99
                               ,pr_cdbccxlt => 100
                               ,pr_nrdolote => 8503
                               ,pr_cdoperad => '1'
                               ,pr_nrdcaixa => 0
                               ,pr_tplotmov => 1
                               ,pr_cdhistor => 0
                               ,pr_craplot  => vr_tmp_craplot
                               ,pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
       RAISE vr_excsaida;
    END IF;
    
    vr_nrseqdig := fn_sequence('CRAPLOT'
                              ,'NRSEQDIG'
                              ,vr_tab_lanctos(vr_idx_tab).cdcooper||';'
                              ||to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||';'
                              ||'99;'  --cdagenci
                              ||'100;'  --cdbccxlt
                              ||'8503'); --nrdolote
    
    LANC0001.pc_gerar_lancamento_conta(
                          pr_cdcooper => vr_tab_lanctos(vr_idx_tab).cdcooper
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_cdagenci => 99
                         ,pr_cdbccxlt => 100
                         ,pr_nrdolote => 8503
                         ,pr_nrdconta => vr_tab_lanctos(vr_idx_tab).nrdconta
                         ,pr_nrdctabb => vr_tab_lanctos(vr_idx_tab).nrdconta
                         ,pr_nrdocmto => vr_tab_lanctos(vr_idx_tab).nraplica
                         ,pr_nrseqdig => vr_nrseqdig
                         ,pr_dtrefere => rw_crapdat.dtmvtolt
                         ,pr_vllanmto => vr_tab_lanctos(vr_idx_tab).vllanmto
                         ,pr_cdhistor => vr_cdhistor
                         ,pr_nraplica => vr_tab_lanctos(vr_idx_tab).nraplica
                         ,pr_inprolot => 0
                         ,pr_tplotmov => 1
                         -- OUTPUT --
                         ,pr_tab_retorno => vr_tab_retorno
                         ,pr_incrineg => vr_incrineg
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);

    IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
       RAISE vr_excsaida;
    END IF;
    
    backup('delete from craplcm where rowid = '''||vr_tab_retorno.rowidlct||''';');
    
    sucesso('Cooper: '||vr_tab_lanctos(vr_idx_tab).cdcooper||' Conta: '||vr_tab_lanctos(vr_idx_tab).nrdconta||' Valor: '|| formata(vr_tab_lanctos(vr_idx_tab).vllanmto));
    vr_vltotal := vr_vltotal + vr_tab_lanctos(vr_idx_tab).vllanmto;
    
    vr_idx_tab := vr_tab_lanctos.NEXT(vr_idx_tab);    
  END LOOP;  
  
  IF vr_vltotal > 32000 THEN
    vr_dscritic := 'Estouro validacao de seguranca 2 - '||formata(vr_vltotal);
    RAISE vr_excsaida;
  END IF;
  
  sucesso('Total lancado: '||formata(vr_vltotal));
  loga('Fim Processo - efetua lancamento');
  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utl_file); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;  

  :vr_dscritic := 'SUCESSO';
  
  COMMIT;
  
EXCEPTION
  WHEN vr_excsaida then 
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utl_file); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;    
    
  WHEN OTHERS then
    loga(vr_dscritic);
    loga(SQLERRM);
    :vr_dscritic := 'ERRO ' || nvl(vr_dscritic,' ') || SQLERRM;
    rollback;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utl_file); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;  
end;
1
vr_dscritic
0
5
0
