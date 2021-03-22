/* inc0083322 - Remover marcação de baixa */
UPDATE crapcyb c
   SET c.dtdbaixa = NULL
 WHERE c.cdorigem = 5
   AND c.dtdbaixa = to_date('18/03/2021','DD/MM/RRRR');
   
   COMMIT;
   
   
  
