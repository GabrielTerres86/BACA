UPDATE crapaca a
SET a.lstparam = a.lstparam||',pr_flgrepro'
where a.nmdeacao = 'INCLINHA'
AND a.nmpackag = 'TELA_LCREDI';

UPDATE crapaca a
SET a.lstparam = a.lstparam||',pr_flgrepro'
where a.nmdeacao = 'ALTLINHA'
AND a.nmpackag = 'TELA_LCREDI';

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('BUSCA_FAIXA_RECIPRO_TAXA', 'TELA_RECCRD', 'pc_busca_faixa_recipro_web', 'pr_tpproduto,pr_cdcatego,pr_inpessoa ',
                      NVL((SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_RECCRD' AND ROWNUM = 1),1));                                                                 
            
			
commit;