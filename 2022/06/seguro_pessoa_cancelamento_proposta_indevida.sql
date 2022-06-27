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
      select p.cdcooper,
             p.nrdconta,
             p.nrctremp,
             p.nrctrseg,
             p.tpregist,
             p.nrproposta,
             p.rowid    as nr_linha_tbprest,
             s.cdsitseg,
             s.dtcancel,
             s.dtfimvig,
             s.rowid    as nr_linha_tbseg
        from cecred.tbseg_prestamista p, cecred.crapseg s
       where p.cdcooper = s.cdcooper
         and p.nrdconta = s.nrdconta
         and p.nrctrseg = s.nrctrseg
         and p.nrproposta in ('770349693674',
                              '770349866501',
                              '770350487905',
                              '770350563890',
                              '770351893516',
                              '770353906771',
                              '770356029186',
                              '770352641782',
                              '770359146086',
                              '770359316100',
                              '770359665369',
                              '770359957750',
                              '770356381343',
                              '770357499488',
                              '770355953653',
                              '770355062988',
                              '770356500440',
                              '770573776364',
                              '770355244431',
                              '770355466558',
                              '770355613445',
                              '770573108795',
                              '770355989321',
                              '770355228975',
                              '770355727084',
                              '770354610159',
                              '770355799352',
                              '770573500326',
                              '770572906230',
                              '770613023593',
                              '770573830091',
                              '770573476158',
                              '770612826820');
  
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
    
      ds_nome_diretorio_v := ds_nome_diretorio_v || 'cpd/bacas/INC377012';
    
    else
    
      ds_nome_diretorio_v := cecred.gene0001.fn_diretorio(pr_tpdireto => 'C',
                                                          pr_cdcooper => 3);
    
      ds_nome_diretorio_v := ds_nome_diretorio_v || '/INC377012';
    
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
          nm_arquivo_rollback_v := 'ROLLBACK_INC377012_' || nr_arquivo ||
                                   '.sql';
        
          nr_arquivo := nr_arquivo + 1;
        
        end if;
      
        qt_reg_commit  := qt_reg_commit + 1;
        qt_reg_arquivo := qt_reg_arquivo + 1;
      
        update cecred.tbseg_prestamista a
           set a.tpregist = 0
         where a.rowid = r01.nr_linha_tbprest;
      
        cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                       ds_texto_rollback_v,
                                       'update cecred.tbseg_prestamista a ' ||
                                       chr(13) || 'set  a.tpregist = ' ||
                                       r01.tpregist || chr(13) ||
                                       'where  a.rowid = ' || chr(39) ||
                                       r01.nr_linha_tbprest || chr(39) || ';' ||
                                       chr(13) || chr(13),
                                       false);
      
        update cecred.crapseg s
           set s.cdsitseg = 2,
               s.dtcancel = trunc(sysdate),
               s.dtfimvig = trunc(sysdate)
         where s.rowid = r01.nr_linha_tbseg;
      
        cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                       ds_texto_rollback_v,
                                       'update crapseg a ' || chr(13) ||
                                       'set  a.cdsitseg = ' || r01.cdsitseg ||
                                       chr(13) || ', a.dtcancel = to_date(' ||
                                       chr(39) ||
                                       trim(to_char(r01.dtcancel,
                                                    'dd/mm/yyyy')) ||
                                       chr(39) || ',' || chr(39) ||
                                       'dd/mm/yyyy' || chr(39) || ')' ||
                                       chr(13) || ', a.dtfimvig = to_date(' ||
                                       chr(39) ||
                                       trim(to_char(r01.dtfimvig,
                                                    'dd/mm/yyyy')) ||
                                       chr(39) || ',' || chr(39) ||
                                       'dd/mm/yyyy' || chr(39) || ')' ||
                                       chr(13) || 'where  a.rowid = ' ||
                                       chr(39) || r01.nr_linha_tbseg ||
                                       chr(39) || ';' || chr(13) || chr(13),
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