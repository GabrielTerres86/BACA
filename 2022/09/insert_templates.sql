BEGIN
  insert into SEGURO.tbseg_template_texto( cdtexto_template, dstexto_template, flstatus_texto_template)  values( '4', 'Até R$ 7.000 para serviço funeral ou reembolso.',  1);
  insert into SEGURO.tbseg_template_texto( cdtexto_template, dstexto_template, flstatus_texto_template)  values( '5', 'Pessoa(s) designada(s) pelo titular do seguro para receberem a indenização em caso de sua ausência.\n\nNa falta de indicação de beneficiários ou se por algum motivo não prevalecer a que for feita, serão considerados beneficiários os herdeiros legais do segurado.\n\nPara beneficiário menor de idade, a indenização será paga diretamente na conta corrente do menor de idade (caso possua) ou de seu represente legal.',  1);
  insert into SEGURO.tbseg_template_texto( cdtexto_template, dstexto_template, flstatus_texto_template)  values( '7', 'Seguros de Vida administrados por Icatu Seguros S.A, inscrita no CNPJ/MF sob o nº 42.283.770/0001-39, VG Faixa Etária - Processo SUSEP nº 15414.001272/2006-36. \n\nSAC: {telefoneSAC} de segunda a sexta-feira: das 8h às 20h, exceto em feriados nacionais. \n\nTítulos de Capitalização da modalidade incentivo emitido pela Icatu Capitalização  S/A, CNPJ/MF nº 74.267.170/0001-73, VG Faixa Etária - Processo SUSEP nº 15414.001272/2006-36. \n\nApós a comunicação do sorteio, o prêmio estará disponível para pagamento pelo prazo prescricional em vigor, o qual, atualmente é de 5 anos, conforme previsto no Código Civil de 2002. \n\nOuvidoria Icatu Seguros: {telefoneIcatu} de segunda a sexta-feira, das 8h às 18h, exceto feriados.',  1);
  insert into SEGURO.tbseg_template_texto( cdtexto_template, dstexto_template, flstatus_texto_template)  values( '8', '0800 286 0110',  1);
  insert into SEGURO.tbseg_template_texto( cdtexto_template, dstexto_template, flstatus_texto_template)  values( '9', '0800 286 0047',  1);
  insert into SEGURO.tbseg_template_texto( cdtexto_template, dstexto_template, flstatus_texto_template)  values( '10', 'A contratação neste canal só é permitida para pessoas residentes no Brasil. Gentileza entrar em contato com a Ailos Corretora através do WhatsApp pelo número:', 1);

COMMIT;
exception
  when others then
    dbms_output.put_line('Erro: '|| sqlerrm);
END;
/
