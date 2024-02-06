UPDATE crapscb c
   SET c.dsdirarq =  ' /usr/connect/bancoob' -- temporario /usr/coop/viacredi/bancoob
 WHERE c.dsdsigla = 'CB117';

COMMIT; 
 