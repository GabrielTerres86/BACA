-- Add/modify columns 
alter table CECRED.CRAPRIS add vlsld59d number(25,2) default 0 not null;
-- Add comments to the columns 
comment on column CECRED.CRAPRIS.vlsld59d
  is 'Saldo devedor ate 59 dias (Saldo devedor total - Juros +60)';