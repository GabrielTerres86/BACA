-- Add/modify columns 
alter table CECRED.TBRISCO_CENTRAL_OCR add qtdiaatr NUMBER(10) default 0 not null;
-- Add comments to the columns 
comment on column CECRED.TBRISCO_CENTRAL_OCR.qtdiaatr
  is 'Quantidade de dias em atraso da central no momento que foi criado o risco consolidado';