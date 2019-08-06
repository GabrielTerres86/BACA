DECLARE
  
  -- Buscar registro da RDR
  CURSOR cr_craprdr IS
    SELECT t.nrseqrdr
      FROM craprdr t
     WHERE t.NMPROGRA = 'VERLOG';
  
  -- Variaveis
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  
BEGIN
  
  -- Buscar RDR
  OPEN  cr_craprdr;
  FETCH cr_craprdr INTO vr_nrseqrdr;
  
  -- Se nao encontrar
  IF cr_craprdr%NOTFOUND THEN
  
  INSERT INTO craprdr(nmprogra,dtsolici)
       VALUES('VERLOG', SYSDATE)
       RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
  
  END IF;
  
  -- Fechar o cursor
  CLOSE cr_craprdr;

  INSERT INTO crapaca(nmpackag, nmdeacao, nmproced, lstparam, nrseqrdr) VALUES ('TELA_VERLOG','BUSCA_LOGS','pc_busca_logs','pr_cdcooperativa,pr_nrdconta,pr_dtopeini,pr_dtopefin,pr_dsorigem,pr_cdoperad,pr_dstransa,pr_pagina,pr_idseqttl',vr_nrseqrdr);
  INSERT INTO crapaca(nmpackag, nmdeacao, nmproced, lstparam, nrseqrdr) VALUES ('TELA_VERLOG','BUSCA_LOG_ITENS','pc_busca_log_itens','pr_dsrowid',vr_nrseqrdr);

  COMMIT;
  
  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Referencia a VERLOG criado com sucesso!');
  
END;
