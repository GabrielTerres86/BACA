-- Add/modify columns 
alter table CECRED.CRAPEPR add dtinicio_atraso_refin date;
-- Add comments to the columns 
comment on column CECRED.CRAPEPR.dtinicio_atraso_refin
  is 'Data de Inicio do pior atraso dos contratos refinanciados';
