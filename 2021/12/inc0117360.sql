declare
  vr_cdcritic  crapcri.cdcritic%type;
  vr_dscritic  crapcri.dscritic%type;
begin
  -- Remove os lançamentos incorretos
  delete from cecred.craplcm l
   where 1=1
   and l.nrdconta =  11371331
   and l.cdcooper = 1
   and l.cdagenci = 1
   and l.cdbccxlt = 100
   and l.nrdolote = 37000
   and l.cdhistor = 3728
   and l.vllanmto = 309.67;    
  
  -- Atualiza o Bloqueio com o valor certo, que havia sido bloqueado
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
