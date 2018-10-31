declare 
  CURSOR cr_acordos IS
	SELECT aco.cdcooper
	     , aco.nrdconta
			 , aco.nracordo
			 , ctr.vliofdev - ctr.vliofpag iof_pendente
	  FROM tbrecup_acordo aco
		   , tbrecup_acordo_contrato ctr
	 WHERE aco.cdsituacao = 3
	   AND aco.dtcancela >= to_date('26/10/2018', 'DD/MM/YYYY')
		 AND ctr.nracordo = aco.nracordo
		 AND ctr.cdorigem = 1
		 AND nvl(ctr.vliofdev, 0) - nvl(ctr.vliofpag, 0) > 0;
	rw_acordos cr_acordos%ROWTYPE;
begin
  FOR rw_acordos IN cr_acordos LOOP
		UPDATE crapsld
		   SET vliofmes = nvl(vliofmes, 0) + rw_acordos.iof_pendente
		 WHERE cdcooper = rw_acordos.cdcooper
		   AND nrdconta = rw_acordos.nrdconta;
			 
		UPDATE tbgen_iof_lancamento
		   SET nracordo = NULL
		 WHERE nracordo = rw_acordos.nracordo;
	END LOOP;  
	
	COMMIT;
end;
/
