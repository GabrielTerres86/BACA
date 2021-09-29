declare
  vr_nrseqrdr craprdr.nrseqrdr%TYPE := 0;
BEGIN
  INSERT INTO craprdr(nmprogra,dtsolici) VALUES ('TCARGA',SYSDATE) returning craprdr.nrseqrdr into vr_nrseqrdr;
  INSERT INTO crapaca(nmdeacao 
             ,nmpackag 
             ,nmproced)
         VALUES('VERIFICAAMBIENTE' -- nmdeacao
             ,'tela_tcarga'-- nmpackag
             ,'pc_verifica_ambiente'-- nmproced 
             );
  INSERT INTO crapaca(nmdeacao 
             ,nmpackag 
             ,nmproced)
         VALUES('VERIFICAEXECUCAO' -- nmdeacao
             ,'tela_tcarga'-- nmpackag
             ,'pc_verifica_execucao'-- nmproced                      
             ); -- nrseqrdr
  INSERT INTO crapaca(nmdeacao 
             ,nmpackag 
             ,nmproced
             ,lstparam)
         VALUES('SOLICITACARGA' -- nmdeacao
             ,'tela_tcarga'-- nmpackag
             ,'pc_solicita_teste_carga'-- nmproced                                   
             ,'pr_cooperativas, pr_mensagens, pr_quantidade'); -- nrseqrdr
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
  NULL;
END;
