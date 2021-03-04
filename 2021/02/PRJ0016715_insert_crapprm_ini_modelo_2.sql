BEGIN
  INSERT INTO cecred.crapprm p
    (nmsistem
    ,cdcooper
    ,cdacesso
    ,dstexprm
    ,dsvlrprm)
  VALUES
    ('CRED'
    ,0
    ,'INIC_GERA_ACOR_3040_MOD2'
    ,'Data inicio da geração acordo modelo modelo 2'
    ,trunc(SYSDATE));
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20100,
                            'Erro na criação de parametro - ' || SQLERRM);
END;
