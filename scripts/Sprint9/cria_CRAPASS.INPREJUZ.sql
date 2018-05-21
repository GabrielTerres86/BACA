ALTER TABLE CECRED.CRAPASS
  ADD inprejuz NUMBER(5) DEFAULT 0
/
comment on column CECRED.CRAPASS.inprejuz is 'Indicador do prejuizo (1 - em prejuizo)'
/