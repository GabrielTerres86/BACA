BEGIN
  insert into SEGURO.tbseg_template_textos( cdtexto_template, dstexto_template, flstatus_texto_template)  values( '4', 'Até R$ 7.000 para serviço funeral ou reembolso.',  1);
COMMIT;
exception
  when others then
    dbms_output.put_line('Erro: '|| sqlerrm);
END;
/
