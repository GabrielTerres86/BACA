-- Remoção de caracteres especiais de 4 lançamentos 
-- INC0032327
 UPDATE craplcm a
    SET a.dsidenti       = 'deposito' -- de´posito
  where a.progress_recid =  637400976;
  
 UPDATE craplcm a
    SET a.dsidenti       = 'representacao' -- re´presentacao
  where a.progress_recid =  641810790;  
  
 UPDATE craplcm a
    SET a.dsidenti       = 'propru' -- ´propru
  where a.progress_recid =  642996486;    

 UPDATE craplcm a
    SET a.dsidenti       = 'refpensaop do mes 02' -- ref´pensaop do mes 02
  where a.progress_recid =  648684182;      
  
COMMIT;
  