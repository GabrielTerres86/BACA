begin

  declare
  
    ds_exc_erro_v      exception;
    ds_erro_registro_v exception;
    ds_critica_v          crapcri.dscritic%type;
    ds_critica_rollback_v crapcri.dscritic%type;
    ie_idprglog_v         cecred.tbgen_prglog.idprglog%type := 0;
  
    ds_dados_rollback_v   clob := null;
    ds_texto_rollback_v   varchar2(32600);
    nm_arquivo_rollback_v varchar2(100);
  
    cd_cooperativa_v    cecred.crapcop.cdcooper%type := 3;
    ds_nome_diretorio_v cecred.crapprm.dsvlrprm%type;
  
    qt_reg_commit  number(10) := 0;
    nr_arquivo     number(10) := 1;
    qt_reg_arquivo number(10) := 50000;
  
    cursor c01 is
      select a.cdcooper,
             a.nrproposta,
             a.rowid as nr_linha_tbseg,
             a.tpregist,
             c.rowid as nr_linha_crap,
             decode(a.nrproposta,
                    '770628945675',
                    107.24,
                    '770629331379',
                    513.31,
                    '770629333495',
                    618,
                    '770628804257',
                    126.7,
                    '770629679626',
                    192.95,
                    '770629680535',
                    297.87,
                    '770628945349',
                    378.51,
                    '770629678913',
                    258.57,
                    '770628805903',
                    223.23,
                    '770629224092',
                    112.57,
                    '770628803951',
                    187.12,
                    '770628945900',
                    495.5,
                    '770629331867',
                    1018.2,
                    '770629331883',
                    73.93,
                    '770629333533',
                    491,
                    '770628802629',
                    52.37,
                    '770629332553',
                    20.88,
                    '770629679758',
                    484.09,
                    '770629331565',
                    596.72,
                    '770629333282',
                    361.33,
                    '770629680713',
                    563.05,
                    '770629224335',
                    44.85,
                    '770628803943',
                    7.81,
                    '770629332677',
                    349.45,
                    '770629271872',
                    460.42,
                    '770629332979',
                    146.99,
                    '770628804702',
                    301.62,
                    '770628806004',
                    5.96,
                    '770629002944',
                    874.93,
                    '770629332928',
                    397.21,
                    '770629441603',
                    496.34,
                    '770629332952',
                    49.44,
                    '770628803897',
                    98.7,
                    '770629331921',
                    640.78,
                    '770629331484',
                    160.34,
                    '770629270183',
                    91.97,
                    '770629271791',
                    558.62,
                    '770629678042',
                    139.88,
                    '770629224009',
                    362,
                    '770628804508',
                    88.65,
                    '770629270337',
                    254.61,
                    '770629332421',
                    16.62,
                    '770629333690',
                    1102.07,
                    '770629331220',
                    126.04,
                    '770629331387',
                    547.56,
                    '770629680306',
                    37.24,
                    '770629679529',
                    1473.57,
                    '770628803080',
                    480.71,
                    '770629441450',
                    464.91,
                    '770629436863',
                    2.63,
                    '770629332995',
                    386.75,
                    '770629680497',
                    476.25,
                    '770629439390',
                    188.4,
                    '770628802610',
                    333.59,
                    '770628805296',
                    56.85,
                    '770628805431',
                    244.98,
                    '770628802491',
                    400.58,
                    '770629331751',
                    916.75,
                    '770628945500',
                    828.76,
                    '770629001638',
                    732.15,
                    '770629332200',
                    511.02,
                    '770629331433',
                    307.17,
                    '770629271112',
                    6.27,
                    '770629333452',
                    630.91,
                    '770628803307',
                    344.14,
                    '770629441417',
                    127.36,
                    '770629331328',
                    134.04,
                    '770628945888',
                    4.41,
                    '770629680543',
                    633.73,
                    '770629439463',
                    10.51,
                    '770629331590',
                    121.42,
                    '770628803048',
                    585.21,
                    '770628802645',
                    12.38,
                    '770629271937',
                    10.07,
                    '770628804389',
                    74.1,
                    '770628802483',
                    62.38,
                    '770628802440',
                    44.15,
                    '770628804230',
                    55.62,
                    '770628804362',
                    51.1,
                    '770629441549',
                    239.12,
                    '770629331913',
                    8.25,
                    '770628805334',
                    27.04,
                    '770629439269',
                    122.02,
                    '770629678018',
                    121.19,
                    '770629441697',
                    238.79,
                    '770629332740',
                    159.53,
                    '770628802831',
                    122.88,
                    '770629678140',
                    186.74,
                    '770629680055',
                    189.21,
                    '770629332251',
                    331.74,
                    '770628804672',
                    241.68,
                    '770629333380',
                    148.29,
                    '770629331344',
                    75.37,
                    '770628805601',
                    495.81,
                    '770628803676',
                    38.4,
                    '770629333851',
                    73.96,
                    '770629268227',
                    2284.89,
                    '770629334041',
                    126.23,
                    '770629333827',
                    184.02,
                    '770629332847',
                    126.24,
                    '770629333010',
                    239.77,
                    '770628945403',
                    376.37,
                    '770629680438',
                    25.64,
                    '770628804745',
                    140.19,
                    '770629271880',
                    18.71,
                    '770629334289',
                    37.15) vl_corrigido,
             a.vlprodut as vlprodut_tbseg,
             c.vlpremio as vlpremio_crap,
             b.rowid as nr_linha_craw,
             b.vlpremio as vlpremio_craw
        from cecred.crapseg c, cecred.crawseg b, cecred.tbseg_prestamista a
       where c.cdsitseg = 1
         and c.tpseguro = 4
         and b.nrctrseg = c.nrctrseg
         and b.nrdconta = c.nrdconta
         and b.cdcooper = c.cdcooper
         and a.nrproposta = b.nrproposta
         and a.nrctrseg = b.nrctrseg
         and a.nrdconta = b.nrdconta
         and a.cdcooper = b.cdcooper
         and trim(a.tprecusa) is null
         and nvl(a.cdmotrec, 0) = 0
         and a.dtrecusa is null
         and a.nrproposta in ('770628945675',
                              '770629331379',
                              '770629333495',
                              '770628804257',
                              '770629679626',
                              '770629680535',
                              '770628945349',
                              '770629678913',
                              '770628805903',
                              '770629224092',
                              '770628803951',
                              '770628945900',
                              '770629331867',
                              '770629331883',
                              '770629333533',
                              '770628802629',
                              '770629332553',
                              '770629679758',
                              '770629331565',
                              '770629333282',
                              '770629680713',
                              '770629224335',
                              '770628803943',
                              '770629332677',
                              '770629271872',
                              '770629332979',
                              '770628804702',
                              '770628806004',
                              '770629002944',
                              '770629332928',
                              '770629441603',
                              '770629332952',
                              '770628803897',
                              '770629331921',
                              '770629331484',
                              '770629270183',
                              '770629271791',
                              '770629678042',
                              '770629224009',
                              '770628804508',
                              '770629270337',
                              '770629332421',
                              '770629333690',
                              '770629331220',
                              '770629331387',
                              '770629680306',
                              '770629679529',
                              '770628803080',
                              '770629441450',
                              '770629436863',
                              '770629332995',
                              '770629680497',
                              '770629439390',
                              '770628802610',
                              '770628805296',
                              '770628805431',
                              '770628802491',
                              '770629331751',
                              '770628945500',
                              '770629001638',
                              '770629332200',
                              '770629331433',
                              '770629271112',
                              '770629333452',
                              '770628803307',
                              '770629441417',
                              '770629331328',
                              '770628945888',
                              '770629680543',
                              '770629439463',
                              '770629331590',
                              '770628803048',
                              '770628802645',
                              '770629271937',
                              '770628804389',
                              '770628802483',
                              '770628802440',
                              '770628804230',
                              '770628804362',
                              '770629441549',
                              '770629331913',
                              '770628805334',
                              '770629439269',
                              '770629678018',
                              '770629441697',
                              '770629332740',
                              '770628802831',
                              '770629678140',
                              '770629680055',
                              '770629332251',
                              '770628804672',
                              '770629333380',
                              '770629331344',
                              '770628805601',
                              '770628803676',
                              '770629333851',
                              '770629268227',
                              '770629334041',
                              '770629333827',
                              '770629332847',
                              '770629333010',
                              '770628945403',
                              '770629680438',
                              '770628804745',
                              '770629271880',
                              '770629334289');
  
    procedure valida_diretorio_p(ds_nome_diretorio_p in varchar2,
                                 ds_critica_p        out cecred.crapcri.dscritic%TYPE) is
    
      ds_critica_v    cecred.crapcri.dscritic%type;
      ie_tipo_saida_v varchar2(3);
      ds_saida_v      varchar2(1000);
    
    begin
    
      if (cecred.gene0001.fn_exis_diretorio(ds_nome_diretorio_p)) then
      
        ds_critica_p := null;
      
      else
      
        cecred.gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' ||
                                                             ds_nome_diretorio_p ||
                                                             ' 1> /dev/null',
                                           pr_typ_saida   => ie_tipo_saida_v,
                                           pr_des_saida   => ds_saida_v);
      
        if (ie_tipo_saida_v = 'ERR') then
        
          ds_critica_v := 'CRIAR DIRETORIO ARQUIVO -> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                          ds_saida_v;
          raise ds_exc_erro_v;
        
        end if;
      
        cecred.gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' ||
                                                             ds_nome_diretorio_p ||
                                                             ' 1> /dev/null',
                                           pr_typ_saida   => ie_tipo_saida_v,
                                           pr_des_saida   => ds_saida_v);
      
        if (ie_tipo_saida_v = 'ERR') then
        
          ds_critica_v := 'PERMISSAO NO DIRETORIO -> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' ||
                          ds_saida_v;
          raise ds_exc_erro_v;
        
        end if;
      
      end if;
    
    exception
      when ds_exc_erro_v then
      
        ds_critica_p := ds_critica_v;
      
    end valida_diretorio_p;
  
  begin
  
    if (upper(cecred.gene0001.fn_database_name) like '%AYLLOSP%' or
       upper(gene0001.fn_database_name) like '%AILOSTS%') then
    
      select max(a.dsvlrprm)
        into ds_nome_diretorio_v
        from cecred.crapprm a
       where a.nmsistem = 'CRED'
         and a.cdcooper = cd_cooperativa_v
         and a.cdacesso = 'ROOT_MICROS';
    
      if (ds_nome_diretorio_v is null) then
      
        select max(a.dsvlrprm)
          into ds_nome_diretorio_v
          from cecred.crapprm a
         where a.nmsistem = 'CRED'
           and a.cdcooper = 0
           and a.cdacesso = 'ROOT_MICROS';
      
      end if;
    
      ds_nome_diretorio_v := ds_nome_diretorio_v || 'cpd/bacas/INC389193';
    
    else
    
      ds_nome_diretorio_v := cecred.gene0001.fn_diretorio(pr_tpdireto => 'C',
                                                          pr_cdcooper => 3);
    
      ds_nome_diretorio_v := ds_nome_diretorio_v || '/INC389193';
    
    end if;
  
    valida_diretorio_p(ds_nome_diretorio_p => ds_nome_diretorio_v,
                       ds_critica_p        => ds_critica_v);
  
    if (trim(ds_critica_v) is not null) then
    
      raise ds_exc_erro_v;
    
    end if;
  
    for r01 in c01 loop
    
      begin
      
        if (qt_reg_arquivo >= 50000) then
        
          qt_reg_arquivo := 0;
        
          dbms_lob.createtemporary(ds_dados_rollback_v,
                                   true,
                                   dbms_lob.CALL);
          dbms_lob.open(ds_dados_rollback_v, dbms_lob.lob_readwrite);
          cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                         ds_texto_rollback_v,
                                         'begin ' || chr(13) || chr(13),
                                         false);
          nm_arquivo_rollback_v := 'ROLLBACK_INC389193_' || nr_arquivo ||
                                   '.sql';
        
          nr_arquivo := nr_arquivo + 1;
        
        end if;
      
        qt_reg_commit  := qt_reg_commit + 1;
        qt_reg_arquivo := qt_reg_arquivo + 1;
      
        update cecred.tbseg_prestamista a
           set a.vlprodut = r01.vl_corrigido
         where a.rowid = r01.nr_linha_tbseg;
      
        cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                       ds_texto_rollback_v,
                                       'update cecred.tbseg_prestamista a ' ||
                                       chr(13) || 'set  a.vlprodut = ' ||
                                       replace(nvl(trim(to_char(r01.vlprodut_tbseg)),
                                                   'null'),
                                               ',',
                                               '.') || chr(13) ||
                                       'where  a.rowid = ' || chr(39) ||
                                       r01.nr_linha_tbseg || chr(39) || ';' ||
                                       chr(13) || chr(13),
                                       false);
      
        update cecred.crawseg a
           set a.vlpremio = r01.vl_corrigido
         where a.rowid = r01.nr_linha_craw;
      
        cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                       ds_texto_rollback_v,
                                       'update crawseg a ' || chr(13) ||
                                       'set  a.vlpremio = ' ||
                                       replace(nvl(trim(to_char(r01.vlpremio_craw)),
                                                   'null'),
                                               ',',
                                               '.') || chr(13) ||
                                       'where  a.rowid = ' || chr(39) ||
                                       r01.nr_linha_craw || chr(39) || ';' ||
                                       chr(13) || chr(13),
                                       false);
      
        update cecred.crapseg a
           set a.vlpremio = r01.vl_corrigido
         where a.rowid = r01.nr_linha_crap;
      
        cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                       ds_texto_rollback_v,
                                       'update crapseg a ' || chr(13) ||
                                       'set  a.vlpremio = ' ||
                                       replace(nvl(trim(to_char(r01.vlpremio_crap)),
                                                   'null'),
                                               ',',
                                               '.') || chr(13) ||
                                       'where  a.rowid = ' || chr(39) ||
                                       r01.nr_linha_crap || chr(39) || ';' ||
                                       chr(13) || chr(13),
                                       false);
      
        if (qt_reg_commit >= 5000) then
        
          cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                         ds_texto_rollback_v,
                                         'commit;' || chr(13) || chr(13),
                                         FALSE);
        
          commit;
        
          qt_reg_commit := 0;
        
        end if;
      
        if (qt_reg_arquivo >= 50000) then
        
          cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                         ds_texto_rollback_v,
                                         'end;' || chr(13),
                                         FALSE);
          cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                         ds_texto_rollback_v,
                                         chr(13),
                                         TRUE);
        
          cecred.gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => cd_cooperativa_v,
                                                     pr_cdprogra  => 'ATENDA',
                                                     pr_dtmvtolt  => trunc(sysdate),
                                                     pr_dsxml     => ds_dados_rollback_v,
                                                     pr_dsarqsaid => ds_nome_diretorio_v || '/' ||
                                                                     nm_arquivo_rollback_v,
                                                     pr_flg_impri => 'N',
                                                     pr_flg_gerar => 'S',
                                                     pr_flgremarq => 'N',
                                                     pr_nrcopias  => 1,
                                                     pr_des_erro  => ds_critica_rollback_v);
        
          if (trim(ds_critica_rollback_v) is not null) then
          
            raise ds_erro_registro_v;
          
          end if;
        
          dbms_lob.close(ds_dados_rollback_v);
          dbms_lob.freetemporary(ds_dados_rollback_v);
        
        end if;
      
      exception
        when ds_erro_registro_v then
        
          cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                         ds_texto_rollback_v,
                                         'LOG: falha mapeada ao atualizar registro:' ||
                                         chr(13) || 'Proposta: ' ||
                                         r01.nrproposta || chr(13) ||
                                         'Crítica: ' ||
                                         ds_critica_rollback_v || chr(13) ||
                                         chr(13),
                                         false);
        
        when others then
        
          rollback;
        
          cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                         ds_texto_rollback_v,
                                         'LOG: erro de sistema ao atualizar registro:' ||
                                         chr(13) || 'Proposta: ' ||
                                         r01.nrproposta || chr(13) ||
                                         'Erro: ' || sqlerrm || chr(13) ||
                                         chr(13),
                                         false);
        
          exit;
        
      end;
    
    end loop;
  
    if (qt_reg_arquivo <> 50000) then
    
      cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                     ds_texto_rollback_v,
                                     'commit;' || chr(13) || chr(13),
                                     FALSE);
      cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                     ds_texto_rollback_v,
                                     'end;' || chr(13),
                                     FALSE);
      cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                     ds_texto_rollback_v,
                                     chr(13),
                                     TRUE);
    
      cecred.gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => cd_cooperativa_v,
                                                 pr_cdprogra  => 'ATENDA',
                                                 pr_dtmvtolt  => trunc(sysdate),
                                                 pr_dsxml     => ds_dados_rollback_v,
                                                 pr_dsarqsaid => ds_nome_diretorio_v || '/' ||
                                                                 nm_arquivo_rollback_v,
                                                 pr_flg_impri => 'N',
                                                 pr_flg_gerar => 'S',
                                                 pr_flgremarq => 'N',
                                                 pr_nrcopias  => 1,
                                                 pr_des_erro  => ds_critica_v);
    
      if (trim(ds_critica_v) is not null) then
      
        raise ds_exc_erro_v;
      
      end if;
    
      dbms_lob.close(ds_dados_rollback_v);
      dbms_lob.freetemporary(ds_dados_rollback_v);
    
      commit;
    
    end if;
  
  exception
    when ds_exc_erro_v then
    
      rollback;
      raise_application_error(-20111, ds_critica_v);
    
  end;

end;
