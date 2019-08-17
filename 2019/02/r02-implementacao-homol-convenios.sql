declare 

  -- Loop entre cooperativas ativas
  cursor cr_crapcop is
  select cop.cdcooper
    from crapcop cop;

  -- Variaveis do script
  nm_nrseqrdr  number;
  vr_idprglog  number;
  vr_dscritic  varchar2(1000);
  vr_nmdireto  varchar2(100);
  vr_nmarquiv  varchar2(100) := 'backup-exec-script-convenios.log';
  vr_utlfile   utl_file.file_type;
  vr_exc_saida exception;
  vr_cdoperad  gene0002.typ_split;
  vr_database  varchar2(100);
  
begin

  -- Busca ambiente conectado
  vr_database := GENE0001.fn_database_name;
/*
  -- Nao permitido em ambiente de producao
  if instr(upper(vr_database),'P',1) > 0 then
    vr_dscritic := 'Ambiente não permite esta operação.';
    raise vr_exc_saida;
  end if;
*/
  begin
    -- Busca do diretorio base da cooperativa
    vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => 3
                                        ,pr_nmsubdir => 'log');
    -- Abre arquivo para registro de logs
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                            ,pr_nmarquiv => vr_nmarquiv
                            ,pr_tipabert => 'W'
                            ,pr_utlfileh => vr_utlfile
                            ,pr_des_erro => vr_dscritic);
  exception
    when others then
      vr_dscritic := 'Erro ao manipular arquivo de log: '||sqlerrm;
      raise vr_exc_saida;
  end;
  
  -- Aborta caso variavel contenha erro
  if trim(vr_dscritic) is not null then
    vr_dscritic := 'Erro ao executar gene0001.pc_abre_arquivo: '||vr_dscritic;
    raise vr_exc_saida;
  end if;

  begin
    -- Cria acessos na tabela para mensageria
    insert into craprdr (nmprogra,dtsolici)                                values ('TELA_HCONVE',sysdate) returning nrseqrdr into nm_nrseqrdr;
    insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR) values ('POPULAR_OPCAO_H',        'TELA_HCONVE', 'pc_popular_opcao_h',           null,                                                                                                     nm_nrseqrdr);
    insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR) values ('HOMOL_AUTO_DEB_CONV',    'TELA_HCONVE', 'pc_conv_autori_de_debito_web', 'pr_cdconven',                                                                  nm_nrseqrdr);
    insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR) values ('HOMOL_FATURAS',          'TELA_HCONVE', 'pc_conv_homologa_faturas_web', 'pr_cdconven',                                                                                            nm_nrseqrdr);
    insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR) values ('PC_BUSCA_CONVENIOS',     'TELA_HCONVE', 'pc_busca_convenio',            'pr_cdconven, pr_nmempres, pr_nrregist, pr_nriniseq',                                                     nm_nrseqrdr);
    insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR) values ('IMPORTA_ARQ',            'TELA_HCONVE', 'pc_conv_importa_arquivos_web', 'pr_dsarquiv,pr_dsdireto',                                                                                nm_nrseqrdr);
    insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR) values ('PC_HIST_LUPA_OPCAO_H',   'TELA_HCONVE', 'pc_hist_lupa_opcao_h',         'pr_cdhistor, pr_dsexthst,pr_nrregist, pr_nriniseq',                                                      nm_nrseqrdr);
    insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR) values ('PC_CRIAR_HISTORICO_WEB', 'TELA_HCONVE', 'pc_criar_historico_web',       'pr_hisconv1, pr_hisrefe1, pr_nmabrev1, pr_nmexten1, pr_hisconv2, pr_hisrefe2, pr_nmabrev2, pr_nmexten2', nm_nrseqrdr);
    insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR) values ('LIMPAR_AUTO_DEB_CONV',   'TELA_HCONVE', 'pc_limpar_autori_de_debito',   'pr_cdconven',                                                                                            nm_nrseqrdr);
    insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR) values ('LIMPAR_FATURAS',         'TELA_HCONVE', 'pc_limpar_homologa_faturas',   'pr_cdconven',                                                                                            nm_nrseqrdr);
  exception
    when others then
      vr_dscritic := 'Erro ao inserir dados para mensageria da tela hconve: '||sqlerrm;
      raise vr_exc_saida;
  end;

  for rw_crapcop in cr_crapcop loop
    begin
      -- Inserir parametros para acesso da tela hconve
      insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
           values ('HCONVE', 5, '@,A,F,H,I', 'Tela de homologacao de convenios', 'Tela de homologacao de convenios', 0, 1, ' ', 'ACESSO,AUTORIZA DEB.,FATURAS,HISTORICO,IMPORTACAO', 0, rw_crapcop.cdcooper, 1, 0, 1, 1, ' ', 2);
    exception
      when others then
        vr_dscritic := 'Erro ao inserir parametros para acesso web: '||rw_crapcop.cdcooper||' - '||sqlerrm;
        raise vr_exc_saida;
    end;

    begin
      -- Insere o registro de cadastro do programa
      insert into crapprg (nmsistem, cdprogra, dsprogra##1, dsprogra##2, dsprogra##3, dsprogra##4, nrsolici, nrordprg, 
                           inctrprg, cdrelato##1, cdrelato##2, cdrelato##3, cdrelato##4, cdrelato##5, inlibprg, cdcooper) 
          (select 'CRED', 'HCONVE', 'Tela de homologacao de convenios', '.', '.', '.', 50,
                  (select max(crapprg.nrordprg) + 1 
                    from crapprg 
                   where crapprg.cdcooper = crapcop.cdcooper 
                     and crapprg.nrsolici = 50), 1, 0, 0, 0, 0, 0, 1, crapcop.cdcooper
             from crapcop          
            where cdcooper = rw_crapcop.cdcooper);
    exception
      when others then
        vr_dscritic := 'Erro ao inserir dados na tabela crapprg: '||rw_crapcop.cdcooper||' - '||sqlerrm;
        raise vr_exc_saida;
    end;
  end loop;

  gene0001.pc_fecha_arquivo(vr_utlfile);
  
  commit;

exception
  
  when vr_exc_saida then

    rollback;
      
    vr_idprglog := 0;
    
    cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                          ,pr_cdprograma    => vr_nmarquiv
                          ,pr_cdcooper      => 3
                          ,pr_tpexecucao    => 3   -- Online
                          ,pr_tpocorrencia  => 2   -- Erro nao tratado
                          ,pr_cdcriticidade => 3   -- Critico
                          ,pr_cdmensagem    => 0
                          ,pr_dsmensagem    => '(1) '||sqlerrm||' Module: '||vr_dscritic
                          ,pr_idprglog      => vr_idprglog);
  
    gene0001.pc_escr_linha_arquivo(vr_utlfile,vr_dscritic); 
    gene0001.pc_fecha_arquivo(vr_utlfile);
    
  when others then
    
    rollback;
      
    vr_idprglog := 0;
    
    cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                          ,pr_cdprograma    => vr_nmarquiv
                          ,pr_cdcooper      => 3
                          ,pr_tpexecucao    => 3   -- Online
                          ,pr_tpocorrencia  => 2   -- Erro nao tratado
                          ,pr_cdcriticidade => 3   -- Critico
                          ,pr_cdmensagem    => 0
                          ,pr_dsmensagem    => '(2) '||sqlerrm||' Module: '||vr_dscritic
                          ,pr_idprglog      => vr_idprglog);
  
    gene0001.pc_escr_linha_arquivo(vr_utlfile,vr_dscritic); 
    gene0001.pc_fecha_arquivo(vr_utlfile);

end;