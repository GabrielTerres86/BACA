-- Add/modify columns 
alter table CECRED.CRAPEPR add qtdias_atraso_refin number(5) default 0 not null;
-- Add comments to the columns 
comment on column CECRED.CRAPEPR.qtdias_atraso_refin
  is 'Quantidade Dias Atraso utilizado para calculo Risco Refinanciamento';