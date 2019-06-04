CREATE OR REPLACE TRIGGER CECRED.trg_crawepr_insert
  before insert on crawepr
  for each row
declare
  -- local variables here
begin

 select dtmvtolt into :NEW.dtrefatu from crapdat where crapdat.cdcooper = :NEW.cdcooper;

 declare
   vrhrinclus crawepr.hrinclus%type;
 begin   
   vrhrinclus := gene0002.fn_busca_time();     
   select sysdate,
          decode(:new.hrinclus,
                 0,
                 vrhrinclus,
                 null,
                 vrhrinclus,
                 :new.hrinclus)
     into :new.dtinclus, :new.hrinclus
     from dual;
 end;


EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100,'ERRO NA ATUALIZACAO do campo dtrefatu - TABELA crawepr!');

end trg_crawepr_atu;
/
