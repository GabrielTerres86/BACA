begin
  insert into tbcontab_prm_risco_slip
  select trim(t.cdrisco_operacional)
       , t.dsrisco_operacional
       , t.idativo
    from tbcontab_prm_risco_slip t
   where t.cdrisco_operacional <> trim(t.cdrisco_operacional)
     and not exists (select 1
                       from tbcontab_prm_risco_slip t2
                      where t2.cdrisco_operacional = trim(t.cdrisco_operacional));
  
  update tbcontab_prm_risco_cta_slip t
     set t.cdrisco_operacional = trim(t.cdrisco_operacional)
   where t.cdrisco_operacional <> trim(t.cdrisco_operacional)
     and not exists (select 1
                      from tbcontab_prm_risco_cta_slip t2
                     where t2.cdrisco_operacional = trim(t.cdrisco_operacional)
                       and t2.nrconta_contabil = t.nrconta_contabil);

  delete tbcontab_prm_risco_cta_slip t
   where t.cdrisco_operacional <> trim(t.cdrisco_operacional);

  delete tbcontab_prm_risco_slip t
   where t.cdrisco_operacional <> trim(t.cdrisco_operacional);

  update tbcontab_prm_risco_slip t
     set t.dsrisco_operacional = 'FURTO DE ENVELOPE COM VALORES PARA DEPOSITO'
       , t.idativo = 'S'
   where t.cdrisco_operacional = 'RO.02.01.005';

  commit;
exception
  when others then
    raise_application_error(-20001,'Erro ao ajustar parâmetros SLIP. Erro: '||sqlerrm);
end;
