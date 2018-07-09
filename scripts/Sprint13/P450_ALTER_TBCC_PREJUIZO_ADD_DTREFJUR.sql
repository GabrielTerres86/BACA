-- Add/modify columns 
alter table CECRED.TBCC_PREJUIZO add dtrefjur date;
alter table CECRED.TBCC_PREJUIZO add nrdiarefju number(2);
alter table CECRED.TBCC_PREJUIZO add nrmesrefju number(2);
alter table CECRED.TBCC_PREJUIZO add nranorefju number(4);
-- Add comments to the columns 
comment on column CECRED.TBCC_PREJUIZO.dtrefjur
  is 'Data de referencia da ultima vez que foi calculado juros para o saldo devedor do prejuizo';
comment on column CECRED.TBCC_PREJUIZO.nrdiarefju
  is 'Dia de referencia da ultima vez que foi calculado juros para o saldo devedor do prejuizo';
comment on column CECRED.TBCC_PREJUIZO.nrmesrefju
  is 'Mes de referencia da ultima vez que foi calculado juros para o saldo devedor do prejuizo';
comment on column CECRED.TBCC_PREJUIZO.nranorefju
  is 'Ano  de referencia da ultima vez que foi calculado juros para o saldo devedor do prejuizo';


-- Add/modify columns 
alter table CECRED.TBCC_PREJUIZO add intipo_transf number(1) default 0 not null;
-- Add comments to the columns 
comment on column CECRED.TBCC_PREJUIZO.intipo_transf
  is 'Indicador do tipo de transferencia (0 - Transferencia por atraso/estouro de conta  /  1 - Transferencia por fraude)';