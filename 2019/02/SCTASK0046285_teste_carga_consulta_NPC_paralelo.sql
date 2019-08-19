declare
  --
  vr_hash_principal varchar2(26) := 'PRL'||trim(replace(to_char(current_timestamp,'yyyymmddhh24missxff'),','));
  --
begin
  --
  declare
    --
    vr_dsplsql  varchar2(10000);
    vr_qtsimultaneo number(2) := 50;
    vr_qtregistro number(10) := 0;
    vr_qtreprogramacao number(10) := 0;
    vr_currenttimestamp timestamp with time zone := to_timestamp_tz(to_char(CAST(current_timestamp AT TIME ZONE 'AMERICA/SAO_PAULO' AS timestamp)+(20/86400),'ddmmyyyyhh24miss')||' AMERICA/SAO_PAULO','ddmmyyyyhh24miss TZR');
    vr_jobname  varchar2(100);
    vr_dscritic VARCHAR2(4000);
    --
  begin
    --
    for r0001 in (
                  select tit.cdcooper
                        ,tit.nrdconta
                        ,tit.cdagenci
                        ,0 flmobile
                        ,''''||trim(to_char(tit.dscodbar))||'''' dscodbar
                  from craptit tit
                  where tit.cdcooper >= 0
                    and tit.dtdpagto = to_date('14082018','ddmmyyyy')
                    and tit.vltitulo >= 400
                    and rownum <= 1000
                    and to_number(substr(tit.dscodbar,10,10)) <> 0
                 )
    loop
      --
      vr_qtregistro := vr_qtregistro + 1;
      --
      if mod(vr_qtregistro,vr_qtsimultaneo) = 0 then
--      if vr_qtsimultaneo <= 0 then
        --
--        vr_qtsimultaneo := trunc(dbms_random.value(1,17));
        vr_qtreprogramacao := vr_qtreprogramacao + 1;
        --
        vr_currenttimestamp := to_timestamp_tz(to_char(CAST(current_timestamp AT TIME ZONE 'AMERICA/SAO_PAULO' AS timestamp)+((20+vr_qtreprogramacao)/86400),'ddmmyyyyhh24miss')||' AMERICA/SAO_PAULO','ddmmyyyyhh24miss TZR');
--        vr_currenttimestamp := to_timestamp_tz(to_char(current_timestamp+((20+vr_qtreprogramacao)/86400),'ddmmyyyyhh24miss')||' AMERICA/SAO_PAULO','ddmmyyyyhh24miss TZR');
--        dbms_output.put_line(vr_qtregistro/vr_qtsimultaneo);
--        dbms_output.put_line(vr_currenttimestamp);
        --
      end if;
      --
--      vr_qtsimultaneo := vr_qtsimultaneo - 1;
      --
--/*
    vr_dsplsql := 
'declare
  -- Non-scalar parameters require additional processing 
  pr_tbtitulocip cecred.npcb0001.typ_reg_titulocip;
  -- variaveis NCP
  vr_nrdocbenf NUMBER;  
  vr_tppesbenf VARCHAR2(100); 
  vr_dsbenefic VARCHAR2(100); 
  vr_vlrtitulo NUMBER;       
  vr_vlrjuros NUMBER;
  vr_vlrmulta NUMBER;
  vr_vldescto NUMBER;
  vr_cdctrlcs  VARCHAR2(100);  
  vr_tbtitulocip NPCB0001.typ_reg_titulocip;        
  vr_flblq_valor INTEGER;
  vr_flgtitven   INTEGER;
  vr_flcontig    NUMBER;
  -- Descricao e codigo da critica
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  vr_des_erro VARCHAR2(4000);
  --
  vr_hash varchar2(26) := '''||vr_hash_principal||''';
  vr_req_inicio timestamp with time zone;
  vr_req_fim    timestamp with time zone;
  vr_log varchar2(4000);
  vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
  --
begin
  --
  vr_nrdocbenf := null;
  vr_tppesbenf := null;
  vr_dsbenefic := null;
  vr_vlrtitulo := null;
  vr_vlrjuros := null;
  vr_vlrmulta := null;
  vr_vldescto := null;
  vr_cdctrlcs  := null;
  vr_flblq_valor := null;
  vr_flgtitven := null;
  vr_flcontig := null;
  --
  vr_req_inicio := current_timestamp;
  --
  npcb0002.pc_consultar_titulo_cip(pr_cdcooper => '||r0001.cdcooper||'
                                  ,pr_nrdconta => '||r0001.nrdconta||'
                                  ,pr_cdagenci => '||r0001.cdagenci||'
                                  ,pr_flmobile => '||r0001.flmobile||'
                                  ,pr_dtmvtolt => trunc(sysdate)
                                  ,pr_titulo1 => null
                                  ,pr_titulo2 => null
                                  ,pr_titulo3 => null
                                  ,pr_titulo4 => null
                                  ,pr_titulo5 => null
                                  ,pr_codigo_barras => '||trim(to_char(r0001.dscodbar))||'
                                  ,pr_cdoperad => 1
                                  ,pr_idorigem => 1
                                  ,pr_nrdocbenf => vr_nrdocbenf
                                  ,pr_tppesbenf => vr_tppesbenf
                                  ,pr_dsbenefic => vr_dsbenefic
                                  ,pr_vlrtitulo => vr_vlrtitulo
                                  ,pr_vlrjuros => vr_vlrjuros
                                  ,pr_vlrmulta => vr_vlrmulta
                                  ,pr_vlrdescto => vr_vldescto
                                  ,pr_cdctrlcs => vr_cdctrlcs
                                  ,pr_tbtitulocip => pr_tbtitulocip
                                  ,pr_flblq_valor => vr_flblq_valor
                                  ,pr_fltitven => vr_flgtitven
                                  ,pr_flcontig => vr_flcontig
                                  ,pr_des_erro => vr_des_erro
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
  --
  vr_req_fim := current_timestamp;
  --
  vr_log := vr_hash||'';cb:''||'||trim(to_char(r0001.dscodbar))||'||'';''||vr_cdctrlcs||'';''||to_char(vr_req_inicio,''HH24:MI:SSXFF'')||'';''||to_char(vr_req_fim,''HH24:MI:SSXFF'')||'';''||substr((vr_req_fim-vr_req_inicio),12);
  --
  --dbms_output.put_line(vr_log);
  --
  CECRED.pc_log_programa(pr_dstiplog      => ''O''
                        ,pr_cdprograma    => ''NPC_TST_CNS_PRL''
                        ,pr_cdcooper      => 3
                        ,pr_tpexecucao    => 2 --job
                        ,pr_tpocorrencia  => 4
                        ,pr_cdcriticidade => 0
                        ,pr_cdmensagem    => 0
                        ,pr_dsmensagem    => vr_log
                        ,pr_idprglog      => vr_idprglog
                        ,pr_nmarqlog      => NULL);
  --
end;';
      --
      vr_jobname := 'NPC_TST_CNS_PRL$';
      --
      gene0001.pc_submit_job(pr_cdcooper => r0001.cdcooper
                            ,pr_cdprogra => 'NPC_TST_CNS_PRL'
                            ,pr_dsplsql  => vr_dsplsql
                            ,pr_dthrexe  => vr_currenttimestamp
                            ,pr_interva  => NULL
                            ,pr_jobname  => vr_jobname
                            ,pr_des_erro => vr_dscritic );
--*/
      --
      if trim(vr_dscritic) is not null then
        --
        raise_application_error(-20001,vr_dscritic);
        --
      end if;
      --
    end loop;
    --
  end;
  --
end;
