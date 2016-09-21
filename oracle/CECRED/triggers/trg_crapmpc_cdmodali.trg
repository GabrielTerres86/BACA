CREATE OR REPLACE TRIGGER CECRED.trg_CRAPMPC_CDMODALI
BEFORE INSERT ON CRAPMPC
FOR EACH ROW
BEGIN
  if nvl(:new.cdmodali,0) = 0 then
    :new.cdmodali := seqmpc_cdmodali.nextval;
  end if;
END;
/

