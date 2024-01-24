BEGIN
  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio
    ,dhregistro)
  VALUES
    (11708796
    ,1
    ,'RECUPERACAO_BOLETO'
    ,SYSDATE);
  COMMIT;
exception
  when others then
    raise_application_error(-20000, 'erro ao inserir dados: ' || sqlerrm);
end;
