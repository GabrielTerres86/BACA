declare
begin

UPDATE cecred.tbgen_analise_fraude_param
   SET vlcorte_envio_topaz = 98
WHERE cdoperacao in (16,17);

UPDATE cecred.crapaca
   SET lstparam = 'pr_cdoperacao,pr_tpoperacao,pr_hrretencao,pr_strhoraminutos,pr_flgemail_entrega,pr_dsemail_entrega,pr_dsassunto_entrega,pr_dscorpo_entrega,pr_flgemail_retorno,pr_dsemail_retorno,pr_dsassunto_retorno,pr_dscorpo_retorno,pr_flgativo,pr_tpretencao,pr_vlcorteofs,pr_flgenvio_nao_util,pr_vlcortetopaz'
WHERE nmdeacao = 'CADFRA_GRAVA'
and nmproced = 'pc_grava_dados';

commit;
end;
/