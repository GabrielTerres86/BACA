BEGIN

   INSERT INTO cecred.crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
   VALUES('BUSCA_TOTAL_BLOQ_PIX', 'TELA_ATENDA_DEPOSVIS', 'pc_consulta_vltotal_bloqueio_pix', 'pr_cdcooper, pr_nrdconta', 1166);
   
   COMMIT;
   
   EXCEPTION
     WHEN DUP_VAL_ON_INDEX THEN
       BEGIN
         ROLLBACK;
         RAISE_APPLICATION_ERROR(-20000, 'CHAVE DUPLICADA' ||SQLERRM);
       END;
       
     WHEN OTHERS THEN
       BEGIN
         ROLLBACK;
         RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' ||SQLERRM);
       END;
   
END;