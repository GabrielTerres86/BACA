BEGIN

  UPDATE crapprm p
    SET p.dsvlrprm = 'envolti-andreia.brancher@ailos.coop.br'
  WHERE
    p.cdacesso LIKE '%EMAIL_TESTE%';
  COMMIT;

exception
  when others then
    raise_application_error(-20000, 'erro ao inserir dados: ' || sqlerrm);
end;
