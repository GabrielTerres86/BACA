begin

declare

ds_exc_erro_v   exception;
ds_dados_rollback_v clob      := null;
ds_texto_rollback_v varchar2(32600);

cd_cooperativa_v  cecred.crapcop.cdcooper%type  := 3;
ds_nome_arquivo_bkp_v varchar2(100);
ds_nome_diretorio_v cecred.crapprm.dsvlrprm%type;
ds_critica_v    cecred.crapcri.dscritic%type;

qt_registro number(10)  := 0;
nr_arquivo  number(10)  := 1;
qt_reg_arquivo  number(10)  := 50000;

vr_dscritic VARCHAR2(1000);

cursor  c01 is
select w.tpcustei tpcusteio, w.vlseguro vlrseguro, w.vlpremio vlrpremio, 
       p.cdcooper cdcoopertbseg, p.nrdconta nrdcontatbseg, p.nrctrseg nrctrsegtbseg, p.dtinivig dtinivigtbseg, p.dtfimvig dtfimvigtbseg, p.qtparcel qtparceltbseg,
       idseqtra, p.nrctremp nrctremptbseg,tpregist,cdapolic,p.nrcpfcgc,nmprimtl, dtnasctl,cdsexotl,p.dsendres,dsdemail,p.nmbairro,p.nmcidade,p.cdufresd,p.nrcepend,nrtelefo,dtdevend,cdcobran,cdadmcob,tpfrecob,tpsegura,cdprodut,cdplapro,vlprodut,tpcobran,vlsdeved,vldevatu,dtrefcob,dtdenvio,p.nrproposta,tprecusa,cdmotrec,dtrecusa,situacao,p.tpcustei,pemorte,peinvalidez,peiftttaxa,qtifttdias,nrapolice,vlpielimit,vlifttlimi,dsprotocolo,p.flfinanciasegprestamista,
       s.dtmvtolt,cdagenci,cdbccxlt,cdsitseg,dtaltseg,dtcancel,s.dtdebito,s.dtiniseg,indebito,nrdolote,nrseqdig,qtprepag,vlprepag,s.vlpreseg,dtultpag,s.tpseguro,s.tpplaseg,qtprevig,s.cdsegura,s.lsctrant,s.nrctratu,s.flgunica,s.dtprideb,s.vldifseg,nmbenvid##1,nmbenvid##2,nmbenvid##3,nmbenvid##4,nmbenvid##5,dsgraupr##1,dsgraupr##2,dsgraupr##3,dsgraupr##4,dsgraupr##5,txpartic##1,txpartic##2,txpartic##3,txpartic##4,txpartic##5,dtultalt,cdoperad,s.vlpremio,s.tpdpagto,s.flgconve,flgclabe,cdmotcan, tpendcor, s.progress_recid, cdopecnl,dtrenova,cdopeori,cdageori,dtinsori,cdopeexc,cdageexc,dtinsexc,vlslddev,idimpdps,
       p.cdcooper cdcoopercrap, p.nrdconta nrdcontacrap, p.nrctrseg nrctrsegcrap, p.dtinivig dtinivigcrap, p.dtfimvig dtfimvigcrap, p.qtparcel qtparcelcrap
  from cecred.crawseg w,
       cecred.tbseg_prestamista p,
       cecred.crapseg s
 where w.cdcooper = 13
   and w.nrdconta = 577022
   and w.cdcooper = p.cdcooper
   and w.nrdconta = p.nrdconta
   and w.nrctrseg = p.nrctrseg
   and w.cdcooper = s.cdcooper
   and w.nrdconta = s.nrdconta
   and w.nrctrseg = s.nrctrseg
   and w.nrctrato = 229872
   and w.nrctrseg = 382324
