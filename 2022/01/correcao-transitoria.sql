BEGIN
  DELETE FROM TBCC_PREJUIZO_LANCAMENTO
   WHERE CDCOOPER = 6
     AND NRDCONTA = 130664
     AND VLLANMTO = 110
     AND CDHISTOR = 2738
     AND dtmvtolt = to_date('18/01/2022', 'dd/mm/rrrr');
       
  UPDATE tbcc_prejuizo
     SET vlsdprej = Nvl(vlsdprej, 0) - 110
   WHERE cdcooper = 6
     AND nrdconta = 130664;
       
  EXCEPTION
    WHEN OTHERS THEN 
      dbms_output.put_line('Erro ao atualizar prejuizo: ' || SQLERRM);
END;
