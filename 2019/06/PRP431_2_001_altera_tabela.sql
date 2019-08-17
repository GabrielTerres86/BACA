-- Add/modify columns 
alter table CECRED.TBCOBRAN_PAGADOR_AGREGADO add dsobserv VARCHAR2(200);
alter table CECRED.TBCOBRAN_PAGADOR_AGREGADO add incooper NUMBER(5);
alter table CECRED.TBCOBRAN_PAGADOR_AGREGADO add dtregistro date not null;
-- Add comments to the columns 
comment on column CECRED.TBCOBRAN_PAGADOR_AGREGADO.dsobserv
  is 'Observacoes pertinentes ao processo';
comment on column CECRED.TBCOBRAN_PAGADOR_AGREGADO.incooper
  is 'Indicador Cooperado ou Terceiro';
comment on column CECRED.TBCOBRAN_PAGADOR_AGREGADO.dtregistro
  is 'Data de Criação do Registro.';

