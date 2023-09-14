begin
update cecred.crapaca c set c.lstparam = c.lstparam || ',pr_flmigrado'  
where c.nmpackag ='TELA_CONVEN' AND c.nmproced = 'pc_grava_conv_ailos'
and c.nmdeacao = 'GRAVAR_DADOS_CONVEN_AILOS';
commit;
end;
