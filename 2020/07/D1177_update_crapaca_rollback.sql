UPDATE crapaca 
SET nmdeacao = 'LIMITE_SAQUE_TAA_ALTERAR',nmproced = 'pc_tela_lim_saque_alterar'
WHERE nmdeacao = 'LIMITE_TAA_ALTERAR';

UPDATE crapaca 
SET nmdeacao = 'LIMITE_SAQUE_TAA_CONSULTAR',nmproced = 'pc_tela_lim_saque_consultar'
WHERE nmdeacao = 'LIMITE_TAA_CONSULTAR';

COMMIT;