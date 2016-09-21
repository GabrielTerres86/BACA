CREATE OR REPLACE TRIGGER CECRED.trg_CRAPnpc_cdnomenc
BEFORE INSERT ON CRAPNPC
FOR EACH ROW
BEGIN
  if nvl(:new.cdnomenc,0) = 0 then
    :new.cdnomenc := seqnpc_cdnomenc.nextval;
  end if;
END;
/

