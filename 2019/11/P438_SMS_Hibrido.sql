-- Inclui tipo de mensagem para propostas aprovadas e disponíveis para contratação no IB.
insert into TBGEN_TIPO_MENSAGEM (CDTIPO_MENSAGEM, DSTIPO_MENSAGEM, CDPRODUTO, DSOBSERVACAO, DSAGRUPADOR)
values (25, 'SMS para emprestimo aprovado - HIBRIDO', 31, 'Os campos #Cooperado# e #Proposta# serão preenchidos automaticamente pelo sistema.', null);

COMMIT;

BEGIN
  FOR rw_crapcop IN (SELECT cdcooper FROM crapcop c WHERE c.flgativo = 1) LOOP   
    -- Insere mensagem de emprestimo aprovado - HIBRIDO
    insert into TBGEN_MENSAGEM (CDCOOPER, CDPRODUTO, CDTIPO_MENSAGEM, DSMENSAGEM)
    values (rw_crapcop.cdcooper, 31, 25, 'Cooperado #Cooperado#, sua proposta de empréstimo nº #Proposta# foi aprovada. Visite seu Posto de Atendimento ou acesse sua conta online para contratação.');

  END LOOP;
  COMMIT;
END;
