begin

  UPDATE crapprm
     SET dsvlrprm = 'https://apiaymaruhml.cecred.coop.br/BarramentoTest/api/Ayllos'
   WHERE nmsistem = 'CRED'
     AND cdcooper = 0
     AND cdacesso = 'ENDERECO.AYMARU';
  commit;
end;