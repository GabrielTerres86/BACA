BEGIN
  UPDATE crapaca c
     SET c.lstparam = lstparam || ', pr_flgassum, pr_flggarad'
   WHERE c.nmpackag = 'TELA_ATENDA_SIMULACAO'
     AND c.nmdeacao = 'SIMULA_GRAVA_SIMULACAO';
	 
  INSERT INTO crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	VALUES ((select max(NRSEQACA) + 1 from crapaca), 'CONSULTA_CRAPLCR_TPCUSPR', 'TELA_ATENDA_SEGURO','pc_retorna_tpcuspr','pr_cdcooper,pr_cdlcremp,pr_nrdconta,pr_nrctremp,pr_vlemprst,pr_qtpreemp',
	(SELECT nrseqrdr from CRAPRDR WHERE nmprogra = 'TELA_ATENDA_SEGURO')); 

  INSERT INTO crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	VALUES ((select max(NRSEQACA) + 1 from crapaca), 'ATUALIZA_PROPOSTA_PREST', 'TELA_ATENDA_SEGURO','pc_atualiza_dados_prest','pr_cdcooper,pr_nrdconta,pr_nrctrato,pr_flggarad,pr_flgassum,pr_tpcustei',
	(SELECT nrseqrdr from CRAPRDR WHERE nmprogra = 'TELA_ATENDA_SEGURO')); 
	 
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES('CRED', 0, 'FIM_VIG_PRESTAMISTA', 'Quantidade de anos para fim de vigência contratação seguro prestamista', '5');	 
	
	
  UPDATE crapaca c
     SET c.lstparam = 'pr_cdlcremp,pr_dslcremp,pr_tpctrato,pr_txjurfix,pr_txjurvar,pr_txpresta,pr_qtdcasas,pr_nrinipre,pr_nrfimpre,pr_txbaspre,pr_qtcarenc,pr_vlmaxass,pr_vlmaxasj,pr_txminima,pr_txmaxima,pr_perjurmo,pr_tpdescto,pr_nrdevias,pr_cdusolcr,pr_flgtarif,pr_flgtaiof,pr_vltrfesp,pr_flgcrcta,pr_dsoperac,pr_dsorgrec,pr_manterpo,pr_flgimpde,pr_flglispr,pr_tplcremp,pr_cdmodali,pr_cdsubmod,pr_flgrefin,pr_flgreneg,pr_qtrecpro,pr_consaut,pr_flgdisap,pr_flgcobmu,pr_flgsegpr,pr_cdhistor,pr_flprapol,pr_tpprodut,pr_cddindex,pr_permingr,pr_vlperidx,pr_tpmodcon,pr_vlmaxopr,pr_perisco_r1,pr_perisco_r2,pr_perisco_r3,pr_perisco_r4,pr_perisco_r5,pr_perisco_r6,pr_perisco_r7,pr_perisco_r8,pr_perisco_r9,pr_perisco_r10,pr_perisco_r11,pr_perisco_r12,pr_perisco_r13,pr_perisco_r14,pr_perisco_r15,pr_perisco_r16,pr_perisco_r17,pr_perisco_r18,pr_perisco_r19,pr_perisco_r20,pr_perisco_r21,pr_perisco_r22,pr_perisco_r23,pr_perisco_r24,pr_perisco_r25,pr_perisco_r26,pr_perisco_r27,pr_perisco_r28,pr_perisco_r29,pr_perisco_r30,pr_perisco_r31,pr_perisco_r32,pr_perisco_r33,pr_perisco_r34,pr_perisco_r35,pr_perisco_r36,pr_perisco_r37,pr_perisco_r38,pr_perisco_r39,pr_perisco_r40,pr_perisco_r41,pr_perisco_r42,pr_perisco_r43,pr_perisco_r44,pr_perisco_r45,pr_flgrepro,pr_flgdigit,pr_reccateg,pr_tpcuspr'
   WHERE c.nmpackag = 'TELA_LCREDI'
     AND c.nmproced IN ('pc_alterar_linha_credito');
	 
  UPDATE crapaca c
     SET c.lstparam = 'pr_cdlcremp,pr_dslcremp,pr_tpctrato,pr_txjurfix,pr_txjurvar,pr_txpresta,pr_qtdcasas,pr_nrinipre,pr_nrfimpre,pr_txbaspre,pr_qtcarenc,pr_vlmaxass,pr_vlmaxasj,pr_txminima,pr_txmaxima,pr_perjurmo,pr_tpdescto,pr_nrdevias,pr_cdusolcr,pr_flgtarif,pr_flgtaiof,pr_vltrfesp,pr_flgcrcta,pr_dsoperac,pr_dsorgrec,pr_manterpo,pr_flgimpde,pr_flglispr,pr_tplcremp,pr_cdmodali,pr_cdsubmod,pr_flgrefin,pr_flgreneg,pr_qtrecpro,pr_consaut,pr_flgdisap,pr_flgcobmu,pr_flgsegpr,pr_cdhistor,pr_flprapol,pr_cdfinali,pr_tpprodut,pr_cddindex,pr_permingr,pr_vlperidx,pr_tpmodcon,pr_vlmaxopr,pr_perisco_r1,pr_perisco_r2,pr_perisco_r3,pr_perisco_r4,pr_perisco_r5,pr_perisco_r6,pr_perisco_r7,pr_perisco_r8,pr_perisco_r9,pr_perisco_r10,pr_perisco_r11,pr_perisco_r12,pr_perisco_r13,pr_perisco_r14,pr_perisco_r15,pr_perisco_r16,pr_perisco_r17,pr_perisco_r18,pr_perisco_r19,pr_perisco_r20,pr_perisco_r21,pr_perisco_r22,pr_perisco_r23,pr_perisco_r24,pr_perisco_r25,pr_perisco_r26,pr_perisco_r27,pr_perisco_r28,pr_perisco_r29,pr_perisco_r30,pr_perisco_r31,pr_perisco_r32,pr_perisco_r33,pr_perisco_r34,pr_perisco_r35,pr_perisco_r36,pr_perisco_r37,pr_perisco_r38,pr_perisco_r39,pr_perisco_r40,pr_perisco_r41,pr_perisco_r42,pr_perisco_r43,pr_perisco_r44,pr_perisco_r45,pr_flgrepro,pr_flgdigit,pr_reccateg,pr_tpcuspr'
   WHERE c.nmpackag = 'TELA_LCREDI'
     AND c.nmproced IN ('pc_incluir_linha_credito');
	
  FOR st_cdcooper IN (SELECT c.cdcooper FROM crapcop c) LOOP
    INSERT INTO crapprm
      (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES
      ('CRED',
       st_cdcooper.cdcooper,
       'TPCUSTEI_PADRAO',
       'Valor padrão do tipo de custeio para cadastro de uma nova linha de crédito',
       '1');
  END LOOP;
  
  UPDATE craplcr SET tpcuspr = 0 WHERE cdcooper IN (9,13);	
	
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
