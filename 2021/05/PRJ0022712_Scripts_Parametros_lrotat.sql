-- PRJ0022712 - LROTAT

UPDATE crapaca a
   SET a.lstparam = a.lstparam || ',pr_inpreapr'
 WHERE a.nmdeacao = 'INCLUILROTAT'; 
  
UPDATE crapaca a
   SET a.lstparam = a.lstparam || ',pr_inpreapr'
 WHERE a.nmdeacao = 'ALTERALROTAT'; 

-- Setar linhas com flag pre-aprovado
UPDATE craplrt lrt
   SET lrt.inpreapr = 1
 WHERE lrt.cddlinha IN (30,31,32,40,41,42);
COMMIT;






