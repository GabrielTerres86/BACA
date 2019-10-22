declare

  cursor cr_coop is
  select crapcop.nmrescop
        ,crapcop.cdcooper
    from cecred.crapcop
  order by crapcop.cdcooper;
  
  rw_coop        cr_coop%rowtype;  
  
  vr_dataini     date := to_date('01/07/2018','dd/mm/yyyy');
  vr_datafim     date := to_date('30/09/2018','dd/mm/yyyy');
  vr_dataproc    date;

  PROCEDURE pc_apura_tarifas_financiadas(pr_cdcooper IN crapcop.cdcooper%TYPE    --> Cooperativa
                                        ,pr_dtmvtoan IN crapdat.dtmvtoan%TYPE) IS --> Data de movimento do dia anterior)        
  
 /* ..........................................................................
   Sistema : Conta-Corrente - Cooperativa de Credito
   Autor   : Marcus Abreu (Supero)
   Data    : Setembro/2019.                     Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Diário.
   Objetivo  : Importar dados de tarifa financiadas - retirado o envio de e-mails e registro em log, para execução via script

   Alteracoes:

  ..........................................................................*/  
  -- Variaveis de erro    
  vr_cdcritic        crapcri.cdcritic%TYPE;
  vr_dscritic        VARCHAR2(4000);
  vr_exc_erro        EXCEPTION;
                                          
  vr_nrmesref   INTEGER;
  vr_nranoref   INTEGER;
  vr_anomvtolt  INTEGER;
  
  
  CURSOR cr_tarempfin(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_dtmvtoan crapdat.dtmvtoan%TYPE) IS
  SELECT crapepr.cdcooper,
         crapepr.nrdconta,
         crapepr.nrctremp,
         crapepr.vltarifa       
    FROM crapepr 
    JOIN crawepr
      ON crawepr.cdcooper = crapepr.cdcooper
     AND crawepr.nrdconta = crapepr.nrdconta
     AND crawepr.nrctremp = crapepr.nrctremp
   WHERE crapepr.cdcooper = pr_cdcooper
     AND crapepr.dtmvtolt = pr_dtmvtoan
     AND crapepr.idfiniof = 1;
     
  rw_tarempfin   cr_tarempfin%ROWTYPE;

  BEGIN
      
    -- Busca o mes de apuracao da data, para somar na coluna correta
    vr_nrmesref := EXTRACT(MONTH FROM pr_dtmvtoan);
    vr_nranoref := EXTRACT(YEAR FROM pr_dtmvtoan);
    
    SELECT MAX(ctp.nranolct)
      INTO vr_anomvtolt
      FROM tbcotas_tarifas_pagas ctp
     WHERE ctp.cdcooper = pr_cdcooper;
      
    FOR rw_tarempfin IN cr_tarempfin(pr_cdcooper, pr_dtmvtoan) LOOP
      BEGIN
        IF nvl(vr_anomvtolt,vr_nranoref) > vr_nranoref THEN
          MERGE INTO tbcotas_tarifas_pagas ctp
          USING (SELECT rw_tarempfin.cdcooper AS cdcooper
                       ,rw_tarempfin.nrdconta AS nrdconta
                       ,vr_anomvtolt          AS anomvtolt
                       ,rw_tarempfin.vltarifa AS vlrtarifa
                  FROM DUAL) c
             ON (ctp.cdcooper = c.cdcooper AND ctp.nrdconta = c.nrdconta)
          WHEN MATCHED THEN -- Se existe registro, atualiza, somando ao valor do ano anterior
            UPDATE SET ctp.vltarifa_financiada_anoant = ctp.vltarifa_financiada_anoant +
                                                  c.vlrtarifa
          WHEN NOT MATCHED THEN -- Se não existe, insere novo registro
            INSERT 
           (cdcooper
           ,nrdconta
           ,nranolct
           ,vlpagomes1
           ,vlpagomes2
           ,vlpagomes3
           ,vlpagomes4
           ,vlpagomes5
           ,vlpagomes6
           ,vlpagomes7
           ,vlpagomes8
           ,vlpagomes9
           ,vlpagomes10
           ,vlpagomes11
           ,vlpagomes12
           ,vlpagoanoant
           ,vltarifa_financiada_anoant)
           VALUES
           (c.cdcooper
           ,c.nrdconta
           ,c.anomvtolt
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,c.vlrtarifa
           );
        ELSE -- Senão, popula na coluna do mês
          MERGE INTO tbcotas_tarifas_pagas ctp
          USING (SELECT rw_tarempfin.cdcooper AS cdcooper
                       ,rw_tarempfin.nrdconta AS nrdconta
                       ,vr_nranoref           AS anomvtolt
                       ,vr_nrmesref           AS nrmesref
                       ,rw_tarempfin.vltarifa AS vlrtarifa
                  FROM DUAL) c
             ON (ctp.cdcooper = c.cdcooper AND ctp.nrdconta = c.nrdconta)
          WHEN MATCHED THEN -- Se existe registro, atualiza, somando ao valor do mes
             UPDATE SET ctp.vltarifa_financiada_mes1  = DECODE(c.nrmesref, 1,  ctp.vltarifa_financiada_mes1  + c.vlrtarifa, ctp.vltarifa_financiada_mes1),
                        ctp.vltarifa_financiada_mes2  = DECODE(c.nrmesref, 2,  ctp.vltarifa_financiada_mes2  + c.vlrtarifa, ctp.vltarifa_financiada_mes2),
                        ctp.vltarifa_financiada_mes3  = DECODE(c.nrmesref, 3,  ctp.vltarifa_financiada_mes3  + c.vlrtarifa, ctp.vltarifa_financiada_mes3),
                        ctp.vltarifa_financiada_mes4  = DECODE(c.nrmesref, 4,  ctp.vltarifa_financiada_mes4  + c.vlrtarifa, ctp.vltarifa_financiada_mes4),
                        ctp.vltarifa_financiada_mes5  = DECODE(c.nrmesref, 5,  ctp.vltarifa_financiada_mes5  + c.vlrtarifa, ctp.vltarifa_financiada_mes5),
                        ctp.vltarifa_financiada_mes6  = DECODE(c.nrmesref, 6,  ctp.vltarifa_financiada_mes6  + c.vlrtarifa, ctp.vltarifa_financiada_mes6),
                        ctp.vltarifa_financiada_mes7  = DECODE(c.nrmesref, 7,  ctp.vltarifa_financiada_mes7  + c.vlrtarifa, ctp.vltarifa_financiada_mes7),
                        ctp.vltarifa_financiada_mes8  = DECODE(c.nrmesref, 8,  ctp.vltarifa_financiada_mes8  + c.vlrtarifa, ctp.vltarifa_financiada_mes8),
                        ctp.vltarifa_financiada_mes9  = DECODE(c.nrmesref, 9,  ctp.vltarifa_financiada_mes9  + c.vlrtarifa, ctp.vltarifa_financiada_mes9),
                        ctp.vltarifa_financiada_mes10 = DECODE(c.nrmesref, 10, ctp.vltarifa_financiada_mes10 + c.vlrtarifa, ctp.vltarifa_financiada_mes10),
                        ctp.vltarifa_financiada_mes11 = DECODE(c.nrmesref, 11, ctp.vltarifa_financiada_mes11 + c.vlrtarifa, ctp.vltarifa_financiada_mes11),
                        ctp.vltarifa_financiada_mes12 = DECODE(c.nrmesref, 12, ctp.vltarifa_financiada_mes12 + c.vlrtarifa, ctp.vltarifa_financiada_mes12)
           WHEN NOT MATCHED THEN
             INSERT
             (cdcooper
             ,nrdconta
             ,nranolct
             ,vlpagomes1
             ,vlpagomes2
             ,vlpagomes3
             ,vlpagomes4
             ,vlpagomes5
             ,vlpagomes6
             ,vlpagomes7
             ,vlpagomes8
             ,vlpagomes9
             ,vlpagomes10
             ,vlpagomes11
             ,vlpagomes12
             ,vlpagoanoant
             ,vltarifa_financiada_mes1
             ,vltarifa_financiada_mes2
             ,vltarifa_financiada_mes3
             ,vltarifa_financiada_mes4
             ,vltarifa_financiada_mes5
             ,vltarifa_financiada_mes6
             ,vltarifa_financiada_mes7
             ,vltarifa_financiada_mes8
             ,vltarifa_financiada_mes9
             ,vltarifa_financiada_mes10
             ,vltarifa_financiada_mes11
             ,vltarifa_financiada_mes12
             ,vltarifa_financiada_anoant)
             VALUES
             (c.cdcooper
             ,c.nrdconta
             ,c.anomvtolt
             ,0
             ,0
             ,0
             ,0
             ,0
             ,0
             ,0
             ,0
             ,0
             ,0
             ,0
             ,0
             ,0
             ,DECODE(c.nrmesref, 1,  c.vlrtarifa, 0)
             ,DECODE(c.nrmesref, 2,  c.vlrtarifa, 0)
             ,DECODE(c.nrmesref, 3,  c.vlrtarifa, 0)
             ,DECODE(c.nrmesref, 4,  c.vlrtarifa, 0)
             ,DECODE(c.nrmesref, 5,  c.vlrtarifa, 0)
             ,DECODE(c.nrmesref, 6,  c.vlrtarifa, 0)
             ,DECODE(c.nrmesref, 7,  c.vlrtarifa, 0)
             ,DECODE(c.nrmesref, 8,  c.vlrtarifa, 0)
             ,DECODE(c.nrmesref, 9,  c.vlrtarifa, 0)
             ,DECODE(c.nrmesref, 10, c.vlrtarifa, 0)
             ,DECODE(c.nrmesref, 11, c.vlrtarifa, 0)
             ,DECODE(c.nrmesref, 12, c.vlrtarifa, 0)
             ,0);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic  := 1035;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                          ||'TBCOTAS_TARIFAS_PAGAS:'
                          ||' cdcooper:'||pr_cdcooper
                          ||', nrdconta:'||pr_dtmvtoan
                          ||', vr_anomvtolt:'||vr_anomvtolt
                          ||'. '||SQLERRM;
          RAISE vr_exc_erro;
      END;                             
    END LOOP;
         
  EXCEPTION
    WHEN vr_exc_erro THEN
      dbms_output.put_line('vr_dscritic: ' || vr_dscritic);
      dbms_output.put_line('vr_dscritic: ' || vr_dscritic);
      rollback;
    WHEN OTHERS THEN
      dbms_output.put_line('vr_dscritic: ' || vr_dscritic);
      dbms_output.put_line('vr_dscritic: ' || vr_dscritic);
      rollback;
  END pc_apura_tarifas_financiadas;
  
