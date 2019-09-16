CREATE OR REPLACE PACKAGE CECRED.GENE0002 AS

  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : GENE0002
    Sistema  : Rotinas genéricas para mascaras e relatórios
    Sigla    : GENE
    Autor    : Marcos E. Martini - Supero
    Data     : Novembro/2012.                   Ultima atualizacao: 04/08/2017
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Definir variaveis e funções para auxilio de mascaras e rotinas de relatórios
                
               27/02/2015 - Incluido o nome do arquivo .pdf no retorno da variavel pr_nmarqpdf,
                            feito tratamento para arquivos .lst na procedure pc_envia_arquivo_web
                            (Jean Michel).                  
  
               22/09/2015 - Adicionar validação na procedure pc_solicita_relato para quando o 
                            relatorio for solicitado durante o processo batch, o erro seja escrito
                            no proc_batch, caso contrario no proc_message (Douglas - Chamado 306525)

               05/02/2016 - Realizado ajustes na rotina para efetuar a copia 
                            correta dos arquivos para a intranet
                            (Adriano ).
      
               22/06/2017 - Tratamento de erros 
                          - setado modulo
                          - Chamado 660322 - Belli - Envolti
      
			   10/10/2017 - Alteracoes melhoria 407 (Mauricio - Mouts)
      
  ------------------------------------------------------------------------------------------------------------------*/

  /* Tabela de memória para armazenar os separadores de milhar e casas decimais
     limitando o número de execuções do contexto SQL para buscar estes parametros
     melhorando a performance */
  TYPE typ_reg_nlspar IS
    RECORD(dssepmil VARCHAR2(1)
          ,dssepdec VARCHAR2(1));
  TYPE typ_tab_nlspar IS TABLE OF typ_reg_nlspar INDEX BY PLS_INTEGER;
  vr_nlspar typ_tab_nlspar;

  -- Tabela de memória para armazenar o conteudo de um arquivo XML
  TYPE typ_reg_tabela IS
    RECORD(dslinha varchar2(1000));
  TYPE typ_tab_tabela IS TABLE OF typ_reg_tabela INDEX BY PLS_INTEGER;

  /* Função genérica para aplicar uma maskara ao conteudo passado */
  FUNCTION fn_mask(pr_dsorigi IN VARCHAR2
                  ,pr_dsforma IN VARCHAR2) RETURN VARCHAR2;

  /* Função para mascarar o Nro da Conta */
  FUNCTION fn_mask_conta(pr_nrdconta IN crapass.nrdconta%TYPE) RETURN VARCHAR2;

  /* Função para mascarar a Conta Integração */
  FUNCTION fn_mask_ctitg(pr_nrdctitg IN crapass.nrdctitg%TYPE) RETURN VARCHAR2;

  /* Função para mascarar o CPF ou CNPJ */
  FUNCTION fn_mask_cpf_cnpj(pr_nrcpfcgc IN crapass.nrcpfcgc%type,
                            pr_inpessoa in crapass.inpessoa%type) RETURN VARCHAR2;

  /* Função para mascarar o CEP */
  FUNCTION fn_mask_cep(pr_nrcepend IN crapenc.nrcepend%TYPE) RETURN VARCHAR2;

  /* Função para mascarar a matrícula */
  FUNCTION fn_mask_matric(pr_nrmatric IN crapass.nrmatric%TYPE) RETURN VARCHAR2;

  /* Função para mascarar o contrato */
  FUNCTION fn_mask_contrato(pr_nrcontrato IN crapepr.nrctremp%TYPE) RETURN VARCHAR2;

  /* Calcular as horas e minutos com base nos segundos informados */
  FUNCTION fn_calc_hora(pr_segundos IN PLS_INTEGER) RETURN VARCHAR2;    --> Segundos decorridos

  /* Funçao para testar se a variável contém numéricos */
  FUNCTION fn_numerico(pr_vlrteste IN VARCHAR2) RETURN BOOLEAN;

  /* Retonar um determinado dado de uma string separado por um delimitador */
  FUNCTION fn_busca_entrada(pr_postext     IN NUMBER                          --> Posicao do parametro desejada
                           ,pr_dstext      IN VARCHAR2                        --> Texto a ser analisado
                           ,pr_delimitador IN VARCHAR2) RETURN VARCHAR2;      --> Delimitador utilizado na string

  /* Declaração de tipo para suprir necessidade da função de quebra de strings */
  TYPE typ_split IS TABLE OF VARCHAR2(32767);

  /* Quebra string com base no delimitador e retorna array de resultados */
  FUNCTION fn_quebra_string(pr_string   IN VARCHAR2                             --> String que será quebrada
                           ,pr_delimit  IN CHAR DEFAULT ',') RETURN typ_split;  --> Delimitador com valor default

  /* Pesquisa por valor informado quebrando a busca pelo delimitador passado */
  FUNCTION fn_existe_valor(pr_base      IN VARCHAR2                    --> String que irá sofrer a busca
                          ,pr_busca     IN VARCHAR2                    --> String objeto de busca
                          ,pr_delimite  IN VARCHAR2) RETURN VARCHAR2;  --> String que será o delimitador

  /* Pesquisa no texto pelas strings de procura sem observar a ordem das mesmas */
  FUNCTION fn_contem(pr_dstexto in varchar2                   --> String que irá sofrer a busca
                    ,pr_dsprocu in varchar2) RETURN VARCHAR2; --> String objeto de busca

  /* Função para converter um arquivo em BLOB */
  FUNCTION fn_arq_para_blob(pr_caminho IN VARCHAR2
                           ,pr_arquivo IN VARCHAR2) RETURN BLOB;

  /* Função para converter um arquivo em CLOB */
  FUNCTION fn_arq_para_clob(pr_caminho IN VARCHAR2
                           ,pr_arquivo IN VARCHAR2) RETURN CLOB;

  /* Procedure para gravar os dados de um BLOB para um arquivo */
  PROCEDURE pc_blob_para_arquivo(pr_blob      IN BLOB     --> Blob com os dados
                                ,pr_caminho   IN VARCHAR2 --> Diretório para saída
                                ,pr_arquivo   IN VARCHAR2 --> Nome do arquivo de saída
                                ,pr_des_erro OUT VARCHAR2);

  /* Procedure para gravar os dados de um CLOB para um arquivo */
  PROCEDURE pc_clob_para_arquivo(pr_clob      IN CLOB     --> Blob com os dados
                                ,pr_caminho   IN VARCHAR2 --> Diretório para saída
                                ,pr_arquivo   IN VARCHAR2 --> Nome do arquivo de saída
                                ,pr_flappend  IN VARCHAR2 DEFAULT 'N' --> Indica que a solicitação irá incrementar o arquivo
                                ,pr_des_erro OUT VARCHAR2);

  /**  Procedure para copiar arquivo PDF para o sistema ayllos web   **/
  PROCEDURE pc_efetua_copia_pdf (pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa conectada
                                ,pr_cdagenci IN INTEGER                   --> Codigo da agencia para erros
                                ,pr_nrdcaixa IN INTEGER                   --> Codigo do caixa para erros
                                ,pr_nmarqpdf IN VARCHAR2                  --> Arquivo PDF  a ser gerado                                 
                                ,pr_des_reto OUT VARCHAR2                 --> Saída com erro
                                ,pr_tab_erro OUT gene0001.typ_tab_erro);  --> tabela de erros

  /** Procedure para copiar arquivos para o sistema InternetBank **/
  PROCEDURE pc_efetua_copia_arq_ib(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa conectada
                                  ,pr_nmarqpdf IN VARCHAR2                  --> Arquivo a ser enviado
                                  ,pr_des_erro OUT VARCHAR2);               --> Saída com erro
  
  PROCEDURE pc_copia_arq_para_download(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa conectada
                                      ,pr_dsdirecp IN VARCHAR2                  --> Diretório do arquivo a ser copiado
                                      ,pr_nmarqucp IN VARCHAR2                  --> Arquivo a ser copiado
                                      ,pr_flgcopia IN NUMBER DEFAULT 1          --> Indica se deve ser feita copia (TRUE = Copiar / FALSE = Mover)
                                      ,pr_dssrvarq OUT VARCHAR2                 --> Nome do servidor onde o arquivo foi postado                                        
                                      ,pr_dsdirarq OUT VARCHAR2                 --> Nome do diretório onde o arquivo foi postado
                                      ,pr_des_erro OUT VARCHAR2);               --> Saída com erro
                                      
  --> Publicar arquivo de controle na intranet
  PROCEDURE pc_publicar_arq_intranet;   
  
  /* Procedure para converter proposta para o formato PDF */
  PROCEDURE pc_gera_pdf_impressao(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa conectada
                                 ,pr_nmarqimp IN VARCHAR2                  --> Arquivo a ser convertido para pDf
                                 ,pr_nmarqpdf IN VARCHAR2                  --> Arquivo PDF  a ser gerado                                 
                                 ,pr_des_erro OUT VARCHAR2);               --> Saída com erro
  
  /* Procedimento para geração de PDFs */
  PROCEDURE pc_cria_PDF(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa conectada
                       ,pr_nmorigem IN VARCHAR2                  --> Path arquivo origem
                       ,pr_ingerenc IN VARCHAR2                  --> SIM/NAO
                       ,pr_tirelato IN VARCHAR2                  --> Tipo (80col, etc..)
                       ,pr_dtrefere IN DATE  DEFAULT NULL        --> Data de referencia
                       ,pr_nmsaida  OUT VARCHAR2                 --> Path do arquivo gerado
                       ,pr_des_erro OUT VARCHAR2);               --> Saída com erro

  --> Procedimento para juntar varios PDFs
  PROCEDURE pc_Juntar_Pdf( pr_dsdirarq  IN VARCHAR2           --> Diretorio de onde se encontram os arquivos PDFs
                         ,pr_lsarqpdf  IN VARCHAR2           --> Lista dos nomes dos arquivos PDFs
                         ,pr_nmpdfsai  IN VARCHAR2           --> Diretorio + nome do arquivo PDF de saida
                         ,pr_dscritic OUT VARCHAR2);        --> Critica caso ocorra
                         
  /* Procedimento para tratamento de arquivos ZIP*/
  PROCEDURE pc_zipcecred(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Cooperativa conectada
                        ,pr_tpfuncao  IN VARCHAR2 DEFAULT 'A'      --> Tipo de função (A-Add;E-Extract;V-View)
                        ,pr_dsorigem  IN VARCHAR2                  --> Lista de arquivos a compactar (separados por espaço) ou arquivo a descompactar
                        ,pr_dsdestin  IN VARCHAR2                  --> Caminho para o arquivo Zip a gerar ou caminho de destino dos arquivos descompactados
                        ,pr_dspasswd  IN VARCHAR2                  --> Password a incluir no arquivo
                        ,pr_flsilent  IN VARCHAR2 DEFAULT 'S'      --> Se a chamada terá retorno ou não a tela
                        ,pr_des_erro OUT VARCHAR2);

  /* Rotina de Impressão de Arquivos (antiga imprim.p) */
  PROCEDURE pc_imprim(pr_cdcooper    IN crapcop.cdcooper%TYPE  --> Cooperativa conectada
                     ,pr_cdprogra    IN VARCHAR2               --> Nome do programa que está executando
                     ,pr_cdrelato    IN craprel.cdrelato%TYPE  --> Código do relatório solicitado
                     ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE  --> Data movimento atual
                     ,pr_caminho     IN VARCHAR2               --> Path arquivo origem
                     ,pr_nmarqimp    IN VARCHAR2               --> Nome arquivo para impressao
                     ,pr_nmformul    IN VARCHAR2               --> Nome do formulário de impressão
                     ,pr_nrcopias    IN NUMBER                 --> Quantidade de Copias desejadas
                     ,pr_dircop_pdf OUT VARCHAR2               --> Retornar o path de geração do PDF
                     ,pr_cdcritic   OUT NUMBER                 --> Retornar código do erro
                     ,pr_dscritic   OUT VARCHAR2);             --> Retornar descrição do erro

  /* Rotina para extração do tempo */
  FUNCTION fn_busca_time RETURN NUMBER;

  /* Retonar a data a partir do numero de segundos */
  FUNCTION fn_converte_time_data(pr_nrsegs IN INTEGER
                                ,pr_tipsaida IN VARCHAR2 DEFAULT 'M') RETURN VARCHAR2; --Retorna data em minutos ou segundos

  /* Incluir log de geração de relatórios. */
  PROCEDURE pc_gera_log_relato(pr_cdcooper IN crapcop.cdcooper%TYPE       --> Cooperativa conectada
                              ,pr_des_log IN VARCHAR2);

  /* Rotina para gerar um arquivo do XMLType passado */
  PROCEDURE pc_XML_para_arquivo(pr_XML       IN OUT NOCOPY XMLtype  --> Instância do XML Type
                               ,pr_caminho   IN VARCHAR2            --> Diretório para saída
                               ,pr_arquivo   IN VARCHAR2            --> Nome do arquivo de saída
                               ,pr_des_erro OUT VARCHAR2);          --> Variavel de retorno de Erro

  /* Rotina para gerar um arquivo do CLOB passado */
  PROCEDURE pc_XML_para_arquivo(pr_XML       IN OUT NOCOPY CLOB     --> Instância do CLOB
                               ,pr_caminho   IN VARCHAR2            --> Diretório para saída
                               ,pr_arquivo   IN VARCHAR2            --> Nome do arquivo de saída
                               ,pr_des_erro OUT VARCHAR2);          --> Variavel de retorno de Erro

  /* Procedimento que processa os relatórios pendentes e chama sua geração */
  PROCEDURE pc_process_relato_penden(pr_nrseqsol IN crapslr.nrseqsol%TYPE DEFAULT NULL --> Processar somente a sequencia passada
                                    ,pr_cdfilrel IN crapslr.cdfilrel%TYPE DEFAULT NULL --> Processar todas as sequencias da fila
                                    ,pr_des_erro OUT VARCHAR2);

  /* Rotina para solicitar geração de relatorio em PDF a partir de um XML de dados */
  PROCEDURE pc_solicita_relato(pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Cooperativa conectada
                              ,pr_cdprogra  IN crapprg.cdprogra%TYPE    --> Programa chamador
                              ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE    --> Data do movimento atual
                              ,pr_dsxml     IN OUT NOCOPY CLOB          --> Arquivo XML de dados
                              ,pr_dsxmlnode IN VARCHAR2                 --> Nó do XML para iteração
                              ,pr_dsjasper  IN VARCHAR2                 --> Arquivo de layout do iReport
                              ,pr_dsparams  IN VARCHAR2                 --> Array de parametros diversos
                              ,pr_dsarqsaid IN VARCHAR2                 --> Path/Nome do arquivo PDF gerado
                              ,pr_flg_gerar IN VARCHAR2 DEFAULT 'N'     --> Gerar o arquivo na hora
                              ,pr_qtcoluna  IN NUMBER                   --> Qtd colunas do relatório (80,132,234)
                              ,pr_sqcabrel  IN NUMBER DEFAULT 1         --> Sequencia do relatorio (cabrel 1..5)
                              ,pr_cdrelato  IN NUMBER DEFAULT NULL      --> Código fixo para o relatório (nao busca pelo sqcabrel)
                              ,pr_cdfilrel  IN VARCHAR2 DEFAULT NULL    --> Fila para o relatório
                              ,pr_nrseqpri  IN NUMBER DEFAULT NULL      --> Prioridade para o relatório (0..5)
                              ,pr_flg_impri IN VARCHAR2 DEFAULT 'N'     --> Chamar a impressão (Imprim.p)
                              ,pr_nmformul  IN VARCHAR2 DEFAULT NULL    --> Nome do formulário para impressão
                              ,pr_nrcopias  IN NUMBER   DEFAULT NULL    --> Número de cópias para impressão
                              ,pr_dspathcop IN VARCHAR2 DEFAULT NULL    --> Lista sep. por ';' de diretórios a copiar o relatório
                              ,pr_dsextcop  IN VARCHAR2 DEFAULT NULL    --> Extensão para cópia do relatório aos diretórios
                              ,pr_fldoscop  IN VARCHAR2 DEFAULT 'N'     --> Flag para converter o arquivo gerado em DOS antes da cópia
                              ,pr_dscmaxcop IN VARCHAR2 DEFAULT NULL    --> Comando auxiliar para o comando ux2dos na cópia de diretório
                              ,pr_dsmailcop IN VARCHAR2 DEFAULT NULL    --> Lista sep. por ';' de emails para envio do relatório
                              ,pr_dsassmail IN VARCHAR2 DEFAULT NULL    --> Assunto do e-mail que enviará o relatório
                              ,pr_dscormail IN VARCHAR2 DEFAULT NULL    --> HTML corpo do email que enviará o relatório
                              ,pr_dsextmail IN VARCHAR2 DEFAULT NULL    --> Extensão para envio do relatório
                              ,pr_fldosmail IN VARCHAR2 DEFAULT 'N'     --> Flag para converter o arquivo gerado em DOS antes do e-mail
                              ,pr_dscmaxmail IN VARCHAR2 DEFAULT NULL    --> Comando auxiliar para o comando ux2dos no envio de e-mail
                              ,pr_flgremarq IN VARCHAR2 DEFAULT 'N'     --> Flag para remover o arquivo após cópia/email
                              ,pr_flsemqueb IN VARCHAR2 DEFAULT 'N'     --> Flag S/N para não gerar quebra no relatório
                              ,pr_flappend  IN VARCHAR2 DEFAULT 'N'     --> Indica que a solicitação irá incrementar o arquivo
                              ,pr_parser    IN VARCHAR2 DEFAULT 'D'     --> Seleciona o tipo do parser. "D" para VTD e "R" para Jasper padrão
                              ,pr_nrvergrl  IN crapslr.nrvergrl%TYPE DEFAULT 0 --> Numero da versão da função de geração de relatorio
                              ,pr_des_erro  OUT VARCHAR2);              --> Saída com erro

  /* Rotina para solicitar geração de arquivo lst a partir de um XML de dados */
  PROCEDURE pc_solicita_relato_arquivo(pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Cooperativa conectada
                                      ,pr_cdprogra  IN crapprg.cdprogra%TYPE    --> Programa chamador
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE    --> Data do movimento atual
                                      ,pr_dsxml     IN OUT NOCOPY CLOB          --> Arquivo XML de dados
                                      ,pr_dsarqsaid IN VARCHAR2                 --> Path/Nome do arquivo PDF gerado
                                      ,pr_cdrelato  IN NUMBER DEFAULT NULL      --> Código fixo para o relatório
                                      ,pr_flg_impri IN VARCHAR2 DEFAULT 'N'     --> Chamar a impressão (Imprim.p)
                                      ,pr_flg_gerar IN VARCHAR2 DEFAULT 'N'     --> Gerar o arquivo na hora
                                      ,pr_nmformul  IN VARCHAR2 DEFAULT NULL    --> Nome do formulário para impressão
                                      ,pr_nrcopias  IN NUMBER   DEFAULT NULL    --> Número de cópias para impressão
                                      ,pr_dspathcop IN VARCHAR2 DEFAULT NULL    --> Lista sep. por ';' de diretórios a copiar o arquivo
                                      ,pr_fldoscop  IN VARCHAR2 DEFAULT 'N'     --> Flag para converter o arquivo gerado em DOS antes da cópia
                                      ,pr_dscmaxcop IN VARCHAR2 DEFAULT NULL    --> Comando auxiliar para o comando ux2dos na cópia de diretório
                                      ,pr_dsextcop  IN VARCHAR2 DEFAULT NULL    --> Extensão para cópia do relatório aos diretórios
                                      ,pr_dsmailcop IN VARCHAR2 DEFAULT NULL    --> Lista sep. por ';' de emails para envio do arquivo
                                      ,pr_dsassmail IN VARCHAR2 DEFAULT NULL    --> Assunto do e-mail que enviará o arquivo
                                      ,pr_dscormail IN VARCHAR2 DEFAULT NULL    --> HTML corpo do email que enviará o arquivo
                                      ,pr_dsextmail IN VARCHAR2 DEFAULT NULL    --> Extensão para envio do relatório
                                      ,pr_fldosmail IN VARCHAR2 DEFAULT 'N'     --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                      ,pr_dscmaxmail IN VARCHAR2 DEFAULT NULL    --> Comando auxiliar para o comando ux2dos no envio de e-mail
                                      ,pr_flgremarq IN VARCHAR2 DEFAULT 'N'     --> Flag para remover o arquivo após cópia/email
                                      ,pr_flappend  IN VARCHAR2 DEFAULT 'N'     --> Indica que a solicitação irá incrementar o arquivo
                                      ,pr_des_erro  OUT VARCHAR2);              --> Saída com erro


  /* Procedimento que gerencia as filas de relatórios e controla seus jobs */
  PROCEDURE pc_controle_filas_relato;

  /* Função para processar uma string que contém um valor e retorná-lo em number  */
  FUNCTION fn_char_para_number(pr_dsnumtex IN varchar2) RETURN NUMBER;


  /* Calcular a diferença entre duas datas e retornar diferença em hh:mi:ss */
  FUNCTION fn_calc_difere_datas(pr_dtinicio IN DATE
                               ,pr_dttermin IN DATE) RETURN VARCHAR2;

  /* Procedure para controlar buferização de um CLOB */
  PROCEDURE pc_clob_buffer(pr_dados   IN OUT NOCOPY VARCHAR2       --> Buffer de dados
                          ,pr_btam    IN PLS_INTEGER DEFAULT 32600 --> Determina o tamanho do buffer
                          ,pr_gravfim IN BOOLEAN                   --> Verifica se é gravação final do buffer
                          ,pr_clob    IN OUT NOCOPY CLOB);         --> Clob de gravação

  -- Subrotina para escrever texto na variável CLOB do XML
  procedure pc_escreve_xml(pr_xml in out nocopy clob,
                           pr_texto_completo in out nocopy varchar2,
                           pr_texto_novo in varchar2,
                           pr_fecha_xml in boolean default false);

  /* Procedure para copiar arquivos para a intranet */
  PROCEDURE pc_gera_arquivo_intranet(pr_cdcooper IN PLS_INTEGER                --> Código da cooperativa
                                    ,pr_cdagenci IN PLS_INTEGER                --> Código da agencia
                                    ,pr_dtmvtolt IN DATE                       --> Data de movimento
                                    ,pr_nmarqimp IN VARCHAR2                   --> Nome arquivo de impressão
                                    ,pr_nmformul IN VARCHAR2                   --> Nome do formulário
                                    ,pr_dscritic OUT VARCHAR2                  --> Descrição da crítica
                                    ,pr_tab_erro IN OUT GENE0001.typ_tab_erro  --> Tabela com erros
                                    ,pr_des_erro OUT VARCHAR2);                --> Retorno de erros no processo

  /* Funçao para testar se a variável é uma data valida */
  FUNCTION fn_data(pr_vlrteste IN VARCHAR2
                  ,pr_formato IN VARCHAR2) RETURN BOOLEAN;


  -- Subrotina para enviar arquivo de extrato da conta para servidor web
  PROCEDURE pc_envia_arquivo_web (pr_cdcooper IN crapcop.cdcooper%TYPE  --Codigo Cooperativa
                                 ,pr_cdagenci IN crapass.cdagenci%TYPE  --Codigo Agencia
                                 ,pr_nrdcaixa IN INTEGER                --Numero do Caixa
                                 ,pr_nmarqimp IN VARCHAR2               --Nome Arquivo Impressao
                                 ,pr_nmdireto IN VARCHAR2               --Nome Diretorio
                                 ,pr_nmarqpdf OUT VARCHAR2              --Nome Arquivo PDF
                                 ,pr_des_reto OUT VARCHAR2              --Retorno OK/NOK
                                 ,pr_tab_erro OUT gene0001.typ_tab_erro); --Tabela Erros


  -- Procedure para importar arquivo XML para XMLtype
  PROCEDURE pc_arquivo_para_XML (pr_nmarquiv IN VARCHAR2       --> Nome do caminho completo) 
                                ,pr_tipmodo  IN NUMBER DEFAULT 1 --> Tipo de modo de carregamento 1 - Normal(utl_file) 2 - Alternativo(usando blob)
                                ,pr_xmltype  OUT XmlType       --> Saida para o XML
                                ,pr_des_reto OUT VARCHAR2      --> Descrição OK/NOK
                                ,pr_dscritic OUT VARCHAR2);    --> Descricao Erro    
                                
  -- Função para abreviar string
  FUNCTION fn_abreviar_string (pr_nmdentra IN VARCHAR2                  --> Nome de Entrada
                              ,pr_qtletras IN INTEGER) RETURN VARCHAR2; --> Quantidade de Letras                                

  -- Função para centralizar e preencher texto a direita e esquerda
  FUNCTION fn_centraliza_texto (pr_dstexto  IN VARCHAR2       --> Texto de Entrada
                               ,pr_dscarac  IN VARCHAR2       --> Caracter para preencher 
                               ,pr_tamanho  IN INTEGER) RETURN VARCHAR2; --> Tamanho da String

  -- Função para retornar o valor em extenso
  FUNCTION fn_valor_extenso (pr_idtipval  IN VARCHAR2      --> Tipo de valor (M-Monetario, P-Porcentagem, I-Inteiro)
                            ,pr_valor     IN VARCHAR2   )  --> Valor a ser convertido para extenso
                            RETURN VARCHAR2;                               

  -- Procedure para importar arquivo XML para Tabela em memória
  PROCEDURE pc_arquivo_para_table_of (pr_nmarquiv IN VARCHAR2                     --> Nome do caminho completo)
                                     ,pr_table_of OUT GENE0002.typ_tab_tabela --> Saida para o array
                                     ,pr_des_reto OUT VARCHAR2                    --> Descrição OK/NOK
                                     ,pr_dscritic OUT VARCHAR2);                  --> Descricao Erro

  PROCEDURE pc_transf_arq_smartshare(pr_nmdiretorio IN VARCHAR2  --> diretorio local, onde esta o arquivo a ser copiado
                                    ,pr_nmarquiv IN VARCHAR2     --> nome do arquivo a ser copiado                                   
                                    ,pr_cdcooper IN crapcop.cdcooper%TYPE --> cooperativa
                                    ,pr_des_reto OUT VARCHAR2 --> Descrição OK/NOK
                                    ,pr_dscritic OUT VARCHAR2 --> Descricao Erro
                                    );

/* P565_1*/
PROCEDURE pc_gera_relato(pr_nrseqsol IN crapslr.nrseqsol%TYPE    --> Sequencia da solicitação
                        ,pr_des_erro  OUT VARCHAR2);

