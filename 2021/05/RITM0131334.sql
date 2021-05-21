begin
  update crapaca set lstparam = 'pr_cdcooper,pr_nrdconta,pr_cdtipmov,pr_cdmodali,pr_vlbloque,pr_nroficio,pr_nrproces,pr_dsjuizem,pr_dsresord,pr_flblcrft,pr_dtenvres,pr_vlrsaldo,pr_cdoperad,pr_dsinfadc,pr_email' where nmdeacao = 'INCLUI_BLOQUEIO';
  commit;
end;