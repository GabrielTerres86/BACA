/*
INC0016764 - parte 2 - retorno baca
Script para retorno caso ocorra algum erro - incluir os c�digos do conte�do do campo dscritic para as cr�ticas: 1418, 1419
Ana Volles - 07/06/2019

select cdcritic, dscritic from crapcri where cdcritic in (1418,1419) order by dscritic, cdcritic;

*/

begin
  begin
   update CRAPCRI
   set    dscritic = cdcritic ||' - '|| dscritic
   where  cdcritic in (1418,1419);
  exception
    when others then
      rollback;  
  end;

  commit;
end;

