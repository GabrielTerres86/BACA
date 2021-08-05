begin
  update crapaca
  set LSTPARAM='pr_nrdconta,pr_inpessoa,pr_idmatriz,pr_idcooperado_cdc,pr_flgconve,pr_fldpposf,pr_dtinicon,pr_inmotcan,pr_dtcancon,pr_dsmotcan,pr_dtrencon,pr_dttercon,pr_nmfantasia,pr_cdcnae,pr_dslogradouro,pr_dscomplemento,pr_nrendereco,pr_nmbairro,pr_nrcep,pr_idcidade,pr_dstelefone,pr_dsemail,pr_nrlatitude,pr_nrlongitude,pr_idcomissao,pr_flgitctr'
  where nmdeacao='CVNCDC_GRAVA';

  commit;
exception
  WHEN others THEN
    rollback;
    raise_application_error(-20501, SQLERRM);
end;
/
