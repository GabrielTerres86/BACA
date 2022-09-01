BEGIN
  insert into SEGURO.tbseg_template_texto( cdtexto_template, dstexto_template, flstatus_texto_template)  values( '4', 'At� R$ 7.000 para servi�o funeral ou reembolso.',  1);
  insert into SEGURO.tbseg_template_texto( cdtexto_template, dstexto_template, flstatus_texto_template)  values( '5', 'Pessoa(s) designada(s) pelo titular do seguro para receberem a indeniza��o em caso de sua aus�ncia.\n\nNa falta de indica��o de benefici�rios ou se por algum motivo n�o prevalecer a que for feita, ser�o considerados benefici�rios os herdeiros legais do segurado.\n\nPara benefici�rio menor de idade, a indeniza��o ser� paga diretamente na conta corrente do menor de idade (caso possua) ou de seu represente legal.',  1);
  insert into SEGURO.tbseg_template_texto( cdtexto_template, dstexto_template, flstatus_texto_template)  values( '7', 'Seguros de Vida administrados por Icatu Seguros S.A, inscrita no CNPJ/MF sob o n� 42.283.770/0001-39, VG Faixa Et�ria - Processo SUSEP n� 15414.001272/2006-36. \n\nSAC: {telefoneSAC} de segunda a sexta-feira: das 8h �s 20h, exceto em feriados nacionais. \n\nT�tulos de Capitaliza��o da modalidade incentivo emitido pela Icatu Capitaliza��o  S/A, CNPJ/MF n� 74.267.170/0001-73, VG Faixa Et�ria - Processo SUSEP n� 15414.001272/2006-36. \n\nAp�s a comunica��o do sorteio, o pr�mio estar� dispon�vel para pagamento pelo prazo prescricional em vigor, o qual, atualmente � de 5 anos, conforme previsto no C�digo Civil de 2002. \n\nOuvidoria Icatu Seguros: {telefoneIcatu} de segunda a sexta-feira, das 8h �s 18h, exceto feriados.',  1);
  insert into SEGURO.tbseg_template_texto( cdtexto_template, dstexto_template, flstatus_texto_template)  values( '8', '0800 286 0110',  1);
  insert into SEGURO.tbseg_template_texto( cdtexto_template, dstexto_template, flstatus_texto_template)  values( '9', '0800 286 0047',  1);
  insert into SEGURO.tbseg_template_texto( cdtexto_template, dstexto_template, flstatus_texto_template)  values( '10', 'A contrata��o neste canal s� � permitida para pessoas residentes no Brasil. Gentileza entrar em contato com a Ailos Corretora atrav�s do WhatsApp pelo n�mero:', 1);

COMMIT;
exception
  when others then
    dbms_output.put_line('Erro: '|| sqlerrm);
END;
/
