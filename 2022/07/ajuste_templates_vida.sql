BEGIN
  update SEGURO.tbseg_template_textos set dstexto_template = 'Seguros de Vida administrados por Icatu Seguros S.A, inscrita no CNPJ/MF sob o n� 42.283.770/0001-39, VG Faixa Et�ria - Processo SUSEP n� 15414.001272/2006-36. \n\nSAC: {telefoneSAC} de segunda a sexta-feira: das 8h �s 20h, exceto em feriados nacionais. \n\nT�tulos de Capitaliza��o da modalidade incentivo emitido pela Icatu Capitaliza��o  S/A, CNPJ/MF n� 74.267.170/0001-73, VG Faixa Et�ria - Processo SUSEP n� 15414.001272/2006-36. \n\nAp�s a comunica��o do sorteio, o pr�mio estar� dispon�vel para pagamento pelo prazo prescricional em vigor, o qual, atualmente � de 5 anos, conforme previsto no C�digo Civil de 2002. \n\nOuvidoria Icatu Seguros: {telefoneIcatu} de segunda a sexta-feira, das 8h �s 18h, exceto feriados.'
   where cdtexto_template = 7;
  insert into SEGURO.tbseg_template_textos( cdtexto_template, dstexto_template, flstatus_texto_template)  values( '8', '0800 286 0110',  1);
  insert into SEGURO.tbseg_template_textos( cdtexto_template, dstexto_template, flstatus_texto_template)  values( '9', '0800 286 0047',  1);
COMMIT;
exception
  when others then
    dbms_output.put_line('Erro: '|| sqlerrm);
END;
/
