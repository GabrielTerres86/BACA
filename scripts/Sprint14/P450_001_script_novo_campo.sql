
--Criar coluna na tabela
ALTER TABLE CECRED.CRAPASS ADD (NRCPFCNPJ_BASE NUMBER(11) default 0 NOT NULL);


--Criar comentário
comment on column CECRED.CRAPASS.NRCPFCNPJ_BASE
  is 'Numero do CPF/CNPJ Base do associado.';

  
--Criar indice no banco de dados
create index CECRED.CRAPASS##CRAPASS9 on CECRED.CRAPASS (CDCOOPER, NRCPFCNPJ_BASE)
  tablespace TBS_CADASTRO_I
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
 
 
 -- 
 SELECT nrcpfcgc,nrdconta
  FROM crapass a
 WHERE a.cdcooper = 1
   AND a.NRCPFCNPJ_BASE = 3925280
   ;