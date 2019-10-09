declare
 
begin
update crawepr
  set insitest=0
 where insitapr=0 and insitest=1 and dtenvmot<trunc(sysdate) AND dtenvest IS NULL AND dtenvmot IS NOT NULL;
 commit;
end; 