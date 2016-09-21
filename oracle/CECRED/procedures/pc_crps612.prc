CREATE OR REPLACE PROCEDURE CECRED.pc_crps612 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                               ) IS

  /* ............................................................................

     Programa: PC_CRPS612                       Antigo: Fontes/crps612.p
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Henrique
     Data    : Outubro/2011                         Ultima alteracao: 22/02/2016

     Dados referentes ao programa:

     Frequencia: Diario
     Objetivo  : Buscar titulos gerados no DDA diariamente e gerar mensagem de
                 chegada.
     Alteracoes:
              19/12/2013 - Conversão Progress >> Oracle PL/SQL ( Renato - Supero)
              
              22/02/2016 - Alterado rotina para retirar programa da cadeia e colocar
                           em job com execução diaria SD388026 (Odirlei-AMcom).

  ............................................................................ */
  -- Código do programa
  vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS612';

  ------------------------------- CURSORES ---------------------------------
  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.nmrescop,
           cop.cdcooper
      FROM crapcop cop
     WHERE cop.cdcooper <> 3
       AND cop.flgativo = 1
       AND(cop.cdcooper = pr_cdcooper OR
           pr_cdcooper = 3)
     ORDER BY cop.cdcooper;
       
  -- Buscar nome do programa      
  CURSOR cr_crapprg IS
    SELECT dsprogra##1
      FROM crapprg
     WHERE cdprogra = vr_cdprogra
       AND dsprogra##1 IS NOT NULL
       AND ROWNUM = 1;     
  rw_crapprg cr_crapprg%ROWTYPE; 
  
  
  ------------------------------- REGISTROS -------------------------------
  rw_crapcop cr_crapcop%ROWTYPE;

  ------------------------------- VARIAVEIS -------------------------------
  
  -- Data de movimento e mês de referencia
  vr_dtmvtolt     DATE;
  vr_dtmvtoan     DATE;
  
  vr_desdolog     VARCHAR2(500);
  vr_tempo        NUMBER;
  vr_cdcooper     crapcop.cdcooper%TYPE;

  -- Rolbacks para erros, ignorar o resto do processo e rollback
  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);

BEGIN

  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra);
  vr_cdcooper := pr_cdcooper;
  
  --> buscar nome do programa
  OPEN cr_crapprg;
  FETCH cr_crapprg INTO rw_crapprg;
  CLOSE cr_crapprg;
  
  -- Buscar os titulos DDA por cooperativa  
  FOR rw_crapcop IN cr_crapcop LOOP
  
    --> Armazenar codigo da cooperativa
    vr_cdcooper := rw_crapcop.cdcooper;
      
    -- Inicializar o tempo
    vr_tempo := to_char(SYSDATE,'SSSSS'); 
    
    -- Gerar log    
    vr_desdolog := to_char(SYSDATE,'HH24:MI:SS')||' - '|| vr_cdprogra ||
                   ' --> Inicio da execucao: '||vr_cdprogra||' - '||lower(rw_crapprg.dsprogra##1);
                   
    btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper, 
                               pr_ind_tipo_log => 1, 
                               pr_des_log      => vr_desdolog);    
                               
    --> Definir datas de filtro, processo será rodado todos os dia,
    -- assim buscará sempre os dados do dia anterior
    vr_dtmvtoan := SYSDATE - 1;
    vr_dtmvtolt := SYSDATE;
    
    -- Chama a rotina para envio de mensagens atraves do site de chegada de novos titulos DDA
    DDDA0001.pc_chegada_titulos_DDA(pr_cdcooper => rw_crapcop.cdcooper
                                   ,pr_cdprogra => vr_cdprogra
                                   ,pr_dtemiini => vr_dtmvtoan
                                   ,pr_dtemifim => vr_dtmvtolt
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);

    -- Se retornar crítica
    IF TRIM(vr_dscritic) IS NOT NULL OR 
       nvl(vr_cdcritic,0) > 0 THEN
      
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
    
      -- Gerar log de critica
      vr_desdolog := to_char(SYSDATE,'HH24:MI:SS')||' - '|| vr_cdprogra ||
                     ' --> ERRO:'||vr_dscritic;
      btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper, 
                                 pr_ind_tipo_log => 2, 
                                 pr_des_log      => vr_desdolog);
      ROLLBACK;
      --> Buscar proxima cooperativa
      continue;
      
    END IF;
    
    --> Criar log de fim de execução
    vr_desdolog := to_char(SYSDATE,'HH24:MI:SS')||' - '|| vr_cdprogra ||
                       ' --> Stored Procedure rodou em '|| 
                       -- calcular tempo de execução
                       to_char(to_date(to_char(SYSDATE,'SSSSS') - vr_tempo,'SSSSS'),'HH24:MI:SS');
                   
    btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper, 
                               pr_ind_tipo_log => 1, 
                               pr_des_log      => vr_desdolog);
    
    -- Commitar as alterações
    COMMIT;
    
  END LOOP;  

  -- Salvar informacoes no banco de dados
  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    
    -- Gerar log de critica
    vr_desdolog := to_char(SYSDATE,'HH24:MI:SS')||' - '|| vr_cdprogra ||
                   ' --> ERRO:'||vr_dscritic;
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper, 
                               pr_ind_tipo_log => 2, 
                               pr_des_log      => vr_desdolog);
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    
    vr_cdcritic := 0;
    vr_dscritic := sqlerrm;
    -- Gerar log de critica
    vr_desdolog := to_char(SYSDATE,'HH24:MI:SS')||' - '|| vr_cdprogra ||
                   ' --> ERRO:'||vr_dscritic;
                   
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper, 
                               pr_ind_tipo_log => 2, 
                               pr_des_log      => vr_desdolog);
    -- Efetuar rollback
    ROLLBACK;
END PC_CRPS612;
/
