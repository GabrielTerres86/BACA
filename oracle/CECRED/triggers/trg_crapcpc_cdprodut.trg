CREATE OR REPLACE TRIGGER CECRED.trg_crapCPC_CDPRODUT
BEFORE INSERT ON CRAPCPC
FOR EACH ROW
BEGIN
  if nvl(:new.cdPRODUT,0) = 0 then
    :new.cdPRODUT := seqcpc_cdprodut.nextval;
  end if;
END;
/

