BEGIN
    UPDATE cecred.crapaca a
    SET a.lstparam = a.lstparam||',pr_flsituacao'
    where a.nmdeacao = 'CONSULTA_CONTRATOS_LI'
    AND a.nmpackag = 'TELA_PRONAM';
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END;