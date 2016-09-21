/* .............................................................................

   Programa: includes/criticas_coo.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Marco/2005.                       Ultima atualizacao: 06/03/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Retornar descricao da critica proveniente dos arquivos de
               retorno vindos do Banco do Brasil sobre CONTA DE INTEGRACAO.

   Alteracoes: 06/03/2006 - Inclusao das criticas do COO508 (Evandro).

............................................................................. */

IF  aux_dsprogra = "COO400"   THEN   /* ERROS NO COO400 - Cadastramento */
    DO:
       IF  aux_tpregist = 0   THEN
           DO:
              /* HEADER */
              CASE aux_cdocorre:
                   WHEN 2 THEN aux_dscritic = "Cabecalho Invalido".
                   WHEN 3 THEN aux_dscritic = "Rodape Invalido".
                   WHEN 4 THEN aux_dscritic = "Detalhe Parcialmente Invalido".
                   WHEN 5 THEN aux_dscritic = "Recusa Total - Tipo Registro".
                   WHEN 6 THEN aux_dscritic = "Recusa Total - Sequencia".
                   WHEN 8 THEN aux_dscritic = "Recusa Total - Conteudo".
                   OTHERWISE   aux_dscritic = "Critica Desconhecida".
              END CASE.
           END.
       ELSE
       IF  aux_tpregist = 1   THEN
           DO:
              /* DETALHE TIPO 1 */
              CASE aux_cdocorre:
                   WHEN 01 THEN aux_dscritic = "Sequencial do Registro".
                   WHEN 02 THEN aux_dscritic = "Tipo de Detalhe".             
                   WHEN 03 THEN aux_dscritic = "CPF/CNPJ".
                   WHEN 04 THEN aux_dscritic = "Tipo CPF/CNPJ".
                   WHEN 05 THEN aux_dscritic = "Data de Nascimento".
                   WHEN 06 THEN aux_dscritic = "Nome do Associado".
                   WHEN 07 THEN aux_dscritic = "Nome Personalizado".
                   WHEN 08 THEN aux_dscritic = "Titularidade do Cooperado".
                   WHEN 09 THEN aux_dscritic = "CPF Primeiro Titular".
                   WHEN 10 THEN aux_dscritic = "Sexo do Associado".
                   WHEN 11 THEN aux_dscritic = "Nacionalidade".
                   WHEN 12 THEN aux_dscritic = "Naturalidade".
                   WHEN 13 THEN aux_dscritic = "Tipo de Documento".
                   WHEN 14 THEN aux_dscritic = "Numero do Documento".
                   WHEN 15 THEN aux_dscritic = "Orgao Emissor".
                   WHEN 16 THEN aux_dscritic = "Data Emissao Documento".
                   WHEN 17 THEN aux_dscritic = "Estado Civil".
                   WHEN 18 THEN aux_dscritic = "Capacidade Civil".
                   WHEN 19 THEN aux_dscritic = "Formacao".
                   WHEN 20 THEN aux_dscritic = "Grau de Instrucao".
                   WHEN 21 THEN aux_dscritic = "Natureza de Ocupacao".
                   WHEN 22 THEN aux_dscritic = "Ocupacao".
                   WHEN 23 THEN aux_dscritic = "Valor do Rendimento".
                   WHEN 24 THEN aux_dscritic = "Mes/ano Rendimento".
                   WHEN 25 THEN aux_dscritic = "Endereco do Cooperado".
                   WHEN 26 THEN aux_dscritic = "Bairro do Cooperado".
                   WHEN 27 THEN aux_dscritic = "CEP do Cooperado".
                   WHEN 28 THEN aux_dscritic = "DDD do Cooperado".
                   WHEN 29 THEN aux_dscritic = "Telefone do Cooperado".
                   WHEN 30 THEN aux_dscritic = "Caixa Postal do Cooperado".
                   WHEN 31 THEN aux_dscritic = "Situacao do Imovel Cooperado".
                   WHEN 32 THEN aux_dscritic = "Tempo de Residencia".
                   WHEN 33 THEN aux_dscritic = "Uso Talonario".
                   WHEN 34 THEN aux_dscritic = "Ordem Impressao Talonario".
                   WHEN 35 THEN aux_dscritic = "Telefone no Cheque".
                   WHEN 36 THEN aux_dscritic = "Data Abertura C/C".
                   WHEN 37 THEN aux_dscritic = "Numero da C/C".
                   OTHERWISE    aux_dscritic = "Critica desconhecida".
              END CASE.
           END.
       ELSE
       IF  aux_tpregist = 2   THEN
           DO:
              /* DETALHE TIPO 2 */
              CASE aux_cdocorre:
                   WHEN 01 THEN aux_dscritic = "Sequencial do Registro".
                   WHEN 02 THEN aux_dscritic = "Tipo de Detalhe".             
                   WHEN 03 THEN aux_dscritic = "CPF/CNPJ do Primeiro Titular".
                   WHEN 04 THEN aux_dscritic = "Nome da Mae".
                   WHEN 05 THEN aux_dscritic = "Nome do Pai".
                   WHEN 06 THEN aux_dscritic = "CPF do Conjuge".
                   WHEN 07 THEN aux_dscritic = "Data Nascimento Conjuge".
                   WHEN 08 THEN aux_dscritic = "Nome do Conjuge".
                   WHEN 09 THEN aux_dscritic = "Contrato de Trabalho".
                   WHEN 10 THEN aux_dscritic = "Tipo de Pessoa".
                   WHEN 11 THEN aux_dscritic = "CPF/CNPJ do Empregador".
                   WHEN 12 THEN aux_dscritic = "Inicio do Emprego".
                   WHEN 13 THEN aux_dscritic = "Nome do Empregador".
                   WHEN 14 THEN aux_dscritic = "Cargo".              
                   WHEN 15 THEN aux_dscritic = "Nivel do Cargo".
                   OTHERWISE    aux_dscritic = "Critica desconhecida".
              END CASE.
           END.
      ELSE
           aux_dscritic = "Critica desconhecida".
    END.
