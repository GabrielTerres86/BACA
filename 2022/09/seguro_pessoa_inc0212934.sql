BEGIN
  UPDATE cecred.crapaca p
     SET p.lstparam = 'pr_cdcooper,pr_nrdconta,pr_nrctrato,pr_flggarad,pr_flgassum,pr_tpcustei,pr_flgsegma,pr_flfinanciasegprestamista'
   WHERE p.nmpackag = 'TELA_ATENDA_SEGURO'
     AND p.nmdeacao = 'ATUALIZA_PROPOSTA_PREST';
  COMMIT;
END;
/
