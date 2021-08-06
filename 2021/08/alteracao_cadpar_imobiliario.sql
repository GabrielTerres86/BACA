BEGIN
UPDATE  crappat 
   SET  cdpartar = (SELECT MAX(cdpartar)+1  FROM crappat)
 where nmpartar = 'LINFIN_IMOBILIARIO';
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;     