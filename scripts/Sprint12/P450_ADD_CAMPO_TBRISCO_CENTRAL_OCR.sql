-- Add/modify columns 
alter table CECRED.TBRISCO_CENTRAL_OCR add qtdias_atraso_refin number(5);
-- Add comments to the columns 
comment on column CECRED.TBRISCO_CENTRAL_OCR.qtdias_atraso_refin
  is 'Quantidade Dias Atraso utilizado para calculo Risco Refinanciamento';