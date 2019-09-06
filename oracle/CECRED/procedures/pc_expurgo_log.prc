CREATE OR REPLACE PROCEDURE CECRED.pc_expurgo_log IS

  --Variaveis de Excecao
  vr_dscritic  VARCHAR2(2000);
  vr_exc_saida  EXCEPTION;

  BEGIN

    /** Deleta os dados anteriores ao dia corrente menos o parâmetro **/
    DELETE
    FROM logmobile
      WHERE datalog < SYSDATE - (
                                SELECT valor
                                FROM parametromobile
                                  WHERE nome='ExpurgoLogDias'
                              );

  EXCEPTION
    WHEN OTHERS THEN
    --Variavel de erro recebe erro ocorrido
    vr_dscritic := 'Erro ao deletar registro. Rotina pc_expurgo_log.';
    INSERT
    INTO LOGMOBILE
            (
              URLTRANSACAO,
              DATALOG,
              MENSAGEM
            )
            VALUES
            (
              'PC_EXPURGO_LOG',
              SYSDATE,
              vr_dscritic
            );
        COMMIT;
    --Sair do programa
    RAISE vr_exc_saida;
END pc_expurgo_log;
/

