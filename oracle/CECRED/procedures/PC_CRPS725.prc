CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS725(pr_dscritic OUT VARCHAR2) IS
  /* .............................................................................

     Programa: pc_crps725
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Renato Darosci
     Data    : Agosto/2017                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Executado via Job
     Objetivo  : Realizar a importacao das cargas de limites de cartao de credito 
                 calculados pelos SAS, para atualizacao no Ayllos e Bancoob.

     Alteracoes: 

  ............................................................................ */
  
  ---------------------------- VARIAVEIS -----------------------------------

  -- C�digo do programa
  vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS725';
  vr_nomdojob     CONSTANT VARCHAR2(100) := 'jbcrd_bancoob_envia_solcc';
  -- Refere-se � carga de majora��o de limite do cart�o de cr�dito Bancoob
  vr_skprocess    CONSTANT NUMBER := 119; 

  -- Tratamento de erros
  vr_exc_saida    EXCEPTION;
  vr_dscritic     VARCHAR2(4000);
  vr_vlmaxaumento NUMBER;
  vr_flgerlog     BOOLEAN := TRUE;
  vr_qtdregok     NUMBER := 0; -- Contador de registros processados com sucesso
  vr_qtregerr     NUMBER := 0; -- Contador de registros processados com erro

  ------------------------------- CURSORES ---------------------------------
  -- Buscar os controles de cargas do BI, identificando as cargas prontas para importa��o
  CURSOR cr_controlecarga IS
    SELECT ctr.skcarga
         , ROWID        dsdrowid
      FROM INTEGRADADOS.dw_fatocontrolecarga@SASP ctr
     WHERE ctr.skprocesso               = vr_skprocess
       AND ctr.qtregistroprocessado     > 0
       AND nvl(ctr.qtregistrook,0)      = 0
       AND nvl(ctr.qtregistroatencao,0) = 0
       AND nvl(ctr.qtregistroerro,0)    = 0
       AND ctr.dthorafiminclusao IS NOT NULL;
       
  -- Buscar todos os registros de majora��o a serem processados
  CURSOR cr_majoracao(pr_skcarga  IN NUMBER) IS
    SELECT maj.*
         , ROWID    dsdrowid
      FROM INTEGRADADOS.sasf_majoracaocartao@SASP maj
     WHERE maj.skcarga    = pr_skcarga
       AND maj.cdmajorado = 0; -- N�o processado 

  -- Cursor para validar a cooperativa do registro
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop   cr_crapcop%ROWTYPE;
  
  -- Cursor para vallidar o associado
  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.nmprimtl
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass  cr_crapass%ROWTYPE;
  
  -- Cursor para validar se a conta cart�o existe
  CURSOR cr_ctacard(pr_cdcooper   tbcrd_conta_cartao.cdcooper%TYPE
                   ,pr_nrdconta   tbcrd_conta_cartao.nrdconta%TYPE
                   ,pr_nrctacrd   tbcrd_conta_cartao.nrconta_cartao%TYPE) IS
    SELECT 1
      FROM tbcrd_conta_cartao  ccr
     WHERE ccr.cdcooper       = pr_cdcooper
       AND ccr.nrdconta       = pr_nrdconta
       AND ccr.nrconta_cartao = pr_nrctacrd;
  rw_ctacard   cr_ctacard%ROWTYPE;
  
  -- Cursor para buscar o valor do limite da conta cart�o atual e o tipo do cart�o
  CURSOR cr_crawcrd(pr_cdcooper  crawcrd.cdcooper%TYPE
                   ,pr_nrdconta  crawcrd.nrdconta%TYPE
                   ,pr_nrctacrd  crawcrd.nrcctitg%TYPE) IS
    SELECT DISTINCT crd.vllimcrd
         , crd.cdadmcrd
      FROM crawcrd crd
     WHERE crd.cdcooper = pr_cdcooper
       AND crd.nrdconta = pr_nrdconta
       AND crd.nrcctitg = pr_nrctacrd
       AND crd.cdadmcrd BETWEEN 10 AND 80 -- Bancoob 
       AND crd.insitcrd = 4               -- Em Uso 
     ORDER BY vllimcrd DESC
            , cdadmcrd DESC;
  rw_crawcrd   cr_crawcrd%ROWTYPE;
  
  -- Cursor para verificar se o limite para atualiza��o est� habilitado para o tipo do cart�o. 
  CURSOR cr_craptlc(pr_cdcooper   craptlc.cdcooper%TYPE 
                   ,pr_cdadmcrd   craptlc.cdadmcrd%TYPE 
                   ,pr_vllimatu   craptlc.vllimcrd%TYPE ) IS
    SELECT 1 
      FROM craptlc tlc
     WHERE tlc.cdcooper = pr_cdcooper
       AND tlc.cdadmcrd = pr_cdadmcrd
       AND tlc.vllimcrd = pr_vllimatu
       AND tlc.insittab = 0;
  rw_craptlc   cr_craptlc%ROWTYPE;
  
  -- Buscar algum outro processo de majora��o em andamento para o cart�o
  CURSOR cr_maj_penden(pr_cdcooper  NUMBER
                      ,pr_nrdconta  NUMBER
                      ,pr_nrctacrd  NUMBER) IS
    SELECT 1
		  FROM INTEGRADADOS.sasf_majoracaocartao@SASP maj
		 WHERE maj.nrdconta      = pr_nrdconta
		   AND maj.nrcontacartao = pr_nrctacrd
		   AND maj.cdmajorado    = 4 -- Pendente 
     UNION
    SELECT 1
		  from tbcrd_limite_atualiza atu
		 where atu.cdcooper       = pr_cdcooper
		   and atu.nrdconta       = pr_nrdconta
		   and atu.nrconta_cartao = pr_nrctacrd
		   and atu.tpsituacao     IN (1,2); -- Pendente ou Enviado ao Bancoob 
  rw_maj_penden  cr_maj_penden%ROWTYPE;
  
  -------------------------- ROTINAS INTERNAS ------------------------------
  -- Rotina respons�vel pela atualiza��o da data e hora de in�cio do 
  -- processamento do controle de carga
  PROCEDURE pc_atualiza_controlecarga(pr_dsdrowid   IN VARCHAR2
                                     ,pr_idinifim   IN VARCHAR2 -- Indica se est� informando in�cio ou fim(I/F)
                                     ,pr_qtproces   IN NUMBER DEFAULT NULL
                                     ,pr_qtcomerr   IN NUMBER DEFAULT NULL
                                     ,pr_dscritic  OUT VARCHAR2) IS
    
    PRAGMA AUTONOMOUS_TRANSACTION;
  
  BEGIN
    
    -- Se estiver indicando inicio de processamento
    IF pr_idinifim = 'I' THEN
    
      -- Atualizar a data e hora de inicio do processamento do controle de carga
      UPDATE INTEGRADADOS.dw_fatocontrolecarga@SASP ctr
         SET ctr.dthorainicioprocesso = SYSDATE
       WHERE ROWID = pr_dsdrowid;
    
    ELSIF pr_idinifim = 'F' THEN
    
      -- Atualizar a data e hora de fim do processamento do controle de carga
      UPDATE INTEGRADADOS.dw_fatocontrolecarga@SASP ctr
         SET ctr.dthorafimprocesso = SYSDATE
           , ctr.qtregistrook      = pr_qtproces
           , ctr.qtregistroerro    = pr_qtcomerr
       WHERE ROWID = pr_dsdrowid;
    
    END IF;
    
    -- Comitar sess�o pragma (obrigat�rio)
    COMMIT;
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na PC_ATUALIZA_CONTROLECARGA: '||SQLERRM;
      ROLLBACK;
  END pc_atualiza_controlecarga;
  
  
