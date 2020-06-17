/* Opção E/H - Ajuste de parametro */
update crapaca aca
set aca.lstparam = 'pr_cdcooper, pr_nrdconta, pr_operacao,pr_dtgerini,pr_dtgerfim,pr_situacao'
where aca.nmpackag = 'PGTA0001' 
and   aca.nmproced = 'pc_consulta_arquivo_remessa'; 

commit;
