UPDATE tbgen_debitador_param
SET NRPRIORIDADE = NRPRIORIDADE + 3
/

delete tbgen_debitador_horario_proc x
where x.cdprocesso in ('PC_CRPS782','PC_CRPS783','PC_CRPS784','PC_CRPS785')
/

delete tbgen_debitador_param d
where d.cdprocesso in ('PC_CRPS782','PC_CRPS783','PC_CRPS784','PC_CRPS785')
/

insert into tbgen_debitador_param 
 (CDPROCESSO,           
  DSPROCESSO,           
  INDEB_SEM_SALDO,      
  INDEB_PARCIAL,        
  QTDIAS_REPESCAGEM,    
  NRPRIORIDADE,         
  INEXEC_CADEIA_NOTURNA,
  INCONTROLE_EXEC_PROG) 
values 
 ('PC_CRPS784',
  'PAGAMENTO DO EMPRÉSTIMO CONSIGNADO REFINANCIAMENTO',
  'N', 'S', NULL,1,'N',0)
/  
insert into tbgen_debitador_param 
 (CDPROCESSO,           
  DSPROCESSO,           
  INDEB_SEM_SALDO,      
  INDEB_PARCIAL,        
  QTDIAS_REPESCAGEM,    
  NRPRIORIDADE,         
  INEXEC_CADEIA_NOTURNA,
  INCONTROLE_EXEC_PROG) 
values 
 ('PC_CRPS785',
  'PAGAMENTO DO EMPRÉSTIMO CONSIGNADO BOLETO',
  'N', 'S', NULL,2,'N',0)
/  
INSERT into tbgen_debitador_param 
 (CDPROCESSO,           
  DSPROCESSO,           
  INDEB_SEM_SALDO,      
  INDEB_PARCIAL,        
  QTDIAS_REPESCAGEM,    
  NRPRIORIDADE,         
  INEXEC_CADEIA_NOTURNA,
  INCONTROLE_EXEC_PROG) 
values 
 ('PC_CRPS782',
  'ATUALIZA SALDO E EXTRATO DE EMPRÉSTIMO CONSIGNADO',
  'N', 'S', NULL,3,'S',0)
/
insert into tbgen_debitador_horario_proc values ('PC_CRPS782',1)
/
insert into tbgen_debitador_horario_proc values ('PC_CRPS782',2)
/
insert into tbgen_debitador_horario_proc values ('PC_CRPS782',3)
/
insert into tbgen_debitador_horario_proc values ('PC_CRPS782',5)
/
insert into tbgen_debitador_horario_proc values ('PC_CRPS785',1)
/
insert into tbgen_debitador_horario_proc values ('PC_CRPS785',2)
/
insert into tbgen_debitador_horario_proc values ('PC_CRPS785',3)
/
insert into tbgen_debitador_horario_proc values ('PC_CRPS785',5)
/
insert into tbgen_debitador_horario_proc values ('PC_CRPS784',1)
/
COMMIT 
/
