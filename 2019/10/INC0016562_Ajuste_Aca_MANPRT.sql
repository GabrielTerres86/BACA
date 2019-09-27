BEGIN
    UPDATE crapaca
       SET lstparam = 'pr_cdcooper_usr,pr_cdcooperativa,pr_nrdconta,pr_dtinicial,pr_dtfinal,pr_cdestado,pr_cartorio,pr_flcustas'
     WHERE lower(nmproced) = 'pc_exporta_consulta_custas'
       AND lower(nmpackag) = 'tela_manprt';
END;