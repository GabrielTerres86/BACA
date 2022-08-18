INSERT 
  INTO CECRED.crapaca (NRSEQACA, NMDEACAO, 
                       NMPACKAG, NMPROCED, 
                       LSTPARAM, NRSEQRDR)
VALUES ((SELECT MAX(NRSEQACA) + 1 FROM CECRED.crapaca), 
       'LISTA_CONSULTA_GERAL', 
       'TELA_ENVNOT', 'pc_lista_mensagens_manuais_geral', 
       'pr_dtinicionotificacoes, pr_dtfimnotificacoes, pr_flgcalcestatistica', 885);
	   
	   
COMMIT;
