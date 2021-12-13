DECLARE
 /* [INC0114189] - Erro ao emitir comprovante de pagamento dos boletos */
BEGIN
update crappro set dscedent = 'SUREK CIA LTDA - ME'  where nrdconta = 477893 and cdcooper = 11 and dtmvtolt =  '16/11/2021' and nrseqaut = 455;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.put_line(SQLERRM);
    sistema.excecaoInterna(pr_compleme => 'INC0114189');  
END;                            