union all
select w.tpcustei tpcusteio, w.vlseguro vlrseguro, w.vlpremio vlrpremio, 
       p.cdcooper cdcoopertbseg, p.nrdconta nrdcontatbseg, p.nrctrseg nrctrsegtbseg, p.dtinivig dtinivigtbseg, p.dtfimvig dtfimvigtbseg, p.qtparcel qtparceltbseg,
       idseqtra, p.nrctremp nrctremptbseg,tpregist,cdapolic,p.nrcpfcgc,nmprimtl, dtnasctl,cdsexotl,p.dsendres,dsdemail,p.nmbairro,p.nmcidade,p.cdufresd,p.nrcepend,nrtelefo,dtdevend,cdcobran,cdadmcob,tpfrecob,tpsegura,cdprodut,cdplapro,vlprodut,tpcobran,vlsdeved,vldevatu,dtrefcob,dtdenvio,p.nrproposta,tprecusa,cdmotrec,dtrecusa,situacao,p.tpcustei,pemorte,peinvalidez,peiftttaxa,qtifttdias,nrapolice,vlpielimit,vlifttlimi,dsprotocolo,p.flfinanciasegprestamista,
       s.dtmvtolt,cdagenci,cdbccxlt,cdsitseg,dtaltseg,dtcancel,s.dtdebito,s.dtiniseg,indebito,nrdolote,nrseqdig,qtprepag,vlprepag,s.vlpreseg,dtultpag,s.tpseguro,s.tpplaseg,qtprevig,s.cdsegura,s.lsctrant,s.nrctratu,s.flgunica,s.dtprideb,s.vldifseg,nmbenvid##1,nmbenvid##2,nmbenvid##3,nmbenvid##4,nmbenvid##5,dsgraupr##1,dsgraupr##2,dsgraupr##3,dsgraupr##4,dsgraupr##5,txpartic##1,txpartic##2,txpartic##3,txpartic##4,txpartic##5,dtultalt,cdoperad,s.vlpremio,s.tpdpagto,s.flgconve,flgclabe,cdmotcan, tpendcor, s.progress_recid, cdopecnl,dtrenova,cdopeori,cdageori,dtinsori,cdopeexc,cdageexc,dtinsexc,vlslddev,idimpdps,
       p.cdcooper cdcoopercrap, p.nrdconta nrdcontacrap, p.nrctrseg nrctrsegcrap, p.dtinivig dtinivigcrap, p.dtfimvig dtfimvigcrap, p.qtparcel qtparcelcrap
  from cecred.crawseg w,
       cecred.tbseg_prestamista p,
       cecred.crapseg s
 where w.cdcooper = 13
   and w.nrdconta = 15375552
   and w.cdcooper = p.cdcooper
   and w.nrdconta = p.nrdconta
   and w.nrctrseg = p.nrctrseg 
   and w.cdcooper = s.cdcooper
   and w.nrdconta = s.nrdconta
   and w.nrctrseg = s.nrctrseg
   and w.nrctrato = 229873
   and w.nrctrseg = 382267
union all
select w.tpcustei tpcusteio, w.vlseguro vlrseguro, w.vlpremio vlrpremio, 
       p.cdcooper cdcoopertbseg, p.nrdconta nrdcontatbseg, p.nrctrseg nrctrsegtbseg, p.dtinivig dtinivigtbseg, p.dtfimvig dtfimvigtbseg, p.qtparcel qtparceltbseg,
       idseqtra, p.nrctremp nrctremptbseg,tpregist,cdapolic,p.nrcpfcgc,nmprimtl, dtnasctl,cdsexotl,p.dsendres,dsdemail,p.nmbairro,p.nmcidade,p.cdufresd,p.nrcepend,nrtelefo,dtdevend,cdcobran,cdadmcob,tpfrecob,tpsegura,cdprodut,cdplapro,vlprodut,tpcobran,vlsdeved,vldevatu,dtrefcob,dtdenvio,p.nrproposta,tprecusa,cdmotrec,dtrecusa,situacao,p.tpcustei,pemorte,peinvalidez,peiftttaxa,qtifttdias,nrapolice,vlpielimit,vlifttlimi,dsprotocolo,p.flfinanciasegprestamista,
       s.dtmvtolt,cdagenci,cdbccxlt,cdsitseg,dtaltseg,dtcancel,s.dtdebito,s.dtiniseg,indebito,nrdolote,nrseqdig,qtprepag,vlprepag,s.vlpreseg,dtultpag,s.tpseguro,s.tpplaseg,qtprevig,s.cdsegura,s.lsctrant,s.nrctratu,s.flgunica,s.dtprideb,s.vldifseg,nmbenvid##1,nmbenvid##2,nmbenvid##3,nmbenvid##4,nmbenvid##5,dsgraupr##1,dsgraupr##2,dsgraupr##3,dsgraupr##4,dsgraupr##5,txpartic##1,txpartic##2,txpartic##3,txpartic##4,txpartic##5,dtultalt,cdoperad,s.vlpremio,s.tpdpagto,s.flgconve,flgclabe,cdmotcan, tpendcor, s.progress_recid, cdopecnl,dtrenova,cdopeori,cdageori,dtinsori,cdopeexc,cdageexc,dtinsexc,vlslddev,idimpdps,
       p.cdcooper cdcoopercrap, p.nrdconta nrdcontacrap, p.nrctrseg nrctrsegcrap, p.dtinivig dtinivigcrap, p.dtfimvig dtfimvigcrap, p.qtparcel qtparcelcrap
  from cecred.crawseg w,
       cecred.tbseg_prestamista p,
       cecred.crapseg s
 where w.cdcooper = 13
   and w.nrdconta = 236969
   and w.cdcooper = p.cdcooper
   and w.nrdconta = p.nrdconta
   and w.nrctrseg = p.nrctrseg 
   and w.cdcooper = s.cdcooper
   and w.nrdconta = s.nrdconta
   and w.nrctrseg = s.nrctrseg
   and w.nrctrato = 229708
   and w.nrctrseg = 382565   
