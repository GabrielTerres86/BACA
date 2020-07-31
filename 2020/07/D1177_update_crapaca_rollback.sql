UPDATE crapaca 
SET nmdeacao = 'LIMITE_SAQUE_TAA_ALTERAR',nmproced = 'pc_tela_lim_saque_alterar'
WHERE nmdeacao = 'LIMITE_TAA_ALTERAR';

UPDATE crapaca 
SET nmdeacao = 'LIMITE_SAQUE_TAA_CONSULTAR',nmproced = 'pc_tela_lim_saque_consultar'
WHERE nmdeacao = 'LIMITE_TAA_CONSULTAR';

UPDATE crapaca 
SET lstparam = 'pr_nrdconta, pr_dtmvtolt, pr_vllimite_saque, pr_flgemissao_recibo_saque'
WHERE nmdeacao = 'LIMITE_TAA_ALTERAR';

COMMIT;