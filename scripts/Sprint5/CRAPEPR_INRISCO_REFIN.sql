-- Alter table
ALTER TABLE CECRED.CRAPEPR
  ADD (INRISCO_REFIN NUMBER(5))
/
-- Add comments to the columns
comment on column CECRED.CRAPEPR.INRISCO_REFIN
  is 'Nivel de risco do Refinanciamento(Aceleracao)'
/