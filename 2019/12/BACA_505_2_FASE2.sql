begin
  begin
    insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    values ('CRED',0,'CARTAO_ASS_SINCRONICA','Diretorio de leitura dos cartoes de assinatura para envio a Sincronica',
            '/usr/sistemas/Sincronica/cartaoassinatura');
  end;

  begin
    delete craprel a where a.cdrelato=774;
  end;

  for creg in (select cdcooper from crapcop a
               where a.flgativo=1) loop
    begin
      insert into craprel (CDRELATO, NRVIADEF, NRVIAMAX, NMRELATO, NRMODULO, NMDESTIN, 
                           NMFORMUL, INDAUDIT, CDCOOPER, PERIODIC, TPRELATO, INIMPREL, 
                           INGERPDF, DSDEMAIL, CDFILREL, NRSEQPRI)
      values (774, 1, 1, 'RETORNO PROCESSAMENTO SINCRONICA', 5, 'COMPE ', '132col', 0, creg.cdcooper, 'D', 1, 1, 1, ' ', null, null);
    end;
  end loop;
  
  declare
    vr_nrordprg  number(10):=615;
  BEGIN
    FOR creg IN (SELECT a.cdcooper 
                 FROM crapcop a
                 WHERE a.flgativo=1) LOOP
        insert into crapprg (
          nmsistem, cdprogra, dsprogra##1, 
          dsprogra##2, dsprogra##3, dsprogra##4, 
          nrsolici, nrordprg, inctrprg, 
          cdrelato##1, cdrelato##2, cdrelato##3, 
          cdrelato##4, cdrelato##5, inlibprg, 
          cdcooper, qtminmed)
        values ('CRED','JBCHQ_BAIX','Job baixa arquivo Sincronica',
                null,null,null,
                50,vr_nrordprg,1,
                774,0,0,
                0,0,1,
                creg.cdcooper,null);
    END LOOP;
  END;
  
  -- grava alterações
  commit;
end;
/
