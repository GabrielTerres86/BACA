begin  
  --#######################################################################################################################################
  --
  -- 
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de parametros';
    begin
	
		--Guarda o limite de envio de email quando ocorre problema na comunicacao com o bancoob. Nova proposta e alteracao limite
		INSERT INTO tbcartao_limite_operacional (   nmsistem  ,cdcooper  ,cdacesso  ,dstexprm  ,dsvlrprm  ) 
		VALUES (  'CRED'  ,3  ,'QTD_ERR_EMAIL_BANCOOB'  ,'Guarda o limite de envio de email quando ocorre problema na comunicacao com o bancoob. Nova proposta e alteracao limite'  ,to_char(to_date(TRUNC(SYSDATE), 'DD/MM/RRRR')) || ';0'  );

		--Quantidade de envios de email com erro do bancoob por dia.
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 1, 'QTD_EMAIL_ERR_BANCOOB', 'Quantidade de envios de email com erro do bancoob por dia.', '10');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 2, 'QTD_EMAIL_ERR_BANCOOB', 'Quantidade de envios de email com erro do bancoob por dia.', '10');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 3, 'QTD_EMAIL_ERR_BANCOOB', 'Quantidade de envios de email com erro do bancoob por dia.', '10');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 4, 'QTD_EMAIL_ERR_BANCOOB', 'Quantidade de envios de email com erro do bancoob por dia.', '10');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 5, 'QTD_EMAIL_ERR_BANCOOB', 'Quantidade de envios de email com erro do bancoob por dia.', '10');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 6, 'QTD_EMAIL_ERR_BANCOOB', 'Quantidade de envios de email com erro do bancoob por dia.', '10');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 7, 'QTD_EMAIL_ERR_BANCOOB', 'Quantidade de envios de email com erro do bancoob por dia.', '10');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 8, 'QTD_EMAIL_ERR_BANCOOB', 'Quantidade de envios de email com erro do bancoob por dia.', '10');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 9, 'QTD_EMAIL_ERR_BANCOOB', 'Quantidade de envios de email com erro do bancoob por dia.', '10');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 10, 'QTD_EMAIL_ERR_BANCOOB', 'Quantidade de envios de email com erro do bancoob por dia.', '10');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 11, 'QTD_EMAIL_ERR_BANCOOB', 'Quantidade de envios de email com erro do bancoob por dia.', '10');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 12, 'QTD_EMAIL_ERR_BANCOOB', 'Quantidade de envios de email com erro do bancoob por dia.', '10');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 13, 'QTD_EMAIL_ERR_BANCOOB', 'Quantidade de envios de email com erro do bancoob por dia.', '10');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 14, 'QTD_EMAIL_ERR_BANCOOB', 'Quantidade de envios de email com erro do bancoob por dia.', '10');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 15, 'QTD_EMAIL_ERR_BANCOOB', 'Quantidade de envios de email com erro do bancoob por dia.', '10');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 16, 'QTD_EMAIL_ERR_BANCOOB', 'Quantidade de envios de email com erro do bancoob por dia.', '10');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 17, 'QTD_EMAIL_ERR_BANCOOB', 'Quantidade de envios de email com erro do bancoob por dia.', '10');	  
	
		--Email para receber informacao de quando ocorrer erro na comunicacao com o bancoob  
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 1, 'EMAIL_ERR_CON_BANCOOB', 'Email para receber informacao de quando ocorrer erro na comunicacao com o bancoob', 'otavio.theiss@ailos.coop.br');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 2, 'EMAIL_ERR_CON_BANCOOB', 'Email para receber informacao de quando ocorrer erro na comunicacao com o bancoob', 'otavio.theiss@ailos.coop.br');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 3, 'EMAIL_ERR_CON_BANCOOB', 'Email para receber informacao de quando ocorrer erro na comunicacao com o bancoob', 'otavio.theiss@ailos.coop.br');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 4, 'EMAIL_ERR_CON_BANCOOB', 'Email para receber informacao de quando ocorrer erro na comunicacao com o bancoob', 'otavio.theiss@ailos.coop.br');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 5, 'EMAIL_ERR_CON_BANCOOB', 'Email para receber informacao de quando ocorrer erro na comunicacao com o bancoob', 'otavio.theiss@ailos.coop.br');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 6, 'EMAIL_ERR_CON_BANCOOB', 'Email para receber informacao de quando ocorrer erro na comunicacao com o bancoob', 'otavio.theiss@ailos.coop.br');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 7, 'EMAIL_ERR_CON_BANCOOB', 'Email para receber informacao de quando ocorrer erro na comunicacao com o bancoob', 'otavio.theiss@ailos.coop.br');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 8, 'EMAIL_ERR_CON_BANCOOB', 'Email para receber informacao de quando ocorrer erro na comunicacao com o bancoob', 'otavio.theiss@ailos.coop.br');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 9, 'EMAIL_ERR_CON_BANCOOB', 'Email para receber informacao de quando ocorrer erro na comunicacao com o bancoob', 'otavio.theiss@ailos.coop.br');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 10, 'EMAIL_ERR_CON_BANCOOB', 'Email para receber informacao de quando ocorrer erro na comunicacao com o bancoob', 'otavio.theiss@ailos.coop.br');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 11, 'EMAIL_ERR_CON_BANCOOB', 'Email para receber informacao de quando ocorrer erro na comunicacao com o bancoob', 'otavio.theiss@ailos.coop.br');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 12, 'EMAIL_ERR_CON_BANCOOB', 'Email para receber informacao de quando ocorrer erro na comunicacao com o bancoob', 'otavio.theiss@ailos.coop.br');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 13, 'EMAIL_ERR_CON_BANCOOB', 'Email para receber informacao de quando ocorrer erro na comunicacao com o bancoob', 'otavio.theiss@ailos.coop.br');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 14, 'EMAIL_ERR_CON_BANCOOB', 'Email para receber informacao de quando ocorrer erro na comunicacao com o bancoob', 'otavio.theiss@ailos.coop.br');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 15, 'EMAIL_ERR_CON_BANCOOB', 'Email para receber informacao de quando ocorrer erro na comunicacao com o bancoob', 'otavio.theiss@ailos.coop.br');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 16, 'EMAIL_ERR_CON_BANCOOB', 'Email para receber informacao de quando ocorrer erro na comunicacao com o bancoob', 'otavio.theiss@ailos.coop.br');
		INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES ('CRED', 17, 'EMAIL_ERR_CON_BANCOOB', 'Email para receber informacao de quando ocorrer erro na comunicacao com o bancoob', 'otavio.theiss@ailos.coop.br');
	  
	  
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
end;

