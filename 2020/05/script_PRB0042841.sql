begin  
   begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação do parâmetros CRPS670_MONITORACAO';
    begin
      insert into tbcrd_dominio_campo(
    NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
    values
    ('CRPS670_MONITORACAO', '1', to_date('20/05/2020', 'DD/MM/RRRR'), 1);
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
end;