ELSE
IF  aux_dsprogra = "COO405"   THEN   /* ERROS NO COO405 */
    DO:
       IF  aux_tpregist = 0   THEN
           DO:
              /* HEADER */
              CASE aux_cdocorre:
                   WHEN 02 THEN aux_dscritic = "Recusa total header invalido".
                   WHEN 03 THEN aux_dscritic = "Recusa total trailer invalido"
                                               + "/inexistente".
                   WHEN 04 THEN aux_dscritic = "Recusa parcial do detalhe".
                   WHEN 05 THEN aux_dscritic = "Recusa total tipo registro " +
                                               "inexistente".
                   WHEN 06 THEN aux_dscritic = "Recusa total sequencial " +
                                               "invalido".
                   WHEN 07 THEN aux_dscritic = "Em processamento".
                   WHEN 08 THEN aux_dscritic = "Recusa total conteudo da " +
                                               "remessa invalida".
                   OTHERWISE    aux_dscritic = "Critica desconhecida".
              END CASE.
           END.
       ELSE
       IF  aux_tpregist = 1   THEN
           DO:
              /* DETALHE TIPO 1 */
              CASE aux_cdocorre:
                   WHEN 01 THEN aux_dscritic = "Sequencial do Registro".
                   WHEN 02 THEN aux_dscritic = "Tipo do detalhe".
                   WHEN 03 THEN aux_dscritic = "Cod. Integracao do Cooperado".
                   WHEN 04 THEN aux_dscritic = "Dig. Verif. do Cod. Integracao".
                   WHEN 05 THEN aux_dscritic = "Comando de Atualizacao".
                   WHEN 08 THEN aux_dscritic = "Data de Abertura da Conta".
                   WHEN 09 THEN aux_dscritic = "Titularidade do Cooperado".
                   OTHERWISE    aux_dscritic = "Critica desconhecida".
              END CASE.
           END.
       ELSE
       IF  aux_tpregist = 2   THEN
           DO:    
              /* DETALHE TIPO 2 */
              CASE aux_cdocorre:
                   WHEN 01 THEN aux_dscritic = "Sequencial do Registro".
                   WHEN 02 THEN aux_dscritic = "Tipo do detalhe".
                   WHEN 03 THEN aux_dscritic = "Cod. Integracao do Cooperado".
                   WHEN 04 THEN aux_dscritic = "Dig. Verif. do Cod. Integracao".
                   WHEN 05 THEN aux_dscritic = "CPF/CNPJ do cooperado".
                   WHEN 06 THEN aux_dscritic = "Tipo de CPF/CNPJ".
                   WHEN 07 THEN aux_dscritic = "Data de nascimento".
                   WHEN 09 THEN aux_dscritic = "Nome para Talonario".
                   OTHERWISE    aux_dscritic = "Critica desconhecida".
              END CASE.
           END.
       ELSE
       IF  aux_tpregist = 3   THEN
           DO:
              /* DETALHE TIPO 3 */
              CASE aux_cdocorre:
                   WHEN 01 THEN aux_dscritic = "Sequencial do Registro".
                   WHEN 02 THEN aux_dscritic = "Tipo do detalhe".
                   WHEN 03 THEN aux_dscritic = "Cod. Integracao do Cooperado".
                   WHEN 04 THEN aux_dscritic = "Dig. Verif. do Cod. Integracao".
                   WHEN 05 THEN aux_dscritic = "Sexo".
                   WHEN 06 THEN aux_dscritic = "Nacionalidade".
                   WHEN 07 THEN aux_dscritic = "Naturalidade".
                   WHEN 08 THEN aux_dscritic = "Tipo do Documento".
                   WHEN 09 THEN aux_dscritic = "Numero do documento".
                   WHEN 10 THEN aux_dscritic = "Orgao Emissor".
                   WHEN 11 THEN aux_dscritic = "Data de Emissao".
                   WHEN 12 THEN aux_dscritic = "Estado Civil".
                   WHEN 13 THEN aux_dscritic = "Capacidade Civil".
                   WHEN 14 THEN aux_dscritic = "Formacao".
                   WHEN 15 THEN aux_dscritic = "Grau de Instrucao".
                   WHEN 16 THEN aux_dscritic = "Natureza da Ocupacao".
                   WHEN 17 THEN aux_dscritic = "Ocupacao".
                   WHEN 18 THEN aux_dscritic = "Valor do Rendimento".
                   WHEN 19 THEN aux_dscritic = "Mes/ano do rendimento".
                   OTHERWISE    aux_dscritic = "Critica desconhecida".
              END CASE.
           END.  
       ELSE
       IF  aux_tpregist = 4   THEN
           DO:
              /* DETALHE TIPO 4 */
              CASE aux_cdocorre:
                   WHEN 01 THEN aux_dscritic = "Sequencial do Registro".
                   WHEN 02 THEN aux_dscritic = "Tipo do detalhe".
                   WHEN 03 THEN aux_dscritic = "Cod. Integracao do Cooperado".
                   WHEN 04 THEN aux_dscritic = "Dig. Verif. do Cod. Integracao".
                   WHEN 05 THEN aux_dscritic = "Nome da Mae".
                   WHEN 06 THEN aux_dscritic = "Nome do Pai".
                   OTHERWISE    aux_dscritic = "Critica desconhecida".
              END CASE.
           END.  
       ELSE       
       IF  aux_tpregist = 5   THEN
           DO:
              /* DETALHE TIPO 5 */
              CASE aux_cdocorre:
                   WHEN 01 THEN aux_dscritic = "Sequencial do Registro".
                   WHEN 02 THEN aux_dscritic = "Tipo do detalhe".
                   WHEN 03 THEN aux_dscritic = "Cod. Integracao do Cooperado".
                   WHEN 04 THEN aux_dscritic = "Dig. Verif. do Cod. Integracao".
                   WHEN 05 THEN aux_dscritic = "CPF do Conjuge".
                   WHEN 06 THEN aux_dscritic = "Data de nascimento do Conjuge".
                   WHEN 07 THEN aux_dscritic = "Nome do Conjuge".
                   OTHERWISE    aux_dscritic = "Critica desconhecida".
              END CASE.
           END.
       ELSE
       IF  aux_tpregist = 6   THEN
           DO:
              /* DETALHE TIPO 6 */
              CASE aux_cdocorre:
                   WHEN 01 THEN aux_dscritic = "Sequencial do Registro".
                   WHEN 02 THEN aux_dscritic = "Tipo do detalhe".
                   WHEN 03 THEN aux_dscritic = "Cod. Integracao do Cooperado".
                   WHEN 04 THEN aux_dscritic = "Dig. Verif. do Cod. Integracao".
                   WHEN 05 THEN aux_dscritic = "Contrato de Trabalho".
                   WHEN 06 THEN aux_dscritic = "Tipo de Pessoa".
                   WHEN 07 THEN aux_dscritic = "CPF/CNPJ do empregador".
                   WHEN 08 THEN aux_dscritic = "Inicio do Emprego".
                   WHEN 09 THEN aux_dscritic = "Nome do Empregador".
                   WHEN 10 THEN aux_dscritic = "Cargo".
                   WHEN 11 THEN aux_dscritic = "Nivel do Cargo".
                   OTHERWISE    aux_dscritic = "Critica desconhecida".
              END CASE.
           END.  
       ELSE       
       IF  aux_tpregist = 7   THEN
           DO:
              /* DETALHE TIPO 7 */
              CASE aux_cdocorre:
                   WHEN 01 THEN aux_dscritic = "Sequencial do Registro".
                   WHEN 02 THEN aux_dscritic = "Tipo do detalhe".
                   WHEN 03 THEN aux_dscritic = "Cod. Integracao do Cooperado".
                   WHEN 04 THEN aux_dscritic = "Dig. Verif. do Cod. Integracao".
                   WHEN 05 THEN aux_dscritic = "Logradouro".
                   WHEN 06 THEN aux_dscritic = "Bairro".
                   WHEN 07 THEN aux_dscritic = "CEP".
                   WHEN 08 THEN aux_dscritic = "DDD".
                   WHEN 09 THEN aux_dscritic = "Telefone".
                   WHEN 10 THEN aux_dscritic = "Caixa Postal".
                   WHEN 11 THEN aux_dscritic = "Situacao do Imovel".
                   OTHERWISE    aux_dscritic = "Inicio de Residencia".
              END CASE.
           END.  
       ELSE
       IF   aux_tpregist = 999   THEN
            DO:
               /* TRAILER */
               CASE aux_cdocorre:
                    WHEN 03 THEN aux_dscritic = "Total de Associados".
                    WHEN 04 THEN aux_dscritic = "Total de Registros".
                    OTHERWISE    aux_dscritic = "Critica desconhecida".
               END CASE.
            END.  
       ELSE
            aux_dscritic = "Critica desconhecida".
    END.
