begin 
  
  -- Carregar codigo do banco nas cooperativas
  update tbpix_crapcop set cdbcoctl = 85;
  
  -- Mudar EVP para Chave Aleatória
  Update tbpix_chave_tipos 
     set dstipo = 'Chave Aleatória'
   where idtipo_chave = 4
  
  -- Remover análises com valor zerado
  update tbpix_transacao 
     set idanalise_fraude = null
   where idanalise_fraude = 0;
  
  -- Tabela de tipos de transação --
  insert into tbpix_tipo_transacao (IDTIPO_TRANSACAO, NMTIPO_TRANSACAO, IDSITUACAO, NRDOLOTE, CDHISTOR, CDHISTOR_ESTORNO, NRDOLOTE_ESTORNO, CDTIPO_PROTOCOLO, CDHISTOR_ESTORNO_OFSAA, NRDOLOTE_ESTORNO_OFSAA, CDHISTOR_COOP, NRDOLOTE_COOP, CDHISTOR_ESTORNO_OFSAA_COOP, NRDOLOTE_ESTORNO_OFSAA_COOP)
  values ('P', 'Pagamento', 'A', 700001, 3320, 3323, 700002, 34, 3322, 700006, 3371, 700007, 3379, 700008);

  insert into tbpix_tipo_transacao (IDTIPO_TRANSACAO, NMTIPO_TRANSACAO, IDSITUACAO, NRDOLOTE, CDHISTOR, CDHISTOR_ESTORNO, NRDOLOTE_ESTORNO, CDTIPO_PROTOCOLO, CDHISTOR_ESTORNO_OFSAA, NRDOLOTE_ESTORNO_OFSAA, CDHISTOR_COOP, NRDOLOTE_COOP, CDHISTOR_ESTORNO_OFSAA_COOP, NRDOLOTE_ESTORNO_OFSAA_COOP)
  values ('R', 'Recebimento', 'A', 700004, 3318, null, null, null, 0, null, 3373, 700009, null, null);

  insert into tbpix_tipo_transacao (IDTIPO_TRANSACAO, NMTIPO_TRANSACAO, IDSITUACAO, NRDOLOTE, CDHISTOR, CDHISTOR_ESTORNO, NRDOLOTE_ESTORNO, CDTIPO_PROTOCOLO, CDHISTOR_ESTORNO_OFSAA, NRDOLOTE_ESTORNO_OFSAA, CDHISTOR_COOP, NRDOLOTE_COOP, CDHISTOR_ESTORNO_OFSAA_COOP, NRDOLOTE_ESTORNO_OFSAA_COOP)
  values ('D', 'Devolução Enviada', 'A', 700005, 3319, 3323, 700002, 35, 0, null, 3375, 700010, null, null);

  insert into tbpix_tipo_transacao (IDTIPO_TRANSACAO, NMTIPO_TRANSACAO, IDSITUACAO, NRDOLOTE, CDHISTOR, CDHISTOR_ESTORNO, NRDOLOTE_ESTORNO, CDTIPO_PROTOCOLO, CDHISTOR_ESTORNO_OFSAA, NRDOLOTE_ESTORNO_OFSAA, CDHISTOR_COOP, NRDOLOTE_COOP, CDHISTOR_ESTORNO_OFSAA_COOP, NRDOLOTE_ESTORNO_OFSAA_COOP)
  values ('E', 'Devolução Recebida', 'A', 700003, 3321, null, null, null, 0, null, 3377, 700011, null, null);

  ------------------------------------------------- Fases ------------------------------------------------------------------------------
  insert into tbpix_tipo_fase (idfase,nmfase,idsituacao) values (01,'Registro PSP Pagador','A'); 
  insert into tbpix_tipo_fase (idfase,nmfase,idsituacao) values (02,'Registro Cabine JDPI','A');
  insert into tbpix_tipo_fase (idfase,nmfase,idsituacao) values (03,'Registro API PIX','A');
  insert into tbpix_tipo_fase (idfase,nmfase,idsituacao) values (04,'Registro Crédito Conta','A');
  insert into tbpix_tipo_fase (idfase,nmfase,idsituacao) values (05,'Registro Débito em Conta','A');
  insert into tbpix_tipo_fase (idfase,nmfase,idsituacao) values (06,'Envio Análise OFSAA','A');
  insert into tbpix_tipo_fase (idfase,nmfase,idsituacao) values (07,'Registro API Transacional','A');
  insert into tbpix_tipo_fase (idfase,nmfase,idsituacao) values (08,'Consulta do Status da Transação','A');
  insert into tbpix_tipo_fase (idfase,nmfase,idsituacao) values (09,'OFSAA desativado','A');
  insert into tbpix_tipo_fase (idfase,nmfase,idsituacao) values (10,'Notificação Cooperado','A');
  insert into tbpix_tipo_fase (idfase,nmfase,idsituacao) values (11,'Estorno de débito não confirmado','A');
  insert into tbpix_tipo_fase (idfase,nmfase,idsituacao) values (12,'Retorno Análise OFSAA (Auto)','A');
  insert into tbpix_tipo_fase (idfase,nmfase,idsituacao) values (13,'Retorno Análise OFSAA (Manual)','A');
  insert into tbpix_tipo_fase (idfase,nmfase,idsituacao) values (14,'Efetivação BACEN','A');
  insert into tbpix_tipo_fase (idfase,nmfase,idsituacao) values (15,'Situação final cabine JDPI','A');
  insert into tbpix_tipo_fase (idfase,nmfase,idsituacao) values (16, 'Confirmação Lançamento em Conta', 'A');
  insert into tbpix_tipo_fase (idfase,nmfase,idsituacao) values (17, 'Validação de Recebimentos', 'A');
  
  --- Vinculo Fases a Transação de Recebimento 
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (1,'R',17,null,'S',null);  
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (2,'R',1,1,'N',null);
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (3,'R',7,2,'N',null);
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (4,'R',4,3,'S',null);
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (5,'R',10,4,'S',null);   
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (6,'R',16,4,'S',null);   


  --- Vinculo Fases a Transação de Recebimento de Devolução 
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (10,'E',17,null,'S',null);  
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (11,'E',1,10,'N',null);
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (12,'E',7,11,'N',null);
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (13,'E',4,12,'S',null);
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (14,'E',10,13,'S',null);   
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (15,'E',16,13,'S',null);  				  
				  

  --- Vinculo Fases a Transação de Devolução para o Pagador 
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (20,'D',3,null,'N',null);
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (21,'D',7,20,'N',null);
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (22,'D',5,21,'S',null);
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (23,'D',2,22,'N',null);
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (24,'D',8,23,'N',null);
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (25,'D',11,24,'S',null);  
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (26,'D',14,24,'S',null);
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (27,'D',6,26,'N',null);                
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (29,'D',16,22,'S',null);   	
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (49,'D',16,25,'S',null);	

  --- Vinculo Fases a Transação de Pagamento 
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (30,'P',3,null,'N',null);
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (31,'P',7,30,'N',null);
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (32,'P',5,31,'S',null);
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (33,'P',6,32,'S',null);
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (34,'P',9,33,'S',null);
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (35,'P',12,34,'S',null);
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (36,'P',13,35,'S',null);                
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (41,'P',11,36,'S',null);      
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (37,'P',2,36,'N',null);
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (38,'P',8,37,'N',null);
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (42,'P',11,38,'S',null);  
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (39,'P',14,38,'S',null);
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (40,'P',15,39,'N',null);
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (44,'P',16,32,'S',null);   	
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (45,'P',16,41,'S',null);					  
  insert into tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (46,'P',16,42,'S',null);		
  
  -- Dominios com caracteres invalidos
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Em inclusão' WHERE NMDOMINIO = 'PIX_SITUACAO_CHAVE' AND CDDOMINIO = 'I';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Reivindicação' WHERE NMDOMINIO = 'PIX_SITUACAO_CHAVE' AND CDDOMINIO = 'R';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Solicitação do usuário' WHERE NMDOMINIO = 'PIX_MOTIVO_CANCELA_CHAVE' AND CDDOMINIO = '0';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Tentativa ou efetivação de uso fraudulento' WHERE NMDOMINIO = 'PIX_MOTIVO_CANCELA_CHAVE' AND CDDOMINIO = '4';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Chave cadastrada em outra instituição ' WHERE NMDOMINIO = 'PIX_MOTIVO_CANCELA_CHAVE' AND CDDOMINIO = '5';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Reinvidicação de Posse em outra IF' WHERE NMDOMINIO = 'PIX_MOTIVO_CANCELA_CHAVE' AND CDDOMINIO = '6';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Reinvidicação não finalizada' WHERE NMDOMINIO = 'PIX_MOTIVO_CANCELA_CHAVE' AND CDDOMINIO = '8';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Portabilidade não finalizada' WHERE NMDOMINIO = 'PIX_MOTIVO_CANCELA_CHAVE' AND CDDOMINIO = '9';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Inconsistência no processo de sincronismo' WHERE NMDOMINIO = 'PIX_MOTIVO_CANCELA_CHAVE' AND CDDOMINIO = '10';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Aguardando Resolução' WHERE NMDOMINIO = 'PIX_SITUACAO_TRANSFERE_POSSE' AND CDDOMINIO = '1';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Concluída' WHERE NMDOMINIO = 'PIX_SITUACAO_TRANSFERE_POSSE' AND CDDOMINIO = '4';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Por solicitação do usuário' WHERE NMDOMINIO = 'PIX_MOTIVO_RESP_TRANSFE_POSSE' AND CDDOMINIO = '0';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Indício de fraude' WHERE NMDOMINIO = 'PIX_MOTIVO_RESP_TRANSFE_POSSE' AND CDDOMINIO = '4';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Devolução devido ao valor recebido não estar de acordo com o esperado' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVOLUCAO' AND CDDOMINIO = 'AM09';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Devolução devido a um erro do PSP' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVOLUCAO' AND CDDOMINIO = 'BE08';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Devolução após problemas técnicos, resultando em transação incorreta' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVOLUCAO' AND CDDOMINIO = 'DS28';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Devolução após solicitação de cancelamento da transação' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVOLUCAO' AND CDDOMINIO = 'FOCR';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Devolução devido a fraude no pagamento' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVOLUCAO' AND CDDOMINIO = 'FR01';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Devolução solicitado pelo usuário recebedor do pagamento original' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVOLUCAO' AND CDDOMINIO = 'MD06';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Devolução após a solicitação de investigação' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVOLUCAO' AND CDDOMINIO = 'RUTA';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Usuário do recebedor não faz parte da Whitelist com o usuário do pagador' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVOLUCAO' AND CDDOMINIO = 'SL11';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Usuário do recebedor incluída na Blacklist do usuário do pagador' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVOLUCAO' AND CDDOMINIO = 'SL12';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Ordem de pagamento não justificada' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVOLUCAO' AND CDDOMINIO = 'UPAY';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Código de erro genérico' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVOLUCAO' AND CDDOMINIO = 'NARR';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Pix não aceito pelo recebedor' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVO_COOPERADO' AND CDDOMINIO = 'FOCR';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Devolução devido ao valor recebido não estar de acordo com o esperado' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVO_COOPERADO' AND CDDOMINIO = 'AM09';
  UPDATE tbpix_dominio_campo SET DSCODIGO = 'Desistência do pagador' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVO_COOPERADO' AND CDDOMINIO = 'MD06';
				  

  commit;
  
end;  
