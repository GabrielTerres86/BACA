CREATE OR REPLACE TRIGGER CECRED.trg_crapind_cddindex
BEFORE INSERT ON CECRED.crapind
FOR EACH ROW
BEGIN
if nvl(:new.cddindex,0) = 0 then
:new.cddindex := seqind_cddindex.nextval;
end if;
END;
/