ELSE
IF  aux_dsprogra = "COO406"   THEN   /* ERROS NO COO406 */
    DO:
       IF  aux_tpregist = 0   THEN
           DO:
              /* HEADER */
              CASE aux_cdocorre:
                   WHEN 02 THEN aux_dscritic = "Recusa total header invalido".
                   WHEN 03 THEN aux_dscritic = "Recusa total trailer invalido"
                                               + "/inexistente".
                   WHEN 04 THEN aux_dscritic = "Recusa parcial do detalhe".
                   WHEN 05 THEN aux_dscritic = "Recusa total tipo registro " +
                                               "inexistente".
                   WHEN 06 THEN aux_dscritic = "Recusa total sequencial " +
                                               "invalido".
                   WHEN 07 THEN aux_dscritic = "Em processamento".
                   WHEN 08 THEN aux_dscritic = "Recusa total conteudo da " +
                                               "remessa invalida".
                   OTHERWISE    aux_dscritic = "Critica desconhecida".
              END CASE.
           END.
       ELSE
       IF  aux_tpregist = 1   THEN
           DO:
              /* DETALHE UNICO */
              CASE aux_cdocorre:
                   WHEN 01 THEN aux_dscritic = "Sequencial do Registro".
                   WHEN 02 THEN aux_dscritic = "Cod. Integracao do Cooperado".
                   WHEN 03 THEN aux_dscritic = "Dig. Verif. do Cod. Integracao".
                   WHEN 04 THEN aux_dscritic = "Nro Inicial do Intervalo de " +
                                               "Cheques".
                   WHEN 05 THEN aux_dscritic = "Nro Final do Intervalo de " +
                                               "Cheques".
                   WHEN 06 THEN aux_dscritic = "Codigo do Comando de Cheque".
                   WHEN 07 THEN aux_dscritic = "Cod. Motivo da Contra-Ordem".
                   OTHERWISE    aux_dscritic = "Critica desconhecida".
              END CASE.
           END.
       ELSE
            aux_dscritic = "Critica desconhecida".
    END.
