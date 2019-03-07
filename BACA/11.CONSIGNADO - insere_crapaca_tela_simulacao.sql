INSERT INTO CRAPACA VALUES (SEQACA_NRSEQACA.NEXTVAL,'SIMULA_VALIDA_CONSIGNADO',
'TELA_ATENDA_SIMULACAO','pc_valida_simul_consig','pr_nrdconta,pr_cdlcremp',1893)
/
UPDATE  crapaca  a
set a.lstparam = a.lstparam||',pr_vlparepr,pr_vliofepr'
where a.nmpackag = 'TELA_ATENDA_SIMULACAO'
AND A.NMDEACAO = 'SIMULA_GRAVA_SIMULACAO'
/
commit
/
