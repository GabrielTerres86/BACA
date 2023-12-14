BEGIN
    update crapaca set lstparam = 'pr_cdtarcom,pr_dtinicom,pr_dtfimcom,pr_pedescom,pr_cdtarcob,pr_dtinicob,pr_dtfimcob,pr_pedescob,pr_dsjustif,pr_cdaprova,pr_cdoperad,pr_cdcooper,pr_nrdconta' where nmdeacao = 'INCLUI_DESCONTO_PIX'; 
    COMMIT;
END;