union all
select w.tpcustei tpcusteio, w.vlseguro vlrseguro, w.vlpremio vlrpremio, 
       p.cdcooper cdcoopertbseg, p.nrdconta nrdcontatbseg, p.nrctrseg nrctrsegtbseg, p.dtinivig dtinivigtbseg, p.dtfimvig dtfimvigtbseg, p.qtparcel qtparceltbseg,
       idseqtra, p.nrctremp nrctremptbseg,tpregist,cdapolic,p.nrcpfcgc,nmprimtl, dtnasctl,cdsexotl,p.dsendres,dsdemail,p.nmbairro,p.nmcidade,p.cdufresd,p.nrcepend,nrtelefo,dtdevend,cdcobran,cdadmcob,tpfrecob,tpsegura,cdprodut,cdplapro,vlprodut,tpcobran,vlsdeved,vldevatu,dtrefcob,dtdenvio,p.nrproposta,tprecusa,cdmotrec,dtrecusa,situacao,p.tpcustei,pemorte,peinvalidez,peiftttaxa,qtifttdias,nrapolice,vlpielimit,vlifttlimi,dsprotocolo,p.flfinanciasegprestamista,
       s.dtmvtolt,cdagenci,cdbccxlt,cdsitseg,dtaltseg,dtcancel,s.dtdebito,s.dtiniseg,indebito,nrdolote,nrseqdig,qtprepag,vlprepag,s.vlpreseg,dtultpag,s.tpseguro,s.tpplaseg,qtprevig,s.cdsegura,s.lsctrant,s.nrctratu,s.flgunica,s.dtprideb,s.vldifseg,nmbenvid##1,nmbenvid##2,nmbenvid##3,nmbenvid##4,nmbenvid##5,dsgraupr##1,dsgraupr##2,dsgraupr##3,dsgraupr##4,dsgraupr##5,txpartic##1,txpartic##2,txpartic##3,txpartic##4,txpartic##5,dtultalt,cdoperad,s.vlpremio,s.tpdpagto,s.flgconve,flgclabe,cdmotcan, tpendcor, s.progress_recid, cdopecnl,dtrenova,cdopeori,cdageori,dtinsori,cdopeexc,cdageexc,dtinsexc,vlslddev,idimpdps,
       p.cdcooper cdcoopercrap, p.nrdconta nrdcontacrap, p.nrctrseg nrctrsegcrap, p.dtinivig dtinivigcrap, p.dtfimvig dtfimvigcrap, p.qtparcel qtparcelcrap
  from cecred.crawseg w,
       cecred.tbseg_prestamista p,
       cecred.crapseg s
 where w.cdcooper = 13
   and w.nrdconta = 556661
   and w.cdcooper = p.cdcooper
   and w.nrdconta = p.nrdconta
   and w.nrctrseg = p.nrctrseg 
   and w.cdcooper = s.cdcooper
   and w.nrdconta = s.nrdconta
   and w.nrctrseg = s.nrctrseg
   and w.nrctrato = 229994
   and w.nrctrseg = 382587
union all
select w.tpcustei tpcusteio, w.vlseguro vlrseguro, w.vlpremio vlrpremio, 
       p.cdcooper cdcoopertbseg, p.nrdconta nrdcontatbseg, p.nrctrseg nrctrsegtbseg, p.dtinivig dtinivigtbseg, p.dtfimvig dtfimvigtbseg, p.qtparcel qtparceltbseg,
       idseqtra, p.nrctremp nrctremptbseg,tpregist,cdapolic,p.nrcpfcgc,nmprimtl, dtnasctl,cdsexotl,p.dsendres,dsdemail,p.nmbairro,p.nmcidade,p.cdufresd,p.nrcepend,nrtelefo,dtdevend,cdcobran,cdadmcob,tpfrecob,tpsegura,cdprodut,cdplapro,vlprodut,tpcobran,vlsdeved,vldevatu,dtrefcob,dtdenvio,p.nrproposta,tprecusa,cdmotrec,dtrecusa,situacao,p.tpcustei,pemorte,peinvalidez,peiftttaxa,qtifttdias,nrapolice,vlpielimit,vlifttlimi,dsprotocolo,p.flfinanciasegprestamista,
       s.dtmvtolt,cdagenci,cdbccxlt,cdsitseg,dtaltseg,dtcancel,s.dtdebito,s.dtiniseg,indebito,nrdolote,nrseqdig,qtprepag,vlprepag,s.vlpreseg,dtultpag,s.tpseguro,s.tpplaseg,qtprevig,s.cdsegura,s.lsctrant,s.nrctratu,s.flgunica,s.dtprideb,s.vldifseg,nmbenvid##1,nmbenvid##2,nmbenvid##3,nmbenvid##4,nmbenvid##5,dsgraupr##1,dsgraupr##2,dsgraupr##3,dsgraupr##4,dsgraupr##5,txpartic##1,txpartic##2,txpartic##3,txpartic##4,txpartic##5,dtultalt,cdoperad,s.vlpremio,s.tpdpagto,s.flgconve,flgclabe,cdmotcan, tpendcor, s.progress_recid, cdopecnl,dtrenova,cdopeori,cdageori,dtinsori,cdopeexc,cdageexc,dtinsexc,vlslddev,idimpdps,
       p.cdcooper cdcoopercrap, p.nrdconta nrdcontacrap, p.nrctrseg nrctrsegcrap, p.dtinivig dtinivigcrap, p.dtfimvig dtfimvigcrap, p.qtparcel qtparcelcrap
  from cecred.crawseg w,
       cecred.tbseg_prestamista p,
       cecred.crapseg s
 where w.cdcooper = 13
   and w.nrdconta = 745260
   and w.cdcooper = p.cdcooper
   and w.nrdconta = p.nrdconta
   and w.nrctrseg = p.nrctrseg 
   and w.cdcooper = s.cdcooper
   and w.nrdconta = s.nrdconta
   and w.nrctrseg = s.nrctrseg
   and w.nrctrato = 229973
   and w.nrctrseg = 382477   
