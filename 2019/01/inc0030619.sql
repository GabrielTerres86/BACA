/*
  Script para remover os registros da crapdev da conta abaixo:
    Cooperativa: 101 - Viacredi
          Conta: 868.451-0
      Cheque nº: 245.3 
          Valor: R$ 11.000,00
          
    select * from crapdev;

    SELECT 'DELETE crapdev d where d.progress_recid = ' || crapdev.progress_recid || ';'
          ,crapdev.*
      FROM crapdev
     WHERE cdcooper = 1
       AND cdalinea = 21
       AND nrdconta = 8684510;
*/

DELETE crapdev d where d.progress_recid = 2169542;
DELETE crapdev d where d.progress_recid = 2169543;

COMMIT;
