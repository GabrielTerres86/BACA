declare
vr_nrseqrdr craprdr.nrseqrdr%TYPE := 0;
BEGIN
  -- Insere registro pai
INSERT INTO craprdr(nmprogra,dtsolici) VALUES ('TCARGA',SYSDATE);
-- Insere registros filhos
INSERT INTO crapaca(nmdeacao
					,nmpackag
					,nmproced
					,nrseqrdr)
			 VALUES('VERIFICAAMBIENTE' -- nmdeacao
				   ,'tela_tcarga'-- nmpackag
				   ,'pc_verifica_ambiente'-- nmproced
				   ,(select craprdr.nrseqrdr from craprdr where nmprogra='TCARGA'));
INSERT INTO crapaca(nmdeacao
					,nmpackag
					,nmproced
					,nrseqrdr)
			VALUES('VERIFICAEXECUCAO' -- nmdeacao
				  ,'tela_tcarga'-- nmpackag
			      ,'pc_verifica_execucao'-- nmproced
			      ,(select craprdr.nrseqrdr from craprdr where nmprogra='TCARGA')); -- nrseqrdr
INSERT INTO crapaca(nmdeacao
					,nmpackag
					,nmproced
					,lstparam
					,nrseqrdr)
			VALUES('SOLICITACARGA' -- nmdeacao
			      ,'tela_tcarga'-- nmpackag
            ,'pc_solicita_teste_carga'-- nmproced
            ,'pr_cooperativas, pr_mensagens, pr_quantidade'
            ,(select craprdr.nrseqrdr from craprdr where nmprogra='TCARGA')); -- nrseqrdr
COMMIT;
EXCEPTION
WHEN OTHERS THEN
NULL;
END;
