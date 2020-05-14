/*************************************************************888888888****
11/05/2020 - P577 - 30838 - Risco Inclusão.
             ROLLBACK - Corrigir Risco Inclusão dos Contratos Renegociados.
*******************************************8888888888**********************/
DECLARE
  --Empréstimos Renegociados
  CURSOR cr_renegociados IS
    SELECT trc.cdcooper
          ,trc.nrdconta
          ,trc.nrctrepr
          ,trc.nrctremp
    FROM   tbepr_renegociacao_contrato  trc
          ,tbepr_renegociacao           tr  
          ,crawepr                      wepr      
    WHERE  trc.cdcooper = tr.cdcooper
    AND    trc.nrdconta = tr.nrdconta
    AND    trc.nrctremp = tr.nrctremp
    AND    tr.dtlibera IS NOT NULL --Renegociação Efetivada    
    AND    trc.cdcooper = wepr.cdcooper
    AND    trc.nrdconta = wepr.nrdconta
    AND    trc.nrctrepr = wepr.nrctremp
    AND    Nvl(wepr.flgreneg,0) = 1 --Renegociado 
    ORDER BY trc.cdcooper
            ,trc.nrdconta
            ,trc.nrctremp
            ,trc.nrctrepr;    
  --         
  --
  --Variáveis de Erro
  vr_erro                  EXCEPTION;
  vr_ds_erro               VARCHAR2(1000);    
  vr_cdcritic              crapcri.cdcritic%TYPE;
  vr_dscritic              VARCHAR2(4000);        
  --
  -- Variáveis   
  rw_crapdat                btch0001.cr_crapdat%ROWTYPE;
  vr_flgreneg               crawepr.flgreneg%TYPE;
  vr_nrcpfcnpj_base         tbrisco_operacoes.nrcpfcnpj_base%TYPE;
  vr_tpctrato               NUMBER(2) := 90; --Empréstimos (Fixo)
  vr_inrisco_rating         tbrisco_operacoes.inrisco_rating%TYPE; 
  vr_inrisco_inclusao       tbrisco_operacoes.inrisco_inclusao%TYPE; 
  vr_inrisco_melhora        tbrisco_operacoes.inrisco_melhora%TYPE;
  vr_inrisco_operacao       tbrisco_central_ocr.inrisco_operacao%TYPE; 
  vr_dsctrreneg             VARCHAR2(1000);
  vr_innivris               tbrisco_operacoes.inrisco_inclusao%TYPE;    
  vr_risco_inclusao_antigo  VARCHAR2(2); 
  vr_risco_inc_prop_antigo  VARCHAR2(2); 
  vr_risco_inclusao_novo    VARCHAR2(2);  
  vr_dsnivris               crawepr.dsnivris%TYPE;
  vr_dsnivori               crawepr.dsnivori%TYPE;
  vr_qt_reg_lido            NUMBER := 0;
  vr_qt_reg_diferente       NUMBER := 0;
  vr_qt_reg_alterado        NUMBER := 0;
  --
  --
  --Retorna os contratos renegociados separados por vírgula para ser utilizado para o cálculo do Novo Risco Inlusão, conforme parâmetro da RISC0004.pc_calcula_risco_inclusao.
  FUNCTION fn_retorna_dsctr_reneg(pr_cdcooper IN tbepr_renegociacao_contrato.cdcooper%TYPE
                                 ,pr_nrdconta IN tbepr_renegociacao_contrato.nrdconta%TYPE
                                 ,pr_nrctremp IN tbepr_renegociacao_contrato.nrctremp%TYPE
                                 ,pr_nrctrepr IN tbepr_renegociacao_contrato.nrctrepr%TYPE) RETURN VARCHAR2 IS
    CURSOR cr_contrato_renegociado(pr_cdcooper IN tbepr_renegociacao_contrato.cdcooper%TYPE
                                  ,pr_nrdconta IN tbepr_renegociacao_contrato.nrdconta%TYPE
                                  ,pr_nrctremp IN tbepr_renegociacao_contrato.nrctremp%TYPE
                                  ,pr_nrctrepr IN tbepr_renegociacao_contrato.nrctrepr%TYPE) IS  
       SELECT trc.nrctrepr
       FROM   tbepr_renegociacao_contrato  trc
       WHERE  trc.cdcooper = pr_cdcooper
       AND    trc.nrdconta = pr_nrdconta
       AND    trc.nrctremp = pr_nrctremp
       AND    trc.nrctrepr = Nvl(pr_nrctrepr,trc.nrctrepr);
                            
    vr_dsctrreneg  VARCHAR2(1000);             
  BEGIN
    FOR rw_contrato_renegociado IN cr_contrato_renegociado(pr_cdcooper => pr_cdcooper
                                                          ,pr_nrdconta => pr_nrdconta
                                                          ,pr_nrctremp => pr_nrctremp
                                                          ,pr_nrctrepr => pr_nrctrepr)  LOOP
      IF vr_dsctrreneg IS NULL THEN
        vr_dsctrreneg := rw_contrato_renegociado.nrctrepr;
      ELSE
        vr_dsctrreneg := vr_dsctrreneg||','||rw_contrato_renegociado.nrctrepr;
      END IF;
    END LOOP;
    
    RETURN(vr_dsctrreneg);
  END fn_retorna_dsctr_reneg;
  --
  --
