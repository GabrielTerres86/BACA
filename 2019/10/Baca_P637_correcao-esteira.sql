declare
 
begin
update crawepr
  set insitest=0
 where cdcooper=1 and insitapr=0 and insitest=1 and p.dtenvmot<trunc(sysdate);
 commit;
end; 