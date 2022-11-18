begin

declare

ds_exc_erro_v   exception;
ds_dados_rollback_v clob      := null;
ds_texto_rollback_v varchar2(32600);

cd_cooperativa_v  cecred.crapcop.cdcooper%type  := 3;
ds_nome_arquivo_bkp_v varchar2(100);
ds_nome_diretorio_v cecred.crapprm.dsvlrprm%type;
ds_critica_v    cecred.crapcri.dscritic%type;
vr_cdcritic  PLS_INTEGER;
vr_dscritic  VARCHAR2(4000);
vr_exc_saida EXCEPTION;

qt_registro number(10)  := 0;
nr_arquivo  number(10)  := 1;
qt_reg_arquivo  number(10)  := 50000;

vr_nrsequen  NUMBER(10);
vr_vlpercmo  NUMBER;
vr_vlpercin  NUMBER;
rw_tbseg_parametros_prst tbseg_parametros_prst%ROWTYPE;

cursor  c01 is
select w.*, e.cdagenci , e.cdbccxlt, e.cdopeori, e.cdageori,
       case when w.nrctrseg in (264726, 57856) then
         1
       else 0 end idimpdps
  from cecred.crawseg w,
       cecred.crapepr e     
 where w.cdcooper = e.cdcooper
   and w.nrdconta = e.nrdconta
   and w.nrctrato = e.nrctremp
   and w.tpseguro = 4
   and (w.cdcooper,w.nrdconta,w.nrctrseg) IN 
       ((6,31020,91582),    
        (9,550140,33651),
        (9,15294323,33083),
        (11,167,256111),
        (11,140228,258045),
        (11,173215,258459),
        (11,197300,264763),
        (11,227331,264726),
        (11,308099,265011),
        (11,384615,266661),
        (11,438197,263574),
        (11,460710,264122),
        (11,496685,259777),
        (11,720372,265733),
        (11,798142,261311),
        (11,798142,261313),
        (11,809276,264162),
        (11,834840,259361),
        (11,846180,261618),
        (11,859397,264405),
        (11,14089912,259842),
        (11,14673991,261983),
        (11,15160009,258444),
        (13,243396,403550),
        (13,324620,398863),
        (13,658804,396457),
        (14,14656310,57856));
  
procedure valida_diretorio_p( ds_nome_diretorio_p in  varchar2,
        ds_critica_p    out crapcri.dscritic%TYPE) is

ds_critica_v  cecred.crapcri.dscritic%type;
ie_tipo_saida_v varchar2(3);
ds_saida_v  varchar2(1000);
   
begin

  if (cecred.gene0001.fn_exis_diretorio(ds_nome_diretorio_p)) then

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

  ds_nome_diretorio_v := ds_nome_diretorio_v || 'cpd/bacas/INC0230359/rollback';

