BEGIN
  DECLARE
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de novos parâmetros da Renegociação Facilitada para Canais (tabela crapprm)';
    CURSOR cr_crapcop IS
    SELECT *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
    --
  BEGIN
    FOR rw_crapcop IN cr_crapcop LOOP
      --
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED', rw_crapcop.cdcooper, 'QT_MAXMESENVAN_RENCAN', 'Meses decorridos para controle de maximo de envios para analise',6);
      --
    END LOOP;
    --
    UPDATE crapaca SET lstparam = lstparam || ',pr_qtmsenva' WHERE nmdeacao = 'TAB089_ALTERAR_RENEG';
    --
    COMMIT;
    dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
    ROLLBACK;
  END;
END;
