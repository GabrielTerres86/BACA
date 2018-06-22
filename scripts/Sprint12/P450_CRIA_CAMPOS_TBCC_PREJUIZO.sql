-- Add/modify columns 
alter table CECRED.TBCC_PREJUIZO add qtdiaatr number(5) default 0 not null;
alter table CECRED.TBCC_PREJUIZO add vlsdprej number(25,2) default 0 not null;
alter table CECRED.TBCC_PREJUIZO add vljuprej number(25,2) default 0 not null;
alter table CECRED.TBCC_PREJUIZO add vlpgprej number(25,2) default 0 not null;
alter table CECRED.TBCC_PREJUIZO add vlrabono number(25,2) default 0 not null;
alter table CECRED.TBCC_PREJUIZO add incontabilizado number(1) default 0 not null;
-- Add comments to the columns 
comment on column CECRED.TBCC_PREJUIZO.qtdiaatr
  is 'Quantidade de dias em atraso no momento da transferencia para prejuizo';
comment on column CECRED.TBCC_PREJUIZO.vlsdprej
  is 'Valor do saldo prejuizo';
comment on column CECRED.TBCC_PREJUIZO.vljuprej
  is 'Valor do juros remuneratorio do prejuizo';
comment on column CECRED.TBCC_PREJUIZO.vlpgprej
  is 'Valor pago prejuizo';
comment on column CECRED.TBCC_PREJUIZO.vlrabono
  is 'Valor abono prejuizo';
comment on column CECRED.TBCC_PREJUIZO.incontabilizado
  is 'Indicador de contabilizacao da transferencia para prejuizo (0-Nao / 1-Sim)';
