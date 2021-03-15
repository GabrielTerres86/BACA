--RDM0038345 ritm0115682 - Aumentar qtd de sessões paralelas do programa crps155
UPDATE tbgen_batch_param m SET m.qtparalelo = 40 WHERE m.cdprograma = 'CRPS155';
COMMIT;
