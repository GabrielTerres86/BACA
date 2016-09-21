CREATE OR REPLACE TRIGGER CECRED.TRG_CRAPDAT_CDPRGANT
  BEFORE INSERT OR UPDATE ON crapdat
  FOR EACH ROW
BEGIN
  -- Garantir que o código do programa fique sem em maiuscula
  :new.cdprgant := upper(:new.cdprgant);
END TRG_CRAPDAT_CDPRGANT;
/

