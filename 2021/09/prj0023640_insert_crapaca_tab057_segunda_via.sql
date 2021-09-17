BEGIN

  INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES ((SELECT MAX(nrseqaca)+1 FROM crapaca), 'TAB057_BUSCA_ARRECADACOES_SEGVIA', 'TELA_TAB057', 'pc_remessa_pagfor_segundavia', 'pr_cdcooper, pr_comprovantesegvia, pr_stproces, pr_dtmsegvia, pr_cdidssegvia, pr_nriniseq, pr_nrregist', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TAB057'));
  
  INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES ((SELECT MAX(nrseqaca)+1 FROM crapaca), 'TAB057_BUSCA_ARRECADACOES_SEGVIA', 'TELA_TAB057', 'pc_atualiza_comprovante_segunda_via', 'pr_idsicredi,pr_dscomprovante', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TAB057'));

  COMMIT;
END;
