BEGIN

	UPDATE crapaca c
	SET c.lstparam = lstparam || ',pr_tpcustei'
    WHERE c.nmpackag = 'SEGU0001'
	AND c.nmdeacao = 'CRIA_PROPOSTA_SEGURO';

	UPDATE crapaca a 
	SET a.lstparam = 'pr_nrdconta ,pr_idseqttl ,pr_dtmvtolt ,pr_cddopcao ,pr_nrsimula ,pr_cdlcremp ,pr_vlemprst ,pr_qtparepr ,pr_dtlibera ,pr_dtdpagto ,pr_percetop ,pr_cdfinemp ,pr_idfiniof ,pr_flggrava ,pr_idpessoa ,pr_nrseq_email ,pr_nrseq_telefone ,pr_idsegmento ,pr_tpemprst ,pr_idcarenc ,pr_dtcarenc, pr_flgerlog,pr_vlparepr,pr_vliofepr,pr_riscovariavel, pr_flgassum, pr_flggarad'
	WHERE nmpackag = 'TELA_ATENDA_SIMULACAO' 
	AND NMDEACAO = 'SIMULA_GRAVA_SIMULACAO';

	UPDATE cecred.crapprm p
	SET p.DSVLRPRM = '0'
	WHERE p.cdacesso like '%TPCUSTEI_PADRAO%'
	AND p.NMSISTEM = 'CRED'
	AND p.CDCOOPER in (9,13);

  COMMIT;
  EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
	
END;