declare
  vr_nrseqrdr craprdr.nrseqrdr%TYPE := 0;
BEGIN
  INSERT INTO craprdr(nrseqrdr,nmprogra,dtsolici) VALUES (((select max(nrseqrdr) from craprdr) + 1),'TCARGA',SYSDATE) returning craprdr.nrseqrdr into vr_nrseqrdr;
  INSERT INTO crapaca(nmdeacao 
             ,nmpackag 
             ,nmproced             
             ,nrseqrdr)
         VALUES('VERIFICAAMBIENTE' -- nmdeacao
             ,'tela_tcarga'-- nmpackag
             ,'pc_verifica_ambiente'-- nmproced                      
             ,vr_nrseqrdr); -- nrseqrdr
  INSERT INTO crapaca(nmdeacao 
             ,nmpackag 
             ,nmproced             
             ,nrseqrdr)
         VALUES('VERIFICAEXECUCAO' -- nmdeacao
             ,'tela_tcarga'-- nmpackag
             ,'pc_verifica_execucao'-- nmproced                      
             ,vr_nrseqrdr); -- nrseqrdr
  INSERT INTO crapaca(nmdeacao 
             ,nmpackag 
             ,nmproced             
             ,nrseqrdr
             ,lstparam)
         VALUES('SOLICITACARGA' -- nmdeacao
             ,'tela_tcarga'-- nmpackag
             ,'pc_solicita_teste_carga'-- nmproced                      
             ,vr_nrseqrdr
             ,'pr_cooperativas, pr_mensagens, pr_quantidade'); -- nrseqrdr
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
  NULL;
END;