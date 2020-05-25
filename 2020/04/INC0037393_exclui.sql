--INC0037393
--Ana Volles - 15/04/2020
--Excluir os 2 benefícios que não deveriam estar associados o cpf 46851321904
--  SELECT * FROM crapdbi a WHERE a.nrcpfcgc = 46851321904;
BEGIN
  DELETE crapdbi a
  WHERE  a.nrcpfcgc = 46851321904
  AND    a.nrrecben <> 1035254090;
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
