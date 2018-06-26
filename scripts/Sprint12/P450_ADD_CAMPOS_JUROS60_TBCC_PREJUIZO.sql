-- Add/modify columns 
alter table CECRED.TBCC_PREJUIZO add vljur60_ctneg number(25,2) default 0 not null;
alter table CECRED.TBCC_PREJUIZO add vljur60_lcred number(25,2) default 0 not null;
-- Add comments to the columns 
comment on column CECRED.TBCC_PREJUIZO.vlsdprej
  is 'Valor do saldo prejuizo (saldo devedor ate 59 dias)';
comment on column CECRED.TBCC_PREJUIZO.vljur60_ctneg
  is 'Valor dos juros +60 (taxa sobre conta negativa a partir de 60 dias de atraso)';
comment on column CECRED.TBCC_PREJUIZO.vljur60_lcred
  is 'Valor dos juros +60 (juros sobre limite de credito)';