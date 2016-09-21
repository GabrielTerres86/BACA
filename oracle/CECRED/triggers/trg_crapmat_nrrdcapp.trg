CREATE OR REPLACE TRIGGER CECRED.trg_crapmat_nrrdcapp
BEFORE INSERT ON crapmat
FOR EACH ROW
BEGIN
  if nvl(:new.nrrdcapp,0) = 0 then
    :new.nrrdcapp := seq_crapmat_nrrdcapp.nextval;
  end if;
END;
/

