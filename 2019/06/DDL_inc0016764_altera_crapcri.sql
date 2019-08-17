/*
INC0016764 - retirar os códigos do conteúdo do campo dscritic para as críticas: 1448, 1449, 1450, 1451
na Volles - 04/06/2019

select cdcritic, dscritic from crapcri where cdcritic in (1448, 1449, 1450, 1451) order by dscritic, cdcritic;

*/

begin
  begin
   update CRAPCRI
   set    dscritic = substr(dscritic, instr(dscritic,'-')+2)
   where  cdcritic in (1448, 1449, 1450, 1451);
  exception
    when others then
      rollback;  
  end;

  commit;
end;

