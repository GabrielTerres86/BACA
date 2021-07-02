declare
begin
  insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  values ('BUSCA_NOME_FORNECEDOR', 'TELA_CALRIS', 'pc_busca_nome_fornecedor', 'pr_nrcpfcgc', 2184);

  insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  values ('BUSCA_NOME_CANDIDATO', 'TELA_CALRIS', 'pc_busca_nome_candidato', 'pr_nrcpfcgc', 2184);

  UPDATE crapaca x
    SET x.lstparam = 'pr_idcalris_pessoa,pr_dsjustificativa,pr_cdclasrisco_espe_aten,pr_cdclasrisco_list_rest,pr_cdclasrisco_list_inte,pr_cdclasrisco_final,pr_tprelacionamento,pr_dtproxcalculo,pr_cdstatus'
  WHERE x.nmdeacao = 'ALTERA_CLASSIF_RISCO'
    AND x.nmpackag = 'TELA_CALRIS';

  UPDATE crapaca x
    SET x.lstparam = 'pr_nrcpfcgc,pr_nriniseq,pr_nrregist,pr_tpcalculadora'
  WHERE x.nmdeacao = 'LISTA_VERSAO_PESSOA'
    AND x.nmpackag = 'TELA_CALRIS';

  UPDATE crapaca x
    SET x.lstparam = 'pr_dtinicio,pr_dtfim,pr_status,pr_tppessoa,pr_nriniseq,pr_nrregist,pr_cdclasrisco,pr_tpcooperado'
  WHERE x.nmdeacao = 'BUSCA_TANQUE'
    AND x.nmpackag = 'TELA_CALRIS';

  UPDATE crapaca x
    SET x.lstparam = 'pr_dtinicio,pr_dtfim,pr_status,pr_tppessoa,pr_cdopcao,pr_cdclasrisco,pr_tpcooperado'
  WHERE x.nmdeacao = 'MANUTENCAO_TANQUE_TODOS'
    AND x.nmpackag = 'TELA_CALRIS';
commit;
exception
	when others then
		ROLLBACK;
		INSERT INTO cecred.tbgen_erro_sistema
            (cdcooper            
            ,dherro
            ,dserro
            ,nrsqlcode)
          VALUES
            (0
            ,SYSDATE
            , 'Parte 3 acoes - ' ||
			 dbms_utility.format_error_backtrace || ' - ' ||
             dbms_utility.format_error_stack
            ,20011);
			Commit;
end;
/