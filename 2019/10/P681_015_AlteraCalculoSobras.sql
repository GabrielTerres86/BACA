BEGIN 
       UPDATE crapaca
          SET lstparam = 'pr_ininccmi,pr_increret,pr_txretorn,pr_txjurcap,pr_txjurapl,pr_txjursdm,pr_txjurtar,pr_txreauat,pr_inpredef,pr_indeschq,pr_indemiti,pr_indestit,pr_unsobdep,pr_dssopfco,pr_dssopjco,pr_inentpub,pr_txretcrd'
        WHERE nmdeacao = 'ALTERA_CALC_SOBRAS'
          AND nmpackag = 'TELA_SOL030'
          AND nmproced = 'pc_altera_calculo_sobras';
       
       COMMIT;
				
       
END;
