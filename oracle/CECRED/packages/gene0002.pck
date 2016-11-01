CREATE OR REPLACE PACKAGE CECRED.gene0002 AS

  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : GENE0002
    Sistema  : Rotinas gen�ricas para mascaras e relat�rios
    Sigla    : GENE
    Autor    : Marcos E. Martini - Supero
    Data     : Novembro/2012.                   Ultima atualizacao: 05/02/2016
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Definir variaveis e fun��es para auxilio de mascaras e rotinas de relat�rios
                
               27/02/2015 - Incluido o nome do arquivo .pdf no retorno da variavel pr_nmarqpdf,
                            feito tratamento para arquivos .lst na procedure pc_envia_arquivo_web
                            (Jean Michel).                  
  
               22/09/2015 - Adicionar valida��o na procedure pc_solicita_relato para quando o 
                            relatorio for solicitado durante o processo batch, o erro seja escrito
                            no proc_batch, caso contrario no proc_message (Douglas - Chamado 306525)

               05/02/2016 - Realizado ajustes na rotina para efetuar a copia 
                            correta dos arquivos para a intranet
                            (Adriano ).
  ------------------------------------------------------------------------------------------------------------------*/

  /* Tabela de mem�ria para armazenar os separadores de milhar e casas decimais
     limitando o n�mero de execu��es do contexto SQL para buscar estes parametros
     melhorando a performance */
  TYPE typ_reg_nlspar IS
    RECORD(dssepmil VARCHAR2(1)
          ,dssepdec VARCHAR2(1));
  TYPE typ_tab_nlspar IS TABLE OF typ_reg_nlspar INDEX BY PLS_INTEGER;
  vr_nlspar typ_tab_nlspar;

  /* Fun��o gen�rica para aplicar uma maskara ao conteudo passado */
  FUNCTION fn_mask(pr_dsorigi IN VARCHAR2
                  ,pr_dsforma IN VARCHAR2) RETURN VARCHAR2;

  /* Fun��o para mascarar o Nro da Conta */
  FUNCTION fn_mask_conta(pr_nrdconta IN crapass.nrdconta%TYPE) RETURN VARCHAR2;

  /* Fun��o para mascarar a Conta Integra��o */
  FUNCTION fn_mask_ctitg(pr_nrdctitg IN crapass.nrdctitg%TYPE) RETURN VARCHAR2;

  /* Fun��o para mascarar o CPF ou CNPJ */
  FUNCTION fn_mask_cpf_cnpj(pr_nrcpfcgc IN crapass.nrcpfcgc%type,
                            pr_inpessoa in crapass.inpessoa%type) RETURN VARCHAR2;

  /* Fun��o para mascarar o CEP */
  FUNCTION fn_mask_cep(pr_nrcepend IN crapenc.nrcepend%TYPE) RETURN VARCHAR2;

  /* Fun��o para mascarar a matr�cula */
  FUNCTION fn_mask_matric(pr_nrmatric IN crapass.nrmatric%TYPE) RETURN VARCHAR2;

  /* Fun��o para mascarar o contrato */
  FUNCTION fn_mask_contrato(pr_nrcontrato IN crapepr.nrctremp%TYPE) RETURN VARCHAR2;

  /* Calcular as horas e minutos com base nos segundos informados */
  FUNCTION fn_calc_hora(pr_segundos IN PLS_INTEGER) RETURN VARCHAR2;    --> Segundos decorridos

  /* Fun�ao para testar se a vari�vel cont�m num�ricos */
  FUNCTION fn_numerico(pr_vlrteste IN VARCHAR2) RETURN BOOLEAN;

  /* Retonar um determinado dado de uma string separado por um delimitador */
  FUNCTION fn_busca_entrada(pr_postext     IN NUMBER                          --> Posicao do parametro desejada
                           ,pr_dstext      IN VARCHAR2                        --> Texto a ser analisado
                           ,pr_delimitador IN VARCHAR2) RETURN VARCHAR2;      --> Delimitador utilizado na string

  /* Declara��o de tipo para suprir necessidade da fun��o de quebra de strings */
  TYPE typ_split IS TABLE OF VARCHAR2(32767);

  /* Quebra string com base no delimitador e retorna array de resultados */
  FUNCTION fn_quebra_string(pr_string   IN VARCHAR2                             --> String que ser� quebrada
                           ,pr_delimit  IN CHAR DEFAULT ',') RETURN typ_split;  --> Delimitador com valor default

  /* Pesquisa por valor informado quebrando a busca pelo delimitador passado */
  FUNCTION fn_existe_valor(pr_base      IN VARCHAR2                    --> String que ir� sofrer a busca
                          ,pr_busca     IN VARCHAR2                    --> String objeto de busca
                          ,pr_delimite  IN VARCHAR2) RETURN VARCHAR2;  --> String que ser� o delimitador

  /* Pesquisa no texto pelas strings de procura sem observar a ordem das mesmas */
  FUNCTION fn_contem(pr_dstexto in varchar2                   --> String que ir� sofrer a busca
                    ,pr_dsprocu in varchar2) RETURN VARCHAR2; --> String objeto de busca

  /* Fun��o para converter um arquivo em BLOB */
  FUNCTION fn_arq_para_blob(pr_caminho IN VARCHAR2
                           ,pr_arquivo IN VARCHAR2) RETURN BLOB;

  /* Fun��o para converter um arquivo em CLOB */
  FUNCTION fn_arq_para_clob(pr_caminho IN VARCHAR2
                           ,pr_arquivo IN VARCHAR2) RETURN CLOB;

  /* Procedure para gravar os dados de um BLOB para um arquivo */
  PROCEDURE pc_blob_para_arquivo(pr_blob      IN BLOB     --> Blob com os dados
                                ,pr_caminho   IN VARCHAR2 --> Diret�rio para sa�da
                                ,pr_arquivo   IN VARCHAR2 --> Nome do arquivo de sa�da
                                ,pr_des_erro OUT VARCHAR2);

  /* Procedure para gravar os dados de um CLOB para um arquivo */
  PROCEDURE pc_clob_para_arquivo(pr_clob      IN CLOB     --> Blob com os dados
                                ,pr_caminho   IN VARCHAR2 --> Diret�rio para sa�da
                                ,pr_arquivo   IN VARCHAR2 --> Nome do arquivo de sa�da
                                ,pr_flappend  IN VARCHAR2 DEFAULT 'N' --> Indica que a solicita��o ir� incrementar o arquivo
                                ,pr_des_erro OUT VARCHAR2);

  /**  Procedure para copiar arquivo PDF para o sistema ayllos web   **/
  PROCEDURE pc_efetua_copia_pdf (pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa conectada
                                ,pr_cdagenci IN INTEGER                   --> Codigo da agencia para erros
                                ,pr_nrdcaixa IN INTEGER                   --> Codigo do caixa para erros
                                ,pr_nmarqpdf IN VARCHAR2                  --> Arquivo PDF  a ser gerado                                 
                                ,pr_des_reto OUT VARCHAR2                 --> Sa�da com erro
                                ,pr_tab_erro OUT gene0001.typ_tab_erro);  --> tabela de erros

  /** Procedure para copiar arquivos para o sistema InternetBank **/
  PROCEDURE pc_efetua_copia_arq_ib(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa conectada
                                  ,pr_nmarqpdf IN VARCHAR2                  --> Arquivo a ser enviado
                                  ,pr_des_erro OUT VARCHAR2);               --> Sa�da com erro
  
  --> Publicar arquivo de controle na intranet
  PROCEDURE pc_publicar_arq_intranet;   
  
  /* Procedure para converter proposta para o formato PDF */
  PROCEDURE pc_gera_pdf_impressao(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa conectada
                                 ,pr_nmarqimp IN VARCHAR2                  --> Arquivo a ser convertido para pDf
                                 ,pr_nmarqpdf IN VARCHAR2                  --> Arquivo PDF  a ser gerado                                 
                                 ,pr_des_erro OUT VARCHAR2);               --> Sa�da com erro
  
  /* Procedimento para gera��o de PDFs */
  PROCEDURE pc_cria_PDF(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa conectada
                       ,pr_nmorigem IN VARCHAR2                  --> Path arquivo origem
                       ,pr_ingerenc IN VARCHAR2                  --> SIM/NAO
                       ,pr_tirelato IN VARCHAR2                  --> Tipo (80col, etc..)
                       ,pr_dtrefere IN DATE  DEFAULT NULL        --> Data de referencia
                       ,pr_nmsaida  OUT VARCHAR2                 --> Path do arquivo gerado
                       ,pr_des_erro OUT VARCHAR2);               --> Sa�da com erro

  /* Procedimento para tratamento de arquivos ZIP*/
  PROCEDURE pc_zipcecred(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Cooperativa conectada
                        ,pr_tpfuncao  IN VARCHAR2 DEFAULT 'A'      --> Tipo de fun��o (A-Add;E-Extract;V-View)
                        ,pr_dsorigem  IN VARCHAR2                  --> Lista de arquivos a compactar (separados por espa�o) ou arquivo a descompactar
                        ,pr_dsdestin  IN VARCHAR2                  --> Caminho para o arquivo Zip a gerar ou caminho de destino dos arquivos descompactados
                        ,pr_dspasswd  IN VARCHAR2                  --> Password a incluir no arquivo
                        ,pr_flsilent  IN VARCHAR2 DEFAULT 'S'      --> Se a chamada ter� retorno ou n�o a tela
                        ,pr_des_erro OUT VARCHAR2);

  /* Rotina de Impress�o de Arquivos (antiga imprim.p) */
  PROCEDURE pc_imprim(pr_cdcooper    IN crapcop.cdcooper%TYPE  --> Cooperativa conectada
                     ,pr_cdprogra    IN VARCHAR2               --> Nome do programa que est� executando
                     ,pr_cdrelato    IN craprel.cdrelato%TYPE  --> C�digo do relat�rio solicitado
                     ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE  --> Data movimento atual
                     ,pr_caminho     IN VARCHAR2               --> Path arquivo origem
                     ,pr_nmarqimp    IN VARCHAR2               --> Nome arquivo para impressao
                     ,pr_nmformul    IN VARCHAR2               --> Nome do formul�rio de impress�o
                     ,pr_nrcopias    IN NUMBER                 --> Quantidade de Copias desejadas
                     ,pr_dircop_pdf OUT VARCHAR2               --> Retornar o path de gera��o do PDF
                     ,pr_cdcritic   OUT NUMBER                 --> Retornar c�digo do erro
                     ,pr_dscritic   OUT VARCHAR2);             --> Retornar descri��o do erro

  /* Rotina para extra��o do tempo */
  FUNCTION fn_busca_time RETURN NUMBER;

  /* Retonar a data a partir do numero de segundos */
  FUNCTION fn_converte_time_data(pr_nrsegs IN INTEGER
                                ,pr_tipsaida IN VARCHAR2 DEFAULT 'M') RETURN VARCHAR2; --Retorna data em minutos ou segundos

  /* Incluir log de gera��o de relat�rios. */
  PROCEDURE pc_gera_log_relato(pr_cdcooper IN crapcop.cdcooper%TYPE       --> Cooperativa conectada
                              ,pr_des_log IN VARCHAR2);

  /* Rotina para gerar um arquivo do XMLType passado */
  PROCEDURE pc_XML_para_arquivo(pr_XML       IN OUT NOCOPY XMLtype  --> Inst�ncia do XML Type
                               ,pr_caminho   IN VARCHAR2            --> Diret�rio para sa�da
                               ,pr_arquivo   IN VARCHAR2            --> Nome do arquivo de sa�da
                               ,pr_des_erro OUT VARCHAR2);          --> Variavel de retorno de Erro

  /* Rotina para gerar um arquivo do CLOB passado */
  PROCEDURE pc_XML_para_arquivo(pr_XML       IN OUT NOCOPY CLOB     --> Inst�ncia do CLOB
                               ,pr_caminho   IN VARCHAR2            --> Diret�rio para sa�da
                               ,pr_arquivo   IN VARCHAR2            --> Nome do arquivo de sa�da
                               ,pr_des_erro OUT VARCHAR2);          --> Variavel de retorno de Erro

  /* Procedimento que processa os relat�rios pendentes e chama sua gera��o */
  PROCEDURE pc_process_relato_penden(pr_nrseqsol IN crapslr.nrseqsol%TYPE DEFAULT NULL --> Processar somente a sequencia passada
                                    ,pr_cdfilrel IN crapslr.cdfilrel%TYPE DEFAULT NULL --> Processar todas as sequencias da fila
                                    ,pr_des_erro OUT VARCHAR2);

  /* Rotina para solicitar gera��o de relatorio em PDF a partir de um XML de dados */
  PROCEDURE pc_solicita_relato(pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Cooperativa conectada
                              ,pr_cdprogra  IN crapprg.cdprogra%TYPE    --> Programa chamador
                              ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE    --> Data do movimento atual
                              ,pr_dsxml     IN OUT NOCOPY CLOB          --> Arquivo XML de dados
                              ,pr_dsxmlnode IN VARCHAR2                 --> N� do XML para itera��o
                              ,pr_dsjasper  IN VARCHAR2                 --> Arquivo de layout do iReport
                              ,pr_dsparams  IN VARCHAR2                 --> Array de parametros diversos
                              ,pr_dsarqsaid IN VARCHAR2                 --> Path/Nome do arquivo PDF gerado
                              ,pr_flg_gerar IN VARCHAR2 DEFAULT 'N'     --> Gerar o arquivo na hora
                              ,pr_qtcoluna  IN NUMBER                   --> Qtd colunas do relat�rio (80,132,234)
                              ,pr_sqcabrel  IN NUMBER DEFAULT 1         --> Sequencia do relatorio (cabrel 1..5)
                              ,pr_cdrelato  IN NUMBER DEFAULT NULL      --> C�digo fixo para o relat�rio (nao busca pelo sqcabrel)
                              ,pr_cdfilrel  IN VARCHAR2 DEFAULT NULL    --> Fila para o relat�rio
                              ,pr_nrseqpri  IN NUMBER DEFAULT NULL      --> Prioridade para o relat�rio (0..5)
                              ,pr_flg_impri IN VARCHAR2 DEFAULT 'N'     --> Chamar a impress�o (Imprim.p)
                              ,pr_nmformul  IN VARCHAR2 DEFAULT NULL    --> Nome do formul�rio para impress�o
                              ,pr_nrcopias  IN NUMBER   DEFAULT NULL    --> N�mero de c�pias para impress�o
                              ,pr_dspathcop IN VARCHAR2 DEFAULT NULL    --> Lista sep. por ';' de diret�rios a copiar o relat�rio
                              ,pr_dsextcop  IN VARCHAR2 DEFAULT NULL    --> Extens�o para c�pia do relat�rio aos diret�rios
                              ,pr_fldoscop  IN VARCHAR2 DEFAULT 'N'     --> Flag para converter o arquivo gerado em DOS antes da c�pia
                              ,pr_dscmaxcop IN VARCHAR2 DEFAULT NULL    --> Comando auxiliar para o comando ux2dos na c�pia de diret�rio
                              ,pr_dsmailcop IN VARCHAR2 DEFAULT NULL    --> Lista sep. por ';' de emails para envio do relat�rio
                              ,pr_dsassmail IN VARCHAR2 DEFAULT NULL    --> Assunto do e-mail que enviar� o relat�rio
                              ,pr_dscormail IN VARCHAR2 DEFAULT NULL    --> HTML corpo do email que enviar� o relat�rio
                              ,pr_dsextmail IN VARCHAR2 DEFAULT NULL    --> Extens�o para envio do relat�rio
                              ,pr_fldosmail IN VARCHAR2 DEFAULT 'N'     --> Flag para converter o arquivo gerado em DOS antes do e-mail
                              ,pr_dscmaxmail IN VARCHAR2 DEFAULT NULL    --> Comando auxiliar para o comando ux2dos no envio de e-mail
                              ,pr_flgremarq IN VARCHAR2 DEFAULT 'N'     --> Flag para remover o arquivo ap�s c�pia/email
                              ,pr_flsemqueb IN VARCHAR2 DEFAULT 'N'     --> Flag S/N para n�o gerar quebra no relat�rio
                              ,pr_flappend  IN VARCHAR2 DEFAULT 'N'     --> Indica que a solicita��o ir� incrementar o arquivo
                              ,pr_parser    IN VARCHAR2 DEFAULT 'D'     --> Seleciona o tipo do parser. "D" para VTD e "R" para Jasper padr�o
                              ,pr_des_erro  OUT VARCHAR2);              --> Sa�da com erro

  /* Rotina para solicitar gera��o de arquivo lst a partir de um XML de dados */
  PROCEDURE pc_solicita_relato_arquivo(pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Cooperativa conectada
                                      ,pr_cdprogra  IN crapprg.cdprogra%TYPE    --> Programa chamador
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE    --> Data do movimento atual
                                      ,pr_dsxml     IN OUT NOCOPY CLOB          --> Arquivo XML de dados
                                      ,pr_dsarqsaid IN VARCHAR2                 --> Path/Nome do arquivo PDF gerado
                                      ,pr_cdrelato  IN NUMBER DEFAULT NULL      --> C�digo fixo para o relat�rio
                                      ,pr_flg_impri IN VARCHAR2 DEFAULT 'N'     --> Chamar a impress�o (Imprim.p)
                                      ,pr_flg_gerar IN VARCHAR2 DEFAULT 'N'     --> Gerar o arquivo na hora
                                      ,pr_nmformul  IN VARCHAR2 DEFAULT NULL    --> Nome do formul�rio para impress�o
                                      ,pr_nrcopias  IN NUMBER   DEFAULT NULL    --> N�mero de c�pias para impress�o
                                      ,pr_dspathcop IN VARCHAR2 DEFAULT NULL    --> Lista sep. por ';' de diret�rios a copiar o arquivo
                                      ,pr_fldoscop  IN VARCHAR2 DEFAULT 'N'     --> Flag para converter o arquivo gerado em DOS antes da c�pia
                                      ,pr_dscmaxcop IN VARCHAR2 DEFAULT NULL    --> Comando auxiliar para o comando ux2dos na c�pia de diret�rio
                                      ,pr_dsextcop  IN VARCHAR2 DEFAULT NULL    --> Extens�o para c�pia do relat�rio aos diret�rios
                                      ,pr_dsmailcop IN VARCHAR2 DEFAULT NULL    --> Lista sep. por ';' de emails para envio do arquivo
                                      ,pr_dsassmail IN VARCHAR2 DEFAULT NULL    --> Assunto do e-mail que enviar� o arquivo
                                      ,pr_dscormail IN VARCHAR2 DEFAULT NULL    --> HTML corpo do email que enviar� o arquivo
                                      ,pr_dsextmail IN VARCHAR2 DEFAULT NULL    --> Extens�o para envio do relat�rio
                                      ,pr_fldosmail IN VARCHAR2 DEFAULT 'N'     --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                      ,pr_dscmaxmail IN VARCHAR2 DEFAULT NULL    --> Comando auxiliar para o comando ux2dos no envio de e-mail
                                      ,pr_flgremarq IN VARCHAR2 DEFAULT 'N'     --> Flag para remover o arquivo ap�s c�pia/email
                                      ,pr_flappend  IN VARCHAR2 DEFAULT 'N'     --> Indica que a solicita��o ir� incrementar o arquivo
                                      ,pr_des_erro  OUT VARCHAR2);              --> Sa�da com erro


  /* Procedimento que gerencia as filas de relat�rios e controla seus jobs */
  PROCEDURE pc_controle_filas_relato;

  /* Fun��o para processar uma string que cont�m um valor e retorn�-lo em number  */
  FUNCTION fn_char_para_number(pr_dsnumtex IN varchar2) RETURN NUMBER;


  /* Calcular a diferen�a entre duas datas e retornar diferen�a em hh:mi:ss */
  FUNCTION fn_calc_difere_datas(pr_dtinicio IN DATE
                               ,pr_dttermin IN DATE) RETURN VARCHAR2;

  /* Procedure para controlar buferiza��o de um CLOB */
  PROCEDURE pc_clob_buffer(pr_dados   IN OUT NOCOPY VARCHAR2       --> Buffer de dados
                          ,pr_btam    IN PLS_INTEGER DEFAULT 32600 --> Determina o tamanho do buffer
                          ,pr_gravfim IN BOOLEAN                   --> Verifica se � grava��o final do buffer
                          ,pr_clob    IN OUT NOCOPY CLOB);         --> Clob de grava��o

  -- Subrotina para escrever texto na vari�vel CLOB do XML
  procedure pc_escreve_xml(pr_xml in out nocopy clob,
                           pr_texto_completo in out nocopy varchar2,
                           pr_texto_novo in varchar2,
                           pr_fecha_xml in boolean default false);

  /* Procedure para copiar arquivos para a intranet */
  PROCEDURE pc_gera_arquivo_intranet(pr_cdcooper IN PLS_INTEGER                --> C�digo da cooperativa
                                    ,pr_cdagenci IN PLS_INTEGER                --> C�digo da agencia
                                    ,pr_dtmvtolt IN DATE                       --> Data de movimento
                                    ,pr_nmarqimp IN VARCHAR2                   --> Nome arquivo de impress�o
                                    ,pr_nmformul IN VARCHAR2                   --> Nome do formul�rio
                                    ,pr_dscritic OUT VARCHAR2                  --> Descri��o da cr�tica
                                    ,pr_tab_erro IN OUT GENE0001.typ_tab_erro  --> Tabela com erros
                                    ,pr_des_erro OUT VARCHAR2);                --> Retorno de erros no processo

  /* Fun�ao para testar se a vari�vel � uma data valida */
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
                                ,pr_des_reto OUT VARCHAR2      --> Descri��o OK/NOK
                                ,pr_dscritic OUT VARCHAR2);    --> Descricao Erro    
                                
  -- Fun��o para abreviar string
  FUNCTION fn_abreviar_string (pr_nmdentra IN VARCHAR2                  --> Nome de Entrada
                              ,pr_qtletras IN INTEGER) RETURN VARCHAR2; --> Quantidade de Letras                                

  -- Fun��o para centralizar e preencher texto a direita e esquerda
  FUNCTION fn_centraliza_texto (pr_dstexto  IN VARCHAR2       --> Texto de Entrada
                               ,pr_dscarac  IN VARCHAR2       --> Caracter para preencher 
                               ,pr_tamanho  IN INTEGER) RETURN VARCHAR2; --> Tamanho da String
