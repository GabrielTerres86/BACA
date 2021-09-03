BEGIN
  INSERT INTO crapprm
    (nmsistem
    ,cdcooper
    ,cdacesso
    ,dstexprm
    ,dsvlrprm)
  VALUES
    ('CRED'
    ,0
    ,'EMAIL_RECEB_TED_PRONAMPE'
    ,'Email das pessoas que recebem as divergências dos TED recebidos do FGO Pronampe'
    ,'estrategiadecobranca@ailos.coop.br');
  COMMIT;
END;