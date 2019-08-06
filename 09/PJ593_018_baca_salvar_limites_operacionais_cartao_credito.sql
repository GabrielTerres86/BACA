DECLARE    

BEGIN

    INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	VALUES ('SALVA_LIMITES_OPERACIONAIS', 'CCRD0009', 'pccrd_salvar_limites_ope', 'pr_cdcooperativa, pr_id, pr_vllimite_outo, pr_vllimite_cons, pr_vllimite_disp, pr_perseguranca, pr_perdisp_majo, pr_perdisp_prea, pr_perdisp_oper, pr_email_notif', (SELECT NRSEQRDR FROM craprdr WHERE nmprogra = 'CCRD0009'));
    COMMIT;	
END;
