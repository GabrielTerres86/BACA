BEGIN 
  insert into SEGURO.tbseg_template_texto( cdtexto_template, dstexto_template, flstatus_texto_template)  values( '11', 'Neste canal � permitida a contrata��o para at� 3 passageiros. Para contrata��es acima de 3 passageiros, entre em contato com a Ailos Corretora pelo WhatsApp no n�mero:', 1);
  COMMIT;
exception
  when others then
    dbms_output.put_line('Erro: '|| sqlerrm);
END;
/
