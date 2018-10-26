/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +----------------------------------------+--------------------------------------------------+
  | Rotina Progress                        | Rotina Oracle PLSQL                              |
  +----------------------------------------+--------------------------------------------------+
  | b1wgen0091.p                           | INSS0001                                         |
  | gera_credito_em_conta                  | INSS0001.pc_gera_credito_em_conta                |
  | transfere_beneficio                    | INSS0001.pc_transfere_beneficio                  |
  | beneficios_inss_solicitacao_creditos   | INSS0001.pc_benef_inss_solic_cred                |
  | beneficios_inss_processa_pagamentos    | INSS0001.pc_benef_inss_proces_pagto              |
  | gera_cabecalho_xml                     | INSS0001.pc_gera_cabecalho_xml                   |
  | beneficios_inss_verifica_retorno_webservice | INSS0001.pc_benef_inss_ret_webservc         |
  | criptografa_move_arquivo               | INSS0001.pc_criptografa_move_arquiv              |     
  | beneficios_inss_xml_divergencias_pagto | INSS0001.pc_benef_inss_xml_div_pgto              |
  | beneficios_inss_gera_credito           | INSS0001.pc_benef_inss_gera_credito              |   
  | gera_relatorio_rejeicoes               | INSS0001.pc_gera_relatorio_rejeic                |            
  | beneficios_inss_envia_req_via_mq       | INSS0001.pc_benef_inss_envia_req_mq              |
  | beneficios_inss_xml_confirma_pagamento | INSS0001.pc_benef_inss_confir_pagto              |
  | solicita_relatorio_beneficios_pagos    | INSS0001.pc_solic_rel_benef_pago                 |
  | solicita_relatorio_beneficios_pagar    | INSS0001.pc_solic_rel_benef_pagar                |
  | gera_cabecalho_soap                    | INSS0001.pc_gera_cabecalho_soap                  |
  | efetua_requisicao_soap                 | INSS0001.pc_efetua_requisicao_soap               |
  | obtem_fault_packet                     | INSS0001.pc_obtem_fault_packet                   |
  | elimina_arquivos_requisicao            | INSS0001.pc_elimina_arquivos_requis              |
  | retorna_linha_log                      | INSS0001.pc_retorna_linha_log                    |
  | busca_crapttl                          | INSS0001.pc_busca_crapttl                        |
  | busca_crapdbi                          | INSS0001.pc_busca_crapdbi                        |
  | busca_cdorgins                         | INSS0001.pc_busca_cdorgins                       |
  | gera_termo_troca_domicilio             | INSS0001.pc_gera_termo_troca_domic               |
  | gera_termo_troca_conta_corrente        | INSS0001.pc_gera_termo_troca_conta               |
  | gera_termo_comprovacao_vida            | INSS0001.pc_gera_termo_cpvcao_vida               |
  | gera_arquivo_demonstrativo             | INSS0001.pc_gera_arq_demonstrativo               |
  | solicita_troca_domicilio               | INSS0001.pc_solic_troca_domicilio                |
  | solicita_demonstrativo                 | INSS0001.pc_solicita_demonstrativo               |
  | solicita_comprovacao_vida              | INSS0001.pc_solic_comprovacao_vida               |
  | relatorio_beneficios_rejeitados        | INSS0001.pc_relat_benef_rejeitados               |
  | solicita_troca_op_conta_corrente_entre_coop | INSS0001.pc_solic_troca_op_cc_coop          |
  | solicita_troca_op_conta_corrente            | INSS0001.pc_solic_troca_op_cc               |
  | solicita_alteracao_cadastral_beneficiario   | INSS0001.pc_solic_alt_cadast_benef          |
  | solicita_consulta_beneficiario         | INSS0001.pc_solic_consulta_benef                 |
  +----------------------------------------+--------------------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*.............................................................................

   Programa: b1wgen0091.p                  
   Autora  : André - DB1
   Data    : 16/05/2011                        Ultima atualizacao: 12/06/2018
    
   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : BO - Alteracao de Domicilio Bancario

   Alteracoes:  13/09/2011 - Adicionadas procedures para processamento de 
                             arquivos e informacoes para Previdencia 
                             (GATI - Eder). 
                             
                30/09/2011 - Não carregar cooperativa 3 na gera_arquivos_inss
                             (GATI - Vitor).
                             
                04/10/2011 - Na verifica_arquivos_demonstrativo_inss buscar no
                             diretório fixo da CECRED
                             Na processa_arquivos_demonstrativo salvar também
                             no diretório fixo da CECRED
                05/10/2011 - Na validação do diretório verificar apenas 1 
                             arquivo e não todos (Vitor - GATI)
                             
                24/10/2011 - Adicionado a include b1cabrelvar.i para ser usada
                             pela b1cabrel080.i ( Rogerius Militão - DB1 )             
                             
                23/12/2011 - Ajustes referente ao Uniprope e criado as 
                             procedures:
                             - gera_credito_em_conta
                             - busca_credito_em_conta
                             (Adriano).            
                             
                21/03/2012 - Ajuste na procedure processa_arquivos_demonstrativo
                             para descartar os arquivos que ja tenham sido 
                             processados (Adriano).
                             
                22/03/2012 - Ajuste na procedure envia_arquivos_inss para
                             passar o crapcop.cdagebcb de acordo com a 
                             cooperativa do arquivo para o upload.sh (Adriano).
                                          
                23/03/2012 - Alimentado as variaveis aux_flgderro,aux_arqcerro
                             para FALSE na procedure processa_arquivos_inss
                             (Adriano).  
                             
                29/03/2012 - Zerado as variaveis aux_nrseqreg, aux_nrseqlot na
                             procedure gera_arquivos_inss e ajustado a 
                             procedure envia_arquivos_inss para corrigir
                             o problema de lentidao no envio (Adriano).  
                             
                03/04/2012 - Ajuste na procedure envia_arquivos_inss para 
                             corrigir o problema de lentidao no envio (Adriano).                         
                             
                18/06/2012 - Alteracao na leitura da craptco (David Kruger).  
                
                29/06/2012 - Alterado o "FIRST" para "FIRST-OF" na procedure    
                             gera_arquivos_inss quando for tratado o 
                             lote 31 (Adriano).
                
                22/10/2012 - Validacoes de CPFs no arquivo de 
                             credito(craplbi) Tiago.                                     
                             
                07/12/2012 - Criado a procedure transfere_beneficio (Tiago).
                
                21/12/2012 - Ajustes referente ao Projeto Prova de Vida 
                            (Adriano).
                             
                27/12/2012 - Alterado procedure pi_processa_arquivo_inss para 
                             acumular aux_qtdbloqu quando registro nao estiver
                             na craplbi  (Daniel).
                      
                24/01/2013 - Efetuado leitura na tt-crapcbi utilizando todos os
                                                         campos do indice para sanar problemas com
                                                         performance do processo (Rodrigo).
                             
                29/01/2013 - Alterações nos campos do Rel.473 (Lucas).
                
                25/03/2013 - Ajustes realizados:
                             - Na procedure pi_grava_registros_inss para   
                               que, no momento da atualizacao "buffer-copy" da 
                               crapcbi, nao atualizar os campos dtenvipv, 
                               dtcompvi, indresvi;
                             - Na funcao verificacao_bloqueio para que, quando
                               haja mais de um beneficio com bloqueio, seja 
                               retornado o tpbloque corretamente (Adriano).
                               
                17/05/2013 - Criado a procedure busca-benefic-compvi (Adriano).
                
                20/05/2013 - Ajuste para a criacao das procedures:
                             - retorna_linha_log
                             - gera_cabecalho_soap
                             - efetua_requisicao_soap
                             - obtem_fault_packet
                             - elimina_arquivos_requisicao
                             - cria_objetos_xml
                             - elimina_objetos_xml
                             - cria_objetos_soap
                             - elimina_objetos_soap
                             - solicita_consulta_beneficiario
                             - solicita_alteracao_cadastral_beneficiario
                             - solicita_troca_op_conta_corrente
                             - solicita_troca_op_conta_corrente_entre_coop
                             - solicita_comprovacao_vida
                             - solicita_demonstrativo
                             - solicita_relatorio_beneficios_pagos
                             - solicita_relatorio_beneficios_pagar
                             - relatorio_beneficios_rejeitados
                             - solicita_troca_domicilio
                             - busca_crapttl
                             - busca_cdorgins
                             - busca_crapdbi
                             - gera_arquivo_demonstrativo
                             - gera_termo_troca_domicilio
                             - gera_termo_troca_conta_corrente
                             - gera_termo_comprovacao_vida
                             (Adriano)
                
                13/11/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (Guilherme Gielow)
                             
                03/01/2014 - Criticas de busca de crapage alteradas de 15 para 
                             962 (Carlos)
                             
                03/02/2014 - No tratamento de bloqueios, procedure 
                             pi_processa_arquivo_inss, ajustado para alimentar
                             os campos cdbloque, tporiblq conforme versao 6.52 
                             do INSS (Adriano).
                             
                05/03/2014 - Incluso VALIDATE (Daniel).
              
              
                05/04/2014 - Ajustes nas procedures abaixo pois estava
                             deixando registro da crapcbi alocado.
                             - gera_arquivo_comprovacao_vida 
                             - comprova_vida (alimentado o dtenvipv com ?)
                             Ajuste na terceira logica e incluido uma quarta,
                             na procedure bloqueio (Adriano).
                             
                29/04/2014 - Realizado os devidos ajustes para que na procedure
                             elimina_arquivos_requisicao, ao inves 
                             de excluir o arquivo de retorno do SICREDI, 
                             o mesmo, seja criptografado e enviado ao diretorio 
                             conforme recebido por parametro (Adriano).             
                             
                12/05/2014 - Criando as procedures validarGPS e arrecadarGPS 
                             (Carlos)
                             
                27/05/2014 - Ajustes realizados:
                             - Na procedure beneficios_inss_processa_pagamentos,
                               as mensagens rejeitadas serao movidas para o
                               salvar com o acrescimo do sufixo "REJEI" em seu 
                               nome, diferenciando-se das mensagens processadas
                               com sucesso;
                             - Retirado o envia-arquivo-web da procedure 
                               relatorio_beneficios_rejeitados
                             (Adriano).
                             
                30/05/2014 - Alterado na procedure
                             beneficios_inss_processa_pagamentos para validar
                             o CPF do beneficiario pela ttl e nao pela ass.
                             (Sem n. de chamado) - (Fabricio)
                           - Alterado tambem para gerar o relatorio de
                             rejeicoes (gera_relatorio_rejeicoes) com extensao
                             '.lst'; antes estava '.ex', fazendo com que
                             o relatorio nao fosse disponibilizado na Intranet,
                             pois, o script CriaPDF.sh espera uma extensao
                             '.lst'. (Chamado 163261) - (Fabricio)
                             
                10/06/2014 - Alterado atribuicao do campo nrdocmto no CREATE
                             da craplcm para o sequencial do lote, na procedure 
                             beneficios_inss_gera_credito; motivo: um 
                             beneficiario pode receber mais do que um credito
                             de beneficio no mesmo dia. 
                             (Chamado 165424) - (Fabricio)
                             
                09/07/2014 - Alterado na procedure 
                             beneficios_inss_processa_pagamentos a validacao
                             da conta do cooperado; passado a verificar o 
                             dtelimin = ? e nao mais o dtdemiss.
                             Motivo: Por alguns motivos, existem cooperados
                                     que trabalham ainda com a cooperativa mas,
                                     no seu cadastro, possuem uma data de 
                                     demissao.
                           - Alterado descricao da critica quando cod.
                             divergencia = 2; de: POUPANCA INVALIDA para:
                             CONTA ENCERRADA 
                             (procedure beneficios_inss_xml_divergencias_pagto).
                             (Chamado 170273, 166445) - (Fabricio)
                             
                28/07/2014 - Ajustes na procedure beneficios_inss_gera_credito:
                             - Utilizar o nrdolote = 10132
                             - Alterado FIND FIRST para FIND na leitura da
                               craplot
                             (Adriano).     
                             
                07/08/2014 - Realizado ajuste na procedure abaixo para utilizar
                             o TODAY no envio da mensagem de solicitacao dos
                             creditos ao SICREDI
                             - beneficios_inss_solicitacao_creditos
                             (Adriano).                                     
                             
                27/08/2014 - Ajustes realizados:
                             - Ajustes nas procedures pertinentes ao
                               pagamento de GPS devido a homologacao com o
                               SICREDI 
                             (Adriano).
                               
                24/09/2014 - Ajuste realiados:
                            - Limitar o nome do endereco, a ser enviado
                              no xml de request, em no maximo 40 caracters
                              nas rotinas de pagamento de beneficios
                            - Alterado retorno de erro da obtem_fault_packet
                            (Adriano) Softdesk 202231.
                             
                24/10/2014 - Ajuste nas procedures abaixo para tratar 
                             contas migradas:
                             - solicita_consulta_beneficiario
                             - beneficios_inss_solicitacao_creditos
                             (Adriano)             
                             
                04/11/2014 - Ajuste nas procedures abaixo referente a 
                             incorporacao da concredi:
                             - pi_valida_registros: Rejeitar os
                               beneficios bancoob  aa cooperativa concredi
                             - pi_gera_retorno                       
                             Ajuste nas procedures abaixo referente aos
                             servicos INSS - SICREDI:
                             - solicita_troca_op_conta_corrente: Ajuste no
                               tratamento de erro
                             - solicita_troca_op_conta_corrente_entre_coop:
                               Ajuste no tramento de erro
                             (Adriano).                                      
                             
                25/11/2014 - Ajuste nas procedures abaixo referente a 
                             incorporacao da concredi:
                             - beneficios_inss_processa_pagamentos
                             - solicita_consulta_beneficiario
                             (Adriano). 
                             
                28/11/2014 - Devido ao SICREDI permitir apenas PAs com no 
                             maximo 2 digitos, na rotina abaixo, foi relizado 
                             um tratamento para encontrar o PA a partir do OP,
                             recebido no XML do cooperado em questao, pois
                             o SICREDI cadastra um PA ficticio aos beneficiarios
                             que estao em um PA com mais de 2 digitos.
                             - beneficios_inss_processa_pagamentos
                            (Adriano).
                            
                29/11/2014 - Ajuste nas procedures abaixo para enviar o 
                             "NumeroUnidadeAtendimento" fixo como "2" 
                             para contornar o problema de PAs com mais
                             de 2 digitos
                             - beneficios_inss_xml_divergencias_pagto
                             - beneficios_inss_xml_confirma_pagamento
                             (Adriano).
                 
               01/12/2014 - Ajuste na procedure abaixo para pegar o 
                            cdorgins corretamente:
                            - beneficios_inss_processa_pagamentos              
                            (Adriano).
                            
               10/12/2014 - Realizado os ajustes abaixo:
                            - Na procedure beneficios_inss_processa_pagamentos,
                              tratar corretamente os casos em que o SICREDI 
                              envia cooperativa divergente a conta (Devido
                              a migracao da concredi):
                            - Nas procedures abaixo, alterado para utilizar
                              o b-crapcop2
                               > beneficios_inss_xml_divergencias_pagto
                               > beneficios_inss_xml_confirma_pagamento
                               > beneficios_inss_envia_req_via_mq
                            (Adriano).
                            
               18/12/2014 - Ajuste para atender a premissa do SICREDI, 
                            utilizacao de PA com no maximo dois digitos -
                            SD 228692  (Adriano).
                            
               23/03/2015 - Decorrente a conversao das rotinas INSS - SICREDI
                            para PLSQL, foram removidas as procedures:
                            - solicita_alteracao_cadastral_beneficiario
                            - solicita_troca_op_conta_corrente_entre_coop
                            - solicita_comprovacao_vida
                            - solicita_demonstrativo
                            - solicita_relatorio_beneficios_pagos
                            - solicita_relatorio_beneficios_pagar
                            - relatorio_beneficios_rejeitados
                            - solicita_troca_domicilio
                            - busca_crapttl
                            - busca_cdorgins
                            - gera_arquivo_demonstrativo
                            - gera_termo_troca_domicilio
                            - gera_termo_troca_conta_corrente
                            - gera_termo_comprovacao_vida
                            - beneficios_inss_verifica_retorno_webservice
                            - beneficios_inss_processa_pagamentos
                            - beneficios_inss_xml_divergencias_pagto
                            - beneficios_inss_xml_confirma_pagamento
                            - beneficios_inss_envia_req_via_mq
                            - beneficios_inss_gera_credito
                            - gera_cabecalho_xml
                            - gera_relatorio_rejeicoes
                            - retorna_linha_log
                            - solicita_troca_op_conta_corrente
                            - solicita_consulta_beneficiario
                            - beneficios_inss_solicitacao_creditos
                            (Adriano).
             
               06/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)

			   26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).
                            
               12/06/2018 - P450 - Chamada da rotina para consistir lançamento em conta corrente(LANC0001) na tabela CRAPLCM  - José Carvalho(AMcom)
                            
 ............................................................................*/

/*................................ DEFINICOES ...............................*/ 

{ sistema/generico/includes/b1wgen0091tt.i } 
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1cabrelvar.i }
{dbo/bo-erro1.i}
{ sistema/generico/includes/b1wgen0200tt.i }

DEF STREAM str_1.
DEF STREAM str_2.
DEF STREAM str_3.
DEF STREAM str_4.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                         NO-UNDO.

DEF VAR aux_hrfimpag AS INTE                                           NO-UNDO.
DEF VAR aux_mnfimpag AS INTE                                           NO-UNDO.
DEF VAR aux_nmarqtmp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_arqlista AS CHAR                                           NO-UNDO.
DEF VAR aux_nrseqmsg AS INTE                                           NO-UNDO.
DEF VAR aux_nmarqext AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdmeses AS CHAR     EXTENT 12
                                 INIT["1","2","3","4","5","6",
                                      "7","8","9","O","N","D"]         NO-UNDO.
DEF VAR aux_setlinha AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqger AS CHAR                                           NO-UNDO.
DEF VAR aux_cdagefim AS INTE                                           NO-UNDO.
DEF VAR aux_fmpagben AS INTE                                           NO-UNDO.
DEF VAR aux_nrseqlot AS INTE                                           NO-UNDO.
DEF VAR aux_nrseqreg AS INTE                                           NO-UNDO.
DEF VAR aux_qttotreg AS INTE                                           NO-UNDO.
DEF VAR aux_vltotreg AS DECI                                           NO-UNDO.
DEF VAR aux_tamarqui AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqdat AS CHAR                                           NO-UNDO.
DEF VAR aux_nomedarq AS CHAR                                           NO-UNDO.
DEF VAR aux_cdagenci AS CHAR                                           NO-UNDO.
DEF VAR rel_nomedarq AS CHAR                                           NO-UNDO.
DEF VAR aux_nmextarq AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdoextr AS INTE                                           NO-UNDO.
DEF VAR aux_cdtplote AS INTE                                           NO-UNDO.
DEF VAR aux_iddobanc AS INTE                                           NO-UNDO.
DEF VAR aux_dtgralot AS DATE     FORMAT "99/99/9999"                   NO-UNDO.
DEF VAR aux_dtcomext AS CHAR                                           NO-UNDO.
DEF VAR aux_nmemiten AS CHAR     FORMAT "x(40)"                        NO-UNDO.
DEF VAR aux_nrcnpjem AS DECI                                           NO-UNDO.
DEF VAR aux_filler1  AS INTE                                           NO-UNDO.
DEF VAR aux_nrctrltr AS INTE                                           NO-UNDO.
DEF VAR aux_dsclinha AS CHAR     FORMAT "x(40)" EXTENT 3               NO-UNDO.
DEF VAR aux_filler2  AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS CHAR                                           NO-UNDO.
DEF VAR aux_qttotcre AS INTE     FORMAT "zzzz9"                        NO-UNDO.
DEF VAR aux_vltotcre AS DECI     FORMAT "zzz,zz9.99"                   NO-UNDO.
DEF VAR aux_qttotblq AS INTE     FORMAT "zzzz9"                        NO-UNDO.
DEF VAR aux_vltotblq AS DECI     FORMAT "zzz,zz9.99"                   NO-UNDO.
DEF VAR aux_qttotdbl AS INTE     FORMAT "zzzz9"                        NO-UNDO.
DEF VAR aux_vltotdbl AS DECI     FORMAT "zzz,zz9.99"                   NO-UNDO.
DEF VAR aux_tpmepgto AS INTE                                           NO-UNDO.
DEF VAR aux_qtdcredi AS INTE                                           NO-UNDO.
DEF VAR aux_vldcredi AS DECI                                           NO-UNDO.
DEF VAR aux_flgderro AS LOGI     INIT NO                               NO-UNDO.
DEF VAR aux_nrdcont2 AS INTE                                           NO-UNDO.
DEF VAR h_b1crap85   AS HANDLE                                         NO-UNDO.
DEF VAR aux_vlliquid AS DECI                                           NO-UNDO.
DEF VAR aux_vldoipmf AS DECI                                           NO-UNDO.
DEF VAR aux_cfrvipmf AS DECI                                           NO-UNDO.
DEF VAR aux_qtdcadas AS INTE                                           NO-UNDO.
DEF VAR aux_dtnasben AS CHAR                                           NO-UNDO.
DEF VAR aux_nrrmsblq AS INTE                                           NO-UNDO.
DEF VAR aux_qtdbloqu AS INTE                                           NO-UNDO.
DEF VAR aux_nrrecben LIKE craplbi.nrrecben                             NO-UNDO.
DEF VAR aux_nrbenefi LIKE craplbi.nrbenefi                             NO-UNDO.
DEF VAR aux_dtfimper LIKE craplbi.dtfimper                             NO-UNDO.
DEF VAR aux_dtiniper LIKE craplbi.dtiniper                             NO-UNDO.
DEF VAR aux_nrseqcre LIKE craplbi.nrseqcre                             NO-UNDO.
DEF VAR aux_qtdprocu AS INTE                                           NO-UNDO.
DEF VAR aux_arqcerro AS LOGICAL  INIT NO                               NO-UNDO.


/** Objetos Resposta XML **/                                         
DEF VAR hDoc          AS HANDLE                                        NO-UNDO.
DEF VAR hRoot         AS HANDLE                                        NO-UNDO.
DEF VAR hNode         AS HANDLE                                        NO-UNDO.
DEF VAR hNode2        AS HANDLE                                        NO-UNDO.
DEF VAR hSubNode      AS HANDLE                                        NO-UNDO.
DEF VAR hSubNode2     AS HANDLE                                        NO-UNDO.
DEF VAR hNameTag      AS HANDLE                                        NO-UNDO.
DEF VAR hNameTag2     AS HANDLE                                        NO-UNDO.
DEF VAR hNameTag3     AS HANDLE                                        NO-UNDO.
DEF VAR hTextTag      AS HANDLE                                        NO-UNDO.
DEF VAR hTextTag2     AS HANDLE                                        NO-UNDO.
DEF VAR hTextTag3     AS HANDLE                                        NO-UNDO.
                                                                     
/** Objetos Mensagem XML-SOAP **/                                    
DEF VAR hXmlSoap          AS HANDLE                                    NO-UNDO.
DEF VAR hXmlEnvelope      AS HANDLE                                    NO-UNDO.
DEF VAR hXmlHeader        AS HANDLE                                    NO-UNDO.
DEF VAR hXmlWsse          AS HANDLE                                    NO-UNDO.
DEF VAR hXmlUsernameToken AS HANDLE                                    NO-UNDO.
DEF VAR hXmlBody          AS HANDLE                                    NO-UNDO.
DEF VAR hXmlAutentic      AS HANDLE                                    NO-UNDO.
DEF VAR hXmlMetodo        AS HANDLE                                    NO-UNDO.
DEF VAR hXmlRootSoap      AS HANDLE                                    NO-UNDO.
DEF VAR hXmlNode1Soap     AS HANDLE                                    NO-UNDO.
DEF VAR hXmlNode2Soap     AS HANDLE                                    NO-UNDO.
DEF VAR hXmlNode3Soap     AS HANDLE                                    NO-UNDO.
DEF VAR hXmlTagSoap       AS HANDLE                                    NO-UNDO.
DEF VAR hXmlTag2Soap      AS HANDLE                                    NO-UNDO.
DEF VAR hXmlTag3Soap      AS HANDLE                                    NO-UNDO.
DEF VAR hXmlTag4Soap      AS HANDLE                                    NO-UNDO.
DEF VAR hXmlTextSoap      AS HANDLE                                    NO-UNDO.

/** Variaveis do pagamento beneficios */
DEF VAR hHeader           AS HANDLE                                    NO-UNDO.
DEF VAR hBody             AS HANDLE                                    NO-UNDO.
DEF VAR hMain             AS HANDLE                                    NO-UNDO.
DEF VAR hSubNode3         AS HANDLE                                    NO-UNDO.

DEF BUFFER b-crapcop1 FOR crapcop.
DEF BUFFER b-crapcop2 FOR crapcop.
DEF BUFFER crablbi    FOR craplbi.

/* atualiza-pagamento */
DEF VAR i-nro-lote            AS INTE                NO-UNDO.
DEF VAR aux_mmaacomp          AS CHAR                NO-UNDO FORMAT "x(06)".
DEF VAR i-cod-erro            AS INT                 NO-UNDO.
DEF VAR c-desc-erro           AS CHAR                NO-UNDO.
DEF VAR h_b1crap00            AS HANDLE              NO-UNDO.
DEF VAR p-registro            AS Recid               NO-UNDO.
DEF VAR p-literal       AS CHAR       NO-UNDO.
DEF VAR p-ult-sequencia AS INTE       NO-UNDO.
DEF VAR p-nro-docto     AS INTE       NO-UNDO.

/* id da arrecadacao da gps*/
DEF VAR aux_idarrgps    AS DECIMAL INIT 0    NO-UNDO.

DEF TEMP-TABLE tt-crapcop LIKE crapcop.

/* Variáveis de uso da BO 200 */
DEF VAR h-b1wgen0200         AS HANDLE                              NO-UNDO.
DEF VAR aux_incrineg         AS INT                                 NO-UNDO.
/*DEF VAR aux_cdcritic         AS INT                                 NO-UNDO.
DEF VAR aux_dscritic         AS CHAR                                NO-UNDO.*/


FUNCTION verificacao_bloqueio RETURNS INTEGER
         (INPUT par_cdcooper AS INT,
          INPUT par_nrdcaixa AS INT,
          INPUT par_cdagenci AS INT,
          INPUT par_cdoperad AS CHAR,
          INPUT par_nmdatela AS CHAR,
          INPUT par_idorigem AS INT,
          INPUT par_dtmvtolt AS DATE,
          INPUT par_nrcpfcgc AS DEC,
          INPUT par_nrprocur AS DEC,
          INPUT par_tpdconsu AS INT) FORWARD.


FUNCTION busca_procurador_beneficio RETURNS LOGICAL
        (INPUT par_cdcooper AS INT,
         INPUT par_cdagenci AS INT,
         INPUT par_cdoperad AS CHAR,
         INPUT par_nrdcaixa AS INT,
         INPUT par_nmdatela AS CHAR,
         INPUT par_cdcopben AS INT,
         INPUT par_nrrecben AS DEC,
         INPUT par_nrbenefi AS DEC,
         OUTPUT TABLE FOR tt-lancred) FORWARD.


/*............................ PROCEDURES EXTERNAS ..........................*/

/* ************************************************************************* */
/**               Procedure para buscar domicilio bancario - DOMINS         **/
/* ************************************************************************  */
PROCEDURE busca-domins:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-domins.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-domins.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter domicilio bancario".
 
    Busca: DO WHILE TRUE:

        FIND crapcop WHERE 
             crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapcop  THEN
            DO:
                ASSIGN aux_cdcritic = 651.
                LEAVE Busca.
            END.

        FIND crapass WHERE  
             crapass.cdcooper = par_cdcooper AND
             crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF  crapass.inpessoa = 2 THEN
            DO:
                ASSIGN aux_cdcritic = 833.
                LEAVE Busca.
            END.

        FIND crapage WHERE  
             crapage.cdcooper = par_cdcooper     AND
             crapage.cdagenci = crapass.cdagenci NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapage  THEN
            DO:
                ASSIGN aux_cdcritic = 962.
                LEAVE Busca.
            END.

        FIND crapttl WHERE 
             crapttl.cdcooper = par_cdcooper   AND
             crapttl.nrdconta = par_nrdconta   AND
             crapttl.idseqttl = par_idseqttl   NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapttl  THEN
            DO:
                ASSIGN aux_cdcritic = 012.
                LEAVE Busca.
            END.

        FIND crapope WHERE 
             crapope.cdcooper = par_cdcooper AND
             crapope.cdoperad = par_cdoperad NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapttl  THEN
            DO:
                ASSIGN aux_cdcritic = 067.
                LEAVE Busca.
            END.

        CREATE tt-domins.
        ASSIGN tt-domins.cdcooper = crapttl.cdcooper
               tt-domins.nrdconta = crapttl.nrdconta
               tt-domins.cdagenci = crapass.cdagenci
               tt-domins.nmresage = crapage.nmresage
               tt-domins.nmrecben = crapttl.nmextttl
               tt-domins.cdorgpag = crapage.cdorgpag
               tt-domins.dsdircop = crapcop.dsdircop
               tt-domins.nmextttl = crapttl.nmextttl
               tt-domins.nmoperad = crapope.nmoperad
               tt-domins.nmcidade = crapage.nmcidade
               tt-domins.nmextcop = crapcop.nmextcop
               tt-domins.nmrescop = crapcop.nmrescop
               tt-domins.cdagebcb = crapcop.cdagebcb
               tt-domins.idseqttl = crapttl.idseqttl
               tt-domins.nrctacre = crapass.nrdconta.
        LEAVE.
    END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).
            

            IF  par_flgerlog  THEN
                RUN proc_gerar_log ( INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid ).
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


/*****************************************************************************/
/**                         Valida NB e NIT   - DOMINS                      **/
/*************************************************************************** */
PROCEDURE valida-nbnit:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_tpregist AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrbenefi AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_nrrecben AS DECI                              NO-UNDO.
                                                                    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                              NO-UNDO.  
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           par_nmdcampo = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Validar NB e NIT".

    DO WHILE TRUE:

        IF  par_nrbenefi = 0  AND par_nrrecben = 0  THEN
            DO:
                ASSIGN aux_dscritic = "NB ou NIT devem ser informados."
                       par_nmdcampo = "nrbenefi".
                LEAVE.
            END.

        FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND  
                           craptab.nmsistem = "CRED"         AND
                           craptab.tptabela = "GENERI"       AND
                           craptab.cdempres = 0              AND
                           craptab.cdacesso = "ARQRETINSS"   AND
                           craptab.tpregist = par_tpregist  
                           NO-LOCK NO-ERROR NO-WAIT.
                          
        IF  NOT AVAIL craptab   THEN
            DO:   
                ASSIGN aux_cdcritic = 55
                       par_nmdcampo = "nrbenefi".
                LEAVE.         
            END.
           
        LEAVE. 
       
    END. /* fim DO WHILE */ 

    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT TRUE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).

            RETURN "NOK".
        END.

    RETURN "OK".
    
END PROCEDURE. /* Fim - busca_sequencia */

/*****************************************************************************/
/**                    Gera impressao da alteracao  - DOMINS                **/
/*************************************************************************** */
PROCEDURE gera-impressao:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_cdagebcb AS INTE FORMAT "zz,zz9"              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_nrbenefi AS DECI FORMAT "zzzzzzzzz9"          NO-UNDO.
    DEF  INPUT PARAM par_nrctacre AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdorgpag AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrrecben AS DECI FORMAT "zzzzzzzzzz9"         NO-UNDO.
    DEF  INPUT PARAM par_nmrecben AS CHAR FORMAT "X(28)"               NO-UNDO.
    DEF  INPUT PARAM par_dsdircop AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmextttl AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmextcop AS CHAR FORMAT "X(50)"               NO-UNDO.
    DEF  INPUT PARAM par_nmrescop AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                              NO-UNDO.
                                                                     
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_tpregist AS INTE                                       NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                       NO-UNDO.
    DEF VAR aux_dstextab AS CHAR                                       NO-UNDO.
    DEF VAR aux_sittrans AS CHAR                                       NO-UNDO.
    DEF VAR aux_dscooper AS CHAR                                       NO-UNDO.
    DEF VAR aux_retornvl AS CHAR INIT "NOK"                            NO-UNDO.
    DEF VAR aux_nmarqger AS CHAR                                       NO-UNDO.
    DEF VAR aux_nrseqlot AS INTE                                       NO-UNDO.
    DEF VAR aux_nrseqreg AS INTE                                       NO-UNDO.
    DEF VAR aux_qttotreg AS INTE                                       NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR FORMAT "x(50)"                        NO-UNDO.
    DEF VAR aux_nmoperad AS CHAR FORMAT "x(40)"                        NO-UNDO.
    DEF VAR aux_nmmesano AS CHAR EXTENT 12
                       INIT ["JANEIRO","FEVEREIRO","MARCO",
                             "ABRIL","MAIO","JUNHO",
                             "JULHO","AGOSTO","SETEMBRO",
                             "OUTUBRO","NOVEMBRO","DEZEMBRO"]          NO-UNDO.
    DEF VAR aux_dsdmeses AS CHAR EXTENT 12                          
                                  INIT["1","2","3","4","5","6",     
                                       "7","8","9","O","N","D"]        NO-UNDO.
    DEF VAR aux_nmcidade AS CHAR                                       NO-UNDO. 
    DEF VAR rel_dsrefere AS CHAR FORMAT "x(50)"                        NO-UNDO.
    
    
    FORM  "\022\024\033\120\0330\033x0\033\105" /* Reseta e seta a fonte */
           SKIP(4) 
           "ALTERACAO DE DOMICILIO DE PAGAMENTO"         AT 20         SKIP(3)
           "\033\120\033\106"
           "\022\024\033\120" /* reseta impressora */
           "\0332\033x0"  
           SKIP (3) 
           par_nmrecben LABEL "NOME DO BENEFICIARIO"                   SKIP(2)   
           par_nrbenefi LABEL "NUMERO DO BENEFICIO"                    SPACE(3)
           par_nrrecben LABEL "No. NIT (se houver)"            /*(3)*/ SKIP(2) 
           "PARA"                                        AT 5          SKIP(1)
           par_cdorgpag LABEL "ORGAO PAGADOR"            AT 5          SKIP(1)
           par_nrctacre LABEL "CONTA-CORRENTE"           AT 5  /*(4)*/ SKIP(2) 
           "AUTORIZACAO"                                 AT 33         SKIP(2)
           "Autorizo,      sob     minha      total     "              
           "responsabilidade,     a"                                   SKIP
           par_nmextcop                  NO-LABEL    
           " - " 
           par_nmrescop                  NO-LABEL ","                  SKIP
           "codigo" par_cdagebcb         NO-LABEL 
           ",  a efetuar  a  alteracao de  domicilio,  relativa ao"    SKIP
           "beneficio acima citado."                                   SKIP(2)
           rel_dsrefere NO-LABEL                                       SKIP(6)
           "_______________________________________"    AT 17
           SKIP
           aux_nmprimtl                     NO-LABEL    AT 17
           SKIP (5)
           "_______________________________________"    AT 17  
           SKIP
           aux_nmoperad                     NO-LABEL    AT 17  
           
           WITH SIDE-LABEL COLUMN 10 FRAME f_declaracao.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_tpregist = 30.

    IF  par_flgerlog THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Imprime Autorizacao de Alteracao de Domicilio".

    Gera: DO WHILE TRUE:

        EMPTY TEMP-TABLE tt-erro.

        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".

        Grava: DO TRANSACTION
            ON ERROR  UNDO Grava, LEAVE Grava
            ON QUIT   UNDO Grava, LEAVE Grava
            ON STOP   UNDO Grava, LEAVE Grava
            ON ENDKEY UNDO Grava, LEAVE Grava:

            ASSIGN aux_sittrans = "NOK".

            ContadorTab: DO aux_contador = 1 TO 10:
        
                FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND  
                                   craptab.nmsistem = "CRED"         AND
                                   craptab.tptabela = "GENERI"       AND
                                   craptab.cdempres = 0              AND
                                   craptab.cdacesso = "ARQRETINSS"   AND
                                   craptab.tpregist = aux_tpregist  
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                  
                IF  NOT AVAILABLE craptab   THEN
                    IF  LOCKED craptab   THEN
                        DO:
                            IF  aux_contador = 10 THEN
                                DO:
                                    ASSIGN aux_cdcritic = 77.
                                    UNDO Grava, LEAVE Grava.
                                END.
                            ELSE 
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT ContadorTab.
                                END.
                        END.
                    ELSE       
                        DO:   
                            ASSIGN aux_cdcritic = 55.
                            UNDO Grava, LEAVE Grava.        
                        END.

                ASSIGN aux_dstextab = craptab.dstextab.

                LEAVE ContadorTab.
            END.

            /* Monta o nome do arquivo de retorno */
            ASSIGN aux_nmarqger = "0" + STRING(par_cdagebcb,"9999") +
                                  STRING(DAY(par_dtmvtolt),"99") +
                                  aux_dsdmeses[MONTH(par_dtmvtolt)] +
                                  ".RET" +
                                  LEFT-TRIM(aux_dstextab,"0"). 

                 
            OUTPUT STREAM str_1 TO VALUE (aux_dscooper + "arq/" + aux_nmarqger).
        
            ASSIGN  aux_nrseqlot = aux_nrseqlot + 1
                    aux_nrseqreg = aux_nrseqreg + 1
                    aux_qttotreg = 0. 
    
            /* Header do lote */
            PUT STREAM  str_1 UNFORMATTED
                        "1"
                        STRING(aux_nrseqreg,"9999999")
                        "30"
                        "756"
                        "02"          
                        SUBSTRING(STRING(par_dtmvtolt,"99999999"),5,4)
                        SUBSTRING(STRING(par_dtmvtolt,"99999999"),3,2)
                        SUBSTRING(STRING(par_dtmvtolt,"99999999"),1,2)
                        STRING(aux_nrseqlot,"99")
                        "CONPAG"
                        FILL(" ",63)                    
                        STRING(aux_dstextab,"x(6)")  
                        FILL(" ",140)
                        SKIP.
                                   
            ASSIGN aux_nrseqreg = aux_nrseqreg + 1
                   aux_qttotreg = aux_qttotreg + 1.
                        
            /* Detalhe */     
            PUT STREAM  str_1 UNFORMATTED
                        "2"
                        STRING(aux_nrseqreg,"9999999")
                        STRING(par_nrbenefi,"9999999999")   /** NB **/ 
                        FILL("0",14)  
                        FILL(" ",1)
                        FILL("0",10)  
                        FILL(" ",1)
                        STRING(par_nrctacre,"9999999999")   
                        "3"          
                        STRING(par_cdorgpag,"999999") 
                        FILL(" ",11)               
                        FILL(" ",28)  
                        STRING(par_nrrecben,"99999999999")  /** NIT **/
                        FILL("0",19) 
                        FILL(" ",110)
                        SKIP.
                       
            ASSIGN aux_nrseqreg = aux_nrseqreg + 1.
                         
            /* Trailer do lote */
            PUT STREAM  str_1 UNFORMATTED
                        "3"
                        STRING(aux_nrseqreg,"9999999")
                        "30"

                        "756"
                        STRING(aux_qttotreg,"99999999")
                        STRING(aux_nrseqlot,"99")
                        FILL(" ",217)
                        SKIP.
                            
            /* Fim - Atualizacao de dados cadastrais */
            
            RUN gera_log_dmns ( INPUT par_cdcooper,
                                INPUT par_nrbenefi, 
                                INPUT par_nrrecben, 
                                INPUT par_nmrecben, 
                                INPUT par_nrctacre,
                                INPUT par_idseqttl,
                                INPUT par_cdorgpag,
                                INPUT par_cdagenci,
                                INPUT par_dtmvtolt,
                                INPUT par_cdoperad ).
    
            IF  aux_tpregist = 0  THEN
                ASSIGN craptab.dstextab = STRING(INT(craptab.dstextab) + 1).
            ELSE
                ASSIGN craptab.dstextab = STRING(INT(craptab.dstextab) + 1,"999999").

            OUTPUT STREAM str_1 CLOSE.

            ASSIGN aux_sittrans = "OK".

        END. /* Final da Transação */

        IF  aux_sittrans <> "OK" THEN
            LEAVE Gera.

        /* copia o arquivo para diretorio do BANCOOB */
        UNIX SILENT VALUE("ux2dos < " + aux_dscooper + "arq/" + aux_nmarqger +
                          ' | tr -d "\032"' +
                          " > /micros/" + crapcop.dsdircop +
                          "/bancoob/" + aux_nmarqger + " 2>/dev/null").

        /* Move para o salvar */
        UNIX SILENT VALUE("mv " + aux_dscooper + "arq/" + aux_nmarqger +
                            " " + aux_dscooper + "salvar 2>/dev/null").
        
     /********************* IMPRESSAO DA AUTORIZACAO ************************/
    
        ASSIGN aux_nmprimtl = TRIM(par_nmextttl).
               aux_nmprimtl = FILL(" ",INT((40 - LENGTH(par_nmextttl)) / 2 )) +
                              aux_nmprimtl.
    
        ASSIGN aux_nmoperad = TRIM(par_nmoperad).
               aux_nmoperad = FILL(" ",INT((40 - LENGTH(par_nmoperad)) / 2 )) +
                              aux_nmoperad.
    
        ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" +
                              par_dsiduser.
        
        UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
    
        ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
               aux_nmarqimp = aux_nmarquiv + ".ex".
                  
        OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp).
        
        ASSIGN aux_nmcidade = TRIM(SUBSTRING(par_nmcidade,1,1) +
                                   SUBSTRING(LOWER(par_nmcidade),2))
               rel_dsrefere = 
                     aux_nmcidade + ", " + STRING(DAY(par_dtmvtolt),"99")  +
                     " de " + LOWER(TRIM(aux_nmmesano[MONTH(par_dtmvtolt)])) + 
                     " de " + STRING(YEAR(par_dtmvtolt),"9999") + ".".
    
        DISPLAY  STREAM  str_1   par_nmrecben      par_nrbenefi   
                                 par_nrrecben      par_cdorgpag        
                                 par_nrctacre      par_nmextcop 
                                 par_nmrescop      par_cdagebcb 
                                 rel_dsrefere      aux_nmprimtl 
                                 aux_nmoperad 
                                 WITH FRAME f_declaracao.

        OUTPUT STREAM str_1 CLOSE.

        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.

                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE Gera.
                    END.

                RUN envia-arquivo-web IN h-b1wgen0024 
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT aux_nmarqimp,
                     OUTPUT par_nmarqpdf,
                     OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen0024)  THEN
                    DELETE PROCEDURE h-b1wgen0024.

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE Gera.
        END.  

        ASSIGN par_nmarqimp = aux_nmarqimp.
               aux_retornvl = "OK".

        LEAVE Gera.

    END.

    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        RUN gera_erro ( INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1,            /** Sequencia **/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic ).

    IF  par_flgerlog  THEN
        DO:
            RUN proc_gerar_log ( INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_dscritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT (IF aux_retornvl = "OK" THEN TRUE
                                        ELSE FALSE),
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid ).

             RUN proc_gerar_log_item 
                ( INPUT aux_nrdrowid,
                  INPUT "nrbenefi",
                  INPUT "",
                  INPUT par_nrbenefi ).

              RUN proc_gerar_log_item 
                ( INPUT aux_nrdrowid,
                  INPUT "nrrecben",
                  INPUT "",
                  INPUT par_nrrecben ).

               RUN proc_gerar_log_item 
                ( INPUT aux_nrdrowid,
                  INPUT "dstextab",
                  INPUT "",
                  INPUT aux_dstextab).
                  
        END.

    RETURN aux_retornvl.

END PROCEDURE. /* Fim gera impressão */

/* ************************************************************************* */
/*                       Busca beneficiarios - CADINS                        */
/* ************************************************************************* */
PROCEDURE busca-benefic:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nmrecben AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdagcpac AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                              NO-UNDO.
                                                                   
    DEF OUTPUT PARAM par_qtregist AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.                            
    DEF OUTPUT PARAM TABLE FOR tt-benefic.                         
                                                                   
    DEF VAR aux_nrregist AS INTE                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-benefic.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_nrregist = par_nrregist.
           
    Busca: DO WHILE TRUE:

        FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                           crapage.cdagenci = par_cdagcpac 
                           NO-LOCK NO-ERROR. 

        IF NOT AVAIL crapage THEN
           DO:
               ASSIGN aux_cdcritic = 962.
               LEAVE Busca.
           END.

        FOR EACH crapcbi WHERE 
                 crapcbi.cdcooper = par_cdcooper                     AND
                 crapcbi.nmrecben MATCHES "*" + par_nmrecben + "*"   AND
                 crapcbi.cdagenci = par_cdagcpac 
                 NO-LOCK BY crapcbi.nmrecben:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginação */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:

                    CREATE tt-benefic.

                    ASSIGN tt-benefic.nmrecben = crapcbi.nmrecben
                           tt-benefic.nrcpfcgc = crapcbi.nrcpfcgc
                           tt-benefic.nrbenefi = crapcbi.nrbenefi
                           tt-benefic.nrrecben = crapcbi.nrrecben
                           tt-benefic.cdaginss = crapcbi.cdaginss 
                           tt-benefic.dtatucad = crapcbi.dtatucad 
                           tt-benefic.dtdenvio = crapcbi.dtdenvio
                           tt-benefic.tpmepgto = crapcbi.tpmepgto
                           tt-benefic.nrdconta = crapcbi.nrdconta
                           tt-benefic.cdaltcad = crapcbi.cdaltcad.
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.

        END.

        IF NOT(CAN-FIND(FIRST tt-benefic NO-LOCK)) THEN
           DO:
               ASSIGN aux_cdcritic = 911.
               LEAVE Busca.
           END.

        LEAVE.

    END.

    IF aux_dscritic <> "" OR 
       aux_cdcritic <> 0  THEN
       DO:
           RUN gera_erro ( INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic ).

           RETURN "NOK".

       END.

    RETURN "OK".

END PROCEDURE. /* Fim busca-benefic */

/* ************************************************************************* */
/*                      Trata opcao de alteracao - CADINS                    */
/* ************************************************************************* */
PROCEDURE trata-opcao:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
                                                                     
    DEF  INPUT PARAM par_nrrecben AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_nmrecben AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nrbenefi AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_nrnovcta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdaltera AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdaltcad AS INTE                              NO-UNDO.
                                                                       
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dstextab AS CHAR                                       NO-UNDO.
    DEF VAR aux_retornvl AS CHAR INIT "NOK"                            NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapcbi-ant.
    EMPTY TEMP-TABLE tt-crapcbi-atl.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Trata opcao de alteracao".
 
    Trata: DO TRANSACTION
        ON ERROR  UNDO Trata, LEAVE Trata
        ON QUIT   UNDO Trata, LEAVE Trata
        ON STOP   UNDO Trata, LEAVE Trata
        ON ENDKEY UNDO Trata, LEAVE Trata:

        ContadorCbi: DO aux_contador = 1 TO 10:

            FIND crapcbi WHERE crapcbi.cdcooper = par_cdcooper   AND
                               crapcbi.nrrecben = par_nrrecben   AND
                               crapcbi.nrbenefi = par_nrbenefi
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAIL crapcbi  THEN
                IF  LOCKED crapcbi  THEN
                    DO:
                        IF  aux_contador = 10 THEN
                            DO:
                                ASSIGN aux_cdcritic = 341.
                                UNDO Trata, LEAVE Trata.
                            END.
                        ELSE 
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT ContadorCbi.
                            END.
                    END.
            LEAVE ContadorCbi.
        END.
        /* Tratamento para posterior geracao de log */
        CREATE tt-crapcbi-ant.
        BUFFER-COPY crapcbi TO tt-crapcbi-ant.
    
        IF  par_cdaltera = 90 OR par_cdaltera = 92 THEN
            DO:
                ASSIGN crapcbi.dtdenvio = ?
                       crapcbi.cdaltcad = par_cdaltera
                       crapcbi.nrnovcta = 0
                       crapcbi.tpnovmpg = 0.

                IF  par_cdaltera = 90 THEN
                    ASSIGN crapcbi.dtatucad = ?.
                ELSE
                    ASSIGN crapcbi.dtatucad = par_dtmvtolt.
                /* Tratamento para posterior geracao de log */
                CREATE tt-crapcbi-atl.
                BUFFER-COPY crapcbi TO tt-crapcbi-atl.
                
                FIND craptab WHERE
                     craptab.cdcooper = 0            AND
                     craptab.nmsistem = "CRED"       AND
                     craptab.tptabela = "GENERI"     AND
                     craptab.cdempres = 0            AND
                     craptab.cdacesso = "DSCMANINSS" AND
                     craptab.tpregist = par_cdaltera
                     NO-LOCK NO-ERROR.

                ASSIGN aux_dstextab = craptab.dstextab.

                RUN gera_log_cdns ( INPUT par_cdcooper,
                                    INPUT par_dtmvtolt,
                                    INPUT par_cdoperad,
                                    INPUT par_nrnovcta,
                                    INPUT par_nmrecben,
                                    INPUT par_nrbenefi,
                                    INPUT par_nrrecben,
                                    INPUT aux_dstextab ).
            END.
        ELSE
        IF  par_cdaltera = 01 THEN
            DO:
                ASSIGN crapcbi.dtdenvio = ?
                       crapcbi.tpnovmpg = 1
                       crapcbi.cdaltcad = 1
                       crapcbi.dtatucad = par_dtmvtolt
                       crapcbi.nrnovcta = 0.

                /* Tratamento para posterior geracao de log */
                CREATE tt-crapcbi-atl.
                BUFFER-COPY crapcbi TO tt-crapcbi-atl.
                                              
                FIND craptab WHERE craptab.cdcooper = 0              AND
                                   craptab.nmsistem = "CRED"         AND
                                   craptab.tptabela = "GENERI"       AND
                                   craptab.cdempres = 0              AND
                                   craptab.cdacesso = "DSCMANINSS"   AND
                                   craptab.tpregist = 1          
                                   NO-LOCK NO-ERROR.
          
                ASSIGN aux_dstextab = craptab.dstextab.

                RUN gera_log_cdns ( INPUT par_cdcooper,
                                    INPUT par_dtmvtolt,
                                    INPUT par_cdoperad,
                                    INPUT par_nrnovcta,
                                    INPUT par_nmrecben,
                                    INPUT par_nrbenefi,
                                    INPUT par_nrrecben,
                                    INPUT aux_dstextab ).

                RUN imprime-termo ( INPUT crapcbi.cdcooper,
                                    INPUT crapcbi.cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT par_cdoperad,
                                    INPUT par_idorigem,
                                    INPUT crapcbi.dtatucad,
                                    INPUT crapcbi.cdaltcad,
                                    INPUT crapcbi.nrrecben,
                                    INPUT crapcbi.nrbenefi,
                                    INPUT par_dsiduser,
                                   OUTPUT par_nmarqimp,
                                   OUTPUT par_nmarqpdf,
                                   OUTPUT TABLE tt-erro ).

                IF  RETURN-VALUE = "NOK" THEN
                    LEAVE Trata.
            END.
        ELSE
        IF  par_cdaltera = 02 OR par_cdaltera = 09 THEN
            DO:
                ASSIGN crapcbi.dtdenvio = ?
                       crapcbi.cdaltcad = (IF par_cdaltera = 02 THEN 2 ELSE 9)
                       crapcbi.dtatucad = par_dtmvtolt
                       crapcbi.tpnovmpg = 2
                       crapcbi.nrnovcta = par_nrnovcta.

                /* Tratamento para posterior geracao de log */
                CREATE tt-crapcbi-atl.
                BUFFER-COPY crapcbi TO tt-crapcbi-atl.
                               
                FIND craptab WHERE craptab.cdcooper = 0              AND
                                   craptab.nmsistem = "CRED"         AND
                                   craptab.tptabela = "GENERI"       AND
                                   craptab.cdempres = 0              AND
                                   craptab.cdacesso = "DSCMANINSS"   AND
                                   craptab.tpregist = 2  
                                   NO-LOCK NO-ERROR.
                
                ASSIGN aux_dstextab = craptab.dstextab.
                
                RUN gera_log_cdns ( INPUT par_cdcooper,
                                    INPUT par_dtmvtolt,
                                    INPUT par_cdoperad,
                                    INPUT par_nrnovcta,
                                    INPUT par_nmrecben,
                                    INPUT par_nrbenefi,
                                    INPUT par_nrrecben,
                                    INPUT aux_dstextab ).
                
                RUN imprime-termo ( INPUT crapcbi.cdcooper,
                                    INPUT crapcbi.cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT par_cdoperad,
                                    INPUT par_idorigem,
                                    INPUT crapcbi.dtatucad,
                                    INPUT crapcbi.cdaltcad,
                                    INPUT crapcbi.nrrecben,
                                    INPUT crapcbi.nrbenefi,
                                    INPUT par_dsiduser,
                                   OUTPUT par_nmarqimp,
                                   OUTPUT par_nmarqpdf,
                                   OUTPUT TABLE tt-erro ).
                IF  RETURN-VALUE = "NOK" THEN
                    LEAVE Trata.
                       
            END.

        ASSIGN aux_retornvl = "OK".
    
        LEAVE Trata.
       
    END. /* Fim do DO WHILE TRUE */

    RELEASE crapcbi.

    IF  aux_retornvl <> "OK" OR
        aux_dscritic <> ""   OR   aux_cdcritic <> 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAIL tt-erro THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
            ELSE
                RUN gera_erro ( INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT 1,            /** Sequencia **/
                                INPUT aux_cdcritic,
                                INPUT-OUTPUT aux_dscritic ).
        END.


    IF  par_nrdconta = 0  THEN
        ASSIGN par_flgerlog = FALSE.

    IF  par_flgerlog  THEN
        RUN proc_gerar_log_tab
            ( INPUT par_cdcooper,
              INPUT par_cdoperad,
              INPUT aux_dscritic,
              INPUT aux_dsorigem,
              INPUT aux_dstransa,
              INPUT (IF aux_retornvl = "OK" THEN TRUE
                        ELSE FALSE),
              INPUT par_idseqttl,
              INPUT par_nmdatela,
              INPUT par_nrdconta,
              INPUT TRUE,
              INPUT BUFFER tt-crapcbi-ant:HANDLE,
              INPUT BUFFER tt-crapcbi-atl:HANDLE ).

    RETURN aux_retornvl.

END PROCEDURE. /* Fim trata-opcao */

/* ************************************************************************* */
/*                           Valida nova conta - CADINS                      */
/* ************************************************************************* */
PROCEDURE valida-nvconta:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_nrnovcta AS INTE                              NO-UNDO.
                                                                    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_nmprimtl AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.                             

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           par_nmdcampo = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Validar nova conta".

    DO WHILE TRUE:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                           crapass.nrdconta = par_nrnovcta   NO-LOCK NO-ERROR. 
          
        IF  NOT AVAIL crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 9
                       par_nmdcampo = "nrnovcta".
                LEAVE.
            END.

        ASSIGN par_nmprimtl = crapass.nmprimtl.
    
        LEAVE.
    END.

    IF  aux_cdcritic <> 0 THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log ( INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid ).

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE. /* Fim valida-nvconta */

/*****************************************************************************/
/**               Procedure para validar opcao de alteracao - CADINS        **/
/*************************************************************************** */
PROCEDURE valida-opcao:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
                                                                    
    DEF  INPUT PARAM par_nrrecben AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_nrbenefi AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_cdaltera AS INTE                              NO-UNDO.
                                                                       
    DEF OUTPUT PARAM par_nmprimtl AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_dsnovmpg AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_nrnovcta AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_tpnovmpg AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_msgretor AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_dstextab AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           par_nmdcampo = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Validar opcao de alteracao".
 
    Valida: DO WHILE TRUE:

        FIND FIRST craptab WHERE craptab.cdcooper = 0            AND
                                 craptab.nmsistem = "CRED"       AND
                                 craptab.tptabela = "GENERI"     AND
                                 craptab.cdempres = 0            AND
                                 craptab.cdacesso = "DSCMANINSS" AND
                                 craptab.tpregist = par_cdaltera 
                                 NO-LOCK NO-ERROR.
        IF  NOT AVAIL craptab THEN
            DO:
               ASSIGN aux_cdcritic = 14
                      par_nmdcampo = "cdaltera".
               LEAVE Valida. 
            END.
        ELSE
            DO:
                ASSIGN par_dstextab = craptab.dstextab.
            END.

        FIND crapcbi WHERE crapcbi.cdcooper = par_cdcooper   AND
                           crapcbi.nrrecben = par_nrrecben   AND
                           crapcbi.nrbenefi = par_nrbenefi
                           NO-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crapcbi THEN
            DO:
                ASSIGN aux_cdcritic = 911
                       par_nmdcampo = "cdaltera".
                LEAVE Valida.
            END. 

        ASSIGN par_nrnovcta = crapcbi.nrnovcta
               par_tpnovmpg = crapcbi.tpnovmpg.

        /* OPCAO 90*/
        /* Cancelar alteracao */
        IF  par_cdaltera = 90   THEN
            DO:
                IF  crapcbi.dtdenvio <> ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Solicitacao ja enviada. " +
                                              "Cancelamento nao permitido."
                               par_nmdcampo = "cdaltera".
                        LEAVE Valida.
                    END.
                 
                IF  crapcbi.dtatucad = ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Nao ha alteracoes para " +
                                              "cancelar."
                               par_nmdcampo = "cdaltera".
                        LEAVE Valida.        
                    END.
            END.
        ELSE
        /* OPCAO 91 */
        /* Verificar ultima alteracao pendente de resposta */
        /* Que foram enviadas e ainda nao tiveram retorno */
        IF  par_cdaltera = 91  THEN
            DO:
                IF  crapcbi.dtdenvio = ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Nao ha alteracoes pendentes."
                               par_nmdcampo = "cdaltera".
                        LEAVE Valida.
                    END.
                ELSE
                    DO:
                        RUN alteracao-anterior
                            ( INPUT par_cdcooper,
                              INPUT par_nrnovcta,
                              INPUT par_tpnovmpg,
                             OUTPUT par_nmprimtl,
                             OUTPUT par_dsnovmpg ).

                        LEAVE Valida.
                    END.            
            END.  /* Fim da OPCAO 91 */
        ELSE
        /* OPCAO 92 */
        /* Solicita confirmacao de cadastro */
        IF  par_cdaltera = 92   THEN
            DO:
                IF  crapcbi.dtdenvio <> ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Solicitacao pendente. Favor " +
                                              "aguardar o retorno."
                               par_nmdcampo = "cdaltera".
                        LEAVE Valida.
                    END.
            END. /* Fim da OPCAO 92 */
        ELSE
        /* Impressao de declaracao com os dados do cooperado */
        IF  par_cdaltera = 93  THEN
            DO:
                IF  NOT crapcbi.tpmepgto = 1  THEN
                    DO:
                        ASSIGN aux_dscritic = "Tipo de pagamento deve ser" +
                                              " cartao."
                               par_nmdcampo = "cdaltera".
                        LEAVE Valida.        
                    END.
            END.
        ELSE
        /* OPCAO 1 */
        /* Troca de C/C para cartao sem trocar cooperativa/PA */
        IF  par_cdaltera = 01   THEN
            DO:
                IF  crapcbi.tpmepgto = 1  THEN
                    DO:
                        ASSIGN aux_dscritic = "Meio de pagamento atual " +
                                              "deve ser conta."
                               par_nmdcampo = "cdaltera".
                        LEAVE Valida.
                    END.
                
                IF  crapcbi.dtatucad <> ? AND
                    crapcbi.dtdenvio = par_dtmvtolt THEN
                    DO:
                        ASSIGN aux_dscritic = "Ja existe solicitacao " +
                                              "enviada na data de hoje."
                               par_nmdcampo = "cdaltera".
                        LEAVE Valida.      
                    END.
                
                IF (crapcbi.cdaltcad <> 90  AND
                    crapcbi.cdaltcad <> 92 )AND
                    crapcbi.dtatucad <> ?   AND
                    crapcbi.dtdenvio = ?   THEN
                    DO:
                        ASSIGN aux_dscritic = "Alteracao pendente para envio."
                               par_nmdcampo = "cdaltera".
                        LEAVE Valida.
                    END.
            END. /* Fim da OPCAO 1 */
        ELSE
        /* OPCAO 2 */
        /* Troca de conta corrente */
        IF  par_cdaltera = 02  THEN
            DO:
                IF  crapcbi.tpmepgto = 1   THEN
                    DO:
                        ASSIGN aux_dscritic = "Meio de pagamento atual " +
                                              "deve ser conta."
                               par_nmdcampo = "cdaltera".
                        LEAVE Valida.
                    END.
               
                IF  crapcbi.dtatucad <> ? AND
                    crapcbi.dtdenvio = par_dtmvtolt   THEN
                    DO:
                        ASSIGN aux_dscritic = "Ja existe solicitacao " +
                                              "enviada na data de hoje."
                               par_nmdcampo = "cdaltera".
                        LEAVE Valida.       
                    END.
               
                IF (crapcbi.cdaltcad <> 90   AND
                    crapcbi.cdaltcad <> 92)  AND 
                    crapcbi.dtatucad <> ?    AND
                    crapcbi.dtdenvio  = ?    THEN
                    DO:
                        ASSIGN par_msgretor = "Alteracao pendente para " +
                                              "envio. Uma nova ira cancelar " +
                                              "a anterior.".
                   
                        RUN alteracao-anterior
                            ( INPUT par_cdcooper,
                              INPUT par_nrnovcta,
                              INPUT par_tpnovmpg,
                             OUTPUT par_nmprimtl,
                             OUTPUT par_dsnovmpg ).

                        LEAVE Valida.
                      
                    END.
                
                IF  crapcbi.cdaltcad = par_cdaltera  AND
                    crapcbi.dtdenvio <> ?            AND
                    crapcbi.dtdenvio <> par_dtmvtolt THEN
                    DO:
                        ASSIGN par_msgretor = "Ja existe uma alteracao desta" +
                                              " opcao aguardando retorno.".
                      
                        RUN alteracao-anterior
                            ( INPUT par_cdcooper,
                              INPUT par_nrnovcta,
                              INPUT par_tpnovmpg,
                             OUTPUT par_nmprimtl,
                             OUTPUT par_dsnovmpg ).

                        LEAVE Valida.
                     
                    END.
            END. /* Fim da OPCAO 2 */
        ELSE
        /* Opcao 09 */
        /* Troca de cartao para c/c na mesma cooperativa/PA */
        IF  par_cdaltera = 09   THEN
            DO:
                IF  crapcbi.tpmepgto = 2  THEN
                    DO:
                        ASSIGN aux_dscritic = "Meio de pagamento atual " +
                                              "deve ser Recibo/Cartao."
                               par_nmdcampo = "cdaltera".
                        LEAVE Valida.
                    END.
                
                IF  crapcbi.dtatucad <> ? AND
                    crapcbi.dtdenvio = par_dtmvtolt  THEN
                    DO:
                        ASSIGN aux_dscritic = 
                                           "Ja existe solicitacao enviada " +
                                           "na data de hoje."
                               par_nmdcampo = "cdaltera".

                        RUN alteracao-anterior
                            ( INPUT par_cdcooper,
                              INPUT par_nrnovcta,
                              INPUT par_tpnovmpg,
                             OUTPUT par_nmprimtl,
                             OUTPUT par_dsnovmpg ).
                       
                        LEAVE Valida.        
                    END.
                
                IF  crapcbi.dtatucad <> ? AND
                    crapcbi.dtdenvio = ? THEN
                    DO:
                        ASSIGN par_msgretor = 
                                           "Alteracao pendente para envio. " +
                                           "Uma nova ira cancelar a anterior.".
                        
                        RUN alteracao-anterior
                            ( INPUT par_cdcooper,
                              INPUT par_nrnovcta,
                              INPUT par_tpnovmpg,
                             OUTPUT par_nmprimtl,
                             OUTPUT par_dsnovmpg ).

                        LEAVE Valida.
                    END.
                   
                IF  crapcbi.cdaltcad = par_cdaltera  AND
                    crapcbi.dtdenvio <> ?            AND
                    crapcbi.dtdenvio <> par_dtmvtolt THEN
                    DO:
                        ASSIGN par_msgretor = "Ja existe uma alteracao desta" +
                                              " opcao aguardando retorno.".
                   
                        RUN alteracao-anterior
                            ( INPUT par_cdcooper,
                              INPUT par_nrnovcta,
                              INPUT par_tpnovmpg,
                             OUTPUT par_nmprimtl,
                             OUTPUT par_dsnovmpg ). 

                        LEAVE Valida.
                    END.
              
                LEAVE Valida.
                
            END. /* Fim do OPCAO 9 */

        LEAVE.
                  
    END. /* Fim do DO WHILE TRUE */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:

            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).
            
            IF  par_nrdconta = 0  THEN
                ASSIGN par_flgerlog = FALSE.

            IF  par_flgerlog  THEN
                RUN proc_gerar_log ( INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid ).
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/**               Procedure para geracao de declaracao - CADINS             **/
/*************************************************************************** */
PROCEDURE gera-declaracao:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_nmrecben LIKE crapcbi.nmrecben                NO-UNDO.
    DEF  INPUT PARAM par_nrbenefi LIKE crapcbi.nrbenefi                NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdagcpac AS INTE                              NO-UNDO.
                                                                       
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_cdrelato AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.                                
                                                                       
    DEF VAR rel_dtrefere AS CHAR  FORMAT "x(45)"                       NO-UNDO.
    DEF VAR rel_dsmesref AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                       NO-UNDO.

    FORM "DECLARACAO DE RECEBIMENTO DE CARTAO DE BENEFICIO"  
         SKIP(2)
         "Eu,"  par_nmrecben ", beneficio" par_nrbenefi  ","
         "declaro ter recebido o cartao de pagamento eletronico de beneficios"
         "com proposito de permitir saques de valores concedidos pela Previdencia"
         "Social."
         SKIP(1)
         "Declaro ainda que me responsabilizo pela guarda do cartao e senha."
         WITH WIDTH 80 NO-LABELS FRAME f_declaracao_1.
     
    FORM SKIP(4)     
         "------------------------------         ------------------------------"
         SKIP
         par_nmrecben     AT 01 
         crapope.nmoperad AT 40
         SKIP(2)
         rel_dtrefere
         SKIP(2)
         "Orientacoes:"
         SKIP(1)
         "- Entregar o cartao somente para o titular e/ou procurador legalmente"
         "  constituido."
         SKIP
         "- Anexar copia do documento de identidade."
         WITH NO-LABELS WIDTH 80 FRAME f_declaracao_2.

             
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Impressao da declaracao de recebimento de cartao".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/crrl509_" + 
                          par_dsiduser
           par_cdrelato = 509
           rel_dsmesref = "Janeiro,Fevereiro,Marco,Abril,Maio,Junho,Julho" +
                          ",Agosto,Setembro,Outubro,Novembro,Dezembro".

        UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").

        ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
                   aux_nmarqimp = aux_nmarquiv + ".ex".

    Gera: DO WHILE TRUE:

        OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp) PAGED.
                 
        { sistema/generico/includes/b1cabrelvar.i }
        { sistema/generico/includes/b1cabrel080.i "0" par_cdrelato }
        
        VIEW STREAM str_1 FRAME f_cabrel080_1. 
        
        FIND crapage WHERE crapage.cdcooper = par_cdcooper   AND
                           crapage.cdagenci = par_cdagcpac   NO-LOCK NO-ERROR.
    
        FIND crapope WHERE crapope.cdcooper = par_cdcooper   AND
                           crapope.cdoperad = par_cdoperad   NO-LOCK NO-ERROR.
        
        IF  AVAILABLE crapage   THEN
            ASSIGN rel_dtrefere = crapage.nmcidade + ", "   + 
                                  STRING(DAY(par_dtmvtolt)) + 
                                  " de " + ENTRY(MONTH(par_dtmvtolt),rel_dsmesref)
                                  + " de " + STRING(YEAR(par_dtmvtolt)) + ".".


        DISPLAY STREAM str_1 par_nmrecben
                             par_nrbenefi      
                             WITH FRAME f_declaracao_1.
        
        PAUSE 0.
    
        DISPLAY STREAM str_1 par_nmrecben
                             crapope.nmoperad  WHEN AVAILABLE crapope
                             rel_dtrefere      WITH FRAME f_declaracao_2.
        PAUSE 0.
    
        OUTPUT STREAM str_1 CLOSE.
    
        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.

                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE Gera.
                    END.
               
                RUN envia-arquivo-web IN h-b1wgen0024 
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT aux_nmarqimp,
                     OUTPUT par_nmarqpdf,
                     OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen0024)  THEN
                    DELETE PROCEDURE h-b1wgen0024.

                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".
        END.   
                                                      
        ASSIGN par_nmarqimp = aux_nmarqimp.
    
        LEAVE Gera.
    END.

    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).

            IF  par_nrdconta = 0  THEN
                ASSIGN par_flgerlog = FALSE.

            IF  par_flgerlog  THEN
                RUN proc_gerar_log ( INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid ).

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE. /* Fim gera-declaracao */ 


/*****************************************************************************/
/**            Procedure para consultar beneficio pela data - BEINSS        **/
/*************************************************************************** */
PROCEDURE busca-beneficio:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nrrecben AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_nrbenefi AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_dtdinici AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_dtdfinal AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
                                                                    
    DEF OUTPUT PARAM TABLE FOR tt-erro.                             
    DEF OUTPUT PARAM TABLE FOR tt-lancred.                          
                                                                    
    DEF VAR aux_nrrecben AS DECI                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-lancred.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    Busca: DO WHILE TRUE:

        ASSIGN aux_nrrecben = par_nrrecben.

        IF  par_nrbenefi <> 0  THEN
            aux_nrrecben = ?.

        FOR EACH craplbi WHERE (craplbi.cdcooper = par_cdcooper      AND
                                craplbi.nrrecben = aux_nrrecben)
                                OR
                               (craplbi.cdcooper = par_cdcooper      AND
                                craplbi.nrrecben = par_nrrecben  AND
                                craplbi.nrbenefi = par_nrbenefi) NO-LOCK:

            IF  craplbi.dtiniper >= par_dtdinici AND
                craplbi.dtfimper <= par_dtdfinal THEN
                .
            ELSE NEXT.

            CREATE tt-lancred.
                   
            FIND craptab NO-LOCK WHERE
                 craptab.cdcooper = 0                  AND
                 craptab.nmsistem = "CRED"             AND
                 craptab.tptabela = "CONFIG"           AND
                 craptab.cdempres = 0                  AND
                 craptab.cdacesso = "TPBENEINSS"       AND
                 craptab.tpregist = craplbi.nrespeci   NO-ERROR.
            
            IF  AVAILABLE craptab   THEN
                ASSIGN tt-lancred.dsespeci = craptab.dstextab. 
            
            ASSIGN tt-lancred.nrrecben = craplbi.nrrecben
                   tt-lancred.nrbenefi = craplbi.nrbenefi
                   tt-lancred.dtiniper = craplbi.dtiniper
                   tt-lancred.dtfimper = craplbi.dtfimper
                   tt-lancred.dtinipag = craplbi.dtinipag
                   tt-lancred.dtfimpag = craplbi.dtfimpag
                   tt-lancred.vlliqcre = craplbi.vlliqcre
                   tt-lancred.tpmepgto = IF  craplbi.tpmepgto = 2 THEN
                                             "Conta"
                                         ELSE  "Cartao ou Recibo"   
                   tt-lancred.nrdconta = craplbi.nrdconta
                   tt-lancred.cdagenci = craplbi.cdagenci
                   tt-lancred.dtdpagto = craplbi.dtdpagto
                  /*Se as duas datas estiverem em branco entao nao tem 
                    indice de debito ou credito*/
                   tt-lancred.flgcredi = IF  craplbi.dtblqcre = ? AND
                                             craplbi.dtlibcre = ? 
                                         THEN ""
                                         ELSE 
                                         IF  craplbi.dtlibcre = ? THEN 
                                             "Bloqueado"
                                         ELSE
                                         IF  craplbi.dtblqcre = ? THEN 
                                             "Desbloqueado"
                                         ELSE "" 
                   tt-lancred.dtflgcre = IF  craplbi.dtblqcre = ? THEN 
                                             craplbi.dtlibcre
                                         ELSE 
                                         IF  craplbi.dtlibcre = ? THEN 
                                             craplbi.dtblqcre
                                         ELSE ? NO-ERROR.

            IF  ERROR-STATUS:ERROR  THEN
                DO:
                    ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                    LEAVE Busca.
                END.

            FIND crappbi WHERE 
                             crappbi.cdcooper = par_cdcooper         AND
                 crappbi.nrrecben = tt-lancred.nrrecben  AND
                 crappbi.nrbenefi = tt-lancred.nrbenefi  AND

                      (crappbi.dtvalprc <> ?            AND
                       crappbi.dtvalprc >= tt-lancred.dtdpagto OR
                       
                      (tt-lancred.dtdpagto = ?          AND 
                       crappbi.dtvalprc >= par_dtmvtolt AND
                       crappbi.dtvalprc >= tt-lancred.dtinipag))
                       NO-LOCK NO-ERROR.

            IF  AVAIL crappbi THEN
                DO: 
                    ASSIGN tt-lancred.cdcooper = crappbi.cdcooper
                           tt-lancred.dtmvtolt = crappbi.dtmvtolt
                           tt-lancred.nrbenefi = crappbi.nrbenefi
                           tt-lancred.nmprocur = crappbi.nmprocur
                           tt-lancred.dsdocpcd = crappbi.dsdocpcd
                           tt-lancred.nrdocpcd = crappbi.nrdocpcd
                           tt-lancred.cdoedpcd = crappbi.cdoedpcd
                           tt-lancred.cdufdpcd = crappbi.cdufdpcd
                           tt-lancred.dtvalprc = crappbi.dtvalprc
                           tt-lancred.nrrecben = crappbi.nrrecben
                           tt-lancred.cdorgpag = crappbi.cdorgpag
                           tt-lancred.flgexist = TRUE NO-ERROR.

                    IF  ERROR-STATUS:ERROR  THEN
                        DO:
                            ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                            LEAVE Busca.
                        END.
                END.
            ELSE
                ASSIGN tt-lancred.flgexist = FALSE.
        END.

        LEAVE Busca.

    END. /* Fim Busca */

    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE. /* Fim busca-beneficio */

/* ************************************************************************* */
/*                      Busca beneficiarios INSS - BEINSS                    */
/* ************************************************************************* */
PROCEDURE busca-benefic-beinss:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
                                                                    
    DEF  INPUT PARAM par_nmrecben AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdageins AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_nrprocur AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                              NO-UNDO.
                                                                    
    DEF OUTPUT PARAM aux_qtregist AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.                             
    DEF OUTPUT PARAM TABLE FOR tt-benefic.                          
                                                                    
    DEF VAR aux_nrregist AS INTE                                       NO-UNDO.
   
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-benefic.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_nrregist = par_nrregist.
 
    Busca: DO WHILE TRUE:

        IF  par_nrprocur <> 0  THEN
            DO:     
                FOR EACH crapcbi WHERE crapcbi.cdcooper = par_cdcooper AND
                                       crapcbi.nrrecben = par_nrprocur NO-LOCK:
                    RUN gera-tt-benefic 
                        ( INPUT par_cdcooper,
                          INPUT par_nrregist,
                          INPUT par_nriniseq,
                          INPUT-OUTPUT aux_nrregist,
                          INPUT-OUTPUT aux_qtregist,
                          INPUT-OUTPUT TABLE tt-benefic ).
                END.

                IF  NOT TEMP-TABLE tt-benefic:HAS-RECORDS  THEN
                    DO:
                        FOR EACH crapcbi WHERE 
                                 crapcbi.cdcooper = par_cdcooper AND
                                 crapcbi.nrbenefi = par_nrprocur NO-LOCK:

                            RUN gera-tt-benefic 
                                ( INPUT par_cdcooper,
                                  INPUT par_nrregist,
                                  INPUT par_nriniseq,
                                  INPUT-OUTPUT aux_nrregist,
                                  INPUT-OUTPUT aux_qtregist,
                                  INPUT-OUTPUT TABLE tt-benefic ).
                        END.
                    END.
            END.
        ELSE
        IF  par_nrcpfcgc <> 0  THEN
            DO:
                FOR EACH crapcbi WHERE crapcbi.cdcooper = par_cdcooper AND
                                       crapcbi.nrcpfcgc = par_nrcpfcgc NO-LOCK:
                    RUN gera-tt-benefic 
                        ( INPUT par_cdcooper,
                          INPUT par_nrregist,
                          INPUT par_nriniseq,
                          INPUT-OUTPUT aux_nrregist,
                          INPUT-OUTPUT aux_qtregist,
                          INPUT-OUTPUT TABLE tt-benefic ).
                END.
            END.
        ELSE
        IF  par_cdageins = 0  THEN
            DO:
                
                FOR EACH crapcbi WHERE crapcbi.cdcooper = par_cdcooper  AND
                                       crapcbi.nmrecben MATCHES "*" +
                                               par_nmrecben + "*"
                                       NO-LOCK BY crapcbi.nmrecben:

                    RUN gera-tt-benefic 
                        ( INPUT par_cdcooper,
                          INPUT par_nrregist,
                          INPUT par_nriniseq,
                          INPUT-OUTPUT aux_nrregist,
                          INPUT-OUTPUT aux_qtregist,
                          INPUT-OUTPUT TABLE tt-benefic ).

                END.
            END.
       ELSE
            DO:
      
                FIND crapage WHERE
                     crapage.cdcooper = par_cdcooper   AND
                     crapage.cdagenci = par_cdageins 
                     NO-LOCK NO-ERROR.
                
                IF  NOT AVAILABLE crapage  THEN   
                    DO:
                        ASSIGN aux_cdcritic = 962.
                        LEAVE Busca.
                    END.

                FOR EACH crapcbi WHERE crapcbi.cdcooper = par_cdcooper   AND
                                       crapcbi.cdagenci = par_cdageins   AND
                                       crapcbi.nmrecben MATCHES "*" + 
                                               par_nmrecben + "*"
                                       NO-LOCK BY crapcbi.nmrecben:

                    RUN gera-tt-benefic 
                        ( INPUT par_cdcooper,
                          INPUT par_nrregist,
                          INPUT par_nriniseq,
                          INPUT-OUTPUT aux_nrregist,
                          INPUT-OUTPUT aux_qtregist,
                          INPUT-OUTPUT TABLE tt-benefic ).
                END.           
            END.
           
        IF  NOT(CAN-FIND(FIRST tt-benefic NO-LOCK)) THEN
            DO:
                ASSIGN aux_cdcritic = 911.
                LEAVE Busca.
            END.
        LEAVE.
    END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE. /* Fim busca-benefic-beinss */
             

/* ........................PROCEDURE INTERNAS............................... */

PROCEDURE alteracao-anterior:

    DEF  INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF  INPUT PARAM par_nrnovcta AS INTE NO-UNDO.
    DEF  INPUT PARAM par_tpnovmpg AS INTE NO-UNDO.
    DEF OUTPUT PARAM par_nmprimtl AS CHAR NO-UNDO.
    DEF OUTPUT PARAM par_dsnovmpg AS CHAR NO-UNDO.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                       crapass.nrdconta = par_nrnovcta
                       NO-LOCK NO-ERROR.
                                     
    IF  AVAILABLE crapass  THEN
        ASSIGN par_nmprimtl = crapass.nmprimtl.
    
    IF  par_tpnovmpg = 1 THEN
        ASSIGN par_dsnovmpg = "Cartao/Recibo".
    ELSE
    IF  par_tpnovmpg = 2  THEN
        ASSIGN par_dsnovmpg = "Conta".
    ELSE
        ASSIGN par_dsnovmpg = "".

    RETURN "OK".
                 
END PROCEDURE. /* FIm valida-opcao */



PROCEDURE gera_log_dmns:
    
    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrbenefi AS DECI                               NO-UNDO.
    DEF INPUT PARAM par_nrrecben AS DECI                               NO-UNDO.
    DEF INPUT PARAM par_nmrecben AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_nrctacre AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdorgpag AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                               NO-UNDO.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
                            
    UNIX SILENT
         VALUE("echo " + STRING(par_dtmvtolt, "99/99/9999")
               + " "                                              +
               STRING(TIME,"HH:MM:SS") + "' --> '"                +
               " Operador "  + par_cdoperad              + " - "  +
               " NB " + STRING(par_nrbenefi)             + " - "  +
               " NIT " + STRING(par_nrrecben)            + " - "  +
               " PA  " + STRING(par_cdagenci)            + " - "  +
               " Titularidade " + STRING(par_idseqttl)   + " - "  +
               " Orgao pagador " + STRING(par_cdorgpag)  + " - "  +
               " alterou o domicilio de pagamento do INSS"        +
               " para conta/dv " + STRING(par_nrctacre) + "."     + 
               " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
               "/log/domins.log").

END.  


PROCEDURE gera_log_cdns:
                                                                    
    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nrnovcta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nmrecben AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nrbenefi AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_nrrecben AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_dstextab AS CHAR                              NO-UNDO.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
                     
    UNIX SILENT
         VALUE("echo " + STRING(par_dtmvtolt, "99/99/9999")
               + " " +
               STRING(TIME,"HH:MM:SS") + "' --> '"         + 
               " Operador " + par_cdoperad       + " - "   +
               " NIT "  + STRING(par_nrrecben)   + " - "   +
               " NB " + STRING(par_nrbenefi)     + " - "   +
               " Beneficiario " + par_nmrecben   + " - "   +
               " conta: " + STRING(par_nrnovcta) + " - "   +
                 par_dstextab  +  "."                      + 
               " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
               "/log/cadins.log").

END PROCEDURE.


PROCEDURE imprime-termo:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dtatucad AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_cdaltcad AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrrecben AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_nrbenefi AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                              NO-UNDO.
                                                                    
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.                             
                                                                    
    DEF VAR h-b1crap85   AS HANDLE                                     NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                       NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    Gera: DO WHILE TRUE:

        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
        ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" +
                              par_dsiduser.

        UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
        
        ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
               aux_nmarqimp = aux_nmarquiv + ".ex"
               aux_nmarqpdf = aux_nmarquiv + ".pdf".
                  
        FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                           crapope.cdoperad = par_cdoperad 
                           NO-LOCK NO-ERROR NO-WAIT.
    
        IF  NOT AVAILABLE crapope   THEN
            DO:
                ASSIGN aux_cdcritic = 67.
                LEAVE Gera.
            END.

        RUN siscaixa/web/dbo/b1crap85.p PERSISTENT SET h-b1crap85.
        
        RUN termo IN h-b1crap85 (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT crapope.cdoperad,
                                 INPUT par_dtatucad,
                                 INPUT par_nrrecben,
                                 INPUT par_nrbenefi,
                                 INPUT par_cdaltcad,
                                 INPUT aux_nmarqimp).

        DELETE PROCEDURE h-b1crap85.

        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.

                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE Gera.
                    END.

                RUN envia-arquivo-web IN h-b1wgen0024 
                   ( INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT aux_nmarqimp,
                    OUTPUT par_nmarqpdf,
                    OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen0024)  THEN
                    DELETE PROCEDURE h-b1wgen0024.
            
                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".
            END.   
                                                      
        ASSIGN par_nmarqimp = aux_nmarqimp.
        LEAVE.
    END.
    IF  aux_cdcritic <> 0 THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE gera-tt-benefic:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                              NO-UNDO.
                                                                     
    DEF INPUT-OUTPUT PARAM aux_nrregist AS INTE                        NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_qtregist AS INTE                        NO-UNDO.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-benefic.

    ASSIGN par_qtregist = par_qtregist + 1.

    /* controles da paginação */
    IF  (par_qtregist < par_nriniseq) OR
        (par_qtregist > (par_nriniseq + par_nrregist)) THEN
        NEXT.

    IF  aux_nrregist > 0 THEN
        DO:

            CREATE tt-benefic.
            ASSIGN tt-benefic.nmrecben = crapcbi.nmrecben
                   tt-benefic.nrcpfcgc = crapcbi.nrcpfcgc
                   tt-benefic.nrbenefi = crapcbi.nrbenefi
                   tt-benefic.nrrecben = crapcbi.nrrecben
                   tt-benefic.cdaginss = crapcbi.cdaginss
                   tt-benefic.dtatucad = crapcbi.dtatucad 
                   tt-benefic.dtdenvio = crapcbi.dtdenvio
                   tt-benefic.tpmepgto = crapcbi.tpmepgto
                   tt-benefic.nrdconta = crapcbi.nrdconta
                   tt-benefic.cdaltcad = crapcbi.cdaltcad
                   tt-benefic.dtnasben = crapcbi.dtnasben
                   tt-benefic.nmmaeben = crapcbi.nmmaeben
                   tt-benefic.dsendben = crapcbi.dsendben
                   tt-benefic.nmbairro = crapcbi.nmbairro
                   tt-benefic.nrcepend = crapcbi.nrcepend
                   tt-benefic.dtatuend = crapcbi.dtatuend
                   tt-benefic.cdagenci = crapcbi.cdagenci
                   tt-benefic.indresvi = crapcbi.indresvi
                   tt-benefic.dscresvi = IF crapcbi.indresvi = 1 THEN
                                            "Beneficiario"
                                         ELSE
                                            IF crapcbi.indresvi = 2 THEN
                                               "Procurador"
                                            ELSE
                                               ""
                   tt-benefic.dtcompvi = crapcbi.dtcompvi
                   tt-benefic.dtprcomp = ADD-INTERVAL(crapcbi.dtcompvi,1,"YEAR").
                   

            FIND FIRST crapage WHERE crapage.cdcooper = par_cdcooper AND
                                     crapage.cdagenci = crapcbi.cdagenci
                                     NO-LOCK NO-ERROR.

            IF AVAIL crapage THEN
                ASSIGN tt-benefic.nmresage = crapage.nmresage.
    END.

    ASSIGN aux_nrregist = aux_nrregist - 1.

END PROCEDURE.

/**************************************************************************
 Procedures do processamento de arquivos do INSS (GATI)
**************************************************************************/
PROCEDURE consulta_horario:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_hrfimpag AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_mnfimpag AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_horarios AS CHAR                                    NO-UNDO.

    ASSIGN aux_horarios = "".

    EMPTY TEMP-TABLE tt-erro.
    
    DO  aux_contador = 1 TO 10:

        FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                           craptab.nmsistem = "CRED"        AND
                           craptab.tptabela = "GENERI"      AND
                           craptab.cdempres = 00            AND
                           craptab.cdacesso = "HRPGTOINSS"  AND
                           craptab.tpregist = par_cdagenci
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.


        IF   NOT AVAILABLE craptab   THEN
             IF   LOCKED craptab   THEN
                  DO:
                      aux_cdcritic = 77.
                      PAUSE 1 NO-MESSAGE.
                      NEXT.
                  END.
             ELSE
                  DO:
                      aux_cdcritic = 55.
                      LEAVE.
                  END.    
        ELSE
             aux_cdcritic = 0.

        LEAVE.
    END.  /*  Fim do DO .. TO  */


    IF  aux_cdcritic > 0  THEN
        DO:
            ASSIGN aux_dscritic = "".
        
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END. 
    ELSE
       DO: 
           ASSIGN aux_horarios = STRING((INT(craptab.dstextab)),"HH:MM:SS")
                  par_hrfimpag = INT(SUBSTR(aux_horarios,1,2))        
                  par_mnfimpag = INT(SUBSTR(aux_horarios,4,2)).

       END.


    RETURN "OK".

END PROCEDURE. /* consulta_horario */

PROCEDURE altera_horario:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_hrfimpag AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_mnfimpag AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    DO   aux_contador = 1 TO 10:
         
         FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                            craptab.nmsistem = "CRED"        AND
                            craptab.tptabela = "GENERI"      AND
                            craptab.cdempres = 00            AND
                            craptab.cdacesso = "HRPGTOINSS"  AND
                            craptab.tpregist = par_cdagenci
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
         
         IF   NOT AVAILABLE craptab   THEN
              IF   LOCKED craptab   THEN
                   DO:
                       aux_cdcritic = 77.
                       PAUSE 1 NO-MESSAGE.
                       NEXT.
                   END.
              ELSE
                   DO:
                       aux_cdcritic = 55.
                       LEAVE.
                   END.    
         ELSE
              aux_cdcritic = 0.
         
         LEAVE.
    END.  /*  Fim do DO .. TO  */

    IF   aux_cdcritic > 0   THEN
         DO:
             ASSIGN aux_dscritic = "".
         
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
         
             RETURN "NOK".
         END. 

    ASSIGN aux_hrfimpag = INT(SUBSTR(STRING(INT(craptab.dstextab),
                                                "HH:MM"),1,2))        
           aux_mnfimpag = INT(SUBSTR(STRING(INT(craptab.dstextab),
                                                "HH:MM"),4,2)).
    
    ASSIGN craptab.dstextab = STRING((par_hrfimpag * 3600) +
                                     (par_mnfimpag * 60)).

    UNIX SILENT VALUE(
                "echo "      + STRING(par_dtmvtolt,"99/99/9999")         + 
                " "          + STRING(TIME,"HH:MM:SS")    + "' --> '"    +
                "Operador: " + par_cdoperad               + " - "        +
                "alterou o horario de pagamento do PA  "  + 
                STRING(par_cdagenci,"zz9")                + " de "       + 
                STRING(aux_hrfimpag,"99")                 + ":"          + 
                STRING(aux_mnfimpag,"99")                 + " para "     + 
                STRING(par_hrfimpag,"99")                 + ":"          + 
                STRING(par_mnfimpag,"99") + " >> log/presoc.log").

    RETURN "OK".

END PROCEDURE. /* altera_horario */

PROCEDURE consulta_log_processamento:

    DEF  INPUT PARAM par_cdcoopss AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenss AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_ncaixass AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_datadlog LIKE crapdat.dtmvtolt             NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-log-process.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-log-process.
    EMPTY TEMP-TABLE tt-erro.

    RUN pi_carrega_temp_cooperativas (INPUT par_cdcoopss,
                                      INPUT par_cdagenss,
                                      INPUT par_ncaixass,
                                      INPUT par_cdcooper).

    IF   RETURN-VALUE = "NOK"   THEN
         RETURN "NOK".

    FOR EACH tt-crapcop:

        /* Monta a lista de arquivos processados e gerados na data escolhida */
        FOR EACH craplog WHERE craplog.cdcooper = tt-crapcop.cdcooper   AND
                               craplog.cdprogra = "PRPREV"              AND
                               craplog.dttransa = par_datadlog         
                               NO-LOCK BY craplog.hrtransa:
            
            /* Arquivos PROCESSADOS ou DEVOLVIDOS */
            IF craplog.dstransa MATCHES "*CONCILIADO*"  OR
               craplog.dstransa MATCHES "*CONCILIACAO*" THEN
               DO:
                  /* Arquivo de importacao */
                  IF SUBSTRING(craplog.dstransa,6,9) <> "FSUBDMC13" THEN
                     DO:
                        /* Se for PA sede */
                        IF par_cdagenci = tt-crapcop.cdagsede   THEN
                           DO:
                              IF INT(SUBSTRING(craplog.dstransa,6,2)) <> 0 THEN
                                 NEXT.

                           END.
                        ELSE
                        IF INT(SUBSTRING(craplog.dstransa,6,2)) <> par_cdagenci
                                        AND par_cdagenci        <> 0       THEN
                           NEXT.
    
                        CREATE tt-log-process.

                        ASSIGN tt-log-process.cdcooper = tt-crapcop.cdcooper
                               tt-log-process.nmrescop = tt-crapcop.nmrescop
                              /* tt-log-process.dslinlog = "PA "*/
                               tt-log-process.cdagenci = par_cdagenci.
    
                        IF INT(SUBSTRING(craplog.dstransa,6,2)) = 0   THEN
                           ASSIGN tt-log-process.dslinlog = 
                                         tt-log-process.dslinlog +
                                         STRING(tt-crapcop.cdagsede,"99").
                        ELSE
                           ASSIGN tt-log-process.dslinlog = 
                                          tt-log-process.dslinlog +
                                          SUBSTRING(craplog.dstransa,6,2).
                        
                     END.
                  ELSE
                     DO:
                        /* Arquivo extrato */
                        CREATE tt-log-process.

                        ASSIGN tt-log-process.cdcooper = tt-crapcop.cdcooper
                               tt-log-process.nmrescop = tt-crapcop.nmrescop
                               tt-log-process.dslinlog = 
                                  "PA  " + STRING(par_cdagenci,"999") +
                                  " - "  +
                                  STRING(craplog.hrtransa,"HH:MM")   +
                                  " - "  +
                                  craplog.dstransa
                               tt-log-process.cdagenci = par_cdagenci.
                            
                        
                     END.
                
                  ASSIGN tt-log-process.dslinlog =  
                                        tt-log-process.dslinlog            +
                                        " - "                              +
                                        STRING(craplog.hrtransa,"HH:MM")   +
                                        " - "                              +
                                        craplog.dstransa.

                  

               END.

        END. /* FOR EACH craplog  */

    END. /* FOR EACH tt-crapcop: */
    
    RETURN "OK".

END PROCEDURE. /* consulta_log_processamento */

PROCEDURE consulta_log_geracao:

    DEF  INPUT PARAM par_cdcoopss AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenss AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_ncaixass AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_datadlog LIKE crapdat.dtmvtolt             NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-log-process.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-log-process.
    EMPTY TEMP-TABLE tt-erro.

    RUN pi_carrega_temp_cooperativas (INPUT par_cdcoopss,
                                      INPUT par_cdagenss,
                                      INPUT par_ncaixass,
                                      INPUT par_cdcooper).

    IF RETURN-VALUE = "NOK"   THEN
       RETURN "NOK".

    
    FOR EACH tt-crapcop:

        /* Monta a lista de arquivos processados e gerados na data escolhida */
        FOR EACH craplog WHERE craplog.cdcooper = tt-crapcop.cdcooper   AND
                               craplog.cdprogra = "PRPREV"              AND
                               craplog.dttransa = par_datadlog          
                               NO-LOCK BY craplog.hrtransa:
            
            /* Arquivos GERADOS */
            IF craplog.dstransa MATCHES "*GERADO*"   THEN
               DO:
                   CREATE tt-log-process.

                   ASSIGN tt-log-process.cdcooper = tt-crapcop.cdcooper
                          tt-log-process.nmrescop = tt-crapcop.nmrescop
                          tt-log-process.dslinlog = "GERAL "
                          tt-log-process.cdagenci = 9999
                          tt-log-process.dslinlog =  
                                tt-log-process.dslinlog            +
                                " - "                              +
                                STRING(craplog.hrtransa,"HH:MM")   +
                                " - "                              +
                                craplog.dstransa.

               END.
            
        END. /* FOR EACH craplog  */

    END. /* FOR EACH tt-crapcop: */
    
    RETURN "OK".

END PROCEDURE. /* consulta_log_geracao */


PROCEDURE verifica_operador_envio:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-mensagens.

    EMPTY TEMP-TABLE tt-mensagens.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND 
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "GENERI"       AND
                       craptab.cdempres = 00             AND
                       craptab.cdacesso = "NRARQMVBCB"   AND
                       craptab.tpregist = 99             
                       NO-LOCK NO-ERROR.

    IF   AVAIL craptab          AND
         craptab.dstextab <> "" THEN
         DO:
             CREATE tt-mensagens.

             ASSIGN tt-mensagens.nrseqmsg = 1
                    tt-mensagens.dsmensag =
                                 "Esta tela esta sendo usada pelo operador " + 
                                 craptab.dstextab.
         
             IF   par_cdoperad <> SUBSTRING(craptab.dstextab,1,10)   THEN
                  DO:
                      CREATE tt-mensagens.

                      ASSIGN tt-mensagens.nrseqmsg = 2
                             tt-mensagens.dsmensag = 
                                "Peca a liberacao ao Coordenador/Gerente...".
                  END.
             ELSE
                  DO:
                      CREATE tt-mensagens.

                      ASSIGN tt-mensagens.nrseqmsg = 3
                             tt-mensagens.dsmensag =
                                "Aguarde ou pressione F4/END para sair...".
                  END.
         END.   
         
    RETURN "OK".

END PROCEDURE. /* verifica_operador_envio */

PROCEDURE grava_operador_envio:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flggrava AS LOGI  FORMAT "Grava/Libera"    NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmoperad AS CHAR                           NO-UNDO.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND 
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 00           AND
                       craptab.cdacesso = "NRARQMVBCB" AND
                       craptab.tpregist = 99           EXCLUSIVE-LOCK NO-ERROR.
    IF   NOT AVAILABLE craptab   THEN
         DO:
             CREATE craptab.
             ASSIGN craptab.cdcooper = par_cdcooper
                    craptab.nmsistem = "CRED"   
                    craptab.tptabela = "GENERI"
                    craptab.cdempres = 0
                    craptab.cdacesso = "NRARQMVBCB"
                    craptab.tpregist = 99.
         END.
    
    IF   AVAILABLE craptab   THEN
         DO:
             IF   par_flggrava   THEN
                  ASSIGN craptab.dstextab = STRING(par_cdoperad,"x(10)") + "-" +
                                            par_nmoperad.
             ELSE
                  ASSIGN craptab.dstextab = "".
         END.
         
    RELEASE craptab.

    RETURN "OK".

END PROCEDURE. /* grava_operador_envio */

PROCEDURE verifica_arquivos_demonstrativo_inss:

    DEF  INPUT PARAM par_cdcoopss AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenss AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_ncaixass AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-arquivos.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    aux_nmarqtmp = "*" + "-FSUBDMC13." + "*B756*".

    FOR FIRST crapcop WHERE crapcop.cdcooper = 3 /* CECRED */ NO-LOCK:

        ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + 
                              "/integra/" + aux_nmarqtmp.
            
        INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + ".ZIP" + 
                                         " 2>/dev/null") NO-ECHO.
        
        DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
           
           SET STREAM str_1 aux_nmarquiv FORMAT "X(78)" WITH WIDTH 80.
        
           CREATE tt-arquivos.

           ASSIGN tt-arquivos.cdcooper = crapcop.cdcooper
                  tt-arquivos.nmrescop = crapcop.nmrescop
                  tt-arquivos.nmarquiv = SUBSTRING(aux_nmarquiv,
                                               R-INDEX(aux_nmarquiv,"/") + 1)
                  tt-arquivos.cdagenci = 0
                  tt-arquivos.qtnaopag = 0
                  tt-arquivos.vlnaopag = 0
                  tt-arquivos.qtbloque = 0
                  tt-arquivos.vlbloque = 0
                  tt-arquivos.dsstatus = "NAO PROCESSADO". 
           
           
        END.  /*  Fim do DO WHILE TRUE  */
        
        INPUT STREAM str_1 CLOSE.
    END. /* for each crapcop */

    RETURN "OK".

END PROCEDURE. /* verifica_arquivos_demonstrativo_inss */

PROCEDURE valida_diretorio_arquivos:

    DEF  INPUT PARAM par_cdcoopss AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenss AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_ncaixass AS INTE                           NO-UNDO.    
    DEF OUTPUT PARAM TABLE FOR tt-arq-cooper.
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    EMPTY TEMP-TABLE tt-arq-cooper.
    EMPTY TEMP-TABLE tt-erro.

    RUN verifica_arquivos_envio_inss (INPUT par_cdcoopss,
                                      INPUT par_cdagenss,
                                      INPUT par_ncaixass,  
                                      INPUT 0, /* par_cdcooper */
                                      INPUT YES,
                                      OUTPUT TABLE tt-arquivos,
                                      OUTPUT TABLE tt-erro).
    
    IF   RETURN-VALUE = "NOK"   THEN
         RETURN "NOK".

    FOR EACH tt-arquivos BREAK BY tt-arquivos.cdcooper:

        IF   FIRST-OF(tt-arquivos.cdcooper)   THEN
             DO:
                 CREATE tt-arq-cooper.

                 ASSIGN tt-arq-cooper.nmrescop = CAPS(tt-arquivos.nmrescop)
                        tt-arq-cooper.dsmensag = 
                                      "Ha arquivos pendentes de envio!".
             END.
    END.

    RUN verifica_arquivos_processamento_inss (INPUT par_cdcoopss,
                                              INPUT par_cdagenss,
                                              INPUT par_ncaixass,
                                              INPUT 0, /* par_cdcooper */
                                              INPUT 0, /* par_cdagenci */
                                              INPUT YES,
                                              OUTPUT TABLE tt-arquivos,
                                              OUTPUT TABLE tt-erro).
    
    IF   RETURN-VALUE = "NOK"   THEN
         RETURN "NOK".

    FOR EACH tt-arquivos BREAK BY tt-arquivos.cdcooper:

        IF   FIRST-OF(tt-arquivos.cdcooper)   THEN
             DO:
                 CREATE tt-arq-cooper.

                 ASSIGN tt-arq-cooper.nmrescop = CAPS(tt-arquivos.nmrescop)
                        tt-arq-cooper.dsmensag = 
                                      "Ha arquivos pendentes de processamento!".
             END.
    END.

    RETURN "OK".

END PROCEDURE. /* valida_diretorio_arquivos */

PROCEDURE processa_arquivos_demonstrativo:

    DEF  INPUT PARAM par_cdcoopss AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenss AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_ncaixass AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-arquivos.
    
    DEF  OUTPUT PARAM par_flgproce AS LOG                           NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_arqlista = ""
           par_flgproce = TRUE.

    FOR EACH tt-arquivos:


        FIND crapcop WHERE crapcop.cdcooper = tt-arquivos.cdcooper 
                           NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapcop  THEN
            DO:
                 ASSIGN aux_cdcritic = 651
                        aux_dscritic = "".
                 
                 RUN gera_erro (INPUT par_cdcoopss,
                                INPUT par_cdagenss,
                                INPUT par_ncaixass,
                                INPUT 1,            /** Sequencia **/
                                INPUT aux_cdcritic,
                                INPUT-OUTPUT aux_dscritic).
                 
                 RETURN "NOK".

             END. 

        
        /* Verifica se o extrato ja foi processado */
        FIND LAST craplog WHERE craplog.cdcooper = tt-arquivos.cdcooper   AND
                                craplog.cdprogra = "PRPREV"               AND
                                craplog.dstransa = tt-arquivos.nmarquiv +
                                " - EXTRATO PROCESSADO COM SUCESSO"
                                NO-LOCK NO-ERROR.

        IF   AVAILABLE craplog   THEN
             DO:
                 ASSIGN aux_cdcritic = 0
                        aux_dscritic = "Extrato " + tt-arquivos.nmarquiv + 
                                       " ja processado...".
                 
                 RUN gera_erro (INPUT par_cdcoopss,
                                INPUT par_cdagenss,
                                INPUT par_ncaixass,
                                INPUT 1,            /** Sequencia **/
                                INPUT aux_cdcritic,
                                INPUT-OUTPUT aux_dscritic).
                                          
                 /* Remove arquivo */
                 UNIX SILENT VALUE("rm /usr/coop/" + crapcop.dsdircop     +
                                   "/integra/" + tt-arquivos.nmarquiv + 
                                   " 2>/dev/null").
                 
                 RETURN "NOK".

             END. 
    
        RUN pi_extrai_demonstrativos (INPUT par_cdcoopss,
                                      INPUT par_cdagenss,
                                      INPUT par_ncaixass,
                                      INPUT crapcop.dsdircop,
                                      INPUT par_dtmvtolt, 
                                      INPUT par_cdoperad).
        
        IF RETURN-VALUE = "NOK" THEN
           par_flgproce = FALSE.

        IF   aux_arqlista = ""   THEN
             ASSIGN aux_arqlista = tt-arquivos.nmarquiv.
        ELSE
             ASSIGN aux_arqlista = aux_arqlista + "," + tt-arquivos.nmarquiv.

    END. /* FOR EACH tt-arquivos */

     
    UNIX SILENT VALUE("echo "      + STRING(par_dtmvtolt,"99/99/9999")         +
                      " "          + STRING(TIME,"HH:MM:SS")    + "' --> '"    +
                      "Operador: " + par_cdoperad               + " - "        +
                      "efetuou processamento dos demonstrativos: "             +
                      aux_arqlista + " >> log/prprev.log").

    RETURN "OK".

END PROCEDURE. /* processa_arquivos_demonstrativo */

PROCEDURE processa_arquivos_inss:

    DEF  INPUT        PARAM par_cdcoopss AS INTE                    NO-UNDO.
    DEF  INPUT        PARAM par_cdagenss AS INTE                    NO-UNDO.
    DEF  INPUT        PARAM par_ncaixass AS INTE                    NO-UNDO.
    DEF  INPUT        PARAM par_cddepart AS INTE                    NO-UNDO.
    DEF  INPUT        PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF  INPUT        PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF  INPUT        PARAM par_concilia AS CHAR                    NO-UNDO.
    DEF  INPUT-OUTPUT PARAM TABLE FOR tt-arquivos.
    DEF OUTPUT        PARAM TABLE FOR tt-mensagens.
    DEF OUTPUT        PARAM TABLE FOR tt-dif-import.
    DEF OUTPUT        PARAM TABLE FOR tt-rejeicoes.
    DEF OUTPUT        PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-mensagens.
    EMPTY TEMP-TABLE tt-dif-import.
    EMPTY TEMP-TABLE tt-rejeicoes.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_nrseqmsg = 1
           aux_arqlista = "".
    
    /* Arquivos de extrato nao podem entrar no for each  */
    FOR EACH tt-arquivos WHERE tt-arquivos.cdagenci <> 0 
                               BY tt-arquivos.cdagenci
                                BY tt-arquivos.nmarquiv:

        FIND crapcop WHERE crapcop.cdcooper = tt-arquivos.cdcooper
                           NO-LOCK NO-ERROR.

        /* Monta o nome do arquivo que sera extraido do ZIP */
        ASSIGN aux_nmarqext = "0" +
                       SUBSTRING(tt-arquivos.nmarquiv,1,4) +
                       SUBSTRING(tt-arquivos.nmarquiv,24,2) +
                       aux_dsdmeses[INT(SUBSTRING(tt-arquivos.nmarquiv,26,2))] +
                       ".EMI"
               aux_arqcerro = FALSE
               aux_flgderro = FALSE.

        /* Verifica se existe algum arquivo extraido sem complemento de PA */
        DO  aux_contador = 1 TO 10:
        
            IF   SEARCH("/usr/coop/" + TRIM(crapcop.dsdircop) + 
                        "/integra/" + aux_nmarqext) <> ?          THEN
                 DO:
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
                 
            LEAVE.

        END.

        /* Extrai o arquivo para o integra */
        UNIX SILENT VALUE("zipcecred.pl -silent " +
                          "-extract /usr/coop/" + TRIM(crapcop.dsdircop) +
                          "/integra/" + tt-arquivos.nmarquiv + 
                          " /usr/coop/" + TRIM(crapcop.dsdircop) + "/integra").

        /* Adiciona _<PA> no arquivo extraido */
        UNIX SILENT VALUE("mv /usr/coop/" + TRIM(crapcop.dsdircop) +
                          "/integra/" + aux_nmarqext +
                          " /usr/coop/" + TRIM(crapcop.dsdircop) +
                          "/integra/" + aux_nmarqext + "_" +
                          STRING(tt-arquivos.cdagenci,"999")).

        RUN pi_processa_arquivo_inss (INPUT par_cdcoopss,
                                      INPUT par_cdagenss,
                                      INPUT par_ncaixass,
                                      INPUT par_dtmvtolt,
                                      INPUT par_cdoperad,
                                      INPUT crapcop.nmrescop,
                                      INPUT crapcop.dsdircop,
                                      INPUT par_cddepart,
                                      INPUT par_concilia).

        /* Remove o arquivo extraido  */
       UNIX SILENT VALUE("rm /usr/coop/" + TRIM(crapcop.dsdircop) +
                          "/integra/" + aux_nmarqext + "_" +
                          STRING(tt-arquivos.cdagenci,"999") + " 2>/dev/null").

        /* Reprocessar arquivo */
        IF   RETURN-VALUE          = "NOK"         OR
             KEY-FUNCTION(LASTKEY) = "END-ERROR"   THEN
             NEXT.

        /* Move o ZIP para o salvar */
        UNIX SILENT VALUE("mv /usr/coop/" + TRIM(crapcop.dsdircop) +
                          "/integra/" + tt-arquivos.nmarquiv + 
                          " /usr/coop/" + TRIM(crapcop.dsdircop) + "/salvar").
        

        IF   aux_arqlista = ""   THEN
             ASSIGN aux_arqlista = tt-arquivos.nmarquiv.
        ELSE
             ASSIGN aux_arqlista = aux_arqlista + "," + tt-arquivos.nmarquiv.

    END.   
    
    RETURN "OK".

END PROCEDURE. /* processa_arquivos_inss */
                              

                                           
PROCEDURE envia_arquivos_inss:

  DEF  INPUT PARAM par_glbcdcop AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_dsdsenha AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
  DEF  INPUT PARAM TABLE FOR tt-arquivos.

  DEF OUTPUT PARAM par_flgderro AS LOG                            NO-UNDO.
  DEF OUTPUT PARAM TABLE FOR tt-erro.

  EMPTY TEMP-TABLE tt-erro.

  DEF VAR aux_arquivos AS CHAR                                    NO-UNDO.
  DEF VAR aux_arqderro AS CHAR                                    NO-UNDO.
  DEF VAR aux_tamarqui AS CHAR                                    NO-UNDO.

  ASSIGN aux_setlinha = ""
         aux_arqlista = ""
         aux_arquivos = ""
         aux_arqderro = ""
         par_flgderro = TRUE
         aux_tamarqui = ""
         aux_nmarquiv = "log/prprev.log"
         aux_arqderro = "log/msgerro.log".

  /* Obs.: Todos os log serao gerados para a CECRED */
  IF   NOT CAN-FIND(FIRST tt-arquivos)   THEN
       DO:
           ASSIGN aux_cdcritic = 239
                  aux_dscritic = "".
  
           RUN gera_erro (INPUT par_glbcdcop,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
  
           RETURN "NOK".

       END.

  RUN pi_carrega_temp_cooperativas (INPUT par_glbcdcop,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT par_cdcooper).

  IF RETURN-VALUE = "NOK"   THEN
     RETURN "NOK".

  FOR EACH tt-crapcop NO-LOCK BY tt-crapcop.cdcooper:

      ASSIGN aux_arqlista = "".

      FOR EACH tt-arquivos WHERE tt-arquivos.cdcooper = tt-crapcop.cdcooper
                                 NO-LOCK:
      
          FIND crapcop WHERE crapcop.cdcooper = tt-arquivos.cdcooper
                             NO-LOCK NO-ERROR.
      
          IF NOT AVAILABLE crapcop   THEN
             DO:
                 ASSIGN aux_cdcritic = 651
                        aux_dscritic = "".
                
                 RUN gera_erro (INPUT par_glbcdcop,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT 1,            /** Sequencia **/
                                INPUT aux_cdcritic,
                                INPUT-OUTPUT aux_dscritic).
      
                 RETURN "NOK".
      
             END.

          ASSIGN tt-arquivos.nmarquiv = 
                             ENTRY(NUM-ENTRIES(tt-arquivos.nmarquiv,"/"),
                             tt-arquivos.nmarquiv,"/").

          IF aux_arquivos = "" THEN
             ASSIGN aux_arquivos = tt-arquivos.nmarquiv.
          ELSE
             ASSIGN aux_arquivos = aux_arquivos + "," + tt-arquivos.nmarquiv.

          IF aux_arqlista = "" THEN
             ASSIGN  aux_arqlista = tt-arquivos.nmarquiv.
          ELSE
             ASSIGN aux_arqlista = aux_arqlista + "," + tt-arquivos.nmarquiv.


      END.

      IF aux_arqlista <> "" THEN
         DO:
            /* pega o nome do usuario no UNIX para o upload.sh */
            INPUT STREAM str_1 THROUGH VALUE("who am i").
            
            IMPORT STREAM str_1 aux_setlinha.
            
            INPUT STREAM str_1 CLOSE.
            
            IF SEARCH(aux_nmarquiv) = ? THEN
               UNIX SILENT VALUE(" > log/prprev.log").
            
            IF SEARCH(aux_arqderro) = ? THEN
               UNIX SILENT VALUE(" > log/msgerro.log").
            
            UNIX SILENT VALUE(" sudo upload.sh " +
                              STRING(crapcop.cdagebcb) +
                              " " +
                              par_dsdsenha + 
                              " " +
                              aux_arqlista +
                              " " +
                              aux_setlinha + "").
            

         END.
      
      IF par_flgderro = TRUE THEN
         DO:
            INPUT STREAM str_2 THROUGH VALUE("wc -m " + aux_arqderro + 
                                         " 2> /dev/null") NO-ECHO.
        
            SET STREAM str_2 aux_tamarqui FORMAT "x(30)".
             
            IF INT(SUBSTRING(aux_tamarqui,1,1)) <> 0 THEN
               par_flgderro = FALSE.
             
            INPUT STREAM str_2 CLOSE.
            
            UNIX SILENT VALUE("rm " + aux_arqderro + " 2> /dev/null").
               
         END.
        
      IF SEARCH(aux_arqderro) <> ? THEN
         UNIX SILENT VALUE("rm " + aux_arqderro + " 2> /dev/null").
          
  END.

  UNIX SILENT VALUE("echo "                                          +
                    STRING(par_dtmvtolt,"99/99/9999")                +
                    " - " + STRING(TIME,"HH:MM:SS")                  +
                    " - OPERADOR: "                                  +
                    par_cdoperad + " - Tela: PRPREV"                 + 
                    "' --> '" + STRING(crapcop.cdagebcb)             +
                    ". Enviou os arquivos " + aux_arquivos           + 
                    " ao Bancoob." + " >> log/proc_batch.log").
  
  UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")    +
                    " " + STRING(TIME,"HH:MM:SS") + "' --> '"      +
                    "Operador: " + par_cdoperad + " - "            +
                    "efetuou envio dos arquivos para INSS:  "      +
                    aux_arquivos + " >> log/prprev.log").
  
  RETURN "OK".

END PROCEDURE. /* envia_arquivos_inss */ 


PROCEDURE gera_arquivos_inss:

    DEF  INPUT PARAM par_cdcoopss AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenss AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_ncaixass AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    EMPTY TEMP-TABLE tt-erro.

    /* Valida PA quando for informado */
    IF   par_cdcooper <> 0                               AND 
         par_cdagenci <> 0                               AND
         NOT CAN-FIND(crapage WHERE
                      crapage.cdcooper = par_cdcooper    AND
                      crapage.cdagenci = par_cdagenci)   THEN
         DO:
             ASSIGN aux_cdcritic = 962
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcoopss,
                            INPUT par_cdagenss,
                            INPUT par_ncaixass,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    RUN pi_carrega_temp_cooperativas (INPUT par_cdcoopss,
                                      INPUT par_cdagenss,
                                      INPUT par_ncaixass,
                                      INPUT par_cdcooper).

    IF   RETURN-VALUE = "NOK"   THEN
         RETURN "NOK".

    ASSIGN aux_arqlista = "".

    BLOCO_COOPER:
    FOR EACH  tt-crapcop
        WHERE tt-crapcop.cdcooper NE 3:
        
        ASSIGN aux_nmarqger = ""
               aux_cdagefim = IF   par_cdagenci = 0   THEN
                                   999
                              ELSE par_cdagenci
               aux_nrseqlot = 0
               aux_nrseqreg = 0.

    
        DO TRANSACTION:

           RUN pi_busca_sequencia (INPUT tt-crapcop.cdcooper, 
                                   INPUT par_cdagenci,
                                   INPUT par_ncaixass, 
                                   INPUT 0).
           
        
           IF   RETURN-VALUE = "NOK"   THEN
                UNDO, RETURN "NOK".
           
           /* Monta o nome do arquivo de retorno */
           ASSIGN aux_nmarqger = "0" +
                                 STRING(tt-crapcop.cdagebcb,"9999") +
                                 STRING(DAY(par_dtmvtolt),"99")     +
                                 aux_dsdmeses[MONTH(par_dtmvtolt)]  +
                                 ".RET" +
                                 craptab.dstextab.
    
           RUN pi_atualiza_sequencia (INPUT 0).

           
           OUTPUT STREAM str_1 TO VALUE("/usr/coop/" + tt-crapcop.dsdircop +
                                        "/arq/" + aux_nmarqger).
           
           /* Creditos pagos - Nao contempla credito em C/C */
           RUN pi_busca_sequencia (INPUT tt-crapcop.cdcooper , 
                                   INPUT par_cdagenci,
                                   INPUT par_ncaixass,
                                   INPUT 1).
    
           IF   RETURN-VALUE = "NOK"   THEN
                UNDO, RETURN "NOK".

           FOR EACH craplbi WHERE craplbi.cdcooper  = tt-crapcop.cdcooper   AND
                                  craplbi.dtdenvio  = ?                     AND
                                  craplbi.dtdpagto <> ?                     AND
                                  craplbi.cdagenci >= par_cdagenci          AND
                                  craplbi.cdagenci <= aux_cdagefim          AND
                                  craplbi.tpmepgto  = 1 /* Cartao/Recibo */
                                  EXCLUSIVE-LOCK
                                  BREAK BY YEAR(craplbi.dtdpagto)
                                          BY MONTH(craplbi.dtdpagto)
                                            BY craplbi.tpmepgto
                                              BY DAY(craplbi.dtdpagto):
                                              
               /* Busca o registro de pagamento */
               FIND LAST craplpi WHERE craplpi.cdcooper = craplbi.cdcooper   AND
                                       craplpi.nrbenefi = craplbi.nrbenefi   AND
                                       craplpi.nrrecben = craplbi.nrrecben   AND
                                       craplpi.dtmvtolt = craplbi.dtdpagto   AND
                                       craplpi.dtiniper = craplbi.dtiniper   AND
                                       craplpi.dtfimper = craplbi.dtfimper   AND
                                       craplpi.nrseqcre = craplbi.nrseqcre
                                       NO-LOCK NO-ERROR.
                                  
               IF   AVAILABLE craplpi   THEN
                    ASSIGN aux_fmpagben = 
                               craplpi.tppagben. /* Cartao ou Recibo */
               ELSE
                    ASSIGN aux_fmpagben = 0. /* Conta Corrente */
               
               IF   FIRST-OF(craplbi.tpmepgto)   THEN
                    DO:
                        ASSIGN aux_nrseqlot = aux_nrseqlot + 1
                               aux_nrseqreg = aux_nrseqreg + 1
    
                               aux_qttotreg = 0
                               aux_vltotreg = 0.
                     
                        /* Header do lote */
                        PUT STREAM str_1 UNFORMATTED
                            "1"
                            STRING(aux_nrseqreg,"9999999")
                            "01"
                            "756"
                            STRING(craplbi.tpmepgto,"99")
                            SUBSTRING(STRING(par_dtmvtolt,"99999999"),5,4)
                            SUBSTRING(STRING(par_dtmvtolt,"99999999"),3,2)
                            SUBSTRING(STRING(par_dtmvtolt,"99999999"),1,2)
                            STRING(aux_nrseqlot,"99")
                            SUBSTRING(STRING(par_dtmvtolt,"99999999"),5,4)
                            SUBSTRING(STRING(par_dtmvtolt,"99999999"),3,2)
                            "CONPAG"
                            FILL(" ",57)
                            STRING(craptab.dstextab,"x(6)")
                            FILL(" ",140)
                            SKIP.
                    END.
                 
               ASSIGN aux_nrseqreg     = aux_nrseqreg + 1
                      aux_qttotreg     = aux_qttotreg + 1
                      aux_vltotreg     = aux_vltotreg + craplbi.vllanmto
                      craplbi.dtdenvio = par_dtmvtolt.
            
               /* Detalhe */
               PUT STREAM str_1 UNFORMATTED
                          "2"
                          STRING(aux_nrseqreg,"9999999")
                          STRING(craplbi.nrbenefi,"9999999999")
                          SUBSTRING(STRING(craplbi.dtfimper,"99999999"),5,4)
                          SUBSTRING(STRING(craplbi.dtfimper,"99999999"),3,2)
                          SUBSTRING(STRING(craplbi.dtfimper,"99999999"),1,2)
                          SUBSTRING(STRING(craplbi.dtiniper,"99999999"),5,4)
                          SUBSTRING(STRING(craplbi.dtiniper,"99999999"),3,2)
                          SUBSTRING(STRING(craplbi.dtiniper,"99999999"),1,2)
                          STRING(craplbi.nrseqcre,"99")
                          SUBSTRING(STRING(craplbi.dtcalcre,"99999999"),5,4)
                          SUBSTRING(STRING(craplbi.dtcalcre,"99999999"),3,2)
                          SUBSTRING(STRING(craplbi.dtcalcre,"99999999"),1,2)
                          STRING(craplbi.cdorgpag,"999999")
                          STRING(craplbi.vllanmto * 100,"999999999999")
                          STRING(craplbi.tpunimon,"9")
                          SUBSTRING(STRING(craplbi.dtdpagto,"99999999"),5,4)
                          SUBSTRING(STRING(craplbi.dtdpagto,"99999999"),3,2)
                          SUBSTRING(STRING(craplbi.dtdpagto,"99999999"),1,2)
                          FILL(" ",1)
                          STRING(aux_fmpagben,"9")
                          FILL(" ",27)
                          STRING(craplbi.nrrecben,"99999999999")
                          "01"
                          FILL(" ",127)
                          SKIP.
    
               IF   LAST-OF(craplbi.tpmepgto)   THEN
                    DO:
                        ASSIGN aux_nrseqreg = aux_nrseqreg + 1.
                      
                        /* Trailer do lote */
                        PUT STREAM str_1 UNFORMATTED
                            "3"
                            STRING(aux_nrseqreg,"9999999")
                            "01"
                            "756"
                            STRING(aux_qttotreg,"99999999")
                            STRING(aux_vltotreg * 100,"99999999999999999")
                            STRING(aux_nrseqlot,"99")
                            FILL(" ",200)
                            SKIP.
    
                        RUN pi_atualiza_sequencia (INPUT 1).
                    END.
           END.
           /* Fim - Creditos pagos */
    
           /* Creditos nao pagos */
           RUN pi_busca_sequencia (INPUT tt-crapcop.cdcooper, 
                                   INPUT par_cdagenci,
                                   INPUT par_ncaixass,
                                   INPUT 2).
    
           IF   RETURN-VALUE = "NOK"   THEN
                UNDO, RETURN "NOK".
    
           FOR EACH craplbi WHERE craplbi.cdcooper  = tt-crapcop.cdcooper   AND
                                  craplbi.dtdenvio  = ?                     AND
                                  craplbi.dtdpagto  = ?                     AND
                                  craplbi.dtfimpag  < par_dtmvtolt          AND
                                  craplbi.cdagenci >= par_cdagenci          AND
                                  craplbi.cdagenci <= aux_cdagefim
                                  EXCLUSIVE-LOCK
                                  BREAK BY YEAR(craplbi.dtdpagto)
                                          BY MONTH(craplbi.dtdpagto)
                                            BY craplbi.tpmepgto
                                              BY DAY(craplbi.dtdpagto):
                                       
               IF   FIRST-OF(craplbi.tpmepgto)   THEN
                    DO:
                        ASSIGN aux_nrseqlot = aux_nrseqlot + 1
                               aux_nrseqreg = aux_nrseqreg + 1
                 
                               aux_qttotreg = 0
                               aux_vltotreg = 0.
                     
                        /* Header do lote */
                        PUT STREAM str_1 UNFORMATTED
                            "1"
                            STRING(aux_nrseqreg,"9999999")
                            "02"
                            "756"
                            STRING(craplbi.tpmepgto,"99")
                            SUBSTRING(STRING(par_dtmvtolt,"99999999"),5,4)
                            SUBSTRING(STRING(par_dtmvtolt,"99999999"),3,2)
                            SUBSTRING(STRING(par_dtmvtolt,"99999999"),1,2)
                            STRING(aux_nrseqlot,"99")
                            SUBSTRING(STRING(par_dtmvtolt,"99999999"),5,4)
                            SUBSTRING(STRING(par_dtmvtolt,"99999999"),3,2)
                            "CONPAG"
                            FILL(" ",57)
                            STRING(craptab.dstextab,"x(6)")
                            FILL(" ",140)
                            SKIP.
                    END.
                 
               ASSIGN aux_nrseqreg     = aux_nrseqreg + 1
                      aux_qttotreg     = aux_qttotreg + 1
                      aux_vltotreg     = aux_vltotreg + craplbi.vllanmto
                      craplbi.dtdenvio = par_dtmvtolt.
            
               /* Detalhe */
               PUT STREAM str_1 UNFORMATTED
                          "2"
                          STRING(aux_nrseqreg,"9999999")
                          STRING(craplbi.nrbenefi,"9999999999")
                          SUBSTRING(STRING(craplbi.dtfimper,"99999999"),5,4)
                          SUBSTRING(STRING(craplbi.dtfimper,"99999999"),3,2)
                          SUBSTRING(STRING(craplbi.dtfimper,"99999999"),1,2)
                          SUBSTRING(STRING(craplbi.dtiniper,"99999999"),5,4)
                          SUBSTRING(STRING(craplbi.dtiniper,"99999999"),3,2)
                          SUBSTRING(STRING(craplbi.dtiniper,"99999999"),1,2)
                          STRING(craplbi.nrseqcre,"99")
                          SUBSTRING(STRING(craplbi.dtcalcre,"99999999"),5,4)
                          SUBSTRING(STRING(craplbi.dtcalcre,"99999999"),3,2)
                          SUBSTRING(STRING(craplbi.dtcalcre,"99999999"),1,2)
                          STRING(craplbi.cdorgpag,"999999")
                          STRING(craplbi.vllanmto * 100,"999999999999")
                          STRING(craplbi.tpunimon,"9")
                          SUBSTRING(STRING(craplbi.dtfimpag,"99999999"),5,4)
                          SUBSTRING(STRING(craplbi.dtfimpag,"99999999"),3,2)
                          SUBSTRING(STRING(craplbi.dtfimpag,"99999999"),1,2)
                          FILL(" ",1)
                          FILL(" ",28)
                          STRING(craplbi.nrrecben,"99999999999")
                          "04"
                          FILL(" ",127)
                          SKIP.
    
               IF   LAST-OF(craplbi.tpmepgto)   THEN
                    DO:
                        ASSIGN aux_nrseqreg = aux_nrseqreg + 1.
                     
                        /* Trailer do lote */
                        PUT STREAM str_1 UNFORMATTED
                            "3"
                            STRING(aux_nrseqreg,"9999999")
                            "02"
                            "756"
                            STRING(aux_qttotreg,"99999999")
                            STRING(aux_vltotreg * 100,"99999999999999999")
                            STRING(aux_nrseqlot,"99")
                            FILL(" ",200)
                            SKIP.
    
                        RUN pi_atualiza_sequencia (INPUT 2).
                    END.
           END.
           /* Fim - Creditos nao pagos */
        
           /* Atualizacao de dados cadastrais */
           RUN pi_busca_sequencia (INPUT tt-crapcop.cdcooper, 
                                   INPUT par_cdagenci,
                                   INPUT par_ncaixass,
                                   INPUT 30).
    
           IF   RETURN-VALUE = "NOK"   THEN
                UNDO, RETURN "NOK".
    
           FOR EACH crapcbi WHERE crapcbi.cdcooper  = tt-crapcop.cdcooper   AND
                                  crapcbi.dtdenvio  = ?                     AND
                                  crapcbi.cdagenci >= par_cdagenci          AND
                                  crapcbi.cdagenci <= aux_cdagefim          AND
                                  crapcbi.dtatucad <> ?                     AND
                                  crapcbi.cdaltcad  < 90
                                  EXCLUSIVE-LOCK USE-INDEX crapcbi4
                                  BREAK BY crapcbi.tpmepgto
                                          BY crapcbi.dtatucad:
    
                   
               IF   FIRST-OF(crapcbi.tpmepgto)   THEN
                    DO:
                        ASSIGN aux_nrseqlot = aux_nrseqlot + 1
                               aux_nrseqreg = aux_nrseqreg + 1
    
                               aux_qttotreg = 0.
                     
                        /* Header do lote */
                        PUT STREAM str_1 UNFORMATTED
                            "1"
                            STRING(aux_nrseqreg,"9999999")
                            "30"
                            "756"
                            STRING(crapcbi.tpmepgto,"99")
                            SUBSTRING(STRING(par_dtmvtolt,"99999999"),5,4)
                            SUBSTRING(STRING(par_dtmvtolt,"99999999"),3,2)
                            SUBSTRING(STRING(par_dtmvtolt,"99999999"),1,2)
                            STRING(aux_nrseqlot,"99")
                            "CONPAG"
                            FILL(" ",63)
                            STRING(craptab.dstextab,"x(6)")
                            FILL(" ",140)
                            SKIP.
                    END.

               ASSIGN aux_nrseqreg     = aux_nrseqreg + 1
                      aux_qttotreg     = aux_qttotreg + 1
                      crapcbi.dtdenvio = par_dtmvtolt.
            
               /* Detalhe */
               PUT STREAM str_1 UNFORMATTED
                          "2"
                          STRING(aux_nrseqreg,"9999999")
                          STRING(crapcbi.nrbenefi,"9999999999")
                          STRING(crapcbi.cdaginss,"99999999")
                          STRING(crapcbi.cdorgpag,"999999")
                          FILL(" ",1)
                          STRING(crapcbi.nrdconta,"9999999999")
                          FILL(" ",1)
                          STRING(crapcbi.nrnovcta,"9999999999")
                          STRING(crapcbi.cdaltcad,"9")
                          "000000"
                          FILL(" ",11)
                          FILL(" ",28) 
                          STRING(crapcbi.nrrecben,"99999999999")
                          STRING(crapcbi.nrcpfcgc,"99999999999")
                          "00000000"
                          FILL(" ",110)
                          SKIP.
               
               IF   LAST-OF(crapcbi.tpmepgto)   THEN
                    DO:
                        ASSIGN aux_nrseqreg = aux_nrseqreg + 1.
                     
                        /* Trailer do lote */
                        PUT STREAM str_1 UNFORMATTED
                                   "3"
                                   STRING(aux_nrseqreg,"9999999")
                                   "30"
                                   "756"
                                   STRING(aux_qttotreg,"99999999")
                                   STRING(aux_nrseqlot,"99")
                                   FILL(" ",217)
                                   SKIP.
    
                        RUN pi_atualiza_sequencia (INPUT 30).
                    END.
           END.
           /* Fim - Atualizacao de dados cadastrais */
    
        
           /* Solicitacao de dados cadastrais */
           RUN pi_busca_sequencia (INPUT tt-crapcop.cdcooper, 
                                   INPUT par_cdagenci,
                                   INPUT par_ncaixass,
                                   INPUT 31).
    
           IF   RETURN-VALUE = "NOK"   THEN
                UNDO, RETURN "NOK".
    
           FOR EACH crapcbi WHERE crapcbi.cdcooper  = tt-crapcop.cdcooper   AND
                                  crapcbi.dtdenvio  = ?                     AND
                                  crapcbi.cdagenci >= par_cdagenci          AND
                                  crapcbi.cdagenci <= aux_cdagefim          AND
                                  crapcbi.dtatucad <> ?                     AND
                                  crapcbi.cdaltcad  = 92
                                  EXCLUSIVE-LOCK USE-INDEX crapcbi4
                                  BREAK BY crapcbi.tpmepgto
                                          BY crapcbi.dtatucad:

               IF   FIRST-OF(crapcbi.tpmepgto)   THEN
                    DO:
                        ASSIGN aux_nrseqlot = aux_nrseqlot + 1
                               aux_nrseqreg = aux_nrseqreg + 1
                               aux_qttotreg = 0.
                     
                        /* Header do lote */
                        PUT STREAM str_1 UNFORMATTED
                            "1"
                            STRING(aux_nrseqreg,"9999999")
                            "31"
                            "756"
                            STRING(crapcbi.tpmepgto,"99")
                            SUBSTRING(STRING(par_dtmvtolt,"99999999"),5,4)
                            SUBSTRING(STRING(par_dtmvtolt,"99999999"),3,2)
                            SUBSTRING(STRING(par_dtmvtolt,"99999999"),1,2)
                            STRING(aux_nrseqlot,"99")
                            "CONPAG"
                            FILL(" ",63)
                            STRING(craptab.dstextab,"x(6)")
                            FILL(" ",140)
                            SKIP.
                    END.
    
               ASSIGN aux_nrseqreg     = aux_nrseqreg + 1
                      aux_qttotreg     = aux_qttotreg + 1
                      crapcbi.dtdenvio = par_dtmvtolt.
    
               /* Detalhe */
               PUT STREAM str_1 UNFORMATTED
                          "2"
                          STRING(aux_nrseqreg,"9999999")
                          STRING(crapcbi.nrbenefi,"9999999999")
                          FILL(" ",82)
                          STRING(crapcbi.nrrecben,"99999999999")
                          FILL(" ",129)
                          SKIP.

           
               IF   LAST-OF(crapcbi.tpmepgto)   THEN
                    DO:
                        ASSIGN aux_nrseqreg = aux_nrseqreg + 1.
                     
                        /* Trailer do lote */
                        PUT STREAM str_1 UNFORMATTED
                                   "3"
                                   STRING(aux_nrseqreg,"9999999")
                                   "31"
                                   "756"
                                   STRING(aux_qttotreg,"99999999")
                                   STRING(aux_nrseqlot,"99")
                                   FILL(" ",217)
                                   SKIP.
    
                        RUN pi_atualiza_sequencia (INPUT 31).
                    END.
           END.
           /* Fim - Solicitacao de dados cadastrais */
           
           OUTPUT STREAM str_1 CLOSE.
           
           /* Verifica se o arquivo esta vazio e o remove */
           INPUT STREAM str_1 THROUGH VALUE("wc -m /usr/coop/" + 
                                            tt-crapcop.dsdircop + "/arq/" + 
                                            aux_nmarqger + " 2> /dev/null") 
                                            NO-ECHO.
                                                        
           SET STREAM str_1 aux_tamarqui FORMAT "X(78)" WITH WIDTH 80.

           IF   INTEGER(SUBSTRING(aux_tamarqui,1,1)) = 0   THEN
                DO:                
                    UNIX SILENT VALUE("rm /usr/coop/" + tt-crapcop.dsdircop + 
                                      "/arq/" + aux_nmarqger + " 2> /dev/null").
                    INPUT STREAM str_1 CLOSE.
                                              
                    /* Desfaz os sequenciais */
                    UNDO BLOCO_COOPER, NEXT BLOCO_COOPER.
                END.
    
        END. /* Fim DO TRANSACTION */

        /* copia o arquivo para diretorio do BANCOOB */
        UNIX SILENT VALUE("ux2dos < /usr/coop/" + tt-crapcop.dsdircop + 
                          "/arq/" + aux_nmarqger + ' | tr -d "\032"' +
                          " > /micros/" + tt-crapcop.dsdircop +
                          "/bancoob/" + aux_nmarqger + " 2>/dev/null").
                             

        /* Move para o salvar */
        UNIX SILENT VALUE("mv /usr/coop/" + tt-crapcop.dsdircop + "/arq/"    + 
                          aux_nmarqger + " /usr/coop/" + tt-crapcop.dsdircop + 
                          "/salvar 2>/dev/null").
                             

        IF   aux_arqlista = ""   THEN
             ASSIGN aux_arqlista = "/usr/coop/" + tt-crapcop.dsdircop + 
                                   "/salvar/"   + aux_nmarqger.
        ELSE
             ASSIGN aux_arqlista = aux_arqlista + "," + "/usr/coop/" + 
                                   tt-crapcop.dsdircop + "/salvar/" + 
                                   aux_nmarqger.

        /* grava o LOG da geracao (opcao G) */
        DO WHILE TRUE TRANSACTION:
        
           FIND craplog WHERE craplog.cdcooper = tt-crapcop.cdcooper   AND
                              craplog.dttransa = par_dtmvtolt          AND
                              craplog.hrtransa = TIME                  AND
                              craplog.cdoperad = par_cdoperad
                              NO-LOCK NO-ERROR.
                              
           IF   AVAILABLE craplog   THEN
                DO:
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.

           CREATE craplog.

           ASSIGN craplog.dttransa = par_dtmvtolt
                  craplog.hrtransa = TIME
                  craplog.cdoperad = par_cdoperad
                  craplog.dstransa = aux_nmarqger + " - GERADO COM SUCESSO"
                  craplog.nrdconta = 0
                  craplog.cdcooper = tt-crapcop.cdcooper
                  craplog.cdprogra = "PRPREV".
                  
           LEAVE.

        END.
        
        /* Libera os registros */
        RELEASE crapcbi.
        RELEASE craplbi.
        RELEASE craptab.
        RELEASE craplog.

    END. /* FOR EACH tt-crapcop (BLOCO_COOPER) */

    IF aux_arqlista  <> ""   THEN
       UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")    +
                         " " + STRING(TIME,"HH:MM:SS")    + "' --> '"   +
                         "Operador: " + par_cdoperad + " - "            +
                         "gerou os arquivos: " + aux_arqlista           + 
                         " >> log/prprev.log").
    ELSE
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Nenhum arquivo gerado.".
             
             RUN gera_erro (INPUT par_cdcoopss,
                            INPUT par_cdagenss,
                            INPUT par_ncaixass,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".

         END.

    RETURN "OK".

END PROCEDURE. /* gera_arquivos_inss */

PROCEDURE gera_relatorio_processamento:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_progerad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdestin AS CHAR  EXTENT 5                 NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-arquivos.
    DEF  INPUT PARAM TABLE FOR tt-rejeicoes.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    /* para os rejeitados */
    DEF VAR rel_qttotrej    AS INT                                  NO-UNDO.
    DEF VAR rel_vltotrej    AS DEC  FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
    DEF VAR rel_valnitnb    LIKE craplbi.nrrecben                   NO-UNDO.

    FORM tt-arquivos.cdcooper AT   6  LABEL "COOP"
         tt-arquivos.cdagenci AT  17  LABEL "PA "
         tt-arquivos.nmarquiv AT  21  LABEL "ARQUIVO"
         tt-arquivos.dsstatus AT  57  LABEL "STATUS" FORMAT "x(36)"
         WITH DOWN NO-BOX NO-LABEL WIDTH 132 FRAME f_arquivos.

    FORM tt-arquivos.cdcooper AT   6 LABEL "COOP"
         tt-arquivos.cdagenci AT  17 LABEL "PA "
         tt-arquivos.nmarquiv AT  21 LABEL "EXTRATO"
         tt-arquivos.dsstatus AT  57 LABEL "STATUS" FORMAT "x(29)"
         WITH DOWN NO-BOX NO-LABEL WIDTH 132 FRAME f_extrato.

    FORM tt-rejeicoes.cdcooper AT   1 LABEL "Coop"
         tt-rejeicoes.cdagenci AT   8 LABEL "PA "
         tt-rejeicoes.nrdconta AT  12 LABEL "C/C"
         rel_valnitnb          AT  23 LABEL "NIT/NB"
         tt-rejeicoes.nmrecben AT  35 LABEL "Nome"
         tt-rejeicoes.dtinipag AT  64 LABEL "Inicio Pgto"
         tt-rejeicoes.dtfimpag AT  76 LABEL "Final Pgto"
         tt-rejeicoes.vllanmto AT  87 LABEL "Valor"              
                                      FORMAT "z,zzz,zz9.99"
         tt-rejeicoes.dscritic AT 101 LABEL "Motivo da critica"  
                                      FORMAT "x(26)"
         WITH DOWN NO-BOX NO-LABEL WIDTH 132 FRAME f_rejeitados.

    EMPTY TEMP-TABLE tt-erro.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper 
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcop   THEN
         DO:
             ASSIGN aux_cdcritic = 651
                    aux_dscritic = "".
            
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
         
             RETURN "NOK".

         END.
         
    ASSIGN par_cdagenci    = IF par_cdagenci = 0 THEN 999 ELSE par_cdagenci
           aux_nmarqimp    = "rl/crrl473_" + STRING(par_cdagenci) + "_" +
                             STRING(TIME) + ".lst".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

    /* Cdempres = 11 , Relatorio 473 em 132 colunas */
    { sistema/generico/includes/cabrel.i "11" "473" "132" }
       
    
    /* Arquivos de extrato nao podem entrar no for each */                
    FOR EACH tt-arquivos WHERE tt-arquivos.cdagenci <> 0 
                               BY tt-arquivos.cdcooper 
                                BY tt-arquivos.cdagenci
                                 BY tt-arquivos.nmarquiv:
                          
        DISPLAY STREAM str_1 tt-arquivos.cdcooper
                             tt-arquivos.cdagenci
                             tt-arquivos.nmarquiv
                             tt-arquivos.dsstatus
                             WITH FRAME f_arquivos.
                   
        DOWN STREAM str_1 WITH FRAME f_arquivos.

    END.
    
                     
    FOR EACH tt-arquivos WHERE tt-arquivos.cdagenci = 0 
                               BY tt-arquivos.cdcooper
                                BY tt-arquivos.cdagenci
                                 BY tt-arquivos.nmarquiv:
                          
        PUT STREAM str_1 SKIP(1)
                         "ARQUIVO DE EXTRATO"
                         SKIP(1).

        DISPLAY STREAM str_1 tt-arquivos.cdcooper
                             tt-arquivos.cdagenci
                             tt-arquivos.nmarquiv
                             tt-arquivos.dsstatus
                             WITH FRAME f_extrato.
                   
        DOWN STREAM str_1 WITH FRAME f_extrato.

    END.

    /* Creditos Inconsistentes */
    FOR EACH tt-rejeicoes WHERE tt-rejeicoes.cdoperac = 1 
                                NO-LOCK BREAK BY tt-rejeicoes.cdcooper
                                               BY tt-rejeicoes.cdagenci
                                                BY tt-rejeicoes.nrbenefi
                                                 BY tt-rejeicoes.nrrecben
                                                  BY tt-rejeicoes.nmrecben
                                                   BY tt-rejeicoes.dtinipag
                                                    BY tt-rejeicoes.dtfimpag
                                                     BY tt-rejeicoes.vllanmto:
                   
        /* No primeiro registro do FOR EACH */
        IF   FIRST(tt-rejeicoes.cdagenci)   THEN
             PUT STREAM str_1 SKIP(2)
                              "CREDITOS REJEITADOS"
                              SKIP(2).

        ASSIGN rel_valnitnb = 0.

        /* Verifica se o NIT veio zerado e exibe o NB em seu lugar */
        IF (tt-rejeicoes.nrrecben = 0) THEN
            ASSIGN rel_valnitnb = tt-rejeicoes.nrbenefi.
        ELSE 
            ASSIGN rel_valnitnb = tt-rejeicoes.nrrecben.

        DISPLAY STREAM str_1
                tt-rejeicoes.cdcooper
                tt-rejeicoes.cdagenci
                tt-rejeicoes.nrdconta
                rel_valnitnb
                tt-rejeicoes.nmrecben
                tt-rejeicoes.dtinipag
                tt-rejeicoes.dtfimpag
                tt-rejeicoes.vllanmto
                tt-rejeicoes.dscritic
                WITH FRAME f_rejeitados.
                
        DOWN STREAM str_1 WITH FRAME f_rejeitados.
        
        ASSIGN rel_qttotrej = rel_qttotrej + 1
               rel_vltotrej = rel_vltotrej + tt-rejeicoes.vllanmto.
               
    END. /* Fim - Creditos */
    
    /* Nao contabiliza pois nao esta sendo rejeitado, so para mostrar no rel.*/
    FOR EACH tt-rejeicoes WHERE tt-rejeicoes.cdoperac = 999 
                                NO-LOCK BREAK BY tt-rejeicoes.cdcooper
                                               BY tt-rejeicoes.cdagenci
                                                BY tt-rejeicoes.nrbenefi
                                                 BY tt-rejeicoes.nrrecben
                                                  BY tt-rejeicoes.nmrecben
                                                   BY tt-rejeicoes.dtinipag
                                                    BY tt-rejeicoes.dtfimpag
                                                     BY tt-rejeicoes.vllanmto:

        IF   FIRST(tt-rejeicoes.cdagenci)   THEN
             PUT STREAM str_1 SKIP(2)
                        "BLOQUEIO DE CREDITOS PAGOS - EFETURAR ESTORNO MANUAL"
                         SKIP(2).

        ASSIGN rel_valnitnb = 0.

        /* Verifica se o NIT veio zerado e exibe o NB em seu lugar */
        IF (tt-rejeicoes.nrrecben = 0) THEN
            ASSIGN rel_valnitnb = tt-rejeicoes.nrbenefi.
        ELSE 
            ASSIGN rel_valnitnb = tt-rejeicoes.nrrecben.

        DISPLAY STREAM str_1     
                tt-rejeicoes.cdcooper
                tt-rejeicoes.cdagenci
                tt-rejeicoes.nrdconta
                rel_valnitnb
                tt-rejeicoes.nmrecben
                tt-rejeicoes.dtinipag
                tt-rejeicoes.dtfimpag
                tt-rejeicoes.vllanmto
                WITH FRAME f_rejeitados.
                
        DOWN STREAM str_1 WITH FRAME f_rejeitados.


    END. /* BLOQUEIO DE CREDITOS PAGOS NO DIA  */ 

    /* Bloqueios por falta de comprovacao de vida */
    FOR EACH tt-rejeicoes WHERE (tt-rejeicoes.cdoperac = 2  OR
                                 tt-rejeicoes.cdoperac = 3) AND
                                 tt-rejeicoes.cdbloque = 9
                                 NO-LOCK BREAK BY tt-rejeicoes.cdcooper 
                                                BY tt-rejeicoes.cdagenci
                                                 BY tt-rejeicoes.nrbenefi
                                                  BY tt-rejeicoes.nrrecben
                                                   BY tt-rejeicoes.nmrecben
                                                    BY tt-rejeicoes.dtinipag
                                                     BY tt-rejeicoes.dtfimpag
                                                      BY tt-rejeicoes.vllanmto:
                                  
        /* No primeiro registro do FOR EACH */
        IF   FIRST(tt-rejeicoes.cdagenci)   THEN
             PUT STREAM str_1 SKIP(2)
                        "BLOQUEIOS POR FALTA DE COMPROVACAO DE VIDA"
                         SKIP(2).

        ASSIGN rel_valnitnb = 0.

        /* Verifica se o NIT veio zerado e exibe o NB em seu lugar */
        IF (tt-rejeicoes.nrrecben = 0) THEN
            ASSIGN rel_valnitnb = tt-rejeicoes.nrbenefi.
        ELSE 
            ASSIGN rel_valnitnb = tt-rejeicoes.nrrecben.
             
        DISPLAY STREAM str_1  
                tt-rejeicoes.cdcooper
                tt-rejeicoes.cdagenci
                tt-rejeicoes.nrdconta
                rel_valnitnb
                tt-rejeicoes.nmrecben
                tt-rejeicoes.dtinipag
                tt-rejeicoes.dtfimpag
                tt-rejeicoes.vllanmto
                tt-rejeicoes.dscritic
                WITH FRAME f_rejeitados.
                
        DOWN STREAM str_1 WITH FRAME f_rejeitados.

        ASSIGN rel_qttotrej = rel_qttotrej + 1
               rel_vltotrej = rel_vltotrej + tt-rejeicoes.vllanmto.

    END. /* Fim - Bloqueios por falta de comprovacao de vida */

    /* Bloqueios/Desbloqueios */
    FOR EACH tt-rejeicoes WHERE (tt-rejeicoes.cdoperac = 2  OR
                                 tt-rejeicoes.cdoperac = 3) AND
                                 tt-rejeicoes.cdbloque <> 9
                                 NO-LOCK BREAK BY tt-rejeicoes.cdcooper 
                                                BY tt-rejeicoes.cdagenci
                                                 BY tt-rejeicoes.nrbenefi
                                                  BY tt-rejeicoes.nrrecben
                                                   BY tt-rejeicoes.nmrecben
                                                    BY tt-rejeicoes.dtinipag
                                                     BY tt-rejeicoes.dtfimpag
                                                      BY tt-rejeicoes.vllanmto:
                                  
        /* No primeiro registro do FOR EACH */
        IF   FIRST(tt-rejeicoes.cdagenci)   THEN
             PUT STREAM str_1 SKIP(2)
                        "BLOQUEIOS E DESBLOQUEIOS REJEITADOS"
                         SKIP(2).

        ASSIGN rel_valnitnb = 0.

        /* Verifica se o NIT veio zerado e exibe o NB em seu lugar */
        IF (tt-rejeicoes.nrrecben = 0) THEN
            ASSIGN rel_valnitnb = tt-rejeicoes.nrbenefi.
        ELSE 
            ASSIGN rel_valnitnb = tt-rejeicoes.nrrecben.
             
        DISPLAY STREAM str_1  
                tt-rejeicoes.cdcooper
                tt-rejeicoes.cdagenci
                tt-rejeicoes.nrdconta
                rel_valnitnb
                tt-rejeicoes.nmrecben
                tt-rejeicoes.dtinipag
                tt-rejeicoes.dtfimpag
                tt-rejeicoes.vllanmto
                tt-rejeicoes.dscritic
                WITH FRAME f_rejeitados.
                
        DOWN STREAM str_1 WITH FRAME f_rejeitados.

        ASSIGN rel_qttotrej = rel_qttotrej + 1
               rel_vltotrej = rel_vltotrej + tt-rejeicoes.vllanmto.

    END. /* Fim - Bloqueios/Desbloqueios */
   
    
    /* Procuradores */
    FOR EACH tt-rejeicoes WHERE tt-rejeicoes.cdoperac = 4 
                                NO-LOCK BREAK BY tt-rejeicoes.cdcooper 
                                               BY tt-rejeicoes.cdagenci
                                                BY tt-rejeicoes.nrbenefi
                                                 BY tt-rejeicoes.nrrecben
                                                  BY tt-rejeicoes.nmrecben
                                                   BY tt-rejeicoes.dtinipag
                                                    BY tt-rejeicoes.dtfimpag
                                                     BY tt-rejeicoes.vllanmto:
                           
        /* No primeiro registro do FOR EACH */
        IF   FIRST(tt-rejeicoes.cdagenci)   THEN
             PUT STREAM str_1 SKIP(2)
                              "PROCURADORES REJEITADOS"
                              SKIP(2).

        ASSIGN rel_valnitnb = 0.

        /* Verifica se o NIT veio zerado e exibe o NB em seu lugar */
        IF (tt-rejeicoes.nrrecben = 0) THEN
            ASSIGN rel_valnitnb = tt-rejeicoes.nrbenefi.
        ELSE 
            ASSIGN rel_valnitnb = tt-rejeicoes.nrrecben.

        DISPLAY STREAM str_1   
                tt-rejeicoes.cdcooper
                tt-rejeicoes.cdagenci
                tt-rejeicoes.nrdconta
                rel_valnitnb
                tt-rejeicoes.nmrecben
                "" @ tt-rejeicoes.dtinipag
                "" @ tt-rejeicoes.dtfimpag
                "" @ tt-rejeicoes.vllanmto
                tt-rejeicoes.dscritic
                WITH FRAME f_rejeitados.
                
        DOWN STREAM str_1 WITH FRAME f_rejeitados.

        ASSIGN rel_qttotrej = rel_qttotrej + 1
               rel_vltotrej = rel_vltotrej + tt-rejeicoes.vllanmto.

    END. /* Fim - Procuradores */

    IF   rel_qttotrej > 0   THEN
         PUT STREAM str_1 SKIP(2)
                          "TOTAL DE REJEITADOS:"
                          rel_qttotrej
                          "     "
                          rel_vltotrej
                          SKIP.
    
    OUTPUT STREAM str_1 CLOSE.

    /* Imprime o relatorio e copia pro salvar */
    ASSIGN par_nmarqimp = aux_nmarqimp.
    
    UNIX SILENT VALUE("cp " + aux_nmarqimp + " rlnsv/").

    RETURN "OK".

END PROCEDURE. /* gera_relatorio_processamento */

PROCEDURE verifica_arquivos_relatorio_processamento:

    DEF OUTPUT PARAM TABLE FOR tt-arquivos.
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_nmarqdat = "rl/crrl473_*".
     
    INPUT STREAM str_3 THROUGH VALUE( "ls " + aux_nmarqdat + " 2> /dev/null")
          NO-ECHO.

    DO   WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
     
         SET STREAM str_3 aux_nomedarq FORMAT "X(78)" WITH WIDTH 80.
         
         CREATE tt-arquivos.
         ASSIGN tt-arquivos.nmarquiv = 
                   SUBSTRING(aux_nomedarq,(R-INDEX(aux_nomedarq,"/") + 1)).
    END.

    INPUT STREAM str_3 CLOSE.

    RETURN "OK".

END PROCEDURE. /* consulta_relatorio_processamento */

PROCEDURE verifica_arquivos_envio_inss:

    DEF  INPUT PARAM par_cdcoopss AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenss AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_ncaixass AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgvalid AS LOG                            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-arquivos.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-arquivos.
    EMPTY TEMP-TABLE tt-erro.

    RUN pi_carrega_temp_cooperativas (INPUT par_cdcoopss,
                                      INPUT par_cdagenss,
                                      INPUT par_ncaixass,
                                      INPUT par_cdcooper).

    IF   RETURN-VALUE = "NOK"   THEN
         RETURN "NOK".

    FOR EACH tt-crapcop:

        ASSIGN aux_nmarquiv = "/micros/" + tt-crapcop.dsdircop +
                              "/bancoob/0" + 
                              STRING(tt-crapcop.cdagebcb,"9999") + "*.RET*".

        INPUT STREAM str_1 THROUGH VALUE("ls " + aux_nmarquiv + " 2> /dev/null")
              NO-ECHO.

        DO   WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
             
             SET STREAM str_1 aux_nmarquiv FORMAT "X(78)" WITH WIDTH 80.
             
             /*** Verifica se o arquivo esta vazio e o remove ***/
             INPUT STREAM str_2 THROUGH VALUE("wc -m " + aux_nmarquiv + 
                                              " 2> /dev/null") NO-ECHO.
                                                       
             SET STREAM str_2 aux_tamarqui FORMAT "X(78)" WITH WIDTH 80.
                  
             IF  INTEGER(SUBSTRING(aux_tamarqui,1,1)) = 0  THEN
                 DO:
                     INPUT STREAM str_2 CLOSE.
                     NEXT.
                 END.
             
             INPUT STREAM str_2 CLOSE.
                     
             DO   TRANSACTION:
                  CREATE tt-arquivos.
                  ASSIGN tt-arquivos.cdcooper = tt-crapcop.cdcooper
                         tt-arquivos.nmrescop = tt-crapcop.nmrescop
                         tt-arquivos.nmarquiv = aux_nmarquiv.
             END.

             IF  par_flgvalid  THEN 
                 LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */

    END.

    INPUT STREAM str_1 CLOSE.

    RETURN "OK".

END PROCEDURE. /* verifica_arquivos_envio_inss */

PROCEDURE verifica_arquivos_processamento_inss:

    DEF  INPUT PARAM par_cdcoopss AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenss AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_ncaixass AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgvalid AS LOG                            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-arquivos.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-arquivos.
    EMPTY TEMP-TABLE tt-erro.

    /* Valida PA quando for informado */
    IF   par_cdcooper <> 0                               AND 
         par_cdagenci <> 0                               AND
         NOT CAN-FIND(crapage WHERE
                      crapage.cdcooper = par_cdcooper    AND
                      crapage.cdagenci = par_cdagenci)   THEN
         DO:
             ASSIGN aux_cdcritic = 962
                    aux_dscritic = "".
             
             RUN gera_erro (INPUT par_cdcoopss,
                            INPUT par_cdagenss,
                            INPUT par_ncaixass,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.
    
    RUN pi_carrega_temp_cooperativas (INPUT par_cdcoopss,
                                      INPUT par_cdagenss,
                                      INPUT par_ncaixass,
                                      INPUT par_cdcooper).

    IF   RETURN-VALUE = "NOK"   THEN
         RETURN "NOK".
    
    FOR EACH tt-crapcop:

        aux_nmarqtmp = STRING(tt-crapcop.cdagebcb,"9999") + "-".
        
        /* Verificacao para PA SEDE que eh tratado com ZERO */
        IF   par_cdagenci = tt-crapcop.cdagsede   THEN
             aux_nmarqtmp = aux_nmarqtmp + "00".
            
        ELSE
        IF   par_cdagenci = 0   THEN
             aux_nmarqtmp = aux_nmarqtmp + "*".
        ELSE        
             aux_nmarqtmp = aux_nmarqtmp + STRING(par_cdagenci,"999").
                    
        aux_nmarqtmp = aux_nmarqtmp + "INFORBENEFICIOS-*" + ".ZIP".
        
        ASSIGN aux_nmarquiv = "/usr/coop/" + tt-crapcop.dsdircop +  
                              "/integra/" + aux_nmarqtmp.

        INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2>/dev/null")
                           NO-ECHO.
        
        DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
           
           SET STREAM str_1 aux_nmarquiv FORMAT "X(78)" WITH WIDTH 80.

           ASSIGN aux_cdagenci = ENTRY(NUM-ENTRIES(aux_nmarquiv,"/"),
                                       aux_nmarquiv,"/")
                  aux_cdagenci = ENTRY(2,aux_cdagenci,"-")
                  aux_cdagenci = SUBSTRING(aux_cdagenci,1,2)
                  aux_nmarquiv = SUBSTRING(aux_nmarquiv,
                                           R-INDEX(aux_nmarquiv,"/") + 1).
           

           /* Remove os arquivos que ja foram processados */
           IF CAN-FIND(craplog WHERE
                       craplog.cdcooper = tt-crapcop.cdcooper   AND
                       craplog.cdprogra = "PRPREV"              AND
                       craplog.dstransa = aux_nmarquiv +
                                          " - CONCILIADO") THEN
              DO:                                              
                    UNIX SILENT VALUE("rm /usr/coop/" + tt-crapcop.dsdircop +
                                     "/integra/" + aux_nmarquiv +
                                     " 2>/dev/null").

                    NEXT.
              END.      
                                     
              IF CAN-FIND(craplog WHERE
                          craplog.cdcooper = tt-crapcop.cdcooper   AND
                          craplog.cdprogra = "PRPREV"              AND
                          craplog.dstransa = aux_nmarquiv +
                                         " - SEM CONCILIACAO") THEN
                 DO:
                     UNIX SILENT VALUE("rm /usr/coop/" + tt-crapcop.dsdircop +
                                     "/integra/" + aux_nmarquiv +
                                     " 2>/dev/null").

                   NEXT.
                 END.  
                    
           CREATE tt-arquivos.

           ASSIGN tt-arquivos.cdagenci = IF   INT(aux_cdagenci) = 0   THEN
                                              tt-crapcop.cdagsede
                                         ELSE
                                              INT(aux_cdagenci)
                  tt-arquivos.nmarquiv = aux_nmarquiv
                  tt-arquivos.qtnaopag = 0
                  tt-arquivos.vlnaopag = 0
                  tt-arquivos.qtbloque = 0
                  tt-arquivos.vlbloque = 0
                  tt-arquivos.dsstatus = "NAO PROCESSADO - ERRO NA CONCILIACAO"
                  tt-arquivos.cdcooper = tt-crapcop.cdcooper
                  tt-arquivos.nmrescop = tt-crapcop.nmrescop.

           IF  par_flgvalid  THEN 
               LEAVE.
                  
        END.  /*  Fim do DO WHILE TRUE  */
        
        INPUT STREAM str_1 CLOSE.
        
    END.
    
    RETURN "OK".

END PROCEDURE. /* verifica_arquivos_processamento_inss */
                  
PROCEDURE verifica_operador_presoc:
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgtrava AS LOGI /* Trava/libera tela */   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-mensagens.

    EMPTY TEMP-TABLE tt-mensagens.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "GENERI"       AND
                       craptab.cdempres = 0              AND
                       craptab.cdacesso = "presoc"       AND
                       craptab.tpregist = 1
                       NO-LOCK NO-ERROR.
                      
    IF   NOT AVAILABLE craptab   THEN
         DO:
             CREATE craptab.
             ASSIGN craptab.cdcooper = par_cdcooper
                    craptab.nmsistem = "CRED"      
                    craptab.tptabela = "GENERI"          
                    craptab.cdempres = 0
                    craptab.cdacesso = "presoc"
                    craptab.tpregist = 1
                    craptab.dstextab = STRING(par_cdoperad,"x(10)") + " - " +
                                       par_nmoperad.
    
             RELEASE craptab.
             RETURN "OK".
         END.
         
    IF   craptab.dstextab                 <> ""             AND
         SUBSTRING(craptab.dstextab,1,10) <> par_cdoperad   THEN
         DO:
             CREATE tt-mensagens.
             ASSIGN tt-mensagens.nrseqmsg = 1
                    tt-mensagens.dsmensag = "3~Processo sendo utilizado pelo " +
                                            "Operador " + craptab.dstextab.
             CREATE tt-mensagens.
             ASSIGN tt-mensagens.nrseqmsg = 2
                    tt-mensagens.dsmensag = "Aguarde ou pressione F4/END " +
                                            "para sair...".
             
             RETURN "NOK".
         END.
         
    FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "GENERI"       AND
                       craptab.cdempres = 0              AND
                       craptab.cdacesso = "presoc"       AND
                       craptab.tpregist = 1
                       EXCLUSIVE-LOCK NO-ERROR.
                       
    IF   par_flgtrava   THEN
         ASSIGN craptab.dstextab = STRING(par_cdoperad,"x(10)") + " - " +
                                   par_nmoperad.
    ELSE
         ASSIGN craptab.dstextab = "".
    
    RELEASE craptab.

    RETURN "OK".

END PROCEDURE. /* verifica_operador_presoc */

PROCEDURE carrega_cooperativas:

    DEFINE OUTPUT PARAMETER aux_nmcooper     AS CHARACTER NO-UNDO.

    /* Alimenta SELECTION-LIST de COOPERATIVAS */
    FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK:
    
        IF crapcop.cdbcoctl <> 85   THEN   /* Execucao apenas para 85*/
           NEXT. 
    
        IF aux_contador = 0   THEN
           ASSIGN aux_nmcooper = "TODAS,0," + CAPS(crapcop.nmrescop) + "," +
                                              STRING(crapcop.cdcooper)
                  aux_contador = 1.
        ELSE
           ASSIGN aux_nmcooper = aux_nmcooper           + "," + 
                                 CAPS(crapcop.nmrescop) + "," + 
                                 STRING(crapcop.cdcooper).
    END.

    RETURN "OK".

END PROCEDURE. /* carrega_cooperativas */

PROCEDURE gera_relatorio_diferencas_importacao:

    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-dif-import.
    DEF OUTPUT PARAM par_nomedarq AS CHAR                           NO-UNDO.

    FORM tt-dif-import.cdagenci AT  9 LABEL "PA "
     SKIP
     tt-dif-import.nmarquiv AT  5 LABEL "Arquivo"
     SKIP(1)
     "-----------Nao pagos----------  -----------Bloqueados---------"   AT 14
     SKIP
     "      Quant            Valor         Quant             Valor"   AT 14
     SKIP
     tt-dif-import.qtnaopag AT  2 LABEL "Informados" FORMAT "zzz,zzz,zz9"
                            HELP "Informe a quantidade de nao pagos."
     tt-dif-import.vlnaopag                        FORMAT "zzz,zzz,zzz,zz9.99"
                            HELP "Informe o valor de nao pagos."
     tt-dif-import.qtbloque AT 46                    FORMAT "zzz,zzz,zz9"
                            HELP "Informe a quantidade de bloqueados."
     tt-dif-import.vlbloque                          FORMAT "zzz,zzz,zzz,zz9.99"
                            HELP "Informe o valor de bloqueados."
     SKIP
     tt-dif-import.qttotcre AT  2 LABEL "Computados" FORMAT "zzz,zzz,zz9"
     tt-dif-import.vltotcre                          FORMAT "zzz,zzz,zzz,zz9.99"
     tt-dif-import.qttotblq AT 46                    FORMAT "zzz,zzz,zz9"
     tt-dif-import.vltotblq                          FORMAT "zzz,zzz,zzz,zz9.99"
     SKIP(1)
     WITH ROW 10 CENTERED OVERLAY NO-LABELS SIDE-LABELS WIDTH 83
     FRAME f_dados.    

     ASSIGN rel_nomedarq = "rl/prprev" + 
                           STRING(par_dtmvtolt,"999999") + ".txt".

     OUTPUT STREAM str_4 TO VALUE(rel_nomedarq).
             
     DISPLAY STREAM str_4 "RELATORIO DE DIFERENCAS NA IMPORTACAO" AT 10
                          "DOS ARQUIVOS DO BANCOOB - " 
                          STRING(par_dtmvtolt,"99/99/99") + "."
                          WITH WIDTH 132.

     FOR EACH tt-dif-import:
                 
         DISPLAY STREAM str_4 tt-dif-import.cdagenci
                              tt-dif-import.nmarquiv
                              tt-dif-import.qtnaopag
                              tt-dif-import.vlnaopag
                              tt-dif-import.qtbloque
                              tt-dif-import.vlbloque
                              tt-dif-import.qttotcre
                              tt-dif-import.vltotcre
                              tt-dif-import.qttotblq
                              tt-dif-import.vltotblq WITH FRAME f_dados.

         DOWN STREAM str_4 WITH FRAME f_dados.
     END.

     OUTPUT STREAM str_4 CLOSE.

     ASSIGN par_nomedarq = rel_nomedarq.

    RETURN "OK".

END PROCEDURE. /* gera_relatorio_diferencas_importacao */

PROCEDURE pi_extrai_demonstrativos:

    DEF  INPUT PARAM par_cdcoopss AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenss AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_ncaixass AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsdircop AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    
    aux_nmextarq = "-*" + "FSUBDMC13.B756*".
        
    IF   tt-arquivos.cdagenci <> 0   THEN
         NEXT.

    ASSIGN aux_nrdoextr = aux_nrdoextr + 1
           aux_nmarqext = "EXTRATO" + tt-arquivos.nmarquiv.

    /* Extrai o extrato para o integra */
    UNIX SILENT VALUE("zipcecred.pl -silent " +
                      "-extract /usr/coop/" + par_dsdircop + "/integra/" + 
                      tt-arquivos.nmarquiv + " /usr/coop/" + par_dsdircop + 
                      "/integra").

    /* Cria uma copia com a tag EXTRATO no nome */
    UNIX SILENT VALUE("scp /usr/coop/" + par_dsdircop + "/integra/" + 
                      tt-arquivos.nmarquiv + " /usr/coop/" + par_dsdircop + 
                      "/integra/" + aux_nmarqext).

    /* Remove arquivo original */
    UNIX SILENT VALUE("rm /usr/coop/" + par_dsdircop + "/integra/" + 
                      tt-arquivos.nmarquiv + " 2>/dev/null").     
    
    aux_nmarqext = TRIM(tt-arquivos.nmarquiv, ".ZIP").    
    
    RUN pi_processa_demonstrativo (INPUT par_dsdircop).  

    
    /* Remove o extrato extraido */
    UNIX SILENT VALUE("rm /usr/coop/" + par_dsdircop + "/integra/" + 
                      TRIM(tt-arquivos.nmarquiv, ".ZIP") + " 2>/dev/null").
    
    UNIX SILENT VALUE("mv /usr/coop/" + par_dsdircop + "/integra/" + "*" + 
                      tt-arquivos.nmarquiv + 
                      " /usr/coop/" + par_dsdircop + "/integra/" +
                      tt-arquivos.nmarquiv). 
    
    /* Reprocessar extrato */
    IF RETURN-VALUE          = "NOK"         OR
       KEY-FUNCTION(LASTKEY) = "END-ERROR"   THEN
       RETURN "NOK".

    RUN pi_grava_demonstrativo (INPUT par_dtmvtolt,
                                INPUT par_cdoperad). 
    
    IF RETURN-VALUE = "OK"   THEN
       DO:
          /* Grava o LOG do processamento */
          DO WHILE TRUE TRANSACTION:
              
             FIND craplog WHERE 
                  craplog.cdcooper = tt-arquivos.cdcooper   AND
                  craplog.dttransa = par_dtmvtolt           AND
                  craplog.hrtransa = TIME                   AND
                  craplog.cdoperad = par_cdoperad
                  NO-LOCK NO-ERROR.
                                
             IF AVAILABLE craplog   THEN
                DO:
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
             
             CREATE craplog.

             ASSIGN craplog.dttransa = par_dtmvtolt
                    craplog.hrtransa = TIME
                    craplog.cdoperad = par_cdoperad
                    craplog.dstransa = 
                            tt-arquivos.nmarquiv +
                            " - EXTRATO PROCESSADO COM SUCESSO"
                    craplog.nrdconta = 0
                    craplog.cdcooper = tt-arquivos.cdcooper 
                    craplog.cdprogra = "PRPREV".
                    
             
             EMPTY TEMP-TABLE tt-extrato.
             
             LEAVE.

          END.
          
          /* Libera o registro */
          RELEASE craplog.
       
       END.
    ELSE
       RETURN "NOK". /* Reprocessar extrato */

    /* Move demonstrativo processado para diretorio salvar */
    UNIX SILENT VALUE("mv /usr/coop/" + par_dsdircop + "/integra/" + 
                      tt-arquivos.nmarquiv + 
                      " /usr/coop/" + par_dsdircop + "/salvar").

    ASSIGN tt-arquivos.dsstatus = "PROCESSADO".
    
    RETURN "OK".

    
END PROCEDURE. /* pi_extrai_demonstrativos */

PROCEDURE pi_processa_demonstrativo:
    
   DEF  INPUT PARAM par_dsdircop AS CHAR                           NO-UNDO.
                       
   INPUT STREAM str_1 FROM VALUE("/usr/coop/" + par_dsdircop + "/integra/" + 
                                 aux_nmarqext) NO-ECHO.

   /* Registros */
   DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
       IMPORT STREAM str_1 UNFORMATTED aux_setlinha.
   
       /*  Substitui o TAB por espaco  */
       aux_setlinha = REPLACE(aux_setlinha,CHR(9)," ").

       /* Header */
       IF   INT(SUBSTRING(aux_setlinha,1,1)) = 1   THEN
            DO:
               IF   INT(SUBSTRING(aux_setlinha,9,2)) = 50   THEN
                    DO:
                       ASSIGN 
                          aux_cdtplote = INT(SUBSTRING(aux_setlinha,9,2))
                          aux_iddobanc = INT(SUBSTRING(aux_setlinha,11,3))
                          aux_dtgralot = DATE(INT(SUBSTRING(aux_setlinha,18,2)),
                                              INT(SUBSTRING(aux_setlinha,20,2)),
                                              INT(SUBSTRING(aux_setlinha,14,4)))
                          aux_nrseqlot = INT(SUBSTRING(aux_setlinha,22,2))
                          aux_dtcomext = SUBSTRING(aux_setlinha,28,2) + "/" +
                                          SUBSTRING(aux_setlinha,24,4)  
                          aux_nmemiten = SUBSTRING(aux_setlinha,30,40)
                          aux_nrcnpjem = DEC(SUBSTRIN(aux_setlinha,70,14))
                          aux_filler1  = DECI(SUBSTRING(aux_setlinha,84,13))
                          aux_nrctrltr = INT(SUBSTRING(aux_setlinha,97,6))
                          aux_dsclinha[1] = SUBSTRING(aux_setlinha,103,40)
                          aux_dsclinha[2] = SUBSTRING(aux_setlinha,143,40)
                          aux_dsclinha[3] = SUBSTRING(aux_setlinha,183,40)
                          aux_filler2 = INT(SUBSTRING(aux_setlinha,223,128)).

                       NEXT.

                    END. 

            END.

       ELSE
       /* Detalhe */
       IF INT(SUBSTRING(aux_setlinha,1,1)) = 2   THEN
          DO:      
             CREATE tt-extrato.
       
             ASSIGN 
                tt-extrato.cdtplote    = aux_cdtplote
                tt-extrato.iddobanc    = aux_iddobanc
                tt-extrato.dtgralot    = aux_dtgralot
                tt-extrato.nrseqlot    = aux_nrseqlot
                tt-extrato.dtcomext    = aux_dtcomext
                tt-extrato.nmemiten    = aux_nmemiten
                tt-extrato.nrcnpjem    = aux_nrcnpjem
                tt-extrato.filler1     = aux_filler1
                tt-extrato.nrctrltr    = aux_nrctrltr
                tt-extrato.dsclinha[1] = aux_dsclinha[1]
                tt-extrato.dsclinha[2] = aux_dsclinha[2]
                tt-extrato.dsclinha[3] = aux_dsclinha[3]
                tt-extrato.filler2     = aux_filler2
                tt-extrato.nrseqdig    = INT(SUBSTRING(aux_setlinha,2,7))
                tt-extrato.nrrecben    = DEC(SUBSTRING(aux_setlinha,09,11))
                tt-extrato.nrbenefi    = DEC(SUBSTRING(aux_setlinha,20,10))
                tt-extrato.dtiniper    = DATE(INT(SUBSTRING(aux_setlinha,42,2)),
                                              INT(SUBSTRING(aux_setlinha,44,2)),
                                              INT(SUBSTRING(aux_setlinha,38,4)))
                tt-extrato.dtfimper    = DATE(INT(SUBSTRING(aux_setlinha,34,2)),
                                              INT(SUBSTRING(aux_setlinha,36,2)),
                                              INT(SUBSTRING(aux_setlinha,30,4)))
                tt-extrato.nrseqcre    = INT(SUBSTRING(aux_setlinha,46,2))
                tt-extrato.nrespeci    = INT(SUBSTRING(aux_setlinha,48,3))
                tt-extrato.dtinival    = DATE(INT(SUBSTRING(aux_setlinha,55,2)),
                                              INT(SUBSTRING(aux_setlinha,57,2)),
                                              INT(SUBSTRING(aux_setlinha,51,4)))
                tt-extrato.dtfimval    = DATE(INT(SUBSTRING(aux_setlinha,63,2)),
                                              INT(SUBSTRING(aux_setlinha,65,2)),
                                              INT(SUBSTRING(aux_setlinha,59,4)))
                tt-extrato.cdorgpag    = INT(SUBSTRING(aux_setlinha,67,6))
                tt-extrato.tpmepgto    = INT(SUBSTRING(aux_setlinha,73,2))
                tt-extrato.nrcpfcgc    = DEC(SUBSTRING(aux_setlinha,75,11)).
   
             ASSIGN aux_nrdconta = SUBSTRING(aux_setlinha,86,10)
                    aux_nrdconta = REPLACE(aux_nrdconta," ","").
   
             ASSIGN tt-extrato.dsdconta = (IF aux_nrdconta = "" THEN
                                           "" ELSE
                                           aux_nrdconta) NO-ERROR.
   
             /* TRANSFERENCIA DE PA */
             IF   tt-extrato.dsdconta <> ""   THEN
                  IF   tt-arquivos.cdcooper = 1  THEN
                       DO:
                          FIND craptco WHERE 
                               craptco.cdcopant = 2                        AND
                               craptco.nrctaant = INT(tt-extrato.dsdconta) AND
                               craptco.tpctatrf = 1                        AND
                               craptco.flgativo = TRUE                     
                               NO-LOCK NO-ERROR.
                  
                          IF   AVAIL craptco   THEN
                               ASSIGN tt-extrato.dsdconta = 
                                                 STRING(craptco.nrdconta).
                          
                       END.
               
             aux_nrdconta = "".
   
             ASSIGN 
              tt-extrato.imprimsg     = INT(SUBSTRING(aux_setlinha,96,1))
              tt-extrato.nmrecben     = SUBSTRING(aux_setlinha,97,28) 
              tt-extrato.idregcmp     = INT(SUBSTRING(aux_setlinha,125,2))
              tt-extrato.cdlanmto[1]  = INT(SUBSTRING(aux_setlinha,127,3))
              tt-extrato.vllanmto[1]  = DEC(SUBSTRING(aux_setlinha,130,8)) / 100
              tt-extrato.cdlanmto[2]  = INT(SUBSTRING(aux_setlinha,138,3))
              tt-extrato.vllanmto[2]  = DEC(SUBSTRING(aux_setlinha,141,8)) / 100
              tt-extrato.cdlanmto[3]  = INT(SUBSTRING(aux_setlinha,149,3))
              tt-extrato.vllanmto[3]  = DEC(SUBSTRING(aux_setlinha,152,8)) / 100
              tt-extrato.cdlanmto[4]  = INT(SUBSTRING(aux_setlinha,160,3))
              tt-extrato.vllanmto[4]  = DEC(SUBSTRING(aux_setlinha,163,8)) / 100
              tt-extrato.cdlanmto[5]  = INT(SUBSTRING(aux_setlinha,171,3))
              tt-extrato.vllanmto[5]  = DEC(SUBSTRING(aux_setlinha,174,8)) / 100
              tt-extrato.cdlanmto[6]  = INT(SUBSTRING(aux_setlinha,182,3))
              tt-extrato.vllanmto[6]  = DEC(SUBSTRING(aux_setlinha,185,8)) / 100
              tt-extrato.cdlanmto[7]  = INT(SUBSTRING(aux_setlinha,193,3))
              tt-extrato.vllanmto[7]  = DEC(SUBSTRING(aux_setlinha,196,8)) / 100
              tt-extrato.cdlanmto[8]  = INT(SUBSTRING(aux_setlinha,204,3))
              tt-extrato.vllanmto[8]  = DEC(SUBSTRING(aux_setlinha,207,8)) / 100
              tt-extrato.cdlanmto[9]  = INT(SUBSTRING(aux_setlinha,215,3))
              tt-extrato.vllanmto[9]  = DEC(SUBSTRING(aux_setlinha,218,8)) / 100
              tt-extrato.cdlanmto[10] = INT(SUBSTRING(aux_setlinha,226,3))
              tt-extrato.vllanmto[10] = DEC(SUBSTRING(aux_setlinha,229,8)) / 100
              tt-extrato.cdlanmto[11] = INT(SUBSTRING(aux_setlinha,237,3))
              tt-extrato.vllanmto[11] = DEC(SUBSTRING(aux_setlinha,240,8)) / 100
              tt-extrato.cdlanmto[12] = INT(SUBSTRING(aux_setlinha,248,3))
              tt-extrato.vllanmto[12] = DEC(SUBSTRING(aux_setlinha,251,8)) / 100
              tt-extrato.cdlanmto[13] = INT(SUBSTRING(aux_setlinha,259,3))
              tt-extrato.vllanmto[13] = DEC(SUBSTRING(aux_setlinha,262,8)) / 100
              tt-extrato.vlrbruto     = DEC(SUBSTRING(aux_setlinha,270,8)) / 100
              tt-extrato.vlrdesco     = DEC(SUBSTRING(aux_setlinha,278,8)) / 100
              tt-extrato.vlrliqui     = DEC(SUBSTRING(aux_setlinha,286,8)) / 100
              tt-extrato.filler3      = INT(SUBSTRING(aux_setlinha,294,57)).
              
   
             NEXT.

       END.
       ELSE
       /* Rubricas */
       IF INT(SUBSTRING(aux_setlinha,1,1)) = 3   THEN
          DO: 
             
             ASSIGN 
              tt-extrato.cdlanmto[14]= INT(SUBSTRING(aux_setlinha,50,3))
              tt-extrato.vllanmto[14] = DEC(SUBSTRING(aux_setlinha,53,8)) / 100
              tt-extrato.cdlanmto[15] = INT(SUBSTRING(aux_setlinha,61,3))
              tt-extrato.vllanmto[15] = DEC(SUBSTRING(aux_setlinha,64,8)) / 100
              tt-extrato.cdlanmto[16] = INT(SUBSTRING(aux_setlinha,72,3))
              tt-extrato.vllanmto[16] = DEC(SUBSTRING(aux_setlinha,75,8)) / 100
              tt-extrato.cdlanmto[17] = INT(SUBSTRING(aux_setlinha,83,3))
              tt-extrato.vllanmto[17] = DEC(SUBSTRING(aux_setlinha,86,8)) / 100
              tt-extrato.cdlanmto[18] = INT(SUBSTRING(aux_setlinha,94,3))
              tt-extrato.vllanmto[18] = DEC(SUBSTRING(aux_setlinha,97,8)) / 100
              tt-extrato.cdlanmto[19] = INT(SUBSTRING(aux_setlinha,105,3))
              tt-extrato.vllanmto[19] = DEC(SUBSTRING(aux_setlinha,108,8)) / 100
              tt-extrato.cdlanmto[20] = INT(SUBSTRING(aux_setlinha,116,3))
              tt-extrato.vllanmto[20] = DEC(SUBSTRING(aux_setlinha,119,8)) / 100
              tt-extrato.cdlanmto[21] = INT(SUBSTRING(aux_setlinha,127,3))
              tt-extrato.vllanmto[21] = DEC(SUBSTRING(aux_setlinha,130,8)) / 100
              tt-extrato.cdlanmto[22] = INT(SUBSTRING(aux_setlinha,138,3))
              tt-extrato.vllanmto[22] = DEC(SUBSTRING(aux_setlinha,141,8)) / 100
              tt-extrato.cdlanmto[23] = INT(SUBSTRING(aux_setlinha,149,3))
              tt-extrato.vllanmto[23] = DEC(SUBSTRING(aux_setlinha,152,8)) / 100
              tt-extrato.cdlanmto[24] = INT(SUBSTRING(aux_setlinha,160,3))
              tt-extrato.vllanmto[24] = DEC(SUBSTRING(aux_setlinha,163,8)) / 100
              tt-extrato.cdlanmto[25] = INT(SUBSTRING(aux_setlinha,171,3))
              tt-extrato.vllanmto[25] = DEC(SUBSTRING(aux_setlinha,174,8)) / 100
              tt-extrato.cdlanmto[26] = INT(SUBSTRING(aux_setlinha,182,3))
              tt-extrato.vllanmto[26] = DEC(SUBSTRING(aux_setlinha,185,8)) / 100
              tt-extrato.cdlanmto[27] = INT(SUBSTRING(aux_setlinha,193,3))
              tt-extrato.vllanmto[27] = DEC(SUBSTRING(aux_setlinha,196,8)) / 100
              tt-extrato.cdlanmto[28] = INT(SUBSTRING(aux_setlinha,204,3))
              tt-extrato.vllanmto[28] = DEC(SUBSTRING(aux_setlinha,207,8)) / 100
              tt-extrato.cdlanmto[29] = INT(SUBSTRING(aux_setlinha,215,3))
              tt-extrato.vllanmto[29] = DEC(SUBSTRING(aux_setlinha,218,8)) / 100
              tt-extrato.cdlanmto[30] = INT(SUBSTRING(aux_setlinha,226,3))
              tt-extrato.vllanmto[30] = DEC(SUBSTRING(aux_setlinha,229,8)) / 100
              tt-extrato.cdlanmto[31] = INT(SUBSTRING(aux_setlinha,237,3))
              tt-extrato.vllanmto[31] = DEC(SUBSTRING(aux_setlinha,240,8)) / 100
              tt-extrato.cdlanmto[32] = INT(SUBSTRING(aux_setlinha,248,3))
              tt-extrato.vllanmto[32] = DEC(SUBSTRING(aux_setlinha,251,8)) / 100
              tt-extrato.cdlanmto[33] = INT(SUBSTRING(aux_setlinha,259,3))
              tt-extrato.vllanmto[33] = DEC(SUBSTRING(aux_setlinha,262,8)) / 100
              tt-extrato.filler4 = INT(SUBSTRING(aux_setlinha,270,81)).
       
             NEXT.
         
          END.
       ELSE
       /* Trailer */
       IF INT(SUBSTRING(aux_setlinha,1,1)) = 4   THEN
          DO:     
                 
             ASSIGN 
                 tt-extrato.qtregdet = INT(SUBSTRING(aux_setlinha,14,8))
                 tt-extrato.vlbrtdet = DEC(SUBSTRING(aux_setlinha,22,17)) / 100
                 tt-extrato.vldscdet = DEC(SUBSTRING(aux_setlinha,39,17)) / 100
                 tt-extrato.vlliqdet = DEC(SUBSTRING(aux_setlinha,56,17)) / 100
                 tt-extrato.filler5  = INT(SUBSTRING(aux_setlinha,75,276)).
       
             NEXT.
                 
          END.

   END.

   INPUT STREAM str_1 CLOSE.
   
   RETURN "OK".

END PROCEDURE. /* pi_processa_demonstrativo */

PROCEDURE pi_grava_demonstrativo:

    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    

    FOR EACH crapcop NO-LOCK:

        FOR EACH crapage WHERE crapage.cdcooper = crapcop.cdcooper AND
                               crapage.cdorgpag <> 0           
                               NO-LOCK:
            
            FOR EACH tt-extrato WHERE tt-extrato.cdorgpag = crapage.cdorgpag:  

                FIND crapcbi WHERE crapcbi.cdcooper = crapage.cdcooper       AND
                                   crapcbi.nrrecben = tt-extrato.nrrecben    AND
                                   crapcbi.nrbenefi = tt-extrato.nrbenefi    AND
                                   crapcbi.nrdconta = INT(tt-extrato.dsdconta)
                                   NO-LOCK NO-ERROR. 
                    
                IF AVAIL crapcbi   THEN
                   DO:
                       FIND crapcei WHERE 
                            crapcei.cdcooper = crapcbi.cdcooper   AND 
                            crapcei.nrrecben = crapcbi.nrrecben   AND
                            crapcei.nrbenefi = crapcbi.nrbenefi   AND
                            crapcei.dtcomext = tt-extrato.dtcomext
                            EXCLUSIVE-LOCK NO-ERROR.
                      
                       IF NOT AVAIL crapcei   THEN
                          DO:
                              CREATE crapcei.

                              ASSIGN crapcei.cdcooper = crapcbi.cdcooper
                                     crapcei.nrrecben = crapcbi.nrrecben
                                     crapcei.nrbenefi = crapcbi.nrbenefi
                                     crapcei.dtcomext = tt-extrato.dtcomext
                                     crapcei.dtfimper = tt-extrato.dtfimper
                                     crapcei.dtiniper = tt-extrato.dtiniper
                                     crapcei.nrseqcre = tt-extrato.nrseqcre
                                     crapcei.nrespeci = tt-extrato.nrespeci
                                     crapcei.cdorgpag = tt-extrato.cdorgpag
                                     crapcei.tpmepgto = tt-extrato.tpmepgto
                                     crapcei.nrcpfcgc = tt-extrato.nrcpfcgc
                                     crapcei.dsdconta = STRING(crapcbi.nrdconta)
                                     crapcei.nmrecben = tt-extrato.nmrecben
                                     crapcei.nmemiten = tt-extrato.nmemiten
                                     crapcei.nrcnpjem = tt-extrato.nrcnpjem
                                     crapcei.vlrbruto = tt-extrato.vlrbruto
                                     crapcei.vlrdesco = tt-extrato.vlrdesco
                                     crapcei.vlrliqui = tt-extrato.vlrliqui
                                     crapcei.dslinha1 = tt-extrato.dsclinha[1]
                                     crapcei.dslinha2 = tt-extrato.dsclinha[2]
                                     crapcei.dslinha3 = tt-extrato.dsclinha[3]
                                     crapcei.dtmvtolt = par_dtmvtolt
                                     crapcei.cdoperad = par_cdoperad
                                     crapcei.dtgralot = tt-extrato.dtgralot.
        
                              DO aux_contador = 1 TO 33:
                                                    
                                 IF tt-extrato.cdlanmto[aux_contador] <> 0 AND
                                    tt-extrato.vllanmto[aux_contador] <> 0 THEN
                                    DO: 
                                        FIND craplei WHERE 
                                             craplei.cdcooper = 
                                                     crapcbi.cdcooper   AND
                                             craplei.nrrecben =         
                                                     crapcbi.nrrecben   AND  
                                             craplei.nrbenefi =         
                                                     crapcbi.nrbenefi   AND
                                             craplei.dtcomext =         
                                                     crapcei.dtcomext   AND
                                             craplei.nrseqdig = aux_contador
                                             EXCLUSIVE-LOCK NO-ERROR.
                                             
                                        IF NOT AVAIL craplei THEN
                                           DO:
                                              CREATE craplei.

                                              ASSIGN 
                                              craplei.cdcooper = crapcbi.cdcooper
                                              craplei.nrrecben = crapcbi.nrrecben
                                              craplei.nrbenefi = crapcbi.nrbenefi
                                              craplei.dtcomext = 
                                                      tt-extrato.dtcomext
                                              craplei.nrseqdig = aux_contador
                                              craplei.cdlanmto = 
                                                tt-extrato.cdlanmto[aux_contador]
                                              craplei.vllanmto = 
                                                tt-extrato.vllanmto[aux_contador]
                                              craplei.cdoperad = par_cdoperad
                                              craplei.dtmvtolt = par_dtmvtolt.

                                           END.
        
                                    END. /* IF tt-extrato.cdlanmto... */
                              
                              END. /* DO aux_contador = 1 TO 33: */
                          
                          END. /* IF   NOT AVAIL crapcei   THEN */
                   
                   END. /* IF   AVAIL crapcbi */
                ELSE
                   DO:     
                       FIND crapcei WHERE 
                            crapcei.cdcooper = crapage.cdcooper    AND 
                            crapcei.nrrecben = tt-extrato.nrrecben AND
                            crapcei.nrbenefi = tt-extrato.nrbenefi AND
                            crapcei.dtcomext = tt-extrato.dtcomext
                            EXCLUSIVE-LOCK NO-ERROR.
                      
                       IF NOT AVAIL crapcei   THEN
                          DO:
                              CREATE crapcei.

                              ASSIGN crapcei.cdcooper = crapage.cdcooper
                                     crapcei.nrrecben = tt-extrato.nrrecben
                                     crapcei.nrbenefi = tt-extrato.nrbenefi
                                     crapcei.dtcomext = tt-extrato.dtcomext
                                     crapcei.dtfimper = tt-extrato.dtfimper
                                     crapcei.dtiniper = tt-extrato.dtiniper
                                     crapcei.nrseqcre = tt-extrato.nrseqcre
                                     crapcei.nrespeci = tt-extrato.nrespeci
                                     crapcei.cdorgpag = tt-extrato.cdorgpag
                                     crapcei.tpmepgto = tt-extrato.tpmepgto
                                     crapcei.nrcpfcgc = tt-extrato.nrcpfcgc
                                     crapcei.dsdconta = tt-extrato.dsdconta
                                     crapcei.nmrecben = tt-extrato.nmrecben
                                     crapcei.nmemiten = tt-extrato.nmemiten
                                     crapcei.nrcnpjem = tt-extrato.nrcnpjem
                                     crapcei.vlrbruto = tt-extrato.vlrbruto
                                     crapcei.vlrdesco = tt-extrato.vlrdesco
                                     crapcei.vlrliqui = tt-extrato.vlrliqui
                                     crapcei.dslinha1 = tt-extrato.dsclinha[1]
                                     crapcei.dslinha2 = tt-extrato.dsclinha[2]
                                     crapcei.dslinha3 = tt-extrato.dsclinha[3]
                                     crapcei.dtmvtolt = par_dtmvtolt
                                     crapcei.cdoperad = par_cdoperad
                                     crapcei.dtgralot = tt-extrato.dtgralot.
                                     
                              DO aux_contador = 1 TO 33:
                                                 
                                 IF tt-extrato.cdlanmto[aux_contador] <> 0 AND
                                    tt-extrato.vllanmto[aux_contador] <> 0 THEN
                                    DO:
                                        FIND craplei WHERE 
                                             craplei.cdcooper = 
                                                     crapage.cdcooper       AND
                                             craplei.nrrecben = 
                                                     tt-extrato.nrrecben    AND
                                             craplei.nrbenefi = 
                                                     tt-extrato.nrbenefi    AND
                                             craplei.dtcomext = 
                                                     crapcei.dtcomext       AND
                                             craplei.nrseqdig = aux_contador
                                             EXCLUSIVE-LOCK NO-ERROR.
                                         
                                        IF NOT AVAIL craplei THEN
                                           DO: 
                                              CREATE craplei.

                                              ASSIGN 
                                              craplei.cdcooper = 
                                                      crapage.cdcooper
                                              craplei.nrrecben = 
                                                      tt-extrato.nrrecben
                                              craplei.nrbenefi = 
                                                      tt-extrato.nrbenefi
                                              craplei.dtcomext = 
                                                      tt-extrato.dtcomext
                                              craplei.nrseqdig = aux_contador
                                              craplei.cdlanmto = 
                                                tt-extrato.cdlanmto[aux_contador]
                                              craplei.vllanmto = 
                                                tt-extrato.vllanmto[aux_contador]
                                              craplei.cdoperad = par_cdoperad
                                              craplei.dtmvtolt = par_dtmvtolt.

                                           END.
                                          
                                    END. /* IF tt-extrato.cdlanmto ... */
                              
                              END. /* DO aux_contador = 1 TO 33: */
                    
                          END. /* IF   NOT AVAIL crapcei */
                   
                   END. /* ELSE (IF   AVAIL crapcbi) */
        
            END. /* FOR EACH tt-extrato */
        
        END. /* FOR EACH crapage */

    END.

    RELEASE crapcei.
    RELEASE craplei.

    RETURN "OK". 

END PROCEDURE. /* pi_grava_demonstrativo */

PROCEDURE pi_processa_arquivo_inss:

    DEF  INPUT PARAM par_cdcoopss AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenss AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_ncaixass AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmrescop AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdircop AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_concilia AS CHAR                           NO-UNDO.
    
    EMPTY TEMP-TABLE tt-craplbi.
    EMPTY TEMP-TABLE tt-crapcbi.
    EMPTY TEMP-TABLE tt-crappbi.

    ASSIGN aux_qttotcre = 0
           aux_vltotcre = 0
           aux_qttotblq = 0
           aux_vltotblq = 0
           aux_qttotdbl = 0
           aux_vltotdbl = 0.

    
    INPUT STREAM str_1 FROM VALUE("/usr/coop/" + par_dsdircop + "/integra/" + 
                                  aux_nmarqext + "_" +
                                  STRING(tt-arquivos.cdagenci,"999")) NO-ECHO.

    /* Registros */
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

        IMPORT STREAM str_1 UNFORMATTED aux_setlinha.


        /* Creditos */
        IF   INT(SUBSTRING(aux_setlinha,9,2)) = 20   THEN
             DO:
                 /* Header */
                 IF   INT(SUBSTRING(aux_setlinha,1,1)) = 1   THEN
                      DO:
                          /* Tipo de pagamento */
                          ASSIGN aux_tpmepgto =
                                     INT(SUBSTRING(aux_setlinha,14,2))
                                 aux_qtdcredi = 0
                                 aux_vldcredi = 0.
                          NEXT.
                      END.

                 /* Trailer */
                 IF   INT(SUBSTRING(aux_setlinha,1,1)) = 3   THEN
                      DO:
                          IF   aux_qtdcredi <> 
                                 INT(SUBSTRING(aux_setlinha,14,8))         OR
                               aux_vldcredi <>
                                 DEC(SUBSTRING(aux_setlinha,22,17)) / 100  THEN
                               DO:
                                   CREATE tt-mensagens.
                                   ASSIGN 
                                       tt-mensagens.nrseqmsg = aux_nrseqmsg
                                       aux_nrseqmsg          = aux_nrseqmsg + 1
                                       tt-mensagens.dsmensag = 
                                              "ATENCAO!! Total de registros " +
                                              "de creditos nao conferem. "    +
                                              "Arquivo:" + tt-arquivos.nmarquiv.
                                           
                                   aux_flgderro = YES.        
                               END.

                          NEXT.
                      END.
                 
                 /* TRANSFERENCIA DE PA */
                 IF   tt-arquivos.cdcooper = 1    AND
                      tt-arquivos.cdagenci = 58   THEN
                      DO:
                          FIND craptco WHERE 
                               craptco.cdcopant = 2                       AND
                               craptco.nrctaant =
                                       INT(SUBSTRING(aux_setlinha,83,10)) AND
                               craptco.tpctatrf = 1                       AND
                               craptco.flgativo = TRUE                    
                               NO-LOCK NO-ERROR.
                
                          IF   AVAIL craptco   THEN
                               ASSIGN aux_nrdcont2 = craptco.nrdconta.
                          ELSE
                               ASSIGN aux_nrdcont2 = 
                                      INT(SUBSTRING(aux_setlinha,83,10)).
                      END.
                 ELSE
                      ASSIGN aux_nrdcont2 = INT(SUBSTRING(aux_setlinha,83,10)).

                 CREATE tt-craplbi.
                 ASSIGN 
                     tt-craplbi.cdcooper = tt-arquivos.cdcooper
                     tt-craplbi.cdagenci = tt-arquivos.cdagenci
                     tt-craplbi.nrrecben = DEC(SUBSTRING(aux_setlinha,101,11))
                     tt-craplbi.tpcredit = INT(SUBSTRING(aux_setlinha,112,2))
                     tt-craplbi.nrbenefi = DEC(SUBSTRING(aux_setlinha,11,10))
                     tt-craplbi.dtfimper = 
                             DATE(INT(SUBSTRING(aux_setlinha,25,2)),
                                  INT(SUBSTRING(aux_setlinha,27,2)),
                                  INT(SUBSTRING(aux_setlinha,21,4)))
                     tt-craplbi.dtiniper = 
                             DATE(INT(SUBSTRING(aux_setlinha,33,2)),
                                  INT(SUBSTRING(aux_setlinha,35,2)),
                                  INT(SUBSTRING(aux_setlinha,29,4)))
                     tt-craplbi.nrseqcre = INT(SUBSTRING(aux_setlinha,37,02))
                     tt-craplbi.dtcalcre =
                             DATE(INT(SUBSTRING(aux_setlinha,43,2)),
                                  INT(SUBSTRING(aux_setlinha,45,2)),
                                  INT(SUBSTRING(aux_setlinha,39,4)))
                     tt-craplbi.cdorgpag = INT(SUBSTRING(aux_setlinha,47,06))
                     tt-craplbi.vllanmto = 
                             DEC(SUBSTRING(aux_setlinha,53,12)) / 100
                     tt-craplbi.tpunimon = INT(SUBSTRING(aux_setlinha,65,01))
                     tt-craplbi.dtfimpag = 
                             DATE(INT(SUBSTRING(aux_setlinha,70,2)),
                                  INT(SUBSTRING(aux_setlinha,72,2)),
                                  INT(SUBSTRING(aux_setlinha,66,4)))
                     tt-craplbi.dtinipag = 
                             DATE(INT(SUBSTRING(aux_setlinha,78,2)),
                                  INT(SUBSTRING(aux_setlinha,80,2)),
                                  INT(SUBSTRING(aux_setlinha,74,4)))
                     tt-craplbi.nrdconta = aux_nrdcont2
                     tt-craplbi.tporiorc = INT(SUBSTRING(aux_setlinha,93,02))
                     tt-craplbi.tpagenci = INT(SUBSTRING(aux_setlinha,95,01))
                     tt-craplbi.nrespeci = INT(SUBSTRING(aux_setlinha,114,03))
                     tt-craplbi.tprecben = INT(SUBSTRING(aux_setlinha,117,01))
                     tt-craplbi.cdbloque = INT(SUBSTRING(aux_setlinha,142,02))
                     tt-craplbi.tpmepgto = aux_tpmepgto
                     tt-craplbi.dtmvtolt = par_dtmvtolt
                     tt-craplbi.cdoperad = par_cdoperad
                     tt-craplbi.dtdpagto = ?
                     tt-craplbi.cdsitcre = INT(SUBSTRING(aux_setlinha,82,01))
                     tt-craplbi.cdoperac = 1 /* Credito */
                     
                     aux_qtdcredi     = aux_qtdcredi + 1
                     aux_vldcredi     = aux_vldcredi + tt-craplbi.vllanmto

                     aux_qttotcre     = aux_qttotcre + 1
                     aux_vltotcre     = aux_vltotcre + tt-craplbi.vllanmto.
                        
                 /* Para pagamentos via cartao/recibo, calcula a cpmf */
                 IF   tt-craplbi.tpmepgto = 1   THEN
                      DO:
                          /* BO com o calculo do CPMF */
                          RUN siscaixa/web/dbo/b1crap85.p 
                                               PERSISTENT SET h_b1crap85.
                          
                          RUN calcula_cpmf IN h_b1crap85
                                             (INPUT  par_nmrescop,
                                              INPUT  tt-craplbi.cdagenci,
                                              INPUT  0,
                                              INPUT  par_dtmvtolt,
                                              INPUT  tt-craplbi.vllanmto,
                                              OUTPUT aux_vlliquid,
                                              OUTPUT aux_vldoipmf,
                                              OUTPUT aux_cfrvipmf).
                        
                          DELETE PROCEDURE h_b1crap85.
                          
                          ASSIGN tt-craplbi.vlliqcre = aux_vlliquid.
                      END.
                 ELSE
                      ASSIGN tt-craplbi.vlliqcre = tt-craplbi.vllanmto.
             END.
        ELSE
        /* Cadastros */
        IF   INT(SUBSTRING(aux_setlinha,9,2)) = 21   THEN
             DO:
                 /* Header */
                 IF   INT(SUBSTRING(aux_setlinha,1,1)) = 1   THEN
                      DO:
                          /* Tipo de pagamento */
                          ASSIGN aux_tpmepgto =
                                     INT(SUBSTRING(aux_setlinha,14,2))
                                 aux_qtdcadas = 0.
                               
                          NEXT.
                      END.
                
                 /* Trailer */
                 IF   INT(SUBSTRING(aux_setlinha,1,1)) = 3   THEN
                      DO:
                          IF   aux_qtdcadas <>
                                   INT(SUBSTRING(aux_setlinha,14,8))   THEN
                               DO:
                                   CREATE tt-mensagens.
                                   ASSIGN 
                                       tt-mensagens.nrseqmsg = aux_nrseqmsg
                                       aux_nrseqmsg          = aux_nrseqmsg + 1
                                       tt-mensagens.dsmensag = 
                                              "ATENCAO!! Total de registros " +
                                              "de cadastro nao conferem. "    +
                                              "Arquivo:" + tt-arquivos.nmarquiv.

                                   aux_flgderro = YES.      
                               END.
                               
                          NEXT.
                      END.
                 
                 /*** Tratamento para zeros na data de nascimento ***/
                 ASSIGN aux_dtnasben = SUBSTRING(aux_setlinha,177,8).
                 
                 IF  (SUBSTRING(aux_dtnasben,1,4)) = "0000" THEN
                     aux_dtnasben =  REPLACE(aux_dtnasben, 
                                          SUBSTRING(aux_dtnasben,1,4), "0001").
                 IF  (SUBSTRING(aux_dtnasben,5,2)) = "00" THEN
                     aux_dtnasben =  REPLACE(aux_dtnasben, 
                                          SUBSTRING(aux_dtnasben,5,2), "01").
                 IF  (SUBSTRING(aux_dtnasben,7,2)) = "00" THEN
                     aux_dtnasben =  REPLACE(aux_dtnasben, 
                                          SUBSTRING(aux_dtnasben,7,2), "01").

                  /* TRANSFERENCIA DE PA */
                  IF   tt-arquivos.cdcooper = 1    AND
                       tt-arquivos.cdagenci = 58   THEN
                       DO:
                           FIND craptco WHERE 
                                craptco.cdcopant = 2                       AND
                                craptco.nrctaant = 
                                        INT(SUBSTRING(aux_setlinha,39,10)) AND
                                craptco.tpctatrf = 1                       AND
                                craptco.flgativo = TRUE                    
                                NO-LOCK NO-ERROR.
                  
                           IF   AVAIL craptco   THEN
                                ASSIGN aux_nrdcont2 = craptco.nrdconta.
                           ELSE
                                ASSIGN aux_nrdcont2 = 
                                       INT(SUBSTRING(aux_setlinha,39,10)).
                       END.
                  ELSE
                       ASSIGN aux_nrdcont2 = 
                              INT(SUBSTRING(aux_setlinha,39,10)).
                           
                 CREATE tt-crapcbi.
                 ASSIGN 
                     tt-crapcbi.cdcooper = tt-arquivos.cdcooper
                     tt-crapcbi.cdagenci = tt-arquivos.cdagenci
                     tt-crapcbi.dtmvtolt = par_dtmvtolt
                     tt-crapcbi.cdoperad = par_cdoperad
                     tt-crapcbi.cdaginss = INT(SUBSTRING(aux_setlinha,30,08))
                     tt-crapcbi.nrdconta = aux_nrdcont2
                     tt-crapcbi.tppresta = INT(SUBSTRING(aux_setlinha,38,01))
                     tt-crapcbi.nmrecben = SUBSTRING(aux_setlinha,73,28)
                     tt-crapcbi.nrrecben = DEC(SUBSTRING(aux_setlinha,101,11))
                     tt-crapcbi.nrbenefi = DEC(SUBSTRING(aux_setlinha,11,10))
                     tt-crapcbi.cdorgpag = INT(SUBSTRING(aux_setlinha,21,06))
                     tt-crapcbi.nrespeci = INT(SUBSTRING(aux_setlinha,27,03))
                     tt-crapcbi.dsendben = SUBSTRING(aux_setlinha,112,40)
                     tt-crapcbi.nmbairro = SUBSTRING(aux_setlinha,152,17)
                     tt-crapcbi.nrcepend = INT(SUBSTRING(aux_setlinha,169,08))
                     tt-crapcbi.dtnasben = 
                              IF INT(SUBSTRING(aux_setlinha,177,8)) = 0 THEN
                                  01/01/1960
                              ELSE    
                                  DATE(INT(SUBSTRING(aux_dtnasben,5,2)),
                                       INT(SUBSTRING(aux_dtnasben,7,2)),
                                       INT(SUBSTRING(aux_dtnasben,1,4)))

                     tt-crapcbi.nmmaeben = SUBSTRING(aux_setlinha,185,32)
                     tt-crapcbi.nrdiauti = INT(SUBSTRING(aux_setlinha,217,02))
                     tt-crapcbi.tpcadast = INT(SUBSTRING(aux_setlinha,219,02))
                     tt-crapcbi.dtatuend =
                             DATE(INT(SUBSTRING(aux_setlinha,225,2)),
                                  INT(SUBSTRING(aux_setlinha,227,2)),
                                  INT(SUBSTRING(aux_setlinha,221,4)))
                     tt-crapcbi.tpmepgto = aux_tpmepgto
                     tt-crapcbi.nrcpfcgc = DEC(SUBSTRING(aux_setlinha,49,11))
                     
                     /* Campos de alteracao sao limpos para permitir que
                        possam ser solicitadas novas alteracoes */
                     tt-crapcbi.dtatucad = ?
                     tt-crapcbi.cdnovopg = 0
                     tt-crapcbi.nrnovcta = 0
                     tt-crapcbi.tpnovmpg = 0
                     tt-crapcbi.dtdenvio = ?
                     tt-crapcbi.cdaltcad = 0

                     aux_qtdcadas     = aux_qtdcadas + 1.
             END.
        ELSE
        /* Bloqueios e Desbloqueios */
        IF   INT(SUBSTRING(aux_setlinha,9,2)) = 40   OR     /* Bloqueios */
             INT(SUBSTRING(aux_setlinha,9,2)) = 41   THEN   /* Desbloqueios */
             DO:  

                 /* Bloqueios */
                 IF   INT(SUBSTRING(aux_setlinha,9,2)) = 40   THEN
                      DO:
                          /* Header */
                          IF   INT(SUBSTRING(aux_setlinha,1,1)) = 1    THEN
                               ASSIGN aux_nrrmsblq = 
                                          INT(SUBSTRING(aux_setlinha,26,07))
                                      aux_qtdbloqu = 0.
                                      
                          /* Trailer */
                          IF   INT(SUBSTRING(aux_setlinha,1,1)) = 3    THEN
                               DO:

                                IF   aux_qtdbloqu <>
                                        INT(SUBSTRING(aux_setlinha,14,8))  THEN
                                        DO:
                                            
                                            CREATE tt-mensagens.
                                            ASSIGN 
                                            tt-mensagens.nrseqmsg = aux_nrseqmsg
                                            aux_nrseqmsg          = 
                                                    aux_nrseqmsg + 1
                                            tt-mensagens.dsmensag = 
                                                    "ATENCAO!! Total de "     +
                                                    "registros de "           +
                                                    "bloqueio nao conferem. " +
                                                    "Arquivo: "               +
                                                    tt-arquivos.nmarquiv.
                                                               
                                            aux_flgderro = YES.            
                                        END.

                               END.
                      END.
                             
                      
                 /* Header e Trailer */
                 IF   INT(SUBSTRING(aux_setlinha,1,1)) = 1   OR
                      INT(SUBSTRING(aux_setlinha,1,1)) = 3   THEN
                      NEXT.
                      
                 ASSIGN aux_nrrecben = DEC(SUBSTRING(aux_setlinha,101,11))
                        aux_nrbenefi = DEC(SUBSTRING(aux_setlinha,11,10))
                        aux_dtfimper = DATE(INT(SUBSTRING(aux_setlinha,25,02)),
                                            INT(SUBSTRING(aux_setlinha,27,02)),
                                            INT(SUBSTRING(aux_setlinha,21,04)))
                        aux_dtiniper = DATE(INT(SUBSTRING(aux_setlinha,33,02)),
                                            INT(SUBSTRING(aux_setlinha,35,02)),
                                            INT(SUBSTRING(aux_setlinha,29,04)))
                        aux_nrseqcre = INT(SUBSTRING(aux_setlinha,37,02)).

                 /* Procura o registro do credito */
                 FIND tt-craplbi WHERE 
                      tt-craplbi.cdcooper = tt-arquivos.cdcooper   AND
                      tt-craplbi.nrrecben = aux_nrrecben           AND
                      tt-craplbi.nrbenefi = aux_nrbenefi           AND
                      tt-craplbi.dtfimper = aux_dtfimper           AND
                      tt-craplbi.dtiniper = aux_dtiniper           AND
                      tt-craplbi.nrseqcre = aux_nrseqcre   
                      EXCLUSIVE-LOCK NO-ERROR.
                                    
                 IF   NOT AVAILABLE tt-craplbi   THEN
                      DO:
                          FIND craplbi WHERE
                               craplbi.cdcooper = tt-arquivos.cdcooper   AND
                               craplbi.nrrecben = aux_nrrecben           AND
                               craplbi.nrbenefi = aux_nrbenefi           AND
                               craplbi.dtfimper = aux_dtfimper           AND
                               craplbi.dtiniper = aux_dtiniper           AND
                               craplbi.nrseqcre = aux_nrseqcre
                               NO-LOCK NO-ERROR.
                               
                          IF   NOT AVAILABLE craplbi   THEN
                               DO: 
                                   CREATE tt-craplbi.
                                   ASSIGN tt-craplbi.cdcooper = 
                                                     tt-arquivos.cdcooper
                                          tt-craplbi.nrrecben = aux_nrrecben
                                          tt-craplbi.nrbenefi = aux_nrbenefi
                                          tt-craplbi.dtfimper = aux_dtfimper
                                          tt-craplbi.dtiniper = aux_dtiniper
                                          tt-craplbi.nrseqcre = aux_nrseqcre.

                                   

                                   IF INT(SUBSTRING(aux_setlinha,9,2)) = 40   THEN
                                        ASSIGN aux_qtdbloqu = aux_qtdbloqu + 1.
                                   
                                   /* Credito inexistente */
                                   ASSIGN tt-craplbi.instatus = 1 /* Erro */
                                          tt-craplbi.cdocorre = 1. 
                                   NEXT.
                               END.
                          ELSE
                               DO:
                                   CREATE tt-craplbi.
                                   BUFFER-COPY craplbi TO tt-craplbi.
                               END.
                      END.

                 /* Bloqueio */
                 IF   INT(SUBSTRING(aux_setlinha,9,2)) = 40   THEN

                     ASSIGN tt-craplbi.idbloque =
                                     INT(SUBSTRING(aux_setlinha,69,09))
                             tt-craplbi.tporiblq =
                                     INT(SUBSTRING(aux_setlinha,113,02))
                             tt-craplbi.dtblqcre = 
                                     DATE(INT(SUBSTRING(aux_setlinha,43,02)),
                                          INT(SUBSTRING(aux_setlinha,45,02)),
                                          INT(SUBSTRING(aux_setlinha,39,04)))
                             tt-craplbi.dtlibcre = ?
                             tt-craplbi.cdsitcre = 2 /* Bloqueado */
                             tt-craplbi.cdoperac = IF tt-craplbi.cdoperac = 0 
                                                      THEN 2 /* Bloqueio */
                                                   ELSE tt-craplbi.cdoperac
                             tt-craplbi.cdbloque = 
                                        INT(SUBSTRING(aux_setlinha,113,02))
                             /* Totais computados */
                             aux_qtdbloqu = aux_qtdbloqu + 1
                             aux_qttotblq = aux_qttotblq + 1
                             aux_vltotblq = aux_vltotblq + tt-craplbi.vllanmto.

                 ELSE
                      /* Desbloqueio */
                      ASSIGN tt-craplbi.idbloque =
                                     INT(SUBSTRING(aux_setlinha,69,09))
                             tt-craplbi.tporiblq = 0
                             tt-craplbi.dtblqcre = ?
                             tt-craplbi.dtlibcre =
                                     DATE(INT(SUBSTRING(aux_setlinha,43,02)),
                                          INT(SUBSTRING(aux_setlinha,45,02)),
                                          INT(SUBSTRING(aux_setlinha,39,04)))
                             tt-craplbi.cdsitcre = 1  /* Nao Bloqueado */
                             tt-craplbi.cdoperac = IF tt-craplbi.cdoperac = 0 
                                                      THEN 3 /* Desbloqueio */
                                                   ELSE tt-craplbi.cdoperac
                             aux_qttotdbl = aux_qttotdbl + 1
                             aux_vltotdbl = aux_vltotdbl + tt-craplbi.vllanmto.
             
             END.
        ELSE
        /* Procuradores */
        IF   INT(SUBSTRING(aux_setlinha,9,2)) = 93   THEN
             DO:
                 IF   INT(SUBSTRING(aux_setlinha,1,1)) = 1   THEN /* Header */
                      DO:
                          aux_qtdprocu = 0.
                          
                          NEXT.
                      END.
                      
                 IF   INT(SUBSTRING(aux_setlinha,1,1)) = 3   THEN /* Trailer */
                      DO:
                          IF   aux_qtdprocu <>
                               INT(SUBSTRING(aux_setlinha,14,8))  THEN
                               DO:
                                   CREATE tt-mensagens.

                                   ASSIGN 
                                       tt-mensagens.nrseqmsg = aux_nrseqmsg
                                       aux_nrseqmsg          = aux_nrseqmsg + 1
                                       tt-mensagens.dsmensag = 
                                           "ATENCAO!! Total de registros de " +
                                           "procuradores nao conferem. "      +
                                           "Arquivo: " + tt-arquivos.nmarquiv.

                                   aux_flgderro = YES.
                               END.
                               
                          NEXT.
                      END.

                 CREATE tt-crappbi.

                 ASSIGN 
                     tt-crappbi.cdcooper = tt-arquivos.cdcooper
                     tt-crappbi.cdagenci = tt-arquivos.cdagenci
                     tt-crappbi.dtmvtolt = par_dtmvtolt
                     tt-crappbi.nrbenefi = DEC(SUBSTRING(aux_setlinha,11,10))
                     tt-crappbi.nmprocur = SUBSTRING(aux_setlinha,27,47)
                     tt-crappbi.dsdocpcd = SUBSTRING(aux_setlinha,74,12)
                     tt-crappbi.cdoedpcd = SUBSTRING(aux_setlinha,86,05)
                     tt-crappbi.cdufdpcd = SUBSTRING(aux_setlinha,91,02)  
                     tt-crappbi.dtvalprc = DATE(SUBSTRING(aux_setlinha,93,08))
                     tt-crappbi.nrrecben = DEC(SUBSTRING(aux_setlinha,101,11))
                     tt-crappbi.cdorgpag = INT(SUBSTRING(aux_setlinha,21,06))
                     
                     aux_qtdprocu     = aux_qtdprocu + 1.
             END.
    END.
   
    INPUT STREAM str_1 CLOSE.

    /* Na conciliacao do BANCOOB, as quantidades informadas no relatorio sao
       referentes a todos os creditos nao pagos e bloqueados que devem estar
       cadastrados na base, portanto sao contabilizados os registros da nossa
       base com os importados no arquivo para poder "bater" com o relatorio do
       BANCOOB. A consideracao de creditos vencidos e ainda nao enviados,
       deve-se ao fato que o envio destes creditos como vencidos (para o 
       Bancoob) acontece no mesmo momento da importacao, ou seja, o Bancoob
       ainda "nao sabe" que o credito esta vencido */

                           /* Creditos NAO PAGOS */
    FOR EACH craplbi WHERE (craplbi.cdcooper  = tt-arquivos.cdcooper   AND
                            craplbi.cdagenci  = tt-arquivos.cdagenci   AND
                            craplbi.dtdpagto  = ?                      AND
                            craplbi.dtfimpag >= par_dtmvtolt           AND
                            craplbi.cdsitcre  = 1 /* Nao Bloq. */      AND
                            craplbi.dtlibcre  = ?)
                            OR
                           /* Creditos PAGOS NO DIA */
                           (craplbi.cdcooper  = tt-arquivos.cdcooper   AND
                            craplbi.cdagenci  = tt-arquivos.cdagenci   AND
                            craplbi.dtdpagto  = par_dtmvtolt           AND
                            craplbi.dtfimpag >= par_dtmvtolt           AND
                            craplbi.cdsitcre  = 1 /* Nao Bloq. */      AND
                            craplbi.dtlibcre  = ?)                       
                            OR
                           /* Creditos VENCIDOS E AINDA NAO ENVIADOS */
                           (craplbi.cdcooper  = tt-arquivos.cdcooper   AND
                            craplbi.cdagenci  = tt-arquivos.cdagenci   AND
                            craplbi.dtdpagto  = ?                      AND
                            craplbi.dtfimpag  < par_dtmvtolt           AND
                            craplbi.dtdenvio  = ?                      AND
                            craplbi.cdsitcre  = 1 /* Nao Bloq. */      AND
                            craplbi.dtlibcre  = ?)
                            NO-LOCK:

        /* Creditos NAO PAGOS */                           
        ASSIGN aux_qttotcre = aux_qttotcre + 1
               aux_vltotcre = aux_vltotcre + craplbi.vllanmto.

    END.

    /* Creditos NAO PAGOS, descontando os BLOQUEIOS feitos no arquivo */
    ASSIGN aux_qttotcre = aux_qttotcre - aux_qttotblq 
           aux_vltotcre = aux_vltotcre - aux_vltotblq. 


    /* Creditos BLOQUEADOS (nao enviados) */
    FOR EACH craplbi WHERE (craplbi.cdcooper = tt-arquivos.cdcooper   AND
                            craplbi.cdagenci = tt-arquivos.cdagenci   AND
                            craplbi.dtdpagto = ?                      AND
                            craplbi.dtdenvio = ?                      AND
                            craplbi.cdsitcre = 2 /* Bloq. */          AND
                            craplbi.dtlibcre = ?)
                            NO-LOCK:

        /* Creditos BLOQUEADOS */
        ASSIGN aux_qttotblq = aux_qttotblq + 1
               aux_vltotblq = aux_vltotblq + craplbi.vllanmto.

    END.
    
    /* Creditos BLOQUEADOS, descontando os DESBLOQUEIOS feitos no arquivo */
    ASSIGN aux_qttotblq = aux_qttotblq - aux_qttotdbl
           aux_vltotblq = aux_vltotblq - aux_vltotdbl.


     /* Creditos DESBLOQUEADOS (nao enviados) */
    FOR EACH craplbi WHERE (craplbi.cdcooper = tt-arquivos.cdcooper   AND
                            craplbi.cdagenci = tt-arquivos.cdagenci   AND
                            craplbi.dtdpagto = ?                      AND
                            craplbi.dtdenvio = ?                      AND
                            craplbi.cdsitcre = 1 /* Desbloq. */       AND
                            craplbi.dtlibcre <> ?)
                            NO-LOCK:

        /* Creditos DESBLOUEADOS */
        ASSIGN aux_qttotdbl = aux_qttotdbl + 1
               aux_vltotdbl = aux_vltotdbl + craplbi.vllanmto.

    END.
    
    /* Total de Creditos, somando com o total de creditos DESBLOQUEADOS */
    ASSIGN aux_qttotcre = aux_qttotcre + aux_qttotdbl
           aux_vltotcre = aux_vltotcre + aux_vltotdbl.


    /* Verifica se os dados informados conferem com os computados */
    IF   par_concilia          = "S"             AND
        (tt-arquivos.qtnaopag <> aux_qttotcre    OR
         tt-arquivos.vlnaopag <> aux_vltotcre    OR
         tt-arquivos.qtbloque <> aux_qttotblq    OR
         tt-arquivos.vlbloque <> aux_vltotblq)   THEN
         DO:
             tt-arquivos.dsstatus = "NAO PROCESSADO - ERRO NA CONCILIACAO".

             CREATE tt-dif-import.
             ASSIGN tt-dif-import.cdagenci = tt-arquivos.cdagenci
                    tt-dif-import.nmarquiv = tt-arquivos.nmarquiv
                    tt-dif-import.qtnaopag = tt-arquivos.qtnaopag
                    tt-dif-import.vlnaopag = tt-arquivos.vlnaopag
                    tt-dif-import.qtbloque = tt-arquivos.qtbloque
                    tt-dif-import.vlbloque = tt-arquivos.vlbloque
                    tt-dif-import.qttotcre = aux_qttotcre
                    tt-dif-import.vltotcre = aux_vltotcre
                    tt-dif-import.qttotblq = aux_qttotblq
                    tt-dif-import.vltotblq = aux_vltotblq.

             RETURN "NOK".

         END.


    /* Verifica se o PA que esta importando o arquivo esta credenciado, para
       evitar erros de importacao */
    FIND crapage WHERE 
         crapage.cdcooper = tt-arquivos.cdcooper   AND
         crapage.cdagenci = tt-arquivos.cdagenci
         NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapage   OR
         crapage.cdorgpag = 0    THEN
         DO:
             CREATE tt-mensagens.

             ASSIGN tt-mensagens.nrseqmsg = aux_nrseqmsg
                    aux_nrseqmsg          = aux_nrseqmsg + 1
                    tt-mensagens.dsmensag = "Atencao!!! PA  "         + 
                                            STRING(tt-arquivos.cdagenci) +
                                            " da cooperativa " +
                                            STRING(tt-arquivos.cdcooper) +
                                            " nao foi credenciado!".
             
             /* Fara a devolucao do lote */
             aux_flgderro = YES.

         END.

    
    RUN pi_valida_registros (INPUT par_dtmvtolt,
                             INPUT aux_flgderro,
                             INPUT par_concilia).

      
    
    /* Campo crapage.cdorgpag NAO cadastrado na CADPAC */
    IF   AVAILABLE crapage   THEN
         IF   crapage.cdorgpag = 0   THEN
              tt-arquivos.dsstatus = "LOTE DEVOLVIDO".

    
    RUN pi_gera_retorno (INPUT par_ncaixass,
                         INPUT par_dtmvtolt,
                         INPUT par_cdoperad).
    
    /* Erro quando craptab nao for encontrada */
    IF   RETURN-VALUE = "NOK"   THEN
         DO:
            ASSIGN aux_dscritic = ""
                    aux_cdcritic = 55.
        
            RUN gera_erro (INPUT par_cdcoopss,
                           INPUT par_cdagenss,
                           INPUT par_ncaixass,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
         END.

    RUN pi_grava_registros_inss.

    /* grava o LOG do processamento */
    DO WHILE TRUE TRANSACTION:
    
       FIND craplog WHERE craplog.cdcooper = tt-arquivos.cdcooper   AND
                          craplog.dttransa = par_dtmvtolt           AND
                          craplog.hrtransa = TIME                   AND
                          craplog.cdoperad = par_cdoperad
                          NO-LOCK NO-ERROR.
                          
       IF   AVAILABLE craplog   THEN
            DO:
                PAUSE 1 NO-MESSAGE.
                NEXT.
            END.
       
       CREATE craplog.
       ASSIGN craplog.dttransa = par_dtmvtolt
              craplog.hrtransa = TIME
              craplog.cdoperad = par_cdoperad
              craplog.dstransa = tt-arquivos.nmarquiv + " - " +
                                 IF   aux_flgderro         THEN
                                      "LOTE DEVOLVIDO"
                                 ELSE
                                 IF   par_concilia = "S"   THEN
                                      "CONCILIADO"
                                 ELSE
                                      "SEM CONCILIACAO"
              craplog.nrdconta = 0
              craplog.cdcooper = tt-arquivos.cdcooper 
              craplog.cdprogra = "PRPREV".
        
       LEAVE.
    END.
      
    /* Libera o registro */
    RELEASE craplog.           
    
    RETURN "OK".
           
END PROCEDURE. /* pi_processa_arquivo_inss */

PROCEDURE pi_grava_registros_inss:

    DO TRANSACTION:
       
       /* Cadastros */
       FOR EACH tt-crapcbi WHERE 
                tt-crapcbi.cdcooper = tt-arquivos.cdcooper   AND
                tt-crapcbi.instatus = 0 /* OK */             NO-LOCK:
           
           DO WHILE TRUE:
    
              /* Se ja existe, faz atualizacao do registro */
              FIND crapcbi WHERE crapcbi.cdcooper = tt-crapcbi.cdcooper   AND
                                 crapcbi.nrrecben = tt-crapcbi.nrrecben   AND
                                 crapcbi.nrbenefi = tt-crapcbi.nrbenefi
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

              IF   NOT AVAILABLE crapcbi   THEN
                   DO:
                       IF   LOCKED crapcbi   THEN
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            CREATE crapcbi.
                   END.
                
              LEAVE.
           END.
    
           BUFFER-COPY tt-crapcbi EXCEPT tt-crapcbi.indresvi
                                         tt-crapcbi.dtcompvi
                                         tt-crapcbi.dtenvipv TO crapcbi.

       END.
       
       /* Creditos / Bloqueios / Desbloqueios */
       FOR EACH tt-craplbi WHERE 
                tt-craplbi.cdcooper = tt-arquivos.cdcooper   AND
                tt-craplbi.instatus = 0 /* OK */             NO-LOCK:
                              
           DO WHILE TRUE:
    
              /* Se ja existe, faz atualizacao do registro */
              FIND craplbi WHERE craplbi.cdcooper = tt-craplbi.cdcooper   AND
                                 craplbi.nrrecben = tt-craplbi.nrrecben   AND
                                 craplbi.nrbenefi = tt-craplbi.nrbenefi   AND
                                 craplbi.dtfimper = tt-craplbi.dtfimper   AND
                                 craplbi.dtiniper = tt-craplbi.dtiniper   AND
                                 craplbi.nrseqcre = tt-craplbi.nrseqcre
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

              IF   NOT AVAILABLE craplbi   THEN
                   DO: 
                       IF   LOCKED craplbi   THEN
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            CREATE craplbi.
                   END.
                
              LEAVE.
           END.
    
           BUFFER-COPY tt-craplbi TO craplbi.
       END.
                      
       /* Procuradores */
       FOR EACH tt-crappbi WHERE 
                tt-crappbi.cdcooper = tt-arquivos.cdcooper   AND
                tt-crappbi.instatus = 0 /* OK */             NO-LOCK:
                           
           DO WHILE TRUE:

              /* Se ja existe, faz atualizacao do registro */
              FIND crappbi WHERE crappbi.cdcooper = tt-crappbi.cdcooper   AND
                                 crappbi.nrrecben = tt-crappbi.nrrecben   AND
                                 crappbi.nrbenefi = tt-crappbi.nrbenefi
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
              IF   NOT AVAILABLE crappbi   THEN
                   DO:
                       IF   LOCKED crappbi   THEN
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            CREATE crappbi.
                   END.
                
              LEAVE.
           END.
 
           BUFFER-COPY tt-crappbi TO crappbi.
       END.
       
    END. /* Fim DO TRANSACTION */
                                     
    /* Libera os registros */
    RELEASE crapcbi.
    RELEASE craplbi.
    RELEASE crappbi.
    RELEASE craptab.

END PROCEDURE. /* pi_grava_registros_inss */

PROCEDURE pi_busca_sequencia:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpregist LIKE craptab.tpregis              NO-UNDO.
    
    DO   WHILE TRUE:

         FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                            craptab.nmsistem = "CRED"         AND
                            craptab.tptabela = "GENERI"       AND
                            craptab.cdempres = 0              AND
                            craptab.cdacesso = "ARQRETINSS"   AND
                            craptab.tpregist = par_tpregist
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                            
         IF   NOT AVAILABLE craptab   THEN
              DO:
                  IF   LOCKED craptab   THEN
                       DO:
                           PAUSE 1 NO-MESSAGE.
                           NEXT.
                       END.
                  ELSE
                       DO:
                           ASSIGN aux_cdcritic = 55
                                  aux_dscritic = "".
                           RUN gera_erro (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT 1,            /** Sequencia **/
                                          INPUT aux_cdcritic,
                                          INPUT-OUTPUT aux_dscritic).

                           RETURN "NOK".
                       END.
              END.
         
         LEAVE.
       
    END. /* fim DO WHILE */
    
    RETURN "OK".
     
END PROCEDURE. /* pi_busca_sequencia */

PROCEDURE pi_atualiza_sequencia:

    DEF  INPUT PARAM par_tpregist LIKE craptab.tpregis              NO-UNDO.

    IF   par_tpregist = 0   THEN
         ASSIGN craptab.dstextab = STRING(INT(craptab.dstextab) + 1).
    ELSE
         ASSIGN craptab.dstextab = STRING(INT(craptab.dstextab) + 1,"999999").
         
END PROCEDURE. /* pi_atualiza_sequencia */
                  
PROCEDURE pi_valida_registros:

    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgderro AS LOGICAL                        NO-UNDO.
    DEF  INPUT PARAM par_concilia AS CHAR                           NO-UNDO.

    /* Cadastros - verifica se existem as contas dos creditos em conta */
    FOR EACH tt-crapcbi WHERE tt-crapcbi.cdcooper = tt-arquivos.cdcooper 
                              EXCLUSIVE-LOCK:
                           
        IF par_flgderro THEN
           DO:
               /* Para a devolucao do lote, sera usada a critica 2-Ocorrencia
                  de nao pagamento devido ao orgao pagador nao ser
                  localizado */
               ASSIGN tt-crapcbi.instatus = 1 /* Erro */
                      tt-crapcbi.cdocorre = 2
                      aux_arqcerro     = YES.
               NEXT.

           END.

        /*Devido a incorporacao da CONCREDI, devera ser desprazado os registros
          para esta, conforme abaixo:*/
        IF tt-crapcbi.cdcooper = 4 THEN
           DO:
              ASSIGN tt-crapcbi.instatus = 1 /* Erro */
                     tt-crapcbi.cdocorre = (IF tt-crapcbi.tpmepgto = 2 THEN
                                               8
                                            ELSE
                                               9)
                     aux_arqcerro        = YES.

              NEXT. 

           END.
             
        /* Conta Corrente */
        IF tt-crapcbi.tpmepgto = 2   THEN
           DO: 
               FIND crapass WHERE crapass.cdcooper = tt-crapcbi.cdcooper   AND
                                  crapass.nrdconta = tt-crapcbi.nrdconta   
                                  NO-LOCK NO-ERROR.
               
               /* Critica 08-Ocorrencia de nao pagamento devido ao numero da
                  Conta Corrente/Poupanca invalido ou encerrada*/
               IF   NOT AVAILABLE crapass   THEN
                    ASSIGN tt-crapcbi.instatus = 1 /* Erro */
                           tt-crapcbi.cdocorre = 8
                           aux_arqcerro        = YES.
               ELSE
               IF    crapass.dtelimin <> ?   THEN
                     ASSIGN tt-crapcbi.instatus = 1 /* Erro */
                            tt-crapcbi.cdocorre = 8
                            aux_arqcerro        = YES.
           END.

    END. /* FOR EACH tt-crapcbi */
    
    
    /* Creditos, Bloqueios e Desbloqueios - verifica a existencia dos cadastros
       e a possibilidade de execucao das operacoes */
    FOR EACH tt-craplbi WHERE tt-craplbi.cdcooper = tt-arquivos.cdcooper 
                              EXCLUSIVE-LOCK:

        /* Conta Corrente */
        IF tt-craplbi.tpmepgto = 2   THEN
           DO:
               FIND crapass WHERE crapass.cdcooper = tt-craplbi.cdcooper   AND
                                  crapass.nrdconta = tt-craplbi.nrdconta   
                                  NO-LOCK NO-ERROR.
               
               /* Critica 08-Ocorrencia de nao pagamento devido ao numero da
                  Conta Corrente/Poupanca invalido ou encerrada*/
               IF NOT AVAILABLE crapass   THEN   
                  ASSIGN tt-craplbi.instatus = 1 /* Erro */
                         tt-craplbi.cdocorre = 8
                         aux_arqcerro        = YES.      
               ELSE
                 IF crapass.dtelimin <> ?   THEN
                    ASSIGN tt-craplbi.instatus = 1 /* Erro */
                           tt-craplbi.cdocorre = 8
                           aux_arqcerro        = YES.  

               /* Busca por NB */
               FIND crapcbi WHERE crapcbi.cdcooper = tt-craplbi.cdcooper AND
                                  crapcbi.nrrecben = 0                   AND
                                  crapcbi.nrbenefi = tt-craplbi.nrbenefi   
                                  NO-LOCK NO-ERROR.

               /* Busca por NIT */
               IF NOT AVAILABLE crapcbi THEN
                  FIND crapcbi WHERE crapcbi.cdcooper = tt-craplbi.cdcooper AND
                                     crapcbi.nrrecben = tt-craplbi.nrrecben AND
                                     crapcbi.nrbenefi = 0                  
                                     NO-LOCK NO-ERROR.
    
               IF NOT AVAIL(crapcbi) THEN
                  DO:
                     /* Busca por NB */
                     FIND tt-crapcbi WHERE tt-crapcbi.cdcooper = tt-craplbi.cdcooper AND
                                           tt-crapcbi.nrrecben = 0                   AND
                                           tt-crapcbi.nrbenefi = tt-craplbi.nrbenefi   
                                           NO-LOCK NO-ERROR.
                     
                     /* Busca por NIT */
                     IF NOT AVAILABLE tt-crapcbi   THEN
                        FIND tt-crapcbi WHERE tt-crapcbi.cdcooper = tt-craplbi.cdcooper AND
                                              tt-crapcbi.nrrecben = tt-craplbi.nrrecben AND
                                              tt-crapcbi.nrbenefi = 0                  
                                              NO-LOCK NO-ERROR.
    
                     IF NOT AVAIL(tt-crapcbi) THEN
                        DO:                                
                            ASSIGN tt-craplbi.instatus = 1 /* Erro */
                                   tt-craplbi.cdocorre = 16
                                   aux_arqcerro        = YES.
                        END.
                     ELSE
                        DO:
                           FIND  crapttl 
                           WHERE crapttl.cdcooper = tt-crapcbi.cdcooper AND
                                 crapttl.nrdconta = tt-craplbi.nrdconta AND
                                 crapttl.nrcpfcgc = tt-crapcbi.nrcpfcgc  
                                 NO-LOCK NO-ERROR.
    
                           IF NOT AVAIL(crapttl) THEN
                              DO:
                                  ASSIGN tt-craplbi.instatus = 1 /* Erro */

                                         tt-craplbi.cdocorre = 16
                                         aux_arqcerro        = YES.  
                              END.
                        END.
                  END.
               ELSE
                  DO:
                     /* Busca por NB */
                     FIND tt-crapcbi WHERE tt-crapcbi.cdcooper = tt-craplbi.cdcooper AND
                                           tt-crapcbi.nrrecben = 0                   AND
                                           tt-crapcbi.nrbenefi = tt-craplbi.nrbenefi   
                                           NO-LOCK NO-ERROR.
                     
                     /* Busca por NIT */
                     IF NOT AVAILABLE tt-crapcbi THEN
                        FIND tt-crapcbi WHERE tt-crapcbi.cdcooper = tt-craplbi.cdcooper AND
                                              tt-crapcbi.nrrecben = tt-craplbi.nrrecben AND
                                              tt-crapcbi.nrbenefi = 0                  
                                              NO-LOCK NO-ERROR.
                     
                     FIND FIRST crapttl 
                      WHERE crapttl.cdcooper = crapcbi.cdcooper     AND
                            crapttl.nrdconta = tt-craplbi.nrdconta  AND
                            ((AVAIL(crapcbi) AND
                              crapttl.nrcpfcgc = crapcbi.nrcpfcgc)    OR
                             (AVAIL(tt-crapcbi) AND
                              crapttl.nrcpfcgc = tt-crapcbi.nrcpfcgc))
                             NO-LOCK NO-ERROR.
        
                     IF NOT AVAIL(crapttl) THEN
                        DO:
                            ASSIGN tt-craplbi.instatus = 1 /* Erro */
                                   tt-craplbi.cdocorre = 16
                                   aux_arqcerro        = YES.  
                        END.
                  END.

           END.

        /* Verifica se o cadastro esta sendo feito nesta importacao */

        /* Busca por NB */
        FIND tt-crapcbi WHERE tt-crapcbi.cdcooper = tt-craplbi.cdcooper AND
                              tt-crapcbi.nrrecben = 0                   AND
                              tt-crapcbi.nrbenefi = tt-craplbi.nrbenefi   
                              NO-LOCK NO-ERROR.
                         
        /* Busca por NIT */
        IF NOT AVAILABLE tt-crapcbi   THEN
           FIND tt-crapcbi WHERE tt-crapcbi.cdcooper = tt-craplbi.cdcooper AND
                                 tt-crapcbi.nrrecben = tt-craplbi.nrrecben AND
                                 tt-crapcbi.nrbenefi = 0                  
                                 NO-LOCK NO-ERROR.
                         
        IF par_flgderro   THEN
           DO:
               ASSIGN tt-craplbi.instatus = 1 /* Erro */
                      aux_arqcerro     = YES.
               
               /* Credito */
               IF   tt-craplbi.cdoperac = 1   THEN
                    DO:
                       /* verifica se houve erro do cadastro para diferenciar
                          as criticas */

                       IF   AVAILABLE tt-crapcbi   THEN
                            tt-craplbi.cdocorre = tt-crapcbi.cdocorre.
                       ELSE
                            /* erro por falta de dados cadastrais */
                            tt-craplbi.cdocorre = 9.
                    END.
               ELSE
                    /* Bloq/Desbloq - credito inexistente */
                    tt-craplbi.cdocorre = 1. 
               
               NEXT.
           END.

        IF AVAILABLE tt-crapcbi   THEN
           DO:
               IF   tt-crapcbi.instatus <> 0   THEN
                    ASSIGN tt-craplbi.instatus = 1 /* Erro */
                           tt-craplbi.cdocorre = tt-crapcbi.cdocorre
                           aux_arqcerro     = YES.
           END.
        ELSE
           DO:
               /* Verifica se ja esta cadastrado na base */

               /* Busca por NB */
               FIND crapcbi WHERE crapcbi.cdcooper = tt-craplbi.cdcooper   AND
                                  crapcbi.nrrecben = 0                     AND
                                  crapcbi.nrbenefi = tt-craplbi.nrbenefi
                                  NO-LOCK NO-ERROR.
                                 
               /* Busca por NIT */
               IF   NOT AVAILABLE crapcbi   THEN
                    FIND crapcbi WHERE
                         crapcbi.cdcooper = tt-craplbi.cdcooper   AND
                         crapcbi.nrrecben = tt-craplbi.nrrecben   AND
                         crapcbi.nrbenefi = 0
                         NO-LOCK NO-ERROR.
                                  
               IF   NOT AVAILABLE crapcbi   THEN
                    DO:
                        ASSIGN tt-craplbi.instatus = 1 /* Erro */
                               aux_arqcerro     = YES.
                        
                        /* Credito - erro por falta de dados cadastrais */
                        IF   tt-craplbi.cdoperac = 1   THEN
                             tt-craplbi.cdocorre = 9.
                        ELSE
                        /* Bloq/Desbloq - credito inexistente */
                             tt-craplbi.cdocorre = 1. 
                             
                        NEXT.
                    END.

               /*Devido a incorporacao da CONCREDI, devera ser desprazado os registros
                 para esta, conforme abaixo:*/
               IF tt-arquivos.cdcooper = 4 THEN
                  DO:
                     ASSIGN tt-craplbi.instatus = 1 /* Erro */
                            tt-craplbi.cdocorre = (IF crapcbi.tpmepgto = 2 THEN
                                                      8
                                                   ELSE
                                                      9)
                            aux_arqcerro        = YES.
             
                     NEXT. 
             
                  END.
               
           END.

        /* Verifica se o registro ja esta cadastrado */
        FIND craplbi WHERE craplbi.cdcooper = tt-craplbi.cdcooper   AND
                           craplbi.nrrecben = tt-craplbi.nrrecben   AND
                           craplbi.nrbenefi = tt-craplbi.nrbenefi   AND
                           craplbi.dtfimper = tt-craplbi.dtfimper   AND
                           craplbi.dtiniper = tt-craplbi.dtiniper   AND
                           craplbi.nrseqcre = tt-craplbi.nrseqcre
                           NO-LOCK NO-ERROR.
        
        /* Se o pagamento ja foi efetuado */
        IF AVAILABLE craplbi       AND
           craplbi.dtdpagto <> ?   THEN
           DO:
               IF tt-craplbi.cdoperac = 1   THEN  /* Credito */
                  ASSIGN tt-craplbi.instatus = 1  /* Erro */ 
                         tt-craplbi.cdocorre = 13 /* Credito - duplicidade */
                         aux_arqcerro        = YES.
               ELSE                              /* Bloqueio */
                  DO:
                      /* Nao rejeita mas mostra no relatorio 473 
                        (tt-rejeicoes) */  
                      IF par_dtmvtolt = craplbi.dtdpagto   THEN 
                         DO:
                             /* Limpar data de pagamento/envio  */ 
                             ASSIGN tt-craplbi.dtdpagto = ?
                                    tt-craplbi.dtdenvio = ?.

                             CREATE tt-rejeicoes.
                             ASSIGN 
                              tt-rejeicoes.cdcooper = tt-craplbi.cdcooper
                              tt-rejeicoes.tpmepgto = tt-craplbi.tpmepgto
                              tt-rejeicoes.cdoperac = 999 
                                     /* Bloqueio de Creditos Pagos */
                                     /*  Efetuar estorno manual   */
                              tt-rejeicoes.cdagenci = tt-craplbi.cdagenci
                              tt-rejeicoes.nrrecben = tt-craplbi.nrrecben
                              tt-rejeicoes.nrbenefi = tt-craplbi.nrbenefi
                              tt-rejeicoes.nmrecben = 
                                     IF   AVAILABLE tt-crapcbi   THEN
                                          tt-crapcbi.nmrecben
                                     ELSE
                                     IF   AVAILABLE crapcbi      THEN
                                          crapcbi.nmrecben
                                     ELSE "BENEFICIARIO NAO ENCONTRADO"
                              tt-rejeicoes.dtinipag = tt-craplbi.dtinipag
                              tt-rejeicoes.dtfimpag = tt-craplbi.dtfimpag
                              tt-rejeicoes.vllanmto = tt-craplbi.vllanmto
                              tt-rejeicoes.nrdconta = tt-craplbi.nrdconta.
                         END.                             
                      ELSE /* Rejeita */
                         ASSIGN tt-craplbi.instatus = 1  /* Erro */
                                tt-craplbi.cdocorre = 2  
                                       /* Blq - Pagto ja efetuado */
                                aux_arqcerro        = YES.     

                  END.
                  
           END. /* Fim pagamento ja efetuado */
            
    END.
    
    
    /* Procuradores - Nao sera mais necessario verificar se existe lancamento,
       pois existem casos em que primeiro eh enviado o arquivo com o procurador 
       e em outro dia, o arquivo com o beneficiario/beneficio */      
    
    FOR EACH tt-crappbi WHERE 
             tt-crappbi.cdcooper = tt-arquivos.cdcooper EXCLUSIVE-LOCK:

        IF par_flgderro THEN
           DO:
              ASSIGN tt-crappbi.instatus = 1 /* Erro */
                     aux_arqcerro        = YES.
              NEXT.
           END.

        /*Devido a incorporacao da CONCREDI, devera ser desprazado os registros
          para esta, conforme abaixo:*/
        IF tt-arquivos.cdcooper = 4 THEN
           DO:
              ASSIGN tt-crappbi.instatus = 1 /* Erro */
                     aux_arqcerro        = YES.
        
              NEXT. 
        
           END.

    END.
    

    IF   aux_arqcerro         THEN
         tt-arquivos.dsstatus = "COM REJEITADOS".
    ELSE
    IF   par_concilia = "S"   THEN
         tt-arquivos.dsstatus = "CONCILIADO".
    ELSE
         tt-arquivos.dsstatus = "SEM CONCILIACAO".
    
END PROCEDURE. /* pi_valida_registros */

PROCEDURE pi_gera_retorno:

    DEF  INPUT PARAM par_ncaixass AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.

    DEF VAR aux_nrseqlot    AS INT                                  NO-UNDO.
    DEF VAR aux_nrseqreg    AS INT                                  NO-UNDO.
    DEF VAR aux_qttotreg    AS INT                                  NO-UNDO.
    DEF VAR aux_vltotreg    AS DEC                                  NO-UNDO.
    

    DO  TRANSACTION:
    
        RUN pi_busca_sequencia (INPUT tt-arquivos.cdcooper,
                                INPUT tt-arquivos.cdagenci,
                                INPUT par_ncaixass,
                                INPUT 0).
    
        IF   RETURN-VALUE = "NOK"   THEN
             RETURN "NOK".
    
        
        /* Monta o nome do arquivo de retorno */
        ASSIGN aux_nmarqger = "0" +
                              SUBSTRING(tt-arquivos.nmarquiv,1,4) +
                              STRING(DAY(par_dtmvtolt),"99") +
                              aux_dsdmeses[MONTH(par_dtmvtolt)] +
                              ".RET" +
                              craptab.dstextab.

        RUN pi_atualiza_sequencia (INPUT 0).
    
        OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarqger).
        
        /* Creditos Inconsistentes */
        RUN pi_busca_sequencia (INPUT tt-arquivos.cdcooper,
                                INPUT tt-arquivos.cdagenci,
                                INPUT par_ncaixass,
                                INPUT 3).
    
       
        IF   RETURN-VALUE = "NOK"   THEN
             RETURN "NOK".
        
        FOR EACH tt-craplbi WHERE 
                 tt-craplbi.cdcooper = tt-arquivos.cdcooper   AND
                 tt-craplbi.cdoperac = 1                      AND /* Cred */
                 tt-craplbi.instatus = 1                          /* Erro */
                 NO-LOCK BREAK BY tt-craplbi.tpmepgto: 
                           
            IF   FIRST-OF(tt-craplbi.tpmepgto)   THEN
                 DO:
                     ASSIGN aux_nrseqlot = aux_nrseqlot + 1
                            aux_nrseqreg = aux_nrseqreg + 1
                            aux_qttotreg = 0
                            aux_vltotreg = 0.
                 
                     /* Header */
                     PUT STREAM str_1 UNFORMATTED
                                "1"
                                STRING(aux_nrseqreg,"9999999")
                                "03"
                                "756"
                                STRING(tt-craplbi.tpmepgto,"99")
                                SUBSTRING(STRING(par_dtmvtolt,"99999999"),5,4)
                                SUBSTRING(STRING(par_dtmvtolt,"99999999"),3,2)
                                SUBSTRING(STRING(par_dtmvtolt,"99999999"),1,2)
                                STRING(aux_nrseqlot,"99")
                                SUBSTRING(STRING(par_dtmvtolt,"99999999"),5,4)
                                SUBSTRING(STRING(par_dtmvtolt,"99999999"),3,2)
                                "CONPAG"
                                FILL(" ",57)
                                STRING(craptab.dstextab,"x(6)")
                                FILL(" ",140)
                                SKIP.
                 END.
             
            ASSIGN aux_nrseqreg = aux_nrseqreg + 1
                   aux_qttotreg = aux_qttotreg + 1
                   aux_vltotreg = aux_vltotreg + tt-craplbi.vllanmto.

            
            /* Detalhe */
            PUT STREAM str_1 UNFORMATTED
                       "2"
                       STRING(aux_nrseqreg,"9999999")
                       STRING(tt-craplbi.nrbenefi,"9999999999")
                       SUBSTRING(STRING(tt-craplbi.dtfimper,"99999999"),5,4)
                       SUBSTRING(STRING(tt-craplbi.dtfimper,"99999999"),3,2)
                       SUBSTRING(STRING(tt-craplbi.dtfimper,"99999999"),1,2)
                       SUBSTRING(STRING(tt-craplbi.dtiniper,"99999999"),5,4)
                       SUBSTRING(STRING(tt-craplbi.dtiniper,"99999999"),3,2)
                       SUBSTRING(STRING(tt-craplbi.dtiniper,"99999999"),1,2)
                       STRING(tt-craplbi.nrseqcre,"99")
                       SUBSTRING(STRING(tt-craplbi.dtcalcre,"99999999"),5,4)
                       SUBSTRING(STRING(tt-craplbi.dtcalcre,"99999999"),3,2)
                       SUBSTRING(STRING(tt-craplbi.dtcalcre,"99999999"),1,2)
                       STRING(tt-craplbi.cdorgpag,"999999")
                       STRING(tt-craplbi.vllanmto * 100,"999999999999")
                       STRING(tt-craplbi.tpunimon,"9")
                       SUBSTRING(STRING(tt-craplbi.dtfimpag,"99999999"),5,4)
                       SUBSTRING(STRING(tt-craplbi.dtfimpag,"99999999"),3,2)
                       SUBSTRING(STRING(tt-craplbi.dtfimpag,"99999999"),1,2)
                       FILL(" ",1)
                       FILL(" ",28)
                       STRING(tt-craplbi.nrrecben,"99999999999")
                       STRING(tt-craplbi.cdocorre,"99")
                       FILL(" ",127)
                       SKIP.
                
            /* Busca por NB sendo criado na importacao */
            FIND tt-crapcbi WHERE 
                 tt-crapcbi.cdcooper = tt-craplbi.cdcooper   AND
                 tt-crapcbi.nrrecben = 0                     AND
                 tt-crapcbi.nrbenefi = tt-craplbi.nrbenefi   NO-LOCK NO-ERROR.
                         
            /* Busca por NIT sendo criado na importacao */
            IF   NOT AVAILABLE tt-crapcbi   THEN
                 FIND tt-crapcbi WHERE 
                      tt-crapcbi.cdcooper = tt-craplbi.cdcooper   AND
                      tt-crapcbi.nrrecben = tt-craplbi.nrrecben   AND
                      tt-crapcbi.nrbenefi = 0                     
                      NO-LOCK NO-ERROR.
                                    
            /* Busca por NB na base */
            IF   NOT AVAILABLE tt-crapcbi   THEN
                 FIND crapcbi WHERE 
                      crapcbi.cdcooper = tt-craplbi.cdcooper   AND
                      crapcbi.nrrecben = 0                     AND
                      crapcbi.nrbenefi = tt-craplbi.nrbenefi   NO-LOCK NO-ERROR.
                         
            /* Busca por NIT na base */
            IF   NOT AVAILABLE crapcbi   THEN
                 FIND crapcbi WHERE crapcbi.cdcooper = tt-craplbi.cdcooper   AND
                                    crapcbi.nrrecben = tt-craplbi.nrrecben   AND
                                    crapcbi.nrbenefi = 0
                                    NO-LOCK NO-ERROR.

            CREATE tt-rejeicoes.
            ASSIGN tt-rejeicoes.cdcooper = tt-craplbi.cdcooper
                   tt-rejeicoes.tpmepgto = tt-craplbi.tpmepgto
                   tt-rejeicoes.cdoperac = tt-craplbi.cdoperac
                   tt-rejeicoes.cdagenci = tt-craplbi.cdagenci
                   tt-rejeicoes.nrrecben = tt-craplbi.nrrecben
                   tt-rejeicoes.nrbenefi = tt-craplbi.nrbenefi
                   tt-rejeicoes.nmrecben = IF   AVAILABLE tt-crapcbi   THEN
                                               tt-crapcbi.nmrecben
                                           ELSE
                                           IF   AVAILABLE crapcbi      THEN
                                                crapcbi.nmrecben
                                           ELSE "BENEFICIARIO NAO ENCONTRADO"
                   tt-rejeicoes.dtinipag = tt-craplbi.dtinipag
                   tt-rejeicoes.dtfimpag = tt-craplbi.dtfimpag
                   tt-rejeicoes.vllanmto = tt-craplbi.vllanmto
                   tt-rejeicoes.nrdconta = tt-craplbi.nrdconta
                   tt-rejeicoes.dscritic = IF   tt-craplbi.cdocorre = 2    THEN
                                                "Orgao pagador nao encontrado"
                                           ELSE
                                           IF   tt-craplbi.cdocorre = 8    THEN
                                                STRING(tt-craplbi.nrdconta) + 
                                                "-" + "C/C invalida"
                                           ELSE
                                           IF   tt-craplbi.cdocorre = 9    THEN
                                                "Falta de dados cadastrais"
                                           ELSE
                                           IF   tt-craplbi.cdocorre = 13   THEN
                                                "Duplicidade de credito"
                                           ELSE
                                           IF   tt-craplbi.cdocorre = 16   THEN
                                                "CPF diferente do cadastrado na cooperativa"
                                           ELSE
                                                "Critica desconhecida".
        
            IF   LAST-OF(tt-craplbi.tpmepgto)   THEN
                 DO:
                     ASSIGN aux_nrseqreg = aux_nrseqreg + 1.

                     /* Trailer */
                     PUT STREAM str_1 UNFORMATTED
                                "3"
                                STRING(aux_nrseqreg,"9999999")
                                "03"
                                "756"
                                STRING(aux_qttotreg,"99999999")
                                STRING(aux_vltotreg * 100,"99999999999999999")
                                STRING(aux_nrseqlot,"99")
                                FILL(" ",200)
                                SKIP.

                     RUN pi_atualiza_sequencia (INPUT 3).

                 END.
        END. /* Fim - Creditos (FOR EACH tt-craplbi WHERE) */
    
    
        /* Bloqueios/Desbloqueios */
        RUN pi_busca_sequencia (INPUT tt-arquivos.cdcooper,
                                INPUT tt-arquivos.cdagenci,
                                INPUT par_ncaixass,
                                INPUT 42).
    
        IF   RETURN-VALUE = "NOK"   THEN
             RETURN "NOK".

        FOR EACH tt-craplbi WHERE 
                 tt-craplbi.cdcooper = tt-arquivos.cdcooper   AND
                 tt-craplbi.cdoperac > 1                      AND /* Blqs */
                 tt-craplbi.instatus = 1                          /* Erro */
                 NO-LOCK BREAK BY tt-craplbi.cdoperac
                                  BY tt-craplbi.tpmepgto: 
                           
            IF   FIRST-OF(tt-craplbi.tpmepgto)   THEN
                 DO:
                     ASSIGN aux_nrseqlot = aux_nrseqlot + 1
                            aux_nrseqreg = aux_nrseqreg + 1
                            aux_qttotreg = 0
                            aux_vltotreg = 0.
                 
                     /* Header */
                     PUT STREAM str_1 UNFORMATTED
                                "1"
                                STRING(aux_nrseqreg,"9999999")
                                "42"
                                "756"
                                STRING(tt-craplbi.tpmepgto,"99")
                                SUBSTRING(STRING(par_dtmvtolt,"99999999"),5,4)
                                SUBSTRING(STRING(par_dtmvtolt,"99999999"),3,2)
                                SUBSTRING(STRING(par_dtmvtolt,"99999999"),1,2)
                                STRING(aux_nrseqlot,"99")
                                "CONPAG"
                                STRING(aux_nrrmsblq,"9999999")
                                FILL(" ",56)
                                STRING(craptab.dstextab,"x(6)")
                                FILL(" ",140)
                                SKIP.
                 END.
             
            ASSIGN aux_nrseqreg = aux_nrseqreg + 1
                   aux_qttotreg = aux_qttotreg + 1
                   aux_vltotreg = aux_vltotreg + tt-craplbi.vllanmto.

            /* Detalhe */
            PUT STREAM str_1 UNFORMATTED
                       "2"
                       STRING(aux_nrseqreg,"9999999")
                       STRING(tt-craplbi.nrbenefi,"9999999999")
                       SUBSTRING(STRING(tt-craplbi.dtfimper,"99999999"),5,4)
                       SUBSTRING(STRING(tt-craplbi.dtfimper,"99999999"),3,2)
                       SUBSTRING(STRING(tt-craplbi.dtfimper,"99999999"),1,2)
                       SUBSTRING(STRING(tt-craplbi.dtiniper,"99999999"),5,4)
                       SUBSTRING(STRING(tt-craplbi.dtiniper,"99999999"),3,2)
                       SUBSTRING(STRING(tt-craplbi.dtiniper,"99999999"),1,2)
                       STRING(tt-craplbi.tpmepgto,"99")
                       SUBSTRING(STRING(tt-craplbi.dtcalcre,"99999999"),5,4)
                       SUBSTRING(STRING(tt-craplbi.dtcalcre,"99999999"),3,2)
                       SUBSTRING(STRING(tt-craplbi.dtcalcre,"99999999"),1,2)
                       STRING(tt-craplbi.cdocorre,"9")
                       STRING(tt-craplbi.idbloque,"999999999")
                       FILL(" ",46)
                       STRING(tt-craplbi.nrrecben,"99999999999")
                       FILL(" ",129)
                       SKIP.
            
            /* Busca por NB sendo criado na importacao*/
            FIND tt-crapcbi WHERE 
                 tt-crapcbi.cdcooper = tt-craplbi.cdcooper   AND
                 tt-crapcbi.nrrecben = 0                     AND
                 tt-crapcbi.nrbenefi = tt-craplbi.nrbenefi   NO-LOCK NO-ERROR.
                         
            /* Busca por NIT sendo criado na importacao */
            IF   NOT AVAILABLE tt-crapcbi   THEN
                 FIND tt-crapcbi WHERE 
                      tt-crapcbi.cdcooper = tt-craplbi.cdcooper   AND
                      tt-crapcbi.nrrecben = tt-craplbi.nrrecben   AND
                      tt-crapcbi.nrbenefi = 0                     
                      NO-LOCK NO-ERROR.
 
            /* Busca por NB na base */
            IF   NOT AVAILABLE tt-crapcbi   THEN
                 FIND crapcbi WHERE 
                      crapcbi.cdcooper = tt-craplbi.cdcooper   AND
                      crapcbi.nrrecben = 0                     AND
                      crapcbi.nrbenefi = tt-craplbi.nrbenefi   NO-LOCK NO-ERROR.
                         
            /* Busca por NIT na base */
            IF   NOT AVAILABLE crapcbi   THEN
                 FIND crapcbi WHERE crapcbi.cdcooper = tt-craplbi.cdcooper   AND
                                    crapcbi.nrrecben = tt-craplbi.nrrecben   AND
                                    crapcbi.nrbenefi = 0
                                    NO-LOCK NO-ERROR.

            CREATE tt-rejeicoes.
            ASSIGN tt-rejeicoes.cdcooper = tt-craplbi.cdcooper
                   tt-rejeicoes.tpmepgto = tt-craplbi.tpmepgto
                   tt-rejeicoes.cdoperac = tt-craplbi.cdoperac
                   tt-rejeicoes.cdagenci = tt-craplbi.cdagenci
                   tt-rejeicoes.nrrecben = tt-craplbi.nrrecben
                   tt-rejeicoes.nrbenefi = tt-craplbi.nrbenefi
                   tt-rejeicoes.nmrecben = IF   AVAILABLE tt-crapcbi   THEN
                                                tt-crapcbi.nmrecben
                                           ELSE
                                           IF   AVAILABLE crapcbi   THEN
                                                crapcbi.nmrecben
                                           ELSE "BENEFICIARIO NAO ENCONTRADO"
                   tt-rejeicoes.dtinipag = tt-craplbi.dtinipag
                   tt-rejeicoes.dtfimpag = tt-craplbi.dtfimpag
                   tt-rejeicoes.vllanmto = tt-craplbi.vllanmto
                   tt-rejeicoes.dscritic = IF   tt-craplbi.cdocorre = 1   THEN
                                                "Credito inexistente"
                                           ELSE
                                           IF   tt-craplbi.cdocorre = 2   THEN
                                                "Pagamento ja efetuado"
                                           ELSE
                                           IF   tt-craplbi.cdocorre = 9   THEN
                                                "Falta de dados cadastrais"
                                           ELSE
                                           IF   tt-craplbi.cdocorre = 16   THEN
                                                "CPF diferente do cadastrado na cooperativa"
                                           ELSE
                                                "Critica desconhecida"
                   tt-rejeicoes.cdbloque = tt-craplbi.cdbloque
                   tt-rejeicoes.nrdconta = tt-craplbi.nrdconta.
                
            IF   LAST-OF(tt-craplbi.tpmepgto)   THEN
                 DO:
                     ASSIGN aux_nrseqreg = aux_nrseqreg + 1.
            
                     /* Trailer */
                     PUT STREAM str_1 UNFORMATTED
                                "3"
                                STRING(aux_nrseqreg,"9999999")
                                "42"
                                "756"
                                STRING(aux_qttotreg,"99999999")
                                STRING(aux_nrseqlot,"99")
                                FILL(" ",217)
                                SKIP.
                 
                     RUN pi_atualiza_sequencia (INPUT 42).
                 END.
        END. /* Fim - Bloqueios/Desbloqueios */
     
        /* Procuradores */
        FOR EACH tt-crappbi WHERE  
                 tt-crappbi.cdcooper = tt-arquivos.cdcooper   AND
                 tt-crappbi.instatus = 1 /* Erro */           NO-LOCK:
            
            CREATE tt-rejeicoes.

            ASSIGN tt-rejeicoes.cdcooper = tt-crappbi.cdcooper
                   tt-rejeicoes.tpmepgto = 0 
                   tt-rejeicoes.cdoperac = 4 /* Procuradores */
                   tt-rejeicoes.cdagenci = tt-crappbi.cdagenci
                   tt-rejeicoes.nrrecben = tt-crappbi.nrrecben
                   tt-rejeicoes.nrbenefi = tt-crappbi.nrbenefi
                   tt-rejeicoes.nmrecben = "Beneficiario nao encontrado"
                   tt-rejeicoes.dtinipag = ?
                   tt-rejeicoes.dtfimpag = ?
                   tt-rejeicoes.vllanmto = 0
                   tt-rejeicoes.dscritic = "Credito inexistente"
                   tt-rejeicoes.nrdconta = 0.
        END.
        
        OUTPUT STREAM str_1 CLOSE.
    
        /* Verifica se o arquivo gerado esta vazio e o remove */
        INPUT STREAM str_1 THROUGH VALUE( "wc -m arq/" + aux_nmarqger +
                                          " 2> /dev/null") NO-ECHO.
              
        SET STREAM str_1 aux_tamarqui FORMAT "X(78)" WITH WIDTH 80.
           
        IF   INTEGER(SUBSTRING(aux_tamarqui,1,1)) = 0   THEN
             DO:
                 UNIX SILENT VALUE("rm arq/" + aux_nmarqger + " 2> /dev/null").
                 INPUT STREAM str_1 CLOSE.
                 UNDO, RETURN.
             END.
 
        INPUT STREAM str_1 CLOSE.
                                 
    END. /* Fim TRANSACTION */
    
    /* copia o arquivo para diretorio do BANCOOB */
    UNIX SILENT VALUE("ux2dos < arq/" + aux_nmarqger +
                      ' | tr -d "\032"' +
                      " > /micros/" + crapcop.dsdircop +
                      "/bancoob/" + aux_nmarqger + " 2>/dev/null").
    
    /* Move para o salvar */
    UNIX SILENT VALUE("mv arq/" + aux_nmarqger + " salvar 2>/dev/null").
    
    /* grava o LOG da geracao (retorno) */
    DO WHILE TRUE TRANSACTION:
    
       FIND craplog WHERE craplog.cdcooper = tt-arquivos.cdcooper   AND
                          craplog.dttransa = par_dtmvtolt           AND
                          craplog.hrtransa = TIME                   AND
                          craplog.cdoperad = par_cdoperad
                          NO-LOCK NO-ERROR.
                          
       IF   AVAILABLE craplog   THEN
            DO:
                PAUSE 1 NO-MESSAGE.
                NEXT.
            END.

       CREATE craplog.
       ASSIGN craplog.dttransa = par_dtmvtolt
              craplog.hrtransa = TIME
              craplog.cdoperad = par_cdoperad
              craplog.dstransa = aux_nmarqger + " - GERADO COM SUCESSO"
              craplog.nrdconta = 0
              craplog.cdcooper = tt-arquivos.cdcooper 
              craplog.cdprogra = "PRPREV".
              
       LEAVE.
    END.
    
    /* Libera o registro */
    RELEASE craplog.
    
END PROCEDURE. /* pi_gera_retorno */

PROCEDURE pi_carrega_temp_cooperativas:

    DEF  INPUT PARAM par_cdcoopss AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenss AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_ncaixass AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.

    EMPTY TEMP-TABLE tt-crapcop.

    IF   par_cdcooper = 0   THEN
         DO:
             FOR EACH crapcop NO-LOCK:
                 CREATE tt-crapcop.
                 BUFFER-COPY crapcop EXCEPT nrctabcb TO tt-crapcop.
             END.
         END.
    ELSE 
         DO:
            FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapcop   THEN
                 DO:
                     ASSIGN aux_cdcritic = 651
                            aux_dscritic = "".
                    
                     RUN gera_erro (INPUT par_cdcoopss,
                                    INPUT par_cdagenss,
                                    INPUT par_ncaixass,
                                    INPUT 1,            /** Sequencia **/
                                    INPUT aux_cdcritic,
                                    INPUT-OUTPUT aux_dscritic).
                     RETURN "NOK".
                 END.

            CREATE tt-crapcop.
            BUFFER-COPY crapcop EXCEPT nrctabcb TO tt-crapcop.
            RELEASE crapcop.
        END.

    RETURN "OK".

END PROCEDURE. /* pi_carrega_temp_cooperativas */


PROCEDURE gera_credito_em_conta:

    DEF INPUT PARAM par_cdcooper AS INT                         NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                        NO-UNDO.
    DEF INPUT PARAM par_cdprogra AS CHAR                        NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                        NO-UNDO.
    DEF INPUT PARAM par_dtdehoje AS DATE                        NO-UNDO.
    DEF INPUT PARAM par_nrdrowid AS ROWID                       NO-UNDO.


    FIND crablbi WHERE ROWID(crablbi) = par_nrdrowid
                       EXCLUSIVE-LOCK NO-ERROR.

    DO WHILE TRUE:

       FIND craplot WHERE craplot.cdcooper = par_cdcooper     AND
                          craplot.dtmvtolt = par_dtmvtolt     AND
                          craplot.cdagenci = crablbi.cdagenci AND
                          craplot.cdbccxlt = 100              AND
                          craplot.nrdolote = 10114
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                          
       IF NOT AVAILABLE craplot   THEN
          IF LOCKED craplot   THEN
             DO:
                PAUSE 1 NO-MESSAGE.
                NEXT.

             END.
          ELSE
             DO:
                CREATE craplot.

                ASSIGN craplot.cdcooper = par_cdcooper
                       craplot.dtmvtolt = par_dtmvtolt
                       craplot.cdagenci = crablbi.cdagenci
                       craplot.cdbccxlt = 100
                       craplot.nrdolote = 10114
                       craplot.tplotmov = 1.
             END.
                     
       LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */
                  
    ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
           craplot.qtcompln = craplot.qtcompln + 1
           craplot.qtinfoln = craplot.qtinfoln + 1
           craplot.vlcompcr = craplot.vlcompcr + crablbi.vlliqcre
           craplot.vlinfocr = craplot.vlinfocr + crablbi.vlliqcre.
           
           
          /* BLOCO DA INSERÇAO DA CRAPLCM */
          IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
            RUN sistema/generico/procedures/b1wgen0200.p 
              PERSISTENT SET h-b1wgen0200.

          RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
            (INPUT craplot.dtmvtolt               /* par_dtmvtolt */
            ,INPUT craplot.cdagenci               /* par_cdagenci */
            ,INPUT craplot.cdbccxlt               /* par_cdbccxlt */
            ,INPUT craplot.nrdolote               /* par_nrdolote */
            ,INPUT crablbi.nrdconta               /* par_nrdconta */
            ,INPUT craplot.nrseqdig               /* par_nrdocmto */
            ,INPUT 581                            /* par_cdhistor */
            ,INPUT craplot.nrseqdig               /* par_nrseqdig */
            ,INPUT crablbi.vlliqcre               /* par_vllanmto */
            ,INPUT crablbi.nrdconta               /* par_nrdctabb */
            ,INPUT ""                             /* par_cdpesqbb */
            ,INPUT 0                              /* par_vldoipmf */
            ,INPUT 0                              /* par_nrautdoc */
            ,INPUT 0                              /* par_nrsequni */
            ,INPUT 0                              /* par_cdbanchq */
            ,INPUT 0                              /* par_cdcmpchq */
            ,INPUT 0                              /* par_cdagechq */
            ,INPUT 0                              /* par_nrctachq */
            ,INPUT 0                              /* par_nrlotchq */
            ,INPUT 0                              /* par_sqlotchq */
            ,INPUT ""                             /* par_dtrefere */
            ,INPUT ""                             /* par_hrtransa */
            ,INPUT 0                              /* par_cdoperad */
            ,INPUT 0                              /* par_dsidenti */
            ,INPUT par_cdcooper                   /* par_cdcooper */
            ,INPUT STRING(crablbi.nrdconta,"99999999")/* par_nrdctitg */
            ,INPUT ""                             /* par_dscedent */
            ,INPUT 0                              /* par_cdcoptfn */
            ,INPUT 0                              /* par_cdagetfn */
            ,INPUT 0                              /* par_nrterfin */
            ,INPUT 0                              /* par_nrparepr */
            ,INPUT 0                              /* par_nrseqava */
            ,INPUT 0                              /* par_nraplica */
            ,INPUT 0                              /* par_cdorigem */
            ,INPUT 0                              /* par_idlautom */
            /* CAMPOS OPCIONAIS DO LOTE                                                            */ 
            ,INPUT 0                              /* Processa lote                                 */
            ,INPUT 0                              /* Tipo de lote a movimentar                     */
            /* CAMPOS DE SAÍDA                                                                     */                                            
            ,OUTPUT TABLE tt-ret-lancto           /* Collection que contém o retorno do lançamento */
            ,OUTPUT aux_incrineg                  /* Indicador de crítica de negócio               */
            ,OUTPUT aux_cdcritic                  /* Código da crítica                             */
            ,OUTPUT aux_dscritic).                /* Descriçao da crítica                          */
            
          IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:  
             /* Tratar o erro */
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT crablbi.cdagenci,
                            INPUT 100,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
          END.
    ASSIGN crablbi.dtdpagto = par_dtmvtolt
           crablbi.dtdenvio = par_dtmvtolt.

    IF UPPER(par_cdprogra) = "PRPREV" THEN
       UNIX SILENT VALUE("echo "      + STRING(par_dtdehoje,"99/99/9999")      +
                         " "          + STRING(TIME,"HH:MM:SS")    + "' --> '" +
                         "Operador: " + par_cdoperad               + " - "     +
                         "Realizou o credito em conta para a "                 +
                         "Conta: " + STRING(crablbi.nrdconta,"zzzz,zzz,9") +
                         ", Coop.: " + STRING(crablbi.cdcooper) +
                         ", PA : " + STRING(crablbi.cdagenci) +
                         ", Valor: " + STRING(crablbi.vlliqcre) + "." 
                         + " >> log/prprev.log").
    ELSE
       UNIX SILENT VALUE("echo "      + STRING(par_dtdehoje,"99/99/9999")      +
                         " "          + STRING(TIME,"HH:MM:SS")    + "' --> '" +
                         "Realizado o credito em conta para a "                +
                         "Conta: " + STRING(crablbi.nrdconta,"zzzz,zzz,9") +
                         ", Coop.: " + STRING(crablbi.cdcooper) +
                         ", PA : " + STRING(crablbi.cdagenci) +
                         ", Valor: " + STRING(crablbi.vlliqcre) + "."
                         + " >> log/prprev.log").
    
    RELEASE craplot.


    IF  VALID-HANDLE(h-b1wgen0200) THEN
        DELETE PROCEDURE h-b1wgen0200.

    RETURN "OK".

END PROCEDURE.   /* FIM gera_credito_em_conta  */


PROCEDURE busca_credito_em_conta:

    DEF INPUT PARAM par_cdcooper AS INT                     NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INT                     NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-cred_conta.

    EMPTY TEMP-TABLE tt-cred_conta.


    FOR EACH crapage WHERE (IF par_cdcooper = 0 THEN
                               TRUE 
                            ELSE
                               crapage.cdcooper = par_cdcooper) AND
                           (IF par_cdagenci = 0 THEN
                                TRUE
                            ELSE
                               crapage.cdagenci = par_cdagenci)
                            NO-LOCK:

        FOR EACH craplbi WHERE craplbi.cdcooper  = crapage.cdcooper         AND
                               craplbi.cdagenci  = crapage.cdagenci         AND
                               craplbi.dtinipag <= par_dtmvtolt             AND
                               craplbi.dtfimpag >= par_dtmvtolt             AND
                               craplbi.tpmepgto  = 2 /* Credito em conta */ AND
                               craplbi.cdsitcre  = 1 /* Nao bloqueado */    AND
                               craplbi.dtdpagto  = ? /* Nao pago */
                               NO-LOCK:
            
            CREATE tt-cred_conta.

            BUFFER-COPY craplbi TO tt-cred_conta.

            ASSIGN tt-cred_conta.nrdrowid = ROWID(craplbi)
                   tt-cred_conta.flgenvio = FALSE.

        END.

    END.


    RETURN "OK".


END PROCEDURE.   /* busca_credito_em_conta */

PROCEDURE transfere_beneficio:

    DEF INPUT PARAM par_cdcooper    LIKE    crapcop.cdcooper        NO-UNDO.
    DEF INPUT PARAM par_cdoperad    AS      CHAR                    NO-UNDO.
    DEF INPUT PARAM par_cdprogra    AS      CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta    LIKE    crapass.nrdconta        NO-UNDO.
    DEF INPUT PARAM par_cdhistor    LIKE    craplcm.cdhistor        NO-UNDO.
    DEF INPUT PARAM par_nrdolote    LIKE    craplot.nrdolote        NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    AS      DATE                    NO-UNDO.
    DEF INPUT PARAM par_dtdehoje    AS      DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdrowid    AS      ROWID                   NO-UNDO.

    
    FIND crablbi WHERE ROWID(crablbi) = par_nrdrowid
                             EXCLUSIVE-LOCK NO-ERROR.
    
    DO WHILE TRUE:

        FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                           craplot.dtmvtolt = par_dtmvtolt AND
                           craplot.cdagenci = 1            AND
                           craplot.cdbccxlt = 100          AND
                           craplot.nrdolote = par_nrdolote NO-ERROR.
    
        IF  NOT AVAILABLE craplot   THEN
            DO:
            
                IF  LOCKED craplot   THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
        
                    END.
                ELSE
                    DO:
                        CREATE craplot.
                        ASSIGN craplot.cdcooper = par_cdcooper
                               craplot.dtmvtolt = par_dtmvtolt
                               craplot.cdagenci = 1
                               craplot.cdbccxlt = 100
                               craplot.nrdolote = par_nrdolote
                               craplot.tplotmov = 1.
                    END.
            END.

        LEAVE.
    END.
    /******fim do while true *******/

      /* BLOCO DA INSERÇAO DA CRAPLCM */
      IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
        RUN sistema/generico/procedures/b1wgen0200.p 
          PERSISTENT SET h-b1wgen0200.

      RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
        (INPUT craplot.dtmvtolt               /* par_dtmvtolt */
        ,INPUT craplot.cdagenci               /* par_cdagenci */
        ,INPUT craplot.cdbccxlt               /* par_cdbccxlt */
        ,INPUT craplot.nrdolote               /* par_nrdolote */
        ,INPUT par_nrdconta                   /* par_nrdconta */
        ,INPUT craplot.nrseqdig + 1           /* par_nrdocmto */
        ,INPUT par_cdhistor                   /* par_cdhistor */
        ,INPUT craplot.nrseqdig + 1           /* par_nrseqdig */
        ,INPUT crablbi.vlliqcre               /* par_vllanmto */
        ,INPUT par_nrdconta                   /* par_nrdctabb */
        ,INPUT ""                             /* par_cdpesqbb */
        ,INPUT 0                              /* par_vldoipmf */
        ,INPUT 0                              /* par_nrautdoc */
        ,INPUT 0                              /* par_nrsequni */
        ,INPUT 0                              /* par_cdbanchq */
        ,INPUT 0                              /* par_cdcmpchq */
        ,INPUT 0                              /* par_cdagechq */
        ,INPUT 0                              /* par_nrctachq */
        ,INPUT 0                              /* par_nrlotchq */
        ,INPUT 0                              /* par_sqlotchq */
        ,INPUT ""                             /* par_dtrefere */
        ,INPUT ""                             /* par_hrtransa */
        ,INPUT 0                              /* par_cdoperad */
        ,INPUT 0                              /* par_dsidenti */
        ,INPUT craplot.cdcooper               /* par_cdcooper */
        ,INPUT STRING(par_nrdconta,"99999999")/* par_nrdctitg */
        ,INPUT ""                             /* par_dscedent */
        ,INPUT 0                              /* par_cdcoptfn */
        ,INPUT 0                              /* par_cdagetfn */
        ,INPUT 0                              /* par_nrterfin */
        ,INPUT 0                              /* par_nrparepr */
        ,INPUT 0                              /* par_nrseqava */
        ,INPUT 0                              /* par_nraplica */
        ,INPUT 0                              /* par_cdorigem */
        ,INPUT 0                              /* par_idlautom */
        /* CAMPOS OPCIONAIS DO LOTE                                                            */ 
        ,INPUT 0                              /* Processa lote                                 */
        ,INPUT 0                              /* Tipo de lote a movimentar                     */
        /* CAMPOS DE SAÍDA                                                                     */                                            
        ,OUTPUT TABLE tt-ret-lancto           /* Collection que contém o retorno do lançamento */
        ,OUTPUT aux_incrineg                  /* Indicador de crítica de negócio               */
        ,OUTPUT aux_cdcritic                  /* Código da crítica                             */
        ,OUTPUT aux_dscritic).                /* Descriçao da crítica                          */
        
        IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:  
           /* Tratar o erro */
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT craplot.cdagenci,
                          INPUT 100,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
           RETURN "NOK".
        END.

        IF  VALID-HANDLE(h-b1wgen0200) THEN
            DELETE PROCEDURE h-b1wgen0200.    



    FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                       craphis.cdhistor = par_cdhistor
                       NO-LOCK NO-ERROR.

    IF  AVAIL craphis THEN
        DO:
            IF  craphis.indebcre = "D" THEN
                DO:
                    craplot.vlcompdb = craplot.vlcompdb + crablbi.vlliqcre.
                    craplot.vlinfodb = craplot.vlcompdb.
                END.
            ELSE
                DO:  
                    IF  craphis.indebcre = "C" THEN
                        DO:
                            craplot.vlcompcr = craplot.vlcompcr + crablbi.vlliqcre.
                            craplot.vlinfocr = craplot.vlcompcr.
                        END.
                END.
        END.

    ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
           craplot.qtcompln = craplot.qtcompln + 1
           craplot.qtinfoln = craplot.qtcompln. 


    ASSIGN crablbi.dtdpagto = par_dtmvtolt
           crablbi.dtdenvio = par_dtmvtolt.

    VALIDATE craplot.


    IF UPPER(par_cdprogra) = "PRPREV" THEN
       UNIX SILENT VALUE("echo "      + STRING(par_dtdehoje,"99/99/9999")      +
                         " "          + STRING(TIME,"HH:MM:SS")    + "' --> '" +
                         "Operador: " + par_cdoperad               + " - "     +
                         "Realizou o credito em conta para a "                 +
                         "Conta: " + STRING(par_nrdconta,"zzzz,zzz,9") +
                         ", Coop.: " + STRING(crablbi.cdcooper) +
                         ", PA : " + STRING(crablbi.cdagenci) +
                         ", Valor: " + STRING(crablbi.vlliqcre) + "." 
                         + " >> log/prprev.log").
    ELSE
       UNIX SILENT VALUE("echo "      + STRING(par_dtdehoje,"99/99/9999")      +
                         " "          + STRING(TIME,"HH:MM:SS")    + "' --> '" +
                         "Realizado o credito em conta para a "                +
                         "Conta: " + STRING(par_nrdconta,"zzzz,zzz,9") +
                         ", Coop.: " + STRING(crablbi.cdcooper) +
                         ", PA : " + STRING(crablbi.cdagenci) +
                         ", Valor: " + STRING(crablbi.vlliqcre) + "."
                         + " >> log/prprev.log").

END PROCEDURE.


/*PROCEDURE RESPONSAVEL POR REALIZAR A COMPROVACAO DE VIDA*/
PROCEDURE comprova_vida:

  DEF INPUT PARAM par_cdcooper AS INT                              NO-UNDO.
  DEF INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
  DEF INPUT PARAM par_nrdcaixa AS INT                              NO-UNDO.
  DEF INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
  DEF INPUT PARAM par_nmdatela AS CHAR                             NO-UNDO.
  DEF INPUT PARAM par_cdagenci AS INT                              NO-UNDO.
  DEF INPUT PARAM par_idorigem AS INT                              NO-UNDO.
  DEF INPUT PARAM par_nrrecben AS DEC                              NO-UNDO.
  DEF INPUT PARAM par_nrbenefi AS DEC                              NO-UNDO.
  DEF INPUT PARAM par_nrcpfcgc AS DEC                              NO-UNDO.
  DEF INPUT PARAM par_nmrecben AS CHAR                             NO-UNDO.
  DEF INPUT PARAM par_hrtransa AS CHAR                             NO-UNDO.
  DEF INPUT PARAM par_indresvi AS INT                              NO-UNDO.
  DEF INPUT PARAM par_nmprocur AS CHAR                             NO-UNDO.
  DEF INPUT PARAM par_dsdocpcd AS CHAR                             NO-UNDO.
  DEF INPUT PARAM par_cdoedpcd AS CHAR                             NO-UNDO.
  DEF INPUT PARAM par_cdufdpcd AS CHAR                             NO-UNDO.
  DEF INPUT PARAM par_dtvalprc AS DATE                             NO-UNDO.
  DEF INPUT PARAM par_dsiduser AS CHAR                             NO-UNDO.

  DEF OUTPUT PARAM par_nmarqimp AS CHAR                            NO-UNDO.
  DEF OUTPUT PARAM TABLE FOR tt-erro.


  DEF VAR aux_dscooper AS CHAR                                     NO-UNDO.
  DEF VAR aux_nmarqimp AS CHAR                                     NO-UNDO.
  DEF VAR aux_sittrans AS CHAR                                     NO-UNDO.
  DEF VAR aux_retornvl AS CHAR INIT "NOK"                          NO-UNDO.
  DEF VAR aux_pxrnvida AS DATE                                     NO-UNDO.
  DEF VAR aux_dtmvtolt AS DATE                                     NO-UNDO.
  DEF VAR aux_nmprocur AS CHAR                                     NO-UNDO.
  DEF VAR aux_nmrecben AS CHAR                                     NO-UNDO.
  DEF VAR aux_centtext AS INT                                      NO-UNDO.
  DEF VAR aux_nmextcop AS CHAR                                     NO-UNDO.


  FORM  "\022\024\033\120\0330\033x0\033\105" /* Reseta e seta a fonte */
         SKIP(4) 
         crapcop.nmextcop       NO-LABEL                      AT 18
         SKIP                                                 
         par_dtmvtolt           NO-LABEL FORMAT "99/99/9999"  AT 13
         " SISTEMA AILOS  - CONVENIOS INSS "                  AT 28
         par_hrtransa NO-LABEL                                AT 65 
         SKIP                                                 
         "COMPROVANTE DE RENOVACAO PROVA DE VIDA INSS"        AT 21
         "\033\120\033\106"
         "\022\024\033\120" /* reseta impressora */
         "\0332\033x0"  
         SKIP (3) 
         par_nrbenefi LABEL "NIT/NB" FORMAT "zzzzzzzzz9"      AT 30
         SKIP                                                
         par_nmrecben LABEL "Beneficiario" FORMAT "X(28)"     AT 24
         SKIP(5)                                             
         par_nmprocur LABEL "Procurador" FORMAT "X(40)"       AT 26 
         SKIP                                                
         par_dsdocpcd LABEL "RG"  FORMAT "X(12)"              AT 34
         par_cdoedpcd LABEL "OE"  FORMAT "X(10)"              AT 54
         par_cdufdpcd LABEL "UF"  FORMAT "X(2)"               AT 69
         par_dtvalprc LABEL "Validade da procuracao"         
                                  FORMAT "99/99/9999"         AT 14
         SKIP(3)                                             
         "Seu recadastramento foi efetuado com sucesso em "   AT 13
         aux_dtmvtolt NO-LABEL FORMAT "99/99/9999"            AT 61
         SKIP(6)
         "--------------------------------------------------" AT 17
         SKIP
         aux_nmprocur NO-LABEL FORMAT "X(50)"                 AT 17
         SKIP(6)                                             
         "Proxima Renovacao Prova de Vida: "                  AT 21 
         aux_pxrnvida NO-LABEL FORMAT "99/99/9999"            AT 54
         WITH SIDE-LABEL COLUMN 10 WIDTH 132 FRAME f_declaracao_proc.

  FORM  "\022\024\033\120\0330\033x0\033\105" /* Reseta e seta a fonte */
         SKIP(4) 
         crapcop.nmextcop       NO-LABEL                      AT 18
         SKIP                                                
         par_dtmvtolt           NO-LABEL FORMAT "99/99/9999"  AT 13
         " SISTEMA AILOS  - CONVENIOS INSS "                  AT 28
         par_hrtransa NO-LABEL                                AT 65 
         SKIP                                                
         "COMPROVANTE DE RENOVACAO PROVA DE VIDA INSS"        AT 21
         "\033\120\033\106"                                  
         "\022\024\033\120" /* reseta impressora */          
         "\0332\033x0"                                       
         SKIP(3)                                             
         par_nrbenefi LABEL "NIT/NB" FORMAT "zzzzzzzzz9"      AT 30
         SKIP                                                
         par_nmrecben LABEL "Beneficiario" FORMAT "X(28)"     AT 24
         SKIP(5)                                             
         "Seu recadastramento foi efetuado com sucesso em "   AT 13
         aux_dtmvtolt NO-LABEL FORMAT "99/99/9999"            AT 61
         SKIP(6)                                             
         "--------------------------------------------------" AT 17
         SKIP                                                
         aux_nmrecben NO-LABEL FORMAT "X(50)"                 AT 17
         SKIP(6)                                             
         "Proxima Renovacao Prova de Vida: "                  AT 21 
         aux_pxrnvida NO-LABEL FORMAT "99/99/9999"            AT 54
         WITH SIDE-LABEL WIDTH 132 FRAME f_declaracao_ben.



  FORM   aux_nmextcop FORMAT "X(44)" NO-LABEL                 AT 2
         SKIP                                                 
         " SISTEMA AILOS  - CONVENIOS INSS "                  AT 7
         SKIP
         par_dtmvtolt           NO-LABEL FORMAT "99/99/9999"  AT 12
         " - " 
         par_hrtransa NO-LABEL                                AT 27
         SKIP                                                 
         "COMPROVANTE DE RENOVACAO PROVA DE VIDA INSS"        AT 2
         SKIP (1) 
         SKIP
         par_nrbenefi LABEL "NIT/NB" FORMAT "zzzzzzzzz9"      AT 10
         SKIP                                                
         par_nmrecben LABEL "Beneficiario" FORMAT "X(28)"     AT 4
         SKIP(1)                                             
         "Seu recadastramento foi efetuado com sucesso"       AT 2 
         SKIP 
         "em "                                                AT 2
         aux_dtmvtolt NO-LABEL FORMAT "99/99/9999"            AT 5
         SKIP(3)                                             
         "------------------------------------------"         AT 4
         SKIP                                                
         aux_nmrecben NO-LABEL FORMAT "X(42)"                 AT 4
         SKIP(1)                                             
         SKIP
         "Proxima Renovacao Prova de Vida: "                  AT 2 
         aux_pxrnvida NO-LABEL FORMAT "99/99/9999"            AT 35
         WITH SIDE-LABEL WIDTH 48 FRAME f_declaracao_ben_caixa.


  FORM   SKIP(5)
         aux_nmextcop FORMAT "X(44)" NO-LABEL                 AT 2
         SKIP                                                 
         " SISTEMA AILOS  - CONVENIOS INSS "                  AT 7
         SKIP
         par_dtmvtolt           NO-LABEL FORMAT "99/99/9999"  AT 12
         " - " 
         par_hrtransa NO-LABEL                                AT 27
         SKIP                                                 
         "COMPROVANTE DE RENOVACAO PROVA DE VIDA INSS"        AT 2
         SKIP (1) 
         SKIP
         par_nrbenefi LABEL "NIT/NB" FORMAT "zzzzzzzzz9"      AT 10
         SKIP                                                
         par_nmrecben LABEL "Beneficiario" FORMAT "X(28)"     AT 4
         SKIP(1)                                             
         "Seu recadastramento foi efetuado com sucesso"       AT 2 
         SKIP 
         "em "                                                AT 2
         aux_dtmvtolt NO-LABEL FORMAT "99/99/9999"            AT 5
         SKIP(3)                                             
         "------------------------------------------"         AT 4
         SKIP                                                
         aux_nmrecben NO-LABEL FORMAT "X(42)"                 AT 4
         SKIP(1)                                             
         SKIP
         "Proxima Renovacao Prova de Vida: "                  AT 2 
         aux_pxrnvida NO-LABEL FORMAT "99/99/9999"            AT 35
         SKIP(10)
         WITH SIDE-LABEL WIDTH 48 FRAME f_declaracao_ben_caixa2.


  FORM   aux_nmextcop FORMAT "X(44)"  NO-LABEL                AT 2
         SKIP                                                 
         " SISTEMA AILOS  - CONVENIOS INSS "                  AT 7
         SKIP
         par_dtmvtolt           NO-LABEL FORMAT "99/99/9999"  AT 12
         " - "
         par_hrtransa NO-LABEL                                AT 27 
         SKIP                                                 
         "COMPROVANTE DE RENOVACAO PROVA DE VIDA INSS"        AT 2
         SKIP (1) 
         par_nrbenefi LABEL "NIT/NB" FORMAT "zzzzzzzzz9"      AT 10
         SKIP                                                
         par_nmrecben LABEL "Beneficiario" FORMAT "X(28)"     AT 4
         SKIP(1)                                             
         par_nmprocur LABEL "Procurador" FORMAT "X(28)"       AT 6 
         SKIP                                                
         par_dsdocpcd LABEL "RG"  FORMAT "X(12)"              AT 14
         SKIP
         par_cdoedpcd LABEL "OE"  FORMAT "X(10)"              AT 14
         par_cdufdpcd LABEL "UF"  FORMAT "X(2)"               AT 29
         SKIP
         par_dtvalprc LABEL "Validade da procuracao"         
                                  FORMAT "99/99/9999"         AT 7
         SKIP(1)                                             
         "Seu recadastramento foi efetuado com sucesso"       AT 2
         SKIP 
         "em "                                                AT 2
         aux_dtmvtolt NO-LABEL FORMAT "99/99/9999"            AT 5
         SKIP(3)
         "------------------------------------------"         AT 4
         SKIP
         aux_nmprocur NO-LABEL FORMAT "X(42)"                 AT 4
         SKIP(1)                                             
         "Proxima Renovacao Prova de Vida: "                  AT 2 
         aux_pxrnvida NO-LABEL FORMAT "99/99/9999"            AT 35
         SKIP(5)
         WITH SIDE-LABEL WIDTH 48 FRAME f_declaracao_proc_caixa.
  

  FORM   aux_nmextcop FORMAT "X(44)"  NO-LABEL                AT 2
         SKIP                                                 
         " SISTEMA AILOS  - CONVENIOS INSS "                  AT 7
         SKIP
         par_dtmvtolt           NO-LABEL FORMAT "99/99/9999"  AT 12
         " - "
         par_hrtransa NO-LABEL                                AT 27 
         SKIP                                                 
         "COMPROVANTE DE RENOVACAO PROVA DE VIDA INSS"        AT 2
         SKIP (1) 
         par_nrbenefi LABEL "NIT/NB" FORMAT "zzzzzzzzz9"      AT 10
         SKIP                                                
         par_nmrecben LABEL "Beneficiario" FORMAT "X(28)"     AT 4
         SKIP(1)                                             
         par_nmprocur LABEL "Procurador" FORMAT "X(28)"       AT 6 
         SKIP                                                
         par_dsdocpcd LABEL "RG"  FORMAT "X(12)"              AT 14
         SKIP
         par_cdoedpcd LABEL "OE"  FORMAT "X(10)"              AT 14
         par_cdufdpcd LABEL "UF"  FORMAT "X(2)"               AT 29
         SKIP
         par_dtvalprc LABEL "Validade da procuracao"         
                                  FORMAT "99/99/9999"         AT 7
         SKIP(1)                                             
         "Seu recadastramento foi efetuado com sucesso"       AT 2
         SKIP 
         "em "                                                AT 2
         aux_dtmvtolt NO-LABEL FORMAT "99/99/9999"            AT 5
         SKIP(3)
         "------------------------------------------"         AT 4
         SKIP
         aux_nmprocur NO-LABEL FORMAT "X(42)"                 AT 4
         SKIP(1)                                             
         "Proxima Renovacao Prova de Vida: "                  AT 2 
         aux_pxrnvida NO-LABEL FORMAT "99/99/9999"            AT 35
         SKIP(10)
         WITH SIDE-LABEL WIDTH 48 FRAME f_declaracao_proc_caixa2.
  
  EMPTY TEMP-TABLE tt-erro.                                 
                                                            
                                                            
  ASSIGN aux_cdcritic = 0                                   
         aux_dscritic = ""                                  
         aux_pxrnvida = ?                                   
         aux_dtmvtolt = par_dtmvtolt                        
         aux_centtext = 0.

  Gera: DO WHILE TRUE:

      EMPTY TEMP-TABLE tt-erro.

      FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

      ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".
      
      Grava: DO TRANSACTION
          ON ERROR  UNDO Grava, LEAVE Grava
          ON QUIT   UNDO Grava, LEAVE Grava
          ON STOP   UNDO Grava, LEAVE Grava
          ON ENDKEY UNDO Grava, LEAVE Grava:

          ASSIGN aux_sittrans = "NOK".

          /*Realiza a comprovacao do beneficio*/
          ContadorCbi: DO aux_contador = 1 TO 10:
             
             FIND FIRST crapcbi WHERE crapcbi.cdcooper = par_cdcooper AND
                                      crapcbi.nrrecben = par_nrbenefi AND
                                      crapcbi.nrbenefi = 0
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
             
             IF NOT AVAIL crapcbi THEN
                FIND FIRST crapcbi WHERE crapcbi.cdcooper = par_cdcooper AND
                                         crapcbi.nrrecben = 0            AND
                                         crapcbi.nrbenefi = par_nrbenefi
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

             IF NOT AVAIL crapcbi   THEN
                IF LOCKED crapcbi   THEN
                   DO:
                      IF aux_contador = 10 THEN
                         DO:
                             ASSIGN aux_cdcritic = 77.
                             UNDO Grava, LEAVE Grava.
                         END.
                      ELSE 
                         DO:
                             PAUSE 1 NO-MESSAGE.
                             NEXT ContadorCbi.
                         END.
                   END.
                ELSE       
                   DO:   
                      ASSIGN aux_dscritic = "Nao foi possivel realizar " +
                                            "comprovacao de vida.".
                      UNDO Grava, LEAVE Grava.        

                   END.
             
             ASSIGN crapcbi.dtcompvi = par_dtmvtolt
                    crapcbi.indresvi = par_indresvi
                    crapcbi.dtenvipv = ?.
                                                    
             LEAVE ContadorCbi.

          END. /*Fim do ContadorCbi*/

          /*Realiza o desbloqueio do beneficio*/
          FOR EACH craplbi WHERE craplbi.cdcooper = crapcbi.cdcooper AND
                                 craplbi.nrrecben = crapcbi.nrrecben AND
                                 craplbi.nrbenefi = crapcbi.nrbenefi AND
                                 craplbi.cdbloque = 9 /*falta de comp.*/
                                 EXCLUSIVE-LOCK:
          
              ASSIGN craplbi.cdsitcre = 1
                     craplbi.cdbloque = 0.

          END.
                                                                     
      END. /*Fim da transacao - Grava*/

      RELEASE crapcbi.

      /******************** IMPRESSAO DA AUTORIZACAO ************************/
      ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" +
                            par_dsiduser.
      
      UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
  
      ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
             aux_nmarqimp = aux_nmarquiv + ".ex"
             aux_pxrnvida = ADD-INTERVAL(par_dtmvtolt,1,"YEAR")
             aux_nmrecben = par_nmrecben
             aux_nmprocur = par_nmprocur
             aux_nmextcop = crapcop.nmextcop.
                
      OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp).
      

      IF par_indresvi = 1 THEN
         DO:
            IF par_idorigem = 1 THEN /*ayllos*/
               DO:
                  ASSIGN aux_centtext = TRUNC(((50 - LENGTH(TRIM(aux_nmrecben))) / 2),0)
                         aux_nmrecben = FILL(" ",aux_centtext) + TRIM(aux_nmrecben).
                  
                  
                  /** Esta sendo emitido as duas vias em uma unica folha */
                  DISPLAY STREAM str_1 crapcop.nmextcop
                                       par_dtmvtolt
                                       par_hrtransa
                                       par_nrbenefi
                                       par_nmrecben
                                       aux_dtmvtolt
                                       aux_nmrecben
                                       aux_pxrnvida
                                       WITH FRAME f_declaracao_ben.
                  
                  DOWN WITH FRAME f_declaracao_ben.
                  
                  PUT STREAM str_1 SKIP(3)
                                   FILL("-",80) AT 13 FORMAT "x(80)".
                  
                  DISPLAY STREAM str_1 crapcop.nmextcop
                                       par_dtmvtolt
                                       par_hrtransa
                                       par_nrbenefi
                                       par_nmrecben
                                       aux_dtmvtolt
                                       aux_nmrecben
                                       aux_pxrnvida
                                       WITH FRAME f_declaracao_ben.

               END.
            ELSE
               DO: /*caixa on-line*/
                  ASSIGN aux_centtext = TRUNC(((42 - LENGTH(TRIM(aux_nmrecben))) / 2),0)
                         aux_nmrecben = FILL(" ",aux_centtext) + TRIM(aux_nmrecben)
                         aux_centtext = TRUNC(((44 - LENGTH(TRIM(crapcop.nmextcop))) / 2),0)
                         aux_nmextcop = FILL(" ",aux_centtext) + TRIM(aux_nmextcop).
                  
                  
                  DISPLAY STREAM str_1 aux_nmextcop
                                       par_dtmvtolt
                                       par_hrtransa
                                       par_nrbenefi
                                       par_nmrecben
                                       aux_dtmvtolt
                                       aux_nmrecben
                                       aux_pxrnvida
                                       WITH FRAME f_declaracao_ben_caixa.

                  DOWN STREAM str_1.

                  DISPLAY STREAM str_1 aux_nmextcop
                                       par_dtmvtolt
                                       par_hrtransa
                                       par_nrbenefi
                                       par_nmrecben
                                       aux_dtmvtolt
                                       aux_nmrecben
                                       aux_pxrnvida
                                       WITH FRAME f_declaracao_ben_caixa2.                                                   

                       
               END.

         END.
      ELSE
         DO:
            IF par_idorigem = 1 THEN /*ayllos*/
               DO:
                  ASSIGN aux_centtext = TRUNC(((42 - LENGTH(TRIM(aux_nmprocur))) / 2),0)
                         aux_nmprocur = FILL(" ",aux_centtext) + TRIM(aux_nmprocur).
                         
                  
                  /** Esta sendo emitido as duas vias em uma unica folha */
                  DISPLAY STREAM str_1 crapcop.nmextcop
                                       par_dtmvtolt
                                       par_hrtransa
                                       par_nrbenefi
                                       par_nmrecben
                                       par_nmprocur
                                       par_dsdocpcd
                                       par_cdoedpcd
                                       par_cdufdpcd
                                       aux_pxrnvida 
                                       par_dtvalprc
                                       aux_dtmvtolt
                                       aux_nmprocur
                                       WITH FRAME f_declaracao_proc.
                  
                  DOWN WITH FRAME f_declaracao_proc.
                  
                  PUT STREAM str_1 SKIP(3)
                                  FILL("-",80) AT 13 FORMAT "x(80)".

                  
                  DISPLAY STREAM str_1 crapcop.nmextcop
                                       par_dtmvtolt
                                       par_hrtransa
                                       par_nrbenefi
                                       par_nmrecben
                                       par_nmprocur
                                       par_dsdocpcd
                                       par_cdoedpcd
                                       par_cdufdpcd
                                       aux_pxrnvida 
                                       par_dtvalprc
                                       aux_dtmvtolt
                                       aux_nmprocur
                                       WITH FRAME f_declaracao_proc.

               END.
            ELSE
               DO: /*caixa on-line*/
                  ASSIGN aux_centtext = TRUNC(((42 - LENGTH(TRIM(aux_nmprocur))) / 2),0)
                         aux_nmprocur = FILL(" ",aux_centtext) + TRIM(aux_nmprocur)
                         aux_centtext = TRUNC(((44 - LENGTH(TRIM(crapcop.nmextcop))) / 2),0)
                         aux_nmextcop = FILL(" ",aux_centtext) + TRIM(aux_nmextcop).
                  
                  
                  DISPLAY STREAM str_1 aux_nmextcop
                                       par_dtmvtolt
                                       par_hrtransa
                                       par_nrbenefi
                                       par_nmrecben
                                       par_nmprocur
                                       par_dsdocpcd
                                       par_cdoedpcd
                                       par_cdufdpcd
                                       aux_pxrnvida 
                                       par_dtvalprc
                                       aux_dtmvtolt
                                       aux_nmprocur
                                       WITH FRAME f_declaracao_proc_caixa.

                  DOWN STREAM str_1.

                  DISPLAY STREAM str_1 aux_nmextcop
                                       par_dtmvtolt
                                       par_hrtransa
                                       par_nrbenefi
                                       par_nmrecben
                                       par_nmprocur
                                       par_dsdocpcd
                                       par_cdoedpcd
                                       par_cdufdpcd
                                       aux_pxrnvida 
                                       par_dtvalprc
                                       aux_dtmvtolt
                                       aux_nmprocur
                                       WITH FRAME f_declaracao_proc_caixa2.


               END.

         END.

      OUTPUT STREAM str_1 CLOSE.
        
      ASSIGN par_nmarqimp = aux_nmarqimp.
             aux_retornvl = "OK".

      LEAVE Gera.

  END.


  IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
     RUN gera_erro ( INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT 1,            /** Sequencia **/
                     INPUT aux_cdcritic,
                     INPUT-OUTPUT aux_dscritic).
  ELSE
     UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt, "99/99/9999") + " " +
                       STRING(TIME,"HH:MM:SS") + "' --> '"                +
                       " Operador "  + par_cdoperad              + " - "  +
                       " Efetuou a comprovacao de vida do NIT/NB "        +
                       STRING(par_nrbenefi) + "," + " atraves do "        + 
                       (IF par_indresvi = 1 THEN 
                           "beneficiario " + STRING(par_nrcpfcgc)
                        ELSE
                           "procurador " + STRING(par_dsdocpcd))          +
                       "." + " >> /usr/coop/" + TRIM(crapcop.dsdircop)    +
                       "/log/compvi.log").


  RETURN aux_retornvl.


END PROCEDURE.
  

/*FUNCAO RESPONSAVEL POR VERIFICAR OS ITENS ABAIXO:
  RETURN   => 1 - Beneficio bloqueado por falta de comprovacao de vida
              2 - Comprovacao ainda nao efetuada   
              3 - Menos de 60 dias para expirar o prazo de comprovacao  
  tpdconsu => 1 - Busca qualquer registro referente ao cpf informado
              2 - Busca um registro especifico */
FUNCTION verificacao_bloqueio RETURNS INTEGER
         (INPUT par_cdcooper AS INT,
          INPUT par_nrdcaixa AS INT,
          INPUT par_cdagenci AS INT,
          INPUT par_cdoperad AS CHAR,
          INPUT par_nmdatela AS CHAR,
          INPUT par_idorigem AS INT,
          INPUT par_dtmvtolt AS DATE,
          INPUT par_nrcpfcgc AS DEC,
          INPUT par_nrprocur AS DEC,
          INPUT par_tpdconsu AS INT):

    DEF VAR aux_tpbloque AS INT                                    NO-UNDO.
    DEF VAR aux_bloqueio AS INT                                    NO-UNDO.

    DEF BUFFER b-crapcbi1 FOR crapcbi.

    ASSIGN aux_tpbloque = 0
           aux_bloqueio = 0.

    /*Qualquer beneficio com referencia ao cpf informado*/
    IF par_tpdconsu = 1 THEN
       FOR EACH b-crapcbi1 WHERE b-crapcbi1.cdcooper = par_cdcooper AND
                                 b-crapcbi1.nrcpfcgc = par_nrcpfcgc  
                                 NO-LOCK:

           RUN bloqueio(INPUT b-crapcbi1.cdcooper,
                        INPUT b-crapcbi1.nrrecben,
                        INPUT b-crapcbi1.nrbenefi,
                        INPUT b-crapcbi1.dtcompvi,
                        INPUT par_dtmvtolt,
                        OUTPUT aux_bloqueio).

           IF aux_bloqueio > aux_tpbloque THEN
              ASSIGN aux_tpbloque = aux_bloqueio.

       END.
    ELSE
       IF par_tpdconsu = 2 THEN /*Busca beneficio informado*/
          DO:
             FOR EACH b-crapcbi1 WHERE b-crapcbi1.cdcooper = par_cdcooper AND
                                       b-crapcbi1.nrrecben = 0            AND
                                       b-crapcbi1.nrbenefi = par_nrprocur
                                       NO-LOCK:

                 RUN bloqueio(INPUT b-crapcbi1.cdcooper,
                              INPUT b-crapcbi1.nrrecben,
                              INPUT b-crapcbi1.nrbenefi,
                              INPUT b-crapcbi1.dtcompvi,
                              INPUT par_dtmvtolt,
                              OUTPUT aux_bloqueio).

                 IF aux_bloqueio > aux_tpbloque THEN
                    ASSIGN aux_tpbloque = aux_bloqueio.
            
             END.

             FOR EACH b-crapcbi1 WHERE b-crapcbi1.cdcooper = par_cdcooper AND
                                       b-crapcbi1.nrrecben = par_nrprocur AND
                                       b-crapcbi1.nrbenefi = 0
                                       NO-LOCK:
            
                 RUN bloqueio(INPUT b-crapcbi1.cdcooper,
                              INPUT b-crapcbi1.nrrecben,
                              INPUT b-crapcbi1.nrbenefi,
                              INPUT b-crapcbi1.dtcompvi,
                              INPUT par_dtmvtolt,
                              OUTPUT aux_bloqueio).

                 IF aux_bloqueio > aux_tpbloque THEN
                    ASSIGN aux_tpbloque = aux_bloqueio.

             END.

          END.
          
    RETURN aux_tpbloque.
    
END FUNCTION.


/*PROCEDURE RESPONSAVEL POR ENCONTRAR ALGUMA RESTRICAO REFERENTE 
  A COMPROVACAO DE VIDA.*/
PROCEDURE bloqueio:

    DEF INPUT PARAM par_cdcopben AS INT                              NO-UNDO.
    DEF INPUT PARAM par_nrrecben AS DEC                              NO-UNDO.
    DEF INPUT PARAM par_nrbenefi AS DEC                              NO-UNDO.
    DEF INPUT PARAM par_dtcompvi AS DATE                             NO-UNDO.
    DEF INPUT PARAM par_dtdmovto AS DATE                             NO-UNDO.

    DEF OUTPUT PARAM par_tpbloque AS INT                             NO-UNDO.
    
    DEF VAR aux_przexpir AS LOGICAL                                  NO-UNDO.

    DEF BUFFER b-craplbi1 FOR craplbi.

    ASSIGN aux_przexpir = FALSE.

    /*Busca beneficios bloqueados (cdsitcre = 2) por falta de comprovacao de 
      vida (cdbloque = 9)*/
    FIND FIRST b-craplbi1 WHERE b-craplbi1.cdcooper = par_cdcopben  AND
                                b-craplbi1.nrrecben = par_nrrecben  AND
                                b-craplbi1.nrbenefi = par_nrbenefi  AND
                                b-craplbi1.cdsitcre = 2             AND
                                b-craplbi1.cdbloque = 9             
                                NO-LOCK NO-ERROR.

    IF AVAIL b-craplbi1 THEN
       DO:
           ASSIGN par_tpbloque = 1.
           RETURN "OK".

       END.
  
    /*Busca beneficios que estao sem comprovacao de vida, se recebe no mes
      atual ou se recebeu nos ultimos 2 meses.*/
    FIND FIRST b-craplbi1 
         WHERE b-craplbi1.cdcooper = par_cdcopben                    AND
               b-craplbi1.nrrecben = par_nrrecben                    AND
               b-craplbi1.nrbenefi = par_nrbenefi                    AND
              (b-craplbi1.dtfimpag >= par_dtdmovto                    OR
               b-craplbi1.dtdpagto >= (ADD-INTERVAL(par_dtdmovto,-2,     
                                      "MONTH")))                     AND
               par_dtcompvi = ?                                   
               NO-LOCK NO-ERROR.

    IF AVAIL b-craplbi1 THEN
       DO:
          ASSIGN par_tpbloque = 2.
          RETURN "OK".

       END.
     
    /*Verifica se a data de comprovacao de vida esta proximo dos
      60 dias em relacao ao prazo final.*/
    IF ADD-INTERVAL(par_dtcompvi,1,"YEAR") >= par_dtdmovto THEN
       DO:
          IF (ADD-INTERVAL(par_dtcompvi,1,"YEAR") - par_dtdmovto) <=
             (ADD-INTERVAL(par_dtdmovto,2,"MONTH") - par_dtdmovto) THEN
              ASSIGN aux_przexpir = TRUE.
       END.
    ELSE
       IF (par_dtdmovto - ADD-INTERVAL(par_dtcompvi,1,"YEAR")) <=
          (par_dtdmovto - ADD-INTERVAL(par_dtdmovto,-2,"MONTH") ) THEN
          ASSIGN aux_przexpir = TRUE.

    /*Busca registros que realizaram comprovacao de vida e que, a data de
     comprovacao, esteja proximo aos 60 dias da data de expiracao da 
     comprovacao (prazo de um ano a partir da data de comprovacao).*/
    FIND FIRST b-craplbi1 WHERE b-craplbi1.cdcooper = par_cdcopben  AND
                                b-craplbi1.nrrecben = par_nrrecben  AND
                                b-craplbi1.nrbenefi = par_nrbenefi  AND
                                b-craplbi1.dtfimpag >= par_dtdmovto AND
                                par_dtcompvi <> ?                   AND
                                aux_przexpir
                                NO-LOCK NO-ERROR.

    IF AVAIL b-craplbi1 THEN
       DO: 
          ASSIGN par_tpbloque = 3.
          RETURN "OK".
       END.

    /*Se o beneficiario recebeu no mes ou nos ultimos 2 meses e que necessitam
      comprovar vida ainda neste ano.*/
    FIND FIRST b-craplbi1 
         WHERE b-craplbi1.cdcooper = par_cdcopben                    AND
               b-craplbi1.nrrecben = par_nrrecben                    AND
               b-craplbi1.nrbenefi = par_nrbenefi                    AND
              (b-craplbi1.dtfimpag >= par_dtdmovto                    OR
               b-craplbi1.dtdpagto >= (ADD-INTERVAL(par_dtdmovto,-2,     
                                      "MONTH")))                     AND
               YEAR(par_dtcompvi) < YEAR(par_dtdmovto)
               NO-LOCK NO-ERROR.

    IF AVAIL b-craplbi1 THEN
       DO:
          ASSIGN par_tpbloque = 4.
          RETURN "OK".

       END.
     
    RETURN "OK".

END PROCEDURE.

/* FUNCAO RESPONSAVEL PELOS ITENS ABAIXO:
   RETURN => TRUE - Beneficiario possue um procurador */
FUNCTION busca_procurador_beneficio RETURNS LOGICAL
        (INPUT par_cdcooper AS INT,
         INPUT par_cdagenci AS INT,
         INPUT par_cdoperad AS CHAR,
         INPUT par_nrdcaixa AS INT,
         INPUT par_nmdatela AS CHAR,
         INPUT par_cdcopben AS INT,
         INPUT par_nrrecben AS DEC,
         INPUT par_nrbenefi AS DEC,
         OUTPUT TABLE FOR tt-lancred):

    EMPTY TEMP-TABLE tt-lancred.
                                      
    FIND crappbi WHERE crappbi.cdcooper = par_cdcopben AND
                       crappbi.nrrecben = par_nrrecben AND
                       crappbi.nrbenefi = par_nrbenefi
                       NO-LOCK NO-ERROR.

    IF AVAIL crappbi THEN
       DO:
           CREATE tt-lancred.

           ASSIGN tt-lancred.cdcooper = crappbi.cdcooper
                  tt-lancred.dtmvtolt = crappbi.dtmvtolt
                  tt-lancred.nrbenefi = crappbi.nrbenefi
                  tt-lancred.nmprocur = crappbi.nmprocur
                  tt-lancred.dsdocpcd = crappbi.dsdocpcd
                  tt-lancred.nrdocpcd = crappbi.nrdocpcd
                  tt-lancred.cdoedpcd = crappbi.cdoedpcd
                  tt-lancred.cdufdpcd = crappbi.cdufdpcd
                  tt-lancred.dtvalprc = crappbi.dtvalprc
                  tt-lancred.nrrecben = crappbi.nrrecben
                  tt-lancred.cdorgpag = crappbi.cdorgpag
                  tt-lancred.flgexist = TRUE.

          RETURN TRUE.

       END.

    RETURN FALSE.

END FUNCTION.  

  
/*PROCEDURE RESPONSAVEL PELA OPCAO "G" DA TELA COMPVI*/
PROCEDURE gera_arquivo_comprovacao_vida:

  DEF INPUT PARAM par_cdcooper AS INT                              NO-UNDO.
  DEF INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
  DEF INPUT PARAM par_nrdcaixa AS INT                              NO-UNDO.
  DEF INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
  DEF INPUT PARAM par_nmdatela AS CHAR                             NO-UNDO.
  DEF INPUT PARAM par_cdagenci AS INT                              NO-UNDO.
  DEF INPUT PARAM par_idorigem AS INT                              NO-UNDO.
  DEF INPUT PARAM par_coopcomp AS INT                              NO-UNDO.

  DEF OUTPUT PARAM TABLE FOR tt-erro.
  DEF OUTPUT PARAM TABLE FOR tt-arquivos-comp-vida.

  DEF VAR aux_sittrans AS LOG                                      NO-UNDO.
  DEF VAR aux_contador AS INT                                      NO-UNDO.
  DEF VAR aux_nmarqger AS CHAR                                     NO-UNDO.
  DEF VAR aux_dscooper AS CHAR                                     NO-UNDO.
  DEF VAR aux_nrseqlot AS INT                                      NO-UNDO.    
  DEF VAR aux_nrseqreg AS INT                                      NO-UNDO.    
  DEF VAR aux_qttotreg AS INT                                      NO-UNDO.   
  DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.
  DEF VAR aux_cdcritic AS INT                                      NO-UNDO.
  DEF VAR aux_dsdmeses AS CHAR EXTENT 12                          
                               INIT["1","2","3","4","5","6",     
                                    "7","8","9","O","N","D"]       NO-UNDO.

  EMPTY TEMP-TABLE tt-arquivos-comp-vida.
  EMPTY TEMP-TABLE tt-erro.

  ASSIGN aux_nmarqger = ""
         aux_dscooper = ""
         aux_nrseqlot = 0
         aux_nrseqreg = 0
         aux_qttotreg = 0
         aux_dscritic = ""
         aux_cdcritic = 0
         aux_contador = 0
         aux_sittrans = FALSE.
       

  FOR EACH crapcop WHERE (IF par_coopcomp <> 0 THEN 
                             crapcop.cdcooper = par_coopcomp
                          ELSE
                             crapcop.cdcooper <> 3)
                          NO-LOCK:

      ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/"
             aux_nrseqlot = 0
             aux_nrseqreg = 0
             aux_qttotreg = 0
             aux_sittrans = FALSE.
      
      Gera: DO TRANSACTION
            ON ERROR  UNDO Gera, LEAVE Gera
            ON QUIT   UNDO Gera, LEAVE Gera
            ON STOP   UNDO Gera, LEAVE Gera
            ON ENDKEY UNDO Gera, LEAVE Gera:

            RUN pi_busca_sequencia (INPUT crapcop.cdcooper, 
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT 0) /*tipo registro*/.
    
            IF RETURN-VALUE <> "OK"   THEN
               UNDO Gera, LEAVE Gera. 

            /* Monta o nome do arquivo */
            ASSIGN aux_nmarqger = "0" + STRING(crapcop.cdagebcb,"9999") +
                                  STRING(DAY(par_dtmvtolt),"99")    +
                                  aux_dsdmeses[MONTH(par_dtmvtolt)] +
                                  ".RET" + craptab.dstextab.

            RUN pi_atualiza_sequencia (INPUT 0).
            
            /*Se nao houver alguma comprovacao entao, nao sera criado o 
              arquivo para envio*/
            FIND FIRST crapcbi WHERE crapcbi.cdcooper = crapcop.cdcooper AND
                                     crapcbi.dtenvipv = ?                AND
                                     crapcbi.dtcompvi <> ?               
                                     NO-LOCK NO-ERROR.
            
            IF NOT AVAIL crapcbi THEN
               DO:
                  CREATE tt-arquivos-comp-vida.
                  
                  ASSIGN tt-arquivos-comp-vida.cdcooepr = crapcop.cdcooper
                         tt-arquivos-comp-vida.nmrescop = crapcop.nmrescop
                         tt-arquivos-comp-vida.dscsitua = "Nao ha comprovacoes " + 
                                                          "nesta data".
            
                  RELEASE craptab.
                  NEXT.
            
               END.
            
            OUTPUT STREAM str_1 TO VALUE (aux_dscooper + "arq/" + aux_nmarqger).
            
            RUN pi_busca_sequencia (INPUT crapcop.cdcooper, 
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT 30) /*tipo registro*/.
    
            IF RETURN-VALUE <> "OK"   THEN
               UNDO Gera, LEAVE Gera. 
            
            FOR EACH crapcbi WHERE crapcbi.cdcooper = crapcop.cdcooper AND
                                   crapcbi.dtenvipv = ?                AND
                                   crapcbi.dtcompvi <> ?               
                                   EXCLUSIVE-LOCK BREAK BY crapcbi.tpmepgto:

                IF FIRST-OF(crapcbi.tpmepgto) THEN
                   DO:
                      ASSIGN aux_nrseqlot = aux_nrseqlot + 1
                             aux_nrseqreg = aux_nrseqreg + 1
                             aux_qttotreg = 0.
                      
                      /* Header do lote */
                      PUT STREAM  str_1 UNFORMATTED
                                  "1"
                                  STRING(aux_nrseqreg,"9999999")
                                  "30"
                                  "756"
                                  "02"          
                                  SUBSTRING(STRING(par_dtmvtolt,"99999999"),5,4)
                                  SUBSTRING(STRING(par_dtmvtolt,"99999999"),3,2)
                                  SUBSTRING(STRING(par_dtmvtolt,"99999999"),1,2)
                                  STRING(aux_nrseqlot,"99")
                                  "CONPAG"
                                  FILL(" ",63)                    
                                  STRING(craptab.dstextab,"x(6)")  
                                  FILL(" ",140)
                                  SKIP.
                                       
                   END.
 
                ASSIGN aux_nrseqreg = aux_nrseqreg + 1
                       aux_qttotreg = aux_qttotreg + 1.
                       
                            
                /* Detalhe */     
                PUT STREAM  str_1 UNFORMATTED
                            "2"
                            STRING(aux_nrseqreg,"9999999")
                            STRING(crapcbi.nrbenefi,"9999999999")   /** NB **/ 
                            FILL("0",8)  
                            STRING(crapcbi.cdorgpag,"999999")  
                            FILL(" ",1)
                            FILL("0",10)  
                            FILL(" ",1)
                            FILL("0",10)
                            "5"
                            FILL("0",6)
                            FILL(" ",11)          
                            FILL(" ",28)
                            STRING(crapcbi.nrrecben,"99999999999")  /** NIT **/
                            FILL("0",11) 
                            SUBSTRING(STRING(crapcbi.dtcompvi,"99999999"),5,4)
                            SUBSTRING(STRING(crapcbi.dtcompvi,"99999999"),3,2)
                            SUBSTRING(STRING(crapcbi.dtcompvi,"99999999"),1,2)
                            FILL(" ",104)
                            STRING(crapcbi.indresvi,"9")
                            FILL(" ",5)
                            SKIP.
                
            
                IF LAST-OF(crapcbi.tpmepgto) THEN
                   DO:
                      ASSIGN aux_nrseqreg = aux_nrseqreg + 1.
                             
                      /* Trailer do lote */
                      PUT STREAM  str_1 UNFORMATTED
                                  "3"
                                  STRING(aux_nrseqreg,"9999999")
                                  "30"
                                  "756"
                                  STRING(aux_qttotreg,"99999999")
                                  STRING(aux_nrseqlot,"99")
                                  FILL(" ",217)
                                  SKIP.

                      RUN pi_atualiza_sequencia (INPUT 30 /*tipo registro*/).
                
                   END.

                ASSIGN crapcbi.dtenvipv = par_dtmvtolt.

            END.

            OUTPUT STREAM str_1 CLOSE.

            ASSIGN aux_sittrans = TRUE.
                   

      END. /*Fim do transaction Gera */

      RELEASE craptab.
      RELEASE crapcbi.

      IF aux_cdcritic <> 0  OR
         aux_dscritic <> "" THEN
         DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT crapcop.cdcooper,  /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
      
             RETURN "NOK".

         END.

      IF aux_sittrans = FALSE THEN
         NEXT.

      /* copia o arquivo para diretorio do BANCOOB */
      UNIX SILENT VALUE("ux2dos < " + aux_dscooper + "arq/" + aux_nmarqger +
                        ' | tr -d "\032"' +
                        " > /micros/" + crapcop.dsdircop +
                        "/bancoob/" + aux_nmarqger + " 2>/dev/null").
     
      /* Move para o salvar */
      UNIX SILENT VALUE("mv " + aux_dscooper + "arq/" + aux_nmarqger +
                        " " + aux_dscooper + "salvar 2>/dev/null").

      CREATE tt-arquivos-comp-vida.
            
      ASSIGN tt-arquivos-comp-vida.cdcooepr = crapcop.cdcooper
             tt-arquivos-comp-vida.nmrescop = crapcop.nmrescop
             tt-arquivos-comp-vida.nmarquiv = "/micros/" + 
                                              crapcop.dsdircop +
                                              "/bancoob/" + aux_nmarqger
             tt-arquivos-comp-vida.dscsitua = "Gerado com sucesso".
  

      UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt, "99/99/9999") + " " +
                       STRING(TIME,"HH:MM:SS") + "' --> '"                 + 
                       " Operador "  + par_cdoperad              + " - "   +
                       " Gerou o arquivo de comprovacao de vida da "       + 
                       "cooperativa " + crapcop.nmrescop + "."             + 
                       " >> /usr/coop/" + TRIM(crapcop.dsdircop)     +
                       "/log/compvi.log").


  END.

  RETURN "OK".

END PROCEDURE.

    
/* ************************************************************************* */
/*                      Busca beneficiarios INSS - COMPVI                    */
/* ************************************************************************* */
PROCEDURE busca-benefic-compvi:

    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INT                                NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                               NO-UNDO.
                                                                    
    DEF INPUT PARAM par_nmrecben AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_cdageins AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrcpfcgc AS DECI                               NO-UNDO.
    DEF INPUT PARAM par_nrprocur AS DECI                               NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                               NO-UNDO.
                                                                     
    DEF OUTPUT PARAM aux_qtregist AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.                             
    DEF OUTPUT PARAM TABLE FOR tt-benefic.                          
                                                                    
    DEF VAR aux_nrregist AS INTE                                       NO-UNDO.
    DEF VAR aux_tpbloque AS INTE                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-benefic.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_nrregist = par_nrregist
           aux_tpbloque = 0.
 
    Busca: 
    DO WHILE TRUE:
          
       IF par_nrprocur <> 0  THEN
          DO:     
             FOR EACH crapcbi WHERE crapcbi.cdcooper = par_cdcooper AND
                                    crapcbi.nrrecben = par_nrprocur 
                                    NO-LOCK:
                 
                 ASSIGN aux_tpbloque = verificacao_bloqueio(
                                       INPUT crapcbi.cdcooper,         
                                       INPUT par_nrdcaixa,             
                                       INPUT par_cdagenci,             
                                       INPUT par_cdoperad,             
                                       INPUT par_nmdatela,             
                                       INPUT par_idorigem,             
                                       INPUT par_dtmvtolt,             
                                       INPUT crapcbi.nrcpfcgc,         
                                       INPUT (IF crapcbi.nrrecben <> 0 THEN 
                                                 crapcbi.nrrecben
                                              ELSE
                                                 crapcbi.nrbenefi),
                                       INPUT 2 /*Ben. Especifico*/).
                          
                 IF aux_tpbloque <> 0 THEN
                    RUN gera-tt-benefic(INPUT par_cdcooper,
                                        INPUT par_nrregist,
                                        INPUT par_nriniseq,
                                        INPUT-OUTPUT aux_nrregist,
                                        INPUT-OUTPUT aux_qtregist,
                                        INPUT-OUTPUT TABLE tt-benefic).   


             END.

             IF NOT TEMP-TABLE tt-benefic:HAS-RECORDS  THEN
                DO:
                   FOR EACH crapcbi 
                       WHERE crapcbi.cdcooper = par_cdcooper AND
                             crapcbi.nrbenefi = par_nrprocur 
                             NO-LOCK:

                       ASSIGN aux_tpbloque = verificacao_bloqueio(
                                             INPUT crapcbi.cdcooper,         
                                             INPUT par_nrdcaixa,             
                                             INPUT par_cdagenci,             
                                             INPUT par_cdoperad,             
                                             INPUT par_nmdatela,             
                                             INPUT par_idorigem,             
                                             INPUT par_dtmvtolt,             
                                             INPUT crapcbi.nrcpfcgc,         
                                             INPUT (IF crapcbi.nrrecben <> 0 THEN 
                                                       crapcbi.nrrecben
                                                    ELSE
                                                       crapcbi.nrbenefi),
                                             INPUT 2 /*Ben. Especifico*/).
                          
                       IF aux_tpbloque <> 0 THEN
                          RUN gera-tt-benefic(INPUT par_cdcooper,
                                              INPUT par_nrregist,
                                              INPUT par_nriniseq,
                                              INPUT-OUTPUT aux_nrregist,
                                              INPUT-OUTPUT aux_qtregist,
                                              INPUT-OUTPUT TABLE tt-benefic).

                   END.

                END.

          END.
       ELSE
       IF par_nrcpfcgc <> 0  THEN
          DO:
             FOR EACH crapcbi WHERE crapcbi.cdcooper = par_cdcooper AND
                                    crapcbi.nrcpfcgc = par_nrcpfcgc 
                                    NO-LOCK:

                 ASSIGN aux_tpbloque = verificacao_bloqueio(
                                       INPUT crapcbi.cdcooper,         
                                       INPUT par_nrdcaixa,             
                                       INPUT par_cdagenci,             
                                       INPUT par_cdoperad,             
                                       INPUT par_nmdatela,             
                                       INPUT par_idorigem,             
                                       INPUT par_dtmvtolt,             
                                       INPUT crapcbi.nrcpfcgc,         
                                       INPUT (IF crapcbi.nrrecben <> 0 THEN 
                                                 crapcbi.nrrecben
                                              ELSE
                                                 crapcbi.nrbenefi),
                                       INPUT 2 /*Ben. Especifico*/).
                          
                 IF aux_tpbloque <> 0 THEN
                    RUN gera-tt-benefic(INPUT par_cdcooper,
                                        INPUT par_nrregist,
                                        INPUT par_nriniseq,
                                        INPUT-OUTPUT aux_nrregist,
                                        INPUT-OUTPUT aux_qtregist,
                                        INPUT-OUTPUT TABLE tt-benefic ).

             END.

          END.
       ELSE
       IF par_cdageins = 0  THEN
          DO:
             FOR EACH crapcbi WHERE crapcbi.cdcooper = par_cdcooper  AND
                                    crapcbi.nmrecben MATCHES "*" +
                                            par_nmrecben + "*"
                                    NO-LOCK BY crapcbi.nmrecben:

                 ASSIGN aux_tpbloque = verificacao_bloqueio(
                                       INPUT crapcbi.cdcooper,         
                                       INPUT par_nrdcaixa,             
                                       INPUT par_cdagenci,             
                                       INPUT par_cdoperad,             
                                       INPUT par_nmdatela,             
                                       INPUT par_idorigem,             
                                       INPUT par_dtmvtolt,             
                                       INPUT crapcbi.nrcpfcgc,         
                                       INPUT (IF crapcbi.nrrecben <> 0 THEN 
                                                 crapcbi.nrrecben
                                              ELSE
                                                 crapcbi.nrbenefi),
                                       INPUT 2 /*Ben. Especifico*/).
                          
                 IF aux_tpbloque <> 0 THEN
                    RUN gera-tt-benefic(INPUT par_cdcooper,
                                        INPUT par_nrregist,
                                        INPUT par_nriniseq,
                                        INPUT-OUTPUT aux_nrregist,
                                        INPUT-OUTPUT aux_qtregist,
                                        INPUT-OUTPUT TABLE tt-benefic ).

             END.

          END.
       ELSE
          DO:
             FIND crapage WHERE crapage.cdcooper = par_cdcooper   AND
                                crapage.cdagenci = par_cdageins 
                                NO-LOCK NO-ERROR.
             
             IF NOT AVAILABLE crapage  THEN   
                DO:
                    ASSIGN aux_cdcritic = 962.
                    LEAVE Busca.
         
                END.
         
             FOR EACH crapcbi WHERE crapcbi.cdcooper = par_cdcooper   AND
                                    crapcbi.cdagenci = par_cdageins   AND
                                    crapcbi.nmrecben MATCHES "*" + 
                                            par_nmrecben + "*"
                                    NO-LOCK BY crapcbi.nmrecben:
         
                 ASSIGN aux_tpbloque = verificacao_bloqueio(
                                       INPUT crapcbi.cdcooper,         
                                       INPUT par_nrdcaixa,             
                                       INPUT par_cdagenci,             
                                       INPUT par_cdoperad,             
                                       INPUT par_nmdatela,             
                                       INPUT par_idorigem,             
                                       INPUT par_dtmvtolt,             
                                       INPUT crapcbi.nrcpfcgc,         
                                       INPUT (IF crapcbi.nrrecben <> 0 THEN 
                                                 crapcbi.nrrecben
                                              ELSE
                                                 crapcbi.nrbenefi),
                                       INPUT 2 /*Ben. Especifico*/).
                          
                 IF aux_tpbloque <> 0 THEN
                    RUN gera-tt-benefic(INPUT par_cdcooper,
                                        INPUT par_nrregist,
                                        INPUT par_nriniseq,
                                        INPUT-OUTPUT aux_nrregist,
                                        INPUT-OUTPUT aux_qtregist,
                                        INPUT-OUTPUT TABLE tt-benefic).
         
             END.           
         
          END.
          
       IF NOT(CAN-FIND(FIRST tt-benefic NO-LOCK)) THEN
          DO:
              ASSIGN aux_dscritic = "Nenhum beneficio encontrado.".
              LEAVE Busca.
          END.

       LEAVE.

    END.

    IF aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
       DO:
           RUN gera_erro ( INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic ).

           RETURN "NOK".

       END.

    RETURN "OK".

END PROCEDURE. /* Fim busca-benefic-beinss */

                           
PROCEDURE gera_cabecalho_soap PRIVATE:

    DEF INPUT PARAM par_idservic AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nmmetodo AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_username AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_password AS CHAR                            NO-UNDO.

    DEF VAR aux_nmservic AS CHAR                                    NO-UNDO.

    RUN cria_objetos_soap.

    /** Criacao do Envelope SOAP **/
    hXmlSoap:CREATE-NODE(hXmlEnvelope,"soapenv:Envelope","ELEMENT").

    CASE par_idservic:
      WHEN 1 THEN /*Consulta (Beneficiario e Demonstrativo)*/
         DO:
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:ben",
               "http://sicredi.com.br/convenios/cadastro/BeneficiarioINSS").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:soapenv",
               "http://schemas.xmlsoap.org/soap/envelope/").
            
         END. 
      WHEN 2 THEN /*Alteracao e Inclusao (Beneficiario)*/
         DO:
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:ben",
               "http://sicredi.com.br/convenios/cadastro/BeneficiarioINSS").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:soapenv",
               "http://schemas.xmlsoap.org/soap/envelope/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v1",
               "http://sicredi.com.br/cadastro/pessoa/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v12",
               "http://sicredi.com.br/cadastro/localidade/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v11",
               "http://sicredi.com.br/cadastro/bens/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v13",
               "http://sicredi.com.br/cadastro/contato/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v14",
               "http://sicredi.com.br/convenios/cadastro/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v15",
               "http://sicredi.com.br/cadastro/entidade/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v16",
               "http://sicredi.com.br/convenios/pagamento/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v17",
               "http://sicredi.com.br/contas/conta/cmodel/v1/").
    
         END.

      WHEN 3 THEN /*Efetivacao de prova de vida*/
         DO:
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:prov",
               "http://sicredi.com.br/convenios/pagamento/ProvaDeVida").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:soapenv",
               "http://schemas.xmlsoap.org/soap/envelope/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v1",
               "http://sicredi.com.br/cadastro/pessoa/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v12",
               "http://sicredi.com.br/cadastro/localidade/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v11",
               "http://sicredi.com.br/cadastro/bens/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v13",
               "http://sicredi.com.br/cadastro/contato/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v14",
               "http://sicredi.com.br/convenios/cadastro/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v15",
               "http://sicredi.com.br/cadastro/entidade/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v16",
               "http://sicredi.com.br/convenios/pagamento/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v17",
               "http://sicredi.com.br/contas/conta/cmodel/v1/").

         END.

      
      WHEN 4 THEN /*Relatorios (Beneficios pagos/A pagar e bloqueado)*/
         DO:
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:soapenv",
               "http://schemas.xmlsoap.org/soap/envelope/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:rel",
               "http://sicredi.com.br/convenios/pagamento/RelatorioBeneficioINSS").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v1",
               "http://sicredi.com.br/cadastro/pessoa/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v12",
               "http://sicredi.com.br/cadastro/localidade/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v11",
               "http://sicredi.com.br/cadastro/bens/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v13",
               "http://sicredi.com.br/cadastro/contato/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v14",
               "http://sicredi.com.br/cadastro/entidade/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:dad",
               "http://sicredi.com.br/convenios/pagamento/DadosBeneficioINSS").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v15",
                "http://sicredi.com.br/convenios/cadastro/cmodel/v1/").   
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v16",
               "http://sicredi.com.br/convenios/pagamento/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v17",
               "http://sicredi.com.br/contas/conta/cmodel/v1/").
         END.

      WHEN 5 THEN
         DO:
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:soapenv", "http://schemas.xmlsoap.org/soap/envelope/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:arr",     "http://sicredi.com.br/convenios/pagamento/ArrecadacaoGPSINSS").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v1",      "http://sicredi.com.br/cadastro/entidade/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v11",     "http://sicredi.com.br/cadastro/pessoa/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v12",     "http://sicredi.com.br/cadastro/localidade/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v13",     "http://sicredi.com.br/cadastro/bens/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v14",     "http://sicredi.com.br/cadastro/contato/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v15",     "http://sicredi.com.br/convenios/pagamento/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:aut",     "http://sicredi.com.br/convenios/pagamento/Autenticacao").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v16",     "http://sicredi.com.br/contas/conta/cmodel/v1/").
            hXmlEnvelope:SET-ATTRIBUTE("xmlns:v17",     "http://sicredi.com.br/contas/cadastro/cmodel/v1/").
         END.


    END CASE.

    hXmlSoap:APPEND-CHILD(hXmlEnvelope).
         
    /** Criacao do SOAP HEADER **/
    hXmlSoap:CREATE-NODE(hXmlHeader,"soapenv:Header","ELEMENT").
    hXmlEnvelope:APPEND-CHILD(hXmlHeader).
    
    /*Cria as tags de seguranca informando uruario e senha.*/
    hXmlSoap:CREATE-NODE(hXmlWsse,"wsse:Security","ELEMENT").
    hXmlHeader:APPEND-CHILD(hXmlWsse).
    hXmlWsse:SET-ATTRIBUTE("soapenv:mustUnderstand","1").
    hXmlWsse:SET-ATTRIBUTE("xmlns:wsse","http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd").

    hXmlSoap:CREATE-NODE(hXmlUsernameToken,"wsse:UsernameToken","ELEMENT").
    hXmlWsse:APPEND-CHILD(hXmlUsernameToken).
    hXmlUsernameToken:SET-ATTRIBUTE("wsu:Id","UsernameToken-4").
    hXmlUsernameToken:SET-ATTRIBUTE("xmlns:wsu","http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd").

    hXmlSoap:CREATE-NODE(hXmlNode1Soap,"wsse:Username","ELEMENT").
    hXmlUsernameToken:APPEND-CHILD(hXmlNode1Soap).
    
    hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
    hXmlNode1Soap:APPEND-CHILD(hXmlTextSoap).
    hXmlTextSoap:NODE-VALUE = par_username. 

    hXmlSoap:CREATE-NODE(hXmlNode1Soap,"wsse:Password","ELEMENT").
    hXmlNode1Soap:SET-ATTRIBUTE("TYPE","http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText").
    hXmlUsernameToken:APPEND-CHILD(hXmlNode1Soap).
    
    hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
    hXmlNode1Soap:APPEND-CHILD(hXmlTextSoap).
    hXmlTextSoap:NODE-VALUE = par_password. 
    
    /** Criacao do SOAP BODY **/
    hXmlSoap:CREATE-NODE(hXmlBody,"soapenv:Body","ELEMENT").
    hXmlEnvelope:APPEND-CHILD(hXmlBody).

    /** Criacao do Node de Metodo e Parametros **/
    hXmlSoap:CREATE-NODE(hXmlMetodo,par_nmmetodo,"ELEMENT").
    hXmlBody:APPEND-CHILD(hXmlMetodo).

    RETURN "OK".

END PROCEDURE.


PROCEDURE efetua_requisicao_soap PRIVATE:

    DEF INPUT PARAM par_cdcooper AS INT                             NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INT                             NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INT                             NO-UNDO.
    DEF INPUT PARAM par_idservic AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_dsservic AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nmmetodo AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_msgenvio AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_msgreceb AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_movarqto AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nmarqlog AS CHAR                            NO-UNDO.

    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_dsderror AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    hXmlSoap:SAVE("FILE",par_msgenvio).

    UNIX SILENT VALUE("cat " + par_msgenvio + " | /usr/local/cecred/bin/"     +
                      "SendSoapSICREDI.pl --servico='" + STRING(par_idservic) +
                      "' > " + par_msgreceb).
    
    ASSIGN aux_dsderror = "".

    
    /** Cria novamente os handles para leitura do soap retornado **/
    RUN cria_objetos_soap.    
    
    DO WHILE TRUE:

       /** Valida SOAP retornado pelo WebService **/
       hXmlSoap:LOAD("FILE",par_msgreceb,FALSE) NO-ERROR.
    
       IF ERROR-STATUS:NUM-MESSAGES > 0 THEN
          DO:  
              /* Retorna "OK2" para PDF válido e descodificado, com tags 
                 XML padrão removidas. */
              IF par_idservic = 3 THEN 
                 RETURN "OK2".

              ASSIGN aux_dsderror = "Resposta SOAP invalida (XML).".

              LEAVE.

          END. 

       hXmlSoap:GET-DOCUMENT-ELEMENT(hXmlEnvelope) NO-ERROR.
    
       IF ERROR-STATUS:NUM-MESSAGES > 0            OR 
          NOT hXmlEnvelope:LOCAL-NAME = "Envelope" THEN
          DO:
              ASSIGN aux_dsderror = "Resposta SOAP invalida (Envelope).".
              LEAVE.
          END.
            
       hXmlEnvelope:GET-CHILD(hXmlBody,1) NO-ERROR.
    
       IF ERROR-STATUS:NUM-MESSAGES > 0  OR 
          NOT hXmlBody:LOCAL-NAME = "Body" THEN
          DO:
              ASSIGN aux_dsderror = "Resposta SOAP invalida (Body).".
              LEAVE.
          END.
    
       hXmlBody:GET-CHILD(hXmlMetodo,1) NO-ERROR.
       
       IF ERROR-STATUS:NUM-MESSAGES > 0         OR 
         (hXmlMetodo:LOCAL-NAME = "Fault"       AND 
          hXmlMetodo:LOCAL-NAME = par_nmmetodo) THEN
          DO:
              ASSIGN aux_dsderror = "Resposta SOAP invalida (Result).".
              LEAVE.
          END.

       LEAVE.
    
    END. /** Fim do DO WHILE TRUE **/

    IF aux_dsderror <> ""  THEN
       DO: 
           RUN elimina_arquivos_requisicao(INPUT par_msgenvio,
                                           INPUT par_msgreceb,
                                           INPUT par_movarqto,
                                           INPUT par_nmarqlog).
           
           ASSIGN par_dscritic = "Falha na execucao do metodo de " +
                                  par_dsservic                     +
                                 (IF aux_dsderror <> ""  THEN
                                     " (Erro: " + aux_dsderror + ")"
                                  ELSE
                                     "") + ".".

           RETURN "NOK".

       END.
         

    RETURN "OK".

END PROCEDURE.


PROCEDURE obtem_fault_packet PRIVATE:

    DEF INPUT PARAM par_cdcooper AS INT                             NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INT                             NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INT                             NO-UNDO.
    /* Parametro que serve para ignorar certos erros */
    DEF INPUT PARAM par_dsderror AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_msgenvio AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_msgreceb AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_movarqto AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nmarqlog AS CHAR                            NO-UNDO.

    DEF OUTPUT PARAM par_dsreturn AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_cdderror AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsderror AS CHAR                                    NO-UNDO.
    DEF VAR aux_contador AS INT                                     NO-UNDO.

    ASSIGN aux_cdderror = ""
           aux_dsderror = ""
           aux_contador = 0.

    EMPTY TEMP-TABLE tt-erro.

    /** Verifica se foi retornado um fault packet (Erro) **/
    IF hXmlMetodo:LOCAL-NAME = "Fault" THEN
       DO: 
          DO aux_contador = 1 TO hXmlMetodo:NUM-CHILDREN:
    
             hXmlMetodo:GET-CHILD(hXmlTagSoap,aux_contador).
       
             IF hXmlTagSoap:NAME = "#text" THEN
                NEXT.

             hXmlTagSoap:GET-CHILD(hXmlTextSoap,1) NO-ERROR.
              
             IF ERROR-STATUS:ERROR            OR 
                ERROR-STATUS:NUM-MESSAGES > 0 THEN
                NEXT.             

             IF hXmlTagSoap:NAME = "faultstring" THEN
                ASSIGN aux_cdderror = SUBSTR(hXmlTextSoap:NODE-VALUE,1,4)
                       aux_dsderror = hXmlTextSoap:NODE-VALUE.
       
          END. /** Fim do DO ... TO **/
          
          /* Se possui erro e foi passado parametro para ignorar ... */
          IF par_dsderror <> ""                         AND 
             aux_cdderror <> ""                         AND 
             CAN-DO (par_dsderror,STRING(aux_cdderror)) THEN
             ASSIGN par_dsreturn = "OK".
          ELSE
             ASSIGN par_dscritic = (IF aux_dsderror <> ""  THEN
                                       aux_dsderror
                                    ELSE
                                       "")
                    par_dsreturn = "NOK".

          RUN elimina_arquivos_requisicao(INPUT par_msgenvio,
                                          INPUT par_msgreceb,
                                          INPUT par_movarqto,
                                          INPUT par_nmarqlog).

          RETURN "NOK".

       END.
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE elimina_arquivos_requisicao PRIVATE:

    DEF INPUT PARAM par_msgenvio AS CHAR                          NO-UNDO.
    DEF INPUT PARAM par_msgreceb AS CHAR                          NO-UNDO.
    DEF INPUT PARAM par_movarqto AS CHAR                          NO-UNDO.
    DEF INPUT PARAM par_nmarqlog AS CHAR                          NO-UNDO.

    RUN elimina_objetos_soap. 
    
    /*Criptografa e move o arquivo de envio*/
    IF SEARCH(par_msgenvio) <> ? THEN
       RUN criptografa_move_arquivo ( INPUT par_msgenvio, /* Arquivo Orig  */
                                      INPUT par_movarqto +
                                            ENTRY(6,par_msgenvio,"/"), /* Arquivo Destino */
                                      INPUT "INSS - Gestao de beneficios",
                                      INPUT par_nmarqlog). /* Mensagem Log (se erro) */

    /*Criptografa e move o arquivo de recebimento*/
    IF SEARCH(par_msgreceb) <> ? THEN
       RUN criptografa_move_arquivo ( INPUT par_msgreceb, /* Arquivo Orig  */
                                      INPUT par_movarqto + 
                                            ENTRY(6,par_msgreceb,"/"), /* Arquivo Destino */
                                      INPUT "INSS - Gestao de beneficios",
                                      INPUT par_nmarqlog). /* Mensagem Log (se erro) */
      
    RETURN "OK".

END PROCEDURE.


PROCEDURE cria_objetos_xml PRIVATE:
            
    RUN elimina_objetos_xml.

    CREATE X-DOCUMENT hDoc.
    CREATE X-NODEREF  hRoot.
    CREATE X-NODEREF  hHeader.
    CREATE X-NODEREF  hBody.
    CREATE X-NODEREF  hMain.
    CREATE X-NODEREF  hNode.
    CREATE X-NODEREF  hSubNode.
    CREATE X-NODEREF  hNameTag.
    CREATE X-NODEREF  hTextTag.

    CREATE X-NODEREF  hNode2.
    CREATE X-NODEREF  hSubNode2.
    CREATE X-NODEREF  hNameTag2.
    CREATE X-NODEREF  hTextTag2.

    CREATE X-NODEREF  hNameTag3.
    CREATE X-NODEREF  hSubNode3.
    CREATE X-NODEREF  hTextTag3.
              
    RETURN "OK".

END PROCEDURE.


PROCEDURE elimina_objetos_xml PRIVATE:

    IF VALID-HANDLE(hDoc) THEN
       DELETE OBJECT(hDoc).

    IF VALID-HANDLE(hRoot) THEN
       DELETE OBJECT(hRoot).

    IF VALID-HANDLE(hHeader) THEN
       DELETE OBJECT(hHeader).

    IF VALID-HANDLE(hBody) THEN
       DELETE OBJECT(hBody).

    IF VALID-HANDLE(hMain) THEN
       DELETE OBJECT(hMain).

    IF VALID-HANDLE(hNode) THEN
       DELETE OBJECT(hNode).

    IF VALID-HANDLE(hSubNode) THEN
       DELETE OBJECT(hSubNode).

    IF VALID-HANDLE(hNameTag) THEN
       DELETE OBJECT(hNameTag).

    IF VALID-HANDLE(hTextTag) THEN
       DELETE OBJECT(hTextTag).

    IF VALID-HANDLE(hNode2) THEN
       DELETE OBJECT(hNode2).

    IF VALID-HANDLE(hSubNode2) THEN
       DELETE OBJECT(hSubNode2).

    IF VALID-HANDLE(hNameTag2) THEN
       DELETE OBJECT(hNameTag2).

    IF VALID-HANDLE(hTextTag2) THEN
       DELETE OBJECT(hTextTag2).

    IF VALID-HANDLE(hNameTag3) THEN
       DELETE OBJECT(hNameTag3).

    IF VALID-HANDLE(hSubNode3) THEN
       DELETE OBJECT(hSubNode3).

    IF VALID-HANDLE(hTextTag3) THEN
       DELETE OBJECT(hTextTag3).


    RETURN "OK".

END PROCEDURE.


PROCEDURE cria_objetos_soap PRIVATE:

    RUN elimina_objetos_soap.

    CREATE X-DOCUMENT hXmlSoap.             
    CREATE X-NODEREF  hXmlEnvelope.
    CREATE X-NODEREF  hXmlHeader.
    CREATE X-NODEREF  hXmlWsse.
    CREATE X-NODEREF  hXmlUsernameToken.
    CREATE X-NODEREF  hXmlBody.
    CREATE X-NODEREF  hXmlAutentic.
    CREATE X-NODEREF  hXmlMetodo.
    CREATE X-NODEREF  hXmlRootSoap.
    CREATE X-NODEREF  hXmlNode1Soap.
    CREATE X-NODEREF  hXmlNode2Soap.
    CREATE X-NODEREF  hXmlNode3Soap.
    CREATE X-NODEREF  hXmlTagSoap.
    CREATE X-NODEREF  hXmlTag2Soap.
    CREATE X-NODEREF  hXmlTag3Soap.
    CREATE X-NODEREF  hXmlTag4Soap.
    CREATE X-NODEREF  hXmlTextSoap.

    RETURN "OK".

END PROCEDURE.


PROCEDURE elimina_objetos_soap PRIVATE:

    IF VALID-HANDLE(hXmlTextSoap) THEN
       DELETE OBJECT hXmlTextSoap.

    IF VALID-HANDLE(hXmlTagSoap) THEN
       DELETE OBJECT hXmlTagSoap.

    IF VALID-HANDLE(hXmlTag2Soap) THEN
       DELETE OBJECT hXmlTag2Soap.

    IF VALID-HANDLE(hXmlTag3Soap) THEN
       DELETE OBJECT hXmlTag3Soap.

    IF VALID-HANDLE(hXmlTag4Soap) THEN
       DELETE OBJECT hXmlTag4Soap.

    IF VALID-HANDLE(hXmlMetodo) THEN
       DELETE OBJECT hXmlMetodo.

    IF VALID-HANDLE(hXmlRootSoap) THEN
       DELETE OBJECT hXmlRootSoap.

    IF VALID-HANDLE(hXmlNode1Soap) THEN
       DELETE OBJECT hXmlNode1Soap.

    IF VALID-HANDLE(hXmlNode2Soap) THEN
       DELETE OBJECT hXmlNode2Soap.

    IF VALID-HANDLE(hXmlNode3Soap) THEN
       DELETE OBJECT hXmlNode3Soap.

    IF VALID-HANDLE(hXmlAutentic) THEN
       DELETE OBJECT hXmlAutentic.

    IF VALID-HANDLE(hXmlBody) THEN
       DELETE OBJECT hXmlBody.

    IF VALID-HANDLE(hXmlHeader) THEN
       DELETE OBJECT hXmlHeader.

    IF VALID-HANDLE(hXmlEnvelope) THEN
       DELETE OBJECT hXmlEnvelope.

    IF VALID-HANDLE(hXmlSoap) THEN
       DELETE OBJECT hXmlSoap.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
 CRIPTOGRAFA O ARQUIVO PARA GRAVAR NO /SALVAR 
 ****************************************************************************/
PROCEDURE criptografa_move_arquivo:

   DEF INPUT PARAM par_nmarquiv AS CHAR                             NO-UNDO.
   DEF INPUT PARAM par_arqdesti AS CHAR                             NO-UNDO.
   DEF INPUT PARAM par_dsmensag AS CHAR                             NO-UNDO.
   DEF INPUT PARAM par_nmarqlog AS CHAR                             NO-UNDO.
   
   DEF VAR aux_nmarqcri AS CHAR                                     NO-UNDO.
   
   ASSIGN aux_nmarqcri = "".
   
   INPUT STREAM str_1 THROUGH VALUE
      ("/usr/local/cecred/bin/mqcecred_criptografa.pl --criptografa='" +
       par_nmarquiv + "'").

   /* Obtem arquivo temporario criptografado / com .crypto no fim */
   IMPORT STREAM str_1 UNFORMATTED aux_nmarqcri.

   IF TRIM(aux_nmarqcri) = "" THEN 
      DO:
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           par_dsmensag + "' --> '"                  +
                           "Erro ao criptografar o arquivo: "        +
                           par_nmarquiv                              + 
                           " >> " + par_nmarqlog).
        
         /** MOVE SEM CRIPTOGRAFAR **/
         UNIX SILENT VALUE("mv " + par_nmarquiv + " " + par_arqdesti + 
                           STRING(TIME) + ""                         +
                           STRING(RANDOM(0,9999),"9999")             +
                           " 2>/dev/null").
      END.
   ELSE 
      DO: /** MOVE ARQ CRIPTOGRAFADO **/
         /** MOVE ARQUIVO .CRIPTO **/  
         UNIX SILENT VALUE("mv " + aux_nmarqcri + " " + par_arqdesti + 
                           STRING(TIME) + ""                         +
                           STRING(RANDOM(0,9999),"9999")             +
                           " 2>/dev/null").
         
         /** REMOVE ARQUIVO SEM CRIPTOGRAFIA - ORIGEM **/
         UNIX SILENT VALUE("rm " + par_nmarquiv + " 2> /dev/null").
        
   END.

   RETURN "OK".

END PROCEDURE.

/* ************************************************************************* */
/*                      Busca beneficiarios INSS - Tela INSS                 */
/* ************************************************************************* */
PROCEDURE busca_crapdbi:

   DEF INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
   DEF INPUT PARAM par_nrcpfcgc AS DEC                            NO-UNDO.
   DEF INPUT PARAM par_nrdcaixa AS INT                            NO-UNDO.
   DEF INPUT PARAM par_cdagenci AS INT                            NO-UNDO.
   DEF INPUT PARAM par_nrregist AS INT                            NO-UNDO.
   DEF INPUT PARAM par_nriniseq AS INT                            NO-UNDO.
   
   DEF OUTPUT PARAM par_qtregist AS INT                           NO-UNDO.
   DEF OUTPUT PARAM par_nmdcampo AS CHAR                          NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-benefic.
   DEF OUTPUT PARAM TABLE FOR tt-erro.

   DEF VAR aux_nrregist AS INT                                     NO-UNDO.
   DEF VAR aux_cdcritic AS INT                                     NO-UNDO.
   DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

   ASSIGN aux_nrregist = par_nrregist
          aux_cdcritic = 0
          aux_dscritic = "".

   DO ON ERROR UNDO, LEAVE:

      EMPTY TEMP-TABLE tt-benefic.
      EMPTY TEMP-TABLE tt-erro.

      FOR EACH crapdbi WHERE crapdbi.nrcpfcgc = par_nrcpfcgc
                             NO-LOCK:

          ASSIGN par_qtregist = par_qtregist + 1.

          /* controles da paginação */
          IF (par_qtregist < par_nriniseq)                  OR
             (par_qtregist > (par_nriniseq + par_nrregist)) THEN
             NEXT.

          IF aux_nrregist > 0 THEN
             DO:
                FIND FIRST tt-benefic
                     WHERE tt-benefic.nrcpfcgc = crapdbi.nrcpfcgc AND
                           tt-benefic.nrrecben = crapdbi.nrrecben
                           NO-ERROR.
   
                IF NOT AVAILABLE tt-benefic THEN
                   DO:
                      CREATE tt-benefic.

                      BUFFER-COPY crapdbi TO tt-benefic.

                      ASSIGN par_qtregist = par_qtregist + 1.
                      
                   END.

             END.

           ASSIGN aux_nrregist = aux_nrregist - 1.

      END.

      LEAVE.

   END.

   RETURN "OK".
   
END PROCEDURE.


/***************************************************************************
Procedure responsavel por realizar a validacao de guias de GPS alem de, 
efetuar o pagamento das mesmas. (INSS - SICREDI)
***************************************************************************/
PROCEDURE validarGPS:
 
    DEF INPUT PARAM par_cdcooper AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INT                            NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INT                            NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INT                            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_cdpagmto AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_cdidenti AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_vlprinci AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_dtvencim AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_codbarra AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_lindigit AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_valorjur AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_competen AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_vlouenti AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_valorins AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_tppessoa AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INT                            NO-UNDO.
    
    DEF OUTPUT PARAM p-literal    AS CHAR                          NO-UNDO.
    DEF OUTPUT PARAM p-ult-sequencia AS INT                        NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INT                                    NO-UNDO.
    DEF VAR aux_msgenvio AS CHAR                                   NO-UNDO.
    DEF VAR aux_msgreceb AS CHAR                                   NO-UNDO.
    DEF VAR aux_movarqto AS CHAR                                   NO-UNDO.
    DEF VAR aux_nmarqlog AS CHAR                                   NO-UNDO.
    DEF VAR aux_gpsvalid AS LOG INIT FALSE                         NO-UNDO.
                                                                
    DEF VAR aux_dsreturn AS CHAR                                   NO-UNDO.
    DEF VAR aux_retornvl AS CHAR INIT "NOK"                        NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = par_cdcooper NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcop THEN
       DO:
           ASSIGN aux_cdcritic = 651.

           RUN gera_erro(INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic ).
   
           RETURN "NOK".
   
       END.
   
    IF LENGTH(par_cdpagmto) = 0 THEN
       ASSIGN par_cdpagmto = IF LENGTH(par_codbarra) > 0 THEN 
                                SUBSTR(par_codbarra, 20, 4) 
                             ELSE 
                                SUBSTR(par_lindigit, 21, 3) + 
                                SUBSTR(par_lindigit, 25, 1).
                  
    IF LENGTH(par_cdidenti) = 0 THEN
       ASSIGN par_cdidenti = IF LENGTH(par_codbarra) > 0 THEN 
                                SUBSTR(par_codbarra, 24, 14) 
                             ELSE 
                                SUBSTR(par_lindigit, 26, 14).
                 
    ASSIGN aux_nmarqlog = "/usr/coop/" + crapcop.dsdircop + "/log/"         +
                          "SICREDI_Soap_LogErros.log"
           aux_msgenvio = "/usr/coop/" + crapcop.dsdircop + "/arq/"         +
                          "SOAP.MESSAGE.GPS.ENVIO.VALIDA"                   + 
                          STRING(par_dtmvtolt,"99999999")                   +
                          STRING(TIME,"99999") + par_cdoperad
           aux_msgreceb = "/usr/coop/" + crapcop.dsdircop + "/arq/"         +
                          "SOAP.MESSAGE.GPS.RECEBIMENTO.VALIDA"             + 
                          STRING(par_dtmvtolt,"99999999")                   + 
                          STRING(TIME,"99999") + par_cdoperad
           aux_movarqto = "/usr/coop/" + crapcop.dsdircop + "/salvar/".

    ValidaGPS:
    DO WHILE TRUE:

       RUN gera_cabecalho_soap (INPUT 5,                   /* idservic*/
                                INPUT "arr:InValidarArrecadacaoGPS",
                                INPUT "app_cecred_client", /* username */
                                INPUT "Sicredi123").        /* password*/

       hXmlSoap:CREATE-NODE(hXmlTagSoap, "v1:UnidadeAtendimento", "ELEMENT").
       
       hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v1:Cooperativa", "ELEMENT").
       hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).

       hXmlSoap:CREATE-NODE(hXmlTag3Soap, "v1:CodigoCooperativa", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap, "", "TEXT").
       hXmlTextSoap:NODE-VALUE = STRING(crapcop.cdagesic).
       hXmlTag3Soap:APPEND-CHILD(hXmlTextSoap). 
       hXmlTag2Soap:APPEND-CHILD(hXmlTag3Soap). 
       
       hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v1:NumeroUnidadeAtendimento", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").

       /*Devido a limitacao do SICREDI, PA com no maximo dois digitos, foi
        definido que sempre sera enviado o PA 2 (Sem os zeros) ao inves
        do par_cdagenci.*/
       hXmlTextSoap:NODE-VALUE = "2".

       hXmlTag2Soap:APPEND-CHILD(hXmlTextSoap).
       hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).
       
       hXmlMetodo:APPEND-CHILD(hXmlTagSoap).
       hXmlSoap:CREATE-NODE(hXmlTagSoap, "arr:guiaPrevidenciaSocial", "ELEMENT").
       hXmlTagSoap:SET-ATTRIBUTE("v15:ID", "0").
           
       hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v15:IdentificacaoPessoa", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = par_cdidenti.
       hXmlTag2Soap:APPEND-CHILD(hXmlTextSoap).
       hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).
       
       hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v15:Receita", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = par_cdpagmto.
       hXmlTag2Soap:APPEND-CHILD(hXmlTextSoap).
       hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).
       
       /*Mesmo que nao haja valor, somos obrigados a enviar "0" pois
         o SICREDI nao aceita valor nulo.*/
       hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v15:ValorPrincipal", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = IF LENGTH(par_valorins) > 0 THEN
                                    REPLACE(REPLACE(par_valorins,'.',''),',','.')
                                 ELSE 
                                    "0".       
       hXmlTag2Soap:APPEND-CHILD(hXmlTextSoap).
       hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).
       
       IF par_dtvencim <> '' THEN 
          DO:
             hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v15:DataVencimento", "ELEMENT").
             hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
             
             IF LENGTH(par_dtvencim) > 0 THEN
                hXmlTextSoap:NODE-VALUE = SUBSTR(par_dtvencim,7,4) + "-" +
                                          SUBSTR(par_dtvencim,4,2) + "-" + 
                                          SUBSTR(par_dtvencim,1,2) + "T00:00:00". /* 06/30/2013 para 2013-06-30 */
             ELSE
                hXmlTextSoap:NODE-VALUE = "".
             
             hXmlTag2Soap:APPEND-CHILD(hXmlTextSoap).
             hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).

          END.
       
       IF par_codbarra <> ""  THEN 
          DO:
             hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v15:CodigoBarra", "ELEMENT").
             hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
             hXmlTextSoap:NODE-VALUE = par_codbarra.
             hXmlTag2Soap:APPEND-CHILD(hXmlTextSoap).
             hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).
          END.
       
       IF par_lindigit <> "" THEN 
          DO:
             hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v15:LinhaDigitada", "ELEMENT").
             hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
             hXmlTextSoap:NODE-VALUE = par_lindigit.
             hXmlTag2Soap:APPEND-CHILD(hXmlTextSoap).
             hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).
          END.
       
        /*Mesmo que nao haja valor, somos obrigados a enviar "0" pois
         o SICREDI nao aceita valor nulo.*/
        hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v15:AtualizacaoMonetaria", "ELEMENT").
        hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
        hXmlTextSoap:NODE-VALUE = IF LENGTH(par_valorjur) > 0 THEN
                                     REPLACE(REPLACE(par_valorjur, '.', ''),',','.')
                                  ELSE 
                                     "0".                            
        hXmlTag2Soap:APPEND-CHILD(hXmlTextSoap).
        hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).

       IF par_competen <> "" THEN 
          DO:
             hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v15:Competencia", "ELEMENT").
             hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
             hXmlTextSoap:NODE-VALUE = par_competen.
             hXmlTag2Soap:APPEND-CHILD(hXmlTextSoap).
             hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).
             
          END.

       /*Mesmo que nao haja valor, somos obrigados a enviar "0" pois
         o SICREDI nao aceita valor nulo.*/
       hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v15:ValorOutrasEntidades", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = IF LENGTH(par_vlouenti) > 0 THEN
                                    REPLACE(REPLACE(par_vlouenti,'.',''),',','.')
                                 ELSE 
                                    "0".
       hXmlTag2Soap:APPEND-CHILD(hXmlTextSoap).
       hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).
       
       hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v15:FormaCaptacao", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = "MANUAL BOCA DE CAIXA E RETAGUARDA".
       hXmlTag2Soap:APPEND-CHILD(hXmlTextSoap).
       hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).
       hXmlMetodo:APPEND-CHILD(hXmlTagSoap).

       hXmlSoap:CREATE-NODE(hXmlTagSoap, "arr:canal", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = "TERMINAL_FINANCEIRO".
       hXmlTagSoap:APPEND-CHILD(hXmlTextSoap).
       hXmlMetodo:APPEND-CHILD(hXmlTagSoap).

       hXmlSoap:CREATE-NODE(hXmlTagSoap, "arr:formaPagamento", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = "DINHEIRO".
       hXmlTagSoap:APPEND-CHILD(hXmlTextSoap).
       hXmlMetodo:APPEND-CHILD(hXmlTagSoap).

       hXmlSoap:CREATE-NODE(hXmlTagSoap, "arr:aceitaGpsArrecadada", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = "NAO".
       hXmlTagSoap:APPEND-CHILD(hXmlTextSoap).
       hXmlMetodo:APPEND-CHILD(hXmlTagSoap).

       hXmlSoap:CREATE-NODE(hXmlTagSoap,"arr:autenticacao","ELEMENT").
       
       /*Estaremos enviando "CECR" pois o SICREDI permite apenas
         usuario com ate 4 letras/numeros.*/
       hXmlSoap:CREATE-NODE(hXmlNode1Soap,"aut:usuario","ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = "CECR". 
       hXmlNode1Soap:APPEND-CHILD(hXmlTextSoap).
       hXmlTagSoap:APPEND-CHILD(hXmlNode1Soap).
       
       /*Pode ser enviado fixo "1".*/
       hXmlSoap:CREATE-NODE(hXmlNode2Soap,"aut:terminal","ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = "1".
       hXmlNode2Soap:APPEND-CHILD(hXmlTextSoap).
       hXmlTagSoap:APPEND-CHILD(hXmlNode2Soap).
       
       /*O numero da autenticacao eh obrigatorio porem, neste xml de validacao,
         enviaremos uma autenticacao ficticia pois a autenticacao real
         sera gerada e enviada apenas no xml de arrecadacao.
         Apesar de ser obrigatorio o envio de um valor, o SICREDI nao ira
         valida-lo*/
       hXmlSoap:CREATE-NODE(hXmlNode3Soap,"aut:numeroAutenticacao","ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = "0001". 
       hXmlNode3Soap:APPEND-CHILD(hXmlTextSoap).
       hXmlTagSoap:APPEND-CHILD(hXmlNode3Soap).
       
       hXmlMetodo:APPEND-CHILD(hXmlTagSoap).
       
       RUN efetua_requisicao_soap(INPUT crapcop.cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT 7, /*idservic*/
                                  INPUT "Validar GPS",
                                  INPUT "OutValidarArrecadacaoGPS",
                                  INPUT aux_msgenvio,
                                  INPUT aux_msgreceb,
                                  INPUT aux_movarqto,
                                  INPUT aux_nmarqlog,
                                  OUTPUT aux_dscritic).

       IF RETURN-VALUE <> "OK" THEN 
          LEAVE ValidaGPS.

       RUN obtem_fault_packet (INPUT  crapcop.cdcooper,
                               INPUT  par_cdagenci,
                               INPUT  par_nrdcaixa,
                               INPUT  "SOAP-ENV:-950",
                               INPUT  aux_msgenvio,
                               INPUT  aux_msgreceb,
                               INPUT  aux_movarqto,
                               INPUT  aux_nmarqlog,
                               OUTPUT aux_dsreturn,
                               OUTPUT aux_dscritic).
                               
       IF RETURN-VALUE <> "OK"  THEN
          DO:
              ASSIGN aux_retornvl = aux_dsreturn.

              LEAVE ValidaGPS.

          END.
       ELSE 
          DO:  
             hXmlMetodo:GET-CHILD(hXmlTagSoap,1) NO-ERROR. 
             
             IF ERROR-STATUS:NUM-MESSAGES > 0            OR 
                NOT hXmlTagSoap:LOCAL-NAME = "gpsValida" THEN
                DO:
                   IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                      ASSIGN aux_dscritic = "Validacao de GPS nao efetuada.".
                          
                   LEAVE ValidaGPS.

                END.    

          END.
       
       /* GPS valida */
       ASSIGN aux_retornvl = "OK".
       
       LEAVE.

    END. /* fim do while*/

    RUN elimina_objetos_xml.
    RUN elimina_arquivos_requisicao(INPUT aux_msgenvio,
                                    INPUT aux_msgreceb,
                                    INPUT aux_movarqto,
                                    INPUT aux_nmarqlog).

    IF aux_retornvl = "OK" THEN
       DO:
           /* fazer arrecadacao GPS*/
           RUN arrecadarGPS(INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_idorigem,
                            INPUT par_dtmvtolt,
                            INPUT par_nmdatela,
                            INPUT par_cdoperad,
                            INPUT par_cddopcao,
                            INPUT par_cdpagmto,
                            INPUT par_cdidenti,
                            INPUT par_vlprinci,
                            INPUT par_dtvencim,
                            INPUT par_codbarra,
                            INPUT par_lindigit,
                            INPUT par_valorjur,
                            INPUT par_competen,
                            INPUT par_vlouenti,
                            INPUT par_tppessoa,
                            INPUT par_valorins,
                            INPUT par_flgerlog, 
                            INPUT par_idseqttl,
                            OUTPUT p-literal,
                            OUTPUT p-ult-sequencia,
                            OUTPUT TABLE tt-erro). 

           IF RETURN-VALUE <> "OK" THEN
              DO:
                 IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                    DO:
                       ASSIGN aux_cdcritic = 0
                              aux_dscritic = "Nao foi possivel realizar " + 
                                             "arrecadacao de GPS.".
                       
                       RUN gera_erro(INPUT crapcop.cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1,            /** Sequencia **/
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).

                    END.

                 RETURN "NOK".

              END.

       END.
    ELSE
       DO:
          IF aux_cdcritic = 0  AND
             aux_dscritic = "" THEN
             ASSIGN aux_dscritic = "Nao foi possivel realizar a validacao " +
                                   "da GPS.".
          
          RUN gera_erro(INPUT crapcop.cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1,            /** Sequencia **/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).
          
          RETURN aux_retornvl.
         
      END.                                     

   RETURN aux_retornvl.

END PROCEDURE.


/*****************************************************************************
Procedure responsavel por efetuar a arrecadacao de guias de GPS (INSS-SICREDI)
*****************************************************************************/
PROCEDURE arrecadarGPS:
    
    DEF INPUT PARAM par_cdcooper AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INT                            NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INT                            NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INT                            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.

    DEF INPUT PARAM par_cdpagmto AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_cdidenti AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_vlprinci AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_dtvencim AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_codbarra AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_lindigit AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_valorjur AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_competen AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_vlouenti AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_tppessoa AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_valorins AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INT                            NO-UNDO.

    DEF OUTPUT PARAM p-literal       AS CHAR                       NO-UNDO.
    DEF OUTPUT PARAM p-ult-sequencia AS INT                        NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_msgenvio AS CHAR                                   NO-UNDO.
    DEF VAR aux_msgreceb AS CHAR                                   NO-UNDO.
    DEF VAR aux_movarqto AS CHAR                                   NO-UNDO.
    DEF VAR aux_nmarqlog AS CHAR                                   NO-UNDO.
                                                                   
    DEF VAR aux_dsreturn AS CHAR                                   NO-UNDO.
    DEF VAR aux_retornvl AS CHAR INIT "NOK"                        NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    FIND crapcop WHERE crapcop.nmrescop = par_cdcooper NO-LOCK NO-ERROR.
   
    IF NOT AVAIL crapcop  THEN
       DO:
           ASSIGN aux_cdcritic = 651.

           RUN gera_erro(INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic ).
   
           RETURN "NOK".
   
       END.

    ASSIGN aux_nmarqlog = "/usr/coop/" + crapcop.dsdircop + "/log/"         +
                          "SICREDI_Soap_LogErros.log"
           aux_msgenvio = "/usr/coop/" + crapcop.dsdircop + "/arq/"         +
                          "SOAP.MESSAGE.GPS.ENVIO.ARRECADACAO"              + 
                          STRING(par_dtmvtolt,"99999999")                   +
                          STRING(TIME,"99999") + par_cdoperad
           aux_msgreceb = "/usr/coop/" + crapcop.dsdircop + "/arq/"         +
                          "SOAP.MESSAGE.GPS.RECEBIMENTO.ARRECADACAO"        + 
                          STRING(par_dtmvtolt,"99999999")                   + 
                          STRING(TIME,"99999") + par_cdoperad
           aux_movarqto = "/usr/coop/" + crapcop.dsdircop + "/salvar/".
 
    ArrecadaGPS:
    DO WHILE TRUE:

       RUN atualiza-pagamento(INPUT crapcop.cdcooper,
                              INPUT par_cdagenci, 
                              INPUT par_nrdcaixa, 
                              INPUT par_cdoperad, 
                              INPUT DEC(par_cdidenti),
                              INPUT INTE(par_cdpagmto),
                              INPUT INTE(SUBSTR(par_competen,1,2)),
                              INPUT INTE(SUBSTR(par_competen,3,4)),
                              INPUT DEC(par_valorins),
                              INPUT DEC(par_valorjur),
                              INPUT DEC(par_vlouenti),
                              INPUT DEC(par_vlprinci),
                              INPUT par_codbarra,
                              OUTPUT p-literal,
                              OUTPUT p-ult-sequencia,
                              OUTPUT p-nro-docto,
                              OUTPUT TABLE tt-erro).

       IF RETURN-VALUE <> "OK" THEN
          LEAVE ArrecadaGPS.
    
       RUN gera_cabecalho_soap(INPUT 5,                   /* idservic*/
                               INPUT "arr:InArrecadarGPS",
                               INPUT "app_cecred_client", /* username*/
                               INPUT "Sicredi123").       /* password*/
    
       hXmlSoap:CREATE-NODE(hXmlTagSoap, "v1:UnidadeAtendimento", "ELEMENT").
     
       hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v1:Cooperativa", "ELEMENT").
       hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).
     
       hXmlSoap:CREATE-NODE(hXmlTag3Soap, "v1:CodigoCooperativa", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap, "", "TEXT").
       hXmlTextSoap:NODE-VALUE = STRING(crapcop.cdagesic).
       hXmlTag3Soap:APPEND-CHILD(hXmlTextSoap). 
       hXmlTag2Soap:APPEND-CHILD(hXmlTag3Soap). 
    
       hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v1:NumeroUnidadeAtendimento", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").

       /*Devido a limitacao do SICREDI, PA com no maximo dois digitos, foi
        definido que sempre sera enviado o PA 2 (Sem os zeros) ao inves
        do par_cdaggenci.*/
       hXmlTextSoap:NODE-VALUE = "2".
       
       hXmlTag2Soap:APPEND-CHILD(hXmlTextSoap).
       hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).

       hXmlMetodo:APPEND-CHILD(hXmlTagSoap).
   
       hXmlSoap:CREATE-NODE(hXmlTagSoap, "arr:guiaPrevidenciaSocial", "ELEMENT").
       hXmlTagSoap:SET-ATTRIBUTE("v15:ID", "0").
   
       hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v15:IdentificacaoPessoa", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = par_cdidenti.
       hXmlTag2Soap:APPEND-CHILD(hXmlTextSoap).
       hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).
       
       hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v15:Receita", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = par_cdpagmto.
       hXmlTag2Soap:APPEND-CHILD(hXmlTextSoap).
       hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).
       
       /*Mesmo que nao haja valor, somos obrigados a enviar "0" pois
         o SICREDI nao aceita valor nulo.*/
       hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v15:ValorPrincipal", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = IF LENGTH(par_valorins) > 0 THEN
                                    REPLACE(REPLACE(par_valorins,'.',''),',','.')
                                 ELSE 
                                    "0".       
       hXmlTag2Soap:APPEND-CHILD(hXmlTextSoap).
       hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).

       hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v15:DataVencimento", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
   
       IF LENGTH(par_dtvencim) > 0 THEN
          hXmlTextSoap:NODE-VALUE = SUBSTR(par_dtvencim,7,4) + "-" +
                                    SUBSTR(par_dtvencim,4,2) + "-" + 
                                    SUBSTR(par_dtvencim,1,2) + "T00:00:00". /* 06/30/2013 para 2013-06-30 */
       ELSE
          hXmlTextSoap:NODE-VALUE = "".
   
       hXmlTag2Soap:APPEND-CHILD(hXmlTextSoap).
       hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).
       
       IF par_codbarra <> "" THEN
          DO:
             hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v15:CodigoBarra", "ELEMENT").
             hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
             hXmlTextSoap:NODE-VALUE = par_codbarra.
             hXmlTag2Soap:APPEND-CHILD(hXmlTextSoap).
             hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).
          END.

       IF par_lindigit <> "" THEN
          DO:
             hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v15:LinhaDigitada", "ELEMENT").
             hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
             hXmlTextSoap:NODE-VALUE = par_lindigit.
             hXmlTag2Soap:APPEND-CHILD(hXmlTextSoap).
             hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).
          END.

       /*Mesmo que nao haja valor, somos obrigados a enviar "0" pois
         o SICREDI nao aceita valor nulo.*/
       hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v15:AtualizacaoMonetaria", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = IF LENGTH(par_valorjur) > 0 THEN
                                    REPLACE(REPLACE(par_valorjur,'.', ''),',','.')
                                 ELSE 
                                    "0".                            
       hXmlTag2Soap:APPEND-CHILD(hXmlTextSoap).
       hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).
       
       hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v15:Competencia", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = par_competen.
       hXmlTag2Soap:APPEND-CHILD(hXmlTextSoap).
       hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).
       
       /*Mesmo que nao haja valor, somos obrigados a enviar "0" pois
         o SICREDI nao aceita valor nulo.*/
       hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v15:ValorOutrasEntidades", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = IF LENGTH(par_vlouenti) > 0 THEN
                                    REPLACE(REPLACE(par_vlouenti,'.',''),',','.')
                                 ELSE 
                                    "0".
       hXmlTag2Soap:APPEND-CHILD(hXmlTextSoap).
       hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).
       
       hXmlSoap:CREATE-NODE(hXmlTag2Soap, "v15:FormaCaptacao", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = "MANUAL BOCA DE CAIXA E RETAGUARDA".
       hXmlTag2Soap:APPEND-CHILD(hXmlTextSoap).
       hXmlTagSoap:APPEND-CHILD(hXmlTag2Soap).
       hXmlMetodo:APPEND-CHILD(hXmlTagSoap).
       
       hXmlSoap:CREATE-NODE(hXmlTagSoap, "arr:canal", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = "TERMINAL_FINANCEIRO".
       hXmlTagSoap:APPEND-CHILD(hXmlTextSoap).
       hXmlMetodo:APPEND-CHILD(hXmlTagSoap).
   
       hXmlSoap:CREATE-NODE(hXmlTagSoap, "arr:formaPagamento", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = "DINHEIRO".
       hXmlTagSoap:APPEND-CHILD(hXmlTextSoap).
       hXmlMetodo:APPEND-CHILD(hXmlTagSoap).
   
       hXmlSoap:CREATE-NODE(hXmlTagSoap, "arr:aceitaGpsArrecadada", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = "NAO".
       hXmlTagSoap:APPEND-CHILD(hXmlTextSoap).
       hXmlMetodo:APPEND-CHILD(hXmlTagSoap).
   
       hXmlSoap:CREATE-NODE(hXmlTagSoap, "arr:autenticacao", "ELEMENT").
   
       /*Estaremos enviando "CECR" pois o SICREDI permite apenas
         usuario com ate 4 letras/numeros.*/
       hXmlSoap:CREATE-NODE(hXmlNode1Soap, "aut:usuario", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = "CECR".
       hXmlNode1Soap:APPEND-CHILD(hXmlTextSoap).
       hXmlTagSoap:APPEND-CHILD(hXmlNode1Soap).
   
       /*Pode ser enviado fixo "1".*/
       hXmlSoap:CREATE-NODE(hXmlNode2Soap, "aut:terminal", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = "1".
       hXmlNode2Soap:APPEND-CHILD(hXmlTextSoap).
       hXmlTagSoap:APPEND-CHILD(hXmlNode2Soap).
   
       hXmlSoap:CREATE-NODE(hXmlNode3Soap, "aut:numeroAutenticacao", "ELEMENT").
       hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
       hXmlTextSoap:NODE-VALUE = SUBSTR(p-literal,15,4).
       hXmlNode3Soap:APPEND-CHILD(hXmlTextSoap).
       hXmlTagSoap:APPEND-CHILD(hXmlNode3Soap).
   
       hXmlMetodo:APPEND-CHILD(hXmlTagSoap).
   
       RUN efetua_requisicao_soap(INPUT crapcop.cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT 7, /*idservic*/
                                  INPUT "Arrecadar GPS",
                                  INPUT "OutArrecadacaoGPSINSS",
                                  INPUT aux_msgenvio,
                                  INPUT aux_msgreceb,
                                  INPUT aux_movarqto,
                                  INPUT aux_nmarqlog,
                                  OUTPUT aux_dscritic).
   
       IF RETURN-VALUE <> "OK" THEN
          LEAVE ArrecadaGPS.
   
       RUN obtem_fault_packet (INPUT  crapcop.cdcooper,
                               INPUT  par_cdagenci,
                               INPUT  par_nrdcaixa,
                               INPUT  "SOAP-ENV:-950",
                               INPUT  aux_msgenvio,
                               INPUT  aux_msgreceb,
                               INPUT  aux_movarqto,
                               INPUT  aux_nmarqlog,
                               OUTPUT aux_dsreturn,
                               OUTPUT aux_dscritic).
   
       IF RETURN-VALUE <> "OK"  THEN
          DO:
              ASSIGN aux_retornvl = aux_dsreturn.
              LEAVE ArrecadaGPS.
          END.
       ELSE 
          DO:  
             hXmlMetodo:GET-CHILD(hXmlTagSoap,1) NO-ERROR. 
      
            IF ERROR-STATUS:NUM-MESSAGES > 0     OR 
               NOT hXmlTagSoap:LOCAL-NAME = "id" THEN
               DO:
                  IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                     ASSIGN aux_dscritic = "Arrecadacao de GPS nao efetuada.".
                         
                  LEAVE ArrecadaGPS.
            
               END.    
            
            RUN cria_objetos_xml.

            IF hXmlTagSoap:LOCAL-NAME = "id" THEN
               DO:
                  hXmlTagSoap:GET-CHILD(hTextTag,1) NO-ERROR.
                        
                  /* Se nao vier conteudo na TAG */ 
                  IF ERROR-STATUS:ERROR            OR  
                     ERROR-STATUS:NUM-MESSAGES > 0 THEN
                     ASSIGN aux_idarrgps = 0.

                  ASSIGN aux_idarrgps = INT(hTextTag:NODE-VALUE).

               END.

          END.
   
        Cont:
        DO aux_contador = 1 TO 10:

          /* Grava id da arrecadacao da gps do sicredi na lgp */
          FIND FIRST craplgp 
               WHERE craplgp.cdcooper = crapcop.cdcooper               AND 
                     craplgp.dtmvtolt = par_dtmvtolt                   AND 
                     craplgp.cdagenci = par_cdagenci                   AND 
                     craplgp.cdbccxlt = 11                             AND 
                     craplgp.nrdolote = 31000 + par_nrdcaixa           AND 
                     craplgp.cdidenti = DEC(par_cdidenti)              AND 
                     craplgp.mmaacomp = INT(SUBSTR(par_competen,1,2) + 
                                            SUBSTR(par_competen,3,4))  AND
                     craplgp.vlrtotal = DEC(par_vlprinci)              AND 
                     craplgp.cddpagto = INTE(par_cdpagmto)
                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
         
          IF NOT AVAIL craplgp THEN
             DO:
                IF LOCKED craplgp THEN
                   DO:
                      IF aux_contador = 10 THEN
                         DO:
                            ASSIGN aux_cdcritic = 77.
                            LEAVE ArrecadaGPS.
                         END.
                      ELSE 
                         DO:
                             PAUSE 1 NO-MESSAGE.
                             NEXT Cont.
                         END.

                   END.
                 ELSE       
                   DO:   
                      ASSIGN aux_cdcritic = 55.
                      LEAVE ArrecadaGPS.       
                   END.

             END.

          ASSIGN craplgp.idsicred = aux_idarrgps.
         
          RELEASE craplgp.

       END.

       /* GPS valida */
       ASSIGN aux_retornvl = "OK".
   
       LEAVE.
   
    END. /* fim do while ArrecadaGPS */

    RUN elimina_objetos_xml.
    RUN elimina_arquivos_requisicao(INPUT aux_msgenvio,
                                    INPUT aux_msgreceb,
                                    INPUT aux_movarqto,
                                    INPUT aux_nmarqlog).

    IF aux_retornvl <> "OK"               AND  
       NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO:
          IF aux_cdcritic = 0  AND 
             aux_dscritic = "" THEN
             ASSIGN aux_dscritic = "Nao foi possivel consultar o " + 
                                   "beneficiario.".
      
          RUN gera_erro(INPUT crapcop.cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1,            /** Sequencia **/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).

       END.
    
    RETURN aux_retornvl.

END PROCEDURE.


/******************************************************************************
Procedure responsavel por efetuar o lancamento do credito da guia de GPS.
******************************************************************************/
PROCEDURE atualiza-pagamento:
    
    DEF INPUT  PARAM p-cooper             AS CHAR                   NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia        AS INTEGER                NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa          AS INTEGER                NO-UNDO.
    DEF INPUT  PARAM p-cod-operador       AS CHAR                   NO-UNDO.
    DEF INPUT  PARAM p-identificador      AS DEC                    NO-UNDO.
    DEF INPUT  PARAM p-codigo             AS INTE                   NO-UNDO.
    DEF INPUT  PARAM p-mesref             AS INTE                   NO-UNDO.
    DEF INPUT  PARAM p-anoref             AS INTE                   NO-UNDO.
    DEF INPUT  PARAM p-valorins           AS DEC                    NO-UNDO.
    DEF INPUT  PARAM p-valorjur           AS DEC                    NO-UNDO.
    DEF INPUT  PARAM p-valorout           AS DEC                    NO-UNDO.
    DEF INPUT  PARAM p-valortot           AS DEC                    NO-UNDO.
    DEF INPUT  PARAM p-cdbarras           AS CHAR                   NO-UNDO.

    DEF OUTPUT PARAM p-literal            AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM p-ult-sequencia      AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM p-docto              AS DEC                    NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INT                                     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_contador = 0
           i-nro-lote   = 31000 + p-nro-caixa.

    FIND crapcop WHERE crapcop.cdcooper = INTE(p-cooper) NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcop  THEN
       DO:
          ASSIGN aux_cdcritic = 651
                 aux_dscritic = "".
          
          RUN gera_erro (INPUT INTE(p-cooper),
                         INPUT p-cod-agencia,
                         INPUT p-nro-caixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
          
          RETURN "NOK".

       END.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapdat  THEN
       DO:
          ASSIGN aux_cdcritic = 1
                 aux_dscritic = "".
          
          RUN gera_erro (INPUT p-cooper,
                         INPUT p-cod-agencia,
                         INPUT p-nro-caixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
          
          RETURN "NOK".

       END.

    ASSIGN aux_mmaacomp = STRING(p-mesref,"99")  + 
                          STRING(p-anoref,"9999").

    FIND FIRST craplgp WHERE
               craplgp.cdcooper = crapcop.cdcooper                     AND
               craplgp.dtmvtolt = crapdat.dtmvtolt                     AND
               craplgp.cdagenci = p-cod-agencia                        AND
               craplgp.cdbccxlt = 11                   /* Fixo */      AND 
               craplgp.nrdolote = i-nro-lote                           AND
               craplgp.cdidenti = p-identificador                      AND
               craplgp.cddpagto = p-codigo                             AND
               craplgp.mmaacomp = INTE(STRING(aux_mmaacomp,"999999"))  AND
               craplgp.vlrtotal = p-valortot 
               EXCLUSIVE-LOCK NO-ERROR. 

    IF AVAIL craplgp THEN 
       DO:
          ASSIGN aux_cdcritic = 92
                 aux_dscritic = "".
          
          RUN gera_erro (INPUT p-cooper,
                         INPUT p-cod-agencia,
                         INPUT p-nro-caixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
          
          RETURN "NOK".

       END. 

    ContLote:
    DO aux_contador = 1 TO 10:

       FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper AND
                          craplot.dtmvtolt = crapdat.dtmvtolt AND
                          craplot.cdagenci = p-cod-agencia    AND
                          craplot.cdbccxlt = 11               AND  /* Fixo */
                          craplot.nrdolote = i-nro-lote         
                          NO-ERROR.
    
        IF NOT AVAIL craplot THEN
           DO:
              IF LOCKED craplot THEN
                 DO:
                     IF aux_contador = 10 THEN
                        ASSIGN aux_cdcritic = 77.
                     ELSE
                        NEXT.

                     LEAVE ContLote.
        
                 END.
              ELSE
                 DO:
                     CREATE craplot.

                     ASSIGN craplot.dtmvtolt = crapdat.dtmvtolt
                            craplot.cdagenci = p-cod-agencia   
                            craplot.cdbccxlt = 11              
                            craplot.nrdolote = i-nro-lote
                            craplot.tplotmov = 30 
                            craplot.cdoperad = p-cod-operador
                            /* Historico gps sicredi */
                            craplot.cdhistor = 1414
                            /* Pagto GPS */
                            craplot.nrdcaixa = p-nro-caixa
                            craplot.cdopecxa = p-cod-operador 
                            craplot.cdcooper = crapcop.cdcooper.

                 END.

           END.

        LEAVE ContLote.

    END.

    IF aux_cdcritic <> 0 THEN
       DO:
          RUN gera_erro (INPUT p-cooper,
                         INPUT p-cod-agencia,
                         INPUT p-nro-caixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
          
          RETURN "NOK".

       END.
    
    CREATE craplgp.

    ASSIGN craplgp.cdcooper = crapcop.cdcooper  /* cdcooper */ 
           craplgp.dtmvtolt = craplot.dtmvtolt  /* dtmvtolt */
           craplgp.cdagenci = craplot.cdagenci  /* cdagenci */
           craplgp.cdbccxlt = craplot.cdbccxlt  /* cdbccxlt */
           craplgp.nrdolote = craplot.nrdolote  /* nrdolote */
           craplgp.cdopecxa = p-cod-operador    /* cdidenti */
           craplgp.nrdcaixa = p-nro-caixa       /* mmaacomp */
           craplgp.nrdmaqui = p-nro-caixa       /* vlrtotal */
           craplgp.cdidenti = p-identificador   /* cddpagto */
           craplgp.cddpagto = p-codigo          
           aux_mmaacomp = STRING(p-mesref,"99")  + 
                          STRING(p-anoref,"9999")      
           craplgp.mmaacomp = INTE(STRING(aux_mmaacomp,"999999"))           
           craplgp.vlrdinss = p-valorins   
           craplgp.vlrouent = p-valorout
           craplgp.vlrjuros = p-valorjur 
           craplgp.vlrtotal = p-valortot                                  
           craplgp.nrseqdig = craplot.nrseqdig + 1   
           craplgp.hrtransa = TIME
           craplgp.flgenvio = TRUE
           craplgp.cdbarras = p-cdbarras
           craplot.nrseqdig = craplot.nrseqdig + 1
           craplot.qtcompln = craplot.qtcompln + 1
           craplot.qtinfoln = craplot.qtinfoln + 1
           craplot.vlcompdb = craplot.vlcompdb + p-valortot    
           craplot.vlinfodb = craplot.vlinfodb + p-valortot.

    /*--- Grava Autenticacao Arquivo/Spool --*/
    IF NOT VALID-HANDLE(h_b1crap00) THEN
       RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.

    RUN grava-autenticacao-internet IN h_b1crap00
       (INPUT crapcop.nmrescop,
        INPUT 0, /* par_nrdconta, */
        INPUT 1, /* par_idseqttl, */
        INPUT p-cod-agencia,
        INPUT p-nro-caixa,
        INPUT p-cod-operador,
        INPUT DEC(p-valortot),
        INPUT p-identificador,    /* p-docto, */
        INPUT NO, /* p-pg, *//* YES (PG), NO (REC) */
        INPUT "1",  /* On-line            */
        INPUT NO,   /* Nao estorno        */
        INPUT 1414, /* p-histor, */
        INPUT ?, /* Data off-line */
        INPUT 0, /* Sequencia off-line */
        INPUT 0, /* Hora off-line */
        INPUT 0, /* Seq.orig.Off-line */
        INPUT "", /*aux_cdempres deve ser vazio. Preenchido eh usado p/ darf */
        OUTPUT p-literal,
        OUTPUT p-ult-sequencia,
        OUTPUT p-registro).
          
    IF VALID-HANDLE(h_b1crap00) THEN
       DELETE OBJECT h_b1crap00.

    IF RETURN-VALUE = "NOK" THEN
       RETURN "NOK".

    ASSIGN craplgp.nrautdoc = p-ult-sequencia
           p-docto          = craplgp.nrseqdig.
   
    RELEASE craplgp.
    RELEASE craplot.

    RETURN "OK".

END PROCEDURE.