ELSE
IF  aux_dsprogra = "COO407"   THEN   /* ERROS NO COO407 */
    DO:
       IF  aux_tpregist = 0   THEN
           DO:
              /* HEADER */
              CASE aux_cdocorre:
                   WHEN 02 THEN aux_dscritic = "Recusa total header invalido".
                   WHEN 03 THEN aux_dscritic = "Recusa total trailer invalido"
                                               + "/inexistente".
                   WHEN 04 THEN aux_dscritic = "Recusa parcial do detalhe".
                   WHEN 05 THEN aux_dscritic = "Recusa total tipo registro " +
                                               "inexistente".
                   WHEN 06 THEN aux_dscritic = "Recusa total sequencial " +
                                               "invalido".
                   WHEN 07 THEN aux_dscritic = "Em processamento".
                   WHEN 08 THEN aux_dscritic = "Recusa total conteudo da " +
                                               "remessa invalida".
                   OTHERWISE    aux_dscritic = "Critica desconhecida".
              END CASE.
           END.
       ELSE
       IF  aux_tpregist = 1   THEN
           DO:
              /* DETALHE UNICO */
              CASE aux_cdocorre:
                   WHEN 01 THEN aux_dscritic = "Sequencial do Registro".
                   WHEN 02 THEN aux_dscritic = "Cod. Integracao do Cooperado".
                   WHEN 03 THEN aux_dscritic = "Dig. Verif. do Cod. Integracao".
                   WHEN 04 THEN aux_dscritic = "Tipo do Comando".
                   WHEN 05 THEN aux_dscritic = "Numero do Cheque".
                   WHEN 06 THEN aux_dscritic = "Valor do Cheque".
                   WHEN 07 THEN aux_dscritic = "Motivo da Devolucao".
                   OTHERWISE    aux_dscritic = "Critica desconhecida".
              END CASE.
           END.
       ELSE
            aux_dscritic = "Critica desconhecida".
    END.
