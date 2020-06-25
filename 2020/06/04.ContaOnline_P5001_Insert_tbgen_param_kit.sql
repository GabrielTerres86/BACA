begin
  
  insert into tbgen_param_kit (DSURLSERVER, NMUSUARIO, CDDSENHA)
  values ('https://conteudohml2.cecred.coop.br/kit_materiais/', 'conteudo', '8974e8c1acb');

  insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  values('CRED',0,'PRM_VALIDACAO_500', 'Parametro para validar se o piloto está ativo', 1);
  
  commit;
end;
  
