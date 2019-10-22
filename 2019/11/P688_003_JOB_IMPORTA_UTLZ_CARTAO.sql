/*
*  JOB para realizar a leitura dos dados da tabela TBCRD_INTERMED_CARTAO e passar para a tabela TBCRD_UTILIZACAO_CARTAO.
*  Autor: Guilherme Cervo (Supero)                 Data Criação: 25/09/2019
*
*
*/
begin

  sys.dbms_scheduler.create_job(
    job_name            => 'CECRED.jbcrd_importa_utlz_cartao',
    job_type            => 'PLSQL_BLOCK',
    job_action          => 'DECLARE
      pr_dtmvtolt crapdat.dtmvtolt%TYPE;
      pr_cdcritic PLS_INTEGER;
      pr_dscritic VARCHAR2(500);
    BEGIN
      
      pr_dtmvtolt := trunc(SYSDATE);
      
      cecred.PC_JOB_IMPORTA_UTLZ_CARTAO(pr_dtmvtolt  => pr_dtmvtolt
                      ,pr_cdcritic => pr_cdcritic
                      ,pr_dscritic => pr_dscritic);

      IF pr_dscritic IS NOT NULL THEN
        raise_application_error(-20001, pr_dscritic);
      END IF;
    END;',
    
    start_date          => '10/09/19 20:00:00,000000 AMERICA/SAO_PAULO',
    repeat_interval     => 'Freq=MONTHLY; ByHour=20;',
    end_date            => to_date(null),
    job_class           => 'DEFAULT_JOB_CLASS',
    enabled             => true,
    auto_drop           => false,
    comments            => 'Buscar dados de utilizacao de cartao carregados pelo BI.');
end;