END gene0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.gene0002 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : GENE0002
  --  Sistema  : Rotinas gen�ricas para mascaras e relat�rios
  --  Sigla    : GENE
  --  Autor    : Marcos E. Martini - Supero
  --  Data     : Novembro/2012.                   Ultima atualizacao: 26/10/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Definir variaveis e fun��es para auxilio de mascaras e rotinas de relat�rios
  --
  -- Altera��es: 21/01/2015 - Alterado o formato do campo nrctremp para 8
  --                          caracters (Kelvin - 233714)
  --
  --             27/02/2015 - Incluido o nome do arquivo .pdf no retorno da variavel pr_nmarqpdf,
  --                          feito tratamento para arquivos .lst na procedure pc_envia_arquivo_web
  --                          (Jean Michel).
  --
  --             22/09/2015 - Adicionar valida��o na procedure pc_solicita_relato para quando o
  --                          relatorio for solicitado durante o processo batch, o erro seja escrito
  --                          no proc_batch, caso contrario no proc_message (Douglas - Chamado 306525)
  --
  --             11/03/2016 - Na procedure pc_gera_relato ao ocorrer erro na exclus�o do xml foi modificado
  --                          para logar no proc_message e n�o mais no proc_batch conforme solicitado
  --                          no chamado 411723 (Kelvin)                                 
  --
  --             05/04/2016 - Ajuste para retirar o "*" ao remover o arquivo
  --                          (Adriano).        
  --
  --             29/09/2016 - #523947 No procedimento pc_controle_filas_relato, inclu�do log de in�cio, fim e 
  --                          erro na execu��o do job (Carlos)
  --
  --             26/10/2016 - Gravado em log a execu��o da rotina procedimento pc_controle_filas_relato apenas
  --                          apenas quando tiverem relat�rios pendentes para execu��o (Carlos)
  ---------------------------------------------------------------------------------------------------------------

  /* Lista de vari�veis para armazenar as mascaras parametrizadas */
  vr_des_mask_conta    VARCHAR2(10);
  vr_des_mask_ctitg    VARCHAR2(11);
  vr_des_mask_cpf      VARCHAR2(14);
  vr_des_mask_cnpj     VARCHAR2(20);
  vr_des_mask_cep      VARCHAR2(10);
  vr_des_mask_matric   VARCHAR2(7);
  vr_des_mask_contrato VARCHAR2(9);

  /* Sa�da com erro */
  vr_des_erro VARCHAR2(4000);
  vr_exc_erro EXCEPTION;
  vr_typ_said VARCHAR2(100);

  -- Busca do diret�rio conforme a cooperativa conectada
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.dsdircop
          ,cop.nmrescop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  /* Fun��o gen�rica para aplicar uma mascara ao conteudo passado */
  FUNCTION fn_mask(pr_dsorigi in varchar2,
                   pr_dsforma in varchar2) RETURN varchar2 IS
    -- ..........................................................................
    --
    --  Programa : fn_mask
    --  Sistema  : Rotinas gen�ricas
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Novembro/2012.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Mascarar a informa��o enviada seguindo o formado passado.
    --               A fun��o N�O DEVE ser utilizada para formatar VALOR, pois n�o trata casas decimais.
    --               Regras utilizadas na mascara
    --               -> 9 - Ao encontrar um nove, a rotina mostra o caracter n�mero
    --                      correspondente, e em caso de n�o existir, substitui por um
    --                      zero.
    --               -> z - Ao encontrar um Z, a rotina preenche a casa com a informa��o
    --                      enviada e caso n�o exista nada, � enviado um espa�o em branco
    --               -> Qualquer outro - � interpretado como um caracter especial e ser�
    --                                   enviado na nota��o final.
    --
    --    Exemplos : 12233        -> zz99-99-0        -> ' 122-33-0'
    --               abcd1        -> zzzzz            -> 'abcd1'
    --               33342000     -> zzzz-zzzz        -> '3334-2000'
    --               554733233000 -> +99(99)9999-9999 -> '+55(47)3323-3000'
    --
    --   Alteracoes: 26/07/2013 - Altera��o da fun��o para n�o utilizar mais 'select from dual'
    --                            devido a problemas de performance. (Daniel - Supero)
    -- .............................................................................
    vr_dsauxil   varchar2(200);
    vr_dsconve   varchar2(200);
    vr_dsforma   varchar2(200);
    vr_tam_mask  integer;
    vr_tam_var   integer;
  BEGIN
    -- Deixar em maiusculo para facilitar testes
    vr_dsforma := upper(pr_dsforma);
    vr_dsauxil := nvl(pr_dsorigi,' ');
    -- Identifica o tamanho das vari�veis para auxiliar na formata��o da m�scara
    vr_tam_mask := length(vr_dsforma);
    vr_tam_var := length(vr_dsauxil);
    -- Varrer a string, come�ando pelo final, para aplicar os caracteres especiais
    for vr_ind in reverse 1..vr_tam_mask loop
      -- Se o caracter atual na mascara nao for 9 ou Z
      if substr(vr_dsforma,vr_ind,1) not in('9','Z') then
        -- Ent�o � um caracter especial, inclu�-lo na saida
        vr_dsconve := substr(vr_dsforma,vr_ind,1)||vr_dsconve;
      else
        -- Se n�o for, utilizar o caracter da string original
        vr_dsconve := substr(vr_dsauxil,vr_tam_var,1)||vr_dsconve;
        -- Diminuir 1 no tamanho do texto, indicando que falta um caracter a menos para acabar
        vr_tam_var := vr_tam_var - 1;
        -- Quando n�o houver mais caracteres restantes, sai do loop, mesmo que n�o tenha terminado a m�scara
        if vr_tam_var = 0 then
          exit;
        end if;
      end if;
    end loop;
    -- Preencher o restante da informa�ao cfme a mascara
    -- Varrer a string partindo do final at� chegar no 9
    for vr_i in reverse 1..length(vr_dsforma) - length(vr_dsconve) loop
      if substr(vr_dsforma,vr_i,1) = '9' then
        -- Se encontrarmos um 9 no formato, adiciona um zero
        vr_dsconve := '0'||vr_dsconve;
      elsif substr(vr_dsforma,vr_i,1) = 'Z' then
        -- Se encontrar um Z, adiciona um espa�o em branco
        vr_dsconve := ' '||vr_dsconve;
      else
        -- � um caracter especial. Devemos verificar qual o caracter anterior para saber como tratar.
        if substr(vr_dsforma,vr_i-1,1) = 'Z' then
          -- Adicionar um espa�o em branco
          vr_dsconve := ' '||vr_dsconve;
        else
          -- Adicionar o caracter do formato
          vr_dsconve := substr(vr_dsforma,vr_i,1)||vr_dsconve;
        end if;
      end if;
    end loop;
    -- Retornar o valor processado
    return vr_dsconve;
  EXCEPTION
    when others then
      -- Incluir log de que houve problema na mascara
      gene0001.pc_print(pr_des_mensag => to_char(SYSDATE,'hh24:mi:ss')||' - GENE0002.fn_mask --> Problema ao montar a mascara "'||pr_dsforma||'" ao campo "'||pr_dsorigi||'".');
      -- Retonar como resultado o valor original
      return pr_dsorigi;
  END fn_mask;

  /* Fun��o para mascarar o Nro da Conta */
  FUNCTION fn_mask_conta(pr_nrdconta IN crapass.nrdconta%TYPE) RETURN VARCHAR2 IS
  BEGIN
    -- Se ainda n�o foi buscado
    IF vr_des_mask_conta IS NULL THEN
      vr_des_mask_conta := nvl(gene0001.fn_param_sistema('CRED',0,'MASK_CONTA'), 'zzzz.zzz.z');
    END IF;
    -- Utilizar mascara padr�o de conta
    RETURN fn_mask(pr_nrdconta,vr_des_mask_conta);
  END;

  /* Fun��o para mascarar a Conta Integra��o */
  FUNCTION fn_mask_ctitg(pr_nrdctitg IN crapass.nrdctitg%TYPE) RETURN VARCHAR2 IS
  BEGIN
    -- Se ainda n�o foi buscado
    IF vr_des_mask_ctitg IS NULL THEN
      vr_des_mask_ctitg := nvl(gene0001.fn_param_sistema('CRED',0,'MASK_CONTA_ITG'), 'z.zzz.zzz.z');
    END IF;
    -- Utilizar mascara padr�o de conta de integra��o
    RETURN fn_mask(pr_nrdctitg,vr_des_mask_ctitg);
  END;

  /* Fun��o para mascarar o CPF ou CNPJ */
  FUNCTION fn_mask_cpf_cnpj(pr_nrcpfcgc IN crapass.nrcpfcgc%type,
                            pr_inpessoa in crapass.inpessoa%type) RETURN varchar2 IS
  BEGIN
    -- Se ainda n�o foi buscado
    IF vr_des_mask_cpf IS NULL THEN
      vr_des_mask_cpf := nvl(gene0001.fn_param_sistema('CRED',0,'MASK_CPF'), '999.999.999-99');
    END IF;
    -- Mesmo esquema para o CNPJ
    IF vr_des_mask_cnpj IS NULL THEN
      vr_des_mask_cnpj := nvl(gene0001.fn_param_sistema('CRED',0,'MASK_CNPJ'), 'zz.zzz.zzz/zzzz-zz');
    END IF;
    -- Verifica se � pessoa f�sica (inpessoa = 1) ou pessoa jur�dica (inpessoa = 2)
    IF pr_inpessoa = 1 THEN
      -- Utilizar mascara padr�o de conta de CPF
      RETURN fn_mask(pr_nrcpfcgc,vr_des_mask_cpf);
    ELSE
      -- Utilizar mascara padr�o de conta de CNPJ
      RETURN fn_mask(pr_nrcpfcgc,vr_des_mask_cnpj);
    END IF;
  END;

  /* Fun��o para mascarar o CEP */
  FUNCTION fn_mask_cep(pr_nrcepend IN crapenc.nrcepend%TYPE) RETURN VARCHAR2 IS
  BEGIN
    -- Se ainda n�o foi buscado
    IF vr_des_mask_cep IS NULL THEN
      vr_des_mask_cep := nvl(gene0001.fn_param_sistema('CRED',0,'MASK_CEP'), 'zzzzz-zz9');
    END IF;
    -- Utilizar mascara padr�o de conta de CEP
    RETURN fn_mask(pr_nrcepend,vr_des_mask_cep);
  END;

  /* Fun��o para mascarar a matr�cula */
  FUNCTION fn_mask_matric(pr_nrmatric IN crapass.nrmatric%TYPE) RETURN VARCHAR2 IS
  BEGIN
    -- Se ainda n�o foi buscado
    IF vr_des_mask_matric IS NULL THEN
      vr_des_mask_matric := nvl(gene0001.fn_param_sistema('CRED',0,'MASK_MATRICULA'), 'zzzzz-zz9');
    END IF;
    -- Utilizar mascara padr�o de conta de Matr�cula
    RETURN fn_mask(pr_nrmatric,vr_des_mask_matric);
  END;

  /* Fun��o para mascarar o contrato */
  FUNCTION fn_mask_contrato(pr_nrcontrato IN crapepr.nrctremp%TYPE) RETURN VARCHAR2 IS
  BEGIN
   -- Se ainda n�o foi buscado
    IF vr_des_mask_contrato IS NULL THEN
      vr_des_mask_contrato := nvl(gene0001.fn_param_sistema('CRED',0,'MASK_CONTRATO'), 'zz.zzz.zz9');
    END IF;
    -- Utilizar mascara padr�o de conta de Nro Contrato
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
    -- Data    : Junho/2013                     Ultima atualizacao:

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


  /* Rotina para testar carateres num�ricos */
  FUNCTION fn_numerico(pr_vlrteste IN VARCHAR2) RETURN boolean IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : fn_numerico
    --  Sistema  : Rotinas gen�ricas
    --  Sigla    : GENE
    --  Autor    : Petter - Supero Tecnologia
    --  Data     : Dezembro/2012.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Retornar valida��o se a vari�vel contem numeros.
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- ............................................................................
    DECLARE
      vr_ctrteste       BOOLEAN := TRUE;
      vr_qvalor         VARCHAR2(1);

    BEGIN
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
    --  Sistema  : Rotinas gen�ricas
    --  Sigla    : GENE
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Dezembro/2012.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Retornar determinada informacao da string conforme parametros.
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- ............................................................................
    DECLARE
      /* Variaveis Locais */
      vr_pos    NUMBER;
      vr_string VARCHAR2(4000):= pr_dstext;
    BEGIN
      --Se o valor desejado for o 1� parametro
      IF pr_postext = 1 THEN
        --Encontrar a posi��o do delimitador na string
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
          --Encontrar a posi��o do delimitador na string
          vr_pos:= InStr(vr_string,pr_delimitador);

          --Atribuir a variavel o texto apos o delimitador
          vr_string:= SubStr(vr_string,vr_pos+1);
        END LOOP;
        --Encontrar a posi��o do delimitador na string
        vr_pos:= InStr(vr_string,pr_delimitador);
        IF vr_pos > 0 THEN
          --Atribuir a variavel o texto apos o delimitador
          vr_string:= SubStr(vr_string,1,vr_pos-1);
        END IF;
      END IF;
      RETURN(vr_string);
    END;
  END fn_busca_entrada;

  /* Quebra string com base no delimitador e retorna array de resultados */
  FUNCTION fn_quebra_string(pr_string   IN VARCHAR2
                           ,pr_delimit  IN CHAR DEFAULT ',') RETURN typ_split IS

    -- ..........................................................................
    --
    --  Programa : fn_quebra_string
    --  Sistema  : Rotinas gen�ricas
    --  Sigla    : GENE
    --  Autor    : Petter Rafael - Supero
    --  Data     : Janeiro/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Retornar array com os campos referentes a quebra da string
    --               com base no delimitador informado.
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- ............................................................................

    vr_vlret    typ_split := typ_split();
    vr_quebra   LONG DEFAULT pr_string || pr_delimit;
    vr_idx      NUMBER;

  BEGIN
    --Se a string estiver nula retorna count = 0 no vetor
    IF nvl(pr_string,'#') = '#' THEN
      RETURN vr_vlret;
    END IF;

    LOOP
      -- Identifica ponto de quebra inicial
      vr_idx := instr(vr_quebra, pr_delimit);

      -- Clausula de sa�da para o loop
      exit WHEN nvl(vr_idx, 0) = 0;

      -- Acrescenta elemento para a cole��o
      vr_vlret.EXTEND;
      -- Acresce mais um registro gravado no array com o bloco de quebra
      vr_vlret(vr_vlret.count) := trim(substr(vr_quebra, 1, vr_idx - 1));
      -- Atualiza a vari�vel com a string integral eliminando o bloco quebrado
      vr_quebra := substr(vr_quebra, vr_idx + LENGTH(pr_delimit));
    END LOOP;

    -- Retorno do array com as substrings separadas em cada registro
    RETURN vr_vlret;
  END fn_quebra_string;

  /* Pesquisa por valor informado quebrando a busca pelo delimitador passado */
  FUNCTION fn_existe_valor(pr_base      IN VARCHAR2                    --> String que ir� sofrer a busca
                          ,pr_busca     IN VARCHAR2                    --> String objeto de busca
                          ,pr_delimite  IN VARCHAR2) RETURN VARCHAR2 IS --> String que ser� o delimitador
    -- ..........................................................................
    --
    --  Programa : fn_existe_valor
    --  Sistema  : Rotinas gen�ricas
    --  Sigla    : GENE
    --  Autor    : Petter Rafael - Supero
    --  Data     : Janeiro/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Quebra uma string enviada de acordo com um delimitador informado
    --               e pesquisa se uma string objeto de busca existe dentre os
    --               resultados da quebra da string retornando 'S' em caso de sucesso
    --               ou 'N' em caso de insucesso.
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- ............................................................................

    vr_buscar  typ_split;
    vr_result  VARCHAR2(1) := 'N';

  BEGIN
    -- Quebra a string pelo delimitador informado
    vr_buscar := fn_quebra_string(pr_base, pr_delimite);
    -- Verifica se a quebra resultou em um array v�lido
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
    -- Retorno se localizou ou n�o o objeto de busca
    RETURN vr_result;
  END fn_existe_valor;

  /* Pesquisa recursiva do contains */
  FUNCTION fn_verifica_contem(pr_dstexto in varchar2                     --> Texto que ir� sofrer a busca
                             ,pr_dsprocu in varchar2) RETURN VARCHAR2 IS --> String objeto de busca
  BEGIN
    -- ............................................................................
    DECLARE
      -- Guardar a chave atual
      vr_dspalav VARCHAR2(4000);
    BEGIN
      -- Se existir mais de uma palavra na chave de procura
      IF instr(pr_dsprocu,' ') > 0 THEN
        -- Separar da chave de procura a primeira palavra
        vr_dspalav := substr(pr_dsprocu,1,instr(pr_dsprocu,' ')-1);
      ELSIF trim(pr_dsprocu) IS NULL THEN
        -- N�o h� mais chaves de procura, finaliza
        RETURN 'S';
      ELSE
        -- Utiliza a palavra inteira
        vr_dspalav := pr_dsprocu;
      END IF;

      -- Invalidar se n�o encontrar a chave de procura
      -- Na palavra inteira
      -- OU no in�cio
      -- OU no fim
      -- OU no meio desde seja a palavra inteira
      IF NOT(   pr_dstexto = vr_dspalav
             OR pr_dstexto LIKE vr_dspalav||' %'
             OR pr_dstexto LIKE '% '||vr_dspalav
             OR pr_dstexto LIKE '% '||vr_dspalav||' %' ) THEN
        -- N�o casou pelo menos uma das strings de busca, ent�o retorna false
        RETURN 'N';
      ELSE
        -- Do contr�rio, chama recursivamente passando a lista de palavras e removendo a atual
        RETURN fn_verifica_contem(pr_dstexto => pr_dstexto
                                 ,pr_dsprocu => ltrim(ltrim(pr_dsprocu,vr_dspalav)));
      END IF;
    END;
  END;

  /* Pesquisa no texto pelas strings de procura sem observar a ordem das mesmas */
  FUNCTION fn_contem(pr_dstexto in varchar2                     --> Texto que ir� sofrer a busca
                    ,pr_dsprocu in varchar2) RETURN VARCHAR2 IS --> String objeto de busca
  BEGIN
    -- ..........................................................................
    --
    --  Programa : fn_contains e fn_verifica_contem
    --  Sistema  : Rotinas gen�ricas
    --  Sigla    : GENE
    --  Autor    : Marcos Martini - Supero
    --  Data     : Mar�o/2014.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Simular a mesma busca efetuada pelo comando Contains no Progress.
    --               A string de procura pode conter n sub strings de busca, e a ordem
    --               n�o afeta o resultado, exemplos:
    --               pr_dsprocu =>  SUL RIO DO
    --               Retornar�:
    --                  RIO BRANCO DO SUL
    --                  RIO DO SUL
    --                  RIO NOVO DO SUL
    --   Obs:        A l�gica de procura est� na fun��o fn_verifica_contem
    --               a fn_contem apenas prepara as strings de busca e objeto
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- ............................................................................
    BEGIN
      -- Usar a fun��o recursiva para valida��o, esta apenas serve para preparar as strings
      RETURN fn_verifica_contem(pr_dstexto => UPPER(pr_dstexto)
                               ,pr_dsprocu => UPPER(REPLACE(pr_dsprocu,'*','%'))); --> Trocar os caracteres curinga Progress (*) pelos do Oracle (%)
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 'N';
    END;
  END fn_contem;

  /* Fun��o para converter um arquivo em BLOB */
  FUNCTION fn_arq_para_blob(pr_caminho IN VARCHAR2
                           ,pr_arquivo IN VARCHAR2) RETURN BLOB IS
  BEGIN
    /*..............................................................................

       Programa: fn_arq_para_blob
       Autor   : Marcos (Supero)
       Data    : Dezembro/2012                      Ultima atualizacao: 05/12/2012

       Dados referentes ao programa:

       Objetivo  : Criar um Blob a apartir do arquivo passado

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- BLOB para saida
      vr_blob BLOB := EMPTY_BLOB;
      -- Vari�veis para tratamento do arquivo
      vr_input_file    utl_file.file_type;
      vr_chunk_size    constant pls_integer := 32767;
      vr_buf           raw                    (32767);
      vr_bytes_to_read pls_integer;
      vr_read_sofar    pls_integer := 0;
    BEGIN
      -- Criar um LOB para armazenar o arquivo
      DBMS_LOB.CREATETEMPORARY(vr_blob, TRUE);
      -- Abrir o arquivo local e escrev�-lo ao Blob
      BEGIN
        vr_input_file := utl_file.fopen(pr_caminho,pr_arquivo,'RB',32767);
        LOOP
          -- Le os dados em peda�os e escreve no Blob
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
      -- Retornar o BLOB montado
      RETURN vr_blob;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN EMPTY_BLOB;
    END;
  END fn_arq_para_blob;

  /* Fun��o para converter um arquivo em CLOB */
  FUNCTION fn_arq_para_clob(pr_caminho IN VARCHAR2
                           ,pr_arquivo IN VARCHAR2) RETURN CLOB IS
    /*..............................................................................

       Programa: fn_arq_para_blob
       Autor   : Dionathan
       Data    : Maio/2015                      Ultima atualizacao: 12/05/2015

       Dados referentes ao programa:

       Objetivo  : Criar um CLOB a apartir do arquivo passado

       Alteracoes:

    ..............................................................................*/

    -- CLOB para saida
    vr_clob CLOB;
  BEGIN
    vr_clob := DBMS_XSLPROCESSOR.read2clob(pr_caminho, pr_arquivo, 1);
    RETURN vr_clob;
  END fn_arq_para_clob;

  /* Procedure para gravar os dados de um BLOB para um arquivo */
  PROCEDURE pc_blob_para_arquivo(pr_blob      IN BLOB     --> Blob com os dados
                                ,pr_caminho   IN VARCHAR2 --> Diret�rio para sa�da
                                ,pr_arquivo   IN VARCHAR2 --> Nome do arquivo de sa�da
                                ,pr_des_erro OUT VARCHAR2) IS
  BEGIN
    /*..............................................................................

       Programa: pc_blob_para_arquivo
       Autor   : Marcos (Supero)
       Data    : Dezembro/2012                      Ultima atualizacao: 05/12/2012

       Dados referentes ao programa:

       Objetivo  : Efetua leitura das informa��es de um Blob e grava em arquivo

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Vari�veis para tratamento do arquivo
      vr_output_file   utl_file.file_type;
      vr_blob_length   INTEGER;
      vr_start_byte    NUMBER;
      vr_bytes_to_read NUMBER := 32767;
      vr_bytes_total   NUMBER := 32767;
      vr_raw_readed    RAW(32767);
    BEGIN
      -- Abrir o arquivo local para escrita dos bytes
      vr_output_file := utl_file.fopen(pr_caminho,pr_arquivo,'WB',32767);
      -- Guardar o tamanho do Blob
      vr_blob_length := dbms_lob.getlength(pr_blob);
      vr_bytes_total := vr_blob_length;
      -- Se o Blob for pequeno o suficiente para ser escrito de uma s� vez
      IF vr_blob_length < 32767 THEN
        -- Escreve apenas uma vez
        utl_file.put_raw(vr_output_file,pr_blob);
        utl_file.fflush(vr_output_file);
      ELSE
        -- Efetuar escrita em por��es
        vr_start_byte := 1;
        WHILE vr_start_byte < vr_blob_length AND vr_bytes_to_read > 0 LOOP
          -- Ler os dados do Blob
          dbms_lob.read(pr_blob,vr_bytes_to_read,vr_start_byte,vr_raw_readed);
          -- Escreve no arquivo
          utl_file.put_raw(vr_output_file,vr_raw_readed);
          utl_file.fflush(vr_output_file);
          -- Reposiciona o byte inicial para leitura
          vr_start_byte := vr_start_byte + vr_bytes_to_read;
          -- Desconta do total a quantidade j� lida
          vr_bytes_total := vr_bytes_total - vr_bytes_to_read;
          -- Reajusta a quantidade de bytes a ler caso seja inferior m�ximo poss�vel
          IF vr_bytes_total < 32767 THEN
            vr_bytes_to_read := vr_bytes_total;
          END IF;
        END loop;
      END IF;
      -- Fechar o arquivo;
      utl_file.fclose(vr_output_file);
      -- Setar privil�gio para evitar falta de permiss�o a outros usu�rios
      gene0001.pc_OScommand_Shell(pr_des_comando => 'chmod 666 '||pr_caminho||'/'||pr_arquivo);
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'GENE0002.pc_blob_para_arquivo --> || Erro ao gravar o conte�do do Blob para arquivo: '||sqlerrm;
    END;
  END pc_blob_para_arquivo;

  /* Procedure para gravar os dados de um CLOB para um arquivo */
  PROCEDURE pc_clob_para_arquivo(pr_clob      IN CLOB     --> Blob com os dados
                                ,pr_caminho   IN VARCHAR2 --> Diret�rio para sa�da
                                ,pr_arquivo   IN VARCHAR2 --> Nome do arquivo de sa�da
                                ,pr_flappend  IN VARCHAR2 DEFAULT 'N' --> Indica que a solicita��o ir� incrementar o arquivo
                                ,pr_des_erro OUT VARCHAR2) IS
  BEGIN
    /*..............................................................................

       Programa: pc_clob_para_arquivo
       Autor   : Marcos (Supero)
       Data    : Mar�o/2014                      Ultima atualizacao: 31/08/2015

       Dados referentes ao programa:

       Objetivo  : Efetua leitura das informa��es de um Clob e gravar em arquivo

       Alteracoes: 31/08/2015 - Inclusao do parametro flappend. (Jaison/Marcos-Supero)

    ..............................................................................*/
    DECLARE
    	vr_nom_arquiv VARCHAR2(2000);
      vr_ext_arqsai VARCHAR2(100);
      vr_typ_saida  VARCHAR2(10);
      vr_des_saida  VARCHAR2(4000);
      vr_comando    VARCHAR2(32767);

    BEGIN
      -- Nome do arquivo
      vr_nom_arquiv := pr_arquivo;

      -- Se foi solicitado o arquivo com Append
      IF pr_flappend = 'S' THEN
        -- Guarda a extensao do arquivo de sa�da
        vr_ext_arqsai := GENE0001.fn_extensao_arquivo(vr_nom_arquiv);
        -- Remove a extens�o do nome do arquivo
        vr_nom_arquiv := SUBSTR(vr_nom_arquiv,1,LENGTH(vr_nom_arquiv)-LENGTH(vr_ext_arqsai)-1);
        -- Mudar o nome do arquivo para evitar sobscrever o relat�rio antigo
        vr_nom_arquiv := vr_nom_arquiv||'-append'||'.'||vr_ext_arqsai;
      END IF;

      -- Gerar no diret�rio solicitado
      DBMS_XSLPROCESSOR.CLOB2FILE(pr_clob, pr_caminho, vr_nom_arquiv, NLS_CHARSET_ID('UTF8'));
      -- Setar privil�gio para evitar falta de permiss�o a outros usu�rios
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
        -- Testa se a sa�da da execu��o acusou erro
        IF vr_typ_saida = 'ERR' THEN
          vr_des_saida := 'Erro ao efetuar concatenacao do relat�rio: '||vr_des_saida;
          RAISE vr_exc_erro;
        END IF;

        -- Remover o arquivo do Append
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => 'rm '||pr_caminho||'/'||vr_nom_arquiv
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_des_saida);
        -- Testa se a sa�da da execu��o acusou erro
        IF vr_typ_saida = 'ERR' THEN
          vr_des_saida := 'Erro ao eliminar o relatorio de append: '||vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
      END IF; -- pr_flappend = 'S'

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro := 'GENE0002.pc_clob_para_arquivo --> ' || vr_des_saida;
      WHEN OTHERS THEN
        pr_des_erro := 'GENE0002.pc_clob_para_arquivo --> || Erro ao gravar o conte�do do Blob para arquivo: '||sqlerrm;
    END;
  END pc_clob_para_arquivo;

  /****************************************************************************/
  /**          Procedure para copiar arquivo PDF para o sistema ayllos web   **/
  /****************************************************************************/
  PROCEDURE pc_efetua_copia_pdf (pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa conectada
                                ,pr_cdagenci IN INTEGER                      -- Codigo da agencia para erros
                                ,pr_nrdcaixa IN INTEGER                      -- Codigo do caixa para erros
                                ,pr_nmarqpdf IN VARCHAR2                  --> Arquivo PDF  a ser gerado
                                ,pr_des_reto OUT VARCHAR2                 --> Sa�da com erro
                                ,pr_tab_erro OUT gene0001.typ_tab_erro) IS   -- tabela de erros
  /*..............................................................................

       Programa: pc_efetua_copia_pdf            Antiga(b1wgen0024.p/efetua-copia-pdf)
       Autor   : Odirlei Busana (AMcom)
       Data    : Junho/2014                      Ultima atualizacao: 25/06/2014

       Dados referentes ao programa:

       Objetivo  : Procedure para copiar arquivo PDF para o sistema ayllos web

       Altera��o:

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
    -- Sa�da do Shell
    vr_typ_saida VARCHAR2(3);


  BEGIN
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se n�o encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haver� raise
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
    -- Alterar informa��es do comando
    vr_cmdcopia := replace(replace(replace(vr_cmdcopia
                                         ,'<##pr_nmarqpdf##>',pr_nmarqpdf)
                                         ,'<##srvintra##>'   ,vr_srvintra)
                                         ,'<##dsdircop##>'   ,rw_crapcop.dsdircop);

    -- Efetuar a execu��o do comando montado
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

  EXCEPTION
    WHEN vr_exc_saida THEN

      pr_des_reto := 'NOK';
      -- Chamar rotina de grava��o de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cod_erro
                           ,pr_dscritic => vr_dsc_erro
                           ,pr_tab_erro => pr_tab_erro);
    WHEN OTHERS THEN
      -- Retornando a critica para o programa chamdador
      vr_cod_erro := 0;
      vr_dsc_erro := 'Erro na rotina GENE0002.pc_efetua_copia_pdf. '||sqlerrm;

      pr_des_reto := 'NOK';
      -- Chamar rotina de grava��o de erro
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
                                  ,pr_des_erro OUT VARCHAR2) IS             --> Sa�da com erro
  /*..............................................................................

       Programa: pc_efetua_copia_arq_ib
       Autor   : Marcos Martini (Supero)
       Data    : Agosto/2015                      Ultima atualizacao: 20/08/2015

       Dados referentes ao programa:

       Objetivo  : Procedure para copiar arquivo PDF para o sistema InternetBanking

       Altera��o:

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
    -- Sa�da do Shell
    vr_typ_saida VARCHAR2(3);


  BEGIN
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se n�o encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haver� raise
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
    -- Alterar informa��es do comando
    vr_cmdcopia := replace(replace(vr_cmdcopia,'<##pr_nmarqpdf##>',pr_nmarqpdf),'<##dsurlitb##>'   ,vr_srvib);

    -- Efetuar a execu��o do comando montado
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

  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_des_erro := vr_dsc_erro;
    WHEN OTHERS THEN
      -- Retornando a critica para o programa chamdador
      pr_des_erro := 'Erro na rotina GENE0002.pc_efetua_copia_pdf_ib. '||sqlerrm;
  END pc_efetua_copia_arq_ib;
  
  /*****************************************************
  **   Publicar arquivo de controle na intranet       **
  ******************************************************/
  PROCEDURE pc_publicar_arq_intranet IS

    /* ..........................................................................

     Programa: PC_PUBLICAR_ARQ_INTRANET
     Sistema : Conta-Corrente - Cooperativa de Credito
     Autor   : Odirlei Busana - AMcom
     Data    : Dezembro/2015.                     Ultima atualizacao: 05/02/2015

     Dados referentes ao programa:

     Frequencia: Em job de 30 em 30 min.
     Objetivo  : Buscar arquivos pendentes na TMPPDF da coop e enviar arquivo de controle
                 para o servidor da intranet. 

     Alteracoes:

    ..........................................................................*/

    --> Buscar dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.dsdircop,
             cop.cdcooper
        FROM crapcop cop,
             crapdat dat        
       WHERE cop.cdcooper <> 3 
         AND cop.flgativo = 1
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
    
    vr_cdcooper := 1;
    vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
    vr_dscomora := gene0001.fn_param_sistema('CRED',3,'SCRIPT_EXEC_SHELL');  
    
    --> Validar horario que a rotina pode rodar
    vr_dsinterval := gene0001.fn_param_sistema('CRED',3,'INTERVAL_PUBLIC_INTRANET');  
    
    vr_dthora_inic := to_date(gene0002.fn_busca_entrada(pr_postext => 1, 
                                                        pr_dstext  => vr_dsinterval, 
                                                        pr_delimitador => ';'),
                              'HH24:MI');
    
    vr_dthora_fim  := to_date(gene0002.fn_busca_entrada(pr_postext => 2, 
                                                        pr_dstext  => vr_dsinterval, 
                                                        pr_delimitador => ';'),
                              'HH24:MI');
        
    IF to_char(SYSDATE,'HH24MI') NOT BETWEEN to_char(vr_dthora_inic,'HH24MI') AND 
                                             to_char(vr_dthora_fim,'HH24MI') THEN      
      RETURN;
    END IF;     
    
    --> Buscar coops ativas para verifica��o dos arquivos pendentes
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
          
          -- alterar o diretorio pois como ser� executado via ssh no servidor progress
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
                               to_char(SYSDATE,'DDMM')||'.'||gene0002.fn_busca_time; --> Nome do arq. destino

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
      -- Exception por cooperativa, para execu��o de uma n�o interferir as demais
      EXCEPTION
        WHEN vr_exc_erro THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                                     pr_ind_tipo_log => 2, --> erro tratado
                                     pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - '||vr_cdprogra ||' --> ' || vr_dscritic,
                                     pr_nmarqlog     => vr_nmarqlog);

        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao enviar arquivo de controle para intranet: '||SQLERRM;
          btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                                     pr_ind_tipo_log => 2, --> erro tratado
                                     pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - '||vr_cdprogra ||' --> ' || vr_dscritic,
                                     pr_nmarqlog     => vr_nmarqlog);
      END; 
    END LOOP; --> Fim loop coop
    
    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                                 pr_ind_tipo_log => 2, --> erro tratado
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra ||' --> ' || vr_dscritic,
                                 pr_nmarqlog     => vr_nmarqlog);

    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao enviar arquivo de controle para intranet: '||SQLERRM;
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                                 pr_ind_tipo_log => 2, --> erro tratado
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra ||' --> ' || vr_dscritic,
                                 pr_nmarqlog     => vr_nmarqlog);


  END pc_publicar_arq_intranet;

  /****************************************************************************/
  /**          Procedure para converter proposta para o formato PDF          **/
  /****************************************************************************/
  PROCEDURE pc_gera_pdf_impressao(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa conectada
                                 ,pr_nmarqimp IN VARCHAR2                  --> Arquivo a ser convertido para pDf
                                 ,pr_nmarqpdf IN VARCHAR2                  --> Arquivo PDF  a ser gerado
                                 ,pr_des_erro OUT VARCHAR2) IS             --> Sa�da com erro

  /*..............................................................................

       Programa: pc_gera_pdf_impressao          Antiga(b1wgen0024.p/gera-pdf-impressao)
       Autor   : Odirlei Busana (AMcom)
       Data    : Maio/2014                      Ultima atualizacao: 30/05/2014

       Dados referentes ao programa:

       Objetivo  : Procedure para converter proposta para o formato PDF

       Altera��o:

    ..............................................................................*/
    vr_script  VARCHAR2(2000);
    -- Sa�da do Shell
    vr_typ_saida VARCHAR2(3);


  BEGIN

    /** Retirar caracteres especiais para impressoras matriciais **/
    vr_script := 'cat '||pr_nmarqimp||' | '||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SCRIPT_CONVERTEPCL')||
                 ' > ' ||pr_nmarqimp||'_PCL';-- 2>/dev/null';

    -- Efetuar a execu��o do comando montado
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

    -- Efetuar a execu��o do comando montado
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

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Concatenar ao erro a descri��o tempor�ria
      pr_des_erro := 'GENE0002.pc_gera_pdf_impressao --> '||vr_des_erro;

    WHEN OTHERS THEN
      -- Retornar erro
      pr_des_erro := 'GENE0002.pc_gera_pdf_impressao --> '||sqlerrm;
  END pc_gera_pdf_impressao;

  /* Procedimento para gera��o de PDFs */
  PROCEDURE pc_cria_PDF(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa conectada
                       ,pr_nmorigem IN VARCHAR2                  --> Path arquivo origem
                       ,pr_ingerenc IN VARCHAR2                  --> SIM/NAO
                       ,pr_tirelato IN VARCHAR2                  --> Tipo (80col, etc..)
                       ,pr_dtrefere IN DATE  DEFAULT NULL        --> Data de referencia
                       ,pr_nmsaida  OUT VARCHAR2                 --> Path do arquivo gerado
                       ,pr_des_erro OUT VARCHAR2) IS             --> Sa�da com erro
  BEGIN
    /*..............................................................................

       Programa: pc_cria_PDF
       Autor   : Marcos (Supero)
       Data    : Dezembro/2012                      Ultima atualizacao: 23/01/2014

       Dados referentes ao programa:

       Objetivo  : Efetuar a gera��o de PDF e devolver o caminho do arquivo gerado

       Observa��es: A sintaxe do CriaPDF.sh segue a seguinte:
                    /usr/coop/<DsDirCop>/script/CriaPDF.sh <ArqOrigem> <EhGerencial> <TipoRel> <PastaDestino> <DsDirCop>
                    Onde:
                    <ArqOrigem>    : Path do arquivo a gerar o PDF, o
                    <EhGerencial>  : SIM/NAO para gerar arquivo gerencial ou n�o
                    <TipoRel>      : TIpo do relat�rio (80col por ex)
                    <PastaDestino> : Subdiret�rio que a rotina gerar� o PDF, o caminho final seguir� ficar� no seguinte path:
                                     /usr/audit/pdf/<DsDirCop>/<PastaDestino>/<nomeArquivo>.pdf
                    <DsDirCop>     : Diret�rio raiz da cooperativa conectada

       Alteracoes:  23/10/2013 - Ajustar o script para n�o enviar mais uma barra antes
                                 do diret�rio rl, e tamb�m n�o usar a pc_gera_log_batch
                                 mas sim as rotinas espec�ficas de manuten��o de arquivo
                                 (Marcos-Supero)

                    21/01/2014 - Ajustar a valida��o da gera��o do arquivo, para que ao
                                 montar o nome do arquivo a ser verificado, a extens�o
                                 n�o seja obrigat�ria.
                               - Incluir o parametro pr_dtrefere, para indicar uma data
                                 de referencia, caso for necess�rio. (Renato - Supero)

                    23/01/2014 - Caso o arquivo de origem precise ser copiado para o
                                 diret�rio 'rl' da cooperativa PR_CDCOOPER, deve remover
                                 o arquivo ao final do processamento. (Daniel - Supero)

    ..............................................................................*/
    DECLARE
      -- Diret�rio script da cooperativa
      vr_dircop VARCHAR2(200);
      -- Nome da pasta destino do PDF
      vr_nmpasta VARCHAR2(40);
      -- Script completo para a executa��o
      vr_script VARCHAR2(4000);
      -- Busca da data de movimento atual
      CURSOR cr_crapdat IS
        SELECT dat.dtmvtolt
          FROM crapdat dat
         WHERE dat.cdcooper = pr_cdcooper;
      vr_dtmvtolt crapdat.dtmvtolt%TYPE;
      -- Diret�rio e nome do arquivo
      vr_direto VARCHAR2(4000);
      vr_arquivo VARCHAR2(4000);
      vr_dsexarq VARCHAR2(1000);
      -- Sa�da do Shell
      vr_typ_saida VARCHAR2(3);
      -- Handle para arquivo de log
      vr_ind_arqlog UTL_FILE.file_type;
      -- Flag para indicar se houve c�pia do arquivo origem para o diret�rio /usr/coop/<nmrescop>/rl
      vr_flg_copiou  boolean := false;
    BEGIN
      -- Buscar dsdircop
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      CLOSE cr_crapcop;
      -- Buscar o diret�rio script da cooperativa conectada
      vr_dircop := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                        ,pr_cdcooper => pr_cdcooper);
      -- Busca somente o nome do arquivo a partir do path completo passado
      gene0001.pc_separa_arquivo_path(pr_caminho => pr_nmorigem
                                     ,pr_direto  => vr_direto
                                     ,pr_arquivo => vr_arquivo);
      -- Verifica se uma data de referencia foi repassada
      IF pr_dtrefere IS NULL THEN
        -- Montar diret�rio para gera��o do arquivo PDF, usar AAAA_MM/DD
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
      -- Copiar o arquivo de origem para o diret�rio rl, caso ele n�o esteja l�.
      -- Setar o flag como TRUE para excluir o arquivo ao final do procedimento.
      IF pr_nmorigem <> vr_dircop||'/rl/'||vr_arquivo THEN
        gene0001.pc_OScommand_Shell('cp '||pr_nmorigem||' '||vr_dircop||'/rl/'||vr_arquivo);
        vr_flg_copiou := true;
      END IF;
      -- Montar comando Shell de cria��o do PDF
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
      -- Efetuar a execu��o do comando montado
      gene0001.pc_OScommand_Shell(pr_des_comando => vr_script
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_des_erro);
      -- Se retornou erro
      IF vr_typ_saida = 'ERR' OR vr_des_erro IS NOT null THEN
        -- N�o enviar nenhuma informa��o no arquivo de sa�da
        pr_nmsaida := '';
        -- Concatena o erro que veio
        vr_des_erro := 'Erro na chamada ao Shell: '||vr_des_erro;
        -- Exclui o arquivo tempor�rio, caso tenha sido criado
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
        -- Buscar a extens�o do arquivo
        vr_dsexarq := GENE0001.fn_extensao_arquivo(pr_arquivo => vr_arquivo);

        -- Se o arquivo n�o possui extens�o
        IF vr_dsexarq IS NULL THEN
          -- Montar o nome
          pr_nmsaida := pr_nmsaida || '/' || vr_arquivo ||'.pdf';
        ELSE

          -- Incluir o nome no caminho final
          pr_nmsaida := pr_nmsaida || '/' || SUBSTR(vr_arquivo,1,LENGTH(vr_arquivo)-4) ||'.pdf';
        END IF;
        -- Testa se o arquivo n�o foi criado com sucesso
        IF NOT gene0001.fn_exis_arquivo(pr_nmsaida) THEN
          -- Montar erro
          vr_des_erro := 'Rotina PDF n�o retornou erro, mas n�o existe o arquivo final: "'||pr_nmsaida||'"';
          -- N�o enviar nenhuma informa��o no arquivo de sa�da
          pr_nmsaida := '';
          -- Exclui o arquivo tempor�rio, caso tenha sido criado
          if vr_flg_copiou then
            gene0001.pc_OScommand_Shell('rm '||vr_dircop||'/rl/'||vr_arquivo);
          end if;
          -- LEvantar exce��o
          RAISE vr_exc_erro;
        END IF;
      END IF;
      -- Exclui o arquivo tempor�rio, caso tenha sido criado
      if vr_flg_copiou then
        gene0001.pc_OScommand_Shell('rm '||vr_dircop||'/rl/'||vr_arquivo);
      end if;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Concatenar ao erro a descri��o tempor�ria
        pr_des_erro := 'GENE0002.pc_cria_pdf --> '||vr_des_erro;
        vr_des_erro := '';
        -- Enviar ao Log tamb�m
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratado
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '||pr_des_erro);
      WHEN OTHERS THEN
        -- Retornar erro
        pr_des_erro := 'GENE0002.pc_cria_pdf --> Erro n�o tratado a gerar o arquivo origem: "'||pr_nmorigem||'". Erro: '||sqlerrm;
        -- Enviar ao Log tamb�m
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 3 -- Erro cr�tico
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '||pr_des_erro);
    END;
  END pc_cria_PDF;

  /* Procedimento para tratamento de arquivos ZIP*/
  PROCEDURE pc_zipcecred(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Cooperativa conectada
                        ,pr_tpfuncao  IN VARCHAR2 DEFAULT 'A'      --> Tipo de fun��o (A-Add;E-Extract;V-View)
                        ,pr_dsorigem  IN VARCHAR2                  --> Lista de arquivos a compactar (separados por espa�o) ou arquivo a descompactar
                        ,pr_dsdestin  IN VARCHAR2                  --> Caminho para o arquivo Zip a gerar ou caminho de destino dos arquivos descompactados
                        ,pr_dspasswd  IN VARCHAR2                  --> Password a incluir no arquivo
                        ,pr_flsilent  IN VARCHAR2 DEFAULT 'S'      --> Se a chamada ter� retorno ou n�o a tela
                        ,pr_des_erro OUT VARCHAR2) IS
  BEGIN
    /*..............................................................................

       Programa : pc_zipcecred
       Autor    : Marcos (Supero)
       Data     : Dezembro/2012                      Ultima atualizacao: 27/11/2013

       Dados referentes ao programa:

       Objetivo  : Efetuar a compacta��o e descompacta��o de ZIP atrav�s de chamada
                   ao zipcecred.pl

       Observa��es: A sintaxe do zipcecred.pl segue o seguinte esquema:
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

    ..............................................................................*/
    DECLARE
      -- Script completo para a executa��o
      vr_script VARCHAR2(4000);
      -- NOme do arquivo final
      vr_dsdestin VARCHAR2(4000);
      vr_dsorigem VARCHAR2(4000);
    BEGIN

      -- Montar comando Perl compacta��o ZIP
      vr_script := vr_script||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SCRIPT_ZIPCECRED');

      --Verifica a fun��o a ser executada
      IF pr_tpfuncao = 'A' THEN
        -- Guardar nome enviado
        vr_dsdestin := pr_dsdestin;
        -- Remover aspas duplas no in�cio e fim do nome pois a rotina j� inclui
        vr_dsdestin := LTRIM(RTRIM(vr_dsdestin,'"'),'"');
        -- Se n�o foi passado a extens�o
        IF SUBSTR(vr_dsdestin,LENGTH(vr_dsdestin)-3) <> '.zip' THEN
          -- Incluir .zip no arquivo final
          vr_dsdestin := vr_dsdestin || '.zip';
        END IF;

        -- Incluir fun��o ADD
        vr_script := vr_script || ' -add';

        -- Incluir o destino no script
        vr_script := vr_script || ' "'||vr_dsdestin||'" ';

        -- Se informou a lista de arquivos e a fun��o � ADD
        IF pr_dsorigem IS NOT NULL  THEN
          -- inclui a lista de arquivo a "zippar"
          vr_script := vr_script ||pr_dsorigem;
        END IF;

      ELSIF pr_tpfuncao = 'E' THEN
        -- Remover aspas duplas no in�cio e fim do nome pois a rotina j� inclui
        vr_dsorigem := LTRIM(RTRIM(pr_dsorigem,'"'),'"');
        vr_dsdestin := LTRIM(RTRIM(pr_dsdestin,'"'),'"');
        -- Incluir fun��o EXTRACT
        vr_script := vr_script || ' -extract';
        -- Incluir o arquivo a extrair
        vr_script := vr_script ||' "'||vr_dsorigem||'"';
        -- Incluir o destino no script
        vr_script := vr_script || ' "'||vr_dsdestin||'" ';
      ELSIF pr_tpfuncao = 'V' THEN
        -- Remover aspas duplas no in�cio e fim do nome pois a rotina j� inclui
        vr_dsorigem := LTRIM(RTRIM(pr_dsorigem,'"'),'"');
        -- Incluir fun��o VIEW
        vr_script := vr_script || ' -view';
        -- Incluir o arquivo a listar
        vr_script := vr_script ||' "'||vr_dsorigem||'"';
      ELSE
        -- Retorna a mensagem de erro informando que a fun��o informada n�o � valida
        pr_des_erro := 'GENE0002.pc_zipcecred --> Tipo de fun��o informado n�o � valido.';
        RETURN;
      END IF;

      -- Se foi solicitada a execu��o silenciosa
      IF pr_flsilent = 'S' THEN
        vr_script := vr_script || ' -silent ';
      END IF;
      -- Se foi passado Password
      IF pr_dspasswd IS NOT NULL THEN
        vr_script := vr_script || ' -pass='||pr_dspasswd||' ';
      END IF;

      -- Chamar o script rec�m criado
      gene0001.pc_OScommand_shell(pr_des_comando => vr_script
                                 ,pr_typ_saida   => vr_typ_said
                                 ,pr_des_saida   => vr_des_erro);
      -- Testar erro
      IF vr_typ_said = 'ERR' THEN
        -- O comando shell executou com erro, gerar log e sair do processo
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 3 -- Erro cr�tico
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - GENE0002.pc_cria_ZIP --> Erro ao zippar o(s) arquivos:"'||pr_dsorigem||'" para: "'||vr_dsdestin||'". Erro> '|| vr_des_erro);
        -- Retornar no erro
        pr_des_erro := 'GENE0002.pc_cria_ZIP --> Erro ao zippar o(s) arquivos:"'||pr_dsorigem||'" para: "'||vr_dsdestin||'". Erro> '|| vr_des_erro;
      ELSIF pr_tpfuncao = 'A' THEN -- Verifica apenas se a fun��o for de cria��o do ZIP
        -- Testa se o arquivo n�o foi criado com sucesso
        IF NOT gene0001.fn_exis_arquivo(vr_dsdestin) THEN
          -- Gerar LOG avisando que o arquivo n�o foi criado
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 3 -- Erro cr�tico
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - GENE0002.pc_cria_ZIP --> N�o gerou arquivo "'||vr_dsdestin||'" do(s) arquivos: "'||pr_dsorigem||'"');
          -- Retornar no erro
          pr_des_erro := 'GENE0002.pc_cria_ZIP --> N�o gerou arquivo "'||vr_dsdestin||'" do(s) arquivos: "'||pr_dsorigem||'"';
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 3 -- Erro cr�tico
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - GENE0002.pc_zipcecred --> Erro n�o tratado na rotina: '||sqlerrm);
        -- Retornar no erro
        pr_des_erro := 'GENE0002.pc_zipcecred --> Erro n�o tratao na rotina: '||sqlerrm;
    END;
  END pc_zipcecred;

  -- Rotina de Impress�o de Arquivos
  PROCEDURE pc_imprim(pr_cdcooper    IN crapcop.cdcooper%TYPE  --> Cooperativa conectada
                     ,pr_cdprogra    IN VARCHAR2               --> Nome do programa que est� executando
                     ,pr_cdrelato    IN craprel.cdrelato%TYPE  --> C�digo do relat�rio solicitado
                     ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE  --> Data movimento atual
                     ,pr_caminho     IN VARCHAR2               --> Path arquivo origem
                     ,pr_nmarqimp    IN VARCHAR2               --> Nome arquivo para impressao
                     ,pr_nmformul    IN VARCHAR2               --> Nome do formul�rio de impress�o
                     ,pr_nrcopias    IN NUMBER                 --> Quantidade de Copias desejadas
                     ,pr_dircop_pdf OUT VARCHAR2               --> Retornar o path de gera��o do PDF
                     ,pr_cdcritic   OUT NUMBER                 --> Retornar c�digo do erro
                     ,pr_dscritic   OUT VARCHAR2) IS           --> Retornar descri��o do erro
  BEGIN
    /* .............................................................................

       Programa: pc_imprim (Antigo Fontes/imprim.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah
       Data    : Novembro/91.                        Ultima atualizacao: 25/02/2014

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outro programa.
       Objetivo  : Executar o comando de impressao no UNIX.

       Op��es de formul�rio(nmformul): "80col,80dcol,132m,132dm,132col,endless,padrao,timbre,etqcorreio,timb132,234dh"

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
                                servidor Web, para visualizacao em Documentos
                                (Junior).

                   16/05/2006 - Efetuar tratamento do campo craprel.inimprel
                                Efetuar impressao(Sim/Nao) (Mirtes)

                   26/05/2006 - Inicializar a variavel aux_dsgerenc com "NAO"
                                (Edson).

                   30/08/2012 - Tratamento crapcop.nmrescop "x(20)" (Diego).

                   23/01/2013 - Convers�o Progress >> PL/SQL (Marcos-Supero)

                   23/08/2013 - Prever novo m�todo de impress�o (Marcos-Supero)

                   12/09/2013 - Altera��o na rotina para retornar se a solicita��o
                                gerou PDF ou n�o. (Marcos-Supero)

                   07/01/2014 - Ajuste para evitar que seja repassado nmformul com
                                espa�os apenas, pois isto gera erro durante a chamada
                                do script (Marcos-Supero)

                   03/01/2014 - Retirado leitura da craptab "FILAIMPRES" (Tiago).

                   08/01/2014 - Inicializar variavel glb_nmformul se nao estiver
                                parametrizada (David).

                   25/02/2014 - Replicar manuten��o progress 02/2014 (Odirlei-AMcom)

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

      -- Gera��o do PDF
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
      -- Testar se o arquivo existe
      IF NOT gene0001.fn_exis_arquivo(pr_caminho|| '/' || pr_nmarqimp) THEN
        -- Levantar exce��o
        pr_dscritic := 'O arquivo gerado n�o existe.';
        RAISE vr_exc_erro;
      END IF;
      -- Buscar nome do diret�rio no cadastro da cooperativa
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Gerar erro caso n�o encontre
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
      -- Verificar se tem caracter inv�lido no nome do arquivo
      IF InStr(pr_nmarqimp,'*') > 0 THEN
        pr_dscritic := 'Caracter invalido no nome do relatorio. --> Arquivo: '|| pr_nmarqimp;
        RAISE vr_exc_erro;
      END IF;
      -- Limpar vari�veis de informa��es do cadastro de relat�rio
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
        -- Copiar as informa��es do cursor
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
      -- Verificar se o nome do formulario � NULL
      IF TRIM(pr_nmformul) IS NULL THEN
        -- Utilizaremos formulario padr�o
        vr_nmformul:= 'padrao';
      ELSE
        -- Utilizaremos o enviado
        vr_nmformul:= pr_nmformul;
      END IF;
      -- Se precisa gerar PDF
      IF vr_ingerpdf = 1 THEN
        -- Extrair a extens�o do nome do arquivo
        vr_nmarqtmp := SubStr(pr_nmarqimp,1,InStr(pr_nmarqimp,'.')-1);
        vr_nmarqpdf := vr_nmarqtmp || '.pdf';
        vr_nmarqtmp := vr_nmarqtmp || '.txt';
        -- Buscar o diret�rio tmppdf da cooperativa conectada
        vr_dircop_txt := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => 'tmppdf');
        -- Tenta abrir o arquivo de log em modo append
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_dircop_txt    --> Diret�rio do arquivo
                                ,pr_nmarquiv => vr_nmarqtmp      --> Nome do arquivo
                                ,pr_tipabert => 'W'              --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_ind_arqtxt    --> Handle do arquivo aberto
                                ,pr_des_erro => pr_dscritic);
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Prepara a linha com as informa��es para gerar o TXT
        vr_setlinha := RPad(rw_crapcop.nmrescop,20,' ')          ||';'||
                       To_Char(pr_dtmvtolt,'YYYY;MM;DD')         ||';'||
                       gene0002.fn_mask(vr_tprelato,'z9')        ||';'||
                       RPAD(vr_nmarqpdf,40,' ')                  ||';'||
                       RPAD(Upper(vr_nmrelato),50,' ')           ||';';
        -- Adiciona a linha de cabecalho
        gene0001.pc_escr_texto_arquivo(vr_ind_arqtxt,vr_setlinha);
        --Fechar Arquivo
        BEGIN
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqtxt);
        EXCEPTION
          WHEN OTHERS THEN
          -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
          pr_dscritic := 'Problema ao fechar o arquivo <'||vr_dircop_txt||'/'||vr_nmarqtmp||'>: ' || sqlerrm;
          RAISE vr_exc_erro;
        END;
        -- Executar a cria��o do PDF
        gene0002.pc_cria_PDF(pr_cdcooper => pr_cdcooper
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

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := Nvl(pr_cdcritic,0);
        pr_dscritic := 'GENE0002.pc_imprim--> '||pr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'GENE0002.pc_imprim --> Erro n�o tratado ao processar a solicita��o. Erro: '||sqlerrm;
    END;
  END pc_imprim;

  /* Rotina para gerar um arquivo do CLOB passado */
  PROCEDURE pc_XML_para_arquivo(pr_XML       IN OUT NOCOPY CLOB     --> Inst�ncia do Clob
                               ,pr_caminho   IN VARCHAR2            --> Diret�rio para sa�da
                               ,pr_arquivo   IN VARCHAR2            --> Nome do arquivo de sa�da
                               ,pr_des_erro  OUT VARCHAR2) IS       --> Retorno de erro, caso ocorra
  BEGIN
    /*..............................................................................

       Programa: pc_XML_para_arquivo
       Autor   : Marcos (Supero)
       Data    : Dezembro/2012                      Ultima atualizacao: 05/12/2012

       Dados referentes ao programa:

       Objetivo  : Efetua leitura das informa��es de um Clob e grava as mesmas em arquivo

       Alteracoes:
       21/03/13 - Petter (Supero): Alterar parser para SAX (classe Java) para melhorar performance.
    ..............................................................................*/
    DECLARE
      -- Vari�veis para tratamento do arquivo
      vr_xML    XMLType;
    BEGIN
      -- Efetuar parser para gerar mensagens de erro e validar XML
      vr_xML := XMLType.createXML(pr_XML);

      DBMS_XSLPROCESSOR.CLOB2FILE(vr_xML.getclobval(), pr_caminho, pr_arquivo, NLS_CHARSET_ID('UTF8'));
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'GENE0002.pc_XML_para_arquivo --> || Erro ao gravar o conte�do do Clob para arquivo: '||sqlerrm;
    END;
  END pc_XML_para_arquivo;

  /* Rotina para gerar um arquivo do XMLType passado */
  PROCEDURE pc_XML_para_arquivo(pr_XML       IN OUT NOCOPY XMLType  --> Inst�ncia do XML Type
                               ,pr_caminho   IN VARCHAR2            --> Diret�rio para sa�da
                               ,pr_arquivo   IN VARCHAR2            --> Nome do arquivo de sa�da
                               ,pr_des_erro  OUT VARCHAR2) IS       --> Retorno de erro, caso ocorra
  BEGIN
    /*..............................................................................

       Programa: pc_XML_para_arquivo
       Autor   : Marcos (Supero)
       Data    : Dezembro/2012                      Ultima atualizacao: 05/12/2012

       Dados referentes ao programa:

       Objetivo  : Efetua leitura das informa��es de um XMLType e grava as mesmas em arquivo

    ..............................................................................*/
    DECLARE
      -- Vari�veis para tratamento do arquivo
      vr_dom_doc DBMS_XMLDOM.DOMDocument;
    BEGIN
      -- Se o XMLTYpe possui informa��es
      IF pr_XML IS NOT NULL THEN
        -- Inicializar o processador Dom
        vr_dom_doc := DBMS_XMLDOM.NewDOMDocument(pr_XML);
        -- Gerar os dados do XML Type para arquivo
        DBMS_XMLDOM.WriteToFile(vr_dom_doc,pr_caminho||'/'||pr_arquivo);
        -- Liberar a mem�ria
        DBMS_XMLDOM.freeDocument(vr_dom_doc);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'GENE0002.pc_XML_para_arquivo --> || Erro ao gravar o conte�do do XMLType para arquivo: '||sqlerrm;
    END;
  END pc_XML_para_arquivo;

  /* Incluir log de gera��o de relat�rios. */
  PROCEDURE pc_gera_log_relato(pr_cdcooper IN crapcop.cdcooper%TYPE --> Coop conectada
                              ,pr_des_log IN VARCHAR2) IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_gera_log_relato
    --  Sistema  : Processos Gen�ricos
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Dezembro/2012.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: ---
    --   Objetivo  : Prever m�todo centralizado de log de Relat�rios
    --
    --   Alteracoes:  31/10/2013 - Troca do arquivo de log para salvar a partir
    --                             de agora no diret�rio log das Cooperativas (Marcos-Supero)
    -- .............................................................................

    DECLARE
      vr_ind_arqlog UTL_FILE.file_type; -- Handle para o arquivo de log
      vr_des_erro VARCHAR2(4000); -- Descri��o de erro
      vr_exc_saida EXCEPTION; -- Sa�da com exception
      vr_des_complet VARCHAR2(100);
      vr_des_diretor VARCHAR2(100);
      vr_des_arquivo VARCHAR2(100);
    BEGIN
      -- Busca o diret�rio de log da Cooperativa
      vr_des_complet := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => 'log');
      -- Adicionar o nome do arquivo de log
      vr_des_complet := vr_des_complet ||'/'|| NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_RELATO'),'proc_gerac_relato.log');
      -- Separa o diret�rio e o nome do arquivo
      gene0001.pc_separa_arquivo_path(pr_caminho => vr_des_complet
                                     ,pr_direto  => vr_des_diretor
                                     ,pr_arquivo => vr_des_arquivo);
      -- Tenta abrir o arquivo de log em modo append
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_des_diretor   --> Diret�rio do arquivo
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
          -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
          vr_des_erro := 'Problema ao escrever no arquivo <'||vr_des_diretor||'/'||vr_des_arquivo||'>: ' || sqlerrm;
          RAISE vr_exc_saida;
      END;
      -- Libera o arquivo
      BEGIN
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
      EXCEPTION
        WHEN OTHERS THEN
          -- Gerar erro
          vr_des_erro := 'Problema ao fechar o arquivo <'||vr_des_diretor||'/'||vr_des_arquivo||'>: ' || sqlerrm;
          RAISE vr_exc_saida;
      END;
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Enviar a mensagem de erro ao DMBS_OUTPUT e ignorar o log
        gene0001.pc_print(to_char(sysdate,'hh24:mi:ss')||' - '|| 'GENE0002.pc_gera_log_relato --> '||vr_des_erro);
      WHEN OTHERS THEN
        -- Temporariamente apenas imprimir na tela
        gene0001.pc_print(pr_des_mensag => to_char(sysdate,'hh24:mi:ss')||' - '
                                           || 'GENE0002.pc_gera_log_relato'
                                           || ' --> Erro n�o tratado : ' || sqlerrm);
    END;
  END pc_gera_log_relato;

    /* Rotina para gerar relatorio o relat�rio solicitado  */
  PROCEDURE pc_gera_relato(pr_nrseqsol IN crapslr.nrseqsol%TYPE    --> Sequencia da solicita��o
                          ,pr_des_erro  OUT VARCHAR2) IS           --> Sa�da com erro
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_gera_relato
    --  Sistema  : Rotinas gen�ricas
    --  Sigla    : GENE
    --  Autor    : Petter Rafael - Supero Tecnologia
    --  Data     : Dezembro/2012.                   Ultima atualizacao: 10/04/2015
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Gerar LST a partir da configura��o de relat�rio montada na
    --              tabela de solicita��es de relat�rio CRAPSLR
    --
    --  Alteracoes: 07/11/2013 - Ajustes na passagem dos par�metros conforme solicita��o
    --                           do Guilherme. Tambem remo��o de valida��es que eram executadas
    --                           aqui e foram repassadas para o momento da solicita��o (Marcos-Supero)
    --
    --              26/12/2013 - Incluir nova funcionalidade onde o relat�rio � gerado no mesmo
    --                           arquivo das solicita��es antigas (append), ao contr�rio da fun��o
    --                           padr�o onde cada relat�rio gera um arquivo novo.
    --
	  --				      17/09/2014 - Aumentar o tamanho do parametro PR_NMRELATO de 40 para 80 caracteres onde a quantidade
	  --							             de colunas for diferentes de 80 ou 132. (Felipe Oliveira)
    --
    --              10/04/2015 - Alterado a chamada do comando "cat" para concatena��o dos relat�rios
    --                           para passar a usar o script concatena_relatorios.sh
    --                           (Adriano).
    -- ...........................................................................
    DECLARE
      -- Buscar dados da solicita��o
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
          FROM crapslr slr
         WHERE slr.nrseqsol = pr_nrseqsol;
      rw_crapslr cr_crapslr%ROWTYPE;
      -- Busca do nome da Cooperativa
      CURSOR cr_crapcop IS
        SELECT REPLACE(cop.nmrescop,Chr(96),Chr(39)) nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = rw_crapslr.cdcooper;
      vr_nmrescop crapcop.nmrescop%TYPE;
      -- Busda dos detalhes do programa em execu��o
      CURSOR cr_crapprg IS
        SELECT prg.nrsolici
          FROM crapprg prg
         WHERE prg.cdcooper = rw_crapslr.cdcooper
           AND prg.cdprogra = UPPER(rw_crapslr.cdprogra);
      rw_crapprg cr_crapprg%ROWTYPE;
      -- Busca do cadastro de relat�rios
      CURSOR cr_craprel(pr_cdrelato craprel.cdrelato%TYPE) IS
        SELECT REPLACE(rel.nmrelato,Chr(96),Chr(39)) nmrelato
              ,rel.nrmodulo
              ,REPLACE(UPPER(rel.nmdestin),Chr(96),Chr(39)) nmdestin
          FROM craprel rel
         WHERE rel.cdcooper = rw_crapslr.cdcooper  --> Coop conectada
           AND rel.cdrelato = pr_cdrelato;         --> C�digo relat�rio vinculado ao m�dulo
      vr_nmrelato craprel.nmrelato%TYPE;
      vr_nrmodulo craprel.nrmodulo%TYPE;
      vr_nmdestin craprel.nmdestin%TYPE;
      -- Vari�vel para o caminho e nome do arquivo base
      vr_nom_direto VARCHAR2(2000);
      vr_nom_arqsai VARCHAR2(2000);
      vr_ext_arqsai VARCHAR2(100);
      vr_nom_arqxml VARCHAR2(2000);
      -- Vari�vel para montagem do comando a ser executado
      vr_des_comando VARCHAR2(2000);
      -- Vari�veis para teste de sa�da da OSCommand
      vr_typ_saida VARCHAR2(10);
      vr_des_saida VARCHAR2(4000);
      -- Vari�veis para armazenar os par�metros
      vr_progerad VARCHAR2(3);
      vr_dsparams VARCHAR2(32767);
      -- Guardar a flag de quebra como number(0/1)
      vr_flsemqueb NUMBER(1);

      --Vari�veis para pegar o caminho base
      vr_dscomora  VARCHAR2(1000);
      vr_dsdirbin  VARCHAR2(1000);

      --Vari�vel para descri��o de comando
      vr_comando   VARCHAR2(32767);

    BEGIN
      -- Busca das informa�oes do relat�rio solicitado
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
        -- Busca dos detalhes do programa em execu��o
        OPEN cr_crapprg;
        FETCH cr_crapprg
         INTO rw_crapprg;
        -- Fechar o cursor para continuar o processo
        CLOSE cr_crapprg;
        -- Se houver c�digo solicita��o gravado na tabela
        IF rw_crapprg.nrsolici = 50 THEN /* TELAS */
          -- Utilizar TEL
          vr_progerad := 'TEL';
        ELSE
          -- Utilizar as ultimas tr�s letras do c�digo do programa
          vr_progerad := substr(lpad(rw_crapslr.cdprogra,7,' '),5);
        END IF;
        -- Incluir espa�os a esquerda em caso necess�rio
        vr_progerad := LPAD(vr_progerad,3,' ');
        -- Busca do cadastro de relat�rios as informa��es do relat�rio
        OPEN cr_craprel(pr_cdrelato => rw_crapslr.cdrelato);
        FETCH cr_craprel
         INTO vr_nmrelato
             ,vr_nrmodulo
             ,vr_nmdestin;
        -- Se n�o encontrar informa��es
        IF cr_craprel%NOTFOUND THEN
          -- enviar valores default
          vr_nmrelato := ' ';
          -- Para 80 colunas ir� nr = 1
          IF rw_crapslr.qtcoluna = 80 THEN
            vr_nrmodulo := 1;
          ELSE
            vr_nrmodulo := 5;
          END IF;
        END IF;
        -- Fechar o cursor
        CLOSE cr_craprel;
        -- Separar a pasta base de sa�da e o nome do arquivo
        gene0001.pc_separa_arquivo_path(pr_caminho  => rw_crapslr.dsarqsai
                                       ,pr_direto   => vr_nom_direto
                                       ,pr_arquivo  => vr_nom_arqxml);
        -- Trocar a extens�o do arquivo
        vr_nom_arqxml := REPLACE(vr_nom_arqxml,gene0001.fn_extensao_arquivo(vr_nom_arqxml),'xml');
        -- Gerar o arquivo de XML com mesmo nome e na mesma pasta do arquivo de sa�da
        gene0002.pc_XML_para_arquivo(pr_XML      => rw_crapslr.dsxmldad
                                    ,pr_caminho  => vr_nom_direto
                                    ,pr_arquivo  => vr_nom_arqxml
                                    ,pr_des_erro => vr_des_saida);
        -- Testar se houve erro
        IF vr_des_saida IS NOT NULL THEN
          -- Gerar exce��o
          RAISE vr_exc_erro;
        END IF;
        -- Testa a existencia do arquivo XML gerado
        IF NOT gene0001.fn_exis_arquivo(vr_nom_direto||'/'||vr_nom_arqxml) THEN
          vr_des_saida := 'N�o foi localizado o arquivo XML gerado: "' || vr_nom_direto||'/'||vr_nom_arqxml || '"';
          RAISE vr_exc_erro;
        END IF;
        -- Armazenar o nome de saida do relat�rio
        vr_nom_arqsai := rw_crapslr.dsarqsai;
        -- Se foi solicitado o relat�rio com Append
        IF rw_crapslr.flappend = 'S' THEN
          -- Guarda a extensao do arquivo de sa�da
          vr_ext_arqsai := gene0001.fn_extensao_arquivo(vr_nom_arqsai);
          -- Remove a extens�o do nome do arquivo
          vr_nom_arqsai := SUBSTR(vr_nom_arqsai,1,LENGTH(vr_nom_arqsai)-LENGTH(vr_ext_arqsai)-1);
          -- Mudar o nome do arquivo para evitar sobscrever o relat�rio antigo
          vr_nom_arqsai := vr_nom_arqsai||'-append'||'.'||vr_ext_arqsai;
        END IF;
        -- Adicionar os par�metros b�sicos na lista de par�metros, s�o eles:
        -- 1 - PR_NMRESCOP => Nome da cooperativa conectada
        -- 2 - PR_NMRELATO => Nome extenso do relat�rio
        -- 3 - PR_DTMVTOLT => Data do movimento atual
        -- 4 - PR_NMMODULO => Nome do m�dulo do sistema (Vetor gene0001.vr_vet_nmmodulo)
        -- 5 - PR_CDRELATO => C�digo do relat�rio
        -- 6 - PR_PROGERAD => C�digo do programa (tres ultimas letras)
        -- 7 - PR_NMDESTIN => Nome destino do cadastro de relat�rio
        -- 8 - PR_SQSOLICI => N�mero da solicita��o
        -- Lembrando que cada tipo de relat�rio pode ter um cabe�alho diferente
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
        -- Monta comando para execu��o via Shell (Java), caso os par�metros do sistemas sejam nulos retorna o path padr�o
        vr_des_comando := nvl(gene0001.fn_param_sistema('CRED',rw_crapslr.cdcooper,'SCRIPT_IREPORT'), 'java -Xms512m -Xmx4000m -jar /usr/coop/ireport/_GeraRelatorio.jar')
                       || ' "'  ||  vr_nom_direto||'/'||vr_nom_arqxml || '" "' || rw_crapslr.dsxmlnod || '" "'
                       || nvl(gene0001.fn_param_sistema('CRED',rw_crapslr.cdcooper,'ROOT_IREPORT'), '/usr/coop/ireport/') || rw_crapslr.dsjasper
                       || '" "' || vr_dsparams || '" "' || vr_nom_arqsai || '" '
                       || rw_crapslr.qtcoluna|| ' ' ||vr_flsemqueb;

        -- Executa comando via Shell
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_des_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_des_saida);

        -- Testa se a sa�da da execu��o acusou erro
        IF length(trim(vr_des_saida)) > 4 THEN
          vr_des_saida := 'Erro na chamada ao Shell: '||vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
        -- Testa para verificar se o arquivo existe
        IF NOT gene0001.fn_exis_arquivo(vr_nom_arqsai) THEN
          vr_des_saida := 'Rotina n�o retornou erro, mas n�o existe o arquivo final: "'||vr_nom_arqsai||'"';
          RAISE vr_exc_erro;
        END IF;
        -- Eliminar o XML gerado
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => 'rm '||vr_nom_direto||'/'||vr_nom_arqxml
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_des_saida);
        -- Testa se a sa�da da execu��o acusou erro
        IF vr_typ_saida = 'ERR' THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapslr.cdcooper
                                    ,pr_ind_tipo_log => 2 --> Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',rw_crapslr.cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(sysdate, 'hh24:mi:ss')
                                                     || ' - '
                                                     || rw_crapslr.cdprogra
                                                     || ' --> ' || 'GENE0002.pc_gera_relato--> '|| REPLACE(vr_des_saida,chr(10),''));

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

            --Gera exce��o
            RAISE vr_exc_erro;

          END IF;

          /*Decorrente a deficiencia do script convertePCL.pl, que tem uma certa limita��o
            em identificar um caracter de quebra de p�gina "^L" sozinho em uma linha, faz com que
            o arquivo seja convertido de forma errada e, consequentemente, se este for convertido para
            pdf (pelo gnupdf.pl) ser� convertido de forma errada. O arquivo ter� v�rias quebras de p�ginas
            indevidas.
            Para contornar este problema, foi desenvolvido o script concatena_relatorios.sh para
            efetuar a concatena��o de forma que o conte�do fique na mesma linha da queba "^LArquivo...".
            Desta forma, o convertePCL.pl conseguir� converter o relat�rio de forma correta e o gnupdf.pl
            tamb�m. Assim, resolvendo o problema.*/
          vr_comando:= vr_dscomora || ' shell ' || vr_dsdirbin || 'concatena_relatorios.sh '||
                       chr(39)||vr_nom_arqsai||chr(39) || ' ' ||
                       chr(39)||rw_crapslr.dsarqsai||chr(39) ||
                       ' > ' ||rw_crapslr.dsarqsai || '.tmp';

          --Executar Comando Unix
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => vr_comando
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_des_saida);

          -- Testa se a sa�da da execu��o acusou erro
          IF vr_typ_saida = 'ERR' THEN
            vr_des_saida := 'Erro ao efetuar concatenacao do relat�rio: '||vr_des_saida;
            RAISE vr_exc_erro;
          END IF;

          -- Efetuar mv do arquivo tempor�rio gerado para o nome real do relat�rio
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => 'mv '||rw_crapslr.dsarqsai||'.tmp  '||rw_crapslr.dsarqsai
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_des_saida);

          -- Testa se a sa�da da execu��o acusou erro
          IF vr_typ_saida = 'ERR' THEN
            vr_des_saida := 'Erro ao efetuar Mv do relat�rio: '||vr_des_saida;
            RAISE vr_exc_erro;
          END IF;

          -- Remover o arquivo do Append
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => 'rm '||vr_nom_arqsai
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_des_saida);
          -- Testa se a sa�da da execu��o acusou erro
          IF vr_typ_saida = 'ERR' THEN
            vr_des_saida := 'Erro ao eliminar o relatorio de append: '||vr_des_saida;
            RAISE vr_exc_erro;
          END IF;
        END IF;
      ELSE
        -- fechar o cursor
        CLOSE cr_crapslr;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro := 'GENE0002.pc_gera_relato--> '||vr_des_saida;
      WHEN OTHERS THEN
        pr_des_erro := 'GENE0002.pc_gera_relato --> Erro n�o tratado ao processar a solicita��o. Erro: '||sqlerrm;
    END;
  END pc_gera_relato;

  /* Procedimento que processa os relat�rios pendentes e chama sua gera��o */
  PROCEDURE pc_process_relato_penden(pr_nrseqsol IN crapslr.nrseqsol%TYPE DEFAULT NULL --> Processar somente a sequencia passada
                                    ,pr_cdfilrel IN crapslr.cdfilrel%TYPE DEFAULT NULL --> Processar todas as sequencias da fila
                                    ,pr_des_erro OUT VARCHAR2) IS
  BEGIN
    /* ..........................................................................

        Programa : pc_process_relato_penden
        Sistema  : Rotinas gen�ricas
        Sigla    : GENE
        Autor    : Marcos E. Martini - Supero
        Data     : Dezembro/2012.                   Ultima atualizacao: 29/12/2015

        Dados referentes ao programa:

         Frequencia: Sempre que for chamado
         Objetivo  : Esta rotina tem as seguintes funcionalidades:

                     a) Em caso de envio de uma solicita��o (pr_nrseqsol)
                        - Processar a solicita��o
                        - N�o commitar no momento
                     b) Em caso de envio de uma fila espec�fica (pr_cdfilrel)
                        - Processar as <n> ultimas solicita��es pendentes da fila

                     Em ambas as situa��es acima ocorre o processo normal, que consiste
                     em gerar o arquivo cfme par�metros, imprimir e gerar para intranet, copiar
                     para diret�rios de rede, enviar e-mail, e enviar log de erro.

         Obs: A rotina nao para o processo em caso de erro na solicita�ao, pois todas devem ser processadas

         Alteracoes: 11/09/2013 - Prevista op��o para converter o arquivo para envio de
                                  email ou c�pia em PDF (Marcos-Supero)

                     17/10/2013 - Somente copiar para intranet/imprimir, enviar por email ou
                                  copiar para diret�rio se o relat�rio possuir pelo menos 1 Byte
                                  (Marcos-Supero)

                     28/10/2013 - Remover a elimina��o de solicita��es antigas daqui e pass�-la
                                  para o processo controlador (pc_controle_filas_relato)
                                - Tamb�m ajustar a busca das solicita��es pendentes para que a
                                  consulta trave o registro (for update). Isto se deve ao fato
                                  da altera��o de sistema que preve que mais do que um job por
                                  fila pode estar ativo. E se n�o travarmos o registro, dois
                                  jobs podem pegar a mesma  solicita��o.
                                - Tamb�m evitar que o processo chame um relat�rio que tenha a
                                  mesma sa�da que outro em processo  (Marcos-Supero)

                     18/11/2013 - Ajustar log de remo��o do arquivo, pois a remo��o pode ser
                                  solicitada inclusive se for solicitado somente a imprim.p,
                                  antes s� era feita na copia/email do relat�rio (Marcos-Supero)


                     08/01/2014 - Altera��o da rotina para deixar din�mico qual a extens�o desejada
                                  para c�pia ou envio de e-mail do relat�rios p�s-processo (Marcos-Supero)

                     12/03/2014 - Altera��o para permitir que o arquivos seja convertido para DOS
                                  antes do envio por e-mail ou c�pia para diret�rio (Marcos-Supero)

                     31/08/2015 - Inclusao do parametro flappend na pc_clob_para_arquivo.
                                  (Jaison/Marcos-Supero)
                     
                     29/12/2015 - Controlar lock na tabela crapslr, para que o lock ocorra a nivel de registro 
                                  e n�o toda a consulta SD379026 (Odirlei-AMcom)             

       ............................................................................. */
    DECLARE
      -- Busca de informa��es da fila
      CURSOR cr_crapfil IS
        SELECT fil.qtreljob
          FROM crapfil fil
         WHERE fil.cdfilrel = pr_cdfilrel;
      -- Quantidade de relat�rios a processar no Job
      vr_qtreljob NUMBER;
      -- Auxiliar para controle da qtdade de relat�rios processados por vez
      vr_qtrelproc NUMBER := 0;
      -- Busca dos relat�rios pendentes de gera��o
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
              ,slr.dsxmldad
              ,slr.flremarq
              ,slr.flappend
          FROM crapslr slr
         WHERE    --> Sempre processa quando passado uma espec�fica
              (   slr.nrseqsol = pr_nrseqsol
                  --> OU aqueles da fila passada, que ainda n�o foram gerados e iniciados
               OR(     slr.cdfilrel = pr_cdfilrel AND slr.flgerado = 'N' AND slr.dtiniger IS NULL
                   --> Evitar que o processo chame um relat�rio que tenha a mesma sa�da que outro em processo
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
      
      -- lockar registro, por�m sem aguardar em caso se ja estar lockado
      CURSOR cr_crapslr_rowid (pr_rowid ROWID) IS
        SELECT slr.rowid,
               slr.dtiniger
          FROM crapslr slr
         WHERE slr.ROWID = pr_rowid
           FOR UPDATE NOWAIT; --> Lockando o registro
      rw_crapslr_rowid cr_crapslr_rowid%ROWTYPE;
      
      -- Configura��o do relat�rio
      CURSOR cr_craprel(pr_cdcooper IN craprel.cdcooper%TYPE
                       ,pr_cdrelato IN craprel.cdrelato%TYPE) IS
        SELECT craprel.tprelato
          FROM craprel craprel
         WHERE craprel.cdcooper = pr_cdcooper
           AND craprel.cdrelato = pr_cdrelato;
      vr_tprelato craprel.tprelato%TYPE;
      vr_dsgerenc VARCHAR2(3) := 'NAO';
      -- Separa�ao do caminho e nome do arquivo
      vr_dsdir VARCHAR2(300);
      vr_dsarq VARCHAR2(300);
      -- Variavel para armazenar o hor�rio de in�cio da solicita��o.
      vr_dthorain DATE;
      -- Lista de diret�rios para c�pia
      vr_lista_copia gene0002.typ_split; --> Split de caminhos
      -- Tipo de sa�da e comando Host
      vr_typ_said VARCHAR2(100);
      vr_des_comando VARCHAR2(4000);
      -- Auxiliar para chamada a impress�o
      vr_cdcritic NUMBER;
      -- Texto auxiliar para escrita no log
      vr_des_log VARCHAR2(32767);
      -- Texto para grava��o do erro na tabela
      vr_dserrger crapslr.dserrger%TYPE;
      -- Caminho de gera��o do PDF p�s imprimp.p
      vr_nmsai_pdf VARCHAR2(400);
      vr_nmdir_pdf VARCHAR2(300);
      vr_nmarq_pdf VARCHAR2(100);
      -- Nome do arquivo para c�pia/e-mail
      vr_nmarq_base  VARCHAR2(300);
      vr_nmarq_copia VARCHAR2(400);
      vr_dsdirconv   VARCHAR2(100);
      -- Tamanho do arquivo
      vr_qtd_bytes NUMBER;
      
    BEGIN
      
      -- Efetuar la�o para processar a quantidade maxima de relat�rios
      LOOP
        -- Busca quantidade maxima de relat�rios por Job na fila
        -- Obs.: Buscamos a cada itera��o justamente para em casos
        --       do gestor alterar esta quantidade quando o job estiver
        --       processando muitos relat�rios por vez, ent�o j� temos
        --       a quantidade atualizada.
        OPEN cr_crapfil;
        FETCH cr_crapfil
         INTO vr_qtreljob;
        CLOSE cr_crapfil;
        -- Incrementa a quantidade de solicita��es processadas
        vr_qtrelproc := vr_qtrelproc + 1;
        -- Limpar variavel de erro
        vr_dserrger := null;
        vr_des_erro := null;
        -- Limpar o caminho de gera��o de PDF
        vr_nmsai_pdf := '';
        -- Busca 1 solicita��o por vez, isso garante que caso algu�m
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
                --> Garantir que nesse meio tempo outro processo j� lockou 
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
              
                -- caso registro j� esteja lockado busca o proximo              
                continue;              
            END;
          END IF;  
          EXIT;          
        END LOOP; 
        
        -- Somente se encontrou registro
        IF cr_crapslr%FOUND THEN
          -- Fechar o cursor
          CLOSE cr_crapslr;
          -- Guardar o in�cio da execu��o
          vr_dthorain := SYSDATE;
          -- Atualizar o registro com a data de in�cio
          BEGIN
            UPDATE crapslr
               SET dtiniger = vr_dthorain
             WHERE rowid = rw_crapslr.rowid;
            -- Se estiver rodando no processo automatizado
            -- j� commita o registro para n�o processa-la mais de uma vez
            IF pr_nrseqsol IS NULL THEN
              -- Commitar os registros processados
              COMMIT;
            END IF;
          END;
          -- Adicionar log
          vr_des_log := chr(13)
                     || to_char(sysdate,'hh24:mi:ss')
                     || ' --> In�cio da gera��o --> Seq '||rw_crapslr.nrseqsol
                     || ', programa '||rw_crapslr.cdprogra
                     || ', saida '||rw_crapslr.dsarqsai;
          -- Separa�ao do caminho e nome do arquivo
          gene0001.pc_separa_arquivo_path(pr_caminho => rw_crapslr.dsarqsai
                                         ,pr_direto  => vr_dsdir
                                         ,pr_arquivo => vr_dsarq);
          -- Se for para gerar o arquivo texto puro
          IF Nvl(rw_crapslr.flarquiv,'N') = 'S' THEN
            -- Criar o arquivo no diretorio especificado
            pc_clob_para_arquivo(pr_clob     => rw_crapslr.dsxmldad
                                ,pr_caminho  => vr_dsdir
                                ,pr_arquivo  => vr_dsarq
                                ,pr_flappend => rw_crapslr.flappend
                                ,pr_des_erro => vr_des_erro);
          ELSE
            -- Chamar a gera��o
            pc_gera_relato(pr_nrseqsol => rw_crapslr.nrseqsol
                          ,pr_des_erro => vr_des_erro);
            -- Setar as propriedades para garantir que o arquivo seja acess�vel por outros usu�rios
            gene0001.pc_OScommand_Shell(pr_des_comando => 'chmod 666 '||vr_dsdir||'/'||vr_dsarq);
          END IF;

          -- Se houve erro
          IF vr_des_erro IS NOT NULL THEN
            -- Adicion�-lo a variavel acumulativa de erro
            vr_dserrger := vr_des_erro;
            -- Adicionar no arquivo de log o problema na execu��o
            vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> Gera��o arquivo com erro --> '||vr_des_erro;
          ELSE
            -- Adicionar no log a execu��o com sucesso
            vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> Gera��o arquivo com �xito em '||fn_calc_difere_datas(vr_dthorain,SYSDATE);
            -- Busca o tamanho do arquivo, pois para enviar para a intranet/impressora
            -- ou copiar para os diret�rios/enviar por email, precisa ter sido gerado algo
            vr_qtd_bytes := GENE0001.fn_tamanho_arquivo(rw_crapslr.dsarqsai);

            -- Se foi solicitado a impress�o e o arquivo possui pelo menos 1 byte
            IF rw_crapslr.flimprim = 'S' AND vr_qtd_bytes > 0 THEN
              -- Guardar a hora de in�cio do processo de impress�o
              vr_dthorain := SYSDATE;
              -- Chamar a rotina de impress�o
              pc_imprim(pr_cdcooper   => rw_crapslr.cdcooper --> Cooperativa conectada
                       ,pr_cdprogra   => rw_crapslr.cdprogra --> Nome do programa que solicitou o rep
                       ,pr_cdrelato   => rw_crapslr.cdrelato --> C�digo do relat�rio solicitado
                       ,pr_dtmvtolt   => rw_crapslr.dtmvtolt --> Data movimento atual
                       ,pr_caminho    => vr_dsdir            --> Path arquivo origem
                       ,pr_nmarqimp   => vr_dsarq            --> Nome arquivo para impressao
                       ,pr_nmformul   => rw_crapslr.nmformul --> Nome do formul�rio de impress�o
                       ,pr_nrcopias   => rw_crapslr.nrcopias --> Quantidade de Copias desejadas
                       ,pr_dircop_pdf => vr_nmsai_pdf       --> Retorna o caminho do PDF gerado pela imprim.p
                       ,pr_cdcritic   => vr_cdcritic         --> C�digo do erro
                       ,pr_dscritic   => vr_des_erro);       --> Sa�da com erro
              -- Testar sa�da com erro
              IF vr_des_erro IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
                -- Adicion�-lo a variavel acumulativa de erro
                vr_dserrger := vr_dserrger || chr(10) || vr_des_erro;
                -- Adicionar no arquivo de log o problema na execu��o
                vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> impressao/copia intranet com erro --> '||vr_des_erro;
              ELSE
                -- Enviar log com o tempo de impress�o e compacta��o PDF
                vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> impressao/copia intranet com �xito em '||fn_calc_difere_datas(vr_dthorain,SYSDATE);
              END IF;
            END IF;

            -- Se foi solicitado email ou c�pia em PDF e o arquivo possui pelo menos 1 byte
            IF (rw_crapslr.dsextcop = 'pdf' OR rw_crapslr.dsextmail = 'pdf') AND vr_qtd_bytes > 0 THEN
              -- Somente se o PDF ainda n�o foi gerado
              IF vr_nmsai_pdf IS NULL THEN
                -- Enviar o LOG da gera��o do PDF
                vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> Seq '||rw_crapslr.nrseqsol||' --> convertendo para PDF devido envio ou c�pia do relat�rio em PDF.';
                -- Buscar configura��o do relat�rio
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
                -- Executar a cria��o do PDF
                gene0002.pc_cria_PDF(pr_cdcooper => rw_crapslr.cdcooper
                                    ,pr_nmorigem => vr_dsdir||'/'||vr_dsarq
                                    ,pr_ingerenc => vr_dsgerenc
                                    ,pr_tirelato => NVL(rw_crapslr.nmformul,'padrao')
                                    ,pr_dtrefere => rw_crapslr.dtmvtolt
                                    ,pr_nmsaida  => vr_nmsai_pdf
                                    ,pr_des_erro => vr_des_erro);
                -- Se houve erro
                IF vr_des_erro IS NOT NULL THEN
                  -- Mandar o arquivo original pois n�o temos como enviar o PDF com erro
                  vr_nmsai_pdf := vr_dsdir||'/'||vr_dsarq;
                  -- Adicionar LOG do erro
                  vr_dserrger := vr_dserrger || chr(10) || ' --> erro na convers�o do arquivo para PDF --> '||vr_des_erro;
                  -- O comando shell executou com erro, gerar log
                  vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> erro na convers�o do arquivo para PDF  --> '||vr_des_erro;
                END IF;
              END IF;
              -- Separar path e nome do arquivo PDF
              gene0001.pc_separa_arquivo_path(pr_caminho => vr_nmsai_pdf
                                             ,pr_direto  => vr_nmdir_pdf
                                             ,pr_arquivo => vr_nmarq_pdf);
            END IF;

            -- Se foi solicitado a c�pia do relat�rio para um ou mais diret�rios
            IF rw_crapslr.dspathcop IS NOT NULL THEN
              -- Troca todas as virgulas por ponto e virgula, para facilitar a busca abaixo
              rw_crapslr.dspathcop := REPLACE(rw_crapslr.dspathcop,',',';');
              -- Quebra string retornada da consulta pelo delimitador ';'
              vr_lista_copia := gene0002.fn_quebra_string(rw_crapslr.dspathcop, ';');
              -- Se foi solicitada a c�pia do arquivo em PDF
              IF rw_crapslr.dsextcop = 'pdf' THEN
                -- Copiaremos o PDF
                vr_nmarq_base := vr_nmdir_pdf||'/'||vr_nmarq_pdf;
                -- Nome do arquivo p�s copia continua o mesmo do PDF
                vr_nmarq_copia := vr_nmarq_pdf;
              ELSE
                -- A base para c�pia � o arquivo original
                vr_nmarq_base := vr_dsdir||'/'||vr_dsarq;
                -- Se foi qualquer outra extens�o
                IF rw_crapslr.dsextcop IS NOT NULL THEN
                  -- Montamos o novo nome do arquivo trocando a extens�o original pela nova
                  vr_nmarq_copia := REPLACE(vr_dsarq,gene0001.fn_extensao_arquivo(vr_dsarq),rw_crapslr.dsextcop);
                ELSE
                  -- Mantemos o nome do arquivo original
                  vr_nmarq_copia := vr_dsarq;
                END IF;
              END IF;
              -- Itera sobre o array para encontrar se foi possivel retornar 1 ou mais caminhos para c�pia
              IF vr_lista_copia.count > 0 THEN
                -- Ler todos os registros do vetor de caminhos
                FOR vr_idx IN 1..vr_lista_copia.count LOOP
                  -- Enviar o LOG de c�pia do arquivo
                  vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> copiando/convertendo arquivo para '||vr_lista_copia(vr_idx);
                  -- Remover / a direita para evitar problemas no comando CP
                  vr_lista_copia(vr_idx) := RTRIM(vr_lista_copia(vr_idx),'/');
                  -- Se foi solicitada a convers�o para DOS
                  IF rw_crapslr.fldoscop = 'S' AND nvl(rw_crapslr.dsextcop,' ') != 'pdf' THEN
                    -- Executa comando UX2DOS concatenando o comando auxiliar (se existir)
                    vr_des_comando := 'ux2dos < ' || vr_nmarq_base || ' ' || rw_crapslr.dscmaxcop ||' > ' ||vr_lista_copia(vr_idx)||'/'||vr_nmarq_copia||' 2>/dev/null';
                  ELSE -- Sen�o, apenas faz a c�pia
                    vr_des_comando := 'cp '||vr_nmarq_base||' '||vr_lista_copia(vr_idx)||'/'||vr_nmarq_copia;
                  END IF;
                  -- Para cada caminho, executar o comando montado acima
                  gene0001.pc_OScommand_Shell(pr_des_comando => vr_des_comando
                                             ,pr_typ_saida   => vr_typ_said
                                             ,pr_des_saida   => vr_des_erro);
                  -- Testar erro
                  IF vr_typ_said = 'ERR' THEN
                    -- Adicionar o erro na variavel acumulativa de erros
                    vr_dserrger := vr_dserrger || chr(10) || ' --> erro na copia/convers�o do arquivo --> '||vr_des_erro;
                    -- O comando shell executou com erro, gerar log
                    vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> erro na copia/convers�o do arquivo --> '||vr_des_erro;
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
                -- Nome do arquivo p�s copia continua o mesmo do PDF
                vr_nmarq_copia := vr_nmarq_pdf;
              ELSE
                -- A base para c�pia � o arquivo original
                vr_nmarq_base := vr_dsdir||'/'||vr_dsarq;
                -- Se foi qualquer outra extens�o
                IF trim(rw_crapslr.dsextmail) IS NOT NULL THEN
                  -- Montamos o novo nome do arquivo trocando a extens�o original pela nova
                  vr_nmarq_copia := REPLACE(vr_dsarq,gene0001.fn_extensao_arquivo(vr_dsarq),rw_crapslr.dsextmail);
                ELSE
                  -- Mantemos o mesmo nome do arquivo original
                  vr_nmarq_copia := vr_dsarq;
                END IF;
              END IF;

              -- Busca do diret�rio converte
              vr_dsdirconv := gene0001.fn_diretorio(pr_cdcooper => rw_crapslr.cdcooper
                                                   ,pr_tpdireto => 'C'
                                                   ,pr_nmsubdir => 'converte');

              -- Se foi solicitada a convers�o para DOS antes de enviar
              IF rw_crapslr.fldosmail = 'S' AND nvl(rw_crapslr.dsextmail,' ') != 'pdf' THEN
                -- Executa comando UX2DOS concatenando o comando auxiliar (se existir)
                vr_des_comando := 'ux2dos < ' || vr_nmarq_base || ' ' || rw_crapslr.dscmaxmail ||' > ' ||vr_dsdirconv||'/'||vr_nmarq_copia||' 2>/dev/null';
              ELSE -- Sen�o, apenas faz a c�pia
                vr_des_comando := 'cp '||vr_nmarq_base||' '||vr_dsdirconv||'/'||vr_nmarq_copia;
              END IF;
              -- Para cada caminho, executar o comando montado acima
              gene0001.pc_OScommand_Shell(pr_des_comando => vr_des_comando
                                         ,pr_typ_saida   => vr_typ_said
                                         ,pr_des_saida   => vr_des_erro);
              -- Testar erro
              IF vr_typ_said = 'ERR' THEN
                -- Adicionar o erro na variavel acumulativa de erros
                vr_dserrger := vr_dserrger || chr(10) || ' --> erro na copia/convers�o do arquivo para envio de e-mail --> '||vr_des_erro;
                -- O comando shell executou com erro, gerar log
                vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> erro na copia/convers�o do arquivo para envio de email --> '||vr_des_erro;
              ELSE
                -- Enviar o relat�rio por e-mail
                gene0003.pc_solicita_email(pr_cdcooper        => rw_crapslr.cdcooper
                                          ,pr_flg_remete_coop => 'S' --> Envio pelo e-mail da Cooperativa
                                          ,pr_cdprogra        => rw_crapslr.cdprogra
                                          ,pr_des_destino     => rw_crapslr.dsmailcop
                                          ,pr_des_assunto     => rw_crapslr.dsassmail
                                          ,pr_des_corpo       => rw_crapslr.dscormail
                                          ,pr_des_anexo       => vr_dsdirconv||'/'||vr_nmarq_copia
                                          ,pr_flg_remove_anex => 'N' --> Manter o arquivo no diret�rio converte
                                          ,pr_des_erro        => vr_des_erro);
                -- Se houver erro
                IF vr_des_erro IS NOT NULL THEN
                  -- Adicionar o erro na variavel acumulativa de erros
                  vr_dserrger := vr_dserrger || chr(10) || ' --> solicita��o envio de email com erro --> '||vr_des_erro;
                  -- Gerar log
                  vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> solicita��o envio de email com erro --> '||vr_des_erro;
                END IF;
              END IF;
            END IF;

            -- Se foi solicitado para remover o arquivo de origem
            IF rw_crapslr.flremarq = 'S' THEN
              -- Enviar o LOG de c�pia do arquivo
              vr_des_log := vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> removendo o arquivo ap�s c�pia/email/impressao';
              -- Para cada caminho, executar o comando de c�pia
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

          -- Por fim, ir� atualizar o registro na tabela com a data final e
          -- o texto acumulativo de erro, que pode estar vazio caso n�o tenha
          -- ocorrido nenhum imprevisto no processo
          BEGIN
            UPDATE crapslr
               SET flgerado = 'S'
                  ,dtfimger = sysdate
                  ,dserrger = vr_dserrger
             WHERE rowid = rw_crapslr.rowid;
          END;

          -- Enviar o LOG da gera��o do relat�rio
          pc_gera_log_relato(rw_crapslr.cdcooper,vr_des_log || chr(10) || to_char(sysdate,'hh24:mi:ss')||' --> T�rmino da gera��o --> Seq '||rw_crapslr.nrseqsol||'.');
          -- Se estiver rodando no processo automatizado
          IF pr_nrseqsol IS NULL THEN
            -- Commitar o registro processado
            COMMIT;
          ELSE
            -- Retornar se houver algum erro
            pr_des_erro := vr_dserrger;
            -- Sair do la�o pois � necess�rio apenas uma intera��o
            EXIT;
          END IF;
        ELSE
          -- Fechar o cursor pq n�o encontrou nada
          CLOSE cr_crapslr;
          -- Sair do processo pois n�o h� mais registros
          EXIT;
        END IF;
        -- Sair do processo por fila em caso de ter processado a quantidade m�xima por JOB
        IF vr_qtrelproc >= vr_qtreljob THEN
          EXIT;
        END IF;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        -- Gerar Log
        pc_gera_log_relato(0,to_char(sysdate,'hh24:mi:ss')||' --> Erro n�o tratado ao processar relat�rios pendentes --> '|| sqlerrm);
    END;
  END pc_process_relato_penden;

  -- Subrotina simples para corrigir extens�es informadas erroneamente
  FUNCTION fn_replace_extensao(pr_dsext IN VARCHAR2) RETURN VARCHAR2 IS
    vr_dsext crapslr.dsextcop%TYPE;
  BEGIN
    -- converter para min�sculo
    vr_dsext := lower(pr_dsext);
    -- remover espa�os
    vr_dsext := trim(vr_dsext);
    -- remover . se houver no in�cio ou no fim
    vr_dsext := ltrim(rtrim(vr_dsext,'.'),'.');
    -- retornar valor ajustado
    RETURN vr_dsext;
  END;

  /* Rotina para solicitar gera��o de relatorio em PDF a partir de um XML de dados */
  PROCEDURE pc_solicita_relato(pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Cooperativa conectada
                              ,pr_cdprogra  IN crapprg.cdprogra%TYPE    --> Programa chamador
                              ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE    --> Data do movimento atual
                              ,pr_dsxml     IN OUT NOCOPY CLOB          --> Arquivo XML de dados
                              ,pr_dsxmlnode IN VARCHAR2                 --> N� do XML para itera��o
                              ,pr_dsjasper  IN VARCHAR2                 --> Arquivo de layout do iReport
                              ,pr_dsparams  IN VARCHAR2                 --> Array de parametros diversos
                              ,pr_dsarqsaid IN VARCHAR2                 --> Path/Nome do arquivo PDF gerado
                              ,pr_flg_gerar IN VARCHAR2 DEFAULT 'N'     --> Gerar o arquivo na hora
                              ,pr_qtcoluna  IN NUMBER                   --> Qtd colunas do relat�rio (80,132,234)
                              ,pr_sqcabrel  IN NUMBER DEFAULT 1         --> Sequencia do relatorio (cabrel 1..5)
                              ,pr_cdrelato  IN NUMBER DEFAULT NULL      --> C�digo fixo para o relat�rio (nao busca pelo sqcabrel)
                              ,pr_cdfilrel  IN VARCHAR2 DEFAULT NULL    --> Fila para o relat�rio
                              ,pr_nrseqpri  IN NUMBER DEFAULT NULL      --> Prioridade para o relat�rio (0..5)
                              ,pr_flg_impri IN VARCHAR2 DEFAULT 'N'     --> Chamar a impress�o (Imprim.p)
                              ,pr_nmformul  IN VARCHAR2 DEFAULT NULL    --> Nome do formul�rio para impress�o
                              ,pr_nrcopias  IN NUMBER   DEFAULT NULL    --> N�mero de c�pias para impress�o
                              ,pr_dspathcop IN VARCHAR2 DEFAULT NULL    --> Lista sep. por ';' de diret�rios a copiar o relat�rio
                              ,pr_dsextcop  IN VARCHAR2 DEFAULT NULL    --> Extens�o para c�pia do relat�rio aos diret�rios
                              ,pr_fldoscop  IN VARCHAR2 DEFAULT 'N'     --> Flag para converter o arquivo gerado em DOS antes da c�pia
                              ,pr_dscmaxcop IN VARCHAR2 DEFAULT NULL    --> Comando auxiliar para o comando ux2dos na c�pia de diret�rio
                              ,pr_dsmailcop IN VARCHAR2 DEFAULT NULL    --> Lista sep. por ';' de emails para envio do relat�rio
                              ,pr_dsassmail IN VARCHAR2 DEFAULT NULL    --> Assunto do e-mail que enviar� o relat�rio
                              ,pr_dscormail IN VARCHAR2 DEFAULT NULL    --> HTML corpo do email que enviar� o relat�rio
                              ,pr_dsextmail IN VARCHAR2 DEFAULT NULL    --> Extens�o para envio do relat�rio
                              ,pr_fldosmail IN VARCHAR2 DEFAULT 'N'     --> Flag para converter o arquivo gerado em DOS antes do e-mail
                              ,pr_dscmaxmail IN VARCHAR2 DEFAULT NULL    --> Comando auxiliar para o comando ux2dos no envio de e-mail
                              ,pr_flgremarq IN VARCHAR2 DEFAULT 'N'     --> Flag para remover o arquivo ap�s c�pia/email
                              ,pr_flsemqueb IN VARCHAR2 DEFAULT 'N'     --> Flag S/N para n�o gerar quebra no relat�rio
                              ,pr_flappend  IN VARCHAR2 DEFAULT 'N'     --> Indica que a solicita��o ir� incrementar o arquivo
                              ,pr_parser    IN VARCHAR2 DEFAULT 'D'     --> Seleciona o tipo do parser. "D" para VTD e "R" para Jasper padr�o
                              ,pr_des_erro  OUT VARCHAR2) IS            --> Sa�da com erro
  BEGIN
    /* ..........................................................................
    --
    --  Programa : pc_solicita_relato
    --  Sistema  : Rotinas gen�ricas
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Dezembro/2012.                   Ultima atualizacao: 22/09/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Esta rotina recebe os par�metros necessarios para a gera��o de relat�rio
    --               e grava as informa�oes na tabela CRAPSLR para processamento posterior.
    --   Obs: Em caso de solicita��o para gera��o na hora, o mesmo � efetuado j� neste momento.
    --
    --   Alteracoes: 14/06/2013 - Incluso flag para remover o arquivo original ap�s
    --                            copiar ou enviar e-mail (Marcos-Supero)
    --
    --               11/09/2013 - Inclu�do par�metro para converter o arquivo para envio de
    --                            email em PDF (Marcos-Supero)
    --
    --               01/10/2013 - N�o parar o processo durante a solicita��o, mas sim gravar
    --                            a crapslr com erro, e gerar no log o erro (Marcos-Supero)
    --
    --               28/10/2013 - Gravar a nova flag para saber se a solicita��o est� no batch
    --                            ou n�o atraves da busca na crapdat.inproces (Marcos-Supero)
    --
    --               07/11/2013 - Inclus�o da valida��o do Jasper na solicita��o, antes estava
    --                            na gera��o (Marcos-Supero)
    --
    --               18/11/2013 - Ajustar consistencia de remo��o do arquivo, pois a mesma pode
    --                            ser solicitada inclusive se for solicitado somente a imprim.p,
    --                            antes s� era feita na copia/email do relat�rio (Marcos-Supero)
    --
    --               08/01/2014 - Altera��o da rotina para deixar din�mico qual a extens�o desejada
    --                            para c�pia ou envio de e-mail do relat�rios p�s-processo (Marcos-Supero)
    --
    --               12/03/2014 - Preparar a execu��o para converter o arquivo de unix para dos (Marcos-Supero)
    --
    --               22/09/2015 - Adicionar valida��o para quando o relatorio for solicitado durante o processo
    --                            batch, o erro seja escrito no proc_batch, caso contrario no proc_message
    --                            (Douglas - Chamado 306525)
    -- ............................................................................. */
    DECLARE
      -- Busca do indicador do processo no calend�rio
      CURSOR cr_crapdat IS
        SELECT inproces
          FROM crapdat
         WHERE cdcooper = pr_cdcooper;
      vr_inproces crapdat.inproces%TYPE;
      vr_flgbatch crapslr.flgbatch%TYPE := 0;
      -- Busca dos detalhes do programa em execu��o
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
           AND prg.cdprogra = UPPER(pr_cdprogra);
      rw_crapprg cr_crapprg%ROWTYPE;
      -- Busca do cadastro de relat�rios
      CURSOR cr_craprel(pr_cdrelato craprel.cdrelato%TYPE) IS
        SELECT rel.cdfilrel
              ,rel.nrseqpri
          FROM craprel rel
         WHERE rel.cdcooper = pr_cdcooper
           AND rel.cdrelato = pr_cdrelato; --> C�digo relat�rio vinculado ao m�dulo
      rw_craprel cr_craprel%ROWTYPE;
      -- Busca da fila de emiss�o
      CURSOR cr_crapfil IS
        SELECT flgativa
          FROM crapfil
         WHERE cdfilrel = rw_craprel.cdfilrel;
      vr_flgativa crapfil.flgativa%TYPE;
      -- Sequencia gravada na tabela de relat�rios
      vr_nrseqsol crapslr.nrseqsol%TYPE;
      -- Guardar flag de gera��o e erros para o caso de
      -- encontrarmos problemas antes de solicitar
      vr_flgerado crapslr.flgerado%TYPE := 'N'; --> Default � ainda n�o gerado
      vr_dserrger crapslr.dserrger%TYPE;

      -- Guardar extens�es pada copia/email
      vr_dsextmail crapslr.dsextmail%TYPE;
      vr_dsextcop  crapslr.dsextcop%TYPE;

    BEGIN
      -- Cria��o de bloco para tratar todos os poss�veis problemas na solicita��o
      BEGIN
        -- Busca do indicador do processo no calend�rio
        OPEN cr_crapdat;
        FETCH cr_crapdat
         INTO vr_inproces;
        CLOSE cr_crapdat;
        -- Inproces = 1 eh Online, maior que isso � Batch
        IF vr_inproces = 1 THEN
          -- Online
          vr_flgbatch := 0;
        ELSE
          -- Batch
          vr_flgbatch := 1;
        END IF;
        -- Busca dos detalhes do programa em execu��o
        OPEN cr_crapprg (pr_cdcooper => pr_cdcooper
                        ,pr_cdprogra => pr_cdprogra
                        ,pr_sqcabrel => pr_sqcabrel);
        FETCH cr_crapprg INTO rw_crapprg;
        -- Caso o programa n�o exista
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
          vr_dserrger := 'Solicita��o com n�mero de colunas inv�lido: '||pr_qtcoluna;
          RAISE vr_exc_erro;
        END IF;
        -- Se foi enviado um c�digo de programa ao inv�s do sqcabrel
        IF pr_cdrelato IS NOT NULL THEN
          -- Substituir o c�digo de relat�rio encontrado atrav�s
          -- do sqcabrel com este c�digo enviado
          rw_crapprg.cdrelato := pr_cdrelato;
        END IF;
        -- Testar se o m�dulo possui relat�rio vinculado
        IF NVL(rw_crapprg.cdrelato,0) = 0 THEN
          -- Gerar erro
          vr_dserrger := 'Programa '||pr_cdprogra||' n�o possui o c�digo do relat�rio vinculado.';
          RAISE vr_exc_erro;
        END IF;
        -- Busca do cadastro de relat�rios as informa��es do relat�rio
        OPEN cr_craprel(pr_cdrelato => rw_crapprg.cdrelato);
        FETCH cr_craprel
         INTO rw_craprel;
        -- Fechar o cursor para continuar o processo
        CLOSE cr_craprel;
        -- Se foi enviado uma fila espec�fica
        IF trim(pr_cdfilrel) IS NOT NULL THEN
          -- Utiliz�-la, ao inv�s da encontrada no cadastro do relat�rio
          rw_craprel.cdfilrel := pr_cdfilrel;
        END IF;
        -- Se foi enviada uma prioridade espec�fica
        IF trim(pr_nrseqpri) IS NOT NULL THEN
          -- Utiliz�-la, ao inv�s da cadastrada no relat�rio
          rw_craprel.nrseqpri := pr_nrseqpri;
        END IF;
        -- Por fim, em caso de n�o ter encontrado fila e prioridade
        -- no cadastro do relat�rio ou pela solicita��o do relat�rio
        -- ent�o utilizamos o NVL abaixo e buscamos a parametriza��o
        -- do sistema em COD_FILA_REL_PADRAO e NUM_PRIOR_REL_PADRAO
        rw_craprel.cdfilrel := NVL(rw_craprel.cdfilrel,gene0001.fn_param_sistema('CRED',pr_cdcooper,'COD_FILA_RELATO'));
        rw_craprel.nrseqpri := NVL(rw_craprel.nrseqpri,gene0001.fn_param_sistema('CRED',pr_cdcooper,'NUM_PRIOR_RELATO'));
        -- Somente continuar se a fila enviada estiver ativa
        OPEN cr_crapfil;
        FETCH cr_crapfil
         INTO vr_flgativa;
        -- Se n�o encontrar ou a fila estiver inativa
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
        -- Se foi solicitada a remo��o do arquivo original
        IF pr_flgremarq = 'S' THEN
          -- Somente continuar se foi indicado a impress�o ou algum email ou diret�rio para c�pia do arquivo
          IF trim(pr_dspathcop) IS NULL AND trim(pr_dsmailcop) IS NULL AND pr_flg_impri = 'N' THEN
            vr_dserrger := 'Voce nao pode remover o arquivo se n�o h� diret�rio / email para envio, ou impressao do relatorio.';
            RAISE vr_exc_erro;
          END IF;
        END IF;
        -- Testa a existencia do arquivo de layout (JASPER) enviado.
        IF NOT gene0001.fn_exis_arquivo(nvl(gene0001.fn_param_sistema('CRED',pr_cdcooper,'ROOT_IREPORT'), '/usr/coop/ireport/') || pr_dsjasper) THEN
          vr_dserrger := 'N�o foi localizado o arquivo "' || nvl(gene0001.fn_param_sistema('CRED',pr_cdcooper,'ROOT_IREPORT'), '/usr/coop/ireport/') || pr_dsjasper || '"';
          RAISE vr_exc_erro;
        END IF;
      EXCEPTION
        WHEN vr_exc_erro THEN
          -- Incluir mensagem padr�o inicial
          vr_dserrger := 'Relatorio '||pr_dsarqsaid||' nao sera processado. Motivo: '|| vr_dserrger;
          -- E tamb�m setar a flag de gerado como 'S' para que o
          -- mecanismo n�o tente ger�-lo j� que encontrarmos erro
          vr_flgerado := 'S';
      END;
      -- Guardar extens�es pada copia/email
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
                           ,flappend)
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
                           ,pr_flappend)
                  RETURNING nrseqsol INTO vr_nrseqsol;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dserrger := 'Solicita��o do Relatorio '||pr_dsarqsaid||' com erro ao inserir. Motivo: '|| sqlerrm;
      END;
      -- Se foi solicitado o envio na hora e n�o houve erro na solicita��o
      IF pr_flg_gerar = 'S' AND vr_dserrger IS NULL THEN
        -- Chamar o processamento de solicita��es pendentes passando-a
        pc_process_relato_penden(pr_nrseqsol => vr_nrseqsol
                                ,pr_des_erro => vr_dserrger);
      END IF;

      -- Se n�o saimos pela exce��o acima e houve erro
      IF vr_dserrger IS NOT NULL THEN
        -- Validar se o relatorio foi solicitado no processo batch
        IF vr_flgbatch = 1 THEN
          -- Enviar ao LOG Batch
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 --> Erro tratato
                                    ,pr_des_log      => to_char(sysdate, 'hh24:mi:ss')
                                                     || ' - '
                                                     || pr_cdprogra
                                                     || ' --> ' || vr_dserrger);
        ELSE
          -- Escrever No LOG proc_message
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 --> Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(sysdate, 'hh24:mi:ss')
                                                     || ' - '
                                                     || pr_cdprogra
                                                     || ' --> ' || vr_dserrger);
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN -- Gerar log de erro
        -- Retornar o erro contido na sqlerrm
        pr_des_erro := 'GENE0002.pc_solicita_relato --> ' || sqlerrm;
    END;
  END pc_solicita_relato;

  /* Rotina para solicitar gera��o de arquivo lst a partir de um XML de dados */
  PROCEDURE pc_solicita_relato_arquivo(pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Cooperativa conectada
                                      ,pr_cdprogra  IN crapprg.cdprogra%TYPE    --> Programa chamador
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE    --> Data do movimento atual
                                      ,pr_dsxml     IN OUT NOCOPY CLOB          --> Arquivo XML de dados
                                      ,pr_dsarqsaid IN VARCHAR2                 --> Path/Nome do arquivo PDF gerado
                                      ,pr_cdrelato  IN NUMBER DEFAULT NULL      --> C�digo fixo para o relat�rio
                                      ,pr_flg_impri IN VARCHAR2 DEFAULT 'N'     --> Chamar a impress�o (Imprim.p)
                                      ,pr_flg_gerar IN VARCHAR2 DEFAULT 'N'     --> Gerar o arquivo na hora
                                      ,pr_nmformul  IN VARCHAR2 DEFAULT NULL    --> Nome do formul�rio para impress�o
                                      ,pr_nrcopias  IN NUMBER   DEFAULT NULL    --> N�mero de c�pias para impress�o
                                      ,pr_dspathcop IN VARCHAR2 DEFAULT NULL    --> Lista sep. por ';' de diret�rios a copiar o arquivo
                                      ,pr_fldoscop  IN VARCHAR2 DEFAULT 'N'     --> Flag para converter o arquivo gerado em DOS antes da c�pia
                                      ,pr_dscmaxcop IN VARCHAR2 DEFAULT NULL    --> Comando auxiliar para o comando ux2dos na c�pia de diret�rio
                                      ,pr_dsextcop  IN VARCHAR2 DEFAULT NULL    --> Extens�o para c�pia do relat�rio aos diret�rios
                                      ,pr_dsmailcop IN VARCHAR2 DEFAULT NULL    --> Lista sep. por ';' de emails para envio do arquivo
                                      ,pr_dsassmail IN VARCHAR2 DEFAULT NULL    --> Assunto do e-mail que enviar� o arquivo
                                      ,pr_dscormail IN VARCHAR2 DEFAULT NULL    --> HTML corpo do email que enviar� o arquivo
                                      ,pr_dsextmail IN VARCHAR2 DEFAULT NULL    --> Extens�o para envio do relat�rio
                                      ,pr_fldosmail IN VARCHAR2 DEFAULT 'N'     --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                      ,pr_dscmaxmail IN VARCHAR2 DEFAULT NULL    --> Comando auxiliar para o comando ux2dos no envio de e-mail
                                      ,pr_flgremarq IN VARCHAR2 DEFAULT 'N'     --> Flag para remover o arquivo ap�s c�pia/email
                                      ,pr_flappend  IN VARCHAR2 DEFAULT 'N'     --> Indica que a solicita��o ir� incrementar o arquivo
                                      ,pr_des_erro  OUT VARCHAR2) IS            --> Sa�da com erro
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_solicita_relato_arquivo
    --  Sistema  : Rotinas gen�ricas
    --  Sigla    : GENE
    --  Autor    : Alisson C. Berrido - Amcom
    --  Data     : Abril/2013.                   Ultima atualizacao: 31/08/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Esta rotina recebe os par�metros necessarios para a gera��o do arquivo
    --               e grava as informa�oes na tabela CRAPSLR para processamento posterior.
    --   Obs: Em caso de solicita��o para gera��o na hora, o mesmo � efetuado j� neste momento.
    --
    --   Alteracoes: 14/06/2013 - Incluso flag para remover o arquivo original ap�s
    --                            copiar ou enviar e-mail
    --
    --               01/10/2013 - N�o parar o processo durante a solicita��o, mas sim gravar
    --                            a crapslr com erro, e gerar no log o erro (Marcos-Supero)
    --
    --               28/10/2013 - Gravar a nova flag para saber se a solicita��o est� no batch
    --                            ou n�o atraves da busca na crapdat.inproces (Marcos-Supero)
    --
    --               18/11/2013 - Ajustar consistencia de remo��o do arquivo, pois a mesma pode
    --                            ser solicitada inclusive se for solicitado somente a imprim.p,
    --                            antes s� era feita na copia/email do relat�rio (Marcos-Supero)
    --
    --               09/01/2013 - Altera��o da rotina para deixar din�mico qual a extens�o desejada
    --                            para c�pia ou envio de e-mail do relat�rios p�s-processo (Marcos-Supero)
    --
    --               12/03/2014 - Preparar a execu��o para converter o arquivo de unix para dos (Marcos-Supero)
    --
    --               31/08/2015 - Inclusao do parametro flappend. (Jaison/Marcos-Supero)
    -- .............................................................................
    DECLARE
      -- Busca do indicador do processo no calend�rio
      CURSOR cr_crapdat IS
        SELECT inproces
          FROM crapdat
         WHERE cdcooper = pr_cdcooper;
      vr_inproces crapdat.inproces%TYPE;
      vr_flgbatch crapslr.flgbatch%TYPE := 0;
      -- Busda dos detalhes do programa em execu��o
      CURSOR cr_crapprg IS
        SELECT prg.nrsolici
          FROM crapprg prg
         WHERE prg.cdcooper = pr_cdcooper
           AND prg.cdprogra = UPPER(pr_cdprogra);
      rw_crapprg cr_crapprg%ROWTYPE;
      -- Busca do cadastro de relat�rios
      CURSOR cr_craprel(pr_cdrelato craprel.cdrelato%TYPE) IS
        SELECT rel.cdfilrel
              ,rel.nrseqpri
          FROM craprel rel
         WHERE rel.cdcooper = pr_cdcooper
           AND rel.cdrelato = pr_cdrelato; --> C�digo relat�rio vinculado ao m�dulo
      rw_craprel cr_craprel%ROWTYPE;
      -- Busca da fila de emiss�o
      CURSOR cr_crapfil IS
        SELECT flgativa
          FROM crapfil
         WHERE cdfilrel = rw_craprel.cdfilrel;
      vr_flgativa crapfil.flgativa%TYPE;
      -- Sequencia gravada na tabela de relat�rios
      vr_nrseqsol crapslr.nrseqsol%TYPE;
      -- Guardar flag de gera��o e erros para o caso de
      -- encontrarmos problemas antes de solicitar
      vr_flgerado crapslr.flgerado%TYPE := 'N'; --> Default � ainda n�o gerado
      vr_dserrger crapslr.dserrger%TYPE;
      -- Guardar extens�es pada copia/email
      vr_dsextmail crapslr.dsextmail%TYPE;
      vr_dsextcop  crapslr.dsextcop%TYPE;
    BEGIN
      -- Cria��o de bloco para tratar todos os poss�veis problemas na solicita��o
      BEGIN
        -- Busca do indicador do processo no calend�rio
        OPEN cr_crapdat;
        FETCH cr_crapdat
         INTO vr_inproces;
        CLOSE cr_crapdat;
        -- Inproces = 1 eh Online, maior que isso � Batch
        IF vr_inproces = 1 THEN
          -- Online
          vr_flgbatch := 0;
        ELSE
          -- Batch
          vr_flgbatch := 1;
        END IF;
        -- Busca dos detalhes do programa em execu��o
        OPEN cr_crapprg;
        FETCH cr_crapprg
         INTO rw_crapprg;
        -- Caso o programa n�o exista
        IF cr_crapprg%NOTFOUND THEN
          -- Fechar o cursor pois teremos um raise
          CLOSE cr_crapprg;
          vr_dserrger := 'Programa '||pr_cdprogra||' inexistente na tabela CRAPPRG';
          RAISE vr_exc_erro;
        ELSE
          -- Fechar o cursor para continuar o processo
          CLOSE cr_crapprg;
        END IF;
        -- Se foi enviado um c�digo de relat�rio
        IF pr_cdrelato IS NOT NULL THEN
          -- Busca do cadastro de relat�rios as informa��es do relat�rio
          OPEN cr_craprel(pr_cdrelato => pr_cdrelato);
          FETCH cr_craprel
           INTO rw_craprel;
          -- Fechar o cursor para continuar o processo
          CLOSE cr_craprel;
        END IF;
        -- Por fim, em caso de n�o ter encontrado fila e prioridade
        -- no cadastro do relat�rio ou pela solicita��o do relat�rio
        -- ent�o utilizamos o NVL abaixo e buscamos a parametriza��o
        -- do sistema em COD_FILA_REL_PADRAO e NUM_PRIOR_REL_PADRAO
        rw_craprel.cdfilrel := NVL(rw_craprel.cdfilrel,gene0001.fn_param_sistema('CRED',pr_cdcooper,'COD_FILA_RELATO'));
        rw_craprel.nrseqpri := NVL(rw_craprel.nrseqpri,gene0001.fn_param_sistema('CRED',pr_cdcooper,'NUM_PRIOR_RELATO'));
        -- Somente continuar se a fila enviada estiver ativa
        OPEN cr_crapfil;
        FETCH cr_crapfil
         INTO vr_flgativa;
        -- Se n�o encontrar ou a fila estiver inativa
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
        -- Se foi solicitada a remo��o do arquivo original
        IF pr_flgremarq = 'S' THEN
          -- Somente continuar se foi indicado a impress�o ou algum email ou diret�rio para c�pia do arquivo
          IF pr_dspathcop IS NULL AND pr_dsmailcop IS NULL AND pr_flg_impri = 'N' THEN
            vr_dserrger := 'Voce nao pode remover o arquivo se n�o h� diret�rio / email para envio, ou impressao do relatorio.';
            RAISE vr_exc_erro;
          END IF;
        END IF;
      EXCEPTION
        WHEN vr_exc_erro THEN
          -- Incluir mensagem padr�o inicial
          vr_dserrger := 'Relatorio '||pr_dsarqsaid||' nao sera processado. Motivo: '|| vr_dserrger;
          -- E tamb�m setar a flag de gerado como 'S' para que o
          -- mecanismo n�o tente ger�-lo j� que encontrarmos erro
          vr_flgerado := 'S';
      END;
      -- Guardar extens�es pada copia/email
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
          vr_dserrger := 'Solicita��o do Relatorio '||pr_dsarqsaid||' com erro ao inserir. Motivo: '|| sqlerrm;
      END;
      -- Se foi solicitado o envio na hora e n�o houve erro na solicita��o
      IF pr_flg_gerar = 'S' AND vr_dserrger IS NULL THEN
        -- Chamar o processamento de solicita��es pendentes passando-a
        pc_process_relato_penden(pr_nrseqsol => vr_nrseqsol
                                ,pr_des_erro => vr_dserrger);
      END IF;
      -- Se n�o saimos pela exce��o acima e houve erro
      IF vr_dserrger IS NOT NULL THEN
        -- Enviar ao LOG Batch
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 --> Erro tratato
                                  ,pr_des_log      => to_char(sysdate, 'hh24:mi:ss')
                                                   || ' - '
                                                   || pr_cdprogra
                                                   || ' --> ' || vr_dserrger);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN -- Gerar log de erro
        -- Retornar o erro contido na sqlerrm
        pr_des_erro := 'GENE0002.pc_solicita_relato --> ' || sqlerrm;
    END;
  END pc_solicita_relato_arquivo;

  /* Procedimento que verifica poss�veis erros no processo de relat�rios e alerta os respons�veis */
  PROCEDURE pc_aviso_erros_procrel IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_aviso_erros_procrel
    --  Sistema  : Rotinas gen�ricas
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini
    --  Data     : Mar�o/2014.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Ser acionado por Job Controlador do Banco
    --
    --   Objetivo  : 1 - Listar todos os relat�rios com erro no processo atual
    --               2 - Gerar por e-mail listagem alertando os repons�veis
    --               3 - Atualizar os relat�rios indicando que j� houve o alerta
    DECLARE
      -- Lista dos relat�rios a montar a tabela
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
              ,gene0002.fn_calc_difere_datas(slr.dtiniger,slr.dtfimger) qttmpexe
              ,slr.dserrger
              ,ROW_NUMBER() OVER(PARTITION BY cdcooper
                                     ORDER BY cdcooper) nrseq_coop
              ,COUNT(1) OVER(PARTITION BY cdcooper) conta_coop
          from crapslr slr
        where slr.flgbatch = 1          --> Solicitado no processo
          and slr.dserrger is not null  --> Teve erro
          and slr.flgaviso = 'N'        --> Ainda n�o avisado
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
      -- Guardar par�metros
      vr_hhalerta      VARCHAR2(5) := gene0001.fn_param_sistema('CRED',0,'RELBATCH_HORA_AVISO');
      vr_dslista_email VARCHAR2(4000);
      -- Guardar HMTL texto
      vr_dshmtl     clob;
      vr_dshmtl_aux varchar2(32600);
      vr_dscorpo    varchar2(3000);
      -- Erro no envio
      vr_dserro varchar2(4000);
    BEGIN
      -- Se tiver sido alcan�ando o hor�rio para alertas
      IF vr_hhalerta IS NOT NULL AND to_char(sysdate,'hh24:mi') >= vr_hhalerta THEN
        -- Agrupar todos os relat�rios por cooperativa
        FOR rw_crapslr IN cr_crapslr LOOP
          -- No primeiro registro da coop
          IF rw_crapslr.nrseq_coop = 1 THEN
            -- BUscar nmrescop
            OPEN cr_crapcop(pr_cdcooper => rw_crapslr.cdcooper);
            FETCH cr_crapcop
             INTO vr_nmrescop;
            CLOSE cr_crapcop;
            -- Buscar o diret�rio converte
            vr_dsdircop := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                                ,pr_cdcooper => rw_crapslr.cdcooper
                                                ,pr_nmsubdir => 'converte');
            -- Busca a lista dos respons�veis nesta coop
            vr_dslista_email := gene0001.fn_param_sistema('CRED',rw_crapslr.cdcooper,'RELBATCH_EMAIL_AVISO');
            -- Montar o cabe�alho do html e o alerta
            vr_dscorpo := '<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >';
            vr_dscorpo := vr_dscorpo || 'Segue em anexo a listagem dos relatorios que encontraram problema de execucao no processo da <b>'||vr_nmrescop||'</b> ref. <b>'||to_char(rw_crapslr.dtmvtolt,'dd/mm/yy')||'</b>.';
            vr_dscorpo := vr_dscorpo || '</meta>';
            -- Montar o in�cio da tabela (Agora num clob para evitar estouro)
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
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>In�cio</th>');
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>Fim</th>');
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>Tempo Execu��o</th>');
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
            -- Liberando a mem�ria alocada pro CLOB
            dbms_lob.close(vr_dshmtl);
            dbms_lob.freetemporary(vr_dshmtl);
            IF vr_dserro IS NOT NULL THEN
              -- Gerar log
              pc_gera_log_relato(pr_cdcooper => rw_crapslr.cdcooper
                                ,pr_des_log  => to_char(SYSDATE,'hh24:mi:ss')||' Erro ao enviar email de alerta de relat�rios com problema --> '||vr_dserro);
            ELSE
              -- Solicitar o e-mail
              gene0003.pc_solicita_email(pr_cdcooper      => rw_crapslr.cdcooper --> Cooperativa conectada
                                        ,pr_cdprogra      => null                --> Programa conectado
                                        ,pr_des_destino   => vr_dslista_email    --> Um ou mais detinat�rios separados por ';' ou ','
                                        ,pr_des_assunto   => 'Relat�rios com erro no processo da '||vr_nmrescop --> Assunto do e-mail
                                        ,pr_des_corpo     => vr_dscorpo          --> Corpo (conteudo) do e-mail
                                        ,pr_des_anexo     => vr_dsdircop||'/procrel_'||vr_nmrescop||'_erro.html'               --> Um ou mais anexos separados por ';
                                        ,pr_flg_remove_anex => 'S'               --> Remover o anexo
                                        ,pr_flg_log_batch => 'N'                 --> Incluir no log a informa��o do anexo?
                                        ,pr_des_erro      => vr_dserro);
              IF vr_dserro IS NOT NULL THEN
                -- Gerar log
                pc_gera_log_relato(pr_cdcooper => rw_crapslr.cdcooper
                                  ,pr_des_log  => to_char(SYSDATE,'hh24:mi:ss')||' Erro ao enviar email de alerta de relat�rios com problema --> '||vr_dserro);

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
    EXCEPTION
      WHEN OTHERS THEN
        -- Gerar log
        pc_gera_log_relato(pr_cdcooper => 1
                          ,pr_des_log  => to_char(SYSDATE,'hh24:mi:ss')||' Erro ao processar avisos de relat�rios com problema no processo--> '||sqlerrm);

    END;
  END pc_aviso_erros_procrel;

  /* Procedimento que gerencia as filas de relat�rios e controla seus jobs */
  PROCEDURE pc_controle_filas_relato IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_controle_filas_relato
    --  Sistema  : Rotinas gen�ricas
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini
    --  Data     : Outubro/2013.                   Ultima atualizacao: 21/03/2014
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Ser acionado por Job Controlador do Banco
    --
    --   Objetivo  : 1   - No in�cio do processo, varrer todas as Cooperativas e para cada um:
    --               1.1 - Se estivermos com o processo diario ou noturno executando
    --               1.2 - Se o processo de relat�rios n�o estiver em execu��o
    --               1.3 - Ent�o criar o arquivo de controle de in�cio da cadeia de relat�rios

    --               2   - A rotina ir� tamb�m varrer todas as filas de gera��o de relat�rio (CRAPFIL),
    --                     e para cada fila, efetuar os seguintes controles:
    --
    --               2.1 - Remover solicita��es antigas da fila conforma a quantidade
    --                     de dias parametrizado de arquivo dos relat�rios.
    --               2.2 - Contar quantos Jobs ativos da fila;
    --               2.3 - Contar quantas solicita��es est�o pendentes daquela fila;
    --               2.4 - Buscar a quantidade m�xima de solicita��es por Job e a
    --                     quantidade m�xima de jobs ativos para a fila
    --               2.5 - Escalonar quantos jobs forem necess�rios para processar
    --                     as solicita��es pendentes, desde que n�o escalonemos mais
    --                     jobs do que a quantidade maxima dispon�vel por fila.
    --
    --               2.6 - Chamar rotina que verifica poss�veis erros nos relat�rios e avisa os respons�veis
    --
    --               3   - E no final do processo, varrer novamente todas as Cooperativas
    --                     e para cada uma encontrada:
    --
    --               3.1 - Se n�o estivermos com nenum processo rodando
    --               3.2 - Com o processo de gera��o de relat�rios da cadeia ativo
    --               3.3 - Sem nenhum relat�rio da cadeia pendente de execu��o
    --                     para aquela Cooperativa;
    --               3.4 - Ent�o atualizar o arquivo de controle da cadeia de relatorios
    --                     para indicar que o processo de relat�rios da cadeia encerrou
    --
    --   Alteracoes:
    --
    --   21/03/2014 - Chamar rotina que alerta os respons�veis caso encontremos erros de
    --                relat�rios da cadeia (Marcos-Supero)
    --
    -- .............................................................................
    DECLARE
      -- Busca de todas as cooperativas
      CURSOR cr_crapcop IS
        SELECT cdcooper
          FROM crapcop;
      -- Prefixo padr�o dos jobs para as filas
      vr_nmjobnam VARCHAR2(30);
      -- Quantidade auxiliar para calculo de relat�rios pendentes
      vr_qtjobnec NUMBER;
      -- Bloco PLSQL para chamar a execu��o paralela do pc_crps414
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
      -- Contagem da quantidade de solicita��es pendentes da fila
      CURSOR cr_crapslr_fila(pr_cdfilrel crapfil.cdfilrel%TYPE) IS
        SELECT COUNT(1)
          FROM crapslr
         WHERE cdfilrel = pr_cdfilrel
           AND flgerado = 'N'
           AND dtiniger IS NULL;
      -- Contagem da quantidade de solicita��es pendentes da fila
      -- trazendo somente aqueles que s�o da cadeia
      CURSOR cr_crapslr_batch(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT COUNT(1)
          FROM crapslr
         WHERE cdcooper = pr_cdcooper
           AND flgerado = 'N'
           AND dtfimger IS NULL;
      -- Var gen�rica para a quantidade pendente
      vr_qtrel_penden NUMBER;

      vr_cdprogra    VARCHAR2(40) := 'PC_CONTROLE_FILAS_RELATO';
      vr_nomdojob    VARCHAR2(40) := 'JBGEN_CONTROLE_FILAS_RELATO';
      vr_flgerlog    BOOLEAN := FALSE;

      --> Controla log proc_batch, para apenas exibir qnd realmente processar informa��o
      PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' in�cio; 'F' fim; 'E' erro
                                      pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
      BEGIN
        --> Controlar gera��o de log de execu��o dos jobs 
        BTCH0001.pc_log_exec_job( pr_cdcooper  => 3    --> Cooperativa
                                 ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                                 ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                                 ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                                 ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                                 ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
      END pc_controla_log_batch;     
      
    BEGIN

      -- Somente trabalhar com os arquivos de controle na base de produ��o
      IF gene0001.fn_database_name = gene0001.fn_param_sistema('CRED',0,'DB_NAME_PRODUC') THEN --> Produ��o
        -- Sempre no in�cio do processo controlador, varrer todas as cooperativas
        -- do sistema Cecred, e verificar se a cadeia noturna ou di�ria esta executando.
        -- Isso � poss�vel atrav�s das fun�oes na btch0001
        FOR rw_crapcop IN cr_crapcop LOOP
          -- Para cada uma que estiver com o processo executando
          IF btch0001.fn_procnot_exec(rw_crapcop.cdcooper) OR btch0001.fn_procdia_exec(rw_crapcop.cdcooper) THEN
            -- Se o processo ainda n�o estiver ativo
            IF NOT btch0001.fn_procrel_exec(rw_crapcop.cdcooper) THEN
              -- Devemos criar o arquivo de indica��o de in�cio da
              btch0001.pc_atuali_procrel(pr_cdcooper => rw_crapcop.cdcooper --> Cooperativa
                                        ,pr_flgsitua => 'E'                 --> Situa��o (E-Execu��o, O-OK)
                                        ,pr_des_erro => vr_des_erro);       --> Sa�da de erro
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

      -- Buscar todas as filas de relat�rios
      FOR rw_crapfil IN cr_crapfil LOOP

        -- Efetuar limpeza da tabela de solicita��o de relat�rios para a fila
        BEGIN
          -- Eliminar solicita��es com data inferior aos dias parametrizados
          DELETE
            FROM crapslr slr
           WHERE slr.cdfilrel = rw_crapfil.cdfilrel
             AND slr.dtsolici < TRUNC(SYSDATE) - rw_crapfil.qtdiaarq
             AND slr.flgerado = 'S';
        EXCEPTION
          WHEN OTHERS THEN
            pc_gera_log_relato(pr_cdcooper => 0
                              ,pr_des_log  => to_char(sysdate,'hh24:mi:ss')||' --> Problema ao eliminar os relat�rios antigos da fila: '
                                           || rw_crapfil.cdfilrel ||'. Detalhes: '||sqlerrm||'.');
        END;
        -- Contagem da quantidade de solicita��es pendentes da fila
        OPEN cr_crapslr_fila(pr_cdfilrel => rw_crapfil.cdfilrel);
        FETCH cr_crapslr_fila
         INTO vr_qtrel_penden;
        CLOSE cr_crapslr_fila;
        -- Somente continuar se a fila possui relat�rios pendentes
        IF vr_qtrel_penden > 0 THEN
          
          -- Log de inicio de execucao
          pc_controla_log_batch(pr_dstiplog => 'I');

          -- Contar a quantidade de Jobs ativos da fila
          OPEN cr_jobs(pr_cdfilrel => rw_crapfil.cdfilrel);
          FETCH cr_jobs
           INTO vr_qtjobati;
          CLOSE cr_jobs;
          -- Somente continuar se a quantidade de Jobs ativos
          -- for inferior a quantidade m�xima permitida
          IF vr_qtjobati < rw_crapfil.qtjobati THEN
            -- Dividir a quantidade de jobs pendentes pela qtde m�xima
            -- de relat�rios por Jobs, assim definimos quantos jobs s�o
            -- necess�rios ainda para processarmos todos os pendentes
            -- Obs: Usar CEIL para arredondar para cima
            vr_qtjobnec := CEIL(vr_qtrel_penden / rw_crapfil.qtreljob);
            -- Efetuar LOOP de 1 at� a quantidade de jobs necess�rios para escalonar
            FOR vr_ind IN 1..vr_qtjobnec LOOP
              -- Preparar prefixo padr�o dos JobNames
              -- RLJOB_<CDFILREL>#<N>
              -- Onde:
              --   RLJOB$   : Prefixo padr�o
              --   CDFILREL : C�digo da fila
              --   N        : Sequencial criado pelo Oracle
              vr_nmjobnam := 'RLJOB_'||rw_crapfil.cdfilrel||'#';
              -- Sair ao alcan�ar a quantidade m�xima de Jobs
              EXIT WHEN vr_ind + vr_qtjobati > rw_crapfil.qtjobati;
              -- Criamos o bloco PLSQL para execu��o da fila
              -- Obs: N�o h� tratamento de erro pois todo erro de relat�rios � lan�ado ao arquivo de log dos mesmos
              vr_dsplsql := 'declare'||chr(10)
                         || '  vr_des_erro VARCHAR2(4000);'||chr(10)
                         || 'begin' ||chr(10)
                         || '  gene0002.pc_process_relato_penden(pr_cdfilrel=>'''||rw_crapfil.cdfilrel||''',pr_des_erro=>vr_des_erro);'||chr(10)
                         || 'end;';
              -- Devemos criar um novo JOB para a fila
              gene0001.pc_submit_job(pr_cdcooper  => 0             --> C�digo da cooperativa
                                    ,pr_cdprogra  => NULL          --> C�digo do programa
                                    ,pr_dsplsql   => vr_dsplsql    --> Bloco PLSQL a executar
                                    ,pr_dthrexe   => SYSTIMESTAMP  --> Executar nesta hora
                                    ,pr_interva   => NULL          --> Sem intervalo de execu��o da fila, ou seja, apenas 1 vez
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
      
      -- Chamar rotina que verifica poss�veis erros nos relat�rios e avisa os respons�veis
      pc_aviso_erros_procrel;

      IF vr_qtrel_penden > 0 THEN 
        -- Log de inicio de execucao
        pc_controla_log_batch(pr_dstiplog => 'F');
      END IF;

      -- Somente trabalhar com os arquivos de controle na base de produ��o
      IF gene0001.fn_database_name = gene0001.fn_param_sistema('CRED',0,'DB_NAME_PRODUC') THEN --> Produ��o
        -- Sempre no t�rmino do processo controlador, varrer todas as cooperativas
        -- do sistema Cecred, e verificar se a cadeia noturna e di�ria encerram.
        -- Isso � poss�vel atrav�s das fun�oes na btch0001
        FOR rw_crapcop IN cr_crapcop LOOP
          -- Se todos os processos finalizaram
          IF NOT btch0001.fn_procnot_exec(rw_crapcop.cdcooper) AND NOT btch0001.fn_procdia_exec(rw_crapcop.cdcooper) THEN
            -- Se o processo de relat�rios ainda estiver ativo
            IF btch0001.fn_procrel_exec(rw_crapcop.cdcooper) THEN
              -- Contagem da quantidade de solicita��es pendentes da coop
              -- trazendo somente aqueles que s�o da cadeia
              OPEN cr_crapslr_batch(pr_cdcooper => rw_crapcop.cdcooper);
              FETCH cr_crapslr_batch
               INTO vr_qtrel_penden;
              CLOSE cr_crapslr_batch;
              -- Se n�o houverem mais relat�rios da cadeia pendentes para a Cooperativa
              IF vr_qtrel_penden = 0 THEN
                -- Devemos atualizar o arquivo de indica��o do t�rmino dos relat�rios
                btch0001.pc_atuali_procrel(pr_cdcooper => rw_crapcop.cdcooper --> Cooperativa
                                          ,pr_flgsitua => 'O'                 --> Situa��o (E-Execu��o, O-OK)
                                          ,pr_des_erro => vr_des_erro);       --> Sa�da de erro
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

      -- Gravar as altera��es
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        pc_gera_log_relato(pr_cdcooper => 0
                          ,pr_des_log  => to_char(sysdate,'hh24:mi:ss')||' --> Problema na rotina controladora das filas. Detalhes: '||sqlerrm||'.');
    END;
  END pc_controle_filas_relato;

  /* Fun��o para buscar o tempo do sistema  */
  FUNCTION fn_busca_time RETURN NUMBER IS
  BEGIN
    -- Retonar o tempo de forma padronizada
    RETURN (To_Number(To_Char(systimestamp,'SSSSS')));
  END fn_busca_time;

  /* Retonar a data a partir do numero de segundos */
  FUNCTION fn_converte_time_data(pr_nrsegs   in integer,
                                 pr_tipsaida in varchar2 default 'M') RETURN varchar2 IS
    vr_nrsegs    integer := pr_nrsegs;
  BEGIN
    -- Reduz a quantidade de segundos para apenas 1 dia
    while vr_nrsegs >= 86400 loop
      vr_nrsegs := vr_nrsegs - 86400;
    end loop;
    -- Se for para retornar segundos
    if upper(pr_tipsaida) = 'S' then
      -- Retonar a data a partir do numero de segundos
      return(to_char(to_date(vr_nrsegs, 'sssss'), 'hh24:mi:ss'));
    else
      -- Retonar a data a partir do numero de segundos
      return(to_char(to_date(vr_nrsegs, 'sssss'), 'hh24:mi'));
    end if;
  END;

  /* Fun��o para processar uma string que cont�m um valor e retorn�-lo em number  */
  FUNCTION fn_char_para_number(pr_dsnumtex IN varchar2) RETURN NUMBER IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : fn_char_para_number
    --  Sistema  : Rotinas gen�ricas
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Dezembro/2012.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Esta rotina recebe uma string que deve conter um valor em
    --               moeda ou numero e convete a mesma para ser retornada como
    --               um number.
    --      Regras : 1) A rotina utilizar� a view nls_database_parameters para
    --                  conhecer quais s�o os separadores configurados no banco
    --               2) O ultimo separador da string (ponto ou virgual) � considerado
    --                  o separador de decimal
    --               3) Informa��es como o sinal e a moeda podem ser enviada e
    --                  apenas o sinal ser� considerado para a convers�o de number
    --               4) Em caso de erro, a fun��o retornar� NUL
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
    DECLARE
      -- Buscar os caracteres separadores
      CURSOR cr_sep IS
        SELECT substr(value,2,1) dssepmil
              ,substr(value,1,1) dssepdec
          FROM nls_session_parameters
         WHERE parameter = 'NLS_NUMERIC_CHARACTERS';
      -- Variavel auxiliar para guardar as informa��es
      -- do n�mero ainda representado como texto
      vr_dsnumtex VARCHAR2(60);
      -- Guardar o ultimo separador encontrado
      vr_dsultsep VARCHAR2(1);
    BEGIN
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
            -- j� copiado, pois isso garante que no final
            -- tenhamos apenas o separador decimal restando
            vr_dsnumtex := REPLACE(REPLACE(vr_dsnumtex,',',''),'.','');
            -- Guardar este caracter como o ultimo separador
            -- encontrado at� o presente momento
            vr_dsultsep := substr(pr_dsnumtex,vr_ind,1);
          END IF;
          -- Adiciona na string o caracter encontrado
          vr_dsnumtex := vr_dsnumtex || substr(pr_dsnumtex,vr_ind,1);
        END IF;
      END LOOP;
      -- Verificar se o ultimo caracter � um sinal
      IF substr(vr_dsnumtex,LENGTH(vr_dsnumtex),1) IN('+','-') THEN
        -- Copi�-lo para o come�o da string
        vr_dsnumtex := substr(vr_dsnumtex,LENGTH(vr_dsnumtex),1)||substr(vr_dsnumtex,1,LENGTH(vr_dsnumtex)-1);
      END IF;
      -- Ao final, se foi encontrado algum caracter separador
      IF vr_dsultsep IS NOT NULL THEN
        -- Subsituimos o mesmo pelo caracter separador
        -- de decimal configurado na sess�o
        -- (Se for igual, n�o haver� problema)
        vr_dsnumtex := REPLACE(vr_dsnumtex,vr_dsultsep,vr_nlspar(1).dssepdec);
      END IF;
      -- Enfim, efetuamos return para converter o texto
      -- que ficou restando na string processada, que de acordo
      -- com as vaida��es acima deve ter ficado apenas com o sinal,
      -- os valores e o caracter decimal apenas
      --RETURN vr_dsnumtex; -- Renato Darosci => tratar corretamente o retorno do num�rico
      RETURN to_number(vr_dsnumtex, 'FM999999999999999999999999999d9999999999', 'NLS_NUMERIC_CHARACTERS='''||vr_nlspar(1).dssepdec||vr_nlspar(1).dssepmil||'');
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
  END fn_char_para_number;

  /* Calcular a diferen�a entre duas datas e retornar diferen�a em hh:mi:ss */
  FUNCTION fn_calc_difere_datas(pr_dtinicio IN DATE
                               ,pr_dttermin IN DATE) RETURN VARCHAR2 IS
  BEGIN
    /*..............................................................................

       Programa: fn_calc_difere_datas
       Autor   : Marcos (Supero)
       Data    : Fevereiro/2013                    Ultima atualizacao:

       Dados referentes ao programa:

       Objetivo  : Calcular a diferen�a entre duas datas e retornar diferen�a em hh:mi:ss

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Variaveis para o c�lculo
    vr_qtddfrac NUMBER;
    vr_qthrsdif NUMBER;
    vr_qtmindif NUMBER;
    vr_qtsecdif NUMBER;
    BEGIN
      -- Armazenar a fra�ao de dias entre as datas
      vr_qtddfrac := (pr_dttermin-pr_dtinicio)-trunc(pr_dttermin-pr_dtinicio);
      -- Acumular horas, minutos e segundos separadamente
      vr_qthrsdif := ABS(trunc(vr_qtddfrac*24));
      vr_qtmindif := ABS(trunc((((vr_qtddfrac)*24)-(vr_qthrsdif))*60));
      vr_qtsecdif := ABS(trunc(mod((pr_dttermin-pr_dtinicio)*86400,60)));
      -- Retornar os valores calculados no formado hh24:mi:ss
      RETURN(LPAD (vr_qthrsdif, 2, '0') ||':'|| LPAD (vr_qtmindif, 2, '0') ||':'|| LPAD (vr_qtsecdif, 2, '0'));
    EXCEPTION
      WHEN OTHERS THEN
        -- Retornar 00 como diferen�a
        RETURN '00:00:00';
    END;
  END fn_calc_difere_datas;

  /* Procedure para controlar buferiza��o de um CLOB */
  PROCEDURE pc_clob_buffer(pr_dados   IN OUT NOCOPY VARCHAR2       --> Buffer de dados
                          ,pr_btam    IN PLS_INTEGER DEFAULT 32600 --> Determina o tamanho do buffer
                          ,pr_gravfim IN BOOLEAN                   --> Verifica se � grava��o final do buffer
                          ,pr_clob    IN OUT NOCOPY CLOB) IS       --> Clob de grava��o
    -- ..........................................................................
    --
    --  Programa : pc_clob_buffer
    --  Sistema  : Rotinas gen�ricas
    --  Sigla    : GENE
    --  Autor    : Petter Rafael - Supero Tecnologia
    --  Data     : Setembro/2013.                   Ultima atualizacao: 20/05/2014
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Controlar a grava��o de dados em um CLOB utilizando buferiza��o
    --               para melhorar a performance.
    --
    --   Alteracoes: Ajustes para n�o gravar linha no clob, caso o parametro esteja vazio(Odirlei/AMcom)
    --
    -- .............................................................................
  BEGIN
    DECLARE
      /* Declara��o de fun��es e procedures */
      -- Procedure para escrever texto na vari�vel CLOB do XML
      PROCEDURE pc_xml_tag(pr_buffer    IN VARCHAR2                --> String que ser� adicionada ao CLOB
                          ,pr_clob      IN OUT NOCOPY CLOB) IS     --> CLOB que ir� receber a string
      BEGIN
        dbms_lob.writeappend(pr_clob, length(pr_buffer), pr_buffer);
      END pc_xml_tag;

    BEGIN
      -- Verifica se � grava��o final
      IF NOT pr_gravfim THEN
        -- Valida o tamanho do buffer para grava��o
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
  END pc_clob_buffer;

  -- Subrotina para escrever texto na vari�vel CLOB do XML
  procedure pc_escreve_xml(pr_xml in out nocopy clob,  --> Vari�vel CLOB onde ser� inclu�do o texto
                           pr_texto_completo in out nocopy varchar2,  --> Vari�vel para armazenar o texto at� ser inclu�do no CLOB
                           pr_texto_novo in varchar2,  --> Texto a incluir no CLOB
                           pr_fecha_xml in boolean default false) is  --> Flag indicando se � o �ltimo texto no CLOB
    /*----------------------------------------------------------
      Programa: pc_escreve_xml
      Autor: Daniel Dallagnese (Supero)
      Data: 11/02/2014                               �ltima atualiza��o: 11/02/2014

      Objetivo: Melhorar a performance dos programas que necessitam escrever muita
                informa��o em vari�vel CLOB. Exemplo de uso: PC_CRPS086.

      Utiliza��o: Quando houver necessidade de incluir informa��es em um CLOB, deve-se
                  declarar, instanciar e abrir o CLOB no programa chamador, e pass�-lo
                  no par�metro PR_XML para este procedimento, juntamente com o texto que
                  se deseja incluir no CLOB. Para finalizar a gera��o do CLOB, deve-se
                  incluir tamb�m o par�metro PR_FECHA_XML com o valor TRUE. Ao final, no
                  programa chamador, deve-se fechar o CLOB e liberar a mem�ria utilizada.

      Altera��es:

    ----------------------------------------------------------*/
    procedure pc_concatena(pr_xml in out nocopy clob,
                           pr_texto_completo in out nocopy varchar2,
                           pr_texto_novo varchar2) is
      -- Prodimento para concatenar os textos em um varchar2 antes de incluir no CLOB,
      -- ganhando performance. Somente grava no CLOB quando estourar a capacidade da vari�vel.
    begin
      -- Tenta concatenar o novo texto ap�s o texto antigo (vari�vel global da package)
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
    -- Concatena o novo texto
    pc_concatena(pr_xml, pr_texto_completo, pr_texto_novo);
    -- Se for o �ltimo texto do arquivo, inclui no CLOB
    if pr_fecha_xml then
      dbms_lob.writeappend(pr_xml, length(pr_texto_completo), pr_texto_completo);
      pr_texto_completo := null;
    end if;
  end;

  /* Procedure para copiar arquivos para a intranet */
  PROCEDURE pc_gera_arquivo_intranet(pr_cdcooper IN PLS_INTEGER                --> C�digo da cooperativa
                                    ,pr_cdagenci IN PLS_INTEGER                --> C�digo da agencia
                                    ,pr_dtmvtolt IN DATE                       --> Data de movimento
                                    ,pr_nmarqimp IN VARCHAR2                   --> Nome arquivo de impress�o
                                    ,pr_nmformul IN VARCHAR2                   --> Nome do formul�rio
                                    ,pr_dscritic OUT VARCHAR2                  --> Descri��o da cr�tica
                                    ,pr_tab_erro IN OUT GENE0001.typ_tab_erro  --> Tabela com erros
                                    ,pr_des_erro OUT VARCHAR2) IS              --> Retorno de erros no processo
    -- ..........................................................................
    --
    --  Programa : pc_gera_arquivo_intranet      (Antigo B1WGEN0024.P --> GERA-ARQUIVO-INTRANET)
    --  Sistema  : Rotinas gen�ricas
    --  Sigla    : GENE
    --  Autor    : Petter Rafael - Supero Tecnologia
    --  Data     : Outubro/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Efetuar o envio de arquivos para a intranet.
    --
    --   Alteracoes:
    --
    -- .............................................................................
  BEGIN
    DECLARE
      vr_nrtamarq   PLS_INTEGER := 0;         --> N�mero de arquivo
      vr_dsgerenc   VARCHAR2(100);            --> Descri��o agencia
      vr_tprelato   PLS_INTEGER := 0;         --> Tipo de relat�rio
      vr_ingerpdf   PLS_INTEGER := 0;         --> Flag para gerar PDF
      vr_nmrelato   VARCHAR2(100);            --> Nome do relat�rio
      vr_cdrelato   PLS_INTEGER := 0;         --> C�digo do relat�rio
      vr_setlinha   VARCHAR2(80);             --> Defini��o de linha
      vr_nmarqtmp   VARCHAR2(150);            --> Nome de arquivo tempor�rio
      vr_nmarqpdf   VARCHAR2(80);             --> Nome de arquivo PDF
      vr_typ_saida  VARCHAR2(40);             --> Sa�da do terminal
      vr_des_saida  VARCHAR2(4000);           --> Descri��o da sa�da do terminal
      vr_retcomando typ_split := typ_split(); --> Array com os resultados do split
      vr_setlinhas  typ_split := typ_split(); --> Array com os resultados do split
      vr_rettermis  typ_split := typ_split(); --> Array com os resultados do split
      vr_exc_erro   EXCEPTION;                --> Controle para sa�da de erros
      vr_rettermi   VARCHAR2(200);            --> Armazenar retorno do terminal
      vr_arquivo    utl_file.file_type;       --> Handle para gravar arquivo
      vr_nomarqf    VARCHAR2(100);            --> Nome do arquivo final para intranet

      arquivo utl_file.file_type;

      /* Buscar dados da cooperativa */
      CURSOR cr_crapcop(pr_cdcooper  IN crapcop.cdcooper%TYPE) IS   --> C�digo da cooperativa
        SELECT cp.nmrescop
        FROM crapcop cp
        WHERE cp.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      /* Buscar dados da execu��o dos relat�rios */
      CURSOR cr_craprel(pr_cdcooper IN craprel.cdcooper%TYPE      --> C�digo da cooperativa
                       ,pr_cdrelato IN craprel.cdrelato%TYPE) IS  --> C�digo de relat�rio
        SELECT cl.ingerpdf
              ,cl.nmrelato
              ,cl.tprelato
        FROM craprel cl
        WHERE cl.cdcooper = pr_cdcooper
          AND cl.cdrelato = pr_cdrelato;
      rw_craprel cr_craprel%ROWTYPE;

    BEGIN
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

      -- Verifica caracter inv�lido
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

      -- Obter Dados para impress�o e INTRANET
      vr_dsgerenc := 'NAO';
      vr_tprelato := 0;
      vr_ingerpdf := 0;
      vr_nmrelato := ' ';
      vr_cdrelato := TO_NUMBER(SUBSTR(pr_nmarqimp, instr(pr_nmarqimp, 'crrl') + 4, 3));

      -- Buscar dados da execu��o dos relat�rios
      OPEN cr_craprel(pr_cdcooper, vr_cdrelato);
      FETCH cr_craprel INTO rw_craprel;

      -- Verifica se a tupla retornou registro
      IF cr_craprel%FOUND THEN
        CLOSE cr_craprel;

        vr_ingerpdf := rw_craprel.ingerpdf;
        vr_nmrelato := rw_craprel.nmrelato;

        -- Verifica o tipo do relat�rio
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
        -- Abrir arquivo em modo de adi��o
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

      pr_des_erro := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro := 'Erro em GENE0002.pc_gera_arquivo_intranet: ' || pr_des_erro;
      WHEN OTHERS THEN
        pr_des_erro := 'Erro em GENE0002.pc_gera_arquivo_intranet: ' || SQLERRM;
    END;
  END pc_gera_arquivo_intranet;


  /* Fun�ao para testar se a vari�vel � uma data valida */
  FUNCTION fn_data(pr_vlrteste IN VARCHAR2
                  ,pr_formato  IN VARCHAR2) RETURN boolean IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : fn_numerico
    --  Sistema  : Rotinas gen�ricas
    --  Sigla    : GENE
    --  Autor    : Daniel Zimmermann
    --  Data     : Dezembro/2014.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Retornar valida��o se a vari�vel � uma data.
    --   Alteracoes:
    -- ............................................................................
    DECLARE
      vr_ctrteste       BOOLEAN := TRUE;
      vr_qvalor         VARCHAR2(1);
      vr_auxdata        DATE;

    BEGIN
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
  --  Data     : Julho/2014                           Ultima atualizacao: 05/04/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo   : Procedure para envio do arquivo de extrato da conta para servidor web
  --
  -- Altera��es : 02/07/2014 - Convers�o Progress -> Oracle (Alisson - AMcom)
  --              21/11/2014 - Remocao do comando de copia do arquivo .PDF de um servidor
  --                           para outro e utilizacao da procedure pronta de geracao do PDF.
  --
  --              27/02/2015 - Incluido o nome do arquivo .pdf no retorno da variavel pr_nmarqpdf,
  --                           feito tratamento para arquivos .lst (Jean Michel).
  --
  --              05/04/2016 - Ajuste para retirar o "*" ao remover o arquivo
  --                           (Adriano).        
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
        vr_tipsplit gene0002.typ_split;

      BEGIN
        --Limpar parametros erro
        pr_des_reto:= 'OK';

        -- Verifica se a cooperativa esta cadastrada
        OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
        FETCH cr_crapcop INTO rw_crapcop;
        -- Se n�o encontrar
        IF cr_crapcop%NOTFOUND THEN
          -- Fechar o cursor pois haver� raise
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
            vr_dscritic:= 'N�o foi poss�vel executar comando unix. '||vr_comando;
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
            vr_dscritic:= 'N�o foi poss�vel executar comando unix. '||vr_comando;
            RAISE vr_exc_erro;
          END IF;
        END IF;

        -- Retornar arquivo .pdf
        IF vr_nmarqpdf IS NOT NULL THEN
          vr_tipsplit := gene0002.fn_quebra_string(pr_string => vr_nmarqpdf, pr_delimit => '/');
          pr_nmarqpdf := vr_tipsplit(vr_tipsplit.LAST);
        END IF;

        --Retornar OK
        pr_des_reto := 'OK';
      EXCEPTION
        WHEN vr_exc_erro THEN
          -- Retorno n�o OK
          pr_des_reto := 'NOK';
          -- Chamar rotina de grava��o de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic --> Critica 0
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        WHEN OTHERS THEN
          -- Retorno n�o OK
          pr_des_reto := 'NOK';
          -- Chamar rotina de grava��o de erro
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
                                ,pr_des_reto OUT VARCHAR2        --> Descri��o OK/NOK
                                ,pr_dscritic OUT VARCHAR2) IS    --> Descricao Erro
  /*............................................................................

   Programa: pc_arquivo_para_xml
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Alisson
   Data    : Fevereiro/2015                          Ultima atualizacao: 19/05/2015

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Importar arquivo XML do modo texto para dentro do XMLtype


   Alteracoes: 11/02/2015 - Desenvolvimento

               19/05/2015 - Inclus�o do parametro pr_tipmodo para permitir importar arquivos
                            que possuam linhas maiores que 32627 caractere:
                            1 - Normal(utl_file), usado para arquivos com linhas menores
                            2 - Alternativo(usando blob) , usado para arquivos com linhas cujo ultrapassem 32627 caracteres
                            (Odirlei-AMcom)

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
              gene0002.pc_escreve_xml(vr_clob,vr_dstxtclob,vr_setlinha);
            END IF;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              --Acabaram as linhas do arquivo, atualiza CLOB
              gene0002.pc_escreve_xml(vr_clob,vr_dstxtclob,' ',TRUE);

              --Fechar o arquivo de leitura
              IF utl_file.is_open(vr_input_file) THEN
                gene0001.pc_fecha_arquivo(vr_input_file);
              END IF;

              --Sair do LOOP
              EXIT;
            WHEN OTHERS THEN
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
        -- Chamar rotina de separa��o do caminho do nome
        gene0001.pc_separa_arquivo_path(pr_caminho => pr_nmarquiv
                                       ,pr_direto  => vr_nmdireto
                                       ,pr_arquivo => vr_nmarquiv);
        -- Exportar arquivo para clob
        vr_Blob := gene0002.fn_arq_para_blob(pr_caminho => vr_nmdireto,
                                             pr_arquivo => vr_nmarquiv);

        -- Criar um LOB para armazenar o arquivo
        DBMS_LOB.CREATETEMPORARY(vr_clob, TRUE);
        dbms_lob.OPEN(vr_clob,dbms_lob.lob_readwrite);

        --> Loop para a leitura do BLOB para clob
        -- loop pela qnt de vezes que � necessario ler os buffers
        FOR i IN 1 .. CEIL(DBMS_LOB.GETLENGTH(vr_Blob) / vr_buffer) LOOP
         -- busca linha do tamanho do buffer
         vr_setlinha := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(vr_Blob,
                                                               vr_buffer,
                                                               vr_posinic));
         -- inclui dados do clob
         DBMS_LOB.WRITEAPPEND(vr_clob, LENGTH(vr_setlinha), vr_setlinha);
         -- incrementa posi��o
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
          vr_dscritic:= 'Resposta invalida (XML).'||' - '||SQLERRM;

          --Fechar Clob e Liberar Memoria
          dbms_lob.close(vr_clob);
          dbms_lob.freetemporary(vr_clob);

          --Levantar Excecao
          RAISE vr_exc_erro;
      END;
      --Retorno OK
      pr_des_reto:= 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_reto:= 'NOK';
        pr_dscritic:= 'Erro na gene0002.pc_arquivo_para_xml. '||vr_dscritic;
      WHEN OTHERS THEN
        pr_des_reto:= 'NOK';
        pr_dscritic:= 'Erro na gene0002.pc_arquivo_para_xml. '||sqlerrm;
    END;
  END pc_arquivo_para_XML;

  -- Fun��o para abreviar string
  FUNCTION fn_abreviar_string (pr_nmdentra IN VARCHAR2       --> Nome de Entrada
                              ,pr_qtletras IN INTEGER) RETURN VARCHAR2 IS --> Quantidade de Letras
  /*............................................................................

   Programa: fn_abreviar_string                      Antigo: fontes/abreviar.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Alisson
   Data    : Fevereiro/2015                          Ultima atualizacao: 23/02/2015

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Abreviar a string conforme quantidade de letras


   Alteracoes: 23/02/2015 - Convers�o Progress --> Oracle (Alisson - AMcom)

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

      --Retonar nome abreviado
      RETURN(vr_nmabrevi);

    EXCEPTION
      WHEN vr_exc_erro THEN
        return(vr_nmabrevi);
      WHEN OTHERS THEN
        return(vr_nmabrevi);
    END;
  END fn_abreviar_string;

  -- Fun��o para centralizar e preencher texto a direita e esquerda
  FUNCTION fn_centraliza_texto (pr_dstexto  IN VARCHAR2       --> Texto de Entrada
                               ,pr_dscarac  IN VARCHAR2       --> Caracter para preencher
                               ,pr_tamanho  IN INTEGER) RETURN VARCHAR2 IS --> Tamanho da String
  /*............................................................................

   Programa: fn_centraliza_texto
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Alisson
   Data    : Fevereiro/2015                          Ultima atualizacao: 23/02/2015

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Centralizar o texto e preencher com caracteres


   Alteracoes: 24/02/2015 - Convers�o Progress --> Oracle (Alisson - AMcom)

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

      --Retonar texto centralizado
      RETURN(vr_texto);

    EXCEPTION
      WHEN OTHERS THEN
        return(pr_dstexto);
    END;
  END fn_centraliza_texto;

END gene0002;
/
