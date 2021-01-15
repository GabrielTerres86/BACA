begin

  insert into tbgen_param_kit (DSURLSERVER, NMUSUARIO, CDDSENHA)
  values ('https://conteudo.cecred.coop.br/kit_materiais/', 'conteudo', 'c0n10.t3u1d70');

  insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  values('CRED',0,'PRM_VALIDACAO_500', 'Parametro para validar se o piloto está ativo', 1);
  
  commit;

end;
  
