BEGIN
  
UPDATE cecred.crapblj
SET dtblqfim =  to_date('23/03/2022','dd/mm/yyyy'), cdopddes = 1,
nrofides = 1, dtenvdes = to_date('23/03/2022','dd/mm/yyyy'),
dsinfdes = 'Desbloqueio de valor zerado'
WHERE cdcooper = 1 AND nrdconta = 8133530 AND vlbloque = 0 AND dtblqfim IS NULL;

COMMIT;

END;