
UPDATE  craptel tel
     SET tel.cdopptel = '@, C'
    ,tel.tldatela = 'CONCILIACAO DA CONTA LIQUIDACAO'
    ,tel.tlrestel = 'CONCILIACAO DA CONTA LIQUIDACAO'
    ,tel.lsopptel = 'ACESSO, CONCILIACAO MANUAL'
WHERE tel.nmdatela ='CONSPB'
AND tel.cdcooper = 3;

COMMIT;
