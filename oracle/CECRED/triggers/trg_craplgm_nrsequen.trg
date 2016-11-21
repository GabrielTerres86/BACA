CREATE OR REPLACE TRIGGER CECRED.trg_craplgm_nrsequen
BEFORE INSERT ON craplgm
FOR EACH ROW
BEGIN
  if nvl(:new.nrsequen,0) = 0 then
    :new.nrsequen := seq_craplgm_nrsequen.nextval;
  end if;
END;
/

