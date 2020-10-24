begin
  --
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'MONITORAMENTO_EMAIL_PIX', 'Email de destino dos monitoramentos.', 'monitoracaodefraudes@ailos.coop.br');
  --
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'MONITORAMENTO_FLAG_PIX', 'Flag ativo/inativo para enviar email de monitoramentos.', '1');
  --
  insert into tbgen_analise_fraude_param (CDOPERACAO, TPOPERACAO, HRRETENCAO, FLGEMAIL_ENTREGA, DSEMAIL_ENTREGA, DSASSUNTO_ENTREGA, DSCORPO_ENTREGA, FLGEMAIL_RETORNO, DSEMAIL_RETORNO, DSASSUNTO_RETORNO, DSCORPO_RETORNO, FLGATIVO, TPRETENCAO, VLCORTE_ENVIO_OFSAA, FLGENVIO_DIA_NUTIL)
  values (17, 1, null, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha na entrega do PIX Externo (Outros bancos) para a análise do sistema antifraude.', null, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha no retorno da análise do PIX Externo (Outros bancos) do sistema antifraude.', null, 1, 1, 0, 1);
  --
  insert into tbgen_analise_fraude_param (CDOPERACAO, TPOPERACAO, HRRETENCAO, FLGEMAIL_ENTREGA, DSEMAIL_ENTREGA, DSASSUNTO_ENTREGA, DSCORPO_ENTREGA, FLGEMAIL_RETORNO, DSEMAIL_RETORNO, DSASSUNTO_RETORNO, DSCORPO_RETORNO, FLGATIVO, TPRETENCAO, VLCORTE_ENVIO_OFSAA, FLGENVIO_DIA_NUTIL)
  values (16, 1, null, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha na entrega do PIX Interno (Sistema Ailos) para a análise do sistema antifraude.', null, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha no retorno da análise do PIX Interno (Sistema Ailos) do sistema antifraude.', null, 1, 1, 0, 1);
  --
  insert into tbcc_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('CDOPERAC_ANALISE_FRAUDE', '16', 'PXI');
  --
  insert into tbcc_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('CDOPERAC_ANALISE_FRAUDE', '17', 'PXE');
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (16, 1, 0, 21540, 20);
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (16, 1, 57600, 71940, 10);
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (16, 1, 72000, 86340, 15);
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (16, 1, 21600, 57540, 15);
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (17, 1, 0, 21540, 15);
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (17, 1, 57600, 71940, 5);
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (17, 1, 72000, 86340, 10);
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (17, 1, 21600, 57540, 10);
  --
  insert into tbcc_produto (CDPRODUTO, DSPRODUTO, FLGITEM_SOA, FLGUTILIZA_INTERFACE_PADRAO, FLGENVIA_SMS, FLGCOBRA_TARIFA, IDFAIXA_VALOR, FLGPRODUTO_API)
  values (54, 'PXI', 0, 0, 0, 0, 0, 0);
  --
  insert into tbcc_produto (CDPRODUTO, DSPRODUTO, FLGITEM_SOA, FLGUTILIZA_INTERFACE_PADRAO, FLGENVIA_SMS, FLGCOBRA_TARIFA, IDFAIXA_VALOR, FLGPRODUTO_API)
  values (55, 'PXE', 0, 0, 0, 0, 0, 0);
  --
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'BLQJ_AUTOMATICO_PIX', 'Faixa de horario para bloqueio automatico entre horarios de indisponibilidade do AIMARO. ATIVO;HRINICIO;HRFIM', '1;79200;28800');
  --
  commit;
end;