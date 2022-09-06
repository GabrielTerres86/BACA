BEGIN		
	UPDATE CRAPACA
	   SET LSTPARAM = 'pr_cdcooper,pr_nrdconta,pr_nrctrato,pr_flggarad,pr_flgassum,pr_tpcustei,pr_flgsegma,pr_flfinanciasegprestamista'
	 WHERE NMPACKAG = 'TELA_ATENDA_SEGURO'
	   AND NMDEACAO = 'ATUALIZA_PROPOSTA_PREST';
	 
    COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/
