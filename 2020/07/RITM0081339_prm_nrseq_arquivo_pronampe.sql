-- PRM para controlar a sequencia de geração de arquivos para o PRONAMPE
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'NRSEQ_ARQUIVO_PRONAMPE', 'Numero sequencial da geração do arquivo do PRONAMPE', '1');

COMMIT;


