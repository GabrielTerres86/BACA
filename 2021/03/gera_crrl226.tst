PL/SQL Developer Test script 3.0
50
-- Created on 03/03/2021 by F0030367 
declare 
  -- Local variables here
  i integer;
  vr_stprogra PLS_INTEGER;            
  vr_infimsol PLS_INTEGER;            
  vr_cdcritic crapcri.cdcritic%TYPE;  --> Critica encontrada
  vr_dscritic  VARCHAR2(5000);  
  vr_excsaida EXCEPTION;  
  
  cursor cr_crapcop is
  select cdcooper
    from crapcop
   where flgativo = 1
     and cdcooper <> 3;
begin
  -- Test statements here
  for rw_crapcop in cr_crapcop loop
  
     cecred.pc_crps279_temp(pr_cdcooper => rw_crapcop.cdcooper,
                            pr_flgresta => 1,
                            pr_stprogra => vr_stprogra,
                            pr_infimsol => vr_infimsol,
                            pr_cdcritic => vr_cdcritic,
                            pr_dscritic => vr_dscritic);

     if vr_dscritic is not null then
       raise vr_excsaida;     
     end if;  
     
  end loop;
  
  -- Dropar a procedure criada após a execucao pra nao ficar lixo no banco
  begin
    execute immediate 'drop procedure CECRED.PC_CRPS279_TEMP';
  exception
  when others then
   null;
  end;

  :vr_dscritic := 'SUCESSO';    
    
  exception
  when vr_excsaida then
    :vr_dscritic := 'ERRO vr_excsaida: ' || vr_dscritic;
    rollback;  
  when others then
    :vr_dscritic := 'ERRO Geral: ' || vr_dscritic;
    rollback;  
end;
1
vr_dscritic
1
SUCESSO
5
0
