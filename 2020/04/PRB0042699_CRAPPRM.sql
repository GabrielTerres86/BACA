begin

  insert
    into CRAPPRM (NMSISTEM
                 ,CDCOOPER
                 ,CDACESSO
                 ,DSTEXPRM
                 ,DSVLRPRM)
  values         ('CRED'
                 ,3
                 ,'729_ENV_PROX_DIA'
                 ,'Datas que deve-se gerar arquivo IEPTB e NAO enviar'||
                  ' - Apenas enviar no proximo dia util. DD/MM;DD/MM'
                 ,'24/12;31/12');

  commit;

end;