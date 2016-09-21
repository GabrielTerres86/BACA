CREATE OR REPLACE TRIGGER CECRED.TRG_CRAPPRG_CDPROGRA
  BEFORE INSERT OR UPDATE ON crapprg
  FOR EACH ROW
BEGIN
  -- Garantir que o código do programa e sistema
  -- fiquem sempre em maiuscula
  :new.cdprogra := upper(:new.cdprogra);
  :new.nmsistem := upper(:new.nmsistem);
END TRG_CRAPPRG_CDPROGRA;
/

