  BEGIN
    -- Atualiza o emprestimo
    UPDATE CECRED.CRAPEPR
	   SET VLSPRJAT = 67130.78
	 	 , VLSDPREJ = 73707.96
	 	 , VLJRAPRJ = 32944.28 + 6577.18
	 	 , VLJRMPRJ = 6577.18
 	 WHERE cdcooper = 1 
	   AND nrdconta = 2615690 
	   AND nrctremp = 794105;
	 
    -- Atualiza o lancamento extrato
    UPDATE CECRED.CRAPLEM
	   SET VLLANMTO = 6577.18
 	 WHERE progress_recid = 188973201;

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
	  ROLLBACK;
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
  END;
