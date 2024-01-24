BEGIN
  UPDATE cobranca.tbcobran_ailosmais_conta_corrente a
    SET nrconta_corrente = 17708796
WHERE a.idailosmais_conta_corrente = '0FB124CE29540660E0630ACC8206B2F5';
  COMMIT;
exception
  when others then
    raise_application_error(-20000, 'erro ao inserir dados: ' || sqlerrm);
end;
