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
select p.cdcooper,p.nrdconta,p.nrctrseg,p.nrctremp,p.nrproposta,p.tpregist,s.cdsitseg,s.tpseguro,s.dtcancel,p.dtrecusa, p.tprecusa, s.cdmotcan, s.dtfimvig, s.cdopeexc, s.dtinsexc, cdopecnl
 from cecred.crapseg s,
      cecred.tbseg_prestamista p
where s.cdcooper = p.cdcooper
  and s.nrdconta = p.nrdconta
  and s.nrctrseg = p.nrctrseg
  and s.cdsitseg <> 5
  and p.nrproposta in ('202210507201',
                      '770629464670',
                      '202213345019',
                      '202212148294',
                      '770629163026',
                      '202210507095',
                      '202213083934',
                      '202213851083',
                      '202213534482',
                      '202213381561',
                      '202210507585',
                      '202213346013',
                      '202213367812',
                      '202213345514',
                      '202212177069',
                      '202213349994',
                      '202212177828',
                      '770629120300');

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

  ds_nome_diretorio_v := ds_nome_diretorio_v || 'cpd/bacas/INC0243430/rollback';

else

  ds_nome_diretorio_v := gene0001.fn_diretorio( pr_tpdireto => 'C',
                pr_cdcooper => 3);

  ds_nome_diretorio_v := ds_nome_diretorio_v || '/INC0243430/rollback';

end if;
 
valida_diretorio_p( ds_nome_diretorio_p => ds_nome_diretorio_v,
      ds_critica_p    => ds_critica_v);

if  (trim(ds_critica_v) is not null) then

  raise ds_exc_erro_v;

end if;


dbms_lob.createtemporary(ds_dados_rollback_v, true, dbms_lob.CALL);
dbms_lob.open(ds_dados_rollback_v, dbms_lob.lob_readwrite);
cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin '||chr(13), false);  
ds_nome_arquivo_bkp_v := 'ROLLBACK_INC0243430_'||nr_arquivo||'.sql';


for r01 in c01 loop

  begin

  update cecred.crapseg 
       set dtfimvig  = trunc(sysdate),
       dtcancel  = trunc(sysdate),
       cdsitseg  = 5,
       cdopeexc  = 1,
       cdageexc  = 1,
       dtinsexc  = trunc(sysdate),
       cdopecnl  = 1
   where cdcooper = r01.cdcooper
     and nrdconta = r01.nrdconta
     and nrctrseg = r01.nrctrseg
     and tpseguro = 4;
     
  cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                  ds_texto_rollback_v,
                  'update cecred.crapseg ' ||
                  '   set cdsitseg = ' || r01.cdsitseg || ',' || 
                  '       dtfimvig = ' || 'to_date(' || chr(39) || trim(to_char(r01.dtfimvig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
                  '       dtcancel = NULL,' ||
                  '       cdopeexc = NULL,' ||
                  '       dtinsexc = NULL,' ||
                  '       cdopecnl = NULL ' ||
                  ' where cdcooper = ' || r01.cdcooper ||
                  ' and nrdconta = ' || r01.nrdconta ||
                  ' and nrctrseg = ' || r01.nrctrseg ||
                  ' and tpseguro = 4' ||        
                  ';' || chr(13) || chr(13), false);
          
  
  update cecred.tbseg_prestamista
     set cdmotrec = 154,
         tprecusa = 'Ajuste via script INC0243430',
         dtrecusa = trunc(sysdate)
   where cdcooper = r01.cdcooper
     and nrdconta = r01.nrdconta
     and nrctrseg = r01.nrctrseg;
     
  cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
                  ds_texto_rollback_v,
                  'update cecred.tbseg_prestamista ' ||
                  '   set cdmotrec = NULL, ' || 
                  '       tprecusa = NULL, ' || 
                  '       dtrecusa = NULL ' ||
                  ' where cdcooper = ' || r01.cdcooper ||
                  ' and nrdconta = ' || r01.nrdconta ||
                  ' and nrctrseg = ' || r01.nrctrseg ||      
                  ';' || chr(13) || chr(13), false);   
     
  commit;

  
  exception
  when others then
    vr_dscritic := 'Falha ao atualizar tbseg_prestamista ou crapseg';
    rollback;
    exit;
  end;

end loop;


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
