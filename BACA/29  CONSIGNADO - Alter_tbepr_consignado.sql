-- Add/modify columns 
alter table TBEPR_CONSIGNADO add pejuro_anual number(5,2);
alter table TBEPR_CONSIGNADO add pecet_anual number(5,2);
alter table TBEPR_CONSIGNADO add vlparcela NUMBER(25,2);
-- Add comments to the columns 
comment on column TBEPR_CONSIGNADO.pejuro_anual is 'Percentual da taxa de juros anual';
comment on column TBEPR_CONSIGNADO.pecet_anual  is 'Percentual do CET anual';
comment on column TBEPR_CONSIGNADO.vlparcela  is 'Valor da parcela';