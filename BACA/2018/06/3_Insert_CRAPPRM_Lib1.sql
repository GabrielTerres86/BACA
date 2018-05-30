--Parâmetro de Quantidade em minutos para reagendar JOBs do Debitador Único.
INSERT INTO crapprm
  (nmsistem, cdcooper, cdacesso, dstexprm,dsvlrprm,progress_recid) 
VALUES
  ('CRED',0,'QTD_MIN_REAGEN_DEBITADOR','Quantidade em minutos para reagendar JOBs do Debitador Único',10,NULL);
  
--Parâmetros por Cooperativa de Controle de qual programa/cooperativa ocasionou erro no Debitador Único.
INSERT INTO crapprm
  (nmsistem, cdcooper, cdacesso, dstexprm,dsvlrprm,progress_recid) 
VALUES
  ('CRED',1,'CTRL_ERRO_PRG_DEBITADOR','Controle de qual programa/cooperativa ocasionou erro no Debitador Único','01/01/1900 00:00#XXXXXXX',NULL); 
 
INSERT INTO crapprm
  (nmsistem, cdcooper, cdacesso, dstexprm,dsvlrprm,progress_recid) 
VALUES
  ('CRED',2,'CTRL_ERRO_PRG_DEBITADOR','Controle de qual programa/cooperativa ocasionou erro no Debitador Único','01/01/1900 00:00#XXXXXXX',NULL);  
  
INSERT INTO crapprm
  (nmsistem, cdcooper, cdacesso, dstexprm,dsvlrprm,progress_recid) 
VALUES
  ('CRED',5,'CTRL_ERRO_PRG_DEBITADOR','Controle de qual programa/cooperativa ocasionou erro no Debitador Único','01/01/1900 00:00#XXXXXXX',NULL);   
  
INSERT INTO crapprm
  (nmsistem, cdcooper, cdacesso, dstexprm,dsvlrprm,progress_recid) 
VALUES
  ('CRED',6,'CTRL_ERRO_PRG_DEBITADOR','Controle de qual programa/cooperativa ocasionou erro no Debitador Único','01/01/1900 00:00#XXXXXXX',NULL);
  
INSERT INTO crapprm
  (nmsistem, cdcooper, cdacesso, dstexprm,dsvlrprm,progress_recid) 
VALUES
  ('CRED',7,'CTRL_ERRO_PRG_DEBITADOR','Controle de qual programa/cooperativa ocasionou erro no Debitador Único','01/01/1900 00:00#XXXXXXX',NULL);  
    
INSERT INTO crapprm
  (nmsistem, cdcooper, cdacesso, dstexprm,dsvlrprm,progress_recid) 
VALUES
  ('CRED',8,'CTRL_ERRO_PRG_DEBITADOR','Controle de qual programa/cooperativa ocasionou erro no Debitador Único','01/01/1900 00:00#XXXXXXX',NULL);  
  
INSERT INTO crapprm
  (nmsistem, cdcooper, cdacesso, dstexprm,dsvlrprm,progress_recid) 
VALUES
  ('CRED',9,'CTRL_ERRO_PRG_DEBITADOR','Controle de qual programa/cooperativa ocasionou erro no Debitador Único','01/01/1900 00:00#XXXXXXX',NULL);  
  
INSERT INTO crapprm
  (nmsistem, cdcooper, cdacesso, dstexprm,dsvlrprm,progress_recid) 
VALUES
  ('CRED',10,'CTRL_ERRO_PRG_DEBITADOR','Controle de qual programa/cooperativa ocasionou erro no Debitador Único','01/01/1900 00:00#XXXXXXX',NULL);  
  
INSERT INTO crapprm
  (nmsistem, cdcooper, cdacesso, dstexprm,dsvlrprm,progress_recid) 
VALUES
  ('CRED',11,'CTRL_ERRO_PRG_DEBITADOR','Controle de qual programa/cooperativa ocasionou erro no Debitador Único','01/01/1900 00:00#XXXXXXX',NULL);  
  
INSERT INTO crapprm
  (nmsistem, cdcooper, cdacesso, dstexprm,dsvlrprm,progress_recid) 
VALUES
  ('CRED',12,'CTRL_ERRO_PRG_DEBITADOR','Controle de qual programa/cooperativa ocasionou erro no Debitador Único','01/01/1900 00:00#XXXXXXX',NULL);
  
INSERT INTO crapprm
  (nmsistem, cdcooper, cdacesso, dstexprm,dsvlrprm,progress_recid) 
VALUES
  ('CRED',13,'CTRL_ERRO_PRG_DEBITADOR','Controle de qual programa/cooperativa ocasionou erro no Debitador Único','01/01/1900 00:00#XXXXXXX',NULL);    
  
INSERT INTO crapprm
  (nmsistem, cdcooper, cdacesso, dstexprm,dsvlrprm,progress_recid) 
