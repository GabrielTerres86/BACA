CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS657 (pr_cdcooper IN crapcop.cdcooper%TYPE      --> Codigo Cooperativa
                                       ,pr_nmdatela IN VARCHAR2                   --> Nome Tela
                                       ,pr_stprogra OUT PLS_INTEGER               --> Saida de termino da execucao
                                       ,pr_infimsol OUT PLS_INTEGER               --> Saida de termino da solicitacao
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2) IS              --> Descricao da Critica
  BEGIN

  /* .............................................................................

   Programa: PC_CRPS657                      Antigo: Fontes/CRPS657.p
   Sistema : CRIA/ATUALIZA PREJUIZO CYBER
   Sigla   : CRED
   Autor   : James Prust Junior
   Data    : Agosto/2013.                     Ultima atualizacao: 31/10/2018

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 76. Ordem = 3.
               Criar/Atualizar dados na tabela crapspc.

   Alteracoes: 11/11/2013 - Alteracao no nome do arquivo .zip. (James)
                            
               10/03/2014 - Conversao Progress -> Oracle (Alisson - Amcom)
               
               31/03/2014 - Ajuste para liberar a importacao para todas as 
                            cooperativas que estao no CYBER (James)

               23/10/2014 - Inlusao de verificacao das Cooperativas Inativas
                            (Concredi/Credimilsul) para passar para o proximo 
                            registro: TO_NUMBER(SUBSTR(vr_setlinha,1,4)) IN (4,15). 
                            (Jaison)
                            
               25/02/2015 - Ajuste para nao catalogar no proc_batch quando o avalista
                            nao existir na tela CADSPC.(James)
                            
               02/03/2015 - Ajuste para nao catalogar no proc_batch quando o avalista
                            nao existir no emprestimo.(James)
                            
               09/10/2018 - Padrões - Tratar erro de lay-out no arquivo de entrada.
                            (Belli - Envolti - Chd REQ0029189)
                            
               31/10/2018 - Padrões - Complemento de descrições no retorno de erros.
                            (Belli - Envolti - Chd REQ0031662) 
														
							 09/09/2019 - PRJ573 - Incluir chamada da rotina para processamento dos arquivos do
							              CPC (Nagasava - Supero).
														
     ............................................................................. */

     DECLARE
     
      
       /*Cursores Locais */

       -- Selecionar os dados da Cooperativa
       CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
         SELECT crapcop.cdcooper
               ,crapcop.nmrescop
               ,crapcop.nrtelura
               ,crapcop.cdbcoctl
               ,crapcop.cdagectl
               ,crapcop.dsdircop
               ,crapcop.nrctactl
               ,crapcop.cdagedbb
               ,crapcop.cdageitg
               ,crapcop.nrdocnpj
         FROM crapcop crapcop
         WHERE crapcop.cdcooper = pr_cdcooper;
       rw_crapcop cr_crapcop%ROWTYPE;
           
       --Selecionar os dados da tabela de Associados
       CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
         SELECT crapass.nrdconta
               ,crapass.cdsitdct
               ,crapass.cdagenci
               ,crapass.cdsitdtl
               ,crapass.nrcpfcgc
         FROM crapass crapass
         WHERE crapass.cdcooper = pr_cdcooper
         AND   crapass.nrdconta = pr_nrdconta;
       rw_crapass cr_crapass%ROWTYPE;
        
       --Selecionar Emprestimos
       CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%TYPE
                         ,pr_nrdconta IN crapepr.nrdconta%TYPE
                         ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS  
         SELECT crapepr.*
               ,crapepr.rowid
         FROM crapepr 
         WHERE crapepr.cdcooper = pr_cdcooper   
         AND   crapepr.nrdconta = pr_nrdconta   
         AND   crapepr.nrctremp = pr_nrctremp;
       rw_crapepr cr_crapepr%ROWTYPE;   
       
       --Selecionar Avalistas
       CURSOR cr_crapavt (pr_cdcooper IN crapavt.cdcooper%TYPE
                         ,pr_nrdconta IN crapavt.nrdconta%TYPE
                         ,pr_nrctremp IN crapavt.nrctremp%TYPE
                         ,pr_tpctrato IN crapavt.tpctrato%TYPE) IS
         SELECT crapavt.nrcpfcgc
         FROM crapavt
         WHERE crapavt.cdcooper = pr_cdcooper      
         AND   crapavt.nrdconta = pr_nrdconta
         AND   crapavt.nrctremp = pr_nrctremp
         AND   crapavt.tpctrato = pr_tpctrato
         ORDER BY cdcooper, tpctrato, nrdconta, nrctremp, nrcpfcgc;
       rw_crapavt cr_crapavt%ROWTYPE;
          
       --Selecionar cadastro spc
       CURSOR cr_crapspc (pr_cdcooper IN crapspc.cdcooper%TYPE
                         ,pr_nrdconta IN crapspc.nrdconta%TYPE
                         ,pr_nrcpfcgc IN crapspc.nrcpfcgc%TYPE
                         ,pr_nrctremp IN crapspc.nrctremp%TYPE
                         ,pr_dtinclus IN crapspc.dtinclus%TYPE) IS
         SELECT crapspc.rowid
         FROM crapspc 
         WHERE crapspc.cdcooper = pr_cdcooper 
         AND   crapspc.nrdconta = pr_nrdconta 
         AND   crapspc.nrcpfcgc = pr_nrcpfcgc 
         AND   crapspc.nrctremp = pr_nrctremp 
         AND   crapspc.dtinclus = pr_dtinclus;                
       rw_crapspc cr_crapspc%ROWTYPE; 
                                    
       --Registro do tipo calendario
       rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
            
       --Constantes
       vr_cdprogra CONSTANT crapprg.cdprogra%TYPE:= 'CRPS657';


       --Variaveis Locais
       vr_nmtmpzip VARCHAR2(200);
       --vr_nmtmptxt VARCHAR2(200);
       vr_nmarqzip VARCHAR2(200);
       vr_nmarqtxt VARCHAR2(200);
       vr_endarqui VARCHAR2(200);
       vr_nrctrspc VARCHAR2(200);
       vr_dsobsbxa VARCHAR2(200);
       vr_setlinha VARCHAR2(200);
       vr_cddopcao VARCHAR2(200);
       vr_nmdcampo VARCHAR2(200);
       vr_dsinsttu VARCHAR2(200);
       vr_operador VARCHAR2(200);
       vr_nmtmparq VARCHAR2(200);
       vr_cdcooper INTEGER;
       vr_modalida INTEGER;
       vr_nrdconta INTEGER;
       vr_nrctremp INTEGER;
       vr_cdagenci INTEGER:= 1;
       vr_nrdcaixa INTEGER:= 0;
       vr_nrctaavl INTEGER;
       vr_contarqv INTEGER:= 0;
       vr_nrindice INTEGER;
       vr_bkpndice INTEGER;
       vr_tpinsttu INTEGER;
       vr_tpidenti INTEGER:= 0;
       vr_nrcpfcgc NUMBER;
       vr_vldivida NUMBER;
       vr_dtinclus DATE;
       vr_dtvencto DATE;
       vr_dtdbaixa DATE;
       vr_dtarquiv DATE;
       vr_nrdrowid ROWID;
       vr_idx_txt  INTEGER;
       vr_crapspc  BOOLEAN;

       -- Padrões - 09/10/2018 - Chd REQ0029189
       vr_cdproexe   tbgen_prglog.cdprograma%TYPE := 'pc_crps657';
       vr_cdproint   VARCHAR2(100);
       vr_sqlerrm    VARCHAR2(4000);
       vr_dsparame   VARCHAR2(4000); -- Agrupa parametros
       vr_dspardat   VARCHAR2(4000); -- Agrupa parametros loop arquivos compactados
       vr_dspartxt   VARCHAR2(4000); -- Agrupa parametros loop arquivos texto
       vr_dsparlin   VARCHAR2(4000); -- Agrupa parametros loop linha dos arquivos
       vr_ctlinha    NUMBER     (6); -- posiciona linha do arquivo
       vr_tpocorre   NUMBER     (1) := 2;
       vr_exc_erro_tratado EXCEPTION;
       vr_exc_others       EXCEPTION;
       
       --Variaveis Comando Unix
       vr_typ_saida VARCHAR2(10);
       vr_comando   VARCHAR2(4000);
       vr_listadir  VARCHAR2(4000);
       vr_endarqtxt VARCHAR2(4000);
       vr_input_file  utl_file.file_type;

       --Tabela para armazenar erros
       vr_tab_erro GENE0001.typ_tab_erro;
       
       --Tabela para armazenar arquivos lidos
       vr_tab_arqzip gene0002.typ_split;
       vr_tab_arqtxt gene0002.typ_split;
       
       --Variaveis para retorno de erro
       vr_cdcritic      INTEGER:= 0;
       vr_dscritic      VARCHAR2(4000);
       vr_des_erro      VARCHAR2(3);

       --Variaveis de Excecao
       vr_exc_final     EXCEPTION;
       vr_exc_saida     EXCEPTION;
       vr_exc_fimprg    EXCEPTION;
       vr_exc_proximo   EXCEPTION;

  -- Controla log - Padrões - 09/10/2018 - Chd REQ0029189
  PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2 DEFAULT 'E' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                                 ,pr_tpocorre IN NUMBER   DEFAULT 2   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                 ,pr_cdcricid IN NUMBER   DEFAULT 2   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                                 ,pr_tpexecuc IN NUMBER   DEFAULT 1   -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                                 ,pr_dscritic IN VARCHAR2 DEFAULT NULL
                                 ,pr_cdcritic IN INTEGER  DEFAULT NULL
                                 ,pr_flgsuces IN NUMBER   DEFAULT 1    -- Indicador de sucesso da execução  
                                 ,pr_flabrchd IN INTEGER  DEFAULT 0    -- Abre chamado 1 Sim/ 0 Não
                                 ,pr_textochd IN VARCHAR2 DEFAULT NULL -- Texto do chamado
                                 ,pr_desemail IN VARCHAR2 DEFAULT NULL -- Destinatario do email
                                 ,pr_flreinci IN INTEGER  DEFAULT 0    -- Erro pode reincidir no prog em dias diferentes, devendo abrir chamado                                 
                                      )
  IS
    /* 
    Programa: pc_crps657
    Sistema : Cooperativa de Credito
    Sigla   : CRED
    Data    : 09/10/2018                              Ultima atualizacao: 00/00/0000
    Autor   : Belli - Envolti - Chamado REQ0029189

    Dados referentes ao programa:

    Frequencia: Disparado pela propria procedure.
    Objetivo  : Gerar Log centralizado.

    Alteracoes:                

    */
    vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;
  BEGIN       
    -- Controlar geração de log de execução dos jobs                                                                  
    CECRED.pc_log_programa(pr_dstiplog      => pr_dstiplog -- I-início/ F-fim/ O-ocorrência/ E-erro 
                          ,pr_tpocorrencia  => pr_tpocorre -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          ,pr_cdcriticidade => pr_cdcricid -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                          ,pr_tpexecucao    => pr_tpexecuc -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                          ,pr_dsmensagem    => SUBSTR(pr_dscritic,1,3900)
                          ,pr_cdmensagem    => pr_cdcritic
                          ,pr_cdcooper      => pr_cdcooper 
                          ,pr_flgsucesso    => pr_flgsuces
                          ,pr_flabrechamado => pr_flabrchd -- Abre chamado 1 Sim/ 0 Não
                          ,pr_texto_chamado => pr_textochd
                          ,pr_destinatario_email => pr_desemail
                          ,pr_flreincidente => pr_flreinci
                          ,pr_cdprograma    => vr_cdprogra
                          ,pr_idprglog      => vr_idprglog
                          );   
    IF LENGTH(pr_dscritic) > 3900 THEN   
      -- Controlar geração de log de execução dos jobs                                
      CECRED.pc_log_programa(pr_dstiplog      => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                            ,pr_tpocorrencia  => 3 -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                            ,pr_cdcriticidade => 0 -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                            ,pr_tpexecucao    => 2 -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                            ,pr_dsmensagem    => gene0001.fn_busca_critica(pr_cdcritic => 9999) ||
                                            '. Estouro do atributo pr_dscritic com tamanho de: '||LENGTH(pr_dscritic)||
                                            '. ' || vr_cdproexe || 
                                            '. ' || vr_dsparame ||
                                            '. ' || SUBSTR(pr_dscritic,3901,3900) 
                            ,pr_cdmensagem    => 9999
                            ,pr_cdcooper      => pr_cdcooper 
                            ,pr_flgsucesso    => pr_flgsuces
                            ,pr_flabrechamado => pr_flabrchd -- Abre chamado 1 Sim/ 0 Não
                            ,pr_texto_chamado => pr_textochd
                            ,pr_destinatario_email => pr_desemail
                            ,pr_flreincidente => pr_flreinci
                            ,pr_cdprograma    => vr_cdprogra
                            ,pr_idprglog      => vr_idprglog
                            );     
    END IF;                                        
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log  
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
  END pc_controla_log_batch;  

  -- Excluida pc_limpa_tabela - 09/10/2018 - Chd REQ0029189
       
       --Verificar Pagamento
       PROCEDURE pc_gera_log_importacao(pr_cdcritic IN VARCHAR2       --> cd Critica
                                       ,pr_dscritic IN VARCHAR2       --> ds Critica
                                       ,pr_cdcopcnt IN INTEGER        --> Código da cooperativa da Conta
                                       ,pr_nrdconta IN INTEGER        --> Conta
                                       ,pr_nrctremp IN INTEGER        --> Contrato Emprestimo
                                       ,pr_nrcpfcgc IN NUMBER         --> Cpf/Cnpj
                                       ,pr_tpinsttu IN INTEGER        --> Tipo Instrucao 
                                       ) IS
    /* 
    Programa: pc_crps657
    Sistema : Cooperativa de Credito
    Sigla   : CRED
    Data    : 09/10/2018                              Ultima atualizacao: 00/00/0000
    Autor   : Belli - Envolti - Chamado REQ0029189

    Dados referentes ao programa:

    Frequencia: Disparado pela propria procedure.
    Objetivo  : Verificar Pagamento.

    Alteracoes:                

    */
       BEGIN
         DECLARE 
           --Variaveis Locais                              
           vr_tipregis VARCHAR2(10); 
           vr_dsmensag VARCHAR2(4000);                             
         BEGIN
           -- Posiciona procedure - 09/10/2018 - Chd REQ0029189
           vr_cdproint := vr_cdproexe || '.pc_gera_log_importacao';
           -- Inclusão do módulo e ação logado
           GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);    
           
           --Tipo da Instituicao
           IF pr_tpinsttu = 1 THEN
             vr_tipregis:= 'SPC';
           ELSE
             vr_tipregis:= 'SERASA';
           END IF; 
           --Montar Mensagem
           vr_dsmensag:= pr_dscritic   ||
                         ' tipregis:'  || vr_tipregis ||
                         ', Coop.Cnt:' || pr_cdcopcnt ||
                         ', Conta:'    || pr_nrdconta ||
                         ', Contrato:' || pr_nrctremp ||
                         ', CPF/CNPJ:' || pr_nrcpfcgc;
           -- Envio centralizado de log de erro
           pc_controla_log_batch(pr_cdcritic => pr_cdcritic
                                ,pr_dscritic => vr_dsmensag
                                ,pr_tpocorre => 1
                                ,pr_cdcricid => 0
                                );  
         EXCEPTION
           WHEN vr_exc_others THEN 
             RAISE vr_exc_others; 
           WHEN OTHERS THEN
             -- No caso de erro de programa gravar tabela especifica de log 
             CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
             -- Trata erro
             vr_sqlerrm := SQLERRM;
             RAISE vr_exc_others;  
         END;       
       END pc_gera_log_importacao;  
       
       --Buscar dados do Emprestimo
       PROCEDURE pc_busca_dados_emprestimo (pr_cdcooper IN INTEGER    --> Cooperativa
                                           ,pr_cdagenci IN INTEGER    --> Agencia
                                           ,pr_nrdcaixa IN INTEGER    --> Caixa
                                           ,pr_nrdconta IN INTEGER    --> Conta
                                           ,pr_nrctremp IN INTEGER    --> Contrato Emprestimo
                                           ,pr_nrcpfcgc IN NUMBER     --> Cpf/Cnpj
                                           ,pr_tpidenti OUT INTEGER   --> Tipo Identificacao 
                                           ,pr_nrctaavl OUT INTEGER   --> Numero Conta Avalista 1
                                           ,pr_tab_erro OUT gene0001.typ_tab_erro  --> Tabela Critica
                                           ,pr_des_reto OUT VARCHAR2) IS  --> Retorno de erro
    /* 
    Programa: pc_crps657
    Sistema : Cooperativa de Credito
    Sigla   : CRED
    Data    : 09/10/2018                              Ultima atualizacao: 00/00/0000
    Autor   : Belli - Envolti - Chamado REQ0029189

    Dados referentes ao programa:

    Frequencia: Disparado pela propria procedure.
    Objetivo  : Buscar dados do Emprestimo.

    Alteracoes:                

    */                                           
       BEGIN
         DECLARE 
           --Variaveis Locais                              
           vr_flgaval1 BOOLEAN:= FALSE;
           vr_flgaval2 BOOLEAN:= FALSE;
           vr_cdcritic INTEGER;
           vr_dscritic VARCHAR2(4000);
         BEGIN
           --Retornar OK
           pr_des_reto:= 'OK';
           vr_dscritic:= NULL;
           -- Posiciona procedure - 09/10/2018 - Chd REQ0029189
           vr_cdproint := vr_cdproexe || '.pc_busca_dados_emprestimo';
           -- Inclusão do módulo e ação logado
           GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);   
           
           --Selecionar Emprestimo
           OPEN cr_crapepr (pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctremp => pr_nrctremp);
           FETCH cr_crapepr INTO rw_crapepr;
           --Se nao encontrou
           IF cr_crapepr%NOTFOUND THEN
             --Fechar Cursor
             CLOSE cr_crapepr;
             --Descricao do erro recebe mensagam da critica
             vr_cdcritic := 356;
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
             -- Gerar rotina de gravação de erro
             gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_nrdcaixa => pr_nrdcaixa
                                  ,pr_nrsequen => 1 --> Fixo
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_tab_erro => pr_tab_erro);
             --Sair do programa
             RAISE vr_exc_saida;
           END IF;  
           --Fechar Cursor
           CLOSE cr_crapepr; 
           /** Avalistas - Terceiros **/ 
           FOR rw_crapavt IN cr_crapavt (pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => rw_crapepr.nrdconta
                                        ,pr_nrctremp => rw_crapepr.nrctremp
                                        ,pr_tpctrato => 1) LOOP
             --Conta avalista nao encontrada                           
             IF nvl(rw_crapepr.nrctaav1,0) = 0 AND NOT vr_flgaval1 THEN 
               --Encontrou avalista 1
               vr_flgaval1:= TRUE;    
               --Cpf do avalista
               IF rw_crapavt.nrcpfcgc = pr_nrcpfcgc THEN
                 pr_tpidenti:= 3;
               END IF;  
             ELSIF nvl(rw_crapepr.nrctaav2,0) = 0 AND NOT vr_flgaval2 THEN
               --Encontrou avalista 2
               vr_flgaval2:= TRUE;    
               --Cpf do avalista
               IF rw_crapavt.nrcpfcgc = pr_nrcpfcgc THEN
                 pr_tpidenti:= 4;
               END IF;  
             END IF;                                       
           END LOOP;
           /** Busca o cpf/cnpj do primeiro avalista **/
           IF nvl(rw_crapepr.nrctaav1,0) <> 0 AND nvl(pr_tpidenti,0) = 0 THEN
             --Selecionar informacoes avalista
             OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => rw_crapepr.nrctaav1);
             FETCH cr_crapass INTO rw_crapass;
             --Se encontrou
             IF cr_crapass%FOUND AND rw_crapass.nrcpfcgc = pr_nrcpfcgc THEN                        
               --Tipo identificacao
               pr_tpidenti:= 3;  
             END IF;
             --Fechar Cursor
             CLOSE cr_crapass;  
           END IF;
           /** Busca o cpf/cnpj do segundo availista **/
           IF nvl(rw_crapepr.nrctaav2,0) <> 0 AND nvl(pr_tpidenti,0) = 0 THEN  
             --Selecionar informacoes avalista
             OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => rw_crapepr.nrctaav2);
             FETCH cr_crapass INTO rw_crapass;
             --Se encontrou
             IF cr_crapass%FOUND AND rw_crapass.nrcpfcgc = pr_nrcpfcgc THEN                        
               --Tipo identificacao
               pr_tpidenti:= 4;  
             END IF;
             --Fechar Cursor
             CLOSE cr_crapass;  
           END IF; 
           --Se for primeiro avalista
           IF nvl(pr_tpidenti,0) = 3 THEN
             pr_nrctaavl:= rw_crapepr.nrctaav1;
           ELSIF nvl(pr_tpidenti,0) = 4 THEN --Segundo avalista
             pr_nrctaavl:= rw_crapepr.nrctaav2;
           END IF;
             
         EXCEPTION
           -- Padrões - 09/10/2018 - Chd REQ0029189
           WHEN vr_exc_saida THEN
             pr_des_reto:= 'NOK';
             -- pr_dscritic:= vr_dscritic; Exclido repasse de erro para não finalizar com erro o processo - 09/10/2018 - Chd REQ0029189
           WHEN vr_exc_others THEN 
             RAISE vr_exc_others; 
           WHEN OTHERS THEN
             -- No caso de erro de programa gravar tabela especifica de log 
             CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
             -- Trata erro
             vr_sqlerrm := SQLERRM;
             RAISE vr_exc_others;  
         END;       
       END pc_busca_dados_emprestimo;  

       /* Procedure para converter arquivos unix */
       PROCEDURE pc_converte_arquivo_txt_unix (pr_caminho  IN  VARCHAR2     --Diretorio dos Arquivos
                                               ,pr_pesq     IN  VARCHAR2     --Filtro dos Arquivos
                                              ) 
       IS 
    /* 
    Programa: pc_crps657
    Sistema : Cooperativa de Credito
    Sigla   : CRED
    Data    : 09/10/2018                              Ultima atualizacao: 31/10/2018
    Autor   : Belli - Envolti - Chamado REQ0029189

    Dados referentes ao programa:

    Frequencia: Disparado pela propria procedure.
    Objetivo  : converter arquivos unix.

    Alteracoes:                
               31/10/2018 - Padrões - Complemento de descrições no retorno de erros.
                           (Belli - Envolti - Chd REQ0031662)

    */                                                                       
       BEGIN
         DECLARE
           --variaveis Locais 
           vr_index    INTEGER;
           -- Variavel vr_cdcritic não utilizada nessa procedure - 31/10/2018 - REQ0031662
           vr_dscritic VARCHAR2(4000);
           -- Eliminada variavel vr_nmarqtmp VARCHAR2(200); -- Belli 
           vr_listadir VARCHAR2(2000);
           vr_nmarqsem VARCHAR2(100);
           --Tabela arquivos
           vr_tab_arqtmp GENE0002.typ_split;
         BEGIN
           -- Posiciona procedure
           vr_cdproint := vr_cdproexe || '.pc_converte_arquivo_txt_unix';
           -- Inclusão do módulo e ação logado
           gene0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
           /* Vamos ler todos os arquivos .txt extraido do arquivo .zip do dia */
           gene0001.pc_lista_arquivos(pr_path     => pr_caminho
                                     ,pr_pesq     => pr_pesq||'.txt'
                                     ,pr_listarq  => vr_listadir
                                     ,pr_des_erro => vr_dscritic);

           -- se ocorrer erro ao recuperar lista de arquivos registra no log
           IF trim(vr_dscritic) IS NOT NULL THEN
             pc_controla_log_batch(pr_cdcritic => 0
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_tpocorre => 1
                                  ,pr_cdcricid => 0
                                   ); 
           END IF;
           -- Retorna módulo e ação logado
           GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
           
           --Carregar a lista de arquivos txt na temp table
           vr_tab_arqtmp:= gene0002.fn_quebra_string(pr_string => vr_listadir); 
           -- Inclusão do módulo e ação logado
           GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);   
           
           --Converte todos os arquivos para formato Unix
           vr_index:= vr_tab_arqtmp.FIRST;
           WHILE vr_index IS NOT NULL LOOP
             --Retirar a extensao do nome do arquivo
             vr_nmarqsem:= substr(vr_tab_arqtmp(vr_index),1,instr(vr_tab_arqtmp(vr_index),'.')-1);
             
             /* Converte o arquivo para formato unix */
             vr_comando:= 'ux2dos '||pr_caminho||'/'||vr_tab_arqtmp(vr_index)||' > '|| 
                                     pr_caminho||'/'||vr_nmarqsem||'_original.txt 2>/dev/null';
             
             --Executar o comando no unix
             GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                  ,pr_des_comando => vr_comando
                                  ,pr_typ_saida   => vr_typ_saida
                                  ,pr_des_saida   => vr_dscritic);
             --Se ocorreu erro dar RAISE
             IF vr_typ_saida = 'ERR' THEN
               pr_cdcritic := 1114; -- Nao foi possivel executar comando unix - 09/10/2018 - Chd REQ0029189
               pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                              ' ' || vr_dscritic; -- ajuste complemento - 31/10/2018 - REQ0031662
               vr_dsparame := vr_dsparame || ' (1) vr_comando:' || vr_comando;
               RAISE vr_exc_erro_tratado;
             END IF;

             /* Remove o arquivo txt extraido */
             vr_comando:= 'rm '||pr_caminho||'/'||vr_tab_arqtmp(vr_index)||' 1> /dev/null';

             --Executar o comando no unix
             GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                  ,pr_des_comando => vr_comando
                                  ,pr_typ_saida   => vr_typ_saida
                                  ,pr_des_saida   => vr_dscritic);
             --Se ocorreu erro dar RAISE
             IF vr_typ_saida = 'ERR' THEN
               pr_cdcritic := 1114; -- Nao foi possivel executar comando unix - 09/10/2018 - Chd REQ0029189
               pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                              ' ' || vr_dscritic; -- ajuste complmento - 31/10/2018 - REQ0031662
               vr_dsparame := vr_dsparame || ' (2) vr_comando:' || vr_comando;
               RAISE vr_exc_erro_tratado;
             END IF;
             
             --Proximo registro
             vr_index:= vr_tab_arqtmp.NEXT(vr_index);
           END LOOP;                                     
         EXCEPTION
           -- Padrões - 09/10/2018 - Chd REQ0029189
           WHEN vr_exc_erro_tratado THEN
              -- Deixar as descrições já ajustadas - 31/10/2018 - REQ0031662
             RAISE vr_exc_erro_tratado;
           WHEN vr_exc_others THEN 
             RAISE vr_exc_others; 
           WHEN OTHERS THEN
             -- No caso de erro de programa gravar tabela especifica de log 
             CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
             -- Trata erro
             vr_sqlerrm := SQLERRM;
             RAISE vr_exc_others;      
         END;       
       END pc_converte_arquivo_txt_unix;  
         
     ---------------------------------------
     -- Inicio Bloco Principal PC_CRPS657
     ---------------------------------------
     BEGIN

       --Limpar parametros saida
       pr_cdcritic:= NULL;
       pr_dscritic:= NULL;

       -- Incluir nome do modulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                 ,pr_action => NULL);
  
       vr_dsparame := ' pr_cdcooper:'  || pr_cdcooper ||
                      ', pr_nmdatela:' || pr_nmdatela;
       vr_tpocorre := 2;

       -- Validacoes iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 0
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_cdcritic => vr_cdcritic);

       --Se retornou critica aborta programa
       IF NVL(vr_cdcritic,0) <> 0 THEN
         --Descricao do erro recebe mensagam da critica
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;       
       -- Verifica se a cooperativa esta cadastrada
       OPEN cr_crapcop(pr_cdcooper => 3);
       FETCH cr_crapcop INTO rw_crapcop;
       -- Se nao encontrar
       IF cr_crapcop%NOTFOUND THEN
         -- Fechar o cursor pois havera raise
         CLOSE cr_crapcop;
         -- Montar mensagem de critica
         vr_cdcritic:= 651;
         vr_tpocorre := 1;
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
       END IF;

       -- Verifica se a data esta cadastrada
       OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
       -- Se nao encontrar
       IF BTCH0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois havera raise
         CLOSE BTCH0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic := 1;
         vr_tpocorre := 1;
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE BTCH0001.cr_crapdat;
       END IF;

       -- Busca do diretorio micros da cooperativa
       vr_endarqui:= gene0001.fn_diretorio(pr_tpdireto => 'M' -- /micros/coop
                                          ,pr_cdcooper => rw_crapcop.cdcooper
                                          ,pr_nmsubdir => '/cyber/recebe/'); 
       --Arquivos que serao procurados                                   
       vr_nmtmpzip:= '%LEGADO.zip';  
       
       /* Vamos ler todos os arquivos .zip */
       gene0001.pc_lista_arquivos(pr_path     => vr_endarqui
                                 ,pr_pesq     => vr_nmtmpzip
                                 ,pr_listarq  => vr_listadir
                                 ,pr_des_erro => vr_dscritic);
       -- se ocorrer erro ao recuperar lista de arquivos registra no log
       IF trim(vr_dscritic) IS NOT NULL THEN                                                    
         --Montar Mensagem para log - Buscar mensagem - 09/10/2018 - Chd REQ0029189
         vr_cdcritic := 0;
         vr_dscritic := vr_dscritic;
         vr_dsparame := vr_dsparame || 
                        ', pr_path:' || vr_endarqui || 
                        ', pr_pesq:' || vr_nmtmpzip;
         --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;
       
       IF vr_listadir IS NULL THEN                                                                                                                    
         vr_cdcritic := 182; -- Arquivo nao existe - 09/10/2018 - Chd REQ0029189
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         --Imprimir mensagem no log
         pc_controla_log_batch( pr_dstiplog   => 'O'
                               ,pr_tpocorre   => 4
                               ,pr_cdcritic   => vr_cdcritic
                               ,pr_dscritic   => vr_dscritic || 
                                                 ' '         || vr_dsparame || 
                                                 ', pr_path:' || vr_endarqui || 
                                                 ', pr_pesq:' || vr_nmtmpzip
                              );                 
         -- Saida sem erro e sem arquivo
         RAISE vr_exc_fimprg;                                                  
       END IF;

       --Carregar a lista de arquivos na temp table
       vr_tab_arqzip:= gene0002.fn_quebra_string(pr_string => vr_listadir);
       vr_dspardat  := vr_dsparame;
       --Filtrar os arquivos da lista
       IF vr_tab_arqzip.count > 0 THEN
         vr_nrindice:= vr_tab_arqzip.first;
         -- carrega informacoes na cratqrq
         WHILE vr_nrindice IS NOT NULL LOOP
           --Filtrar a data apartir do Nome arquivo
           vr_nmtmparq := SUBSTR(vr_tab_arqzip(vr_nrindice),1,8);
           vr_dsparame := vr_dspardat ||
                          ', vr_nmtmparq:'   || vr_nmtmparq ||
                          ', vr_nrindice:'   || vr_nrindice ||
                          ', vr_tab_arqzip:' || vr_tab_arqzip(vr_nrindice); 
           --Transformar em Data
           vr_dtarquiv:= TO_DATE(vr_nmtmparq,'YYYYMMDD');
           --Data Arquivo entre a data anterior e proximo dia util
           IF vr_dtarquiv > rw_crapdat.dtmvtoan AND vr_dtarquiv < rw_crapdat.dtmvtopr THEN
             --Incrementar quantidade arquivos
             vr_contarqv:= vr_tab_arqzip.count + 1;
             --Proximo Registro
             vr_nrindice:= vr_tab_arqzip.next(vr_nrindice);
           ELSE  
             --Diminuir quantidade arquivos
             vr_contarqv:= vr_tab_arqzip.count - 1;
             --Salvar Proximo Registro
             vr_bkpndice:= vr_tab_arqzip.next(vr_nrindice);
             --Retirar o arquivo da lista
             vr_tab_arqzip.DELETE(vr_nrindice);
             --Setar o proximo (backup) no indice 
             vr_nrindice:= vr_bkpndice;
           END IF;
         END LOOP;
       END IF;        
       vr_dsparame := vr_dspardat;   
       
       -- Buscar Primeiro arquivo da temp table
       vr_nrindice:= vr_tab_arqzip.FIRST;
       
       IF vr_nrindice IS NULL THEN                                                                                                                   
         vr_cdcritic := 173; -- Nome do arquivo nao confere com o seu conteudo - 09/10/2018 - Chd REQ0029189
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         --Imprimir mensagem no log
         pc_controla_log_batch( pr_dstiplog   => 'O'
                               ,pr_tpocorre   => 4
                               ,pr_cdcritic   => vr_cdcritic
                               ,pr_dscritic   => vr_dscritic || 
                                                 ' '         || vr_dsparame || 
                                                 ', pr_path:' || vr_endarqui || 
                                                 ', pr_pesq:' || vr_nmtmpzip ||
                                                 ', dtarquiv:' || vr_dtarquiv  ||
                                                 ', dtmvtoan:' || rw_crapdat.dtmvtoan  ||
                                                 ', dtmvtopr:' || rw_crapdat.dtmvtopr 
                              );   
         -- Saida sem erro e sem arquivo
         RAISE vr_exc_fimprg;                   
       END IF;       
       
       vr_dspardat  := vr_dsparame;       
       --Processar os arquivos lidos
       WHILE vr_nrindice IS NOT NULL LOOP
         --Nome Arquivo zip
         vr_nmarqzip:= vr_tab_arqzip(vr_nrindice);
         
         vr_dsparame := vr_dspardat ||
                        ', vr_nmarqzip:'   || vr_nmarqzip; 
         
         --Nome do arquivo sem extensao
         vr_nmtmparq:= SUBSTR(vr_nmarqzip,1,LENGTH(vr_nmarqzip)-4);         
         
         /* Montar Comando para eliminar arquivos do diretorio */
         vr_comando:= 'rm '||vr_endarqui||'/'||vr_nmtmparq||'/*.txt 1> /dev/null';

         --Executar o comando no unix
         GENE0001.pc_OScommand(pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);

         --Se ocorreu erro dar RAISE
         IF vr_typ_saida = 'ERR' THEN
           vr_cdcritic := 1114; -- Nao foi possivel executar comando unix - 15/03/2018 - Chamado 801483
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)  ||
                          ' ' || vr_dscritic; -- ajuste complemento - 31/10/2018 - REQ0031662           
           vr_dsparame := vr_dsparame || ' (3) vr_comando:' || vr_comando;
           RAISE vr_exc_saida;
         END IF;
         
         /* Remover o diretorio caso exista */
         vr_comando:= 'rmdir '||vr_endarqui||'/'||vr_nmtmparq||' 1> /dev/null';

         --Executar o comando no unix
         GENE0001.pc_OScommand(pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);

         --Se ocorreu erro dar RAISE
         IF vr_typ_saida = 'ERR' THEN
           vr_cdcritic := 1114; -- Nao foi possivel executar comando unix - 15/03/2018 - Chamado 801483
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                          ' ' || vr_dscritic; -- ajuste complemento - 31/10/2018 - REQ0031662         
           vr_dsparame := vr_dsparame || ' (4) vr_comando:' || vr_comando;
           RAISE vr_exc_saida;
         END IF;
         
         /* Criar o diretorio com o nome do arquivo */
         vr_comando:= 'mkdir '||vr_endarqui||'/'||vr_nmtmparq||' 1> /dev/null';

         --Executar o comando no unix
         GENE0001.pc_OScommand(pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);

         --Se ocorreu erro dar RAISE
         IF vr_typ_saida = 'ERR' THEN
           vr_cdcritic := 1114; -- Nao foi possivel executar comando unix - 15/03/2018 - Chamado 801483
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                          ' ' || vr_dscritic; -- ajuste complemento - 31/10/2018 - REQ0031662        
           vr_dsparame := vr_dsparame || ' (5) vr_comando:' || vr_comando;
           RAISE vr_exc_saida;
         END IF;
         
         --Executar Extracao do arquivo zip
         gene0002.pc_zipcecred (pr_cdcooper => rw_crapcop.cdcooper
                               ,pr_tpfuncao => 'E'
                               ,pr_dsorigem => vr_endarqui||'/'||vr_nmarqzip
                               ,pr_dsdestin => vr_endarqui||'/'||vr_nmtmparq
                               ,pr_dspasswd => NULL 
                               ,pr_flsilent => 'S'
                               ,pr_des_erro => vr_dscritic);
         --Se ocorreu erro
         IF vr_dscritic IS NOT NULL THEN
           --Montar Mensagem para log - Buscar mensagem - 09/10/2018 - Chd REQ0029189
           vr_cdcritic := 0;
           vr_dscritic := vr_dscritic;
           vr_dsparame := vr_dsparame || 
                          ',pr_cdcooper:' || rw_crapcop.cdcooper || 
                          ',pr_tpfuncao:' || 'E' ||
                          ',pr_dsorigem:' || vr_endarqui||'/'||vr_nmarqzip ||
                          ',pr_dsdestin:' || vr_endarqui||'/'||vr_nmtmparq ||
                          ',pr_dspasswd:' || 'NULL' ||
                          ',pr_flsilent:' || 'S';
           --Levantar Excecao
           RAISE vr_exc_saida;
         END IF;                        

         /* Lista todos os arquivos .txt do diretorio criado */
         vr_endarqtxt:= vr_endarqui||'/'||vr_nmtmparq;

         /* Converte cada arquivo texto para formato UNIX */
         pc_converte_arquivo_txt_unix (pr_caminho  => vr_endarqtxt    --Diretorio Arquivos
                                      ,pr_pesq     => '%BUREAU_out'); --Filtro Arquivos
         -- Retorno nome do módulo logado
         GENE0001.pc_set_modulo(pr_module => vr_cdproexe, pr_action => NULL);
         
         --Buscar todos os arquivos extraidos na nova pasta
         gene0001.pc_lista_arquivos(pr_path     => vr_endarqtxt
                                   ,pr_pesq     => '%BUREAU_out_original.txt'
                                   ,pr_listarq  => vr_listadir
                                   ,pr_des_erro => vr_dscritic);

         -- se ocorrer erro ao recuperar lista de arquivos registra no log
         IF trim(vr_dscritic) IS NOT NULL THEN
           --Montar Mensagem para log - Buscar mensagem - 09/10/2018 - Chd REQ0029189
           vr_cdcritic := 0;
           vr_dscritic := vr_dscritic;
           vr_dsparame := vr_dsparame || 
                          ', pr_path:' || vr_endarqtxt || 
                          ', pr_pesq:' || '%BUREAU_out_original.txt';
           --Levantar Excecao
           RAISE vr_exc_saida;
         END IF;

         --Carregar a lista de arquivos na temp table
         vr_tab_arqtxt:= gene0002.fn_quebra_string(pr_string => vr_listadir); 
         
         --Se possuir arquivos no diretorio
         IF vr_tab_arqtxt.COUNT > 0 THEN
           
           vr_dspartxt  := vr_dsparame;   
           --Selecionar primeiro arquivo
           vr_idx_txt:= vr_tab_arqtxt.FIRST;
           --Percorrer todos os arquivos lidos
           WHILE vr_idx_txt IS NOT NULL LOOP
             
             --Nome do arquivo
             vr_nmarqtxt:= vr_tab_arqtxt(vr_idx_txt);
         
             vr_dsparame := vr_dspartxt || ', vr_nmarqtxt:' || vr_nmarqtxt; 
                        
             --Montar Mensagem para log - Buscar mensagem - 09/10/2018 - Chd REQ0029189
             vr_cdcritic := 219;
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
             --Imprimir mensagem no log
             pc_controla_log_batch( pr_dstiplog   => 'O'
                                   ,pr_tpocorre   => 4
                                   ,pr_cdcritic   => vr_cdcritic
                                   ,pr_dscritic   => vr_dscritic || 
                                                     vr_dsparame || 
                                                     ', pr_nmdireto:' || vr_endarqtxt || 
                                                     ', vr_nmarqtxt:' || vr_nmarqtxt
                                  );  
             vr_cdcritic := NULL;
             vr_dscritic := NULL;
             --Abrir o arquivo lido 
             gene0001.pc_abre_arquivo(pr_nmdireto => vr_endarqtxt   --> Diretório do arquivo
                                     ,pr_nmarquiv => vr_nmarqtxt    --> Nome do arquivo
                                     ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                                     ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                     ,pr_des_erro => vr_dscritic);  --> Erro
             IF vr_dscritic IS NOT NULL THEN
               --Montar Mensagem para log - Buscar mensagem - 09/10/2018 - Chd REQ0029189
               vr_cdcritic := 0;
               vr_dsparame := vr_dsparame || ', vr_dscritic:' || vr_dscritic;
               --Levantar Excecao
               RAISE vr_exc_saida;
             END IF;
             
             vr_dsparlin := vr_dsparame;
             vr_ctlinha  := 0;      
             LOOP
               BEGIN
                 --Criar savepoint para desfazer transacoes
                 SAVEPOINT save_trans;
                 --Verificar se o arquivo está aberto
                 IF  utl_file.IS_OPEN(vr_input_file) THEN
                   BEGIN
                     -- Le os dados do arquivo e coloca na variavel vr_setlinha
                     gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                 ,pr_des_text => vr_setlinha); --> Texto lido
                   EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                       --Fim do arquivo
                       RAISE vr_exc_final;
                   END;                                  
                 END IF; --Arquivo aberto
                 
                 vr_ctlinha  := vr_ctlinha + 1;      
                 vr_dsparame := vr_dsparlin || 
                                ', vr_ctlinha:' || vr_ctlinha  || 
                                ', ds_linha:'   || vr_setlinha;
                 
                 --Se a linha estiver em branco ou Cooperativa estiver Inativa
                 IF TRIM(vr_setlinha) IS NULL OR 
                    SUBSTR(vr_setlinha,1,1) IN (' ',chr(10),chr(13)) OR 
                    TO_NUMBER(SUBSTR(vr_setlinha,1,4)) IN (4,15) -- Concredi ou Credimilsul
                 THEN
                   --Pular para proxima linha do arquivo
                   RAISE vr_exc_proximo;
                 END IF;
                 --Limpar tabela erro
                 vr_tab_erro.DELETE;
                 --Limpar Critica
                 vr_dscritic:= NULL;
                 --Atribuir valores lidos
                 vr_cdcooper:= TO_NUMBER(SUBSTR(vr_setlinha,1,4));
                 vr_modalida:= TO_NUMBER(SUBSTR(vr_setlinha,5,4));
                 vr_nrdconta:= TO_NUMBER(SUBSTR(vr_setlinha,9,8));
                 vr_nrctremp:= TO_NUMBER(SUBSTR(vr_setlinha,17,8));
                 vr_nrcpfcgc:= TO_NUMBER(SUBSTR(vr_setlinha,25,14));
                 vr_dtinclus:= TO_DATE(SUBSTR(vr_setlinha,39,10),'DD-MM-YYYY');
                 vr_dtvencto:= TO_DATE(SUBSTR(vr_setlinha,49,10),'DD-MM-YYYY');
                 vr_vldivida:= TO_NUMBER(SUBSTR(vr_setlinha,59,15));
                 vr_nrctrspc:= SUBSTR(vr_setlinha,74,40);
                 --Se a data existir
                 IF TRIM(substr(vr_setlinha,114,10)) IS NOT NULL THEN
                   vr_dtdbaixa:= TO_DATE(SUBSTR(vr_setlinha,114,10),'DD-MM-YYYY');
                 ELSE
                   vr_dtdbaixa:= NULL;
                 END IF;    
                 vr_dsobsbxa:= SUBSTR(vr_setlinha,125,60);
                 vr_tpinsttu:= TO_NUMBER(SUBSTR(vr_setlinha,185,2));
                 vr_tpidenti:= 0;
                 vr_nrctaavl:= 0;
                 vr_nrdrowid:= NULL;

                 --Valor Divida maior zero
                 IF nvl(vr_vldivida,0) > 0 THEN
                   vr_vldivida:= vr_vldivida / 100;
                 END IF;  
                 /* Quando for serasa pegar o proximo dia util da data de inclusao do arquivo texto */ 
                 IF vr_tpinsttu = 2 THEN
                   --Data Inclusao diferente 03/NOV/2013
                   IF vr_dtinclus <> to_date('03/11/2013','DD/MM/YYYY') THEN
                     --Proximo dia util
                     vr_dtinclus:= GENE0005.fn_valida_dia_util(pr_cdcooper => vr_cdcooper 
                                                              ,pr_dtmvtolt => vr_dtinclus + 1
                                                              ,pr_tipo => 'P');
                   END IF;
                 END IF;    
                 /* Vamos verificar se a conta está na tabela de associado */
                 OPEN cr_crapass (pr_cdcooper => vr_cdcooper
                                 ,pr_nrdconta => vr_nrdconta);
                 FETCH cr_crapass INTO rw_crapass;
                 --Se nao encontrou
                 IF cr_crapass%NOTFOUND THEN
                   --Montar Mensagem para log
                   vr_cdcritic:= 9;
                   --Buscar mensagem
                   vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                   --Gerar log importacao
                   pc_gera_log_importacao(pr_cdcritic => vr_cdcritic    --> cd Critica
                                         ,pr_dscritic => vr_dscritic    --> Critica
                                         ,pr_cdcopcnt => vr_cdcooper    --> Cooperativa da conta corrente
                                         ,pr_nrdconta => vr_nrdconta    --> Conta
                                         ,pr_nrctremp => vr_nrctremp    --> Contrato Emprestimo
                                         ,pr_nrcpfcgc => vr_nrcpfcgc    --> Cpf/Cnpj
                                         ,pr_tpinsttu => vr_tpinsttu    --> Tipo Instrucao
                                         );
                   -- Retorna módulo e ação logado
                   GENE0001.pc_set_modulo(pr_module => vr_cdproexe, pr_action => NULL);        
                   --Fechar Cursor
                   CLOSE cr_crapass;
                   --Proximo registro
                   RAISE vr_exc_proximo;
                 END IF;                  
                 --Fechar Cursor
                 CLOSE cr_crapass; 
                 --Verificar Cpf associado
                 IF rw_crapass.nrcpfcgc = vr_nrcpfcgc THEN
                   vr_tpidenti:= 1;
                 ELSE
                   --Buscar Dados Emprestimo
                   pc_busca_dados_emprestimo (pr_cdcooper => vr_cdcooper    --> Cooperativa
                                             ,pr_cdagenci => vr_cdagenci    --> Agencia
                                             ,pr_nrdcaixa => vr_nrdcaixa    --> Caixa
                                             ,pr_nrdconta => vr_nrdconta    --> Conta
                                             ,pr_nrctremp => vr_nrctremp    --> Contrato Emprestimo
                                             ,pr_nrcpfcgc => vr_nrcpfcgc    --> Cpf/Cnpj
                                             ,pr_tpidenti => vr_tpidenti    --> Tipo Identificacao 
                                             ,pr_nrctaavl => vr_nrctaavl    --> Numero Conta Avalista 1
                                             ,pr_tab_erro => vr_tab_erro    --> Tabela Critica
                                             ,pr_des_reto => vr_des_erro);  --> Retorno de erro
                   --Se ocorreu erro
                   IF vr_des_erro <> 'OK' THEN
                     --Se possui erro na tabela
                     IF vr_tab_erro.count > 0 THEN
                       --mensagem critica
                       vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                       vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                       --Gerar log importacao
                       pc_gera_log_importacao(pr_cdcritic => vr_cdcritic  --> cd Critica
                                             ,pr_dscritic => vr_dscritic  --> Critica
                                             ,pr_cdcopcnt => vr_cdcooper  --> Cooperativa da conta corrente
                                             ,pr_nrdconta => vr_nrdconta  --> Conta
                                             ,pr_nrctremp => vr_nrctremp  --> Contrato Emprestimo
                                             ,pr_nrcpfcgc => vr_nrcpfcgc  --> Cpf/Cnpj
                                             ,pr_tpinsttu => vr_tpinsttu  --> Tipo Instrucao
                                             );
                       -- Retorna módulo e ação logado
                       GENE0001.pc_set_modulo(pr_module => vr_cdproexe, pr_action => NULL);
                     END IF;  
                     --Proximo registro
                     RAISE vr_exc_proximo;
                   END IF; 
                   -- Retorna módulo e ação logado
                   GENE0001.pc_set_modulo(pr_module => vr_cdproexe, pr_action => NULL);                          
                 END IF;
                 
                 /* Caso nao foi encontrado o motivo de debito, vamos catalogar o erro*/
                 IF nvl(vr_tpidenti,0) = 0 THEN
                   --Proximo registro
                   RAISE vr_exc_proximo;
                 END IF;
                 
                 --Selecionar cadastro spc
                 OPEN cr_crapspc (pr_cdcooper => vr_cdcooper
                                 ,pr_nrdconta => vr_nrdconta
                                 ,pr_nrcpfcgc => vr_nrcpfcgc
                                 ,pr_nrctremp => vr_nrctremp
                                 ,pr_dtinclus => vr_dtinclus);
                 FETCH cr_crapspc INTO rw_crapspc;
                 --Determinar se encontrou
                 vr_crapspc:= cr_crapspc%FOUND;
                 --Fechar Cursor
                 CLOSE cr_crapspc;             
                 --Data de Baixa Preenchida     
                 IF vr_dtdbaixa IS NOT NULL THEN
                   --Se nao encontrou spc
                   IF NOT vr_crapspc THEN
                     --Proximo registro
                     RAISE vr_exc_proximo;                    
                   END IF;
                   --Retornar rowid
                   vr_nrdrowid:= rw_crapspc.rowid;
                   --Opcao = baixar
                   vr_cddopcao:= 'B';  
                 ELSE  
                   --Se encontrou SPC
                   IF vr_crapspc THEN
                     --Proximo registro
                     RAISE vr_exc_proximo;  
                   END IF;
                   --Opcao = Inclusao
                   vr_cddopcao:= 'I';    
                 END IF;
                 /* Validar Os Dados do Contrato de Emprestimo */
                 CYBE0001.pc_valida_dados (pr_cdcooper => vr_cdcooper         --> Cooperativa conectada
                                          ,pr_cdagenci => vr_cdagenci         --> Código da agência
                                          ,pr_nrdcaixa => vr_nrdcaixa         --> Número do caixa
                                          ,pr_idorigem => 1 /* pr_idorigem */ --> Id do módulo de sistema
                                          ,pr_cddopcao => vr_cddopcao         --> Codigo opcao
                                          ,pr_cdoperad => 1 /* pr_cdoperad */ --> Código do Operador
                                          ,pr_nrdconta => vr_nrdconta         --> Número da conta
                                          ,pr_nrcpfcgc => vr_nrcpfcgc         --> Numero Cpf/Cnpj
                                          ,pr_tpidenti => vr_tpidenti         --> Tipo identificacao
                                          ,pr_dtvencto => vr_dtvencto         --> Data Vencimento
                                          ,pr_dtinclus => vr_dtinclus         --> Data Inclusao
                                          ,pr_vldivida => vr_vldivida         --> Valor da dívida
                                          ,pr_tpinsttu => vr_tpinsttu         --> Tipo Instrucao
                                          ,pr_dtdbaixa => vr_dtdbaixa         --> Data de Baixa
                                          ,pr_nmdcampo => vr_nmdcampo         --> Nome do Campo
                                          ,pr_dsinsttu => vr_dsinsttu         --> Descricao Instrucao
                                          ,pr_operador => vr_operador         --> Nome operador
                                          ,pr_des_reto => vr_des_erro         --> Retorno OK / NOK
                                          ,pr_tab_erro => vr_tab_erro);       --> Tabela com possíves erros
                 IF vr_des_erro <> 'OK' THEN
                   --Se possui erro na tabela
                   IF vr_tab_erro.count > 0 THEN
                     --Montar Mensagem
                     vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                     vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                     --Gerar log importacao
                     pc_gera_log_importacao(pr_cdcritic => vr_cdcritic    --> cd Critica
                                           ,pr_dscritic => vr_dscritic    --> Critica
                                           ,pr_cdcopcnt => vr_cdcooper    --> Cooperativa da conta corrente
                                           ,pr_nrdconta => vr_nrdconta    --> Conta
                                           ,pr_nrctremp => vr_nrctremp    --> Contrato Emprestimo
                                           ,pr_nrcpfcgc => vr_nrcpfcgc    --> Cpf/Cnpj
                                           ,pr_tpinsttu => vr_tpinsttu    --> Tipo Instrucao
                                           );
                     -- Retorna módulo e ação logado
                     GENE0001.pc_set_modulo(pr_module => vr_cdproexe, pr_action => NULL);
                   END IF;  
                   --Proximo registro
                   RAISE vr_exc_proximo;
                 END IF;  
                 -- Retorna módulo e ação logado
                 GENE0001.pc_set_modulo(pr_module => vr_cdproexe, pr_action => NULL);

                 /* Gravar Os Dados do Contrato de Emprestimo */
                 CYBE0001.pc_grava_dados  (pr_cdcooper => vr_cdcooper         --> Cooperativa conectada
                                          ,pr_cdagenci => vr_cdagenci         --> Código da agência
                                          ,pr_nrdcaixa => vr_nrdcaixa         --> Número do caixa
                                          ,pr_idorigem => 1 /* pr_idorigem */ --> Id do módulo de sistema
                                          ,pr_nmdatela => vr_cdprogra         --> Nome Programa
                                          ,pr_cdoperad => 1 /* pr_cdoperad */ --> Código do Operador
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data Movimento
                                          ,pr_cddopcao => vr_cddopcao         --> Codigo opcao
                                          ,pr_nrcpfcgc => vr_nrcpfcgc         --> Numero Cpf/Cnpj
                                          ,pr_nrdconta => vr_nrdconta         --> Número da conta
                                          ,pr_tpidenti => vr_tpidenti         --> Tipo identificacao
                                          ,pr_nrctremp => vr_nrctremp         --> Numero Contrato
                                          ,pr_tpctrdev => vr_modalida         --> modalidade
                                          ,pr_dtinclus => vr_dtinclus         --> Data Inclusao
                                          ,pr_nrctrspc => vr_nrctrspc         --> Numero Contrato SPC
                                          ,pr_dtvencto => vr_dtvencto         --> Data Vencimento
                                          ,pr_vldivida => vr_vldivida         --> Valor da dívida
                                          ,pr_tpinsttu => vr_tpinsttu         --> Tipo Instrucao
                                          ,pr_dsoberv1 => 'CYBER crps657'     --> Observacao 1
                                          ,pr_dtdbaixa => vr_dtdbaixa         --> Data de Baixa
                                          ,pr_dsoberv2 => NULL                --> Observacao 2
                                          ,pr_nrctaavl => vr_nrctaavl         --> Numero Conta Avalista
                                          ,pr_nrdrowid => vr_nrdrowid         --> Numero Rowid
                                          ,pr_des_reto => vr_des_erro         --> Retorno OK / NOK
                                          ,pr_tab_erro => vr_tab_erro);       --> Tabela com possíves erros
                 IF vr_des_erro <> 'OK' THEN
                   --Se possui erro na tabela
                   IF vr_tab_erro.count > 0 THEN
                     --Montar Mensagem
                     vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                     vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                     --Gerar log importacao
                     pc_gera_log_importacao(pr_cdcritic => vr_cdcritic    --> cd Critica
                                           ,pr_dscritic => vr_dscritic    --> Critica
                                           ,pr_cdcopcnt => vr_cdcooper    --> Cooperativa da conta corrente
                                           ,pr_nrdconta => vr_nrdconta    --> Conta
                                           ,pr_nrctremp => vr_nrctremp    --> Contrato Emprestimo
                                           ,pr_nrcpfcgc => vr_nrcpfcgc    --> Cpf/Cnpj
                                           ,pr_tpinsttu => vr_tpinsttu    --> Tipo Instrucao
                                           );
                     -- Retorna módulo e ação logado
                     GENE0001.pc_set_modulo(pr_module => vr_cdproexe, pr_action => NULL);
                   END IF;  
                   --Proximo registro
                   RAISE vr_exc_proximo; 
                 END IF; 
                 -- Retorna módulo e ação logado
                 GENE0001.pc_set_modulo(pr_module => vr_cdproexe, pr_action => NULL); 
               EXCEPTION -- Padrões - 09/10/2018 - Chd REQ0029189
                 WHEN vr_exc_proximo THEN
                   ROLLBACK TO save_trans;
                 WHEN vr_exc_final THEN
                   -- Verificar se Arquivo está aberto
                   IF utl_file.IS_OPEN(vr_input_file) THEN
                     -- Fechar o arquivo
                     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
                   END IF;
                   --Sair do Loop
                   EXIT;
                 WHEN vr_exc_others THEN 
                   RAISE vr_exc_others; 
                 WHEN OTHERS THEN   
                   -- No caso de erro de programa gravar tabela especifica de log
                   cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
                   -- Trata erro
                   vr_sqlerrm  := SQLERRM;
                   RAISE vr_exc_others;    
               END;       
             END LOOP; --Linhas do arquivo   
                          
             vr_dsparame := vr_dsparlin;                                                                                                                   
             vr_cdcritic := 190; -- ARQUIVO INTEGRADO - 09/10/2018 - Chd REQ0029189
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
             --Imprimir mensagem no log
             pc_controla_log_batch( pr_dstiplog   => 'O'
                                   ,pr_tpocorre   => 4
                                   ,pr_cdcritic   => vr_cdcritic
                                   ,pr_dscritic   => vr_dscritic || 
                                                     vr_dsparame
                                  );  
             vr_cdcritic := NULL;
             vr_dscritic := NULL;                    
                                                           
             --Buscar proximo arquivo
             vr_idx_txt:= vr_tab_arqtxt.NEXT(vr_idx_txt);    
           END LOOP; --Arquivo txt 
           
           vr_dsparame := vr_dspartxt; 
           
           /* Remove o diretorio criado */
           vr_comando:= 'rm -rf '||vr_endarqui||'/'||vr_nmtmparq||' 1> /dev/null';

           --Executar o comando no unix
           GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                ,pr_des_comando => vr_comando
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => vr_dscritic);
           --Se ocorreu erro dar RAISE
           IF vr_typ_saida = 'ERR' THEN
             vr_cdcritic := 1114; -- Nao foi possivel executar comando unix - 15/03/2018 - Chamado 801483
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                            ' ' || vr_dscritic; -- ajuste complemento - 31/10/2018 - REQ0031662        
             vr_dsparame := vr_dsparame || ' (6) vr_comando:' || vr_comando;
             RAISE vr_exc_saida;
           END IF; 
           
           /* Renomear os arquivos .txt que foram processados */
           vr_comando:= 'mv '||vr_endarqui||'/'||vr_nmtmparq||'.zip '||
                        vr_endarqui||'/'||vr_nmtmparq||'_processado.pro 1> /dev/null';
           --Executar o comando no unix
           GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                ,pr_des_comando => vr_comando
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => vr_dscritic);
           --Se ocorreu erro dar RAISE
           IF vr_typ_saida = 'ERR' THEN
             vr_cdcritic := 1114; -- Nao foi possivel executar comando unix - 15/03/2018 - Chamado 801483
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                            ' ' || vr_dscritic; -- ajuste complemento - 31/10/2018 - REQ0031662        
             vr_dsparame := vr_dsparame || ' (7) vr_comando:' || vr_comando;
             RAISE vr_exc_saida;
           END IF; 
                                                      
         END IF;  
         --Proximo arquivo zip da lista
         vr_nrindice:= vr_tab_arqzip.NEXT(vr_nrindice);
       END LOOP; --Arquivos zip 
       
       vr_dsparame := vr_dspardat;           
       -- pc_limpa_tabela; Limpar Tabela - excluida - 09/10/2018 - Chd REQ0029189       
       
       -- Processo OK, devemos chamar a fimprg
       btch0001.pc_valida_fimprg (pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);

       --Salvar informacoes no banco de dados
       COMMIT;
       
			 -- PRJ573
			 cybe0004.pc_importa_arquivo_cpc(pr_des_reto => vr_des_erro
			                                ,pr_dscritic => pr_dscritic
																			);
       --
			 IF pr_dscritic IS NOT NULL OR
				  vr_des_erro <> 'OK' THEN
				 --
				 RAISE vr_exc_saida;
				 --
			 END IF;
       
       -- Limpa módulo e ação logado
       GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
       
     EXCEPTION
       -- Padrões - 09/10/2018 - Chd REQ0029189
       WHEN vr_exc_fimprg THEN       
         -- Processo OK, devemos chamar a fimprg
         btch0001.pc_valida_fimprg (pr_cdcooper => pr_cdcooper
                                   ,pr_cdprogra => vr_cdprogra
                                   ,pr_infimsol => pr_infimsol
                                   ,pr_stprogra => pr_stprogra);
         --Salvar informacoes no banco de dados
         COMMIT;       
         -- Limpa módulo e ação logado
         GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
       WHEN vr_exc_erro_tratado THEN
         -- Monta mensagem
         pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic
                                                 ,pr_dscritic => pr_dscritic) ||
                        ' ' || vr_dsparame;                   
         -- Log de erro de execucao
         pc_controla_log_batch(pr_cdcritic => pr_cdcritic
                              ,pr_dscritic => pr_dscritic);         
       WHEN vr_exc_saida THEN
         -- Devolvemos codigo e critica encontradas
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic
                                                 ,pr_dscritic => vr_dscritic) || 
                        ' ' || vr_dsparame; 
         -- Log de erro de execucao
         pc_controla_log_batch(pr_cdcritic => pr_cdcritic
                              ,pr_dscritic => pr_dscritic
                              ,pr_tpocorre => vr_tpocorre);
         -- Efetuar rollback
         ROLLBACK;
       WHEN vr_exc_others THEN   
         -- Monta mensagem
         pr_cdcritic := 9999;
         pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                        vr_sqlerrm ||
                        '. ' || vr_dsparame; 
         -- Log de erro de execucao
         pc_controla_log_batch(pr_cdcritic => pr_cdcritic
                              ,pr_dscritic => pr_dscritic);
         -- Efetuar rollback
         ROLLBACK;
       WHEN OTHERS THEN         
         -- No caso de erro de programa gravar tabela especifica de log 
         CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
         -- Efetuar retorno do erro nao tratado
         pr_cdcritic := 9999;
         pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                        SQLERRM ||
                        '. ' || vr_dsparame;                   
         -- Gravação de Log do processo
         pc_controla_log_batch(pr_dscritic => pr_dscritic
                              ,pr_cdcritic => pr_cdcritic
                              );
         -- Efetuar rollback
         ROLLBACK;
     END;
   END PC_CRPS657;
/
