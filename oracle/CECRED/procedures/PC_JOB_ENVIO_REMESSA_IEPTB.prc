CREATE OR REPLACE PROCEDURE CECRED.PC_JOB_ENVIO_REMESSA_IEPTB IS

  /* ..........................................................................

   JOB: PC_JOB_ENVIO_REMESSA_IEPTB
   Sistema : Conta-Corrente - Cooperativa de Credito
   Autor   : Supero
   Data    : Junho/2018.                     Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Diário.
   Objetivo  : Irá controlar a criação dos JOBs individuais para cada cooperativa, que tratarão de chamar
               a rotina de baixa automática do gravames para os registros de prejuízos que foram pagos.

   Alteracoes: 27/06/2018 - Criação da rotina pela Supero

  ..........................................................................*/
	  CURSOR cr_data(pr_cdcooper tbcobran_param_protesto.cdcooper%TYPE) IS
		  SELECT TO_TIMESTAMP(TO_CHAR((SYSDATE),'DD/MM/RRRR')||' '||TO_CHAR(TO_DATE(prm.hrenvio_arquivo,'SSSSS'),'HH24:MI')||':'||TO_CHAR(3,'fm00'), 'DD/MM/RRRR HH24:MI:SS') horario
				FROM tbcobran_param_protesto prm
			 WHERE prm.cdcooper = pr_cdcooper;
		--
		rw_data cr_data%ROWTYPE;
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
    vr_cdprogra    CONSTANT VARCHAR2(40) := 'PC_JOB_ENVIO_REMESSA_IEPTB';
    vr_des_reto    VARCHAR2(1000);
    vr_tab_erro    gene0001.typ_tab_erro;
    vr_cdcritic    PLS_INTEGER;
    vr_dscritic    VARCHAR2(4000);
    vr_dsplsql     VARCHAR2(2000);
    vr_jobname     VARCHAR2(30);
    vr_minuto      TIMESTAMP;
    vr_cdcooper    crapcop.cdcooper%TYPE := 3;

    vr_exc_erro    EXCEPTION;

    -- Variáveis de controle de calendário
    rw_crapdat     BTCH0001.cr_crapdat%ROWTYPE;


    /******************************/
    --> LOG de execucao
    PROCEDURE pc_gera_log_execucao(pr_dsexecut  IN VARCHAR2,
                                   pr_cdcooper  IN INTEGER,
                                   pr_dtmvtolt  IN DATE) IS
      vr_nmarqlog VARCHAR2(500);
      vr_desdolog VARCHAR2(2000);

    BEGIN

      --> Definir nome do log
      vr_nmarqlog := 'remessa_ieptb.log';
      --> Definir descrição do log
      vr_desdolog := 'Automatizado - '||to_char(pr_dtmvtolt,'DD/MM/YYYY')||' - '||to_char(SYSDATE,'HH24:MI:SS')||
                     ' [ENVIO REMESSA IEPTB] - ' || pr_dsexecut;

      -- Gera o Log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 1,
                                 pr_des_log      => vr_desdolog,
                                 pr_nmarqlog     => vr_nmarqlog);

    END pc_gera_log_execucao;
    /******************************/

  BEGIN

  -- Verificação do calendário
  OPEN  BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    CLOSE BTCH0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic:= 1;
    vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

    -- Forma a frase de erro para incluir no log
    vr_dscritic:= 'Erro: '||vr_dscritic;

    RAISE vr_exc_erro;
  ELSE
    -- Apenas fechar o cursor
    CLOSE BTCH0001.cr_crapdat;
  END IF;
	--
	OPEN cr_data(vr_cdcooper);
	--
	FETCH cr_data INTO rw_data;
	--
	IF cr_data%FOUND THEN
		--
		vr_minuto := rw_data.horario;
		--
	ELSE
		--
		CLOSE cr_data;
		vr_dscritic := 'Não foi possível retornar o horário de execução do Job de envio de remessas ao IEPTB: ' || SQLERRM;
		RAISE vr_exc_erro;
		--
	END IF;
	--
	CLOSE cr_data;
  --
	IF (vr_minuto IS NULL) THEN
		vr_dscritic := 'O horário de execução do Job de envio de remessas ao IEPTB não foi configurado.';
		RAISE vr_exc_erro;
	END IF;
  -- Criar o nome para o job
  vr_jobname := 'ENV_REMESSA_IEPTB$';
  vr_dsplsql := 'declare vr_dscritic varchar2(4000); begin cecred.pc_crps729(pr_dscritic => vr_dscritic); if vr_dscritic is not null then raise_application_error(-20001, vr_dscritic); end if; end;';

  -- Faz a chamada ao programa paralelo atraves de JOB
  gene0001.pc_submit_job(pr_cdcooper  => vr_cdcooper      --> Código da cooperativa
              ,pr_cdprogra  => vr_cdprogra          --> Código do programa
              ,pr_dsplsql   => vr_dsplsql           --> Bloco PLSQL a executar
              ,pr_dthrexe   => vr_minuto       --> Incrementar o tempo
              ,pr_jobname   => vr_jobname           --> Nome randomico criado
              ,pr_des_erro  => vr_dscritic);

  IF TRIM(vr_dscritic) is not null THEN
    vr_dscritic := 'Falha na criacao do Job (Coop:'||vr_cdcooper||' Job: '||vr_jobname||'): '|| vr_dscritic;
    RAISE vr_exc_erro;
  END IF;

    -- Efetivar os dados
    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Efetuar rollback
      ROLLBACK;

      -- Log de execução NOK
      pc_gera_log_execucao(pr_dsexecut  => vr_dscritic
                          ,pr_cdcooper  => vr_cdcooper
                          ,pr_dtmvtolt  => TRUNC(SYSDATE));
      raise_application_error(-20001, 'PC_JOB_ENVIO_REMESSA_IEPTB: ' || vr_dscritic);
    WHEN OTHERS THEN
      vr_dscritic := SQLERRM;
      -- Efetuar rollback
      ROLLBACK;


      -- Log de execução NOK
      pc_gera_log_execucao(pr_dsexecut  => 'Erro na PC_JOB_ENVIO_REMESSA_IEPTB: '||vr_dscritic
                          ,pr_cdcooper  => vr_cdcooper
                          ,pr_dtmvtolt  => TRUNC(SYSDATE));
		  raise_application_error(-20002, 'PC_JOB_ENVIO_REMESSA_IEPTB: ' || vr_dscritic);
 END PC_JOB_ENVIO_REMESSA_IEPTB;
/
