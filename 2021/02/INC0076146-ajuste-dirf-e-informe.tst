PL/SQL Developer Test script 3.0
532
DECLARE 
  vr_cdcritic INTEGER;
  vr_exc_erro EXCEPTION;
  vr_dscritic   VARCHAR2(5000) := ' ';
  vr_nmarqimp1       VARCHAR2(100)  := 'erro.txt';
  vr_ind_arquiv1     utl_file.file_type;
  vr_nmarqimp2       VARCHAR2(100)  := 'backup.txt';
  vr_ind_arquiv2     utl_file.file_type;
  vr_nmarqimp3       VARCHAR2(100)  := 'log.txt';
  vr_ind_arquiv3     utl_file.file_type;
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0076146'; 
  
  vr_cdretenc   NUMBER; --cod retencao do lancamento
  vr_nrseqdig   NUMBER; --seq digitacao
  vr_ano        NUMBER := 2020;
  vr_dsobserv   VARCHAR2(12);
  vr_rowid      ROWID;
  
  CURSOR cr_crapdir  IS
  SELECT cdcooper, 
         nrdconta,
         dtmvtolt,
         vlrirrpp##8 IR_MES_8_FALTANTE, 
         vlrirrpp##9 IR_MES_9_FALTANTE,
         (select sum(lpp.vllanmto) 
            from craplpp lpp
           where lpp.cdcooper = crapdir.cdcooper 
             and lpp.nrdconta = crapdir.nrdconta 
             and lpp.cdhistor = 151
             and lpp.dtmvtolt between to_date('01/08/2020','dd/mm/rrrr') and to_date('31/08/2020','dd/mm/rrrr')) RTR_MES_8_FALTANTE,
         (select sum(lpp.vllanmto) 
            from craplpp lpp
           where lpp.cdcooper = crapdir.cdcooper 
             and lpp.nrdconta = crapdir.nrdconta 
             and lpp.cdhistor = 151
             and lpp.dtmvtolt between to_date('01/09/2020','dd/mm/rrrr') and to_date('30/09/2020','dd/mm/rrrr')) RTR_MES_9_FALTANTE
    from crapdir 
   where dtmvtolt = to_date('31/12/2020','dd/mm/rrrr')
     and (crapdir.vlrirrpp##8 > 0 or crapdir.vlrirrpp##9 > 0)
        AND      (crapdir.vlrentot##1  = 0
        AND       crapdir.vlrentot##2  = 0
        AND       crapdir.vlrentot##3  = 0
        AND       crapdir.vlrentot##4  = 0
        AND       crapdir.vlrentot##5  = 0
        AND       crapdir.vlrentot##6  = 0
        AND       crapdir.vlrentot##7  = 0
        AND       crapdir.vlrentot##8  = 0
        AND       crapdir.vlrentot##9  = 0
        AND       crapdir.vlrentot##10 = 0
        AND       crapdir.vlrentot##11 = 0
        AND       crapdir.vlrentot##12 = 0
        AND       crapdir.vlirfcot = 0)
  order by cdcooper, nrdconta;                  
  rw_crapdir cr_crapdir%ROWTYPE;
  
  CURSOR cr_craplpp IS
  SELECT origem.cdcooper, origem.nrdconta,sum(vlrendim8) vlrendim8, sum(vlrendim9) vlrendim9
    from
    (
    SELECT cdcooper, nrdconta, dtmvtolt, vllanmto vlrendim8, 0 vlrendim9
      from craplpp craprpp 
     where cdhistor = 151 and dtmvtolt between to_date('01/08/2020','dd/mm/rrrr') and to_date('31/08/2020','dd/mm/rrrr')
    union all
    SELECT cdcooper, nrdconta, dtmvtolt, 0 vlrendim8, vllanmto vlrendim9
      from craplpp craprpp 
     where cdhistor = 151 and dtmvtolt between to_date('01/09/2020','dd/mm/rrrr') and to_date('30/09/2020','dd/mm/rrrr')
    ) origem
    group by origem.cdcooper, origem.nrdconta
    order by origem.cdcooper, origem.nrdconta;
  rw_craplpp cr_craplpp%ROWTYPE;
  
  CURSOR cr_crapdir_atual(pr_cdcooper IN crapdir.cdcooper%TYPE,
                          pr_nrdconta IN crapdir.nrdconta%TYPE,
                          pr_dtmvtolt IN crapdir.dtmvtolt%TYPE) IS
   SELECT crapdir.*, crapdir.rowid
     FROM crapdir
    WHERE crapdir.cdcooper = pr_cdcooper
      AND crapdir.nrdconta = pr_nrdconta
      AND crapdir.dtmvtolt = pr_dtmvtolt;
  rw_crapdir_atual cr_crapdir_atual%ROWTYPE;
  
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
  SELECT cop.nmrescop
        ,cop.nmextcop
        ,cop.nrdocnpj
    FROM crapcop cop
   WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
    
  --busca cadastro de associados
  CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE,
                    pr_nrdconta IN crapdir.nrdconta%TYPE) IS
    SELECT   cdagenci
            ,nrdconta
            ,inpessoa
            ,nrcpfcgc
            ,nmprimtl
    FROM    crapass
    WHERE   crapass.cdcooper = pr_cdcooper
    AND     crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
  
   CURSOR cr_crapdrf (pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_nrseqdig IN crapvir.nrseqdig%TYPE,
                      pr_cdretenc IN crapvir.cdretenc%TYPE,
                      pr_nranocal IN crapvir.nranocal%TYPE,
                      pr_nrcpfbnf IN crapvir.nrcpfbnf%TYPE)IS
    SELECT 1
      FROM crapdrf
     WHERE cdcooper = pr_Cdcooper
       AND nrseqdig = pr_nrseqdig
       AND cdretenc = pr_cdretenc
       AND nranocal = pr_nranocal
       AND nrcpfbnf = pr_nrcpfbnf;
   rw_crapdrf cr_crapdrf%ROWTYPE;
  
   CURSOR cr_crapvir (pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_nrcpfbnf IN crapvir.nrcpfbnf%TYPE,
                      pr_nranocal IN crapvir.nranocal%TYPE,
                      pr_nrmesref IN crapvir.nrmesref%TYPE,
                      pr_cdretenc IN crapvir.cdretenc%TYPE)IS
    SELECT  crapvir.*, rowid
    FROM    crapvir
    WHERE   crapvir.cdcooper = pr_cdcooper
    AND     crapvir.nrcpfbnf = pr_nrcpfbnf
    AND     crapvir.nranocal = pr_nranocal
    AND     crapvir.cdretenc = pr_cdretenc;
  rw_crapvir cr_crapvir%ROWTYPE;
  
  function fn_busca_nrsegdig(pr_cdcooper IN crapcop.cdcooper%TYPE,
                             pr_nrcpfbnf IN crapvir.nrcpfbnf%TYPE,
                             pr_nranocal IN crapvir.nranocal%TYPE,
                             pr_cdretenc IN crapvir.cdretenc%TYPE) return number IS

 CURSOR cr_crapvir IS
    SELECT  distinct nrseqdig
    FROM    crapvir
    WHERE   crapvir.cdcooper = pr_cdcooper
    AND     crapvir.nrcpfbnf = pr_nrcpfbnf
    AND     crapvir.nranocal = pr_nranocal
    AND     crapvir.cdretenc = pr_cdretenc;
  rw_crapvir cr_crapvir%ROWTYPE;    

 CURSOR cr_crapvir_max_all IS
    SELECT  max(nrseqdig) nrseqdig
    FROM    crapvir
    WHERE   crapvir.cdcooper = pr_cdcooper;
  rw_crapvir_max_all cr_crapvir_max_all%ROWTYPE;  
 
  BEGIN
    OPEN cr_crapvir;
    FETCH cr_crapvir INTO rw_crapvir;
    IF cr_crapvir%NOTFOUND THEN
      CLOSE cr_crapvir;
      
       OPEN cr_crapvir_max_all;
      FETCH cr_crapvir_max_all INTO rw_crapvir_max_all;
      IF cr_crapvir_max_all%NOTFOUND THEN
        CLOSE cr_crapvir_max_all;
        vr_dscritic := 'Nao foi possivel encontrar o ultimo nrseqdig para a cdcooper '|| pr_cdcooper;
        raise vr_exc_erro;
      END IF;
      CLOSE cr_crapvir_max_all;
      RETURN (nvl(rw_crapvir_max_all.nrseqdig,0) + 1);
      
    END IF;
    CLOSE cr_crapvir;
    RETURN rw_crapvir.nrseqdig;
  END fn_busca_nrsegdig;
      
  PROCEDURE erro (pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv1, pr_msg);    
  END; 
  PROCEDURE backup (pr_msg VARCHAR2) IS
    BEGIN
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv2, pr_msg);
  END; 
  PROCEDURE log (pr_msg VARCHAR2) IS
    BEGIN
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv3, to_char(sysdate,'ddmmyyyy_hh24miss')||' - '|| pr_msg);
  END; 
  
  PROCEDURE fecha_arquivos IS
  BEGIN
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1);
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2);
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3);  
  END;
  
  --INICIO