union all
select w.tpcustei tpcusteio, w.vlseguro vlrseguro, w.vlpremio vlrpremio, 
       p.cdcooper cdcoopertbseg, p.nrdconta nrdcontatbseg, p.nrctrseg nrctrsegtbseg, p.dtinivig dtinivigtbseg, p.dtfimvig dtfimvigtbseg, p.qtparcel qtparceltbseg,
       idseqtra, p.nrctremp nrctremptbseg,tpregist,cdapolic,p.nrcpfcgc,nmprimtl, dtnasctl,cdsexotl,p.dsendres,dsdemail,p.nmbairro,p.nmcidade,p.cdufresd,p.nrcepend,nrtelefo,dtdevend,cdcobran,cdadmcob,tpfrecob,tpsegura,cdprodut,cdplapro,vlprodut,tpcobran,vlsdeved,vldevatu,dtrefcob,dtdenvio,p.nrproposta,tprecusa,cdmotrec,dtrecusa,situacao,p.tpcustei,pemorte,peinvalidez,peiftttaxa,qtifttdias,nrapolice,vlpielimit,vlifttlimi,dsprotocolo,p.flfinanciasegprestamista,
       s.dtmvtolt,cdagenci,cdbccxlt,cdsitseg,dtaltseg,dtcancel,s.dtdebito,s.dtiniseg,indebito,nrdolote,nrseqdig,qtprepag,vlprepag,s.vlpreseg,dtultpag,s.tpseguro,s.tpplaseg,qtprevig,s.cdsegura,s.lsctrant,s.nrctratu,s.flgunica,s.dtprideb,s.vldifseg,nmbenvid##1,nmbenvid##2,nmbenvid##3,nmbenvid##4,nmbenvid##5,dsgraupr##1,dsgraupr##2,dsgraupr##3,dsgraupr##4,dsgraupr##5,txpartic##1,txpartic##2,txpartic##3,txpartic##4,txpartic##5,dtultalt,cdoperad,s.vlpremio,s.tpdpagto,s.flgconve,flgclabe,cdmotcan, tpendcor, s.progress_recid, cdopecnl,dtrenova,cdopeori,cdageori,dtinsori,cdopeexc,cdageexc,dtinsexc,vlslddev,idimpdps,
       p.cdcooper cdcoopercrap, p.nrdconta nrdcontacrap, p.nrctrseg nrctrsegcrap, p.dtinivig dtinivigcrap, p.dtfimvig dtfimvigcrap, p.qtparcel qtparcelcrap
  from cecred.crawseg w,
       cecred.tbseg_prestamista p,
       cecred.crapseg s
 where w.cdcooper = 13
   and w.nrdconta = 487775
   and w.cdcooper = p.cdcooper
   and w.nrdconta = p.nrdconta
   and w.nrctrseg = p.nrctrseg 
   and w.cdcooper = s.cdcooper
   and w.nrdconta = s.nrdconta
   and w.nrctrseg = s.nrctrseg
   and w.nrctrato = 229905
   and w.nrctrseg = 382305;



procedure valida_diretorio_p( ds_nome_diretorio_p in  varchar2,
        ds_critica_p    out crapcri.dscritic%TYPE) is

ds_critica_v  cecred.crapcri.dscritic%type;
ie_tipo_saida_v varchar2(3);
ds_saida_v  varchar2(1000);
   
