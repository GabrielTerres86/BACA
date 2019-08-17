/*
INC0016764 - prate 2 - retirar os códigos do conteúdo do campo dscritic para as críticas: 1418, 1419
Ana Volles - 07/06/2019

select cdcritic, dscritic from crapcri where cdcritic in (1418,1419) order by dscritic, cdcritic;

*/

begin
  begin
   update CRAPCRI
   set    dscritic = substr(dscritic, instr(dscritic,'-')+2)
   where  cdcritic in (1418,1419);
  exception
    when others then
      rollback;  
  end;

  commit;
end;