VALUES
  ('CRED',14,'CTRL_ERRO_PRG_DEBITADOR','Controle de qual programa/cooperativa ocasionou erro no Debitador Único','01/01/1900 00:00#XXXXXXX',NULL);
  
INSERT INTO crapprm
  (nmsistem, cdcooper, cdacesso, dstexprm,dsvlrprm,progress_recid) 
VALUES
  ('CRED',16,'CTRL_ERRO_PRG_DEBITADOR','Controle de qual programa/cooperativa ocasionou erro no Debitador Único','01/01/1900 00:00#XXXXXXX',NULL);

COMMIT;



--Parâmetro de Controle Execução Tarifas

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 1, 'CTRL_DEBUNITAR_EXEC', 'Controle de execução debito tarifa no Debitador Unico (tari0001.pc_deb_tarifa_pend)', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 2, 'CTRL_DEBUNITAR_EXEC', 'Controle de execução debito tarifa no Debitador Unico (tari0001.pc_deb_tarifa_pend)', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 5, 'CTRL_DEBUNITAR_EXEC', 'Controle de execução debito tarifa no Debitador Unico (tari0001.pc_deb_tarifa_pend)', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 6, 'CTRL_DEBUNITAR_EXEC', 'Controle de execução debito tarifa no Debitador Unico (tari0001.pc_deb_tarifa_pend)', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 7, 'CTRL_DEBUNITAR_EXEC', 'Controle de execução debito tarifa no Debitador Unico (tari0001.pc_deb_tarifa_pend)', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 8, 'CTRL_DEBUNITAR_EXEC', 'Controle de execução debito tarifa no Debitador Unico (tari0001.pc_deb_tarifa_pend)', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 9, 'CTRL_DEBUNITAR_EXEC', 'Controle de execução debito tarifa no Debitador Unico (tari0001.pc_deb_tarifa_pend)', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 10, 'CTRL_DEBUNITAR_EXEC', 'Controle de execução debito tarifa no Debitador Unico (tari0001.pc_deb_tarifa_pend)', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 11, 'CTRL_DEBUNITAR_EXEC', 'Controle de execução debito tarifa no Debitador Unico (tari0001.pc_deb_tarifa_pend)', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 12, 'CTRL_DEBUNITAR_EXEC', 'Controle de execução debito tarifa no Debitador Unico (tari0001.pc_deb_tarifa_pend)', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 13, 'CTRL_DEBUNITAR_EXEC', 'Controle de execução debito tarifa no Debitador Unico (tari0001.pc_deb_tarifa_pend)', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 14, 'CTRL_DEBUNITAR_EXEC', 'Controle de execução debito tarifa no Debitador Unico (tari0001.pc_deb_tarifa_pend)', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 16, 'CTRL_DEBUNITAR_EXEC', 'Controle de execução debito tarifa no Debitador Unico (tari0001.pc_deb_tarifa_pend)', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 1, 'QTD_EXEC_DEBUNITAR', 'Quantidade de execuções da TARI0001.pc_deb_tarifa_pend durante o dia', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 2, 'QTD_EXEC_DEBUNITAR', 'Quantidade de execuções da TARI0001.pc_deb_tarifa_pend durante o dia', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 5, 'QTD_EXEC_DEBUNITAR', 'Quantidade de execuções da TARI0001.pc_deb_tarifa_pend durante o dia', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 6, 'QTD_EXEC_DEBUNITAR', 'Quantidade de execuções da TARI0001.pc_deb_tarifa_pend durante o dia', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 7, 'QTD_EXEC_DEBUNITAR', 'Quantidade de execuções da TARI0001.pc_deb_tarifa_pend durante o dia', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 8, 'QTD_EXEC_DEBUNITAR', 'Quantidade de execuções da TARI0001.pc_deb_tarifa_pend durante o dia', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 9, 'QTD_EXEC_DEBUNITAR', 'Quantidade de execuções da TARI0001.pc_deb_tarifa_pend durante o dia', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 10, 'QTD_EXEC_DEBUNITAR', 'Quantidade de execuções da TARI0001.pc_deb_tarifa_pend durante o dia', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 11, 'QTD_EXEC_DEBUNITAR', 'Quantidade de execuções da TARI0001.pc_deb_tarifa_pend durante o dia', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 12, 'QTD_EXEC_DEBUNITAR', 'Quantidade de execuções da TARI0001.pc_deb_tarifa_pend durante o dia', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 13, 'QTD_EXEC_DEBUNITAR', 'Quantidade de execuções da TARI0001.pc_deb_tarifa_pend durante o dia', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 14, 'QTD_EXEC_DEBUNITAR', 'Quantidade de execuções da TARI0001.pc_deb_tarifa_pend durante o dia', null, null);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 16, 'QTD_EXEC_DEBUNITAR', 'Quantidade de execuções da TARI0001.pc_deb_tarifa_pend durante o dia', null, null);

COMMIT;