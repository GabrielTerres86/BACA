PL/SQL Developer Test script 3.0
16
-- Created on 04/11/2020 by T0032500 
declare 
  -- Local variables here
  i integer;
begin
  -- Test statements here
        UPDATE tbrecarga_operacao
                SET tbrecarga_operacao.insit_operacao = 2,
                    tbrecarga_operacao.dtdebito = '07/05/2019'
              WHERE tbrecarga_operacao.cdcooper = 16 AND
                    tbrecarga_operacao.nrdconta = 464023;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('Nao foi possivel alterar o registro'||SQLERRM);
        commit;
end;
0
0
