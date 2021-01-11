--primeiro limpa os dados antigos da tabela depois executa a procedure que gera os tokens
delete from TBEVENTO_PESSOA_TOKEN;
commit;
begin
 cecred.pc_mng_pessoa_token(tpoperacao => 1);
end;
commit;
/