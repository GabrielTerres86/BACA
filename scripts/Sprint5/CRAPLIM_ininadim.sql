ALTER TABLE CECRED.CRAPLIM
  ADD ininadim NUMBER(2) DEFAULT 0
/
comment on column CECRED.CRAPLIM.ininadim is 'Identificador de Inadimplencia(0-Nao 1-Sim)'
/