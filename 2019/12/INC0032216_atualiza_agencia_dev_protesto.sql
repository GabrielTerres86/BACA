BEGIN
  UPDATE tbfin_recursos_movimento tr
    SET tr.cdagenci_creditada = 1
  WHERE tr.dtmvtolt = '20/11/2019'
    AND tr.dsconta_debitada = 590401  
    AND tr.cdagenci_creditada = 100    
    AND tr.vllanmto IN( 4500,3039.13);
  COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    dbms_output.put_line('Erro ao atualziar tbfin_recursos_movimento: '||sqlerrm);
END;
