BEGIN

  UPDATE crapprm p
    SET p.dsvlrprm = 'emanuele.schatz@ailos.coop.br'
  WHERE
    p.cdacesso LIKE '%EMAIL_TESTE%';
  COMMIT;

exception
  when others then
    raise_application_error(-20000, 'erro ao inserir dados: ' || sqlerrm);
end;
