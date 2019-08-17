/*
  Script para remover os registros da crapdev das contas abaixo:
    1ª cheque: Conta: 919.743.5 nº 118.0 R$ 10.432,00
    2º Cheque: Conta: 919.726-5 nº 87.6  R$ 10.432,00
    DELETE crapdev d where d.progress_recid = 2167637;

    SELECT 'DELETE crapdev d where d.progress_recid = ' || crapdev.progress_recid || ';'
          ,crapdev.*
      FROM crapdev
     WHERE cdcooper = 1
       AND cdalinea = 21
       AND nrdconta IN (9197435, 9197265);
*/

DELETE crapdev d where d.progress_recid = 2167637;
DELETE crapdev d where d.progress_recid = 2167638;
DELETE crapdev d where d.progress_recid = 2167639;
DELETE crapdev d where d.progress_recid = 2167640;

COMMIT;
