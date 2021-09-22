-- INC0100233
-- Tempo Estimado: 17 min
declare 
  cursor cr_craplim is
    select l.cdcooper
          ,l.nrdconta
          ,l.nrctrlim
          ,l.dtpropos
          ,l.vllimite
          ,a.nrcpfcnpj_base
          ,o.dtrisco_rating_autom
      from craplim l, crapass a, tbrisco_operacoes o
     where l.cdcooper = a.cdcooper
       and l.nrdconta = a.nrdconta
       and o.cdcooper = l.cdcooper
       and o.nrdconta = l.nrdconta
       and o.nrctremp = l.nrctrlim
       and o.tpctrato = 1             -- Limite Credito
       and l.tpctrlim = 1             -- Limite Credito
       and l.insitlim = 2             -- Limite ativo
       and o.inrisco_rating IS NULL   -- Sem rating
       and o.inrisco_rating_autom IS NOT NULL;
  rw_craplim     cr_craplim%rowtype;
  vr_cdcritic    PLS_INTEGER;
  vr_dscritic    VARCHAR2(4000);
  vr_contador    PLS_INTEGER;

begin

  vr_contador := 0;
  for rw_craplim in cr_craplim loop
    vr_cdcritic := NULL;
    vr_dscritic := NULL;

    rati0003.pc_grava_rating_operacao(pr_cdcooper          => rw_craplim.cdcooper
                                     ,pr_nrdconta          => rw_craplim.nrdconta
                                     ,pr_tpctrato          => 1 -- Limite Credito
                                     ,pr_nrctrato          => rw_craplim.nrctrlim
                                     ,pr_dtrating          => rw_craplim.dtrisco_rating_autom
                                     ,pr_strating          => 4
                                     ,pr_cdoperad          => '1'
                                     ,pr_dtmvtolt          => rw_craplim.dtrisco_rating_autom
                                     ,pr_valor             => rw_craplim.vllimite
                                     ,pr_justificativa     => '[BACA INC0100233]'
                                     ,pr_tpoperacao_rating => 2
                                     ,pr_nrcpfcnpj_base    => rw_craplim.nrcpfcnpj_base
                                     -- Saída
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
    if (trim(vr_dscritic) is not null or nvl(vr_cdcritic,0) > 0) then
      dbms_output.put_line('Coop:'|| rw_craplim.cdcooper ||
                           ', Conta:'|| rw_craplim.nrdconta ||
                           ', Contrato:'|| rw_craplim.nrctrlim ||
                           ', DS Erro: ' || vr_dscritic ||
                           ', CD Erro: ' || vr_cdcritic);
    end if;
    vr_contador := vr_contador + 1;

    if vr_contador > 5000 then
      vr_contador := 0;
      commit;
    end if;

  end loop
  commit;
end;
