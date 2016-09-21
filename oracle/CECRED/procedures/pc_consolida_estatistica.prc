create or replace procedure cecred.PC_CONSOLIDA_ESTATISTICA is
vr_dserro varchar2(2000);
begin
 /* .............................................................................
       Programa: PC_CONSOLIDA_ESTATISTICA (Arquitetura/Projetos/Cecred Mobile Bank/data/PC_CONSOLIDA_ESTATISTICA.sql)
       Sistema : MobileBank
       Autor   : Thiago Baumgartner
       Data    : Novembro/2014                     Ultima atualizacao: 16/12/2014

       Dados referentes ao programa:
       Frequencia: Diário
       Objetivo  : Consolida os dados estatísticos diários para otimização de consultas.

                   16/12/2014 - Tratamento de exceção com geração de log (Thiago B. RKAM)

                   18/12/2014 - Nova metodologia para consolidação estatística (Thiago B. RKAM)

                   07/01/2015 - Problema com consolidação por cooperativas, não consolidando a não ser cooperativa 1 (Thiago B. RKAM)

                   14/01/2015 - Inclusão do campo valorComMovimento que contabilizará o número de transações contendo movimentação financeira (Luciano G. RKAM)
                   
                   01/06/2015 - Tratamento da URL na consolidação das transações (Guilherme).
    ............................................................................ */

    -- insere os registros consolidados na visão geral agrupado por cooperativas
    insert into estatisticavisao
      (
        categoriaid,
        categoria,
        dataestatistica,
        estatisticatipoid,
        valor,
        total,
        conta,
        valorComMovimento
      )
      Select
        t1.cooperativaid,
        t2.nmrescop,
        to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd'),
        1,
        count(t1.cooperativaid),
        sum(t1.valor),
        0,
        (Select
              count(subt1.cooperativaid)
            from estatisticamobile subt1
            where
                subt1.valor <> 0
                and subt1.geraestatistica = 1
                and t1.cooperativaid = subt1.cooperativaid
                and to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') = to_date(to_char(subt1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
          group by
            subt1.cooperativaid,
            to_date(to_char(subt1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
        ) as valorComMovimento
      from estatisticamobile t1
      join crapcop t2 on t2.cdcooper = t1.cooperativaid
      where to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') NOT IN (
                                                                        Select
                                                                        to_date(to_char( t3.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                        from estatisticavisao t3
                                                                        where t3.estatisticatipoid = 1
                                                                        group by
                                                                        to_date(to_char( t3.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                      )
            and t1.geraestatistica = 1
            and t1.datalog < to_date(to_char(sysdate, 'yyyy-mm-dd'), 'yyyy-mm-dd')
      group by
        t1.cooperativaid,
        t2.nmrescop,
        to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
      order by
        t1.cooperativaid;

    -- insere os registros consolidados na visão geral agrupado por transação
    insert into estatisticavisao
      (
        categoriaid,
        categoria,
        dataestatistica,
        estatisticatipoid,
        valor,
        total,
        conta,
        valorComMovimento
      )
      Select
        0,
        substr(t1.urltransacao,1,decode(instr(t1.urltransacao,'?'),0,length(t1.urltransacao),instr(t1.urltransacao,'?')-1)),
        to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd'),
        2,
        count(t1.cooperativaid),
        sum(t1.valor),
        0,
        (Select
              count(subt1.cooperativaid)
            from estatisticamobile subt1
            where
                subt1.valor <> 0
                and subt1.geraestatistica = 1
                and substr(t1.urltransacao,1,decode(instr(t1.urltransacao,'?'),0,length(t1.urltransacao),instr(t1.urltransacao,'?')-1)) = substr(subt1.urltransacao,1,decode(instr(subt1.urltransacao,'?'),0,length(subt1.urltransacao),instr(subt1.urltransacao,'?')-1))
                and to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') = to_date(to_char(subt1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
          group by
            substr(subt1.urltransacao,1,decode(instr(subt1.urltransacao,'?'),0,length(subt1.urltransacao),instr(subt1.urltransacao,'?')-1)),
            to_date(to_char(subt1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
        ) as valorComMovimento
      from estatisticamobile t1
      where to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') NOT IN (
                                                                        Select
                                                                        to_date(to_char( t3.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                        from estatisticavisao t3
                                                                        where t3.estatisticatipoid = 2
                                                                        group by
                                                                        to_date(to_char( t3.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                      )
            and t1.geraestatistica = 1
            and t1.datalog < to_date(to_char(sysdate, 'yyyy-mm-dd'), 'yyyy-mm-dd')
      group by
        substr(t1.urltransacao,1,decode(instr(t1.urltransacao,'?'),0,length(t1.urltransacao),instr(t1.urltransacao,'?')-1)),
        to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
      order by
        substr(t1.urltransacao,1,decode(instr(t1.urltransacao,'?'),0,length(t1.urltransacao),instr(t1.urltransacao,'?')-1));

    -- insere os registros consolidados na visão geral agrupado por plataforma
    insert into estatisticavisao
      (
        categoriaid,
        categoria,
        dataestatistica,
        estatisticatipoid,
        valor,
        total,
        conta,
        valorComMovimento
      )
      Select
        0,
        t1.plataforma,
        to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd'),
        3,
        count(t1.cooperativaid),
        sum(t1.valor),
        0,
        (Select
              count(subt1.cooperativaid)
            from estatisticamobile subt1
            where
                subt1.valor <> 0
                and subt1.geraestatistica = 1
                and t1.plataforma= subt1.plataforma
                and to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') = to_date(to_char(subt1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
          group by
            subt1.plataforma,
            to_date(to_char(subt1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
        ) as valorComMovimento
      from estatisticamobile t1
      where to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') NOT IN (
                                                                        Select
                                                                        to_date(to_char( t3.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                        from estatisticavisao t3
                                                                        where t3.estatisticatipoid = 3
                                                                        group by
                                                                        to_date(to_char( t3.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                      )
            and t1.geraestatistica = 1
            and t1.datalog < to_date(to_char(sysdate, 'yyyy-mm-dd'), 'yyyy-mm-dd')
      group by
        t1.plataforma,
        to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
      order by
        t1.plataforma;

    -- insere os registros consolidados na visão geral agrupado por plataforma / versao
    insert into estatisticavisao
      (
        categoriaid,
        categoria,
        dataestatistica,
        estatisticatipoid,
        valor,
        total,
        conta,
        valorComMovimento
      )
      Select
        0,
        t1.plataforma || ' / ' || t1.versaoso,
        to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd'),
        4,
        count(t1.cooperativaid),
        sum(t1.valor),
        0,
        (Select
              count(subt1.cooperativaid)
            from estatisticamobile subt1
            where
                subt1.valor <> 0
                and subt1.geraestatistica = 1
                and t1.plataforma= subt1.plataforma
                and t1.versaoso = subt1.versaoso
                and to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') = to_date(to_char(subt1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
          group by
            subt1.plataforma,
            subt1.versaoso,
            to_date(to_char(subt1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
        ) as valorComMovimento
      from estatisticamobile t1
      where to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') NOT IN (
                                                                        Select
                                                                        to_date(to_char( t3.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                        from estatisticavisao t3
                                                                        where t3.estatisticatipoid = 4
                                                                        group by
                                                                        to_date(to_char( t3.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                      )
            and t1.geraestatistica = 1
            and t1.datalog < to_date(to_char(sysdate, 'yyyy-mm-dd'), 'yyyy-mm-dd')
      group by
        t1.plataforma,
        t1.versaoso,
        to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
      order by
        t1.plataforma, t1.versaoso;

    -- insere os registros consolidados na visão geral agrupado por versão do aplicativo
    insert into estatisticavisao
      (
        categoriaid,
        categoria,
        dataestatistica,
        estatisticatipoid,
        valor,
        total,
        conta,
        valorComMovimento
      )
      Select
        0,
        t1.versaoaplicativo,
        to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd'),
        5,
        count(t1.cooperativaid),
        sum(t1.valor),
        0,
        (Select
              count(subt1.cooperativaid)
            from estatisticamobile subt1
            where
                subt1.valor <> 0
                and subt1.geraestatistica = 1
                and t1.versaoaplicativo= subt1.versaoaplicativo
                and to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') = to_date(to_char(subt1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
          group by
            subt1.versaoaplicativo,
            to_date(to_char(subt1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
        ) as valorComMovimento
      from estatisticamobile t1
      where to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') NOT IN (
                                                                        Select
                                                                        to_date(to_char( t3.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                        from estatisticavisao t3
                                                                        where t3.estatisticatipoid = 5
                                                                        group by
                                                                        to_date(to_char( t3.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                      )
            and t1.geraestatistica = 1
            and t1.datalog < to_date(to_char(sysdate, 'yyyy-mm-dd'), 'yyyy-mm-dd')
      group by
        t1.versaoaplicativo,
        to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
      order by
        t1.versaoaplicativo;

    -- insere os registros consolidados na visão geral agrupado por hora
    insert into estatisticavisao
      (
        categoriaid,
        categoria,
        dataestatistica,
        estatisticatipoid,
        valor,
        total,
        conta,
        valorComMovimento
      )
      Select
        0,
        to_char(t1.datalog, 'hh24'),
        to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd'),
        6,
        count(t1.cooperativaid),
        sum(t1.valor),
        0,
        (Select
              count(subt1.cooperativaid)
            from estatisticamobile subt1
            where
                subt1.valor <> 0
                and subt1.geraestatistica = 1
                and to_char(t1.datalog, 'hh24')= to_char(subt1.datalog, 'hh24')
                and to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') = to_date(to_char(subt1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
          group by
            to_char(subt1.datalog, 'hh24'),
            to_date(to_char(subt1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
        ) as valorComMovimento
      from estatisticamobile t1
      where to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') NOT IN (
                                                                        Select
                                                                        to_date(to_char( t3.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                        from estatisticavisao t3
                                                                        where t3.estatisticatipoid = 6
                                                                        group by
                                                                        to_date(to_char( t3.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                      )
            and t1.geraestatistica = 1
            and t1.datalog < to_date(to_char(sysdate, 'yyyy-mm-dd'), 'yyyy-mm-dd')
      group by
        to_char(t1.datalog, 'hh24'),
        to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
      order by
        to_number(to_char(t1.datalog, 'hh24'));

    begin
        -- Cria um loop para inserir estatisticas por cooperativa
        begin
          for rcoop in (select t1.cooperativaid
                      from estatisticamobile t1
                      group by t1.cooperativaid)
          loop
            -- insere os registros consolidados na visão cooperativa agrupado por transacao
            insert into estatisticavisao
              (
                categoriaid,
                categoria,
                dataestatistica,
                estatisticatipoid,
                valor,
                total,
                conta,
                valorComMovimento
              )
              Select
                rcoop.cooperativaid,
                substr(t1.urltransacao,1,decode(instr(t1.urltransacao,'?'),0,length(t1.urltransacao),instr(t1.urltransacao,'?')-1)),
                to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd'),
                7,
                count(t1.cooperativaid),
                sum(t1.valor),
                0,
                (Select
                      count(subt1.cooperativaid)
                    from estatisticamobile subt1
                    where
                        subt1.valor <> 0
                        and subt1.cooperativaid = rcoop.cooperativaid
                        and subt1.geraestatistica = 1
                        and substr(t1.urltransacao,1,decode(instr(t1.urltransacao,'?'),0,length(t1.urltransacao),instr(t1.urltransacao,'?')-1)) = substr(subt1.urltransacao,1,decode(instr(subt1.urltransacao,'?'),0,length(subt1.urltransacao),instr(subt1.urltransacao,'?')-1))
                        and to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') = to_date(to_char(subt1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                  group by
                    substr(subt1.urltransacao,1,decode(instr(subt1.urltransacao,'?'),0,length(subt1.urltransacao),instr(subt1.urltransacao,'?')-1)),
                    to_date(to_char(subt1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                ) as valorComMovimento
              from estatisticamobile t1
              where t1.cooperativaid = rcoop.cooperativaid
                    and to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') NOT IN (
                                                                                            Select
                                                                                            to_date(to_char( t3.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                                            from estatisticavisao t3
                                                                                            where t3.estatisticatipoid = 7 and t3.categoriaid = rcoop.cooperativaid
                                                                                            group by
                                                                                            to_date(to_char( t3.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                                          )
                    and t1.geraestatistica = 1
                    and t1.datalog < to_date(to_char(sysdate, 'yyyy-mm-dd'), 'yyyy-mm-dd')
              group by
                substr(t1.urltransacao,1,decode(instr(t1.urltransacao,'?'),0,length(t1.urltransacao),instr(t1.urltransacao,'?')-1)),
                to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
              order by
                substr(t1.urltransacao,1,decode(instr(t1.urltransacao,'?'),0,length(t1.urltransacao),instr(t1.urltransacao,'?')-1));

            -- insere os registros consolidados na visão cooperativa agrupado por plataforma
            insert into estatisticavisao
              (
                categoriaid,
                categoria,
                dataestatistica,
                estatisticatipoid,
                valor,
                total,
                conta,
                valorComMovimento
              )
              Select
                rcoop.cooperativaid,
                t1.plataforma,
                to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd'),
                8,
                count(t1.cooperativaid),
                sum(t1.valor),
                0,
                (Select
                      count(subt1.cooperativaid)
                    from estatisticamobile subt1
                    where
                        subt1.valor <> 0
                        and subt1.cooperativaid = rcoop.cooperativaid
                        and subt1.geraestatistica = 1
                        and t1.plataforma= subt1.plataforma
                        and to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') = to_date(to_char(subt1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                  group by
                    subt1.plataforma,
                    to_date(to_char(subt1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                ) as valorComMovimento
              from estatisticamobile t1
              where t1.cooperativaid = rcoop.cooperativaid
                    and to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') NOT IN (
                                                                                            Select
                                                                                            to_date(to_char( t3.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                                            from estatisticavisao t3
                                                                                            where t3.estatisticatipoid = 8 and t3.categoriaid = rcoop.cooperativaid
                                                                                            group by
                                                                                            to_date(to_char( t3.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                                          )
                    and t1.geraestatistica = 1
                    and t1.datalog < to_date(to_char(sysdate, 'yyyy-mm-dd'), 'yyyy-mm-dd')
              group by
                t1.plataforma,
                to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
              order by
                t1.plataforma;

            -- insere os registros consolidados na visão cooperativa agrupado por plataforma / versao
            insert into estatisticavisao
              (
                categoriaid,
                categoria,
                dataestatistica,
                estatisticatipoid,
                valor,
                total,
                conta,
                valorComMovimento
              )
              Select
                rcoop.cooperativaid,
                t1.plataforma || ' / ' || t1.versaoso,
                to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd'),
                9,
                count(t1.cooperativaid),
                sum(t1.valor),
                0,
                (Select
                      count(subt1.cooperativaid)
                    from estatisticamobile subt1
                    where
                        subt1.valor <> 0
                        and subt1.cooperativaid = rcoop.cooperativaid
                        and subt1.geraestatistica = 1
                        and t1.plataforma= subt1.plataforma
                        and t1.versaoso = subt1.versaoso
                        and to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') = to_date(to_char(subt1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                  group by
                    subt1.plataforma,
                    subt1.versaoso,
                    to_date(to_char(subt1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                ) as valorComMovimento
              from estatisticamobile t1
              where t1.cooperativaid = rcoop.cooperativaid
                    and to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') NOT IN (
                                                                                            Select
                                                                                            to_date(to_char( t3.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                                            from estatisticavisao t3
                                                                                            where t3.estatisticatipoid = 9 and t3.categoriaid = rcoop.cooperativaid
                                                                                            group by
                                                                                            to_date(to_char( t3.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                                          )
                    and t1.geraestatistica = 1
                    and t1.datalog < to_date(to_char(sysdate, 'yyyy-mm-dd'), 'yyyy-mm-dd')
              group by
                t1.plataforma,
                t1.versaoso,
                to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
              order by
                t1.plataforma, t1.versaoso;

            -- insere os registros consolidados na visão cooperativa agrupado por versão do aplicativo
            insert into estatisticavisao
              (
                categoriaid,
                categoria,
                dataestatistica,
                estatisticatipoid,
                valor,
                total,
                conta,
                valorComMovimento
              )
              Select
                rcoop.cooperativaid,
                t1.versaoaplicativo,
                to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd'),
                10,
                count(t1.cooperativaid),
                sum(t1.valor),
                0,
                (Select
                      count(subt1.cooperativaid)
                    from estatisticamobile subt1
                    where
                        subt1.valor <> 0
                        and subt1.cooperativaid = rcoop.cooperativaid
                        and subt1.geraestatistica = 1
                        and t1.versaoaplicativo= subt1.versaoaplicativo
                        and to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') = to_date(to_char(subt1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                  group by
                    subt1.versaoaplicativo,
                    to_date(to_char(subt1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                ) as valorComMovimento
              from estatisticamobile t1
              where t1.cooperativaid = rcoop.cooperativaid
                    and to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') NOT IN (
                                                                                            Select
                                                                                            to_date(to_char( t3.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                                            from estatisticavisao t3
                                                                                            where t3.estatisticatipoid = 10 and t3.categoriaid = rcoop.cooperativaid
                                                                                            group by
                                                                                            to_date(to_char( t3.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                                          )
                    and t1.geraestatistica = 1
                    and t1.datalog < to_date(to_char(sysdate, 'yyyy-mm-dd'), 'yyyy-mm-dd')
              group by
                t1.versaoaplicativo,
                to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
              order by
                t1.versaoaplicativo;

            -- insere os registros consolidados na visão cooperativa agrupado por hora
            insert into estatisticavisao
              (
                categoriaid,
                categoria,
                dataestatistica,
                estatisticatipoid,
                valor,
                total,
                conta,
                valorComMovimento
              )
              Select
                rcoop.cooperativaid,
                to_char(t1.datalog, 'hh24'),
                to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd'),
                11,
                count(t1.cooperativaid),
                sum(t1.valor),
                0,
                (Select
                      count(subt1.cooperativaid)
                    from estatisticamobile subt1
                    where
                        subt1.valor <> 0
                        and subt1.cooperativaid = rcoop.cooperativaid
                        and subt1.geraestatistica = 1
                        and to_char(t1.datalog, 'hh24') = to_char(subt1.datalog, 'hh24')
                        and to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') = to_date(to_char(subt1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                  group by
                    to_char(subt1.datalog, 'hh24'),
                    to_date(to_char(subt1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                ) as valorComMovimento
              from estatisticamobile t1
              where t1.cooperativaid = rcoop.cooperativaid
                    and to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd') NOT IN (
                                                                                            Select
                                                                                            to_date(to_char( t3.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                                            from estatisticavisao t3
                                                                                            where t3.estatisticatipoid = 11 and t3.categoriaid = rcoop.cooperativaid
                                                                                            group by
                                                                                            to_date(to_char( t3.dataestatistica, 'yyyy-mm-dd'), 'yyyy-mm-dd')
                                                                                          )
                    and t1.geraestatistica = 1
                    and t1.datalog < to_date(to_char(sysdate, 'yyyy-mm-dd'), 'yyyy-mm-dd')
              group by
                to_char(t1.datalog, 'hh24'),
                to_date(to_char(t1.datalog, 'yyyy-mm-dd'), 'yyyy-mm-dd')
              order by
                to_number(to_char(t1.datalog, 'hh24'));
          end loop;
        end;
        commit;
    exception
      when others then
        rollback;
        vr_dserro := sqlerrm;
        insert into LOGMOBILE
            (
              URLTRANSACAO,
              DATALOG,
              MENSAGEM
            )
            values
            (
              'PC_CONSOLIDA_ESTATISTICA',
              sysdate,
              vr_dserro
            );
        commit;
    end;

END PC_CONSOLIDA_ESTATISTICA;
/

