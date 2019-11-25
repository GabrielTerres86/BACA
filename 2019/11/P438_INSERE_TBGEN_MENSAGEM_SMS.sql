BEGIN
  FOR rw_crapcop IN (SELECT cdcooper FROM crapcop c WHERE c.flgativo = 1) LOOP   
    -- Insere mensagem de emprestimo aprovado - AIMARO
    insert into TBGEN_MENSAGEM (CDCOOPER, CDPRODUTO, CDTIPO_MENSAGEM, DSMENSAGEM)
    values (rw_crapcop.cdcooper, 31, 23, 'Cooperado, sua proposta de empréstimo número #Proposta# foi aprovada. Visite seu Posto de Atendimento para contratação.');

    -- Insere mensagem de emprestimo aprovado - INTERNET
    insert into TBGEN_MENSAGEM (CDCOOPER, CDPRODUTO, CDTIPO_MENSAGEM, DSMENSAGEM)
    values (rw_crapcop.cdcooper, 31, 24, 'Cooperado, sua proposta de empréstimo número #Proposta# foi aprovada. Para contratar acesse os canais digitais.');

  END LOOP;
  COMMIT;
END;

