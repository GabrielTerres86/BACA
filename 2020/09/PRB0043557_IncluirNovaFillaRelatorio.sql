DECLARE

  CURSOR cr_crapcop IS
    SELECT t.cdcooper
      FROM crapcop t
     WHERE t.flgativo = 1 
       AND t.cdcooper <> 3;
BEGIN
  
  -- 
  INSERT INTO crapfil(cdfilrel
                     ,dsnmfila
                     ,qtdiaarq
                     ,qtjobati
                     ,qtreljob
                     ,flgativa)
               VALUES('00PAR1' -- Código da fila
                     ,'Fila paralela ao BATCH' -- Nome da fila
                     ,60 -- Quantidade de dias que as solicitações ficam arquivadas
                     ,15 -- Quantidade máxima de jobs ativos na fila
                     ,65 -- Quantidade de relatórios processados por vez
                     ,'S'); -- Fila ativa

  -- Corrigir registros faltantes do relatório
  FOR coop IN cr_crapcop LOOP
    
    BEGIN
      INSERT INTO craprel(cdrelato
                         ,nrviadef
                         ,nrviamax
                         ,nmrelato
                         ,nrmodulo
                         ,nmdestin
                         ,nmformul
                         ,indaudit
                         ,cdcooper
                         ,periodic
                         ,tprelato
                         ,inimprel
                         ,ingerpdf
                         ,dsdemail)
                   VALUES(714
                         ,1
                         ,1
                         ,'RESUMO MENSAL ARQUIVO 5300 BACEN'
                         ,5
                         ,'CONTABILIDADE'
                         ,'132col'
                         ,0
                         ,coop.cdcooper
                         ,'Diario'
                         ,1
                         ,1
                         ,0
                         ,' ');
                
    EXCEPTION
      WHEN dup_val_on_index THEN
        NULL; -- Ignorar registros já existentes
      WHEN OTHERS THEN
        raise_application_error(-20005,'Erro ao ajustar CRAPREL: '||SQLERRM);
    END;
   
  END LOOP; -- Loop cooperativas ativas
  
  -- Alterar o relatório CRRL714 para que seja executado pela nova fila
  UPDATE craprel t 
     SET t.cdfilrel = '00PAR1'
   WHERE t.cdrelato = 714;

  COMMIT;

END;
