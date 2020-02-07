-- Insere o Parametro indicando a data de ativação da nova reciprocidade
    INSERT INTO crapprm
      (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES
      ('CRED',
       3,
       'DT_CUSTAS_CARTORARIAS',
       'Data de vigencia para nao cobrar custas cartorarias.',
       '02/12/2019');
       
COMMIT;       
