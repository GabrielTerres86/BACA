DECLARE 
  max_id NUMBER := 0;
BEGIN
  
 SELECT MAX(p.idparametro) + 1 INTO max_id FROM tbgen_batch_param p;
 
 IF max_id > 0 THEN
   INSERT INTO tbgen_batch_param VALUES (max_id,20,0,1,'CRPS575');   
 END IF;
 
 COMMIT;
 
END;
