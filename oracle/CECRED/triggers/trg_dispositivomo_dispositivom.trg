CREATE OR REPLACE TRIGGER CECRED.TRG_DispositivoMo_DispositivoM
  BEFORE INSERT
  ON DispositivoMobile
  FOR EACH ROW
  BEGIN
    SELECT CECRED.SEQ_DispositivoMo_DispositivoM.NEXTVAL
    INTO :NEW.DispositivoMobileId
    FROM DUAL;
  END;
/

