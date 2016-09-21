CREATE OR REPLACE TRIGGER CECRED.trg_crapbcx_nrseqdig
BEFORE INSERT ON crapbcx
FOR EACH ROW
BEGIN
  if nvl(:new.nrseqdig,0) = 0 then
    :new.nrseqdig := seq_crapbcx_nrseqdig.nextval;
  end if;
END;
/

