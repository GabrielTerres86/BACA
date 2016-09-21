CREATE OR REPLACE TRIGGER CECRED.trg_craptex_nrseqext
BEFORE INSERT ON craptex
FOR EACH ROW
BEGIN
  if nvl(:new.nrseqext,0) = 0 then
    :new.nrseqext := seq_craptex_nrseqext.nextval;
  end if;
END;
/

