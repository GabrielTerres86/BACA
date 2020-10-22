UPDATE crapaca a
SET a.lstparam = a.lstparam||',pr_flgrepro'
where a.nmdeacao = 'INCLINHA'
AND a.nmpackag = 'TELA_LCREDI';

UPDATE crapaca a
SET a.lstparam = a.lstparam||',pr_flgrepro'
where a.nmdeacao = 'ALTLINHA'
AND a.nmpackag = 'TELA_LCREDI';

-- armazenar tela para interface web
INSERT INTO CRAPRDR (NMPROGRA, DTSOLICI) values ('TELA_RECCRD', sysdate);

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('BUSCA_FAIXA_RECIPRO_TAXA', 'TELA_RECCRD', 'pc_busca_faixa_recipro_web', 'pr_tpproduto,pr_cdcatego,pr_inpessoa ',
                      (SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_RECCRD' AND ROWNUM = 1));                                                                 
            

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('EXEC_ACAO_FAIXA_RECIPRO_TAXA', 'TELA_RECCRD', 'pc_executa_acao_web', 'pr_tpproduto,pr_cdcatego,pr_inpessoa,pr_cdfaixa_recipro,pr_tpdeacao
            ,pr_peinicial,pr_pefinal,pr_dtinicio_vigencia,pr_dtfim_vigencia,pr_pedesconto',
               (SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_RECCRD' AND ROWNUM = 1));
			   
commit;
