declare
vr_nrseqrdr craprdr.nrseqrdr%TYPE := 0;
BEGIN
INSERT INTO craprdr(nmprogra,dtsolici) VALUES ('TCARGA',SYSDATE) returning craprdr.nrseqrdr into vr_nrseqrdr;
INSERT INTO crapaca(nmdeacao
					,nmpackag
					,nmproced
					,nrseqrdr)
			 VALUES('VERIFICAAMBIENTE' -- nmdeacao
				   ,'tela_tcarga'-- nmpackag
				   ,'pc_verifica_ambiente'-- nmproced
				   ,vr_nrseqrdr);
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
					,lstparam
					,nrseqrdr)
			VALUES('SOLICITACARGA' -- nmdeacao
			      ,'tela_tcarga'-- nmpackag
                  ,'pc_solicita_teste_carga'-- nmproced
                  ,'pr_cooperativas, pr_mensagens, pr_quantidade'
                  ,vr_nrseqrdr); -- nrseqrdr
COMMIT;
EXCEPTION
WHEN OTHERS THEN
NULL;
END;