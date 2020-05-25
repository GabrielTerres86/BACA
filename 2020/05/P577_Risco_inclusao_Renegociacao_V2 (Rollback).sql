/*****************************************************************
25/05/2020 - (ROLLBACK) P577 - 30838 - Risco Inclusão.
             Corrigir Risco Inclusão dos Contratos Renegociados.
*****************************************************************/
DECLARE   
  --Central OCR/Riscos
  CURSOR cr_ocr_antes_reneg(pr_cdcooper IN NUMBER
                           ,pr_nrdconta IN NUMBER
                           ,pr_nrctremp IN NUMBER) IS
    SELECT ocr.cdcooper
          ,ocr.nrdconta
          ,ocr.nrctremp
          ,ocr.dtrefere
          ,ocr.inrisco_rating
          ,ocr.inrisco_operacao
          ,ocr.inrisco_inclusao 
    FROM   tbrisco_central_ocr  ocr
    WHERE  ocr.cdcooper  = pr_cdcooper
    AND    ocr.nrdconta  = pr_nrdconta
    AND    ocr.nrctremp  = pr_nrctremp
    AND    ocr.dtrefere  = (select a.dtmvtoan from crapdat a where a.cdcooper = ocr.cdcooper);                        

  --Contratos Renegociados
  CURSOR cr_renegociados IS
    SELECT epr.cdcooper
          ,epr.nrdconta
          ,epr.nrctremp 
          ,wepr.nrctrliq##1  nrctrotr      
          ,epr.dtmvtolt      
    FROM   crapepr  epr   
          ,crawepr  wepr     
    WHERE  epr.cdcooper  = wepr.cdcooper
    AND    epr.nrdconta  = wepr.nrdconta
    AND    epr.nrctremp  = wepr.nrctremp
    AND    Nvl(wepr.flgreneg,0) = 1 --Regegociado    
    AND    epr.dtmvtolt >= To_Date('25/01/2020','dd/mm/yyyy') --Fixo (Performance). As Renegociações começaram em 28/Janeiro/2020.                                                     
    AND    epr.dtmvtolt <= To_Date('17/05/2020','dd/mm/yyyy') --Fixo (Performance). Apartir de 15/05/2020 foi corrigido o Risco Inclusão das Renegociações.                                                     
    ORDER BY epr.cdcooper
            ,epr.nrdconta
            ,epr.nrctremp;
  --
  --Variáveis de Erro
  vr_erro                      EXCEPTION;
  vr_ds_erro                   VARCHAR2(1000);     
  --
  -- Variáveis 
  vr_qt_reg_lido               NUMBER := 0;
  vr_qt_reg_alterado_risco     NUMBER := 0;
  vr_qt_reg_alterado_proposta  NUMBER := 0;
  vr_qt_reg_diferente          NUMBER := 0;
  vr_qt_reg_igual              NUMBER := 0;
  vr_qt_reg_nao_achou_ocr      NUMBER := 0;
  --
  vr_tem_ocr                   VARCHAR2(1) := 'N'; 
  vr_tem_dif_risco             VARCHAR2(1) := 'N'; 
  vr_tem_dif_proposta          VARCHAR2(1) := 'N'; 
  vr_tpctrato                  NUMBER(2)   := 90; --Empréstimos (Fixo)
  vr_inrisco_rating            tbrisco_operacoes.inrisco_rating%TYPE; 
  vr_inrisco_inclusao          tbrisco_operacoes.inrisco_inclusao%TYPE; 
  vr_inrisco_melhora           tbrisco_operacoes.inrisco_melhora%TYPE; 
  vr_dsrisco_melhora           crawepr.dsnivori%TYPE;
  vr_dsrisco_rating            crawepr.dsnivori%TYPE;
  vr_dsrisco_inclusao          crawepr.dsnivori%TYPE;
  vr_dsnivris                  crawepr.dsnivris%TYPE;
  vr_dsnivori                  crawepr.dsnivori%TYPE;
  vr_inrisco_inclusao_new      tbrisco_operacoes.inrisco_inclusao%TYPE;  
  vr_dsrisco_inclusao_new      crawepr.dsnivori%TYPE;
  vr_dsrisco_operacao_ocr      crawepr.dsnivori%TYPE;
  -- 
  --Traduz Risco (Número para Letra)
  FUNCTION fn_traduz_risco_interna(pr_innivris IN NUMBER) RETURN VARCHAR2 IS 
    vr_dsnivris  VARCHAR2(2);
  BEGIN
    vr_dsnivris := CASE
                     WHEN pr_innivris = 1  THEN 'AA'
                     WHEN pr_innivris = 2  THEN 'A'
                     WHEN pr_innivris = 3  THEN 'B'
                     WHEN pr_innivris = 4  THEN 'C'
                     WHEN pr_innivris = 5  THEN 'D'
                     WHEN pr_innivris = 6  THEN 'E'
                     WHEN pr_innivris = 7  THEN 'F'
                     WHEN pr_innivris = 8  THEN 'G'
                     WHEN pr_innivris = 9  THEN 'H'
                     WHEN pr_innivris = 10 THEN 'HH'
                     ELSE ''
                   END;
    RETURN (vr_dsnivris);
  END fn_traduz_risco_interna;    
  --
