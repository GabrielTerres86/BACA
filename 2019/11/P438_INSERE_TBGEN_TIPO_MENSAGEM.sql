-- Inclui tipo de mensagem para propostas aprovadas e disponíveis para contratação no PA.
insert into TBGEN_TIPO_MENSAGEM (CDTIPO_MENSAGEM, DSTIPO_MENSAGEM, CDPRODUTO, DSOBSERVACAO, DSAGRUPADOR)
values (23, 'SMS para emprestimo aprovado - AIMARO', 31, 'Os campos #Cooperado# e #Proposta# serão preenchidos automaticamente pelo sistema.', null);

-- Inclui tipo de mensagem para propostas aprovadas e disponíveis para contratação no IB.
insert into TBGEN_TIPO_MENSAGEM (CDTIPO_MENSAGEM, DSTIPO_MENSAGEM, CDPRODUTO, DSOBSERVACAO, DSAGRUPADOR)
values (24, 'SMS para emprestimo aprovado - INTERNET', 31, 'Os campos #Cooperado# e #Proposta# serão preenchidos automaticamente pelo sistema.', null);

COMMIT;