BEGIN
  --Imprime Mensagem de Início de Execução
  dbms_output.put_line('Início Execução: '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));  
  
  --Para cada Empréstimo Renegociado
  FOR rw_renegociados IN cr_renegociados LOOP
    --Busca data de movimento da Cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => rw_renegociados.cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_ds_erro := 'Erro ao Buscar Data da Cooperativa: '||rw_renegociados.cdcooper||'. Erro: '||SubStr(SQLERRM,1,255);
      RAISE vr_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;       
  
    --Limpa Variáveis
    vr_inrisco_rating        := NULL;
    vr_inrisco_inclusao      := NULL;
    vr_inrisco_melhora       := NULL;
    vr_inrisco_operacao      := NULL;
    vr_risco_inclusao_antigo := NULL;
    vr_risco_inc_prop_antigo := NULL;
    vr_risco_inclusao_novo   := NULL;
    vr_dsnivris              := NULL;
    vr_dsnivori              := NULL;
    vr_flgreneg              := NULL;
    vr_nrcpfcnpj_base        := NULL;
    vr_dsctrreneg            := NULL;
    vr_innivris              := NULL;
    
    --Incrementa Qtde de Registros Lidos
    vr_qt_reg_lido := Nvl(vr_qt_reg_lido,0) + 1;
    
    --Busca Risco Inclusão Atual na Risco Operações
    BEGIN
      SELECT Nvl(tbro.inrisco_rating_autom,tbro.inrisco_rating)  inrisco_rating
            ,tbro.inrisco_inclusao
            ,tbro.nrcpfcnpj_base
            ,tbro.inrisco_melhora
      INTO   vr_inrisco_rating
            ,vr_inrisco_inclusao
            ,vr_nrcpfcnpj_base
            ,vr_inrisco_melhora
      FROM   tbrisco_operacoes tbro
      WHERE  tbro.cdcooper = rw_renegociados.cdcooper
      AND    tbro.nrdconta = rw_renegociados.nrdconta
      AND    tbro.nrctremp = rw_renegociados.nrctrepr
      AND    tbro.tpctrato = vr_tpctrato;   
    EXCEPTION
      WHEN OTHERS THEN
        vr_ds_erro := 'Erro ao Buscar Risco Inclusão na Risco Operações. Cooper: '||rw_renegociados.cdcooper||' | Conta: '||rw_renegociados.nrdconta||' | Contrato: '||rw_renegociados.nrctrepr||' | Tipo: '||vr_tpctrato||'. Erro: '||SubStr(SQLERRM,1,255);      
        RAISE vr_erro;
    END; 
    
    --Busca Risco Inclusão Atual na Proposta
    BEGIN
      SELECT Replace(t.dsnivris,' ',NULL)  dsnivris          
            ,Replace(t.dsnivori,' ',NULL)  dsnivori     
      INTO   vr_dsnivris
            ,vr_dsnivori    
      FROM   crawepr  t             
      WHERE  t.cdcooper = rw_renegociados.cdcooper
      AND    t.nrdconta = rw_renegociados.nrdconta
      AND    t.nrctremp = rw_renegociados.nrctrepr;
    EXCEPTION
      WHEN OTHERS THEN
        vr_ds_erro := 'Erro ao Buscar Risco Inclusão na Proposta. Cooper: '||rw_renegociados.cdcooper||' | Conta: '||rw_renegociados.nrdconta||' | Contrato: '||rw_renegociados.nrctrepr||'. Erro: '||SubStr(SQLERRM,1,255);      
        RAISE vr_erro;
    END;  
    
    --Busca Risco Operação
    BEGIN
      SELECT ris.inrisco_operacao
      INTO   vr_inrisco_operacao
      FROM   tbrisco_central_ocr  ris
      WHERE  ris.cdcooper = rw_renegociados.cdcooper
      AND    ris.nrdconta = rw_renegociados.nrdconta
      AND    ris.nrctremp = rw_renegociados.nrctrepr
      AND    ris.dtrefere = rw_crapdat.dtmvtoan;
    EXCEPTION
      WHEN No_Data_Found THEN
        vr_inrisco_operacao := 2;
      WHEN OTHERS THEN
        vr_ds_erro := 'Erro ao Buscar Risco Operação. Cooper: '||rw_renegociados.cdcooper||' | Conta: '||rw_renegociados.nrdconta||' | Contrato: '||rw_renegociados.nrctrepr||' Data Referência: '||rw_crapdat.dtmvtoan||'. Erro: '||SubStr(SQLERRM,1,255);      
        RAISE vr_erro;
    END;   
    /*
    --Buscar os Contratos Renegociados (Separados por virgula) para fazer o cálculo do Novo Risco Inclusão   
    vr_dsctrreneg := fn_retorna_dsctr_reneg(pr_cdcooper => rw_renegociados.cdcooper
                                           ,pr_nrdconta => rw_renegociados.nrdconta
                                           ,pr_nrctremp => rw_renegociados.nrctremp
                                           ,pr_nrctrepr => rw_renegociados.nrctrepr);
    */                                           
        
    --Calcula Risco Inclusão                                                 
    risc0004.pc_calcula_risco_inclusao(pr_cdcooper   => rw_renegociados.cdcooper
                                      ,pr_nrdconta   => rw_renegociados.nrdconta
                                      ,pr_dsctrliq   => NULL--vr_dsctrreneg
                                      ,pr_rw_crapdat => rw_crapdat
                                      ,pr_nrctremp   => rw_renegociados.nrctrepr
                                      ,pr_tpctrato   => vr_tpctrato
                                      ,pr_innivris   => vr_innivris
                                      ,pr_cdcritic   => vr_cdcritic
                                      ,pr_dscritic   => vr_dscritic);
    IF Nvl(vr_cdcritic,0) > 0 OR Trim(vr_dscritic) IS NOT NULL THEN                       
      vr_ds_erro := 'Erro ao Calcular Risco Inclusão. Cooper: '||rw_renegociados.cdcooper||' | Conta: '||rw_renegociados.nrdconta||' | Contrato: '||rw_renegociados.nrctrepr||' | Tipo: '||vr_tpctrato||'. Erro: '||vr_dscritic;
      RAISE vr_erro; 
    END IF; 
    
    --Não pode haver Risco Inclusão Novo Sem Valor
    IF vr_innivris IS NULL THEN
      vr_ds_erro := 'Não Encontrado Risco Inclusão Novo. Cooper: '||rw_renegociados.cdcooper||' | Conta: '||rw_renegociados.nrdconta||' | Contrato: '||rw_renegociados.nrctrepr||' | Tipo: '||vr_tpctrato||'. Erro: '||vr_dscritic;
      RAISE vr_erro;
    END IF; 
      
    --Se o Risco Inclusão Antigo (da Risco Operações ou da Proposta) é diferente do Risco Inclusão é Novo
    IF Nvl(vr_inrisco_inclusao,-999) <> Nvl(vr_innivris,-999)
      OR Nvl(vr_dsnivori,'XXX') <> Nvl(risc0004.fn_traduz_risco(vr_innivris),'XXX') THEN
      --Incrementa Qtde de Registros com Risco Inclusão Diferente
      vr_qt_reg_diferente := Nvl(vr_qt_reg_diferente,0) + 1;
      
      --Traduz Risco Inclusão Antigo da Risco Operações          
      vr_risco_inclusao_antigo := risc0004.fn_traduz_risco(vr_inrisco_inclusao);
      
      --Traduz Risco Inclusão Antigo da Risco Operações Proposta     
      vr_risco_inc_prop_antigo := vr_dsnivori;
      
      --Traduz Risco Inclusão Novo
      vr_risco_inclusao_novo := risc0004.fn_traduz_risco(vr_innivris);
      
      /*
      --Imprime Mensagens de Cabeçalho e Valores (Coop, Conta, Contrato e Riscos Inclusão Antigos e Novo)
      IF Nvl(vr_qt_reg_diferente,0) = 1 THEN 
        dbms_output.put_line(' ');
        dbms_output.put_line('Cooperativa;Conta;Renegociacao;Contrato;Risco Melhora;Risco Rating;Risco Operacao;Risco Inclusao Antigo Risco Operacoes;Risco Inclusao Antigo Proposta/Contrato;Risco Inclusao Novo');
      END IF; 
      dbms_output.put_line(rw_renegociados.cdcooper||';'||
                           rw_renegociados.nrdconta||';'||
                           rw_renegociados.nrctremp||';'||
                           rw_renegociados.nrctrepr||';'||                                                     
                           Nvl(risc0004.fn_traduz_risco(vr_inrisco_melhora),'NAO_TEM')||';'||
                           Nvl(risc0004.fn_traduz_risco(vr_inrisco_rating),'NAO_TEM')||';'||
                           Nvl(risc0004.fn_traduz_risco(vr_inrisco_operacao),'A')||';'|| --Na Central OCR se for Nulo (' ') então leva "A" 
                           Nvl(vr_risco_inclusao_antigo,'NAO_TEM')||';'||
                           Nvl(vr_risco_inc_prop_antigo,'A')||';'|| --Na Central OCR se for Nulo (' ') então leva "A" 
                           Nvl(vr_risco_inclusao_novo,'NAO_TEM'));   
      */
                                                                   
      -- Grava Risco Inclusão
      risc0004.pc_grava_risco_inclusao(pr_cdcooper         => rw_renegociados.cdcooper
                                      ,pr_nrdconta         => rw_renegociados.nrdconta
                                      ,pr_nrctremp         => rw_renegociados.nrctrepr
                                      ,pr_tpctrato         => vr_tpctrato
                                      ,pr_nrcpfcnpj_base   => vr_nrcpfcnpj_base
                                      ,pr_updatewer        => 1 --Atualizar dsnivris e dsnivori com risco inclusao na crawepr
                                      ,pr_inrisco_inclusao => vr_innivris
                                      ,pr_dscritic         => vr_dscritic);
      IF Trim(vr_dscritic) IS NOT NULL THEN
        vr_ds_erro := 'Erro ao Gravar Risco Inclusão. Cooper: '||rw_renegociados.cdcooper||' | Conta: '||rw_renegociados.nrdconta||' | Contrato: '||rw_renegociados.nrctrepr||' | Tipo: '||vr_tpctrato||'. Erro: '||vr_dscritic;
        RAISE vr_erro;
      ELSE 
        --Incrementa Qtde de Registros Alterados
        vr_qt_reg_alterado := Nvl(vr_qt_reg_alterado,0) + 1; 
      END IF;      
      --  
    END IF;  
    --    
  END LOOP;
  
  --Imprime Mensagens de Qtdes
  dbms_output.put_line(' ');
  dbms_output.put_line(Lpad(vr_qt_reg_lido,6,0)||' Registro(s) Lido(s)');
  dbms_output.put_line(Lpad(vr_qt_reg_diferente,6,0)||' Registro(s) com Risco Inclusão Diferente(s)');
  dbms_output.put_line(Lpad(vr_qt_reg_alterado,6,0)||' Registro(s) Alterado(s)');
  
  --Imprime Mensagem de Fim de Execução
  dbms_output.put_line(' ');
  dbms_output.put_line('Fim Execução: '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));
  
  --Salva
  COMMIT;
 
EXCEPTION
  WHEN vr_erro THEN
    dbms_output.put_line(vr_ds_erro);
    ROLLBACK;
    Raise_application_error(-20000,vr_ds_erro);
  WHEN OTHERS THEN
    dbms_output.put_line('Erro Geral no Script Rollback. Erro: '||SubStr(SQLERRM,1,255));
    ROLLBACK;
    Raise_application_error(-20001,'Erro Geral no Script Rollback. Erro: '||SubStr(SQLERRM,1,255)); 
END;
/
