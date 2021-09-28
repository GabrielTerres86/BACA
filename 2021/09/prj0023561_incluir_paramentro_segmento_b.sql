begin

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'TED_ARQUIV_INI_SEG_B', 'Data de controle para iniciar validação somente para todas as adesões, segmento B, TED arquivo.', '01/07/2022');

COMMIT;

  
EXCEPTION
  WHEN OTHERS THEN 
       dbms_output.put_line('Erro: ' || SQLERRM);
       
end;