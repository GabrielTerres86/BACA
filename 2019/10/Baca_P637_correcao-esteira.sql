declare
 
begin
update crawepr
  set insitest=0
 where insitapr=0 and insitest=1 and dtenvmot<trunc(sysdate);
 commit;
end; 