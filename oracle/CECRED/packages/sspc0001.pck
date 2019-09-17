CREATE OR REPLACE PACKAGE CECRED.SSPC0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: SSPC0001         
  --  Autor   : Andrino Carlos de Souza Junior
  --  Data    : Julho/2014                     Ultima Atualizacao: 01/03/2019
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package referente a regras de geracao de arquivos SSPCR
  --
  --  Alteracoes: 07/07/2014 - Criação da rotina.
  --              
  --              16/12/2014 - Efetuar o reaproveitamento interno (Andrino-RKAM)
  --
  --              10/06/2015 - Inclusao dos limites de credito
  --
  --              08/09/2015 - Colocado upper para a busca do operador. Inclundo
  --                           consulta para criacao do cooperado (Andrino-RKAM)                    
  --
  --              01/10/2015 - Ajustes para efetuar a consulta na abertura da conta
  --                           Projeto 217-IPP de Entrada (Andrino-RKAM)
  --
  --              10/12/2015 - Inclusao do campo dsmotivo para receber informacoes textuais
  --                           Ex: Estava retornando SUSTADO no campo cdalinea que e numerico.
  -- 						               Chamado 363148 (Heitor - RKAM)
  --
  --              12/09/2016 - Correção do projeto 207 esteira de credito, ao efetuar a 
  --                           consulta de uma proposta com análise finalizada o sistema 
  --                           estava validando se a proposta tinha sido enviada para 
  --                           esteira apresentando uma critica ao efetuar a consulta 
  --                           automatizada somente pela opção "Somente consultas" 
  --                           até mesmo nas cooperativas que não usam a esteira.
  --                           (Oscar)
  --              13/09/2016 - Quando a data vier vazia, nao gerar erro (Andrino-RKAM)
  --
  --              19/05/2017 - Alteração da mensagem de retorno do cursor crawepr
  --                         - Inclusão módulo e ação e rotina de log no exception otheres - Chamado 663304
  --                           pc_solicita_consulta_biro (Ana - Envolti)
  --
  --             04/12/2017 - Colocado no final pc_retorna_conaut_esteira chamada para pc_atualiza_tab_controle 
  --                          para atualizar tabela craprpf e craprsc (restricoes de crédito) (Alexandre-Mouts)
  --
  --             27/02/2018 - Adicionado o procedimento pc_retorna_conaut_est_limdesct (Paulo Penteado (GFT))
  --
  --             23/03/2018 - Alterado a referencia que era para a tabela CRAPLIM para a tabela CRAWLIM nos procedimentos 
  --                          Referentes a proposta. (Lindon Carlos Pecile - GFT)
  --
  --              28/03/2018 - Adicionando o procedimento pc_solicita_cons_bordero_biro (Andrew Albuquerque - GFT)
  --
  --              01/03/2019 - Incluso leitura da tabela crapcbc para ignorar operações de desconto na busca de dados
  --                           de consultas de orgao d eprotecao (Daniel)
  --
  --              05/08/2019 - Incluido leitura de classe de risco e probabilidade de inadimplencia para o SERASA
  --                           PRJ 438 - Sprint 15 - Rubens Lima (Mouts)
  ---------------------------------------------------------------------------------------------------------------

-- Atualiza as tabelas de controle com as informacoes finais
PROCEDURE pc_atualiza_tab_controle(pr_nrconbir IN  crapcbd.nrconbir%TYPE, --> Numero da consulta do biro 
                                   pr_cdcritic OUT crapcri.cdcritic%TYPE, --> Critica encontrada
                                   pr_dscritic OUT VARCHAR2);          --> Texto de erro/critica encontrada


-- Rotina geral de insert, update, select e delete da tela CONAUT da opção cadastro de Biros
PROCEDURE pc_tela_conaut_crapbir(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - ALteracao / C - Consulta / E - Exclur / I - Inclur)
                                ,pr_cdbircon IN crapbir.cdbircon%TYPE --> Codigo do biro de consultas
                                ,pr_dsbircon IN crapbir.dsbircon%TYPE --> Nome do Biro
                                ,pr_nmtagbir IN crapbir.nmtagbir%TYPE --> Nome da TAG XML do biro
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

-- Rotina geral de insert, update, select e delete da tela CONAUT da opção de contingencia de Biros
PROCEDURE pc_tela_conaut_crapcbr(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - ALteracao / C - Consulta / E - Exclur / I - Inclur)
                                ,pr_cdcooper IN crapcbr.cdcooper%TYPE --> Código da cooperativa
                                ,pr_cdbircon IN crapcbr.cdbircon%TYPE --> Codigo do biro de consultas
                                ,pr_dtinicon IN VARCHAR2              --> Data de inicio da contingencia
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

-- Rotina geral de insert, update, select e delete da tela CONAUT da opção de dias de reaproveitamento
PROCEDURE pc_tela_conaut_craprbi(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                                ,pr_cdcooper IN craprbi.cdcooper%TYPE --> Codigo da cooperativa
                                ,pr_inprodut IN craprbi.inprodut%TYPE --> Indicador de tipo de produto
                                ,pr_inpessoa IN craprbi.inpessoa%TYPE --> Indicador de pessoa Fisica / Juridica
                                ,pr_qtdiarpv IN craprbi.qtdiarpv%TYPE --> Quantidade de dias de reaproveitamento
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

-- Rotina geral de insert, update, select e delete da tela CONAUT da opção de cadastro de modalidades
PROCEDURE pc_tela_conaut_crapmbr(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                                ,pr_cdbircon IN crapmbr.cdbircon%TYPE --> Código do biro de consultas
                                ,pr_cdmodbir IN crapmbr.cdmodbir%TYPE --> Codigo da modalidade do biro
                                ,pr_dsmodbir IN crapmbr.dsmodbir%TYPE --> Descricao da modalidade do biro
                                ,pr_inpessoa IN crapmbr.inpessoa%TYPE --> Indicador de pessoa Fisica / Juridica
                                ,pr_nmtagmod IN crapmbr.nmtagmod%TYPE --> Nome da tag XML da modalidade
                                ,pr_nrordimp IN crapmbr.nrordimp%TYPE --> Ordem de importancia da modalidade
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

-- Rotina geral de insert, update, select e delete da tela CONAUT da opção de parametrizaçao de modalidades
PROCEDURE pc_tela_conaut_crappcb(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                                ,pr_cdcooper IN crappcb.cdcooper%TYPE --> Codigo da cooperativa
                                ,pr_inprodut IN crappcb.inprodut%TYPE --> Indicador de tipo de produto
                                ,pr_cdbircon IN crappcb.cdbircon%TYPE --> Código do biro de consultas
                                ,pr_inpessoa IN crappcb.inpessoa%TYPE --> Indicador de pessoa Fisica / Juridica
                                ,pr_vlinicio IN crappcb.vlinicio%TYPE --> Inicio da faixa de parametrizacao
                                ,pr_cdmodbir IN crappcb.cdmodbir%TYPE --> Modalidade do biro
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

-- Rotina geral de insert e update da tela CONAUT da opção de tempo de retorno das consultaas
PROCEDURE pc_tela_conaut_crapprm(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta)
                                ,pr_cdcooper IN crapcbr.cdcooper%TYPE --> Código da cooperativa
                                ,pr_qtsegrsp IN PLS_INTEGER           --> Quantidade de segundos para aguardo de resposta
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

-- Procedure para consulta na tela CONAUT
PROCEDURE pc_consulta_campo_conaut( pr_nmcamp   IN VARCHAR2                  -- Nome do campo que esta sendo consultado
                                   ,pr_dspesq   IN VARCHAR2                  -- Chave de pesquisa
                                   ,pr_xmllog   IN VARCHAR2                  -- XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER              -- Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                 -- Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType        -- Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                 -- Nome do campo com erro                      
                                   ,pr_des_erro OUT VARCHAR2);               -- Erros do processo                                            

-- Procedure para consulta da tabela crapesc (dados do escore)
PROCEDURE pc_busca_escore(pr_nrconbir in  crapesc.nrconbir%type, --> Sequencial com o numero da consulta no biro 
                          pr_nrseqdet in  crapesc.nrseqdet%type, --> Sequencial da consulta
                          pr_nrseqesc in  crapesc.nrseqesc%type, --> Sequencial do escore
                          pr_dsescore out crapesc.dsescore%type, --> Descrição do escore
                          pr_vlpontua out crapesc.vlpontua%type, --> Pontuação
                          pr_dsclassi out crapesc.dsclassi%type, --> Descrição da classificação
                          pr_dscritic out varchar2);

-- Quando o nome da cidade vem junto com a UF, deve-se separar para a gravacao
FUNCTION fn_separa_cidade_uf(pr_nmcidade IN VARCHAR2,     --> Nome da cidade com a UF
                             pr_idretorn IN PLS_INTEGER)  --> Indicador de retorno - 1=Municipio, 2=UF
                                         RETURN VARCHAR2;
                                         
-- Efetua a consulta ao biro da Ibratan para os emprestimos
PROCEDURE pc_solicita_consulta_biro(pr_cdcooper IN  crapepr.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                    pr_nrdconta IN  crapepr.nrdconta%TYPE, --> Numero da conta de emprestimo
                                    pr_nrdocmto IN  crapepr.nrctremp%TYPE, --> Numero do documento a ser consultado
                                    pr_inprodut IN  PLS_INTEGER,           --> Indicador de produto (1-Emprestimos, 2-Financiamentos, 3-Contrato limite cheque especial, 4-Contrato limite desconto de cheque, 5-Contrato Limite Desconto de Titulos)
                                    pr_cdoperad IN  crapope.cdoperad%TYPE, --> Operador que solicitou a consulta
                                    pr_flvalest IN  PLS_INTEGER DEFAULT 0, --> Valida se proposta esta na esteira de credito
                                    pr_cdcritic OUT crapcri.cdcritic%TYPE, --> Critica encontrada
                                    pr_dscritic OUT VARCHAR2);             --> Texto de erro/critica encontrada

-- Efetua a consulta ao biro da Ibratan para os títulos de um Borderô
PROCEDURE pc_solicita_cons_bordero_biro(pr_cdcooper IN  crapcob.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                        pr_nrdconta IN  crapcob.nrdconta%TYPE, --> Numero da conta de emprestimo
                                        pr_nrinssac IN  crapcob.nrinssac%TYPE,
                                        pr_vlttitbd IN  NUMBER,                --> Valor total
                                        pr_nrctrlim IN  craplim.nrctrlim%TYPE,  --> Contrato de desconto de titulo
                                        pr_inpessoa IN  crapsab.cdtpinsc%TYPE, --> tipo de pessoa
                                        pr_nrcepsac IN  crapsab.nrcepsac%TYPE, --> Cep do pagador
                                        pr_cdoperad IN  crapcob.cdoperad%TYPE, --> Operador que solicitou a consulta
                                        pr_cdcritic OUT crapcri.cdcritic%TYPE, --> Critica encontrada
                                        pr_dscritic OUT VARCHAR2);             --> Texto de erro/critica encontrada

-- Chama a rotina de consulta ao biro da Ibratan para os emprestimos
PROCEDURE pc_solicita_consulta_biro_xml(pr_cdcooper IN  crapepr.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                        pr_nrdconta IN  crapepr.nrdconta%TYPE, --> Numero da conta de emprestimo
                                        pr_nrdocmto IN  crapepr.nrctremp%TYPE, --> Numero do documento a ser consultado
                                        pr_inprodut IN  PLS_INTEGER,           --> Indicador de produto (1-Emprestimos, 2-Financiamentos, 3-Contrato limite cheque especial, 4-Contrato limite desconto de cheque, 5-Contrato Limite Desconto de Titulos)
                                        pr_cdoperad IN  crapope.cdoperad%TYPE, --> Operador que solicitou a consulta
                                        pr_flvalest IN  PLS_INTEGER DEFAULT 0, --> Valida se proposta esta na esteira de credito
                                        pr_xmllog   IN  VARCHAR2,              --> XML com informações de LOG
                                        pr_cdcritic OUT PLS_INTEGER,           --> Código da crítica
                                        pr_dscritic OUT VARCHAR2,              --> Descrição da crítica
                                        pr_retxml   IN  OUT NOCOPY XMLType,    --> Arquivo de retorno do XML
                                        pr_nmdcampo OUT VARCHAR2,              --> Nome do campo com erro
                                        pr_des_erro OUT VARCHAR2);             --> Erros do processo


-- Verifica se houve mudanca de faixa com base nas consultas ja realizadas.
PROCEDURE pc_verifica_mud_faixa_emp(pr_cdcooper IN  crapepr.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                    pr_nrdconta IN  crapepr.nrdconta%TYPE, --> Numero da conta de emprestimo
                                    pr_nrctremp IN  crapepr.nrctremp%TYPE, --> Numero do contrato de emprestimo
                                    pr_flmudfai OUT VARCHAR2);             --> Indicador de mudanca de faixa

-- Busca a modalidade parametrizada que devera ser utilizada
PROCEDURE pc_busca_modalidade_prm(pr_cdcooper IN  crappcb.cdcooper%TYPE, --> Codigo da cooperativa
                                  pr_inprodut IN  crappcb.inprodut%TYPE, --> Indicador de produto (1-Emprestimos, 2-Financiamentos, 
                                                                         --  3-Contrato limite cheque especial, 4-Contrato limite desconto de cheque, 
                                                                         --  5-Contrato Limite Desconto de Titulos)
                                  pr_inpessoa IN  crappcb.inpessoa%TYPE, --> Indicador de pessoa (1-Fisica, 2-Juridica)
                                  pr_vlprodut IN  crappcb.vlinicio%TYPE, --> Valor do produto
                                  pr_cdbircon OUT crappcb.cdbircon%TYPE, --> Codigo do biro de consulta
                                  pr_cdmodbir OUT crappcb.cdmodbir%TYPE);--> Modalidade do biro de consulta

-- Busca a sequencia da consulta do biro para a tela CONTAS
PROCEDURE pc_busca_consulta_biro(pr_cdcooper IN  crapass.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                 pr_nrdconta IN  crapass.nrdconta%TYPE, --> Numero da conta de emprestimo
                                 pr_nrconbir OUT crapcbd.nrconbir%TYPE, --> Numero da consulta que foi realizada
                                 pr_nrseqdet OUT crapcbd.nrseqdet%TYPE);--> Sequencial dentro da consulta que foi realizada

-- Busca a sequencia da consulta do biro para a tela CONTAS e retorna por xml
PROCEDURE pc_busca_consulta_biro_xml(pr_cdcooper IN  crapass.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                     pr_nrdconta IN  crapass.nrdconta%TYPE, --> Numero da conta de emprestimo
                                     pr_xmllog   IN VARCHAR2,               --> XML com informações de LOG
                                     pr_cdcritic OUT PLS_INTEGER,           --> Código da crítica
                                     pr_dscritic OUT VARCHAR2,              --> Descrição da crítica
                                     pr_retxml   IN OUT NOCOPY XMLType,     --> Arquivo de retorno do XML
                                     pr_nmdcampo OUT VARCHAR2,              --> Nome do campo com erro
                                     pr_des_erro OUT VARCHAR2);             --> Erros do processo



-- Busca a sequencia da consulta do biro para as telas caracter
PROCEDURE pc_busca_cns_biro(pr_cdcooper       IN  crapass.cdcooper%TYPE, --> Codigo da cooperativa 
                            pr_nrdconta       IN  crapass.nrdconta%TYPE, --> Numero da conta 
                            pr_nrdocmto       IN  crapepr.nrctremp%TYPE, --> Numero do contrato
                            pr_inprodut       IN  craprbi.inprodut%TYPE, --> Indicador de tipo de produto
                            pr_nrdconta_busca IN  crapass.nrdconta%TYPE, --> Numero da conta que se deseja buscar
                            pr_nrcpfcgc_busca IN  crapass.nrcpfcgc%TYPE, --> Numero do CPF/CGC que se deseja buscar
                            pr_nrconbir OUT crapcbd.nrconbir%TYPE,       --> Numero da consulta que foi realizada
                            pr_nrseqdet OUT crapcbd.nrseqdet%TYPE);      --> Sequencial dentro da consulta que foi realizada

-- Busca a sequencia da consulta do biro para as telas WEB
PROCEDURE pc_busca_cns_biro_xml(pr_cdcooper       IN  crapass.cdcooper%TYPE, --> Codigo da cooperativa
                                pr_nrdconta       IN  crapass.nrdconta%TYPE, --> Numero da conta 
                                pr_nrdocmto       IN  crapepr.nrctremp%TYPE, --> Numero do contrato
                                pr_inprodut       IN  craprbi.inprodut%TYPE, --> Indicador de tipo de produto
                                pr_nrdconta_busca IN  crapass.nrdconta%TYPE, --> Numero da conta que se deseja buscar
                                pr_nrcpfcgc_busca IN  crapass.nrcpfcgc%TYPE, --> Numero do CPF/CGC que se deseja buscar
                                pr_xmllog         IN  VARCHAR2,              --> XML com informações de LOG
                                pr_cdcritic       OUT PLS_INTEGER,           --> Código da crítica
                                pr_dscritic       OUT VARCHAR2,              --> Descrição da crítica
                                pr_retxml         IN  OUT NOCOPY XMLType,    --> Arquivo de retorno do XML
                                pr_nmdcampo       OUT VARCHAR2,              --> Nome do campo com erro
                                pr_des_erro       OUT VARCHAR2);             --> Erros do processo

-- Efetua a consulta geral com base em uma sequencia de consulta do biro e retorna em XML
PROCEDURE pc_consulta_geral_xml(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                               ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

-- Efetua a consulta geral com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_geral(pr_nrconbir IN  crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                           ,pr_nrseqdet IN  crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                           ,pr_retxml   OUT CLOB                  --> Contem o xml de retorno das informacoes
                           ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica

-- Busca os registros do SPC com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_spc(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                         ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                         ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                         ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                         ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                         ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

-- Busca os registros de cheques com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_cheque(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                            ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                            ,pr_idsitchq IN crapcsf.idsitchq%TYPE --> Tipo de cheque (1-Sem fundo, 2-Sinis/Extrav)
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

-- Busca os dados do cabecalho com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_cabecalho(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                               ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
         
-- Busca os registros do PEFIN e/ou REFIN com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_pefin_refin(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                                 ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                                 ,pr_inpefref IN crapprf.inpefref%TYPE --> Indicador de Pefin/Refin (1-Pefin, 2-Refin, 0-Todos)
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

-- Busca os registros de acoes com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_escore(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                            ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

-- Busca os registros de protestos com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_protesto(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                              ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

-- Busca o resumo das pendencias financeiras com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_pendencia_fin(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                                   ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                                   ,pr_innegati IN craprpf.innegati%TYPE --> Indicador de negativa (0-Todos, 1-Refin, 2-Pefin, 3-Protesto, 4-Acao judicial, 
                                                                         --  5-Participacao em falencia, 6-Cheque sem fundo, 7-Cheques sustados e extraviados)
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

-- Busca os registros de acoes com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_acao(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                          ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

-- Busca os registros de recuperacoes, falencias e concordatas com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_falencia(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                              ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

-- Busca os registros de socios com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_socios(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                            ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

-- Busca os registros de administradores com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_administrador(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                                   ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

-- Retorna se o associado esta com pendencia no Biro de consulta
PROCEDURE pc_verifica_situacao(pr_nrconbir IN  crapcbd.nrconbir%TYPE, --> Numero da consulta que foi realizada
                               pr_nrseqdet IN  crapcbd.nrseqdet%TYPE, --> Sequencial dentro da consulta que foi realizada
                               pr_cdbircon OUT crapbir.cdbircon%TYPE, --> Codigo do biro de consulta
                               pr_dsbircon OUT crapbir.dsbircon%TYPE, --> Descricao do biro de consulta
                               pr_cdmodbir OUT crapmbr.cdmodbir%TYPE, --> Codigo da modalidade de consulta
                               pr_dsmodbir OUT crapmbr.dsmodbir%TYPE, --> Descricao da modalidade de consulta
                               pr_flsituac OUT VARCHAR2);             --> Situacao da consulta

-- Retorna se o associado esta com pendencia no Biro de consulta por XML
PROCEDURE pc_verifica_situacao_xml(pr_nrconbir crapcbd.nrconbir%TYPE, --> Numero da consulta que foi realizada
                                   pr_nrseqdet crapcbd.nrseqdet%TYPE, --> Sequencial dentro da consulta que foi realizada
                                   pr_xmllog   IN VARCHAR2,           --> XML com informações de LOG
                                   pr_cdcritic OUT PLS_INTEGER,       --> Código da crítica
                                   pr_dscritic OUT VARCHAR2,          --> Descrição da crítica
                                   pr_retxml   IN OUT NOCOPY XMLType, --> Arquivo de retorno do XML
                                   pr_nmdcampo OUT VARCHAR2,          --> Nome do campo com erro
                                   pr_des_erro OUT VARCHAR2);         --> Erros do processo

-- Gera o relatorio com o resumo das pesquisas nos Biros
PROCEDURE pc_solicita_relato_xml(pr_cdcooper IN crapepr.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                 pr_intiprel IN PLS_INTEGER,           --> Tipo de relatorio. 1-Analitico, 2-Sintetico
                                 pr_dtperini IN DATE,                  --> Data de inicio da consulta
                                 pr_dtperfim IN DATE,                  --> Data final da consulta
                                 pr_cdagenci IN crapage.cdagenci%TYPE, --> Codigo do PA que solicitou a consulta
                                 pr_xmllog   IN VARCHAR2,              --> XML com informações de LOG
                                 pr_cdcritic OUT PLS_INTEGER,          --> Código da crítica
                                 pr_dscritic OUT VARCHAR2,             --> Descrição da crítica
                                 pr_retxml   IN OUT NOCOPY XMLType,    --> Arquivo de retorno do XML
                                 pr_nmdcampo OUT VARCHAR2,             --> Nome do campo com erro
                                 pr_des_erro OUT VARCHAR2);            --> Erros do processo    -- Busca os dados da consulta do Biro

-- Rotina para geracao dos dados de relatorio detalhado
PROCEDURE pc_solicita_relato_det_xml(pr_cdcooper IN crapepr.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                     pr_dtperini IN DATE,                  --> Data de inicio da consulta
                                     pr_dtperfim IN DATE,                  --> Data final da consulta
                                     pr_cdagenci IN crapage.cdagenci%TYPE, --> Codigo do PA que solicitou a consulta
                                     pr_xmllog   IN VARCHAR2,              --> XML com informações de LOG
                                     pr_cdcritic OUT PLS_INTEGER,          --> Código da crítica
                                     pr_dscritic OUT VARCHAR2,             --> Descrição da crítica
                                     pr_retxml   IN OUT NOCOPY XMLType,    --> Arquivo de retorno do XML
                                     pr_nmdcampo OUT VARCHAR2,             --> Nome do campo com erro
                                     pr_des_erro OUT VARCHAR2);            --> Erros do processo    -- Busca os dados da consulta do Biro

-- Funcao para conversao de texto em base64
FUNCTION pc_encode_base64(pr_texto IN VARCHAR2) RETURN VARCHAR2;

-- Busca os dados de consulta do SCR
PROCEDURE pc_consulta_bacen_xml(pr_cdcooper       IN  crapass.cdcooper%TYPE --> Codigo da cooperativa de emprestimo
                               ,pr_nrdconta       IN  crapass.nrdconta%TYPE --> Numero da conta do emprestimo
                               ,pr_nrdocmto       IN  crapepr.nrctremp%TYPE --> Numero do documento a ser consultado
                               ,pr_inprodut       IN  PLS_INTEGER           --> Indicador de produto (1-Emprestimos, 2-Financiamentos, 3-Contrato limite cheque especial, 4-Contrato limite desconto de cheque, 5-Contrato Limite Desconto de Titulos)
                               ,pr_nrdconta_busca IN  crapass.nrdconta%TYPE --> Numero da conta que se deseja buscar
                               ,pr_nrcpfcgc_busca IN  crapass.nrcpfcgc%TYPE --> Numero do CPF/CGC que se deseja buscar
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

-- Busca os dados da consulta Bacen
PROCEDURE pc_consulta_bacen(pr_cdcooper       IN  crapass.cdcooper%TYPE --> Codigo da cooperativa de emprestimo
                           ,pr_nrdconta       IN  crapass.nrdconta%TYPE --> Numero da conta do emprestimo
                           ,pr_nrdocmto       IN  crapepr.nrctremp%TYPE --> Numero do documento a ser consultado
                           ,pr_inprodut       IN  PLS_INTEGER           --> Indicador de produto (1-Emprestimos, 2-Financiamentos, 3-Contrato limite cheque especial, 4-Contrato limite desconto de cheque, 5-Contrato Limite Desconto de Titulos)
                           ,pr_nrdconta_busca IN  crapass.nrdconta%TYPE --> Numero da conta que se deseja buscar
                           ,pr_nrcpfcgc_busca IN  crapass.nrcpfcgc%TYPE --> Numero do CPF/CGC que se deseja buscar
                           ,pr_retxml   OUT CLOB                        --> Contem o xml de retorno das informacoes
                           ,pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2);                  --> Descrição da crítica

-- Atualiza o campo de informacoes cadastrais automaticamenteo na conta
PROCEDURE pc_atualiza_inf_cad_cta(pr_cdcooper IN  crapepr.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                  pr_nrdconta IN  crapepr.nrdconta%TYPE, --> Numero da conta de emprestimo
                                  pr_cdcritic OUT PLS_INTEGER,           --> Código da crítica
                                  pr_dscritic OUT VARCHAR2);             --> Descrição da crítica

-- Atualiza o campo de informacoes cadastrais automaticamenteo
PROCEDURE pc_atualiza_inf_cadastrais(pr_cdcooper IN  crapepr.cdcooper%TYPE,    --> Codigo da cooperativa de emprestimo
                                     pr_nrdconta IN  crapepr.nrdconta%TYPE,    --> Numero da conta de emprestimo
                                     pr_nrdocmto IN  crapepr.nrctremp%TYPE, --> Numero do contrato
                                     pr_inprodut IN  craprbi.inprodut%TYPE, --> Indicador de tipo de produto
                                     pr_cdcritic OUT PLS_INTEGER,              --> Código da crítica
                                     pr_dscritic OUT VARCHAR2);                --> Descrição da crítica

-- Atualiza o campo de informacoes cadastrais automaticamente no XML
PROCEDURE pc_atualiza_inf_cadastrais_xml(pr_cdcooper IN  crapepr.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                         pr_nrdconta IN  crapepr.nrdconta%TYPE, --> Numero da conta de emprestimo
                                         pr_nrdocmto IN  crapepr.nrctremp%TYPE, --> Numero do contrato
                                         pr_inprodut IN  craprbi.inprodut%TYPE, --> Indicador de tipo de produto
                                         pr_xmllog   IN  VARCHAR2,              --> XML com informações de LOG
                                         pr_cdcritic OUT PLS_INTEGER,           --> Código da crítica
                                         pr_dscritic OUT VARCHAR2,              --> Descrição da crítica
                                         pr_retxml   IN  OUT NOCOPY XMLType,    --> Arquivo de retorno do XML
                                         pr_nmdcampo OUT VARCHAR2,              --> Nome do campo com erro
                                         pr_des_erro OUT VARCHAR2);             --> Erros do processo

-- Verifica se deve chamar a tela de informacoes cadastrais e nao disparar a consulta
PROCEDURE pc_obrigacao_consulta(pr_cdcooper IN  crapass.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                pr_inprodut IN  craprbi.inprodut%TYPE, --> Indicador de tipo de produto
                                pr_inpessoa IN  crappcb.inpessoa%TYPE, --> Indicador de pessoa (1-Fisica, 2-Juridica, 3-Ambos)
                                pr_vlprodut IN  crappcb.vlinicio%TYPE, --> Valor do produto
                                pr_cdfinemp IN  crawepr.cdfinemp%TYPE, --> Codigo da finalidade do emprestimo
                                pr_cdlcremp IN  craplcr.cdlcremp%TYPE, --> Codigo da linha de credito
                                pr_inobriga OUT varchar2);

-- Verifica se deve chamar a tela de informacoes cadastrais e nao disparar a consulta
PROCEDURE pc_obrigacao_consulta_xml(pr_cdcooper IN  crapass.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                    pr_nrdconta IN  crapass.nrdconta%TYPE, --> Numero da conta de emprestimo
                                    pr_nrctremp IN  crapepr.nrctremp%TYPE, --> Numero do contrato de emprestimo
                                    pr_xmllog   IN  VARCHAR2,              --> XML com informações de LOG
                                    pr_cdcritic OUT PLS_INTEGER,           --> Código da crítica
                                    pr_dscritic OUT VARCHAR2,              --> Descrição da crítica
                                    pr_retxml   IN  OUT NOCOPY XMLType,    --> Arquivo de retorno do XML
                                    pr_nmdcampo OUT VARCHAR2,              --> Nome do campo com erro
                                    pr_des_erro OUT VARCHAR2);             --> Erros do processo

-- Verifica se deve chamar a tela de informacoes cadastrais e nao disparar a consulta
-- Esta rotina eh chamada atraves da inclusao da proposta na WEB
PROCEDURE pc_obrigacao_cns_cpl_xml(pr_cdcooper IN  crapass.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                   pr_inprodut IN  craprbi.inprodut%TYPE, --> Indicador de tipo de produto
                                   pr_inpessoa IN  crappcb.inpessoa%TYPE, --> Indicador de pessoa (1-Fisica, 2-Juridica, 3-Ambos)
                                   pr_vlprodut IN  crappcb.vlinicio%TYPE, --> Valor do produto
                                   pr_cdfinemp IN  crawepr.cdfinemp%TYPE, --> Codigo da finalidade do emprestimo
                                   pr_cdlcremp IN  craplcr.cdlcremp%TYPE, --> Codigo da linha de credito
                                   pr_xmllog   IN  VARCHAR2,              --> XML com informações de LOG
                                   pr_cdcritic OUT PLS_INTEGER,           --> Código da crítica
                                   pr_dscritic OUT VARCHAR2,              --> Descrição da crítica
                                   pr_retxml   IN  OUT NOCOPY XMLType,    --> Arquivo de retorno do XML
                                   pr_nmdcampo OUT VARCHAR2,              --> Nome do campo com erro
                                   pr_des_erro OUT VARCHAR2);             --> Erros do processo

-- Verifica se houve mudanca de faixa com base nas consultas ja realizadas para limites.
PROCEDURE pc_verifica_mud_faixa_lim(pr_cdcooper IN  craplim.cdcooper%TYPE, --> Codigo da cooperativa de limite
                                    pr_nrdconta IN  craplim.nrdconta%TYPE, --> Numero da conta de limite
                                    pr_nrctremp IN  craplim.nrctrlim%TYPE, --> Numero do contrato de limite
                                    pr_flmudfai OUT VARCHAR2);             --> Indicador de mudanca de faixa
          
-- Retornar qual o enquadramento da pessoa na proposta 
PROCEDURE pc_busca_intippes(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cód. da cooperativa
													 ,pr_nrdconta IN crapass.nrdconta%TYPE     --> Nr. da conta
													 ,pr_nrctremp IN crapepr.nrctremp%TYPE     --> Nr. do contrato de empréstimo
													 ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE     --> Nr. do CPF/CNPJ
													 ,pr_dsclasse IN VARCHAR2                  --> Classe Ibratan
                                                     ,pr_tpctrato IN crapavt.tpctrato%TYPE DEFAULT 1 --> Tipo de Contrato 1-Emprestimo, 8-Limite Desconto Titulo
                                                     ,pr_nrctapes OUT NUMBER                   --> Conta relacionada
													 ,pr_intippes OUT NUMBER                   --> 1-Titular; 2-Avalista; 3-Conjuge; 7-Repr. Legal/Procurador; 0-Erro.
													 ,pr_inpessoa OUT NUMBER);                 --> 1-Física; 2- Jurídica

-- Busca as informações das consultas efetuadas nos Birôs a partir da Esteira
PROCEDURE pc_retorna_conaut_esteira(pr_cdcooper IN NUMBER        -- Código da Cooperativa da Proposta
																	 ,pr_nrdconta IN NUMBER        -- Número da Conta da Proposta
																	 ,pr_nrctremp IN NUMBER        -- Número da Proposta
																	 ,pr_dsprotoc IN VARCHAR2      -- Descrição do Protocolo da Análise automática na Ibratan
																	 ,pr_cdcritic OUT NUMBER       -- Retornará um possível código de critica
																	 ,pr_dscritic OUT VARCHAR2);   -- Retornará uma possível descrição da crítica

-- Busca as informações das consultas efetuadas nos Birôs a partir da Esteira pelo processo de limite desconto de titulo
PROCEDURE pc_retorna_conaut_est_limdesct(pr_cdcooper IN NUMBER    -- Código da Cooperativa da Proposta
                                        ,pr_nrdconta IN NUMBER    -- Número da Conta da Proposta
                                        ,pr_nrctrlim IN NUMBER    -- Número da Proposta
                                        ,pr_tpctrlim IN NUMBER    -- Tipo da Proposta
                                        ,pr_dsprotoc IN VARCHAR2  -- Descrição do Protocolo da Análise automática na Ibratan
                                        ,pr_cdcritic OUT NUMBER   -- Retornará um possível código de critica
                                        ,pr_dscritic OUT VARCHAR2 -- Retornará uma possível descrição da crítica
                                        );

  PROCEDURE pc_lista_erros_biro_proposta(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                        ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta
                                        ,pr_nrctrato  IN crapepr.nrctremp%TYPE --> Numero do contrato
                                        ,pr_inprodut  IN crappcb.inprodut%TYPE --> Indicador de tipo de produto
                                        --------> OUT <--------
                                        ,pr_clob_xml OUT CLOB                  --> XML com informacoes do retorno
                                        ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                        ,pr_dscritic OUT VARCHAR2);            --> Descricao da critica

  PROCEDURE pc_job_conaut_contigencia;
                                        
END SSPC0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.SSPC0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: SSPC0001                        
  --  Autor   : Andrino Carlos de Souza Junior (RKAM)
  --  Data    : Julho/2014                     Ultima Atualizacao: - 25/01/2019
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package referente a regras de geracao de arquivos SSPCR
  --
  --  Alteracoes: 07/07/2014 - Criação da rotina.
  --
  --              17/03/2016 - Incluido parametro e tratamento Esteira na pc_solicita_consulta_biro    
  --                           PRJ207 - Esteira  (Odirlei-AMcom)
	-- 
	--              27/04/2017 - Incluido procedures pc_busca_intippes e pc_retorna_conaut_esteira.
	--                           Alterado procedures pc_obrigacao_consulta, pc_solicita_retorno_req,
	--                           pc_processa_retorno_req e pc_solicita_consulta_biro. (PRJ337 - Motor de Crédito / Reinert)
  --
  --              19/05/2017 - Alteração da mensagem de retorno do cursor crawepr
  --                         - Inclusão módulo e ação e rotina de log no exception otheres - Chamado 663304
  --                           pc_solicita_consulta_biro (Ana - Envolti)
  --
  --              26/06/2017 - Incluido o campo nrconbir nas pesquisas da crapcbd, melhoria de performance
  --                           (Tiago/Rodrigo #700127).
  --
  --              28/09/2017 - Utilização do atributo classe da consulta da Ibratan
  --                           (Marcos-Supero).
  --
  --             04/12/2017 - Colocado no final pc_retorna_conaut_esteira chamada para pc_atualiza_tab_controle 
  --                          para atualizar tabela craprpf e craprsc (restricoes de crédito) (Alexandre-Mouts)
  --
  --              18/12/2017 - Apresentar erros nos Biros Externos. (Jaison/James - M464)
  --
  --
  --             20/12/2017 - Ajuste de desempenho na procedure pc_consulta_adimistrador onde adicionei a chave
  --                          correta no cursor principal, conforme solicitado no chamado 808164. (Kelvin)            
  --
  --			 07/02/2018 - Ajuste no retorno do XML pc_processa_retorno_req para aceitar multiplas Observacoes, 
  --						  pegando apenas a primeira obs - (Antonio R. JR - Mouts - Chamado 841067)          
  --  
  --             23/03/2018 - Alterado a referencia que era para a tabela CRAPLIM para a tabela CRAWLIM nos procedimentos 
  --                          Referentes a proposta. (Lindon Carlos Pecile - GFT)
  --				
  --             14/03/2018 - Inclusão nova tag no XML  <CEP_END_RES> na procedure pc_monta_cpf_cnpj_envio (Paulo Martins - Mout´s)
  --                          
  --             11/07/2018 - Adicionado na procedure pc_busca_intippes o parâmetro pr_tpctrato e o cursor cr_crawlim para buscar 
  --                          informações da pessoa do contrato de limite de desconto de titulos (Paulo Penteado GFT)
  --
  --             18/10/2018 - sctask0032817 Na rotina pc_solicita_retorno_req, desativada a criação do arquivo da 
  --                          consulta do biro (Carlos)
  --
  --             05/08/2019 - Incluido leitura de classe de risco e probabilidade de inadimplencia para o SERASA
  --                           PRJ 438 - Sprint 15 - Rubens Lima (Mouts)  
  ---------------------------------------------------------------------------------------------------------------

    -- Cursor sobre as pendencias financeiras existentes
    CURSOR cr_craprpf(pr_nrconbir craprpf.nrconbir%TYPE,
                      pr_nrseqdet craprpf.nrseqdet%TYPE,
                      pr_innegati PLS_INTEGER) IS
      SELECT innegati,
             dsnegati,
             decode(qtnegati,0,NULL,qtnegati) qtnegati,
             decode(qtnegati,0,NULL,vlnegati) vlnegati,
             dtultneg
        FROM (SELECT 1 innegati,
                     'REFIN' dsnegati,
                     MAX(craprpf.qtnegati) qtnegati,
                     MAX(craprpf.vlnegati) vlnegati,
                     MAX(craprpf.dtultneg) dtultneg
                FROM craprpf
               WHERE craprpf.nrconbir = pr_nrconbir
                 AND craprpf.nrseqdet = pr_nrseqdet
                 AND craprpf.innegati = 1
              UNION ALL
              SELECT 2,
                     'PEFIN' dsnegati,
                     MAX(craprpf.qtnegati),
                     MAX(craprpf.vlnegati),
                     MAX(craprpf.dtultneg)
                FROM craprpf
               WHERE craprpf.nrconbir = pr_nrconbir
                 AND craprpf.nrseqdet = pr_nrseqdet
                 AND craprpf.innegati = 2
              UNION ALL
              SELECT 3,
                     'Protesto' dsnegati,
                     MAX(craprpf.qtnegati),
                     MAX(craprpf.vlnegati),
                     MAX(craprpf.dtultneg)
                FROM craprpf
               WHERE craprpf.nrconbir = pr_nrconbir
                 AND craprpf.nrseqdet = pr_nrseqdet
                 AND craprpf.innegati = 3
              UNION ALL
              SELECT 4,
                     'A&ccedil;&atilde;o Judicial' dsnegati,
                     MAX(craprpf.qtnegati),
                     MAX(craprpf.vlnegati),
                     MAX(craprpf.dtultneg)
                FROM craprpf
               WHERE craprpf.nrconbir = pr_nrconbir
                 AND craprpf.nrseqdet = pr_nrseqdet
                 AND craprpf.innegati = 4
              UNION ALL
              SELECT 5,
                     'Participa&ccedil;&atilde;o fal&ecirc;ncia' dsnegati,
                     MAX(craprpf.qtnegati),
                     MAX(craprpf.vlnegati),
                     MAX(craprpf.dtultneg)
                FROM craprpf
               WHERE craprpf.nrconbir = pr_nrconbir
                 AND craprpf.nrseqdet = pr_nrseqdet
                 AND craprpf.innegati = 5
              UNION ALL
              SELECT 6,
                     'Cheque sem fundo' dsnegati,
                     MAX(craprpf.qtnegati),
                     MAX(craprpf.vlnegati),
                     MAX(craprpf.dtultneg)
                FROM craprpf
               WHERE craprpf.nrconbir = pr_nrconbir
                 AND craprpf.nrseqdet = pr_nrseqdet
                 AND craprpf.innegati = 6
              UNION ALL
              SELECT 7,
                     'Cheque Sust./Extrav.' dsnegati,
                     MAX(craprpf.qtnegati),
                     MAX(craprpf.vlnegati),
                     MAX(craprpf.dtultneg)
                FROM craprpf
               WHERE craprpf.nrconbir = pr_nrconbir
                 AND craprpf.nrseqdet = pr_nrseqdet
                 AND craprpf.innegati = 7
              UNION ALL
              SELECT 10,
                     'D&iacute;vida vencida' dsnegati,
                     MAX(craprpf.qtnegati),
                     MAX(craprpf.vlnegati),
                     MAX(craprpf.dtultneg)
                FROM craprpf
               WHERE craprpf.nrconbir = pr_nrconbir
                 AND craprpf.nrseqdet = pr_nrseqdet
                 AND craprpf.innegati = 10
              UNION ALL
              SELECT 11,
                     'Inadimpl&ecirc;ncia' dsnegati,
                     MAX(craprpf.qtnegati),
                     MAX(craprpf.vlnegati),
                     MAX(craprpf.dtultneg)
                FROM craprpf
               WHERE craprpf.nrconbir = pr_nrconbir
                 AND craprpf.nrseqdet = pr_nrseqdet
                 AND craprpf.innegati = 11)
       WHERE innegati = decode(pr_innegati,0,innegati
                                            ,pr_innegati);


-- Rotina geral de insert, update, select e delete da tela CONAUT da opção cadastro de Biros
PROCEDURE pc_tela_conaut_crapbir(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - ALteracao / C - Consulta / E - Exclur / I - Inclur)
                                ,pr_cdbircon IN crapbir.cdbircon%TYPE --> Codigo do biro de consultas
                                ,pr_dsbircon IN crapbir.dsbircon%TYPE --> Nome do Biro
                                ,pr_nmtagbir IN crapbir.nmtagbir%TYPE --> Nome da TAG XML do biro
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

      -- Selecionar os dados do cadastro de biro
      CURSOR cr_crapbir IS
      SELECT cdbircon,
             dsbircon,
             nmtagbir
        FROM crapbir
       WHERE cdbircon = decode(pr_cddopcao,'I',nvl(pr_cdbircon,0),nvl(pr_cdbircon,crapbir.cdbircon));

      rw_crapbir cr_crapbir%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis de log
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper      NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);
      
      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN
        -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
        GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_tela_conaut_crapbir');  

        gene0004.pc_extrai_dados(pr_xml => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
        -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
        GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'SSPC0001.pc_tela_conaut_crapbir');  


        OPEN cr_crapbir;
          FETCH cr_crapbir
            INTO rw_crapbir;

        -- Se não encontrar
        IF cr_crapbir%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_crapbir;

          IF pr_cddopcao <> 'I' THEN
            vr_dscritic := 'Biro nao cadastrado.';
            RAISE vr_exc_saida;
          END IF;

        ELSE
          -- Fechar o cursor
          CLOSE cr_crapbir;

          IF pr_cddopcao = 'I' THEN
            vr_dscritic := 'Biro ja cadastrado.';
            RAISE vr_exc_saida;
          END IF;
        END IF;

        -- Verifica o tipo de acao que sera executada
        CASE pr_cddopcao

          WHEN 'A' THEN -- Alteracao

            BEGIN
              -- Atualizacao de registro de biros
              UPDATE
                crapbir
              SET
                crapbir.dsbircon = pr_dsbircon,
                crapbir.nmtagbir = pr_nmtagbir
              WHERE
                crapbir.cdbircon = pr_cdbircon;

            -- Verifica se houve problema na atualizacao do registro
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
                CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
              -- Descricao do erro na insercao de registros
              vr_dscritic := 'Problema ao atualizar CRAPBIR: ' || sqlerrm;
              RAISE vr_exc_saida;

            END;

          WHEN 'C' THEN -- Consulta
            -- Criar cabeçalho do XML
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

            -- Loop sobre os biros
            FOR rw_crapbir IN cr_crapbir LOOP
                
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdbircon', pr_tag_cont => rw_crapbir.cdbircon, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsbircon', pr_tag_cont => rw_crapbir.dsbircon, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmtagbir', pr_tag_cont => rw_crapbir.nmtagbir, pr_des_erro => vr_dscritic);
              
              vr_contador := vr_contador + 1;
            END LOOP;

          WHEN 'E' THEN -- Exclusao

            -- Efetua a exclusao do cadastro de biros
            BEGIN
              DELETE crapbir WHERE cdbircon = pr_cdbircon;
            -- Verifica se houve problema na delecao do registro
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
                CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir CRAPBIR: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

          WHEN 'I' THEN -- Inclusao

            -- Efetua a inclusao no cadastro de biros
            BEGIN
              INSERT INTO
                crapbir(
                  cdbircon,
                  dsbircon,
                  nmtagbir
                )
                VALUES(
                  (SELECT nvl(max(cdbircon)+1,1) FROM crapbir),
                  pr_dsbircon,
                  pr_nmtagbir
                );

            -- Verifica se houve problema na insercao de registros
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
                CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
                vr_dscritic := 'Problema ao inserir CRAPBIR: ' || sqlerrm;
                RAISE vr_exc_saida;

            END;

        END CASE;

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CRAPBIR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    END pc_tela_conaut_crapbir;

-- Rotina geral de insert, update, select e delete da tela CONAUT da opção de contingencia de Biros
PROCEDURE pc_tela_conaut_crapcbr(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - ALteracao / C - Consulta / E - Exclur / I - Inclur)
                                ,pr_cdcooper IN crapcbr.cdcooper%TYPE --> Código da cooperativa
                                ,pr_cdbircon IN crapcbr.cdbircon%TYPE --> Codigo do biro de consultas
                                ,pr_dtinicon IN VARCHAR2              --> Data de inicio da contingencia
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

      -- Selecionar os dados do cadastro de consistencia do biro
      CURSOR cr_crapcbr IS
      SELECT crapcbr.dtinicon,
             crapcbr.cdbircon,
             crapbir.dsbircon,
             crapcbr.cdcooper
        FROM crapbir,
             crapcbr
       WHERE crapcbr.cdcooper = pr_cdcooper
         AND (crapcbr.cdbircon = pr_cdbircon OR pr_cddopcao = 'C')
         AND crapbir.cdbircon = crapcbr.cdbircon;
      rw_crapcbr cr_crapcbr%ROWTYPE;

      -- Busca o nome do biro de consulta
      CURSOR cr_crapbir IS
        SELECT dsbircon
          FROM crapbir
         WHERE cdbircon = pr_cdbircon;
      rw_crapbir cr_crapbir%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      vr_des_erro      VARCHAR2(10000);
      vr_des_log       VARCHAR2(10000);

      -- Variaveis de log
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper      NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN
        -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
        GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_tela_conaut_crapcbr');  

        gene0004.pc_extrai_dados(pr_xml => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
        -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
        GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'SSPC0001.pc_tela_conaut_crapcbr');  

        OPEN cr_crapcbr;
          FETCH cr_crapcbr
            INTO rw_crapcbr;

        -- Se não encontrar
        IF cr_crapcbr%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_crapcbr;

          IF pr_cddopcao <> 'I' THEN
            vr_dscritic := 'Contingencia nao cadastrada.';
            RAISE vr_exc_saida;
          END IF;

        ELSE
          -- Fechar o cursor
          CLOSE cr_crapcbr;

          IF pr_cddopcao = 'I' THEN
            vr_dscritic := 'Contingencia ja cadastrada.';
            RAISE vr_exc_saida;
          END IF;
        END IF;

        -- Verifica o tipo de acao que sera executada
        CASE pr_cddopcao
          WHEN 'A' THEN -- Alteracao
            vr_des_log := to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                          'Operador ' || vr_cdoperad || ' alterou contingencia do biro '||
                          rw_crapcbr.dsbircon||' da data '||to_char(rw_crapcbr.dtinicon,'dd/mm/yyyy')|| 
                          ' para a data de '||pr_dtinicon;
                          
            -- gera o log de alteracao
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog     => 'CONAUT' 
                                      ,pr_des_log      => vr_des_log);

            -- Insere na inconsistencia
            GENE0005.pc_gera_inconsistencia(pr_cdcooper => 3 -- CECRED
                                           ,pr_iddgrupo => 4 -- Consulta Automatizada
                                           ,pr_tpincons => 1 -- Aviso
                                           ,pr_dsregist => 'Cooperativa: ' || pr_cdcooper
                                           ,pr_dsincons => vr_des_log
                                           ,pr_flg_enviar => 'S'
                                           ,pr_des_erro => vr_des_erro
                                           ,pr_dscritic => vr_dscritic);

            BEGIN
              -- Atualizacao de registro de contingencia de biros
              UPDATE crapcbr SET
                     crapcbr.dtinicon = to_date(pr_dtinicon,'dd/mm/yyyy')
               WHERE crapcbr.cdcooper = pr_cdcooper
                 AND crapcbr.cdbircon = pr_cdbircon;
            -- Verifica se houve problema na atualizacao do registro
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao atualizar CRAPBIR: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

          WHEN 'C' THEN -- Consulta
            -- Criar cabeçalho do XML
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
            
            -- Loop sobre o cadastro de contingencia
            FOR rw_crapcbr IN cr_crapcbr LOOP
            
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdbircon', pr_tag_cont => rw_crapcbr.cdbircon, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsbircon', pr_tag_cont => rw_crapcbr.dsbircon, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtinicon', pr_tag_cont => to_char(rw_crapcbr.dtinicon,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);
              
              vr_contador := vr_contador + 1;
            END LOOP;

          WHEN 'E' THEN -- Exclusao

            vr_des_log := to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                          'Operador ' || vr_cdoperad || ' excluiu contingencia do biro '||
                          rw_crapcbr.dsbircon||' com data de '||to_char(rw_crapcbr.dtinicon,'dd/mm/yyyy');
                          
            -- gera o log de exclusao
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog     => 'CONAUT' 
                                      ,pr_des_log      => vr_des_log);

            -- Insere na inconsistencia
            GENE0005.pc_gera_inconsistencia(pr_cdcooper => 3 -- CECRED
                                           ,pr_iddgrupo => 4 -- Consulta Automatizada
                                           ,pr_tpincons => 1 -- Aviso
                                           ,pr_dsregist => 'Cooperativa: ' || pr_cdcooper
                                           ,pr_dsincons => vr_des_log
                                           ,pr_flg_enviar => 'S'
                                           ,pr_des_erro => vr_des_erro
                                           ,pr_dscritic => vr_dscritic);
                                                                                    
            -- Efetua a exclusao do cadastro de contingencia de biros
            BEGIN
              DELETE crapcbr 
                WHERE cdcooper = pr_cdcooper
                  AND cdbircon = pr_cdbircon;
            -- Verifica se houve problema na delecao do registro
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir CRAPCBR: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

          WHEN 'I' THEN -- Inclusao

            -- Verifica se a data foi informada
            IF pr_dtinicon IS NULL OR pr_dtinicon = ' ' THEN
              vr_dscritic := 'Data de inicio deve ser informada!';
              RAISE vr_exc_saida;
            END IF;

            -- Busca o nome do Biro
            OPEN cr_crapbir;
            FETCH cr_crapbir INTO rw_crapbir;
            CLOSE cr_crapbir;
            
            vr_des_log := to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                          'Operador ' || vr_cdoperad || ' incluiu contingencia do biro '||
                          rw_crapbir.dsbircon||' com data de '||pr_dtinicon;
            
            -- gera o log de inclusao
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog     => 'CONAUT' 
                                      ,pr_des_log      => vr_des_log);
                                         
            -- Insere na inconsistencia
            GENE0005.pc_gera_inconsistencia(pr_cdcooper => 3 -- CECRED
                                           ,pr_iddgrupo => 4 -- Consulta Automatizada
                                           ,pr_tpincons => 1 -- Aviso
                                           ,pr_dsregist => 'Cooperativa: ' || pr_cdcooper
                                           ,pr_dsincons => vr_des_log
                                           ,pr_flg_enviar => 'S'
                                           ,pr_des_erro => vr_des_erro
                                           ,pr_dscritic => vr_dscritic);                             

            -- Efetua a inclusao no cadastro de biros
            BEGIN
              INSERT INTO
                crapcbr(
                  cdcooper,
                  cdbircon,
                  dtinicon
                )
                VALUES(
                   pr_cdcooper,
                   pr_cdbircon,
                   to_date(pr_dtinicon,'dd/mm/yyyy')
                );

            -- Verifica se houve problema na insercao de registros
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
                vr_dscritic := 'Problema ao inserir CRAPCBR: ' || sqlerrm;
                RAISE vr_exc_saida;

            END;

        END CASE;

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CRAPCBR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    END pc_tela_conaut_crapcbr;

-- Rotina geral de insert, update, select e delete da tela CONAUT da opção de dias de reaproveitamento
PROCEDURE pc_tela_conaut_craprbi(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                                ,pr_cdcooper IN craprbi.cdcooper%TYPE --> Codigo da cooperativa
                                ,pr_inprodut IN craprbi.inprodut%TYPE --> Indicador de tipo de produto
                                ,pr_inpessoa IN craprbi.inpessoa%TYPE --> Indicador de pessoa Fisica / Juridica
                                ,pr_qtdiarpv IN craprbi.qtdiarpv%TYPE --> Quantidade de dias de reaproveitamento
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

      -- Selecionar os dados do cadastro de reaproveitamento de consulta
      CURSOR cr_craprbi IS
      SELECT inprodut,
             inpessoa,
             qtdiarpv
        FROM craprbi
       WHERE cdcooper = pr_cdcooper
         AND ((inprodut = nvl(pr_inprodut,inprodut)
          AND  inpessoa = nvl(pr_inpessoa,inpessoa)
          AND pr_cddopcao = 'C')
          OR  (inprodut = pr_inprodut
          AND  inpessoa = pr_inpessoa));

      rw_craprbi cr_craprbi%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis de log
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper      NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);
      
      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;
      vr_inprodut VARCHAR2(50); --Descricao do tipo de produto
      vr_inpessoa VARCHAR2(10); --Descricao do tipo de pessoa

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN
        -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
        GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_tela_conaut_craprbi');  

        gene0004.pc_extrai_dados(pr_xml => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
        -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
        GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'SSPC0001.pc_tela_conaut_craprbi');  

        OPEN cr_craprbi;
          FETCH cr_craprbi
            INTO rw_craprbi;

        -- Monta o produto para o log
        IF pr_inprodut = 1 THEN
          vr_inprodut := 'Emprestimos';
        ELSIF pr_inprodut = 2 THEN
          vr_inprodut := 'Financiamentos';
        ELSIF pr_inprodut = 3 THEN
          vr_inprodut := 'Contrato limite cheque especial';
        ELSIF pr_inprodut = 4 THEN
          vr_inprodut := 'Contrato limite desconto de cheque';
        ELSIF pr_inprodut = 5 THEN
          vr_inprodut := 'Contrato limite desconto de titulos';
        ELSIF pr_inprodut = 6 THEN
          vr_inprodut := 'Cadastramento de Conta';
        ELSE
          vr_inprodut := pr_inprodut;
        END IF; 
        
        -- Monta o tipo de pessoa para o log
        IF pr_inpessoa = 1 THEN
          vr_inpessoa := 'Fisica';
        ELSE
          vr_inpessoa := 'Juridica';
        END IF;

        -- Se não encontrar
        IF cr_craprbi%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_craprbi;

          IF pr_cddopcao <> 'I' THEN
            vr_dscritic := 'Quantidade de dias de reaproveitamento nao cadastrado.';
            RAISE vr_exc_saida;
          END IF;

        ELSE
          -- Fechar o cursor
          CLOSE cr_craprbi;

          IF pr_cddopcao = 'I' THEN
            vr_dscritic := 'Quantidade de dias de reaproveitamento ja cadastrado.';
            RAISE vr_exc_saida;
          END IF;
        END IF;

        -- Verifica o tipo de acao que sera executada
        CASE pr_cddopcao
          WHEN 'A' THEN -- Alteracao

            -- gera o log de alteracao
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog => 'CONAUT' 
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                         'Operador ' || vr_cdoperad || ' alterou a quantidade de dias de reaproveitamento de  '||
                                         rw_craprbi.qtdiarpv||' dia(s) para '||pr_qtdiarpv||' dia(s). '||
                                         'Produto: '||vr_inprodut||
                                         '. Pessoa: '||vr_inpessoa||'.');

            BEGIN
              -- Atualizacao de dias de reaproveitamento das consultas do biro
              UPDATE craprbi
                 SET craprbi.qtdiarpv = pr_qtdiarpv
               WHERE craprbi.cdcooper = pr_cdcooper
                 AND craprbi.inprodut = pr_inprodut
                 AND craprbi.inpessoa = pr_inpessoa;

            -- Verifica se houve problema na atualizacao do registro
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
              -- Descricao do erro na insercao de registros
              vr_dscritic := 'Problema ao atualizar craprbi: ' || sqlerrm;
              RAISE vr_exc_saida;

            END;

          WHEN 'C' THEN -- Consulta
            -- Criar cabeçalho do XML
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

            -- Loop sobre os dias de reaproveitamento das consultas do biro
            FOR rw_craprbi IN cr_craprbi LOOP
                
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'inprodut', pr_tag_cont => rw_craprbi.inprodut, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'inpessoa', pr_tag_cont => rw_craprbi.inpessoa, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'qtdiarpv', pr_tag_cont => rw_craprbi.qtdiarpv, pr_des_erro => vr_dscritic);
              
              vr_contador := vr_contador + 1;
            END LOOP;

          WHEN 'E' THEN -- Exclusao

            -- gera o log de exclusao
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog => 'CONAUT' 
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                         'Operador ' || vr_cdoperad || ' excluiu a quantidade de dias de reaproveitamento. '||
                                         'Produto: '||vr_inprodut||
                                         '. Pessoa: '||vr_inpessoa||
                                         '. Dia(s): '||pr_qtdiarpv||'. ');

            -- Efetua a exclusao de dias de reaproveitamento das consultas do biro
            -- Ps: Nao fara exclusao, apenas mudado a quantidade de dias para zero, conforme
            --     solicitado pela Luana
            BEGIN
              -- Atualizacao de dias de reaproveitamento das consultas do biro
              UPDATE craprbi
                 SET craprbi.qtdiarpv = 0
               WHERE craprbi.cdcooper = pr_cdcooper
                 AND craprbi.inprodut = pr_inprodut
                 AND craprbi.inpessoa = pr_inpessoa;
            -- Verifica se houve problema na delecao do registro
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir craprbi: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

          WHEN 'I' THEN -- Inclusao

            -- gera o log de inclusao
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog => 'CONAUT' 
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                         'Operador ' || vr_cdoperad || ' incluiu a quantidade de dias de reaproveitamento. '||
                                         'Produto: '||vr_inprodut||
                                         '. Pessoa: '||vr_inpessoa||
                                         '. Dia(s): '||pr_qtdiarpv||'. ');

            -- Efetua a inclusao no cadastro de biros
            BEGIN
              INSERT INTO
                craprbi(
                  cdcooper,
                  inprodut,
                  inpessoa,
                  qtdiarpv
                )
                VALUES(
                   pr_cdcooper,
                   pr_inprodut,
                   pr_inpessoa,
                   pr_qtdiarpv
                );

            -- Verifica se houve problema na insercao de registros
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
                vr_dscritic := 'Problema ao inserir craprbi: ' || sqlerrm;
                RAISE vr_exc_saida;

            END;

        END CASE;

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em craprbi: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    END pc_tela_conaut_craprbi;


-- Rotina geral de insert, update, select e delete da tela CONAUT da opção de cadastro de modalidades
PROCEDURE pc_tela_conaut_crapmbr(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                                ,pr_cdbircon IN crapmbr.cdbircon%TYPE --> Código do biro de consultas
                                ,pr_cdmodbir IN crapmbr.cdmodbir%TYPE --> Codigo da modalidade do biro
                                ,pr_dsmodbir IN crapmbr.dsmodbir%TYPE --> Descricao da modalidade do biro
                                ,pr_inpessoa IN crapmbr.inpessoa%TYPE --> Indicador de pessoa Fisica / Juridica
                                ,pr_nmtagmod IN crapmbr.nmtagmod%TYPE --> Nome da tag XML da modalidade
                                ,pr_nrordimp IN crapmbr.nrordimp%TYPE --> Ordem de importancia da modalidade
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

      -- Selecionar os dados da parametrizacao de modalidades
      CURSOR cr_crapmbr IS
      SELECT crapmbr.cdbircon,
             crapbir.dsbircon,
             crapmbr.inpessoa,
             crapmbr.cdmodbir,
             crapmbr.dsmodbir,
             crapmbr.nmtagmod,
             crapmbr.nrordimp
        FROM crapbir,
             crapmbr
       WHERE crapmbr.cdbircon = nvl(pr_cdbircon,crapmbr.cdbircon)
         AND crapmbr.cdmodbir = decode(pr_cddopcao,'I',nvl(pr_cdmodbir,0),nvl(pr_cdmodbir,crapmbr.cdmodbir))
         AND crapmbr.inpessoa = decode(pr_cddopcao,'C',nvl(pr_inpessoa,crapmbr.inpessoa),crapmbr.inpessoa)
         AND crapbir.cdbircon = crapmbr.cdbircon;

      rw_crapmbr cr_crapmbr%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis de log
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper      NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);
      
      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN
        -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
        GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_tela_conaut_crapmbr');  

        gene0004.pc_extrai_dados(pr_xml => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
        -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
        GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'SSPC0001.pc_tela_conaut_crapmbr');  

        OPEN cr_crapmbr;
          FETCH cr_crapmbr
            INTO rw_crapmbr;

        -- Se não encontrar
        IF cr_crapmbr%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_crapmbr;

          IF pr_cddopcao <> 'I' THEN
            vr_dscritic := 'Modalidade nao cadastrada.';
            RAISE vr_exc_saida;
          END IF;

        ELSE
          -- Fechar o cursor
          CLOSE cr_crapmbr;

          IF pr_cddopcao = 'I' THEN
            vr_dscritic := 'Modalidade ja cadastrada.';
            RAISE vr_exc_saida;
          END IF;
        END IF;

        -- Verifica o tipo de acao que sera executada
        CASE pr_cddopcao

          WHEN 'A' THEN -- Alteracao

            BEGIN
              -- Atualizacao da modalidade de consulta
              UPDATE crapmbr
                 SET crapmbr.dsmodbir = pr_dsmodbir,
                     crapmbr.inpessoa = pr_inpessoa,
                     crapmbr.nmtagmod = pr_nmtagmod,
                     crapmbr.nrordimp = pr_nrordimp
               WHERE crapmbr.cdbircon = pr_cdbircon
                 AND crapmbr.cdmodbir = pr_cdmodbir;

            -- Verifica se houve problema na atualizacao do registro
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
               CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
              -- Descricao do erro na insercao de registros
              vr_dscritic := 'Problema ao atualizar crapmbr: ' || sqlerrm;
              RAISE vr_exc_saida;

            END;

          WHEN 'C' THEN -- Consulta
            -- Criar cabeçalho do XML
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

            -- Loop sobre a modalidade de consulta
            FOR rw_crapmbr IN cr_crapmbr LOOP
                
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdbircon', pr_tag_cont => rw_crapmbr.cdbircon, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsbircon', pr_tag_cont => rw_crapmbr.dsbircon, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdmodbir', pr_tag_cont => rw_crapmbr.cdmodbir, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsmodbir', pr_tag_cont => rw_crapmbr.dsmodbir, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'inpessoa', pr_tag_cont => rw_crapmbr.inpessoa, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmtagmod', pr_tag_cont => rw_crapmbr.nmtagmod, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrordimp', pr_tag_cont => rw_crapmbr.nrordimp, pr_des_erro => vr_dscritic);
              
              vr_contador := vr_contador + 1;
            END LOOP;

          WHEN 'E' THEN -- Exclusao

            -- Efetua a exclusao da modalidade de consulta
            BEGIN
              DELETE crapmbr 
               WHERE cdbircon = pr_cdbircon
                 AND cdmodbir = pr_cdmodbir;
            -- Verifica se houve problema na delecao do registro
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
                CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir crapmbr: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

          WHEN 'I' THEN -- Inclusao

            -- Efetua a inclusao de parametrizacao da modalidade de consulta
            BEGIN
              INSERT INTO
                crapmbr(
                  cdbircon,
                  cdmodbir,
                  dsmodbir,
                  inpessoa,
                  nmtagmod,
                  nrordimp
                )
                VALUES(
                   pr_cdbircon,
                   (SELECT nvl(max(cdmodbir)+1,1) FROM crapmbr WHERE cdbircon = pr_cdbircon),
                   pr_dsmodbir,
                   pr_inpessoa,
                   pr_nmtagmod,
                   pr_nrordimp
                );

            -- Verifica se houve problema na insercao de registros
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
                CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
                vr_dscritic := 'Problema ao inserir crapmbr: ' || sqlerrm;
                RAISE vr_exc_saida;

            END;

        END CASE;

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em crapmbr: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    END pc_tela_conaut_crapmbr;
    
    
-- Rotina geral de insert, update, select e delete da tela CONAUT da opção de parametrizaçao de modalidades
PROCEDURE pc_tela_conaut_crappcb(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                                ,pr_cdcooper IN crappcb.cdcooper%TYPE --> Codigo da cooperativa
                                ,pr_inprodut IN crappcb.inprodut%TYPE --> Indicador de tipo de produto
                                ,pr_cdbircon IN crappcb.cdbircon%TYPE --> Código do biro de consultas
                                ,pr_inpessoa IN crappcb.inpessoa%TYPE --> Indicador de pessoa Fisica / Juridica
                                ,pr_vlinicio IN crappcb.vlinicio%TYPE --> Inicio da faixa de parametrizacao
                                ,pr_cdmodbir IN crappcb.cdmodbir%TYPE --> Modalidade do biro
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

      -- Selecionar os dados da parametrizacao de modalidades
      CURSOR cr_crappcb IS
      SELECT crappcb.inprodut,
             crappcb.cdbircon,
             crapbir.dsbircon,
             crappcb.inpessoa,
             crappcb.vlinicio,
             crappcb.cdmodbir,
             crapmbr.dsmodbir
        FROM crapmbr,
             crapbir,
             crappcb
       WHERE crappcb.cdcooper = pr_cdcooper
         AND crappcb.inprodut = decode(nvl(pr_inprodut,0),0,crappcb.inprodut,pr_inprodut)
         AND crappcb.cdbircon = nvl(pr_cdbircon,crappcb.cdbircon)
         AND crappcb.inpessoa = nvl(pr_inpessoa,crappcb.inpessoa)
         AND crappcb.vlinicio = nvl(pr_vlinicio,crappcb.vlinicio)
         AND crapbir.cdbircon = crappcb.cdbircon
         AND crapmbr.cdbircon = crappcb.cdbircon
         AND crapmbr.cdmodbir = crappcb.cdmodbir;
      rw_crappcb cr_crappcb%ROWTYPE;
      
      -- Cursor para trazer o nome da modalidade do biro
      CURSOR cr_crapmbr IS
        SELECT crapbir.dsbircon,
               crapmbr.dsmodbir
          FROM crapbir,
               crapmbr
         WHERE crapmbr.cdbircon = pr_cdbircon
           AND crapmbr.cdmodbir = pr_cdmodbir
           AND crapbir.cdbircon = crapmbr.cdbircon;
      rw_crapmbr cr_crapmbr%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis de log
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper      NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);
      
      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;
      vr_inprodut VARCHAR2(50); --Descricao do tipo de produto
      vr_inpessoa VARCHAR2(10); --Descricao do tipo de pessoa

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN
        -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
        GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_tela_conaut_crappcb');  

        gene0004.pc_extrai_dados(pr_xml => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
        -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
        GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'SSPC0001.pc_tela_conaut_crappcb');  

        -- Monta o produto para o log
        IF pr_inprodut = 1 THEN
          vr_inprodut := 'Emprestimos';
        ELSIF pr_inprodut = 2 THEN
          vr_inprodut := 'Financiamentos';
        ELSIF pr_inprodut = 3 THEN
          vr_inprodut := 'Contrato limite cheque especial';
        ELSIF pr_inprodut = 4 THEN
          vr_inprodut := 'Contrato limite desconto de cheque';
        ELSIF pr_inprodut = 5 THEN
          vr_inprodut := 'Contrato limite desconto de titulos';
        ELSIF pr_inprodut = 6 THEN
          vr_inprodut := 'Cadastramento de Conta';
        ELSE
          vr_inprodut := pr_inprodut;
        END IF; 
        
        -- Monta o tipo de pessoa para o log
        IF pr_inpessoa = 1 THEN
          vr_inpessoa := 'Fisica';
        ELSE
          vr_inpessoa := 'Juridica';
        END IF;

        OPEN cr_crappcb;
          FETCH cr_crappcb
            INTO rw_crappcb;

        -- Se não encontrar
        IF cr_crappcb%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_crappcb;

          IF pr_cddopcao = 'C' THEN
            -- Nao da mensagem que nao encontrou... apenas volta para o fonte
            RETURN;
          ELSIF pr_cddopcao <> 'I' THEN
            vr_dscritic := 'Parametrizacao de modalidade nao cadastrada.';
            RAISE vr_exc_saida;
          END IF;

        ELSE
          -- Fechar o cursor
          CLOSE cr_crappcb;

          IF pr_cddopcao = 'I' THEN
            vr_dscritic := 'Parametrizacao de modalidade ja cadastrada.';
            RAISE vr_exc_saida;
          END IF;
        END IF;

        -- Verifica o tipo de acao que sera executada
        CASE pr_cddopcao

          WHEN 'A' THEN -- Alteracao

            -- Busca o nome da modalidade do biro para o log
            OPEN cr_crapmbr;
            FETCH cr_crapmbr INTO rw_crapmbr;
            CLOSE cr_crapmbr;

            -- gera o log de alteracao
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog => 'CONAUT' 
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                         'Operador ' || vr_cdoperad || ' alterou a modalidade do biro na parametrizacao da proposta de  '||
                                         rw_crappcb.dsmodbir ||' para '||rw_crapmbr.dsmodbir||'. '||
                                         'Produto: '||vr_inprodut||
                                         '. Pessoa: '||vr_inpessoa||
                                         '. Vl Inicio: '||to_char(pr_vlinicio,'fm999G999G990D00')||
                                         '. Biro: '||rw_crapmbr.dsbircon||'.');


            BEGIN
              -- Atualizacao de parametrizacao da modalidade de consulta
              UPDATE crappcb
                 SET crappcb.cdmodbir = pr_cdmodbir
               WHERE crappcb.cdcooper = pr_cdcooper
                 AND crappcb.inprodut = pr_inprodut
                 AND crappcb.cdbircon = pr_cdbircon
                 AND crappcb.inpessoa = pr_inpessoa
                 AND crappcb.vlinicio = pr_vlinicio;

            -- Verifica se houve problema na atualizacao do registro
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
              -- Descricao do erro na insercao de registros
              vr_dscritic := 'Problema ao atualizar crappcb: ' || sqlerrm;
              RAISE vr_exc_saida;

            END;

          WHEN 'C' THEN -- Consulta
            -- Criar cabeçalho do XML
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

            -- Loop sobre a parametrizacao da modalidade de consulta
            FOR rw_crappcb IN cr_crappcb LOOP
                
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'inprodut', pr_tag_cont => rw_crappcb.inprodut, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdbircon', pr_tag_cont => rw_crappcb.cdbircon, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsbircon', pr_tag_cont => rw_crappcb.dsbircon, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'inpessoa', pr_tag_cont => rw_crappcb.inpessoa, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlinicio', pr_tag_cont => rw_crappcb.vlinicio, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdmodbir', pr_tag_cont => rw_crappcb.cdmodbir, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsmodbir', pr_tag_cont => rw_crappcb.dsmodbir, pr_des_erro => vr_dscritic);
              
              vr_contador := vr_contador + 1;
            END LOOP;

          WHEN 'E' THEN -- Exclusao

            -- gera o log de exclusao
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog => 'CONAUT' 
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                         'Operador ' || vr_cdoperad || ' excluiu a parametrizacao da proposta do '||
                                         'Produto: '||vr_inprodut||
                                         '. Pessoa: '||vr_inpessoa||
                                         '. Vl Inicio: '||to_char(pr_vlinicio,'fm999G999G990D00')||
                                         '. Biro: '||rw_crappcb.dsbircon||'-'||rw_crappcb.dsmodbir|| '.');

            -- Efetua a exclusao de parametrizacao da modalidade de consulta
            BEGIN
              DELETE crappcb 
               WHERE cdcooper = pr_cdcooper
                 AND inprodut = pr_inprodut
                 AND cdbircon = pr_cdbircon
                 AND inpessoa = pr_inpessoa
                 AND vlinicio = pr_vlinicio;
            -- Verifica se houve problema na delecao do registro
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir crappcb: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

          WHEN 'I' THEN -- Inclusao

            -- Busca o nome da modalidade do biro para o log
            OPEN cr_crapmbr;
            FETCH cr_crapmbr INTO rw_crapmbr;
            CLOSE cr_crapmbr;

            -- gera o log de inclusao
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog => 'CONAUT' 
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                         'Operador ' || vr_cdoperad || ' incluiu parametrizacao da proposta do '||
                                         'Produto: '||vr_inprodut||
                                         '. Pessoa: '||vr_inpessoa||
                                         '. Vl Inicio: '||to_char(pr_vlinicio,'fm999G999G990D00')||
                                         '. Biro: '||rw_crapmbr.dsbircon||'-'||rw_crapmbr.dsmodbir|| '.');

            -- Efetua a inclusao de parametrizacao da modalidade de consulta
            BEGIN
              INSERT INTO
                crappcb(
                  cdcooper,
                  inprodut,
                  cdbircon,
                  inpessoa,
                  vlinicio,
                  cdmodbir
                )
                VALUES(
                   pr_cdcooper,
                   pr_inprodut,
                   pr_cdbircon,
                   pr_inpessoa,
                   pr_vlinicio,
                   pr_cdmodbir
                );

            -- Verifica se houve problema na insercao de registros
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
                vr_dscritic := 'Problema ao inserir crappcb: ' || sqlerrm;
                RAISE vr_exc_saida;

            END;

        END CASE;

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em crappcb: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    END pc_tela_conaut_crappcb;

-- Rotina geral de insert e update da tela CONAUT da opção de tempo de retorno das consultaas
PROCEDURE pc_tela_conaut_crapprm(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta)
                                ,pr_cdcooper IN crapcbr.cdcooper%TYPE --> Código da cooperativa
                                ,pr_qtsegrsp IN PLS_INTEGER           --> Quantidade de segundos para aguardo de resposta
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo


      -- Selecionar os dados da parametrizacao de modalidades
      CURSOR cr_crapprm IS
        SELECT crapprm.dsvlrprm
          FROM crapprm
         WHERE nmsistem = 'CRED'
           AND cdcooper = pr_cdcooper
           AND cdacesso = 'CONAUT_RESPOSTA';
      rw_crapprm cr_crapprm%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis de log
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper      NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      
      vr_qtsegrsp      PLS_INTEGER;
    BEGIN
        -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
        GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_tela_conaut_crapprm');  

        gene0004.pc_extrai_dados(pr_xml => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
        -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
        GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'SSPC0001.pc_tela_conaut_crapprm');  

        -- Verifica o tipo de acao que sera executada
        CASE pr_cddopcao

          WHEN 'A' THEN -- Alteracao

            -- Busca o tempo anterior para gerar no log
            OPEN cr_crapprm;
            FETCH cr_crapprm INTO rw_crapprm;
            CLOSE cr_crapprm;
            
            -- gera o log de alteracao
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog => 'CONAUT' 
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                         'Operador ' || vr_cdoperad || ' alterou o tempo de retorno das consultas de '||
                                         nvl(rw_crapprm.dsvlrprm,'0') ||' segundos para '||
                                         pr_qtsegrsp || ' segundos.');

            -- Efetua a inclusao na tabela de parametros
            BEGIN
              INSERT INTO crapprm
                (nmsistem,
                 cdcooper,
                 cdacesso,
                 dstexprm,
                 dsvlrprm)
              VALUES
                ('CRED',
                 pr_cdcooper,
                 'CONAUT_RESPOSTA',
                 'Tempo de retorno das consultas do Biro. Parametrizado na tela CONAUT',
                 pr_qtsegrsp);
            EXCEPTION
              WHEN dup_val_on_index THEN
                -- Se ja existir faz o update
                BEGIN
                  UPDATE crapprm
                     SET dsvlrprm = pr_qtsegrsp
                   WHERE nmsistem = 'CRED'
                     AND cdcooper = pr_cdcooper
                     AND cdacesso = 'CONAUT_RESPOSTA';
                EXCEPTION
                  WHEN OTHERS THEN
                    -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
                    CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
                    vr_dscritic := 'Erro ao alterar a CRAPPRM: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
                vr_dscritic := 'Erro ao inserir na CRAPPRM: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
          WHEN 'C' THEN -- Consulta
            -- Criar cabeçalho do XML
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

            -- Busca o tempo de resposta
            OPEN cr_crapprm;
            FETCH cr_crapprm INTO vr_qtsegrsp;
            IF cr_crapprm%NOTFOUND THEN
              vr_qtsegrsp := 0;
            END IF;
            CLOSE cr_crapprm;
            
            -- Monta o XML
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'qtsegrsp', pr_tag_cont => vr_qtsegrsp, pr_des_erro => vr_dscritic);

        END CASE;
           
    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CRAPCBR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    END pc_tela_conaut_crapprm;
        
-- Procedure para consulta na tela CONAUT
PROCEDURE pc_consulta_campo_conaut( pr_nmcamp   IN VARCHAR2                  -- Nome do campo que esta sendo consultado
                                   ,pr_dspesq   IN VARCHAR2                  -- Chave de pesquisa
                                   ,pr_xmllog   IN VARCHAR2                  -- XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER              -- Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                 -- Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType        -- Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                 -- Nome do campo com erro                      
                                   ,pr_des_erro OUT VARCHAR2) IS             -- Erros do processo                                            

      -- Consulta o nome do biro
      CURSOR cr_crapbir(pr_cdbircon crapbir.cdbircon%TYPE) IS
        SELECT dsbircon
          FROM crapbir
         WHERE cdbircon = pr_cdbircon;
      rw_crapbir cr_crapbir%ROWTYPE;

      -- Consulta o nome da modalidade do biro
      CURSOR cr_crapmbr(pr_cdbircon crapmbr.cdbircon%TYPE,
                        pr_cdmodbir crapmbr.cdmodbir%TYPE) IS
        SELECT dsmodbir
          FROM crapmbr
         WHERE cdbircon = pr_cdbircon
           AND cdmodbir = pr_cdmodbir;
      rw_crapmbr cr_crapmbr%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      
      -- Variaveis gerais
      vr_nmcampo_ret   VARCHAR2(08);
      vr_retorno       VARCHAR2(100);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_contador      PLS_INTEGER := 0;    
    BEGIN
        -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
        GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_consulta_campo_conaut');  

      -- Verifica o tipo de campo que se deseja consultar
      IF upper(pr_nmcamp) = 'CDBIRCON' THEN -- Codigo do biro
        OPEN cr_crapbir(pr_dspesq);
        FETCH cr_crapbir INTO rw_crapbir;
        IF cr_crapbir%NOTFOUND THEN
          CLOSE cr_crapbir;
          vr_dscritic := 'Biro inexistente. Favor verificar!';
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapbir;
        vr_nmcampo_ret := 'nmbircon';
        vr_retorno     := rw_crapbir.dsbircon;
        
      ELSIF upper(pr_nmcamp) = 'CDMODBIR' THEN -- Codigo da modalidade do biro
        OPEN cr_crapmbr(SUBSTR(pr_dspesq,1,instr(pr_dspesq,';')-1), --Codigo do biro
                        SUBSTR(pr_dspesq,instr(pr_dspesq,';')+1));  --Modalidade do biro
        FETCH cr_crapmbr INTO rw_crapmbr;
        IF cr_crapmbr%NOTFOUND THEN
          CLOSE cr_crapmbr;
          vr_dscritic := 'Modalidade do biro inexistente. Favor verificar!';
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapmbr;
        vr_nmcampo_ret := 'dsmodbir';
        vr_retorno     := rw_crapmbr.dsmodbir;
      
      ELSE -- Se o parametro nao existe
        vr_dscritic := 'Campo informado na busca nao previsto!';
        RAISE vr_exc_saida;
      END IF;
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => vr_nmcampo_ret, pr_tag_cont => vr_retorno, pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => NULL);  
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CONAUT: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_consulta_campo_conaut;

-- Insere registro na tabela CRAPCBD
PROCEDURE pc_insere_crapcbd(pr_nrconbir IN  crapcbd.nrconbir%TYPE, -- Sequencial com o numero da consulta no biro 
                            pr_cdbircon IN  crapcbd.cdbircon%TYPE, -- Codigo do biro de consultas   
                            pr_cdmodbir IN  crapcbd.cdmodbir%TYPE, -- Codigo da modalidade no biro de consultas   
                            pr_cdcooper IN  crapcbd.cdcooper%TYPE, -- Codigo da cooperativa 
                            pr_nrdconta IN  crapcbd.nrdconta%TYPE, -- Numero da conta/dv do associado (zeros no caso do consultado nao possuir conta). 
                            pr_nrcpfcgc IN  crapcbd.nrcpfcgc%TYPE, -- Numero do cpf/cgc do consultado 
                            pr_inpessoa IN  crapcbd.inpessoa%TYPE, -- Tipo de pessoa (1 - fisica, 2 - juridica) 
                            pr_intippes IN  crapcbd.intippes%TYPE, -- Indicador de tipo de pessoa (1-titular, 2-avalista, 3-conjuge, 4-socio, 5-socio e administrador) 
                            pr_cdcritic OUT crapcri.cdcritic%TYPE, --> Critica encontrada
                            pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_insere_crapcbd');  

    INSERT INTO crapcbd
      (nrconbir,
       nrseqdet,
       dtconbir,
       cdbircon,
       cdmodbir,
       cdcooper,
       nrdconta,
       nrcpfcgc,
       inpessoa,
       intippes,
       inreterr,
       inreapro)
     VALUES
      (pr_nrconbir,
       (SELECT nvl(max(nrseqdet),0)+1 FROM crapcbd WHERE nrconbir = pr_nrconbir),
       SYSDATE,
       pr_cdbircon,
       pr_cdmodbir,
       pr_cdcooper,
       pr_nrdconta,
       pr_nrcpfcgc,
       pr_inpessoa,
       pr_intippes,
       0,
       0);
   EXCEPTION
     WHEN dup_val_on_index THEN
       NULL; -- Nao fazer nada, pois o resumo foi enviado
     WHEN OTHERS THEN
       -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
       CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
       pr_dscritic := 'Erro ao inserir na CRAPCBD: ' ||SQLERRM;
   END;

-- Funcao para verificar se existe reaproveitamento para o CNPJ informado
FUNCTION fn_verifica_reaproveitamento(pr_nrconbir IN  crapcbd.nrconbir%TYPE, -- Sequencial com o numero da consulta no biro 
                                      pr_cdbircon IN  crapcbd.cdbircon%TYPE, -- Codigo do biro de consultas   
                                      pr_cdmodbir IN  crapcbd.cdmodbir%TYPE, -- Codigo da modalidade no biro de consultas   
                                      pr_cdcooper IN  crapcbd.cdcooper%TYPE, -- Codigo da cooperativa 
                                      pr_nrdconta IN  crapcbd.nrdconta%TYPE, -- Numero da conta/dv do associado (zeros no caso do consultado nao possuir conta). 
                                      pr_nrcpfcgc IN  crapcbd.nrcpfcgc%TYPE, -- Numero do cpf/cgc do consultado 
                                      pr_intippes IN  crapcbd.intippes%TYPE, -- Indicador de tipo de pessoa (1-titular, 2-avalista, 3-conjuge, 4-socio, 5-socio e administrador) 
                                      pr_qtdiarpv IN  craprbi.qtdiarpv%TYPE, -- Quantidade de dias de reaproveitamento
                                      pr_cdcritic OUT crapcri.cdcritic%TYPE, --> Critica encontrada
                                      pr_dscritic OUT VARCHAR2)              --> Texto de erro/critica encontrada
                                        RETURN BOOLEAN IS
    -- Cursor para buscar a ordem de importancia do biro que sera consultado
    CURSOR cr_crapmbr IS
      SELECT nrordimp
        FROM crapmbr
       WHERE cdbircon = pr_cdbircon
         AND cdmodbir = pr_cdmodbir;
    rw_crapmbr cr_crapmbr%ROWTYPE;
    
    -- Cursor para verificar se existe consulta com o mesmo CPF
    CURSOR cr_crapcbd(pr_nrordimp crapmbr.nrordimp%TYPE) IS
      SELECT crapcbd.nrconbir,
             crapcbd.nrseqdet,
             crapcbd.cdbircon,
             crapcbd.cdmodbir,
             crapcbd.dtconbir,
             crapcbd.cdcooper,
             crapcbd.nrdconta,
             crapcbd.nrcpfcgc,
             crapcbd.nmtitcon,
             crapcbd.inreapro,
             crapcbd.inreterr,
             crapcbd.dslogret,
             crapcbd.intippes,
             crapcbd.dtentsoc,
             crapcbd.nrcbrsoc,
             crapcbd.nrsdtsoc,
             crapcbd.percapvt,
             crapcbd.pertotal,
             crapcbd.dsvincul,
             crapcbd.dtentadm,
             crapcbd.dtmanadm,
             crapcbd.dsendere,
             crapcbd.nmbairro,
             crapcbd.nrcepend,
             crapcbd.nmcidade,
             crapcbd.cdufende,
             crapcbd.dsprofis,
             crapcbd.dtatuend,
             crapcbd.dtatusoc,
             crapcbd.dtatuadm,
             crapcbd.dtatupar,
             crapcbd.inpessoa,
             crapcbd.qtopescr,
             crapcbd.qtifoper,
             crapcbd.vltotsfn,
             crapcbd.vlopescr,
             crapcbd.vlprejui,
             crapcbd.nrprotoc,
             crapcbd.dtreapro 
        FROM crapmbr,
             crapcbd
       WHERE crapcbd.inreapro = 0 -- Utilizar somente consultas que nao foram reaproveitadas
         AND crapcbd.inreterr = 0 -- Que nao teve erros
         AND crapcbd.nrsdtsoc IS NULL -- Nao pode ser socio, pois as informacoes dos socios vem resumidas
         AND crapcbd.nrcpfcgc = pr_nrcpfcgc
         AND trunc(crapcbd.dtconbir) >= trunc(SYSDATE) - pr_qtdiarpv
         AND crapmbr.cdbircon = crapcbd.cdbircon
         AND crapmbr.cdmodbir = crapcbd.cdmodbir
         AND crapmbr.nrordimp >= pr_nrordimp  -- So reaproveitar se a importancia for maior ou igual ao solicitado
         AND crapmbr.cdbircon = pr_cdbircon -- Somente se for do mesmo biro de consultas
       ORDER BY crapmbr.nrordimp DESC, crapcbd.dtconbir DESC;
    rw_crapcbd cr_crapcbd%ROWTYPE;

    -- Cursor para buscar os dados dos socios do reaproveitamento
    CURSOR cr_crapcbd_soc(pr_nrconbir_soc crapcbd.nrcbrsoc%TYPE,
                          pr_nrseqdet_soc crapcbd.nrsdtsoc%TYPE) IS
      SELECT crapcbd.nrconbir,
             crapcbd.nrseqdet,
             crapcbd.cdbircon,
             crapcbd.cdmodbir,
             crapcbd.dtconbir,
             crapcbd.cdcooper,
             crapcbd.nrdconta,
             crapcbd.nrcpfcgc,
             crapcbd.nmtitcon,
             crapcbd.inreapro,
             crapcbd.inreterr,
             crapcbd.dslogret,
             crapcbd.intippes,
             crapcbd.dtentsoc,
             crapcbd.nrcbrsoc,
             crapcbd.nrsdtsoc,
             crapcbd.percapvt,
             crapcbd.pertotal,
             crapcbd.dsvincul,
             crapcbd.dtentadm,
             crapcbd.dtmanadm,
             crapcbd.dsendere,
             crapcbd.nmbairro,
             crapcbd.nrcepend,
             crapcbd.nmcidade,
             crapcbd.cdufende,
             crapcbd.dsprofis,
             crapcbd.dtatuend,
             crapcbd.dtatusoc,
             crapcbd.dtatuadm,
             crapcbd.dtatupar,
             crapcbd.inpessoa,
             crapcbd.qtopescr,
             crapcbd.qtifoper,
             crapcbd.vltotsfn,
             crapcbd.vlopescr,
             crapcbd.vlprejui,
             crapcbd.nrprotoc,
             crapcbd.dtreapro 
        FROM crapcbd
       WHERE nrconbir = pr_nrconbir_soc
         AND nrcbrsoc = pr_nrconbir_soc
         AND nrsdtsoc = pr_nrseqdet_soc;

    -- Variaveis de erro
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista
  
    -- Variaveis gerais
    vr_nrseqdet     crapcbd.nrseqdet%TYPE; --> Sequencia de detalhe da consulta
    vr_nrseqdet_soc crapcbd.nrseqdet%TYPE; --> Sequencia de detalhe da consulta do socio

  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.fn_verifica_reaproveitamento');  

    -- Busca a ordem de importancia da consulta que sera realizada
    OPEN cr_crapmbr;
    FETCH cr_crapmbr INTO rw_crapmbr;
    CLOSE cr_crapmbr;
    
    -- Busca a ordem de importancia da consulta que sera realizada
    OPEN cr_crapcbd(rw_crapmbr.nrordimp);
    FETCH cr_crapcbd INTO rw_crapcbd;
    
    -- Verifica se existe registro para reaproveitar. Em caso positivo
    -- insere todas as tabelas de consultas.
    IF cr_crapcbd%FOUND THEN
      -- Insere o registro de consulta, com base no registro reaproveitado
      BEGIN
        INSERT INTO crapcbd
          (nrconbir,
           nrseqdet,
           cdbircon,
           cdmodbir,
           dtconbir,
           cdcooper,
           nrdconta,
           nrcpfcgc,
           nmtitcon,
           inreapro,
           inreterr,
           dslogret,
           intippes,
           dtentsoc,
           nrcbrsoc,
           nrsdtsoc,
           percapvt,
           pertotal,
           dsvincul,
           dtentadm,
           dtmanadm,
           dsendere,
           nmbairro,
           nrcepend,
           nmcidade,
           cdufende,
           dsprofis,
           dtatuend,
           dtatusoc,
           dtatuadm,
           dtatupar,
           inpessoa,
           qtopescr,
           qtifoper,
           vltotsfn,
           vlopescr,
           vlprejui,
           nrprotoc,
           dtreapro )
         VALUES
          (pr_nrconbir,  
           (SELECT nvl(MAX(nrseqdet),0)+1 FROM crapcbd WHERE nrconbir = pr_nrconbir),
           rw_crapcbd.cdbircon,
           rw_crapcbd.cdmodbir,
           SYSDATE,
           pr_cdcooper,
           pr_nrdconta,
           pr_nrcpfcgc,
           rw_crapcbd.nmtitcon,
           2, -- Reaproveitado pela propria Cecred
           rw_crapcbd.inreterr,
           rw_crapcbd.dslogret,
           pr_intippes,
           rw_crapcbd.dtentsoc,
           rw_crapcbd.nrcbrsoc,
           rw_crapcbd.nrsdtsoc,
           rw_crapcbd.percapvt,
           rw_crapcbd.pertotal,
           rw_crapcbd.dsvincul,
           rw_crapcbd.dtentadm,
           rw_crapcbd.dtmanadm,
           rw_crapcbd.dsendere,
           rw_crapcbd.nmbairro,
           rw_crapcbd.nrcepend,
           rw_crapcbd.nmcidade,
           rw_crapcbd.cdufende,
           rw_crapcbd.dsprofis,
           rw_crapcbd.dtatuend,
           rw_crapcbd.dtatusoc,
           rw_crapcbd.dtatuadm,
           rw_crapcbd.dtatupar,
           rw_crapcbd.inpessoa,
           rw_crapcbd.qtopescr,
           rw_crapcbd.qtifoper,
           rw_crapcbd.vltotsfn,
           rw_crapcbd.vlopescr,
           rw_crapcbd.vlprejui,
           NULL, -- Nao possui protocolo, pois foi reaproveitado
           trunc(rw_crapcbd.dtconbir))
         RETURNING nrseqdet INTO vr_nrseqdet;
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
          vr_dscritic := 'Erro ao duplicar CRAPCBD: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Duplica o registro de consulta do SPC
      BEGIN
        INSERT INTO craprsc
          (nrconbir,
           nrseqdet,
           nrseqreg,
           dsinstit,
           nmcidade,
           cdufende,
           dtregist,
           dtvencto,
           dsmtvreg,
           vlregist,
           dsentorg,
           inlocnac)
        (SELECT pr_nrconbir,
                vr_nrseqdet,
                nrseqreg,
                dsinstit,
                nmcidade,
                cdufende,
                dtregist,
                dtvencto,
                dsmtvreg,
                vlregist,
                dsentorg,
                inlocnac
           FROM craprsc
          WHERE nrconbir = rw_crapcbd.nrconbir
            AND nrseqdet = rw_crapcbd.nrseqdet);
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
          vr_dscritic := 'Erro ao duplicar CRAPRSC: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Duplica o registro de consulta do Pefin / Refin
      BEGIN
        INSERT INTO crapprf
          (nrconbir,
           nrseqdet,
           nrseqreg,
           inpefref,
           dsinstit,
           dtvencto,
           vlregist,
           dsmtvreg,
           dsnature)
        (SELECT pr_nrconbir,
                vr_nrseqdet,
                nrseqreg,
                inpefref,
                dsinstit,
                dtvencto,
                vlregist,
                dsmtvreg,
                dsnature
           FROM crapprf
          WHERE nrconbir = rw_crapcbd.nrconbir
            AND nrseqdet = rw_crapcbd.nrseqdet);
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
          vr_dscritic := 'Erro ao duplicar CRAPPRF: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
                                
      -- Duplica o registro de consulta de cheque sem fundo
      -- Chamado 363148
      BEGIN
        INSERT INTO crapcsf
          (nrconbir,
           nrseqdet,
           nrseqreg,
           nmbanchq,
           cdagechq,
           cdalinea,
           qtcheque,
           dtultocr,
           dtinclus,
           nrcheque,
           vlcheque,
           nmcidade,
           cdufende,
           idsitchq,
           dsmotivo)
        (SELECT pr_nrconbir,
                vr_nrseqdet,
                nrseqreg,
                nmbanchq,
                cdagechq,
                cdalinea,
                qtcheque,
                dtultocr,
                dtinclus,
                nrcheque,
                vlcheque,
                nmcidade,
                cdufende,
                idsitchq,
                dsmotivo
           FROM crapcsf
          WHERE nrconbir = rw_crapcbd.nrconbir
            AND nrseqdet = rw_crapcbd.nrseqdet);
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
          vr_dscritic := 'Erro ao duplicar CRAPCSF: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Duplica o registro de consulta de protestos
      BEGIN
        INSERT INTO crapprt
          (nrconbir,
           nrseqdet,
           nrseqreg,
           nmlocprt,
           dtprotes,
           vlprotes,
           nmcidade,
           cdufende)
        (SELECT pr_nrconbir,
                vr_nrseqdet,
                nrseqreg,
                nmlocprt,
                dtprotes,
                vlprotes,
                nmcidade,
                cdufende
           FROM crapprt
          WHERE nrconbir = rw_crapcbd.nrconbir
            AND nrseqdet = rw_crapcbd.nrseqdet);
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
          vr_dscritic := 'Erro ao duplicar CRAPPRT: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Duplica o registro de consulta de falencia
      BEGIN
        INSERT INTO craprfc
          (nrconbir,
           nrseqdet,
           nrseqreg,
           dtregist,
           dstipreg,
           dsorgreg,
           nmcidade,
           cdufende)
        (SELECT pr_nrconbir,
                vr_nrseqdet,
                nrseqreg,
                dtregist,
                dstipreg,
                dsorgreg,
                nmcidade,
                cdufende
           FROM craprfc
          WHERE nrconbir = rw_crapcbd.nrconbir
            AND nrseqdet = rw_crapcbd.nrseqdet);
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
          vr_dscritic := 'Erro ao duplicar CRAPRFC: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Duplica o registro de consulta de acoes
      BEGIN
        INSERT INTO crapabr
          (nrconbir,
           nrseqdet,
           nrseqreg,
           dtacajud,
           dsnataca,
           vltotaca,
           nrdistri,
           nrvaraca,
           nmcidade,
           cdufende)
        (SELECT pr_nrconbir,
                vr_nrseqdet,
                nrseqreg,
                dtacajud,
                dsnataca,
                vltotaca,
                nrdistri,
                nrvaraca,
                nmcidade,
                cdufende
           FROM crapabr
          WHERE nrconbir = rw_crapcbd.nrconbir
            AND nrseqdet = rw_crapcbd.nrseqdet);
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
          vr_dscritic := 'Erro ao duplicar CRAPABR: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Duplica o registro de consulta de participacao
      BEGIN
        INSERT INTO crappsa
          (nrconbir,
           nrseqdet,
           nrseqreg,
           nmempres,
           nmcidade,
           cdufende,
           pertotal,
           nrcpfcgc,
           nmvincul)
        (SELECT pr_nrconbir,
                vr_nrseqdet,
                nrseqreg,
                nmempres,
                nmcidade,
                cdufende,
                pertotal,
                nrcpfcgc,
                nmvincul
           FROM crappsa
          WHERE nrconbir = rw_crapcbd.nrconbir
            AND nrseqdet = rw_crapcbd.nrseqdet);
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
          vr_dscritic := 'Erro ao duplicar CRAPPSA: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Duplica o registro de consulta de resumo
      BEGIN
        INSERT INTO craprpf
          (nrconbir,
           nrseqdet,
           innegati,
           qtnegati,
           vlnegati,
           dtultneg)
        (SELECT pr_nrconbir,
                vr_nrseqdet,
                innegati,
                qtnegati,
                vlnegati,
                dtultneg
           FROM craprpf
          WHERE nrconbir = rw_crapcbd.nrconbir
            AND nrseqdet = rw_crapcbd.nrseqdet);
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
          vr_dscritic := 'Erro ao duplicar CRAPRPF: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Efetua loop sobre os socios
      FOR rw_crapcbd_soc IN cr_crapcbd_soc(rw_crapcbd.nrconbir, rw_crapcbd.nrseqdet) LOOP

        -- Insere o registro de consulta, com base no registro reaproveitado do socio
        BEGIN
          INSERT INTO crapcbd
            (nrconbir,
             nrseqdet,
             cdbircon,
             cdmodbir,
             dtconbir,
             cdcooper,
             nrdconta,
             nrcpfcgc,
             nmtitcon,
             inreapro,
             inreterr,
             dslogret,
             intippes,
             dtentsoc,
             nrcbrsoc,
             nrsdtsoc,
             percapvt,
             pertotal,
             dsvincul,
             dtentadm,
             dtmanadm,
             dsendere,
             nmbairro,
             nrcepend,
             nmcidade,
             cdufende,
             dsprofis,
             dtatuend,
             dtatusoc,
             dtatuadm,
             dtatupar,
             inpessoa,
             qtopescr,
             qtifoper,
             vltotsfn,
             vlopescr,
             vlprejui,
             nrprotoc,
             dtreapro )
           VALUES
            (pr_nrconbir,  
            (SELECT nvl(MAX(nrseqdet),0)+1 FROM crapcbd WHERE nrconbir = pr_nrconbir),
             rw_crapcbd_soc.cdbircon,
             rw_crapcbd_soc.cdmodbir,
             SYSDATE,
             pr_cdcooper,
             0, -- Socio nao deve posuir conta
             rw_crapcbd_soc.nrcpfcgc,
             rw_crapcbd_soc.nmtitcon,
             2, -- Reaproveitado pela propria Cecred
             rw_crapcbd_soc.inreterr,
             rw_crapcbd_soc.dslogret,
             rw_crapcbd_soc.intippes,
             rw_crapcbd_soc.dtentsoc,
             pr_nrconbir,
             vr_nrseqdet,
             rw_crapcbd_soc.percapvt,
             rw_crapcbd_soc.pertotal,
             rw_crapcbd_soc.dsvincul,
             rw_crapcbd_soc.dtentadm,
             rw_crapcbd_soc.dtmanadm,
             rw_crapcbd_soc.dsendere,
             rw_crapcbd_soc.nmbairro,
             rw_crapcbd_soc.nrcepend,
             rw_crapcbd_soc.nmcidade,
             rw_crapcbd_soc.cdufende,
             rw_crapcbd_soc.dsprofis,
             rw_crapcbd_soc.dtatuend,
             rw_crapcbd_soc.dtatusoc,
             rw_crapcbd_soc.dtatuadm,
             rw_crapcbd_soc.dtatupar,
             rw_crapcbd_soc.inpessoa,
             rw_crapcbd_soc.qtopescr,
             rw_crapcbd_soc.qtifoper,
             rw_crapcbd_soc.vltotsfn,
             rw_crapcbd_soc.vlopescr,
             rw_crapcbd_soc.vlprejui,
             NULL, -- Nao possui protocolo
             trunc(rw_crapcbd_soc.dtconbir))
           RETURNING nrseqdet INTO vr_nrseqdet_soc;
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
            vr_dscritic := 'Erro ao duplicar CRAPCBD do socio: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Duplica o registro de consulta de participacao dos socios
        BEGIN
          INSERT INTO crappsa
            (nrconbir,
             nrseqdet,
             nrseqreg,
             nmempres,
             nmcidade,
             cdufende,
             pertotal,
             nrcpfcgc,
             nmvincul)
          (SELECT pr_nrconbir,
                  vr_nrseqdet_soc,
                  nrseqreg,
                  nmempres,
                  nmcidade,
                  cdufende,
                  pertotal,
                  nrcpfcgc,
                  nmvincul
             FROM crappsa
            WHERE nrconbir = rw_crapcbd_soc.nrconbir
              AND nrseqdet = rw_crapcbd_soc.nrseqdet);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
            vr_dscritic := 'Erro ao duplicar CRAPPSA do socio: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Duplica o registro de consulta de resumo
        BEGIN
          INSERT INTO craprpf
            (nrconbir,
             nrseqdet,
             innegati,
             qtnegati,
             vlnegati,
             dtultneg)
          (SELECT pr_nrconbir,
                  vr_nrseqdet_soc,
                  innegati,
                  qtnegati,
                  vlnegati,
                  dtultneg
             FROM craprpf
            WHERE nrconbir = rw_crapcbd_soc.nrconbir
              AND nrseqdet = rw_crapcbd_soc.nrseqdet);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
            vr_dscritic := 'Erro ao duplicar CRAPRPF do socio: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        
      END LOOP;


      -- Retorna informando que teve reaproveitamento
      RETURN TRUE;
      
      -- Fecha o cursor de consultas
      CLOSE cr_crapcbd;
    END IF;
    -- Fecha o cursor de consultas
    CLOSE cr_crapcbd;

    -- Retorna informando que nao teve reaproveitamento
    RETURN FALSE;
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Atualiza a variavel de retorno de descricao do erro
      pr_dscritic := vr_dscritic;
      RETURN FALSE;
      
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
      -- Efetuar retorno do erro não tratado
      pr_dscritic := SQLERRM;
      RETURN FALSE;
  END;

-- Insere registro na tabela CRAPRPF (resumo das pendencias financeiras)
PROCEDURE pc_insere_craprpf(pr_nrconbir IN  craprpf.nrconbir%TYPE, --> Sequencial com o numero da consulta no biro 
                            pr_nrseqdet IN  craprpf.nrseqdet%TYPE, --> Sequencial da consulta
                            pr_innegati IN  craprpf.innegati%TYPE, --> Indicador de negativa (1-refin, 2-pefin, 3-protesto, 4-acao judicial, 5-participacao em falencia, 6-cheque sem fundo, 7-cheques sustados e extraviados, 10-dívida vencida, 11-inadimplência) 
                            pr_qtnegati IN  craprpf.qtnegati%TYPE, --> Quantidade de negativas 
                            pr_vlnegati IN  craprpf.vlnegati%TYPE, --> Valor total das negativas 
                            pr_dtultneg IN  craprpf.dtultneg%TYPE, --> Data da ultima negativa 
                            pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_insere_craprpf');  

    INSERT INTO craprpf
      (nrconbir,
       nrseqdet,
       innegati,
       qtnegati,
       vlnegati,
       dtultneg)
     values
      (pr_nrconbir,
       pr_nrseqdet,
       pr_innegati,
       pr_qtnegati,
       pr_vlnegati,
       pr_dtultneg);
   EXCEPTION
    WHEN dup_val_on_index THEN
      NULL; -- Nao faz nada, pois o resumo ja veio do arquivo
     WHEN OTHERS THEN
       -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
       CECRED.pc_internal_exception (pr_cdcooper => NULL);  
       pr_dscritic := 'Erro ao inserir na CRAPRPF: ' ||SQLERRM;
   END;

-- Insere registro na tabela CRAPESC (escore)
PROCEDURE pc_insere_crapesc(pr_nrconbir IN  crapesc.nrconbir%TYPE, --> Sequencial com o numero da consulta no biro 
                            pr_nrseqdet IN  crapesc.nrseqdet%TYPE, --> Sequencial da consulta
                            pr_dsescore IN  crapesc.dsescore%TYPE, --> Descrição do escore
                            pr_vlpontua IN  crapesc.vlpontua%TYPE, --> Pontuação
                            pr_dsclassi IN  crapesc.dsclassi%TYPE, --> Descrição da classificação
                            pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_insere_crapesc');  

    INSERT INTO crapesc
      (nrconbir,
       nrseqdet,
       nrseqesc,
       dsescore,
       vlpontua,
       dsclassi)
     values
      (pr_nrconbir,
       pr_nrseqdet,
       (select nvl(max(nrseqesc),0)+1 from crapesc where nrconbir = pr_nrconbir and nrseqdet = pr_nrseqdet),
       pr_dsescore,
       pr_vlpontua,
       pr_dsclassi);
   EXCEPTION
    WHEN dup_val_on_index THEN
      NULL; -- Nao faz nada, pois o resumo ja veio do arquivo
     WHEN OTHERS THEN
       -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
       CECRED.pc_internal_exception (pr_cdcooper => NULL);  
       pr_dscritic := 'Erro ao inserir na CRAPESC: ' ||SQLERRM;
   END;

-- Insere registro na tabela CRAPESC (escore)
PROCEDURE pc_atualiza_classe_serasa(pr_nrconbir IN  crapesc.nrconbir%TYPE, --> Sequencial com o numero da consulta no biro 
                                    pr_nrseqdet IN  crapesc.nrseqdet%TYPE, --> Sequencial da consulta
                                    pr_dsclaris IN  crapesc.dsescore%TYPE, --> Descrição do escore
                                    pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_atualiza_classe_serasa');  
    UPDATE crapcbd c
     SET c.dsclaris = NVL(pr_dsclaris,' ')
     WHERE c.nrconbir = pr_nrconbir
     AND   c.nrseqdet = pr_nrseqdet;
   EXCEPTION
    WHEN dup_val_on_index THEN
      NULL; -- Nao faz nada, pois o resumo ja veio do arquivo
     WHEN OTHERS THEN
       CECRED.pc_internal_exception (pr_cdcooper => NULL);  
       pr_dscritic := 'Erro ao atualizar classe de risco na CRAPCBD: ' ||SQLERRM;
   END;
PROCEDURE pc_atualiza_inadimplencia(pr_nrconbir IN  crapcbd.nrconbir%TYPE, --> Sequencial com o numero da consulta no biro 
                                    pr_nrseqdet IN  crapcbd.nrseqdet%TYPE, --> Sequencial da consulta
                                    pr_peinadim IN  crapcbd.peinadim%TYPE, --> Probabilidade de Inadimplência
                                    pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_atualiza_inadimplencia');  
    UPDATE crapcbd c
     SET c.peinadim = NVL(pr_peinadim,0)
     WHERE c.nrconbir = pr_nrconbir
     AND   c.nrseqdet = pr_nrseqdet;
   EXCEPTION
    WHEN dup_val_on_index THEN
      NULL; -- Nao faz nada, pois o resumo ja veio do arquivo
     WHEN OTHERS THEN
       CECRED.pc_internal_exception (pr_cdcooper => NULL);  
       pr_dscritic := 'Erro ao atualizar probabilidade de inadimplencia na CRAPCBD: ' ||SQLERRM;
   END;
PROCEDURE pc_busca_escore(pr_nrconbir in  crapesc.nrconbir%type, --> Sequencial com o numero da consulta no biro 
                          pr_nrseqdet in  crapesc.nrseqdet%type, --> Sequencial da consulta
                          pr_nrseqesc in  crapesc.nrseqesc%type, --> Sequencial do escore
                          pr_dsescore out crapesc.dsescore%type, --> Descrição do escore
                          pr_vlpontua out crapesc.vlpontua%type, --> Pontuação
                          pr_dsclassi out crapesc.dsclassi%type, --> Descrição da classificação
                          pr_dscritic out varchar2) is
  cursor cr_crapesc is
    select dsescore,
           vlpontua,
           dsclassi
      from crapesc
     where nrconbir = pr_nrconbir
       and nrseqdet = pr_nrseqdet
       and nrseqesc = pr_nrseqesc;
  begin
    open cr_crapesc;
      fetch cr_crapesc into pr_dsescore, pr_vlpontua, pr_dsclassi;
      if cr_crapesc%notfound then
        pr_dsescore := null;
        pr_vlpontua := null;
        pr_dsclassi := null;
      end if;
    close cr_crapesc;
  exception
    when others then
      pr_dscritic := 'Erro não tratado ao buscar dados de escore: '||sqlerrm;
  end;


PROCEDURE pc_trata_erro_retorno(pr_cdcooper IN crapepr.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                pr_nrdconta IN crapepr.nrdconta%TYPE, --> Numero da conta de emprestimo
                                pr_nrdocmto IN crapepr.nrctremp%TYPE, --> Numero do documento
                                pr_nrprotoc IN crapcbd.nrprotoc%TYPE, --> Numero do protocolo do biro
                                pr_nrconbir IN crapcbd.nrconbir%TYPE, --> Numero da consulta no biro
                                pr_dscritic IN OUT VARCHAR2,
                                pr_tpocorre IN VARCHAR2 DEFAULT 2) IS --> Texto de erro/critica encontrada
    vr_qtconsul crapcbc.qtconsul%TYPE; --> Quantidade de registros consultados
    vr_titulo   varchar2(10);          --> indica se é erro ou alerta
  ---------------------------------------------------------------------------------------------------------------
  --
  --                                                      Última atualização: 06/06/2017
  --
  --              06/06/2017 - Inclusão do parâmetro para indicar o tipo de ocorrência a gravar na tabela
  --                           tbgen_prglog_ocorrencia e padronização da mensagem
  --                           (Ana - Envolti) CH=660433 / 660325
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    --Verifica se é erro ou alerta
    IF pr_tpocorre = '1' THEN
       vr_titulo := 'ALERTA';
    ELSE
       vr_titulo := 'ERRO';
    END IF;
       
    -- Envio centralizado de log de erro
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => pr_tpocorre  
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' - '||'SSPC0001'||' --> '|| 
                                                  vr_titulo||': '|| pr_dscritic||' Nrdconta:'||pr_nrdconta|| 
                                                  ',Nrdocmto:'||pr_nrdocmto||',Nrprotoc:'||pr_nrprotoc|| 
                                                  ',Nrconbir:'||pr_nrconbir
                              ,pr_nmarqlog => 'CONAUT');

    -- Atualiza o numero do protocolo nos detalhes
    BEGIN
      UPDATE crapcbd
         SET nrprotoc = nvl(nrprotoc, pr_nrprotoc),
             inreterr = 1, -- Ocorreu erro no envio
             dslogret = substr(pr_dscritic,1,100)
       WHERE nrconbir = pr_nrconbir;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
        pr_dscritic := 'Erro ao atualizar CRAPCBD: ' ||SQLERRM;
        RETURN;
    END;
    -- Atualza a quantidade de consultas, com base nos updates      
    vr_qtconsul := SQL%ROWCOUNT;

    -- Atualiza a capa da consulta, com a quantidade de erros
    BEGIN
      UPDATE crapcbc
         SET qtconsul = vr_qtconsul,
             qterrcon = vr_qtconsul
       WHERE nrconbir = pr_nrconbir;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
        pr_dscritic := 'Erro ao atualizar CRAPCBD: ' ||SQLERRM;
        RETURN;
    END;
    
  END;

-- Envia a requisicao para o biro de consultas
PROCEDURE pc_envia_requisicao(pr_cdcooper IN  crapepr.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                              pr_nrdconta IN  crapepr.nrdconta%TYPE, --> Numero da conta de emprestimo
                              pr_nrdocmto IN  crapepr.nrctremp%TYPE, --> Numero do documento
                              pr_dsprodut IN  VARCHAR2,              --> Produto que sera enviado
                              pr_envioxml IN OUT NOCOPY XMLType,     --> XML que sera enviado para o biro
                              pr_nrprotoc OUT crapcbd.nrprotoc%TYPE, --> Numero do protocolo gerado
                              pr_cdcritic OUT crapcri.cdcritic%TYPE, --> Critica encontrada
                              pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
    
    -- Busca os dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT nmrescop
        FROM crapcop
       WHERE cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Variaveis de erro
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista

    -- Variaveis gerais
    vr_clob          CLOB;          --> Variavel de comunicacao com o Biro
    vr_dsautori      VARCHAR2(500); --> texto com a cooperativa, usuario e senha de acesso
    l_http_request   UTL_HTTP.req;  --> Request do XML
    l_http_response  UTL_HTTP.resp; --> Resposta do XML
    l_text           VARCHAR2(32000); --> Texto de resposta do Biro
    v_ds_url         VARCHAR2(500); --> URL da Ibratan
    vr_nmdecamp      VARCHAR2(100); --> Campo de retorno do cabecalho
    vr_result        VARCHAR2(100); --> Resultado do campo do cabecalho

  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_envia_requisicao');  
  
    -- Busca a url de comunicacao 
    v_ds_url := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                          pr_cdacesso => 'URL_IBRATAN');
  
    -- Se nao encontrar URL, cancela a rotina
    -- Para testar com o ambiente de homologacao, deve-se utilizar o link abaixo
    -- http://tan_homol:2435/xml/ibracred/cogerplus
    IF v_ds_url IS NULL THEN
      vr_dscritic := 'URL de acesso ao biro nao encontrada. Favor verificar!';
      RAISE vr_exc_saida;
    END IF;
    
    -- Busca o texto de autorizacao
    vr_dsautori := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                            pr_cdcooper =>  pr_cdcooper,
                                            pr_cdacesso => 'AUTORIZACAO_IBRATAN');
                                            
    -- Se nao encontrar conteudo de autorizacao, cancela a rotina
    IF vr_dsautori IS NULL THEN
      vr_dscritic := 'Autorizacao (usuario e senha) de acesso ao biro nao encontrada. Favor verificar!';
      RAISE vr_exc_saida;
    END IF;
        
    -- Busca o nome da cooperativa
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    CLOSE cr_crapcop;

    -- Concatena a cooperativa no usuario e senha 
    vr_dsautori := 'CECRED'||lpad(pr_cdcooper,2,'0')||':'||vr_dsautori;

    -- Transforma o xml em variavel clob, para ser enviada para o Biro
    vr_clob := pr_envioxml.getclobval();

    -- Define o tempo de timeout com o servidor
    UTL_HTTP.set_transfer_timeout(500);

    -- Configura o HTTP request
    BEGIN
      l_http_request  := UTL_HTTP.begin_request(v_ds_url,'POST',utl_http.http_version_1_1);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
        vr_dscritic := 'Nao foi possivel conectar com Ibratan: '||SQLERRM;
        RAISE vr_exc_saida;
    END;

    -- Setar o header padrão do XML
    UTL_HTTP.set_body_charset(l_http_request, 'UTF-8');
    UTL_HTTP.set_header(l_http_request, 'Content-Type', 'text/xml');
    UTL_HTTP.set_header(l_http_request, 'Content-Length', length(vr_clob) );
    
    -- Parametros que deverao ser passados para a Ibratan
    UTL_HTTP.set_header(l_http_request, 'Application-Token', pc_encode_base64('ChaveDeAcessoAoSistemaIbracred'));
    UTL_HTTP.set_header(l_http_request, 'Authorization', 'Ibratan '||pc_encode_base64(vr_dsautori));
    UTL_HTTP.set_header(l_http_request, 'Custom-Template', 'CECRED');
    UTL_HTTP.set_header(l_http_request, 'Proposta', pr_nrdocmto);
    UTL_HTTP.set_header(l_http_request, 'Conta-Credito', pr_nrdconta);
    UTL_HTTP.set_header(l_http_request, 'Produto', pr_dsprodut);

    -- Escreve o conteúdo
    utl_http.write_text(l_http_request, vr_clob );

    -- Response do Web Service
    l_http_response := UTL_HTTP.get_response(l_http_request);

    -- Buscar o numero do protocolo no cabecalho
    FOR i IN 1..UTL_HTTP.GET_HEADER_COUNT(l_http_response) LOOP
      UTL_HTTP.GET_HEADER(l_http_response, i, vr_nmdecamp, vr_result);
      IF vr_nmdecamp = 'Identification'  THEN
        pr_nrprotoc := vr_result;
      END IF;
    END LOOP;
     
    -- Inicializa o CLOB.
    vr_clob := null;
    DBMS_LOB.createtemporary(vr_clob, FALSE);

    -- Copia a resposta para dentro de um CLOB
    BEGIN
      LOOP
        UTL_HTTP.read_text(l_http_response, l_text, 32000);
        DBMS_LOB.writeappend (vr_clob, LENGTH(l_text), l_text);
      END LOOP;
    EXCEPTION
      WHEN UTL_HTTP.end_of_body THEN
        UTL_HTTP.end_response(l_http_response);
      WHEN OTHERS THEN
        NULL;
    END;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Fecha a conexao, caso existir      
      BEGIN
        UTL_HTTP.end_response(l_http_response);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Fecha a conexao, caso existir      
      BEGIN
        UTL_HTTP.end_response(l_http_response);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
  END;                                 
  
-- Quando o nome da cidade vem junto com a UF, deve-se separar para a gravacao
FUNCTION fn_separa_cidade_uf(pr_nmcidade IN VARCHAR2,     --> Nome da cidade com a UF
                             pr_idretorn IN PLS_INTEGER)  --> Indicador de retorno - 1=Municipio, 2=UF
                                         RETURN VARCHAR2 IS
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.fn_separa_cidade_uf');  

    -- Se for para retornar municipio
    IF pr_idretorn = 1 THEN
      -- Se nao possuir quebra por UF, retorna o nome inteiro da UF
      IF nvl(instr(pr_nmcidade,'/'),0) = 0 THEN
        RETURN pr_nmcidade;
      ELSIF trim(pr_nmcidade) = '/' THEN
        RETURN NULL;
      ELSE -- Se possuir quebra, deve-se retornar somente o municipio
        RETURN substr(pr_nmcidade,1,instr(pr_nmcidade,'/')-1);
      END IF;
    ELSE  -- Se for para retornar a UF
      -- Se nao possuir quebra por UF, retorna vazaio
      IF nvl(instr(pr_nmcidade,'/'),0) = 0 THEN
        RETURN NULL;
      ELSIF trim(pr_nmcidade) = '/' THEN
        RETURN NULL;
      ELSE -- Se possuir quebra, deve-se retornar somente a uf
        RETURN substr(pr_nmcidade,instr(pr_nmcidade,'/')+1);
      END IF;
    END IF;
  END;

-- Envia a requisicao para o biro de consultas
PROCEDURE pc_solicita_retorno_req(pr_cdcooper IN crapcop.cdcooper%TYPE,  --> Código da cooperativa
                                  pr_nrprotoc IN VARCHAR2,  --> Numero do protocolo gerado
                                  pr_retxml   IN OUT NOCOPY XMLType,     --> XML de retorno da operadora
                                  pr_cdcritic OUT crapcri.cdcritic%TYPE, --> Critica encontrada
                                  pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

    -- Variaveis de comunicacao
    l_http_request   UTL_HTTP.req;  --> Request do XML
    l_http_response  UTL_HTTP.resp; --> Resposta do XML
    l_text           VARCHAR2(32000); --> Texto de resposta do Biro
    v_ds_url         VARCHAR2(500); --> URL da Ibratan
    vr_ds_xml        CLOB;
    
    -- Variaveis gerais
    vr_qttmpret NUMBER;  --> Tempo maximo possivel para retorno da operadora
    vr_dtinicio DATE;         --> Data/hora do inicio do processo
    vr_nmdirarq VARCHAR2(200);--> Diretorio de gravacao dos arquivos XML
    vr_cdstatus PLS_INTEGER;  --> Status de retorno da consulta no Biro

    -- Variaveis de erro
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_solicita_retorno_req');  
    
    -- Busca o diretorio onde sera gravado o XML
    vr_nmdirarq := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                         pr_cdcooper => pr_cdcooper,
                                         pr_nmsubdir => 'salvar');  
  
    -- Montar URL consulta
    v_ds_url := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                            pr_cdacesso => 'URL_IBRATAN');
    -- Grava a data de inicio do processo
    vr_dtinicio := SYSDATE;
    
    -- busca o tempo maximo de aguardo de retorno
    vr_qttmpret := gene0001.fn_param_sistema('CRED', pr_cdcooper, 'CONAUT_RESPOSTA');
    
    -- Converte o tempo para segundos no oracle. (24=horas, 60=minutos, 60=segundos)
    vr_qttmpret := nvl(vr_qttmpret,60) / 24 / 60 / 60; 

    LOOP
      -- Aguarda 1 segundo para fazer nova solicitacao de resposta           
      sys.dbms_lock.sleep(1);
      
      -- Define o tempo de timeout do biro
      UTL_HTTP.set_transfer_timeout(500);

			-- Configura o HTTP request
      l_http_request  := UTL_HTTP.begin_request(v_ds_url||'/'||pr_nrprotoc
		                                           ,'GET'
				  																		 ,utl_http.http_version_1_1);
      -- Atualiza o cabecalho da requisicao
      UTL_HTTP.set_header(l_http_request
                         ,'Application-Token'
                         ,pc_encode_base64('ChaveDeAcessoAoSistemaIbracred'));

      -- Escreve o conteúdo
      utl_http.write_text(l_http_request, NULL );

      -- Response do Web Service
      l_http_response := UTL_HTTP.get_response(l_http_request);

      -- Colocado o codigo abaixo somente para teste e verificar o que vem no cabecalho
      --FOR i IN 1..UTL_HTTP.GET_HEADER_COUNT(l_http_response) LOOP
      --  UTL_HTTP.GET_HEADER(l_http_response, i, vr_nmdecamp, vr_result);
      --END LOOP;
      
      -- Busca o status da consulta no Biro
      vr_cdstatus := l_http_response.status_code;
      dbms_output.put_line(vr_cdstatus);

      -- Se retornar o codigo 200, eh que o processo foi concluido. Deve-se Buscar o XML
      IF vr_cdstatus = 200 THEN 
        -- Inicializa o CLOB.
        vr_ds_xml := null;
        DBMS_LOB.createtemporary(vr_ds_xml, FALSE);

        -- Copia a resposta para dentro da variavel CLOB
        BEGIN
          LOOP
            UTL_HTTP.read_text(l_http_response, l_text, 32000);
            DBMS_LOB.writeappend (vr_ds_xml, LENGTH(l_text), l_text);
          END LOOP;
        EXCEPTION
          WHEN UTL_HTTP.end_of_body THEN
            -- Encerra a conexao
            UTL_HTTP.end_response(l_http_response);
          WHEN OTHERS THEN
            NULL;
        END;
      ELSE
        -- Fecha a conexao, caso existir      
        BEGIN
          UTL_HTTP.end_response(l_http_response);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END IF;

      -- Se o codigo de retorno for 200, eh que o retorno foi um sucesso
      EXIT WHEN vr_cdstatus NOT IN (204, 429); -- 204=Em Processamento e 429=Excesso de requisicao

      -- Se ultrapassou o tempo maximo de retorno
      IF SYSDATE > vr_dtinicio + vr_qttmpret THEN
        vr_dscritic := 'Sistema indisponivel. Consultas nao efetuadas. Tente novamente mais tarde!';
        RAISE vr_exc_saida;
      END IF;
    END LOOP;
    
    -- Se o codigo de retorno for diferente de 200, deu erro no processo
    IF vr_cdstatus <> 200 THEN 
      vr_dscritic := 'Atencao! Codigo de retorno do Biro nao previsto. Cod='||vr_cdstatus;
      RAISE vr_exc_saida;
    END IF;
    
    -- Atualizar a variavel de retorno com a resposta do Biro
    BEGIN
      pr_retxml := xmltype(vr_ds_xml);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
        gene0002.pc_clob_para_arquivo(pr_clob => vr_ds_xml, 
                                      pr_caminho => vr_nmdirarq, 
                                      pr_arquivo => 'erro_xml'||to_char(sysdate,'HH24MISS')||'.xml', 
                                      pr_des_erro => vr_dscritic);

        vr_dscritic := 'XML retornado nao eh um XML valido!';
        RAISE vr_exc_saida;
    END;

    -- Verificar se deve salvar a requisição em arquivo
    IF NVL(gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                     pr_cdacesso => 'FL_SALVAR_ARQ_RET_BIRO'),'N') = 'S' THEN

      -- Grava o xml de retorno no diretorio SALVAR da cooperativa
      gene0002.pc_XML_para_arquivo(pr_XML => pr_retxml,
                                   pr_caminho => vr_nmdirarq,
                                   pr_arquivo => to_char(pr_nrprotoc)||'.xml',
                                   pr_des_erro => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

    END IF;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;                                 

-- Rotina para buscar o conteudo do campo com base no xml enviado
PROCEDURE pc_busca_conteudo_campo(pr_retxml    IN OUT NOCOPY XMLType,    --> XML de retorno da operadora
                                  pr_nrcampo   IN VARCHAR2,              --> Campo a ser buscado no XML
                                  pr_indcampo  IN VARCHAR2,              --> Tipo de dado: S=String, D=Data, N=Numerico
                                  pr_retorno  OUT VARCHAR2,              --> Retorno do campo do xml
                                  pr_dscritic IN OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
                                  
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista
    vr_tab_xml   gene0007.typ_tab_tagxml; --> PL Table para armazenar conteúdo XML
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_busca_conteudo_campo');  

    -- Busca a informacao no XML
    gene0007.pc_itera_nodos(pr_xpath      => pr_nrcampo
                           ,pr_xml        => pr_retxml
                           ,pr_list_nodos => vr_tab_xml
                           ,pr_des_erro   => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
    -- Se encontrou mais de um registro, deve dar mensagem de erro
    IF  vr_tab_xml.count > 1 THEN
      vr_dscritic := 'Mais de um registro XML encontrado.';
      RAISE vr_exc_saida;
    ELSIF vr_tab_xml.count = 1 THEN -- Se encontrou, retornar o texto
      IF pr_indcampo = 'D' THEN -- Se o tipo de dado for Data, transformar para data
        -- Se for tudo zeros, desconsiderar
        IF vr_tab_xml(0).tag IN ('00000000','0','')  THEN
          pr_retorno := NULL;
        ELSE
          pr_retorno := to_date(vr_tab_xml(0).tag,'yyyymmdd');
        END IF;
      ELSE
        pr_retorno := replace(vr_tab_xml(0).tag,'.',',');
      END IF;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_dscritic := 'Erro ao buscar campo '||pr_nrcampo||'. '||vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => NULL);  
      pr_dscritic := 'Erro ao buscar campo '||pr_nrcampo||'. '||SQLERRM;
  END;
  
-- Processa o retorno da requisicao
PROCEDURE pc_processa_retorno_req(pr_cdcooper IN NUMBER,                 --> Cód. da cooperativa
	                                pr_nrconbir IN crapcbd.nrconbir%TYPE,  --> Numero da consulta que foi realizada
                                  pr_nrprotoc IN crapcbd.nrprotoc%TYPE,  --> Numero do protocolo gerado
                                  pr_nrdconta IN crapepr.nrdconta%TYPE,  --> Numero da conta do documento
                                  pr_nrdocmto IN crapepr.nrctremp%TYPE,  --> Numero do documento a ser consultado
                                  pr_inprodut IN PLS_INTEGER,            --> Indicador de produto (1-Emprestimos, 2-Financiamentos, 3-Contrato limite cheque especial, 4-Contrato limite desconto de cheque, 5-Contrato Limite Desconto de Titulos)
	                                pr_tpconaut IN VARCHAR2,               --> Tipo de consulta automatizada ('A' - Ayllos / 'M' -  Motor)
																	pr_inconscr IN OUT NUMBER,						 --> Data da última consulta ao SCR
                                  pr_retxml   IN OUT NOCOPY XMLType,     --> XML de retorno da operadora
                                  pr_cdcritic OUT crapcri.cdcritic%TYPE, --> Critica encontrada
                                  pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

    -- Cursor para buscar o biro e o modulo de consulta do biro
    CURSOR cr_crapbir(pr_nmtagbir crapbir.nmtagbir%TYPE,
                      pr_nmtagmod crapmbr.nmtagmod%TYPE) IS
      SELECT crapbir.cdbircon,
             crapmbr.cdmodbir
        FROM crapmbr,
             crapbir
       WHERE crapbir.nmtagbir = pr_nmtagbir
         AND crapmbr.cdbircon = crapbir.cdbircon
         AND crapmbr.nmtagmod = pr_nmtagmod;
    rw_crapbir cr_crapbir%ROWTYPE;

    -- Cursor para buscar o socio de uma empresa participante
    CURSOR cr_crapcbd_soc(pr_nrseqdet crapcbd.nrsdtsoc%TYPE,
                          pr_nrcpfcgc crapcbd.nrcpfcgc%TYPE,
                          pr_cdbircon crapcbd.cdbircon%TYPE,
                          pr_cdmodbir crapcbd.cdmodbir%TYPE) IS
      SELECT nrseqdet
        FROM crapcbd
       WHERE nrconbir = pr_nrconbir
         AND nrcbrsoc = pr_nrconbir
         AND nrsdtsoc = pr_nrseqdet
         AND nrcpfcgc = pr_nrcpfcgc
         AND cdbircon = pr_cdbircon
         AND cdmodbir = pr_cdmodbir
         AND intippes IN (4,5); -- Socio ou socio administrador
    rw_crapcbd_soc cr_crapcbd_soc%ROWTYPE;
		
		-- Cursor para verificar se houve consulta SCR
		CURSOR cr_conscr(pr_nmtagbir IN crapbir.nmtagbir%TYPE
		                ,pr_nmtagmod IN crapmbr.nmtagmod%TYPE)IS
		  SELECT 1
        FROM crapbir, 
             crapmbr
       WHERE crapmbr.nrordimp = 0 -- Consulta do SCR
         AND crapbir.cdbircon = crapmbr.cdbircon
         AND crapbir.nmtagbir = pr_nmtagbir
         AND crapmbr.nmtagmod = pr_nmtagmod;
		rw_conscr cr_conscr%ROWTYPE;

    -- Variaveis de erro
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista
    vr_erro       VARCHAR2(4000); --> Erro oriundo do XML
    
    -- Crias as variaveis com a mesma estrutura que as tabelas
    vr_crapcbd crapcbd%ROWTYPE;  --> Tabela de detalhes da consulta
    vr_craprsc craprsc%ROWTYPE;  --> Registro de consulta do SPC Nacional e Local
    vr_crapprf crapprf%ROWTYPE;  --> Consulta do Pefin e do Refin no SPC e no Serasa
    vr_crapcsf crapcsf%ROWTYPE;  --> Consulta de cheques sem fundos, sinistrados ou extraviados no biro
    vr_crapprt crapprt%ROWTYPE;  --> Consulta de protestos
    vr_crappsa crappsa%ROWTYPE;  --> Consulta de empresas participantes
    vr_crapabr crapabr%ROWTYPE;  --> Consulta de acoes no biro de consultas
    vr_craprfc craprfc%ROWTYPE;  --> Consulta de recuperacoes, falencias e concordatas
    vr_craprpf craprpf%ROWTYPE;  --> Consulta de pendencia financeira dos socios
    vr_crapesc crapesc%ROWTYPE;  --> Consulta de escore
    vr_dsclaris VARCHAR2(100);    --> Classe de risco do Serasa
    
    -- Variaveis gerais
    vr_contador PLS_INTEGER;     --> Variavel contador de solicitacoes
    vr_contador_rsc PLS_INTEGER; --> Contador de registros no SPC
    vr_contador_prf PLS_INTEGER; --> Contador de registros do PEFIN e REFIN
    vr_contador_csf PLS_INTEGER; --> Contador de cheques sem fundos
    vr_contador_prt PLS_INTEGER; --> Contador de registros de protesto
    vr_contador_abr PLS_INTEGER; --> Contador de registros de acoes
    vr_contador_rfc PLS_INTEGER; --> Contador de registros de falencia
    vr_contador_soc PLS_INTEGER; --> Contador de registros de socios
    vr_contador_adm PLS_INTEGER; --> Contador de registros de administradores
    vr_contador_psa PLS_INTEGER; --> Contador de registros de empresa participante
    vr_contador_rpf PLS_INTEGER; --> Contador de registros de pendencias financeiras
    vr_contador_esc PLS_INTEGER; --> Contador de registros de escore
    
    vr_nmtagger VARCHAR2(100);   --> Nome da tag do biro completa
    vr_nmtagbir crapbir.nmtagbir%TYPE; --> Nome da tag do biro de consultas
    vr_nmtagmod crapmbr.nmtagmod%TYPE; --> Nome da tag da modalidade do biro
    vr_nmtagaux VARCHAR2(200);         --> Tag auxiliar para busca das informacoes
    vr_nmtagau2 VARCHAR2(200);         --> Tag auxiliar para busca das informacoes    
    vr_flgrechq BOOLEAN;               --> Flag para indicar se eh consulta Recheque    
    vr_nrseqdet crapcbd.nrseqdet%TYPE; --> Numero da sequencia de consulta
    vr_database VARCHAR2(06);          --> Data base para as consultas SCR, no formato AAAAMM
    vr_dsclasse VARCHAR2(100);         --> Classe da consulta
    vr_inlocnac craprsc.inlocnac%TYPE; --> Indicador de SPC local ou nacional
    vr_insitchq PLS_INTEGER;           --> Tipo de chque (1-Estadual, 2-Nacional, 3-Serasa)
    vr_inpefref crapprf.inpefref%TYPE; --> Indicador de 1-Pefin ou 2-Refin
    vr_dtatusoc crapcbd.dtatusoc%TYPE; --> Data de atualizacao do socio
    vr_dtatuadm crapcbd.dtatuadm%TYPE; --> Data de atualizacao do administrador
    vr_cdcooper crapcbd.cdcooper%TYPE; --> Codigo da cooperativa
    vr_nrcpfcgc_psa crapcbd.nrcpfcgc%TYPE; --> CPF do socio da empresa participante
    vr_nrcpfcgc_rpf crapcbd.nrcpfcgc%TYPE; --> CPF do socio da empresa com pendencia financeira
    vr_vltotsfn crapcbd.vltotsfn%TYPE; --> Valor total de endividamento
    vr_dsvincul VARCHAR2(100);         --> Descricao do vinculo do socio, mas com tamanho maior, utilizado como temporario
    vr_inpessoa crapcbd.inpessoa%TYPE; --> Indicador de pessoa fisica ou juridica
    vr_dsobserv VARCHAR2(100);         --> Observacao existente na tag de reaproveitamento
    vr_dsmsgobs VARCHAR2(500);         --> Mensagem da observacao existente na tag de reaproveitamento
    vr_txalinea VARCHAR2(30);          --> Receber a alinea como texto para tratamento do campo dsmotivo
    vr_nrdconta NUMBER;                --> Receber a conta da pessoa relacionada
		vr_intippes NUMBER;                --> Receber o enquadramento do tipo de pessoa na proposta
    vr_tpctrato crapavt.tpctrato%TYPE;
    --
    PROCEDURE PC_INCLUI_MODALIDADE_BIRO (pr_retxml    IN XMLTYPE
                                        ,pr_nrconbir  IN crapcbd.nrconbir%TYPE
                                        ,pr_nrseqdet  IN crapcbd.nrseqdet%TYPE
                                        ,pr_nrcpfcgc  IN crapass.nrcpfcgc%TYPE
                                        ,pr_dscritic OUT VARCHAR2
                                        ) IS
    -- PRJ 438 - Marcelo Telles Coelho - Mouts
    -- Buscar bloco que contenha a tag <MODALIDADE>
    -- e gravar na tabela TBGEN_MODALIDADE_BIRO
      TYPE typ_reg_tags IS RECORD(
        nmtag      VARCHAR2(100),
        nrloop     NUMBER);
      TYPE typ_tab_tags IS TABLE OF typ_reg_tags INDEX BY PLS_INTEGER;
      vr_tab_tags typ_tab_tags;
      vr_indice_tag NUMBER;
      --
      TYPE typ_reg_modalidade IS RECORD(
        dsendereco varchar2(1000));
      TYPE typ_tab_modalidade IS TABLE OF typ_reg_modalidade INDEX BY PLS_INTEGER;
      vr_tab_modalidade typ_tab_modalidade;
      --
      TYPE typ_reg_bloco IS RECORD(
        dsbloco      VARCHAR2(1000),
        cdmodalidade NUMBER);
      TYPE typ_tab_bloco IS TABLE OF typ_reg_bloco INDEX BY PLS_INTEGER;
      vr_tab_bloco typ_tab_bloco;
      -- Variaveis
      vr_clob         CLOB;
      vr_nrnodo       NUMBER;
      vr_nrseqdet     NUMBER;
      vr_dsendereco   VARCHAR2(1000);
      vr_cdmodalidade NUMBER;
      vr_nrdocumento  NUMBER;
      -- Documento
      vr_xmltype xmlType;
      vr_parser  xmlparser.Parser;
      vr_doc     xmldom.DOMDocument;
      -- Root
      vr_node_root xmldom.DOMNodeList;
      vr_item_root xmldom.DOMNode;
      vr_elem_root xmldom.DOMElement;
      -- SubItens
      vr_node_list_1 xmldom.DOMNodeList;
      vr_node_name_1 VARCHAR2(100);
      vr_item_node_1 xmldom.DOMNode;
      vr_elem_node_1 xmldom.DOMElement;
      vr_node_list_2 xmldom.DOMNodeList;
      vr_node_name_2 VARCHAR2(100);
      vr_item_node_2 xmldom.DOMNode;
      vr_elem_node_2 xmldom.DOMElement;
      vr_node_list_3 xmldom.DOMNodeList;
      vr_node_name_3 VARCHAR2(100);
      vr_item_node_3 xmldom.DOMNode;
      vr_elem_node_3 xmldom.DOMElement;
      vr_valu_node_3 xmldom.DOMNode;
      vr_node_list_4 xmldom.DOMNodeList;
      vr_node_name_4 VARCHAR2(100);
      vr_item_node_4 xmldom.DOMNode;
      vr_elem_node_4 xmldom.DOMElement;
      vr_valu_node_4 xmldom.DOMNode;
      vr_node_list_5 xmldom.DOMNodeList;
      vr_node_name_5 VARCHAR2(100);
      vr_item_node_5 xmldom.DOMNode;
      vr_elem_node_5 xmldom.DOMElement;
      vr_valu_node_5 xmldom.DOMNode;
      vr_node_list_6 xmldom.DOMNodeList;
      vr_node_name_6 VARCHAR2(100);
      vr_item_node_6 xmldom.DOMNode;
      vr_elem_node_6 xmldom.DOMElement;
      vr_valu_node_6 xmldom.DOMNode;
      -- Rotina para substituir caracteres
      FUNCTION fn_getValue(pr_conteudo IN xmldom.DOMNode)RETURN VARCHAR2 IS
  BEGIN
        RETURN gene0007.fn_caract_controle(xmldom.getNodeValue(pr_conteudo));
      END fn_getValue;
      --
    BEGIN
      vr_tab_tags.DELETE;
      vr_tab_modalidade.DELETE;
      vr_tab_bloco.DELETE;
      vr_indice_tag := 1;
      vr_nrnodo     := 0;
      vr_dsendereco := '//LISTA_RESPOSTAS';
      pr_dscritic   := NULL;
      vr_tab_tags(vr_indice_tag).nmtag := 'LISTA_RESPOSTAS';
      vr_tab_tags(vr_indice_tag).nrloop := 0;

      -- Faz o parse do XMLTYPE para o XMLDOM e libera o parser ao fim
      vr_parser := xmlparser.newParser;
      xmlparser.parseClob(vr_parser, pr_retxml.getClobVal());
      vr_doc    := xmlparser.getDocument(vr_parser);
      xmlparser.freeParser(vr_parser);

      -- Buscar nodo LISTA_RESPOSTAS
      vr_node_root := xmldom.getElementsByTagName(vr_doc, 'LISTA_RESPOSTAS');
      vr_item_root := xmldom.item(vr_node_root, 0);
      vr_elem_root := xmldom.makeElement(vr_item_root);

      -- Faz o get de toda a lista SISMSG
      vr_node_list_1 := xmldom.getChildrenByTagName(vr_elem_root, '*');

      -- Percorrer os elementos
      FOR i IN 0 .. xmldom.getLength(vr_node_list_1) - 1 LOOP
        -- Buscar o item atual
        vr_item_node_1 := xmldom.item(vr_node_list_1, i);
        -- Captura o nome e tipo do nodo
        vr_node_name_1 := xmldom.getNodeName(vr_item_node_1);
        -- Sair se o nodo não for elemento
        IF xmldom.getNodeType(vr_item_node_1) <> xmldom.ELEMENT_NODE THEN
          CONTINUE;
        END IF;
      
        IF vr_node_name_1 <> vr_tab_tags(vr_indice_tag).nmtag THEN
          vr_indice_tag := vr_indice_tag + 1;
          vr_tab_tags(vr_indice_tag).nmtag := vr_node_name_1;
          vr_tab_tags(vr_indice_tag).nrloop := 1;
          vr_nrnodo := vr_nrnodo + 1;
          vr_tab_modalidade(vr_tab_tags(vr_indice_tag).nrloop).dsendereco := vr_tab_tags(vr_indice_tag).nmtag||'['||vr_nrnodo||']';
        END IF;
        --===============================================
        -- Buscar todos os filhos deste nó
        vr_elem_node_2 := xmldom.makeElement(vr_item_node_1);
        -- Faz o get de toda a lista de folhas da SEGCAB
        vr_node_list_2 := xmldom.getChildrenByTagName(vr_elem_node_2, '*');
        -- Percorrer os elementos
        FOR i IN 0 .. xmldom.getLength(vr_node_list_2) - 1 LOOP
          -- Buscar o item atual
          vr_item_node_2 := xmldom.item(vr_node_list_2, i);
          -- Captura o nome e tipo do nodo
          vr_node_name_2 := xmldom.getNodeName(vr_item_node_2);
          -- Sair se o nodo não for elemento
          IF xmldom.getNodeType(vr_item_node_2) <> xmldom.ELEMENT_NODE THEN
            CONTINUE;
          END IF;
          IF vr_node_name_2 <> vr_tab_tags(vr_indice_tag).nmtag THEN
            vr_indice_tag := vr_indice_tag + 1;
            vr_tab_tags(vr_indice_tag).nmtag := vr_node_name_2;
            vr_tab_tags(vr_indice_tag).nrloop := 2;
            vr_tab_modalidade(vr_tab_tags(vr_indice_tag).nrloop).dsendereco := vr_tab_tags(vr_indice_tag).nmtag;
          END IF;
          --====================================================================
          -- Buscar todos os filhos deste nó
          vr_elem_node_3 := xmldom.makeElement(vr_item_node_2);
          -- Faz o get de toda a lista de filhos
          vr_node_list_3 := xmldom.getChildrenByTagName(vr_elem_node_3, '*');
          -- Percorrer os elementos
          FOR i IN 0 .. xmldom.getLength(vr_node_list_3) - 1 LOOP
            -- Buscar o item atual
            vr_item_node_3 := xmldom.item(vr_node_list_3, i);
            -- Captura o nome e tipo do nodo
            vr_node_name_3 := xmldom.getNodeName(vr_item_node_3);
            -- Sair se o nodo não for elemento
            IF xmldom.getNodeType(vr_item_node_3) <> xmldom.ELEMENT_NODE THEN
              CONTINUE;
            END IF;
            IF vr_node_name_3 <> vr_tab_tags(vr_indice_tag).nmtag THEN
              vr_indice_tag := vr_indice_tag + 1;
              vr_tab_tags(vr_indice_tag).nmtag := vr_node_name_3;
              vr_tab_tags(vr_indice_tag).nrloop := 3;
              vr_tab_modalidade(vr_tab_tags(vr_indice_tag).nrloop).dsendereco := vr_tab_tags(vr_indice_tag).nmtag;
              --
              IF vr_node_name_3 = 'DOCUMENTO' THEN
                -- Buscar valor da TAG
                vr_valu_node_3 := xmldom.getFirstChild(vr_item_node_3);
                vr_nrdocumento := fn_getValue(vr_valu_node_3);
              END IF;
            END IF;
            --====================================================================
            -- Buscar todos os filhos deste nó
            vr_elem_node_4 := xmldom.makeElement(vr_item_node_3);
            -- Faz o get de toda a lista de filhos
            vr_node_list_4 := xmldom.getChildrenByTagName(vr_elem_node_4, '*');
            -- Percorrer os elementos
            FOR i IN 0 .. xmldom.getLength(vr_node_list_4) - 1 LOOP
              -- Buscar o item atual
              vr_item_node_4 := xmldom.item(vr_node_list_4, i);
              -- Captura o nome e tipo do nodo
              vr_node_name_4 := xmldom.getNodeName(vr_item_node_4);
              -- Sair se o nodo não for elemento
              IF xmldom.getNodeType(vr_item_node_4) <> xmldom.ELEMENT_NODE THEN
                CONTINUE;
              END IF;
              IF vr_node_name_4 <> vr_tab_tags(vr_indice_tag).nmtag THEN
                vr_indice_tag := vr_indice_tag + 1;
                vr_tab_tags(vr_indice_tag).nmtag := vr_node_name_4;
                vr_tab_tags(vr_indice_tag).nrloop := 4;
                vr_tab_modalidade(vr_tab_tags(vr_indice_tag).nrloop).dsendereco := vr_tab_tags(vr_indice_tag).nmtag;
                --
                IF vr_node_name_4 = 'DOCUMENTO' THEN
                  -- Buscar valor da TAG
                  vr_valu_node_4 := xmldom.getFirstChild(vr_item_node_4);
                  vr_nrdocumento := fn_getValue(vr_valu_node_4);
                END IF;
                --
                IF NVL(vr_nrdocumento,0) = pr_nrcpfcgc
                AND vr_node_name_4 = 'MODALIDADE' THEN
                  BEGIN
                  -- Buscar valor da TAG
                  vr_valu_node_4  := xmldom.getFirstChild(vr_item_node_4);
                  vr_cdmodalidade := fn_getValue(vr_valu_node_4);
                  --
                  FOR i IN 1 .. vr_tab_modalidade.COUNT() - 1 LOOP
                    vr_dsendereco := vr_dsendereco || '/' || vr_tab_modalidade(i).dsendereco;
                  END LOOP;
                  --
                  vr_tab_bloco(vr_tab_bloco.count()+1).dsbloco    := vr_dsendereco;
                  vr_tab_bloco(vr_tab_bloco.count()).cdmodalidade := vr_cdmodalidade;
                  vr_dsendereco := '//LISTA_RESPOSTAS';
                  EXCEPTION
                    WHEN OTHERS THEN
                      NULL;
                  END;
                  
                END IF;
              END IF;
              --====================================================================
              -- Buscar todos os filhos deste nó
              vr_elem_node_5 := xmldom.makeElement(vr_item_node_4);
              -- Faz o get de toda a lista de filhos
              vr_node_list_5 := xmldom.getChildrenByTagName(vr_elem_node_5, '*');
              -- Percorrer os elementos
              FOR i IN 0 .. xmldom.getLength(vr_node_list_5) - 1 LOOP
                -- Buscar o item atual
                vr_item_node_5 := xmldom.item(vr_node_list_5, i);
                -- Captura o nome e tipo do nodo
                vr_node_name_5 := xmldom.getNodeName(vr_item_node_5);
                -- Sair se o nodo não for elemento
                IF xmldom.getNodeType(vr_item_node_5) <> xmldom.ELEMENT_NODE THEN
                  CONTINUE;
                END IF;
                IF vr_node_name_5 <> vr_tab_tags(vr_indice_tag).nmtag THEN
                  vr_indice_tag := vr_indice_tag + 1;
                  vr_tab_tags(vr_indice_tag).nmtag := vr_node_name_5;
                  vr_tab_tags(vr_indice_tag).nrloop := 5;
                  vr_tab_modalidade(vr_tab_tags(vr_indice_tag).nrloop).dsendereco := vr_tab_tags(vr_indice_tag).nmtag;
                  --
                  IF vr_node_name_5 = 'DOCUMENTO' THEN
                    -- Buscar valor da TAG
                    vr_valu_node_5 := xmldom.getFirstChild(vr_item_node_5);
                    vr_nrdocumento := fn_getValue(vr_valu_node_5);
                  END IF;
                  --
                  IF NVL(vr_nrdocumento,0) = pr_nrcpfcgc
                  AND vr_node_name_5 = 'MODALIDADE' THEN
                    BEGIN
                    -- Buscar valor da TAG
                    vr_valu_node_5  := xmldom.getFirstChild(vr_item_node_5);
                    vr_cdmodalidade := fn_getValue(vr_valu_node_5);
                    --
                    FOR i IN 1 .. vr_tab_modalidade.COUNT() - 1 LOOP
                      vr_dsendereco := vr_dsendereco || '/' || vr_tab_modalidade(i).dsendereco;
                    END LOOP;
                    --
                    vr_tab_bloco(vr_tab_bloco.count()+1).dsbloco    := vr_dsendereco;
                    vr_tab_bloco(vr_tab_bloco.count()).cdmodalidade := vr_cdmodalidade;
                    vr_dsendereco := '//LISTA_RESPOSTAS';
                    EXCEPTION
                      WHEN OTHERS THEN
                        NULL;
                    END;                    
                  END IF;
                END IF;
                --====================================================================
                -- Buscar todos os filhos deste nó
                vr_elem_node_6 := xmldom.makeElement(vr_item_node_5);
                -- Faz o get de toda a lista de filhos do nó passado
                vr_node_list_6 := xmldom.getChildrenByTagName(vr_elem_node_6,
                                                              '*');
                -- Percorrer os elementos
                FOR i IN 0 .. xmldom.getLength(vr_node_list_6) - 1 LOOP
                  -- Buscar o item atual
                  vr_item_node_6 := xmldom.item(vr_node_list_6, i);
                  -- Captura o nome e tipo do nodo
                  vr_node_name_6 := xmldom.getNodeName(vr_item_node_6);
                  IF vr_node_name_6 <> vr_tab_tags(vr_indice_tag).nmtag THEN
                    vr_indice_tag := vr_indice_tag + 1;
                    vr_tab_tags(vr_indice_tag).nmtag := vr_node_name_6;
                    vr_tab_tags(vr_indice_tag).nrloop := 6;
                    --
                    IF vr_node_name_6 = 'DOCUMENTO' THEN
                      -- Buscar valor da TAG
                      vr_valu_node_6  := xmldom.getFirstChild(vr_item_node_6);
                      vr_nrdocumento := fn_getValue(vr_valu_node_6);
                    END IF;
                    --
                    IF NVL(vr_nrdocumento,0) = pr_nrcpfcgc
                    AND vr_node_name_6 = 'MODALIDADE' THEN
                      BEGIN
                      -- Buscar valor da TAG
                      vr_valu_node_6  := xmldom.getFirstChild(vr_item_node_6);
                      vr_cdmodalidade := fn_getValue(vr_valu_node_6);
                      --
                      FOR i IN 1 .. vr_tab_modalidade.COUNT() - 1 LOOP
                        vr_dsendereco := vr_dsendereco || '/' || vr_tab_modalidade(i).dsendereco;
                      END LOOP;
                      --
                      vr_tab_bloco(vr_tab_bloco.count()+1).dsbloco    := vr_dsendereco;
                      vr_tab_bloco(vr_tab_bloco.count()).cdmodalidade := vr_cdmodalidade;
                      vr_dsendereco := '//LISTA_RESPOSTAS';
                      EXCEPTION
                        WHEN OTHERS THEN
                          NULL;
                      END;                        
                    END IF;
                  END IF;
                END LOOP;
                vr_tab_modalidade.DELETE(5);
              END LOOP;
              vr_tab_modalidade.DELETE(4);
              vr_tab_modalidade.DELETE(5);
            END LOOP;
            vr_tab_modalidade.DELETE(3);
            vr_tab_modalidade.DELETE(4);
            vr_tab_modalidade.DELETE(5);
          END LOOP;
          vr_tab_modalidade.DELETE(2);
          vr_tab_modalidade.DELETE(3);
          vr_tab_modalidade.DELETE(4);
          vr_tab_modalidade.DELETE(5);
        END LOOP;
        vr_tab_modalidade.DELETE(1);
        vr_tab_modalidade.DELETE(2);
        vr_tab_modalidade.DELETE(3);
        vr_tab_modalidade.DELETE(4);
        vr_tab_modalidade.DELETE(5);
      END LOOP;
      --
      -- Efetuar o insert na tabela TBGEN_MODALIDADE_BIRO
      --
      FOR i IN 1 .. vr_tab_bloco.COUNT() LOOP
        DBMS_OUTPUT.PUT_LINE(i || '=' || vr_tab_bloco(i).dsbloco);
        SELECT EXTRACT(pr_retxml,vr_tab_bloco(i).dsbloco).getClobVal()
          INTO vr_clob
          FROM DUAL;
        --
        IF vr_tab_bloco(i).cdmodalidade IS NOT NULL THEN
        BEGIN
          INSERT INTO tbgen_modalidade_biro
            (nrconbir,
             nrseqdet,
             cdmodbir,
             nrcpfcgc,
             xmlmodal)
          VALUES
            (pr_nrconbir,
             pr_nrseqdet,
             vr_tab_bloco(i).cdmodalidade,
             pr_nrcpfcgc,
             vr_clob);
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            BEGIN
              UPDATE tbgen_modalidade_biro
                 SET xmlmodal = vr_clob
               WHERE nrconbir = pr_nrconbir
                 AND nrseqdet = pr_nrseqdet
                 AND cdmodbir = vr_tab_bloco(i).cdmodalidade;
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
                vr_dscritic := 'Erro ao alterar a CRAPPRM: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
            pr_dscritic := 'Erro ao inserir na TBGEN_MODALIDE_BIRO: '||SQLERRM;
        END;
        END IF;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
        pr_dscritic := 'Erro ao inserir na TBGEN_MODALIDE_BIRO: '||SQLERRM;        
    END PC_INCLUI_MODALIDADE_BIRO;
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_processa_retorno_req');  

    -- Setar o tipo de contrato conforme o indicador do produto
    IF pr_inprodut = 5 THEN
      vr_tpctrato := 8;
    ELSE
      vr_tpctrato := 1;
    END IF;

    -- Inicializa o contador de consultas
    vr_contador := 1;
    LOOP
      -- Verifica se existe dados na consulta
      IF pr_retxml.existsnode('//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/CONSULTA/DOCUMENTO') = 0 THEN  
        EXIT;      
      END IF;

      -- Verifica se houve erro de requisicao
      IF pr_retxml.existsnode('//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/ERROS/MENSAGEM') <> 0 THEN  
        pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/ERROS/MENSAGEM','S',vr_erro, vr_dscritic);
        -- Para requisições do Motor, apenas enviamos ao LOG
        IF pr_tpconaut = 'M' THEN 
          -- Gerar LOG
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Cecred
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - '
                                                     || 'Nrconbir: ' || ' --> ' ||pr_nrconbir
                                                     || ' Protocolo: '|| ' --> ' ||pr_nrprotoc
                                                     || ' Erro: --> Resposta Ignorada devido erro na consulta '
                                                     || ' retornada na resposta #'
                                                     || vr_contador||': Retorno XML: '||vr_erro
                                    ,pr_nmarqlog => 'CONAUT');
          -- Incrementar contador e ir ao próximo
          vr_contador := vr_contador + 1;
          CONTINUE;            
        ELSE  
        -- Atualiza o erro encontrado na variavel de critica
        vr_dscritic := 'Retorno XML: ' || vr_erro;
        RAISE vr_exc_saida;
      END IF;      
      END IF;      
      
      -- Limpa as variaveis gerais
      vr_database := NULL;
      vr_dsclasse := NULL;
      vr_intippes := NULL;
      vr_inpessoa := NULL;
      
------------- BUSCA OS DADOS DO CRAPCBD (titular da consulta) -------------
      BEGIN
        --Busca os campos do detalhe da consulta
        pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/CONSULTA/TIPO',         'S',vr_nmtagger, vr_dscritic);
        pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/CONSULTA/DOCUMENTO',    'S',vr_crapcbd.nrcpfcgc, vr_dscritic);
        pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/CONSULTA/DATA_BASE',    'S',vr_database, vr_dscritic);
        BEGIN
          vr_crapcbd.dtbaseba := to_date(vr_database,'YYYY/MM');
        EXCEPTION
          WHEN OTHERS THEN
            vr_crapcbd.dtbaseba := NULL;
        END;
        -- Somente para Motor
        IF pr_tpconaut = 'M' THEN 
          pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/CONSULTA/CLASSE',       'S',vr_dsclasse, vr_dscritic);        
        END IF;  
        pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/CADASTRO/IDENTIFICACAO/RAZAO_SOCIAL', 'S',vr_crapcbd.nmtitcon, vr_dscritic);
        pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/CADASTRO/SITUACAO-CADASTRAL/DT_INICIO', 'D',vr_crapcbd.dtatuend, vr_dscritic);
        pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/CADASTRO/LOCALIZACAO/ENDERECO', 'S',vr_crapcbd.dsendere, vr_dscritic);
        pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/CADASTRO/LOCALIZACAO/BAIRRO', 'S',vr_crapcbd.nmbairro, vr_dscritic);
        pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/CADASTRO/LOCALIZACAO/CIDADE', 'S',vr_crapcbd.nmcidade, vr_dscritic);
        pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/CADASTRO/LOCALIZACAO/UF', 'S',vr_crapcbd.cdufende, vr_dscritic);
        pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/CADASTRO/LOCALIZACAO/CEP', 'N',vr_crapcbd.nrcepend, vr_dscritic);
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
          CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
          vr_dscritic := 'Erro processo titular da consulta-'||vr_contador||': '||SQLERRM;
          RAISE vr_exc_saida;
       END;

      -- Verifica se ocorreu algum erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Separa a tag geral em duas tags
      vr_nmtagbir := substr(vr_nmtagger,1,instr(vr_nmtagger,'-')-1);
      vr_nmtagmod := substr(vr_nmtagger,instr(vr_nmtagger,'-')+1);

      -- Busca qual o biro e modulo do biro que esta sendo consultado
      OPEN cr_crapbir(vr_nmtagbir, vr_nmtagmod);
      FETCH cr_crapbir INTO rw_crapbir;
      IF cr_crapbir%NOTFOUND THEN
        CLOSE cr_crapbir;
        -- Para requisições do Motor, apenas enviamos ao LOG
        IF pr_tpconaut = 'M' THEN 
          -- Gerar LOG
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Cecred
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - '
                                                     || 'Nrconbir: ' || ' --> ' ||pr_nrconbir
                                                     || ' Protocolo: '|| ' --> ' ||pr_nrprotoc
                                                     || ' CPF: '|| ' --> ' ||vr_crapcbd.nrcpfcgc
                                                     || ' Erro: --> Resposta Ignorada pois nao foi encontrado'
                                                     || ' o biro de consulta retornado na resposta #'
                                                     || vr_contador||': TAGS: '||vr_nmtagbir||'-'||vr_nmtagmod
                                    ,pr_nmarqlog => 'CONAUT');
          -- Incrementar contador e ir ao próximo
          vr_contador := vr_contador + 1;
          CONTINUE;            
        ELSE   
          -- PAra requisições de Consulta Automatizada, seguimos o processo anterior, de gerar erro
          vr_dscritic := 'Nao foi encontrado o biro de consulta retornado: TAGS: '||vr_nmtagbir||'-'||vr_nmtagmod;
          RAISE vr_exc_saida;
        END IF;  
      END IF;
      CLOSE cr_crapbir;
			
      -- Para requisições do Motor
			IF pr_tpconaut = 'M' THEN 
        
        -- Checar se houve consulta SCR
        OPEN cr_conscr(pr_nmtagbir => vr_nmtagbir
		                  ,pr_nmtagmod => vr_nmtagmod);
				FETCH cr_conscr INTO rw_conscr;

        -- Se encontrou, houve consulta				
				IF cr_conscr%FOUND THEN
					-- Atualizar indicador
					pr_inconscr := 1;
				END IF;
				-- Fechar cursor 
        CLOSE cr_conscr;
				
        -- Buscaremos o tipo da Pessoa em relação a Proposta (Titular, Conjuge, Avalista, etc)
        pc_busca_intippes(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrctremp => pr_nrdocmto
                         ,pr_nrcpfcgc => vr_crapcbd.nrcpfcgc
                         ,pr_dsclasse => vr_dsclasse
                         ,pr_tpctrato => vr_tpctrato
                         ,pr_intippes => vr_intippes 
                         ,pr_nrctapes => vr_nrdconta
                         ,pr_inpessoa => vr_inpessoa); 

				-- Caso não tenhamos conseguido encontrar o tipo 
				IF vr_intippes IS NULL or vr_inpessoa IS NULL THEN
					-- Gerar erro
					vr_dscritic := 'Erro ao verificar tipo de pessoa CPF/CNPJ: '||vr_crapcbd.nrcpfcgc;
					RAISE vr_exc_saida;
				END IF;

				-- Insere o titular da consulta para PJ
				pc_insere_crapcbd(pr_nrconbir => pr_nrconbir,
													pr_cdbircon => rw_crapbir.cdbircon,
													pr_cdmodbir => rw_crapbir.cdmodbir,
													pr_cdcooper => pr_cdcooper,
													pr_nrdconta => vr_nrdconta,
													pr_nrcpfcgc => vr_crapcbd.nrcpfcgc,
													pr_inpessoa => vr_inpessoa,
													pr_intippes => vr_intippes,
													pr_cdcritic => vr_cdcritic,
													pr_dscritic => vr_dscritic);
				IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
					RAISE vr_exc_saida;
				END IF;
			END IF;			

------------- Verifica se exite reaproveitamento -------------
      -- Verifica se existe dados na consulta
      IF pr_retxml.existsnode('//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/OBSERVACOES[1]/LISTA_OBSERVACAO/OBSERVACAO/DESCRICAO') > 0 THEN  

	    IF pr_inprodut = 7 THEN
          
          BEGIN
            pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/OBSERVACOES[1]/LISTA_OBSERVACAO/OBSERVACAO[1]/DESCRICAO','S',vr_dsobserv, vr_dscritic);
            pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/OBSERVACOES[1]/LISTA_OBSERVACAO/OBSERVACAO[1]/MENSAGEM', 'S',vr_dsmsgobs, vr_dscritic);
          EXCEPTION
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
              CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
              vr_dscritic := 'Erro processo reaproveitamento-'||vr_contador||': '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        ELSE

		 /*Alterado em 20/05/2019 - Retorno de mais de uma lista de observacao*/
			BEGIN
			  pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/OBSERVACOES[1]/LISTA_OBSERVACAO/OBSERVACAO[1]/DESCRICAO','S',vr_dsobserv, vr_dscritic);
			  pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/OBSERVACOES[1]/LISTA_OBSERVACAO/OBSERVACAO[1]/MENSAGEM', 'S',vr_dsmsgobs, vr_dscritic);
			EXCEPTION
			  WHEN OTHERS THEN
				-- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
				CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
				vr_dscritic := 'Erro processo reaproveitamento-'||vr_contador||': '||SQLERRM;
				RAISE vr_exc_saida;
			END;
        END IF;  


        -- Verifica se ocorreu algum erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        -- Verifica se a mensagem eh de reaproveitamento
        IF vr_dsobserv = 'REAPROVEITAMENTO' THEN
          BEGIN
            vr_crapcbd.inreapro := 1;
            vr_crapcbd.dtreapro := to_date(substr(vr_dsmsgobs,instr(vr_dsmsgobs,'/')-2,10) || 
                                           substr(vr_dsmsgobs,instr(vr_dsmsgobs,':')-2,8)  ,'dd/mm/yyyyhh24:mi:ss');
          EXCEPTION
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
              CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
              -- Apenas insere um log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Cecred
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - '
                                                         || 'Nrconbir: ' || ' --> ' ||pr_nrconbir
                                                         || ' CPF: '|| ' --> ' ||vr_crapcbd.nrcpfcgc
                                                         || ' Erro: '    || ' --> Erro na data de reaproveitamento: ' ||vr_dsmsgobs
                                        ,pr_nmarqlog => 'CONAUT');
          END;
        END IF;
      END IF;

      -- Gravar a tabela de detalhes
      BEGIN
        UPDATE crapcbd
           SET nmtitcon = vr_crapcbd.nmtitcon,
               dtentsoc = vr_crapcbd.dtentsoc,
               nrcbrsoc = vr_crapcbd.nrcbrsoc,
               nrsdtsoc = vr_crapcbd.nrsdtsoc,
               percapvt = vr_crapcbd.percapvt,
               pertotal = vr_crapcbd.pertotal,
               dsvincul = vr_crapcbd.dsvincul,
               dtentadm = vr_crapcbd.dtentadm,
               dtmanadm = vr_crapcbd.dtmanadm,
               dsendere = vr_crapcbd.dsendere,
               nmbairro = vr_crapcbd.nmbairro,
               nrcepend = vr_crapcbd.nrcepend,
               nmcidade = vr_crapcbd.nmcidade,
               cdufende = vr_crapcbd.cdufende,
               dsprofis = vr_crapcbd.dsprofis,
               dtatuend = vr_crapcbd.dtatuend,
               dtatusoc = vr_crapcbd.dtatusoc,
               dtatuadm = vr_crapcbd.dtatuadm,
               dtatupar = vr_crapcbd.dtatupar,
               qtopescr = vr_crapcbd.qtopescr,
               qtifoper = vr_crapcbd.qtifoper,
               vltotsfn = vr_crapcbd.vltotsfn,
               vlopescr = vr_crapcbd.vlopescr,
               vlprejui = vr_crapcbd.vlprejui,
               nrprotoc = pr_nrprotoc,
               inreapro = nvl(vr_crapcbd.inreapro,0),
               dtreapro = vr_crapcbd.dtreapro,
               dtbaseba = vr_crapcbd.dtbaseba
         WHERE nrconbir = pr_nrconbir
           AND nrcpfcgc = vr_crapcbd.nrcpfcgc
           AND cdbircon = rw_crapbir.cdbircon
           AND intippes = DECODE(pr_tpconaut,'M',vr_intippes,intippes)
        RETURN nrseqdet, inpessoa 
          INTO vr_nrseqdet, vr_inpessoa;
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
          CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
          vr_dscritic := 'Erro ao atualizar CRAPCBD: ' ||SQLERRM;
          RAISE vr_exc_saida;
      END;
           
      -- Se nao alterou nenhum registro eh porque nao encontrou a solicitacao. Devera cancelar.
      IF SQL%ROWCOUNT = 0 THEN
        vr_dscritic := 'Nao foi encontrado requisicao para o CPF :'||vr_crapcbd.nrcpfcgc;
        RAISE vr_exc_saida;
      END IF;
      
      -- Limpa os dados da tabela
      vr_crapcbd := NULL;
      
------------- BUSCA OS DADOS DO CRAPRSC (SPC) -------------
      -- Primeiro faz a busca no spc local
      vr_inlocnac := 1; -- Local
      -- Atualiza o contador de registro para o inicio
      vr_contador_rsc := 1; 
      LOOP
        
        -- monta a tag principal
        IF vr_inlocnac = 1 THEN -- SPC Local
          vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/LISTA_SPC_ESTADUAL/SPC_ESTADUAL['||vr_contador_rsc||']/';
        ELSE -- SPC Nacional
          vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/LISTA_SPC_NACIONAL/SPC_NACIONAL['||vr_contador_rsc||']/';
        END IF;

        -- Verifica se existe dados na consulta do SPC Local
        IF vr_inlocnac = 1 AND -- Se for local
          pr_retxml.existsnode(vr_nmtagaux||'DT_OCORRENCIA') = 0 THEN  
          -- Muda para o SPC Nacional
          vr_inlocnac := 2;   
          vr_contador_rsc := 1;
          continue; -- Volta para o inicio do loop
        END IF;
        
        -- Verifica se existe dados na consulta do SPC Nacional
        IF vr_inlocnac = 2 AND -- Se for nacional
          pr_retxml.existsnode(vr_nmtagaux||'DT_OCORRENCIA') = 0 THEN  
          EXIT;        
        END IF;
        
        BEGIN
          -- Busca as informacoes
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_OCORRENCIA', 'D',vr_craprsc.dtregist, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'IDENTIFICACAO', 'S',vr_craprsc.dsinstit, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'MOTIVO',        'S',vr_craprsc.dsmtvreg, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'VL_OCORRENCIA', 'N',vr_craprsc.vlregist, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CIDADE',        'S',vr_craprsc.nmcidade, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'INFORMANTE',    'S',vr_craprsc.dsentorg, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_VENCIMENTO', 'D',vr_craprsc.dtvencto, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro processo no SPC-'||vr_contador||'-'||vr_inlocnac||'-'||vr_contador_rsc||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        -- Verifica se ocorreu algum erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        -- Insere o registro de SPC
        BEGIN
          INSERT INTO craprsc
            (nrconbir,
             nrseqdet,
             nrseqreg,
             dsinstit,
             nmcidade,
             cdufende,
             dtregist,
             dtvencto,
             dsmtvreg,
             vlregist,
             dsentorg,
             inlocnac)
           VALUES
            (pr_nrconbir,
             vr_nrseqdet,
             (SELECT nvl(MAX(nrseqreg),0)+1 FROM craprsc WHERE nrconbir=pr_nrconbir AND nrseqdet=vr_nrseqdet),
             vr_craprsc.dsinstit,
             fn_separa_cidade_uf(vr_craprsc.nmcidade,1),
             fn_separa_cidade_uf(vr_craprsc.nmcidade,2),
             vr_craprsc.dtregist,
             vr_craprsc.dtvencto,
             vr_craprsc.dsmtvreg,
             vr_craprsc.vlregist,
             vr_craprsc.dsentorg,
             vr_inlocnac);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro ao inserir na CRAPRSC: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        -- Vai para o proximo registro do XML
        vr_contador_rsc := vr_contador_rsc + 1;
        
        -- Limpa o conteudo da variavel de registro
        vr_craprsc := NULL;
        
      END LOOP;

------------- BUSCA OS DADOS DO CRAPPRF (Pefin / Refin) para o SPC -------------
      -- Atualiza o contador de registro para o inicio
      vr_contador_prf := 1; 
      LOOP
       
        -- monta a tag com o caminho para a busca das informacoes 
        vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/LISTA_PEFIN_REFIN/PEFIN_REFIN['||vr_contador_prf||']/';

        -- Verifica se existe dados na consulta 
        IF pr_retxml.existsnode(vr_nmtagaux||'DT_OCORRENCIA') = 0 THEN  
          EXIT;        
        END IF;
        
        BEGIN
          -- Busca as informacoes
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'MOTIVO',       'S',vr_crapprf.dsmtvreg, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'VL_OCORRENCIA','N',vr_crapprf.vlregist, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'IDENTIFICACAO','S',vr_crapprf.dsinstit, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'MODALIDADE',   'S',vr_crapprf.dsnature, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_VENCIMENTO','D',vr_crapprf.dtvencto, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro processo PEFIN / REFIN-'||vr_contador||'-'||vr_contador_prf||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        -- Verifica se ocorreu algum erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Insere o registro de Pefin / Refin
        BEGIN
          INSERT INTO crapprf
            (nrconbir,
             nrseqdet,
             nrseqreg,
             dsinstit,
             dtvencto,
             vlregist,
             dsmtvreg,
             dsnature)
           VALUES
            (pr_nrconbir,
             vr_nrseqdet,
             vr_contador_prf,
             vr_crapprf.dsinstit,
             vr_crapprf.dtvencto,
             vr_crapprf.vlregist,
             vr_crapprf.dsmtvreg,
             vr_crapprf.dsnature);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro ao inserir na CRAPPRF: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Vai para a proxima consulta
        vr_contador_prf := vr_contador_prf + 1;

        -- Limpa a tabela
        vr_crapprf := NULL;
      END LOOP;

      
------------- BUSCA OS DADOS DO CRAPPRF (Pefin/Refin) para o Serasa -------------
      -- efetuar somente se for do Serasa, pois estava pegando o somatorio do Pefin / Refin para o SPC tambem
      IF vr_inpessoa = 2 THEN
        -- Busca os totais
        -- Monta a tag de resumo do Pefin
        vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/RESUMO_PEFIN/';

        -- Verifica se existe o resumo do Pefin
        IF pr_retxml.existsnode(vr_nmtagaux||'QTDE_TOTAL') <> 0 THEN  
          BEGIN
            pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'QTDE_TOTAL','N',vr_craprpf.qtnegati, vr_dscritic);
            pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'VAL_TOTAL','N',vr_craprpf.vlnegati, vr_dscritic);
            pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_ULTIMO','D',vr_craprpf.dtultneg, vr_dscritic);
          EXCEPTION
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
              CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
              vr_dscritic := 'Erro resumo PEFIN Serasa-'||vr_contador||': '||SQLERRM;
              RAISE vr_exc_saida;
          END;
          -- Insere o resumo financeiro do Pefin
          pc_insere_craprpf(pr_nrconbir, vr_nrseqdet, 2, vr_craprpf.qtnegati, 
                            vr_craprpf.vlnegati, vr_craprpf.dtultneg, vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
          -- Limpa a tabela de memoria
          vr_craprpf := NULL;
        END IF;

        -- Monta a tag de resumo do Refin
        vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/RESUMO_REFIN/';

        -- Verifica se existe o resumo do Refin
        IF pr_retxml.existsnode(vr_nmtagaux||'QTDE_TOTAL') <> 0 THEN  
          BEGIN
            pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'QTDE_TOTAL','N',vr_craprpf.qtnegati, vr_dscritic);
            pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'VAL_TOTAL','N',vr_craprpf.vlnegati, vr_dscritic);
            pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_ULTIMO','D',vr_craprpf.dtultneg, vr_dscritic);
          EXCEPTION
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
              CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
              vr_dscritic := 'Erro resumo REFIN Serasa-'||vr_contador||': '||SQLERRM;
              RAISE vr_exc_saida;
          END;
          
          -- Insere o resumo financeiro do Refin
          pc_insere_craprpf(pr_nrconbir, vr_nrseqdet, 1, vr_craprpf.qtnegati, 
                            vr_craprpf.vlnegati, vr_craprpf.dtultneg, vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
          -- Limpa a tabela de memoria
          vr_craprpf := NULL;
        END IF;

        -- Primeiro faz a busca do Pefin 
        vr_inpefref := 1; -- Pefin
        -- Atualiza o contador de registro para o inicio
        vr_contador_prf := 1; 
        LOOP
         
          -- Se for Pefin
          IF vr_inpefref = 1 THEN
            -- monta a tag com o caminho para a busca das informacoes 
            vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/LISTA_PEFIN/PEFIN['||vr_contador_prf||']/';
          ELSE -- Se for Refin
            -- monta a tag com o caminho para a busca das informacoes 
            vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/LISTA_REFIN/REFIN['||vr_contador_prf||']/';
          END IF;
          
          -- Verifica se existe dados na consulta do Pefin
          IF vr_inpefref = 1 AND -- Se for Pefin
            pr_retxml.existsnode(vr_nmtagaux||'DT_OCORRENCIA') = 0 THEN  
            -- Muda para o Refin
            vr_inpefref := 2;   
            vr_contador_prf := 1;
            continue; -- Volta para o inicio do loop
          END IF;

          -- Verifica se existe dados na consulta do Refin
          IF vr_inpefref = 2 AND -- Se for Refin
            pr_retxml.existsnode(vr_nmtagaux||'DT_OCORRENCIA') = 0 THEN  
            EXIT;
          END IF;

          BEGIN
            -- Busca as informacoes
            pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_OCORRENCIA','D',vr_crapprf.dtvencto, vr_dscritic);
            pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'MODALIDADE',   'S',vr_crapprf.dsmtvreg, vr_dscritic);
            pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'VL_OCORRENCIA','N',vr_crapprf.vlregist, vr_dscritic);
            pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'IDENTIFICACAO','S',vr_crapprf.dsinstit, vr_dscritic);
          EXCEPTION
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
              CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
              vr_dscritic := 'Erro PEFIN/REFIN do Serasa-'||vr_contador||'-'||vr_inpefref||'-'||vr_contador_prf||': '||SQLERRM;
              RAISE vr_exc_saida;
          END;
          -- Verifica se ocorreu algum erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

          -- Insere o registro de Pefin / Refin
          BEGIN
            INSERT INTO crapprf
              (nrconbir,
               nrseqdet,
               nrseqreg,
               inpefref,
               dsinstit,
               dtvencto,
               vlregist,
               dsnature,
               dsmtvreg)
             VALUES
              (pr_nrconbir,
               vr_nrseqdet,
               (SELECT nvl(MAX(nrseqreg),0)+1 FROM crapprf WHERE nrconbir=pr_nrconbir AND nrseqdet=vr_nrseqdet),
               vr_inpefref,
               vr_crapprf.dsinstit,
               vr_crapprf.dtvencto,
               vr_crapprf.vlregist,
               vr_crapprf.dsnature,
               vr_crapprf.dsmtvreg);
          EXCEPTION
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
              CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
              vr_dscritic := 'Erro ao inserir na CRAPPRF: '||SQLERRM;
              RAISE vr_exc_saida;
          END;

          -- Vai para a proxima consulta
          vr_contador_prf := vr_contador_prf + 1;

          -- Limpa a tabela
          vr_crapprf := NULL;

        END LOOP;
      END IF;      

------------- BUSCA OS DADOS DO CRAPPRF (Dívida Vencida) para o Serasa -------------
      -- Busca os totais
      -- Monta a tag de resumo de dívida vencida
      vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/RESUMO_DIVIDA_VENCIDA/';

      -- Verifica se existe o resumo de dívida vencida
      IF pr_retxml.existsnode(vr_nmtagaux||'QTDE_TOTAL') <> 0 THEN  
        BEGIN
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'QTDE_TOTAL','N',vr_craprpf.qtnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'VAL_TOTAL','N',vr_craprpf.vlnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_ULTIMO','D',vr_craprpf.dtultneg, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro resumo dívida vencida Serasa-'||vr_contador||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        -- Insere o resumo financeiro de dívida vencida
        pc_insere_craprpf(pr_nrconbir, vr_nrseqdet, 10, vr_craprpf.qtnegati, 
                          vr_craprpf.vlnegati, vr_craprpf.dtultneg, vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Limpa a tabela de memoria
        vr_craprpf := NULL;
      END IF;

      -- Atualiza o contador de registro para o inicio
      vr_contador_prf := 1; 
      LOOP
         
        -- monta a tag com o caminho para a busca das informacoes 
        vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/LISTA_DIVIDA_VENCIDA/DIVIDA_VENCIDA['||vr_contador_prf||']/';
          
        -- Verifica se existe dados na consulta de dívida vencida
        IF pr_retxml.existsnode(vr_nmtagaux||'DT_OCORRENCIA') = 0 THEN  
          EXIT;
        END IF;

        BEGIN
          -- Busca as informacoes
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_OCORRENCIA','D',vr_crapprf.dtvencto, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'VL_OCORRENCIA','N',vr_crapprf.vlregist, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'IDENTIFICACAO','S',vr_crapprf.dsinstit, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro divida vencida do Serasa-'||vr_contador||'-'||vr_inpefref||'-'||vr_contador_prf||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        -- Verifica se ocorreu algum erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Insere o registro de dívida vencida
        BEGIN
          INSERT INTO crapprf
            (nrconbir,
             nrseqdet,
             nrseqreg,
             inpefref,
             dsinstit,
             dtvencto,
             vlregist,
             dsnature,
             dsmtvreg)
           VALUES
            (pr_nrconbir,
             vr_nrseqdet,
             (SELECT nvl(MAX(nrseqreg),0)+1 FROM crapprf WHERE nrconbir=pr_nrconbir AND nrseqdet=vr_nrseqdet),
             3,
             vr_crapprf.dsinstit,
             vr_crapprf.dtvencto,
             vr_crapprf.vlregist,
             vr_crapprf.dsnature,
             vr_crapprf.dsmtvreg);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro ao inserir na CRAPPRF: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Vai para a proxima consulta
        vr_contador_prf := vr_contador_prf + 1;

        -- Limpa a tabela
        vr_crapprf := NULL;

      END LOOP;

------------- BUSCA OS DADOS DO CRAPPRF (Inadimplência) para o Serasa -------------
      -- Busca os totais
      -- Monta a tag de resumo de Inadimplência
      vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/INADIMPLENCIA/';

      -- Verifica se existe o resumo de Inadimplência
      IF pr_retxml.existsnode(vr_nmtagaux||'QTDE_TOTAL') <> 0 THEN  
        BEGIN
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'QTDE_TOTAL','N',vr_craprpf.qtnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'VAL_TOTAL','N',vr_craprpf.vlnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_ULTIMO','D',vr_craprpf.dtultneg, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro resumo inadimplência Serasa-'||vr_contador||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        -- Insere o resumo financeiro de inadimplência
        pc_insere_craprpf(pr_nrconbir, vr_nrseqdet, 11, vr_craprpf.qtnegati, 
                          vr_craprpf.vlnegati, vr_craprpf.dtultneg, vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Limpa a tabela de memoria
        vr_craprpf := NULL;
      END IF;

------------- BUSCA OS DADOS DO CRAPESC (Escore) para o Serasa -------------
      -- Monta a tag de escore
      vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/RISCOS/ESCORE/';

      -- Verifica se existe o resumo de Inadimplência
      IF pr_retxml.existsnode(vr_nmtagaux||'PONTUACAO') <> 0 THEN  
        BEGIN
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'PONTUACAO','N',vr_crapesc.vlpontua, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DESCRICAO','S',vr_crapesc.dsescore, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CLASSIFICACAO','S',vr_crapesc.dsclassi, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro resumo escore Serasa-'||vr_contador||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        -- Insere o escore
        pc_insere_crapesc(pr_nrconbir, vr_nrseqdet, vr_crapesc.dsescore, vr_crapesc.vlpontua, nvl(vr_crapesc.dsclassi,' '), vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Limpa a tabela de memoria
        vr_crapesc := NULL;
      END IF;

      /* PRJ 438 - Sprint 15 BUSCA OS DADOS DA CRAPCDB (Classe de Risco) para o Serasa */
      -- Monta a tag de classe de risco
      vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/RISCOS/MENSAGEM_ESCORE/';
      -- Verifica se existe a mensagem da classe de risco pois não tem pontuação
      IF pr_retxml.existsnode(vr_nmtagaux||'DESCRICAO') <> 0 THEN  
        BEGIN
          --Busca a descrição da classe de risco do SERASA
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DESCRICAO','S',vr_dsclaris, vr_dscritic);
          vr_dsclaris := SUBSTR(vr_dsclaris,-2);
        EXCEPTION
          WHEN OTHERS THEN
            --Grava a tabela de erro
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro classe de risco do Serasa'||vr_contador||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        -- Atualiza a classificacao do risco
        pc_atualiza_classe_serasa(pr_nrconbir => pr_nrconbir
                                 ,pr_nrseqdet => vr_nrseqdet
                                 ,pr_dsclaris => vr_dsclaris
                                 ,pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Limpa a tabela de memoria
        vr_dsclaris := NULL;
      END IF;
      /* PRJ 438 - Sprint 15 BUSCA OS DADOS DA CRAPCDB (Probabilidade de Inadimplência) para o Serasa */
      -- Monta a tag de classe de risco
      vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/RISCOS/PROBABILIDADE/';
      -- Verifica se existe a mensagem de probabilidade de inadimplencia
      IF pr_retxml.existsnode(vr_nmtagaux||'PONTUACAO') <> 0 THEN  
        BEGIN
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'PONTUACAO','N',vr_crapesc.vlpontua, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            --Grava a tabela de erro
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro classe de risco do Serasa'||vr_contador||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        -- Atualiza a inadimplencia
        pc_atualiza_inadimplencia(pr_nrconbir => pr_nrconbir
                                 ,pr_nrseqdet => vr_nrseqdet
                                 ,pr_peinadim => vr_crapesc.vlpontua
                                 ,pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Limpa a tabela de memoria
        vr_dsclaris := NULL;
      END IF;
------------- BUSCA OS DADOS DO CRAPCSF (Cheque sem fundos) para o SPC -------------
      -- Primeiro faz a busca de cheques estaduais
      vr_insitchq := 1; -- Cheque estadual
      -- Atualiza o contador de registro para o inicio
      vr_contador_csf := 1; 
      LOOP
        
        -- monta a tag principal
        IF vr_insitchq = 1 THEN -- Cheque estadual
          vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/LISTA_CHEQUE_ESTADUAL/CHEQUE_ESTADUAL['||vr_contador_csf||']/';
        ELSIF vr_insitchq = 2 THEN -- Cheque nacional
          vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/LISTA_CHEQUE_NACIONAL/CHEQUE_NACIONAL['||vr_contador_csf||']/';
        ELSIF vr_insitchq = 3 THEN -- Cheque serasa
          vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/LISTA_CHEQUE_SERASA/CHEQUE_SERASA['||vr_contador_csf||']/';
        END IF;

        -- Verifica se existe dados na consulta do cheque Local
        IF vr_insitchq = 1 AND -- Se for estadual
          pr_retxml.existsnode(vr_nmtagaux||'DT_OCORRENCIA') = 0 THEN  
          -- Muda para o Nacional
          vr_insitchq := 2;   
          vr_contador_csf := 1;
          continue; -- Volta para o inicio do loop
        END IF;
        
        IF vr_insitchq = 2 AND -- Se for nacional
          pr_retxml.existsnode(vr_nmtagaux||'DT_OCORRENCIA') = 0 THEN  
          -- Muda para o Serasa
          vr_insitchq := 3;   
          vr_contador_csf := 1;
          continue; -- Volta para o inicio do loop
        END IF;

        -- Verifica se existe dados na consulta do Serasa
        IF vr_insitchq = 3 AND -- Se for Serasa
          pr_retxml.existsnode(vr_nmtagaux||'DT_OCORRENCIA') = 0 THEN  
          EXIT;        
        END IF;
        
        BEGIN
          -- Busca as informacoes
          --Chamado 363148
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_OCORRENCIA','D',vr_crapcsf.dtinclus, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'BANCO',        'S',vr_crapcsf.nmbanchq, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'AGENCIA',      'N',vr_crapcsf.cdagechq, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CHEQUE',       'S',vr_crapcsf.nrcheque, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'VL_OCORRENCIA','N',vr_crapcsf.vlcheque, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CIDADE', 		  'S',vr_crapcsf.nmcidade, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_EMISSAO',   'D',vr_crapcsf.dtultocr, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'MOTIVO',       'S',vr_txalinea, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'QTDE_TOTAL',   'S',vr_crapcsf.qtcheque, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro cheque sem fundo do SPC-'||vr_contador||'-'||vr_insitchq||'-'||vr_contador_csf||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Verifica se ocorreu algum erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        --Chamado 363148
        begin
          vr_crapcsf.cdalinea := to_number(vr_txalinea);
          vr_txalinea := '';
        exception
          when value_error then
            vr_crapcsf.cdalinea := null;
        end;
        
        -- Insere o registro de SPC
        -- Chamado 363148
        BEGIN
          INSERT INTO crapcsf
            (nrconbir,
             nrseqdet,
             nrseqreg,
             nmbanchq,
             cdagechq,
             cdalinea,
             qtcheque,
             dtultocr,
             dtinclus,
             nrcheque,
             vlcheque,
             nmcidade,
             cdufende,
             idsitchq,
             dsmotivo)
           VALUES
            (pr_nrconbir,
             vr_nrseqdet,
             (SELECT nvl(MAX(nrseqreg),0)+1 FROM crapcsf WHERE nrconbir=pr_nrconbir AND nrseqdet=vr_nrseqdet),
             vr_crapcsf.nmbanchq,
             vr_crapcsf.cdagechq,
             vr_crapcsf.cdalinea,
             vr_crapcsf.qtcheque,
             vr_crapcsf.dtultocr,
             vr_crapcsf.dtinclus,
             vr_crapcsf.nrcheque,
             vr_crapcsf.vlcheque,
             fn_separa_cidade_uf(vr_crapcsf.nmcidade,1),
             fn_separa_cidade_uf(vr_crapcsf.nmcidade,2),
             1,
             vr_txalinea);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro ao inserir na CRAPCSF: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        -- Limpa o conteudo da variavel de registro
        vr_crapcsf := NULL;
        
        -- Vai para o proximo registro
        vr_contador_csf := vr_contador_csf + 1;
      END LOOP;

------------- BUSCA OS DADOS DO CRAPCSF (Cheque sem fundos ou cancelados/devolvidos) para o Serasa -------------
      -- Primeiro faz a busca de cheques sem fundos
      vr_insitchq := 1; -- Cheque sem fundos

      -- Atualiza o contador de registro para o inicio
      vr_contador_csf := 1; 
      LOOP
        
        -- Se for cheque sem fundos
        IF vr_insitchq = 1 THEN 
          -- monta a tag principal buscando por CHEQUE ou RECHEQUE
          vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/LISTA_RECHEQUE_SEM_FUNDO/RECHEQUE_SEM_FUNDO['||vr_contador_csf||']/';
          vr_nmtagau2 := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/LISTA_CHEQUE_SEM_FUNDO/CHEQUE_SEM_FUNDO['||vr_contador_csf||']/';
        ELSE -- sustado / cancelado
          -- monta a tag principal buscando por CHEQUE ou RECHEQUE
          vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/LISTA_RECHEQUE_DEVOLVIDO/RECHEQUE_DEVOLVIDO['||vr_contador_csf||']/';
          vr_nmtagau2 := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/LISTA_CHEQUE_DEVOLVIDO/CHEQUE_DEVOLVIDO['||vr_contador_csf||']/';
        END IF;          

        -- Verifica se existe dados na consulta do cheque sem fundos
        IF vr_insitchq = 1 -- Se for cheque sem fundo
        AND pr_retxml.existsnode(vr_nmtagaux||'DT_OCORRENCIA') = 0 
        AND pr_retxml.existsnode(vr_nmtagau2||'DT_OCORRENCIA') = 0 THEN  
          -- Muda para o sustado / cancelado
          vr_insitchq := 2;   
          vr_contador_csf := 1;
          continue; -- Volta para o inicio do loop
        END IF;

        -- Verifica se existe dados na consulta do cheque sustado / cancelado
        IF vr_insitchq = 2 -- Se for sustado / cancelado
        AND pr_retxml.existsnode(vr_nmtagaux||'DT_OCORRENCIA') = 0 
        AND pr_retxml.existsnode(vr_nmtagau2||'DT_OCORRENCIA') = 0 THEN  
          EXIT;        
        END IF;

        -- Guardar se é Recheque ou não
        IF pr_retxml.existsnode(vr_nmtagaux||'DT_OCORRENCIA') <> 0 THEN
          vr_flgrechq := true;
        ELSE
          vr_flgrechq := false;  
        END IF;

        -- Limpa a variavel de totais
        vr_craprpf := NULL;
        
        -- Busca os totais
        -- Se for cheque sem fundos
        IF vr_insitchq = 1 THEN 
          -- Busca os valores
          pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/RESUMO_CHEQUE_SEM_FUNDO/QTDE_TOTAL','N',vr_craprpf.qtnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/RESUMO_CHEQUE_SEM_FUNDO/VAL_TOTAL', 'N',vr_craprpf.vlnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/RESUMO_CHEQUE_SEM_FUNDO/DT_ULTIMO', 'D',vr_craprpf.dtultneg, vr_dscritic);

        ELSE -- sustado / cancelado
          -- Busca os valores
          pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/RESUMO_CHEQUE_SUSTADO/QTDE_TOTAL','N',vr_craprpf.qtnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/RESUMO_CHEQUE_SUSTADO/VAL_TOTAL', 'N',vr_craprpf.vlnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/RESUMO_CHEQUE_SUSTADO/DT_ULTIMO', 'D',vr_craprpf.dtultneg, vr_dscritic);
        END IF;          

        IF nvl(vr_craprpf.qtnegati,0) > 0 OR nvl(vr_craprpf.vlnegati,0) > 0 THEN
          -- Insere o resumo financeiro do cheque sem fundo ou cheque cancelado / estornado
          pc_insere_craprpf(pr_nrconbir, vr_nrseqdet, 5+vr_insitchq, vr_craprpf.qtnegati, 
                            vr_craprpf.vlnegati, vr_craprpf.dtultneg, vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
          -- Limpa a tabela de memoria
          vr_craprpf := NULL;
        END IF;
        
        -- Somente para Recheque
        IF vr_flgrechq THEN 
        
        BEGIN
          -- Busca as informacoes
          -- Chamado 363148
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_OCORRENCIA','D',vr_crapcsf.dtinclus, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'BANCO',        'S',vr_crapcsf.nmbanchq, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'AGENCIA',      'N',vr_crapcsf.cdagechq, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CHEQUE',       'S',vr_crapcsf.nrcheque, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'VL_OCORRENCIA','N',vr_crapcsf.vlcheque, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CIDADE', 		  'S',vr_crapcsf.nmcidade, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'MOTIVO',       'S',vr_txalinea, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro cheque sem fundo do Serasa-'||vr_contador||'-'||vr_insitchq||'-'||vr_contador_csf||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        -- Verifica se ocorreu algum erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        --Chamado 363148
        begin
          vr_crapcsf.cdalinea := to_number(vr_txalinea);
          vr_txalinea := '';
        exception
          when value_error then
            vr_crapcsf.cdalinea := null;
        end;
        
        -- Insere o registro de Cheque sem fundo
        -- Chamado 363148
        BEGIN
          INSERT INTO crapcsf
            (nrconbir,
             nrseqdet,
             nrseqreg,
             nmbanchq,
             cdagechq,
             cdalinea,
             qtcheque,
             dtinclus,
             nrcheque,
             vlcheque,
             nmcidade,
             cdufende,
             idsitchq,
             dsmotivo)
           VALUES
            (pr_nrconbir,
             vr_nrseqdet,
             (SELECT nvl(MAX(nrseqreg),0)+1 FROM crapcsf WHERE nrconbir=pr_nrconbir AND nrseqdet=vr_nrseqdet),
             vr_crapcsf.nmbanchq,
             vr_crapcsf.cdagechq,
             vr_crapcsf.cdalinea,
             1,
             vr_crapcsf.dtinclus,
             vr_crapcsf.nrcheque,
             vr_crapcsf.vlcheque,
             fn_separa_cidade_uf(vr_crapcsf.nmcidade,1),
             fn_separa_cidade_uf(vr_crapcsf.nmcidade,2),
             vr_insitchq,
             vr_txalinea);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro ao inserir na CRAPCSF (Serasa): '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        END IF; 

        -- Vai para a proxima consulta
        vr_contador_csf := vr_contador_csf + 1;

        -- Limpa o conteudo da variavel de registro
        vr_crapcsf := NULL;

      END LOOP;


------------- BUSCA OS DADOS DO CRAPPRT (Protesto SPC e Serasa) -------------
      -- Busca os totais
      -- Monta a tag de resumo do Protesto
      vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/RESUMO_PROTESTO/';

      -- Verifica se existe o resumo do Protesto
      IF pr_retxml.existsnode(vr_nmtagaux||'QTDE_TOTAL') <> 0 THEN  
        BEGIN
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'QTDE_TOTAL','N',vr_craprpf.qtnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'VAL_TOTAL', 'N',vr_craprpf.vlnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_ULTIMO', 'D',vr_craprpf.dtultneg, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro resumo protesto-'||vr_contador||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        -- Insere o resumo financeiro do Protesto
        pc_insere_craprpf(pr_nrconbir, vr_nrseqdet, 3, vr_craprpf.qtnegati, 
                          vr_craprpf.vlnegati, vr_craprpf.dtultneg, vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Limpa a tabela de memoria
        vr_craprpf := NULL;
      END IF;

      -- Atualiza o contador de registro para o inicio
      vr_contador_prt := 1; 
      LOOP
       
        -- monta a tag com o caminho para a busca das informacoes 
        vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/LISTA_PROTESTO/PROTESTO['||vr_contador_prt||']/';

        -- Verifica se existe dados na consulta 
        IF pr_retxml.existsnode(vr_nmtagaux||'IDENTIFICACAO') = 0 THEN  
          EXIT;        
        END IF;
        
        BEGIN
          -- Busca as informacoes
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'IDENTIFICACAO','S',vr_crapprt.nmlocprt, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'ENDERECO','S',vr_crapprt.nmcidade, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'VL_OCORRENCIA','N',vr_crapprt.vlprotes, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_OCORRENCIA','D',vr_crapprt.dtprotes, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro protesto-'||vr_contador||'-'||vr_contador_prt||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        -- Verifica se ocorreu algum erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Insere o registro de Protesto
        BEGIN
          INSERT INTO crapprt
            (nrconbir,
             nrseqdet,
             nrseqreg,
             nmlocprt,
             vlprotes,
             dtprotes,
             nmcidade,
             cdufende)
           VALUES
            (pr_nrconbir,
             vr_nrseqdet,
             vr_contador_prt,
             vr_crapprt.nmlocprt,
             vr_crapprt.vlprotes,
             vr_crapprt.dtprotes,
             decode(rw_crapbir.cdbircon,2,fn_separa_cidade_uf(vr_crapprt.nmcidade,1),' '),
             decode(rw_crapbir.cdbircon,2,fn_separa_cidade_uf(vr_crapprt.nmcidade,2),' ')); 
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro ao inserir na CRAPPRT: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Vai para a proxima consulta
        vr_contador_prt := vr_contador_prt + 1;

        -- Limpa o conteudo da variavel de registro
        vr_crapprt := NULL;

      END LOOP;
      

------------- BUSCA OS DADOS DO CRAPABR (Acoes) para o Serasa -------------
      -- Busca os totais
      -- Monta a tag de resumo de acao judicial
      vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/RESUMO_ACAO_JUDICIAL/';

      -- Verifica se existe o resumo do acao judicial
      IF pr_retxml.existsnode(vr_nmtagaux||'QTDE_TOTAL') <> 0 THEN  
        BEGIN
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'QTDE_TOTAL','N',vr_craprpf.qtnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'VAL_TOTAL','N',vr_craprpf.vlnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_ULTIMO','D',vr_craprpf.dtultneg, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro resumo de acoes-'||vr_contador||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        -- Insere o resumo financeiro de acao judicial
        pc_insere_craprpf(pr_nrconbir, vr_nrseqdet, 4, vr_craprpf.qtnegati, 
                          vr_craprpf.vlnegati, vr_craprpf.dtultneg, vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Limpa a tabela de memoria
        vr_craprpf := NULL;
      END IF;

      -- Atualiza o contador de registro para o inicio
      vr_contador_abr := 1; 
      LOOP
        
        -- monta a tag principal
        vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/LISTA_ACAO_JUDICIAL/ACAO_JUDICIAL['||vr_contador_abr||']/';

        -- Verifica se existe dados na consulta do cheque
        IF pr_retxml.existsnode(vr_nmtagaux||'DT_OCORRENCIA') = 0 THEN  
          EXIT;        
        END IF;
        
        BEGIN
          -- Busca as informacoes
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_OCORRENCIA','D',vr_crapabr.dtacajud, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'VL_OCORRENCIA','N',vr_crapabr.vltotaca, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'MODALIDADE',   'S',vr_crapabr.dsnataca, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CIDADE',       'S',vr_crapabr.nmcidade, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'VARA',         'N',vr_crapabr.nrvaraca, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DISTRITO_JUR', 'N',vr_crapabr.nrdistri, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro no retorno de acoes-'||vr_contador||'-'||vr_contador_abr||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Verifica se ocorreu algum erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        -- Insere o registro de Acoes
        BEGIN
          INSERT INTO crapabr
            (nrconbir,
             nrseqdet,
             nrseqreg,
             dtacajud,
             dsnataca,
             vltotaca,
             nrdistri,
             nrvaraca,
             nmcidade,
             cdufende)
           VALUES
            (pr_nrconbir,
             vr_nrseqdet,
             vr_contador_abr,
             vr_crapabr.dtacajud,
             vr_crapabr.dsnataca,
             vr_crapabr.vltotaca,
             vr_crapabr.nrdistri,
             vr_crapabr.nrvaraca,
             fn_separa_cidade_uf(vr_crapabr.nmcidade,1),
             fn_separa_cidade_uf(vr_crapabr.nmcidade,2));
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro ao inserir na CRAPABR: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        -- Vai para a proxima consulta
        vr_contador_abr := vr_contador_abr + 1;

        -- Limpa o conteudo da variavel de registro
        vr_crapabr := NULL;

      END LOOP;

------------- BUSCA OS DADOS DO CRAPRFC (Falencia) para o Serasa -------------
      -- Busca os totais
      -- Monta a tag de resumo de participacao em falencia
      vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/RESUMO_FALENCIA_CONCORDATA/';

      -- Verifica se existe o resumo de participacao em falencia
      IF pr_retxml.existsnode(vr_nmtagaux||'QTDE_TOTAL') <> 0 THEN  
        BEGIN
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'QTDE_TOTAL','N',vr_craprpf.qtnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_ULTIMO','D',vr_craprpf.dtultneg, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro no resumo de falencias-'||vr_contador||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        -- Insere o resumo financeiro de participacao em falencia
        pc_insere_craprpf(pr_nrconbir, vr_nrseqdet, 5, vr_craprpf.qtnegati, 
                          0, vr_craprpf.dtultneg, vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Limpa a tabela de memoria
        vr_craprpf := NULL;
      END IF;

      -- Atualiza o contador de registro para o inicio
      vr_contador_rfc := 1; 
      LOOP
        
        -- monta a tag principal
        vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/APONTAMENTOS/LISTA_PARTICIPACAO_FALENCIA/PARTICIPACAO_FALENCIA['||vr_contador_rfc||']/';

        -- Verifica se existe dados na consulta do cheque
        IF pr_retxml.existsnode(vr_nmtagaux||'DT_OCORRENCIA') = 0 THEN  
          EXIT;
        END IF;

        BEGIN
          -- Busca as informacoes
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_OCORRENCIA','D',vr_craprfc.dtregist, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'MOTIVO',       'S',vr_craprfc.dstipreg, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'LOCALIZACAO',  'S',vr_craprfc.dsorgreg, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CIDADE',       'S',vr_craprfc.nmcidade, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro processo de falencias-'||vr_contador||'-'||vr_contador_rfc||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        -- Verifica se ocorreu algum erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        -- Insere o registro de falencia
        BEGIN
          INSERT INTO craprfc
            (nrconbir,
             nrseqdet,
             nrseqreg,
             dtregist,
             dstipreg,
             dsorgreg,
             nmcidade,
             cdufende)
           VALUES
            (pr_nrconbir,
             vr_nrseqdet,
             vr_contador_rfc,
             vr_craprfc.dtregist,
             vr_craprfc.dstipreg,
             vr_craprfc.dsorgreg,
             fn_separa_cidade_uf(vr_craprfc.nmcidade,1),
             fn_separa_cidade_uf(vr_craprfc.nmcidade,2));
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro ao inserir na CRAPRFC: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        -- Vai para a proxima consulta
        vr_contador_rfc := vr_contador_rfc + 1;

        -- Limpa o conteudo da variavel de registro
        vr_craprfc := NULL;

      END LOOP;

------------- BUSCA OS DADOS DO CRAPCBD (Socios) -------------
      -- Busca a data de atualizacao no resumo
      IF pr_retxml.existsnode('//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/QUADRO_SOCIAL/RESUMO_CONTROLE_SOCIETARIO/DT_ATUALIZACAO') <> 0 THEN  
        pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/QUADRO_SOCIAL/RESUMO_CONTROLE_SOCIETARIO/DT_ATUALIZACAO',
                                'D',vr_dtatusoc, vr_dscritic);
        -- Verifica se ocorreu algum erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      ELSE
        vr_dtatusoc := NULL;
      END IF;
      
      -- Atualiza o contador de registro para o inicio
      vr_contador_soc := 1; 
      LOOP
        
        -- monta a tag principal
        vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/QUADRO_SOCIAL/LISTA_CONTROLE_SOCIETARIO/CONTROLE_SOCIETARIO['||vr_contador_soc||']/';

        -- Verifica se existe dados na consulta do socio
        IF pr_retxml.existsnode(vr_nmtagaux||'DOCUMENTO') = 0 THEN  
          EXIT;        
        END IF;
        
        BEGIN
          -- Busca as informacoes
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DOCUMENTO',      'N',vr_crapcbd.nrcpfcgc, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'RAZAO_SOCIAL',   'S',vr_crapcbd.nmtitcon, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_INICIO',      'D',vr_crapcbd.dtentsoc, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'PERC_CAP_VOTANT','N',vr_crapcbd.percapvt, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'PERC_PARTIC',    'N',vr_crapcbd.pertotal, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro processo busca de socios-'||vr_contador||'-'||vr_contador_soc||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Verifica se ocorreu algum erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        -- Insere o registro de socio
        BEGIN
          INSERT INTO crapcbd
            (nrconbir,
             nrseqdet,
             cdbircon,
             cdmodbir,
             dtconbir,
             cdcooper,
             nrdconta,
             nrcpfcgc,
             inpessoa,
             nmtitcon,
             intippes,
             dtentsoc,
             nrcbrsoc,
             nrsdtsoc,
             percapvt,
             pertotal,
             dtatusoc,
             nrprotoc,
             inreterr,
             inreapro)
           VALUES
            (pr_nrconbir,
             (SELECT MAX(nrseqdet)+1 FROM crapcbd WHERE nrconbir=pr_nrconbir),
             rw_crapbir.cdbircon,
             rw_crapbir.cdmodbir,
             SYSDATE,
             pr_cdcooper,
             0, --Numero da conta vazio, pois socio nao tem conta
             vr_crapcbd.nrcpfcgc,
             1,
             vr_crapcbd.nmtitcon,
             4,
             vr_crapcbd.dtentsoc,
             pr_nrconbir,
             vr_nrseqdet,
             vr_crapcbd.percapvt,
             vr_crapcbd.pertotal,
             vr_dtatusoc,
             pr_nrprotoc,
             0,
             0);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro ao inserir na CRAPCBD (socio): '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        -- Vai para a proxima consulta
        vr_contador_soc := vr_contador_soc + 1;

        -- Limpa o conteudo da variavel de registro
        vr_crapcbd := NULL;

      END LOOP;

------------- BUSCA OS DADOS DO CRAPCBD (Administradores) -------------
      -- Busca a data de atualizacao no resumo
      IF pr_retxml.existsnode('//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/QUADRO_SOCIAL/RESUMO_ADMINISTRACAO/DT_ATUALIZACAO') <> 0 THEN  
        pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/QUADRO_SOCIAL/RESUMO_ADMINISTRACAO/DT_ATUALIZACAO',
                                'D',vr_dtatuadm, vr_dscritic);
        -- Verifica se ocorreu algum erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      ELSE
        vr_dtatuadm := NULL;
      END IF;
      
      -- Atualiza o contador de registro para o inicio
      vr_contador_adm := 1; 
      LOOP
        
        -- monta a tag principal
        vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/QUADRO_SOCIAL/LISTA_ADMINISTRACAO/ADMINISTRACAO['||vr_contador_adm||']/';

        -- Verifica se existe dados na consulta do administrador
        IF pr_retxml.existsnode(vr_nmtagaux||'DOCUMENTO') = 0 THEN  
          EXIT;        
        END IF;
        
        BEGIN
          -- Busca as informacoes
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DOCUMENTO',      'N',vr_crapcbd.nrcpfcgc, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'RAZAO_SOCIAL',   'S',vr_crapcbd.nmtitcon, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_INICIO',      'D',vr_crapcbd.dtentadm, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'FUNCAO',         'S',vr_dsvincul, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'MANDATO',        'S',vr_crapcbd.dtmanadm, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro processo socios administradores-'||vr_contador||'-'||vr_contador_adm||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        -- Atualiza o vinculo com as 10 primeiras posicoes
        vr_crapcbd.dsvincul := substr(vr_dsvincul,1,10);
        
        -- Verifica se ocorreu algum erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        -- Atualiza o registro de socios, mudando para socio-administrador
        BEGIN
          UPDATE crapcbd
             SET dtentadm = vr_crapcbd.dtentadm,
                 dsvincul = vr_crapcbd.dsvincul,
                 dtmanadm = vr_crapcbd.dtmanadm,
                 intippes = 5 -- Socio administrador
           WHERE nrconbir = pr_nrconbir
             AND nrcbrsoc = pr_nrconbir
             AND nrsdtsoc = vr_nrseqdet
             AND nrcpfcgc = vr_crapcbd.nrcpfcgc
             AND intippes = 4
             AND cdbircon = rw_crapbir.cdbircon
             AND cdmodbir = rw_crapbir.cdmodbir;
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro ao alterar a CRAPCBD (administrador): '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        -- Se nao atualizou nada eh porque o administrador nao eh socio. 
        -- Neste caso deve-se adicionar como socio com ZERO cotas
        IF SQL%ROWCOUNT = 0 THEN
          -- Insere o registro de socio/administrador
          BEGIN
            INSERT INTO crapcbd
              (nrconbir,
               nrseqdet,
               cdbircon,
               cdmodbir,
               dtconbir,
               cdcooper,
               nrdconta,
               nrcpfcgc,
               inpessoa,
               nmtitcon,
               intippes,
               nrcbrsoc,
               nrsdtsoc,
               percapvt,
               pertotal,
               nrprotoc,
               inreterr,
               inreapro,
               dtentadm,
               dsvincul,
               dtmanadm)
             VALUES
              (pr_nrconbir,
               (SELECT MAX(nrseqdet)+1 FROM crapcbd WHERE nrconbir=pr_nrconbir),
               rw_crapbir.cdbircon,
               rw_crapbir.cdmodbir,
               SYSDATE,
               pr_cdcooper,
               0, --Numero da conta vazio, pois socio nao tem conta
               vr_crapcbd.nrcpfcgc,
               1,
               vr_crapcbd.nmtitcon,
               5, --Socio/Administrador
               pr_nrconbir,
               vr_nrseqdet,
               0,
               0,
               pr_nrprotoc,
               0,
               0,
               vr_crapcbd.dtentadm,
               vr_crapcbd.dsvincul,
               vr_crapcbd.dtmanadm);
          EXCEPTION
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
              CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
              vr_dscritic := 'Erro ao inserir na CRAPCBD (socio/adm): '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;
        
        -- Vai para a proxima consulta
        vr_contador_adm := vr_contador_adm + 1;

        -- Limpa o conteudo da variavel de registro
        vr_crapcbd := NULL;

      END LOOP;

------------- BUSCA OS DADOS DO CRAPPSA (Empresas Participantes) -------------

      -- Atualiza o contador de registro para o inicio
      vr_contador_psa := 1; 
      LOOP
        
        -- monta a tag principal
        vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/QUADRO_SOCIAL/LISTA_PARTICIPACAO/PARTICIPACAO['||vr_contador_psa||']/';

        -- Verifica se existe dados na consulta de participacao
        IF pr_retxml.existsnode(vr_nmtagaux||'DOCUMENTO') = 0 THEN  
          EXIT;        
        END IF;
        
        BEGIN
          -- Busca as informacoes
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DOC_PARTDA','N',vr_crappsa.nrcpfcgc, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'RAZ_SOC_PARTDA', 'S',vr_crappsa.nmempres, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DOCUMENTO',      'N',vr_nrcpfcgc_psa, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CIDADE',         'S',vr_crappsa.nmcidade, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'FUNCAO',         'S',vr_crappsa.nmvincul, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'PERC_PARTIC',    'N',vr_crappsa.pertotal, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro processo de empresas participantes-'||vr_contador||'-'||vr_contador_soc||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Verifica se ocorreu algum erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
       
        -- Busca a sequencia do socio da empresa
        OPEN cr_crapcbd_soc(vr_nrseqdet, vr_nrcpfcgc_psa, rw_crapbir.cdbircon, rw_crapbir.cdmodbir);
        FETCH cr_crapcbd_soc INTO rw_crapcbd_soc;
        -- Se nao encontrar o socio da empresa participante, cancelar o programa
        IF cr_crapcbd_soc%NOTFOUND THEN
          CLOSE cr_crapcbd_soc;
          -- Nao dar erro, apenas ignorar o registro
          --vr_dscritic := 'Socio com CPF: '||vr_nrcpfcgc_psa||' nao encontrado para empresa '||vr_crappsa.nmempres;
          --RAISE vr_exc_saida;
          -- Vai para a proxima consulta
          vr_contador_psa := vr_contador_psa + 1;
          -- Limpa o conteudo da variavel de registro
          vr_crappsa := NULL;
          CONTINUE;
        END IF;
        CLOSE cr_crapcbd_soc;

        -- Insere o registro de socio
        BEGIN
          INSERT INTO crappsa
            (nrconbir,
             nrseqdet,
             nrseqreg,
             nmempres,
             nmcidade,
             cdufende,
             pertotal,
             nrcpfcgc,
             nmvincul)
           VALUES
            (pr_nrconbir,
             rw_crapcbd_soc.nrseqdet,
             (SELECT nvl(MAX(nrseqreg),0)+1 FROM crappsa WHERE nrconbir=pr_nrconbir AND nrseqdet=rw_crapcbd_soc.nrseqdet),
             vr_crappsa.nmempres,
             fn_separa_cidade_uf(vr_crappsa.nmcidade,1),
             fn_separa_cidade_uf(vr_crappsa.nmcidade,2),
             vr_crappsa.pertotal,
             vr_crappsa.nrcpfcgc,
             vr_crappsa.nmvincul);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro ao inserir na CRAPPSA: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        -- Vai para a proxima consulta
        vr_contador_psa := vr_contador_psa + 1;

        -- Limpa o conteudo da variavel de registro
        vr_crappsa := NULL;

      END LOOP;


------------- BUSCA OS DADOS DO CRAPCBD (BACEN) -------------
     
      -- Atualiza o contador de registro para o inicio
        
      -- monta a tag principal
      vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/COMPORTAMENTOS/';

      BEGIN
        
        -- Busca o CPF
        IF pr_retxml.existsnode('//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/CONSULTA/DOCUMENTO') > 0 THEN  
          pc_busca_conteudo_campo(pr_retxml, '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/CONSULTA/DOCUMENTO',    'S',vr_crapcbd.nrcpfcgc, vr_dscritic);
        END IF;
        
        -- Verifica se existe dados na consulta do limite de credito
        IF pr_retxml.existsnode(vr_nmtagaux||'LIMITE_CREDITO/VAL_TOTAL') > 0 THEN  
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'LIMITE_CREDITO/VAL_TOTAL','N',vr_vltotsfn, vr_dscritic);
          vr_crapcbd.vltotsfn := nvl(vr_crapcbd.vltotsfn,0) + vr_vltotsfn;
        END IF;

        -- Verifica se existe dados na consulta de creditos a vencer
        IF pr_retxml.existsnode(vr_nmtagaux||'CREDITOS_VENCER/VAL_TOTAL') > 0 THEN  
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CREDITOS_VENCER/VAL_TOTAL','N',vr_vltotsfn, vr_dscritic);
          vr_crapcbd.vltotsfn := nvl(vr_crapcbd.vltotsfn,0) + vr_vltotsfn;
        END IF;

        -- Verifica se existe dados na consulta de creditos vencidos
        IF pr_retxml.existsnode(vr_nmtagaux||'CREDITOS_VENCIDOS/VAL_TOTAL') > 0 THEN  
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CREDITOS_VENCIDOS/VAL_TOTAL','N',vr_vltotsfn, vr_dscritic);
          vr_crapcbd.vltotsfn := nvl(vr_crapcbd.vltotsfn,0) + vr_vltotsfn;
          vr_crapcbd.vlopescr := vr_vltotsfn;
        END IF;

        -- PRJ 438 - INICIO - Valor total das operacoes vencidas dos ultimos 12 meses
        IF pr_retxml.existsnode(vr_nmtagaux||'CREDITOS_VENCIDOS/VPER_01D_14D') > 0 THEN  
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CREDITOS_VENCIDOS/VPER_01D_14D','N',vr_vltotsfn, vr_dscritic);
          vr_crapcbd.vlopesme := nvl(vr_crapcbd.vlopesme,0) + vr_vltotsfn;
        END IF;
        
        IF pr_retxml.existsnode(vr_nmtagaux||'CREDITOS_VENCIDOS/VPER_15D_30D') > 0 THEN  
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CREDITOS_VENCIDOS/VPER_15D_30D','N',vr_vltotsfn, vr_dscritic);
          vr_crapcbd.vlopesme := nvl(vr_crapcbd.vlopesme,0) + vr_vltotsfn;
        END IF;
        
        IF pr_retxml.existsnode(vr_nmtagaux||'CREDITOS_VENCIDOS/VPER_31D_60D') > 0 THEN  
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CREDITOS_VENCIDOS/VPER_31D_60D','N',vr_vltotsfn, vr_dscritic);
          vr_crapcbd.vlopesme := nvl(vr_crapcbd.vlopesme,0) + vr_vltotsfn;
        END IF;
        
        IF pr_retxml.existsnode(vr_nmtagaux||'CREDITOS_VENCIDOS/VPER_61D_90D') > 0 THEN  
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CREDITOS_VENCIDOS/VPER_61D_90D','N',vr_vltotsfn, vr_dscritic);
          vr_crapcbd.vlopesme := nvl(vr_crapcbd.vlopesme,0) + vr_vltotsfn;
        END IF;
        
        IF pr_retxml.existsnode(vr_nmtagaux||'CREDITOS_VENCIDOS/VPER_91D_120D') > 0 THEN  
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CREDITOS_VENCIDOS/VPER_91D_120D','N',vr_vltotsfn, vr_dscritic);
          vr_crapcbd.vlopesme := nvl(vr_crapcbd.vlopesme,0) + vr_vltotsfn;
        END IF;
        
        IF pr_retxml.existsnode(vr_nmtagaux||'CREDITOS_VENCIDOS/VPER_121D_150D') > 0 THEN  
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CREDITOS_VENCIDOS/VPER_121D_150D','N',vr_vltotsfn, vr_dscritic);
          vr_crapcbd.vlopesme := nvl(vr_crapcbd.vlopesme,0) + vr_vltotsfn;
        END IF;
        
        IF pr_retxml.existsnode(vr_nmtagaux||'CREDITOS_VENCIDOS/VPER_151D_180D') > 0 THEN  
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CREDITOS_VENCIDOS/VPER_151D_180D','N',vr_vltotsfn, vr_dscritic);
          vr_crapcbd.vlopesme := nvl(vr_crapcbd.vlopesme,0) + vr_vltotsfn;
        END IF;
        
        IF pr_retxml.existsnode(vr_nmtagaux||'CREDITOS_VENCIDOS/VPER_181D_240D') > 0 THEN  
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CREDITOS_VENCIDOS/VPER_181D_240D','N',vr_vltotsfn, vr_dscritic);
          vr_crapcbd.vlopesme := nvl(vr_crapcbd.vlopesme,0) + vr_vltotsfn;
        END IF;
        
        IF pr_retxml.existsnode(vr_nmtagaux||'CREDITOS_VENCIDOS/VPER_241D_300D') > 0 THEN  
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CREDITOS_VENCIDOS/VPER_241D_300D','N',vr_vltotsfn, vr_dscritic);
          vr_crapcbd.vlopesme := nvl(vr_crapcbd.vlopesme,0) + vr_vltotsfn;
        END IF;
        
        IF pr_retxml.existsnode(vr_nmtagaux||'CREDITOS_VENCIDOS/VPER_301D_360D') > 0 THEN  
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CREDITOS_VENCIDOS/VPER_301D_360D','N',vr_vltotsfn, vr_dscritic);
          vr_crapcbd.vlopesme := nvl(vr_crapcbd.vlopesme,0) + vr_vltotsfn;
        END IF;
        -- PRJ 438 - FIM - Valor total das operacoes vencidas dos ultimos 12 meses

        -- Verifica se existe dados na consulta de creditos a liberar
        IF pr_retxml.existsnode(vr_nmtagaux||'CREDITOS_LIBERAR/VAL_TOTAL') > 0 THEN  
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CREDITOS_LIBERAR/VAL_TOTAL','N',vr_vltotsfn, vr_dscritic);
          vr_crapcbd.vltotsfn := nvl(vr_crapcbd.vltotsfn,0) + vr_vltotsfn;
        END IF;

        -- Verifica se existe dados na consulta de creditos baixados com prejuizo
        IF pr_retxml.existsnode(vr_nmtagaux||'CREDITOS_BAIXADOS_PREJUIZOS/VAL_TOTAL') > 0 THEN  
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CREDITOS_BAIXADOS_PREJUIZOS/VAL_TOTAL','N',vr_vltotsfn, vr_dscritic);
          vr_crapcbd.vltotsfn := nvl(vr_crapcbd.vltotsfn,0) + vr_vltotsfn;
          vr_crapcbd.vlprejui := vr_vltotsfn;
        END IF;

        -- PRJ 438 - Valor total das operacoes em prejuizo dos ultimos 12 meses
        IF pr_retxml.existsnode(vr_nmtagaux||'CREDITOS_BAIXADOS_PREJUIZOS/VPER_01D_360D') > 0 THEN  
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'CREDITOS_BAIXADOS_PREJUIZOS/VPER_01D_360D','N',vr_vltotsfn, vr_dscritic);
          vr_crapcbd.vlprejme := vr_vltotsfn;
        END IF;

        -- Verifica se existe dados no resumo de informacoes do Bacen
        IF pr_retxml.existsnode(vr_nmtagaux||'INFORMACOES_BACEN/QTDE_INSTIT') > 0 OR
           pr_retxml.existsnode(vr_nmtagaux||'INFORMACOES_BACEN/QTDE_OPERAC') > 0 THEN  
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'INFORMACOES_BACEN/QTDE_INSTIT','N',vr_crapcbd.qtifoper, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'INFORMACOES_BACEN/QTDE_OPERAC','N',vr_crapcbd.qtopescr, vr_dscritic);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
          CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
          vr_dscritic := 'Erro processo BACEN-'||vr_contador||'-'||vr_contador_adm||': '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Verifica se ocorreu algum erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
        
      -- Atualiza o registro com as informacoes do Bacen
      BEGIN
        UPDATE crapcbd
           SET qtopescr = vr_crapcbd.qtopescr,
               qtifoper = vr_crapcbd.qtifoper,
               vltotsfn = vr_crapcbd.vltotsfn,
               vlopescr = vr_crapcbd.vlopescr,
               vlprejui = vr_crapcbd.vlprejui
         WHERE nrconbir = pr_nrconbir
           AND nrcpfcgc = vr_crapcbd.nrcpfcgc
           AND cdbircon = rw_crapbir.cdbircon;
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
          CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
          vr_dscritic := 'Erro ao alterar a CRAPCBD (bacen): '||SQLERRM;
          RAISE vr_exc_saida;
      END;
   
      -- PRJ 438 - Marcelo Telles Coelho - Mouts
      PC_INCLUI_MODALIDADE_BIRO (pr_retxml   => pr_retxml
                                ,pr_nrconbir => pr_nrconbir
                                ,pr_nrseqdet => vr_nrseqdet
                                ,pr_nrcpfcgc => vr_crapcbd.nrcpfcgc
                                ,pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      -- Fim PRJ 438
   
      -- Limpa o conteudo da variavel de registro
      vr_crapcbd := NULL;


------------- BUSCA OS DADOS DO CRAPRPF (Pendencias financeiras dos Socios) -------------
      -- Atualiza o contador de registro para o inicio
      vr_contador_rpf := 1; 
      LOOP
        
        -- monta a tag principal
        vr_nmtagaux := '//LISTA_RESPOSTAS/RESPOSTA['||vr_contador||']/DADOS/QUADRO_SOCIAL/LISTA_PENDENCIA_FINANCEIRA_SOCIO/PENDENCIA_FINANCEIRA_SOCIO['||vr_contador_rpf||']/';

        -- Verifica se existe dados na consulta da pendencias financeira
        IF pr_retxml.existsnode(vr_nmtagaux||'DOCUMENTO') = 0 THEN  
          EXIT;        
        END IF;
        
        -- Busca o CNPJ do socio
        pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DOCUMENTO',      'N',vr_nrcpfcgc_rpf, vr_dscritic);
        -- Verifica se ocorreu algum erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        -- Busca a sequencia do socio da empresa
        OPEN cr_crapcbd_soc(vr_nrseqdet, vr_nrcpfcgc_rpf, rw_crapbir.cdbircon, rw_crapbir.cdmodbir);
        FETCH cr_crapcbd_soc INTO rw_crapcbd_soc;
        -- Se nao encontrar o socio da empresa participante, cancelar o programa
        IF cr_crapcbd_soc%NOTFOUND THEN
          CLOSE cr_crapcbd_soc;
          vr_dscritic := 'Socio com CPF: '||vr_nrcpfcgc_psa||' nao encontrado para pendencia financeira';
          RAISE vr_exc_saida;
         
        END IF;
        CLOSE cr_crapcbd_soc;

        BEGIN
          -- Busca os dados do pefin
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'QTDE_PEFIN',  'N',vr_craprpf.qtnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'VL_PEFIN',    'N',vr_craprpf.vlnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_ULT_PEFIN','D',vr_craprpf.dtultneg, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro pendencia financeira PEFIN-'||vr_contador||'-'||vr_contador_rpf||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Insere a pendencia financeira
        pc_insere_craprpf(pr_nrconbir, rw_crapcbd_soc.nrseqdet, 2, vr_craprpf.qtnegati, 
                          vr_craprpf.vlnegati, vr_craprpf.dtultneg, vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Limpa o conteudo da variavel de registro
        vr_craprpf := NULL;

        BEGIN
          -- Busca os dados do refin
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'QTDE_REFIN',  'N',vr_craprpf.qtnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'VL_REFIN',    'N',vr_craprpf.vlnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_ULT_REFIN','D',vr_craprpf.dtultneg, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro pendencia financeira REFIN-'||vr_contador||'-'||vr_contador_rpf||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Insere a pendencia financeira
        pc_insere_craprpf(pr_nrconbir, rw_crapcbd_soc.nrseqdet, 1, vr_craprpf.qtnegati, 
                          vr_craprpf.vlnegati, vr_craprpf.dtultneg, vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Limpa o conteudo da variavel de registro
        vr_craprpf := NULL;

        BEGIN
          -- Busca os dados do protesto
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'QTDE_PROTESTO',  'N',vr_craprpf.qtnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'VL_PROTESTO',    'N',vr_craprpf.vlnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_ULT_PROTESTO','D',vr_craprpf.dtultneg, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro pendencia financeira protesto-'||vr_contador||'-'||vr_contador_rpf||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Insere a pendencia financeira
        pc_insere_craprpf(pr_nrconbir, rw_crapcbd_soc.nrseqdet, 3, vr_craprpf.qtnegati, 
                          vr_craprpf.vlnegati, vr_craprpf.dtultneg, vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Limpa o conteudo da variavel de registro
        vr_craprpf := NULL;

        BEGIN
          -- Busca os dados da acao judicial
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'QTDE_ACAO_JUD',  'N',vr_craprpf.qtnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'VL_ACAO_JUD',    'N',vr_craprpf.vlnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_ULT_ACAO_JUD','D',vr_craprpf.dtultneg, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro pendencia financeira acao judicial-'||vr_contador||'-'||vr_contador_rpf||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Insere a pendencia financeira
        pc_insere_craprpf(pr_nrconbir, rw_crapcbd_soc.nrseqdet, 4, vr_craprpf.qtnegati, 
                          vr_craprpf.vlnegati, vr_craprpf.dtultneg, vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Limpa o conteudo da variavel de registro
        vr_craprpf := NULL;

        BEGIN
          -- Busca os dados de participacao em falencia
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'QTDE_PART_FALEN',  'N',vr_craprpf.qtnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_ULT_PART_FALEN','D',vr_craprpf.dtultneg, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro pendencia financeira falencia-'||vr_contador||'-'||vr_contador_rpf||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Insere a pendencia financeira
        pc_insere_craprpf(pr_nrconbir, rw_crapcbd_soc.nrseqdet, 5, vr_craprpf.qtnegati, 
                          0, vr_craprpf.dtultneg, vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Limpa o conteudo da variavel de registro
        vr_craprpf := NULL;

        BEGIN
          -- Busca os dados de cheques sem fundo
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'QTDE_CHQ_FUNDO',  'N',vr_craprpf.qtnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'VL_CHQ_FUNDO',    'N',vr_craprpf.vlnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_ULT_CHQ_FUNDO','D',vr_craprpf.dtultneg, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro pendencia financeira Cheque sem fundo-'||vr_contador||'-'||vr_contador_rpf||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Insere a pendencia financeira
        pc_insere_craprpf(pr_nrconbir, rw_crapcbd_soc.nrseqdet, 6, vr_craprpf.qtnegati, 
                          vr_craprpf.vlnegati, vr_craprpf.dtultneg, vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Limpa o conteudo da variavel de registro
        vr_craprpf := NULL;
        
        BEGIN
          -- Busca os dados de cheques sustados e cancelados
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'QTDE_CHQ_SUSCAN',  'N',vr_craprpf.qtnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'VL_CHQ_SUSCAN',    'N',vr_craprpf.vlnegati, vr_dscritic);
          pc_busca_conteudo_campo(pr_retxml, vr_nmtagaux||'DT_ULT_CHQ_SUSCAN','D',vr_craprpf.dtultneg, vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
            vr_dscritic := 'Erro pendencia financeira cheque sustado-'||vr_contador||'-'||vr_contador_rpf||': '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Insere a pendencia financeira
        pc_insere_craprpf(pr_nrconbir, rw_crapcbd_soc.nrseqdet, 7, vr_craprpf.qtnegati, 
                          vr_craprpf.vlnegati, vr_craprpf.dtultneg, vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        -- Limpa o conteudo da variavel de registro
        vr_craprpf := NULL;
        
        
        -- Vai para a proxima consulta
        vr_contador_rpf := vr_contador_rpf + 1;

      END LOOP;


--------------------------------------------------------------------
      -- Vai para a proxima consulta
      vr_contador := vr_contador + 1;
    END LOOP;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;                                 

-- Rotina para atualizar o SCR das tabelas de consulta automatizada para as 
-- tabelas dos produtos
PROCEDURE pc_atualiza_scr(pr_nrconbir IN  crapcbd.nrconbir%TYPE, --> Numero da consulta do biro 
                          pr_cdcooper IN  crapepr.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                          pr_nrdconta IN  crapepr.nrdconta%TYPE, --> Numero da conta de emprestimo
                          pr_nrdocmto IN  crapepr.nrctremp%TYPE, --> Numero do documento a ser consultado
                          pr_inprodut IN  PLS_INTEGER,           --> Indicador de produto (1-Emprestimos, 2-Financiamentos, 3-Contrato limite cheque especial, 4-Contrato limite desconto de cheque, 5-Contrato Limite Desconto de Titulos)
                          pr_database IN DATE,                   --> DataBase da consulta do SCR 
                          pr_cdcritic OUT crapcri.cdcritic%TYPE, --> Critica encontrada
                          pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
    -- Cursor sobre as consultas de SCR                                    
    CURSOR cr_crapcbd IS
      SELECT a.intippes,
             a.nrdconta,
             a.nrcpfcgc,
             a.qtopescr,
             a.qtifoper,
             a.vltotsfn,
             a.vlopescr,
             a.vlprejui
        FROM crapcbd a
       WHERE a.nrconbir = pr_nrconbir
         AND a.cdbircon = 3; -- Biro do SCR

    -- Cursor sobre os dados do conjuge
    CURSOR cr_crapcje IS
      SELECT nvl(crapass.nrcpfcgc,crapcje.nrcpfcjg) nrcpfcjg
        FROM crapass,
             crapcje
       WHERE crapcje.cdcooper = pr_cdcooper
         AND crapcje.nrdconta = pr_nrdconta
         AND crapcje.idseqttl = 1
         AND crapass.cdcooper (+) = crapcje.cdcooper
         AND crapass.nrdconta (+) = crapcje.nrctacje
         AND (crapcje.nrcpfcjg <> 0 OR crapass.nrcpfcgc IS NOT NULL);
    rw_crapcje cr_crapcje%ROWTYPE;
    
    -- Variaveis de erro
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista

  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_atualiza_scr');  

    -- Busca os dados do conjuge
    OPEN cr_crapcje;
    FETCH cr_crapcje INTO rw_crapcje;
    CLOSE cr_crapcje;  
  
    -- Efetua loop sobre as consultas que foram feitas no SCR
    FOR rw_crapcbd IN cr_crapcbd LOOP
      -- Se for do titular
      IF rw_crapcbd.intippes = 1 THEN
        BEGIN
          UPDATE crapprp
             SET crapprp.dtdrisco = last_day(pr_database),
                 crapprp.qtopescr = nvl(rw_crapcbd.qtopescr,0),
                 crapprp.qtifoper = nvl(rw_crapcbd.qtifoper,0),
                 crapprp.vltotsfn = nvl(rw_crapcbd.vltotsfn,0),
                 crapprp.vlopescr = nvl(rw_crapcbd.vlopescr,0),
                 crapprp.vlrpreju = nvl(rw_crapcbd.vlprejui,0)
           WHERE crapprp.cdcooper = pr_cdcooper
             AND crapprp.nrdconta = pr_nrdconta
             AND crapprp.nrctrato = pr_nrdocmto
             AND crapprp.tpctrato = decode(pr_inprodut,1,90,
                                                       3,1);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
            vr_dscritic := 'Erro ao alterar a CRAPPRP (bacen-tit): '||SQLERRM;
            RAISE vr_exc_saida;
        END;
      ELSIF rw_crapcbd.intippes = 2 THEN  -- Se for avalistas
        -- Atualiza o SCR nos avalistas terceiros
        BEGIN
          UPDATE crapavt 
             SET dtdrisco = last_day(pr_database),
                 qtopescr = nvl(rw_crapcbd.qtopescr,0),
                 qtifoper = nvl(rw_crapcbd.qtifoper,0),
                 vltotsfn = nvl(rw_crapcbd.vltotsfn,0),
                 vlopescr = nvl(rw_crapcbd.vlopescr,0),
                 vlprejuz = nvl(rw_crapcbd.vlprejui,0)
           WHERE crapavt.cdcooper = pr_cdcooper
             AND crapavt.nrdconta = pr_nrdconta -- Utiliza a conta do documento
             AND crapavt.nrctremp = pr_nrdocmto
             AND crapavt.nrcpfcgc = rw_crapcbd.nrcpfcgc -- Utiliza o CPF/CNPJ do analisado
             AND crapavt.tpctrato = decode(pr_inprodut,3,3,  -- Limite de credito
                                                       1,1); -- Emprestimo   
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
            vr_dscritic := 'Erro ao alterar a CRAPAVT (bacen): '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Atualiza a tabela de avalista cooperado
        BEGIN
          UPDATE crapavl
             SET dtdrisco = last_day(pr_database),
                 qtopescr = nvl(rw_crapcbd.qtopescr,0),
                 qtifoper = nvl(rw_crapcbd.qtifoper,0),
                 vltotsfn = nvl(rw_crapcbd.vltotsfn,0),
                 vlopescr = nvl(rw_crapcbd.vlopescr,0),
                 vlprejuz = nvl(rw_crapcbd.vlprejui,0)
           WHERE crapavl.cdcooper = pr_cdcooper
             AND crapavl.nrctaavd = pr_nrdconta -- Utiliza a conta do analisado
             AND crapavl.nrctravd = pr_nrdocmto
             AND crapavl.nrdconta = rw_crapcbd.nrdconta -- Conta do avalista
             AND crapavl.tpctrato = decode(pr_inprodut,3,3, -- Limite de credito
                                                       1,1); -- Emprestimo   
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
            vr_dscritic := 'Erro ao alterar a CRAPAVL (bacen): '||SQLERRM;
            RAISE vr_exc_saida;
        END;
      END IF;

      IF rw_crapcbd.intippes = 3 OR -- Se for o conjuge, atualiza as informacoes do SCR no contrato para o mesmo
        (nvl(rw_crapcje.nrcpfcjg,-1) = rw_crapcbd.nrcpfcgc) THEN  -- Se o avalista for o conjuge, atualiza as informacoes do SCR no conjuge
        BEGIN
          UPDATE crapprp
             SET crapprp.dtoutris = last_day(pr_database),
                 crapprp.vlsfnout = nvl(rw_crapcbd.vltotsfn,0),
                 crapprp.qtopecje = nvl(rw_crapcbd.qtopescr,0),
                 crapprp.qtifocje = nvl(rw_crapcbd.qtifoper,0),
                 crapprp.vlopecje = nvl(rw_crapcbd.vlopescr,0),
                 crapprp.vlprjcje = nvl(rw_crapcbd.vlprejui,0)
           WHERE crapprp.cdcooper = pr_cdcooper
             AND crapprp.nrdconta = pr_nrdconta -- Utiliza a conta do titular do emprestimo
             AND crapprp.nrctrato = pr_nrdocmto
             AND crapprp.tpctrato = decode(pr_inprodut,1,90,
                                                       3,1);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
            vr_dscritic := 'Erro ao alterar a CRAPPRP (bacen-cje): '||SQLERRM;
            RAISE vr_exc_saida;
        END;
      END IF;
    END LOOP;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;                                 
  
-- Atualiza as tabelas de controle com as informacoes finais
PROCEDURE pc_atualiza_tab_controle(pr_nrconbir IN  crapcbd.nrconbir%TYPE, --> Numero da consulta do biro 
                                   pr_cdcritic OUT crapcri.cdcritic%TYPE, --> Critica encontrada
                                   pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

    -- Cursor somando o total das pendencias financeiras
    CURSOR cr_craprpf(pr_nrconbir craprpf.nrconbir%TYPE) IS
      SELECT crapprf.nrseqdet,
             decode(crapprf.inpefref,1,2,1) innegati,
             MAX(crapprf.dtvencto) dtultneg,
             SUM(crapprf.vlregist) vlnegati,
             COUNT(*)              qtnegati
        FROM crapprf -- Pefin / Refin
       WHERE crapprf.nrconbir = pr_nrconbir
       GROUP BY crapprf.nrseqdet, decode(crapprf.inpefref,1,2,1)
      UNION ALL
      SELECT crapprt.nrseqdet,
             3,
             MAX(crapprt.dtprotes),
             SUM(crapprt.vlprotes),
             COUNT(*)
        FROM crapprt -- Protestos
       WHERE crapprt.nrconbir = pr_nrconbir
       GROUP BY crapprt.nrseqdet
      UNION ALL
      SELECT crapabr.nrseqdet,
             4,
             MAX(crapabr.dtacajud),
             SUM(crapabr.vltotaca),
             COUNT(*)
        FROM crapabr -- Acoes
       WHERE crapabr.nrconbir = pr_nrconbir
        GROUP BY crapabr.nrseqdet
      UNION ALL
      SELECT craprfc.nrseqdet,
             5,
             MAX(craprfc.dtregist),
             0,
             COUNT(*)
        FROM craprfc -- Recuperacoes, falencias ou concordatas
       WHERE craprfc.nrconbir = pr_nrconbir
       GROUP BY craprfc.nrseqdet
      UNION ALL
      SELECT crapcsf.nrseqdet,
             decode(crapcsf.idsitchq,1,6,7),
             MAX(crapcsf.dtinclus) dtultneg,
             SUM(crapcsf.vlcheque) vlnegati,
             SUM(crapcsf.qtcheque) qtnegati
        FROM crapcsf -- Cheques sem fundo / Sinistrados ou Extraviados
       WHERE crapcsf.nrconbir = pr_nrconbir
       GROUP BY crapcsf.nrseqdet, decode(crapcsf.idsitchq,1,6,7)
      UNION ALL
      SELECT craprsc.nrseqdet,
             decode(craprsc.inlocnac,1,8,9), 
             MAX(craprsc.dtregist),
             SUM(craprsc.vlregist),
             COUNT(*)
        FROM craprsc -- SPC Local e SPC Nacional
       WHERE craprsc.nrconbir = pr_nrconbir
       GROUP BY craprsc.nrseqdet,
                decode(craprsc.inlocnac,1,8,9);

    -- Cursor para buscar a quantidade de registros processados e com erro
    CURSOR cr_crapcbd(pr_nrconbir crapcbd.nrconbir%TYPE) IS
      SELECT COUNT(*) qtconsul,
             SUM(inreterr) qterrcon,
             SUM(decode(inreapro,0,0,1)) qtreapro
        FROM crapcbd
       WHERE nrconbir = pr_nrconbir;
    rw_crapcbd cr_crapcbd%ROWTYPE;

    -- Variaveis de erro
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista

  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_atualiza_tab_controle');  

    -- Efetua a somatoria das pendencias financeiras 
    FOR rw_craprpf IN cr_craprpf(pr_nrconbir) LOOP
      BEGIN
        INSERT INTO craprpf
          (nrconbir,
           nrseqdet,
           innegati,
           qtnegati, 
           vlnegati,
           dtultneg)
         VALUES
          (pr_nrconbir,
           rw_craprpf.nrseqdet,
           rw_craprpf.innegati,
           rw_craprpf.qtnegati,
           rw_craprpf.vlnegati,
           rw_craprpf.dtultneg);
      EXCEPTION
        WHEN dup_val_on_index THEN
          NULL; -- Nao faz nada, pois o resumo ja veio do arquivo
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
          CECRED.pc_internal_exception (pr_cdcooper => null);  
          vr_dscritic := 'Erro ao inserir na CRAPRPF: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
    END LOOP;

    -- Busca o total de registros consultados
    OPEN cr_crapcbd(pr_nrconbir);
    FETCH cr_crapcbd INTO rw_crapcbd;
    CLOSE cr_crapcbd;

    -- Atualiza a capa da consulta, com a quantidade de registros consultados e com erro
    BEGIN
      UPDATE crapcbc
         SET qtconsul = nvl(rw_crapcbd.qtconsul,0),
             qterrcon = nvl(rw_crapcbd.qterrcon,0),
             qtreapro = nvl(rw_crapcbd.qtreapro,0)
       WHERE nrconbir = pr_nrconbir;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => null);  
        pr_dscritic := 'Erro ao atualizar a CRAPCBD: ' ||SQLERRM;
        RETURN;
    END;
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => null);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;

-- Rotina para montar o XML de solicitacao de consulta do CPF / CNPJ
PROCEDURE pc_monta_cpf_cnpj_envio(pr_xml  IN OUT XmlType,               --> XML que sera alterado
                                  pr_contador IN PLS_INTEGER,           --> Posicao em que a requisicao estara no XML
                                  pr_nmtagbir IN VARCHAR2,              --> Nome da tag de consulta para pessoa fisica
                                  pr_nrcpfcgc IN crapcbd.nrcpfcgc%TYPE, --> Numero do CPF/CGC que sera consultado
                                  pr_inpessoa IN VARCHAR2,              --> Indicador de pessoa (F=Fisica, J=Juridica)
                                  pr_cdpactra IN crapope.cdpactra%TYPE, --> PA de trabalho do operador
                                  pr_qthrsrpv IN PLS_INTEGER,           --> Quantidade de horas de reaproveitamento
                                  pr_dtconscr IN DATE,                  --> Data base para a consulta no SCR
                                  pr_nrcep    IN crapavt.nrcepend%TYPE,  --> Cep
                                  pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

                          
                                  
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_monta_cpf_cnpj_envio');  

    -- Envia o cabecalho e o tipo de consulta
    gene0007.pc_insere_tag(pr_xml => pr_xml, pr_tag_pai => 'LISTA_CONSULTA', pr_posicao => 0          , pr_tag_nova => 'CONSULTA',    pr_tag_cont => NULL, pr_des_erro => pr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_xml, pr_tag_pai => 'CONSULTA',       pr_posicao => pr_contador, pr_tag_nova => 'TIPO',        pr_tag_cont => pr_nmtagbir, pr_des_erro => pr_dscritic);

    -- Se for pessoa fisica, manda com 11 zeros a esquerda
    IF pr_inpessoa = 'F' THEN 
      gene0007.pc_insere_tag(pr_xml => pr_xml, pr_tag_pai => 'CONSULTA',       pr_posicao => pr_contador, pr_tag_nova => 'DOCUMENTO',   pr_tag_cont => lpad(pr_nrcpfcgc,11,'0'), pr_des_erro => pr_dscritic);
    ELSE -- Entao eh pessoa Juridica, envia com 14 zeros a esquerda
      gene0007.pc_insere_tag(pr_xml => pr_xml, pr_tag_pai => 'CONSULTA',       pr_posicao => pr_contador, pr_tag_nova => 'DOCUMENTO',   pr_tag_cont => lpad(pr_nrcpfcgc,14,'0'), pr_des_erro => pr_dscritic);
    END IF;
    
    -- Envia o tipo de pessoa
    gene0007.pc_insere_tag(pr_xml => pr_xml, pr_tag_pai => 'CONSULTA',       pr_posicao => pr_contador, pr_tag_nova => 'TIPO_PESSOA', pr_tag_cont => pr_inpessoa, pr_des_erro => pr_dscritic);
    
    -- Se possuir data de consulta SCR, entao deve-se enviar
    IF pr_dtconscr IS NOT NULL THEN
      gene0007.pc_insere_tag(pr_xml => pr_xml, pr_tag_pai => 'CONSULTA',       pr_posicao => pr_contador, pr_tag_nova => 'DATA_BASE',   pr_tag_cont => to_char(pr_dtconscr,'YYYYMM'), pr_des_erro => pr_dscritic);
    END IF;

    -- Envia o PA e a quantidade de horas de reaproveitamento
    gene0007.pc_insere_tag(pr_xml => pr_xml, pr_tag_pai => 'CONSULTA',       pr_posicao => pr_contador, pr_tag_nova => 'CENTRO_CUSTO',pr_tag_cont => pr_cdpactra, pr_des_erro => pr_dscritic);
    --Cep
    gene0007.pc_insere_tag(pr_xml => pr_xml, pr_tag_pai => 'CONSULTA',       pr_posicao => pr_contador, pr_tag_nova => 'CEP_END_RES',pr_tag_cont => pr_nrcep, pr_des_erro => pr_dscritic);    
    gene0007.pc_insere_tag(pr_xml => pr_xml, pr_tag_pai => 'CONSULTA',       pr_posicao => pr_contador, pr_tag_nova => 'HORA_REAPROVEITAMENTO',pr_tag_cont => pr_qthrsrpv, pr_des_erro => pr_dscritic);
  END;

-- Efetua a consulta ao biro da Ibratan para os emprestimos
PROCEDURE pc_solicita_consulta_biro(pr_cdcooper IN  crapepr.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                    pr_nrdconta IN  crapepr.nrdconta%TYPE, --> Numero da conta de emprestimo
                                    pr_nrdocmto IN  crapepr.nrctremp%TYPE, --> Numero do documento a ser consultado
                                    pr_inprodut IN  PLS_INTEGER,           --> Indicador de produto (1-Emprestimos, 2-Financiamentos, 3-Contrato limite cheque especial, 4-Contrato limite desconto de cheque, 5-Contrato Limite Desconto de Titulos)
                                    pr_cdoperad IN  crapope.cdoperad%TYPE, --> Operador que solicitou a consulta
                                    pr_flvalest IN  PLS_INTEGER DEFAULT 0, --> Valida se proposta esta na esteira de credito
                                    pr_cdcritic OUT crapcri.cdcritic%TYPE, --> Critica encontrada
                                    pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada


  ---------------------------------------------------------------------------------------------------------------
  --
  --                                                      Ultima atualizacao: 
  --
  --              06/06/2017 - Alteração da mensagem de retorno do cursor crawepr
  --                           pc_solicita_consulta_biro CH=660371
  --                         - Tratamento na chamada da pc_gera_log_batch CH=660433 / CH=660325
  --                         - Inclusão módulo e ação e rotina de loh no exception otheres - Chamado 663304
  --                           (Ana - Envolti) 06/06/2017
  --
  ---------------------------------------------------------------------------------------------------------------

    -- Cursor sobre os dados de emprestimo
    CURSOR cr_crawepr IS
      SELECT crawepr.nrctaav1,
             crawepr.nrctaav2,
             crawepr.inconcje, 
             crawepr.nrconbir,
             crawepr.vlemprst,
             crawepr.dtenvest,
             crawepr.cdlcremp,
             crawepr.cdfinemp
        FROM crawepr
       WHERE crawepr.cdcooper = pr_cdcooper
         AND crawepr.nrdconta = pr_nrdconta
         AND crawepr.nrctremp = pr_nrdocmto;
    
    -- Cursor sobre os dados de limite
    CURSOR cr_craplim IS
      SELECT craplim.nrctaav1,
             craplim.nrctaav2,
             craplim.inconcje, 
             craplim.nrconbir,
             craplim.vllimite
        FROM craplim
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.nrctrlim = pr_nrdocmto
         AND craplim.tpctrlim = 1; -- Limite de credito

    -- Buscar os dados do associado
    CURSOR cr_crapass(pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT crapass.nrcpfcgc,
             crapass.inpessoa,
             crapass.cdagenci,
             crapass.vllimcre
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;

    -- Busca os dados dos avalistas terceiros
    CURSOR cr_crapavt IS
      SELECT crapavt.nrcpfcgc,
             crapavt.inpessoa,
             crapavt.nrcepend
        FROM crapavt
       WHERE crapavt.cdcooper = pr_cdcooper
         AND crapavt.nrdconta = pr_nrdconta
         AND crapavt.nrctremp = pr_nrdocmto
         AND crapavt.tpctrato = 1; -- Emprestimo

    -- Cursor sobre os dados do conjuge
    CURSOR cr_crapcje IS
      SELECT crapcje.nrctacje,
             nvl(crapass.nrcpfcgc,crapcje.nrcpfcjg) nrcpfcjg
        FROM crapass,
             crapcje
       WHERE crapcje.cdcooper = pr_cdcooper
         AND crapcje.nrdconta = pr_nrdconta
         AND crapcje.idseqttl = 1
         AND crapass.cdcooper (+) = crapcje.cdcooper
         AND crapass.nrdconta (+) = crapcje.nrctacje
         AND (crapcje.nrcpfcjg <> 0 OR crapass.nrcpfcgc IS NOT NULL);

    -- Busca as tags para a consulta do biro
    CURSOR cr_crapmbr(pr_cdbircon crapmbr.cdbircon%TYPE,
                      pr_cdmodbir crapmbr.cdmodbir%TYPE) IS
      SELECT crapbir.nmtagbir ||'-'||crapmbr.nmtagmod,
             crapbir.dsbircon
        FROM crapbir, 
             crapmbr
       WHERE crapmbr.cdbircon = pr_cdbircon
         AND crapmbr.cdmodbir = pr_cdmodbir
         AND crapbir.cdbircon = crapmbr.cdbircon;

    -- Busca as tags do SCR
    CURSOR cr_crapmbr_2 IS
      SELECT crapmbr.cdbircon,
             crapmbr.cdmodbir,
             crapbir.nmtagbir ||'-'||crapmbr.nmtagmod,
             crapbir.dsbircon
        FROM crapbir, 
             crapmbr
       WHERE crapmbr.nrordimp = 0 -- Consulta do SCR
         AND crapbir.cdbircon = crapmbr.cdbircon;

    -- Busca os dados do operador
    CURSOR cr_crapope IS
      SELECT crapope.cdpactra
        FROM crapope
       WHERE crapope.cdcooper = pr_cdcooper
         AND upper(crapope.cdoperad) = upper(pr_cdoperad);
    rw_crapope cr_crapope%ROWTYPE;
    
    -- Cursor para verificacao de existencia de consulta no SCR
    CURSOR cr_crapopf(pr_nrcpfcgc crapopf.nrcpfcgc%TYPE) IS
      SELECT 1
        FROM crapopf
       WHERE crapopf.nrcpfcgc = pr_nrcpfcgc;
    rw_crapopf cr_crapopf%ROWTYPE;

    -- Cursor para buscar a maior data de consulta no SCR
    CURSOR cr_crapopf_max IS
      SELECT MAX(crapopf.dtrefere)
        FROM crapopf;

    -- Cursor de verificacao de contingencia de biro
    CURSOR cr_crapcbr(pr_cdbircon crapcbr.cdbircon%TYPE) IS
      SELECT 1
        FROM crapcbr
       WHERE cdcooper = pr_cdcooper
         AND cdbircon = pr_cdbircon
         AND dtinicon <= trunc(SYSDATE);
    rw_crapcbr cr_crapcbr%ROWTYPE;
         
    -- Cursor para busca do tempo de reaproveitamento
    CURSOR cr_craprbi(pr_inprodut craprbi.inprodut%TYPE,
                      pr_inpessoa craprbi.inpessoa%TYPE) IS
      SELECT craprbi.qtdiarpv,
             craprbi.qtdiarpv * 24 qthrsrpv
        FROM craprbi
       WHERE craprbi.cdcooper = pr_cdcooper
         AND craprbi.inprodut = pr_inprodut
         AND craprbi.inpessoa = pr_inpessoa;
        
    -- Cursor para buscar CEP tbcadast_pessoa                              
      cursor c_cep(p_tppessoa in number,
                   p_nrcpfcgc in number) is
      select pe.nrcep 
        from tbcadast_pessoa p,
             tbcadast_pessoa_endereco pe
       where p.idpessoa = pe.idpessoa
         and p.tppessoa = p_tppessoa
         and pe.tpendereco = decode(p.tppessoa,1,10,2,9)
         and p.nrcpfcgc = p_nrcpfcgc
         and nvl(pe.nrcep,0) > 0;

    -- Cursor para buscar CEP Avalistas                              
      cursor c_cep_avt(p_nrcpfcgc in number) is
      select a.nrcepend 
        from crapavt a 
       where a.cdcooper = pr_cdcooper 
         and a.nrdconta = pr_nrdconta
         and a.nrctremp = pr_nrdocmto
         and a.nrcpfcgc = p_nrcpfcgc
         and nvl(a.nrcepend,0) > 0;         
         
    -- Busca cep crapenc 
      cursor c_crapenc(p_nrdconta in number) is
      select e.nrcepend
        from crapenc e
       where e.cdcooper = pr_cdcooper
         and e.nrdconta = p_nrdconta
         and e.idseqttl = 1
         ORDER BY decode(e.tpendass,10,1,2);
         
        
    -- Monta o registro de data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Variaveis de erro
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_dscritic_aux VARCHAR2(4000); --> descricao do erro
    vr_dscritic_padrao VARCHAR2(400); --> descricao do erro padrao para nao exibir erros tecnicos para o usuario
    vr_exc_saida  EXCEPTION; --> Excecao prevista
    vr_des_erro   VARCHAR2(10);

    -- Variaveis gerais
    vr_xmlenv   XMLtype;               --> XML de envio
    vr_xmlret   XMLtype;               --> XML de retorno
    vr_contador PLS_INTEGER;           --> Contador do xml de envio
    vr_qtenvreq PLS_INTEGER;           --> Contador de envio de requisicoes
    vr_nrprotoc crapcbd.nrprotoc%TYPE; --> Numero do protocolo do envio da requisicao
    vr_inconscr PLS_INTEGER := 0;      --> Indicador de consulta de SCR do titular
    
    vr_nrconbir crapcbd.nrconbir%TYPE; --> Numero da consulta no biro
    vr_nrseqdet crapcbd.nrseqdet%TYPE; --> Numero da sequencia da consulta no biro

    vr_nrctaav1 crawepr.nrctaav1%TYPE; --> Numero da conta do avalista 1
    vr_nrctaav2 crawepr.nrctaav2%TYPE; --> Numero da conta do avalista 2
    vr_inconcje crawepr.inconcje%TYPE; --> Indicador se deve consultar o conjuge
    vr_nrconbir_dct crapcbd.nrconbir%TYPE; --> Numero da consulta do biro que esta cadastrada no documento
    vr_vlprodut crawepr.vlemprst%TYPE; --> Valor do produto que esta sendo utilizado
    vr_dsprodut VARCHAR2(100);         --> Descricao do produto que sera utilizado

    vr_nrcpfcgc crapcbd.nrcpfcgc%TYPE; --> Numero do CPF/CGC da conta principal
    vr_nrcepend tbcadast_pessoa_endereco.nrcep%TYPE; --> Número do Cep do titular da Conta
    vr_cdagenci crapass.cdagenci%TYPE; --> Codigo da agencia do cooperado
    vr_vllimcre crapass.vllimcre%TYPE; --> Valor do limite de credito cadastrado para o associado
    vr_vlemprst crawepr.vlemprst%TYPE; --> Valor total de emprestimo que o cooperado possui
    vr_inpessoa crapcbd.inpessoa%TYPE; --> Indicador de pessoa fisica ou juridica da conta principal
    vr_inpessoa_txt VARCHAR2(01);      --> Indicador de pessoa fisica ou juridica da conta principal, mas em formato texto (F ou J)
    vr_contador_scr PLS_INTEGER;           --> Contador de execucoes do SCR
    vr_inpessoa_scr crapcbd.inpessoa%TYPE; --> Indicador de pessoa fisica ou juridica do SCR
    vr_intippes_scr crapcbd.intippes%TYPE; --> Indicador de tipo de pessoa mo SCR
    vr_cdbircon_tit crapcbd.cdbircon%TYPE; --> Biro de consulta para o titular da conta
    vr_cdmodbir_tit crapcbd.cdmodbir%TYPE; --> Modalidade do biro de consulta para o titular da conta
    
    vr_nrdconta_scr crapcbd.nrdconta%TYPE := 0;--> Numero da conta do avalista utilizado no SCR
    vr_nrcpfcgc_scr crapcbd.nrcpfcgc%TYPE; --> Numero do CPF/CGC do avalista utilizado no SCR
    vr_nrcepend_scr tbcadast_pessoa_endereco.nrcep%TYPE; --> Número do Cep SCR
    vr_nrdconta_av1 crapcbd.nrdconta%TYPE := 0;--> Numero da conta do avalista 1
    vr_nrcpfcgc_av1 crapcbd.nrcpfcgc%TYPE; --> Numero do CPF/CGC do avalista 1
    vr_cdagenci_av1 crapass.cdagenci%TYPE; --> Codigo da agencia do avalista 1
    vr_vllimcre_av1 crapass.vllimcre%TYPE; --> Valor do limite de credito cadastrado para o avalista 1
    vr_inpessoa_av1 crapcbd.inpessoa%TYPE; --> Indicador de pessoa fisica ou juridica do avalista 1
    vr_cdbircon_av1 crapcbd.cdbircon%TYPE; --> Biro de consulta para o avalista 1
    vr_cdmodbir_av1 crapcbd.cdmodbir%TYPE; --> Modalidade do biro de consulta para o avalista 1
    vr_nrconbir_av1 crapcbd.nrconbir%TYPE; --> Numero da consulta do biro do avalista 1
    vr_nrseqdet_av1 crapcbd.nrseqdet%TYPE; --> Numero da sequencia da consulta do biro do avalista 1
    vr_nrcepend_av1 crapavt.nrcepend%TYPE; --> Numero Cep do Endereco do avalista 1
    
    
    vr_nrdconta_av2 crapcbd.nrdconta%TYPE := 0; --> Numero da conta do avalista 2
    vr_nrcpfcgc_av2 crapcbd.nrcpfcgc%TYPE; --> Numero do CPF/CGC do avalista 2
    vr_cdagenci_av2 crapass.cdagenci%TYPE; --> Codigo da agencia do avalista 2
    vr_vllimcre_av2 crapass.vllimcre%TYPE; --> Valor do limite de credito cadastrado para o avalista 2
    vr_inpessoa_av2 crapcbd.inpessoa%TYPE; --> Indicador de pessoa fisica ou juridica do avalista 2
    vr_cdbircon_av2 crapcbd.cdbircon%TYPE; --> Biro de consulta para o avalista 2
    vr_cdmodbir_av2 crapcbd.cdmodbir%TYPE; --> Modalidade do biro de consulta para o avalista 2
    vr_nrconbir_av2 crapcbd.nrconbir%TYPE; --> Numero da consulta do biro do avalista 2
    vr_nrseqdet_av2 crapcbd.nrseqdet%TYPE; --> Numero da sequencia da consulta do biro do avalista 2
    vr_nrcepend_av2 crapavt.nrcepend%TYPE; --> Numero Cep do Endereco do avalista 2
    
    vr_nrdconta_cje crapcbd.nrdconta%TYPE; --> Numero da conta do conjuge
    vr_nrcpfcgc_cje crapcbd.nrcpfcgc%TYPE; --> Numero do CPF/CGC do conjuge
    vr_nrcepend_cje tbcadast_pessoa_endereco.Nrcep%TYPE; --> Número do Cep do titular da Conta

    vr_cdbircon_pf  crapcbd.cdbircon%TYPE; --> Biro de consulta para pessoa fisica
    vr_cdmodbir_pf  crapcbd.cdmodbir%TYPE; --> Modalidade do biro de consulta para pessoa fisica
    vr_dsbircon_pf  crapbir.dsbircon%TYPE; --> Nome do biro de consultas para pessoa fisica
    vr_nmtagbir_pf  VARCHAR2(100);         --> Nome da tag de consulta para pessoa fisica
    vr_qthrsrpv_pf  PLS_INTEGER;           --> Quantidade de horas de reaproveitamento para pessoa fisica
    vr_qtdiarpv_pf  PLS_INTEGER;           --> Quantidade de dias de reaproveitamento para pessoa fisica
    vr_qtdiarpv_scr PLS_INTEGER;           --> Quantidade de dias de reaproveitamento para SCR
    vr_cdbircon_pj  crapcbd.cdbircon%TYPE; --> Biro de consulta para pessoa juridica
    vr_cdmodbir_pj  crapcbd.cdmodbir%TYPE; --> Modalidade do biro de consulta para pessoa juridica
    vr_dsbircon_pj  crapbir.dsbircon%TYPE; --> Nome do biro de consultas para pessoa juridica
    vr_nmtagbir_pj  VARCHAR2(100);         --> Nome da tag de consulta para pessoa juridica
    vr_qthrsrpv_pj  PLS_INTEGER;           --> Quantidade de horas de reaproveitamento para pessoa juridica
    vr_qtdiarpv_pj  PLS_INTEGER;           --> Quantidade de dias de reaproveitamento para pessoa juridica
    vr_qthrsrpv_scr PLS_INTEGER;           --> Quantidade de horas de reaproveitamento para o SCR
    vr_cdbircon_scr crapcbd.cdbircon%TYPE; --> Biro de consulta para o SCR
    vr_cdmodbir_scr crapcbd.cdmodbir%TYPE; --> Modalidade do biro de consulta para o SCR
    vr_nmtagbir_scr VARCHAR2(100);         --> Nome da tag de consulta para o SCR
    vr_dsbircon_scr crapbir.dsbircon%TYPE; --> Nome do biro de consultas para o SCR
    vr_dtconmax_scr DATE;                  --> Maior data de consulta no SCR
    vr_inreapro     PLS_INTEGER;           --> Indicador se ocorreu reaproveitamento nos avalistas
    
    vr_dtenvest     crawepr.dtenvest%TYPE := NULL; --> Data de envio da proposta esteira
    vr_cdlcremp     crawepr.cdlcremp%type := NULL; --> Linha de Credito da Proposta
    vr_cdfinemp     crawepr.cdfinemp%TYPE := NULL; --> Finalidade do Credito da Proposta
    vr_inobriga     varchar2(1);                   --> Se a proposta deve passar por analise automatica
    
  BEGIN
    GENE0001.pc_informa_acesso(pr_module => 'ATENDA'
  	                          ,pr_action => 'SSPC0001.pc_solicita_consulta_biro');

    -- Monta a descricao do produto que sera utilizado
    IF pr_inprodut = 1 THEN
      vr_dsprodut := '01-Emprestimo';
    ELSIF pr_inprodut = 3 THEN
      vr_dsprodut := '03-Limite Credito';
    ELSIF pr_inprodut = 6 THEN
      vr_dsprodut := '06-Cadastro Conta';
    END IF;

    -- Busca a data
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- Popula as variaveis do titular da consulta
    OPEN cr_crapass(pr_nrdconta);
    FETCH cr_crapass INTO vr_nrcpfcgc, vr_inpessoa, vr_cdagenci, vr_vllimcre;
    IF cr_crapass%NOTFOUND THEN
      vr_dscritic := 'Nao foi possivel encontrar a conta do titular';
      CLOSE cr_crapass;
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapass;

    --Busca Cep do Titular
    vr_nrcepend := null;
    open c_cep(vr_inpessoa,vr_nrcpfcgc);
     fetch c_cep into vr_nrcepend;
      if c_cep%notfound then
       open c_crapenc(pr_nrdconta); 
        fetch c_crapenc into vr_nrcepend;
       close c_crapenc;
      end if;
    close c_cep;

    -- Busca os dados de emprestimo
    IF pr_inprodut = 1 THEN
      OPEN cr_crawepr;
      FETCH cr_crawepr INTO vr_nrctaav1,
                            vr_nrctaav2, 
                            vr_inconcje, 
                            vr_nrconbir_dct,
                            vr_vlprodut,
                            vr_dtenvest,
                            vr_cdlcremp,
                            vr_cdfinemp;    
      
      -- Se nao encontrar o emprestimo, retorna com erro
      --Alterada mensagem CH=660371
      IF cr_crawepr%NOTFOUND THEN
        vr_dscritic := 'Contrato de Emprestimo inexistente. Favor verificar!';

        CLOSE cr_crawepr;
        RAISE vr_exc_saida;
      END IF;
      -- Fecha o cursor de emprestimo
      CLOSE cr_crawepr;
      
      --> Verificar se a Esteira esta em contigencia para a cooperativa
      este0001.pc_obrigacao_analise_automatic(pr_cdcooper => pr_cdcooper
                                             ,pr_inpessoa => vr_inpessoa
                                             ,pr_cdfinemp => vr_cdfinemp
                                             ,pr_cdlcremp => vr_cdlcremp
                                             ,pr_inobriga => vr_inobriga
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
      -- Se não foi possivel verificar
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN 
        RAISE vr_exc_saida;      
      END IF;
      
      -- Verificar se deve realizar validacao Esteira e se a Proposta deve passar por lá
      IF pr_flvalest = 1 AND vr_inobriga = 'S' THEN 
        vr_dscritic := 'Consulta não permitida - As Consultas desta Proposta só podem ser efetuadas pela Analise Automática da Esteira de Crédito!';
        RAISE vr_exc_saida;
      END IF;      
      
      
    ELSIF pr_inprodut = 3 THEN
      OPEN cr_craplim;
      FETCH cr_craplim INTO vr_nrctaav1,
                            vr_nrctaav2, 
                            vr_inconcje, 
                            vr_nrconbir_dct,
                            vr_vlprodut;    
      
      -- Se nao encontrar o emprestimo, retorna com erro
      IF cr_craplim%NOTFOUND THEN
        vr_dscritic := 'Limite inexistente. Favor verificar!';
        CLOSE cr_craplim;
        RAISE vr_exc_saida;
      END IF;
      -- Fecha o cursor de emprestimo
      CLOSE cr_craplim;
    ELSIF pr_inprodut = 6 THEN -- Abertura de conta
      vr_inconcje := 0;
      vr_vlprodut := 0;
      vr_nrconbir_dct := 0;
    END IF;
    
    -- Busca os dados do operador
    OPEN cr_crapope;
    FETCH cr_crapope INTO rw_crapope;
    -- Se nao encontrar o operador, retorna com erro
    IF cr_crapope%NOTFOUND THEN
      vr_dscritic := 'Operador '||pr_cdoperad|| ' inexistente. Favor verificar!';
      CLOSE cr_crapope;
      RAISE vr_exc_saida;
    END IF;
    -- Fecha o cursor de operador
    CLOSE cr_crapope;
    
    -- Busca o valor acumulado de emprestimo que o cooperado possui
    gene0005.pc_saldo_utiliza (pr_cdcooper => pr_cdcooper
                              ,pr_tpdecons => 3
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => 0
                              ,pr_cdoperad => 0
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrcpfcgc => vr_nrcpfcgc
                              ,pr_idseqttl => 1 
                              ,pr_idorigem => NULL
                              ,pr_dsctrliq => NULL
                              ,pr_cdprogra => 'SSPC0001'
                              ,pr_tab_crapdat => rw_crapdat
                              ,pr_inusatab => TRUE
                              ,pr_vlutiliz => vr_vlemprst
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
      -- Se for erro 9, entao o associado esta com data de eliminacao preenchida.
      -- Neste caso nao deve dar erro, e sim considerar como valor zerado
      IF nvl(vr_cdcritic,0) = 9 THEN
        vr_vlemprst := 0;
        vr_cdcritic := 0;
        vr_dscritic := NULL;
      ELSE
        vr_dscritic_padrao := 'Houve erro no acesso ao biro (SPC/Serasa/SCR), consulta nao realizada!';
        RAISE vr_exc_saida;
      END IF;
    END IF;

    -- Atualiza o valor do emprestimo/limite no valor retornado
    vr_vlemprst := nvl(vr_vlemprst,0) + nvl(vr_vlprodut,0);

    -- Se for de limite de credito, deve-se subtrair o valor do limite ja existente
    IF pr_inprodut = 3 THEN
      vr_vlemprst := vr_vlemprst - vr_vllimcre;
    END IF;
    
    -- Busca os dados do avalista 1 --
    -- Verifica se o avalista possui conta na cooperativa
    IF nvl(vr_nrctaav1,0) <> 0 THEN
      -- Popula as variaveis do avalista 1
      vr_nrdconta_av1 := vr_nrctaav1;
      OPEN cr_crapass(vr_nrdconta_av1);
      FETCH cr_crapass INTO vr_nrcpfcgc_av1, vr_inpessoa_av1, vr_cdagenci_av1, vr_vllimcre_av1;
      IF cr_crapass%NOTFOUND THEN
        vr_dscritic := 'Nao foi possivel encontrar a conta do avalista 1';
        CLOSE cr_crapass;
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapass;
      --Buscar Cep
      -- Se possuir conta, podes buscar da TBCADAST_PESSOA
      vr_nrcepend_av1 := null;
      open c_cep(vr_inpessoa_av1,vr_nrcpfcgc_av1);
       fetch c_cep into vr_nrcepend_av1;
      if c_cep%notfound then
        --Tipo endereco(9-Comercial,10-Residencial,11-Progrid,12-Corresp)
        open c_crapenc(vr_nrdconta_av1); 
        fetch c_crapenc into vr_nrcepend_av1;
        close c_crapenc;
      end if;       
      close c_cep;     
    END IF;

    -- Busca os dados do avalista 2 --
    -- Verifica se o avalista possui conta na cooperativa
    IF nvl(vr_nrctaav2,0) <> 0 THEN
      -- Popula as variaveis do avalista 2
      vr_nrdconta_av2 := vr_nrctaav2;
      OPEN cr_crapass(vr_nrdconta_av2);
      FETCH cr_crapass INTO vr_nrcpfcgc_av2, vr_inpessoa_av2, vr_cdagenci_av2, vr_vllimcre_av2;
      IF cr_crapass%NOTFOUND THEN
        vr_dscritic := 'Nao foi possivel encontrar a conta do avalista 2';
        CLOSE cr_crapass;
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapass;
      --Buscar Cep
      -- Se possuir conta, podes buscar da TBCADAST_PESSOA
      vr_nrcepend_av2 := null;
      open c_cep(vr_inpessoa_av2,vr_nrcpfcgc_av2);
       fetch c_cep into vr_nrcepend_av2;
        if c_cep%notfound then
         open c_crapenc(vr_nrdconta_av2); 
          fetch c_crapenc into vr_nrcepend_av2;
         close c_crapenc;
        end if;       
      close c_cep;       
    END IF;

    -- Busca os avalistas terceiros
    FOR rw_crapavt IN cr_crapavt LOOP
      -- Se nao tiver avalista 1, utiliza o avalista terceiro para jogar neste local
      IF nvl(vr_nrdconta_av1,0) = 0 AND vr_nrcpfcgc_av1 IS NULL THEN
        vr_nrcpfcgc_av1 := rw_crapavt.nrcpfcgc;
        vr_inpessoa_av1 := rw_crapavt.inpessoa;
        vr_nrcepend_av1 := rw_crapavt.nrcepend; --Cep
      ELSIF nvl(vr_nrdconta_av2,0) = 0 THEN -- Se nao tiver avalista 2
        vr_nrcpfcgc_av2 := rw_crapavt.nrcpfcgc;
        vr_inpessoa_av2 := rw_crapavt.inpessoa;
        vr_nrcepend_av2 := rw_crapavt.nrcepend; --Cep
      END IF;
    END LOOP;
    
    -- Se for para consultar conjuge, busca os dados do conjuge
    IF vr_inconcje = 1 THEN
      OPEN cr_crapcje;
      FETCH cr_crapcje INTO vr_nrdconta_cje, vr_nrcpfcgc_cje;
      CLOSE cr_crapcje;
      --Busca Cep do Conjuge
      vr_nrcepend_cje := null;
      open c_cep(1,vr_nrcpfcgc_cje);--Pessoa Física 
       fetch c_cep into vr_nrcepend_cje;
      close c_cep;
    END IF;

    -- Se possuir alguma pessoa fisica
    IF vr_inpessoa = 1 OR vr_inpessoa_av1 = 1 OR vr_inpessoa_av2 = 1 THEN
      -- Verifica qual o biro de consulta
      SSPC0001.pc_busca_modalidade_prm(pr_cdcooper => pr_cdcooper,
                                       pr_inprodut => pr_inprodut,
                                       pr_inpessoa => 1, -- Pessoa fisica
                                       pr_vlprodut => vr_vlemprst,
                                       pr_cdbircon => vr_cdbircon_pf,
                                       pr_cdmodbir => vr_cdmodbir_pf);
      -- Busca o nome da tag para pessoa fisica
      OPEN cr_crapmbr(vr_cdbircon_pf, vr_cdmodbir_pf);
      FETCH cr_crapmbr INTO vr_nmtagbir_pf, vr_dsbircon_pf;
      IF cr_crapmbr%NOTFOUND THEN
        vr_dscritic := 'TAG para pessoa fisica nao encontrada!';
        CLOSE cr_crapmbr;
        RAISE vr_exc_saida;
      END iF;
      CLOSE cr_crapmbr;
      
      -- Verifica se o BIRO esta em CONTINGENCIA
      OPEN cr_crapcbr(vr_cdbircon_pf);
      FETCH cr_crapcbr INTO rw_crapcbr;
      -- Se encontrou, deve-se cancelar a consulta
      IF cr_crapcbr%FOUND THEN
        CLOSE cr_crapcbr;
        vr_dscritic := 'Atencao! As consultas SPC/Serasa/SCR foram desabilitadas na proposta. Efetue as consultas manualmente.';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapcbr;

      -- Busca a quantidade de horas de reaproveitamento
      OPEN cr_craprbi(pr_inprodut, 
                      1); -- Pessoa Fisica
      FETCH cr_craprbi INTO vr_qtdiarpv_pf, vr_qthrsrpv_pf;
      -- Se encontrou, deve-se cancelar a consulta
      IF cr_craprbi%NOTFOUND THEN
        CLOSE cr_craprbi;
        vr_dscritic := 'Nao existe tempo de reaproveitamento cadastrado para pessoa fisica!';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_craprbi;
      
    END IF;
    
    -- Se possuir alguma pessoa juridica
    IF vr_inpessoa = 2 OR vr_inpessoa_av1 = 2 OR vr_inpessoa_av2 = 2 THEN
      -- Verifica qual o biro de consulta
      pc_busca_modalidade_prm(pr_cdcooper => pr_cdcooper,
                              pr_inprodut => pr_inprodut,
                              pr_inpessoa => 2, -- Pessoa juridica
                              pr_vlprodut => vr_vlemprst,
                              pr_cdbircon => vr_cdbircon_pj,
                              pr_cdmodbir => vr_cdmodbir_pj);
      -- Busca o nome da tag para pessoa juridica
      OPEN cr_crapmbr(vr_cdbircon_pj, vr_cdmodbir_pj);
      FETCH cr_crapmbr INTO vr_nmtagbir_pj, vr_dsbircon_pj;
      IF cr_crapmbr%NOTFOUND THEN
        vr_dscritic := 'TAG para pessoa juridica nao encontrada!';
        CLOSE cr_crapmbr;
        RAISE vr_exc_saida;
      END iF;
      CLOSE cr_crapmbr;

      -- Verifica se o BIRO esta em CONTINGENCIA
      OPEN cr_crapcbr(vr_cdbircon_pj);
      FETCH cr_crapcbr INTO rw_crapcbr;
      -- Se encontrou, deve-se cancelar a consulta
      IF cr_crapcbr%FOUND THEN
        CLOSE cr_crapcbr;
        vr_dscritic := 'Atencao! As consultas SPC/Serasa/SCR foram desabilitadas na proposta. Efetue as consultas manualmente.';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapcbr;

      -- Busca a quantidade de horas de reaproveitamento para PJ
      OPEN cr_craprbi(pr_inprodut,
                      2); -- Pessoa Juridica
      FETCH cr_craprbi INTO vr_qtdiarpv_pj, vr_qthrsrpv_pj;
      -- Se encontrou, deve-se cancelar a consulta
      IF cr_craprbi%NOTFOUND THEN
        CLOSE cr_craprbi;
        vr_dscritic := 'Nao existe tempo de reaproveitamento cadastrado para pessoa juridica!';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_craprbi;

    END IF;
    
    -- Busca a tag do SCR
    OPEN cr_crapmbr_2;
    FETCH cr_crapmbr_2 INTO vr_cdbircon_scr, vr_cdmodbir_scr, vr_nmtagbir_scr, vr_dsbircon_scr;
    IF cr_crapmbr_2%NOTFOUND THEN
      vr_dscritic := 'Nao encontrado a tag do SCR';
      CLOSE cr_crapmbr_2;
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapmbr_2;

    -- Busca a maior data de consulta no SCR
    OPEN cr_crapopf_max;
    FETCH cr_crapopf_max INTO vr_dtconmax_scr;
    CLOSE cr_crapopf_max;

    -- Verifica se o BIRO esta em CONTINGENCIA
    OPEN cr_crapcbr(vr_cdbircon_scr);
    FETCH cr_crapcbr INTO rw_crapcbr;
    -- Se encontrou, deve-se cancelar a consulta
    IF cr_crapcbr%FOUND THEN
      CLOSE cr_crapcbr;
      CLOSE cr_crapopf;
      vr_dscritic := 'Atencao! As consultas SPC/Serasa/SCR foram desabilitadas na proposta. Efetue as consultas manualmente.';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapcbr;

    -- Se o titular for CPF, deve-se verificar se tem que consultar SCR
    IF vr_inpessoa = 1 THEN      
      -- define o biro e a modalidade de consulta do titular para PF
      vr_cdbircon_tit := vr_cdbircon_pf;
      vr_cdmodbir_tit := vr_cdmodbir_pf;
    ELSE     
      -- define o biro e a modalidade de consulta do titular para PJ
      vr_cdbircon_tit := vr_cdbircon_pj;
      vr_cdmodbir_tit := vr_cdmodbir_pj;
    END IF; 

    -- Busca a proxima numeracao para consulta do biro
    vr_nrconbir := fn_sequence(pr_nmtabela => 'CRAPCBC', pr_nmdcampo => 'NRCONBIR',pr_dsdchave => '0');

    -- Insere a capa da consulta de biro
    BEGIN
      INSERT INTO crapcbc
        (nrconbir,
         cdcooper,
         dtconbir,
         qtreapro,
         qterrcon,
         qtconsul,
         inprodut,
         dshiscon,
         cdoperad,
         cdpactra)
       VALUES
        (vr_nrconbir,
         pr_cdcooper,
         SYSDATE,
         0,
         0,
         0,
         pr_inprodut,
         lpad(pr_nrdconta,10,'0')||'-'||lpad(pr_nrdocmto,10,'0')||'-'||pr_inprodut,
         pr_cdoperad,
         rw_crapope.cdpactra);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
        vr_dscritic := 'Erro ao inserir CRAPCBC: '||SQLERRM;
        RAISE vr_exc_saida;
    END;

    -- Atualiza o codigo da consulta na tabela de emprestimo
    IF pr_inprodut = 1 THEN
      BEGIN
        UPDATE crawepr
           SET nrconbir = vr_nrconbir
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrdocmto;
      EXCEPTION
        WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
          vr_dscritic := 'Erro ao atualizar a tabela CRAWEPR: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
    ELSIF pr_inprodut = 3 THEN -- Limite de credito
      BEGIN
        UPDATE craplim
           SET nrconbir = vr_nrconbir
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctrlim = pr_nrdocmto
           AND tpctrlim = 1; -- limite de credito
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
          vr_dscritic := 'Erro ao atualizar a tabela CRAPLIM: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
    END IF;

    -- Inicializa o contador de envio de requisicoes
    vr_qtenvreq := 0;

    -- Efetua o loop, pois pode haver duas requisicoes quando o titular for PJ
    LOOP
      
      -- Inicializa o contador do XML
      vr_contador := 0;

      -- Incrementa o contador de envio de requisicoes
      vr_qtenvreq := vr_qtenvreq + 1;

      -- COMECO DO ENVIO
      -- Cria o cabecalho do xml de envio
      vr_xmlenv := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><LISTA_CONSULTA/>');

      -- Se o titular da consulta for PJ, entao consultar somente ele, pois os avalistas podem ser
      -- os socios e neste caso nao deve-se solicitar a consulta dos avalistas
      IF vr_inpessoa = 2 AND  -- Se for PJ
         vr_qtenvreq = 1 THEN -- E for a primeira requisicao
         
        -- Verifica se tem como reaproveitar o registro
        IF fn_verifica_reaproveitamento(pr_nrconbir => vr_nrconbir,
                                        pr_cdbircon => vr_cdbircon_tit,
                                        pr_cdmodbir => vr_cdmodbir_tit,
                                        pr_cdcooper => pr_cdcooper,
                                        pr_nrdconta => pr_nrdconta,
                                        pr_nrcpfcgc => vr_nrcpfcgc,
                                        pr_intippes => 1, -- Titular
                                        pr_qtdiarpv => vr_qtdiarpv_pj,
                                        pr_cdcritic => vr_cdcritic,
                                        pr_dscritic => vr_dscritic) THEN
          -- Volta para o inicio do loop, pois nao sera necessario mais enviar a consulta do PJ, pois
          -- o mesmo foi reaproveitado
          continue; 
        END IF;
        
        -- Se ocorreu erro na busca do reaproveitamento, cancela a rotina
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Envia o titular da consulta
        pc_monta_cpf_cnpj_envio(pr_xml      => vr_xmlenv,
                                pr_contador => vr_contador,
                                pr_nmtagbir => vr_nmtagbir_pj,
                                pr_nrcpfcgc => vr_nrcpfcgc,
                                pr_inpessoa => 'J',
                                pr_cdpactra => rw_crapope.cdpactra,
                                pr_qthrsrpv => vr_qthrsrpv_pj,
                                pr_dtconscr => NULL,
                                pr_nrcep    => vr_nrcepend, --Cep 
                                pr_dscritic => vr_dscritic);

        -- Incrementa o contador de enviados       
        vr_contador := vr_contador + 1;

        -- Insere o titular da consulta para PJ
        pc_insere_crapcbd(pr_nrconbir => vr_nrconbir,
                          pr_cdbircon => vr_cdbircon_tit,
                          pr_cdmodbir => vr_cdmodbir_tit,
                          pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => pr_nrdconta,
                          pr_nrcpfcgc => vr_nrcpfcgc,
                          pr_inpessoa => vr_inpessoa,
                          pr_intippes => 1, -- Titular
                          pr_cdcritic => vr_cdcritic,
                          pr_dscritic => vr_dscritic);
        IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
      ELSE

        -- Enviar o titular somente se for diferente de PJ
        IF vr_inpessoa <> 2 THEN
          -- Verifica se nao tem como reaproveitar o registro
          IF NOT fn_verifica_reaproveitamento(pr_nrconbir => vr_nrconbir,
                                          pr_cdbircon => vr_cdbircon_tit,
                                          pr_cdmodbir => vr_cdmodbir_tit,
                                          pr_cdcooper => pr_cdcooper,
                                          pr_nrdconta => pr_nrdconta,
                                          pr_nrcpfcgc => vr_nrcpfcgc,
                                          pr_intippes => 1, -- Titular
                                          pr_qtdiarpv => vr_qtdiarpv_pf,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic) THEN
            -- Se ocorreu erro na busca do reaproveitamento, cancela a rotina
            IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;

            -- Envia o titular PF da consulta
            pc_monta_cpf_cnpj_envio(pr_xml      => vr_xmlenv,
                                    pr_contador => vr_contador,
                                    pr_nmtagbir => vr_nmtagbir_pf,
                                    pr_nrcpfcgc => vr_nrcpfcgc,
                                    pr_inpessoa => 'F',
                                    pr_cdpactra => rw_crapope.cdpactra,
                                    pr_qthrsrpv => vr_qthrsrpv_pf,
                                    pr_dtconscr => NULL,
                                    pr_nrcep    => vr_nrcepend, --Cep
                                    pr_dscritic => vr_dscritic);

            -- Incrementa o contador de enviados       
            vr_contador := vr_contador + 1;

            -- Insere o titular da consulta para PF
            pc_insere_crapcbd(pr_nrconbir => vr_nrconbir,
                              pr_cdbircon => vr_cdbircon_tit,
                              pr_cdmodbir => vr_cdmodbir_tit,
                              pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => pr_nrdconta,
                              pr_nrcpfcgc => vr_nrcpfcgc,
                              pr_inpessoa => vr_inpessoa,
                              pr_intippes => 1, -- Titular
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic);
            IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF; -- Fim da verificacao de reaproveitamento
        END IF;

        -- Se o titular da consulta for pessoa juridica, verifica se os socios nao sao avalistas
        IF vr_inpessoa = 2 THEN
          -- Verifica o avalista 1
          IF nvl(vr_nrcpfcgc_av1,0) > 0 THEN
            sspc0001.pc_busca_cns_biro(pr_cdcooper => pr_cdcooper,
                                       pr_nrdconta => pr_nrdconta,
                                       pr_nrdocmto => pr_nrdocmto,
                                       pr_inprodut => pr_inprodut,
                                       pr_nrdconta_busca => -1,
                                       pr_nrcpfcgc_busca => vr_nrcpfcgc_av1,
                                       pr_nrconbir => vr_nrconbir_av1,
                                       pr_nrseqdet => vr_nrseqdet_av1);
          END IF;
          -- Verifica o avalista 2
          IF nvl(vr_nrcpfcgc_av2,0) > 0 THEN
            sspc0001.pc_busca_cns_biro(pr_cdcooper => pr_cdcooper,
                                       pr_nrdconta => pr_nrdconta,
                                       pr_nrdocmto => pr_nrdocmto,
                                       pr_inprodut => pr_inprodut,
                                       pr_nrdconta_busca => -1,
                                       pr_nrcpfcgc_busca => vr_nrcpfcgc_av2,
                                       pr_nrconbir => vr_nrconbir_av2,
                                       pr_nrseqdet => vr_nrseqdet_av2);
          END IF;
        END IF;

        -- Envia o avalista 1 somente se o mesmo ja nao existir como socio
        IF nvl(vr_nrcpfcgc_av1,0) > 0 AND nvl(vr_nrconbir_av1,0) = 0 THEN

          -- Inicia a verificacao de existencia de reaproveitamento
          vr_inreapro := 0;
          -- Se for PF, verifica reaproveitamento com os dados de PF
          IF vr_inpessoa_av1 = 1 THEN
            IF fn_verifica_reaproveitamento(pr_nrconbir => vr_nrconbir,
                                            pr_cdbircon => vr_cdbircon_pf,
                                            pr_cdmodbir => vr_cdmodbir_pf,
                                            pr_cdcooper => pr_cdcooper,
                                            pr_nrdconta => vr_nrdconta_av1,
                                            pr_nrcpfcgc => vr_nrcpfcgc_av1,
                                            pr_intippes => 2, -- Avalista
                                            pr_qtdiarpv => vr_qtdiarpv_pf,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic) THEN
              vr_inreapro := 1; -- Ocorreu reaproveitamento
            END IF;
          ELSE -- Se for PJ
            IF fn_verifica_reaproveitamento(pr_nrconbir => vr_nrconbir,
                                            pr_cdbircon => vr_cdbircon_pj,
                                            pr_cdmodbir => vr_cdmodbir_pj,
                                            pr_cdcooper => pr_cdcooper,
                                            pr_nrdconta => vr_nrdconta_av1,
                                            pr_nrcpfcgc => vr_nrcpfcgc_av1,
                                            pr_intippes => 2, -- Avalista
                                            pr_qtdiarpv => vr_qtdiarpv_pj,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic) THEN
              vr_inreapro := 1; -- Ocorreu reaproveitamento
            END IF;
          END IF;
          -- Se ocorreu erro na busca do reaproveitamento, cancela a rotina
          IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

          -- Envia a solicitacao somente se nao possuir reaproveitamento
          IF vr_inreapro = 0 THEN
            IF vr_inpessoa_av1 = 1 THEN

              pc_monta_cpf_cnpj_envio(pr_xml      => vr_xmlenv,
                                      pr_contador => vr_contador,
                                      pr_nmtagbir => vr_nmtagbir_pf,
                                      pr_nrcpfcgc => vr_nrcpfcgc_av1,
                                      pr_inpessoa => 'F',
                                      pr_cdpactra => rw_crapope.cdpactra,
                                      pr_qthrsrpv => vr_qthrsrpv_pf,
                                      pr_dtconscr => NULL,
                                      pr_nrcep    => vr_nrcepend_av1, --Cep
                                      pr_dscritic => vr_dscritic);
  
              -- define o biro e a modalidade de consulta do avalista 1
              vr_cdbircon_av1 := vr_cdbircon_pf;
              vr_cdmodbir_av1 := vr_cdmodbir_pf;
            ELSE

              pc_monta_cpf_cnpj_envio(pr_xml      => vr_xmlenv,
                                      pr_contador => vr_contador,
                                      pr_nmtagbir => vr_nmtagbir_pj,
                                      pr_nrcpfcgc => vr_nrcpfcgc_av1,
                                      pr_inpessoa => 'J',
                                      pr_cdpactra => rw_crapope.cdpactra,
                                      pr_qthrsrpv => vr_qthrsrpv_pf,
                                      pr_dtconscr => NULL,
                                      pr_nrcep    => vr_nrcepend_av1, --Cep
                                      pr_dscritic => vr_dscritic);

              -- define o biro e a modalidade de consulta do avalista 1
              vr_cdbircon_av1 := vr_cdbircon_pj;
              vr_cdmodbir_av1 := vr_cdmodbir_pj;
            END IF;

            -- Incrementa o contador de enviados       
            vr_contador := vr_contador + 1;

            -- Insere o avalista 1 da consulta
            pc_insere_crapcbd(pr_nrconbir => vr_nrconbir,
                              pr_cdbircon => vr_cdbircon_av1,
                              pr_cdmodbir => vr_cdmodbir_av1,
                              pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => vr_nrdconta_av1,
                              pr_nrcpfcgc => vr_nrcpfcgc_av1,
                              pr_inpessoa => vr_inpessoa_av1,
                              pr_intippes => 2, -- Avalista
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic);
            IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF; -- Fim da verificacao se houve reaproveitamento
        END IF; -- Fim da verificacao se deve ou nao consultar o avalista 1
              
        -- Envia o avalista 2 somente se o mesmo ja nao existir como socio
        IF nvl(vr_nrcpfcgc_av2,0) > 0 AND nvl(vr_nrconbir_av2,0) = 0 THEN

          -- Inicia a verificacao de existencia de reaproveitamento
          vr_inreapro := 0;
          -- Se for PF, verifica reaproveitamento com os dados de PF
          IF vr_inpessoa_av2 = 1 THEN
            IF fn_verifica_reaproveitamento(pr_nrconbir => vr_nrconbir,
                                            pr_cdbircon => vr_cdbircon_pf,
                                            pr_cdmodbir => vr_cdmodbir_pf,
                                            pr_cdcooper => pr_cdcooper,
                                            pr_nrdconta => vr_nrdconta_av2,
                                            pr_nrcpfcgc => vr_nrcpfcgc_av2,
                                            pr_intippes => 2, -- Avalista
                                            pr_qtdiarpv => vr_qtdiarpv_pf,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic) THEN
              vr_inreapro := 1; -- Ocorreu reaproveitamento
            END IF;
          ELSE -- Se for PJ
            IF fn_verifica_reaproveitamento(pr_nrconbir => vr_nrconbir,
                                            pr_cdbircon => vr_cdbircon_pj,
                                            pr_cdmodbir => vr_cdmodbir_pj,
                                            pr_cdcooper => pr_cdcooper,
                                            pr_nrdconta => vr_nrdconta_av2,
                                            pr_nrcpfcgc => vr_nrcpfcgc_av2,
                                            pr_intippes => 2, -- Avalista
                                            pr_qtdiarpv => vr_qtdiarpv_pj,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic) THEN
              vr_inreapro := 1; -- Ocorreu reaproveitamento
            END IF;
          END IF;
          -- Se ocorreu erro na busca do reaproveitamento, cancela a rotina
          IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

          -- Envia a solicitacao somente se nao possuir reaproveitamento
          IF vr_inreapro = 0 THEN
            IF vr_inpessoa_av2 = 1 THEN
              pc_monta_cpf_cnpj_envio(pr_xml      => vr_xmlenv,
                                      pr_contador => vr_contador,
                                      pr_nmtagbir => vr_nmtagbir_pf,
                                      pr_nrcpfcgc => vr_nrcpfcgc_av2,
                                      pr_inpessoa => 'F',
                                      pr_cdpactra => rw_crapope.cdpactra,
                                      pr_qthrsrpv => vr_qthrsrpv_pf,
                                      pr_dtconscr => NULL,
                                      pr_nrcep    => vr_nrcepend_av2, --Cep
                                      pr_dscritic => vr_dscritic);

              -- define o biro e a modalidade de consulta do avalista 2
              vr_cdbircon_av2 := vr_cdbircon_pf;
              vr_cdmodbir_av2 := vr_cdmodbir_pf;
            ELSE
              pc_monta_cpf_cnpj_envio(pr_xml      => vr_xmlenv,
                                      pr_contador => vr_contador,
                                      pr_nmtagbir => vr_nmtagbir_pj,
                                      pr_nrcpfcgc => vr_nrcpfcgc_av2,
                                      pr_inpessoa => 'J',
                                      pr_cdpactra => rw_crapope.cdpactra,
                                      pr_qthrsrpv => vr_qthrsrpv_pf,
                                      pr_dtconscr => NULL,
                                      pr_nrcep    => vr_nrcepend_av2, --Cep
                                      pr_dscritic => vr_dscritic);

              -- define o biro e a modalidade de consulta do avalista 2
              vr_cdbircon_av2 := vr_cdbircon_pj;
              vr_cdmodbir_av2 := vr_cdmodbir_pj;
            END IF;

            -- Incrementa o contador de enviados       
            vr_contador := vr_contador + 1;

            -- Insere o avalista 2 da consulta
            pc_insere_crapcbd(pr_nrconbir => vr_nrconbir,
                              pr_cdbircon => vr_cdbircon_av2,
                              pr_cdmodbir => vr_cdmodbir_av2,
                              pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => vr_nrdconta_av2,
                              pr_nrcpfcgc => vr_nrcpfcgc_av2,
                              pr_inpessoa => vr_inpessoa_av2,
                              pr_intippes => 2, -- Avalista
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic);
            IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF; -- Fim da verificacao se houve reaproveitamento
        END IF; -- Fim da verificacao se deve ou nao consultar o avalista 1

        -- Envia o conjuge para o SPC
        IF nvl(vr_nrcpfcgc_cje,0) > 0 AND 
           vr_nrcpfcgc_cje <> nvl(vr_nrcpfcgc_av1,0) AND   -- Se for avalista nao deve efetuar consulta novamente
           vr_nrcpfcgc_cje <> nvl(vr_nrcpfcgc_av2,0) THEN  -- Se for avalista nao deve efetuar consulta novamente

          -- Verifica se nao tem como reaproveitar a consulta do conjuge
          IF NOT fn_verifica_reaproveitamento(pr_nrconbir => vr_nrconbir,
                                              pr_cdbircon => vr_cdbircon_pf,
                                              pr_cdmodbir => vr_cdmodbir_pf,
                                              pr_cdcooper => pr_cdcooper,
                                              pr_nrdconta => vr_nrdconta_cje,
                                              pr_nrcpfcgc => vr_nrcpfcgc_cje,
                                              pr_intippes => 3, -- Conjuge
                                              pr_qtdiarpv => vr_qtdiarpv_pf,
                                              pr_cdcritic => vr_cdcritic,
                                              pr_dscritic => vr_dscritic) THEN
            -- Verifica se ocorreu erro na busca do reaproveitamento
            IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;

            -- Envia os dados do conjuge
            pc_monta_cpf_cnpj_envio(pr_xml      => vr_xmlenv,
                                    pr_contador => vr_contador,
                                    pr_nmtagbir => vr_nmtagbir_pf,
                                    pr_nrcpfcgc => vr_nrcpfcgc_cje,
                                    pr_inpessoa => 'F',
                                    pr_cdpactra => rw_crapope.cdpactra,
                                    pr_qthrsrpv => vr_qthrsrpv_pf,
                                    pr_dtconscr => NULL,
                                    pr_nrcep    => vr_nrcepend_cje, --Cep
                                    pr_dscritic => vr_dscritic);
           
            -- Incrementa o contador de enviados       
            vr_contador := vr_contador + 1;

            -- Insere o conjuge da consulta
            pc_insere_crapcbd(pr_nrconbir => vr_nrconbir,
                              pr_cdbircon => vr_cdbircon_pf,
                              pr_cdmodbir => vr_cdmodbir_pf,
                              pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => vr_nrdconta_cje,
                              pr_nrcpfcgc => vr_nrcpfcgc_cje,
                              pr_inpessoa => 1, -- PF
                              pr_intippes => 3, -- Conjuge
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic);
            IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF; -- Finaliza a verificacao de consulta de reaproveitamento
        END IF; -- Finaliza a verificacao se deve ou nao consultar o conjuge
        
        -- Inicializa o contador de SCR
        vr_contador_scr := 1;
        
        -- Loop sobre o SCR 
        LOOP

          -- Sai quando o contador de SCR chegar a 4
          EXIT WHEN vr_contador_scr = 5;
          
          vr_nrcepend := null;
          -- Se for a primeira execucao
          IF vr_contador_scr = 1 THEN
            -- Atualiza os dados com o conjuge
            vr_inpessoa_scr := vr_inpessoa;
            vr_nrdconta_scr := pr_nrdconta;
            vr_nrcpfcgc_scr := vr_nrcpfcgc;
            vr_intippes_scr := 1; -- Titular
            vr_nrcepend_scr := vr_nrcepend;
          ELSIF vr_contador_scr = 2 THEN -- Conjuge
            -- Envia o conjuge somente se ele nao for avalista
           IF nvl(vr_nrcpfcgc_cje,0) <> nvl(vr_nrcpfcgc_av1,0) AND   -- Se for avalista nao deve efetuar consulta novamente
              nvl(vr_nrcpfcgc_cje,0) <> nvl(vr_nrcpfcgc_av2,0) THEN  -- Se for avalista nao deve efetuar consulta novamente
              -- Atualiza os dados com o conjuge
              vr_inpessoa_scr := 1; -- Pessoa Fisica
              vr_nrdconta_scr := vr_nrdconta_cje;
              vr_nrcpfcgc_scr := vr_nrcpfcgc_cje;
              vr_intippes_scr := 3; -- Conjuge
              vr_nrcepend_scr := vr_nrcepend_cje;
            ELSE
              vr_nrcpfcgc_scr := 0;
            END IF;
          ELSIF vr_contador_scr = 3 THEN
            -- Atualiza os dados com o avalista 1
            vr_inpessoa_scr := vr_inpessoa_av1;
            vr_nrdconta_scr := vr_nrdconta_av1;
            vr_nrcpfcgc_scr := vr_nrcpfcgc_av1;
            vr_intippes_scr := 2; -- Avalista
            vr_nrcepend_scr := vr_nrcepend_av1;
          ELSE
            -- Atualiza os dados com o avalista 2
            vr_inpessoa_scr := vr_inpessoa_av2;
            vr_nrdconta_scr := vr_nrdconta_av2;
            vr_nrcpfcgc_scr := vr_nrcpfcgc_av2;
            vr_intippes_scr := 2; -- Avalista
            vr_nrcepend_scr := vr_nrcepend_av2;
          END IF;
          
          -- Verifica se eh pessoa fisica
          IF vr_inpessoa_scr = 1 THEN
            vr_qtdiarpv_scr := vr_qtdiarpv_pf;
            vr_inpessoa_txt := 'F';
            vr_qthrsrpv_scr := vr_qthrsrpv_pf;
          ELSE
            vr_qtdiarpv_scr := vr_qtdiarpv_pj;
            vr_inpessoa_txt := 'J';
            vr_qthrsrpv_scr := vr_qthrsrpv_pj;
          END IF;

          -- Incrementa o contador de SCR
          vr_contador_scr := vr_contador_scr + 1;

          -- Se nao tiver CPF/CGC para consultar, volta para o inicio
          IF nvl(vr_nrcpfcgc_scr,0) = 0 THEN
            CONTINUE;
          END IF;

          -- Verifica se tem que consultar SCR
          OPEN cr_crapopf(vr_nrcpfcgc_scr);
          FETCH cr_crapopf INTO rw_crapopf;
          -- Se ja existir consulta SCR entao nao precisa consultar novamente
          IF cr_crapopf%FOUND THEN
            CLOSE cr_crapopf;
            CONTINUE; -- Vai para a proxima consulta
          END IF;
          CLOSE cr_crapopf;
          
          -- Verifica se nao tem como reaproveitar a consulta do SCR do titular
          IF NOT fn_verifica_reaproveitamento(pr_nrconbir => vr_nrconbir,
                                              pr_cdbircon => vr_cdbircon_scr,
                                              pr_cdmodbir => vr_cdmodbir_scr,
                                              pr_cdcooper => pr_cdcooper,
                                              pr_nrdconta => vr_nrdconta_scr,
                                              pr_nrcpfcgc => vr_nrcpfcgc_scr,
                                              pr_intippes => vr_intippes_scr,
                                              pr_qtdiarpv => vr_qtdiarpv_scr,
                                              pr_cdcritic => vr_cdcritic,
                                              pr_dscritic => vr_dscritic) THEN
            -- Verifica se ocorreu erro na busca do reaproveitamento
            IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;

            -- Se nao existir, tem que enviar a consulta do SCR
            pc_monta_cpf_cnpj_envio(pr_xml      => vr_xmlenv,
                                    pr_contador => vr_contador,
                                    pr_nmtagbir => vr_nmtagbir_scr,
                                    pr_nrcpfcgc => vr_nrcpfcgc_scr,
                                    pr_inpessoa => vr_inpessoa_txt,
                                    pr_cdpactra => rw_crapope.cdpactra,
                                    pr_qthrsrpv => vr_qthrsrpv_scr,
                                    pr_dtconscr => vr_dtconmax_scr,
                                    pr_nrcep    => vr_nrcepend_scr, --Cep
                                    pr_dscritic => vr_dscritic);

            -- Incrementa o contador de enviados       
            vr_contador := vr_contador + 1;

            -- Insere o titular da consulta para consulta SCR
            pc_insere_crapcbd(pr_nrconbir => vr_nrconbir,
                              pr_cdbircon => vr_cdbircon_scr,
                              pr_cdmodbir => vr_cdmodbir_scr,
                              pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => vr_nrdconta_scr,
                              pr_nrcpfcgc => vr_nrcpfcgc_scr,
                              pr_inpessoa => vr_inpessoa_scr,
                              pr_intippes => vr_intippes_scr,
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic);
            IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
            
            -- Se for o contador 1 (titular), entao atualiza o indicador de consulta de scr
            IF vr_contador_scr = 1 THEN
              vr_inconscr := 1;
            END IF;
            
          END IF; -- Fim da verificacao de reaproveitamento para SCR o avalista
        END LOOP; -- Fim do loop do SCR para avalista
        
      END IF; -- Fim da verificacao da primeira ou segunda execucao
      
      -- Se nao existir consultas a serem feitas, sai do loop
      EXIT WHEN vr_contador = 0;
                 
      -- Envia a requisicao
      pc_envia_requisicao(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => pr_nrdconta,
                          pr_nrdocmto => pr_nrdocmto,
                          pr_dsprodut => vr_dsprodut,
                          pr_envioxml => vr_xmlenv,
                          pr_nrprotoc => vr_nrprotoc,
                          pr_cdcritic => vr_cdcritic,
                          pr_dscritic => vr_dscritic);
      
      -- Se ocorreu erro na requisicao
      IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN

        -- Joga um texto padrao de retorno para a rotina
        vr_dscritic_padrao := 'Houve erro no acesso ao biro (SPC/Serasa/SCR), consulta nao realizada!';

        -- Forca saida da rotina
        RAISE vr_exc_saida;
      END IF;
      
      -- Se nao veio protocolo, deve-se cancelar
      IF nvl(vr_nrprotoc,'0') = '0' THEN
        vr_dscritic := 'Numero do protocolo nao retornado pelo biro de consultas automatizadas';

        -- Joga um texto padrao de retorno para a rotina
        vr_dscritic_padrao := 'Houve erro no acesso ao biro (SPC/Serasa/SCR), consulta nao realizada!';

        RAISE vr_exc_saida;
      END IF;
      
      -- Solicita o retorno do biro de consultas. Vai sair somente quando possuir o retorno
      -- ou quando encerrar o tempo de requisicao
      pc_solicita_retorno_req(pr_cdcooper => pr_cdcooper,
                              pr_nrprotoc => vr_nrprotoc,
															pr_retxml   => vr_xmlret,
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic);

      -- Se ocorreu erro na requisicao
      IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN

        -- Joga um texto padrao de retorno para a rotina
        vr_dscritic_padrao := 'Houve erro no acesso ao biro (SPC/Serasa/SCR), consulta nao realizada!';

        -- Forca saida da rotina
        RAISE vr_exc_saida;
      END IF;
      
      -- Processa o retorno do biro e grava as tabelas do sistema
      pc_processa_retorno_req(pr_cdcooper => pr_cdcooper,
			                        pr_nrconbir => vr_nrconbir,
                              pr_nrprotoc => vr_nrprotoc,
                              pr_nrdconta => pr_nrdconta,
                              pr_nrdocmto => pr_nrdocmto,
                              pr_inprodut => pr_inprodut,
															pr_tpconaut => 'A',
															pr_inconscr => vr_inconscr,
                              pr_retxml   => vr_xmlret,
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic);

      -- Se ocorreu erro no processo do XML
      IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN

        -- Joga um texto padrao de retorno para a rotina
        vr_dscritic_padrao := 'Houve erro no acesso ao biro (SPC/Serasa/SCR), consulta nao realizada!';

        -- Forca saida da rotina
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se todas as consultas ja foram feitas para sair do loop
      EXIT WHEN vr_qtenvreq = 2 OR  -- Se ja efetuou as duas consultas
                vr_inpessoa = 1;    -- Se o titular for PF
      
    END LOOP;

    -- Atualiza a data da consulta no emprestimo
    IF pr_inprodut = 1 THEN
      BEGIN
        UPDATE crapprp
           SET dtdrisco = decode(vr_inconscr,1,nvl(vr_dtconmax_scr, dtdrisco),dtdrisco),
               dtcnsspc = (SELECT trunc(nvl(dtreapro, dtconbir))
                             FROM crapcbd
                            WHERE nrconbir = vr_nrconbir
                              AND nrseqdet = 1)
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctrato = pr_nrdocmto
           AND tpctrato = 90; -- Contrato de emprestimo
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
          vr_dscritic := 'Erro ao atualizar a tabela CRAPPRP: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
    ELSIF pr_inprodut = 3 THEN -- Se for limite de credito
      -- Atualiza a data da consulta na tabela de limite
      BEGIN
        UPDATE craplim
           SET dtconbir = (SELECT trunc(nvl(dtreapro, dtconbir))
                             FROM crapcbd
                            WHERE nrconbir = vr_nrconbir
                              AND nrseqdet = 1)
         WHERE craplim.cdcooper = pr_cdcooper
           AND craplim.nrdconta = pr_nrdconta -- Utiliza a conta do documento
           AND craplim.nrctrlim = pr_nrdocmto
           AND craplim.tpctrlim = 1; -- Limite de credito            
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
          vr_dscritic := 'Erro ao atualizar a tabela CRAPPRP: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

    END IF;

    IF pr_inprodut <> 6 THEN -- Se for abertura de conta, nao atualiza SCR nas tabelas de origem
      -- Atualizao SCR nas tabelas originais dos produtos
      pc_atualiza_scr(pr_nrconbir => vr_nrconbir,
                      pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_nrdocmto => pr_nrdocmto,
                      pr_inprodut => pr_inprodut,
                      pr_database => vr_dtconmax_scr,
                      pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic);
      -- Se ocorreu erro no processo do XML
      IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
        -- Joga um texto padrao de retorno para a rotina
        vr_dscritic_padrao := 'Houve erro no acesso ao biro (SPC/Serasa/SCR), consulta nao realizada!';
        -- Forca saida da rotina
        RAISE vr_exc_saida;
      END IF;
    END IF;

    -- Se for abertura de conta, ja atualiza as informacoes cadastrais
    IF pr_inprodut = 6 THEN
      pc_atualiza_inf_cad_cta(pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => pr_nrdconta,
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic);
      -- Se ocorreu erro no processo do XML
      IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
        -- Joga um texto padrao de retorno para a rotina
        vr_dscritic_padrao := 'Houve erro no acesso ao biro (SPC/Serasa/SCR), consulta nao realizada!';
        -- Forca saida da rotina
        RAISE vr_exc_saida;
      END IF;
    END IF;
                              
    -- Atualiza as tabelas finais de controle
    pc_atualiza_tab_controle(pr_nrconbir => vr_nrconbir,
                             pr_cdcritic => vr_cdcritic,
                             pr_dscritic => vr_dscritic);
    -- Se ocorreu erro na atualizacao
    IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN

      -- Joga um texto padrao de retorno para a rotina
      vr_dscritic_padrao := 'Houve erro no acesso ao biro (SPC/Serasa/SCR), consulta nao realizada!';

      -- Forca saida da rotina
      RAISE vr_exc_saida;
    END IF;
     
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
           
      --Tratamento na chamada da pc_gera_log_batch CH=660433 / CH=660325
      -- Trata erro na requisicao, mostra parãmentros na gravação da tbgen_prglog
      pc_trata_erro_retorno(pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => pr_nrdconta,
                            pr_nrdocmto => pr_nrdocmto,
                            pr_nrprotoc => vr_nrprotoc,
                            pr_nrconbir => vr_nrconbir,
                            pr_dscritic => vr_dscritic,
                            pr_tpocorre => 1);
      
      -- Volta o numero da consulta do biro no emprestimo
      IF pr_inprodut = 1 THEN
        BEGIN
          UPDATE crawepr
             SET nrconbir = nvl(vr_nrconbir, nrconbir)
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrdocmto;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      ELSIF pr_inprodut = 3 THEN -- Limite de Credito
        BEGIN
          UPDATE craplim
             SET nrconbir = nvl(vr_nrconbir, nrconbir)
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctrlim = pr_nrdocmto
           AND tpctrlim = 1; -- limite de credito
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;        
      END IF;
      
      IF vr_nrconbir > 0 THEN
        -- Insere na inconsistencia
        GENE0005.pc_gera_inconsistencia(pr_cdcooper => 3 -- CECRED
                                       ,pr_iddgrupo => 4 -- Consulta Automatizada
                                       ,pr_tpincons => 2 -- Erro
                                       ,pr_dsregist => 'Cooperativa: ' || pr_cdcooper
                                                    || ' Conta: '      || pr_nrdconta
                                                    || ' Documento: '  || pr_nrdocmto
                                                    || ' Protocolo do biro: ' || vr_nrprotoc
                                                    || ' Consulta no biro: '  || vr_nrconbir
                                       ,pr_dsincons => vr_dscritic
                                       ,pr_flg_enviar => 'S'
                                       ,pr_des_erro => vr_des_erro
                                       ,pr_dscritic => vr_dscritic_aux);
      END IF;                                       

      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := nvl(vr_dscritic_padrao, vr_dscritic);                                      

    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;

      IF vr_nrconbir > 0 THEN
        -- Insere na inconsistencia
        GENE0005.pc_gera_inconsistencia(pr_cdcooper => 3 -- CECRED
                                       ,pr_iddgrupo => 4 -- Consulta Automatizada
                                       ,pr_tpincons => 2 -- Erro
                                       ,pr_dsregist => 'Cooperativa: ' || pr_cdcooper
                                                    || ' Conta: '      || pr_nrdconta
                                                    || ' Documento: '  || pr_nrdocmto
                                                    || ' Protocolo do biro: ' || vr_nrprotoc
                                                    || ' Consulta no biro: '  || vr_nrconbir
                                       ,pr_dsincons => pr_dscritic
                                       ,pr_flg_enviar => 'S'
                                       ,pr_des_erro => vr_des_erro
                                       ,pr_dscritic => vr_dscritic);
      END IF;                                       

      --Tratamento na chamada da pc_gera_log_batch CH=660433 / CH=660325
      -- Trata erro na requisicao
      pc_trata_erro_retorno(pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => pr_nrdconta,
                            pr_nrdocmto => pr_nrdocmto,
                            pr_nrprotoc => vr_nrprotoc,
                            pr_nrconbir => vr_nrconbir,
                            pr_dscritic => vr_dscritic,
                            pr_tpocorre => 2);

      -- Volta o numero da consulta do biro no emprestimo
      IF pr_inprodut = 1 THEN
        BEGIN
          UPDATE crawepr
             SET nrconbir = nvl(vr_nrconbir, nrconbir)
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrdocmto;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      ELSIF pr_inprodut = 3 THEN -- Limite de Credito
        BEGIN
          UPDATE craplim
             SET nrconbir = nvl(vr_nrconbir, nrconbir)
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctrlim = pr_nrdocmto
           AND tpctrlim = 1; -- limite de credito
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;        
      END IF;

  END;                                 

-- Efetua a consulta ao biro da Ibratan para os Pagadores de Títulos de um Borderô
PROCEDURE pc_solicita_cons_bordero_biro(pr_cdcooper IN  crapcob.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                        pr_nrdconta IN  crapcob.nrdconta%TYPE, --> Numero da conta de emprestimo
                                        pr_nrinssac IN  crapcob.nrinssac%TYPE,
                                        pr_vlttitbd IN  NUMBER,                --> Valor total
                                        pr_nrctrlim IN  craplim.nrctrlim%TYPE,  --> Contrato de desconto de titulo
                                        pr_inpessoa IN  crapsab.cdtpinsc%TYPE, --> tipo de pessoa
                                        pr_nrcepsac IN  crapsab.nrcepsac%TYPE, --> Cep do pagador
                                        pr_cdoperad IN  crapcob.cdoperad%TYPE, --> Operador que solicitou a consulta
                                        pr_cdcritic OUT crapcri.cdcritic%TYPE, --> Critica encontrada
                                        pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada


  ---------------------------------------------------------------------------------------------------------------
  --
  --                                                      Ultima atualizacao:
  --
  --              28/03/2018 - Andrew Albuquerque GFT (AWAE) - Criação da Procedure.
  --              23/01/2019 - Luis Fernando GFT - Alterações na procedure para executar por pagador e nao por titulo
  --
  ---------------------------------------------------------------------------------------------------------------
    -- Busca as tags para a consulta do biro
    CURSOR cr_crapmbr(pr_cdbircon crapmbr.cdbircon%TYPE,
                      pr_cdmodbir crapmbr.cdmodbir%TYPE) IS
      SELECT crapbir.nmtagbir ||'-'||crapmbr.nmtagmod,
             crapbir.dsbircon
        FROM crapbir,
             crapmbr
       WHERE crapmbr.cdbircon = pr_cdbircon
         AND crapmbr.cdmodbir = pr_cdmodbir
         AND crapbir.cdbircon = crapmbr.cdbircon;

    -- Busca os dados do operador
    CURSOR cr_crapope IS
      SELECT crapope.cdpactra
        FROM crapope
       WHERE crapope.cdcooper = pr_cdcooper
         AND upper(crapope.cdoperad) = upper(pr_cdoperad);
    rw_crapope cr_crapope%ROWTYPE;

    -- Cursor de verificacao de contingencia de biro
    CURSOR cr_crapcbr(pr_cdbircon crapcbr.cdbircon%TYPE) IS
      SELECT 1
        FROM crapcbr
       WHERE cdcooper = pr_cdcooper
         AND cdbircon = pr_cdbircon
         AND dtinicon <= trunc(SYSDATE);
    rw_crapcbr cr_crapcbr%ROWTYPE;

    -- Cursor para busca do tempo de reaproveitamento
    CURSOR cr_craprbi(pr_inprodut craprbi.inprodut%TYPE,
                      pr_inpessoa craprbi.inpessoa%TYPE) IS
      SELECT craprbi.qtdiarpv,
             craprbi.qtdiarpv * 24 qthrsrpv
        FROM craprbi
       WHERE craprbi.cdcooper = pr_cdcooper
         AND craprbi.inprodut = pr_inprodut
         AND craprbi.inpessoa = pr_inpessoa;

    -- Monta o registro de data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Variaveis de erro
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_dscritic_aux VARCHAR2(4000); --> descricao do erro
    vr_dscritic_padrao VARCHAR2(400); --> descricao do erro padrao para nao exibir erros tecnicos para o usuario
    vr_exc_saida  EXCEPTION; --> Excecao prevista
    vr_des_erro   VARCHAR2(10);

    -- Variaveis gerais
    vr_xmlenv   XMLtype;               --> XML de envio
    vr_xmlret   XMLtype;               --> XML de retorno
    vr_contador PLS_INTEGER;           --> Contador do xml de envio
    vr_qtenvreq PLS_INTEGER;           --> Contador de envio de requisicoes
    vr_nrprotoc crapcbd.nrprotoc%TYPE; --> Numero do protocolo do envio da requisicao
    vr_inconscr PLS_INTEGER := 0;      --> Indicador de consulta de SCR do titular : AWAE: NÃO É UTILIZADO, APENAS PARA PARAMETRO DA PROCEDURE

    vr_nrconbir crapcbd.nrconbir%TYPE; --> Numero da consulta no biro
    
    vr_cdbircon_tit crapcbd.cdbircon%TYPE; --> Biro de consulta para o titular da conta
    vr_cdmodbir_tit crapcbd.cdmodbir%TYPE; --> Modalidade do biro de consulta para o titular da conta

    vr_cdbircon_pf  crapcbd.cdbircon%TYPE; --> Biro de consulta para pessoa fisica
    vr_cdmodbir_pf  crapcbd.cdmodbir%TYPE; --> Modalidade do biro de consulta para pessoa fisica
    vr_dsbircon_pf  crapbir.dsbircon%TYPE; --> Nome do biro de consultas para pessoa fisica
    vr_nmtagbir_pf  VARCHAR2(100);         --> Nome da tag de consulta para pessoa fisica
    vr_qthrsrpv_pf  PLS_INTEGER;           --> Quantidade de horas de reaproveitamento para pessoa fisica
    vr_qtdiarpv_pf  PLS_INTEGER;           --> Quantidade de dias de reaproveitamento para pessoa fisica

    vr_cdbircon_pj  crapcbd.cdbircon%TYPE; --> Biro de consulta para pessoa juridica
    vr_cdmodbir_pj  crapcbd.cdmodbir%TYPE; --> Modalidade do biro de consulta para pessoa juridica
    vr_dsbircon_pj  crapbir.dsbircon%TYPE; --> Nome do biro de consultas para pessoa juridica
    vr_nmtagbir_pj  VARCHAR2(100);         --> Nome da tag de consulta para pessoa juridica
    vr_qthrsrpv_pj  PLS_INTEGER;           --> Quantidade de horas de reaproveitamento para pessoa juridica
    vr_qtdiarpv_pj  PLS_INTEGER;           --> Quantidade de dias de reaproveitamento para pessoa juridica

    vr_dsprodut VARCHAR2(100);         --> Descricao do produto que sera utilizado
    vr_inprodut INTEGER := 7;          --> Desconto de título

  BEGIN
    GENE0001.pc_informa_acesso(pr_module => 'ATENDA'
                              ,pr_action => 'SSPC0001.pc_solicita_cons_bordero_biro');

    -- Monta a descricao do produto que sera utilizado
    vr_dsprodut := '07 - Título de Borderô';

    
    -- Busca a data
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- Busca os dados do operador
    OPEN cr_crapope;
    FETCH cr_crapope INTO rw_crapope;
    -- Se não encontrar o operador, retorna com erro
    IF cr_crapope%NOTFOUND THEN
      vr_dscritic := 'Operador '||pr_cdoperad|| ' inexistente. Favor verificar!';
      CLOSE cr_crapope;
      RAISE vr_exc_saida;
    END IF;
    -- Fecha o cursor de operador
    CLOSE cr_crapope;
    
    -- Se o Pagador é Pessoa Física
    IF pr_inpessoa = 1 /*vr_inpessoa = 1 OR vr_inpessoa_av1 = 1 OR vr_inpessoa_av2 = 1*/ THEN
      -- Verifica qual o biro de consulta
      SSPC0001.pc_busca_modalidade_prm(pr_cdcooper => pr_cdcooper,
                                       pr_inprodut => vr_inprodut,
                                       pr_inpessoa => 1, -- Pessoa fisica
                                       pr_vlprodut => pr_vlttitbd, --vr_vlemprst,
                                       pr_cdbircon => vr_cdbircon_pf,
                                       pr_cdmodbir => vr_cdmodbir_pf);
      -- Busca o nome da tag para pessoa fisica
      OPEN cr_crapmbr(vr_cdbircon_pf, vr_cdmodbir_pf);
      FETCH cr_crapmbr INTO vr_nmtagbir_pf, vr_dsbircon_pf;
      IF cr_crapmbr%NOTFOUND THEN
        vr_dscritic := 'TAG para pessoa fisica nao encontrada!';
        CLOSE cr_crapmbr;
        RAISE vr_exc_saida;
      END iF;
      CLOSE cr_crapmbr;

      -- Verifica se o BIRO esta em CONTINGENCIA
      OPEN cr_crapcbr(vr_cdbircon_pf);
      FETCH cr_crapcbr INTO rw_crapcbr;
      -- Se encontrou, deve-se cancelar a consulta
      IF cr_crapcbr%FOUND THEN
        CLOSE cr_crapcbr;
        vr_dscritic := 'Atencao! As consultas SPC/Serasa/SCR foram desabilitadas na proposta. Efetue as consultas manualmente.';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapcbr;

      -- Busca a quantidade de horas de reaproveitamento para PF
      OPEN cr_craprbi(vr_inprodut,
                      1); -- Pessoa Fisica
      FETCH cr_craprbi INTO vr_qtdiarpv_pf, vr_qthrsrpv_pf;
      -- Se encontrou, deve-se cancelar a consulta
      IF cr_craprbi%NOTFOUND THEN
        CLOSE cr_craprbi;
        vr_dscritic := 'Nao existe tempo de reaproveitamento cadastrado para pessoa fisica!';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_craprbi;

    END IF;

    -- Se possuir alguma pessoa juridica
    IF pr_inpessoa = 2/* OR vr_inpessoa_av1 = 2 OR vr_inpessoa_av2 = 2*/ THEN
      -- Verifica qual o biro de consulta
      pc_busca_modalidade_prm(pr_cdcooper => pr_cdcooper,
                              pr_inprodut => vr_inprodut,
                              pr_inpessoa => 2, -- Pessoa juridica
                              pr_vlprodut => pr_vlttitbd, --vr_vlemprst,
                              pr_cdbircon => vr_cdbircon_pj,
                              pr_cdmodbir => vr_cdmodbir_pj);
      -- Busca o nome da tag para pessoa juridica
      OPEN cr_crapmbr(vr_cdbircon_pj, vr_cdmodbir_pj);
      FETCH cr_crapmbr INTO vr_nmtagbir_pj, vr_dsbircon_pj;
      IF cr_crapmbr%NOTFOUND THEN
        vr_dscritic := 'TAG para pessoa juridica nao encontrada!';
        CLOSE cr_crapmbr;
        RAISE vr_exc_saida;
      END iF;
      CLOSE cr_crapmbr;

      -- Verifica se o BIRO esta em CONTINGENCIA
      OPEN cr_crapcbr(vr_cdbircon_pj);
      FETCH cr_crapcbr INTO rw_crapcbr;
      -- Se encontrou, deve-se cancelar a consulta
      IF cr_crapcbr%FOUND THEN
        CLOSE cr_crapcbr;
        vr_dscritic := 'Atencao! As consultas SPC/Serasa/SCR foram desabilitadas na proposta. Efetue as consultas manualmente.';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapcbr;

      -- Busca a quantidade de horas de reaproveitamento para PJ
      OPEN cr_craprbi(vr_inprodut,
                      2); -- Pessoa Juridica
      FETCH cr_craprbi INTO vr_qtdiarpv_pj, vr_qthrsrpv_pj;
      -- Se encontrou, deve-se cancelar a consulta
      IF cr_craprbi%NOTFOUND THEN
        CLOSE cr_craprbi;
        vr_dscritic := 'Nao existe tempo de reaproveitamento cadastrado para pessoa juridica!';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_craprbi;

    END IF;

    -- Se o Pagador for CPF, deve-se verificar se tem que consultar SCR
    IF pr_inpessoa = 1 THEN
      -- define o biro e a modalidade de consulta do titular para PF
      vr_cdbircon_tit := vr_cdbircon_pf;
      vr_cdmodbir_tit := vr_cdmodbir_pf;
    ELSE
      -- define o biro e a modalidade de consulta do titular para PJ
      vr_cdbircon_tit := vr_cdbircon_pj;
      vr_cdmodbir_tit := vr_cdmodbir_pj;
      END IF;

    -- Busca a proxima numeracao para consulta do biro
    vr_nrconbir := fn_sequence(pr_nmtabela => 'CRAPCBC', pr_nmdcampo => 'NRCONBIR',pr_dsdchave => '0');

    -- Insere a capa da consulta de biro
    BEGIN
      INSERT INTO crapcbc
        (nrconbir,
         cdcooper,
         dtconbir,
         qtreapro,
         qterrcon,
         qtconsul,
         inprodut,
         dshiscon,
         cdoperad,
         cdpactra)
       VALUES
        (vr_nrconbir,
         pr_cdcooper,
         SYSDATE,
         0,
         0,
         0,
         vr_inprodut,
         lpad(pr_nrdconta,10,'0')||'-'||lpad(pr_nrctrlim,10,'0')||vr_inprodut,
         pr_cdoperad,
         rw_crapope.cdpactra);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        vr_dscritic := 'Erro ao inserir CRAPCBC: '||SQLERRM;
        RAISE vr_exc_saida;
    END;

    -- AWAE: TODO: Atualizar quando for criado o campo NRCONBIR na tabela de Pagador (crapsab) 
    -- Atualiza o codigo da consulta na tabela de limite para o produto Título.
    /*    
    BEGIN
      UPDATE crapsab
         SET nrconbir = vr_nrconbir
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         and nrinssac = vr_nrinssac;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        vr_dscritic := 'Erro ao atualizar a tabela CRAPSAB: '||SQLERRM;
        RAISE vr_exc_saida;
  END;                                 
    */
    
    -- Inicializa o contador de envio de requisicoes
    vr_qtenvreq := 0;

    -- Efetua o loop, pois pode haver duas requisicoes quando o titular for PJ
    LOOP

      -- Inicializa o contador do XML
      vr_contador := 0;

      -- Incrementa o contador de envio de requisicoes
      vr_qtenvreq := vr_qtenvreq + 1;

      -- COMECO DO ENVIO
      -- Cria o cabecalho do xml de envio
      vr_xmlenv := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><LISTA_CONSULTA/>');

      -- Se o titular da consulta for PJ, entao consultar somente ele, pois os avalistas podem ser
      -- os socios e neste caso nao deve-se solicitar a consulta dos avalistas
      IF pr_inpessoa = 2 AND  -- Se for PJ
         vr_qtenvreq = 1 THEN -- E for a primeira requisicao

        -- Verifica se tem como reaproveitar o registro
        IF fn_verifica_reaproveitamento(pr_nrconbir => vr_nrconbir,
                                        pr_cdbircon => vr_cdbircon_tit,
                                        pr_cdmodbir => vr_cdmodbir_tit,
                                        pr_cdcooper => pr_cdcooper,
                                        pr_nrdconta => pr_nrdconta,
                                        pr_nrcpfcgc => pr_nrinssac,
                                        pr_intippes => 1, -- Titular
                                        pr_qtdiarpv => vr_qtdiarpv_pj,
                                        pr_cdcritic => vr_cdcritic,
                                        pr_dscritic => vr_dscritic) THEN
          -- Volta para o inicio do loop, pois nao sera necessario mais enviar a consulta do PJ, pois
          -- o mesmo foi reaproveitado
          continue;
        END IF;

        -- Se ocorreu erro na busca do reaproveitamento, cancela a rotina
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Envia o titular da consulta
        pc_monta_cpf_cnpj_envio(pr_xml      => vr_xmlenv,
                                pr_contador => vr_contador,
                                pr_nmtagbir => vr_nmtagbir_pj,
                                pr_nrcpfcgc => pr_nrinssac,
                                pr_inpessoa => 'J',
                                pr_cdpactra => rw_crapope.cdpactra,
                                pr_qthrsrpv => vr_qthrsrpv_pj,
                                pr_dtconscr => NULL,
                                pr_nrcep    => pr_nrcepsac,
                                pr_dscritic => vr_dscritic);

        -- Incrementa o contador de enviados
        vr_contador := vr_contador + 1;

        -- Insere o titular da consulta para PJ
        pc_insere_crapcbd(pr_nrconbir => vr_nrconbir,
                          pr_cdbircon => vr_cdbircon_tit,
                          pr_cdmodbir => vr_cdmodbir_tit,
                          pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => pr_nrdconta,
                          pr_nrcpfcgc => pr_nrinssac,
                          pr_inpessoa => pr_inpessoa,
                          pr_intippes => 1, -- Titular
                          pr_cdcritic => vr_cdcritic,
                          pr_dscritic => vr_dscritic);
        IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

      ELSE

        -- Enviar o titular somente se for diferente de PJ
        IF pr_inpessoa <> 2 THEN
          -- Verifica se nao tem como reaproveitar o registro
          IF NOT fn_verifica_reaproveitamento(pr_nrconbir => vr_nrconbir,
                                          pr_cdbircon => vr_cdbircon_tit,
                                          pr_cdmodbir => vr_cdmodbir_tit,
                                          pr_cdcooper => pr_cdcooper,
                                          pr_nrdconta => pr_nrdconta,
                                          pr_nrcpfcgc => pr_nrinssac,
                                          pr_intippes => 1, -- Titular
                                          pr_qtdiarpv => vr_qtdiarpv_pf,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic) THEN
            -- Se ocorreu erro na busca do reaproveitamento, cancela a rotina
            IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;

            -- Envia o titular PF da consulta
            pc_monta_cpf_cnpj_envio(pr_xml      => vr_xmlenv,
                                    pr_contador => vr_contador,
                                    pr_nmtagbir => vr_nmtagbir_pf,
                                    pr_nrcpfcgc => pr_nrinssac,
                                    pr_inpessoa => 'F',
                                    pr_cdpactra => rw_crapope.cdpactra,
                                    pr_qthrsrpv => vr_qthrsrpv_pf,
                                    pr_dtconscr => NULL,
                                    pr_nrcep    => pr_nrcepsac,
                                    pr_dscritic => vr_dscritic);

            -- Incrementa o contador de enviados
            vr_contador := vr_contador + 1;

            -- Insere o Pagador da consulta para PF
            pc_insere_crapcbd(pr_nrconbir => vr_nrconbir,
                              pr_cdbircon => vr_cdbircon_tit,
                              pr_cdmodbir => vr_cdmodbir_tit,
                              pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => pr_nrdconta,
                              pr_nrcpfcgc => pr_nrinssac,
                              pr_inpessoa => pr_inpessoa,
                              pr_intippes => 1, -- Titular
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic);
            IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF; -- Fim da verificacao de reaproveitamento
        END IF;
      END IF; -- Fim da verificacao da primeira ou segunda execucao

      -- Se nao existir consultas a serem feitas, sai do loop
      EXIT WHEN vr_contador = 0;

      -- Envia a requisicao
      pc_envia_requisicao(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => pr_nrdconta,
                          pr_nrdocmto => pr_nrctrlim,
                          pr_dsprodut => vr_dsprodut,
                          pr_envioxml => vr_xmlenv,
                          pr_nrprotoc => vr_nrprotoc,
                          pr_cdcritic => vr_cdcritic,
                          pr_dscritic => vr_dscritic);

      -- Se ocorreu erro na requisicao
      IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN

        -- Joga um texto padrao de retorno para a rotina
        vr_dscritic_padrao := 'Houve erro no acesso ao biro (SPC/Serasa/SCR), consulta nao realizada!';

        -- Forca saida da rotina
        RAISE vr_exc_saida;
      END IF;

      -- Se nao veio protocolo, deve-se cancelar
      IF nvl(vr_nrprotoc,'0') = '0' THEN
        vr_dscritic := 'Numero do protocolo nao retornado pelo biro de consultas automatizadas';

        -- Joga um texto padrao de retorno para a rotina
        vr_dscritic_padrao := 'Houve erro no acesso ao biro (SPC/Serasa/SCR), consulta nao realizada!';

        RAISE vr_exc_saida;
      END IF;

      -- Solicita o retorno do biro de consultas. Vai sair somente quando possuir o retorno
      -- ou quando encerrar o tempo de requisicao
      pc_solicita_retorno_req(pr_cdcooper => pr_cdcooper,
                              pr_nrprotoc => vr_nrprotoc,
                              pr_retxml   => vr_xmlret,
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic);

      -- Se ocorreu erro na requisicao
      IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN

        -- Joga um texto padrao de retorno para a rotina
        vr_dscritic_padrao := 'Houve erro no acesso ao biro (SPC/Serasa/SCR), consulta nao realizada!';

        -- Forca saida da rotina
        RAISE vr_exc_saida;
      END IF;

      -- Processa o retorno do biro e grava as tabelas do sistema
      pc_processa_retorno_req(pr_cdcooper => pr_cdcooper,
                              pr_nrconbir => vr_nrconbir,
                              pr_nrprotoc => vr_nrprotoc,
                              pr_nrdconta => pr_nrdconta,
                              pr_nrdocmto => pr_nrctrlim,
                              pr_inprodut => vr_inprodut,
                              pr_tpconaut => 'A',
                              pr_inconscr => vr_inconscr,
                              pr_retxml   => vr_xmlret,
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic);

      -- Se ocorreu erro no processo do XML
      IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN

        -- Joga um texto padrao de retorno para a rotina
        vr_dscritic_padrao := 'Houve erro no acesso ao biro (SPC/Serasa/SCR), consulta nao realizada!';

        -- Forca saida da rotina
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se todas as consultas ja foram feitas para sair do loop
      EXIT WHEN vr_qtenvreq = 2 OR  -- Se ja efetuou as duas consultas
                pr_inpessoa = 1;    -- Se o titular for PF

    END LOOP;

    -- Atualiza as tabelas finais de controle
    pc_atualiza_tab_controle(pr_nrconbir => vr_nrconbir,
                             pr_cdcritic => vr_cdcritic,
                             pr_dscritic => vr_dscritic);
    -- Se ocorreu erro na atualizacao
    IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN

      -- Joga um texto padrao de retorno para a rotina
      vr_dscritic_padrao := 'Houve erro no acesso ao biro (SPC/Serasa/SCR), consulta nao realizada!';

      -- Forca saida da rotina
      RAISE vr_exc_saida;
    END IF;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      --Tratamento na chamada da pc_gera_log_batch CH=660433 / CH=660325
      -- Trata erro na requisicao, mostra paramentros na gravação da tbgen_prglog
      pc_trata_erro_retorno(pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => pr_nrdconta,
                            pr_nrdocmto => pr_nrctrlim,
                            pr_nrprotoc => vr_nrprotoc,
                            pr_nrconbir => vr_nrconbir,
                            pr_dscritic => vr_dscritic,
                            pr_tpocorre => 1);

      IF vr_nrconbir > 0 THEN
        -- Insere na inconsistencia
        GENE0005.pc_gera_inconsistencia(pr_cdcooper => 3 -- CECRED
                                       ,pr_iddgrupo => 4 -- Consulta Automatizada
                                       ,pr_tpincons => 2 -- Erro
                                       ,pr_dsregist => 'Cooperativa: ' || pr_cdcooper
                                                    || ' Conta: '      || pr_nrdconta
                                                    || ' Documento: '  || pr_nrctrlim
                                                    || ' Protocolo do biro: ' || vr_nrprotoc
                                                    || ' Consulta no biro: '  || vr_nrconbir
                                       ,pr_dsincons => vr_dscritic
                                       ,pr_flg_enviar => 'S'
                                       ,pr_des_erro => vr_des_erro
                                       ,pr_dscritic => vr_dscritic_aux);
      END IF;

      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := nvl(vr_dscritic_padrao, vr_dscritic);

    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Efetuar retorno do erro nao tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;

      IF vr_nrconbir > 0 THEN
        -- Insere na inconsistencia
        GENE0005.pc_gera_inconsistencia(pr_cdcooper => 3 -- CECRED
                                       ,pr_iddgrupo => 4 -- Consulta Automatizada
                                       ,pr_tpincons => 2 -- Erro
                                       ,pr_dsregist => 'Cooperativa: ' || pr_cdcooper
                                                    || ' Conta: '      || pr_nrdconta
                                                    || ' Documento: '  || pr_nrctrlim
                                                    || ' Protocolo do biro: ' || vr_nrprotoc
                                                    || ' Consulta no biro: '  || vr_nrconbir
                                       ,pr_dsincons => pr_dscritic
                                       ,pr_flg_enviar => 'S'
                                       ,pr_des_erro => vr_des_erro
                                       ,pr_dscritic => vr_dscritic);
      END IF;

      --Tratamento na chamada da pc_gera_log_batch CH=660433 / CH=660325
      -- Trata erro na requisicao
      pc_trata_erro_retorno(pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => pr_nrdconta,
                            pr_nrdocmto => pr_nrctrlim,
                            pr_nrprotoc => vr_nrprotoc,
                            pr_nrconbir => vr_nrconbir,
                            pr_dscritic => vr_dscritic,
                            pr_tpocorre => 2);
      
  END pc_solicita_cons_bordero_biro;

-- Chama a rotina de consulta ao biro da Ibratan para os emprestimos
PROCEDURE pc_solicita_consulta_biro_xml(pr_cdcooper IN  crapepr.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                        pr_nrdconta IN  crapepr.nrdconta%TYPE, --> Numero da conta de emprestimo
                                        pr_nrdocmto IN  crapepr.nrctremp%TYPE, --> Numero do documento a ser consultado
                                        pr_inprodut IN  PLS_INTEGER,           --> Indicador de produto (1-Emprestimos, 2-Financiamentos, 3-Contrato limite cheque especial, 4-Contrato limite desconto de cheque, 5-Contrato Limite Desconto de Titulos)
                                        pr_cdoperad IN  crapope.cdoperad%TYPE, --> Operador que solicitou a consulta
                                        pr_flvalest IN  PLS_INTEGER DEFAULT 0, --> Valida se proposta esta na esteira de credito
                                        pr_xmllog   IN  VARCHAR2,              --> XML com informações de LOG
                                        pr_cdcritic OUT PLS_INTEGER,           --> Código da crítica
                                        pr_dscritic OUT VARCHAR2,              --> Descrição da crítica
                                        pr_retxml   IN  OUT NOCOPY XMLType,    --> Arquivo de retorno do XML
                                        pr_nmdcampo OUT VARCHAR2,              --> Nome do campo com erro
                                        pr_des_erro OUT VARCHAR2) IS           --> Erros do processo
    vr_dscritic VARCHAR2(500); --> Retorno das criticas de geracao do xml
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_solicita_consulta_biro_xml');  
    
    -- Efetua a consulta no biro da Ibratan
    pc_solicita_consulta_biro(pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => pr_nrdconta,
                              pr_nrdocmto => pr_nrdocmto,
                              pr_inprodut => pr_inprodut,
                              pr_cdoperad => pr_cdoperad,
                              pr_flvalest => pr_flvalest,
                              pr_cdcritic => pr_cdcritic,
                              pr_dscritic => pr_dscritic);

    -- Se ocorreu erro, entao gera o XML de retorno
    IF nvl(pr_cdcritic,0) <> 0 OR pr_dscritic IS NOT NULL THEN
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'erro', pr_tag_cont => pr_dscritic, pr_des_erro => vr_dscritic);
    END IF;
  END;

-- Busca a modalidade parametrizada que devera ser utilizada
PROCEDURE pc_busca_modalidade_prm(pr_cdcooper IN  crappcb.cdcooper%TYPE, --> Codigo da cooperativa
                                  pr_inprodut IN  crappcb.inprodut%TYPE, --> Indicador de produto (1-Emprestimos, 2-Financiamentos, 
                                                                         --  3-Contrato limite cheque especial, 4-Contrato limite desconto de cheque, 
                                                                         --  5-Contrato Limite Desconto de Titulos)
                                  pr_inpessoa IN  crappcb.inpessoa%TYPE, --> Indicador de pessoa (1-Fisica, 2-Juridica)
                                  pr_vlprodut IN  crappcb.vlinicio%TYPE, --> Valor do produto
                                  pr_cdbircon OUT crappcb.cdbircon%TYPE, --> Codigo do biro de consulta
                                  pr_cdmodbir OUT crappcb.cdmodbir%TYPE) IS --> Modalidade do biro de consulta
    -- Busca os parametros de consultas para identificar qual biro sera utilizado
    CURSOR cr_crappcb IS
      SELECT crappcb.cdbircon,
             crappcb.cdmodbir
        FROM crapmbr,
             crappcb
       WHERE crappcb.cdcooper  = pr_cdcooper
         AND crappcb.inprodut  = pr_inprodut
         AND crappcb.inpessoa  = pr_inpessoa
         AND crappcb.vlinicio <= pr_vlprodut 
         AND crapmbr.cdbircon  = crappcb.cdbircon
         AND crapmbr.cdmodbir  = crappcb.cdmodbir
         AND crapmbr.nrordimp <> 0 -- Para nao pegar a consulta Bacen
        ORDER BY crappcb.vlinicio DESC;
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_busca_modalidade_prm');  

    -- Busca os parametros de consultas para identificar qual biro sera utilizado
    OPEN cr_crappcb;
    FETCH cr_crappcb INTO pr_cdbircon, pr_cdmodbir;
    CLOSE cr_crappcb;
  END;

-- Verifica se teve mudanca de faixa, independente do produto
PROCEDURE pc_verifica_mud_faixa(pr_cdcooper IN  crapepr.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                pr_nrdconta IN  crapepr.nrdconta%TYPE, --> Numero da conta de emprestimo
                                pr_nrconbir IN  crapcbd.nrconbir%TYPE, --> Numero da consulta do biro
                                pr_inprodut IN  PLS_INTEGER,           --> Tipo de produto que sera verificado
                                pr_vlprodut IN  crawepr.vlemprst%TYPE, --> Novo valor do produto apos alteracao do valor
                                pr_flmudfai OUT VARCHAR2) IS           --> Indicador de mudanca de faixa
        
    -- Cursor sobre a tabela de associados
    CURSOR cr_crapass IS
      SELECT crapass.inpessoa,
             crapass.nrcpfcgc,
             crapass.cdagenci,
             crapass.vllimcre
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;   
    
    -- Cursor sobre os detalhes da consulta do biro
    CURSOR cr_crapcbd(pr_nrconbir crapcbd.nrconbir%TYPE) IS
      SELECT cdbircon,
             cdmodbir
        FROM crapcbd
       WHERE nrconbir = pr_nrconbir
         AND cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND inreterr = 0; -- Nao ocorreu erro
    rw_crapcbd cr_crapcbd%ROWTYPE;
    
    -- Cursor sobre o cadastro de modalidades do biro
    CURSOR cr_crapmbr(pr_cdbircon crapmbr.cdbircon%TYPE,
                      pr_cdmodbir crapmbr.cdmodbir%TYPE) IS
      SELECT nrordimp
        FROM crapmbr
       WHERE cdbircon = pr_cdbircon
         AND cdmodbir = pr_cdmodbir;
    
    -- Monta o registro de data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    -- Variaveis de erro
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro

    -- Variaveis gerais
    vr_cdbircon     crapmbr.cdbircon%TYPE;     --> Codigo do biro de consultas
    vr_cdmodbir     crapmbr.cdmodbir%TYPE;     --> Codigo da modalidade do biro
    vr_nrordimp_prm crapmbr.nrordimp%TYPE;     --> Ordem de importancia da modalidade da parametrizacao
    vr_nrordimp_epr crapmbr.nrordimp%TYPE;     --> Ordem de importancia da modalidade do imprestimo
    vr_vlemprst     crawepr.vlemprst%TYPE;     --> Valor total de emprestimo que o cooperado possui

  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_verifica_mud_faixa');  
    
    -- Joga como padrao que nao muda o valor
    pr_flmudfai := 'N';

    -- Busca os dados do associado
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;

    -- Se nao encontrar o emprestimo nao deve-se mudar o valor
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      RETURN;
    END IF;
    -- Fecha o cursor de emprestimo
    CLOSE cr_crapass;

    -- Busca o codigo e a modalidade do biro
    OPEN cr_crapcbd(pr_nrconbir);
    FETCH cr_crapcbd INTO rw_crapcbd;
    -- Se nao encontrou consultas eh porque o biro estava fora. Neste caso deve-se fazer nova consulta
    IF cr_crapcbd%NOTFOUND THEN
      pr_flmudfai := 'S';
      CLOSE cr_crapcbd;
      RETURN;
    END IF;
    CLOSE cr_crapcbd;
    
    -- Busca a ordem de importancia do biro existente no emprestimo
    OPEN cr_crapmbr(rw_crapcbd.cdbircon,
                    rw_crapcbd.cdmodbir);
    FETCH cr_crapmbr INTO vr_nrordimp_epr;
    CLOSE cr_crapmbr;
    
    -- Busca a data
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- Busca o valor acumulado de emprestimo que o cooperado possui
    gene0005.pc_saldo_utiliza (pr_cdcooper => pr_cdcooper
                              ,pr_tpdecons => 3
                              ,pr_cdagenci => rw_crapass.cdagenci
                              ,pr_nrdcaixa => 0
                              ,pr_cdoperad => 0
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrcpfcgc => rw_crapass.nrcpfcgc
                              ,pr_idseqttl => 1 
                              ,pr_idorigem => NULL
                              ,pr_dsctrliq => NULL
                              ,pr_cdprogra => 'SSPC0001'
                              ,pr_tab_crapdat => rw_crapdat
                              ,pr_inusatab => TRUE
                              ,pr_vlutiliz => vr_vlemprst
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
      pr_flmudfai := 'N';
      RETURN;
    END IF;

    -- Se for de limite de credito, deve-se subtrair o valor do limite
    IF pr_inprodut = 3 THEN
      vr_vlemprst := vr_vlemprst - rw_crapass.vllimcre;
    END IF;

    -- Atualiza o valor do emprestimo no valor retornado
    vr_vlemprst := vr_vlemprst + pr_vlprodut;

    -- Busca a modalidade parametrizada
    pc_busca_modalidade_prm(pr_cdcooper => pr_cdcooper,
                            pr_inprodut => pr_inprodut,
                            pr_inpessoa => rw_crapass.inpessoa,
                            pr_vlprodut => vr_vlemprst,
                            pr_cdbircon => vr_cdbircon,
                            pr_cdmodbir => vr_cdmodbir);
    
    -- Busca a ordem de importancia do biro existente na parametrizacao
    OPEN cr_crapmbr(vr_cdbircon,
                    vr_cdmodbir);
    FETCH cr_crapmbr INTO vr_nrordimp_prm;
    CLOSE cr_crapmbr;
    
    -- Se a ordem de importancia existente no parametro for maior que a 
    --      ordem de importancia do emprestimo, entao deve-se retornar S (mudou a faixa)
    IF nvl(vr_nrordimp_prm,0) > nvl(vr_nrordimp_epr,0) THEN
      pr_flmudfai := 'S';
    END IF;
    
  END;


-- Verifica se houve mudanca de faixa com base nas consultas ja realizadas para emprestimos e financiamentos.
PROCEDURE pc_verifica_mud_faixa_emp(pr_cdcooper IN  crapepr.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                    pr_nrdconta IN  crapepr.nrdconta%TYPE, --> Numero da conta de emprestimo
                                    pr_nrctremp IN  crapepr.nrctremp%TYPE, --> Numero do contrato de emprestimo
                                    pr_flmudfai OUT VARCHAR2) IS           --> Indicador de mudanca de faixa
        
    -- Cursor sobre a tabela de emprestimos
    CURSOR cr_crawepr IS
      SELECT crawepr.vlemprst,
             crawepr.nrconbir
        FROM crawepr
       WHERE crawepr.cdcooper = pr_cdcooper
         AND crawepr.nrdconta = pr_nrdconta
         AND crawepr.nrctremp = pr_nrctremp;
    rw_crawepr cr_crawepr%ROWTYPE;

  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_verifica_mud_faixa_emp');  
    
    -- Busca o valor do emprestimo e o numero da consulta do biro
    OPEN cr_crawepr;
    FETCH cr_crawepr INTO rw_crawepr;

    -- Se nao encontrar o emprestimo nao deve-se mudar o valor
    IF cr_crawepr%NOTFOUND THEN
      CLOSE cr_crawepr;
      RETURN;
    END IF;
    -- Fecha o cursor de emprestimo
    CLOSE cr_crawepr;

    -- Efetua a verificacao de mudanca de faixa
    pc_verifica_mud_faixa(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => pr_nrdconta,
                          pr_nrconbir => rw_crawepr.nrconbir,
                          pr_inprodut => 1, -- Emprestimo / Financiamento
                          pr_vlprodut => rw_crawepr.vlemprst,
                          pr_flmudfai => pr_flmudfai);
    
  END;

-- Verifica se houve mudanca de faixa com base nas consultas ja realizadas para limites.
PROCEDURE pc_verifica_mud_faixa_lim(pr_cdcooper IN  craplim.cdcooper%TYPE, --> Codigo da cooperativa de limite
                                    pr_nrdconta IN  craplim.nrdconta%TYPE, --> Numero da conta de limite
                                    pr_nrctremp IN  craplim.nrctrlim%TYPE, --> Numero do contrato de limite
                                    pr_flmudfai OUT VARCHAR2) IS           --> Indicador de mudanca de faixa
        
    -- Cursor sobre a tabela de limites
    CURSOR cr_craplim IS
      SELECT craplim.vllimite,
             craplim.nrconbir
        FROM craplim
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.nrctrlim = pr_nrctremp
         AND craplim.tpctrlim = 1; -- Limite de credito
    rw_craplim cr_craplim%ROWTYPE;

  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_verifica_mud_faixa_lim');  
    
    -- Busca o valor do emprestimo e o numero da consulta do biro
    OPEN cr_craplim;
    FETCH cr_craplim INTO rw_craplim;

    -- Se nao encontrar o emprestimo nao deve-se mudar o valor
    IF cr_craplim%NOTFOUND THEN
      CLOSE cr_craplim;
      RETURN;
    END IF;
    -- Fecha o cursor de emprestimo
    CLOSE cr_craplim;

    -- Efetua a verificacao de mudanca de faixa
    pc_verifica_mud_faixa(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => pr_nrdconta,
                          pr_nrconbir => rw_craplim.nrconbir,
                          pr_inprodut => 3, -- Limite de credito
                          pr_vlprodut => rw_craplim.vllimite,
                          pr_flmudfai => pr_flmudfai);
    
  END;


-- Verifica se deve chamar a tela de informacoes cadastrais e nao disparar a consulta
-- Esta rotina eh chamada atraves da alteracao de valor na WEB
PROCEDURE pc_obrigacao_consulta_xml(pr_cdcooper IN  crapass.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                    pr_nrdconta IN  crapass.nrdconta%TYPE, --> Numero da conta de emprestimo
                                    pr_nrctremp IN  crapepr.nrctremp%TYPE, --> Numero do contrato de emprestimo
                                    pr_xmllog   IN  VARCHAR2,              --> XML com informações de LOG
                                    pr_cdcritic OUT PLS_INTEGER,           --> Código da crítica
                                    pr_dscritic OUT VARCHAR2,              --> Descrição da crítica
                                    pr_retxml   IN  OUT NOCOPY XMLType,    --> Arquivo de retorno do XML
                                    pr_nmdcampo OUT VARCHAR2,              --> Nome do campo com erro
                                    pr_des_erro OUT VARCHAR2) IS           --> Erros do processo
    CURSOR cr_crawepr IS
      SELECT crawepr.vlemprst,
             crawepr.cdfinemp,
             crawepr.cdlcremp,
             crapass.inpessoa,
             crapass_1.inpessoa inpessoa_1,
             crapass_2.inpessoa inpessoa_2
        FROM crapass crapass_2, -- Avalista 2
             crapass crapass_1, -- Avalista 1
             crapass,
             crawepr
       WHERE crawepr.cdcooper = pr_cdcooper
         AND crawepr.nrdconta = pr_nrdconta
         AND crawepr.nrctremp = pr_nrctremp
         AND crapass.cdcooper = crawepr.cdcooper
         AND crapass.nrdconta = crawepr.nrdconta
         AND crapass_1.cdcooper (+) = crawepr.cdcooper
         AND crapass_1.nrdconta (+) = crawepr.nrctaav1
         AND crapass_2.cdcooper (+) = crawepr.cdcooper
         AND crapass_2.nrdconta (+) = crawepr.nrctaav2;
    rw_crawepr cr_crawepr%ROWTYPE;

    -- Busca os dados dos avalistas terceiros
    CURSOR cr_crapavt IS
      SELECT crapavt.inpessoa
        FROM crapavt
       WHERE crapavt.cdcooper = pr_cdcooper
         AND crapavt.nrdconta = pr_nrdconta
         AND crapavt.nrctremp = pr_nrctremp
         AND crapavt.tpctrato = 1; -- Emprestimo
    
    vr_dscritic   VARCHAR2(4000); --> descricao do erro

    -- Variaveis de retorno da consulta
    vr_inobriga VARCHAR2(01);
    vr_inpessoa PLS_INTEGER;

  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_obrigacao_consulta_xml');  

    -- Busca os dados dos emprestimos
    OPEN cr_crawepr;
    FETCH cr_crawepr INTO rw_crawepr;
    CLOSE cr_crawepr;
    
    -- Se for tudo pessoa fisica
    IF rw_crawepr.inpessoa = 1 AND nvl(rw_crawepr.inpessoa_1,1) = 1 AND nvl(rw_crawepr.inpessoa_2,1) = 1 THEN
      vr_inpessoa := 1;
    -- Se for tudo pessoa juridica
    ELSIF rw_crawepr.inpessoa = 2 AND nvl(rw_crawepr.inpessoa_1,2) = 2 AND nvl(rw_crawepr.inpessoa_2,2) = 2 THEN
      vr_inpessoa := 2;
    ELSE -- Se tiver ambos (PF e PJ)
      vr_inpessoa := 3;
    END IF;

    -- Cursor sobre os avalistas terceiros
    FOR rw_crapavt IN cr_crapavt LOOP
      -- Se mudou o tipo de pessoa com o que veio do emprestimo
      IF nvl(rw_crapavt.inpessoa,2) = 1 AND vr_inpessoa = 2 OR
         nvl(rw_crapavt.inpessoa,1) = 2 AND vr_inpessoa = 1 THEN
        vr_inpessoa := 3; -- Ambos (PF e PJ)
      END IF;
    END LOOP;
    
    -- Busca o codigo do biro e a sequencia
    pc_obrigacao_consulta(pr_cdcooper, 
                          1, -- Emprestimo
                          vr_inpessoa, 
                          rw_crawepr.vlemprst, 
                          rw_crawepr.cdfinemp, 
                          rw_crawepr.cdlcremp, 
                          vr_inobriga);

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inobriga', pr_tag_cont => vr_inobriga, pr_des_erro => vr_dscritic);

  END;

-- Verifica se deve chamar a tela de informacoes cadastrais e nao disparar a consulta
-- Esta rotina eh chamada atraves da inclusao da proposta na WEB
PROCEDURE pc_obrigacao_cns_cpl_xml(pr_cdcooper IN  crapass.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                   pr_inprodut IN  craprbi.inprodut%TYPE, --> Indicador de tipo de produto
                                   pr_inpessoa IN  crappcb.inpessoa%TYPE, --> Indicador de pessoa (1-Fisica, 2-Juridica, 3-Ambos)
                                   pr_vlprodut IN  crappcb.vlinicio%TYPE, --> Valor do produto
                                   pr_cdfinemp IN  crawepr.cdfinemp%TYPE, --> Codigo da finalidade do emprestimo
                                   pr_cdlcremp IN  craplcr.cdlcremp%TYPE, --> Codigo da linha de credito
                                   pr_xmllog   IN  VARCHAR2,              --> XML com informações de LOG
                                   pr_cdcritic OUT PLS_INTEGER,           --> Código da crítica
                                   pr_dscritic OUT VARCHAR2,              --> Descrição da crítica
                                   pr_retxml   IN  OUT NOCOPY XMLType,    --> Arquivo de retorno do XML
                                   pr_nmdcampo OUT VARCHAR2,              --> Nome do campo com erro
                                   pr_des_erro OUT VARCHAR2) IS           --> Erros do processo
    vr_dscritic   VARCHAR2(4000); --> descricao do erro

    -- Variaveis de retorno da consulta
    vr_inobriga VARCHAR2(01);

  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_obrigacao_cns_cpl_xml');  
    
    -- Exeucta a rotina principal
    pc_obrigacao_consulta(pr_cdcooper, 
                          pr_inprodut,
                          pr_inpessoa, 
                          pr_vlprodut, 
                          pr_cdfinemp, 
                          pr_cdlcremp, 
                          vr_inobriga);

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inobriga', pr_tag_cont => vr_inobriga, pr_des_erro => vr_dscritic);

  END;


-- Verifica se deve chamar a tela de informacoes cadastrais e nao disparar a consulta
PROCEDURE pc_obrigacao_consulta(pr_cdcooper IN  crapass.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                pr_inprodut IN  craprbi.inprodut%TYPE, --> Indicador de tipo de produto
                                pr_inpessoa IN  crappcb.inpessoa%TYPE, --> Indicador de pessoa (1-Fisica, 2-Juridica, 3-Ambos)
                                pr_vlprodut IN  crappcb.vlinicio%TYPE, --> Valor do produto
                                pr_cdfinemp IN  crawepr.cdfinemp%TYPE, --> Codigo da finalidade do emprestimo
                                pr_cdlcremp IN  craplcr.cdlcremp%TYPE, --> Codigo da linha de credito
                                pr_inobriga OUT varchar2) IS --> Retona S (se obriga a consulta) ou N (nao efetuara consulta)
    -- Efetua a busca na linha de credito
    CURSOR cr_craplcr IS
      SELECT 1
        FROM craplcr
       WHERE cdcooper = pr_cdcooper
         AND cdlcremp = pr_cdlcremp
         AND nvl(inconaut,0) = 1; -- Nao deve efetuar consulta
    rw_craplcr cr_craplcr%ROWTYPE;

    -- Busca no cadastro de contingencia para verificar se o biro esta neste estado
    CURSOR cr_crapcbr(pr_cdbircon crapcbr.cdbircon%TYPE) IS
      SELECT 1
        FROM crapcbr
       WHERE cdcooper = pr_cdcooper
         AND cdbircon = pr_cdbircon
         AND dtinicon <= trunc(SYSDATE);
    rw_crapcbr cr_crapcbr%ROWTYPE;

    -- Cursor sobre a tabela de credito pré-aprovado
    CURSOR cr_crappre(pr_inpessoa crapass.inpessoa%TYPE) IS
      SELECT cdfinemp 
        FROM crappre
       WHERE cdcooper = pr_cdcooper
         AND inpessoa = pr_inpessoa
         AND cdfinemp = pr_cdfinemp;
    rw_crappre cr_crappre%ROWTYPE;

    vr_cdcritic PLS_INTEGER;
		vr_dscritic VARCHAR2(4000);
		
    vr_inpessoa crapass.inpessoa%TYPE; --> Indicador do tipo de pessoa (1-Fisica, 2-Juridica)
    vr_cdbircon crapcbd.cdbircon%TYPE; --> Codigo do biro de consulta
    vr_cdmodbir crapcbd.cdmodbir%TYPE; --> Modalidade do biro de consulta
    
    vr_inobriga_esteira_auto VARCHAR2(1);   --> Obrigação de passagem pela Analise Auto Esteira Sim/Não
    
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_obrigacao_consulta');  
    
    -- Efetua a verificacao de linha de credito habilitada para consulta
    -- somente se o produto for de emprestimo / financiamento
    IF pr_inprodut = 1 THEN
      -- Verifica se a linha de credito esta parametrizada para nao efetuar consulta
      OPEN cr_craplcr;
      FETCH cr_craplcr INTO rw_craplcr;
      
      -- Se encontrou registro, deve-se retornar com N, pois a linha de credito eh uma excessao
      IF cr_craplcr%FOUND THEN
        CLOSE cr_craplcr;
        pr_inobriga := 'N';
        RETURN;
      END IF;
      CLOSE cr_craplcr;
			
			-- Somente retornar a obrigação caso a esteira não for efetuar a consulta
      este0001.pc_obrigacao_analise_automatic(pr_cdcooper => pr_cdcooper
                                             ,pr_inpessoa => pr_inpessoa
                                             ,pr_cdfinemp => pr_cdfinemp
			                                       ,pr_cdlcremp => pr_cdlcremp
																						 ,pr_inobriga => vr_inobriga_esteira_auto
																						 ,pr_cdcritic => vr_cdcritic
																						 ,pr_dscritic => vr_dscritic);
      -- Se é obrigatório passagem pela análise automática esteira
      IF vr_inobriga_esteira_auto = 'S' THEN
        -- Remover obrigatoriedade consulta
        pr_inobriga := 'N';
        RETURN;
      END IF;
                                             
    END IF;
    
    -- Se for pessoa fisica e juridica, comeca processando pela psssoa fisica
    IF pr_inpessoa = 3 THEN
      vr_inpessoa := 1;
    ELSE
      vr_inpessoa := pr_inpessoa;
    END IF;
    
    LOOP
      -- Efetuar a verificacao de pre-aprovado somente se for para emprestimo
      IF pr_inprodut = 1 THEN
        -- Verifica se a finalidade eh de pre-aprovado
        OPEN cr_crappre(vr_inpessoa);
        FETCH cr_crappre INTO rw_crappre;
        -- Se encontrou registro, deve-se retornar com N, pois eh de pre-aprovado
        IF cr_crappre%FOUND THEN
          CLOSE cr_crappre;
          pr_inobriga := 'N';
          RETURN;
        END IF;
        CLOSE cr_crappre;      
      END IF;

      -- Busca o biro que deve ser consultado
      pc_busca_modalidade_prm(pr_cdcooper => pr_cdcooper,
                              pr_inprodut => pr_inprodut,
                              pr_inpessoa => vr_inpessoa,
                              pr_vlprodut => pr_vlprodut,
                              pr_cdbircon => vr_cdbircon,
                              pr_cdmodbir => vr_cdmodbir);
                              
      -- Verifica se o biro esta em contingencia
      OPEN cr_crapcbr(vr_cdbircon);
      FETCH cr_crapcbr INTO rw_crapcbr;
      -- Se encontrou registro, deve-se retornar com N, pois esta em contingencia
      IF cr_crapcbr%FOUND THEN
        pr_inobriga := 'C'; -- Neste caso retorna C informando que esta em contingencia
      END IF;
      CLOSE cr_crapcbr;
      
      -- Verifica se deve consultar tambem como PJ
      IF pr_inpessoa = 3 AND vr_inpessoa = 1 THEN
        vr_inpessoa := 2;
      ELSE
        EXIT;
      END IF;
      
    END LOOP;

    IF nvl(pr_inobriga,'N') <> 'C' THEN
      pr_inobriga := 'S';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      pr_inobriga := 'S';
  END;                                  

-- Busca a sequencia da consulta do biro para a tela CONTAS
PROCEDURE pc_busca_consulta_biro(pr_cdcooper IN  crapass.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                 pr_nrdconta IN  crapass.nrdconta%TYPE, --> Numero da conta de emprestimo
                                 pr_nrconbir OUT crapcbd.nrconbir%TYPE, --> Numero da consulta que foi realizada
                                 pr_nrseqdet OUT crapcbd.nrseqdet%TYPE) IS --> Sequencial dentro da consulta que foi realizada
    -- Cursor sobre os detalhes das consultas de biros
    CURSOR cr_crapcbd IS
      SELECT crapcbd.nrconbir,
             crapcbd.nrseqdet
        FROM crapmbr,
             crapcbd,
             crapass,
             crapcbc
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta
         AND crapcbd.cdcooper = crapass.cdcooper
         AND (crapcbd.nrdconta = crapass.nrdconta
          OR  crapcbd.nrcpfcgc = crapass.nrcpfcgc)
         AND crapmbr.cdbircon = crapcbd.cdbircon
         AND crapmbr.cdmodbir = crapcbd.cdmodbir
         AND crapmbr.nrordimp <> 0 -- Descosiderar Bacen
         AND crapcbd.inreterr = 0  -- Nao houve erros
         AND crapcbc.nrconbir = crapcbd.nrconbir
         AND crapcbc.inprodut <> 7
       ORDER BY crapcbd.dtconbir DESC, DTREAPRO; -- Buscar a consulta mais recente
  
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_busca_consulta_biro');  

    -- Busca os detalhes das consultas de biros
    OPEN cr_crapcbd;
    FETCH cr_crapcbd INTO pr_nrconbir, pr_nrseqdet;
    CLOSE cr_crapcbd;
  END;                                 

-- Busca a sequencia da consulta do biro para a tela CONTAS e retorna por xml
PROCEDURE pc_busca_consulta_biro_xml(pr_cdcooper IN  crapass.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                     pr_nrdconta IN  crapass.nrdconta%TYPE, --> Numero da conta de emprestimo
                                     pr_xmllog   IN VARCHAR2,               --> XML com informações de LOG
                                     pr_cdcritic OUT PLS_INTEGER,           --> Código da crítica
                                     pr_dscritic OUT VARCHAR2,              --> Descrição da crítica
                                     pr_retxml   IN OUT NOCOPY XMLType,     --> Arquivo de retorno do XML
                                     pr_nmdcampo OUT VARCHAR2,              --> Nome do campo com erro
                                     pr_des_erro OUT VARCHAR2) IS           --> Erros do processo

    vr_dscritic   VARCHAR2(4000); --> descricao do erro

    -- Variaveis de retorno da consulta
    vr_nrconbir crapcbd.nrconbir%TYPE;
    vr_nrseqdet crapcbd.nrseqdet%TYPE;

  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_busca_consulta_biro_xml');  

    -- Busca o codigo do biro e a sequencia
    pc_busca_consulta_biro(pr_cdcooper, pr_nrdconta, vr_nrconbir, vr_nrseqdet);
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0          , pr_tag_nova => 'nrconbir', pr_tag_cont => vr_nrconbir, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0          , pr_tag_nova => 'nrseqdet', pr_tag_cont => vr_nrseqdet, pr_des_erro => vr_dscritic);

  END;

-- Busca a sequencia da consulta do biro para as telas caracter
PROCEDURE pc_busca_cns_biro(pr_cdcooper       IN  crapass.cdcooper%TYPE, --> Codigo da cooperativa 
                            pr_nrdconta       IN  crapass.nrdconta%TYPE, --> Numero da conta 
                            pr_nrdocmto       IN  crapepr.nrctremp%TYPE, --> Numero do contrato
                            pr_inprodut       IN  craprbi.inprodut%TYPE, --> Indicador de tipo de produto
                            pr_nrdconta_busca IN  crapass.nrdconta%TYPE, --> Numero da conta que se deseja buscar
                            pr_nrcpfcgc_busca IN  crapass.nrcpfcgc%TYPE, --> Numero do CPF/CGC que se deseja buscar
                            pr_nrconbir OUT crapcbd.nrconbir%TYPE,       --> Numero da consulta que foi realizada
                            pr_nrseqdet OUT crapcbd.nrseqdet%TYPE) IS    --> Sequencial dentro da consulta que foi realizada
    -- Cursor sobre os detalhes das consultas de biros para os emprestimos
    CURSOR cr_crapcbd_emp IS
      SELECT crapcbd.nrconbir,
             crapcbd.nrseqdet
        FROM crapmbr,
             crapcbd,
             crawepr
       WHERE crawepr.cdcooper = pr_cdcooper
         AND crawepr.nrdconta = pr_nrdconta
         AND crawepr.nrctremp = pr_nrdocmto
         AND crapcbd.nrconbir = crawepr.nrconbir
         AND crapmbr.cdbircon = crapcbd.cdbircon
         AND crapmbr.cdmodbir = crapcbd.cdmodbir
         AND crapmbr.nrordimp <> 0 -- Descosiderar Bacen
         AND (crapcbd.nrdconta = decode(pr_nrdconta_busca,0,-1,pr_nrdconta_busca)
          OR  crapcbd.nrcpfcgc = pr_nrcpfcgc_busca)
         AND crapcbd.inreterr = 0; -- Nao ocorreu erro

    -- Cursor sobre os detalhes das consultas de biros para os limites de credito
    CURSOR cr_crapcbd_lim IS
      SELECT crapcbd.nrconbir,
             crapcbd.nrseqdet
        FROM crapmbr,
             crapcbd,
             craplim
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.nrctrlim = pr_nrdocmto
         AND craplim.tpctrlim = 1 -- limite de credito
         AND crapcbd.nrconbir = craplim.nrconbir
         AND crapmbr.cdbircon = crapcbd.cdbircon
         AND crapmbr.cdmodbir = crapcbd.cdmodbir
         AND crapmbr.nrordimp <> 0 -- Descosiderar Bacen
         AND (crapcbd.nrdconta = decode(pr_nrdconta_busca,0,-1,pr_nrdconta_busca)
          OR  crapcbd.nrcpfcgc = pr_nrcpfcgc_busca)
         AND crapcbd.inreterr = 0; -- Nao ocorreu erro

  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_busca_cns_biro');  

    -- Busca os detalhes das consultas de biros para o emprestimo
    IF pr_inprodut = 1 THEN
      OPEN cr_crapcbd_emp;
      FETCH cr_crapcbd_emp INTO pr_nrconbir, pr_nrseqdet;
      CLOSE cr_crapcbd_emp;
    ELSIF pr_inprodut = 3 THEN -- Se for limite de credito
      OPEN cr_crapcbd_lim;
      FETCH cr_crapcbd_lim INTO pr_nrconbir, pr_nrseqdet;
      CLOSE cr_crapcbd_lim;
    END IF;
    
  END;                                 

-- Busca a sequencia da consulta do biro para as telas WEB
PROCEDURE pc_busca_cns_biro_xml(pr_cdcooper       IN  crapass.cdcooper%TYPE, --> Codigo da cooperativa
                                pr_nrdconta       IN  crapass.nrdconta%TYPE, --> Numero da conta 
                                pr_nrdocmto       IN  crapepr.nrctremp%TYPE, --> Numero do contrato
                                pr_inprodut       IN  craprbi.inprodut%TYPE, --> Indicador de tipo de produto
                                pr_nrdconta_busca IN  crapass.nrdconta%TYPE, --> Numero da conta que se deseja buscar
                                pr_nrcpfcgc_busca IN  crapass.nrcpfcgc%TYPE, --> Numero do CPF/CGC que se deseja buscar
                                pr_xmllog         IN  VARCHAR2,              --> XML com informações de LOG
                                pr_cdcritic       OUT PLS_INTEGER,           --> Código da crítica
                                pr_dscritic       OUT VARCHAR2,              --> Descrição da crítica
                                pr_retxml         IN  OUT NOCOPY XMLType,    --> Arquivo de retorno do XML
                                pr_nmdcampo       OUT VARCHAR2,              --> Nome do campo com erro
                                pr_des_erro       OUT VARCHAR2) IS           --> Erros do processo

    vr_dscritic   VARCHAR2(4000); --> descricao do erro

    -- Variaveis de retorno da consulta
    vr_nrconbir crapcbd.nrconbir%TYPE;
    vr_nrseqdet crapcbd.nrseqdet%TYPE;

  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_busca_cns_biro_xml');  

    -- Busca o codigo do biro e a sequencia
    pc_busca_cns_biro(pr_cdcooper, pr_nrdconta, pr_nrdocmto, pr_inprodut, pr_nrdconta_busca, pr_nrcpfcgc_busca, vr_nrconbir, vr_nrseqdet);
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'nrconbir', pr_tag_cont => vr_nrconbir, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'nrseqdet', pr_tag_cont => vr_nrseqdet, pr_des_erro => vr_dscritic);

  END;

-- Efetua a consulta geral com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_geral(pr_nrconbir IN  crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                           ,pr_nrseqdet IN  crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                           ,pr_retxml   OUT CLOB                  --> Contem o xml de retorno das informacoes
                           ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    -- Variaveis de retorno da consulta
    vr_xmllog   VARCHAR2(500);
    vr_retxml   XMLType;
    vr_nmdcampo VARCHAR2(500);
    vr_des_erro VARCHAR2(500);
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_consulta_geral');  

    -- busca o xml com os parametros gerais
    pc_consulta_geral_xml(pr_nrconbir => pr_nrconbir,
                          pr_nrseqdet => pr_nrseqdet,
                          pr_xmllog   => vr_xmllog,
                          pr_cdcritic => pr_cdcritic,
                          pr_dscritic => pr_dscritic,
                          pr_retxml   => vr_retxml,  
                          pr_nmdcampo => vr_nmdcampo,
                          pr_des_erro => vr_des_erro);
                          
    -- Se nao ocorreu erro efetua a gravacao na tabela de interface
    IF pr_cdcritic IS NULL AND pr_dscritic IS NULL THEN
      pr_retxml := vr_retxml.getclobval();
    END IF;
  END;
  
-- Efetua a consulta geral com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_geral_xml(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                               ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    -- Cursor sobre o detalhe da consulta do SPC/Serasa
    CURSOR cr_crapcbd IS
      SELECT crapcbd.cdbircon,
             crapcbd.cdmodbir
        FROM crapcbd
       WHERE crapcbd.nrconbir = pr_nrconbir
         AND crapcbd.nrseqdet = pr_nrseqdet
         AND crapcbd.inreterr = 0; -- Nao ocorreu erro
    rw_crapcbd cr_crapcbd%ROWTYPE;
    
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista

    vr_contador   PLS_INTEGER :=0; --> Contador de registros para geracao do xml
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_consulta_geral_xml');  

    -- Verifica qual o biro e a modalidade da consulta
    OPEN cr_crapcbd;
    FETCH cr_crapcbd INTO rw_crapcbd;
    IF cr_crapcbd%NOTFOUND THEN
      CLOSE cr_crapcbd;
      -- Comentado a linha abaixo, pois estava parando o limite.
      --vr_dscritic := 'Não foram efetuadas consultas automatizadas de SPC, Serasa e SCR.'; 
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapcbd;
  
    -- Busca o cabecalho
    pc_consulta_cabecalho(pr_nrconbir => pr_nrconbir,
                          pr_nrseqdet => pr_nrseqdet,
                          pr_xmllog => pr_xmllog,
                          pr_cdcritic => vr_cdcritic,
                          pr_dscritic => vr_dscritic,
                          pr_retxml => pr_retxml,
                          pr_nmdcampo => pr_nmdcampo,
                          pr_des_erro => pr_des_erro);
    IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Busca o resumo das pendencias
    pc_consulta_pendencia_fin(pr_nrconbir => pr_nrconbir,
                              pr_nrseqdet => pr_nrseqdet,
                              pr_innegati => 0,
                              pr_xmllog => pr_xmllog,
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic,
                              pr_retxml => pr_retxml,
                              pr_nmdcampo => pr_nmdcampo,
                              pr_des_erro => pr_des_erro);
    IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Busca os cheques sem fundos
    pc_consulta_cheque(pr_nrconbir => pr_nrconbir,
                       pr_nrseqdet => pr_nrseqdet,
                       pr_idsitchq => 1,
                       pr_xmllog => pr_xmllog,
                       pr_cdcritic => vr_cdcritic,
                       pr_dscritic => vr_dscritic,
                       pr_retxml => pr_retxml,
                       pr_nmdcampo => pr_nmdcampo,
                       pr_des_erro => pr_des_erro);
    IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
    -- Se for SPC, deve-se fazer consultas especificas para este biro
    IF rw_crapcbd.cdbircon = 1 THEN
      -- Busca o SPC
      pc_consulta_spc(pr_nrconbir => pr_nrconbir,
                      pr_nrseqdet => pr_nrseqdet,
                      pr_xmllog => pr_xmllog,
                      pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic,
                      pr_retxml => pr_retxml,
                      pr_nmdcampo => pr_nmdcampo,
                      pr_des_erro => pr_des_erro);
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Se for consulta SPC 65 ou SPC 513 deve-se buscar o PEFIN, REFIN e Protestos
      IF rw_crapcbd.cdmodbir in (2, 3) THEN
        -- Busca o PEFIN/REFIN
        pc_consulta_pefin_refin(pr_nrconbir => pr_nrconbir,
                                pr_nrseqdet => pr_nrseqdet,
                                pr_inpefref => 0,
                                pr_xmllog => pr_xmllog,
                                pr_cdcritic => vr_cdcritic,
                                pr_dscritic => vr_dscritic,
                                pr_retxml => pr_retxml,
                                pr_nmdcampo => pr_nmdcampo,
                                pr_des_erro => pr_des_erro);
        IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        -- Busca os Protestos
        pc_consulta_protesto(pr_nrconbir => pr_nrconbir,
                             pr_nrseqdet => pr_nrseqdet,
                             pr_xmllog => pr_xmllog,
                             pr_cdcritic => vr_cdcritic,
                             pr_dscritic => vr_dscritic,
                             pr_retxml => pr_retxml,
                             pr_nmdcampo => pr_nmdcampo,
                             pr_des_erro => pr_des_erro);
        IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      END IF;
    ELSE -- Se for consulta SERASA
      -- Busca o PEFIN
      pc_consulta_pefin_refin(pr_nrconbir => pr_nrconbir,
                              pr_nrseqdet => pr_nrseqdet,
                              pr_inpefref => 1,
                              pr_xmllog => pr_xmllog,
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic,
                              pr_retxml => pr_retxml,
                              pr_nmdcampo => pr_nmdcampo,
                              pr_des_erro => pr_des_erro);
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Busca o REFIN
      pc_consulta_pefin_refin(pr_nrconbir => pr_nrconbir,
                              pr_nrseqdet => pr_nrseqdet,
                              pr_inpefref => 2,
                              pr_xmllog => pr_xmllog,
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic,
                              pr_retxml => pr_retxml,
                              pr_nmdcampo => pr_nmdcampo,
                              pr_des_erro => pr_des_erro);
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Busca Dívida Vencida
      pc_consulta_pefin_refin(pr_nrconbir => pr_nrconbir,
                              pr_nrseqdet => pr_nrseqdet,
                              pr_inpefref => 3,
                              pr_xmllog => pr_xmllog,
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic,
                              pr_retxml => pr_retxml,
                              pr_nmdcampo => pr_nmdcampo,
                              pr_des_erro => pr_des_erro);
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Busca os Protestos
      pc_consulta_protesto(pr_nrconbir => pr_nrconbir,
                           pr_nrseqdet => pr_nrseqdet,
                           pr_xmllog => pr_xmllog,
                           pr_cdcritic => vr_cdcritic,
                           pr_dscritic => vr_dscritic,
                           pr_retxml => pr_retxml,
                           pr_nmdcampo => pr_nmdcampo,
                           pr_des_erro => pr_des_erro);
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Busca os cheques sinistrados
      pc_consulta_cheque(pr_nrconbir => pr_nrconbir,
                         pr_nrseqdet => pr_nrseqdet,
                         pr_idsitchq => 2,
                         pr_xmllog => pr_xmllog,
                         pr_cdcritic => vr_cdcritic,
                         pr_dscritic => vr_dscritic,
                         pr_retxml => pr_retxml,
                         pr_nmdcampo => pr_nmdcampo,
                         pr_des_erro => pr_des_erro);
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Busca as Acoes
      pc_consulta_acao(pr_nrconbir => pr_nrconbir,
                       pr_nrseqdet => pr_nrseqdet,
                       pr_xmllog => pr_xmllog,
                       pr_cdcritic => vr_cdcritic,
                       pr_dscritic => vr_dscritic,
                       pr_retxml => pr_retxml,
                       pr_nmdcampo => pr_nmdcampo,
                       pr_des_erro => pr_des_erro);
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Busca as falencias
      pc_consulta_falencia(pr_nrconbir => pr_nrconbir,
                           pr_nrseqdet => pr_nrseqdet,
                           pr_xmllog => pr_xmllog,
                           pr_cdcritic => vr_cdcritic,
                           pr_dscritic => vr_dscritic,
                           pr_retxml => pr_retxml,
                           pr_nmdcampo => pr_nmdcampo,
                           pr_des_erro => pr_des_erro);
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Busca os socios
      pc_consulta_socios(pr_nrconbir => pr_nrconbir,
                         pr_nrseqdet => pr_nrseqdet,
                         pr_xmllog => pr_xmllog,
                         pr_cdcritic => vr_cdcritic,
                         pr_dscritic => vr_dscritic,
                         pr_retxml => pr_retxml,
                         pr_nmdcampo => pr_nmdcampo,
                         pr_des_erro => pr_des_erro);
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Busca os administradores
      pc_consulta_administrador(pr_nrconbir => pr_nrconbir,
                                pr_nrseqdet => pr_nrseqdet,
                                pr_xmllog => pr_xmllog,
                                pr_cdcritic => vr_cdcritic,
                                pr_dscritic => vr_dscritic,
                                pr_retxml => pr_retxml,
                                pr_nmdcampo => pr_nmdcampo,
                                pr_des_erro => pr_des_erro);
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Busca os administradores
      pc_consulta_escore(pr_nrconbir => pr_nrconbir,
                         pr_nrseqdet => pr_nrseqdet,
                         pr_xmllog => pr_xmllog,
                         pr_cdcritic => vr_cdcritic,
                         pr_dscritic => vr_dscritic,
                         pr_retxml => pr_retxml,
                         pr_nmdcampo => pr_nmdcampo,
                         pr_des_erro => pr_des_erro);
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
    END IF;

    END IF;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => null);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;


-- Busca os registros do SPC com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_spc(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                         ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                         ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                         ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                         ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                         ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    -- Cursor sobre os registros do SPC
    CURSOR cr_craprsc IS
      SELECT craprsc.nrseqreg,
             decode(craprsc.inlocnac,1,'LOCAL','NACIONAL') inlocnac,
             craprsc.dsinstit,
             craprsc.dsentorg,
             craprsc.nmcidade,
             craprsc.cdufende,
             craprsc.dtregist,
             craprsc.dtvencto,
             craprsc.dsmtvreg,
             craprsc.vlregist
        FROM craprsc
       WHERE craprsc.nrconbir = pr_nrconbir
         AND craprsc.nrseqdet = pr_nrseqdet;
    
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista

    vr_contador   PLS_INTEGER :=0; --> Contador de registros para geracao do xml
    vr_vlregist   craprsc.vlregist%TYPE :=0; --> Somatorio do campo vlregist
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_consulta_spc');  

    -- Criar cabeçalho do XML
    IF pr_retxml IS NULL THEN
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    END IF;
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0          , pr_tag_nova => 'craprsc', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Loop sobre os registros de SPC
    FOR rw_craprsc IN cr_craprsc LOOP
                
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprsc', pr_posicao => 0          , pr_tag_nova => 'craprsc_inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprsc_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nrseqreg', pr_tag_cont => rw_craprsc.nrseqreg, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprsc_inf',   pr_posicao => vr_contador, pr_tag_nova => 'inlocnac', pr_tag_cont => rw_craprsc.inlocnac, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprsc_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dsinstit', pr_tag_cont => rw_craprsc.dsinstit, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprsc_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dsentorg', pr_tag_cont => rw_craprsc.dsentorg, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprsc_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nmcidade', pr_tag_cont => rw_craprsc.nmcidade, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprsc_inf',   pr_posicao => vr_contador, pr_tag_nova => 'cdufende', pr_tag_cont => rw_craprsc.cdufende, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprsc_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dtregist', pr_tag_cont => to_char(rw_craprsc.dtregist,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprsc_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dtvencto', pr_tag_cont => to_char(rw_craprsc.dtvencto,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprsc_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dsmtvreg', pr_tag_cont => rw_craprsc.dsmtvreg, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprsc_inf',   pr_posicao => vr_contador, pr_tag_nova => 'vlregist', pr_tag_cont => to_char(rw_craprsc.vlregist,'fm999G999G990D00'), pr_des_erro => vr_dscritic);

      -- Efetua o acumulador
      vr_vlregist := vr_vlregist + rw_craprsc.vlregist;
      vr_contador := vr_contador + 1;
    END LOOP;       

    -- Insere os nos de totais
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprsc', pr_posicao => 0          , pr_tag_nova => 'contador', pr_tag_cont => to_char(vr_contador,'fm9990'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprsc', pr_posicao => 0          , pr_tag_nova => 'vlregist_tot', pr_tag_cont => to_char(vr_vlregist,'fm999G999G990D00'), pr_des_erro => vr_dscritic);

    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => null);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;

-- Busca os registros de cheques com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_cheque(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                            ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                            ,pr_idsitchq IN crapcsf.idsitchq%TYPE --> Tipo de cheque (1-Sem fundo, 2-Sinis/Extrav)
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    -- Cursor sobre os registros de cheques
    -- Chamado 363148
    CURSOR cr_crapcsf IS
      SELECT crapcsf.nrseqreg,
             crapcsf.nmbanchq,
             crapcsf.cdagechq,
             crapcsf.cdalinea,
             crapcsf.qtcheque,
             crapcsf.nrcheque,
             crapcsf.dtultocr,
             crapcsf.dtinclus,
             crapcsf.vlcheque,
             crapcsf.nmcidade,
             crapcsf.cdufende,
             crapcsf.dsmotivo
        FROM crapcsf
       WHERE crapcsf.nrconbir = pr_nrconbir
         AND crapcsf.nrseqdet = pr_nrseqdet
         AND crapcsf.idsitchq = pr_idsitchq;
    
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista

    vr_contador   PLS_INTEGER :=0; --> Contador de registros para geracao do xml
    vr_nmtagpnc   VARCHAR2(20); --> Nome da tag principal
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_consulta_cheque');  

    IF pr_idsitchq = 1 THEN
      vr_nmtagpnc := 'crapcsf_sem_fundos';
    ELSE
      vr_nmtagpnc := 'crapcsf_sinistrado';
    END IF;
    
    -- Criar cabeçalho do XML
    IF pr_retxml IS NULL THEN
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    END IF;
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0          , pr_tag_nova => vr_nmtagpnc, pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Loop sobre os cheques
    -- Chamado 363148
    FOR rw_crapcsf IN cr_crapcsf LOOP
                
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc, pr_posicao => 0          , pr_tag_nova => vr_nmtagpnc||'_inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nrseqreg', pr_tag_cont => rw_crapcsf.nrseqreg, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nmbanchq', pr_tag_cont => rw_crapcsf.nmbanchq, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'cdagechq', pr_tag_cont => rw_crapcsf.cdagechq, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'cdalinea', pr_tag_cont => rw_crapcsf.cdalinea, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'qtcheque', pr_tag_cont => rw_crapcsf.qtcheque, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nrcheque', pr_tag_cont => rw_crapcsf.nrcheque, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dtultocr', pr_tag_cont => to_char(rw_crapcsf.dtultocr,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dtinclus', pr_tag_cont => to_char(rw_crapcsf.dtinclus,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'vlcheque', pr_tag_cont => to_char(rw_crapcsf.vlcheque,'fm999G999G990D00'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nmcidade', pr_tag_cont => rw_crapcsf.nmcidade, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'cdufende', pr_tag_cont => rw_crapcsf.cdufende, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dsmotivo', pr_tag_cont => rw_crapcsf.dsmotivo, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
    END LOOP;        
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => null);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;

-- Busca os dados do cabecalho com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_cabecalho(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                               ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    -- Cursor sobre o detalhe da consulta do SPC/Serasa
    CURSOR cr_crapcbd IS
      SELECT crapcbd.cdbircon,
             crapcbd.cdmodbir,
             crapcbd.nmtitcon,
             to_char(lpad(crapcbd.nrcpfcgc,decode(crapcbd.inpessoa,2,14,11),'0')) nrcpfcgc,
             crapcbd.dsendere,
             crapcbd.nmbairro,
             crapcbd.nmcidade,
             crapcbd.cdufende,
             decode(crapcbd.nrcepend,null,null,gene0002.fn_mask_cep(crapcbd.nrcepend)) nrcepend,
             crapcbd.dtatuend,
             nvl(crapcbd.dtreapro,crapcbd.dtconbir) dtconbir,
             crapcbd.dslogret,
             crapmbr.dsmodbir,
             decode(nvl(crapcbd.inreapro,0),0,'Nao','Sim') inreapro,
             'DETALHAMENTO DA CONSULTA '||decode(crapcbd.inpessoa,1,'PF','PJ')||
               ' - '||crapbir.dsbircon || ' '||crapmbr.dsmodbir nmtitcab
        FROM crapbir,
             crapmbr,
             crapcbd
       WHERE crapcbd.nrconbir = pr_nrconbir
         AND crapcbd.nrseqdet = pr_nrseqdet
         AND crapbir.cdbircon = crapcbd.cdbircon
         AND crapmbr.cdbircon = crapcbd.cdbircon
         AND crapmbr.cdmodbir = crapcbd.cdmodbir;
    
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista

    vr_contador   PLS_INTEGER :=0; --> Contador de registros para geracao do xml
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_consulta_cabecalho');  

    -- Criar cabeçalho do XML
    IF pr_retxml IS NULL THEN
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    END IF;
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0          , pr_tag_nova => 'crapcbd', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Loop sobre o detalhe da consulta do SPC / Serasa
    FOR rw_crapcbd IN cr_crapcbd LOOP
                
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd', pr_posicao => 0          , pr_tag_nova => 'crapcbd_inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_inf',   pr_posicao => vr_contador, pr_tag_nova => 'cdbircon', pr_tag_cont => rw_crapcbd.cdbircon, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_inf',   pr_posicao => vr_contador, pr_tag_nova => 'cdmodbir', pr_tag_cont => rw_crapcbd.cdmodbir, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dsmodbir', pr_tag_cont => rw_crapcbd.dsmodbir, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nmtitcab', pr_tag_cont => rw_crapcbd.nmtitcab, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nmtitcon', pr_tag_cont => rw_crapcbd.nmtitcon, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nrcpfcgc', pr_tag_cont => rw_crapcbd.nrcpfcgc, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dtconbir', pr_tag_cont => to_char(rw_crapcbd.dtconbir,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dsendere', pr_tag_cont => rw_crapcbd.dsendere, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nmbairro', pr_tag_cont => rw_crapcbd.nmbairro, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nmcidade', pr_tag_cont => rw_crapcbd.nmcidade, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_inf',   pr_posicao => vr_contador, pr_tag_nova => 'cdufende', pr_tag_cont => rw_crapcbd.cdufende, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nrcepend', pr_tag_cont => rw_crapcbd.nrcepend, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dtatuend', pr_tag_cont => to_char(rw_crapcbd.dtatuend,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dslogret', pr_tag_cont => rw_crapcbd.dslogret, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_inf',   pr_posicao => vr_contador, pr_tag_nova => 'inreapro', pr_tag_cont => rw_crapcbd.inreapro, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
    END LOOP;
        
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => null);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;

-- Busca os registros do PEFIN e/ou REFIN com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_pefin_refin(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                                 ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                                 ,pr_inpefref IN crapprf.inpefref%TYPE --> Indicador de Pefin/Refin (1-Pefin, 2-Refin, 0-Todos, 3-Dívida Vencida)
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    -- Cursor sobre o resumo das pendencias financeiras
    CURSOR cr_craprpf IS
      SELECT MAX(craprpf.dtultneg) dtultneg,
             SUM(craprpf.vlnegati) vlnegati,
             SUM(craprpf.qtnegati) qtnegati
        FROM craprpf
       WHERE craprpf.nrconbir = pr_nrconbir
         AND craprpf.nrseqdet = pr_nrseqdet
         AND craprpf.innegati IN (1,2,10)
         AND craprpf.innegati = decode(pr_inpefref,1,2,
                                                   2,1,
                                                   3,10,
                                          craprpf.innegati);
    rw_craprpf cr_craprpf%ROWTYPE;

    -- Cursor sobre os registros do PEFIN/REFIN
    CURSOR cr_crapprf IS
      SELECT crapprf.nrseqreg,
             crapprf.dsinstit,
             crapprf.inpefref,
             crapprf.dtvencto,
             crapprf.vlregist,
             crapprf.dsmtvreg,
             crapprf.dsnature
        FROM crapprf
       WHERE crapprf.nrconbir = pr_nrconbir
         AND crapprf.nrseqdet = pr_nrseqdet
         AND (crapprf.inpefref = decode(pr_inpefref,0,crapprf.inpefref,pr_inpefref)
          OR  crapprf.inpefref IS NULL);
    
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista

    vr_nmtagpnc   VARCHAR2(20); --> Nome da tag principal
    vr_contador   PLS_INTEGER :=0; --> Contador de registros para geracao do xml
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_consulta_pefin_refin');  

    -- Define o nome da tag principal
    IF pr_inpefref = 1 THEN
      vr_nmtagpnc := 'crapprf_pefin';
    ELSIF pr_inpefref = 2 THEN
      vr_nmtagpnc := 'crapprf_refin';
    ELSIF pr_inpefref = 3 THEN
      vr_nmtagpnc := 'crapprf_divida';
    ELSE
      vr_nmtagpnc := 'crapprf';
    END IF;
    
    -- Resumo das pendencias financeiras do Refin/Pefin
    OPEN cr_craprpf;
    FETCH cr_craprpf INTO rw_craprpf;
    CLOSE cr_craprpf ;
    
    -- Criar cabeçalho do XML
    IF pr_retxml IS NULL THEN
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    END IF;
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0          , pr_tag_nova => vr_nmtagpnc, pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Insere os nos de totais
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc, pr_posicao => 0          , pr_tag_nova => 'dtultneg', pr_tag_cont => to_char(rw_craprpf.dtultneg,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc, pr_posicao => 0          , pr_tag_nova => 'vlnegati', pr_tag_cont => to_char(rw_craprpf.vlnegati,'fm999G999G990D00'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc, pr_posicao => 0          , pr_tag_nova => 'qtnegati', pr_tag_cont => to_char(rw_craprpf.qtnegati,'fm999G999G990'), pr_des_erro => vr_dscritic);

    -- Loop sobre os registros de SPC
    FOR rw_crapprf IN cr_crapprf LOOP
                
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc, pr_posicao => 0          , pr_tag_nova => vr_nmtagpnc||'_inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nrseqreg', pr_tag_cont => rw_crapprf.nrseqreg, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dsinstit', pr_tag_cont => rw_crapprf.dsinstit, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'inpefref', pr_tag_cont => rw_crapprf.inpefref, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dtvencto', pr_tag_cont => to_char(rw_crapprf.dtvencto,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'vlregist', pr_tag_cont => to_char(rw_crapprf.vlregist,'fm999G999G990D00'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dsmtvreg', pr_tag_cont => rw_crapprf.dsmtvreg, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dsnature', pr_tag_cont => rw_crapprf.dsnature, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
    END LOOP;
        
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => null);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;

-- Busca os registros de protestos com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_protesto(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                              ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    -- Cursor sobre o resumo das pendencias financeiras
    CURSOR cr_craprpf IS
      SELECT MAX(craprpf.dtultneg) dtultneg,
             SUM(craprpf.vlnegati) vlnegati,
             SUM(craprpf.qtnegati) qtnegati
        FROM craprpf
       WHERE craprpf.nrconbir = pr_nrconbir
         AND craprpf.nrseqdet = pr_nrseqdet
         AND craprpf.innegati = 3; -- Protesto
    rw_craprpf cr_craprpf%ROWTYPE;

    -- Cursor sobre os registros do SPC
    CURSOR cr_crapprt IS
      SELECT crapprt.nmlocprt,
             crapprt.dtprotes,
             sum(crapprt.vlprotes) vlprotes,
             COUNT(*) qtprotes,
             crapprt.nmcidade,
             crapprt.cdufende
        FROM crapprt
       WHERE crapprt.nrconbir = pr_nrconbir
         AND crapprt.nrseqdet = pr_nrseqdet
       GROUP BY crapprt.nmlocprt,
             crapprt.dtprotes,
             crapprt.nmcidade,
             crapprt.cdufende;
    
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista

    vr_contador   PLS_INTEGER :=0; --> Contador de registros para geracao do xml
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_consulta_protesto');  

    -- Resumo das pendencias financeiras do Refin/Pefin
    OPEN cr_craprpf;
    FETCH cr_craprpf INTO rw_craprpf;
    CLOSE cr_craprpf ;
    
    -- Criar cabeçalho do XML
    IF pr_retxml IS NULL THEN
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    END IF;
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0          , pr_tag_nova => 'crapprt', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Insere os nos de totais
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapprt', pr_posicao => 0          , pr_tag_nova => 'dtultneg', pr_tag_cont => to_char(rw_craprpf.dtultneg,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapprt', pr_posicao => 0          , pr_tag_nova => 'vlnegati', pr_tag_cont => to_char(rw_craprpf.vlnegati,'fm999G999G990D00'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapprt', pr_posicao => 0          , pr_tag_nova => 'qtnegati', pr_tag_cont => to_char(rw_craprpf.qtnegati,'fm999G999G990'), pr_des_erro => vr_dscritic);

    -- Loop sobre os registros de protestos
    FOR rw_crapprt IN cr_crapprt LOOP
                
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapprt', pr_posicao => 0          , pr_tag_nova => 'crapprt_inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapprt_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nmlocprt', pr_tag_cont => rw_crapprt.nmlocprt, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapprt_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dtprotes', pr_tag_cont => to_char(rw_crapprt.dtprotes,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapprt_inf',   pr_posicao => vr_contador, pr_tag_nova => 'vlprotes', pr_tag_cont => to_char(rw_crapprt.vlprotes,'fm999G999G990D00'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapprt_inf',   pr_posicao => vr_contador, pr_tag_nova => 'qtprotes', pr_tag_cont => to_char(rw_crapprt.qtprotes,'fm999G999G990'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapprt_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nmcidade', pr_tag_cont => rw_crapprt.nmcidade, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapprt_inf',   pr_posicao => vr_contador, pr_tag_nova => 'cdufende', pr_tag_cont => rw_crapprt.cdufende, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
    END LOOP;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => null);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;

-- Busca o resumo das pendencias financeiras com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_pendencia_fin(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                                   ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                                   ,pr_innegati IN craprpf.innegati%TYPE --> Indicador de negativa (0-Todos, 1-Refin, 2-Pefin, 3-Protesto, 4-Acao judicial, 
                                                                         --  5-Participacao em falencia, 6-Cheque sem fundo, 7-Cheques sustados e extraviados)
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista

    vr_contador   PLS_INTEGER :=0; --> Contador de registros para geracao do xml
    vr_nmtagpnc   VARCHAR2(20); --> Nome da tag principal
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_consulta_pendencia_fin');  

    -- Criar cabeçalho do XML
    IF pr_retxml IS NULL THEN
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    END IF;
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0          , pr_tag_nova => 'craprpf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    
    -- Define a tag principal    
    vr_nmtagpnc := 'craprpf';

    -- Loop sobre os registros de SPC
    FOR rw_craprpf IN cr_craprpf(pr_nrconbir, pr_nrseqdet, pr_innegati) LOOP
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprpf', pr_posicao => 0          , pr_tag_nova => vr_nmtagpnc||'_inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'innegati', pr_tag_cont => rw_craprpf.innegati, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dsnegati', pr_tag_cont => rw_craprpf.dsnegati, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'qtnegati', pr_tag_cont => nvl(to_char(rw_craprpf.qtnegati,'fm999G999G990'), 'Nada consta'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'vlnegati', pr_tag_cont => to_char(rw_craprpf.vlnegati,'fm999G999G990D00'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dtultneg', pr_tag_cont => to_char(rw_craprpf.dtultneg,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
    END LOOP;        
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => null);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;

-- Busca o escore com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_escore(pr_nrconbir IN crapcbd.nrconbir%TYPE, --> Numero da consulta que foi realizada
                             pr_nrseqdet IN crapcbd.nrseqdet%TYPE, --> Sequencial dentro da consulta que foi realizada
                             pr_xmllog   IN VARCHAR2,              --> XML com informações de LOG
                             pr_cdcritic OUT PLS_INTEGER,          --> Código da crítica
                             pr_dscritic OUT VARCHAR2,             --> Descrição da crítica
                             pr_retxml   IN OUT NOCOPY XMLType,    --> Arquivo de retorno do XML
                             pr_nmdcampo OUT VARCHAR2,             --> Nome do campo com erro
                             pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
    -- Cursor sobre os registros de acoes
    cursor cr_crapesc is
      select crapesc.dsescore,
             crapesc.vlpontua,
             crapesc.dsclassi
        from crapesc
       where crapesc.nrconbir = pr_nrconbir
         and crapesc.nrseqdet = pr_nrseqdet;
    
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista

    vr_contador   PLS_INTEGER :=0; --> Contador de registros para geracao do xml
    vr_nmtagpnc   VARCHAR2(20); --> Nome da tag principal
  BEGIN
    -- Inclusão nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_consulta_escore');

    -- Criar cabeçalho do XML
    IF pr_retxml IS NULL THEN
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    END IF;
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0          , pr_tag_nova => 'crapesc', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    
    -- Define a tag principal    
    vr_nmtagpnc := 'crapesc';

    -- Loop sobre os registros de escore
    FOR rw_crapesc IN cr_crapesc LOOP
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapesc', pr_posicao => 0          , pr_tag_nova => vr_nmtagpnc||'_inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dsescore', pr_tag_cont => rw_crapesc.dsescore, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'vlpontua', pr_tag_cont => to_char(rw_crapesc.vlpontua,'fm99990D00'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => vr_nmtagpnc||'_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dsclassi', pr_tag_cont => rw_crapesc.dsclassi, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
    END LOOP;        
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception (pr_cdcooper => null);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;

-- Busca os registros de acoes com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_acao(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                          ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    -- Cursor sobre os registros de acoes
    CURSOR cr_crapabr IS
      SELECT crapabr.nrseqreg,
             crapabr.dtacajud,
             crapabr.dsnataca,
             crapabr.vltotaca,
             crapabr.nrdistri,
             crapabr.nrvaraca,
             crapabr.nmcidade,
             crapabr.cdufende
        FROM crapabr
       WHERE crapabr.nrconbir = pr_nrconbir
         AND crapabr.nrseqdet = pr_nrseqdet;
    
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista

    vr_contador   PLS_INTEGER :=0; --> Contador de registros para geracao do xml
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_consulta_acao');  

    -- Criar cabeçalho do XML
    IF pr_retxml IS NULL THEN
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    END IF;
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0          , pr_tag_nova => 'crapabr', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Loop sobre os registros de acao
    FOR rw_crapabr IN cr_crapabr LOOP
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapabr', pr_posicao => 0          , pr_tag_nova => 'crapabr_inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapabr_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nrseqreg', pr_tag_cont => rw_crapabr.nrseqreg, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapabr_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dtacajud', pr_tag_cont => to_char(rw_crapabr.dtacajud,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapabr_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dsnataca', pr_tag_cont => rw_crapabr.dsnataca, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapabr_inf',   pr_posicao => vr_contador, pr_tag_nova => 'vltotaca', pr_tag_cont => to_char(rw_crapabr.vltotaca,'fm999G999G990D00'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapabr_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nrdistri', pr_tag_cont => rw_crapabr.nrdistri, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapabr_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nrvaraca', pr_tag_cont => rw_crapabr.nrvaraca, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapabr_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nmcidade', pr_tag_cont => rw_crapabr.nmcidade, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapabr_inf',   pr_posicao => vr_contador, pr_tag_nova => 'cdufende', pr_tag_cont => rw_crapabr.cdufende, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
    END LOOP;
        
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => null);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;


-- Busca os dados da consulta Bacen e retorna no formato de XML
PROCEDURE pc_consulta_bacen_xml(pr_cdcooper       IN  crapass.cdcooper%TYPE --> Codigo da cooperativa de emprestimo
                               ,pr_nrdconta       IN  crapass.nrdconta%TYPE --> Numero da conta do emprestimo
                               ,pr_nrdocmto       IN  crapepr.nrctremp%TYPE --> Numero do documento a ser consultado
                               ,pr_inprodut       IN  PLS_INTEGER           --> Indicador de produto (1-Emprestimos, 2-Financiamentos, 3-Contrato limite cheque especial, 4-Contrato limite desconto de cheque, 5-Contrato Limite Desconto de Titulos)
                               ,pr_nrdconta_busca IN  crapass.nrdconta%TYPE --> Numero da conta que se deseja buscar
                               ,pr_nrcpfcgc_busca IN  crapass.nrcpfcgc%TYPE --> Numero do CPF/CGC que se deseja buscar
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    -- Busca o numero do biro para o emprestimo
    CURSOR cr_crawepr IS
      SELECT nrconbir
        FROM crawepr
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctremp = pr_nrdocmto;

    -- Busca o numero do biro para o limite
    CURSOR cr_craplim IS
      SELECT nrconbir 
        FROM craplim
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrlim = pr_nrdocmto
         AND tpctrlim = 1; -- Limite de credito

    -- Cursor sobre os detalhes das consultas de biros
    CURSOR cr_crapcbd(pr_nrconbir crapcbd.nrconbir%TYPE) IS
      SELECT crapcbd.qtopescr,
             crapcbd.qtifoper,
             crapcbd.vltotsfn,
             crapcbd.vlopescr,
             crapcbd.vlprejui
        FROM crapmbr,
             crapcbd
       WHERE crapcbd.nrconbir = pr_nrconbir
         AND crapmbr.cdbircon = crapcbd.cdbircon
         AND crapmbr.cdmodbir = crapcbd.cdmodbir
         AND crapmbr.nrordimp = 0 -- Buscar somente o que for Bacen
         AND (crapcbd.nrdconta = pr_nrdconta_busca
          OR  crapcbd.nrcpfcgc = pr_nrcpfcgc_busca)
         AND crapcbd.inreterr = 0; -- Nao ocorreu erro
    
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista

    vr_contador   PLS_INTEGER :=0; --> Contador de registros para geracao do xml
    vr_nrconbir   crapcbd.nrconbir%TYPE; --> Numero da consulta do biro
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_consulta_bacen_xml');  
  
    -- Se for emprestimo, entao busca os dados na crawepr
    IF pr_inprodut = 1 THEN  
      OPEN cr_crawepr;
      FETCH cr_crawepr INTO vr_nrconbir;
      CLOSE cr_crawepr;
    ELSIF pr_inprodut = 3 THEN   -- Se for limite de credito
      OPEN cr_craplim;
      FETCH cr_craplim INTO vr_nrconbir;
      CLOSE cr_craplim;    
    END IF;
  
    -- Criar cabeçalho do XML
    IF pr_retxml IS NULL THEN
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    END IF;
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0          , pr_tag_nova => 'crapcbd_scr', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Loop sobre os registros de acao
    FOR rw_crapcbd IN cr_crapcbd(vr_nrconbir) LOOP
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_scr',       pr_posicao => 0          , pr_tag_nova => 'crapcbd_scr_inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_scr_inf',   pr_posicao => vr_contador, pr_tag_nova => 'qtopescr', pr_tag_cont => to_char(nvl(rw_crapcbd.qtopescr,0),'fm999G999G990D00'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_scr_inf',   pr_posicao => vr_contador, pr_tag_nova => 'qtifoper', pr_tag_cont => to_char(nvl(rw_crapcbd.qtifoper,0),'fm999G999G990D00'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_scr_inf',   pr_posicao => vr_contador, pr_tag_nova => 'vltotsfn', pr_tag_cont => to_char(nvl(rw_crapcbd.vltotsfn,0),'fm999G999G990D00'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_scr_inf',   pr_posicao => vr_contador, pr_tag_nova => 'vlopescr', pr_tag_cont => to_char(nvl(rw_crapcbd.vlopescr,0),'fm999G999G990D00'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_scr_inf',   pr_posicao => vr_contador, pr_tag_nova => 'vlprejui', pr_tag_cont => to_char(nvl(rw_crapcbd.vlprejui,0),'fm999G999G990D00'), pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
    END LOOP;
        
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;


-- Busca os dados da consulta Bacen
PROCEDURE pc_consulta_bacen(pr_cdcooper       IN  crapass.cdcooper%TYPE --> Codigo da cooperativa de emprestimo
                           ,pr_nrdconta       IN  crapass.nrdconta%TYPE --> Numero da conta do emprestimo
                           ,pr_nrdocmto       IN  crapepr.nrctremp%TYPE --> Numero do documento a ser consultado
                           ,pr_inprodut       IN  PLS_INTEGER           --> Indicador de produto (1-Emprestimos, 2-Financiamentos, 3-Contrato limite cheque especial, 4-Contrato limite desconto de cheque, 5-Contrato Limite Desconto de Titulos)
                           ,pr_nrdconta_busca IN  crapass.nrdconta%TYPE --> Numero da conta que se deseja buscar
                           ,pr_nrcpfcgc_busca IN  crapass.nrcpfcgc%TYPE --> Numero do CPF/CGC que se deseja buscar
                           ,pr_retxml   OUT CLOB                        --> Contem o xml de retorno das informacoes
                           ,pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2) IS                --> Descrição da crítica
    vr_retxml xmltype;
    vr_nmdcampo VARCHAR2(500);
    vr_des_erro VARCHAR2(500);
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_consulta_bacen');  

    pc_consulta_bacen_xml(pr_cdcooper       => pr_cdcooper,
                         pr_nrdconta       => pr_nrdconta,
                         pr_nrdocmto       => pr_nrdocmto,
                         pr_inprodut       => pr_inprodut,
                         pr_nrdconta_busca => pr_nrdconta_busca,
                         pr_nrcpfcgc_busca => pr_nrcpfcgc_busca,
                         pr_xmllog         => NULL,
                         pr_cdcritic       => pr_cdcritic,
                         pr_dscritic       => pr_dscritic,
                         pr_retxml         => vr_retxml,
                         pr_nmdcampo       => vr_nmdcampo,
                         pr_des_erro       => vr_des_erro);
                         
    -- Atualiza o retorno na variavel CLOB
    pr_retxml := vr_retxml.getclobval();
  END;
   
-- Busca os registros de recuperacoes, falencias e concordatas com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_falencia(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                              ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    -- Cursor sobre os registros do SPC
    CURSOR cr_craprfc IS
      SELECT craprfc.nrseqreg,
             craprfc.dtregist,
             craprfc.dstipreg,
             craprfc.dsorgreg,
             craprfc.nmcidade,
             craprfc.cdufende
        FROM craprfc
       WHERE craprfc.nrconbir = pr_nrconbir
         AND craprfc.nrseqdet = pr_nrseqdet;
    
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista

    vr_contador   PLS_INTEGER :=0; --> Contador de registros para geracao do xml
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_consulta_falencia');  

    -- Criar cabeçalho do XML
    IF pr_retxml IS NULL THEN
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    END IF;
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0          , pr_tag_nova => 'craprfc', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Loop sobre os registros de SPC
    FOR rw_craprfc IN cr_craprfc LOOP
                
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprfc', pr_posicao => 0          , pr_tag_nova => 'craprfc_inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprfc_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nrseqreg', pr_tag_cont => rw_craprfc.nrseqreg, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprfc_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dtregist', pr_tag_cont => to_char(rw_craprfc.dtregist,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprfc_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dsinstit', pr_tag_cont => rw_craprfc.dstipreg, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprfc_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dsentorg', pr_tag_cont => rw_craprfc.dsorgreg, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprfc_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nmcidade', pr_tag_cont => rw_craprfc.nmcidade, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprfc_inf',   pr_posicao => vr_contador, pr_tag_nova => 'cdufende', pr_tag_cont => rw_craprfc.cdufende, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
    END LOOP;
        
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => null);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;

-- Busca os registros de socios com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_socios(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                            ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
        
    -- Cursor sobre o detalhe da consulta do SPC/Serasa
    CURSOR cr_crapcbd IS
      SELECT crapcbd.nmtitcon,
             crapcbd.nrcpfcgc,
             crapcbd.dtentsoc,
             crapcbd.percapvt,
             crapcbd.pertotal,
             crapcbd.nrconbir,
             crapcbd.nrseqdet,
             crapcbd.dtatusoc,
             crapcbd.inpessoa
        FROM crapcbd
       WHERE crapcbd.nrconbir = pr_nrconbir
         AND crapcbd.nrcbrsoc = pr_nrconbir
         AND crapcbd.nrsdtsoc = pr_nrseqdet
         AND crapcbd.intippes IN (4,5)
--         AND (nvl(crapcbd.percapvt,0) > 0 OR nvl(crapcbd.pertotal,0) >0 ) -- Colocado para nao mostrar quando eh
--                                                                         -- Somente administrador
       ORDER BY crapcbd.nrcpfcgc; -- Socio e socio/administrador

    -- Cursor sobre o detalhe das participacoes do socio em outras empresas
    CURSOR cr_crappsa(pr_nrseqdet crappsa.nrseqdet%TYPE) IS
      SELECT crappsa.nrcpfcgc nrcpfcgc_empresa,
             crappsa.nmempres,
             crappsa.nmcidade,
             crappsa.cdufende,
             crappsa.pertotal,
             crappsa.nmvincul
        FROM crappsa
       WHERE crappsa.nrconbir = pr_nrconbir
         AND crappsa.nrseqdet = pr_nrseqdet;
         
    
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista

    vr_contador     PLS_INTEGER :=0; --> Contador de registros para geracao do xml
    vr_contador_det PLS_INTEGER :=0; --> Contador de registros de pendencias financeiras para geracao do xml
    vr_contador_psa PLS_INTEGER :=0; --> Contador de registros de pendencias financeiras para geracao do xml
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_consulta_socios');  

    -- Criar cabeçalho do XML
    IF pr_retxml IS NULL THEN
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    END IF;
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0          , pr_tag_nova => 'crapcbd_socio', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Insere os nos de totais

    -- Loop sobre os socios
    FOR rw_crapcbd IN cr_crapcbd LOOP
                
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_socio', pr_posicao => 0          , pr_tag_nova => 'crapcbd_socio_inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_socio_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nmtitcon', pr_tag_cont => rw_crapcbd.nmtitcon, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_socio_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nrcpfcgc', pr_tag_cont => gene0002.fn_mask_cpf_cnpj(rw_crapcbd.nrcpfcgc,rw_crapcbd.inpessoa), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_socio_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dtentsoc', pr_tag_cont => to_char(rw_crapcbd.dtentsoc,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_socio_inf',   pr_posicao => vr_contador, pr_tag_nova => 'percapvt', pr_tag_cont => to_char(rw_crapcbd.percapvt,'990D00'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_socio_inf',   pr_posicao => vr_contador, pr_tag_nova => 'pertotal', pr_tag_cont => to_char(rw_crapcbd.pertotal,'990D00'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_socio_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dtatusoc', pr_tag_cont => to_char(rw_crapcbd.dtatusoc,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);      
  
      -- Insere o no principal das pendencias financeiras
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_socio_inf', pr_posicao => vr_contador, pr_tag_nova => 'craprpf_soc', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

      -- Loop sobre as pendencias financeiras dos socios
      FOR rw_craprpf IN cr_craprpf(rw_crapcbd.nrconbir, rw_crapcbd.nrseqdet, 0) LOOP
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprpf_soc', pr_posicao => vr_contador, pr_tag_nova => 'craprpf_soc_inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprpf_soc_inf',   pr_posicao => vr_contador_det, pr_tag_nova => 'innegati', pr_tag_cont => rw_craprpf.innegati, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprpf_soc_inf',   pr_posicao => vr_contador_det, pr_tag_nova => 'dsnegati', pr_tag_cont => rw_craprpf.dsnegati, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprpf_soc_inf',   pr_posicao => vr_contador_det, pr_tag_nova => 'qtnegati', pr_tag_cont => nvl(to_char(rw_craprpf.qtnegati,'fm999G999G990'), 'Nada consta'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprpf_soc_inf',   pr_posicao => vr_contador_det, pr_tag_nova => 'vlnegati', pr_tag_cont => to_char(rw_craprpf.vlnegati,'fm999G999G990D00'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craprpf_soc_inf',   pr_posicao => vr_contador_det, pr_tag_nova => 'dtultneg', pr_tag_cont => to_char(rw_craprpf.dtultneg,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);
        vr_contador_det := vr_contador_det + 1;
      END LOOP;        

      -- Insere o no principal das participacoes do socio em outras empresas
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_socio_inf', pr_posicao => vr_contador, pr_tag_nova => 'crappsa_soc', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

      -- Loop sobre as participacoes do socio em outras empresas
      FOR rw_crappsa IN cr_crappsa(rw_crapcbd.nrseqdet) LOOP
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crappsa_soc', pr_posicao => vr_contador  , pr_tag_nova => 'crappsa_soc_inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crappsa_soc_inf',   pr_posicao => vr_contador_psa, pr_tag_nova => 'nrcpfcgc_empresa', pr_tag_cont => gene0002.fn_mask_cpf_cnpj(rw_crappsa.nrcpfcgc_empresa,2), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crappsa_soc_inf',   pr_posicao => vr_contador_psa, pr_tag_nova => 'nmempres', pr_tag_cont => rw_crappsa.nmempres, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crappsa_soc_inf',   pr_posicao => vr_contador_psa, pr_tag_nova => 'nmcidade', pr_tag_cont => rw_crappsa.nmcidade, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crappsa_soc_inf',   pr_posicao => vr_contador_psa, pr_tag_nova => 'cdufende', pr_tag_cont => rw_crappsa.cdufende, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crappsa_soc_inf',   pr_posicao => vr_contador_psa, pr_tag_nova => 'pertotal', pr_tag_cont => to_char(rw_crappsa.pertotal,'990D00'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crappsa_soc_inf',   pr_posicao => vr_contador_psa, pr_tag_nova => 'nmvincul', pr_tag_cont => rw_crappsa.nmvincul, pr_des_erro => vr_dscritic);
        vr_contador_psa := vr_contador_psa + 1;
      END LOOP;

      vr_contador := vr_contador + 1;


    END LOOP;
        
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => null);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;


-- Busca os registros de administradores com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_administrador(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                                   ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
        
    -- Cursor sobre o detalhe da consulta do SPC/Serasa
    CURSOR cr_crapcbd IS
      SELECT crapcbd.nmtitcon,
             crapcbd.nrcpfcgc,
             crapcbd.dtentadm,
             crapcbd.dsprofis,
             crapcbd.dtmanadm,
             crapcbd.dtatuadm,
             crapcbd.inpessoa
        FROM crapcbd
       WHERE crapcbd.nrconbir = pr_nrconbir
         AND crapcbd.nrcbrsoc = pr_nrconbir
         AND crapcbd.nrsdtsoc = pr_nrseqdet
         AND crapcbd.intippes = 5; -- Somente administrador
    
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista

    vr_contador   PLS_INTEGER :=0; --> Contador de registros para geracao do xml
    vr_dtmanadm   VARCHAR2(50);    --> Descricao da data do mandato
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_consulta_administrador');  

    -- Criar cabeçalho do XML
    IF pr_retxml IS NULL THEN
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    END IF;
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0          , pr_tag_nova => 'crapcbd_adm', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Insere os nos de totais

    -- Loop sobre os socios
    FOR rw_crapcbd IN cr_crapcbd LOOP
                
      -- Verifica se veio data no mandato
      BEGIN
        vr_dtmanadm := nvl(to_char(to_date(rw_crapcbd.dtmanadm,'YYYYMMDD'),'dd/mm/yyyy'),'INDET.');
      EXCEPTION
        WHEN OTHERS THEN
          vr_dtmanadm := 'INDET.';
      END;
      
      -- Gera os dados de administrador
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_adm', pr_posicao => 0          , pr_tag_nova => 'crapcbd_adm_inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_adm_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nmtitcon', pr_tag_cont => rw_crapcbd.nmtitcon, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_adm_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nrcpfcgc', pr_tag_cont => gene0002.fn_mask_cpf_cnpj(rw_crapcbd.nrcpfcgc,rw_crapcbd.inpessoa), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_adm_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dtentadm', pr_tag_cont => to_char(rw_crapcbd.dtentadm,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_adm_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dsprofis', pr_tag_cont => rw_crapcbd.dsprofis, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_adm_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dtmanadm', pr_tag_cont => vr_dtmanadm, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcbd_adm_inf',   pr_posicao => vr_contador, pr_tag_nova => 'dtatuadm', pr_tag_cont => to_char(rw_crapcbd.dtatuadm,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
    END LOOP;
        
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => null);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;

-- Busca os registros dos socios com administracao em outras empresas 
-- com base em uma sequencia de consulta do biro
PROCEDURE pc_consulta_participacao(pr_nrconbir IN crapcbd.nrconbir%TYPE --> Numero da consulta que foi realizada
                                  ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE --> Sequencial dentro da consulta que foi realizada
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
        
    -- Cursor sobre o detalhe da consulta do SPC/Serasa
    CURSOR cr_crapcbd IS
      SELECT crapcbd.nmtitcon,
             crapcbd.nrcpfcgc,
             crappsa.nrcpfcgc nrcpfcgc_empresa,
             crappsa.nmempres,
             crappsa.nmcidade,
             crappsa.cdufende,
             crappsa.pertotal,
             crappsa.nmvincul
        FROM crappsa,
             crapcbd
       WHERE crapcbd.nrcbrsoc = pr_nrconbir
         AND crapcbd.nrsdtsoc = pr_nrseqdet
         AND crapcbd.intippes IN (4,5) -- Socio e socio/administrador
         AND crappsa.nrconbir = crapcbd.nrconbir
         AND crappsa.nrseqdet = crapcbd.nrseqdet;
         
    
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista

    vr_contador   PLS_INTEGER :=0; --> Contador de registros para geracao do xml
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_consulta_participacao');  

    -- Criar cabeçalho do XML
    IF pr_retxml IS NULL THEN
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    END IF;
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0          , pr_tag_nova => 'crappsa', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Insere os nos de totais

    -- Loop sobre os socios
    FOR rw_crapcbd IN cr_crapcbd LOOP
                
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crappsa', pr_posicao => 0          , pr_tag_nova => 'crappsa_inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crappsa_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nmtitcon', pr_tag_cont => rw_crapcbd.nmtitcon, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crappsa_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nrcpfcgc', pr_tag_cont => rw_crapcbd.nrcpfcgc, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crappsa_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nrcpfcgc_empresa', pr_tag_cont => rw_crapcbd.nrcpfcgc_empresa, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crappsa_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nmempres', pr_tag_cont => rw_crapcbd.nmempres, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crappsa_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nmcidade', pr_tag_cont => rw_crapcbd.nmcidade, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crappsa_inf',   pr_posicao => vr_contador, pr_tag_nova => 'cdufende', pr_tag_cont => rw_crapcbd.cdufende, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crappsa_inf',   pr_posicao => vr_contador, pr_tag_nova => 'pertotal', pr_tag_cont => to_char(rw_crapcbd.pertotal,'990D00'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crappsa_inf',   pr_posicao => vr_contador, pr_tag_nova => 'nmvincul', pr_tag_cont => rw_crapcbd.nmvincul, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
    END LOOP;
        
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => null);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;


-- Retorna se o associado esta com pendencia no Biro de consulta                   
FUNCTION fn_verifica_situacao(pr_nrconbir crapcbd.nrconbir%TYPE, --> Numero da consulta que foi realizada
                              pr_nrseqdet crapcbd.nrseqdet%TYPE) --> Sequencial dentro da consulta que foi realizada
         RETURN VARCHAR2 IS
    -- Efetua busca nas tabelas de pendencias para verificar se o mesmo possui alguma
    CURSOR cr_crapcbd IS
      SELECT nvl(SUM(craprpf.qtnegati),0) qtnegati
        FROM craprpf
       WHERE craprpf.nrconbir = pr_nrconbir
         AND craprpf.nrseqdet = pr_nrseqdet;
    rw_crapcbd cr_crapcbd%ROWTYPE;
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.fn_verifica_situacao');  

    -- Busca as pendencias financeiras
    OPEN cr_crapcbd;
    FETCH cr_crapcbd INTO rw_crapcbd;
    CLOSE cr_crapcbd;
    
    -- Se possuir alguma negativa, retorna como S
    IF rw_crapcbd.qtnegati > 0 THEN
      RETURN 'S';
    END IF;
    
    RETURN 'N';
  END;

-- Retorna se o associado esta com pendencia no Biro de consulta por XML
PROCEDURE pc_verifica_situacao(pr_nrconbir IN  crapcbd.nrconbir%TYPE, --> Numero da consulta que foi realizada
                               pr_nrseqdet IN  crapcbd.nrseqdet%TYPE, --> Sequencial dentro da consulta que foi realizada
                               pr_cdbircon OUT crapbir.cdbircon%TYPE, --> Codigo do biro de consulta
                               pr_dsbircon OUT crapbir.dsbircon%TYPE, --> Descricao do biro de consulta
                               pr_cdmodbir OUT crapmbr.cdmodbir%TYPE, --> Codigo da modalidade de consulta
                               pr_dsmodbir OUT crapmbr.dsmodbir%TYPE, --> Descricao da modalidade de consulta
                               pr_flsituac OUT VARCHAR2) IS           --> Situacao da consulta

      -- Cursor sobre os detalhes da consulta do biro
      CURSOR cr_crapcbd IS
        SELECT crapcbd.cdbircon,
               crapcbd.cdmodbir,
               crapbir.dsbircon,
               crapmbr.dsmodbir
          FROM crapmbr,
               crapbir,
               crapcbd
         WHERE crapcbd.nrconbir = pr_nrconbir
           AND crapcbd.nrseqdet = pr_nrseqdet
           AND crapbir.cdbircon = crapcbd.cdbircon
           AND crapmbr.cdbircon = crapcbd.cdbircon
           AND crapmbr.cdmodbir = crapcbd.cdmodbir;
      rw_crapcbd cr_crapcbd%ROWTYPE;

      vr_dscritic   VARCHAR2(4000); --> descricao do erro

      -- Variaveis de retorno da consulta
      vr_flsituac VARCHAR2(01);

    BEGIN
      -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
      GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_verifica_situacao');  

      -- Se vier com zeros, nao deve retornar nenhum valor nos parametros de saida
      IF nvl(pr_nrconbir,0) = 0 THEN
        RETURN;
      END IF;
      -- Busca o codigo do bir e a sequencia
      pr_flsituac := fn_verifica_situacao(pr_nrconbir, pr_nrseqdet);
      
      -- Busca a modalidade do Biro
      OPEN cr_crapcbd;
      FETCH cr_crapcbd INTO pr_cdbircon, pr_cdmodbir, pr_dsbircon, pr_dsmodbir;
      CLOSE cr_crapcbd;
 
    END;
  
-- Retorna se o associado esta com pendencia no Biro de consulta por XML
PROCEDURE pc_verifica_situacao_xml(pr_nrconbir crapcbd.nrconbir%TYPE, --> Numero da consulta que foi realizada
                                   pr_nrseqdet crapcbd.nrseqdet%TYPE, --> Sequencial dentro da consulta que foi realizada
                                   pr_xmllog   IN VARCHAR2,           --> XML com informações de LOG
                                   pr_cdcritic OUT PLS_INTEGER,       --> Código da crítica
                                   pr_dscritic OUT VARCHAR2,          --> Descrição da crítica
                                   pr_retxml   IN OUT NOCOPY XMLType, --> Arquivo de retorno do XML
                                   pr_nmdcampo OUT VARCHAR2,          --> Nome do campo com erro
                                   pr_des_erro OUT VARCHAR2) IS       --> Erros do processo

      vr_dscritic   VARCHAR2(4000); --> descricao do erro

      -- Variaveis de retorno da consulta
      vr_flsituac VARCHAR2(01);
      vr_nrconbir crapcbd.nrconbir%TYPE;
      vr_nrseqdet crapcbd.nrseqdet%TYPE;
      vr_cdbircon crapbir.cdbircon%TYPE;
      vr_dsbircon crapbir.dsbircon%TYPE;
      vr_cdmodbir crapmbr.cdmodbir%TYPE;
      vr_dsmodbir crapmbr.dsmodbir%TYPE;

    BEGIN
      -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
      GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_verifica_situacao_xml');  

      -- Busca os dados com base na rotina original
      pc_verifica_situacao(pr_nrconbir,
                           pr_nrseqdet,
                           vr_cdbircon,
                           vr_dsbircon,
                           vr_cdmodbir,
                           vr_dsmodbir,
                           vr_flsituac);
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0          , pr_tag_nova => 'flsituac', pr_tag_cont => vr_flsituac, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0          , pr_tag_nova => 'cdbircon', pr_tag_cont => vr_cdbircon, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0          , pr_tag_nova => 'dsbircon', pr_tag_cont => vr_dsbircon, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0          , pr_tag_nova => 'cdmodbir', pr_tag_cont => vr_cdmodbir, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0          , pr_tag_nova => 'dsmodbir', pr_tag_cont => vr_dsmodbir, pr_des_erro => vr_dscritic);

    END;
  
  -- Gera o relatorio com o resumo das pesquisas nos Biros
  PROCEDURE pc_solicita_relato_xml(pr_cdcooper IN crapepr.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                   pr_intiprel IN PLS_INTEGER,           --> Tipo de relatorio. 1-Analitico, 2-Sintetico
                                   pr_dtperini IN DATE,                  --> Data de inicio da consulta
                                   pr_dtperfim IN DATE,                  --> Data final da consulta
                                   pr_cdagenci IN crapage.cdagenci%TYPE, --> Codigo do PA que solicitou a consulta
                                   pr_xmllog   IN VARCHAR2,              --> XML com informações de LOG
                                   pr_cdcritic OUT PLS_INTEGER,          --> Código da crítica
                                   pr_dscritic OUT VARCHAR2,             --> Descrição da crítica
                                   pr_retxml   IN OUT NOCOPY XMLType,    --> Arquivo de retorno do XML
                                   pr_nmdcampo OUT VARCHAR2,             --> Nome do campo com erro
                                   pr_des_erro OUT VARCHAR2) IS          --> Erros do processo    -- Busca os dados da consulta do Biro
    CURSOR cr_crapcbc IS
      SELECT crapcbc.cdcooper,
             crapcop.nmrescop,
             crapcbd.cdbircon,
             crapbir.dsbircon,
             crapcbd.cdmodbir,
             crapmbr.dsmodbir,
             decode(pr_intiprel,1,crapcbc.cdpactra,0) cdagenci,
             decode(pr_intiprel,1,crapage.nmresage,'TODOS') nmresage,
             COUNT(1) - SUM(crapcbd.inreterr) qtdtotok,
             SUM(crapcbd.inreterr) qttoterr,
             COUNT(1) qttotcon,
             row_number() over (partition by crapcbc.cdcooper
                                    order by crapcbc.cdcooper) nrregcop,
             row_number() over (partition by crapcbc.cdcooper, decode(pr_intiprel,1,crapcbc.cdpactra,0)
                                    order by crapcbc.cdcooper, decode(pr_intiprel,1,crapcbc.cdpactra,0)) nrregpac
        FROM crapage,
             crapmbr,
             crapbir,
             crapcop,
             crapcbd,
             crapcbc
       WHERE crapcbc.cdcooper = nvl(pr_cdcooper,crapcbc.cdcooper)
         AND crapcbc.dtconbir BETWEEN pr_dtperini AND pr_dtperfim
         AND crapcbc.cdpactra = nvl(pr_cdagenci,crapcbc.cdpactra)
         AND crapcbd.nrconbir = crapcbc.nrconbir
         AND crapcop.cdcooper = crapcbc.cdcooper
         AND crapbir.cdbircon = crapcbd.cdbircon
         AND crapmbr.cdbircon = crapcbd.cdbircon
         AND crapmbr.cdmodbir = crapcbd.cdmodbir
         AND crapage.cdcooper = crapcbc.cdcooper
         AND crapage.cdagenci = crapcbc.cdpactra
       GROUP BY crapcbc.cdcooper,
             crapcop.nmrescop,
             crapcbd.cdbircon,
             crapbir.dsbircon,
             crapcbd.cdmodbir,
             crapmbr.dsmodbir,
             decode(pr_intiprel,1,crapcbc.cdpactra,0),
             decode(pr_intiprel,1,crapage.nmresage,'TODOS');
    
    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);

    -- Variaveis gerais
    vr_exc_saida  EXCEPTION; --> Excecao prevista
    vr_nrposcop   PLS_INTEGER := 0; --> Posicao da cooperativa no xml
    vr_nrpospac   PLS_INTEGER := 0; --> Posicao do PA no xml
    vr_contador   PLS_INTEGER := 0; --> Contador de registro de detalhes

  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_solicita_relato_xml');  

    -- Cria o no inicial do XML
    pr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><dados/>');   
    
    -- Efetua loop sobre os registros de retornos
    FOR rw_crapcbc IN cr_crapcbc LOOP
      -- Se for o primeiro registro da cooperativa, cria o no inicial
      IF rw_crapcbc.nrregcop = 1 THEN
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dados',   pr_posicao => 0, pr_tag_nova => 'cooperativa', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cooperativa',   pr_posicao => vr_nrposcop, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_crapcbc.cdcooper, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cooperativa',   pr_posicao => vr_nrposcop, pr_tag_nova => 'nmrescop', pr_tag_cont => rw_crapcbc.nmrescop, pr_des_erro => vr_dscritic);
        -- Incrementa o valor da cooperativa
        vr_nrposcop := vr_nrposcop + 1;
      END IF;

      -- Se for o primeiro registro da cooperativa, cria o no inicial
      IF rw_crapcbc.nrregpac = 1 THEN
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cooperativa',   pr_posicao => vr_nrposcop-1, pr_tag_nova => 'pa', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'pa',   pr_posicao => vr_nrpospac, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_crapcbc.cdagenci, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'pa',   pr_posicao => vr_nrpospac, pr_tag_nova => 'nmresage', pr_tag_cont => rw_crapcbc.nmresage, pr_des_erro => vr_dscritic);
        -- Incrementa o valor da cooperativa
        vr_nrpospac := vr_nrpospac + 1;
      END IF;
      
      -- Gera os detalhes        
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'pa',pr_posicao => vr_nrpospac-1, pr_tag_nova => 'detalhe', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe',   pr_posicao => vr_contador, pr_tag_nova => 'cdbircon', pr_tag_cont => rw_crapcbc.cdbircon, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe',   pr_posicao => vr_contador, pr_tag_nova => 'dsbircon', pr_tag_cont => rw_crapcbc.dsbircon, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe',   pr_posicao => vr_contador, pr_tag_nova => 'cdmodbir', pr_tag_cont => rw_crapcbc.cdmodbir, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe',   pr_posicao => vr_contador, pr_tag_nova => 'dsmodbir', pr_tag_cont => rw_crapcbc.dsmodbir, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe',   pr_posicao => vr_contador, pr_tag_nova => 'qttotok', pr_tag_cont => to_char(rw_crapcbc.qttotcon-rw_crapcbc.qttoterr,'fm999G990'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe',   pr_posicao => vr_contador, pr_tag_nova => 'qttoterr', pr_tag_cont => to_char(rw_crapcbc.qttoterr,'fm999G990'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe',   pr_posicao => vr_contador, pr_tag_nova => 'qttotcon', pr_tag_cont => to_char(rw_crapcbc.qttotcon,'fm999G990'), pr_des_erro => vr_dscritic);
      
      vr_contador := vr_contador + 1;
        
    END LOOP;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;
  
  -- Rotina para geracao dos dados de relatorio detalhado
  PROCEDURE pc_solicita_relato_det_xml(pr_cdcooper IN crapepr.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                       pr_dtperini IN DATE,                  --> Data de inicio da consulta
                                       pr_dtperfim IN DATE,                  --> Data final da consulta
                                       pr_cdagenci IN crapage.cdagenci%TYPE, --> Codigo do PA que solicitou a consulta
                                       pr_xmllog   IN VARCHAR2,              --> XML com informações de LOG
                                       pr_cdcritic OUT PLS_INTEGER,          --> Código da crítica
                                       pr_dscritic OUT VARCHAR2,             --> Descrição da crítica
                                       pr_retxml   IN OUT NOCOPY XMLType,    --> Arquivo de retorno do XML
                                       pr_nmdcampo OUT VARCHAR2,             --> Nome do campo com erro
                                       pr_des_erro OUT VARCHAR2) IS          --> Erros do processo    -- Busca os dados da consulta do Biro
    -- Busca os dados da consulta do Biro
    CURSOR cr_crapcbc IS
      SELECT crapcbc.dtconbir,
             crapcbc.cdpactra,
             crapage.nmresage,
             crapcbd.nrdconta,
             crapcbd.nmtitcon,
             crapcbd.nrcpfcgc,
             crapope.nmoperad,
             crapbir.dsbircon,
             crapmbr.dsmodbir,
             crapcbd.inpessoa
        FROM crapope,
             crapage,
             crapmbr,
             crapbir,
             crapcop,
             crapcbd,
             crapcbc
       WHERE crapcbc.cdcooper = pr_cdcooper
         AND crapcbc.dtconbir BETWEEN pr_dtperini AND pr_dtperfim
         AND crapcbc.cdpactra = nvl(pr_cdagenci,crapcbc.cdpactra)
         AND crapcbd.nrconbir = crapcbc.nrconbir
         AND crapcop.cdcooper = crapcbc.cdcooper
         AND crapbir.cdbircon = crapcbd.cdbircon
         AND crapmbr.cdbircon = crapcbd.cdbircon
         AND crapmbr.cdmodbir = crapcbd.cdmodbir
         AND crapage.cdcooper = crapcbc.cdcooper
         AND crapage.cdagenci = crapcbc.cdpactra
         AND crapope.cdcooper = crapcbc.cdcooper
         AND upper(crapope.cdoperad) = upper(crapcbc.cdoperad)
       ORDER BY crapcbc.dtconbir,
             crapcbc.cdpactra,
             crapcbd.nmtitcon;
             
    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);

    -- Variaveis gerais
    vr_exc_saida  EXCEPTION; --> Excecao prevista
    vr_contador   PLS_INTEGER := 0; --> Contador de registro de detalhes

  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_solicita_relato_det_xml');  

    -- Cria o no inicial do XML
    pr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><dados/>');   
    
    -- Efetua loop sobre os registros de retornos
    FOR rw_crapcbc IN cr_crapcbc LOOP
      
      -- Gera os detalhes        
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dados',pr_posicao => 0, pr_tag_nova => 'detalhe', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe',   pr_posicao => vr_contador, pr_tag_nova => 'dtconbir', pr_tag_cont => to_char(rw_crapcbc.dtconbir,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe',   pr_posicao => vr_contador, pr_tag_nova => 'cdpactra', pr_tag_cont => rw_crapcbc.cdpactra, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe',   pr_posicao => vr_contador, pr_tag_nova => 'nmresage', pr_tag_cont => rw_crapcbc.nmresage, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe',   pr_posicao => vr_contador, pr_tag_nova => 'nrdconta', pr_tag_cont => gene0002.fn_mask_conta(rw_crapcbc.nrdconta), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe',   pr_posicao => vr_contador, pr_tag_nova => 'nmtitcon', pr_tag_cont => rw_crapcbc.nmtitcon, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe',   pr_posicao => vr_contador, pr_tag_nova => 'nrcpfcgc', pr_tag_cont => gene0002.fn_mask_cpf_cnpj(rw_crapcbc.nrcpfcgc,rw_crapcbc.inpessoa), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe',   pr_posicao => vr_contador, pr_tag_nova => 'nmoperad', pr_tag_cont => rw_crapcbc.nmoperad, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe',   pr_posicao => vr_contador, pr_tag_nova => 'dsbircon', pr_tag_cont => rw_crapcbc.dsbircon, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe',   pr_posicao => vr_contador, pr_tag_nova => 'dsmodbir', pr_tag_cont => rw_crapcbc.dsmodbir, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
        
    END LOOP;
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;


  -- Atualiza o campo de informacoes cadastrais automaticamente no XML
  PROCEDURE pc_atualiza_inf_cadastrais_xml(pr_cdcooper IN  crapepr.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                           pr_nrdconta IN  crapepr.nrdconta%TYPE, --> Numero da conta de emprestimo
                                           pr_nrdocmto IN  crapepr.nrctremp%TYPE, --> Numero do contrato
                                           pr_inprodut IN  craprbi.inprodut%TYPE, --> Indicador de tipo de produto
                                           pr_xmllog   IN  VARCHAR2,              --> XML com informações de LOG
                                           pr_cdcritic OUT PLS_INTEGER,           --> Código da crítica
                                           pr_dscritic OUT VARCHAR2,              --> Descrição da crítica
                                           pr_retxml   IN  OUT NOCOPY XMLType,    --> Arquivo de retorno do XML
                                           pr_nmdcampo OUT VARCHAR2,              --> Nome do campo com erro
                                           pr_des_erro OUT VARCHAR2) IS           --> Erros do processo

    vr_dscritic   VARCHAR2(4000); --> descricao do erro

    -- Variaveis de retorno da consulta
    vr_nrconbir crapcbd.nrconbir%TYPE;
    vr_nrseqdet crapcbd.nrseqdet%TYPE;

  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_atualiza_inf_cadastrais_xml');  

    -- Busca o codigo do biro e a sequencia
    pc_atualiza_inf_cadastrais(pr_cdcooper, pr_nrdconta, pr_nrdocmto, pr_inprodut, pr_cdcritic, pr_dscritic);
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'cdcritic', pr_tag_cont => vr_nrconbir, pr_des_erro => pr_cdcritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dscritic', pr_tag_cont => vr_nrseqdet, pr_des_erro => pr_dscritic);

  END;

  -- Atualiza o campo de informacoes cadastrais automaticamenteo para os limites de credito
  PROCEDURE pc_atualiza_inf_cad_emp(pr_cdcooper IN  crapepr.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                    pr_nrdconta IN  crapepr.nrdconta%TYPE, --> Numero da conta de emprestimo
                                    pr_nrctremp IN  crapepr.nrctremp%TYPE, --> Numero do contrato
                                    pr_cdcritic OUT PLS_INTEGER,           --> Código da crítica
                                    pr_dscritic OUT VARCHAR2) IS           --> Descrição da crítica
    -- Efetua busca nas tabelas de pendencias para verificar se o mesmo possui alguma
    CURSOR cr_crapcbd IS
      SELECT SUM(NVL(craprpf.vlnegati,0)) vlnegati
            ,SUM(NVL(craprpf.qtnegati,0)) qtnegati
            ,SUM(NVL(crapcbd.vlprejui,0)) vlprejuz
            ,SUM(NVL(DECODE(craprpf.innegati,3,craprpf.qtnegati,0),0)) qtprotest
            ,SUM(NVL(DECODE(craprpf.innegati,4,craprpf.qtnegati,0),0)) qtacaojud
            ,SUM(NVL(DECODE(craprpf.innegati,5,craprpf.qtnegati,0),0)) qtfalenci
            ,SUM(NVL(DECODE(craprpf.innegati,6,craprpf.qtnegati,0),0)) qtchqsemf
        FROM craprpf,
             crapcbd,
             crawepr
       WHERE crawepr.cdcooper = pr_cdcooper
         AND crawepr.nrdconta = pr_nrdconta
         AND crawepr.nrctremp = pr_nrctremp
         AND crapcbd.nrconbir = crawepr.nrconbir
         AND crapcbd.nrdconta = crawepr.nrdconta
         AND crapcbd.inreterr = 0 -- Nao ocorreu erro
         AND craprpf.nrconbir = crapcbd.nrconbir
         AND craprpf.nrseqdet = crapcbd.nrseqdet;
    rw_crapcbd cr_crapcbd%ROWTYPE;
      
    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);

    -- Variaveis gerais
    vr_exc_saida  EXCEPTION; --> Excecao prevista
    vr_nrinfcad   PLS_INTEGER := 1; -- Flag de informacoes cadastrais
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_atualiza_inf_cad_emp');  

    -- Busca as pendencias financeiras
    OPEN cr_crapcbd;
    FETCH cr_crapcbd INTO rw_crapcbd;
    CLOSE cr_crapcbd;
      
    -- Alguma restrição relevante    
    IF rw_crapcbd.vlprejuz + rw_crapcbd.qtprotest +
          rw_crapcbd.qtacaojud + rw_crapcbd.qtfalenci + rw_crapcbd.qtchqsemf > 0 THEN 
      vr_nrinfcad := 4; -- Restricoes relevantes
    -- Se possuir ate 3 restricoes com valor de pendencias for inferior a 1000
    ELSIF (rw_crapcbd.qtnegati BETWEEN 1 AND 3) AND rw_crapcbd.vlnegati <= 1000 THEN
      vr_nrinfcad := 2; -- Ate 3 restricoes com somatoria inferior R$1000.
    -- Acima 4 Restrições ou Valores acima 1000 
    ELSIF rw_crapcbd.qtnegati > 3 OR rw_crapcbd.vlnegati > 1000 THEN 
      vr_nrinfcad := 3; -- Acima 3 restricoes ou somatoria superior R$1000.
    END IF;
      
    -- Atualiza a tabela de emprestimo com a situacao da informacao cadastral
    BEGIN
      UPDATE crapprp
         SET crapprp.nrinfcad = vr_nrinfcad
       WHERE crapprp.cdcooper = pr_cdcooper
         AND crapprp.nrdconta = pr_nrdconta
         AND crapprp.nrctrato = pr_nrctremp
         AND crapprp.tpctrato = 90;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
        vr_dscritic := 'Erro ao atualizar crapprp: '||SQLERRM;
        RAISE vr_exc_saida;
    END;
      
    BEGIN
      UPDATE crapttl 
         SET crapttl.nrinfcad = vr_nrinfcad
       WHERE crapttl.cdcooper = pr_cdcooper
         AND crapttl.nrdconta = pr_nrdconta
         AND crapttl.idseqttl = 1;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
        vr_dscritic := 'Erro ao atualizar crapttl: '||SQLERRM;
        RAISE vr_exc_saida;
    END;

    BEGIN
      UPDATE crapjur
         SET crapjur.nrinfcad = vr_nrinfcad
       WHERE crapjur.cdcooper = pr_cdcooper
         AND crapjur.nrdconta = pr_nrdconta;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
        vr_dscritic := 'Erro ao atualizar crapjur: '||SQLERRM;
        RAISE vr_exc_saida;
    END;
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;

  -- Atualiza o campo de informacoes cadastrais automaticamenteo para os limites de credito
  PROCEDURE pc_atualiza_inf_cad_lim(pr_cdcooper IN  craplim.cdcooper%TYPE, --> Codigo da cooperativa de limite
                                    pr_nrdconta IN  craplim.nrdconta%TYPE, --> Numero da conta de limite
                                    pr_nrctrlim IN  craplim.nrctrlim%TYPE, --> Numero do contrato de limite
                                    pr_cdcritic OUT PLS_INTEGER,           --> Código da crítica
                                    pr_dscritic OUT VARCHAR2) IS           --> Descrição da crítica
    -- Efetua busca nas tabelas de pendencias para verificar se o mesmo possui alguma
    CURSOR cr_crapcbd IS
      SELECT SUM(NVL(craprpf.vlnegati,0)) vlnegati
            ,SUM(NVL(craprpf.qtnegati,0)) qtnegati
            ,SUM(NVL(crapcbd.vlprejui,0)) vlprejuz
            ,SUM(NVL(DECODE(craprpf.innegati,3,craprpf.qtnegati,0),0)) qtprotest
            ,SUM(NVL(DECODE(craprpf.innegati,4,craprpf.qtnegati,0),0)) qtacaojud
            ,SUM(NVL(DECODE(craprpf.innegati,5,craprpf.qtnegati,0),0)) qtfalenci
            ,SUM(NVL(DECODE(craprpf.innegati,6,craprpf.qtnegati,0),0)) qtchqsemf
        FROM craprpf,
             crapcbd,
             craplim
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.nrctrlim = pr_nrctrlim
         AND craplim.tpctrlim = 1 -- limite de credito
         AND crapcbd.nrconbir = craplim.nrconbir
         AND crapcbd.nrdconta = craplim.nrdconta
         AND crapcbd.inreterr = 0 -- Nao ocorreu erro
         AND craprpf.nrconbir = crapcbd.nrconbir
         AND craprpf.nrseqdet = crapcbd.nrseqdet;
    rw_crapcbd cr_crapcbd%ROWTYPE;
      
    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);

    -- Variaveis gerais
    vr_exc_saida  EXCEPTION; --> Excecao prevista
    vr_nrinfcad   PLS_INTEGER := 1; -- Flag de informacoes cadastrais
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_atualiza_inf_cad_lim');  

    -- Busca as pendencias financeiras
    OPEN cr_crapcbd;
    FETCH cr_crapcbd INTO rw_crapcbd;
    CLOSE cr_crapcbd;
      
    -- Alguma restrição relevante    
    IF rw_crapcbd.vlprejuz + rw_crapcbd.qtprotest +
          rw_crapcbd.qtacaojud + rw_crapcbd.qtfalenci + rw_crapcbd.qtchqsemf > 0 THEN 
      vr_nrinfcad := 4; -- Restricoes relevantes
    -- Se possuir ate 3 restricoes com valor de pendencias for inferior a 1000
    ELSIF (rw_crapcbd.qtnegati BETWEEN 1 AND 3) AND rw_crapcbd.vlnegati <= 1000 THEN
      vr_nrinfcad := 2; -- Ate 3 restricoes com somatoria inferior R$1000.
    -- Acima 4 Restrições ou Valores acima 1000 
    ELSIF rw_crapcbd.qtnegati > 3 OR rw_crapcbd.vlnegati > 1000 THEN 
      vr_nrinfcad := 3; -- Acima 3 restricoes ou somatoria superior R$1000.
    END IF;
      
    -- Atualiza a tabela de emprestimo com a situacao da informacao cadastral
    BEGIN
      UPDATE craplim
         SET craplim.nrinfcad = vr_nrinfcad
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.nrctrlim = pr_nrctrlim
         AND craplim.tpctrlim = 1;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
        vr_dscritic := 'Erro ao atualizar craplim: '||SQLERRM;
        RAISE vr_exc_saida;
    END;
      
    -- Atualiza a tabela de limite com a situacao da informacao cadastral
    BEGIN
      UPDATE crapprp
         SET crapprp.nrinfcad = vr_nrinfcad
       WHERE crapprp.cdcooper = pr_cdcooper
         AND crapprp.nrdconta = pr_nrdconta
         AND crapprp.nrctrato = pr_nrctrlim
         AND crapprp.tpctrato = 1;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
        vr_dscritic := 'Erro ao atualizar crapprp: '||SQLERRM;
        RAISE vr_exc_saida;
    END;

    
    -- Atualiza a tabela de titular
    BEGIN
      UPDATE crapttl 
         SET crapttl.nrinfcad = vr_nrinfcad
       WHERE crapttl.cdcooper = pr_cdcooper
         AND crapttl.nrdconta = pr_nrdconta
         AND crapttl.idseqttl = 1;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
        vr_dscritic := 'Erro ao atualizar crapttl: '||SQLERRM;
        RAISE vr_exc_saida;
    END;

    BEGIN
      UPDATE crapjur
         SET crapjur.nrinfcad = vr_nrinfcad
       WHERE crapjur.cdcooper = pr_cdcooper
         AND crapjur.nrdconta = pr_nrdconta;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
        vr_dscritic := 'Erro ao atualizar crapjur: '||SQLERRM;
        RAISE vr_exc_saida;
    END;
        
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;

  -- Atualiza o campo de informacoes cadastrais automaticamenteo na conta
  PROCEDURE pc_atualiza_inf_cad_cta(pr_cdcooper IN  crapepr.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                    pr_nrdconta IN  crapepr.nrdconta%TYPE, --> Numero da conta de emprestimo
                                    pr_cdcritic OUT PLS_INTEGER,           --> Código da crítica
                                    pr_dscritic OUT VARCHAR2) IS           --> Descrição da crítica
    -- Busca o numero da conta
    CURSOR cr_crapcbd_2 IS
      SELECT nrconbir
        FROM crapcbd a
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND inreterr = 0
       ORDER BY dtconbir DESC;
    rw_crapcbd_2 cr_crapcbd_2%ROWTYPE;

    -- Efetua busca nas tabelas de pendencias para verificar se o mesmo possui alguma
    CURSOR cr_crapcbd IS
      SELECT SUM(NVL(craprpf.vlnegati,0)) vlnegati
            ,SUM(NVL(craprpf.qtnegati,0)) qtnegati
            ,SUM(NVL(crapcbd.vlprejui,0)) vlprejuz
            ,SUM(NVL(DECODE(craprpf.innegati,3,craprpf.qtnegati,0),0)) qtprotest
            ,SUM(NVL(DECODE(craprpf.innegati,4,craprpf.qtnegati,0),0)) qtacaojud
            ,SUM(NVL(DECODE(craprpf.innegati,5,craprpf.qtnegati,0),0)) qtfalenci
            ,SUM(NVL(DECODE(craprpf.innegati,6,craprpf.qtnegati,0),0)) qtchqsemf
        FROM craprpf,
             crapcbd
       WHERE crapcbd.nrconbir = rw_crapcbd_2.nrconbir
         AND crapcbd.nrdconta = pr_nrdconta
         AND craprpf.nrconbir = crapcbd.nrconbir
         AND craprpf.nrseqdet = crapcbd.nrseqdet;
    rw_crapcbd cr_crapcbd%ROWTYPE;
      
    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);

    -- Variaveis gerais
    vr_exc_saida  EXCEPTION; --> Excecao prevista
    vr_nrinfcad   PLS_INTEGER := 1; -- Flag de informacoes cadastrais
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_atualiza_inf_cad_cta');  

    -- Abre o numero da consulta do biro 
    OPEN cr_crapcbd_2;
    FETCH cr_crapcbd_2 INTO rw_crapcbd_2;
    CLOSE cr_crapcbd_2;
  
    -- Busca as pendencias financeiras
    OPEN cr_crapcbd;
    FETCH cr_crapcbd INTO rw_crapcbd;
    CLOSE cr_crapcbd;
      
    -- Alguma restrição relevante    
    IF rw_crapcbd.vlprejuz + rw_crapcbd.qtprotest +
          rw_crapcbd.qtacaojud + rw_crapcbd.qtfalenci + rw_crapcbd.qtchqsemf > 0 THEN 
      vr_nrinfcad := 4; -- Restricoes relevantes
    -- Se possuir ate 3 restricoes com valor de pendencias for inferior a 1000
    ELSIF (rw_crapcbd.qtnegati BETWEEN 1 AND 3) AND rw_crapcbd.vlnegati <= 1000 THEN
      vr_nrinfcad := 2; -- Ate 3 restricoes com somatoria inferior R$1000.
    -- Acima 4 Restrições ou Valores acima 1000 
    ELSIF rw_crapcbd.qtnegati > 3 OR rw_crapcbd.vlnegati > 1000 THEN 
      vr_nrinfcad := 3; -- Acima 3 restricoes ou somatoria superior R$1000.
    END IF;
          
    BEGIN
      UPDATE crapttl 
         SET crapttl.nrinfcad = vr_nrinfcad
       WHERE crapttl.cdcooper = pr_cdcooper
         AND crapttl.nrdconta = pr_nrdconta
         AND crapttl.idseqttl = 1;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
        vr_dscritic := 'Erro ao atualizar crapttl: '||SQLERRM;
        RAISE vr_exc_saida;
    END;

    BEGIN
      UPDATE crapjur
         SET crapjur.nrinfcad = vr_nrinfcad
       WHERE crapjur.cdcooper = pr_cdcooper
         AND crapjur.nrdconta = pr_nrdconta;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
        vr_dscritic := 'Erro ao atualizar crapjur: '||SQLERRM;
        RAISE vr_exc_saida;
    END;
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 12/07/2018 - Chamado 663304        
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;

  -- Atualiza o campo de informacoes cadastrais automaticamenteo para os emprestimos
  PROCEDURE pc_atualiza_inf_cadastrais(pr_cdcooper IN  crapepr.cdcooper%TYPE,    --> Codigo da cooperativa de emprestimo
                                       pr_nrdconta IN  crapepr.nrdconta%TYPE,    --> Numero da conta de emprestimo
                                       pr_nrdocmto IN  crapepr.nrctremp%TYPE, --> Numero do contrato
                                       pr_inprodut IN  craprbi.inprodut%TYPE, --> Indicador de tipo de produto
                                       pr_cdcritic OUT PLS_INTEGER,              --> Código da crítica
                                       pr_dscritic OUT VARCHAR2) IS              --> Descrição da crítica
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_atualiza_inf_cadastrais');  

    IF pr_inprodut = 1 THEN -- Se for emprestimo
      pc_atualiza_inf_cad_emp(pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => pr_nrdconta,
                              pr_nrctremp => pr_nrdocmto,
                              pr_cdcritic => pr_cdcritic,
                              pr_dscritic => pr_dscritic);
    
    ELSIF pr_inprodut = 3 THEN -- Se for limite de credito
      pc_atualiza_inf_cad_lim(pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => pr_nrdconta,
                              pr_nrctrlim => pr_nrdocmto,
                              pr_cdcritic => pr_cdcritic,
                              pr_dscritic => pr_dscritic);

    END IF;
  END;



  -- Funcao para conversao de texto em base64
  FUNCTION pc_encode_base64(pr_texto IN VARCHAR2) RETURN VARCHAR2 IS
    v_return VARCHAR2(4000);
    v_offset INTEGER;
    v_chunk_size BINARY_INTEGER := (48 / 4) * 3;
    v_buffer_varchar VARCHAR2(48);
    v_buffer_raw RAW(48);
  BEGIN
    v_offset := 1;
    FOR i IN 1 .. ceil(length(pr_texto) / v_chunk_size) LOOP
      v_buffer_raw := utl_raw.cast_to_raw(substr(pr_texto, v_offset, v_chunk_size));
      v_buffer_raw := utl_encode.base64_encode(v_buffer_raw);
      v_buffer_varchar := utl_raw.cast_to_varchar2(v_buffer_raw);
      v_return := v_return || v_buffer_varchar;
      v_offset := v_offset + v_chunk_size;
    END LOOP;
    RETURN v_return;
  END pc_encode_base64;

  PROCEDURE pc_busca_intippes(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cód. da cooperativa
														 ,pr_nrdconta IN crapass.nrdconta%TYPE     --> Nr. da conta
														 ,pr_nrctremp IN crapepr.nrctremp%TYPE     --> Nr. do contrato de empréstimo
														 ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE     --> Nr. do CPF/CNPJ
														 ,pr_dsclasse IN VARCHAR2                  --> Classe Ibratan
                                                         ,pr_tpctrato IN crapavt.tpctrato%TYPE DEFAULT 1 --> Tipo de Contrato 1-Emprestimo, 8-Limite Desconto Titulo
														 ,pr_nrctapes OUT NUMBER                   --> Conta relacionada
														 ,pr_intippes OUT NUMBER                   --> 1-Titular; 2-Avalista; 3-Conjuge; 7-Repr. Legal/Procurador; 0-Erro.
														 ,pr_inpessoa OUT NUMBER) IS               --> 1-Física; 2- Jurídica
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: pc_busca_intippes
  --  Autor   : Lucas Reinert
  --  Data    : Abril/2017                     Ultima Atualizacao: --/--/----
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Rotina responsável por retornar qual o enquadramento da pessoa na proposta passada 
	--              por parâmetro
  --
  --  Alteracoes: 11/07/2018 - Adicionado o parâmetro pr_tpctrato e o cursor cr_crawlim para buscar informações da
  --                           pessoa do contrato de limite de desconto de titulos (Paulo Penteado GFT)
  --
  --  Alteracoes: 
  ---------------------------------------------------------------------------------------------------------------														 
  BEGIN
		DECLARE
		  -- Tratamento de exceções
			vr_exc_erro EXCEPTION;
      vr_exc_null EXCEPTION;
			
		  -- Variáveis auxiliáres
		  vr_nrctaav1 crawepr.nrctaav1%TYPE;
		  vr_nrctaav2 crawepr.nrctaav2%TYPE;
			vr_nrdconta_av1 crawepr.nrctaav1%TYPE;
			vr_nrdconta_av2 crawepr.nrctaav1%TYPE;
			vr_inconcje crawepr.inconcje%TYPE;
			vr_nrcpfcgc crapass.nrcpfcgc%TYPE;
			vr_inpessoa crapass.inpessoa%TYPE;
			vr_nrcpfcgc_cje crapass.nrcpfcgc%TYPE;
			vr_nrdconta_cje crawepr.nrctaav1%TYPE;
			vr_inpessoa_cje crapass.inpessoa%TYPE;
			vr_nrcpfcgc_av1 crapass.nrcpfcgc%TYPE;
			vr_inpessoa_av1 crapass.inpessoa%TYPE;
			vr_nrcpfcgc_av2 crapass.nrcpfcgc%TYPE;
			vr_inpessoa_av2 crapass.inpessoa%TYPE;
			vr_stsnrcal BOOLEAN; --> validação tipo de pessoa
			
			-- Cursor sobre os dados de emprestimo
			CURSOR cr_crawepr IS
				SELECT crawepr.nrctaav1
							,crawepr.nrctaav2
							,crawepr.inconcje
					FROM crawepr
				 WHERE crawepr.cdcooper = pr_cdcooper
					 AND crawepr.nrdconta = pr_nrdconta
					 AND crawepr.nrctremp = pr_nrctremp
					 AND crawepr.dsprotoc IS NOT NULL;
					 
   -- Cursor sobre os dados de contrato de limite desconto titulo
   CURSOR cr_crawlim IS
   SELECT lim.nrctaav1
         ,lim.nrctaav2
         ,lim.inconcje
     FROM crawlim lim
    WHERE lim.cdcooper = pr_cdcooper
      AND lim.nrdconta = pr_nrdconta
      AND lim.nrctrlim = pr_nrctremp
      AND lim.tpctrlim = 3
      AND lim.dsprotoc IS NOT NULL;
           
			-- Buscar os dados do associado
			CURSOR cr_crapass(pr_nrdconta crapass.nrdconta%TYPE) IS
				SELECT crapass.nrcpfcgc,
							 crapass.inpessoa
					FROM crapass
				 WHERE crapass.cdcooper = pr_cdcooper
					 AND crapass.nrdconta = pr_nrdconta;
					 
			-- Cursor sobre os dados do conjuge
			CURSOR cr_crapcje IS
				SELECT crapcje.nrctacje
				      ,1 inpessoa
				      ,nvl(crapass.nrcpfcgc,crapcje.nrcpfcjg) nrcpfcjg
					FROM crapass,
							 crapcje
				 WHERE crapcje.cdcooper = pr_cdcooper
					 AND crapcje.nrdconta = pr_nrdconta
					 AND crapcje.idseqttl = 1
					 AND crapass.cdcooper (+) = crapcje.cdcooper
					 AND crapass.nrdconta (+) = crapcje.nrctacje
					 AND (crapcje.nrcpfcjg <> 0 OR crapass.nrcpfcgc IS NOT NULL);			
					 
			-- Busca os dados dos avalistas terceiros
			CURSOR cr_crapavt IS
				SELECT crapavt.nrcpfcgc,
							 crapavt.inpessoa
					FROM crapavt
				 WHERE crapavt.cdcooper = pr_cdcooper
					 AND crapavt.nrdconta = pr_nrdconta
					 AND crapavt.nrctremp = pr_nrctremp
           AND crapavt.tpctrato = pr_tpctrato;                
					 					 
		BEGIN
			-- Buscar as informações da proposta
   IF pr_tpctrato = 8 THEN
     OPEN  cr_crawlim;
     FETCH cr_crawlim INTO vr_nrctaav1
                          ,vr_nrctaav2
                          ,vr_inconcje;
     IF    cr_crawlim%NOTFOUND THEN
           CLOSE cr_crawlim;
           RAISE vr_exc_erro;
     END   IF;
     CLOSE cr_crawlim;
     
   ELSE
      -- Buscar as informaçoes da proposta
			OPEN cr_crawepr;
      FETCH cr_crawepr 
       INTO vr_nrctaav1
           ,vr_nrctaav2
           ,vr_inconcje;
					 
      -- Se nao encontrar o emprestimo, retorna com 0
      IF cr_crawepr%NOTFOUND THEN
        CLOSE cr_crawepr;
				RAISE vr_exc_erro;
      END IF;
      -- Fecha o cursor de emprestimo
      CLOSE cr_crawepr;
   END IF;
			
      -- Popula as variaveis do titular da consulta
			OPEN cr_crapass(pr_nrdconta);
			FETCH cr_crapass INTO vr_nrcpfcgc, vr_inpessoa;
			IF cr_crapass%NOTFOUND THEN
				CLOSE cr_crapass;
				RAISE vr_exc_erro;
			END IF;
			CLOSE cr_crapass;	
			
			-- Caso for o titular da proposta
			IF vr_nrcpfcgc = pr_nrcpfcgc THEN
				 -- Titular da conta
				 pr_nrctapes := pr_nrdconta;
				 pr_intippes := 1;
				 pr_inpessoa := vr_inpessoa;
				 -- Retornar
				 RETURN; 
			END IF;	
			 
		 	-- Se for para consultar conjuge, busca os dados do conjuge
			IF vr_inpessoa = 1 THEN
				OPEN cr_crapcje;
				FETCH cr_crapcje INTO vr_nrdconta_cje,vr_inpessoa_cje, vr_nrcpfcgc_cje;
				CLOSE cr_crapcje;
				
				-- Caso o CPF do conjuge for o da consulta
				IF vr_nrcpfcgc_cje = pr_nrcpfcgc AND NVL(pr_dsclasse,'C') = 'C' THEN
					 -- Conjuge
					 pr_nrctapes := vr_nrdconta_cje;
				   pr_intippes := 3;
				   pr_inpessoa := vr_inpessoa_cje;
					 -- Retornar
           RETURN; 
				END IF;
			END IF;
			
			-- Verifica se o avalista possui conta na cooperativa
			IF nvl(vr_nrctaav1,0) <> 0 THEN
				-- Popula as variaveis do avalista 2
        vr_nrdconta_av1 := vr_nrctaav1;
        -- Buscar conta do avalista
				OPEN cr_crapass(vr_nrdconta_av1);
				FETCH cr_crapass INTO vr_nrcpfcgc_av1, vr_inpessoa_av1;
				-- Se não encontrou
				IF cr_crapass%NOTFOUND THEN
					CLOSE cr_crapass;
					vr_nrcpfcgc_av1 := 0;
          vr_nrdconta_av1 := 0;
				END IF;
				CLOSE cr_crapass;
			END IF;
			
			-- Verifica se o avalista possui conta na cooperativa
			IF nvl(vr_nrctaav2,0) <> 0 THEN
				-- Popula as variaveis do avalista 2
        vr_nrdconta_av2 := vr_nrctaav2;
			  -- Buscar conta do avalista
				OPEN cr_crapass(vr_nrdconta_av2);
				FETCH cr_crapass INTO vr_nrcpfcgc_av2, vr_inpessoa_av2;
				-- Se não encontrou
				IF cr_crapass%NOTFOUND THEN
					CLOSE cr_crapass;
					vr_nrcpfcgc_av2 := 0;
          vr_nrdconta_av2 := 0;
				END IF;
				CLOSE cr_crapass;
			END IF; 			
			
			-- Busca os avalistas terceiros
			FOR rw_crapavt IN cr_crapavt LOOP
				-- Se nao tiver avalista 1, utiliza o avalista terceiro para jogar neste local
				IF nvl(vr_nrdconta_av1,0) = 0 AND vr_nrcpfcgc_av1 IS NULL THEN
					vr_nrcpfcgc_av1 := rw_crapavt.nrcpfcgc;
          vr_nrdconta_av1 := 0;
					vr_inpessoa_av1 := rw_crapavt.inpessoa;
				ELSIF nvl(vr_nrdconta_av2,0) = 0 THEN -- Se nao tiver avalista 2
					vr_nrcpfcgc_av2 := rw_crapavt.nrcpfcgc;
          vr_nrdconta_av2 := 0;
					vr_inpessoa_av2 := rw_crapavt.inpessoa;
				END IF;
			END LOOP;			
			
			-- Caso for um dos avalistas da proposta
			IF vr_nrcpfcgc_av1 = pr_nrcpfcgc AND NVL(pr_dsclasse,'A') = 'A' THEN 
				-- Avalista
				pr_intippes := 2;
        pr_nrctapes := vr_nrdconta_av1;
				pr_inpessoa := vr_inpessoa_av1;
				RETURN;
			ELSIF vr_nrcpfcgc_av2 = pr_nrcpfcgc AND NVL(pr_dsclasse,'A') = 'A' THEN
				-- Avalista				
				pr_intippes := 2;
        pr_nrctapes := vr_nrdconta_av2;
				pr_inpessoa := vr_inpessoa_av2;
				RETURN;				
			END IF;

      -- Sem conta
      pr_nrctapes := 0;
			
      -- Buscar tipo de pessoa
      gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => pr_nrcpfcgc
                                 ,pr_stsnrcal => vr_stsnrcal
                                 ,pr_inpessoa => pr_inpessoa);
      
	  IF NVL(pr_dsclasse,' ') = 'S' THEN
        pr_intippes := 4;          
      ELSIF NVL(pr_dsclasse,' ') = 'T' THEN
        pr_intippes := 6;          
      ELSE
        -- Qualquer outro caso retornaremos o tipo 7 - Representante Legal/Procurador e PF
		pr_intippes := 7;
      END IF;  
			
		EXCEPTION
			WHEN vr_exc_erro THEN
				-- Retorna Tipo pessoa com 0 -> Erro
        pr_intippes := 0;
        pr_nrctapes := 0;
        pr_inpessoa := 0;
			WHEN OTHERS THEN
				-- Retorna Tipo pessoa com 0 -> Erro
        pr_intippes := 0;
        pr_nrctapes := 0;
        pr_inpessoa := 0;
		END;
	END pc_busca_intippes;

-- Solicitar o retorno de consulta gerada pelo Motor de Crédito
PROCEDURE pc_solicita_retorno_esteira(pr_cdcooper IN crapcop.cdcooper%TYPE,  --> Código da cooperativa
                                      pr_nrprotoc IN VARCHAR2,  --> Numero do protocolo gerado
                                      pr_retxml   IN OUT NOCOPY XMLType,     --> XML de retorno da operadora
                                      pr_cdcritic OUT crapcri.cdcritic%TYPE, --> Critica encontrada
                                      pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

    -- Variaveis de comunicacao
    l_http_request   UTL_HTTP.req;  --> Request do XML
    l_http_response  UTL_HTTP.resp; --> Resposta do XML
    l_text           VARCHAR2(32000); --> Texto de resposta do Biro
    v_ds_url         VARCHAR2(500); --> URL da Ibratan
    vr_nmdecamp      VARCHAR2(100); --> Campo de retorno do cabecalho
    vr_result        VARCHAR2(100); --> Resultado do campo do cabecalho
    vr_ds_xml        CLOB;
    
    -- Variaveis gerais
    vr_dscomand VARCHAR2(4000); --> Comando para baixa do arquivo
    vr_qttmpret NUMBER;          --> Tempo maximo possivel para retorno da operadora
    vr_dtinicio DATE;            --> Data/hora do inicio do processo
    vr_nmdirarq VARCHAR2(200);   --> Diretorio de gravacao dos arquivos XML
    vr_cdstatus PLS_INTEGER;     --> Status de retorno da consulta no Biro

    -- Variaveis de erro
    vr_cdcritic   PLS_INTEGER;    --> codigo retorno de erro
    vr_des_reto   VARCHAR2(3);    --> tipo saida
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION;      --> Excecao prevista
  BEGIN
    
    -- Busca o diretorio onde sera gravado o XML
    vr_nmdirarq := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => 'salvar');  
                                                                                     
    -- Comando para download
    vr_dscomand := GENE0001.fn_param_sistema('CRED',3,'SCRIPT_DOWNLOAD_PDF_ANL');
    
    -- Substituir o caminho do arquivo a ser baixado
    vr_dscomand := replace(vr_dscomand
                          ,'[local-name]'
                          ,vr_nmdirarq || '/' || to_char(pr_nrprotoc)||'.xml');

    -- Substiruir a URL para Download
    vr_dscomand := REPLACE(vr_dscomand
                          ,'[remote-name]'
                          ,GENE0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'HOST_WEBSRV_MOTOR_IBRA')
                          ||GENE0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'URI_WEBSRV_MOTOR_IBRA')
                          || '_result/' || pr_nrprotoc || '/xml/complete_file');

    -- Executar comando para Download
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomand);

    -- Se NAO encontrou o arquivo
    IF NOT GENE0001.fn_exis_arquivo(vr_nmdirarq || '/' || to_char(pr_nrprotoc)||'.xml') THEN
      vr_dscritic := 'Problema na recepcao do Arquivo - Tente novamente mais tarde!';
      RAISE vr_exc_saida;
    END IF;
    
    -- Converter o arquivo para XML
    gene0002.pc_arquivo_para_XML(pr_nmarquiv => vr_nmdirarq || '/' || to_char(pr_nrprotoc)||'.xml'
                                ,pr_tipmodo  => 2
                                ,pr_xmltype  => pr_retxml
                                ,pr_des_reto => vr_des_reto
                                ,pr_dscritic => vr_dscritic);
    -- Se houve erro
    IF vr_des_reto <> 'OK' THEN 
      -- Renomear o arquivo 
      gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_nmdirarq || '/' || to_char(pr_nrprotoc)||'.xml '||vr_nmdirarq || '/erro_xml_' || to_char(pr_nrprotoc)||'.xml'
                                 ,pr_flg_aguard  => 'S'
                                 ,pr_typ_saida   => vr_des_reto
                                 ,pr_des_saida   => vr_dscritic);
      
    END IF;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;


  -- Solicitar e processar o retorno das consultas geradas pelo Motor de Crédito
  PROCEDURE pc_retorna_conaut_esteira(pr_cdcooper IN NUMBER        -- Código da Cooperativa da Proposta
                                     ,pr_nrdconta IN NUMBER        -- Número da Conta da Proposta
                                     ,pr_nrctremp IN NUMBER        -- Número da Proposta
                                     ,pr_dsprotoc IN VARCHAR2      -- Descrição do Protocolo da Análise automática na Ibratan
                                     ,pr_cdcritic OUT NUMBER       -- Retornará um possível código de critica
                                     ,pr_dscritic OUT VARCHAR2) IS -- Retornará uma possível descrição da crítica
  BEGIN
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: pc_retorna_conaut_esteira
  --  Autor   : Lucas Reinert
  --  Data    : Abril/2017                     Ultima Atualizacao: --/--/----
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Rotina responsável por buscar as informações das consultas efetuadas nos Birôs a partir da 
	--              Esteira
  --
  --  Alteracoes: 01/08/2018 - Ajustado para propostas de CDC (Rafael Faria - Supero)
  ---------------------------------------------------------------------------------------------------------------			
		DECLARE
		  -- Tratamento de críticas
			vr_exc_erro EXCEPTION;
		  vr_cdcritic crapcri.cdcritic%TYPE;
			vr_dscritic crapcri.dscritic%TYPE;
	    vr_dscritic_padrao VARCHAR2(400); --> descricao do erro padrao para nao exibir erros tecnicos para o usuario
      vr_nrprotoc crapcbd.nrprotoc%TYPE; --> Numero do protocolo do envio da requisicao

		  -- Variáveis auxiliares
			vr_nrconbir crapcbd.nrconbir%TYPE; --> Numero da consulta no biro
	    vr_xmlret   XMLtype;               --> XML de retorno
			vr_dtconmax_scr DATE;
	    vr_inconscr PLS_INTEGER := 0;      --> Indicador de consulta de SCR do titular
		
		  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
			
			-- Cursor sobre os dados de emprestimo
			CURSOR cr_crawepr IS
				SELECT decode(empr0001.fn_tipo_finalidade(pr_cdcooper => crawepr.cdcooper
                                                         ,pr_cdfinemp => crawepr.cdfinemp), 3, crawepr.cdoperad, crawepr.cdopeste) as cdopeste
							,crawepr.nrconbir
					FROM crawepr
				 WHERE crawepr.cdcooper = pr_cdcooper
					 AND crawepr.nrdconta = pr_nrdconta
					 AND crawepr.nrctremp = pr_nrctremp
					 AND crawepr.dsprotoc IS NOT NULL;
			rw_crawper cr_crawepr%ROWTYPE;
			
			-- Busca os dados do operador
			CURSOR cr_crapope(pr_cdoperad IN varchar2) IS
				SELECT crapope.cdpactra
					FROM crapope
				 WHERE crapope.cdcooper = pr_cdcooper
					 AND upper(crapope.cdoperad) = upper(pr_cdoperad);
			rw_crapope cr_crapope%ROWTYPE;					
			
	    -- Cursor para buscar a maior data de consulta no SCR
			CURSOR cr_crapopf_max IS
				SELECT MAX(crapopf.dtrefere)
					FROM crapopf; 
			
		BEGIN
      -- Requisição poderá vir do AyllosWeb, garantir o formato decimal para evitar InvalidNumbers
      gene0001.pc_informa_acesso(pr_module => 'sspc0001', pr_action => 'pc_retorna_conaut_esteira');  
    
			-- Busca a proxima numeracao para consulta do biro
			vr_nrconbir := fn_sequence(pr_nmtabela => 'CRAPCBC'
																,pr_nmdcampo => 'NRCONBIR'
																,pr_dsdchave => '0');
																
			-- Busca a data
			OPEN btch0001.cr_crapdat(pr_cdcooper);
			FETCH btch0001.cr_crapdat INTO rw_crapdat;
			CLOSE btch0001.cr_crapdat;

      -- Buscar as informações da Proposta
      OPEN cr_crawepr;
      FETCH cr_crawepr 
       INTO rw_crawper;

      -- Se nao encontrar o emprestimo, retorna com erro
      IF cr_crawepr%NOTFOUND THEN
				-- Atribuir crítica
				vr_cdcritic := 0;
        vr_dscritic := 'Emprestimo inexistente. Favor verificar! Coop: '||pr_cdcooper
                    || ' Cta: '||gene0002.fn_mask_conta(pr_nrdconta)||' Ctr: '||gene0002.fn_mask_contrato(pr_nrctremp);
				-- Fechar cursor de emprestimo
        CLOSE cr_crawepr;
				-- Levantar exceção
        RAISE vr_exc_erro;
      END IF;
      -- Fecha o cursor de emprestimo
      CLOSE cr_crawepr;
      
      -- Busca a maior data de consulta no SCR
      OPEN cr_crapopf_max;
      FETCH cr_crapopf_max INTO vr_dtconmax_scr;
      CLOSE cr_crapopf_max;
      
			-- Busca os dados do operador
			OPEN cr_crapope(rw_crawper.cdopeste);
			FETCH cr_crapope INTO rw_crapope;
			-- Se nao encontrar o operador, retorna com erro
			IF cr_crapope%NOTFOUND THEN
				-- Atribuir crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Operador '||rw_crawper.cdopeste|| ' inexistente. Favor verificar!';
				-- Fechar cursor de operador
				CLOSE cr_crapope;
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
			-- Fecha o cursor de operador
			CLOSE cr_crapope;
			
			-- Insere a capa da consulta de biro
			BEGIN
				INSERT INTO crapcbc
					(nrconbir,
					 cdcooper,
					 dtconbir,
					 qtreapro,
					 qterrcon,
					 qtconsul,
					 inprodut,
					 dshiscon,
					 cdoperad,
					 cdpactra)
				 VALUES
					(vr_nrconbir,
					 pr_cdcooper,
					 SYSDATE,
					 0,
					 0,
					 0,
					 1,
					 lpad(pr_nrdconta,10,'0')||'-'||lpad(pr_nrctremp,10,'0')||'-'||1,
					 rw_crawper.cdopeste,
					 rw_crapope.cdpactra);
			EXCEPTION
				WHEN OTHERS THEN
					-- Atribuir crítica
					vr_cdcritic := 0;
					vr_dscritic := 'Erro ao inserir CRAPCBC: '||SQLERRM;
					-- Levantar exceção
					RAISE vr_exc_erro;
			END;
			
      -- Atualiza o codigo da consulta na tabela de emprestimo
			BEGIN
				UPDATE crawepr
					 SET nrconbir = vr_nrconbir
				 WHERE cdcooper = pr_cdcooper
					 AND nrdconta = pr_nrdconta
					 AND nrctremp = pr_nrctremp;
			EXCEPTION
				WHEN OTHERS THEN
					-- Atribuir crítica
					vr_cdcritic := 0;					
					vr_dscritic := 'Erro ao atualizar a tabela CRAWEPR: '||SQLERRM;
					-- Levantar exceção
					RAISE vr_exc_erro;
			END;			
			
      -- Solicita o retorno do biro de consultas
      pc_solicita_retorno_esteira(pr_cdcooper => pr_cdcooper,
                                  pr_nrprotoc => pr_dsprotoc,
                                  pr_retxml   => vr_xmlret,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);

      -- Se ocorreu erro na requisicao
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN

        -- Incluir o erro em LOG e prosseguir, pois não podemos cancelar o processo 
        -- de aprovação da Proposta devido a erro no Retorno das Consultas Automatizadas
				btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Cecred
																	,pr_ind_tipo_log => 2 -- Erro tratato
																	,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')
																									 ||' - '
																									 || 'Nrconbir: ' || ' --> ' || vr_nrconbir
																									 || ' Protoc: '|| ' --> ' || pr_dsprotoc
																									 || ' Erro: '    || ' --> Erro no retorno'
																									 || ' das consultas automatizadas efetuadas'
																									 || ' pela Esteira de Credito: '||vr_dscritic
																	,pr_nmarqlog     => 'CONAUT');
      END IF;			
			
      -- Processa o retorno do biro e grava as tabelas do sistema
      pc_processa_retorno_req(pr_cdcooper => pr_cdcooper,
                              pr_nrconbir => vr_nrconbir,
                              pr_nrprotoc => pr_dsprotoc,
                              pr_nrdconta => pr_nrdconta,
                              pr_nrdocmto => pr_nrctremp,
                              pr_inprodut => 1,
                              pr_tpconaut => 'M',             -- Motor de Credito
                              pr_inconscr => vr_inconscr,     -- Houve consulta SCR?
                              pr_retxml   => vr_xmlret,
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic);

      -- Se ocorreu erro no processo de retorno das Consultas Automatizadas
      IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN

        -- Incluir o erro em LOG e prosseguir, pois não podemos cancelar o processo 
        -- de aprovação da Proposta devido a erro no Retorno das Consultas Automatizadas
				btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Cecred
																	,pr_ind_tipo_log => 2 -- Erro tratato
																	,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')
																									 ||' - '
																									 || 'Nrconbir: ' || ' --> ' || vr_nrconbir
																									 || ' Protoc: '|| ' --> ' || pr_dsprotoc
																									 || ' Erro: '    || ' --> Erro no retorno'
																									 || ' das consultas automatizadas efetuadas'
																									 || ' pela Esteira de Credito: '||vr_dscritic
																	,pr_nmarqlog     => 'CONAUT');
      END IF;			
			
			-- Atualizamos a tabela da Proposta para gravarmos as datas em que houve a consulta
      BEGIN
        UPDATE crapprp
           SET dtdrisco = decode(vr_inconscr,1,nvl(vr_dtconmax_scr, dtdrisco),dtdrisco),
               dtcnsspc = (SELECT MAX(trunc(nvl(crapcbd.dtreapro, crapcbd.dtconbir)))
                             FROM crapmbr,
                                  crapcbd
                            WHERE crapcbd.nrconbir = vr_nrconbir
                              AND crapmbr.cdbircon = crapcbd.cdbircon
                              AND crapmbr.cdmodbir = crapcbd.cdmodbir
                              AND crapmbr.nrordimp <> 0 -- Descosiderar Bacen
                              AND crapcbd.intippes = 1  -- Somente Titular 
                           )
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctrato = pr_nrctremp
           AND tpctrato = 90; -- Contrato de emprestimo
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar a tabela CRAPPRP: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
						
		  -- Atualizar o risco da proposta
			RATI0002.pc_atualiza_risco_proposta(pr_cdcooper => pr_cdcooper           --> Cooperativa
			                                   ,pr_cdagenci => rw_crapope.cdpactra   --> PA do operador
																				 ,pr_nrdcaixa => 1                     --> Caixa
																				 ,pr_cdoperad => rw_crawper.cdopeste   --> Operador da esteira
																				 ,pr_nmdatela => 'SSPC0001'            --> Nome da tela
																				 ,pr_idorigem => 5                     --> Origem (5 - Ayllos)
																				 ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --> Data de movimento
																				 ,pr_nrdconta => pr_nrdconta           --> Nr. da conta
																				 ,pr_nrctremp => pr_nrctremp           --> Nr. do contrato de emprestimo
																				 ,pr_dscritic => vr_dscritic           --> Descrição da crítica
																				 ,pr_cdcritic => vr_cdcritic);         --> Código da crítica
			
			-- Se ocorreu erro na atualizacao
			IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				-- Envia erro genério para a rotina
				vr_dscritic := 'Houve erro no retorno das Consultas Automatizadas da Esteira de ' ||
											 'Credito: '||vr_dscritic;
				-- Forca saida da rotina
				RAISE vr_exc_erro;
			END IF;  			
			
      -- Efetua a analise de credito de um contrato
			RATI0002.pc_efetua_analise_ctr(pr_cdcooper => pr_cdcooper   --> Codigo da cooperativa
																		,pr_nrdconta => pr_nrdconta   --> Numero da conta
																		,pr_nrctremp => pr_nrctremp   --> Numero do contrato
																		,pr_cdcritic => vr_cdcritic   --> Código da crítica
																		,pr_dscritic => vr_dscritic); --> Descrição da crítica
			-- Se ocorreu erro na atualizacao
			IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				-- Envia erro genério para a rotina
				vr_dscritic := 'Houve erro no retorno das Consultas Automatizadas da Esteira de ' ||
											 'Credito: '||vr_dscritic;
				-- Forca saida da rotina
				RAISE vr_exc_erro;
			END IF;  			


      -- Atualiza as tabelas finais de controle
      pc_atualiza_tab_controle(pr_nrconbir => vr_nrconbir,
                               pr_cdcritic => vr_cdcritic,
                               pr_dscritic => vr_dscritic);
      -- Se ocorreu erro na atualizacao
      IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN

        -- Joga um texto padrao de retorno para a rotina
        vr_dscritic_padrao := 'Houve erro no acesso ao biro (SPC/Serasa/SCR), consulta nao realizada!';

        -- Forca saida da rotina
        RAISE vr_exc_erro;
      END IF;
     
		EXCEPTION
			WHEN vr_exc_erro THEN
				-- Se possuir código da crítica e descrição for nula
				IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
					-- Devemos buscar a descrição da crítica
					vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				END IF;
				
	      -- Trata erro na requisicao
				pc_trata_erro_retorno(pr_cdcooper => pr_cdcooper,
															pr_nrdconta => pr_nrdconta,
															pr_nrdocmto => pr_nrctremp,
															pr_nrprotoc => pr_dsprotoc,
															pr_nrconbir => vr_nrconbir,
															pr_dscritic => vr_dscritic);

				-- Repassa as críticas para os parâmetros
				pr_cdcritic := NVL(vr_cdcritic,0);
				pr_dscritic := vr_dscritic;
				-- Efetuar Rollback
				ROLLBACK;
			WHEN OTHERS THEN
				vr_cdcritic := 0;
				vr_dscritic := 'Erro inesperado na rotina SSPC0001.pc_retorna_conaut_esteira : ' ||SQLERRM;				
			
	      -- Trata erro na requisicao
				pc_trata_erro_retorno(pr_cdcooper => pr_cdcooper,
															pr_nrdconta => pr_nrdconta,
															pr_nrdocmto => pr_nrctremp,
															pr_nrprotoc => pr_dsprotoc,
															pr_nrconbir => vr_nrconbir,
															pr_dscritic => vr_dscritic);
							
				-- Repassa as críticas para os parâmetros
				pr_cdcritic := NVL(vr_cdcritic,0);
				pr_dscritic := vr_dscritic;
				
				-- Efetuar Rollback
				ROLLBACK;				
		END;
	END pc_retorna_conaut_esteira;

PROCEDURE pc_retorna_conaut_est_limdesct(pr_cdcooper IN NUMBER    -- Código da Cooperativa da Proposta
                                        ,pr_nrdconta IN NUMBER    -- Número da Conta da Proposta
                                        ,pr_nrctrlim IN NUMBER    -- Número da Proposta
                                        ,pr_tpctrlim IN NUMBER    -- Tipo da Proposta
                                        ,pr_dsprotoc IN VARCHAR2  -- Descrição do Protocolo da Análise automática na Ibratan
                                        ,pr_cdcritic OUT NUMBER   -- Retornará um possível código de critica
                                        ,pr_dscritic OUT VARCHAR2 -- Retornará uma possível descrição da crítica
                                        ) is
BEGIN
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: pc_retorna_conaut_esteira
  --  Autor   : Paulo Penteado (GFT) 
  --  Data    : Fevereiro/2018                     Ultima Atualizacao: 27/02/2018
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Rotina responsável por buscar as informações das consultas efetuadas nos Birôs a partir da 
   --              Esteira
  --
  --  Alteracoes: 27/02/2018 - Criação (Paulo Penteado (GFT))
  ---------------------------------------------------------------------------------------------------------------      
DECLARE
     -- Tratamento de críticas
      vr_exc_erro exception;
     vr_cdcritic crapcri.cdcritic%type;
      vr_dscritic crapcri.dscritic%type;
    vr_dscritic_padrao varchar2(400); --> descricao do erro padrao para nao exibir erros tecnicos para o usuario
   vr_nrprotoc crapcbd.nrprotoc%type; --> Numero do protocolo do envio da requisicao

     -- Variáveis auxiliares
      vr_nrconbir crapcbd.nrconbir%type; --> Numero da consulta no biro
    vr_xmlret   xmltype;               --> XML de retorno
      vr_dtconmax_scr date;
    vr_inconscr pls_integer := 0;      --> Indicador de consulta de SCR do titular
    
     rw_crapdat btch0001.cr_crapdat%rowtype;
   -- Tratamento de erros
   vr_exc_saida     exception;
      
      -- Cursor sobre os dados de emprestimo
      cursor cr_crawlim is
      select lim.cdopeste
                ,lim.nrconbir
      from   crawlim lim
      where  lim.cdcooper = pr_cdcooper
      and    lim.nrdconta = pr_nrdconta
      and    lim.nrctrlim = pr_nrctrlim
      and    lim.tpctrlim = pr_tpctrlim
      and    lim.dsprotoc is not null;
      rw_crawlim cr_crawlim%rowtype;
      
      -- Busca os dados do operador
      cursor cr_crapope(pr_cdoperad in varchar2) is
      select crapope.cdpactra
      from   crapope
      where  crapope.cdcooper        = pr_cdcooper
      and    upper(crapope.cdoperad) = upper(pr_cdoperad);
      rw_crapope cr_crapope%rowtype;          
      
    -- Cursor para buscar a maior data de consulta no SCR
      cursor cr_crapopf_max is
      select max(crapopf.dtrefere)
      from   crapopf; 
      
BEGIN
   -- Requisição poderá vir do AyllosWeb, garantir o formato decimal para evitar InvalidNumbers
   gene0001.pc_informa_acesso(pr_module => 'sspc0001'
                             ,pr_action => 'pc_retorna_conaut_esteira');  

      -- Busca a proxima numeracao para consulta do biro
      vr_nrconbir := fn_sequence(pr_nmtabela => 'CRAPCBC'
                                             ,pr_nmdcampo => 'NRCONBIR'
                                             ,pr_dsdchave => '0');
                                
      -- Busca a data
      open  btch0001.cr_crapdat(pr_cdcooper);
      fetch btch0001.cr_crapdat into rw_crapdat;
      close btch0001.cr_crapdat;

   -- Buscar as informações da Proposta
   open  cr_crawlim;
   fetch cr_crawlim into rw_crawlim;
   if    cr_crawlim%notfound then
             vr_cdcritic := 0;
         vr_dscritic := 'Emprestimo inexistente. Favor verificar! Coop: '||pr_cdcooper
                        || ' Cta: '||gene0002.fn_mask_conta(pr_nrdconta)||' Ctr: '||gene0002.fn_mask_contrato(pr_nrctrlim);
         close cr_crawlim;
          raise vr_exc_erro;
   end   if;
   close cr_crawlim;
      
   -- Busca a maior data de consulta no SCR
   open  cr_crapopf_max;
   fetch cr_crapopf_max into vr_dtconmax_scr;
   close cr_crapopf_max;
      
      -- Busca os dados do operador
      open  cr_crapope(rw_crawlim.cdopeste);
      fetch cr_crapope into rw_crapope;
      if    cr_crapope%notfound then
             vr_cdcritic := 0;
             vr_dscritic := 'Operador '||rw_crawlim.cdopeste|| ' inexistente. Favor verificar!';
             close cr_crapope;
             raise vr_exc_erro;
      end   if;
      close cr_crapope;
      
   -- Insere a capa da consulta de biro
      begin
          insert into crapcbc
                  (nrconbir
             ,cdcooper
             ,dtconbir
             ,qtreapro
             ,qterrcon
             ,qtconsul
             ,inprodut
             ,dshiscon
             ,cdoperad
             ,cdpactra)
          values (vr_nrconbir
             ,pr_cdcooper
             ,sysdate
             ,0
             ,0
             ,0
             ,1
             ,lpad(pr_nrdconta,10,'0')||'-'||lpad(pr_nrctrlim,10,'0')||'-'||1
             ,rw_crawlim.cdopeste
             ,rw_crapope.cdpactra);
      exception
          when others then
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao inserir CRAPCBC: '||sqlerrm;
                raise vr_exc_erro;
      end;
      
   -- Atualiza o codigo da consulta na tabela de emprestimo
      begin
      update crawlim lim
      set    nrconbir = vr_nrconbir
      where  lim.cdcooper = pr_cdcooper
           and    lim.nrdconta = pr_nrdconta
           and    lim.nrctrlim = pr_nrctrlim
      and    lim.tpctrlim = pr_tpctrlim;
      exception
          when others then
                vr_cdcritic := 0;          
                vr_dscritic := 'Erro ao atualizar a tabela CRAWEPR: '||sqlerrm;
                raise vr_exc_erro;
      end;      
      
   -- Solicita o retorno do biro de consultas
   pc_solicita_retorno_esteira(pr_cdcooper => pr_cdcooper
                              ,pr_nrprotoc => pr_dsprotoc
                              ,pr_retxml   => vr_xmlret
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

   if  nvl(vr_cdcritic,0) <> 0 or trim(vr_dscritic) is not null then
       -- Incluir o erro em LOG e prosseguir, pois nao podemos cancelar o processo 
       -- de aprovação da Proposta devido a erro no Retorno das Consultas Automatizadas
           btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Cecred
                                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                                  ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - '
                                                                              || 'Nrconbir: ' || ' --> ' || vr_nrconbir
                                                                              || ' Protoc: '|| ' --> ' || pr_dsprotoc
                                                                              || ' Erro: '    || ' --> Erro no retorno'
                                                                              || ' das consultas automatizadas efetuadas'
                                                                              || ' pela Esteira de Credito: '||vr_dscritic
                                                  ,pr_nmarqlog     => 'CONAUT');
   end if;      
      
   -- Processa o retorno do biro e grava as tabelas do sistema
   pc_processa_retorno_req(pr_cdcooper => pr_cdcooper
                          ,pr_nrconbir => vr_nrconbir
                          ,pr_nrprotoc => pr_dsprotoc
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdocmto => pr_nrctrlim
                          ,pr_inprodut => 5
                          ,pr_tpconaut => 'M'             -- Motor de Credito
                          ,pr_inconscr => vr_inconscr     -- Houve consulta SCR?
                          ,pr_retxml   => vr_xmlret
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);

   --  Se ocorreu erro no processo de retorno das Consultas Automatizadas
   if  nvl(vr_cdcritic,0) <> 0 or vr_dscritic is not null then
       -- Incluir o erro em LOG e prosseguir, pois nao podemos cancelar o processo 
       -- de aprovação da Proposta devido a erro no Retorno das Consultas Automatizadas
           btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Cecred
                                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                                  ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - '
                                                                              || 'Nrconbir: ' || ' --> ' || vr_nrconbir
                                                                              || ' Protoc: '|| ' --> ' || pr_dsprotoc
                                                                              || ' Erro: '    || ' --> Erro no retorno'
                                                                              || ' das consultas automatizadas efetuadas'
                                                                              || ' pela Esteira de Credito: '||vr_dscritic
                                                  ,pr_nmarqlog     => 'CONAUT');
   end if;      
      
      -- Atualizamos a tabela da Proposta para gravarmos as datas em que houve a consulta
   begin
      update crapprp
      set    dtdrisco = decode(vr_inconscr,1,nvl(vr_dtconmax_scr, dtdrisco),dtdrisco)
            ,dtcnsspc = (select MAX(trunc(nvl(crapcbd.dtreapro, crapcbd.dtconbir)))
                         from   crapmbr
                               ,crapcbd
                         where  crapcbd.nrconbir = vr_nrconbir
                         and    crapmbr.cdbircon = crapcbd.cdbircon
                         and    crapmbr.cdmodbir = crapcbd.cdmodbir
                         and    crapmbr.nrordimp <> 0 -- Descosiderar Bacen
                         and    crapcbd.intippes = 1  -- Somente Titular 
                        )
      where  cdcooper = pr_cdcooper
      and    nrdconta = pr_nrdconta
      and    nrctrato = pr_nrctrlim
      and    tpctrato = 3; -- Limite Desconto Titulo
   exception
      when others then
           vr_dscritic := 'Erro ao atualizar a tabela CRAPPRP: '||sqlerrm;
           raise vr_exc_erro;
   end;      

   -- Atualiza as tabelas finais de controle
   pc_atualiza_tab_controle(pr_nrconbir => vr_nrconbir
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
   
   if  nvl(vr_cdcritic,0) <> 0 or vr_dscritic is not null then
       vr_dscritic_padrao := 'Houve erro no acesso ao biro (SPC/Serasa/SCR), consulta nao realizada!';
       raise vr_exc_erro;
   end if;
     
EXCEPTION
      when vr_exc_erro then
            if  vr_cdcritic > 0 and trim(vr_dscritic) is null then
                 vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            end if;
        
         -- Trata erro na requisicao
            pc_trata_erro_retorno(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrdocmto => pr_nrctrlim
                             ,pr_nrprotoc => pr_dsprotoc
                             ,pr_nrconbir => vr_nrconbir
                             ,pr_dscritic => vr_dscritic);

            -- Repassa as críticas para os parâmetros
            pr_cdcritic := nvl(vr_cdcritic,0);
            pr_dscritic := vr_dscritic;

            ROLLBACK;

      when others then
            vr_cdcritic := 0;
            vr_dscritic := 'Erro inesperado na rotina SSPC0001.pc_retorna_conaut_esteira : ' ||sqlerrm;        
      
         -- Trata erro na requisicao
            pc_trata_erro_retorno(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrdocmto => pr_nrctrlim
                             ,pr_nrprotoc => pr_dsprotoc
                             ,pr_nrconbir => vr_nrconbir
                             ,pr_dscritic => vr_dscritic);

            -- Repassa as críticas para os parâmetros
            pr_cdcritic := nvl(vr_cdcritic,0);
            pr_dscritic := vr_dscritic;
        
            ROLLBACK;
END;
END pc_retorna_conaut_est_limdesct;


  PROCEDURE pc_lista_erros_biro_proposta(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                        ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta
                                        ,pr_nrctrato  IN crapepr.nrctremp%TYPE --> Numero do contrato
                                        ,pr_inprodut  IN crappcb.inprodut%TYPE --> Indicador de tipo de produto
                                        --------> OUT <--------
                                        ,pr_clob_xml OUT CLOB                  --> XML com informacoes do retorno
                                        ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                        ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica

    /* .............................................................................

        Programa: pc_lista_erros_biro_proposta
        Sistema : CECRED
        Sigla   : SSPC
        Autor   : Jaison Fernando
        Data    : Dezembro/2017.                    Ultima atualizacao: 

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado.

        Objetivo  : Rotina responsavel em buscar os erros do biro e retornar ao Progress.

        Observacao: -----

        Alteracoes: 

    ..............................................................................*/

    -------------- CURSORES --------------
    -- Cursor de emprestimo
    CURSOR cr_crawepr IS
      SELECT DISTINCT crapbir.dsbircon
        FROM crawepr
        JOIN crapcbd
          ON crapcbd.nrconbir = crawepr.nrconbir
   LEFT JOIN crapbir
          ON crapbir.cdbircon = crapcbd.cdbircon
       WHERE crawepr.cdcooper = pr_cdcooper
         AND crawepr.nrdconta = pr_nrdconta
         AND crawepr.nrctremp = pr_nrctrato
         AND crapcbd.inreterr = 1; -- Erro

    -- Cursor de limite
    CURSOR cr_craplim IS
      SELECT DISTINCT crapbir.dsbircon
        FROM craplim
        JOIN crapcbd
          ON crapcbd.nrconbir = craplim.nrconbir
   LEFT JOIN crapbir
          ON crapbir.cdbircon = crapcbd.cdbircon
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.nrctrlim = pr_nrctrato
         AND craplim.tpctrlim = 1  -- Limite de credito
         AND crapcbd.inreterr = 1; -- Erro

    -------------- VARIAVEIS --------------
    -- Variaveis locais
    vr_xml_temp VARCHAR2(32767);
    vr_dsdoerro VARCHAR2(70) := 'Houve erro no acesso ao biro externo, consulta nao realizada.';

    --------------- SUBROTINAS INTERNAS --------------
    -- Subrotina para escrever texto na variavel CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      GENE0002.pc_escreve_xml(pr_clob_xml, vr_xml_temp, pr_des_dados, pr_fecha_xml);
    END;

  BEGIN

    -- Criar documento XML
    dbms_lob.createtemporary(pr_clob_xml, TRUE);
    dbms_lob.open(pr_clob_xml, dbms_lob.lob_readwrite);

    -- Insere o cabeçalho do XML
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><erros>');

    -- Se for emprestimo
    IF pr_inprodut = 1 THEN

      FOR rw_dados IN cr_crawepr LOOP
        pc_escreve_xml('<erro>' || rw_dados.dsbircon || ' - ' || vr_dsdoerro || '</erro>');
      END LOOP;

    -- Se for limite de credito
    ELSIF pr_inprodut = 3 THEN

      FOR rw_dados IN cr_craplim LOOP
        pc_escreve_xml('<erro>' || rw_dados.dsbircon || ' - ' || vr_dsdoerro || '</erro>');
      END LOOP;

    END IF;

    -- Encerrar a tag raiz
    pc_escreve_xml('</erros></root>',TRUE);

  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao buscar lista de erros do biro na proposta: ' || SQLERRM;

  END pc_lista_erros_biro_proposta;
  
  PROCEDURE pc_job_conaut_contigencia IS
    CURSOR cr_crapcbr IS
        SELECT crapcop.nmrescop
              ,crapbir.dsbircon
          from crapcbr
          join crapcop
            on crapcop.cdcooper = crapcbr.cdcooper
           and crapcop.flgativo = 1
          join crapbir
            on crapbir.cdbircon = crapcbr.cdbircon
      order by crapcop.cdcooper,
               crapbir.cdbircon;

    vr_cdprogra   VARCHAR2(1000) := 'JBCONAUT_CONTIGENCIA';
    vr_flgerlog   BOOLEAN        := FALSE;
    vr_dsregist   VARCHAR2(4000) := NULL;
    vr_des_erro   VARCHAR2(1000);
    
    -- Variaveis de Erros
    vr_cdcritic   crapcri.cdcritic%TYPE;
    vr_dscritic   crapcri.dscritic%TYPE;
    vr_exc_erro   EXCEPTION;
  BEGIN 
    --> Controlar geração de log de execução dos jobs
    BTCH0001.pc_log_exec_job(pr_cdcooper  => 3
                            ,pr_cdprogra  => vr_cdprogra
                            ,pr_nomdojob  => vr_cdprogra
                            ,pr_dstiplog  => 'I'
                            ,pr_dscritic  => NULL
                            ,pr_flgerlog  => vr_flgerlog);
             
    -- Percorrer todos as modalidades que estao em contigencia
    FOR rw_crapcbr IN cr_crapcbr LOOP
      vr_dsregist := vr_dsregist || '<br />' || rw_crapcbr.nmrescop||': '||rw_crapcbr.dsbircon;
    END LOOP;

    IF vr_dsregist IS NOT NULL THEN
      -- Insere na inconsistencia
      GENE0005.pc_gera_inconsistencia(pr_cdcooper => 3 -- CECRED
                                     ,pr_iddgrupo => 4 -- Consulta Automatizada
                                     ,pr_tpincons => 1 -- Aviso
                                     ,pr_dsregist => vr_dsregist
                                     ,pr_dsincons => 'Contigencia Habilitada'
                                     ,pr_flg_enviar => 'S'
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;                    
    END IF;                                   
  
    --> Controlar geração de log de execução dos jobs
    BTCH0001.pc_log_exec_job(pr_cdcooper  => 3
                            ,pr_cdprogra  => vr_cdprogra
                            ,pr_nomdojob  => vr_cdprogra
                            ,pr_dstiplog  => 'F'
                            ,pr_dscritic  => NULL
                            ,pr_flgerlog  => vr_flgerlog);
                            
    COMMIT;
     
  EXCEPTION
    WHEN vr_exc_erro THEN
      --> Controlar geração de log de execução dos jobs
      BTCH0001.pc_log_exec_job(pr_cdcooper  => 3
                              ,pr_cdprogra  => vr_cdprogra
                              ,pr_nomdojob  => vr_cdprogra
                              ,pr_dstiplog  => 'E'
                              ,pr_dscritic  => vr_dscritic
                              ,pr_flgerlog  => vr_flgerlog);
      ROLLBACK;
    WHEN OTHERS THEN
      --> Controlar geração de log de execução dos jobs
      BTCH0001.pc_log_exec_job(pr_cdcooper  => 3
                              ,pr_cdprogra  => vr_cdprogra
                              ,pr_nomdojob  => vr_cdprogra
                              ,pr_dstiplog  => 'E'
                              ,pr_dscritic  => SQLERRM
                              ,pr_flgerlog  => vr_flgerlog);
                                  
      ROLLBACK;
  END pc_job_conaut_contigencia;
  
END SSPC0001;
/
