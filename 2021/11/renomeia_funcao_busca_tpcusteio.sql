begin

 UPDATE CRAPACA SET NMPROCED = 'pc_retorna_tpcuspr'
WHERE NMDEACAO = 'CONSULTA_CRAPLCR_TPCUSPR'
AND NMPACKAG = 'TELA_ATENDA_SEGURO';
  
commit;

exception

    WHEN others THEN
        rollback;
        raise_application_error(-20501, SQLERRM);
end;