BEGIN
  
  -- Incluir nome do m�dulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                            ,pr_action => null);
  
  /* -------------
    Devemos finalizar os registros que por algum motivo, ficaram pendentes e n�o 
    tiveram retorno. Necess�rio para que uma conta n�o fique bloqueada para 
    majora��o, devido a algum erro de processamento nosso ou do Bancoob. Vamos 
    considerar que os registros ser�o expirados ap�s 15 dias sem retorno.
  ------------- */
  BEGIN
    UPDATE tbcrd_limite_atualiza atu
	     SET tpsituacao = 5    -- Expirado 
	   WHERE atu.dtalteracao < TRUNC(SYSDATE - 15)
	     AND atu.tpsituacao IN (1,2); -- Pendente ou Enviado ao Bancoob
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro alterar registro expirados na TBCRD_LIMITE_ATUALIZA: '||SQLERRM;
      RAISE vr_exc_saida;
  END;
  
  BEGIN
	  UPDATE INTEGRADADOS.sasf_majoracaocartao@SASP maj
	     SET maj.cdmajorado = 3   -- Erro
	       , maj.dsexclusao = 'Registro expirado'
	   WHERE maj.dtbase     < TRUNC(SYSDATE - 15)
	     AND maj.cdmajorado = 4; -- Pendente
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro alterar registro expirados na majora��o: '||SQLERRM;
      RAISE vr_exc_saida;
  END;
  /* ------------- */
  
  -- Buscar o valor do parametro de diferen�a m�xima de limite
  vr_vlmaxaumento := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdacesso => 'VLR_MAX_AUMENTO_LIMITE');
                                                    
  -- Percorrer todos os controles de cargas prontas para importa��o
  FOR rw_controle IN cr_controlecarga LOOP
    -- Rotina para atualizar a data e hora de in�cio do processamento
    pc_atualiza_controlecarga(pr_dsdrowid => rw_controle.dsdrowid
                             ,pr_idinifim => 'I' -- in�cio
                             ,pr_dscritic => pr_dscritic);
                        
    -- Se ocorrer retorno de erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
    -- Limpar os contadores a cada controle de carga processado
    vr_qtdregok := 0;
    vr_qtregerr := 0;
    
    -- Percorrer os registros de majora��o n�o processados
    FOR rw_majoracao IN cr_majoracao(rw_controle.skcarga) LOOP
      -- Bloco para tratar erros no processamento 
      DECLARE 
        vr_expmajoracao    EXCEPTION;
      BEGIN
        ------------------------------------------------
        
        -- VERIFICAR SE A COOPERATIVA EXISTE NA CRAPCOP. 
        OPEN  cr_crapcop(rw_majoracao.cdcooper);
        FETCH cr_crapcop INTO rw_crapcop;
        -- Se n�o encontrar a cooperativa
        IF cr_crapcop%NOTFOUND THEN
          -- Fechar o cursor 
          CLOSE cr_crapcop;
          
          vr_dscritic := 'Cooperativa inexistente!';
          RAISE vr_expmajoracao;
        END IF;
        
        -- Fechar o cursor 
        CLOSE cr_crapcop;
        
        ------------------------------------------------
        
        -- VERIFICAR SE A CONTA EXISTE NA CRAPASS
        OPEN  cr_crapass(rw_majoracao.cdcooper
                        ,rw_majoracao.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        -- Se n�o encontrar o associado
        IF cr_crapass%NOTFOUND THEN
          -- Fechar o cursor 
          CLOSE cr_crapass;
          
          vr_dscritic := 'Associado inexistente!';
          RAISE vr_expmajoracao;
        END IF;
        
        -- Fechar o cursor
        CLOSE cr_crapass;
        
        ------------------------------------------------
          
        -- VERIFICAR SE A CONTA CART�O EXISTE
        OPEN  cr_ctacard(rw_majoracao.cdcooper
                        ,rw_majoracao.nrdconta
                        ,rw_majoracao.nrcontacartao);
        FETCH cr_ctacard INTO rw_ctacard;
        -- Se n�o encontrar o associado
        IF cr_ctacard%NOTFOUND THEN
          -- Fechar o cursor 
          CLOSE cr_ctacard;
          
          vr_dscritic := 'Conta cart�o inexistente!';
          RAISE vr_expmajoracao;
        END IF;
        
        -- Fechar o cursor
        CLOSE cr_ctacard;
        
        ------------------------------------------------
        
        -- Verificar se o valor de limite para atualiza��o menor ou igual a zero. 
        IF NVL(rw_majoracao.vllimite,0) <= 0 THEN
          vr_dscritic := 'Valor de atualiza��o para o limite dever� ser superior a zero!';
          RAISE vr_expmajoracao;
        END IF;
        
        ------------------------------------------------
        
        -- Buscar o valor do limite da conta cart�o atual e o tipo do cart�o 
        OPEN  cr_crawcrd(rw_majoracao.cdcooper
                        ,rw_majoracao.nrdconta
                        ,rw_majoracao.nrcontacartao);
        FETCH cr_crawcrd INTO rw_crawcrd;
        -- Se n�o encontrar registro
        IF cr_crawcrd%NOTFOUND THEN
          -- Fechar o cursor 
          CLOSE cr_crawcrd;
          
          vr_dscritic := 'N�o existe cart�o "Em uso" para a Conta Cart�o!';
          RAISE vr_expmajoracao;
        END IF;
        
        -- Fechar o cursor 
        CLOSE cr_crawcrd;
        
        ------------------------------------------------
        
        -- Validar se o limite para atualiza��o est� habilitado para o tipo do cart�o. 
        OPEN  cr_craptlc(rw_majoracao.cdcooper    -- pr_cdcooper
                        ,rw_crawcrd.cdadmcrd      -- pr_cdadmcrd
                        ,rw_majoracao.vllimite);  -- pr_vllimatu
        FETCH cr_craptlc INTO rw_craptlc;
        -- Verificar se existe registro 
        IF cr_craptlc%NOTFOUND THEN
          -- Fechar o cursor 
          CLOSE cr_craptlc;
          
          vr_dscritic := 'Valor do limite solicitado n�o existe para o tipo de cart�o '||rw_crawcrd.cdadmcrd||' na tela LIMCRD!';
          RAISE vr_expmajoracao;
        END IF;
   
        -- Fechar o cursor 
        CLOSE cr_craptlc;
        
        ------------------------------------------------
        
        -- Verificar se a diferen�a de altera��o de limite ultrapassa o valor parametrizado
        IF (rw_majoracao.vllimite - rw_crawcrd.vllimcrd) > vr_vlmaxaumento THEN
          vr_dscritic := 'Solicita��o de aumento de limite inv�lida, valor solicitado ultrapassa '||
                         'valor m�ximo permitido de '||to_char(vr_vlmaxaumento,'FM999G990D00')||'!';
                         
          RAISE vr_expmajoracao;
        END IF;
          
        ------------------------------------------------
          
        -- Verificar se o novo valor de limite � menor ou igual ao valor anterior
        IF (rw_majoracao.vllimite <= rw_crawcrd.vllimcrd) THEN
          vr_dscritic := 'Novo valor de limite deve ser superior ao valor '||
                         'atual ('||to_char(rw_crawcrd.vllimcrd,'FM999G990D00')||')!';
          RAISE vr_expmajoracao;
        END IF;
        
        ------------------------------------------------
        
        -- Validar para que n�o exista nenhum processo de majora��o pendente na tabela do SAS e no Ayllos
        OPEN  cr_maj_penden(rw_majoracao.cdcooper         -- pr_cdcooper
                           ,rw_majoracao.nrdconta         -- pr_nrdconta
                           ,rw_majoracao.nrcontacartao);  -- pr_nrctacrd
        FETCH cr_maj_penden INTO rw_maj_penden;
        -- Se encontrar registros
        IF cr_maj_penden%FOUND THEN
          -- Fechar o cursor 
          CLOSE cr_maj_penden;
          
          vr_dscritic := 'J� existe processo de majora��o pendente para esta conta cart�o!';
          RAISE vr_expmajoracao;
        END IF;
        
        -- Fechar o cursor
        CLOSE cr_maj_penden;
        
        ------------------------------------------------
		    
      EXCEPTION
        WHEN vr_expmajoracao THEN
          -- Se ocorrer erro na majora��o deve atualizar o registro
          BEGIN
            UPDATE INTEGRADADOS.sasf_majoracaocartao@SASP maj
               SET maj.cdmajorado = 3 -- Erro
                 , maj.dsexclusao = vr_dscritic
             WHERE ROWID = rw_majoracao.dsdrowid;
             
            -- INCREMENTAR O CONTADOR DE REGISTROS PROCESSADOS COM ERRO
            vr_qtregerr := vr_qtregerr + 1; 
             
            -- Pular para o pr�ximo registro a ser processado
            CONTINUE;
             
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro ao incluir critica de majora��o['||rw_majoracao.dsdrowid||']: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao processar majora��o: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      /* AP�S CONCLUIR TODAS AS VALIDA��ES, PROCESSA O REGISTRO */
      BEGIN
        -- Incluir o registro na tabela de atualiza��o de limite
        INSERT INTO tbcrd_limite_atualiza
                      (cdcooper
                      ,nrdconta
                      ,nrconta_cartao
                      ,dtalteracao
                      ,dtretorno
                      ,tpsituacao
                      ,vllimite_anterior
                      ,vllimite_alterado
                      ,cdcanal
                      ,cdcribcb)
                VALUES(rw_majoracao.cdcooper       -- cdcooper
                      ,rw_majoracao.nrdconta       -- nrdconta
                      ,rw_majoracao.nrcontacartao  -- nrconta_cartao
                      ,SYSDATE                     -- dtalteracao
                      ,NULL                        -- dtretorno
                      ,1     -- pendente           -- tpsituacao
                      ,rw_crawcrd.vllimcrd         -- vllimite_anterior
                      ,rw_majoracao.vllimite       -- vllimite_alterado
                      ,14    -- SAS                -- cdcanal
                      ,NULL);                      -- cdcribcb
        
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao incluir TBCRD_LIMITE_ATUALIZA: '||SQLERRM;  
        
          -- Neste caso deve gerar log e passar para o pr�ximo registro
          BTCH0001.pc_log_exec_job(pr_cdcooper  => 3    --> Cooperativa
                                  ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                                  ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                                  ,pr_dstiplog  => 'E'    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                                  ,pr_dscritic  => vr_dscritic    --> Critica a ser apresentada em caso de erro
                                  ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
          
          -- INCREMENTAR O CONTADOR DE REGISTROS PROCESSADOS COM ERRO
          vr_qtregerr := vr_qtregerr + 1;
          
          -- Passar para o pr�ximo registro
          CONTINUE;
      END;

      -- Atualizar o registro de majora��o
      BEGIN
        
        UPDATE INTEGRADADOS.sasf_majoracaocartao@SASP maj
           SET maj.cdmajorado = 4  -- Pendente
         WHERE ROWID = rw_majoracao.dsdrowid;
         
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar majora��o['||rw_majoracao.dsdrowid||']: '||SQLERRM;
        
          -- Neste caso deve gerar log e passar para o pr�ximo registro
          BTCH0001.pc_log_exec_job(pr_cdcooper  => 3    --> Cooperativa
                                  ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                                  ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                                  ,pr_dstiplog  => 'E'    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                                  ,pr_dscritic  => vr_dscritic    --> Critica a ser apresentada em caso de erro
                                  ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
          
          -- INCREMENTAR O CONTADOR DE REGISTROS PROCESSADOS COM ERRO
          vr_qtregerr := vr_qtregerr + 1;
          
          -- Passar para o pr�ximo registro
          CONTINUE;
      END;
      
      
      -- INCREMENTAR O CONTADOR DE REGISTROS PROCESSADOS COM SUCESSO
      vr_qtdregok := vr_qtdregok + 1;
    
    END LOOP; -- cr_majoracao
    
    -- Rotina para atualizar a data e hora de fim do processamento, bem como as quantidades de registros processadas
    pc_atualiza_controlecarga(pr_dsdrowid => rw_controle.dsdrowid
                             ,pr_idinifim => 'F' -- in�cio
                             ,pr_qtproces => vr_qtdregok
                             ,pr_qtcomerr => vr_qtregerr
                             ,pr_dscritic => pr_dscritic);
                        
    -- Se ocorrer retorno de erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
                   
  END LOOP; -- cr_controlecarga
  
  -- comitar os dados processados
  COMMIT;
  
EXCEPTION  
  WHEN vr_exc_saida THEN
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro n�o tratado
    pr_dscritic := 'Erro ao executar PC_CRPS725: '||SQLERRM;
                                          
    -- Efetuar rollback
    ROLLBACK;
END PC_CRPS725;
/
