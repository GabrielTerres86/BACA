/*  
 
   BACA - Respons�vel por atualizar o registro na tabela de par�metros
          do servidor de imagens de cheque de conting�ncia CTB para o 
          padr�o SP.
          
          Daniel Lombardi - Mout'S
*/
UPDATE CRAPPRM
SET dsvlrprm = 'http://imagenscheque.cecred.coop.br/imagem/085/'
WHERE progress_recid = 91413;
COMMIT;
