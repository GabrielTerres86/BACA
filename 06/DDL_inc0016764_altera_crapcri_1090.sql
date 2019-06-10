/*
INC0016764 - prate 3 - retirar os c�digos do conte�do do campo dscritic para as cr�ticas: 1090
Ana Volles - 10/06/2019

select cdcritic, dscritic from crapcri where cdcritic in (1090) order by dscritic, cdcritic;

*/

begin
  begin
   update CRAPCRI
   set    dscritic = substr(dscritic, instr(dscritic,'-')+2)
   where  cdcritic in (1090);
  exception
    when others then
      rollback;  
  end;

  commit;
end;

