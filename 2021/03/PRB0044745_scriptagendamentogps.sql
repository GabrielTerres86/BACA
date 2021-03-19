-- Created on 25/11/2020 by F003098
declare 
  vr_exc_erro exception;
  -- Local variables here
  cursor cr_agdmto_gps is
    select 
      a.cdcooper, 
      b.cdagenci, 
      a.dtmvtolt, 
      a.nrdconta, 
      a.nrdocmto, 
      a.vllanaut, 
      a.dtdebito, 
      to_char(a.dscodbar), 
      a.insitlau, 
      decode(a.insitlau, 1,'Pendente', 2, 'Pendente', 3, 'Cancelado', 4, 'Nao Efetivado') as stastus,
      (select count(*) from craplgp g where g.cdcooper = a.cdcooper and g.nrctapag = a.nrdconta and g.vlrtotal = a.vllanaut and g.dtmvtolt = a.dtmvtolt and a.nrdocmto = g.nrseqdig) as lgp,
      (select count(*) from tbinss_agendamento_gps t where t.cdcooper = 1 and t.nrdconta = a.nrdconta and t.vltotal_gps = a.vllanaut and t.dtagendamento = a.dtmvtolt and t.dtdebito = a.dtdebito and t.dtpagamento is null) as inss
    from 
      craplau a 
      join crapass b on (a.cdcooper = b.cdcooper and a.nrdconta = b.nrdconta) 
    where 
      a.cdhistor = 540 -- GPS
      and a.dtmvtopg between '15/03/2021' and '17/03/2021'
      and (a.insitlau = 4 and a.dscritic like '%agendada%')
    order by 
      a.cdcooper, b.cdagenci, a.dtmvtopg, a.nrdconta;
  
begin
  for rw_reg_agdmto in cr_agdmto_gps loop
    begin  
      delete from craplgp 
      where 
        craplgp.cdcooper = rw_reg_agdmto.cdcooper and 
        craplgp.dtmvtolt = rw_reg_agdmto.dtmvtolt and 
        craplgp.nrctapag = rw_reg_agdmto.nrdconta and 
        craplgp.nrseqdig = rw_reg_agdmto.nrdocmto and 
        craplgp.vlrtotal = rw_reg_agdmto.vllanaut;
    exception
    when others then
    rollback;
      raise_application_error(-20001, 'Erro ao excluir registro craplgp -> ' ||sqlerrm);
    end;
  end loop;

  commit;
end;
