begin 
  -- Participantes indiretos
  insert into tbpix_participante_indireto (nrispbif,cdcooper,nrdocnpj,nmpartici,dtinicio_utiliza,idativo)
  select 82639451,1,nrdocnpj,nmrescop,trunc(sysdate),'S' from tbpix_crapcop where cdcooper = 1;
  
  insert into tbpix_participante_indireto (nrispbif,cdcooper,nrdocnpj,nmpartici,dtinicio_utiliza,idativo)
  select 03461243,2,nrdocnpj,nmrescop,trunc(sysdate),'S' from tbpix_crapcop where cdcooper = 2;  
  
  insert into tbpix_participante_indireto (nrispbif,cdcooper,nrdocnpj,nmpartici,dtinicio_utiliza,idativo)
  select 16779741,16,nrdocnpj,nmrescop,trunc(sysdate),'S' from tbpix_crapcop where cdcooper = 16;  

  insert into tbpix_participante_indireto (nrispbif,cdcooper,nrdocnpj,nmpartici,dtinicio_utiliza,idativo)
  select 03427097,5,nrdocnpj,nmrescop,trunc(sysdate),'S' from tbpix_crapcop where cdcooper = 5;  

  insert into tbpix_participante_indireto (nrispbif,cdcooper,nrdocnpj,nmpartici,dtinicio_utiliza,idativo)
  select 10218474,13,nrdocnpj,nmrescop,trunc(sysdate),'S' from tbpix_crapcop where cdcooper = 13;  

  insert into tbpix_participante_indireto (nrispbif,cdcooper,nrdocnpj,nmpartici,dtinicio_utiliza,idativo)
  select 05979692,7,nrdocnpj,nmrescop,trunc(sysdate),'S' from tbpix_crapcop where cdcooper = 7;  

  insert into tbpix_participante_indireto (nrispbif,cdcooper,nrdocnpj,nmpartici,dtinicio_utiliza,idativo)
  select 08850613,8,nrdocnpj,nmrescop,trunc(sysdate),'S' from tbpix_crapcop where cdcooper = 8;  

  insert into tbpix_participante_indireto (nrispbif,cdcooper,nrdocnpj,nmpartici,dtinicio_utiliza,idativo)
  select 09590601,10,nrdocnpj,nmrescop,trunc(sysdate),'S' from tbpix_crapcop where cdcooper = 10;  

  insert into tbpix_participante_indireto (nrispbif,cdcooper,nrdocnpj,nmpartici,dtinicio_utiliza,idativo)
  select 02405189,6,nrdocnpj,nmrescop,trunc(sysdate),'S' from tbpix_crapcop where cdcooper = 6;  

  insert into tbpix_participante_indireto (nrispbif,cdcooper,nrdocnpj,nmpartici,dtinicio_utiliza,idativo)
  select 09512539,11,nrdocnpj,nmrescop,trunc(sysdate),'S' from tbpix_crapcop where cdcooper = 11;  

  insert into tbpix_participante_indireto (nrispbif,cdcooper,nrdocnpj,nmpartici,dtinicio_utiliza,idativo)
  select 10143743,12,nrdocnpj,nmrescop,trunc(sysdate),'S' from tbpix_crapcop where cdcooper = 12;  

  insert into tbpix_participante_indireto (nrispbif,cdcooper,nrdocnpj,nmpartici,dtinicio_utiliza,idativo)
  select 10311218,14,nrdocnpj,nmrescop,trunc(sysdate),'S' from tbpix_crapcop where cdcooper = 14;  

  insert into tbpix_participante_indireto (nrispbif,cdcooper,nrdocnpj,nmpartici,dtinicio_utiliza,idativo)
  select 08075352,9,nrdocnpj,nmrescop,trunc(sysdate),'S' from tbpix_crapcop where cdcooper = 9;  

  -- Criação dos tipos de chave 
  insert into tbpix_chave_tipos (IDTIPO_CHAVE, DSTIPO, IDSITUACAO, DSMENSAGEM)
  values (1, 'Telefone Celular', 'A', null);
  insert into tbpix_chave_tipos (IDTIPO_CHAVE, DSTIPO, IDSITUACAO, DSMENSAGEM)
  values (2, 'E-mail', 'A', null);
  insert into tbpix_chave_tipos (IDTIPO_CHAVE, DSTIPO, IDSITUACAO, DSMENSAGEM)
  values (3, 'CPF/CNPJ', 'A', null);
  insert into tbpix_chave_tipos (IDTIPO_CHAVE, DSTIPO, IDSITUACAO, DSMENSAGEM)
  values (4, 'Endereço Virtual de Pagamento (EVP)', 'A', null);

  -- Criação dos domínios
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_SITUACAO_CHAVE', 'I', 'Em inclusão');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_SITUACAO_CHAVE', 'A', 'Ativa');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_SITUACAO_CHAVE', 'C', 'Cancelada');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_SITUACAO_CHAVE', 'E', 'Em cancelamento');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_SITUACAO_CHAVE', 'P', 'Portabilidade');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_SITUACAO_CHAVE', 'R', 'Reivindicação');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVO_CANCELA_CHAVE', '0', 'Solicitação do usuário');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVO_CANCELA_CHAVE', '1', 'Encerramento de conta');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVO_CANCELA_CHAVE', '2', 'Encerramento de titularidade');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVO_CANCELA_CHAVE', '3', 'Inatividade de uso');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVO_CANCELA_CHAVE', '4', 'Tentativa ou efetivação de uso fraudulento');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVO_CANCELA_CHAVE', '5', 'Chave cadastrada em outra instituição ');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVO_CANCELA_CHAVE', '6', 'Reinvidicação de Posse em outra IF');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVO_CANCELA_CHAVE', '7', 'Portabilidade para outra IF');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVO_CANCELA_CHAVE', '8', 'Reinvidicação não finalizada');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVO_CANCELA_CHAVE', '9', 'Portabilidade não finalizada');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVO_CANCELA_CHAVE', '10', 'Inconsistência no processo de sincronismo');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_SITUACAO_TRANSFERE_POSSE', '0', 'Aberta');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_SITUACAO_TRANSFERE_POSSE', '1', 'Aguardando Resolução');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_SITUACAO_TRANSFERE_POSSE', '2', 'Confirmada');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_SITUACAO_TRANSFERE_POSSE', '3', 'Cancelada');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_SITUACAO_TRANSFERE_POSSE', '4', 'Concluída');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVO_RESP_TRANSFE_POSSE', '0', 'Por solicitação do usuário');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVO_RESP_TRANSFE_POSSE', '1', 'Encerramento de conta');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVO_RESP_TRANSFE_POSSE', '2', 'Pelo doador');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVO_RESP_TRANSFE_POSSE', '3', 'Decurso de prazo');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVO_RESP_TRANSFE_POSSE', '4', 'Indício de fraude');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVO_RESP_TRANSFE_POSSE', '5', 'Pelo reivindicador');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVOS_DEVOLUCAO', 'AM05', 'Ordem de pagamento em duplicidade');  
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVOS_DEVOLUCAO', 'AM09', 'Devolução devido ao valor recebido não estar de acordo com o esperado');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVOS_DEVOLUCAO', 'BE08', 'Devolução devido a um erro do PSP');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVOS_DEVOLUCAO', 'DS28', 'Devolução após problemas técnicos, resultando em transação incorreta');  
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVOS_DEVOLUCAO', 'FOCR', 'Devolução após solicitação de cancelamento da transação');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVOS_DEVOLUCAO', 'FR01', 'Devolução devido a fraude no pagamento');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVOS_DEVOLUCAO', 'MD06', 'Devolução solicitado pelo usuário recebedor do pagamento original');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVOS_DEVOLUCAO', 'RUTA', 'Devolução após a solicitação de investigação');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVOS_DEVOLUCAO', 'SL11', 'Usuário do recebedor não faz parte da Whitelist com o usuário do pagador');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVOS_DEVOLUCAO', 'SL12', 'Usuário do recebedor incluída na Blacklist do usuário do pagador');
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVOS_DEVOLUCAO', 'UPAY', 'Ordem de pagamento não justificada');  
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVOS_DEVOLUCAO', 'NARR', 'Código de erro genérico');  
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVOS_DEVO_COOPERADO', 'FOCR', 'PIX não aceito pelo recebedor');  
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVOS_DEVO_COOPERADO', 'FR01', 'Fraude identificada');    
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVOS_DEVO_COOPERADO', 'AM05', 'Ordem de pagamento em duplicidade');    
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVOS_DEVO_COOPERADO', 'AM09', 'Ordem de pagamento em duplicidade');      
  insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('PIX_MOTIVOS_DEVO_COOPERADO', 'MD06', 'Desistência do pagador'); 				  

  commit;
  
end;  
