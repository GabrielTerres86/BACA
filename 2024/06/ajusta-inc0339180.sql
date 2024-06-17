BEGIN

update cecred.tb_consumo_barramento set inem_processamento = null
where nrseq_consumo = '240600134813'
and nrcontrole_if = '1240617010000152866A'
and inem_processamento = 'P'

COMMIT;
END;