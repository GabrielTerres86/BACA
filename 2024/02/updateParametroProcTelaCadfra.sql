BEGIN
    UPDATE CECRED.CRAPACA SET LSTPARAM = 'pr_cdoperacao,pr_tpoperacao,pr_hrretencao,pr_strhoraminutos,pr_flgemail_entrega,pr_dsemail_entrega,pr_dsassunto_entrega,pr_dscorpo_entrega,pr_flgemail_retorno,pr_dsemail_retorno,pr_dsassunto_retorno,pr_dscorpo_retorno,pr_flgativo,pr_tpretencao,pr_vlcorteofs,pr_vlcortegeo,pr_flgenvio_nao_util,pr_vlcortetopaz'
    WHERE NMPACKAG = 'TELA_CADFRA' AND NMPROCED = 'pc_grava_dados' AND NMDEACAO = 'CADFRA_GRAVA';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN 
   ROLLBACK;  
END;