CREATE OR REPLACE PROCEDURE CECRED.pc_crps728(pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

  /*..............................................................................

    Programa: pc_crps728                      
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Odirlei Busana - AMcom
    Data    : fevereiro/2018                  Ultima Atualizacao : 18/10/2018

    Dados referente ao programa:

    Frequencia : Diario (JOB).
    Objetivo   : Importar arquivo de retorno de arrecadacao Bancoob

    Alteracoes : 05/06/2018 - Ajustes para mover arquivo pdf independente da sua data de geração.
                              PRJ406 - FGTS(Odirlei - AMcom)
															
								 25/07/2018 - Alterado busca dos nomes de arquivos de retorno para CECRED
								              devido a mudança de marca ainda não tratada no parceiro Bancoob.
															(Reinert)
															
								 18/10/2018 - Alterado busca dos nomes de arquivos de retorno para AILOS
								              novamente. (Reinert)
															
  ..............................................................................*/

  --------------------- ESTRUTURAS PARA OS RELATÓRIOS ---------------------

  ------------------------------- VARIAVEIS -------------------------------

  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;
  vr_exc_erro   EXCEPTION;
  vr_exc_prox   EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);
  vr_dscritic_aux VARCHAR2(4000);
  vr_des_erro     VARCHAR2(400);

  
  -- Auxiliares para o processamento 
  vr_vltotfat     NUMBER;
  vr_vlgarbcb     crapcop.vlgarbcb%TYPE;
  vr_pergabcb     NUMBER;
  
  vr_dsmsggar     VARCHAR2(4000);
  vr_dsdestin     VARCHAR2(400);
  vr_dsdcorpo     VARCHAR2(4000);
  vr_dsassunt     VARCHAR2(400);
  
  vr_dsdircon     VARCHAR2(400);
  vr_nmarquiv     VARCHAR2(400);
  vr_nmarqpdf     VARCHAR2(400);
  vr_listarq      VARCHAR2(32000);
  vr_tab_arquiv   gene0002.typ_split;
  vr_tab_linhas   gene0009.typ_tab_linhas;
  
  vr_cdconven     NUMBER;
  vr_nrsequen     NUMBER;
  vr_dtarquiv     DATE;
  vr_dtproces     DATE;
  vr_fltraile     BOOLEAN;
  vr_cdsitret     INTEGER;
  
  vr_dsarqlog_ori  VARCHAR2(400);    
  vr_dsarqlog_dest VARCHAR2(400);
  
  -- Código do programa
  vr_cdprogra           CONSTANT crapprg.cdprogra%TYPE := 'CRPS728';
  vr_nomdojob           CONSTANT VARCHAR2(30)          := 'JBCONV_BANCOOB_PROTOCOLOS';
  vr_flgerlog           BOOLEAN  := FALSE;
  
  ---------------------------------- CURSORES  ----------------------------------

  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
          ,cop.nmrescop
          ,cop.cdagebcb 
      FROM crapcop cop
     WHERE cop.flgativo = 1  -- Somente ativas
       ORDER BY cdcooper;

  -- Busca dos dados da cooperativa central
  CURSOR cr_crapcop_central (pr_cdcooper INTEGER) IS
    SELECT cop.cdcooper
          ,cop.nmrescop
          ,cop.cdagebcb 
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;     
  rw_crapcop_central cr_crapcop_central%ROWTYPE;   

  -- Buscar controle
  CURSOR cr_gncontr(pr_cdcooper crapcop.cdcooper%TYPE
                   ,pr_cdconven gncontr.cdconven%TYPE
                   ,pr_dtmvtolt gncontr.dtmvtolt%TYPE
                   ,pr_nrsequen gncontr.nrsequen%TYPE) IS
    SELECT ctr.nmarquiv,
           ctr.cdsitret,
           ctr.dtmvtolt,
           ctr.nrsequen,
           ctr.rowid  
      FROM gncontr ctr
     WHERE ctr.cdcooper = pr_cdcooper       
       AND ctr.cdconven = pr_cdconven
       AND ctr.tpdcontr = 6
       AND ctr.dtmvtolt = pr_dtmvtolt
       AND ctr.nrsequen = pr_nrsequen;
  rw_gncontr cr_gncontr%ROWTYPE;
  
  ------------------------------- REGISTROS -------------------------------
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  ------------------------- PROCEDIMENTOS INTERNOS -----------------------------   
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    PROCEDURE pc_controla_log_batch(pr_cdcooper IN INTEGER,
                                    pr_dstiplog IN VARCHAR2,
                                    pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
      
      --> Controlar geração de log de execução dos jobs 
      BTCH0001.pc_log_exec_job( pr_cdcooper  => nvl(pr_cdcooper,3) --> Cooperativa
                               ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                               ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
        
    END pc_controla_log_batch;
    
     --> Geracao de log da tela prccon
    PROCEDURE pc_gera_log_prccon(pr_desdolog IN VARCHAR2) IS
    BEGIN
      
      --> Controlar geração de log de execução dos jobs 
      BTCH0001.pc_gera_log_batch( pr_cdcooper     => 3 ,
                                  pr_ind_tipo_log => 1, 
                                  pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' -> ' ||
                                                     pr_desdolog, 
                                  pr_nmarqlog     => 'prccon_b.log',                                   
                                  pr_flfinmsg     => 'N', 
                                  pr_cdprograma   => vr_cdprogra);
        
    END pc_gera_log_prccon;
    
    --> Rotina para mover arquivo
    PROCEDURE pc_move_arq(pr_nmarquiv IN VARCHAR2,
                          pr_dsdirori IN VARCHAR2,
                          pr_dsdirdes IN VARCHAR2) IS
    
      vr_comando  VARCHAR2(1000);
      vr_typ_saida VARCHAR2(100);
      
    BEGIN
    
      -- Copiar arquivo para o diretorio envia
      vr_comando := 'mv ' || pr_dsdirori || '/' || pr_nmarquiv || ' '||pr_dsdirdes;
      -- Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      -- Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        --
        vr_dscritic := 'Não foi possível executar comando unix. ' || vr_comando || ' Erro: ' || vr_dscritic;        
        RAISE vr_exc_erro;
      END IF;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        pc_gera_log_prccon('Erro ao mover arquivo '||pr_nmarquiv ||': '|| vr_dscritic);
        vr_dscritic := NULL;
      WHEN OTHERS THEN
        pc_gera_log_prccon('Erro ao mover arquivo '||pr_nmarquiv ||': '|| SQLERRM);
        vr_dscritic := NULL;
    END;
    
    --> Rotina para copia arquivo
    PROCEDURE pc_copia_arq( pr_dsdirori IN VARCHAR2,
                            pr_dsdirdes IN VARCHAR2) IS
    
      vr_comando  VARCHAR2(1000);
      vr_typ_saida VARCHAR2(100);
      
    BEGIN
    
      -- Copiar arquivo para o diretorio envia
      vr_comando := 'cp ' || pr_dsdirori || ' '||pr_dsdirdes;
      -- Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      -- Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        --
        vr_dscritic := 'Não foi possível executar comando unix. ' || vr_comando || ' Erro: ' || vr_dscritic;        
        RAISE vr_exc_erro;
      END IF;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        pc_gera_log_prccon('Erro ao copiar arquivo '||pr_dsdirori ||': '|| vr_dscritic);
        vr_dscritic := NULL;
      WHEN OTHERS THEN
        pc_gera_log_prccon('Erro ao copiar arquivo '||pr_dsdirori ||': '|| SQLERRM);
        vr_dscritic := NULL;
    END;
    
   
  BEGIN
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
    
    --> buscar diretorio do connect
    vr_dsdircon := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                             pr_cdcooper => 3, 
                                             pr_cdacesso => 'DIR_CONNECT_BANCOOB');
      
    -- Busca dos dados da cooperativa central
    OPEN cr_crapcop_central (pr_cdcooper => 3);
    FETCH cr_crapcop_central INTO rw_crapcop_central;
    IF cr_crapcop_central%NOTFOUND THEN
      CLOSE cr_crapcop_central;
      vr_dscritic := 'Cooperativa central nao encontrada.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapcop_central;
    END IF;
    
      
    vr_dtproces := SYSDATE;
    
    --> Listar cooperativas ativas
    FOR rw_crapcop IN cr_crapcop LOOP
        
      BEGIN
        -->>>>> Caso alterado nome do arquivo de retorno, necessario alterar package tela_tab057 <<<<--
        vr_nmarquiv := to_char(rw_crapcop.cdagebcb,'fm0000')||'-RT%'||to_char(vr_dtproces,'RRRRMMDD')||'%'||rw_crapcop_central.nmrescop||'%';
        vr_nmarqpdf := to_char(rw_crapcop.cdagebcb,'fm0000')||'-RT%'||'%'||rw_crapcop_central.nmrescop||'%';
        
        --> Buscar arquivos 
        gene0001.pc_lista_arquivos(pr_path     => vr_dsdircon||'/recebe', 
                                   pr_pesq     => vr_nmarquiv||'.RET', 
                                   pr_listarq  => vr_listarq, 
                                   pr_des_erro => vr_dscritic);
                                   
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        --> quebrar listas
        vr_tab_arquiv := gene0002.fn_quebra_string(pr_string  => vr_listarq, 
                                                   pr_delimit => ',');
      
        -- Verificar se localizou algum arquivo
        IF vr_tab_arquiv.count > 0 THEN
        
          --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
          pc_controla_log_batch(pr_cdcooper => rw_crapcop.cdcooper,
                                pr_dstiplog => 'I');
                   
          --> ler arquivos localizados             
          FOR idx IN vr_tab_arquiv.first..vr_tab_arquiv.last LOOP
            BEGIN
             
              vr_dtarquiv := to_date(SUBSTR(vr_tab_arquiv(idx),18,8),'RRRRMMDD');
              
              vr_tab_linhas.delete;
              --Importar o arquivo
              gene0009.pc_importa_arq_layout( pr_nmlayout   => 'RET_ARRECAD_BANCOOB', 
                                              pr_dsdireto   => vr_dsdircon||'/recebe', 
                                              pr_nmarquiv   => vr_tab_arquiv(idx), 
                                              pr_dscritic   => vr_dscritic, 
                                              pr_tab_linhas => vr_tab_linhas);
              IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := vr_dscritic;
                RAISE vr_exc_prox;               
              END IF;
              
              IF vr_tab_linhas.count > 0 THEN
              
                vr_fltraile := FALSE;
                --> Varrer linhas do arquivo
                FOR i IN vr_tab_linhas.first..vr_tab_linhas.last LOOP
                
                  --Gerar critica do arquivo quando os erros forem os registros cadastrados
                  IF vr_tab_linhas(i)('$LAYOUT$').texto IN ('H','D','R','T') THEN
                    IF vr_tab_linhas(i).exists('$ERRO$') THEN --Problemas com importacao do layout
                      vr_dscritic := 'Linha '||i||' '|| vr_tab_linhas(i)('$ERRO$').texto;

                      RAISE vr_exc_prox;
                    END IF;
                  END IF;
                  
                  -------------------  Header do Arquivo --------------------
                  IF vr_tab_linhas(i)('$LAYOUT$').texto = 'H' THEN 
                  
                    BEGIN
                     
                      rw_gncontr:= NULL;
                      vr_cdconven := vr_tab_linhas(i)('CDCONVENIO').texto;                                    
                    
                      IF vr_tab_linhas(i)('DTPROCES').data <> vr_dtarquiv THEN
                        vr_dscritic := 'Data de processamento do arquivo não confere';                       
                        RAISE vr_exc_prox;
                      END IF;   
                      
                      -- Buscar controle
                      OPEN cr_gncontr( pr_cdcooper => rw_crapcop.cdcooper
                                      ,pr_cdconven => vr_cdconven
                                      ,pr_dtmvtolt => vr_tab_linhas(i)('DTPROCES').data
                                      ,pr_nrsequen => vr_tab_linhas(i)('NRSEQNSA').numero); 
                      
                      FETCH cr_gncontr INTO rw_gncontr;
                      IF cr_gncontr%NOTFOUND THEN
                        CLOSE cr_gncontr;
                        vr_dscritic := 'Sequencial do arquivo não encontrado.';
                        RAISE vr_exc_prox;
                      ELSE
                        CLOSE cr_gncontr;
                      END IF;
                      
                      --> Verificar se ja foi processado
                      IF rw_gncontr.cdsitret > 1 THEN
                        vr_dscritic := 'Arquivo de retorno já processado.';             
                        RAISE vr_exc_prox;
                      END IF;
                    
                      --> Validar NSA
                      IF vr_tab_linhas(i)('NRSEQNSA').numero <> rw_gncontr.nrsequen THEN
                        vr_dscritic := 'NSA do arquivo não confere.';
                        RAISE vr_exc_prox;                       
                      END IF; 
                    
                    EXCEPTION
                      WHEN vr_exc_prox THEN
                        --> apenas sair, para validar abaixo se possui critica
                        NULL;
                      WHEN OTHERS THEN
                        vr_dscritic := 'Erro ao validar header: '||SQLERRM;
                    END;
                    
                    IF vr_dscritic IS NOT NULL THEN
                                           
                      gene0005.pc_gera_inconsistencia( pr_cdcooper => rw_crapcop.cdcooper ,
                                                       pr_iddgrupo => 5, 
                                                       pr_tpincons => 2, 
                                                       pr_dsregist => 'Arquivo: '|| vr_tab_arquiv(idx), 
                                                       pr_dsincons => vr_dscritic, 
                                                       pr_flg_enviar => 'N', 
                                                       pr_des_erro => vr_des_erro, 
                                                       pr_dscritic => vr_dscritic_aux);
                    
                      --> Atualizar registro de controle
                      BEGIN
                        UPDATE gncontr ctr
                           SET ctr.cdsitret = 5
                         WHERE ctr.ROWID = rw_gncontr.rowid;  
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_dscritic := vr_dscritic ||' Erro ao atulizar registro de controle '||SQLERRM;                          
                      END;
                      
                      RAISE vr_exc_prox; 
                    
                    END IF;
                                         
                  
                  ------------------- Trailer do Arquivo -------------------- 
                  ELSIF vr_tab_linhas(i)('$LAYOUT$').texto = 'T' THEN 
                    vr_fltraile := TRUE;                  
                  
                  
                  ------------------- Rejeitados do Arquivo -------------------- 
                  ELSIF vr_tab_linhas(i)('$LAYOUT$').texto = 'R' THEN 
                  
                    gene0005.pc_gera_inconsistencia( pr_cdcooper => rw_crapcop.cdcooper ,
                                                     pr_iddgrupo => 5, 
                                                     pr_tpincons => 2, 
                                                     pr_dsregist => 'Arquivo: '|| vr_tab_arquiv(idx) ||
                                                                    '<br> NSR: '|| vr_tab_linhas(i)('NRSEQREG').numero, 
                                                     pr_dsincons => CONVERT(vr_tab_linhas(i)('DSMTVREC').texto, 'WE8ISO8859P1', 'AL32UTF8'), 
                                                     pr_flg_enviar => 'N',
                                                     pr_des_erro => vr_des_erro, 
                                                     pr_dscritic => vr_dscritic_aux);  
                  
				    IF vr_tab_linhas(i)('NRSEQREG').numero = 0        OR   --> Se for erro no HEADER
					   vr_tab_linhas(i)('NRSEQREG').numero = 99999999 THEN --  ou TRAILER
                      --> Atualizar registro de controle
                      BEGIN
                        UPDATE gncontr ctr
                           SET ctr.cdsitret = 4 -- Rejeitado
                         WHERE ctr.ROWID = rw_gncontr.rowid;  
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_dscritic := vr_dscritic ||' Erro ao atulizar registro de controle '||SQLERRM;                          
                      END;										  
					END IF;
                  ------------------- Resumo do Arquivo -------------------- 
                  ELSIF vr_tab_linhas(i)('$LAYOUT$').texto = 'D' THEN 
                    vr_cdsitret := 0;
                    
                    IF vr_tab_linhas(i)('QTREGACE').numero = 0 AND
                       vr_tab_linhas(i)('QTREGREJ').numero > 0 THEN                      
                      -- Rejeitado 
                      vr_cdsitret := 4;    
                       
                    ELSIF vr_tab_linhas(i)('QTREGACE').numero > 0 AND
                       vr_tab_linhas(i)('QTREGREJ').numero = 0 THEN   
                      -- Processado com sucesso 
                      vr_cdsitret := 2;    
                      
                    ELSIF vr_tab_linhas(i)('QTREGACE').numero > 0 AND
                       vr_tab_linhas(i)('QTREGREJ').numero > 0 THEN   
                      -- Processado com Inconsistencia
                      vr_cdsitret := 3;     
                    END IF;     
                    
                    IF vr_cdsitret > 0 THEN
                      --> Atualizar registro de controle
                      BEGIN
                        UPDATE gncontr ctr
                           SET ctr.cdsitret = vr_cdsitret
                         WHERE ctr.ROWID = rw_gncontr.rowid;  
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_dscritic := vr_dscritic ||' Erro ao atulizar registro de controle '||SQLERRM;                          
                      END;
                    END IF;
                    
                  END IF; --Fim Rejeitados
                
                END LOOP;
                
                IF vr_fltraile = FALSE THEN                
                  gene0005.pc_gera_inconsistencia( pr_cdcooper => rw_crapcop.cdcooper ,
                                                   pr_iddgrupo => 5, 
                                                   pr_tpincons => 1, 
                                                   pr_dsregist => 'Arquivo: '|| vr_tab_arquiv(idx), 
                                                   pr_dsincons => 'Arquivo incompleto: registro Z não encontrado.', 
                                                   pr_flg_enviar => 'N',
                                                   pr_des_erro => vr_des_erro, 
                                                   pr_dscritic => vr_dscritic_aux);
                    
                  --> Atualizar registro de controle
                  BEGIN
                    UPDATE gncontr ctr
                       SET ctr.cdsitret = 5
                     WHERE ctr.ROWID = rw_gncontr.rowid;  
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := vr_dscritic ||' Erro ao atulizar registro de controle '||SQLERRM;                          
                  END;
                      
                  RAISE vr_exc_prox; 
                
                END IF;
                
              ELSE
                vr_dscritic := 'Arquivo vazio.';
                RAISE vr_exc_prox;               
              END IF;
              
              pc_move_arq(pr_nmarquiv => vr_tab_arquiv(idx),
                          pr_dsdirori => vr_dsdircon||'/recebe',
                          pr_dsdirdes => vr_dsdircon||'/recebidos');
              
              
              --> Salvar a cada registro pois o mesmo foi movido para pasta e nao pode ser mais processado
              COMMIT;
              
            EXCEPTION 
              WHEN vr_exc_prox THEN
                pc_gera_log_prccon('Connect --> Retorno não processado: '|| vr_tab_arquiv(idx) ||'. Motivo: '||vr_dscritic);
                vr_dscritic := NULL;
                pc_move_arq(pr_nmarquiv => vr_tab_arquiv(idx),
                            pr_dsdirori => vr_dsdircon||'/recebe',
                            pr_dsdirdes => vr_dsdircon||'/recebidos');
                --> Garantir  alterações realizadas no processo
                COMMIT;
              
            END;
          END LOOP; -- Fim Arq
          
          --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
          pc_controla_log_batch(pr_cdcooper => rw_crapcop.cdcooper,
                              pr_dstiplog => 'F');
      

        END IF;
        
        IF gene0001.fn_exis_arquivo(pr_caminho => vr_dsdircon||'/recebe/'||replace(vr_nmarqpdf,'%','*')||'.PDF') THEN
          pc_move_arq(pr_nmarquiv => replace(vr_nmarqpdf,'%','*')||'.PDF',
                      pr_dsdirori => vr_dsdircon||'/recebe',
                      pr_dsdirdes => '/usr/sistemas/bancoob/convenios/recebidos');
        
        END IF;
      EXCEPTION
        WHEN vr_exc_erro THEN
          --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
          pc_controla_log_batch(pr_cdcooper => rw_crapcop.cdcooper,
                                pr_dstiplog => 'E'
                               ,pr_dscritic => vr_dscritic);
        
          
      END;
    END LOOP; --> Fim loop CRAPCOP
    
    vr_dsarqlog_ori  := vr_dsdircon||'/logs/prccon.log'; 
      
    vr_dsarqlog_dest := gene0001.fn_param_sistema( pr_nmsistem => 'CRED',
                                                   pr_cdcooper => 3,
                                                   pr_cdacesso => 'ROOT_SISTEMAS'); 
    vr_dsarqlog_dest := vr_dsarqlog_dest ||'/bancoob/convenios/recebidos/prccon_connect.log';
    
    IF gene0001.fn_exis_arquivo(pr_caminho => vr_dsarqlog_ori) THEN
      pc_copia_arq(pr_dsdirori => vr_dsarqlog_ori,
                   pr_dsdirdes => vr_dsarqlog_dest);
          
    END IF;
           
    ----------------- ENCERRAMENTO DO PROGRAMA -------------------                                                     

    -- Salvar informações atualizadas
    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    pc_controla_log_batch( pr_cdcooper => 3
                          ,pr_dstiplog => 'E'
                          ,pr_dscritic => vr_dscritic);
    
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
    raise_application_error(-20500,vr_dscritic);
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    vr_dscritic := SQLERRM;                           
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    pc_controla_log_batch( pr_cdcooper => 3
                          ,pr_dstiplog => 'E'
                          ,pr_dscritic => vr_dscritic);
    pr_dscritic := vr_dscritic;                      
    -- Efetuar rollback
    ROLLBACK;
    raise_application_error(-20500,vr_dscritic);
End pc_crps728;
/
