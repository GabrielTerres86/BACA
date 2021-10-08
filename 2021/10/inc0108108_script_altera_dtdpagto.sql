BEGIN
  UPDATE crawepr wpr
     SET wpr.dtdpagto = to_date('15/10/2021','dd/mm/yyyy')
   WHERE wpr.cdcooper = 3
     AND wpr.nrdconta = 94
     AND wpr.nrctremp = 211409;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    dbms_output.put_line('Erro ao atualizar a dtdpagto: ' || SQLERRM);
END;  
