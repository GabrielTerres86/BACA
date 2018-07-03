-- Add/modify columns 
alter table CECRED.TBCC_PREJUIZO add dtrefjur date;
alter table CECRED.TBCC_PREJUIZO add diarefju number(2);
alter table CECRED.TBCC_PREJUIZO add mesrefju number(2);
alter table CECRED.TBCC_PREJUIZO add anorefju number(4);
-- Add comments to the columns 
comment on column CECRED.TBCC_PREJUIZO.dtrefjur
  is 'Data de referencia da ultima vez que foi calculado juros para o saldo devedor do prejuizo';
comment on column CECRED.TBCC_PREJUIZO.diarefju
  is 'Dia de referencia da ultima vez que foi calculado juros para o saldo devedor do prejuizo';
comment on column CECRED.TBCC_PREJUIZO.mesrefju
  is 'Mes de referencia da ultima vez que foi calculado juros para o saldo devedor do prejuizo';
comment on column CECRED.TBCC_PREJUIZO.anorefju
  is 'Ano  de referencia da ultima vez que foi calculado juros para o saldo devedor do prejuizo';