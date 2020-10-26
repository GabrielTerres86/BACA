begin 
  
  -- Carregar codigo do banco nas cooperativas
  update aimaro.tbpix_crapcop set cdbcoctl = 85;
  
  -- Mudar EVP para Chave Aleat�ria
  Update pix.tbpix_chave_tipos 
     set dstipo = 'Chave Aleat�ria'
   where idtipo_chave = 4
  
  -- Remover an�lises com valor zerado
  update pix.tbpix_transacao 
     set idanalise_fraude = null
   where idanalise_fraude = 0;
  
  -- Tabela de tipos de transa��o --
  insert into pix.tbpix_tipo_transacao (IDTIPO_TRANSACAO, NMTIPO_TRANSACAO, IDSITUACAO, NRDOLOTE, CDHISTOR, CDHISTOR_ESTORNO, NRDOLOTE_ESTORNO, CDTIPO_PROTOCOLO, CDHISTOR_ESTORNO_OFSAA, NRDOLOTE_ESTORNO_OFSAA, CDHISTOR_COOP, NRDOLOTE_COOP, CDHISTOR_ESTORNO_OFSAA_COOP, NRDOLOTE_ESTORNO_OFSAA_COOP)
  values ('P', 'Pagamento', 'A', 700001, 3320, 3323, 700002, 34, 3322, 700006, 3371, 700007, 3379, 700008);

  insert into pix.tbpix_tipo_transacao (IDTIPO_TRANSACAO, NMTIPO_TRANSACAO, IDSITUACAO, NRDOLOTE, CDHISTOR, CDHISTOR_ESTORNO, NRDOLOTE_ESTORNO, CDTIPO_PROTOCOLO, CDHISTOR_ESTORNO_OFSAA, NRDOLOTE_ESTORNO_OFSAA, CDHISTOR_COOP, NRDOLOTE_COOP, CDHISTOR_ESTORNO_OFSAA_COOP, NRDOLOTE_ESTORNO_OFSAA_COOP)
  values ('R', 'Recebimento', 'A', 700004, 3318, null, null, null, 0, null, 3373, 700009, null, null);

  insert into pix.tbpix_tipo_transacao (IDTIPO_TRANSACAO, NMTIPO_TRANSACAO, IDSITUACAO, NRDOLOTE, CDHISTOR, CDHISTOR_ESTORNO, NRDOLOTE_ESTORNO, CDTIPO_PROTOCOLO, CDHISTOR_ESTORNO_OFSAA, NRDOLOTE_ESTORNO_OFSAA, CDHISTOR_COOP, NRDOLOTE_COOP, CDHISTOR_ESTORNO_OFSAA_COOP, NRDOLOTE_ESTORNO_OFSAA_COOP)
  values ('D', 'Devolu��o Enviada', 'A', 700005, 3319, 3323, 700002, 35, 0, null, 3375, 700010, null, null);

  insert into pix.tbpix_tipo_transacao (IDTIPO_TRANSACAO, NMTIPO_TRANSACAO, IDSITUACAO, NRDOLOTE, CDHISTOR, CDHISTOR_ESTORNO, NRDOLOTE_ESTORNO, CDTIPO_PROTOCOLO, CDHISTOR_ESTORNO_OFSAA, NRDOLOTE_ESTORNO_OFSAA, CDHISTOR_COOP, NRDOLOTE_COOP, CDHISTOR_ESTORNO_OFSAA_COOP, NRDOLOTE_ESTORNO_OFSAA_COOP)
  values ('E', 'Devolu��o Recebida', 'A', 700003, 3321, null, null, null, 0, null, 3377, 700011, null, null);

  ------------------------------------------------- Fases ------------------------------------------------------------------------------
  insert into pix.tbpix_tipo_fase (idfase,nmfase,idsituacao) values (01,'Registro PSP Pagador','A'); 
  insert into pix.tbpix_tipo_fase (idfase,nmfase,idsituacao) values (02,'Registro Cabine JDPI','A');
  insert into pix.tbpix_tipo_fase (idfase,nmfase,idsituacao) values (03,'Registro API PIX','A');
  insert into pix.tbpix_tipo_fase (idfase,nmfase,idsituacao) values (04,'Registro Cr�dito Conta','A');
  insert into pix.tbpix_tipo_fase (idfase,nmfase,idsituacao) values (05,'Registro D�bito em Conta','A');
  insert into pix.tbpix_tipo_fase (idfase,nmfase,idsituacao) values (06,'Envio An�lise OFSAA','A');
  insert into pix.tbpix_tipo_fase (idfase,nmfase,idsituacao) values (07,'Registro API Transacional','A');
  insert into pix.tbpix_tipo_fase (idfase,nmfase,idsituacao) values (08,'Consulta do Status da Transa��o','A');
  insert into pix.tbpix_tipo_fase (idfase,nmfase,idsituacao) values (09,'OFSAA desativado','A');
  insert into pix.tbpix_tipo_fase (idfase,nmfase,idsituacao) values (10,'Notifica��o Cooperado','A');
  insert into pix.tbpix_tipo_fase (idfase,nmfase,idsituacao) values (11,'Estorno de d�bito n�o confirmado','A');
  insert into pix.tbpix_tipo_fase (idfase,nmfase,idsituacao) values (12,'Retorno An�lise OFSAA (Auto)','A');
  insert into pix.tbpix_tipo_fase (idfase,nmfase,idsituacao) values (13,'Retorno An�lise OFSAA (Manual)','A');
  insert into pix.tbpix_tipo_fase (idfase,nmfase,idsituacao) values (14,'Efetiva��o BACEN','A');
  insert into pix.tbpix_tipo_fase (idfase,nmfase,idsituacao) values (15,'Situa��o final da Transa��o','A');
  insert into pix.tbpix_tipo_fase (idfase,nmfase,idsituacao) values (16, 'Confirma��o Lan�amento em Conta', 'A');
  insert into pix.tbpix_tipo_fase (idfase,nmfase,idsituacao) values (17, 'Valida��o de Recebimentos', 'A');
  insert into pix.tbpix_tipo_fase (idfase,nmfase,idsituacao) values (18, 'Efetiva��o INTER/INTRA cooperativa', 'A');
  insert into pix.tbpix_tipo_fase (idfase,nmfase,idsituacao) values (19, 'Avalia��o dos cr�ditos do cooperado', 'A');

  
  --- Vinculo Fases a Transa��o de Recebimento 
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (1,'R',17,null,'S',null);  
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (2,'R',1,1,'N',null);
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (3,'R',7,2,'N',null);
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (4,'R',4,3,'S',null);
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (5,'R',10,4,'S',null);   
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (6,'R',16,4,'S',null);   


  --- Vinculo Fases a Transa��o de Recebimento de Devolu��o 
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (10,'E',17,null,'S',null);  
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (11,'E',1,10,'N',null);
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (12,'E',7,11,'N',null);
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (13,'E',4,12,'S',null);
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (14,'E',10,13,'S',null);   
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (15,'E',16,13,'S',null);  				  
				  

  --- Vinculo Fases a Transa��o de Devolu��o para o Pagador 
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (20,'D',3,null,'N',null);
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (21,'D',7,20,'N',null);
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (22,'D',5,21,'S',null);
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (23,'D',2,22,'N',null);
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (24,'D',8,23,'N',null);
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (25,'D',11,24,'S',null);  
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (26,'D',14,24,'S',null);
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (27,'D',6,26,'N',null);                
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (29,'D',16,22,'S',null);   	
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (50,'D',18,22,'S',null);	
	
				  

  --- Vinculo Fases a Transa��o de Pagamento 
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (30,'P',3,null,'N',null);
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (31,'P',7,30,'N',null);
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (32,'P',5,31,'S',null);
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (33,'P',6,32,'S',null);
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (34,'P',9,33,'S',null);
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (35,'P',12,34,'S',null);
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (36,'P',13,35,'S',null);                
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (41,'P',11,36,'S',null);      
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (37,'P',2,36,'N',null);
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (38,'P',8,37,'N',null);
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (39,'P',14,38,'S',null);
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (40,'P',15,39,'N',null);
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (44,'P',16,32,'S',null);   	
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (47,'P',18,32,'S',null);					  
  insert into pix.tbpix_tipo_fase_transacao(idsequen,idtipo_transacao,idfase,idsequen_anterior,flfase_auditada,qtsegundo_maximo) 
                  values (48,'P',19,47,'N',null);					  
  
  -- Dominios com caracteres invalidos
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Em inclus�o' WHERE NMDOMINIO = 'PIX_SITUACAO_CHAVE' AND CDDOMINIO = 'I';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Reivindica��o' WHERE NMDOMINIO = 'PIX_SITUACAO_CHAVE' AND CDDOMINIO = 'R';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Solicita��o do usu�rio' WHERE NMDOMINIO = 'PIX_MOTIVO_CANCELA_CHAVE' AND CDDOMINIO = '0';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Tentativa ou efetiva��o de uso fraudulento' WHERE NMDOMINIO = 'PIX_MOTIVO_CANCELA_CHAVE' AND CDDOMINIO = '4';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Chave cadastrada em outra institui��o ' WHERE NMDOMINIO = 'PIX_MOTIVO_CANCELA_CHAVE' AND CDDOMINIO = '5';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Reinvidica��o de Posse em outra IF' WHERE NMDOMINIO = 'PIX_MOTIVO_CANCELA_CHAVE' AND CDDOMINIO = '6';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Reinvidica��o n�o finalizada' WHERE NMDOMINIO = 'PIX_MOTIVO_CANCELA_CHAVE' AND CDDOMINIO = '8';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Portabilidade n�o finalizada' WHERE NMDOMINIO = 'PIX_MOTIVO_CANCELA_CHAVE' AND CDDOMINIO = '9';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Inconsist�ncia no processo de sincronismo' WHERE NMDOMINIO = 'PIX_MOTIVO_CANCELA_CHAVE' AND CDDOMINIO = '10';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Aguardando Resolu��o' WHERE NMDOMINIO = 'PIX_SITUACAO_TRANSFERE_POSSE' AND CDDOMINIO = '1';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Conclu�da' WHERE NMDOMINIO = 'PIX_SITUACAO_TRANSFERE_POSSE' AND CDDOMINIO = '4';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Por solicita��o do usu�rio' WHERE NMDOMINIO = 'PIX_MOTIVO_RESP_TRANSFE_POSSE' AND CDDOMINIO = '0';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Ind�cio de fraude' WHERE NMDOMINIO = 'PIX_MOTIVO_RESP_TRANSFE_POSSE' AND CDDOMINIO = '4';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Devolu��o devido ao valor recebido n�o estar de acordo com o esperado' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVOLUCAO' AND CDDOMINIO = 'AM09';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Devolu��o devido a um erro do PSP' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVOLUCAO' AND CDDOMINIO = 'BE08';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Devolu��o ap�s problemas t�cnicos, resultando em transa��o incorreta' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVOLUCAO' AND CDDOMINIO = 'DS28';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Devolu��o ap�s solicita��o de cancelamento da transa��o' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVOLUCAO' AND CDDOMINIO = 'FOCR';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Devolu��o devido a fraude no pagamento' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVOLUCAO' AND CDDOMINIO = 'FR01';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Devolu��o solicitado pelo usu�rio recebedor do pagamento original' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVOLUCAO' AND CDDOMINIO = 'MD06';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Devolu��o ap�s a solicita��o de investiga��o' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVOLUCAO' AND CDDOMINIO = 'RUTA';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Usu�rio do recebedor n�o faz parte da Whitelist com o usu�rio do pagador' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVOLUCAO' AND CDDOMINIO = 'SL11';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Usu�rio do recebedor inclu�da na Blacklist do usu�rio do pagador' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVOLUCAO' AND CDDOMINIO = 'SL12';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Ordem de pagamento n�o justificada' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVOLUCAO' AND CDDOMINIO = 'UPAY';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'C�digo de erro gen�rico' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVOLUCAO' AND CDDOMINIO = 'NARR';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Pix n�o aceito pelo recebedor' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVO_COOPERADO' AND CDDOMINIO = 'FOCR';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Devolu��o devido ao valor recebido n�o estar de acordo com o esperado' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVO_COOPERADO' AND CDDOMINIO = 'AM09';
  UPDATE pix.tbpix_dominio_campo SET DSCODIGO = 'Desist�ncia do pagador' WHERE NMDOMINIO = 'PIX_MOTIVOS_DEVO_COOPERADO' AND CDDOMINIO = 'MD06';
				  

  commit;
  
end;  
