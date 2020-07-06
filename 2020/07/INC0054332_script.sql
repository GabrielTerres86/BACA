begin  
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Script de atualização do sequencial do arquivo DAUR';
    begin

    UPDATE crapscb
       SET nrseqarq = 833
         , dtultint = SYSDATE
     WHERE crapscb.tparquiv = 8; -- Arquivo DAUR - Debito em cota das faturas
           
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
end;