else

  ds_nome_diretorio_v := cecred.gene0001.fn_diretorio( pr_tpdireto => 'C',
                pr_cdcooper => 3);

  ds_nome_diretorio_v := ds_nome_diretorio_v || '/INC0230359/rollback';

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
    ds_nome_arquivo_bkp_v := 'ROLLBACK2_INC0230359_'||nr_arquivo||'.sql';

    nr_arquivo  := nr_arquivo + 1;

  end if;

  qt_registro := qt_registro + 1;
  qt_reg_arquivo  := qt_reg_arquivo + 1;

  insert into cecred.crapseg(nrdconta,
                             nrctrseg,
                             dtinivig,
                             dtfimvig,
                             dtmvtolt,
                             cdagenci,
                             cdbccxlt,
                             cdsitseg,
                             dtaltseg,
                             dtcancel,
                             dtdebito,
                             dtiniseg,
                             indebito,
                             nrdolote,
                             nrseqdig,
                             qtprepag,
                             vlprepag,
                             vlpreseg,
                             dtultpag,
                             tpseguro,
                             tpplaseg,
                             qtprevig,
                             cdsegura,
                             lsctrant,
                             nrctratu,
                             flgunica,
                             dtprideb,
                             vldifseg,
                             nmbenvid##1,
                             nmbenvid##2,
                             nmbenvid##3,
                             nmbenvid##4,
                             nmbenvid##5,
                             dsgraupr##1,
                             dsgraupr##2,
                             dsgraupr##3,
                             dsgraupr##4,
                             dsgraupr##5,
                             txpartic##1,
                             txpartic##2,
                             txpartic##3,
                             txpartic##4,
                             txpartic##5,
                             dtultalt,
                             cdoperad,
                             vlpremio,
                             qtparcel,
                             tpdpagto,
                             cdcooper,
                             flgconve,
                             flgclabe,
                             cdmotcan,
                             tpendcor,
                             progress_recid,
                             cdopecnl,
                             dtrenova,
                             cdopeori,
                             cdageori,
                             dtinsori,
                             cdopeexc,
                             cdageexc,
                             dtinsexc,
                             vlslddev,
                             idimpdps)
     values(r01.nrdconta,
            r01.nrctrseg,
            r01.dtinivig,
            r01.dtfimvig,
            r01.dtmvtolt,
            r01.cdagenci,
            r01.cdbccxlt,
            1,
            null,
            null,
            r01.dtdebito,
            r01.dtiniseg,
            0,
            0,
            r01.nrctrseg,
            0,
            0,
            r01.vlpreseg,
            null,
            r01.tpseguro,
            r01.tpplaseg,
            0,
            r01.cdsegura,
            r01.lsctrant,
            r01.nrctratu,
            r01.flgunica,
            r01.dtprideb,
            r01.vldifseg,
            r01.dscobext##1,
            r01.dscobext##2,
            r01.dscobext##3,
            r01.dscobext##4,
            r01.dscobext##5,
            null,
            null,
            null,
            null,
            null,
            r01.vlcobext##1,
            r01.vlcobext##2,
            r01.vlcobext##3,
            r01.vlcobext##4,
            r01.vlcobext##5,
            null,
            r01.cdopeori,
            r01.vlpremio,
            r01.qtparcel,
            r01.tpdpagto,
            r01.cdcooper,
            0,
            0,
            0,
            0,
            r01.progress_recid,
            null,
            null,
            r01.cdopeori,
            r01.cdageori,
            null,
            null,
            0,
            null,
            r01.vlseguro,
            r01.idimpdps);
     
    cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                  ds_texto_rollback_v,
                  'delete cecred.crapseg ' ||
                  ' where cdcooper = ' || r01.cdcooper ||
                  '   and nrdconta = ' || r01.nrdconta ||
                  '   and nrctrseg = ' || r01.nrctrseg ||
                  '   and tpseguro = 4' ||        
                  ';' || chr(13) || chr(13), false);
  
  vr_nrsequen := fn_sequence('TBSEG_PRESTAMISTA', 'SEQCERTIFICADO', 0);
  
   cecred.segu0003.pc_parametros_segpre( pr_cdcooper        => r01.cdcooper
                                        ,pr_nrdconta        => r01.nrdconta
                                        ,pr_nrctremp        => r01.nrctrato
                                        ,pr_nrctrseg        => r01.nrctrseg
                                        ,pr_parametros_prst => rw_tbseg_parametros_prst
                                        ,pr_cdcritic        => vr_cdcritic
                                        ,pr_dscritic        => vr_dscritic);
  
   vr_vlpercmo := cecred.segu0003.fn_retorna_prst_perc_morte(pr_cdcooper => r01.cdcooper,
															 pr_tppessoa => rw_tbseg_parametros_prst.tppessoa,
															 pr_cdsegura => rw_tbseg_parametros_prst.cdsegura,
															 pr_tpcustei => rw_tbseg_parametros_prst.tpcustei,
															 pr_dtnasc   => r01.dtnascsg,
															 pr_cdcritic => vr_cdcritic,
															 pr_dscritic => vr_dscritic);
   IF vr_dscritic IS NOT NULL THEN
     RAISE vr_exc_saida;
   END IF;
       
   vr_vlpercin := cecred.segu0003.fn_retorna_prst_perc_invalidez(pr_cdcooper => r01.cdcooper,
                                                                 pr_tppessoa => rw_tbseg_parametros_prst.tppessoa,
                                                                 pr_cdsegura => rw_tbseg_parametros_prst.cdsegura,
                                                                 pr_tpcustei => rw_tbseg_parametros_prst.tpcustei,
                                                                 pr_dtnasc   => r01.dtnascsg,
                                                                 pr_cdcritic => vr_cdcritic,
                                                                 pr_dscritic => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
  insert into cecred.tbseg_prestamista(cdcooper,
                                       nrdconta,
                                       nrctrseg,
                                       nrctremp,
                                       tpregist,
                                       cdapolic,
                                       nrcpfcgc,
                                       nmprimtl,
                                       dtnasctl,
                                       cdsexotl,
                                       dsendres,
                                       dsdemail,
                                       nmbairro,
                                       nmcidade,
                                       cdufresd,
                                       nrcepend,
                                       nrtelefo,
                                       dtdevend,
                                       dtinivig,
                                       cdcobran,
                                       cdadmcob,
                                       tpfrecob,
                                       tpsegura,
                                       cdprodut,
                                       cdplapro,
                                       vlprodut,
                                       tpcobran,
                                       vlsdeved,
                                       vldevatu,
                                       dtrefcob,
                                       dtfimvig,
                                       dtdenvio,
                                       nrproposta,
                                       tprecusa,
                                       cdmotrec,
                                       dtrecusa,
                                       situacao,
                                       tpcustei,
                                       pemorte,
                                       peinvalidez,
                                       peiftttaxa,
                                       qtifttdias,
                                       nrapolice,
                                       qtparcel,
                                       vlpielimit,
                                       vlifttlimi,
                                       dsprotocolo,
                                       flfinanciasegprestamista)
   values (r01.cdcooper,
           r01.nrdconta,
           r01.nrctrseg,
           r01.nrctrato,
           1, 
           vr_nrsequen,
           r01.nrcpfcgc,
           r01.nmdsegur,
           r01.dtnascsg,
           r01.cdsexosg,
           r01.dsendres,
           null,
           r01.nmbairro,
           r01.nmcidade,
           r01.cdufresd,
           r01.nrcepend,
           r01.nrfonres,
           r01.dtmvtolt,
           r01.dtinivig,
           10,
           null,
           'M',
           'MI',
           'BCV012',
           1,
           r01.vlpremio,
           'O',
           r01.vlseguro, 
           r01.vlseguro, 
           r01.dtmvtolt, 
           r01.dtfimvig,
           r01.dtmvtolt, 
           r01.nrproposta,
           null,
           null,
           null,
           null,
           r01.tpcustei,
           vr_vlpercmo,
           vr_vlpercin,
           rw_tbseg_parametros_prst.iftttaxa,
           rw_tbseg_parametros_prst.ifttparc,
           rw_tbseg_parametros_prst.nrapolic,
           rw_tbseg_parametros_prst.qtparcel,
           rw_tbseg_parametros_prst.pielimit,
           rw_tbseg_parametros_prst.ifttlimi,
           null,
           r01.flfinanciasegprestamista);
  
  cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                  ds_texto_rollback_v,
                  'delete cecred.tbseg_prestamista ' ||
                  ' where cdcooper = ' || r01.cdcooper ||
                  '   and nrdconta = ' || r01.nrdconta ||
                  '   and nrctrseg = ' || r01.nrctrseg ||      
                  ';' || chr(13) || chr(13), false);
          
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