BEGIN   
   --Criar arquivo
   gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                           ,pr_nmarquiv => vr_nmarqimp1       --> Nome do arquivo
                           ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                           ,pr_utlfileh => vr_ind_arquiv1     --> handle do arquivo aberto
                           ,pr_des_erro => vr_dscritic);      --> erro
   -- em caso de crítica
   IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exc_erro;
   END IF; 
--Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp2       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv2     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exc_erro;
  END IF;   
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp3       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv3     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exc_erro;
  END IF;
      
  log('Inicio do processamento - ajuste DIRF');
   
  FOR rw_crapdir IN cr_crapdir LOOP
    
     OPEN cr_crapass(rw_crapdir.cdcooper, rw_crapdir.nrdconta);--busca associado
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN -- se nao encontrou associado gera critica e pula para proximo
      CLOSE cr_crapass;
      vr_dscritic := 'Cooperado nao encontrado! Cooper: '|| rw_crapdir.cdcooper ||' - Conta: ' || rw_crapdir.nrdconta;
      raise vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;
    /* 3426/8053 -> IR sobre aplicacoes finnanceiras de renda fixa, exceto em
                   fundos de investimento */
    --verifica se eh pessoa fisica
    IF rw_crapass.inpessoa = 1   THEN
      vr_cdretenc := 8053;
    ELSE
      vr_cdretenc := 3426;
    END IF;
    
    vr_nrseqdig := fn_busca_nrsegdig(rw_crapdir.cdcooper, rw_crapass.nrcpfcgc, vr_ano, vr_cdretenc);
   
    -- se tem dados referente ao mes 8
    IF rw_crapdir.IR_MES_8_FALTANTE > 0 OR rw_crapdir.RTR_MES_8_FALTANTE > 0 THEN
      -- verifica se ja existe o registro
      OPEN cr_crapvir (pr_cdcooper => rw_crapdir.cdcooper,
                       pr_nrcpfbnf => rw_crapass.nrcpfcgc,
                       pr_nranocal => vr_ano,
                       pr_nrmesref => 8,
                       pr_cdretenc => vr_cdretenc);
      FETCH cr_crapvir INTO rw_crapvir;
      IF cr_crapvir%NOTFOUND THEN
        -- se nao existe, cria um registro novo
        CLOSE cr_crapvir;
        log('Criar crapvir mes 8 - Cooper: '|| rw_crapdir.cdcooper ||' - Conta: ' || rw_crapdir.nrdconta);
        
        BEGIN
          INSERT INTO crapvir
                  ( cdcooper
                   ,nrcpfbnf
                   ,nranocal
                   ,nrmesref
                   ,cdretenc
                   ,nrseqdig
                   ,tporireg
                   ,vlrrtirf
                   ,vlrdrtrt
                  )
                  VALUES
                  ( rw_crapdir.cdcooper
                   ,rw_crapass.nrcpfcgc
                   ,vr_ano
                   ,8
                   ,vr_cdretenc
                   ,vr_nrseqdig
                   ,1
                   ,nvl(rw_crapdir.IR_MES_8_FALTANTE,0) * 100
                   ,nvl(rw_crapdir.RTR_MES_8_FALTANTE,0) * 100
                  )
                  RETURNING ROWID INTO vr_rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao criar crapvri 8 - Cooper: '|| rw_crapdir.cdcooper ||' - Conta: ' || rw_crapdir.nrdconta || ' erro - '|| SQLERRM;
            RAISE vr_exc_erro;
        END;
        backup('DELETE FROM CRAPVIR WHERE ROWID = '''||vr_rowid||''';');
        
      ELSE
        -- se ja existe, faz update
        CLOSE cr_crapvir;
        log('Atualizar crapvir mes 8 - Cooper: '|| rw_crapdir.cdcooper ||' - Conta: ' || rw_crapdir.nrdconta);
        
        BEGIN
          UPDATE crapvir
             SET crapvir.vlrrtirf = crapvir.vlrrtirf + (nvl(rw_crapdir.IR_MES_8_FALTANTE,0) * 100),
                 crapvir.vlrdrtrt = crapvir.vlrdrtrt + (nvl(rw_crapdir.RTR_MES_8_FALTANTE,0) * 100)
           WHERE rowid = rw_crapvir.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao update crapvir 8 - Cooper: '|| rw_crapdir.cdcooper ||' - Conta: ' || rw_crapdir.nrdconta || ' erro - '|| SQLERRM;
            RAISE vr_exc_erro;
        END;
        backup('UPDATE CRAPVIR ' ||
                 ' SET vlrrtirf = '|| rw_crapvir.vlrrtirf ||','||
                     ' vlrdrtrt = '||rw_crapvir.vlrdrtrt ||
               ' WHERE ROWID = '''||rw_crapvir.rowid||''';');       
        
      END IF; 

    END IF; -- fim if mes 8
    
    
   
    -- se tem dados referente ao mes 9
    IF rw_crapdir.IR_MES_9_FALTANTE > 0 OR rw_crapdir.RTR_MES_9_FALTANTE > 0 THEN
      -- verifica se ja existe o registro
      OPEN cr_crapvir (pr_cdcooper => rw_crapdir.cdcooper,
                       pr_nrcpfbnf => rw_crapass.nrcpfcgc,
                       pr_nranocal => vr_ano,
                       pr_nrmesref => 9,
                       pr_cdretenc => vr_cdretenc);
      FETCH cr_crapvir INTO rw_crapvir;
      IF cr_crapvir%NOTFOUND THEN
        -- se nao existe, cria um registro novo
        CLOSE cr_crapvir;
        log('Criar crapvir mes 9 - Cooper: '|| rw_crapdir.cdcooper ||' - Conta: ' || rw_crapdir.nrdconta);
        
        BEGIN
          INSERT INTO crapvir
                  ( cdcooper
                   ,nrcpfbnf
                   ,nranocal
                   ,nrmesref
                   ,cdretenc
                   ,nrseqdig
                   ,tporireg
                   ,vlrrtirf
                   ,vlrdrtrt
                  )
                  VALUES
                  ( rw_crapdir.cdcooper
                   ,rw_crapass.nrcpfcgc
                   ,vr_ano
                   ,9
                   ,vr_cdretenc
                   ,vr_nrseqdig
                   ,1
                   ,nvl(rw_crapdir.IR_MES_9_FALTANTE,0) * 100
                   ,nvl(rw_crapdir.RTR_MES_9_FALTANTE,0) * 100
                  )
                  RETURNING ROWID INTO vr_rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao criar crapvri 9 - Cooper: '|| rw_crapdir.cdcooper ||' - Conta: ' || rw_crapdir.nrdconta || ' erro - '|| SQLERRM;
            RAISE vr_exc_erro;
        END;
        backup('DELETE FROM CRAPVIR WHERE ROWID = '''||vr_rowid||''';');
        
      ELSE
        -- se ja existe, faz update
        CLOSE cr_crapvir;
        log('Atualizar crapvir mes 9 - Cooper: '|| rw_crapdir.cdcooper ||' - Conta: ' || rw_crapdir.nrdconta);
        
        BEGIN
          UPDATE crapvir
             SET crapvir.vlrrtirf = crapvir.vlrrtirf + (nvl(rw_crapdir.IR_MES_9_FALTANTE,0) * 100),
                 crapvir.vlrdrtrt = crapvir.vlrdrtrt + (nvl(rw_crapdir.RTR_MES_9_FALTANTE,0) * 100)
           WHERE rowid = rw_crapvir.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao update crapvir 9 - Cooper: '|| rw_crapdir.cdcooper ||' - Conta: ' || rw_crapdir.nrdconta || ' erro - '|| SQLERRM;
            RAISE vr_exc_erro;
        END;
        backup('UPDATE CRAPVIR ' ||
                 ' SET vlrrtirf = '|| rw_crapvir.vlrrtirf ||','||
                     ' vlrdrtrt = '||rw_crapvir.vlrdrtrt ||
               ' WHERE ROWID = '''||rw_crapvir.rowid||''';');       
        
      END IF; 
      
    END IF;  -- fim if mes 9   
    
    
    -- verifica se cria crapdrf
    IF rw_crapdir.IR_MES_8_FALTANTE > 0 OR rw_crapdir.RTR_MES_8_FALTANTE > 0 OR
       rw_crapdir.IR_MES_9_FALTANTE > 0 OR rw_crapdir.RTR_MES_9_FALTANTE > 0 THEN    
    
      OPEN cr_crapdrf (rw_crapdir.cdcooper,
                       vr_nrseqdig,
                       vr_cdretenc,
                       vr_ano,
                       rw_crapass.nrcpfcgc); 
      FETCH cr_crapdrf INTO rw_crapdrf;
      IF cr_crapdrf%NOTFOUND THEN
        -- se nao existe, cria um registro novo
        CLOSE cr_crapdrf;
        log('Criar crapdrf - Cooper: '|| rw_crapdir.cdcooper ||' - Conta: ' || rw_crapdir.nrdconta);
        
        
         OPEN cr_crapcop(pr_cdcooper => rw_crapdir.cdcooper);
        FETCH cr_crapcop INTO rw_crapcop;
        IF cr_crapcop%NOTFOUND THEN
          CLOSE cr_crapcop;
          vr_dscritic := 'Cooperativa nao encontrada! Cooper ' || rw_crapdir.cdcooper;
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_crapcop;
        END IF;
        
        vr_dsobserv := lpad(rw_crapass.cdagenci, 3,'0')||' '||lpad(rw_crapass.nrdconta,8,'0');
        BEGIN
          INSERT INTO crapdrf --insere dados DIRF
            ( cdretenc
             ,nrseqdig
             ,tporireg
             ,tpregist
             ,dtmvtolt
             ,nranocal
             ,inpessoa
             ,insitimp
             ,nmbenefi
             ,nrcpfbnf
             ,nrcpfcgc
             ,nrdconta
             ,dsobserv
             ,cdcooper
            )
            VALUES
            ( vr_cdretenc
             ,vr_nrseqdig
             ,1
             ,2
             ,rw_crapdir.dtmvtolt
             ,vr_ano
             ,rw_crapass.inpessoa
             ,0
             ,rw_crapass.nmprimtl
             ,rw_crapass.nrcpfcgc
             ,rw_crapcop.nrdocnpj
             ,rw_crapdir.nrdconta
             ,vr_dsobserv
             ,rw_crapdir.cdcooper
            ) RETURNING ROWID INTO vr_rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao criar crapdrf - Cooper: '|| rw_crapdir.cdcooper ||' - Conta: ' || rw_crapdir.nrdconta || ' erro - '|| SQLERRM;
            RAISE vr_exc_erro;
        END;
        backup('DELETE FROM CRAPDRF WHERE ROWID = '''||vr_rowid||''';');
        
      ELSE
        -- se ja existe, nao precisa fazer nada
        CLOSE cr_crapdrf;
        log('Nao precisou criar crapdrf - Cooper: '|| rw_crapdir.cdcooper ||' - Conta: ' || rw_crapdir.nrdconta);
      END IF;
    END IF; -- if mes 8 e mes 9 > 0
  
   
   
   
   END LOOP; 
   log('Fim do processo de atualizacao - DIRF');
   
   
   
   log('Inicio fase II - ajuste informe de rendimento');
   
   FOR rw_craplpp IN cr_craplpp LOOP
   
     --encontrar registro na crapdir
     OPEN cr_crapdir_atual(pr_cdcooper => rw_craplpp.cdcooper,
                           pr_nrdconta => rw_craplpp.nrdconta,
                           pr_dtmvtolt => to_date('31/12/'||vr_ano,'dd/mm/rrrr'));
     FETCH cr_crapdir_atual INTO rw_crapdir_atual;
     IF cr_crapdir_atual%NOTFOUND THEN
       CLOSE cr_crapdir_atual;
       vr_dscritic := 'Registro na crapdir nao encontrada! Cooper: '|| rw_craplpp.cdcooper ||' - Conta: ' || rw_craplpp.nrdconta;
       RAISE vr_exc_erro;
     ELSE
       CLOSE cr_crapdir_atual;
     END IF; 
   
     BEGIN
       UPDATE crapdir
          SET vlrenrpp    = vlrenrpp    + nvl(rw_craplpp.vlrendim8,0) + nvl(rw_craplpp.vlrendim9,0),
              vlrentot##8 = vlrentot##8 + nvl(rw_craplpp.vlrendim8,0),
              vlrentot##9 = vlrentot##9 + nvl(rw_craplpp.vlrendim9,0)
        WHERE crapdir.rowid = rw_crapdir_atual.rowid;
        
     EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar crapdir - Cooper: '|| rw_craplpp.cdcooper ||' - Conta: ' || rw_craplpp.nrdconta || ' erro - '|| SQLERRM;
          RAISE vr_exc_erro;
     END;
     backup( 'UPDATE CRAPDIR ' ||
               ' SET vlrenrpp    = '|| replace(rw_crapdir_atual.vlrenrpp,',','.')    ||','||
                   ' vlrentot##8 = '|| replace(rw_crapdir_atual.vlrentot##8,',','.') ||','||
                   ' vlrentot##9 = '|| replace(rw_crapdir_atual.vlrentot##9,',','.') ||
             ' WHERE ROWID = '''||rw_crapdir_atual.rowid||''';');
             
     log('Atualizou o crapdir - Cooper: '|| rw_craplpp.cdcooper ||' - Conta: ' || rw_craplpp.nrdconta);
     
   END LOOP;
   
   log('Fim do ajuste informe de rendimento');
   
   
   COMMIT; 
   fecha_arquivos;
   :vr_dscritic := 'SUCESSO';
   
EXCEPTION
  WHEN vr_exc_erro THEN
    erro(vr_dscritic);   
    :vr_cdcritic := vr_cdcritic;
    :vr_dscritic := vr_dscritic;
    fecha_arquivos;
    ROLLBACK;
  WHEN OTHERS THEN
    vr_dscritic := 'Erro inesperado' || sqlerrm;
    erro(vr_dscritic);
    :vr_cdcritic := 0;
    :vr_dscritic := vr_dscritic;
    fecha_arquivos;
    ROLLBACK;
END;
2
vr_cdcritic
0
5
vr_dscritic
0
5
1
vr_dscritic
