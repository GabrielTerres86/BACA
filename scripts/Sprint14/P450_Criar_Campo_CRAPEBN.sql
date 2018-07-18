-- Add/modify columns 
alter table CECRED.CRAPEBN add cdindxdr number(3);
-- Add comments to the columns 
comment on column CECRED.CRAPEBN.cdindxdr
  is 'Codigo do Indexador / Identificar Linha Credito';