ELSE
IF  aux_dsprogra = "COO401"   THEN   /* ERROS NO COO401 */
    DO:
       IF  aux_tpregist = 0   THEN
           DO:
              /* HEADER */
              CASE aux_cdocorre:
                   WHEN 02 THEN aux_dscritic = "Recusa total header invalido".
                   WHEN 03 THEN aux_dscritic = "Recusa total trailer invalido"
                                               + "/inexistente".
                   WHEN 04 THEN aux_dscritic = "Recusa parcial do detalhe".
                   WHEN 05 THEN aux_dscritic = "Recusa total tipo registro " +
                                               "inexistente".
                   WHEN 06 THEN aux_dscritic = "Recusa total sequencial " +
                                               "invalido".
                   WHEN 07 THEN aux_dscritic = "Em processamento".
                   WHEN 08 THEN aux_dscritic = "Recusa total conteudo da " +
                                               "remessa invalida".
                   OTHERWISE    aux_dscritic = "Critica desconhecida".
              END CASE.
           END.
       ELSE
       IF  aux_tpregist = 1   THEN
           DO:
              /* DETALHE UNICO */
              CASE aux_cdocorre:
                   WHEN 01 THEN aux_dscritic = "Sequencial do Registro".
                   WHEN 02 THEN aux_dscritic = "Tipo de Detalhe".
                   WHEN 03 THEN aux_dscritic = "Cod. Integracao do Cooperado".
                   WHEN 04 THEN aux_dscritic = "Dig. Verif. do Cod. Integracao".
                   WHEN 05 THEN aux_dscritic = "Valor do Limite".
                   WHEN 06 THEN aux_dscritic = "Data do Vencimento do Limite".
                   OTHERWISE    aux_dscritic = "Critica desconhecida".
              END CASE.
           END.
       ELSE
            aux_dscritic = "Critica desconhecida".
    END.           
