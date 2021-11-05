begin

 update crapaca a 
    set a.lstparam = 'pr_cdcooper,pr_nrdconta,pr_nrctrato,pr_flggarad,pr_flgassum'
  where a.nmdeacao = 'ATUALIZA_PROPOSTA_PREST'
    and a.nmpackag = 'TELA_ATENDA_SEGURO'
    and a.nmproced = 'pc_atualiza_dados_prest';
  
commit;

exception

    WHEN others THEN
        rollback;
        raise_application_error(-20501, SQLERRM);
end;