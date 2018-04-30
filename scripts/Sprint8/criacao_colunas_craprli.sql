ALTER TABLE CECRED.CRAPRLI
  ADD cnauinad NUMBER(1) DEFAULT 1
/
comment on column CECRED.CRAPRLI.cnauinad is 'Identificador de cancelamento automatico por Inadimplencia(0-Nao 1-Sim)'
/

ALTER TABLE CECRED.CRAPRLI
  ADD qtdiatin NUMBER(3) DEFAULT 60
/
comment on column CECRED.CRAPRLI.qtdiatin is 'Qtde de dias a serem considerados para cancelamento automatico'
/

