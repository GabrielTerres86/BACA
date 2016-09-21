CREATE OR REPLACE PROCEDURE CECRED.pc_expurgo_estatistica IS

  --Variaveis de Excecao
  vr_dscritic  VARCHAR2(2000);
  vr_exc_saida  EXCEPTION;

  BEGIN

    /** Deleta os dados anteriores ao dia corrente menos o parâmetro verificando a existência na tabela consolidada **/
    DELETE
    FROM estatisticamobile t1
      WHERE t1.datalog < SYSDATE -  (
                                    SELECT valor
                                    FROM parametromobile
                                      WHERE nome='ExpurgoEstatisticaDias'
                                  )
      AND   to_date(to_char( t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') IN (
                                                                          SELECT to_date(to_char( t2.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                          FROM estatisticavisao t2
                                                                            WHERE t2.dataestatistica < SYSDATE -  (
                                                                                                                  SELECT valor
                                                                                                                  FROM parametromobile
                                                                                                                    WHERE nome='ExpurgoEstatisticaDias'
                                                                                                                )
                                                                          GROUP BY to_date(to_char( t2.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                      );
  EXCEPTION
    WHEN OTHERS THEN
    --Variavel de erro recebe erro ocorrido
    vr_dscritic := 'Erro ao deletar registro. Rotina pc_expurgo_estatistica.';
    INSERT
    INTO LOGMOBILE
            (
              URLTRANSACAO,
              DATALOG,
              MENSAGEM
            )
            VALUES
            (
              'PC_EXPURGO_ESTATISTICA',
              SYSDATE,
              vr_dscritic
            );
        COMMIT;
    --Sair do programa
    RAISE vr_exc_saida;
END pc_expurgo_estatistica;
/

