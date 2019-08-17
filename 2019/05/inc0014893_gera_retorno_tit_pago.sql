declare
  --
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  --
begin
  --
  for r_cop in (
                select cop.cdcooper
                from crapcop cop
                where cop.cdcooper <> 3
                  and cop.flgativo = 1
                  and cop.cdcooper in (1)
                order by cop.cdcooper
               )
  loop
    --
    dbms_output.put_line('Coop: '|| r_cop.cdcooper);
    --
    PGTA0001.pc_gera_retorno_tit_pago(pr_cdcooper => r_cop.cdcooper
                                    , pr_dtmvtolt => to_date('09052019','ddmmyyyy')
                                    , pr_idorigem => 3    -- Ayllos
                                    , pr_cdoperad => '1'
                                    , pr_cdcritic => vr_cdcritic
                                    , pr_dscritic => vr_dscritic );

    IF trim(vr_dscritic) is not null then
      dbms_output.put_line('Erro: '|| vr_dscritic);
    else 
      dbms_output.put_line('>>>>> Sucesso <<<<<');
    end if;
    --
    commit;
    --
  end loop;
  --
  commit;
  --
end;
