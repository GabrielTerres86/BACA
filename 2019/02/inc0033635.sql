/*
   Script para atualizar situação do cheque.

    --Selecet para gear o update:
      SELECT f.*,
             'UPDATE crapfdc f ' ||
               ' SET f.incheque = 0 ' ||
             'WHERE f.progress_recid = ' || f.progress_recid || ';'
        FROM crapfdc f
       WHERE f.cdcooper = 5
         AND f.nrdconta = 160385
         AND f.nrcheque = 39;
   
   --Select para gerar o backup:
      SELECT f.*,
             'UPDATE crapfdc f ' ||
               ' SET f.incheque = ' || f.incheque || 
             ' WHERE f.progress_recid = ' || f.progress_recid || ';'
        FROM crapfdc f
       WHERE f.cdcooper = 5
         AND f.nrdconta = 160385
         AND f.nrcheque = 39;
         
   --Update de backup:
      UPDATE crapfdc f  SET f.incheque = 5 WHERE f.progress_recid = 54043756;
      
*/

UPDATE crapfdc f  SET f.incheque = 0 WHERE f.progress_recid = 54043756;

COMMIT;   

