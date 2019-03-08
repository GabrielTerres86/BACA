CREATE OR REPLACE TRIGGER trg_crawepr_insert
  before insert on crawepr
  for each row
declare
  -- local variables here
begin

 select dtmvtolt into :NEW.dtrefatu from crapdat where crapdat.cdcooper = :NEW.cdcooper;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100,'ERRO NA ATUALIZACAO do campo dtrefatu - TABELA crawepr!');

end trg_crawepr_atu;