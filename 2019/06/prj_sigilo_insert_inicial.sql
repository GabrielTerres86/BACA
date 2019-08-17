DECLARE
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  
  CURSOR c1 IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1;
BEGIN
  INSERT INTO craptel(nmdatela,
                      nrmodulo,
                      cdopptel,
                      tldatela,
                      tlrestel,
                      flgteldf,
                      flgtelbl,
                      lsopptel,
                      inacesso,
                      cdcooper,
                      idsistem,
                      idevento,
                      nrordrot,
                      nrdnivel,
                      idambtel) VALUES ('QBRSIG'
                                             ,5
                                             ,'@,PR,PH,QS'
                                             ,'QUEBRA DE SIGILO BANCARIO'
                                             ,'QUEBRA DE SIGILO BANCARIO'
                                             ,0
                                             ,1
                                             ,'ACESSO,PARAMETRO REGRA,PARAMETRO HISTORICO,QUEBRA DE SIGILO'
                                             ,1
                                             ,3
                                             ,1
                                             ,0
                                             ,1
                                             ,1
                                             ,2);

  INSERT INTO crapprg(nmsistem,
                    cdprogra,
                    dsprogra##1,
                    dsprogra##2,
                    dsprogra##3,
                    dsprogra##4,
                    nrsolici,
                    nrordprg,
                    inctrprg,
                    inlibprg,
                    cdcooper) VALUES ('CRED'
                                     ,'QBRSIG'
                                     ,'Quebra de sigilo bancario'
                                     ,'.'
                                     ,'.'
                                     ,'.'
                                     ,50
                                     ,(SELECT MAX(nrordprg) + 1 FROM crapprg a WHERE a.cdcooper = 3 AND a.nrsolici = 50)
                                     ,1
                                     ,1
                                     ,3);

  INSERT INTO craprdr(nmprogra
                     ,dtsolici) VALUES ('QBRSIG'
                                       ,SYSDATE) RETURNING nrseqrdr INTO vr_nrseqrdr;

  INSERT INTO crapaca(nmdeacao,
                      nmpackag,
                      nmproced,
                      nrseqrdr) VALUES ('QBRSIG_CON_REGRA'
                                       ,'TELA_QBRSIG'
                                       ,'pc_con_regra_qbrsig'
                                       ,vr_nrseqrdr);

  INSERT INTO crapaca(nmdeacao,
                    nmpackag,
                    nmproced,
					lstparam,
                    nrseqrdr) VALUES ('QBRSIG_CON_HISTORICO'
                                     ,'TELA_QBRSIG'
                                     ,'pc_con_historico_qbrsig'
									 ,'pr_cdhistor'
                                     ,vr_nrseqrdr);

  INSERT INTO crapaca(nmdeacao,
                    nmpackag,
                    nmproced,
                    lstparam,
                    nrseqrdr) VALUES ('QBRSIG_SALVAR_HISTORICO'
                                     ,'TELA_QBRSIG'
                                     ,'pc_salvar_historico_qbrsig'
                                     ,'pr_cdhistor,pr_cdhisrec,pr_cdestsig'
                                     ,vr_nrseqrdr);

  INSERT INTO crapaca(nmdeacao,
                    nmpackag,
                    nmproced,
                    lstparam,
                    nrseqrdr) VALUES ('QBRSIG_CON_CONTA'
                                     ,'TELA_QBRSIG'
                                     ,'pc_con_conta_qbrsig'
                                     ,'pr_cdcoptel,pr_nrdconta'
                                     ,vr_nrseqrdr);

  INSERT INTO crapaca(nmdeacao,
                    nmpackag,
                    nmproced,
                    lstparam,
                    nrseqrdr) VALUES ('QBRSIG_CON_QUEBRA'
                                     ,'TELA_QBRSIG'
                                     ,'pc_con_quebra_qbrsig'
                                     ,'pr_nrseq_quebra_sigilo,pr_idsitqbr,pr_iniregis,pr_qtregpag'
                                     ,vr_nrseqrdr);

  INSERT INTO crapaca(nmdeacao,
                      nmpackag,
                      nmproced,
                      lstparam,
                      nrseqrdr) VALUES ('QBRSIG_QUEBRA_SIGILO'
                                       ,'TELA_QBRSIG'
                                       ,'pc_quebra_sigilo'
                                       ,'pr_cdcoptel,pr_nrdconta,pr_dtiniper,pr_dtfimper'
                                       ,vr_nrseqrdr);

  INSERT INTO crapaca(nmdeacao,
                      nmpackag,
                      nmproced,
                      lstparam,
                      nrseqrdr) VALUES ('QBRSIG_GERA_ARQUIVO'
                                       ,'TELA_QBRSIG'
                                       ,'pc_gera_arquivo'
                                       ,'pr_nrseq_quebra_sigilo'
                                       ,vr_nrseqrdr);

  INSERT INTO crapaca(nmdeacao,
                      nmpackag,
                      nmproced,
                      lstparam,
                      nrseqrdr) VALUES ('QBRSIG_SALVAR_INFO'
                                       ,'TELA_QBRSIG'
                                       ,'pc_atualiza_info_qbrsig'
                                       ,'pr_nrseq_quebra_sigilo,pr_nrseqlcm,pr_cdbandep,pr_cdagedep,pr_nrctadep,pr_nrcpfcgc,pr_nmprimtl'
                                       ,vr_nrseqrdr);

  INSERT INTO crapaca(nmdeacao,
                    nmpackag,
                    nmproced,
                    lstparam,
                    nrseqrdr) VALUES ('QBRSIG_REPROCESSAR_QUEBRA'
                                     ,'TELA_QBRSIG'
                                     ,'pc_reprocessar_quebra'
                                     ,'pr_nrseq_quebra_sigilo'
                                     ,vr_nrseqrdr);

  FOR r1 IN c1 LOOP
    INSERT INTO crapprm(nmsistem,
                        cdcooper,
                        cdacesso,
                        dstexprm,
                        dsvlrprm) VALUES ('CRED'
                                         ,r1.cdcooper
                                         ,'QBRSIG_ICF_ATIVO'
                                         ,'Indica se o processo de ICFJUD esta ativo no processo de quebra de sigilo bancario'
                                         ,0);
  END LOOP;

  COMMIT;
END;