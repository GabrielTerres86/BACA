----------------------------Ribeiro------------------------------------------
-- Cadastro relatorio proposta_prestamista_contributario
BEGIN
  UPDATE tbseg_historico_relatorio t SET t.fltpcusteio = 1;

  INSERT INTO cecred.tbseg_historico_relatorio
    (cdacesso, dstexprm, dsvlrprm, dtinicio, fltpcusteio)
  VALUES
    ('PROPOSTA_PREST_CONTRIB',
     'Relatório Prestamista contributário',
     'proposta_prestamista_contributario.jasper',
     TRUNC(SYSDATE),
     0);
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;     
END;
/
-- Cadastro do relatorio 820
BEGIN
  FOR rw_crapcop in (SELECT cdcooper FROM crapcop) LOOP
    INSERT INTO cecred.craprel
      (cdrelato,
       nrviadef,
       nrviamax,
       nmrelato,
       nrmodulo,
       nmdestin,
       nmformul,
       indaudit,
       cdcooper,
       periodic,
       tprelato,
       inimprel,
       ingerpdf)
    values
      (820,
       '1',
       '999',
       'ARQUIVO PRESTAMISTA INADIMPLENTES',
       '1',
       'PRESTAMISTA',
       '234col',
       '0',
       rw_crapcop.cdcooper,
       'Mensal',
       '1',
       '1',
       '1');
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/
--- Chave SEGPRE
BEGIN
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES('CRED', 0, 'UTILIZA_REGRAS_SEGPRE', 'Utiliza novas regras prestamista SEGPRE S (SIM) e N (NÃO)', 'N');
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
-- TELA SEGPRE
BEGIN
	UPDATE CRAPACA SET LSTPARAM = LSTPARAM ||', PR_TPCUSTEI' where NMPACKAG = 'TELA_SEGPRE' AND NMDEACAO = 'SEGPRE_CONSULTAR';
	COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
-- TELA LCREDI
BEGIN
  UPDATE crapaca c
     SET c.lstparam = c.lstparam || ',pr_tpcuspr'
   WHERE c.nmpackag = 'TELA_LCREDI'
     AND c.nmproced IN ('pc_alterar_linha_credito','pc_incluir_linha_credito');
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
-- COOPERATIVA CUSTEIO PADRAO
BEGIN
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
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/
-- TELA SEGPRE
BEGIN
  UPDATE crapaca c
     SET c.lstparam = REPLACE(c.lstparam, 'NRAPOLIC', 'APOLICO')
   WHERE c.nmpackag = 'TELA_SEGPRE'
     AND c.lstparam LIKE '%NRAPOLIC%';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/
-- TELA SEGPRE
BEGIN
  UPDATE crapaca c
     SET c.lstparam = c.lstparam || ', PR_PAGSEGU, PR_SEQARQU, PR_APOLINC'
   WHERE c.nmpackag = 'TELA_SEGPRE'
     AND c.nmproced = 'pc_alterar';
    COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
------------------RAIZA-------------------
--crapaca
BEGIN
	insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ((select max(NRSEQACA) + 1 from crapaca), 'ATUALIZA_PROPOSTA_PREST', 'TELA_ATENDA_SEGURO','pc_atualiza_dados_prest','pr_cdcooper,pr_nrdconta,pr_nrctrato,pr_flggarad,pr_flgassum',
	(select nrseqrdr from CRAPRDR WHERE nmprogra = 'TELA_ATENDA_SEGURO')); insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ((select max(NRSEQACA) + 1 from crapaca), 'CONSULTA_CRAPLCR_TPCUSPR', 'TELA_ATENDA_SEGURO','pc_retorna_tpcuspr','pr_cdcooper,pr_cdlcremp,pr_nrdconta',
	(select nrseqrdr from CRAPRDR WHERE nmprogra = 'TELA_ATENDA_SEGURO')); insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ((select max(NRSEQACA) + 1 from crapaca), 'RETORNA_DADOS_SEGPRE', 'TELA_ATENDA_SEGURO','pc_retorna_dados_segpre','pr_cdcooper,pr_nrdconta,pr_nrctrseg,pr_nrctremp',
	(select nrseqrdr from CRAPRDR WHERE nmprogra = 'TELA_ATENDA_SEGURO')); insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ((select max(NRSEQACA) + 1 from crapaca), 'RETORNA_DADOS_PREST', 'SEGU0003','pc_retorna_dados_prest','pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_nrctrseg,pr_flggarad',
	(select nrseqrdr from CRAPRDR WHERE nmprogra = 'SEGU0003'));
	COMMIT;
EXCEPTION WHEN OTHERS THEN
	ROLLBACK;
END;
/
-- TODAS AS LINHAS DE CREDITO PARA CONTRIBUTARIO
BEGIN
  UPDATE CRAPLCR SET TPCUSPR = 0;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
-- PERMISSAO
BEGIN
  INSERT INTO crapace(nmdatela,
                      cddopcao,
                      cdoperad,
                      nmrotina,
                      cdcooper,
                      nrmodulo,
                      idevento,
                      idambace)
   (SELECT 'SEGPRE',
           cddopcao,
           cdoperad,
           nmrotina,
           cdcooper,
           nrmodulo,
           idevento,
           idambace
      FROM CRAPACE 
     WHERE NMDATELA = 'TAB049');
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/