-- Created on 08/08/2019 by Rafael Ferreira (Mouts) - T0032702 
DECLARE

BEGIN
  -- Este Script tem por finalidade atualizar todas as contas que possam estar com o problema descrito no
  -- INC0020100. Ele busca todas as contas que possuem qtd_float ou "decurso de prazo" = 0... e atualiza
  -- com a informação do parametro da crapcco

  -- Dropa Tabela de Backup caso ela exista
  begin
    execute immediate 'drop table cecred.crapceb_bkpfloat';
  exception
    when others then
      sys.dbms_output.put_line('Tabela crapceb_bkpfloat ainda não existe: ' || sqlerrm);
  end;
  
  --Criando Tabela de Backup
  sys.dbms_output.put_line('Criando Tabela de Backup crapceb_bkpfloat... Aguarde');
  execute immediate 'create table cecred.crapceb_bkpfloat as select cdcooper, nrdconta, nrconven, qtdfloat, qtdecprz from cecred.crapceb';

  -- Cursor que armazena os parametros da crapcco
  FOR cr_cco IN (SELECT cco.cdcooper, cco.nrconven, cco.qtdfloat, cco.qtdecini
                   FROM cecred.crapcco cco
                  WHERE cco.qtdfloat > 0) LOOP
  
    -- Cursor que varre os Cooperados e atualiza os que possuem qtdfloat 0 ou decurso de prazo 0
    FOR cr_ceb IN (SELECT ceb.cdcooper, ceb.nrconven, ceb.qtdfloat, ceb.qtdecprz, ceb.nrdconta, ceb.rowid
                     FROM cecred.crapceb ceb
                    WHERE ceb.cdcooper = cr_cco.cdcooper
                      AND ceb.nrconven = cr_cco.nrconven
                      AND (ceb.qtdfloat = 0 OR ceb.qtdecprz = 0)) LOOP
    
      -- Tenta efetuar o update, e passa caso ocorra algum erro
      BEGIN
        -- Feito decode para só atualizar os que estiverem zerados, isso é mais performático do que 
        -- fazer 2 updates distintos
        UPDATE cecred.crapceb ceb
           SET ceb.qtdfloat = cr_cco.qtdfloat, ceb.qtdecprz = decode(ceb.qtdecprz, 0, cr_cco.qtdecini, ceb.qtdecprz)
         WHERE ceb.rowid = cr_ceb.rowid;
      EXCEPTION
        -- Caso ocorra alguma falha ignora o registro atual e continua o próximo
        WHEN OTHERS THEN
          continue;
      END;
    
    END LOOP; -- cr_ceb
  
    COMMIT; -- Commit do Convenio na Cooperativa
  
  END LOOP; -- cr_cco

  COMMIT; -- Commit Geral
END;