begin
  update cecred.tbcontab_prm_risco_slip
  set idativo = 'S', dsrisco_operacional = 'FRAUDE POR ENGENHARIA SOCIAL - BILHETE PREMIADO'
  where cdrisco_operacional = 'RO.02.03.003';

  update cecred.tbcontab_prm_risco_slip
  set idativo = 'S', dsrisco_operacional = 'FRAUDE POR ENGENHARIA SOCIAL - FALSO COLABORADOR'
  where cdrisco_operacional = 'RO.02.03.004';
  
  commit;
end;