begin
  dbms_output.enable(null);
  -- Percorre para cada uma das cooperativas
  for rw_coop in cr_coop loop
    dbms_output.put_line('--------------------------------------------------------');
    dbms_output.put_line('Processando cooperativa ' || rw_coop.cdcooper || ' - ' || rw_coop.nmrescop);
    dbms_output.put_line('--------------------------------------------------------');
    -- Seta a data de início na data de processamento
    vr_dataproc := vr_dataini;
    -- Executa o processo até a data de processamento ser maior que a data final
    while vr_dataproc <= vr_datafim loop
      dbms_output.put_line(' ->  ' || to_char(vr_dataproc,'dd/mm/yyyy'));
      -- chama o processo de apuração (igual ao criado na package, mas sem registros em logs da execução do processo batch)
      pc_apura_tarifas_financiadas(pr_cdcooper => rw_coop.cdcooper, pr_dtmvtoan => vr_dataproc);
      vr_dataproc := vr_dataproc + 1;
      
      commit;
      
    end loop;
  end loop;
exception
  when others then
    dbms_output.put_line('Erro no script de Importação de Dados Tarifas - '    ||
                         'vr_dataini : ' || to_char(vr_dataini,'dd/mm/yyyy')   || ' / ' ||
                         'vr_datafim : ' || to_char(vr_datafim,'dd/mm/yyyy')   || ' / ' ||
                         'vr_dataproc: ' || to_char(vr_dataproc,'dd/mm/yyyy')  || ' / ' ||
                         'erro: '        || sqlerrm);
    rollback;
end;

