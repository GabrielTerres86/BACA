-- TELA DE PARÂMETRO PARA HABILITAR BOTÃO DE FORMA DE PAGAMENTO NA TELA ATENDA>PRESTACOES>COPERATIVA PARA CONCEDER PREMISSOES INSERIR NA CRAPACE OU TELA PERMISS

--------------------- Permissoes ---------------------
DECLARE

BEGIN

  FOR rw_crapcop IN (SELECT cdcooper
                       FROM crapcop c
                      WHERE c.flgativo = 1) LOOP

    UPDATE craptel t
       SET t.cdopptel = t.cdopptel || ',FP'
          ,t.lsopptel = t.lsopptel || ',ALTERAR F. PAGTO'
     WHERE t.cdcooper = rw_crapcop.cdcooper
       AND UPPER(t.nmdatela) = 'ATENDA'
	   AND UPPER(t.nmrotina) = 'EMPRESTIMOS';
               
  END LOOP;
COMMIT;
END;
