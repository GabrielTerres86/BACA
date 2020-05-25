/*  
 
   BACA - Responsável por atualizar o registro na tabela de parâmetros
          do servidor de imagens de cheque de contingência CTB para o 
          padrão SP.
          
          Daniel Lombardi - Mout'S
*/
UPDATE CRAPPRM
SET dsvlrprm = 'http://imagenscheque.cecred.coop.br/imagem/085/'
WHERE progress_recid = 91413;
COMMIT;