begin

  if  (gene0001.fn_exis_diretorio(ds_nome_diretorio_p)) then

    ds_critica_p  := null;

  else

    cecred.gene0001.pc_OSCommand_Shell( pr_des_comando  => 'mkdir ' || ds_nome_diretorio_p || ' 1> /dev/null',
            pr_typ_saida  => ie_tipo_saida_v,
            pr_des_saida  => ds_saida_v);

    if  (ie_tipo_saida_v  = 'ERR') then

      ds_critica_v  := 'CRIAR DIRETORIO ARQUIVO -> Nao foi possivel criar o diretorio para gerar os arquivos. ' || ds_saida_v;
      raise   ds_exc_erro_v;

    end if;

    cecred.gene0001.pc_OSCommand_Shell( pr_des_comando  => 'chmod 777 ' || ds_nome_diretorio_p || ' 1> /dev/null',
            pr_typ_saida  => ie_tipo_saida_v,
            pr_des_saida  => ds_saida_v);

    if  (ie_tipo_saida_v  = 'ERR') then

      ds_critica_v  := 'PERMISSAO NO DIRETORIO -> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' || ds_saida_v;
      raise   ds_exc_erro_v;

    end if;

  end if;

exception
when  ds_exc_erro_v then

        ds_critica_p  := ds_critica_v;

end valida_diretorio_p;

begin

if  (upper(cecred.gene0001.fn_database_name) like '%AYLLOSP%' or upper(gene0001.fn_database_name) like '%AILOSTS%') then

  select  max(a.dsvlrprm)
  into  ds_nome_diretorio_v
  from  cecred.crapprm a
  where a.nmsistem  = 'CRED'
  and a.cdcooper  = cd_cooperativa_v
  and a.cdacesso  = 'ROOT_MICROS';

  if  (ds_nome_diretorio_v  is null) then

    select  max(a.dsvlrprm)
    into  ds_nome_diretorio_v
    from  cecred.crapprm a
    where a.nmsistem  = 'CRED'
    and a.cdcooper  = 0
    and a.cdacesso  = 'ROOT_MICROS';

  end if;

  ds_nome_diretorio_v := ds_nome_diretorio_v || 'cpd/bacas/INC0215230/rollback';

else

  ds_nome_diretorio_v := gene0001.fn_diretorio( pr_tpdireto => 'C',
                pr_cdcooper => 3);

  ds_nome_diretorio_v := ds_nome_diretorio_v || '/INC0215230/rollback';

end if;
 
valida_diretorio_p( ds_nome_diretorio_p => ds_nome_diretorio_v,
      ds_critica_p    => ds_critica_v);

if  (trim(ds_critica_v) is not null) then

  raise ds_exc_erro_v;

end if;