ELSE
IF  aux_dsprogra = "COO410"   THEN   /* ERROS NO COO410 */
    DO:
       /* 31 CORRESPONDE AOS ERROS NO DETALHE TIPO 13/14 DO COO410 */
       IF  aux_tpregist = 31   THEN
           DO:

              /* DETALHE TIPO 13 */
              IF   INTEGER(SUBSTR(aux_setlinha,45,01)) = 1   THEN
                   DO:
                      CASE aux_cdocorre:
                           WHEN 01 THEN aux_dscritic = "Sequencial do Registro".
                           WHEN 02 THEN aux_dscritic = "Tipo de Detalhe".
                           WHEN 03 THEN aux_dscritic = "Cod. do Tipo do Cartao".
                           WHEN 04 THEN aux_dscritic = "Dia do Vencimento " +
                                                       "da Fatura".       
                           WHEN 05 THEN aux_dscritic = "Indicador de Debito " +
                                                       "em Conta".
                           WHEN 06 THEN aux_dscritic = "Prefixo da Agencia".
                           WHEN 08 THEN aux_dscritic = "Numero da Conta " + 
                                                       "Integracao".
                           WHEN 10 THEN aux_dscritic = "Indicador de Mala " +
                                                       "Direta".
                           WHEN 11 THEN aux_dscritic = "Indicador de Remessa "+
                                                       "Pelo Correio".
                           WHEN 12 THEN aux_dscritic = "Indicador de " +
                                                       "Protecao Ouro".
                           WHEN 13 THEN aux_dscritic = "Nome Abreviado".
                           WHEN 16 THEN aux_dscritic = "Limite de Credito".
                           OTHERWISE    aux_dscritic = "Critica desconhecida".
                      END CASE.
                   END.
              ELSE      /* DETALHE TIPO 14 */
                   DO:
                      CASE aux_cdocorre:
                           WHEN 01 THEN aux_dscritic = "Sequencial do Registro".
                           WHEN 02 THEN aux_dscritic = "Tipo de Detalhe".
                           WHEN 03 THEN aux_dscritic = "CPF do Titular".
                           WHEN 04 THEN aux_dscritic = "Nome Abreviado".
                           WHEN 05 THEN aux_dscritic = "Prefixo da Agencia".
                           WHEN 07 THEN aux_dscritic = "Numero da Conta " + 
                                                       "Integracao".
                           WHEN 11 THEN aux_dscritic = "Numero da Conta Cartao".
                           WHEN 12 THEN aux_dscritic = "Cod. do Tipo do Cartao".
                           WHEN 13 THEN aux_dscritic = "CPF do Adicional".
                           OTHERWISE    aux_dscritic = "Critica desconhecida".
                      END CASE.
                   END.
           END.
       ELSE
       IF  aux_tpregist = 32   THEN
           DO:
              CASE aux_cdocorre:
                   WHEN 01 THEN aux_dscritic = "Sequencial do Registro".
                   WHEN 02 THEN aux_dscritic = "Tipo de Detalhe".
                   WHEN 03 THEN aux_dscritic = "Numero da Conta Cartao".
                   WHEN 04 THEN aux_dscritic = "CPF do Portador".
                   WHEN 06 THEN aux_dscritic = "Indicador de Titularidade".
                   WHEN 07 THEN aux_dscritic = "Indicador de Bloq/Desbloq/" +
                                               "Encerramento".
                   OTHERWISE    aux_dscritic = "Critica desconhecida".
              END CASE.
           END.
       ELSE
       IF  aux_tpregist = 37   THEN
           DO:
              CASE aux_cdocorre:
                   WHEN 01 THEN aux_dscritic = "Sequencial do Registro".
                   WHEN 02 THEN aux_dscritic = "Tipo de Detalhe".
                   WHEN 03 THEN aux_dscritic = "Numero da Conta Cartao".
                   WHEN 04 THEN aux_dscritic = "Valor do Novo Limite".
                   OTHERWISE    aux_dscritic = "Critica desconhecida".
              END CASE.
           END.
       ELSE
           aux_dscritic = "Critica desconhecida".
    END.           
