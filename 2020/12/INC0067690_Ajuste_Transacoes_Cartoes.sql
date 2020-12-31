declare 
  vr_cdcritic   crapcri.cdcritic%TYPE;
  vr_dscritic   varchar2(5000) := ' ';
  vr_excsaida EXCEPTION;
  
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0067690';
 -- vr_nmdireto        VARCHAR2(4000) := 'F://Documents/Testes/INC0067690';
  vr_nmarqimp        VARCHAR2(100)  := 'log.txt';
  vr_nmarqimp2       VARCHAR2(100)  := 'sucesso.txt';
  vr_nmarqimp3       VARCHAR2(100)  := 'falha.txt';
  vr_nmarqimp4       VARCHAR2(100)  := 'backup.txt';
  vr_ind_arquiv      utl_file.file_type;
  vr_ind_arquiv2     utl_file.file_type;
  vr_ind_arquiv3     utl_file.file_type;
  vr_ind_arquiv4     utl_file.file_type;
  
  cursor cr_crapcar IS
     SELECT crd.rowid, crd.nrconta_cartao, crd.dtmvtolt, crd.cdcooper, crd.nrdconta, 
           (select car.cdcooper from tbcrd_conta_cartao car where  crd.nrconta_cartao = car.nrconta_cartao) coop_certa,
           (select car.nrdconta from tbcrd_conta_cartao car where crd.nrconta_cartao = car.nrconta_cartao) conta_certa,
           crd.qttransa_debito, crd.qttransa_credito, crd.vltransa_debito, crd.vltransa_credito 
    from tbcrd_utilizacao_cartao crd
    where not exists(Select 1 from tbcrd_conta_cartao car where crd.cdcooper = car.cdcooper and crd.nrdconta = car.nrdconta and crd.nrconta_cartao = car.nrconta_cartao)
          and crd.dtmvtolt between '01/01/2020'  AND '31/12/2020';
  rw_crapcar cr_crapcar%ROWTYPE;

  vr_vlsppant_correto craprpp.vlsppant%TYPE;

  procedure loga(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, pr_msg);
  END;
    
  procedure sucesso(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv2, pr_msg);
  END;
  
  procedure falha(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv3, pr_msg);
    loga(pr_msg);
  END;
  
  procedure backup(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv4, pr_msg);
  END;

BEGIN
  
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
  
  loga('Ajustando a conta ao cartão: Cooper Associada: '  || rw_crapcar.cdcooper || 
                                     ' Cooper Correta: '  || rw_crapcar.coop_certa ||
                                     ' Conta Associada: ' || rw_crapcar.nrdconta ||
                                     ' Conta Correta: '   || rw_crapcar.conta_certa);
 
    -- Gera backup com valor atual do campo - script de rollback
    backup('update tbcrd_utilizacao_cartao set nrdconta = '|| rw_crapcar.nrdconta || ', cdcooper = ' || rw_crapcar.cdcooper ||
           ' where tbcrd_utilizacao_cartao.rowid = '''|| rw_crapcar.rowid ||''';');    
    
    BEGIN
      UPDATE tbcrd_utilizacao_cartao
         SET nrdconta      = rw_crapcar.conta_certa,
             cdCooper      = rw_crapcar.coop_certa
       WHERE tbcrd_utilizacao_cartao.rowid = rw_crapcar.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := ' Erro atualizando tbcrd_utilizacao_cartao!' || 
                       ' Cooper Associada: '|| rw_crapcar.cdcooper || 
                       ' Cooper Correta: '  || rw_crapcar.coop_certa ||
                       ' Conta Associada: ' || rw_crapcar.nrdconta ||
                       ' Conta Correta: '   || rw_crapcar.conta_certa || ' SQLERRM: ' || SQLERRM;
        loga(vr_dscritic);
        falha(vr_dscritic);
        RAISE vr_excsaida;
    END;

    sucesso('Cartão associado a conta correta: Cooper: '|| rw_crapcar.cdcooper || 
            ' Cartão: ' ||rw_crapcar.nrconta_cartao || 
            ' Cooper Errada: '|| rw_crapcar.cdcooper || 
            ' Cooper Correta: '  || rw_crapcar.coop_certa ||
            ' Conta Errada: ' ||rw_crapcar.nrdconta || 
            ' Conta Certa: ' || rw_crapcar.Conta_certa);
  END LOOP;
  
  COMMIT;

  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;  

  :vr_dscritic := 'SUCESSO';
  
EXCEPTION
  WHEN vr_excsaida then 
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;
    
  WHEN OTHERS then
    loga(vr_dscritic);
    loga(SQLERRM);
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;
end;