for r01 in c01 loop

  begin

  if  (qt_reg_arquivo >= 50000) then

    qt_reg_arquivo  := 0;

    dbms_lob.createtemporary(ds_dados_rollback_v, true, dbms_lob.CALL);
    dbms_lob.open(ds_dados_rollback_v, dbms_lob.lob_readwrite);
    cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin '||chr(13), false);  
    ds_nome_arquivo_bkp_v := 'ROLLBACK2_INC0215230_'||nr_arquivo||'.sql';

    nr_arquivo  := nr_arquivo + 1;

  end if;

  qt_registro := qt_registro + 1;
  qt_reg_arquivo  := qt_reg_arquivo + 1;

  update  cecred.crawseg
     set  tpcustei  = 0,
		  vlseguro  = 0,
		  vlpremio  = 0
   where  cdcooper = r01.cdcoopertbseg
     and  nrdconta = r01.nrdcontatbseg
     and  nrctrseg = r01.nrctrsegtbseg
     and  nrctrato = r01.nrctremptbseg
     and  nrproposta = r01.nrproposta;
     
  delete  cecred.crapseg
   where  cdcooper  = r01.cdcoopercrap
     and  nrdconta  = r01.nrdcontacrap
     and  tpseguro  = 4
     and  nrctrseg  = r01.nrctrsegcrap;
     
  delete  cecred.tbseg_prestamista
   where  cdcooper  = r01.cdcoopertbseg
     and  nrdconta  = r01.nrdcontatbseg
     and  nrctrseg  = r01.nrctrsegtbseg
     and  nrctremp  = r01.nrctremptbseg
     and  nrproposta  = r01.nrproposta;   

  cecred.gene0002.pc_escreve_xml( ds_dados_rollback_v,
          ds_texto_rollback_v,
          'update cecred.crawseg ' ||
          '   set tpcustei = ' || r01.tpcusteio ||
          '      ,vlseguro = ' || replace(nvl(trim(to_char(r01.vlrseguro)),'null'),',','.') ||  
          '      ,vlpremio = ' || replace(nvl(trim(to_char(r01.vlrpremio)),'null'),',','.') || 
          ' where cdcooper = ' || r01.cdcoopertbseg ||
          ' and nrdconta = ' || r01.nrdcontatbseg ||
          ' and nrctrseg = ' || r01.nrctrsegtbseg ||
          ' and nrctrato = ' || r01.nrctremptbseg ||
          ' and nrproposta = ' || r01.nrproposta ||         
          ';' || chr(13) || chr(13), false);
  
  cecred.gene0002.pc_escreve_xml( ds_dados_rollback_v,
          ds_texto_rollback_v,
          'insert into cecred.crapseg(nrdconta, ' ||
                    ' nrctrseg, ' ||
                    ' dtinivig, ' ||
                    ' dtfimvig, ' ||
                    ' dtmvtolt, ' || 
                    ' cdagenci, ' ||
                    ' cdbccxlt, ' ||
                    ' cdsitseg, ' ||
                    ' dtaltseg, ' ||
                    ' dtcancel, ' ||
                    ' dtdebito, ' ||
                    ' dtiniseg, ' ||
                    ' indebito, ' ||
                    ' nrdolote, ' ||
                    ' nrseqdig, ' ||
                    ' qtprepag, ' ||
                    ' vlprepag, ' ||
                    ' vlpreseg, ' ||
                    ' dtultpag, ' ||
                    ' tpseguro, ' ||
                    ' tpplaseg, ' ||
                    ' qtprevig, ' ||
                    ' cdsegura, ' ||
                    ' lsctrant, ' ||
                    ' nrctratu, ' ||
                    ' flgunica, ' ||
                    ' dtprideb, ' ||
                    ' vldifseg, ' ||
                    ' nmbenvid##1, ' ||
                    ' nmbenvid##2, ' ||
                    ' nmbenvid##3, ' ||
                    ' nmbenvid##4, ' ||
                    ' nmbenvid##5, ' ||
                    ' dsgraupr##1, ' ||
                    ' dsgraupr##2, ' ||
                    ' dsgraupr##3, ' ||
                    ' dsgraupr##4, ' ||
                    ' dsgraupr##5, ' ||
                    ' txpartic##1, ' ||
                    ' txpartic##2, ' ||
                    ' txpartic##3, ' ||
                    ' txpartic##4, ' ||
                    ' txpartic##5, ' ||
                    ' dtultalt, ' ||
                    ' cdoperad, ' ||
                    ' vlpremio, ' ||
                    ' qtparcel, ' ||
                    ' tpdpagto, ' ||
                    ' cdcooper, ' ||
                    ' flgconve, ' ||
                    ' flgclabe, ' ||
                    ' cdmotcan, ' ||
                    ' tpendcor, ' ||
                    ' progress_recid, ' ||
                    ' cdopecnl, ' ||
                    ' dtrenova, ' ||
                    ' cdopeori, ' ||
                    ' cdageori, ' ||
                    ' dtinsori, ' ||
                    ' cdopeexc, ' ||
                    ' cdageexc, ' ||
                    ' dtinsexc, ' ||
                    ' vlslddev, ' ||
                    ' idimpdps)' || chr(13) ||
          'values (' || replace(nvl(trim(to_char(r01.nrdcontacrap)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.nrctrsegcrap)),'null'),',','.') || ', ' ||
            'to_date(' || chr(39) || trim(to_char(r01.dtinivigcrap,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
            'to_date(' || chr(39) || trim(to_char(r01.dtfimvigcrap,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
            'to_date(' || chr(39) || trim(to_char(r01.dtmvtolt,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
            replace(nvl(trim(to_char(r01.cdagenci)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.cdbccxlt)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.cdsitseg)),'null'),',','.') || ', ' ||
            'to_date(' || chr(39) || trim(to_char(r01.dtaltseg,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
            'to_date(' || chr(39) || trim(to_char(r01.dtcancel,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
            'to_date(' || chr(39) || trim(to_char(r01.dtdebito,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
            'to_date(' || chr(39) || trim(to_char(r01.dtiniseg,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
            replace(nvl(trim(to_char(r01.indebito)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.nrdolote)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.nrseqdig)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.qtprepag)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.vlprepag)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.vlpreseg)),'null'),',','.') || ', ' ||
            'to_date(' || chr(39) || trim(to_char(r01.dtultpag,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
            replace(nvl(trim(to_char(r01.tpseguro)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.tpplaseg)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.qtprevig)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.cdsegura)),'null'),',','.') || ', ' ||
            chr(39) || r01.lsctrant || chr(39) || ', ' ||
            replace(nvl(trim(to_char(r01.nrctratu)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.flgunica)),'null'),',','.') || ', ' ||
            'to_date(' || chr(39) || trim(to_char(r01.dtprideb,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
            replace(nvl(trim(to_char(r01.vldifseg)),'null'),',','.') || ', ' ||
            chr(39) || r01.nmbenvid##1 || chr(39) || ', ' ||
            chr(39) || r01.nmbenvid##2 || chr(39) || ', ' ||
            chr(39) || r01.nmbenvid##3 || chr(39) || ', ' ||
            chr(39) || r01.nmbenvid##4 || chr(39) || ', ' ||
            chr(39) || r01.nmbenvid##5 || chr(39) || ', ' ||
            chr(39) || r01.dsgraupr##1 || chr(39) || ', ' ||
            chr(39) || r01.dsgraupr##2 || chr(39) || ', ' ||
            chr(39) || r01.dsgraupr##3 || chr(39) || ', ' ||
            chr(39) || r01.dsgraupr##4 || chr(39) || ', ' ||
            chr(39) || r01.dsgraupr##5 || chr(39) || ', ' ||
            replace(nvl(trim(to_char(r01.txpartic##1)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.txpartic##2)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.txpartic##3)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.txpartic##4)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.txpartic##5)),'null'),',','.') || ', ' ||
            'to_date(' || chr(39) || trim(to_char(r01.dtultalt,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
            chr(39) || r01.cdoperad || chr(39) || ', ' ||
            replace(nvl(trim(to_char(r01.vlpremio)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.qtparcelcrap)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.tpdpagto)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.cdcoopercrap)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.flgconve)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.flgclabe)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.cdmotcan)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.tpendcor)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.progress_recid)),'null'),',','.') || ', ' ||
            chr(39) || r01.cdopecnl || chr(39) || ', ' ||
            'to_date(' || chr(39) || trim(to_char(r01.dtrenova,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
            chr(39) || r01.cdopeori || chr(39) || ', ' ||
            replace(nvl(trim(to_char(r01.cdageori)),'null'),',','.') || ', ' ||
            'to_date(' || chr(39) || trim(to_char(r01.dtinsori,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
            chr(39) || r01.cdopeexc || chr(39) || ', ' ||
            replace(nvl(trim(to_char(r01.cdageexc)),'null'),',','.') || ', ' ||
            'to_date(' || chr(39) || trim(to_char(r01.dtinsexc,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
            replace(nvl(trim(to_char(r01.vlslddev)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.idimpdps)),'null'),',','.') ||
            ');' || chr(13) || chr(13), false);
  
  cecred.gene0002.pc_escreve_xml( ds_dados_rollback_v,
          ds_texto_rollback_v,
          'insert into cecred.tbseg_prestamista ' ||
          '  (idseqtra, ' ||
          '   cdcooper, ' ||
          '   nrdconta, ' ||
          '   nrctrseg, ' ||
          '   nrctremp, ' ||
          '   tpregist, ' ||
          '   cdapolic, ' ||
          '   nrcpfcgc, ' ||
          '   nmprimtl, ' ||
          '   dtnasctl, ' ||
          '   cdsexotl, ' ||
          '   dsendres, ' ||
          '   dsdemail, ' ||
          '   nmbairro, ' ||
          '   nmcidade, ' ||
          '   cdufresd, ' ||
          '   nrcepend, ' ||
          '   nrtelefo, ' ||
          '   dtdevend, ' ||
          '   dtinivig, ' ||
          '   cdcobran, ' ||
          '   cdadmcob, ' ||
          '   tpfrecob, ' ||
          '   tpsegura, ' ||
          '   cdprodut, ' ||
          '   cdplapro, ' ||
          '   vlprodut, ' ||
          '   tpcobran, ' ||
          '   vlsdeved, ' ||
          '   vldevatu, ' ||
          '   dtrefcob, ' ||
          '   dtfimvig, ' ||
          '   dtdenvio, ' ||
          '   nrproposta, ' ||
          '   tprecusa, ' ||
          '   cdmotrec, ' ||
          '   dtrecusa, ' ||
          '   situacao, ' ||
          '   tpcustei, ' ||
          '   pemorte, ' ||
          '   peinvalidez, ' ||
          '   peiftttaxa, ' ||
          '   qtifttdias, ' ||
          '   nrapolice, ' ||
          '   qtparcel, ' ||
          '   vlpielimit, ' ||
          '   vlifttlimi, ' ||
          '   dsprotocolo, ' ||
          '   flfinanciasegprestamista)' || chr(13) ||
          'values (' || replace(nvl(trim(to_char(r01.idseqtra)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.cdcoopertbseg)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.nrdcontatbseg)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.nrctrsegtbseg)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.nrctremptbseg)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.tpseguro)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.cdapolic)),'null'),',','.') || ', ' ||
            chr(39) || r01.nrcpfcgc || chr(39) || ', ' ||
            chr(39) || r01.nmprimtl || chr(39) || ', ' ||
            'to_date(' || chr(39) || trim(to_char(r01.dtnasctl,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
            replace(nvl(trim(to_char(r01.cdsexotl)),'null'),',','.') || ', ' ||
            chr(39) || r01.dsendres || chr(39) || ', ' ||
            chr(39) || r01.dsdemail || chr(39) || ', ' ||
            chr(39) || r01.nmbairro || chr(39) || ', ' ||
            chr(39) || r01.nmcidade || chr(39) || ', ' ||
            chr(39) || r01.cdufresd || chr(39) || ', ' ||
            replace(nvl(trim(to_char(r01.nrcepend)),'null'),',','.') || ', ' ||
            chr(39) || r01.nrtelefo || chr(39) || ', ' ||            
            'to_date(' || chr(39) || trim(to_char(r01.dtdevend,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
            'to_date(' || chr(39) || trim(to_char(r01.dtinivigtbseg,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
            replace(nvl(trim(to_char(r01.cdcobran)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.cdadmcob)),'null'),',','.') || ', ' ||
            chr(39) || r01.tpfrecob || chr(39) || ', ' ||
            chr(39) || r01.tpsegura || chr(39) || ', ' ||
            chr(39) || r01.cdprodut || chr(39) || ', ' ||
            replace(nvl(trim(to_char(r01.cdplapro)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.vlprodut)),'null'),',','.') || ', ' ||
            chr(39) || r01.tpcobran || chr(39) || ', ' ||
            replace(nvl(trim(to_char(r01.vlsdeved)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.vldevatu)),'null'),',','.') || ', ' ||
            'to_date(' || chr(39) || trim(to_char(r01.dtrefcob,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
            'to_date(' || chr(39) || trim(to_char(r01.dtfimvigtbseg,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
            'to_date(' || chr(39) || trim(to_char(r01.dtdenvio,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
            replace(nvl(trim(to_char(r01.nrproposta)),'null'),',','.') || ', ' ||
            chr(39) || r01.tprecusa || chr(39) || ', ' ||
            replace(nvl(trim(to_char(r01.cdmotrec)),'null'),',','.') || ', ' ||
            'to_date(' || chr(39) || trim(to_char(r01.dtrecusa,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
            replace(nvl(trim(to_char(r01.situacao)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.tpcustei)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.pemorte)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.peinvalidez)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.peiftttaxa)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.qtifttdias)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.nrapolice)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.qtparceltbseg)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.vlpielimit)),'null'),',','.') || ', ' ||
            replace(nvl(trim(to_char(r01.vlifttlimi)),'null'),',','.') || ', ' ||
            chr(39) || r01.dsprotocolo || chr(39) || ', ' ||
            replace(nvl(trim(to_char(r01.flfinanciasegprestamista)),'null'),',','.') ||
          ');' || chr(13) || chr(13), false);     

  if  (qt_registro  >= 10000) then

    cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);

    commit;

    qt_registro := 0;

  end if;

  if  (qt_reg_arquivo >= 50000) then

    cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);
    cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'end;'||chr(13), FALSE);
    cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13), TRUE);

    cecred.gene0002.pc_solicita_relato_arquivo( pr_cdcooper => cd_cooperativa_v,
              pr_cdprogra => 'ATENDA',
              pr_dtmvtolt => trunc(sysdate),
              pr_dsxml  => ds_dados_rollback_v,
              pr_dsarqsaid  => ds_nome_diretorio_v || '/' || ds_nome_arquivo_bkp_v,
              pr_flg_impri  => 'N',
              pr_flg_gerar  => 'S',
              pr_flgremarq  => 'N',
              pr_nrcopias => 1,
              pr_des_erro => ds_critica_v);

    if  (trim(ds_critica_v) is not null) then

      rollback;
      raise ds_exc_erro_v;

    end if;

    dbms_lob.close(ds_dados_rollback_v);
    dbms_lob.freetemporary(ds_dados_rollback_v);

  end if;

  exception
  when others then
    vr_dscritic := 'Falha ao atualizar tbseg_prestamista ou crapseg';
    rollback;
    exit;
  end;

end loop;


if  (qt_reg_arquivo <> 50000) then

  cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);
  cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'end;' || chr(13), FALSE);
  cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13), TRUE);

  cecred.gene0002.pc_solicita_relato_arquivo( pr_cdcooper => cd_cooperativa_v,
            pr_cdprogra => 'ATENDA',
            pr_dtmvtolt => trunc(sysdate),
            pr_dsxml  => ds_dados_rollback_v,
            pr_dsarqsaid  => ds_nome_diretorio_v || '/' || ds_nome_arquivo_bkp_v,
            pr_flg_impri  => 'N',
            pr_flg_gerar  => 'S',
            pr_flgremarq  => 'N',
            pr_nrcopias => 1,
            pr_des_erro => ds_critica_v);

  if  (trim(ds_critica_v) is not null) then

    raise ds_exc_erro_v;

  end if;

  dbms_lob.close(ds_dados_rollback_v);
  dbms_lob.freetemporary(ds_dados_rollback_v);

end if;

if  (trim(vr_dscritic) is not null) then

  ds_critica_v  := vr_dscritic;
  raise ds_exc_erro_v;

end if;

commit;

exception
when  ds_exc_erro_v then

  raise_application_error(-20111, ds_critica_v);

end;

end;
