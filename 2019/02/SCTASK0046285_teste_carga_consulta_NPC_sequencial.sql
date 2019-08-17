declare
  --
  vr_hash_principal varchar2(26) := 'SEQ'||trim(replace(to_char(current_timestamp,'yyyymmddhh24missxff'),','));
  --
begin
  --
  begin
    --
    for r0001 in (
                  select tit.cdcooper
                        ,tit.nrdconta
                        ,tit.cdagenci
                        ,0 flmobile
                        ,trunc(sysdate) dtmvtolt
                        ,tit.dscodbar
                  from craptit tit
                  where tit.cdcooper >= 0
                    and tit.dtdpagto = to_date('14082018','ddmmyyyy')
                    and tit.vltitulo >= 400
                    and rownum <= 1000
                    and to_number(substr(tit.dscodbar,10,10)) <> 0
/*

                  select 1 cdcooper
                        ,329 nrdconta
                        ,199 cdagenci
                        ,0 flmobile
                        ,to_date('01112018','ddmmyyyy') dtmvtolt
                        ,dscodbar
                  from (
select '08591770400000500000101900230678600000027301' dscodbar, 20181110 DtVencTit,'F' TpPessoaPagdr,41933771801 CNPJCPFPagdr from dual union all
select '08591773400000500000101900230678600000027401' dscodbar, 20181210 DtVencTit,'F' TpPessoaPagdr,41933771801 CNPJCPFPagdr from dual union all
select '08597776500000500000101900230678600000027501' dscodbar, 20190110 DtVencTit,'F' TpPessoaPagdr,41933771801 CNPJCPFPagdr from dual union all
select '08592779600000500000101900230678600000027601' dscodbar, 20190210 DtVencTit,'F' TpPessoaPagdr,41933771801 CNPJCPFPagdr from dual union all
select '08591782400000500000101900230678600000027701' dscodbar, 20190310 DtVencTit,'F' TpPessoaPagdr,41933771801 CNPJCPFPagdr from dual
                       )
                  select 1 cdcooper
                        ,329 nrdconta
                        ,199 cdagenci
                        ,0 flmobile
                        ,to_date('22102018','ddmmyyyy') dtmvtolt
                        ,lg."CodBarras" dscodbar
                  from tbjdnpcdstleg_lg2jd_optit@jdnpcbisql lg
                      ,tbjdnpcdstleg_jd2lg_optit@jdnpcbisql jd
                  where lg."IdOpLeg" = jd."IdOpLeg"
                    and lg."ISPBAdministrado" = jd."ISPBAdministrado"
                    and lg."IdTituloLeg" = jd."IdTituloLeg"
                    and lg."CdLeg" = jd."CdLeg"
                    --
                    and jd."DtHrOpJD" >= '20180801000000'
                    and jd."TpOpJD" = 'RI'
                    and jd."SitOpJD" = 'RC'
                    and rownum <= 10
--                    and upper(tit.dscodbar) = '34197761600001999251090000581418677027370000'
*/
                 )
    loop
      --
      declare
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
        vr_cdcritic number(9);
        vr_dscritic VARCHAR2(4000);
        vr_des_erro VARCHAR2(4000);
        --
        vr_hash varchar2(26) := vr_hash_principal;
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
        npcb0002.pc_consultar_titulo_cip(pr_cdcooper => r0001.cdcooper
                                        ,pr_nrdconta => r0001.nrdconta
                                        ,pr_cdagenci => r0001.cdagenci
                                        ,pr_flmobile => r0001.flmobile
                                        ,pr_dtmvtolt => r0001.dtmvtolt
                                        ,pr_titulo1 => null
                                        ,pr_titulo2 => null
                                        ,pr_titulo3 => null
                                        ,pr_titulo4 => null
                                        ,pr_titulo5 => null
                                        ,pr_codigo_barras => r0001.dscodbar
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
        dbms_output.put_line(vr_cdcritic);
        dbms_output.put_line(vr_dscritic);
        vr_req_fim := current_timestamp;
        --
        vr_log := vr_hash||';"'||r0001.dscodbar||'";'||vr_cdctrlcs||';'||to_char(vr_req_inicio,'HH24:MI:SSXFF')||';'||to_char(vr_req_fim,'HH24:MI:SSXFF')||';'||substr((vr_req_fim-vr_req_inicio),12);
        --
        dbms_output.put_line(vr_log);
        dbms_output.put_line(vr_cdctrlcs
                      ||' '||vr_vlrtitulo);
        --
        CECRED.pc_log_programa(pr_dstiplog      => 'O'
                              ,pr_cdprograma    => 'NPC_TST_CNS_SQS'
                              ,pr_cdcooper      => 3
                              ,pr_tpexecucao    => 2 --job
                              ,pr_tpocorrencia  => 4
                              ,pr_cdcriticidade => 0
                              ,pr_cdmensagem    => 0
                              ,pr_dsmensagem    => vr_log
                              ,pr_idprglog      => vr_idprglog
                              ,pr_nmarqlog      => NULL);
        --
      end;
      --
    end loop;
    --
  end;
  --
end;
