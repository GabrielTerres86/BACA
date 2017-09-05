CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS673 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                                ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                                ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                                ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                                ,pr_cdoperad IN crapnrc.cdoperad%TYPE   --> Código do operador
                                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                                ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada                                          
  BEGIN				
    
/* ..........................................................................

       Programa: pc_crps673
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Lucas Lunelli
       Data    : Março/2014.                     Ultima atualizacao: 26/07/2017

       Dados referentes ao programa:

       Frequencia: Diário.
       Objetivo  : Atende a solicitacao 82, Ordem 19.
                   Processar Arquivo de Débito Em Conta das Faturas (Bancoob/CABAL).

       Alteracoes: 24/04/2014 - Atualizalção de sequência e arquivos reprocessados (Jean Michel).
                   
                   22/08/2014 - Alteração da busca do diretorio do bancoob(Odirlei/AMcom)                
                
                   27/08/2014 - Realizar commit a cada processamento de arquivo(Odirlei/Amcom)
                   
                   22/09/2014 - Retirar a regra para buscar apenas cartões em Uso
                              - Não parar o processo em caso de erro de busca de registros,
                                apenas gerar log e passar para a próxima linha (Renato - Supero)
                                
                   07/10/2014 - Retirar o update da flag crapscb.flgretpr, conforme solicitado: 
                                006 - Parâmetros de integração dos arquivos ( Renato - Supero )

                   12/12/2014 - Retirado cpf da consulta no cursor cr_crawcrd_nrcctitg.
                                (Jorge/Rodrigo) Emergnecial SD 231519
                                
                   24/04/2015 - Ajustado somatorio do campo vr_vlcompdb, pois estava sendo reinicializado a cada 
                                criação de craplot, porém é comparado com o valor total do relatorio,
                                alterado para inicializar apenas na abertura do arquivo SD273356 (Odirlei-Busana)             
                                
                   09/06/2015 - Adicionado gravacao do campo dslindig na craplau com o 
                                valor minimo da fatura posicao 49 a 57 do arquivo e
                                gravacao da data vencimento dtvencto
                                (Melhoria repique fatura cartao - Tiago/Rodrigo)           
                                
                   09/12/2015 - Alterar log para proc_message (Lucas Ranghetti #365409 )
                   
                   24/02/2017 - Incluindo tratamento para enviar e-mail para responsavel caso
                                o arquivo ao tenha trailler, conforme solicitado no chamado
                                615979. (Kelvin)
                                
                   04/07/2017 - Melhoria na busca dos arquivos que irão ser processador, conforme
                                solicitado no chamado 703589. (Kelvin)
                                
                   26/07/2017 - Padronizar as mensagens - Chamado 721285
                               	Tratar os exception others - Chamado 721285
                                Tratar dia 10 útil ou próximo dia útil - Chamado 678813
                                Retirada validação "IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN"
                                ( Belli - Envolti )                   
                   
                   04/08/2017 - Retirar tratamento dia 10 útil ou próximo dia útil - Chamado 678813
                                Retirar variáveis não utilizadas (vr_idinsert, vr_chave, vr_nmarquiv)
                                ( Belli - Envolti )                   

........................................................................................................... */
    DECLARE                                                                             
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
      
      vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS673';       --> Código do programa
      vr_dsdireto   VARCHAR2(2000);                                    --> Caminho para gerar
      vr_direto_connect   VARCHAR2(200);                               --> Caminho CONNECT
      vr_nmrquivo   VARCHAR2(2000);                                    --> Nome do arquivo
      vr_des_text   VARCHAR2(2000);                                    --> Conteúdo da Linha do Arquivo
      vr_comando    VARCHAR2(2000);                                    --> Comando UNIX para Mover arquivo lido
      vr_dtmvtolt   DATE;                                              --> Data retirada do HEADER
      vr_vlcompdb   craplot.vlcompdb%TYPE;                             --> Guarda valor computado para comparação
      vr_ind_arquiv utl_file.file_type;                                --> declarando handle do arquivo
      vr_nrseqarq   INTEGER;                                           --> Sequencia de Arquivo						
      vr_maior_seq  INTEGER  := 0;                                     --> Maior Sequencia de Arquivo					
      vr_contador   NUMBER:= 0;                                        --> Conta qtd. arquivos	
      vr_conarqui   NUMBER:= 0;                                        --> Contador auxiliar para for
      vr_indice     NUMBER:= 0;                                        --> Conta qtd. linhas arquivo	
      vr_flgtrail   NUMBER;                                             --> Identifica se o arquivo tem trailler
      vr_listarq    VARCHAR2(5000);                                     -->Lista de arquivos
      vr_split      gene0002.typ_split := gene0002.typ_split();

      --Chamado 721285
      vr_dsparam    VARCHAR2(4000);
      
      --Variaveis para e-mail
      vr_conteudo    VARCHAR2(4000); 	      
      vr_des_assunto VARCHAR2(100);
      vr_email_dest  VARCHAR2(100);
      
      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_des_erro   VARCHAR2(4000);
	    vr_typ_saida  VARCHAR2(4000);
      
      TYPE typ_reg_crawcrd IS
        RECORD (nrdconta crawcrd.nrdconta%TYPE
               ,nrctrcrd crawcrd.nrctrcrd%TYPE);
               
      TYPE typ_tab_crawcrd IS
        TABLE OF typ_reg_crawcrd
          INDEX BY VARCHAR2(32); -- Coop(5) + CtaItg(25) + Sequencial(2)
          
      vr_tab_crawcrd typ_tab_crawcrd;    
               
      vr_chv_cartao VARCHAR2(32);
      
	  -- Definicao do tipo de arquivo para processamento			
      TYPE typ_tab_nmarquiv IS
			 TABLE OF VARCHAR2(100)
			 INDEX BY BINARY_INTEGER;

      -- Vetor para armazenar os arquivos para processamento
      vr_vet_nmarquiv typ_tab_nmarquiv;     
      
      /*temptable com as linhas do arquivo*/
      TYPE typ_reg_linarq IS
        RECORD (linhaarq           VARCHAR2(4000),
                cdagebcb           crapcop.cdagebcb%TYPE,
                nrcctitg           crawcrd.nrcctitg%TYPE,
                dsdocumento        tbcrd_fatura.dsdocumento%TYPE,
                vlfatura           tbcrd_fatura.vlfatura%TYPE,
                vlminimo_pagamento tbcrd_fatura.vlminimo_pagamento%TYPE,
                dtvencimento       tbcrd_fatura.dtvencimento%TYPE,
                nrconta_cartao     tbcrd_fatura.nrconta_cartao%TYPE,
                nrsequencia        tbcrd_fatura.nrsequencia%TYPE);

      /* Tipos de tabela de memoria */
      TYPE typ_tab_linarq
        IS TABLE OF typ_reg_linarq INDEX BY PLS_INTEGER;
    			
      -- Temp Table
      vr_tab_linarq typ_tab_linarq;
      
      ------------------------------- CURSORES ---------------------------------
                   
      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.cdagebcb
							,cop.dsdircop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
                                          
      -- Cursor genérico de calendário
      rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
						
			-- Cursor para retornar cooperativa com base na agencia do bancoob
      CURSOR cr_crapcop_cdagebcb (pr_cdagebcb IN crapcop.cdagebcb%TYPE) IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.cdagebcb = pr_cdagebcb;
      rw_crapcop_cdagebcb cr_crapcop_cdagebcb%ROWTYPE;

	  -- Busca dados da proposta do cartão usando Nr. Conta Cartão
      CURSOR cr_crawcrd_nrcctitg  IS
        SELECT pcr.cdcooper
              ,pcr.nrcctitg
              ,pcr.nrdconta
              ,pcr.nrctrcrd
              ,pcr.nrcrcard
              ,pcr.nrcpftit
              ,pcr.flgprcrd
          FROM crawcrd pcr;
		 --AND pcr.insitcrd = 4; /* EM USO */
      
      -- Informações arquivo bancoob
      CURSOR cr_crapscb IS 
        SELECT crapscb.Dsdirarq,
               crapscb.nrseqarq
          FROM crapscb
         WHERE crapscb.tparquiv = 4;  -- Arquivo DAUT - Debito em conta das faturas
      rw_crapscb cr_crapscb%ROWTYPE;
   
      vr_idfatura tbcrd_fatura.idfatura%TYPE;
                                
      -- Subrotina para escrever críticas no LOG do processo
      PROCEDURE pc_log_batch
        ( pr_origem in number )
      IS
        -- Padronização do log - 26/07/2017 - Chamado 721285  
      BEGIN
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN 
          
          -- Ajustada chamada para buscar a descrição da critica - 31/07/2017 - Chamado 721285
          -- Devolvemos código e critica encontradas das variaveis locais
          vr_cdcritic := nvl(vr_cdcritic,0);
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_cdprograma   => vr_cdprogra
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')|| ' - ' || vr_cdprogra
                                                                || ' --> ' || 'ERRO: ' || vr_dscritic );
          if ( pr_origem = 1 ) then
            vr_cdcritic := 0;
            vr_dscritic := '';
          end if;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 31/07/2017 - Chamado 721285        
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
      END pc_log_batch;
    
  BEGIN			
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
                        
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
      
    -- Se nao encontrar
    IF cr_crapcop%NOTFOUND THEN          
      -- Fechar o cursor pois havera raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_saida;        
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;        
    END IF;
      
    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
            
    -- Se nao encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN        
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
      
    -- Validacoes iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se a variavel nao for 0
    IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;
    
    -- buscar informações do arquivo a ser processado
    OPEN cr_crapscb;
    FETCH cr_crapscb INTO rw_crapscb;
    IF cr_crapscb%NOTFOUND  THEN
      vr_dscritic := 'Registro crapscb não encontrado!';      
      CLOSE cr_crapscb;  
       --levantar excecao
      RAISE vr_exc_saida; 
    END IF;  
    CLOSE cr_crapscb;       

    -- buscar caminho de arquivos do Bancoob/CABAL
    vr_dsdireto := rw_crapscb.dsdirarq;
          
    vr_direto_connect := vr_dsdireto || '/recebe';
        
    -- monta nome do arquivo
    vr_nmrquivo := 'DAUT756' || TO_CHAR(lpad(rw_crapcop.cdagebcb,4,'0')) || '%.%';

    gene0001.pc_lista_arquivos(pr_path     => vr_direto_connect 
                              ,pr_pesq     => vr_nmrquivo  
                              ,pr_listarq  => vr_listarq 
                              ,pr_des_erro => vr_des_erro); 

    --Ocorreu um erro no lista_arquivos
    IF TRIM(vr_des_erro) IS NOT NULL THEN
       vr_cdcritic := 0;
       vr_dscritic := vr_des_erro;
      RAISE vr_exc_saida;
    END IF;  
            
    --Nao encontrou nenhuma arquivo para processar
    IF TRIM(vr_listarq) IS NULL THEN
        vr_cdcritic := 182;
        vr_dscritic := NULL;
        RAISE vr_exc_fimprg;
    END IF;
            
    vr_split := gene0002.fn_quebra_string(pr_string  => vr_listarq
                                         ,pr_delimit => ',');
                  
    IF vr_split.count = 0 THEN
       vr_cdcritic := 182;
       vr_dscritic := NULL;
       RAISE vr_exc_fimprg;
    END IF;
            
    FOR vr_conarqui IN vr_split.FIRST..vr_split.LAST LOOP
      vr_vet_nmarquiv(vr_conarqui) := vr_split(vr_conarqui);    
      vr_contador :=  vr_conarqui; 
    END LOOP;
          
    -- Se o contador está zerado
    IF vr_contador = 0 THEN        
      vr_cdcritic:= 182;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_fimprg;
    END IF;

    -- Carregar tabela de cartões
    FOR rw_crawcrd IN cr_crawcrd_nrcctitg LOOP
              
      -- Considerar apenas o titular
      IF rw_crawcrd.flgprcrd <> 1 THEN
         CONTINUE;
      END IF;   
            
      vr_indice := 0;
      vr_chv_cartao := lpad(rw_crawcrd.cdcooper,5,'0')||lpad(rw_crawcrd.nrcctitg,25,'0');
                
      IF vr_tab_crawcrd.EXISTS(vr_chv_cartao) THEN
         CONTINUE;
      END IF;   
                
      vr_tab_crawcrd(vr_chv_cartao).nrdconta := rw_crawcrd.nrdconta;
      vr_tab_crawcrd(vr_chv_cartao).nrctrcrd := rw_crawcrd.nrctrcrd;
                
    END LOOP;

    -- Guardar a maior sequencia processada
    vr_maior_seq := rw_crapscb.nrseqarq;

    -- Percorre cada arquivo encontrado
    FOR i IN 1..vr_contador LOOP
        vr_flgtrail := 0;
        -- adquire sequencial do arquivo
        vr_nrseqarq := to_number(substr(vr_vet_nmarquiv(i),22,3));           

        -- Verificar se sequencial já foi importado
        IF nvl(rw_crapscb.nrseqarq,0) >= nvl(vr_nrseqarq,0) THEN
          -- Montar mensagem de critica
          vr_dscritic := 'Sequencial do arquivo '|| vr_vet_nmarquiv(i) ||
                         ' deve ser maior que o ultimo já processado (seq arq.: ' ||vr_nrseqarq||
                         ', Ult. seq.: ' || rw_crapscb.nrseqarq|| '), arquivo não será processado.';
          -- Padronização do log - 26/07/2017 - Chamado 721285  
          -- gravar log do erro
          pc_log_batch ( 1 );
          CONTINUE;
        -- verificar se não pulou algum sequencial
        ELSIF nvl(vr_maior_seq,0) + 1 <> nvl(vr_nrseqarq,0) THEN
          -- Montar mensagem de critica
          vr_dscritic := 'Falta sequencial de arquivo ' ||
                         '(seq arq.: ' ||vr_nrseqarq|| ', Ult. seq.: ' || vr_maior_seq||
                         '), arquivo '|| vr_vet_nmarquiv(i) ||' não será processado.';
          -- Padronização do log - 26/07/2017 - Chamado 721285  
          -- gravar log do erro
          pc_log_batch ( 1 );
          CONTINUE;
        END IF;
                
        -- criar handle de arquivo de Débitos em Contas das Faturas
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_direto_connect  --> Diretorio do arquivo
                                ,pr_nmarquiv => vr_vet_nmarquiv(i) --> Nome do arquivo
                                ,pr_tipabert => 'R'                --> modo de abertura (r,w,a)
                                ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic);      --> erro
                                
        -- Retorna nome do módulo logado - Chamado 721285 31/07/2017
        GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);
                                        
        -- em caso de crítica                        
        IF vr_dscritic IS NOT NULL THEN        
          -- levantar excecao
          RAISE vr_exc_saida;        
        END IF;

        vr_indice := 0;
        vr_tab_linarq.delete;
                
        IF utl_file.is_open(vr_ind_arquiv) THEN
           LOOP
             BEGIN                 
               -- Lê a linha do arquivo aberto
               gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv --> Handle do arquivo aberto
                                           ,pr_des_text => vr_des_text); --> Texto lido    
               
               -- Retorna nome do módulo logado - Chamado 721285 31/07/2017
               GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);

               vr_tab_linarq(vr_indice).linhaarq := vr_des_text;
               vr_indice := vr_indice + 1;
             EXCEPTION
               WHEN vr_exc_saida THEN
                 RAISE vr_exc_saida;
               WHEN no_data_found THEN -- não encontrar mais linhas
                 EXIT;
               WHEN OTHERS THEN
                 -- No caso de erro de programa gravar tabela especifica de log - 26/07/2017 - Chamado 721285        
                 CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
                 vr_des_erro := 'Erro arquivo ['|| vr_vet_nmarquiv(i) ||']: '||SQLERRM;
                 vr_dscritic := vr_des_erro;
                 RAISE vr_exc_saida;
             END;               
           END LOOP;  
                   
           -- Fechar o arquivo
           gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;
                     
        END IF;
                
        -- Verifica o maior sequencial entre todos os arquivos abertos para armazenar na crapscb
        IF vr_maior_seq < vr_nrseqarq THEN
           vr_maior_seq := vr_nrseqarq;
        END IF;
                      
        -- ATUALIZA REGISTRO REFERENTE A SEQUENCIA DE ARQUIVOS
        BEGIN
          UPDATE crapscb
             SET nrseqarq = vr_maior_seq,
                 dtultint = SYSDATE
                 -- flgretpr = 0 -- Alteração: 006 - Parâmetros de integração dos arquivos ( Renato - Supero )
           WHERE crapscb.tparquiv = 4; -- Arquivo DAUT - Debito em conta das faturas
                            
        -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZACAO DE REGISTROS
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 26/07/2017 - Chamado 721285        
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
            -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
            vr_dscritic := 'Problema ao atualizar registro na tabela CRAPSCB: ' || sqlerrm;
            RAISE vr_exc_saida;
        END;       
                
        -- inicializar variaveis
        vr_vlcompdb := 0;
        vr_indice := 0;
                
        -- Leitura da tabela temporaria 
        FOR vr_indice IN vr_tab_linarq.FIRST..vr_tab_linarq.LAST LOOP
                    
            IF SUBSTR(vr_tab_linarq(vr_indice).linhaarq,5,1) = '0' THEN
               vr_dtmvtolt := to_date(substr(vr_tab_linarq(vr_indice).linhaarq,13,8),'DDMMRRRR');
               CONTINUE;
            END IF;     

            -- adquire data do TRAILER do arquivo
            IF substr(vr_tab_linarq(vr_indice).linhaarq,5,1) = '9'  THEN
                      
               vr_flgtrail := 1;
                       
               IF (substr(vr_tab_linarq(vr_indice).linhaarq,22,16) / 100 ) != vr_vlcompdb THEN
                   -- Montar mensagem de critica
                   vr_dscritic := 'Valor Total a Debito Comp do lote '||vr_vlcompdb||' diferente do ' ||
                                  'valor '||(substr(vr_tab_linarq(vr_indice).linhaarq,22,16) / 100)||
                                  ' presente no arquivo: ' || vr_vet_nmarquiv(i);

                   -- Padronização do log - 26/07/2017 - Chamado 721285 
                   -- Grava Log do Erro
                   pc_log_batch ( 2 );
               END IF;
                       
               CONTINUE;
            END IF;    
                    
            --Preenche as variaveis da pltable apenas uma vez a partir da linha do arquivo
            vr_tab_linarq(vr_indice).cdagebcb := SUBSTR(vr_tab_linarq(vr_indice).linhaarq,33,4);
            vr_tab_linarq(vr_indice).nrcctitg := SUBSTR(vr_tab_linarq(vr_indice).linhaarq,06,13);
            vr_tab_linarq(vr_indice).dsdocumento := SUBSTR(vr_tab_linarq(vr_indice).linhaarq,06,13);
            vr_tab_linarq(vr_indice).vlfatura := (SUBSTR(vr_tab_linarq(vr_indice).linhaarq,70,12) / 100);
            vr_tab_linarq(vr_indice).vlminimo_pagamento := (SUBSTR(vr_tab_linarq(vr_indice).linhaarq,49,9) / 100);
            vr_tab_linarq(vr_indice).dtvencimento := TO_DATE(SUBSTR(vr_tab_linarq(vr_indice).linhaarq,82,8),'DDMMRRRR');
            vr_tab_linarq(vr_indice).nrconta_cartao := SUBSTR(vr_tab_linarq(vr_indice).linhaarq,06,13);
            vr_tab_linarq(vr_indice).nrsequencia := SUBSTR(vr_tab_linarq(vr_indice).linhaarq,27,6);            
                    
            -- busca a cooperativa com base no cod. da agencia do bancoob
            OPEN cr_crapcop_cdagebcb(pr_cdagebcb =>  vr_tab_linarq(vr_indice).cdagebcb);
            FETCH cr_crapcop_cdagebcb INTO rw_crapcop_cdagebcb;
        							
            IF cr_crapcop_cdagebcb%NOTFOUND THEN
               -- Fechar o cursor pois havera raise
               CLOSE cr_crapcop_cdagebcb;
               -- Montar mensagem de critica
               vr_dscritic := 'Cod. Agencia do Bancoob ' || vr_tab_linarq(vr_indice).cdagebcb || 
                              ' nao possui Cooperativa correspondente.';
        								
               -- Padronização do log - 26/07/2017 - Chamado 721285 
               -- Envio centralizado de log de erro
               pc_log_batch ( 2 );
                            
               -- Próxima linha                                                    
               CONTINUE;						
            END IF;
        															
            -- Fecha cursor cooperativa			
            CLOSE cr_crapcop_cdagebcb;            
                    
            vr_chv_cartao := lpad(rw_crapcop_cdagebcb.cdcooper,5,'0')||lpad(vr_tab_linarq(vr_indice).nrcctitg,25,'0');
                    
            IF NOT vr_tab_crawcrd.EXISTS(vr_chv_cartao) THEN
                    
              -- Montar mensagem de critica
              vr_dscritic := 'Nenhuma proposta de cartao de credito ' || 
                             'encontrada com Nr. Conta Cartao: '      || vr_tab_linarq(vr_indice).nrcctitg || '.';																
            								
              -- Padronização do log - 26/07/2017 - Chamado 721285 
              -- Envio centralizado de log de erro
               pc_log_batch ( 2 );  
              -- Próxima linha                                                    
              CONTINUE;
            END IF;
        						            
            -- Inserir FATURA
            BEGIN
                INSERT INTO tbcrd_fatura
                    (idfatura
                    ,cdcooper
                    ,nrdconta
                    ,nrcontrato
                    ,dtmovimento
                    ,dsdocumento
                    ,vlfatura
                    ,vlminimo_pagamento
                    ,dtvencimento
                    ,dtpagamento
                    ,nrconta_cartao
                    ,insituacao
                    ,vlpendente
                    ,nmarquivo
                    ,nrsequencia)
                VALUES
                    (seq_crd_idfatura.nextval
                    ,rw_crapcop_cdagebcb.cdcooper
                    ,vr_tab_crawcrd(vr_chv_cartao).nrdconta
                    ,vr_tab_crawcrd(vr_chv_cartao).nrctrcrd 
                    ,rw_crapdat.dtmvtolt
                    ,vr_tab_linarq(vr_indice).dsdocumento||TO_CHAR(rw_crapdat.dtmvtolt,'MMRRRR') --dsdocumento = nrcctitg+mes+ano
                    ,vr_tab_linarq(vr_indice).vlfatura
                    ,vr_tab_linarq(vr_indice).vlminimo_pagamento
                    ,vr_tab_linarq(vr_indice).dtvencimento
                    ,NULL
                    ,vr_tab_linarq(vr_indice).nrconta_cartao
                    ,1 --Aberto
                    ,vr_tab_linarq(vr_indice).vlfatura
                    ,vr_vet_nmarquiv(i)
                    ,vr_tab_linarq(vr_indice).nrsequencia)
                    RETURNING idfatura INTO vr_idfatura;
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 26/07/2017 - Chamado 721285        
                CECRED.pc_internal_exception (pr_cdcooper =>pr_cdcooper);   
                vr_dscritic := 'Erro ao inserir tbcrd_fatura: '||SQLERRM;
                vr_dsparam := '.Cdcooper: '||rw_crapcop_cdagebcb.cdcooper
                            ||',nrdconta:'||vr_tab_crawcrd(vr_chv_cartao).nrdconta
                            ||',nrctrcrd:'||vr_tab_crawcrd(vr_chv_cartao).nrctrcrd 
                            ||',dtmvtolt:'||rw_crapdat.dtmvtolt
                            ||',dsdocto:'||vr_tab_linarq(vr_indice).dsdocumento||TO_CHAR(rw_crapdat.dtmvtolt,'MMRRRR')
                            ||',vlfatura:'||vr_tab_linarq(vr_indice).vlfatura
                            ||',vlminimo_pagamento:'||vr_tab_linarq(vr_indice).vlminimo_pagamento
                            ||',dtvencimento:'||vr_tab_linarq(vr_indice).dtvencimento
                            ||',nrconta_cartao:'||vr_tab_linarq(vr_indice).nrconta_cartao
                            ||',nmarquivo:'||vr_vet_nmarquiv(i)
                            ||',sequencia:'||vr_tab_linarq(vr_indice).nrsequencia;
                RAISE vr_exc_saida;
            END;
                    
            /* Gravar os lançamentos por cartão */
            BEGIN
              INSERT INTO tbcrd_lancamento_fatura
                  (idlancamento_fatura
                  ,idfatura
                  ,nrcpf_portador
                  ,nrcartao
                  ,dtlancamento
                  ,vllancamento
                  ,cdhistor)
              SELECT seq_crd_idlancamento_fatura.nextval
                    ,vr_idfatura 
                    ,pcr.nrcpftit
                    ,pcr.nrcrcard
                    ,rw_crapdat.dtmvtolt
                    ,DECODE( pcr.flgprcrd,1,vr_tab_linarq(vr_indice).vlfatura,0 )
                    ,1545
                FROM crawcrd pcr
               WHERE pcr.cdcooper = rw_crapcop_cdagebcb.cdcooper
                 AND pcr.nrcctitg = vr_tab_linarq(vr_indice).nrcctitg
                 AND pcr.nrdconta = vr_tab_crawcrd(vr_chv_cartao).nrdconta; 
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 26/07/2017 - Chamado 721285        
                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
                vr_dscritic := 'Erro ao inserir tbcrd_lancamento_fatura: '||SQLERRM;

                vr_dsparam := '.Cdcooper: '||rw_crapcop_cdagebcb.cdcooper
                            ||',nrcctitg:'||vr_tab_linarq(vr_indice).nrcctitg
                            ||',nrdconta:'||vr_tab_crawcrd(vr_chv_cartao).nrdconta
                            ||',dtlancamento:'||rw_crapdat.dtmvtolt
                            ||',cdhistor:'||vr_tab_linarq(vr_indice).nrconta_cartao;
                                
                RAISE vr_exc_saida;
            END;   
                    
            -- soma o valor computado para comparação posterior
            vr_vlcompdb := vr_vlcompdb + vr_tab_linarq(vr_indice).vlfatura;
                    
        END LOOP;           

        --Se não há trailler
        IF vr_flgtrail = 0 THEN
                  
          ROLLBACK;
                  
          --Buscar destinatario email
          vr_email_dest := gene0001.fn_param_sistema('CRED',0,'EMAIL_DESTINO_CRPS673');          

          --Assunto do e-mail
          vr_des_assunto := 'Falha na execução do CRPS637';
                  
          --Corpo do e-mail
          vr_conteudo := 'Arquivo incompleto: ' ||  vr_vet_nmarquiv(i);          
                  
          --Solicita o envio do e-mail
          GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper    --> Cooperativa conectada
                                    ,pr_cdprogra        => 'CRPS673'      --> Programa conectado
                                    ,pr_des_destino     => vr_email_dest  --> Um ou mais detinatários separados por ';' ou ','
                                    ,pr_des_assunto     => vr_des_assunto --> Assunto do e-mail
                                    ,pr_des_corpo       => vr_conteudo    --> Corpo (conteudo) do e-mail
                                    ,pr_des_anexo       => NULL           --> Um ou mais anexos separados por ';' ou ','
                                    ,pr_flg_remove_anex => 'N'            --> Remover os anexos passados
                                    ,pr_flg_remete_coop => 'N'            --> Se o envio será do e-mail da Cooperativa
                                    ,pr_des_nome_reply  => NULL           --> Nome para resposta ao e-mail
                                    ,pr_des_email_reply => NULL           --> Endereço para resposta ao e-mail
                                    ,pr_flg_enviar      => 'S'            --> Enviar o e-mail na hora
                                    ,pr_flg_log_batch    => 'N'           --> Incluir inf. no log
                                    ,pr_des_erro        => vr_dscritic);  --> Descricao Erro  
                                    
          -- Retorna nome do módulo logado - Chamado 721285 31/07/2017
          GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);
                  
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
                  
          EXIT;
                  
        END IF;
                
        -- Montar Comando para copiar o arquivo lido para o diretório recebidos do CONNECT
        vr_comando:= 'cp '|| vr_direto_connect || '/' || vr_vet_nmarquiv(i) ||
                     ' '  || vr_dsdireto || '/recebidos/ 2> /dev/null';
                                           
        -- Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);

        -- Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN        
          vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
          RAISE vr_exc_saida;
        END IF;
                                                      
        -- Montar Comando para mover o arquivo lido para o diretório salvar
        vr_comando:= 'mv '|| vr_direto_connect || '/' || vr_vet_nmarquiv(i) ||
                     ' /usr/coop/' || rw_crapcop.dsdircop || '/salvar/ 2> /dev/null';
                                           
        -- Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);
        -- Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN        
          vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
          RAISE vr_exc_saida;
        END IF;
                
        -- Apos processar o arquivo, deve realizar o commit,
        -- pois já moveu para a pasta recebidos
        COMMIT;
                                    
    END LOOP;            
              
    -- Apaga o arquivo pc_crps673.txt no unix
    vr_comando:= 'rm ' || vr_direto_connect || '/pc_crps673.txt 2> /dev/null';      
    -- Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                             ,pr_des_comando => vr_comando
                                             ,pr_typ_saida   => vr_typ_saida
                                             ,pr_des_saida   => vr_dscritic);
    IF vr_typ_saida = 'ERR' THEN
        RAISE vr_exc_saida;
    END IF; 
          		                                      
    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra); 
               
    -- Retorna nome do módulo logado - Chamado 721285 31/07/2017
    GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);

    COMMIT;
          
  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
        
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        -- Padronização do log - 26/07/2017 - Chamado 721285
        -- Envio centralizado de log de erro
        pc_log_batch ( 2 );
      END IF;
        
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);                               
      -- Efetuar commit
      COMMIT;

    WHEN vr_exc_saida THEN          

      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic, vr_dscritic);

      pr_dscritic := pr_dscritic || vr_dsparam;
      
      -- Efetuar rollback
      ROLLBACK;

    WHEN OTHERS THEN        
      -- No caso de erro de programa gravar tabela especifica de log - 26/07/2017 - Chamado 721285        
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;

      -- Efetuar rollback
      ROLLBACK;        
  END;        
END PC_CRPS673;
/
