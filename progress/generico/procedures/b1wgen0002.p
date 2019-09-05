/******************************************************************************
                           ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +-------------------------------------+-------------------------------------------+
  | Rotina Progress                     | Rotina Oracle PLSQL                       |
  +-------------------------------------+-------------------------------------------+
  | b1wgen0002.p                        | EMPR0001                                  |
  | saldo-devedor-epr                   | EMPR0001.pc_saldo_devedor_epr             |
  | obtem-dados-emprestimos             | EMPR0001.pc_obtem_dados_empresti          |
  | obtem-parametros-tabs               | EMPR0001.pc_config_empresti_empresa       |
  | obtem-dados-conta-contrato          | EMPR0001.pc_obtem_dados_empresti          |
  | obtem-extrato-emprestimo            | EXTR0002.pc_obtem_extrato_emprest         |
  | verifica_microcredito               | EMPR0005.pc_verifica_microcredito         |
  | retornaDataUtil                     | EMPR0008.pc_retorna_data_util             |
  | atualiza_risco_proposta             | RATI0002.pc_atualiza_risco_proposta       |  
  | proc_qualif_operacao                | EMPR9999.pc_proc_qualif_operacao          |
  | valida-dados-alienacao              | TELA_MANBEM.pc_valida_dados_alienacao     |
  | grava-alienacao-hipoteca            | TELA_MANBEM.pc_grava_alienacao_hipot_prog |
  +-------------------------------------+-------------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*..............................................................................

   Programa: b1wgen0002.p
   Autora  : Mirtes.
   Data    : 14/09/2005                        Ultima atualizacao: 15/04/2019

   Dados referentes ao programa:

   Objetivo  : BO - PROPOSTA DE EMPRESTIMO/EXTRATO EMPRESTIMO/SALDO EMPRESTIMO

   Alteracoes: 03/03/2006 - Nao deletar a tabela tt-dados-epr, e mudada
                            para INPUT-OUTPUT (Junior).

               19/05/2006 - Incluido codigo da cooperativa nas leituras de
                            tabelas (Diego).

               07/06/2006 - Desabilitado o trecho de codigo que faz referencia
                            a entidade crapfol (Julio)

               03/08/2007 - Definicoes de temp-tables para include (David)
                          - Incluir campo dtultpag na workepr (Guilherme).

               05/03/2008 - Reformulacao da BO criando novas procedures (David).

               26/03/2008 - Utilizar tres digitos nos campos qtpreemp e qtprecal
                          - Retornar valor total de prestacoes na procedure
                            saldo-devedor-epr (David).

               29/07/2008 - Corrigir condicao no campo flgpagto na procedure
                            obtem-dados-emprestimos (David).

               04/08/2008 - Gravar numero da conta na tt-dados-epr (David).

               10/11/2008 - Dar empty temp-table, return "ok", e
                            limpar variaveis de erro (Guilherme).

               05/12/2008 - Igualar BO e include gera_workepr (David).

               22/01/2009 - Alteracao cdempres (Diego).

               07/05/2009 - Adaptar para rotina PRESTACOES da ATENDA (David).

               18/06/2009 - Substituido os campos dsdebens por dsrelbem e
                            vloutras por vldrendi nas TEMP-TABLES
                            tt-impprop-epr e tt-proposta-epr (Elton).

               11/12/2009 - Listar somente emprestimos ativos - inliquid = 0
                            (David).

               29/06/2010 - Incluir procedure obtem-propostas-emprestimo
                            (Gabriel).

               09/07/2010 - Projeto de melhorias de operacoes de credito.
                            Retirar as procedures nao utilizadas sobre
                            a impressao (Gabriel).

               24/11/2010 - Arrumado valor da prestacao (Gabriel).

               26/11/2010 - Criticar CPF/CNPJ do proprietario invalido
                            soh quando ele for prenchido (Gabriel)

               10/01/2011 - Alterado o format do aux_qtprecal de "zz9.9999"
                            para "-zzz,zz9.9999" no assign onde o
                            tt-dados-epr.dspreapg o recebe (Adriano).

               20/01/2011 - Alterado a procedure altera-valor-proposta. Estava
                            sendo pego a variavel par_vlpreemp ao inves da
                            par_vlemprst para verificar o valor a ser alterado
                            (Adriano).

               27/01/2011 - Identificacao no procedure altera-valor-proposta
                            (Ze).

               04/02/2011 - Incluir parametro par_flgcondc na procedure
                            obtem-dados-emprestimos  (Gabriel - DB1).

               21/02/2011 - Arrumar critica quando cooperado demitido
                            (Gabriel).

               21/03/2011 - Alimentar nrcpfcgc do bem de acordo com a TAB016
                            (Guilherme).

               23/03/2011 - Incluido procedimento gera-impressao-empr
                            (André - DB1).

               13/04/2011 - Alterações devido a CEP integrado. Campos
                            nrendere, complend e nrcxapst na tt-interv-anuente
                            e tt-dados-avais. Alterado grava proposta completa
                            e grava-alienacao-hipoteca.(André - DB1)

               29/04/2011 - Inclusão de campo bairro e endereco na
                            tt-interv-anuente para facilitar leitura web.
                            Feito procedimento valida-interv. (André - DB1)

               28/06/2011 - Ajuste na composicao do campo tt-dados-epr.dspreapg
                            para utilizar mesma logica da include gera_workepr.i
                            (David).

               01/07/2011 - Ajuste na validacao dos avalistas. Realizar
                            UNDO quando der erro na gravacao da Inclusao
                            (Gabriel).

               05/07/2011 - Implementacao para tratar novo calculo de
                            emprestimo (taxa pre-fixada):
                            - Inclusao de campos na tt-proposta-epr
                            (GATI - Diego/Eder).

               21/07/2011 - Inclusao de procedimentos para obtencao e
                            manipulacao de dados da proposta.
                            (GATI - Diego B.)

               05/08/2011 - Alterado condição na leitura da crapepr na
                            procedure obtem-dados-emprestimos
                            ( Gabriel - DB1 ).

               13/09/2011 - Adicionado parametro par_tpemprst na procedure
                            valida dados gerais. (Diego B. - GATI)

               14/09/2011 - Desenvolvimento valida-analise-proposta.
                            (Diego B. - GATI)

               15/09/2011 - Carregados campos cdhistor e nrseqdig na
                            tt-extrato_epr (obtem-extrato-emprestimo) e
                            inliquid na tt-dados-epr (obtem-dados-emprestimos)
                            (Gabriel - DB1).

               16/09/2011 - Desenvolvimento da rotina valida-dados-proposta.
                            Alteracao de nomenclatura do tipo de emprestimo:
                            - De "Calculo Atual" para "Price TR"
                            - De "Pre-Fixada" para "Price Pre-Fixado"
                            (Diego B. - GATI).

               05/10/2011 - Alterada mensagem de erro proveniente da execucao
                            do metodo valida_novo_calculo. (GATI - Oliver)

               06/10/2011 - Incluida atualização da taxa mensal do emprestimo
                            quando for realizada uma alteração total ou apenas
                            de valor. Procedure alterada foi
                            altera-valor-proposta. (GATI - Oliver)

               28/10/2011 - Incluido na procedure obtem-dados-proposta-emprestimo
                            a chamada da procedure valida_percentual_societario.
                            (Fabricio)

               21/11/2011 - Colocado em comentario temporariamente a chamada
                            da procedure valida_percentual_societario.
                            (Fabricio)

               28/11/2011 - Incluido o parametro dsjusren na procedure
                            grava proposta completa (Adriano).

               07/02/2012 - Carregar todos os emprestimos quando a BO for
                            chamada pela tela IMPRES (David).

               22/02/2012 - Mostrar o valor de craplcr.txmensal quando
                            crapepr.tpemprst=1 em obtem-dados-emprestimos.
                            (Tiago)

               24/02/2012 - Corrigido erro que somava dias uteis como dias
                            corridos, adicionado var aux_dtlibera com
                            a soma correta (Tiago).

               07/03/2012 - Retirado a consulta de IOF e da tarifa de
                             emprestimo de dentro da procedure
                             calcula_emprestimo (Tiago).

               20/03/2012 - Desprezar os historicos 1032,1033,1034,1035 na
                            obtem-extrato-emprestimo (Tiago).

               29/03/2012 - Nao permitir valor do emprestimo e data do pagamento
                            em branco (Gabriel).

               03/04/2012 - Nao permite emprestimo com linha de credito 100
                            quando risco do cooperado nao estiver em nivel "H"
                            por mais de 180 dias (Elton)

               08/06/2012 - Softdesk 2749: Nao permitir alterar o numero da
                            proposta se a mesma ja foi efetivada. (Irlan)

               14/06/2012 - Tratamento para remoção do campo EXTENT
                            crapfin.cdlcrhab[] (Lucas).
               10/04/2012 - Incluir tratamento para permitir inclusao de
                            emprestimos nas contas migradas (Gabriel)

               08/10/2012 - Incluir campo dsextrat na procedure
                            obtem-extrato-emprestimo (Lucas R).

               11/10/2012 - Incluido a passagem de um novo parametro na
                            chamada da procedure saldo_utiliza - Projeto GE
                            (Adriano).

               25/10/2012 - Incluir parametro na procedure verifica-outras-propostas,
                            incluir chamada da funcao busca_grupo que verifica
                            se conta pertence a grupo economico;
                            Incluir Paramentro de saida na procedure
                            valida-dados-gerais e na verifica-limites-excedidos,
                            chamada da procedure calc_endivid_grupo e tratamento
                            para cadasto da temp-table tt-ge-epr.(Lucas R.)

                           21/11/2012 - Retirado restrição de numeracao de
                                        contratos de emprestimos
                                        (David Kruger).

               13/12/2012 - Não listar os históricos de juros de atraso normal
                            no extrato de emprestimo (1050, 1051)  (Oscar).
               17/12/2012 - Nao permitir dia de vencimento da parcela maior
                            que 27 quando produto pre-fixado (Gabriel).

               28/12/2012 - Incluso parametro par_cdoperad na chamda da
                            procedure atualiza_tabela_avalistas (Daniel).

               08/01/2013 - Tratamento no qtmesdec para o novo tipo de
                            emprestimo (Gabriel).

               08/01/2013 - Incluida condicao (craptco.tpctatrf <> 3) na
                            consulta da craptco (Tiago)
                          - Correção de críticas genéricas (Lucas).

               30/01/2013 - Incluir condicao para validar historicos que deverao
                            aparecer na listagem (Lucas R.).

               31/01/2013 - Quando for emprestimo do tipo 1 colocar no
                            campo tt-dados-epr.dsidenti, tipo 0 fica em branco
                            (Lucas R.).

               25/02/2013 - Receber o numero do contrato na validacao da
                            liquidacao (Gabriel)

               13/03/2013 - Alterar extrato do emprestimo (Gabriel).

               03/04/2013 - Removido da obtem-propostas-emprestimo tratamento
                            que criava mensagem se for menor que 18 anos.
                          - Incluir validacao na procedure
                            obtem-dados-proposta-emprestimo para nao permitir
                            cooperador fazer emprestimo se for menor que 16
                            anos (Lucas R.).

               04/04/2013 - Incluir * nas propostas do Price Pré fixado
                            (Gabriel)

               19/04/2013 - Alteração performance foi cria novo indice na tabela
                            craplem alterei as rotinas que estava forcando
                            indice para usar o indice que o banco determinar no
                            caso o novo indice craplem5.
                            (Oscar)

               24/04/2013 - Corrigir extrato do emprestimo pre-fixado.
                            Forcar o uso do indice craplem2 no extrato do
                            emprestimo (Gabriel).

               29/04/2013 - Incluido a chamada da procedure alerta_fraude
                            nas procedures:
                             - valida-dados-gerais;
                             - altera-valor-proposta;
                             - altera-numero-proposta;
                             - grava-proposta-completa;
                            (Adriano).

               07/05/2013 - Adicionado retorno de documento de emprestimo
                            digitalizado para consulta de imagens do GED
                            (Lucas).

               22/05/2013 - Ao incluir nova proposta de emprestimo, trazer
                            qtd. de notas promissorias da TAB016 (Lucas).

               20/06/2013 - Campos BNDES  no grava-dados-proposta (BO 0024)
                            altera-numero-proposta - Validacao PRP
                            (Guilherme/SUPERO)

               28/06/2013 - Trazer contratos para liquidar dependendo da linha
                            de credito em questao (Gabriel).

               23/07/2013 - Evitar erros quando pressionado <F4>/<END-ERROR>
                            na inclusão / alteracao da proposta (Gabriel).

               08/08/2013 - Mudar historicos 1077 e 1078 para mostrar em debito
                            no extrato (Gabriel).

               11/09/2013 - Incluir os pacs liberados para emprestimos
                            prefixados. (Irlan)

               22/10/2013 - Ajustes:
                            - Realizado ajuste para retirar o bloqueio de
                              emprestimos Pre-fixado da cooperativa Viacredi e
                              incluido a cooperativa Acredicoop.
                              Procedures alterdadas:
                               > obtem-propostas-emprestimo
                               > obtem-dados-proposta-emprestimo
                            - Ajuste na procedure valida-dados-alienacao para
                               permitir que UF, Renavam possam nao ser
                               informados
                            (Adriano).

               06/11/2013 - Melhorar o desempenho na leitura crapepr (Gabriel)

               12/11/2013 - Nova forma de chamar as agências, de PAC agora
                            a escrita será PA (Guilherme Gielow)

               14/11/2013 - GRAVAMES - Alteracao grava-alienacao-hipoteca para
                            gravar o flginclu e tpinclus quando recriar os bens
                            da proposta (Guilherme/SUPERO)

               06/12/2013 - Considerar 60 dias para propostas sem carência
                            realizadas até dia 19 do mês. (Irlan)

               09/01/2014 - Ajuste na procedure "obtem-dados-conta-contrato"
                            para atualizar o valor qtlemcal da tt-dados-epr
                            (James).

               14/01/2014 - Ajustes para permitir qtd nota promissoria com "0".
                            Realizar gravao de qtpromis baseado na tab016.(JORGE)

               16/01/2014 - Alterada Procedure busca_aval_terceiro para buscar
                            avalistas com CNPJ.
                          - Alterada critica ao nao encontrar PA para
                            "962 - PA nao cadastrado.".(Reinert)

               23/01/2014 - Adicionados parametros na procedure
                            'verifica-outras-propostas' para validação de
                            CPF/CNPJ do proprietário dos bens como
                            interveniente (Lucas).

               28/01/2014 - Novo campo tt-bens-alienacao -> uflicenc
                          - Buscar uflicenc baseado no UF do PA
                          - Campo crapbpr.uflicenc recebia fixo "SC", alterado
                            para receber do parametro
                          - Novo parametro chassi para validacoes na procedure
                            valida-dados-alienacao
                            (Guilherme/SUPERO)

               03/02/2014 - Liberar a inclusão e alteração de propostas
                            Price-prefixado para Acredi. (James)

               24/02/2014 - Adionado param. de paginacao em proc. 
                            obtem-dados-emprestimos. (Jorge)

               05/03/2014 - Ajuste na procedure "obtem-dados-conta-contrato"
                            para carregar o valor da multa e juros de mora
                            na tt-dados-epr. (James)

                            Ajuste na procedure "grava-proposta-completa"
                            para gravar o campo crawepr.qttolatr. (James)

                            Incluso VALIDATE (Daniel). 

               14/03/2014 - Novos parametros valida-dados-alienacao
                          - Incluida validacao da situacao do Bem
                          - Novo tratamento para bens Alien True, na 
                            grava-alienacao-hipoteca (Guilherme/SUPERO).
                 
               24/03/2014 - Ajuste na procedure "grava-proposta-completa" 
                            para buscar a proxima sequencia crapmat.nrctremp
                            apartir banco Oracle (James)             

               25/04/2014 - Alteracoes [GRAVAMES]
                            -> obtem-propostas-emprestimo: incluida
                            verificacao se permite excluir
                            -> obtem-dados-proposta-emprestimo: incluida
                            verificacao se permite excluir (para WEB)
                            -> excluir-proposta: Deletar registros da crapGRV
                            (Guilherme/SUPERO)
                            
               29/04/2014 - Ajuste na procedure "altera-numero-proposta"
                            para fazer UNDO, quando ocorrer erro. (James)
                            
               05/05/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074).
                            
               12/06/2014 - Ajuste na procedure "obtem-extrato-emprestimo"
                            para mostrar o avalista que efetuou o pagamento
                            (James)
                            
               25/06/2014 - Adicionado o parametro par_dsoperac 
                            (com valor 'PROPOSTA EMPRESTIMO') 'a chamada das
                            procedures atualiza_tabela_avalistas e 
                            grava-dados-cadastro.
                            (Chamado 166383) - (Fabricio)
                            
               14/07/2014 - Ajuste na procedure "obtem-extrato-emprestimo"
                            para mostrar o juros de mora na opcao de Debito.
                            (James)
                            
                            
               17/07/2014 - Incluso parametros nas procedures grava-proposta-completa,
                            atualiza_tabela_avalistas,  valida-avalistas. Adicionado 
                            tratamento na valida-avalistas para verificar tipo de 
                            pessoa e data de nascimento do avalista (Daniel). 
                            
              14/07/2014 - Exclusao da criacao da temp table tt-ge-epr
                           sera utilizado a temp table tt-grupo na include b1wgen0138tt. 
                           (Tiago Castro - RKAM)
                           
              28/07/2014 - Adicionado param. par_cdagenci e par_nrdcaixa em 
                           chamada da proc. atualiza_tabela_avalistas.
                           (Jorge/Gielow) - SD 156112
                           
              20/08/2014 - Incluid ajustes referentes ao Projeto CET, nova
                           PROCEDURE calcula-cet (Lucas R./Gielow)
                     
              20/08/2014 - Incluir validacao na procedure "valida-dados-gerais"
                           referente ao projeto do pre-aprovado. (James)
                           
              22/08/2014 - Novo campo de consulta ao conjuge (Jonata-RKAM).   
              
              01/09/2014 - Projeto Automatização de Consultas em Propostas 
                           de Crédito ( Jonata- RKAM ).        
                           
              10/09/2014 - Incluir o campo flgpreap na temp-table tt-dados-epr
                           (James)
             
              07/10/2014 - Ajuste em condicao de tratamento para paginacao em
                           proc. obtem-dados-emprestimos. (Jorge/Gielow)
                           
              15/10/2014 - Inclusão de tratamento na verifica-traz-avalista             
                           para verificar se o cpf do avalista é uma conta migrada.
                           (SD 209860 Odirlei/AMcom)
                           
              22/10/2014 - Adicionado verificacao da data de pagamento deve ser
                           mes diferente do mes da data de liberacao.
                           (Jorge/Rosangela) - SD 156642      
                           
              24/10/2014 - Incluir rotina para calcular o cet na procedure
                           altera-valor-proposta (Lucas R. )
                         - Adicionado verificacao de data de liberacao para 
                           restringir data de pagamento fora do mes de
                           liberacao. (Jorge/Gielow) - SD 156642         
                           
              29/10/2014 - Ajuste na mensagem da procedure
                           valida-liquidacao-emprestimos. (James)
                           
              03/11/2014 - Incluido novos parametros vlttmupr, vlttjmpr, vlpgmupr,
                           vlpgjmpr na procedures obtem-dados-conta-contrato (Daniel).
                           
              06/11/2014 - Alterado parametro passado na chamada das procedures
                           atualiza_tabela_avalistas e grava-dados-cadastro;
                           de: 'PROPOSTA EMPRESTIMO' para: 'PROP.EMPREST'.
                           Motivo: Erro ao tentar gravar registro de log 
                           (craplgm). (Fabricio)
                           
              07/11/2014 - Incluido o campo cdorigem na tt-proposta-epr na 
                           procedure obtem-propostas-emprestimo. (Jaison)
                           
              18/11/2014 - Inclusao do parametro nrcpfope na
                           procedure "valida-dados-gerais". (Jaison)

              20/11/2014 - Retirado alteracao do dia 22/10/2014, por solicitacao
                           da Luana, Irlan e Mirtes (Andrino-RKAM) - SD 156642

              28/11/2014 - GRAVAMES - Adicionado TRIM para comparacao das strings
                           na valida-dados-alienacao quando alterando bens da 
                           proposta (Guilherme/SUPERO)

              15/12/2014 - Adicionado chamada da proc. ver_cadastro da BO1 em 
                           proc. obtem-dados-proposta-emprestimo.
                           (Jorge/Gielow) - SD 230769 - Melhorias
                                                
              28/11/2014 - Alteracao de bloqueio de resgate quando aditivo vinculado
                           a aplicacao estiver bloqueado (Jean Michel).
              
              05/01/2015 - Projeto Microcredito. (Jonata-RKAM)
              
              14/01/2015 - Adicionado validacao de campo chassi em quantidade
                           de caracteres para MOTO, VEICULO e CAMINHAO. 
                           (Jorge/Gielow) - SD 241854
                           
              22/01/2015 - Alterado o formato do campo nrctremp para 8 
                           caracters (Kelvin - 233714)             
                           
              29/01/2015 - Ajuste no calculo do prejuizo para o emprestimo PP.
                           (James/Oscar)
                           
              12/02/2015 - Ajuste para nao permitir informar a linha de 
                           microcredito para o produto TR(254183). (James) 
                           
              18/02/2015 - Analise da proposta (Gabriel-RKAM).                               
            
                      19/03/2015 - Alteracao da delecao de registros da tabela crapadi
                           da procedure excluir-proposta (Jean Michel).
                           
              30/03/2015 - Bloqueio de operacoes no produto TR.(270806)(James).

              08/04/2015 - Inclusao de todos os Estados do Brasil.
                           (Jaison/Gielow - SD: 274267)

              13/04/2015 - Inclusao de consulta ao tabela crapmcr na validação 
                           do numero do contrato criado na grava-proposta-completa
                           (Jean - RKAM - SD: 272596)

              07/05/2015 - Inclusao do contrato no log na procedure 
                           excluir-proposta. (Jaison/Gielow - SD: 283541)

              15/05/2015 - Correcao no momento de pegar a sequence para nao 
                           causar loop. (Jaison/Oscar - SD: 282684)
                           
              18/05/2015 - Incluir procedure "carrega_dados_proposta_finalidade"
                           (James)                                                           
                                                                        
              27/05/2015 - "Alterado para apresentar mensagem ao realizar inclusao 
                           de nova proposta de emprestimo para menores 
                           nao emancipados. (Reinert)" (Reinert)
                          
                          28/05/2015 - Ajuste para evitar erros na gravacao da crapbpr
                           (Gabriel-RKAM).  

              28/05/2015 - Retornar se mudou de faixa na gravacao complera
                           da proposta (Gabriel-RKAM).
                           
              16/06/2015 - Projeto 158 - Servico Folha de Pagto
                           (Andre Santos - SUPERO)                                                                                          
                                                                            
              24/06/2015 - Projeto Alterar forma de calculo de provisao. (James)
              
              25/06/2015 - Projeto 215 - DV 3. Incluso novo campo liquidia. (Daniel)

              07/07/2015 - Criacao da variavel aux_err_efet nas procedures:
                           obtem-propostas-emprestimo, obtem-dados-conta-contrato.
                           (Jaison/Diego - SD: 290027)
              
              16/07/2015 - Incluida validacao para nao retornar contas inativas do interveniente.
                           Ao inserir um cpf que possuia uma conta ativa e uma inativa, estava
                           retornando a inativa. Chamado 304656 (Heitor - RKAM) 
              
              31/07/2015 - Adicionado verificacao se a proposta nao foi efetivada
                           em proc. excluir-proposta. (Jorge/Elton) - SD 303221
                           
              07/08/2015 - Alteracao na mensagem de validacao da data de pagamento.
                           (James)
                          
              10/08/2015 - Incluido procedure "recalcular_emprestimo()". (James)            
              
              13/08/2015 - Tratado historicos 1711 e 1720 na procedure 
                           obtem-extrato-emprestimo. (Reinert)      
                           
              21/08/2015 - Correcao da exclusao de registros de Portabilidade
                           Projeto 134 - Portabilidade de credito
                           (Carlos Rafael Tanholi)                            
                           
              05/10/2015 - Adicionado validacao para que nao seja permitido alterar
                           um emprestimo quando estiver em processo na tela gravames,
                           conforme solicitado no chamado 319024. (Kelvin)
              
              08/10/2015 - Tratar os históricos de estorno do produto PP (Oscar)  
              
              12/11/2015 - Criacao da rotina de calculo de iof para emprestimos
                           Projeto 134 - Portabilidade de credito
                           (Carlos Rafael Tanholi)   
                           
              17/11/2015 - Criacao do parametro (par_cdfinemp) parametro de finalidade 
                           usado para portabilidade. Projeto 134 - Portabilidade de credito
                           (Carlos Rafael Tanholi)
                           
              23/11/2015 - Incluso novo campo tt-extrato_epr.cdorigem  na procedure 
                           obtem-dados-emprestimos (Daniel)
                           
              01/12/2015 - Inclusao de parametro na procedure "pc_valida_inclusao_tr". 
                           (James)
                            
              08/12/2015 - Adiciondo nova validacao para que o cooperado nao possa
                           inserir duas proposta com alienacao de veiculos com o mesmo
                           chassi, conforme solicitado no chamado 352624. (Kelvin)
                           
              08/12/2015 - Retirado select da funcao fn_sequence e substituido
                           pela chamada da procedure pc_sequence_progress
                           por problemas de cursores abertos 
                           (Tiago/Rodrigo SD347440).

              13/01/2016 - Verificacao de carga ativa na altera-valor-proposta
                           Pre-Aprovado fase II. (Jaison/Anderson)
              
              20/01/2016 - Inclusao de mensagem de aviso apos a confirmacao da garantia 
                           no emprestimo. (Chamado: 380129). (James)
                           
              01/03/2016 - Alteracoes ao projeto de esteira de credito (Oscar).

              01/03/2016 - PRJ Esteira de Credito. (Jaison/Oscar/Odirlei)

             11/03/2016 - inclusao do campo cdpactra na rotina grava-proposta-completa 
                          PRJ Esteira de Credito. (Odirlei-Amcom)

             23/03/2016 - Projeto Esteira de Credito. (Daniel/Oscar)
             
             14/04/2016 - Incluir chamada pc_alter_nrctrprp_aciona para atualizar numero da proposta
                          no acionamento PRJ207 Esteira de Credito. (Odirlei-Amcom)

             05/05/2016 - Incluir a regra quando o valor da proposta for alterado para menos e já foi enviada 
                          para esteira e a análise nao foi finalizada deverá obrigar a reenviar a proposta.  (Oscar)         
 
             03/02/2016 - Adicionado tratamento para permitir a exclusao de propostas 
                          de portabilidade que foram canceladas no JDCTC. (Reinert)                          

			       12/04/2016 - Adicionado nova situacao "SI8" para permitir a exclusao de
                          propostas de portabilidade. (Reinert)

             18/04/2016 - Conforme solicitacao, agora sera mantido o operador inicial
                          das propostas de Portabilidade nao sendo alterado com a 
                          aprovacao automatica.(SD 432942 - Carlos Rafael Tanholi)	

			 11/05/2016 - Calculo vlatraso na chamada pc_calcula_atraso_tr.
                          Criacao da leitura_lem. (Jaison/James)
						   							
		     09/06/2016 - Ajuste na rotina obtem-dados-conta-contrato para retirar a leitura da 
                          tabela craplcm, a rotina em Progress nao e chamada pelo emprestimo novo,
                          dessa forma nao sera mais necessario verificar se o credito do emprestimo foi efetuado
                          efetuado para permitir a liquidação no dia.
                          (Adriano - SD 467073).
                          
              21/06/2016 - Alterado a rotina altera-numero-proposta para nao permitir 
                           alterar o numero do contrato caso ele seja uma proposta de 
                           portabilidade conforme solicitado no chamado 466077. (Kelvin)

              06/07/2016 - Ajuste para ao inves de olhar apenas o codigo da finalidade
			               ver na tabela de finalidade se eh realmente uma
						   portabilidade de credito para ai entao bloquear
						   a alteracao do numero da proposta (Tiago/Thiago SD466077)
              
             13/07/2016 - Ajuste na validaçao da Linha de credito na procedure valida-dados-gerais. Agora
                          valida pelo metodo EMPR0002.pc_busca_linha_credito_prog.

              07/09/2016 - Alterada forma de calculo do atraso na rotina proc_qualif_operacao
                           pois estava somando 2x o numero calculado de parcelas, impactando
                           na qualificacao da operacao
                           Andrey (RKAM) - Chamado 473364

              23/09/2016 - Correçao deletar o Handle da b1wgen0114 esta gerando erro na geraçao
                           do PDF para envio da esteira (Oscar).

			  23/09/2016 - Inclusao de validacao de contratos de acordos,
                           Prj. 302 (Jean Michel).

			  25/10/2016 - Verificar CNAE restrito Melhoria 310 (Tiago/Thiago).

			  19/10/2016 - Incluido registro de log sobre liberacao de alienacao de bens 10x maior que 
						   o valor do emprestimo, SD-507761 (Jean Michel).
						  	               
			  26/10/2016 - Chamado 537058 - Correcao referente a linhas de creditos inativas.
						   (Gil - MOUTS)
             
              31/01/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)

			  20/02/2017 - Ajuste para validaçao de Capital de Giro na procedure valida-dados-gerais. 
			               Nao permitir utilizacao de Capital de Giro por pessoa fisica. 
						   (Daniel - Chamado 581906).
               
        22/03/2017 - Incluido tratamento para emprestimos PP quando a carencia da linha de credito for nula.
                     Nesses casos ira seguir as mesmas regras de carencia = 0 dias.
                     Hoje esta considerando fixo 60 dias nesses casos.
                     Heitor (Mouts) - Chamado 629653.
             
               11/04/2017 - Alterado rotina carrega_dados_proposta_finalidade para limpar temptable antes
                            de popular. 
							Ajustado para exluir tbcrd_cessao_credito quando a proposta for excluida.
                            PRJ343 - Cessao de credito (Odirlei-AMcom)

			  12/04/2017 - Realizado ajuste onde não estava sendo possível lançar contratos 
                           de emprestimos com a linha 70, conforme solicitado no chamado 644168. (Kelvin)
				 
		  
			  25/04/2017 - Adicionado chamada para a procedure pc_obrigacao_analise_automatic
						   na procedure carrega_dados_proposta_linha_credito e novo parametro
						   de saida na procedure valida_impressao. Projeto 337 - Motor de crédito. (Reinert)
             
              25/04/2017 - Alterado rotina atualiza_risco_proposta para chamada da rotina oracle.
                           Diversos ajustes para controle apos envio para Esteira.
                           PRJ337 - Motor de Credito (Odirlei-Amcom)

              02/05/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)              

              06/06/2017 - Alteraçao na rotina proc_qualif_operacao, pois nao estava considerando as prestacoes 
                           calculadas nos meses anteriores, apenas do mes atual.
                           (Mateus - Mouts - Chamado 671976)


			  08/06/2017 - Inicializacao do parâmetro par_nrctremp nas rotinas grava-proposta-completa,
                     altera-valor-proposta, atualiza_dados_avalista_proposta
                     Substituicao do 'LEAVE Grava' ou 'LEAVE Grava_valor' por 'RETURN NOK' em algumas situacoes
                     Chamado 660371 - Ana (Envolti)

              22/06/2017 - Ajuste na procedure obtem-dados-proposta-emprestimo para nao validar o tempo
                           minimo para revisao cadastral, nos casos de cessao de cartao de credito. (Anderson)


			  07/07/2017 - Nao permitir utilizar linha 100, quando possuir acordo
                           de estouro de conta ativo. (Jaison/James)

              10/07/2017 - Criacao do FIELD insitest na tt-proposta-epr.
                           (Jaison/Marcos Martini - PRJ337)

              27/07/2017 - Alterado para nao validar associado demitido e nem menor de idade para emprestimos
                           de cessao da fatura do cartao de credito (Anderson).

			  29/07/2017 - Desenvolvimento da melhoria 364 - Grupo Economico Novo. (Mauro)

			  29/09/2017 - P337 - SMII - Ajustes no processo de perca de aprovação quando 
			               Alterar Somente Avalista (Marcos-Supero)

              06/10/2017 - Projeto 410 - Incluir campo Indicador de 
                            financiamento do IOF (Diogo - Mouts)

              31/10/2017 - Passagem do tpctrato. (Jaison/Marcos Martini - PRJ404)	 

			  14/12/2017 - SM Motor de Crédito - Interrupçao de Fluxo (Marcos-Supero)
			  
              15/12/2017 - Inserção do campo idcobope. Inclusão do vinculo com a cobertura. PRJ404 (Lombardi)

              01/12/2017 - P410 - Alteracao Calculo IOF - incluir o Valor IOF complementar por atraso (Jean -Mout´s)
  
                          21/11/2017 - Inclusão do campo flgpreap na procedure altera-valor-proposta,
                                                         Prj. 402 (Jean Michel)
	  
              14/12/2017 - Inclusão dos campo flintcdc, inintegra_cont na tt tt-proposta-epr
                           utilizada nas procedures obtem-propostas-emprestimo e 
                           obtem-dados-proposta-emprestimo, Prj. 402 (Jean Michel).                     
	  
              22/01/2018 - Inclusao de trava para testes em producao do produto Pos-Fixado. 
                           (Jaison/James - PRJ298)
                           
              21/02/2018 - Liberar o produto Pós-Fixado para todas as contas da cooperativa Viacredi. (James)

              23/01/2018 - Alterada Regras para retorno da Qualificação da Operação de acordo com dias de atraso. 
						   (Diego Simas - AMcom) (Projeto Regulatório Crédito).

              23/01/2018 - PRJ450 - Criado a rotina obtem-dados-limite-adp para obter os dados do limite crédito/adp que
                           trará para ser liquidado na tela Atenda - Empréstimos.
                           Alterado as rotina proc_qualif_operacao, valida-liquidacao-emprestimos,
                           obtem-dados-proposta-emprestimo e grava-proposta-completa para considerar limite/adp quando
                           selecionado para liquidar.
                           (Diego Simas - AMcom) (Projeto Regulatório Crédito).

			  25/01/2018 - Alteração nas procedures obtem-dados-proposta-emprestimo e grava-proposta-completa
			               para considerar o novo campo DSNIVORI (Nível de Risco Original da Proposta).
						   (Reginaldo - AMcom) (Projeto Regulatório Crédito).

              16/02/2018 - Ajuste na procedure obtem-dados-proposta-emprestimo para verificar se existe valor 
                           na coluna nrrenavo, caso sim, retorna esse valor, senao retorna o nrrenava.
                           Chamado 845869 - (Mateus Z - Mouts)

              16/03/2018 - Ajuste para ignorar validacao alerta_fraude quando for cessao de credito (crps714).
                           Chamado 858710 (Mateus Z / Mouts).

              21/03/2018 - Alterado para permitir alteracao do nr. de contrato para 
                           tipo de linha 4 - Aplicacao. (PRJ404 - Reinert)
                           
              12/04/2018 - P410 - Melhorias/Ajustes IOF (Marcos-Envolti)
              
              13/04/2018 - Ajuste na procedure valida-dados-gerais para verificar se o tipo de conta
                           do cooperado permite adesao do produto 31 - Emprestimo. PRJ366 (Lombardi)
              
              21/11/2017 - Inclusão do campo flgpreap na procedure altera-valor-proposta, Prj. 402 (Jean Michel)
			 
              14/12/2017 - Inclusão dos campo flintcdc, inintegra_cont na tt tt-proposta-epr
                           utilizada nas procedures obtem-propostas-emprestimo e 
                           obtem-dados-proposta-emprestimo, Prj. 402 (Jean Michel). 

			  28/06/2018 - Ajustes projeto CDC. PRJ439 - CDC (Odirlei-AMcom)

			  24/05/2018 - P450 - Ajuste na data anterior na proc_qualif_operacao (Guilherme/AMcom)

              22/05/2018 - Adicionado campo "par_idquapro" na procedure "valida-dados-gerais".
                           Incluida validacao das linhas de credito 100,800,900 e 6901 e do campo
                           par_idquapro. PRJ366 (Lombardi)
           
		      26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).

		      16/06/2018 - Alterado para verificar o campo nrplnovo na crapbpr, caso tenha valor neste campo,
			               deve ser pego este campo, caso contrario pegar do campo nrdplaca.
						   (Alcemir Mout's) - (PRB0040101).

          12/07/2018 - Ajuste para alterar a data pagto dentro da opcao "Valor da proposta e data de vencimento" (PRJ 438 - Mateus Z / Mouts).     
              
          19/07/2018 - Chamar nova rotina para validar perda de aprovaçao quando alterado valor ou valor da prestaçao ou Rating (PRJ 438 - Rafael - Mouts).

          13/08/2018 - P437 - Conversao proc_qualif_operac (James)

          
          29/08/2018 - Adicionado retorno do 'insitest' na PROC 'obtem-propostas-emprestimo' PRJ 438 (Mateus Z - Mouts)

         31/08/2018 - P438 - Efetivaçao seguro prestamista -- Paulo Martins -- Mouts          
          
          10/09/2018 - P442 - Tradução das chamadas da validacao, gravacao de bem e interveniente
                       para rotinas convertidas, Inclusao de novos campos nas tabelas de bens alienados, 
                       remocao de tratamento e parametros de bens e intervenientes na verifica-outras-propostas
                       e por fim remocao de tratamento de CPFs de Intervenientes com CPFs dos Bens
                       que esta sendo feito no Oracle (Marcos-Envolti)
                       
          19/10/2018 - P442 - Inclusao de opcao OUTROS VEICULOS onde ha procura por CAMINHAO (Marcos-Envolti)             

          31/10/2018 - P438 - Inclusão de novos campos gravação da Hipoteca	 

		  23/10/2018 - PJ298.2 - Validar emprestimo migrado para listar na tela prestacoes (Rafael Faria-Supero)
          
          13/12/2018  HANDLE sem delete h-b1wgen0059 INC0027352 (Oscar).
          
          19/12/2018 -  P438 nova regra perda de aprovacao 
                        aux_idpeapro: 0 = Nao Perde Aprovacao 
                                      1 = Perde Aprovacao 
                                      2 = Aprovacao Auto.
									  
          29/03/2019 - Incidente 0033759 - Erro na geracao automatica da cessao de credito - Ramon		  

          20/12/2018 - P298.2.2 - Apresentar pagamento na carencia (Adriano Nagasava - Supero)
          			 
          15/04/2019 - P438 - Alterada valida-dados-gerais para não permitir utilizar linha ou finalidade de credito
							que esteja cadastrada em SubSegmento de contratacao Online. (Douglas Pagel / AMcom)

          29/04/2019 - P450 - Nas rotinas altera-valor-proposta e recalcular-emprestimo, incluir para atualizar o campo dsnivori (Heckmann - AMcom)

          11/05/2019 - P298.2.2 - Ajuste de valores de prejuizo (Rafael Faria - Supero)
		
          21/02/2019 - P442 - PreAprovado nova estrutura 
                            + Gravar aceite Online quando operacao nao for AimaroWEB          
                            (Marcos-Envolti)
 ..............................................................................*/

/*................................ DEFINICOES ................................*/

{ sistema/generico/includes/b1wgen0002tt.i  }
{ sistema/generico/includes/b1wgen0024tt.i  }
{ sistema/generico/includes/b1wgen0043tt.i  }
{ sistema/generico/includes/b1wgen0056tt.i  }
{ sistema/generico/includes/b1wgen0059tt.i  }
{ sistema/generico/includes/b1wgen0069tt.i  }
{ sistema/generico/includes/b1wgen0084tt.i  }
{ sistema/generico/includes/b1wgen0084att.i }
{ sistema/generico/includes/b1wgen9999tt.i  }
{ sistema/generico/includes/b1wgen0114tt.i  }
{ sistema/generico/includes/b1wgen0138tt.i  }
{ sistema/generico/includes/b1wgen0147tt.i }
{ sistema/generico/includes/b1wgen0188tt.i  }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR tab_indpagto AS INTE                                           NO-UNDO.
DEF VAR tab_diapagto AS INTE                                           NO-UNDO.
DEF VAR tab_dtcalcul AS DATE                                           NO-UNDO.
DEF VAR tab_inusatab AS LOGI                                           NO-UNDO.
DEF VAR tab_flgfolha AS LOGI                                           NO-UNDO.

DEF VAR aux_qtprecal LIKE crapepr.qtprecal                             NO-UNDO.
DEF VAR aux_msgconta AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_nrctremp AS INTE                                           NO-UNDO.
DEF VAR aux_nrdiacal AS INTE                                           NO-UNDO.
DEF VAR aux_ddlanmto AS INTE                                           NO-UNDO.
DEF VAR aux_qtprepag AS INTE                                           NO-UNDO.
DEF VAR aux_nrdiames AS INTE                                           NO-UNDO.
DEF VAR aux_nrdiamss AS INTE                                           NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_vlsdeved AS DECI                                           NO-UNDO.
DEF VAR aux_vljuracu AS DECI                                           NO-UNDO.
DEF VAR aux_vldescto AS DECI                                           NO-UNDO.
DEF VAR aux_vlprovis AS DECI                                           NO-UNDO.
DEF VAR aux_txdjuros AS DECI     DECIMALS 7                            NO-UNDO.
DEF VAR aux_qtpreapg AS DECI     DECIMALS 4                            NO-UNDO.
DEF VAR aux_vlprepag AS DECI                                           NO-UNDO.
DEF VAR aux_vljurmes AS DECI                                           NO-UNDO.
DEF VAR aux_dtinipag AS DATE                                           NO-UNDO.
DEF VAR aux_dtrefavs AS DATE                                           NO-UNDO.
DEF VAR aux_dtrefere AS DATE                                           NO-UNDO.
DEF VAR aux_dtultpag AS DATE                                           NO-UNDO.
DEF VAR aux_dtcalcul AS DATE                                           NO-UNDO.
DEF VAR aux_dtultdia AS DATE                                           NO-UNDO.
DEF VAR aux_dtmesant AS DATE                                           NO-UNDO.
DEF VAR aux_flghaavs AS LOGI                                           NO-UNDO.
DEF VAR aux_inhst093 AS LOGI                                           NO-UNDO.
DEF VAR aux_cdpesqui AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdaval1 AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdaval2 AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdavali AS CHAR                                           NO-UNDO.
DEF VAR aux_dslcremp AS CHAR                                           NO-UNDO.
DEF VAR aux_dsfinemp AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dsmensag AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_vlr_arrasto AS DECI                                        NO-UNDO.
DEF VAR aux_dadosusr AS CHAR                                           NO-UNDO.
DEF VAR aux_vlrtarif AS DECI                                        NO-UNDO.
DEF VAR par_loginusr AS CHAR                                           NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                           NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                           NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                           NO-UNDO.
DEF VAR par_numipusr AS CHAR                                           NO-UNDO.

DEF VAR h-b1wgen0024  AS HANDLE                                        NO-UNDO.
DEF VAR h-b1wgen0056  AS HANDLE                                        NO-UNDO.
DEF VAR h-b1wgen0084  AS HANDLE                                        NO-UNDO.
DEF VAR h-b1wgen9999  AS HANDLE                                        NO-UNDO.
DEF VAR h-b1wgen0002i AS HANDLE                                        NO-UNDO.
DEF VAR h-b1wgen0138  AS HANDLE                                        NO-UNDO.
DEF VAR h-b1wgen0195  AS HANDLE                                        NO-UNDO.


DEF TEMP-TABLE tt-aval-crapbem                                         NO-UNDO
    LIKE tt-crapbem
    USE-INDEX crapbem2 USE-INDEX tt-crapbem AS PRIMARY.

DEF TEMP-TABLE bk-aval-crapbem                                         NO-UNDO
    LIKE tt-crapbem.

DEF TEMP-TABLE tt-bens-bpr                                             NO-UNDO
    LIKE crapbpr.


/*................................. FUNCTIONS ...............................*/

FUNCTION verificaContrato RETURNS CHARACTER
        ( INPUT par_cdcooper AS INTE ,
      INPUT par_nrdconta AS INTE ,
      INPUT par_nrctremp AS INTE ,
      INPUT par_nrctrem2 AS INTE ,
      INPUT par_inusatab AS INTE ,
      INPUT par_nralihip AS INTE ):
                                                    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    DO WHILE TRUE:

       IF   par_nrctremp = 0   THEN
            DO:
                aux_cdcritic = 361.
                LEAVE.
            END.

       IF   CAN-FIND(crapmcr WHERE crapmcr.cdcooper = par_cdcooper  AND
                                   crapmcr.nrdconta = par_nrdconta  AND
                                   crapmcr.nrcontra = par_nrctremp  AND
                                   crapmcr.tpctrmif = 1)            OR
            CAN-FIND(crawepr WHERE crawepr.cdcooper = par_cdcooper  AND
                                   crawepr.nrdconta = par_nrdconta  AND
                                   crawepr.nrctremp = par_nrctremp) OR
            CAN-FIND(crapepr WHERE crapepr.cdcooper = par_cdcooper  AND
                                   crapepr.nrdconta = par_nrdconta  AND
                                   crapepr.nrctremp = par_nrctremp) OR
            CAN-FIND(crapprp WHERE crapprp.cdcooper = par_cdcooper  AND
                                   crapprp.nrdconta = par_nrdconta  AND
                                   crapprp.nrctrato = par_nrctremp  AND
                                   crapprp.tpctrato = 90)           THEN
            DO:
                aux_cdcritic = 670.
                LEAVE.
            END.

       LEAVE.

    END.

    /* Devolver a critica correspondente */
    IF   aux_cdcritic <> 0   THEN
         DO:
             FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                NO-LOCK NO-ERROR.

             IF   AVAIL crapcri   THEN
                  ASSIGN aux_dscritic = crapcri.dscritic.

         END.

    RETURN aux_dscritic.

END FUNCTION.


FUNCTION trazObservacao RETURN CHARACTER

        (INPUT par_cdcooper  AS INTE ,
         INPUT par_nrdconta  AS INTE ,
         INPUT par_nrctremp  AS INTE ,
         OUTPUT aux_dscritic AS CHAR):

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    DO WHILE TRUE:

       FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                          crawepr.nrdconta = par_nrdconta   AND
                          crawepr.nrctremp = par_nrctremp
                          NO-LOCK NO-ERROR.

       IF   NOT AVAIL crawepr   THEN
            DO:
                aux_dscritic = "356 - Contrato de emprestimo nao encontrado.".
                LEAVE.
            END.

       LEAVE.

    END.

    IF   aux_dscritic <> ""   THEN
         RETURN "".
    RETURN crawepr.dsobserv.

END FUNCTION.

/*............................ PROCEDURES EXTERNAS ...........................*/

/******************************************************************************/
/**           Procedure para calcular saldo devedor de emprestimos           **/
/******************************************************************************/
PROCEDURE saldo-devedor-epr:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_vlsdeved AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vltotpre AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_qtprecal LIKE crapepr.qtprecal             NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter saldo devedor do associado em emprestimos".

    SALDO:
    DO ON ERROR UNDO , LEAVE:
       
       RUN obtem-parametros-tabs (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_nrdconta,
                                   INPUT par_dtmvtolt,
                                  OUTPUT tab_indpagto,
                                  OUTPUT tab_diapagto,
                                  OUTPUT tab_dtcalcul,
                                  OUTPUT tab_flgfolha,
                                  OUTPUT tab_inusatab,
                                  OUTPUT TABLE tt-erro).

       IF  RETURN-VALUE = "NOK"  THEN
           UNDO SALDO , LEAVE SALDO.

       /* Se o contrato foi prenchido */
       IF  par_nrctremp <> 0   THEN
           DO:
               /* Calcula somente para o contrato enviado como parametro */
               FOR EACH crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                                      crapepr.nrdconta = par_nrdconta AND
                                      crapepr.nrctremp = par_nrctremp NO-LOCK:

                   RUN calcula-saldo-epr (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_cdoperad,
                                          INPUT par_nmdatela,
                                          INPUT par_idorigem,
                                          INPUT par_nrdconta,
                                          INPUT par_idseqttl,
                                          INPUT par_dtmvtolt,
                                          INPUT par_dtmvtopr,
                                          INPUT par_nrctremp,
                                          INPUT par_cdprogra,
                                          INPUT par_inproces,
                                          INPUT par_flgerlog,
                                          INPUT-OUTPUT par_vlsdeved,
                                          INPUT-OUTPUT par_vltotpre,
                                          INPUT-OUTPUT par_qtprecal).

                   IF  RETURN-VALUE <> "OK"   THEN
                       UNDO SALDO, LEAVE SALDO.

               END.
           END.
      ELSE
           DO:
               /* Calcula para todos os emprestimos da conta */
               FOR EACH crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                                      crapepr.nrdconta = par_nrdconta NO-LOCK:

                   RUN calcula-saldo-epr (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_cdoperad,
                                          INPUT par_nmdatela,
                                          INPUT par_idorigem,
                                          INPUT par_nrdconta,
                                          INPUT par_idseqttl,
                                          INPUT par_dtmvtolt,
                                          INPUT par_dtmvtopr,
                                          INPUT crapepr.nrctremp,
                                          INPUT par_cdprogra,
                                          INPUT par_inproces,
                                          INPUT par_flgerlog,
                                          INPUT-OUTPUT par_vlsdeved,
                                          INPUT-OUTPUT par_vltotpre,
                                          INPUT-OUTPUT par_qtprecal).

                   IF  RETURN-VALUE <> "OK"   THEN
                       UNDO SALDO, LEAVE SALDO.

               END.
           END.

       ASSIGN aux_flgtrans = TRUE.

    END.

    IF   NOT aux_flgtrans THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF  AVAILABLE tt-erro  THEN
                 ASSIGN aux_cdcritic = tt-erro.cdcritic
                        aux_dscritic = tt-erro.dscritic.
             ELSE
                 RUN gera_erro (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT 1,
                                INPUT aux_cdcritic,
                                INPUT-OUTPUT aux_dscritic).

             IF  par_flgerlog  THEN
                 RUN proc_gerar_log (INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid).
             RETURN "NOK".
         END.

    IF   par_flgerlog  THEN
         RUN proc_gerar_log (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "",
                             INPUT aux_dsorigem,
                             INPUT aux_dstransa,
                             INPUT TRUE,
                             INPUT par_idseqttl,
                             INPUT par_nmdatela,
                             INPUT par_nrdconta,
                            OUTPUT aux_nrdrowid).

    RETURN "OK".

END PROCEDURE.


/******************************************************************************
 Procedure para obter dados de emprestimos do associado
******************************************************************************/
PROCEDURE obtem-dados-emprestimos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcalcul AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgcondc AS LOGI                           NO-UNDO.
    
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dados-epr-out.

    DEF VAR aux_nmprimtl AS CHAR                                    NO-UNDO.
    DEF VAR aux_lsdtelas AS CHAR                                    NO-UNDO.
    DEF VAR aux_tpdocged AS INTE                                    NO-UNDO.
    DEF VAR aux_nrregist AS INTE                                    NO-UNDO.
    DEF VAR aux_permulta AS DECI                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dados-epr.
    EMPTY TEMP-TABLE tt-dados-epr-out.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter dados dos emprestimos do associado".
    
    RUN obtem-parametros-tabs (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_nrdconta,
                               INPUT par_dtmvtolt,
                              OUTPUT tab_indpagto,
                              OUTPUT tab_diapagto,
                              OUTPUT tab_dtcalcul,
                              OUTPUT tab_flgfolha,
                              OUTPUT tab_inusatab,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro  THEN
                ASSIGN aux_cdcritic = tt-erro.cdcritic
                       aux_dscritic = tt-erro.dscritic.

            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).

            RETURN "NOK".
        END.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "GENERI"       AND
                       craptab.cdempres = 00             AND
                       craptab.cdacesso = "DIGITALIZA"   AND
                       craptab.tpregist = 5    /* Contrt. emprestimo/financiamento (GED) */
                       NO-LOCK NO-ERROR.

    IF  AVAIL craptab THEN
        DO:
          ASSIGN aux_tpdocged = INT(ENTRY(3,craptab.dstextab,";")).
        END.

    /** Leitura da crapass efetuada na procedure obtem-parametros-tabs **/
    ASSIGN aux_nmprimtl = crapass.nmprimtl
           aux_lsdtelas = "EXTEMP,IMPRES".

    FIND craptab WHERE craptab.cdcooper = 3            AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "USUARI"     AND
                       craptab.cdempres = 11           AND
                       craptab.cdacesso = "PAREMPCTL"  AND
                       craptab.tpregist = 01
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL craptab THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Informacoes nao encontradas.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).

            RETURN "NOK".
        END.

    ASSIGN aux_permulta = DEC(SUBSTRING(craptab.dstextab,1,6)).

    /* Se contrato nao enviado, ler todos da conta */
    IF  par_nrctremp = 0 THEN
        DO:
            FOR EACH crapepr WHERE crapepr.cdcooper  = par_cdcooper AND
                                   crapepr.nrdconta  = par_nrdconta NO-LOCK
                                   BY crapepr.cdlcremp BY crapepr.cdfinemp:
                 
                RUN obtem-dados-conta-contrato (INPUT par_cdcooper,
                                                INPUT par_cdagenci,
                                                INPUT par_nrdcaixa,
                                                INPUT par_cdoperad,
                                                INPUT par_nmdatela,
                                                INPUT par_idorigem,
                                                INPUT par_nrdconta,
                                                INPUT par_idseqttl,
                                                INPUT par_dtmvtolt,
                                                INPUT par_dtmvtopr,
                                                INPUT par_dtcalcul,
                                                INPUT par_nrctremp,
                                                INPUT par_cdprogra,
                                                INPUT par_inproces,
                                                INPUT par_flgcondc,
                                                INPUT aux_nmprimtl,
                                                INPUT aux_lsdtelas,
                                                INPUT aux_tpdocged,
                                                INPUT par_flgerlog,
                                                INPUT aux_permulta,
                                                OUTPUT TABLE tt-erro,
                                          INPUT-OUTPUT TABLE tt-dados-epr).

                IF  RETURN-VALUE <> "OK"   THEN
                    RETURN "NOK".
            END.
        END.
    ELSE /* Ler um contrato especifico */
        DO:
            FOR EACH crapepr WHERE crapepr.cdcooper  = par_cdcooper AND
                                   crapepr.nrdconta  = par_nrdconta AND
                                   crapepr.nrctremp  = par_nrctremp
                                   BY crapepr.cdlcremp BY crapepr.cdfinemp:
            
                RUN obtem-dados-conta-contrato (INPUT par_cdcooper,
                                                INPUT par_cdagenci,
                                                INPUT par_nrdcaixa,
                                                INPUT par_cdoperad,
                                                INPUT par_nmdatela,
                                                INPUT par_idorigem,
                                                INPUT par_nrdconta,
                                                INPUT par_idseqttl,
                                                INPUT par_dtmvtolt,
                                                INPUT par_dtmvtopr,
                                                INPUT par_dtcalcul,
                                                INPUT par_nrctremp,
                                                INPUT par_cdprogra,
                                                INPUT par_inproces,
                                                INPUT par_flgcondc,
                                                INPUT aux_nmprimtl,
                                                INPUT aux_lsdtelas,
                                                INPUT aux_tpdocged,
                                                INPUT par_flgerlog,
                                                INPUT aux_permulta,
                                                OUTPUT TABLE tt-erro,
                                          INPUT-OUTPUT TABLE tt-dados-epr).

                IF  RETURN-VALUE <> "OK"   THEN
                    RETURN "NOK".

            END.

        END.
    
    /* Tratamento de paginação somente para web*/
    IF  par_idorigem =  5 AND
        par_nriniseq <> 0 AND 
        par_nrregist <> 0 AND 
        par_nrctremp = 0 THEN
        DO:
            ASSIGN aux_nrregist = par_nrregist.
            
            FOR EACH tt-dados-epr NO-LOCK:

                ASSIGN par_qtregist = par_qtregist + 1.

                /* controles da paginação */

                IF  (par_qtregist < par_nriniseq) OR
                    (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                    NEXT.

                IF  aux_nrregist > 0 THEN
                    DO: 
                        CREATE tt-dados-epr-out.
                        BUFFER-COPY tt-dados-epr TO tt-dados-epr-out.
                    END.

                ASSIGN aux_nrregist = aux_nrregist - 1.
            
            END.
        END.
    ELSE
        DO:
            FOR EACH tt-dados-epr:
                CREATE tt-dados-epr-out.
                BUFFER-COPY tt-dados-epr TO tt-dados-epr-out.
            END.
        END.
    
    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Procedure para validar a liquidacao de emprestimos do associado
 Jose Luis Marchezoni - DB1 Informatica, 30/03/2011
******************************************************************************/
PROCEDURE valida-liquidacao-emprestimos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtoep AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_qtlinsel AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlsdeved AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tosdeved AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_idenempr AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_tpdretor AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_msgretor AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgativo AS INT                                     NO-UNDO.
    DEF VAR aux_lim_adp  AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN
        aux_cdcritic = 0
        aux_dscritic = ""
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Validar dados dos emprestimos do associado"
        aux_returnvl = "NOK"
        aux_lim_adp  = "N".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:

        EMPTY TEMP-TABLE tt-erro.
        IF  par_nrctremp <> 0 THEN DO:
            /* TRATA TIPO DE EMPRESTIMO LIMITE/ADP                          */
            /* DIEGO SIMAS (AMcom)                                          */
            IF  par_idenempr = 2 THEN DO:            
                FIND craplim WHERE craplim.cdcooper = par_cdcooper   AND
                                    craplim.nrdconta = par_nrdconta   AND
                                    craplim.nrctrlim = par_nrctremp
                                    NO-LOCK NO-ERROR.

                IF  AVAIL craplim  THEN DO:
                    aux_lim_adp = "S".
                END.
                FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                                    crapass.nrdconta = par_nrdconta
                                    NO-LOCK NO-ERROR.

                IF  AVAIL crapass  THEN DO:
                    aux_lim_adp = "S".
                END.
                IF  aux_lim_adp = "N" THEN DO:
                    ASSIGN aux_cdcritic = 90001.
                    LEAVE Valida.
                END.
                ELSE DO:
                    ASSIGN par_tpdretor = "".
                END.                
            END.
            ELSE DO:
                 FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                                    crawepr.nrdconta = par_nrdconta   AND
                                    crawepr.nrctremp = par_nrctremp
                                    NO-LOCK NO-ERROR.

                 IF   NOT AVAIL crawepr   THEN
                      DO:
                          ASSIGN aux_cdcritic = 510.
                          LEAVE Valida.
                      END.

                 IF crawepr.tpemprst = 1   OR
                    crawepr.tpemprst = 2   THEN
                    DO:
                        IF crawepr.dtlibera >= par_dtmvtolt   THEN
                           DO:
                               aux_dscritic = 
                                     "Atencao! contrato liberado nesta "       +
                                     "data. Liquidacao/antecipacao permitida " +
                                     "a partir de "                            +
                                     STRING(crawepr.dtlibera + 1,"99/99/9999") +
                                     ".".
                               LEAVE Valida.
                           END.
                    END.
                    
                /* Verifica se ha contratos de acordo */            
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                
                RUN STORED-PROCEDURE pc_verifica_acordo_ativo
                  aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                      ,INPUT par_nrdconta
                                                      ,INPUT par_nrctremp
													  ,INPUT 3
                                                      ,0
                                                      ,0
                                                      ,"").

                CLOSE STORED-PROC pc_verifica_acordo_ativo
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                ASSIGN aux_cdcritic = 0
                       aux_dscritic = ""
                       aux_cdcritic = pc_verifica_acordo_ativo.pr_cdcritic WHEN pc_verifica_acordo_ativo.pr_cdcritic <> ?
                       aux_dscritic = pc_verifica_acordo_ativo.pr_dscritic WHEN pc_verifica_acordo_ativo.pr_dscritic <> ?
                       aux_flgativo = INT(pc_verifica_acordo_ativo.pr_flgativo).
                
                IF aux_cdcritic > 0 THEN
                  DO:
                      RUN fontes/critic.p.
                      LEAVE Valida.
             END.
                ELSE IF aux_dscritic <> ? AND aux_dscritic <> "" THEN
                  DO:
                    LEAVE Valida.
                  END.

                IF aux_flgativo = 1 THEN
                  DO:
                    ASSIGN aux_dscritic = "Nao e possivel marcar o contrato " + STRING(par_nrctremp) + " para liquidar, contrato esta em acordo.".
                    LEAVE Valida.
                  END.  

        /* Validar Data do Emprestimo */
        IF  par_dtmvtoep = par_dtmvtolt  THEN
            DO:
               ASSIGN
                 par_tpdretor = "D" /* Display */
                 par_msgretor = "~n   Nao e' possivel liquidar emprestimo   " +
                                "~n      feito nesta data -"                  +
                                STRING(par_dtmvtolt,"99/99/9999") + "~n".
               LEAVE Valida.
            END.
            END.                                 

        /* Validar a quantidade de linhas selecionadas */
        IF  par_qtlinsel >= 10 THEN
            DO:
               ASSIGN aux_dscritic = "Maximo de emprestimos para liquidar: 10".
               LEAVE Valida.
            END.

        /* Validar o saldo devedor */
        IF (par_tosdeved + par_vlsdeved) > par_vlemprst THEN
           DO:
              IF   par_vlsdeved = 0   THEN
                   ASSIGN par_tpdretor = "MC". /* Mensagem */
              ELSE
                   ASSIGN par_tpdretor = "M".

              ASSIGN par_msgretor =
                            "Saldo a liquidar e maior que o valor a " +
                            "emprestar. Confirme (S/N):".
              LEAVE Valida.
           END.

        IF  par_vlsdeved = 0   THEN /* Validacao final, proxima tela */
            DO:
                ASSIGN par_tpdretor = "C".
                LEAVE Valida.
            END.

        LEAVE Valida.
        END. /* par_nrctremp <> 0 */
        ELSE DO:
            ASSIGN par_tpdretor = "C".
            LEAVE Valida.
    END.
    END. /* VALIDA */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_returnvl = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    IF  par_flgerlog AND aux_returnvl = "NOK" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT NO,
                            INPUT 1, /** idseqttl **/
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

    RETURN aux_returnvl.

END PROCEDURE.

/******************************************************************************
 Procedure para obter/retornar a temp-table para liquidacao de emprestimos com
 o flag de selecao atualizado conforme o parametro de contrato selecionados
 Jose Luis Marchezoni - DB1 Informatica, 01/04/2011
******************************************************************************/
PROCEDURE obtem-emprestimos-selecionados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_dsctrliq AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-dados-epr.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_contaliq AS INTE                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN
        aux_cdcritic = 0
        aux_dscritic = ""
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Selecionar os emprestimos do associado"
        aux_returnvl = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:

        FIND craplcr WHERE craplcr.cdcooper = par_cdcooper   AND
                           craplcr.cdlcremp = par_cdlcremp
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL craplcr   THEN
             DO:
                 ASSIGN aux_cdcritic = 363.
                 LEAVE Valida.
             END.

        IF   craplcr.flgrefin   THEN  /* Se pode refinanciar */
             DO:
                 FOR EACH tt-dados-epr WHERE tt-dados-epr.nrctremp <> 0 AND
                                         tt-dados-epr.vlsdeved <> 0:
                    /* verifica se existe contrato de liquidacao equivalente */
                    CONTA-LIQ: DO aux_contaliq = 1 TO NUM-ENTRIES(par_dsctrliq):
                        IF  TRIM(ENTRY(aux_contaliq,par_dsctrliq)) =
                            TRIM(STRING(tt-dados-epr.nrctremp,"zz,zzz,zz9")) THEN
                            DO:
                               ASSIGN tt-dados-epr.idseleca = "*".
                               LEAVE CONTA-LIQ.
                             END.
                    END.
                 END.
             END.
        ELSE                          /* Se nao pode refinanciar */
            DO:
                EMPTY TEMP-TABLE tt-dados-epr.
            END.

        LEAVE Valida.
    END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_returnvl = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    IF  par_flgerlog AND aux_returnvl = "NOK" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT NO,
                            INPUT 1, /** idseqttl **/
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

    RETURN aux_returnvl.

END PROCEDURE.

/******************************************************************************
 Procedure para obter extrato de emprestimos
******************************************************************************/
PROCEDURE obtem-extrato-emprestimo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-extrato_epr.

    DEF  VAR aux_cdhistor AS INTE                                   NO-UNDO.
    DEF  VAR aux_dshistor AS CHAR                                   NO-UNDO.
    DEF  VAR aux_flgpripa AS LOGI EXTENT 999                        NO-UNDO.
    DEF  VAR aux_vllantmo AS DECI                                   NO-UNDO.

    DEF  BUFFER crablem FOR craplem.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-extrato_epr.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter extrato do emprestimo".

    FIND crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                       crapepr.nrdconta = par_nrdconta AND
                       crapepr.nrctremp = par_nrctremp NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapepr  THEN
        DO:
            ASSIGN aux_cdcritic = 356
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).

            RETURN "NOK".
        END.

    ASSIGN aux_dshistor = "1032,1033,1034,1035,1048,1049,2566,2567,2388,2473,2389,2390,2475,2392,2474,2393,2394,2476".

    FOR EACH craplem WHERE craplem.cdcooper  = par_cdcooper AND
                           craplem.nrdconta  = par_nrdconta AND
                           craplem.nrctremp  = par_nrctremp AND
                         ((craplem.dtmvtolt >= par_dtiniper AND
                           par_dtiniper     <> ?)           OR
                           par_dtiniper      = ?)           AND
                         ((craplem.dtmvtolt <= par_dtfimper AND
                           par_dtfimper     <> ?)           OR
                           par_dtfimper      = ?)
                           NO-LOCK USE-INDEX craplem2
                                             BREAK BY craplem.cdcooper
                                                      BY craplem.nrdconta
                                                         BY craplem.dtmvtolt:

        IF   FIRST-OF(craplem.dtmvtolt)   THEN
             DO:
                 ASSIGN aux_flgpripa = FALSE.
             END.

        /* Desprezando historicos de concessao de credito com juros
          a apropriar e lancamendo para desconto */
        IF   CAN-DO(aux_dshistor,STRING(craplem.cdhistor))    THEN
             NEXT.

        /** Verifica se o contrato estah em prejuizo */
        IF  crapepr.tpemprst = 1 AND
            crapepr.inprejuz = 1 AND craplem.dtmvtolt >= crapepr.dtprejuz THEN
            DO:
                /* Lote do novo emprestimo */
                IF craplem.nrdolote <= 600000 OR craplem.nrdolote >= 650000 THEN
                   NEXT.

            END. /* END IF crapepr.inprejuz = 1 */

        CREATE tt-extrato_epr.
        ASSIGN tt-extrato_epr.qtpresta = IF  craplem.vlpreemp > 0  THEN
                                             ROUND(craplem.vllanmto /
                                                   craplem.vlpreemp,4)
                                         ELSE
                                             0.
        /*Historicos que nao vao compor o saldo,
          mas vao aparecer no relatorio*/
        IF  CAN-DO("1048,1049,1050,1051,1717,1720,1708,1711,2566,2567",
                   STRING(craplem.cdhistor)) THEN
            ASSIGN tt-extrato_epr.flgsaldo = FALSE.

        /*Historicos que nao vao aparecer no relatorio,
          mas vao compor saldo */
        IF  craplem.cdhistor = 1040 OR craplem.cdhistor = 1041 OR    /* PP */
            craplem.cdhistor = 1042 OR craplem.cdhistor = 1043 OR    /* PP */
            craplem.cdhistor = 2471 OR craplem.cdhistor = 2472 OR    /* POS */
            craplem.cdhistor = 2358 OR craplem.cdhistor = 2359 THEN  /* POS */
            ASSIGN tt-extrato_epr.flglista = FALSE.

        /* Verifica se o contrato estah em prejuizo */
        IF  crapepr.tpemprst = 1 AND
            crapepr.inprejuz = 1 AND craplem.dtmvtolt >= crapepr.dtprejuz THEN
            DO:
                /* Multa e Juros de Mora de Prejuizo */
                IF CAN-DO("1733,1734,1735,1736",STRING(craplem.cdhistor)) THEN
                   ASSIGN tt-extrato_epr.flgsaldo = FALSE.

            END. /* END IF crapepr.inprejuz = 1 */

        ASSIGN aux_vllantmo = craplem.vllanmto.

        /* Se lancamento de pagamento*/
        IF   CAN-DO("1044,1039,1057,1045",STRING(craplem.cdhistor)) THEN 
             DO:
        
                 IF   NOT aux_flgpripa[craplem.nrparepr]   THEN
                      DO:
                          CASE craplem.cdhistor:
                               WHEN 1044 THEN ASSIGN aux_cdhistor = 1077.
                               /* Pagamento de avalista - Juros de Mora */
                               WHEN 1045 THEN ASSIGN aux_cdhistor = 1619.
                               WHEN 1057 THEN ASSIGN aux_cdhistor = 1620.
                               /* Default */
                               OTHERWISE aux_cdhistor = 1078.
                          END CASE.

                          /* Achar juros de inadimplencia desta parcela */
                          FIND FIRST crablem WHERE
                                     crablem.cdcooper = craplem.cdcooper   AND
                                     crablem.nrdconta = craplem.nrdconta   AND
                                     crablem.nrctremp = craplem.nrctremp   AND
                                     crablem.nrparepr = craplem.nrparepr   AND
                                     crablem.dtmvtolt = craplem.dtmvtolt   AND
                                     crablem.cdhistor = aux_cdhistor
                                     NO-LOCK NO-ERROR.

                          /* Se achar o juros de mora entao pegar*/
                          /* o valor de pagamento e somar o juro */
                          IF   AVAIL crablem   THEN
                               DO:
                                    ASSIGN aux_vllantmo = aux_vllantmo +
                                                           crablem.vllanmto.
                               END.

                          /* Historico de juros de multa */
                          CASE craplem.cdhistor:
                               WHEN 1044 THEN ASSIGN aux_cdhistor = 1047.
                               /* Pagamento de avalista - Multa */
                               WHEN 1045 THEN ASSIGN aux_cdhistor = 1540.
                               WHEN 1057 THEN ASSIGN aux_cdhistor = 1618.
                               /* Default */
                               OTHERWISE aux_cdhistor = 1076.
                          END CASE.

                          /* Achar juros de inadimplencia desta parcela */
                          FIND FIRST crablem WHERE
                                     crablem.cdcooper = craplem.cdcooper   AND
                                     crablem.nrdconta = craplem.nrdconta   AND
                                     crablem.nrctremp = craplem.nrctremp   AND
                                     crablem.nrparepr = craplem.nrparepr   AND
                                     crablem.dtmvtolt = craplem.dtmvtolt   AND
                                     crablem.cdhistor = aux_cdhistor
                                     NO-LOCK NO-ERROR.

                          /* Se achar a multa entao pegar*/
                          /* o valor de pagamento e somar */
                          IF   AVAIL crablem   THEN
                               DO:
                                    ASSIGN aux_vllantmo = aux_vllantmo +
                                                           crablem.vllanmto.
                               END.

                          /* Historico de IOF PP - Emprestimo */
                          CASE craplem.cdhistor:
                               WHEN 1044 THEN ASSIGN aux_cdhistor = 2311.
                               /* Pagamento de avalista - Multa */
                               WHEN 1045 THEN ASSIGN aux_cdhistor = 2311.
                               WHEN 1057 THEN ASSIGN aux_cdhistor = 2311.
                               /* Default */
                               OTHERWISE aux_cdhistor = 2311.
                          END CASE.

                          /* Achar juros de inadimplencia desta parcela */
                          FIND FIRST crablem WHERE
                                     crablem.cdcooper = craplem.cdcooper   AND
                                     crablem.nrdconta = craplem.nrdconta   AND
                                     crablem.nrctremp = craplem.nrctremp   AND
                                     crablem.nrparepr = craplem.nrparepr   AND
                                     crablem.dtmvtolt = craplem.dtmvtolt   AND
                                     crablem.cdhistor = aux_cdhistor
                                     NO-LOCK NO-ERROR.

                          /* Se achar a multa entao pegar*/
                          /* o valor de pagamento e somar */
                          IF   AVAIL crablem   THEN
                               ASSIGN aux_vllantmo = aux_vllantmo + crablem.vllanmto.                               
                               
                          /* Historico de IOF PP - Financiamento */
                          CASE craplem.cdhistor:
                               WHEN 1044 THEN ASSIGN aux_cdhistor = 2312.
                               /* Pagamento de avalista - Multa */
                               WHEN 1045 THEN ASSIGN aux_cdhistor = 2312.
                               WHEN 1057 THEN ASSIGN aux_cdhistor = 2312.
                               /* Default */
                               OTHERWISE aux_cdhistor = 2312.
                          END CASE.

                          /* Achar juros de inadimplencia desta parcela */
                          FIND FIRST crablem WHERE
                                     crablem.cdcooper = craplem.cdcooper   AND
                                     crablem.nrdconta = craplem.nrdconta   AND
                                     crablem.nrctremp = craplem.nrctremp   AND
                                     crablem.nrparepr = craplem.nrparepr   AND
                                     crablem.dtmvtolt = craplem.dtmvtolt   AND
                                     crablem.cdhistor = aux_cdhistor
                                     NO-LOCK NO-ERROR.

                          /* Se achar a multa entao pegar*/
                          /* o valor de pagamento e somar */
                          IF   AVAIL crablem   THEN
                               ASSIGN aux_vllantmo = aux_vllantmo + crablem.vllanmto.
                               
                          ASSIGN aux_flgpripa[craplem.nrparepr] = TRUE.

                      END.
             END.

        FIND craphis WHERE craphis.cdcooper = par_cdcooper     AND
                           craphis.cdhistor = craplem.cdhistor NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE craphis  THEN
            ASSIGN tt-extrato_epr.dshistor = STRING(craplem.cdhistor)
                   tt-extrato_epr.dshistoi = STRING(craplem.cdhistor)
                   tt-extrato_epr.indebcre = "*".
        ELSE
           DO:
              ASSIGN tt-extrato_epr.dshistor =
                      STRING(craphis.cdhistor,"9999") +  " - " + craphis.dshistor
                      tt-extrato_epr.dshistoi = craphis.dshistor
                      tt-extrato_epr.indebcre = craphis.indebcre
                      tt-extrato_epr.dsextrat = craphis.dsextrat.
    
              /* Pagamento de avalista */
              IF (CAN-DO("1057,1045,1620,1619,1618,1540",STRING(craphis.cdhistor))  OR   /* PP */
                  CAN-DO("2335,2336,2377,2375,2369,2367",STRING(craphis.cdhistor))) AND  /* POS */
                 craplem.nrseqava > 0 THEN
                 DO:
                     ASSIGN tt-extrato_epr.dshistor = tt-extrato_epr.dshistor + " " +
                                                      STRING(craplem.nrseqava)
                            tt-extrato_epr.dsextrat = craphis.dsextrat + " " +
                                                      STRING(craplem.nrseqava).
                 END.

              IF CAN-DO("1077,1078,1619,1620",STRING(craphis.cdhistor)) OR    /* PP */
                 CAN-DO("2371,2373,2375,2377",STRING(craphis.cdhistor)) THEN  /* POS */
                 ASSIGN tt-extrato_epr.indebcre = "D".
           END.

        ASSIGN tt-extrato_epr.dtmvtolt = craplem.dtmvtolt
               tt-extrato_epr.cdhistor = craplem.cdhistor
               tt-extrato_epr.nrseqdig = craplem.nrseqdig
               tt-extrato_epr.cdagenci = craplem.cdagenci
               tt-extrato_epr.cdbccxlt = craplem.cdbccxlt
               tt-extrato_epr.nrdolote = craplem.nrdolote
               tt-extrato_epr.nrdocmto = craplem.nrdocmto
               tt-extrato_epr.vllanmto = aux_vllantmo
               tt-extrato_epr.txjurepr = craplem.txjurepr
               tt-extrato_epr.tpemprst = crapepr.tpemprst
               tt-extrato_epr.cdorigem = craplem.cdorigem
               tt-extrato_epr.qtdiacal = craplem.qtdiacal
               tt-extrato_epr.vlrdtaxa = craplem.vltaxprd * 100.

        IF   craplem.nrparepr <> 0 THEN
             tt-extrato_epr.nrparepr = STRING(craplem.nrparepr,"zz9").
        ELSE /* Se ajuste, parcela = 99 para aparecer por ultimo no extrato*/
        IF   CAN-DO("1040,1041,1042,1043",STRING(craplem.cdhistor)) OR    /* PP */
             CAN-DO("2471,2472,2358,2359",STRING(craplem.cdhistor)) THEN  /* POS */
             tt-extrato_epr.nrparepr = STRING("","zz9").

    END. /** Fim do FOR EACH craplem **/
    
    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).
      
    RETURN "OK".

END PROCEDURE.


/****************************************************************************
   Procedure para obter todas as propostas de emprestimo do cooperado
*****************************************************************************/
PROCEDURE obtem-propostas-emprestimo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-proposta-epr.
    DEF OUTPUT PARAM TABLE FOR tt-dados-gerais.
    DEF OUTPUT PARAM par_dsdidade AS CHAR                           NO-UNDO.

    DEF  VAR         aux_cdempres AS INTE                           NO-UNDO.
    DEF  VAR         aux_lscatbem AS CHAR                           NO-UNDO.
    DEF  VAR         aux_lscathip AS CHAR                           NO-UNDO.
    DEF  VAR         aux_ddmesnov AS INTE                           NO-UNDO.
    DEF  VAR         aux_dtdpagto AS DATE                           NO-UNDO.
    DEF  VAR         aux_dsdidade AS CHAR                           NO-UNDO.

    DEF  VAR         par_nrdeanos AS INTE                           NO-UNDO.
    DEF  VAR         par_nrdmeses AS INTE                           NO-UNDO.
    DEF  VAR         aux_flexclui AS LOG                            NO-UNDO.
    DEF  VAR         aux_portabilidade AS CHAR                      NO-UNDO.
    DEF  VAR         aux_err_efet AS INTE                           NO-UNDO.
    DEF  VAR         aux_dtlibera AS DATE                           NO-UNDO.

    DEF  VAR        aux_inobriga AS CHAR                           NO-UNDO.
    DEF  VAR        aux_incdccon AS INTE                           NO-UNDO.        
    DEF  VAR        h-b1wgen0097 AS HANDLE                         NO-UNDO.
    DEF  VAR        aux_dscatbem AS CHAR                           NO-UNDO.
    DEF  VAR        i            AS INTE                           NO-UNDO.    
    DEF  VAR        aux_qtdias_carencia AS INTE                    NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter as propostas de emprestimo.".

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-proposta-epr.
    EMPTY TEMP-TABLE tt-dados-gerais.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-WAIT NO-ERROR.
    
    /* Buscar dados Gerais */
    DO WHILE TRUE:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                           crapass.nrdconta = par_nrdconta
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapass THEN
             DO:
                 aux_cdcritic = 9.
                 LEAVE.
             END.

        /* Pegar a empresa do associado */
        IF   crapass.inpessoa = 1   THEN
             DO:
                 FIND crapttl WHERE crapttl.cdcooper = par_cdcooper   AND
                                    crapttl.nrdconta = par_nrdconta   AND
                                    crapttl.idseqttl = 1
                                    NO-LOCK NO-ERROR.

                 IF   AVAIL crapttl   THEN
                      aux_cdempres = crapttl.cdempres.

             END.
        ELSE
             DO:
                 FIND crapjur WHERE crapjur.cdcooper = par_cdcooper   AND
                                    crapjur.nrdconta = par_nrdconta
                                    NO-LOCK NO-ERROR.

                 IF   AVAIL crapjur   THEN
                      aux_cdempres = crapjur.cdempres.
             END.


        /*  Descricao da categoria de bens alienaveis  */
        FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                           craptab.nmsistem = "CRED"       AND
                           craptab.tptabela = "GENERI"     AND
                           craptab.cdempres = 0            AND
                           craptab.cdacesso = "CATEGORIAS" AND
                           craptab.tpregist = 0            NO-LOCK NO-ERROR.

        IF   NOT AVAIL craptab   THEN
             DO:
                 ASSIGN aux_cdcritic = 0
                        aux_dscritic = "Falta descricao de categoria de " +
                                       "bens alienaveis.".

                 LEAVE.
             END.

        aux_lscatbem = TRIM (craptab.dstextab).

        /*  Descricao da categoria de bens hipotecaveis  */
        FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                           craptab.nmsistem = "CRED"       AND
                           craptab.tptabela = "GENERI"     AND
                           craptab.cdempres = 0            AND
                           craptab.cdacesso = "HIPOTECAS"  AND
                           craptab.tpregist = 0            NO-LOCK NO-ERROR.

        IF   NOT AVAIL craptab   THEN
             DO:
                 ASSIGN aux_cdcritic = 0
                        aux_dscritic = "Falta descricao de categoria de " +
                                       "bens hipotecaveis.".
                 LEAVE.
             END.

        aux_lscathip = TRIM (craptab.dstextab).

        /*  Calculo da data do primeiro pagamento do emprestimo para esta
            empresa  */
        FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                           craptab.nmsistem = "CRED"       AND
                           craptab.tptabela = "GENERI"     AND
                           craptab.cdempres = 0            AND
                           craptab.cdacesso = "DIADOPAGTO" AND
                           craptab.tpregist = aux_cdempres NO-LOCK NO-ERROR.

        IF   NOT AVAIL craptab   THEN
             DO:                   
                 ASSIGN aux_cdcritic = 0
                        aux_dscritic = "Falta cadastro da empresa " + STRING(aux_cdempres) + ".".

                 LEAVE.
             END.

        ASSIGN aux_ddmesnov = INTEGER(SUBSTRING(craptab.dstextab,1,2)).

        IF   DAY(par_dtmvtolt) < aux_ddmesnov THEN
             aux_dtdpagto = DATE(IF   MONTH(par_dtmvtolt) = 12   THEN   1
                                 ELSE MONTH(par_dtmvtolt) + 1,
                            10,
                            IF   MONTH(par_dtmvtolt) = 12 THEN
                                 YEAR(par_dtmvtolt) + 1
                            ELSE YEAR(par_dtmvtolt)).
        ELSE
             aux_dtdpagto = DATE(IF MONTH(par_dtmvtolt) > 10 THEN
                               IF   MONTH(par_dtmvtolt) = 11  THEN 1
                                    ELSE 2
                                  ELSE MONTH(par_dtmvtolt) + 2,
                            10,
                            IF   MONTH(par_dtmvtolt) > 10 THEN
                                 YEAR(par_dtmvtolt) + 1
                            ELSE YEAR(par_dtmvtolt)).

        CREATE tt-dados-gerais.
        ASSIGN tt-dados-gerais.lscatbem = aux_lscatbem
               tt-dados-gerais.lscathip = aux_lscathip
               tt-dados-gerais.ddmesnov = aux_ddmesnov
               tt-dados-gerais.dtdpagto = aux_dtdpagto.

        LEAVE.

    END. /* Fim tratamento criticas */

    /* Propostas de emprestimo */
    FOR EACH crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                           crawepr.nrdconta = par_nrdconta   AND

                          ((par_nrctremp <> 0                AND
                           crawepr.nrctremp = par_nrctremp)  OR

                           (par_nrctremp = 0))
                           
                           NO-LOCK,

        FIRST crapprp WHERE crapprp.cdcooper = par_cdcooper      AND
                            crapprp.nrdconta = par_nrdconta      AND
                            crapprp.tpctrato = 90                AND
                            crapprp.nrctrato = crawepr.nrctremp
                            NO-LOCK

                            BY crawepr.dtaltpro DESC
                            BY crawepr.dtmvtolt DESC
                            
                            .

        IF   CAN-FIND(crapepr WHERE crapepr.cdcooper = par_cdcooper       AND
                                    crapepr.nrdconta = crawepr.nrdconta   AND
                                    crapepr.nrctremp = crawepr.nrctremp)  THEN
             NEXT.

        FIND craplcr WHERE craplcr.cdcooper = par_cdcooper AND
                           craplcr.cdlcremp = crawepr.cdlcremp
                           NO-LOCK NO-ERROR.


        /*** GRAVAMES - Verifica se permite excluir proposta **/
        ASSIGN aux_flexclui = TRUE.

        FIND FIRST crapbpr NO-LOCK
             WHERE crapbpr.cdcooper = crawepr.cdcooper
               AND crapbpr.nrdconta = crawepr.nrdconta
               AND crapbpr.tpctrpro = 90
               AND crapbpr.nrctrpro = crawepr.nrctremp
               AND crapbpr.flgalien = TRUE
               AND (crapbpr.dscatbem MATCHES "*AUTOMOVEL*" OR
                    crapbpr.dscatbem MATCHES "*MOTO*"      OR
                    crapbpr.dscatbem MATCHES "*CAMINHAO*"  OR 
                    crapbpr.dscatbem MATCHES "*OUTROS VEICULOS*" ) 
               AND (crapbpr.cdsitgrv = 1 OR /* Em Processamento */
                    crapbpr.cdsitgrv = 2)   /* Alienado */
            NO-ERROR.

        IF  AVAIL crapbpr THEN
            aux_flexclui = FALSE.
        /*** FIM - GRAVAMES - Verifica se permite excluir proposta **/

        /*** PORTABILIDADE - Verifica se eh uma proposta de portabilidade **/

        RUN possui_portabilidade (INPUT par_cdcooper,
                                  INPUT par_nrdconta,
                                  INPUT crawepr.nrctremp,
                                 OUTPUT aux_err_efet,
                                 OUTPUT aux_portabilidade,
                                 OUTPUT aux_cdcritic,
                                 OUTPUT aux_dscritic).

        IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            LEAVE.
        END.

        ASSIGN aux_portabilidade = RETURN-VALUE.

        /*** FIM - PORTABILIDADE - Verifica se eh uma proposta de portabilidade **/

        /* Verificar se Proposta devera passar por Analise Automatica */ 
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        RUN STORED-PROCEDURE pc_obrigacao_analise_automatic
         aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                              INPUT crapass.inpessoa, /* Tipo de Pessoa */
                                              INPUT crawepr.cdfinemp, /* Código da ~ Finalidade de crédito */
                                              INPUT crawepr.cdlcremp, /* Código da ~ linha de crédito */
                                              OUTPUT "",           /* Obrigaçao de análise automática (S/N) */
                                              OUTPUT 0,            /* Código da crítica */
                                              OUTPUT "").          /* Descrição da crítica */
    
        /* Fechar o procedimento para buscarmos o resultado */ 
        CLOSE STORED-PROC pc_obrigacao_analise_automatic
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_inobriga = pc_obrigacao_analise_automatic.pr_inobriga
                                                                 WHEN pc_obrigacao_analise_automatic.pr_inobriga <> ?
               aux_cdcritic = pc_obrigacao_analise_automatic.pr_cdcritic
                                                                 WHEN pc_obrigacao_analise_automatic.pr_cdcritic <> ?
               aux_dscritic = pc_obrigacao_analise_automatic.pr_dscritic
                                                                 WHEN pc_obrigacao_analise_automatic.pr_dscritic <> ?.

        IF aux_cdcritic > 0 OR 
           aux_dscritic <> '' THEN
            DO:
                CREATE tt-erro.
                ASSIGN tt-erro.cdcritic = aux_cdcritic
                       tt-erro.dscritic = aux_dscritic.
                RETURN "NOK".
            END.
        
        
        CREATE tt-proposta-epr. 

        ASSIGN tt-proposta-epr.dtmvtolt = crawepr.dtmvtolt
               tt-proposta-epr.nrctremp = crawepr.nrctremp
               tt-proposta-epr.vlemprst = crawepr.vlemprst
               tt-proposta-epr.vlpreemp = crawepr.vlpreemp
               tt-proposta-epr.vlprecar = crawepr.vlprecar
               tt-proposta-epr.qtpreemp = crawepr.qtpreemp
               tt-proposta-epr.qtpromis = crawepr.qtpromis
               tt-proposta-epr.cdlcremp = crawepr.cdlcremp
               tt-proposta-epr.cdfinemp = crawepr.cdfinemp
               tt-proposta-epr.cdoperad = crawepr.cdoperad
               tt-proposta-epr.flgimppr = crawepr.flgimppr
               tt-proposta-epr.flgimpnp = crawepr.flgimpnp
               tt-proposta-epr.cdorigem = crawepr.cdorigem
               tt-proposta-epr.dsctrliq = ""
               tt-proposta-epr.flgenvio = IF   crapprp.flgenvio  THEN
                                               "Sim"
                                          ELSE
                                               "Nao"
               tt-proposta-epr.nrdrecid = RECID(crawepr)
               tt-proposta-epr.tplcremp = (IF AVAIL craplcr THEN
                                                   craplcr.tpctrato
                                          ELSE 0)
               tt-proposta-epr.tpemprst = crawepr.tpemprst
               tt-proposta-epr.dsidenti = "*" WHEN crawepr.tpemprst = 1
               tt-proposta-epr.cdtpempr = "0,1,2"
               tt-proposta-epr.dstpempr = "Price TR,Price Pre-Fixado,Pos-Fixado"
               tt-proposta-epr.flexclui = aux_flexclui      
               tt-proposta-epr.portabil = aux_portabilidade
               tt-proposta-epr.inobriga = aux_inobriga
               tt-proposta-epr.insitapr = crawepr.insitapr
               tt-proposta-epr.err_efet = aux_err_efet	
               tt-proposta-epr.idcobope = crawepr.idcobope
               tt-proposta-epr.vlfinanc = 0
               tt-proposta-epr.vlrtotal = 0
               tt-proposta-epr.flintcdc = crapcop.flintcdc
               tt-proposta-epr.vlrtotal = 0
               /* PRJ 438 */
               tt-proposta-epr.insitest = crawepr.insitest.

               IF crawepr.idfiniof > 0 THEN
                  DO:
                    
                    /* Busca os bens em garantia */
                    ASSIGN aux_dscatbem = "".
                    FOR EACH crapbpr WHERE crapbpr.cdcooper = crawepr.cdcooper  AND
                                           crapbpr.nrdconta = crawepr.nrdconta  AND
                                           crapbpr.nrctrpro = crawepr.nrctremp  AND 
                                           crapbpr.tpctrpro = 90 NO-LOCK:
                        ASSIGN aux_dscatbem = aux_dscatbem + "|" + crapbpr.dscatbem.
                    END.
                    
                    RUN sistema/generico/procedures/b1wgen0097.p 
                           
                    PERSISTENT SET h-b1wgen0097.               
                    RUN consulta_tarifa_emprst IN h-b1wgen0097 (INPUT  crawepr.cdcooper,
                                                                INPUT  crawepr.cdlcremp,
                                                                INPUT  crawepr.vlemprst,
                                                                INPUT  crawepr.nrdconta,
                                                                INPUT  crawepr.nrctremp,
                                                                INPUT  aux_dscatbem,
                                                                OUTPUT aux_vlrtarif,
                                                                OUTPUT TABLE tt-erro).                                
                    DELETE PROCEDURE h-b1wgen0097.
                           
                    IF RETURN-VALUE = "NOK" THEN
                      RETURN "NOK".
                                 
                    
                                 
                                 
                    IF  AVAIL crapepr THEN
                      ASSIGN aux_dtlibera = crapepr.dtmvtolt.
                    ELSE
                      ASSIGN aux_dtlibera = crawepr.dtlibera. 
                   
                   
                   DO i = 1 TO 10:

                     IF  crawepr.nrctrliq[i] > 0  THEN
                       tt-proposta-epr.dsctrliq = tt-proposta-epr.dsctrliq +
                          (IF  tt-proposta-epr.dsctrliq = ""  THEN
                               TRIM(STRING(crawepr.nrctrliq[i],
                                           "z,zzz,zz9"))
                           ELSE
                               ", " +
                               TRIM(STRING(crawepr.nrctrliq[i],
                                           "z,zzz,zz9"))).

                   END. /** Fim do DO ... TO **/
                                        
                   ASSIGN aux_qtdias_carencia = 0.
                   IF crawepr.idcarenc > 0 THEN
                   DO:
                   
                     { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                     
                     /* Efetuar a chamada a rotina Oracle  */
                     RUN STORED-PROCEDURE pc_busca_qtd_dias_carencia
                         aux_handproc = PROC-HANDLE NO-ERROR (INPUT crawepr.idcarenc,
                                                             OUTPUT 0,   /* pr_qtddias */
                                                             OUTPUT 0,   /* pr_cdcritic */
                                                             OUTPUT ""). /* pr_dscritic */  

                     /* Fechar o procedimento para buscarmos o resultado */ 
                     CLOSE STORED-PROC pc_busca_qtd_dias_carencia
                            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                     { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                     ASSIGN aux_cdcritic = 0
                            aux_dscritic = ""
                            aux_cdcritic = INT(pc_busca_qtd_dias_carencia.pr_cdcritic) 
                                           WHEN pc_busca_qtd_dias_carencia.pr_cdcritic <> ?
                            aux_dscritic = pc_busca_qtd_dias_carencia.pr_dscritic
                                           WHEN pc_busca_qtd_dias_carencia.pr_dscritic <> ?
                            aux_qtdias_carencia = INT(pc_busca_qtd_dias_carencia.pr_qtddias) 
                                                  WHEN pc_busca_qtd_dias_carencia.pr_qtddias <> ?.
                    END.
                                        
               { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                    RUN STORED-PROCEDURE pc_calcula_iof_epr
                    aux_handproc = PROC-HANDLE NO-ERROR(INPUT crawepr.cdcooper
                                                       ,INPUT crawepr.nrdconta
                                                       ,INPUT crawepr.nrctremp
                                                       ,INPUT crawepr.dtmvtolt
                                                       ,INPUT crapass.inpessoa
                                                       ,INPUT crawepr.cdlcremp
                                                       ,INPUT crawepr.cdfinemp                                                       
                                                       ,INPUT crawepr.qtpreemp
                                                       ,INPUT crawepr.vlpreemp
                                                       ,INPUT crawepr.vlemprst
                                                       ,INPUT crawepr.dtdpagto
                                                       ,INPUT aux_dtlibera
                                                       ,INPUT crawepr.tpemprst
                                                       ,INPUT crawepr.dtcarenc /* Data de carencia */
                                                       ,INPUT aux_qtdias_carencia /* dias de carencia */
                                                       ,INPUT aux_dscatbem     /* Bens em garantia */
                                                       ,INPUT crawepr.idfiniof /* Indicador de financiamento de iof e tarifa */
                                                       ,INPUT tt-proposta-epr.dsctrliq /* pr_dsctrliq */
                                                       ,INPUT "N" /* Nao gravar valor nas parcelas */
                                                       ,OUTPUT 0 /* Valor calculado da Parcel */
                                                       ,OUTPUT 0 /* Valor calculado com o iof (principal + adicional) */
                                                       ,OUTPUT 0 /* Valor calculado do iof principal */
                                                       ,OUTPUT 0 /* Valor calculado do iof adicional */
                                                       ,OUTPUT 0 /* Imunidade tributária */
                                                       ,OUTPUT "").
            
                    CLOSE STORED-PROC pc_calcula_iof_epr 
                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                           
                    ASSIGN tt-proposta-epr.vliofepr = 0
                           tt-proposta-epr.vliofepr = pc_calcula_iof_epr.pr_valoriof 
                                                      WHEN pc_calcula_iof_epr.pr_valoriof <> ?.
               
                    ASSIGN tt-proposta-epr.vlfinanc = crawepr.vlemprst + tt-proposta-epr.vliofepr + aux_vlrtarif
                           tt-proposta-epr.vlrtotal = crawepr.vlemprst - tt-proposta-epr.vliofepr - aux_vlrtarif.

                  END.
               ELSE
                  ASSIGN tt-proposta-epr.vlfinanc = crawepr.vlemprst
                         tt-proposta-epr.vlrtotal = crawepr.vlemprst.
               

               /* faria integracao cdc */
               { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
               RUN STORED-PROCEDURE pc_verifica_contingencia_cdc
                 aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                                      OUTPUT 0,           /* Indicador de contingencia CDC */
                                                      OUTPUT 0,            /* Código da crítica */
                                                      OUTPUT "").          /* Descrição da crítica */
            
                /* Fechar o procedimento para buscarmos o resultado */ 
                CLOSE STORED-PROC pc_verifica_contingencia_cdc
                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                           
                ASSIGN aux_incdccon = pc_verifica_contingencia_cdc.pr_incdccon
                                                                         WHEN pc_verifica_contingencia_cdc.pr_incdccon <> ?
                       aux_cdcritic = pc_verifica_contingencia_cdc.pr_cdcritic
                                                                         WHEN pc_verifica_contingencia_cdc.pr_cdcritic <> ?
                       aux_dscritic = pc_verifica_contingencia_cdc.pr_dscritic
                                                                         WHEN pc_verifica_contingencia_cdc.pr_dscritic <> ?.
               
                 ASSIGN tt-proposta-epr.inintegra_cont = aux_incdccon.

               FIND crapfin where crapfin.cdcooper = par_cdcooper
                              AND crapfin.cdfinemp = crawepr.cdfinemp NO-LOCK NO-ERROR NO-WAIT.
               
               If AVAILABLE crapfin THEN
                 ASSIGN tt-proposta-epr.tpfinali = crapfin.tpfinali.
               ELSE
                 ASSIGN tt-proposta-epr.tpfinali = 0.

               
				CASE crawepr.insitest:
					WHEN 0 THEN ASSIGN tt-proposta-epr.dssitest = "Nao Enviada".
					WHEN 1 THEN ASSIGN tt-proposta-epr.dssitest = "Enviada p/ Analise Aut.".
					WHEN 2 THEN ASSIGN tt-proposta-epr.dssitest = "Enviada p/ Analise Man.".
					WHEN 3 THEN ASSIGN tt-proposta-epr.dssitest = "Analise Finalizada".
					WHEN 4 THEN ASSIGN tt-proposta-epr.dssitest = "Expirado".
          WHEN 5 THEN ASSIGN tt-proposta-epr.dssitest = "Expirada por decurso de prazo".
          WHEN 6 THEN ASSIGN tt-proposta-epr.dssitest = "Anulada". /*PRJ438 - Paulo Martins (Mouts)*/
					OTHERWISE tt-proposta-epr.dssitest = "-".
				END CASE.

				CASE crawepr.insitapr:
					WHEN 0 THEN ASSIGN tt-proposta-epr.dssitapr = "Nao Analisado".
					WHEN 1 THEN 
            DO:
              IF crawepr.cdopeapr = "MOTOR" THEN
                ASSIGN tt-proposta-epr.dssitapr = "Aprov. Autom.".
                    ELSE IF crawepr.cdopeapr = "ESTEIRA" THEN
                ASSIGN tt-proposta-epr.dssitapr = "Aprov. Manual".
                    ELSE   
                      ASSIGN tt-proposta-epr.dssitapr = "Aprovada".
            END.
					WHEN 2 THEN 
            DO:
              IF crawepr.cdopeapr = "MOTOR" THEN
                      ASSIGN tt-proposta-epr.dssitapr = "Rejeit. Autom.".
                    ELSE IF crawepr.cdopeapr = "ESTEIRA" THEN
                      ASSIGN tt-proposta-epr.dssitapr = "Rejeit. Manual".
              ELSE
                      ASSIGN tt-proposta-epr.dssitapr = "Rejeitada".
            END.
					WHEN 3 THEN ASSIGN tt-proposta-epr.dssitapr = "Com Restricao".
					WHEN 4 THEN ASSIGN tt-proposta-epr.dssitapr = "Refazer".          
                  WHEN 5 THEN ASSIGN tt-proposta-epr.dssitapr = "Derivar".
                  WHEN 6 THEN ASSIGN tt-proposta-epr.dssitapr = "Erro".
					OTHERWISE tt-proposta-epr.dssitapr = "-".
				END CASE.
    END.


    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

             IF  par_flgerlog  THEN
                 RUN proc_gerar_log (INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid).

             RETURN "NOK".

         END.

    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

    RETURN "OK".

END PROCEDURE.


/******************************************************************************
 Procedure para obter todos os dados da proposta de emprestimo
******************************************************************************/
PROCEDURE obtem-dados-proposta-emprestimo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inconfir AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    /* Temp-table com dados de consulta só */
    DEF OUTPUT PARAM TABLE FOR tt-dados-coope.
    DEF OUTPUT PARAM TABLE FOR tt-dados-assoc.
    DEF OUTPUT PARAM TABLE FOR tt-tipo-rendi.
    DEF OUTPUT PARAM TABLE FOR tt-itens-topico-rating.
    /* Temp-table com os dados a serem atualizados (se alteraçao ou inclusao) */
    DEF OUTPUT PARAM TABLE FOR tt-proposta-epr. /* campos novos**/
    DEF OUTPUT PARAM TABLE FOR tt-crapbem.
    DEF OUTPUT PARAM TABLE FOR tt-bens-alienacao.
    DEF OUTPUT PARAM TABLE FOR tt-rendimento.
    DEF OUTPUT PARAM TABLE FOR tt-faturam.
    DEF OUTPUT PARAM TABLE FOR tt-dados-analise.
    DEF OUTPUT PARAM TABLE FOR tt-interv-anuentes.
    DEF OUTPUT PARAM TABLE FOR tt-hipoteca.
    DEF OUTPUT PARAM TABLE FOR tt-dados-avais.
    DEF OUTPUT PARAM TABLE FOR tt-aval-crapbem.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.

    DEF VAR aux_stsnrcal AS LOGI                                    NO-UNDO.
    DEF VAR aux_flginter AS LOGI                                    NO-UNDO.
    DEF VAR aux_diasmini AS INTE                                    NO-UNDO.
    DEF VAR aux_inusatab AS INTE                                    NO-UNDO.
    DEF VAR aux_nrctremp AS INTE                                    NO-UNDO.
    DEF VAR aux_nralihip AS INTE                                    NO-UNDO.
    DEF VAR aux_lslibemp AS CHAR                                    NO-UNDO.
    DEF VAR aux_lssemseg AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdempres AS INTE                                    NO-UNDO.
    DEF VAR aux_inpessoa AS INTE                                    NO-UNDO.
    DEF VAR aux_cdagenci AS INTE                                    NO-UNDO.
    DEF VAR aux_vlminimo AS DECI                                    NO-UNDO.
    DEF VAR aux_vlemprst AS DECI                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_idseqbem AS INTE                                    NO-UNDO.
    DEF VAR aux_nrcpfcjg AS DECI                                    NO-UNDO. 
    DEF VAR aux_nrctacje AS INTE                                    NO-UNDO. 
    DEF VAR i            AS INTE                                    NO-UNDO.
    DEF VAR aux_dtlibera AS DATE                                    NO-UNDO.
    DEF VAR aux_cdfinemp LIKE crawepr.cdfinemp                      NO-UNDO.
    DEF VAR aux_tpemprst LIKE crawepr.tpemprst                      NO-UNDO.
    DEF VAR aux_nrctrliq LIKE crawepr.nrctrliq                      NO-UNDO.
	DEF VAR aux_flgcescr AS LOG INIT FALSE                          NO-UNDO.
    DEF VAR aux_fleprCDC AS LOG INIT FALSE                          NO-UNDO.

    DEF VAR h-b1wgen0001 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0043 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0058 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0097 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_nrdeanos AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdmeses AS INTE                                    NO-UNDO.
    DEF VAR aux_dsdidade AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR aux_vlrtarif AS DECI                                    NO-UNDO.
    DEF VAR aux_dscatbem AS CHAR                                    NO-UNDO.
    DEF VAR aux_concontr AS INTE                                    NO-UNDO.        
    DEF VAR aux_qtdias_carencia AS INTE                             NO-UNDO.
    DEF VAR aux_incdccon AS INTE                                    NO-UNDO.
    DEF VAR aux_endereco AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dados-coope.
    EMPTY TEMP-TABLE tt-dados-assoc.
    EMPTY TEMP-TABLE tt-proposta-epr.
    EMPTY TEMP-TABLE tt-bens-alienacao.
    EMPTY TEMP-TABLE tt-interv-anuentes.
    EMPTY TEMP-TABLE tt-hipoteca.
    EMPTY TEMP-TABLE tt-dados-avais.
    EMPTY TEMP-TABLE tt-aval-crapbem.
    EMPTY TEMP-TABLE bk-aval-crapbem.
    EMPTY TEMP-TABLE tt-msg-confirma.

    ASSIGN aux_cdcritic = 0
           aux_concontr = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter dados da proposta de emprestimo".

	/* Carregar flag de cadasatro de cessao de credito */
    IF par_nmdatela = "CRPS714" THEN
       ASSIGN aux_flgcescr = TRUE.

    IF par_nmdatela = "AUTOCDC" OR 
       par_cdoperad = "AUTOCDC" THEN
      ASSIGN aux_fleprCDC = TRUE.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
       IF  par_cddopcao = "I" THEN
           DO:
                /* rotina para buscar o crapttl.inhabmen */
                FIND FIRST crapttl WHERE crapttl.cdcooper = par_cdcooper   AND
                                         crapttl.nrdconta = par_nrdconta   AND
                                         crapttl.idseqttl = 1
                                         NO-LOCK NO-ERROR.
    
                IF  AVAIL crapttl THEN
                    DO:
                        /* validar revisao cadastral e idade minima apenas se nao for cessao de credito */
                        IF  NOT aux_flgcescr AND
                            /* Nao validar para CDC */ 
                            NOT aux_fleprCDC THEN
                            DO:
                        IF  NOT VALID-HANDLE(h-b1wgen0001) THEN
                            RUN sistema/generico/procedures/b1wgen0001.p 
                                PERSISTENT SET h-b1wgen0001.
                        
                        RUN ver_cadastro IN h-b1wgen0001 (INPUT par_cdcooper,
                                                          INPUT par_nrdconta,
                                                          INPUT par_cdagenci, 
                                                          INPUT par_nrdcaixa, 
                                                          INPUT par_dtmvtolt,
                                                          INPUT par_idorigem,
                                                         OUTPUT TABLE tt-erro).
    
                        DELETE PROCEDURE h-b1wgen0001.
                        
                        IF  RETURN-VALUE = "NOK"  THEN
                            RETURN "NOK".
    
                        IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
                            RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.

                        /*  Rotina que retorna a idade do cooperado */
                        RUN idade IN h-b1wgen9999(INPUT crapttl.dtnasttl,
                                                  INPUT par_dtmvtolt,
                                                  OUTPUT aux_nrdeanos,
                                                  OUTPUT aux_nrdmeses,
                                                  OUTPUT aux_dsdidade).

                        IF  VALID-HANDLE(h-b1wgen9999) THEN
                            DELETE PROCEDURE h-b1wgen9999.

                        IF  par_inconfir = 1     AND
                            aux_nrdeanos >= 16   AND 
                            aux_nrdeanos <  18   AND 
                            crapttl.inhabmen = 0 THEN 
                            DO:
                                CREATE tt-msg-confirma.                    
                                ASSIGN tt-msg-confirma.inconfir = par_inconfir + 1
                                       tt-msg-confirma.dsmensag = "Atencao! Cooperado menor de idade. Deseja continuar?".
            
                                RETURN "OK".
                            END.

                        IF  aux_nrdeanos < 16 THEN
                            DO:
                               ASSIGN aux_cdcritic = 0
                                      aux_dscritic = "Cooperado menor de idade, nao"
                                             +  " e possivel realizar a operacao.".
                                      LEAVE.
                            END.
                    END.
           END.
           END.

       FIND crapcop WHERE crapcop.cdcooper = par_cdcooper   NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapcop   THEN
            DO:
                aux_cdcritic = 794.
                LEAVE.
            END.

       FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                          crapass.nrdconta = par_nrdconta
                          NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapass   THEN
            DO:
                aux_cdcritic = 9.
                LEAVE.
            END.

       IF   crapass.inpessoa = 1   THEN
            DO:
                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper   AND
                                   crapttl.nrdconta = par_nrdconta   AND
                                   crapttl.idseqttl = 1
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAIL crapttl   THEN
                     DO:
                         aux_cdcritic = 821.
                         LEAVE.
                     END.

                ASSIGN aux_cdempres = crapttl.cdempres.

                FIND crapcje WHERE crapcje.cdcooper = par_cdcooper   AND
                                   crapcje.nrdconta = par_nrdconta   AND
                                   crapcje.idseqttl = 1
                                   NO-LOCK NO-ERROR.

                IF   AVAIL crapcje   THEN
                     ASSIGN aux_nrcpfcjg = crapcje.nrcpfcjg
                            aux_nrctacje = crapcje.nrctacje.

            END.
       ELSE
            DO:
                FIND crapjur WHERE crapjur.cdcooper = par_cdcooper   AND
                                   crapjur.nrdconta = par_nrdconta
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAIL crapjur   THEN
                     DO:
                         aux_cdcritic = 821.
                         LEAVE.
                     END.

                ASSIGN aux_cdempres = crapjur.cdempres.

            END.

       FIND crapemp WHERE crapemp.cdcooper = par_cdcooper   AND
                          crapemp.cdempres = aux_cdempres
                          NO-LOCK NO-ERROR.

       ASSIGN aux_cdagenci = crapass.cdagenci.

       DO aux_contador = 1 TO 2:

          FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                            craptab.nmsistem = "CRED"         AND
                            craptab.tptabela = "USUARI"       AND
                            craptab.cdempres = 11             AND
                            craptab.cdacesso = "PROPOSTEPR"   AND
                            craptab.tpregist = aux_cdagenci   NO-LOCK NO-ERROR.

          IF   NOT AVAILABLE craptab   THEN
               IF   aux_contador > 1   THEN
                    ASSIGN aux_vlemprst = 0.
               ELSE
                    DO:
                        aux_cdagenci = 0.
                        NEXT.
                    END.
          ELSE
               ASSIGN aux_vlemprst = DECIMAL(SUBSTR(craptab.dstextab,17,15))
                      aux_diasmini = INTEGER(SUBSTR(craptab.dstextab,36,03))
                      aux_flginter = LOGICAL(SUBSTR(craptab.dstextab,56,03)).
       END.

       /* Na inclusao nao existe crawepr ainda */
       IF   par_cddopcao <> "I"   THEN
            DO:
                FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                                   crawepr.nrdconta = par_nrdconta   AND
                                   crawepr.nrctremp = par_nrctremp
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAIL crawepr   THEN
                     DO:
                         aux_cdcritic = 356.
                         LEAVE.
                     END.

                /** Linha de credito **/
                FIND craplcr WHERE craplcr.cdcooper = par_cdcooper     AND
                                   craplcr.cdlcremp = crawepr.cdlcremp
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE craplcr  THEN
                    DO:
                        aux_cdcritic = 363.
                        LEAVE.
                    END.


                /*** GRAVAMES - Verifica se permite excluir proposta WEB **/
                IF  par_cddopcao = "E"
                AND par_idorigem = 5 THEN DO:
                    FIND FIRST crapbpr NO-LOCK
                         WHERE crapbpr.cdcooper = crawepr.cdcooper
                           AND crapbpr.nrdconta = crawepr.nrdconta
                           AND crapbpr.tpctrpro = 90
                           AND crapbpr.nrctrpro = crawepr.nrctremp
                           AND crapbpr.flgalien = TRUE
                           AND (crapbpr.dscatbem MATCHES "*AUTOMOVEL*" OR
                                crapbpr.dscatbem MATCHES "*MOTO*"      OR
                                crapbpr.dscatbem MATCHES "*CAMINHAO*"  OR 
                                crapbpr.dscatbem MATCHES "*OUTROS VEICULOS*" )                                 
                                
                           AND (crapbpr.cdsitgrv = 1 OR /* Em Processamento */
                                crapbpr.cdsitgrv = 2)   /* Alienado */
                        NO-ERROR.

                    IF  AVAIL crapbpr THEN DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = " Exclusao Nao Permitida: " +
                                           "Gravames em Processamento/Alienado".
                        LEAVE.
                    END.
                END.
                /*** FIM - GRAVAMES - Verifica se permite excluir proposta **/
            END.
       ELSE     /*  Inclusao */
            DO:
                /* Parametros de execucao do programa  */
                FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                                   craptab.nmsistem = "CRED"         AND
                                   craptab.tptabela = "CONFIG"       AND
                                   craptab.cdempres = par_cdcooper   AND
                                   craptab.cdacesso = "NUMCTREMPR"   AND
                                   craptab.tpregist = 0
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAIL craptab   THEN
                     DO:
                         aux_cdcritic = 652.
                         LEAVE.
                     END.

                ASSIGN aux_inusatab = INT(SUBSTRING(craptab.dstextab,01,1))
                       aux_nrctremp = INT(SUBSTRING(craptab.dstextab,03,8))
                       aux_nralihip = INT(SUBSTRING(craptab.dstextab,11,7)).

                /* Buscar lista de categorias dispensadas do seguro */
                FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                                   craptab.nmsistem = "CRED"         AND
                                   craptab.tptabela = "USUARI"       AND
                                   craptab.cdempres = 11             AND
                                   craptab.cdacesso = "DISPSEGURO"   AND
                                   craptab.tpregist = 001
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAILABLE craptab   THEN
                     aux_lssemseg = "".
                ELSE
                     aux_lssemseg = craptab.dstextab.

                /* Buscar lista  contas que podem fazer emprestimo antes do */
                /* prazo minimo */
                FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                                   craptab.nmsistem = "CRED"       AND
                                   craptab.tptabela = "USUARI"     AND
                                   craptab.cdempres = 11           AND
                                   craptab.cdacesso = "LIBPRAZEMP" AND
                                   craptab.tpregist = 001
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAIL craptab   THEN
                     aux_lslibemp = "".
                ELSE
                     aux_lslibemp = craptab.dstextab.

                /* validar tempo minimo de sociedade apenas se nao for cessao de credito */
                IF  NOT aux_flgcescr AND
                    /* Nao validar para CDC */ 
                    NOT aux_fleprCDC  THEN
                    DO:
                /* Associado com tempo de sociedade menor que o permitido */
                IF   (crapass.dtmvtolt + aux_diasmini) > par_dtmvtolt THEN
                      DO:
                          IF   NOT CAN-DO   (aux_lslibemp,
                                      STRING(crapass.nrdconta))  AND
                               NOT CAN-FIND (craptco WHERE
                                      craptco.cdcooper = par_cdcooper  AND
                                      craptco.nrdconta = par_nrdconta  AND
                                      craptco.tpctatrf <> 3) THEN
                               DO:
                                   aux_cdcritic = 674.
                                   LEAVE.
                               END.
                      END.
            END.
            END.

       /* Busca valor minimo */
       FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                          craptab.nmsistem = "CRED"         AND
                          craptab.tptabela = "USUARI"       AND
                          craptab.cdempres = 11             AND
                          craptab.cdacesso = "SEGPRESTAM"   AND
                          craptab.tpregist = 0              NO-LOCK NO-ERROR.

       IF  NOT AVAIL craptab THEN
           DO:
               ASSIGN aux_cdcritic = 0
                      aux_dscritic = "Falta parametro de seguro prestamista.".

               LEAVE.
           END.
       ELSE
           ASSIGN aux_vlminimo = DECIMAL(SUBSTRING(craptab.dstextab,1,12)).

       CREATE tt-dados-coope.
       ASSIGN tt-dados-coope.vlmaxleg = crapcop.vlmaxleg
              tt-dados-coope.vlmaxutl = crapcop.vlmaxutl
              tt-dados-coope.vlcnsscr = crapcop.vlcnsscr
              tt-dados-coope.vllimapv = crapcop.vllimapv
              tt-dados-coope.flgcmtlc = crapcop.flgcmtlc
              tt-dados-coope.vlminimo = aux_vlminimo
              tt-dados-coope.vlemprst = aux_vlemprst
              tt-dados-coope.inusatab = aux_inusatab
              tt-dados-coope.nrctremp = aux_nrctremp
              tt-dados-coope.nralihip = aux_nralihip
              tt-dados-coope.lssemseg = aux_lssemseg
              tt-dados-coope.flginter = aux_flginter
              tt-dados-coope.flintcdc = crapcop.flintcdc.

              
             /* faria integracao cdc */
             { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

             RUN STORED-PROCEDURE pc_verifica_contingencia_cdc
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                                     OUTPUT 0,           /* Indicador de contingencia CDC */
                                                     OUTPUT 0,            /* Código da crítica */
                                                     OUTPUT "").          /* Descrição da crítica */
            
             /* Fechar o procedimento para buscarmos o resultado */ 
             CLOSE STORED-PROC pc_verifica_contingencia_cdc
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

             { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                           
             ASSIGN aux_incdccon = pc_verifica_contingencia_cdc.pr_incdccon
                              WHEN pc_verifica_contingencia_cdc.pr_incdccon <> ?
                    aux_cdcritic = pc_verifica_contingencia_cdc.pr_cdcritic
                              WHEN pc_verifica_contingencia_cdc.pr_cdcritic <> ?
                    aux_dscritic = pc_verifica_contingencia_cdc.pr_dscritic
                              WHEN pc_verifica_contingencia_cdc.pr_dscritic <> ?.
               
             ASSIGN tt-dados-coope.inintegra_cont = aux_incdccon.

       CREATE tt-dados-assoc.
       ASSIGN tt-dados-assoc.inpessoa = crapass.inpessoa
              tt-dados-assoc.inmatric = crapass.inmatric
              tt-dados-assoc.cdagenci = crapass.cdagenci
              tt-dados-assoc.cdempres = aux_cdempres
              tt-dados-assoc.nrcpfcjg = aux_nrcpfcjg 
              tt-dados-assoc.nrctacje = aux_nrctacje
              tt-dados-assoc.flgpagto = (crapemp.flgpagto OR crapemp.flgpgtib) WHEN AVAIL crapemp.

       FIND crapope WHERE crapope.cdcooper = par_cdcooper   AND
                          crapope.cdoperad = par_cdoperad   NO-LOCK NO-ERROR.

       CREATE tt-proposta-epr.
       ASSIGN tt-proposta-epr.cdtpempr = "0,1,2"
              tt-proposta-epr.dstpempr = "Price TR,Price Pre-Fixado,Pos-Fixado".

       IF   par_cddopcao <> "I"   THEN /* Na inclusao nao existe crawepr */
            DO:
                FIND  crapepr WHERE crapepr.cdcooper = crawepr.cdcooper   AND
                      crapepr.nrdconta = crawepr.nrdconta   AND
                      crapepr.nrctremp = crawepr.nrctremp
                      NO-LOCK NO-ERROR.

                IF  AVAIL crapepr THEN
                  DO:
                      ASSIGN aux_dtlibera = crapepr.dtmvtolt
                             aux_vlrtarif = crapepr.vltarifa.
                  END.
                ELSE
                  DO:
                    ASSIGN aux_dtlibera = crawepr.dtlibera. 
                
                RUN sistema/generico/procedures/b1wgen0097.p 
                  PERSISTENT SET h-b1wgen0097.
                 
                RUN consulta_tarifa_emprst IN h-b1wgen0097 (INPUT  crawepr.cdcooper,
                               INPUT  crawepr.cdlcremp,
                               INPUT  crawepr.vlemprst,
                               INPUT  crawepr.nrdconta,
                               INPUT  crawepr.nrctremp,
                               INPUT  "",
                               OUTPUT aux_vlrtarif,
                               OUTPUT TABLE tt-erro).
				
                DELETE PROCEDURE h-b1wgen0097.

                IF  RETURN-VALUE = "NOK" THEN
                  RETURN "NOK".
                  END.

                ASSIGN tt-proposta-epr.dtmvtolt = crawepr.dtmvtolt
                       tt-proposta-epr.vlemprst = crawepr.vlemprst
                       tt-proposta-epr.nrctremp = crawepr.nrctremp
                       tt-proposta-epr.vlpreemp = crawepr.vlpreemp
                       tt-proposta-epr.qtpreemp = crawepr.qtpreemp
                       tt-proposta-epr.nivrisco = crawepr.dsnivris
					   tt-proposta-epr.nivriori = crawepr.dsnivori
                       tt-proposta-epr.nivcalcu = crawepr.dsnivcal
                       tt-proposta-epr.cdlcremp = crawepr.cdlcremp
                       tt-proposta-epr.cdfinemp = crawepr.cdfinemp
                       tt-proposta-epr.qtdialib = crawepr.qtdialib
                       tt-proposta-epr.flgimppr = crawepr.flgimppr
                       tt-proposta-epr.flgimpnp = crawepr.flgimpnp
                       tt-proposta-epr.flgpagto = crawepr.flgpagto
                       tt-proposta-epr.dtdpagto = crawepr.dtdpagto
                       tt-proposta-epr.dsctrliq = ""
                       tt-proposta-epr.qtpromis = crawepr.qtpromis
                       tt-proposta-epr.nmchefia = crawepr.nmchefia
                       tt-proposta-epr.dsobserv = crawepr.dsobserv
                       tt-proposta-epr.dsobscmt = crawepr.dsobscmt
                       tt-proposta-epr.idquapro = crawepr.idquapro
                       tt-proposta-epr.percetop = crawepr.percetop
                       tt-proposta-epr.dtvencto = crawepr.dtvencto
                       tt-proposta-epr.tpemprst = crawepr.tpemprst
                       tt-proposta-epr.nrseqrrq = crawepr.nrseqrrq
                       tt-proposta-epr.dtlibera = aux_dtlibera
                       tt-proposta-epr.inpessoa = crapass.inpessoa
					   tt-proposta-epr.idcarenc = crawepr.idcarenc
                       tt-proposta-epr.dtcarenc = crawepr.dtcarenc
                       tt-proposta-epr.insitest = crawepr.insitest
                       tt-proposta-epr.idcobope = crawepr.idcobope
                       tt-proposta-epr.vlrtarif = aux_vlrtarif
                       tt-proposta-epr.vliofepr = 0
					   tt-proposta-epr.idfiniof = crawepr.idfiniof
                       tt-proposta-epr.flintcdc = crapcop.flintcdc
                       tt-proposta-epr.vlprecar = crawepr.vlprecar.

                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                RUN STORED-PROCEDURE pc_verifica_contingencia_cdc
                  aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                                       OUTPUT 0,           /* Indicador de contingencia CDC */
                                                       OUTPUT 0,           /* Código da crítica */
                                                       OUTPUT "").         /* Descrição da crítica */
            
                /* Fechar o procedimento para buscarmos o resultado */ 
                CLOSE STORED-PROC pc_verifica_contingencia_cdc
                         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                             
                ASSIGN aux_incdccon = pc_verifica_contingencia_cdc.pr_incdccon
                                      WHEN pc_verifica_contingencia_cdc.pr_incdccon <> ?
                       aux_cdcritic = pc_verifica_contingencia_cdc.pr_cdcritic
                                      WHEN pc_verifica_contingencia_cdc.pr_cdcritic <> ?
                       aux_dscritic = pc_verifica_contingencia_cdc.pr_dscritic
                                      WHEN pc_verifica_contingencia_cdc.pr_dscritic <> ?.
               
                 ASSIGN tt-proposta-epr.inintegra_cont = aux_incdccon
                        tt-dados-coope.inintegra_cont = aux_incdccon.

                FIND crapfin where crapfin.cdcooper = par_cdcooper
                               AND crapfin.cdfinemp = crawepr.cdfinemp NO-LOCK NO-ERROR NO-WAIT.
               
                If AVAILABLE crapfin THEN
                  ASSIGN tt-proposta-epr.tpfinali = crapfin.tpfinali.
                ELSE
                  ASSIGN tt-proposta-epr.tpfinali = 0.



                       
				IF  AVAIL crapepr THEN
                  DO:
                    ASSIGN tt-proposta-epr.idfiniof = crapepr.idfiniof
                           tt-proposta-epr.vliofepr = crapepr.vliofepr
                           tt-proposta-epr.vlfinanc = crapepr.vlemprst
                           tt-proposta-epr.vlrtotal = crapepr.vlemprst.
                    /* Se financiou IOF */
                    IF crawepr.idfiniof > 0 THEN
                        DO:
                            /* Remover IOF e tarifa do valor total */
                            ASSIGN tt-proposta-epr.vlrtotal = tt-proposta-epr.vlrtotal
                                                            - tt-proposta-epr.vliofepr
                                                            - tt-proposta-epr.vlrtarif.
                  END.
                  END.
                  ELSE
                  DO:

                      /* Busca os bens em garantia */
                      ASSIGN aux_dscatbem = "".
                      FOR EACH crapbpr WHERE crapbpr.cdcooper = crawepr.cdcooper  AND
                                             crapbpr.nrdconta = crawepr.nrdconta  AND
                                             crapbpr.nrctrpro = crawepr.nrctremp  AND
                                             crapbpr.tpctrpro = 90 NO-LOCK:
                          ASSIGN aux_dscatbem = aux_dscatbem + "|" + crapbpr.dscatbem.
                  END.
                    
                      /* Calcular o IOF */
                     ASSIGN aux_qtdias_carencia = 0.
                     IF crawepr.idcarenc > 0 THEN
                     DO:
                     
                      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                       
                       /* Efetuar a chamada a rotina Oracle  */
                       RUN STORED-PROCEDURE pc_busca_qtd_dias_carencia
                           aux_handproc = PROC-HANDLE NO-ERROR (INPUT crawepr.idcarenc,
                                                               OUTPUT 0,   /* pr_qtddias */
                                                               OUTPUT 0,   /* pr_cdcritic */
                                                               OUTPUT ""). /* pr_dscritic */  

                       /* Fechar o procedimento para buscarmos o resultado */ 
                       CLOSE STORED-PROC pc_busca_qtd_dias_carencia
                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                       ASSIGN aux_cdcritic = 0
                              aux_dscritic = ""
                              aux_cdcritic = INT(pc_busca_qtd_dias_carencia.pr_cdcritic) 
                                             WHEN pc_busca_qtd_dias_carencia.pr_cdcritic <> ?
                              aux_dscritic = pc_busca_qtd_dias_carencia.pr_dscritic
                                             WHEN pc_busca_qtd_dias_carencia.pr_dscritic <> ?
                              aux_qtdias_carencia = INT(pc_busca_qtd_dias_carencia.pr_qtddias) 
                                                    WHEN pc_busca_qtd_dias_carencia.pr_qtddias <> ?.
                      END.
                      
                      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                      RUN STORED-PROCEDURE pc_calcula_iof_epr
                          aux_handproc = PROC-HANDLE NO-ERROR
                                           (INPUT crawepr.cdcooper
                                            ,INPUT crawepr.nrdconta
                                            ,INPUT crawepr.nrctremp
                                            ,INPUT crawepr.dtmvtolt
                                            ,INPUT crapass.inpessoa
                                            ,INPUT crawepr.cdlcremp
                                            ,INPUT crawepr.cdfinemp                                            
                                            ,INPUT crawepr.qtpreemp
                                            ,INPUT crawepr.vlpreemp
                                            ,INPUT crawepr.vlemprst
                                            ,INPUT crawepr.dtdpagto
                                            ,INPUT aux_dtlibera
                                            ,INPUT crawepr.tpemprst
                                            ,INPUT crawepr.dtcarenc
                                            ,INPUT aux_qtdias_carencia  /* dias de carencia */
                                            ,INPUT aux_dscatbem         /* Bens em garantia */
                                            ,INPUT crawepr.idfiniof     /* Indicador de financiamento de IOF e tarifa */
                                            ,INPUT tt-proposta-epr.dsctrliq /* pr_dsctrliq */
                                            ,INPUT "N" /* Nao gravar valor nas parcelas */
                                            ,OUTPUT 0 /* Valor calculado da Parcela */
                                            ,OUTPUT 0 /* Valor calculado com o iof (principal + adicional) */
                                            ,OUTPUT 0 /* Valor calculado do iof principal */
                                            ,OUTPUT 0 /* Valor calculado do iof adicional */
                                            ,OUTPUT 0 /* Imunidade tributária */
                                            ,OUTPUT "").

                      CLOSE STORED-PROC pc_calcula_iof_epr 
                            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                      ASSIGN tt-proposta-epr.vliofepr = 0
                             tt-proposta-epr.vliofepr = pc_calcula_iof_epr.pr_valoriof 
                                                        WHEN pc_calcula_iof_epr.pr_valoriof <> ?.
                    


                IF crawepr.idfiniof > 0 THEN
                  DO:
                           ASSIGN tt-proposta-epr.vlfinanc = crawepr.vlemprst + tt-proposta-epr.vliofepr + aux_vlrtarif
                                  tt-proposta-epr.vlrtotal = crawepr.vlemprst - tt-proposta-epr.vliofepr - aux_vlrtarif.
                  END.
                       ELSE
                       DO:
                           ASSIGN tt-proposta-epr.vlfinanc = crawepr.vlemprst
                                  tt-proposta-epr.vlrtotal = crawepr.vlemprst.
                  
                       END.

                  END.
                  
                CASE crawepr.idquapro:
                  WHEN 1 THEN ASSIGN tt-proposta-epr.dsquapro = "Operacao Normal".
                  WHEN 2 THEN ASSIGN tt-proposta-epr.dsquapro =
                                     "Renovacao Credito".
                  WHEN 3 THEN ASSIGN tt-proposta-epr.dsquapro = "Reneg. Credito".
                  WHEN 4 THEN ASSIGN tt-proposta-epr.dsquapro = "Compos. Divida".
				  WHEN 5 THEN ASSIGN tt-proposta-epr.dsquapro = "Cessao de Cartao".
                END CASE.

                DO i = 1 TO 10:

                   IF  crawepr.nrctrliq[i] > 0  THEN
                       DO:
                           aux_concontr = aux_concontr + 1.
                           tt-proposta-epr.dsctrliq = tt-proposta-epr.dsctrliq +
                               (IF  tt-proposta-epr.dsctrliq = ""  THEN
                                  TRIM(STRING(crawepr.nrctrliq[i],"z,zzz,zz9"))
                                ELSE
                                  ", " + TRIM(STRING(crawepr.nrctrliq[i],
                                         "z,zzz,zz9"))).
                       END.
                END. /** Fim do DO ... TO **/	
                  
                /* Trazer também o LIMITE/ADP */
                IF crawepr.nrliquid > 0 THEN
                DO:
                    IF aux_concontr > 0 THEN
                        DO:
                            tt-proposta-epr.dsctrliq = tt-proposta-epr.dsctrliq +
                                ", " +
                                TRIM(STRING(crawepr.nrliquid, "z,zzz,zz9")).
                        END.
                    ELSE
                        DO:
                            tt-proposta-epr.dsctrliq = tt-proposta-epr.dsctrliq +
                                TRIM(STRING(crawepr.nrliquid, "z,zzz,zz9")).
                        END.
                END.

                /** Finalidade do emprestimo **/
                FIND crapfin WHERE crapfin.cdcooper = par_cdcooper     AND
                                   crapfin.cdfinemp = crawepr.cdfinemp
                                   NO-LOCK NO-ERROR.

                ASSIGN tt-proposta-epr.tplcremp = craplcr.tpctrato
                       tt-proposta-epr.flgcrcta = craplcr.flgcrcta
                       tt-proposta-epr.dslcremp = craplcr.dslcremp
                       tt-proposta-epr.dsfinemp = IF  AVAILABLE crapfin  THEN
                                                      crapfin.dsfinemp
                                                  ELSE
                                                    "** Nao cadastrada **".
            END.
       ELSE     /* Inclusao */
            DO:
                /* Busca registro de Qtd de impressoes de NP */
                FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                                   craptab.nmsistem = "CRED"       AND
                                   craptab.tptabela = "USUARI"     AND
                                   craptab.cdempres = 11           AND
                                   craptab.cdacesso = "PROPOSTANP" AND
                                   craptab.tpregist = 0
                                   NO-LOCK NO-ERROR.

                ASSIGN tt-proposta-epr.flgimpnp = TRUE /* Nota promissoria */
                       tt-proposta-epr.flgimppr = TRUE /* Proposta */
                       tt-proposta-epr.idquapro = 1
                       tt-proposta-epr.dsquapro = "Operacao Normal"
                       tt-proposta-epr.flgpagto = tt-dados-assoc.flgpagto
                       tt-proposta-epr.tpemprst = IF par_idorigem = 1 THEN 0
                                                  ELSE 1
                       tt-proposta-epr.dtlibera = par_dtmvtolt
                       tt-proposta-epr.qtpromis = INTEGER(craptab.dstextab) WHEN AVAIL craptab
                       tt-proposta-epr.inpessoa = crapass.inpessoa
					   tt-proposta-epr.idfiniof = 1
                       tt-proposta-epr.vliofepr = 0.
            END.

       /* Para a exclusao, só as informacoes mais relevantes sao necessarias*/
       IF   CAN-DO("E",par_cddopcao)   THEN
            DO:
                ASSIGN aux_flgtrans = TRUE.
                LEAVE.
            END.

       /* A partir daqui só as opcoes de (C)onsulta, (Alteraçao) , (I)nclusao */

       RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT SET h-b1wgen0024.

       RUN bens-cadastro-proposta IN h-b1wgen0024 (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT par_cdoperad,
                                                   INPUT par_nmdatela,
                                                   INPUT par_idorigem,
                                                   INPUT par_dtmvtolt,
                                                   INPUT par_nrdconta,
                                                   INPUT 90, /* Emprestimo */
                                                   INPUT par_nrctremp,
                                                   INPUT par_cddopcao,
                                                   INPUT par_flgerlog,
                                                   OUTPUT TABLE tt-erro,
                                                   OUTPUT TABLE tt-crapbem).
       DELETE PROCEDURE h-b1wgen0024.

       IF   RETURN-VALUE <> "OK"   THEN
            RETURN "NOK".

       RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT SET h-b1wgen0024.

       RUN rendimentos-cadastro-proposta IN h-b1wgen0024
                                            (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_idorigem,
                                             INPUT par_dtmvtolt,
                                             INPUT par_nrdconta,
                                             INPUT 90, /*Empr.*/
                                             INPUT par_nrctremp,
                                             INPUT par_cddopcao,
                                             INPUT par_flgerlog,
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT TABLE tt-tipo-rendi,
                                             OUTPUT TABLE tt-rendimento,
                                             OUTPUT TABLE tt-faturam).
       DELETE PROCEDURE h-b1wgen0024.

       IF   RETURN-VALUE <> "OK" THEN
            RETURN "NOK".

       RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT SET h-b1wgen0024.

       RUN dados-analise-proposta IN h-b1wgen0024
                                     (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_idorigem,
                                      INPUT par_dtmvtolt,
                                      INPUT par_nrdconta,
                                      INPUT crapass.inpessoa,
                                      INPUT 90, /* Emprestimo */
                                      INPUT par_nrctremp,
                                      INPUT par_cddopcao,
                                      INPUT par_flgerlog,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-dados-analise,
                                      OUTPUT TABLE tt-itens-topico-rating).

       DELETE PROCEDURE h-b1wgen0024.

       IF   RETURN-VALUE <> "OK"   THEN
            RETURN "NOK".

       /* Estes dados nao existem na Inclusao ainda */
       /* Alteraçao ou Consulta */
       IF   par_cddopcao <> "I"   THEN
            DO:
                IF  craplcr.tpctrato = 2  THEN  /** ALIENACAO **/
                    DO:
                        i = 0.

                        /* Bens da alienaçao */
                        FOR EACH crapbpr
                           WHERE crapbpr.cdcooper = par_cdcooper
                             AND crapbpr.nrdconta = par_nrdconta
                             AND crapbpr.tpctrpro = 90
                             AND crapbpr.nrctrpro = crawepr.nrctremp
                             AND crapbpr.flgalien = TRUE         
                             NO-LOCK
                             BY RECID(crapbpr):

                            CREATE tt-bens-alienacao.
                            ASSIGN i = i + 1
                                   tt-bens-alienacao.lsbemfin =
                                              "( " + STRING(i,"z9") + "º Bem )"

                                   tt-bens-alienacao.dscatbem = crapbpr.dscatbem
                                   tt-bens-alienacao.dsbemfin = crapbpr.dsbemfin
                                   tt-bens-alienacao.dscorbem = crapbpr.dscorbem
                                   tt-bens-alienacao.dschassi = crapbpr.dschassi
                                   tt-bens-alienacao.nranobem = crapbpr.nranobem
                                   tt-bens-alienacao.nrmodbem = crapbpr.nrmodbem
                                   tt-bens-alienacao.nrdplaca =
								       IF (crapbpr.nrplnovo <> ?) and (trim(crapbpr.nrplnovo) <> "") THEN
								           crapbpr.nrplnovo 
					                   ELSE crapbpr.nrdplaca 
                                   tt-bens-alienacao.nrrenava = 
                                       IF crapbpr.nrrenovo > 0 THEN
                                           crapbpr.nrrenovo
                                       ELSE crapbpr.nrrenava
                                   tt-bens-alienacao.tpchassi = crapbpr.tpchassi
                                   tt-bens-alienacao.ufdplaca = crapbpr.ufdplaca
                                   tt-bens-alienacao.vlmerbem = crapbpr.vlmerbem
                                   tt-bens-alienacao.uflicenc = crapbpr.uflicenc
                                   tt-bens-alienacao.idseqbem = crapbpr.idseqbem
                                   tt-bens-alienacao.dstipbem = crapbpr.dstipbem
                                   tt-bens-alienacao.dsmarbem = crapbpr.dsmarbem
                                   tt-bens-alienacao.vlfipbem = crapbpr.vlfipbem
                                   tt-bens-alienacao.dstpcomb = crapbpr.dstpcomb                                   
                                   tt-bens-alienacao.idalibem = i
								   tt-bens-alienacao.nrnotanf = crapbpr.nrnotanf  /* PRJ 438 - Sprint 4 */
                                   tt-bens-alienacao.dsmarceq = crapbpr.dsmarceq. /* PRJ 438 - Sprint 4 */

                            IF  NOT tt-dados-coope.flginter  THEN
                                tt-bens-alienacao.nrcpfbem = crapass.nrcpfcgc.
                            ELSE
                                tt-bens-alienacao.nrcpfbem = crapbpr.nrcpfbem.

                            /** Verificar o tipo do CPF/CNPJ do bem **/
                            RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.

                            IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                                DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "Handle invalido para BO"
                                                          + " b1wgen9999.".
                                   LEAVE.
                                END.

                            RUN valida-cpf-cnpj IN h-b1wgen9999
                                      (INPUT tt-bens-alienacao.nrcpfbem,
                                      OUTPUT aux_stsnrcal,
                                      OUTPUT aux_inpessoa).

                            DELETE PROCEDURE h-b1wgen9999.

                            IF  aux_inpessoa = 1  THEN
                                ASSIGN tt-bens-alienacao.dscpfbem =
                                       STRING(STRING(tt-bens-alienacao.nrcpfbem,
                                         "99999999999"),"xxx.xxx.xxx-xx").
                            ELSE
                                ASSIGN tt-bens-alienacao.dscpfbem =
                                       STRING(STRING(tt-bens-alienacao.nrcpfbem,
                                         "99999999999999"),"xx.xxx.xxx/xxxx-xx").

                            /* Buscaremos a situacao do Gravames */   
                            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                     
                            /* Efetuar a chamada a rotina Oracle  */
                            RUN STORED-PROCEDURE pc_situac_gravame_bem
                                aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                                    ,INPUT par_nrdconta
                                                                    ,INPUT crawepr.nrctremp
                                                                    ,INPUT crapbpr.idseqbem
                                                                    ,OUTPUT ""   /* pr_dssituac */
                                                                    ,OUTPUT ""). /* pr_dscritic */  
                       
                            /* Fechar o procedimento para buscarmos o resultado */ 
                            CLOSE STORED-PROC pc_situac_gravame_bem
                                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                       
                            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                       
                            ASSIGN aux_dscritic = ""
                                   aux_dscritic = pc_situac_gravame_bem.pr_dscritic
                                                  WHEN pc_situac_gravame_bem.pr_dscritic <> ?
                                   tt-bens-alienacao.dssitgrv = pc_situac_gravame_bem.pr_dssituac.

                        END. /** Fim do  FOR EACH bens de alienaçao  **/

                        ASSIGN aux_contador = 0.

                        FOR EACH crapavt WHERE
                                 crapavt.cdcooper = par_cdcooper AND
                                 crapavt.nrdconta = par_nrdconta AND
                                 crapavt.nrctremp = par_nrctremp AND
                                 crapavt.tpctrato = 9            NO-LOCK:

                            FIND FIRST crapass WHERE
                                       crapass.cdcooper = par_cdcooper   AND
                                       crapass.nrcpfcgc = crapavt.nrcpfcgc AND
                                       crapass.dtdemiss = ? /* Chamado 304656 (Heitor - RKAM) */
                                       NO-LOCK NO-ERROR.

                            CREATE tt-interv-anuentes.
                            ASSIGN aux_contador = aux_contador + 1

                                   tt-interv-anuentes.nrdindic = aux_contador
                                   tt-interv-anuentes.nrctaava =
                                       IF  AVAIL crapass THEN
                                           crapass.nrdconta
                                       ELSE 0
                                   tt-interv-anuentes.nmdavali = crapavt.nmdavali
                                   tt-interv-anuentes.nrcpfcgc = crapavt.nrcpfcgc
                                   tt-interv-anuentes.tpdocava = crapavt.tpdocava
                                   tt-interv-anuentes.nrdocava = crapavt.nrdocava
                                   tt-interv-anuentes.cdnacion = crapavt.cdnacion
                                   tt-interv-anuentes.nmconjug = crapavt.nmconjug
                                   tt-interv-anuentes.nrcpfcjg = crapavt.nrcpfcjg
                                   tt-interv-anuentes.tpdoccjg = crapavt.tpdoccjg
                                   tt-interv-anuentes.nrdoccjg = crapavt.nrdoccjg
                                   tt-interv-anuentes.nrfonres = crapavt.nrfonres
                                   tt-interv-anuentes.dsdemail = crapavt.dsdemail
                                   tt-interv-anuentes.nmcidade = crapavt.nmcidade
                                   tt-interv-anuentes.cdufresd = crapavt.cdufresd
                                   tt-interv-anuentes.nrcepend = crapavt.nrcepend
                                   tt-interv-anuentes.dsendres[1] =
                                              crapavt.dsendres[1]
                                   tt-interv-anuentes.dsendres[2] =
                                              crapavt.dsendres[2]
                                   tt-interv-anuentes.nrendere = crapavt.nrendere
                                   tt-interv-anuentes.complend = crapavt.complend
                                   tt-interv-anuentes.nrcxapst = crapavt.nrcxapst
                                   tt-interv-anuentes.dsbarlog =
                                              crapavt.dsendres[2]
                                   tt-interv-anuentes.dsendlog =
                                              crapavt.dsendres[1]
                                   tt-interv-anuentes.inpessoa = crapavt.inpessoa
                                   tt-interv-anuentes.dtnascto = crapavt.dtnascto. /*PRJ438*/           


                            /* Buscar a Nacionalidade */
                            FOR FIRST crapnac FIELDS(dsnacion)
                                              WHERE crapnac.cdnacion = crapavt.cdnacion
                                                    NO-LOCK:

                                ASSIGN tt-interv-anuentes.dsnacion = crapnac.dsnacion.

                            END.

                        END. /** Fim do FOR EACH crapavt **/

                    END. /* Fim Alienaçao  */
                ELSE
                IF  craplcr.tpctrato = 3  THEN  /** HIPOTECA **/
                    DO:
                       i = 0.

                       FOR EACH crapbpr WHERE crapbpr.cdcooper = par_cdcooper
                                          AND crapbpr.nrdconta = par_nrdconta
                                          AND crapbpr.tpctrpro = 90
                                          AND crapbpr.nrctrpro = crawepr.nrctremp
                                          AND crapbpr.flgalien = TRUE   NO-LOCK:

                                           /*Utilizado para mostrar os casos anteriores ao PRJ438 - Paulo Martins*/
                                          IF crapbpr.nrcepend = 0 AND crapbpr.dscorbem <> ' ' THEN
                                            ASSIGN aux_endereco = crapbpr.dscorbem.
                                          ELSE
                                            ASSIGN aux_endereco = crapbpr.dsendere.

                           CREATE tt-hipoteca.
                           ASSIGN i = i + 1
                                  tt-hipoteca.lsbemfin =
                                               "( " + STRING(i,"z9") + "º Imovel )"
                                  tt-hipoteca.dscatbem = crapbpr.dscatbem
                                  tt-hipoteca.dsbemfin = crapbpr.dsbemfin
                                  tt-hipoteca.dscorbem = crapbpr.dscorbem
                                  tt-hipoteca.vlmerbem = crapbpr.vlmerbem
                                  tt-hipoteca.vlrdobem = crapbpr.vlrdobem
                                  tt-hipoteca.cdufende = crapbpr.cdufende 
                                  tt-hipoteca.dscompend = crapbpr.dscompend 
                                  tt-hipoteca.dsendere = aux_endereco   /*crapbpr.dsendere*/
                                  tt-hipoteca.nmbairro = crapbpr.nmbairro 
                                  tt-hipoteca.nmcidade = crapbpr.nmcidade 
                                  tt-hipoteca.nrcepend = crapbpr.nrcepend 
                                  tt-hipoteca.nrendere = crapbpr.nrendere 
                                  tt-hipoteca.dsclassi = crapbpr.dsclassi 
                                  tt-hipoteca.vlareuti = crapbpr.vlareuti 
                                  tt-hipoteca.vlaretot = crapbpr.vlaretot 
                                  tt-hipoteca.nrmatric = crapbpr.nrmatric
                                  tt-hipoteca.idseqhip = i
                                  tt-hipoteca.idseqbem = crapbpr.idseqbem. /*PRJ 438 BUG 13721 - Paulo Martins*/

                       END. /** Fim do DO ... TO **/

                    END. /* Fim Hipoteca */

                RUN sistema/generico/procedures/b1wgen9999.p
                    PERSISTENT SET h-b1wgen9999.

                IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Handle invalido para BO "
                                              + "b1wgen9999.".
                        LEAVE.
                     END.

                RUN lista_avalistas IN h-b1wgen9999
                                           (INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_nmdatela,
                                            INPUT par_idorigem,
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT 1, /** EMPRESTIMO **/
                                            INPUT crawepr.nrctremp,
                                            INPUT crawepr.nrctaav1,
                                            INPUT crawepr.nrctaav2,
                                           OUTPUT TABLE tt-dados-avais,
                                           OUTPUT TABLE tt-erro).

                DELETE PROCEDURE h-b1wgen9999.

                IF  RETURN-VALUE <> "OK"  THEN
                    RETURN "NOK".

                /* Alimentar os campos que estao na crawepr sobre avalistas */
                FOR EACH tt-dados-avais BREAK BY tt-dados-avais.idavalis:

                    IF  tt-dados-avais.idavalis = 1  THEN
                        ASSIGN tt-dados-avais.nmconjug = crawepr.nmcjgav1
                               tt-dados-avais.nrdoccjg = crawepr.dscfcav1.
                    ELSE
                        ASSIGN tt-dados-avais.nmconjug = crawepr.nmcjgav2
                               tt-dados-avais.nrdoccjg = crawepr.dscfcav2.

                END.

                /* Bens do primeiro aval cooperado */
                IF   crawepr.nrctaav1 <> 0   THEN
                     DO:
                         RUN sistema/generico/procedures/b1wgen0056.p
                                              PERSISTENT SET h-b1wgen0056.

                         RUN Busca-Dados IN h-b1wgen0056 (INPUT par_cdcooper,
                                                          INPUT par_cdagenci,
                                                          INPUT par_nrdcaixa,
                                                          INPUT par_cdoperad,
                                                          INPUT crawepr.nrctaav1,
                                                          INPUT par_idorigem,
                                                          INPUT par_nmdatela,
                                                          INPUT par_idseqttl,
                                                          INPUT par_flgerlog,
                                                          INPUT 0, /*Todos bens*/
                                                          INPUT "C",
                                                          INPUT ?,
                                                          OUTPUT aux_msgconta,
                                                          OUTPUT TABLE
                                                                 tt-aval-crapbem,
                                                          OUTPUT TABLE tt-erro).
                         DELETE PROCEDURE h-b1wgen0056.

                         IF   RETURN-VALUE <> "OK"   THEN
                              RETURN "NOK".
                     END.

                /* Bens do segundo aval cooperado  */
                IF   crawepr.nrctaav2 <> 0  THEN
                     DO:
                         RUN sistema/generico/procedures/b1wgen0056.p
                                              PERSISTENT SET h-b1wgen0056.

                         RUN Busca-Dados IN h-b1wgen0056 (
                                         INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT crawepr.nrctaav2,
                                         INPUT par_idorigem,
                                         INPUT par_nmdatela,
                                         INPUT par_idseqttl,
                                         INPUT par_flgerlog,
                                         INPUT 0, /* Todos os bens*/
                                         INPUT "C",
                                         INPUT ?,
                                         OUTPUT aux_msgconta,
                                         OUTPUT TABLE bk-aval-crapbem,
                                         OUTPUT TABLE tt-erro).

                         DELETE PROCEDURE h-b1wgen0056.

                         IF   RETURN-VALUE <> "OK"   THEN
                              RETURN "NOK".

                         /* Passar os registro para a temp-table do output */
                         FOR EACH bk-aval-crapbem NO-LOCK:

                             CREATE tt-aval-crapbem.
                             BUFFER-COPY bk-aval-crapbem TO tt-aval-crapbem.

                         END.

                     END.

                /* Se tem algum aval terceiro */
                IF   crawepr.nrctaav1 = 0   OR
                     crawepr.nrctaav2 = 0   THEN
                     DO:
                         ASSIGN aux_idseqbem = 0.
                         FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper
                                                AND
                                                crapavt.tpctrato = 1
                                                AND
                                                crapavt.nrdconta = par_nrdconta
                                                AND
                                                crapavt.nrctremp = crawepr.nrctremp
                                                NO-LOCK:

                            DO i = 1 TO 6:
                               IF   crapavt.dsrelbem[i] = ""   THEN
                                    NEXT.
                               CREATE tt-aval-crapbem.
                               ASSIGN
                                   aux_idseqbem             = aux_idseqbem + 1
                                   tt-aval-crapbem.nrcpfcgc = crapavt.nrcpfcgc
                                   tt-aval-crapbem.dsrelbem = crapavt.dsrelbem[i]
                                   tt-aval-crapbem.persemon = crapavt.persemon[i]
                                   tt-aval-crapbem.qtprebem = crapavt.qtprebem[i]
                                   tt-aval-crapbem.vlrdobem = crapavt.vlrdobem[i]
                                   tt-aval-crapbem.vlprebem = crapavt.vlprebem[i]
                                   tt-aval-crapbem.idseqbem = aux_idseqbem.

                            END.

                        END.

                     END.

            END. /* Fim Opcao diferente de Inclusao */

            /* Se for alterar ou incluir */
       IF CAN-DO ("A,I",par_cddopcao)   THEN
          DO:
             IF AVAIL tt-proposta-epr THEN
                ASSIGN aux_cdfinemp = tt-proposta-epr.cdfinemp
                       aux_tpemprst = tt-proposta-epr.tpemprst.

             /* Busca os dados da proposta a partir */
             RUN carrega_dados_proposta_finalidade (INPUT par_cdcooper,
                                                    INPUT par_cdagenci,
                                                    INPUT par_nrdcaixa,
                                                    INPUT par_cdoperad,
                                                    INPUT par_nmdatela,
                                                    INPUT par_idorigem,
                                                    INPUT par_dtmvtolt,
                                                    INPUT par_nrdconta,
                                                    INPUT aux_tpemprst,
                                                    INPUT aux_cdfinemp,
                                                    INPUT tt-proposta-epr.cdlcremp,
                                                    INPUT FALSE,
                                                    INPUT tt-proposta-epr.dsctrliq,
                                                   OUTPUT TABLE tt-erro,
                                                   OUTPUT TABLE tt-dados-proposta-fin).

             IF RETURN-VALUE <> "OK" THEN
                RETURN "NOK".

             FIND FIRST tt-dados-proposta-fin NO-LOCK NO-ERROR.
             /* Caso a Finalidade for Cessao de Credito */
             IF AVAIL tt-dados-proposta-fin AND tt-dados-proposta-fin.flgcescr THEN
                DO:
                    FIND FIRST tt-dados-analise NO-LOCK NO-ERROR.
                    IF AVAIL tt-dados-analise THEN
                       DO:
                          ASSIGN tt-dados-analise.nrinfcad = tt-dados-proposta-fin.nrinfcad
                                 tt-dados-analise.dsinfcad = tt-dados-proposta-fin.dsinfcad
                                 tt-dados-analise.nrgarope = tt-dados-proposta-fin.nrgarope
                                 tt-dados-analise.dsgarope = tt-dados-proposta-fin.dsgarope
                                 tt-dados-analise.nrperger = tt-dados-proposta-fin.nrperger
                                 tt-dados-analise.dsperger = tt-dados-proposta-fin.dsperger
                                 tt-dados-analise.nrliquid = tt-dados-proposta-fin.nrliquid
                                 tt-dados-analise.dsliquid = tt-dados-proposta-fin.dsliquid
                                 tt-dados-analise.nrpatlvr = tt-dados-proposta-fin.nrpatlvr
                                 tt-dados-analise.dspatlvr = tt-dados-proposta-fin.dspatlvr
                                 tt-proposta-epr.flgcescr  = TRUE.
                       END.
                END.

             RUN sistema/generico/procedures/b1wgen0043.p
                 PERSISTENT SET h-b1wgen0043.

             RUN obtem_emprestimo_risco IN h-b1wgen0043
                                        (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_nrdconta,
                                         INPUT par_idseqttl,
                                         INPUT par_idorigem,
                                         INPUT par_nmdatela,
                                         INPUT FALSE,
                                         INPUT aux_cdfinemp,
                                         INPUT tt-proposta-epr.cdlcremp,
                                         INPUT aux_nrctrliq,
                                         INPUT tt-proposta-epr.dsctrliq,
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT tt-proposta-epr.nivrisco).
             
             DELETE PROCEDURE h-b1wgen0043.

          END. /* END IF CAN-DO ("A,I",par_cddopcao) THEN */

       ASSIGN aux_flgtrans = TRUE.
       LEAVE.

    END. /* Fim do tratamento das criticas */

    IF   NOT aux_flgtrans  THEN
         DO:
             IF   aux_cdcritic = 0   AND
                  aux_dscritic = ""  THEN
                  ASSIGN aux_dscritic = "Operacao nao foi concluida.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    IF   par_flgerlog  THEN
         RUN proc_gerar_log (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "",
                             INPUT aux_dsorigem,
                             INPUT aux_dstransa,
                             INPUT TRUE,
                             INPUT par_idseqttl,
                             INPUT par_nmdatela,
                             INPUT par_nrdconta,
                            OUTPUT aux_nrdrowid).

    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Fazer as validacoes quando for alteracao do tipo 'Toda a Proposta de
 Emprestimo' e 'Somente o Valor da Proposta'.
******************************************************************************/
PROCEDURE valida-dados-gerais:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdageass AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtpreemp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsctrliq AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vlmaxutl AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlmaxleg AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlcnsscr AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inconfir AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpaltera AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgpagto AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagt2 AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_ddmesnov AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdfinemp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtdialib AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inmatric AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_tpemprst AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtlibera AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inconfi2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdmodali AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idcarenc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcarenc AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idfiniof AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idquapro AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    DEF OUTPUT PARAM TABLE FOR tt-grupo.
    DEF OUTPUT PARAM par_dsmesage AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_vlpreemp AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_dslcremp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dsfinemp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_tplcremp AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM aux_flgpagto AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM aux_dtdpagto AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM par_vlutiliz AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_nivrisco AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_vlprecar AS DECI                           NO-UNDO.

    DEF   VAR        aux_contador AS INTE                           NO-UNDO.
    DEF   VAR        aux_nrdodias AS INTE                           NO-UNDO.
    DEF   VAR        aux_dtmvtolt AS DATE                           NO-UNDO.
    DEF   VAR        aux_qtdiacar AS INTE                           NO-UNDO.
    DEF   VAR        aux_vlajuepr AS DECI                           NO-UNDO.
    DEF   VAR        aux_txdiaria AS DECI                           NO-UNDO.
    DEF   VAR        aux_txmensal AS DECI                           NO-UNDO.
    DEF   VAR        aux_permnovo AS LOGI                           NO-UNDO.
    DEF   VAR        aux_dsoperac AS CHAR                           NO-UNDO.
    DEF   VAR        aux_inlcrmcr AS CHAR                           NO-UNDO.
    DEF   VAR        aux_lslcremp AS CHAR                           NO-UNDO.
    DEF   VAR        aux_nrctrliq LIKE crawepr.nrctrliq             NO-UNDO.
    DEF   VAR        h-b1wgen0110 AS HANDLE                         NO-UNDO.
    DEF   VAR        h-b1wgen0188 AS HANDLE                         NO-UNDO.
    DEF   VAR        h-b1wgen0043 AS HANDLE                         NO-UNDO.
    DEF   VAR        h-b1wgen0097 AS HANDLE                         NO-UNDO.

    DEF   VAR        aux_flgativo AS INTEGER                        NO-UNDO.
    DEF   VAR        aux_contaliq AS INTEGER                        NO-UNDO.
    DEF   VAR        aux_inobriga AS CHAR                           NO-UNDO.
    DEF   VAR        aux_qtdias_carencia AS INTE                    NO-UNDO.
		
    DEF   VAR        aux_vlpreemp AS DECIMAL                        NO-UNDO.
    DEF   VAR        aux_vlemprst AS DECIMAL                        NO-UNDO.
    DEF   VAR        aux_vlrtarif AS DECIMAL                        NO-UNDO.
    DEF   VAR        aux_vlrdoiof AS DECIMAL                        NO-UNDO.
    DEF   VAR        aux_dscatbem AS CHAR                           NO-UNDO.
    DEF   VAR        aux_valida_adesao AS LOGICAL                   NO-UNDO.

    DEF   VAR        aux_flgcescr AS LOG INIT FALSE                 NO-UNDO.
    DEF   VAR        aux_fleprCDC AS LOG INIT FALSE                 NO-UNDO.
    DEF   VAR        aux_cdmodali AS INTEGER                        NO-UNDO.
    DEF   VAR        aux_flgconsignado_salario AS LOGI              NO-UNDO.
		
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgconsignado_salario = FALSE.

    /* Carregar flag de cessao de credito */
    IF par_nmdatela = "CRPS714" THEN
       ASSIGN aux_flgcescr = TRUE.

    IF par_nmdatela = "AUTOCDC" OR 
       par_cdoperad = "AUTOCDC" THEN
      ASSIGN aux_fleprCDC = TRUE.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-msg-confirma.
    EMPTY TEMP-TABLE tt-grupo.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapass THEN
       DO:
          ASSIGN aux_cdcritic = 9.

          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).

          RETURN "NOK".

       END.

    IF NOT VALID-HANDLE(h-b1wgen0110) THEN
       RUN sistema/generico/procedures/b1wgen0110.p 
           PERSISTENT SET h-b1wgen0110.
    
    /*Monta a mensagem da operacao para envio no e-mail*/
    IF par_cddopcao = "A" THEN
       ASSIGN aux_dsoperac = "Tentativa de alteracao da "                  +
                             "proposta de emprestimo/financiamento "       +
                             "na conta "                                   +
                             STRING(crapass.nrdconta,"zzzz,zzz,9")         +
                             " - CPF/CNPJ "                                +
                            (IF crapass.inpessoa = 1 THEN
                                STRING((STRING(crapass.nrcpfcgc,
                                        "99999999999")),"xxx.xxx.xxx-xx")
                             ELSE
                                STRING((STRING(crapass.nrcpfcgc,
                                        "99999999999999")),
                                        "xx.xxx.xxx/xxxx-xx")).
    ELSE
       ASSIGN aux_dsoperac = "Tentativa de inclusao de nova proposta "    +
                             "de emprestimo/financiamento na conta "      +
                             STRING(crapass.nrdconta,"zzzz,zzz,9")        +
                             " - CPF/CNPJ "                               +
                            (IF crapass.inpessoa = 1 THEN
                                STRING((STRING(crapass.nrcpfcgc,
                                        "99999999999")),"xxx.xxx.xxx-xx")
                             ELSE
                                STRING((STRING(crapass.nrcpfcgc,
                                        "99999999999999")),
                                        "xx.xxx.xxx/xxxx-xx")).

    /* Validar fraude apenas se nao for cessao de credito */
    IF  NOT aux_flgcescr AND
        /* Nao validar para CDC */ 
        NOT aux_fleprCDC THEN
      DO:
    /*Verifica se o associado esta no cadastro restritivo*/
    RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_dtmvtolt,
                                      INPUT par_idorigem,
                                      INPUT crapass.nrcpfcgc,
                                      INPUT crapass.nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT TRUE, /*bloqueia operacao*/
                                      INPUT (IF par_cddopcao = "A" THEN
                                                9 /*cdoperac*/
                                             ELSE
                                                12), /*cdoperac*/
                                      INPUT aux_dsoperac,
                                      OUTPUT TABLE tt-erro).

    IF VALID-HANDLE(h-b1wgen0110) THEN
       DELETE PROCEDURE(h-b1wgen0110).

    IF RETURN-VALUE <> "OK" THEN
       DO:
          IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
             DO:
                ASSIGN aux_dscritic = "Nao foi possivel verificar o " +
                                      "cadastro restritivo.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

             END.

          RETURN "NOK".

       END.
      END.
    
    /* Buscamos a modalidade da conta */    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
          
    RUN STORED-PROCEDURE pc_busca_modalidade_tipo aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT crapass.inpessoa 
                         ,INPUT crapass.cdtipcta
                         ,OUTPUT 0
                         ,OUTPUT ""
                         ,OUTPUT "").
                         

    CLOSE STORED-PROC pc_busca_modalidade_tipo aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dscritic = ""
           aux_cdmodali = 0
           aux_dscritic = pc_busca_modalidade_tipo.pr_dscritic 
                          WHEN pc_busca_modalidade_tipo.pr_dscritic <> ?
           aux_cdmodali = pc_busca_modalidade_tipo.pr_cdmodalidade_tipo 
                          WHEN pc_busca_modalidade_tipo.pr_cdmodalidade_tipo <> ?.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    IF aux_dscritic <> "" THEN
      DO:
        LEAVE.
      END.
      
    IF aux_cdmodali = 2 AND par_cdfinemp = 57 THEN
      DO:
        ASSIGN aux_flgconsignado_salario = TRUE.
      END.
    
    DO WHILE TRUE:

        IF  NOT CAN-DO("0,58,59", STRING(par_cdfinemp)) AND
            NOT CAN-DO("100,800,900,6901", STRING(par_cdlcremp)) AND /* CDC */
            NOT CAN-DO("2,4", STRING(par_idquapro)) AND
            aux_flgconsignado_salario = FALSE THEN /* Empréstimo consignado para contas salário */
            DO:
                aux_valida_adesao = TRUE.
                IF par_cddopcao = "A" THEN
                    DO:
                        FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                                           crawepr.nrdconta = par_nrdconta   AND
                                           crawepr.nrctremp = par_nrctremp
                                           NO-LOCK NO-ERROR.
                        
                        /* Se mudou finalidade de contrato  ... */
                        /* Verifica se valida */
                        IF  AVAIL crawepr   THEN
                            DO:
                                IF  CAN-DO("0,58,59", STRING(crawepr.cdfinemp)) OR 
                                    CAN-DO("100,800,900,6901", STRING(crawepr.cdlcremp)) OR /* CDC */
                                    CAN-DO("2,4", STRING(crawepr.idquapro)) THEN
                                    aux_valida_adesao = TRUE.
                                ELSE 
                                    aux_valida_adesao = FALSE.
                             END.
                        
                    END.
                IF  aux_valida_adesao = TRUE THEN
                    DO:
                        /* buscar quantidade maxima de digitos aceitos para o convenio */
                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
                        
                        RUN STORED-PROCEDURE pc_valida_adesao_produto
                            aux_handproc = PROC-HANDLE NO-ERROR
                                                    (INPUT par_cdcooper,
                                                     INPUT par_nrdconta,
                                                     INPUT 31,   /* Emprestimos */
                                                     OUTPUT 0,   /* pr_cdcritic */
                                                     OUTPUT ""). /* pr_dscritic */

                        CLOSE STORED-PROC pc_valida_adesao_produto
                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                        
                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                        
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = ""
                               aux_cdcritic = pc_valida_adesao_produto.pr_cdcritic                          
                                                  WHEN pc_valida_adesao_produto.pr_cdcritic <> ?
                               aux_dscritic = pc_valida_adesao_produto.pr_dscritic
                                                  WHEN pc_valida_adesao_produto.pr_dscritic <> ?.
                        
                        IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
                            DO:
                                IF aux_dscritic = "" THEN
                                   DO:
                                      FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                                                         NO-LOCK NO-ERROR.
                                      
                                      IF AVAIL crapcri THEN
                                         ASSIGN aux_dscritic = crapcri.dscritic.
                                      ELSE
                                         ASSIGN aux_dscritic =  "Nao foi possivel validar a adesao do produto.".
                                   END.
                                LEAVE.
                            END.
                    END.
            END.
        
        IF  NOT CAN-DO("0,", par_cdmodali) AND 
            NOT CAN-FIND(craplcr WHERE
                         craplcr.cdcooper = par_cdcooper AND
                         craplcr.cdlcremp = par_cdlcremp AND
						             craplcr.flgstlcr AND
                         craplcr.cdmodali = SUBSTRING(par_cdmodali,1,2) AND 
                         craplcr.cdsubmod = SUBSTRING(par_cdmodali,3,2)) THEN
            DO:
                ASSIGN aux_dscritic =
                       "Linha de credito nao permitida para esta modalidade.".
                LEAVE.
            END.        
                
		IF crapass.inpessoa = 1  THEN
		DO:

			IF CAN-FIND(craplcr WHERE
						 craplcr.cdcooper = par_cdcooper AND
						 craplcr.cdlcremp = par_cdlcremp AND
						 craplcr.cdmodali = "02" AND 
						 craplcr.cdsubmod = "15") THEN
			DO:	   
				ASSIGN aux_cdcritic = 0
					   aux_dscritic = "Capital de giro apenas permito para conta pessoa juridica.".

				LEAVE.
			END.

			IF CAN-FIND(craplcr WHERE
						 craplcr.cdcooper = par_cdcooper AND
						 craplcr.cdlcremp = par_cdlcremp AND
						 craplcr.cdmodali = "02" AND 
						 craplcr.cdsubmod = "16") THEN
			DO:	   
				ASSIGN aux_cdcritic = 0
					   aux_dscritic = "Capital de giro apenas permito para conta pessoa juridica.".

				LEAVE.
			END.

		END.	     
                

        IF   par_vlemprst = 0   THEN
             DO:
                 ASSIGN aux_dscritic =
                        "Valor do emprestimo deve ser informado.".
                 LEAVE.
             END.

        IF   par_dtdpagto = ?   THEN
             DO:
                 ASSIGN aux_dscritic = "Data do pagamento deve ser informada.".
                 LEAVE.
             END.
             
        ASSIGN aux_flgpagto = par_flgpagto
               aux_dtdpagto = par_dtdpagto.

        IF  par_flgpagto AND ( par_inmatric = 2  OR
                               CAN-FIND(craplcr WHERE
                                        craplcr.cdcooper = par_cdcooper AND
                                        craplcr.cdlcremp = par_cdlcremp AND
                                        craplcr.tpdescto = 2 NO-LOCK)) THEN
            ASSIGN aux_flgpagto = FALSE.

        IF  aux_flgpagto  THEN
            ASSIGN aux_dtdpagto = par_dtdpagt2.

		/* verificacao de linha de credito somente online P442 - Pré-Aprovado 
		   Leva em consideraçao a finalidade do financiamento */
		IF par_cdfinemp = 68 THEN
		  DO:
			IF (par_idorigem = 5 AND CAN-FIND(craplcr WHERE
											  craplcr.cdcooper = par_cdcooper AND
											  craplcr.cdlcremp = par_cdlcremp AND
											  craplcr.flprapol = 1 NO-LOCK)) THEN
			  DO:
				  ASSIGN aux_dscritic = "Linha de Credito exclusiva para contratacao Online".
				  LEAVE.
			  END.
		  END.
			
		/* Verificacao de linha de credito e finalidade somente OnLine - PRJ438*/		
		IF (par_idorigem = 5) THEN
			DO:
			
				{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                 /* Verifica se a linha esta cadastrada em algum subsegmento */
                 RUN STORED-PROCEDURE pc_verifica_linha_segmento
                 aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                     ,INPUT par_cdlcremp
                                                     ,INPUT par_cdfinemp
                                                     ,0
													 ,0
                                                     ,"").

                 CLOSE STORED-PROC pc_verifica_linha_segmento
                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                 { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                 ASSIGN aux_flgativo = 0
                        aux_cdcritic = 0
                        aux_dscritic = ""
                        aux_cdcritic = INT(pc_verifica_linha_segmento.pr_cdcritic) WHEN pc_verifica_linha_segmento.pr_cdcritic <> ?
                        aux_dscritic = pc_verifica_linha_segmento.pr_dscritic WHEN pc_verifica_linha_segmento.pr_dscritic <> ?
                        aux_flgativo = INT(pc_verifica_linha_segmento.pr_flgativo) WHEN pc_verifica_linha_segmento.pr_flgativo <> ?.
                                  
                  IF   aux_cdcritic > 0   OR
                       (aux_dscritic <> ? AND aux_dscritic <> "") THEN
                       DO:
                           LEAVE.
                       END.
                                
                  IF   aux_flgativo = 1  THEN
                       DO:
                           ASSIGN aux_dscritic = "Linha de Credito exclusiva para contratacao online.".
                           LEAVE.
						END.
			
			END.
			
        IF   par_inconfir = 1   THEN
             DO:
                 RUN verifica_valores_linha (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_idorigem,
                                             INPUT par_nrdconta,
                                             INPUT par_dtmvtolt,
                                             INPUT par_dtmvtopr,
                                             INPUT par_inproces,
                                             INPUT par_nrctremp,
                                             INPUT par_dsctrliq,
                                             INPUT par_cdlcremp,
                                             INPUT par_vlemprst,
                                             INPUT par_inconfir,
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT TABLE tt-msg-confirma).

                 IF   RETURN-VALUE <> "OK" THEN
                      RETURN "NOK".

                 IF   TEMP-TABLE tt-msg-confirma:HAS-RECORDS THEN
                      RETURN "OK".

                 ASSIGN par_inconfir = par_inconfir + 1.

             END.

        IF par_tpemprst = 1 THEN
            DO:

                RUN sistema/generico/procedures/b1wgen0084.p
                    PERSISTENT SET h-b1wgen0084.

                RUN valida_novo_calculo IN h-b1wgen0084
                    (INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_qtpreemp, /*par_qtparepr*/
                     INPUT par_cdlcremp,
                     INPUT par_flgpagto,
                     OUTPUT TABLE tt-erro).

                DELETE PROCEDURE h-b1wgen0084.

                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".
            END.
        ELSE IF par_tpemprst = 2 THEN
            DO:
                /* Trava para testes em producao 
                IF par_cdcooper <> 1 THEN
                   DO:
                      ASSIGN aux_dscritic = "Produto nao liberado.".
                      LEAVE.
                   END. */
				 
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                /* Efetuar a chamada a rotina Oracle  */
                RUN STORED-PROCEDURE pc_valida_dados_pos_fixado
                    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_cdlcremp,
                                                         INPUT par_vlemprst,
                                                         INPUT par_qtpreemp,
                                                         INPUT par_dtlibera,
                                                         INPUT par_dtdpagto,
                                                         INPUT par_dtcarenc,
                                                         INPUT (IF par_flgpagto THEN 1
                                                                ELSE 0),
                                                        OUTPUT 0,   /* pr_cdcritic */
                                                        OUTPUT ""). /* pr_dscritic */  

                /* Fechar o procedimento para buscarmos o resultado */ 
                CLOSE STORED-PROC pc_valida_dados_pos_fixado
                       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                ASSIGN aux_cdcritic = 0
                       aux_dscritic = ""
                       aux_cdcritic = INT(pc_valida_dados_pos_fixado.pr_cdcritic) 
                                      WHEN pc_valida_dados_pos_fixado.pr_cdcritic <> ?
                       aux_dscritic = pc_valida_dados_pos_fixado.pr_dscritic
                                      WHEN pc_valida_dados_pos_fixado.pr_dscritic <> ?.

                IF   aux_cdcritic <> 0    OR
                     aux_dscritic <> ""   THEN
                     LEAVE.
            END.

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        /* Efetuar a chamada a rotina Oracle */ 
        RUN STORED-PROCEDURE pc_obrigacao_analise_automatic
         aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                            INPUT crapass.inpessoa, /* Tipo de Pessoa */
                            INPUT par_cdfinemp, /* Código da Finalidade de crédito */
                                                                                  INPUT par_cdlcremp, /* Código da linha de crédito */
                                                                                 OUTPUT "",           /* Obrigaçao de análise automática (S/N) */
                                                                                 OUTPUT 0,            /* Código da crítica */
                                                                                 OUTPUT "").          /* Descrição da crítica */
    
        /* Fechar o procedimento para buscarmos o resultado */ 
        CLOSE STORED-PROC pc_obrigacao_analise_automatic
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }


        ASSIGN aux_inobriga = pc_obrigacao_analise_automatic.pr_inobriga
                                                                 WHEN pc_obrigacao_analise_automatic.pr_inobriga <> ?
                           aux_cdcritic = pc_obrigacao_analise_automatic.pr_cdcritic
                                                                 WHEN pc_obrigacao_analise_automatic.pr_cdcritic <> ?
                           aux_dscritic = pc_obrigacao_analise_automatic.pr_dscritic
                                                                 WHEN pc_obrigacao_analise_automatic.pr_dscritic <> ?.

                IF aux_cdcritic > 0 OR 
                   aux_dscritic <> '' THEN
                   DO:
                          CREATE tt-erro.
                          ASSIGN tt-erro.cdcritic = aux_cdcritic
                                         tt-erro.dscritic = aux_dscritic.

                          RETURN "NOK".

            END.

        RUN verifica-limites-excedidos (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT par_nmdatela,
                                        INPUT par_idorigem,
                                        INPUT par_nrdconta,
                                        INPUT par_vlemprst,
                                        INPUT par_vlmaxutl,
                                        INPUT par_vlmaxleg,
                                        INPUT par_vlcnsscr,
                                        INPUT par_idseqttl,
                                        INPUT par_dtmvtolt,
                                        INPUT par_dtmvtopr,
                                        INPUT par_dsctrliq,
                                        INPUT par_inconfir,
                                        INPUT par_inproces,
                                        INPUT par_inconfi2,
                                        INPUT aux_inobriga,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-msg-confirma,
                                        OUTPUT TABLE tt-grupo,
                                        OUTPUT par_dsmesage,
                                        OUTPUT par_vlutiliz).


        IF   RETURN-VALUE <> "OK"   THEN
             RETURN "NOK".

        FIND crapccp WHERE crapccp.cdcooper = par_cdcooper   AND
                           crapccp.cdlcremp = par_cdlcremp   AND
                           crapccp.nrparcel = par_qtpreemp
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapccp  THEN
             DO:
                 ASSIGN aux_cdcritic = 842.
                 LEAVE.
             END.

        IF   par_cdcooper = 2 AND
             par_cdageass = 5 AND
             CAN-DO ("700,701,702,703",STRING(par_cdlcremp))   THEN
             DO:
                 ASSIGN aux_dscritic =
                         "Linha de credito bloqueada. Migracao de PA.".
                 LEAVE.
             END.

/*
        /* Nao permitir utilizar linha 100, quando possuir acordo de estouro de conta ativo */
        IF   par_cdlcremp = 100  THEN
             DO:
                 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                 /* Verifica se ha contratos de acordo */
                 RUN STORED-PROCEDURE pc_verifica_acordo_ativo
                 aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                     ,INPUT par_nrdconta
                                                     ,INPUT par_nrdconta
                                                     ,INPUT 1
                                                     ,0
                                                     ,0
                                                     ,"").

                 CLOSE STORED-PROC pc_verifica_acordo_ativo
                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                 { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                 ASSIGN aux_flgativo = 0
                        aux_cdcritic = 0
                        aux_dscritic = ""
                        aux_cdcritic = INT(pc_verifica_acordo_ativo.pr_cdcritic) WHEN pc_verifica_acordo_ativo.pr_cdcritic <> ?
                        aux_dscritic = pc_verifica_acordo_ativo.pr_dscritic WHEN pc_verifica_acordo_ativo.pr_dscritic <> ?
                        aux_flgativo = INT(pc_verifica_acordo_ativo.pr_flgativo) WHEN pc_verifica_acordo_ativo.pr_flgativo <> ?.
                                  
                  IF   aux_cdcritic > 0   OR
                       (aux_dscritic <> ? AND aux_dscritic <> "") THEN
                       DO:
                           LEAVE.
                       END.
                                
                  IF   aux_flgativo = 1  THEN
                       DO:
                           ASSIGN aux_dscritic = "Operacao nao permitida, conta corrente esta em acordo.".
                           LEAVE.
             END.
             END.
             */

        FIND craplcr WHERE craplcr.cdcooper = par_cdcooper   AND
                           craplcr.cdlcremp = par_cdlcremp
                           NO-LOCK NO-ERROR.

        IF   AVAIL craplcr    THEN
             ASSIGN par_tplcremp = craplcr.tpctrato.

        /* Se inclusao , pegar data do sistema */
        IF   par_cddopcao = "I"   THEN
             DO:
                 ASSIGN aux_dtmvtolt = par_dtmvtolt.
             END.
        ELSE /* Senao pegar data do emprestimo */
             DO:
        ASSIGN aux_flgativo = 0.

				FIND crawepr WHERE crawepr.cdcooper = par_cdcooper
                       AND crawepr.nrdconta = par_nrdconta
                       AND crawepr.nrctremp = par_nrctremp NO-LOCK NO-ERROR.

        IF AVAILABLE crawepr   THEN
          DO:
                      ASSIGN aux_dtmvtolt = crawepr.dtmvtolt.
              
            IF UPPER(par_dsctrliq) <> UPPER("Sem liquidacoes")   THEN
					ASSIGN aux_contaliq = NUM-ENTRIES(par_dsctrliq).
				ELSE
          ASSIGN aux_contaliq = 0.               
        
          DO aux_contador = 1 TO aux_contaliq:

            IF NUM-ENTRIES(par_dsctrliq) > 0 THEN
              DO:

              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

              /* Verifica se ha contratos de acordo */
              RUN STORED-PROCEDURE pc_verifica_acordo_ativo
              aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                        ,INPUT par_nrdconta
                        ,INPUT INTEGER(ENTRY(aux_contador,par_dsctrliq))
						,INPUT 3
                        ,0
                        ,0
                        ,"").

              CLOSE STORED-PROC pc_verifica_acordo_ativo
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

              ASSIGN aux_cdcritic = 0
                  aux_dscritic = ""
                  aux_cdcritic = INT(pc_verifica_acordo_ativo.pr_cdcritic) WHEN pc_verifica_acordo_ativo.pr_cdcritic <> ?
                  aux_dscritic = pc_verifica_acordo_ativo.pr_dscritic WHEN pc_verifica_acordo_ativo.pr_dscritic <> ?
                  aux_flgativo = INT(pc_verifica_acordo_ativo.pr_flgativo) WHEN pc_verifica_acordo_ativo.pr_flgativo <> ?.
                              
              IF aux_cdcritic > 0 THEN
              DO:
                LEAVE.
             END.
              ELSE IF aux_dscritic <> ? AND aux_dscritic <> "" THEN
              DO:
                LEAVE.
              END.
                            
              IF aux_flgativo = 1 THEN
                DO:
				ASSIGN aux_dscritic = "Nao e possivel marcar o contrato " + ENTRY(aux_contador,par_dsctrliq) + " para liquidar, contrato esta em acordo.".	
                LEAVE.
                END.
              END.
                                  
          END. /* DO TO aux_contaliq */  
          END.
        
				IF aux_flgativo = 1 THEN
				  DO:
            LEAVE.
          END.

             END.
        
        IF par_tpemprst = 0 THEN
             DO:

                 /* validar finalidade de portabilidade(crapfin.tpfinali=2) para produto "PRICE TR" */
                 FIND crapfin WHERE 
                      crapfin.cdfinemp = par_cdfinemp AND
                      crapfin.tpfinali = 2 
                      NO-LOCK NO-ERROR.

                 IF AVAIL crapfin THEN
                 DO:
                     ASSIGN aux_dscritic = "Finalidade nao permitida para este produto".
                     LEAVE.
                 END.

                 RUN valida_inclusao_tr (INPUT par_cdcooper,
                                         INPUT par_cdlcremp,
                                         INPUT aux_dtmvtolt,
                                         INPUT par_qtpreemp,
                                         INPUT par_flgpagto,
                                         INPUT par_dtdpagto,
                                         INPUT par_cdfinemp,
                                         INPUT par_cdoperad,
                                        OUTPUT aux_cdcritic,
                                        OUTPUT aux_dscritic).

                 IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
                    LEAVE.

             END. /* END IF par_tpemprst = 0 THEN */

        
        /* Garantir que Microcredito seja efetuado somente pelo AyllosWeb */
        IF   par_idorigem = 1   THEN
             DO:
                 /* Checar se a proposta eh de Microcredito */
                 RUN verifica_microcredito (INPUT par_cdcooper,
                                            INPUT par_cdlcremp,
                                           OUTPUT aux_dscritic,
                                           OUTPUT aux_inlcrmcr).
                
                 IF   aux_dscritic <> ""  THEN
                      LEAVE.
                
                 /* Se for ayllos caracter e for linha microcredito, bloquear */
                 IF   aux_inlcrmcr = "S"   THEN
                      DO:
                          ASSIGN aux_dscritic = 
                                "Linha de credito e' de microcredito. " + 
                                "Deve ser feito via Ayllos Web.".
                          LEAVE.
                      END.
                 
             END.

        /* Guardar valor do emprestimo */
        ASSIGN aux_vlemprst = par_vlemprst.
        
        /* Calculo da Parcela e valor do emprestimo conforme seu tipo */
        CASE par_tpemprst:
            WHEN 0 THEN
                 DO:
                     /** Calculo da Prestacao - Somente 1 prestacao **/
                     IF   par_qtpreemp = 1   THEN
                          DO:
                              ASSIGN aux_contador = 1
                                     aux_nrdodias = par_dtdpagto - par_dtmvtolt
                                     par_vlpreemp = par_vlemprst.

                              DO WHILE aux_contador LE aux_nrdodias:

                                  ASSIGN par_vlpreemp = par_vlpreemp +
                                         TRUNC((par_vlpreemp *
                                                craplcr.txdiaria),2)
                                         aux_contador = aux_contador + 1.

                              END.

                              ASSIGN par_vlpreemp = ROUND(par_vlpreemp,0).

                          END.
                     ELSE
                          ASSIGN par_vlpreemp =
                                 ROUND (par_vlemprst * crapccp.incalpre,2).
                 END.
            OTHERWISE
                 /* Para PP e Pós */
                 DO:

                     /* Somente para Pós */
                     IF par_tpemprst = 2 THEN
                 DO:
                     { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                     /* Efetuar a chamada a rotina Oracle  */
                     RUN STORED-PROCEDURE pc_busca_qtd_dias_carencia
                         aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_idcarenc,
                                                             OUTPUT 0,   /* pr_qtddias */
                                                             OUTPUT 0,   /* pr_cdcritic */
                                                             OUTPUT ""). /* pr_dscritic */  

                     /* Fechar o procedimento para buscarmos o resultado */ 
                     CLOSE STORED-PROC pc_busca_qtd_dias_carencia
                            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                     { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                     ASSIGN aux_cdcritic = 0
                            aux_dscritic = ""
                            aux_cdcritic = INT(pc_busca_qtd_dias_carencia.pr_cdcritic) 
                                           WHEN pc_busca_qtd_dias_carencia.pr_cdcritic <> ?
                            aux_dscritic = pc_busca_qtd_dias_carencia.pr_dscritic
                                           WHEN pc_busca_qtd_dias_carencia.pr_dscritic <> ?
                            aux_qtdias_carencia = INT(pc_busca_qtd_dias_carencia.pr_qtddias) 
                                                  WHEN pc_busca_qtd_dias_carencia.pr_qtddias <> ?.
                     END.

                     /* Se financiar IOF, calcula esses valores e soma ao total emprestado, para enviar ao cálculo da parcela*/                             
                     ASSIGN aux_vlrtarif = 0
                            aux_vlrdoiof = 0 
                            aux_vlpreemp = 0.
                     
                     /* Calcular o IOF para retornar o valor do IOF e da prestação */
                        /* Busca os bens em garantia */
                        ASSIGN aux_dscatbem = "".
                        FOR EACH crapbpr WHERE crapbpr.cdcooper = par_cdcooper  AND
                                               crapbpr.nrdconta = par_nrdconta  AND
                                               crapbpr.nrctrpro = par_nrctremp  AND 
                                               crapbpr.tpctrpro = 90 NO-LOCK:
                          ASSIGN aux_dscatbem = aux_dscatbem + "|" + crapbpr.dscatbem.
                        END.
                            
                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                        RUN STORED-PROCEDURE pc_calcula_iof_epr
                        aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper
                                                           ,INPUT par_nrdconta
                                                           ,INPUT par_nrctremp
                                                           ,INPUT par_dtmvtolt
                                                           ,INPUT crapass.inpessoa
                                                           ,INPUT par_cdlcremp
                                                           ,INPUT par_cdfinemp
                                                           ,INPUT par_qtpreemp
                                                           ,INPUT par_vlpreemp
                                                           ,INPUT par_vlemprst
                                                           ,INPUT par_dtdpagto
                                                           ,INPUT par_dtmvtolt
                                                           ,INPUT par_tpemprst
                                                           ,INPUT par_dtcarenc /* Data carencia */
                                                           ,INPUT aux_qtdias_carencia /* dias de carencia */
                                                           ,INPUT aux_dscatbem     /* Bens em garantia */
                                                           ,INPUT par_idfiniof /* Indicador de financiamento de iof e tarifa */
                                                        ,INPUT par_dsctrliq /* pr_dsctrliq */
                                                           ,INPUT "N" /* Nao gravar valor nas parcelas */
                                                           ,OUTPUT 0 /* Valor calculado da Parcela */
                                                           ,OUTPUT 0 /* Valor calculado com o iof (principal + adicional) */
                                                           ,OUTPUT 0 /* Valor calculado do iof principal */
                                                           ,OUTPUT 0 /* Valor calculado do iof adicional */
                                                           ,OUTPUT 0 /* Imunidade tributária */
                                                           ,OUTPUT "").

                        CLOSE STORED-PROC pc_calcula_iof_epr 
                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                     /* Retornar valor da prestação */
                     ASSIGN aux_dscritic = ""
                            aux_dscritic = pc_calcula_iof_epr.pr_dscritic
                                           WHEN pc_calcula_iof_epr.pr_dscritic <> ?
                            par_vlpreemp = pc_calcula_iof_epr.pr_vlpreclc
                                           WHEN pc_calcula_iof_epr.pr_vlpreclc <> ?
                            aux_vlrdoiof = pc_calcula_iof_epr.pr_valoriof
                                           WHEN pc_calcula_iof_epr.pr_valoriof <> ?.

                     /* Se financia IOF + Tarifa */
                     IF par_idfiniof > 0 THEN DO:
               
                        RUN sistema/generico/procedures/b1wgen0097.p PERSISTENT SET h-b1wgen0097.               
                        RUN consulta_tarifa_emprst IN h-b1wgen0097 (INPUT  par_cdcooper,
                                                              INPUT par_cdlcremp,
                                                                    INPUT  par_vlemprst,
                                                                    INPUT  par_nrdconta,
                                                                    INPUT  par_nrctremp,
                                                                    INPUT  aux_dscatbem,
                                                                    OUTPUT aux_vlrtarif,
                                                                    OUTPUT TABLE tt-erro).                                
                        DELETE PROCEDURE h-b1wgen0097.
                        
                        IF RETURN-VALUE = "NOK" THEN
                           RETURN "NOK".

                        ASSIGN aux_vlemprst = aux_vlemprst + aux_vlrtarif + aux_vlrdoiof.

                     END.
                     
                   /*Retorna os valores de prestacao*/
                   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                   RUN STORED-PROCEDURE pc_retorna_val_parc_pos_fixado
                   aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper
                                                      ,INPUT par_dtmvtolt
                                                      ,INPUT par_cdlcremp
                                                      ,INPUT par_dtcarenc
                                                      ,INPUT aux_qtdias_carencia
                                                      ,INPUT par_dtdpagto
                                                      ,INPUT par_qtpreemp
                                                      ,INPUT aux_vlemprst
                                                      ,OUTPUT 0  /* Valor da prestacao carencia */
                                                      ,OUTPUT 0  /* Valor da prestacao emprestimo */
                                                      ,OUTPUT 0  /* Codigo da critica */
                                                      ,OUTPUT "" /* Descricao da critica */
                                                      ).

                  CLOSE STORED-PROC pc_retorna_val_parc_pos_fixado 
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                  /* Retornar valor da prestação */
                  ASSIGN aux_cdcritic = 0
                         aux_dscritic = ""
                         aux_cdcritic = INT(pc_retorna_val_parc_pos_fixado.pr_cdcritic) 
                                        WHEN pc_retorna_val_parc_pos_fixado.pr_cdcritic <> ?
                         aux_dscritic = pc_retorna_val_parc_pos_fixado.pr_dscritic
                                        WHEN pc_retorna_val_parc_pos_fixado.pr_dscritic <> ?
                         aux_vlpreemp = pc_retorna_val_parc_pos_fixado.pr_vlpreemp
                                        WHEN pc_retorna_val_parc_pos_fixado.pr_vlpreemp <> ?
                         par_vlprecar = ROUND(pc_retorna_val_parc_pos_fixado.pr_vlprecar,2)
                                        WHEN pc_retorna_val_parc_pos_fixado.pr_vlprecar <> ?.

                 END. /* par_tpemprst = 2 */
        END CASE.

        /* Para MicroCredito */
        IF craplcr.cdusolcr = 1 THEN
        DO:
              /* Para PF */
              IF (crapass.inpessoa = 1 AND craplcr.vlmaxass < aux_vlemprst)
              OR (crapass.inpessoa = 2 AND craplcr.vlmaxasj < aux_vlemprst) THEN
              DO:
                   ASSIGN aux_dscritic = 
                                "Valor da proposta excede o valor maximo por Cooperado para Microcredito.".
                          LEAVE.
              END.
        END.
        

        IF   par_tpaltera = 1   THEN
             DO:
                 RUN valida-dados-proposta-completa (INPUT par_cdcooper,
                                                     INPUT par_cdagenci,
                                                     INPUT par_nrdcaixa,
                                                     INPUT par_cdoperad,
                                                     INPUT par_nmdatela,
                                                     INPUT par_idorigem,
                                                     INPUT par_nrdconta,
                                                     INPUT par_idseqttl,
                                                     INPUT par_dtmvtolt,
                                                     INPUT par_dtmvtopr,
                                                     INPUT par_cddopcao,
                                                     INPUT par_nrctremp,
                                                     INPUT par_cdempres,
                                                     INPUT par_dtdpagto,
                                                     INPUT par_dtdpagt2,
                                                     INPUT par_flgpagto,
                                                     INPUT par_cdlcremp,
                                                     INPUT par_cdfinemp,
                                                     INPUT par_qtpreemp,
                                                     INPUT par_qtdialib,
                                                     INPUT par_ddmesnov,
                                                     INPUT par_tpemprst,
                                                     INPUT par_dtlibera,
                                                     OUTPUT TABLE tt-erro,
                                                     OUTPUT par_dslcremp,
                                                     OUTPUT par_dsfinemp).

                 IF   RETURN-VALUE <> "OK"   THEN
                      RETURN "NOK".

             END.
        
        FOR EACH crappre WHERE crappre.cdcooper = par_cdcooper NO-LOCK:
        
            IF par_cdfinemp     = crappre.cdfinemp AND 
               crapass.inpessoa = crappre.inpessoa THEN
               DO:
                   IF par_tpemprst = 0 OR 
                      par_tpemprst = 2 THEN
                      DO:
                          ASSIGN aux_dscritic = "Finalidade nao permitida".
                          LEAVE.
                      END.
                                   
                   IF NOT VALID-HANDLE(h-b1wgen0188) THEN
                      RUN sistema/generico/procedures/b1wgen0188.p
                          PERSISTENT SET h-b1wgen0188.

                   /* Valida os dados do credito pre-aprovado */
                   RUN valida_dados_contrato IN h-b1wgen0188 (INPUT par_cdcooper,
                                                               INPUT par_cdagenci,
                                                               INPUT par_nrdcaixa,
                                                               INPUT par_cdoperad,
                                                               INPUT par_nmdatela,
                                                               INPUT par_idorigem,
                                                               INPUT par_nrdconta,
                                                               INPUT par_idseqttl,
                                                               INPUT par_vlemprst,
                                                               INPUT DAY(par_dtdpagto),
                                                               INPUT par_nrcpfope,
                                                               INPUT par_nrctremp,
                                                               OUTPUT TABLE tt-erro).
                   
                   IF VALID-HANDLE(h-b1wgen0188) THEN
                      DELETE PROCEDURE(h-b1wgen0188).

                   IF RETURN-VALUE <> "OK" THEN
                      RETURN "NOK".

               END. /* END IF par_cdfinemp = crappre.cdfinemp */

        END. /* END FOR EACH crappre */

        /* Calculo do Risco do Emprestimo */
        IF NOT VALID-HANDLE(h-b1wgen0043) THEN
           RUN sistema/generico/procedures/b1wgen0043.p 
               PERSISTENT SET h-b1wgen0043.

        RUN obtem_emprestimo_risco IN h-b1wgen0043
                                (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_nrdconta,
                                 INPUT par_idseqttl,
                                 INPUT par_idorigem,
                                 INPUT par_nmdatela,
                                 INPUT par_flgerlog,
                                 INPUT par_cdfinemp,
                                 INPUT par_cdlcremp,
                                 INPUT aux_nrctrliq,
                                 INPUT par_dsctrliq,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT par_nivrisco).

        IF VALID-HANDLE(h-b1wgen0043) THEN
           DELETE PROCEDURE h-b1wgen0043.
           
        IF RETURN-VALUE <> "OK" THEN
           RETURN "NOK".

        LEAVE.

    END. /* Fim tratamento de criticas */

    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".

         END.

    RETURN "OK".

END PROCEDURE.


/**************************************************************************
 Trazer a qualificao da operacao.
 Na alteraçao e inclusao de proposta.
**************************************************************************/
PROCEDURE proc_qualif_operacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsctrliq AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
	DEF  INPUT PARAM par_dtmvtoan AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM par_idquapro AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dsquapro AS CHAR                           NO-UNDO.
    
    DEF VAR aux_idquapro          AS INTE                           NO-UNDO.
    DEF VAR aux_dsquapro          AS CHAR                           NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    ASSIGN par_dsctrliq = " " + par_dsctrliq.

    /* AWAE (GFT) - Chamada para nova funçao de qualificaçao da operacao em Oracle */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_proc_qualif_operacao
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                        ,INPUT par_nrdconta
                                        ,INPUT par_nrdcaixa
                                        ,INPUT par_cdoperad
                                        ,INPUT par_nmdatela
                                        ,INPUT par_idorigem
                                        ,INPUT par_nrdconta
                                        ,INPUT par_dsctrliq
                                        ,INPUT par_dtmvtolt
                                        ,INPUT par_dtmvtopr
                                        /* --------- OUT --------- */
                                        ,OUTPUT 0  /* pr_idquapro */
                                        ,OUTPUT ""  /* pr_dsquapro */
                                        ,OUTPUT 0  /* pr_cdcritic --> Codigo da critica */
                                        ,OUTPUT "" /* pr_dscritic --> Descriçao da critica */
                                        ).

    CLOSE STORED-PROC pc_proc_qualif_operacao
    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_idquapro = pc_proc_qualif_operacao.pr_idquapro
                             WHEN pc_proc_qualif_operacao.pr_idquapro <> ?
           aux_dsquapro = pc_proc_qualif_operacao.pr_dsquapro
                             WHEN pc_proc_qualif_operacao.pr_dsquapro <> ?
           aux_cdcritic = pc_proc_qualif_operacao.pr_cdcritic
                             WHEN pc_proc_qualif_operacao.pr_cdcritic <> ?
           aux_dscritic = pc_proc_qualif_operacao.pr_dscritic
                             WHEN pc_proc_qualif_operacao.pr_dscritic <> ?.

    /* Se ocorrer critica, abortar e gerar erro.*/
    IF aux_cdcritic <> 0   OR
       aux_dscritic <> ""  THEN
                    DO:
         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1,
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).

         RETURN "NOK".
                    END.                
	    ELSE 
			DO:
         ASSIGN par_idquapro = aux_idquapro
                par_dsquapro = aux_dsquapro.

    RETURN "OK".
       END.

END PROCEDURE.


/*****************************************************************************
 Verificar os valores maximos por linha de credito.
*****************************************************************************/
PROCEDURE verifica_valores_linha:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsctrliq AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_inconfir AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.


    DEF VAR          aux_totlinha AS DECI                           NO-UNDO.
    DEF VAR          aux_contaliq AS INTE                           NO-UNDO.
    DEF VAR          aux_despreza AS LOGI                           NO-UNDO.
    DEF VAR          aux_contador AS INTE                           NO-UNDO.
    DEF VAR      aux_valor_maximo AS DECI                           NO-UNDO.

    DEF VAR          par_vlsdeved AS DECI                           NO-UNDO.
    DEF VAR          par_vltotpre AS DECI                           NO-UNDO.
    DEF VAR          par_qtprecal AS INTE                           NO-UNDO.

    DEF BUFFER crabass FOR crapass.


    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-msg-confirma.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".


    DO WHILE TRUE:

       FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                          crapass.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapass   THEN
            DO:
                aux_cdcritic = 9.
                LEAVE.
            END.

       FIND craplcr WHERE craplcr.cdcooper = par_cdcooper   AND
                          craplcr.cdlcremp = par_cdlcremp   NO-LOCK NO-ERROR.

       IF   NOT AVAIL craplcr   THEN
            DO:
                aux_cdcritic = 363.
                LEAVE.
            END.

       EMPTY TEMP-TABLE tt-contas.

       FOR EACH crabass WHERE crabass.cdcooper = par_cdcooper      AND
                              crabass.nrcpfcgc = crapass.nrcpfcgc  NO-LOCK:

           CREATE tt-contas.
           ASSIGN tt-contas.nrdconta = crabass.nrdconta.

       END.

       /*---  Verificar Valor Maximo Linha p/associado ------*/
       IF  ((craplcr.vlmaxass > 0   AND   crapass.inpessoa = 1)   OR
            (craplcr.vlmaxasj > 0   AND   crapass.inpessoa <> 1)) THEN
           DO:
               ASSIGN aux_totlinha = 0.

               IF   Upper(par_dsctrliq) <> Upper("Sem liquidacoes")   THEN
                    ASSIGN aux_contaliq = NUM-ENTRIES(par_dsctrliq).
               ELSE
                    ASSIGN aux_contaliq = 0.

               FOR EACH tt-contas NO-LOCK,

                   EACH crapepr WHERE crapepr.cdcooper = par_cdcooper      AND
                                      crapepr.nrdconta = tt-contas.nrdconta AND
                                      crapepr.inliquid = 0                 AND
                                      crapepr.cdlcremp = craplcr.cdlcremp
                                      NO-LOCK:

                   ASSIGN aux_despreza = NO.

                   DO aux_contador = 1 TO aux_contaliq:

                      IF   crapepr.nrctremp =
                                INTEGER(ENTRY(aux_contador,par_dsctrliq)) THEN
                           DO:
                               ASSIGN aux_despreza = YES.
                               LEAVE.
                           END.
                    END.

                    IF   aux_despreza   THEN
                         NEXT.

                    RUN saldo-devedor-epr (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_nmdatela,
                                           INPUT par_idorigem,
                                           INPUT par_nrdconta,
                                           INPUT 1,
                                           INPUT par_dtmvtolt,
                                           INPUT par_dtmvtopr,
                                           INPUT crapepr.nrctremp,
                                           INPUT "",
                                           INPUT par_inproces,
                                           INPUT FALSE,
                                           OUTPUT par_vlsdeved,
                                           OUTPUT par_vltotpre,
                                           OUTPUT par_qtprecal,
                                           OUTPUT TABLE tt-erro).

                    IF   RETURN-VALUE <> "OK" THEN
                         NEXT.

                    IF   par_vlsdeved < 0   THEN
                         par_vlsdeved = 0.

                    ASSIGN aux_totlinha = aux_totlinha + par_vlsdeved.

               END. /* Fim tt-contas */

               IF   crapass.inpessoa = 1 THEN
                    ASSIGN aux_valor_maximo = craplcr.vlmaxass.
               ELSE
                    ASSIGN aux_valor_maximo = craplcr.vlmaxasj.

               /* Valor excedido */
               IF  (aux_totlinha + par_vlemprst) > aux_valor_maximo THEN
                   DO:
                      CREATE tt-msg-confirma.
                      ASSIGN tt-msg-confirma.inconfir = par_inconfir
                             tt-msg-confirma.dsmensag =

                       "Vlrs(Linha) Excedidos (Utiliz. " +

                       TRIM(STRING(aux_totlinha,"zzz,zzz,zz9.99")) +
                       " Excedido " + TRIM(STRING((aux_totlinha +

                       par_vlemprst - aux_valor_maximo),"zzz,zzz,zz9.99")) +
                       ")Confirma? ".

                   END.

           END.

       LEAVE.

    END. /* Fim tratamento criticas */

    IF   aux_cdcritic <> 0  OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.


/**************************************************************************
 Verificar e criar as mensagens alertando dos limites ultrapassados.
 Na alteraçao e inclusao da proposta.
**************************************************************************/
PROCEDURE verifica-limites-excedidos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlmaxutl AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlmaxleg AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlcnsscr AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsctrliq AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inconfir AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inconfi2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inconmot AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    DEF OUTPUT PARAM TABLE FOR tt-grupo.
    DEF OUTPUT PARAM par_dsmesage AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_vlutiliz AS DECI                           NO-UNDO.


    DEF VAR aux_dsdrisco AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdgrupo AS INTE                                    NO-UNDO.
    DEF VAR aux_gergrupo AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdrisgp AS CHAR                                    NO-UNDO.
    DEF VAR aux_pertengp AS LOGI                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-msg-confirma.
    EMPTY TEMP-TABLE tt-grupo.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF NOT VALID-HANDLE(h-b1wgen0138) THEN
       RUN sistema/generico/procedures/b1wgen0138.p
           PERSISTENT SET h-b1wgen0138.

    ASSIGN aux_pertengp =  DYNAMIC-FUNCTION("busca_grupo" IN h-b1wgen0138,
                                                          INPUT par_cdcooper,
                                                          INPUT par_nrdconta,
                                                         OUTPUT aux_nrdgrupo,
                                                         OUTPUT aux_gergrupo,
                                                         OUTPUT aux_dsdrisgp).

    IF par_inconfi2 = 30 AND aux_gergrupo <> "" THEN
        DO:
            CREATE tt-msg-confirma.

            ASSIGN tt-msg-confirma.inconfir = par_inconfi2 + 1
                   tt-msg-confirma.dsmensag = aux_gergrupo.

            IF VALID-HANDLE(h-b1wgen0138) THEN
               DELETE OBJECT h-b1wgen0138.

            RETURN "OK".

        END.

    IF aux_pertengp THEN
       DO:
          /* Procedure responsavel para calcular o risco e o
             endividamento do grupo */
           RUN calc_endivid_grupo IN h-b1wgen0138
                                 (INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_cdoperad,
                                  INPUT par_dtmvtolt,
                                  INPUT par_nmdatela,
                                  INPUT par_idorigem,
                                  INPUT aux_nrdgrupo,
                                  INPUT TRUE, /*Consulta por conta*/
                                 OUTPUT aux_dsdrisco,
                                 OUTPUT par_vlutiliz,
                                 OUTPUT TABLE tt-grupo,
                                 OUTPUT TABLE tt-erro).

           IF VALID-HANDLE(h-b1wgen0138) THEN
              DELETE OBJECT h-b1wgen0138.

           IF RETURN-VALUE <> "OK"   THEN
              RETURN "NOK".

           IF par_vlmaxutl > 0  THEN
              DO:
                /* Se valor utilizado excedido */
                  IF  par_inconfir = 2                               AND
                     (par_vlutiliz + par_vlemprst) > par_vlmaxutl   THEN
                      DO:
                         CREATE tt-msg-confirma.

                         ASSIGN tt-msg-confirma.inconfir = par_inconfir
                                tt-msg-confirma.dsmensag =
                              "Vlrs(Utl) Excedidos (Utiliz. "                 +
                              TRIM(STRING(par_vlutiliz,"zzz,zzz,zz9.99"))     +
                              " Excedido " + TRIM(STRING((par_vlutiliz        +
                              par_vlemprst - par_vlmaxutl),"zzz,zzz,zz9.99")) +
                              ")Confirma? ".

                             RETURN "OK".

                      END.

                  /* Se valor legal excedido */
                  IF par_inconfir = 3 AND
                    (par_vlutiliz + par_vlemprst) > par_vlmaxleg THEN
                     DO:
                        CREATE tt-msg-confirma.

                        ASSIGN tt-msg-confirma.inconfir = par_inconfir
                               tt-msg-confirma.dsmensag =
                                              "Vlr(Legal) Excedido " +
                                              "(Utiliz. "            +
                                              TRIM(STRING(par_vlutiliz,
                                              "zzz,zzz,zz9.99"))  +
                                              " Excedido "       +
                                              TRIM(STRING((par_vlutiliz +
                                              par_vlemprst - par_vlmaxleg),
                                              "zzz,zzz,zz9.99")) + ") ".

                        ASSIGN aux_cdcritic = 79.

                     END.

              END.

       END.
    ELSE /*nao e do grupo*/
        DO:
            IF VALID-HANDLE(h-b1wgen0138) THEN
               DELETE OBJECT(h-b1wgen0138).

            RUN sistema/generico/procedures/b1wgen9999.p
                PERSISTENT SET h-b1wgen9999.

            RUN saldo_utiliza IN h-b1wgen9999 (INPUT  par_cdcooper,
                                               INPUT  par_cdagenci,
                                               INPUT  par_nrdcaixa,
                                               INPUT  par_cdoperad,
                                               INPUT  par_nmdatela,
                                               INPUT  par_idorigem,
                                               INPUT  par_nrdconta,
                                               INPUT  par_idseqttl,
                                               INPUT  par_dtmvtolt,
                                               INPUT  par_dtmvtopr,
                                               INPUT  par_dsctrliq,
                                               INPUT  par_inproces,
                                               INPUT  FALSE, /*Consulta por cpf*/
                                               OUTPUT par_vlutiliz,
                                               OUTPUT TABLE tt-erro).
             IF VALID-HANDLE(h-b1wgen9999) THEN
                DELETE PROCEDURE h-b1wgen9999.

                IF   RETURN-VALUE <> "OK"   THEN
                     RETURN "NOK".

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               IF par_vlmaxutl > 0  THEN
                  DO:
                    /* Se valor utilizado excedido */
                      IF  par_inconfir = 2                               AND
                         (par_vlutiliz + par_vlemprst) > par_vlmaxutl   THEN
                          DO:
                              CREATE tt-msg-confirma.
                              ASSIGN tt-msg-confirma.inconfir = par_inconfir
                                     tt-msg-confirma.dsmensag =
                                   "Vlrs(Utl) Excedidos (Utiliz. "                +
                                   TRIM(STRING(par_vlutiliz,"zzz,zzz,zz9.99")) +
                                   " Excedido " + TRIM(STRING((par_vlutiliz      +
                                   par_vlemprst - par_vlmaxutl),"zzz,zzz,zz9.99")) +
                                   ")Confirma? ".

                              RETURN "OK".

                          END.

                      /* Se valor legal excedido */
                      IF (par_vlutiliz + par_vlemprst) > par_vlmaxleg THEN
                         DO:
                             ASSIGN aux_dscritic = 
                                            "Vlr(Legal) Excedido " +
                                            "(Utiliz. "            +
                                            TRIM(STRING(par_vlutiliz,
                                                        "zzz,zzz,zz9.99")) +
                                            " Excedido "           +
                                            TRIM(STRING((par_vlutiliz + 
                                                         par_vlemprst -
                                                         par_vlmaxleg),
                                                 "zzz,zzz,zz9.99")) + ") ".
                                
                             LEAVE.
                         END.
                  END.

               /* Mostrar alerta de consulta somente quando operacao nao passara */
               /* por analise automatica da Esteira (Motor de Credito)  */
               IF (par_vlutiliz + par_vlemprst) > par_vlcnsscr AND par_inconmot = "N" THEN
                  DO:
                      par_dsmesage = "Sera necessaria nova consulta ao SCR.".
                  END.

                LEAVE.

            END. /* Tratamento de criticas */

        END.

    IF aux_cdcritic <> 0    OR
       aux_dscritic <> ""   THEN
       DO:
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".

       END.

    RETURN "OK".

END PROCEDURE.


/**************************************************************************
 Trazer um determinado avalista (cooperado ou terceiro) e pesquisar
 os contratos onde ele já é aval.
**************************************************************************/
PROCEDURE verifica-traz-avalista:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctaava AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dados-avais.
    DEF OUTPUT PARAM TABLE FOR tt-crapbem.
    DEF OUTPUT PARAM TABLE FOR tt-fiador.
    DEF OUTPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.


    DEF VAR aux_avljaacu         AS LOGI                            NO-UNDO.
    DEF VAR aux_qtctaavl         AS INTE                            NO-UNDO.
    DEF VAR par_vlsdeved         AS DECI                            NO-UNDO.
    DEF VAR par_vltotpre         AS DECI                            NO-UNDO.
    DEF VAR par_qtprecal         AS INTE                            NO-UNDO.
    DEF VAR i                    AS INTE                            NO-UNDO.
    DEF VAR aux_dsrelbem         AS CHAR                            NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dados-avais.
    EMPTY TEMP-TABLE tt-crapbem.
    EMPTY TEMP-TABLE tt-fiador.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".


    DO WHILE TRUE:

        IF   par_nrctaava  = 0    AND
             par_nrcpfcgc <> 0   THEN
             DO:
                 FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper  AND
                                          crapass.nrcpfcgc = par_nrcpfcgc
                                          NO-LOCK NO-ERROR.

                 IF   AVAIL crapass   THEN /* CPF de associado */
                      DO:
                          /* verificar se a conta esta demitida 
                            caso sim, deve verificar se esta demitida pois foi
                            migrada */
                          IF crapass.dtdemiss <> ? THEN
                          DO:
                              FIND FIRST craptco 
                                  WHERE craptco.cdcopant = crapass.cdcooper
                                    AND craptco.nrctaant = crapass.nrdconta
                                  NO-LOCK NO-ERROR.
                              /* caso for uma conta migrada não deve 
                                 apresentar critica*/
                              IF AVAIL craptco   THEN 
                                LEAVE.
                          END.
                          /* caso não for uma conta demitida, ou 
                             esta demitida porém não foi migrada deve 
                             gerar a critica */
                          aux_cdcritic = 806.
                          LEAVE.
                      END.
             END.

        LEAVE.

    END.

    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    /* Contratos onde é avalista */
    FOR EACH crapavl WHERE crapavl.cdcooper = par_cdcooper    AND
                           crapavl.nrdconta = par_nrctaava    AND
                           crapavl.tpctrato = 1               NO-LOCK
                           BREAK BY crapavl.nrctaavd:

        IF   FIRST-OF(crapavl.nrctaavd)   THEN
             ASSIGN aux_avljaacu = NO.

        FIND crapepr WHERE crapepr.cdcooper = par_cdcooper       AND
                           crapepr.nrdconta = crapavl.nrctaavd   AND
                           crapepr.nrctremp = crapavl.nrctravd
                           USE-INDEX crapepr2 NO-LOCK NO-ERROR.

        IF   AVAIL crapepr    THEN
             DO:
                 IF   crapepr.inliquid = 0   AND
                      NOT aux_avljaacu       THEN
                      ASSIGN aux_qtctaavl = aux_qtctaavl + 1
                             aux_avljaacu = YES.

             END.

    END.

    /* Se for avalista de pelo menos 3 contratos */
    IF   aux_qtctaavl >= 3   THEN
         DO:
             FIND crapass WHERE crapass.cdcooper = par_cdcooper  AND
                                crapass.nrdconta = par_nrctaava
                                NO-LOCK NO-ERROR.

             IF   AVAIL crapass   THEN
                  ASSIGN par_nmprimtl = crapass.nmprimtl.

             FOR EACH crapavl WHERE crapavl.cdcooper = par_cdcooper  AND
                                    crapavl.nrdconta = par_nrctaava  AND
                                    crapavl.tpctrato = 1             NO-LOCK:

                 FIND crapepr WHERE crapepr.cdcooper = par_cdcooper       AND
                                    crapepr.nrdconta = crapavl.nrctaavd   AND
                                    crapepr.nrctremp = crapavl.nrctravd
                                    USE-INDEX crapepr2 NO-LOCK NO-ERROR.

                 IF    NOT AVAIL crapepr   THEN
                       NEXT.

                 IF    crapepr.inliquid <> 0   THEN
                       NEXT.

                 CREATE tt-fiador.
                 ASSIGN tt-fiador.nrdconta = crapepr.nrdconta
                        tt-fiador.nrctremp = crapepr.nrctremp
                        tt-fiador.dtmvtolt = crapepr.dtmvtolt
                        tt-fiador.vlemprst = crapepr.vlemprst
                        tt-fiador.qtpreemp = crapepr.qtpreemp
                        tt-fiador.vlpreemp = crapepr.vlpreemp.

                 RUN saldo-devedor-epr (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT par_nmdatela,
                                        INPUT par_idorigem,
                                        INPUT crapepr.nrdconta,
                                        INPUT 1,
                                        INPUT par_dtmvtolt,
                                        INPUT par_dtmvtopr,
                                        INPUT crapepr.nrctremp,
                                        INPUT "",
                                        INPUT 0,
                                        INPUT FALSE,
                                        OUTPUT par_vlsdeved,
                                        OUTPUT par_vltotpre,
                                        OUTPUT par_qtprecal,
                                        OUTPUT TABLE tt-erro).

                 IF   RETURN-VALUE <> "OK"   THEN
                      RETURN "NOK".

                 ASSIGN tt-fiador.vlsdeved = par_vlsdeved.

             END.

         END.

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    RUN consulta-avalista IN h-b1wgen9999 (INPUT par_cdcooper,
                                           INPUT 0,
                                           INPUT 0,
                                           INPUT 1, /* Ayllos*/
                                           INPUT par_nrdconta,
                                           INPUT par_dtmvtolt,
                                           INPUT par_nrctaava,
                                           INPUT par_nrcpfcgc,
                                           OUTPUT TABLE tt-dados-avais,
                                           OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h-b1wgen9999.

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    IF   par_nrctaava > 0   THEN /* Pegar os bens do avalista */
         DO:
             RUN sistema/generico/procedures/b1wgen0056.p
                                             PERSISTENT SET h-b1wgen0056.

             RUN Busca-Dados IN h-b1wgen0056 (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_cdoperad,
                                              INPUT par_nrctaava,
                                              INPUT par_idorigem,
                                              INPUT par_nmdatela,
                                              INPUT par_idseqttl,
                                              INPUT FALSE,
                                              INPUT 0, /* Todos os bens */
                                              INPUT "C", /* Consulta */
                                              INPUT ?,
                                              OUTPUT aux_msgconta,
                                              OUTPUT TABLE tt-crapbem,
                                              OUTPUT TABLE tt-erro).
             DELETE PROCEDURE h-b1wgen0056.

             IF   RETURN-VALUE <> "OK"   THEN
                  RETURN "NOK".
         END.
    ELSE
         IF   par_nrcpfcgc > 0   THEN
              DO:
                  FIND LAST crapavt WHERE crapavt.cdcooper = par_cdcooper   AND
                                          crapavt.nrcpfcgc = par_nrcpfcgc
                                          NO-LOCK NO-ERROR.

                  IF   AVAIL crapavt   THEN
                       DO:
                           DO i = 1 TO 6:

                               IF   crapavt.dsrelbem[i] = ""   THEN
                                    NEXT.

                               aux_dsrelbem = REPLACE(crapavt.dsrelbem[i], ";", ",").
                               aux_dsrelbem = REPLACE(aux_dsrelbem, "|", "-").

                               CREATE tt-crapbem.
                               ASSIGN tt-crapbem.dsrelbem = aux_dsrelbem
                                      tt-crapbem.persemon = crapavt.persemon[i]
                                      tt-crapbem.qtprebem = crapavt.qtprebem[i]
                                      tt-crapbem.vlrdobem = crapavt.vlrdobem[i]
                                      tt-crapbem.vlprebem = crapavt.vlprebem[i]
                                      tt-crapbem.idseqbem = i.

                           END.

                       END.
              END.

    RETURN "OK".

END PROCEDURE.


/**************************************************************************
 Validar os bens cadastrado na proposta de emprestimo com linha
 de credito do tipo alienacao.
**************************************************************************/
PROCEDURE valida-dados-alienacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.

    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dscorbem AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdplaca AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idseqbem AS INTE                           NO-UNDO.
    
    DEF  INPUT PARAM par_dscatbem AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dstipbem AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsbemfin AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vlmerbem AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpchassi AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dschassi AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ufdplaca AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_uflicenc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrrenava AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nranobem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrmodbem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfbem AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_idcatbem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_flgsenha AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM par_dsmensag AS CHAR                           NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    /* Acionar rotina convertida */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_valida_dados_alienacao
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                             INPUT par_cddopcao,
                                             INPUT par_nmdatela,
                                             INPUT par_cdoperad,
                                             INPUT par_nrdconta,
                                             INPUT par_nrctremp,
                                             INPUT par_dscorbem,
                                             INPUT par_nrdplaca,
                                             INPUT par_idseqbem,
                                             INPUT par_dscatbem,
                                             INPUT par_dstipbem,
                                             INPUT par_dsbemfin,
                                             INPUT par_vlmerbem,
                                             INPUT par_tpchassi,
                                             INPUT par_dschassi,
                                             INPUT par_ufdplaca,
                                             INPUT par_uflicenc,
                                             INPUT par_nrrenava,
                                             INPUT par_nranobem,
                                             INPUT par_nrmodbem,
                                             INPUT par_nrcpfbem,
                                             INPUT par_vlemprst,        
                                            OUTPUT "",  /* par_nmdcampo */
                                            OUTPUT 0,   /* par_flgsenha */
                                            OUTPUT "",  /* par_dsmensag */
                                            OUTPUT 0,   /* par_cdcritic */
                                            OUTPUT ""). /* par_dscritic */  
        
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_valida_dados_alienacao
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
        
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
        
                           ASSIGN aux_cdcritic = 0
                       aux_dscritic = ""
           aux_cdcritic = INT(pc_valida_dados_alienacao.par_cdcritic) 
                          WHEN pc_valida_dados_alienacao.par_cdcritic <> ?
           aux_dscritic = pc_valida_dados_alienacao.par_dscritic
                          WHEN pc_valida_dados_alienacao.par_dscritic <> ?
           par_nmdcampo = pc_valida_dados_alienacao.par_nmdcampo 
                                 WHEN pc_valida_dados_alienacao.par_nmdcampo <> ?               
           par_flgsenha = pc_valida_dados_alienacao.par_flgsenha 
                                 WHEN pc_valida_dados_alienacao.par_flgsenha <> ?               
           par_dsmensag = pc_valida_dados_alienacao.par_dsmensag 
                                 WHEN pc_valida_dados_alienacao.par_dsmensag <> ?.
            
    IF aux_cdcritic <> 0 OR aux_dscritic <> " " THEN
                 DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.


/**************************************************************************
 Validar os dados do imovel cadastrado na proposta de emprestimo com linha
 de credito do tipo hipoteca.
**************************************************************************/
PROCEDURE valida-dados-hipoteca:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dscatbem AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsbemfin AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vlmerbem AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_idcatbem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsclassi AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_vlrdobem AS DECI                           NO-UNDO.    
    DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmbairro AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufende AS CHAR                           NO-UNDO.
    
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_flgsenha AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dsmensag AS CHAR                           NO-UNDO.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    DO WHILE TRUE:

        IF   TRIM(par_dscatbem) <> ""   AND
             TRIM(par_dsbemfin)  = ""   THEN
             DO:
                 ASSIGN aux_dscritic = "Descricao do imovel deve ser informada."
                        par_nmdcampo = "dsbemfin".
                 LEAVE.
             END.

        IF   TRIM(par_dscatbem)  = ""   AND
             TRIM(par_dsbemfin) <> ""   THEN
             DO:
                 ASSIGN aux_dscritic = "Categoria do imovel deve ser informada."
                        par_nmdcampo = "dscatbem".
                 LEAVE.
             END.

        IF   TRIM(par_dsclassi)  = ""   AND
             TRIM(par_dsbemfin) <> ""   THEN
             DO:
                 ASSIGN aux_dscritic = "Classificacao do imovel deve ser informada."
                        par_nmdcampo = "dsclassi".
                 LEAVE.
             END.             

        IF   TRIM(par_dscatbem) <> ""   AND
             par_vlmerbem = 0     THEN
             DO:
                 ASSIGN aux_dscritic = "Valor de mercado do bem deve ser "
                                       + "informado."
                        par_nmdcampo = "vlmerbem".
                 LEAVE.
             END.

        IF   TRIM(par_dscatbem) <> ""   AND
             par_vlrdobem = 0     THEN
             DO:
                 ASSIGN aux_dscritic = "Valor de venda do bem deve ser "
                                       + "informado."
                        par_nmdcampo = "vlrdobem".
                 LEAVE.
             END.         
             
        IF   TRIM(par_dscatbem) <> ""   AND
             par_dsendere = ""    THEN
             DO:
                 ASSIGN aux_dscritic = "Endereco do bem deve ser "
                                       + "informado."
                        par_nmdcampo = "dsendere".
                 LEAVE.
             END.         
             
         IF   TRIM(par_dscatbem) <> ""  THEN
              DO:
                IF  par_nrcepend = 0 THEN
                 DO:
                   ASSIGN aux_dscritic = "Cep do bem deve ser "
                               + "informado."
                      par_nmdcampo = "nrcepend".
                   LEAVE.
                 END.                
              END.
             
        IF   TRIM(par_dscatbem) <> ""   AND
             par_nmbairro = ""    THEN
             DO:
                 ASSIGN aux_dscritic = "Bairro do bem deve ser "
                                       + "informado."
                        par_nmdcampo = "nmbairro".
                 LEAVE.
             END.                

        IF   TRIM(par_dscatbem) <> ""   AND
             par_nmcidade = ""    THEN
             DO:
                 ASSIGN aux_dscritic = "Cidade do bem deve ser "
                                       + "informado."
                        par_nmdcampo = "nmcidade".
                 LEAVE.
             END.                
             
        IF   TRIM(par_dscatbem) <> ""   AND
             par_cdufende = ""    THEN
             DO:
                 ASSIGN aux_dscritic = "UF do bem deve ser "
                                       + "informado."
                        par_nmdcampo = "cdufende".
                 LEAVE.
             END.         
             

        IF   par_idcatbem = 1    AND
             TRIM(par_dscatbem) = ""   THEN
             DO:
                 ASSIGN aux_dscritic = "Deve ser informado pelo menos 1 (um) "
                                       + "imovel."
                        par_nmdcampo = "dscatbem".
                 LEAVE.
             END.

        LEAVE.

    END. /* Fim tratamento criticas */

    IF   aux_cdcritic <> 0   OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    /* Verifica se apresenta a mensagem de garantia na tela */
    RUN verifica_mensagem_garantia (INPUT par_cdcooper,
                                    INPUT par_dscatbem,
                                    INPUT par_vlmerbem,
                                    INPUT par_vlemprst,
                                    OUTPUT par_flgsenha,
                                    OUTPUT par_dsmensag,
                                    OUTPUT aux_cdcritic,
                                    OUTPUT aux_dscritic).
    
    IF RETURN-VALUE <> "OK" THEN
       DO:
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
           RETURN "NOK".
       END.

    RETURN "OK".

END PROCEDURE.


/**************************************************************************
 Montar as mensagens de alerta no final do prenchimento das alteraçoes
 ou inclusoes de propostas de emprestimo.
**************************************************************************/
PROCEDURE verifica-outras-propostas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vleprori AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlminimo AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_qtpromis AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtpreemp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    DEF OUTPUT PARAM TABLE FOR tt-grupo.

    DEF  VAR aux_contador AS INTE                                   NO-UNDO.
    DEF  VAR aux_contaepr AS INTE                                   NO-UNDO.
    DEF  VAR aux_vlestudo AS DECI                                   NO-UNDO.
    DEF  VAR aux_nrdgrupo AS INTE                                   NO-UNDO.
    DEF  VAR aux_gergrupo AS CHAR                                   NO-UNDO.
    DEF  VAR aux_dsdrisgp AS CHAR                                   NO-UNDO.
    DEF  VAR aux_pertengp AS LOGI                                   NO-UNDO.
    DEF  VAR aux_vlendivi AS DEC                                    NO-UNDO.
    DEF  VAR aux_vltotemp AS DECI                                   NO-UNDO.
    DEF  VAR aux_vlemprst AS DECI                                   NO-UNDO.
    DEF  VAR aux_qtprecal AS DECI                                   NO-UNDO.
	DEF  VAR aux_flgrestrito AS DECI                                NO-UNDO.
    DEF  VAR h-b1wgen0147 AS HANDLE                                 NO-UNDO.
    
    DEF  BUFFER b1-craplcr FOR craplcr.
    DEF  BUFFER b2-craplcr FOR craplcr.
	DEF  BUFFER b1-crapass FOR crapass.

    EMPTY TEMP-TABLE tt-grupo.
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-msg-confirma.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FOR FIRST b1-craplcr FIELDS(flgsegpr) 
                         WHERE b1-craplcr.cdcooper = par_cdcooper AND
                               b1-craplcr.cdlcremp = par_cdlcremp
                               NO-LOCK: END.

    IF NOT AVAIL b1-craplcr THEN
       DO:
           ASSIGN aux_cdcritic = 363.
                 
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".
       END.
    
    /* Verifica se a Linha solicita para cadastrar Seguro Prestamista*/
    IF b1-craplcr.flgsegpr THEN
       DO:
          /* Valores das propostas */
          FOR EACH crawepr WHERE crawepr.cdcooper = par_cdcooper AND
                                 crawepr.nrdconta = par_nrdconta
                                 NO-LOCK:
        
              FOR FIRST b2-craplcr FIELDS(flgsegpr)
                                   WHERE b2-craplcr.cdcooper = crawepr.cdcooper AND
                                         b2-craplcr.cdlcremp = crawepr.cdlcremp
                                         NO-LOCK: END.
        
              /* Verifica se a linha de credito eh Seguro Prestamista*/
              IF AVAIL b2-craplcr AND NOT b2-craplcr.flgsegpr THEN
                 NEXT.

              FOR FIRST crapepr FIELDS(cdcooper nrdconta nrctremp inliquid)
                                WHERE crapepr.cdcooper = crawepr.cdcooper AND
                                      crapepr.nrdconta = crawepr.nrdconta AND
                                      crapepr.nrctremp = crawepr.nrctremp
                                      NO-LOCK: END.
        
              IF AVAILABLE crapepr THEN
                 DO:
                     IF crapepr.inliquid = 1 THEN
                         NEXT.

                     /* Calcula saldo devedor do contrato */
                     RUN saldo-devedor-epr(INPUT crapepr.cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_nmdatela,
                                           INPUT par_idorigem,
                                           INPUT crapepr.nrdconta,
                                           INPUT par_idseqttl,
                                           INPUT par_dtmvtolt,
                                           INPUT par_dtmvtopr,
                                           INPUT crapepr.nrctremp,
                                           INPUT "ATENDA",
                                           INPUT 1,
                                           INPUT FALSE,
                                          OUTPUT aux_vlsdeved,
                                          OUTPUT aux_vlemprst,
                                          OUTPUT aux_qtprecal,
                                          OUTPUT TABLE tt-erro).
    
                     IF RETURN-VALUE <> "OK" THEN
                        RETURN "NOK".

                     /* Soma todos os saldos devedores dos contratos */
                     ASSIGN aux_vltotemp = aux_vltotemp + aux_vlsdeved.

                 END. /* END IF AVAILABLE crapepr THEN */
              ELSE
                 DO:
                     ASSIGN aux_vlestudo = aux_vlestudo + crawepr.vlemprst.
        
                     /* Verificar se existe outras propostas em aberto */
                     IF par_nrctremp > 0 THEN
                        IF crawepr.nrctremp = par_nrctremp THEN
                           NEXT.
                
                     ASSIGN aux_contaepr = aux_contaepr + 1.

                 END.
        
          END.  /*  Fim do FOR EACH  */

          IF NOT VALID-HANDLE(h-b1wgen0147) THEN
             RUN sistema/generico/procedures/b1wgen0147.p
                 PERSISTEN SET h-b1wgen0147.

          /* Informacoes de emprestimo BNDES */
          RUN dados_bndes IN h-b1wgen0147 (INPUT par_cdcooper,
                                           INPUT par_nrdconta,
                                           OUTPUT aux_vlemprst,
                                           OUTPUT aux_vlsdeved,
                                           OUTPUT TABLE tt-saldo-devedor-bndes).
        
          DELETE PROCEDURE h-b1wgen0147.

          /* Somar no Valor Total do Emprestimo */
          ASSIGN aux_vltotemp = aux_vltotemp + aux_vlsdeved.
        
          /* Retirado em 31/08/2018 - PRJ438 - Seguro Prestamista será criado automaticamente - Paulo Martins       
          /* Valor desta proposta               + Valor dos emprestimos atuais  + */
          /* Valor de todas as outras propostas - valor anterior desta proposta   */
          IF (par_vlemprst + aux_vltotemp + aux_vlestudo - par_vleprori) >=
              par_vlminimo   THEN
              DO:
                 CREATE tt-msg-confirma.
        
                 ASSIGN aux_contador = aux_contador + 1
                        tt-msg-confirma.inconfir = aux_contador
                        tt-msg-confirma.dsmensag = "690 - ATENCAO! VERIFIQUE SE" +
                                                   " JA EXISTE PROPOSTA "        +
                                                   "PRESTAMISTA!".
        
              END.
           */
        
	      FIND b1-crapass WHERE b1-crapass.cdcooper = par_cdcooper
		                    AND b1-crapass.nrdconta = par_nrdconta
							NO-LOCK NO-ERROR.  

		  IF  AVAIL(b1-crapass) THEN
			  DO:
			    /*Se tem cnae verificar se e um cnae restrito*/
			    IF  b1-crapass.cdclcnae > 0 THEN
				    DO:

                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                        /* Busca a se o CNAE eh restrito */
                        RUN STORED-PROCEDURE pc_valida_cnae_restrito
                        aux_handproc = PROC-HANDLE NO-ERROR (INPUT b1-crapass.cdclcnae
                                                            ,0).

                        CLOSE STORED-PROC pc_valida_cnae_restrito
                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                        ASSIGN aux_flgrestrito = INTE(pc_valida_cnae_restrito.pr_flgrestrito)
                                                 WHEN pc_valida_cnae_restrito.pr_flgrestrito <> ?.

						IF  aux_flgrestrito = 1 THEN
						    DO:
    							 CREATE tt-msg-confirma.
								 ASSIGN aux_contador = aux_contador + 1				  
										tt-msg-confirma.inconfir = aux_contador
										tt-msg-confirma.dsmensag = "CNAE restrito, conforme previsto na Política de Responsabilidade Socioambiental do Sistema AILOS. Necessário apresentar Licença Regulatória.".
							END.

					END.
			  END.
        
          /* Existe outra proposta de emprestimo */
          IF aux_contaepr > 0 THEN
             DO:
                CREATE tt-msg-confirma.
        
                ASSIGN aux_contador = aux_contador + 1
                       tt-msg-confirma.inconfir = aux_contador
                       tt-msg-confirma.dsmensag = CAPS("Existem propostas em "  +
                                                  "aberto," + " atencao para "  +
                                                  "o comprometimento da renda.").
        
             END.

       END. /* END IF craplcr.flgsegpr THEN */

    IF NOT VALID-HANDLE(h-b1wgen0138) THEN
       RUN sistema/generico/procedures/b1wgen0138.p
           PERSISTENT SET h-b1wgen0138.

    ASSIGN aux_pertengp =  DYNAMIC-FUNCTION("busca_grupo" IN h-b1wgen0138,
                                                          INPUT par_cdcooper,
                                                          INPUT par_nrdconta,
                                                          OUTPUT aux_nrdgrupo,
                                                          OUTPUT aux_gergrupo,
                                                          OUTPUT aux_dsdrisgp).

    IF aux_gergrupo <> "" THEN
       DO:
           CREATE tt-msg-confirma.

           ASSIGN aux_contador = aux_contador + 1
                  tt-msg-confirma.inconfir = aux_contador
                  tt-msg-confirma.dsmensag = CAPS(aux_gergrupo).

       END.

    IF aux_pertengp THEN
       DO:
           RUN calc_endivid_grupo IN h-b1wgen0138
                                 (INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_cdoperad,
                                  INPUT par_dtmvtolt,
                                  INPUT par_nmdatela,
                                  INPUT par_idorigem,
                                  INPUT aux_nrdgrupo,
                                  INPUT TRUE, /*Consulta por conta*/
                                  OUTPUT aux_dsdrisgp,
                                  OUTPUT aux_vlendivi,
                                  OUTPUT TABLE tt-grupo,
                                  OUTPUT TABLE tt-erro).

           IF VALID-HANDLE(h-b1wgen0138) THEN
              DELETE OBJECT h-b1wgen0138.

           IF RETURN-VALUE <> "OK" THEN
              RETURN "NOK".

       END.

    IF VALID-HANDLE(h-b1wgen0138) THEN
       DELETE OBJECT h-b1wgen0138.

    DO WHILE TRUE:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper  AND  
                           crapass.nrdconta = par_nrdconta  NO-LOCK NO-ERROR.
        
        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN aux_dscritic = "Registro de associado nao encontrado.".
                LEAVE.
            END.
            
    
        IF  TEMP-TABLE tt-bens-alienacao:HAS-RECORDS THEN
            FOR EACH tt-bens-alienacao WHERE tt-bens-alienacao.nrcpfbem > 0 NO-LOCK:
    
                IF  tt-bens-alienacao.nrcpfbem = crapass.nrcpfcgc THEN
                    NEXT.
                
                IF  NOT CAN-FIND(tt-interv-anuentes WHERE
                                 tt-interv-anuentes.nrcpfcgc = tt-bens-alienacao.nrcpfbem) THEN
                    DO:
                        CREATE tt-msg-confirma.
                        
                        ASSIGN aux_contador = aux_contador + 1
                               tt-msg-confirma.inconfir = aux_contador
                               tt-msg-confirma.dsmensag = "CPF/CNPJ PROPR. DO(S) BEM(NS) DEVE SER CADASTRADO COMO INTERVENIENTE!".
    
                        LEAVE.
    
                    END.
            END.

       /* Criticar qtdade promissorias/qtdade prestacoes */
       IF  par_qtpromis > par_qtpreemp      OR
           (par_qtpromis > 0 AND par_qtpreemp MOD par_qtpromis > 0) THEN
           DO:
               ASSIGN aux_cdcritic = 842.
               LEAVE.

           END.

       LEAVE.

    END. /* Tratamento de criticas */

    IF aux_cdcritic <> 0  OR
       aux_dscritic <> "" THEN
       DO:
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".

       END.

    RETURN "OK".

END PROCEDURE.


/**************************************************************************
 Alterar todos os dados da proposta de emprestimo.
 Opcao de Alterar na rotina Emprestimo da tela ATENDA.
**************************************************************************/
PROCEDURE grava-proposta-completa:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
        DEF  INPUT PARAM par_cdpactra AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE INIT 0                    NO-UNDO. /*Inicializaçao = CH660371 - Ana (Envolti)*/
    DEF  INPUT PARAM par_tpemprst AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgcmtlc AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_vlutiliz AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vllimapv AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    /** ---------------------- Dados para a crawepr -------------------- */
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlpreant AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlpreemp AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_qtpreemp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnivris AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdfinemp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtdialib AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgimppr AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgimpnp AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_percetop AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_idquapro AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_qtpromis AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgpagto AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dsctrliq AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrctaava AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctaav2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idcarenc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcarenc AS DATE                           NO-UNDO.
    /** ------- Dados para dados do Rating e do Banco central ---------- */
    DEF  INPUT PARAM par_nrgarope AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrperger AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcnsspc AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrinfcad AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdrisco AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vltotsfn AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_qtopescr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtifoper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrliquid AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlopescr AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlrpreju AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrpatlvr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtoutspc AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtoutris AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlsfnout AS DECI                           NO-UNDO.
    /** ---------------- Dados Salario/Faturamento -------------------- **/
    DEF  INPUT PARAM par_vlsalari AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vloutras AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlalugue AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlsalcon AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nmempcje AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgdocje AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctacje AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcje AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_perfatcl AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlmedfat AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_inconcje AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgconsu AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dsobserv AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdfinan AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdrendi AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdebens AS CHAR                           NO-UNDO.
    /** ----------- Alienacao / Hipoteca / Intervenientes ------------- **/
    DEF  INPUT PARAM par_dsdalien AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsinterv AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_lssemseg AS CHAR                           NO-UNDO.
    /** ------------------- Parametros do 1 avalista ------------------ **/
    DEF  INPUT PARAM par_nmdaval1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfav1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdocav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdcjav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpfcjav1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tdccjav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_doccjav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende1av1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende2av1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrfonav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_emailav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufava1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepav1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnacio1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vledvmt1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlrenme1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrender1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complen1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxaps1 AS INTE                           NO-UNDO.
    /* Daniel */
    DEF  INPUT PARAM par_inpesso1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtnasct1 AS DATE                           NO-UNDO.
    /* Leonardo P438 */
	DEF  INPUT PARAM par_vlrecjg1 AS DECI                           NO-UNDO.
    
    /** ------------------- Parametros do 2 avalista ------------------- **/
    DEF  INPUT PARAM par_nmdaval2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfav2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdocav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdcjav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpfcjav2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tdccjav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_doccjav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende1av2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende2av2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrfonav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_emailav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufava2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepav2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnacio2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vledvmt2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlrenme2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrender2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complen2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxaps2 AS INTE                           NO-UNDO.
    /* Daniel */
    DEF  INPUT PARAM par_inpesso2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtnasct2 AS DATE                           NO-UNDO.
    /* Leonardo P438*/
	DEF  INPUT PARAM par_vlrecjg2 AS DECI                           NO-UNDO.

    DEF  INPUT PARAM par_dsdbeavt AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dsjusren AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtlibera AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idcobope AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idfiniof AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dscatbem AS CHAR                           NO-UNDO.
    /* par_inresapr DEFAULT 1, INTCDC envia 0 quando nao alterada sit proposta */
    DEF  INPUT PARAM par_inresapr AS INT                            NO-UNDO.
	/* PJ438 Sprint 5 */
	DEF  INPUT PARAM par_dsdopcao AS CHAR                           NO-UNDO.
    /*P438 novo parametro para receber se perde ou nao perder aprovacao COM-HANDLE
      a alteracao de garantia.
      */
    DEF  INPUT PARAM par_ingarapr AS INT                            NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    DEF OUTPUT PARAM par_recidepr AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM nov_nrctremp AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_flmudfai AS CHAR                           NO-UNDO.


    DEF  VAR         aux_contador AS INTE                           NO-UNDO.
    DEF  VAR         aux_contabns AS INTE                           NO-UNDO.
    DEF  VAR         aux_contbens AS INTE                           NO-UNDO.
    DEF  VAR         aux_contbem1 AS INTE                           NO-UNDO.
    DEF  VAR         reg_dsdregis AS CHAR                           NO-UNDO.
    DEF  VAR         reg_dsdregi1 AS CHAR                           NO-UNDO.
    DEF  VAR         aux_idchsdup AS LOG                           NO-UNDO.
    DEF  VAR         aux_nmdcampo AS CHAR                           NO-UNDO.
    DEF  VAR         aux_nrcpfcgc AS CHAR                           NO-UNDO.
    DEF  VAR         par_idseqbem AS INTE                           NO-UNDO.

    DEF   VAR        aux_qtdiacar AS INTE                           NO-UNDO.
    DEF   VAR        aux_vlajuepr AS DECI                           NO-UNDO.
    DEF   VAR        aux_txdiaria AS DECI                           NO-UNDO.
    DEF   VAR        aux_txmensal AS DECI                           NO-UNDO.
    DEF   VAR        aux_vliofepr AS DECI                           NO-UNDO.
    DEF   VAR        aux_vlrtarif AS DECI                           NO-UNDO.
    DEF   VAR        aux_vllibera AS DECI                           NO-UNDO.
    DEF   VAR        aux_qttolatr AS INTE INIT 0                    NO-UNDO.
    DEF   VAR        aux_dsoperac AS CHAR                           NO-UNDO.
    DEF   VAR        aux_ponteiro AS INTE                           NO-UNDO.
    DEF   VAR        aux_seqcontr AS INTE                           NO-UNDO.
    DEF   VAR        aux_inconfir AS INTE                           NO-UNDO.
    DEF   VAR        aux_dsretorn AS CHAR                           NO-UNDO.
    DEF   VAR        aux_inlcrmcr AS CHAR                           NO-UNDO.
    DEF   VAR        aux_flgsenha AS INTE                           NO-UNDO.
    DEF   VAR        aux_ncraliqu AS INTE                           NO-UNDO.
    DEF   VAR        aux_contaemp AS INTE                           NO-UNDO.
    DEF   VAR        aux_tpatuidx AS INTE                           NO-UNDO.

    DEF  VAR         h-b1wgen0043 AS HANDLE                         NO-UNDO.
    DEF  VAR         h-b1wgen0191 AS HANDLE                         NO-UNDO.
    DEF  VAR         h-b1wgen0110 AS HANDLE                         NO-UNDO.
    DEF   VAR        h-b1wgen0188 AS HANDLE                         NO-UNDO.
    DEF  VAR         aux_cdcritic AS INTE                           NO-UNDO.
    DEF  VAR         aux_dscritic AS CHAR                           NO-UNDO.
    DEF  VAR         aux_dstransa AS CHAR                           NO-UNDO.
    DEF  VAR         aux_dsorigem AS CHAR                           NO-UNDO.  
    DEF	 VAR 		     aux_mensagens AS CHAR						              NO-UNDO.

    DEF VAR          aux_flgcescr AS LOG INIT FALSE                 NO-UNDO.
    DEF VAR          aux_fleprCDC AS LOG INIT FALSE                 NO-UNDO.
    DEF  VAR         aux_vlemprst        AS DECI                    NO-UNDO.   
    DEF  VAR         aux_qtdias_carencia AS INTE                    NO-UNDO.
    DEF  VAR         aux_vlrdoiof        AS DECIMAL                 NO-UNDO.           
    DEF  VAR         h-b1wgen0097        AS HANDLE                  NO-UNDO.
    DEF  VAR         aux_dscatbem        AS CHAR                    NO-UNDO.
    DEF  VAR         aux_flperapr        AS CHAR                    NO-UNDO.
	DEF  VAR         aux_opcaoalt        AS CHAR                    NO-UNDO.
    DEF VAR          aux_idpeapro AS INT                            NO-UNDO.
    DEF  VAR         aux_regrager AS INT                            NO-UNDO.
    DEF  VAR         aux_reggaran AS INT                            NO-UNDO.
    DEF VAR          aux_dserro   AS CHAR                           NO-UNDO.
    DEF VAR          aux_nrgarope AS INT                            NO-UNDO. /*PRJ 438 BUG*/
    DEF VAR          aux_nrliquid AS INT                            NO-UNDO. /*PRJ 438 BUG*/
    DEF VAR          aux_contigen AS LOGI                           NO-UNDO.
    DEF VAR          aux_interrup AS LOGI                           NO-UNDO.
    DEF VAR          aux_vloutras AS DECI                           NO-UNDO.

    DEF VAR          aux_dsassdig  AS CHAR                          NO-UNDO.
    DEF VAR          aux_des_reto  AS CHAR                          NO-UNDO.

    DEF  BUFFER      crabavt FOR  crapavt.

    EMPTY TEMP-TABLE tt-erro.
    /*
      P438 nova regra perda de aprovacao 
      aux_idpeapro: 0 = Nao Perde Aprovacao 
                    1 = Perde Aprovacao 
                    2 = Aprovacao Auto.
    */
    ASSIGN aux_cdcritic = 0
           aux_contaemp = 0
           aux_dscritic = ""
           aux_idpeapro = 0 /*Inicia como não perde aprovacao*/
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Gravar as informacoes da proposta de credito"
           aux_regrager = 0
           aux_reggaran = par_ingarapr
           aux_idpeapro = par_ingarapr
           aux_interrup = FALSE.

    /* Carregar flag de cessao de credito */
    IF par_nmdatela = "CRPS714" THEN
       ASSIGN aux_flgcescr = TRUE.       

    IF par_nmdatela = "AUTOCDC" OR 
       par_cdoperad = "AUTOCDC" THEN
      ASSIGN aux_fleprCDC = TRUE. 
    
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapass THEN
       DO:
          ASSIGN aux_cdcritic = 9.

          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).

          RETURN "NOK".

       END.

    IF NOT VALID-HANDLE(h-b1wgen0110) THEN
       RUN sistema/generico/procedures/b1wgen0110.p PERSISTENT SET h-b1wgen0110.

    /*Monta a mensagem da operacao para envio no e-mail*/
    IF par_cddopcao = "A" THEN
       ASSIGN aux_dsoperac =  "Tentativa de alteracao da proposta de "     +
                              "emprestimo/financiamento na conta "         +
                              STRING(crapass.nrdconta,"zzzz,zzz,9")        +
                              " - CPF/CNPJ "                               +
                             (IF crapass.inpessoa = 1 THEN
                                 STRING((STRING(crapass.nrcpfcgc,
                                         "99999999999")),"xxx.xxx.xxx-xx")
                              ELSE
                                 STRING((STRING(crapass.nrcpfcgc,
                                         "99999999999999")),
                                         "xx.xxx.xxx/xxxx-xx")).
    ELSE
      ASSIGN aux_dsoperac =  "Tentativa de inclusao de nova proposta de "   +
                             "emprestimo/financiamento na conta "           +
                             STRING(crapass.nrdconta,"zzzz,zzz,9")          +
                             " - CPF/CNPJ "                                 +
                            (IF crapass.inpessoa = 1 THEN
                                STRING((STRING(crapass.nrcpfcgc,
                                        "99999999999")),"xxx.xxx.xxx-xx")
                             ELSE
                                STRING((STRING(crapass.nrcpfcgc,
                                        "99999999999999")),
                                        "xx.xxx.xxx/xxxx-xx")).

    /* Validar fraude apenas se nao for cessao de credito */
    IF  NOT aux_flgcescr AND
        /* Nao validar para CDC */ 
        NOT aux_fleprCDC THEN
      DO:
    /*Verifica se o associado esta no cadastro restritivo*/
    RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_dtmvtolt,
                                      INPUT par_idorigem,
                                      INPUT crapass.nrcpfcgc,
                                      INPUT crapass.nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT TRUE, /*bloqueia operacao*/
                                      INPUT (IF par_cddopcao = "A" THEN
                                                9 /*cdoperac*/
                                             ELSE
                                                12), /*cdoperac*/
                                      INPUT aux_dsoperac,
                                      OUTPUT TABLE tt-erro).

    IF VALID-HANDLE(h-b1wgen0110) THEN
       DELETE PROCEDURE(h-b1wgen0110).

    IF RETURN-VALUE <> "OK" THEN
       DO:
          IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
             DO:
                ASSIGN aux_dscritic = "Nao foi possivel verificar o " +
                                      "cadastro restritivo.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

             END.

          RETURN "NOK".

       END.
      END.
    
    ASSIGN aux_contbens = 0
           aux_contabns = 0
           aux_idchsdup = FALSE.

    /*Valida se nos bens alienados existem dois bens com os mesmos chassis*/
    DO aux_contador = 1 TO NUM-ENTRIES(par_dsdalien,"|"):
        
        ASSIGN reg_dsdregis = ENTRY(aux_contador,par_dsdalien,"|")
               aux_contbens = aux_contbens + 1
               aux_idchsdup = FALSE
               aux_dscatbem = aux_dscatbem + "|" + CAPS(ENTRY(1,reg_dsdregis,";")).
               
        IF CAN-DO("MOTO,AUTOMOVEL,CAMINHAO,OUTROS VEICULOS",TRIM(CAPS(ENTRY(1,reg_dsdregis,";")))) THEN
            DO:
                DO aux_contabns = 1 TO NUM-ENTRIES(par_dsdalien,"|"): 
                    
                    ASSIGN reg_dsdregi1 = ENTRY(aux_contabns,par_dsdalien,"|")
                           aux_contbem1 =  aux_contbem1 + 1.
                    
                    IF CAPS(ENTRY(5,reg_dsdregis,";")) = CAPS(ENTRY(5,reg_dsdregi1,";")) THEN
                        DO: 
                            IF  aux_idchsdup = TRUE THEN
                                DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "Existem dois chassis iguais na mesma proposta.".
                                       RUN gera_erro (INPUT par_cdcooper,
                                                      INPUT par_cdagenci,
                                                      INPUT par_nrdcaixa,
                                                      INPUT 1, /*sequencia*/
                                                      INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
                                    RETURN "NOK".
                            END.
                            

                            ASSIGN aux_idchsdup = TRUE.
                        END.
                END.                          
            
            END.

    END.

    ASSIGN aux_contbens = 0.

    /*Caso alteração de proposta*/
    IF par_cddopcao = "A" THEN
       DO:
           /* Bens alienados separados por pipe */
           DO aux_contador = 1 TO NUM-ENTRIES(par_dsdalien,"|"):
               
               ASSIGN reg_dsdregis = ENTRY(aux_contador,par_dsdalien,"|")
                      aux_contbens = aux_contbens + 1.
                      
               IF CAN-DO("MOTO,AUTOMOVEL,CAMINHAO,OUTROS VEICULOS",TRIM(CAPS(ENTRY(1,reg_dsdregis,";")))) THEN
                  DO:
               
                     RUN valida-dados-alienacao (INPUT par_cdcooper,
                                                 INPUT 0,
                                                 INPUT 0,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nmdatela,
                                                 INPUT 1, /* Ayllos*/
                                                 
                                                 INPUT "A",
                                                 INPUT par_nrdconta,
                                                 INPUT par_nrctremp,
                                                 INPUT CAPS(ENTRY(3,reg_dsdregis,";")),
                                                 INPUT IF CAPS(ENTRY(14,reg_dsdregis,";")) = "USADO" THEN
                                                          CAPS(ENTRY(8,reg_dsdregis,";"))
                                                       ELSE "" /* ZERO KM */,
                                                 INPUT INTE(ENTRY(15,reg_dsdregis,";")),
                                                 
                                                 INPUT CAPS(ENTRY(1,reg_dsdregis,";")),
                                                 INPUT CAPS(ENTRY(14,reg_dsdregis,";")),
                                                 INPUT CAPS(ENTRY(2,reg_dsdregis,";")),
                                                 INPUT DECI(ENTRY(4,reg_dsdregis,";")),
                                                 INPUT INTE(ENTRY(10,reg_dsdregis,";")),
                                                 INPUT CAPS(ENTRY(5,reg_dsdregis,";")),
                                                 INPUT IF CAPS(ENTRY(14,reg_dsdregis,";")) = "USADO" THEN
                                                          CAPS(ENTRY(11,reg_dsdregis,";"))
                                                       ELSE "" /* ZERO KM */,
                                                 INPUT CAPS(ENTRY(13,reg_dsdregis,";")),
                                                 INPUT IF CAPS(ENTRY(14,reg_dsdregis,";")) = "USADO" THEN
                                                          DECI(ENTRY(9,reg_dsdregis,";"))
                                                       ELSE 0  /* ZERO KM */,
                                                 INPUT INTE (ENTRY(6,reg_dsdregis,";")),
                                                 INPUT INTE(ENTRY(7,reg_dsdregis,";")),
                                                 INPUT DECI(CAPS(ENTRY(12,reg_dsdregis,";"))),
                                                 INPUT aux_contbens,
                                                 INPUT TRUE,
                                                 INPUT par_vlemprst,
                                                 OUTPUT TABLE tt-erro,
                                                 OUTPUT aux_nmdcampo,
                                                 OUTPUT aux_flgsenha,
                                                 OUTPUT aux_dsmensag).
               

                                              
                     IF RETURN-VALUE <> "OK"   THEN
                         DO:
                             FIND FIRST tt-erro NO-LOCK NO-ERROR.
              
                             IF   AVAIL tt-erro  THEN
                                  MESSAGE tt-erro.dscritic.
                             ELSE
                                  MESSAGE
                                     "Erro na validacao dos dados alienados.".
              
                             DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
                                 PAUSE 3 NO-MESSAGE.
                                 LEAVE.
                             END.
              
                             RETURN "NOK".
              
                         END. 
                  END.
           END.    
    END. /*par_cddopcao = "A"*/

    /*
      Validaçao em caso de alteraçao, verifica perda de aprovaçao - PRJ438 Sprint-5  
     Regra Geral - Paulo Martins (Mouts)
      Caso alteração de proposta
      Nao validar em caso de CDC
      Se ja nao perde devido alteracao de garantia
     */
    IF par_cddopcao = "A" AND NOT aux_fleprCDC AND aux_reggaran = 0 THEN
       DO:

       {includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
       RUN STORED-PROCEDURE pc_valida_perda_aprov_proposta
		   aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT par_nrctremp,
                                            INPUT aux_dsorigem,
                                            /** ---------------------- Dados para a crawepr -------------------- */
                                            INPUT par_qtpreemp,
                                            INPUT par_dsnivris,
                                            INPUT par_cdlcremp,
                                            INPUT par_cdfinemp,
                                            INPUT par_qtdialib,
                                            INPUT (IF par_flgimpnp THEN 1 ELSE 0),
                                            INPUT par_percetop,
                                            INPUT par_idquapro,
                                            INPUT par_dtdpagto,
                                            INPUT par_qtpromis,
                                            INPUT (IF par_flgpagto THEN 1 ELSE 0),
                                            INPUT par_dsctrliq,
                                            INPUT par_idcarenc,
                                            INPUT par_dtcarenc,
                                            /** ------- Dados para dados do Rating e do Banco central ---------- */
                                            INPUT par_nrgarope,
                                            INPUT par_nrperger,
                                            INPUT par_dtcnsspc,
                                            INPUT par_dtdrisco,
                                            INPUT par_vltotsfn,
                                            INPUT par_qtopescr,
                                            INPUT par_qtifoper,
                                            INPUT par_nrliquid,
                                            INPUT par_vlopescr,
                                            INPUT par_vlrpreju,
                                            INPUT par_nrpatlvr,
                                            INPUT par_dtoutspc,
                                            INPUT par_dtoutris,
                                            INPUT par_vlsfnout,
                                            /** ---------------- Dados Salario/Faturamento -------------------- **/
                                            INPUT par_vlsalari,
                                            INPUT par_vloutras,
                                            INPUT par_vlalugue,
                                            INPUT par_vlsalcon,
                                            INPUT par_nmempcje,
                                            INPUT (IF par_flgdocje THEN 1 ELSE 0),                                            
                                            INPUT par_nrctacje,
                                            INPUT par_nrcpfcje,
                                            INPUT par_vlmedfat,
                                           INPUT par_dsdfinan,
                                            INPUT par_dsdrendi,
                                           INPUT par_dsjusren,
                                            INPUT par_idfiniof,
                                            OUTPUT 0, /*0 - Nao perdeu aprovaçao e 1 - Perdeu aprovaçao*/
                                            OUTPUT "", /*OK - se processar e NOK - se erro*/
                                            OUTPUT 0, /*Codigo da critica*/
                                            OUTPUT ""). /*Descricao da critica*/

          /* Fechar o procedimento para buscarmos o resultado */ 
          CLOSE STORED-PROC pc_valida_perda_aprov_proposta
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
              
          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

      ASSIGN aux_idpeapro = pc_valida_perda_aprov_proposta.pr_idpeapro
        WHEN pc_valida_perda_aprov_proposta.pr_idpeapro <> ?
               aux_dserro   = pc_valida_perda_aprov_proposta.pr_dserro
                              WHEN pc_valida_perda_aprov_proposta.pr_dserro <> ?
               aux_cdcritic = pc_valida_perda_aprov_proposta.pr_cdcritic
        WHEN pc_valida_perda_aprov_proposta.pr_cdcritic <> ?
               aux_dscritic = pc_valida_perda_aprov_proposta.pr_dscritic
                              WHEN pc_valida_perda_aprov_proposta.pr_dscritic <> ?
        aux_regrager = aux_idpeapro.
          
       END.

    /* Emprestimo do tipo PRICE PRE-FIXADO ou POS-FIXADO */
    IF par_tpemprst = 1 OR 
       par_tpemprst = 2 THEN
       DO:
           /* Obter o numero de dias para cobranca - TAB089 */
           FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                              craptab.nmsistem = "CRED"       AND
                              craptab.tptabela = "USUARI"     AND
                              craptab.cdempres = 11           AND
                              craptab.cdacesso = "PAREMPREST" AND
                              craptab.tpregist = 01           
                              NO-LOCK NO-ERROR.
        
           IF NOT AVAIL craptab THEN
              DO:
                  ASSIGN aux_cdcritic = 55.
                  RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                  RETURN "NOK".
              END.

           ASSIGN aux_qttolatr = INTE(SUBSTRING(craptab.dstextab,1,3)).

       END. /* IF par_tpemprst = 1 */

    /* Busca registro de Qtd de impressoes de Notas Promissorias */
    DO  aux_contador = 1 TO 10:
    
        FIND craptab WHERE craptab.cdcooper = par_cdcooper    AND
                           craptab.nmsistem = "CRED"          AND
                           craptab.tptabela = "USUARI"        AND
                           craptab.cdempres = 11              AND
                           craptab.cdacesso = "PROPOSTANP"    AND
                           craptab.tpregist = 0
                           NO-LOCK NO-ERROR NO-WAIT.
    
        IF   NOT AVAILABLE craptab   THEN
           IF   LOCKED craptab   THEN
                DO:
                    aux_cdcritic = 77.
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
           ELSE
                aux_cdcritic = 55.
        ELSE
           aux_cdcritic = 0.
    
        LEAVE.
    
    END.  /*  Fim do DO .. TO  */

    IF aux_cdcritic <> 0 THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    
    FIND craplcr WHERE craplcr.cdcooper = par_cdcooper   AND
                       craplcr.cdlcremp = par_cdlcremp
                       NO-LOCK NO-ERROR.

    IF   NOT AVAIL craplcr   THEN
         DO:
             aux_cdcritic = 363.
             RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.          
         
    /* Guardar valor do emprestimo */
    ASSIGN aux_vlemprst = par_vlemprst.

    /* Caso financie IOF */
    IF par_idfiniof > 0 THEN 
    DO:
        
        /* Somente para Pós */
        IF par_tpemprst = 2 THEN
        DO:
          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

          /* Efetuar a chamada a rotina Oracle  */
          RUN STORED-PROCEDURE pc_busca_qtd_dias_carencia
              aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_idcarenc,
                                                  OUTPUT 0,   /* pr_qtddias */
                                                  OUTPUT 0,   /* pr_cdcritic */
                                                  OUTPUT ""). /* pr_dscritic */  

          /* Fechar o procedimento para buscarmos o resultado */ 
          CLOSE STORED-PROC pc_busca_qtd_dias_carencia
                 aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

          ASSIGN aux_cdcritic = 0
                 aux_dscritic = ""
                 aux_cdcritic = INT(pc_busca_qtd_dias_carencia.pr_cdcritic) 
                                WHEN pc_busca_qtd_dias_carencia.pr_cdcritic <> ?
                 aux_dscritic = pc_busca_qtd_dias_carencia.pr_dscritic
                                WHEN pc_busca_qtd_dias_carencia.pr_dscritic <> ?
                 aux_qtdias_carencia = INT(pc_busca_qtd_dias_carencia.pr_qtddias) 
                                       WHEN pc_busca_qtd_dias_carencia.pr_qtddias <> ?.
        END.
        
        IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
        DO:
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.        
                     
        /* Se financiar IOF, calcula esses valores e soma ao total emprestado, para enviar ao cálculo da parcela*/                             
        ASSIGN aux_vlrtarif = 0
               aux_vlrdoiof = 0.           
            
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        RUN STORED-PROCEDURE pc_calcula_iof_epr
        aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper
                                           ,INPUT par_nrdconta
                                           ,INPUT par_nrctremp
                                           ,INPUT par_dtmvtolt
                                           ,INPUT crapass.inpessoa                                                           
                                           ,INPUT par_cdlcremp
                                           ,INPUT par_cdfinemp
                                           ,INPUT par_qtpreemp
                                           ,INPUT par_vlpreemp
                                           ,INPUT par_vlemprst
                                           ,INPUT par_dtdpagto
                                           ,INPUT par_dtmvtolt
                                           ,INPUT par_tpemprst
                                           ,INPUT par_dtcarenc /* Data carencia */
                                           ,INPUT aux_qtdias_carencia /* dias de carencia */
                                           ,INPUT aux_dscatbem     /* Bens em garantia */
                                           ,INPUT par_idfiniof /* Indicador de financiamento de iof e tarifa */
                                           ,INPUT par_dsctrliq /* pr_dsctrliq */
                                           ,INPUT "N" /* Nao gravar valor nas parcelas */
                                           ,OUTPUT 0 /* Valor calculado da Parcela */
                                           ,OUTPUT 0 /* Valor calculado com o iof (principal + adicional) */
                                           ,OUTPUT 0 /* Valor calculado do iof principal */
                                           ,OUTPUT 0 /* Valor calculado do iof adicional */
                                           ,OUTPUT 0 /* Imunidade tributária */
                                           ,OUTPUT "").

        CLOSE STORED-PROC pc_calcula_iof_epr 
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
        /* Retornar valor da prestação */
        ASSIGN aux_dscritic = ""
               aux_dscritic = pc_calcula_iof_epr.pr_dscritic
                              WHEN pc_calcula_iof_epr.pr_dscritic <> ?
               aux_vlrdoiof = pc_calcula_iof_epr.pr_valoriof
                              WHEN pc_calcula_iof_epr.pr_valoriof <> ?.
        
        IF aux_dscritic <> "" THEN
        DO:
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT 0,
                         INPUT-OUTPUT aux_dscritic).
           RETURN "NOK".
        END.                              

        /* Se financia IOF + Tarifa */
        IF par_idfiniof > 0 THEN DO:

             IF NOT VALID-HANDLE(h-b1wgen0097) THEN
                RUN sistema/generico/procedures/b1wgen0097.p PERSISTENT SET h-b1wgen0097.               
             RUN consulta_tarifa_emprst IN h-b1wgen0097 (INPUT  par_cdcooper,
                                                         INPUT  par_cdlcremp,
                                                         INPUT  par_vlemprst,
                                                         INPUT  par_nrdconta,
                                                         INPUT  par_nrctremp,
                                                         INPUT  aux_dscatbem,
                                                         OUTPUT aux_vlrtarif,
                                                         OUTPUT TABLE tt-erro).                                
             DELETE PROCEDURE h-b1wgen0097.
             
             IF RETURN-VALUE = "NOK" THEN
                RETURN "NOK".
                
             ASSIGN aux_vlemprst = aux_vlemprst + aux_vlrtarif + aux_vlrdoiof.
             
        END.

    END.

    /* Para MicroCredito */
    IF craplcr.cdusolcr = 1 THEN
    DO:
          /* Para PF */
          IF (crapass.inpessoa = 1 AND craplcr.vlmaxass < aux_vlemprst)
          OR (crapass.inpessoa = 2 AND craplcr.vlmaxasj < aux_vlemprst) THEN
          DO:
               ASSIGN aux_dscritic = 
                            "Valor da proposta excede o valor maximo por Cooperado para Microcredito.".
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1, /*sequencia*/
                              INPUT 0,
                              INPUT-OUTPUT aux_dscritic).
               RETURN "NOK".
        END.
    END.     
    
    ASSIGN par_qtpromis = INTEGER(craptab.dstextab).

    IF  par_qtpromis = 0 THEN
        ASSIGN par_flgimpnp = FALSE.
        
        
    Gravar: DO TRANSACTION ON ERROR  UNDO Gravar, LEAVE Gravar
                          ON ENDKEY UNDO Gravar, LEAVE Gravar:

        DO aux_contador = 1 TO 10:

           FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                              crawepr.nrdconta = par_nrdconta   AND
                              crawepr.nrctremp = par_nrctremp
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF   NOT AVAIL crawepr   THEN
                IF   LOCKED crawepr   THEN
                     DO:
                         aux_cdcritic = 371.
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE    /* Inclusao da proposta */
                     DO:
                         DO WHILE TRUE:
                             { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                             /* Busca a proxima sequencia do campo crapldt.nrsequen */
                             RUN STORED-PROCEDURE pc_sequence_progress
                             aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPMAT"
                                                                 ,INPUT "NRCTREMP"
                                                                 ,INPUT STRING(par_cdcooper)
                                                                 ,INPUT "N"
                                                                 ,"").

                             CLOSE STORED-PROC pc_sequence_progress
                             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                             { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                             EMPTY TEMP-TABLE tt-erro.

                             ASSIGN aux_cdcritic = 0
                                    aux_dscritic = ""
                                    aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                                    aux_dstransa = "NRCTEMP: * " + pc_sequence_progress.pr_sequenc.

                             RUN proc_gerar_log (INPUT par_cdcooper,
                                                 INPUT par_cdoperad,
                                                 INPUT "",
                                                 INPUT aux_dsorigem,
                                                 INPUT aux_dstransa,
                                                 INPUT TRUE,
                                                 INPUT par_idseqttl,
                                                 INPUT par_nmdatela,
                                                 INPUT par_nrdconta,
                                                OUTPUT aux_nrdrowid).

                             /*Chamado 660371 - Se sequence nula ou com 0 -> está com erro*/
                             /*Seta mensagem de erro, sai da transaçao e gera log*/
                             IF pc_sequence_progress.pr_sequenc = ? /*OR pc_sequence_progress.pr_sequenc = 0*/ THEN 
                                DO: 
                                    ASSIGN aux_cdcritic = 0                                
                                           aux_dscritic = "Erro ao buscar sequence na tabela CRAPMAT.".
                                    LEAVE.
                             END.
                             ASSIGN par_nrctremp = INTE(pc_sequence_progress.pr_sequence)
                                                   WHEN pc_sequence_progress.pr_sequence <> ?.

                            IF  CAN-FIND(crawepr WHERE
                                    crawepr.cdcooper = par_cdcooper  AND
                                    crawepr.nrdconta = par_nrdconta  AND
                                    crawepr.nrctremp = par_nrctremp)
                                OR
                                CAN-FIND(crapepr WHERE
                                    crapepr.cdcooper = par_cdcooper  AND
                                    crapepr.nrdconta = par_nrdconta  AND
                                    crapepr.nrctremp = par_nrctremp)
                                OR
                                CAN-FIND(crapmcr WHERE
                                    crapmcr.cdcooper = par_cdcooper  AND
                                    crapmcr.nrdconta = par_nrdconta  AND
                                    crapmcr.nrcontra = par_nrctremp)
                                OR
                                par_nrctremp = 0

                                THEN NEXT.

                            LEAVE.

                         END.
                         
                         CREATE crawepr.
                         ASSIGN crawepr.cdcooper = par_cdcooper
                                crawepr.nrdconta = par_nrdconta
                                crawepr.nrctremp = par_nrctremp
                                crawepr.dtmvtolt = par_dtmvtolt
                                crawepr.cdoperad = par_cdoperad
                                crawepr.flgpreap = 0
                                crawepr.flgdocdg = 0.
                         VALIDATE crawepr.

                     END.  /* Fim Inclusao de proposta */
          
           aux_cdcritic = 0.
           LEAVE.
        END.             

        /*Chamado 660371*/
        IF   aux_cdcritic <> 0    or 
             aux_dscritic <> ""  THEN
             UNDO, LEAVE Gravar.

        /* Mandar como parametro de volta o recid da proposta e o numero */
        ASSIGN par_recidepr = INTE(RECID(crawepr))
               nov_nrctremp = par_nrctremp.

        IF par_tpemprst = 0 THEN
            ASSIGN crawepr.txdiaria = craplcr.txdiaria.
        ASSIGN crawepr.cdorigem = par_idorigem
               crawepr.dtaltpro = par_dtmvtolt
               crawepr.qtpreemp = par_qtpreemp
               crawepr.dsnivris = IF crawepr.dsnivris = ? 
			                      OR crawepr.dsnivris = ""
			                      THEN 
								     UPPER(par_dsnivris) 
							      ELSE 
								     crawepr.dsnivris
               crawepr.dsnivori = IF crawepr.dsnivori = ? 
			                      OR crawepr.dsnivori = ""
								  OR crawepr.dsnivori = "0"
			                      THEN 
								     UPPER(par_dsnivris) 
							      ELSE 
								     crawepr.dsnivori
               crawepr.cdlcremp = par_cdlcremp
               crawepr.cdfinemp = par_cdfinemp
               crawepr.qtdialib = par_qtdialib
               crawepr.flgimppr = par_flgimppr
               crawepr.flgimpnp = par_flgimpnp
               crawepr.percetop = par_percetop
               crawepr.dtdpagto = par_dtdpagto
               crawepr.dtvencto = par_dtdpagto
               crawepr.qtpromis = par_qtpromis
               crawepr.idquapro = par_idquapro
               crawepr.nrctrliq  = 0
               crawepr.flgpagto = IF   craplcr.tpdescto = 2   THEN
                                       FALSE
                                  ELSE
                                       par_flgpagto
               crawepr.tpdescto = craplcr.tpdescto
               crawepr.txbaspre = craplcr.txbaspre
               crawepr.txminima = craplcr.txminima
               crawepr.dsoperac = craplcr.dsoperac
               crawepr.dsobserv = par_dsobserv
               crawepr.inconcje = IF  (par_inconcje = TRUE) THEN 
                                       1
                                  ELSE
                                       0
               crawepr.tpemprst = par_tpemprst
               crawepr.qttolatr = aux_qttolatr
                           /* Agencia de que operador cadastrou a proposta*/
                           crawepr.cdagenci = par_cdpactra when crawepr.cdagenci = 0  
                           crawepr.hrinclus = TIME WHEN crawepr.hrinclus = 0

               crawepr.idcarenc = IF  (par_tpemprst = 2) THEN /* Pos-Fixado */
                                       par_idcarenc
                                  ELSE 0
               crawepr.dtcarenc = IF  (par_tpemprst = 2) THEN /* Pos-Fixado */
                                       par_dtcarenc
                                  ELSE ?
               crawepr.cddindex = IF  (par_tpemprst = 2) THEN /* Pos-Fixado */
                                       craplcr.cddindex
                                  ELSE 0
               crawepr.idfiniof = par_idfiniof.
               
               /*
               IF crawepr.idfiniof = 1 THEN               
                  ASSIGN crawepr.vlpreemp = par_vlpreemp.
               */ 

        /* Para PreAprovado */       
        FOR crappre FIELDS(cdfinemp) 
              WHERE crappre.cdcooper = par_cdcooper          AND
                    crappre.inpessoa = crapass.inpessoa      AND
                    crappre.cdfinemp = par_cdfinemp
                    NO-LOCK: END.

        IF AVAIL crappre THEN
            DO:
                
                 /* Gravar aceite Online quando operacao nao for AimaroWEB */                   
                 ASSIGN crawepr.dtpreapv = IF (par_idorigem = 5) THEN
                                               ?
                                           ELSE TODAY
                        crawepr.hrpreapv = IF (par_idorigem = 5) THEN
                                               0
                                           ELSE TIME.
                 
                 /* Enviar ao LOG somente quando nao for AimaroWeb*/  
                 IF (par_idorigem <> 5) THEN
                 DO:
                     RUN proc_gerar_log (INPUT par_cdcooper,
                                         INPUT par_cdoperad,
                                         INPUT "",
                                         INPUT aux_dsorigem,
                                         INPUT "PreAprovado assinado digitalmente em " 
                                               + STRING(crawepr.dtpreapv,"99/99/99") + " as " 
                                               + STRING(crawepr.hrpreapv,"HH:MM:SS") ,
                                         INPUT TRUE,
                                         INPUT par_idseqttl,
                                         INPUT par_nmdatela,
                                         INPUT par_nrdconta,
                                        OUTPUT aux_nrdrowid).
                 END.
            END.			   

        /* Se for Pos-Fixado */
        IF  par_tpemprst = 2  THEN
            DO:
               { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
               
               /* Efetuar a chamada a rotina Oracle  */
               RUN STORED-PROCEDURE pc_busca_tip_atualiz_index
                   aux_handproc = PROC-HANDLE NO-ERROR (INPUT craplcr.cddindex,
                                                       OUTPUT 0,   /* pr_tpatualizacao */
                                                       OUTPUT 0,   /* pr_cdcritic */
                                                       OUTPUT ""). /* pr_dscritic */  

               /* Fechar o procedimento para buscarmos o resultado */ 
               CLOSE STORED-PROC pc_busca_tip_atualiz_index
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

               { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
               
               ASSIGN aux_tpatuidx = 0
                      aux_cdcritic = 0
                      aux_dscritic = ""
                      aux_tpatuidx = pc_busca_tip_atualiz_index.pr_tpatualizacao
                                     WHEN pc_busca_tip_atualiz_index.pr_tpatualizacao <> ?
                      aux_cdcritic = INT(pc_busca_tip_atualiz_index.pr_cdcritic) 
                                     WHEN pc_busca_tip_atualiz_index.pr_cdcritic <> ?
                      aux_dscritic = pc_busca_tip_atualiz_index.pr_dscritic
                                     WHEN pc_busca_tip_atualiz_index.pr_dscritic <> ?

                      crawepr.tpatuidx = aux_tpatuidx.
            END.
      IF par_idcobope <> crawepr.idcobope THEN
          DO:
			{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

			RUN STORED-PROCEDURE pc_vincula_cobertura_operacao
				aux_handproc = PROC-HANDLE NO-ERROR (INPUT crawepr.idcobope
                                              ,INPUT par_idcobope
                                              ,INPUT crawepr.nrctremp
                                              ,"").

			CLOSE STORED-PROC pc_vincula_cobertura_operacao
				aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

			{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

			ASSIGN aux_dscritic  = ""
               aux_dscritic  = pc_vincula_cobertura_operacao.pr_dscritic 
               WHEN pc_vincula_cobertura_operacao.pr_dscritic <> ?.
                        
			IF aux_dscritic <> "" THEN
                                UNDO Gravar, LEAVE Gravar.
        
              ASSIGN crawepr.idcobope = par_idcobope
                     crawepr.idcobefe = par_idcobope.
          END.
        
		  
		ASSIGN aux_opcaoalt = "TP".  
		IF par_dsdopcao = "SVP" THEN
		  DO:
		   ASSIGN aux_opcaoalt = "ASA".
		END.
        
        RUN atualiza_dados_avalista_proposta 
            (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_nmdatela,
                                   INPUT par_idorigem,
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT par_dtmvtolt,
                                   INPUT par_nrctremp,
                                   INPUT par_flgerlog,
                                  /* INPUT "TP",     Altera Toda Proposta */
								   INPUT aux_opcaoalt,
                                       INPUT par_nrctaava,
             INPUT par_nrctaav2,
                                       INPUT par_nmdaval1,
                                       INPUT par_nrcpfav1,
                                       INPUT par_tpdocav1,
                                       INPUT par_dsdocav1,
                                       INPUT par_nmdcjav1,
                                       INPUT par_cpfcjav1,
                                       INPUT par_tdccjav1,
                                       INPUT par_doccjav1,
                                       INPUT par_ende1av1,
                                       INPUT par_ende2av1,
                                       INPUT par_nrfonav1,
                                       INPUT par_emailav1,
                                       INPUT par_nmcidav1,
                                       INPUT par_cdufava1,
                                       INPUT par_nrcepav1,
                                       INPUT par_cdnacio1,
                                       INPUT par_vledvmt1,
                                       INPUT par_vlrenme1,
                                       INPUT par_nrender1,
                                       INPUT par_complen1,
                                       INPUT par_nrcxaps1,
                                       INPUT par_inpesso1,
                                       INPUT par_dtnasct1,
									   INPUT par_vlrecjg1,
                                       INPUT par_nmdaval2,
                                       INPUT par_nrcpfav2,
                                       INPUT par_tpdocav2,
                                       INPUT par_dsdocav2,
                                       INPUT par_nmdcjav2,
                                       INPUT par_cpfcjav2,
                                       INPUT par_tdccjav2,
                                       INPUT par_doccjav2,
                                       INPUT par_ende1av2,
                                       INPUT par_ende2av2,
                                       INPUT par_nrfonav2,
                                       INPUT par_emailav2,
                                       INPUT par_nmcidav2,
                                       INPUT par_cdufava2,
                                       INPUT par_nrcepav2,
                                       INPUT par_cdnacio2,
                                       INPUT par_vledvmt2,
                                       INPUT par_vlrenme2,
                                       INPUT par_nrender2,
                                       INPUT par_complen2,
                                       INPUT par_nrcxaps2,
                                       INPUT par_inpesso2,
                                       INPUT par_dtnasct2,
									   INPUT par_vlrecjg2,
             INPUT par_dsdbeavt,
             /* Indica se deve restartar fluxo de aprovaçao */
             INPUT par_inresapr,
			 INPUT par_vlemprst, /*PJ438*/
             INPUT-OUTPUT aux_idpeapro,
            OUTPUT par_flmudfai,
            OUTPUT aux_nrgarope, /*PRJ438 - Bugs*/
            OUTPUT aux_nrliquid, /*PRJ438 - Bugs*/
            OUTPUT TABLE tt-erro,
            OUTPUT TABLE tt-msg-confirma).
        IF   RETURN-VALUE <> "OK"   THEN
             do:
				     FIND FIRST tt-erro NO-ERROR.
               IF   AVAIL tt-erro   THEN
                    aux_dscritic = tt-erro.dscritic.
               ELSE
                    aux_dscritic = "Ocorreram erros na atualizacao de dados do avalista da proposta".
               EMPTY TEMP-TABLE tt-erro.
             UNDO Gravar, LEAVE Gravar.
             end.
        RUN verifica_microcredito (INPUT par_cdcooper,
                                   INPUT par_cdlcremp,
                                  OUTPUT aux_dscritic,
                                  OUTPUT aux_inlcrmcr).
        
        IF   aux_dscritic <> ""   THEN
             UNDO Gravar, LEAVE Gravar.

        IF   aux_inlcrmcr <> "S"   THEN
             ASSIGN crawepr.nrseqrrq = 0.
        /* Contratos a serem liquidados */
        DO aux_contador = 1 TO NUM-ENTRIES(par_dsctrliq):

            IF   ENTRY(aux_contador,par_dsctrliq) = ""   THEN
                 NEXT.

            /* ALTERADO PARA QUANDO O CONTRATO FOR LIMITE/ADP */
            aux_ncraliqu = INTE(ENTRY(aux_contador,par_dsctrliq)) NO-ERROR.

            FIND FIRST crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                                     crapepr.nrdconta = par_nrdconta AND
                                     crapepr.nrctremp = aux_ncraliqu NO-LOCK NO-ERROR.

            IF AVAIL crapepr THEN
                DO:
                    aux_contaemp = aux_contaemp + 1.
                    ASSIGN crawepr.nrctrliq[aux_contaemp] =
                      INTE(ENTRY(aux_contador,par_dsctrliq)) NO-ERROR.
        END.
            ELSE
                DO:
                    ASSIGN crawepr.nrliquid =
                           INTE(ENTRY(aux_contador,par_dsctrliq)) NO-ERROR.
                END.
        END.

        /*Caso tenha ocorrido alteração de avalista e a proposta esteja aprovada, os dados nrgarope e nrliquid são atualizados antes
        em atualiza_dados_avalista_proposta*/
        IF aux_nrgarope = 0 THEN
          DO:
            ASSIGN aux_nrgarope = par_nrgarope
                   aux_nrliquid = par_nrliquid.
          END.
        
        
        /*Quando o proponente tiver cônjuge que possui conta cadastrado, deverá ser apresentado informação do campo "total de outros rendimentos" da conta do cônjuge.*/
         ASSIGN aux_vloutras = par_vloutras.
         IF  par_inpessoa = 1 THEN
           DO:
              FIND crapcje WHERE crapcje.cdcooper = par_cdcooper   AND
                                 crapcje.nrdconta = par_nrdconta   AND
                                 crapcje.idseqttl = 1
                                 NO-LOCK NO-ERROR.

              IF AVAILABLE crapcje THEN
              DO:
               FOR FIRST crapttl FIELDS(vldrendi)
                   WHERE crapttl.cdcooper = par_cdcooper AND
                         crapttl.nrdconta = crapcje.nrctacje AND
                         crapttl.idseqttl = 1 NO-LOCK:
               END.
                  
               IF  AVAILABLE crapttl THEN
               DO:
                 ASSIGN aux_vloutras = crapttl.VLDRENDI[1] + crapttl.VLDRENDI[2] + 
                                       crapttl.VLDRENDI[3] + crapttl.VLDRENDI[4] + 
                                       crapttl.VLDRENDI[5] + crapttl.VLDRENDI[6].
               END.
             END.
           END.
        
        RUN sistema/generico/procedures/b1wgen0024.p
                            PERSISTENT SET h-b1wgen0024.
        /* Gravar os dados que sao comuns as operacoes de credito */
        RUN grava-dados-proposta IN h-b1wgen0024 (INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                  INPUT par_cdoperad,
                                                  INPUT par_nmdatela,
                                                  INPUT par_idorigem,
                                                  INPUT par_nrdconta,
                                                  INPUT par_idseqttl,
                                                  INPUT par_dtmvtolt,
                                                  /* Emprestimo */
                                                  INPUT 90,
                                                  INPUT par_nrctremp,
                                                  INPUT 0, /* vlempbnd - BNDES */
                                                  INPUT 0, /* qtparbnd - BNDES */
                                                  /* Analise da proposta */
                                                  INPUT aux_nrgarope, /*par_nrgarope, PRJ438 - BUG*/
                                                  INPUT par_nrperger,
                                                  INPUT par_dtcnsspc,
                                                  INPUT par_nrinfcad,
                                                  INPUT par_dtdrisco,
                                                  INPUT par_vltotsfn,
                                                  INPUT par_qtopescr,
                                                  INPUT par_qtifoper,
                                                  INPUT aux_nrliquid, /*par_nrliquid, PRJ438 - BUG*/
                                                  INPUT par_vlopescr,
                                                  INPUT par_vlrpreju,
                                                  INPUT par_nrpatlvr,
                                                  INPUT par_dtoutspc,
                                                  INPUT par_dtoutris,
                                                  INPUT par_vlsfnout,
                                                  /* Rendimentos */
                                                  INPUT par_vlsalari,
                                                  INPUT aux_vloutras, /*par_vloutras, PRJ438*/
                                                  INPUT par_vlalugue,
                                                  INPUT par_vlsalcon,
                                                  INPUT par_nmempcje,
                                                  INPUT par_flgdocje,
                                                  INPUT par_nrctacje,
                                                  INPUT par_nrcpfcje,
                                                  INPUT par_vlmedfat,
                                                  INPUT par_dsobserv,
                                                  INPUT par_dsdrendi,
                                                  /* Bens */
                                                  INPUT par_dsdebens,
                                                  INPUT par_flgerlog,
                                                  INPUT par_dsjusren,
                                                  OUTPUT TABLE tt-erro,
                                                  OUTPUT par_idseqbem).
        DELETE PROCEDURE h-b1wgen0024.
        
        IF   RETURN-VALUE <> "OK"   THEN
             do:
				     FIND FIRST tt-erro NO-ERROR.
               IF   AVAIL tt-erro   THEN
                    aux_dscritic = tt-erro.dscritic.
               ELSE
                    aux_dscritic = "Ocorreram erros na gravacao de dados da proposta".
               EMPTY TEMP-TABLE tt-erro.
               UNDO Gravar, LEAVE Gravar.
             end.
                                                                   
        /* Se Alienaçao ou Hipoteca */
        IF   craplcr.tpctrato = 2   OR craplcr.tpctrato = 3   THEN
             DO:

                 /* Acionar gravação convertida para Oracle */
                 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                 
                 RUN STORED-PROCEDURE pc_grava_alienacao_hipot_prog
                 aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Cooperativa conectada */
                                                      INPUT par_cdoperad, /* Codigo do operador conectado */
                                                      INPUT par_nrdconta, /* Conta do associado */                                                 
                                                      INPUT par_dtmvtolt, /* Data do movimento */
                                                      INPUT 90, /* Tipo Contrato */
                                                      INPUT par_nrctremp, /* Numero Contrato */
                                                      INPUT par_cddopcao, /* Opcao da tela */
                                                      INPUT par_dsdalien, /* Lista de Alienacoes */
                                                      INPUT par_dsinterv, /* Lista de Intervenientes */
                                                      INPUT aux_idpeapro, /* Identificado de Aprovado ou Perda*/
                                                      OUTPUT aux_flperapr,       /* Flag de Perca de Aprovacao */
                                                      OUTPUT 0,                  /* Codigo da critica  */
                                                      OUTPUT "").                /* Descricao da critica */

                 /* Fechar o procedimento para buscarmos o resultado */ 
                 CLOSE STORED-PROC pc_grava_alienacao_hipot_prog
                     aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.                                                
                                                      
                 { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                 ASSIGN aux_flperapr = ""
                        aux_cdcritic = 0
                        aux_dscritic = ""
                        aux_flperapr = pc_grava_alienacao_hipot_prog.par_flperapr
                                          WHEN pc_grava_alienacao_hipot_prog.par_flperapr <> ?
                        aux_cdcritic = pc_grava_alienacao_hipot_prog.par_cdcritic
                                          WHEN pc_grava_alienacao_hipot_prog.par_cdcritic <> ?
                        aux_dscritic = pc_grava_alienacao_hipot_prog.par_dscritic
                                          WHEN pc_grava_alienacao_hipot_prog.par_dscritic <> ?.                 

                  IF aux_cdcritic <> 0 OR aux_dscritic <> ""   THEN
                  DO:
                     UNDO Gravar, LEAVE Gravar.
                  END.
          /*Se teve perda e nas regras anteriores nao tiveram perda, realizar a perda pela alteracao imovel*/
          IF aux_flperapr = "S" AND aux_idpeapro = 0 AND par_inresapr = 1 THEN
          DO:
            IF crawepr.hrenvest > 0 AND crawepr.insitest <> 0 THEN  
            DO:
              ASSIGN aux_interrup = true. /* Interromper na Esteira*/
            END.
            /* Perder a aprovaçao */
            ASSIGN crawepr.insitapr = 0
                   crawepr.cdopeapr = ""
                   crawepr.dtaprova = ?
                   crawepr.hraprova = 0
                   crawepr.insitest = 0
                   aux_idpeapro     = 1. /*Perde aprovacao para as demais regras*/       
             
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT "Perda de aprovacao devido regras alienação ",
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).

          END.
        END.
        /*Se houve a perda de aprovacao pela regra geral*/
        /*Se for alteracao e a decisao estiver diferente de aprovado, realizar perda*/
        IF ( aux_regrager = 1 AND aux_idpeapro = 1 ) OR 
           ( par_cddopcao = "A" AND NOT aux_fleprCDC AND crawepr.insitapr <> 1 )THEN
        DO:
          IF crawepr.hrenvest > 0 AND crawepr.insitest <> 0 THEN  
          DO:
            ASSIGN aux_interrup = true. /* Interromper na Esteira*/
          END.
          /*Realizar perda*/
          ASSIGN crawepr.insitapr = 0
                 crawepr.cdopeapr = ""
                 crawepr.dtaprova = ?
                 crawepr.hraprova = 0
                 crawepr.insitest = 0
                 crawepr.cdopealt = par_cdoperad
                 aux_idpeapro     = 1.
          CREATE tt-msg-confirma.
          ASSIGN tt-msg-confirma.inconfir = 1
                 tt-msg-confirma.dsmensag = "Essa proposta deve ser " + " enviada para Analise de Credito".
                 

        END.
          /* Se devemos interromper a proposta na Esteira */
          IF aux_interrup THEN
          DO:
            
            FIND FIRST crapope  
             WHERE crapope.cdcooper = par_cdcooper
               AND crapope.cdoperad = par_cdoperad
                   NO-LOCK NO-ERROR.
            
            RUN sistema/generico/procedures/b1wgen0195.p
                             PERSISTENT SET h-b1wgen0195.
                     
            /* Enviar Interrupção na Esteira */
            RUN Enviar_proposta_esteira IN h-b1wgen0195        
                              ( INPUT par_cdcooper,
                                INPUT crapope.cdpactra,
                                               INPUT par_nrdcaixa,
                                INPUT par_nmdatela,
                                               INPUT par_cdoperad,
                                INPUT par_idorigem,
                                               INPUT par_nrdconta,
                                               INPUT par_dtmvtolt,
                                INPUT par_dtmvtolt,
                                INPUT par_nrctremp, /* nrctremp */
                                INPUT 0,            /* nrctremp_novo */
                                INPUT "",           /* dsiduser */
                                INPUT 0,            /* flreiflx */
                                INPUT "P",          /* tpenvest */
                               OUTPUT aux_dsmensag,                          
                               OUTPUT aux_cdcritic, 
                               OUTPUT aux_dscritic).

            DELETE OBJECT h-b1wgen0195.

            /* Ignorar erro de "%Proposta nao encontrada" */ 
            IF RETURN-VALUE = "NOK" AND 
               NOT LOWER(aux_dscritic) MATCHES "*proposta nao encontrada*" AND
               NOT LOWER(aux_dscritic) MATCHES "*proposta nao permite interromper o fluxo*" AND
               NOT LOWER(aux_dscritic) MATCHES "*produto cdc nao integrado*" THEN
            DO:
              IF aux_cdcritic = 0 AND 
                 aux_dscritic = "" THEN
              DO:
                ASSIGN aux_dscritic = "Nao foi possivel enviar cancelamento da " +
                                      "proposta para Analise de Credito.".
             END.
            END.
        END. /*IF aux_interrup THEN*/
        /*Se perde devido a garantia de aplicacao*/
        IF aux_reggaran = 1 AND aux_idpeapro = 1 THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT "Proposta perdeu a aprovaçao devido alteracao na garantia de aplicacao",
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
          /*Realizar perda*/
          ASSIGN crawepr.insitapr = 0
                 crawepr.cdopeapr = ""
                 crawepr.dtaprova = ?
                 crawepr.hraprova = 0
                 crawepr.insitest = 0
                 crawepr.cdopealt = par_cdoperad
                 aux_idpeapro     = 1.

                         
        END. 
/* Tratar as mensagens da aprovacao */
        RUN altera-valor-proposta (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_nmdatela,
                                   INPUT par_idorigem,
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT par_dtmvtolt,
                                   INPUT par_nrctremp,
                                   INPUT par_flgcmtlc,
                                   INPUT par_vlemprst,
                                   INPUT par_vlpreemp,
                                   INPUT par_vlutiliz,
                                   INPUT par_vlpreant,
                                   INPUT par_vllimapv,
                                   INPUT par_flgerlog,
                                   /*INPUT "TP",      Altera Toda Proposta */
                                   INPUT par_dsdopcao,
                                   INPUT par_dtlibera,
                                   INPUT par_idfiniof,
                                   INPUT par_dscatbem,
                                   INPUT par_inresapr,
                                   /* PRJ 438 - Ajuste para alterar a data pagto dentro da proc altera-valor-proposta */
                                   INPUT par_dtdpagto,
                                 INPUT-OUTPUT aux_idpeapro,
                                   OUTPUT par_flmudfai,
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT TABLE tt-msg-confirma).


        IF   RETURN-VALUE <> "OK"   THEN
             do:
                                     FIND FIRST tt-erro NO-ERROR.
               IF   AVAIL tt-erro   THEN
                    aux_dscritic = tt-erro.dscritic.
               ELSE
                    aux_dscritic = "Ocorreram erros na alteracao do valor da proposta".
               EMPTY TEMP-TABLE tt-erro.
             UNDO Gravar, LEAVE Gravar.
        END.

      IF aux_idpeapro = 1 THEN
      DO:
        /* Verificar se a Esteira esta em contigencia para a cooperativa*/
              { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
          RUN STORED-PROCEDURE pc_param_sistema aux_handproc = PROC-HANDLE
             (INPUT "CRED",           /* pr_nmsistem */
              INPUT par_cdcooper,     /* pr_cdcooper */
              INPUT "CONTIGENCIA_ESTEIRA_IBRA",  /* pr_cdacesso */
              OUTPUT ""               /* pr_dsvlrprm */
              ).

          CLOSE STORED-PROCEDURE pc_param_sistema WHERE PROC-HANDLE = aux_handproc.
          { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

              ASSIGN aux_contigen = FALSE.
              IF pc_param_sistema.pr_dsvlrprm = "1" then
                 ASSIGN aux_contigen = TRUE.
                 
        CREATE tt-msg-confirma.
        ASSIGN tt-msg-confirma.inconfir = 1
               tt-msg-confirma.dsmensag =  IF aux_contigen THEN
                                           "Essa proposta deve ser" +
                                           " aprovada na tela CMAPRV"
                                           ELSE 
                                           "Essa proposta deve ser" +
                                           " enviada para Analise de Credito".
      END.
        
      /*Para inclusão, caso a proposta não esteja aprovada no final, deve apresentar a mensagem -- PRJ438*/
      IF aux_idpeapro = 0 AND crawepr.insitapr = 0 AND par_cddopcao = "I" 
         AND par_cdcooper <> 3 THEN
      DO:
        CREATE tt-msg-confirma.
        ASSIGN tt-msg-confirma.inconfir = 1
               tt-msg-confirma.dsmensag = "Essa proposta deve ser " + " enviada para Analise de Credito".
      END.
      /* Quando inclusao*/
      IF par_cddopcao = "I" THEN
      DO:
        ASSIGN crawepr.vlempinc = crawepr.vlemprst
               crawepr.vlpreinc = crawepr.vlpreemp.
             end.
        /* Atualiza a data de liberacao */
        ASSIGN crawepr.dtlibera = par_dtlibera.
        
        RUN sistema/generico/procedures/b1wgen0024.p
                             PERSISTENT SET h-b1wgen0024.

        /* Gravar os dados cadastrais (Tela Contas) do cooperado */
        RUN grava-dados-cadastro IN h-b1wgen0024 (INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                  INPUT par_cdoperad,
                                                  INPUT "PROP.EMPREST",
                                                  INPUT par_idorigem,
                                                  INPUT par_nrdconta,
                                                  INPUT par_idseqttl,
                                                  INPUT par_dtmvtolt,
                                                  INPUT par_inpessoa,
                                                  INPUT par_dsdebens,
                                                  INPUT par_dsdrendi,
                                                  INPUT par_vlsalari,
                                                  INPUT par_vlalugue,
                                                  INPUT par_vlsalcon,
                                                  INPUT par_nmempcje,
                                                  INPUT par_perfatcl,
                                                  INPUT par_dsdfinan,
                                                  INPUT par_dsjusren,
                                                  OUTPUT TABLE tt-erro).

        DELETE PROCEDURE h-b1wgen0024.

        IF   RETURN-VALUE <> "OK"   THEN
             do:
				     FIND FIRST tt-erro NO-ERROR.
               IF   AVAIL tt-erro   THEN
                    aux_dscritic = tt-erro.dscritic.
               ELSE
                    aux_dscritic = "Ocorreram erros na gravacao dos dados do cadastro".
               EMPTY TEMP-TABLE tt-erro.
               UNDO Gravar, LEAVE Gravar.
             end.
        RUN sistema/generico/procedures/b1wgen0043.p
                        PERSISTENT SET h-b1wgen0043.

        /** Gravar rating do cooperado nas tabelas crapttl ou crapjur **/
        RUN grava_rating IN h-b1wgen0043 (INPUT  par_cdcooper,
                                          INPUT  par_cdagenci,
                                          INPUT  par_nrdcaixa,
                                          INPUT  par_cdoperad,
                                          INPUT  par_dtmvtolt,
                                          INPUT  par_nrdconta,
                                          INPUT  par_inpessoa,
                                          INPUT  par_nrinfcad,
                                          INPUT  par_nrpatlvr,
                                          INPUT  par_nrperger,
                                          INPUT  par_idorigem,
                                          INPUT  par_idseqttl,
                                          INPUT  par_nmdatela,
                                          INPUT  FALSE,
                                          OUTPUT TABLE tt-erro).
        DELETE PROCEDURE h-b1wgen0043.

        IF   RETURN-VALUE <> "OK"   THEN 
             do:
				     FIND FIRST tt-erro NO-ERROR.
               IF   AVAIL tt-erro   THEN
                    aux_dscritic = tt-erro.dscritic.
               ELSE
                    aux_dscritic = "Ocorreram erros na gravacao do rating".
               EMPTY TEMP-TABLE tt-erro.
               UNDO Gravar, LEAVE Gravar.
             end.
        IF  crawepr.tpemprst <> 1  AND 
            crawepr.tpemprst <> 2  THEN
            DO:
                RUN sistema/generico/procedures/b1wgen0084.p
                    PERSISTENT SET h-b1wgen0084.

                RUN exclui_parcelas_proposta IN h-b1wgen0084 (
                    INPUT par_cdcooper,
                    INPUT par_cdagenci,
                    INPUT par_nrdcaixa,
                    INPUT par_cdoperad,
                    INPUT par_nmdatela,
                    INPUT par_idorigem,
                    INPUT par_nrdconta,
                    INPUT par_idseqttl,
                    INPUT par_dtmvtolt,
                    INPUT par_flgerlog,
                    INPUT par_nrctremp,
                    OUTPUT TABLE tt-erro).

                DELETE PROCEDURE h-b1wgen0084.

                IF   RETURN-VALUE <> "OK"   THEN
             do:
				     FIND FIRST tt-erro NO-ERROR.
               IF   AVAIL tt-erro   THEN
                    aux_dscritic = tt-erro.dscritic.
               ELSE
                    aux_dscritic = "Ocorreram erros na exclusao das parcelas da proposta".
               EMPTY TEMP-TABLE tt-erro.
              UNDO Gravar, LEAVE Gravar.
             end.
             END.
        /* Verificar se a conta pertence ao grupo economico novo */	
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_obtem_mensagem_grp_econ_prg
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                              ,INPUT par_nrdconta
                                              ,""
                                              ,0
                                              ,"").

        CLOSE STORED-PROC pc_obtem_mensagem_grp_econ_prg
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_cdcritic  = 0
               aux_dscritic  = ""
               aux_cdcritic  = INT(pc_obtem_mensagem_grp_econ_prg.pr_cdcritic) WHEN pc_obtem_mensagem_grp_econ_prg.pr_cdcritic <> ?
               aux_dscritic  = pc_obtem_mensagem_grp_econ_prg.pr_dscritic WHEN pc_obtem_mensagem_grp_econ_prg.pr_dscritic <> ?
               aux_mensagens = pc_obtem_mensagem_grp_econ_prg.pr_mensagens WHEN pc_obtem_mensagem_grp_econ_prg.pr_mensagens <> ?.
                        
        IF aux_cdcritic > 0 THEN
           DO:
               UNDO Gravar, LEAVE Gravar.
           END.
        ELSE IF aux_dscritic <> ? AND aux_dscritic <> "" THEN
          DO:
              UNDO Gravar, LEAVE Gravar.
          END.

        IF aux_mensagens <> ? AND aux_mensagens <> "" THEN
           DO:
               CREATE tt-msg-confirma.                        
               ASSIGN tt-msg-confirma.inconfir = 4
                      tt-msg-confirma.dsmensag = aux_mensagens.
           END.
        
        /*Valida a criaçao de seguro prestamista - PRJ438 - Paulo Martins (Mouts)*/
        IF par_inpessoa = 1 AND NOT aux_fleprCDC THEN /*INC0026220 não gera para CDC*/
        DO:
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        RUN STORED-PROCEDURE pc_cria_proposta_sp
                             aux_handproc = PROC-HANDLE NO-ERROR
                      (INPUT par_cdcooper,      /* Cooperativa */
                       INPUT par_nrdconta,      /* Número da conta */
                       INPUT par_nrctremp,      /* Número emrepstimo */
                       INPUT par_cdagenci,      /* Agencia */
                       INPUT par_nrdcaixa,      /* Caixa */
                       INPUT par_cdoperad,      /* Operador   */
                       INPUT par_nmdatela,      /* Tabela   */
                       INPUT par_idorigem,      /* Origem  */
                      OUTPUT 0,
                      OUTPUT "").
         
        CLOSE STORED-PROC pc_cria_proposta_sp 
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
     
        ASSIGN aux_cdcritic = pc_cria_proposta_sp.pr_cdcritic
                                 WHEN pc_cria_proposta_sp.pr_cdcritic <> ?
               aux_dscritic = pc_cria_proposta_sp.pr_dscritic
                                 WHEN pc_cria_proposta_sp.pr_dscritic <> ?.
        IF aux_cdcritic > 0 OR aux_dscritic <> '' THEN
          DO:
            UNDO Gravar, LEAVE Gravar.
          END.
       END.

    END. /* Fim Grava- Fim TRANSACTION */
     
    IF   aux_dscritic <> ""  OR
         aux_cdcritic <> 0   THEN
         DO:
             IF  par_flgerlog  THEN
                 RUN proc_gerar_log (INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid).

             IF   NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).
                 
             RETURN "NOK".
         END.
    /* Chamar apos o fechamento da transacao pois depende de valores   */
    /* anteriores no Oracle. Os erros aqui dentro sao retornados na    */
    /* tt-msg-confirma pois nao podem comprometer o resto da execucao  */
    /* PJ298.2.2 - Liberado apenas para migracao de contratos*/
    IF par_nmdatela <> "MIGRACAO" THEN
      DO:    
    RUN sistema/generico/procedures/b1wgen0191.p  PERSISTENT SET h-b1wgen0191.
                      
    RUN Verifica_Consulta_Biro IN h-b1wgen0191 (INPUT par_cdcooper,
                                                INPUT par_nrdconta,
                                                INPUT 1, /* inprodut*/
                                                INPUT par_nrctremp,
                                                INPUT par_cdoperad,
                                                INPUT par_cddopcao,
                                         INPUT-OUTPUT TABLE tt-msg-confirma,
                                               OUTPUT par_flmudfai).          
    DELETE PROCEDURE h-b1wgen0191.
      END.
    IF  par_flgerlog  THEN
        DO:
        
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).
                           
           RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                    INPUT "nrctremp",
                                    INPUT par_nrctremp,
                                    INPUT par_nrctremp).


           /* Bens alienados separados por pipe JMD*/
           DO aux_contador = 1 TO NUM-ENTRIES(par_dsdalien,"|"):

             ASSIGN reg_dsdregis = ENTRY(aux_contador,par_dsdalien,"|").
			 
             IF (NUM-ENTRIES(reg_dsdregis, ";") >= 16) THEN
                DO:
                 IF ENTRY(16,reg_dsdregis,";") <> "0" AND
				ENTRY(16,reg_dsdregis,";") <> "" THEN
				DO:
			      RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                           INPUT "Garantia: "+ STRING(aux_contador), /*ENTRY(15,reg_dsdregis,";"),*/
                                           INPUT "",
                                           INPUT "Aprovado Coordenador: " + ENTRY(16,reg_dsdregis,";")).
		        END.
	       END.	
        END.                   
        END.                   
    
        /*Valida a criaçao de seguro prestamista - PRJ438 - Paulo Martins (Mouts)*/
        IF par_inpessoa = 1 THEN
        DO:
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        RUN STORED-PROCEDURE pc_cria_proposta_sp
                             aux_handproc = PROC-HANDLE NO-ERROR
                      (INPUT par_cdcooper,      /* Cooperativa */
                       INPUT par_nrdconta,      /* Número da conta */
                       INPUT par_nrctremp,      /* Número emrepstimo */
                       INPUT par_cdagenci,      /* Agencia */
                       INPUT par_nrdcaixa,      /* Caixa */
                       INPUT par_cdoperad,      /* Operador   */
                       INPUT par_nmdatela,      /* Tabela   */
                       INPUT par_idorigem,      /* Origem  */
                      OUTPUT 0,
                      OUTPUT "").

        CLOSE STORED-PROC pc_cria_proposta_sp 
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
     
        ASSIGN aux_cdcritic = pc_cria_proposta_sp.pr_cdcritic
                                 WHEN pc_cria_proposta_sp.pr_cdcritic <> ?
               aux_dscritic = pc_cria_proposta_sp.pr_dscritic
                                 WHEN pc_cria_proposta_sp.pr_dscritic <> ?.
        IF aux_cdcritic > 0 OR aux_dscritic <> '' THEN
                        DO:
                          CREATE tt-erro.
                          ASSIGN tt-erro.cdcritic = aux_cdcritic
                                         tt-erro.dscritic = aux_dscritic.

                          RETURN "NOK".

        END.                   
        END.                   
    


    RETURN "OK".

END PROCEDURE.  /* grava proposta completa */


/**************************************************************************
 Procedure para alterar o valor da proposta de emprestimo.
 Opcao de Alterar na rotina Emprestimo da tela ATENDA.
 E utilizada na Inclusao da proposta.
**************************************************************************/
PROCEDURE altera-valor-proposta:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE INIT 0                    NO-UNDO. /*Inicializaçao - Chamado 660371*/
    DEF  INPUT PARAM par_flgcmtlc AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlpreemp AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlutiliz AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vleprori AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vllimapv AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dsdopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtlibera AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idfiniof AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dscatbem AS CHAR                           NO-UNDO.
    /* Indica se permite reiniciar fluxo de aprovaçao default 1*/
    DEF  INPUT PARAM par_inresapr AS INT                            NO-UNDO.    
    /* PRJ 438 - Ajuste para alterar a data pagto dentro da proc altera-valor-proposta */
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_idpeapro AS INT                    NO-UNDO.
    DEF OUTPUT PARAM par_flmudfai AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.


    DEF VAR          aux_contador AS INTE                           NO-UNDO.
    DEF VAR          aux_vlemprst LIKE crawepr.vlemprst             NO-UNDO.
    DEF VAR          aux_dsratori LIKE crawepr.dsratori             NO-UNDO.
    DEF VAR          aux_vlpreemp LIKE crawepr.vlpreemp             NO-UNDO.
    DEF VAR          aux_vlprecar LIKE crawepr.vlprecar             NO-UNDO.
    DEF VAR          aux_insitapr LIKE crawepr.insitapr             NO-UNDO.
    DEF VAR          aux_cdopeapr LIKE crawepr.cdopeapr             NO-UNDO.
    DEF VAR          aux_tpctrato LIKE craplcr.tpctrato             NO-UNDO.
    DEF VAR          aux_txdiaria AS DECI                           NO-UNDO.
    DEF VAR          aux_txmensal AS DECI                           NO-UNDO.
    DEF VAR          aux_vliofepr AS DECI                           NO-UNDO.
    DEF VAR          aux_vlrtarif AS DECI                           NO-UNDO.
    DEF VAR          aux_vllibera AS DECI                           NO-UNDO.
    DEF VAR          aux_qtdiacar AS INTE                           NO-UNDO.
    DEF VAR          aux_vlajuepr AS DECI                           NO-UNDO.
    DEF VAR          aux_dtaprova LIKE crawepr.dtaprova             NO-UNDO.
    DEF VAR          aux_hraprova LIKE crawepr.hraprova             NO-UNDO.
    DEF VAR          aux_dtlibera AS DATE                           NO-UNDO.
    DEF VAR          aux_dsoperac AS CHAR                           NO-UNDO.
    DEF VAR          aux_dsdmensa AS CHAR                           NO-UNDO.
    DEF VAR          aux_percetop AS DECI                           NO-UNDO.
    DEF VAR          aux_txcetmes AS DECI                           NO-UNDO.
    DEF VAR          aux_nivrisco AS CHAR                           NO-UNDO.
    DEF VAR          aux_percamnt AS DECI                           NO-UNDO.
    DEF VAR          aux_percatua AS DECI                           NO-UNDO.
    DEF VAR          aux_flapvpor AS LOGI                           NO-UNDO.
    DEF VAR          aux_idcarga  AS INTE                           NO-UNDO.
    DEF VAR          aux_contigen AS LOGI                           NO-UNDO.
    DEF VAR          aux_insitest LIKE crawepr.insitest             NO-UNDO.
    DEF VAR          aux_interrup AS LOGI                           NO-UNDO.
    DEF VAR          aux_inobriga AS CHAR                           NO-UNDO.
    DEF VAR          aux_dserro   AS CHAR                           NO-UNDO.
    DEF VAR          aux_idpeapro AS INT                            NO-UNDO.
    DEF VAR          aux_qtdias_carencia AS INTE                    NO-UNDO.

    DEF VAR          h-b1wgen0110 AS HANDLE                         NO-UNDO.
    DEF VAR          h-b1wgen0191 AS HANDLE                         NO-UNDO.
    DEF VAR          h-b1wgen0043 AS HANDLE                         NO-UNDO.
    DEF VAR          h-b1wgen0188 AS HANDLE                         NO-UNDO.
    DEF VAR          aux_cdcritic AS INTE                           NO-UNDO.
    DEF VAR          aux_dscritic AS CHAR                           NO-UNDO.
    DEF VAR          aux_dstransa AS CHAR                           NO-UNDO.
    DEF VAR          aux_dsorigem AS CHAR                           NO-UNDO.
    DEF VAR          aux_dsctrliq AS CHAR                           NO-UNDO.
    DEF VAR          aux_fleprCDC AS LOGI                           NO-UNDO.
    
	/* PJ438 controle de log para alteracao de data de vencimento */
	DEF VAR          aux_dtvencto AS DATE                           NO-UNDO.
	DEF VAR          aux_dtdpagto AS DATE                           NO-UNDO.
	DEF VAR          aux_msg_log  AS CHAR                           NO-UNDO.
    
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-msg-confirma.

    IF par_nmdatela = "AUTOCDC" OR 
       par_cdoperad = "AUTOCDC" THEN
      ASSIGN aux_fleprCDC = TRUE.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Alterar o valor da proposta de credito"
           aux_interrup = FALSE
           aux_inobriga = "N"
		   aux_dtvencto = par_dtdpagto
		   aux_dtdpagto = par_dtdpagto
		   aux_msg_log  = "". 

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapass THEN
       DO:
           ASSIGN aux_cdcritic = 9.

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1, /*sequencia*/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".
       END.

    /* Verificar se a Esteira esta em contigencia para a cooperativa*/
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_param_sistema aux_handproc = PROC-HANDLE
       (INPUT "CRED",           /* pr_nmsistem */
        INPUT par_cdcooper,     /* pr_cdcooper */
        INPUT "CONTIGENCIA_ESTEIRA_IBRA",  /* pr_cdacesso */
        OUTPUT ""               /* pr_dsvlrprm */
        ).

    CLOSE STORED-PROCEDURE pc_param_sistema WHERE PROC-HANDLE = aux_handproc.
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_contigen = FALSE.
        IF pc_param_sistema.pr_dsvlrprm = "1" then
           ASSIGN aux_contigen = TRUE.

    Grava_valor:
    DO WHILE TRUE TRANSACTION ON ERROR UNDO Grava_valor, LEAVE Grava_valor:

        DO  aux_contador = 1 TO 10:

            FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                               crawepr.nrdconta = par_nrdconta   AND
                               crawepr.nrctremp = par_nrctremp
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAIL crawepr   THEN
                 IF   LOCKED crawepr   THEN
                      DO:
                          aux_cdcritic = 371.
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.
                 ELSE
                      DO:
                          aux_cdcritic = 510.
                          LEAVE.
                      END.

            aux_cdcritic = 0.
            LEAVE.

        END.

        IF  aux_cdcritic <> 0    OR
            aux_dscritic <> ""   THEN
            LEAVE.

			
	    /* PJ438 Sprint 5 trecho movido para esse ponto par_dsdopcao SVP */
    /* Quando for apenas alteracao do valor */
    IF par_dsdopcao = "SVP" THEN
       DO:
          IF NOT VALID-HANDLE(h-b1wgen0110) THEN
             RUN sistema/generico/procedures/b1wgen0110.p PERSISTENT SET h-b1wgen0110.

          /*Monta a mensagem da operacao para envio no e-mail*/
          ASSIGN aux_dsoperac = "Tentativa de alterar o valor da proposta de " +
                                "emprestimo/financiamento na conta "           +
                                STRING(crapass.nrdconta,"zzzz,zzz,9")          +
                                " - CPF/CNPJ "                                 +
                               (IF crapass.inpessoa = 1 THEN
                                   STRING((STRING(crapass.nrcpfcgc,
                                           "99999999999")),"xxx.xxx.xxx-xx")
                                ELSE
                                   STRING((STRING(crapass.nrcpfcgc,
                                                 "99999999999999")),
                                                 "xx.xxx.xxx/xxxx-xx")).

          /*Verifica se o associado esta no cadastro restritivo*/
          RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_nmdatela,
                                            INPUT par_dtmvtolt,
                                            INPUT par_idorigem,
                                            INPUT crapass.nrcpfcgc,
                                            INPUT crapass.nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT TRUE, /*bloqueia operacao*/
                                            INPUT 10, /*cdoperac*/
                                            INPUT aux_dsoperac,
                                            OUTPUT TABLE tt-erro).

          IF VALID-HANDLE(h-b1wgen0110) THEN
             DELETE PROCEDURE(h-b1wgen0110).

          IF RETURN-VALUE <> "OK" THEN
             DO:
                IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                   DO:
                      ASSIGN aux_dscritic = "Nao foi possivel verificar o " +
                                            "cadastro restritivo.".

                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1, /*sequencia*/
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).

                   END.

                RETURN "NOK".

                      END.

        END.
	   /* fim doo move PJ438 Sprint 5 */


        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        /* Verificar se a Proposta possui obrigatoriedade de passar pela analise automatica */ 
        RUN STORED-PROCEDURE pc_obrigacao_analise_automatic
         aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                              INPUT crapass.inpessoa, /* Tipo da Pessoa */
                                              INPUT crawepr.cdfinemp, /* Código da finalidade de crédito */
                                              INPUT crawepr.cdlcremp, /* Código da linha de crédito */
                                             OUTPUT "",           /* Obrigaçao de análise automática (S/N) */
                                             OUTPUT 0,            /* Código da crítica */
                                             OUTPUT "").          /* Descrição da crítica */
        
        /* Fechar o procedimento para buscarmos o resultado */ 
        CLOSE STORED-PROC pc_obrigacao_analise_automatic
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }


        ASSIGN aux_inobriga = pc_obrigacao_analise_automatic.pr_inobriga
                                 WHEN pc_obrigacao_analise_automatic.pr_inobriga <> ?
               aux_cdcritic = pc_obrigacao_analise_automatic.pr_cdcritic
                                 WHEN pc_obrigacao_analise_automatic.pr_cdcritic <> ?
               aux_dscritic = pc_obrigacao_analise_automatic.pr_dscritic
                                 WHEN pc_obrigacao_analise_automatic.pr_dscritic <> ?.

        IF aux_cdcritic > 0 OR 
           aux_dscritic <> '' THEN
           LEAVE.
        
        ASSIGN  aux_insitapr = crawepr.insitapr
                aux_cdopeapr = crawepr.cdopeapr
                aux_dtaprova = crawepr.dtaprova
                aux_hraprova = crawepr.hraprova
                aux_insitest = crawepr.insitest.            
            
        FOR crappre FIELDS(cdfinemp) 
                    WHERE crappre.cdcooper = par_cdcooper     AND
                          crappre.inpessoa = crapass.inpessoa
                          NO-LOCK: END.
    
        /* Verifica se o emprestimo eh pre-aprovado */
        IF AVAIL crappre AND crawepr.cdfinemp = crappre.cdfinemp THEN
           DO:
               IF NOT VALID-HANDLE(h-b1wgen0188) THEN
                  RUN sistema/generico/procedures/b1wgen0188.p 
                      PERSISTENT SET h-b1wgen0188.

               /* Verifica se existe limite disponível */
               RUN busca_dados IN h-b1wgen0188
                               (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT par_cdoperad,
                                INPUT par_nmdatela,
                                INPUT par_idorigem,
                                INPUT par_nrdconta,
                                INPUT par_idseqttl,
                                INPUT 0,
                                OUTPUT TABLE tt-dados-cpa,
                                OUTPUT TABLE tt-erro).

               FIND tt-dados-cpa NO-LOCK NO-ERROR.
               IF  AVAIL tt-dados-cpa THEN
                   DO:
                       ASSIGN aux_idcarga  = tt-dados-cpa.idcarga.
                   END.
               
               IF aux_idcarga > 0 THEN
                  DO:
          RUN proc_gerar_log (INPUT par_cdcooper,
                              INPUT par_cdoperad,
                              INPUT "",
                              INPUT aux_dsorigem,
                              INPUT "Emprestimo pre-aprovado, aprovacao automatica",
                              INPUT TRUE,
                              INPUT par_idseqttl,
                              INPUT par_nmdatela,
                              INPUT par_nrdconta,
                             OUTPUT aux_nrdrowid).
                            
          RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                   INPUT "Contrato",
                                   INPUT "ND",
                                   INPUT par_nrctremp).                  
                     ASSIGN crawepr.insitapr =  1
                            crawepr.cdopeapr = par_cdoperad
                            crawepr.dtaprova = par_dtmvtolt
                            crawepr.hraprova = TIME
                            crawepr.insitest = 3
                 crawepr.flgpreap = 1
                 par_idpeapro     = 2. /*Aprovado automaticamente*/
    
                     CREATE tt-msg-confirma.
                     ASSIGN tt-msg-confirma.inconfir = 1
                            tt-msg-confirma.dsmensag = "Essa proposta foi aprovada automaticamente."
							aux_msg_log = "Emprestimo Aprovado Pois é Pré Aprovado".
    
                  END. /* END  IF aux_idcarga > 0 THEN */
    
           END. /* END IF par_cdfinemp = crappre.cdfinemp */
        ELSE
           DO:
             
             /* Identifica se deve reiniciar o fluxo de aprovaçao */
             IF par_inresapr = 1 THEN DO:
            
           
               /* Verificar se a linha aprova automaticamente */
               FIND FIRST craplcr
                   WHERE craplcr.cdcooper = crawepr.cdcooper AND
                         craplcr.cdlcremp = crawepr.cdlcremp
                                                 NO-LOCK NO-ERROR.

               IF AVAIL craplcr AND craplcr.flgdisap AND NOT aux_fleprCDC THEN
                  DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT "Linha de credito com aprovacao automatica ",
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
                              
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Contrato",
                                     INPUT "ND",
                                     INPUT par_nrctremp).                  
                     ASSIGN crawepr.insitapr = 1
                            crawepr.cdopeapr = par_cdoperad
                            crawepr.dtaprova = par_dtmvtolt
                            crawepr.hraprova = TIME
                   crawepr.insitest = 3
                   par_idpeapro     = 2.

                     CREATE tt-msg-confirma.
                     ASSIGN tt-msg-confirma.inconfir = 1
                            tt-msg-confirma.dsmensag =
                                       "Essa proposta foi aprovada automaticamente."
							aux_msg_log = "Aprovado pela Linha de crédito".
                  END. /* IF AVAIL craplcr AND craplcr.flgdisap THEN */
               ELSE
                  DO:
        /* Verificar se é contrato de portabilidade */
                      FOR FIRST crapfin FIELDS(tpfinali) 
                          WHERE crapfin.cdcooper = crawepr.cdcooper AND
                           crapfin.cdfinemp = crawepr.cdfinemp
                      NO-LOCK: END.

                    IF AVAIL crapfin AND crapfin.tpfinali = 2 THEN
            DO:            
               IF  crawepr.insitapr = 1 OR
                   crawepr.insitapr = 3 THEN
                   DO:                        
                        /* Calcula percentual de aumento do novo valor de emprestimo */
                        ASSIGN aux_percamnt = ((par_vlemprst - crawepr.vlemprst) * 100)
                                               / crawepr.vlemprst.            
        
                        /* Busca percentual de atualizacao de portabilidade */
                        FIND craptab WHERE craptab.cdcooper = 3             AND
                                           craptab.nmsistem = "CRED"        AND
                                           craptab.tptabela = "USUARI"      AND
                                           craptab.cdacesso = "PAREMPCTL"   AND
                                           craptab.cdempres = 11
                                           NO-LOCK NO-ERROR.
        
                        IF  AVAIL craptab THEN
                            DO:
                                ASSIGN aux_percatua = DECI(SUBSTRING(craptab.dstextab, 13, 6)).
        
                                IF  aux_percamnt < aux_percatua AND
                                    aux_percamnt > (aux_percatua * (-1)) THEN
                                    DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT "",
                                        INPUT aux_dsorigem,
                                        INPUT "Contrato de portabilidade, nao perde aprovacao",
                                        INPUT TRUE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
                                      
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Contrato",
                                             INPUT "ND",
                                             INPUT par_nrctremp).
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Percentual Portabilidade",
                                             INPUT "ND",
                                             INPUT aux_percatua). 
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Calculo percentual de aumento do valor de emp",
                                             INPUT "ND",
                                             INPUT aux_percamnt).                                           
                                        ASSIGN /*crawepr.cdopeapr = mantera operador da CMAPRV*/
                                               crawepr.dtaprova = par_dtmvtolt
                                                             crawepr.hraprova = TIME
                           crawepr.insitest = 3
                           par_idpeapro     = 2.
                                        
                                        CREATE tt-msg-confirma.
                                        ASSIGN tt-msg-confirma.inconfir = 1
                                               tt-msg-confirma.dsmensag =
                                                       "Proposta de portabilidade aprovada " + 
                                                       "automaticamente."
										       aux_msg_log = "Proposta de portabilidade aprovada automaticamente".
													   
													
                                    END.
                                ELSE
                                    DO:
                                       CREATE tt-msg-confirma.
                                       ASSIGN tt-msg-confirma.inconfir = 1
                                              tt-msg-confirma.dsmensag =
                                                                        IF aux_contigen THEN
                                              "Essa proposta deve ser" +
                                                                           " aprovada na tela CMAPRV"
                                                                        ELSE 
                                                                           "Essa proposta deve ser" +
                                                             " enviada para Analise de Credito".

                                                    /* Se nao estiver em contigencia e a proposta estava na Esteira */
                                                    IF NOT aux_contigen AND crawepr.hrenvest > 0 AND aux_insitest <> 0 THEN  
                                                    DO:
                                                       ASSIGN aux_interrup = true. /* Interromper na Esteira*/
                                                    END.

                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT "",
                                        INPUT aux_dsorigem,
                                        INPUT "Perda de aprovacao para portabilidade",
                                        INPUT TRUE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
                                      
                      RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                               INPUT "Contrato",
                                               INPUT "ND",
                                               INPUT par_nrctremp). 
                                               
                      RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                               INPUT "Informacao",
                                               INPUT "ND",
                                               INPUT "Aprovar na tela CMAPRV perc de aumento maior que permitido").                                                
                                        ASSIGN crawepr.insitapr = 0
                                               crawepr.cdopeapr = ""
                                               crawepr.dtaprova = ?
                                                             crawepr.hraprova = 0
                           crawepr.insitest = 0
                           par_idpeapro     = 1.
															 
										ASSIGN aux_msg_log = "Aprovar na tela CMAPRV perc de aumento maior que permitido".
										
                                    END.
                            END.                        
                        ELSE
                            DO:
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT "",
                                      INPUT aux_dsorigem,
                                      INPUT "Proposta de portabilidade aprovada automaticamente",
                                      INPUT TRUE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                     OUTPUT aux_nrdrowid).
                                    
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Contrato",
                                             INPUT "ND",
                                             INPUT par_nrctremp).   
                                             
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Informacao",
                                             INPUT "ND",
                                             INPUT "Proposta de portabilidade aprovada automaticamente").                                              
                    
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Complemento",
                                             INPUT "ND",
                                             INPUT "Nao existe parametro de perc. para esta portabilidade").                                              
                                ASSIGN /*crawepr.cdopeapr = mantera operador da CMAPRV*/
                                       crawepr.dtaprova = par_dtmvtolt
                                                     crawepr.hraprova = TIME
                         crawepr.insitest = 3
                         par_idpeapro     = 2.
                                
                                       CREATE tt-msg-confirma.
                                       ASSIGN tt-msg-confirma.inconfir = 1
                                              tt-msg-confirma.dsmensag =
                                               "Proposta de portabilidade aprovada " + 
                                               "automaticamente."
											  aux_msg_log = "Proposta de portabilidade aprovada automaticamente ".
                                    END.                                                                        
                            END.                        
               ELSE
                   DO:
                      /*CREATE tt-msg-confirma.
                      ASSIGN tt-msg-confirma.inconfir = 1
                             tt-msg-confirma.dsmensag =
                                                       IF aux_contigen THEN
                             "Essa proposta deve ser" +
                                                          " aprovada na tela CMAPRV"
                                                       ELSE 
                                                          "Essa proposta deve ser" +
                                            " enviada para Analise de Credito".*/

                                         /* Se nao estiver em contigencia e a proposta estava na Esteira */
                                         IF NOT aux_contigen AND crawepr.hrenvest > 0 AND aux_insitest <> 0 THEN  
                                         DO:
                                             ASSIGN aux_interrup = true. /* Interromper na Esteira*/
                                         END.   
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT "",
                                    INPUT aux_dsorigem,
                                    INPUT "Contrato de portabilidade deve ser enviada para Analise de Credito",
                                    INPUT TRUE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                  
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "Contrato",
                                         INPUT "ND",
                                         INPUT par_nrctremp).

                       ASSIGN crawepr.insitapr = 0
                              crawepr.cdopeapr = ""
                              crawepr.dtaprova = ?
                                            crawepr.hraprova = 0
                              crawepr.insitest = 0
                              par_idpeapro     = 1.
											
						ASSIGN aux_msg_log = "Essa proposta deve ser aprovada tpfinali = 2".
                   END.                
                       END. /* IF AVAIL crapfin AND crapfin.tpfinali = 2 THEN */
        ELSE            
            DO:
			/* PJ438 Sprint 5 crawepr.vlpreemp <> par_vlpreemp */
         IF par_dsdopcao = "SVP" THEN /*AND crawepr.vlpreemp <> par_vlpreemp THEN */
           DO:
              /** M438 - Nova regra  para determinar perda de aprovaçao com a 
                         alteraçao de valor da proposta quando aprovada e ter 
                         valores nos campos originais, regra nova senao
                         regra antiga
              **/
              IF crawepr.vlempori > 0 AND
                 crawepr.vlpreori > 0 AND
                 crawepr.insitapr = 1 THEN
              DO:
              
              ASSIGN aux_idpeapro = 0.
              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                RUN STORED-PROCEDURE pc_processa_perda_aprov
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /*Codigo da Cooperativa*/
                                                     INPUT par_nrdconta, /*Numero da conta*/
                                                     INPUT par_nrctremp, /*Numero do contrato de emprestimo*/
                                                     INPUT "S",  /* C - Consulta ou P - Processo de perda */
                                                     INPUT par_vlemprst,
                                                     INPUT par_vlpreemp,                                                     
                                                     INPUT par_cdagenci, /*Codigo Agencia*/
                                                     INPUT par_nrdcaixa, /*Numero Caixa*/
                                                     INPUT par_cdoperad, /*Codigo Operador*/
                                                     INPUT 90, /*Tipo Contrato Rating*/
                                                     INPUT 0,   /*pr_flgcriar Indicado se deve criar o rating*/
                                                     INPUT 1, /*pr_flgcalcu Indicador de calculo*/
                                                     INPUT par_idseqttl, /*Sequencial do Titular*/
                                                     INPUT par_idorigem, /*Identificador Origem*/
                                                     INPUT par_nmdatela, /*Nome da tela*/
                                                     INPUT "N", /*pr_flgerlog Identificador de geraçao de log*/
                                                     INPUT 0,   /*pr_flghisto Indicador se deve gerar historico*/
                                                     INPUT aux_dsorigem, /*Descriçao da origem*/
                                                    OUTPUT 0, /*0 - Nao perdeu aprovaçao e 1 - Perdeu aprovaçao*/
                                                    OUTPUT "", /*OK - se processar e NOK - se erro*/
                                                    OUTPUT 0, /*Codigo da critica*/
                                                    OUTPUT ""). /*Descricao da critica*/
              /* Fechar o procedimento para buscarmos o resultado */ 
                CLOSE STORED-PROC pc_processa_perda_aprov
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                      
              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                      
                ASSIGN aux_idpeapro = pc_processa_perda_aprov.pr_idpeapro
                  WHEN pc_processa_perda_aprov.pr_idpeapro <> ?
                       aux_dserro = pc_processa_perda_aprov.pr_dserro
                  WHEN pc_processa_perda_aprov.pr_dserro <> ?      
                       aux_cdcritic = pc_processa_perda_aprov.pr_cdcritic
                  WHEN pc_processa_perda_aprov.pr_cdcritic <> ?
                       aux_dscritic = pc_processa_perda_aprov.pr_dscritic
                  WHEN pc_processa_perda_aprov.pr_dscritic <> ?.
                      
               /*Se ocorreu erro*/
              IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                UNDO Grava_valor, LEAVE Grava_valor.
              
              /*Se houve a perda de aprovacao*/
              IF aux_idpeapro = 1 THEN
              DO:
                /*Salvar operador da alteraçao*/
                ASSIGN crawepr.cdopealt = par_cdoperad.
                
                IF NOT aux_contigen AND crawepr.hrenvest > 0 AND aux_insitest <> 0 THEN  
                DO:
                  ASSIGN aux_interrup = true. /* Interromper na Esteira*/
                END.
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT "",
                                        INPUT aux_dsorigem,
                                        INPUT "Regra especifica de valor, valor prestacao e rating, perde aprovacao",
                                        INPUT TRUE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
                                      
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Contrato",
                                             INPUT "ND",
                                             INPUT par_nrctremp).
                /*Realizar perda*/
                ASSIGN crawepr.insitapr = 0
                       crawepr.cdopeapr = ""
                       crawepr.dtaprova = ?
                       crawepr.hraprova = 0
                       crawepr.insitest = 0
                       crawepr.cdopealt = par_cdoperad
                       par_idpeapro     = 1.
                       
                /*                
                CREATE tt-msg-confirma.
                ASSIGN tt-msg-confirma.inconfir = 1
                       tt-msg-confirma.dsmensag =
                       IF aux_contigen THEN
                         "Essa proposta deve ser" + " aprovada na tela CMAPRV"
                       ELSE
                         "Essa proposta deve ser " + " enviada para Analise de Credito".*/
              END.
              END.
                ELSE IF  par_vlemprst > par_vleprori AND par_idpeapro = 0 AND par_vleprori > 0 THEN /*Regra anterior a 438*/
                                        DO:
                     
                      /* Se nao estiver em contigencia e a proposta estava na Esteira */
                      IF NOT aux_contigen AND crawepr.hrenvest > 0 AND aux_insitest <> 0 THEN  
                      DO:
                          ASSIGN aux_interrup = true. /* Interromper na Esteira*/
                      END.
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT "",
                                      INPUT aux_dsorigem,
                                      INPUT "Regra antiga de alteraçao do valor de emprestimo",
                                      INPUT TRUE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                     OUTPUT aux_nrdrowid).
                                    
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Contrato",
                                             INPUT "ND",
                                             INPUT par_nrctremp).
                                             
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Valor Emprestimo Anterior",
                                             INPUT "ND",
                                             INPUT par_vleprori).
                                             
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Valor Emprestimo Novo",
                                             INPUT "ND",
                                             INPUT par_vlemprst). 
                 
                      ASSIGN crawepr.insitapr = 0
                             crawepr.cdopeapr = ""
                             crawepr.dtaprova = ?
                                                  crawepr.hraprova = 0
                             crawepr.insitest = 0
                           crawepr.cdopealt = par_cdoperad
                           par_idpeapro     = 1.
                   
                  /*Salvar operador da alteraçao*/
                  ASSIGN crawepr.cdopealt = par_cdoperad.

                                   /*
                                   CREATE tt-msg-confirma.
                                   ASSIGN tt-msg-confirma.inconfir = 1
                                      tt-msg-confirma.dsmensag =
                                                                    IF aux_contigen THEN
                                          "Essa proposta deve ser" +
                                                                       " aprovada na tela CMAPRV"
                                            ELSE
                                                    "Essa proposta deve ser " +
                                                                       " enviada para Analise de Credito".*/     
                      END.
                ELSE IF par_vlemprst < par_vleprori AND par_idpeapro = 0 THEN /*Incluido Paulo Martins*/
                                        DO: /* Dimuniu o valor da proposta e ja foi para esteira perde aprovaçao */
                                        IF  ( (crawepr.insitest <> 3) /* Nao finalizou analise */
                                         /* OU Finalizou analise como "2 - Nao aprovado" ou "4 - Refazer" */
                                         OR ( (crawepr.insitest =  3) AND CAN-DO("2,4", STRING(crawepr.insitapr)) ) ) 
                                         /* E Enviada para esteira */
                                        AND (crawepr.dtenvest <> ?) THEN 
             DO:
                 
                 /* Se nao estiver em contigencia e a proposta estava na Esteira */
                 IF NOT aux_contigen AND crawepr.hrenvest > 0 AND aux_insitest <> 0 THEN  
                 DO:
                     ASSIGN aux_interrup = true. /* Interromper na Esteira*/
                 END.
                 
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT "",
                                        INPUT aux_dsorigem,
                                        INPUT "Regra de valor emprestimo menor que o original",
                                        INPUT TRUE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
                                     
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "contrato",
                                             INPUT "ND",
                                             INPUT par_nrctremp).
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "ValorEmprestimo",
                                             INPUT par_vleprori,
                                             INPUT par_vlemprst).
                 ASSIGN crawepr.insitapr = 0
                        crawepr.cdopeapr = ""
                        crawepr.dtaprova = ?
                                                      crawepr.hraprova = 0
                           crawepr.insitest = 0
                           par_idpeapro     = 1.

                           /*
                                   CREATE tt-msg-confirma.
                                   ASSIGN tt-msg-confirma.inconfir = 1
                                      tt-msg-confirma.dsmensag =
                                                                        IF aux_contigen THEN
                                          "Essa proposta deve ser" +
                                                                           " aprovada na tela CMAPRV"
                          ELSE
                                                                           "Essa proposta deve ser " +
                                                                           " enviada para Analise de Credito". */     

                                        END.
                                        END.
                              END. /* IF par_dsdopcao = "SVP" THEN */
             END.
            END.
        END.
        END. /*par_inresapr */


        ASSIGN aux_vlemprst     = crawepr.vlemprst
               aux_vlpreemp     = crawepr.vlpreemp
               crawepr.vlemprst = par_vlemprst
               crawepr.vlpreemp = par_vlpreemp.

        /* PRJ 438 - Gravar data pagto recebida via parametro quando for opcao de Somente valor proposta */
        IF par_dsdopcao = "SVP" THEN  
        DO:
            ASSIGN aux_dtvencto = crawepr.dtvencto
			       aux_dtdpagto = crawepr.dtdpagto
			       crawepr.dtvencto = par_dtdpagto
                   crawepr.dtdpagto = par_dtdpagto.
        END.       
      /*Inicio M438*/
      IF par_dsdopcao = "TP" THEN /*Inclusao Proposta*/
      DO:
        IF  NOT VALID-HANDLE(h-b1wgen0043) THEN
            RUN sistema/generico/procedures/b1wgen0043.p
                PERSISTENT SET h-b1wgen0043.
        
        IF  NOT VALID-HANDLE(h-b1wgen0043)  THEN
        DO:
                MESSAGE "Handle invalido para BO b1wgen0043.".
                UNDO Grava_valor, LEAVE Grava_valor.
        END.
        
        FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper.
        
        RUN gera_rating IN h-b1wgen0043
                        (INPUT par_cdcooper,
                         INPUT par_cdagenci,   /** Pac   **/
                         INPUT par_nrdcaixa,   /** Caixa **/
                         INPUT par_cdoperad,
                         INPUT par_nmdatela,
                         INPUT par_idorigem,   /** Ayllos  **/
                         INPUT par_nrdconta,
                         INPUT par_idseqttl,   /** Titular **/
                         INPUT crapdat.dtmvtolt,
                         INPUT crapdat.dtmvtopr,
                         INPUT crapdat.inproces,
                         INPUT 90, /*aux_tpctrato*/
                         INPUT par_nrctremp, /*crawepr.nrctrato,*/
                         INPUT FALSE,  /* NAO GRAVA */
                         INPUT TRUE,   /** Log **/
                        OUTPUT TABLE tt-erro,
                        OUTPUT TABLE tt-cabrel,
                        OUTPUT TABLE tt-impressao-coop,
                        OUTPUT TABLE tt-impressao-rating,
                        OUTPUT TABLE tt-impressao-risco,
                        OUTPUT TABLE tt-impressao-risco-tl,
                        OUTPUT TABLE tt-impressao-assina,
                        OUTPUT TABLE tt-efetivacao,
                        OUTPUT TABLE tt-ratings).
                
        IF  VALID-HANDLE(h-b1wgen0043) THEN
            DELETE PROCEDURE h-b1wgen0043.
            
        IF  RETURN-VALUE = "NOK"  THEN
          ASSIGN aux_dsratori = "".
         
        ASSIGN aux_dsratori = "".
        FIND FIRST tt-impressao-risco NO-LOCK NO-ERROR.
        IF  AVAIL tt-impressao-risco THEN
            aux_dsratori = tt-impressao-risco.dsdrisco.
        
        IF (crawepr.dsratori = ? OR crawepr.dsratori = " ") AND 
           (aux_dsratori <> "" OR aux_dsratori <> ?) THEN
          ASSIGN crawepr.dsratori = aux_dsratori.
                
      END. /*IF par_dsdopcao = "TP" THEN*/
      /*Fim M438*/
      IF  crawepr.tpemprst = 1   THEN /*emprestimo PP*/
            DO:
                ASSIGN aux_dtlibera     = crawepr.dtlibera
                       crawepr.dtlibera = par_dtlibera.

                RUN sistema/generico/procedures/b1wgen0084.p
                    PERSISTENT SET h-b1wgen0084.

                RUN grava_parcelas_proposta IN h-b1wgen0084 (
                     INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_nrdconta,
                     INPUT par_idseqttl,
                     INPUT par_dtmvtolt,
                     INPUT par_flgerlog,
                     INPUT crawepr.nrctremp,
                     INPUT crawepr.cdlcremp,
                     INPUT crawepr.cdfinemp,
                     INPUT crawepr.vlemprst,
                     INPUT crawepr.qtpreemp,
                     INPUT crawepr.dtlibera,
                     /* PRJ 438 - Ajuste para quando for opcao de Somente valor proposta, passar a data pagto recebida via parametro */
                     INPUT (IF par_dsdopcao = "SVP" THEN 
                               par_dtdpagto
                            ELSE crawepr.dtdpagto),
                     INPUT crawepr.idfiniof,
                     OUTPUT TABLE tt-erro).

                DELETE OBJECT h-b1wgen0084.

                IF  RETURN-VALUE <> "OK"   THEN
                    DO:
                        FIND FIRST tt-erro NO-ERROR.
                        IF   AVAIL tt-erro   THEN
                            aux_dscritic = tt-erro.dscritic.
                        ELSE
                            aux_dscritic =
                                "Ocorreram erros durante a gravacao das " +
                                "parcelas da proposta.".

                        EMPTY TEMP-TABLE tt-erro.

                        UNDO Grava_valor, LEAVE Grava_valor.
                    END.
                
                /* Caso o valor da prestacao foi alterado, vamos mostrar mensagem */
                IF aux_dtlibera     <> ?            AND 
                   aux_dtlibera     <> par_dtmvtolt AND 
                   crawepr.vlpreemp <> aux_vlpreemp THEN
                   DO:
                       CREATE tt-msg-confirma.
                       ASSIGN tt-msg-confirma.inconfir = 1
                              tt-msg-confirma.dsmensag = "Atencao! A data de liberacao do recurso " +
                                                         "foi alterada automaticamente para hoje "  +
                                                         STRING(par_dtmvtolt,"99/99/9999") + ". <br />" +
                                                         "Valor da parcela atualizado de R$ "        +
                                                         TRIM(STRING(aux_vlpreemp,"zzz,zzz,zz9.99")) +
                                                         " para R$ " +
                                                         TRIM(STRING(crawepr.vlpreemp,"zzz,zzz,zz9.99")) + ".".
                                                         
                   END. /* END IF crawepr.vlpreemp <> aux_vlpreemp THEN */
            END.
        ELSE IF  crawepr.tpemprst = 2   THEN
            DO:
                ASSIGN aux_dtlibera     = crawepr.dtlibera
                       crawepr.dtlibera = par_dtlibera.

                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                /* Efetuar a chamada a rotina Oracle  */
                RUN STORED-PROCEDURE pc_busca_qtd_dias_carencia
                    aux_handproc = PROC-HANDLE NO-ERROR (INPUT crawepr.idcarenc,
                                                        OUTPUT 0,   /* pr_qtddias */
                                                        OUTPUT 0,   /* pr_cdcritic */
                                                        OUTPUT ""). /* pr_dscritic */  

                /* Fechar o procedimento para buscarmos o resultado */ 
                CLOSE STORED-PROC pc_busca_qtd_dias_carencia
                       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                ASSIGN aux_cdcritic = 0
                       aux_dscritic = ""
                       aux_cdcritic = INT(pc_busca_qtd_dias_carencia.pr_cdcritic) 
                                      WHEN pc_busca_qtd_dias_carencia.pr_cdcritic <> ?
                       aux_dscritic = pc_busca_qtd_dias_carencia.pr_dscritic
                                      WHEN pc_busca_qtd_dias_carencia.pr_dscritic <> ?
                       aux_qtdias_carencia = INT(pc_busca_qtd_dias_carencia.pr_qtddias) 
                                             WHEN pc_busca_qtd_dias_carencia.pr_qtddias <> ?.

                IF   aux_cdcritic <> 0    OR
                     aux_dscritic <> ""   THEN
                     UNDO Grava_valor, LEAVE Grava_valor.

                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                /* Efetuar a chamada a rotina Oracle  */
                RUN STORED-PROCEDURE pc_grava_parcel_pos_fixado
                    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                                         INPUT par_nrdconta,
                                                         INPUT par_dtmvtolt,
                                                         INPUT crawepr.nrctremp,
                                                         INPUT crawepr.cdlcremp,
                                                         INPUT crawepr.vlemprst,
                                                         INPUT crawepr.qtpreemp,
                                                         INPUT crawepr.dtcarenc,
                                                         /* PRJ 438 - Ajuste para quando for opcao de Somente valor proposta, passar a data pagto recebida via parametro */
                                                         INPUT (IF par_dsdopcao = "SVP" THEN 
                                                                   par_dtdpagto
                                                                ELSE crawepr.dtdpagto),
                                                         INPUT aux_qtdias_carencia,
                                                        OUTPUT 0,   /* pr_vlpreemp */
                                                        OUTPUT 0,   /* pr_txdiaria */
                                                        OUTPUT 0,   /* pr_txmensal */
                                                        OUTPUT 0,   /* pr_cdcritic */
                                                        OUTPUT ""). /* pr_dscritic */  

                /* Fechar o procedimento para buscarmos o resultado */ 
                CLOSE STORED-PROC pc_grava_parcel_pos_fixado
                       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                ASSIGN aux_cdcritic = 0
                       aux_dscritic = ""
                       aux_cdcritic = INT(pc_grava_parcel_pos_fixado.pr_cdcritic) 
                                      WHEN pc_grava_parcel_pos_fixado.pr_cdcritic <> ?
                       aux_dscritic = pc_grava_parcel_pos_fixado.pr_dscritic
                                      WHEN pc_grava_parcel_pos_fixado.pr_dscritic <> ?.

                IF   aux_cdcritic <> 0    OR
                     aux_dscritic <> ""   THEN
                     UNDO Grava_valor, LEAVE Grava_valor.

                /* Atualizar o buffer na tabela crawepr */
                ASSIGN crawepr.vlpreemp = pc_grava_parcel_pos_fixado.pr_vlpreemp
                       crawepr.txdiaria = pc_grava_parcel_pos_fixado.pr_txdiaria
                       crawepr.txmensal = pc_grava_parcel_pos_fixado.pr_txmensal.

                
                /* Caso o valor da prestacao foi alterado, vamos mostrar mensagem */
                IF   aux_dtlibera     <> ?              AND
                     aux_dtlibera     <> par_dtmvtolt   AND
                     crawepr.vlpreemp <> aux_vlpreemp   THEN
                     DO:
                         CREATE tt-msg-confirma.
                         ASSIGN tt-msg-confirma.inconfir = 1
                                tt-msg-confirma.dsmensag = "Atencao! A data de liberacao do recurso "     +
                                                           "foi alterada automaticamente para hoje "      +
                                                           STRING(par_dtmvtolt,"99/99/9999") + ". <br />" +
                                                           "Valor da parcela atualizado de R$ "           +
                                                           TRIM(STRING(aux_vlpreemp,"zzz,zzz,zz9.99"))    +
                                                           " para R$ " +
                                                           TRIM(STRING(crawepr.vlpreemp,"zzz,zzz,zz9.99")) + ".".
                     END.
            END.
        ELSE
        DO:
            IF par_dsdopcao <> "SVP" THEN
               ASSIGN crawepr.dtlibera = par_dtlibera.
        
        END.

        /* Busca liquidacoes contrato */
        RUN buscar_liquidacoes_contrato(INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrctremp,
                                        OUTPUT aux_dsctrliq).

        /* Calclar o cet automaticamente */
        RUN calcula_cet_novo(INPUT par_cdcooper,
                             INPUT 0, /* agencia */
                             INPUT 0, /* caixa */
                             INPUT par_cdoperad,
                             INPUT par_nmdatela,
                             INPUT 1, /* ayllos */
                             INPUT par_dtmvtolt,
                             INPUT par_nrdconta,
                             INPUT crapass.inpessoa, 
                             INPUT 2, /* cdusolcr */
                             INPUT crawepr.cdlcremp, 
                             INPUT crawepr.tpemprst, 
                             INPUT crawepr.nrctremp, 
                             INPUT (IF crawepr.dtlibera <> ? THEN 
                                       crawepr.dtlibera
                                    ELSE par_dtmvtolt), 
                             INPUT crawepr.vlemprst, 
                             INPUT crawepr.vlpreemp,
                             INPUT crawepr.qtpreemp, 
                             /* PRJ 438 - Ajuste para quando for opcao de Somente valor proposta, passar a data pagto recebida via parametro */
                             INPUT (IF par_dsdopcao = "SVP" THEN 
                                       par_dtdpagto
                                    ELSE crawepr.dtdpagto),
                             INPUT crawepr.cdfinemp, 
                             INPUT par_dscatbem,
                             INPUT par_idfiniof,
                             INPUT aux_dsctrliq,
                             INPUT "N",
                             INPUT crawepr.dtcarenc,
                            OUTPUT aux_percetop, /* taxa cet ano */
                            OUTPUT aux_txcetmes, /* taxa cet mes */
                            OUTPUT TABLE tt-erro). 

        IF  RETURN-VALUE <> "OK" THEN
            DO:
                FIND FIRST tt-erro NO-ERROR.
                IF  AVAIL tt-erro   THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE
                    aux_dscritic = "Nao foi possivel calcular o CET.".

                EMPTY TEMP-TABLE tt-erro.

                UNDO Grava_valor, LEAVE Grava_valor.
            END.

        ASSIGN crawepr.percetop = aux_percetop.

        /* Quando for apenas alteracao do valor */
        IF par_dsdopcao = "SVP" THEN
           DO:
               /* Calculo do Risco do Emprestimo */
               IF NOT VALID-HANDLE(h-b1wgen0043) THEN
                  RUN sistema/generico/procedures/b1wgen0043.p 
                      PERSISTENT SET h-b1wgen0043.
        
               RUN obtem_emprestimo_risco IN h-b1wgen0043
                                       (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT par_nrdconta,
                                        INPUT par_idseqttl,
                                        INPUT par_idorigem,
                                        INPUT par_nmdatela,
                                        INPUT par_flgerlog,
                                        INPUT crawepr.cdfinemp,
                                        INPUT crawepr.cdlcremp,
                                        INPUT crawepr.nrctrliq,
                                        INPUT "",
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT aux_nivrisco).
        
               IF VALID-HANDLE(h-b1wgen0043) THEN
                  DELETE PROCEDURE h-b1wgen0043.

               IF RETURN-VALUE <> "OK" THEN
                  DO:
                      FIND FIRST tt-erro NO-LOCK NO-ERROR.
                      IF AVAILABLE tt-erro THEN
                         ASSIGN aux_dscritic = tt-erro.dscritic.
                      ELSE
                         ASSIGN aux_dscritic =
                                   "Ocorreram erros durante o calculo do " +
                                   "risco da proposta.".

                      EMPTY TEMP-TABLE tt-erro.                        
                      UNDO Grava_valor, LEAVE Grava_valor.
                  END.    

               ASSIGN crawepr.dsnivris = UPPER(aux_nivrisco)
                      crawepr.dsnivori = UPPER(aux_nivrisco).

           END.

        LEAVE.

    END. /* Tratamento de criticas */
        
    /* Se devemos interromper a proposta na Esteira */
    IF aux_interrup THEN
    DO:
      
      FIND FIRST crapope  
       WHERE crapope.cdcooper = par_cdcooper             
         AND crapope.cdoperad = par_cdoperad
             NO-LOCK NO-ERROR.
      
      RUN sistema/generico/procedures/b1wgen0195.p
                       PERSISTENT SET h-b1wgen0195.
               
      /* Enviar Interrupção na Esteira */
      RUN Enviar_proposta_esteira IN h-b1wgen0195        
                        ( INPUT par_cdcooper,
                          INPUT crapope.cdpactra,
                          INPUT par_nrdcaixa,
                          INPUT par_nmdatela,
                          INPUT par_cdoperad,
                          INPUT par_idorigem,
                          INPUT par_nrdconta,
                          INPUT par_dtmvtolt,
                          INPUT par_dtmvtolt,
                          INPUT par_nrctremp, /* nrctremp */
                          INPUT 0,            /* nrctremp_novo */
                          INPUT "",           /* dsiduser */
                          INPUT 0,            /* flreiflx */
                          INPUT "P",          /* tpenvest */
                         OUTPUT aux_dsmensag,                          
                         OUTPUT aux_cdcritic, 
                         OUTPUT aux_dscritic).
      
      DELETE OBJECT h-b1wgen0195.
       
      /* Ignorar erro de "%Proposta nao encontrada" */ 
      IF RETURN-VALUE = "NOK" AND 
         NOT LOWER(aux_dscritic) MATCHES "*proposta nao encontrada*" AND
         NOT LOWER(aux_dscritic) MATCHES "*proposta nao permite interromper o fluxo*" AND
         NOT LOWER(aux_dscritic) MATCHES "*produto cdc nao integrado*" THEN
          DO:
              IF aux_cdcritic = 0 AND 
                 aux_dscritic = "" THEN
              DO:
                ASSIGN aux_dscritic = "Nao foi possivel enviar cancelamento da " +
                                      "proposta para Analise de Credito.".
              END.
          END.
      ELSE
          DO:
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "".
          END.
    END.
    
    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    /* Alteracao somente de valor */
    /* Chamar apos a transacao pois depende de valores anteriores no Oracle */
    /* Os erros desta proc, sao trazidos somente como mensagens */
    /*  BUG 14629 - PRJ438
    IF   par_dsdopcao = "SVP"   THEN 
         DO:
              RUN sistema/generico/procedures/b1wgen0191.p
                           PERSISTENT SET h-b1wgen0191.
                      
              RUN Verifica_Consulta_Biro IN h-b1wgen0191 
                                              (INPUT par_cdcooper,
                                               INPUT par_nrdconta,
                                               INPUT 1, /* inprodut*/
                                               INPUT par_nrctremp,
                                               INPUT par_cdoperad,
                                               INPUT "A",
                                        INPUT-OUTPUT TABLE tt-msg-confirma,
                                              OUTPUT par_flmudfai).
          
              DELETE PROCEDURE h-b1wgen0191.
              
         END.*/

    IF  par_flgerlog   THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).

            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrctremp",
                                     INPUT par_nrctremp,
                                     INPUT par_nrctremp).

            IF  aux_vlemprst <> par_vlemprst     THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "vlemprst",
                                         INPUT aux_vlemprst,
                                         INPUT par_vlemprst).

            IF  aux_vlpreemp <> par_vlpreemp     THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "vlpreemp",
                                         INPUT aux_vlpreemp,
                                         INPUT par_vlpreemp).

            IF  aux_insitapr <> crawepr.insitapr THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "insitapr",
                                         INPUT aux_insitapr,
                                         INPUT crawepr.insitapr).

            IF  aux_cdopeapr <> crawepr.cdopeapr THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "cdopeapr",
                                         INPUT aux_cdopeapr,
                                         INPUT crawepr.cdopeapr).

            IF  aux_dtaprova <> crawepr.dtaprova THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "dtaprova",
                                         INPUT aux_dtaprova,
                                         INPUT crawepr.dtaprova).

            IF  aux_hraprova <> crawepr.hraprova THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "hraprova",
                                         INPUT aux_hraprova,
                                         INPUT crawepr.hraprova).

            IF  aux_insitest <> crawepr.insitest THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "insitest",
                                         INPUT aux_insitest,
                                         INPUT crawepr.insitest).                                         

            IF  par_dtdpagto <> aux_dtvencto THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "dtvencto",
                                         INPUT par_dtdpagto,
                                         INPUT aux_dtvencto). 
										
			IF  par_dtdpagto <> aux_dtdpagto THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "dtvencto",
                                         INPUT par_dtdpagto,
                                         INPUT aux_dtdpagto). 
										 
										 
                                   
			RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "aux_msg_log",
                                         INPUT aux_msg_log,
                                         INPUT aux_msg_log).							 
										 

        END.

    RETURN "OK".

END PROCEDURE.


/***************************************************************************
 Procedure para alterar o numero da proposta de emprestimo.
 Opcao de Alterar na rotina Emprestimo da tela ATENDA.
***************************************************************************/
PROCEDURE altera-numero-proposta:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrant AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.


    DEF  VAR         aux_contador AS INTE                           NO-UNDO.
    DEF  VAR         aux_dsoperac AS CHAR                           NO-UNDO.
    DEF  VAR         h-b1wgen0110 AS HANDLE                         NO-UNDO.

    DEF  BUFFER      crabavt      FOR crapavt.
    DEF  BUFFER      crabavl      FOR crapavl.
    DEF  BUFFER      crabbpr      FOR crapbpr.
    DEf  BUFFER      crabrpr      FOR craprpr.


    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Alterar o numero da proposta de credito".

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapass THEN
       DO:
          ASSIGN aux_cdcritic = 9.

          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).

          RETURN "NOK".

       END.

    IF NOT VALID-HANDLE(h-b1wgen0110) THEN
       RUN sistema/generico/procedures/b1wgen0110.p PERSISTENT SET h-b1wgen0110.

    /*Monta a mensagem da operacao para envio no e-mail*/
    ASSIGN aux_dsoperac = "Tentativa de alterar o numero do contrato da "  +
                          "proposta de emprestimo/financiamento na conta " +
                          STRING(crapass.nrdconta,"zzzz,zzz,9")            +
                          " - CPF/CNPJ "                                   +
                         (IF crapass.inpessoa = 1 THEN
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999")),"xxx.xxx.xxx-xx")
                          ELSE
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999999")),"xx.xxx.xxx/xxxx-xx")).

    /*Verifica se o associado esta no cadastro restritivo*/
    RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_dtmvtolt,
                                      INPUT par_idorigem,
                                      INPUT crapass.nrcpfcgc,
                                      INPUT crapass.nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT TRUE, /*bloqueia operacao*/
                                      INPUT 11, /*cdoperac*/
                                      INPUT aux_dsoperac,
                                      OUTPUT TABLE tt-erro).

    IF VALID-HANDLE(h-b1wgen0110) THEN
       DELETE PROCEDURE(h-b1wgen0110).

    IF RETURN-VALUE <> "OK" THEN
       DO:
          IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
             DO:
                ASSIGN aux_dscritic = "Nao foi possivel verificar o " +
                                      "cadastro restritivo.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

             END.

          RETURN "NOK".

       END.

    DO TRANSACTION WHILE TRUE:
        
        
        FIND craplcr WHERE craplcr.cdcooper = par_cdcooper   AND
                           craplcr.cdlcremp = par_cdlcremp
                           NO-LOCK NO-ERROR.

        IF   AVAIL craplcr   THEN
             IF   NOT CAN-DO("1,4", STRING(craplcr.tpctrato)) THEN
                  DO:
                      aux_dscritic =
                          "Tipo de linha nao permitida nesta alteracao.".
                      LEAVE.
                  END.
        

        /* Verifica se ja existe contrato com o numero informado */
        FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                           crawepr.nrdconta = par_nrdconta   AND
                           crawepr.nrctremp = par_nrctremp
                           NO-LOCK NO-ERROR.

        IF   AVAIL crawepr   THEN
             DO:
                 aux_dscritic =
                     "Numero da proposta de emprestimo ja existente.".
                 LEAVE.
             END.

        /* Verifica se o contrato atual ja foi efetivado. */
        FIND crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                           crapepr.nrdconta = par_nrdconta AND
                           crapepr.nrctremp = par_nrctrant
                           NO-LOCK NO-ERROR.

        IF   AVAIL crapepr   THEN
             DO:
                aux_dscritic = "Proposta ja efetivada.".
                LEAVE.
             END.


        /* BNDES */
        FIND FIRST crapprp WHERE crapprp.cdcooper = par_cdcooper  AND
                                 crapprp.nrdconta = par_nrdconta  AND
                                 crapprp.nrctrato = par_nrctremp  AND
                                 crapprp.tpctrato = 90
                           NO-LOCK NO-ERROR.

        IF   AVAIL crapprp   THEN
             DO:
                 aux_dscritic =
                     "Numero de proposta BNDES ja existente.".
                 LEAVE.
             END.


        DO aux_contador = 1 TO 10:

            FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                               crawepr.nrdconta = par_nrdconta   AND
                               crawepr.nrctremp = par_nrctrant
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAIL crawepr   THEN
                 IF   LOCKED crawepr   THEN
                      DO:
                          aux_cdcritic = 371.
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.
                 ELSE
                      DO:
                          aux_cdcritic = 356.
                          LEAVE.
                      END.

            aux_cdcritic = 0.
            LEAVE.

        END. /* Tratamento Lock crawepr */

		/*Se for Portabilidade Credito Tpfinali = 2 
		  nao permite alterar o numero da proposta*/
		FIND crapfin WHERE crapfin.cdcooper = crawepr.cdcooper
		               AND crapfin.cdfinemp = crawepr.cdfinemp
					   AND crapfin.tpfinali = 2 NO-LOCK NO-ERROR. 

        IF AVAIL(crapfin) THEN
           DO:
               aux_dscritic = "Nao e permitido alterar o numero da proposta de portabilidade".
               LEAVE.
           END.
        
        IF   aux_cdcritic <> 0 OR
             aux_dscritic <> ""  THEN
             UNDO, LEAVE.

        /* Mudar o numero do contrato */
        ASSIGN aux_nrctremp     = crawepr.nrctremp
               crawepr.nrctremp = par_nrctremp.

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_vincula_cobertura_operacao
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT 0
                                              ,INPUT crawepr.idcobope
                                              ,INPUT crawepr.nrctremp
                                              ,"").

        CLOSE STORED-PROC pc_vincula_cobertura_operacao
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_dscritic  = ""
               aux_dscritic  = pc_vincula_cobertura_operacao.pr_dscritic 
               WHEN pc_vincula_cobertura_operacao.pr_dscritic <> ?.
                        
        IF aux_dscritic <> "" THEN
           UNDO, LEAVE.     
        
        /* Avalistas terceiros, intervenientes anuentes */
        FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper        AND
                               crapavt.nrdconta = par_nrdconta        AND
                               CAN-DO("1,9",STRING(crapavt.tpctrato)) AND
                               crapavt.nrctremp = par_nrctrant        NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND crabavt WHERE crabavt.cdcooper = crapavt.cdcooper   AND
                                   crabavt.nrdconta = crapavt.nrdconta   AND
                                   crabavt.tpctrato = crapavt.tpctrato   AND
                                   crabavt.nrctremp = crapavt.nrctremp   AND
                                   crabavt.nrcpfcgc = crapavt.nrcpfcgc
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF    NOT AVAIL crabavt   THEN
                      IF   LOCKED crabavt   THEN
                           DO:
                               aux_cdcritic = 77.
                               PAUSE 1 NO-MESSAGE.
                               NEXT.
                           END.
                      ELSE
                           DO:
                               aux_cdcritic = 869.
                               LEAVE.
                           END.

                aux_cdcritic = 0.
                LEAVE.

            END.

            IF   aux_cdcritic <> 0   THEN
                 LEAVE.

            /* Atualizar numero contrato */
            ASSIGN crabavt.nrctremp = par_nrctremp.

        END.

        IF   aux_cdcritic <> 0   THEN
             UNDO, LEAVE.

        /* Avalistas cooperados */
        FOR EACH crapavl WHERE crapavl.cdcooper = par_cdcooper   AND
                               crapavl.nrctaavd = par_nrdconta   AND
                               crapavl.nrctravd = par_nrctrant   AND
                               crapavl.tpctrato = 1              NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND crabavl WHERE crabavl.cdcooper = crapavl.cdcooper   AND
                                   crabavl.nrdconta = crapavl.nrdconta   AND
                                   crabavl.nrctravd = crapavl.nrctravd   AND
                                   crabavl.tpctrato = crapavl.tpctrato
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAIL crabavl   THEN
                     IF   LOCKED crabavl   THEN
                          DO:
                              aux_cdcritic = 77.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              aux_cdcritic = 869.
                              LEAVE.
                          END.

                aux_cdcritic = 0.
                LEAVE.

            END.

            IF   aux_cdcritic <> 0   THEN
                 LEAVE.

            /* Mudar o numero do contrato */
            ASSIGN crabavl.nrctravd = par_nrctremp.

        END.

        IF   aux_cdcritic <> 0   THEN
             UNDO, LEAVE.

        /* Bens das propostas */
        FOR EACH crapbpr WHERE crapbpr.cdcooper = par_cdcooper    AND
                               crapbpr.nrdconta = par_nrdconta    AND
                               crapbpr.tpctrpro = 90              AND
                               crapbpr.nrctrpro = par_nrctrant    NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND crabbpr WHERE crabbpr.cdcooper = crapbpr.cdcooper   AND
                                   crabbpr.nrdconta = crapbpr.nrdconta   AND
                                   crabbpr.tpctrpro = crapbpr.tpctrpro   AND
                                   crabbpr.nrctrpro = crapbpr.nrctrpro   AND
                                   crabbpr.idseqbem = crapbpr.idseqbem
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAIL crabbpr   THEN
                     IF   LOCKED crabbpr   THEN
                          DO:
                              aux_cdcritic = 77.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              ASSIGN aux_dscritic = "Descricao dos bens da proposta " +
                                                    "de emprestimo nao encontrada.".
                              LEAVE.
                          END.

                aux_cdcritic = 0.
                LEAVE.

            END.

            IF   aux_cdcritic <> 0  OR
                 aux_dscritic <> "" THEN
                 LEAVE.

            ASSIGN crabbpr.nrctrpro = par_nrctremp.

        END. /* Fim bens das propostas */

        IF   aux_cdcritic <> 0  OR
             aux_dscritic <> "" THEN
             UNDO, LEAVE.

        /* Proposta */
        DO aux_contador = 1 TO 10:

            FIND crapprp WHERE crapprp.cdcooper = par_cdcooper   AND
                               crapprp.nrdconta = par_nrdconta   AND
                               crapprp.tpctrato = 90             AND
                               crapprp.nrctrato = par_nrctrant
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF    NOT AVAIL crapprp   THEN
                  IF   LOCKED crapprp   THEN
                       DO:
                           aux_cdcritic = 371.
                           PAUSE 1 NO-MESSAGE.
                           NEXT.
                       END.
                  ELSE
                       DO:
                           aux_cdcritic = 510.
                           LEAVE.
                       END.

            aux_cdcritic = 0.
            LEAVE.

        END.

        IF   aux_cdcritic <> 0   THEN
             UNDO, LEAVE.

        /* Novo numero de contrato */
        ASSIGN crapprp.nrctrato = par_nrctremp.


        /* Rendimentos da proposta */
        FOR EACH craprpr WHERE craprpr.cdcooper = par_cdcooper   AND
                               craprpr.nrdconta = par_nrdconta   AND
                               craprpr.tpctrato = 90             AND
                               craprpr.nrctrato = par_nrctrant   NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND crabrpr WHERE crabrpr.cdcooper = craprpr.cdcooper   AND
                                   crabrpr.nrdconta = craprpr.nrdconta   AND
                                   crabrpr.tpctrato = craprpr.tpctrato   AND
                                   crabrpr.nrctrato = craprpr.nrctrato   AND
                                   crabrpr.tpdrendi = craprpr.tpdrendi
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAIL crabrpr   THEN
                     IF   LOCKED crabrpr   THEN
                          DO:
                              aux_cdcritic = 77.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              ASSIGN aux_dscritic = "Registro de rendimento " +
                                                    "do cooperado nao encontrado.".

                              LEAVE.
                          END.

                aux_cdcritic = 0.
                LEAVE.

            END.

            IF   aux_cdcritic <> 0  OR
                 aux_dscritic <> "" THEN
                 LEAVE.

            /* Novo numero de contrato */
            ASSIGN crabrpr.nrctrato = par_nrctremp.

        END.

        IF   aux_cdcritic <> 0  OR
             aux_dscritic <> "" THEN
             UNDO, LEAVE.

        IF   crawepr.tpemprst = 1   THEN
             DO:
                 RUN sistema/generico/procedures/b1wgen0084.p
                     PERSISTENT SET h-b1wgen0084.

                 RUN altera_numero_proposta_parcelas IN h-b1wgen0084 (
                     INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_nrdconta,
                     INPUT par_idseqttl,
                     INPUT par_dtmvtolt,
                     INPUT par_flgerlog,
                     INPUT par_nrctrant,
                     INPUT crawepr.nrctremp,
                     OUTPUT TABLE tt-erro).

                 DELETE OBJECT h-b1wgen0084.

                 IF   RETURN-VALUE <> "OK"   THEN
                      DO:
                          FIND FIRST tt-erro NO-ERROR.
                          IF AVAIL tt-erro   THEN
                             aux_dscritic = tt-erro.dscritic.
                          ELSE
                             aux_dscritic = "Ocorreram erros durante a "
                                           + "gravacao das parcelas da "
                                           + "proposta.".

                          EMPTY TEMP-TABLE tt-erro.

                          UNDO, LEAVE.
                      END.
             END.
        ELSE IF crawepr.tpemprst = 2 THEN
             DO:
                 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                 /* Efetuar a chamada a rotina Oracle  */
                 RUN STORED-PROCEDURE pc_alt_numero_parcelas_pos
                     aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                                          INPUT par_nrdconta,
                                                          INPUT par_nrctrant,
                                                          INPUT crawepr.nrctremp,
                                                         OUTPUT 0,   /* pr_cdcritic */
                                                         OUTPUT ""). /* pr_dscritic */  

                 /* Fechar o procedimento para buscarmos o resultado */ 
                 CLOSE STORED-PROC pc_alt_numero_parcelas_pos
                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                 { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                 ASSIGN aux_cdcritic = 0
                        aux_dscritic = ""
                        aux_cdcritic = INT(pc_alt_numero_parcelas_pos.pr_cdcritic) 
                                       WHEN pc_alt_numero_parcelas_pos.pr_cdcritic <> ?
                        aux_dscritic = pc_alt_numero_parcelas_pos.pr_dscritic
                                       WHEN pc_alt_numero_parcelas_pos.pr_dscritic <> ?.

                 IF   aux_cdcritic <> 0    OR
                      aux_dscritic <> ""   THEN
                      UNDO, LEAVE.
             END.

             /* Somente enviar alteracao de numero se proposta ja foi enviada
                para analise manual na Esteira */
             IF crawepr.dtenvest <> ? AND 
                crawepr.insitest >= 2 AND 
                crawepr.cdopeapr <> "MOTOR" THEN
             DO: 
                 FIND FIRST crapope  
                                   WHERE crapope.cdcooper = par_cdcooper             
                                     AND crapope.cdoperad = par_cdoperad
                                         NO-LOCK NO-ERROR.
                 
                 RUN sistema/generico/procedures/b1wgen0195.p
                     PERSISTENT SET h-b1wgen0195.
             
                 /* Enviar alteracao do numero para esteira*/
                 RUN Enviar_proposta_esteira IN h-b1wgen0195        
                                   ( INPUT par_cdcooper,
                                     INPUT crapope.cdpactra,
                                     INPUT par_nrdcaixa,
                                     INPUT par_nmdatela,
                                     INPUT par_cdoperad,
                                     INPUT par_idorigem,
                                     INPUT par_nrdconta,
                                     INPUT par_dtmvtolt,
                                     INPUT par_dtmvtolt,
                                     INPUT par_nrctrant, /* nrctremp */
                                     INPUT par_nrctremp, /* nrctremp_novo */
                                     INPUT "",           /* dsiduser */
                                     INPUT 0,            /* flreiflx */
                                     INPUT "N",          /* tpenvest */
                                    OUTPUT aux_dsmensag, 
                                    OUTPUT aux_cdcritic, 
                                    OUTPUT aux_dscritic).
                 
                 DELETE OBJECT h-b1wgen0195.
                 
                 IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        IF aux_cdcritic = 0 AND 
                           aux_dscritic = "" THEN
                        DO:
                          ASSIGN aux_dscritic = "Nao foi possivel enviar alteracao do " + 
                                                "numero da proposta para Analise de Credito.".
                        END.
                          UNDO, LEAVE.
                      END.

                             /* Chamar rotina para alterar numero da proposta no acionamento */
                 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                 RUN STORED-PROCEDURE pc_alter_nrctrprp_aciona 
                      aux_handproc = PROC-HANDLE NO-ERROR
                                       (INPUT par_cdcooper,  /* Codigo da cooperativa */
                                        INPUT par_nrdconta,  /* Numero da conta do cooperado */
                                        INPUT par_nrctrant,  /* Numero da proposta de emprestimo antigo */
                                        INPUT par_nrctremp,  /* Numero da proposta de emprestimo novo */
                                        INPUT par_dtmvtolt,  /* Data do movimento */  
                                       OUTPUT "").

                  CLOSE STORED-PROC pc_alter_nrctrprp_aciona 
                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                  
                  ASSIGN aux_dscritic = ""                         
                         aux_dscritic = pc_alter_nrctrprp_aciona.pr_dscritic 
                                        WHEN pc_alter_nrctrprp_aciona.pr_dscritic <> ?.
                      
                  IF  aux_dscritic <> ""  THEN
                      DO:                                  
                          UNDO, LEAVE.
             END.

                         END.
        LEAVE.

    END. /* Fim TRANSACTION , tratamento criticas */

    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             IF  par_flgerlog  THEN
                 RUN proc_gerar_log (INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid).

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    IF  par_flgerlog  THEN
        DO:

            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).

            IF  aux_nrctremp <> par_nrctremp THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "nrctremp",
                                         INPUT aux_nrctremp,
                                         INPUT par_nrctremp).
        END.
    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Excluir a proposta de emprestimo, Opcao excluir na rotina de emprestimos
 da tela ATENDA.
*****************************************************************************/
PROCEDURE excluir-proposta:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdmodali AS CHAR               NO-UNDO.
    DEF VAR aux_des_erro AS CHAR               NO-UNDO.
    DEF VAR aux_contador AS INTE               NO-UNDO.
    DEF VAR aux_nrdconta LIKE crapass.nrdconta NO-UNDO.
    DEF VAR aux_flgrespo AS INTE               NO-UNDO.
    DEF VAR h-b1wgen0114 AS HANDLE             NO-UNDO.

    DEF  BUFFER crabavt           FOR crapavt.
    DEF  BUFFER crabbpr           FOR crapbpr.
    DEF  BUFFER crabrpr           FOR craprpr.
    DEF  BUFFER crabadi           FOR crapadi.
    DEF  BUFFER crabadt           FOR crapadt.
    DEF  BUFFER crabgrv           FOR crapgrv.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Excluir a proposta de emprestimo".

    DO TRANSACTION WHILE TRUE:

        /* verificar se a proposta nao foi efetivada */
        FIND FIRST crapepr WHERE crapepr.cdcooper = par_cdcooper
                             AND crapepr.nrdconta = par_nrdconta
                             AND crapepr.nrctremp = par_nrctremp
                             NO-LOCK NO-ERROR.
        IF  AVAIL crapepr THEN
        DO:
            ASSIGN aux_dscritic = "Nao e possivel excluir uma proposta ja efetivada.".
            LEAVE.
        END.

        DO aux_contador = 1 TO 10:

            FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                               crawepr.nrdconta = par_nrdconta   AND
                               crawepr.nrctremp = par_nrctremp
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAIL crawepr   THEN
                 IF   LOCKED crawepr   THEN
                      DO:
                          aux_cdcritic = 371.
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.
                 ELSE
                      DO:
                          aux_cdcritic = 356.
                          LEAVE.
                      END.

            aux_cdcritic = 0.
            LEAVE.

        END. /* Tratamento Lock crawepr */


        /* verifica se eh uma proposta de portabilidade */
        FIND tbepr_portabilidade WHERE tbepr_portabilidade.cdcooper = par_cdcooper   AND
                                       tbepr_portabilidade.nrdconta = par_nrdconta   AND
                                       tbepr_portabilidade.nrctremp = par_nrctremp 
                                       EXCLUSIVE-LOCK NO-ERROR.

        IF AVAIL tbepr_portabilidade THEN
        DO:
                /* Se proposta ja foi aprovada devemos cancela-la no JDCTC */
            IF crawepr.insitapr = 1 OR crawepr.insitapr = 3 THEN
				DO:
					FOR FIRST craplcr FIELDS (cdmodali cdsubmod)
									  WHERE craplcr.cdcooper = crawepr.cdcooper
										AND craplcr.cdlcremp = crawepr.cdlcremp
										NO-LOCK:
						ASSIGN aux_cdmodali = craplcr.cdmodali + craplcr.cdsubmod.
					END.

					FOR FIRST crapban FIELDS (nrispbif)
									   WHERE crapban.cdbccxlt = 85 NO-LOCK:
					END.

					/* Busca cpf/cnpj do cooperado */
					FOR FIRST crapass FIELDS (nrcpfcgc)
									  WHERE crapass.cdcooper = par_cdcooper
										AND crapass.nrdconta = par_nrdconta
									  NO-LOCK:                    
					END.

					FOR FIRST crapcop FIELDS (nrdocnpj)
									  WHERE crapcop.cdcooper = par_cdcooper
									  NO-LOCK:
					END.
                
					IF NOT VALID-HANDLE(h-b1wgen0114) THEN
					   RUN sistema/generico/procedures/b1wgen0114.p PERSISTENT SET h-b1wgen0114.
                                
					/* Consulta situacao da portabilidade no JDCTC */
					RUN consulta_situacao IN h-b1wgen0114 (INPUT par_cdcooper,                                   /* Código da Cooperativa*/
														   INPUT crapban.nrispbif,                               /* Nr. ISPB IF */
														   INPUT SUBSTRING(STRING(crapcop.nrdocnpj, 
																 "99999999999999"), 1, 8),                       /* Identificador Participante Administrado */
														   INPUT SUBSTRING(STRING(tbepr_portabilidade.nrcnpjbase_if_origem,
																 "99999999999999"), 1, 8),                       /* CNPJ Base IF Credora Original Contrato */
														   INPUT tbepr_portabilidade.nrunico_portabilidade,      /* Número único da portabilidade na CTC */  
														   INPUT tbepr_portabilidade.nrcontrato_if_origem,       /* Código Contrato Original                */
														   INPUT aux_cdmodali,                                   /* Tipo Contrato                           */
														   INPUT crapass.nrcpfcgc,                               /* CNPJ CPF Cliente                        */
														   OUTPUT aux_des_erro,                                  /* Indicador erro OK/NOK */
														   OUTPUT aux_dscritic,                                  /* Descrição da crítica  */ 
														   OUTPUT TABLE tt-dados-portabilidade).                 /* TT com dados de portabilidade */   
                                
					IF VALID-HANDLE(h-b1wgen0114) THEN
             DELETE PROCEDURE h-b1wgen0114.
          
					FIND FIRST tt-dados-portabilidade.
                
					/* Se nao encontrou portabilidade ou houve algum erro */
					IF  NOT AVAIL tt-dados-portabilidade OR 
						aux_des_erro <> "OK"             THEN
						DO:
							IF aux_dscritic = "" THEN
								ASSIGN aux_dscritic = "Nao foi possivel consultar a situacao da portabilidade no sistema JDCTC.".
							LEAVE.
            
						END.
            
					/* Se portabilidade ainda nao foi cancelada no JDCTC */
					IF  CAN-DO("PS7,PX7,RX9,SXA,SXB,SX7,SX9,SI3,SR6,SR7,SI8", 
							  tt-dados-portabilidade.stportabilidade) THEN
						DO:
							DELETE tbepr_portabilidade.
						END.
					ELSE
            DO:
							ASSIGN aux_dscritic = "Exclusao nao permitida. Solicitacao de Portabilidade em andamento!".
                LEAVE.
            END.
				END.
            ELSE
            DO:
                DELETE tbepr_portabilidade.
            END.
                
        END.
                                                        

        IF crawepr.tpemprst = 1 THEN
            DO:

                RUN sistema/generico/procedures/b1wgen0084.p
                    PERSISTENT SET h-b1wgen0084.

                RUN exclui_parcelas_proposta IN h-b1wgen0084 (
                    INPUT par_cdcooper,
                    INPUT par_cdagenci,
                    INPUT par_nrdcaixa,
                    INPUT par_cdoperad,
                    INPUT par_nmdatela,
                    INPUT par_idorigem,
                    INPUT par_nrdconta,
                    INPUT par_idseqttl,
                    INPUT par_dtmvtolt,
                    INPUT par_flgerlog,
                    INPUT par_nrctremp,
                    OUTPUT TABLE tt-erro).

                DELETE OBJECT h-b1wgen0084.

                IF RETURN-VALUE <> "OK" THEN
                    DO:
                        FIND FIRST tt-erro NO-ERROR.
                        IF AVAIL tt-erro THEN
                            aux_dscritic = tt-erro.dscritic.
                        ELSE

                            aux_dscritic = "Ocorreram erros durante a exclusao"
                                           + " das parcelas da proposta.".
                    END.

            END.
        ELSE IF crawepr.tpemprst = 2 THEN
            DO:
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                /* Efetuar a chamada a rotina Oracle  */
                RUN STORED-PROCEDURE pc_exclui_prop_pos_fixado
                    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                                         INPUT par_nrdconta,
                                                         INPUT par_nrctremp,
                                                        OUTPUT 0,   /* pr_cdcritic */
                                                        OUTPUT ""). /* pr_dscritic */  

                /* Fechar o procedimento para buscarmos o resultado */ 
                CLOSE STORED-PROC pc_exclui_prop_pos_fixado
                       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                ASSIGN aux_cdcritic = 0
                       aux_dscritic = ""
                       aux_cdcritic = INT(pc_exclui_prop_pos_fixado.pr_cdcritic) 
                                      WHEN pc_exclui_prop_pos_fixado.pr_cdcritic <> ?
                       aux_dscritic = pc_exclui_prop_pos_fixado.pr_dscritic
                                      WHEN pc_exclui_prop_pos_fixado.pr_dscritic <> ?.
            END.

        IF   aux_cdcritic <> 0  OR
             aux_dscritic <> "" THEN
             UNDO, LEAVE.

        /*  Primeiro avalista  */
        DO aux_contador = 1 TO 10:

           FIND crapavl WHERE crapavl.cdcooper = par_cdcooper       AND 
                              crapavl.nrdconta = crawepr.nrctaav1   AND
                              crapavl.nrctravd = crawepr.nrctremp   AND
                              crapavl.tpctrato = 1 
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
           
           IF   NOT AVAILABLE crapavl   THEN
                IF   LOCKED crapavl   THEN
                     DO:
                         ASSIGN aux_cdcritic = 77.
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     LEAVE.
           ELSE
                DELETE crapavl.
           
          LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */

        IF   aux_cdcritic <> 0   THEN
             UNDO, LEAVE.

        /*  Segundo avalista  */
        DO aux_contador = 1 TO 10:

           FIND crapavl WHERE crapavl.cdcooper = par_cdcooper       AND 
                              crapavl.nrdconta = crawepr.nrctaav2   AND
                              crapavl.nrctravd = crawepr.nrctremp   AND
                              crapavl.tpctrato = 1
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
           IF   NOT AVAILABLE crapavl   THEN
                IF   LOCKED crapavl   THEN
                     DO:
                         ASSIGN aux_cdcritic = 77.
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     LEAVE.
           ELSE
                DELETE crapavl.
        
           LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */

        IF   aux_cdcritic <> 0   THEN
             UNDO, LEAVE.

        /* Avalistas terceiros, intervenientes anuentes */
        FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper        AND
                               crapavt.nrdconta = par_nrdconta        AND
                               CAN-DO("1,9",STRING(crapavt.tpctrato)) AND
                               crapavt.nrctremp = par_nrctremp        NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND crabavt WHERE crabavt.cdcooper = crapavt.cdcooper   AND
                                   crabavt.nrdconta = crapavt.nrdconta   AND
                                   crabavt.tpctrato = crapavt.tpctrato   AND
                                   crabavt.nrctremp = crapavt.nrctremp   AND
                                   crabavt.nrcpfcgc = crapavt.nrcpfcgc
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF    NOT AVAIL crabavt   THEN
                      IF   LOCKED crabavt   THEN
                           DO:
                               aux_cdcritic = 77.
                               PAUSE 1 NO-MESSAGE.
                               NEXT.
                           END.
                      ELSE
                           DO:
                               aux_cdcritic = 869.
                               LEAVE.
                           END.

                aux_cdcritic = 0.
                LEAVE.

            END.

            IF   aux_cdcritic <> 0   THEN
                 LEAVE.

            /* Excluir avalista terceiro */
            DELETE crabavt.

        END.

        IF   aux_cdcritic <> 0   THEN
             UNDO, LEAVE.


        /* Bens das propostas */
        FOR EACH crapbpr WHERE crapbpr.cdcooper = par_cdcooper    AND
                               crapbpr.nrdconta = par_nrdconta    AND
                               crapbpr.tpctrpro = 90              AND
                               crapbpr.nrctrpro = par_nrctremp    NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND crabbpr WHERE crabbpr.cdcooper = crapbpr.cdcooper   AND
                                   crabbpr.nrdconta = crapbpr.nrdconta   AND
                                   crabbpr.tpctrpro = crapbpr.tpctrpro   AND
                                   crabbpr.nrctrpro = crapbpr.nrctrpro   AND
                                   crabbpr.idseqbem = crapbpr.idseqbem
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAIL crabbpr   THEN
                     IF   LOCKED crabbpr   THEN
                          DO:
                              aux_cdcritic = 77.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              ASSIGN aux_dscritic = "Descricao dos bens da proposta " +
                                                    "de emprestimo nao encontrada.".
                              LEAVE.
                          END.

                aux_cdcritic = 0.
                LEAVE.

            END.

            IF   aux_cdcritic <> 0  OR
                 aux_dscritic <> "" THEN
                 LEAVE.

            DELETE crabbpr.

        END.

        IF   aux_cdcritic <> 0  OR
             aux_dscritic <> "" THEN
             UNDO, LEAVE.


        /* GRAVAMES dos BENS */
        FOR EACH crapgrv
           WHERE crapgrv.cdcooper = par_cdcooper
             AND crapgrv.nrdconta = par_nrdconta
             AND crapgrv.tpctrpro = 90
             AND crapgrv.nrctrpro = par_nrctremp
              NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND FIRST crabgrv
                     WHERE ROWID(crabgrv) = ROWID(crapgrv)
                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAIL crabgrv THEN
                    IF  LOCKED crabgrv THEN DO:
                        aux_cdcritic = 77.
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                    ELSE DO:
                        ASSIGN aux_dscritic = "Registro do Gravames nao" +
                                              " encontrado.".
                        LEAVE.
                    END.

                aux_cdcritic = 0.
                LEAVE.

            END.

            IF  aux_cdcritic <> 0  OR
                aux_dscritic <> "" THEN
                LEAVE.

            DELETE crabgrv.

        END.

        IF  aux_cdcritic <> 0  OR
            aux_dscritic <> "" THEN
            UNDO, LEAVE.



        /* Proposta */
        DO aux_contador = 1 TO 10:

            FIND crapprp WHERE crapprp.cdcooper = par_cdcooper   AND
                               crapprp.nrdconta = par_nrdconta   AND
                               crapprp.tpctrato = 90             AND
                               crapprp.nrctrato = par_nrctremp
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF    NOT AVAIL crapprp   THEN
                  IF   LOCKED crapprp   THEN
                       DO:
                           aux_cdcritic = 371.
                           PAUSE 1 NO-MESSAGE.
                           NEXT.
                       END.
                  ELSE
                       DO:
                           aux_cdcritic = 510.
                           LEAVE.
                       END.

            aux_cdcritic = 0.
            LEAVE.

        END.

        IF   aux_cdcritic <> 0   THEN
             UNDO, LEAVE.

        DELETE crapprp.

        /* Rendimentos da proposta */
        FOR EACH craprpr WHERE craprpr.cdcooper = par_cdcooper   AND
                               craprpr.nrdconta = par_nrdconta   AND
                               craprpr.tpctrato = 90             AND
                               craprpr.nrctrato = par_nrctremp   NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND crabrpr WHERE crabrpr.cdcooper = craprpr.cdcooper   AND
                                   crabrpr.nrdconta = craprpr.nrdconta   AND
                                   crabrpr.tpctrato = craprpr.tpctrato   AND
                                   crabrpr.nrctrato = craprpr.nrctrato   AND
                                   crabrpr.tpdrendi = craprpr.tpdrendi
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAIL crabrpr   THEN
                     IF   LOCKED crabrpr   THEN
                          DO:
                              aux_cdcritic = 77.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              ASSIGN aux_dscritic = "Registro de rendimento " +
                                                    "do cooperado nao encontrado.".
                              LEAVE.
                          END.

                aux_cdcritic = 0.
                LEAVE.

            END.

            IF   aux_cdcritic <> 0  OR
                 aux_dscritic <> "" THEN
                 LEAVE.

            DELETE crabrpr.

        END.

        IF   aux_cdcritic <> 0  OR
             aux_dscritic <> "" THEN
             UNDO, LEAVE.
        
        FOR EACH crapadt WHERE crapadt.cdcooper = par_cdcooper   AND
                               crapadt.nrdconta = par_nrdconta   AND
                               crapadt.nrctremp = par_nrctremp   AND
                               crapadt.tpctrato = 90             NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND crabadt WHERE crabadt.cdcooper = crapadt.cdcooper   AND
                                   crabadt.nrdconta = crapadt.nrdconta   AND
                                   crabadt.nrctremp = crapadt.nrctremp   AND
                                   crabadt.nraditiv = crapadt.nraditiv   AND 
                                   crabadt.tpctrato = crapadt.tpctrato
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAIL crabadt   THEN
                     IF   LOCKED crabadt   THEN
                          DO:
                              aux_cdcritic = 77.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              ASSIGN aux_dscritic = "Registro de aditivo" +
                                                    "contratual nao encontrado.".
                              LEAVE.
                          END.

                aux_cdcritic = 0.
                LEAVE.

            END.

            IF   aux_cdcritic <> 0  OR
                 aux_dscritic <> "" THEN
                 LEAVE.
    
            IF  crapadt.cdaditiv = 2 THEN /* Aplicações da própria conta da proposta */
                aux_nrdconta = crapadt.nrdconta.
            ELSE IF crapadt.cdaditiv = 3 THEN /* Aplicações de interveniente garantidor */
                aux_nrdconta = crapadt.nrctagar.
            
            FOR EACH crapadi WHERE crapadi.cdcooper = crapadt.cdcooper AND
                                   crapadi.nrdconta = crapadt.nrdconta AND
                                   crapadi.nrctremp = crapadt.nrctremp AND
                                   crapadi.nraditiv = crapadt.nraditiv AND
                                   crapadi.tpctrato = crapadt.tpctrato NO-LOCK:


                IF  crapadi.tpproapl = 1 THEN /* Produto Novo */
                    DO:
                        FOR FIRST craprac FIELDS(cdcooper) WHERE 
                                  craprac.cdcooper = crapadi.cdcooper
                              AND craprac.nrdconta = aux_nrdconta
                              AND craprac.nraplica = crapadi.nraplica
                              AND craprac.idblqrgt = 2 EXCLUSIVE-LOCK. /* Blq.ADITIV */

                            ASSIGN craprac.idblqrgt = 0.
                            VALIDATE craprac.

                        END.
                    END.
                ELSE IF crapadi.tpproapl = 2 THEN /* Produto Antigo */
                    DO:
                        /* DESBLOQUEIA todas as aplicacoes dessa conta e contrato
                           que foram bloqueadas pela tela ADITIV */
                        FIND craptab WHERE craptab.cdcooper = crapadi.cdcooper AND
                                           craptab.nmsistem = "CRED"           AND
                                           craptab.tptabela = "BLQRGT"         AND
                                           craptab.cdempres = 00               AND
                                           craptab.cdacesso = STRING(aux_nrdconta,"9999999999") AND
                                           SUBSTR(craptab.dstextab,1,7) = STRING(crapadi.nraplica,"9999999") AND
                                           SUBSTR(craptab.dstextab,10,1) = "A"
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
                        IF  AVAIL craptab THEN
                            DELETE craptab.
                    END.
    
                DO aux_contador = 1 TO 10:
    
                    FIND crabadi WHERE crabadi.cdcooper = crapadi.cdcooper   AND
                                       crabadi.nrdconta = crapadi.nrdconta   AND
                                       crabadi.nrctremp = crapadi.nrctremp   AND
                                       crabadi.nraditiv = crapadi.nraditiv   AND
                                       crabadi.nrsequen = crapadi.nrsequen   AND
                                       crabadi.tpctrato = crapadt.tpctrato
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                    IF   NOT AVAIL crabadi   THEN
                         IF   LOCKED crabadi   THEN
                              DO:
                                  aux_cdcritic = 77.
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT.
                              END.
                         ELSE
                              DO:
                                  ASSIGN aux_dscritic = "Registro de item do aditivo" +
                                                        "contratual nao encontrado.".
                                  LEAVE.
                              END.
    
                    aux_cdcritic = 0.
                    LEAVE.
    
                END.
    
                IF   aux_cdcritic <> 0  OR
                     aux_dscritic <> "" THEN
                     LEAVE.
                
                DELETE crabadi.
    
            END.
            
            IF   aux_cdcritic <> 0  OR
                 aux_dscritic <> "" THEN
                 LEAVE.

            DELETE crabadt.

        END.

        IF   aux_cdcritic <> 0  OR
             aux_dscritic <> "" THEN
             UNDO, LEAVE.

        
        /* verificar se existe cessao de credito */
        FIND FIRST tbcrd_cessao_credito
            WHERE tbcrd_cessao_credito.cdcooper = par_cdcooper
              AND tbcrd_cessao_credito.nrdconta = par_nrdconta
              AND tbcrd_cessao_credito.nrctremp = par_nrctremp
              EXCLUSIVE-LOCK NO-ERROR.
        IF AVAILABLE tbcrd_cessao_credito THEN      
          DO:
             DELETE tbcrd_cessao_credito.
          END.

        /* Cancelar proposta na Esteira de credito*/
        /* Somente Cancelar a Proposta na Esteira se a mesma 
           foi enviada para analise manual na Esteira  */
        IF crawepr.dtenvest <> ? AND 
           crawepr.insitest >= 2 AND 
           crawepr.cdopeapr <> "MOTOR" AND
           crawepr.cdoperad <> "AUTOCDC" THEN /*Proposta de origem CDC sao cancelada primeiro na IBRATAN/ESTEIRA*/
        DO: 
        
           FIND FIRST crapope  
                WHERE crapope.cdcooper = par_cdcooper             
                  AND crapope.cdoperad = par_cdoperad
                   NO-LOCK NO-ERROR.
                     
           RUN sistema/generico/procedures/b1wgen0195.p
               PERSISTENT SET h-b1wgen0195.
       
           /* Enviar Cancelamento da proposta para esteira*/
           RUN Enviar_proposta_esteira IN h-b1wgen0195        
                             ( INPUT par_cdcooper,
                               INPUT crapope.cdpactra,
                               INPUT par_nrdcaixa,
                               INPUT par_nmdatela,
                               INPUT par_cdoperad,
                               INPUT par_idorigem,
                               INPUT par_nrdconta,
                               INPUT par_dtmvtolt,
                               INPUT par_dtmvtolt,
                               INPUT par_nrctremp, /* nrctremp */
                               INPUT par_nrctremp, /* nrctremp_novo */
                               INPUT "",           /* dsiduser */
                               INPUT 0,            /* flreiflx */
                               INPUT "C",          /* tpenvest */
                              OUTPUT aux_dsmensag, 
                              OUTPUT aux_cdcritic, 
                              OUTPUT aux_dscritic).
           
           DELETE OBJECT h-b1wgen0195.
           
           IF  RETURN-VALUE = "NOK"  THEN
              DO:
                  IF aux_cdcritic = 0 AND 
                     aux_dscritic = "" THEN
                  DO:
                    ASSIGN aux_dscritic = "Nao foi possivel enviar exclusao do " + 
                                          "numero da proposta para Analise de Credito.".
                  END.
                  UNDO, LEAVE.
              END. 
        END.

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_vincula_cobertura_operacao
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT crawepr.idcobope
                                              ,INPUT 0
                                              ,INPUT 0
                                              ,"").

        CLOSE STORED-PROC pc_vincula_cobertura_operacao
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_dscritic  = ""
               aux_dscritic  = pc_vincula_cobertura_operacao.pr_dscritic 
               WHEN pc_vincula_cobertura_operacao.pr_dscritic <> ?.
                        
        IF aux_dscritic <> "" THEN
           UNDO, LEAVE.
        
        /* Excluir proposta */
        DELETE crawepr.

        LEAVE.

    END. /* Fim TRANSACTION , criticas */

    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             IF  par_flgerlog  THEN
                 DO:
                     RUN proc_gerar_log (INPUT par_cdcooper,
                                         INPUT par_cdoperad,
                                         INPUT aux_dscritic,
                                         INPUT aux_dsorigem,
                                         INPUT aux_dstransa,
                                         INPUT FALSE,
                                         INPUT par_idseqttl,
                                         INPUT par_nmdatela,
                                         INPUT par_nrdconta,
                                        OUTPUT aux_nrdrowid).

                     RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                              INPUT "nrctremp",
                                              INPUT par_nrctremp,
                                              INPUT par_nrctremp).
                 END.

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".

         END.

    IF  par_flgerlog  THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).

            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrctremp",
                                     INPUT par_nrctremp,
                                     INPUT par_nrctremp).
        END.

    RETURN "OK".

END PROCEDURE.

/**************************************************************************
 Fazer as validacoes quando a alteraçao for do tipo 'Toda a Proposta de
 'Emprestimo'.
**************************************************************************/
PROCEDURE valida-dados-proposta-completa:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagt2 AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgpagto AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdfinemp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtpreemp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtdialib AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_ddmesnov AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpemprst AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtlibera AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM par_dslcremp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dsfinemp AS CHAR                           NO-UNDO.

    DEF VAR          aux_qtdias   AS INTE                           NO-UNDO.
    DEF VAR          aux_qtdias2  AS INTE                           NO-UNDO.
    DEF VAR          aux_qtdiacar AS INTE                           NO-UNDO.
	DEF VAR          aux_flgcescr AS LOG INIT FALSE                 NO-UNDO.
    DEF VAR          aux_fleprCDC AS LOG INIT FALSE                 NO-UNDO.
    DEF VAR          aux_tpprodut AS INTE                           NO-UNDO.

    DEF BUFFER crablcr FOR craplcr.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.

	/* Condicao para caso a Finalidade for Cessao de Credito */
    FOR FIRST crapfin FIELDS(tpfinali)
                       WHERE crapfin.cdcooper = par_cdcooper AND 
                             crapfin.cdfinemp = par_cdfinemp
                             NO-LOCK: END.

    IF AVAIL crapfin AND crapfin.tpfinali = 1 THEN
       ASSIGN aux_flgcescr = TRUE.

    IF par_nmdatela = "AUTOCDC" OR 
       par_cdoperad = "AUTOCDC" THEN
      ASSIGN aux_fleprCDC = TRUE.

    DO WHILE TRUE:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                           crapass.nrdconta = par_nrdconta
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapass   THEN
             DO:
                 aux_cdcritic = 9.
                 LEAVE.
             END.

        IF   crapass.dtdemiss <> ?     AND
             par_cdlcremp     <> 100   AND 
             NOT aux_flgcescr          THEN  /* Nao validar para cessao de credito */
             DO:
                 aux_cdcritic = 75.
                 LEAVE.
             END.
        
        IF   par_dtdpagto <= par_dtmvtolt   THEN
             DO:
                 aux_dscritic =
                     "Data de pagamento menor/igual que a data do sistema.".
                 LEAVE.
             END.
        
        IF  par_dtlibera = ? THEN
            RUN retornaDataUtil( INPUT par_cdcooper,
                                 INPUT par_dtmvtolt,
                                 INPUT par_qtdialib,
                                OUTPUT par_dtlibera).

        /* Em conversa com Luana (Credito), Irlan e Mirtes, foi definido que esta chamada
           foi cancelada por solicitacao da Luana e sera reavaliada no futuro (chamado 156642)*/
        /*IF MONTH(par_dtlibera) = MONTH(par_dtdpagto) AND 
            YEAR(par_dtlibera) =  YEAR(par_dtdpagto) THEN
        DO:
            aux_dscritic =
            "Nao e permitido data de pagamento no mesmo mes de liberacao.".
            LEAVE.
        END.*/

        IF   NOT par_flgpagto   THEN
             IF  (DAY(par_dtdpagto) > 28 OR par_dtdpagto < par_dtmvtopr)  AND
                 par_tpemprst = 0  THEN
                 DO:
                     aux_cdcritic = 13.
                     LEAVE.
                 END.

        IF   (par_tpemprst = 1 OR par_tpemprst = 2) AND
             DAY(par_dtdpagto) > 27   THEN
             DO:
                 aux_cdcritic = 13.
                 LEAVE.
             END.

        FIND craplcr WHERE craplcr.cdcooper = par_cdcooper   AND
                           craplcr.cdlcremp = par_cdlcremp   NO-LOCK NO-ERROR.

        IF   NOT AVAIL craplcr   THEN
             DO:
                 aux_cdcritic = 363.
                 LEAVE.
             END.

        /* Devolver a descricao da linha */
        ASSIGN par_dslcremp = craplcr.dslcremp.

        IF   NOT craplcr.flgstlcr   THEN
             DO:
                 aux_cdcritic = 470.
                 LEAVE.
             END.

        /* Emprestimo TR */
        IF  par_tpemprst = 0 THEN
            ASSIGN aux_tpprodut = 1.
        ELSE
            ASSIGN aux_tpprodut = par_tpemprst.
        
        /* Validar se a linha de credito esta habilitada para o produto */
        IF craplcr.tpprodut <> aux_tpprodut THEN
           DO:
               ASSIGN aux_dscritic = "Linha nao permitida para esse produto".
               LEAVE.
           END.

        IF   par_cddopcao = "A"   THEN /* Se for alteraçao */
             DO:
                 FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                                    crawepr.nrdconta = par_nrdconta   AND
                                    crawepr.nrctremp = par_nrctremp
                                    NO-LOCK NO-ERROR.

                 /* Se mudou tipo de contrato  ... */
                 IF    AVAIL crawepr   THEN
                       DO:
                           FIND crablcr WHERE
                                crablcr.cdcooper = par_cdcooper AND
                                crablcr.cdlcremp = crawepr.cdlcremp
                                NO-LOCK NO-ERROR.

                           IF   crablcr.tpctrato <> craplcr.tpctrato   THEN
                                DO:
                                    aux_cdcritic = 567.
                                    LEAVE.
                                END.
                       END.
             END.

        IF   craplcr.nrctacre > 0   AND   par_qtdialib > 0   THEN
             DO:
                 aux_cdcritic = 26.
                 LEAVE.
             END.

        IF   craplcr.flgcrcta = NO  AND   par_qtdialib > 0   THEN
             DO:
                aux_cdcritic = 26.
                LEAVE.
             END.

        IF   craplcr.tpdescto = 2   THEN
             DO:
                 FIND crapemp WHERE crapemp.cdcooper = par_cdcooper AND
                                    crapemp.cdempres = par_cdempres
                                     NO-LOCK NO-ERROR.

                 IF   NOT AVAILABLE crapemp   OR   crapemp.indescsg = 1   THEN
                      DO:
                          aux_cdcritic = 817.
                          LEAVE.
                   END.

             END.

        FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                           craptab.nmsistem = "CRED"       AND
                           craptab.tptabela = "GENERI"     AND
                           craptab.cdempres = 0            AND
                           craptab.cdacesso = "DIADOPAGTO" AND
                           craptab.tpregist = par_cdempres NO-LOCK NO-ERROR.

        IF   NOT AVAIL craptab   THEN
             DO:                     
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Falta cadastro da empresa " + STRING(par_cdempres) + ".".

                LEAVE.
             END.

        /* Finalidade da operaçao */
        FIND crapfin WHERE crapfin.cdcooper = par_cdcooper   AND
                           crapfin.cdfinemp = par_cdfinemp
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapfin   THEN
             DO:
                 aux_cdcritic = 362.
                 LEAVE.
             END.

        /* Devolver a descricao da finalidade */
        ASSIGN par_dsfinemp = crapfin.dsfinemp.

        IF   NOT crapfin.flgstfin   THEN
             DO:
                 aux_cdcritic = 469.
                 LEAVE.
             END.

        FIND craplch WHERE craplch.cdcooper = par_cdcooper AND
                           craplch.cdfinemp = par_cdfinemp AND
                           craplch.cdlcrhab = par_cdlcremp
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL craplch THEN
             DO:
                 aux_cdcritic = 364.
                 LEAVE.
             END.

        IF   par_qtpreemp = 0   THEN
             DO:
                 aux_cdcritic = 842.
                 LEAVE.
             END.

        IF   par_dtlibera >= par_dtdpagto   THEN
             DO:
                 aux_dscritic = "Atencao! A data de liberacao do recurso e "         +
                                "igual ou menor que a data do primeiro vencimento. " +
                                "Altere a data de vencimento na proposta".
                 LEAVE.
             END.

        IF   par_tpemprst = 0   THEN
             DO:
                 ASSIGN aux_qtdiacar =  IF   craplcr.qtcarenc <> 0   THEN
                                             craplcr.qtcarenc
                                        ELSE
                                   INTEGER(SUBSTRING(craptab.dstextab,10,3))

                        aux_qtdias  = IF   par_cdcooper = 6   THEN
                                           61
                                      ELSE
                                      IF   par_cdcooper = 2   THEN
                                           IF   par_cddopcao = "A"  THEN
                                                50
                                           ELSE
                                                90
                                      ELSE
                                           46

                        aux_qtdias2 = IF   par_cddopcao = "A"   THEN
                                           50
                                      ELSE
                                      IF   par_cdcooper = 2   THEN
                                           90
                                      ELSE
                                           50.

                 /* Criticar carencia */
                 IF  CAN-DO("4,5",STRING(par_cdcooper)) OR
                     craplcr.qtcarenc <> 0              THEN
                     DO:
                         IF   par_dtdpagto - par_dtmvtolt > aux_qtdiacar   THEN
                              DO:
                                  aux_dscritic =
                             "Data de pagamento superior a carencia da linha.".
                                  LEAVE.
                              END.
                     END.
                 ELSE
                 IF  NOT par_flgpagto   THEN
                     DO:
                         IF   (DAY (par_dtmvtolt) >= par_ddmesnov AND
                              (par_dtdpagto - par_dtmvtolt) > aux_qtdias)
                                                                           OR
                              (DAY (par_dtmvtolt) <  par_ddmesnov AND
                              (par_dtdpagto - par_dtmvtolt) > aux_qtdias2) THEN
                              DO:
                                  IF   par_cdcooper = 9  AND
                                       CAN-DO("3,7,8,102,34,35,36,103,29",STRING(
                                           par_cdlcremp)) THEN
                                       .
                                  ELSE
                                       DO:
                                           aux_cdcritic = 13.
                                           LEAVE.
                                       END.
                              END.

                         IF   DAY(par_dtmvtolt) > par_ddmesnov   THEN
                              IF   par_dtdpagto > par_dtdpagt2   THEN
                                   DO:
                                       IF   par_cdcooper <> 6   THEN
                                            DO:
                                                aux_cdcritic = 13.
                                                LEAVE.
                                            END.
                                   END.
                     END.
             END.
        ELSE     /* tpemprst = 1 */
             DO:
                 ASSIGN aux_qtdiacar = craplcr.qtcarenc.

                 IF   aux_qtdiacar <> 0 AND aux_qtdiacar <> ? THEN
                      DO:
                          IF   par_dtdpagto - par_dtlibera > aux_qtdiacar   THEN
                               DO:
                                    ASSIGN aux_dscritic =
                                     "Carencia da linha deve ser ate " +
                                       TRIM (STRING(aux_qtdiacar,"zz9")) +
                                        " dias." .
                                    LEAVE.
                               END.
                      END.
                 ELSE
                      DO: /* Temporariamente solicitado para ficar 60 dias
                             Foi mantido o IF e ELSE pois será reavaliado
                             pelo negócio essa carência e será alterado
                             posteriormente */

                          IF   DAY(par_dtlibera) <= 19   THEN
                               DO:
                                   IF   par_dtdpagto - par_dtlibera > 60   THEN
                                        DO:
                                            ASSIGN aux_dscritic =
                                          "Carencia da linha deve ser ate 60" +
                                          " dias." .
                                            LEAVE.
                                        END.
                               END.
                          ELSE
                               DO:
                                   IF   par_dtdpagto - par_dtlibera > 60   THEN
                                        DO:
                                            ASSIGN aux_dscritic =
                                          "Carencia da linha deve ser ate 60" +
                                          " dias." .
                                            LEAVE.
                                        END.
                               END.
                      END.
             END.

        LEAVE.

    END. /* Fim tratamento de criticas */

    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE retornaDataUtil:

    DEF  INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                               NO-UNDO.
    DEF  INPUT PARAM par_qtdialib AS INTE                               NO-UNDO.
    DEF OUTPUT PARAM par_datadper AS DATE                               NO-UNDO.


    /* Funcao para calcular proxima data util a partir do numero de dias uteis
       informado */

    DEF VAR aux_nrdialib AS INTE                                     NO-UNDO.
    DEF VAR aux_datadper AS DATE                                     NO-UNDO.

    ASSIGN aux_datadper = par_dtiniper.

    DO  WHILE aux_nrdialib < par_qtdialib:

        ASSIGN aux_datadper = aux_datadper + 1.

        IF    NOT CAN-DO ("1,7",STRING(WEEKDAY(aux_datadper)))   AND
              NOT CAN-FIND(crapfer WHERE
                           crapfer.cdcooper = par_cdcooper AND
                           crapfer.dtferiad = aux_datadper)     THEN
              ASSIGN aux_nrdialib = aux_nrdialib + 1.

    END.

    ASSIGN par_datadper = aux_datadper.

    RETURN "OK".

END PROCEDURE.


/*............................ PROCEDURES INTERNAS ..........................*/

PROCEDURE obtem-dados-conta-contrato:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcalcul AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgcondc AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_lsdtelas AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocged AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_permulta AS DECI                           NO-UNDO.
    DEF       OUTPUT PARAM TABLE FOR tt-erro.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-dados-epr.

    DEF VAR aux_dsdpagto AS CHAR                                    NO-UNDO.
    DEF VAR aux_qtaditiv AS INTE                                    NO-UNDO.
    DEF VAR aux_qtmesdec AS DECI                                    NO-UNDO.
    DEF VAR aux_qtpreemp AS DECI                                    NO-UNDO.
    DEF VAR aux_vlpreapg AS DECI                                    NO-UNDO.
    DEF VAR aux_vlmrapar LIKE crappep.vlmrapar                      NO-UNDO.
    DEF VAR aux_vlmtapar LIKE crappep.vlmtapar                      NO-UNDO.
    DEF VAR aux_vliofcpl LIKE crappep.vliofcpl                      NO-UNDO.
    DEF VAR aux_vlpreemp LIKE crapepr.vlpreemp                      NO-UNDO.
    DEF VAR aux_flgatras AS LOGI                                    NO-UNDO.
    DEF VAR aux_vlprvenc AS DECI                                    NO-UNDO.
    DEF VAR aux_vlpraven AS DECI                                    NO-UNDO.
    DEF VAR aux_flpgmujm AS LOG                                     NO-UNDO.
    DEF VAR aux_portabilidade AS CHAR                               NO-UNDO.
    DEF VAR aux_err_efet AS INTE                                    NO-UNDO.

    DEF VAR aux_nrctremp_migrado AS INTE                            NO-UNDO.
    DEF VAR aux_exibe_migrado    AS LOGI                            NO-UNDO.

    DEF VAR aux_liquidia AS INTE                                    NO-UNDO.

    DEF VAR h-b1wgen0084a AS HANDLE                                 NO-UNDO.

    DEF BUFFER crabass FOR crapass.

    DEF BUFFER crapepr_migrado FOR crapepr.

    FIND craplcr WHERE craplcr.cdcooper = par_cdcooper    AND
                       craplcr.cdlcremp = crapepr.cdlcremp 
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craplcr  THEN
        DO:
            ASSIGN aux_cdcritic = 363
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).

            RETURN "NOK".
        END.

    /* Verifica se cobra multa */
    IF NOT craplcr.flgcobmu THEN
       ASSIGN par_permulta = 0.

    aux_dslcremp = TRIM(STRING(craplcr.cdlcremp,"zzz9")) + "-" + craplcr.dslcremp.

    /* Somente quando for tela atenda prestacoes, nao deve listar*/
    ASSIGN aux_exibe_migrado = FALSE
           aux_nrctremp_migrado = 0.
    IF par_nmdatela='ATENDA' THEN
        DO:
          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

          /* Efetuar a chamada a rotina Oracle  */
          RUN STORED-PROCEDURE pc_verifica_empr_migrado
              aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /*pr_cdcooper*/
                                                   INPUT par_nrdconta, /*pr_nrdconta*/
                                                   INPUT crapepr.nrctremp, /*pr_nrctrnov*/
                                                   INPUT 1, /*pr_tpempmgr*/
                                                   OUTPUT 0,    /* pr_nrctremp */
                                                   OUTPUT 0,    /* pr_cdcritic */
                                                   OUTPUT "").  /* pr_dscritic */

          /* Fechar o procedimento para buscarmos o resultado */
          CLOSE STORED-PROC pc_verifica_empr_migrado
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
          
          ASSIGN aux_nrctremp_migrado = pc_verifica_empr_migrado.pr_nrctremp
                                       WHEN pc_verifica_empr_migrado.pr_nrctremp <> ?
                 aux_cdcritic        = pc_verifica_empr_migrado.pr_cdcritic
                                       WHEN pc_verifica_empr_migrado.pr_cdcritic <> ?
                 aux_dscritic        = pc_verifica_empr_migrado.pr_dscritic
                                       WHEN pc_verifica_empr_migrado.pr_dscritic <> ?.

          IF  aux_cdcritic <> 0   OR
              aux_dscritic <> ""  THEN
              DO:
                  aux_cdcritic = 0.
                  aux_dscritic = "".
              END.

          /* se o emprestimo foi migrado carrrega os dados para validacao do regitro*/
          IF aux_nrctremp_migrado > 0 THEN
              DO:
                  FOR FIRST crapepr_migrado FIELDS(nrctremp)
                                            WHERE crapepr_migrado.cdcooper = par_cdcooper AND
                                                  crapepr_migrado.nrdconta = par_nrdconta AND
                                                  crapepr_migrado.nrctremp = crapepr.nrctremp AND 
                                                  NOT (CAN-DO(par_lsdtelas,par_nmdatela) OR
                                                              crapepr_migrado.inliquid = 0 OR
                                                              crapepr_migrado.inprejuz = 1 OR
                                                             (crapepr_migrado.inliquid = 1 AND
                                                              crapepr_migrado.inprejuz = 0 AND
                                                              crapepr_migrado.dtultpag + craplcr.nrdialiq >= par_dtmvtolt)) 
                                           NO-LOCK: END.

                  IF NOT AVAIL crapepr_migrado THEN
                      ASSIGN aux_exibe_migrado = TRUE.

              END.
          END.    

    /*se nao for migrado ou o contrato migrado nao aparecer 
      quando um contrato e migrado ele somente some quando o migrado sumir */
    IF aux_nrctremp_migrado = 0 OR not aux_exibe_migrado THEN
        DO:
    /*********************************************************************
      Mostrar emprestimos em aberto (nao liquidados), emprestimos que
      estao em prejuizo, e emprestimos liquidados sem prejuizo que ainda
      podem ser visualizados conforme campo craplcr.nrdialiq cadastrado
      na tela LCREDI. A ultima condicao e utilizada conforme o parametro
      par_flgcondic for alimentando.
    *********************************************************************/

    IF  NOT (CAN-DO(par_lsdtelas,par_nmdatela) OR
             crapepr.inliquid = 0              OR
             crapepr.inprejuz = 1              OR
            (par_flgcondc                      AND
             crapepr.inliquid = 1              AND
             crapepr.inprejuz = 0              AND
             crapepr.dtultpag + craplcr.nrdialiq >= par_dtmvtolt))  THEN
        NEXT.
          END.
    
    IF  tab_inusatab AND crapepr.inliquid = 0  THEN
        ASSIGN aux_txdjuros = craplcr.txdiaria.
    ELSE
        ASSIGN aux_txdjuros = crapepr.txjuremp.

    /** Inicialiazacao das variaves para a rotina de calculo **/
    ASSIGN aux_nrdconta = crapepr.nrdconta
           aux_nrctremp = crapepr.nrctremp
           aux_vlsdeved = crapepr.vlsdeved
           aux_vljuracu = crapepr.vljuracu
           aux_vlmrapar = 0
           aux_vliofcpl = 0   
           aux_vlmtapar = 0
           aux_qtprecal = IF  crapepr.inliquid = 0  THEN
                              crapepr.qtprecal
                          ELSE
                              crapepr.qtpreemp
           aux_dtcalcul = par_dtcalcul
           aux_dtultdia = ((DATE(MONTH(par_dtmvtolt),28,YEAR(par_dtmvtolt))
                          + 4) - DAY(DATE(MONTH(par_dtmvtolt),28,
                          YEAR(par_dtmvtolt)) + 4)).

    /** Rotina para calculo do saldo devedor **/
    { sistema/generico/includes/b1wgen0002.i }

    /** Verifica se deve deixar saldo provisionado no chq. sal **/
    IF   tab_indpagto = 0   THEN
         aux_dtrefere = aux_dtultdia - DAY(aux_dtultdia).
    ELSE
         aux_dtrefere = aux_dtultdia.

    IF   crapepr.tpemprst = 0   THEN
         DO:
             ASSIGN aux_qtprecal = aux_qtprecal +
                                    IF   crapepr.inliquid = 0  THEN
                                         lem_qtprecal
                                    ELSE
                                         0.
         END.

    ASSIGN aux_vldescto = 0
           aux_vlprovis = 0
           aux_cdpesqui = STRING(crapepr.dtmvtolt,"99/99/9999") + "-" +
                          STRING(crapepr.cdagenci,"999")        + "-" +
                          STRING(crapepr.cdbccxlt,"999")        + "-" +
                          STRING(crapepr.nrdolote,"999999")
           aux_qtpreapg = IF  crapepr.qtpreemp < aux_qtprecal  THEN
                              0
                          ELSE
                              crapepr.qtpreemp - aux_qtprecal
           aux_dsdpagto = IF  crapepr.flgpagto  THEN
                              "Debito em C/C vinculado ao credito" +
                              " da folha"
                          ELSE
                              "Debito em C/C no dia " +
                              STRING(DAY(crapepr.dtdpagto),"99") + " (" +
                              STRING(crapepr.dtdpagto,"99/99/9999") + ")".

    FIND crawepr WHERE crawepr.cdcooper = par_cdcooper     AND
                       crawepr.nrdconta = crapepr.nrdconta AND
                       crawepr.nrctremp = crapepr.nrctremp NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crawepr  THEN
        ASSIGN aux_dtinipag = crapepr.dtdpagto.
    ELSE
        ASSIGN aux_dtinipag = crawepr.dtdpagto.

    IF  MONTH(crapepr.dtmvtolt) = MONTH(par_dtmvtolt)  AND
        YEAR(crapepr.dtmvtolt)  = YEAR(par_dtmvtolt)   THEN
        ASSIGN aux_dtinipag = crapepr.dtdpagto.

    /** Leitura da descricao da finalidade do emprestimo **/
    FIND crapfin WHERE crapfin.cdcooper = par_cdcooper     AND
                       crapfin.cdfinemp = crapepr.cdfinemp
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapfin  THEN
        aux_dsfinemp = TRIM(STRING(crapepr.cdfinemp,"zz9")) + "-" +
                       "N/CADASTRADA!".
    ELSE
        aux_dsfinemp = TRIM(STRING(crapfin.cdfinemp,"zz9")) + "-" +
                       crapfin.dsfinemp.

    ASSIGN aux_qtaditiv = 0.

    FOR EACH crapadt WHERE crapadt.cdcooper = par_cdcooper     AND
                           crapadt.nrdconta = par_nrdconta     AND
                           crapadt.nrctremp = crapepr.nrctremp AND
                           crapadt.tpctrato = 90 /* Emprestimo/Financiamento */
                           NO-LOCK:

        ASSIGN aux_qtaditiv = aux_qtaditiv + 1.

    END.

    ASSIGN aux_dsdaval1 = " "
           aux_dsdaval2 = " "
           aux_dsdavali = " ".

    /** Avalistas - Terceiros **/
    FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper     AND
                           crapavt.nrdconta = crapepr.nrdconta AND
                           crapavt.nrctremp = crapepr.nrctremp AND
                           crapavt.tpctrato = 1                NO-LOCK:

        IF  crapepr.nrctaav1 = 0 AND aux_dsdaval1 = " "  THEN
            ASSIGN aux_dsdaval1 = STRING(crapavt.nrcpfcgc) + " - " +
                                  crapavt.nmdavali
                   aux_dsdavali = "Aval " + STRING(crapavt.nrcpfcgc).
        ELSE
        IF  crapepr.nrctaav2 = 0 AND aux_dsdaval2 = " "  THEN
            ASSIGN aux_dsdaval2 = STRING(crapavt.nrcpfcgc) + " - " +
                                  crapavt.nmdavali
                   aux_dsdavali = (IF  aux_dsdavali <> " "  THEN
                                       aux_dsdavali + "/"
                                   ELSE
                                       "") +
                                   "Aval " + STRING(crapavt.nrcpfcgc).

    END.

    /** Busca o nome do primeiro availista **/
    IF  crapepr.nrctaav1 <> 0  THEN
        DO:
            FIND crabass WHERE crabass.cdcooper = par_cdcooper     AND
                               crabass.nrdconta = crapepr.nrctaav1
                               NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE crabass   THEN
                aux_dsdaval1 = STRING(crapepr.nrctaav1,"zzzz,zzz,9") +
                               ": Nao cadastrado!!!".
            ELSE
                aux_dsdaval1 = STRING(crapepr.nrctaav1,"zzzz,zzz,9") + ": " +
                               SUBSTRING(crabass.nmprimtl,1,14) + "...".

            ASSIGN aux_dsdavali = "Aval " +
                                  TRIM(STRING(crapepr.nrctaav1,"zzzz,zzz,9")) +
                                 (IF  aux_dsdavali <> " "  THEN
                                      "/" + aux_dsdavali
                                  ELSE
                                      "").
        END.

    /** Busca o nome do segundo availista **/
    IF  crapepr.nrctaav2 <> 0  THEN
        DO:
            FIND crabass WHERE crabass.cdcooper = par_cdcooper     AND
                               crabass.nrdconta = crapepr.nrctaav2
                               NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE crabass   THEN
                aux_dsdaval2 = STRING(crapepr.nrctaav2,"zzzz,zzz,9") +
                               ": Nao cadastrado!!!".
            ELSE
                aux_dsdaval2 = STRING(crapepr.nrctaav2,"zzzz,zzz,9") + ": " +
                               SUBSTRING(crabass.nmprimtl,1,14) + "...".

            ASSIGN aux_dsdavali = (IF  aux_dsdavali <> " "  THEN
                                       aux_dsdavali + "/"
                                   ELSE
                                       "") +
                                  "Aval " +
                                  TRIM(STRING(crapepr.nrctaav2,"zzzz,zzz,9")).
        END.


    IF   crapepr.tpemprst = 1   OR   /* Pre-Fixado */
         crapepr.tpemprst = 2   THEN /* Pos-Fixado */
         DO:
             ASSIGN aux_vljurmes = crapepr.vljurmes
                    aux_flgatras = FALSE.

             FIND crapdat WHERE crapdat.cdcooper = par_cdcooper
                                NO-LOCK NO-ERROR.

             FOR EACH crappep WHERE
                      crappep.cdcooper = par_cdcooper       AND
                      crappep.nrdconta = par_nrdconta       AND
                      crappep.nrctremp = crapepr.nrctremp   AND
                      crappep.inliquid = 0                  NO-LOCK:

                      /* Parcela em dia */
                 IF   crappep.dtvencto >  crapdat.dtmvtoan   AND
                      crappep.dtvencto <= crapdat.dtmvtolt   THEN
                      ASSIGN aux_flgatras = FALSE.
                 ELSE /* Parcela Vencida */
                 IF   crappep.dtvencto < crapdat.dtmvtolt   THEN
                      DO:
                          ASSIGN aux_flgatras = TRUE.
                          LEAVE.
                      END.
                 ELSE /* Parcela a vencer */
                 IF   crappep.dtvencto > crapdat.dtmvtolt   THEN
                      ASSIGN aux_flgatras = FALSE.

             END.
         END.
    ELSE
         DO:
             ASSIGN aux_flgatras = NO.
         END.

	/*** PORTABILIDADE - Verifica se eh uma proposta de portabilidade **/

    RUN possui_portabilidade (INPUT par_cdcooper,
                              INPUT par_nrdconta,
                              INPUT crapepr.nrctremp,
                             OUTPUT aux_err_efet,
                             OUTPUT aux_portabilidade,
                             OUTPUT aux_cdcritic,
                             OUTPUT aux_dscritic).

	ASSIGN aux_portabilidade = RETURN-VALUE.

	/*** FIM - PORTABILIDADE - Verifica se eh uma proposta de portabilidade **/

    /* Verifica se contrato pode ser liquidado */
    aux_liquidia = 0.

    IF  crapepr.dtmvtolt = par_dtmvtolt THEN
        aux_liquidia = 1.

    IF crapepr.vlsdeved <= 0 THEN
        aux_liquidia = 0.
             
    CREATE tt-dados-epr.
    ASSIGN tt-dados-epr.nrdconta = par_nrdconta
           tt-dados-epr.nmprimtl = par_nmprimtl
           tt-dados-epr.cdagenci = crapepr.cdagenci
           tt-dados-epr.nrctremp = crapepr.nrctremp
           tt-dados-epr.vlemprst = crapepr.vlemprst
           tt-dados-epr.vlsdeved = aux_vlsdeved
           tt-dados-epr.vlpreemp = crapepr.vlpreemp
           tt-dados-epr.vlprepag = aux_vlprepag
           tt-dados-epr.cdpesqui = aux_cdpesqui
           tt-dados-epr.txjuremp = aux_txdjuros
           tt-dados-epr.vljurmes = aux_vljurmes
           tt-dados-epr.vljuracu = aux_vljuracu
           tt-dados-epr.vlprovis = aux_vlprovis
           tt-dados-epr.cdlcremp = crapepr.cdlcremp
           tt-dados-epr.dslcremp = aux_dslcremp
           tt-dados-epr.cdfinemp = crapepr.cdfinemp
           tt-dados-epr.dsfinemp = aux_dsfinemp
           tt-dados-epr.dsdaval1 = aux_dsdaval1
           tt-dados-epr.dsdaval2 = aux_dsdaval2
           tt-dados-epr.dsdavali = aux_dsdavali
           tt-dados-epr.flgpagto = crapepr.flgpagto
           tt-dados-epr.dtdpagto = crapepr.dtdpagto
           tt-dados-epr.inprejuz = crapepr.inprejuz
           tt-dados-epr.dtmvtolt = crapepr.dtmvtolt
           tt-dados-epr.qtpreemp = crapepr.qtpreemp
           tt-dados-epr.dtultpag = crapepr.dtultpag
           tt-dados-epr.qtaditiv = aux_qtaditiv
           tt-dados-epr.dsdpagto = aux_dsdpagto
           tt-dados-epr.tplcremp = craplcr.tpctrato
           tt-dados-epr.permulta = par_permulta
           tt-dados-epr.tpemprst = crapepr.tpemprst
           tt-dados-epr.cdtpempr = "0,1,2"
           tt-dados-epr.dstpempr = "Cálculo Atual,Pré-Fixada,Pós-Fixado"
           tt-dados-epr.perjurmo = craplcr.perjurmo
           tt-dados-epr.inliquid = crapepr.inliquid
           tt-dados-epr.flgatras = aux_flgatras
           tt-dados-epr.flgdigit = crapepr.flgdigit
           tt-dados-epr.tpdocged = par_tpdocged
           tt-dados-epr.qtlemcal = lem_qtprecal
           tt-dados-epr.vlmrapar = aux_vlmrapar
           tt-dados-epr.vliofcpl = aux_vliofcpl
           tt-dados-epr.vlmtapar = aux_vlmtapar
           tt-dados-epr.vlprvenc = aux_vlprvenc
           tt-dados-epr.vlpraven = aux_vlpraven
           tt-dados-epr.flgpreap = FALSE
           tt-dados-epr.cdorigem = crapepr.cdorigem
        
           tt-dados-epr.vlttmupr = crapepr.vlttmupr
           tt-dados-epr.vlttjmpr = crapepr.vlttjmpr
           tt-dados-epr.vlpgmupr = crapepr.vlpgmupr
           tt-dados-epr.vlpgjmpr = crapepr.vlpgjmpr
		   tt-dados-epr.qtimpctr = crapepr.qtimpctr	
           tt-dados-epr.portabil = aux_portabilidade
           tt-dados-epr.liquidia = aux_liquidia
           tt-dados-epr.dtapgoib = crapepr.dtapgoib
           tt-dados-epr.vliofcpl = crapepr.vliofcpl
           /* IOF Prejuizo */
           tt-dados-epr.vltiofpr = crapepr.vltiofpr
           tt-dados-epr.vlpiofpr = crapepr.vlpiofpr.
           
         

    IF  crapepr.tpemprst = 1  THEN /* Price Pre-Fixada */
        DO:
            ASSIGN tt-dados-epr.txmensal = crapepr.txmensal
                   tt-dados-epr.dsidenti = "*"
                   tt-dados-epr.tipoempr = "PP".
        END.
    ELSE IF crapepr.tpemprst = 2 THEN /* Price Pos-Fixado */
        DO:
            ASSIGN tt-dados-epr.txmensal = crapepr.txmensal
                   tt-dados-epr.dsidenti = ""
                   tt-dados-epr.tipoempr = "POS".
        END.
    ELSE IF crapepr.tpemprst = 0 THEN /* Price TR */
        DO:
            ASSIGN tt-dados-epr.txmensal = craplcr.txmensal
                   tt-dados-epr.dsidenti = ""
                   tt-dados-epr.tipoempr = "TR".
        END.

    IF  AVAIL crawepr THEN
        DO:
            ASSIGN tt-dados-epr.flgimppr = crawepr.flgimppr
                   tt-dados-epr.flgimpnp = crawepr.flgimpnp
                   tt-dados-epr.nrdrecid = INTE(RECID(crawepr))
                   tt-dados-epr.qtpromis = crawepr.qtpromis
                   tt-dados-epr.dtpripgt = crawepr.dtdpagto
                   tt-dados-epr.idcobope = crawepr.idcobope.
                   /*tt-dados-epr.nrseqrrq = */
        END.

    /** Prejuizo **/
    IF  tt-dados-epr.inprejuz > 0  THEN
        DO:
            ASSIGN tt-dados-epr.vlprejuz = crapepr.vlprejuz
                   tt-dados-epr.dtprejuz = crapepr.dtprejuz
                   tt-dados-epr.vljraprj = crapepr.vljraprj
                   tt-dados-epr.vljrmprj = crapepr.vljrmprj
                   tt-dados-epr.slprjori = crapepr.vlprejuz.

            /* IOF */
            ASSIGN tt-dados-epr.vltiofpr = crapepr.vltiofpr
                   tt-dados-epr.vlpiofpr = crapepr.vlpiofpr.                 
            
            /* Daniel */
            ASSIGN  aux_flpgmujm          = FALSE
                    tt-dados-epr.vlsdprej = crapepr.vlsdprej +
                               (tt-dados-epr.vlttmupr - tt-dados-epr.vlpgmupr ) +
                               (tt-dados-epr.vlttjmpr - tt-dados-epr.vlpgjmpr ) +
                               (tt-dados-epr.vltiofpr - tt-dados-epr.vlpiofpr ).

            /* Verificacao para saber se foi pago multa e juros de mora */
            IF tt-dados-epr.vlttmupr - tt-dados-epr.vlpgmupr <= 0  AND
               tt-dados-epr.vlttjmpr - tt-dados-epr.vlpgjmpr <= 0  THEN
               ASSIGN aux_flpgmujm = TRUE.

            FOR EACH craplem WHERE craplem.cdcooper = par_cdcooper     AND
                                   craplem.nrdconta = crapepr.nrdconta AND
                                   craplem.nrctremp = crapepr.nrctremp
                                   NO-LOCK:

                IF  craplem.cdhistor = 391  OR   /** pagto prejuizo **/
                    craplem.cdhistor = 382  OR   /** pagto prejuizo orig **/
                    craplem.cdhistor = 2388  OR  /* 2388 - PAGAMENTO DE PREJUIZO VALOR PRINCIPAL */
                    craplem.cdhistor = 2473  OR  /* 2473 - PAGAMENTO JUROS +60 PREJUIZO */
                    craplem.cdhistor = 2389  OR  /* 2389 - PAGAMENTO JUROS PREJUIZO */
                    craplem.cdhistor = 2390  OR  /* 2390 - PAGAMENTO MULTA ATRASO PREJUIZO */
                    craplem.cdhistor = 2475     /* 2475 - PAGAMENTO JUROS MORA PREJUIZO */
                    THEN 
                    ASSIGN tt-dados-epr.vlrpagos = tt-dados-epr.vlrpagos +
                                                   craplem.vllanmto.

                IF  craplem.cdhistor = 2392  OR   /* 2392 - ESTORNO PAGAMENTO DE PREJUIZO VALOR PRINCIPAL */
                    craplem.cdhistor = 2474  OR   /* 2474 - ESTORNO PAGAMENTO JUROS +60 PREJUIZO */
                    craplem.cdhistor = 2393  OR  /* 2393 - ESTORNO PAGAMENTO DE JUROS PREJUIZO */
                    craplem.cdhistor = 2394  OR  /* 2394 - ESTORNO PAGAMENTO MULTA ATRASO PREJUIZO */
                    craplem.cdhistor = 2476  
                    THEN 
                    ASSIGN tt-dados-epr.vlrpagos = tt-dados-epr.vlrpagos -
                                                   craplem.vllanmto.

                /* Somente sera mostrado o valor do Saldo Prejuizo Original,
                   quando o valor da multa e juros de mora for pago total   */
                IF  ((aux_flpgmujm) AND
                     (craplem.cdhistor = 382 OR craplem.cdhistor = 383))  THEN
                    ASSIGN tt-dados-epr.slprjori = tt-dados-epr.slprjori -
                                                   craplem.vllanmto.

                IF  craplem.cdhistor = 383 OR craplem.cdhistor = 2391 THEN
                    ASSIGN tt-dados-epr.vlrabono = tt-dados-epr.vlrabono + craplem.vllanmto.
                    
                IF  craplem.cdhistor = 2395 THEN
                    ASSIGN tt-dados-epr.vlrabono = tt-dados-epr.vlrabono - craplem.vllanmto.

                IF  craplem.cdhistor = 390  THEN  /** pagto outras desp **/
                    ASSIGN tt-dados-epr.vlacresc = tt-dados-epr.vlacresc +
                                                   craplem.vllanmto.

            END. /** Fim do FOR EACH craplem **/

            /* desconta o abono do pagamento */
            ASSIGN tt-dados-epr.vlrpagos = tt-dados-epr.vlrpagos - tt-dados-epr.vlrabono.
            
            /* busca o IOF*/
            FOR EACH craplcm WHERE craplcm.cdcooper = par_cdcooper     AND
                                   craplcm.nrdconta = crapepr.nrdconta AND
                                   craplcm.cdpesqbb = STRING(crapepr.nrctremp, "zz.zzz.zz9") AND
                                   craplcm.cdagenci = 1                AND
                                   craplcm.cdbccxlt = 100              AND
                                   craplcm.cdoperad = '1'              AND
                                   craplcm.nrdolote = 8457             AND
                                   craplcm.cdhistor = 2317             
                                   NO-LOCK:
                              
               ASSIGN tt-dados-epr.vlrpagos = tt-dados-epr.vlrpagos +
                                                   craplem.vllanmto.

            END. /* LOOP LCM*/
            

            /* Como nao tem historico para multa e juros de mora, precisamos
               diminuir do valor total pago da multa e juros de mora      */
            IF aux_flpgmujm THEN
               DO:
                   ASSIGN tt-dados-epr.slprjori = tt-dados-epr.slprjori  + 
                                                  (tt-dados-epr.vlpgmupr + 
                                                   tt-dados-epr.vlpgjmpr).
               END.

            IF  tt-dados-epr.slprjori < 0  THEN
                ASSIGN tt-dados-epr.slprjori = 0.
        END.

    IF   crapepr.tpemprst = 1  OR
         crapepr.tpemprst = 2  THEN
         tt-dados-epr.qtmesdec = crapepr.qtmesdec.
    ELSE
         DO:
            IF  NOT crapepr.flgpagto  THEN /** Conta **/
                IF  MONTH(crapepr.dtdpagto) = MONTH(par_dtmvtolt)  AND
                    YEAR(crapepr.dtdpagto)  = YEAR(par_dtmvtolt)   THEN
                    /** Ainda nao pagou no mes **/
                    IF  crapepr.dtdpagto <= par_dtmvtolt  THEN
                        tt-dados-epr.qtmesdec = crapepr.qtmesdec + 1.
                    ELSE
                        tt-dados-epr.qtmesdec = crapepr.qtmesdec.
                ELSE
                    IF  MONTH(crapepr.dtmvtolt) = MONTH(par_dtmvtolt)  AND
                        YEAR(crapepr.dtmvtolt)  = YEAR(par_dtmvtolt)   THEN
                        /** Contrato do mes **/
                        IF  MONTH(aux_dtinipag) = MONTH(par_dtmvtolt)  AND
                            YEAR(aux_dtinipag)  = YEAR(par_dtmvtolt)   THEN
                            /** Devia ter pago a primeira no mes do contrato **/
                            tt-dados-epr.qtmesdec = crapepr.qtmesdec + 1.
                        ELSE
                            /** Paga a primeira somente no mes seguinte **/
                            tt-dados-epr.qtmesdec = crapepr.qtmesdec.
                    ELSE
                        DO:
                            IF  (crapepr.dtdpagto < par_dtmvtolt             AND
                                DAY(crapepr.dtdpagto) <= DAY(par_dtmvtolt))  OR
                                crapepr.dtdpagto > par_dtmvtolt              THEN
                                ASSIGN tt-dados-epr.qtmesdec = crapepr.qtmesdec + 1.
                            ELSE
                                ASSIGN tt-dados-epr.qtmesdec = crapepr.qtmesdec.
                        END.
            ELSE
                IF  MONTH(crapepr.dtmvtolt) = MONTH(par_dtmvtolt)  AND
                    YEAR(crapepr.dtmvtolt)  = YEAR(par_dtmvtolt)   THEN
                    /** Contrato do mes - ainda nao atualizou o qtmesdec **/
                    tt-dados-epr.qtmesdec = crapepr.qtmesdec.
                ELSE
                    DO:
                        ASSIGN aux_dtrefavs = par_dtmvtolt - DAY(par_dtmvtolt)
                               aux_flghaavs = FALSE.

                        FOR EACH crapavs WHERE
                                 crapavs.cdcooper = par_cdcooper     AND
                                 crapavs.nrdconta = crapepr.nrdconta AND
                                 crapavs.cdhistor = 108              AND
                                 crapavs.dtrefere = aux_dtrefavs     AND
                                 crapavs.tpdaviso = 1                AND
                                 crapavs.flgproce = FALSE            NO-LOCK:

                            ASSIGN aux_flghaavs = TRUE.

                        END.

                        IF  aux_flghaavs  THEN
                            tt-dados-epr.qtmesdec = crapepr.qtmesdec.
                        ELSE
                            tt-dados-epr.qtmesdec = crapepr.qtmesdec + 1.
                    END.
         END.

    ASSIGN tt-dados-epr.qtmesdec = IF  tt-dados-epr.qtmesdec < 0  THEN
                                       0
                                   ELSE
                                       tt-dados-epr.qtmesdec
           tt-dados-epr.dspreapg = "   " + STRING(aux_qtprecal,"-z9.9999") +
                                   "/" + STRING(crapepr.qtpreemp,"999") +
                                   " ->" + STRING(aux_qtpreapg,"zz9.9999-").

    IF   crapepr.tpemprst = 0   THEN
         DO:
             IF  crapepr.qtprecal >  crapepr.qtmesdec  AND
                 crapepr.dtdpagto <= par_dtmvtolt      AND
                 NOT crapepr.flgpagto                  THEN
                 DO:
                     ASSIGN tt-dados-epr.vlpreapg = crapepr.vlpreemp -
                                                    aux_vlprepag.

                     IF  tt-dados-epr.vlpreapg < 0  THEN
                         ASSIGN tt-dados-epr.vlpreapg = 0.
                 END.
             ELSE
                 tt-dados-epr.vlpreapg = IF  (tt-dados-epr.qtmesdec -
                                             aux_qtprecal) > 0        THEN
                                             (tt-dados-epr.qtmesdec - aux_qtprecal) *
                                             crapepr.vlpreemp
                                         ELSE
                                             0.

             IF  tt-dados-epr.qtmesdec > crapepr.qtpreemp  THEN
                 ASSIGN tt-dados-epr.vlpreapg = aux_vlsdeved.
             ELSE
                 tt-dados-epr.vlpreapg = IF tt-dados-epr.vlpreapg > aux_vlsdeved THEN
                                            aux_vlsdeved
                                         ELSE
                                            tt-dados-epr.vlpreapg.

             IF  tt-dados-epr.vlpreapg < 0  THEN
                 ASSIGN tt-dados-epr.vlpreapg = 0.

         END.
    ELSE
        DO:
            ASSIGN tt-dados-epr.vlpreapg = aux_vlpreapg.
        END.

    ASSIGN tt-dados-epr.qtprecal = aux_qtprecal
           tt-dados-epr.vltotpag = tt-dados-epr.vlpreapg +
                                   tt-dados-epr.vlmrapar + 
                                     tt-dados-epr.vlmtapar +
                                                                         tt-dados-epr.vliofcpl.

    /* Calcular Parcela/Atraso */
    ASSIGN aux_qtmesdec = tt-dados-epr.qtmesdec - tt-dados-epr.qtprecal
           aux_qtpreemp = tt-dados-epr.qtpreemp - tt-dados-epr.qtprecal.

    IF   aux_qtmesdec > aux_qtpreemp   THEN
         tt-dados-epr.qtmesatr = aux_qtpreemp.
    ELSE
         tt-dados-epr.qtmesatr = aux_qtmesdec.

    IF   tt-dados-epr.qtmesatr < 0   THEN
         tt-dados-epr.qtmesatr = 0.

    FOR crapass FIELDS(inpessoa)
                WHERE crapass.cdcooper = par_cdcooper AND
                      crapass.nrdconta = par_nrdconta
                      NO-LOCK: END.

    IF AVAIL crapass THEN
       DO:
           FOR crappre FIELDS(cdfinemp) 
                       WHERE crappre.cdcooper = par_cdcooper          AND
                             crappre.inpessoa = crapass.inpessoa      AND
                             crappre.cdfinemp = tt-dados-epr.cdfinemp
                             NO-LOCK: END.

           IF AVAIL crappre THEN
              ASSIGN tt-dados-epr.flgpreap = TRUE.

       END. /* END IF AVAIL crapass THEN */

    RETURN "OK".

END PROCEDURE.

PROCEDURE calcula-saldo-epr:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF INPUT-OUTPUT PARAM par_vlsdeved AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vltotpre AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_qtprecal LIKE crapepr.qtprecal       NO-UNDO.

    DEF VAR aux_vlpreemp LIKE crapepr.vlpreemp                      NO-UNDO.
    DEF VAR aux_qtpreemp LIKE crapepr.qtpreemp                      NO-UNDO.
    DEF VAR aux_qtmesdec LIKE crapepr.qtmesdec                      NO-UNDO.
    DEF VAR aux_dtmvtoan LIKE crapdat.dtmvtoan                      NO-UNDO.
    DEF VAR aux_vlmrapar LIKE crappep.vlmrapar                      NO-UNDO.
    DEF VAR aux_vlmtapar LIKE crappep.vlmtapar                      NO-UNDO.
    DEF VAR aux_vliofcpl LIKE crappep.vliofcpl                      NO-UNDO.
    DEF VAR aux_vlpreapg AS DECI                                    NO-UNDO.
    DEF VAR aux_vlprvenc AS DECI                                    NO-UNDO.
    DEF VAR aux_vlpraven AS DECI                                    NO-UNDO.
    DEF VAR h-b1wgen0084a AS HANDLE                                 NO-UNDO.


    IF  tab_inusatab AND crapepr.inliquid = 0  THEN
        DO:
            FIND craplcr WHERE craplcr.cdcooper = par_cdcooper   AND
                               craplcr.cdlcremp = crapepr.cdlcremp
                               NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE craplcr  THEN
                DO:
                    ASSIGN aux_cdcritic = 363
                           aux_dscritic = "".

                    RETURN "NOK".
                END.

            aux_txdjuros = craplcr.txdiaria.
        END.
    ELSE
        aux_txdjuros = crapepr.txjuremp.

    ASSIGN aux_nrdconta = crapepr.nrdconta
          aux_nrctremp = crapepr.nrctremp
          aux_vlsdeved = crapepr.vlsdeved
          aux_vljuracu = crapepr.vljuracu
          aux_vlmrapar = 0
          aux_vliofcpl = 0
          aux_vlmtapar = 0
          aux_dtcalcul = ?
          aux_dtultdia = ((DATE(MONTH(par_dtmvtolt),28,YEAR(par_dtmvtolt))
                         + 4) - DAY(DATE(MONTH(par_dtmvtolt),28,
                         YEAR(par_dtmvtolt)) + 4))
          aux_qtprecal = IF  crapepr.inliquid = 0  THEN
                             crapepr.qtprecal
                         ELSE
                             crapepr.qtpreemp  .

    /** Rotina para calculo do saldo devedor **/
    { sistema/generico/includes/b1wgen0002.i }

    IF   aux_vlsdeved > 0  THEN
        ASSIGN par_vltotpre = par_vltotpre + crapepr.vlpreemp.

    IF   crapepr.tpemprst = 0   THEN
        DO:
            ASSIGN par_qtprecal = par_qtprecal + lem_qtprecal.
        END.
    ELSE
        DO:
            ASSIGN par_qtprecal = par_qtprecal + aux_qtprecal.
        END.

    ASSIGN par_vlsdeved = par_vlsdeved + aux_vlsdeved.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/**     Procedure para trazer o registro a liquidar limite/adp              **/
/**     Diego Simas - AMcom                                                 **/
/*****************************************************************************/

PROCEDURE obtem-dados-limite-adp:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF  INPUT-OUTPUT PARAM TABLE FOR tt-dados-epr.

    EMPTY TEMP-TABLE tt-erro.

    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

    DEF VAR aux_tipo     AS INTE                                    NO-UNDO.
    DEF VAR aux_data     AS CHAR                                    NO-UNDO.
    DEF VAR aux_contrato AS INTE                                    NO-UNDO.
    DEF VAR aux_saldo    AS DECI                                    NO-UNDO.


    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        /* Efetuar a chamada a rotina Oracle  */
        RUN STORED-PROCEDURE pc_consultar_limite_adp
            aux_handproc = PROC-HANDLE NO-ERROR (
                            INPUT par_cdcooper,
                            INPUT par_nrdconta,
                           OUTPUT 0,    /* Tipo                 */
                           OUTPUT "",   /* Data                 */
                           OUTPUT 0,    /* Contrato             */
                           OUTPUT 0,    /* Saldo                */
                           OUTPUT 0,    /* Código da crítica    */
                           OUTPUT "").  /* Descrição da crítica */

        /* Fechar o procedimento para buscarmos o resultado */
        CLOSE STORED-PROC pc_consultar_limite_adp
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_tipo     = 0
           aux_data     = ""
           aux_contrato = 0
           aux_saldo    = 0
           aux_tipo     = pc_consultar_limite_adp.pr_tipo
                          WHEN pc_consultar_limite_adp.pr_tipo <> ?
           aux_data     = pc_consultar_limite_adp.pr_data
                          WHEN pc_consultar_limite_adp.pr_data <> ?
           aux_contrato = pc_consultar_limite_adp.pr_contrato
                          WHEN pc_consultar_limite_adp.pr_contrato <> ?
           aux_saldo    = pc_consultar_limite_adp.pr_saldo
                          WHEN pc_consultar_limite_adp.pr_saldo <> ?
           aux_cdcritic = pc_consultar_limite_adp.pr_cdcritic
                          WHEN pc_consultar_limite_adp.pr_cdcritic <> ?
           aux_dscritic = pc_consultar_limite_adp.pr_dscritic
                          WHEN pc_consultar_limite_adp.pr_dscritic <> ?.
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.cdcritic = aux_cdcritic
                   tt-erro.dscritic = aux_dscritic.
            RETURN "NOK".
        END.

    IF  aux_tipo > 0 THEN
        DO:
            CREATE tt-dados-epr.
            ASSIGN tt-dados-epr.idenempr = aux_tipo
                   tt-dados-epr.dtmvtolt = date(aux_data)
                   tt-dados-epr.nrctremp = aux_contrato
                   tt-dados-epr.vlsdeved = aux_saldo.
        END.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
 Validar o uf digitados nas propostas de emprestimos.
 ****************************************************************************/
PROCEDURE valida_uf:

    DEF  INPUT PARAM par_ufbrasil AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_cdcritic AS INTE                              NO-UNDO.

    ASSIGN aux_cdcritic = 0.

    IF   NOT CAN-DO ("AC,AL,AP,AM,BA,CE,DF,ES,GO,MA,MG,MS,MT,PA,PB,PE,PI," +
                     "PR,RJ,RN,RO,RR,RS,SC,SE,SP,TO",par_ufbrasil) THEN
         DO:
             ASSIGN aux_cdcritic = 33.
         END.

    RETURN "OK".

END PROCEDURE.


/*****************************************************************************/
/**     Procedure para obter dados utilizados em calculos de emprestimos    **/
/****************************************************************************/
PROCEDURE obtem-parametros-tabs:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_indpagto AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_diapagto AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dtcalcul AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM par_flgfolha AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM par_inusatab AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdempres AS INT                                     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdempres = 0.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "USUARI"     AND
                       craptab.cdempres = 11           AND
                       craptab.cdacesso = "TAXATABELA" AND
                       craptab.tpregist = 0            NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craptab  THEN
        par_inusatab = FALSE.
    ELSE
        par_inusatab = IF  SUBSTRING(craptab.dstextab,1,1) = "0"  THEN
                           FALSE
                       ELSE
                           TRUE.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.
    
    IF   crapass.inpessoa = 1   THEN
         DO:  
             FIND crapttl WHERE crapttl.cdcooper = par_cdcooper       AND
                                crapttl.nrdconta = crapass.nrdconta   AND
                                crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

             IF   AVAIL crapttl  THEN                    
                  ASSIGN aux_cdempres = crapttl.cdempres. 
         END.
    ELSE
         DO:
             FIND crapjur WHERE crapjur.cdcooper = par_cdcooper  AND
                                crapjur.nrdconta = crapass.nrdconta
                                NO-LOCK NO-ERROR.

             IF   AVAIL crapjur  THEN
                  ASSIGN aux_cdempres = crapjur.cdempres.
         END.
    
    FIND craptab WHERE craptab.cdcooper = par_cdcooper     AND
                       craptab.nmsistem = "CRED"           AND
                       craptab.tptabela = "GENERI"         AND
                       craptab.cdempres = 00               AND
                       craptab.cdacesso = "DIADOPAGTO"     AND
                       craptab.tpregist = aux_cdempres NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craptab  THEN
        DO:                                 
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Falta cadastro da empresa " + STRING(aux_cdempres) + ".".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    IF  CAN-DO("1,3,4",STRING(crapass.cdtipsfx))  THEN
        par_diapagto = INTE(SUBSTR(craptab.dstextab,4,2)). /** Mensal **/
    ELSE
        par_diapagto = INTE(SUBSTR(craptab.dstextab,7,2)). /** Horis. **/

    par_indpagto = INTE(SUBSTRING(craptab.dstextab,14,1)).

    /** Verifica se a data do pagamento da empresa cai num dia util **/
    par_dtcalcul = DATE(MONTH(par_dtmvtolt),par_diapagto,YEAR(par_dtmvtolt)).

    DO WHILE TRUE:

        IF  WEEKDAY(par_dtcalcul) = 1 OR WEEKDAY(par_dtcalcul) = 7  THEN
            DO:
                par_dtcalcul = par_dtcalcul + 1.
                NEXT.
            END.

        FIND crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                           crapfer.dtferiad = par_dtcalcul NO-LOCK NO-ERROR.

        IF  AVAILABLE crapfer  THEN
            DO:
                par_dtcalcul = par_dtcalcul + 1.
                NEXT.
            END.

        par_diapagto = DAY(par_dtcalcul).

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    par_flgfolha = IF  SUBSTRING(craptab.dstextab,14,1) = "0"  THEN
                       FALSE
                   ELSE
                       TRUE.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
 Procedure para validar os avalistas por separado. (Um aval por tela)
 *****************************************************************************/
PROCEDURE valida-avalistas:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.

   /* Nota promissoria / Pestacoes */
   DEF  INPUT PARAM par_qtpromis AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_qtpreemp AS INTE                           NO-UNDO.

   /* Para verificar que os dois avalistas nao sejam o mesmo */
   DEF  INPUT PARAM par_nrctaav1 AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrcpfav1 AS DECI                           NO-UNDO.

   /* Dados do avalista */
   DEF  INPUT PARAM par_idavalis AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrctaava AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nmdavali AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_nrcpfava AS DECI                           NO-UNDO.
   DEF  INPUT PARAM par_cpfcjavl AS DECI                           NO-UNDO.
   DEF  INPUT PARAM par_ende1avl AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_cdufresd AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.

   /* Daniel */
   DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_dtnascto AS DATE                           NO-UNDO.

   DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-erro.


   /* Estes parametros sao so para quando prencher o 2. aval*/
   IF   par_idavalis = 1   THEN
        DO:
            ASSIGN par_nrctaav1 = 0
                   par_nrcpfav1 = 0.
        END.

   IF par_nrcpfava <> 0 THEN DO:

        IF par_inpessoa <> 1 AND 
           par_inpessoa <> 2 THEN DO:

            aux_dscritic = "Tipo Natureza deve ser Informada.".

            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).

            par_nmdcampo = "inpessoa".
            RETURN "NOK".
        END.
    
        IF par_inpessoa = 1 AND
           par_dtnascto = ? THEN DO:

            aux_dscritic = "Data de Nascimento deve ser Informada.".

            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).

             par_nmdcampo = "dtnascto".
             RETURN "NOK".
        END.
   END.


   RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT SET h-b1wgen0024.

   RUN valida-avalistas IN h-b1wgen0024 (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_nrdconta,
                                         INPUT par_qtpromis,
                                         INPUT par_qtpreemp,
                                         INPUT par_nrctaav1,
                                         INPUT par_nrcpfav1,
                                         INPUT par_idavalis,
                                         INPUT par_nrctaava,
                                         INPUT par_nmdavali,
                                         INPUT par_nrcpfava,
                                         INPUT par_cpfcjavl,
                                         INPUT par_ende1avl,
                                         INPUT par_cdufresd,
                                         INPUT par_nrcepend,
                                         INPUT par_inpessoa,
                                        OUTPUT par_nmdcampo,
                                        OUTPUT TABLE tt-erro).
   DELETE PROCEDURE h-b1wgen0024.

   IF   RETURN-VALUE <> "OK"   THEN
        RETURN "NOK".

   RETURN "OK".

END.

/**********************************************************************/
/** Procedure para consultar dados do avalista informado             **/
/**********************************************************************/
PROCEDURE consulta-avalista:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nrctaava AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.

   DEF OUTPUT PARAM TABLE FOR tt-dados-avais.
   DEF OUTPUT PARAM TABLE FOR tt-erro.

   RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

   RUN consulta-avalista IN h-b1wgen9999
                         (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_idorigem,
                          INPUT par_nrdconta,
                          INPUT par_dtmvtolt,
                          INPUT par_nrctaava,
                          INPUT par_nrcpfcgc,
                         OUTPUT TABLE tt-dados-avais,
                         OUTPUT TABLE tt-erro).

   DELETE PROCEDURE h-b1wgen9999.

   IF   RETURN-VALUE <> "OK"   THEN
        RETURN "NOK".

   RETURN "OK".

END.



PROCEDURE busca_aval_terceiro:

   DEF INPUT PARAM aux_dscpfavl AS CHAR                     NO-UNDO.
   DEF INPUT PARAM aux_dsavlter AS CHAR                     NO-UNDO.

   DEF VAR aux_contador AS INTE                             NO-UNDO.

   ASSIGN aux_dsavlter = "".

   DO  aux_contador = 1 TO LENGTH(aux_dscpfavl):

       IF  SUBSTR(aux_dscpfavl,aux_contador,6) = "C.P.F." OR
           SUBSTR(aux_dscpfavl,aux_contador,6) = "C.G.C." OR 
           SUBSTR(aux_dscpfavl,aux_contador,4) = "CNPJ" THEN
           DO:
                ASSIGN  aux_dsavlter =
                            SUBSTR(aux_dscpfavl,aux_contador + 7,18).
           END.

   END.

END  PROCEDURE.

/****************************************************************************/
/**     Procedure para tratamento da impressão                             **/
/****************************************************************************/
PROCEDURE gera-impressao-empr:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idimpres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgescra AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrpagina AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgemail AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtcalcul AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_promsini AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgentra AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM par_flgentrv AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    IF  VALID-HANDLE(h-b1wgen0002i)  THEN
        DELETE PROCEDURE h-b1wgen0002i.

    RUN sistema/generico/procedures/b1wgen0002i.p PERSISTENT
        SET h-b1wgen0002i.

    IF  NOT VALID-HANDLE(h-b1wgen0002i)  THEN
        DO:
            ASSIGN aux_dscritic = "Handle invalido para BO " +
                                  "b1wgen0002i.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
        END.

    RUN gera-impressao-empr IN h-b1wgen0002i (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_cdoperad,
                                              INPUT par_nmdatela,
                                              INPUT par_idorigem,
                                              INPUT par_nrdconta,
                                              INPUT par_idseqttl,
                                              INPUT par_dtmvtolt,
                                              INPUT par_dtmvtopr,
                                              INPUT par_flgerlog,
                                              INPUT par_recidepr,
                                              INPUT par_idimpres,
                                              INPUT par_flgescra,
                                              INPUT par_nrpagina,
                                              INPUT par_flgemail,
                                              INPUT par_dsiduser,
                                              INPUT par_dtcalcul,
                                              INPUT par_inproces,
                                              INPUT par_promsini,
                                              INPUT par_cdprogra,
                                              INPUT par_flgentra,
                                             OUTPUT par_flgentrv,
                                             OUTPUT par_nmarqimp,
                                             OUTPUT par_nmarqpdf,
                                             OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro THEN
                DO:
                    DELETE PROCEDURE h-b1wgen0002i.
                    RETURN "NOK".
                END.

        END.

    DELETE PROCEDURE h-b1wgen0002i.

    RETURN "OK".

END PROCEDURE.

/****************************************************************************/
/**     Procedure para tratamento da impressão                             **/
/****************************************************************************/
PROCEDURE valida_impressao:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_tplcremp AS INTE                              NO-UNDO.

    DEF OUTPUT PARAM par_inobriga AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    RUN sistema/generico/procedures/b1wgen0002i.p PERSISTENT
        SET h-b1wgen0002i.

    IF  NOT VALID-HANDLE(h-b1wgen0002i)  THEN
        DO:
            ASSIGN aux_dscritic = "Handle invalido para BO " +
                                  "b1wgen0002i.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
        END.

    RUN valida_impressao IN h-b1wgen0002i ( INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_idorigem,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT par_recidepr,
                                            INPUT par_tplcremp,
                                           OUTPUT par_inobriga,
                                           OUTPUT TABLE tt-erro ).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro THEN
                DO:
                    DELETE PROCEDURE h-b1wgen0002i.
                    RETURN "NOK".
                END.

        END.

    DELETE PROCEDURE h-b1wgen0002i.

    RETURN "OK".

END PROCEDURE.

/****************************************************************************/
/**                  Procedure para Busca de Observação                    **/
/****************************************************************************/
PROCEDURE traz-observacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrobs AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_dsobserv AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

    ASSIGN par_dsobserv = DYNAMIC-FUNCTION( "trazObservacao",
                                          INPUT par_cdcooper,
                                          INPUT par_nrdconta,
                                          INPUT par_nrctrobs,
                                         OUTPUT aux_dscritic).

    IF   aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    RETURN "OK".

END.

/****************************************************************************/
/**               Procedure para verificar se contrato é valido            **/
/****************************************************************************/
PROCEDURE verifica-contrato:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrem2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inusatab AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nralihip AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

    ASSIGN aux_dscritic = DYNAMIC-FUNCTION( "verificaContrato",
                                            INPUT par_cdcooper,
                                            INPUT par_nrdconta,
                                            INPUT par_nrctremp,
                                            INPUT par_nrctrem2,
                                            INPUT par_inusatab,
                                            INPUT par_nralihip).


    IF   aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    RETURN "OK".

END.

/****************************************************************************/
/**               Procedure para validar interveniente                     **/
/****************************************************************************/
PROCEDURE valida-interv:

    DEF INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_nrctaava AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_nmdavali AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF INPUT PARAM par_tpdocava AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_nrdocava AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_cdnacion AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_nmconjug AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_nrcpfcjg AS DECI                           NO-UNDO.
    DEF INPUT PARAM par_tpdoccjg AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_nrdoccjg AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_dsendre1 AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_dsendre2 AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_nrfonres AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_dsdemail AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_cdufresd AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.

    DEF VAR aux_dscritic AS CHAR NO-UNDO.

    /* Acionar gravação convertida para Oracle */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_valida_interv
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_nrctaava,
                                         INPUT par_nrcepend,
                                         INPUT par_dsendre1,                   
                                         INPUT par_nmdavali,
                                         INPUT par_nrcpfcgc,
                                         INPUT par_tpdocava,
                                         INPUT par_nrdocava,
                                         INPUT par_nmconjug,
                                         INPUT par_nrcpfcjg,
                                         INPUT par_tpdoccjg,
                                         INPUT par_nrdoccjg,
                                         INPUT par_cdnacion,
                                         OUTPUT par_nmdcampo,       /* Campo */
                                         OUTPUT "0",                  /* Codigo d~ a critica  */
                                         OUTPUT "").                /* Descricao da critica */

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_valida_interv
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.                                                

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN par_nmdcampo = ""
           aux_cdcritic = 0
           aux_dscritic = ""
           par_nmdcampo = pc_valida_interv.par_nmdcampo
                             WHEN pc_valida_interv.par_nmdcampo <> ?
           aux_cdcritic = INTE(pc_valida_interv.par_cdcritic)
                             WHEN pc_valida_interv.par_cdcritic <> ?
           aux_dscritic = pc_valida_interv.par_dscritic
                             WHEN pc_valida_interv.par_dscritic <> ?.                 


    IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT aux_cdcritic,
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    RETURN "OK".
END PROCEDURE. /* valida-interv */


PROCEDURE valida-analise-proposta:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF  INPUT PARAM par_dtcnsspc AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrinfcad AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtoutspc AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdrisco AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtoutris AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrgarope AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrliquid AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrpatlvr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrperger AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_nomcampo AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    IF   par_flgerlog THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Valida analise proposta.".

    FIND   crapass NO-LOCK WHERE
           crapass.cdcooper = par_cdcooper AND
           crapass.nrdconta = par_nrdconta NO-ERROR.

    IF   NOT AVAIL crapass THEN
         DO:

             ASSIGN par_nomcampo = "nrdconta"
                    aux_cdcritic = 9
                    aux_dscritic = "".

             RUN gera_erro ( INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

         END.

    IF   par_dtcnsspc <> ? AND
         par_dtcnsspc  > par_dtmvtolt THEN
         DO:
             ASSIGN par_nomcampo = "dtcnsspc"
                    aux_cdcritic = 013
                    aux_dscritic = "".

             RUN gera_erro ( INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".

         END.

    IF   crapass.inpessoa = 1 AND
         par_dtoutspc    <> ? AND
         par_dtoutspc     > par_dtmvtolt THEN
         DO:
             ASSIGN par_nomcampo = "dtoutspc"
                    aux_cdcritic = 013
                    aux_dscritic = "".

             RUN gera_erro ( INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

         END.

    IF   par_dtdrisco <> ? AND
         par_dtdrisco  > par_dtmvtolt THEN
         DO:
             ASSIGN par_nomcampo = "dtdrisco"
                    aux_cdcritic = 013
                    aux_dscritic = "".

             RUN gera_erro ( INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

         END.

    IF   crapass.inpessoa = 1 AND
         par_dtoutris    <> ? AND
         par_dtoutris     > par_dtmvtolt THEN
         DO:
             ASSIGN par_nomcampo = "dtoutris"
                    aux_cdcritic = 013
                    aux_dscritic = "".

             RUN gera_erro ( INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

         END.


    IF   par_nrgarope = 0 THEN
         DO:

             ASSIGN par_nomcampo = "nrgarope"
                    aux_cdcritic = 375
                    aux_dscritic = "".

             RUN gera_erro ( INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

         END.


    IF   par_nrliquid = 0 THEN
         DO:

             ASSIGN par_nomcampo = "nrliquid"
                    aux_cdcritic = 375
                    aux_dscritic = "".

             RUN gera_erro ( INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

         END.


    IF   par_nrpatlvr = 0 THEN
         DO:

             ASSIGN par_nomcampo = "nrpatlvr"
                    aux_cdcritic = 375
                    aux_dscritic = "".

             RUN gera_erro ( INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".

         END.


    IF   crapass.inpessoa = 2 AND
         par_nrperger     = 0 THEN
         DO:

             ASSIGN par_nomcampo = "nrperger"
                    aux_cdcritic = 375
                    aux_dscritic = "".

             RUN gera_erro ( INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".

         END.


    IF  par_flgerlog THEN
        DO:

            RUN proc_gerar_log ( INPUT  par_cdcooper,
                                 INPUT  par_cdoperad,
                                 INPUT  aux_dscritic,
                                 INPUT  aux_dsorigem,
                                 INPUT  aux_dstransa,
                                 INPUT  FALSE,
                                 INPUT  par_idseqttl,
                                 INPUT  par_nmdatela,
                                 INPUT  par_nrdconta,
                                 OUTPUT aux_nrdrowid).

        END.

    RETURN "OK".

END PROCEDURE. /* valida-analise-proposta */

PROCEDURE retorna_UF_PA_ASS:

    DEF INPUT  PARAM par_cdcooper AS INTE            NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INTE            NO-UNDO.
    DEF OUTPUT PARAM aux_uflicenc AS CHAR            NO-UNDO.


    ASSIGN aux_uflicenc = "".

    DO WHILE TRUE:

        FIND FIRST crapass
             WHERE crapass.cdcooper = par_cdcooper
               AND crapass.nrdconta = par_nrdconta
            NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapass THEN
            ASSIGN aux_uflicenc = "".
        ELSE DO:
            FIND FIRST crapage
                 WHERE crapage.cdcooper = crapass.cdcooper
                   AND crapage.cdagenci = crapass.cdagenci
                NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapage THEN
                ASSIGN aux_uflicenc = "".
            ELSE
                ASSIGN aux_uflicenc = crapage.cdufdcop.
        END.

        LEAVE.

    END.

    IF  aux_uflicenc = "" THEN DO:
        ASSIGN aux_uflicenc = "SC". /*FIXO - CASO NAO ENCONTRE ACIMA */
    END.

END PROCEDURE.

/*** Rotina para efetuar o calculo do cet ***/
PROCEDURE calcula-cet:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF  INPUT PARAM p-qtparemp AS INTE                                NO-UNDO.
    DEF  INPUT PARAM p-vlpreemp AS DECI                                NO-UNDO.
    DEF  INPUT PARAM p-vlemprst AS DECI                                NO-UNDO.
    DEF  INPUT PARAM p-dtinictr AS DATE                                NO-UNDO.
    DEF  INPUT PARAM p-dtdpagto AS DATE                                NO-UNDO.
    DEF OUTPUT PARAM p-txcetano AS DECI                                NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dscritic AS CHAR NO-UNDO.
    DEF VAR aux_cdcritic AS INTE NO-UNDO.    

    EMPTY TEMP-TABLE tt-erro.
  
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_juros_cet 
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT p-qtparemp, /* Qtd parcelas */
                          INPUT p-vlpreemp, /* valor parcela */
                          INPUT p-vlemprst, /* valor total do emprestimo */
                          INPUT p-dtinictr, /* data inicial do contrato  */
                          INPUT p-dtdpagto, /* data do primeiro pagamento */
                         OUTPUT 0,
                         OUTPUT 0, 
                         OUTPUT 0,
                         OUTPUT 0,
                         OUTPUT "").

    CLOSE STORED-PROC pc_juros_cet 
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           p-txcetano   = 0
           p-txcetano   = pc_juros_cet.pr_tx_cet_ano 
                          WHEN pc_juros_cet.pr_tx_cet_ano <> ?
           aux_cdcritic = pc_juros_cet.pr_cdcritic 
                          WHEN pc_juros_cet.pr_cdcritic <> ?
           aux_dscritic = pc_juros_cet.pr_dscritic 
                          WHEN pc_juros_cet.pr_dscritic <> ?.
        
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
        DO:                                  
            CREATE tt-erro.
            ASSIGN tt-erro.cdcritic = aux_cdcritic
                   tt-erro.dscritic = aux_dscritic.

            RETURN "NOK".
        END.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE monta_registros_proposta:

    DEF INPUT PARAM TABLE FOR tt-aval-crapbem.
    DEF INPUT PARAM TABLE FOR tt-faturam.
    DEF INPUT PARAM TABLE FOR tt-crapbem.
    DEF INPUT PARAM TABLE FOR tt-bens-alienacao.
    DEF INPUT PARAM TABLE FOR tt-hipoteca.
    DEF INPUT PARAM TABLE FOR tt-interv-anuentes.
    DEF INPUT PARAM TABLE FOR tt-rendimento.
    DEF OUTPUT PARAM par_dsdbeavt AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM par_dsdfinan AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM par_dsdrendi AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM par_dsdebens AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM par_dsdalien AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM par_dsinterv AS CHAR                            NO-UNDO.
    
    DEF VAR aux_contador          AS INTE                            NO-UNDO.
    
    /* Bens dos avalistas */
    IF   TEMP-TABLE tt-aval-crapbem:HAS-RECORDS THEN
         FOR EACH tt-aval-crapbem NO-LOCK:
    
             IF   par_dsdbeavt <> "" THEN
                  ASSIGN par_dsdbeavt = par_dsdbeavt + "|".
            
             ASSIGN par_dsdbeavt = par_dsdbeavt + 
                                  STRING(tt-aval-crapbem.nrdconta) + ";" +
                                  STRING(tt-aval-crapbem.nrcpfcgc) + ";" +
                                         tt-aval-crapbem.dsrelbem  + ";" +
                                  STRING(tt-aval-crapbem.persemon) + ";" +
                                  STRING(tt-aval-crapbem.qtprebem) + ";" +
                                  STRING(tt-aval-crapbem.vlprebem) + ";" +
                                  STRING(tt-aval-crapbem.vlrdobem) + ";" + 
                                  STRING(tt-aval-crapbem.idseqbem).                                  
         END.
    
    /* Faturamento mensal (P. Juridicas) */
    IF   TEMP-TABLE tt-faturam:HAS-RECORDS  THEN 
         FOR EACH tt-faturam NO-LOCK:
            
             /* Separar os Registros por '|' e campos por ';' */
             IF   par_dsdfinan <> ""   THEN
                  par_dsdfinan = par_dsdfinan + "|".
                  
             ASSIGN par_dsdfinan = par_dsdfinan + STRING(tt-faturam.anoftbru) +
                                   ";"          + STRING(tt-faturam.mesftbru) +
                                   ";"          + STRING(tt-faturam.vlrftbru).     
         END.
    
    /* Juntar os rendimentos  */
    IF  TEMP-TABLE tt-rendimento:HAS-RECORDS  THEN 
        DO:
            FIND FIRST tt-rendimento NO-LOCK NO-ERROR.

            DO aux_contador = 1 TO 6:
            
               IF   tt-rendimento.tpdrendi[aux_contador] = 0   THEN
                    NEXT.
            
               IF   par_dsdrendi <> ""  THEN
                    par_dsdrendi = par_dsdrendi + "|". 
                                     
               ASSIGN par_dsdrendi = par_dsdrendi + 
                                STRING(tt-rendimento.tpdrendi[aux_contador]) + ";" +
                                STRING(tt-rendimento.vldrendi[aux_contador]).                
            END.
    
        END.
    
    /* Juntar os bens do cooperado */
    IF   TEMP-TABLE tt-crapbem:HAS-RECORDS   THEN
         FOR EACH tt-crapbem NO-LOCK:
    
             IF   par_dsdebens <> ""  THEN
                  par_dsdebens = par_dsdebens + "|".
                
              /* Esta montagem tem que ficar no mesmo estilo dos bens dos aval */
              /* Neste caso vai sem CPF apos a conta */
              ASSIGN par_dsdebens = par_dsdebens + 
                                            STRING(tt-crapbem.nrdconta) + ";;" +
                                                   tt-crapbem.dsrelbem  + ";"  +
                                            STRING(tt-crapbem.persemon) + ";"  +
                                            STRING(tt-crapbem.qtprebem) + ";"  +
                                            STRING(tt-crapbem.vlprebem) + ";"  +
                                            STRING(tt-crapbem.vlrdobem) + ";"  +
                                            STRING(tt-crapbem.idseqbem).                                 
         END.
    
    /* Bens Alienacao */
    IF   TEMP-TABLE tt-bens-alienacao:HAS-RECORDS  THEN 
         FOR EACH tt-bens-alienacao NO-LOCK:
    
             IF   par_dsdalien <> ""  THEN
                  par_dsdalien = par_dsdalien + "|".
             
             /* Esta variavel é usada na hipoteca tambem */    
             ASSIGN par_dsdalien = par_dsdalien + 
                                      tt-bens-alienacao.dscatbem  + ";" +
                                      tt-bens-alienacao.dsbemfin  + ";" +
                                      tt-bens-alienacao.dscorbem  + ";" +
                               STRING(tt-bens-alienacao.vlmerbem) + ";" +
                                      tt-bens-alienacao.dschassi  + ";" +
                               STRING(tt-bens-alienacao.nranobem) + ";" + 
                               STRING(tt-bens-alienacao.nrmodbem) + ";" +
                                      tt-bens-alienacao.nrdplaca  + ";" +
                               STRING(tt-bens-alienacao.nrrenava) + ";" +
                               STRING(tt-bens-alienacao.tpchassi) + ";" +
                                      tt-bens-alienacao.ufdplaca  + ";" +
                               STRING(tt-bens-alienacao.nrcpfbem) + ";" +
                                      tt-bens-alienacao.uflicenc  + ";" +
                                      tt-bens-alienacao.dstipbem  + ";" +
                               STRING(tt-bens-alienacao.idseqbem) + ";" +
                                                                    ";" + /*vlrdobem*/
                                                                    ";" + /*cdufende*/
                                                                    ";" + /*dscompend*/
                                                                    ";" + /*dsendere*/
                                                                    ";" + /*nmbairro*/
                                                                    ";" + /*nmcidade*/
                                                                    ";" + /*nrcepend*/
                                                                    ";" + /*nrendere*/
                                                                    ";" + /*dsclassi*/
                                                                    ";" + /*vlareuti*/
                                                                    ";" + /*vlaretot*/
                                                                    ";" + /*nrmatric*/
                                                                    ";" . /*vlrdobem*/
         END.
    
    /* Juntar os intervenientes  */
    IF   TEMP-TABLE tt-interv-anuentes:HAS-RECORDS  THEN
         FOR EACH tt-interv-anuentes NO-LOCK:
             
             IF   par_dsinterv <> ""  THEN
                  par_dsinterv = par_dsinterv + "|". 
                               
             ASSIGN par_dsinterv = par_dsinterv + 
                                 STRING(tt-interv-anuentes.nrcpfcgc)   + ";" +
                                        tt-interv-anuentes.nmdavali    + ";" +
                                 STRING(tt-interv-anuentes.nrcpfcjg)   + ";" +
                                        tt-interv-anuentes.nmconjug    + ";" +
                                        tt-interv-anuentes.tpdoccjg    + ";" +
                                        tt-interv-anuentes.nrdoccjg    + ";" +
                                        tt-interv-anuentes.tpdocava    + ";" +
                                 STRING(tt-interv-anuentes.nrdocava)   + ";" +
                                        tt-interv-anuentes.dsendres[1] + ";" + 
                                        tt-interv-anuentes.dsendres[2] + ";" +
                                        tt-interv-anuentes.nrfonres    + ";" +
                                        tt-interv-anuentes.dsdemail    + ";" +
                                        tt-interv-anuentes.nmcidade    + ";" +
                                        tt-interv-anuentes.cdufresd    + ";" +
                                 STRING(tt-interv-anuentes.nrcepend)   + ";" +
                                 STRING(tt-interv-anuentes.cdnacion)   + ";" +
                                 STRING(tt-interv-anuentes.nrendere)   + ";" +
                                        tt-interv-anuentes.complend    + ";" +
                                 STRING(tt-interv-anuentes.nrcxapst)   + ";" +
                                 STRING(tt-interv-anuentes.dtnascto).
                  
         END.
    
      
    /* Bens hipoteca */
    IF   TEMP-TABLE tt-hipoteca:HAS-RECORDS THEN
         FOR EACH tt-hipoteca NO-LOCK:
    
             IF   par_dsdalien <> ""  THEN
                  par_dsdalien = par_dsdalien + "|".
    
             /* Esta variavel é usada na alienaçao tambem */    
             /* Demais campos nao utilizados, entao colocar soh ; */
             ASSIGN par_dsdalien = par_dsdalien + 
                                      tt-hipoteca.dscatbem  + ";" +
                                      tt-hipoteca.dsbemfin  + ";" +
                                      tt-hipoteca.dscorbem  + ";" +
             STRING(tt-hipoteca.vlmerbem) + ";" +
                                            ";" + /*dschassi*/
                                            ";" + /*nranobem*/
                                            ";" + /*nrmodbem*/
                                            ";" + /*nrdplaca*/
                                            ";" + /*nrrenava)*/
                                            ";" + /*tpchassi)*/
                                            ";" + /*ufdplaca*/
                                            ";" + /*nrcpfbem*/
                                            ";" + /*uflicenc*/
                                            ";" + /*dstipbem*/
             STRING(tt-hipoteca.idseqbem) + ";" + /*idseqbem*/ /*PRJ 438 BUG 13721 - Paulo Martins*/
                                            ";" + /*cdcoplib*/
                                            ";" + /*dsmarbem*/
                                            ";" + /*vlfipbem*/
                                            ";" + /*dstpcomb*/
                    tt-hipoteca.cdufende + ";" +
                    tt-hipoteca.dscompend + ";" +
                    tt-hipoteca.dsendere + ";" +
                    tt-hipoteca.nmbairro + ";" +
                    tt-hipoteca.nmcidade + ";" +
             STRING(tt-hipoteca.nrcepend) + ";" +
             STRING(tt-hipoteca.nrendere) + ";" +
                    tt-hipoteca.dsclassi + ";" +
             STRING(tt-hipoteca.vlareuti) + ";" +
             STRING(tt-hipoteca.vlaretot) + ";" +
             STRING(tt-hipoteca.nrmatric) + ";" +
             STRING(tt-hipoteca.vlrdobem) + ";" . 
         END.

END PROCEDURE. /* END monta_registros_proposta */

PROCEDURE calcula_cet_novo:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS DECI                             NO-UNDO.

    DEF INPUT PARAM p-inpessoa AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-cdusolcr AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-cdlcremp AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-tpemprst AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-nrctremp AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-dtlibera AS DATE                                 NO-UNDO.
    DEF INPUT PARAM p-vlemprst AS DECI                                 NO-UNDO.
    DEF INPUT PARAM p-vlpreemp AS DECI                                 NO-UNDO.
    DEF INPUT PARAM p-qtpreemp AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-dtdpagto AS DATE                                 NO-UNDO.
    /* parametro de finalidade usado para portabilidade */
    DEF INPUT PARAM par_cdfinemp AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_dscatbem AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_idfiniof AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_dsctrliq AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_idgravar AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_dtcarenc AS DATE                               NO-UNDO.

    DEF OUTPUT PARAM par_txcetano AS DECI                              NO-UNDO. 
    DEF OUTPUT PARAM par_txcetmes AS DECI                              NO-UNDO. 
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    DEF VAR aux_dscritic AS CHAR NO-UNDO.
    DEF VAR aux_cdcritic AS INTE NO-UNDO.    

    EMPTY TEMP-TABLE tt-erro.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_calculo_cet_emprestimos
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper, /* Cooperativa */
                          INPUT par_dtmvtolt, /* Data Movimento */
                          INPUT par_nrdconta,
                          INPUT par_nmdatela, /* Programa chamador */
                          INPUT p-inpessoa, /* Indicativo de pessoa */
                          INPUT p-cdusolcr, /* Codigo de uso da linha de credito */
                          INPUT p-cdlcremp, /* Linha de credio  */
                          INPUT p-tpemprst, /* Tipo da operacao */
                          INPUT p-nrctremp, /* Contrato         */
                          INPUT p-dtlibera, /* Data liberacao   */
                          INPUT p-vlemprst, /* Valor emprestado */
                          INPUT 0, /* Taxa mensal */
                          INPUT p-vlpreemp, /* valor parcela    */  
                          INPUT p-qtpreemp, /* prestacoes       */
                          INPUT p-dtdpagto, /* data pagamento   */
                          INPUT par_cdfinemp, /* finalidade */
                          INPUT par_dscatbem,
                          INPUT par_idfiniof,
                          INPUT par_dsctrliq,
                          INPUT par_idgravar,
                          INPUT par_dtcarenc,
                         OUTPUT 0,
                         OUTPUT 0,
                         OUTPUT 0,
                         OUTPUT "").

    CLOSE STORED-PROC pc_calculo_cet_emprestimos 
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           par_txcetano   = 0
           par_txcetmes   = 0
           par_txcetano   = pc_calculo_cet_emprestimos.pr_txcetano
                          WHEN pc_calculo_cet_emprestimos.pr_txcetano <> ? 
           par_txcetmes   = pc_calculo_cet_emprestimos.pr_txcetmes
                          WHEN pc_calculo_cet_emprestimos.pr_txcetmes <> ? 
           aux_cdcritic = pc_calculo_cet_emprestimos.pr_cdcritic 
                          WHEN pc_calculo_cet_emprestimos.pr_cdcritic <> ?
           aux_dscritic = pc_calculo_cet_emprestimos.pr_dscritic 
                          WHEN pc_calculo_cet_emprestimos.pr_dscritic <> ?.

    ASSIGN par_txcetano = ROUND(par_txcetano,2).
        
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
        DO:                                    
            CREATE tt-erro.
            ASSIGN tt-erro.cdcritic = aux_cdcritic
                   tt-erro.dscritic = aux_dscritic.

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE verifica_microcredito:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM par_inlcrmcr AS CHAR                            NO-UNDO. 

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_verifica_microcredito
         aux_handproc = PROC-HANDLE NO-ERROR
                      (INPUT par_cdcooper, /* Cooperativa */
                       INPUT par_cdlcremp, /* Linha de credito */
                      OUTPUT "",
                      OUTPUT 0,
                      OUTPUT "").

    CLOSE STORED-PROC pc_verifica_microcredito 
       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
 
    ASSIGN par_dscritic = pc_verifica_microcredito.pr_dscritic
                             WHEN pc_verifica_microcredito.pr_dscritic <> ?
           par_inlcrmcr = pc_verifica_microcredito.pr_inlcrmcr 
                             WHEN pc_verifica_microcredito.pr_inlcrmcr <> ?.

    RETURN "OK".

END PROCEDURE.

PROCEDURE valida_inclusao_tr:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_qtpreemp AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_flgpagto AS LOGI                            NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_cdfinemp AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                            NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_valida_inclusao_tr
         aux_handproc = PROC-HANDLE NO-ERROR
                      (INPUT par_cdcooper,      /* Cooperativa */
                       INPUT par_cdlcremp,      /* Linha de credito */
                       INPUT par_dtmvtolt,      /* Data Movimentacao */
                       INPUT par_qtpreemp,      /* Quantidade Presacoes */
                       INPUT INT(par_flgpagto), /* Debitar em Conta */
                       INPUT par_dtdpagto,      /* Data de Pagamento */
                       INPUT par_cdfinemp,      /* Finalidade */
                       INPUT par_cdoperad,      /* Operador   */
                      OUTPUT 0,
                      OUTPUT "").

    CLOSE STORED-PROC pc_valida_inclusao_tr 
       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
 
    ASSIGN par_cdcritic = pc_valida_inclusao_tr.pr_cdcritic
                             WHEN pc_valida_inclusao_tr.pr_cdcritic <> ?
           par_dscritic = pc_valida_inclusao_tr.pr_dscritic
                             WHEN pc_valida_inclusao_tr.pr_dscritic <> ?.

    RETURN "OK".

END PROCEDURE.
              
PROCEDURE carrega_dados_proposta_finalidade:

    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_tpemprst AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdfinemp AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_flgatual AS LOG                              NO-UNDO.
    DEF  INPUT PARAM par_dsctrliq AS CHAR                             NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dados-proposta-fin.

    DEF VAR aux_qtregist AS INTE                                      NO-UNDO.
    DEF VAR aux_flgcescr AS LOG INIT FALSE                            NO-UNDO.
    DEF VAR aux_dtdpagto LIKE crawepr.dtdpagto                        NO-UNDO.
    DEF VAR aux_nrctrliq LIKE crawepr.nrctrliq                        NO-UNDO.
    DEF VAR h-b1wgen0043 AS HANDLE                                    NO-UNDO.
    DEF VAR h-b1wgen0059 AS HANDLE                                    NO-UNDO.

    DEF  BUFFER b1-crapfin FOR crapfin.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

     FOR EACH tt-dados-proposta-fin NO-LOCK:
          DELETE tt-dados-proposta-fin.
     END.

    CREATE tt-dados-proposta-fin.

    /* Verifica se atualiza as informacoes em tela */
    IF par_flgatual THEN
       DO:
           RUN sistema/generico/procedures/b1wgen0043.p
               PERSISTENT SET h-b1wgen0043.

           /* Calcula o Risco */
           RUN obtem_emprestimo_risco 
               IN h-b1wgen0043 (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT par_cdoperad,
                                INPUT par_nrdconta,
                                INPUT 1, /* par_idseqttl */
                                INPUT par_idorigem,
                                INPUT par_nmdatela,
                                INPUT FALSE, /* par_flgerlog */
                                INPUT par_cdfinemp,
                                INPUT par_cdlcremp,
                                INPUT aux_nrctrliq,
                                INPUT par_dsctrliq,
                                OUTPUT TABLE tt-erro,
                                OUTPUT tt-dados-proposta-fin.dsnivris).

           DELETE PROCEDURE h-b1wgen0043.
            
           IF RETURN-VALUE <> "OK" THEN
              RETURN "NOK".
       END.

    /* Condicao para a Finalidade for Cessao de Credito */
    FOR FIRST b1-crapfin FIELDS(tpfinali)
                         WHERE b1-crapfin.cdcooper = par_cdcooper AND 
                               b1-crapfin.cdfinemp = par_cdfinemp
                               NO-LOCK: END.

    IF AVAIL b1-crapfin AND b1-crapfin.tpfinali = 1 THEN
       ASSIGN aux_flgcescr = TRUE.
          
    /* Verificacao para saber se a finalidade eh cessao de credito */
    IF aux_flgcescr THEN
       DO:
           /* Emprestimo TR e POS nao poderao ter finalidade de cessao de credito */
           IF par_tpemprst = 0 OR
              par_tpemprst = 2 THEN
              DO:
                  ASSIGN aux_cdcritic = 946.
        
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).
                  RETURN "NOK".
              END.
           
           ASSIGN tt-dados-proposta-fin.flgcescr = TRUE.

           /* Verifica se atualiza as informacoes em tela */
           IF par_flgatual THEN
              DO:
                  FOR FIRST crapdat FIELDS(dtmvtopr) 
                                    WHERE crapdat.cdcooper = par_cdcooper
                                          NO-LOCK: END.

                  /* Campo Data de Pagamento */
                  IF CAN-DO("28,29,30,31",STRING(DAY(crapdat.dtmvtopr))) THEN
                     DO:
                        /* ultimo dia do mes corrente */
                        ASSIGN aux_dtdpagto = ((DATE(MONTH(par_dtmvtolt),28,YEAR(par_dtmvtolt)) + 4) -
                                                DAY(DATE(MONTH(par_dtmvtolt),28,
                                                YEAR(par_dtmvtolt)) + 4)).

                        /* Retorna o proximo dia util do mes */
                        RUN retornaDataUtil(INPUT par_cdcooper,
                                            INPUT aux_dtdpagto,
                                            INPUT 1,
                                           OUTPUT tt-dados-proposta-fin.dtdpagto).

                     END.
                  ELSE
                     ASSIGN tt-dados-proposta-fin.dtdpagto = crapdat.dtmvtopr.

              END. /* END IF par_cddopcao = "I" THEN */

           FOR FIRST crapass FIELDS(inpessoa)
                             WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta
                                   NO-LOCK: END.

           IF NOT AVAIL crapass THEN
              DO:
                  ASSIGN aux_cdcritic = 9.
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).
                  RETURN "NOK".
              END.

           IF NOT VALID-HANDLE(h-b1wgen0059) THEN
              RUN sistema/generico/procedures/b1wgen0059.p 
                  PERSISTENT SET h-b1wgen0059.

           IF crapass.inpessoa = 1 THEN
              DO:
                  FOR FIRST crapttl FIELDS(nrinfcad nrpatlvr)
                                    WHERE crapttl.cdcooper = par_cdcooper AND
                                          crapttl.nrdconta = par_nrdconta AND
                                          crapttl.idseqttl = 1
                                          NO-LOCK: END.

                  IF NOT AVAIL crapttl THEN
                     DO:
                         ASSIGN aux_cdcritic = 821.
                         RUN gera_erro (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT 1,
                                        INPUT aux_cdcritic,
                                        INPUT-OUTPUT aux_dscritic).
                         
                         IF VALID-HANDLE(h-b1wgen0059) THEN
                            DELETE PROCEDURE h-b1wgen0059.               
                         
                         RETURN "NOK".
                     END.


                  ASSIGN tt-dados-proposta-fin.nrinfcad = crapttl.nrinfcad
                         tt-dados-proposta-fin.nrpatlvr = crapttl.nrpatlvr
                         tt-dados-proposta-fin.nrgarope = 10
                         tt-dados-proposta-fin.nrliquid = 9.

                  IF crapttl.nrinfcad < 3 OR crapttl.nrinfcad = ? THEN
                     ASSIGN tt-dados-proposta-fin.nrinfcad = 3.

                  IF crapttl.nrpatlvr = 0 OR crapttl.nrpatlvr = ? THEN
                     ASSIGN tt-dados-proposta-fin.nrpatlvr = 3.

                  /* Descricao da Garantia */
                  RUN busca-craprad 
                   IN h-b1wgen0059 (INPUT par_cdcooper,
                                    INPUT 2,
                                    INPUT 2,
                                    INPUT tt-dados-proposta-fin.nrgarope,
                                    INPUT "",
                                    INPUT NO,
                                    INPUT 1,
                                    INPUT 0,
                                    OUTPUT aux_qtregist,
                                    OUTPUT TABLE tt-craprad).

                  FIND FIRST tt-craprad NO-LOCK NO-ERROR.
                  IF AVAIL tt-craprad THEN 
                     ASSIGN tt-dados-proposta-fin.dsgarope = tt-craprad.dsseqit1.

                  /* Descricao da Liquidez */
                  RUN busca-craprad 
                   IN h-b1wgen0059 (INPUT par_cdcooper,
                                    INPUT 2,
                                    INPUT 3,
                                    INPUT tt-dados-proposta-fin.nrliquid,
                                    INPUT "",
                                    INPUT NO,
                                    INPUT 1,
                                    INPUT 0,
                                    OUTPUT aux_qtregist,
                                    OUTPUT TABLE tt-craprad).

                  FIND FIRST tt-craprad NO-LOCK NO-ERROR.
                  IF AVAIL tt-craprad THEN 
                     ASSIGN tt-dados-proposta-fin.dsliquid = tt-craprad.dsseqit1.

                  /* Descricao Patrimonio Pessoal Livre */
                  RUN busca-craprad 
                   IN h-b1wgen0059 (INPUT par_cdcooper,
                                    INPUT 1,
                                    INPUT 8,
                                    INPUT tt-dados-proposta-fin.nrpatlvr,
                                    INPUT "",
                                    INPUT NO,
                                    INPUT 1,
                                    INPUT 0,
                                    OUTPUT aux_qtregist,
                                    OUTPUT TABLE tt-craprad).

                  FIND FIRST tt-craprad NO-LOCK NO-ERROR.
                  IF AVAIL tt-craprad THEN 
                     ASSIGN tt-dados-proposta-fin.dspatlvr = tt-craprad.dsseqit1.

                  /* Informacao Cadastral */
                  RUN busca-craprad 
                   IN h-b1wgen0059 (INPUT par_cdcooper,
                                    INPUT 1,
                                    INPUT 4,
                                    INPUT tt-dados-proposta-fin.nrinfcad,
                                    INPUT "",
                                    INPUT NO,
                                    INPUT 1,
                                    INPUT 0,
                                    OUTPUT aux_qtregist,
                                    OUTPUT TABLE tt-craprad).

                  FIND FIRST tt-craprad NO-LOCK NO-ERROR.
                  IF AVAIL tt-craprad THEN 
                     ASSIGN tt-dados-proposta-fin.dsinfcad = tt-craprad.dsseqit1.

              END.
           ELSE
              DO:
                  FOR FIRST crapjur FIELDS(nrinfcad nrpatlvr)
                                    WHERE crapjur.cdcooper = par_cdcooper AND
                                          crapjur.nrdconta = par_nrdconta
                                          NO-LOCK: END.

                  IF NOT AVAIL crapjur THEN
                     DO:
                         ASSIGN aux_cdcritic = 821.
                         RUN gera_erro (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT 1,
                                        INPUT aux_cdcritic,
                                        INPUT-OUTPUT aux_dscritic).
                        
                        IF VALID-HANDLE(h-b1wgen0059) THEN
                           DELETE PROCEDURE h-b1wgen0059.              
                                        
                         RETURN "NOK".
                     END.

                  ASSIGN tt-dados-proposta-fin.nrinfcad = crapjur.nrinfcad
                         tt-dados-proposta-fin.nrpatlvr = crapjur.nrpatlvr
                         tt-dados-proposta-fin.nrgarope = 11
                         tt-dados-proposta-fin.nrliquid = 11
                         tt-dados-proposta-fin.nrperger = 4.

                  IF crapjur.nrinfcad < 3 OR crapjur.nrinfcad = ? THEN
                     ASSIGN tt-dados-proposta-fin.nrinfcad = 3.

                  IF crapjur.nrpatlvr = 0 OR crapjur.nrpatlvr = ? THEN
                     ASSIGN tt-dados-proposta-fin.nrpatlvr = 5.

                  /* Descricao da Garantia */
                  RUN busca-craprad 
                   IN h-b1wgen0059 (INPUT par_cdcooper,
                                    INPUT 4,
                                    INPUT 2,
                                    INPUT tt-dados-proposta-fin.nrgarope,
                                    INPUT "",
                                    INPUT NO,
                                    INPUT 1,
                                    INPUT 0,
                                    OUTPUT aux_qtregist,
                                    OUTPUT TABLE tt-craprad).

                  FIND FIRST tt-craprad NO-LOCK NO-ERROR.
                  IF AVAIL tt-craprad THEN 
                     ASSIGN tt-dados-proposta-fin.dsgarope = tt-craprad.dsseqit1.

                  /* Descricao da Liquidez */
                  RUN busca-craprad 
                   IN h-b1wgen0059 (INPUT par_cdcooper,
                                    INPUT 4,
                                    INPUT 2,
                                    INPUT tt-dados-proposta-fin.nrliquid,
                                    INPUT "",
                                    INPUT NO,
                                    INPUT 1,
                                    INPUT 0,
                                    OUTPUT aux_qtregist,
                                    OUTPUT TABLE tt-craprad).

                  FIND FIRST tt-craprad NO-LOCK NO-ERROR.
                  IF AVAIL tt-craprad THEN 
                     ASSIGN tt-dados-proposta-fin.dsliquid = tt-craprad.dsseqit1.

                  /* Descricao Patrimonio Pessoal Livre */
                  RUN busca-craprad 
                   IN h-b1wgen0059 (INPUT par_cdcooper,
                                    INPUT 3,
                                    INPUT 9,
                                    INPUT tt-dados-proposta-fin.nrpatlvr,
                                    INPUT "",
                                    INPUT NO,
                                    INPUT 1,
                                    INPUT 0,
                                    OUTPUT aux_qtregist,
                                    OUTPUT TABLE tt-craprad).

                  FIND FIRST tt-craprad NO-LOCK NO-ERROR.
                  IF AVAIL tt-craprad THEN 
                     ASSIGN tt-dados-proposta-fin.dspatlvr = tt-craprad.dsseqit1.

                  /* Percepcao Geral Relacao a Empresa */
                  RUN busca-craprad 
                   IN h-b1wgen0059 (INPUT par_cdcooper,
                                    INPUT 3,
                                    INPUT 11,
                                    INPUT tt-dados-proposta-fin.nrperger,
                                    INPUT "",
                                    INPUT NO,
                                    INPUT 1,
                                    INPUT 0,
                                    OUTPUT aux_qtregist,
                                    OUTPUT TABLE tt-craprad).

                  FIND FIRST tt-craprad NO-LOCK NO-ERROR.
                  IF AVAIL tt-craprad THEN 
                     ASSIGN tt-dados-proposta-fin.dsperger = tt-craprad.dsseqit1.

                  /* Informacao Cadastral */
                  RUN busca-craprad 
                   IN h-b1wgen0059 (INPUT par_cdcooper,
                                    INPUT 3,
                                    INPUT 3,
                                    INPUT tt-dados-proposta-fin.nrinfcad,
                                    INPUT "",
                                    INPUT NO,
                                    INPUT 1,
                                    INPUT 0,
                                    OUTPUT aux_qtregist,
                                    OUTPUT TABLE tt-craprad).

                  FIND FIRST tt-craprad NO-LOCK NO-ERROR.
                  IF AVAIL tt-craprad THEN 
                     ASSIGN tt-dados-proposta-fin.dsinfcad = tt-craprad.dsseqit1.
              END.

           IF VALID-HANDLE(h-b1wgen0059) THEN
              DELETE PROCEDURE h-b1wgen0059.

       END. /* END IF IF aux_flgcescr THEN */
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE carrega_dados_proposta_linha_credito:

    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdfinemp AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_dsctrliq AS CHAR                             NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM par_dsnivris AS CHAR                             NO-UNDO.
    DEF OUTPUT PARAM par_inobriga AS CHAR                             NO-UNDO.

    DEF VAR aux_nrctrliq LIKE crawepr.nrctrliq                        NO-UNDO.
    DEF VAR h-b1wgen0043 AS HANDLE                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    IF NOT VALID-HANDLE(h-b1wgen0043) THEN
       RUN sistema/generico/procedures/b1wgen0043.p
           PERSISTENT SET h-b1wgen0043.

    /* Calcula o Risco */
    RUN obtem_emprestimo_risco 
        IN h-b1wgen0043 (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT par_cdoperad,
                         INPUT par_nrdconta,
                         INPUT 1, /* par_idseqttl */
                         INPUT par_idorigem,
                         INPUT par_nmdatela,
                         INPUT FALSE, /* par_flgerlog */
                         INPUT par_cdfinemp,
                         INPUT par_cdlcremp,
                         INPUT aux_nrctrliq,
                         INPUT par_dsctrliq,
                         OUTPUT TABLE tt-erro,
                         OUTPUT par_dsnivris).
                         
    IF VALID-HANDLE(h-b1wgen0043) THEN
       DELETE PROCEDURE h-b1wgen0043.
     
    IF RETURN-VALUE <> "OK" THEN
       RETURN "NOK".

    /* Buscar tipo da Pessoa */
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapass THEN
       DO:
          ASSIGN aux_cdcritic = 9.

          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).

          RETURN "NOK".

       END.
       
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_obrigacao_analise_automatic
     aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                          INPUT crapass.inpessoa, /* Tipo da Pessoa */
                                          INPUT par_cdfinemp, /* Código da finalidade de crédito */
                                          INPUT par_cdlcremp, /* Código da linha de crédito */
                                         OUTPUT "",           /* Obrigaçao de análise automática (S/N) */
                                         OUTPUT 0,            /* Código da crítica */
                                         OUTPUT "").          /* Descrição da crítica */
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_obrigacao_analise_automatic
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }


    ASSIGN par_inobriga = pc_obrigacao_analise_automatic.pr_inobriga
                             WHEN pc_obrigacao_analise_automatic.pr_inobriga <> ?
           aux_cdcritic = pc_obrigacao_analise_automatic.pr_cdcritic
                             WHEN pc_obrigacao_analise_automatic.pr_cdcritic <> ?
           aux_dscritic = pc_obrigacao_analise_automatic.pr_dscritic
                             WHEN pc_obrigacao_analise_automatic.pr_dscritic <> ?.

    IF aux_cdcritic > 0 OR 
       aux_dscritic <> '' THEN
       DO:
          CREATE tt-erro.
          ASSIGN tt-erro.cdcritic = aux_cdcritic
                 tt-erro.dscritic = aux_dscritic.

          RETURN "NOK".

       END.
       
    RETURN "OK".

END PROCEDURE.

PROCEDURE atualiza_risco_proposta:

    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                             NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dsnivris AS CHAR                                      NO-UNDO.
    DEF VAR aux_contador AS INTE                                      NO-UNDO.
    DEF VAR h-b1wgen0043 AS HANDLE                                    NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_atualiza_risco_proposta
      aux_handproc = PROC-HANDLE NO-ERROR 
                   ( INPUT par_cdcooper /* pr_cdcooper --> Codigo da cooperativa */
                    ,INPUT par_cdagenci /* pr_cdagenci --> Codigo de agencia */
                    ,INPUT par_nrdcaixa /* pr_nrdcaixa --> Numero do caixa */
                    ,INPUT par_cdoperad /* pr_cdoperad --> Codigo do operador */
                    ,INPUT par_nmdatela /* pr_nmdatela --> Nome da tela */
                    ,INPUT par_idorigem /* pr_idorigem --> Identificado de oriem */
                    ,INPUT par_dtmvtolt /* pr_dtmvtolt --> Data de movimento */
                    ,INPUT par_nrdconta /* pr_nrdconta --> Numero da conta */
                    ,INPUT par_nrctremp /* pr_nrctremp --> Numero de contrato */                                      
                      /* ------ OUT ------                         */              
                    ,OUTPUT ""           /* pr_dscritic --> Descriçao da critica */
                    ,OUTPUT 0  ).        /* pr_cdcritic --> Codigo da critica */
        
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_atualiza_risco_proposta
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }


    ASSIGN aux_cdcritic = pc_atualiza_risco_proposta.pr_cdcritic
                             WHEN pc_atualiza_risco_proposta.pr_cdcritic <> ?
           aux_dscritic = pc_atualiza_risco_proposta.pr_dscritic
                             WHEN pc_atualiza_risco_proposta.pr_dscritic <> ?.

    IF aux_cdcritic > 0 OR aux_dscritic <> '' THEN
       DO:
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                        INPUT 1, /*sequencia*/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
           RETURN "NOK".
       END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE recalcular_emprestimo:

    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                             NO-UNDO.    
    DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                             NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    
    DEF VAR aux_dsoperac AS CHAR                                      NO-UNDO.
    DEF VAR aux_contador AS INTE                                      NO-UNDO.
    DEF VAR aux_percetop AS DECI                                      NO-UNDO.
    DEF VAR aux_txcetmes AS DECI                                      NO-UNDO.
    DEF VAR aux_nivrisco AS CHAR                                      NO-UNDO.
    DEF VAR aux_vlpreemp LIKE crawepr.vlpreemp                        NO-UNDO.
    DEF VAR aux_qtdias_carencia AS INTE                               NO-UNDO.
    DEF VAR h-b1wgen0043 AS HANDLE                                                             NO-UNDO.
    DEF VAR h-b1wgen0110 AS HANDLE                                                             NO-UNDO.
    DEF VAR aux_dscatbem AS CHAR                                      NO-UNDO.
    DEF VAR aux_dsctrliq AS CHAR                                      NO-UNDO.
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-msg-confirma. 
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Recalcular Emprestimo".
       
    FOR crapass FIELDS(inpessoa nrcpfcgc) 
		          	WHERE crapass.cdcooper = par_cdcooper AND
                      crapass.nrdconta = par_nrdconta
                      NO-LOCK: END.

    IF NOT AVAILABLE crapass THEN
       DO:
           ASSIGN aux_cdcritic = 9.
           
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1, /*sequencia*/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".
       END.
   
    /*Monta a mensagem da operacao para envio no e-mail */
    ASSIGN aux_dsoperac = "Tentativa de recalcular o valor da proposta de " +
                          "emprestimo/financiamento na conta "              + 
                          STRING(par_nrdconta,"zzzz,zzz,9")                 +
                          " - CPF/CNPJ "                                    +
                         (IF crapass.inpessoa = 1 THEN
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999")),"xxx.xxx.xxx-xx")
                          ELSE
                             STRING((STRING(crapass.nrcpfcgc,
                                           "99999999999999")),
                                           "xx.xxx.xxx/xxxx-xx")).
   
    RECALCULAR: 
    DO TRANSACTION ON ERROR  UNDO RECALCULAR, LEAVE RECALCULAR
                   ON ENDKEY UNDO RECALCULAR, LEAVE RECALCULAR:
                          
       IF NOT VALID-HANDLE(h-b1wgen0110) THEN
          RUN sistema/generico/procedures/b1wgen0110.p PERSISTENT SET h-b1wgen0110.
          
       /*Verifica se o associado esta no cadastro restritivo*/
       RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_nmdatela,
                                         INPUT par_dtmvtolt,
                                         INPUT par_idorigem,
                                         INPUT crapass.nrcpfcgc,
                                         INPUT par_nrdconta,
                                         INPUT par_idseqttl,
                                         INPUT TRUE, /*bloqueia operacao*/
                                         INPUT 10,   /*cdoperac*/
                                         INPUT aux_dsoperac,
                                         OUTPUT TABLE tt-erro).

       IF VALID-HANDLE(h-b1wgen0110) THEN
          DELETE PROCEDURE(h-b1wgen0110).
   
       IF RETURN-VALUE <> "OK" THEN
          DO:
              IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                 ASSIGN aux_dscritic = "Nao foi possivel verificar o " +
                                       "cadastro restritivo.".

              UNDO RECALCULAR, LEAVE RECALCULAR.
              
          END. /* END IF RETURN-VALUE <> "OK" THEN */
       
       DO aux_contador = 1 TO 10:

          FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                             crawepr.nrdconta = par_nrdconta   AND
                             crawepr.nrctremp = par_nrctremp
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF NOT AVAILABLE crawepr THEN
             IF LOCKED crawepr THEN
                DO:
                    ASSIGN aux_cdcritic = 371.
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
             ELSE
                DO:
                    ASSIGN aux_cdcritic = 510.
                    LEAVE.
                END.

          ASSIGN aux_cdcritic = 0.
          LEAVE.

       END. /* END DO aux_contador = 1 TO 10: */

       IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
          UNDO RECALCULAR, LEAVE RECALCULAR.
    
       /* Somente os produtos PP e POS poderao recalcular as parcelas */
       IF crawepr.tpemprst <> 1 AND
          crawepr.tpemprst <> 2 THEN
          DO:
              ASSIGN aux_cdcritic = 946.
              UNDO RECALCULAR, LEAVE RECALCULAR.
          END.
          
       IF crawepr.dtlibera = par_dtmvtolt THEN
          DO:
              ASSIGN aux_dscritic = "A proposta nao foi recalculada. A data " +
                                    "atual e igual a data de liberacao da proposta.".
              UNDO RECALCULAR, LEAVE RECALCULAR.
          END.   
          
       /* Atualiza a nova data de liberacao da proposta de emprestimo */
       ASSIGN crawepr.dtlibera = par_dtmvtolt
              aux_vlpreemp     = crawepr.vlpreemp.    
    
       IF   crawepr.tpemprst = 1   THEN
            DO:
       IF NOT VALID-HANDLE(h-b1wgen0084) THEN
          RUN sistema/generico/procedures/b1wgen0084.p 
              PERSISTENT SET h-b1wgen0084.

       RUN grava_parcelas_proposta IN h-b1wgen0084(INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT par_cdoperad,
                                                   INPUT par_nmdatela,
                                                   INPUT par_idorigem,
                                                   INPUT par_nrdconta,
                                                   INPUT par_idseqttl,
                                                   INPUT par_dtmvtolt,
                                                   INPUT TRUE,
                                                   INPUT crawepr.nrctremp,
                                                   INPUT crawepr.cdlcremp,
                                                   INPUT crawepr.cdfinemp,
                                                   INPUT crawepr.vlemprst,
                                                   INPUT crawepr.qtpreemp,
                                                   INPUT crawepr.dtlibera,
                                                   INPUT crawepr.dtdpagto,
                                                   INPUT crawepr.idfiniof,
                                                   OUTPUT TABLE tt-erro).

       IF VALID-HANDLE(h-b1wgen0084) THEN
          DELETE OBJECT h-b1wgen0084.
    
       IF RETURN-VALUE <> "OK" THEN
          DO:
              IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                 ASSIGN aux_dscritic = "Ocorreram erros durante a gravacao das " +
                                       "parcelas da proposta.".

                       UNDO RECALCULAR, LEAVE RECALCULAR.
                   END.
            END.
       ELSE IF  crawepr.tpemprst = 2   THEN
            DO:
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                /* Efetuar a chamada a rotina Oracle  */
                RUN STORED-PROCEDURE pc_busca_qtd_dias_carencia
                    aux_handproc = PROC-HANDLE NO-ERROR (INPUT crawepr.idcarenc,
                                                        OUTPUT 0,   /* pr_qtddias */
                                                        OUTPUT 0,   /* pr_cdcritic */
                                                        OUTPUT ""). /* pr_dscritic */  

                /* Fechar o procedimento para buscarmos o resultado */ 
                CLOSE STORED-PROC pc_busca_qtd_dias_carencia
                       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                ASSIGN aux_cdcritic = 0
                       aux_dscritic = ""
                       aux_cdcritic = INT(pc_busca_qtd_dias_carencia.pr_cdcritic) 
                                      WHEN pc_busca_qtd_dias_carencia.pr_cdcritic <> ?
                       aux_dscritic = pc_busca_qtd_dias_carencia.pr_dscritic
                                      WHEN pc_busca_qtd_dias_carencia.pr_dscritic <> ?
                       aux_qtdias_carencia = INT(pc_busca_qtd_dias_carencia.pr_qtddias) 
                                             WHEN pc_busca_qtd_dias_carencia.pr_qtddias <> ?.

                IF   aux_cdcritic <> 0    OR
                     aux_dscritic <> ""   THEN
                     UNDO RECALCULAR, LEAVE RECALCULAR.

                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                /* Efetuar a chamada a rotina Oracle  */
                RUN STORED-PROCEDURE pc_grava_parcel_pos_fixado
                    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                                         INPUT par_nrdconta,
                                                         INPUT par_dtmvtolt,
                                                         INPUT crawepr.nrctremp,
                                                         INPUT crawepr.cdlcremp,
                                                         INPUT crawepr.vlemprst,
                                                         INPUT crawepr.qtpreemp,
                                                         INPUT crawepr.dtcarenc,
                                                         INPUT crawepr.dtdpagto,
                                                         INPUT aux_qtdias_carencia,
                                                        OUTPUT 0,   /* pr_vlpreemp */
                                                        OUTPUT 0,   /* pr_txdiaria */
                                                        OUTPUT 0,   /* pr_txmensal */
                                                        OUTPUT 0,   /* pr_cdcritic */
                                                        OUTPUT ""). /* pr_dscritic */  

                /* Fechar o procedimento para buscarmos o resultado */ 
                CLOSE STORED-PROC pc_grava_parcel_pos_fixado
                       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                ASSIGN aux_cdcritic = 0
                       aux_dscritic = ""
                       aux_cdcritic = INT(pc_grava_parcel_pos_fixado.pr_cdcritic) 
                                      WHEN pc_grava_parcel_pos_fixado.pr_cdcritic <> ?
                       aux_dscritic = pc_grava_parcel_pos_fixado.pr_dscritic
                                      WHEN pc_grava_parcel_pos_fixado.pr_dscritic <> ?.

                IF   aux_cdcritic <> 0    OR
                     aux_dscritic <> ""   THEN
              UNDO RECALCULAR, LEAVE RECALCULAR.

                /* Atualizar o buffer na tabela crawepr */
                ASSIGN crawepr.vlpreemp = pc_grava_parcel_pos_fixado.pr_vlpreemp.

            END.

       ASSIGN aux_dscatbem = "".
       FOR EACH crapbpr WHERE crapbpr.cdcooper = crawepr.cdcooper  AND
                             crapbpr.nrdconta = crawepr.nrdconta  AND
                             crapbpr.nrctrpro = crawepr.nrctremp  AND 
                             crapbpr.tpctrpro = 90 NO-LOCK:
          ASSIGN aux_dscatbem = aux_dscatbem + "|" + crapbpr.dscatbem.
          END.

       RUN buscar_liquidacoes_contrato(INPUT crawepr.cdcooper,
                                        INPUT crawepr.nrdconta,
                                        INPUT crawepr.nrctremp,
                                        OUTPUT aux_dsctrliq).
                    
       /* Calclar o cet automaticamente */
       RUN calcula_cet_novo(INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_nmdatela,
                            INPUT par_idorigem,
                            INPUT par_dtmvtolt,
                            INPUT par_nrdconta,
                            INPUT crapass.inpessoa, 
                            INPUT 2, /* cdusolcr */
                            INPUT crawepr.cdlcremp,
                            INPUT crawepr.tpemprst,
                            INPUT crawepr.nrctremp,
                            INPUT crawepr.dtlibera,
                            INPUT crawepr.vlemprst,
                            INPUT crawepr.vlpreemp,
                            INPUT crawepr.qtpreemp,
                            INPUT crawepr.dtdpagto,
                            INPUT crawepr.cdfinemp, 
                            INPUT aux_dscatbem,
                            INPUT crawepr.idfiniof,
                            INPUT aux_dsctrliq,
                            INPUT "N",
                            INPUT crawepr.dtcarenc,
                           OUTPUT aux_percetop, /* taxa cet ano */
                           OUTPUT aux_txcetmes, /* taxa cet mes */
                           OUTPUT TABLE tt-erro). 

       IF RETURN-VALUE <> "OK" THEN
          DO:
              IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                 ASSIGN aux_dscritic = "Nao foi possivel calcular o CET.".

              UNDO RECALCULAR, LEAVE RECALCULAR.
          END.	
              
       /* Calculo do Risco do Emprestimo */
       IF NOT VALID-HANDLE(h-b1wgen0043) THEN
          RUN sistema/generico/procedures/b1wgen0043.p 
              PERSISTENT SET h-b1wgen0043.
       
       RUN obtem_emprestimo_risco IN h-b1wgen0043 (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT par_cdoperad,
                                                   INPUT par_nrdconta,
                                                   INPUT par_idseqttl,
                                                   INPUT par_idorigem,
                                                   INPUT par_nmdatela,
                                                   INPUT TRUE,
                                                   INPUT crawepr.cdfinemp,
                                                   INPUT crawepr.cdlcremp,
                                                   INPUT crawepr.nrctrliq,
                                                   INPUT "",
                                                   OUTPUT TABLE tt-erro,
                                                   OUTPUT aux_nivrisco).
       
       IF VALID-HANDLE(h-b1wgen0043) THEN
          DELETE PROCEDURE h-b1wgen0043.

       IF RETURN-VALUE <> "OK" THEN
          UNDO RECALCULAR, LEAVE RECALCULAR.
                  
       /* Atualiza os campos da proposta de emprestimo */
       ASSIGN crawepr.percetop = aux_percetop
              crawepr.dsnivris = UPPER(aux_nivrisco)
              crawepr.dsnivori = UPPER(aux_nivrisco).

       CREATE tt-msg-confirma.
       ASSIGN tt-msg-confirma.inconfir = 1
              tt-msg-confirma.dsmensag = "Atencao! A data de liberacao do recurso "     +
                                         "foi alterada automaticamente para hoje "      +
                                         STRING(par_dtmvtolt,"99/99/9999") + ". <br />" +
                                         "Valor da parcela atualizado de R$ "           +
                                         TRIM(STRING(aux_vlpreemp,"zzz,zzz,zz9.99"))    +
                                         " para R$ " +
                                         TRIM(STRING(crawepr.vlpreemp,"zzz,zzz,zz9.99")) + ".".
                                       
       RUN proc_gerar_log (INPUT par_cdcooper,
                           INPUT par_cdoperad,
                           INPUT "",
                           INPUT aux_dsorigem,
                           INPUT aux_dstransa,
                           INPUT TRUE,
                           INPUT par_idseqttl,
                           INPUT par_nmdatela,
                           INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

       RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                INPUT "nrctremp",
                                INPUT par_nrctremp,
                                INPUT par_nrctremp).
                                
       RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                INPUT "vlpreemp",
                                INPUT aux_vlpreemp,
                                INPUT crawepr.vlpreemp).

    END. /* END DO TRANSACTION */

    /* Verificacao para saber se ocorreu erro no processamento */
    IF aux_cdcritic <> 0 OR aux_dscritic <> "" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO:
           IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN 
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".
       END.
       
    RETURN "OK".

END.


/* rotina para verificacao de emprestimo de portabilidade */
PROCEDURE possui_portabilidade:

    DEF INPUT  PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT  PARAM par_nrctremp AS INTE NO-UNDO.
    DEF OUTPUT PARAM par_err_efet AS INTE NO-UNDO.
    DEF OUTPUT PARAM par_des_reto AS CHAR NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_possui_portabilidade
     aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                          INPUT par_nrdconta, /* Numero da Conta */
                                          INPUT par_nrctremp, /* Numero da Proposta */
                                         OUTPUT 0,            /* Erro na efetivacao (0/1) */
                                         OUTPUT "",           /* Portabilidade(S/N) */
                                         OUTPUT 0,            /* Código da crítica */
                                         OUTPUT "").          /* Descrição da crítica */
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_possui_portabilidade
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }


    ASSIGN par_err_efet = pc_possui_portabilidade.pr_err_efet
                             WHEN pc_possui_portabilidade.pr_err_efet <> ?
           par_des_reto = pc_possui_portabilidade.pr_des_reto
                             WHEN pc_possui_portabilidade.pr_des_reto <> ?
           par_cdcritic = pc_possui_portabilidade.pr_cdcritic
                             WHEN pc_possui_portabilidade.pr_cdcritic <> ?
           par_dscritic = pc_possui_portabilidade.pr_dscritic
                             WHEN pc_possui_portabilidade.pr_dscritic <> ?.

    IF par_cdcritic > 0 OR par_dscritic <> '' THEN
    DO:
        RETURN "Erro nr.: " + STRING(par_cdcritic) + " - " + par_dscritic.
    END.
    ELSE
    DO:
        RETURN par_des_reto. /* Portabilidade (S/N)*/
    END.

END PROCEDURE.

PROCEDURE verifica_mensagem_garantia:

    DEF INPUT  PARAM par_cdcooper AS INTE                 NO-UNDO.
    DEF INPUT  PARAM par_dscatbem AS CHAR                 NO-UNDO.
    DEF INPUT  PARAM par_vlmerbem AS DECI                 NO-UNDO.
    DEF INPUT  PARAM par_vlemprst AS DECI                 NO-UNDO.
    DEF OUTPUT PARAM par_flgsenha AS INTE                 NO-UNDO.
    DEF OUTPUT PARAM par_dsmensag AS CHAR                 NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                 NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                 NO-UNDO.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_verifica_msg_garantia
     aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Codigo da Cooperativa */
                                          INPUT par_dscatbem, /* Descricao da categoria do Bem */
                                          INPUT par_vlmerbem, /* Valor da garantia do Bem */
                                          INPUT par_vlemprst, /* Valor do Emprestimo */
                                         OUTPUT 0,            /* Verifica se solicita senha de coordenador */                                         
                                         OUTPUT "",           /* Descricao da mensagem de aviso */
                                         OUTPUT 0,            /* Codigo da crítica */
                                         OUTPUT "").          /* Descrição da critica */
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_verifica_msg_garantia
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN par_flgsenha = pc_verifica_msg_garantia.pr_flgsenha
                             WHEN pc_verifica_msg_garantia.pr_flgsenha <> ?
           par_dsmensag = pc_verifica_msg_garantia.pr_dsmensag
                             WHEN pc_verifica_msg_garantia.pr_dsmensag <> ?
           par_cdcritic = pc_verifica_msg_garantia.pr_cdcritic
                             WHEN pc_verifica_msg_garantia.pr_cdcritic <> ?
           par_dscritic = pc_verifica_msg_garantia.pr_dscritic
                             WHEN pc_verifica_msg_garantia.pr_dscritic <> ?.

    IF par_cdcritic <> 0 OR par_dscritic <> "" THEN
       RETURN "NOK".
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE valida_alteracao_valor_proposta:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_flgsenha AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dsmensag AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.    
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_valida_alt_valor_prop
      aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Cooperativa conectada */
                                           INPUT par_cdagenci, /* Codigo da agencia */
                                           INPUT par_nrdcaixa, /* Numero do caixa */
                                           INPUT par_cdoperad, /* Codigo do operador */
                                           INPUT par_nmdatela, /* Nome da tela */
                                           INPUT par_idorigem, /* Indicador da origem da chamada */
                                           INPUT par_nrdconta, /* Conta do associado */
                                           INPUT par_idseqttl, /* Sequencia de titularidade da conta */
                                           INPUT par_dtmvtolt, /* Data de Movimentacao */
                                           INPUT par_nrctremp, /* Numero Contrato */
                                           INPUT par_vlemprst, /* Numero Contrato */
                                          OUTPUT 0,            /* Verifica se solicita senha de coordenador */                                         
                                          OUTPUT "",           /* Descricao da mensagem de aviso */
                                          OUTPUT 0,            /* Codigo da critica  */
                                          OUTPUT "").          /* Descricao da critica */
                                    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_valida_alt_valor_prop
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN par_flgsenha = pc_valida_alt_valor_prop.pr_flgsenha
                             WHEN pc_valida_alt_valor_prop.pr_flgsenha <> ?
           par_dsmensag = pc_valida_alt_valor_prop.pr_dsmensag
                             WHEN pc_valida_alt_valor_prop.pr_dsmensag <> ?
           par_cdcritic = pc_valida_alt_valor_prop.pr_cdcritic
                             WHEN pc_valida_alt_valor_prop.pr_cdcritic <> ?
           par_dscritic = pc_valida_alt_valor_prop.pr_dscritic
                             WHEN pc_valida_alt_valor_prop.pr_dscritic <> ?.

    IF par_cdcritic <> 0 OR par_dscritic <> "" THEN
       RETURN "NOK".
    
    RETURN "OK".
    
END PROCEDURE.

/**************************************************************************
 Alterar todos os dados do avalista.
**************************************************************************/
PROCEDURE atualiza_dados_avalista_proposta:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE INIT 0                    NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dsdopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrctaava AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctaav2 AS INTE                           NO-UNDO.

    /** ------------------- Parametros do 1 avalista ------------------ **/
    DEF  INPUT PARAM par_nmdaval1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfav1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdocav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdcjav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpfcjav1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tdccjav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_doccjav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende1av1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende2av1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrfonav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_emailav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufava1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepav1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnacio1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vledvmt1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlrenme1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrender1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complen1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxaps1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inpesso1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtnasct1 AS DATE                           NO-UNDO.
	DEF  INPUT PARAM par_vlrecjg1 AS DECI                           NO-UNDO.

    /** ------------------- Parametros do 2 avalista ------------------- **/
    DEF  INPUT PARAM par_nmdaval2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfav2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdocav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdcjav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpfcjav2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tdccjav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_doccjav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende1av2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende2av2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrfonav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_emailav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufava2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepav2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnacio2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vledvmt2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlrenme2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrender2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complen2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxaps2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inpesso2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtnasct2 AS DATE                           NO-UNDO.
	DEF  INPUT PARAM par_vlrecjg2 AS DECI                           NO-UNDO.

    DEF  INPUT PARAM par_dsdbeavt AS CHAR                           NO-UNDO.
    /* Indica se permite reiniciar fluxo de aprovaçao */
    DEF  INPUT PARAM par_inresapr AS INT                            NO-UNDO.
	/* PJ438 */
	DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_idpeapro AS INT                     NO-UNDO.

    DEF OUTPUT PARAM par_flmudfai AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nrgarope AS INT                            NO-UNDO. /*PRJ438 - BUG*/
    DEF OUTPUT PARAM par_nrliquid AS INT                            NO-UNDO. /*PRJ438 - BUG*/    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.

    DEF  VAR         aux_contador AS INTE                           NO-UNDO.
    DEF  VAR         h-b1wgen0191 AS HANDLE                         NO-UNDO.
    DEF  VAR         h-b1wgen0188 AS HANDLE                         NO-UNDO.
    DEF  VAR         aux_insitapr LIKE crawepr.insitapr             NO-UNDO.
    DEF  VAR         aux_cdopeapr LIKE crawepr.cdopeapr             NO-UNDO.
    DEF  VAR         aux_dtaprova LIKE crawepr.dtaprova             NO-UNDO.
    DEF  VAR         aux_hraprova LIKE crawepr.hraprova             NO-UNDO.
    DEF  VAR         aux_insitest LIKE crawepr.insitest             NO-UNDO.
    DEF  VAR         aux_idcarga  AS INTE                           NO-UNDO.
    DEF VAR          aux_percamnt AS DECI                           NO-UNDO.
    
    DEF VAR          aux_contigen AS LOGI                           NO-UNDO.
    DEF VAR          aux_interrup AS LOGI                           NO-UNDO.
    DEF VAR          aux_avlalter AS LOGI                           NO-UNDO.
    DEF VAR          aux_inobriga AS CHAR                           NO-UNDO.

	/* Leonardo PJ438*/
	DEF VAR          aux_perdeaprvava AS INTE                       NO-UNDO.
	DEF VAR          aux_vlrmaxaprov AS DECI                        NO-UNDO.
	DEF VAR          aux_perdeuaprv   AS CHAR                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-msg-confirma.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Alterar os avalistas da proposta de credito"
           aux_interrup = FALSE
           aux_avlalter = FALSE
           aux_inobriga = "N"
		   aux_perdeuaprv = "N".

    Grava_valor:
    DO WHILE TRUE TRANSACTION
       ON ERROR UNDO Grava_valor, LEAVE Grava_valor:

        DO  aux_contador = 1 TO 10:

            FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                               crawepr.nrdconta = par_nrdconta   AND
                               crawepr.nrctremp = par_nrctremp
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAIL crawepr   THEN
                 IF   LOCKED crawepr   THEN
                      DO:
                          aux_cdcritic = 371.
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.
                 ELSE
                      DO:
                          aux_cdcritic = 510.
                          LEAVE.
                      END.

            aux_cdcritic = 0.
            LEAVE.

        END.

        IF  aux_cdcritic <> 0    OR
            aux_dscritic <> ""   THEN
            LEAVE.

      /* Se houve alteraçao do primeiro avalista */
      IF STRING(crawepr.nrctaav1) + TRIM(crawepr.nmdaval1) <> STRING(par_nrctaava) + TRIM(par_nmdaval1) THEN
        DO: 
        /*Valida alteração avalista não cooperado*/
        IF crawepr.nrctaav1 = 0 AND TRIM(crawepr.nmdaval1) <> "" THEN
        DO: 

        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT "Primeiro avalista nao cooperado alterado!",
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                            OUTPUT aux_nrdrowid). 

				  RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Nomes Avalista 1",
                                 INPUT crawepr.nmdaval1,
                                 INPUT par_nmdaval1).  
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Contas Avalista 1",
                                   INPUT crawepr.nrctaav1,
                                   INPUT par_nrctaava).
          ASSIGN aux_avlalter = TRUE.
      END.
        ELSE /*Casos onde são contas de cooperados*/
      DO:
          IF crawepr.nrctaav1 <> par_nrctaava THEN
          DO:
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT "Primeiro avalista alterado!",
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid). 
                                   
				  RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Avalista 1",
                                     INPUT crawepr.nrctaav1,
                                     INPUT par_nrctaava).        
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Nomes Avalista 1",
                                     INPUT crawepr.nmdaval1,
                                     INPUT ENCODE(par_nmdaval1)).
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Nomes Avalista 99",
                                     INPUT ENCODE(crawepr.nmdaval1),
                                     INPUT ENCODE(par_nmdaval1)).
           ASSIGN aux_avlalter = TRUE.
          END.
        END.
        END.
      
      /*Se houve alteracao do segundo avalista*/
      /*IF crawepr.nrctaav2 <> par_nrctaav2 THEN*/      
      IF STRING(crawepr.nrctaav2) + TRIM(crawepr.nmdaval2) <> STRING(par_nrctaav2) + TRIM(par_nmdaval2) THEN
      DO:
        /*Valida alteração avalista não cooperado*/
        IF crawepr.nrctaav2 = 0 AND TRIM(crawepr.nmdaval2) <> "" THEN
        DO:
          RUN proc_gerar_log (INPUT par_cdcooper,
                              INPUT par_cdoperad,
                              INPUT "",
                              INPUT aux_dsorigem,
                              INPUT "Segundo avalista nao cooperado alterado!",
                              INPUT TRUE,
                              INPUT par_idseqttl,
                              INPUT par_nmdatela,
                              INPUT par_nrdconta,
                             OUTPUT aux_nrdrowid).
                                     
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Nomes Avalista 2",
                                     INPUT crawepr.nmdaval2,
                                     INPUT par_nmdaval2).             
                                  
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Contas Avalista 2",
                                     INPUT crawepr.nrctaav2,
                                     INPUT par_nrctaav2).                                     
          ASSIGN aux_avlalter = TRUE.
      END.
        ELSE
        DO:
          IF crawepr.nrctaav2 <> par_nrctaav2 THEN
        DO: 
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT "Segundo avalista alterado!",
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
                               
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Avalista 2",
                                     INPUT crawepr.nrctaav2,
                                     INPUT par_nrctaav2).
           ASSIGN aux_avlalter = TRUE.
        END.
        END.
        END.
        
			IF aux_avlalter THEN
			DO:
			
				   ASSIGN aux_perdeaprvava = 0
						  aux_vlrmaxaprov  = 0.
						  
						{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
						 
						 /* chamar excecao de analise de aprovacao */
						 RUN STORED-PROCEDURE pc_aval_perde_aprov
						  aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */                                                           
															  OUTPUT 0, /* Parametro: 0 - False, 1 - True */
															  OUTPUT 0, /* valor maximo para nao perder aprovacao */          
															  OUTPUT 0,
															  OUTPUT ""). 
						 
						 /* Fechar o procedimento para buscarmos o resultado */ 
						 CLOSE STORED-PROC pc_aval_perde_aprov
							 aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

						 { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

						 ASSIGN aux_perdeaprvava = pc_aval_perde_aprov.pr_avtperda WHEN pc_aval_perde_aprov.pr_avtperda <> ?
								aux_vlrmaxaprov  = pc_aval_perde_aprov.pr_vlperavt WHEN pc_aval_perde_aprov.pr_vlperavt <> ?.
								
        /*P438 - Aplicar regra especifica do avalista com base na tab089 
          Se esta paremetrizado para Nao perder e valor parametrizado maior que o valor do empresitmo
          Nao devera perder a aprovacao
        */
					IF aux_perdeaprvava = 1 AND aux_vlrmaxaprov >= par_vlemprst THEN 
					  DO:
          ASSIGN aux_perdeuaprv = "N". /*Segunda a regra especifica nao devera perder*/
					  END.
					ELSE 
					  DO:
          ASSIGN aux_perdeuaprv = "S". /*Segunda a regra especifica deverá perder*/
					  END.
					  
					  
				RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Valor Maximo Aprovacao Parametrizado",
                                 INPUT "ND",
                                     INPUT aux_vlrmaxaprov).
									 
			    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Valor Emprestimo",
                                 INPUT "ND",
                                     INPUT par_vlemprst).
									 
				RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Deve Perder Aprovacao?",
                                 INPUT "ND",
                                     INPUT aux_perdeuaprv).
			
        END.
        
        
        ASSIGN crawepr.nrctaav1    = par_nrctaava
               crawepr.nrctaav2    = par_nrctaav2
               
               /* Avalista 1*/
               crawepr.nmdaval1    = CAPS(par_nmdaval1)
               crawepr.dscpfav1    = par_dsdocav1 + /* Documento / CPF */
                                     " " + STRING(par_nrctaava,"zzzz,zzz,9")
               crawepr.dsendav1[1] = CAPS(par_ende1av1) + " " +
                                     STRING(par_nrender1)
               crawepr.dsendav1[2] = CAPS(par_ende2av1) + " - " +
                                     CAPS(par_nmcidav1) + " - " +
                                     STRING(par_nrcepav1,"99999,999") + " - " +
                                     par_cdufava1
               /* Conjuge do aval 1*/
               crawepr.nmcjgav1 = CAPS(par_nmdcjav1)
               crawepr.dscfcav1 = par_doccjav1

               /* Avalista 2 */
               crawepr.nmdaval2    = CAPS(par_nmdaval2)
               crawepr.dscpfav2    = par_dsdocav2 + /* Documento / CPF */
                                     " " + STRING(par_nrctaav2,"zzzz,zzz,9")

               crawepr.dsendav2[1] = CAPS(par_ende1av2) + " " +
                                     STRING(par_nrender2)
               crawepr.dsendav2[2] = CAPS(par_ende2av2) + " - " +
                                     CAPS(par_nmcidav2) + " - " +
                                     STRING(par_nrcepav2,"99999,999") + " - " +
                                     par_cdufava2
               /* Conjuge o aval 2 */
               crawepr.nmcjgav2 = CAPS(par_nmdcjav2)
               crawepr.dscfcav2 = par_doccjav2.

               /* Criar os avalistas */
               RUN sistema/generico/procedures/b1wgen9999.p
                              PERSISTENT SET h-b1wgen9999.

               RUN atualiza_tabela_avalistas IN h-b1wgen9999
                                             (INPUT par_cdcooper,
                                              INPUT par_cdoperad,
                                              INPUT par_idorigem,
                                              INPUT "PROP.EMPREST",
                                              INPUT par_nrdconta,
                                              INPUT par_dtmvtolt,
                                              INPUT 1, /* Avalistas */
                                              INPUT par_nrctremp,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_nrctaava,
                                              INPUT par_nmdaval1,
                                              INPUT par_nrcpfav1,
                                              INPUT par_tpdocav1,
                                              INPUT par_dsdocav1,
                                              INPUT par_nmdcjav1,
                                              INPUT par_cpfcjav1,
                                              INPUT par_tdccjav1,
                                              INPUT par_doccjav1,
                                              INPUT par_ende1av1,
                                              INPUT par_ende2av1,
                                              INPUT par_nrfonav1,
                                              INPUT par_emailav1,
                                              INPUT par_nmcidav1,
                                              INPUT par_cdufava1,
                                              INPUT par_nrcepav1,
                                              INPUT par_cdnacio1,
                                              INPUT par_vledvmt1,
                                              INPUT par_vlrenme1,
                                              INPUT par_nrender1,
                                              INPUT par_complen1,
                                              INPUT par_nrcxaps1,
                                              INPUT par_inpesso1,
                                              INPUT par_dtnasct1,
											  INPUT par_vlrecjg1,
                                              INPUT par_nrctaav2,
                                              INPUT par_nmdaval2,
                                              INPUT par_nrcpfav2,
                                              INPUT par_tpdocav2,
                                              INPUT par_dsdocav2,
                                              INPUT par_nmdcjav2,
                                              INPUT par_cpfcjav2,
                                              INPUT par_tdccjav2,
                                              INPUT par_doccjav2,
                                              INPUT par_ende1av2,
                                              INPUT par_ende2av2,
                                              INPUT par_nrfonav2,
                                              INPUT par_emailav2,
                                              INPUT par_nmcidav2,
                                              INPUT par_cdufava2,
                                              INPUT par_nrcepav2,
                                              INPUT par_cdnacio2,
                                              INPUT par_vledvmt2,
                                              INPUT par_vlrenme2,
                                              INPUT par_nrender2,
                                              INPUT par_complen2,
                                              INPUT par_nrcxaps2,
                                              INPUT par_inpesso2,
                                              INPUT par_dtnasct2,
											  INPUT par_vlrecjg2,
                                              INPUT par_dsdbeavt).

               DELETE PROCEDURE h-b1wgen9999.

               /* Para Alterar Somente Avalista e Proposta já aprovada */
			   /* PJ438 Sprint 5 se forcar para perder aprvo. entao pula essa opcao */
               IF par_dsdopcao = "ASA" AND crawepr.insitapr = 1 AND aux_avlalter THEN /*Deve validar em caso de alteração de avalista - BUG 13989 e 14467*/ 
                  DO:
                  
                     VALIDATE crawepr.
               
                     { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                     
                     /* Acionar rotina para atualizar as respostas do Rating  */
                     /* referente a Garantia e Liquidez conforme a quantidade */
                     /* e tipo dos avalistas informados                       */
                     RUN STORED-PROCEDURE pc_atuali_garant_liquid_epr
                      aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                                           INPUT par_nrdconta, /* Conta da Proposta */
                                                           INPUT par_nrctremp, /* Numero da Proposta */
                                                OUTPUT 0, /*nrgarope*/
                                                OUTPUT 0, /*nrliquid*/
                                                          OUTPUT "").          /* Descrição da crítica */
                     
                     /* Fechar o procedimento para buscarmos o resultado */ 
                     CLOSE STORED-PROC pc_atuali_garant_liquid_epr
                         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                     { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                     ASSIGN aux_dscritic = pc_atuali_garant_liquid_epr.pr_dscritic
                                              WHEN pc_atuali_garant_liquid_epr.pr_dscritic <> ?
                            par_nrgarope = pc_atuali_garant_liquid_epr.pr_nrgarope
                                              WHEN pc_atuali_garant_liquid_epr.pr_nrgarope <> ?
                            par_nrliquid = pc_atuali_garant_liquid_epr.pr_nrliquid
                                              WHEN pc_atuali_garant_liquid_epr.pr_nrliquid <> ?.
                                              
                 RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                          INPUT "Atualizado Garantia e Liquidez",
                                          INPUT par_nrgarope,
                                          INPUT par_nrliquid).

                     IF aux_dscritic <> "" THEN
           DO:
                        LEAVE.
                  END.
         END.
                  /* Quando não aprovada, devemos verificar se temos o Motor na Cooperativa */ 
          /*  ELSE  DO:*/ 
               FIND FIRST crapass 
                    WHERE crapass.cdcooper = par_cdcooper   
                      AND crapass.nrdconta = par_nrdconta
                      NO-LOCK NO-ERROR.

                IF   NOT AVAIL crapass THEN
                     DO:
                         aux_cdcritic = 9.
                         LEAVE.
                     END.
                     
               /* Verificar se a Esteira esta em contigencia para a cooperativa*/
               { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
               RUN STORED-PROCEDURE pc_param_sistema aux_handproc = PROC-HANDLE
                 (INPUT "CRED",           /* pr_nmsistem */
                  INPUT par_cdcooper,     /* pr_cdcooper */
                  INPUT "CONTIGENCIA_ESTEIRA_IBRA",  /* pr_cdacesso */
                  OUTPUT ""               /* pr_dsvlrprm */
                  ).

               CLOSE STORED-PROCEDURE pc_param_sistema WHERE PROC-HANDLE = aux_handproc.
               { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }


               ASSIGN aux_contigen = FALSE.
               IF pc_param_sistema.pr_dsvlrprm = "1" then
                  ASSIGN aux_contigen = TRUE.      
               
               /* Verificar se a Proposta possui obrigatoriedade de passar pela analise automatica */ 
               { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
               RUN STORED-PROCEDURE pc_obrigacao_analise_automatic
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                                     INPUT crapass.inpessoa, /* Tipo da Pessoa */
                                                     INPUT crawepr.cdfinemp, /* Código da finalidade de crédito */
                                                     INPUT crawepr.cdlcremp, /* Código da linha de crédito */
                                                    OUTPUT "",           /* Obrigaçao de análise automática (S/N) */
                                                    OUTPUT 0,            /* Código da crítica */
                                                    OUTPUT "").          /* Descrição da crítica */
               
               /* Fechar o procedimento para buscarmos o resultado */ 
               CLOSE STORED-PROC pc_obrigacao_analise_automatic
                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

               { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

               ASSIGN aux_inobriga = pc_obrigacao_analise_automatic.pr_inobriga
                                        WHEN pc_obrigacao_analise_automatic.pr_inobriga <> ?
                      aux_cdcritic = pc_obrigacao_analise_automatic.pr_cdcritic
                                        WHEN pc_obrigacao_analise_automatic.pr_cdcritic <> ?
                      aux_dscritic = pc_obrigacao_analise_automatic.pr_dscritic
                                        WHEN pc_obrigacao_analise_automatic.pr_dscritic <> ?.

               IF aux_cdcritic > 0 OR 
                  aux_dscritic <> '' THEN
                  LEAVE.
               
               /*Indica se deve reiniciar o fluxo de aprovaçao*/
				   /* PJ438 Sprint 5 se deve forcar a perda de aprov */
               IF par_inresapr = 1 THEN
               DO:
               
               /* Incluir checagem para perca da aprovacao devido 
					  mudanca nos avalistas, somente se analise auto obrigatoria 
					  ver regra mais acima de PJ438 Sprint 5 */
                 IF aux_avlalter AND aux_inobriga = "S" THEN
                 DO:                
                   ASSIGN  aux_insitapr = crawepr.insitapr
                           aux_cdopeapr = crawepr.cdopeapr
                           aux_dtaprova = crawepr.dtaprova
                           aux_hraprova = crawepr.hraprova
                           aux_insitest = crawepr.insitest.            
                       
                   FOR crappre FIELDS(cdfinemp) 
                      WHERE crappre.cdcooper = par_cdcooper     
                        AND crappre.inpessoa = crapass.inpessoa  NO-LOCK: END.
                
                   /* Verifica se o emprestimo eh pre-aprovado */
                   IF AVAIL crappre AND crawepr.cdfinemp = crappre.cdfinemp THEN
                      DO:
                          IF NOT VALID-HANDLE(h-b1wgen0188) THEN
                             RUN sistema/generico/procedures/b1wgen0188.p 
                                 PERSISTENT SET h-b1wgen0188.

                          /* Verifica se existe limite disponível */
                          RUN busca_dados IN h-b1wgen0188
                                          (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_nmdatela,
                                           INPUT par_idorigem,
                                           INPUT par_nrdconta,
                                           INPUT par_idseqttl,
                                           INPUT 0,
                                           OUTPUT TABLE tt-dados-cpa,
                                           OUTPUT TABLE tt-erro).

                          FIND tt-dados-cpa NO-LOCK NO-ERROR.
                          IF  AVAIL tt-dados-cpa THEN
                              DO:
                                  ASSIGN aux_idcarga  = tt-dados-cpa.idcarga.
                              END.
                          
                          IF aux_idcarga > 0 THEN
                             DO:
                 RUN proc_gerar_log (INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT "",
                                     INPUT aux_dsorigem,
                                     INPUT "Emprestimo Pré-Aprovado, nao perde aprovacao",
                                     INPUT TRUE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid).
                            
                 RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                          INPUT "contrato",
                                          INPUT "ND",
                                          INPUT par_nrctremp).
                                     
                 RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                          INPUT "Informacao",
                                          INPUT "ND",
                                          INPUT "Essa proposta foi aprovada automaticamente - avalista.").  
                                    
                                ASSIGN crawepr.insitapr =  1
                                       crawepr.cdopeapr = par_cdoperad
                                       crawepr.dtaprova = par_dtmvtolt
                                       crawepr.hraprova = TIME
                        crawepr.insitest = 3
                        par_idpeapro     = 2. /*2 = aprovacao aut.*/
               
                                CREATE tt-msg-confirma.
                                ASSIGN tt-msg-confirma.inconfir = 1
                                       tt-msg-confirma.dsmensag = "Essa proposta foi aprovada automaticamente.".
               
                             END. /* END  IF aux_idcarga > 0 THEN */
                
                      END. /* END IF par_cdfinemp = crappre.cdfinemp */
                   ELSE
                      DO:
                          /* Verificar se a linha aprova automaticamente */
                          FIND FIRST craplcr
                              WHERE craplcr.cdcooper = crawepr.cdcooper AND
                                    craplcr.cdlcremp = crawepr.cdlcremp
                                                            NO-LOCK NO-ERROR.
                          IF AVAIL craplcr AND craplcr.flgdisap THEN
                             DO:
                 RUN proc_gerar_log (INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT "",
                                     INPUT aux_dsorigem,
                                     INPUT "Emprestimo aprovado automaticamente, nao perde aprovacao",
                                     INPUT TRUE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid).
                            
                 RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                          INPUT "contrato",
                                          INPUT "ND",
                                          INPUT par_nrctremp).
                                     
                 RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                          INPUT "Informacao",
                                          INPUT "ND",
                                          INPUT "Essa proposta foi aprovada automaticamente - avalista.").
                 RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                          INPUT "Complemento",
                                          INPUT "ND",
                                          INPUT "Linha de credito com aprovacao automatica").                                         
                                ASSIGN crawepr.insitapr = 1
                                       crawepr.cdopeapr = par_cdoperad
                                       crawepr.dtaprova = par_dtmvtolt
                                       crawepr.hraprova = TIME
                        crawepr.insitest = 3
                        par_idpeapro     = 2. /*2 = aprovacao aut.*/

                                CREATE tt-msg-confirma.
                                ASSIGN tt-msg-confirma.inconfir = 1
                                       tt-msg-confirma.dsmensag =
                                                  "Essa proposta foi aprovada automaticamente.".
                             END. /* IF AVAIL craplcr AND craplcr.flgdisap THEN */
                             
                          ELSE            
                             DO:
                 IF par_idpeapro = 0 AND crawepr.insitapr = 1 THEN /*Pela Regras anteriores ainda nao perdeu*/
                               DO:
                   IF aux_perdeuaprv = "S" THEN
                 DO:                   
                  /* Se nao estiver em contigencia e a proposta estava na Esteira 
                     If abaixo:
                     Não estiver em contigencia
                     E
                     Situação da proposta na esteira esteja:
                     -> Enviada p/ Analise Man.         
                     OU
                     -> Situacao como Nao Enviada E não tenha Hora do ultimo envio para Analise Manual na Esteira e Não tenha tido retorno da esteira
                     OU
                     -> Situação como Analise Finalizada e Operador que aprovou seja ESTEIRA
                     OU
                     -> Situação esteja Expirado                
                  */
                  IF NOT aux_contigen 
                     AND (crawepr.insitest = 2 OR 
                         ( crawepr.insitest = 0 AND crawepr.hrenvest > 0 AND (crawepr.dsprotoc = ? OR crawepr.dsprotoc = " " ) ) OR 
                         ( crawepr.insitest = 3 AND UPPER(crawepr.cdopeapr) = 'ESTEIRA' ) OR 
                         ( crawepr.insitest = 4 ) ) THEN 
                               DO:
                                  ASSIGN aux_interrup = true. /* Interromper na Esteira*/
                               END.
                             
                   RUN proc_gerar_log (INPUT par_cdcooper,
                                       INPUT par_cdoperad,
                                       INPUT "",
                                       INPUT aux_dsorigem,
                                       INPUT "Proposta: " + STRING(crawepr.nrctremp) + " avalista alterado e valor maior que o parametrizado, perde aprovacao",
                                       INPUT TRUE,
                                       INPUT par_idseqttl,
                                       INPUT par_nmdatela,
                                       INPUT par_nrdconta,
                                      OUTPUT aux_nrdrowid).
                                                
                   RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                            INPUT "Contrato",
                                            INPUT "ND",
                                            INPUT par_nrctremp).
                                 /* Perder a aprovaçao */
                               ASSIGN crawepr.insitapr = 0
                                      crawepr.cdopeapr = ""
                                      crawepr.dtaprova = ?
                                      crawepr.hraprova = 0
                          crawepr.insitest = 0
                          par_idpeapro     = 1. /*Perde aprovacao para as demais regras*/

                               CREATE tt-msg-confirma.
                               ASSIGN tt-msg-confirma.inconfir = 1
                               tt-msg-confirma.dsmensag = IF aux_contigen THEN
                                                            "Avalistas Alterados - A proposta deve ser" +
                                                            " aprovada na tela CMAPRV"
                                                          ELSE
                                                            "Avalistas Alterados - A proposta devera ser " +
                                                            " enviada para Analise de Credito".      
                               
                                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Perdeu Aprovacao Ou Nao aprovado Automaticamente - Aval",
                                            INPUT "ND",
                                     INPUT aux_perdeuaprv).															
                             END.
                      END. 
                 ELSE
                 DO:
                   IF par_idpeapro = 0 THEN
                   DO:
                     /* Se nao estiver em contigencia e a proposta estava na Esteira 
                      If abaixo:
                      Não estiver em contigencia
                      E
                      Situação da proposta na esteira esteja:
                      -> Enviada p/ Analise Man.         
                      OU
                      -> Situacao como Nao Enviada E não tenha Hora do ultimo envio para Analise Manual na Esteira e Não tenha tido retorno da esteira
                      OU
                      -> Situação como Analise Finalizada e Operador que aprovou seja ESTEIRA
                      OU
                      -> Situação esteja Expirado                
                     */
                     IF NOT aux_contigen 
                       AND (crawepr.insitest = 2 OR 
                           ( crawepr.insitest = 0 AND crawepr.hrenvest > 0 AND (crawepr.dsprotoc = ? OR crawepr.dsprotoc = " " ) ) OR 
                           ( crawepr.insitest = 3 AND UPPER(crawepr.cdopeapr) = 'ESTEIRA' ) OR 
                           ( crawepr.insitest = 4 ) ) THEN 
                     DO:
                       ASSIGN aux_interrup = true. /* Interromper na Esteira*/
                 END.  
                         
                     RUN proc_gerar_log (INPUT par_cdcooper,
                                         INPUT par_cdoperad,
                                         INPUT "",
                                         INPUT aux_dsorigem,
                                         INPUT "Proposta: " + STRING(crawepr.nrctremp) + 
                                               " avalista alterado com situacao diferente de aprovado, perde aprovacao",
                                         INPUT TRUE,
                                         INPUT par_idseqttl,
                                         INPUT par_nmdatela,
                                         INPUT par_nrdconta,
                                        OUTPUT aux_nrdrowid).
                                
                     RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                              INPUT "Contrato",
                                              INPUT "ND",
                                              INPUT par_nrctremp).
                             /* Perder a aprovaçao */
                     ASSIGN crawepr.insitapr = 0
                            crawepr.cdopeapr = ""
                            crawepr.dtaprova = ?
                            crawepr.hraprova = 0
                            crawepr.insitest = 0
                            par_idpeapro     = 1. /*Perde aprovacao para as demais regras*/
                               
                     CREATE tt-msg-confirma.
                     ASSIGN tt-msg-confirma.inconfir = 1
                            tt-msg-confirma.dsmensag = IF aux_contigen THEN
                                                  "Avalistas Alterados - A proposta deve ser" +
                                                  " aprovada na tela CMAPRV"
                                                ELSE
                                                  "Avalistas Alterados - A proposta devera ser " +
                                                  " enviada para Analise de Credito".
              END.     
                             END.
                             END.
                      END. 
                 END.  
              END.     
        /*END.*/ /* FIM IF par_inresapr*/
        LEAVE.

    END. /* DO WHILE TRUE TRANSACTION */

                                /* Soh devemos interromper a proposta na Esteira */
                                IF aux_interrup THEN
    DO:
      
      FIND FIRST crapope  
       WHERE crapope.cdcooper = par_cdcooper             
         AND crapope.cdoperad = par_cdoperad
             NO-LOCK NO-ERROR.
      
      RUN sistema/generico/procedures/b1wgen0195.p
                       PERSISTENT SET h-b1wgen0195.
               
                                  /* Enviar Interrupção na Esteira */
      RUN Enviar_proposta_esteira IN h-b1wgen0195        
                        ( INPUT par_cdcooper,
                          INPUT crapope.cdpactra,
                          INPUT par_nrdcaixa,
                          INPUT par_nmdatela,
                          INPUT par_cdoperad,
                          INPUT par_idorigem,
                          INPUT par_nrdconta,
                          INPUT par_dtmvtolt,
                          INPUT par_dtmvtolt,
                          INPUT par_nrctremp, /* nrctremp */
                          INPUT 0,            /* nrctremp_novo */
                          INPUT "",           /* dsiduser */
                          INPUT 0,            /* flreiflx */
                                                      INPUT "P",          /* tpenvest */
                         OUTPUT aux_dsmensag,
                         OUTPUT aux_cdcritic, 
                         OUTPUT aux_dscritic).
      
      DELETE OBJECT h-b1wgen0195.
       
      /* Ignorar erro de "%Proposta nao encontrada" */ 
      IF RETURN-VALUE = "NOK" AND
          NOT lower(aux_dscritic) MATCHES "*proposta nao encontrada*" AND
          NOT lower(aux_dscritic) MATCHES "*proposta nao permite interromper o fluxo*" AND
          NOT lower(aux_dscritic) MATCHES "*produto cdc nao integrado*" THEN
          DO:
              IF aux_cdcritic = 0 AND 
                 aux_dscritic = "" THEN
              DO:
                ASSIGN aux_dscritic = "Nao foi possivel enviar cancelamento da " +
                                      "proposta para Analise de Credito.".
              END.
          END.
      ELSE
          DO:
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "".
          END.
    END.
    
    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    /* Chamar apos a transacao pois depende de valores anteriores no Oracle */
    /* Os erros desta proc, sao trazidos somente como mensagens */
    /*IF   par_dsdopcao = "ASA"  AND aux_avlalter THEN*/ /* Alterar Somente Avalistas */
    IF aux_avlalter THEN /* Alterar Somente Avalistas */      
         DO:
              RUN sistema/generico/procedures/b1wgen0191.p
                             PERSISTENT SET h-b1wgen0191.

              RUN Verifica_Consulta_Biro IN h-b1wgen0191 
                                              (INPUT par_cdcooper,
                                               INPUT par_nrdconta,
                                               INPUT 1, /* inprodut*/
                                               INPUT par_nrctremp,
                                               INPUT par_cdoperad,
                                               INPUT "A",
                                        INPUT-OUTPUT TABLE tt-msg-confirma,
                                              OUTPUT par_flmudfai).

              DELETE PROCEDURE h-b1wgen0191.
         END.

    /*IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).*/
    
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE leitura_lem:

    DEF INPUT        PARAM par_cdcooper AS INTE         NO-UNDO.
    DEF INPUT        PARAM par_cdprogra AS CHAR         NO-UNDO.
    DEF INPUT        PARAM par_nrdconta AS INTE         NO-UNDO.
    DEF INPUT        PARAM par_nrctremp AS INTE         NO-UNDO.
    DEF INPUT        PARAM par_dtcalcul AS DATE         NO-UNDO.
    DEF INPUT        PARAM par_qtprecal AS DECI         NO-UNDO.

    DEF INPUT-OUTPUT PARAM par_diapagto AS INTE         NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_txdjuros AS DECI         NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_qtprepag AS INTE         NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlprepag AS DECI         NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vljurmes AS DECI         NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vljuracu AS DECI         NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlsdeved AS DECI         NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_dtultpag AS DATE         NO-UNDO.

    DEF OUTPUT       PARAM par_qtmesdec AS INTE         NO-UNDO.
    DEF OUTPUT       PARAM par_vlpreapg AS DECI         NO-UNDO.
    DEF OUTPUT       PARAM par_cdcritic AS INTE         NO-UNDO.
    DEF OUTPUT       PARAM par_dscritic AS CHAR         NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_leitura_lem_car
      aux_handproc = PROC-HANDLE NO-ERROR (INPUT        par_cdcooper, /* Cooperativa conectada */
                                           INPUT        par_cdprogra, /* Codigo do programa corrente */
                                           INPUT        par_nrdconta, /* Conta do associado */
                                           INPUT        par_nrctremp, /* Numero Contrato */
                                           INPUT        par_dtcalcul, /* Data para calculo do emprestimo */
                                           INPUT-OUTPUT par_diapagto, /* Dia para pagamento */
                                           INPUT-OUTPUT par_txdjuros, /* Taxa de juros aplicada */
                                           INPUT        par_qtprecal, /* Quantidade de prestacoes calculadas ate momento */
                                           INPUT-OUTPUT par_qtprepag, /* Quantidade de prestacoes paga ate momento */
                                           INPUT-OUTPUT par_vlprepag, /* Valor acumulado pago no mes */
                                           INPUT-OUTPUT par_vljurmes, /* Juros no mes corrente */
                                           INPUT-OUTPUT par_vljuracu, /* Juros acumulados total */
                                           INPUT-OUTPUT par_vlsdeved, /* Saldo devedor acumulado */
                                           INPUT-OUTPUT par_dtultpag, /* Ultimo dia de pagamento das prestacoes */
                                           OUTPUT 0,                  /* Quantidade de meses decorridos */
                                           OUTPUT 0,                  /* Valor a pagar */
                                           OUTPUT 0,                  /* Codigo da critica  */
                                           OUTPUT "").                /* Descricao da critica */
                                    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_leitura_lem_car
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN par_cdcritic = 0
           par_dscritic = ""
           par_cdcritic = pc_leitura_lem_car.pr_cdcritic
                             WHEN pc_leitura_lem_car.pr_cdcritic <> ?
           par_dscritic = pc_leitura_lem_car.pr_dscritic
                             WHEN pc_leitura_lem_car.pr_dscritic <> ?
           par_diapagto = pc_leitura_lem_car.pr_diapagto
                             WHEN pc_leitura_lem_car.pr_diapagto <> ?
           par_txdjuros = pc_leitura_lem_car.pr_txdjuros
                             WHEN pc_leitura_lem_car.pr_txdjuros <> ?
           par_qtprepag = pc_leitura_lem_car.pr_qtprepag
                             WHEN pc_leitura_lem_car.pr_qtprepag <> ?
           par_vlprepag = pc_leitura_lem_car.pr_vlprepag
                             WHEN pc_leitura_lem_car.pr_vlprepag <> ?
           par_vljurmes = pc_leitura_lem_car.pr_vljurmes
                             WHEN pc_leitura_lem_car.pr_vljurmes <> ?
           par_vljuracu = pc_leitura_lem_car.pr_vljuracu
                             WHEN pc_leitura_lem_car.pr_vljuracu <> ?
           par_vlsdeved = pc_leitura_lem_car.pr_vlsdeved
                             WHEN pc_leitura_lem_car.pr_vlsdeved <> ?
           par_dtultpag = pc_leitura_lem_car.pr_dtultpag
                             WHEN pc_leitura_lem_car.pr_dtultpag <> ?
           par_qtmesdec = pc_leitura_lem_car.pr_qtmesdec
                             WHEN pc_leitura_lem_car.pr_qtmesdec <> ?
           par_vlpreapg = pc_leitura_lem_car.pr_vlpreapg
                             WHEN pc_leitura_lem_car.pr_vlpreapg <> ?.

    IF par_cdcritic <> 0 OR par_dscritic <> "" THEN
       RETURN "NOK".

    RETURN "OK".
    
END PROCEDURE.


PROCEDURE buscar_liquidacoes_contrato:
    DEF INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS DECI                             NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                             NO-UNDO.    
    DEF OUTPUT PARAM par_dsctrliq AS CHAR                            NO-UNDO. 
    DEF VAR i AS INTE NO-UNDO.
    DEF BUFFER crabwepr FOR crawepr.
    
    ASSIGN par_dsctrliq = "".
    
    FIND crabwepr WHERE crabwepr.cdcooper = par_cdcooper AND
                        crabwepr.nrdconta = par_nrdconta AND
                        crabwepr.nrctremp = par_nrctremp NO-LOCK NO-ERROR.
    IF AVAIL crabwepr THEN DO:
      DO i = 1 TO 10:
         IF  crabwepr.nrctrliq[i] > 0  THEN DO:
            par_dsctrliq = par_dsctrliq + (IF par_dsctrliq = "" THEN TRIM(STRING(crabwepr.nrctrliq[i], "z,zzz,zz9")) ELSE "," + TRIM(STRING(crabwepr.nrctrliq[i], "z,zzz,zz9"))).
         END.
      END.
    END.
    
END PROCEDURE.