BEGIN
  --Imprime Mensagem de Início de Execução
  dbms_output.put_line('Início Execução: '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));
  
  --Para cada Contrato Renegociado
  FOR rw_renegociados IN cr_renegociados LOOP
    --Inicializa/Limpa Variável
    vr_tem_dif_risco        := 'N';
    vr_tem_dif_proposta     := 'N';
    vr_tem_ocr              := 'N';
    vr_inrisco_rating       := NULL;
    vr_inrisco_inclusao     := NULL;
    vr_inrisco_melhora      := NULL;      
    vr_dsrisco_melhora      := NULL;
    vr_dsrisco_rating       := NULL;
    vr_dsrisco_inclusao     := NULL;
    vr_dsnivris             := NULL;
    vr_dsnivori             := NULL;
      
    --Incrementa Qtde de Registros Lidos
    vr_qt_reg_lido := Nvl(vr_qt_reg_lido,0) + 1;
    --
    --Busca Risco Inclusão Atual na Risco Operações
    BEGIN
      SELECT Nvl(tbro.inrisco_rating_autom,tbro.inrisco_rating)  inrisco_rating
            ,tbro.inrisco_inclusao
            ,tbro.inrisco_melhora                       
      INTO   vr_inrisco_rating
            ,vr_inrisco_inclusao
            ,vr_inrisco_melhora          
      FROM   tbrisco_operacoes  tbro
      WHERE  tbro.cdcooper = rw_renegociados.cdcooper
      AND    tbro.nrdconta = rw_renegociados.nrdconta
      AND    tbro.nrctremp = rw_renegociados.nrctremp
      AND    tbro.tpctrato = vr_tpctrato;   
    EXCEPTION
      WHEN OTHERS THEN
        vr_ds_erro := 'Erro ao Buscar Risco Inclusão na Risco Operações. Cooper: '||rw_renegociados.cdcooper||' | Conta: '||rw_renegociados.nrdconta||' | Contrato: '||rw_renegociados.nrctremp||' | Tipo: '||vr_tpctrato||'. Erro: '||SubStr(SQLERRM,1,255);      
        RAISE vr_erro;
    END;
    
    -- Traduz Riscos para Mostrar nas Mensagens
    vr_dsrisco_melhora  := fn_traduz_risco_interna(vr_inrisco_melhora);
    vr_dsrisco_rating   := fn_traduz_risco_interna(vr_inrisco_rating);
    vr_dsrisco_inclusao := fn_traduz_risco_interna(vr_inrisco_inclusao);
      
    --Busca Risco Inclusão Atual na Proposta
    BEGIN
      SELECT Replace(t.dsnivris,' ',NULL)  dsnivris          
            ,Replace(t.dsnivori,' ',NULL)  dsnivori     
      INTO   vr_dsnivris
            ,vr_dsnivori    
      FROM   crawepr  t             
      WHERE  t.cdcooper = rw_renegociados.cdcooper
      AND    t.nrdconta = rw_renegociados.nrdconta
      AND    t.nrctremp = rw_renegociados.nrctremp;
    EXCEPTION
      WHEN OTHERS THEN
        vr_ds_erro := 'Erro ao Buscar Risco Inclusão na Proposta. Cooper: '||rw_renegociados.cdcooper||' | Conta: '||rw_renegociados.nrdconta||' | Contrato: '||rw_renegociados.nrctremp||'. Erro: '||SubStr(SQLERRM,1,255);      
        RAISE vr_erro;
    END;
    --          
    --Busca Dados Central OCR antes da Renegociação
    FOR rw_ocr_antes_reneg IN cr_ocr_antes_reneg(pr_cdcooper => rw_renegociados.cdcooper
                                                ,pr_nrdconta => rw_renegociados.nrdconta
                                                ,pr_nrctremp => rw_renegociados.nrctremp) LOOP
      --Indica que achou OCR antes da Renegociação                                                
      vr_tem_ocr := 'S';
                                                      
      --Limpa Variáveis
      vr_inrisco_inclusao_new := NULL;    
      vr_dsrisco_inclusao_new := NULL;     
      vr_dsrisco_operacao_ocr := NULL;                                       
                                                           
      --O Novo Risco Inclusão é o Pior Risco entre o Risco Operação antes da Renegociação e o Risco Rating Atual        
      vr_inrisco_inclusao_new := GREATEST(Nvl(rw_ocr_antes_reneg.inrisco_operacao,2),Nvl(vr_inrisco_rating,2));
      --Traduz Novo Risco Inclusão 
      vr_dsrisco_inclusao_new := Nvl(fn_traduz_risco_interna(Nvl(vr_inrisco_inclusao_new,2)),'A');
      
      --Não pode haver Risco Inclusão Novo Sem Valor
      IF vr_inrisco_inclusao_new IS NULL THEN
        vr_ds_erro := 'Não foi possível Calcular Novo Risco Inclusão. Cooper: '||rw_ocr_antes_reneg.cdcooper||' | Conta: '||rw_ocr_antes_reneg.nrdconta||' | Contrato: '||rw_ocr_antes_reneg.nrctremp||'.';
        RAISE vr_erro;
      END IF;
               
      --Se o Novo Risco Inclusão Calculado é diferente do Risco Inclusão Atual (da Risco Operações)
      IF Nvl(vr_inrisco_inclusao_new,2) <> Nvl(vr_inrisco_inclusao,2) THEN
        --Indica que diferença no Novo Risco Inclusão para o Autal Risco Inclusão na Risco Operações
        vr_tem_dif_risco := 'S';
        --
        --Atualizar o Risco Inclusão na Risco Operações
        BEGIN
          UPDATE tbrisco_operacoes  t
          SET    t.inrisco_inclusao = Nvl(vr_inrisco_inclusao_new,2)
          WHERE  t.cdcooper         = rw_ocr_antes_reneg.cdcooper
          AND    t.nrdconta         = rw_ocr_antes_reneg.nrdconta
          AND    t.nrctremp         = rw_ocr_antes_reneg.nrctremp
          AND    t.tpctrato         = vr_tpctrato;        
        EXCEPTION
          WHEN OTHERS THEN                       
            vr_ds_erro := 'Erro ao Atualizar Risco Inclusão na Risco Operações. Cooper: '||rw_ocr_antes_reneg.cdcooper||' | Conta: '||rw_ocr_antes_reneg.nrdconta||' | Contrato: '||rw_ocr_antes_reneg.nrctremp||' | Tipo: '||vr_tpctrato||'. Erro: '||SubStr(SQLERRM,1,255);      
            RAISE vr_erro;
        END;
        --Incrementa Qtde de Registros Atualizados na tabela de Risco Operações
        IF SQL%ROWCOUNT > 0 THEN 
          vr_qt_reg_alterado_risco := Nvl(vr_qt_reg_alterado_risco,0) + SQL%ROWCOUNT; 
        END IF;
        --
      END IF; --Se o Novo Risco Inclusão Calculado é diferente do Risco Inclusão Atual (da Risco Operações)
       
      --Se o Novo Risco Inclusão Calculado é diferente do Risco Inclusão Atual (da Proposta) 
      IF Nvl(vr_dsrisco_inclusao_new,'A') <> Nvl(vr_dsnivori,'A') THEN
        --Indica que diferença no Novo Risco Inclusão para o Autal Risco Inclusão na Proposta
        vr_tem_dif_proposta := 'S';
        --
        --Atualizar o Risco Inclusão na Risco Operações
        BEGIN
          UPDATE crawepr  t
          SET    t.dsnivris = Nvl(vr_dsrisco_inclusao_new,'A')
                ,t.dsnivori = Nvl(vr_dsrisco_inclusao_new,'A')
          WHERE  t.cdcooper = rw_ocr_antes_reneg.cdcooper
          AND    t.nrdconta = rw_ocr_antes_reneg.nrdconta
          AND    t.nrctremp = rw_ocr_antes_reneg.nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_ds_erro := 'Erro ao Atualizar Risco Inclusão na Proposta. Cooper: '||rw_ocr_antes_reneg.cdcooper||' | Conta: '||rw_ocr_antes_reneg.nrdconta||' | Contrato: '||rw_ocr_antes_reneg.nrctremp||'. Erro: '||SubStr(SQLERRM,1,255);      
            RAISE vr_erro;
        END;
        --Incrementa Qtde de Registros Atualizados na tabela de Proposta
        IF SQL%ROWCOUNT > 0 THEN 
          vr_qt_reg_alterado_proposta := Nvl(vr_qt_reg_alterado_proposta,0) + SQL%ROWCOUNT; 
        END IF;
        --
      END IF; --Se o Novo Risco Inclusão Calculado é diferente do Risco Inclusão Atual (da Proposta) 
      --
      --Se tem Diferença
      IF Nvl(vr_tem_dif_risco,'N') = 'S' OR Nvl(vr_tem_dif_proposta,'N') = 'S' THEN
        --Incrementa Qtde de Registros Diferentes
        vr_qt_reg_diferente := Nvl(vr_qt_reg_diferente,0) + 1;
            
        --Traduz Risco Operação da Central OCR
        vr_dsrisco_operacao_ocr := fn_traduz_risco_interna(rw_ocr_antes_reneg.inrisco_operacao);
            
        --Lista Dados do Contrato
        /*
        IF Nvl(vr_qt_reg_diferente,0) = 1 AND Nvl(vr_qt_reg_nao_achou_ocr,0) = 0 THEN 
          dbms_output.put_line(' ');       
          dbms_output.put_line('Tipo;Cooperativa;Conta;Contrato;Contrato TR;Data Contrato Renegociado;Data Referencia Central OCR;Risco Melhora;Risco Rating;Risco Operacao Antes Renegociacao;Risco Inclusao Risco Operacoes;Risco Inclusao Proposta/Contrato;Novo Risco Inclusao');                
        END IF;  
        
        dbms_output.put_line('Diferente'||';'||                                       --Tipo de Registro
                             rw_renegociados.cdcooper||';'||                          --Cooperativa
                             rw_renegociados.nrdconta||';'||                          --Conta
                             rw_renegociados.nrctremp||';'||                          --Contrato
                             rw_ocr_antes_reneg.nrctrotr||';'||                       --Contrato TR
                             To_Char(rw_renegociados.dtmvtolt,'dd/mm/yyyy')||';'||    --Data Contrato Renegociado
                             To_Char(rw_ocr_antes_reneg.dtrefere,'dd/mm/yyyy')||';'|| --Data Referencia Central OCR                                  
                             Nvl(vr_dsrisco_melhora,'NAO_TEM')||';'||                 --Risco Melhora da Risco Operações
                             Nvl(vr_dsrisco_rating,'A')||';'||                        --Risco Rating da Risco Operações
                             Nvl(vr_dsrisco_operacao_ocr,'A')||';'||                  --Risco Operação da Central OCR Antes da Renegociação--Na Central OCR se for Nulo (' ') então leva "A" 
                             Nvl(vr_dsrisco_inclusao,'A')||';'||                      --Risco Inclusão da Risco Operações
                             Nvl(vr_dsnivori,'A')||';'||                              --Risco Inclusão da Proposta --Na Central OCR se for Nulo (' ') então leva "A" 
                             Nvl(vr_dsrisco_inclusao_new,'A'));                       --Novo Risco Inclusão Calculado
        */
      ELSE
        --Incrementa Qtde de Registros Iguais
        vr_qt_reg_igual := Nvl(vr_qt_reg_igual,0) + 1;   
      END IF; --Se tem Diferença 
      --
    END LOOP; --Central OCR
    --
    --Se não achou OCR antes da Renegociação
    IF Nvl(vr_tem_ocr,'N') = 'N' THEN 
      --Incrementa Qtde de Registros que não foi encontrado OCR antes da Renegociação
      vr_qt_reg_nao_achou_ocr := Nvl(vr_qt_reg_nao_achou_ocr,0) + 1;
            
      --Lista Dados do Contrato
      /*
      IF Nvl(vr_qt_reg_nao_achou_ocr,0) = 1 AND Nvl(vr_qt_reg_diferente,0) = 0 THEN 
        dbms_output.put_line(' ');       
        dbms_output.put_line('Tipo;Cooperativa;Conta;Contrato;Contrato TR;Data Contrato Renegociado;Data Referencia Central OCR;Risco Melhora;Risco Rating;Risco Operacao Antes Renegociacao;Risco Inclusao Risco Operacoes;Risco Inclusao Proposta/Contrato;Novo Risco Inclusao');                
      END IF; 
      dbms_output.put_line('Sem Central OCR'||';'||                              --Tipo de Registro
                           rw_renegociados.cdcooper||';'||                       --Cooperativa
                           rw_renegociados.nrdconta||';'||                       --Conta
                           rw_renegociados.nrctremp||';'||                       --Contrato
                           rw_renegociados.nrctrotr||';'||                       --Contrato TR
                           To_Char(rw_renegociados.dtmvtolt,'dd/mm/yyyy')||';'|| --Data Contrato Renegociado
                           NULL||';'||                                           --Data Referencia Central OCR                                  
                           Nvl(vr_dsrisco_melhora,'NAO_TEM')||';'||              --Risco Melhora da Risco Operações
                           Nvl(vr_dsrisco_rating,'A')||';'||                     --Risco Rating da Risco Operações
                           NULL||';'||                                           --Risco Operação da Central OCR Antes da Renegociação--Na Central OCR se for Nulo (' ') então leva "A" 
                           Nvl(vr_dsrisco_inclusao,'A')||';'||                   --Risco Inclusão da Risco Operações
                           Nvl(vr_dsnivori,'A')||';'||                           --Risco Inclusão da Proposta --Na Central OCR se for Nulo (' ') então leva "A" 
                           NULL);                                                --Novo Risco Inclusão Calculado
      */
    END IF; --Se não achou OCR antes da Renegociação
    --
  END LOOP; --Contratos Renegociados
  
  --Imprime Mensagens de Qtdes
  dbms_output.put_line(' ');
  dbms_output.put_line(Lpad(vr_qt_reg_lido,6,0)             ||' Registro(s) Lido(s)');
  dbms_output.put_line(Lpad(vr_qt_reg_igual,6,0)            ||' Registro(s) com Risco Inclusão Igual(is)');
  dbms_output.put_line(Lpad(vr_qt_reg_diferente,6,0)        ||' Registro(s) com Risco Inclusão Diferente(s)');  
  dbms_output.put_line(Lpad(vr_qt_reg_nao_achou_ocr,6,0)    ||' Registro(s) Não Encontrado OCR Antes da Renegociação');
  dbms_output.put_line(' ');  
  dbms_output.put_line(Lpad(vr_qt_reg_alterado_risco,6,0)   ||' Registro(s) Alterado(s) na Risco Operações');
  dbms_output.put_line(Lpad(vr_qt_reg_alterado_proposta,6,0)||' Registro(s) Alterado(s) na Proposta');  
  
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
    dbms_output.put_line('Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));
    ROLLBACK;
    Raise_application_error(-20001,'Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255)); 
END;
/