IF  aux_dsprogra = "COO408"   THEN   /* ERROS NO COO408 */
    DO:
       IF  aux_tpregist = 0   THEN
           DO:
              /* HEADER */
              CASE aux_cdocorre:
                   WHEN 02 THEN aux_dscritic = "Recusa total header invalido".
                   WHEN 03 THEN aux_dscritic = "Recusa total trailer invalido"
                                               + "/inexistente".
                   WHEN 04 THEN aux_dscritic = "Recusa parcial do detalhe".
                   WHEN 05 THEN aux_dscritic = "Recusa total tipo registro " +
                                               "inexistente".
                   WHEN 06 THEN aux_dscritic = "Recusa total sequencial " +
                                               "invalido".
                   WHEN 07 THEN aux_dscritic = "Em processamento".
                   WHEN 08 THEN aux_dscritic = "Recusa total conteudo da " +
                                               "remessa invalida".
                   OTHERWISE    aux_dscritic = "Critica desconhecida".
              END CASE.
           END.
       ELSE
       IF  aux_tpregist = 1   THEN
           DO:
              /* DETALHE UNICO */
              CASE aux_cdocorre:
                   WHEN 01 THEN aux_dscritic = "Sequencial do Registro".
                   WHEN 03 THEN aux_dscritic = "Cod. Integracao do Cooperado".
                   WHEN 04 THEN aux_dscritic = "Dig. Verif. do Cod. Integracao".
                   WHEN 05 THEN aux_dscritic = "Tipo de comando errado".
                   WHEN 06 THEN aux_dscritic = "Tipo de pessoa".
                   WHEN 07 THEN aux_dscritic = "CPF/CNPJ errado".
                   WHEN 08 THEN aux_dscritic = "Numero do cheque".
                   WHEN 09 THEN aux_dscritic = "Valor do cheque".
                   WHEN 10 THEN aux_dscritic = "Motivo da devolucao".
                   WHEN 11 THEN aux_dscritic = "Data da devolucao".
                   WHEN 12 THEN aux_dscritic = "Nome do cooperado".
                   WHEN 13 THEN aux_dscritic = "Titularidade".
                   WHEN 14 THEN aux_dscritic = "Data da inclusao".
                   WHEN 15 THEN aux_dscritic = "Seq. do cheque do titular".
                   OTHERWISE    aux_dscritic = "Critica desconhecida".
              END CASE.
           END.
       ELSE
            aux_dscritic = "Critica desconhecida".
    END.

/*............................................................................*/
