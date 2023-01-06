BEGIN 
  insert into SEGURO.tbseg_template_texto( cdtexto_template, dstexto_template, flstatus_texto_template)  values( '11', 'Neste canal é permitida a contratação para até 3 passageiros. Para contratações acima de 3 passageiros, entre em contato com a Ailos Corretora pelo WhatsApp no número:', 1);
  COMMIT;
exception
  when others then
    dbms_output.put_line('Erro: '|| sqlerrm);
END;
/
