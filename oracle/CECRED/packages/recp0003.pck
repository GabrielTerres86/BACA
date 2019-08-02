CREATE OR REPLACE PACKAGE CECRED.RECP0003 IS 
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RECP0003
  --  Sistema  : Rotinas referentes a importacao de arquivos CYBER de acordos de emprestimos
  --  Sigla    : RECP
  --  Autor    : Jean Michel Deschamps
  --  Data     : Outubro/2016.                   Ultima atualizacao: 11/10/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: N/A
  -- Objetivo  : Agrupar rotinas genericas refente a importacao de arquivos referente a acordos de emprestimos
  --
  -- Alteracoes:
  -- 
  ---------------------------------------------------------------------------------------------------------------

  -- Retorna valor bloqueado em acordos
  PROCEDURE pc_import_arq_acordo_job;
                                    
END RECP0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.RECP0003 IS
/*  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RECP0003
  --  Sistema  : Rotinas referentes a importacao de arquivos CYBER de acordos de emprestimos
  --  Sigla    : RECP
  --  Autor    : Jean Michel Deschamps
  --  Data     : Outubro/2016.                   Ultima atualizacao: 06/04/2018 
  -- 
  -- Dados referentes ao programa:
  --
  -- Frequencia: N/A
  -- Objetivo  : Agrupar rotinas genericas refente a importacao de arquivos referente a acordos de emprestimos
  --
  -- Alteracoes: 20/02/2017 - Alteracao para colocar msgs do log de JOB. (Jaison/James)
  --
  --             22/02/2017 - Alteracao para passar pr_nrparcel como zero. (Jaison/James)
  --
  --             06/03/2017 - Foi passado o UPDATE crapcyc para dentro do LOOP. (Jaison/James)
  --
  --             02/05/2017 - Remocao do SAVEPOINT. (Jaison/James)
  --
  --             03/05/2017 - Salvar registros por arquivo e desfazer acoes se aconteceu erro numa linha. (Jaison/James)

                 21/09/2017 - #756229 Setando pr_flgemail true nas rotinas pc_imp_arq_acordo_cancel e pc_imp_arq_acordo_quitado
                  quando ocorrer erro nos comandos de extração de zip, listagem dos arquivos extraídos e conversão 
                  txt para unix para que os responsáveis pelo negócio sejam avisados por e-mail (Carlos)

                 27/09/2017 - Ajuste para atender SM 3 do projeto 210.2 (Daniel)

                 08/12/2017 - Inclusão de chamada da npcb0002.pc_libera_sessao_sqlserver_npc
                              na procedure pc_imp_arq_acordo_cancel. (SD#791193 - AJFink)

  --             13/03/2018 - Chamado 806202 - ALterado update CRAPCYC para não atualizar motivos 2 e 7.

			     06/04/2018 - Alteração do cursor "cr_crapcyb" para considerar somente contratos marcados
							  com INDPAGAR = 'S' e considerar o contrato LC100 que não está na CRAPCYB.
															(Reginaldo - AMcom)

                 23/07/2018 - Quando é feito um acordo de cobrança pelo CYBER, o acordo é fechado com um valor específico.
                              Ao longo do pagamento deste acordo, podem incidir novos valores na conta,
                              como taxas de atraso ou juros de mora, por exemplo.
                              Quando o acordo é quitado, é feita uma verificação se o valor pago no acordo não foi
                              suficiente para pagar todo o saldo devedor da conta. Neste caso, é feito um lançamento
                              de abono (abatimento), para liquidar este saldo residual.
                              Para este abono/abatimento, atualmente, é feito um lançamento com o histórico 2181.
                              Alterado para que no momento de fazer o lançamento do abono,
                              verificar se a conta está em prejuízo.
                              Se estiver, ao invés de lançar com o histórico 2181, vamos usar o histórico 2723.
                             (Renato Cordeiro - AMcom)


            07/08/2018 - 9318:Pagamento de Emprestimo  Alterar a chamada para : 
                                                -pc_pagar_emprestimo_tr
                                                -pc_pagar_emprestimo_prejuizo
                                                -pc_pagar_emprestimo_folha    
                         da RECP0001 para EMPR999;      Rangel Decker (AMcom)                                                                                                                          
                         
            21/02/2019 - P450 - Ajuste na rotina "pc_imp_arq_acordo_quitado" para adequação do abono de prejuízo
                         com uso do novo histórico (2919) criado pela Contabilidade.                                                                                                                        
                         (Reginaldo/AMcom)
            
            08/03/2019 - P450 - Ajuste na rotina "pc_imp_arq_acordo_quitado" para debitar da conta transitória valor
                         pago (abonado) em contrato de empréstimo se a conta está em prejuízo.  
                         (Reginaldo/AMcom)                                                                                                                                   
                         
            09/05/2019 - P450 - Ajuste na procedure "pc_imp_arq_acordo_quitado" para não deixar saldo do prejuízo negativo ao lançar abono 
                         (Reginaldo/AMcom)    
                         
            17/07/2019 - PJ 450.2 - Ajuste na procedure na pc_imp_arq_acordo_quitado. Retirado chamada da 
                         PREJ0003.pc_gera_debt_cta_prj para contratos de empréstimos, pois o débito do prejuízo 
                         já é feito nas rotinas de empréstimos para conta em prejuízo (Marcelo/Amcom).
  ---------------------------------------------------------------------------------------------------------------*/

  vr_flgerlog BOOLEAN := FALSE;

  -- Controla log proc_batch, para apensa exibir qnd realmente processar informacao
  PROCEDURE pc_controla_log_batch(pr_cdcooper IN PLS_INTEGER
                                 ,pr_dstiplog IN VARCHAR2
                                 ,pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
  BEGIN

    --> Controlar geração de log de execução dos jobs
    BTCH0001.pc_log_exec_job( pr_cdcooper  => pr_cdcooper    --> Cooperativa
                             ,pr_cdprogra  => 'JOB_ACORDO_CYBER' --> Codigo do programa
                             ,pr_nomdojob  => 'JOB_ACORDO_CYBER' --> Nome do job
                             ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                             ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                             ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim

  END pc_controla_log_batch;

  -- Procedure para converter arquivos unix
  PROCEDURE pc_converte_arquivo_txt_unix (pr_cdcooper IN crapcop.cdcooper%TYPE      -- Codigo da Cooperativa
                                         ,pr_caminho  IN  VARCHAR2                  -- Diretorio dos Arquivos
                                         ,pr_pesq     IN  VARCHAR2                  -- Filtro dos Arquivos
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE     -- Codigo Erro
                                         ,pr_dscritic OUT crapcri.dscritic%TYPE) IS -- Descricao erro
    BEGIN
      DECLARE
        -- Variaveis Locais
        vr_index    INTEGER;
        vr_cdcritic INTEGER;
        vr_dscritic VARCHAR2(4000);
        
        vr_listadir VARCHAR2(2000);
        vr_nmarqsem VARCHAR2(100);
        -- Tabela arquivos
        vr_tab_arqtmp GENE0002.typ_split;

        vr_exc_saida EXCEPTION;

        vr_typ_saida VARCHAR2(10);
        vr_comando   VARCHAR2(4000);
        
      BEGIN
        
        vr_cdcritic := 0;
        vr_dscritic := '';
        
        -- Vamos ler todos os arquivos .txt extraido do arquivo .zip do dia
        gene0001.pc_lista_arquivos(pr_path     => pr_caminho
                                  ,pr_pesq     => pr_pesq || '.txt'
                                  ,pr_listarq  => vr_listadir
                                  ,pr_des_erro => vr_dscritic);

        -- Se ocorrer erro ao recuperar lista de arquivos registra no log
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          -- Log de erro de execucao
          pc_controla_log_batch(pr_cdcooper => pr_cdcooper
                               ,pr_dstiplog => 'E'
                               ,pr_dscritic => vr_dscritic);
        END IF;

        -- Carregar a lista de arquivos txt na temp table
        vr_tab_arqtmp:= gene0002.fn_quebra_string(pr_string => vr_listadir);

        -- Converte todos os arquivos para formato Unix
        vr_index:= vr_tab_arqtmp.FIRST;
   
        WHILE vr_index IS NOT NULL LOOP
         -- Retirar a extensao do nome do arquivo
         vr_nmarqsem:= substr(vr_tab_arqtmp(vr_index),1,instr(vr_tab_arqtmp(vr_index),'.')-1);

         -- Converte o arquivo para formato unix
         vr_comando:= 'ux2dos '||pr_caminho||'/'||vr_tab_arqtmp(vr_index)||' > '||
                                 pr_caminho||'/TMP_'||vr_nmarqsem||'.txt 2>/dev/null';

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

         -- Converte o arquivo para formato unix */
         vr_comando:= 'mv '||pr_caminho||'/TMP_'||vr_tab_arqtmp(vr_index)|| ' ' ||
                      pr_caminho||'/'||vr_nmarqsem||'.txt 2>/dev/null';

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

         -- Proximo registro
         vr_index:= vr_tab_arqtmp.NEXT(vr_index);
             
       END LOOP;

     EXCEPTION
       WHEN vr_exc_saida THEN
         pr_cdcritic := vr_cdcritic;
         
         IF pr_cdcritic > 0 THEN
           pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
         ELSE
           pr_dscritic := vr_dscritic;
         END IF;

       WHEN OTHERS THEN
         pr_cdcritic := 0;
         pr_dscritic:= 'Erro ao converter arquivo para Dos no RECP0003.pc_converte_arquivo_txt_unix '||SQLERRM;
     END;
   END pc_converte_arquivo_txt_unix;
  
  -- Importa arquivo referente a acordos cancelados
  PROCEDURE pc_imp_arq_acordo_cancel(pr_flgemail OUT BOOLEAN
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
    
      -- Variaveis de Erros
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic crapcri.dscritic%TYPE := '';
      vr_dsdetcri crapcri.dscritic%TYPE := '';

      -- Variaveis Locais
      vr_des_erro VARCHAR2(100);
      vr_nmarqtxt VARCHAR2(200)  := '';
      vr_nmtmpzip VARCHAR2(4000) := '';
      vr_endarqui VARCHAR2(4000) := '';
      vr_nmtmparq VARCHAR2(4000) := '';
      vr_nmarqzip VARCHAR2(4000) := '';
      vr_setlinha VARCHAR2(4000) := '';
      vr_nrindice INTEGER;
      vr_idx_txt  INTEGER;
      vr_nrlinha  INTEGER := 0;
      vr_nracordo NUMBER;
      vr_dtcancel DATE;

      vr_cdcooper crapcop.cdcooper%TYPE := 3;

      --Variaveis Comando Unix
      vr_typ_saida VARCHAR2(10);
      vr_comando   VARCHAR2(4000);
      vr_listadir  VARCHAR2(4000);
      vr_endarqtxt VARCHAR2(4000);
      vr_input_file  utl_file.file_type;

      -- Tabela para armazenar arquivos lidos
      vr_tab_arqzip gene0002.typ_split;
      vr_tab_arqtxt gene0002.typ_split;

      -- Buscar situacao do acordo
      CURSOR cr_tbacordo(pr_nracordo tbrecup_acordo.nracordo%TYPE) IS
         SELECT aco.cdsituacao
          FROM tbrecup_acordo aco
          WHERE nracordo = pr_nracordo;
      rw_tbacordo cr_tbacordo%ROWTYPE;

    BEGIN

      pr_flgemail := FALSE; 

      -- Busca do diretorio micros da cooperativa
      vr_endarqui:= gene0001.fn_diretorio(pr_tpdireto => 'M' -- /micros/coop
                                         ,pr_cdcooper => vr_cdcooper
                                         ,pr_nmsubdir => '/cyber/recebe/');
      -- Arquivos que serao procurados
      vr_nmtmpzip:= '%_queb_acordo_out.zip';

      -- Vamos ler todos os arquivos .zip
      gene0001.pc_lista_arquivos(pr_path    => vr_endarqui
                                ,pr_pesq     => vr_nmtmpzip
                                ,pr_listarq  => vr_listadir
                                ,pr_des_erro => vr_dscritic);

      
      -- Se ocorrer erro ao recuperar lista de arquivos registra no log
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Log de erro de execucao
        pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                             ,pr_dstiplog => 'E'
                             ,pr_dscritic => vr_dscritic);
      END IF;

      -- Carregar a lista de arquivos na temp table
      vr_tab_arqzip := gene0002.fn_quebra_string(pr_string => vr_listadir);

      -- Buscar Primeiro arquivo da temp table
      vr_nrindice:= vr_tab_arqzip.FIRST;
      
      -- Processar os arquivos lidos
      WHILE vr_nrindice IS NOT NULL LOOP
        -- Nome Arquivo zip
        vr_nmarqzip:= vr_tab_arqzip(vr_nrindice);

        -- Envio centralizado de log de erro
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' --> ' || 'INTEGRANDO ARQUIVO ' || vr_nmarqzip);

        -- Nome do arquivo sem extensao
        vr_nmtmparq:= SUBSTR(vr_nmarqzip,1,LENGTH(vr_nmarqzip)-4);

        -- Montar Comando para eliminar arquivos do diretorio
        vr_comando := 'rm '||vr_endarqui||'/'||vr_nmtmparq||'/*.txt 1> /dev/null';

        -- Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);

        -- Remover o diretorio caso exista
        vr_comando:= 'rmdir ' || vr_endarqui || '/' || vr_nmtmparq || ' 1> /dev/null';

        -- Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);

        -- Criar o diretorio com o nome do arquivo
        vr_comando:= 'mkdir '||vr_endarqui||'/'||vr_nmtmparq||' 1> /dev/null';

        -- Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);

        -- Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic:= 'Nao foi possivel executar comando unix. ' || vr_comando || ' - ' || vr_dscritic;
          -- Log de erro de execucao
          pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                               ,pr_dstiplog => 'E'
                               ,pr_dscritic => vr_dscritic);
          CONTINUE;
        END IF;

        -- Executar Extracao do arquivo zip
        gene0002.pc_zipcecred (pr_cdcooper => vr_cdcooper
                              ,pr_tpfuncao => 'E'
                              ,pr_dsorigem => vr_endarqui||'/'||vr_nmarqzip
                              ,pr_dsdestin => vr_endarqui||'/'||vr_nmtmparq
                              ,pr_dspasswd => NULL
                              ,pr_flsilent => 'S'
                              ,pr_des_erro => vr_dscritic);
      	
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          -- Log de erro de execucao
          pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                               ,pr_dstiplog => 'E'
                               ,pr_dscritic => vr_dscritic);
          pr_flgemail := TRUE;
          CONTINUE;
        END IF;

        -- Lista todos os arquivos .txt do diretorio criado
        vr_endarqtxt:= vr_endarqui || '/' || vr_nmtmparq;

        -- Buscar todos os arquivos extraidos na nova pasta
        gene0001.pc_lista_arquivos(pr_path     => vr_endarqtxt
                                  ,pr_pesq     => '%_queb_acordo_out.txt'
                                  ,pr_listarq  => vr_listadir
                                  ,pr_des_erro => vr_dscritic);

        -- Se ocorrer erro ao recuperar lista de arquivos registra no log
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          -- Log de erro de execucao
          pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                               ,pr_dstiplog => 'E'
                               ,pr_dscritic => vr_dscritic);
          pr_flgemail := TRUE;
          CONTINUE;
        END IF;

        IF vr_listadir IS NULL THEN
          CONTINUE;
        END IF;

        -- Converte cada arquivo texto para formato UNIX
        pc_converte_arquivo_txt_unix (pr_cdcooper => vr_cdcooper
                                     ,pr_caminho  => vr_endarqtxt        -- Diretorio Arquivos
                                     ,pr_pesq     => '%_queb_acordo_out' -- Filtro Arquivos
                                     ,pr_cdcritic => vr_cdcritic         -- Codigo Erro
                                     ,pr_dscritic => vr_dscritic);       -- Descricao erro
        -- Se ocorreu erro
        IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Log de erro de execucao
          pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                               ,pr_dstiplog => 'E'
                               ,pr_dscritic => vr_dscritic);
          pr_flgemail := TRUE;
          CONTINUE;
        END IF;

        -- Carregar a lista de arquivos na temp table
        vr_tab_arqtxt:= gene0002.fn_quebra_string(pr_string => vr_listadir);

        -- Se possuir arquivos no diretorio
        IF vr_tab_arqtxt.COUNT > 0 THEN

          --Selecionar primeiro arquivo
           vr_idx_txt:= vr_tab_arqtxt.FIRST;
           --Percorrer todos os arquivos lidos
           WHILE vr_idx_txt IS NOT NULL LOOP

             --Nome do arquivo
             vr_nmarqtxt:= vr_tab_arqtxt(vr_idx_txt);

             --Abrir o arquivo lido
             gene0001.pc_abre_arquivo(pr_nmdireto => vr_endarqtxt   --> Diretório do arquivo
                                     ,pr_nmarquiv => vr_nmarqtxt    --> Nome do arquivo
                                     ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                                     ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                     ,pr_des_erro => vr_des_erro);  --> Erro

             IF vr_des_erro <> 'OK' THEN
               -- Log de erro de execucao
               pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                                    ,pr_dstiplog => 'E'
                                    ,pr_dscritic => 'Erro ao abrir arquivo: ' || vr_nmarqtxt);

               -- Fechar o arquivo
               GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;  

               -- Buscar proximo arquivo
               vr_idx_txt:= vr_tab_arqtxt.NEXT(vr_idx_txt);
               CONTINUE;
             END IF;

             vr_nrlinha := 0;

             LOOP
               -- Verificar se o arquivo está aberto
               IF utl_file.IS_OPEN(vr_input_file) THEN
                 BEGIN
                   -- Le os dados do arquivo e coloca na variavel vr_setlinha
                   gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                               ,pr_des_text => vr_setlinha); --> Texto lido

                   vr_nrlinha := vr_nrlinha + 1;
                 EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                     -- Fechar o arquivo
                     GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
                     -- Fim do arquivo
                     EXIT;
                 END;
                 
                 IF SUBSTR(vr_setlinha,1,1) = 'H' AND vr_nrlinha = 1 THEN
                   CONTINUE;
                 ELSIF SUBSTR(vr_setlinha,1,1) = 'H' AND vr_nrlinha > 1 THEN
                   -- Header errado
                   -- Log de erro de execucao
                   pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                                        ,pr_dstiplog => 'E'
                                        ,pr_dscritic => 'ARQUIVO INCONSISTENTE');

                   pr_flgemail := TRUE;
                   ROLLBACK;
                   -- Fim do arquivo
                   EXIT;
                 ELSIF SUBSTR(vr_setlinha,1,1) = 'T' THEN
                   CONTINUE;                                          
                 END IF;
                 
                 vr_nracordo := TO_NUMBER(SUBSTR(vr_setlinha,29,13));
                 vr_dtcancel := TRUNC(SYSDATE);
                 
                 OPEN cr_tbacordo(pr_nracordo => vr_nracordo);
                 FETCH cr_tbacordo INTO rw_tbacordo;
                 IF cr_tbacordo%NOTFOUND THEN
                   CLOSE cr_tbacordo;
                   CONTINUE;
                 ELSE
                   CLOSE cr_tbacordo;
                 END IF;
                 
                  -- Acordo Quitado e Cancelado
                 IF rw_tbacordo.cdsituacao IN(2,3) THEN
                   CONTINUE;
                 END IF;              
                 
                 -- Procedure responsavel para cancelar o acordo    
                 RECP0002.pc_cancelar_acordo(pr_nracordo => vr_nracordo
                                            ,pr_dtcancel => vr_dtcancel
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_dsdetcri => vr_dsdetcri);

                 IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
                   -- Log de erro de execucao
                   pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                                        ,pr_dstiplog => 'E'
                                        ,pr_dscritic => 'Acordo: ' || vr_nracordo || 
                                                        '. Critica: ' || vr_dscritic || 
                                                        '. Detalhe: '||vr_dsdetcri);
                   pr_flgemail := TRUE;
                   ROLLBACK; -- Desfaz acoes
                   EXIT; -- Sai do loop de linhas
                 END IF;

               END IF; --Arquivo aberto
             END LOOP;

             COMMIT; -- Salva os dados por arquivo
             npcb0002.pc_libera_sessao_sqlserver_npc('RECP0003_1');

             -- Verificar se o arquivo está aberto
             IF utl_file.IS_OPEN(vr_input_file) THEN
               -- Fechar o arquivo
               GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
             END IF;
             --Buscar proximo arquivo
             vr_idx_txt:= vr_tab_arqtxt.NEXT(vr_idx_txt);
             
           END LOOP;
           
        END IF;
        
        -- Renomear os arquivos .zip que foram processados
        vr_comando:= 'mv '||vr_endarqui||'/'||vr_nmtmparq||'.zip '||
                    vr_endarqui||'/'||vr_nmtmparq||'_processado.pro 1> /dev/null';
        
        -- Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);
        
        -- Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic:= 'Nao foi possivel executar comando unix. ' || vr_comando;
          -- Log de erro de execucao
          pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                               ,pr_dstiplog => 'E'
                               ,pr_dscritic => vr_dscritic);
        END IF;

        -- Remove o diretorio criado
        vr_comando:= 'rm -R '||vr_endarqui||'/'||vr_nmtmparq;

        -- Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);
        
        -- Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic:= 'Nao foi possivel executar comando unix. ' || vr_comando || '. Erro: ' || vr_dscritic;
          -- Log de erro de execucao
          pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                               ,pr_dstiplog => 'E'
                               ,pr_dscritic => vr_dscritic);
        END IF;                

        -- Envio centralizado de log de erro
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratato
                                   pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' --> ' ||
                                                   'ARQUIVO INTEGRADO: ' || vr_nmarqzip); 

        -- Proximo registro
        vr_nrindice:= vr_tab_arqzip.NEXT(vr_nrindice);

      END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na RECP0003.PC_IMP_ARQ_ACORDO_CANCEL: ' || SQLERRM;
      pr_flgemail := TRUE;
      -- Log de erro de execucao
      pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                           ,pr_dstiplog => 'E'
                           ,pr_dscritic => pr_dscritic);
      ROLLBACK;
      npcb0002.pc_libera_sessao_sqlserver_npc('RECP0003_2');
  END pc_imp_arq_acordo_cancel;

  -- Importa arquivo referente a acordos quitados
  PROCEDURE pc_imp_arq_acordo_quitado(pr_flgemail OUT BOOLEAN
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
    
      -- Variaveis de Erros
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic crapcri.dscritic%TYPE := '';

      -- Variaveis Locais
      vr_des_erro VARCHAR2(100);
      vr_nmarqtxt VARCHAR2(200)  := '';
      vr_nmtmpzip VARCHAR2(4000) := '';
      vr_endarqui VARCHAR2(4000) := '';
      vr_nmtmparq VARCHAR2(4000) := '';
      vr_nmarqzip VARCHAR2(4000) := '';
      vr_setlinha VARCHAR2(4000) := '';
      vr_nrindice INTEGER;
      vr_idx_txt  INTEGER;
      vr_nrlinha  INTEGER := 0;

      vr_cdcooper crapcop.cdcooper%TYPE := 3;

      -- Variavel de retorno
      vr_des_reto  VARCHAR2(100);

      --Variaveis Comando Unix
      vr_typ_saida VARCHAR2(10);
      vr_comando   VARCHAR2(4000);
      vr_listadir  VARCHAR2(4000);
      vr_endarqtxt VARCHAR2(4000);
      vr_input_file  utl_file.file_type;

      -- Tabela para armazenar arquivos lidos
      vr_tab_arqzip gene0002.typ_split;
      vr_tab_arqtxt gene0002.typ_split;

      vr_vlsddisp NUMBER(25,2) := 0; -- Saldo disponivel
      vr_vltotpag NUMBER(25,2) := 0; -- Valor Total de Pagamento
      vr_vllancam NUMBER(25,2) := 0; -- Saldo disponivel
      vr_vllanacc NUMBER(25,2) := 0; -- Valor do abatimento em conta corrente
      vr_vllanact NUMBER(25,2) := 0; -- Valor do abatimento em contratos (emprésitmo, desc. de título)
      vr_vlpagmto NUMBER;
      vr_idvlrmin NUMBER(25,2) := 0; -- Indicador de valor Minimo
      vr_cdoperad crapope.cdoperad%TYPE := '1';
      vr_nmdatela craptel.nmdatela%TYPE := 'JOB';
      vr_nracordo NUMBER;
      vr_dtquitac DATE;

      vr_cdhistor craplcm.cdhistor%type;
			
			vr_vlrabono tbcc_prejuizo.vlrabono%TYPE;

      -- Consulta contratos em acordo
      CURSOR cr_crapcyb(pr_nracordo tbrecup_acordo.nracordo%TYPE) IS
			  WITH acordo_contrato AS (
				     SELECT a.cdcooper
						  , a.nracordo
              , a.nrdconta
              , c.nrctremp
              , c.cdorigem
              , c.indpagar
           FROM tbrecup_acordo a
              , tbrecup_acordo_contrato c
         WHERE a.nracordo = pr_nracordo
           AND c.nracordo = a.nracordo 
					 AND c.indpagar = 'S'
				)
        SELECT acc.nracordo
              ,acc.cdcooper
              ,acc.nrdconta
              ,acc.cdorigem
              ,acc.nrctremp
          FROM acordo_contrato acc,
               crapcyb cyb
         WHERE cyb.cdcooper(+) = acc.cdcooper
           AND cyb.nrdconta(+) = acc.nrdconta
           AND cyb.nrctremp(+) = acc.nrctremp
           AND cyb.cdorigem(+) = acc.cdorigem          
      ORDER BY cyb.cdorigem;
      rw_crapcyb cr_crapcyb%ROWTYPE;

      -- Consulta PA e limites de credito do cooperado
      CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                       ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT ass.cdagenci
              ,ass.vllimcre
              ,ass.cdcooper
              ,ass.nrdconta
              ,ass.inprejuz
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
     
      -- Consulta cooperativas
      CURSOR cr_crapcop IS
        SELECT cop.cdcooper
          FROM crapcop cop
         WHERE cop.flgativo = 1;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Consulta valor bloqueado pelo acordo
      CURSOR cr_nracordo(pr_nracordo tbrecup_acordo.nracordo%TYPE)IS
        SELECT aco.vlbloqueado
              ,aco.cdcooper
              ,aco.nrdconta
              ,aco.nracordo
         FROM tbrecup_acordo aco
        WHERE aco.nracordo = pr_nracordo;
      rw_nracordo cr_nracordo%ROWTYPE;  

      -- Consulta valor bloqueado pelo acordo
      CURSOR cr_crapepr(pr_cdcooper crapepr.cdcooper%TYPE
                       ,pr_nrdconta crapepr.nrdconta%TYPE
                       ,pr_nrctremp crapepr.nrctremp%TYPE)IS
        SELECT epr.cdcooper
              ,epr.nrdconta
              ,epr.nrctremp
              ,epr.inliquid
              ,epr.inprejuz
              ,epr.flgpagto
              ,epr.tpemprst
              ,epr.vlsdprej
              ,epr.vlprejuz
              ,epr.vlsprjat
              ,epr.vlpreemp
              ,epr.vlttmupr
              ,epr.vlpgmupr
              ,epr.vlttjmpr
              ,epr.vlpgjmpr
              ,epr.cdlcremp
              ,epr.qtprepag
              ,epr.vlsdeved
              ,epr.vlsdevat
              ,epr.vljuracu
              ,epr.txjuremp
              ,epr.dtultpag
              ,epr.vliofcpl
							,epr.dtmvtolt
							,epr.vlemprst
							,epr.txmensal
							,epr.dtdpagto
							,epr.vlsprojt
							,epr.qttolatr
							,wpr.dtdpagto wdtdpagto
							,wpr.txmensal wtxmensal
         FROM crapepr epr
				     ,crawepr wpr
        WHERE epr.cdcooper = wpr.cdcooper
				  AND epr.nrdconta = wpr.nrdconta
					AND epr.nrctremp = wpr.nrctremp
				  AND epr.cdcooper = pr_cdcooper
          AND epr.nrdconta = pr_nrdconta
          AND epr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;      

      -- Cursor genérico de data
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      TYPE typ_tab_crapdat IS
      TABLE OF btch0001.cr_crapdat%ROWTYPE
		  INDEX BY BINARY_INTEGER;
            
      -- Tabela de Saldos
      vr_tab_saldos EXTR0001.typ_tab_saldos;
      vr_tab_crapdat typ_tab_crapdat;
      vr_tab_erro GENE0001.typ_tab_erro;
      vr_index_saldo INTEGER;

    BEGIN

      FOR rw_crapcop IN cr_crapcop LOOP
        OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
        
        FETCH btch0001.cr_crapdat INTO rw_crapdat;
        
        vr_tab_crapdat(rw_crapcop.cdcooper) := rw_crapdat;

        CLOSE btch0001.cr_crapdat;

      END LOOP;
  
      pr_flgemail := FALSE; 

      -- Busca do diretorio micros da cooperativa
      vr_endarqui:= gene0001.fn_diretorio(pr_tpdireto => 'M' -- /micros/coop
                                         ,pr_cdcooper => vr_cdcooper
                                         ,pr_nmsubdir => '/cyber/recebe/');
      -- Arquivos que serao procurados
      vr_nmtmpzip:= '%_quit_acordo_out.zip';

      -- Vamos ler todos os arquivos .zip
      gene0001.pc_lista_arquivos(pr_path    => vr_endarqui
                                ,pr_pesq     => vr_nmtmpzip
                                ,pr_listarq  => vr_listadir
                                ,pr_des_erro => vr_dscritic);
      
      -- Se ocorrer erro ao recuperar lista de arquivos registra no log
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Log de erro de execucao
        pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                             ,pr_dstiplog => 'E'
                             ,pr_dscritic => vr_dscritic);
      END IF;

      -- Carregar a lista de arquivos na temp table
      vr_tab_arqzip := gene0002.fn_quebra_string(pr_string => vr_listadir);

      -- Buscar Primeiro arquivo da temp table
      vr_nrindice:= vr_tab_arqzip.FIRST;
      
      -- Processar os arquivos lidos
      WHILE vr_nrindice IS NOT NULL LOOP
        -- Nome Arquivo zip
        vr_nmarqzip:= vr_tab_arqzip(vr_nrindice);

        -- Envio centralizado de log de erro
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' --> ' || 'INTEGRANDO ARQUIVO ' || vr_nmarqzip);

        -- Nome do arquivo sem extensao
        vr_nmtmparq:= SUBSTR(vr_nmarqzip,1,LENGTH(vr_nmarqzip)-4);

        -- Montar Comando para eliminar arquivos do diretorio
        vr_comando := 'rm '||vr_endarqui||'/'||vr_nmtmparq||'/*.txt 1> /dev/null';

        -- Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);

        -- Remover o diretorio caso exista
        vr_comando := 'rmdir ' || vr_endarqui || '/' || vr_nmtmparq || ' 1> /dev/null';

        -- Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);

        -- Criar o diretorio com o nome do arquivo
        vr_comando:= 'mkdir '||vr_endarqui||'/'||vr_nmtmparq||' 1> /dev/null';

        -- Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);

        -- Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic:= 'Nao foi possivel executar comando unix. ' || vr_comando || ' - ' || vr_dscritic;
          -- Log de erro de execucao
          pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                               ,pr_dstiplog => 'E'
                               ,pr_dscritic => vr_dscritic);
          CONTINUE;
        END IF;

        -- Executar Extracao do arquivo zip
        gene0002.pc_zipcecred (pr_cdcooper => vr_cdcooper
                              ,pr_tpfuncao => 'E'
                              ,pr_dsorigem => vr_endarqui||'/'||vr_nmarqzip
                              ,pr_dsdestin => vr_endarqui||'/'||vr_nmtmparq
                              ,pr_dspasswd => NULL
                              ,pr_flsilent => 'S'
                              ,pr_des_erro => vr_dscritic);
      	
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          -- Log de erro de execucao
          pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                               ,pr_dstiplog => 'E'
                               ,pr_dscritic => vr_dscritic);
          pr_flgemail := TRUE;
          CONTINUE;
        END IF;

        -- Lista todos os arquivos .txt do diretorio criado
        vr_endarqtxt := vr_endarqui || '/' || vr_nmtmparq;

        -- Buscar todos os arquivos extraidos na nova pasta
        gene0001.pc_lista_arquivos(pr_path     => vr_endarqtxt
                                  ,pr_pesq     => '%_quit_acordo_out.txt'
                                  ,pr_listarq  => vr_listadir
                                  ,pr_des_erro => vr_dscritic);

        -- Se ocorrer erro ao recuperar lista de arquivos registra no log
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          -- Log de erro de execucao
          pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                               ,pr_dstiplog => 'E'
                               ,pr_dscritic => vr_dscritic);
          pr_flgemail := TRUE;
          CONTINUE;
        END IF;

        IF vr_listadir IS NULL THEN
          CONTINUE;
        END IF;

        -- Converte cada arquivo texto para formato UNIX
        pc_converte_arquivo_txt_unix (pr_cdcooper => vr_cdcooper
                                     ,pr_caminho  => vr_endarqtxt        -- Diretorio Arquivos
                                     ,pr_pesq     => '%_quit_acordo_out' -- Filtro Arquivos
                                     ,pr_cdcritic => vr_cdcritic         -- Indicador Erro
                                     ,pr_dscritic => vr_dscritic);       -- Descricao erro
        -- Se ocorreu erro
        IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Log de erro de execucao
          pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                               ,pr_dstiplog => 'E'
                               ,pr_dscritic => vr_dscritic);
          pr_flgemail := TRUE;
          CONTINUE;
        END IF;

        -- Carregar a lista de arquivos na temp table
        vr_tab_arqtxt:= gene0002.fn_quebra_string(pr_string => vr_listadir);

        --Se possuir arquivos no diretorio
        IF vr_tab_arqtxt.COUNT > 0 THEN

          --Selecionar primeiro arquivo
           vr_idx_txt:= vr_tab_arqtxt.FIRST;
           --Percorrer todos os arquivos lidos
           WHILE vr_idx_txt IS NOT NULL LOOP

             --Nome do arquivo
             vr_nmarqtxt:= vr_tab_arqtxt(vr_idx_txt);

             --Abrir o arquivo lido
             gene0001.pc_abre_arquivo(pr_nmdireto => vr_endarqtxt   --> Diretório do arquivo
                                     ,pr_nmarquiv => vr_nmarqtxt    --> Nome do arquivo
                                     ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                                     ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                     ,pr_des_erro => vr_des_erro);  --> Erro

             IF vr_des_erro <> 'OK' THEN
               -- Log de erro de execucao
               pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                                    ,pr_dstiplog => 'E'
                                    ,pr_dscritic => 'Erro ao abrir arquivo: ' || vr_nmarqtxt);
                                         
               -- Verificar se o arquivo está aberto
               IF utl_file.IS_OPEN(vr_input_file) THEN
                 -- Fechar o arquivo
                 GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
               END IF;

               --Buscar proximo arquivo
               vr_idx_txt:= vr_tab_arqtxt.NEXT(vr_idx_txt);
               CONTINUE;
             END IF;

             vr_nrlinha := 0;
             <<LEITURA_TXT>>
             LOOP
               --Verificar se o arquivo está aberto
               IF utl_file.IS_OPEN(vr_input_file) THEN
                 BEGIN
                   -- Le os dados do arquivo e coloca na variavel vr_setlinha
                   gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                               ,pr_des_text => vr_setlinha); --> Texto lido

                   vr_nrlinha := vr_nrlinha + 1;
                 EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                     -- Fechar o arquivo
                     GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
                     --Fim do arquivo
                     EXIT;
                 END;
                 
                 IF SUBSTR(vr_setlinha,1,1) = 'H' AND vr_nrlinha = 1 THEN
                   CONTINUE;
                 ELSIF SUBSTR(vr_setlinha,1,1) = 'H' AND vr_nrlinha > 1 THEN
                   -- Header errado
                   -- Log de erro de execucao
                   pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                                        ,pr_dstiplog => 'E'
                                        ,pr_dscritic => 'Arquivo: ' || vr_nmarqtxt || ' ' || 'ARQUIVO INCONSISTENTE');
                   --Fim do arquivo
                   pr_flgemail := TRUE;
                   ROLLBACK;
                   EXIT LEITURA_TXT;
                 ELSIF SUBSTR(vr_setlinha,1,1) = 'T' THEN
                   CONTINUE;                                          
                 END IF;

                 vr_vllanacc := 0;
                 vr_vllanact := 0;
                 vr_nracordo := TO_NUMBER(SUBSTR(vr_setlinha,29,13));
                 vr_dtquitac := TRUNC(SYSDATE);

                 FOR rw_crapcyb IN cr_crapcyb(pr_nracordo => vr_nracordo) LOOP
                   
                   OPEN cr_crapass(pr_cdcooper => rw_crapcyb.cdcooper
                                  ,pr_nrdconta => rw_crapcyb.nrdconta);

                   FETCH cr_crapass INTO rw_crapass;
                     
                   CLOSE cr_crapass;
  
                   -- Estouro de Conta
                   IF rw_crapcyb.cdorigem IN (1) THEN 
                     --Limpar tabela saldos
                     vr_tab_saldos.DELETE;
                    
                     -- Saldo  disponivel
                     vr_vlsddisp := 0;

                     --Obter Saldo do Dia
                     EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => rw_crapcyb.cdcooper
                                                ,pr_rw_crapdat => vr_tab_crapdat(rw_crapcyb.cdcooper)
                                                ,pr_cdagenci   => rw_crapass.cdagenci
                                                ,pr_nrdcaixa   => 100
                                                ,pr_cdoperad   => vr_cdoperad
                                                ,pr_nrdconta   => rw_crapcyb.nrdconta
                                                ,pr_vllimcre   => rw_crapass.vllimcre
                                                ,pr_dtrefere   => vr_tab_crapdat(rw_crapcyb.cdcooper).dtmvtolt
                                                ,pr_des_reto   => vr_des_erro
                                                ,pr_tab_sald   => vr_tab_saldos
                                                ,pr_tipo_busca => 'A'
                                                ,pr_tab_erro   => vr_tab_erro);

                     IF vr_des_erro <> 'OK' THEN
                       vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                       vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                       -- Log de erro de execucao
                       pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                                            ,pr_dstiplog => 'E'
                                            ,pr_dscritic => 'Arquivo: ' || vr_nmarqtxt || ' ' || vr_dscritic);
                       pr_flgemail := TRUE;
                       ROLLBACK; -- Desfaz acoes
                       EXIT LEITURA_TXT;
                     END IF;

                     --Buscar Indice
                     vr_index_saldo := vr_tab_saldos.FIRST;
                     IF vr_index_saldo IS NOT NULL THEN
                       -- Saldo Disponivel na conta corrente
                       vr_vlsddisp := NVL(vr_tab_saldos(vr_index_saldo).vlsddisp, 0);
                     END IF;

                     -- Armazenar valor para ser lancado no final como ajuste contabil
                     -- Somente deverá conter o valor para zerar o estouro de conta.
                     IF vr_vlsddisp < 0 THEN        
                       RECP0001.pc_pagar_contrato_conta(pr_cdcooper => rw_crapcyb.cdcooper
                                                       ,pr_nrdconta => rw_crapcyb.nrdconta
                                                       ,pr_cdagenci => rw_crapass.cdagenci
                                                       ,pr_crapdat  => vr_tab_crapdat(rw_crapcyb.cdcooper)
                                                       ,pr_cdoperad => vr_cdoperad
                                                       ,pr_nracordo => rw_crapcyb.nracordo
                                                       ,pr_vlsddisp => vr_vlsddisp
                                                       ,pr_vlparcel => ABS(vr_vlsddisp)
                                                       ,pr_vltotpag => vr_vltotpag
                                                       ,pr_cdcritic => vr_cdcritic
                                                       ,pr_dscritic => vr_dscritic);
                                                       
                       IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN

                         IF NVL(vr_cdcritic,0) > 0 THEN
                           vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                         END IF;
                         -- Log de erro de execucao
                         pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                                              ,pr_dstiplog => 'E'
                                              ,pr_dscritic => 'Arquivo: ' || vr_nmarqtxt || ' ' || vr_dscritic);
                         pr_flgemail := TRUE;
                         ROLLBACK; -- Desfaz acoes
                         EXIT LEITURA_TXT;
                       END IF;

                       vr_vllanacc := NVL(vr_vllanacc,0) + NVL(ABS(vr_vltotpag),0);  -- Valor para lancto de abatimento na C/C (Reginaldo/AMcom - P450)
                       
                     END IF;

                   ELSIF rw_crapcyb.cdorigem IN (2,3) THEN
                     
                     OPEN cr_crapepr(pr_cdcooper => rw_crapcyb.cdcooper
                                    ,pr_nrdconta => rw_crapcyb.nrdconta
                                    ,pr_nrctremp => rw_crapcyb.nrctremp);

                     FETCH cr_crapepr INTO rw_crapepr;

                     IF cr_crapepr%NOTFOUND THEN
                       CLOSE cr_crapepr;
                       
                       -- Erro
                       vr_dscritic := 'Contrato Num. ' || GENE0002.fn_mask_contrato(rw_crapcyb.nrctremp) ||
                                      ' nao encontrado. Conta: ' || GENE0002.fn_mask_conta(rw_crapcyb.nrdconta) ||
                                      ', Cooperativa: ' || TO_CHAR(rw_crapcyb.cdcooper);

                       -- Log de erro de execucao
                       pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                                            ,pr_dstiplog => 'E'
                                            ,pr_dscritic => 'Arquivo: ' || vr_nmarqtxt || ' ' || vr_dscritic);
                       pr_flgemail := TRUE;
                       ROLLBACK; -- Desfaz acoes
                       EXIT LEITURA_TXT;
                     ELSE
                       CLOSE cr_crapepr;
                     END IF;

                     -- Verificar se o contrato já está LIQUIDADO   OU
                     -- Se o contrato de PREJUIZO já foi TOTALMENTE PAGO
                     IF (rw_crapepr.inliquid = 1 AND rw_crapepr.inprejuz = 0) OR 
                        (rw_crapepr.inprejuz = 1 AND rw_crapepr.vlsdprej <= 0) THEN
                       -- Proximo Contrato
                       CONTINUE;
                     END IF;

                     -- Condicao para verificar se o contrato de emprestimo é de prejuizo
                     IF rw_crapepr.inprejuz = 1 THEN
                        
                       -- Realizar a chamada da rotina para pagamento de prejuizo
                       EMPR9999.pc_pagar_emprestimo_prejuizo(pr_cdcooper => rw_crapepr.cdcooper
                                                            ,pr_nrdconta => rw_crapepr.nrdconta         
                                                            ,pr_cdagenci => rw_crapass.cdagenci         
                                                            ,pr_crapdat  => vr_tab_crapdat(rw_crapepr.cdcooper)
                                                            ,pr_nrctremp => rw_crapepr.nrctremp 
                                                            ,pr_tpemprst => rw_crapepr.tpemprst
                                                            ,pr_vlprejuz => rw_crapepr.vlprejuz 
                                                            ,pr_vlsdprej => rw_crapepr.vlsdprej
                                                            ,pr_vlsprjat => rw_crapepr.vlsprjat 
                                                            ,pr_vlpreemp => rw_crapepr.vlpreemp 
                                                            ,pr_vlttmupr => rw_crapepr.vlttmupr
                                                            ,pr_vlpgmupr => rw_crapepr.vlpgmupr 
                                                            ,pr_vlttjmpr => rw_crapepr.vlttjmpr 
                                                            ,pr_vlpgjmpr => rw_crapepr.vlpgjmpr
                                                            ,pr_nrparcel => 0
                                                            ,pr_cdoperad => vr_cdoperad
                                                            ,pr_vlparcel => 0
                                                            ,pr_nmtelant => vr_nmdatela
                                                            ,pr_inliqaco => 'S'           -- Indicador informando que é para liquidar o contrato de emprestimo
                                                            ,pr_vliofcpl => rw_crapepr.vliofcpl
                                                            ,pr_vltotpag => vr_vltotpag -- Retorno do total pago       
                                                            ,pr_cdcritic => vr_cdcritic
                                                            ,pr_dscritic => vr_dscritic);
                       
                       -- Se retornar erro da rotina
                       IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN

                         IF NVL(vr_cdcritic,0) > 0 THEN
                           vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                         END IF;

                         -- Log de erro de execucao
                         pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                                              ,pr_dstiplog => 'E'
                                              ,pr_dscritic => 'Arquivo: ' || vr_nmarqtxt || ' ' || vr_dscritic);
                         pr_flgemail := TRUE;
                         ROLLBACK; -- Desfaz acoes
                         EXIT LEITURA_TXT;
                       END IF;
                        
                       -- Não deve mais gerar lancamento 2181 para pagamento prejuizo.
                       -- vr_vllancam := NVL(vr_vllancam,0) + NVL(vr_vltotpag,0);   
                     -- Folha de Pagamento
                     ELSIF rw_crapepr.flgpagto = 1 THEN 
                       
                       -- Realizar a chamada da rotina para pagamento de prejuizo
                       EMPR9999.pc_pagar_emprestimo_folha(pr_cdcooper => rw_crapepr.cdcooper
                                                         ,pr_nrdconta => rw_crapepr.nrdconta
                                                         ,pr_cdagenci => rw_crapass.cdagenci
                                                         ,pr_crapdat  => vr_tab_crapdat(rw_crapepr.cdcooper)
                                                         ,pr_nrctremp => rw_crapepr.nrctremp
                                                         ,pr_nrparcel => 0
                                                         ,pr_cdlcremp => rw_crapepr.cdlcremp
                                                         ,pr_inliquid => rw_crapepr.inliquid
                                                         ,pr_qtprepag => rw_crapepr.qtprepag
                                                         ,pr_vlsdeved => rw_crapepr.vlsdeved
                                                         ,pr_vlsdevat => rw_crapepr.vlsdevat
                                                         ,pr_vljuracu => rw_crapepr.vljuracu
                                                         ,pr_txjuremp => rw_crapepr.txjuremp
                                                         ,pr_dtultpag => rw_crapepr.dtultpag
                                                         ,pr_vlparcel => 0
                                                         ,pr_nmtelant => vr_nmdatela
                                                         ,pr_cdoperad => vr_cdoperad
                                                         ,pr_inliqaco => 'S'           -- Indicador informando que é para liquidar o contrato de emprestimo
                                                         ,pr_vltotpag => vr_vltotpag
                                                         ,pr_cdcritic => vr_cdcritic
                                                         ,pr_dscritic => vr_dscritic);
                       
                       -- Se retornar erro da rotina
                       IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN

                         IF NVL(vr_cdcritic,0) > 0 THEN
                           vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                         END IF;

                         -- Log de erro de execucao
                         pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                                              ,pr_dstiplog => 'E'
                                              ,pr_dscritic => 'Arquivo: ' || vr_nmarqtxt || ' ' || vr_dscritic);
                         pr_flgemail := TRUE;
                         ROLLBACK; -- Desfaz acoes
                         EXIT LEITURA_TXT;
                       END IF;
                       
                       vr_vllanact := NVL(vr_vllanact,0) + NVL(vr_vltotpag,0); 
                      -- Emprestimo TR
                      ELSIF rw_crapepr.tpemprst = 0 THEN
                        
                        -- Pagar empréstimo TR
                        EMPR9999.pc_pagar_emprestimo_tr(pr_cdcooper => rw_crapepr.cdcooper
                                                       ,pr_nrdconta => rw_crapepr.nrdconta
                                                       ,pr_cdagenci => rw_crapass.cdagenci
                                                       ,pr_crapdat  => vr_tab_crapdat(rw_crapepr.cdcooper)
                                                       ,pr_nrctremp => rw_crapepr.nrctremp
                                                       ,pr_nrparcel => 0
                                                       ,pr_cdlcremp => rw_crapepr.cdlcremp
                                                       ,pr_inliquid => rw_crapepr.inliquid
                                                       ,pr_qtprepag => rw_crapepr.qtprepag
                                                       ,pr_vlsdeved => rw_crapepr.vlsdeved
                                                       ,pr_vlsdevat => rw_crapepr.vlsdevat
                                                       ,pr_vljuracu => rw_crapepr.vljuracu
                                                       ,pr_txjuremp => rw_crapepr.txjuremp
                                                       ,pr_dtultpag => rw_crapepr.dtultpag
                                                       ,pr_vlparcel => 0
                                                       ,pr_idorigem => 7
                                                       ,pr_nmtelant => vr_nmdatela
                                                       ,pr_cdoperad => vr_cdoperad
                                                       ,pr_inliqaco => 'S'
                                                       ,pr_vltotpag => vr_vltotpag
                                                       ,pr_cdcritic => vr_cdcritic
                                                       ,pr_dscritic => vr_dscritic);
                         
                        -- Se retornar erro da rotina
                        IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN

                          IF NVL(vr_cdcritic,0) > 0 THEN
                            vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                          END IF;

                          -- Log de erro de execucao
                          pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                                               ,pr_dstiplog => 'E'
                                               ,pr_dscritic => 'Arquivo: ' || vr_nmarqtxt || ' ' || vr_dscritic);
                          pr_flgemail := TRUE;
                          ROLLBACK; -- Desfaz acoes
                          EXIT LEITURA_TXT;
                        END IF;
                       
                        vr_vllanact := NVL(vr_vllanact,0) + NVL(vr_vltotpag,0); 
                      -- Emprestimo PP
                      ELSIF rw_crapepr.tpemprst = 1 THEN
                        -- Pagar empréstimo PP
                        RECP0001.pc_pagar_emprestimo_pp(pr_cdcooper => rw_crapepr.cdcooper
                                                       ,pr_nrdconta => rw_crapepr.nrdconta         
                                                       ,pr_cdagenci => rw_crapass.cdagenci         
                                                       ,pr_crapdat  => vr_tab_crapdat(rw_crapepr.cdcooper)
                                                       ,pr_nrctremp => rw_crapcyb.nrctremp
                                                       ,pr_nracordo => rw_crapcyb.nracordo
                                                       ,pr_nrparcel => 0
                                                       ,pr_vlsdeved => rw_crapepr.vlsdeved
                                                       ,pr_vlsdevat => rw_crapepr.vlsdevat
                                                       ,pr_vlparcel => 0
                                                       ,pr_idorigem => 7 
                                                       ,pr_nmtelant => vr_nmdatela
                                                       ,pr_cdoperad => vr_cdoperad
                                                       ,pr_inliqaco => 'S'
                                                       ,pr_idvlrmin => vr_idvlrmin
                                                       ,pr_vltotpag => vr_vltotpag         
                                                       ,pr_cdcritic => vr_cdcritic         
                                                       ,pr_dscritic => vr_dscritic);       
                        
                        -- Se retornar erro da rotina
                        IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN

                          IF NVL(vr_cdcritic,0) > 0 THEN
                            vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                          END IF;

                          -- Log de erro de execucao
                          pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                                               ,pr_dstiplog => 'E'
                                               ,pr_dscritic => 'Arquivo: ' || vr_nmarqtxt || ' ' || vr_dscritic);
                          pr_flgemail := TRUE;
                          ROLLBACK; -- Desfaz acoes
                          EXIT LEITURA_TXT;
                        END IF;
                       
                        vr_vllanact := NVL(vr_vllanact,0) + NVL(vr_vltotpag,0);
						-- Emprestimo Pos-Fixado
						ELSIF rw_crapepr.tpemprst = 2 THEN
							-- Pagar emprestimo Pos-Fixado
							recp0001.pc_pagar_emprestimo_pos(pr_cdcooper => rw_crapepr.cdcooper
							                                ,pr_nrdconta => rw_crapepr.nrdconta
															,pr_cdagenci => rw_crapass.cdagenci
															,pr_crapdat  => vr_tab_crapdat(rw_crapepr.cdcooper)
															,pr_nrctremp => rw_crapcyb.nrctremp
															,pr_dtefetiv => rw_crapepr.dtmvtolt
															,pr_cdlcremp => rw_crapepr.cdlcremp
															,pr_vlemprst => rw_crapepr.vlemprst
																							,pr_txmensal => rw_crapepr.wtxmensal
																							,pr_dtdpagto => rw_crapepr.wdtdpagto
															,pr_vlsprojt => rw_crapepr.vlsprojt
															,pr_qttolatr => rw_crapepr.qttolatr
															,pr_nrparcel => 0
															,pr_vlparcel => 0
															,pr_inliqaco => 'S'
															,pr_idorigem => 7
															,pr_nmtelant => vr_nmdatela
															,pr_cdoperad => vr_cdoperad
															--
															,pr_idvlrmin => vr_idvlrmin
															,pr_vltotpag => vr_vltotpag
															,pr_cdcritic => vr_cdcritic
															,pr_dscritic => vr_dscritic
															);      
                        
                        -- Se retornar erro da rotina
                        IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN

                          IF NVL(vr_cdcritic,0) > 0 THEN
                            vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                          END IF;

                          -- Log de erro de execucao
                          pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                                               ,pr_dstiplog => 'E'
                                               ,pr_dscritic => 'Arquivo: ' || vr_nmarqtxt || ' ' || vr_dscritic);
                          pr_flgemail := TRUE;
                          ROLLBACK; -- Desfaz acoes
                          EXIT LEITURA_TXT;
                        END IF;
                       
                        vr_vllanact := NVL(vr_vllanact,0) + NVL(vr_vltotpag,0);
                      END IF;

                      -- Se a conta está em prejuízo, debita da conta transitória o valor pago no contrato de empréstimo
                      IF NVL(vr_vltotpag,0) > 0 AND rw_crapass.inprejuz = 1 THEN
                        PREJ0003.pc_gera_debt_cta_prj(pr_cdcooper => rw_crapepr.cdcooper
                                                    , pr_nrdconta => rw_crapepr.nrdconta
                                                    , pr_vlrlanc  => vr_vltotpag
                                                    , pr_dtmvtolt => vr_tab_crapdat(rw_crapepr.cdcooper).dtmvtolt
                                                    , pr_cdcritic => vr_cdcritic
                                                    , pr_dscritic => vr_dscritic);
                                                    
                        -- Se retornar erro da rotina
                        IF TRIM(vr_dscritic) IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
                          IF NVL(vr_cdcritic,0) > 0 THEN
                            vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                          END IF;
						-- Log de erro de execucao
                          pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                                               ,pr_dstiplog => 'E'
                                               ,pr_dscritic => 'Arquivo: ' || vr_nmarqtxt || ' ' || vr_dscritic);
                          pr_flgemail := TRUE;
                          ROLLBACK; -- Desfaz acoes
                          EXIT LEITURA_TXT;
                        END IF;
                    END IF;
				  END IF;
                   BEGIN
                     UPDATE crapcyc 
                        SET flgehvip = decode(cdmotcin,2,flgehvip,7,flgehvip,flvipant),
                            cdmotcin = decode(cdmotcin,2,cdmotcin,7,cdmotcin,cdmotant),
                            dtaltera = vr_tab_crapdat(rw_crapcyb.cdcooper).dtmvtolt,
                            cdoperad = 'cyber'
                      WHERE cdcooper = rw_crapcyb.cdcooper
                        AND cdorigem = DECODE(rw_crapcyb.cdorigem,2,3,rw_crapcyb.cdorigem)
                        AND nrdconta = rw_crapcyb.nrdconta
                        AND nrctremp = rw_crapcyb.nrctremp;
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_dscritic := 'Erro ao atualizar CRAPCYC: '||SQLERRM;
                       -- Envio centralizado de log de erro
                       BTCH0001.pc_gera_log_batch(pr_cdcooper    => vr_cdcooper,
                                                  pr_ind_tipo_log => 2, -- Erro tratato
                                                  pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' --> Arquivo: ' || vr_nmarqtxt
                                                                      || ' Erro:' || vr_dscritic);
                       pr_flgemail := TRUE;
                       ROLLBACK;
                       EXIT LEITURA_TXT;
                   END;

                 END LOOP;
                 
                 OPEN cr_nracordo(pr_nracordo => vr_nracordo);

                 FETCH cr_nracordo INTO rw_nracordo;

                 CLOSE cr_nracordo;

                 OPEN cr_crapass(pr_cdcooper => rw_nracordo.cdcooper
                                ,pr_nrdconta => rw_nracordo.nrdconta);   

                 FETCH cr_crapass INTO rw_crapass;               

                 CLOSE cr_crapass;

                 IF rw_nracordo.vlbloqueado > 0 THEN
                                      
                    IF rw_crapass.inprejuz = 0 THEN   
                    EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_crapass.cdcooper                          --> Cooperativa conectada
                                                  ,pr_dtmvtolt => vr_tab_crapdat(rw_crapass.cdcooper).dtmvtolt --> Movimento atual
                                                  ,pr_cdagenci => rw_crapass.cdagenci                          --> Código da agência
                                                  ,pr_cdbccxlt => 100                                          --> Número do caixa
                                                  ,pr_cdoperad => vr_cdoperad                                  --> Código do Operador
                                                  ,pr_cdpactra => rw_crapass.cdagenci                          --> P.A. da transação
                                                  ,pr_nrdolote => 650001                                       --> Numero do Lote
                                                  ,pr_nrdconta => rw_crapass.nrdconta                          --> Número da conta
                                                  ,pr_cdhistor => 2194                                         --> Codigo historico 2194 - CR.DESB.ACORD
                                                  ,pr_vllanmto => rw_nracordo.vlbloqueado                      --> Valor da parcela emprestimo
                                                  ,pr_nrparepr => 0                                            --> Número parcelas empréstimo
                                                  ,pr_nrctremp => rw_nracordo.nracordo                         --> Número do contrato de empréstimo
                                                  ,pr_des_reto => vr_des_reto                                  --> Retorno OK / NOK
                                                  ,pr_tab_erro => vr_tab_erro);                                --> Tabela com possíves erros
                    --Se Retornou erro
                    IF vr_des_reto <> 'OK' THEN
                      -- Se possui algum erro na tabela de erros
                      IF vr_tab_erro.count() > 0 THEN
                        -- Atribui críticas às variaveis
                        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                      ELSE
                        vr_cdcritic := 0;
                        vr_dscritic := 'Erro ao criar o lancamento de desbloqueio de acordo';
                      END IF;
                      
                      -- Log de erro de execucao
                      pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                                           ,pr_dstiplog => 'E'
                                           ,pr_dscritic => 'Arquivo: ' || vr_nmarqtxt || ' ' || vr_dscritic);

                      pr_flgemail := TRUE;
                      ROLLBACK; -- Desfaz acoes
                      EXIT LEITURA_TXT;
                    END IF;
										ELSE
											PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => rw_crapass.cdcooper
				                            , pr_nrdconta => rw_crapass.nrdconta
																		, pr_vlrlanc  => rw_nracordo.vlbloqueado
																		, pr_dtmvtolt => vr_tab_crapdat(rw_crapass.cdcooper).dtmvtolt
																		, pr_cdcritic => vr_cdcritic
																		, pr_dscritic => vr_dscritic); 
														
											IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
												-- Log de erro de execucao
												pc_controla_log_batch(pr_cdcooper => vr_cdcooper
																						 ,pr_dstiplog => 'E'
																						 ,pr_dscritic => 'Arquivo: ' || vr_nmarqtxt || ' ' || vr_dscritic);

												pr_flgemail := TRUE;
												ROLLBACK; -- Desfaz acoes
												EXIT LEITURA_TXT;
											END IF;
										END IF;

                 END IF;

                 -- Verifica se deve lançar abatimento no acordo
                 IF vr_vllanacc + vr_vllanact - rw_nracordo.vlbloqueado > 0 THEN
                   IF rw_crapass.inprejuz = 0 THEN        
                     vr_vlrabono := vr_vllanacc + vr_vllanact - rw_nracordo.vlbloqueado;
                                  
										 -- Lança crédito do abono na conta corrente
                   EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_crapass.cdcooper                          --> Cooperativa conectada
                                                 ,pr_dtmvtolt => vr_tab_crapdat(rw_crapass.cdcooper).dtmvtolt --> Movimento atual
                                                 ,pr_cdagenci => rw_crapass.cdagenci                          --> Código da agência
                                                 ,pr_cdbccxlt => 100                                          --> Número do caixa
                                                 ,pr_cdoperad => vr_cdoperad                                  --> Código do Operador
                                                 ,pr_cdpactra => rw_crapass.cdagenci                          --> P.A. da transação
                                                 ,pr_nrdolote => 650001                                       --> Numero do Lote
                                                 ,pr_nrdconta => rw_crapass.nrdconta                          --> Número da conta
                                                 ,pr_cdhistor => 2181                                         --> Codigo historico
																									 ,pr_vllanmto => vr_vlrabono                                  --> Valor do credito
                                                 ,pr_nrparepr => 0                                            --> Número do Acordo
                                                 ,pr_nrctremp => rw_nracordo.nracordo                         --> Número do contrato de empréstimo
                                                 ,pr_des_reto => vr_des_reto                                  --> Retorno OK / NOK
                                                 ,pr_tab_erro => vr_tab_erro);                                --> Tabela com possíves erros

                   -- Se ocorreu erro
                   IF vr_des_reto <> 'OK' THEN
                     -- Se possui algum erro na tabela de erros
                     IF vr_tab_erro.COUNT() > 0 THEN
                       vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                       vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                     ELSE
                       vr_cdcritic := 0;
                       vr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
                     END IF;
                     -- Log de erro de execucao
                     pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                                          ,pr_dstiplog => 'E'
                                          ,pr_dscritic => 'Arquivo: ' || vr_nmarqtxt || ' ' || vr_dscritic);
                     pr_flgemail := TRUE;
                     ROLLBACK; -- Desfaz acoes
                     EXIT LEITURA_TXT;
                   END IF;
                   ELSE
                     IF vr_vllanacc > 0 THEN -- Abatimento em conta corrente
                       IF vr_vllanacc > rw_nracordo.vlbloqueado THEN
                         vr_vlrabono := vr_vllanacc - rw_nracordo.vlbloqueado;
                       
                         -- Lança crédito do abono na conta corrente
                         EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_crapass.cdcooper                          --> Cooperativa conectada
                                                       ,pr_dtmvtolt => vr_tab_crapdat(rw_crapass.cdcooper).dtmvtolt --> Movimento atual
                                                       ,pr_cdagenci => rw_crapass.cdagenci                          --> Código da agência
                                                       ,pr_cdbccxlt => 100                                          --> Número do caixa
                                                       ,pr_cdoperad => vr_cdoperad                                  --> Código do Operador
                                                       ,pr_cdpactra => rw_crapass.cdagenci                          --> P.A. da transação
                                                       ,pr_nrdolote => 650001                                       --> Numero do Lote
                                                       ,pr_nrdconta => rw_crapass.nrdconta                          --> Número da conta
                                                       ,pr_cdhistor => 2919                                         --> Codigo historico
                                                       ,pr_vllanmto => vr_vlrabono                                  --> Valor do credito
                                                       ,pr_nrparepr => 0                                            --> Número do Acordo
                                                       ,pr_nrctremp => rw_nracordo.nracordo                         --> Número do contrato de empréstimo
                                                       ,pr_des_reto => vr_des_reto                                  --> Retorno OK / NOK
                                                       ,pr_tab_erro => vr_tab_erro);                                --> Tabela com possíves erros

                         -- Se ocorreu erro
                         IF vr_des_reto <> 'OK' THEN
                           -- Se possui algum erro na tabela de erros
                           IF vr_tab_erro.COUNT() > 0 THEN
                             vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                             vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                           ELSE
                             vr_cdcritic := 0;
                             vr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
                           END IF;
                           -- Log de erro de execucao
                           pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                                                ,pr_dstiplog => 'E'
                                                ,pr_dscritic => 'Arquivo: ' || vr_nmarqtxt || ' ' || vr_dscritic);
                           pr_flgemail := TRUE;
                           ROLLBACK; -- Desfaz acoes
                           EXIT LEITURA_TXT;
                         END IF;

                 -- Atualiza valor do abono do saldo do prejuízo da conta corrente
                 BEGIN
                   -- Abate o valor do abono do saldo do prejuízo da conta corrente
                   UPDATE tbcc_prejuizo prj
                      SET vlsdprej = 0
                        , vljur60_ctneg = 0
                        , vljur60_lcred = 0
                        , vljuprej = 0
                        , vlrabono = vlrabono + vr_vlrabono
                    WHERE cdcooper = rw_crapass.cdcooper
                       AND nrdconta = rw_crapass.nrdconta
                        AND dtliquidacao IS NULL;
                 EXCEPTION
                   WHEN OTHERS THEN
                     vr_dscritic := 'Erro ao atualizar registro na tabela TBCC_PREJUIZO: ' || SQLERRM;
                     -- Log de erro de execucao
                     pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                                          ,pr_dstiplog => 'E'
                                          ,pr_dscritic => 'Arquivo: ' || vr_nmarqtxt || ' ' || vr_dscritic);
                     pr_flgemail := TRUE;
                     ROLLBACK; -- Desfaz acoes
                     EXIT LEITURA_TXT;
                 END;
                 END IF;
                     
                       IF vr_vllanacc >= rw_nracordo.vlbloqueado THEN
                         rw_nracordo.vlbloqueado := 0;
                       ELSE
                         rw_nracordo.vlbloqueado := rw_nracordo.vlbloqueado - vr_vllanacc;
									 END IF;
                     END IF;
                     
                     IF vr_vllanact > 0 THEN -- Abatimento em contratos (empréstimo, descto. de títulos, ...)
                       vr_vlrabono := vr_vllanact - rw_nracordo.vlbloqueado;
                       
                       -- Lança crédito do abono na conta corrente
                       EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_crapass.cdcooper                          --> Cooperativa conectada
                                                     ,pr_dtmvtolt => vr_tab_crapdat(rw_crapass.cdcooper).dtmvtolt --> Movimento atual
                                                     ,pr_cdagenci => rw_crapass.cdagenci                          --> Código da agência
                                                     ,pr_cdbccxlt => 100                                          --> Número do caixa
                                                     ,pr_cdoperad => vr_cdoperad                                  --> Código do Operador
                                                     ,pr_cdpactra => rw_crapass.cdagenci                          --> P.A. da transação
                                                     ,pr_nrdolote => 650001                                       --> Numero do Lote
                                                     ,pr_nrdconta => rw_crapass.nrdconta                          --> Número da conta
                                                     ,pr_cdhistor => 2181                                         --> Codigo historico
                                                     ,pr_vllanmto => vr_vlrabono                                  --> Valor do credito
                                                     ,pr_nrparepr => 0                                            --> Número do Acordo
                                                     ,pr_nrctremp => rw_nracordo.nracordo                         --> Número do contrato de empréstimo
                                                     ,pr_des_reto => vr_des_reto                                  --> Retorno OK / NOK
                                                     ,pr_tab_erro => vr_tab_erro);                                --> Tabela com possíves erros

                       -- Se ocorreu erro
                       IF vr_des_reto <> 'OK' THEN
                         -- Se possui algum erro na tabela de erros
                         IF vr_tab_erro.COUNT() > 0 THEN
                           vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                           vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                         ELSE
                           vr_cdcritic := 0;
                           vr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
                         END IF;
                         -- Log de erro de execucao
                         pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                                              ,pr_dstiplog => 'E'
                                              ,pr_dscritic => 'Arquivo: ' || vr_nmarqtxt || ' ' || vr_dscritic);
                         pr_flgemail := TRUE;
                         ROLLBACK; -- Desfaz acoes
                         EXIT LEITURA_TXT;
                       END IF;
                       
                     END IF;
                   END IF;
                 END IF;

                 -- Atualiza a situação do acordo
                 BEGIN
                   UPDATE tbrecup_acordo
                      SET vlbloqueado = 0,
                          cdsituacao  = 2,
                          dtliquid    = vr_dtquitac
                    WHERE tbrecup_acordo.nracordo = vr_nracordo;
                 EXCEPTION
                   WHEN OTHERS THEN
                     vr_dscritic := 'Erro ao atualizar registro na tabela TBRECUP_ACORDO: ' || SQLERRM;
                     -- Log de erro de execucao
                     pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                                          ,pr_dstiplog => 'E'
                                          ,pr_dscritic => 'Arquivo: ' || vr_nmarqtxt || ' ' || vr_dscritic);
                     pr_flgemail := TRUE;
                     ROLLBACK; -- Desfaz acoes
                     EXIT LEITURA_TXT;                                          
                 END;   
               END IF; --Arquivo aberto
             END LOOP;
             
             COMMIT; -- Salva os dados por arquivo
             
             -- Verificar se o arquivo está aberto
             IF utl_file.IS_OPEN(vr_input_file) THEN
               -- Fechar o arquivo
               GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
             END IF;

             -- Buscar proximo arquivo
             vr_idx_txt:= vr_tab_arqtxt.NEXT(vr_idx_txt);
           END LOOP;

        END IF;
        
        -- Renomear os arquivos .zip que foram processados
        vr_comando:= 'mv '||vr_endarqui||'/'||vr_nmtmparq||'.zip '||
                    vr_endarqui||'/'||vr_nmtmparq||'_processado.pro 1> /dev/null';
        
        -- Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);
        
        -- Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic:= 'Nao foi possivel executar comando unix. ' || vr_comando;
          -- Log de erro de execucao
          pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                               ,pr_dstiplog => 'E'
                               ,pr_dscritic => vr_dscritic);
          CONTINUE;
        END IF;

        -- Remove o diretorio criado
        vr_comando:= 'rm -Rf '||vr_endarqui||'/'||vr_nmtmparq||' 1> /dev/null';

        -- Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);
        
        -- Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic:= 'Nao foi possivel executar comando unix. ' || vr_comando || '. Erro: ' || vr_dscritic;
          -- Log de erro de execucao
          pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                               ,pr_dstiplog => 'E'
                               ,pr_dscritic => vr_dscritic);
          CONTINUE;
        END IF;                

        -- Envio centralizado de log de erro
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratato
                                   pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' --> ' ||
                                                      'ARQUIVO INTEGRADO: ' || vr_nmarqzip); 

        -- Proximo registro
        vr_nrindice:= vr_tab_arqzip.NEXT(vr_nrindice);

      END LOOP;
      
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na RECP0003.PC_IMP_ARQ_ACORDO_QUITADO: ' || SQLERRM;
      pr_flgemail := TRUE;
      -- Log de erro de execucao
      pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                           ,pr_dstiplog => 'E'
                           ,pr_dscritic => pr_dscritic);

      ROLLBACK;
  END pc_imp_arq_acordo_quitado; 

  PROCEDURE pc_import_arq_acordo_job IS

    -- Variaveis de Erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_flgemail_cancelado BOOLEAN := FALSE;
    vr_flgemail_quitado BOOLEAN := FALSE;
    vr_dscemail VARCHAR2(4000) := '';     
  BEGIN
    -- Buscar o CRAPDAT da cooperativa
    OPEN BTCH0001.cr_crapdat(3); 
    FETCH BTCH0001.cr_crapdat INTO BTCH0001.rw_crapdat;
    -- Se não encontrar registro na CRAPDAT
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE BTCH0001.cr_crapdat;    
      RETURN;
    END IF;        
    -- Fechar o cursor
    CLOSE BTCH0001.cr_crapdat;
  
    -- Condicao para verificar se o processo noturno está rodando
    IF BTCH0001.rw_crapdat.inproces >= 2 THEN
      RETURN;
    END IF;  
  
      -- Log de inicio de execucao
      pc_controla_log_batch(pr_cdcooper => 3
                           ,pr_dstiplog => 'I');
            
      -- Importacao de arquivo de acordos cancelados
      pc_imp_arq_acordo_cancel(pr_flgemail => vr_flgemail_cancelado
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

      -- Importacao de arquivo de acordos quitados
      pc_imp_arq_acordo_quitado(pr_flgemail => vr_flgemail_quitado
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);

      IF vr_flgemail_cancelado AND vr_flgemail_quitado THEN
        vr_dscemail := 'Houve erro de importação no arquivo referente a acordos cancelados e quitados.';
      ELSIF vr_flgemail_cancelado THEN
        vr_dscemail := 'Houve erro de importação no arquivo referente a acordos cancelados.';
      ELSIF vr_flgemail_quitado THEN
        vr_dscemail := 'Houve erro de importação no arquivo referente a acordos quitados.';
      END IF;
           
      IF vr_dscemail IS NOT NULL THEN
        -- Envia email aos responsaveis pela importacao do arquivo CB117
        GENE0003.pc_solicita_email(pr_cdcooper        => 3
                                  ,pr_cdprogra        => 'RECP0003'
                                  ,pr_des_destino     => 'estrategiadecobranca@ailos.coop.br'
                                  ,pr_des_assunto     => 'IMPORTACAO ARQUIVO ACORDO'
                                  ,pr_des_corpo       => vr_dscemail
                                  ,pr_des_anexo       => NULL --> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                  ,pr_flg_remove_anex => 'N'  --> Remover os anexos passados
                                  ,pr_flg_remete_coop => 'N'  --> Se o envio sera do e-mail da Cooperativa
                                  ,pr_flg_enviar      => 'S'  --> Enviar o e-mail na hora
                                  ,pr_des_erro        => vr_dscritic);

        -- Se houver erros
        IF vr_dscritic IS NOT NULL THEN
          -- Log de erro de execucao
          pc_controla_log_batch(pr_cdcooper => 3
                               ,pr_dstiplog => 'E'
                               ,pr_dscritic => vr_dscritic);
        END IF;
      END IF;

      -- Log de final de execucao
      pc_controla_log_batch(pr_cdcooper => 3
                           ,pr_dstiplog => 'F');

      COMMIT;
     
  EXCEPTION
    WHEN OTHERS THEN
      -- Log de erro de execucao
          pc_controla_log_batch(pr_cdcooper => 3
                               ,pr_dstiplog => 'E'
                               ,pr_dscritic => SQLERRM);
      ROLLBACK;
  END pc_import_arq_acordo_job;
  
END RECP0003;
/