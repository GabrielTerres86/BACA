BEGIN
  
  insert into CECRED.TBGEN_CHAVES_CRYPTO (cdacesso, dtinicio_vigencia, dschave_crypto, dsserie_chave)
  values ('PCPS_CHAVE_PUBLICA_CIP', TRUNC(SYSDATE), '-----BEGIN PUBLIC KEY-----' || chr(10) 
												|| 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqt1w2EQW50c8YozC+Yid' || chr(10)
												|| 'InQGXv97z4FQGRJLVZ8zYP8xtz/DBpRFNg+zZfXKCDla226wHBBNkZSzTc0WWjmd' || chr(10)
												|| 'IVWmB49asG6tkdAHtJmb5nK+iRXpJivwiAwZR/FJdRljyEEy/7VBC48X+0XZ8FtQ' || chr(10)
												|| 'Qp0YGaCAz3tqAxqjXCYKFfLA+9drAB9DAyO0x7qgMW3np88J8zEXQ/uFvcHYnAW/' || chr(10)
												|| 'oc/B2rZd81KQF88+gnvk+AOGkX/tzBsCwg/LTYLmALSEnfo0VUaK+Ba1T1MK2DNr' || chr(10)
												|| 'YRmnl0++0CQfIKCt6xP4UQPBhpJNmn0LgN8sxiYNr6pbh1tMKTphpSTpETiLggzf' || chr(10)
												|| 'MwIDAQAB' || chr(10)
												|| '-----END PUBLIC KEY-----', '2DAFD83CED96E31F');
  
  commit;

END;
