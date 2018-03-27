-- Alter table
ALTER TABLE CECRED.TBRISCO_CENTRAL_OCR
  ADD (INDDOCTO NUMBER(5))
/
ALTER TABLE CECRED.TBRISCO_CENTRAL_OCR
  ADD (CDORIGEM NUMBER(5))
/
ALTER TABLE CECRED.TBRISCO_CENTRAL_OCR
  ADD (INRISCO_REFIN NUMBER(5))
/
-- Add comments to the columns
comment on column CECRED.TBRISCO_CENTRAL_OCR.INDDOCTO
  is 'Indica Docto(0 - 3010 / 1 - 3020)'
/
comment on column CECRED.TBRISCO_CENTRAL_OCR.CDORIGEM
  is 'Origem(1- Conta , 2 - Desconto Cheques, 3 - Emprestimos)'
/
comment on column CECRED.TBRISCO_CENTRAL_OCR.INRISCO_REFIN
  is 'Nivel de risco do Refinanciamento(Aceleracao)'
/