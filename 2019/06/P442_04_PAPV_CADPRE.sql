declare
  vr_nrseqrdr number;
BEGIN

  -- Ajustar opções da tela
  UPDATE craptel tel 
     SET tel.cdopptel = 'A,C'
        ,tel.lsopptel = 'ALTERACAO,CONSULTA'     
  WHERE upper(tel.nmdatela) = 'CADPRE';

  -- Remover acessos de opções desativadas
  DELETE crapace ace
   WHERE upper(ace.nmdatela) = 'CADPRE'
     AND upper(ace.cddopcao) = 'G';

  -- Buscar RDR da CADPRE
  SELECT r.nrseqrdr INTO vr_nrseqrdr
    FROM craprdr r
   WHERE r.nmprogra = 'CADPRE';


  -- Remover ações que serão desativadas (ao final do projeto rodar e remover a procs)
  DELETE crapaca r
   WHERE r.nrseqrdr = vr_nrseqrdr
     AND r.nmdeacao IN('ALTERA_CARGA','CONSULTAR_CARGA','GERAR_CARGA','CADPRE');

  -- Criar novas ações
	INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
               VALUES(vr_nrseqrdr, 'BUSCA_CRAPPRE','TELA_CADPRE','pc_busca_cadpre','pr_inpessoa');
  
	INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
               VALUES(vr_nrseqrdr, 'GRAVA_CRAPPRE','TELA_CADPRE','pc_grava_cadpre','pr_inpessoa,pr_cdfinemp,pr_vllimmin,pr_vllimctr,pr_vlmulpli,pr_qtdiavig,pr_vllimman,pr_vllimaut,pr_dslstali,pr_qtdevolu,pr_qtdiadev,pr_vldiadev,pr_qtctaatr,pr_vlctaatr,pr_qtepratr,pr_vlepratr,pr_qtestour,pr_qtdiaest,pr_vldiaest,pr_qtavlatr,pr_vlavlatr,pr_qtavlope,pr_qtcjgatr,pr_vlcjgatr,pr_qtcjgope,pr_qtcarcre,pr_vlcarcre,pr_qtdtitul,pr_vltitulo');
  commit;
end;
