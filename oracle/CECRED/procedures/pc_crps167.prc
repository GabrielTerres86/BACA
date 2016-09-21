CREATE OR REPLACE PROCEDURE CECRED.pc_crps167 (pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padr�o para utiliza��o de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Sa�da de termino da execu��o
                                              ,pr_infimsol OUT PLS_INTEGER            --> Sa�da de termino da solicita��o
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada                                              
/* ..........................................................................

   Programa: Fontes/crps167.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Agosto/96.                         Ultima atualizacao: 06/04/2015

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 005.
               Listar a relacao de arquivos de integracao de convenios de debito
               em conta que nao estao disponiveis
               Ordem do programa na solicitacao 10.
               Emite relatrio 132.

   Alteracoes: 20/02/97 - Tratar seguro saude Bradesco (Odair).

               03/06/97 - Ler arquivos de convenios crapcnv (Odair)

               20/06/97 - Alterado para eliminar tratamento do convenio de
                          dentistas (Deborah).

               10/07/97 - Tratar convenio 14 saude bradesco (Odair)

               28/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               25/10/1999 - Alterado para rodar um dia antes do dia do pro-
                            cessamento dos convenios (Deborah).

               03/11/2000 - Eliminar a coluna Empresa e incluir o campo
                            Obrigatorio e Observacao (Eduardo).
                            
               31/05/2002 - Selecionar somente crapcnv.inobriga igual a 1 
                            (Junior).
                            
               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder            
               
               04/01/2008 - Enviar crrl132 por email(Guilherme).
               
               06/04/2015 - Convers�o Progress -> PL/SQL (Carlos)
............................................................................. */

    --====================== VARIAVEIS PRINCIPAIS ========================
    -- C�digo do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS167';

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    --===================== FIM VARIAVEIS PRINCIPAIS =====================

    --======================== CURSORES ==================================
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.cdcooper
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    cr_crapcop_found boolean;
    -- Cursor gen�rico de calend�rio
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;    

	  -- Cursor da tabela gen�rica
		CURSOR cr_craptab (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
		  SELECT tab.dstextab
			  FROM craptab tab
			 WHERE tab.cdcooper = pr_cdcooper
			   AND upper(tab.nmsistem) = 'CRED'
				 AND upper(tab.tptabela) = 'GENERI'
				 AND tab.cdempres = 11
				 AND upper(tab.cdacesso) = 'PROCCONVEN'
				 AND tab.tpregist = 0;
		rw_craptab cr_craptab%ROWTYPE;
    cr_craptab_found boolean;
    
    CURSOR cr_crapcnv (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cnv.nrconven, cnv.dsconven, cnv.tpconven 
        FROM crapcnv cnv 
        WHERE cnv.cdcooper = pr_cdcooper  AND
              cnv.inobriga = 1;
    rw_crapcnv cr_crapcnv%ROWTYPE;
    --========================== FIM CURSORES ==========================
        
    --============================ VARIAVEIS ===========================
    cr_crapdat_found boolean;
    vr_dtultdia        DATE;
    vr_dtddmmaa        VARCHAR(6);    
    vr_nmarquiv        VARCHAR2(25);
    vr_dsemail_dest    VARCHAR2(2000);
    
    -- Vari�vel para armazenar as informa��es em XML    
    vr_clobxml         CLOB;

    vr_caminho         VARCHAR2(100);
    vr_dttabela        DATE;
    vr_auxdttab        DATE;   
    vr_flinirel        boolean DEFAULT FALSE; -- Indica se criou relat�rio
    vr_des_erro        VARCHAR2(4000);
    --========================== FIM VARIAVEIS =============================
    
    --======================= SUBROTINAS INTERNAS ==========================    
    -- Subrotina para escrever texto na vari�vel CLOB do XML     
    PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB -- Subrotina para escrever texto na vari�vel CLOB do XML
                             ,pr_desdados IN VARCHAR2) IS
    BEGIN
      dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
    END;    
    --======================= FIM SUBROTINAS ===============================

  BEGIN

    --================= VALIDACOES INICIAIS ====================
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    cr_crapcop_found := cr_crapcop%FOUND;
    CLOSE cr_crapcop;
    -- Se n�o encontrar
    IF NOT cr_crapcop_found THEN
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    END IF;

    -- Leitura do calend�rio da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    cr_crapdat_found := btch0001.cr_crapdat%FOUND;
    CLOSE btch0001.cr_crapdat;
    -- Se n�o encontrar
    IF NOT cr_crapdat_found THEN
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    END IF;

    -- Valida��es iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro � <> 0
    IF vr_cdcritic <> 0 THEN
      RAISE vr_exc_saida;
    END IF;
    --================= FIM VALIDACOES INICIAIS ==================
    
    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
    
    vr_dtultdia := TO_DATE('28' || TO_CHAR(rw_crapdat.dtmvtolt ,'mm') || TO_CHAR(rw_crapdat.dtmvtolt ,'RRRR'), 'ddmmRRRR') + 4;
    vr_dtultdia := vr_dtultdia - TO_NUMBER(TO_CHAR(vr_dtultdia,'dd'));
    vr_dtddmmaa := TO_CHAR(vr_dtultdia,'ddmmRR');

    -- Verifica se o registro PROCCONVEN da tab gen�rica existe
    OPEN cr_craptab(pr_cdcooper);
    FETCH cr_craptab INTO rw_craptab;
    cr_craptab_found := cr_craptab%FOUND;
    CLOSE cr_craptab;
    IF NOT cr_craptab_found THEN
      vr_cdcritic := 566;      
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic || 
                                                 ' CREDI-GENERI-11-PROCCONVEN-0');
      vr_cdcritic := 0;
      vr_dscritic := NULL;
      RAISE vr_exc_saida;
    END IF;

    vr_dttabela := TO_DATE(SUBSTR(rw_craptab.dstextab,4,2) || 
                           SUBSTR(rw_craptab.dstextab,1,2) || 
                           SUBSTR(rw_craptab.dstextab,7,4), 'mmddRRRR');

    /* Retorna a data imediatamente anterior que n�o � final de semana ou feriado, 
    considerando o ultimo dia do mes como data eleg�vel */
    vr_dttabela := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                               pr_dtmvtolt => vr_dttabela - 1,
                                               pr_tipo     => 'A',
                                               pr_feriado  => TRUE,
                                               pr_excultdia=> TRUE);
                                                 
    IF vr_dttabela <= rw_crapdat.dtmvtopr AND SUBSTR(rw_craptab.dstextab,12,1) = '0' THEN

        --Buscar Diretorio padrao Relatorios para a cooperativa
        vr_caminho := lower(gene0001.fn_diretorio(pr_tpdireto => 'C'
                                                 ,pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsubdir => 'rl'));
        --Se nao encontrou
        IF vr_caminho IS NULL THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Diretorio padr�o da cooperativa n�o encontrado!';
            --Levantar Excecao
            RAISE vr_exc_saida;
        END IF;

        OPEN cr_crapcnv(pr_cdcooper);
        LOOP FETCH cr_crapcnv INTO rw_crapcnv;
        -- Sai quando nao houver mais convenios
            EXIT WHEN cr_crapcnv%notfound;

            vr_nmarquiv := 'convenios/' || vr_dtddmmaa || '.' || SUBSTR(LPAD(TO_CHAR(rw_crapcnv.nrconven),6,'0'), 4,3);

            IF NOT gene0001.fn_exis_arquivo(pr_caminho => vr_nmarquiv) THEN
                
                IF NOT vr_flinirel THEN -- Se o relatorio ainda nao foi iniciado:
                    vr_flinirel := TRUE; -- relat�rio inicializado
                    -- Preparar o CLOB para armazenar as infos do arquivo
                    dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
                    dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
                    pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><crps167>');
                END IF;

                vr_auxdttab := vr_dttabela;
                IF rw_crapcnv.tpconven <> 1 THEN
                    vr_auxdttab := '';
                END IF;

                pc_escreve_clob(vr_clobxml, pr_desdados => 
                '<registro>' ||
                  '<dsconven>' || rw_crapcnv.dsconven || '</dsconven>' || 
                  '<dttabela>' || to_date(vr_auxdttab,'dd/mm/RRRR')    || '</dttabela>' ||
                  '<nmarquiv>' || vr_nmarquiv         || '</nmarquiv>' ||
                  '<dsobriga>SIM</dsobriga>'                           ||
                  '<dsobserv>________________________________</dsobserv>' ||
                '</registro>');

            END IF;
            
        END LOOP;
        
        CLOSE cr_crapcnv;
        
        IF vr_flinirel THEN -- Se o relatorio foi gerado, fechar tag crps167
            pc_escreve_clob(vr_clobxml,'</crps167>');
            -- Submeter o relat�rio 132
            
            -- buscar emails de destino
            vr_dsemail_dest := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                                         pr_cdcooper => pr_cdcooper, 
                                                         pr_cdacesso => 'CRPS167_EMAIL');            

            gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                 --> Cooperativa conectada
                                       ,pr_cdprogra  => vr_cdprogra                 --> Programa chamador
                                       ,pr_dtmvtolt  => rw_crapdat.dtmvtolt         --> Data do movimento atual
                                       ,pr_dsxml     => vr_clobxml                  --> Arquivo XML de dados
                                       ,pr_dsxmlnode => '/crps167/registro'         --> N� base do XML para leitura dos dados
                                       ,pr_dsjasper  => 'crrl132.jasper'            --> Arquivo de layout do iReport
                                       ,pr_dsparams  => null                        --> Sem par�metros
                                       ,pr_dsarqsaid => vr_caminho||'/crrl132.lst'  --> Arquivo final com o path
                                       ,pr_qtcoluna  => 132                         --> 132 colunas
                                       ,pr_flg_gerar => 'N'                         --> Gera�ao na hora
                                       ,pr_flg_impri => 'S'                         --> Chamar a impress�o (Imprim.p)
                                       ,pr_nmformul  => '132col'                    --> Nome do formul�rio para impress�o
                                       ,pr_nrcopias  => 1                           --> N�mero de c�pias

                                       ,pr_dsmailcop => vr_dsemail_dest          --> Lista sep. por ';' de emails para envio do relat�rio
                                       ,pr_dsassmail => 'RELATORIO crrl132'      --> Assunto do e-mail que enviar� o relat�rio
                                       ,pr_dscormail => 'Segue anexo o relat�rio crrl132.' --> HTML corpo do email que enviar� o relat�rio
                                       ,pr_fldosmail => 'S'                      --> Converter anexo para DOS antes de enviar
                                       
                                       ,pr_sqcabrel  => 0                           --> Qual a seq do cabrel
                                       ,pr_des_erro  => vr_des_erro);               --> Sa�da com erro

            -- Liberando a mem�ria alocada pro CLOB
            dbms_lob.close(vr_clobxml);
            dbms_lob.freetemporary(vr_clobxml);
            -- Verifica se ocorreram erros na gera��o do relat�rio
            IF vr_des_erro IS NOT NULL THEN
              pr_dscritic := vr_des_erro;
              -- Gerar exce��o
              RAISE vr_exc_saida;
            END IF;

        END IF;
    END IF;
    
    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    -- Processo OK, devemos chamar a fimprg e commitar
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    COMMIT;

  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas c�digo
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descri��o
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit
      COMMIT;
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas c�digo      
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos c�digo e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro n�o tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
  END pc_crps167;
/

