INSERT 
  INTO CECRED.crapaca (NRSEQACA, NMDEACAO, 
                       NMPACKAG, NMPROCED, 
                       LSTPARAM, NRSEQRDR)
VALUES ((SELECT MAX(NRSEQACA) + 1 FROM CECRED.crapaca), 
       'EXCLUI_ENVIO_PUSH', 
       'TELA_ENVNOT', 'pc_exclui_msg_manual', 
       'pr_cdmensagem', 885);

UPDATE CECRED.craptel t
   SET t.CDOPPTEL = 'A,C,N,E'
     , t.LSOPPTEL = 'ALTERACAO,CONSULTA,CADASTRAR/ENVIAR,EXCLUIR'
 WHERE t.NMDATELA = 'ENVNOT';


INSERT 
  INTO CECRED.crapaca (NRSEQACA, NMDEACAO, 
                       NMPACKAG, NMPROCED, 
                       LSTPARAM, NRSEQRDR)
VALUES ((SELECT MAX(NRSEQACA) + 1 FROM CECRED.crapaca), 
       'LISTA_CONSULTA_GERAL', 
       'TELA_ENVNOT', 'pc_lista_mensagens_manuais_geral', 
       'pr_dtinicionotificacoes, pr_dtfimnotificacoes, pr_flgcalcestatistica', 885);
	   
	   
COMMIT;
