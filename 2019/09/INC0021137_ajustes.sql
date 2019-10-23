--Delete para remover o registro de transação pendente criado erroneamente.
DELETE TBCC_OPERAD_APROV a  where a.cdcooper = 8  and a.nrdconta = 30066  and a.nrcpf_preposto = 34461493920  and a.nrcpf_operador = 41294694871;

--Deleta registro de senha criado erroneamente
DELETE crapsnh s WHERE s.progress_recid = 1800960; 

   
COMMIT;
