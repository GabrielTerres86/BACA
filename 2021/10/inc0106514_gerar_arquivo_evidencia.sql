declare 
  prdscritic varchar2(2000);
  prcdcritic INTEGER;
  
begin
  CECRED.PC_CNS_RETORNO_ARQ(3,prcdcritic, prdscritic);
end;
