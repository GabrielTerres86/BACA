declare
  vr_cdcritic  crapcri.cdcritic%type;
  vr_dscritic  crapcri.dscritic%type;
begin
  update contacorrente.tbcc_solicitacao_bloqueio t set t.vlbloqueado = 309.67
  where t.idsolblq = 'D1F88837A0DF0230E0530A29357E4CBE';
  
  contacorrente.finalizabloqueiopix(pr_idblqpix => 'D1F88837A0DF0230E0530A29357E4CBE', -- Código do bloqueio
                                    pr_instatus => 2, --Status de desbloqueio: 1 - Fraude / 2 - Cancelamento
                                    pr_cdcritic => vr_cdcritic,
                                    pr_dscritic => vr_dscritic);

  if (vr_cdcritic <> 0) then
    RAISE_APPLICATION_ERROR(-20000,'Erro ao finalizar bloqueio - cdcritic: ' || vr_cdcritic || ' - ' || vr_dscritic);
  end if;
end;
