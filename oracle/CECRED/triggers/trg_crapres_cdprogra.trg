CREATE OR REPLACE TRIGGER CECRED.TRG_CRAPRES_CDPROGRA
  BEFORE INSERT OR UPDATE ON crapres
  FOR EACH ROW
BEGIN
  -- Garantir que o código do programa fique sem em maiuscula
  :new.cdprogra := upper(:new.cdprogra);
END TRG_CRAPRES_CDPROGRA;
/

