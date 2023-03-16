begin
       UPDATE CECRED.tbrecarga_operacao SET INSIT_OPERACAO = 4 WHERE INSIT_OPERACAO = 1 AND DTRECARGA < TO_DATE('01/01/2023', 'dd/mm/yyyy');
       Commit;   
end;
