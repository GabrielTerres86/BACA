CREATE OR REPLACE TRIGGER CECRED.trg_crawepr_atu
  before update on crawepr
  for each row
declare
  -- local variables here
begin

 select dtmvtolt into :NEW.dtrefatu from crapdat where crapdat.cdcooper = :NEW.cdcooper;
 
 IF :OLD.INSITEST = 5 and :OLD.INSITEST <> :NEW.INSITEST THEN
   :NEW.dtexpira:=null;
 END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100,'ERRO NA ATUALIZACAO do campo dtrefatu - TABELA crawepr!');

end trg_crawepr_atu;
/
