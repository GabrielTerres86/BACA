-- Script de criação da tabela de vigências de tarifas convênio Sicredi
-- Create table
create table CECRED.CRAPTHV
(
  cdhistor  NUMBER(5)    default 0,
  dsorigem  VARCHAR2(13) default ' ',
  vltarifa  NUMBER(25,2) default 0,
  cdcooper  NUMBER(10)   default 0,
  dtvigenc  DATE         default sysdate
)

-- Add comments to the table 
comment on table CECRED.CRAPTHV
  is 'Vigência das tarifas dos historicos(por canal)';
-- Add comments to the columns 
comment on column CECRED.CRAPTHV.cdhistor
  is 'Codigo do historico da tarifa especial.';
comment on column CECRED.CRAPTHV.dsorigem
  is 'Sistema no qual foi originada a operacao.';
comment on column CECRED.CRAPTHV.vltarifa
  is 'Tarifa do historico.';
comment on column CECRED.CRAPTHV.cdcooper
  is 'Codigo que identifica a Cooperativa.';
comment on column CECRED.CRAPTHV.dtvigenc
  is 'Data de vigência do valor da tarifa de acordo com a importação do arquivo.';  

-- Create/Recreate indexes 
create unique index CECRED.CRAPTHV##CRAPTHV1 on CECRED.CRAPTHV (cdcooper, cdhistor, UPPER(dsorigem));