END GENE0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.gene0002 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : GENE0002
  --  Sistema  : Rotinas genéricas para mascaras e relatórios
  --  Sigla    : GENE
  --  Autor    : Marcos E. Martini - Supero
  --  Data     : Novembro/2012.                   Ultima atualizacao: 19/04/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Definir variaveis e funções para auxilio de mascaras e rotinas de relatórios
  --
  -- Alterações: 21/01/2015 - Alterado o formato do campo nrctremp para 8
  --                          caracters (Kelvin - 233714)
  --
  --             27/02/2015 - Incluido o nome do arquivo .pdf no retorno da variavel pr_nmarqpdf,
  --                          feito tratamento para arquivos .lst na procedure pc_envia_arquivo_web
  --                          (Jean Michel).
  --
  --             22/09/2015 - Adicionar validação na procedure pc_solicita_relato para quando o
  --                          relatorio for solicitado durante o processo batch, o erro seja escrito
  --                          no proc_batch, caso contrario no proc_message (Douglas - Chamado 306525)
  --
  --             11/03/2016 - Na procedure pc_gera_relato ao ocorrer erro na exclusão do xml foi modificado
  --                          para logar no proc_message e não mais no proc_batch conforme solicitado
  --                          no chamado 411723 (Kelvin)                                 
  --
  --             05/04/2016 - Ajuste para retirar o "*" ao remover o arquivo
  --                          (Adriano).        
  --
  --             29/09/2016 - #523947 No procedimento pc_controle_filas_relato, incluído log de início, fim e 
  --                          erro na execução do job (Carlos)
  --
  --             26/10/2016 - Gravado em log a execução da rotina procedimento pc_controle_filas_relato apenas
  --                          apenas quando tiverem relatórios pendentes para execução (Carlos)
  --    
  --             22/06/2017 - Tratamento de erros                         
  --                        - setado modulo
  --                        - Chamado 660322 - Belli - Envolti
  --
  --             04/08/2017 - Retirado pc_set_modulo da procedure fn_quebra_string
  --                        - Chamado 678813 - Belli - Envolti
  --    
  --             27/07/2017 - #724054 retirada a exclusão da coop 3 do cursor cr_crapcop, rotina 
  --                          pc_publicar_arq_intranet (Carlos)
  --
  --             17/10/2017 - Retirado pc_set_modulo
  --                          (Ana - Envolti - Chamado 776896)
  --
  --             18/10/2017 - Incluído pc_set_modulo com novo padrão
  --                          (Ana - Envolti - Chamado 776896)
  --
  --             24/11/2017 - Ajuste na rotina fn_char_para_number, para sair da mesma quando o parâmetro estiver
  --                          nulo (Carlos)
  --
  --             19/04/2018 - #812349 Na rotina pc_gera_relato, utilizada a rotina pc_mv_arquivo para ganho de
  --                          perfomance no comando (Carlos)
  --
  --             12/12/2018 - Alterado padrão da mascara de contrato
  --                          (Andre Clemer - Supero)
  ---------------------------------------------------------------------------------------------------------------

  /* Lista de variáveis para armazenar as mascaras parametrizadas */
  vr_des_mask_conta    VARCHAR2(10);
  vr_des_mask_ctitg    VARCHAR2(11);
  vr_des_mask_cpf      VARCHAR2(14);
  vr_des_mask_cnpj     VARCHAR2(20);
  vr_des_mask_cep      VARCHAR2(10);
  vr_des_mask_matric   VARCHAR2(7);
  vr_des_mask_contrato VARCHAR2(13);

  /* Saída com erro */
  vr_des_erro VARCHAR2(4000);
  vr_exc_erro EXCEPTION;
  vr_typ_said VARCHAR2(100);

  -- Busca do diretório conforme a cooperativa conectada
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.dsdircop
          ,cop.nmrescop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  /* Função genérica para aplicar uma mascara ao conteudo passado */
  FUNCTION fn_mask(pr_dsorigi in varchar2,
                   pr_dsforma in varchar2) RETURN varchar2 IS
    -- ..........................................................................
    --
    --  Programa : fn_mask
    --  Sistema  : Rotinas genéricas
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Novembro/2012.                   Ultima atualizacao: 18/10/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Mascarar a informação enviada seguindo o formado passado.
    --               A função NÃO DEVE ser utilizada para formatar VALOR, pois não trata casas decimais.
    --               Regras utilizadas na mascara
    --               -> 9 - Ao encontrar um nove, a rotina mostra o caracter número
    --                      correspondente, e em caso de não existir, substitui por um
    --                      zero.
    --               -> z - Ao encontrar um Z, a rotina preenche a casa com a informação
    --                      enviada e caso não exista nada, é enviado um espaço em branco
    --               -> Qualquer outro - É interpretado como um caracter especial e será
    --                                   enviado na notação final.
    --
    --    Exemplos : 12233        -> zz99-99-0        -> ' 122-33-0'
    --               abcd1        -> zzzzz            -> 'abcd1'
    --               33342000     -> zzzz-zzzz        -> '3334-2000'
    --               554733233000 -> +99(99)9999-9999 -> '+55(47)3323-3000'
    --
    --   Alteracoes: 26/07/2013 - Alteração da função para não utilizar mais 'select from dual'
    --                            devido a problemas de performance. (Daniel - Supero)
    --               17/10/2017 - Retirado pc_set_modulo
    --                            (Ana - Envolti - Chamado 776896)
    --               18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                            (Ana - Envolti - Chamado 776896)
    -- ..........................................................................
    vr_dsauxil   varchar2(200);
    vr_dsconve   varchar2(200);
    vr_dsforma   varchar2(200);
    vr_tam_mask  integer;
    vr_tam_var   integer;
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
		GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.fn_mask');        
      
    -- Deixar em maiusculo para facilitar testes
    vr_dsforma := upper(pr_dsforma);
    vr_dsauxil := nvl(pr_dsorigi,' ');
    -- Identifica o tamanho das variáveis para auxiliar na formatação da máscara
    vr_tam_mask := length(vr_dsforma);
    vr_tam_var := length(vr_dsauxil);
    -- Varrer a string, começando pelo final, para aplicar os caracteres especiais
    for vr_ind in reverse 1..vr_tam_mask loop
      -- Se o caracter atual na mascara nao for 9 ou Z
      if substr(vr_dsforma,vr_ind,1) not in('9','Z') then
        -- Então é um caracter especial, incluí-lo na saida
        vr_dsconve := substr(vr_dsforma,vr_ind,1)||vr_dsconve;
      else
        -- Se não for, utilizar o caracter da string original
        vr_dsconve := substr(vr_dsauxil,vr_tam_var,1)||vr_dsconve;
        -- Diminuir 1 no tamanho do texto, indicando que falta um caracter a menos para acabar
        vr_tam_var := vr_tam_var - 1;
        -- Quando não houver mais caracteres restantes, sai do loop, mesmo que não tenha terminado a máscara
        if vr_tam_var = 0 then
          exit;
        end if;
      end if;
    end loop;
    -- Preencher o restante da informaçao cfme a mascara
    -- Varrer a string partindo do final até chegar no 9
    for vr_i in reverse 1..length(vr_dsforma) - length(vr_dsconve) loop
      if substr(vr_dsforma,vr_i,1) = '9' then
        -- Se encontrarmos um 9 no formato, adiciona um zero
        vr_dsconve := '0'||vr_dsconve;
      elsif substr(vr_dsforma,vr_i,1) = 'Z' then
        -- Se encontrar um Z, adiciona um espaço em branco
        vr_dsconve := ' '||vr_dsconve;
      else
        -- É um caracter especial. Devemos verificar qual o caracter anterior para saber como tratar.
        if substr(vr_dsforma,vr_i-1,1) = 'Z' then
          -- Adicionar um espaço em branco
          vr_dsconve := ' '||vr_dsconve;
        else
          -- Adicionar o caracter do formato
          vr_dsconve := substr(vr_dsforma,vr_i,1)||vr_dsconve;
        end if;
      end if;
    end loop;

    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    -- Retornar o valor processado
    return vr_dsconve;

  EXCEPTION
    when others then
      -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
      CECRED.pc_internal_exception;
      -- Incluir log de que houve problema na mascara
      gene0001.pc_print(pr_des_mensag => to_char(SYSDATE,'hh24:mi:ss')||' - GENE0002.fn_mask --> Problema ao montar a mascara "'||pr_dsforma||'" ao campo "'||pr_dsorigi||'".');
      -- Retonar como resultado o valor original
      return pr_dsorigi;
  END fn_mask;

  /* Função para mascarar o Nro da Conta */
  FUNCTION fn_mask_conta(pr_nrdconta IN crapass.nrdconta%TYPE) RETURN VARCHAR2 IS
    -- ..........................................................................
    --   Alteracoes: 17/10/2017 - Retirado pc_set_modulo
    --                            (Ana - Envolti - Chamado 776896)
    --               18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                            (Ana - Envolti - Chamado 776896)
    -- ..........................................................................
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
		GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.fn_mask_conta');   
    -- Se ainda não foi buscado
    IF vr_des_mask_conta IS NULL THEN
      vr_des_mask_conta := nvl(gene0001.fn_param_sistema('CRED',0,'MASK_CONTA'), 'zzzz.zzz.z');
    END IF;
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    -- Utilizar mascara padrão de conta
    RETURN fn_mask(pr_nrdconta,vr_des_mask_conta);
  END;

  /* Função para mascarar a Conta Integração */
  FUNCTION fn_mask_ctitg(pr_nrdctitg IN crapass.nrdctitg%TYPE) RETURN VARCHAR2 IS
    -- ..........................................................................
    --   Alteracoes: 17/10/2017 - Retirado pc_set_modulo
    --                            (Ana - Envolti - Chamado 776896)
    --               18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                            (Ana - Envolti - Chamado 776896)
    -- ..........................................................................
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
		GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.fn_mask_ctitg');   
    -- Se ainda não foi buscado
    IF vr_des_mask_ctitg IS NULL THEN
      vr_des_mask_ctitg := nvl(gene0001.fn_param_sistema('CRED',0,'MASK_CONTA_ITG'), 'z.zzz.zzz.z');
    END IF;
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    -- Utilizar mascara padrão de conta de integração
    RETURN fn_mask(pr_nrdctitg,vr_des_mask_ctitg);
  END;

  /* Função para mascarar o CPF ou CNPJ */
  FUNCTION fn_mask_cpf_cnpj(pr_nrcpfcgc IN crapass.nrcpfcgc%type,
                            pr_inpessoa in crapass.inpessoa%type) RETURN varchar2 IS
    -- ..........................................................................
    --   Alteracoes: 17/10/2017 - Retirado pc_set_modulo
    --                            (Ana - Envolti - Chamado 776896)
    --               18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                            (Ana - Envolti - Chamado 776896)
    -- ..........................................................................
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
		GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.fn_mask_cpf_cnpj');   
    -- Se ainda não foi buscado
    IF vr_des_mask_cpf IS NULL THEN
      vr_des_mask_cpf := nvl(gene0001.fn_param_sistema('CRED',0,'MASK_CPF'), '999.999.999-99');
    END IF;
    -- Mesmo esquema para o CNPJ
    IF vr_des_mask_cnpj IS NULL THEN
      vr_des_mask_cnpj := nvl(gene0001.fn_param_sistema('CRED',0,'MASK_CNPJ'), 'zz.zzz.zzz/zzzz-zz');
    END IF;
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    -- Verifica se é pessoa física (inpessoa = 1) ou pessoa jurídica (inpessoa = 2)
    IF pr_inpessoa = 1 THEN
      -- Utilizar mascara padrão de conta de CPF
      RETURN fn_mask(pr_nrcpfcgc,vr_des_mask_cpf);
    ELSE
      -- Utilizar mascara padrão de conta de CNPJ
      RETURN fn_mask(pr_nrcpfcgc,vr_des_mask_cnpj);
    END IF;
  END;

  /* Função para mascarar o CEP */
  FUNCTION fn_mask_cep(pr_nrcepend IN crapenc.nrcepend%TYPE) RETURN VARCHAR2 IS
    -- ..........................................................................
    --   Alteracoes: 17/10/2017 - Retirado pc_set_modulo
    --                            (Ana - Envolti - Chamado 776896)
    --               18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                            (Ana - Envolti - Chamado 776896)
    -- ..........................................................................
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
		GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.fn_mask_cep');   
    -- Se ainda não foi buscado
    IF vr_des_mask_cep IS NULL THEN
      vr_des_mask_cep := nvl(gene0001.fn_param_sistema('CRED',0,'MASK_CEP'), 'zzzzz-zz9');
    END IF;
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    -- Utilizar mascara padrão de conta de CEP
    RETURN fn_mask(pr_nrcepend,vr_des_mask_cep);
  END;

  /* Função para mascarar a matrícula */
  FUNCTION fn_mask_matric(pr_nrmatric IN crapass.nrmatric%TYPE) RETURN VARCHAR2 IS
    -- ..........................................................................
    --   Alteracoes: 17/10/2017 - Retirado pc_set_modulo
    --                            (Ana - Envolti - Chamado 776896)
    --               18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                            (Ana - Envolti - Chamado 776896)
    -- ..........................................................................
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
		GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.fn_mask_matric'); 
    -- Se ainda não foi buscado
    IF vr_des_mask_matric IS NULL THEN
      vr_des_mask_matric := nvl(gene0001.fn_param_sistema('CRED',0,'MASK_MATRICULA'), 'zzzzz-zz9');
    END IF;
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    -- Utilizar mascara padrão de conta de Matrícula
    RETURN fn_mask(pr_nrmatric,vr_des_mask_matric);
  END;

  /* Função para mascarar o contrato */
  FUNCTION fn_mask_contrato(pr_nrcontrato IN crapepr.nrctremp%TYPE) RETURN VARCHAR2 IS
    -- ..........................................................................
    --   Alteracoes: 17/10/2017 - Retirado pc_set_modulo
    --                            (Ana - Envolti - Chamado 776896)
    --               18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                            (Ana - Envolti - Chamado 776896)
    --               12/12/2018 - Alterado padrão da mascara de contrato
    --                            (Andre Clemer - Supero)
    -- ..........................................................................
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
		GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.fn_mask_contrato'); 
   -- Se ainda não foi buscado
    IF vr_des_mask_contrato IS NULL THEN
      vr_des_mask_contrato := nvl(gene0001.fn_param_sistema('CRED',0,'MASK_CONTRATO'), 'z.zzz.zzz.zz9');
    END IF;
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    -- Utilizar mascara padrão de conta de Nro Contrato
    RETURN fn_mask(pr_nrcontrato,vr_des_mask_contrato);
  END;

  /* Calcular as horas e minutos com base nos segundos informados */
  FUNCTION fn_calc_hora(pr_segundos IN PLS_INTEGER) RETURN VARCHAR2 IS  --> Segundos decorridos
  BEGIN
    -- ..........................................................................
    -- Programa: fn_calc_hora
    -- Sistema : Conta-Corrente - Cooperativa de Credito
    -- Sigla   : CRED
    -- Autor   : Deborah/Edson
    -- Data    : Junho/2013                     Ultima atualizacao: 18/10/2017

    -- Dados referentes ao programa:

    -- Frequencia: Sempre que chamado por outros programas.
    -- Objetivo  : Calcular e retornar a hora e minuto formatados.
    -- .............................................................................
    BEGIN
      RETURN to_char(trunc(pr_segundos/60/60),'FM09') || ':' ||
             to_char(trunc(mod(pr_segundos,3600)/60),'FM09') ||  ':' ||
             to_char(mod(mod(pr_segundos,3600),60),'FM09');
    END;
  END fn_calc_hora;

  /* Rotina para testar carateres numéricos */
  FUNCTION fn_numerico(pr_vlrteste IN VARCHAR2) RETURN boolean IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : fn_numerico
    --  Sistema  : Rotinas genéricas
    --  Sigla    : GENE
    --  Autor    : Petter - Supero Tecnologia
    --  Data     : Dezembro/2012.                   Ultima atualizacao: 18/10/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Retornar validação se a variável contem numeros.
    --   Alteracoes: 17/10/2017 - Retirado pc_set_modulo
    --                            (Ana - Envolti - Chamado 776896)
    --               18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                            (Ana - Envolti - Chamado 776896)
    -- ............................................................................
    DECLARE
      vr_ctrteste       BOOLEAN := TRUE;
      vr_qvalor         VARCHAR2(1);

    BEGIN
	  -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
		GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.fn_numerico'); 
      -- Se o parametro for enviado sozinho retorna false.
      IF pr_vlrteste IS NULL THEN
        vr_ctrteste := FALSE;
      ELSE
        -- Itera sobre a string enviada checando caracter a caracter, se encontrar
        -- letras retorna false
        FOR vr_ind IN 1..LENGTH(pr_vlrteste) LOOP
          vr_qvalor := substr(pr_vlrteste, vr_ind, 1);
          IF vr_qvalor NOT IN ('0','1','2','3','4','5','6','7','8','9') THEN
            vr_ctrteste := FALSE;
          END IF;
        END loop;
      END IF;

      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
      RETURN vr_ctrteste;
    END;
  END fn_numerico;


  /* Retonar um determinado dado de uma string separado por um delimitador */
  FUNCTION fn_busca_entrada(pr_postext     IN NUMBER
                           ,pr_dstext      IN VARCHAR2
                           ,pr_delimitador IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : fn_busca_entrada
    --  Sistema  : Rotinas genéricas
    --  Sigla    : GENE
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Dezembro/2012.                   Ultima atualizacao: 18/10/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Retornar determinada informacao da string conforme parametros.
    --   Alteracoes: 17/10/2017 - Retirado pc_set_modulo
    --                            (Ana - Envolti - Chamado 776896)
    --               18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                            (Ana - Envolti - Chamado 776896)
    -- ............................................................................
    DECLARE
      /* Variaveis Locais */
      vr_pos    NUMBER;
      vr_string VARCHAR2(4000):= pr_dstext;
    BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
  		GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.fn_busca_entrada'); 
      --Se o valor desejado for o 1º parametro
      IF pr_postext = 1 THEN
        --Encontrar a posição do delimitador na string
        vr_pos:= InStr(vr_string,pr_delimitador);
        --Se nao encontrou o delimitador
        IF vr_pos = 0 THEN
          RETURN(vr_string);
        ELSE
          RETURN(SubStr(pr_dstext,1,InStr(pr_dstext,pr_delimitador)-1));
        END IF;
      ELSE
        vr_pos:= InStr(vr_string,pr_delimitador);
        --Se nao encontrou o delimitador ou a string termina no delimitador retorna zero
        IF vr_pos = 0 OR vr_pos = length(vr_string) THEN
          RETURN('0');
        END IF;
        --Percorrer a string procurando pelos delimitadores
        FOR idx IN 1..pr_postext-1 LOOP
          --Encontrar a posição do delimitador na string
          vr_pos:= InStr(vr_string,pr_delimitador);

          --Atribuir a variavel o texto apos o delimitador
          vr_string:= SubStr(vr_string,vr_pos+1);
        END LOOP;
        --Encontrar a posição do delimitador na string
        vr_pos:= InStr(vr_string,pr_delimitador);
        IF vr_pos > 0 THEN
          --Atribuir a variavel o texto apos o delimitador
          vr_string:= SubStr(vr_string,1,vr_pos-1);
        END IF;
      END IF;
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
      RETURN(vr_string);
    END;
  END fn_busca_entrada;

  /* Quebra string com base no delimitador e retorna array de resultados */
  FUNCTION fn_quebra_string(pr_string   IN VARCHAR2
                           ,pr_delimit  IN CHAR DEFAULT ',') RETURN typ_split IS

    -- ..........................................................................
    --
    --  Programa : fn_quebra_string
    --  Sistema  : Rotinas genéricas
    --  Sigla    : GENE
    --  Autor    : Petter Rafael - Supero
    --  Data     : Janeiro/2013.                   Ultima atualizacao: 18/10/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Retornar array com os campos referentes a quebra da string
    --               com base no delimitador informado.
    --   Alteracoes: 04/08/2017 - Retirado pc_set_modulo
    --                            (Belli - Envolti - Chamado 678813)
    --               18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                            (Ana - Envolti - Chamado 776896)
    -- ............................................................................

    vr_vlret    typ_split := typ_split();
    vr_quebra   LONG DEFAULT pr_string || pr_delimit;
    vr_idx      NUMBER;

  BEGIN
	  -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => 'GENE0002.fn_quebra_string');
    --Se a string estiver nula retorna count = 0 no vetor
    IF nvl(pr_string,'#') = '#' THEN
      RETURN vr_vlret;
    END IF;

    LOOP
      -- Identifica ponto de quebra inicial
      vr_idx := instr(vr_quebra, pr_delimit);

      -- Clausula de saída para o loop
      exit WHEN nvl(vr_idx, 0) = 0;

      -- Acrescenta elemento para a coleção
      vr_vlret.EXTEND;
      -- Acresce mais um registro gravado no array com o bloco de quebra
      vr_vlret(vr_vlret.count) := trim(substr(vr_quebra, 1, vr_idx - 1));
      -- Atualiza a variável com a string integral eliminando o bloco quebrado
      vr_quebra := substr(vr_quebra, vr_idx + LENGTH(pr_delimit));
    END LOOP;
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);

    -- Retorno do array com as substrings separadas em cada registro
    RETURN vr_vlret;
  END fn_quebra_string;

  /* Pesquisa por valor informado quebrando a busca pelo delimitador passado */
  FUNCTION fn_existe_valor(pr_base      IN VARCHAR2                    --> String que irá sofrer a busca
                          ,pr_busca     IN VARCHAR2                    --> String objeto de busca
                          ,pr_delimite  IN VARCHAR2) RETURN VARCHAR2 IS --> String que será o delimitador
    -- ..........................................................................
    --
    --  Programa : fn_existe_valor
    --  Sistema  : Rotinas genéricas
    --  Sigla    : GENE
    --  Autor    : Petter Rafael - Supero
    --  Data     : Janeiro/2013.                   Ultima atualizacao: 18/10/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Quebra uma string enviada de acordo com um delimitador informado
    --               e pesquisa se uma string objeto de busca existe dentre os
    --               resultados da quebra da string retornando 'S' em caso de sucesso
    --               ou 'N' em caso de insucesso.
    --   Alteracoes: 17/10/2017 - Retirado pc_set_modulo
    --                            (Ana - Envolti - Chamado 776896)
    --               18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                            (Ana - Envolti - Chamado 776896)
    -- ............................................................................

    vr_buscar  typ_split;
    vr_result  VARCHAR2(1) := 'N';

  BEGIN
	  -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
		GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.fn_existe_valor'); 
    -- Quebra a string pelo delimitador informado
    vr_buscar := fn_quebra_string(pr_base, pr_delimite);
    -- Verifica se a quebra resultou em um array válido
    IF vr_buscar.count() > 0 THEN
      -- Itera sobre o array para pesquisar seus objetos
      FOR idx IN 1..vr_buscar.count() LOOP
        -- Testa se algum objeto do array coincide com o objeto de busca
        IF vr_buscar(idx) = pr_busca THEN
          vr_result := 'S';
          EXIT;
        END IF;
      END LOOP;
    END IF;
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    -- Retorno se localizou ou não o objeto de busca
    RETURN vr_result;
  END fn_existe_valor;

  /* Pesquisa recursiva do contains */
  FUNCTION fn_verifica_contem(pr_dstexto in varchar2                     --> Texto que irá sofrer a busca
                             ,pr_dsprocu in varchar2) RETURN VARCHAR2 IS --> String objeto de busca
  -- ..........................................................................
  --   Alteracoes: 17/10/2017 - Retirado pc_set_modulo
  --                            (Ana - Envolti - Chamado 776896)
    --               18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                            (Ana - Envolti - Chamado 776896)
  -- ..........................................................................
  BEGIN
    -- ............................................................................
    DECLARE
      -- Guardar a chave atual
      vr_dspalav VARCHAR2(4000);
    BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
  		GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.fn_verifica_contem'); 
      -- Se existir mais de uma palavra na chave de procura
      IF instr(pr_dsprocu,' ') > 0 THEN
        -- Separar da chave de procura a primeira palavra
        vr_dspalav := substr(pr_dsprocu,1,instr(pr_dsprocu,' ')-1);
      ELSIF trim(pr_dsprocu) IS NULL THEN
        -- Não há mais chaves de procura, finaliza
        RETURN 'S';
      ELSE
        -- Utiliza a palavra inteira
        vr_dspalav := pr_dsprocu;
      END IF;

      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
      -- Invalidar se não encontrar a chave de procura
      -- Na palavra inteira
      -- OU no início
      -- OU no fim
      -- OU no meio desde seja a palavra inteira
      IF NOT(   pr_dstexto = vr_dspalav
             OR pr_dstexto LIKE vr_dspalav||' %'
             OR pr_dstexto LIKE '% '||vr_dspalav
             OR pr_dstexto LIKE '% '||vr_dspalav||' %' ) THEN
        -- Não casou pelo menos uma das strings de busca, então retorna false
        RETURN 'N';
      ELSE
        -- Do contrário, chama recursivamente passando a lista de palavras e removendo a atual
        RETURN fn_verifica_contem(pr_dstexto => pr_dstexto
                                 ,pr_dsprocu => ltrim(ltrim(pr_dsprocu,vr_dspalav)));
      END IF;
    END;
  END;

  /* Pesquisa no texto pelas strings de procura sem observar a ordem das mesmas */
  FUNCTION fn_contem(pr_dstexto in varchar2                     --> Texto que irá sofrer a busca
                    ,pr_dsprocu in varchar2) RETURN VARCHAR2 IS --> String objeto de busca
  BEGIN
    -- ..........................................................................
    --
    --  Programa : fn_contains e fn_verifica_contem
    --  Sistema  : Rotinas genéricas
    --  Sigla    : GENE
    --  Autor    : Marcos Martini - Supero
    --  Data     : Março/2014.                   Ultima atualizacao: 18/10/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Simular a mesma busca efetuada pelo comando Contains no Progress.
    --               A string de procura pode conter n sub strings de busca, e a ordem
    --               não afeta o resultado, exemplos:
    --               pr_dsprocu =>  SUL RIO DO
    --               Retornará:
    --                  RIO BRANCO DO SUL
    --                  RIO DO SUL
    --                  RIO NOVO DO SUL
    --   Obs:        A lógica de procura está na função fn_verifica_contem
    --               a fn_contem apenas prepara as strings de busca e objeto
    --   Alteracoes: 18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                            (Ana - Envolti - Chamado 776896)
    -- ............................................................................
    BEGIN
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => 'GENE0002.fn_contem');
      -- Usar a função recursiva para validação, esta apenas serve para preparar as strings
      RETURN fn_verifica_contem(pr_dstexto => UPPER(pr_dstexto)
                               ,pr_dsprocu => UPPER(REPLACE(pr_dsprocu,'*','%'))); --> Trocar os caracteres curinga Progress (*) pelos do Oracle (%)
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 'N';
    END;
  END fn_contem;

  /* Função para converter um arquivo em BLOB */
  FUNCTION fn_arq_para_blob(pr_caminho IN VARCHAR2
                           ,pr_arquivo IN VARCHAR2) RETURN BLOB IS
  BEGIN
    /*..............................................................................

       Programa: fn_arq_para_blob
       Autor   : Marcos (Supero)
       Data    : Dezembro/2012                      Ultima atualizacao: 18/10/2017

       Dados referentes ao programa:

       Objetivo  : Criar um Blob a apartir do arquivo passado

       Alteracoes: 17/10/2017 - Retirado pc_set_modulo
                                (Ana - Envolti - Chamado 776896)
                   18/10/2017 - Incluído pc_set_modulo com novo padrão
                                (Ana - Envolti - Chamado 776896)
    ..............................................................................*/
    DECLARE
      -- BLOB para saida
      vr_blob BLOB := EMPTY_BLOB;
      -- Variáveis para tratamento do arquivo
      vr_input_file    utl_file.file_type;
      vr_chunk_size    constant pls_integer := 32767;
      vr_buf           raw                    (32767);
      vr_bytes_to_read pls_integer;
      vr_read_sofar    pls_integer := 0;
    BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
  		GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.fn_arq_para_blob'); 
      -- Criar um LOB para armazenar o arquivo
      DBMS_LOB.CREATETEMPORARY(vr_blob, TRUE);
      -- Abrir o arquivo local e escrevê-lo ao Blob
      BEGIN
        vr_input_file := utl_file.fopen(pr_caminho,pr_arquivo,'RB',32767);
        LOOP
          -- Le os dados em pedaços e escreve no Blob
          utl_file.get_raw(vr_input_file, vr_buf, vr_chunk_size);
          vr_bytes_to_read := length(vr_buf) / 2;
          dbms_lob.write(vr_blob, vr_bytes_to_read, vr_read_sofar+1, vr_buf);
          vr_read_sofar := vr_read_sofar + vr_bytes_to_read;
        END LOOP;
        -- Fechar o arquivo
        utl_file.fclose(vr_input_file);
      EXCEPTION
        WHEN no_data_found THEN
          -- Terminou de ler o arquivo
          utl_file.fclose(vr_input_file);
      END;
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
      -- Retornar o BLOB montado
      RETURN vr_blob;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN EMPTY_BLOB;
    END;
  END fn_arq_para_blob;

  /* Função para converter um arquivo em CLOB */
  FUNCTION fn_arq_para_clob(pr_caminho IN VARCHAR2
                           ,pr_arquivo IN VARCHAR2) RETURN CLOB IS
    /*..............................................................................

       Programa: fn_arq_para_blob
       Autor   : Dionathan
       Data    : Maio/2015                      Ultima atualizacao: 18/10/2017

       Dados referentes ao programa:

       Objetivo  : Criar um CLOB a apartir do arquivo passado

       Alteracoes: 17/10/2017 - Retirado pc_set_modulo
                                (Ana - Envolti - Chamado 776896)
                   18/10/2017 - Incluído pc_set_modulo com novo padrão
                                (Ana - Envolti - Chamado 776896)
    ..............................................................................*/

    -- CLOB para saida
    vr_clob CLOB;
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
		GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.fn_arq_para_clob'); 
    vr_clob := DBMS_XSLPROCESSOR.read2clob(pr_caminho, pr_arquivo, 1);
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    RETURN vr_clob;
  END fn_arq_para_clob;

  /* Procedure para gravar os dados de um BLOB para um arquivo */
  PROCEDURE pc_blob_para_arquivo(pr_blob      IN BLOB     --> Blob com os dados
                                ,pr_caminho   IN VARCHAR2 --> Diretório para saída
                                ,pr_arquivo   IN VARCHAR2 --> Nome do arquivo de saída
                                ,pr_des_erro OUT VARCHAR2) IS
  BEGIN
    /*..............................................................................

       Programa: pc_blob_para_arquivo
       Autor   : Marcos (Supero)
       Data    : Dezembro/2012                      Ultima atualizacao: 18/10/2017

       Dados referentes ao programa:

       Objetivo  : Efetua leitura das informações de um Blob e grava em arquivo

       Alteracoes: 17/10/2017 - Retirado pc_set_modulo
                                (Ana - Envolti - Chamado 776896)
                   18/10/2017 - Incluído pc_set_modulo com novo padrão
                                (Ana - Envolti - Chamado 776896)
    ..............................................................................*/
    DECLARE
      -- Variáveis para tratamento do arquivo
      vr_output_file   utl_file.file_type;
      vr_blob_length   INTEGER;
      vr_start_byte    NUMBER;
      vr_bytes_to_read NUMBER := 32767;
      vr_bytes_total   NUMBER := 32767;
      vr_raw_readed    RAW(32767);
    BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
  		GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_blob_para_arquivo'); 
      -- Abrir o arquivo local para escrita dos bytes
      vr_output_file := utl_file.fopen(pr_caminho,pr_arquivo,'WB',32767);
      -- Guardar o tamanho do Blob
      vr_blob_length := dbms_lob.getlength(pr_blob);
      vr_bytes_total := vr_blob_length;
      -- Se o Blob for pequeno o suficiente para ser escrito de uma só vez
      IF vr_blob_length < 32767 THEN
        -- Escreve apenas uma vez
        utl_file.put_raw(vr_output_file,pr_blob);
        utl_file.fflush(vr_output_file);
      ELSE
        -- Efetuar escrita em porções
        vr_start_byte := 1;
        WHILE vr_start_byte < vr_blob_length AND vr_bytes_to_read > 0 LOOP
          -- Ler os dados do Blob
          dbms_lob.read(pr_blob,vr_bytes_to_read,vr_start_byte,vr_raw_readed);
          -- Escreve no arquivo
          utl_file.put_raw(vr_output_file,vr_raw_readed);
          utl_file.fflush(vr_output_file);
          -- Reposiciona o byte inicial para leitura
          vr_start_byte := vr_start_byte + vr_bytes_to_read;
          -- Desconta do total a quantidade já lida
          vr_bytes_total := vr_bytes_total - vr_bytes_to_read;
          -- Reajusta a quantidade de bytes a ler caso seja inferior máximo possível
          IF vr_bytes_total < 32767 THEN
            vr_bytes_to_read := vr_bytes_total;
          END IF;
        END loop;
      END IF;
      -- Fechar o arquivo;
      utl_file.fclose(vr_output_file);
      -- Setar privilégio para evitar falta de permissão a outros usuários
      gene0001.pc_OScommand_Shell(pr_des_comando => 'chmod 666 '||pr_caminho||'/'||pr_arquivo);
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
        CECRED.pc_internal_exception;
        pr_des_erro := 'GENE0002.pc_blob_para_arquivo --> || Erro ao gravar o conteúdo do Blob para arquivo: '||sqlerrm;
    END;
  END pc_blob_para_arquivo;

  /* Procedure para gravar os dados de um CLOB para um arquivo */
  PROCEDURE pc_clob_para_arquivo(pr_clob      IN CLOB     --> Blob com os dados
                                ,pr_caminho   IN VARCHAR2 --> Diretório para saída
                                ,pr_arquivo   IN VARCHAR2 --> Nome do arquivo de saída
                                ,pr_flappend  IN VARCHAR2 DEFAULT 'N' --> Indica que a solicitação irá incrementar o arquivo
                                ,pr_des_erro OUT VARCHAR2) IS
  BEGIN
    /*..............................................................................

       Programa: pc_clob_para_arquivo
       Autor   : Marcos (Supero)
       Data    : Março/2014                      Ultima atualizacao: 18/10/2017

       Dados referentes ao programa:

       Objetivo  : Efetua leitura das informações de um Clob e gravar em arquivo

       Alteracoes: 31/08/2015 - Inclusao do parametro flappend. (Jaison/Marcos-Supero)
                   08/12/2016 - Ajuste para incrementar nomenclatura qnd realizar
                                append, para garantir processo.
                                SD572620 (Odirlei-AMcom)
                   17/10/2017 - Retirado pc_set_modulo
                                (Ana - Envolti - Chamado 776896)
                   18/10/2017 - Incluído pc_set_modulo com novo padrão
                                (Ana - Envolti - Chamado 776896)
    ..............................................................................*/
    DECLARE
    	vr_nom_arquiv VARCHAR2(2000);
      vr_ext_arqsai VARCHAR2(100);
      vr_typ_saida  VARCHAR2(10);
      vr_des_saida  VARCHAR2(4000);
      vr_comando    VARCHAR2(32767);

    BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
		  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_clob_para_arquivo'); 
      -- Nome do arquivo
      vr_nom_arquiv := pr_arquivo;

      -- Se foi solicitado o arquivo com Append
      IF pr_flappend = 'S' THEN
        -- Guarda a extensao do arquivo de saída
        vr_ext_arqsai := GENE0001.fn_extensao_arquivo(vr_nom_arquiv);
        -- Remove a extensão do nome do arquivo
        vr_nom_arquiv := SUBSTR(vr_nom_arquiv,1,LENGTH(vr_nom_arquiv)-LENGTH(vr_ext_arqsai)-1);
        -- Mudar o nome do arquivo para evitar sobscrever o relatório antigo
        vr_nom_arquiv := vr_nom_arquiv||'-append'||to_char(SYSTIMESTAMP,'SSSSSFF5')||
                         '.'||vr_ext_arqsai;
      END IF;

      -- Gerar no diretório solicitado
      DBMS_XSLPROCESSOR.CLOB2FILE(pr_clob, pr_caminho, vr_nom_arquiv, NLS_CHARSET_ID('UTF8'));
      -- Setar privilégio para evitar falta de permissão a outros usuários
      gene0001.pc_OScommand_Shell(pr_des_comando => 'chmod 666 '||pr_caminho||'/'||vr_nom_arquiv);

      -- Se foi solicitado o arquivo com Append
      IF pr_flappend = 'S' THEN
        -- Comando para concatenar o conteudo
        vr_comando := 'cat '||pr_caminho||'/'||vr_nom_arquiv||' >> '||pr_caminho||'/'||pr_arquivo;
        --Executar Comando Unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_des_saida);
        -- Testa se a saída da execução acusou erro
        IF vr_typ_saida = 'ERR' THEN
          vr_des_saida := 'Erro ao efetuar concatenacao do relatório: '||vr_des_saida;
          RAISE vr_exc_erro;
        END IF;

        -- Remover o arquivo do Append
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => 'rm '||pr_caminho||'/'||vr_nom_arquiv
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_des_saida);
        -- Testa se a saída da execução acusou erro
        IF vr_typ_saida = 'ERR' THEN
          vr_des_saida := 'Erro ao eliminar o relatorio de append: '||vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
      END IF; -- pr_flappend = 'S'
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro := 'GENE0002.pc_clob_para_arquivo --> ' || vr_des_saida;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
        CECRED.pc_internal_exception;
        pr_des_erro := 'GENE0002.pc_clob_para_arquivo --> || Erro ao gravar o conteúdo do Blob para arquivo: '||sqlerrm;
    END;
  END pc_clob_para_arquivo;

  /****************************************************************************/
  /**          Procedure para copiar arquivo PDF para o sistema ayllos web   **/
  /****************************************************************************/
  PROCEDURE pc_efetua_copia_pdf (pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa conectada
                                ,pr_cdagenci IN INTEGER                      -- Codigo da agencia para erros
                                ,pr_nrdcaixa IN INTEGER                      -- Codigo do caixa para erros
                                ,pr_nmarqpdf IN VARCHAR2                  --> Arquivo PDF  a ser gerado
                                ,pr_des_reto OUT VARCHAR2                 --> Saída com erro
                                ,pr_tab_erro OUT gene0001.typ_tab_erro) IS   -- tabela de erros
  /*..............................................................................

       Programa: pc_efetua_copia_pdf            Antiga(b1wgen0024.p/efetua-copia-pdf)
       Autor   : Odirlei Busana (AMcom)
       Data    : Junho/2014                      Ultima atualizacao: 18/10/2017

       Dados referentes ao programa:

       Objetivo  : Procedure para copiar arquivo PDF para o sistema ayllos web

       Alteracoes: 17/10/2017 - Retirado pc_set_modulo
                                (Ana - Envolti - Chamado 776896)
                   18/10/2017 - Incluído pc_set_modulo com novo padrão
                                (Ana - Envolti - Chamado 776896)
    ..............................................................................*/

    ------------------------------- CURSORES ---------------------------------
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.*
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    ------------------------------- VARIAVEIS -------------------------------

    -- controle de criticas
    vr_exc_saida     EXCEPTION;
    vr_cod_erro      crapcri.cdcritic%TYPE;
    vr_dsc_erro      VARCHAR2(4000);

    vr_cmdcopia  VARCHAR2(2000);
    vr_srvintra  VARCHAR2(200);
    -- Saída do Shell
    vr_typ_saida VARCHAR2(3);

  BEGIN
	  -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
		GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_efetua_copia_pdf'); 
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cod_erro := 651; --> 651 - Falta registro de controle da cooperativa - ERRO DE SISTEMA
      vr_dsc_erro := NULL;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Buscar servidor da intranet do ambiente conectado
    vr_srvintra := gene0001.fn_param_sistema('CRED',pr_cdcooper,'SRVINTRA');
    -- Buscar script do comando de copia do arquivo
    vr_cmdcopia := gene0001.fn_param_sistema('CRED',pr_cdcooper,'SCRIPT_COPIA_INTRANET');
    -- Alterar informações do comando
    vr_cmdcopia := replace(replace(replace(vr_cmdcopia
                                         ,'<##pr_nmarqpdf##>',pr_nmarqpdf)
                                         ,'<##srvintra##>'   ,vr_srvintra)
                                         ,'<##dsdircop##>'   ,rw_crapcop.dsdircop);

    -- Efetuar a execução do comando montado
    gene0001.pc_OScommand(pr_typ_comando => 'S'
                          ,pr_des_comando => vr_cmdcopia
                          ,pr_typ_saida   => vr_typ_saida
                          ,pr_des_saida   => vr_des_erro);

    -- Se retornou erro
    IF vr_typ_saida = 'ERR' OR vr_des_erro IS NOT null THEN
      -- Concatena o erro que veio
      vr_dsc_erro := 'Erro na chamada ao Shell: '||vr_des_erro;
      RAISE vr_exc_saida;
    END IF;

    pr_des_reto := 'OK';
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);

  EXCEPTION
    WHEN vr_exc_saida THEN

      pr_des_reto := 'NOK';
      -- Chamar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cod_erro
                           ,pr_dscritic => vr_dsc_erro
                           ,pr_tab_erro => pr_tab_erro);
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
      -- Retornando a critica para o programa chamdador
      vr_cod_erro := 0;
      vr_dsc_erro := 'Erro na rotina GENE0002.pc_efetua_copia_pdf. '||sqlerrm;

      pr_des_reto := 'NOK';
      -- Chamar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cod_erro
                           ,pr_dscritic => vr_dsc_erro
                           ,pr_tab_erro => pr_tab_erro);
  END pc_efetua_copia_pdf;

  /****************************************************************************/
  /**          Procedure para copiar arquivos para o sistema InternetBank **/
  /****************************************************************************/
  PROCEDURE pc_efetua_copia_arq_ib(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa conectada
                                  ,pr_nmarqpdf IN VARCHAR2                  --> Arquivo a ser enviado
                                  ,pr_des_erro OUT VARCHAR2) IS             --> Saída com erro
  /*..............................................................................

       Programa: pc_efetua_copia_arq_ib
       Autor   : Marcos Martini (Supero)
       Data    : Agosto/2015                      Ultima atualizacao: 18/10/2017

       Dados referentes ao programa:

       Objetivo  : Procedure para copiar arquivo PDF para o sistema InternetBanking

       Alteracoes: 17/10/2017 - Retirado pc_set_modulo
                                (Ana - Envolti - Chamado 776896)
                   18/10/2017 - Incluído pc_set_modulo com novo padrão
                                (Ana - Envolti - Chamado 776896)
    ..............................................................................*/

    ------------------------------- CURSORES ---------------------------------
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.*
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    ------------------------------- VARIAVEIS -------------------------------

    -- controle de criticas
    vr_exc_saida     EXCEPTION;
    vr_dsc_erro      VARCHAR2(4000);

    vr_cmdcopia  VARCHAR2(2000);
    vr_srvib     VARCHAR2(200);
    -- Saída do Shell
    vr_typ_saida VARCHAR2(3);


  BEGIN
	  -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
		GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_efetua_copia_arq_ib'); 
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_dsc_erro := '651 - Falta registro de controle da cooperativa - ERRO DE SISTEMA';
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Buscar servidor da intranet do ambiente conectado
    vr_srvib := gene0001.fn_param_sistema('CRED',pr_cdcooper,'SRVIB_WWW')||'.'||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SRVIB_URL');
    -- Buscar script do comando de copia do arquivo
    vr_cmdcopia := gene0001.fn_param_sistema('CRED',pr_cdcooper,'SCRIPT_COPIA_IB');
    -- Alterar informações do comando
    vr_cmdcopia := replace(replace(vr_cmdcopia,'<##pr_nmarqpdf##>',pr_nmarqpdf),'<##dsurlitb##>'   ,vr_srvib);

    -- Efetuar a execução do comando montado
    gene0001.pc_OScommand(pr_typ_comando => 'S'
                          ,pr_des_comando => vr_cmdcopia
                          ,pr_typ_saida   => vr_typ_saida
                          ,pr_des_saida   => vr_des_erro);

    -- Se retornou erro
    IF vr_typ_saida = 'ERR' OR vr_des_erro NOT LIKE 'Arquivo recebido!%' THEN
      -- Concatena o erro que veio
      vr_dsc_erro := 'Erro na chamada ao Shell: '||vr_des_erro;
      RAISE vr_exc_saida;
    END IF;
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);

  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_des_erro := vr_dsc_erro;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
      -- Retornando a critica para o programa chamdador
      pr_des_erro := 'Erro na rotina GENE0002.pc_efetua_copia_pdf_ib. '||sqlerrm;
  END pc_efetua_copia_arq_ib;
  
  PROCEDURE pc_copia_arq_para_download(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa conectada
                                      ,pr_dsdirecp IN VARCHAR2                  --> Diretório do arquivo a ser copiado
                                      ,pr_nmarqucp IN VARCHAR2                  --> Arquivo a ser copiado
                                      ,pr_flgcopia IN NUMBER DEFAULT 1          --> Indica se deve ser feita copia (TRUE = Copiar / FALSE = Mover)
                                      ,pr_dssrvarq OUT VARCHAR2                 --> Nome do servidor onde o arquivo foi postado                                        
                                      ,pr_dsdirarq OUT VARCHAR2                 --> Nome do diretório onde o arquivo foi postado
                                      ,pr_des_erro OUT VARCHAR2) IS             --> Saída com erro
  /*..............................................................................

       Programa: pc_copia_arq_para_download
       Autor   : David G Kistner
       Data    : Dezembro/2017                      Ultima atualizacao: 

       Dados referentes ao programa:

       Objetivo  : Procedure para copiar/mover arquivo para diretorio que possibilita 
                   o download através de request HTTP

       Alteração:

    ..............................................................................*/

    ------------------------------- VARIAVEIS -------------------------------

    -- controle de criticas
    vr_exc_saida     EXCEPTION;
    vr_dsc_erro      VARCHAR2(4000);

    vr_cmdcopia  VARCHAR2(2000);
    vr_srvib     VARCHAR2(200);
    -- Saída do Shell
    vr_typ_saida VARCHAR2(3);

  BEGIN
    -- Buscar dsdircop
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    
    IF cr_crapcop%FOUND THEN      
      CLOSE cr_crapcop;
    ELSE
      CLOSE cr_crapcop;
      vr_des_erro := 'Cooperativa não cadastrada.';
      RAISE vr_exc_saida;
    END IF;
      
    pr_dssrvarq := gene0001.fn_param_sistema('CRED',0,'SRV_DOWNLOAD_ARQUIVO');
    pr_dsdirarq := '/'||rw_crapcop.dsdircop||gene0001.fn_param_sistema('CRED',0,'SUB_PATH_DOWNLOAD_ARQ');      
    
    IF pr_flgcopia = 1 THEN  
      vr_cmdcopia := 'cp '; -- Copiar
    ELSE
      vr_cmdcopia := 'mv '; -- Mover
    END IF;    
    
    vr_cmdcopia := vr_cmdcopia||pr_dsdirecp||pr_nmarqucp||' '||gene0001.fn_diretorio('C',0)||gene0001.fn_param_sistema('CRED',0,'PATH_DOWNLOAD_ARQUIVO')||pr_dsdirarq||'/'||pr_nmarqucp;

    -- Efetuar a execução do comando montado
    gene0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_cmdcopia
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_des_erro);

    -- Se retornou erro
    IF vr_typ_saida = 'ERR' OR vr_des_erro NOT LIKE 'Arquivo recebido!%' THEN
      RAISE vr_exc_saida;
    END IF;

  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_des_erro := vr_des_erro;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
      -- Retornando a critica para o programa chamdador
      pr_des_erro := 'Erro na rotina GENE0002.pc_copia_arq_para_download. '||sqlerrm;
  END pc_copia_arq_para_download;
  
  /*****************************************************
  **   Publicar arquivo de controle na intranet       **
  ******************************************************/
  PROCEDURE pc_publicar_arq_intranet IS

    /* ..........................................................................

     Programa: PC_PUBLICAR_ARQ_INTRANET
     Sistema : Conta-Corrente - Cooperativa de Credito
     Autor   : Odirlei Busana - AMcom
     Data    : Dezembro/2015.                     Ultima atualizacao: 18/10/2017

     Dados referentes ao programa:

     Frequencia: Em job de 30 em 30 min.
     Objetivo  : Buscar arquivos pendentes na TMPPDF da coop e enviar arquivo de controle
                 para o servidor da intranet. 

     Alteracoes: 17/10/2017 - Retirado pc_set_modulo
                              (Ana - Envolti - Chamado 776896)
                 18/10/2017 - Incluído pc_set_modulo com novo padrão
                              (Ana - Envolti - Chamado 776896)
    ..........................................................................*/

    --> Buscar dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.dsdircop,
             cop.cdcooper
        FROM crapcop cop,
             crapdat dat        
       WHERE cop.flgativo = 1
         AND cop.cdcooper = dat.cdcooper
         AND dat.inproces = 1
         ORDER BY cdcooper DESC;
         
    rw_crapcop cr_crapcop%ROWTYPE;
    
    --Tabela para receber arquivos lidos no unix
    vr_tab_arquivo  TYP_SIMPLESTRINGARRAY:= cecred.TYP_SIMPLESTRINGARRAY();
    vr_cdprogra     VARCHAR2(200) := 'pc_publicar_arq_intranet';
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(2000);
    vr_comando      VARCHAR2(2000);
    vr_dscomora     VARCHAR2(2000);
    vr_typ_saida    VARCHAR2(200);
    vr_nmarqctl     VARCHAR2(500);
    vr_nmarqctl_tmp VARCHAR2(500);
    vr_dsdircop     VARCHAR2(500);
    vr_cdcooper     NUMBER;
    vr_nmarqlog     VARCHAR2(500);
    vr_dsinterval   VARCHAR2(500);
    vr_dthora_inic  DATE;
    vr_dthora_fim   DATE;
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
		GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_publicar_arq_intranet'); 
    
    vr_cdcooper := 1;
    vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
    vr_dscomora := gene0001.fn_param_sistema('CRED',3,'SCRIPT_EXEC_SHELL');  
    
    --> Validar horario que a rotina pode rodar
    vr_dsinterval := gene0001.fn_param_sistema('CRED',3,'INTERVAL_PUBLIC_INTRANET');  
    
    vr_dthora_inic := to_date(GENE0002.fn_busca_entrada(pr_postext => 1,
                                                        pr_dstext  => vr_dsinterval, 
                                                        pr_delimitador => ';'),
                              'HH24:MI');
    
    vr_dthora_fim  := to_date(GENE0002.fn_busca_entrada(pr_postext => 2,
                                                        pr_dstext  => vr_dsinterval, 
                                                        pr_delimitador => ';'),
                              'HH24:MI');
        
    IF to_char(SYSDATE,'HH24MI') NOT BETWEEN to_char(vr_dthora_inic,'HH24MI') AND 
                                             to_char(vr_dthora_fim,'HH24MI') THEN      
      RETURN;
    END IF;     
    
    --> Buscar coops ativas para verificação dos arquivos pendentes
    FOR rw_crapcop IN cr_crapcop LOOP
      BEGIN

        vr_cdcooper := rw_crapcop.cdcooper;
        
        --> Definir nome dos arquivos
        vr_nmarqctl := 'controle.'||rw_crapcop.dsdircop||'.txt';
        vr_nmarqctl_tmp := 'controle.'||rw_crapcop.dsdircop||'_'||to_char(SYSDATE,'SSSSS')||'.tmp';

        --> buscar diretorio da cooperativa
        vr_dsdircop := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                             pr_cdcooper => vr_cdcooper,
                                             pr_nmsubdir => NULL);
        
        --> Listar arquivos da pasta tmppdf
        gene0001.pc_lista_arquivos(pr_lista_arquivo => vr_tab_arquivo,
                                   pr_path          => vr_dsdircop||'/tmppdf/',
                                   pr_pesq          => '%');  
        
        IF vr_tab_arquivo.count > 0 THEN
          --> Listar os arquivos encontrados
          FOR idx IN vr_tab_arquivo.first..vr_tab_arquivo.last LOOP
            
            --> Concatenar os arquivos no arquivo de controle
            vr_comando:= 'cat '||vr_dsdircop||'/tmppdf/'||vr_tab_arquivo(idx)||
                         ' >> '||vr_dsdircop||'/tmppdf/'||vr_nmarqctl_tmp;
              
            --Executar o comando no unix
            GENE0001.pc_OScommand (pr_typ_comando => 'S'
                                  ,pr_des_comando => vr_comando
                                  ,pr_typ_saida   => vr_typ_saida
                                  ,pr_des_saida   => vr_dscritic );
            
            IF vr_typ_saida = 'ERR' THEN
              vr_dscritic := 'Erro ao concatenar arquivo: '||vr_dscritic;
              RAISE vr_exc_erro;
            END IF;

            --> Alterar nome para depois remover o arquivo
            vr_comando:= 'mv '||vr_dsdircop||'/tmppdf/'||vr_tab_arquivo(idx)||' '||
                                vr_dsdircop||'/tmppdf/remover_'||vr_tab_arquivo(idx);

            --Executar o comando no unix
            GENE0001.pc_OScommand (pr_typ_comando => 'S'
                                  ,pr_des_comando => vr_comando
                                  ,pr_typ_saida   => vr_typ_saida
                                  ,pr_des_saida   => vr_dscritic );

            IF vr_typ_saida = 'ERR' THEN
              vr_dscritic := 'Erro ao renomear arquivo: '||vr_dscritic;
              RAISE vr_exc_erro;
            END IF;        

          END LOOP; --> Fim loop arquivos

          --> Copiar arquivo de controle para servidor
          vr_comando:= ' sudo /usr/local/cecred/bin/cp_pkghttpintranet.sh '|| rw_crapcop.dsdircop ||' '|| --> nome coop
                        vr_dsdircop||'/tmppdf/'|| vr_nmarqctl_tmp ||' '||     --> Arquivo origem
                        vr_nmarqctl;                                          --> Nome do arq. destino                      
                                  
          vr_comando := vr_dscomora ||' shell_remoto ' || vr_comando;
          
          -- alterar o diretorio pois como será executado via ssh no servidor progress
          vr_comando := regexp_replace(vr_comando,'\/coop[a-z,0-9]*\/','/coop/');
          --Executar o comando no unix
          GENE0001.pc_OScommand (pr_typ_comando => 's'
                                ,pr_des_comando => vr_comando
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => vr_dscritic);

          IF vr_typ_saida = 'ERR' THEN
            vr_dscritic := 'Erro ao enviar arquivo controle: '||vr_dscritic;
            RAISE vr_exc_erro;
          END IF;
          
          --> mover arquivo de controle para pasta salvar
          vr_comando:= 'mv '|| vr_dsdircop||'/tmppdf/'|| vr_nmarqctl_tmp ||' '||        --> Arquivo origem
                               vr_dsdircop||'/salvar/'|| vr_nmarqctl||'.'||
                               to_char(SYSDATE,'DDMM')||'.'||GENE0002.fn_busca_time; --> Nome do arq. destino

          --Executar o comando no unix
          GENE0001.pc_OScommand (pr_typ_comando => 'S'
                                ,pr_des_comando => vr_comando
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => vr_dscritic);

          IF vr_typ_saida = 'ERR' THEN
            vr_dscritic := 'Erro ao mover arquivo controle para salvar: '||vr_dscritic;
            RAISE vr_exc_erro;
          END IF;
          
          --> Remover arquivos ja enviados
          vr_comando:= 'rm '||vr_dsdircop||'/tmppdf/remover_*';

          --Executar o comando no unix
          GENE0001.pc_OScommand (pr_typ_comando => 'S'
                                ,pr_des_comando => vr_comando
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => vr_dscritic );

          IF vr_typ_saida = 'ERR' THEN
            vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
            RAISE vr_exc_erro;
          END IF;
          
        END IF;  
      -- Exception por cooperativa, para execução de uma não interferir as demais
      EXCEPTION
        WHEN vr_exc_erro THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                                     pr_ind_tipo_log => 2, --> erro tratado
                                     pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                        ' - ' || vr_cdprogra || ' --> ' || 
                                                        'ERRO: ' || '1 - pc_publicar_arq_intranet ' || vr_dscritic,
                                     pr_nmarqlog     => vr_nmarqlog,
                                     pr_cdprograma   => vr_cdprogra);

        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
          CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper); 
          vr_dscritic := 'Erro ao enviar arquivo de controle para intranet: '||SQLERRM;
          btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                                     pr_ind_tipo_log => 2, --> erro tratado
                                     pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                        ' - ' || vr_cdprogra || ' --> ' || 
                                                        'ERRO: ' || '2 - pc_publicar_arq_intranet ' || vr_dscritic,
                                     pr_nmarqlog     => vr_nmarqlog,
                                     pr_cdprograma   => vr_cdprogra);
      END; 
    END LOOP; --> Fim loop coop
    
    COMMIT;
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);

  EXCEPTION
    WHEN vr_exc_erro THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                                 pr_ind_tipo_log => 2, --> erro tratado
                                 pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra || ' --> ' || 
                                                    'ERRO: ' || '3 - pc_publicar_arq_intranet ' || vr_dscritic,
                                 pr_nmarqlog     => vr_nmarqlog,
                                 pr_cdprograma   => vr_cdprogra);

    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
      CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper); 
      vr_dscritic := 'Erro ao enviar arquivo de controle para intranet: '||SQLERRM;
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                                 pr_ind_tipo_log => 2, --> erro tratado
                                 pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra || ' --> ' || 
                                                    'ERRO: ' || '4 - pc_publicar_arq_intranet ' || vr_dscritic,
                                 pr_nmarqlog     => vr_nmarqlog,
                                 pr_cdprograma   => vr_cdprogra);

  END pc_publicar_arq_intranet;

  /****************************************************************************/
  /**          Procedure para converter proposta para o formato PDF          **/
  /****************************************************************************/
  PROCEDURE pc_gera_pdf_impressao(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa conectada
                                 ,pr_nmarqimp IN VARCHAR2                  --> Arquivo a ser convertido para pDf
                                 ,pr_nmarqpdf IN VARCHAR2                  --> Arquivo PDF  a ser gerado
                                 ,pr_des_erro OUT VARCHAR2) IS             --> Saída com erro

  /*..............................................................................

       Programa: pc_gera_pdf_impressao          Antiga(b1wgen0024.p/gera-pdf-impressao)
       Autor   : Odirlei Busana (AMcom)
       Data    : Maio/2014                      Ultima atualizacao: 18/10/2017

       Dados referentes ao programa:

       Objetivo  : Procedure para converter proposta para o formato PDF

       Alteracoes: 17/10/2017 - Retirado pc_set_modulo
                                (Ana - Envolti - Chamado 776896)
                   18/10/2017 - Incluído pc_set_modulo com novo padrão
                                (Ana - Envolti - Chamado 776896)
    ..............................................................................*/
    vr_script  VARCHAR2(2000);
    -- Saída do Shell
    vr_typ_saida VARCHAR2(3);

  BEGIN
	  -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
		GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_gera_pdf_impressao'); 

    /** Retirar caracteres especiais para impressoras matriciais **/
    vr_script := 'cat '||pr_nmarqimp||' | '||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SCRIPT_CONVERTEPCL')||
                 ' > ' ||pr_nmarqimp||'_PCL';-- 2>/dev/null';

    -- Efetuar a execução do comando montado
    gene0001.pc_OScommand(pr_typ_comando => 'S'
                          ,pr_des_comando => vr_script
                          ,pr_typ_saida   => vr_typ_saida
                          ,pr_des_saida   => vr_des_erro);
    -- Se retornou erro
    IF vr_typ_saida = 'ERR' OR vr_des_erro IS NOT null THEN
      -- Concatena o erro que veio
      vr_des_erro := 'Erro na chamada ao Shell: '||vr_des_erro;
      -- Remevor arquivo criado
      gene0001.pc_OScommand_Shell('rm '||pr_nmarqimp||'_PCL');

      RAISE vr_exc_erro;
    END IF;

    vr_script := NULL;

    /*Para tratar nova formatacao de arquivo PDF(tamanho de fonte 12 + negrito),
      sera utilizado o script "gnupdf_ft12". Demais PDF's (relatorios batch,
      Ayllos WEB) gerados pelo sistema continuam utilizando "gnupdf" */
    IF pr_nmarqimp LIKE '%proposta_seguro%' THEN
      /** Converte documento para o formato PDF  **/
      vr_script := '/usr/bin/gnupdf_ft12.pl --in '||pr_nmarqimp||'_PCL '||
                   '--conf fonte12.conf --out '||pr_nmarqpdf||' 2>/dev/null';
    ELSE
      /** Converte documento para o formato PDF **/
      vr_script := '/usr/bin/gnupdf.pl --in '||pr_nmarqimp||'_PCL '||
                   ' --out '||pr_nmarqpdf;-- 2>/dev/null
    END IF;

    -- Efetuar a execução do comando montado
    gene0001.pc_OScommand ( pr_typ_comando => 'P'
                           ,pr_des_comando => vr_script
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_des_erro);
    -- Se retornou erro
    IF vr_typ_saida = 'ERR' OR vr_des_erro IS NOT null THEN
      -- Concatena o erro que veio
      vr_des_erro := 'Erro na chamada ao Shell: '||vr_des_erro;
      -- Remevor arquivo criado
      gene0001.pc_OScommand_Shell('rm '||pr_nmarqimp||'_PCL');

      RAISE vr_exc_erro;
    END IF;

    -- Se existir arquivo, limpar pcl
    IF GENE0001.fn_exis_arquivo(pr_nmarqimp) THEN
      gene0001.pc_OScommand_Shell('rm '||pr_nmarqimp||'_PCL 2>/dev/null');
    END IF;
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Concatenar ao erro a descrição temporária
      pr_des_erro := 'GENE0002.pc_gera_pdf_impressao --> '||vr_des_erro;

    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
      -- Retornar erro
      pr_des_erro := 'GENE0002.pc_gera_pdf_impressao --> '||sqlerrm;
  END pc_gera_pdf_impressao;

  /* Procedimento para geração de PDFs */
  PROCEDURE pc_cria_PDF(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa conectada
                       ,pr_nmorigem IN VARCHAR2                  --> Path arquivo origem
                       ,pr_ingerenc IN VARCHAR2                  --> SIM/NAO
                       ,pr_tirelato IN VARCHAR2                  --> Tipo (80col, etc..)
                       ,pr_dtrefere IN DATE  DEFAULT NULL        --> Data de referencia
                       ,pr_nmsaida  OUT VARCHAR2                 --> Path do arquivo gerado
                       ,pr_des_erro OUT VARCHAR2) IS             --> Saída com erro
  BEGIN
    /*..............................................................................
       Programa: pc_cria_PDF
       Autor   : Marcos (Supero)
       Data    : Dezembro/2012                      Ultima atualizacao: 18/10/2017

       Dados referentes ao programa:

       Objetivo  : Efetuar a geração de PDF e devolver o caminho do arquivo gerado

       Observações: A sintaxe do CriaPDF.sh segue a seguinte:
                    /usr/coop/<DsDirCop>/script/CriaPDF.sh <ArqOrigem> <EhGerencial> <TipoRel> <PastaDestino> <DsDirCop>
                    Onde:
                    <ArqOrigem>    : Path do arquivo a gerar o PDF, o
                    <EhGerencial>  : SIM/NAO para gerar arquivo gerencial ou não
                    <TipoRel>      : TIpo do relatório (80col por ex)
                    <PastaDestino> : Subdiretório que a rotina gerará o PDF, o caminho final seguirá ficará no seguinte path:
                                     /usr/audit/pdf/<DsDirCop>/<PastaDestino>/<nomeArquivo>.pdf
                    <DsDirCop>     : Diretório raiz da cooperativa conectada

       Alteracoes:  23/10/2013 - Ajustar o script para não enviar mais uma barra antes
                                 do diretório rl, e também não usar a pc_gera_log_batch
                                 mas sim as rotinas específicas de manutenção de arquivo
                                 (Marcos-Supero)
                    21/01/2014 - Ajustar a validação da geração do arquivo, para que ao
                                 montar o nome do arquivo a ser verificado, a extensão
                                 não seja obrigatória.
                               - Incluir o parametro pr_dtrefere, para indicar uma data
                                 de referencia, caso for necessário. (Renato - Supero)
                    23/01/2014 - Caso o arquivo de origem precise ser copiado para o
                                 diretório 'rl' da cooperativa PR_CDCOOPER, deve remover
                                 o arquivo ao final do processamento. (Daniel - Supero)
                    17/10/2017 - Retirado pc_set_modulo
                                (Ana - Envolti - Chamado 776896)
                    18/10/2017 - Incluído pc_set_modulo com novo padrão
                                (Ana - Envolti - Chamado 776896)
    ..............................................................................*/
    DECLARE
      -- Diretório script da cooperativa
      vr_dircop VARCHAR2(200);
      -- Nome da pasta destino do PDF
      vr_nmpasta VARCHAR2(40);
      -- Script completo para a executação
      vr_script VARCHAR2(4000);
      -- Busca da data de movimento atual
      CURSOR cr_crapdat IS
        SELECT dat.dtmvtolt
          FROM crapdat dat
         WHERE dat.cdcooper = pr_cdcooper;
      vr_dtmvtolt crapdat.dtmvtolt%TYPE;
      -- Diretório e nome do arquivo
      vr_direto VARCHAR2(4000);
      vr_arquivo VARCHAR2(4000);
      vr_dsexarq VARCHAR2(1000);
      -- Saída do Shell
      vr_typ_saida VARCHAR2(3);
      -- Handle para arquivo de log
      vr_ind_arqlog UTL_FILE.file_type;
      -- Flag para indicar se houve cópia do arquivo origem para o diretório /usr/coop/<nmrescop>/rl
      vr_flg_copiou  boolean := false;
    BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
		  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_cria_PDF'); 
      -- Buscar dsdircop
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      CLOSE cr_crapcop;
      -- Buscar o diretório script da cooperativa conectada
      vr_dircop := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                        ,pr_cdcooper => pr_cdcooper);
      -- Busca somente o nome do arquivo a partir do path completo passado
      gene0001.pc_separa_arquivo_path(pr_caminho => pr_nmorigem
                                     ,pr_direto  => vr_direto
                                     ,pr_arquivo => vr_arquivo);
      -- Verifica se uma data de referencia foi repassada
      IF pr_dtrefere IS NULL THEN
        -- Montar diretório para geração do arquivo PDF, usar AAAA_MM/DD
        OPEN cr_crapdat;
        FETCH cr_crapdat
         INTO vr_dtmvtolt;
        CLOSE cr_crapdat;
      ELSE
        -- Utiliza a data do parametro
        vr_dtmvtolt := pr_dtrefere;
      END IF;

      -- Usar sysdate em caso de nao ter encontrado antes
      vr_dtmvtolt := NVL(vr_dtmvtolt,TRUNC(SYSDATE));
      vr_nmpasta := to_char(vr_dtmvtolt,'yyyy')||'_'||to_char(vr_dtmvtolt,'mm')||'/'||to_char(vr_dtmvtolt,'dd');
      -- Copiar o arquivo de origem para o diretório rl, caso ele não esteja lá.
      -- Setar o flag como TRUE para excluir o arquivo ao final do procedimento.
      IF pr_nmorigem <> vr_dircop||'/rl/'||vr_arquivo THEN
        gene0001.pc_OScommand_Shell('cp '||pr_nmorigem||' '||vr_dircop||'/rl/'||vr_arquivo);
        vr_flg_copiou := true;
      END IF;
      -- Montar comando Shell de criação do PDF
      vr_script := gene0001.fn_param_sistema('CRED',pr_cdcooper,'SCRIPT_CRIA_PDF')
                ||' rl/'||vr_arquivo||' '||pr_ingerenc||' '
                ||pr_tirelato||' '||vr_nmpasta||' '||rw_crapcop.dsdircop;
      -- Abrir arquivo de log
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_dircop||'/log'
                              ,pr_nmarquiv => 'CriaPDF.log'
                              ,pr_tipabert => 'A'
                              ,pr_utlfileh => vr_ind_arqlog
                              ,pr_des_erro => vr_des_erro);

      -- Se houver erro
      IF vr_des_erro IS NULL THEN
        -- Gerar LOG para gravar o comando gerado (enviar "Log")
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_ind_arqlog
                                      ,pr_des_text => vr_script);
        -- Fechar o arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
      END IF;
      -- Efetuar a execução do comando montado
      gene0001.pc_OScommand_Shell(pr_des_comando => vr_script
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_des_erro);
      -- Se retornou erro
      IF vr_typ_saida = 'ERR' OR vr_des_erro IS NOT null THEN
        -- Não enviar nenhuma informação no arquivo de saída
        pr_nmsaida := '';
        -- Concatena o erro que veio
        vr_des_erro := 'Erro na chamada ao Shell: '||vr_des_erro;
        -- Exclui o arquivo temporário, caso tenha sido criado
        if vr_flg_copiou then
          gene0001.pc_OScommand_Shell('rm '||vr_dircop||'/rl/'||vr_arquivo);
        end if;
        RAISE vr_exc_erro;
      ELSE
        -- Monta o nome do arquivo gerado
        pr_nmsaida := gene0001.fn_param_sistema('CRED',pr_cdcooper,'ROOT_SAIDA_PDF')||rw_crapcop.dsdircop||'/'||vr_nmpasta;
        -- CAso seja gerencial, concatena subdir ao caminho
        IF pr_ingerenc = 'SIM' THEN
          pr_nmsaida := pr_nmsaida || '/gerencial';
        END IF;
        -- Buscar a extensão do arquivo
        vr_dsexarq := GENE0001.fn_extensao_arquivo(pr_arquivo => vr_arquivo);

        -- Se o arquivo não possui extensão
        IF vr_dsexarq IS NULL THEN
          -- Montar o nome
          pr_nmsaida := pr_nmsaida || '/' || vr_arquivo ||'.pdf';
        ELSE

          -- Incluir o nome no caminho final
          pr_nmsaida := pr_nmsaida || '/' || SUBSTR(vr_arquivo,1,LENGTH(vr_arquivo)-4) ||'.pdf';
        END IF;
        -- Testa se o arquivo não foi criado com sucesso
        IF NOT gene0001.fn_exis_arquivo(pr_nmsaida) THEN
          -- Montar erro
          vr_des_erro := 'Rotina PDF não retornou erro, mas não existe o arquivo final: "'||pr_nmsaida||'"';
          -- Não enviar nenhuma informação no arquivo de saída
          pr_nmsaida := '';
          -- Exclui o arquivo temporário, caso tenha sido criado
          if vr_flg_copiou then
            gene0001.pc_OScommand_Shell('rm '||vr_dircop||'/rl/'||vr_arquivo);
          end if;
          -- LEvantar exceção
          RAISE vr_exc_erro;
        END IF;
      END IF;
      -- Exclui o arquivo temporário, caso tenha sido criado
      if vr_flg_copiou then
        gene0001.pc_OScommand_Shell('rm '||vr_dircop||'/rl/'||vr_arquivo);
      end if;
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Concatenar ao erro a descrição temporária
        pr_des_erro := 'GENE0002.pc_cria_pdf --> '||vr_des_erro;
        vr_des_erro := '';
        -- Enviar ao Log também
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratado
                                  ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                    ' - ' || 'GENE0002' || ' --> ' || 
                                                    'ERRO: ' || '1 - PC_CRIA_PDF ' || pr_des_erro
                                  ,pr_nmarqlog     => NULL
                                  ,pr_cdprograma   => 'GENE0002');

      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
        -- Retornar erro
        pr_des_erro := 'GENE0002.pc_cria_pdf --> Erro não tratado a gerar o arquivo origem: "'||pr_nmorigem||'". Erro: '||sqlerrm;
        -- Enviar ao Log também
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 3 -- Erro crítico
                                  ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                    ' - ' || 'GENE0002' || ' --> ' || 
                                                    'ERRO: ' || '2 - PC_CRIA_PDF ' || pr_des_erro
                                  ,pr_nmarqlog     => NULL
                                  ,pr_cdprograma   => 'GENE0002');
    END;
  END pc_cria_PDF;

  --> Procedimento para juntar varios PDFs
  PROCEDURE pc_Juntar_Pdf( pr_dsdirarq  IN VARCHAR2           --> Diretorio de onde se encontram os arquivos PDFs
                         ,pr_lsarqpdf  IN VARCHAR2           --> Lista dos nomes dos arquivos PDFs separados por ;
                         ,pr_nmpdfsai  IN VARCHAR2           --> Diretorio + nome do arquivo PDF de saida
                         ,pr_dscritic OUT VARCHAR2) IS       --> Critica caso ocorra
    /*..............................................................................

       Programa: pc_Juntar_Pdf
       Autor   : Odirlei Busana (AMcom)
       Data    : Setembro/2016                      Ultima atualizacao: 18/10/2017

       Dados referentes ao programa:

       Objetivo  : Procedimento para juntar/contatenar 2 ou mais arquivos PDFs separados por ;

       Alteracoes: 17/10/2017 - Retirado pc_set_modulo
                                (Ana - Envolti - Chamado 776896)
                   18/10/2017 - Incluído pc_set_modulo com novo padrão
                                (Ana - Envolti - Chamado 776896)
    ..............................................................................*/
    
    vr_exc_erro   EXCEPTION;
    vr_dscritic   VARCHAR2(1000);
    
    vr_dsscript   VARCHAR2(1000); 
    vr_dscomand   VARCHAR2(1000); 
    vr_typsaida   VARCHAR2(100);
    
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_Juntar_Pdf'); 
   
    IF pr_dsdirarq IS NULL THEN
      vr_dscritic := 'Diretorio dos arquivos PDFs não informado.';
      RAISE vr_exc_erro;    
    END IF; 
    
    IF pr_lsarqpdf IS NULL THEN
      vr_dscritic := 'Lista de arquivos PDFs não informada.';
      RAISE vr_exc_erro;    
    END IF; 
    
    IF pr_nmpdfsai IS NULL THEN
      vr_dscritic := 'Saida do PDF não informada.';
      RAISE vr_exc_erro;    
    END IF;
    
    --> Buscar script de merge
    vr_dsscript :=  gene0001.fn_param_sistema( pr_nmsistem => 'CRED', 
                                               pr_cdcooper => 0, 
                                               pr_cdacesso => 'SCRIPT_MERGEPDF');
                                              
                                              
    vr_dscomand := vr_dsscript||'  "'||pr_dsdirarq ||'" "'||
                   pr_lsarqpdf||'" "'||pr_nmpdfsai||'"';

  
    gene0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomand
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);

    -- Se retornou erro
    IF vr_typsaida = 'ERR' OR instr(vr_dscritic,'NOK') > 0 THEN
      vr_dscritic := substr(vr_dscritic,instr(vr_dscritic,'NOK') + 4);
      vr_dscritic := 'Erro ao efetuar Merge dos PDFs: '||substr(vr_dscritic,1,60);
      RAISE vr_exc_erro;
    END IF;                                          
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
      CECRED.pc_internal_exception;
      pr_dscritic := 'Erro ao efetuar Merge dos PDFs: '||SQLERRM;
  END pc_Juntar_Pdf;
  
  /* Procedimento para tratamento de arquivos ZIP*/
  PROCEDURE pc_zipcecred(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Cooperativa conectada
                        ,pr_tpfuncao  IN VARCHAR2 DEFAULT 'A'      --> Tipo de função (A-Add;E-Extract;V-View)
                        ,pr_dsorigem  IN VARCHAR2                  --> Lista de arquivos a compactar (separados por espaço) ou arquivo a descompactar
                        ,pr_dsdestin  IN VARCHAR2                  --> Caminho para o arquivo Zip a gerar ou caminho de destino dos arquivos descompactados
                        ,pr_dspasswd  IN VARCHAR2                  --> Password a incluir no arquivo
                        ,pr_flsilent  IN VARCHAR2 DEFAULT 'S'      --> Se a chamada terá retorno ou não a tela
                        ,pr_des_erro OUT VARCHAR2) IS
  BEGIN
    /*..............................................................................

       Programa : pc_zipcecred
       Autor    : Marcos (Supero)
       Data     : Dezembro/2012                      Ultima atualizacao: 18/10/2017

       Dados referentes ao programa:

       Objetivo  : Efetuar a compactação e descompactação de ZIP através de chamada
                   ao zipcecred.pl

       Observações: A sintaxe do zipcecred.pl segue o seguinte esquema:
                    zipcecred.pl --add="arq.zip" arquivo1 arquivo2 arquivo3 pass=chave
                    zipcecred.pl --extract arq.zip

                    Descricao dos parametros:
                      --add      : Funcao de compactacao
                      --extract  : Funcao de descompactacao
                      --view     : Lista conteudo do arquivo
                      --test     : Testa se existe um arquivo dentro do arquivo compactado
                      --pass     : Define senha para o arquivo a ser compactado
                      --silent   : Executar comando sem retorno para tela

       Alteracoes:
               27/11/2013 - Permitir executar o extract de arquivos. (Renato - Supero)
               17/10/2017 - Retirado pc_set_modulo
                            (Ana - Envolti - Chamado 776896)
               18/10/2017 - Incluído pc_set_modulo com novo padrão
                            (Ana - Envolti - Chamado 776896)
    ..............................................................................*/
    DECLARE
      -- Script completo para a executação
      vr_script VARCHAR2(4000);
      -- NOme do arquivo final
      vr_dsdestin VARCHAR2(4000);
      vr_dsorigem VARCHAR2(4000);
    BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_zipcecred'); 

      -- Montar comando Perl compactação ZIP
      vr_script := vr_script||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SCRIPT_ZIPCECRED');

      --Verifica a função a ser executada
      IF pr_tpfuncao = 'A' THEN
        -- Guardar nome enviado
        vr_dsdestin := pr_dsdestin;
        -- Remover aspas duplas no início e fim do nome pois a rotina já inclui
        vr_dsdestin := LTRIM(RTRIM(vr_dsdestin,'"'),'"');
        -- Se não foi passado a extensão
        IF SUBSTR(vr_dsdestin,LENGTH(vr_dsdestin)-3) <> '.zip' THEN
          -- Incluir .zip no arquivo final
          vr_dsdestin := vr_dsdestin || '.zip';
        END IF;

        -- Incluir função ADD
        vr_script := vr_script || ' -add';

        -- Incluir o destino no script
        vr_script := vr_script || ' "'||vr_dsdestin||'" ';

        -- Se informou a lista de arquivos e a função é ADD
        IF pr_dsorigem IS NOT NULL  THEN
          -- inclui a lista de arquivo a "zippar"
          vr_script := vr_script ||pr_dsorigem;
        END IF;

      ELSIF pr_tpfuncao = 'E' THEN
        -- Remover aspas duplas no início e fim do nome pois a rotina já inclui
        vr_dsorigem := LTRIM(RTRIM(pr_dsorigem,'"'),'"');
        vr_dsdestin := LTRIM(RTRIM(pr_dsdestin,'"'),'"');
        -- Incluir função EXTRACT
        vr_script := vr_script || ' -extract';
        -- Incluir o arquivo a extrair
        vr_script := vr_script ||' "'||vr_dsorigem||'"';
        -- Incluir o destino no script
        vr_script := vr_script || ' "'||vr_dsdestin||'" ';
      ELSIF pr_tpfuncao = 'V' THEN
        -- Remover aspas duplas no início e fim do nome pois a rotina já inclui
        vr_dsorigem := LTRIM(RTRIM(pr_dsorigem,'"'),'"');
        -- Incluir função VIEW
        vr_script := vr_script || ' -view';
        -- Incluir o arquivo a listar
        vr_script := vr_script ||' "'||vr_dsorigem||'"';
      ELSE
        -- Retorna a mensagem de erro informando que a função informada não é valida
        pr_des_erro := 'GENE0002.pc_zipcecred --> Tipo de função informado não é valido.';
        RETURN;
      END IF;

      -- Se foi solicitada a execução silenciosa
      IF pr_flsilent = 'S' THEN
        vr_script := vr_script || ' -silent ';
      END IF;
      -- Se foi passado Password
      IF pr_dspasswd IS NOT NULL THEN
        vr_script := vr_script || ' -pass='||pr_dspasswd||' ';
      END IF;

      -- Chamar o script recém criado
      gene0001.pc_OScommand_shell(pr_des_comando => vr_script
                                 ,pr_typ_saida   => vr_typ_said
                                 ,pr_des_saida   => vr_des_erro);
      -- Testar erro
      IF vr_typ_said = 'ERR' THEN
        -- Retornar no erro
        pr_des_erro := 'GENE0002.pc_cria_ZIP --> Erro ao zippar o(s) arquivos:"'||
                       pr_dsorigem||'" para: "'||vr_dsdestin||'". Erro> '|| vr_des_erro;
        -- O comando shell executou com erro, gerar log e sair do processo
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 3 -- Erro crítico
                                  ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                              ' - ' || 'GENE0002' || ' --> ' || 
                                                              'ERRO: ' || 'pc_cria_ZIP ao zippar o(s) arquivos:"'||
                                                              pr_dsorigem||'" para: "'||vr_dsdestin||
                                                              '" - '|| vr_des_erro
                                  ,pr_nmarqlog     => NULL
                                  ,pr_cdprograma   => 'GENE0002');
      ELSIF pr_tpfuncao = 'A' THEN -- Verifica apenas se a função for de criação do ZIP
        -- Testa se o arquivo não foi criado com sucesso
        IF NOT gene0001.fn_exis_arquivo(vr_dsdestin) THEN
          -- Gerar LOG avisando que o arquivo não foi criado
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 3 -- Erro crítico
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                                ' - ' || 'GENE0002' || ' --> ' || 
                                                                'ERRO: ' || 'pc_cria_ZIP Não gerou arquivo "'||vr_dsdestin||
                                                                '" do(s) arquivos: "'||pr_dsorigem||'"'
                                    ,pr_nmarqlog     => NULL
                                    ,pr_cdprograma   => 'GENE0002');
          -- Retornar no erro
          pr_des_erro := 'GENE0002.pc_cria_ZIP --> Não gerou arquivo "'||vr_dsdestin||'" do(s) arquivos: "'||pr_dsorigem||'"';
        END IF;
      END IF;
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 3 -- Erro crítico
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||
                                                              ' - ' || 'GENE0002' || ' --> ' || 
                                                              'ERRO: ' || 'pc_zipcecred - '||sqlerrm
                                  ,pr_nmarqlog     => NULL
                                  ,pr_cdprograma   => 'GENE0002');
        -- Retornar no erro
        pr_des_erro := 'GENE0002.pc_zipcecred --> Erro não tratao na rotina: '||sqlerrm;
    END;
  END pc_zipcecred;

  -- Rotina de Impressão de Arquivos
  PROCEDURE pc_imprim(pr_cdcooper    IN crapcop.cdcooper%TYPE  --> Cooperativa conectada
                     ,pr_cdprogra    IN VARCHAR2               --> Nome do programa que está executando
                     ,pr_cdrelato    IN craprel.cdrelato%TYPE  --> Código do relatório solicitado
                     ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE  --> Data movimento atual
                     ,pr_caminho     IN VARCHAR2               --> Path arquivo origem
                     ,pr_nmarqimp    IN VARCHAR2               --> Nome arquivo para impressao
                     ,pr_nmformul    IN VARCHAR2               --> Nome do formulário de impressão
                     ,pr_nrcopias    IN NUMBER                 --> Quantidade de Copias desejadas
                     ,pr_dircop_pdf OUT VARCHAR2               --> Retornar o path de geração do PDF
                     ,pr_cdcritic   OUT NUMBER                 --> Retornar código do erro
                     ,pr_dscritic   OUT VARCHAR2) IS           --> Retornar descrição do erro
  BEGIN
    /* .............................................................................

       Programa: pc_imprim (Antigo Fontes/imprim.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah
       Data    : Novembro/91.                        Ultima atualizacao: 18/10/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outro programa.
       Objetivo  : Executar o comando de impressao no UNIX.

       Opções de formulário(nmformul): "80col,80dcol,132m,132dm,132col,endless,padrao,timbre,etqcorreio,timb132,234dh"

       Alteracoes: 28/12/1999 - Tratar tabela de configuracao (Deborah).
                   29/12/1999 - Alterado para testar se o arquivo a ser impresso
                                nao esta vazio (Edson).
                   06/06/2002 - Colocar os relatorios em folha branca diretamente
                                para a impressora (Deborah).
                   14/08/2002 - Mostrar o comando de impressao no crps187 (Deborah)
                   21/08/2002 - Acerto na escolha do nome da impressora (Deborah).
                   07/03/2003 - Passar a creditextil para fila cctextil (Deborah)
                   20/03/2003 - Tratar fila da Concredi (Deborah).
                   08/09/2003 - Foi adicionado a Data na geracao do log (Fernando).
                   04/11/2003 - Tratar cecrisacred e credcred (Deborah).
                   10/11/2003 - Aumentar o tamnaho da glb_nmimpres (Ze Eduardo).
                   18/03/2004 - Acrescentar a Credifiesc (Ze Eduardo).
                   25/03/2004 - Padronizar a programa (Ze Eduardo).
                   26/05/2004 - Incluir formulario timbre e etiquetas para a fila
                                credito. (Ze Eduardo)
                   21/07/2005 - Tratamento para geracao de PDF (Julio)
                   02/08/2005 - Tratamento para relatorios gerenciais (PDF) (Julio)
                   28/09/2005 - Modificado FIND FIRST para FIND na tabela
                                crapcop.cdcooper = glb_cdcooper (Diego).
                   27/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
                   14/03/2006 - Envio dos relatorios em formato PDF para o
                                servidor Web, para visualizacao em Documentos (Junior).
                   16/05/2006 - Efetuar tratamento do campo craprel.inimprel
                                Efetuar impressao(Sim/Nao) (Mirtes)
                   26/05/2006 - Inicializar a variavel aux_dsgerenc com "NAO" (Edson).
                   30/08/2012 - Tratamento crapcop.nmrescop "x(20)" (Diego).
                   23/01/2013 - Conversão Progress >> PL/SQL (Marcos-Supero)
                   23/08/2013 - Prever novo método de impressão (Marcos-Supero)
                   12/09/2013 - Alteração na rotina para retornar se a solicitação
                                gerou PDF ou não. (Marcos-Supero)
                   07/01/2014 - Ajuste para evitar que seja repassado nmformul com
                                espaços apenas, pois isto gera erro durante a chamada
                                do script (Marcos-Supero)
                   03/01/2014 - Retirado leitura da craptab "FILAIMPRES" (Tiago).
                   08/01/2014 - Inicializar variavel glb_nmformul se nao estiver
                                parametrizada (David).
                   25/02/2014 - Replicar manutenção progress 02/2014 (Odirlei-AMcom)
                   17/10/2017 - Retirado pc_set_modulo
                                (Ana - Envolti - Chamado 776896)
                   18/10/2017 - Incluído pc_set_modulo com novo padrão
                                (Ana - Envolti - Chamado 776896)
    -- ...........................................................................

    ............................................................................. */
    DECLARE

      -- Variaveis Locais
      vr_setlinha VARCHAR2(1000);
      vr_tprelato NUMBER;
      vr_nmarqtmp VARCHAR2(40);
      vr_nmarqpdf VARCHAR2(40);
      vr_nmformul VARCHAR2(40);
      vr_nrcopias NUMBER;
      vr_dsgerenc VARCHAR2(3) := 'NAO';
      vr_nmimpres VARCHAR2(40);
      vr_nmrelato craprel.nmrelato%TYPE;
      vr_inimprel NUMBER;
      vr_libera_impress VARCHAR2(1);
      vr_ingerpdf NUMBER;

      -- Tratamento de erros
      vr_typ_saida VARCHAR2(3);
      vr_exc_erro  EXCEPTION;

      -- Geração do PDF
      vr_ind_arqtxt Utl_File.file_TYPE;
      vr_dircop_txt VARCHAR2(200);

      -- Buscar informacoes dos relatorios
      CURSOR cr_craprel (pr_cdcooper IN craprel.cdcooper%TYPE
                        ,pr_cdrelato IN craprel.cdrelato%TYPE) IS
        SELECT craprel.ingerpdf
              ,craprel.nmrelato
              ,craprel.inimprel
              ,craprel.tprelato
          FROM craprel craprel
         WHERE craprel.cdcooper = pr_cdcooper
           AND craprel.cdrelato = pr_cdrelato;
      rw_craprel cr_craprel%ROWTYPE;

      -- Buscar os dados da tabela Generica
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                       ,pr_nmsistem IN craptab.nmsistem%TYPE
                       ,pr_tptabela IN craptab.tptabela%TYPE
                       ,pr_cdempres IN craptab.cdempres%TYPE
                       ,pr_cdacesso IN craptab.cdacesso%TYPE
                       ,pr_tpregist IN craptab.tpregist%TYPE) IS
        SELECT craptab.dstextab
          FROM craptab craptab
         WHERE craptab.cdcooper = pr_cdcooper
           AND upper(craptab.nmsistem) = pr_nmsistem
           AND upper(craptab.tptabela) = pr_tptabela
           AND craptab.cdempres = pr_cdempres
           AND upper(craptab.cdacesso) = pr_cdacesso
           AND craptab.tpregist = pr_tpregist;
      rw_craptab cr_craptab%ROWTYPE;

    BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_imprim'); 
      -- Testar se o arquivo existe
      IF NOT gene0001.fn_exis_arquivo(pr_caminho|| '/' || pr_nmarqimp) THEN
        -- Levantar exceção
        pr_dscritic := 'O arquivo gerado não existe.';
        RAISE vr_exc_erro;
      END IF;
      -- Buscar nome do diretório no cadastro da cooperativa
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Gerar erro caso não encontre
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar cursor pois teremos raise
        CLOSE cr_crapcop;
        -- Sair com erro
        pr_cdcritic := 651;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651) || '.  --> Arquivo: '|| pr_nmarqimp;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      -- Verificar se tem caracter inválido no nome do arquivo
      IF InStr(pr_nmarqimp,'*') > 0 THEN
        pr_dscritic := 'Caracter invalido no nome do relatorio. --> Arquivo: '|| pr_nmarqimp;
        RAISE vr_exc_erro;
      END IF;
      -- Limpar variáveis de informações do cadastro de relatório
      vr_tprelato := 0;
      vr_ingerpdf := 0;
      vr_nmrelato := NULL;
      vr_inimprel := 0;
      --Buscar informacoes do relatorio
      OPEN cr_craprel(pr_cdcooper => pr_cdcooper
                     ,pr_cdrelato => pr_cdrelato);
      FETCH cr_craprel
       INTO rw_craprel;
      -- Somente se encontrar
      IF cr_craprel%FOUND THEN
        -- Copiar as informações do cursor
        vr_ingerpdf := rw_craprel.ingerpdf;
        vr_nmrelato := rw_craprel.nmrelato;
        vr_inimprel := rw_craprel.inimprel;
        -- Se o tipo for gerencial
        IF rw_craprel.tprelato = 2 THEN
          vr_dsgerenc := 'SIM';
          vr_tprelato := 1;
        END IF;
      END IF;
      --Fechar cursor
      CLOSE cr_craprel;
      -- Verificar se o nome do formulario é NULL
      IF TRIM(pr_nmformul) IS NULL THEN
        -- Utilizaremos formulario padrão
        vr_nmformul:= 'padrao';
      ELSE
        -- Utilizaremos o enviado
        vr_nmformul:= pr_nmformul;
      END IF;
      -- Se precisa gerar PDF
      IF vr_ingerpdf = 1 THEN
        -- Extrair a extensão do nome do arquivo
        vr_nmarqtmp := SubStr(pr_nmarqimp,1,InStr(pr_nmarqimp,'.')-1);
        vr_nmarqpdf := vr_nmarqtmp || '.pdf';
        vr_nmarqtmp := vr_nmarqtmp || '.txt';
        -- Buscar o diretório tmppdf da cooperativa conectada
        vr_dircop_txt := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => 'tmppdf');
        -- Tenta abrir o arquivo de log em modo append
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_dircop_txt    --> Diretório do arquivo
                                ,pr_nmarquiv => vr_nmarqtmp      --> Nome do arquivo
                                ,pr_tipabert => 'W'              --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_ind_arqtxt    --> Handle do arquivo aberto
                                ,pr_des_erro => pr_dscritic);
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Prepara a linha com as informações para gerar o TXT
        vr_setlinha := RPad(rw_crapcop.nmrescop,20,' ')          ||';'||
                       To_Char(pr_dtmvtolt,'YYYY;MM;DD')         ||';'||
                       GENE0002.fn_mask(vr_tprelato,'z9')        ||';'||
                       RPAD(vr_nmarqpdf,40,' ')                  ||';'||
                       RPAD(Upper(vr_nmrelato),50,' ')           ||';';
        -- Adiciona a linha de cabecalho
        gene0001.pc_escr_texto_arquivo(vr_ind_arqtxt,vr_setlinha);
        --Fechar Arquivo
        BEGIN
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqtxt);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
          -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
          pr_dscritic := 'Problema ao fechar o arquivo <'||vr_dircop_txt||'/'||vr_nmarqtmp||'>: ' || sqlerrm;
          RAISE vr_exc_erro;
        END;
        -- Executar a criação do PDF
        GENE0002.pc_cria_PDF(pr_cdcooper => pr_cdcooper
                            ,pr_nmorigem => pr_caminho|| '/' || pr_nmarqimp
                            ,pr_ingerenc => vr_dsgerenc
                            ,pr_tirelato => vr_nmformul
                            ,pr_dtrefere => pr_dtmvtolt
                            ,pr_nmsaida  => pr_dircop_pdf
                            ,pr_des_erro => pr_dscritic);
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := Nvl(pr_cdcritic,0);
        pr_dscritic := 'GENE0002.pc_imprim--> '||pr_dscritic;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
        pr_cdcritic := 0;
        pr_dscritic := 'GENE0002.pc_imprim --> Erro não tratado ao processar a solicitação. Erro: '||sqlerrm;
    END;
  END pc_imprim;

  /* Rotina para gerar um arquivo do CLOB passado */
  PROCEDURE pc_XML_para_arquivo(pr_XML       IN OUT NOCOPY CLOB     --> Instância do Clob
                               ,pr_caminho   IN VARCHAR2            --> Diretório para saída
                               ,pr_arquivo   IN VARCHAR2            --> Nome do arquivo de saída
                               ,pr_des_erro  OUT VARCHAR2) IS       --> Retorno de erro, caso ocorra
  BEGIN
    /*..............................................................................
       Programa: pc_XML_para_arquivo
       Autor   : Marcos (Supero)
       Data    : Dezembro/2012                      Ultima atualizacao: 18/10/2017

       Dados referentes ao programa:

       Objetivo  : Efetua leitura das informações de um Clob e grava as mesmas em arquivo

       Alteracoes:
       21/03/2013 - Petter (Supero): Alterar parser para SAX (classe Java) para melhorar performance.
       17/10/2017 - Retirado pc_set_modulo 
                    (Ana - Envolti - Chamado 776896)
       18/10/2017 - Incluído pc_set_modulo com novo padrão
                    (Ana - Envolti - Chamado 776896)
    ..............................................................................*/
    DECLARE
      -- Variáveis para tratamento do arquivo
      vr_xML    XMLType;
    BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_XML_para_arquivo');
      -- Efetuar parser para gerar mensagens de erro e validar XML
      vr_xML := XMLType.createXML(pr_XML);

      DBMS_XSLPROCESSOR.CLOB2FILE(vr_xML.getclobval(), pr_caminho, pr_arquivo, NLS_CHARSET_ID('UTF8'));
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
        CECRED.pc_internal_exception;
        pr_des_erro := 'GENE0002.pc_XML_para_arquivo --> || Erro ao gravar o conteúdo do Clob para arquivo: '||sqlerrm;
    END;
  END pc_XML_para_arquivo;

  /* Rotina para gerar um arquivo do XMLType passado */
  PROCEDURE pc_XML_para_arquivo(pr_XML       IN OUT NOCOPY XMLType  --> Instância do XML Type
                               ,pr_caminho   IN VARCHAR2            --> Diretório para saída
                               ,pr_arquivo   IN VARCHAR2            --> Nome do arquivo de saída
                               ,pr_des_erro  OUT VARCHAR2) IS       --> Retorno de erro, caso ocorra
  BEGIN
    /*..............................................................................
       Programa: pc_XML_para_arquivo
       Autor   : Marcos (Supero)
       Data    : Dezembro/2012                      Ultima atualizacao: 18/10/2017

       Dados referentes ao programa:

       Objetivo  : Efetua leitura das informações de um XMLType e grava as mesmas em arquivo

       Alteracoes: 17/10/2017 - Retirado pc_set_modulo 
                                (Ana - Envolti - Chamado 776896)
                   18/10/2017 - Incluído pc_set_modulo com novo padrão
                                (Ana - Envolti - Chamado 776896)
    ..............................................................................*/
    DECLARE
      -- Variáveis para tratamento do arquivo
      vr_dom_doc DBMS_XMLDOM.DOMDocument;
    BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_XML_para_arquivo - 2');
      -- Se o XMLTYpe possui informações
      IF pr_XML IS NOT NULL THEN
        -- Inicializar o processador Dom
        vr_dom_doc := DBMS_XMLDOM.NewDOMDocument(pr_XML);
        -- Gerar os dados do XML Type para arquivo
        DBMS_XMLDOM.WriteToFile(vr_dom_doc,pr_caminho||'/'||pr_arquivo);
        -- Liberar a memória
        DBMS_XMLDOM.freeDocument(vr_dom_doc);
      END IF;
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
        CECRED.pc_internal_exception;
        pr_des_erro := 'GENE0002.pc_XML_para_arquivo --> || Erro ao gravar o conteúdo do XMLType para arquivo: '||sqlerrm;
    END;
  END pc_XML_para_arquivo;

  /* Incluir log de geração de relatórios. */
  PROCEDURE pc_gera_log_relato(pr_cdcooper IN crapcop.cdcooper%TYPE --> Coop conectada
                              ,pr_des_log IN VARCHAR2) IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_gera_log_relato
    --  Sistema  : Processos Genéricos
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Dezembro/2012.                   Ultima atualizacao: 18/10/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: ---
    --   Objetivo  : Prever método centralizado de log de Relatórios
    --
    --   Alteracoes:  31/10/2013 - Troca do arquivo de log para salvar a partir
    --                             de agora no diretório log das Cooperativas (Marcos-Supero)
    --                17/10/2017 - Retirado pc_set_modulo 
    --                             (Ana - Envolti - Chamado 776896)
    --                18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                             (Ana - Envolti - Chamado 776896)
    -- .............................................................................

    DECLARE
      vr_ind_arqlog UTL_FILE.file_type; -- Handle para o arquivo de log
      vr_des_erro VARCHAR2(4000); -- Descrição de erro
      vr_exc_saida EXCEPTION; -- Saída com exception
      vr_des_complet VARCHAR2(100);
      vr_des_diretor VARCHAR2(100);
      vr_des_arquivo VARCHAR2(100);
    BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_gera_log_relato');
      -- Busca o diretório de log da Cooperativa
      vr_des_complet := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => 'log');
      -- Adicionar o nome do arquivo de log
      vr_des_complet := vr_des_complet ||'/'|| NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_RELATO'),'proc_gerac_relato.log');
      -- Separa o diretório e o nome do arquivo
      gene0001.pc_separa_arquivo_path(pr_caminho => vr_des_complet
                                     ,pr_direto  => vr_des_diretor
                                     ,pr_arquivo => vr_des_arquivo);
      -- Tenta abrir o arquivo de log em modo append
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_des_diretor   --> Diretório do arquivo
                              ,pr_nmarquiv => vr_des_arquivo   --> Nome do arquivo
                              ,pr_tipabert => 'A'              --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_ind_arqlog    --> Handle do arquivo aberto
                              ,pr_des_erro => vr_des_erro);
      IF vr_des_erro IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      -- Adiciona a linha de log
      BEGIN
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog,pr_des_log);
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
          -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
          vr_des_erro := 'Problema ao escrever no arquivo <'||vr_des_diretor||'/'||vr_des_arquivo||'>: ' || sqlerrm;
          RAISE vr_exc_saida;
      END;
      -- Libera o arquivo
      BEGIN
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
          -- Gerar erro
          vr_des_erro := 'Problema ao fechar o arquivo <'||vr_des_diretor||'/'||vr_des_arquivo||'>: ' || sqlerrm;
          RAISE vr_exc_saida;
      END;
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Enviar a mensagem de erro ao DMBS_OUTPUT e ignorar o log
        gene0001.pc_print(to_char(sysdate,'hh24:mi:ss')||' - '|| 'GENE0002.pc_gera_log_relato --> '||vr_des_erro);
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
        -- Temporariamente apenas imprimir na tela
        gene0001.pc_print(pr_des_mensag => to_char(sysdate,'hh24:mi:ss')||' - '
                                           || 'GENE0002.pc_gera_log_relato'
                                           || ' --> Erro não tratado : ' || sqlerrm);
    END;
  END pc_gera_log_relato;

    /* Rotina para gerar relatorio o relatório solicitado  */
  PROCEDURE pc_gera_relato(pr_nrseqsol IN crapslr.nrseqsol%TYPE    --> Sequencia da solicitação
                          ,pr_des_erro  OUT VARCHAR2) IS           --> Saída com erro
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_gera_relato
    --  Sistema  : Rotinas genéricas
    --  Sigla    : GENE
    --  Autor    : Petter Rafael - Supero Tecnologia
    --  Data     : Dezembro/2012.                   Ultima atualizacao: 21/12/2017
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Gerar LST a partir da configuração de relatório montada na
    --              tabela de solicitações de relatório CRAPSLR
    --
    --  Alteracoes: 07/11/2013 - Ajustes na passagem dos parâmetros conforme solicitação
    --                           do Guilherme. Tambem remoção de validações que eram executadas
    --                           aqui e foram repassadas para o momento da solicitação (Marcos-Supero)
    --              26/12/2013 - Incluir nova funcionalidade onde o relatório é gerado no mesmo
    --                           arquivo das solicitações antigas (append), ao contrário da função
    --                           padrão onde cada relatório gera um arquivo novo.
	  --				      17/09/2014 - Aumentar o tamanho do parametro PR_NMRELATO de 40 para 80 caracteres onde a quantidade
	  --							             de colunas for diferentes de 80 ou 132. (Felipe Oliveira)
    --              10/04/2015 - Alterado a chamada do comando "cat" para concatenação dos relatórios
    --                           para passar a usar o script concatena_relatorios.sh
    --                           (Adriano).
    --              02/08/2016 - Ajuste na rotina de geração para utilizar a versão da rotina java de geração do 
    --                           relatorio conforme a informada pelo programa gerador.
    --                           PRJ314 - INDEXAÇÃO CENTRALIZADA (Odirlei-AMcom)
    --              08/12/2016 - Ajuste para incrementar nomenclatura qnd realizar
    --                           append, para garantir processo.
    --                           SD572620 (Odirlei-AMcom)         
    --              22/06/2017 - Tratamento de erros 
    --                         - setado modulo
    --                         - Chamado 660322 - Belli - Envolti         
    --              17/10/2017 - Retirado pc_set_modulo
    --                           (Ana - Envolti - Chamado 776896)
    --              18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                           (Ana - Envolti - Chamado 776896)
    --              
    --              21/12/2017 - Melhorado consulta da crapprg com UPPER (Tiago #812349)
    -- ...........................................................................
    DECLARE
      -- Buscar dados da solicitação
      CURSOR cr_crapslr IS
        SELECT slr.dtsolici
              ,slr.cdcooper
              ,slr.cdprogra
              ,slr.dtmvtolt
              ,slr.dsxmldad
              ,slr.dsxmlnod
              ,slr.dsjasper
              ,slr.dsparams
              ,slr.dsarqsai
              ,slr.qtcoluna
              ,slr.sqcabrel
              ,slr.cdrelato
              ,slr.flsemque
              ,slr.cdparser
              ,slr.flappend
              ,slr.nrvergrl
          FROM crapslr slr
         WHERE slr.nrseqsol = pr_nrseqsol;
      rw_crapslr cr_crapslr%ROWTYPE;
      -- Busca do nome da Cooperativa
      CURSOR cr_crapcop IS
        SELECT REPLACE(cop.nmrescop,Chr(96),Chr(39)) nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = rw_crapslr.cdcooper;
      vr_nmrescop crapcop.nmrescop%TYPE;
      -- Busda dos detalhes do programa em execução
      CURSOR cr_crapprg IS
        SELECT prg.nrsolici
          FROM crapprg prg
         WHERE prg.cdcooper = rw_crapslr.cdcooper
           AND UPPER(prg.cdprogra) = UPPER(rw_crapslr.cdprogra);
      rw_crapprg cr_crapprg%ROWTYPE;
      -- Busca do cadastro de relatórios
      CURSOR cr_craprel(pr_cdrelato craprel.cdrelato%TYPE) IS
        SELECT REPLACE(rel.nmrelato,Chr(96),Chr(39)) nmrelato
              ,rel.nrmodulo
              ,REPLACE(UPPER(rel.nmdestin),Chr(96),Chr(39)) nmdestin
          FROM craprel rel
         WHERE rel.cdcooper = rw_crapslr.cdcooper  --> Coop conectada
           AND rel.cdrelato = pr_cdrelato;         --> Código relatório vinculado ao módulo
      vr_nmrelato craprel.nmrelato%TYPE;
      vr_nrmodulo craprel.nrmodulo%TYPE;
      vr_nmdestin craprel.nmdestin%TYPE;
      -- Variável para o caminho e nome do arquivo base
      vr_nom_direto VARCHAR2(2000);
      vr_nom_arqsai VARCHAR2(2000);
      vr_ext_arqsai VARCHAR2(100);
      vr_nom_arqxml VARCHAR2(2000);
      -- Variável para montagem do comando a ser executado
      vr_des_comando VARCHAR2(2000);
      -- Variáveis para teste de saída da OSCommand
      vr_typ_saida VARCHAR2(10);
      vr_des_saida VARCHAR2(4000);
      -- Variáveis para armazenar os parâmetros
      vr_progerad VARCHAR2(3);
      vr_dsparams VARCHAR2(32767);
      -- Guardar a flag de quebra como number(0/1)
      vr_flsemqueb NUMBER(1);

      --Variáveis para pegar o caminho base
      vr_dscomora  VARCHAR2(1000);
      vr_dsdirbin  VARCHAR2(1000);

      --Variável para descrição de comando
      vr_comando   VARCHAR2(32767);

      vr_scriptrl  VARCHAR2(100);

    BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 20/06/2017      
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => 'GENE0002.pc_gera_relato');
        
      -- Busca das informaçoes do relatório solicitado
      OPEN cr_crapslr;
      FETCH cr_crapslr
       INTO rw_crapslr;
      -- Somente se encontrar
      IF cr_crapslr%FOUND THEN
        -- fechar o cursor
        CLOSE cr_crapslr;
        -- Busca do nome da Cooperativa
        OPEN cr_crapcop;
        FETCH cr_crapcop
         INTO vr_nmrescop;
        CLOSE cr_crapcop;
        -- Busca dos detalhes do programa em execução
        OPEN cr_crapprg;
        FETCH cr_crapprg
         INTO rw_crapprg;
        -- Fechar o cursor para continuar o processo
        CLOSE cr_crapprg;
        -- Se houver código solicitação gravado na tabela
        IF rw_crapprg.nrsolici = 50 THEN /* TELAS */
          -- Utilizar TEL
          vr_progerad := 'TEL';
        ELSE
          -- Utilizar as ultimas três letras do código do programa
          vr_progerad := substr(lpad(rw_crapslr.cdprogra,7,' '),5);
        END IF;
        -- Incluir espaços a esquerda em caso necessário
        vr_progerad := LPAD(vr_progerad,3,' ');
        -- Busca do cadastro de relatórios as informações do relatório
        OPEN cr_craprel(pr_cdrelato => rw_crapslr.cdrelato);
        FETCH cr_craprel
         INTO vr_nmrelato
             ,vr_nrmodulo
             ,vr_nmdestin;
        -- Se não encontrar informações
        IF cr_craprel%NOTFOUND THEN
          -- enviar valores default
          vr_nmrelato := ' ';
          -- Para 80 colunas irá nr = 1
          IF rw_crapslr.qtcoluna = 80 THEN
            vr_nrmodulo := 1;
          ELSE
            vr_nrmodulo := 5;
          END IF;
        END IF;
        -- Fechar o cursor
        CLOSE cr_craprel;
        -- Separar a pasta base de saída e o nome do arquivo
        gene0001.pc_separa_arquivo_path(pr_caminho  => rw_crapslr.dsarqsai
                                       ,pr_direto   => vr_nom_direto
                                       ,pr_arquivo  => vr_nom_arqxml);
        -- Trocar a extensão do arquivo
        vr_nom_arqxml := REPLACE(vr_nom_arqxml,gene0001.fn_extensao_arquivo(vr_nom_arqxml),'xml');
        -- Gerar o arquivo de XML com mesmo nome e na mesma pasta do arquivo de saída
        GENE0002.pc_XML_para_arquivo(pr_XML      => rw_crapslr.dsxmldad
                                    ,pr_caminho  => vr_nom_direto
                                    ,pr_arquivo  => vr_nom_arqxml
                                    ,pr_des_erro => vr_des_saida);
        -- Testar se houve erro
        IF vr_des_saida IS NOT NULL THEN
          -- Gerar exceção
          RAISE vr_exc_erro;
        END IF;
        -- Testa a existencia do arquivo XML gerado
        IF NOT gene0001.fn_exis_arquivo(vr_nom_direto||'/'||vr_nom_arqxml) THEN
          vr_des_saida := 'Não foi localizado o arquivo XML gerado: "' || vr_nom_direto||'/'||vr_nom_arqxml || '"';
          RAISE vr_exc_erro;
        END IF;
        -- Armazenar o nome de saida do relatório
        vr_nom_arqsai := rw_crapslr.dsarqsai;
        -- Se foi solicitado o relatório com Append
        IF rw_crapslr.flappend = 'S' THEN
          -- Guarda a extensao do arquivo de saída
          vr_ext_arqsai := gene0001.fn_extensao_arquivo(vr_nom_arqsai);
          -- Remove a extensão do nome do arquivo
          vr_nom_arqsai := SUBSTR(vr_nom_arqsai,1,LENGTH(vr_nom_arqsai)-LENGTH(vr_ext_arqsai)-1);
          -- Mudar o nome do arquivo para evitar sobscrever o relatório antigo
          vr_nom_arqsai := vr_nom_arqsai||'-append'||pr_nrseqsol||'.'||vr_ext_arqsai;
        END IF;
        -- Adicionar os parâmetros básicos na lista de parâmetros, são eles:
        -- 1 - PR_NMRESCOP => Nome da cooperativa conectada
        -- 2 - PR_NMRELATO => Nome extenso do relatório
        -- 3 - PR_DTMVTOLT => Data do movimento atual
        -- 4 - PR_NMMODULO => Nome do módulo do sistema (Vetor gene0001.vr_vet_nmmodulo)
        -- 5 - PR_CDRELATO => Código do relatório
        -- 6 - PR_PROGERAD => Código do programa (tres ultimas letras)
        -- 7 - PR_NMDESTIN => Nome destino do cadastro de relatório
        -- 8 - PR_SQSOLICI => Número da solicitação
        -- Lembrando que cada tipo de relatório pode ter um cabeçalho diferente
        IF rw_crapslr.qtcoluna IN(80) THEN
          vr_dsparams := 'PR_NMRESCOP##'||SUBSTR(vr_nmrescop,1,11)||'@@'
                      || 'PR_NMRELATO##'||SUBSTR(vr_nmrelato,1,16)||'@@'
                      || 'PR_DTMVTOLT##'||to_char(rw_crapslr.dtmvtolt,'dd/mm/yyyy')||'@@'
                      || 'PR_NMMODULO##'||SUBSTR(gene0001.vr_vet_nmmodulo(vr_nrmodulo),1,15)||'@@'
                      || 'PR_CDRELATO##'||to_char(rw_crapslr.cdrelato,'fm000')||'@@'
                      || 'PR_PROGERAD##'||vr_progerad||'@@'
                      || 'PR_NMDESTIN##'||SUBSTR(vr_nmdestin,1,40)||'@@'
                      || 'PR_SQSOLICI##'||pr_nrseqsol||'@@'
                      || 'PR_PARSER##'||rw_crapslr.cdparser||'@@'
                      || rw_crapslr.dsparams;
        ELSIF rw_crapslr.qtcoluna = 132 THEN
          vr_dsparams := 'PR_NMRESCOP##'||SUBSTR(vr_nmrescop,1,11)||'@@'
                      || 'PR_NMRELATO##'||SUBSTR(vr_nmrelato,1,40)||'@@'
                      || 'PR_DTMVTOLT##'||to_char(rw_crapslr.dtmvtolt,'dd/mm/yyyy')||'@@'
                      || 'PR_NMMODULO##'||SUBSTR(gene0001.vr_vet_nmmodulo(vr_nrmodulo),1,15)||'@@'
                      || 'PR_CDRELATO##'||to_char(rw_crapslr.cdrelato,'fm000')||'@@'
                      || 'PR_PROGERAD##'||vr_progerad||'@@'
                      || 'PR_NMDESTIN##'||SUBSTR(vr_nmdestin,1,40)||'@@'
                      || 'PR_SQSOLICI##'||pr_nrseqsol||'@@'
                      || 'PR_PARSER##'||rw_crapslr.cdparser||'@@'
                      || rw_crapslr.dsparams;
        ELSE
          vr_dsparams := 'PR_NMRESCOP##'||SUBSTR(vr_nmrescop,1,20)||'@@'
                      || 'PR_NMRELATO##'||SUBSTR(vr_nmrelato,1,50)||'@@'
                      || 'PR_DTMVTOLT##'||to_char(rw_crapslr.dtmvtolt,'dd/mm/yyyy')||'@@'
                      || 'PR_NMMODULO##'||SUBSTR(gene0001.vr_vet_nmmodulo(vr_nrmodulo),1,15)||'@@'
                      || 'PR_CDRELATO##'||to_char(rw_crapslr.cdrelato,'fm000')||'@@'
                      || 'PR_PROGERAD##'||vr_progerad||'@@'
                      || 'PR_NMDESTIN##'||SUBSTR(vr_nmdestin,1,50)||'@@'
                      || 'PR_SQSOLICI##'||pr_nrseqsol||'@@'
                      || 'PR_PARSER##'||rw_crapslr.cdparser||'@@'
                      || rw_crapslr.dsparams;
        END IF;
        -- Guardar a flag de quebra como number(0/1)
        IF rw_crapslr.flsemque = 'S' THEN
          vr_flsemqueb := 1;
        ELSE
          vr_flsemqueb := 0;
        END IF;
        
        --> nome do parametro do script do relatorio
        vr_scriptrl := 'SCRIPT_IREPORT';
        IF rw_crapslr.nrvergrl > 0 THEN
          vr_scriptrl := vr_scriptrl||'_V'||rw_crapslr.nrvergrl;
        END IF;
        
        -- Monta comando para execução via Shell (Java), caso os parâmetros do sistemas sejam nulos retorna o path padrão
        vr_des_comando := nvl(gene0001.fn_param_sistema('CRED',rw_crapslr.cdcooper,vr_scriptrl), 'java -Xms512m -Xmx4000m -jar /usr/coop/ireport/_GeraRelatorio.jar')
                       || ' "'  ||  vr_nom_direto||'/'||vr_nom_arqxml || '" "' || rw_crapslr.dsxmlnod || '" "'
                       || nvl(gene0001.fn_param_sistema('CRED',rw_crapslr.cdcooper,'ROOT_IREPORT'), '/usr/coop/ireport/') || rw_crapslr.dsjasper
                       || '" "' || vr_dsparams || '" "' || vr_nom_arqsai || '" '
                       || rw_crapslr.qtcoluna|| ' ' ||vr_flsemqueb;

        -- Executa comando via Shell
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_des_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_des_saida);

                    
        -- 22/06/2017 - Forçado erro - Ch 660322
        --vr_des_saida := 'NOK --> com.ximpleware.ParseException: Other Error: XML not terminated properly: by Belli ';

        -- Testa se a saída da execução acusou erro
        IF length(trim(vr_des_saida)) > 4 THEN
          vr_des_saida := 'Erro na chamada ao Shell: '||vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
        -- Testa para verificar se o arquivo existe
        IF NOT gene0001.fn_exis_arquivo(vr_nom_arqsai) THEN
          vr_des_saida := 'Rotina não retornou erro, mas não existe o arquivo final: "'||vr_nom_arqsai||'"';
          RAISE vr_exc_erro;
        END IF;
        -- Eliminar o XML gerado
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => 'rm '||vr_nom_direto||'/'||vr_nom_arqxml
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_des_saida);
        -- Testa se a saída da execução acusou erro
        IF vr_typ_saida = 'ERR' THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapslr.cdcooper
                                    ,pr_ind_tipo_log => 2 --> Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',rw_crapslr.cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(sysdate, 'hh24:mi:ss') ||
                                                                ' - ' || rw_crapslr.cdprogra || ' --> ' ||
                                                                'ERRO: ' || ' 1 - GENE0002 pc_gera_relato '|| 
                                                                 REPLACE(vr_des_saida,chr(10),'')
                                    ,pr_cdprograma   => rw_crapslr.cdprogra);

        END IF;
        -- Se foi solicitado o append
        IF rw_crapslr.flappend = 'S' THEN

          --Buscar parametros
          vr_dscomora:= gene0001.fn_param_sistema('CRED',rw_crapslr.cdcooper,'SCRIPT_EXEC_SHELL');
          vr_dsdirbin:= gene0001.fn_param_sistema('CRED',rw_crapslr.cdcooper,'ROOT_CECRED_BIN');

          --se nao encontrou
          IF vr_dscomora IS NULL OR
             vr_dsdirbin IS NULL THEN

            --Montar mensagem erro
            vr_des_saida:= 'Nao foi possivel selecionar parametros.';

            --Gera exceção
            RAISE vr_exc_erro;

          END IF;

          /*Decorrente a deficiencia do script convertePCL.pl, que tem uma certa limitação
            em identificar um caracter de quebra de página "^L" sozinho em uma linha, faz com que
            o arquivo seja convertido de forma errada e, consequentemente, se este for convertido para
            pdf (pelo gnupdf.pl) será convertido de forma errada. O arquivo terá várias quebras de páginas
            indevidas.
            Para contornar este problema, foi desenvolvido o script concatena_relatorios.sh para
            efetuar a concatenação de forma que o conteúdo fique na mesma linha da queba "^LArquivo...".
            Desta forma, o convertePCL.pl conseguirá converter o relatório de forma correta e o gnupdf.pl
            também. Assim, resolvendo o problema.*/
          vr_comando:= vr_dscomora || ' shell ' || vr_dsdirbin || 'concatena_relatorios.sh '||
                       chr(39)||vr_nom_arqsai||chr(39) || ' ' ||
                       chr(39)||rw_crapslr.dsarqsai||chr(39) ||
                       ' > ' ||rw_crapslr.dsarqsai || '.tmp';

          --Executar Comando Unix
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => vr_comando
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_des_saida);

          -- Testa se a saída da execução acusou erro
          IF vr_typ_saida = 'ERR' THEN
            vr_des_saida := 'Erro ao efetuar concatenacao do relatório: '||vr_des_saida;
            RAISE vr_exc_erro;
          END IF;

          -- Efetuar mv do arquivo temporário gerado para o nome real do relatório
          gene0001.pc_mv_arquivo(pr_dsarqori  => rw_crapslr.dsarqsai||'.tmp', 
                                 pr_dsarqdes  => rw_crapslr.dsarqsai, 
                                 pr_typ_saida => vr_typ_saida, 
                                 pr_des_saida => vr_des_saida);

          -- Testa se a saída da execução acusou erro
          IF vr_typ_saida = 'ERR' THEN
            vr_des_saida := 'Erro ao efetuar Mv do relatório: '||vr_des_saida;
            RAISE vr_exc_erro;
          END IF;

          -- Remover o arquivo do Append
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => 'rm '||vr_nom_arqsai
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_des_saida);
          -- Testa se a saída da execução acusou erro
          IF vr_typ_saida = 'ERR' THEN
            vr_des_saida := 'Erro ao eliminar o relatorio de append: '||vr_des_saida;
            RAISE vr_exc_erro;
          END IF;
        END IF;
      ELSE
        -- fechar o cursor
        CLOSE cr_crapslr;
      END IF;
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro := 'GENE0002.pc_gera_relato--> '||vr_des_saida;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
        CECRED.pc_internal_exception;
        pr_des_erro := 'GENE0002.pc_gera_relato --> Erro não tratado ao processar a solicitação. Erro: '||sqlerrm;
    END;
  END pc_gera_relato;

  /* Procedimento que processa os relatórios pendentes e chama sua geração */
  PROCEDURE pc_process_relato_penden(pr_nrseqsol IN crapslr.nrseqsol%TYPE DEFAULT NULL --> Processar somente a sequencia passada
                                    ,pr_cdfilrel IN crapslr.cdfilrel%TYPE DEFAULT NULL --> Processar todas as sequencias da fila
                                    ,pr_des_erro OUT VARCHAR2) IS
  BEGIN
    /* ..........................................................................

        Programa : pc_process_relato_penden
        Sistema  : Rotinas genéricas
        Sigla    : GENE
        Autor    : Marcos E. Martini - Supero
        Data     : Dezembro/2012.                   Ultima atualizacao: 21/12/2017

        Dados referentes ao programa:

         Frequencia: Sempre que for chamado
         Objetivo  : Esta rotina tem as seguintes funcionalidades:

                     a) Em caso de envio de uma solicitação (pr_nrseqsol)
                        - Processar a solicitação
                        - Não commitar no momento
                     b) Em caso de envio de uma fila específica (pr_cdfilrel)
                        - Processar as <n> ultimas solicitações pendentes da fila

                     Em ambas as situações acima ocorre o processo normal, que consiste
                     em gerar o arquivo cfme parâmetros, imprimir e gerar para intranet, copiar
                     para diretórios de rede, enviar e-mail, e enviar log de erro.

         Obs: A rotina nao para o processo em caso de erro na solicitaçao, pois todas devem ser processadas

         Alteracoes: 11/09/2013 - Prevista opção para converter o arquivo para envio de
                                  email ou cópia em PDF (Marcos-Supero)
                     17/10/2013 - Somente copiar para intranet/imprimir, enviar por email ou
                                  copiar para diretório se o relatório possuir pelo menos 1 Byte
                                  (Marcos-Supero)
                     28/10/2013 - Remover a eliminação de solicitações antigas daqui e passá-la
                                  para o processo controlador (pc_controle_filas_relato)
                                - Também ajustar a busca das solicitações pendentes para que a
                                  consulta trave o registro (for update). Isto se deve ao fato
                                  da alteração de sistema que preve que mais do que um job por
                                  fila pode estar ativo. E se não travarmos o registro, dois
                                  jobs podem pegar a mesma  solicitação.
                                - Também evitar que o processo chame um relatório que tenha a
                                  mesma saída que outro em processo  (Marcos-Supero)
                     18/11/2013 - Ajustar log de remoção do arquivo, pois a remoção pode ser
                                  solicitada inclusive se for solicitado somente a imprim.p,
                                  antes só era feita na copia/email do relatório (Marcos-Supero)
                     08/01/2014 - Alteração da rotina para deixar dinâmico qual a extensão desejada
                                  para cópia ou envio de e-mail do relatórios pós-processo (Marcos-Supero)
                     12/03/2014 - Alteração para permitir que o arquivos seja convertido para DOS
                                  antes do envio por e-mail ou cópia para diretório (Marcos-Supero)
                     31/08/2015 - Inclusao do parametro flappend na pc_clob_para_arquivo.
                                  (Jaison/Marcos-Supero)
                     29/12/2015 - Controlar lock na tabela crapslr, para que o lock ocorra a nivel de registro 
                                  e não toda a consulta SD379026 (Odirlei-AMcom)             
                     17/10/2017 - Retirado pc_set_modulo
                                  (Ana - Envolti - Chamado 776896)
                     18/10/2017 - Incluído pc_set_modulo com novo padrão
                                  (Ana - Envolti - Chamado 776896)
                     21/12/2017 - Retirado clob da consulta principal na CRAPSLR pois era algo
                                  usado em um caso especifico e contribuia para uma baixa 
                                  performance do programa (Tiago #812349)                     
       ............................................................................. */
    DECLARE
      -- Busca de informações da fila
      CURSOR cr_crapfil IS
        SELECT fil.qtreljob
          FROM crapfil fil
         WHERE fil.cdfilrel = pr_cdfilrel;
      -- Quantidade de relatórios a processar no Job
      vr_qtreljob NUMBER;
      -- Auxiliar para controle da qtdade de relatórios processados por vez
      vr_qtrelproc NUMBER := 0;
      -- Busca dos relatórios pendentes de geração
      CURSOR cr_crapslr IS
        SELECT slr.rowid
              ,slr.nrseqsol
              ,slr.cdcooper
              ,slr.cdprogra
              ,slr.dtmvtolt
              ,slr.dsarqsai
              ,slr.flimprim
              ,slr.nmformul
              ,slr.nrcopias
              ,slr.cdrelato
              ,slr.dspathcop
              ,slr.dsextcop
              ,slr.fldoscop
              ,slr.dscmaxcop
              ,slr.dsmailcop
              ,slr.dsassmail
              ,slr.dscormail
              ,slr.dsextmail
              ,slr.fldosmail
              ,slr.dscmaxmail
              ,slr.flarquiv
              ,slr.flremarq
              ,slr.flappend
          FROM crapslr slr
         WHERE    --> Sempre processa quando passado uma específica
              (   slr.nrseqsol = pr_nrseqsol
                  --> OU aqueles da fila passada, que ainda não foram gerados e iniciados
               OR(     slr.cdfilrel = pr_cdfilrel AND slr.flgerado = 'N' AND slr.dtiniger IS NULL
                   --> Evitar que o processo chame um relatório que tenha a mesma saída que outro em processo
                   AND NOT EXISTS(SELECT 1
                                    FROM crapslr slr_proc
                                   WHERE slr_proc.nrseqsol <> slr.nrseqsol
                                     AND slr_proc.dsarqsai = slr.dsarqsai
                                     AND slr_proc.flgerado = 'N'
                                     AND slr_proc.dtiniger IS NOT NULL)
                 )
              )
         ORDER BY slr.nrseqpri      --> Ordenar pela prioridade cadastrada
                 ,slr.flgbatch DESC --> Depois os que foram solicitados pela cadeia primeiro (flgbatch = 1)
                 ,slr.nrseqsol;     --> e dentro da mesma prioridade os mais antigos primeiro

      rw_crapslr cr_crapslr%ROWTYPE;
      
      CURSOR cr_crapslr_xml (pr_rowid ROWID) IS
        SELECT slr.rowid,
               slr.dsxmldad
          FROM crapslr slr
         WHERE slr.ROWID = pr_rowid;

      rw_crapslr_xml cr_crapslr_xml%ROWTYPE;
      
      -- lockar registro, porém sem aguardar em caso se ja estar lockado
      CURSOR cr_crapslr_rowid (pr_rowid ROWID) IS
        SELECT slr.rowid,
               slr.dtiniger
          FROM crapslr slr
         WHERE slr.ROWID = pr_rowid
           FOR UPDATE NOWAIT; --> Lockando o registro
      rw_crapslr_rowid cr_crapslr_rowid%ROWTYPE;
      
      -- Configuração do relatório
      CURSOR cr_craprel(pr_cdcooper IN craprel.cdcooper%TYPE
                       ,pr_cdrelato IN craprel.cdrelato%TYPE) IS
        SELECT craprel.tprelato
          FROM craprel craprel
         WHERE craprel.cdcooper = pr_cdcooper
           AND craprel.cdrelato = pr_cdrelato;
      vr_tprelato craprel.tprelato%TYPE;
      vr_dsgerenc VARCHAR2(3) := 'NAO';
      -- Separaçao do caminho e nome do arquivo
      vr_dsdir VARCHAR2(300);
      vr_dsarq VARCHAR2(300);
      -- Variavel para armazenar o horário de início da solicitação.
      vr_dthorain DATE;
      -- Lista de diretórios para cópia
      vr_lista_copia GENE0002.typ_split; --> Split de caminhos
      -- Tipo de saída e comando Host
      vr_typ_said VARCHAR2(100);
      vr_des_comando VARCHAR2(4000);
      -- Auxiliar para chamada a impressão
      vr_cdcritic NUMBER;
      -- Texto auxiliar para escrita no log
      vr_des_log VARCHAR2(32767);
      -- Texto para gravação do erro na tabela
      vr_dserrger crapslr.dserrger%TYPE;
      -- Caminho de geração do PDF pós imprimp.p
      vr_nmsai_pdf VARCHAR2(400);
      vr_nmdir_pdf VARCHAR2(300);
      vr_nmarq_pdf VARCHAR2(100);
      -- Nome do arquivo para cópia/e-mail
      vr_nmarq_base  VARCHAR2(300);
      vr_nmarq_copia VARCHAR2(400);
      vr_dsdirconv   VARCHAR2(100);
      -- Tamanho do arquivo
      vr_qtd_bytes NUMBER;
      
    BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_process_relato_penden');
      
      -- Efetuar laço para processar a quantidade maxima de relatórios
      LOOP
        -- Busca quantidade maxima de relatórios por Job na fila
        -- Obs.: Buscamos a cada iteração justamente para em casos
        --       do gestor alterar esta quantidade quando o job estiver
        --       processando muitos relatórios por vez, então já temos
        --       a quantidade atualizada.
        OPEN cr_crapfil;
        FETCH cr_crapfil
         INTO vr_qtreljob;
        CLOSE cr_crapfil;
        -- Incrementa a quantidade de solicitações processadas
        vr_qtrelproc := vr_qtrelproc + 1;
        -- Limpar variavel de erro
        vr_dserrger := null;
        vr_des_erro := null;
        -- Limpar o caminho de geração de PDF
        vr_nmsai_pdf := '';
        -- Busca 1 solicitação por vez, isso garante que caso alguém
        -- mude a prioridade durante o processo, a nova busca retorne
        -- as prioridades atualizadas
        OPEN cr_crapslr;
        --> loop para lockar registro
        LOOP
          FETCH cr_crapslr INTO rw_crapslr;
          IF cr_crapslr%FOUND THEN
          
            -- Lockar o registro
            BEGIN
              
              OPEN cr_crapslr_rowid (pr_rowid => rw_crapslr.rowid);
              FETCH cr_crapslr_rowid INTO rw_crapslr_rowid; 
              IF cr_crapslr_rowid%NOTFOUND THEN
                CLOSE cr_crapslr_rowid;
                EXIT;
              ELSE
                CLOSE cr_crapslr_rowid;
                --> Garantir que nesse meio tempo outro processo já lockou 
                -- e esta processando
                IF rw_crapslr_rowid.dtiniger IS NOT NULL AND
                   pr_nrseqsol IS NULL THEN                  
                  -- Se estiver busca o proximo
                  continue;
                END IF;              
              END IF;                             
            EXCEPTION
              WHEN OTHERS THEN
                IF cr_crapslr_rowid%ISOPEN THEN
                  CLOSE cr_crapslr_rowid;
                END IF;    
              
                -- caso registro já esteja lockado busca o proximo              
                continue;              
            END;
          END IF;  
          EXIT;          
        END LOOP; 
        
        -- Somente se encontrou registro
        IF cr_crapslr%FOUND THEN
          -- Fechar o cursor
          CLOSE cr_crapslr;
          -- Guardar o início da execução
          vr_dthorain := SYSDATE;
          -- Atualizar o registro com a data de início
          BEGIN
            UPDATE crapslr
               SET dtiniger = vr_dthorain
             WHERE rowid = rw_crapslr.rowid;
            -- Se estiver rodando no processo automatizado
            -- já commita o registro para não processa-la mais de uma vez
            IF pr_nrseqsol IS NULL THEN
              -- Commitar os registros processados
              COMMIT;
            END IF;
          END;
          -- Adicionar log
          vr_des_log := chr(13)
                     || to_char(sysdate,'hh24:mi:ss')
                     || ' --> Início da geração --> Seq '||rw_crapslr.nrseqsol
                     || ', programa '||rw_crapslr.cdprogra
                     || ', saida '||rw_crapslr.dsarqsai;
          -- Separaçao do caminho e nome do arquivo
          gene0001.pc_separa_arquivo_path(pr_caminho => rw_crapslr.dsarqsai
                                         ,pr_direto  => vr_dsdir
                                         ,pr_arquivo => vr_dsarq);
          -- Se for para gerar o arquivo texto puro
          IF Nvl(rw_crapslr.flarquiv,'N') = 'S' THEN
            OPEN cr_crapslr_xml(pr_rowid => rw_crapslr.rowid);
            FETCH cr_crapslr_xml INTO rw_crapslr_xml;
            
            IF cr_crapslr_xml%NOTFOUND THEN
              CLOSE cr_crapslr_xml;
              vr_des_erro := 'GENE0002.pc_process_relato_penden --> CLOB do relatorio pendente nao encontrado. rowid: '||rw_crapslr.rowid;              
            ELSE           
              CLOSE cr_crapslr_xml;
            -- Criar o arquivo no diretorio especificado
              pc_clob_para_arquivo(pr_clob     => rw_crapslr_xml.dsxmldad
                                ,pr_caminho  => vr_dsdir
                                ,pr_arquivo  => vr_dsarq
                                ,pr_flappend => rw_crapslr.flappend
                                ,pr_des_erro => vr_des_erro);
            END IF;
          ELSE
            -- Chamar a geração
            pc_gera_relato(pr_nrseqsol => rw_crapslr.nrseqsol
                          ,pr_des_erro => vr_des_erro);
            -- Setar as propriedades para garantir que o arquivo seja acessível por outros usuários
            gene0001.pc_OScommand_Shell(pr_des_comando => 'chmod 666 '||vr_dsdir||'/'||vr_dsarq);
          END IF;

          -- Se houve erro
          IF vr_des_erro IS NOT NULL THEN
            -- Adicioná-lo a variavel acumulativa de erro
            vr_dserrger := vr_des_erro;
            -- Adicionar no arquivo de log o problema na execução
            vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> Geração arquivo com erro --> '||vr_des_erro;
          ELSE
            -- Adicionar no log a execução com sucesso
            vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> Geração arquivo com êxito em '||fn_calc_difere_datas(vr_dthorain,SYSDATE);
            -- Busca o tamanho do arquivo, pois para enviar para a intranet/impressora
            -- ou copiar para os diretórios/enviar por email, precisa ter sido gerado algo
            vr_qtd_bytes := GENE0001.fn_tamanho_arquivo(rw_crapslr.dsarqsai);

            -- Se foi solicitado a impressão e o arquivo possui pelo menos 1 byte
            IF rw_crapslr.flimprim = 'S' AND vr_qtd_bytes > 0 THEN
              -- Guardar a hora de início do processo de impressão
              vr_dthorain := SYSDATE;
              -- Chamar a rotina de impressão
              pc_imprim(pr_cdcooper   => rw_crapslr.cdcooper --> Cooperativa conectada
                       ,pr_cdprogra   => rw_crapslr.cdprogra --> Nome do programa que solicitou o rep
                       ,pr_cdrelato   => rw_crapslr.cdrelato --> Código do relatório solicitado
                       ,pr_dtmvtolt   => rw_crapslr.dtmvtolt --> Data movimento atual
                       ,pr_caminho    => vr_dsdir            --> Path arquivo origem
                       ,pr_nmarqimp   => vr_dsarq            --> Nome arquivo para impressao
                       ,pr_nmformul   => rw_crapslr.nmformul --> Nome do formulário de impressão
                       ,pr_nrcopias   => rw_crapslr.nrcopias --> Quantidade de Copias desejadas
                       ,pr_dircop_pdf => vr_nmsai_pdf       --> Retorna o caminho do PDF gerado pela imprim.p
                       ,pr_cdcritic   => vr_cdcritic         --> Código do erro
                       ,pr_dscritic   => vr_des_erro);       --> Saída com erro
              -- Testar saída com erro
              IF vr_des_erro IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
                -- Adicioná-lo a variavel acumulativa de erro
                vr_dserrger := vr_dserrger || chr(10) || vr_des_erro;
                -- Adicionar no arquivo de log o problema na execução
                vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> impressao/copia intranet com erro --> '||vr_des_erro;
              ELSE
                -- Enviar log com o tempo de impressão e compactação PDF
                vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> impressao/copia intranet com êxito em '||fn_calc_difere_datas(vr_dthorain,SYSDATE);
              END IF;
            END IF;

            -- Se foi solicitado email ou cópia em PDF e o arquivo possui pelo menos 1 byte
            IF (rw_crapslr.dsextcop = 'pdf' OR rw_crapslr.dsextmail = 'pdf') AND vr_qtd_bytes > 0 THEN
              -- Somente se o PDF ainda não foi gerado
              IF vr_nmsai_pdf IS NULL THEN
                -- Enviar o LOG da geração do PDF
                vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> Seq '||rw_crapslr.nrseqsol||' --> convertendo para PDF devido envio ou cópia do relatório em PDF.';
                -- Buscar configuração do relatório
                OPEN cr_craprel(pr_cdcooper => rw_crapslr.cdcooper
                               ,pr_cdrelato => rw_crapslr.cdrelato);
                FETCH cr_craprel
                 INTO vr_tprelato;
                -- Somente se encontrar
                IF cr_craprel%FOUND THEN
                  -- Se o tipo for gerencial
                  IF vr_tprelato = 2 THEN
                    vr_dsgerenc := 'SIM';
                  END IF;
                END IF;
                -- Fechar cursor
                CLOSE cr_craprel;
                -- Executar a criação do PDF
                GENE0002.pc_cria_PDF(pr_cdcooper => rw_crapslr.cdcooper
                                    ,pr_nmorigem => vr_dsdir||'/'||vr_dsarq
                                    ,pr_ingerenc => vr_dsgerenc
                                    ,pr_tirelato => NVL(rw_crapslr.nmformul,'padrao')
                                    ,pr_dtrefere => rw_crapslr.dtmvtolt
                                    ,pr_nmsaida  => vr_nmsai_pdf
                                    ,pr_des_erro => vr_des_erro);
                -- Se houve erro
                IF vr_des_erro IS NOT NULL THEN
                  -- Mandar o arquivo original pois não temos como enviar o PDF com erro
                  vr_nmsai_pdf := vr_dsdir||'/'||vr_dsarq;
                  -- Adicionar LOG do erro
                  vr_dserrger := vr_dserrger || chr(10) || ' --> erro na conversão do arquivo para PDF --> '||vr_des_erro;
                  -- O comando shell executou com erro, gerar log
                  vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> erro na conversão do arquivo para PDF  --> '||vr_des_erro;
                END IF;
              END IF;
              -- Separar path e nome do arquivo PDF
              gene0001.pc_separa_arquivo_path(pr_caminho => vr_nmsai_pdf
                                             ,pr_direto  => vr_nmdir_pdf
                                             ,pr_arquivo => vr_nmarq_pdf);
            END IF;

            -- Se foi solicitado a cópia do relatório para um ou mais diretórios
            IF rw_crapslr.dspathcop IS NOT NULL THEN
              -- Troca todas as virgulas por ponto e virgula, para facilitar a busca abaixo
              rw_crapslr.dspathcop := REPLACE(rw_crapslr.dspathcop,',',';');
              -- Quebra string retornada da consulta pelo delimitador ';'
              vr_lista_copia := GENE0002.fn_quebra_string(rw_crapslr.dspathcop, ';');
              -- Se foi solicitada a cópia do arquivo em PDF
              IF rw_crapslr.dsextcop = 'pdf' THEN
                -- Copiaremos o PDF
                vr_nmarq_base := vr_nmdir_pdf||'/'||vr_nmarq_pdf;
                -- Nome do arquivo pós copia continua o mesmo do PDF
                vr_nmarq_copia := vr_nmarq_pdf;
              ELSE
                -- A base para cópia é o arquivo original
                vr_nmarq_base := vr_dsdir||'/'||vr_dsarq;
                -- Se foi qualquer outra extensão
                IF rw_crapslr.dsextcop IS NOT NULL THEN
                  -- Montamos o novo nome do arquivo trocando a extensão original pela nova
                  vr_nmarq_copia := REPLACE(vr_dsarq,gene0001.fn_extensao_arquivo(vr_dsarq),rw_crapslr.dsextcop);
                ELSE
                  -- Mantemos o nome do arquivo original
                  vr_nmarq_copia := vr_dsarq;
                END IF;
              END IF;
              -- Itera sobre o array para encontrar se foi possivel retornar 1 ou mais caminhos para cópia
              IF vr_lista_copia.count > 0 THEN
                -- Ler todos os registros do vetor de caminhos
                FOR vr_idx IN 1..vr_lista_copia.count LOOP
                  -- Enviar o LOG de cópia do arquivo
                  vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> copiando/convertendo arquivo para '||vr_lista_copia(vr_idx);
                  -- Remover / a direita para evitar problemas no comando CP
                  vr_lista_copia(vr_idx) := RTRIM(vr_lista_copia(vr_idx),'/');
                  -- Se foi solicitada a conversão para DOS
                  IF rw_crapslr.fldoscop = 'S' AND nvl(rw_crapslr.dsextcop,' ') != 'pdf' THEN
                    -- Executa comando UX2DOS concatenando o comando auxiliar (se existir)
                    vr_des_comando := 'ux2dos < ' || vr_nmarq_base || ' ' || rw_crapslr.dscmaxcop ||' > ' ||vr_lista_copia(vr_idx)||'/'||vr_nmarq_copia||' 2>/dev/null';
                  ELSE -- Senão, apenas faz a cópia
                    vr_des_comando := 'cp '||vr_nmarq_base||' '||vr_lista_copia(vr_idx)||'/'||vr_nmarq_copia;
                  END IF;
                  -- Para cada caminho, executar o comando montado acima
                  gene0001.pc_OScommand_Shell(pr_des_comando => vr_des_comando
                                             ,pr_typ_saida   => vr_typ_said
                                             ,pr_des_saida   => vr_des_erro);
                  -- Testar erro
                  IF vr_typ_said = 'ERR' THEN
                    -- Adicionar o erro na variavel acumulativa de erros
                    vr_dserrger := vr_dserrger || chr(10) || ' --> erro na copia/conversão do arquivo --> '||vr_des_erro;
                    -- O comando shell executou com erro, gerar log
                    vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> erro na copia/conversão do arquivo --> '||vr_des_erro;
                  END IF;
                END LOOP;
              END IF;
            END IF;

            -- Se foi solicitado envio por e-mail
            IF trim(rw_crapslr.dsmailcop) IS NOT NULL THEN
              -- Enviar o LOG de envio de e-mail
              vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> Seq '||rw_crapslr.nrseqsol||' --> solicitando envio de e-mail do arquivo para '||rw_crapslr.dsmailcop;

              -- Se foi solicitada o e-mail do arquivo em PDF
              IF rw_crapslr.dsextmail = 'pdf' THEN
                -- Enviaremos o PDF
                vr_nmarq_base := vr_nmdir_pdf||'/'||vr_nmarq_pdf;
                -- Nome do arquivo pós copia continua o mesmo do PDF
                vr_nmarq_copia := vr_nmarq_pdf;
              ELSE
                -- A base para cópia é o arquivo original
                vr_nmarq_base := vr_dsdir||'/'||vr_dsarq;
                -- Se foi qualquer outra extensão
                IF trim(rw_crapslr.dsextmail) IS NOT NULL THEN
                  -- Montamos o novo nome do arquivo trocando a extensão original pela nova
                  vr_nmarq_copia := REPLACE(vr_dsarq,gene0001.fn_extensao_arquivo(vr_dsarq),rw_crapslr.dsextmail);
                ELSE
                  -- Mantemos o mesmo nome do arquivo original
                  vr_nmarq_copia := vr_dsarq;
                END IF;
              END IF;

              -- Busca do diretório converte
              vr_dsdirconv := gene0001.fn_diretorio(pr_cdcooper => rw_crapslr.cdcooper
                                                   ,pr_tpdireto => 'C'
                                                   ,pr_nmsubdir => 'converte');

              -- Se foi solicitada a conversão para DOS antes de enviar
              IF rw_crapslr.fldosmail = 'S' AND nvl(rw_crapslr.dsextmail,' ') != 'pdf' THEN
                -- Executa comando UX2DOS concatenando o comando auxiliar (se existir)
                vr_des_comando := 'ux2dos < ' || vr_nmarq_base || ' ' || rw_crapslr.dscmaxmail ||' > ' ||vr_dsdirconv||'/'||vr_nmarq_copia||' 2>/dev/null';
              ELSE -- Senão, apenas faz a cópia
                vr_des_comando := 'cp '||vr_nmarq_base||' '||vr_dsdirconv||'/'||vr_nmarq_copia;
              END IF;
              -- Para cada caminho, executar o comando montado acima
              gene0001.pc_OScommand_Shell(pr_des_comando => vr_des_comando
                                         ,pr_typ_saida   => vr_typ_said
                                         ,pr_des_saida   => vr_des_erro);
              -- Testar erro
              IF vr_typ_said = 'ERR' THEN
                -- Adicionar o erro na variavel acumulativa de erros
                vr_dserrger := vr_dserrger || chr(10) || ' --> erro na copia/conversão do arquivo para envio de e-mail --> '||vr_des_erro;
                -- O comando shell executou com erro, gerar log
                vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> erro na copia/conversão do arquivo para envio de email --> '||vr_des_erro;
              ELSE
                -- Enviar o relatório por e-mail
                gene0003.pc_solicita_email(pr_cdcooper        => rw_crapslr.cdcooper
                                          ,pr_flg_remete_coop => 'S' --> Envio pelo e-mail da Cooperativa
                                          ,pr_cdprogra        => rw_crapslr.cdprogra
                                          ,pr_des_destino     => rw_crapslr.dsmailcop
                                          ,pr_des_assunto     => rw_crapslr.dsassmail
                                          ,pr_des_corpo       => rw_crapslr.dscormail
                                          ,pr_des_anexo       => vr_dsdirconv||'/'||vr_nmarq_copia
                                          ,pr_flg_remove_anex => 'N' --> Manter o arquivo no diretório converte
                                          ,pr_des_erro        => vr_des_erro);
                -- Se houver erro
                IF vr_des_erro IS NOT NULL THEN
                  -- Adicionar o erro na variavel acumulativa de erros
                  vr_dserrger := vr_dserrger || chr(10) || ' --> solicitação envio de email com erro --> '||vr_des_erro;
                  -- Gerar log
                  vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> solicitação envio de email com erro --> '||vr_des_erro;
                END IF;
              END IF;
            END IF;

            -- Se foi solicitado para remover o arquivo de origem
            IF rw_crapslr.flremarq = 'S' THEN
              -- Enviar o LOG de cópia do arquivo
              vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> removendo o arquivo após cópia/email/impressao';
              -- Para cada caminho, executar o comando de cópia
              gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_dsdir||'/'||vr_dsarq
                                         ,pr_typ_saida   => vr_typ_said
                                         ,pr_des_saida   => vr_des_erro);
              -- Testar erro
              IF vr_typ_said = 'ERR' THEN
                -- Adicionar o erro na variavel acumulativa de erros
                vr_dserrger := vr_dserrger || chr(10) || ' --> erro na exclusao do arquivo --> '||vr_des_erro;
                -- O comando shell executou com erro, gerar log
                vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> erro na exclusao do arquivo --> '||vr_des_erro;
              END IF;
            END IF;
          END IF;

          -- Por fim, irá atualizar o registro na tabela com a data final e
          -- o texto acumulativo de erro, que pode estar vazio caso não tenha
          -- ocorrido nenhum imprevisto no processo
          BEGIN
            UPDATE crapslr
               SET flgerado = 'S'
                  ,dtfimger = sysdate
                  ,dserrger = vr_dserrger
             WHERE rowid = rw_crapslr.rowid;
          END;

          -- Enviar o LOG da geração do relatório
          pc_gera_log_relato(rw_crapslr.cdcooper,vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> Término da geração --> Seq '||rw_crapslr.nrseqsol||'.');
          -- Se estiver rodando no processo automatizado
          IF pr_nrseqsol IS NULL THEN
            -- Commitar o registro processado
            COMMIT;
          ELSE
            -- Retornar se houver algum erro
            pr_des_erro := vr_dserrger;
            -- Sair do laço pois é necessário apenas uma interação
            EXIT;
          END IF;
        ELSE
          -- Fechar o cursor pq não encontrou nada
          CLOSE cr_crapslr;
          -- Sair do processo pois não há mais registros
          EXIT;
        END IF;
        -- Sair do processo por fila em caso de ter processado a quantidade máxima por JOB
        IF vr_qtrelproc >= vr_qtreljob THEN
          EXIT;
        END IF;
      END LOOP;
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
        CECRED.pc_internal_exception;
        -- Gerar Log
        pc_gera_log_relato(0,to_char(sysdate,'hh24:mi:ss')||' --> Erro não tratado ao processar relatórios pendentes --> '|| sqlerrm);
    END;
  END pc_process_relato_penden;

  -- Subrotina simples para corrigir extensões informadas erroneamente
  FUNCTION fn_replace_extensao(pr_dsext IN VARCHAR2) RETURN VARCHAR2 IS
    /*..............................................................................
       Programa: fn_replace_extensao
       Autor   : 
       Data    :                       Ultima atualizacao: 18/10/2017

       Dados referentes ao programa:

       Objetivo  : Corrige extensões informadas erroneamente

       Alteracoes: 18/10/2017 - Incluído pc_set_modulo com novo padrão
                                (Ana - Envolti - Chamado 776896)
    ..............................................................................*/
    vr_dsext crapslr.dsextcop%TYPE;
  BEGIN
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => 'GENE0002.fn_replace_extensao');
    -- converter para minúsculo
    vr_dsext := lower(pr_dsext);
    -- remover espaços
    vr_dsext := trim(vr_dsext);
    -- remover . se houver no início ou no fim
    vr_dsext := ltrim(rtrim(vr_dsext,'.'),'.');
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    -- retornar valor ajustado
    RETURN vr_dsext;
  END;

  /* Rotina para solicitar geração de relatorio em PDF a partir de um XML de dados */
  PROCEDURE pc_solicita_relato(pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Cooperativa conectada
                              ,pr_cdprogra  IN crapprg.cdprogra%TYPE    --> Programa chamador
                              ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE    --> Data do movimento atual
                              ,pr_dsxml     IN OUT NOCOPY CLOB          --> Arquivo XML de dados
                              ,pr_dsxmlnode IN VARCHAR2                 --> Nó do XML para iteração
                              ,pr_dsjasper  IN VARCHAR2                 --> Arquivo de layout do iReport
                              ,pr_dsparams  IN VARCHAR2                 --> Array de parametros diversos
                              ,pr_dsarqsaid IN VARCHAR2                 --> Path/Nome do arquivo PDF gerado
                              ,pr_flg_gerar IN VARCHAR2 DEFAULT 'N'     --> Gerar o arquivo na hora
                              ,pr_qtcoluna  IN NUMBER                   --> Qtd colunas do relatório (80,132,234)
                              ,pr_sqcabrel  IN NUMBER DEFAULT 1         --> Sequencia do relatorio (cabrel 1..5)
                              ,pr_cdrelato  IN NUMBER DEFAULT NULL      --> Código fixo para o relatório (nao busca pelo sqcabrel)
                              ,pr_cdfilrel  IN VARCHAR2 DEFAULT NULL    --> Fila para o relatório
                              ,pr_nrseqpri  IN NUMBER DEFAULT NULL      --> Prioridade para o relatório (0..5)
                              ,pr_flg_impri IN VARCHAR2 DEFAULT 'N'     --> Chamar a impressão (Imprim.p)
                              ,pr_nmformul  IN VARCHAR2 DEFAULT NULL    --> Nome do formulário para impressão
                              ,pr_nrcopias  IN NUMBER   DEFAULT NULL    --> Número de cópias para impressão
                              ,pr_dspathcop IN VARCHAR2 DEFAULT NULL    --> Lista sep. por ';' de diretórios a copiar o relatório
                              ,pr_dsextcop  IN VARCHAR2 DEFAULT NULL    --> Extensão para cópia do relatório aos diretórios
                              ,pr_fldoscop  IN VARCHAR2 DEFAULT 'N'     --> Flag para converter o arquivo gerado em DOS antes da cópia
                              ,pr_dscmaxcop IN VARCHAR2 DEFAULT NULL    --> Comando auxiliar para o comando ux2dos na cópia de diretório
                              ,pr_dsmailcop IN VARCHAR2 DEFAULT NULL    --> Lista sep. por ';' de emails para envio do relatório
                              ,pr_dsassmail IN VARCHAR2 DEFAULT NULL    --> Assunto do e-mail que enviará o relatório
                              ,pr_dscormail IN VARCHAR2 DEFAULT NULL    --> HTML corpo do email que enviará o relatório
                              ,pr_dsextmail IN VARCHAR2 DEFAULT NULL    --> Extensão para envio do relatório
                              ,pr_fldosmail IN VARCHAR2 DEFAULT 'N'     --> Flag para converter o arquivo gerado em DOS antes do e-mail
                              ,pr_dscmaxmail IN VARCHAR2 DEFAULT NULL    --> Comando auxiliar para o comando ux2dos no envio de e-mail
                              ,pr_flgremarq IN VARCHAR2 DEFAULT 'N'     --> Flag para remover o arquivo após cópia/email
                              ,pr_flsemqueb IN VARCHAR2 DEFAULT 'N'     --> Flag S/N para não gerar quebra no relatório
                              ,pr_flappend  IN VARCHAR2 DEFAULT 'N'     --> Indica que a solicitação irá incrementar o arquivo
                              ,pr_parser    IN VARCHAR2 DEFAULT 'D'     --> Seleciona o tipo do parser. "D" para VTD e "R" para Jasper padrão
                              ,pr_nrvergrl  IN crapslr.nrvergrl%TYPE DEFAULT 0 --> Numero da versão da função de geração de relatorio
                              ,pr_des_erro  OUT VARCHAR2) IS            --> Saída com erro
  BEGIN
    /* ..........................................................................
    --
    --  Programa : pc_solicita_relato
    --  Sistema  : Rotinas genéricas
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Dezembro/2012.                   Ultima atualizacao: 21/12/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Esta rotina recebe os parâmetros necessarios para a geração de relatório
    --               e grava as informaçoes na tabela CRAPSLR para processamento posterior.
    --   Obs: Em caso de solicitação para geração na hora, o mesmo é efetuado já neste momento.
    --
    --   Alteracoes: 14/06/2013 - Incluso flag para remover o arquivo original após
    --                            copiar ou enviar e-mail (Marcos-Supero)
    --               11/09/2013 - Incluído parâmetro para converter o arquivo para envio de
    --                            email em PDF (Marcos-Supero)
    --               01/10/2013 - Não parar o processo durante a solicitação, mas sim gravar
    --                            a crapslr com erro, e gerar no log o erro (Marcos-Supero)
    --               28/10/2013 - Gravar a nova flag para saber se a solicitação está no batch
    --                            ou não atraves da busca na crapdat.inproces (Marcos-Supero)
    --               07/11/2013 - Inclusão da validação do Jasper na solicitação, antes estava
    --                            na geração (Marcos-Supero)
    --               18/11/2013 - Ajustar consistencia de remoção do arquivo, pois a mesma pode
    --                            ser solicitada inclusive se for solicitado somente a imprim.p,
    --                            antes só era feita na copia/email do relatório (Marcos-Supero)
    --               08/01/2014 - Alteração da rotina para deixar dinâmico qual a extensão desejada
    --                            para cópia ou envio de e-mail do relatórios pós-processo (Marcos-Supero)
    --               12/03/2014 - Preparar a execução para converter o arquivo de unix para dos (Marcos-Supero)
    --               22/09/2015 - Adicionar validação para quando o relatorio for solicitado durante o processo
    --                            batch, o erro seja escrito no proc_batch, caso contrario no proc_message
    --                            (Douglas - Chamado 306525)
    --               02/08/2016 - Inclusao do paramtro pr_nrvergrl, para permitir informar em qual versao da rotina
    --                            java de geração de relatorio deve ser gerado.
    --                            PRJ314 - INDEXAÇÃO CENTRALIZADA (Odirlei-AMcom)
    --               22/06/2017 - Tratamento de erros 
    --                          - setado modulo
    --                          - Chamado 660322 - Belli - Envolti
    --               17/10/2017 - Retirado pc_set_modulo
    --                            (Ana - Envolti - Chamado 776896)
    --               18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                            (Ana - Envolti - Chamado 776896)
    --
    --               21/12/2017 - Melhorado consulta na crapprg com UPPER (Tiago #812349)
    -- ............................................................................. */
    DECLARE
      -- Busca do indicador do processo no calendário
      CURSOR cr_crapdat IS
        SELECT inproces
          FROM crapdat
         WHERE cdcooper = pr_cdcooper;
      vr_inproces crapdat.inproces%TYPE;
      vr_flgbatch crapslr.flgbatch%TYPE := 0;
      -- Busca dos detalhes do programa em execução
      CURSOR cr_crapprg (pr_cdcooper IN crapcop.cdcooper%type
                        ,pr_cdprogra IN crapprg.cdprogra%type
                        ,pr_sqcabrel IN INTEGER) IS
        SELECT prg.nrsolici
              ,DECODE(pr_sqcabrel,1,prg.cdrelato##1
                                 ,2,prg.cdrelato##2
                                 ,3,prg.cdrelato##3
                                 ,4,prg.cdrelato##4
                                 ,5,prg.cdrelato##5
                                   ,prg.cdrelato##1) cdrelato  --> Retornar o codigo cfme o solicitavdo (1,2,3,4,5)
          FROM crapprg prg
         WHERE prg.cdcooper = pr_cdcooper
           AND UPPER(prg.cdprogra) = UPPER(pr_cdprogra);
      rw_crapprg cr_crapprg%ROWTYPE;
      -- Busca do cadastro de relatórios
      CURSOR cr_craprel(pr_cdrelato craprel.cdrelato%TYPE) IS
        SELECT rel.cdfilrel
              ,rel.nrseqpri
          FROM craprel rel
         WHERE rel.cdcooper = pr_cdcooper
           AND rel.cdrelato = pr_cdrelato; --> Código relatório vinculado ao módulo
      rw_craprel cr_craprel%ROWTYPE;
      -- Busca da fila de emissão
      CURSOR cr_crapfil IS
        SELECT flgativa
          FROM crapfil
         WHERE cdfilrel = rw_craprel.cdfilrel;
      vr_flgativa crapfil.flgativa%TYPE;
      -- Sequencia gravada na tabela de relatórios
      vr_nrseqsol crapslr.nrseqsol%TYPE;
      -- Guardar flag de geração e erros para o caso de
      -- encontrarmos problemas antes de solicitar
      vr_flgerado crapslr.flgerado%TYPE := 'N'; --> Default é ainda não gerado
      vr_dserrger crapslr.dserrger%TYPE;

      -- Guardar extensões pada copia/email
      vr_dsextmail crapslr.dsextmail%TYPE;
      vr_dsextcop  crapslr.dsextcop%TYPE;

      -- Tratamento de erros - 22/06/2017 - Chamado 660322
      vr_exc_saida        EXCEPTION;
     
    BEGIN
      -- Criação de bloco para tratar todos os possíveis problemas na solicitação
      
	    -- Incluir nome do módulo logado - Chamado 660322 20/06/2017      
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => 'GENE0002.pc_solicita_relato');
      
      BEGIN
        -- Busca do indicador do processo no calendário
        OPEN cr_crapdat;
        FETCH cr_crapdat
         INTO vr_inproces;
        CLOSE cr_crapdat;
        -- Inproces = 1 eh Online, maior que isso é Batch
        IF vr_inproces = 1 THEN
          -- Online
          vr_flgbatch := 0;
        ELSE
          -- Batch
          vr_flgbatch := 1;
        END IF;
        -- Busca dos detalhes do programa em execução
        OPEN cr_crapprg (pr_cdcooper => pr_cdcooper
                        ,pr_cdprogra => pr_cdprogra
                        ,pr_sqcabrel => pr_sqcabrel);
        FETCH cr_crapprg INTO rw_crapprg;
        -- Caso o programa não exista
        IF cr_crapprg%NOTFOUND THEN
          -- Fechar o cursor pois teremos um raise
          CLOSE cr_crapprg;
          vr_dserrger := 'Programa '||pr_cdprogra||' inexistente na tabela CRAPPRG';
          RAISE vr_exc_erro;
        ELSE
          -- Fechar o cursor para continuar o processo
          CLOSE cr_crapprg;
        END IF;
        -- Verificando a quantidade de colunas
        IF pr_qtcoluna NOT IN(80,132,234) THEN
          -- Gerar erro
          vr_dserrger := 'Solicitação com número de colunas inválido: '||pr_qtcoluna;
          RAISE vr_exc_erro;
        END IF;
        -- Se foi enviado um código de programa ao invés do sqcabrel
        IF pr_cdrelato IS NOT NULL THEN
          -- Substituir o código de relatório encontrado através
          -- do sqcabrel com este código enviado
          rw_crapprg.cdrelato := pr_cdrelato;
        END IF;
        -- Testar se o módulo possui relatório vinculado
        IF NVL(rw_crapprg.cdrelato,0) = 0 THEN
          -- Gerar erro
          vr_dserrger := 'Programa '||pr_cdprogra||' não possui o código do relatório vinculado.';
          RAISE vr_exc_erro;
        END IF;
        -- Busca do cadastro de relatórios as informações do relatório
        OPEN cr_craprel(pr_cdrelato => rw_crapprg.cdrelato);
        FETCH cr_craprel
         INTO rw_craprel;
        -- Fechar o cursor para continuar o processo
        CLOSE cr_craprel;
        -- Se foi enviado uma fila específica
        IF trim(pr_cdfilrel) IS NOT NULL THEN
          -- Utilizá-la, ao invés da encontrada no cadastro do relatório
          rw_craprel.cdfilrel := pr_cdfilrel;
        END IF;
        -- Se foi enviada uma prioridade específica
        IF trim(pr_nrseqpri) IS NOT NULL THEN
          -- Utilizá-la, ao invés da cadastrada no relatório
          rw_craprel.nrseqpri := pr_nrseqpri;
        END IF;
        -- Por fim, em caso de não ter encontrado fila e prioridade
        -- no cadastro do relatório ou pela solicitação do relatório
        -- então utilizamos o NVL abaixo e buscamos a parametrização
        -- do sistema em COD_FILA_REL_PADRAO e NUM_PRIOR_REL_PADRAO
        rw_craprel.cdfilrel := NVL(rw_craprel.cdfilrel,gene0001.fn_param_sistema('CRED',pr_cdcooper,'COD_FILA_RELATO'));
        rw_craprel.nrseqpri := NVL(rw_craprel.nrseqpri,gene0001.fn_param_sistema('CRED',pr_cdcooper,'NUM_PRIOR_RELATO'));
        -- Somente continuar se a fila enviada estiver ativa
        OPEN cr_crapfil;
        FETCH cr_crapfil
         INTO vr_flgativa;
        -- Se não encontrar ou a fila estiver inativa
        IF cr_crapfil%NOTFOUND OR NVL(vr_flgativa,'N') = 'N' THEN
          -- Fechar o cursor
          CLOSE cr_crapfil;
          -- Gerar erro
          vr_dserrger := 'Fila '||rw_craprel.cdfilrel||' inexistente ou inativa';
          RAISE vr_exc_erro;
        ELSE
          -- Fechar o cursor e continuar
          CLOSE cr_crapfil;
        END IF;
        -- Verificar a prioridade informada
        IF rw_craprel.nrseqpri NOT IN(0,1,2,3,4,5) THEN
          -- Gerar erro
          vr_dserrger := 'Prioridade '||rw_craprel.nrseqpri||' incorretada. Informe de 0 a 5.';
          RAISE vr_exc_erro;
        END IF;
        -- Se foi solicitada a remoção do arquivo original
        IF pr_flgremarq = 'S' THEN
          -- Somente continuar se foi indicado a impressão ou algum email ou diretório para cópia do arquivo
          IF trim(pr_dspathcop) IS NULL AND trim(pr_dsmailcop) IS NULL AND pr_flg_impri = 'N' THEN
            vr_dserrger := 'Voce nao pode remover o arquivo se não há diretório / email para envio, ou impressao do relatorio.';
            RAISE vr_exc_erro;
          END IF;
        END IF;
        -- Testa a existencia do arquivo de layout (JASPER) enviado.
        IF NOT gene0001.fn_exis_arquivo(nvl(gene0001.fn_param_sistema('CRED',pr_cdcooper,'ROOT_IREPORT'), '/usr/coop/ireport/') || pr_dsjasper) THEN
          vr_dserrger := 'Não foi localizado o arquivo "' || nvl(gene0001.fn_param_sistema('CRED',pr_cdcooper,'ROOT_IREPORT'), '/usr/coop/ireport/') || pr_dsjasper || '"';
          RAISE vr_exc_erro;
        END IF;
      EXCEPTION
        WHEN vr_exc_erro THEN
          -- Incluir mensagem padrão inicial
          vr_dserrger := 'Relatorio '||pr_dsarqsaid||' nao sera processado. Motivo: '|| vr_dserrger;
          -- E também setar a flag de gerado como 'S' para que o
          -- mecanismo não tente gerá-lo já que encontrarmos erro
          vr_flgerado := 'S';
      END;
      -- Guardar extensões pada copia/email
      vr_dsextmail := fn_replace_extensao(pr_dsextmail);
      vr_dsextcop  := fn_replace_extensao(pr_dsextcop);
      -- Novo bloco para tratar o insert
      BEGIN
        -- Por fim, cria o registro guardando seu Rowid
        INSERT INTO crapslr(dtsolici
                           ,cdcooper
                           ,cdprogra
                           ,dtmvtolt
                           ,cdfilrel
                           ,nrseqpri
                           ,dsosuser
                           ,dsxmldad
                           ,dsxmlnod
                           ,dsjasper
                           ,dsparams
                           ,dsarqsai
                           ,qtcoluna
                           ,sqcabrel
                           ,cdrelato
                           ,flimprim
                           ,nmformul
                           ,nrcopias
                           ,flgerado
                           ,dserrger
                           ,dspathcop
                           ,dsextcop
                           ,fldoscop
                           ,dscmaxcop
                           ,dsmailcop
                           ,dsassmail
                           ,dscormail
                           ,dsextmail
                           ,fldosmail
                           ,dscmaxmail
                           ,flsemque
                           ,flremarq
                           ,cdparser
                           ,flgbatch
                           ,flappend
                           ,nrvergrl)
                     VALUES(SYSDATE
                           ,pr_cdcooper
                           ,pr_cdprogra
                           ,pr_dtmvtolt
                           ,rw_craprel.cdfilrel
                           ,rw_craprel.nrseqpri
                           ,gene0001.fn_osuser
                           ,pr_dsxml
                           ,pr_dsxmlnode
                           ,pr_dsjasper
                           ,pr_dsparams
                           ,pr_dsarqsaid
                           ,pr_qtcoluna
                           ,pr_sqcabrel
                           ,rw_crapprg.cdrelato
                           ,pr_flg_impri
                           ,pr_nmformul
                           ,pr_nrcopias
                           ,vr_flgerado --> Cfme testes acima
                           ,vr_dserrger --> Cfme testes acima
                           ,pr_dspathcop
                           ,vr_dsextcop
                           ,pr_fldoscop
                           ,pr_dscmaxcop
                           ,pr_dsmailcop
                           ,pr_dsassmail
                           ,pr_dscormail
                           ,vr_dsextmail
                           ,pr_fldosmail
                           ,pr_dscmaxmail
                           ,pr_flsemqueb
                           ,pr_flgremarq
                           ,pr_parser
                           ,vr_flgbatch
                           ,pr_flappend
                           ,pr_nrvergrl)
                  RETURNING nrseqsol INTO vr_nrseqsol;
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
          vr_dserrger := 'Solicitação do Relatorio '||pr_dsarqsaid||' com erro ao inserir. Motivo: '|| sqlerrm;
      END;
      -- Se foi solicitado o envio na hora e não houve erro na solicitação
      IF pr_flg_gerar = 'S' AND vr_dserrger IS NULL THEN
        -- Chamar o processamento de solicitações pendentes passando-a
        pc_process_relato_penden(pr_nrseqsol => vr_nrseqsol
                                ,pr_des_erro => vr_dserrger);
                             
       -- Em caso de erro vai retornar a mensagem - 22/06/2017 - Chamado 660322 - Envolti  
              
       if pr_cdprogra = 'BCAIXA' then
         if vr_dserrger is not null then
           RAISE vr_exc_saida; 
         end if;
       end if;
       --
        
      END IF;

      -- Se não saimos pela exceção acima e houve erro
      IF vr_dserrger IS NOT NULL THEN
        -- Validar se o relatorio foi solicitado no processo batch
        IF vr_flgbatch = 1 THEN
          -- Enviar ao LOG Batch
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 --> Erro tratato
                                    ,pr_des_log      => to_char(sysdate, 'hh24:mi:ss') ||
                                                                ' - ' || pr_cdprogra || ' --> ' ||
                                                                'ERRO : ' || 
                                                                '2 - GENE0002 pc_solicita_relato ' || 
                                                                vr_dserrger
                                    ,pr_nmarqlog     => NULL
                                    ,pr_cdprograma   => pr_cdprogra);
        ELSE
                             
          -- Em caso diferente da tela bcaixa continua gerando registro de critica 
          -- 22/06/2017 - Chamado 660322 - Envolti                  
          if pr_cdprogra <> 'BCAIXA' then
            
          -- Escrever No LOG proc_message
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 --> Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                      ,pr_des_log      => to_char(sysdate, 'hh24:mi:ss') ||
                                                                  ' - ' || pr_cdprogra  || ' --> ' ||
                                                                  'ERRO : ' || 
                                                                  '3 - GENE0002 pc_solicita_relato ' || 
                                                                  vr_dserrger
                                      ,pr_cdprograma   => pr_cdprogra);
          End if;
        END IF;
      END IF;
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    EXCEPTION
      -- Rotina de geracao de erro - Chamado 660322 - Envolti
      WHEN vr_exc_saida THEN
        
        pr_des_erro := vr_dserrger; 
        
      WHEN OTHERS THEN -- Gerar log de erro
        -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
        CECRED.pc_internal_exception;
        -- Retornar o erro contido na sqlerrm
        pr_des_erro := 'GENE0002.pc_solicita_relato --> ' || sqlerrm;
    END;
  END pc_solicita_relato;

  /* Rotina para solicitar geração de arquivo lst a partir de um XML de dados */
  PROCEDURE pc_solicita_relato_arquivo(pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Cooperativa conectada
                                      ,pr_cdprogra  IN crapprg.cdprogra%TYPE    --> Programa chamador
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE    --> Data do movimento atual
                                      ,pr_dsxml     IN OUT NOCOPY CLOB          --> Arquivo XML de dados
                                      ,pr_dsarqsaid IN VARCHAR2                 --> Path/Nome do arquivo PDF gerado
                                      ,pr_cdrelato  IN NUMBER DEFAULT NULL      --> Código fixo para o relatório
                                      ,pr_flg_impri IN VARCHAR2 DEFAULT 'N'     --> Chamar a impressão (Imprim.p)
                                      ,pr_flg_gerar IN VARCHAR2 DEFAULT 'N'     --> Gerar o arquivo na hora
                                      ,pr_nmformul  IN VARCHAR2 DEFAULT NULL    --> Nome do formulário para impressão
                                      ,pr_nrcopias  IN NUMBER   DEFAULT NULL    --> Número de cópias para impressão
                                      ,pr_dspathcop IN VARCHAR2 DEFAULT NULL    --> Lista sep. por ';' de diretórios a copiar o arquivo
                                      ,pr_fldoscop  IN VARCHAR2 DEFAULT 'N'     --> Flag para converter o arquivo gerado em DOS antes da cópia
                                      ,pr_dscmaxcop IN VARCHAR2 DEFAULT NULL    --> Comando auxiliar para o comando ux2dos na cópia de diretório
                                      ,pr_dsextcop  IN VARCHAR2 DEFAULT NULL    --> Extensão para cópia do relatório aos diretórios
                                      ,pr_dsmailcop IN VARCHAR2 DEFAULT NULL    --> Lista sep. por ';' de emails para envio do arquivo
                                      ,pr_dsassmail IN VARCHAR2 DEFAULT NULL    --> Assunto do e-mail que enviará o arquivo
                                      ,pr_dscormail IN VARCHAR2 DEFAULT NULL    --> HTML corpo do email que enviará o arquivo
                                      ,pr_dsextmail IN VARCHAR2 DEFAULT NULL    --> Extensão para envio do relatório
                                      ,pr_fldosmail IN VARCHAR2 DEFAULT 'N'     --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                      ,pr_dscmaxmail IN VARCHAR2 DEFAULT NULL    --> Comando auxiliar para o comando ux2dos no envio de e-mail
                                      ,pr_flgremarq IN VARCHAR2 DEFAULT 'N'     --> Flag para remover o arquivo após cópia/email
                                      ,pr_flappend  IN VARCHAR2 DEFAULT 'N'     --> Indica que a solicitação irá incrementar o arquivo
                                      ,pr_des_erro  OUT VARCHAR2) IS            --> Saída com erro
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_solicita_relato_arquivo
    --  Sistema  : Rotinas genéricas
    --  Sigla    : GENE
    --  Autor    : Alisson C. Berrido - Amcom
    --  Data     : Abril/2013.                   Ultima atualizacao: 21/12/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Esta rotina recebe os parâmetros necessarios para a geração do arquivo
    --               e grava as informaçoes na tabela CRAPSLR para processamento posterior.
    --   Obs: Em caso de solicitação para geração na hora, o mesmo é efetuado já neste momento.
    --
    --   Alteracoes: 14/06/2013 - Incluso flag para remover o arquivo original após
    --                            copiar ou enviar e-mail
    --               01/10/2013 - Não parar o processo durante a solicitação, mas sim gravar
    --                            a crapslr com erro, e gerar no log o erro (Marcos-Supero)
    --               28/10/2013 - Gravar a nova flag para saber se a solicitação está no batch
    --                            ou não atraves da busca na crapdat.inproces (Marcos-Supero)
    --               18/11/2013 - Ajustar consistencia de remoção do arquivo, pois a mesma pode
    --                            ser solicitada inclusive se for solicitado somente a imprim.p,
    --                            antes só era feita na copia/email do relatório (Marcos-Supero)
    --               09/01/2013 - Alteração da rotina para deixar dinâmico qual a extensão desejada
    --                            para cópia ou envio de e-mail do relatórios pós-processo (Marcos-Supero)
    --               12/03/2014 - Preparar a execução para converter o arquivo de unix para dos (Marcos-Supero)
    --               31/08/2015 - Inclusao do parametro flappend. (Jaison/Marcos-Supero)
    --               17/10/2017 - Retirado pc_set_modulo
    --                            (Ana - Envolti - Chamado 776896)
    --               18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                            (Ana - Envolti - Chamado 776896)
    --
    --               21/12/2017 - Melhorado consulta na crapprg com UPPER (Tiago #812349)
    -- .............................................................................
    DECLARE
      -- Busca do indicador do processo no calendário
      CURSOR cr_crapdat IS
        SELECT inproces
          FROM crapdat
         WHERE cdcooper = pr_cdcooper;
      vr_inproces crapdat.inproces%TYPE;
      vr_flgbatch crapslr.flgbatch%TYPE := 0;
      -- Busda dos detalhes do programa em execução
      CURSOR cr_crapprg IS
        SELECT prg.nrsolici
          FROM crapprg prg
         WHERE prg.cdcooper = pr_cdcooper
           AND UPPER(prg.cdprogra) = UPPER(pr_cdprogra);
      rw_crapprg cr_crapprg%ROWTYPE;
      -- Busca do cadastro de relatórios
      CURSOR cr_craprel(pr_cdrelato craprel.cdrelato%TYPE) IS
        SELECT rel.cdfilrel
              ,rel.nrseqpri
          FROM craprel rel
         WHERE rel.cdcooper = pr_cdcooper
           AND rel.cdrelato = pr_cdrelato; --> Código relatório vinculado ao módulo
      rw_craprel cr_craprel%ROWTYPE;
      -- Busca da fila de emissão
      CURSOR cr_crapfil IS
        SELECT flgativa
          FROM crapfil
         WHERE cdfilrel = rw_craprel.cdfilrel;
      vr_flgativa crapfil.flgativa%TYPE;
      -- Sequencia gravada na tabela de relatórios
      vr_nrseqsol crapslr.nrseqsol%TYPE;
      -- Guardar flag de geração e erros para o caso de
      -- encontrarmos problemas antes de solicitar
      vr_flgerado crapslr.flgerado%TYPE := 'N'; --> Default é ainda não gerado
      vr_dserrger crapslr.dserrger%TYPE;
      -- Guardar extensões pada copia/email
      vr_dsextmail crapslr.dsextmail%TYPE;
      vr_dsextcop  crapslr.dsextcop%TYPE;
    BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_solicita_relato_arquivo');
      -- Criação de bloco para tratar todos os possíveis problemas na solicitação
      BEGIN
        -- Busca do indicador do processo no calendário
        OPEN cr_crapdat;
        FETCH cr_crapdat
         INTO vr_inproces;
        CLOSE cr_crapdat;
        -- Inproces = 1 eh Online, maior que isso é Batch
        IF vr_inproces = 1 THEN
          -- Online
          vr_flgbatch := 0;
        ELSE
          -- Batch
          vr_flgbatch := 1;
        END IF;
        -- Busca dos detalhes do programa em execução
        OPEN cr_crapprg;
        FETCH cr_crapprg
         INTO rw_crapprg;
        -- Caso o programa não exista
        IF cr_crapprg%NOTFOUND THEN
          -- Fechar o cursor pois teremos um raise
          CLOSE cr_crapprg;
          vr_dserrger := 'Programa '||pr_cdprogra||' inexistente na tabela CRAPPRG';
          RAISE vr_exc_erro;
        ELSE
          -- Fechar o cursor para continuar o processo
          CLOSE cr_crapprg;
        END IF;
        -- Se foi enviado um código de relatório
        IF pr_cdrelato IS NOT NULL THEN
          -- Busca do cadastro de relatórios as informações do relatório
          OPEN cr_craprel(pr_cdrelato => pr_cdrelato);
          FETCH cr_craprel
           INTO rw_craprel;
          -- Fechar o cursor para continuar o processo
          CLOSE cr_craprel;
        END IF;
        -- Por fim, em caso de não ter encontrado fila e prioridade
        -- no cadastro do relatório ou pela solicitação do relatório
        -- então utilizamos o NVL abaixo e buscamos a parametrização
        -- do sistema em COD_FILA_REL_PADRAO e NUM_PRIOR_REL_PADRAO
        rw_craprel.cdfilrel := NVL(rw_craprel.cdfilrel,gene0001.fn_param_sistema('CRED',pr_cdcooper,'COD_FILA_RELATO'));
        rw_craprel.nrseqpri := NVL(rw_craprel.nrseqpri,gene0001.fn_param_sistema('CRED',pr_cdcooper,'NUM_PRIOR_RELATO'));
        -- Somente continuar se a fila enviada estiver ativa
        OPEN cr_crapfil;
        FETCH cr_crapfil
         INTO vr_flgativa;
        -- Se não encontrar ou a fila estiver inativa
        IF cr_crapfil%NOTFOUND OR NVL(vr_flgativa,'N') = 'N' THEN
          -- Fechar o cursor
          CLOSE cr_crapfil;
          -- Gerar erro
          vr_dserrger := 'Fila '||rw_craprel.cdfilrel||' inexistente ou inativa';
          RAISE vr_exc_erro;
        ELSE
          -- Fechar o cursor e continuar
          CLOSE cr_crapfil;
        END IF;
        -- Verificar a prioridade informada
        IF rw_craprel.nrseqpri NOT IN(0,1,2,3,4,5) THEN
          -- Gerar erro
          vr_dserrger := 'Prioridade '||rw_craprel.nrseqpri||' incorretada. Informe de 0 a 5.';
          RAISE vr_exc_erro;
        END IF;
        -- Se foi solicitada a remoção do arquivo original
        IF pr_flgremarq = 'S' THEN
          -- Somente continuar se foi indicado a impressão ou algum email ou diretório para cópia do arquivo
          IF pr_dspathcop IS NULL AND pr_dsmailcop IS NULL AND pr_flg_impri = 'N' THEN
            vr_dserrger := 'Voce nao pode remover o arquivo se não há diretório / email para envio, ou impressao do relatorio.';
            RAISE vr_exc_erro;
          END IF;
        END IF;
      EXCEPTION
        WHEN vr_exc_erro THEN
          -- Incluir mensagem padrão inicial
          vr_dserrger := 'Relatorio '||pr_dsarqsaid||' nao sera processado. Motivo: '|| vr_dserrger;
          -- E também setar a flag de gerado como 'S' para que o
          -- mecanismo não tente gerá-lo já que encontrarmos erro
          vr_flgerado := 'S';
      END;
      -- Guardar extensões pada copia/email
      vr_dsextmail := fn_replace_extensao(pr_dsextmail);
      vr_dsextcop  := fn_replace_extensao(pr_dsextcop);
      -- Novo bloco para tratar o insert
      BEGIN
        -- Por fim, cria o registro guardando seu Rowid
        INSERT INTO crapslr(dtsolici
                           ,cdcooper
                           ,cdprogra
                           ,dtmvtolt
                           ,cdfilrel
                           ,nrseqpri
                           ,dsosuser
                           ,dsxmldad
                           ,dsxmlnod
                           ,dsjasper
                           ,dsparams
                           ,dsarqsai
                           ,qtcoluna
                           ,sqcabrel
                           ,cdrelato
                           ,flimprim
                           ,nmformul
                           ,nrcopias
                           ,flgerado
                           ,dserrger
                           ,dspathcop
                           ,dsextcop
                           ,fldoscop
                           ,dscmaxcop
                           ,dsmailcop
                           ,dsassmail
                           ,dscormail
                           ,dsextmail
                           ,fldosmail
                           ,dscmaxmail
                           ,flsemque
                           ,flarquiv
                           ,flremarq
                           ,flgbatch
                           ,flappend)
                     VALUES(SYSDATE
                           ,pr_cdcooper
                           ,pr_cdprogra
                           ,pr_dtmvtolt
                           ,rw_craprel.cdfilrel
                           ,rw_craprel.nrseqpri
                           ,gene0001.fn_osuser
                           ,pr_dsxml
                           ,NULL
                           ,NULL
                           ,NULL
                           ,pr_dsarqsaid
                           ,NULL
                           ,NULL
                           ,pr_cdrelato
                           ,pr_flg_impri
                           ,pr_nmformul
                           ,pr_nrcopias
                           ,vr_flgerado --> Cfme testes acima
                           ,vr_dserrger --> Cfme testes acima
                           ,pr_dspathcop
                           ,vr_dsextcop
                           ,pr_fldoscop
                           ,pr_dscmaxcop
                           ,pr_dsmailcop
                           ,pr_dsassmail
                           ,pr_dscormail
                           ,vr_dsextmail
                           ,pr_fldosmail
                           ,pr_dscmaxmail
                           ,'N'
                           ,'S'
                           ,pr_flgremarq
                           ,vr_flgbatch
                           ,pr_flappend)
                  RETURNING nrseqsol INTO vr_nrseqsol;
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
          vr_dserrger := 'Solicitação do Relatorio '||pr_dsarqsaid||' com erro ao inserir. Motivo: '|| sqlerrm;
      END;
      -- Se foi solicitado o envio na hora e não houve erro na solicitação
      IF pr_flg_gerar = 'S' AND vr_dserrger IS NULL THEN
        -- Chamar o processamento de solicitações pendentes passando-a
        pc_process_relato_penden(pr_nrseqsol => vr_nrseqsol
                                ,pr_des_erro => vr_dserrger);
      END IF;
      -- Se não saimos pela exceção acima e houve erro
      IF vr_dserrger IS NOT NULL THEN
        -- Enviar ao LOG Batch
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 --> Erro tratato
                                  ,pr_des_log      => to_char(sysdate, 'hh24:mi:ss') ||
                                                              ' - '  || pr_cdprogra || ' --> ' || 
                                                              'ERRO: ' || 
                                                              '1 - GENE0002 pc_solicita_relato_arquivo ' || 
                                                              vr_dserrger
                                  ,pr_nmarqlog     => NULL
                                  ,pr_cdprograma   => pr_cdprogra);
      END IF;
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    EXCEPTION
      WHEN OTHERS THEN -- Gerar log de erro
        -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
        -- Retornar o erro contido na sqlerrm
        pr_des_erro := 'GENE0002.pc_solicita_relato --> ' || sqlerrm;
    END;
  END pc_solicita_relato_arquivo;

  /* Procedimento que verifica possíveis erros no processo de relatórios e alerta os responsáveis */
  PROCEDURE pc_aviso_erros_procrel IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_aviso_erros_procrel
    --  Sistema  : Rotinas genéricas
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini
    --  Data     : Março/2014.                   Ultima atualizacao: 18/10/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Ser acionado por Job Controlador do Banco
    --
    --   Objetivo  : 1 - Listar todos os relatórios com erro no processo atual
    --               2 - Gerar por e-mail listagem alertando os reponsáveis
    --               3 - Atualizar os relatórios indicando que já houve o alerta
    --
    --   Alteracoes: 17/10/2017 - Retirado pc_set_modulo
    --                            (Ana - Envolti - Chamado 776896)
    --               18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                            (Ana - Envolti - Chamado 776896)
    -- ..........................................................................
    DECLARE
      -- Lista dos relatórios a montar a tabela
      cursor cr_crapslr is
        select slr.cdcooper
              ,slr.nrseqsol
              ,slr.dtsolici
              ,slr.cdprogra
              ,slr.dtmvtolt
              ,slr.cdfilrel
              ,rtrim(lower(slr.dsjasper),'.jasper') dsjasper
              ,slr.dsarqsai
              ,slr.dtiniger
              ,slr.dtfimger
              ,GENE0002.fn_calc_difere_datas(slr.dtiniger,slr.dtfimger) qttmpexe
              ,slr.dserrger
              ,ROW_NUMBER() OVER(PARTITION BY cdcooper
                                     ORDER BY cdcooper) nrseq_coop
              ,COUNT(1) OVER(PARTITION BY cdcooper) conta_coop
          from crapslr slr
        where slr.flgbatch = 1          --> Solicitado no processo
          and slr.dserrger is not null  --> Teve erro
          and slr.flgaviso = 'N'        --> Ainda não avisado
        order by slr.cdcooper
                ,slr.nrseqsol;
      rw_crapslr cr_crapslr%ROWTYPE;
      -- Buscar dscooper
      CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      vr_nmrescop crapcop.nmrescop%TYPE;
      vr_dsdircop varchar2(400);
      -- Guardar parâmetros
      vr_hhalerta      VARCHAR2(5) := gene0001.fn_param_sistema('CRED',0,'RELBATCH_HORA_AVISO');
      vr_dslista_email VARCHAR2(4000);
      -- Guardar HMTL texto
      vr_dshmtl     clob;
      vr_dshmtl_aux varchar2(32600);
      vr_dscorpo    varchar2(3000);
      -- Erro no envio
      vr_dserro varchar2(4000);
    BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_aviso_erros_procrel');
      -- Se tiver sido alcançando o horário para alertas
      IF vr_hhalerta IS NOT NULL AND to_char(sysdate,'hh24:mi') >= vr_hhalerta THEN
        -- Agrupar todos os relatórios por cooperativa
        FOR rw_crapslr IN cr_crapslr LOOP
          -- No primeiro registro da coop
          IF rw_crapslr.nrseq_coop = 1 THEN
            -- BUscar nmrescop
            OPEN cr_crapcop(pr_cdcooper => rw_crapslr.cdcooper);
            FETCH cr_crapcop
             INTO vr_nmrescop;
            CLOSE cr_crapcop;
            -- Buscar o diretório converte
            vr_dsdircop := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                                ,pr_cdcooper => rw_crapslr.cdcooper
                                                ,pr_nmsubdir => 'converte');
            -- Busca a lista dos responsáveis nesta coop
            vr_dslista_email := gene0001.fn_param_sistema('CRED',rw_crapslr.cdcooper,'RELBATCH_EMAIL_AVISO');
            -- Montar o cabeçalho do html e o alerta
            vr_dscorpo := '<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >';
            vr_dscorpo := vr_dscorpo || 'Segue em anexo a listagem dos relatorios que encontraram problema de execucao no processo da <b>'||vr_nmrescop||'</b> ref. <b>'||to_char(rw_crapslr.dtmvtolt,'dd/mm/yy')||'</b>.';
            vr_dscorpo := vr_dscorpo || '</meta>';
            -- Montar o início da tabela (Agora num clob para evitar estouro)
            dbms_lob.createtemporary(vr_dshmtl, TRUE, dbms_lob.CALL);
            dbms_lob.open(vr_dshmtl,dbms_lob.lob_readwrite);
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >');
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<table border="1" style="width:500px; margin: 10px auto; font-family: Tahoma,sans-serif; font-size: 12px; color: #686868;" >');
            -- Montando header
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>NrSeqSol</th>');
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>Hora</th>');
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>Programa</th>');
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>Fila</th>');
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>Jasper</th>');
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>Destino</th>');
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>Início</th>');
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>Fim</th>');
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>Tempo Execução</th>');
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>Erro encontrado</th>');
          END IF;
          -- Para cada registro, montar sua tr
          gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<tr>');
          -- E os detalhes do registro
          gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<td align="right">'||to_char(rw_crapslr.nrseqsol)||'</td>');
          gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<td align="center">'||to_char(rw_crapslr.dtsolici,'hh24:mi:ss')||'</td>');
          gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<td>'||rw_crapslr.cdprogra||'</td>');
          gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<td>'||rw_crapslr.cdfilrel||'</td>');
          gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<td>'||rw_crapslr.dsjasper||'</td>');
          gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<td>'||rw_crapslr.dsarqsai||'</td>');
          gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<td>'||to_char(rw_crapslr.dtiniger,'hh24:mi:ss')||'</td>');
          gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<td>'||to_char(rw_crapslr.dtfimger,'hh24:mi:ss')||'</td>');
          gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<td>'||rw_crapslr.qttmpexe||'</td>');
          gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<td>'||rw_crapslr.dserrger||'</td>');
          -- Encerrar a tr
          gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'</tr>');
          -- No ultimo registro da coop
          IF rw_crapslr.nrseq_coop = rw_crapslr.conta_coop THEN
            -- Enfim, encerrar o texto e o clob
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'',true);
            -- Gerar o arquivo na pasta converte
            pc_clob_para_arquivo(pr_clob     => vr_dshmtl
                                ,pr_caminho  => vr_dsdircop
                                ,pr_arquivo  => 'procrel_'||vr_nmrescop||'_erro.html'
                                ,pr_des_erro => vr_dserro);
            -- Liberando a memória alocada pro CLOB
            dbms_lob.close(vr_dshmtl);
            dbms_lob.freetemporary(vr_dshmtl);
            IF vr_dserro IS NOT NULL THEN
              -- Gerar log
              pc_gera_log_relato(pr_cdcooper => rw_crapslr.cdcooper
                                ,pr_des_log  => to_char(SYSDATE,'hh24:mi:ss')||' Erro ao enviar email de alerta de relatórios com problema --> '||vr_dserro);
            ELSE
              -- Solicitar o e-mail
              gene0003.pc_solicita_email(pr_cdcooper      => rw_crapslr.cdcooper --> Cooperativa conectada
                                        ,pr_cdprogra      => null                --> Programa conectado
                                        ,pr_des_destino   => vr_dslista_email    --> Um ou mais detinatários separados por ';' ou ','
                                        ,pr_des_assunto   => 'Relatórios com erro no processo da '||vr_nmrescop --> Assunto do e-mail
                                        ,pr_des_corpo     => vr_dscorpo          --> Corpo (conteudo) do e-mail
                                        ,pr_des_anexo     => vr_dsdircop||'/procrel_'||vr_nmrescop||'_erro.html'               --> Um ou mais anexos separados por ';
                                        ,pr_flg_remove_anex => 'S'               --> Remover o anexo
                                        ,pr_flg_log_batch => 'N'                 --> Incluir no log a informação do anexo?
                                        ,pr_des_erro      => vr_dserro);
              IF vr_dserro IS NOT NULL THEN
                -- Gerar log
                pc_gera_log_relato(pr_cdcooper => rw_crapslr.cdcooper
                                  ,pr_des_log  => to_char(SYSDATE,'hh24:mi:ss')||' Erro ao enviar email de alerta de relatórios com problema --> '||vr_dserro);

              END IF;
            END IF;
          END IF;
          -- Atualizar o registro como processado
          UPDATE crapslr slr
             SET slr.flgaviso = 'S'
           WHERE slr.nrseqsol = rw_crapslr.nrseqsol;
          -- Efetuar coomit para liberar os registros desta coop e enviar o e-mail
          COMMIT;
        END LOOP;
      END IF;
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
        CECRED.pc_internal_exception;
        -- Gerar log
        pc_gera_log_relato(pr_cdcooper => 1
                          ,pr_des_log  => to_char(SYSDATE,'hh24:mi:ss')||' Erro ao processar avisos de relatórios com problema no processo--> '||sqlerrm);

    END;
  END pc_aviso_erros_procrel;

  /* Procedimento que gerencia as filas de relatórios e controla seus jobs */
  PROCEDURE pc_controle_filas_relato IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_controle_filas_relato
    --  Sistema  : Rotinas genéricas
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini
    --  Data     : Outubro/2013.                   Ultima atualizacao: 18/10/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Ser acionado por Job Controlador do Banco
    --
    --   Objetivo  : 1   - No início do processo, varrer todas as Cooperativas e para cada um:
    --               1.1 - Se estivermos com o processo diario ou noturno executando
    --               1.2 - Se o processo de relatórios não estiver em execução
    --               1.3 - Então criar o arquivo de controle de início da cadeia de relatórios
    --
    --               2   - A rotina irá também varrer todas as filas de geração de relatório (CRAPFIL),
    --                     e para cada fila, efetuar os seguintes controles:
    --
    --               2.1 - Remover solicitações antigas da fila conforma a quantidade
    --                     de dias parametrizado de arquivo dos relatórios.
    --               2.2 - Contar quantos Jobs ativos da fila;
    --               2.3 - Contar quantas solicitações estão pendentes daquela fila;
    --               2.4 - Buscar a quantidade máxima de solicitações por Job e a
    --                     quantidade máxima de jobs ativos para a fila
    --               2.5 - Escalonar quantos jobs forem necessários para processar
    --                     as solicitações pendentes, desde que não escalonemos mais
    --                     jobs do que a quantidade maxima disponível por fila.
    --
    --               2.6 - Chamar rotina que verifica possíveis erros nos relatórios e avisa os responsáveis
    --
    --               3   - E no final do processo, varrer novamente todas as Cooperativas
    --                     e para cada uma encontrada:
    --
    --               3.1 - Se não estivermos com nenum processo rodando
    --               3.2 - Com o processo de geração de relatórios da cadeia ativo
    --               3.3 - Sem nenhum relatório da cadeia pendente de execução
    --                     para aquela Cooperativa;
    --               3.4 - Então atualizar o arquivo de controle da cadeia de relatorios
    --                     para indicar que o processo de relatórios da cadeia encerrou
    --
    --   Alteracoes:
    --
    --   21/03/2014 - Chamar rotina que alerta os responsáveis caso encontremos erros de
    --                relatórios da cadeia (Marcos-Supero)
    --   17/10/2017 - Retirado pc_set_modulo
    --               (Ana - Envolti - Chamado 776896)
    --   18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                (Ana - Envolti - Chamado 776896)
    -- .............................................................................
    DECLARE
      -- Busca de todas as cooperativas
      CURSOR cr_crapcop IS
        SELECT cdcooper
          FROM crapcop;
      -- Prefixo padrão dos jobs para as filas
      vr_nmjobnam VARCHAR2(30);
      -- Quantidade auxiliar para calculo de relatórios pendentes
      vr_qtjobnec NUMBER;
      -- Bloco PLSQL para chamar a execução paralela do pc_crps414
      vr_dsplsql VARCHAR2(4000);
      -- Busca todas as filas ativas
      CURSOR cr_crapfil IS
        SELECT fil.cdfilrel
              ,fil.qtdiaarq
              ,fil.qtreljob
              ,fil.qtjobati
              ,fil.flgativa
          FROM crapfil fil;
      -- Quantidade dos jobs ativos da fila
      CURSOR cr_jobs(pr_cdfilrel crapfil.cdfilrel%TYPE) IS
        SELECT COUNT(1)
          FROM dba_scheduler_jobs
         WHERE job_name like 'RLJOB_'||pr_cdfilrel||'#%';
      vr_qtjobati NUMBER;
      -- Contagem da quantidade de solicitações pendentes da fila
      CURSOR cr_crapslr_fila(pr_cdfilrel crapfil.cdfilrel%TYPE) IS
        SELECT COUNT(1)
          FROM crapslr
         WHERE cdfilrel = pr_cdfilrel
           AND flgerado = 'N'
           AND dtiniger IS NULL;
      -- Contagem da quantidade de solicitações pendentes da fila
      -- trazendo somente aqueles que são da cadeia
      CURSOR cr_crapslr_batch(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT COUNT(1)
          FROM crapslr
         WHERE cdcooper = pr_cdcooper
           AND flgerado = 'N'
           AND dtfimger IS NULL;
      -- Var genérica para a quantidade pendente
      vr_qtrel_penden NUMBER;

      vr_cdprogra    VARCHAR2(40) := 'PC_CONTROLE_FILAS_RELATO';
      vr_nomdojob    VARCHAR2(40) := 'JBGEN_CONTROLE_FILAS_RELATO';
      vr_flgerlog    BOOLEAN := FALSE;

      --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
      PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                      pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
        --> Controlar geração de log de execução dos jobs 
        BTCH0001.pc_log_exec_job( pr_cdcooper  => 3    --> Cooperativa
                                 ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                                 ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                                 ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                                 ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                                 ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
      END pc_controla_log_batch;     

    BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_controle_filas_relato');

      -- Somente trabalhar com os arquivos de controle na base de produção
      IF gene0001.fn_database_name = gene0001.fn_param_sistema('CRED',0,'DB_NAME_PRODUC') THEN --> Produção
        -- Sempre no início do processo controlador, varrer todas as cooperativas
        -- do sistema Cecred, e verificar se a cadeia noturna ou diária esta executando.
        -- Isso é possível através das funçoes na btch0001
        FOR rw_crapcop IN cr_crapcop LOOP
          -- Para cada uma que estiver com o processo executando
          IF btch0001.fn_procnot_exec(rw_crapcop.cdcooper) OR btch0001.fn_procdia_exec(rw_crapcop.cdcooper) THEN
            -- Se o processo ainda não estiver ativo
            IF NOT btch0001.fn_procrel_exec(rw_crapcop.cdcooper) THEN
              -- Devemos criar o arquivo de indicação de início da
              btch0001.pc_atuali_procrel(pr_cdcooper => rw_crapcop.cdcooper --> Cooperativa
                                        ,pr_flgsitua => 'E'                 --> Situação (E-Execução, O-OK)
                                        ,pr_des_erro => vr_des_erro);       --> Saída de erro
              -- Se houve erro
              IF vr_des_erro IS NOT NULL THEN
                -- Gerar log
                pc_gera_log_relato(pr_cdcooper => 0
                                  ,pr_des_log  => to_char(SYSDATE,'hh24:mi:ss')||' --> '||vr_des_erro);
              END IF;
            END IF;
          END IF;
        END LOOP;
      END IF;

      -- Buscar todas as filas de relatórios
      FOR rw_crapfil IN cr_crapfil LOOP

        -- Efetuar limpeza da tabela de solicitação de relatórios para a fila
        BEGIN
          -- Eliminar solicitações com data inferior aos dias parametrizados
          DELETE
            FROM crapslr slr
           WHERE slr.cdfilrel = rw_crapfil.cdfilrel
             AND slr.dtsolici < TRUNC(SYSDATE) - rw_crapfil.qtdiaarq
             AND slr.flgerado = 'S';
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
            CECRED.pc_internal_exception;
            pc_gera_log_relato(pr_cdcooper => 0
                              ,pr_des_log  => to_char(sysdate,'hh24:mi:ss')||' --> Problema ao eliminar os relatórios antigos da fila: '
                                           || rw_crapfil.cdfilrel ||'. Detalhes: '||sqlerrm||'.');
        END;
        -- Contagem da quantidade de solicitações pendentes da fila
        OPEN cr_crapslr_fila(pr_cdfilrel => rw_crapfil.cdfilrel);
        FETCH cr_crapslr_fila
         INTO vr_qtrel_penden;
        CLOSE cr_crapslr_fila;
        -- Somente continuar se a fila possui relatórios pendentes
        IF vr_qtrel_penden > 0 THEN
          
          -- Log de inicio de execucao
          pc_controla_log_batch(pr_dstiplog => 'I');

          -- Contar a quantidade de Jobs ativos da fila
          OPEN cr_jobs(pr_cdfilrel => rw_crapfil.cdfilrel);
          FETCH cr_jobs
           INTO vr_qtjobati;
          CLOSE cr_jobs;
          -- Somente continuar se a quantidade de Jobs ativos
          -- for inferior a quantidade máxima permitida
          IF vr_qtjobati < rw_crapfil.qtjobati THEN
            -- Dividir a quantidade de jobs pendentes pela qtde máxima
            -- de relatórios por Jobs, assim definimos quantos jobs são
            -- necessários ainda para processarmos todos os pendentes
            -- Obs: Usar CEIL para arredondar para cima
            vr_qtjobnec := CEIL(vr_qtrel_penden / rw_crapfil.qtreljob);
            -- Efetuar LOOP de 1 até a quantidade de jobs necessários para escalonar
            FOR vr_ind IN 1..vr_qtjobnec LOOP
              -- Preparar prefixo padrão dos JobNames
              -- RLJOB_<CDFILREL>#<N>
              -- Onde:
              --   RLJOB$   : Prefixo padrão
              --   CDFILREL : Código da fila
              --   N        : Sequencial criado pelo Oracle
              vr_nmjobnam := 'RLJOB_'||rw_crapfil.cdfilrel||'#';
              -- Sair ao alcançar a quantidade máxima de Jobs
              EXIT WHEN vr_ind + vr_qtjobati > rw_crapfil.qtjobati;
              -- Criamos o bloco PLSQL para execução da fila
              -- Obs: Não há tratamento de erro pois todo erro de relatórios é lançado ao arquivo de log dos mesmos
              vr_dsplsql := 'declare'||chr(10)
                         || '  vr_des_erro VARCHAR2(4000);'||chr(10)
                         || 'begin' ||chr(10)
                         || '  GENE0002.pc_process_relato_penden(pr_cdfilrel=>'''||rw_crapfil.cdfilrel||''',pr_des_erro=>vr_des_erro);'||chr(10)
                         || 'end;';
              -- Devemos criar um novo JOB para a fila
              gene0001.pc_submit_job(pr_cdcooper  => 0             --> Código da cooperativa
                                    ,pr_cdprogra  => NULL          --> Código do programa
                                    ,pr_dsplsql   => vr_dsplsql    --> Bloco PLSQL a executar
                                    ,pr_dthrexe   => SYSTIMESTAMP  --> Executar nesta hora
                                    ,pr_interva   => NULL          --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                                    ,pr_jobname   => vr_nmjobnam   --> Nome randomico criado (respeitando o prefixo acima)
                                    ,pr_des_erro  => vr_des_erro);
              -- Testar saida com erro
              IF vr_des_erro IS NOT NULL THEN
                
                pc_controla_log_batch(pr_dstiplog => 'E',
                                      pr_dscritic => 'Problema na rotina controladora das filas ao escalonar job para a fila '||rw_crapfil.cdfilrel||'. Detalhes: '||sqlerrm||'.');
              
                -- Enviar ao LOG
                 pc_gera_log_relato(pr_cdcooper => 0
                                   ,pr_des_log  => to_char(sysdate,'hh24:mi:ss')||' --> Problema na rotina controladora das filas ao escalonar job para a fila '||rw_crapfil.cdfilrel||'. Detalhes: '||sqlerrm||'.');
              END IF;
            END LOOP;
          END IF;
        END IF;
      END LOOP;

      -- Chamar rotina que verifica possíveis erros nos relatórios e avisa os responsáveis
      pc_aviso_erros_procrel;

      IF vr_qtrel_penden > 0 THEN 
        -- Log de inicio de execucao
        pc_controla_log_batch(pr_dstiplog => 'F');
      END IF;

      -- Somente trabalhar com os arquivos de controle na base de produção
      IF gene0001.fn_database_name = gene0001.fn_param_sistema('CRED',0,'DB_NAME_PRODUC') THEN --> Produção
        -- Sempre no término do processo controlador, varrer todas as cooperativas
        -- do sistema Cecred, e verificar se a cadeia noturna e diária encerram.
        -- Isso é possível através das funçoes na btch0001
        FOR rw_crapcop IN cr_crapcop LOOP
          -- Se todos os processos finalizaram
          IF NOT btch0001.fn_procnot_exec(rw_crapcop.cdcooper) AND NOT btch0001.fn_procdia_exec(rw_crapcop.cdcooper) THEN
            -- Se o processo de relatórios ainda estiver ativo
            IF btch0001.fn_procrel_exec(rw_crapcop.cdcooper) THEN
              -- Contagem da quantidade de solicitações pendentes da coop
              -- trazendo somente aqueles que são da cadeia
              OPEN cr_crapslr_batch(pr_cdcooper => rw_crapcop.cdcooper);
              FETCH cr_crapslr_batch
               INTO vr_qtrel_penden;
              CLOSE cr_crapslr_batch;
              -- Se não houverem mais relatórios da cadeia pendentes para a Cooperativa
              IF vr_qtrel_penden = 0 THEN
                -- Devemos atualizar o arquivo de indicação do término dos relatórios
                btch0001.pc_atuali_procrel(pr_cdcooper => rw_crapcop.cdcooper --> Cooperativa
                                          ,pr_flgsitua => 'O'                 --> Situação (E-Execução, O-OK)
                                          ,pr_des_erro => vr_des_erro);       --> Saída de erro
                -- Se houve erro
                IF vr_des_erro IS NOT NULL THEN
                  -- Gerar log
                  pc_gera_log_relato(pr_cdcooper => 0
                                    ,pr_des_log  => to_char(SYSDATE,'hh24:mi:ss')||' --> '||vr_des_erro);
                END IF;
              END IF;
            END IF;
          END IF;
        END LOOP;
      END IF;
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);

      -- Gravar as alterações
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
        CECRED.pc_internal_exception;
        pc_gera_log_relato(pr_cdcooper => 0
                          ,pr_des_log  => to_char(sysdate,'hh24:mi:ss')||' --> Problema na rotina controladora das filas. Detalhes: '||sqlerrm||'.');
    END;
  END pc_controle_filas_relato;

  /* Função para buscar o tempo do sistema  */
  FUNCTION fn_busca_time RETURN NUMBER IS
  BEGIN
    -- Retonar o tempo de forma padronizada
    RETURN (To_Number(To_Char(systimestamp,'SSSSS')));
  END fn_busca_time;

  /* Retonar a data a partir do numero de segundos */
  FUNCTION fn_converte_time_data(pr_nrsegs   in integer,
                                 pr_tipsaida in varchar2 default 'M') RETURN varchar2 IS
    vr_nrsegs    integer := pr_nrsegs;
    -- ..........................................................................
    --   Alteracoes: 17/10/2017 - Retirado pc_set_modulo
    --                            (Ana - Envolti - Chamado 776896)
    --               18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                            (Ana - Envolti - Chamado 776896)
    -- ..........................................................................
  BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.fn_converte_time_data');
    -- Reduz a quantidade de segundos para apenas 1 dia
    while vr_nrsegs >= 86400 loop
      vr_nrsegs := vr_nrsegs - 86400;
    end loop;
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    -- Se for para retornar segundos
    if upper(pr_tipsaida) = 'S' then
      -- Retonar a data a partir do numero de segundos
      return(to_char(to_date(vr_nrsegs, 'sssss'), 'hh24:mi:ss'));
    else
      -- Retonar a data a partir do numero de segundos
      return(to_char(to_date(vr_nrsegs, 'sssss'), 'hh24:mi'));
    end if;
  END;

  /* Função para processar uma string que contém um valor e retorná-lo em number  */
  FUNCTION fn_char_para_number(pr_dsnumtex IN varchar2) RETURN NUMBER IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : fn_char_para_number
    --  Sistema  : Rotinas genéricas
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Dezembro/2012.                   Ultima atualizacao: 18/10/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Esta rotina recebe uma string que deve conter um valor em
    --               moeda ou numero e convete a mesma para ser retornada como
    --               um number.
    --      Regras : 1) A rotina utilizará a view nls_database_parameters para
    --                  conhecer quais são os separadores configurados no banco
    --               2) O ultimo separador da string (ponto ou virgual) é considerado
    --                  o separador de decimal
    --               3) Informações como o sinal e a moeda podem ser enviada e
    --                  apenas o sinal será considerado para a conversão de number
    --               4) Em caso de erro, a função retornará NUL
    --
    --   Alteracoes: 17/10/2017 - Retirado pc_set_modulo
    --                            (Ana - Envolti - Chamado 776896)
    --               18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                            (Ana - Envolti - Chamado 776896)
    -- .............................................................................
    DECLARE
      -- Buscar os caracteres separadores
      CURSOR cr_sep IS
        SELECT substr(value,2,1) dssepmil
              ,substr(value,1,1) dssepdec
          FROM nls_session_parameters
         WHERE parameter = 'NLS_NUMERIC_CHARACTERS';
      -- Variavel auxiliar para guardar as informações
      -- do número ainda representado como texto
      vr_dsnumtex VARCHAR2(60);
      -- Guardar o ultimo separador encontrado
      vr_dsultsep VARCHAR2(1);
    BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.fn_char_para_number');

      -- Se o parâmetro estiver nulo, retornar
      IF pr_dsnumtex IS NULL THEN
        RETURN NULL;
      END IF;
      
      -- Se a tabela de dados estiver vazia vai carregar
      IF vr_nlspar.count = 0 THEN
        FOR rw_sep IN cr_sep LOOP
          vr_nlspar(1).dssepmil := rw_sep.dssepmil;
          vr_nlspar(1).dssepdec := rw_sep.dssepdec;
        END LOOP;
      END IF;
      -- Itera sobre a string enviada checando caracter a caracter
      FOR vr_ind IN 1..LENGTH(pr_dsnumtex) LOOP
        -- Somente entrar se for um numero, um sinal ou separador
        IF substr(pr_dsnumtex,vr_ind,1) IN ('0','1','2','3','4','5','6','7','8','9','+','-','.',',') THEN
          -- Sempre que encontrar um sepador
          IF substr(pr_dsnumtex,vr_ind,1) IN ('.',',') THEN
            -- Remover da string qualquer outro caracter
            -- já copiado, pois isso garante que no final
            -- tenhamos apenas o separador decimal restando
            vr_dsnumtex := REPLACE(REPLACE(vr_dsnumtex,',',''),'.','');
            -- Guardar este caracter como o ultimo separador
            -- encontrado até o presente momento
            vr_dsultsep := substr(pr_dsnumtex,vr_ind,1);
          END IF;
          -- Adiciona na string o caracter encontrado
          vr_dsnumtex := vr_dsnumtex || substr(pr_dsnumtex,vr_ind,1);
        END IF;
      END LOOP;
      -- Verificar se o ultimo caracter é um sinal
      IF substr(vr_dsnumtex,LENGTH(vr_dsnumtex),1) IN('+','-') THEN
        -- Copiá-lo para o começo da string
        vr_dsnumtex := substr(vr_dsnumtex,LENGTH(vr_dsnumtex),1)||substr(vr_dsnumtex,1,LENGTH(vr_dsnumtex)-1);
      END IF;
      -- Ao final, se foi encontrado algum caracter separador
      IF vr_dsultsep IS NOT NULL THEN
        -- Subsituimos o mesmo pelo caracter separador
        -- de decimal configurado na sessão
        -- (Se for igual, não haverá problema)
        vr_dsnumtex := REPLACE(vr_dsnumtex,vr_dsultsep,vr_nlspar(1).dssepdec);
      END IF;
      -- Enfim, efetuamos return para converter o texto
      -- que ficou restando na string processada, que de acordo
      -- com as vaidações acima deve ter ficado apenas com o sinal,
      -- os valores e o caracter decimal apenas
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
      --RETURN vr_dsnumtex; -- Renato Darosci => tratar corretamente o retorno do numérico
      RETURN to_number(vr_dsnumtex, 'FM999999999999999999999999999d9999999999', 'NLS_NUMERIC_CHARACTERS='''||vr_nlspar(1).dssepdec||vr_nlspar(1).dssepmil||'');
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
        CECRED.pc_internal_exception;
        RETURN NULL;
    END;
  END fn_char_para_number;

  /* Calcular a diferença entre duas datas e retornar diferença em hh:mi:ss */
  FUNCTION fn_calc_difere_datas(pr_dtinicio IN DATE
                               ,pr_dttermin IN DATE) RETURN VARCHAR2 IS
  BEGIN
    /*..............................................................................

       Programa: fn_calc_difere_datas
       Autor   : Marcos (Supero)
       Data    : Fevereiro/2013                    Ultima atualizacao:

       Dados referentes ao programa:

       Objetivo  : Calcular a diferença entre duas datas e retornar diferença em hh:mi:ss

       Alteracoes: 18/10/2017 - Incluído pc_set_modulo com novo padrão
                                (Ana - Envolti - Chamado 776896)
    ..............................................................................*/
    DECLARE
      -- Variaveis para o cálculo
    vr_qtddfrac NUMBER;
    vr_qthrsdif NUMBER;
    vr_qtmindif NUMBER;
    vr_qtsecdif NUMBER;
    BEGIN
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => 'GENE0002.fn_calc_difere_datas');
      -- Armazenar a fraçao de dias entre as datas
      vr_qtddfrac := (pr_dttermin-pr_dtinicio)-trunc(pr_dttermin-pr_dtinicio);
      -- Acumular horas, minutos e segundos separadamente
      vr_qthrsdif := ABS(trunc(vr_qtddfrac*24));
      vr_qtmindif := ABS(trunc((((vr_qtddfrac)*24)-(vr_qthrsdif))*60));
      vr_qtsecdif := ABS(trunc(mod((pr_dttermin-pr_dtinicio)*86400,60)));
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
      -- Retornar os valores calculados no formado hh24:mi:ss
      RETURN(LPAD (vr_qthrsdif, 2, '0') ||':'|| LPAD (vr_qtmindif, 2, '0') ||':'|| LPAD (vr_qtsecdif, 2, '0'));
    EXCEPTION
      WHEN OTHERS THEN
        -- Retornar 00 como diferença
        RETURN '00:00:00';
    END;
  END fn_calc_difere_datas;

  /* Procedure para controlar buferização de um CLOB */
  PROCEDURE pc_clob_buffer(pr_dados   IN OUT NOCOPY VARCHAR2       --> Buffer de dados
                          ,pr_btam    IN PLS_INTEGER DEFAULT 32600 --> Determina o tamanho do buffer
                          ,pr_gravfim IN BOOLEAN                   --> Verifica se é gravação final do buffer
                          ,pr_clob    IN OUT NOCOPY CLOB) IS       --> Clob de gravação
    -- ..........................................................................
    --
    --  Programa : pc_clob_buffer
    --  Sistema  : Rotinas genéricas
    --  Sigla    : GENE
    --  Autor    : Petter Rafael - Supero Tecnologia
    --  Data     : Setembro/2013.                   Ultima atualizacao: 18/10/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Controlar a gravação de dados em um CLOB utilizando buferização
    --               para melhorar a performance.
    --
    --   Alteracoes: Ajustes para não gravar linha no clob, caso o parametro esteja vazio(Odirlei/AMcom)
    --
    --               17/10/2017 - Retirado pc_set_modulo
    --                            (Ana - Envolti - Chamado 776896)
    --               18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                            (Ana - Envolti - Chamado 776896)
    -- .............................................................................
  BEGIN
    DECLARE
      /* Declaração de funções e procedures */
      -- Procedure para escrever texto na variável CLOB do XML
      PROCEDURE pc_xml_tag(pr_buffer    IN VARCHAR2                --> String que será adicionada ao CLOB
                          ,pr_clob      IN OUT NOCOPY CLOB) IS     --> CLOB que irá receber a string
      BEGIN
        dbms_lob.writeappend(pr_clob, length(pr_buffer), pr_buffer);
      END pc_xml_tag;

    BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_clob_buffer');
      -- Verifica se é gravação final
      IF NOT pr_gravfim THEN
        -- Valida o tamanho do buffer para gravação
        IF LENGTH(pr_dados) >= pr_btam THEN
          pc_xml_tag(pr_dados, pr_clob);
          pr_dados := '';
        END IF;
      ELSE
        IF pr_dados is not null THEN
          pc_xml_tag(pr_dados, pr_clob);
        END IF;
        pr_dados := '';
      END IF;
    END;
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
  END pc_clob_buffer;

  -- Subrotina para escrever texto na variável CLOB do XML
  procedure pc_escreve_xml(pr_xml in out nocopy clob,  --> Variável CLOB onde será incluído o texto
                           pr_texto_completo in out nocopy varchar2,  --> Variável para armazenar o texto até ser incluído no CLOB
                           pr_texto_novo in varchar2,  --> Texto a incluir no CLOB
                           pr_fecha_xml in boolean default false) is  --> Flag indicando se é o último texto no CLOB
    /*----------------------------------------------------------
      Programa: pc_escreve_xml
      Autor: Daniel Dallagnese (Supero)
      Data: 11/02/2014                               Última atualização: 11/02/2014

      Objetivo: Melhorar a performance dos programas que necessitam escrever muita
                informação em variável CLOB. Exemplo de uso: PC_CRPS086.

      Utilização: Quando houver necessidade de incluir informações em um CLOB, deve-se
                  declarar, instanciar e abrir o CLOB no programa chamador, e passá-lo
                  no parâmetro PR_XML para este procedimento, juntamente com o texto que
                  se deseja incluir no CLOB. Para finalizar a geração do CLOB, deve-se
                  incluir também o parâmetro PR_FECHA_XML com o valor TRUE. Ao final, no
                  programa chamador, deve-se fechar o CLOB e liberar a memória utilizada.

      Alterações: 17/10/2017 - Retirado pc_set_modulo
                              (Ana - Envolti - Chamado 776896)
                  18/10/2017 - Incluído pc_set_modulo com novo padrão
                               (Ana - Envolti - Chamado 776896)
    ----------------------------------------------------------*/
    procedure pc_concatena(pr_xml in out nocopy clob,
                           pr_texto_completo in out nocopy varchar2,
                           pr_texto_novo varchar2) is
      -- Prodimento para concatenar os textos em um varchar2 antes de incluir no CLOB,
      -- ganhando performance. Somente grava no CLOB quando estourar a capacidade da variável.
    begin
      -- Tenta concatenar o novo texto após o texto antigo (variável global da package)
      pr_texto_completo := pr_texto_completo || pr_texto_novo;
    exception when value_error then
      if pr_xml is null then
        pr_xml := pr_texto_completo;
      else
        dbms_lob.writeappend(pr_xml, length(pr_texto_completo), pr_texto_completo);
        pr_texto_completo := pr_texto_novo;
      end if;
    end;
    --
  begin
	  -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_escreve_xml');
    -- Concatena o novo texto
    pc_concatena(pr_xml, pr_texto_completo, pr_texto_novo);
    -- Se for o último texto do arquivo, inclui no CLOB
    if pr_fecha_xml then
      dbms_lob.writeappend(pr_xml, length(pr_texto_completo), pr_texto_completo);
      pr_texto_completo := null;
    end if;
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
  end;

  /* Procedure para copiar arquivos para a intranet */
  PROCEDURE pc_gera_arquivo_intranet(pr_cdcooper IN PLS_INTEGER                --> Código da cooperativa
                                    ,pr_cdagenci IN PLS_INTEGER                --> Código da agencia
                                    ,pr_dtmvtolt IN DATE                       --> Data de movimento
                                    ,pr_nmarqimp IN VARCHAR2                   --> Nome arquivo de impressão
                                    ,pr_nmformul IN VARCHAR2                   --> Nome do formulário
                                    ,pr_dscritic OUT VARCHAR2                  --> Descrição da crítica
                                    ,pr_tab_erro IN OUT GENE0001.typ_tab_erro  --> Tabela com erros
                                    ,pr_des_erro OUT VARCHAR2) IS              --> Retorno de erros no processo
    -- ..........................................................................
    --
    --  Programa : pc_gera_arquivo_intranet      (Antigo B1WGEN0024.P --> GERA-ARQUIVO-INTRANET)
    --  Sistema  : Rotinas genéricas
    --  Sigla    : GENE
    --  Autor    : Petter Rafael - Supero Tecnologia
    --  Data     : Outubro/2013.                   Ultima atualizacao: 18/10/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Efetuar o envio de arquivos para a intranet.
    --
    --   Alteracoes: 17/10/2017 - Retirado pc_set_modulo
    --                            (Ana - Envolti - Chamado 776896)
    --               18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                            (Ana - Envolti - Chamado 776896)
    -- .............................................................................
  BEGIN
    DECLARE
      vr_nrtamarq   PLS_INTEGER := 0;         --> Número de arquivo
      vr_dsgerenc   VARCHAR2(100);            --> Descrição agencia
      vr_tprelato   PLS_INTEGER := 0;         --> Tipo de relatório
      vr_ingerpdf   PLS_INTEGER := 0;         --> Flag para gerar PDF
      vr_nmrelato   VARCHAR2(100);            --> Nome do relatório
      vr_cdrelato   PLS_INTEGER := 0;         --> Código do relatório
      vr_setlinha   VARCHAR2(80);             --> Definição de linha
      vr_nmarqtmp   VARCHAR2(150);            --> Nome de arquivo temporário
      vr_nmarqpdf   VARCHAR2(80);             --> Nome de arquivo PDF
      vr_typ_saida  VARCHAR2(40);             --> Saída do terminal
      vr_des_saida  VARCHAR2(4000);           --> Descrição da saída do terminal
      vr_retcomando typ_split := typ_split(); --> Array com os resultados do split
      vr_setlinhas  typ_split := typ_split(); --> Array com os resultados do split
      vr_rettermis  typ_split := typ_split(); --> Array com os resultados do split
      vr_exc_erro   EXCEPTION;                --> Controle para saída de erros
      vr_rettermi   VARCHAR2(200);            --> Armazenar retorno do terminal
      vr_arquivo    utl_file.file_type;       --> Handle para gravar arquivo
      vr_nomarqf    VARCHAR2(100);            --> Nome do arquivo final para intranet

      arquivo utl_file.file_type;

      /* Buscar dados da cooperativa */
      CURSOR cr_crapcop(pr_cdcooper  IN crapcop.cdcooper%TYPE) IS   --> Código da cooperativa
        SELECT cp.nmrescop
        FROM crapcop cp
        WHERE cp.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      /* Buscar dados da execução dos relatórios */
      CURSOR cr_craprel(pr_cdcooper IN craprel.cdcooper%TYPE      --> Código da cooperativa
                       ,pr_cdrelato IN craprel.cdrelato%TYPE) IS  --> Código de relatório
        SELECT cl.ingerpdf
              ,cl.nmrelato
              ,cl.tprelato
        FROM craprel cl
        WHERE cl.cdcooper = pr_cdcooper
          AND cl.cdrelato = pr_cdrelato;
      rw_craprel cr_craprel%ROWTYPE;

    BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_gera_arquivo_intranet');
      -- Consultar dados da cooperativa
      OPEN cr_crapcop(pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;

      -- Verifica se a tupla retornou registros
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;

        -- Gera tabela de erros
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 0
                             ,pr_cdcritic => 651
                             ,pr_dscritic => pr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        pr_des_erro := 'NOK';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapcop;
      END IF;

      -- Verifica caracter inválido
      IF INSTR(pr_nmarqimp,'*') > 0 THEN
        pr_dscritic := 'Caracter invalido no nome do relatorio ' || pr_nmarqimp || '. VERIFIQUE!';

        -- Gera tabela de erros
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 0
                             ,pr_cdcritic => 0
                             ,pr_dscritic => pr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        pr_des_erro := 'NOK';
        RAISE vr_exc_erro;
      END IF;

      -- Obter Dados para impressão e INTRANET
      vr_dsgerenc := 'NAO';
      vr_tprelato := 0;
      vr_ingerpdf := 0;
      vr_nmrelato := ' ';
      vr_cdrelato := TO_NUMBER(SUBSTR(pr_nmarqimp, instr(pr_nmarqimp, 'crrl') + 4, 3));

      -- Buscar dados da execução dos relatórios
      OPEN cr_craprel(pr_cdcooper, vr_cdrelato);
      FETCH cr_craprel INTO rw_craprel;

      -- Verifica se a tupla retornou registro
      IF cr_craprel%FOUND THEN
        CLOSE cr_craprel;

        vr_ingerpdf := rw_craprel.ingerpdf;
        vr_nmrelato := rw_craprel.nmrelato;

        -- Verifica o tipo do relatório
        IF rw_craprel.tprelato = 2 THEN
          vr_dsgerenc := 'SIM';
          vr_tprelato := 1;
        END IF;
      ELSE
        CLOSE cr_craprel;
      END IF;

      -- Gerar arquivo para intranet
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'ls ' || pr_nmarqimp || ' 2> /dev/null'
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_setlinha);

      -- Obter retorno da linha de comando
      --vr_setlinhas := fn_quebra_string(pr_string => vr_setlinha, pr_delimit => ' ');
      vr_setlinha := translate(vr_setlinha, chr(10)||chr(13),'');

      -- Verificar flag para gerar PDF
      IF vr_ingerpdf = 1 THEN
        -- Processar comando via terminal
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => 'basename ' || pr_nmarqimp
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_rettermi);

        -- Armazenar valor
        vr_nmarqtmp := SUBSTR(translate(vr_rettermi, chr(10)||chr(13),''), 0, 150);

        -- Verificar comando via terminal
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => 'echo ' || pr_nmarqimp || '| cut -d ''.'' -f 1'
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_rettermi);

        -- Armazenar valor
        vr_nmarqpdf := SUBSTR(translate(vr_rettermi, chr(10)||chr(13),''), 0, 40);

        -- Gerar nomes e path para arquivos
        vr_nmarqpdf := vr_nmarqpdf || '.pdf';

        -- Gerar arquivo para log dos eventos
        -- Abrir arquivo em modo de adição
        gene0001.pc_abre_arquivo(pr_nmdireto => gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => 1, pr_nmsubdir => '/tmppdf')
                                ,pr_nmarquiv => SUBSTR(vr_nmarqtmp, 1, LENGTH(vr_nmarqtmp) - 4) || '.txt'
                                ,pr_tipabert => 'W'
                                ,pr_utlfileh => vr_arquivo
                                ,pr_des_erro => pr_des_erro);

        -- Verifica se ocorreram erros
        IF pr_des_erro IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arquivo
                                      ,pr_des_text => rw_crapcop.nmrescop || ';' ||
                                                      to_char(pr_dtmvtolt, 'RRRR') || ';' ||
                                                      to_char(pr_dtmvtolt, 'MM') || ';' ||
                                                      to_char(pr_dtmvtolt, 'DD') || ';' ||
                                                      lpad(vr_tprelato, 2, ' ') || ';' ||
                                                      vr_nmarqpdf || ';' ||
                                                      lpad(upper(vr_nmrelato), 50, ' ') || ';');

        -- Fechar arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_arquivo);

        -- Gerar arquivo PDF
        vr_nomarqf := to_char(pr_dtmvtolt, 'RRRR') || '_' || to_char(pr_dtmvtolt, 'MM') || '/' || to_char(pr_dtmvtolt, 'DD');

        -- Verifica se ocorreram erros
        IF pr_des_erro IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);

      pr_des_erro := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro := 'Erro em GENE0002.pc_gera_arquivo_intranet: ' || pr_des_erro;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
        pr_des_erro := 'Erro em GENE0002.pc_gera_arquivo_intranet: ' || SQLERRM;
    END;
  END pc_gera_arquivo_intranet;


  /* Funçao para testar se a variável é uma data valida */
  FUNCTION fn_data(pr_vlrteste IN VARCHAR2
                  ,pr_formato  IN VARCHAR2) RETURN boolean IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : fn_numerico
    --  Sistema  : Rotinas genéricas
    --  Sigla    : GENE
    --  Autor    : Daniel Zimmermann
    --  Data     : Dezembro/2014.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Retornar validação se a variável é uma data.
    --   Alteracoes: 18/10/2017 - Incluído pc_set_modulo com novo padrão
    --                            (Ana - Envolti - Chamado 776896)
    -- ............................................................................
    DECLARE
      vr_ctrteste       BOOLEAN := TRUE;
      vr_qvalor         VARCHAR2(1);
      vr_auxdata        DATE;

    BEGIN
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => 'GENE0002.fn_data');
      -- Se o parametro for enviado sozinho retorna false.
      IF pr_vlrteste IS NULL OR
         pr_formato IS NULL THEN
        vr_ctrteste := FALSE;
      ELSE

        BEGIN
          vr_auxdata := to_date(pr_vlrteste,pr_formato);
          vr_ctrteste := TRUE;
        EXCEPTION
          WHEN OTHERS THEN
            vr_ctrteste := FALSE;
        END;

      END IF;
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);

      RETURN vr_ctrteste;
    END;
  END fn_data;

  -- Subrotina para enviar arquivo de extrato da conta para servidor web
  PROCEDURE pc_envia_arquivo_web (pr_cdcooper IN crapcop.cdcooper%TYPE  --Codigo Cooperativa
                                 ,pr_cdagenci IN crapass.cdagenci%TYPE  --Codigo Agencia
                                 ,pr_nrdcaixa IN INTEGER                --Numero do Caixa
                                 ,pr_nmarqimp IN VARCHAR2               --Nome Arquivo Impressao
                                 ,pr_nmdireto IN VARCHAR2               --Nome Diretorio
                                 ,pr_nmarqpdf OUT VARCHAR2              --Nome Arquivo PDF
                                 ,pr_des_reto OUT VARCHAR2              --Retorno OK/NOK
                                 ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --Tabela Erros
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_envia_arquivo_web            Antigo: procedures/b1wgen0024.p/envia-arquivo-web
  --  Sistema  :
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2014                           Ultima atualizacao: 18/10/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo   : Procedure para envio do arquivo de extrato da conta para servidor web
  --
  -- Alterações : 02/07/2014 - Conversão Progress -> Oracle (Alisson - AMcom)
  --              21/11/2014 - Remocao do comando de copia do arquivo .PDF de um servidor
  --                           para outro e utilizacao da procedure pronta de geracao do PDF.
  --              27/02/2015 - Incluido o nome do arquivo .pdf no retorno da variavel pr_nmarqpdf,
  --                           feito tratamento para arquivos .lst (Jean Michel).
  --              05/04/2016 - Ajuste para retirar o "*" ao remover o arquivo
  --                           (Adriano).        
  --              17/10/2017 - Retirado pc_set_modulo
  --                            (Ana - Envolti - Chamado 776896)
  --               18/10/2017 - Incluído pc_set_modulo com novo padrão
  --                            (Ana - Envolti - Chamado 776896)
  ---------------------------------------------------------------------------------------------------------------
        --Cursores Locais
        -- Busca dos dados da cooperativa
        CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
          SELECT crapcop.nmrescop
                ,crapcop.nmextcop
                ,crapcop.dsdircop
          FROM crapcop crapcop
          WHERE crapcop.cdcooper = pr_cdcooper;
        rw_crapcop cr_crapcop%ROWTYPE;

        --Variaveis Locais
        vr_typ_saida VARCHAR2(3);
        vr_comando   VARCHAR2(2000);
        vr_setlinha  VARCHAR2(100);
        --Variaveis Erro
        vr_cdcritic  INTEGER;
        vr_dscritic  VARCHAR2(4000);
        --Variaveis de Excecoes
        vr_exc_erro EXCEPTION;
        -- nome do servidor
        vr_srvintra  VARCHAR2(200);

        vr_tab_erro VARCHAR2(200);
        vr_nmarqpdf VARCHAR2(200);
        vr_nmarqimp VARCHAR2(200);
        vr_dircoope VARCHAR2(400);
        vr_tipsplit GENE0002.typ_split;

      BEGIN
	      -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_envia_arquivo_web');
        --Limpar parametros erro
        pr_des_reto:= 'OK';

        -- Verifica se a cooperativa esta cadastrada
        OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
        FETCH cr_crapcop INTO rw_crapcop;
        -- Se não encontrar
        IF cr_crapcop%NOTFOUND THEN
          -- Fechar o cursor pois haverá raise
          CLOSE cr_crapcop;
          -- Montar mensagem de critica
          vr_cdcritic := 651;
          RAISE vr_exc_erro;
        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_crapcop;
        END IF;

        -- recupera o diretorio rl da cooperativa
        vr_dircoope := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => pr_cdcooper, pr_nmsubdir => '/rl');
        -- monta nome do arquivo .PDF
        vr_nmarqpdf := vr_dircoope||'/'|| regexp_replace(pr_nmarqimp, '\.ex|\.lst', '.pdf');
        -- concatena pasta ao nome do arquivo
        vr_nmarqimp := vr_dircoope||'/'||pr_nmarqimp;

        pc_gera_pdf_impressao(pr_cdcooper => pr_cdcooper,
                              pr_nmarqimp => vr_nmarqimp,
                              pr_nmarqpdf => vr_nmarqpdf,
                              pr_des_erro => vr_tab_erro);

        pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nmarqpdf => vr_nmarqpdf,
                            pr_des_reto => pr_des_reto,
                            pr_tab_erro => pr_tab_erro);


        --Excluir arquivo impressao caso o mesmo exista no diretorio
        IF gene0001.fn_exis_arquivo (vr_nmarqimp) THEN
          -- Comando para remover arquivo
          vr_comando:= 'rm '||vr_nmarqimp||' 2>/dev/null';
          --Remover Arquivo pre-existente
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => vr_comando
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_setlinha);
          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
            vr_dscritic:= 'Não foi possível executar comando unix. '||vr_comando;
            RAISE vr_exc_erro;
          END IF;
        END IF;

        --Excluir arquivo impressao caso o mesmo exista no diretorio
        IF gene0001.fn_exis_arquivo (vr_nmarqpdf) THEN
          -- Comando para remover arquivo
          vr_comando:= 'rm '||vr_nmarqpdf||' 2>/dev/null';
          --Remover Arquivo pre-existente
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => vr_comando
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_setlinha);
          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
            vr_dscritic:= 'Não foi possível executar comando unix. '||vr_comando;
            RAISE vr_exc_erro;
          END IF;
        END IF;

        -- Retornar arquivo .pdf
        IF vr_nmarqpdf IS NOT NULL THEN
          vr_tipsplit := GENE0002.fn_quebra_string(pr_string => vr_nmarqpdf, pr_delimit => '/');
          pr_nmarqpdf := vr_tipsplit(vr_tipsplit.LAST);
        END IF;

        --Retornar OK
        pr_des_reto := 'OK';
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
      EXCEPTION
        WHEN vr_exc_erro THEN
          -- Retorno não OK
          pr_des_reto := 'NOK';
          -- Chamar rotina de gravação de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic --> Critica 0
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
          -- Retorno não OK
          pr_des_reto := 'NOK';
          -- Chamar rotina de gravação de erro
          vr_dscritic := 'Erro na pr_envia_arquivo_web --> '|| sqlerrm;
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic --> Critica 0
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
      END pc_envia_arquivo_web;

  -- Procedure para importar arquivo XML para XMLtype
  PROCEDURE pc_arquivo_para_xml (pr_nmarquiv IN VARCHAR2         --> Nome do caminho completo)
                                ,pr_tipmodo  IN NUMBER DEFAULT 1 --> Tipo de modo de carregamento 1 - Normal(utl_file) 2 - Alternativo(usando blob)
                                ,pr_xmltype  OUT XmlType         --> Saida para o XML
                                ,pr_des_reto OUT VARCHAR2        --> Descrição OK/NOK
                                ,pr_dscritic OUT VARCHAR2) IS    --> Descricao Erro
  /*............................................................................

   Programa: pc_arquivo_para_xml
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Alisson
   Data    : Fevereiro/2015                          Ultima atualizacao: 18/10/2017

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Importar arquivo XML do modo texto para dentro do XMLtype

   Alteracoes: 11/02/2015 - Desenvolvimento

               19/05/2015 - Inclusão do parametro pr_tipmodo para permitir importar arquivos
                            que possuam linhas maiores que 32627 caractere:
                            1 - Normal(utl_file), usado para arquivos com linhas menores
                            2 - Alternativo(usando blob) , usado para arquivos com linhas cujo ultrapassem 32627 caracteres
                            (Odirlei-AMcom)

               17/10/2017 - Retirado pc_set_modulo
                           (Ana - Envolti - Chamado 776896)
  .............................................................................*/
  BEGIN
    DECLARE

      vr_contador  INTEGER;
      vr_setlinha  VARCHAR2(32767);
      vr_dstxtclob VARCHAR2(32767);
      --CLOB
      vr_clob CLOB;
      vr_Blob BLOB;
      --handle de Arquivo
      vr_input_file UTL_FILE.FILE_TYPE;
      --Variavel erro
      vr_dscritic VARCHAR2(1000);
      --Variavel Excecao
      vr_exc_erro EXCEPTION;
      -- caminho e nome do arquivo
      vr_nmdireto  VARCHAR2(500);
      vr_nmarquiv  VARCHAR2(500);
      -- posicao inicial para leitura do blob
      vr_posinic   PLS_INTEGER := 1;
      -- tamanho do buffer de leitura
      vr_buffer    PLS_INTEGER := 32767;

    BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_arquivo_para_xml');

      /* Verificar se o arquivo existe */
      IF NOT gene0001.fn_exis_arquivo(pr_caminho => pr_nmarquiv) THEN
        vr_dscritic:= 'Arquivo nao encontrado.';
        RAISE vr_exc_erro;
      END IF;

      -- Modo Normal
      IF pr_tipmodo = 1 THEN

        /* Importar arquivo para retirar caracteres especiais */

        --Abrir o arquivo
        gene0001.pc_abre_arquivo(pr_nmcaminh => pr_nmarquiv   --> Nome do caminho completo
                                ,pr_tipabert => 'R'           --> Somente Leitura
                                ,pr_utlfileh => vr_input_file --> Handle do Arquivo
                                ,pr_des_erro => vr_dscritic); --> Erro
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          --Proximo Registro
          RAISE vr_exc_erro;
        END IF;

        --Inicializar Clob
        dbms_lob.createtemporary(vr_clob, TRUE);
        dbms_lob.OPEN(vr_clob,dbms_lob.lob_readwrite);

        --Inicializar Contador
        vr_contador:= 1;

        --Faz leitura das linhas
        LOOP
          BEGIN
            -- Carrega handle do arquivo
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto lido

            --Substituir caracteres especiais da Linha
            vr_setlinha:= inss0001.fn_substitui_caracter(vr_setlinha);

            --Retirar Sujeira Inicio do arquivo
            IF vr_contador = 1 THEN
              vr_setlinha:= substr(vr_setlinha,instr(vr_setlinha,'<?xml'));
            END IF;

            --Se a linha possuir informacao
            IF vr_setlinha IS NOT NULL THEN
              --Colocar linha convertida no CLOB
              GENE0002.pc_escreve_xml(vr_clob,vr_dstxtclob,vr_setlinha);
            END IF;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              --Acabaram as linhas do arquivo, atualiza CLOB
              GENE0002.pc_escreve_xml(vr_clob,vr_dstxtclob,' ',TRUE);

              --Fechar o arquivo de leitura
              IF utl_file.is_open(vr_input_file) THEN
                gene0001.pc_fecha_arquivo(vr_input_file);
              END IF;

              --Sair do LOOP
              EXIT;
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
              CECRED.pc_internal_exception;
              --Erro no processamento
              vr_dscritic:= 'Erro ao processar arquivo '||pr_nmarquiv||' - '||SQLERRM;

              --Fechar Clob e Liberar Memoria
              dbms_lob.close(vr_clob);
              dbms_lob.freetemporary(vr_clob);

              --Fechar o arquivo de leitura
              IF utl_file.is_open(vr_input_file) THEN
                gene0001.pc_fecha_arquivo(vr_input_file);
              END IF;

              --Levantar Excecao Proximo
              RAISE vr_exc_erro;
          END;
          --Incrementar Contador
          vr_contador:= vr_contador+1;
        END LOOP;

      /* Modo Alternativo, para linhas maiores que o limite*/
      ELSIF pr_tipmodo = 2 THEN
        -- Chamar rotina de separação do caminho do nome
        gene0001.pc_separa_arquivo_path(pr_caminho => pr_nmarquiv
                                       ,pr_direto  => vr_nmdireto
                                       ,pr_arquivo => vr_nmarquiv);
        -- Exportar arquivo para clob
        vr_Blob := GENE0002.fn_arq_para_blob(pr_caminho => vr_nmdireto,
                                             pr_arquivo => vr_nmarquiv);

        -- Criar um LOB para armazenar o arquivo
        DBMS_LOB.CREATETEMPORARY(vr_clob, TRUE);
        dbms_lob.OPEN(vr_clob,dbms_lob.lob_readwrite);

        --> Loop para a leitura do BLOB para clob
        -- loop pela qnt de vezes que é necessario ler os buffers
        FOR i IN 1 .. CEIL(DBMS_LOB.GETLENGTH(vr_Blob) / vr_buffer) LOOP
         -- busca linha do tamanho do buffer
         vr_setlinha := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(vr_Blob,
                                                               vr_buffer,
                                                               vr_posinic));
         -- inclui dados do clob
         DBMS_LOB.WRITEAPPEND(vr_clob, LENGTH(vr_setlinha), vr_setlinha);
         -- incrementa posição
         vr_posinic := vr_posinic + vr_buffer;
       END LOOP;

      END IF;

      BEGIN
        --Converter CLOB para XMLtype para ler tags
        pr_xmltype:= XMLType.createxml(vr_clob);

        --Fechar Clob e Liberar Memoria
        dbms_lob.close(vr_clob);
        dbms_lob.freetemporary(vr_clob);

      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
          CECRED.pc_internal_exception;
          vr_dscritic:= 'Resposta invalida (XML).'||' - '||SQLERRM;

          --Fechar Clob e Liberar Memoria
          dbms_lob.close(vr_clob);
          dbms_lob.freetemporary(vr_clob);

          --Levantar Excecao
          RAISE vr_exc_erro;
      END;
      --Retorno OK
      pr_des_reto:= 'OK';
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_reto:= 'NOK';
        pr_dscritic:= 'Erro na GENE0002.pc_arquivo_para_xml. '||vr_dscritic;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
        CECRED.pc_internal_exception;
        pr_des_reto:= 'NOK';
        pr_dscritic:= 'Erro na GENE0002.pc_arquivo_para_xml. '||sqlerrm;
    END;
  END pc_arquivo_para_XML;

  -- Função para abreviar string
  FUNCTION fn_abreviar_string (pr_nmdentra IN VARCHAR2       --> Nome de Entrada
                              ,pr_qtletras IN INTEGER) RETURN VARCHAR2 IS --> Quantidade de Letras
  /*............................................................................

   Programa: fn_abreviar_string                      Antigo: fontes/abreviar.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Alisson
   Data    : Fevereiro/2015                          Ultima atualizacao: 18/10/2017

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Abreviar a string conforme quantidade de letras

   Alteracoes: 23/02/2015 - Conversão Progress --> Oracle (Alisson - AMcom)
               17/10/2017 - Retirado pc_set_modulo
                           (Ana - Envolti - Chamado 776896)
               18/10/2017 - Incluído pc_set_modulo com novo padrão
                            (Ana - Envolti - Chamado 776896)
  .............................................................................*/

  BEGIN
    DECLARE

      --Vetor de Palavras
      TYPE typ_tab_palavras IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
      vr_tab_palavras typ_tab_palavras;

     --Variaveis Locais
      vr_contador INTEGER;
      vr_nmabrevi VARCHAR2(1000);
      vr_dsdletra VARCHAR2(1000);
      vr_qtdnomes INTEGER;
      vr_qtletini INTEGER;
      vr_eliminar BOOLEAN;
      vr_lssufixo VARCHAR2(1000);
      vr_lsprfixo VARCHAR2(1000);

      --Variavel erro
      vr_dscritic VARCHAR2(1000);
      --Variavel Excecao
      vr_exc_erro EXCEPTION;

    BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.fn_abreviar_string');

      --Nome Abreviado
      vr_nmabrevi:= TRIM(pr_nmdentra);
      vr_eliminar:= FALSE;
      vr_lssufixo:= 'FILHO,NETO,SOBRINHO,JUNIOR,JR.';
      vr_lsprfixo:= 'E/OU';

      WHILE TRUE LOOP
        --Tamanho da string
        vr_qtletini:= LENGTH(vr_nmabrevi);

        --Sair quando atingir quantidade de letras desejada
        IF vr_qtletini <= pr_qtletras THEN
          EXIT;
        END IF;

        --Inicializar Quantidade nomes
        vr_tab_palavras.DELETE;
        vr_qtdnomes:= 1;

        /* Separa os nomes */
        FOR idx IN 1..vr_qtletini LOOP
          --Separar a letra
          vr_dsdletra:= SUBSTR(vr_nmabrevi,idx,1);

          --Contar Palavras
          IF vr_dsdletra <> ' ' THEN
            --Se ja existir
            IF vr_tab_palavras.EXISTS(vr_qtdnomes) THEN
              vr_tab_palavras(vr_qtdnomes):= vr_tab_palavras(vr_qtdnomes)||vr_dsdletra;
            ELSE
              vr_tab_palavras(vr_qtdnomes):= vr_dsdletra;
            END IF;
          ELSE
            vr_qtdnomes:= vr_qtdnomes + 1;
          END IF;
        END LOOP;

        --Verificar se Encontra algum prefixo
        IF instr(vr_lsprfixo,TRIM(vr_tab_palavras(1))) > 0 THEN
          --Concatenar palavras
          IF vr_tab_palavras.EXISTS(1) THEN
            vr_tab_palavras(1):= vr_tab_palavras(1)||' '||vr_tab_palavras(2);
          ELSE
            vr_tab_palavras(1):= vr_tab_palavras(2);
          END IF;

          --Percorrer os nomes
          FOR idx IN 2..vr_qtdnomes LOOP
            vr_tab_palavras(idx):= vr_tab_palavras(idx+1);
          END LOOP;

          --Limpar palavras
          vr_tab_palavras(vr_qtdnomes):= NULL;
          --Diminuir quantidade nomes
          vr_qtdnomes:= vr_qtdnomes-1;
        END IF;

        --Verificar se Encontra algum sufixo
        IF instr(vr_lssufixo,TRIM(vr_tab_palavras(vr_qtdnomes))) > 0 THEN

          IF vr_tab_palavras(vr_qtdnomes) = 'JUNIOR' THEN
            vr_tab_palavras(vr_qtdnomes):= 'JR.';
          END IF;

          --Concatenar palavras
          IF vr_tab_palavras.EXISTS(vr_qtdnomes-1) THEN
            vr_tab_palavras(vr_qtdnomes-1):= vr_tab_palavras(vr_qtdnomes-1)||' '||vr_tab_palavras(vr_qtdnomes);
          ELSE
            vr_tab_palavras(vr_qtdnomes-1):= vr_tab_palavras(vr_qtdnomes);
          END IF;

          --Limpar palavras
          vr_tab_palavras(vr_qtdnomes):= NULL;
          --Diminuir quantidade nomes
          vr_qtdnomes:= vr_qtdnomes-1;
        END IF;

        --Limpar Nome Abreviado
        vr_nmabrevi:= NULL;

        --Percorrer Nomes
        FOR idx IN 1..vr_qtdnomes LOOP
          IF idx <> 1 THEN
            --Concatena espaco
            vr_nmabrevi:= vr_nmabrevi||' '||vr_tab_palavras(idx);
          ELSE
            vr_nmabrevi:= vr_nmabrevi||vr_tab_palavras(idx);
          END IF;
        END LOOP;

        --Se tiver menos de 3 nomes
        IF vr_qtdnomes < 3 THEN
          EXIT;
        END IF;

        --Nome abreviado
        vr_nmabrevi:= vr_tab_palavras(1);
        vr_contador:= 2;

        WHILE TRUE LOOP
          IF LENGTH(vr_tab_palavras(vr_contador)) > 2 THEN
            --Concatenar Nome
            vr_nmabrevi:= vr_nmabrevi ||' '||SUBSTR(vr_tab_palavras(vr_contador),1,1) ||'.';
            EXIT;
          ELSE
            IF vr_eliminar THEN
              vr_eliminar:= FALSE;
            ELSE
              vr_nmabrevi:= vr_nmabrevi ||' '||vr_tab_palavras(vr_contador);
            END IF;
          END IF;
          --Incrementar Contador
          vr_contador:= vr_contador + 1;

          IF vr_contador >= vr_qtdnomes THEN
            --Diminuir Contador
            vr_contador:= vr_contador - 1;
            EXIT;
          END IF;
        END LOOP;

        FOR idx IN (vr_contador + 1)..vr_qtdnomes LOOP
          --Concatenar Nomes
          vr_nmabrevi:= vr_nmabrevi ||' '|| vr_tab_palavras(idx);
        END LOOP;

        --Quantidade Letras igual tamanho nome
        IF vr_qtletini = LENGTH(vr_nmabrevi) THEN
          IF vr_qtdnomes > 2 THEN
            --Eliminar nome
            vr_eliminar:= TRUE;
          ELSE
            EXIT;
          END IF;
        END IF;
      END LOOP;
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);

      --Retonar nome abreviado
      RETURN(vr_nmabrevi);

    EXCEPTION
      WHEN vr_exc_erro THEN
        return(vr_nmabrevi);
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
        CECRED.pc_internal_exception;
        return(vr_nmabrevi);
    END;
  END fn_abreviar_string;

  -- Função para centralizar e preencher texto a direita e esquerda
  FUNCTION fn_centraliza_texto (pr_dstexto  IN VARCHAR2       --> Texto de Entrada
                               ,pr_dscarac  IN VARCHAR2       --> Caracter para preencher
                               ,pr_tamanho  IN INTEGER) RETURN VARCHAR2 IS --> Tamanho da String
  /*............................................................................

   Programa: fn_centraliza_texto
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Alisson
   Data    : Fevereiro/2015                          Ultima atualizacao: 18/10/2017

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Centralizar o texto e preencher com caracteres

   Alteracoes: 24/02/2015 - Conversão Progress --> Oracle (Alisson - AMcom)
               17/10/2017 - Retirado pc_set_modulo
                           (Ana - Envolti - Chamado 776896)
               18/10/2017 - Incluído pc_set_modulo com novo padrão
                            (Ana - Envolti - Chamado 776896)
  .............................................................................*/
  BEGIN
    DECLARE

      --Variaveis Locais
      vr_len      INTEGER;
      vr_qtdcarac INTEGER;
      vr_texto    VARCHAR2(32767);

      --Variavel erro
      vr_dscritic VARCHAR2(1000);
      --Variavel Excecao
      vr_exc_erro EXCEPTION;

    BEGIN
	    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.fn_centraliza_texto');

      --Retirar espacos da string
      vr_texto:= TRIM(pr_dstexto);

      --Tamanho da string
      vr_len:= LENGTH(vr_texto);

      --Se a string passada for maior que a solicitada
      IF vr_len > pr_tamanho THEN
        RETURN(pr_dstexto);
      END IF;

      --Quantidades caracteres a preencher
      vr_qtdcarac:= pr_tamanho - vr_len;

      --Se a quantidade de caracteres a preencher for par
      IF MOD(vr_qtdcarac,2) = 0 THEN
        vr_texto:= lpad(pr_dscarac,(vr_qtdcarac/2),pr_dscarac)||vr_texto||
                   rpad(pr_dscarac,(vr_qtdcarac/2),pr_dscarac);
      ELSE
        vr_texto:= lpad(pr_dscarac,trunc(vr_qtdcarac/2),pr_dscarac)||vr_texto||
                   rpad(pr_dscarac,trunc(vr_qtdcarac/2)+1,pr_dscarac);
      END IF;
      -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);

      --Retonar texto centralizado
      RETURN(vr_texto);

    EXCEPTION
      WHEN OTHERS THEN
        return(pr_dstexto);
    END;
  END fn_centraliza_texto;

  -- Função para retornar o valor em extenso
  FUNCTION fn_valor_extenso (pr_idtipval  IN VARCHAR2   --> Tipo de valor (M-Monetario, P-Porcentagem, I-Inteiro)
                            ,pr_valor     IN VARCHAR2   )  --> Valor a ser convertido para extenso
                            RETURN VARCHAR2 IS
  /*............................................................................

   Programa: fn_valor_extenso (Semelhante a b1wgen9999.valor-extenso)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odirlei Busana - AMcom
   Data    : Fevereiro/2015                          Ultima atualizacao: 18/10/2017

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Retornar o valor em extenso

   Alteracoes: 17/10/2017 - Retirado pc_set_modulo
                           (Ana - Envolti - Chamado 776896)
               18/10/2017 - Incluído pc_set_modulo com novo padrão
                            (Ana - Envolti - Chamado 776896)
  .............................................................................*/
    valor_string VARCHAR2(256);
    valor_conv   VARCHAR2(25);    
    tres_digitos VARCHAR2(3);
    texto_string VARCHAR2(256);
    vr_dsintplu  VARCHAR2(256);
    vr_dsintsin  VARCHAR2(256);
    vr_dsdecplu  VARCHAR2(256);
    vr_dsdecsin  VARCHAR2(256);
    vr_numero    NUMBER;
    
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.fn_valor_extenso');
  
    valor_conv := to_char(trunc((abs(pr_valor) * 100), 0), '0999999999999999999');
    valor_conv := substr(valor_conv, 1, 18) || '0' || substr(valor_conv, 19, 2);
    IF to_number(valor_conv) = 0 THEN
      RETURN('Zero ');
    END IF;
    
    IF pr_idtipval = 'M' THEN
      vr_dsintplu := 'Reais ';  
      vr_dsintsin := 'Real ';
      vr_dsdecplu := 'centavos';  
      vr_dsdecsin := 'centavo';
    ELSIF pr_idtipval = 'P' THEN
      vr_dsintplu := 'Inteiros ';  
      vr_dsintsin := 'Inteiro ';
      vr_dsdecplu := 'por cento';  
      vr_dsdecsin := 'por cento';
    ELSIF pr_idtipval = 'I' THEN
      IF pr_valor < 1 THEN    
        RETURN 'VALOR COM DECIMAIS, NAO COMPATIVEL COM NUMEROS INTEIROS';
      END IF;  
    END IF;
    
    FOR ind IN 1 .. 7 LOOP
      tres_digitos := substr(valor_conv, (((ind - 1) * 3) + 1), 3);
      texto_string := '';
      
      --> Garantir que para qnd informado apenas uma dezena
      --> seja apresentado corretamente
      IF pr_idtipval = 'P' AND 
         ind = 7 AND
         substr(tres_digitos,3,1) = 0 THEN
        tres_digitos := to_char(tres_digitos/10,'fm000');
      END IF; 
      
      -- Extenso para Centena
      IF substr(tres_digitos, 1, 1) = '2' THEN
        texto_string := texto_string || 'Duzentos ';
      ELSIF substr(tres_digitos, 1, 1) = '3' THEN
        texto_string := texto_string || 'Trezentos ';
      ELSIF substr(tres_digitos, 1, 1) = '4' THEN
        texto_string := texto_string || 'Quatrocentos ';
      ELSIF substr(tres_digitos, 1, 1) = '5' THEN
        texto_string := texto_string || 'Quinhentos ';
      ELSIF substr(tres_digitos, 1, 1) = '6' THEN
        texto_string := texto_string || 'Seiscentos ';
      ELSIF substr(tres_digitos, 1, 1) = '7' THEN
        texto_string := texto_string || 'Setecentos ';
      ELSIF substr(tres_digitos, 1, 1) = '8' THEN
        texto_string := texto_string || 'Oitocentos ';
      ELSIF substr(tres_digitos, 1, 1) = '9' THEN
        texto_string := texto_string || 'Novecentos ';
      END IF;
      IF substr(tres_digitos, 1, 1) = '1' THEN
        IF substr(tres_digitos, 2, 2) = '00' THEN
          texto_string := texto_string || 'Cem ';
        ELSE
          texto_string := texto_string || 'Cento ';
        END IF;
      END IF;
      -- Extenso para Dezena
      IF substr(tres_digitos, 2, 1) <> '0' AND
         texto_string IS NOT NULL THEN
        texto_string := texto_string || 'e ';
      END IF;
      IF substr(tres_digitos, 2, 1) = '2' THEN
        texto_string := texto_string || 'Vinte ';
      ELSIF substr(tres_digitos, 2, 1) = '3' THEN
        texto_string := texto_string || 'Trinta ';
      ELSIF substr(tres_digitos, 2, 1) = '4' THEN
        texto_string := texto_string || 'Quarenta ';
      ELSIF substr(tres_digitos, 2, 1) = '5' THEN
        texto_string := texto_string || 'Cinquenta ';
      ELSIF substr(tres_digitos, 2, 1) = '6' THEN
        texto_string := texto_string || 'Sessenta ';
      ELSIF substr(tres_digitos, 2, 1) = '7' THEN
        texto_string := texto_string || 'Setenta ';
      ELSIF substr(tres_digitos, 2, 1) = '8' THEN
        texto_string := texto_string || 'Oitenta ';
      ELSIF substr(tres_digitos, 2, 1) = '9' THEN
        texto_string := texto_string || 'Noventa ';
      END IF;
      IF substr(tres_digitos, 2, 1) = '1' THEN
        IF substr(tres_digitos, 3, 1) <> '0' THEN
          IF substr(tres_digitos, 3, 1) = '1' THEN
            texto_string := texto_string || 'Onze ';
          ELSIF substr(tres_digitos, 3, 1) = '2' THEN
            texto_string := texto_string || 'Doze ';
          ELSIF substr(tres_digitos, 3, 1) = '3' THEN
            texto_string := texto_string || 'Treze ';
          ELSIF substr(tres_digitos, 3, 1) = '4' THEN
            texto_string := texto_string || 'Catorze ';
          ELSIF substr(tres_digitos, 3, 1) = '5' THEN
            texto_string := texto_string || 'Quinze ';
          ELSIF substr(tres_digitos, 3, 1) = '6' THEN
            texto_string := texto_string || 'Dezesseis ';
          ELSIF substr(tres_digitos, 3, 1) = '7' THEN
            texto_string := texto_string || 'Dezessete ';
          ELSIF substr(tres_digitos, 3, 1) = '8' THEN
            texto_string := texto_string || 'Dezoito ';
          ELSIF substr(tres_digitos, 3, 1) = '9' THEN
            texto_string := texto_string || 'Dezenove ';
          END IF;
        ELSE
          texto_string := texto_string || 'Dez ';
        END IF;
      ELSE
        -- Extenso para Unidade
        IF substr(tres_digitos, 3, 1) <> '0' AND
           texto_string IS NOT NULL THEN
          texto_string := texto_string || 'e ';
        END IF;
        IF substr(tres_digitos, 3, 1) = '1' THEN
          texto_string := texto_string || 'Um ';
        ELSIF substr(tres_digitos, 3, 1) = '2' THEN
          texto_string := texto_string || 'Dois ';
        ELSIF substr(tres_digitos, 3, 1) = '3' THEN
          texto_string := texto_string || 'Tres ';
        ELSIF substr(tres_digitos, 3, 1) = '4' THEN
          texto_string := texto_string || 'Quatro ';
        ELSIF substr(tres_digitos, 3, 1) = '5' THEN
          texto_string := texto_string || 'Cinco ';
        ELSIF substr(tres_digitos, 3, 1) = '6' THEN
          texto_string := texto_string || 'Seis ';
        ELSIF substr(tres_digitos, 3, 1) = '7' THEN
          texto_string := texto_string || 'Sete ';
        ELSIF substr(tres_digitos, 3, 1) = '8' THEN
          texto_string := texto_string || 'Oito ';
        ELSIF substr(tres_digitos, 3, 1) = '9' THEN
          texto_string := texto_string || 'Nove ';
        END IF;
      END IF;
      IF to_number(tres_digitos) > 0 THEN
        IF to_number(tres_digitos) = 1 THEN
          IF ind = 1 THEN
            texto_string := texto_string || 'Quatrilhão ';
          ELSIF ind = 2 THEN
            texto_string := texto_string || 'Trilhão ';
          ELSIF ind = 3 THEN
            texto_string := texto_string || 'Bilhão ';
          ELSIF ind = 4 THEN
            texto_string := texto_string || 'Milhão ';
          ELSIF ind = 5 THEN
            texto_string := texto_string || 'Mil ';
          END IF;
        ELSE
          IF ind = 1 THEN
            texto_string := texto_string || 'Quatrilhões ';
          ELSIF ind = 2 THEN
            texto_string := texto_string || 'Trilhões ';
          ELSIF ind = 3 THEN
            texto_string := texto_string || 'Bilhões ';
          ELSIF ind = 4 THEN
            texto_string := texto_string || 'Milhões ';
          ELSIF ind = 5 THEN
            texto_string := texto_string || 'Mil ';
          END IF;
        END IF;
      END IF;
      valor_string := valor_string || texto_string;
      -- Escrita da Moeda Corrente
      IF ind = 5 THEN
        IF to_number(substr(valor_conv, 16, 3)) > 0 AND
           valor_string IS NOT NULL THEN
          valor_string := rtrim(valor_string) || ', ';
        END IF;
      ELSE
        IF ind < 5 AND
           valor_string IS NOT NULL THEN
          valor_string := rtrim(valor_string) || ', ';
        END IF;
      END IF;
      IF ind = 6 THEN
        IF to_number(substr(valor_conv, 1, 18)) > 1 THEN
          IF pr_idtipval = 'P' AND 
             to_number(substr(valor_conv, 20, 2)) = 0 THEN
            valor_string := valor_string || vr_dsdecsin;
          ELSE
            valor_string := valor_string || vr_dsintplu;
          END IF;
        ELSIF to_number(substr(valor_conv, 1, 18)) = 1 THEN
          valor_string := valor_string || vr_dsintsin;
        END IF;

        IF to_number(substr(valor_conv, 20, 2)) > 0 AND
           length(valor_string) > 0 THEN
          valor_string := valor_string || 'e ';
        END IF;
      END IF;
      -- Escrita para Centavos
      IF ind = 7 THEN
        --> Porcentagem deve incrementar texto
        IF pr_idtipval = 'P' THEN
          vr_numero := substr(valor_conv, 20, 2);
          
          IF vr_numero = 10 THEN
            valor_string := valor_string || 'Decimo '||vr_dsdecsin;
          ELSIF substr(vr_numero,2,1) = 0 THEN     
            valor_string := valor_string || 'Decimos '||vr_dsdecsin;
          ELSIF vr_numero = 01 THEN     
            valor_string := valor_string || 'Centesimo  '||vr_dsdecsin; 
          ELSIF vr_numero > 1 THEN     
            valor_string := valor_string || 'Centesimos '||vr_dsdecsin;   
          END IF;
        
        ELSE
          IF to_number(substr(valor_conv, 20, 2)) > 1 THEN
            valor_string := valor_string || vr_dsdecplu;
          ELSIF to_number(substr(valor_conv, 20, 2)) = 1 THEN
            valor_string := valor_string || vr_dsdecsin;
          END IF;
        END IF;
      END IF;
    END LOOP;

    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    RETURN(rtrim(valor_string));
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 18/07/2018 - Chamado 660322
      CECRED.pc_internal_exception; 
      RETURN('*** VALOR INVALIDO ***');
  END;

  -- Procedure para importar arquivo XML para Tabela em memoria
  PROCEDURE pc_arquivo_para_table_of (pr_nmarquiv IN VARCHAR2                     --> Nome do caminho completo)
                                     ,pr_table_of OUT GENE0002.typ_tab_tabela --> Saida para o array
                                     ,pr_des_reto OUT VARCHAR2                    --> Descrição OK/NOK
                                     ,pr_dscritic OUT VARCHAR2)                   --> Descricao Erro
                                     IS
  BEGIN
    DECLARE

      vr_contador  INTEGER;
      vr_setlinha  VARCHAR2(32767);
      --handle de Arquivo
      vr_input_file UTL_FILE.FILE_TYPE;
      --Variavel erro
      vr_dscritic VARCHAR2(1000);
      --Variavel Excecao
      vr_exc_erro EXCEPTION;
      -- caminho e nome do arquivo
      vr_nmdireto  VARCHAR2(500);
      vr_nmarquiv  VARCHAR2(500);

    BEGIN

      /* Verificar se o arquivo existe */
      IF NOT gene0001.fn_exis_arquivo(pr_caminho => pr_nmarquiv) THEN
        vr_dscritic:= 'Arquivo nao encontrado.';
        RAISE vr_exc_erro;
      END IF;

      /* Importar arquivo para retirar caracteres especiais */

      --Abrir o arquivo
      gene0001.pc_abre_arquivo(pr_nmcaminh => pr_nmarquiv   --> Nome do caminho completo
                              ,pr_tipabert => 'R'           --> Somente Leitura
                              ,pr_utlfileh => vr_input_file --> Handle do Arquivo
                              ,pr_des_erro => vr_dscritic); --> Erro
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        --Proximo Registro
        RAISE vr_exc_erro;
      END IF;

      --Inicializar table_of
      pr_table_of.delete;

      --Inicializar Contador
      vr_contador:= 1;

      --Faz leitura das linhas
      LOOP
        BEGIN
          -- Carrega handle do arquivo
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto lido

          --Substituir caracteres especiais da Linha
          vr_setlinha:= inss0001.fn_substitui_caracter(vr_setlinha);

          --Retirar Sujeira Inicio do arquivo
          IF vr_contador = 1 THEN
            vr_setlinha:= substr(vr_setlinha,instr(vr_setlinha,'<?xml'));
          END IF;

          --Se a linha possuir informacao
          IF vr_setlinha IS NOT NULL THEN
            IF INSTR(vr_setlinha,'<opt')      > 0
            OR INSTR(vr_setlinha,'<SISARQ')   > 0
            OR INSTR(vr_setlinha,'</SISARQ>') > 0
            OR INSTR(vr_setlinha,'<BCARQ')    > 0
            OR INSTR(vr_setlinha,'</opt>')    > 0
            OR INSTR(vr_setlinha,'<Grupo_')   > 0
            THEN
              --Colocar linha convertida no table_of
              pr_table_of(vr_contador).dslinha := vr_setlinha;
            ELSE
              vr_contador := vr_contador - 1;
              --Concatenar linha convertida com a linha anterior no table_of
              pr_table_of(vr_contador).dslinha := pr_table_of(vr_contador).dslinha
                                               || vr_setlinha;
            END IF;
          END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            --Acabaram as linhas do arquivo

            --Fechar o arquivo de leitura
            IF utl_file.is_open(vr_input_file) THEN
              gene0001.pc_fecha_arquivo(vr_input_file);
            END IF;

            --Sair do LOOP
            EXIT;
          WHEN OTHERS THEN
            --Erro no processamento
            vr_dscritic:= 'Erro ao processar arquivo '||pr_nmarquiv||' - '||SQLERRM;

            --Fechar o arquivo de leitura
            IF utl_file.is_open(vr_input_file) THEN
              gene0001.pc_fecha_arquivo(vr_input_file);
            END IF;

            --Levantar Excecao Proximo
            RAISE vr_exc_erro;
        END;
        --Incrementar Contador
        vr_contador:= vr_contador+1;
      END LOOP;
    END;
  END pc_arquivo_para_table_of;

  PROCEDURE pc_transf_arq_smartshare(pr_nmdiretorio IN VARCHAR2  --> diretorio local, onde esta o arquivo a ser copiado
                                    ,pr_nmarquiv IN VARCHAR2     --> nome do arquivo a ser copiado                                   
                                    ,pr_cdcooper IN crapcop.cdcooper%TYPE --> codigo da cooperativa
                                    ,pr_des_reto OUT VARCHAR2 --> Descrição OK/NOK
                                    ,pr_dscritic OUT VARCHAR2 --> Descricao Erro
                                    ) IS
   /* ----------------------------------------------------------------------------------------

    Programa: EMPR0019 
    Autor   : Rafael R. Santos / AMcom 
    Data    : 18/04/2019    ultima Atualizacao: -- 
     
    Dados referentes ao programa:
   
    Objetivo  : mover arquivo para o ftp do smartshare
   
    Alteracoes: 30/04/2019 - PRJ438 Removido controles de transação. (Douglas Pagel / AMcom).
				
                08/08/2019 - PRJ438 Buscar o diretório local conforme parametro. (Douglas Pagel / AMcom).
				

    ..........................................................................................*/
    --/
  BEGIN
    
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(1000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      vr_serv_ftp    VARCHAR2(100);
      vr_user_ftp    VARCHAR2(100);
      vr_pass_ftp    VARCHAR2(100);
      
      vr_nmarquiv      VARCHAR2(100);
      vr_diames        VARCHAR2(100);
      vr_dir_local     VARCHAR2(100);
      vr_dir_remoto    VARCHAR2(100);

      vr_script_ftp    VARCHAR2(600);

      -- Cursor genérico de calendário
      rw_crapdat BTCH0001.CR_CRAPDAT%ROWTYPE;
      
      vr_idprglog PLS_INTEGER  := 0;
    
      PROCEDURE pc_processa_arquivo(pr_nmarquiv IN VARCHAR2              --> Nome arquivo a enviar/ String de busca do arquivo a receber
                                   ,pr_idoperac IN VARCHAR2              --> E - Envio de Arquivo, R - Retorno de arquivo
                                   ,pr_nmdireto IN VARCHAR2              --> Diretório do arquivo a enviar
                                   ,pr_idenvseg IN crapcrb.idtpreme%TYPE --> Indicador de utilizacao de protocolo seguro (SFTP)
                                   ,pr_ftp_site IN VARCHAR2              --> Site de acesso ao FTP
                                   ,pr_ftp_user IN VARCHAR2              --> Usuário para acesso ao FTP
                                   ,pr_ftp_pass IN VARCHAR2              --> Senha para acesso ao FTP
                                   ,pr_ftp_path IN VARCHAR2              --> Pasta no FTP para envio do arquivo
                                   ,pr_dscritic OUT VARCHAR2) IS         --> Retorno de crítica

        -- Variável de críticas
        vr_cdcritic      crapcri.cdcritic%type := 0;
        vr_dscritic VARCHAR2(1000);

        -- Tratamento de erros
        vr_exc_saida EXCEPTION;
          
        vr_serv_ftp    VARCHAR2(100);
        vr_user_ftp    VARCHAR2(100);
        vr_pass_ftp    VARCHAR2(100);
          
        vr_nmarquiv      VARCHAR2(100);
        vr_diames        VARCHAR2(100);
        vr_dir_local     VARCHAR2(100);
        vr_dir_remoto    VARCHAR2(100);

        vr_script_ftp    VARCHAR2(600);

        -- Cursor genérico de calendário
        rw_crapdat BTCH0001.CR_CRAPDAT%ROWTYPE;

        vr_jobname  VARCHAR2(40) := 'jbepr_transf_smartshare';
        vr_idprglog PLS_INTEGER  := 0;
      --/
      BEGIN
        DECLARE
        
          vr_arquivo_log VARCHAR2(1000); --> Diretório do log do FTP
          vr_script_ftp  VARCHAR2(1000); --> Script FTP
          vr_comand_ftp  VARCHAR2(4000); --> Comando montado do envio ao FTP
          vr_typ_saida   VARCHAR2(3);    --> Saída de erro
          vr_dsparame    VARCHAR2(2000);
          --/
        BEGIN
          --
          -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'EMPR0019.pc_processa_arquivo_ftp');
          --/
          vr_dsparame := ' - pr_nmarquiv:'||pr_nmarquiv||
                         ', pr_idoperac:'||pr_idoperac||
                         ', pr_nmdireto:'||pr_nmdireto||
                         ', pr_idenvseg:'||pr_idenvseg||
                         ', pr_ftp_site:'||pr_ftp_site||
                         ', pr_ftp_user:'||pr_ftp_user||
                         ', pr_ftp_pass:'||pr_ftp_pass||
                         ', pr_ftp_path:'||pr_ftp_path;

          --Chama script específico para conexão de ftp segura
          IF pr_idenvseg = 'S' THEN
            vr_script_ftp := gene0001.fn_param_sistema('CRED',0,'AUTBUR_SCRIPT_SFTP');
          ELSE
            -- Buscar script para conexão FTP
            vr_script_ftp := gene0001.fn_param_sistema('CRED',0,'AUTBUR_SCRIPT_FTP');
          END IF;
          
          -- Gera o diretório do arquivo de log
          vr_arquivo_log :=  gene0001.fn_diretorio(pr_tpdireto => 'C'
                                                  ,pr_cdcooper => pr_cdcooper
                                                  ,pr_nmsubdir => '/log') || '/proc_autbur.log'; 

          vr_arquivo_log :=  replace(replace(SRCSTR => vr_arquivo_log, OLDSUB => 'cooph6', NEWSUB => 'coop'),'coopl','coop');

          -- Preparar o comando de conexão e envio ao FTP
          vr_comand_ftp := vr_script_ftp
                        || CASE pr_idoperac WHEN 'E' THEN ' -envia' ELSE ' -recebe' END
                        || ' -srv '          || pr_ftp_site
                        || ' -usr '          || pr_ftp_user
                        || ' -pass '         || pr_ftp_pass
                        || ' -arq '          || CHR(39) || pr_nmarquiv || CHR(39)
                        || ' -dir_local '    || CHR(39) || pr_nmdireto || CHR(39)
                        || ' -dir_remoto '   || CHR(39) || pr_ftp_path || CHR(39)
                        || ' -log ' || vr_arquivo_log;

          -- Chama procedure de envio e recebimento via ftp
          GENE0001.pc_OScommand_Shell(pr_des_comando => vr_comand_ftp
                                     ,pr_typ_saida   => vr_typ_saida
                                     ,pr_des_saida   => pr_dscritic);

          -- Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
            RETURN;
          END IF;

          -- Limpa nome do modulo logado - 29/11/2017 - Ch 788828    
          GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 29/11/2017 - Ch 788828 
            CECRED.pc_internal_exception;

            -- Retorna o erro para a procedure chamadora
            vr_cdcritic := 9999;
            pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'empr0019.pc_processa_arquivo_ftp. '||SQLERRM||'. '||vr_dsparame;
        END;

      END pc_processa_arquivo;
      

    BEGIN
    
      -- Buscar a data do movimento
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;

      -- Verificar se existe informação, e gerar erro caso não exista
      IF btch0001.cr_crapdat%NOTFOUND THEN

        -- Fechar o cursor
        CLOSE btch0001.cr_crapdat;

        -- Gerar exceção
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        RAISE vr_exc_saida;
      END IF;
      CLOSE btch0001.cr_crapdat;

      -- Busca nome do servidor
      vr_serv_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'TRAN_CCB_SERV_FTP');
      -- Busca nome de usuario
      vr_user_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'TRAN_CCB_USR_FTP');
      -- Busca senha do usuario
      vr_pass_ftp := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'TRAN_CCB_PASS_FTP');
      -- Busca diretório remoto
      vr_dir_remoto := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => '0'
                                                ,pr_cdacesso => 'TRAN_CCB_DIR_FTP');
      -- Busca diretotio local da cooperativa
      vr_dir_local := replace(replace(pr_nmdiretorio,'cooph6','coop'),'coopl','coop'); 
      
      -- Busca script FTP                                 
      vr_script_ftp := gene0001.fn_param_sistema('CRED',0,'AUTBUR_SCRIPT_FTP');

      -- Seta o nome do arquivo
      vr_nmarquiv := pr_nmarquiv;

      --/ Inicia processamento do arquivo
      pc_processa_arquivo(pr_nmarquiv => vr_nmarquiv        --> Nome arquivo a enviar
                         ,pr_idoperac => 'E'                --> Envio de arquivo
                         ,pr_nmdireto => vr_dir_local       --> Diretório do arquivo a enviar
                         ,pr_idenvseg => 'N'                --> Indicador de utilizacao de protocolo seguro (SFTP)
                         ,pr_ftp_site => vr_serv_ftp        --> Site de acesso ao FTP
                         ,pr_ftp_user => vr_user_ftp        --> Usuário para acesso ao FTP
                         ,pr_ftp_pass => vr_pass_ftp        --> Senha para acesso ao FTP
                         ,pr_ftp_path => vr_dir_remoto      --> Pasta no FTP para envio do arquivo
                         ,pr_dscritic => vr_dscritic);      --> Retorno de crítica

        -- Se ocorrer algum erro
        IF vr_dscritic IS NOT NULL THEN
           RAISE vr_exc_saida;
        END IF;

      pr_des_reto := 'OK';
        
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_des_reto := 'NOK';
        pr_dscritic := vr_dscritic;
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3 --> Sempre na Cecred
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'HH24:MI:SS') || 
                                                      ' - empr0019.pc_transf_ccb_smartshare Erro ao efetuar transf de arquivo: ' || vr_dscritic
                                  ,pr_dstiplog   => 'E'
                                  ,pr_cdprograma => NULL);
      WHEN OTHERS THEN
        pr_des_reto := 'NOK';        
        pr_dscritic := vr_dscritic;        
        cecred.pc_internal_exception;
      
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3 --> Sempre na Cecred
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'HH24:MI:SS') || 
                                                      ' - CONV0001.pc_transf_ccb_smartshare Erro ao efetuar download de arquivo: ' || SQLERRM
                                  ,pr_dstiplog   => 'E'
                                  ,pr_cdprograma => NULL);
    END ;

  END pc_transf_arq_smartshare;


END GENE0002;
/
