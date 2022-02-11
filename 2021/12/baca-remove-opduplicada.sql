DECLARE
BEGIN
  FOR rw_crapcop IN (SELECT cdcooper FROM crapcop c WHERE c.flgativo = 1) LOOP
    DELETE FROM crapace ace
     WHERE UPPER(ace.nmdatela) = 'IMOVEL'
       AND UPPER(ace.cddopcao) = 'M'
       AND UPPER(ace.nmrotina) = ' '
       AND ace.cdcooper = rw_crapcop.cdcooper
       AND ace.idambace = 2;
  
    UPDATE craptel t
       SET t.cdopptel = 'A,B,C,G,I,N,R,X,F,L,P',
           t.lsopptel = 'ALTERAR,BAIXA.MANUAL,CONSULTAR,GERAR,RELATÓRIO,INCLUIR,RECEBER,ALT.POS.ENVIO,INCL. MANUAL,GERA.ARQUIVO,IMPORTACAO.RET.B3'
     WHERE t.cdcooper = rw_crapcop.cdcooper
       AND UPPER(t.nmdatela) = 'IMOVEL';
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
