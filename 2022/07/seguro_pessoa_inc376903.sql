begin

  declare
  
    ds_exc_erro_v      exception;
    ds_erro_registro_v exception;
    cd_critica_v          cecred.crapcri.cdcritic%type;
    ds_critica_v          cecred.crapcri.dscritic%type;
    ds_critica_rollback_v cecred.crapcri.dscritic%type;
    ds_critica_arq_v      cecred.crapcri.dscritic%type;
  
    ds_dados_rollback_v   clob := null;
    ds_texto_rollback_v   varchar2(32600);
    nm_arquivo_rollback_v varchar2(100);
  
    cd_cooperativa_v    cecred.crapcop.cdcooper%type := 3;
    ds_nome_diretorio_v cecred.crapprm.dsvlrprm%type;
  
    qt_reg_commit  number(10) := 0;
    nr_arquivo     number(10) := 1;
    qt_reg_arquivo number(10) := 50000;
  
    vr_nrctrseg       cecred.crapseg.nrctrseg%type;
    vr_flgdps         varchar2(1) := 'N';
    vr_vlproposta     cecred.crawseg.vlseguro%type;
    vr_flgprestamista varchar2(1) := 'N';
    vr_dsmotcan       varchar2(60);
    vr_nrproposta     tbseg_prestamista.nrproposta%TYPE;
    vr_vlpretot       tbseg_prestamista.vlprodut%TYPE;
    vr_dtmvtolt       crapdat.dtmvtolt%type;
  
    qt_efetivado_v number(10);
  
    cursor c01 is
      select c.*,
             n.dhseguro,
             e.cdagenci,
             e.cdoperad,
             c.rowid nr_linha_crawseg
        from cecred.crawseg                 c,
             cecred.crapepr                 b,
             cecred.craplcr                 a,
             cecred.crawepr                 e,
             cecred.tbseg_nrproposta n
       where not exists (select 1
                from cecred.crapseg x
               where x.nrctrseg = c.nrctrseg
                 and x.nrdconta = b.nrdconta
                 and x.cdcooper = b.cdcooper)
         and c.flgassum = 1
         and b.nrdconta = c.nrdconta
         and b.nrctremp = c.nrctrato
         and b.cdcooper = c.cdcooper
         and a.cdlcremp = b.cdlcremp
         and a.cdcooper = b.cdcooper
         and c.cdcooper = e.cdcooper
         and c.nrdconta = e.nrdconta
         and c.nrctrato = e.nrctremp
         and c.nrproposta = n.nrproposta
         and a.tpcuspr = 0;
  
    cursor c03(pr_nrctrseg cecred.crapseg.nrctrseg%type,
               pr_cdcooper cecred.tbseg_prestamista.cdcooper%type,
               pr_nrdconta cecred.tbseg_prestamista.nrdconta%type) is
      select a.rowid nr_linha_crapseg
        from cecred.crapseg a
       where a.tpseguro = 4
         and a.nrdconta = pr_nrdconta
         and a.cdcooper = pr_cdcooper
         and a.nrctrseg = pr_nrctrseg;
  
    cursor c04(pr_nrctrseg cecred.crapseg.nrctrseg%type,
               pr_nrctremp cecred.tbseg_prestamista.nrctremp%type,
               pr_cdcooper cecred.tbseg_prestamista.cdcooper%type,
               pr_nrdconta cecred.tbseg_prestamista.nrdconta%type) is
      select a.rowid nr_linha_tbseg,
             a.cdcooper,
             a.nrdconta,
             a.nrctremp,
             a.nrproposta
        from cecred.tbseg_prestamista a
       where a.nrctrseg = pr_nrctrseg
         and a.nrdconta = pr_nrdconta
         and a.cdcooper = pr_cdcooper
         and a.nrctremp = pr_nrctremp;

    cursor c05(pr_cdseqtel cecred.craplau.cdseqtel%type,
               pr_nrctremp cecred.tbseg_prestamista.nrctremp%type,
               pr_cdcooper cecred.tbseg_prestamista.cdcooper%type,
               pr_nrdconta cecred.tbseg_prestamista.nrdconta%type) is
      select a.rowid nr_linha_lau
        from cecred.craplau a
       where a.cdhistor = 3651
         and a.cdseqtel = pr_cdseqtel
         and a.nrdconta = pr_nrdconta
         and a.cdcooper = pr_cdcooper
         and a.nrctremp = pr_nrctremp;
  
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
       upper(cecred.gene0001.fn_database_name) like '%AILOSTS%') then
    
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
    
      ds_nome_diretorio_v := ds_nome_diretorio_v || 'cpd/bacas/INC376903';
    
    else
    
      ds_nome_diretorio_v := cecred.gene0001.fn_diretorio(pr_tpdireto => 'C',
                                                          pr_cdcooper => 3);
    
      ds_nome_diretorio_v := ds_nome_diretorio_v || '/INC376903';
    
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
          gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                  ds_texto_rollback_v,
                                  'LOGS E ROLLBACK ' || chr(13) || chr(13),
                                  false);
          gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                  ds_texto_rollback_v,
                                  'begin ' || chr(13) || chr(13),
                                  false);
          nm_arquivo_rollback_v := 'ROLLBACK_INC376903_' || nr_arquivo ||
                                   '.sql';
        
          nr_arquivo := nr_arquivo + 1;
        
        end if;
      
        qt_reg_commit  := qt_reg_commit + 1;
        qt_reg_arquivo := qt_reg_arquivo + 1;
      
        cd_critica_v := null;
        ds_critica_v := null;
      
        vr_nrctrseg       := null;
        vr_flgdps         := 'N';
        vr_vlproposta     := null;
        vr_flgprestamista := 'N';
        vr_dsmotcan       := null;
           
        select count(*)
          into qt_efetivado_v
          from cecred.crapseg b, cecred.tbseg_prestamista a
         where b.cdsitseg = 1
           and a.cdcooper = b.cdcooper
           and a.nrdconta = b.nrdconta
           and a.nrctrseg = b.nrctrseg
           and a.tpregist in (1, 3)
           and a.cdcooper = r01.cdcooper
           and a.nrdconta = r01.nrdconta
           and a.nrctremp = r01.nrctrato
           and a.nrctrseg <> r01.nrctrseg;
      
        if (nvl(qt_efetivado_v, 0) = 0) then
        
          cecred.SEGU0003.pc_validar_prestamista(pr_cdcooper        => r01.cdcooper,
                                                 pr_nrdconta        => r01.nrdconta,
                                                 pr_nrctremp        => r01.nrctrato,
                                                 pr_cdagenci        => r01.cdagenci,
                                                 pr_nrdcaixa        => 0,
                                                 pr_cdoperad        => r01.cdoperad,
                                                 pr_nmdatela        => 'SEGURO',
                                                 pr_idorigem        => 1,
                                                 pr_valida_proposta => 'N',
                                                 pr_sld_devedor     => vr_vlproposta,
                                                 pr_flgprestamista  => vr_flgprestamista,
                                                 pr_flgdps          => vr_flgdps,
                                                 pr_dsmotcan        => vr_dsmotcan,
                                                 pr_cdcritic        => cd_critica_v,
                                                 pr_dscritic        => ds_critica_v);
        
        end if;
      
        if (trim(ds_critica_v) is null) then
        
          if (nvl(vr_flgprestamista, 'N') = 'N') or
             (nvl(qt_efetivado_v, 0) > 0) then
          
            delete from cecred.crawseg a
             where a.rowid = r01.nr_linha_crawseg;
          
            update cecred.tbseg_nrproposta a
               set a.dhseguro = null
             where a.nrproposta = r01.nrproposta;
          
            gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                    ds_texto_rollback_v,
                                    'update cecred.tbseg_nrproposta a ' ||
                                    chr(13) ||
                                    'set  a.dhseguro  = to_date(' ||
                                    chr(39) ||
                                    trim(to_char(r01.dhseguro, 'dd/mm/yyyy')) ||
                                    chr(39) || ',' || chr(39) ||
                                    'dd/mm/yyyy' || chr(39) || ') ' ||
                                    chr(13) || 'where  a.nrproposta  = ' ||
                                    chr(39) || r01.nrproposta || chr(39) || ';' ||
                                    chr(13) || chr(13),
                                    false);
          
            cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                           ds_texto_rollback_v,
                                           'insert into cecred.crawseg ' ||
                                           ' (dtmvtolt, ' || ' nrdconta, ' ||
                                           ' nrctrseg, ' || ' tpseguro, ' ||
                                           ' nmdsegur, ' || ' tpplaseg, ' ||
                                           ' nmbenefi, ' || ' nrcadast, ' ||
                                           ' nmdsecao, ' || ' dsendres, ' ||
                                           ' nrendres, ' || ' nmbairro, ' ||
                                           ' nmcidade, ' || ' cdufresd, ' ||
                                           ' nrcepend, ' || ' dtinivig, ' ||
                                           ' dtfimvig, ' || ' dsmarvei, ' ||
                                           ' dstipvei, ' || ' nranovei, ' ||
                                           ' nrmodvei, ' || ' qtpasvei, ' ||
                                           ' ppdbonus, ' || ' flgdnovo, ' ||
                                           ' nrapoant, ' || ' nmsegant, ' ||
                                           ' flgdutil, ' || ' flgnotaf, ' ||
                                           ' flgapant, ' || ' vlpreseg, ' ||
                                           ' vlseguro, ' || ' vldfranq, ' ||
                                           ' vldcasco, ' || ' vlverbae, ' ||
                                           ' flgassis, ' || ' vldanmat, ' ||
                                           ' vldanpes, ' || ' vldanmor, ' ||
                                           ' vlappmor, ' || ' vlappinv, ' ||
                                           ' cdsegura, ' || ' nmempres, ' ||
                                           ' dschassi, ' || ' flgrenov, ' ||
                                           ' dtdebito, ' || ' vlbenefi, ' ||
                                           ' cdcalcul, ' || ' flgcurso, ' ||
                                           ' dtiniseg, ' || ' nrdplaca, ' ||
                                           ' lsctrant, ' || ' nrcpfcgc, ' ||
                                           ' nrctratu, ' || ' nmcpveic, ' ||
                                           ' flgunica, ' || ' nrctrato, ' ||
                                           ' flgvisto, ' || ' cdapoant, ' ||
                                           ' dtprideb, ' || ' vldifseg, ' ||
                                           ' dscobext##1, ' ||
                                           ' dscobext##2, ' ||
                                           ' dscobext##3, ' ||
                                           ' dscobext##4, ' ||
                                           ' dscobext##5, ' ||
                                           ' vlcobext##1, ' ||
                                           ' vlcobext##2, ' ||
                                           ' vlcobext##3, ' ||
                                           ' vlcobext##4, ' ||
                                           ' vlcobext##5, ' ||
                                           ' flgrepgr, ' || ' vlfrqobr, ' ||
                                           ' tpsegvid, ' || ' dtnascsg, ' ||
                                           ' cdsexosg, ' || ' vlpremio, ' ||
                                           ' qtparcel, ' || ' nrfonemp, ' ||
                                           ' nrfonres, ' || ' dsoutgar, ' ||
                                           ' vloutgar, ' || ' tpdpagto, ' ||
                                           ' cdcooper, ' || ' flgconve, ' ||
                                           ' complend, ' ||
                                           ' progress_recid, ' ||
                                           ' nrproposta, ' || ' flggarad, ' ||
                                           ' flgassum, ' || ' tpcustei, ' ||
                                           ' tpmodali) ' || chr(13) ||
                                           'values (' || 'to_date(' ||
                                           chr(39) ||
                                           trim(to_char(r01.dtmvtolt,
                                                        'dd/mm/yyyy')) ||
                                           chr(39) || ',' || chr(39) ||
                                           'dd/mm/yyyy' || chr(39) || '), ' ||
                                           replace(nvl(trim(to_char(r01.nrdconta)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.nrctrseg)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.tpseguro)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' || chr(39) ||
                                           r01.nmdsegur || chr(39) || ', ' ||
                                           replace(nvl(trim(to_char(r01.tpplaseg)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' || chr(39) ||
                                           r01.nmbenefi || chr(39) || ', ' ||
                                           replace(nvl(trim(to_char(r01.nrcadast)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' || chr(39) ||
                                           r01.nmdsecao || chr(39) || ', ' ||
                                           chr(39) || r01.dsendres ||
                                           chr(39) || ', ' ||
                                           replace(nvl(trim(to_char(r01.nrendres)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' || chr(39) ||
                                           r01.nmbairro || chr(39) || ', ' ||
                                           chr(39) || r01.nmcidade ||
                                           chr(39) || ', ' || chr(39) ||
                                           r01.cdufresd || chr(39) || ', ' ||
                                           replace(nvl(trim(to_char(r01.nrcepend)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           'to_date(' || chr(39) ||
                                           trim(to_char(r01.dtinivig,
                                                        'dd/mm/yyyy')) ||
                                           chr(39) || ',' || chr(39) ||
                                           'dd/mm/yyyy' || chr(39) || '), ' ||
                                           'to_date(' || chr(39) ||
                                           trim(to_char(r01.dtfimvig,
                                                        'dd/mm/yyyy')) ||
                                           chr(39) || ',' || chr(39) ||
                                           'dd/mm/yyyy' || chr(39) || '), ' ||
                                           chr(39) || r01.dsmarvei ||
                                           chr(39) || ', ' || chr(39) ||
                                           r01.dstipvei || chr(39) || ', ' ||
                                           replace(nvl(trim(to_char(r01.nranovei)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.nrmodvei)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.qtpasvei)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.ppdbonus)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.flgdnovo)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.nrapoant)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' || chr(39) ||
                                           r01.nmsegant || chr(39) || ', ' ||
                                           replace(nvl(trim(to_char(r01.flgdutil)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.flgnotaf)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.flgapant)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.vlpreseg)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.vlseguro)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.vldfranq)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.vldcasco)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.vlverbae)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.flgassis)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.vldanmat)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.vldanpes)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.vldanmor)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.vlappmor)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.vlappinv)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.cdsegura)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' || chr(39) ||
                                           r01.nmempres || chr(39) || ', ' ||
                                           chr(39) || r01.dschassi ||
                                           chr(39) || ', ' ||
                                           replace(nvl(trim(to_char(r01.flgrenov)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           'to_date(' || chr(39) ||
                                           trim(to_char(r01.dtdebito,
                                                        'dd/mm/yyyy')) ||
                                           chr(39) || ',' || chr(39) ||
                                           'dd/mm/yyyy' || chr(39) || '), ' ||
                                           replace(nvl(trim(to_char(r01.vlbenefi)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.cdcalcul)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.flgcurso)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           'to_date(' || chr(39) ||
                                           trim(to_char(r01.dtiniseg,
                                                        'dd/mm/yyyy')) ||
                                           chr(39) || ',' || chr(39) ||
                                           'dd/mm/yyyy' || chr(39) || '), ' ||
                                           chr(39) || r01.nrdplaca ||
                                           chr(39) || ', ' || chr(39) ||
                                           r01.lsctrant || chr(39) || ', ' ||
                                           chr(39) || r01.nrcpfcgc ||
                                           chr(39) || ', ' ||
                                           replace(nvl(trim(to_char(r01.nrctrato)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' || chr(39) ||
                                           r01.nmcpveic || chr(39) || ', ' ||
                                           replace(nvl(trim(to_char(r01.flgunica)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.nrctrato)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.flgvisto)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' || chr(39) ||
                                           r01.cdapoant || chr(39) || ', ' ||
                                           'to_date(' || chr(39) ||
                                           trim(to_char(r01.dtprideb,
                                                        'dd/mm/yyyy')) ||
                                           chr(39) || ',' || chr(39) ||
                                           'dd/mm/yyyy' || chr(39) || '), ' ||
                                           replace(nvl(trim(to_char(r01.vldifseg)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' || chr(39) ||
                                           r01.dscobext##1 || chr(39) || ', ' ||
                                           chr(39) || r01.dscobext##2 ||
                                           chr(39) || ', ' || chr(39) ||
                                           r01.dscobext##3 || chr(39) || ', ' ||
                                           chr(39) || r01.dscobext##4 ||
                                           chr(39) || ', ' || chr(39) ||
                                           r01.dscobext##5 || chr(39) || ', ' ||
                                           replace(nvl(trim(to_char(r01.vlcobext##1)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.vlcobext##2)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.vlcobext##3)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.vlcobext##4)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.vlcobext##5)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.flgrepgr)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.vlfrqobr)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.tpsegvid)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           'to_date(' || chr(39) ||
                                           trim(to_char(r01.dtnascsg,
                                                        'dd/mm/yyyy')) ||
                                           chr(39) || ',' || chr(39) ||
                                           'dd/mm/yyyy' || chr(39) || '), ' ||
                                           replace(nvl(trim(to_char(r01.cdsexosg)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.vlpremio)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.qtparcel)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' || chr(39) ||
                                           r01.nrfonemp || chr(39) || ', ' ||
                                           chr(39) || r01.nrfonres ||
                                           chr(39) || ', ' || chr(39) ||
                                           r01.dsoutgar || chr(39) || ', ' ||
                                           replace(nvl(trim(to_char(r01.vloutgar)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.tpdpagto)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.cdcooper)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.flgconve)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' || chr(39) ||
                                           r01.complend || chr(39) || ', ' ||
                                           replace(nvl(trim(to_char(r01.progress_recid)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.nrproposta)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.flggarad)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.flgassum)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.tpcustei)),
                                                       'null'),
                                                   ',',
                                                   '.') || ', ' ||
                                           replace(nvl(trim(to_char(r01.tpmodali)),
                                                       'null'),
                                                   ',',
                                                   '.') || ');' || chr(13) ||
                                           chr(13),
                                           false);
          
          else
          
            cecred.segu0001.pc_efetiva_proposta_seguro_p(pr_cdcooper => r01.cdcooper,
                                                         pr_nrdconta => r01.nrdconta,
                                                         pr_nrctrato => r01.nrctrato,
                                                         pr_cdoperad => '1',
                                                         pr_cdagenci => 1,
                                                         pr_vlslddev => vr_vlproposta,
                                                         pr_idimpdps => vr_flgdps,
                                                         pr_nrctrseg => vr_nrctrseg,
                                                         pr_cdcritic => cd_critica_v,
                                                         pr_dscritic => ds_critica_v);
          
            if (trim(ds_critica_v) is null) then
            
        	segu0003.pc_cria_seguro_prest_contributario(pr_cdcooper   => r01.cdcooper,
                                          pr_nrdconta   => r01.nrdconta,
                                          pr_nrctrseg   => vr_nrctrseg,
                                          pr_nrctremp   => r01.nrctrato,
                                          pr_vlpretot   => vr_vlpretot,
                                          pr_nrproposta => vr_nrproposta,
                                          pr_cdcritic   => cd_critica_v,
                                          pr_dscritic   => ds_critica_v);
                                          
        	if	(trim(ds_critica_v) is null) then

			select	max(a.dtmvtolt)
			into	vr_dtmvtolt
			from	crapdat a
			where	a.cdcooper	= r01.cdcooper;
        
        		SEGU0001.pc_agenda_pgto_prest_contrib(pr_dtmvtolt   => vr_dtmvtolt,
                                              pr_cdcooper   => r01.cdcooper,
                                              pr_cdhistor   => 3651,
                                              pr_nrdconta   => r01.nrdconta,
                                              pr_nrctremp   => r01.nrctrato,
                                              pr_nrproposta => vr_nrproposta,
                                              pr_vlslddev   => vr_vlpretot,
                                              pr_cdcritic   => cd_critica_v,
                                              pr_dscritic   => ds_critica_v);

            
              		if (trim(ds_critica_v) is null) then
              
                		commit;
              
              		end if;
            
            	end if;

	    end if;
          
            for r03 in c03(pr_nrctrseg => vr_nrctrseg,
                           pr_cdcooper => r01.cdcooper,
                           pr_nrdconta => r01.nrdconta) loop
            
              if (trim(ds_critica_v) is not null) then
              
                delete from cecred.crapseg a
                 where a.rowid = r03.nr_linha_crapseg;
              
              else
              
                cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                               ds_texto_rollback_v,
                                               'delete from cecred.crapseg a ' ||
                                               chr(13) ||
                                               'where  a.rowid = ' ||
                                               chr(39) ||
                                               r03.nr_linha_crapseg ||
                                               chr(39) || ';' || chr(13) ||
                                               chr(13),
                                               false);
              
              end if;
            
            end loop;
          
            for r04 in c04(pr_nrctrseg => vr_nrctrseg,
                           pr_nrctremp => r01.nrctrato,
                           pr_cdcooper => r01.cdcooper,
                           pr_nrdconta => r01.nrdconta) loop
            
              if (trim(ds_critica_v) is not null) then
              
                delete from cecred.tbseg_prestamista a
                 where a.rowid = r04.nr_linha_tbseg;
              
              else
              
                cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                               ds_texto_rollback_v,
                                               'delete from cecred.tbseg_prestamista a ' ||
                                               chr(13) ||
                                               'where  a.rowid = ' ||
                                               chr(39) ||
                                               r04.nr_linha_tbseg ||
                                               chr(39) || ';' || chr(13) ||
                                               chr(13),
                                               false);

              end if;

	      for r05 in c05(pr_cdseqtel => r04.nrproposta,
                           pr_nrctremp => r04.nrctremp,
                           pr_cdcooper => r04.cdcooper,
                           pr_nrdconta => r04.nrdconta) loop

                if (trim(ds_critica_v) is not null) then

                  delete from cecred.craplau a
                  where a.rowid = r05.nr_linha_lau;

                else

                  cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                               ds_texto_rollback_v,
                                               'delete from cecred.craplau a ' ||
                                               chr(13) ||
                                               'where  a.rowid = ' ||
                                               chr(39) ||
                                               r05.nr_linha_lau ||
                                               chr(39) || ';' || chr(13) ||
                                               chr(13),
                                               false);

                end if;

	      end loop;
            
            end loop;
          
          end if;
        
          if (qt_reg_commit >= 1000) then
          
            cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                           ds_texto_rollback_v,
                                           'commit;' || chr(13) || chr(13),
                                           FALSE);
          
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
        
        end if;
      
        if (trim(ds_critica_v) is not null) then
        
          raise ds_erro_registro_v;
        
        end if;
      
      exception
        when ds_erro_registro_v then
        
          cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                         ds_texto_rollback_v,
                                         'LOG: falha mapeada ao atualizar registro:' ||
                                         chr(13) || 'Proposta: ' ||
                                         r01.nrproposta || chr(13) ||
                                         'Crítica: ' || ds_critica_v ||
                                         chr(13) || chr(13),
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
  
    if (ds_critica_arq_v is not null) then
    
      ds_critica_v := ds_critica_arq_v;
      raise ds_exc_erro_v;
    
    end if;
  
  exception
    when ds_exc_erro_v then
    
      rollback;
      raise_application_error(-20111, ds_critica_v);
    
  end;

end;
