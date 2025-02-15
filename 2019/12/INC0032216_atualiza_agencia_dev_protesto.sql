BEGIN
  UPDATE tbfin_recursos_movimento tr
    SET tr.cdagenci_creditada = 1
  WHERE (tr.dtmvtolt = '20/11/2019'
      AND tr.dsconta_debitada = 590401
      AND tr.cdagenci_creditada = 100
      AND tr.vllanmto IN( 4500,3039.13))
       OR (tr.dtmvtolt = '27/11/2019'
      AND tr.dsconta_debitada = 76740
      AND tr.cdagenci_creditada = 100
      AND tr.vllanmto IN( 2366.94));
      
   UPDATE crapsab b
     SET b.nmbaisac = REGEXP_REPLACE(b.nmbaisac,'[^a-z_A-Z ]')
   WHERE b.cdcooper > 0
     AND b.nmbaisac LIKE '%<%>%';
           
  COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    dbms_output.put_line('Erro ao atualziar registros: '||sqlerrm);
END;
